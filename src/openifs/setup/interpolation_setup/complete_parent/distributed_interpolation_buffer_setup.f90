!> Own the complete local and communicating interpolation-map setup.
module forecast_interpolation_buffer_setup
  use iso_fortran_env, only: int32, int64
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use forecast_interpolation_state_types, only: native_interpolation_state
  use forecast_interpolation_local_maps, only: native_interpolation_grid_parameters, &
                                               create_interpolation_local_maps, release_interpolation_local_maps
  use forecast_live_interpolation_communication, only: &
    initialize_distributed_interpolation_communication => initialize_live_distributed_interpolation_communication, &
    admit_distributed_interpolation_communication => admit_live_distributed_interpolation_communication
  use forecast_interpolation_reporting, only: write_distributed_halo_status
  use forecast_public_transform, only: native_transform_control
  use forecast_distributed_partition_collectives, only: agree_distributed_partition_status, abort_distributed_partition
  implicit none
  private
  public :: initialize_distributed_interpolation_buffer, release_distributed_interpolation_buffer
  public :: interpolation_global_halo_capacity
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Agree added control metadata without changing reached numerical status.
  !! The extra admission MAX has no source arithmetic or I/O role. Its public
  !! library may change errno or floating flags, so this wrapper restores the
  !! incoming environment after collecting the agreed integer result. Original
  !! reporting and SLRSET communication retain their natural library effects.
  integer(int32) function agree_interpolation_control_status(control, local_status) result(status)
    type(native_transform_control), intent(in) :: control
    integer(int32), intent(in) :: local_status
    type(ieee_status_type) :: incoming
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: incoming_errno
    call c_f_pointer(errno_address(), error_number)
    incoming_errno = error_number
    call ieee_get_status(incoming)
    status = agree_distributed_partition_status(control, local_status)
    call ieee_set_status(incoming)
    error_number = incoming_errno
  end function

  !> Produce every local map, report its extent, then perform source SLRSET.
  !! All processes enter together under one borrowed live public message
  !! context. Process and grid-region counts come from that live context.
  !! Numerical acceptance remains limited to independently matched cohorts.
  !! Grid-region indices are KASET/KBSET, distinct from spectral partitions.
  !! STATE has stable TARGET storage and absent source-owned map arrays.
  !! Other incoming members remain unchanged, including an unused RI NSLMAP.
  !! KSTA/KONL retain lower bounds(-1,1), KLOENG starts at-1, and the region
  !! lists and PROCESS_IDS start at1. All integer values are dimensionless.
  !! GLOBAL_CAPACITY is derived from the complete global row lengths by
  !! interpolation_global_halo_capacity. COMMUNICATION_BUDGET bounds new
  !! communication storage in bytes. The outer owner budgets existing local
  !! maps too and establishes nearest rounding and gradual underflow.
  !! REPORT_UNIT is a live Fortran output unit. The exact source report is
  !! emitted before communication. Its I/O failure is a coordinated fatal
  !! public-provider error, as in the generated source route.
  !! Return0 publishes all15SL or14RI map owners and written scalars.
  !! Return1 is an agreed allocation failure;2 is an agreed unsupported
  !! input. Both leave caller-owned state unchanged. CHILD_STATUS is the
  !! coherent source status. Optional ALLOCATOR_DETAIL is the rank-local
  !! native allocation result, which can differ between processes.
  integer(int32) function initialize_distributed_interpolation_buffer(state, grid, &
                                                    ksta, konl, kloeng, kptrfrstlat, kfrstlat, klstlat, kaset, kbset, process_ids, &
                         control, global_capacity, communication_budget, report_unit, child_status, allocator_detail) result(status)
    type(native_interpolation_state), target, intent(inout) :: state
    type(native_interpolation_grid_parameters), intent(in) :: grid
    integer(int32), contiguous, intent(in) :: ksta(-1:, :), konl(-1:, :), kloeng(-1:)
    integer(int32), contiguous, intent(in) :: kptrfrstlat(:), kfrstlat(:), klstlat(:), process_ids(:)
    integer(int32), intent(in) :: kaset, kbset, report_unit
    type(native_transform_control), intent(in) :: control
    integer(int64), intent(in) :: global_capacity, communication_budget
    integer(int32), intent(out) :: child_status
    integer(int32), optional, intent(out) :: allocator_detail
    type(native_interpolation_state), target :: pending
    type(ieee_status_type) :: reached
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: reached_errno
    integer(int32) :: local_status, raw_allocator, ignored
    logical :: radiation
    status = 2; child_status = 2
    if (present(allocator_detail)) allocator_detail = 0
    ! A uniform live message context is the entry's public-lifetime precondition.
    if (.not. control%message_ready) return
    local_status = 0
    if (control%nproc < 1 .or. control%nproc > 65536) local_status = 2
    if (control%regions_ns < 1 .or. control%regions_ew < 1) local_status = 2
    if (control%myproc < 1 .or. control%myproc > control%nproc) local_status = 2
    if (global_capacity < 1 .or. communication_budget < 1_int64) local_status = 2
    if (global_capacity /= interpolation_global_halo_capacity(kloeng, grid%ndglg)) local_status = 2
    if (size(process_ids) /= control%nproc) local_status = 2
    if (grid%ndglg < 2 .or. grid%ndglg > 8192 .or. grid%ndlon < 1 .or. grid%ndlon > 32768) local_status = 2
    radiation = state%cver == 'RI' .or. state%cver == 'RO'
    if (allocated(state%nloeng)) local_status = 2
    if (allocated(state%nslsta)) local_status = 2
    if (allocated(state%nslonl)) local_status = 2
    if (allocated(state%nsloff)) local_status = 2
    if (.not. radiation) then
      if (allocated(state%nslmap)) local_status = 2
    end if
    if (allocated(state%nslcore)) local_status = 2
    if (allocated(state%nslext)) local_status = 2
    if (allocated(state%mask_sl1)) local_status = 2
    if (allocated(state%mask_sl2)) local_status = 2
    if (allocated(state%mask_sld)) local_status = 2
    if (allocated(state%nslsendpos)) local_status = 2
    if (allocated(state%nslrecvpos)) local_status = 2
    if (allocated(state%nslsendptr)) local_status = 2
    if (allocated(state%nslrecvptr)) local_status = 2
    if (allocated(state%nslcomm)) local_status = 2
    child_status = agree_interpolation_control_status(control, local_status)
    if (child_status /= 0) then
      status = child_status
      return
    end if
    pending%CVER = state%CVER
    pending%NSLGROUP = state%NSLGROUP
    pending%NASLB1 = state%NASLB1
    pending%NASLB1_TRUE = state%NASLB1_TRUE
    pending%NSLPAD = state%NSLPAD
    pending%LSLT_ARRAYS_INIT = state%LSLT_ARRAYS_INIT
    pending%LSLONDEM = state%LSLONDEM
    pending%LSLONDEM_ACTIVE = state%LSLONDEM_ACTIVE
    pending%NUNUSEDHALO = state%NUNUSEDHALO
    pending%DISTUNUSEDHALO = state%DISTUNUSEDHALO
    pending%NSLPROCS = state%NSLPROCS
    pending%NSLRPT = state%NSLRPT
    pending%NSLSPT = state%NSLSPT
    pending%NSLWIDEN = state%NSLWIDEN
    pending%NSLWIDES = state%NSLWIDES
    pending%NSLWIDEE = state%NSLWIDEE
    pending%NSLWIDEW = state%NSLWIDEW
    pending%NSLWIDE = state%NSLWIDE
    pending%NDGLG = state%NDGLG
    pending%NDLON = state%NDLON
    pending%NDGSAG = state%NDGSAG
    pending%NDGENG = state%NDGENG
    pending%NDGSAL = state%NDGSAL
    pending%NDGENL = state%NDGENL
    pending%NDGSAH = state%NDGSAH
    pending%NDGENH = state%NDGENH
    pending%NGPTOT = state%NGPTOT
    pending%NDGUXL = state%NDGUXL
    pending%NDLUNG = state%NDLUNG
    pending%NDLUXG = state%NDLUXG
    pending%NDGUNG = state%NDGUNG
    pending%NDGUXG = state%NDGUXG
    pending%NDSUR1 = state%NDSUR1
    pending%NDLSUR = state%NDLSUR
    pending%NDGSUR = state%NDGSUR
    pending%NPTRFLOFF = state%NPTRFLOFF
    pending%NFRSTLOFF = state%NFRSTLOFF
    pending%MYFRSTACTLAT = state%MYFRSTACTLAT
    pending%MYLSTACTLAT = state%MYLSTACTLAT
    local_status = create_interpolation_local_maps(pending, grid, ksta, konl, kloeng, &
                                                   kfrstlat, klstlat, kaset, kbset, raw_allocator)
    if (present(allocator_detail)) allocator_detail = raw_allocator
    child_status = agree_interpolation_control_status(control, local_status)
    if (child_status /= 0) goto900
    ! Admit the exact child predicates collectively before its first MAX.
    local_status = admit_distributed_interpolation_communication(pending, ksta, konl, &
                                        kptrfrstlat, kfrstlat, klstlat, process_ids, control, global_capacity, communication_budget)
    child_status = agree_interpolation_control_status(control, local_status)
    if (child_status /= 0) goto900
    local_status = write_distributed_halo_status(pending, report_unit)
    if (local_status /= 0) call abort_distributed_partition()
    child_status = initialize_distributed_interpolation_communication(pending, ksta, konl, &
                                        kptrfrstlat, kfrstlat, klstlat, process_ids, control, global_capacity, communication_budget)
    if (child_status /= 0) goto900
    call move_alloc(pending%nloeng, state%nloeng)
    call move_alloc(pending%nslsta, state%nslsta)
    call move_alloc(pending%nslonl, state%nslonl)
    call move_alloc(pending%nsloff, state%nsloff)
    if (.not. radiation) call move_alloc(pending%nslmap, state%nslmap)
    call move_alloc(pending%nslcore, state%nslcore)
    call move_alloc(pending%nslext, state%nslext)
    call move_alloc(pending%mask_sl1, state%mask_sl1)
    call move_alloc(pending%mask_sl2, state%mask_sl2)
    call move_alloc(pending%mask_sld, state%mask_sld)
    call move_alloc(pending%nslsendpos, state%nslsendpos)
    call move_alloc(pending%nslrecvpos, state%nslrecvpos)
    call move_alloc(pending%nslsendptr, state%nslsendptr)
    call move_alloc(pending%nslrecvptr, state%nslrecvptr)
    call move_alloc(pending%nslcomm, state%nslcomm)
    state%CVER = pending%CVER
    state%NSLGROUP = pending%NSLGROUP
    state%NASLB1 = pending%NASLB1
    state%NASLB1_TRUE = pending%NASLB1_TRUE
    state%NSLPAD = pending%NSLPAD
    state%LSLT_ARRAYS_INIT = pending%LSLT_ARRAYS_INIT
    state%LSLONDEM = pending%LSLONDEM
    state%LSLONDEM_ACTIVE = pending%LSLONDEM_ACTIVE
    state%NUNUSEDHALO = pending%NUNUSEDHALO
    state%DISTUNUSEDHALO = pending%DISTUNUSEDHALO
    state%NSLPROCS = pending%NSLPROCS
    state%NSLRPT = pending%NSLRPT
    state%NSLSPT = pending%NSLSPT
    state%NSLWIDEN = pending%NSLWIDEN
    state%NSLWIDES = pending%NSLWIDES
    state%NSLWIDEE = pending%NSLWIDEE
    state%NSLWIDEW = pending%NSLWIDEW
    state%NSLWIDE = pending%NSLWIDE
    state%NDGLG = pending%NDGLG
    state%NDLON = pending%NDLON
    state%NDGSAG = pending%NDGSAG
    state%NDGENG = pending%NDGENG
    state%NDGSAL = pending%NDGSAL
    state%NDGENL = pending%NDGENL
    state%NDGSAH = pending%NDGSAH
    state%NDGENH = pending%NDGENH
    state%NGPTOT = pending%NGPTOT
    state%NDGUXL = pending%NDGUXL
    state%NDLUNG = pending%NDLUNG
    state%NDLUXG = pending%NDLUXG
    state%NDGUNG = pending%NDGUNG
    state%NDGUXG = pending%NDGUXG
    state%NDSUR1 = pending%NDSUR1
    state%NDLSUR = pending%NDLSUR
    state%NDGSUR = pending%NDGSUR
    state%NPTRFLOFF = pending%NPTRFLOFF
    state%NFRSTLOFF = pending%NFRSTLOFF
    state%MYFRSTACTLAT = pending%MYFRSTACTLAT
    state%MYLSTACTLAT = pending%MYLSTACTLAT
    status = 0
    return
