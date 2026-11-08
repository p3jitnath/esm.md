!> Keep every actual forecast owner at one stable native execution address.
!! This declaration supplies no scientific default, result or readiness flag.
module forecast_native_execution_state
  use iso_fortran_env, only: int32, int64, real64
  use forecast_native_field_variable_types, only: native_registry_extra_aliases
  use forecast_ecmwf_physics_runtime_controls, only: initialize_actual_registry_physics_data
 use forecast_variational_simulation_control, only: native_variational_simulation_control, initialize_variational_simulation_control
  use forecast_interpolation_coefficient_table_types, only: native_interpolation_coefficient_tables
  use forecast_parallel_interpolation_controls, only: parallel_interpolation_controls, first_parallel_namelist_values, &
                                                      initialize_operational_interpolation_policy
  use forecast_native_io_server_namespace, only: native_io_server_namespace, initialize_owned_io_server_namespace
  use forecast_native_runtime_physics_control_binding, only: native_public_hook_control, refresh_native_public_hook_control
  use forecast_native_single_column_control, only: native_single_column_control, initialize_native_single_column_control
  use forecast_soil_diagnostic_class_counts, only: native_soil_diagnostic_class_counts, initialize_soil_diagnostic_class_counts
  use forecast_output_setup_upstream, only: native_output_setup_upstream
  use forecast_surface_output_selectors, only: native_surface_output_selectors
  use forecast_native_gp_factory_types, only: native_gp_factory_work
  use forecast_scalar_machine_controls, only: native_scalar_machine_controls, initialize_native_scalar_machine_controls
  use mpi_f08, only: MPI_Comm, MPI_COMM_WORLD, MPI_Initialized, MPI_Comm_size, MPI_SUCCESS, operator(==)
  use forecast_loaded_operational_model, only: native_loaded_operational_input_budget, agree_input_controller_status
  use forecast_native_physics_factory_state, only: native_physics_context_factory_state
  use forecast_native_radiation_preparation, only: prepare_native_radiation_setup
  use forecast_native_startup_storage, only: native_forecast_startup_storage, create_native_forecast_startup_storage
  use forecast_remaining_dynamics_controls, only: native_remaining_dynamics_controls, complete_admitted_dynamics_controls
  use forecast_implicit_time_weights, only: initialize_implicit_time_weights
  use forecast_additional_dynamics_controls, only: initialize_inactive_sponge_controls
  use forecast_dynamical_diagnostic_storage, only: native_dynamical_diagnostic_controls, native_dynamical_diagnostic_storage, &
                                                   initialize_dynamical_diagnostic_controls
  use forecast_live_disabled_stochastic_physics, only: initialize_live_disabled_stochastic_physics
  use forecast_inactive_composition, only: initialize_inactive_chemistry_scalars
  use forecast_operational_lagrangian_controls, only: initialize_operational_rayleigh_controls
  use forecast_owned_global_angle_preimages, only: native_owned_global_angle_preimages, initialize_owned_global_angle_preimages
  use forecast_grid_work_state, only: native_grid_work_state
  use forecast_native_flux_controls, only: native_forecast_flux_controls
  use forecast_fullpos_file_metadata, only: native_fullpos_file_metadata
  use selected_radiation_control_setup_port, only: radiation_control_upstream_record
  use yomfpc, only: tnamfpl
  use forecast_disabled_stochastic_patterns, only: native_sppt_data
  use yomspsdt, only: tsppt_config
  use spp_mod, only: tspp_config
  use stoph_mix, only: tstoph
  use yomcompo, only: tcompo
  use yomchem, only: tchem
  use owned_ecmwf_thermal_state_port, only: ecmwf_thermal_state_record
  use forecast_ecmwf_physics_field_types, only: native_physics_runtime_data
  use forecast_spectral_setup_state, only: native_spectral_calculation_state, native_spectral_setup_sources, &
                                           bind_native_spectral_calculation_sources
  use forecast_runtime_dry_mass_reference, only: native_dry_mass_reference
  use md2asm_model_transform_callers, only: model_transform_context, model_transform_state
  use forecast_complete_forecast_grid_driver_strided, only: native_forecast_grid_inputs
  use forecast_native_grid_scan, only: native_forecast_grid_scan_context
  use forecast_native_time_step, only: native_forecast_step_context, native_step_excluded_controls, native_step_transform_flags
  use forecast_native_time_loop, only: native_forecast_loop_context, native_loop_excluded_controls
  use forecast_fullpos_state_types, only: native_fullpos_state, native_fullpos_data
  use forecast_runtime_output_configuration, only: native_runtime_output_configuration
  use forecast_output_runtime_bindings, only: native_output_metadata_namespace
  use forecast_output_request_preparation, only: native_output_common_metadata
  use forecast_complete_physics_context_types, only: native_complete_physics_driver_inputs
  use native_radiation_forecast_driver, only: native_radiation_driver_context
  implicit none
  private
  public :: native_forecast_execution_state, initialize_fresh_execution_mass, prepare_actual_execution_dynamics_controls
  public :: prepare_actual_execution_angle_preimages, prepare_actual_execution_rayleigh_controls
  public :: complete_actual_execution_stochastic_spectral_controls
  public :: prepare_actual_execution_radiation_storage, create_native_forecast_execution_storage
  public :: prepare_actual_execution_machine_controls, prepare_actual_execution_composition
  public :: prepare_actual_execution_metadata
  !> Own setup records once and borrow their existing numerical arrays.
  !! STARTUP owns the only initial geometry, MODEL/FIELDS/input, scalar,
  !! loop-data, norm and forcing records. SPECTRAL_SETUP owns its real
  !! reference/mode/diffusion/pressure arrays. MASS is shared by CNT4 and SPCM.
  !! FULLPOS and its configuration/common records are produced by the real
  !! output setup factory. No empty request owner replaces a scheduled output.
  !! The context records below contain native borrowed views. They do not
  !! own a second weather field or create the work computed by their children.
  !! Allocate this enclosing object as TARGET once. Do not assign or move it
  !! while its internal/external aliases are live. Retire all borrowed views
  !! before releasing any target. PHASE records only a completed real stage.
  type :: native_forecast_execution_state
    type(native_forecast_startup_storage), allocatable :: startup
    type(native_owned_global_angle_preimages) :: global_angles
    type(native_soil_diagnostic_class_counts) :: soil_classes
    type(native_output_setup_upstream) :: output_setup
    type(native_surface_output_selectors) :: surface_selectors
    type(native_variational_simulation_control) :: variational_control
    type(native_interpolation_coefficient_tables) :: interpolation_tables
    type(parallel_interpolation_controls) :: parallel_policy
    type(first_parallel_namelist_values) :: parallel_admitted
    type(native_io_server_namespace) :: io_server
    type(native_public_hook_control) :: hook_control
    type(native_single_column_control) :: single_column_control
    integer(int32) :: ndimsigmv
    type(radiation_control_upstream_record) :: radiation_seed
    type(native_grid_work_state) :: grid_work
    type(native_gp_factory_work) :: gp_work
    type(native_scalar_machine_controls) :: machine_controls
    type(native_forecast_flux_controls) :: flux_controls
    type(native_remaining_dynamics_controls) :: remaining
    type(native_dynamical_diagnostic_controls) :: diagnostic_controls
    type(native_dynamical_diagnostic_storage) :: diagnostic_storage
    type(tsppt_config) :: sppt_configuration
    type(native_sppt_data) :: sppt_data
    type(tspp_config) :: spp_configuration
    type(tstoph) :: stochastic_physics
    type(tcompo) :: composition
    type(tchem) :: chemistry
    real(real64), allocatable :: rspongf(:)
    logical :: lnsponge
    type(ecmwf_thermal_state_record) :: thermal
    type(native_physics_runtime_data) :: physics_runtime
    type(native_physics_context_factory_state) :: physics_factory
    type(native_spectral_setup_sources) :: spectral_sources
    type(native_spectral_calculation_state) :: spectral_setup
    type(native_dry_mass_reference) :: mass
    type(model_transform_context) :: transform
    type(model_transform_state) :: transform_fields
    type(native_forecast_grid_inputs) :: grid
    type(native_complete_physics_driver_inputs) :: physics
    type(native_radiation_driver_context) :: radiation
    type(native_forecast_grid_scan_context) :: scan
    type(native_forecast_step_context) :: step
    type(native_forecast_loop_context) :: loop
    type(native_step_excluded_controls) :: step_controls
    type(native_step_transform_flags) :: inverse_flags
    logical :: rayleigh_isotropic
    type(native_loop_excluded_controls) :: loop_controls
    type(native_fullpos_state), allocatable :: fullpos
    type(tnamfpl) :: output_levels
    type(native_fullpos_file_metadata) :: output_file_metadata
    type(native_fullpos_data) :: fullpos_data
    type(native_runtime_output_configuration) :: output_configuration
    type(native_output_metadata_namespace) :: output_metadata
    type(native_output_common_metadata) :: output_common
    integer(int32) :: n_phys_mwave = 0_int32
    integer(int32), pointer :: physical_count => null(), physical_codes(:) => null()
    type(native_registry_extra_aliases) :: registry_aliases
    integer(int32) :: phase = 0, last_child_status = 0, last_failed_stage = 0
  end type
