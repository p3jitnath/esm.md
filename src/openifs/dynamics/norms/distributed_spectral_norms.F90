!> Compute spectral norms with native field views and public MPI.
module forecast_distributed_spectral_norms
  use iso_fortran_env, only: int8, int32, int64, real64
  use iso_c_binding, only: c_loc, c_f_pointer
  use mpi_f08
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_spectral_norm_namespace, only: spectral_norm_persistent_state
  use forecast_selected_spectral_norms, only: spectral_norm_fields, spectral_norm_model_controls, &
                                              spectral_norm_environment_supported
  use forecast_ordered_spectral_norm_arithmetic, only: spectral_norm_matrix, spectral_norm_average
  implicit none
  private
  public :: compute_runtime_distributed_spectral_norms, compute_operational_distributed_spectral_norms
  public :: distributed_spectral_norm_result_words
  integer(int64), parameter :: fixed_wire = 1421096_int64, fixed_work = 7635400_int64
  integer(int64), parameter :: fixed_matrix = 2856_int64, fixed_stride = 44160_int64
  integer(int64), parameter :: fixed_pressure = 1415976_int64, fixed_scratch = 7105480_int64
  integer(int64), parameter :: fixed_seen = 7458760_int64, fixed_pressure_seen = 7634120_int64
contains
  !> Return the number of FP64 words in the complete canonical result.
  !! Five means precede four level vectors,one pressure value and four matrices.
  pure integer(int64) function distributed_spectral_norm_result_words(levels, degree) result(words)
    integer(int32), intent(in) :: levels, degree
    words = 6_int64 + 4_int64*levels + 4_int64*levels*(int(degree, int64) + 1_int64)
  end function

  pure integer(int64) function wire_size(levels, waves) result(bytes)
    integer, intent(in) :: levels, waves
    bytes = iand(39_int64 + 4_int64*(int(levels, int64) + waves), not(7_int64)) &
            + 32_int64*levels*waves + 8_int64*waves
  end function

  subroutine agree_status(comm, local, status)
    type(MPI_Comm), intent(in) :: comm
    integer(int32), intent(in) :: local
    integer(int32), intent(out) :: status
    integer :: error
    call MPI_Allreduce(local, status, 1, MPI_INTEGER4, MPI_MAX, comm, error)
    if (error /= MPI_SUCCESS) status = 3
  end subroutine

  logical function dense_field(field, levels, columns) result(ok)
    real(real64), pointer, intent(in) :: field(:, :)
    integer, intent(in) :: levels, columns
    ok = .false.
    if (.not. associated(field)) then
      ok = int(levels, int64)*columns == 0_int64
      return
    end if
    if (any(shape(field) /= [levels, columns])) return
    ok = is_contiguous(field)
  end function

  !> Admit actual native metadata before private storage or numerical work.
  !! MYLEVS contains global one-based level indices. MYMS contains wave numbers;
  !! NASM0 gives one-based real-column starts and RLAPIN retains its source sign.
  logical function metadata_supported(geometry, model, fields, controls, world, rank, n, l, u, ll, nc, ps) result(ok)
    type(native_geometry_state), intent(in) :: geometry
    type(spectral_norm_model_controls), intent(in) :: model
    type(spectral_norm_fields), intent(in) :: fields
    integer(int32), intent(in) :: controls(6)
    integer, intent(in) :: world, rank
    integer, intent(out) :: n, l, u, ll, nc, ps
    integer :: horizontal, vertical
    ok = .false.
    n = 0; l = 0; u = 0; ll = 0; nc = 0; ps = 0
    if (world < 1 .or. world > 65536) return
    if (any(controls /= [0_int32, 0_int32, 0_int32, 0_int32, int(world, int32), 0_int32])) return
    if (model%thermal_fields /= 1 .or. model%pressure_fields /= 1 .or. model%spectral_tracers /= 0) return
    if (model%nonhydrostatic) return
    if (geometry%partition%phase /= 7) return
    if (geometry%transform_control%nproc /= world .or. geometry%transform_control%myproc /= rank + 1) return
    if (geometry%transform_resolution%resolution < 1) return
    if (geometry%partition%borrowed_resolution /= geometry%transform_resolution%resolution) return
    horizontal = geometry%transform_control%nprtrw; vertical = geometry%transform_control%nprtrv
    if (horizontal < 1 .or. vertical < 1) return
    if (int(horizontal, int64)*vertical /= world) return
    if (geometry%transform_control%mysetw < 1 .or. geometry%transform_control%mysetw > horizontal) return
    if (geometry%transform_control%mysetv < 1 .or. geometry%transform_control%mysetv > vertical) return
    n = geometry%dimensions%nsmax; l = geometry%dimensions%nflevg
    u = geometry%partition%nump; ll = geometry%partition%nflevl
    nc = geometry%partition%nspec2; ps = geometry%partition%npsp
    if (n < 1 .or. n > 8191 .or. l < 1 .or. l > 512) return
    if (u < 0 .or. u > n + 1 .or. ll < 0 .or. ll > l) return
    if (nc < 0 .or. int(nc, int64) > (int(n, int64) + 1)*(n + 2)) return
    if (ps < 0 .or. ps > 1) return
    if (.not. dense_field(fields%vorticity, ll, nc)) return
    if (.not. dense_field(fields%divergence, ll, nc)) return
    if (.not. dense_field(fields%temperature, ll, nc)) return
    if (.not. allocated(geometry%laplacian%myms)) return
    if (.not. allocated(geometry%laplacian%nasm0)) return
    if (.not. allocated(geometry%laplacian%rlapin)) return
    if (.not. allocated(geometry%partition%mylevs)) return
    if (size(geometry%laplacian%myms) /= u .or. size(geometry%partition%mylevs) /= ll) return
    if (lbound(geometry%laplacian%nasm0, 1) /= 0 .or. ubound(geometry%laplacian%nasm0, 1) /= n) return
    if (lbound(geometry%laplacian%rlapin, 1) /= -1 .or. ubound(geometry%laplacian%rlapin, 1) /= n + 2) return
    if (ps == 1) then
      if (.not. associated(fields%surface_pressure)) then
        if (nc /= 0) return
      else
        if (size(fields%surface_pressure) /= nc .or. .not. is_contiguous(fields%surface_pressure)) return
      end if
    end if
    if (.not. spectral_norm_environment_supported()) return
    ok = .true.
  end function

  logical function local_maps_supported(geometry, n, l, u, ll, nc) result(ok)
    type(native_geometry_state), intent(in) :: geometry
    integer, intent(in) :: n, l, u, ll, nc
    integer :: j, m, first
    integer(int64) :: last_column
    ok = .false.
    do j = 1, u
      m = geometry%laplacian%myms(j)
      if (m < 0 .or. m > n) return
      first = geometry%laplacian%nasm0(m)
      if (first < 1) return
      last_column = int(first, int64) + 2_int64*(n - m)
      if (m /= 0) last_column = last_column + 1
      if (last_column > nc) return
      ! Native children receive the complete stored real/imaginary field extent.
      if (int(first, int64) + 2_int64*(n - m + 1) - 1 > nc) return
    end do
    do j = 1, ll
      if (geometry%partition%mylevs(j) < 1 .or. geometry%partition%mylevs(j) > l) return
    end do
    ok = .true.
  end function

  !> Form the local four matrices and pressure vector in source call order.
  !! Offsets describe our MPI byte packet,not a compiler-dependent model record.
  subroutine form_local_norms(geometry, fields, n, ll, u, nc, ps, work, matrix_offset, field_stride, &
                              pressure_offset, scratch_offset, thermal_before_combination, status)
    type(native_geometry_state), intent(in) :: geometry
    type(spectral_norm_fields), intent(in) :: fields
    integer, intent(in) :: n, ll, u, nc, ps
    integer(int8), target, intent(inout) :: work(:)
    integer(int64), intent(in) :: matrix_offset, field_stride, pressure_offset, scratch_offset
    logical, intent(in) :: thermal_before_combination
    integer(int32), intent(out) :: status
    real(real64), pointer, contiguous :: vo(:, :), div(:, :), energy(:, :), thermal(:, :), scratch(:, :), pressure(:, :)
    real(real64), pointer, contiguous :: source_pressure(:, :)
    real(real64) :: value
    integer :: i, j
    status = 0
    if (ll > 0 .and. u > 0) then
      call c_f_pointer(c_loc(work(matrix_offset + 1)), vo, [ll, u])
      call c_f_pointer(c_loc(work(matrix_offset + 8*field_stride + 1)), div, [ll, u])
      call c_f_pointer(c_loc(work(matrix_offset + 16*field_stride + 1)), energy, [ll, u])
      call c_f_pointer(c_loc(work(matrix_offset + 24*field_stride + 1)), thermal, [ll, u])
      call c_f_pointer(c_loc(work(scratch_offset + 1)), scratch, [ll, u])
      call spectral_norm_matrix(int(n, int32), geometry%laplacian%myms, geometry%laplacian%nasm0, &
                                geometry%laplacian%rlapin(0:n), fields%vorticity, .false., int(ll, int32), vo, status)
      if (status /= 0) return
      call spectral_norm_matrix(int(n, int32), geometry%laplacian%myms, geometry%laplacian%nasm0, &
                                geometry%laplacian%rlapin(0:n), fields%divergence, .false., int(ll, int32), div, status)
      if (status /= 0) return
      call spectral_norm_matrix(int(n, int32), geometry%laplacian%myms, geometry%laplacian%nasm0, &
                                geometry%laplacian%rlapin(0:n), fields%vorticity, .true., int(ll, int32), energy, status)
      if (status /= 0) return
      call spectral_norm_matrix(int(n, int32), geometry%laplacian%myms, geometry%laplacian%nasm0, &
                                geometry%laplacian%rlapin(0:n), fields%divergence, .true., int(ll, int32), scratch, status)
      if (status /= 0) return
      if (thermal_before_combination) then
        call spectral_norm_matrix(int(n, int32), geometry%laplacian%myms, geometry%laplacian%nasm0, &
                                  geometry%laplacian%rlapin(0:n), fields%temperature, .false., int(ll, int32), thermal, status)
        if (status /= 0) return
      end if
      do j = 1, u
        do i = 1, ll
          value = energy(i, j) + scratch(i, j)
          energy(i, j) = value*0.5_real64
        end do
      end do
      if (.not. thermal_before_combination) then
        call spectral_norm_matrix(int(n, int32), geometry%laplacian%myms, geometry%laplacian%nasm0, &
                                  geometry%laplacian%rlapin(0:n), fields%temperature, .false., int(ll, int32), thermal, status)
        if (status /= 0) return
      end if
    end if
    if (ps == 1 .and. u > 0) then
      source_pressure(1:1, 1:nc) => fields%surface_pressure
      call c_f_pointer(c_loc(work(pressure_offset + 1)), pressure, [1, u])
      call spectral_norm_matrix(int(n, int32), geometry%laplacian%myms, geometry%laplacian%nasm0, &
                                geometry%laplacian%rlapin(0:n), source_pressure, .false., 1_int32, pressure, status)
    end if
  end subroutine

  !> Validate one packet,then optionally place its complete matrix words.
  !! Coverage arrays contain bytes;received floating values are never reduced here.
  subroutine unpack_packet(packet, fixed_format, n, l, peer, seen, pressure_seen, global_pressure, &
                           output, copy_values, cover, pressure_cover, status)
    integer(int8), target, intent(inout) :: packet(:)
    logical, intent(in) :: fixed_format, copy_values
    integer, intent(in) :: n, l, peer
    integer(int8), intent(inout) :: seen(:), pressure_seen(:)
    real(real64), intent(inout) :: global_pressure(:), output(:)
    integer(int64), intent(inout) :: cover, pressure_cover
    integer(int32), intent(out) :: status
    integer(int32), pointer :: header(:), waves(:), levels(:)
    real(real64), pointer :: matrix_values(:), pressure_values(:)
    integer :: ll, u, ps, j, k, m, lev, f, before
    integer(int64) :: matrix_offset, field_stride, pressure_offset, index, source_index, destination
    status = 2
    if (fixed_format) then
      if (size(packet, kind=int64) /= fixed_wire) return
      call c_f_pointer(c_loc(packet(1)), header, [4])
      ll = header(1); u = 640; ps = header(2)
      if (ll < 68 .or. ll > 69 .or. ps < 0 .or. ps > 1 .or. header(3) /= peer) return
      before = 16; matrix_offset = fixed_matrix; field_stride = fixed_stride; pressure_offset = fixed_pressure
    else
      if (size(packet) < 32) return
      call c_f_pointer(c_loc(packet(1)), header, [8])
      ll = header(1); u = header(2); ps = header(3)
      if (ll < 0 .or. ll > l .or. u < 0 .or. u > n + 1 .or. ps < 0 .or. ps > 1) return
      if (header(4) /= peer .or. header(5) /= n .or. header(6) /= l .or. header(8) /= 0) return
      if (wire_size(ll, u) /= size(packet, kind=int64)) return
      before = 32
      matrix_offset = iand(39_int64 + 4_int64*(int(ll, int64) + u), not(7_int64))
      field_stride = int(ll, int64)*u; pressure_offset = matrix_offset + 32*field_stride
    end if
    if (u > 0) call c_f_pointer(c_loc(packet(before + 1)), waves, [u])
    if (ll > 0) then
      call c_f_pointer(c_loc(packet(before + 4*u + 1)), levels, [ll])
      do k = 1, ll
        if (levels(k) < 1 .or. levels(k) > l) return
        do j = 1, k - 1
          if (levels(k) == levels(j)) return
        end do
      end do
    end if
    if (u > 0) call c_f_pointer(c_loc(packet(pressure_offset + 1)), pressure_values, [u])
    do j = 1, u
      m = waves(j)
      if (m < 0 .or. m > n) return
      do k = 1, j - 1
        if (waves(k) == m) return
      end do
      if (ps == 1) then
        if (pressure_seen(m + 1) /= 0_int8) return
        pressure_seen(m + 1) = 1_int8
        pressure_cover = pressure_cover + 1
        if (copy_values) global_pressure(m + 1) = pressure_values(j)
      end if
      do k = 1, ll
        lev = levels(k)
        index = int(m, int64)*l + lev
        if (seen(index) /= 0_int8) return
        seen(index) = 1_int8; cover = cover + 1
        if (copy_values) then
          source_index = int(j - 1, int64)*ll + k
          do f = 0, 3
            call c_f_pointer(c_loc(packet(matrix_offset + 8*field_stride*f + 1)), matrix_values, [ll*u])
            destination = 6_int64 + 4_int64*l + int(f, int64)*l*(n + 1) + index
            output(destination) = matrix_values(source_index)
          end do
        end if
      end do
    end do
    status = 0
  end subroutine

  subroutine average_global(stage, global_pressure, l, n, status)
    real(real64), target, intent(inout) :: stage(:)
    real(real64), target, intent(in) :: global_pressure(:)
    integer, intent(in) :: l, n
    integer(int32), intent(out) :: status
    real(real64), pointer :: matrix(:, :), pressure(:, :)
    integer :: f
    integer(int64) :: first
    do f = 0, 3
      first = 7_int64 + 4_int64*l + int(f, int64)*l*(n + 1)
      call c_f_pointer(c_loc(stage(first)), matrix, [l, n + 1])
      call spectral_norm_average(matrix, int(l, int32), f == 2, int(n + 1, int32), &
                                 stage(6 + f*l:5 + (f + 1)*l), stage(f + 1), status)
      if (status /= 0) return
    end do
    call c_f_pointer(c_loc(global_pressure(1)), pressure, [1, n + 1])
    call spectral_norm_average(pressure, 1_int32, .false., int(n + 1, int32), &
                               stage(6 + 4*l:6 + 4*l), stage(5), status)
  end subroutine

  !> Compute a live distributed norm with deterministic rank-ordered gathering.
  !!
  !! Geometry and fields are initialized native owners,with truncation1:8191,
  !! global levels1:512 and actual process layout1:65536. The communicator must
  !! describe that same live layout. All ranks call together. Six controls are
  !! NSPPR,LELAM,LREFGEN,LREFOUT,NPROC,LDSPOR;only NPROC may be nonzero.
  !!
  !! Results is a contiguous FP64 owner with at least result_words(L,N) values.
  !! canonical_capacity and budget are byte counts;budget is at most64GiB.
  !! Only rank0 changes results and persistent%AVNRMDIV. Matrix slots retain
  !! global level-fast,wave-next order. Trailing output words stay unchanged.
  !!
  !! One zeroed byte owner holds the exact source wire,scratch,receive and
  !! coverage storage. Rank0 also owns a complete temporary result. Private
  !! input maps and outputs must not alias. Status0 succeeds,1 refuses allocation,
  !! 2 refuses metadata/coverage and3 reports a returned public MPI error.
  !! Failed admission leaves outputs unchanged;received packets are drained
  !! before a common coverage refusal. No original numerical routine is called.
  subroutine compute_runtime_distributed_spectral_norms(comm, geometry, model, fields, controls, &
                                                        persistent, results, canonical_capacity, budget, status)
    type(MPI_Comm), intent(in) :: comm
    type(native_geometry_state), intent(in) :: geometry
    type(spectral_norm_model_controls), intent(in) :: model
    type(spectral_norm_fields), intent(in) :: fields
    integer(int32), intent(in) :: controls(6)
    type(spectral_norm_persistent_state), intent(inout) :: persistent
    real(real64), target, intent(inout) :: results(:)
    integer(int64), intent(in) :: canonical_capacity, budget
    integer(int32), intent(out) :: status
    integer(int8), allocatable, target :: work(:)
    real(real64), allocatable, target :: stage(:)
    integer(int32), pointer :: header(:), waves(:), levels(:)
    integer(int8), pointer :: seen(:), pressure_seen(:)
    real(real64), pointer :: global_pressure(:)
    integer(int32) :: local_status, common(2), reference(2), packet_status
    type(MPI_Status) :: receive_status
    integer :: rank, world, error, n, l, u, ll, nc, ps, code, j, peer, count
    integer(int64) :: result_words, result_bytes, wire, maxwire, matrix_offset, scratch, receive, &
                      seen_offset, pressure_seen_offset, global_pressure_offset, work_bytes, need, cover, pressure_cover
    status = 3
    call MPI_Comm_rank(comm, rank, error)
    if (error /= MPI_SUCCESS) return
    call MPI_Comm_size(comm, world, error)
    if (error /= MPI_SUCCESS) return
    local_status = 2
    if (.not. metadata_supported(geometry, model, fields, controls, world, rank, n, l, u, ll, nc, ps)) goto100
    result_words = distributed_spectral_norm_result_words(int(l, int32), int(n, int32))
    result_bytes = 8*result_words
    if (.not. is_contiguous(results) .or. size(results, kind=int64) < result_words) goto100
    if (canonical_capacity < result_bytes) goto100
    local_status = 0
