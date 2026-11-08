!> Native complete typed provider for the selected shared source operations.
!! The source role map records every argument and selected/runtime branch.
!! No raw address table, copied weather owner or added numerical stage is used.
!! Types, shapes, units, admission and mutation are the canonical provider contract.
module forecast_shared_convection_layer_arguments
  use forecast_native_convection_layer, only: convection_layer => runtime_owned_convection_layer
  use forecast_native_convection_layer, only: runtime_owned_convection_layer
  use forecast_native_convection_layer, only: convection_layer_model_views
  implicit none
  private
  public :: convection_layer
  public :: runtime_owned_convection_layer
  public :: convection_layer_model_views
end module forecast_shared_convection_layer_arguments
