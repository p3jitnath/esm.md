!> Interpolate the seven native greenhouse-gas time series in source order.
module native_greenhouse_timeseries
  use iso_fortran_env, only: real64, int32
  use yomghgtimeseries, only: tghgtimeseries
  implicit none
  private
  public :: get_ghg_concentrations
contains
  !> Return seven dimensionless molar fractions for a strictly interior year.
  !! SELF is readonly and owns finite increasing years and seven nonnegative
  !! gas tables at logical indices1:NTIME. NTIME is at least2. Allocation
  !! lower bounds may be below1. YEAR is in calendar years. The seven scalar
  !! outputs are separate INOUT owners and stay unchanged on rejection.
  !! The first matching interval wins, so an internal tie starts a new
  !! interval. Difference, width, division, gas difference, product and sum
  !! are separate FP64 operations. The caller admits nearest rounding,
  !! gradual underflow and separate readonly inputs. No allocation or
  !! original type-bound method is called. Return0 on success or2 otherwise.
  integer(int32) function get_ghg_concentrations(self, year, co2, ch4, n2o, cfc11, cfc12, hcfc22, ccl4) result(status)
    type(tghgtimeseries), intent(in) :: self
    real(real64), intent(in) :: year
    real(real64), intent(inout) :: co2, ch4, n2o, cfc11, cfc12, hcfc22, ccl4
    real(real64) :: delta, width, weight, lower, upper, difference, product
    integer :: index, count
    status = 2_int32; count = self%ntime
    if (count < 2) return
    if (.not. allocated(self%ryear)) return
    if (lbound(self%ryear, 1) > 1 .or. ubound(self%ryear, 1) < count) return
    if (.not. allocated(self%vmr_co2)) return
    if (lbound(self%vmr_co2, 1) > 1 .or. ubound(self%vmr_co2, 1) < count) return
    if (.not. allocated(self%vmr_ch4)) return
    if (lbound(self%vmr_ch4, 1) > 1 .or. ubound(self%vmr_ch4, 1) < count) return
    if (.not. allocated(self%vmr_n2o)) return
    if (lbound(self%vmr_n2o, 1) > 1 .or. ubound(self%vmr_n2o, 1) < count) return
    if (.not. allocated(self%vmr_cfc11)) return
    if (lbound(self%vmr_cfc11, 1) > 1 .or. ubound(self%vmr_cfc11, 1) < count) return
    if (.not. allocated(self%vmr_cfc12)) return
    if (lbound(self%vmr_cfc12, 1) > 1 .or. ubound(self%vmr_cfc12, 1) < count) return
    if (.not. allocated(self%vmr_hcfc22)) return
    if (lbound(self%vmr_hcfc22, 1) > 1 .or. ubound(self%vmr_hcfc22, 1) < count) return
    if (.not. allocated(self%vmr_ccl4)) return
    if (lbound(self%vmr_ccl4, 1) > 1 .or. ubound(self%vmr_ccl4, 1) < count) return
    if (.not. (year > self%ryear(1) .and. year < self%ryear(count))) return
    do index = 1, count - 1
      if (year >= self%ryear(index) .and. year < self%ryear(index + 1)) exit
    end do
    if (index >= count) return
    delta = year - self%ryear(index)
    width = self%ryear(index + 1) - self%ryear(index)
    weight = delta/width
    lower = self%vmr_co2(index)
    upper = self%vmr_co2(index + 1)
    difference = upper - lower
    product = weight*difference
    co2 = lower + product
    lower = self%vmr_ch4(index)
    upper = self%vmr_ch4(index + 1)
    difference = upper - lower
    product = weight*difference
    ch4 = lower + product
    lower = self%vmr_n2o(index)
    upper = self%vmr_n2o(index + 1)
    difference = upper - lower
    product = weight*difference
    n2o = lower + product
    lower = self%vmr_cfc11(index)
    upper = self%vmr_cfc11(index + 1)
    difference = upper - lower
    product = weight*difference
    cfc11 = lower + product
    lower = self%vmr_cfc12(index)
    upper = self%vmr_cfc12(index + 1)
    difference = upper - lower
    product = weight*difference
    cfc12 = lower + product
    lower = self%vmr_hcfc22(index)
    upper = self%vmr_hcfc22(index + 1)
    difference = upper - lower
    product = weight*difference
    hcfc22 = lower + product
    lower = self%vmr_ccl4(index)
    upper = self%vmr_ccl4(index + 1)
    difference = upper - lower
    product = weight*difference
    ccl4 = lower + product
    status = 0_int32
  end function
end module native_greenhouse_timeseries
