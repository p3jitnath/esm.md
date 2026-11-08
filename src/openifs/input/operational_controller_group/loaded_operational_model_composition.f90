!> Compose the loaded operational model with stable native owners.
!! Concrete children own the storage,configuration and input calculations.
module forecast_loaded_operational_model
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_int, c_ptr, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use mpi_f08
  use forecast_runtime_operational_input, only: native_runtime_operational_input_state, native_operational_input_budget
  use forecast_initial_geometry_state, only: native_initial_geometry_state
 use forecast_selected_model_storage,only:native_selected_model_storage,create_selected_model_storage,release_selected_model_storage
  use forecast_in_place_model_configuration, only: initialize_operational_model_configuration_in_place
  use forecast_operational_model_configuration, only: associate_operational_model_partition
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_initial_fields_storage, only: native_initial_fields_state, bind_initial_field_storage_owners, &
                                             create_initial_fields_storage, release_initial_fields_storage
  use forecast_attached_field_container, only: attached_field_container_is_empty
  use forecast_native_dynamic_storage, only: native_forecast_dynamic_storage
  use forecast_next_time_field_storage, only: native_next_time_gridpoint_state
  use forecast_staged_work_storage,only:create_distributed_forecast_work_storage,advance_forecast_work_storage,release_forecast_work_storage
  use forecast_operational_lagrangian_controls, only: initialize_operational_lagrangian_controls
  use forecast_native_initial_field_loading, only: prepare_native_initial_field_storage, load_native_initial_spectral_fields, &
                                                   prepare_native_initial_upper_air_storage, advance_native_initial_upper_air_input
  use forecast_native_input_memory, only: native_input_memory_policy, native_input_memory_sample, &
                                          observe_native_input_memory, record_native_input_memory_sample, admit_native_input_payload
  use surface_field_configuration_port, only: surface_operational_controls
  use partitioned_surface_state_startup_port, only: initialize_runtime_partitioned_operational_surface_state, &
                                                   release_partitioned_operational_surface_state, clear_surface_physics_descriptions
  use owned_distributed_spectral_field_storage_port, only: release_distributed_spectral_field
  use forecast_grid_motion_setup, only: release_grid_motion_fields
  use partitioned_upper_air_input_owner_port, only: release_partitioned_upper_air_input_owner
  implicit none
  private
  public :: native_loaded_operational_model_state, native_loaded_operational_input_budget
  public :: create_loaded_operational_model, release_loaded_operational_model
  public :: create_operational_input_model_storage, release_operational_input_model_contents
  public :: create_operational_input_payload, initialize_operational_input_lagrangian
  public :: prepare_operational_input_work, prepare_operational_input_spectral
  public :: initialize_operational_input_surface, initialize_operational_input_upper_air
  public :: prepare_operational_input_next_time, release_operational_input_payload
  public :: agree_input_controller_status, operational_input_borrowers_are_detached

  type native_loaded_operational_input_budget
    !! Capacities are bytes per rank; each child derives its actual live shape.
    type(native_operational_input_budget) :: input
    integer(int64) :: work_bytes = 0
  end type
  type native_loaded_operational_model_state
    !! STORAGE owns the one final-address model. FIELDS borrows its payloads.
    !! INPUT owns the numerical arrays and borrows this same MODEL/FIELDS.
    type(native_selected_model_storage), allocatable :: storage
    type(native_initial_fields_state), pointer :: fields => null()
    type(native_forecast_dynamic_storage) :: dynamic
    type(native_next_time_gridpoint_state) :: next
    !! READY describes the enclosing caller route. INPUT%READY remains false.
    type(native_runtime_operational_input_state), allocatable :: input
    integer(int32) :: phase = 0, last_status = 0
    logical :: ready = .false.
  end type
  interface
    function input_errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains

  !> Own the final-address model and fields,then perform the loaded source order.
  !! INITIAL borrows the same live headers,clock,geometry and partition throughout.
  !! Three paths are separate character strings. All budgets are byte capacities.
  !! OUTPUT is fresh allocatable TARGET storage; successful publication moves only
  !! its allocation descriptor,so every native alias retains its actual target.
  !! Status0 completes storage/input stages10:110,without a forecast claim.
  integer(int32) function create_loaded_operational_model(initial, world, spectral_path, surface_path, upper_air_path, &
                                          budget, memory_policy, resource_prefix, output, child_status, failed_stage) result(status)
    type(native_initial_geometry_state), target, intent(inout) :: initial
    type(MPI_Comm), intent(in) :: world
    character(*), intent(in) :: spectral_path, surface_path, upper_air_path, resource_prefix
    type(native_loaded_operational_input_budget), intent(in) :: budget
    type(native_input_memory_policy), intent(in) :: memory_policy
    type(native_loaded_operational_model_state), allocatable, target, intent(inout) :: output
    integer(int32), intent(out) :: child_status, failed_stage
    type(native_loaded_operational_model_state), allocatable, target :: pending
    integer(int32) :: local, ignored, detail
    integer :: allocation_status
    child_status = 2; failed_stage = 0; local = 2
    if (allocated(output)) goto100
    if (.not. initial%ready .or. .not. allocated(initial%geometry)) goto100
    if (.not. initial%geometry%initialized .or. initial%geometry%partition%phase /= 7) goto100
    if(.not.valid_input_path(spectral_path).or..not.valid_input_path(surface_path).or..not.valid_input_path(upper_air_path))goto100
    local = 0
