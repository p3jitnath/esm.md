!> Own the actual input prefix, controls and complete native geometry.
module forecast_initial_geometry_state
  use iso_c_binding, only: c_int, c_int8_t, c_int64_t, c_ptr, c_f_pointer, c_loc, c_sizeof
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use physical_constant_setup_port, only: forecast_physical_constants, initialize_physical_constants
  use forecast_initial_vertical_state, only: native_initial_vertical_state, &
                                             initialize_initial_vertical_state, release_initial_vertical_state
  use forecast_controls_state_types, only: native_forecast_controls_state, native_forecast_control_upstream
  use forecast_control_configuration, only: initialize_operational_forecast_controls
  use forecast_initialization_controls, only: native_initialization_controls, &
                                              initialize_operational_initialization_controls
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_geometry_setup, only: release_native_geometry
  use forecast_geometry_startup_messages, only: initialize_native_geometry_with_message_owner
  use forecast_public_transform, only: native_transform_control, native_transform_resolution, &
                                       initialize_public_transform_messages, finish_public_transform_context
  use forecast_distributed_partition_collectives, only: agree_distributed_partition_status
  implicit none
  private
  public :: native_initial_geometry_state, initialize_initial_geometry_state, release_initial_geometry_state
  !> Keep one stable owner for every producer needed by initial geometry.
  !! constants contains physical values in the accepted SI-based units.
  !! prefix owns exact configuration bytes, file headers and vertical arrays.
  !! controls owns the complete named namespace and both native clock records;
  !! initialization owns the accepted ten dimensionless zero/one switches.
  !! geometry borrows prefix%vertical once. The allocatable storage must remain
  !! at the same address while geometry or its block-array views are in use.
  type :: native_initial_geometry_state
    type(forecast_physical_constants) :: constants
    type(native_initial_vertical_state), allocatable :: prefix
    type(native_forecast_controls_state) :: controls
    type(native_initialization_controls) :: initialization
    type(native_geometry_state), allocatable :: geometry
    logical :: ready = .false.
  end type
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Initialize all bytes of a fresh, own C-interoperable record.
  !! address and count come from C_LOC and C_SIZEOF of that declared record.
  !! Records with allocatable owners are initialized through named members.
  subroutine zero_native_record(address, count)
    type(c_ptr), intent(in) :: address
    integer(c_int64_t), intent(in) :: count
    integer(c_int8_t), pointer :: bytes(:)
    call c_f_pointer(address, bytes, [int(count)])
    bytes = 0_c_int8_t
  end subroutine

  !> Open messages, agree each local producer, then transfer geometry ownership.
  !! output is unallocated and TARGET on every rank. Every rank enters together
  !! with no other active owned public message context. expected_world is the
  !! same on every rank and is 4 or 32; threads is 1. The current whole-geometry
  !! domain is the operational 137-layer, T1279, N1280 input. These supported
  !! bounds do not claim a current 32-rank original-reference comparison.
  !! Paths follow the accepted prefix contract: 1:4095 characters without NUL.
  !! nprintlev is a nonnegative source print control. Date, seconds and GRIB
  !! file count come from the accepted spectral and header metadata.
  !! Open public messages before allocation, file work or clock construction.
  !! Agree every local function return through the existing public MAX helper.
  !! A refusal releases only private storage and leaves output unallocated.
  !! After geometry consumes the sole message_ready token, geometry owns all
  !! public finalization. This outer entry performs only local cleanup afterward.
  !! Return and child_status are the same agreed raw child function result.
  !! failed_stage is 0 on success, otherwise 1 messages, 2 admission, 3 owner
  !! allocation, 4 constants, 5 file/vertical prefix, 6 forecast controls,
  !! 7 initialization switches, or 8 geometry. Optional child_detail records a
  !! rank-local nested prefix/geometry result before cleanup; it is not reduced.
  !! Optional geometry_stage is the agreed geometry stage, or 0 before geometry.
  !! Public provider failure before a live message context cannot be agreed.
  !! Callers establish nearest-even rounding and gradual underflow. Cleanup
  !! preserves the reached floating status and errno. No time step is run.
  integer(c_int) function initialize_initial_geometry_state(output, configuration_path, spectral_path, grid_path, &
                        expected_world, threads, nprintlev, child_status, failed_stage, child_detail, geometry_stage) result(status)
    type(native_initial_geometry_state), allocatable, target, intent(inout) :: output
    character(*), intent(in) :: configuration_path, spectral_path, grid_path
    integer(c_int), intent(in) :: expected_world, threads, nprintlev
    integer(c_int), intent(out) :: child_status, failed_stage
    integer(c_int), optional, intent(out) :: child_detail, geometry_stage
    type(native_initial_geometry_state), allocatable, target :: pending
    type(native_transform_control) :: early_control
    type(native_transform_resolution) :: no_resolution
    type(native_forecast_control_upstream) :: upstream
    type(ieee_status_type) :: reached
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: child, nested, geometry_child, stage, ignored, error, reached_errno, active_bytes
    integer :: allocation_status
    child_status = 2
    failed_stage = 2
    status = 2
    if (present(child_detail)) child_detail = 0
    if (present(geometry_stage)) geometry_stage = 0
    ! Fresh ownership and a uniform world are collective entry preconditions.
    if (allocated(output)) return
    if (expected_world /= 4 .and. expected_world /= 32) return
    stage = 1
    child = initialize_public_transform_messages(early_control, expected_world)
    child_status = child
    if (early_control%message_ready) &
      child_status = agree_distributed_partition_status(early_control, child)
    if (child_status /= 0) goto900
    stage = 2
    child = 0
    if (threads /= 1 .or. nprintlev < 0) child = 2
    child_status = agree_distributed_partition_status(early_control, child)
    if (child_status /= 0) goto900
    stage = 3
    allocate (pending, stat=allocation_status)
    child = 0
    if (allocation_status /= 0) child = 1
    child_status = agree_distributed_partition_status(early_control, child)
    if (child_status /= 0) goto900
    stage = 4
    call zero_native_record(c_loc(pending%constants), int(c_sizeof(pending%constants), c_int64_t))
    child = initialize_physical_constants(pending%constants)
    child_status = agree_distributed_partition_status(early_control, child)
    if (child_status /= 0) goto900
    stage = 5
    child = initialize_initial_vertical_state(pending%prefix, configuration_path, spectral_path, grid_path, &
                                              pending%constants, nested)
    if (present(child_detail)) child_detail = nested
    child_status = agree_distributed_partition_status(early_control, child)
    if (child_status /= 0) goto900
    active_bytes = pending%prefix%configuration_bytes
    stage = 6
    call zero_native_record(c_loc(pending%controls%clock_input), &
                            int(c_sizeof(pending%controls%clock_input), c_int64_t))
    call zero_native_record(c_loc(pending%controls%clock), int(c_sizeof(pending%controls%clock), c_int64_t))
    upstream%date = pending%prefix%headers%spectral%date
    upstream%seconds = pending%prefix%headers%spectral%seconds
    upstream%nprintlev = nprintlev
    upstream%ngribfile = pending%prefix%headers%ngribfile
    child = initialize_operational_forecast_controls(pending%prefix%configuration_text(1:active_bytes), &
                                                     upstream, pending%controls)
    child_status = agree_distributed_partition_status(early_control, child)
    if (child_status /= 0) goto900
    stage = 7
    child = initialize_operational_initialization_controls(pending%prefix%configuration_text(1:active_bytes), &
                                                           pending%controls%namespace%nconf, pending%initialization)
    child_status = agree_distributed_partition_status(early_control, child)
    if (child_status /= 0) goto900
    stage = 8
    child = initialize_native_geometry_with_message_owner(pending%geometry, pending%prefix%vertical, &
                                                          pending%prefix%headers, pending%prefix%grid, pending%constants, &
                                       pending%prefix%configuration_text(1:active_bytes), expected_world, threads, geometry_child, &
                                                          nested, early_control)
    ! A consumed failure may already have finalized messages. Do not reduce here.
    child_status = child
    if (present(child_detail)) child_detail = geometry_child
    if (present(geometry_stage)) geometry_stage = nested
    if (child_status /= 0) goto900
    pending%ready = .true.
    call move_alloc(pending, output)
    status = 0
    child_status = 0
    failed_stage = 0
    if (present(child_detail)) child_detail = 0
    return
