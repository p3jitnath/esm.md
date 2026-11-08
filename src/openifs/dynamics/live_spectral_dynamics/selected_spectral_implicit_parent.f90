!> The selected SPCSI entry retains its exact scalar vertical calculation.
module forecast_selected_spectral_implicit_parent
  use iso_fortran_env, only: int32, int64, real64
  use md2asm_vertical_operators, only: vertical_operator_matrices
  use md2asm_spectral_implicit_update, only: spectral_implicit_controls, spectral_implicit_coefficients, &
                                             apply_spectral_implicit_update, spectral_implicit_child_calls
  use md2asm_vertical_matrix_product, only: apply_vertical_matrix_product
  implicit none
  private
  public :: spectral_implicit_controls, spectral_implicit_coefficients, vertical_operator_matrices
  public :: update_selected_spectral_implicit_fields, multiply_selected_vertical_matrix, selected_spectral_implicit_child_calls
  abstract interface
    subroutine pressure_stage_interface(rhs, solution, active_columns, full_columns, status)
      import real64, int32
      real(real64), intent(inout) :: rhs(:, :), solution(:, :)
      integer, intent(in) :: active_columns, full_columns
      integer(int32), intent(out) :: status
    end subroutine
    function agreement_interface(local_status) result(global_status)
      import int32
      integer(int32), intent(in) :: local_status
      integer(int32) :: global_status
    end function
  end interface
contains
  !> Borrow the one canonical controls/coefficient owner and real pressure stage.
 !! Arrays use(level,column); temperature is K and divergence is1/s.
 !! PRESSURE_STAGE must be the production native distributed copy/solve,
 !! and AGREE must use that live partition. Neither may provide omitted math.
 !! Scalar SIGAM/SITNU remain distinct from the newer public-DGEMM route.
  subroutine update_selected_spectral_implicit_fields(control, coefficients, tables, nptrsv, nvalue, divergence, temperature, &
                                                      log_pressure, divergence_tendency, pressure_stage, agree, status)
    type(spectral_implicit_controls), intent(in) :: control
    type(spectral_implicit_coefficients), intent(in) :: coefficients
    type(vertical_operator_matrices), intent(in) :: tables
    integer(int32), intent(in) :: nptrsv(:), nvalue(:)
    real(real64), intent(inout) :: divergence(:, :), temperature(:, :), log_pressure(:)
    real(real64), intent(in) :: divergence_tendency(:, :)
    procedure(pressure_stage_interface) :: pressure_stage
    procedure(agreement_interface) :: agree
    integer(int32), intent(out) :: status
    call apply_spectral_implicit_update(control, coefficients, tables, nptrsv, nvalue, divergence, temperature, log_pressure, &
                                        divergence_tendency, pressure_stage, agree, status)
  end subroutine
  !> Reuse the source's ordered vertical matrix product; workspace is borrowed.
  subroutine multiply_selected_vertical_matrix(matrix, input, output, workspace, status)
    real(real64), intent(in) :: matrix(:, :), input(:, :)
    real(real64), intent(inout) :: output(:, :), workspace(:)
    integer(int32), intent(out) :: status
    call apply_vertical_matrix_product(matrix, input, output, workspace, status)
  end subroutine
  function selected_spectral_implicit_child_calls(index) result(value)
    integer, intent(in) :: index
    integer(int64) :: value
    value = spectral_implicit_child_calls(index)
  end function
end module forecast_selected_spectral_implicit_parent
