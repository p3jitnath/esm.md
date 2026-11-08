!> Own explicit live maps for the existing distributed spectral pressure solve.
!! This constructor copies metadata and coefficient words; it calculates no field.
module md2asm_spectral_pressure_context
  use iso_fortran_env, only: int32, int64, real64
  use md2asm_spectral_transposes, only: spectral_transpose_layout
  use md2asm_distributed_pressure_stage, only: spectral_pressure_context
  implicit none
  private
  public :: initialize_spectral_pressure_context, release_spectral_pressure_context
contains
  !> Validate and copy the actual initialized partition and pressure inputs.
  !! layout retains the original phase7 topology and one-based prefix maps.
  !! vertical_mode_indices selects global eigenvalues in the local mode order.
  !! wave_numbers is the actual local MYMS list. wave_first_column(0:N) is
  !! indexed by wave m and holds one-based REAL/IMAGINARY column addresses.
  !! Each wave uses2*(N-m+1) real values. degree_factors(0:N) retains the
  !! exact source coefficient and sign; this entry does not infer a geometry
  !! member from its name. mode_eigenvalues has squared-speed units(m**2/s**2).
  !! time_step is s, beta_time and stretch are dimensionless, rotation_rate
  !! is1/s. Coefficients and signed zeros are copied without arithmetic.
  !!
  !! All inputs are borrowed and unchanged. They must not refer to the
  !! destination context being replaced. On success the context owns its
  !! complete copies, including the0-based wave and degree arrays. The
  !! caller retains its actual public MPI communicator; no communicator
  !! handle or rank is invented here. It must agree this local status before
  !! later communication. The unchanged solver rechecks actual MPI size/rank.
  !!
  !! Status0 commits all owners,1 refuses allocation,2 refuses metadata.
  !! Any refusal preserves the old context. Repeated release is quiet.
  subroutine initialize_spectral_pressure_context(layout, vertical_mode_indices, wave_numbers, &
                                wave_first_column, mode_eigenvalues, degree_factors, time_step, beta_time, stretch, rotation_rate, &
                                                  temporary_bytes_budget, context, status)
    type(spectral_transpose_layout), intent(in) :: layout
    integer(int32), intent(in) :: vertical_mode_indices(:), wave_numbers(:), wave_first_column(0:)
    real(real64), intent(in) :: mode_eigenvalues(:), degree_factors(0:)
    real(real64), intent(in) :: time_step, beta_time, stretch, rotation_rate
    integer(int64), intent(in) :: temporary_bytes_budget
    type(spectral_pressure_context), intent(inout) :: context
    integer(int32), intent(out) :: status
    type(spectral_pressure_context) :: pending
    integer :: n, l, s, v, self, peer, nc, nl, j, k, first, last, other_first, other_last, code
    integer(int64) :: covered, send_count, receive_count, copy_bytes, solve_bytes
    status = 2
    if (.not. valid_layout(layout)) return
    n = layout%maximum_degree; l = layout%local_levels; s = layout%spectral_coefficients
    v = layout%vertical_peers; self = layout%vertical_index
    if (temporary_bytes_budget < 1_int64 .or. temporary_bytes_budget > 2_int64**36) return
    solve_bytes = 16_int64*l*s + 8_int64*(5_int64*(n + 2) + l) + 16_int64*(n + 1)*l
    if (solve_bytes > temporary_bytes_budget) return
    if (size(vertical_mode_indices) /= l .or. size(mode_eigenvalues) < layout%global_levels) return
    if (any(vertical_mode_indices < 1) .or. any(vertical_mode_indices > layout%global_levels)) return
    if (size(wave_numbers) > n + 1) return
    if (ubound(wave_first_column, 1) < n .or. ubound(degree_factors, 1) < n) return
    covered = 0_int64
    do j = 1, size(wave_numbers)
      if (wave_numbers(j) < 0 .or. wave_numbers(j) > n) return
      first = wave_first_column(wave_numbers(j))
      if (first < 1 .or. int(first, int64) > int(s, int64) + 1_int64) return
      if (2_int64*(n - wave_numbers(j) + 1) > int(s, int64) - first + 1_int64) return
      last = first + 2*(n - wave_numbers(j) + 1) - 1
      covered = covered + 2_int64*(n - wave_numbers(j) + 1)
      do k = 1, j - 1
        other_first = wave_first_column(wave_numbers(k))
        other_last = other_first + 2*(n - wave_numbers(k) + 1) - 1
        if (first <= other_last .and. other_first <= last) return
      end do
    end do
    if (covered /= int(s, int64)) return
    ! The accepted one-channel copies allocate both send and receive buffers.
    ! Reversing the copy exchanges these counts and retains their total.
    copy_bytes = 63_int64 + 92_int64*v
    do peer = 1, v
      if (peer == self) cycle
      nc = layout%coefficient_start(peer + 1) - layout%coefficient_start(peer)
      nl = layout%level_start(peer + 1) - layout%level_start(peer)
      send_count = int(nl, int64)*layout%local_columns
      receive_count = int(l, int64)*nc
      if (send_count > int(huge(0_int32) - 2, int64)) return
      if (receive_count > int(huge(0_int32) - 2, int64)) return
      if (send_count > 0) copy_bytes = copy_bytes + 8_int64*(send_count + 2_int64)
      if (receive_count > 0) copy_bytes = copy_bytes + 8_int64*(receive_count + 2_int64)
    end do
    if (copy_bytes > 8589934592_int64) return
    allocate (pending%layout%coefficient_start(v + 1), pending%layout%level_start(v + 1), &
              pending%layout%pressure_partition(v), pending%vertical_mode_indices(l), &
              pending%wave_numbers(size(wave_numbers)), pending%wave_first_column(0:n), &
              pending%global_mode_eigenvalues(layout%global_levels), pending%degree_factors(0:n), stat=code)
    if (code /= 0) then
      status = 1
      return
    end if
    call copy_layout_scalars(layout, pending%layout)
    pending%layout%coefficient_start = layout%coefficient_start
    pending%layout%level_start = layout%level_start
    pending%layout%pressure_partition = layout%pressure_partition
    pending%vertical_mode_indices = vertical_mode_indices
    pending%wave_numbers = wave_numbers
    pending%wave_first_column = wave_first_column(0:n)
    pending%global_mode_eigenvalues = mode_eigenvalues(1:layout%global_levels)
    pending%degree_factors = degree_factors(0:n)
    pending%temporary_bytes_budget = temporary_bytes_budget
    pending%time_step = time_step; pending%beta_time = beta_time
    pending%stretch = stretch; pending%rotation_rate = rotation_rate
    call move_alloc(pending%layout%coefficient_start, context%layout%coefficient_start)
    call move_alloc(pending%layout%level_start, context%layout%level_start)
    call move_alloc(pending%layout%pressure_partition, context%layout%pressure_partition)
    call move_alloc(pending%vertical_mode_indices, context%vertical_mode_indices)
    call move_alloc(pending%wave_numbers, context%wave_numbers)
    call move_alloc(pending%wave_first_column, context%wave_first_column)
    call move_alloc(pending%global_mode_eigenvalues, context%global_mode_eigenvalues)
    call move_alloc(pending%degree_factors, context%degree_factors)
    call copy_layout_scalars(pending%layout, context%layout)
    context%temporary_bytes_budget = pending%temporary_bytes_budget
    context%time_step = pending%time_step; context%beta_time = pending%beta_time
    context%stretch = pending%stretch; context%rotation_rate = pending%rotation_rate
    status = 0
  end subroutine

  !> Release owned context arrays without altering coefficient values elsewhere.
  !! No communication occurs. Every active solve must finish before release.
  subroutine release_spectral_pressure_context(context)
    type(spectral_pressure_context), intent(inout) :: context
    if (allocated(context%degree_factors)) deallocate (context%degree_factors)
    if (allocated(context%global_mode_eigenvalues)) deallocate (context%global_mode_eigenvalues)
    if (allocated(context%wave_first_column)) deallocate (context%wave_first_column)
    if (allocated(context%wave_numbers)) deallocate (context%wave_numbers)
    if (allocated(context%vertical_mode_indices)) deallocate (context%vertical_mode_indices)
    if (allocated(context%layout%pressure_partition)) deallocate (context%layout%pressure_partition)
    if (allocated(context%layout%level_start)) deallocate (context%layout%level_start)
    if (allocated(context%layout%coefficient_start)) deallocate (context%layout%coefficient_start)
    context%layout%phase = 0
  end subroutine

  logical function valid_layout(c) result(ok)
    type(spectral_transpose_layout), intent(in) :: c
    integer :: v
    ok = .false.
    if (c%phase /= 7 .or. .not. c%geometry_matches .or. .not. c%hooks_disabled) return
    if (c%world < 1 .or. c%world > 65536 .or. c%rank_zero_based < 0 .or. c%rank_zero_based >= c%world) return
    if (c%horizontal_peers < 1 .or. c%vertical_peers < 1) return
    if (int(c%horizontal_peers, int64)*c%vertical_peers /= c%world) return
    if (c%horizontal_index < 1 .or. c%horizontal_index > c%horizontal_peers) return
    if (c%vertical_index < 1 .or. c%vertical_index > c%vertical_peers) return
    if (int(c%horizontal_index - 1, int64)*c%vertical_peers + c%vertical_index /= c%rank_zero_based + 1) return
    if (c%maximum_degree < 1 .or. c%maximum_degree > 8191) return
    if (c%global_levels < 1 .or. c%global_levels > 512) return
    if (c%local_levels < 0 .or. c%local_levels > c%global_levels) return
    if (c%vertical_peers > c%global_levels + 1) return
    if (c%spectral_coefficients < 0 .or. c%local_columns < 0) return
    if (.not. allocated(c%coefficient_start) .or. .not. allocated(c%level_start)) return
    if (.not. allocated(c%pressure_partition)) return
    v = c%vertical_peers
    if (size(c%coefficient_start) /= v + 1 .or. size(c%level_start) /= v + 1) return
    if (size(c%pressure_partition) /= v) return
    if (c%coefficient_start(1) /= 1 .or. c%level_start(1) /= 1) return
    if (int(c%coefficient_start(v + 1), int64) /= int(c%spectral_coefficients, int64) + 1_int64) return
    if (c%level_start(v + 1) /= c%global_levels + 1) return
    if (any(c%coefficient_start < 1) .or. any(c%level_start < 1)) return
    if (any(c%coefficient_start(2:) < c%coefficient_start(:v))) return
    if (any(c%level_start(2:) < c%level_start(:v))) return
    if (any(c%pressure_partition < 0) .or. any(c%pressure_partition > 1)) return
    if (sum(c%pressure_partition) /= 1) return
    if (c%coefficient_start(c%vertical_index + 1) - c%coefficient_start(c%vertical_index) /= c%local_columns) return
    if (c%level_start(c%vertical_index + 1) - c%level_start(c%vertical_index) /= c%local_levels) return
    ok = .true.
  end function

  subroutine copy_layout_scalars(source, destination)
    type(spectral_transpose_layout), intent(in) :: source
    type(spectral_transpose_layout), intent(inout) :: destination
    destination%phase = source%phase
    destination%world = source%world; destination%rank_zero_based = source%rank_zero_based
    destination%horizontal_peers = source%horizontal_peers; destination%vertical_peers = source%vertical_peers
    destination%horizontal_index = source%horizontal_index; destination%vertical_index = source%vertical_index
    destination%maximum_degree = source%maximum_degree; destination%global_levels = source%global_levels
    destination%local_levels = source%local_levels; destination%spectral_coefficients = source%spectral_coefficients
    destination%local_columns = source%local_columns
    destination%geometry_matches = source%geometry_matches; destination%hooks_disabled = source%hooks_disabled
  end subroutine
end module
