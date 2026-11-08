module forecast_runtime_spectral_transposes
  !! Exchange selected FP64 fields between level and spectral-column storage.
  !!
  !! Field targets remain owned by the caller. The two field views and the
  !! canonical partition must outlive this call. Pointer lower bounds are
  !! retained; the compiler owns each descriptor. Payload values are copied
  !! without arithmetic. A live caller-owned MPI communicator is required.
  use iso_fortran_env, only: int32, int64, real64
  use mpi_f08
  use yomhook, only: lhook
  use md2asm_spectral_transposes, only: spectral_transpose_layout
  implicit none
  private
  public :: native_runtime_spectral_fields
  public :: transpose_runtime_modes_to_spectral, transpose_runtime_spectral_to_modes

  type :: native_runtime_spectral_fields
    !! Rank-two fields have (levels,coefficients). GFL and selected fields
    !! add a final field index. Pressure has no level index. The local
    !! selected-field arrays retain all candidates; column arrays are packed.
    real(real64), pointer :: vorticity(:, :) => null(), divergence(:, :) => null()
    real(real64), pointer :: temperature(:, :) => null()
    real(real64), pointer :: pressure_departure(:, :) => null(), vertical_departure(:, :) => null()
    real(real64), pointer :: gravity_wave(:, :) => null(), auxiliary(:, :) => null()
    real(real64), pointer :: gfl(:, :, :) => null(), selected_three_dimensional(:, :, :) => null()
    real(real64), pointer :: surface_pressure(:) => null(), selected_two_dimensional(:, :) => null()
  end type
  type :: field_channel
    real(real64), pointer :: local(:, :) => null(), columns(:, :) => null()
  end type
  type :: peer_message
    real(real64), pointer :: send(:) => null(), receive(:) => null()
    integer :: coefficient_offset = 0, coefficient_count = 0, level_offset = 0, level_count = 0
    integer :: send_count = 0, receive_count = 0
  end type
