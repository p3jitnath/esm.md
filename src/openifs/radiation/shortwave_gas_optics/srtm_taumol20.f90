!> Complete portable band 20 absorption, scattering and selected solar update.
!! Inputs retain the supported source domain and separate FP64 rounding.
module native_srtm_taumol20
  use iso_fortran_env, only: real64
  use native_absorption_records, only: shortwave_absorption_record
  use native_shortwave_gas_inputs, only: shortwave_layer_inputs
  use native_shortwave_band_calculations, only: calculate_shortwave_band
  implicit none
  private
  public :: srtm_taumol20
contains
  !> Update daylight cells in complete sixteen-point native owners.
  !! Solar shape is (columns,16); both optical depths are
  !! (columns,layer_capacity,16). Units are W/m2 and dimensionless.
  !! All input owners are readonly; night, inactive layers and tails are retained.
  subroutine srtm_taumol20(coefficients, input, solar, taug, taur)
    type(shortwave_absorption_record), intent(in), target :: coefficients
    type(shortwave_layer_inputs), intent(in) :: input
    real(real64), intent(inout) :: solar(:, :), taug(:, :, :), taur(:, :, :)
    call calculate_shortwave_band(20, coefficients, input, solar, taug, taur)
  end subroutine
end module
