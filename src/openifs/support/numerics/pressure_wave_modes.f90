module forecast_pressure_wave
  !! Solve local spectral pressure modes in binary64 arithmetic.
  !!
  !! The calculations are a structured port of runtime_pressure_wave_solve.S
  !! and runtime_pressure_recurrence_workspace.S. Each assignment preserves
  !! one rounded arithmetic operation. The caller owns both distributed
  !! transposes and supplies their local matrices and source map.
  use, intrinsic :: iso_fortran_env, only: int32, real64
  implicit none
  private
  public :: solve_pressure_modes, solve_pressure_wave

contains

  subroutine solve_pressure_modes(truncation, wave_numbers, wave_first_column, &
                                  mode_eigenvalues, degree_factors, time_step, beta_time, stretch, &
                                  rotation_rate, rhs, solution, status)
    !! Solve all local wave numbers after the forward transpose.
    !!
    !! Dimensions are counts. Wave numbers and degree factors start at zero.
    !! first_column(m) is a one-based matrix column. Each degree has two
    !! columns, with its real column first. The first matrix dimension is
    !! the mode capacity. Only size(mode_eigenvalues) rows are active.
    !! rhs is changed only to clear imaginary rows for wave zero.
    !! solution receives the pressure correction. Other rows are retained.
    integer(int32), intent(in) :: truncation
    integer(int32), intent(in) :: wave_numbers(:), wave_first_column(0:)
    real(real64), intent(in) :: mode_eigenvalues(:), degree_factors(0:)
    real(real64), intent(in) :: time_step, beta_time, stretch, rotation_rate
    real(real64), contiguous, target, intent(inout) :: rhs(:, :), solution(:, :)
    integer(int32), intent(out) :: status
    real(real64), allocatable :: alpha(:), reciprocal(:), epsilon(:)
    real(real64), allocatable :: plus(:), minus(:), workspace(:, :, :)
    real(real64), pointer, contiguous :: wave_rhs(:, :, :), wave_solution(:, :, :)
    real(real64) :: b, time_factor_squared, coriolis, wave_factor
    real(real64) :: rn, rnp1, product, temporary, other, denominator, rm
    integer :: n, m, j, first, last, capacity, active, allocation_status

    status = 2_int32
    n = int(truncation)
    capacity = size(rhs, 1)
    active = size(mode_eigenvalues)
    if (n < 1 .or. n >= 8192 .or. active > 512) return
    if (size(solution, 1) /= capacity .or. size(solution, 2) /= size(rhs, 2)) return
    if (active > capacity .or. size(degree_factors) < n + 1) return
    if (size(wave_numbers) > n + 1 .or. size(wave_first_column) < n + 1) return
    do j = 1, size(wave_numbers)
      m = int(wave_numbers(j))
      if (m < 0 .or. m > n) return
      first = int(wave_first_column(m))
      if (first < 1 .or. first > size(rhs, 2) + 1) return
      if (2*(n - m + 1) > size(rhs, 2) - first + 1) return
    end do
    allocate (alpha(0:n + 1), reciprocal(0:n + 1), epsilon(0:n + 1), &
              plus(0:n + 1), minus(0:n + 1), workspace(capacity, 2, 0:n), stat=allocation_status)
    if (allocation_status /= 0) return

    b = 0.5_real64*time_step
    b = b*beta_time
    time_factor_squared = b*stretch
    time_factor_squared = time_factor_squared*time_factor_squared
    coriolis = 2.0_real64*b
    coriolis = coriolis*rotation_rate
    do j = 1, size(wave_numbers)
      m = int(wave_numbers(j))
      rm = real(m, real64)
      wave_factor = coriolis*rm
      if (m == 0) then
        alpha(0) = 0.0_real64
        reciprocal(0) = 0.0_real64
        epsilon(0) = 0.0_real64
        plus(0) = 0.0_real64
        minus(0) = 0.0_real64
      end if
      do first = max(1, m), n
        rn = real(first, real64)
        rnp1 = rn + 1.0_real64
        product = rn*rnp1
        alpha(first) = wave_factor/product
        temporary = alpha(first)*alpha(first)
        temporary = 1.0_real64 + temporary
        reciprocal(first) = 1.0_real64/temporary
        temporary = rn*rn
        other = rm*rm
        temporary = temporary - other
        denominator = 4.0_real64*rn
        denominator = denominator*rn
        denominator = denominator - 1.0_real64
        temporary = temporary/denominator
        epsilon(first) = sqrt(temporary)
      end do
      alpha(n + 1) = 0.0_real64
      reciprocal(n + 1) = 0.0_real64
      do first = max(1, m), n - 1
        rn = real(first, real64)
        rnp1 = rn + 1.0_real64
        temporary = coriolis*rn
        temporary = temporary*epsilon(first + 1)
        plus(first) = temporary/rnp1
        temporary = coriolis*rnp1
        temporary = temporary*epsilon(first)
        minus(first) = temporary/rn
      end do
      rn = real(n, real64)
      rnp1 = rn + 1.0_real64
      temporary = coriolis*rnp1
      temporary = temporary*epsilon(n)
      minus(n) = temporary/rn
      plus(n) = 0.0_real64
      plus(n + 1) = 0.0_real64
      minus(n + 1) = 0.0_real64

      first = int(wave_first_column(m))
      last = first + 2*(n - m + 1) - 1
      wave_rhs(1:capacity, 1:2, m:n) => rhs(:, first:last)
      wave_solution(1:capacity, 1:2, m:n) => solution(:, first:last)
      call solve_pressure_wave(int(m, int32), truncation, int(active, int32), &
                               alpha(m:), reciprocal(m:), plus(m:), minus(m:), mode_eigenvalues, &
                               degree_factors, time_factor_squared, wave_rhs, wave_solution, &
                               workspace(:, :, m:n), status)
      if (status /= 0_int32) return
    end do
    status = 0_int32
  end subroutine solve_pressure_modes

  subroutine solve_pressure_wave(m, truncation, active_modes, alpha, reciprocal, &
                                 plus, minus, mode_eigenvalues, degree_factors, time_factor_squared, &
                                 rhs, solution, workspace, status)
    !! Solve the real and imaginary parts for one wave number.
    !!
    !! rhs, solution and workspace have shape (mode_capacity,2,m:truncation).
    !! Coefficients have bounds m:truncation+1. Workspace is private scratch.
    !! Rows above active_modes are unchanged, except that wave zero clears
    !! every imaginary row of rhs and solution to positive zero.
    integer(int32), intent(in) :: m, truncation, active_modes
    real(real64), intent(in) :: alpha(m:), reciprocal(m:), plus(m:), minus(m:)
    real(real64), intent(in) :: mode_eigenvalues(:), degree_factors(0:)
    real(real64), intent(in) :: time_factor_squared
    real(real64), contiguous, intent(inout) :: rhs(:, :, m:), solution(:, :, m:)
    real(real64), contiguous, intent(inout) :: workspace(:, :, m:)
    integer(int32), intent(out) :: status
    integer :: n, parity, degree, row, first_degree, tail, capacity, active
    real(real64) :: diagonal_real, diagonal_imag, upper_real, upper_imag
    real(real64) :: lower_real, lower_imag, a, b, rr, ri, temporary, other
    real(real64) :: inverse_denominator, inverse_real, inverse_imag
    real(real64) :: previous_real, previous_imag, next_real, next_imag
    real(real64) :: current_real, current_imag, work_real, work_imag
    logical :: first

    status = 2_int32
    n = int(truncation)
    active = int(active_modes)
    capacity = size(rhs, 1)
    if (m < 0 .or. m > n .or. n >= 8192 .or. active < 0 .or. active > capacity) return
    if (active > size(mode_eigenvalues) .or. size(degree_factors) < n + 1) return
    if (size(alpha) < n - m + 2 .or. size(reciprocal) < n - m + 2) return
    if (size(plus) < n - m + 2 .or. size(minus) < n - m + 2) return
    if (size(rhs, 2) /= 2 .or. size(rhs, 3) /= n - m + 1) return
    if (any(shape(solution) /= shape(rhs)) .or. any(shape(workspace) /= shape(rhs))) return
    if (m == 0) then
      do degree = 0, n
        do row = 1, capacity
          rhs(row, 2, degree) = 0.0_real64
          solution(row, 2, degree) = 0.0_real64
        end do
      end do
    end if

    do parity = 0, 1
      if (parity == 1 .and. m == n) exit
      first_degree = int(m) + parity
      do degree = first_degree, n, 2
        first = degree == first_degree
        if (m == 0) then
          upper_real = plus(degree)*plus(degree + 1)
          if (first) then
            diagonal_real = plus(degree)*minus(degree + 1)
            diagonal_real = 1.0_real64 + diagonal_real
            if (parity == 1) then
              temporary = minus(degree)*plus(degree - 1)
              diagonal_real = diagonal_real + temporary
            end if
          else
            diagonal_real = minus(degree)*plus(degree - 1)
            diagonal_real = 1.0_real64 + diagonal_real
            temporary = plus(degree)*minus(degree + 1)
            diagonal_real = diagonal_real + temporary
            lower_real = minus(degree - 1)*minus(degree)
          end if
          do row = 1, active
            a = time_factor_squared*mode_eigenvalues(row)
            a = a*degree_factors(degree)
            a = diagonal_real - a
            rr = rhs(row, 1, degree)
            if (.not. first) then
              temporary = lower_real*workspace(row, 1, degree - 2)
              a = a + temporary
              temporary = lower_real*solution(row, 1, degree - 2)
              rr = temporary + rr
            end if
            inverse_denominator = a*a
            inverse_denominator = 1.0_real64/inverse_denominator
            inverse_real = -a
            inverse_real = inverse_real*inverse_denominator
            solution(row, 1, degree) = inverse_real*rr
            workspace(row, 1, degree) = inverse_real*upper_real
          end do
        else
          if (first) then
            diagonal_real = reciprocal(degree + 1)*plus(degree)
            diagonal_real = diagonal_real*minus(degree + 1)
            diagonal_real = 1.0_real64 + diagonal_real
            diagonal_imag = -alpha(degree)
            temporary = reciprocal(degree + 1)*alpha(degree + 1)
            temporary = temporary*plus(degree)
            temporary = temporary*minus(degree + 1)
            diagonal_imag = diagonal_imag + temporary
            if (parity == 1) then
              temporary = reciprocal(degree - 1)*minus(degree)
              temporary = temporary*plus(degree - 1)
              diagonal_real = diagonal_real + temporary
              temporary = reciprocal(degree - 1)*alpha(degree - 1)
              temporary = temporary*minus(degree)
              temporary = temporary*plus(degree - 1)
              diagonal_imag = diagonal_imag + temporary
            end if
          else
            diagonal_real = reciprocal(degree - 1)*minus(degree)
            diagonal_real = diagonal_real*plus(degree - 1)
            diagonal_real = 1.0_real64 + diagonal_real
            diagonal_imag = -alpha(degree)
            temporary = reciprocal(degree - 1)*alpha(degree - 1)
            temporary = temporary*minus(degree)
            temporary = temporary*plus(degree - 1)
            diagonal_imag = diagonal_imag + temporary
            lower_real = reciprocal(degree - 1)*minus(degree - 1)
            lower_real = lower_real*minus(degree)
            lower_imag = alpha(degree - 1)*lower_real
            temporary = reciprocal(degree + 1)*plus(degree)
            temporary = temporary*minus(degree + 1)
            diagonal_real = diagonal_real + temporary
            temporary = reciprocal(degree + 1)*alpha(degree + 1)
            temporary = temporary*plus(degree)
            temporary = temporary*minus(degree + 1)
            diagonal_imag = diagonal_imag + temporary
          end if
          upper_real = reciprocal(degree + 1)*plus(degree)
          upper_real = upper_real*plus(degree + 1)
          upper_imag = alpha(degree + 1)*upper_real
          do row = 1, active
            a = time_factor_squared*mode_eigenvalues(row)
            a = a*degree_factors(degree)
            a = diagonal_real - a
            b = diagonal_imag
            rr = rhs(row, 1, degree)
            ri = rhs(row, 2, degree)
            if (.not. first) then
              previous_real = workspace(row, 1, degree - 2)
              previous_imag = workspace(row, 2, degree - 2)
              temporary = lower_real*previous_real
              a = a + temporary
              temporary = lower_imag*previous_imag
              a = a - temporary
              temporary = lower_imag*previous_real
              b = b + temporary
              temporary = lower_real*previous_imag
              b = b + temporary
              previous_real = solution(row, 1, degree - 2)
              previous_imag = solution(row, 2, degree - 2)
              temporary = lower_real*previous_real
              other = lower_imag*previous_imag
              temporary = temporary - other
              rr = temporary + rr
              temporary = lower_imag*previous_real
              other = lower_real*previous_imag
              temporary = temporary + other
              ri = temporary + ri
            end if
            inverse_denominator = a*a
            temporary = b*b
            inverse_denominator = inverse_denominator + temporary
            inverse_denominator = 1.0_real64/inverse_denominator
            inverse_real = -a
            inverse_real = inverse_real*inverse_denominator
            inverse_imag = b*inverse_denominator
            temporary = inverse_real*rr
            other = inverse_imag*ri
            solution(row, 1, degree) = temporary - other
            temporary = inverse_imag*rr
            other = inverse_real*ri
            solution(row, 2, degree) = temporary + other
            temporary = inverse_real*upper_real
            other = inverse_imag*upper_imag
            workspace(row, 1, degree) = temporary - other
            temporary = inverse_imag*upper_real
            other = inverse_real*upper_imag
            workspace(row, 2, degree) = temporary + other
          end do
        end if
      end do

      tail = n - modulo(n - int(m) + parity, 2)
      do row = 1, active
        solution(row, 1, tail) = -solution(row, 1, tail)
        if (m /= 0) solution(row, 2, tail) = -solution(row, 2, tail)
      end do
      do degree = tail - 2, first_degree, -2
        do row = 1, active
          work_real = workspace(row, 1, degree)
          next_real = solution(row, 1, degree + 2)
          current_real = solution(row, 1, degree)
          if (m == 0) then
            temporary = work_real*next_real
            solution(row, 1, degree) = temporary - current_real
          else
            work_imag = workspace(row, 2, degree)
            next_imag = solution(row, 2, degree + 2)
            current_imag = solution(row, 2, degree)
            temporary = work_real*next_real
            other = work_imag*next_imag
            temporary = temporary - other
            solution(row, 1, degree) = temporary - current_real
            temporary = work_imag*next_real
            other = work_real*next_imag
            temporary = temporary + other
            solution(row, 2, degree) = temporary - current_imag
          end if
        end do
      end do
    end do
    status = 0_int32
  end subroutine solve_pressure_wave
end module forecast_pressure_wave
