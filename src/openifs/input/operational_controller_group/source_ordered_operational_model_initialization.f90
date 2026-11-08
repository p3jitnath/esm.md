!> Preserve the default and configured operational input schedules.
!! The common body owns each numerical call. Its two public caller routes
!! select their actual halo policy before communication maps are built.
module forecast_source_ordered_operational_input
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_int, c_ptr, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use mpi_f08
  use forecast_initial_geometry_state, only: native_initial_geometry_state
  use forecast_runtime_operational_input, only: native_runtime_operational_input_state
  use forecast_loaded_operational_model, only: native_loaded_operational_model_state, native_loaded_operational_input_budget, &
               create_operational_input_model_storage, release_operational_input_model_contents, create_operational_input_payload, &
                      initialize_operational_input_lagrangian, prepare_operational_input_work, prepare_operational_input_spectral, &
                initialize_operational_input_surface, initialize_operational_input_upper_air, prepare_operational_input_next_time, &
                                               agree_input_controller_status, operational_input_borrowers_are_detached
  use forecast_initial_spectral_norm_join, only: native_initial_spectral_norm_state, prepare_initial_input_spectral_norms, &
                                                 compute_initial_input_spectral_norms, release_initial_input_spectral_norms
  use forecast_native_input_memory, only: native_input_memory_policy
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_parallel_interpolation_controls, only: initialize_operational_interpolation_policy
  use forecast_owned_interpolation_halo, only: initialize_configured_operational_interpolation_halo, &
                                               initialize_owned_distributed_interpolation_halo
  use forecast_spherical_interpolation_halo, only: initialize_native_selected_spherical_halo_controls, &
                                                   initialize_native_spherical_interpolation_halo
  use forecast_interpolation_buffer_setup, only: release_distributed_interpolation_buffer
  use forecast_orography_initialization, only: initialize_distributed_operational_orography, release_initialized_orography
  use initial_spectral_virtual_temperature_port, only: initialize_runtime_spectral_virtual_temperature
  implicit none
  private
  public :: native_initialized_operational_model_state, native_initialized_operational_input_budget
  public :: create_initialized_operational_model, release_initialized_operational_model
  public :: complete_operational_model_initialization, release_operational_model_initialization_contents
  type native_initialized_operational_input_budget
    !! Result and private-work capacities are bytes per rank.
    type(native_loaded_operational_input_budget) :: loaded
    integer(int64) :: norm_result_bytes = 0, norm_work_bytes = 0
  end type
  type native_initialized_operational_model_state
    !! One inline MODEL owner retains every alias at its original address.
    type(native_loaded_operational_model_state) :: model
    type(native_initial_spectral_norm_state) :: norms
    logical :: ready = .false.
  end type
  interface
    function initialized_input_errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains

  !> Initialize the original four-process route with default on-demand halo.
  !! INITIAL owns the canonical headers,clock,geometry and partition. OUTPUT
  !! owns the native model,field storage,input arrays and canonical norm words.
  !! All paths are separate character strings. Numerical arrays retain the
  !! units,shape and ordering declared by their concrete child providers.
  integer(int32) function create_initialized_operational_model(initial, world, spectral_path, surface_path, upper_air_path, &
                                          budget, memory_policy, resource_prefix, output, child_status, failed_stage) result(status)
    type(native_initial_geometry_state), target, intent(inout) :: initial
    type(MPI_Comm), intent(in) :: world
    character(*), intent(in) :: spectral_path, surface_path, upper_air_path, resource_prefix
    type(native_initialized_operational_input_budget), intent(in) :: budget
    type(native_input_memory_policy), intent(in) :: memory_policy
    type(native_initialized_operational_model_state), allocatable, target, intent(inout) :: output
    integer(int32), intent(out) :: child_status, failed_stage
    type(native_initialized_operational_model_state), allocatable, target :: pending
    integer(int32) :: local, ignored
    integer :: allocation_status, error, world_size
    failed_stage = 0; child_status = 2; local = 2
    if (allocated(output)) goto100
    if (.not. initial%ready .or. .not. allocated(initial%geometry)) goto100
    if (.not. initial%geometry%initialized .or. initial%geometry%partition%phase /= 7) goto100
    if (initial%geometry%dimensions%nflevg /= 137 .or. initial%geometry%dimensions%nsmax /= 1279) goto100
    if (.not. valid_path(spectral_path) .or. .not. valid_path(surface_path) .or. .not. valid_path(upper_air_path)) goto100
    local = 0