100 continue
    call agree_status(comm, local_status, status)
    if (status /= 0) return
    common = [int(n, int32), int(l, int32)]; reference = common
    call MPI_Bcast(reference, 2, MPI_INTEGER4, 0, comm, error)
    if (error /= MPI_SUCCESS) then
      status = 3
      return
    end if
    local_status = 0
    if (any(reference /= common)) local_status = 2
    call agree_status(comm, local_status, status)
    if (status /= 0) return
    wire = wire_size(ll, u); scratch = wire; receive = wire + 8_int64*ll*u
    maxwire = wire_size(l, n + 1); work_bytes = receive
    if (rank == 0) then
      seen_offset = receive + maxwire
      pressure_seen_offset = seen_offset + int(l, int64)*(n + 1)
      global_pressure_offset = iand(pressure_seen_offset + 2_int64*(n + 1) + l + 7_int64, not(7_int64))
      work_bytes = global_pressure_offset + 8_int64*(n + 1)
    end if
    need = work_bytes
    if (rank == 0) need = need + result_bytes
    local_status = 2
    if (budget >= need .and. budget > 0_int64 .and. budget <= 2_int64**36) local_status = 0
    call agree_status(comm, local_status, status)
    if (status /= 0) return
    allocate (work(work_bytes), stat=code)
    local_status = 1
    if (code == 0) then
      work = 0_int8; local_status = 0
      if (rank == 0) then
        allocate (stage(result_words), stat=code)
        if (code /= 0) local_status = 1
      end if
    end if
    call agree_status(comm, local_status, status)
    if (status /= 0) goto900
    call c_f_pointer(c_loc(work(1)), header, [8])
    header = [int(ll, int32), int(u, int32), int(ps, int32), int(rank, int32), &
              int(n, int32), int(l, int32), int(nc, int32), 0_int32]
    if (u > 0) then
      call c_f_pointer(c_loc(work(33)), waves, [u])
      waves = geometry%laplacian%myms
    end if
    if (ll > 0) then
      call c_f_pointer(c_loc(work(33 + 4*u)), levels, [ll])
      levels = geometry%partition%mylevs
    end if
    local_status = 2
    if (local_maps_supported(geometry, n, l, u, ll, nc)) local_status = 0
    call agree_status(comm, local_status, status)
    if (status /= 0) goto900
    matrix_offset = iand(39_int64 + 4_int64*(int(ll, int64) + u), not(7_int64))
    call form_local_norms(geometry, fields, n, ll, u, nc, ps, work, matrix_offset, int(ll, int64)*u, &
                          matrix_offset + 32_int64*ll*u, scratch, .false., local_status)
    if (local_status /= 0) then
      status = local_status
      goto900
    end if
    local_status = 0
    if (rank /= 0) then
      call MPI_Send(work, int(wire), MPI_BYTE, 0, 28861, comm, error)
      if (error /= MPI_SUCCESS) then
        status = 3
        goto900
      end if
    else
      call c_f_pointer(c_loc(work(seen_offset + 1)), seen, [l*(n + 1)])
      call c_f_pointer(c_loc(work(pressure_seen_offset + 1)), pressure_seen, [n + 1])
      call c_f_pointer(c_loc(work(global_pressure_offset + 1)), global_pressure, [n + 1])
      cover = 0; pressure_cover = 0
      do peer = 0, world - 1
        if (peer == 0) then
          call unpack_packet(work(1:wire), .false., n, l, peer, seen, pressure_seen, global_pressure, &
                             stage, .true., cover, pressure_cover, packet_status)
        else
          call MPI_Recv(work(receive + 1:receive + maxwire), int(maxwire), MPI_BYTE, peer, 28861, &
                        comm, receive_status, error)
          if (error /= MPI_SUCCESS) then
            status = 3
            goto900
          end if
          call MPI_Get_count(receive_status, MPI_BYTE, count, error)
          if (error /= MPI_SUCCESS) then
            status = 3
            goto900
          end if
          packet_status = 2
          if (count >= 0 .and. int(count, int64) <= maxwire) then
            call unpack_packet(work(receive + 1:receive + count), .false., n, l, peer, seen, pressure_seen, &
                               global_pressure, stage, .true., cover, pressure_cover, packet_status)
          end if
        end if
        if (packet_status /= 0) local_status = 2
      end do
      if (cover /= int(l, int64)*(n + 1) .or. pressure_cover /= n + 1) local_status = 2
    end if
    call agree_status(comm, local_status, status)
    if (status /= 0) goto900
    local_status = 0
    if (rank == 0) call average_global(stage, global_pressure, l, n, local_status)
    nullify (header, waves, levels, seen, pressure_seen, global_pressure)
    deallocate (work)
    call agree_status(comm, local_status, status)
    if (status /= 0) goto900
    if (rank == 0) then
      results(1:result_words) = stage
      persistent%avnrmdiv = stage(2)
    end if
