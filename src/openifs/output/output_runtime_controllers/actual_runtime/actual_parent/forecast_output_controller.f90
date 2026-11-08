!> Borrow canonical forecast owners for the complete own Fullpos controller.
module forecast_output_controller
  use iso_fortran_env, only: int32, int64, real64
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_initial_fields_storage, only: native_initial_fields_state
  use spectral_field_storage_port, only: spectral_field_state
  use surface_field_configuration_port, only: surface_field_registry
  use surface_field_storage_port, only: surface_field_state
  use forecast_fullpos_state_types, only: native_fullpos_state, native_fullpos_data
  use forecast_output_request_preparation, only: native_output_common_metadata, native_output_preparation_policy
  use forecast_output_request_types, only: native_output_service_counters
  use forecast_output_request_views, only: native_output_view_counters
  use forecast_runtime_fullpos_norm_controllers, only: native_fullpos_norm_context, native_fullpos_norm_results
  use runtime_fullpos_norm_transport_port, only: fullpos_norm_partition
  use forecast_grib_field_writers, only: native_grib_writer_context, native_grib_writer_inputs, native_grib_writer_policy
  use forecast_output_grid_calculations, only: native_output_grid_sources
  use md2asm_scalar_output_transform_caller, only: output_stage_counters
  use forecast_native_scalar_data, only: native_forecast_scalar_data
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use yoecldp, only: tecldp
  use forecast_actual_output_writer_bridge, only: native_actual_output_writer_context, initialize_actual_output_writer
  use forecast_runtime_physical_output_block, only: native_physical_output_controls, admit_physical_output_controls
  use forecast_output_runtime_bindings, only: native_output_metadata_namespace
  use mpi_f08, only: MPI_Comm
  implicit none
  private
  public :: native_fullpos_driver_context, execute_fullpos_driver, bind_actual_fullpos_driver
  !> All pointers borrow the actual root owners. No model or field is copied.
  !! The same MODEL/FIELDS/SP/surface identities are used by SCAN2M.
  !! common is the single canonical output-control owner. The format and norm
  !! contexts own only their source service storage and observations.
  type :: native_fullpos_driver_context
    type(native_operational_model_configuration), pointer :: model => null()
    type(native_initial_fields_state), pointer :: model_fields => null()
    type(spectral_field_state), pointer :: spectral => null()
    type(surface_field_registry), pointer :: surface_metadata => null()
    type(surface_field_state), pointer :: surface_arrays => null()
    type(native_output_common_metadata), pointer :: common => null()
    type(native_forecast_scalar_data), pointer :: scalars => null()
    type(tecldp), pointer :: cloud => null()
    type(thermal_parameter_record), pointer :: thermal => null()
    type(native_actual_output_writer_context) :: actual_writer
    type(native_physical_output_controls) :: physical_controls
    type(native_output_preparation_policy) :: preparation_policy
    type(native_output_service_counters) :: service_counters
    type(native_output_view_counters) :: view_counters
    type(native_fullpos_norm_context) :: norm_context
    type(native_fullpos_norm_results) :: norm_results
    type(fullpos_norm_partition) :: norm_partition
    type(native_grib_writer_context) :: writer
    type(native_grib_writer_inputs) :: writer_inputs
    type(native_grib_writer_policy) :: writer_policy
    type(native_output_grid_sources) :: grid_sources
    type(output_stage_counters) :: transform_counters
    integer(int32) :: nfpos = 0, time_format = 0, update_date = 0, norm_chunk_size = 1
    character(32) :: domain_name = ' '
    integer(int64) :: grid_calculation_calls = 0
    integer(int32) :: grib_file_count = 0, io_service = 0
    logical :: hook_enabled = .false., split_output = .false., cumulative_flux_active = .false.
    integer(int64) :: driver_calls = 0, allfpos_calls = 0, scalar_copy_calls = 0, norm_dispatch_calls = 0
  end type
  interface
    !> Execute the complete source controller with native optional owners.
    !! Its implementation is compiled as the controller submodule.
    module function execute_fullpos_driver(context, fullpos, data, lag, delay, ocean, &
                                           physical_count, physical_codes) result(status)
      integer(int32) :: status
      type(native_fullpos_driver_context), intent(inout) :: context
      type(native_fullpos_state), target, intent(in) :: fullpos
      type(native_fullpos_data), intent(inout) :: data
      integer(int32), intent(in) :: lag
      logical, intent(in) :: delay, ocean
      integer(int32), intent(inout) :: physical_count, physical_codes(:)
    end function
  end interface