100 status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    call MPI_Comm_size(world, world_size, error); call require_mpi(world, error)
    local = 2
    if (world_size == 4 .and. initial%geometry%transform_control%nproc == 4) local = 0
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    allocate (pending, stat=allocation_status)
    local = merge(1_int32, 0_int32, allocation_status /= 0)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) then
      if (allocated(pending)) deallocate (pending)
      return
    end if
    ! The source norm-result calloc precedes the MODEL factory at10.
    status = prepare_initial_input_spectral_norms(world, initial%geometry%dimensions%nflevg, &
                                                  initial%geometry%dimensions%nsmax, budget%norm_result_bytes, pending%norms)
    child_status = status
    if (status /= 0) goto900
    status = create_operational_input_model_storage(initial, world, pending%model, child_status, failed_stage)
    if (status /= 0) then
      status = status + failed_stage
      goto900
    end if
    status = complete_operational_model_initialization(pending%model, pending%norms, world, &
               spectral_path, surface_path, upper_air_path, budget%loaded, budget%norm_work_bytes, memory_policy, resource_prefix, &
                                                       .false., child_status, failed_stage)
    if (status /= 0) goto900
    pending%ready = .true.; failed_stage = 0; child_status = 0
    call move_alloc(pending, output)
    return
900 ignored = release_initialized_operational_model(pending)
  end function

  !> Complete source stages25:120 after the actual final-address factory.
  !! NORMS already owns positive-zero values allocated before factory stage10.
  !! CONFIGURED_POLICY true applies the actual first NAMPAR1 group and admits
  !! the runtime process domain1:32. False preserves the original world4
  !! default on-demand policy. No original or caller-supplied numerical stage
  !! completes this graph. A returned failure keeps reached owners for release.
  !! Status adds the entered source stage to the agreed nonzero child result;
  !! CHILD_STATUS keeps the raw child result and FAILED_STAGE names its stage.
  integer(int32)function complete_operational_model_initialization(state,norms,world,spectral_path,surface_path,upper_air_path, &
              budget, norm_byte_limit, memory_policy, resource_prefix, configured_policy, child_status, failed_stage) result(status)
  type(native_loaded_operational_model_state), target, intent(inout) :: state
  type(native_initial_spectral_norm_state), target, intent(inout) :: norms
  type(MPI_Comm), intent(in) :: world
  character(*), intent(in) :: spectral_path, surface_path, upper_air_path, resource_prefix
  type(native_loaded_operational_input_budget), intent(in) :: budget
  integer(int64), intent(in) :: norm_byte_limit
  type(native_input_memory_policy), intent(in) :: memory_policy
  logical, intent(in) :: configured_policy
  integer(int32), intent(out) :: child_status, failed_stage
  type(native_geometry_state), pointer :: geometry
  integer(int32) :: local, detail, n
  integer :: error, world_size
  failed_stage = 0; child_status = 2; local = 2
  if (.not. allocated(state%storage) .or. .not. associated(state%fields)) goto100
  if (.not. state%storage%model%ready .or. state%ready) goto100
  if (.not. allocated(norms%values) .or. norms%ready) goto100
  if (.not. associated(state%storage%model%initial)) goto100
  if (.not. allocated(state%storage%model%initial%geometry)) goto100
  geometry => state%storage%model%initial%geometry
  if (.not. geometry%initialized .or. geometry%partition%phase /= 7) goto100
  if (budget%input%interpolation_bytes < 1 .or. norm_byte_limit < 1) goto100
  local = 0
