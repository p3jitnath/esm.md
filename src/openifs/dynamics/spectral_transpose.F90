module md2asm_spectral_transposes
  !! Copy spectral fields between complete-level and local-mode layouts.
  !!
  !! The copies preserve the generated TRSTOM/TRMTOS ring, message headers,
  !! coefficient order and level order. No floating-point reduction occurs.
  !! The caller supplies initialized partition maps and owns all field arrays.
  use iso_fortran_env, only: int32, int64, real64
  use mpi_f08
  implicit none
  private
  public :: spectral_transpose_layout, transpose_spectral_to_modes
  public :: transpose_modes_to_spectral, agree_spectral_partition_status

  type :: spectral_transpose_layout
    !! Prefix maps use one-based indices and include the final sentinel.
    integer(int32) :: phase = 0, world = 0, rank_zero_based = -1
    integer(int32) :: horizontal_peers = 0, vertical_peers = 0
    integer(int32) :: horizontal_index = 0, vertical_index = 0
    integer(int32) :: maximum_degree = 0, global_levels = 0, local_levels = 0
    integer(int32) :: spectral_coefficients = 0, local_columns = 0
    logical :: geometry_matches = .false., hooks_disabled = .false.
    integer(int32), allocatable :: coefficient_start(:), level_start(:)
    integer(int32), allocatable :: pressure_partition(:)
  end type
  type :: peer_message
    real(real64), allocatable :: send(:), receive(:)
    integer :: coefficient_offset = 0, coefficient_count = 0
    integer :: level_offset = 0, level_count = 0
  end type
