!> Cartesian departure points for the selected spherical trajectory calculation.
!! The parent owns its interpolation work and retains separate FP64 operations.
!! Public C mathematical functions are candidate providers. Exact byte
!! qualification is required before this entry is selected for a forecast.
module forecast_runtime_source_larmes
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double
  use forecast_runtime_source_larcina, only: departure_field_controls, trajectory_field_component, &
                                             prepare_departure_coordinate_fields
  use md2asm_departure_interpolation_weights, only: departure_weight_controls, departure_weight_geometry, &
                                                    departure_weight_inputs, departure_weight_outputs
  use md2asm_weno_departure_interpolation, only: weno_interpolation_controls
  use md2asm_cartesian_departure_points,only:cartesian_departure_controls,cartesian_arrival_geometry,cartesian_arrival_wind,cartesian_departure_state
  use forecast_departure_source_counters, only: departure_source_hit
  implicit none
  private
  public :: cartesian_departure_controls, cartesian_arrival_geometry, cartesian_arrival_wind
  public :: cartesian_departure_state, find_cartesian_departure_points

  !> Source time and trajectory controls, supplied by their initialized owners.
  !! pi is radians. eta_top_blend and eta_bottom_blend have no unit.
  !! time_factor is the exact RTDT source value. The caller must supply rates
  !! consistent with that value; this entry adds no radius or clock scaling.
  !! Both wind limits use the same units as the supplied Cartesian rates.
  ! Canonical cartesian_departure_controls declaration is imported without a copy.

  !> Borrowed arrival coordinates spanning every active row first:last.
  !! x,y,z retain their supplied length unit. The operational owner uses metres.
  !! Retained component fixtures can use unit-sphere coordinates. longitude is radians;
  !! latitude_sine,latitude_cosine and longitude_cosine have no unit.
  !! The last three fields are read only by rotation or selected reporting.
  ! Canonical cartesian_arrival_geometry declaration is imported without a copy.

  !> Borrowed arrival rates with shape(pitch,at least levels).
  !! Products of time_factor with u,v,z retain the supplied coordinate length unit;
  !! its product with eta_rate has the unit of the supplied vertical coordinate.
  !! No physical unit conversion is performed in this parent.
  ! Canonical cartesian_arrival_wind declaration is imported without a copy.

  !> Borrowed writable output views and their complete containing owners.
  !! Real fields use(pitch,at least levels); saved uses(pitch,levels,3).
  !! Longitude and latitude are radians. eta has the supplied eta unit.
  !! u,v,w preserve their interpolated input-field units; rotation_p/q are
  !! dimensionless. Index families use(pitch,levels,4) and(pitch,levels).
  !! Every output is disjoint from consumed inputs and other active outputs.
  !! Inactive rows, unused planes, padding and unused optional fields remain.
  ! Canonical cartesian_departure_state declaration is imported without a copy.

  interface
    function scalar_sin(x) bind(C, name='sin') result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function scalar_cos(x) bind(C, name='cos') result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function scalar_asin(x) bind(C, name='asin') result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function scalar_acos(x) bind(C, name='acos') result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function scalar_atan2(y, x) bind(C, name='atan2') result(angle)
      import c_double
      real(c_double), value :: y, x
      real(c_double) :: angle
    end function
  end interface