contains
  !> Borrow the final production owners and construct only source output metadata.
  !! physics_controls and writer_policy are readonly projections of the live
  !! physics, flux, coupling and I/O controls. Their flags are never guessed.
  !! soil/water are the genuine surface YSOIL RDAT/RDAW arrays in metres.
  !! Every rank calls this after its real forecast and thermal setup completes.
  integer(int32) function bind_actual_fullpos_driver(context, model, model_fields, spectral, surface_metadata, &
                         surface_arrays, common, scalars, cloud, thermal, metadata, physics_controls, writer_policy, communicator, &
                                                     soil, water, output_directory, budget, time_loop_ready) result(status)
    use forecast_actual_output_norm_bridge, only: initialize_actual_output_norm_maps
    type(native_fullpos_driver_context), intent(inout) :: context
    type(native_operational_model_configuration), target, intent(inout) :: model
    type(native_initial_fields_state), target, intent(inout) :: model_fields
    type(spectral_field_state), target, intent(inout) :: spectral
    type(surface_field_registry), target, intent(inout) :: surface_metadata
    type(surface_field_state), target, intent(inout) :: surface_arrays
    type(native_output_common_metadata), target, intent(inout) :: common
    type(native_forecast_scalar_data), target, intent(in) :: scalars
    type(tecldp), target, intent(in) :: cloud
    type(thermal_parameter_record), target, intent(in) :: thermal
    type(native_output_metadata_namespace), intent(in) :: metadata
    type(native_physical_output_controls), intent(in) :: physics_controls
    type(native_grib_writer_policy), intent(in) :: writer_policy
    type(MPI_Comm), intent(in) :: communicator
    real(real64), intent(in) :: soil(4), water(4)
    character(*), intent(in) :: output_directory
    integer(int64), intent(in) :: budget
    logical, intent(in) :: time_loop_ready
    type(native_actual_output_writer_context) :: writer
    type(native_physical_output_controls) :: physical
    status = 2
    if (.not. associated(model%initial)) return
    if (.not. allocated(model%initial%geometry)) return
    if (.not. associated(model_fields%state_model, model)) return
    if (.not. associated(model_fields%surface_metadata, surface_metadata)) return
    if (.not. associated(model_fields%surface_arrays, surface_arrays)) return
    if (.not. associated(model_fields%grid_fields)) return
    if (.not. allocated(model_fields%grid_fields%gfl)) return
    if (.not. allocated(model%motion%gmv)) return
    if (.not. allocated(surface_arrays%sp_sb) .or. .not. allocated(surface_arrays%sp_sg)) return
    if (context%actual_writer%ready) return
    if (writer_policy%nproc /= model%initial%geometry%transform_control%nproc) return
    if (writer_policy%nouttype /= 1 .or. writer_policy%nconf /= 1 .or. writer_policy%lecmwf /= 1) return
    if (writer_policy%l_oops /= 0 .or. writer_policy%ltwgra /= 0 .or. writer_policy%ltwinc /= 0 .or. &
   writer_policy%ltwbgv /= 0 .or. writer_policy%ltwcgl /= 0 .or. writer_policy%lppsteps /= 0 .or. writer_policy%lvareps /= 0) return
    physical = physics_controls
    physical%block_width = size(model%motion%gmv, 1)
    physical%local_points = model%initial%geometry%partition%ngptot
    physical%soil_layers = size(surface_arrays%sp_sb, 2)
    physical%snow_layers = size(surface_arrays%sp_sg, 2)
    physical%gravity = model%initial%constants%rg
    physical%standard_lapse = model%initial%geometry%atmosphere%reference_tables(1)%gradient(1)
    physical%budget_bytes = budget
    status = admit_physical_output_controls(physical)
    if (status /= 0) return
    status = initialize_actual_output_writer(writer, model%initial%geometry, metadata, &
                                             model%initial%controls%clock, model%initial%controls%namespace%cnmexp, communicator, &
                          time_loop_ready, output_directory, model%initial%constants%rg, thermal%rhoh2o, cloud%ramin, cloud%rlmin, &
                                             soil, water, budget)
    if (status /= 0) return
    status = initialize_actual_output_norm_maps(model%initial%geometry, communicator, budget, context%norm_partition)
    if (status /= 0) return
    context%model => model; context%model_fields => model_fields; context%spectral => spectral
    context%surface_metadata => surface_metadata; context%surface_arrays => surface_arrays; context%common => common
    context%scalars => scalars; context%cloud => cloud; context%thermal => thermal
    context%actual_writer = writer; context%physical_controls = physical; context%writer_policy = writer_policy
    context%preparation_policy%lecmwf = model%initial%controls%namespace%lecmwf /= 0
    context%preparation_policy%larpegef = model%initial%controls%namespace%larpegef /= 0
    context%preparation_policy%lelam = model%initial%controls%namespace%lelam /= 0
    context%nfpos = model%initial%controls%namespace%nfpos
    context%time_format = metadata%ntimefmt
    context%grid_sources%geometry => model%initial%geometry
    context%grid_sources%motion => model%motion
    context%grid_sources%constants => model%initial%constants
    context%grid_sources%constituents => model_fields%grid_fields%gfl
    context%grid_sources%budget_bytes = budget
  end function
end module
