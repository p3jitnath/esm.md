!> Form pressure-weighted monthly gas amounts in Pa.
module forecast_monthly_layer_amount
  use iso_fortran_env, only: int32, real64
  implicit none
  private
  public :: interp_gas
contains
  !> Pressure faces start at dummy index0; other array indices start at1.
  !! Volume has shape(latitude,layer,12), amount(latitude,layer).
  !! Native signed strides and gaps are retained; no input may alias amount.
  subroutine interp_gas(month1, month2, weight, pressure_hl, scaling, volume, amount, status)
    integer(int32), intent(in) :: month1, month2
    real(real64), intent(in) :: weight, pressure_hl(0:), scaling, volume(:, :, :)
    real(real64), intent(inout) :: amount(:, :)
    integer(int32), intent(out) :: status
    integer :: j, k, columns, layers
    real(real64) :: difference, layer_factor, blend
    status = 2
    columns = size(amount, 1); layers = ubound(pressure_hl, 1)
    if (columns > 4096 .or. layers < 0 .or. layers > 512) return
    if (month1 < 1 .or. month1 > 12 .or. month2 < 1 .or. month2 > 12) return
    if (size(amount, 2) /= layers) return
    if (size(volume, 1) /= columns .or. size(volume, 2) /= layers .or. size(volume, 3) /= 12) return
    if (columns == 0 .or. layers == 0) then
      status = 0
      return
    end if
    do k = 1, layers
      difference = pressure_hl(k) - pressure_hl(k - 1)
      layer_factor = difference*scaling
      do j = 1, columns
        blend = volume(j, k, month1) - volume(j, k, month2)
        blend = weight*blend
        blend = volume(j, k, month2) + blend
        amount(j, k) = layer_factor*blend
      end do
    end do
    status = 0
  end subroutine
end module