100 status = agree_input_controller_status(world, local)
    if (status /= 0) return
    allocate (pending, stat=allocation_status)
    local = merge(1_int32, 0_int32, allocation_status /= 0)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) then
      if (allocated(pending)) deallocate (pending)
      return
    end if
    status = create_operational_input_model_storage(initial, world, pending, child_status, failed_stage)
    if (status /= 0) goto900
    local = create_operational_input_payload(pending%storage%model, pending%fields, world, &
                                             spectral_path, surface_path, upper_air_path, budget, pending%input)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) goto900
    failed_stage = 25; pending%phase = 25
    local = initialize_operational_input_lagrangian(pending%input)
    status = complete_stage(world, pending, local, child_status)
    if (status /= 0) goto900
    local = prepare_operational_input_work(pending%input, pending%dynamic, pending%next, world, budget%work_bytes, failed_stage)
    pending%phase = failed_stage; status = complete_stage(world, pending, local, child_status)
    if (status /= 0) goto900
    local = prepare_operational_input_spectral(pending%input, world, spectral_path, budget%input, memory_policy, &
                                               resource_prefix, failed_stage, child_status)
    pending%phase = failed_stage; status = complete_stage(world, pending, local, child_status)
    if (status /= 0) goto900
    failed_stage = 90; pending%phase = 90
    local = initialize_operational_input_surface(pending%input, world, surface_path, memory_policy, resource_prefix)
    status = complete_stage(world, pending, local, child_status)
    if (status /= 0) goto900
    failed_stage = 100; pending%phase = 100
    local = initialize_operational_input_upper_air(pending%input, world, upper_air_path, budget%input, memory_policy, &
                                                   resource_prefix, child_status)
    status = complete_stage(world, pending, local, child_status)
    if (status /= 0) goto900
    failed_stage = 110; pending%phase = 110
    local = prepare_operational_input_next_time(pending%input)
    status = complete_stage(world, pending, local, child_status)
    if (status /= 0) goto900
    pending%ready = .true.; pending%input%phase = 110
    failed_stage = 0; child_status = 0
    call move_alloc(pending, output)
    return
