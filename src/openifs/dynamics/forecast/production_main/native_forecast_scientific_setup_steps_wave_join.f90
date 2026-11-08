!> Run actual scientific startup stages over one final execution owner.
!! All arguments borrow existing native owners. No scientific input is supplied
!! by a verification driver, private layout, callback or replacement model.
module forecast_native_scientific_setup_steps
  use iso_fortran_env, only: int32, int64
  use mpi_f08, only: MPI_Comm
  use forecast_native_execution_state, only: native_forecast_execution_state, &
                                             complete_actual_execution_stochastic_spectral_controls
  use forecast_loaded_operational_model, only: native_loaded_operational_input_budget, agree_input_controller_status
  use forecast_spectral_setup_state, only: initialize_native_spectral_calculation_owners, &
                                           bind_native_spectral_calculation_fields
  use forecast_native_physics_context_bindings, only: prepare_native_radiation_seed, prepare_native_physics_field_storage
  use forecast_owned_ecmwf_physics_setup_native_clock_waves, only: initialize_owned_ecmwf_physics_from_native_clock
  use ecmwf_physics_control_fields_port, only: selected_composition_aerosol_flags
  use forecast_time_forcing_ozone_storage, only: initialize_time_forcing_ozone_global_storage
  use forecast_loaded_field_continuation, only: load_actual_forecast_fields_after_physics_setup
  use forecast_native_input_memory, only: native_input_memory_policy
  use forecast_grid_storage, only: initialize_forecast_grid_work
  use forecast_disabled_stochastic_patterns, only: initialize_disabled_sppt_setup, initialize_disabled_spp_setup
  use forecast_dynamical_diagnostic_storage, only: allocate_dynamical_diagnostic_storage
  use forecast_dynamical_si_field_count, only: initialize_dynamical_si_field_count
  use forecast_owned_interpolation_halo, only: initialize_configured_operational_interpolation_halo
  use forecast_interpolation_coefficient_tables, only: initialize_interpolation_coefficient_tables
  use forecast_runtime_fullpos_factory, only: initialize_runtime_fullpos_factory
  use forecast_output_setup_upstream, only: initialize_native_output_setup_upstream
  use forecast_surface_output_selectors, only: initialize_surface_output_selectors
  use forecast_native_flux_controls, only: initialize_native_forecast_flux_controls
  implicit none
  private
  public :: prepare_actual_forecast_spectral_setup, prepare_actual_forecast_physics_setup
  public :: load_actual_forecast_input_fields, prepare_actual_forecast_grid_work
  public :: prepare_actual_forecast_diagnostic_storage, prepare_actual_forecast_interpolation
  public :: prepare_actual_forecast_fullpos
