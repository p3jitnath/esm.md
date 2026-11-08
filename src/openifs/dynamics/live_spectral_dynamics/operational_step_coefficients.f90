!> Update six actual time coefficients without allocating another model clock.
module forecast_operational_step_coefficients
  use iso_c_binding, only: c_int, c_int64_t, c_double
  implicit none
  private
  public :: update_operational_time_coefficients, pressure_weighted_column_integral
contains
  !> INTERVAL is seconds and RADIUS is metres; VALUE permits source alias intake.
 !! The first four outputs have units s/m,(s/m)**2,(s/m)**2,(s/m)**2.
 !! RTDT/TSPHY are seconds. Parent supplies its actual named scalar owners.
 !! No clock or physics namespace is duplicated; all outputs are atomic on refusal.
  integer(c_int) function update_operational_time_coefficients(interval, radius, half_over_radius, square, sixth, &
                                                               half_square, rtdt, tsphy) result(status)
    real(c_double), value :: interval, radius
    real(c_double), intent(inout) :: half_over_radius, square, sixth, half_square, rtdt, tsphy
    real(c_double) :: half_value, squared, sixth_value, half_squared
    real(c_double), volatile :: six, two
    integer(c_int64_t) :: bits
    status = 2
    bits = transfer(interval, bits)
    if (btest(bits, 63) .or. bits == 0 .or. ibits(bits, 52, 11) == 2047) return
    if (interval > 86400.0_c_double) return
    bits = transfer(radius, bits)
    if (btest(bits, 63) .or. ibits(bits, 52, 11) == 2047) return
    if (radius < 1000000.0_c_double .or. radius > 10000000.0_c_double) return
    half_value = 0.5_c_double*interval
    half_value = half_value/radius
    squared = half_value*half_value
    six = 6.0_c_double; two = 2.0_c_double
    sixth_value = squared/six
    half_squared = squared/two
    half_over_radius = half_value
    square = squared
    sixth = sixth_value
    half_square = half_squared
    rtdt = interval
    tsphy = max(interval, 1.0_c_double)
    status = 0
  end function
  !> Integrate water mass in kg/m**2 using actual half pressure in Pa.
 !! HUMIDITY(pitch,levels) is kg/kg; GRAVITY is m/s**2.
 !! WATER(pitch,0:levels) writes only FIRST:LAST, including positive-zero top.
 !! The source reciprocal occurs before the empty-cell/zero-level decision.
  integer(c_int)function pressure_weighted_column_integral(pitch,first,last,levels,water,humidity,pressure,gravity)result(status)
  integer(c_int), intent(in) :: pitch, first, last, levels
  real(c_double), intent(inout) :: water(:, 0:)
  real(c_double), intent(in) :: humidity(:, :), pressure(:, 0:), gravity
  real(c_double), volatile :: inverse_gravity
  real(c_double) :: difference, product, value
  integer :: cell, level
  status = 2
  if (pitch < 1 .or. pitch > 4096 .or. levels < 0 .or. levels > 4096) return
  if (first < 1 .or. first > pitch + 1 .or. last < 0 .or. last > pitch) return
  if (size(water, 1) /= pitch .or. ubound(water, 2) < levels) return
  if (size(pressure, 1) /= pitch .or. ubound(pressure, 2) < levels) return
  if (size(humidity, 1) /= pitch .or. size(humidity, 2) < levels) return
  inverse_gravity = 1.0_c_double/gravity
  if (first > last) then
    status = 0; return
  end if
  do cell = first, last
    water(cell, 0) = 0.0_c_double
  end do
  do level = 1, levels
    do cell = first, last
      difference = pressure(cell, level) - pressure(cell, level - 1)
      product = humidity(cell, level)*difference
      product = product*inverse_gravity
      value = water(cell, level - 1) + product
      water(cell, level) = value
    end do
  end do
  status = 0
  end function
end module forecast_operational_step_coefficients
