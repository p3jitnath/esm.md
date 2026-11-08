!> Native selected spectral children reuse the frozen arithmetic providers.
module forecast_selected_spectral_children
  use iso_fortran_env, only: int32, int64, real64
  use md2asm_spectral_rotation, only: prepare_spectral_rotation, correct_spectral_rotation
  use md2asm_spectral_thermal_operators, only: spectral_geopotential, spectral_temperature_pressure_rates
  use md2asm_vertical_operators, only: vertical_operator_matrices
  use forecast_pressure_wave, only: solve_pressure_modes, solve_pressure_wave
  implicit none
  private
  public :: vertical_operator_matrices, initialize_spectral_coriolis, finish_spectral_coriolis
 public::solve_spectral_coriolis_modes,solve_spectral_pressure_wave,form_spectral_geopotential,form_spectral_temperature_pressure_rates
contains
  !> SPCIMPFINIT; vorticity/auxiliary(level,column) have units1/s.
  subroutine initialize_spectral_coriolis(n, m, levels, first_column, coefficient, dt, rotation_rate, vorticity, auxiliary, status)
    integer(int32), intent(in) :: n, m, levels, first_column
    real(real64), intent(in) :: coefficient, dt, rotation_rate
    real(real64), intent(inout) :: vorticity(:, :), auxiliary(:, :)
    integer(int32), intent(out) :: status
    call prepare_spectral_rotation(n, m, levels, first_column, coefficient, dt, rotation_rate, vorticity, auxiliary, status)
  end subroutine
  !> SPCIMPFPOST preserves inactive and zero-wave imaginary words.
  subroutine finish_spectral_coriolis(n, m, levels, first_column, coefficient, dt, rotation_rate, divergence, vorticity, status)
    integer(int32), intent(in) :: n, m, levels, first_column
    real(real64), intent(in) :: coefficient, dt, rotation_rate
    real(real64), intent(in) :: divergence(:, :)
    real(real64), intent(inout) :: vorticity(:, :)
    integer(int32), intent(out) :: status
    call correct_spectral_rotation(n, m, levels, first_column, coefficient, dt, rotation_rate, divergence, vorticity, status)
  end subroutine
  !> Complete single-process SPCIMPFSOLVE: copy, gather modes, solve and copy.
 !! INPUT is read-only and may be strided; OUTPUT preserves unused outer rows.
 !! MY_LEVELS selects genuine global SIVP values, not a reshaped19-level table.
 !! Only the original one-process complete-wave domain is admitted here.
  subroutine solve_spectral_coriolis_modes(n, world_size, waves, first_column, my_levels, global_eigenvalues, laplacian, &
                                           dt, beta_time, stretch, rotation_rate, input, output, status)
    integer(int32), intent(in) :: n, world_size, waves(:), first_column(0:), my_levels(:)
    real(real64), intent(in) :: global_eigenvalues(:), laplacian(0:), dt, beta_time, stretch, rotation_rate, input(:, :)
    real(real64), intent(inout) :: output(:, :)
    integer(int32), intent(out) :: status
    real(real64), allocatable, target :: storage(:)
    real(real64), pointer, contiguous :: rhs(:, :), solution(:, :), values(:)
    integer :: levels, columns, j, k, m, other, first, last, ofirst, olast, allocation_status
    integer(int64) :: field_words, words
    status = 2
    levels = size(my_levels); columns = size(input, 2)
    if (n < 1 .or. n >= 8192 .or. world_size /= 1 .or. levels > 512) return
    if (size(waves) /= n + 1 .or. size(first_column) < n + 1 .or. size(laplacian) < n + 1) return
    if (size(input, 1) < levels .or. size(output, 1) < levels .or. size(output, 2) < columns) return
    if (int(columns, int64) /= (int(n, int64) + 1)*(int(n, int64) + 2)) return
    do j = 1, levels
      if (my_levels(j) < 1 .or. my_levels(j) > size(global_eigenvalues)) return
    end do
    do j = 1, size(waves)
      m = waves(j)
      if (m < 0 .or. m > n) return
      first = first_column(m)
      if (first < 1 .or. first > columns) return
      if (2*(n - m + 1) > columns - first + 1) return
      last = first + 2*(n - m + 1) - 1
      do k = 1, j - 1
        other = waves(k)
        if (other == m) return
        ofirst = first_column(other); olast = ofirst + 2*(n - other + 1) - 1
        if (first <= olast .and. ofirst <= last) return
      end do
    end do
    field_words = int(levels, int64)*int(columns, int64)
    words = 2*field_words + levels
    allocate (storage(words), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    rhs(1:levels, 1:columns) => storage(1:field_words)
    solution(1:levels, 1:columns) => storage(field_words + 1:2*field_words)
    values(1:levels) => storage(2*field_words + 1:words)
    do k = 1, columns
      do j = 1, levels
        rhs(j, k) = input(j, k)
      end do
    end do
    do j = 1, levels
      values(j) = global_eigenvalues(my_levels(j))
    end do
  call solve_pressure_modes(n, waves, first_column, values, laplacian, dt, beta_time, stretch, rotation_rate, rhs, solution, status)
    if (status == 0) then
      do k = 1, columns
        do j = 1, levels
          output(j, k) = solution(j, k)
        end do
      end do
    end if
    deallocate (storage)
  end subroutine
  !> Complete SIMPLICO with private workspace and exact real/complex stages.
 !! RHS/SOLUTION have shape(capacity,2,m:n); coefficients span m:n+1.
 !! Zero wave clears every imaginary capacity row as in the source.
  subroutine solve_spectral_pressure_wave(m, n, active, alpha, reciprocal, plus, minus, eigenvalues, laplacian, time_squared, &
                                          rhs, solution, status)
    integer(int32), intent(in) :: m, n, active
    real(real64), intent(in) :: alpha(m:), reciprocal(m:), plus(m:), minus(m:), eigenvalues(:), laplacian(0:), time_squared
    real(real64), intent(inout), contiguous :: rhs(:, :, m:), solution(:, :, m:)
    integer(int32), intent(out) :: status
    real(real64), allocatable :: workspace(:, :, :)
    integer :: allocation_status
    status = 2
    if (m < 0 .or. m > n .or. n >= 8192 .or. active < 0 .or. active > size(rhs, 1)) return
    if (size(rhs, 2) /= 2 .or. size(rhs, 3) /= n - m + 1) return
    if (any(shape(solution) /= shape(rhs))) return
    if (size(alpha) < n - m + 2 .or. size(reciprocal) < n - m + 2 .or. size(plus) < n - m + 2 .or. size(minus) < n - m + 2) return
    if (size(eigenvalues) < active .or. size(laplacian) < n + 1) return
    allocate (workspace(size(rhs, 1), 2, m:n), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    call solve_pressure_wave(m, n, active, alpha, reciprocal, plus, minus, eigenvalues, laplacian, time_squared, &
                             rhs, solution, workspace, status)
    deallocate (workspace)
  end subroutine
  !> SIGAM uses the exact scalar vertical route, including its IBOT/11 pass.
 !! Temperatures are K, RD is J/(kg K), GAMMA is J/kg.
  subroutine form_spectral_geopotential(temperature, log_pressure, rd, surface, alpha, delta, metric, finite_elements, &
                                        tables, integral_bc, derivative_bc, gamma, status)
    real(real64), intent(in) :: temperature(:, :), log_pressure(:), rd, surface, alpha(:), delta(:), metric(:)
    logical, intent(in) :: finite_elements
    type(vertical_operator_matrices), intent(in) :: tables
    integer, intent(in) :: integral_bc, derivative_bc
    real(real64), intent(inout) :: gamma(:, :)
    integer(int32), intent(out) :: status
    call spectral_geopotential(temperature, log_pressure, rd, surface, alpha, delta, metric, finite_elements, &
                               tables, integral_bc, derivative_bc, gamma, status)
  end subroutine
  !> SITNU uses its complete scalar ITOP/11 route and source surface rate.
 !! Divergence is1/s, THERMAL_RATE is K/s and PRESSURE_RATE is1/s.
  subroutine form_spectral_temperature_pressure_rates(divergence, kappa, thermal_coefficient, surface_coefficient, &
         accumulation_weight, mean_weight, delta, alpha, metric, full_weight, finite_elements, tables, integral_bc, derivative_bc, &
                                                      thermal_rate, pressure_rate, status)
    real(real64), intent(in) :: divergence(:, :), kappa, thermal_coefficient, surface_coefficient
    real(real64), intent(in) :: accumulation_weight(:), mean_weight(:), delta(:), alpha(:), metric(:), full_weight(:)
    logical, intent(in) :: finite_elements
    type(vertical_operator_matrices), intent(in) :: tables
    integer, intent(in) :: integral_bc, derivative_bc
    real(real64), intent(inout) :: thermal_rate(:, :), pressure_rate(:)
    integer(int32), intent(out) :: status
    call spectral_temperature_pressure_rates(divergence, kappa, thermal_coefficient, surface_coefficient, &
         accumulation_weight, mean_weight, delta, alpha, metric, full_weight, finite_elements, tables, integral_bc, derivative_bc, &
                                             thermal_rate, pressure_rate, status)
  end subroutine
end module forecast_selected_spectral_children
