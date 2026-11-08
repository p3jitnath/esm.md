!> Construct the historical T21/L19 one-process geometry from its real files.
module forecast_selected_bootstrap_geometry
  use iso_c_binding, only: c_int, c_int8_t, c_int64_t, c_loc, c_sizeof, c_ptr, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use forecast_initial_geometry_state, only: native_initial_geometry_state, release_initial_geometry_state
  use forecast_initial_vertical_state, only: initialize_initial_vertical_state
  use physical_constant_setup_port, only: initialize_physical_constants
  use forecast_controls_state_types, only: native_forecast_control_upstream
  use forecast_control_configuration, only: initialize_selected_forecast_controls
  use forecast_initialization_controls, only: initialize_selected_initialization_controls
  use forecast_serial_geometry_setup, only: complete_owned_geometry
  implicit none
  private
  public :: create_selected_bootstrap_geometry
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> OUTPUT is an absent allocatable TARGET and retains the canonical owner type.
 !! Paths name the original configuration, spectral file and surface file.
 !! NPRINTLEV is dimensionless and nonnegative. All arrays stay at their final
 !! allocated addresses until release_initial_geometry_state is called.
 !! Status0 publishes the complete geometry. A failed child leaves OUTPUT
 !! absent; CHILD_STATUS and FAILED_STAGE identify its natural return.
  integer(c_int) function create_selected_bootstrap_geometry(output, configuration_path, spectral_path, &
                                                             surface_path, nprintlev, child_status, failed_stage) result(status)
    type(native_initial_geometry_state), allocatable, target, intent(inout) :: output
    character(*), intent(in) :: configuration_path, spectral_path, surface_path
    integer(c_int), intent(in) :: nprintlev
    integer(c_int), intent(out) :: child_status, failed_stage
    type(native_initial_geometry_state), allocatable, target :: pending
    type(native_forecast_control_upstream) :: upstream
    type(ieee_status_type) :: reached
    integer(c_int), pointer, volatile :: error_number
    integer(c_int8_t), pointer :: bytes(:)
    integer(c_int) :: n, ignored, reached_errno, detail
    integer :: allocation_status
    status = 2; child_status = 2; failed_stage = 1
    if (allocated(output) .or. nprintlev < 0) return
    allocate (pending, stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; child_status = 1; return
    end if
    call c_f_pointer(c_loc(pending%constants), bytes, [int(c_sizeof(pending%constants))])
    bytes = 0_c_int8_t
    child_status = initialize_physical_constants(pending%constants)
    if (child_status /= 0) goto900
    failed_stage = 2
    child_status = initialize_initial_vertical_state(pending%prefix, configuration_path, &
                                                     spectral_path, surface_path, pending%constants, detail)
    if (child_status /= 0) goto900
    failed_stage = 3
    if (pending%prefix%headers%spectral%levels /= 19 .or. pending%prefix%headers%nusmax /= 21) goto910
    if (pending%prefix%headers%nudgl /= 32 .or. pending%prefix%headers%nudlon /= 64) goto910
    if (pending%prefix%headers%spectral%date /= 20041015) goto910
    n = pending%prefix%configuration_bytes
    call c_f_pointer(c_loc(pending%controls%clock_input), bytes, [int(c_sizeof(pending%controls%clock_input))])
    bytes = 0_c_int8_t
    call c_f_pointer(c_loc(pending%controls%clock), bytes, [int(c_sizeof(pending%controls%clock))])
    bytes = 0_c_int8_t
    upstream%date = pending%prefix%headers%spectral%date
    upstream%seconds = pending%prefix%headers%spectral%seconds
    upstream%nprintlev = nprintlev; upstream%ngribfile = pending%prefix%headers%ngribfile
    child_status = initialize_selected_forecast_controls(pending%prefix%configuration_text(1:n), upstream, pending%controls)
    if (child_status /= 0) goto900
    failed_stage = 4
    child_status = initialize_selected_initialization_controls(pending%prefix%configuration_text(1:n), &
                                                               pending%controls%namespace%nconf, pending%initialization)
    if (child_status /= 0) goto900
    failed_stage = 5
    child_status = complete_owned_geometry(pending%geometry, pending%prefix%vertical, pending%prefix%headers, &
                                           pending%constants, pending%prefix%configuration_text(1:n), detail)
    if (child_status /= 0) goto900
    pending%ready = .true.
    call move_alloc(pending, output)
    status = 0; child_status = 0; failed_stage = 0
    return
910 child_status = 2
900 status = child_status
    call ieee_get_status(reached)
    call c_f_pointer(errno_address(), error_number); reached_errno = error_number
    ignored = release_initial_geometry_state(pending)
    call ieee_set_status(reached); error_number = reached_errno
  end function
end module forecast_selected_bootstrap_geometry
