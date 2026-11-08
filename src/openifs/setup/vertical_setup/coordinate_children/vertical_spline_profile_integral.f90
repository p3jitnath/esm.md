!> Apply the frozen scalar spline integral with its two positive-zero boundary terms.
module forecast_vertical_spline_profile
  use iso_c_binding, only: c_int, c_double
  implicit none
  private
  public :: integrate_vertical_spline_profile
contains
  !> Integrate one dimensionless profile through the supplied spline matrix.
  !! n is19 or137. matrix has shape(n+1,n+2), profile has n words and
  !! integrated has n+1 words. Buffers are disjoint and aligned for FP64.
  !! Columns are accumulated in increasing order, including both zero terms.
  !! The output is volatile so diagnostic-only source integrations remain.
  !! Return2 changes no output; return0 writes every integrated word.
  integer(c_int) function integrate_vertical_spline_profile(n, matrix, profile, integrated) &
    bind(C, name="md2asm_integrate_vertical_spline_profile_fortran") result(status)
    integer(c_int), value, intent(in) :: n
    real(c_double), intent(in) :: matrix(n + 1, n + 2), profile(n)
    real(c_double), intent(inout), volatile :: integrated(n + 1)
    real(c_double) :: extended(n + 2), total, product
    integer :: row, column
    status = 2
    if (n /= 19 .and. n /= 137) return
    extended(1) = 0.0_c_double
    extended(n + 2) = 0.0_c_double
    do column = 1, n
      extended(column + 1) = profile(column)
    end do
    do row = 1, n + 1
      total = 0.0_c_double
      do column = 1, n + 2
        product = extended(column)*matrix(row, column)
        total = total + product
      end do
      integrated(row) = total
    end do
    status = 0
  end function
end module forecast_vertical_spline_profile
