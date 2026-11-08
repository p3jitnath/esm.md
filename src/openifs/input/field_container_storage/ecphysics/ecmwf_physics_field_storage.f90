!> Allocate and zero the source ECMWF physics working arrays.
module forecast_ecmwf_physics_fields
  use, intrinsic :: iso_c_binding, only: c_int, c_double, c_ptr, c_f_pointer
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use forecast_ecmwf_physics_field_types, only: native_ecmwf_physics_fields
  implicit none
  private
  public :: initialize_ecmwf_physics_fields, initialize_runtime_ecmwf_physics_fields
  public :: release_ecmwf_physics_fields, release_runtime_ecmwf_physics_fields
  interface
    function errno_address() bind(c, name='__errno_location') result(address)
      import :: c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Selected shape order is(P,L,B,T):1:64,1:64,1:128,1:16.
  integer(c_int) function initialize_ecmwf_physics_fields(state, shape, owned_count) result(status)
    type(native_ecmwf_physics_fields), intent(inout) :: state
    integer(c_int), intent(in) :: shape(4)
    integer(c_int), intent(inout) :: owned_count
    status = initialize_fields(state, shape, owned_count, .false.)
  end function initialize_ecmwf_physics_fields

  !> Runtime shape order is(P,L,B,T):1:1024,1:1024,positiveINT32,1:16.
  integer(c_int) function initialize_runtime_ecmwf_physics_fields(state, shape, owned_count) result(status)
    type(native_ecmwf_physics_fields), intent(inout) :: state
    integer(c_int), intent(in) :: shape(4)
    integer(c_int), intent(inout) :: owned_count
    status = initialize_fields(state, shape, owned_count, .true.)
  end function initialize_runtime_ecmwf_physics_fields

  !> Status0 succeeds,1 cleans up allocation failure,2 refuses before mutation.
  !> First acquire all five tiles; then zero each; then set OWNED_COUNT9
  !> before acquiring and zeroing PHYS_MWAVE. IEEE status and errno survive.
  integer(c_int) function initialize_fields(state, shape, owned_count, runtime) result(status)
    type(native_ecmwf_physics_fields), intent(inout) :: state
    integer(c_int), intent(in) :: shape(4)
    integer(c_int), intent(inout) :: owned_count
    logical, intent(in) :: runtime
    integer(c_int), pointer, volatile :: errno_word
    integer(c_int) :: incoming_errno, cleanup_status, p, l, b, t
    integer :: allocation_status, maximum_columns, maximum_blocks
    type(ieee_status_type) :: incoming_status
    real(c_double), allocatable :: first_tile(:, :, :)
    status = 2_c_int
    maximum_columns = 64
    maximum_blocks = 128
    if (runtime) then
      maximum_columns = 1024
      maximum_blocks = huge(0_c_int)
    end if
    if (shape(1) < 1 .or. shape(1) > maximum_columns) return
    if (shape(2) < 1 .or. shape(2) > maximum_columns) return
    if (shape(3) < 1 .or. shape(3) > maximum_blocks) return
    if (shape(4) < 1 .or. shape(4) > 16) return
    ! Native descriptors must be valid; no private descriptor bytes are read.
    if (state%storage_metadata_written .or. state%lphys_mwave_filled_in) return

    if(allocated(state%rustrti).or.allocated(state%rvstrti).or.allocated(state%rahfsti).or.allocated(state%revapti).or.allocated(state%rtskti).or.allocated(state%phys_mwave)) return
    call c_f_pointer(errno_address(), errno_word)
    incoming_errno = errno_word
    call ieee_get_status(incoming_status)
    p = shape(1)
    l = shape(2)
    b = shape(3)
    t = shape(4)
    ! The first private owner permits publishing the lifecycle flag before
    ! writing the first output descriptor, without an extra allocation.
    allocate (first_tile(p, t, b), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    state%storage_metadata_written = .true.
    call move_alloc(first_tile, state%rustrti)

    allocate (state%rvstrti(p, t, b), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%rahfsti(p, t, b), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%revapti(p, t, b), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (state%rtskti(p, t, b), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    state%rustrti = 0.0_c_double
    state%rvstrti = 0.0_c_double
    state%rahfsti = 0.0_c_double
    state%revapti = 0.0_c_double
    state%rtskti = 0.0_c_double
    owned_count = 9_c_int
    allocate (state%phys_mwave(p, l, 9, b), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    state%phys_mwave = 0.0_c_double
    status = 0_c_int
    goto 910
900 continue
    cleanup_status = release_ecmwf_physics_fields(state)
    status = 1_c_int
910 continue
    call ieee_set_status(incoming_status)
    errno_word = incoming_errno
  end function initialize_fields

  !> Release six arrays in declaration order, preserving count outside STATE,
  !> filled flag and lifecycle history. All acquired owners are stage-owned.
  integer(c_int) function release_ecmwf_physics_fields(state) result(status)
    type(native_ecmwf_physics_fields), intent(inout) :: state
    integer(c_int), pointer, volatile :: errno_word
    integer(c_int) :: incoming_errno
    type(ieee_status_type) :: incoming_status
    call c_f_pointer(errno_address(), errno_word)
    incoming_errno = errno_word
    call ieee_get_status(incoming_status)

    if (allocated(state%rustrti)) deallocate (state%rustrti)
    if (allocated(state%rvstrti)) deallocate (state%rvstrti)
    if (allocated(state%rahfsti)) deallocate (state%rahfsti)
    if (allocated(state%revapti)) deallocate (state%revapti)
    if (allocated(state%rtskti)) deallocate (state%rtskti)
    if (allocated(state%phys_mwave)) deallocate (state%phys_mwave)
    call ieee_set_status(incoming_status)
    errno_word = incoming_errno
    status = 0_c_int
  end function release_ecmwf_physics_fields

  !> Runtime release has the same native owner and declaration-order body.
  integer(c_int) function release_runtime_ecmwf_physics_fields(state) result(status)
    type(native_ecmwf_physics_fields), intent(inout) :: state
    status = release_ecmwf_physics_fields(state)
  end function release_runtime_ecmwf_physics_fields
end module forecast_ecmwf_physics_fields