900 if (status /= 0 .and. failed_stage > 0) status = status + failed_stage
    ignored = release_loaded_operational_model(pending)
  end function

  !> Create one MODEL with its aliases and one FIELDS record at source stage10.
  !! Configure that same MODEL in place at20. No constructor makes a copy.
  integer(int32) function create_operational_input_model_storage(initial, world, state, child_status, failed_stage) result(status)
    type(native_initial_geometry_state), target, intent(inout) :: initial
    type(MPI_Comm), intent(in) :: world
    type(native_loaded_operational_model_state), target, intent(inout) :: state
    integer(int32), intent(out) :: child_status, failed_stage
    integer(int32) :: local, detail
    failed_stage = 10; state%phase = 10
    local = create_selected_model_storage(state%storage, initial)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    local = create_initial_fields_storage(state%storage%model, state%fields)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 20; state%phase = 20
    local = initialize_operational_model_configuration_in_place(state%storage%model, initial, child_status, detail)
    status = agree_input_controller_status(world, local)
    if (status /= 0) return
    local = associate_operational_model_partition(state%storage%model, initial%geometry%partition)
    status = agree_input_controller_status(world, local); child_status = local
  end function

  !> Release this route before releasing its borrowed INITIAL owner.
  integer(int32) function release_loaded_operational_model(output) result(status)
    type(native_loaded_operational_model_state), allocatable, target, intent(inout) :: output
    status = 0
    if (.not. allocated(output)) return
    status = release_operational_input_model_contents(output)
    if (status /= 0) return
    deallocate (output)
  end function

  !> Close an inline owner after all weather borrowers have detached.
  integer(int32) function release_operational_input_model_contents(state) result(status)
    type(native_loaded_operational_model_state), target, intent(inout) :: state
    status = release_operational_input_payload(state%input)
    if (status /= 0) return
    status = release_initial_fields_storage(state%fields)
    if (status /= 0) return
    ! SUDIMF2 preserves the absent TDIMF GRIB arrays on this source route.
    status = release_selected_model_storage(state%storage)
    if (status == 0) state%ready = .false.
  end function

  !> Admit and create only a fresh numerical-payload owner.
  !! This does not create MODEL/FIELDS or claim their omitted factory stages.
  integer(int32) function create_operational_input_payload(model, fields, world, spectral_path, surface_path, upper_air_path, &
                                                           budget, output) result(status)
    type(native_operational_model_configuration), target, intent(inout) :: model
    type(native_initial_fields_state), target, intent(inout) :: fields
    type(MPI_Comm), intent(in) :: world
    character(*), intent(in) :: spectral_path, surface_path, upper_air_path
    type(native_loaded_operational_input_budget), intent(in) :: budget
    type(native_runtime_operational_input_state), allocatable, target, intent(inout) :: output
    type(native_geometry_state), pointer :: geometry
    integer(int32) :: local, p, l, q, b
    integer :: allocation_status, error, world_size
    local = 2; nullify (geometry)
    if (allocated(output)) goto100
    if (.not. model%ready .or. .not. associated(model%initial)) goto100
    if (.not. model%initial%ready .or. .not. allocated(model%initial%geometry)) goto100
    if (.not. allocated(model%initial%prefix)) goto100
    if (.not. model%initial%prefix%ready) goto100
    if (.not. associated(fields%state_model, model)) goto100
    if (.not. operational_input_borrowers_are_detached(fields)) goto100
    if (associated(fields%grid_fields) .or. associated(fields%surface_arrays)) goto100
    if (associated(fields%geometry) .or. associated(fields%motion) .or. associated(fields%grid_configuration)) goto100
    if (associated(fields%surface_metadata) .or. associated(fields%next_time) .or. associated(fields%runtime_physics)) goto100
    geometry => model%initial%geometry
    if (.not. geometry%initialized .or. geometry%partition%phase /= 7) goto100
    if (.not. associated(model%partition, geometry%partition)) goto100
    p = geometry%dimensions%nproma; l = geometry%dimensions%nflevg
    q = geometry%partition%ngptot; b = geometry%partition%ngpblks
    if (p < 1 .or. p > 1024 .or. l /= 137 .or. q < 1) goto100
    if (geometry%dimensions%nsmax /= 1279 .or. geometry%partition%ngptotg /= 6599680) goto100
    if (int(b, int64) /= (int(q, int64) + p - 1_int64)/p) goto100
    if (.not. allocated(geometry%partition%nglobalindex)) goto100
    if (size(geometry%partition%nglobalindex) < q) goto100
    if (.not. allocated(geometry%partition%nbsetlev)) goto100
    if (size(geometry%partition%nbsetlev) /= l) goto100
    if(.not.valid_input_path(spectral_path).or..not.valid_input_path(surface_path).or..not.valid_input_path(upper_air_path))goto100
    if (budget%work_bytes < 1 .or. budget%input%fields%spectral_map_bytes < 1) goto100
    if (budget%input%fields%gridpoint_bytes < 1 .or. budget%input%fields%spectral_bytes < 1) goto100
    local = 0
