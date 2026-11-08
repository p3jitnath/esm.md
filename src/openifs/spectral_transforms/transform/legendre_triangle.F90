!> Complete dimensionless LEGTRI recurrence in triangular storage.
module md2asm_legendre_triangle
  use iso_fortran_env, only: int32, int64, real64
  use md2asm_transform_types, only: transform_environment_ready
  use, intrinsic :: ieee_arithmetic, only: ieee_is_finite
  implicit none
  private
  public :: generate_legendre_triangle
contains
!> Read sine(latitude) and order count; update the owned real64 output prefix.
!! Output has at least count*(count+1)/2 cells; trailing cells remain unchanged.
!! Status0 succeeds; status2 refuses an unsupported input before output writes.
  subroutine generate_legendre_triangle(sine_latitude, count, output, status)
    real(real64), intent(in) :: sine_latitude
    integer(int32), intent(in) :: count
    real(real64), intent(inout) :: output(:)
    integer(int32), intent(out) :: status
    integer :: order, degree, cell, maximum_degree
    real(real64) :: cosine_latitude, factor_one, factor_two, reciprocal, order_value, order_square
    real(real64) :: twice_order, root_value, degree_square, factor, a, b, t
    real(real64), volatile :: three
    status = 2
    if (count < 2 .or. count > 256) return
    if (size(output, kind=int64) < int(count, int64)*(count + 1_int64)/2) return
    if (size(output, kind=int64) > 1048576_int64) return
    if (.not. ieee_is_finite(sine_latitude)) return
    if (abs(sine_latitude) > 1.0_real64) return
    if (.not. transform_environment_ready()) return
    maximum_degree = count - 1
    t = sine_latitude*sine_latitude
    cosine_latitude = sqrt(1.0_real64 - t)
    output(1) = 1.0_real64
    three = 3.0_real64
    factor_one = sqrt(three)
    output(2) = factor_one*sine_latitude
    cell = 2
    do order = 0, count - 1
      order_value = real(order, real64)
      order_square = order_value*order_value
      twice_order = order_value + order_value
      root_value = sqrt(twice_order + 3.0_real64)
      reciprocal = 1.0_real64/root_value
      if (order > 0) then
        factor_two = factor_one*cosine_latitude
        t = sqrt(twice_order)
        factor_two = factor_two/t
        factor_one = factor_two*root_value
        cell = cell + 1
        output(cell) = factor_two
        if (order == maximum_degree) cycle
        cell = cell + 1
        output(cell) = factor_one*sine_latitude
      end if
      do degree = order + 2, maximum_degree
        t = real(degree, real64)
        degree_square = t*t
        a = 4.0_real64*degree_square
        a = a - 1.0_real64
        b = degree_square - order_square
        a = a/b
        factor = sqrt(a)
        cell = cell + 1
        a = sine_latitude*output(cell - 1)
        b = reciprocal*output(cell - 2)
        a = a - b
        output(cell) = factor*a
        reciprocal = 1.0_real64/factor
      end do
    end do
    status = 0
  end subroutine
end module
