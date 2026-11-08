!> Native complete typed provider for the selected shared source operations.
!! The source role map records every argument and selected/runtime branch.
!! No raw address table, copied weather owner or added numerical stage is used.
!! Types, shapes, units, admission and mutation are the canonical provider contract.
module forecast_shared_radiative_flux_arguments
  use forecast_native_record_radiative_flux_layer, only: radiative_flux_layer => runtime_radiative_flux_layer
  use forecast_native_record_radiative_flux_layer, only: runtime_radiative_flux_layer
  use forecast_native_record_radiative_flux_layer, only: radiative_flux_model_views
  implicit none
  private
  public :: radiative_flux_layer
  public :: runtime_radiative_flux_layer
  public :: radiative_flux_model_views
end module forecast_shared_radiative_flux_arguments