100 status = agree_input_controller_status(world, local)
    if (status /= 0) return
    call MPI_Comm_size(world, world_size, error); call require_input_mpi(world, error)
    local = 2
    if (world_size == geometry%transform_control%nproc .and. world_size <= 32) local = 0
    status = agree_input_controller_status(world, local)
    if (status /= 0) return
    allocate (output, stat=allocation_status)
    local = merge(1_int32, 0_int32, allocation_status /= 0)
    status = agree_input_controller_status(world, local)
    if (status /= 0) then
      if (allocated(output)) deallocate (output)
      return
    end if
    output%model => model; output%field_context => fields; output%world = world
    call clear_surface_physics_descriptions(output%surface_descriptions)
  end function

  !> Apply the source trajectory scalars before any saved-work allocation.
  integer(int32) function initialize_operational_input_lagrangian(state) result(status)
    type(native_runtime_operational_input_state), target, intent(inout) :: state
    type(native_geometry_state), pointer :: geometry
    integer(int32) :: platform(5), n
    status = 2
    if (.not. associated(state%model)) return
    if (.not. associated(state%model%initial)) return
    if (.not. allocated(state%model%initial%geometry) .or. .not. allocated(state%model%initial%prefix)) return
    geometry => state%model%initial%geometry
    n = state%model%initial%prefix%configuration_bytes
    if (n < 1 .or. n > 262144) return
    platform = [state%model%initial%controls%namespace%nconf, state%model%initial%controls%namespace%lecmwf, &
                state%model%initial%controls%namespace%lr2d, state%model%initial%controls%namespace%lr3d, &
                state%model%initial%controls%namespace%lelam]
    status = initialize_operational_lagrangian_controls(state%model%initial%prefix%configuration_text(1:n), platform, &
        state%model%initial%controls%clock%integration%total_steps, geometry%dimensions%nflevg, geometry%atmosphere%half_pressure, &
                          geometry%vertical%vah(1), geometry%vertical%configuration%lvertfe, geometry%configuration%values%rstret, &
            state%model%initial%constants%rd, state%model%dynamics, state%model%field_effects(2), state%lagrangian, state%reference)
    if (status == 0) state%phase = 25
    state%last_status = status
  end function

  !> Create RSAVEDP,then RSLWX,then SAVTEND,with source stage labels30/40/50.
  integer(int32) function prepare_operational_input_work(state, dynamic, next, world, byte_limit, failed_stage) result(status)
    type(native_runtime_operational_input_state), target, intent(inout) :: state
    type(native_forecast_dynamic_storage), target, intent(inout) :: dynamic
    type(native_next_time_gridpoint_state), target, intent(inout) :: next
    type(MPI_Comm), intent(in) :: world
    integer(int64), intent(in) :: byte_limit
    integer(int32), intent(out) :: failed_stage
    integer(int32) :: local
    failed_stage = 30
    local = create_distributed_forecast_work_storage(state%work, state%model, dynamic, next, byte_limit)
    status = agree_input_controller_status(world, local)
    if (status /= 0) return
    state%phase = 30; failed_stage = 40
    local = advance_forecast_work_storage(state%work)
    status = agree_input_controller_status(world, local)
    if (status /= 0) return
    state%phase = 40; failed_stage = 50
    local = advance_forecast_work_storage(state%work)
    status = agree_input_controller_status(world, local)
    if (status == 0) state%phase = 50
    state%last_status = local
  end function

  !> Allocate motion and spectral fields,then load the spectral file.
  integer(int32)function prepare_operational_input_spectral(state,world,path,budget,memory_policy,prefix,failed_stage,child_status)result(status)
  type(native_runtime_operational_input_state), target, intent(inout) :: state
  type(MPI_Comm), intent(in) :: world
  character(*), intent(in) :: path, prefix
  type(native_operational_input_budget), intent(in) :: budget
  type(native_input_memory_policy), intent(in) :: memory_policy
  integer(int32), intent(out) :: failed_stage, child_status
  integer(int32) :: detail
  failed_stage = 60