contains
  subroutine agree_spectral_partition_status(comm, local_status, global_status)
    !! Agree a typed status before allocation or distributed field writes.
    type(MPI_Comm), intent(in) :: comm
    integer(int32), intent(in) :: local_status
    integer(int32), intent(out) :: global_status
    integer :: ierr
    call MPI_Allreduce(local_status, global_status, 1, MPI_INTEGER4, MPI_MAX, comm, ierr)
    call require_mpi(comm, ierr)
  end subroutine

  subroutine transpose_spectral_to_modes(layout, comm, spectral, modes, status)
    !! Copy spectral(global levels, local columns) into modes(local levels,
    !! complete coefficients). Both arrays are contiguous FP64 owners.
    type(spectral_transpose_layout), intent(in) :: layout
    type(MPI_Comm), intent(in) :: comm
    real(real64), contiguous, target, intent(inout) :: spectral(:, :), modes(:, :)
    integer(int32), intent(out) :: status
    real(real64), pointer, contiguous :: local_fields(:, :, :), column_fields(:, :, :)
    local_fields(1:size(modes, 1), 1:size(modes, 2), 1:1) => modes
    column_fields(1:size(spectral, 1), 1:size(spectral, 2), 1:1) => spectral
    call transpose_channels(layout, comm, local_fields, column_fields, 1, status)
  end subroutine

  subroutine transpose_modes_to_spectral(layout, comm, modes, spectral, status)
    !! Reverse the same copy without changing any numerical value.
    type(spectral_transpose_layout), intent(in) :: layout
    type(MPI_Comm), intent(in) :: comm
    real(real64), contiguous, target, intent(inout) :: modes(:, :), spectral(:, :)
    integer(int32), intent(out) :: status
    real(real64), pointer, contiguous :: local_fields(:, :, :), column_fields(:, :, :)
    local_fields(1:size(modes, 1), 1:size(modes, 2), 1:1) => modes
    column_fields(1:size(spectral, 1), 1:size(spectral, 2), 1:1) => spectral
    call transpose_channels(layout, comm, local_fields, column_fields, 0, status)
  end subroutine

  subroutine transpose_channels(c, comm, local_fields, column_fields, direction, status)
    !! Port the generated divergence-only pressure copy.
    !!
    !! direction=1 is TRSTOM; direction=0 is TRMTOS. Channel order is fixed
    !! before entry. The pressure solver selects one divergence channel.
    type(spectral_transpose_layout), intent(in) :: c
    type(MPI_Comm), intent(in) :: comm
    real(real64), contiguous, intent(inout) :: local_fields(:, :, :), column_fields(:, :, :)
    integer, intent(in) :: direction
    integer(int32), intent(out) :: status
    type(peer_message), allocatable :: peers(:)
    type(MPI_Request), allocatable :: sends(:), receives(:)
    type(MPI_Status), allocatable :: receive_status(:)
    integer :: ierr, world, rank, self, v, peer, ring, base, tag, channels, allocation_status
    integer :: k, l, f, co, lo, nc, nl, position, expected_count, actual_count
    integer(int32) :: local_status
    integer(int64) :: send_count, receive_count, total_bytes, metadata_bytes
    logical :: initialized

    status = 2
    call MPI_Initialized(initialized, ierr)
    if (ierr /= MPI_SUCCESS .or. .not. initialized) return
    call MPI_Comm_size(comm, world, ierr); call require_mpi(comm, ierr)
    call MPI_Comm_rank(comm, rank, ierr); call require_mpi(comm, ierr)
    local_status = 2
    if (c%phase /= 7 .or. .not. c%geometry_matches .or. .not. c%hooks_disabled) goto 100
    if (c%world /= world .or. c%rank_zero_based /= rank) goto 100
    if (world < 1 .or. world > 65536) goto 100
    if (c%horizontal_peers < 1 .or. c%vertical_peers < 1) goto 100
    if (int(c%horizontal_peers, int64)*c%vertical_peers /= world) goto 100
    if (c%horizontal_index < 1 .or. c%horizontal_index > c%horizontal_peers) goto 100
    if (c%vertical_index < 1 .or. c%vertical_index > c%vertical_peers) goto 100
    if ((c%horizontal_index - 1)*c%vertical_peers + c%vertical_index /= rank + 1) goto 100
    if (c%maximum_degree < 1 .or. c%maximum_degree > 8191) goto 100
    if (c%global_levels < 1 .or. c%global_levels > 512) goto 100
    if (c%local_levels < 0 .or. c%local_levels > c%global_levels) goto 100
    if (c%vertical_peers > c%global_levels + 1) goto 100
    if (c%spectral_coefficients < 0 .or. c%local_columns < 0) goto 100
    if (.not. allocated(c%coefficient_start) .or. .not. allocated(c%level_start)) goto 100
    if (.not. allocated(c%pressure_partition)) goto 100
    v = c%vertical_peers
    if (size(c%coefficient_start) /= v + 1 .or. size(c%level_start) /= v + 1) goto 100
    if (size(c%pressure_partition) /= v) goto 100
    if (c%coefficient_start(1) /= 1 .or. c%level_start(1) /= 1) goto 100
    if (int(c%coefficient_start(v + 1), int64) /= int(c%spectral_coefficients, int64) + 1) goto 100
    if (c%level_start(v + 1) /= c%global_levels + 1) goto 100
    if (any(c%coefficient_start < 1) .or. any(c%level_start < 1)) goto 100
    if (any(c%coefficient_start(2:) < c%coefficient_start(:v))) goto 100
    if (any(c%level_start(2:) < c%level_start(:v))) goto 100
    if (any(c%pressure_partition < 0) .or. any(c%pressure_partition > 1)) goto 100
    if (sum(c%pressure_partition) /= 1) goto 100
    self = c%vertical_index
    if (c%coefficient_start(self + 1) - c%coefficient_start(self) /= c%local_columns) goto 100
    if (c%level_start(self + 1) - c%level_start(self) /= c%local_levels) goto 100
    if (size(local_fields, 1) < c%local_levels) goto 100
    if (size(local_fields, 2) /= c%spectral_coefficients) goto 100
    if (size(column_fields, 1) < c%global_levels .or. size(column_fields, 2) < c%local_columns) goto 100
    if (v == 1 .and. size(column_fields, 2) /= c%local_columns) goto 100
    channels = size(local_fields, 3)
    if (channels < 1 .or. channels > 4096 .or. size(column_fields, 3) /= channels) goto 100
    if (direction /= 0 .and. direction /= 1) goto 100
    metadata_bytes = 48_int64*channels + int(v, int64)*92 + 15
    total_bytes = metadata_bytes
    do peer = 1, v
      if (peer == self) cycle
      nc = c%coefficient_start(peer + 1) - c%coefficient_start(peer)
      nl = c%level_start(peer + 1) - c%level_start(peer)
      if (direction == 0) then
        send_count = int(c%local_levels, int64)*channels*nc
        receive_count = int(nl, int64)*channels*c%local_columns
      else
        send_count = int(nl, int64)*channels*c%local_columns
        receive_count = int(c%local_levels, int64)*channels*nc
      end if
      if (send_count > int(huge(1) - 2, int64) .or. receive_count > int(huge(1) - 2, int64)) goto 100
      if (send_count > 0) total_bytes = total_bytes + 8*(send_count + 2)
      if (receive_count > 0) total_bytes = total_bytes + 8*(receive_count + 2)
    end do
    if (total_bytes > 8589934592_int64) goto 100
    local_status = 0
