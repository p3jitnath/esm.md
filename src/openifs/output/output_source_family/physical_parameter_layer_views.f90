!> Expose every original layer role through the canonical native field types.
!! These are Fortran module aliases to the complete owned provider routines.
!! The imported interfaces retain their argument intents, shapes, units and
!! mutation rules. No array, parameter record or numerical stage is copied.
!! Nearest-even rounding and gradual underflow are caller preconditions.
!! Each provider retains its explicit supported bounds and policy admission.
module forecast_physical_parameter_layer_views
  use md2asm_runtime_mountain_wave_layer, only: mountain_wave_layer => runtime_mountain_wave_layer
  use forecast_native_record_radiative_flux_layer, only: &
    radiative_flux_layer => runtime_radiative_flux_layer, radiative_flux_model_views
  use forecast_native_convection_layer, only: &
    convection_layer => runtime_owned_convection_layer, convection_layer_model_views
  use forecast_native_record_cloud_layer, only: cloud_microphysics_layer => cloud_layer
  implicit none
  private
  public :: mountain_wave_layer, radiative_flux_layer, convection_layer, cloud_microphysics_layer
  public :: radiative_flux_model_views, convection_layer_model_views
end module
