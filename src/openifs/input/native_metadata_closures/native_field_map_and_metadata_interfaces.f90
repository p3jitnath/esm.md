!> Consume complete field-map recipes and metadata through their actual owners.
!! Indices and dimensions are dimensionless; ATTRIBUTES keeps its input units.
!! This module forwards to the existing source-ordered native producers.
module forecast_native_field_map_and_metadata_interfaces
  use iso_fortran_env, only: int32, real64
  use forecast_grid_motion_types, only: native_grid_motion_state
  use grid_field_configuration_types_port, only: grid_field_configuration
  use surface_field_configuration_port, only: surface_field_registry
  use forecast_live_field_maps, only: native_live_field_maps, initialize_live_field_maps
  use forecast_main_field_metadata, only: native_main_field_metadata, main_field_count, initialize_main_field_metadata
  implicit none
  private
  public :: initialize_native_field_map_recipes, initialize_native_field_metadata_literals
  public :: native_live_field_maps, native_main_field_metadata, main_field_count
contains
 integer(int32) function initialize_native_field_map_recipes(output, motion, configuration, surface, undefined_field) result(status)
    type(native_live_field_maps), intent(inout) :: output
    type(native_grid_motion_state), intent(in) :: motion
    type(grid_field_configuration), intent(in) :: configuration
    type(surface_field_registry), intent(in) :: surface
    integer(int32), intent(in) :: undefined_field
    status = initialize_live_field_maps(output, motion, configuration, surface, undefined_field)
  end function
integer(int32) function initialize_native_field_metadata_literals(output, attributes, dimensions, dynamic_name_count) result(status)
    type(native_main_field_metadata), intent(inout) :: output(:)
    real(real64), intent(in) :: attributes(4)
    integer(int32), intent(inout) :: dimensions(2)
    integer(int32), intent(in) :: dynamic_name_count
    status = initialize_main_field_metadata(output, attributes, dimensions, dynamic_name_count)
  end function
end module
