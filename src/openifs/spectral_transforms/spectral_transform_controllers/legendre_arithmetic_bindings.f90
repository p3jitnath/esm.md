!> Typed bindings to the unchanged own Legendre matrix calculations.
module forecast_native_legendre_arithmetic_bindings
  use iso_fortran_env, only: int32, real64
  use md2asm_transform_types, only: transform_spectral_tables
  use md2asm_legendre_matrix_transforms, only: analyse_legendre_wave, reconstruct_legendre_wave
  implicit none
  private
  public :: leinv, ledir
contains
!> Reconstruct (field,latitude) pairs from (degree,field), retaining units and order.
  subroutine leinv(t, m, im, width, selected, fields, first, latitudes, input, anti, sym, status)
    type(transform_spectral_tables), intent(in) :: t
    integer(int32), intent(in) :: m, im, width, selected, fields, first, latitudes
    real(real64), intent(in) :: input(:, :)
    real(real64), intent(inout) :: anti(:, :), sym(:, :)
    integer(int32), intent(out) :: status
    call reconstruct_legendre_wave(t, m, im, width, selected, fields, first, latitudes, input, anti, sym, status)
  end subroutine
!> Analyse the two latitude parities with immutable Gaussian weights.
  subroutine ledir(t, m, im, width, selected, first, latitudes, output_width, anti, sym, output, weights, status)
    type(transform_spectral_tables), intent(in) :: t
    integer(int32), intent(in) :: m, im, width, selected, first, latitudes, output_width
    real(real64), intent(in) :: anti(:, :), sym(:, :), weights(:)
    real(real64), intent(inout) :: output(:, :)
    integer(int32), intent(out) :: status
    call analyse_legendre_wave(t, m, im, width, selected, first, latitudes, output_width, anti, sym, output, weights, status)
  end subroutine
end module
