!> Exchange fixed interpolation fields through the public MPI interface.
!! A halo contains neighbour values owned by other processes. This routine
!! packs their complete FP64 words, waits for messages, then copies them back.
module md2asm_fixed_interpolation_exchange
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer, c_associated
  use mpi_f08
  use ieee_arithmetic, only: ieee_round_type, ieee_nearest, ieee_get_rounding_mode, &
                             ieee_support_underflow_control, ieee_get_underflow_mode, operator(/=)
  use forecast_interpolation_state_types, only: native_interpolation_state
  implicit none
  private
  public :: exchange_fixed_interpolation_halo
  integer, parameter :: maximum_world = 65536
  interface
    function exchange_errno_location() bind(C, name='__errno_location') result(p)
      import c_ptr
      type(c_ptr) :: p
    end function
  end interface
contains
  !> Fill fixed halo fields using live one-based communication maps.
  !! comm is a live mpi_f08 communicator retained by the caller. sl borrows
  !! the native SLCSET/SLRSET maps, with source lower bound1 and exact extents.
  !! field_count is the complete positive int32 buffer field count. mode0
  !! selects all fields; mode1 selects inclusive fixed_fields(1:2). The
  !! synchronise flag retains the optional public barrier. debug must be
  !! false. Increment, demand, switched and reversed routes are not present.
  !! buffer is contiguous real64(0:sl%NASLB1-1,1:at least field_count).
  !! Its fields retain their supplied units. It is caller-owned and disjoint
  !! from sl and every map. All nonselected buffer words remain unchanged.
  !! Public MPI owns transport only. Own loops pack and unpack complete words;
  !! no real field arithmetic is used. The header is an exact FP64 point count.
  !! Message tag2400 and source peer/field/point order are unchanged.
  !! The native generic route permits1:65536 processes and0:world-1 unique
  !! nonself peers. Its retained selected assembly route was world4 only;
  !! each additional operational world needs its own matching map gate.
  !! Two payload arrays and two native MPI request arrays are private. The
  !! optional nonnegative workspace_limit bounds their bytes; default64GiB.
  !! Status2 is collective admission refusal before buffer changes. Status1
  !! is collective allocation failure with every acquired owner released.
  !! Status0 completes all receives, sends and release. An MPI or message
  !! error after communication begins aborts comm, because live requests
  !! cannot outlive the private owners. Extra admission services restore
  !! actual incoming errno; message, allocation and floating flags are natural.
  integer(int32) function exchange_fixed_interpolation_halo(comm, sl, field_count, mode, &
                                                           fixed_fields, synchronise, debug, buffer, workspace_limit) result(status)
    type(MPI_Comm), intent(in) :: comm
    type(native_interpolation_state), intent(in) :: sl
    integer(int32), intent(in) :: field_count, mode, fixed_fields(2)
    logical, intent(in) :: synchronise, debug
    real(real64), contiguous, intent(inout) :: buffer(0:, :)
    integer(int64), intent(in), optional :: workspace_limit
    integer(int64), allocatable, asynchronous :: send_buffer(:), receive_buffer(:)
    type(MPI_Request), allocatable :: send_requests(:), receive_requests(:)
    integer(int64) :: send_words, receive_words, budget, request_bytes, total_bytes
    integer(int64) :: send_offset, receive_offset, total_send, total_receive, cursor
    integer(int64) :: start, finish, point, word, packed_peer, field
    integer(int32) :: first_field, selected_fields, local_status, global_status
    integer :: world, rank, ierr, allocation_status, j, points, message_count, receives, completed
    integer(c_int), pointer :: errno_pointer
    integer(c_int) :: saved_errno
    type(c_ptr) :: errno_address
    status = 2
    errno_address = exchange_errno_location()
    if (.not. c_associated(errno_address)) then
      call abort_exchange(comm)
      return
    end if
    call c_f_pointer(errno_address, errno_pointer)
    saved_errno = errno_pointer
    call MPI_Comm_size(comm, world, ierr)
    if (ierr /= MPI_SUCCESS) call abort_exchange(comm)
    call MPI_Comm_rank(comm, rank, ierr)
    if (ierr /= MPI_SUCCESS) call abort_exchange(comm)
    errno_pointer = saved_errno
    budget = 64_int64*1024_int64**3
    if (present(workspace_limit)) budget = workspace_limit
    call validate_exchange(sl, world, rank, field_count, mode, fixed_fields, debug, buffer, &
                           first_field, selected_fields, send_words, receive_words, local_status)
    if (budget < 0) local_status = 2
    if (local_status == 0) then
      request_bytes = 2_int64*int(sl%NSLPROCS, int64)*int(storage_size(MPI_REQUEST_NULL)/8, int64)
      total_bytes = 8_int64*(send_words + receive_words) + request_bytes
      if (total_bytes > budget) local_status = 2
    end if
    call agree_exchange_status(comm, local_status, global_status)
    if (global_status /= 0) then
      status = global_status
      return
    end if
    allocate (send_buffer(0:send_words - 1), receive_buffer(0:receive_words - 1), &
              send_requests(sl%NSLPROCS), receive_requests(sl%NSLPROCS), stat=allocation_status)
    local_status = 0
    if (allocation_status /= 0) local_status = 1
    call agree_exchange_status(comm, local_status, global_status)
    if (global_status /= 0) then
      call release_exchange()
      status = global_status
      return
    end if
    if (synchronise) then
      call MPI_Barrier(comm, ierr)
      if (ierr /= MPI_SUCCESS) call abort_exchange(comm)
    end if
    receive_requests = MPI_REQUEST_NULL
    send_requests = MPI_REQUEST_NULL
    total_receive = 0
    receives = 0
    do j = 1, sl%NSLPROCS
      points = sl%NSLRECVPTR(j + 1) - sl%NSLRECVPTR(j)
      if (points == 0) cycle
      receive_offset = total_receive*int(selected_fields, int64)
      message_count = points*selected_fields + 1
      call MPI_Irecv(receive_buffer(receive_offset:receive_offset + int(message_count, int64) - 1), &
                     message_count, MPI_DOUBLE_PRECISION, sl%NSLCOMM(j) - 1, 2400, comm, receive_requests(j), ierr)
      if (ierr /= MPI_SUCCESS) call abort_exchange(comm)
      total_receive = total_receive + int(points, int64) + 1_int64
      receives = receives + 1
    end do
    total_send = 0
    do j = 1, sl%NSLPROCS
      points = sl%NSLSENDPTR(j + 1) - sl%NSLSENDPTR(j)
      if (points == 0) cycle
      send_offset = total_send*int(selected_fields, int64)
      send_buffer(send_offset) = transfer(real(points, real64), 0_int64)
      cursor = send_offset + 1_int64
      start = int(sl%NSLSENDPTR(j), int64)
      finish = int(sl%NSLSENDPTR(j + 1), int64) - 1_int64
      do field = int(first_field, int64), int(first_field, int64) + int(selected_fields, int64) - 1_int64
        do point = start, finish
          send_buffer(cursor) = transfer(buffer(sl%NSLSENDPOS(point) - 1, field), 0_int64)
          cursor = cursor + 1_int64
        end do
      end do
      message_count = points*selected_fields + 1
      call MPI_Isend(send_buffer(send_offset:send_offset + int(message_count, int64) - 1), &
                     message_count, MPI_DOUBLE_PRECISION, sl%NSLCOMM(j) - 1, 2400, comm, send_requests(j), ierr)
      if (ierr /= MPI_SUCCESS) call abort_exchange(comm)
      total_send = total_send + int(points, int64) + 1_int64
    end do
    do completed = 1, receives
      call MPI_Waitany(sl%NSLPROCS, receive_requests, j, MPI_STATUS_IGNORE, ierr)
      if (ierr /= MPI_SUCCESS) call abort_exchange(comm)
      if (j < 1 .or. j > sl%NSLPROCS) call abort_exchange(comm)
      points = sl%NSLRECVPTR(j + 1) - sl%NSLRECVPTR(j)
      if (points < 1) call abort_exchange(comm)
      packed_peer = 0
      do field = 1, j - 1
        word = int(sl%NSLRECVPTR(field + 1), int64) - int(sl%NSLRECVPTR(field), int64)
        if (word > 0) packed_peer = packed_peer + word + 1_int64
      end do
      receive_offset = packed_peer*int(selected_fields, int64)
      if (int(transfer(receive_buffer(receive_offset), 0.0_real64), int32) /= points) call abort_exchange(comm)
      cursor = receive_offset + 1_int64
      start = int(sl%NSLRECVPTR(j), int64)
      finish = int(sl%NSLRECVPTR(j + 1), int64) - 1_int64
      do field = int(first_field, int64), int(first_field, int64) + int(selected_fields, int64) - 1_int64
        do point = start, finish
          buffer(sl%NSLRECVPOS(point) - 1, field) = transfer(receive_buffer(cursor), 0.0_real64)
          cursor = cursor + 1_int64
        end do
      end do
    end do
    call MPI_Waitall(sl%NSLPROCS, send_requests, MPI_STATUSES_IGNORE, ierr)
    if (ierr /= MPI_SUCCESS) call abort_exchange(comm)
    call release_exchange()
    status = 0
  contains
    subroutine release_exchange()
      if (allocated(receive_requests)) deallocate (receive_requests)
      if (allocated(send_requests)) deallocate (send_requests)
      if (allocated(receive_buffer)) deallocate (receive_buffer)
      if (allocated(send_buffer)) deallocate (send_buffer)
    end subroutine
  end function

  subroutine validate_exchange(sl, world, rank, field_count, mode, fixed_fields, debug, buffer, &
                               first_field, selected_fields, send_words, receive_words, status)
    type(native_interpolation_state), intent(in) :: sl
    integer, intent(in) :: world, rank
    integer(int32), intent(in) :: field_count, mode, fixed_fields(2)
    logical, intent(in) :: debug
    real(real64), intent(in) :: buffer(0:, :)
    integer(int32), intent(out) :: first_field, selected_fields, status
    integer(int64), intent(out) :: send_words, receive_words
    integer(int64) :: send_total, receive_total, points, peer_rank
    integer(int64) :: seen((maximum_world + 63)/64)
    integer :: j, slot, bit
    status = 2
    first_field = 1
    selected_fields = 0
    send_words = 0
    receive_words = 0
    if (world < 1 .or. world > maximum_world) return
    if (rank < 0 .or. rank >= world) return
    if (debug) return
    if (sl%NASLB1 < 1 .or. field_count < 1) return
    if (size(buffer, 1, kind=int64) /= int(sl%NASLB1, int64)) return
    if (size(buffer, 2, kind=int64) < int(field_count, int64)) return
    if (int(sl%NASLB1, int64) > huge(0_int64)/(8_int64*int(field_count, int64))) return
    if (mode < 0 .or. mode > 1) return
    selected_fields = field_count
    if (mode == 1) then
      if (fixed_fields(1) < 1 .or. fixed_fields(2) < fixed_fields(1) .or. fixed_fields(2) > field_count) return
      first_field = fixed_fields(1)
      selected_fields = fixed_fields(2) - fixed_fields(1) + 1
    end if
    if (sl%NSLPROCS < 0 .or. sl%NSLPROCS >= world) return
    if (sl%NSLSPT < 0 .or. sl%NSLRPT < 0) return
    if (.not. exact_map(sl%NSLSENDPOS, int(sl%NSLSPT, int64))) return
    if (.not. exact_map(sl%NSLRECVPOS, int(sl%NSLRPT, int64))) return
    if (.not. exact_map(sl%NSLSENDPTR, int(sl%NSLPROCS, int64) + 1_int64)) return
    if (.not. exact_map(sl%NSLRECVPTR, int(sl%NSLPROCS, int64) + 1_int64)) return
    if (.not. exact_map(sl%NSLCOMM, int(sl%NSLPROCS, int64))) return
    if (sl%NSLSENDPTR(1) /= 1 .or. sl%NSLRECVPTR(1) /= 1) return
    if (int(sl%NSLSENDPTR(sl%NSLPROCS + 1), int64) /= int(sl%NSLSPT, int64) + 1_int64) return
    if (int(sl%NSLRECVPTR(sl%NSLPROCS + 1), int64) /= int(sl%NSLRPT, int64) + 1_int64) return
    seen = 0_int64
    send_total = 0
    receive_total = 0
    do j = 1, sl%NSLPROCS
      peer_rank = int(sl%NSLCOMM(j), int64) - 1_int64
      if (peer_rank < 0 .or. peer_rank >= world .or. peer_rank == rank) return
      slot = int(peer_rank/64_int64) + 1
      bit = int(mod(peer_rank, 64_int64))
      if (btest(seen(slot), bit)) return
      seen(slot) = ibset(seen(slot), bit)
      points = int(sl%NSLSENDPTR(j + 1), int64) - int(sl%NSLSENDPTR(j), int64)
      if (points < 0) return
      if (points > 0) send_total = send_total + points + 1_int64
      points = int(sl%NSLRECVPTR(j + 1), int64) - int(sl%NSLRECVPTR(j), int64)
      if (points < 0) return
      if (points > 0) receive_total = receive_total + points + 1_int64
    end do
    send_total = send_total*int(selected_fields, int64)
    receive_total = receive_total*int(selected_fields, int64)
    if (send_total >= int(huge(0_int32), int64) .or. receive_total >= int(huge(0_int32), int64)) return
    send_words = send_total + 1_int64
    receive_words = receive_total + 1_int64
    do j = 1, sl%NSLSPT
      if (sl%NSLSENDPOS(j) < 1 .or. sl%NSLSENDPOS(j) > sl%NASLB1) return
    end do
    do j = 1, sl%NSLRPT
      if (sl%NSLRECVPOS(j) < 1 .or. sl%NSLRECVPOS(j) > sl%NASLB1) return
    end do
    if (.not. exchange_environment_ready()) return
    status = 0
  end subroutine

  logical function exact_map(values, count)
    integer(int32), allocatable, intent(in) :: values(:)
    integer(int64), intent(in) :: count
    exact_map = .false.
    if (.not. allocated(values)) return
    if (lbound(values, 1) /= 1 .or. size(values, kind=int64) /= count) return
    exact_map = .true.
  end function

  subroutine agree_exchange_status(comm, local_status, global_status)
    type(MPI_Comm), intent(in) :: comm
    integer(int32), intent(in) :: local_status
    integer(int32), intent(out) :: global_status
    integer(c_int), pointer :: errno_pointer
    integer(c_int) :: saved_errno
    type(c_ptr) :: address
    integer :: ierr
    address = exchange_errno_location()
    if (.not. c_associated(address)) call abort_exchange(comm)
    call c_f_pointer(address, errno_pointer)
    saved_errno = errno_pointer
    call MPI_Allreduce(local_status, global_status, 1, MPI_INTEGER4, MPI_MAX, comm, ierr)
    if (ierr /= MPI_SUCCESS) call abort_exchange(comm)
    errno_pointer = saved_errno
  end subroutine

  subroutine abort_exchange(comm)
    type(MPI_Comm), intent(in) :: comm
    integer :: ierr
    call MPI_Abort(comm, 3, ierr)
    error stop 'Interpolation exchange cannot return with incomplete messages'
  end subroutine

  logical function exchange_environment_ready()
    type(ieee_round_type) :: rounding
    logical :: gradual
    real(real64), volatile :: minimum_normal, half_value, subnormal_probe
    exchange_environment_ready = .false.
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) return
    if (ieee_support_underflow_control(0.0_real64)) then
      call ieee_get_underflow_mode(gradual)
      if (.not. gradual) return
    else
      minimum_normal = tiny(0.0_real64)
      half_value = 0.5_real64
      subnormal_probe = minimum_normal*half_value
      if (transfer(subnormal_probe, 0_int64) /= ibset(0_int64, 51)) return
    end if
    exchange_environment_ready = .true.
  end function
end module md2asm_fixed_interpolation_exchange
