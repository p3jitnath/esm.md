!> Interpolate the native solar irradiance table without changing its owners.
module native_solar_irradiance
  use iso_fortran_env, only: real64, int32
  use yomsolarirradiance, only: tsolarirradiance
  implicit none
  private
  public :: get_solar_irradiance
contains
  !> Return solar irradiance in W/m^2 at one strictly interior calendar year.
  !! SELF is readonly and owns finite increasing years and positive finite
  !! irradiance at logical indices1:NTIME, with NTIME at least2. Allocation
  !! lower bounds may be below1. YEAR is readonly. IRRADIANCE is a separate
  !! scalar INOUT owner and stays unchanged on rejection. The caller admits
  !! nearest rounding and gradual underflow. The first matching interval,
  !! internal ties and all separate FP64 steps match the generated body.
  !! There is no allocation or original type-bound call. Return0 or2.
  integer(int32) function get_solar_irradiance(self, year, irradiance) result(status)
    type(tsolarirradiance), intent(in) :: self
    real(real64), intent(in) :: year
    real(real64), intent(inout) :: irradiance
    real(real64) :: delta, width, weight, lower, upper, difference, product
    integer :: index, count
    status = 2_int32; count = self%ntime
    if (count < 2) return
    if (.not. allocated(self%ryear) .or. .not. allocated(self%rtsi)) return
    if (lbound(self%ryear, 1) > 1 .or. ubound(self%ryear, 1) < count) return
    if (lbound(self%rtsi, 1) > 1 .or. ubound(self%rtsi, 1) < count) return
    if (.not. (year > self%ryear(1) .and. year < self%ryear(count))) return
    do index = 1, count - 1
      if (year >= self%ryear(index) .and. year < self%ryear(index + 1)) exit
    end do
    if (index >= count) return
    delta = year - self%ryear(index)
    width = self%ryear(index + 1) - self%ryear(index)
    weight = delta/width
    lower = self%rtsi(index)
    upper = self%rtsi(index + 1)
    difference = upper - lower
    product = weight*difference
    irradiance = lower + product
    status = 0_int32
  end function
end module native_solar_irradiance
