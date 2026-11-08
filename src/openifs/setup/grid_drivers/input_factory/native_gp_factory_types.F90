!> Own the metadata used to bind the actual native GP_MODEL inputs.
!! This state owns no second model and no prepared weather calculation.
!! Keep it at one final TARGET address until all borrowed GP views end.
module forecast_native_gp_factory_types
  use iso_fortran_env, only: int32, int64
  use forecast_grid_point_update_strided, only: grid_point_column_views
  use md2asm_moist_air_gas_properties, only: moist_air_constants
  use md2asm_lagrangian_work_initialization, only: lagrangian_component
  use md2asm_two_part_time_filter, only: filter_field_pair
  use forecast_physics_tendency_increment, only: physical_tracer_increment_map
  use md2asm_transport_equation_parent, only: transport_constituent
  use md2asm_departure_field_transport, only: constituent_transport_map
  use md2asm_prognostic_departure_update, only: prognostic_constituent_destination
  use md2asm_trajectory_interpolation_parent, only: trajectory_diagnostic_field
  use forecast_retained_transport_dispatch, only: native_retained_transport_context
  use forecast_dynamics_field_maps, only: native_dynamics_field_maps
  implicit none
  private
  public :: native_gp_factory_work
  !> Column descriptors borrow actual GMV,GFL,terrain,vertical and work owners.
  !! Component records preserve the configured GFL order and exact source slots.
  !! COUNTERS has shape(levels,blocks), as in CPG_DRV; it stores integer events.
  !! RETAINED owns the existing CALL_SL coordinate,weight and index workspace.
  !! The separate canonical native_grid_work_state owns IL0/ZLSCAW/PB1/PB2.
  !! No private CPG pressure or tendency array survives a column call.
  type :: native_gp_factory_work
    type(grid_point_column_views), allocatable :: columns(:)
    type(moist_air_constants) :: constants
    type(lagrangian_component), allocatable :: work_components(:)
    type(filter_field_pair), allocatable :: tracer_pairs(:)
    type(physical_tracer_increment_map), allocatable :: physics_components(:)
    type(transport_constituent), allocatable :: transport_components(:, :)
    type(constituent_transport_map), allocatable :: boundary_components(:)
    type(prognostic_constituent_destination), allocatable :: destinations(:)
    type(trajectory_diagnostic_field), allocatable :: diagnostics(:)
    character(len=12), allocatable :: selectors(:)
    integer(int32), allocatable :: counters(:, :)
    type(native_retained_transport_context) :: retained
    type(native_dynamics_field_maps) :: dynamics_maps
    integer(int32) :: pitch = 0, levels = 0, blocks = 0, components = 0, phase = 0
    integer(int64) :: metadata_bytes = 0
    logical :: base_bound = .false., columns_bound = .false., maps_bound = .false.
    logical :: transport_bound = .false., controls_bound = .false., ready = .false.
    ! True only after the complete actual registry constructor succeeds.
    ! A live metadata prefix after failure does not establish this marker.
    logical :: registry_ready = .false.
  end type
end module forecast_native_gp_factory_types