100 call agree_spectral_partition_status(comm, local_status, status)
    if (status /= 0) return

    allocate (peers(v), sends(v), receives(v), receive_status(v), stat=allocation_status)
    local_status = 0
    if (allocation_status /= 0) local_status = 1
    call agree_spectral_partition_status(comm, local_status, status)
    if (status /= 0) return
    sends = MPI_REQUEST_NULL; receives = MPI_REQUEST_NULL
    do peer = 1, v
      peers(peer)%coefficient_offset = c%coefficient_start(peer) - 1
      peers(peer)%coefficient_count = c%coefficient_start(peer + 1) - c%coefficient_start(peer)
      peers(peer)%level_offset = c%level_start(peer) - 1
      peers(peer)%level_count = c%level_start(peer + 1) - c%level_start(peer)
      if (peer == self) cycle
      nc = peers(peer)%coefficient_count; nl = peers(peer)%level_count
      if (direction == 0) then
        send_count = int(c%local_levels, int64)*channels*nc
        receive_count = int(nl, int64)*channels*c%local_columns
      else
        send_count = int(nl, int64)*channels*c%local_columns
        receive_count = int(c%local_levels, int64)*channels*nc
      end if
      if (send_count > 0) then
        allocate (peers(peer)%send(int(send_count) + 2), stat=allocation_status)
        if (allocation_status /= 0) local_status = 1
      end if
      if (receive_count > 0) then
        allocate (peers(peer)%receive(int(receive_count) + 2), stat=allocation_status)
        if (allocation_status /= 0) local_status = 1
      end if
    end do
    call agree_spectral_partition_status(comm, local_status, status)
    if (status /= 0) return

    co = c%coefficient_start(self) - 1; lo = c%level_start(self) - 1
    do f = 1, channels
      do k = 1, c%local_columns
        do l = 1, c%local_levels
          if (direction == 0) then
            column_fields(lo + l, k, f) = local_fields(l, co + k, f)
          else
            local_fields(l, co + k, f) = column_fields(lo + l, k, f)
          end if
        end do
      end do
    end do
    if (v == 1) then
      status = 0
      return
    end if

    base = (c%horizontal_index - 1)*v
    tag = 1000 + direction*200
    ! Retain the backward receive ring and forward send ring.
    do ring = 1, v - 1
      peer = modulo(self - 1 + v - ring, v) + 1
      if (.not. allocated(peers(peer)%receive)) cycle
      call MPI_Irecv(peers(peer)%receive, size(peers(peer)%receive), MPI_DOUBLE_PRECISION, &
                     base + peer - 1, tag, comm, receives(peer), ierr)
      call require_mpi(comm, ierr)
    end do
    ! Complete every message before the first source send.
    do ring = 1, v - 1
      peer = modulo(self - 1 + ring, v) + 1
      if (.not. allocated(peers(peer)%send)) cycle
      peers(peer)%send(1) = 1.0_real64
      if (direction == 0) then
        peers(peer)%send(2) = real(peers(peer)%coefficient_count, real64)
        nc = peers(peer)%coefficient_count; co = peers(peer)%coefficient_offset
        nl = c%local_levels; lo = 0
      else
        peers(peer)%send(2) = real(c%local_columns, real64)
        nc = c%local_columns; co = 0
        nl = peers(peer)%level_count; lo = peers(peer)%level_offset
      end if
      position = 2
      do k = 1, nc
        do f = 1, channels
          do l = 1, nl
            position = position + 1
            if (direction == 0) then
              peers(peer)%send(position) = local_fields(l, co + k, f)
            else
              peers(peer)%send(position) = column_fields(lo + l, k, f)
            end if
          end do
        end do
      end do
      if (position /= size(peers(peer)%send)) call communication_fatal(comm)
    end do
    do ring = 1, v - 1
      peer = modulo(self - 1 + ring, v) + 1
      if (.not. allocated(peers(peer)%send)) cycle
      call MPI_Isend(peers(peer)%send, size(peers(peer)%send), MPI_DOUBLE_PRECISION, &
                     base + peer - 1, tag, comm, sends(peer), ierr)
      call require_mpi(comm, ierr)
    end do
    call MPI_Waitall(v, receives, receive_status, ierr)
    call require_mpi(comm, ierr)
    do ring = 1, v - 1
      peer = modulo(self - 1 + v - ring, v) + 1
      if (.not. allocated(peers(peer)%receive)) cycle
      expected_count = size(peers(peer)%receive)
      call MPI_Get_count(receive_status(peer), MPI_DOUBLE_PRECISION, actual_count, ierr)
      call require_mpi(comm, ierr)
      if (actual_count /= expected_count) call communication_fatal(comm)
      if (transfer(peers(peer)%receive(1), 0_int64) /= transfer(1.0_real64, 0_int64)) &
        call communication_fatal(comm)
      if (direction == 0) then
        nc = c%local_columns; co = 0
        nl = peers(peer)%level_count; lo = peers(peer)%level_offset
      else
        nc = peers(peer)%coefficient_count; co = peers(peer)%coefficient_offset
        nl = c%local_levels; lo = 0
      end if
      if (transfer(peers(peer)%receive(2), 0_int64) /= transfer(real(nc, real64), 0_int64)) &
        call communication_fatal(comm)
      position = 2
      do k = 1, nc
        do f = 1, channels
          do l = 1, nl
            position = position + 1
            if (direction == 0) then
              column_fields(lo + l, k, f) = peers(peer)%receive(position)
            else
              local_fields(l, co + k, f) = peers(peer)%receive(position)
            end if
          end do
        end do
      end do
      if (position /= expected_count) call communication_fatal(comm)
    end do
    call MPI_Waitall(v, sends, MPI_STATUSES_IGNORE, ierr)
    call require_mpi(comm, ierr)
    status = 0
  end subroutine

  subroutine require_mpi(comm, ierr)
    type(MPI_Comm), intent(in) :: comm
    integer, intent(in) :: ierr
    if (ierr /= MPI_SUCCESS) call communication_fatal(comm)
  end subroutine

  subroutine communication_fatal(comm)
    type(MPI_Comm), intent(in) :: comm
    integer :: ierr
    call MPI_Abort(comm, 3, ierr)
    error stop 'Spectral copy MPI failure'
  end subroutine
end module md2asm_spectral_transposes
