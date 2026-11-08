!> Update provisional hydrostatic fields after departure-point interpolation.
!! LAPINEB combines the complete native LARCINB transport with continuity,
!! wind rotation, temperature and constituent updates in the source order.
module forecast_runtime_source_lapineb
  use iso_fortran_env, only: int32, int64, real64
  use ieee_arithmetic, only: ieee_round_type, ieee_nearest, ieee_get_rounding_mode, operator(/=)
  use md2asm_departure_field_transport, only: departure_transport_controls, general_transport_map, &
                                              constituent_transport_map, transport_hydrostatic_departure_fields
  use md2asm_departure_interpolation_weights, only: departure_weight_outputs
  use md2asm_weno_departure_interpolation, only: weno_interpolation_controls
  use md2asm_vertical_operators, only: vertical_operator_matrices, apply_vertical_operator
  use md2asm_prognostic_departure_update,only:prognostic_departure_controls,prognostic_departure_state_map,prognostic_constituent_destination
  use forecast_departure_source_counters, only: departure_source_hit
  implicit none
  private
  public :: prognostic_departure_controls, prognostic_departure_state_map
  public :: prognostic_constituent_destination, update_prognostic_departure_fields

  !> Original named switches for the selected hydrostatic, spherical route.
  !! The three lag values select the third-order transport method. The other
  !! named switches retain their original logical meanings and are admitted
  !! only in the combinations stated by this entry.
  ! Canonical prognostic_departure_controls declaration is imported without a copy.

  !> One-based output slots in the caller's native state arrays.
  !! general(1:3) names U,V,T; surface_pressure names logarithmic pressure.
  !! When spectral_moisture_copy is true, copy moisture_source to moisture_target.
  ! Canonical prognostic_departure_state_map declaration is imported without a copy.

  !> State destination and grid-point flag for one original constituent.
  !! Its full16-character name and transport flags remain in the separate
  !! constituent_transport_map. Array order remains the original field order.
  ! Canonical prognostic_constituent_destination declaration is imported without a copy.
