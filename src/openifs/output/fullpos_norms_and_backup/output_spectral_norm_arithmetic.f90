!> Retain the selected output spectral norm degree loop without a floor.
module forecast_fullpos_spectral_norm_arithmetic
  use iso_fortran_env, only: int32, int64, real64
  implicit none
  private
  public :: output_spectral_norm_matrix
contains
  !> Sum each wave in ascending degree order, then write its complete level vector.
 !! FIELD(level,real_column) is borrowed; STARTS(0:) gives one-based columns.
 !! METRIC is a source-unused selector retained in the native interface.
 !! Ordinary squared-field units are retained; no positive floor is introduced.
  subroutine output_spectral_norm_matrix(maximum_degree, waves, starts, field, metric, levels, output, status)
    integer(int32), intent(in) :: maximum_degree, waves(:), starts(0:), levels
    real(real64), intent(in) :: field(:, :)
    logical, intent(in) :: metric
    real(real64), intent(inout) :: output(:, :)
    integer(int32), intent(out) :: status
    integer :: w, m, l, n, column
    real(real64) :: sum_value, real_square, imaginary_square, coefficient, weight, product
    status = 2
    if (maximum_degree < 1 .or. maximum_degree > 8191 .or. levels < 0 .or. levels > 512) return
    if (size(waves) /= maximum_degree + 1 .or. ubound(starts, 1) < maximum_degree) return
    if (size(field, 1) < levels .or. size(output, 1) < levels .or. size(output, 2) < size(waves)) return
    do w = 1, size(waves)
      m = waves(w)
      if (m /= w - 1) return
      column = starts(m)
      if (column < 1) return
      if (int(column, int64) + 2_int64*(maximum_degree - m + 1) - 1 > size(field, 2, kind=int64)) return
    end do
    do w = 1, size(waves)
      m = waves(w)
      do l = 1, levels
        sum_value = 0.0_real64; column = starts(m)
        do n = m, maximum_degree
          real_square = field(l, column)*field(l, column)
          coefficient = real_square
          if (m /= 0) then
            imaginary_square = field(l, column + 1)*field(l, column + 1)
            coefficient = real_square + imaginary_square
          end if
          weight = 1.0_real64
          if (m /= 0) weight = 2.0_real64*weight
          product = weight*coefficient
          sum_value = sum_value + product
          column = column + 2
        end do
        output(l, w) = sum_value
      end do
    end do
    status = 0
  end subroutine
end module