contains
  !> Copy local-level fields into complete-level spectral columns.
  !! Selection masks are dimensionless logical arrays with source words0/1.
  !! Nonhydrostatic and gravity-wave controls select their source channels.
  !! Return0 on success,1 for allocation failure or2 for refused inputs.
  integer(int32) function transpose_runtime_modes_to_spectral(layout, comm, local, columns, &
                                                       nonhydrostatic, gravity_wave_fields, selection3d, selection2d) result(status)
    type(spectral_transpose_layout), intent(in) :: layout
    type(MPI_Comm), intent(in) :: comm
    type(native_runtime_spectral_fields), intent(in) :: local, columns
    logical, intent(in) :: nonhydrostatic, gravity_wave_fields, selection3d(:), selection2d(:)
    status = transpose_runtime_channels(layout, comm, local, columns, nonhydrostatic, &
                                        gravity_wave_fields, selection3d, selection2d, 0)
  end function

  !> Copy complete-level spectral columns into local-level fields.
  !! A present need_surface argument retains the source pressure prerequisites,
  !! including when its value is false. True requests pressure replication.
  integer(int32) function transpose_runtime_spectral_to_modes(layout, comm, local, columns, &
                                         nonhydrostatic, gravity_wave_fields, selection3d, selection2d, need_surface) result(status)
    type(spectral_transpose_layout), intent(in) :: layout
    type(MPI_Comm), intent(in) :: comm
    type(native_runtime_spectral_fields), intent(in) :: local, columns
    logical, intent(in) :: nonhydrostatic, gravity_wave_fields, selection3d(:), selection2d(:)
    logical, optional, intent(in) :: need_surface
    status = transpose_runtime_channels(layout, comm, local, columns, nonhydrostatic, &
                                        gravity_wave_fields, selection3d, selection2d, 1, need_surface)
  end function

  integer(int32) function transpose_runtime_channels(c, comm, local, columns, nonhydrostatic, &
                                              gravity_wave_fields, selection3d, selection2d, direction, need_surface) result(status)
    type(spectral_transpose_layout), intent(in) :: c
    type(MPI_Comm), intent(in) :: comm
    type(native_runtime_spectral_fields), intent(in) :: local, columns
    logical, intent(in) :: nonhydrostatic, gravity_wave_fields, selection3d(:), selection2d(:)
    integer, intent(in) :: direction
    logical, optional, intent(in) :: need_surface
    type(field_channel), allocatable :: channel(:)
    type(peer_message), allocatable :: peers(:)
    type(MPI_Request), allocatable :: sends(:), receives(:)
    type(MPI_Status), allocatable :: receive_status(:)
    real(real64), allocatable, target :: message_storage(:)
    real(real64), pointer :: local_pressure(:), column_pressure(:)
    real(real64), pointer :: local_slice(:, :), column_slice(:, :)
    real(real64), pointer :: local_pressure_slice(:), column_pressure_slice(:)
    type(field_channel) :: channel_size
    type(peer_message) :: peer_size
    type(MPI_Request) :: request_size
    type(MPI_Status) :: status_size
    integer :: ierr, world, rank, v, self, nchannels, capacity, ngfl, n3, n2, nselected, k, j, f, packed
    integer :: alloc_status, peer, ring, base, tag, nc, nl, co, lo, actual_count, position
    integer(int32) :: local_status
    integer(int64) :: send_words, receive_words, total_words, total_bytes, next_word, metadata_bytes
    logical :: initialized, active_pressure, presence_flag, direct_pressure, need
    logical :: self_owns, peer_owns, send_pressure, receive_pressure, header_has_pressure
    real(real64) :: expected_header, expected_coefficients

    status = 2
    nullify (local_pressure, column_pressure)
    call MPI_Initialized(initialized, ierr)
    if (ierr /= MPI_SUCCESS) return
    if (.not. initialized) return
    call MPI_Comm_size(comm, world, ierr); call require_mpi(comm, ierr)
    call MPI_Comm_rank(comm, rank, ierr); call require_mpi(comm, ierr)
    local_status = 2
    capacity = 0; ngfl = 0; n3 = 0; n2 = 0; need = .false.
    if (c%phase /= 7) goto 100
    if (.not. c%geometry_matches) goto 100
    if (.not. c%hooks_disabled) goto 100
    if (transfer(lhook, 0_int32) /= 0) goto 100
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
    if (.not. allocated(c%coefficient_start)) goto 100
    if (.not. allocated(c%level_start)) goto 100
    if (.not. allocated(c%pressure_partition)) goto 100
    v = c%vertical_peers; self = c%vertical_index
    if (size(c%coefficient_start) < v + 1 .or. size(c%level_start) < v + 1) goto 100
    if (size(c%pressure_partition) < v) goto 100
    if (c%coefficient_start(1) /= 1 .or. c%level_start(1) /= 1) goto 100
    if (int(c%coefficient_start(v + 1), int64) /= int(c%spectral_coefficients, int64) + 1) goto 100
    if (c%level_start(v + 1) /= c%global_levels + 1) goto 100
    if (any(c%coefficient_start(1:v + 1) < 1)) goto 100
    if (any(c%level_start(1:v + 1) < 1)) goto 100
    if (any(c%coefficient_start(2:v + 1) < c%coefficient_start(1:v))) goto 100
    if (any(c%level_start(2:v + 1) < c%level_start(1:v))) goto 100
    if (any(c%pressure_partition(1:v) < 0) .or. any(c%pressure_partition(1:v) > 1)) goto 100
    if (sum(c%pressure_partition(1:v)) /= 1) goto 100
    if (c%coefficient_start(self + 1) - c%coefficient_start(self) /= c%local_columns) goto 100
    if (c%level_start(self + 1) - c%level_start(self) /= c%local_levels) goto 100
    if (.not. canonical_logical(nonhydrostatic)) goto 100
    if (.not. canonical_logical(gravity_wave_fields)) goto 100
    if (present(need_surface)) then
      if (direction /= 1) goto 100
      if (.not. canonical_logical(need_surface)) goto 100
      need = need_surface
    end if
    if (associated(local%gfl)) ngfl = size(local%gfl, 3)
    if (associated(local%selected_three_dimensional)) n3 = size(local%selected_three_dimensional, 3)
    if (associated(local%selected_two_dimensional)) n2 = size(local%selected_two_dimensional, 2)
    if (ngfl < 0 .or. ngfl > 4096 .or. n3 < 0 .or. n3 > 4096 .or. n2 < 0 .or. n2 > 4096) goto 100
    capacity = 7 + ngfl + n3
    if (capacity > 4096) goto 100
    local_status = 0
