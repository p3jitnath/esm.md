module md2asm_distributed_pressure_stage
  !! Complete the generated pressure parent with both distributed copies.
  !!
  !! Typed configuration replaces compiler-specific byte offsets. The caller
  !! owns the initialized maps, coefficient arrays and public MPI communicator.
  use iso_fortran_env, only: int32, int64, real64
  use mpi_f08, only: MPI_Comm
  use md2asm_spectral_transposes, only: spectral_transpose_layout, &
                                        transpose_spectral_to_modes, transpose_modes_to_spectral, agree_spectral_partition_status
  use forecast_pressure_wave, only: solve_pressure_modes
  implicit none
  private
  public :: spectral_pressure_context, solve_distributed_pressure
  type :: spectral_pressure_context
    type(spectral_transpose_layout) :: layout
    integer(int64) :: temporary_bytes_budget = 0_int64
    integer(int32), allocatable :: vertical_mode_indices(:), wave_numbers(:)
    integer(int32), allocatable :: wave_first_column(:)
    real(real64), allocatable :: global_mode_eigenvalues(:), degree_factors(:)
    real(real64) :: time_step = 0.0_real64, beta_time = 0.0_real64
    real(real64) :: stretch = 1.0_real64, rotation_rate = 0.0_real64
  end type
contains
  subroutine solve_distributed_pressure(c, comm, rhs, solution, status)
    !! Apply TRSTOM, source-ordered local pressure solve, then TRMTOS.
    !!
    !! rhs and solution have shape(global_levels, at least local_columns).
    !! Only the active local columns are copied. Other columns are retained.
    !! rhs has inout intent to match the native copy interface; the forward
    !! copy reads it and only the private local-mode input may be changed.
    type(spectral_pressure_context), intent(in) :: c
    type(MPI_Comm), intent(in) :: comm
    real(real64), contiguous, target, intent(inout) :: rhs(:, :), solution(:, :)
    integer(int32), intent(out) :: status
    real(real64), allocatable, target :: mode_rhs(:, :), mode_solution(:, :)
    real(real64), allocatable :: eigenvalues(:)
    integer :: n, l, s, j, k, m, first, last, other_first, other_last, allocation_status
    integer(int32) :: local_status
    integer(int64) :: required_bytes, covered_columns

    local_status = 2
    n = c%layout%maximum_degree
    l = c%layout%local_levels; s = c%layout%spectral_coefficients
    admission: block
      if (n < 1 .or. n > 8191 .or. l < 0 .or. l > 512 .or. s < 0) exit admission
      if (c%layout%global_levels < 1 .or. c%layout%global_levels > 512) exit admission
      if (l > c%layout%global_levels) exit admission
      if (c%temporary_bytes_budget < 1 .or. c%temporary_bytes_budget > 2_int64**36) exit admission
      required_bytes = 16_int64*l*s + 8_int64*(5_int64*(n + 2) + l) + 16_int64*(n + 1)*l
      if (required_bytes > c%temporary_bytes_budget) exit admission
      if (size(rhs, 1) /= c%layout%global_levels .or. size(solution, 1) /= size(rhs, 1)) exit admission
      if (size(rhs, 2) < c%layout%local_columns .or. size(solution, 2) < c%layout%local_columns) exit admission
      if (.not. allocated(c%vertical_mode_indices) .or. .not. allocated(c%global_mode_eigenvalues)) exit admission
      if (.not. allocated(c%wave_numbers) .or. .not. allocated(c%wave_first_column)) exit admission
      if (.not. allocated(c%degree_factors)) exit admission
      if (size(c%vertical_mode_indices) /= l) exit admission
      if (any(c%vertical_mode_indices < 1) .or. any(c%vertical_mode_indices > size(c%global_mode_eigenvalues))) exit admission
      if (lbound(c%wave_first_column, 1) /= 0 .or. ubound(c%wave_first_column, 1) < n) exit admission
      if (lbound(c%degree_factors, 1) /= 0 .or. ubound(c%degree_factors, 1) < n) exit admission
      if (size(c%wave_numbers) > n + 1) exit admission
      covered_columns = 0
      do j = 1, size(c%wave_numbers)
        m = c%wave_numbers(j)
        if (m < 0 .or. m > n) exit admission
        first = c%wave_first_column(m)
        if (first < 1 .or. first > s + 1) exit admission
        if (2*(n - m + 1) > s - first + 1) exit admission
        last = first + 2*(n - m + 1) - 1
        covered_columns = covered_columns + 2_int64*(n - m + 1)
        do k = 1, j - 1
          other_first = c%wave_first_column(c%wave_numbers(k))
          other_last = other_first + 2*(n - c%wave_numbers(k) + 1) - 1
          if (first <= other_last .and. other_first <= last) exit admission
        end do
      end do
      if (covered_columns /= s) exit admission
      local_status = 0
    end block admission
    call agree_spectral_partition_status(comm, local_status, status)
    if (status /= 0) return
    allocate (mode_rhs(l, s), mode_solution(l, s), eigenvalues(l), stat=allocation_status)
    local_status = 0
    if (allocation_status /= 0) local_status = 1
    call agree_spectral_partition_status(comm, local_status, status)
    if (status /= 0) return
    do j = 1, l
      eigenvalues(j) = c%global_mode_eigenvalues(c%vertical_mode_indices(j))
    end do
    call transpose_spectral_to_modes(c%layout, comm, rhs(:, 1:c%layout%local_columns), mode_rhs, status)
    if (status /= 0) return
    call solve_pressure_modes(int(n, int32), c%wave_numbers, c%wave_first_column, &
                              eigenvalues, c%degree_factors, c%time_step, c%beta_time, c%stretch, c%rotation_rate, &
                              mode_rhs, mode_solution, local_status)
    call agree_spectral_partition_status(comm, local_status, status)
    if (status /= 0) return
    call transpose_modes_to_spectral(c%layout, comm, mode_solution, solution(:, 1:c%layout%local_columns), status)
  end subroutine
end module md2asm_distributed_pressure_stage
