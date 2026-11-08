!> Hydrostatic two-time-level LATTEX parent from the selected generated source.
!! The caller supplies typed current fields, immutable geometry arrays and time
!! coefficients. This routine owns the wind, temperature and constituent update.
!! It calls the complete own Fortran LATTEX_DNT child, never the original model.
module md2asm_transport_equation_parent
  use iso_fortran_env, only: int32, real64
  use, intrinsic :: ieee_arithmetic, only: ieee_is_finite
  use md2asm_two_level_transport_terms, only: transport_term_controls, &
                                              transport_term_fields, transport_field_view, apply_two_level_transport_terms
  implicit none
  private
  public :: transport_parent_controls, transport_parent_fields, transport_constituent
  public :: prepare_transport_equation_terms
  !> The selected route has finite-element, hydrostatic, two-level transport.
  type :: transport_parent_controls
    type(transport_term_controls) :: term
    logical :: two_time_levels = .true., finite_element = .true.
    logical :: nonhydrostatic = .false., semi_lagrangian_acceleration = .false.
    logical :: split_constituents = .false., curved_rhs = .false., advective_forcing = .false.
    logical :: full_coriolis_geometry = .false., cartesian_wind = .false.
    logical :: moisture_convergence_copy = .false., stable_extrapolation = .false.
    integer(int32) :: wind_transport_points = 3, temperature_transport_points = 3
    real(real64) :: interpolation_factor = 1.0_real64
    real(real64) :: dry_gas_constant, reference_temperature
    real(real64) :: gravity, planet_radius
    real(real64) :: rotation_rate, orographic_scale
  end type
  !> Three DNT field groups retain complete padded owner views.
  type :: transport_parent_fields
    type(transport_term_fields) :: wind_u, wind_v, temperature
  end type
  !> One constituent in original increasing descriptor order.
  !! current has shape (pitch,levels); transported stores padded physical levels.
  type :: transport_constituent
    logical :: advected = .false., spline_transform = .false.
    real(real64), pointer, contiguous :: current(:, :) => null()
    real(real64), pointer, contiguous :: transported(:, :) => null()
  end type
