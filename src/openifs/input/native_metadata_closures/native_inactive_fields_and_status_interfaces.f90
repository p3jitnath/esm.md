!> Join unchanged native inactive-field defaults and both public I/O formats.
!! The fields use their existing source units and complete native bounds.
!! No copied numerical stage or private language-runtime descriptor is used.
module forecast_native_metadata_interfaces
  use iso_fortran_env, only: int32
  use grid_field_registration_types_port, only: grid_field_registration_state
  use grid_field_alias_types_port, only: grid_field_alias_controls
  use grid_field_inactive_types_port, only: grid_field_settings, inactive_grid_field_profiles
 use inactive_grid_field_defaults_port,only:initialize_selected_inactive_grid_defaults,initialize_operational_inactive_grid_defaults
  use forecast_interpolation_state_types, only: native_interpolation_state
  use forecast_interpolation_reporting, only: write_distributed_halo_status
  use forecast_geometry_and_radiation_reporting, only: write_radiation_interpolation_extent
  implicit none
  private
  public :: initialize_selected_inactive_table, initialize_runtime_inactive_table
  public :: write_main_interpolation_status, write_radiation_interpolation_status
contains
  integer(int32) function initialize_selected_inactive_table(state, controls, settings, profiles) result(status)
    type(grid_field_registration_state), intent(in) :: state
    type(grid_field_alias_controls), intent(inout) :: controls
    type(grid_field_settings), intent(inout) :: settings
    type(inactive_grid_field_profiles), intent(inout) :: profiles
    status = initialize_selected_inactive_grid_defaults(state, controls, settings, profiles)
  end function
  integer(int32) function initialize_runtime_inactive_table(state, controls, settings, profiles) result(status)
    type(grid_field_registration_state), intent(in) :: state
    type(grid_field_alias_controls), intent(inout) :: controls
    type(grid_field_settings), intent(inout) :: settings
    type(inactive_grid_field_profiles), intent(inout) :: profiles
    status = initialize_operational_inactive_grid_defaults(state, controls, settings, profiles)
  end function
  integer(int32) function write_main_interpolation_status(state, unit) result(status)
    type(native_interpolation_state), intent(in) :: state
    integer(int32), intent(in) :: unit
    status = write_distributed_halo_status(state, unit)
  end function
  integer(int32) function write_radiation_interpolation_status(state, unit) result(status)
    type(native_interpolation_state), intent(in) :: state
    integer(int32), intent(in) :: unit
    status = write_radiation_interpolation_extent(state, unit)
  end function
end module