contains
  !> Run actual scalar metadata producers on their sole retained targets.
  !! TEXT is the unchanged configuration; counts are dimensionless.
  !! Every target is produced before a later context can borrow its address.
  integer(int32) function prepare_actual_execution_metadata(state) result(status)
    type(native_forecast_execution_state), target, intent(inout) :: state
    integer :: n
    status = 2
    if (state%phase /= 11 .or. .not. allocated(state%startup)) return
    n = state%startup%initial%prefix%configuration_bytes
    associate (controls => state%startup%initial%controls%namespace)
      state%last_failed_stage = 113
      status = initialize_soil_diagnostic_class_counts(state%soil_classes, controls%lecmwf /= 0)
      if (status /= 0) return
      state%last_failed_stage = 114
      status = initialize_variational_simulation_control(controls%nconf, state%variational_control)
      if (status /= 0) return
    end associate
    state%last_failed_stage = 115
    status = initialize_operational_interpolation_policy(state%startup%initial%prefix%configuration_text(1:n), &
                                                         state%parallel_policy, state%parallel_admitted)
    if (status /= 0) return
    state%last_failed_stage = 116
    status = initialize_owned_io_server_namespace(state%io_server)
    if (status /= 0) return
    state%last_failed_stage = 117
    status = initialize_native_single_column_control(state%startup, state%single_column_control)
    if (status /= 0) return
    state%last_failed_stage = 119
    status = initialize_actual_registry_physics_data(state%startup%initial%prefix%configuration_text(1:n), &
                                                     state%startup%initial%controls%namespace, state%physics_runtime)
    if (status /= 0) return
    state%last_failed_stage = 118
    status = refresh_native_public_hook_control(state%hook_control)
    if (status /= 0) return
    state%last_failed_stage = 0
  end function

  !> Apply the genuine inactive chemistry defaults to the unique source records.
  !! Counts come from the completed GFL metadata. The child refuses active
  !! chemistry or aerosols; it does not alter any retained strings or arrays.
  integer(int32) function prepare_actual_execution_composition(state) result(status)
    type(native_forecast_execution_state), target, intent(inout) :: state
    integer(int32) :: counts(4)
    status = 2
    if (state%phase /= 10 .or. .not. allocated(state%startup)) return
    if (.not. allocated(state%startup%loaded%storage)) return
    associate (fields => state%startup%loaded%storage%model%fields)
      counts = [fields%alias_controls%nchem, fields%alias_controls%nghg, fields%alias_controls%naero, fields%settings%nactaero]
    end associate
    state%last_failed_stage = 112
    status = initialize_inactive_chemistry_scalars(state%composition, state%chemistry, counts)
    if (status == 0) state%last_failed_stage = 0
  end function

  !> Produce the actual scalar-machine controls from source defaults and text.
  !! LOPT_SCALAR is a source-defined 0/1 word, not an inference from world size.
  integer(int32) function prepare_actual_execution_machine_controls(state) result(status)
    type(native_forecast_execution_state), target, intent(inout) :: state
    integer :: n, error, processes
    status = 2
    if (state%phase /= 10 .or. .not. allocated(state%startup)) return
    if (.not. allocated(state%startup%initial) .or. .not. allocated(state%startup%loaded%input)) return
    call MPI_Comm_size(state%startup%loaded%input%world, processes, error)
    if (error /= MPI_SUCCESS) return
    n = state%startup%initial%prefix%configuration_bytes
    state%last_failed_stage = 110
    status = initialize_native_scalar_machine_controls(state%startup%initial%prefix%configuration_text(1:n), &
                                                       int(processes, int32), state%machine_controls)
    if (status == 0) state%last_failed_stage = 0
  end function

  !> Allocate the final execution owner and run the complete early setup prefix.
  !! This entry stops before the real radiation seed and SUPHEC stages. Return0
  !! means phase11 only; it does not claim loaded weather fields or a forecast.
  !! WORLD is the actual initialized MPI_COMM_WORLD with4 or32 processes.
  !! Byte limits are per-rank capacities. Paths remain immutable inputs.
  !! Failure retains each reached owner for the enclosing source-order release.
  integer(int32) function create_native_forecast_execution_storage(world, spectral_path, surface_path, upper_air_path, &
              configuration_path, budget, loop_bytes, norm_bytes, data_directory, output, child_status, failed_stage) result(status)
    type(MPI_Comm), intent(in) :: world
    character(*), intent(in) :: spectral_path, surface_path, upper_air_path, configuration_path, data_directory
    type(native_loaded_operational_input_budget), intent(in) :: budget
    integer(int64), intent(in) :: loop_bytes, norm_bytes
    type(native_forecast_execution_state), allocatable, target, intent(inout) :: output
    integer(int32), intent(out) :: child_status, failed_stage
    integer(int32) :: local, detail
    integer :: error, processes, allocation_status
    logical :: active
    status = 2; child_status = 2; failed_stage = 1
    call MPI_Initialized(active, error)
    if (error /= MPI_SUCCESS .or. .not. active) return
    if (.not. (world == MPI_COMM_WORLD)) return
    call MPI_Comm_size(world, processes, error)
    if (error /= MPI_SUCCESS) then
      child_status = error; return
    end if
    local = 2
    admission: block
      if (allocated(output)) exit admission
      if (processes /= 4 .and. processes /= 32) exit admission
      if (loop_bytes < 0_int64 .or. norm_bytes < 0_int64) exit admission
      if (.not. execution_path_admitted(spectral_path) .or. .not. execution_path_admitted(surface_path)) exit admission
      if (.not. execution_path_admitted(upper_air_path) .or. .not. execution_path_admitted(configuration_path)) exit admission
      if (len_trim(data_directory) < 1 .or. len_trim(data_directory) > 480) exit admission
      if (index(data_directory, achar(0)) /= 0) exit admission
      local = 0
    end block admission
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    allocate (output, stat=allocation_status)
    local = merge(1_int32, 0_int32, allocation_status /= 0)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) then
      if (allocated(output)) deallocate (output)
      return
    end if
    failed_stage = 2
    status = create_native_forecast_startup_storage(world, spectral_path, surface_path, upper_air_path, configuration_path, &
                                               budget, loop_bytes, norm_bytes, data_directory, output%startup, child_status, detail)
    output%last_failed_stage = detail
    if (status /= 0) return
    failed_stage = 3
    local = initialize_fresh_execution_mass(output)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 4
    local = prepare_actual_execution_angle_preimages(output)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 5
    local = prepare_actual_execution_dynamics_controls(output)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 6
    local = prepare_actual_execution_rayleigh_controls(output)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 7
    local = prepare_actual_execution_machine_controls(output)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 8
    local = prepare_actual_execution_composition(output)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 9
    local = prepare_actual_execution_radiation_storage(output)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 10
    local = prepare_actual_execution_metadata(output)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    output%last_failed_stage = 0; output%last_child_status = 0; failed_stage = 0
  end function

  !> Check an input path before any execution-owner allocation.
  logical function execution_path_admitted(path) result(admitted)
    character(*), intent(in) :: path
    admitted = len(path) >= 1 .and. len(path) <= 4095
    if (admitted) admitted = index(path, achar(0)) == 0
  end function

  !> Run the actual explicit-CMIP radiation storage and context producers.
  !! The source seed projection and SUPHEC remain later real stages.
  integer(int32) function prepare_actual_execution_radiation_storage(state) result(status)
    type(native_forecast_execution_state), target, intent(inout) :: state
    status = 2
    if (state%phase /= 10 .or. .not. allocated(state%startup)) return
    if (.not. state%global_angles%ready) return
    state%last_failed_stage = 111
    status = prepare_native_radiation_setup(state%startup)
    if (status /= 0) return
    state%phase = 11; state%last_failed_stage = 0; state%last_child_status = 0
  end function

  !> Retain the four actual fresh outer-geometry angle preimages once.
  !! The producer checks the real initialized geometry and retains its products.
  integer(int32) function prepare_actual_execution_angle_preimages(state) result(status)
    type(native_forecast_execution_state), target, intent(inout) :: state
    status = 2
    if (state%phase /= 0 .or. .not. allocated(state%startup)) return
    if (.not. allocated(state%startup%initial)) return
    status = initialize_owned_global_angle_preimages(state%startup%initial, state%global_angles)
  end function

  !> Parse the actual inactive Rayleigh branch into its unique source words.
  integer(int32) function prepare_actual_execution_rayleigh_controls(state) result(status)
    type(native_forecast_execution_state), target, intent(inout) :: state
    integer :: n
    status = 2
    if (state%phase /= 10 .or. .not. allocated(state%startup)) return
    if (.not. allocated(state%startup%initial)) return
    n = state%startup%initial%prefix%configuration_bytes
    status = initialize_operational_rayleigh_controls(state%startup%initial%prefix%configuration_text(1:n), &
                                state%startup%initial%geometry%dimensions%nflevg, state%startup%initial%controls%namespace%lecmwf, &
                                                      state%inverse_flags%rayleigh, state%rayleigh_isotropic)
  end function

  !> Produce STOPH from completed SUNHD, then bind the real spectral switches.
  !! Phase30 records completed owned spectral setup at this same TARGET.
  !! No field, diffusion coefficient, clock, reference or mode is recalculated.
  !! A refused stage retains reached source writes for the enclosing release.
  integer(int32) function complete_actual_execution_stochastic_spectral_controls(state) result(status)
    type(native_forecast_execution_state), target, intent(inout) :: state
    integer :: n
    status = 2
    if (state%phase /= 30 .or. .not. allocated(state%startup)) return
    if (.not. state%spectral_setup%ready .or. state%spectral_setup%context%ready) return
    if (.not. state%remaining%ready .or. state%spectral_sources%ready) return
    if (.not. allocated(state%startup%loaded%storage) .or. .not. allocated(state%startup%loaded%input)) return
    n = state%startup%initial%prefix%configuration_bytes
    state%last_failed_stage = 301
    status = initialize_live_disabled_stochastic_physics(state%stochastic_physics, state%startup%loaded%storage%model, &
                                                         state%startup%initial%geometry, state%spectral_setup%diffusion, &
                                                         state%startup%initial%prefix%configuration_text(1:n))
    if (status /= 0) return
    associate (model => state%startup%loaded%storage%model, input => state%startup%loaded%input, &
               source => state%spectral_sources, switches => state%spectral_sources%diffusion_switches)
      source%limpf = input%lagrangian%limpf
      source%lmascor = input%lagrangian%lmascor
      source%lgpmascor = state%remaining%lgpmascor
      source%ncurrent_iter = input%lagrangian%ncurrent_iter
      source%nsiter = state%remaining%nsiter
      switches%lstrhd = state%remaining%lstrhd
      switches%lm0damp = state%spectral_setup%diffusion%lm0damp
      switches%lnhdyn = model%dynamics%lnhdyn
      switches%lnhx = model%dynamics%lnhx
      switches%lslhd_w = model%dynamics%lslhd_w
      switches%lslhd_svd = model%dynamics%lslhd_svd
      switches%lrhdddh = state%diagnostic_controls%lrhdddh
      switches%lnsponge = state%lnsponge
      switches%lstoph_spbs = state%stochastic_physics%lstoph_spbs
      switches%lstoph_casbs = state%stochastic_physics%lstoph_casbs
      switches%lvortcon = state%stochastic_physics%lvortcon
      switches%lspt = model%field_dimensions%lspt
      switches%lnudg = model%nudging%lnudg
      source%ready = .true.
    end associate
    state%last_failed_stage = 302
    call bind_native_spectral_calculation_sources(state%spectral_setup, state%spectral_sources, status)
    if (status /= 0) return
    state%phase = 40; state%last_failed_stage = 0; state%last_child_status = 0
  end function

  !> Complete real early dynamics controls after the actual stage25 producer.
  !! This uses the same final RBT/RBTS2 target later borrowed by STEPO/SPCM.
  !! The source empty NAMDDH/NAMSPNG groups are admitted by their real parsers.
  !! No INPUT readiness is claimed before physics and field loading. A late
  !! failure retains reached source writes and must be released by the caller.
  integer(int32) function prepare_actual_execution_dynamics_controls(state) result(status)
    type(native_forecast_execution_state), target, intent(inout) :: state
    integer :: n
    status = 2
    if (state%phase /= 0 .or. .not. allocated(state%startup)) return
    if (.not. allocated(state%startup%loaded%storage) .or. .not. allocated(state%startup%loaded%input)) return
    if (.not. allocated(state%startup%initial) .or. .not. state%startup%initial%ready) return
    if (state%startup%loaded%input%phase /= 25) return
    if (state%remaining%ready .or. state%loop%implicit_weights%ready) return
    n = state%startup%initial%prefix%configuration_bytes
    state%last_failed_stage = 101
    status = complete_admitted_dynamics_controls(.true., state%startup%initial%controls%namespace%nconf, &
                state%startup%initial%controls%clock%integration%total_steps, state%startup%loaded%input%reference, state%remaining)
    if (status /= 0) return
    state%last_failed_stage = 102
    status = initialize_dynamical_diagnostic_controls(state%diagnostic_controls, &
                                                      state%startup%initial%prefix%configuration_text(1:n))
    if (status /= 0) return
    state%startup%loaded%storage%model%lrsiddh = state%diagnostic_controls%lrsiddh
    state%last_failed_stage = 103
    status = initialize_inactive_sponge_controls(state%startup%initial%prefix%configuration_text(1:n), &
                                                 state%rspongf, state%lnsponge)
    if (status /= 0) return
    state%last_failed_stage = 104
    status = initialize_implicit_time_weights(state%startup%loaded%input%lagrangian, &
                            state%startup%initial%controls%namespace%lr2d /= 0, state%startup%loaded%storage%model%dynamics%lslag, &
                                              state%startup%loaded%storage%model%dynamics%ltwotl, state%loop%implicit_weights)
    if (status /= 0) return
    state%phase = 10; state%last_failed_stage = 0; state%last_child_status = 0
  end function

  !> Establish only the three source fresh-MODEL/calloc mass preimages.
  !! These positive zeros are storage initialization, not a mass calculation.
  !! The real CORMASSDRY producer initializes the reference on its first call.
  !! This entry runs once before any mass/loop/spectral view is associated.
  integer(int32) function initialize_fresh_execution_mass(state) result(status)
    type(native_forecast_execution_state), target, intent(inout) :: state
    status = 2
    if (state%phase /= 0) return
    if (associated(state%loop%mass) .or. associated(state%spectral_setup%context%mass)) return
    state%mass%gmassi = 0.0_real64
    state%mass%gmass0 = 0.0_real64
    state%mass%gmassinc = 0.0_real64
    status = 0
  end function
end module forecast_native_execution_state
