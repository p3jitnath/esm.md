module native_ozone_climatology
  !! Original ozone mixing ratio in ppmv on the fixed 19-latitude, 34-pressure, 12-month file grid.
  !! RPROC keeps its source Pa values. This file grid is independent of model level count.
  use iso_c_binding, only: c_int, c_int8_t, c_int64_t, c_double, c_ptr, c_f_pointer
  use yoeozoc, only: TEOZOC
  use absorption_binary_file_service, only: read_coefficient_file, network_word32, decode_real_words
  implicit none
  private
  public :: initialize_ozone_climatology, read_ozone_climatology_file, release_ozone_climatology
  integer(c_int64_t), parameter :: pressure_words(61) = [ &
    int(z'0000000000000000',c_int64_t),int(z'3fd3333333333333',c_int64_t),int(z'3fe0000000000000',c_int64_t),int(z'3fe6666666666666',c_int64_t), &
    int(z'3ff0000000000000',c_int64_t),int(z'3ff8000000000000',c_int64_t),int(z'4000000000000000',c_int64_t),int(z'4008000000000000',c_int64_t), &
    int(z'4014000000000000',c_int64_t),int(z'401c000000000000',c_int64_t),int(z'4024000000000000',c_int64_t),int(z'402e000000000000',c_int64_t), &
    int(z'4034000000000000',c_int64_t),int(z'403e000000000000',c_int64_t),int(z'4049000000000000',c_int64_t),int(z'4051800000000000',c_int64_t), &
    int(z'4059000000000000',c_int64_t),int(z'4062c00000000000',c_int64_t),int(z'4069000000000000',c_int64_t),int(z'4072c00000000000',c_int64_t), &
    int(z'407f400000000000',c_int64_t),int(z'4085e00000000000',c_int64_t),int(z'408f400000000000',c_int64_t),int(z'4097700000000000',c_int64_t), &
    int(z'409f400000000000',c_int64_t),int(z'40a7700000000000',c_int64_t),int(z'40b3880000000000',c_int64_t),int(z'40bb580000000000',c_int64_t), &
    int(z'40c3880000000000',c_int64_t),int(z'40cd4c0000000000',c_int64_t),int(z'40d3880000000000',c_int64_t),int(z'40dd4c0000000000',c_int64_t), &
    int(z'40e86a0000000000',c_int64_t),int(z'40f1170000000000',c_int64_t),int(z'40f86a0000000000',c_int64_t),int(z'40fadb0000000000',c_int64_t), &
    int(z'0000000000000000',c_int64_t),int(z'0000000000000000',c_int64_t),int(z'0000000000000000',c_int64_t),int(z'0000000000000000',c_int64_t), &
    int(z'0000000000000000',c_int64_t),int(z'0000000000000000',c_int64_t),int(z'0000000000000000',c_int64_t),int(z'0000000000000000',c_int64_t), &
    int(z'0000000000000000',c_int64_t),int(z'0000000000000000',c_int64_t),int(z'0000000000000000',c_int64_t),int(z'0000000000000000',c_int64_t), &
    int(z'0000000000000000',c_int64_t),int(z'0000000000000000',c_int64_t),int(z'0000000000000000',c_int64_t),int(z'0000000000000000',c_int64_t), &
    int(z'0000000000000000',c_int64_t),int(z'0000000000000000',c_int64_t),int(z'0000000000000000',c_int64_t),int(z'0000000000000000',c_int64_t), &
    int(z'0000000000000000',c_int64_t),int(z'0000000000000000',c_int64_t),int(z'0000000000000000',c_int64_t),int(z'0000000000000000',c_int64_t), &
                                   int(z'0000000000000000', c_int64_t)]
  interface
    function errno_address() bind(C, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  function initialize_ozone_climatology(bytes, output) result(status)
    !! Read exactly 62024 bytes; allocate ZOZCL(19,34,12) and commit only after complete decoding.
    !! All other canonical TEOZOC members remain unchanged, except RPROC(61) as the source assigns.
    integer(c_int8_t), intent(in) :: bytes(:)
    type(TEOZOC), intent(inout) :: output
    integer(c_int) :: status, saved_errno
    integer(c_int), pointer :: error_number
    integer :: allocation_status, index
    real(c_double), allocatable :: temporary(:, :, :)
    status = 2_c_int
    if (size(bytes) /= 62024) return
    if (allocated(output%ZOZCL)) return
    if (network_word32(bytes, 1) /= 62016_c_int64_t) return
    if (network_word32(bytes, 62021) /= 62016_c_int64_t) return
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    allocate (temporary(19, 34, 12), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1_c_int
      return
    end if
    call decode_real_words(bytes, 5, temporary, 7752)
    do index = 1, 61
      output%RPROC(lbound(output%RPROC, 1) + index - 1) = transfer(pressure_words(index), 0.0_c_double)
    end do
    call move_alloc(temporary, output%ZOZCL)
    error_number = saved_errno
    status = 0_c_int
  end function
  function read_ozone_climatology_file(path, output) result(status)
    !! Public POSIX input supplies the exact original ECOZC bytes through one bounded workspace.
    character(*), intent(in) :: path
    type(TEOZOC), intent(inout) :: output
    integer(c_int) :: status
    integer(c_int8_t), allocatable, target :: workspace(:)
    status = read_coefficient_file(path, 62024, workspace)
    if (status /= 0) return
    status = initialize_ozone_climatology(workspace(1:62024), output)
  end function
  function release_ozone_climatology(output) result(status)
    !! Release only ZOZCL; preserve pressure, other owners, all scalars and errno. Repeated release is valid.
    type(TEOZOC), intent(inout) :: output
    integer(c_int) :: status, saved_errno
    integer(c_int), pointer :: error_number
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    if (allocated(output%ZOZCL)) deallocate (output%ZOZCL)
    error_number = saved_errno
    status = 0_c_int
  end function
end module native_ozone_climatology
