!> Compute source POS/VPOS fields from live native arrays.
module forecast_output_grid_calculations
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double, c_f_pointer, c_associated
  use forecast_output_request_types, only: type_fprqdyn, increment_output_counter
  use forecast_output_request_views, only: native_output_field_view, native_output_view_counters, output_field_map
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_grid_motion_types, only: native_grid_motion_state
  use physical_constant_setup_port, only: forecast_physical_constants
  use md2asm_hybrid_pressure_one_based, only: hybrid_pressure_controls, compute_hybrid_pressure_one_based
  use md2asm_moist_air_gas_properties, only: moist_air_constants, compute_moist_air_properties
  use forecast_surface_temperature_extrapolation, only: ctstar
  use forecast_pressure_level_interpolation, only: ppinit, ppflev, ppsta, ppt
  use forecast_pressure_humidity_output, only: ppq
  implicit none
  private
  public :: native_output_grid_sources, calculate_output_grid_fields
  !> Borrow actual geometry, motion, constituent storage and constants.
  !! indices name humidity/liquid/ice/rain/snow in the live constituent owner.
  !! water_enabled is the source thermal-activity projection, in that order,
  !! followed by graupel. It supplies metadata, not a calculated field.
  type :: native_output_grid_sources
    type(native_geometry_state), pointer :: geometry => null()
    type(native_grid_motion_state), pointer :: motion => null()
    type(forecast_physical_constants), pointer :: constants => null()
    real(real64), pointer :: constituents(:, :, :, :) => null()
    integer(int32) :: constituent_index(5) = 0
    logical :: water_enabled(6) = .false.
    logical :: old_postprocessing = .false., no_surface_temperature = .false.
    integer(int64) :: budget_bytes = 0
  end type
  interface
    function output_exp(x) bind(c, name='exp') result(value)
      import c_double
      real(c_double), value :: x
      real(c_double) :: value
    end function
    function output_log(x) bind(c, name='log') result(value)
      import c_double
      real(c_double), value :: x
      real(c_double) :: value
    end function
  end interface