contains
  !> Find departure longitude, latitude and vertical position, then rotate winds.
  !! pitch is1:1024 and levels is4:256. first:last may be empty with
  !! last=first-1 and1<=first<=pitch+1. iterations is2:16.
  !! full_eta stores physical nodes0:levels+1; half_eta stores0:levels.
  !! previous_eta_rate(pitch,levels) is read only when saved departure points
  !! are active without full predictor mode. source_fields(1:4)%field borrow
  !! the complete U,V,Z,W source planes; their result pointers are unused.
  !! field_control supplies the live input-level bounds and stretch, while
  !! the parent sets its own midpoint stage and interpolation selection.
  !! The interpolation geometry and selected weight controls are read only.
  !! Shape/control refusal returns2 before public writes. Allocation refusal
  !! returns1. A later child/domain refusal returns2 with partial state
  !! unaccepted. Status0 needs the separate exact bytes/physics/status gate.
  !! Integer crossing expressions must fit the supported int32 NINT domain.
  subroutine find_cartesian_departure_points(pitch, levels, first, last, c, field_control, weight_control, &
                         interpolation_geometry, arrival, wind, full_eta, half_eta, previous_eta_rate, source_fields, state, status)
    integer(int32), intent(in) :: pitch, levels, first, last
    type(cartesian_departure_controls), intent(in) :: c
    type(departure_field_controls), intent(in) :: field_control
    type(departure_weight_controls), intent(in) :: weight_control
    type(departure_weight_geometry), intent(in) :: interpolation_geometry
    type(cartesian_arrival_geometry), intent(in) :: arrival
    type(cartesian_arrival_wind), intent(in) :: wind
    real(real64), intent(in) :: full_eta(0:), half_eta(0:), previous_eta_rate(:, :)
    type(trajectory_field_component), intent(in) :: source_fields(4)
    type(cartesian_departure_state), intent(inout) :: state
    integer(int32), intent(out) :: status
    type(departure_field_controls) :: selected_fields
    type(departure_weight_inputs) :: positions
    type(departure_weight_outputs) :: weights
    type(trajectory_field_component) :: components(4)
    type(weno_interpolation_controls) :: unused_weno
    real(real64), allocatable, target :: scalar_work(:, :, :), circle_work(:, :, :, :)
    real(real64), allocatable, target :: latitude_coefficients(:, :, :, :, :), longitude_coefficients(:, :, :, :, :, :)
    real(real64), allocatable, target :: vertical_coefficients(:, :, :, :)
    integer(int32), allocatable, target :: weno_shift(:, :)
    integer(int32), allocatable :: crossings(:, :)
    real(real64), volatile :: twice_pi, half_time, top, bottom, eta_lower, eta_upper, limit1, limit2
    real(real64), volatile :: reported_wind, reported_longitude, reported_latitude
    real(real64) :: max_u, max_v, a, b, d, x, y, z, raw_eta, crossing, signed_half
    real(real64) :: sin_lat, cos_lat, sin_delta, cos_delta, q12, q21, q22, q33, denominator
    integer(int64) :: planes, work_bytes
    integer :: i, k, iteration, component, side, allocation_status
    integer(int32) :: rounded
    logical :: saved_active, full_saved
    status = 2
    if (real64 /= c_double) return
    if (pitch < 1 .or. pitch > 1024 .or. levels < 4 .or. levels > 256) return
    if (first < 1 .or. first > pitch + 1 .or. last < first - 1 .or. last > pitch) return
    if (c%iterations < 2 .or. c%iterations > 16) return
    if (.not. c%spherical .or. .not. c%cartesian .or. .not. c%curved_departure) return
    if (.not. finite_bits(c%time_factor) .or. .not. finite_bits(c%pi)) return
    if (.not. finite_bits(c%eta_top_blend) .or. .not. finite_bits(c%eta_bottom_blend)) return
    if (.not. finite_bits(c%soft_wind_limit) .or. .not. finite_bits(c%hard_wind_limit)) return
    if (ubound(full_eta, 1) < levels + 1 .or. ubound(half_eta, 1) < levels) return
    if (.not. vector_has(arrival%x) .or. .not. vector_has(arrival%y) .or. .not. vector_has(arrival%z)) return
    if (.not. real2_has(wind%u) .or. .not. real2_has(wind%v) .or. .not. real2_has(wind%z)) return
    if (.not. real2_has(wind%eta_rate)) return
    if (.not. real2_has(state%longitude) .or. .not. real2_has(state%latitude) .or. .not. real2_has(state%eta)) return
    if (.not. real2_has(state%u) .or. .not. real2_has(state%v)) return
    if (.not. integer3_has(state%parent_index) .or. .not. integer3_has(state%horizontal_index)) return
    if (.not. integer2_has(state%vertical_index)) return
    if (c%diagnostic_wind) then
      if (.not. real2_has(state%w)) return
    end if
    if (c%save_departure) then
      if (.not. associated(state%saved)) return
      if (size(state%saved, 1) /= pitch .or. size(state%saved, 2) < levels .or. size(state%saved, 3) < 3) return
    end if
    if (.not. c%rhs_curvature) then
      if (.not. vector_has(arrival%longitude) .or. .not. vector_has(arrival%latitude_sine)) return
      if (.not. vector_has(arrival%latitude_cosine)) return
      if (.not. real2_has(state%rotation_p) .or. .not. real2_has(state%rotation_q)) return
    end if
    if (c%report_crossings) then
      if (.not. vector_has(arrival%longitude_cosine) .or. .not. vector_has(arrival%latitude_sine)) return
    end if
    saved_active = c%save_departure .and. c%step >= 1
    full_saved = saved_active .and. c%full_predictor .and. .not. c%cheap_predictor .and. c%predictor_iteration > 0
    if (saved_active .and. .not. full_saved) then
      if (size(previous_eta_rate, 1) /= pitch .or. size(previous_eta_rate, 2) < levels) return
    end if
    if (field_control%find_vertical_separation .or. field_control%vertical_smoothing) return
    if (field_control%hermite_width /= 0 .or. field_control%limiter /= 0) return
    if (weight_control%slots /= 1 .or. weight_control%trajectory_weno) return
    if (weight_control%diffusion .or. weight_control%quadratic .or. weight_control%turbulence) return
    if (weight_control%static_physics_weights .or. weight_control%coordinate_correction) return
    if (weight_control%horizontal_correction .or. weight_control%vertical_correction) return
    planes = int(field_control%last_input_level, int64) - int(field_control%first_input_level, int64) + 1_int64
    if (interpolation_geometry%buffer_stride < 1 .or. planes < 1 .or. planes > huge(0_int32)) return
    if (int(interpolation_geometry%buffer_stride, int64)*planes > huge(0_int32)) return
    do component = 1, 4
      if (.not. associated(source_fields(component)%field)) return
      if (size(source_fields(component)%field, 1) /= interpolation_geometry%buffer_stride) return
      if (int(size(source_fields(component)%field, 2), int64) /= planes) return
    end do
    work_bytes = 8_int64*int(pitch, int64)*int(levels, int64)*(6 + 8 + 9 + 18 + 12) + &
                 4_int64*int(pitch, int64)*int(levels, int64) + 8_int64*int(pitch, int64)
    if (work_bytes > 536870912_int64) return

    ! Each source scalar is stored even when the selected cell interval is empty.
    twice_pi = 2.0_real64*c%pi
    half_time = 0.5_real64*c%time_factor
    top = full_eta(0)
    bottom = full_eta(levels + 1)
    a = 1.0_real64 - c%eta_top_blend
    a = a*half_eta(0)
    b = c%eta_top_blend*full_eta(1)
    eta_lower = a + b
    a = 1.0_real64 - c%eta_bottom_blend
    a = a*half_eta(levels)
    b = c%eta_bottom_blend*full_eta(levels)
    eta_upper = a + b
    limit1 = c%soft_wind_limit*c%soft_wind_limit
    limit2 = c%hard_wind_limit*c%hard_wind_limit
    max_u = 0.0_real64
    max_v = 0.0_real64
    do k = 1, levels
      do i = first, last
        if (.not. finite_bits(wind%v(i, k))) return
        a = wind%v(i, k)*wind%v(i, k)
        max_v = max(a, max_v)
        if (.not. finite_bits(wind%u(i, k))) return
        a = wind%u(i, k)*wind%u(i, k)
        max_u = max(a, max_u)
        if (.not. finite_bits(wind%z(i, k)) .or. .not. finite_bits(wind%eta_rate(i, k))) return
      end do
    end do
    if (max_v > limit1 .or. max_u > limit1) return

    allocate (scalar_work(pitch, levels, 6), circle_work(pitch, levels, 4, 2), &
              latitude_coefficients(pitch, levels, 3, 1, 3), longitude_coefficients(pitch, levels, 3, 2, 1, 3), &
              vertical_coefficients(pitch, levels, 3, 4), weno_shift(pitch, levels), crossings(pitch, 2), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    scalar_work = 0.0_real64
    circle_work = 0.0_real64
    latitude_coefficients = 0.0_real64
    longitude_coefficients = 0.0_real64
    vertical_coefficients = 0.0_real64
    weno_shift = 0
    crossings = 0
    weights%latitude_fraction => scalar_work(:, :, 3)
    weights%latitude_correction_fraction => scalar_work(:, :, 4)
    weights%vertical_fraction => scalar_work(:, :, 5)
    weights%vertical_correction_fraction => scalar_work(:, :, 6)
    weights%longitude_fraction => circle_work(:, :, :, 1)
    weights%longitude_correction_fraction => circle_work(:, :, :, 2)
    weights%latitude_main => latitude_coefficients(:, :, :, :, 1)
    weights%latitude_correction => latitude_coefficients(:, :, :, :, 2)
    weights%latitude_filtered => latitude_coefficients(:, :, :, :, 3)
    weights%longitude_main => longitude_coefficients(:, :, :, :, :, 1)
    weights%longitude_correction => longitude_coefficients(:, :, :, :, :, 2)
    weights%longitude_filtered => longitude_coefficients(:, :, :, :, :, 3)
    weights%vertical_main => vertical_coefficients(:, :, :, 1)
    weights%vertical_correction => vertical_coefficients(:, :, :, 2)
    weights%vertical_filtered => vertical_coefficients(:, :, :, 3)
    weights%vertical_diffusion => vertical_coefficients(:, :, :, 4)
    weights%parent_index => state%parent_index
    weights%horizontal_index => state%horizontal_index
    weights%vertical_index => state%vertical_index
    weights%weno_shift => weno_shift
    positions%longitude => state%longitude
    positions%latitude => state%latitude
    positions%position => state%eta
    components = source_fields
    components(1)%result => state%u
    components(2)%result => state%v
    components(3)%result => scalar_work(:, :, 1)
    components(4)%result => scalar_work(:, :, 2)
    selected_fields = field_control
    selected_fields%stage = 1
    selected_fields%spherical = .true.
    selected_fields%cartesian = .true.
    selected_fields%curvature = .true.
    selected_fields%plane = .false.
    selected_fields%interpolate_fields = .true.
    selected_fields%spline_origin = .false.
    selected_fields%rhs_weno = .false.
    selected_fields%pi = c%pi

    do k = 1, levels
      do i = first, last
        if (saved_active) then
          state%longitude(i, k) = state%saved(i, k, 1)
          state%latitude(i, k) = state%saved(i, k, 2)
          if (full_saved) then
            state%eta(i, k) = state%saved(i, k, 3)
            cycle
          end if
          a = previous_eta_rate(i, k)*wind%eta_rate(i, k)
          if (a > 0.0_real64) then
            state%eta(i, k) = state%saved(i, k, 3)
            cycle
          end if
        else
          a = c%time_factor*wind%u(i, k)
          x = arrival%x(i) - a
          a = c%time_factor*wind%v(i, k)
          y = arrival%y(i) - a
          a = c%time_factor*wind%z(i, k)
          z = arrival%z(i) - a
          call store_angles(x, y, z, i, k)
          if (status /= 0) return
        end if
        a = c%time_factor*wind%eta_rate(i, k)
        raw_eta = full_eta(k) - a
        state%eta(i, k) = min(eta_upper, max(eta_lower, raw_eta))
      end do
    end do
    do iteration = 2, c%iterations
      call prepare_departure_coordinate_fields(pitch, levels, first, last, selected_fields, weight_control, &
                                               interpolation_geometry, positions, weights, components, unused_weno, status)
      if (status /= 0) return
      do k = 1, levels
        do i = first, last
          a = state%u(i, k) + wind%u(i, k)
          a = half_time*a
          x = arrival%x(i) - a
          a = state%v(i, k) + wind%v(i, k)
          a = half_time*a
          y = arrival%y(i) - a
          a = scalar_work(i, k, 1) + wind%z(i, k)
          a = half_time*a
          z = arrival%z(i) - a
          call store_angles(x, y, z, i, k)
          if (status /= 0) return
          a = scalar_work(i, k, 2) + wind%eta_rate(i, k)
          a = half_time*a
          raw_eta = full_eta(k) - a
          state%eta(i, k) = min(eta_upper, max(eta_lower, raw_eta))
          if (iteration == c%iterations) then
            crossing = raw_eta - top
            crossing = crossing - 0.5_real64
            if (.not. crossing_fits(crossing)) then
              status = 2
              return
            end if
            rounded = nint(crossing, kind=int32)
            crossings(i, 1) = crossings(i, 1) - min(0_int32, max(-1_int32, rounded))
            crossing = bottom - raw_eta
            crossing = crossing - 0.5_real64
            if (.not. crossing_fits(crossing)) then
              status = 2
              return
            end if
            rounded = nint(crossing, kind=int32)
            crossings(i, 2) = crossings(i, 2) - min(0_int32, max(-1_int32, rounded))
          end if
        end do
      end do
    end do

    do k = 1, levels
      do i = first, last
        if (c%diagnostic_wind) state%w(i, k) = scalar_work(i, k, 2)
        if (.not. c%rhs_curvature) then
          sin_lat = scalar_sin(state%latitude(i, k))
          cos_lat = scalar_cos(state%latitude(i, k))
          d = arrival%longitude(i) - state%longitude(i, k)
          sin_delta = scalar_sin(d)
          d = arrival%longitude(i) - state%longitude(i, k)
          cos_delta = scalar_cos(d)
          q12 = sin_lat*sin_delta
          a = -arrival%latitude_sine(i)
          q21 = a*sin_delta
          a = arrival%latitude_cosine(i)*cos_lat
          b = arrival%latitude_sine(i)*sin_lat
          b = b*cos_delta
          q22 = a + b
          a = arrival%latitude_sine(i)*sin_lat
          b = arrival%latitude_cosine(i)*cos_lat
          b = b*cos_delta
          q33 = a + b
          denominator = 1.0_real64 + q33
          a = cos_delta + q22
          state%rotation_p(i, k) = a/denominator
          a = q12 - q21
          state%rotation_q(i, k) = a/denominator
        end if
        if (c%save_departure) then
          state%saved(i, k, 1) = state%longitude(i, k)
          state%saved(i, k, 2) = state%latitude(i, k)
          state%saved(i, k, 3) = state%eta(i, k)
        end if
      end do
    end do
    if (c%report_crossings) then
      do side = 1, 2
        do i = first, last
          if (crossings(i, side) == 0) cycle
          reported_wind = scalar_work(i, 1, 2)
          do k = 2, levels
            reported_wind = max(reported_wind, scalar_work(i, k, 2))
          end do
          reported_longitude = scalar_acos(arrival%longitude_cosine(i))
          reported_longitude = reported_longitude*180.0_real64
          reported_longitude = reported_longitude/c%pi
          reported_latitude = scalar_asin(arrival%latitude_sine(i))
          reported_latitude = reported_latitude*180.0_real64
          reported_latitude = reported_latitude/c%pi
          call departure_source_hit(1_int32, 6_int32)
        end do
      end do
    end if
    call departure_source_hit(1_int32, 5_int32)
    status = 0
  contains
    subroutine store_angles(x, y, z, i, k)
      real(real64), intent(in) :: x, y, z
      integer, intent(in) :: i, k
      real(real64) :: sx, sy, sz, norm, raw_longitude, wrapped
      real(real64), volatile :: ratio
      integer(int64) :: sign_bit
      status = 2
      sx = x*x
      sy = y*y
      norm = sx + sy
      sz = z*z
      norm = norm + sz
      norm = sqrt(norm)
      ratio = z/norm
      if (.not. finite_bits(ratio)) return
      if (ratio < -1.0_real64 .or. ratio > 1.0_real64) return
      raw_longitude = scalar_atan2(y, x)
      sign_bit = iand(transfer(raw_longitude, 0_int64), int(z'8000000000000000', int64))
      signed_half = transfer(ior(sign_bit, int(z'3FE0000000000000', int64)), signed_half)
      wrapped = 0.5_real64 - signed_half
      wrapped = wrapped*twice_pi
      state%longitude(i, k) = wrapped + raw_longitude
      state%latitude(i, k) = scalar_asin(ratio)
      status = 0
    end subroutine
    logical function vector_has(p)
      real(real64), pointer, intent(in) :: p(:)
      vector_has = .false.
      if (.not. associated(p)) return
      vector_has = size(p) >= last
    end function
    logical function real2_has(p)
      real(real64), pointer, intent(in) :: p(:, :)
      real2_has = .false.
      if (.not. associated(p)) return
      real2_has = size(p, 1) == pitch .and. size(p, 2) >= levels
    end function
    logical function integer2_has(p)
      integer(int32), pointer, intent(in) :: p(:, :)
      integer2_has = .false.
      if (.not. associated(p)) return
      integer2_has = size(p, 1) == pitch .and. size(p, 2) >= levels
    end function
    logical function integer3_has(p)
      integer(int32), pointer, intent(in) :: p(:, :, :)
      integer3_has = .false.
      if (.not. associated(p)) return
      integer3_has = size(p, 1) == pitch .and. size(p, 2) >= levels .and. size(p, 3) >= 4
    end function
  end subroutine
  pure logical function finite_bits(x)
    real(real64), intent(in) :: x
    finite_bits = iand(transfer(x, 0_int64), int(z'7FF0000000000000', int64)) /= int(z'7FF0000000000000', int64)
  end function
  logical function crossing_fits(x)
    real(real64), intent(in) :: x
    crossing_fits = .false.
    if (.not. finite_bits(x)) return
    crossing_fits = x > -2147483647.0_real64 .and. x < 2147483647.0_real64
  end function
end module