900 continue
    if (allocated(work)) deallocate (work)
    if (allocated(stage)) deallocate (stage)
  end subroutine

  !> Preserve the distinct fixed four-rank T1279,L137 gathered-wire route.
  !!
  !! Each rank owns exactly640 waves and68 or69 levels from its real metadata.
  !! The complete horizontal field has819840 real columns. One7,635,400-byte
  !! owner holds the source fixed wire,four gathered packets,scratch and coverage.
  !! Public MPI_Gather retains the exact1,421,096-byte packet per process.
  !! All maps are checked before rank0 writes its5,615,952-byte result.
  !! Status and mutation rules match the runtime entry;no budget is fabricated.
  subroutine compute_operational_distributed_spectral_norms(comm, geometry, model, fields, controls, &
                                                            persistent, results, status)
    type(MPI_Comm), intent(in) :: comm
    type(native_geometry_state), intent(in) :: geometry
    type(spectral_norm_model_controls), intent(in) :: model
    type(spectral_norm_fields), intent(in) :: fields
    integer(int32), intent(in) :: controls(6)
    type(spectral_norm_persistent_state), intent(inout) :: persistent
    real(real64), target, intent(inout) :: results(:)
    integer(int32), intent(out) :: status
    integer(int8), allocatable, target :: work(:)
    integer(int32), pointer :: header(:), waves(:), levels(:)
    integer(int8), pointer :: seen(:), pressure_seen(:)
    real(real64), pointer :: global_pressure(:)
    integer :: rank, world, error, n, l, u, ll, nc, ps, code, peer
    integer(int32) :: local_status, packet_status
    integer(int64) :: cover, pressure_cover, packet_first, result_words
    status = 3
    call MPI_Comm_rank(comm, rank, error)
    if (error /= MPI_SUCCESS) return
    call MPI_Comm_size(comm, world, error)
    if (error /= MPI_SUCCESS) return
    local_status = 2
    if (world /= 4) goto100
    if (.not. metadata_supported(geometry, model, fields, controls, world, rank, n, l, u, ll, nc, ps)) goto100
    if (n /= 1279 .or. l /= 137 .or. u /= 640 .or. nc /= 819840 .or. ll < 68 .or. ll > 69) goto100
    result_words = distributed_spectral_norm_result_words(137_int32, 1279_int32)
    if (.not. is_contiguous(results) .or. size(results, kind=int64) < result_words) goto100
    local_status = 0