status=prepare_native_initial_field_storage(state%model,state%spectral,world,budget%fields,memory_policy,prefix,child_status,detail)
  state%owns_motion_spectral = status == 0
  if (status /= 0) then
    if (detail == 4) failed_stage = 70
    return
  end if
  state%phase = 70; failed_stage = 80
 status = load_native_initial_spectral_fields(state%spectral, world, path, state%loaded_orography, budget%fields%spectral_map_bytes)
  state%last_status = status; child_status = status
  if (status == 0) state%phase = 80
  end function

  !> Load the surface at its source position after admitting every live decoder.
  integer(int32) function initialize_operational_input_surface(state, world, path, policy, prefix) result(status)
    type(native_runtime_operational_input_state), target, intent(inout) :: state
    type(MPI_Comm), intent(in) :: world
    character(*), intent(in) :: path, prefix
    type(native_input_memory_policy), intent(in) :: policy
    type(native_geometry_state), pointer :: geometry
    type(surface_operational_controls) :: controls
    geometry => state%model%initial%geometry
    status = admit_surface_input(world, policy, prefix, geometry%dimensions%nproma, &
                                 geometry%partition%ngpblks, geometry%partition%ngptotg)
    if (status /= 0) return
    call project_surface_input_controls(state%model, controls)
    status = initialize_runtime_partitioned_operational_surface_state(path, state%model%initial%constants, &
                              state%model%physics%ecmwf_physics, controls, geometry%dimensions%nproma, geometry%partition%ngpblks, &
                         geometry%partition%nglobalindex(:geometry%partition%ngptot), state%surface_reset, state%surface_metadata, &
                                                         state%surface_trajectory, state%surface_descriptions, state%surface_arrays)
    state%last_status = status
    if (status == 0) state%phase = 90
  end function

  !> Allocate native GFL at the upper-air stage,then enter bounded decoder visits.
  integer(int32)function initialize_operational_input_upper_air(state,world,path,budget,memory_policy,prefix,child_status)result(status)
  type(native_runtime_operational_input_state), target, intent(inout) :: state
  type(MPI_Comm), intent(in) :: world
  character(*), intent(in) :: path, prefix
  type(native_operational_input_budget), intent(in) :: budget
  type(native_input_memory_policy), intent(in) :: memory_policy
  integer(int32), intent(out) :: child_status
  integer(int32) :: detail
  integer :: world_size, error, visit
  status = prepare_native_initial_upper_air_storage(state%model, state%spectral, state%upper, world, state%constituents, &
                                                state%thermal_constants, budget%fields, memory_policy, prefix, child_status, detail)
  if (status /= 0) return
  call MPI_Comm_size(world, world_size, error); call require_input_mpi(world, error)
  do visit = 1, world_size
 status=advance_native_initial_upper_air_input(state%model,state%spectral,state%upper,world,path,budget%fields,memory_policy,prefix)
    child_status = status
    if (status /= 0) return
    if (state%upper%complete) exit
  end do
  status = 0
  if (.not. state%upper%complete) status = 2
  state%last_status = status; child_status = status
  if (status == 0) state%phase = 100
end function

!> Allocate next-time fields,then attach their existing owners to FIELDS.
integer(int32) function prepare_operational_input_next_time(state) result(status)
  type(native_runtime_operational_input_state), target, intent(inout) :: state
  status = advance_forecast_work_storage(state%work)
  if (status /= 0) return
  status = bind_initial_field_storage_owners(state%field_context, state%model%initial%geometry, state%upper%fields, &
                                             state%surface_metadata, state%surface_arrays, state%work%next)
  state%last_status = status
  if (status == 0) state%phase = 110
end function

!> Release only this storage route's acquired payloads and borrowed views.
  !! Active weather containers and registry borrowers must finish first.
  !! The same cleanup handles an unpublished partial owner after a failure.
integer(int32) function release_operational_input_payload(state) result(status)
  type(native_runtime_operational_input_state), allocatable, target, intent(inout) :: state
  type(ieee_status_type) :: saved
  integer(c_int), pointer, volatile :: error_number
  integer(c_int) :: saved_errno
  integer(int32) :: ignored
  status = 0
  if (.not. allocated(state)) return
  status = 2
  if (.not. associated(state%model) .or. .not. associated(state%field_context)) return
  if (.not. operational_input_borrowers_are_detached(state%field_context)) return
  if (state%owns_halo) return
  if (allocated(state%terrain%orog) .or. allocated(state%terrain%orogl) .or. allocated(state%terrain%orogm)) return
  call ieee_get_status(saved); call c_f_pointer(input_errno_address(), error_number); saved_errno = error_number
  nullify (state%field_context%grid_fields, state%field_context%surface_metadata, state%field_context%surface_arrays)
    nullify(state%field_context%next_time,state%field_context%geometry,state%field_context%motion,state%field_context%grid_configuration)
  if (allocated(state%work)) ignored = release_forecast_work_storage(state%work)
  if (state%owns_motion_spectral) ignored = release_grid_motion_fields(state%model%motion)
  ignored = release_partitioned_operational_surface_state(state%surface_metadata, state%surface_arrays)
  ignored = release_distributed_spectral_field(state%spectral)
  ignored = release_partitioned_upper_air_input_owner(state%upper)
  state%ready = .false.; deallocate (state); status = 0
  call ieee_set_status(saved); error_number = saved_errno
