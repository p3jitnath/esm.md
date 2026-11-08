!> Form the original climate means and gas interpolation coordinates.
module native_radiation_climate_calculations
  use iso_fortran_env, only: real64
  use iso_c_binding, only: c_double
  use yomclim, only: tghgclim
  use yoeradghg, only: tradghg
  implicit none
  private
  public :: initialize_radiation_climatology_means, initialize_radiation_gas_coordinates
  interface
    function public_cos(x) bind(C, name='cos') result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function public_sin(x) bind(C, name='sin') result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
  end interface
contains
  !> Set eight dimensionless surface means from the selected monthly gases.
  !! CLIMATOLOGY owns latitude(64) in degrees and nine gas arrays(64,91,12).
  !! RPI is the explicit owned value of pi. The checked reader has closed
  !! the file and admitted every native allocation before this raw child.
  !! Only the eight SURF_MEAN fields change. Pressure plane91 is the surface.
  !! Source sums increase through months, then latitudes; every FP64 step
  !! rounds separately. The fixed64-element weight workspace stays on stack.
  subroutine initialize_radiation_climatology_means(climatology, rpi)
    type(tghgclim), intent(inout) :: climatology
    real(real64), intent(in) :: rpi
    real(real64) :: weights(64), radians, weight_sum, denominator, angle
    integer :: latitude
    radians = rpi/180.0_real64
    do latitude = 1, 64
      angle = climatology%latitude(latitude)*radians
      weights(latitude) = public_cos(angle)
    end do
    weight_sum = 0.0_real64
    do latitude = 1, 64
      weight_sum = weight_sum + weights(latitude)
    end do
    denominator = 12.0_real64*weight_sum
    do latitude = 1, 64
      weights(latitude) = weights(latitude)/denominator
    end do
    climatology%surf_mean_co2 = surface_mean(climatology%vmr_co2, weights)
    climatology%surf_mean_ch4 = surface_mean(climatology%vmr_ch4, weights)
    climatology%surf_mean_n2o = surface_mean(climatology%vmr_n2o, weights)
    climatology%surf_mean_no2 = surface_mean(climatology%vmr_no2, weights)
    climatology%surf_mean_cfc11 = surface_mean(climatology%vmr_cfc11, weights)
    climatology%surf_mean_cfc12 = surface_mean(climatology%vmr_cfc12, weights)
    climatology%surf_mean_hcfc22 = surface_mean(climatology%vmr_hcfc22, weights)
    climatology%surf_mean_ccl4 = surface_mean(climatology%vmr_ccl4, weights)
  end subroutine

  !> Keep the exact month sum, weighted product and latitude sum in order.
  real(real64) function surface_mean(gas, weights) result(value)
    real(real64), intent(in) :: gas(:, :, :), weights(64)
    real(real64) :: month_sum, weighted
    integer :: latitude, month
    value = 0.0_real64
    do latitude = 1, 64
      month_sum = 0.0_real64
      do month = 1, 12
        month_sum = month_sum + gas(latitude, 91, month)
      end do
      weighted = month_sum*weights(latitude)
      value = value + weighted
    end do
  end function

  !> Set sine latitude and the ninety-two pressure interfaces for gas data.
  !! RADIATION owns SINLAT(64), PRESSURE_HL(0:91) and nine mass arrays(64,91).
  !! CLIMATOLOGY supplies latitude degrees and91 full pressures in Pa.
  !! Only SINLAT and PRESSURE_HL change; all nine mass arrays stay unwritten.
  !! Interior interfaces use the source sum followed by multiplication.
  !! The last interface uses two products, subtraction, then the source MAX.
  subroutine initialize_radiation_gas_coordinates(radiation, climatology, rpi)
    type(tradghg), intent(inout) :: radiation
    type(tghgclim), intent(in) :: climatology
    real(real64), intent(in) :: rpi
    real(real64) :: radians, angle, temporary, last, previous
    integer :: latitude, level
    radians = rpi/180.0_real64
    do latitude = 1, 64
      angle = climatology%latitude(latitude)*radians
      radiation%sinlat(latitude) = public_sin(angle)
    end do
    radiation%pressure_hl(0) = 0.0_real64
    do level = 1, 90
      temporary = climatology%pressure(level) + climatology%pressure(level + 1)
      radiation%pressure_hl(level) = 0.5_real64*temporary
    end do
    last = 1.5_real64*climatology%pressure(91)
    previous = 0.5_real64*climatology%pressure(90)
    temporary = last - previous
    radiation%pressure_hl(91) = max(110000.0_real64, temporary)
  end subroutine
end module native_radiation_climate_calculations
