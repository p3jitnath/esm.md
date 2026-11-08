module forecast_runtime_operational_input
  !! Complete the runtime input call order with one canonical set of owners.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: iso_c_binding, only: c_int, c_ptr, c_f_pointer
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use mpi_f08
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_initial_fields_storage, only: native_initial_fields_state, bind_initial_field_storage_owners
  use forecast_attached_field_container, only: attached_field_container_is_empty
  use forecast_staged_work_storage, only: native_forecast_work_storage, advance_forecast_work_storage, release_forecast_work_storage
  use forecast_ecmwf_physics_state, only: native_ecmwf_physics_state
  use forecast_operational_lagrangian_controls, only: native_lagrangian_controls, initialize_operational_lagrangian_controls
  use forecast_reference_pressure_coefficients, only: reference_atmosphere_values
  use forecast_parallel_interpolation_controls, only: parallel_interpolation_controls,first_parallel_namelist_values,initialize_operational_interpolation_policy
  use forecast_owned_interpolation_halo, only: initialize_configured_operational_interpolation_halo
  use forecast_interpolation_buffer_setup, only: release_distributed_interpolation_buffer
  use forecast_native_initial_field_loading, only: native_initial_field_storage_budget, prepare_native_initial_field_storage, &
               load_native_initial_spectral_fields, prepare_native_initial_upper_air_storage, advance_native_initial_upper_air_input
  use forecast_native_input_memory, only: native_input_memory_policy, native_input_memory_sample, observe_native_input_memory, &
                                          admit_native_input_payload, record_native_input_memory_sample
  use spectral_field_storage_port, only: spectral_field_state
  use owned_distributed_spectral_field_storage_port, only: release_distributed_spectral_field
  use forecast_grid_motion_setup, only: release_grid_motion_fields
  use forecast_orography_initialization, only: native_blocked_orography,initialize_distributed_operational_orography,release_initialized_orography
  use surface_field_storage_port, only: surface_field_state
  use surface_field_configuration_port, only: surface_field_registry, surface_operational_controls, surface_physics_descriptions
  use surface_field_registration_port, only: surface_trajectory_metadata
  use partitioned_surface_state_startup_port, only: initialize_runtime_partitioned_operational_surface_state, &
                                                   release_partitioned_operational_surface_state, clear_surface_physics_descriptions
  use partitioned_upper_air_input_owner_port, only: partitioned_upper_air_input_owner, release_partitioned_upper_air_input_owner
  use md2asm_moist_air_gas_properties, only: thermal_constituent, moist_air_constants
  use initial_spectral_virtual_temperature_port, only: initialize_runtime_spectral_virtual_temperature
  implicit none
  private
  public :: native_operational_input_budget, native_runtime_operational_input_state
  public :: initialize_runtime_operational_input_state, release_runtime_operational_input_state
  type :: native_operational_input_budget
    !! Per-rank payload ceilings are booked on the node before allocation.
    !! Public codec and node-service reserves remain separate policy capacities.
    type(native_initial_field_storage_budget) :: fields
    integer(int64) :: interpolation_bytes = 0
  end type
  type :: native_runtime_operational_input_state
    !! Each numerical payload has one creator here. MODEL and FIELD_CONTEXT
    !! are stable borrowed canonical owners. WORK is transferred without copies;
    !! its dynamic and next-time arrays keep their existing canonical owners.
    type(native_operational_model_configuration), pointer :: model => null()
    type(native_initial_fields_state), pointer :: field_context => null()
    type(native_forecast_work_storage), allocatable :: work
    type(MPI_Comm) :: world = MPI_COMM_NULL
    type(spectral_field_state) :: spectral
    type(partitioned_upper_air_input_owner) :: upper
    type(surface_field_registry) :: surface_metadata
    type(surface_field_state) :: surface_arrays
    type(surface_trajectory_metadata) :: surface_trajectory
    type(surface_physics_descriptions) :: surface_descriptions
    type(native_blocked_orography) :: terrain
    type(native_lagrangian_controls) :: lagrangian
    type(reference_atmosphere_values) :: reference
    type(parallel_interpolation_controls) :: interpolation_policy
    type(first_parallel_namelist_values) :: admitted_parallel
    type(thermal_constituent) :: constituents(9)
    type(moist_air_constants) :: thermal_constants
    integer(int32) :: phase = 0, last_status = 0, loaded_orography = 0, surface_reset = 0
    logical :: owns_halo = .false., owns_motion_spectral = .false., ready = .false.
  end type
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  integer(int32) function initialize_runtime_operational_input_state(configuration, field_context, work, physics, world, &
     spectral_path,surface_path,upper_air_path,budget,memory_policy,resource_prefix,output,child_status,failed_stage) result(status)
    !! Enter after the real model, physics and phase2 work setup have succeeded.
    !! Every MPI rank calls the same stages. Files are genuine production
    !! inputs; the canonical NBSETLEV map assigns all137 levels to MYSETV.
    !! No driver, callback or original model supplies a numerical stage.
    !! A successful admission transfers WORK to OUTPUT at its stable address.
    !! Later failures retain the reached owner and phase for collective cleanup.
    !! Status is the agreed child result; FAILED_STAGE is the entered1:14 stage.
    !! Callers establish nearest-even and gradual underflow once before entry.
    type(native_operational_model_configuration), target, intent(inout) :: configuration
    type(native_initial_fields_state), target, intent(inout) :: field_context
    type(native_forecast_work_storage), allocatable, target, intent(inout) :: work
    type(native_ecmwf_physics_state), intent(in) :: physics
    type(MPI_Comm), intent(in) :: world
    character(*), intent(in) :: spectral_path, surface_path, upper_air_path, resource_prefix
    type(native_operational_input_budget), intent(in) :: budget
    type(native_input_memory_policy), intent(in) :: memory_policy
    type(native_runtime_operational_input_state), allocatable, target, intent(inout) :: output
    integer(int32), intent(out) :: child_status, failed_stage
    type(native_runtime_operational_input_state), allocatable, target :: pending
    type(native_geometry_state), pointer :: geometry
    type(surface_operational_controls) :: surface_controls
    integer(int32) :: water_slots(3), local, platform(5), levels, pitch, points, blocks, ignored, n, detail
    integer :: allocation_status, error, world_size, visit
    real(real64), target :: empty_spectral(0)
    real(real64), pointer, contiguous :: geopotential(:)
    child_status = 2; failed_stage = 0; local = 2
    nullify (geometry, geopotential)
    if (allocated(output)) goto100
    if (.not. allocated(work)) goto100
    if (.not. configuration%ready .or. .not. associated(configuration%initial)) goto100
    if (.not. configuration%initial%ready .or. .not. allocated(configuration%initial%geometry)) goto100
    if (.not. allocated(configuration%initial%prefix)) goto100
    if (.not. configuration%initial%prefix%ready .or. .not. physics%setup_complete) goto100
    if (.not. associated(field_context%state_model, configuration)) goto100
    if (associated(field_context%grid_fields) .or. associated(field_context%surface_arrays)) goto100
    if (.not. field_views_detached(field_context)) goto100
    if (work%phase /= 2 .or. .not. associated(work%model, configuration)) goto100
    if (.not. associated(work%dynamic) .or. .not. associated(work%next)) goto100
    geometry => configuration%initial%geometry
    if (.not. geometry%initialized .or. geometry%partition%phase /= 7) goto100
    if (.not. associated(configuration%partition, geometry%partition)) goto100
    if (.not. allocated(geometry%partition%nglobalindex)) goto100
    levels = geometry%dimensions%nflevg; pitch = geometry%dimensions%nproma
    points = geometry%partition%ngptot; blocks = geometry%partition%ngpblks
    if (levels /= 137 .or. geometry%dimensions%nsmax /= 1279) goto100
    if (geometry%partition%ngptotg /= 6599680 .or. pitch < 1 .or. pitch > 1024 .or. points < 1) goto100
    if (int(blocks, int64) /= (int(points, int64) + pitch - 1)/pitch) goto100
    if (.not. allocated(geometry%partition%nbsetlev)) goto100
    if (size(geometry%partition%nbsetlev) /= levels) goto100
    if (.not. valid_path(spectral_path) .or. .not. valid_path(surface_path) .or. .not. valid_path(upper_air_path)) goto100
    water_slots = [configuration%fields%aliases%yq, configuration%fields%aliases%yl, configuration%fields%aliases%yi]
    if (any(water_slots < 1) .or. any(water_slots > size(configuration%fields%components))) goto100
    if (budget%interpolation_bytes < 1 .or. budget%fields%spectral_map_bytes < 1) goto100
    if (budget%fields%gridpoint_bytes < 1 .or. budget%fields%spectral_bytes < 1) goto100
    n = configuration%initial%prefix%configuration_bytes
    if (n < 1 .or. n > 262144) goto100
    local = 0
