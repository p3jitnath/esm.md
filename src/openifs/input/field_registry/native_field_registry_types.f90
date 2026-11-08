!> Own field-registration metadata while borrowing the actual forecast owners.
module forecast_native_field_registry_types
  use iso_fortran_env, only: int32
  use forecast_native_field_variable_types
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_operational_model_types, only: native_operational_model_configuration
  implicit none
  private
  public :: native_field_registry
  type :: native_field_registry
    type(native_geometry_state), pointer :: geometry => null()
    type(native_operational_model_configuration), pointer :: model => null()
    integer(int32) :: nproma = 0, nblocks = 0
    type(native_field_variables), pointer :: variables => null()
    type(native_surface_variables), pointer :: surface => null()
  end type
end module forecast_native_field_registry_types