contains
  !> Create reference/modes/pressure/SUNHD/RCORDIT, then actual STOPH switches.
  !! BUDGET is a per-rank byte ceiling. All ranks in WORLD enter together.
  !! Phase11 records completed real early setup; phase40 records this prefix.
  !! Failure retains only reached owners for the source-order release.
  integer(int32) function prepare_actual_forecast_spectral_setup(state, world, budget, child_status, failed_stage) result(status)
    type(native_forecast_execution_state), target, intent(inout) :: state
    type(MPI_Comm), intent(in) :: world
    integer(int64), intent(in) :: budget
    integer(int32), intent(out) :: child_status, failed_stage
    integer(int32) :: local
    local = 2; child_status = 2; failed_stage = 1
    admission: block
      if (state%phase /= 11 .or. .not. allocated(state%startup)) exit admission
      if (.not. allocated(state%startup%loaded%storage)) exit admission
      if (.not. state%loop%implicit_weights%ready .or. .not. state%remaining%ready) exit admission
      if (budget < 1_int64) exit admission
      local = 0
    end block admission
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 2
    call initialize_native_spectral_calculation_owners(state%spectral_setup, state%startup%loaded%storage%model, &
                                                       state%mass, state%loop%implicit_weights, world, budget, status)
    child_status = status
    if (status /= 0) return
    state%phase = 30
    failed_stage = 3
    local = complete_actual_execution_stochastic_spectral_controls(state)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 0
  end function

  !> Complete actual native-clock SUPHEC and source scientific storage.
  !! The parent reads only real model/configuration/atmosphere/vertical owners.
  !! PHYSICS_BYTES and OZONE_BYTES are per-rank allocation ceilings in bytes.
  !! The local aerosol flags are readonly projections of actual TCOMPO fields.
  !! They are not retained and cannot become a second scientific namespace.
  integer(int32) function prepare_actual_forecast_physics_setup(state, world, physics_bytes, ozone_bytes, &
                                                                child_status, failed_stage) result(status)
    type(native_forecast_execution_state), target, intent(inout) :: state
    type(MPI_Comm), intent(in) :: world
    integer(int64), intent(in) :: physics_bytes, ozone_bytes
    integer(int32), intent(out) :: child_status, failed_stage
    type(selected_composition_aerosol_flags) :: aerosol_flags
    integer(int32) :: local, aerosol_counts(2)
    integer :: n
    local = 2; child_status = 2; failed_stage = 1
    admission: block
      if (state%phase /= 40 .or. .not. allocated(state%startup)) exit admission
      if (.not. allocated(state%startup%initial)) exit admission
      if (.not. allocated(state%startup%initial%geometry)) exit admission
      if (.not. allocated(state%startup%loaded%storage)) exit admission
      if (.not. state%spectral_setup%context%ready) exit admission
      if (physics_bytes < 1_int64 .or. ozone_bytes < 1_int64) exit admission
      local = 0
    end block admission
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 2
   local=prepare_native_radiation_seed(state%startup,merge(1_int32,0_int32,state%machine_controls%lopt_scalar),state%radiation_seed)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    aerosol_flags%laernitrate = state%composition%laernitrate
    aerosol_flags%laersoa = state%composition%laersoa
    n = state%startup%initial%prefix%configuration_bytes
    associate (initial => state%startup%initial, model => state%startup%loaded%storage%model, &
               geometry => state%startup%initial%geometry)
      aerosol_counts = [model%fields%alias_controls%naero, model%fields%settings%nactaero]
      failed_stage = 3
      local = initialize_owned_ecmwf_physics_from_native_clock(state%startup%loaded%storage%ecmwf, &
                                  initial%prefix%configuration_text(1:n), state%startup%forcing%data_directory, initial%constants, &
                                               initial%controls%namespace, geometry%dimensions, geometry%partition, model%physics, &
                                            initial%controls%clock, state%startup%forcing%cmip, geometry%atmosphere%full_pressure, &
                                               geometry%atmosphere%height, geometry%vertical, model%dynamical_core, state%thermal, &
                                 state%startup%runtime_controls, model%climate, model%physics_auxiliary, model%physics_dimensions, &
                                                         state%radiation_seed, aerosol_flags, aerosol_counts, physics_bytes, .true.)
    end associate
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    state%phase = 41
    failed_stage = 4
    local = initialize_time_forcing_ozone_global_storage(state%startup%loaded%storage, state%startup%forcing, ozone_bytes)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    state%phase = 42
    failed_stage = 5
    local = prepare_native_physics_field_storage(state%startup, state%n_phys_mwave)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    state%phase = 50; failed_stage = 0
  end function

  !> Load genuine spectral, surface and upper-air fields, then bind SPCM views.
  !! Paths are immutable. Each real allocating loader applies the live memory
  !! policy and records its actual observation. No field or decoding stage is
  !! supplied here; every call goes to the production-owned loader graph.
  !! NORM_BYTES bounds diagnostic storage; no weather field uses norm results.
  integer(int32) function load_actual_forecast_input_fields(state, world, spectral_path, surface_path, upper_air_path, &
                                       budget, memory_policy, journal_prefix, norm_bytes, child_status, failed_stage) result(status)
    type(native_forecast_execution_state), target, intent(inout) :: state
    type(MPI_Comm), intent(in) :: world
    character(*), intent(in) :: spectral_path, surface_path, upper_air_path, journal_prefix
    type(native_loaded_operational_input_budget), intent(in) :: budget
    type(native_input_memory_policy), intent(in) :: memory_policy
    integer(int64), intent(in) :: norm_bytes
    integer(int32), intent(out) :: child_status, failed_stage
    integer(int32) :: local
    local = 2; child_status = 2; failed_stage = 1
    admission: block
      if (state%phase /= 51 .or. .not. allocated(state%startup)) exit admission
      if (.not. allocated(state%startup%loaded%storage)) exit admission
      if (.not. state%startup%loaded%storage%ecmwf%setup_complete) exit admission
      if (state%startup%loaded%storage%model%dynamics%lgradsp) exit admission
      local = 0
    end block admission
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    status = load_actual_forecast_fields_after_physics_setup(state%startup%loaded, world, spectral_path, surface_path, &
                 upper_air_path, budget, memory_policy, journal_prefix, norm_bytes, state%startup%norms, child_status, failed_stage)
    if (status /= 0) return
    state%phase = 60
    if (associated(state%startup%loaded%fields%runtime_physics)) then
      local = merge(0_int32, 2_int32, associated(state%startup%loaded%fields%runtime_physics, state%physics_runtime))
    else
      state%startup%loaded%fields%runtime_physics => state%physics_runtime
      local = 0_int32
    end if
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 121
    call bind_native_spectral_calculation_fields(state%spectral_setup, state%startup%loaded%input%spectral, local)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    state%phase = 61; failed_stage = 0
  end function

  !> Allocate the unique source GRIDWORK from real model dimensions and maps.
  !! QUOTA is the admitted per-rank byte capacity. Its four payloads retain
  !! their source-unwritten state until the real grid calculation fills them.
  integer(int32) function prepare_actual_forecast_grid_work(state, world, quota, child_status, failed_stage) result(status)
    type(native_forecast_execution_state), target, intent(inout) :: state
    type(MPI_Comm), intent(in) :: world
    integer(int64), intent(in) :: quota
    integer(int32), intent(out) :: child_status, failed_stage
    integer(int32) :: local
    local = 2; child_status = 2; failed_stage = 1
    admission: block
      if (state%phase /= 63 .or. .not. allocated(state%startup)) exit admission
      if (.not. allocated(state%startup%loaded%storage)) exit admission
      if (.not. state%startup%loaded%ready) exit admission
      if (quota < 1_int64) exit admission
      local = 0
    end block admission
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 2
    associate (model => state%startup%loaded%storage%model, geometry => state%startup%initial%geometry)
      local = initialize_forecast_grid_work(state%grid_work, geometry%dimensions%nproma, geometry%dimensions%nflevg, &
                                       geometry%partition%ngpblks, model%linear_full%ndim, int(model%interpolation%naslb1, int64), &
                                            model%buffers%first%nfldslb1, model%buffers%second%nfldslb2, quota)
    end associate
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    state%phase = 64; failed_stage = 0
  end function

  !> Create the actual disabled stochastic grids and diagnostic arrays once.
  !! Sizes come from produced local and global partition owners. The real
  !! SUNDDH counter supplies NDIMSIGMV, including inactive diagnostics.
  !! No source-unwritten SPPT N2D scalar is read on this disabled route.
  integer(int32) function prepare_actual_forecast_diagnostic_storage(state, world, child_status, failed_stage) result(status)
    type(native_forecast_execution_state), target, intent(inout) :: state
    type(MPI_Comm), intent(in) :: world
    integer(int32), intent(out) :: child_status, failed_stage
    integer(int32) :: local, p, l, b, q, g
    integer :: n
    local = 2; child_status = 2; failed_stage = 1
    admission: block
      if (state%phase /= 50 .or. .not. allocated(state%startup)) exit admission
      if (.not. allocated(state%startup%loaded%storage)) exit admission
      if (.not. allocated(state%startup%initial%geometry%partition%nglobalproc)) exit admission
      if (size(state%startup%initial%geometry%partition%nglobalproc, kind=int64) > huge(0_int32)) exit admission
      local = 0
    end block admission
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    n = state%startup%initial%prefix%configuration_bytes
    associate (geometry => state%startup%initial%geometry, model => state%startup%loaded%storage%model)
      p = geometry%dimensions%nproma; l = geometry%dimensions%nflevg
      b = geometry%partition%ngpblks; q = geometry%partition%ngptot
      g = int(size(geometry%partition%nglobalproc, kind=int64), int32)
      failed_stage = 2
      local = initialize_disabled_sppt_setup(state%sppt_configuration, state%sppt_data, p, l, b, q, g, &
                                             state%startup%initial%prefix%configuration_text(1:n))
      status = agree_input_controller_status(world, local); child_status = local
      if (status /= 0) return
      failed_stage = 3
      local = initialize_disabled_spp_setup(state%spp_configuration, state%startup%initial%prefix%configuration_text(1:n))
      status = agree_input_controller_status(world, local); child_status = local
      if (status /= 0) return
      failed_stage = 4
      local = initialize_dynamical_si_field_count(model%field_dimensions%nfther, model%dynamics%lnhdyn, state%ndimsigmv)
      status = agree_input_controller_status(world, local); child_status = local
      if (status /= 0) return
      failed_stage = 5
      local = allocate_dynamical_diagnostic_storage(state%diagnostic_storage, state%diagnostic_controls, b, &
                            model%field_dimensions%nfther, model%fields%registration%numflds, model%fields%registration%numspflds, &
                                                    state%ndimsigmv, model%dynamics%lnhdyn, model%dynamics%lnhx)
    end associate
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    state%phase = 51; failed_stage = 0
  end function

  !> Build real distributed interpolation maps before their coefficient tables.
  !! QUOTA is the per-rank capacity in bytes for the configured halo owner.
  !! POLICY is the already-produced first NAMPAR1 policy from the same text.
  !! These stages own no second geometry, model or weather field.
  integer(int32) function prepare_actual_forecast_interpolation(state, world, quota, child_status, failed_stage) result(status)
    type(native_forecast_execution_state), target, intent(inout) :: state
    type(MPI_Comm), intent(in) :: world
    integer(int64), intent(in) :: quota
    integer(int32), intent(out) :: child_status, failed_stage
    integer(int32) :: local, details(3), table_stage
    local = 2; child_status = 2; failed_stage = 1
    admission: block
      if (state%phase /= 61 .or. .not. allocated(state%startup)) exit admission
      if (.not. state%startup%loaded%ready .or. .not. state%parallel_policy%ready) exit admission
      if (quota < 1_int64) exit admission
      local = 0
    end block admission
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 2
    local = initialize_configured_operational_interpolation_halo(state%startup%initial%geometry, &
                                            state%startup%loaded%storage%model, state%parallel_policy, quota, 6_int32, child_status)
    status = agree_input_controller_status(world, local)
    if (status /= 0) return
    state%phase = 62
    failed_stage = 3
    local = initialize_interpolation_coefficient_tables(state%interpolation_tables, state%startup%loaded%storage%model, &
                                                        details, table_stage)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    state%phase = 63; failed_stage = 0
  end function

  !> Build the actual persistent Fullpos state and its source request metadata.
  !! SPECTRAL_PATH is the same genuine input path, admitted without truncation.
  !! QUOTA bounds owned output setup storage in bytes. The print input is the
  !! same explicit zero passed by the actual initial-geometry constructor.
  integer(int32)function prepare_actual_forecast_fullpos(state,world,spectral_path,quota,child_status,failed_stage)result(status)
  type(native_forecast_execution_state), target, intent(inout) :: state
  type(MPI_Comm), intent(in) :: world
  character(*), intent(in) :: spectral_path
  integer(int64), intent(in) :: quota
  integer(int32), intent(out) :: child_status, failed_stage
  integer(int32) :: local
  integer :: n
  character(200) :: source_spectral_path
  local = 2; child_status = 2; failed_stage = 1
  admission: block
    if (state%phase /= 64 .or. .not. allocated(state%startup)) exit admission
    if (.not. state%global_angles%ready .or. .not. state%remaining%ready) exit admission
    if (len_trim(spectral_path) < 1 .or. len_trim(spectral_path) > 200) exit admission
    if (index(spectral_path, achar(0)) /= 0 .or. quota < 1_int64) exit admission
    local = 0
  end block admission
  status = agree_input_controller_status(world, local); child_status = local
  if (status /= 0) return
  source_spectral_path = spectral_path
  n = state%startup%initial%prefix%configuration_bytes
  failed_stage = 2
  local = initialize_native_output_setup_upstream(state%startup%initial%prefix%configuration_text(1:n), &
                                                  state%startup%loaded%storage%model, state%remaining, 0_int32, state%output_setup)
  status = agree_input_controller_status(world, local); child_status = local
  if (status /= 0) return
  failed_stage = 3
  local = initialize_surface_output_selectors(state%startup%initial%prefix%configuration_text(1:n), &
                                              state%startup%initial%controls%namespace%lecmwf /= 0, state%surface_selectors)
  status = agree_input_controller_status(world, local); child_status = local
  if (status /= 0) return
  failed_stage = 4
  local = initialize_runtime_fullpos_factory(state%fullpos, state%fullpos_data, state%startup%loaded%storage%model, &
                          state%startup%initial%prefix%configuration_text(1:n), state%output_configuration, state%output_metadata, &
                                             state%output_common, quota, child_status, failed_stage, &
                                             nprintlev=state%output_setup%nprintlev, satellite_count=state%output_setup%nsatsim, &
                                      climate_output=state%output_setup%cfnclimout, surfex_extension=state%output_setup%cfpextsfx, &
     regional_angles=[state%global_angles%elatc, state%global_angles%elonc, state%global_angles%elon0, state%global_angles%elat0], &
                                             output_levels=state%output_levels, output_file_metadata=state%output_file_metadata, &
                     grid_prefixes=state%output_setup%cfngg(1:5)//state%output_setup%cfnua(1:5), spectral_path=source_spectral_path)
  status = agree_input_controller_status(world, local)
  if (status /= 0) return
  failed_stage = 5
  local = initialize_native_forecast_flux_controls(state%startup%initial%prefix%configuration_text(1:n), &
                                                 state%startup%loaded%storage%model, state%output_levels, state%fullpos%ynamfpsci, &
                                                   state%output_file_metadata, state%flux_controls)
  status = agree_input_controller_status(world, local); child_status = local
  if (status /= 0) return
  state%phase = 70; failed_stage = 0
  end function

end module forecast_native_scientific_setup_steps
