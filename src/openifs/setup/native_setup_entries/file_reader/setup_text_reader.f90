!> Read the exact bytes of the local fort.4 setup file.
!!
!! The caller receives one 262145-byte allocation and owns its deallocation.
!! Only text(:used) is input text after status zero. The remaining bytes have
!! no defined value. No terminator, line conversion, or second byte copy is made.
!! The public POSIX services use the current Linux LP64 C ABI. They can change
!! errno naturally; the setup parent owns any later source status restoration.
module forecast_setup_text_reader
  use, intrinsic :: iso_c_binding, only: c_char, c_null_char, c_int, c_int32_t, &
                                                                            c_intptr_t, c_size_t, c_ptr, c_loc, c_f_pointer
  implicit none
  private
  public :: read_setup_text

  integer(c_int32_t), parameter :: setup_buffer_bytes = 262145_c_int32_t
  integer(c_int), parameter :: interrupted_system_call = 4_c_int
  character(kind=c_char, len=7), parameter :: setup_filename = 'fort.4'//c_null_char

  interface
    function posix_open(path, flags, mode) bind(C, name='open') result(descriptor)
      import :: c_char, c_int
      character(kind=c_char), intent(in) :: path(*)
      integer(c_int), value :: flags, mode
      integer(c_int) :: descriptor
    end function posix_open

    function posix_read(descriptor, buffer, bytes) bind(C, name='read') result(received)
      import :: c_int, c_ptr, c_size_t, c_intptr_t
      integer(c_int), value :: descriptor
      type(c_ptr), value :: buffer
      integer(c_size_t), value :: bytes
      integer(c_intptr_t) :: received
    end function posix_read

    function posix_close(descriptor) bind(C, name='close') result(code)
      import :: c_int
      integer(c_int), value :: descriptor
      integer(c_int) :: code
    end function posix_close

    function errno_address() bind(C, name='__errno_location') result(address)
      import :: c_ptr
      type(c_ptr) :: address
    end function errno_address
  end interface

contains

  !> Return the bytes from fort.4 without interpreting their contents.
  !!
  !! Parameters
  !! ----------
  !! text : allocatable TARGET scalar character(kind=c_char,len=:), inout
  !!   Must be unallocated at entry. It remains caller-owned after allocation,
  !!   including on failure. Its allocation has exactly 262145 one-byte chars.
  !! used : integer(c_int32_t), out
  !!   Number of bytes received. A successful result is in 0:262144. A full
  !!   rejected buffer reports 262145; failed I/O can report a shorter prefix.
  !! status : integer(c_int32_t), out
  !!   Zero means success. One means allocation or POSIX service failure.
  !!   Two means a nonfresh text owner or the full-buffer size refusal.
  !!
  !! Notes
  !! -----
  !! The reader retries read only for EINTR (errno 4). Every successful open
  !!   has one cleanup close on read and size failures. A failed EOF close
  !!   receives the original second cleanup close attempt.
  !! No floating-point arithmetic, errno assignment, or FP-mode change occurs.
  !! The caller must deallocate text before entering the numerical setup child
  !!   if its parent source requires input storage to have been released there.
  subroutine read_setup_text(text, used, status)
    character(kind=c_char, len=:), allocatable, target, intent(inout) :: text
    integer(c_int32_t), intent(out) :: used, status
    integer(c_int), pointer, volatile :: current_errno
    integer(c_int) :: descriptor, close_code
    integer :: allocation_status
    integer(c_size_t) :: remaining
    integer(c_intptr_t) :: received

    used = 0_c_int32_t
    status = 2_c_int32_t
    if (allocated(text)) return

    call c_f_pointer(errno_address(), current_errno)
    allocate (character(kind=c_char, len=setup_buffer_bytes) :: text, stat=allocation_status)
    status = 1_c_int32_t
    if (allocation_status /= 0) return

    descriptor = posix_open(setup_filename, 0_c_int, 0_c_int)
    if (descriptor < 0_c_int) return

    do
      remaining = int(setup_buffer_bytes - used, c_size_t)
      received = posix_read(descriptor, c_loc(text(used + 1:used + 1)), remaining)
      if (received < 0_c_intptr_t) then
        if (current_errno == interrupted_system_call) cycle
        exit
      end if
      if (received == 0_c_intptr_t) then
        status = 0_c_int32_t
        exit
      end if
      used = used + int(received, c_int32_t)
      if (used >= setup_buffer_bytes) then
        status = 2_c_int32_t
        exit
      end if
    end do

    close_code = posix_close(descriptor)
    if (close_code /= 0_c_int .and. status == 0_c_int32_t) then
      status = 1_c_int32_t
      close_code = posix_close(descriptor)
    end if
  end subroutine read_setup_text

end module forecast_setup_text_reader