100 status = agree_input_controller_status(world, local); child_status = local
  if (status /= 0) return
  call MPI_Comm_size(world, world_size, error); call require_mpi(world, error)
  local = 2
  if (configured_policy) then
    if (world_size >= 1 .and. world_size <= 32) local = 0
  else
    if (world_size == 4) local = 0
  end if
  status = agree_input_controller_status(world, local); child_status = local
  if (status /= 0) return
    local=create_operational_input_payload(state%storage%model,state%fields,world,spectral_path,surface_path,upper_air_path,budget,state%input)
  status = agree_input_controller_status(world, local); child_status = local
  if (status /= 0) return

  failed_stage = 25; state%phase = 25
  local = initialize_operational_input_lagrangian(state%input)
  status = finish_stage(world, state, local, 25_int32, child_status)
  if (status /= 0) return
  failed_stage = 27; state%phase = 27
  if (configured_policy) then
    n = state%storage%model%initial%prefix%configuration_bytes
    local = initialize_operational_interpolation_policy(state%storage%model%initial%prefix%configuration_text(1:n), &
                                                        state%input%interpolation_policy, state%input%admitted_parallel)
    status = finish_stage(world, state, local, 27_int32, child_status)
    if (status /= 0) return
    local = initialize_configured_operational_interpolation_halo(geometry, state%storage%model, state%input%interpolation_policy, &
                                                                 budget%input%interpolation_bytes, 6_int32, detail)
  else
    local = initialize_default_operational_input_halo(state%input, budget%input%interpolation_bytes)
  end if
  state%input%owns_halo = local == 0
  status = finish_stage(world, state, local, 27_int32, child_status)
  if (status /= 0) return
  local = prepare_operational_input_work(state%input, state%dynamic, state%next, world, budget%work_bytes, failed_stage)
  state%phase = failed_stage; status = finish_stage(world, state, local, failed_stage, child_status)
  if (status /= 0) return
  local = prepare_operational_input_spectral(state%input, world, spectral_path, budget%input, memory_policy, &
                                             resource_prefix, failed_stage, child_status)
  state%phase = failed_stage; status = finish_stage(world, state, local, failed_stage, child_status)
  if (status /= 0) return
  failed_stage = 85; state%phase = 85
  local = initialize_input_orography(state%input, world)
  status = finish_stage(world, state, local, 85_int32, child_status)
  if (status /= 0) return
  failed_stage = 90; state%phase = 90
  local = initialize_operational_input_surface(state%input, world, surface_path, memory_policy, resource_prefix)
  status = finish_stage(world, state, local, 90_int32, child_status)
  if (status /= 0) return
  failed_stage = 100; state%phase = 100
    local=initialize_operational_input_upper_air(state%input,world,upper_air_path,budget%input,memory_policy,resource_prefix,child_status)
  status = finish_stage(world, state, local, 100_int32, child_status)
  if (status /= 0) return
  failed_stage = 105; state%phase = 105
  local = convert_input_virtual_temperature(state%input, world)
  status = finish_stage(world, state, local, 105_int32, child_status)
  if (status /= 0) return
  failed_stage = 110; state%phase = 110
  local = prepare_operational_input_next_time(state%input)
  status = finish_stage(world, state, local, 110_int32, child_status)
  if (status /= 0) return
  failed_stage = 120; state%phase = 120
  local = compute_initial_input_spectral_norms(state%storage%model, state%input%spectral, world, norm_byte_limit, norms)
  status = finish_stage(world, state, local, 120_int32, child_status)
  if (status /= 0) return
  state%ready = .true.; state%input%phase = 120
  ! INPUT%READY belongs to the distinct runtime factory/physics route.
  ! This caller publishes only its own complete initialization owner.
  child_status = 0; failed_stage = 0
  end function

  !> Produce the default policy through its real source constructor.
  !! Save and restore the five width fields if later map allocation fails.
  integer(int32) function initialize_default_operational_input_halo(state, byte_limit) result(status)
    type(native_runtime_operational_input_state), target, intent(inout) :: state
    integer(int64), intent(in) :: byte_limit
    type(native_geometry_state), pointer :: geometry
    integer(int32) :: lelam, saved_width, child
    real(real64) :: saved_vmax1, saved_vmax2
    character(2) :: saved_code
    logical :: on_demand, saved_on_demand
    geometry => state%model%initial%geometry
    lelam = state%model%initial%controls%namespace%lelam
    on_demand = .false.
    status = initialize_native_selected_spherical_halo_controls(state%model%initial%controls%namespace, lelam, on_demand)
    status = agree_input_controller_status(state%world, status)
    if (status /= 0) return
    saved_vmax1 = state%model%interpolation_controls%vmax1
    saved_vmax2 = state%model%interpolation_controls%vmax2
    saved_width = state%model%interpolation%nslwide
    saved_code = state%model%interpolation%cver
    saved_on_demand = state%model%interpolation%lslondem
    status = initialize_native_spherical_interpolation_halo(geometry, state%model%initial%controls, state%model%dynamics, &
                            state%model%interpolation_controls, state%model%initial%constants, on_demand, state%model%interpolation)
    status = agree_input_controller_status(state%world, status)
    if (status == 0) then
      status = initialize_owned_distributed_interpolation_halo(geometry, state%model, byte_limit, 6_int32, child)
      if (status == 0) return
    end if
    state%model%interpolation_controls%vmax1 = saved_vmax1
    state%model%interpolation_controls%vmax2 = saved_vmax2
    state%model%interpolation%nslwide = saved_width
    state%model%interpolation%cver = saved_code
    state%model%interpolation%lslondem = saved_on_demand
  end function

  !> Transform the live spectral orography at its original stage85.
  integer(int32) function initialize_input_orography(state, world) result(status)
    type(native_runtime_operational_input_state), target, intent(inout) :: state
    type(MPI_Comm), intent(in) :: world
    type(native_geometry_state), pointer :: geometry
    real(real64), target :: empty(0)
    real(real64), pointer, contiguous :: geopotential(:)
    integer :: error
    geometry => state%model%initial%geometry
    geopotential => empty
    if (state%spectral%ns2d > 0) geopotential => state%spectral%sp2d(:, 2)
    status = initialize_distributed_operational_orography(state%terrain, geometry%terrain, geopotential, &
                          geometry%transform_resolution, geometry%laplacian, geometry%dimensions%nsmax, geometry%partition%ngptot, &
                    geometry%dimensions%nproma, geometry%partition%nspec2, state%spectral%nump, geometry%transform_control%mysetv, &
                                                   geometry%transform_control%nprtrv, .false., .false., state%model%dynamics%lnhdyn)
    if (status /= 0) then
      call MPI_Abort(world, 85 + int(status), error)
      error stop 85
    end if
  end function

  !> Convert actual spectral temperature with the canonical global level map.
  integer(int32) function convert_input_virtual_temperature(state, world) result(status)
    type(native_runtime_operational_input_state), target, intent(inout) :: state
    type(MPI_Comm), intent(in) :: world
    type(native_geometry_state), pointer :: geometry
    integer(int32) :: slots(3)
    integer :: error
    geometry => state%model%initial%geometry
    slots = [state%model%fields%aliases%yq, state%model%fields%aliases%yl, state%model%fields%aliases%yi]
    status = 2
    if (all(slots >= 1) .and. all(slots <= size(state%model%fields%components))) then
      status = initialize_runtime_spectral_virtual_temperature(geometry%transform_control, geometry%transform_resolution, &
                  geometry%partition%nbsetlev, int(geometry%partition%ngptot, int64), state%thermal_constants, state%constituents, &
                              [state%model%fields%components(slots(1))%lsp /= 0, state%model%fields%components(slots(2))%lsp /= 0, &
                            state%model%fields%components(slots(3))%lsp /= 0], state%upper%fields%gfl, state%spectral%sp3d(:, :, 3))
    end if
    if (status /= 0) then
      call MPI_Abort(world, 105 + int(status), error)
      error stop 105
    end if
  end function

  integer(int32) function release_initialized_operational_model(output) result(status)
    type(native_initialized_operational_model_state), allocatable, target, intent(inout) :: output
    status = 0
    if (.not. allocated(output)) return
    status = release_operational_model_initialization_contents(output%model, output%norms)
    if (status /= 0) return
    deallocate (output)
  end function

  !> Preserve the exact source release order:norms,terrain,halo,MODEL/FIELDS.
  !! Weather containers and registry views must be detached before any release.
  integer(int32) function release_operational_model_initialization_contents(state, norms) result(status)
    type(native_loaded_operational_model_state), target, intent(inout) :: state
    type(native_initial_spectral_norm_state), intent(inout) :: norms
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer(int32) :: ignored
    status = 2
    if (associated(state%fields)) then
      if (.not. operational_input_borrowers_are_detached(state%fields)) return
    end if
    call ieee_get_status(saved); call c_f_pointer(initialized_input_errno_address(), error_number); saved_errno = error_number
    status = release_initial_input_spectral_norms(norms)
    if (status == 0 .and. allocated(state%input)) then
      call release_initialized_orography(state%input%terrain)
      if (state%input%owns_halo) then
        status = release_distributed_interpolation_buffer(state%storage%model%interpolation)
        if (status == 0) state%input%owns_halo = .false.
      end if
    end if
    if (status == 0) status = release_operational_input_model_contents(state)
    call ieee_set_status(saved); error_number = saved_errno
  end function

  integer(int32) function finish_stage(world, state, local, stage, child_status) result(status)
    type(MPI_Comm), intent(in) :: world
    type(native_loaded_operational_model_state), intent(inout) :: state
    integer(int32), intent(in) :: local, stage
    integer(int32), intent(out) :: child_status
    integer(int32) :: encoded
    state%last_status = local; child_status = local; encoded = local
    if (local /= 0) encoded = local + stage
    status = agree_input_controller_status(world, encoded)
  end function
  subroutine require_mpi(world, error)
    type(MPI_Comm), intent(in) :: world
    integer, intent(in) :: error
    integer :: ignored
    if (error /= MPI_SUCCESS) call MPI_Abort(world, 3, ignored)
  end subroutine
  pure logical function valid_path(path) result(valid)
    character(*), intent(in) :: path
    valid = .false.
    if (len(path) < 1 .or. len(path) > 4095) return
    if (index(path, achar(0)) /= 0) return
    valid = .true.
  end function
end module forecast_source_ordered_operational_input
