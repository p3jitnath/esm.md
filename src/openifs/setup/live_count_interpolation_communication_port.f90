!> Own generated SLRSET maps with storage derived from the live process count.
!! This draft retains the frozen protocol. Its caller owns public MPI lifetime
!! and supplies independently qualified grid maps, point capacity and budget.
!! The four-process original cohort and each larger live cohort need separate
!! independent acceptance before this entry supplies a production stage.
module forecast_live_interpolation_communication
  use iso_fortran_env, only: int32, int64
  use iso_c_binding, only: c_int
  use forecast_interpolation_state_types, only: native_interpolation_state
  use forecast_public_transform, only: native_transform_control
  use forecast_distributed_partition_collectives, only: &
    agree_distributed_partition_status, abort_distributed_partition
  use mpl_module, only: mpl_alltoallv, mpl_send, mpl_recv, mpl_wait, mpl_allreduce, &
                        JP_NON_BLOCKING_STANDARD
  implicit none
  private
  public :: initialize_live_distributed_interpolation_communication
  public :: release_live_distributed_interpolation_communication
  public :: admit_live_distributed_interpolation_communication
contains
  !> Build the five persistent SLRSET exchange maps in source order.
  !! STATE is a stable caller-owned TARGET record with completed local row
  !! maps. Its five communication owners must be absent. KSTA and KONL are
  !! read-only int32 maps, with first lower bound STATE%NDGSAG and second
  !! lower bound one. The three latitude-region vectors and PROCESS_IDS
  !! are one-based, contiguous, read-only int32 arrays. CONTROL is the same
  !! read-only, message-ready native transform/partition context.
  !! GLOBAL_HALO_POINT_CAPACITY is a caller-qualified positive point bound
  !! for any rank. WORKSPACE_BUDGET_BYTES bounds the three pair/map buffers,
  !! live-count integer metadata and five new persistent owners; parent owners
  !! and the compiler stack are budgeted by the enclosing caller.
  !! CONTROL supplies positive process and region counts and their exact maps.
  !! The enclosing caller collectively admits all bounds/controls before
  !! entry; every rank follows the same protocol. All writable and borrowed
  !! input spans are disjoint. Return 0 completes
  !! the maps; return 1 reports agreed allocation failure; return 2 refuses
  !! unsupported controls before mutation. Source-assigned scalars and
  !! partial persistent allocations remain visible on allocation failure.
  !! The parent owns their rollback. This child releases its three private
  !! buffers and waits any pending count exchange before returning.
  integer(int32) function initialize_live_distributed_interpolation_communication(state, &
                                                                                  ksta, konl, kptrfrstlat, kfrstlat, klstlat, &
                                                                                  process_ids, control, &
                                                                                  global_halo_point_capacity, &
                                                                                  workspace_budget_bytes) result(status)
    type(native_interpolation_state), intent(inout), target :: state
    integer(int32), intent(in), contiguous :: ksta(state%ndgsag:, :), konl(state%ndgsag:, :)
    integer(int32), intent(in), contiguous :: kptrfrstlat(:), kfrstlat(:), klstlat(:), process_ids(:)
    type(native_transform_control), intent(in) :: control
    integer(int64), intent(in) :: global_halo_point_capacity, workspace_budget_bytes
    integer(int32), allocatable :: point_rank(:), outgoing(:), incoming(:)
    integer(int32), allocatable, target :: count_workspace(:)
    integer(int32), pointer, contiguous :: request_counts(:), incoming_counts(:), ones(:), requests(:)
    integer(int32), pointer, contiguous :: receive_prefix(:), send_prefix(:)
    integer(int32) :: first_row, last_row, row, global_row, folded_row, first_lon, row_count, row_offset
    integer(int32) :: lon, canonical_lon, region, ew, map_row, peer, selected_peer, point_index
    integer(int32) :: outgoing_count, incoming_count, position, offset, send_count, active_peers, slot
    integer(int32) :: count_request, local_status, maximum_peers
    integer(int64) :: first64, last64, incoming_capacity, aggregate_upper
    integer :: allocation_error, allocation_error2
    logical :: count_pending
    status = 2_int32
    count_pending = .false.
    if (.not. control%message_ready) return
    if (control%nproc < 1 .or. control%nproc > (huge(0_int32) - 2_int32)/6_int32) return
    if (control%myproc < 1 .or. control%myproc > control%nproc) return
    if (control%regions_ns < 1 .or. control%regions_ew < 1) return
    if (.not. allocated(control%n_regions)) return
    if (.not. allocated(control%ngpset2pe)) return
    if (lbound(control%n_regions, 1) /= 1 .or. size(control%n_regions) /= control%regions_ns) return
    if (any(lbound(control%ngpset2pe) /= 1) .or. &
        any(shape(control%ngpset2pe) /= [control%regions_ew, control%regions_ns])) return
    if (size(process_ids) /= control%nproc) return
    do peer = 1, control%nproc
      if (process_ids(peer) /= peer) return
    end do
    do region = 1, control%regions_ns
      if (control%n_regions(region) < 1 .or. control%n_regions(region) > control%regions_ew) return
      do ew = 1, control%n_regions(region)
        if (control%ngpset2pe(ew, region) < 1 .or. control%ngpset2pe(ew, region) > control%nproc) return
      end do
    end do
    if (size(kptrfrstlat) /= control%regions_ns .or. size(kfrstlat) /= control%regions_ns .or. &
        size(klstlat) /= control%regions_ns) return
    if (size(ksta, 2) /= control%regions_ew .or. size(konl, 2) /= control%regions_ew) return
    if (any(shape(ksta) /= shape(konl))) return
    if (global_halo_point_capacity < 1_int64) return
    ! Pair-buffer indices and prefix sums use the source int32 representation.
    if (global_halo_point_capacity > (int(huge(0_int32), int64) - 1_int64)/ &
        (2_int64*int(control%nproc, int64))) return
    if (workspace_budget_bytes < 1_int64) return
    if (state%naslb1 < 0 .or. int(state%naslb1, int64) > global_halo_point_capacity) return
    if (state%ndglg < 1 .or. state%ndglg > (huge(0_int32) - 1_int32)/2_int32) return
    if (state%nslwiden < 0 .or. state%nslwides < 0) return
    if (allocated(state%nslcomm) .or. allocated(state%nslrecvptr) .or. allocated(state%nslsendptr) .or. &
        allocated(state%nslsendpos) .or. allocated(state%nslrecvpos)) return
    if (.not. allocated(state%nslsta)) return
    if (.not. allocated(state%nslonl)) return
    if (.not. allocated(state%nsloff)) return
    if (.not. allocated(state%nloeng)) return
    first64 = max(max(int(state%myfrstactlat, int64) - int(state%nslwiden, int64), &
                      int(state%ndgsag, int64)) - int(state%nfrstloff, int64), -int(state%nslwiden, int64))
    last64 = min(min(int(state%mylstactlat, int64) + int(state%nslwides, int64), &
                     int(state%ndgeng, int64)) - int(state%nfrstloff, int64), &
                 int(state%ndgenl, int64) + int(state%nslwides, int64))
    if (first64 > last64) return
    if (first64 < int(-huge(0_int32), int64) .or. last64 > int(huge(0_int32), int64)) return
    first_row = int(first64, int32); last_row = int(last64, int32)
    if (first_row < lbound(state%nslsta, 1) .or. last_row > ubound(state%nslsta, 1)) return
    if (first_row < lbound(state%nslonl, 1) .or. last_row > ubound(state%nslonl, 1)) return
    if (first_row < lbound(state%nsloff, 1) .or. last_row > ubound(state%nsloff, 1)) return
    first64 = first64 + int(state%nfrstloff, int64)
    last64 = last64 + int(state%nfrstloff, int64)
    if (first64 < int(lbound(state%nloeng, 1), int64) .or. last64 > int(ubound(state%nloeng, 1), int64)) return
    if (last64 < int(state%ndgsag, int64) .or. last64 > int(state%ndgeng, int64)) return
    if (global_halo_point_capacity > huge(0_int64)/(12_int64*int(control%nproc, int64))) return
    incoming_capacity = int(control%nproc, int64)*global_halo_point_capacity
    aggregate_upper = 16_int64*int(state%naslb1, int64) + 12_int64*incoming_capacity + &
                      36_int64*int(control%nproc, int64) + 16_int64
    if (aggregate_upper > workspace_budget_bytes) return
    ! Acquire the dynamic metadata at the source first allocation boundary.
    allocate (point_rank(0:state%naslb1 - 1), stat=allocation_error)
    allocate (count_workspace(6_int64*int(control%nproc, int64) + 2_int64), stat=allocation_error2)
    local_status = 0_int32
    if (allocation_error /= 0 .or. allocation_error2 /= 0) local_status = 1_int32
    status = agree_distributed_partition_status(control, local_status)
    if (status /= 0_int32) goto 900
    request_counts => count_workspace(1:control%nproc)
    incoming_counts => count_workspace(control%nproc + 1:2*control%nproc)
    ones => count_workspace(2*control%nproc + 1:3*control%nproc)
    requests => count_workspace(3*control%nproc + 1:4*control%nproc)
    receive_prefix => count_workspace(4*control%nproc + 1:5*control%nproc + 1)
    send_prefix => count_workspace(5*control%nproc + 2:6*control%nproc + 2)
    point_rank = -1_int32
    ! Source ownership search: local latitude, longitude, region, east/west.
    do row = first_row, last_row
      global_row = row + state%nfrstloff
      folded_row = fold_latitude(global_row, state%ndglg)
      first_lon = state%nslsta(row); row_count = state%nslonl(row); row_offset = state%nsloff(row)
      if (row_count < 0) call abort_distributed_partition()
      do lon = first_lon, first_lon + row_count - 1
        canonical_lon = source_longitude(lon, state%nloeng(global_row))
        selected_peer = -1_int32
        do region = 1, control%regions_ns
          if (folded_row < kfrstlat(region) .or. folded_row > klstlat(region)) cycle
          map_row = kptrfrstlat(region) + folded_row - kfrstlat(region)
          if (map_row < lbound(ksta, 1) .or. map_row > ubound(ksta, 1)) call abort_distributed_partition()
          do ew = 1, control%n_regions(region)
            if (canonical_lon < ksta(map_row, ew)) cycle
            if (canonical_lon >= ksta(map_row, ew) + konl(map_row, ew)) cycle
            selected_peer = control%ngpset2pe(ew, region)
          end do
        end do
        if (selected_peer < 1 .or. selected_peer > control%nproc) call abort_distributed_partition()
        point_index = lon - first_lon + row_offset
        if (point_index < 0 .or. point_index >= state%naslb1) call abort_distributed_partition()
        point_rank(point_index) = selected_peer
      end do
    end do
    request_counts = 0_int32
    outgoing_count = 0_int32
    do row = first_row, last_row
      first_lon = state%nslsta(row); row_count = state%nslonl(row); row_offset = state%nsloff(row)
      do lon = first_lon, first_lon + row_count - 1
        peer = point_rank(lon - first_lon + row_offset)
        if (peer == control%myproc) cycle
        if (peer < 1 .or. peer > control%nproc) call abort_distributed_partition()
        request_counts(peer) = request_counts(peer) + 1_int32
        outgoing_count = outgoing_count + 1_int32
      end do
    end do
    ones = 1_int32
    incoming_counts = 0_int32
    call mpl_alltoallv(ksendbuf=request_counts, ksendcounts=ones, krecvbuf=incoming_counts, &
                       krecvcounts=ones, kmp_type=JP_NON_BLOCKING_STANDARD, krequest=count_request, cdstring='SLRSET_IPCNTR')
    count_pending = .true.
    ! Reserve both private pair buffers before any point-list send.
    allocate (outgoing(2_int64*int(outgoing_count, int64)), stat=allocation_error)
    allocate (incoming(2_int64*incoming_capacity), stat=allocation_error2)
    local_status = 0_int32
    if (allocation_error /= 0 .or. allocation_error2 /= 0) local_status = 1_int32
    status = agree_distributed_partition_status(control, local_status)
    if (status /= 0_int32) goto 900
    position = 0_int32
    do peer = 1, control%nproc
      if (peer == control%myproc) cycle
      do row = first_row, last_row
        global_row = row + state%nfrstloff
        first_lon = state%nslsta(row); row_count = state%nslonl(row); row_offset = state%nsloff(row)
        do lon = first_lon, first_lon + row_count - 1
          if (point_rank(lon - first_lon + row_offset) /= peer) cycle
          position = position + 1_int32
          outgoing(2*position - 1) = global_row
          outgoing(2*position) = source_longitude(lon, state%nloeng(global_row))
        end do
      end do
    end do
    if (position /= outgoing_count) call abort_distributed_partition()
    send_count = 0_int32; offset = 0_int32
    do peer = 1, control%nproc
      if (request_counts(peer) == 0) cycle
      send_count = send_count + 1_int32
      call mpl_send(outgoing(2*offset + 1:2*(offset + request_counts(peer))), kdest=process_ids(peer), &
                    ktag=2401, kmp_type=JP_NON_BLOCKING_STANDARD, krequest=requests(send_count), &
                    cdstring='SLRSET: IRLSTLAT, IRLSTLON')
      offset = offset + request_counts(peer)
    end do
    call mpl_wait(krequest=count_request, cdstring='SLRSET: WAITALL')
    count_pending = .false.
    incoming_count = 0_int32
    do peer = 1, control%nproc
      if (incoming_counts(peer) < 0 .or. int(incoming_counts(peer), int64) > global_halo_point_capacity) &
        call abort_distributed_partition()
      incoming_count = incoming_count + incoming_counts(peer)
    end do
    if (int(incoming_count, int64) > incoming_capacity) call abort_distributed_partition()
    offset = 0_int32
    do peer = 1, control%nproc
      if (incoming_counts(peer) == 0) cycle
      call mpl_recv(incoming(2*offset + 1:2*(offset + incoming_counts(peer))), ksource=process_ids(peer), &
                    ktag=2401, cdstring='SLRSET: ISLSTLAT, ISLSTLON')
      offset = offset + incoming_counts(peer)
    end do
    call mpl_wait(requests(1:send_count), cdstring='SLRSET: SENDING HALO ICOMBUF')
    receive_prefix(1) = 1_int32; send_prefix(1) = 1_int32; active_peers = 0_int32
    do peer = 1, control%nproc
      receive_prefix(peer + 1) = receive_prefix(peer) + request_counts(peer)
      send_prefix(peer + 1) = send_prefix(peer) + incoming_counts(peer)
      if (ior(request_counts(peer), incoming_counts(peer)) /= 0) active_peers = active_peers + 1_int32
    end do
    state%nslprocs = active_peers
    state%nslrpt = receive_prefix(control%nproc + 1) - 1_int32
    state%nslspt = send_prefix(control%nproc + 1) - 1_int32
    local_status = 1_int32
    acquire_owners: block
      allocate (state%nslcomm(active_peers), stat=allocation_error)
      if (allocation_error /= 0) exit acquire_owners
      allocate (state%nslrecvptr(active_peers + 1), stat=allocation_error)
      if (allocation_error /= 0) exit acquire_owners
      allocate (state%nslsendptr(active_peers + 1), stat=allocation_error)
      if (allocation_error /= 0) exit acquire_owners
      allocate (state%nslsendpos(incoming_count), stat=allocation_error)
      if (allocation_error /= 0) exit acquire_owners
      allocate (state%nslrecvpos(outgoing_count), stat=allocation_error)
      if (allocation_error /= 0) exit acquire_owners
      local_status = 0_int32
    end block acquire_owners
    status = agree_distributed_partition_status(control, local_status)
    if (status /= 0_int32) goto 900
    slot = 0_int32
    do peer = 1, control%nproc
      if (ior(request_counts(peer), incoming_counts(peer)) == 0) cycle
      slot = slot + 1_int32
      state%nslcomm(slot) = peer
      state%nslrecvptr(slot) = receive_prefix(peer)
      state%nslrecvptr(slot + 1) = receive_prefix(peer + 1)
      state%nslsendptr(slot) = send_prefix(peer)
      state%nslsendptr(slot + 1) = send_prefix(peer + 1)
    end do
    do position = 1, incoming_count
      global_row = incoming(2*position - 1); lon = incoming(2*position)
      row = fold_latitude(global_row, state%ndglg) - state%nfrstloff
      if (row < lbound(state%nslsta, 1) .or. row > ubound(state%nslsta, 1)) call abort_distributed_partition()
      if (row < lbound(state%nsloff, 1) .or. row > ubound(state%nsloff, 1)) call abort_distributed_partition()
      state%nslsendpos(position) = state%nsloff(row) + lon - state%nslsta(row) + 1_int32
    end do
    do position = 1, outgoing_count
      global_row = outgoing(2*position - 1); lon = outgoing(2*position)
      row = global_row - state%nfrstloff
      state%nslrecvpos(position) = mod(lon - state%nslsta(row) + state%nloeng(global_row), &
                                       state%nloeng(global_row)) + state%nsloff(row) + 1_int32
    end do
    maximum_peers = active_peers
    call mpl_allreduce(maximum_peers, 'MAX', cdstring='SLRSET:ISLPROCSMX')
    status = 0_int32
