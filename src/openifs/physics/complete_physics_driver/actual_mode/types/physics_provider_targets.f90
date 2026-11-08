!> Borrow actual scientific providers and the live clock without owning copies.
!! This data-only module does not depend on the driver context or on CALLPAR.
module forecast_physics_provider_targets
  use iso_fortran_env, only: int32, int64, real64
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record, stability_parameter_record
  use yomphy3, only: tphy3
  use spp_mod, only: tspp_config
  use yomozo, only: tozo
  use forecast_native_scalar_data, only: native_forecast_scalar_data
  implicit none
  private
  public :: callpar_provider_targets
  type :: callpar_provider_targets
    type(forecast_physical_constants), pointer :: physical => null()
    type(thermal_parameter_record), pointer :: thermal => null()
    type(stability_parameter_record), pointer :: stability => null()
    type(tphy3), pointer :: physics3 => null()
    type(tspp_config), pointer :: stochastic_configuration => null()
    integer(int32), pointer :: current_step => null(), initial_step => null()
    logical, pointer :: hook_enabled => null(), scmec_enabled => null()
    real(real64), pointer :: rslwx(:) => null()
    logical, pointer :: chem_light_active => null()
    type(native_forecast_scalar_data), pointer :: runtime_scalars => null()
    integer(int64) :: byte_limit = 0_int64
    ! The caller supplies the actual TOZO and traced solar-angle targets.
    type(tozo), pointer :: ozone_chemistry => null()
    real(real64), pointer :: solar_declination => null()
  end type
end module forecast_physics_provider_targets
