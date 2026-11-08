!> Own live operational files, constants and the complete vertical state.
module forecast_operational_startup_inputs
  use iso_c_binding, only: c_int, c_int64_t, c_ptr, c_size_t, c_loc, c_sizeof, c_f_pointer, c_null_char
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use physical_constant_setup_port, only: forecast_physical_constants, initialize_physical_constants
  use initial_model_file_headers_port, only: read_initial_model_headers, make_runtime_grid_from_initial_headers
  use forecast_initial_vertical_state, only: native_initial_vertical_state, release_initial_vertical_state
  use vertical_configuration_port, only: native_vertical_configuration, initialize_operational_vertical_configuration
  use forecast_vertical_coordinate_storage, only: create_vertical_startup_state
  use forecast_owned_vertical_system, only: initialize_owned_vertical_system
  implicit none
  private
  public :: native_operational_startup_inputs, create_operational_startup_inputs, release_operational_startup_inputs
  integer(c_int), parameter :: maximum_configuration_bytes = 262144
  !> One stable owner for all values borrowed by later model construction.
  !! PREFIX owns exact configuration bytes, headers, grid metadata and vertical
  !! arrays. CONSTANTS uses SI units. The owner has no horizontal transform,
  !! field payload, message-passing lifetime or forecast calculation.
  type :: native_operational_startup_inputs
    type(forecast_physical_constants) :: constants
    type(native_initial_vertical_state), allocatable :: prefix
    logical :: ready = .false.
  end type
  interface
    function errno_address() bind(C, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
    function clear_native_record(address, value, bytes) bind(C, name='memset') result(result_address)
      import c_ptr, c_int, c_size_t
      type(c_ptr), value :: address
      integer(c_int), value :: value
      integer(c_size_t), value :: bytes
      type(c_ptr) :: result_address
    end function
  end interface
contains
  !> Create the source operational input owner without an original model object.
  !! SPECTRAL_PATH, GRID_PATH and CONFIGURATION_PATH contain 1..4095 characters,
  !! with no NUL. The configuration contains 1..262144 exact bytes.
  !! OUTPUT is an unallocated TARGET owner and changes only after complete
  !! success. The caller retains it until all borrowing consumers are released.
  !! The operational branch has 137 hydrostatic ECMWF levels. Header A has
  !! units Pa; header B is dimensionless. The source numerical children own
  !! their ordered FP64 calculations and intermediate rounding.
  !! Status 0 succeeds, 1 reports allocation failure, 2 refuses entry and 3
  !! reports configuration I/O or length failure. Header/constants, vertical
  !! parsing, constructor and calculation failures add 10,20,30,40 respectively
  !! to CHILD_STATUS. FAILED_STAGE identifies the last entered source phase.
  integer(c_int) function create_operational_startup_inputs(spectral_path, grid_path, configuration_path, &
                                                            output, child_status, failed_stage) result(status)
    character(*), intent(in) :: spectral_path, grid_path, configuration_path
    type(native_operational_startup_inputs), allocatable, target, intent(inout) :: output
    integer(c_int), intent(out) :: child_status, failed_stage
    type(native_operational_startup_inputs), allocatable, target :: pending
    type(native_vertical_configuration), target :: configuration
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: incoming_errno, ignored, geometry(4)
    integer(c_int64_t) :: file_bytes
    integer :: allocation_status, unit, io, close_status
    logical :: opened
    type(c_ptr) :: ignored_address
    type(ieee_status_type) :: reached
    status = 2; child_status = 0; failed_stage = 0
    if (allocated(output)) return
    if (.not. valid_path(spectral_path) .or. .not. valid_path(grid_path)) return
    if (.not. valid_path(configuration_path)) return
    call c_f_pointer(errno_address(), error_number)
    incoming_errno = error_number
    opened = .false.
    failed_stage = 1
    allocate (pending, stat=allocation_status)
    child_status = allocation_status
    status = 1
    if (allocation_status /= 0) goto900
    allocate (pending%prefix, stat=allocation_status)
    child_status = allocation_status
    if (allocation_status /= 0) goto900
    pending%prefix%configuration_text = ' '
    failed_stage = 2
    status = 3
    open (newunit=unit, file=configuration_path, status='old', action='read', &
          access='stream', form='unformatted', iostat=io)
    child_status = io
    if (io /= 0) goto900
    opened = .true.
    inquire (unit=unit, size=file_bytes, iostat=io)
    child_status = io
    if (io /= 0) goto900
    child_status = 0
    if (file_bytes < 1_c_int64_t .or. file_bytes > maximum_configuration_bytes) goto900
    read (unit, iostat=io) pending%prefix%configuration_text(1:int(file_bytes))
    child_status = io
    if (io /= 0) goto900
    close (unit, iostat=io)
    opened = .false.
    child_status = io
    if (io /= 0) goto900
    if (index(pending%prefix%configuration_text(1:int(file_bytes)), c_null_char) /= 0) goto900
    pending%prefix%configuration_bytes = int(file_bytes, c_int)
    failed_stage = 3
    child_status = read_initial_model_headers(spectral_path, grid_path, pending%prefix%headers)
    status = child_status + 10
    if (child_status /= 0) goto900
    child_status = make_runtime_grid_from_initial_headers(pending%prefix%headers, pending%prefix%grid)
    status = child_status + 10
    if (child_status /= 0) goto900
    failed_stage = 4
    ignored_address = clear_native_record(c_loc(pending%constants), 0_c_int, c_sizeof(pending%constants))
    child_status = initialize_physical_constants(pending%constants)
    status = child_status + 10
    if (child_status /= 0) goto900
    failed_stage = 5
    geometry = [pending%prefix%grid%levels, 1_c_int, 0_c_int, 0_c_int]
    ignored_address = clear_native_record(c_loc(configuration), 0_c_int, c_sizeof(configuration))
    child_status = initialize_operational_vertical_configuration( &
                   pending%prefix%configuration_text(1:pending%prefix%configuration_bytes), geometry, configuration)
    status = child_status + 20
    if (child_status /= 0) goto900
    failed_stage = 6
    child_status = create_vertical_startup_state(pending%prefix%vertical, &
                                                pending%prefix%configuration_text(1:pending%prefix%configuration_bytes), geometry, &
                                                 pending%prefix%headers%a, pending%prefix%headers%b)
    status = child_status + 30
    if (child_status /= 0) goto900
    failed_stage = 7
    child_status = initialize_owned_vertical_system(pending%prefix%vertical, &
                                                    pending%prefix%vertical%vp00, pending%constants%rpi)
    status = child_status + 40
    if (child_status /= 0) goto900
    pending%prefix%ready = .true.
    pending%ready = .true.
    call move_alloc(pending, output)
    child_status = 0; failed_stage = 0; status = 0
900 continue
    call ieee_get_status(reached)
    if (opened) close (unit, iostat=close_status)
    if (allocated(pending)) ignored = release_operational_startup_inputs(pending)
    call ieee_set_status(reached)
    error_number = incoming_errno
  end function

  !> Release vertical arrays and configuration before the outer constants owner.
  !! STATE must have no remaining borrowers. Null and repeated release succeed.
  !! Floating controls, exception flags and the incoming C error value remain.
  integer(c_int) function release_operational_startup_inputs(state) result(status)
    type(native_operational_startup_inputs), allocatable, target, intent(inout) :: state
    type(ieee_status_type) :: incoming
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: incoming_errno, ignored
    status = 0
    if (.not. allocated(state)) return
    call ieee_get_status(incoming)
    call c_f_pointer(errno_address(), error_number)
    incoming_errno = error_number
    if (allocated(state%prefix)) ignored = release_initial_vertical_state(state%prefix)
    state%ready = .false.
    deallocate (state)
    call ieee_set_status(incoming)
    error_number = incoming_errno
  end function

  pure logical function valid_path(path) result(valid)
    character(*), intent(in) :: path
    valid = .false.
    if (len(path) < 1 .or. len(path) > 4095) return
    if (index(path, c_null_char) /= 0) return
    valid = .true.
  end function
end module forecast_operational_startup_inputs