900 continue
    if (count_pending) call mpl_wait(krequest=count_request, cdstring='SLRSET: WAITALL')
    if (allocated(point_rank)) deallocate (point_rank)
    if (allocated(outgoing)) deallocate (outgoing)
    if (allocated(incoming)) deallocate (incoming)
    if (allocated(count_workspace)) deallocate (count_workspace)
  end function

  !> Check this live-count entry without MPI, allocation or mutation.
  !! Arguments and units match the owning entry; STATE is read-only.
  !! Return 0 admits the draft bounds and return 2 refuses them. The caller
  !! agrees this value across the same public process group before entry.
  pure integer(int32) function admit_live_distributed_interpolation_communication(state, &
                                                                                  ksta, konl, kptrfrstlat, kfrstlat, klstlat, &
                                                                                  process_ids, control, &
                                                                                  global_halo_point_capacity, &
                                                                                  workspace_budget_bytes) result(status)
    type(native_interpolation_state), intent(in), target :: state
    integer(int32), intent(in), contiguous :: ksta(state%ndgsag:, :), konl(state%ndgsag:, :)
    integer(int32), intent(in), contiguous :: kptrfrstlat(:), kfrstlat(:), klstlat(:), process_ids(:)
    type(native_transform_control), intent(in) :: control
    integer(int64), intent(in) :: global_halo_point_capacity, workspace_budget_bytes
    integer(int32) :: first_row, last_row, peer, region, ew
    integer(int64) :: first64, last64, incoming_capacity, aggregate_upper
    status = 2_int32
    if (.not. control%message_ready) return
    if (control%nproc < 1 .or. control%nproc > (huge(0_int32) - 2_int32)/6_int32) return
    if (control%myproc < 1 .or. control%myproc > control%nproc) return
    if (control%regions_ns < 1 .or. control%regions_ew < 1) return
    if (.not. allocated(control%n_regions)) return
    if (.not. allocated(control%ngpset2pe)) return
    if (lbound(control%n_regions, 1) /= 1 .or. size(control%n_regions) /= control%regions_ns) return
    if (any(lbound(control%ngpset2pe) /= 1) .or. &
        any(shape(control%ngpset2pe) /= [control%regions_ew, control%regions_ns])) return
    if (size(process_ids) /= control%nproc) return
    do peer = 1, control%nproc
      if (process_ids(peer) /= peer) return
    end do
    do region = 1, control%regions_ns
      if (control%n_regions(region) < 1 .or. control%n_regions(region) > control%regions_ew) return
      do ew = 1, control%n_regions(region)
        if (control%ngpset2pe(ew, region) < 1 .or. control%ngpset2pe(ew, region) > control%nproc) return
      end do
    end do
    if (size(kptrfrstlat) /= control%regions_ns .or. size(kfrstlat) /= control%regions_ns .or. &
        size(klstlat) /= control%regions_ns) return
    if (size(ksta, 2) /= control%regions_ew .or. size(konl, 2) /= control%regions_ew) return
    if (any(shape(ksta) /= shape(konl))) return
    if (global_halo_point_capacity < 1_int64) return
    ! Pair-buffer indices and prefix sums use the source int32 representation.
    if (global_halo_point_capacity > (int(huge(0_int32), int64) - 1_int64)/ &
        (2_int64*int(control%nproc, int64))) return
    if (workspace_budget_bytes < 1_int64) return
    if (state%naslb1 < 0 .or. int(state%naslb1, int64) > global_halo_point_capacity) return
    if (state%ndglg < 1 .or. state%ndglg > (huge(0_int32) - 1_int32)/2_int32) return
    if (state%nslwiden < 0 .or. state%nslwides < 0) return
    if (allocated(state%nslcomm) .or. allocated(state%nslrecvptr) .or. allocated(state%nslsendptr) .or. &
        allocated(state%nslsendpos) .or. allocated(state%nslrecvpos)) return
    if (.not. allocated(state%nslsta)) return
    if (.not. allocated(state%nslonl)) return
    if (.not. allocated(state%nsloff)) return
    if (.not. allocated(state%nloeng)) return
    first64 = max(max(int(state%myfrstactlat, int64) - int(state%nslwiden, int64), &
                      int(state%ndgsag, int64)) - int(state%nfrstloff, int64), -int(state%nslwiden, int64))
    last64 = min(min(int(state%mylstactlat, int64) + int(state%nslwides, int64), &
                     int(state%ndgeng, int64)) - int(state%nfrstloff, int64), &
                 int(state%ndgenl, int64) + int(state%nslwides, int64))
    if (first64 > last64) return
    if (first64 < int(-huge(0_int32), int64) .or. last64 > int(huge(0_int32), int64)) return
    first_row = int(first64, int32); last_row = int(last64, int32)
    if (first_row < lbound(state%nslsta, 1) .or. last_row > ubound(state%nslsta, 1)) return
    if (first_row < lbound(state%nslonl, 1) .or. last_row > ubound(state%nslonl, 1)) return
    if (first_row < lbound(state%nsloff, 1) .or. last_row > ubound(state%nsloff, 1)) return
    first64 = first64 + int(state%nfrstloff, int64)
    last64 = last64 + int(state%nfrstloff, int64)
    if (first64 < int(lbound(state%nloeng, 1), int64) .or. last64 > int(ubound(state%nloeng, 1), int64)) return
    if (last64 < int(state%ndgsag, int64) .or. last64 > int(state%ndgeng, int64)) return
    if (global_halo_point_capacity > huge(0_int64)/(12_int64*int(control%nproc, int64))) return
    incoming_capacity = int(control%nproc, int64)*global_halo_point_capacity
    aggregate_upper = 16_int64*int(state%naslb1, int64) + 12_int64*incoming_capacity + &
                      36_int64*int(control%nproc, int64) + 16_int64
    if (aggregate_upper > workspace_budget_bytes) return
    status = 0_int32
  end function

  !> Reflect a polar mimic latitude into the physical global latitude range.
  !! ROW and ROWS are int32 grid indices/counts in the admitted source bounds.
  integer(int32) function fold_latitude(row, rows) result(physical)
    integer(int32), intent(in) :: row, rows
    physical = row
    if (row < 1_int32) then
      physical = 1_int32 - row
    else if (row > rows) then
      physical = 2_int32*rows + 1_int32 - row
    end if
  end function

  !> Apply the source MOD longitude map without changing its sign rule.
  integer(int32) function source_longitude(lon, row_length) result(canonical)
    integer(int32), intent(in) :: lon, row_length
    if (row_length < 1_int32) call abort_distributed_partition()
    canonical = mod(lon - 1_int32 + row_length, row_length) + 1_int32
  end function

  !> Release only the five communication owners, retaining all scalar fields.
  !! STATE is caller-owned INOUT. Repeated release is valid. A failed parent
  !! may use this for its acquired communication prefix; no MPI lifetime ends.
  subroutine release_live_distributed_interpolation_communication(state)
    type(native_interpolation_state), intent(inout) :: state
    if (allocated(state%nslcomm)) deallocate (state%nslcomm)
    if (allocated(state%nslrecvptr)) deallocate (state%nslrecvptr)
    if (allocated(state%nslsendptr)) deallocate (state%nslsendptr)
    if (allocated(state%nslsendpos)) deallocate (state%nslsendpos)
    if (allocated(state%nslrecvpos)) deallocate (state%nslrecvpos)
  end subroutine
end module forecast_live_interpolation_communication