end function

logical function operational_input_borrowers_are_detached(fields) result(detached)
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

subroutine project_surface_input_controls(model, controls)
  type(native_operational_model_configuration), intent(in) :: model
  type(surface_operational_controls), intent(out) :: controls
  controls%levels = model%surface_controls%nflevg; controls%undefined_index = model%surface_controls%nundefld
  controls%stop_step = model%surface_controls%nstop
  controls%wave_coupling = model%surface_controls%lwcou /= 0; controls%two_way_wave = model%surface_controls%lwcou2w /= 0
  controls%wave_heat_flux = model%surface_controls%lwcouhmf /= 0; controls%currents = model%surface_controls%lwcur /= 0
  controls%stokes_drift = model%surface_controls%lwstokes /= 0; controls%wave_flux = model%surface_controls%lwflux /= 0
  controls%aqua = model%surface_controls%laqua /= 0; controls%trajectory = model%surface_controls%lifstraj /= 0
  controls%ecmwf = model%surface_controls%lecmwf /= 0
end subroutine

integer(int32) function admit_surface_input(world, policy, prefix, pitch, blocks, global_points) result(status)
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
  call MPI_Comm_rank(world, rank, error); call require_input_mpi(world, error)
  call MPI_Comm_split_type(world, MPI_COMM_TYPE_SHARED, rank, MPI_INFO_NULL, node, error); call require_input_mpi(world, error)
  local_bytes = 8_int64*pitch*blocks*553_int64
  private_bytes = 8_int64*global_points*156_int64 + 72_int64*81_int64 + policy%codec_reserve_bytes
  call MPI_Allreduce(local_bytes, node_bytes, 1, MPI_INTEGER8, MPI_SUM, node, error); call require_input_mpi(world, error)
  call MPI_Allreduce(private_bytes, node_private, 1, MPI_INTEGER8, MPI_SUM, node, error); call require_input_mpi(world, error)
  call MPI_Comm_free(node, error); call require_input_mpi(world, error)
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
  status = agree_input_controller_status(world, local)
end function

integer(int32) function complete_stage(world, state, local, child_status) result(status)
  type(MPI_Comm), intent(in) :: world
  type(native_loaded_operational_model_state), intent(inout) :: state
  integer(int32), intent(in) :: local
  integer(int32), intent(out) :: child_status
  state%last_status = local; child_status = local
  status = agree_input_controller_status(world, local)
end function

!> Added metadata agreements preserve the incoming arithmetic flags and errno.
integer(int32) function agree_input_controller_status(world, local) result(status)
  type(MPI_Comm), intent(in) :: world
  integer(int32), intent(in) :: local
  type(ieee_status_type) :: saved
  integer(c_int), pointer, volatile :: error_number
  integer(c_int) :: saved_errno
  integer :: error
  call ieee_get_status(saved); call c_f_pointer(input_errno_address(), error_number); saved_errno = error_number
  call MPI_Allreduce(local, status, 1, MPI_INTEGER4, MPI_MAX, world, error)
  call ieee_set_status(saved); error_number = saved_errno
  call require_input_mpi(world, error)
end function
subroutine require_input_mpi(world, error)
  type(MPI_Comm), intent(in) :: world
  integer, intent(in) :: error
  integer :: ignored
  if (error /= MPI_SUCCESS) call MPI_Abort(world, 3, ignored)
end subroutine
pure logical function valid_input_path(path) result(valid)
  character(*), intent(in) :: path
  valid = .false.
  if (len(path) < 1 .or. len(path) > 4095) return
  if (index(path, achar(0)) /= 0) return
  valid = .true.
end function
end module forecast_loaded_operational_model
