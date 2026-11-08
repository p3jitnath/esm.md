!> Compute the seven-coefficient, HLO safe ozone tendency.
!> Pressure is Pa, temperature K, time s, ozone a mass fraction, and tendency
!> mass fraction per second. Input arrays have P columns and L layers.
!> Only FIRST:LAST tendency rows change. Read-only inputs may share storage;
!> the complete tendency must stay separate from every borrowed input owner.
module forecast_runtime_ozone_chemistry
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double, c_loc, c_intptr_t
  use yoephy, only: TEPHY
  use forecast_ozone_coefficient_copy, only: ozone_coefficient_options
  implicit none
  private
  public :: calculate_runtime_ozone_tendency
  interface
    function public_tan(x) bind(c, name='tan') result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function public_acos(x) bind(c, name='acos') result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
  end interface
contains
  !> Fixed maximum private storage avoids reserving from an unvalidated shape.
  !> RECURSIVE keeps the roughly1MiB scratch private to each concurrent caller.
  recursive integer(int32) function calculate_runtime_ozone_tendency(ecmwf, options, p, l, first, last, &
                             gravity, pi, dt, declination, sin_latitude, solar_cosine, half_pressure, full_pressure, coefficients, &
                                                                     pressure_depth, temperature, ozone, tendency) result(status)
    type(TEPHY), intent(in) :: ecmwf
    type(ozone_coefficient_options), intent(in) :: options
    integer(int32), intent(in) :: p, l, first, last
    real(real64), intent(in) :: gravity, pi, dt, declination
    real(real64), target, contiguous, intent(in) :: sin_latitude(:), solar_cosine(:)
    real(real64), target, contiguous, intent(in) :: half_pressure(:, :), full_pressure(:, :), coefficients(:, :, :)
    real(real64), target, contiguous, intent(in) :: pressure_depth(:, :), temperature(:, :), ozone(:, :)
    real(real64), target, contiguous, intent(inout) :: tendency(:, :)
    real(real64) :: depth(128, 512), new_ozone(128, 512), column(128)
    real(real64), volatile :: light(128), tan_declination, a, b, c, term, denominator, t, above, value, scaled
    real(real64) :: floor, clip, threshold, one_plus_epsilon
    integer(int64) :: word, base, finish, address, span
    integer :: j, k
    status = 2
    if (p < 1 .or. p > 128 .or. l < 1 .or. l > 512) return
    if (first < 1 .or. first > p + 1 .or. last < first - 1 .or. last > p) return
    if (options%coefficient_count /= 7 .or. options%monthly_groups /= 1 .or. options%three_dimensional_groups /= 0) return
    if (.not. ecmwf%LEO3CH .or. .not. ecmwf%LO3CH_SAFE .or. .not. ecmwf%LO3CH_HLO) return
    if (ecmwf%LO3CH_OLDVER .or. ecmwf%LO3CH_BMS) return
    word = transfer(gravity, 0_int64)
    if (word <= 0_int64 .or. word >= int(z'7ff0000000000000', int64)) return
    word = transfer(dt, 0_int64)
    if (word <= 0_int64 .or. word >= int(z'7ff0000000000000', int64)) return
    if (size(sin_latitude) /= p .or. size(solar_cosine) /= p) return
    if (any(shape(half_pressure) /= [p, l + 1]) .or. any(shape(full_pressure) /= [p, l])) return
    if (any(shape(coefficients) /= [p, l, 7]) .or. any(shape(pressure_depth) /= [p, l])) return
    if (any(shape(temperature) /= [p, l]) .or. any(shape(ozone) /= [p, l]) .or. any(shape(tendency) /= [p, l])) return
    base = int(transfer(c_loc(tendency(1, 1)), 0_c_intptr_t), int64)
    finish = base + 8_int64*p*l
    address = int(transfer(c_loc(sin_latitude(1)), 0_c_intptr_t), int64)
    span = 8_int64*size(sin_latitude, kind=int64)
    if (address < finish .and. address + span > base) return
    address = int(transfer(c_loc(solar_cosine(1)), 0_c_intptr_t), int64)
    span = 8_int64*size(solar_cosine, kind=int64)
    if (address < finish .and. address + span > base) return
    address = int(transfer(c_loc(half_pressure(1, 1)), 0_c_intptr_t), int64)
    span = 8_int64*size(half_pressure, kind=int64)
    if (address < finish .and. address + span > base) return
    address = int(transfer(c_loc(full_pressure(1, 1)), 0_c_intptr_t), int64)
    span = 8_int64*size(full_pressure, kind=int64)
    if (address < finish .and. address + span > base) return
    address = int(transfer(c_loc(coefficients(1, 1, 1)), 0_c_intptr_t), int64)
    span = 8_int64*size(coefficients, kind=int64)
    if (address < finish .and. address + span > base) return
    address = int(transfer(c_loc(pressure_depth(1, 1)), 0_c_intptr_t), int64)
    span = 8_int64*size(pressure_depth, kind=int64)
    if (address < finish .and. address + span > base) return
    address = int(transfer(c_loc(temperature(1, 1)), 0_c_intptr_t), int64)
    span = 8_int64*size(temperature, kind=int64)
    if (address < finish .and. address + span > base) return
    address = int(transfer(c_loc(ozone(1, 1)), 0_c_intptr_t), int64)
    span = 8_int64*size(ozone, kind=int64)
    if (address < finish .and. address + span > base) return
    floor = transfer(int(z'3e112e0be826d695', int64), 0.0_real64)
    clip = transfer(int(z'402e000000000000', int64), 0.0_real64)
    threshold = transfer(int(z'3faacbc8c0ce91c9', int64), 0.0_real64)
    one_plus_epsilon = transfer(int(z'3ff000000000afec', int64), 0.0_real64)
    tan_declination = public_tan(declination)
    do j = first, last
      a = sin_latitude(j)*sin_latitude(j)
      a = one_plus_epsilon - a
      a = sqrt(a)
      b = tan_declination*sin_latitude(j)
      b = b/a
      if (abs(b) >= 1.0_real64) then
        c = 1.0_real64
      else
        c = public_acos(b)
        c = c/pi
        c = 1.0_real64 - c
        if (.not. (c >= 0.5_real64)) c = 0.5_real64
      end if
      a = solar_cosine(j) - threshold
      word = iand(transfer(a, 0_int64), int(z'8000000000000000', int64))
      word = ior(word, int(z'3fe0000000000000', int64))
      a = transfer(word, 0.0_real64)
      a = 0.5_real64 + a
      light(j) = a/c
    end do
    do k = 1, l
      do j = first, last
        depth(j, k) = full_pressure(j, k) - half_pressure(j, k)
      end do
    end do
    column(1:p) = 0.0_real64
    do k = 1, l
      do j = first, last
        t = temperature(j, k)
        a = t - coefficients(j, k, 4)
        if (a > clip) t = coefficients(j, k, 4) + clip
        a = t - coefficients(j, k, 4)
        b = -clip
        if (.not. (a >= b)) t = coefficients(j, k, 4) - clip
        term = t - coefficients(j, k, 4)
        term = coefficients(j, k, 5)*term
        term = coefficients(j, k, 2) + term
        above = column(j)
        a = above - coefficients(j, k, 6)
        a = coefficients(j, k, 7)*a
        term = term + a
        a = coefficients(j, k, 1)*coefficients(j, k, 3)
        term = term - a
        term = dt*term
        term = ozone(j, k) + term
        denominator = depth(j, k)*coefficients(j, k, 7)
        denominator = denominator/gravity
        denominator = coefficients(j, k, 3) + denominator
        denominator = dt*denominator
        denominator = 1.0_real64 - denominator
        value = term/denominator
        if (.not. (value >= floor)) value = floor
        new_ozone(j, k) = value
        if (k < l) then
          scaled = pressure_depth(j, k)*value
          scaled = scaled/gravity
          column(j) = above + scaled
        end if
      end do
    end do
    do k = 1, l
      do j = first, last
        a = new_ozone(j, k) - ozone(j, k)
        tendency(j, k) = a/dt
      end do
    end do
    status = 0
  end function
end module forecast_runtime_ozone_chemistry