contains
  !> Validate native shape and workspace bounds before entering numerical work.
  !! fit and auxiliary have (pitch,source field capacity,local blocks).
  !! kind1 uses target pressures in Pa; kind5 uses model-level numbers.
  !! Only active rows change. Every source repeated pressure/math pass remains.
  !! Source-selected P24/L19/2048points is retained separately from compiled
  !! live bounds P1:24,L2:512,target1:4096. No numerical acceptance is claimed.
  integer(int32) function calculate_output_grid_fields(request, inputs, targets, kind, fit, auxiliary, &
                                                       view_counters, calls) result(status)
    type(type_fprqdyn), target, intent(in) :: request
    type(native_output_grid_sources), intent(in) :: inputs
    real(real64), intent(in) :: targets(:)
    integer(int32), intent(in) :: kind
    real(real64), intent(inout) :: fit(:, :, :), auxiliary(:, :, :)
    type(native_output_view_counters), intent(inout) :: view_counters
    integer(int64), intent(inout) :: calls
    integer :: pitch, levels, points, blocks, block, active, targets_count
    integer :: mi(3), si(3), j
    integer(int64) :: workspace
    status = 2
    if (.not. associated(inputs%geometry) .or. .not. associated(inputs%motion) .or. &
        .not. associated(inputs%constants) .or. .not. associated(inputs%constituents)) return
    if (.not. associated(inputs%geometry%vertical)) return
    if (.not. allocated(inputs%motion%gmv) .or. .not. allocated(inputs%motion%gmvs)) return
    if (.not. allocated(inputs%geometry%terrain%blocks) .or. &
        .not. allocated(inputs%geometry%spherical%blocked%gm)) return
    pitch = size(inputs%motion%gmv, 1); levels = size(inputs%motion%gmv, 2)
    blocks = size(inputs%motion%gmv, 4); points = inputs%geometry%partition%ngptot
    targets_count = size(targets)
    if (pitch < 1 .or. pitch > 24 .or. levels < 2 .or. levels > 512 .or. points < 1) return
    if (targets_count < 1 .or. targets_count > 4096 .or. (kind /= 1 .and. kind /= 5)) return
    if (int(blocks, int64) /= (int(points, int64) + pitch - 1)/pitch) return
    if (size(inputs%geometry%terrain%blocks) /= blocks) return
    if (any(shape(inputs%geometry%spherical%blocked%gm) /= [pitch, blocks])) return
    if (size(inputs%motion%gmvs, 1) /= pitch .or. size(inputs%motion%gmvs, 3) /= blocks) return
    if (size(inputs%constituents, 1) /= pitch .or. size(inputs%constituents, 2) /= levels .or. &
        size(inputs%constituents, 4) /= blocks) return
    if (.not. is_contiguous(inputs%constituents) .or. .not. is_contiguous(targets) .or. &
        .not. is_contiguous(fit) .or. .not. is_contiguous(auxiliary)) return
    mi = [inputs%motion%yt0%mt, inputs%motion%yt0%mu, inputs%motion%yt0%mv]
    si = [inputs%motion%yt0%msp, inputs%motion%yt0%mspl, inputs%motion%yt0%mspm]
    if (any(mi < 1) .or. any(mi > size(inputs%motion%gmv, 3))) return
    if (any(si < 1) .or. any(si > size(inputs%motion%gmvs, 2))) return
    if (any(inputs%constituent_index < 1) .or. any(inputs%constituent_index > size(inputs%constituents, 3))) return
    if (size(fit, 1) /= pitch .or. size(auxiliary, 1) /= pitch) return
    if (size(fit, 2) < request%nfpgt1 .or. size(auxiliary, 2) < request%nfpauxb) return
    if (size(fit, 3) /= blocks .or. size(auxiliary, 3) /= blocks) return
    if (.not. allocated(request%ll) .or. .not. allocated(request%ilvp)) return
    if (.not. allocated(inputs%geometry%vertical%valh) .or. .not. allocated(inputs%geometry%vertical%vbh)) return
    if (.not. allocated(inputs%geometry%vertical%vc) .or. .not. allocated(inputs%geometry%vertical%vaf) .or. &
        .not. allocated(inputs%geometry%vertical%vbf) .or. .not. allocated(inputs%geometry%vertical%vdela) .or. &
        .not. allocated(inputs%geometry%vertical%vdelb)) return
    if (size(inputs%geometry%vertical%valh) < levels + 1 .or. size(inputs%geometry%vertical%vbh) < levels + 1) return
    if (min(size(inputs%geometry%vertical%vc), size(inputs%geometry%vertical%vaf), &
            size(inputs%geometry%vertical%vbf), size(inputs%geometry%vertical%vdela), &
            size(inputs%geometry%vertical%vdelb)) < levels) return
    workspace = 8_int64*pitch*(22_int64*levels + 2_int64*4*(levels + 1) + 12_int64*targets_count + 64_int64)
    workspace = workspace + 4_int64*pitch*(6_int64*targets_count + 2_int64)
    if (inputs%budget_bytes <= workspace .or. inputs%budget_bytes > 68719476736_int64) return
    if (workspace > 33554432_int64) return
    do block = 1, blocks
      active = min(pitch, points - (block - 1)*pitch)
      if (.not. allocated(inputs%geometry%terrain%blocks(block)%orog) .or. &
          .not. allocated(inputs%geometry%terrain%blocks(block)%orogl) .or. &
          .not. allocated(inputs%geometry%terrain%blocks(block)%orogm)) return
      if (min(size(inputs%geometry%terrain%blocks(block)%orog), size(inputs%geometry%terrain%blocks(block)%orogl), &
              size(inputs%geometry%terrain%blocks(block)%orogm)) < active) return
    end do
    do block = 1, blocks
      active = min(pitch, points - (block - 1)*pitch)
      call calculate_block(request, inputs, targets, kind, pitch, levels, targets_count, block, active, &
                           fit(:, :, block), auxiliary(:, :, block), view_counters, status)
      if (status /= 0) return
    end do
    call increment_output_counter(calls)
    status = 0
  end function

  !> Own compiler-native local work after complete parent admission.
  !! The caller provides at least the declared32MiB stack-workspace bound.
  !! All pressure/temperature arrays preserve source half/full lower bounds.
  subroutine calculate_block(request, inputs, targets, kind, p, l, t, block, active, fit, auxiliary, counters, status)
    type(type_fprqdyn), target, intent(in) :: request
    type(native_output_grid_sources), intent(in) :: inputs
    real(real64), intent(in) :: targets(:)
    integer(int32), intent(in) :: kind
    integer, intent(in) :: p, l, t, block, active
    real(real64), intent(inout) :: fit(:, :), auxiliary(:, :)
    type(native_output_view_counters), intent(inout) :: counters
    integer(int32), intent(out) :: status
    real(real64) :: half(p, 0:l), full(p, l), coefficients(p, l, 7), zero(p, l)
    real(real64) :: heat(p, l), gas(p, l), kappa(p, l), surface(p), tstar(p), tzero(p)
    real(real64) :: terrain(p), terrain_l(p), terrain_m(p)
    real(real64) :: xp(p, 0:l, 4), xpd(p, 0:l, 4), target_pressure(p, t), target_log(p, t)
    real(real64) :: standard_temperature(p, l + 1), standard_geopotential(p, l + 1)
    real(real64) :: temperature_output(p, t), humidity_output(p, t), log_surface(p)
    integer(int32) :: level_below(p, t, 4)
    logical :: below_full(p, t), below_half(p, t), any_below_full(p), any_below_half(p)
    type(hybrid_pressure_controls) :: pressure_control
    type(moist_air_constants) :: gas_control
    real(real64), volatile :: discarded, discarded_second, discarded_third
    real(real64) :: lapse
    integer :: i, k, model_level, temperature_index, u_index, v_index
    type(native_output_field_view) :: view
    integer(int32), pointer :: level_indices(:)
    integer :: field, field_level, destination, code, which
    integer(int32), parameter :: codes(3) = [6, 5, 454]
    call increment_output_counter(counters%calls(1))
    zero = 0.0_real64
    temperature_index = inputs%motion%yt0%mt
    u_index = inputs%motion%yt0%mu; v_index = inputs%motion%yt0%mv
    pressure_control%approximate_mode = inputs%geometry%vertical%configuration%ndlnpr
    pressure_control%finite_elements = inputs%geometry%vertical%configuration%lvertfe /= 0
    pressure_control%arithmetic_full_pressure = inputs%geometry%vertical%configuration%laprxpk /= 0
    pressure_control%top_pressure = inputs%geometry%vertical%toppres
    pressure_control%top_alpha = inputs%geometry%vertical%configuration%rhydr0
    pressure_control%dry_gas_constant = inputs%constants%rd
    pressure_control%dry_isochoric_heat_capacity = inputs%constants%rcvd
    gas_control%dry_gas_constant = inputs%constants%rd
    gas_control%dry_heat_capacity = inputs%constants%rcpd
    gas_control%vapour_gas_constant = inputs%constants%rv
    gas_control%vapour_heat_capacity = inputs%constants%rcpv
    gas_control%liquid_heat_capacity = inputs%constants%rcw
    gas_control%ice_heat_capacity = inputs%constants%rcs
    lapse = inputs%geometry%atmosphere%reference_tables(1)%gradient(1)
    discarded = lapse/inputs%constants%rg
    do i = 1, active
      terrain(i) = inputs%geometry%terrain%blocks(block)%orog(i)
      terrain_l(i) = inputs%geometry%terrain%blocks(block)%orogl(i)
      terrain_m(i) = inputs%geometry%terrain%blocks(block)%orogm(i)
      surface(i) = output_exp(inputs%motion%gmvs(i, inputs%motion%yt0%msp, block))
    end do
    call pressure_pass()
    if (status /= 0) return
    call ctstar(p, 1, active, inputs%motion%gmv(:, l - 1, temperature_index, block), surface, full(:, l - 1), &
                terrain, tstar, tzero, lapse, inputs%constants%rg, inputs%constants%rd, status)
    if (status /= 0) return
    do i = 1, active
      discarded = inputs%geometry%spherical%blocked%gm(i, block)*inputs%geometry%spherical%blocked%gm(i, block)
      discarded_second = terrain_l(i)*inputs%geometry%spherical%blocked%gm(i, block)
      discarded_third = terrain_m(i)*inputs%geometry%spherical%blocked%gm(i, block)
    end do
    do k = 1, l
      do i = 1, active
        discarded = inputs%motion%gmv(i, k, u_index, block)*inputs%geometry%spherical%blocked%gm(i, block)
        discarded = inputs%motion%gmv(i, k, v_index, block)*inputs%geometry%spherical%blocked%gm(i, block)
      end do
    end do
    call compute_moist_air_properties(gas_control, p, 1, active, l, inputs%water_enabled, status, &
                                      heat_capacity=heat, gas_constant=gas, kappa=kappa, &
                                      vapour=inputs%constituents(:, :, inputs%constituent_index(1), block), &
                                      liquid=inputs%constituents(:, :, inputs%constituent_index(2), block), &
                                      ice=inputs%constituents(:, :, inputs%constituent_index(3), block), &
                                      rain=inputs%constituents(:, :, inputs%constituent_index(4), block), &
                                      snow=inputs%constituents(:, :, inputs%constituent_index(5), block), graupel=zero)
    if (status /= 0) return
    do i = 1, active
      surface(i) = output_exp(inputs%motion%gmvs(i, inputs%motion%yt0%msp, block))
    end do
    call pressure_pass()
    if (status /= 0) return
    call ctstar(p, 1, active, inputs%motion%gmv(:, l - 1, temperature_index, block), surface, full(:, l - 1), &
                terrain, tstar, tzero, lapse, inputs%constants%rg, inputs%constants%rd, status)
    if (status /= 0) return
    do k = 1, t
      if (kind == 5) then
        model_level = int(targets(k))
        if (model_level < 1 .or. model_level > l) then
          status = 2
          return
        end if
      end if
      do i = 1, active
        if (kind == 5) then
          target_pressure(i, k) = full(i, model_level)
        else
          target_pressure(i, k) = targets(k)
        end if
        target_log(i, k) = output_log(target_pressure(i, k))
      end do
    end do
    call ppinit(p, 1, active, l, 4, half, full, xp, xpd, status)
    if (status /= 0) return
    call ppflev(p, 1, active, l, t, 4, target_pressure, half, full, level_below, below_full, below_half, &
                any_below_full, any_below_half, status)
    if (status /= 0) return
    call ppsta(inputs%constants, inputs%geometry%atmosphere%reference_tables(2), 'PPREF', p, 1, active, l + 1, 1, &
               xp(:, :, 2), xp(:, :, 4), standard_temperature, standard_geopotential, status)
    if (status /= 0) return
    call ppt(inputs%constants, inputs%geometry%atmosphere%reference_tables(2), lapse, inputs%old_postprocessing, &
             inputs%no_surface_temperature, p, 1, active, l, t, 1, 4, level_below, target_pressure, target_log, &
             below_full, below_half, any_below_full, any_below_half, .true., terrain, xp, xpd, tstar, tzero, gas, &
             inputs%motion%gmv(:, :, temperature_index, block), temperature_output, psttf=standard_temperature, status=status)
    if (status /= 0) return
    if (kind == 5) then
      call ppq(p, 1, active, l, t, 1, 4, level_below, target_pressure, below_full, any_below_full, xp, xpd, &
               inputs%constituents(:, :, inputs%constituent_index(1), block), humidity_output, status=status)
      if (status /= 0) return
    end if
    do which = 1, 3
      code = codes(which)
      status = output_field_map(request, int(code, int32), view, counters)
      if (status /= 0) return
      if (view%level_count == 0) cycle
      if (view%level_count < 0 .or. view%level_count > t .or. .not. c_associated(view%level_indices)) then
        status = 2
        return
      end if
      call c_f_pointer(view%level_indices, level_indices, [int(view%level_count)])
      if (code == 454) then
        do i = 1, active
          log_surface(i) = output_log(surface(i))
        end do
      end if
      do field = 1, int(view%level_count)
        destination = int(view%index) + field - 1
        field_level = level_indices(field)
        if (code /= 454) then
          if (field_level < 1 .or. field_level > t) then
            status = 2
            return
          end if
        end if
        if (view%fit /= 0) then
          if (destination < 1 .or. destination > size(fit, 2)) then
            status = 2
            return
          end if
        else
          if (destination < 1 .or. destination > size(auxiliary, 2)) then
            status = 2
            return
          end if
        end if
        do i = 1, active
          select case (code)
          case (6)
            call store_value(humidity_output(i, field_level))
          case (5)
            call store_value(temperature_output(i, field_level))
          case (454)
            call store_value(log_surface(i))
          end select
        end do
      end do
    end do
    status = 0
  contains
    subroutine pressure_pass()
      half(1:active, l) = surface(1:active)
      call compute_hybrid_pressure_one_based(pressure_control, p, 1, active, l, &
                                             inputs%geometry%vertical%valh, inputs%geometry%vertical%vbh, half, status, &
                                             number_fields=7, field_index=[1, 2, 3, 4, 5, 6, 7], vc=inputs%geometry%vertical%vc, &
                                             full_a=inputs%geometry%vertical%vaf, full_b=inputs%geometry%vertical%vbf, &
                                             delta_a=inputs%geometry%vertical%vdela, delta_b=inputs%geometry%vertical%vdelb, &
                                             coefficients=coefficients, full_pressure=full)
    end subroutine
    subroutine store_value(value)
      real(real64), intent(in) :: value
      if (view%fit /= 0) then
        fit(i, destination) = value
      else
        auxiliary(i, destination) = value
      end if
    end subroutine
  end subroutine
end module