900 continue
    status = child_status
    call ieee_get_status(reached)
    call c_f_pointer(errno_address(), error_number)
    reached_errno = error_number
    ignored = release_interpolation_local_maps(pending, include_nslmap=.not. radiation)
    call release_parent_communication_owners(pending)
    call ieee_set_status(reached)
    error_number = reached_errno
  end function

  !> Release just the map owners created by this parent, permitting repeats.
  !! This entry does not end the borrowed message lifetime or reset source
  !! scalar members. RI/RO preserve a foreign NSLMAP. The incoming floating
  !! status and errno survive cleanup, matching the generated free route.
  integer(int32) function release_distributed_interpolation_buffer(state) result(status)
    type(native_interpolation_state), intent(inout) :: state
    type(ieee_status_type) :: incoming
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer(int32) :: ignored
    logical :: owns_map
    status = 0
    owns_map = state%cver == 'SL'
    call ieee_get_status(incoming)
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    ! Generated source releases local owners before the five communication owners.
    ignored = release_interpolation_local_maps(state, include_nslmap=owns_map)
    call release_parent_communication_owners(state)
    call ieee_set_status(incoming)
    error_number = saved_errno
  end function

  !> Bound a process halo by complete rows and source extension storage.
  !! Every global row appears at most once in one local halo. A row uses at
  !! most its complete physical length plus three periodic extension points.
  !! Include both mirrored rows at each pole, then apply the source's1024
  !! padding and29-point bank offset. All counts use checked int64 arithmetic.
  !! Return0 refuses invalid row lengths or a bound outside the local contract.
  integer(int64) function interpolation_global_halo_capacity(kloeng, ndglg) result(capacity)
    integer(int32), intent(in) :: kloeng(-1:), ndglg
    integer(int64) :: complete_points
    integer :: row
    capacity = 0_int64
    if (ndglg < 2 .or. ndglg > 8192 .or. mod(ndglg, 2) /= 0) return
    if (size(kloeng) < ndglg + 4) return
    complete_points = 3_int64*(int(ndglg, int64) + 4)
    do row = -1, ndglg + 2
      if (kloeng(row) < 1 .or. kloeng(row) > 32768) return
      complete_points = complete_points + int(kloeng(row), int64)
    end do
    capacity = ((complete_points - 1_int64)/1024_int64 + 1_int64)*1024_int64 + 29_int64
    if (capacity > 268435456_int64) capacity = 0_int64
  end function

  !> Release the five communication owners in the enclosing source order.
  !! This order is distinct from the child's private-workspace release order.
  subroutine release_parent_communication_owners(state)
    type(native_interpolation_state), intent(inout) :: state
    if (allocated(state%nslsendpos)) deallocate (state%nslsendpos)
    if (allocated(state%nslrecvpos)) deallocate (state%nslrecvpos)
    if (allocated(state%nslsendptr)) deallocate (state%nslsendptr)
    if (allocated(state%nslrecvptr)) deallocate (state%nslrecvptr)
    if (allocated(state%nslcomm)) deallocate (state%nslcomm)
  end subroutine
end module forecast_interpolation_buffer_setup