900 continue
    status = child_status
    failed_stage = stage
    call ieee_get_status(reached)
    call c_f_pointer(errno_address(), error_number)
    reached_errno = error_number
    ignored = release_initial_geometry_state(pending)
    if (early_control%message_ready) &
      ignored = finish_public_transform_context(early_control, no_resolution, error)
    call ieee_set_status(reached)
    error_number = reached_errno
  end function

  !> Release geometry before its borrowed vertical producer and outer storage.
  !! state is an allocatable native owner. Geometry closes the public transform
  !! and message lifetime once. The prefix then releases only its local arrays.
  !! No other public context or protected module namespace is changed.
  !! Repeated release returns 0 and preserves incoming floating status and errno.
  integer(c_int) function release_initial_geometry_state(state) result(status)
    type(native_initial_geometry_state), allocatable, intent(inout) :: state
    type(ieee_status_type) :: incoming
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: ignored, saved_errno
    status = 0
    if (.not. allocated(state)) return
    call ieee_get_status(incoming)
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    ignored = release_native_geometry(state%geometry)
    ignored = release_initial_vertical_state(state%prefix)
    state%ready = .false.
    deallocate (state)
    call ieee_set_status(incoming)
    error_number = saved_errno
  end function
end module forecast_initial_geometry_state