100 status = agree(world, local); child_status = local
    if (status /= 0) return
    call MPI_Comm_size(world, world_size, error); call require_mpi(world, error)
    local = 2
    if (world_size == geometry%transform_control%nproc .and. world_size <= 32) local = 0
    status = agree(world, local); child_status = local
    if (status /= 0) return
    allocate (pending, stat=allocation_status)
    local = merge(1_int32, 0_int32, allocation_status /= 0)
    status = agree(world, local); child_status = local
    if (status /= 0) then
      if (allocated(pending)) deallocate (pending)
      return
    end if
    pending%model => configuration; pending%field_context => field_context; pending%world = world
    call move_alloc(work, pending%work)
    call move_alloc(pending, output)
    call clear_surface_physics_descriptions(output%surface_descriptions)

    failed_stage = 1; output%phase = 1
    platform = [configuration%initial%controls%namespace%nconf, configuration%initial%controls%namespace%lecmwf, &
                configuration%initial%controls%namespace%lr2d, configuration%initial%controls%namespace%lr3d, &
                configuration%initial%controls%namespace%lelam]
    local = initialize_operational_lagrangian_controls(configuration%initial%prefix%configuration_text(1:n), platform, &
                          configuration%initial%controls%clock%integration%total_steps, levels, geometry%atmosphere%half_pressure, &
                          geometry%vertical%vah(1), geometry%vertical%configuration%lvertfe, geometry%configuration%values%rstret, &
                                       configuration%initial%constants%rd, configuration%dynamics, configuration%field_effects(2), &
                                                       output%lagrangian, output%reference)
    status = finish_stage(world, output, local, child_status)
    if (status /= 0) return
    failed_stage = 2; output%phase = 2
    local = initialize_operational_interpolation_policy(configuration%initial%prefix%configuration_text(1:n), &
                                                        output%interpolation_policy, output%admitted_parallel)
    status = finish_stage(world, output, local, child_status)
    if (status /= 0) return
    failed_stage = 3; output%phase = 3
    local = initialize_configured_operational_interpolation_halo(geometry, configuration, output%interpolation_policy, &
                                                                 budget%interpolation_bytes, 6_int32, detail)
    output%owns_halo = local == 0
    status = finish_stage(world, output, local, child_status)
    if (status /= 0) return
    failed_stage = 4; output%phase = 4
    local = advance_forecast_work_storage(output%work)
    status = finish_stage(world, output, local, child_status)
    if (status /= 0) return
    failed_stage = 5; output%phase = 5
    local = prepare_native_initial_field_storage(configuration, output%spectral, world, budget%fields, memory_policy, &
                                                 resource_prefix, child_status, detail)
    output%owns_motion_spectral = local == 0
    status = finish_stage(world, output, local, child_status)
    if (status /= 0) return
    ! The preparation child performs the source GMV and spectral stages5/6.
    output%phase = 6
    failed_stage = 7; output%phase = 7
    local=load_native_initial_spectral_fields(output%spectral,world,spectral_path,output%loaded_orography,budget%fields%spectral_map_bytes)
    status = finish_stage(world, output, local, child_status)
    if (status /= 0) return
    failed_stage = 8; output%phase = 8
    geopotential => empty_spectral
    if (output%spectral%ns2d > 0) geopotential => output%spectral%sp2d(:, 2)
    local = initialize_distributed_operational_orography(output%terrain, geometry%terrain, geopotential, &
                                      geometry%transform_resolution, geometry%laplacian, geometry%dimensions%nsmax, points, pitch, &
                                               geometry%partition%nspec2, output%spectral%nump, geometry%transform_control%mysetv, &
                                                 geometry%transform_control%nprtrv, .false., .false., configuration%dynamics%lnhdyn)
    if (local /= 0) call MPI_Abort(world, 85 + int(local), error)
    status = finish_stage(world, output, local, child_status)
    if (status /= 0) return
    failed_stage = 9; output%phase = 9
    local = admit_surface_input_stage(world, memory_policy, resource_prefix, pitch, blocks, geometry%partition%ngptotg)
    status = finish_stage(world, output, local, child_status)
    if (status /= 0) return
    call project_surface_controls(configuration, surface_controls)
    local = initialize_runtime_partitioned_operational_surface_state(surface_path, configuration%initial%constants, &
                                                             configuration%physics%ecmwf_physics, surface_controls, pitch, blocks, &
                                          geometry%partition%nglobalindex(:points), output%surface_reset, output%surface_metadata, &
                                                      output%surface_trajectory, output%surface_descriptions, output%surface_arrays)
    status = finish_stage(world, output, local, child_status)
    if (status /= 0) return
    failed_stage = 10; output%phase = 10
    local = prepare_native_initial_upper_air_storage(configuration, output%spectral, output%upper, world, &
                 output%constituents, output%thermal_constants, budget%fields, memory_policy, resource_prefix, child_status, detail)
    status = finish_stage(world, output, local, child_status)
    if (status /= 0) return
    ! Its source shape binding is the unchanged owner constructor stage11.
    output%phase = 11
    failed_stage = 12; output%phase = 12
    do visit = 1, world_size
      local = advance_native_initial_upper_air_input(configuration, output%spectral, output%upper, world, upper_air_path, &
                                                     budget%fields, memory_policy, resource_prefix)
      status = finish_stage(world, output, local, child_status)
      if (status /= 0) return
      if (output%upper%complete) exit
    end do
    local = 0
    if (.not. output%upper%complete) local = 2
    status = finish_stage(world, output, local, child_status)
    if (status /= 0) return
    failed_stage = 13; output%phase = 13
    local=initialize_runtime_spectral_virtual_temperature(geometry%transform_control,geometry%transform_resolution,geometry%partition%nbsetlev, &
                                                          int(points, int64), output%thermal_constants, output%constituents, &
                                                       [configuration%fields%components(configuration%fields%aliases%yq)%lsp /= 0, &
                                                        configuration%fields%components(configuration%fields%aliases%yl)%lsp /= 0, &
                                                       configuration%fields%components(configuration%fields%aliases%yi)%lsp /= 0], &
                                                          output%upper%fields%gfl, output%spectral%sp3d(:, :, 3))
    if (local /= 0) call MPI_Abort(world, 105 + int(local), error)
    status = finish_stage(world, output, local, child_status)
    if (status /= 0) return
    failed_stage = 14; output%phase = 14
    local = advance_forecast_work_storage(output%work)
    status = finish_stage(world, output, local, child_status)
    if (status /= 0) return
    local = bind_initial_field_storage_owners(field_context, geometry, output%upper%fields, output%surface_metadata, &
                                              output%surface_arrays, output%work%next)
    status = finish_stage(world, output, local, child_status)
    if (status /= 0) return
    output%phase = 120; output%ready = .true.; failed_stage = 0; child_status = 0
  end function

  subroutine project_surface_controls(model, controls)
    type(native_operational_model_configuration), intent(in) :: model
    type(surface_operational_controls), intent(out) :: controls
    controls%levels = model%surface_controls%nflevg
    controls%undefined_index = model%surface_controls%nundefld; controls%stop_step = model%surface_controls%nstop
    controls%wave_coupling = model%surface_controls%lwcou /= 0; controls%two_way_wave = model%surface_controls%lwcou2w /= 0
    controls%wave_heat_flux = model%surface_controls%lwcouhmf /= 0; controls%currents = model%surface_controls%lwcur /= 0
    controls%stokes_drift = model%surface_controls%lwstokes /= 0; controls%wave_flux = model%surface_controls%lwflux /= 0
    controls%aqua = model%surface_controls%laqua /= 0; controls%trajectory = model%surface_controls%lifstraj /= 0
    controls%ecmwf = model%surface_controls%lecmwf /= 0
  end subroutine

  integer(int32) function admit_surface_input_stage(world, policy, prefix, pitch, blocks, global_points) result(status)
    !! Reserve every concurrent local surface decoder and its complete source
    !! matrix, plus the553-plane137-level owner. Capacities are not measured
    !! peaks. The observer samples this actual process and every cgroup ancestor.
    type(MPI_Comm), intent(in) :: world
    type(native_input_memory_policy), intent(in) :: policy
    character(*), intent(in) :: prefix
    integer(int32), intent(in) :: pitch, blocks, global_points
    type(MPI_Comm) :: node
    type(native_input_memory_sample) :: sample
    integer(int64) :: local_bytes, node_bytes, private_bytes, node_private
    integer(int32) :: local
    integer :: error, rank, io
    character(4096) :: path
    call MPI_Comm_rank(world, rank, error); call require_mpi(world, error)
    call MPI_Comm_split_type(world, MPI_COMM_TYPE_SHARED, rank, MPI_INFO_NULL, node, error); call require_mpi(world, error)
    local_bytes = 8_int64*pitch*blocks*553_int64
    private_bytes = 8_int64*global_points*156_int64 + 72_int64*81_int64 + policy%codec_reserve_bytes
    call MPI_Allreduce(local_bytes, node_bytes, 1, MPI_INTEGER8, MPI_SUM, node, error); call require_mpi(world, error)
    call MPI_Allreduce(private_bytes, node_private, 1, MPI_INTEGER8, MPI_SUM, node, error); call require_mpi(world, error)
    call MPI_Comm_free(node, error); call require_mpi(world, error)
    local = observe_native_input_memory(policy, sample)
    if (local == 0) then
      write (path, '(a,a,i0,a)', iostat=io) trim(prefix), '/surface_input_rank', rank, '.json'
      if (io /= 0) then
        local = 2
      else
        local = record_native_input_memory_sample(trim(path), sample)
      end if
    end if
    if (local == 0) local = admit_native_input_payload(sample, node_bytes, node_private)
    status = agree(world, local)
  end function

  integer(int32) function finish_stage(world, state, local, child_status) result(status)
    type(MPI_Comm), intent(in) :: world
    type(native_runtime_operational_input_state), intent(inout) :: state
    integer(int32), intent(in) :: local
    integer(int32), intent(out) :: child_status
    state%last_status = local; child_status = local
    status = agree(world, local)
  end function

  integer(int32) function release_runtime_operational_input_state(state) result(status)
    !! All ranks release the successful phase120 lease together. A partial
    !! initialization follows the source fatal path and cannot use this entry.
    !! Weather containers, registry and later physics borrowers expire first.
    !! WORLD remains borrowed and live until this collective release finishes.
    type(native_runtime_operational_input_state), allocatable, target, intent(inout) :: state
    type(ieee_status_type) :: reached
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer(int32) :: ignored, local
    status = 0
    if (.not. allocated(state)) return
    local = 2
    if (state%phase == 120 .and. state%ready) then
      if (associated(state%model) .and. associated(state%field_context)) then
        if (field_views_detached(state%field_context)) local = 0
      end if
    end if
    status = agree(state%world, local)
    if (status /= 0) return
    call ieee_get_status(reached); call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    nullify (state%field_context%grid_fields, state%field_context%surface_metadata, state%field_context%surface_arrays)
    nullify(state%field_context%next_time,state%field_context%geometry,state%field_context%motion,state%field_context%grid_configuration)
    call release_initialized_orography(state%terrain)
    if (state%owns_halo) then
      local = release_distributed_interpolation_buffer(state%model%interpolation)
      status = agree(state%world, local)
      if (status /= 0) goto900
      state%owns_halo = .false.
    end if
    if (allocated(state%work)) then
      local = release_forecast_work_storage(state%work)
      status = agree(state%world, local)
      if (status /= 0) goto900
    end if
    if (state%owns_motion_spectral) then
      local = release_grid_motion_fields(state%model%motion)
      status = agree(state%world, local)
      if (status /= 0) goto900
      state%owns_motion_spectral = .false.
    end if
    local = release_partitioned_operational_surface_state(state%surface_metadata, state%surface_arrays)
    status = agree(state%world, local)
    if (status /= 0) goto900
    local = release_distributed_spectral_field(state%spectral)
    status = agree(state%world, local)
    if (status /= 0) goto900
    local = release_partitioned_upper_air_input_owner(state%upper)
    status = agree(state%world, local)
    if (status /= 0) goto900
    state%ready = .false.
    deallocate (state); status = 0