contains
  !> Complete selected LAPINEB calculation using native arrays and owned work.
  !! pitch is the number of allocated columns; first:last is the active range.
  !! levels is the live full-level count. source(source_pitch,planes) is a
  !! contiguous read-only borrowed transport owner. general_state(pitch,levels,:)
  !! contains wind(m/s) and temperature(K); surface_state(pitch,:) contains
  !! log(p_s/p_0), which has no unit. constituent_state contains mass fractions.
  !! departure_rx,departure_ry and north_m,north_l are dimensionless wind-basis
  !! coefficients and need only span the active rows first:last. layer_weight
  !! is VDELB and inverse_layer_width is VFE_RDETAH.
  !! The latter is used only for finite elements. dry_gas_constant is in J/(kg K).
  !! Diagnostic and split-physics arrays retain the units and slots declared
  !! by the complete native LARCINB interface. Only active cells are changed.
  !! Caller-owned source, state, geometry and output views obey the selected
  !! original alias contract. No pointer to a private workspace escapes.
  !! All consumed input owners remain alive for the call. Status0 succeeds;
  !! status1 refuses workspace and status2 refuses metadata or a child. A late
  !! child refusal leaves the complete parent unaccepted. No original
  !! OpenIFS numerical routine supplies a calculation.
  subroutine update_prognostic_departure_fields(source_pitch, pitch, first, last, levels, c, state_map, &
                            transport, maps, components, destinations, weights, source, layer_weight, inverse_layer_width, tables, &
                                                north_m, north_l, departure_rx, departure_ry, old_moisture, dry_gas_constant, &
                                        general_state, surface_state, constituent_state, diffusion_general, diffusion_constituent, &
                                     linear_general, split_u, split_v, split_temperature, split_constituent, status, weno_control, &
                                                half_level_coordinate)
    integer(int32), intent(in) :: source_pitch, pitch, first, last, levels
    type(prognostic_departure_controls), intent(in) :: c
    type(prognostic_departure_state_map), intent(in) :: state_map
    type(departure_transport_controls), intent(in) :: transport
    type(general_transport_map), intent(in) :: maps(3)
    type(constituent_transport_map), intent(in) :: components(:)
    type(prognostic_constituent_destination), intent(in) :: destinations(:)
    type(departure_weight_outputs), intent(in) :: weights
    real(real64), contiguous, target, intent(in) :: source(:, :)
    real(real64), intent(in) :: layer_weight(:), inverse_layer_width(:)
    type(vertical_operator_matrices), intent(in) :: tables
    real(real64), intent(in) :: north_m(:), north_l(:), departure_rx(:, :), departure_ry(:, :), old_moisture(:, :)
    real(real64), intent(in) :: dry_gas_constant
    real(real64), intent(inout) :: general_state(:, :, :), surface_state(:, :), constituent_state(:, :, :)
    real(real64), intent(inout) :: diffusion_general(:, :, :), diffusion_constituent(:, :, :), linear_general(:, :, :)
    real(real64), intent(inout) :: split_u(:, :), split_v(:, :), split_constituent(:, :, :)
    real(real64), target, intent(inout) :: split_temperature(:, :)
    integer(int32), intent(out) :: status
    type(weno_interpolation_controls), intent(in) :: weno_control
    real(real64), intent(in), optional :: half_level_coordinate(0:)
    type(general_transport_map) :: local_maps(3)
    real(real64), allocatable :: general_term(:, :, :), constituent_term(:, :, :), continuity(:, :, :)
    real(real64), allocatable, target :: saved_wind(:, :, :), split_wind(:, :, :)
    real(real64), allocatable :: integral_input(:, :), integral_output(:, :)
    real(real64), allocatable, volatile :: dry_product(:, :)
    integer(int64) :: cells, source_scratch_bytes
    integer :: field, variable, other, slot, k, i, allocation_status, wind_u, wind_v, temperature
    real(real64) :: a, b, p, q, fu, fv, old_u, old_v, total, increment, weight
    logical :: convergence

    status = 2_int32
    if (pitch < 1 .or. pitch > 1024 .or. levels < 4 .or. levels > 256) return
    if (first < 1 .or. first > pitch + 1 .or. last < first - 1 .or. last > pitch) return
    if (c%lnhee .or. c%lnhdyn .or. c%lgwadv .or. c%lrdbbc .or. c%lsldia .or. c%lslinlc2 .or. c%lslinl) return
    if (c%lpc_cheap .or. c%lrhs_curv .or. c%ladvf .or. c%l2tlff .or. c%lrplane .or. .not. c%l_rdry_vd) return
    if (c%nvlag /= 3 .or. c%nwlag /= 3 .or. c%ntlag /= 3) return
    if (c%finite_elements .and. c%integral_boundary_condition /= 3) return
    if (c%main_field_count < 1 .or. c%main_field_count > 64) return
    if (size(components) > 2163 .or. size(destinations) /= size(components)) return
    if (size(layer_weight) < levels) return
    if (size(north_m) < last .or. size(north_l) < last) return
    if (.not. valid_plane(departure_rx) .or. .not. valid_plane(departure_ry)) return
    if (size(general_state, 1) /= pitch .or. size(general_state, 2) < levels) return
    if (size(surface_state, 1) /= pitch) return
    if (size(constituent_state, 1) /= pitch .or. size(constituent_state, 2) < levels) return
    if (state_map%surface_pressure < 1 .or. state_map%surface_pressure > size(surface_state, 2)) return
    do variable = 1, 3
      slot = state_map%general(variable)
      if (slot < 1 .or. slot > size(general_state, 3)) return
      do other = 1, variable - 1
        if (slot == state_map%general(other)) return
      end do
      slot = maps(variable)%result_slot
      if (slot < 1 .or. slot > c%main_field_count) return
    end do
    do field = 1, size(components)
      if (.not. components(field)%advected) cycle
      convergence = components(field)%name == 'CVGQ            ' .and. destinations(field)%grid_point
      if (convergence) then
        if (components(field)%external_grid) return
        if (.not. valid_plane(old_moisture)) return
      else
        if (components(field)%external_grid) cycle
      end if
      slot = destinations(field)%slot
      if (slot < 1 .or. slot > size(constituent_state, 3)) return
    end do
    if (state_map%spectral_moisture_copy) then
      if (state_map%moisture_source < 1 .or. state_map%moisture_source > size(constituent_state, 3)) return
      if (state_map%moisture_target < 1 .or. state_map%moisture_target > size(constituent_state, 3)) return
    end if
    if (transport%split_physics) then
      if (.not. valid_plane(split_u) .or. .not. valid_plane(split_v) .or. .not. valid_plane(split_temperature)) return
    end if
    if (c%finite_elements) then
      if (first > pitch .or. size(inverse_layer_width) < levels) return
      if (.not. associated(tables%rintbf11)) return
      if (size(tables%rintbf11, 1) /= levels + 1 .or. size(tables%rintbf11, 2) /= levels + 2) return
      if (.not. is_contiguous(tables%rintbf11)) return
    end if
    if (.not. environment_supported()) return
    cells = int(pitch, int64)*int(levels, int64)
    source_scratch_bytes = 8_int64*cells*int(3*c%main_field_count + size(components) + 9, int64) + &
                           24_int64*int(pitch, int64) + 8_int64*int(pitch, int64)*int(2*levels + 3, int64)
    if (source_scratch_bytes > 536870912_int64) return
    allocate (general_term(pitch, levels, c%main_field_count), &
              constituent_term(pitch, levels, size(components)), continuity(pitch, levels, 2), &
              saved_wind(pitch, levels, 2), split_wind(pitch, levels, 2), dry_product(pitch, levels), &
              stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1_int32
      return
    end if
    if (c%finite_elements) then
      allocate (integral_input(pitch, 0:levels + 1), integral_output(pitch, levels + 1), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1_int32
        return
      end if
    end if
    ! The source initializes the whole general-term owner to positive zero.
    general_term = 0.0_real64
    local_maps = maps
    local_maps(1)%saved => saved_wind(:, :, 1)
    local_maps(2)%saved => saved_wind(:, :, 2)
    if (transport%split_physics) then
      split_wind = 0.0_real64
      local_maps(1)%physics => split_wind(:, :, 1)
      local_maps(2)%physics => split_wind(:, :, 2)
      local_maps(3)%physics => split_temperature(1:pitch, 1:levels)
    end if
    call transport_hydrostatic_departure_fields(source_pitch, pitch, first, last, levels, transport, local_maps, &
                            components, weights, source, general_term, constituent_term, diffusion_general, diffusion_constituent, &
                                linear_general, split_constituent, continuity(:, :, 2), continuity(:, :, 1), status, weno_control, &
                                                half_level_coordinate)
    if (status /= 0) return

    ! Add the column integral to logarithmic surface pressure before wind.
    slot = state_map%surface_pressure
    if (c%finite_elements) then
      integral_input = 0.0_real64
      if (first <= last) then
        do k = 1, levels
          weight = layer_weight(k)*inverse_layer_width(k)
          do i = first, last
            total = continuity(i, k, 1) + continuity(i, k, 2)
            integral_input(i, k) = weight*total
          end do
        end do
      end if
      call apply_vertical_operator(tables, .true., int(c%integral_boundary_condition), &
                               int(c%derivative_boundary_condition), 'ITOP', '11', int(pitch), int(first), int(last), int(levels), &
                                   integral_input, integral_output, status, chunk=int(pitch))
      if (status /= 0) return
      call departure_source_hit(1_int32, 9_int32)
      do i = first, last
        surface_state(i, slot) = surface_state(i, slot) + integral_output(i, levels + 1)
      end do
    else
      do k = 1, levels
        do i = first, last
          total = continuity(i, k, 1) + continuity(i, k, 2)
          increment = layer_weight(k)*total
          surface_state(i, slot) = surface_state(i, slot) + increment
        end do
      end do
    end if

    wind_u = state_map%general(1)
    wind_v = state_map%general(2)
    temperature = state_map%general(3)
    do k = 1, levels
      do i = first, last
        a = departure_rx(i, k)*north_m(i)
        b = departure_ry(i, k)*north_l(i)
        p = a - b
        a = departure_ry(i, k)*north_m(i)
        b = departure_rx(i, k)*north_l(i)
        q = a + b
        fu = general_term(i, k, maps(1)%result_slot)
        fv = general_term(i, k, maps(2)%result_slot)
        old_u = general_state(i, k, wind_u)
        old_v = general_state(i, k, wind_v)
        a = p*fu
        total = old_u + a
        b = q*fv
        general_state(i, k, wind_u) = total + b
        a = q*fu
        total = old_v - a
        b = p*fv
        general_state(i, k, wind_v) = total + b
        if (transport%split_physics) then
          fu = split_wind(i, k, 1)
          fv = split_wind(i, k, 2)
          a = p*fu
          b = q*fv
          split_u(i, k) = a + b
          a = -q
          a = a*fu
          b = p*fv
          split_v(i, k) = a + b
        end if
      end do
    end do
    do k = 1, levels
      do i = first, last
        general_state(i, k, temperature) = general_state(i, k, temperature) + general_term(i, k, maps(3)%result_slot)
      end do
    end do
    do field = 1, size(components)
      if (.not. components(field)%advected) cycle
      convergence = components(field)%name == 'CVGQ            ' .and. destinations(field)%grid_point
      if (.not. convergence .and. components(field)%external_grid) cycle
      slot = destinations(field)%slot
      do k = 1, levels
        do i = first, last
          if (convergence) then
            constituent_state(i, k, slot) = constituent_term(i, k, field) - old_moisture(i, k)
          else
            constituent_state(i, k, slot) = constituent_state(i, k, slot) + constituent_term(i, k, field)
          end if
        end do
      end do
    end do
    if (state_map%spectral_moisture_copy) then
      do k = 1, levels
        do i = first, last
          constituent_state(i, k, state_map%moisture_target) = constituent_state(i, k, state_map%moisture_source)
        end do
      end do
    end if
    ! This source-defined temporary is not returned, but its multiplication
    ! contributes to the observable floating-point status and must execute.
    do k = 1, levels
      do i = first, last
        dry_product(i, k) = dry_gas_constant*general_state(i, k, temperature)
      end do
    end do
    call departure_source_hit(1_int32, 8_int32)
    status = 0_int32
  contains
    logical function valid_plane(array) result(valid)
      real(real64), intent(in) :: array(:, :)
      valid = size(array, 1) == pitch .and. size(array, 2) >= levels
    end function
  end subroutine

  logical function environment_supported() result(supported)
    type(ieee_round_type) :: mode
    real(real64), volatile :: normal_value, half, subnormal
    supported = .false.
    call ieee_get_rounding_mode(mode)
    if (mode /= ieee_nearest) return
    normal_value = tiny(1.0_real64)
    half = 0.5_real64
    subnormal = normal_value*half
    if (subnormal /= transfer(int(z'0008000000000000', int64), 1.0_real64)) return
    supported = .true.
  end function
end module forecast_runtime_source_lapineb