100 continue
    call agree_status(comm, local_status, status)
    if (status /= 0) return
    allocate (work(fixed_work), stat=code)
    local_status = 0
    if (code /= 0) local_status = 1
    call agree_status(comm, local_status, status)
    if (status /= 0) goto900
    work(1:fixed_wire) = 0_int8
    call c_f_pointer(c_loc(work(1)), header, [4])
    header(1:3) = [int(ll, int32), int(ps, int32), int(rank, int32)]
    call c_f_pointer(c_loc(work(17)), waves, [640])
    waves = geometry%laplacian%myms
    call c_f_pointer(c_loc(work(2577)), levels, [ll])
    levels = geometry%partition%mylevs
    local_status = 2
    if (local_maps_supported(geometry, n, l, u, ll, nc)) local_status = 0
    call agree_status(comm, local_status, status)
    if (status /= 0) goto900
    call form_local_norms(geometry, fields, n, ll, u, nc, ps, work, fixed_matrix, fixed_stride, &
                          fixed_pressure, fixed_scratch, .true., local_status)
    if (local_status /= 0) then
      status = local_status
      goto900
    end if
    call MPI_Gather(work(1:fixed_wire), int(fixed_wire), MPI_BYTE, &
                    work(fixed_wire + 1:5*fixed_wire), int(fixed_wire), MPI_BYTE, 0, comm, error)
    if (error /= MPI_SUCCESS) then
      status = 3
      goto900
    end if
    local_status = 0
    if (rank == 0) then
      call c_f_pointer(c_loc(work(fixed_seen + 1)), seen, [137*1280])
      call c_f_pointer(c_loc(work(fixed_pressure_seen + 1)), pressure_seen, [1280])
      call c_f_pointer(c_loc(work(fixed_scratch + 1)), global_pressure, [1280])
      seen = 0_int8; pressure_seen = 0_int8; cover = 0; pressure_cover = 0
      do peer = 0, 3
        packet_first = (int(peer, int64) + 1)*fixed_wire + 1
        call unpack_packet(work(packet_first:packet_first + fixed_wire - 1), .true., 1279, 137, peer, &
                           seen, pressure_seen, global_pressure, results, .false., cover, pressure_cover, packet_status)
        if (packet_status /= 0) local_status = 2
      end do
      if (cover /= 175360_int64 .or. pressure_cover /= 1280) local_status = 2
    end if
    call agree_status(comm, local_status, status)
    if (status /= 0) goto900
    if (rank == 0) then
      seen = 0_int8; pressure_seen = 0_int8; cover = 0; pressure_cover = 0
      do peer = 0, 3
        packet_first = (int(peer, int64) + 1)*fixed_wire + 1
        call unpack_packet(work(packet_first:packet_first + fixed_wire - 1), .true., 1279, 137, peer, &
                           seen, pressure_seen, global_pressure, results, .true., cover, pressure_cover, packet_status)
      end do
      call average_global(results, global_pressure, 137, 1279, status)
      if (status == 0) persistent%avnrmdiv = results(2)
    else
      status = 0
    end if
900 continue
    if (allocated(work)) deallocate (work)
  end subroutine
end module forecast_distributed_spectral_norms