900 call ieee_set_status(reached); error_number = saved_errno
  end function

  logical function field_views_detached(fields) result(detached)
    type(native_initial_fields_state), intent(in) :: fields
    detached = .false.
    if (associated(fields%field)) return
    if (.not. attached_field_container_is_empty(fields%field_t0)) return
    if (.not. attached_field_container_is_empty(fields%field_t1)) return
    if (.not. attached_field_container_is_empty(fields%field_t9)) return
    if (.not. attached_field_container_is_empty(fields%field_pc)) return
    if (.not. attached_field_container_is_empty(fields%field_pt)) return
    if (associated(fields%registry%variables) .or. associated(fields%registry%surface)) return
    if (allocated(fields%ecphysics%rustrti) .or. allocated(fields%ecphysics%rvstrti)) return
    if (allocated(fields%ecphysics%rahfsti) .or. allocated(fields%ecphysics%revapti)) return
    if (allocated(fields%ecphysics%rtskti) .or. allocated(fields%ecphysics%phys_mwave)) return
    detached = .true.
  end function

  integer(int32) function agree(world, local) result(status)
    type(MPI_Comm), intent(in) :: world
    integer(int32), intent(in) :: local
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer :: error
    call ieee_get_status(saved); call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    call MPI_Allreduce(local, status, 1, MPI_INTEGER4, MPI_MAX, world, error)
    call ieee_set_status(saved); error_number = saved_errno
    call require_mpi(world, error)
  end function

  subroutine require_mpi(world, error)
    type(MPI_Comm), intent(in) :: world
    integer, intent(in) :: error
    integer :: ignored
    if (error /= MPI_SUCCESS) call MPI_Abort(world, 3, ignored)
  end subroutine

  pure logical function valid_path(path)
    character(*), intent(in) :: path
    valid_path = .false.
    if (len(path) < 1 .or. len(path) > 4095) return
    if (index(path, achar(0)) /= 0) return
    valid_path = .true.
  end function
end module forecast_runtime_operational_input
