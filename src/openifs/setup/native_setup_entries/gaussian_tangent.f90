!> Calculate the bounded Gaussian tangent in its original operation order.
!! This source follows gaussian_tangent.S and uses its exact fixed tables.
!! The calculation derives from the GNU libc 2.38 IBM Accurate Math Library.
!! Copyright (C) 2001-2023 Free Software Foundation, Inc.
!! LGPL-2.1-or-later; without warranty.
module forecast_gaussian_tangent
  use iso_c_binding, only: c_double, c_int64_t
  use forecast_gaussian_tangent_constants
  use forecast_spline_scalar_inverse, only: rounded_product_sum
  implicit none
  private
  public :: gaussian_tangent, md2asm_gaussian_tangent
  interface md2asm_gaussian_tangent
    module procedure gaussian_tangent
  end interface
  interface
    subroutine reject_tangent() bind(C, name="abort")
    end subroutine
  end interface
contains
  !> Return tan(angle) on the closed interval [1/16,25/16] radians.
 !! angle is an input FP64 scalar in radians; the result is dimensionless.
 !! The fixed table is read only, and no caller-owned object is changed.
 !! Unsupported inputs call the public abort service, as in the source.
 !! Each rounded_product_sum preserves the existing single-rounding helper.
  real(c_double) function gaussian_tangent(angle) bind(C, name="md2asm_gaussian_tangent_fortran") result(answer)
    real(c_double), value, intent(in) :: angle
    real(c_double) :: x, a, da, turns, b, db, square, poly, delta, tangent, cotangent, term
    real(c_double) :: reciprocal, product, remainder, correction, high, low
    integer :: index
    logical :: cotangent_path
    if (.not. (angle >= 0.0625_c_double)) call reject_tangent()
    if (.not. (angle <= 1.5625_c_double)) call reject_tangent()
    x = angle
    a = angle
    if (a > tan_g3) then
      turns = rounded_product_sum(x, tan_hpinv, tan_toint)
      turns = turns - tan_toint
      b = rounded_product_sum(-turns, tan_mp1, x)
      b = rounded_product_sum(-turns, tan_mp2, b)
      da = turns*tan_mp3
      a = b - da
      b = b - a
      da = b - da
      if (abs(a) <= tan_g2) then
        square = a*a
        poly = rounded_product_sum(square, tan_d11, tan_d9)
        poly = rounded_product_sum(square, poly, tan_d7)
        poly = rounded_product_sum(square, poly, tan_d5)
        poly = rounded_product_sum(square, poly, tan_d3)
        term = a*square
        da = rounded_product_sum(term, poly, da)
        b = a + da
        square = a - b
        db = square + da
        reciprocal = 1.0_c_double/b
        product = reciprocal*b
        remainder = rounded_product_sum(reciprocal, b, -product)
        correction = 1.0_c_double - product
        correction = correction - remainder
        correction = correction + 0.0_c_double
        correction = rounded_product_sum(-reciprocal, db, correction)
        correction = correction/b
        high = reciprocal + correction
        low = reciprocal - high
        low = low + correction
        answer = high + low
        answer = -answer
        return
      end if
      a = abs(a)
      da = -da
      cotangent_path = .true.
    else
      da = 0.0_c_double
      cotangent_path = .false.
    end if
    term = rounded_product_sum(256.0_c_double, a, tan_mfftnhf)
    index = int(term)
    if (index < 0 .or. index > 185) call reject_tangent()
    delta = a - tangent_table(1, index)
    tangent = tangent_table(2, index)
    cotangent = tangent_table(3, index)
    if (cotangent_path) delta = delta + da
    square = delta*delta
    poly = rounded_product_sum(square, tan_e1, tan_e0)
    term = delta*square
    delta = rounded_product_sum(term, poly, delta)
    term = tangent + cotangent
    term = delta*term
    if (cotangent_path) then
      b = tangent + delta
      term = term/b
      answer = cotangent - term
    else
      b = cotangent - delta
      term = term/b
      answer = tangent + term
    end if
  end function
end module forecast_gaussian_tangent
