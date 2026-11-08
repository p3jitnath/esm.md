!> Own metadata and timers while trajectory saving is inactive.
module forecast_empty_trajectory_storage
  use iso_fortran_env, only: int32, int64
  use iso_c_binding, only: c_int
  use forecast_native_trajectory_types
  use forecast_lifetime_status
  implicit none
  private
  public :: native_empty_trajectory_state, initialize_empty_trajectory_state
  public :: initialize_runtime_empty_trajectory_from_dimensions, release_empty_trajectory_state
contains
!> CONTROLS is START,STOP,BLOCKS,LDFI,LJCDFI, all dimensionless int32 values.
!! STATE is fresh valid native storage. BYTE_LIMIT bounds complete native allocations.
!! Return0 succeeds,1 reports allocation failure,2 refuses without publishing output.
  integer(int32) function initialize_empty_trajectory_state(state, controls, byte_limit) result(status)
    type(native_empty_trajectory_state), intent(inout) :: state
    integer(int32), intent(in) :: controls(5)
    integer(int64), intent(in) :: byte_limit
    status = 2
    if (controls(3) < 1 .or. controls(3) > 128) return
    status = create_trajectory_owners(state, controls, byte_limit)
  end function
!> Derive blocks from live local points and the positive column width.
!! START and STOP are the same forecast clock indices. Both saving flags are false.
integer(int32)function initialize_runtime_empty_trajectory_from_dimensions(state,start,stop,points,width,blocks,ldfi,ljcdfi,byte_limit)result(status)
  type(native_empty_trajectory_state), intent(inout) :: state
  integer(int32), intent(in) :: start, stop, points, width, blocks
  logical, intent(in) :: ldfi, ljcdfi
  integer(int64), intent(in) :: byte_limit
  integer(int32) :: controls(5)
  status = 2
  if (points < 1 .or. width < 1 .or. blocks < 1) return
  if (blocks /= 1 + (points - 1)/width) return
  if (ldfi .or. ljcdfi) return
  controls = [start, stop, blocks, 0_int32, 0_int32]
  status = create_trajectory_owners(state, controls, byte_limit)
  end function
  integer(int32) function create_trajectory_owners(state, controls, byte_limit) result(status)
    type(native_empty_trajectory_state), intent(inout) :: state
    integer(int32), intent(in) :: controls(5)
    integer(int64), intent(in) :: byte_limit
    type(native_empty_trajectory_state) :: pending
    type(native_trajectory_time_record) :: time_type
    type(TRAJ_CST_TYPE) :: constant_type
    type(TRAJ_SLAG_TYPE) :: lagged_type
    type(TRAJ_PHYS_TYPE) :: physics_type
    type(ieee_status_type) :: incoming
    integer(c_int) :: saved_error
    integer(int64) :: required, records, block_bytes
    integer :: allocation_status, j
    integer(int32) :: first, last, blocks, ignored
    status = 2
    first = controls(1); last = controls(2); blocks = controls(3)
    if (first < 0 .or. last < first .or. last > 4096 .or. blocks < 1) return
    if (any(controls(4:5) /= 0)) return
    if (allocated(state%msteptrajw) .or. allocated(state%msteptrajr) .or. allocated(state%trajec)) return
    if (associated(state%cst) .or. associated(state%slag) .or. associated(state%phys)) return
    records = int(last, int64) + 1_int64
 block_bytes=int(storage_size(constant_type),int64)/8+int(storage_size(lagged_type),int64)/8+int(storage_size(physics_type),int64)/8
required = 8_int64*(int(last, int64) - first + 1) + records*(int(storage_size(time_type), int64)/8) + int(blocks, int64)*block_bytes
    if (byte_limit < 0 .or. required > byte_limit) return
    call save_lifetime_status(incoming, saved_error)
    allocate (pending%msteptrajw(first:last), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (pending%msteptrajr(first:last), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (pending%trajec(0:last), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (pending%cst(blocks), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (pending%slag(blocks), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (pending%phys(blocks), stat=allocation_status)
    if (allocation_status /= 0) goto900
    pending%msteptrajw = -99_int32
    pending%msteptrajr = -99_int32
! Pointer declarations establish association only. LASTCHUNK remains unwritten.
    do j = 0, last
      pending%trajec(j)%cst => pending%cst
      pending%trajec(j)%slag => pending%slag
      pending%trajec(j)%phys => pending%phys
    end do
    call move_alloc(pending%msteptrajw, state%msteptrajw)
    call move_alloc(pending%msteptrajr, state%msteptrajr)
    call move_alloc(pending%trajec, state%trajec)
    state%cst => pending%cst; state%slag => pending%slag; state%phys => pending%phys
    nullify (pending%cst, pending%slag, pending%phys)
    call restore_lifetime_status(incoming, saved_error)
    status = 0
    return
900 continue
    ignored = release_empty_trajectory_state(pending)
    call restore_lifetime_status(incoming, saved_error)
    status = 1
  end function
!> Release blocks, time records and timers in reverse source order.
!! A fresh or already released state succeeds. Active saved fields are unsupported.
  integer(int32) function release_empty_trajectory_state(state) result(status)
    type(native_empty_trajectory_state), intent(inout) :: state
    type(ieee_status_type) :: incoming
    integer(c_int) :: saved_error
    call save_lifetime_status(incoming, saved_error)
    if (associated(state%phys)) deallocate (state%phys)
    if (associated(state%slag)) deallocate (state%slag)
    if (associated(state%cst)) deallocate (state%cst)
    nullify (state%phys, state%slag, state%cst)
    if (allocated(state%trajec)) deallocate (state%trajec)
    if (allocated(state%msteptrajr)) deallocate (state%msteptrajr)
    if (allocated(state%msteptrajw)) deallocate (state%msteptrajw)
    call restore_lifetime_status(incoming, saved_error)
    status = 0
  end function
end module forecast_empty_trajectory_storage
