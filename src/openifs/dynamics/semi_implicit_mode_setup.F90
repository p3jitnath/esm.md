!> Build vertical pressure modes from the initialized reference coefficients.
!! This owns the SUBMAT identity response, SUSI ordering and matrix inverses.
module md2asm_semi_implicit_mode_setup
  use iso_fortran_env, only: int32, real64
  use ieee_arithmetic, only: ieee_is_finite
  use md2asm_semi_implicit_mode_storage, only: semi_implicit_mode_state, semi_implicit_environment_supported
  use md2asm_semi_implicit_eigenvalues, only: compute_mode_eigenvalues
  use md2asm_scaled_mode_matrix_inverse, only: invert_scaled_mode_matrix
  use md2asm_spectral_implicit_update, only: spectral_implicit_coefficients
  use md2asm_vertical_operators, only: vertical_operator_matrices
  use md2asm_spectral_thermal_operators, only: spectral_geopotential, spectral_temperature_pressure_rates
  use md2asm_operational_spectral_thermal, only: spectral_geopotential_public
  use md2asm_operational_temperature_pressure_rates, only: spectral_temperature_pressure_rates_public
  implicit none
  private
  public :: semi_implicit_mode_controls, initialize_semi_implicit_modes, initialize_operational_semi_implicit_modes
  type :: semi_implicit_mode_controls
    logical :: finite_elements = .true., diagonal_implicit = .false., extended_diagonal = .false.
    logical :: stability_modification = .false.
    integer :: integral_bc = 3, derivative_bc = 3
    real(real64) :: reference_pressure = 0.0_real64, normalization = 0.0_real64
  end type
