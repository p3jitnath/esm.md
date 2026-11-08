!> Write caller-owned bytes through the public POSIX service.
!! No stream or file descriptor is acquired here. Each call preserves incoming errno.
module forecast_output_stream_services
  use iso_c_binding, only: c_int, c_long, c_size_t, c_ptr, c_f_pointer, c_associated, c_intptr_t
  implicit none
  private
  public :: write_output_bytes
  interface
    function stream_write(fd, bytes, count) bind(c, name='write') result(written)
      import :: c_int, c_long, c_ptr, c_size_t
      integer(c_int), value :: fd
      type(c_ptr), value :: bytes
      integer(c_size_t), value :: count
      integer(c_long) :: written
    end function
    function stream_errno() bind(c, name='__errno_location') result(address)
      import :: c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Return 0 after all bytes, 1 after a failed or zero write, or 2 for invalid size.
  !! retry_interrupt chooses the original entry's EINTR policy. The caller retains ownership.
  integer(c_int) function write_output_bytes(fd, bytes, count, retry_interrupt) result(status)
    integer(c_int), intent(in) :: fd
    type(c_ptr), intent(in) :: bytes
    integer(c_size_t), intent(in) :: count
    logical, intent(in) :: retry_interrupt
    integer(c_int), pointer, volatile :: error_slot
    integer(c_int) :: incoming
    integer(c_size_t) :: remaining
    integer(c_intptr_t) :: address
    integer(c_long) :: written
    type(c_ptr) :: cursor
    call c_f_pointer(stream_errno(), error_slot)
    incoming = error_slot
    status = 2
    if (fd < 0 .or. count < 0_c_size_t) goto 900
    if (count > 0_c_size_t .and. .not. c_associated(bytes)) goto 900
    address = transfer(bytes, address)
    if (count > huge(address) - max(0_c_intptr_t, address)) goto 900
    remaining = count
    status = 1
    do while (remaining > 0_c_size_t)
      cursor = transfer(address, cursor)
      written = stream_write(fd, cursor, remaining)
      if (written < 0_c_long) then
        if (retry_interrupt .and. error_slot == 4_c_int) cycle
        goto 900
      end if
      if (written == 0_c_long) goto 900
      address = address + written
      remaining = remaining - written
    end do
    status = 0
900 continue
    error_slot = incoming
  end function
end module forecast_output_stream_services