100 call agree_status(comm, local_status, status)
    if (status /= 0) return

    allocate (channel(capacity), stat=alloc_status)
    local_status = 0
    if (alloc_status /= 0) local_status = 1
    call agree_status(comm, local_status, status)
    if (status /= 0) return

    local_status = 0; nchannels = 0
    call add_channel(local%vorticity, columns%vorticity)
    call add_channel(local%divergence, columns%divergence)
    call add_channel(local%temperature, columns%temperature)
    if (nonhydrostatic) then
      call add_channel(local%pressure_departure, columns%pressure_departure)
      call add_channel(local%vertical_departure, columns%vertical_departure)
    end if
    if (gravity_wave_fields) call add_channel(local%gravity_wave, columns%gravity_wave)
    call add_channel(local%auxiliary, columns%auxiliary)
    if (associated(local%gfl)) then
      if (ngfl > 0) then
        if (.not. associated(columns%gfl)) then
          local_status = 2
        else if (size(columns%gfl, 3) /= ngfl) then
          local_status = 2
        else
          do j = 1, ngfl
            local_slice => local%gfl(:, :, lbound(local%gfl, 3) + j - 1)
            column_slice => columns%gfl(:, :, lbound(columns%gfl, 3) + j - 1)
            call add_channel(local_slice, column_slice)
          end do
        end if
      end if
    end if
    if (associated(local%selected_three_dimensional)) then
      if (.not. associated(columns%selected_three_dimensional)) then
        local_status = 2
      else if (size(selection3d) /= n3) then
        local_status = 2
      else if (any_noncanonical(selection3d)) then
        local_status = 2
      else if (size(columns%selected_three_dimensional, 3) /= count(selection3d)) then
        local_status = 2
      else
        packed = 0
        do j = 1, n3
          if (.not. selection3d(j)) cycle
          packed = packed + 1
          local_slice => local%selected_three_dimensional(:, :, lbound(local%selected_three_dimensional, 3) + j - 1)
          column_slice => columns%selected_three_dimensional(:, :, lbound(columns%selected_three_dimensional, 3) + packed - 1)
          call add_channel(local_slice, column_slice)
        end do
      end if
    end if

    active_pressure = .false.; presence_flag = .false.; direct_pressure = .false.; nselected = 0
    if (associated(local%surface_pressure)) then
      presence_flag = .true.; direct_pressure = .true.
      if (.not. associated(columns%surface_pressure)) then
        local_status = 2
      else
        call bind_pressure(local%surface_pressure, columns%surface_pressure)
      end if
    end if
    if (associated(local%selected_two_dimensional)) then
      presence_flag = .true.
      if (.not. associated(columns%selected_two_dimensional)) then
        local_status = 2
      else if (size(selection2d) /= n2) then
        local_status = 2
      else if (any_noncanonical(selection2d)) then
        local_status = 2
      else
        nselected = count(selection2d)
        if (nselected > 1 .or. size(columns%selected_two_dimensional, 2) /= nselected) then
          local_status = 2
        else if (size(local%selected_two_dimensional, 1) /= c%spectral_coefficients) then
          local_status = 2
        else if (size(columns%selected_two_dimensional, 1) < c%local_columns) then
          local_status = 2
        else if (v == 1 .and. size(columns%selected_two_dimensional, 1) /= c%local_columns) then
          local_status = 2
        else if (nselected == 1) then
          if (active_pressure) then
            local_status = 2
          else
            do j = 1, n2
              if (selection2d(j)) then
                local_pressure_slice => local%selected_two_dimensional(:, lbound(local%selected_two_dimensional, 2) + j - 1)
                column_pressure_slice => columns%selected_two_dimensional(:, lbound(columns%selected_two_dimensional, 2))
                call bind_pressure(local_pressure_slice, column_pressure_slice)
                exit
              end if
            end do
          end if
        end if
      end if
    end if
    if (present(need_surface)) then
      if (.not. associated(local%surface_pressure)) local_status = 2
      if (.not. associated(local%divergence)) then
        local_status = 2
      else if (size(local%divergence, 2) /= c%spectral_coefficients) then
        local_status = 2
      end if
      if (need) then
        if (.not. direct_pressure .or. nselected /= 0) local_status = 2
      end if
    end if
    call agree_status(comm, local_status, status)
    if (status /= 0) return

    self_owns = c%pressure_partition(self) == 1
    metadata_bytes = int(storage_size(channel_size)/8, int64)*capacity
    metadata_bytes = metadata_bytes + int(v, int64)*(storage_size(peer_size)/8 + &
                                                     2*(storage_size(request_size)/8) + storage_size(status_size)/8)
    total_words = 0; local_status = 0
    do peer = 1, v
      if (peer == self) cycle
      call peer_counts(peer, send_words, receive_words)
      if (send_words > huge(1) - 2_int64 .or. receive_words > huge(1) - 2_int64) local_status = 2
      if (send_words > 0) total_words = total_words + send_words + 2
      if (receive_words > 0) total_words = total_words + receive_words + 2
    end do
    total_bytes = metadata_bytes + 8*total_words
    if (total_bytes > 8589934592_int64) local_status = 2
    call agree_status(comm, local_status, status)
    if (status /= 0) return
    allocate (peers(v), sends(v), receives(v), receive_status(v), message_storage(total_words), stat=alloc_status)
    local_status = 0
    if (alloc_status /= 0) local_status = 1
    call agree_status(comm, local_status, status)
    if (status /= 0) return

    sends = MPI_REQUEST_NULL; receives = MPI_REQUEST_NULL
    next_word = 1
    do peer = 1, v
      peers(peer)%coefficient_offset = c%coefficient_start(peer) - 1
      peers(peer)%coefficient_count = c%coefficient_start(peer + 1) - c%coefficient_start(peer)
      peers(peer)%level_offset = c%level_start(peer) - 1
      peers(peer)%level_count = c%level_start(peer + 1) - c%level_start(peer)
      if (peer == self) cycle
      call peer_counts(peer, send_words, receive_words)
      if (send_words > 0) then
        peers(peer)%send_count = int(send_words) + 2
        peers(peer)%send => message_storage(next_word:next_word + send_words + 1)
        next_word = next_word + send_words + 2
      end if
      if (receive_words > 0) then
        peers(peer)%receive_count = int(receive_words) + 2
        peers(peer)%receive => message_storage(next_word:next_word + receive_words + 1)
        next_word = next_word + receive_words + 2
      end if
    end do

    co = c%coefficient_start(self) - 1; lo = c%level_start(self) - 1
    do f = 1, nchannels
      do k = 1, c%local_columns
        do j = 1, c%local_levels
          if (direction == 0) then
            channel(f)%columns(lbound(channel(f)%columns, 1) + lo + j - 1, &
                               lbound(channel(f)%columns, 2) + k - 1) = &
              channel(f)%local(lbound(channel(f)%local, 1) + j - 1, lbound(channel(f)%local, 2) + co + k - 1)
          else
            channel(f)%local(lbound(channel(f)%local, 1) + j - 1, lbound(channel(f)%local, 2) + co + k - 1) = &
              channel(f)%columns(lbound(channel(f)%columns, 1) + lo + j - 1, lbound(channel(f)%columns, 2) + k - 1)
          end if
        end do
      end do
    end do
    if (active_pressure) then
      if (self_owns .or. (direction == 1 .and. need .and. v > 1)) then
        do k = 1, c%local_columns
          if (direction == 0) then
            column_pressure(lbound(column_pressure, 1) + k - 1) = local_pressure(lbound(local_pressure, 1) + co + k - 1)
          else
            local_pressure(lbound(local_pressure, 1) + co + k - 1) = column_pressure(lbound(column_pressure, 1) + k - 1)
          end if
        end do
      end if
    end if
    if (v == 1) then
      status = 0
      return
    end if

    base = (c%horizontal_index - 1)*v; tag = 1000 + 200*direction
    do ring = 1, v - 1
      peer = modulo(self - 1 + v - ring, v) + 1
      if (.not. associated(peers(peer)%receive)) cycle
      call MPI_Irecv(peers(peer)%receive, peers(peer)%receive_count, MPI_DOUBLE, &
                     base + peer - 1, tag, comm, receives(peer), ierr)
      call require_mpi(comm, ierr)
    end do
    do ring = 1, v - 1
      peer = modulo(self - 1 + ring, v) + 1
      if (associated(peers(peer)%send)) call transfer_message(peer, .false.)
    end do
    do ring = 1, v - 1
      peer = modulo(self - 1 + ring, v) + 1
      if (.not. associated(peers(peer)%send)) cycle
      call MPI_Isend(peers(peer)%send, peers(peer)%send_count, MPI_DOUBLE, &
                     base + peer - 1, tag, comm, sends(peer), ierr)
      call require_mpi(comm, ierr)
    end do
    call MPI_Waitall(v, receives, receive_status, ierr); call require_mpi(comm, ierr)
    do ring = 1, v - 1
      peer = modulo(self - 1 + v - ring, v) + 1
      if (.not. associated(peers(peer)%receive)) cycle
      call MPI_Get_count(receive_status(peer), MPI_DOUBLE, actual_count, ierr)
      call require_mpi(comm, ierr)
      if (actual_count /= peers(peer)%receive_count) call communication_fatal(comm)
      call transfer_message(peer, .true.)
    end do
    call MPI_Waitall(v, sends, MPI_STATUSES_IGNORE, ierr); call require_mpi(comm, ierr)
    status = 0
  contains
    subroutine add_channel(local_array, column_array)
      real(real64), pointer, intent(in) :: local_array(:, :), column_array(:, :)
      if (.not. associated(local_array)) return
      if (.not. associated(column_array)) then
        local_status = 2
        return
      end if
      if (size(local_array, 1) < c%local_levels .or. size(local_array, 2) /= c%spectral_coefficients) then
        local_status = 2
        return
      end if
      if (size(column_array, 1) < c%global_levels .or. size(column_array, 2) < c%local_columns) then
        local_status = 2
        return
      end if
      if (v == 1 .and. size(column_array, 2) /= c%local_columns) then
        local_status = 2
        return
      end if
      if (nchannels == capacity) then
        local_status = 2
        return
      end if
      nchannels = nchannels + 1
      channel(nchannels)%local => local_array
      channel(nchannels)%columns => column_array
    end subroutine
    subroutine bind_pressure(local_array, column_array)
      real(real64), pointer, intent(in) :: local_array(:), column_array(:)
      if (size(local_array) /= c%spectral_coefficients .or. size(column_array) < c%local_columns) then
        local_status = 2
        return
      end if
      if (v == 1 .and. size(column_array) /= c%local_columns) then
        local_status = 2
        return
      end if
      local_pressure => local_array; column_pressure => column_array
      active_pressure = .true.
    end subroutine
    subroutine peer_counts(which, send_payload, receive_payload)
      integer, intent(in) :: which
      integer(int64), intent(out) :: send_payload, receive_payload
      integer :: coefficient_count, level_count, sp, rp
      coefficient_count = c%coefficient_start(which + 1) - c%coefficient_start(which)
      level_count = c%level_start(which + 1) - c%level_start(which)
      peer_owns = c%pressure_partition(which) == 1
      if (direction == 0) then
        sp = 0; rp = 0
        if (active_pressure .and. self_owns) sp = 1
        if (active_pressure .and. peer_owns) rp = 1
        send_payload = (int(c%local_levels, int64)*nchannels + sp)*coefficient_count
        receive_payload = (int(level_count, int64)*nchannels + rp)*c%local_columns
      else
        sp = 0; rp = 0
        if (active_pressure .and. (peer_owns .or. need)) sp = 1
        if (active_pressure .and. (self_owns .or. need)) rp = 1
        send_payload = (int(level_count, int64)*nchannels + sp)*c%local_columns
        receive_payload = (int(c%local_levels, int64)*nchannels + rp)*coefficient_count
      end if
    end subroutine
    subroutine transfer_message(which, unpack)
      integer, intent(in) :: which
      logical, intent(in) :: unpack
      real(real64), pointer :: message(:)
      logical :: local_shape, has_pressure
      integer :: count_coefficient, count_level, offset_coefficient, offset_level
      integer :: x, y, z, pos
      if (unpack) then
        message => peers(which)%receive
      else
        message => peers(which)%send
      end if
      local_shape = ((direction == 0) .neqv. unpack)
      if (local_shape) then
        count_coefficient = peers(which)%coefficient_count
        offset_coefficient = peers(which)%coefficient_offset
        count_level = c%local_levels; offset_level = 0
      else
        count_coefficient = c%local_columns; offset_coefficient = 0
        count_level = peers(which)%level_count; offset_level = peers(which)%level_offset
      end if
      if (direction == 0) then
        if (unpack) then
          has_pressure = c%pressure_partition(which) == 1
        else
          has_pressure = self_owns
        end if
      else
        if (unpack) then
          has_pressure = self_owns .or. need
        else
          has_pressure = (c%pressure_partition(which) == 1) .or. need
        end if
      end if
      expected_header = 1.0_real64
      if (presence_flag .and. has_pressure) expected_header = 0.0_real64
      expected_coefficients = real(count_coefficient, real64)
      if (unpack) then
        if (transfer(message(1), 0_int64) /= transfer(expected_header, 0_int64)) call communication_fatal(comm)
        if (transfer(message(2), 0_int64) /= transfer(expected_coefficients, 0_int64)) call communication_fatal(comm)
      else
        message(1) = expected_header; message(2) = expected_coefficients
      end if
      pos = 2
      if (active_pressure .and. has_pressure) then
        do x = 1, count_coefficient
          pos = pos + 1
          if (local_shape) then
            if (unpack) then
              local_pressure(lbound(local_pressure, 1) + offset_coefficient + x - 1) = message(pos)
            else
              message(pos) = local_pressure(lbound(local_pressure, 1) + offset_coefficient + x - 1)
            end if
          else
            if (unpack) then
              column_pressure(lbound(column_pressure, 1) + offset_coefficient + x - 1) = message(pos)
            else
              message(pos) = column_pressure(lbound(column_pressure, 1) + offset_coefficient + x - 1)
            end if
          end if
        end do
      end if
      do x = 1, count_coefficient
        do y = 1, nchannels
          do z = 1, count_level
            pos = pos + 1
            if (local_shape) then
              if (unpack) then
                channel(y)%local(lbound(channel(y)%local, 1) + offset_level + z - 1, &
                                 lbound(channel(y)%local, 2) + offset_coefficient + x - 1) = message(pos)
              else
                message(pos) = channel(y)%local(lbound(channel(y)%local, 1) + offset_level + z - 1, &
                                                lbound(channel(y)%local, 2) + offset_coefficient + x - 1)
              end if
            else
              if (unpack) then
                channel(y)%columns(lbound(channel(y)%columns, 1) + offset_level + z - 1, &
                                   lbound(channel(y)%columns, 2) + offset_coefficient + x - 1) = message(pos)
              else
                message(pos) = channel(y)%columns(lbound(channel(y)%columns, 1) + offset_level + z - 1, &
                                                  lbound(channel(y)%columns, 2) + offset_coefficient + x - 1)
              end if
            end if
          end do
        end do
      end do
      if (pos /= size(message)) call communication_fatal(comm)
    end subroutine
  end function

  logical function canonical_logical(value) result(ok)
    logical, intent(in) :: value
    integer(int32) :: word
    word = transfer(value, 0_int32)
    ok = word == 0 .or. word == 1
  end function
  logical function any_noncanonical(values) result(bad)
    logical, intent(in) :: values(:)
    integer :: j
    bad = .false.
    do j = 1, size(values)
      if (.not. canonical_logical(values(j))) then
        bad = .true.
        return
      end if
    end do
  end function
  subroutine agree_status(comm, local_status, global_status)
    type(MPI_Comm), intent(in) :: comm
    integer(int32), intent(in) :: local_status
    integer(int32), intent(out) :: global_status
    integer :: ierr
    call MPI_Allreduce(local_status, global_status, 1, MPI_INT, MPI_MAX, comm, ierr)
    call require_mpi(comm, ierr)
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
    error stop 3
  end subroutine
end module