contains
  !> Construct modes with the accepted ordered scalar vertical operator.
  !! All input coefficients and matrices are borrowed and read only.
  subroutine initialize_semi_implicit_modes(control, coef, tables, state, status)
    type(semi_implicit_mode_controls), intent(in) :: control
    type(spectral_implicit_coefficients), intent(in) :: coef
    type(vertical_operator_matrices), intent(in) :: tables
    type(semi_implicit_mode_state), intent(inout) :: state
    integer(int32), intent(out) :: status
    call initialize_modes(control, coef, tables, state, .false., 1, status)
  end subroutine

  !> Construct operational modes with the original public BLAS matrix route.
  !! vertical_chunk is the actual initialized geometry NPROMA, not a default.
  !! pressure_response(level,level) is squared wave speed(m**2/s**2).
  !! eigenvalues(level) has the same units. modes and inverse_modes have no
  !! unit; inverse_response has reciprocal squared-speed units. All five
  !! dense state arrays must already be allocated for levels1:255.
  !! The response, modes and inverse arrays change in original source order.
  !! A later refusal leaves the complete calculation unaccepted. Status0
  !! succeeds,1 refuses storage,2 refuses admission,3 refuses a numerical solve.
  subroutine initialize_operational_semi_implicit_modes(control, coef, tables, state, vertical_chunk, status)
    type(semi_implicit_mode_controls), intent(in) :: control
    type(spectral_implicit_coefficients), intent(in) :: coef
    type(vertical_operator_matrices), intent(in) :: tables
    type(semi_implicit_mode_state), intent(inout) :: state
    integer, intent(in) :: vertical_chunk
    integer(int32), intent(out) :: status
    call initialize_modes(control, coef, tables, state, .true., vertical_chunk, status)
  end subroutine

  subroutine initialize_modes(control, coef, tables, state, public_matrix, vertical_chunk, status)
    type(semi_implicit_mode_controls), intent(in) :: control
    type(spectral_implicit_coefficients), intent(in) :: coef
    type(vertical_operator_matrices), intent(in) :: tables
    type(semi_implicit_mode_state), intent(inout) :: state
    logical, intent(in) :: public_matrix
    integer, intent(in) :: vertical_chunk
    integer(int32), intent(out) :: status
    real(real64), allocatable :: identity(:, :), thermal(:, :), pressure(:), eigenmatrix(:, :)
    real(real64), allocatable :: real_values(:), imaginary_values(:), vectors(:, :), real_work(:)
    real(real64), allocatable :: sorted_vectors(:, :), sorted_real(:), sorted_imaginary(:)
    integer(int32), allocatable :: integer_work(:), order(:)
    integer :: n, row, column, source_column, pass, next, code
    integer(int32) :: swap
    logical :: changed
    real(real64) :: maximum_imaginary, sum_value, product, root, value
    status = 2
    if (.not. semi_implicit_environment_supported()) return
    if (control%diagonal_implicit .or. control%extended_diagonal .or. control%stability_modification) return
    if (public_matrix .and. vertical_chunk < 1) return
    if (.not. ieee_is_finite(control%reference_pressure) .or. .not. ieee_is_finite(control%normalization)) return
    if (control%reference_pressure <= 0.0_real64 .or. control%normalization <= 0.0_real64) return
    if (.not. allocated(state%eigenvalues)) return
    n = size(state%eigenvalues)
    if (n < 1 .or. n > 255) return
    if (.not. allocated(state%pressure_response) .or. .not. allocated(state%modes)) return
    if (.not. allocated(state%inverse_modes) .or. .not. allocated(state%inverse_response)) return
    if (any(shape(state%pressure_response) /= [n, n]) .or. any(shape(state%modes) /= [n, n])) return
    if (any(shape(state%inverse_modes) /= [n, n]) .or. any(shape(state%inverse_response) /= [n, n])) return
    if (.not. associated(coef%alpha) .or. .not. associated(coef%delta)) return
    if (.not. associated(coef%accumulation_weight) .or. .not. associated(coef%mean_weight)) return
    if (.not. associated(coef%metric) .or. .not. associated(coef%full_level_weight)) return
    if (size(coef%alpha) < n .or. size(coef%delta) < n) return
    if (size(coef%accumulation_weight) < n .or. size(coef%mean_weight) < n) return
    if (size(coef%metric) < n .or. size(coef%full_level_weight) < n) return
    do row = 1, n
      if (.not. ieee_is_finite(coef%accumulation_weight(row))) return
      if (coef%accumulation_weight(row) <= 0.0_real64) return
    end do
    if (control%finite_elements) then
      if (control%integral_bc /= 3) return
      if (.not. associated(tables%rintbf11)) return
      if (any(shape(tables%rintbf11) /= [n + 1, n + 2])) return
      if (.not. is_contiguous(tables%rintbf11)) return
    end if
    allocate (identity(n, n), thermal(n, n), pressure(n), eigenmatrix(n, n), &
              real_values(n), imaginary_values(n), vectors(n, n), real_work(n), &
              sorted_vectors(n, n), sorted_real(n), sorted_imaginary(n), integer_work(n), order(n), stat=code)
    if (code /= 0) then
      status = 1
      return
    end if
    do column = 1, n
      do row = 1, n
        identity(row, column) = 0.0_real64
        if (row == column) identity(row, column) = 1.0_real64
      end do
    end do
    if (public_matrix) then
      call spectral_temperature_pressure_rates_public(identity, coef%kappa, coef%thermal_coefficient, &
                                           coef%pressure_rate_coefficient, coef%accumulation_weight, coef%mean_weight, coef%delta, &
                                                 coef%alpha, coef%metric, coef%full_level_weight, control%finite_elements, tables, &
                                              control%integral_bc, control%derivative_bc, vertical_chunk, thermal, pressure, status)
    else
      call spectral_temperature_pressure_rates(identity, coef%kappa, coef%thermal_coefficient, &
                                           coef%pressure_rate_coefficient, coef%accumulation_weight, coef%mean_weight, coef%delta, &
                                               coef%alpha, coef%metric, coef%full_level_weight, control%finite_elements, tables, &
                                               control%integral_bc, control%derivative_bc, thermal, pressure, status)
    end if
    if (status /= 0) return
    if (public_matrix) then
      call spectral_geopotential_public(thermal, pressure, coef%rd, coef%geopotential_surface, &
                                        coef%alpha, coef%delta, coef%metric, control%finite_elements, tables, &
                                        control%integral_bc, control%derivative_bc, vertical_chunk, identity, status)
    else
      call spectral_geopotential(thermal, pressure, coef%rd, coef%geopotential_surface, &
                                 coef%alpha, coef%delta, coef%metric, control%finite_elements, tables, &
                                 control%integral_bc, control%derivative_bc, identity, status)
    end if
    if (status /= 0) return
    state%pressure_response = identity
    eigenmatrix = identity
    call compute_mode_eigenvalues(eigenmatrix, real_values, imaginary_values, vectors, integer_work, real_work, status)
    if (status /= 0) return
    do column = 1, n
      order(column) = column
    end do
    pass = n - 1
    do
      changed = .false.
      do column = 1, pass
        next = column + 1
        if (real_values(order(column)) > real_values(order(next))) then
          swap = order(column)
          order(column) = order(next)
          order(next) = swap
          changed = .true.
        end if
      end do
      if (.not. changed) exit
    end do
    do column = 1, n
      source_column = order(column)
      sorted_real(column) = real_values(source_column)
      sorted_imaginary(column) = imaginary_values(source_column)
      do row = 1, n
        sorted_vectors(row, column) = vectors(row, source_column)
      end do
    end do
    maximum_imaginary = sorted_imaginary(1)
    do column = 1, n
      state%eigenvalues(n - column + 1) = sorted_real(column)
      if (.not. (maximum_imaginary >= sorted_imaginary(column))) maximum_imaginary = sorted_imaginary(column)
      do row = 1, n
        state%modes(row, n - column + 1) = sorted_vectors(row, column)
      end do
    end do
    do column = 1, n
      sum_value = 0.0_real64
      do row = 1, n
        product = state%modes(row, column)*state%modes(row, column)
        product = product*coef%accumulation_weight(row)
        sum_value = sum_value + product
      end do
      value = sum_value/control%reference_pressure
      value = value/control%normalization
      root = sqrt(value)
      do row = 1, n
        state%modes(row, column) = state%modes(row, column)/root
      end do
    end do
    do column = 1, n
      if (state%modes(n, column) < 0.0_real64) then
        do row = 1, n
          state%modes(row, column) = -state%modes(row, column)
        end do
      end if
    end do
    call invert_scaled_mode_matrix(state%modes, state%inverse_modes, status)
    if (status /= 0) return
    if (maximum_imaginary /= 0.0_real64) then
      status = 3
      return
    end if
    call invert_scaled_mode_matrix(state%pressure_response, state%inverse_response, status)
  end subroutine
end module