contains
  !> Form forcing and apply the three complete transport updates.
  !! Wind is in m/s, wind tendency in m/s**2, temperature in K and its
  !! tendency in K/s. half_time_step, wind_time_factor and
  !! temperature_time_factor(:) are supplied time coefficients in seconds.
  !! coriolis(:) is in 1/s. surface_geopotential(:) is in m**2/s**2;
  !! its two horizontal derivatives are in m/s**2. The full and half-level
  !! correction arrays retain their supplied kelvin units.
  !! pressure_transport(:,2:levels+1)*inverse_layer_thickness(:,1:levels)
  !! supplies the original finite-element vertical transport factor.
  !! Inputs and written views are disjoint. All owner checks and private
  !! allocation precede writes. Status 0 succeeds, 1 refuses allocation,
  !! and 2 refuses a selected-route or owner condition.
  subroutine prepare_transport_equation_terms(pitch, levels, first, last, &
                                              transport_first_level, transport_last_level, half_time_step, wind_time_factor, &
                                              temperature_time_factor, pesgp, pesgm, c, coriolis, surface_geopotential, &
                                              orography_x, orography_y, full_level_correction, half_level_correction, &
                                              linear_u, linear_v, linear_temperature, tendency_u, tendency_v, &
                                              tendency_temperature, &
                                              inverse_layer_thickness, pressure_transport, f, constituents, status)
    integer(int32), intent(in) :: pitch, levels, first, last
    integer(int32), intent(in) :: transport_first_level, transport_last_level
    real(real64), intent(in) :: half_time_step, wind_time_factor, pesgp, pesgm
    real(real64), intent(in) :: temperature_time_factor(:), coriolis(:), surface_geopotential(:)
    real(real64), intent(in) :: orography_x(:), orography_y(:)
    real(real64), intent(in) :: full_level_correction(:), half_level_correction(0:)
    real(real64), intent(in) :: linear_u(:, :), linear_v(:, :), linear_temperature(:, :)
    real(real64), intent(in) :: tendency_u(:, :), tendency_v(:, :), tendency_temperature(:, :)
    real(real64), intent(in) :: inverse_layer_thickness(:, :), pressure_transport(:, :)
    type(transport_parent_controls), intent(in) :: c
    type(transport_parent_fields), intent(inout) :: f
    type(transport_constituent), intent(inout) :: constituents(:)
    integer(int32), intent(out) :: status
    type(transport_term_fields) :: u, v, temp
    real(real64), allocatable, target :: source(:, :, :)
    real(real64) :: denominator, a, b, s1, s2, vertical, correction
    real(real64), volatile :: coefficient, unused_scalar
    integer :: i, k, t, j, allocation_status, child_status, padded_levels
    logical :: wind_stable, early, need_mix
    status = 2
    if (pitch < 1 .or. pitch > 1024 .or. levels < 4 .or. levels > 256) return
    if (first < 1 .or. first > pitch .or. last < first - 1 .or. last > pitch) return
    if (transport_first_level < 0 .or. transport_first_level > 1) return
    if (transport_last_level < levels .or. transport_last_level > levels + 1) return
    if (.not. c%two_time_levels .or. .not. c%finite_element) return
    if (c%nonhydrostatic .or. c%semi_lagrangian_acceleration .or. c%split_constituents) return
    if (c%curved_rhs .or. c%advective_forcing .or. c%full_coriolis_geometry .or. c%cartesian_wind) return
    if (c%moisture_convergence_copy .or. c%term%full_predictor_corrector .or. c%term%cheap_corrector) return
    if (c%term%diagnostics .or. c%term%split_interpolation .or. c%term%current_iteration /= 0) return
    if (c%wind_transport_points /= 3 .or. c%temperature_transport_points /= 3) return
    if (c%interpolation_factor /= 1.0_real64) return
    if (c%term%step < 0 .or. c%term%first_order_steps < 0) return
    if (.not. ieee_is_finite(c%term%implicit_time_weight)) return
    if (c%term%implicit_time_weight < -1.0_real64 .or. c%term%implicit_time_weight > 1.0_real64) return
    if (.not. ieee_is_finite(pesgp) .or. .not. ieee_is_finite(pesgm)) return
    if (pesgp < 0.0_real64 .or. pesgp > 2.0_real64 .or. pesgm < 0.0_real64 .or. pesgm > 2.0_real64) return
    if (.not. ieee_is_finite(half_time_step) .or. .not. ieee_is_finite(wind_time_factor)) return
    if (.not. ieee_is_finite(c%dry_gas_constant) .or. .not. ieee_is_finite(c%reference_temperature)) return
    if (.not. ieee_is_finite(c%gravity) .or. .not. ieee_is_finite(c%planet_radius)) return
    if (.not. ieee_is_finite(c%rotation_rate) .or. .not. ieee_is_finite(c%orographic_scale)) return
    if (c%dry_gas_constant <= 0 .or. c%reference_temperature <= 0 .or. c%gravity <= 0 .or. c%planet_radius <= 0) return
    if (size(constituents) > 2163) return
    do j = 1, size(constituents)
      if (constituents(j)%advected .and. constituents(j)%spline_transform) return
    end do
    padded_levels = transport_last_level - transport_first_level + 1
    wind_stable = c%stable_extrapolation
    if (pesgp > pesgm) wind_stable = .false.
    early = c%term%step <= c%term%first_order_steps .or. c%term%escape
    if (first <= last) then
      if (size(temperature_time_factor) < pitch .or. size(coriolis) < pitch) return
      if (size(surface_geopotential) < pitch .or. size(orography_x) < pitch .or. size(orography_y) < pitch) return
      if (size(full_level_correction) < levels .or. ubound(half_level_correction, 1) < levels) return
      if (size(linear_u, 1) < pitch .or. size(linear_u, 2) < levels) return
      if (size(linear_v, 1) < pitch .or. size(linear_v, 2) < levels) return
      if (size(linear_temperature, 1) < pitch .or. size(linear_temperature, 2) < levels) return
      if (size(tendency_u, 1) < pitch .or. size(tendency_u, 2) < levels) return
      if (size(tendency_v, 1) < pitch .or. size(tendency_v, 2) < levels) return
      if (size(tendency_temperature, 1) < pitch .or. size(tendency_temperature, 2) < levels) return
      if (size(inverse_layer_thickness, 1) < pitch .or. size(inverse_layer_thickness, 2) < levels) return
      if (size(pressure_transport, 1) < pitch .or. size(pressure_transport, 2) < levels + 1) return
      need_mix = wind_stable .and. .not. early
      if (.not. valid_group(f%wind_u, pitch, levels, padded_levels,.not. c%term%escape, need_mix)) return
      if (.not. valid_group(f%wind_v, pitch, levels, padded_levels,.not. c%term%escape, need_mix)) return
      need_mix = c%stable_extrapolation .and. .not. early
      if (.not. valid_group(f%temperature, pitch, levels, padded_levels,.not. c%term%escape, need_mix)) return
      do j = 1, size(constituents)
        if (.not. constituents(j)%advected) cycle
        if (.not. associated(constituents(j)%current)) return
        if (.not. associated(constituents(j)%transported)) return
        if (size(constituents(j)%current, 1) < pitch .or. size(constituents(j)%current, 2) < levels) return
        if (size(constituents(j)%transported, 1) < pitch .or. size(constituents(j)%transported, 2) < padded_levels) return
      end do
    end if
    allocate (source(pitch, levels, 3), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    denominator = c%dry_gas_constant*c%reference_temperature
    coefficient = c%orographic_scale/denominator
    unused_scalar = c%gravity*c%planet_radius
    unused_scalar = 2.0_real64/unused_scalar
    unused_scalar = 2.0_real64*c%rotation_rate
    unused_scalar = unused_scalar/c%gravity
    u = f%wind_u
    v = f%wind_v
    temp = f%temperature
    u%pmoy1x%values => source(:, :, 1)
    v%pmoy1x%values => source(:, :, 2)
    temp%pmoy1x%values => source(:, :, 3)
    do k = 1, levels
      do i = first, last
        f%wind_u%pxsi%values(i, k) = wind_time_factor*linear_u(i, k)
        f%wind_v%pxsi%values(i, k) = wind_time_factor*linear_v(i, k)
        a = half_time_step*tendency_u(i, k)
        b = half_time_step*tendency_v(i, k)
        s1 = half_time_step*coriolis(i)
        s2 = s1*f%wind_v%pxt0%values(i, k)
        a = a + s2
        s2 = s1*f%wind_u%pxt0%values(i, k)
        b = b - s2
        source(i, k, 1) = a
        source(i, k, 2) = b
      end do
    end do
    call apply_two_level_transport_terms(pitch, levels, first, last, transport_first_level, &
                                         transport_last_level, 3_int32, pesgp, pesgm, wind_stable, c%term, u, child_status)
    if (child_status /= 0) then
      status = child_status
      return
    end if
    call apply_two_level_transport_terms(pitch, levels, first, last, transport_first_level, &
                                         transport_last_level, 3_int32, pesgp, pesgm, wind_stable, c%term, v, child_status)
    if (child_status /= 0) then
      status = child_status
      return
    end if
    do k = 1, levels
      do i = first, last
        f%temperature%pxsi%values(i, k) = temperature_time_factor(i)*linear_temperature(i, k)
        vertical = pressure_transport(i, k + 1)*inverse_layer_thickness(i, k)
        a = half_time_step*coefficient
        a = a*full_level_correction(k)
        a = a*f%wind_u%pxt0%values(i, k)
        a = a*orography_x(i)
        b = half_time_step*coefficient
        b = b*full_level_correction(k)
        b = b*f%wind_v%pxt0%values(i, k)
        b = b*orography_y(i)
        a = a + b
        b = half_time_step*tendency_temperature(i, k)
        a = a + b
        s1 = half_level_correction(k) - half_level_correction(k - 1)
        b = half_time_step*coefficient
        b = b*s1
        b = b*vertical
        b = b*surface_geopotential(i)
        source(i, k, 3) = a + b
      end do
    end do
    call apply_two_level_transport_terms(pitch, levels, first, last, transport_first_level, &
                                         transport_last_level, 3_int32, pesgp, pesgm, c%stable_extrapolation, c%term, temp, &
                                         child_status)
    if (child_status /= 0) then
      status = child_status
      return
    end if
    do k = 1, levels
      t = k - transport_first_level + 1
      do i = first, last
        correction = full_level_correction(k)*coefficient
        correction = correction*surface_geopotential(i)
        f%temperature%pxt1%values(i, k) = f%temperature%pxt1%values(i, k) - correction
        f%temperature%pxl9%values(i, t) = f%temperature%pxl9%values(i, t) + correction
      end do
    end do
    do j = 1, size(constituents)
      if (.not. constituents(j)%advected) cycle
      do k = 1, levels
        t = k - transport_first_level + 1
        do i = first, last
          constituents(j)%transported(i, t) = constituents(j)%transported(i, t) + constituents(j)%current(i, k)
        end do
      end do
    end do
    status = 0
  end subroutine

  !> Admit only the owners consumed by the selected three-point DNT call.
  logical function valid_group(f, pitch, levels, padded_levels, nonlinear, mixing)
    type(transport_term_fields), intent(in) :: f
    integer, intent(in) :: pitch, levels, padded_levels
    logical, intent(in) :: nonlinear, mixing
    valid_group = .false.
    if (.not. has(f%pxt0, pitch, levels)) return
    if (.not. has(f%pxsi, pitch, levels)) return
    if (.not. has(f%pxt1, pitch, levels)) return
    if (.not. has(f%pxl0, pitch, padded_levels)) return
    if (.not. has(f%pxl9, pitch, padded_levels)) return
    if (nonlinear) then
      if (.not. has(f%pxnlt9, pitch, levels)) return
    end if
    if (mixing) then
      if (.not. has(f%pmixnl, pitch, levels)) return
    end if
    valid_group = .true.
  end function

  logical function has(view, rows, columns)
    type(transport_field_view), intent(in) :: view
    integer, intent(in) :: rows, columns
    has = .false.
    if (.not. associated(view%values)) return
    if (size(view%values, 1) < rows .or. size(view%values, 2) < columns) return
    has = .true.
  end function
end module
