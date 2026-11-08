!> File boundary for the original SUDIM_TRAJ setup route, with native owners.
module forecast_trajectory_dimension_file
  use, intrinsic :: iso_c_binding, only: c_int, c_char, c_ptr, c_loc, c_f_pointer, c_size_t, c_intptr_t, c_null_char
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use forecast_trajectory_dimensions
  use forecast_setup_empty_groups, only: require_empty_trajectory_dimension_bytes
  implicit none
  private
  public :: initialize_trajectory_dimensions_from_file
  integer, parameter :: text_capacity = 262145, path_capacity = 4096
  interface
    function native_open(path, flags, mode) bind(c, name='open') result(fd)
      import :: c_char, c_int
      character(kind=c_char), intent(in) :: path(*)
      integer(c_int), value :: flags, mode
      integer(c_int) :: fd
    end function
    function native_read(fd, buffer, count) bind(c, name='read') result(bytes)
      import :: c_int, c_ptr, c_size_t, c_intptr_t
      integer(c_int), value :: fd
      type(c_ptr), value :: buffer
      integer(c_size_t), value :: count
      integer(c_intptr_t) :: bytes
    end function
    function native_close(fd) bind(c, name='close') result(status)
      import :: c_int
      integer(c_int), value :: fd
      integer(c_int) :: status
    end function
    function native_errno_address() bind(c, name='__errno_location') result(address)
      import :: c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Read PATH, admit its first empty NAMDIM_TRAJ group, and set twelve scalars.
  !> PATH is input, at most4095 characters after Fortran space-padding removal.
  !> OUTPUT and optional diagnostic change only after complete success.
  !> Up to262144 file bytes are supported. Status0 succeeds;2 reports a file,
  !> allocation, parser or wave-domain failure without terminating the process.
  !> A successful file route sets errno0 and preserves incoming IEEE status,
  !> matching the retained successful source boundary. Failure errno is natural.
  integer(c_int) function initialize_trajectory_dimensions_from_file(wave_limit, path, output, diagnostics) result(status)
    integer(c_int), intent(in) :: wave_limit
    character(len=*), intent(in) :: path
    type(native_trajectory_dimensions), intent(inout) :: output
    type(native_trajectory_entry_diagnostics), intent(inout), optional :: diagnostics
    character(kind=c_char), allocatable, target :: buffer(:)
    character(kind=c_char) :: c_path(path_capacity)
    integer(c_int), pointer, volatile :: errno_word
    type(ieee_status_type) :: incoming_status
    integer(c_int) :: fd, closed, parse_status
    integer :: path_length, k, total, allocation_status
    integer(c_intptr_t) :: received
    status = 2_c_int
    path_length = len_trim(path)
    if (path_length == 0 .or. path_length >= path_capacity) return
    do k = 1, path_length
      if (iachar(path(k:k)) == 0) return
      c_path(k) = path(k:k)
    end do
    c_path(path_length + 1) = c_null_char
    call c_f_pointer(native_errno_address(), errno_word)
    call ieee_get_status(incoming_status)
    fd = -1_c_int
    allocate (buffer(text_capacity), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    fd = native_open(c_path, 0_c_int, 0_c_int)
    if (fd < 0_c_int) goto 900
    total = 0
    do
      received = native_read(fd, c_loc(buffer(total + 1)), int(text_capacity - total, c_size_t))
      if (received < 0_c_intptr_t) then
        if (errno_word == 4_c_int) cycle
        goto 900
      end if
      if (received == 0_c_intptr_t) exit
      total = total + int(received)
      if (total >= text_capacity) goto 900
    end do
    closed = native_close(fd)
    if (closed /= 0_c_int) goto 900
    fd = -1_c_int
    parse_status = require_empty_trajectory_dimension_bytes(buffer(:total))
    if (parse_status /= 0_c_int) goto 900
    deallocate (buffer)
    errno_word = 0_c_int
    call ieee_set_status(incoming_status)
    status = initialize_trajectory_dimensions(wave_limit, output)
    if (status == 0_c_int .and. present(diagnostics)) call record_trajectory_entry(diagnostics)
    return
900 continue
    if (fd >= 0_c_int) closed = native_close(fd)
    if (allocated(buffer)) deallocate (buffer)
    call ieee_set_status(incoming_status)
  end function initialize_trajectory_dimensions_from_file
end module forecast_trajectory_dimension_file
