!> Own the distributed TGFL source entry on the canonical native four-owner type.
module forecast_distributed_gridpoint_storage
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use gridpoint_field_storage_port, only: gridpoint_field_state, initialize_gridpoint_field, &
                                          gridpoint_field_storage_is_fresh, gridpoint_field_storage_mode_supported, &
                                          release_gridpoint_field
  use forecast_next_time_field_storage, only: native_next_time_gridpoint_state
  use md2asm_moist_air_gas_properties, only: thermal_constituent
  implicit none
  private
  public :: gridpoint_field_state, initialize_gridpoint_field
  public :: initialize_distributed_gridpoint_field, zero_gridpoint_field, release_gridpoint_field
  interface
    function errno_address() bind(C, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Allocate the source tuple17,137,97055,9,3,0,0 without payload writes.
 !! CONTROLS is seven live int32 counts. Constituents remain borrowed readonly.
 !! The four arrays retain shape(P,L,F,B), including allocated zero extents.
 !! This is distinct from the older388217-block global storage specialization.
 !! Return0 completes,1 releases the acquired prefix on allocation failure,
 !! or2 leaves the destination unchanged on refusal. IEEE/errno are preserved.
  integer(int32) function initialize_distributed_gridpoint_field(state, controls, constituents) result(status)
    type(gridpoint_field_state), intent(inout) :: state
    integer(int32), intent(in) :: controls(7)
    type(thermal_constituent), target, intent(in) :: constituents(:)
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer :: allocation_status
    integer(int32) :: ignored
    status = 2
    if (any(controls /= [17, 137, 97055, 9, 3, 0, 0])) return
    if (.not. gridpoint_field_storage_is_fresh(state)) return
    if (.not. gridpoint_field_storage_mode_supported()) return
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    status = 1
    allocate (state%gfl(controls(1), controls(2), controls(4), controls(3)), stat=allocation_status)
    if (allocation_status /= 0) goto800
    allocate (state%gflslp(controls(1), controls(2), controls(5), controls(3)), stat=allocation_status)
    if (allocation_status /= 0) goto800
    allocate (state%gflpt(controls(1), controls(2), controls(6), controls(3)), stat=allocation_status)
    if (allocation_status /= 0) goto800
    allocate (state%gflpc(controls(1), controls(2), controls(7), controls(3)), stat=allocation_status)
    if (allocation_status /= 0) goto800
    state%pitch = controls(1); state%levels = controls(2); state%blocks = controls(3)
    state%constituents => constituents; state%ready = .true.; status = 0
    goto900
800 ignored = release_gridpoint_field(state)
900 call ieee_set_status(saved); error_number = saved_errno
  end function
  !> Zero every attached source field without allocating or reading absent owners.
 !! NEXT is the separate later GFLT1 owner. Its optional absence denotes an
 !! unattached old fifth field; no change to the initial four-owner type occurs.
  integer(int32) function zero_gridpoint_field(state, next) result(status)
    type(gridpoint_field_state), intent(inout) :: state
    type(native_next_time_gridpoint_state), intent(inout), optional :: next
    status = 0
    if (allocated(state%gfl)) state%gfl = 0.0_real64
    if (present(next)) then
      if (allocated(next%gflt1)) next%gflt1 = 0.0_real64
    end if
    if (allocated(state%gflslp)) state%gflslp = 0.0_real64
    if (allocated(state%gflpt)) state%gflpt = 0.0_real64
    if (allocated(state%gflpc)) state%gflpc = 0.0_real64
  end function
end module
