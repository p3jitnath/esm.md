module absorption_binary_file_service
  !! Public file services supply only the original bounded coefficient bytes.
  use iso_c_binding
  implicit none
  private
  public :: read_coefficient_file, network_word32, decode_real_words
  interface
    function posix_open(path, flags) bind(C, name='open') result(fd)
      import c_char, c_int
      character(kind=c_char), intent(in) :: path(*)
      integer(c_int), value :: flags
      integer(c_int) :: fd
    end function
    function posix_read(fd, buffer, count) bind(C, name='read') result(bytes_read)
      import c_int, c_ptr, c_size_t, c_intptr_t
      integer(c_int), value :: fd
      type(c_ptr), value :: buffer
      integer(c_size_t), value :: count
      integer(c_intptr_t) :: bytes_read
    end function
    function posix_close(fd) bind(C, name='close') result(status)
      import c_int
      integer(c_int), value :: fd
      integer(c_int) :: status
    end function
    function errno_address() bind(C, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  function read_coefficient_file(path, expected, bytes) result(status)
    !! Path has 1 through 4095 non-NUL characters. Read through EOF into one owned workspace.
    !! The returned byte workspace has expected+1 slots; only the first expected are data.
    character(*), intent(in) :: path
    integer, intent(in) :: expected
    integer(c_int8_t), allocatable, target, intent(out) :: bytes(:)
    integer(c_int) :: status, fd, close_status, saved_errno
    integer(c_int), pointer :: error_number
    character(kind=c_char) :: cpath(4096)
    integer :: i, allocation_status, used
    integer(c_intptr_t) :: count
    status = 2_c_int
    if (len(path) < 1 .or. len(path) > 4095 .or. expected <= 0) return
    do i = 1, len(path)
      if (iachar(path(i:i)) == 0) return
      cpath(i) = path(i:i)
    end do
    cpath(len(path) + 1) = c_null_char
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    status = 1_c_int
    fd = posix_open(cpath, 0_c_int)
    if (fd < 0) then
      error_number = saved_errno
      return
    end if
    allocate (bytes(expected + 1), stat=allocation_status)
    if (allocation_status == 0) then
      used = 0
      do
        count = posix_read(fd, c_loc(bytes(used + 1)), int(expected + 1 - used, c_size_t))
        if (count < 0_c_intptr_t) exit
        if (count == 0_c_intptr_t) then
          status = 2_c_int
          if (used == expected) status = 0_c_int
          exit
        end if
        used = used + int(count)
        if (used == expected + 1) then
          status = 2_c_int
          exit
        end if
      end do
    end if
    close_status = posix_close(fd)
    if (status /= 0 .and. allocated(bytes)) deallocate (bytes)
    error_number = saved_errno
  end function
  function network_word32(bytes, first) result(word)
    !! Decode one four-byte unsigned big-endian record length with integer operations.
    integer(c_int8_t), intent(in) :: bytes(:)
    integer, intent(in) :: first
    integer(c_int64_t) :: word
    integer :: j
    word = 0_c_int64_t
    do j = first, first + 3
      word = ior(shiftl(word, 8), iand(int(bytes(j), c_int64_t), 255_c_int64_t))
    end do
  end function
  subroutine decode_real_words(bytes, first, output, count)
    !! Copy count source binary64 words to one named contiguous source array.
    !! Sequence association preserves its declared source rank and lower bounds.
    integer(c_int8_t), intent(in) :: bytes(:)
    integer, intent(in) :: first, count
    real(c_double), intent(inout) :: output(count)
    integer(c_int64_t) :: word
    integer :: i, j, position
    position = first
    do i = 1, count
      word = 0_c_int64_t
      do j = 1, 8
        word = ior(shiftl(word, 8), iand(int(bytes(position), c_int64_t), 255_c_int64_t))
        position = position + 1
      end do
      output(i) = transfer(word, 0.0_c_double)
    end do
  end subroutine
end module absorption_binary_file_service
