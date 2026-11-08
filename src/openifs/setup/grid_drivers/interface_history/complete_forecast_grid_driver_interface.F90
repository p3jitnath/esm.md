!> Own the complete grid forecast call order over canonical native state.
module forecast_complete_forecast_grid_driver
  use iso_fortran_env, only: int32, int64, real64
  use mpi_f08, only: MPI_Comm
  use forecast_operational_model_types, only: native_operational_model_configuration
  use gridpoint_field_storage_port, only: gridpoint_field_state
  use forecast_next_time_field_storage, only: native_next_time_gridpoint_state
  use forecast_native_field_registry_types, only: native_field_registry
  use forecast_native_field_variable_types, only: native_registry_geometry_inputs, &
                                   native_registry_ecphysics_inputs, native_registry_radiation_inputs, native_registry_extra_aliases
  use surface_field_configuration_port, only: surface_field_registry
  use surface_field_storage_port, only: surface_field_state
  use forecast_grid_point_block_driver, only: grid_point_block_controls
  use forecast_grid_point_update, only: grid_point_column_views
  use forecast_grid_calculations, only: forecast_grid_vertical_inputs, forecast_grid_surface_map
  use forecast_hydrostatic_grid_calculations, only: hydrostatic_motion_map
  use forecast_lagged_grid_update, only: lagged_grid_controls
  use md2asm_moist_air_gas_properties, only: moist_air_constants, thermal_constituent
  use md2asm_lagrangian_work_initialization, only: lagrangian_component
  use md2asm_two_part_time_filter, only: filter_field_pair
  use forecast_physics_tendency_increment, only: physical_tracer_increment_map
  use md2asm_transport_equation_parent, only: transport_constituent
  use md2asm_departure_field_transport, only: constituent_transport_map
  use md2asm_interpolation_boundary_values, only: interpolation_boundary_map
  use md2asm_vertical_operators, only: vertical_operator_matrices
  use md2asm_spectral_implicit_update, only: spectral_implicit_coefficients
  use md2asm_native_call_sl, only: native_call_sl_arrays
  use md2asm_semi_lagrangian_transport_stage, only: transport_stage_controls, &
                                                    transport_trajectory_inputs, transport_update_inputs, transport_stage_counts
  use md2asm_internal_interpolation_plane_maps, only: interpolation_plane_controls
  use forecast_geometry_block_storage, only: native_spherical_block_view
  use forecast_retained_transport_dispatch, only: native_retained_transport_context
  use forecast_tracer_mass_correction_types, only: tracer_mass_grid, tracer_mass_layout
  use native_radiation_forecast_driver, only: native_radiation_driver_context
  use forecast_complete_physics_context_types, only: native_complete_physics_driver_inputs
  use md2asm_transform_profile_policy, only: transform_profile_policy
  implicit none
  private
  public :: native_forecast_grid_inputs, native_grid_block_inputs, native_forecast_grid_controls
  public :: gp_model, grid_model_stage_count_get
  !> Small source controls. Time intervals remain in their existing child records.
  !! radiation_frequency and step count model steps. padding_control selects the
  !! source largest-finite sentinel. No value here is a calculated weather field.
  type :: native_forecast_grid_controls
    character(len=9) :: configuration = ' '
    integer(int32) :: step = -1, radiation_frequency = 0, padding_control = 0
    logical :: implicit_radiation = .false., radiation_enabled = .false., runtime_dimensions = .false.
    logical :: two_dimensional = .false., full_corrector = .false., cheap_corrector = .false.
    logical :: grid_stress = .false., extra_mass_diagnostics = .false., chemistry = .false.
    logical :: observation_processing = .false., external_coupling = .false.
  end type
  !> Borrow initialized child controls,field maps and real column workspace views.
  !! All pointers retain their actual native owners. Column views contain no
  !! prepared pressure,tendency,interpolation or physics result. This parent
  !! replaces the five GP_MODEL-owned hydrostatic/trajectory workspace views.
  type :: native_grid_block_inputs
    type(grid_point_block_controls) :: controls
    type(moist_air_constants), pointer :: constants => null()
    type(thermal_constituent), pointer :: thermal_components(:) => null()
    type(lagrangian_component), pointer :: work_components(:) => null()
    type(filter_field_pair), pointer :: tracer_pairs(:) => null()
    type(physical_tracer_increment_map), pointer :: physics_components(:) => null()
    type(transport_constituent), pointer :: transport_components(:, :) => null()
    type(constituent_transport_map), pointer :: boundary_components(:) => null()
    type(vertical_operator_matrices), pointer :: tables => null()
    type(spectral_implicit_coefficients), pointer :: coefficients => null()
    type(forecast_grid_vertical_inputs) :: vertical
    type(forecast_grid_surface_map) :: surface_map
    type(hydrostatic_motion_map) :: motion_map
    type(interpolation_boundary_map) :: boundary_maps
    type(grid_point_column_views), pointer :: columns(:) => null()
    integer(int32), pointer :: core_index(:) => null(), counters(:, :) => null()
    integer(int32), pointer :: reset_requests(:) => null(), reset_minutes(:) => null()
    logical, pointer :: flux_reset => null()
    integer(int64) :: diagnostic_calls = 0, end_calls = 0
  end type
  !> Complete GP_MODEL data join. Every borrowed target stays fixed for the call.
  !!
  !! MODEL is the sole configured model and owns MOTION. MODEL%INITIAL owns
  !! the one clock,initialization and geometry. FIELDS owns current GFL arrays;
  !! NEXT owns the separate later GFLT1 array. REGISTRY owns metadata only.
  !! No initial-field loader,public output encoder or second model is created.
  !!
  !! FIRST_BUFFER is PB1(0:NASLB1-1,F1). SECOND_BUFFER is PB2(P,F2,B).
  !! POINTS,levels and blocks come from the live geometry. Geometry block
  !! views and interpolation maps borrow their canonical setup producers.
  !! SPLIT arrays and the five GP_MODEL workspace owners are allocated here,
  !! consumed by the real children,then released in the original source order.
  !! Registry inputs are genuine field/surface aliases,not prepared stage data.
  !!
  !! On status0,MODEL%MOTION,FIELDS,NEXT and physics owners contain the final
  !! grid-stage state. SCAN2M owns its later source T1-to-GFL copy;the forecast
  !! controller owns file output. No callback or original numerical provider
  !! is permitted at this interface. Source/parent acceptance remains separate.
  type :: native_forecast_grid_inputs
    type(native_forecast_grid_controls) :: controls
    type(native_operational_model_configuration), pointer :: model => null()
    type(gridpoint_field_state), pointer :: fields => null()
    type(native_next_time_gridpoint_state), pointer :: next => null()
    type(native_field_registry), pointer :: registry => null()
    type(surface_field_registry), pointer :: surface_metadata => null()
    type(surface_field_state), pointer :: surface_arrays => null()
    type(native_registry_geometry_inputs) :: registry_geometry
    type(native_registry_ecphysics_inputs) :: registry_physics
    type(native_registry_radiation_inputs) :: registry_radiation
    type(native_registry_extra_aliases) :: registry_aliases
    type(native_grid_block_inputs) :: blocks
    type(MPI_Comm) :: communicator
    type(transport_stage_controls) :: transport_controls
    type(interpolation_plane_controls) :: plane_controls
    type(transport_trajectory_inputs) :: trajectory
    type(transport_update_inputs) :: transport_update
    type(native_call_sl_arrays) :: transport_arrays
    type(native_spherical_block_view), pointer :: geometry_blocks(:) => null()
    type(native_retained_transport_context), pointer :: retained => null()
    type(transport_stage_counts) :: transport_counts
    type(tracer_mass_grid) :: mass_grid
    type(tracer_mass_layout) :: mass_layout
    type(native_radiation_driver_context), pointer :: radiation => null()
    type(native_complete_physics_driver_inputs), pointer :: physics => null()
    type(lagged_grid_controls) :: lagged
    real(real64), pointer, contiguous :: first_buffer(:, :) => null(), second_buffer(:, :, :) => null()
    real(real64), pointer :: stress(:, :, :, :) => null()
    integer(int64) :: stage_calls(0:7) = 0_int64
    integer(int64) :: workspace_limit = 64_int64*1024_int64**3
  end type
  interface
    !> Run registry,CPG,transport,fixers,radiation,physics and lagged update.
    !! Status0 completes the source group,1 reports private allocation failure,
    !! and2 refuses a source/child domain. A late failure leaves the complete
    !! parent unaccepted. Scientific outputs retain natural IEEE flags/errno.
    module integer(int32) function gp_model(inputs, profile) result(status)
      type(native_forecast_grid_inputs), target, intent(inout) :: inputs
      type(transform_profile_policy), intent(in), optional :: profile
    end function
  end interface
contains
  !> Read one actual parent stage word;outside0:7 returns0.
  integer(int64) function grid_model_stage_count_get(inputs, index) result(value)
    type(native_forecast_grid_inputs), intent(in) :: inputs
    integer(int32), intent(in) :: index
    value = 0_int64
    if (index >= 0 .and. index <= 7) value = inputs%stage_calls(index)
  end function
end module forecast_complete_forecast_grid_driver
