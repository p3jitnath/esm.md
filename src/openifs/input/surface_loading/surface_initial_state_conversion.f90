module surface_initial_state_conversion_port
  !! Convert decoded surface inputs in the original scalar operation order.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use surface_input_configuration_port, only: surface_input_configuration
  use surface_field_unit_scaling_port, only: scale_initial_surface_fields
  implicit none
  private
  public :: convert_initial_surface_state
contains
  integer(int32) function convert_initial_surface_state(ordinary, layered, parameters, configuration) result(status)
    !! ordinary(N,F) and layered(N,5,5) are contiguous, disjoint owned arrays.
    !! N/F is2048/47 or6599680/50. parameters has F+5 identifiers; the first
    !! match selects each source field. The immutable configuration supplies
    !! gravity(m/s**2), density(kg/m**3), temperatures(K) and vegetation tables.
    !! Fields keep the generated physical units and every rounded operation.
    !! The caller supplies finite values and nearest, gradual-underflow mode.
    !! Return1 for shape,3 for configuration,4 for absent fields,5 for invalid
    !! vegetation, or0 for success. Every refusal leaves fields and flags unchanged.
    real(real64), contiguous, intent(inout) :: ordinary(:, :), layered(:, :, :)
    integer(int32), intent(in) :: parameters(:)
    type(surface_input_configuration), intent(in) :: configuration
    integer(int32), parameter :: required(23) = [172, 235, 139, 170, 183, 236, 198, 39, 40, 41, 42, &
                                                 228009, 228010, 228007, 34, 29, 30, 27, 28, 43, 31, 151131, 151132]
    integer(int32), parameter :: required_snow(3) = [228141, 238, 228038]
    integer :: n, f, j, k, l, positions(23), snow(3), low_vegetation, high_vegetation
    logical :: use_currents
    type(ieee_status_type) :: incoming
    real(real64) :: upper_index, total_snow, total_liquid, difference, temperature
    real(real64) :: cover_low, cover_high, capacity, product, value
    real(real64), parameter :: missing = -9999.0_real64, lake_freeze = 273.15_real64
    n = size(ordinary, 1); f = size(ordinary, 2)
    status = 1
    if (.not. ((n == 2048 .and. f == 47) .or. (n == 6599680 .and. f == 50))) return
    if (any(shape(layered) /= [n, 5, 5]) .or. size(parameters) /= f + 5) return
    status = 3
    if (configuration%invalid /= 0 .or. configuration%points /= n) return
    if (configuration%maximum_vegetation < 0 .or. configuration%maximum_vegetation > 127) return
    if (.not. configuration%ecmwf .or. configuration%revision /= 1) return
    if (configuration%cover_lower > 0 .or. configuration%leaf_lower > 0) return
    if (configuration%cover_upper < configuration%maximum_vegetation) return
    if (configuration%leaf_upper < configuration%maximum_vegetation) return
    use_currents = configuration%currents .and. .not. configuration%wave_coupling
    positions = 0; snow = 0
    status = 4
    do k = 1, 23
      if (k > 21 .and. .not. use_currents) cycle
      do l = 1, f
        if (parameters(l) /= required(k)) cycle
        positions(k) = l
        exit
      end do
      if (positions(k) == 0) return
    end do
    do k = 1, 3
      do l = 1, 5
        if (parameters(f + l) /= required_snow(k)) cycle
        snow(k) = l
        exit
      end do
      if (snow(k) == 0) return
    end do
    call ieee_get_status(incoming)
    upper_index = real(configuration%maximum_vegetation, real64)
    upper_index = upper_index + 0.5_real64
    status = 5
    do j = 1, n
      value = ordinary(j, positions(16))
      if (.not. (value > -0.5_real64 .and. value < upper_index)) then
        call ieee_set_status(incoming)
        return
      end if
      value = ordinary(j, positions(17))
      if (.not. (value > -0.5_real64 .and. value < upper_index)) then
        call ieee_set_status(incoming)
        return
      end if
    end do
    call ieee_set_status(incoming)
    status = scale_initial_surface_fields(ordinary, layered, parameters, configuration%gravity, configuration%water_density)
    if (status /= 0) return
    do j = 1, n
      if (ordinary(j, positions(15)) == missing) ordinary(j, positions(15)) = configuration%freezing_temperature
      if (ordinary(j, positions(21)) == missing) ordinary(j, positions(21)) = 0.0_real64
      if (ordinary(j, positions(1)) <= 0.5_real64) then
        temperature = ordinary(j, positions(3))
        if (.not. configuration%ocean_coupling .and. .not. configuration%ocean_wave) &
          ordinary(j, positions(2)) = temperature
        ordinary(j, positions(5)) = temperature
        ordinary(j, positions(6)) = temperature
        ordinary(j, positions(7)) = 0.0_real64
        ordinary(j, positions(10)) = 0.0_real64
        ordinary(j, positions(11)) = 0.0_real64
        do l = 1, 5
          layered(j, l, snow(1)) = 0.0_real64
        end do
        ordinary(j, positions(4)) = temperature
        ordinary(j, positions(8)) = 0.0_real64
        ordinary(j, positions(9)) = 0.0_real64
      end if
      total_snow = 0.0_real64
      do l = 1, 5
        value = layered(j, l, snow(1))
        value = max(0.0_real64, value)
        layered(j, l, snow(1)) = value
        total_snow = total_snow + value
      end do
      total_liquid = 0.0_real64
      do l = 1, 5
        value = layered(j, l, snow(3))
        value = max(0.0_real64, value)
        layered(j, l, snow(3)) = value
        total_liquid = total_liquid + value
      end do
      difference = total_snow - total_liquid
      ! An unordered difference must retain both layer arrays.
      if (difference <= 0.0_real64) then
        do l = 1, 5
          layered(j, l, snow(1)) = 0.0_real64
          layered(j, l, snow(3)) = 0.0_real64
        end do
      end if
      do l = 1, 5
        layered(j, l, snow(2)) = min(layered(j, l, snow(2)), configuration%freezing_temperature)
      end do
      low_vegetation = nint(ordinary(j, positions(16)))
      high_vegetation = nint(ordinary(j, positions(17)))
      cover_low = ordinary(j, positions(18))*configuration%cover(low_vegetation)
      cover_high = ordinary(j, positions(19))*configuration%cover(high_vegetation)
      capacity = 1.0_real64 - cover_low
      capacity = capacity - cover_high
      product = cover_low*configuration%leaf_area(low_vegetation)
      capacity = capacity + product
      product = cover_high*configuration%leaf_area(high_vegetation)
      capacity = capacity + product
      capacity = configuration%water_capacity*capacity
      value = min(capacity, ordinary(j, positions(7)))
      value = max(0.0_real64, value)
      ordinary(j, positions(7)) = value
      if (ordinary(j, positions(21)) <= configuration%ice_minimum) ordinary(j, positions(21)) = 0.0_real64
      value = max(2.0_real64, ordinary(j, positions(14)))
      value = min(value, ordinary(j, positions(12)))
      value = max(0.0_real64, value)
      ordinary(j, positions(12)) = value
      ordinary(j, positions(13)) = max(lake_freeze, ordinary(j, positions(13)))
      if (use_currents) then
        if (ordinary(j, positions(22)) == missing) ordinary(j, positions(22)) = 0.0_real64
        if (ordinary(j, positions(23)) == missing) ordinary(j, positions(23)) = 0.0_real64
        if (ordinary(j, positions(1)) > 0.5_real64) then
          ordinary(j, positions(22)) = 0.0_real64
          ordinary(j, positions(23)) = 0.0_real64
        end if
      end if
    end do
    status = 0
  end function
end module
