! GNU libc2.38 IBM Accurate Math Library algorithm and coefficient literals.
! Copyright(C)2001-2023 Free Software Foundation, Inc.
! SPDX-License-Identifier: LGPL-2.1-or-later
!> Own the complete finite two-component direction angle.
module forecast_original_rounding_direction
  use iso_fortran_env, only: int64, real64
  use iso_c_binding, only: c_double, c_int
  use forecast_spline_scalar_inverse, only: rounded_product_sum
 use forecast_original_rounding_atan, only: atan_polynomial, atan_table_polynomial, atan_table_index, atan_table, copy_original_sign
use forecast_private_math_environment,only:require_private_math_environment,get_private_math_library_mode,set_private_math_range_error
  implicit none
  private
  public :: original_rounding_direction
  interface
    subroutine public_abort() bind(C, name='abort')
    end subroutine
  end interface
  real(real64), parameter :: d3 = transfer(int(z'bfd5555555555555', int64), 0.0_real64)
  real(real64), parameter :: d5 = transfer(int(z'3fc99999999997fd', int64), 0.0_real64)
  real(real64), parameter :: d7 = transfer(int(z'bfc24924923f7603', int64), 0.0_real64)
  real(real64), parameter :: d9 = transfer(int(z'3fbc71c6e5129a3b', int64), 0.0_real64)
  real(real64), parameter :: d11 = transfer(int(z'bfb7458022b13c25', int64), 0.0_real64)
  real(real64), parameter :: d13 = transfer(int(z'3fb375f08b31cbce', int64), 0.0_real64)
  real(real64), parameter :: hpi = transfer(int(z'3ff921fb54442d18', int64), 0.0_real64)
  real(real64), parameter :: hpi1 = transfer(int(z'3c91a62633145c07', int64), 0.0_real64)
  real(real64), parameter :: opi = transfer(int(z'400921fb54442d18', int64), 0.0_real64)
  real(real64), parameter :: opi1 = transfer(int(z'3ca1a62633145c07', int64), 0.0_real64)
  real(real64), parameter :: inv16 = transfer(int(z'3fb0000000000000', int64), 0.0_real64)
  real(real64), parameter :: twom500 = transfer(int(z'20b0000000000000', int64), 0.0_real64)
  real(real64), parameter :: two500 = transfer(int(z'5f30000000000000', int64), 0.0_real64)
  real(real64), parameter :: factor256 = transfer(int(z'4070000000000000', int64), 0.0_real64)
  real(real64), parameter :: two52 = transfer(int(z'4330000000000000', int64), 0.0_real64)
  real(real64), parameter :: minnormal = transfer(int(z'0010000000000000', int64), 0.0_real64)
contains
!> Return the direction atan2(y,x) in radians for finite FP64 components.
!! X and Y are input scalar components in the same units, passed by value.
!! All signed-zero axes follow the original library mode. Only the both-zero
!! legacy mode0 pair aborts. No buffer or numerical global supplies a stage.
  real(c_double) function original_rounding_direction(y, x) bind(C, name='md2asm_atan2_original_rounding') result(answer)
    real(c_double), value, intent(in) :: y, x
    real(real64)::ax,ay,ratio,product,ratio_error,offset,low,poly,square,cube,high,constant_high,constant_low,temporary,sum_value
    real(real64), volatile :: underflow_sink, underflow_operand
    integer(int64) :: wy, wx, ay_bits, ax_bits, result_bits
    integer :: difference, quadrant, index
    call require_private_math_environment()
    wy = transfer(y, wy); wx = transfer(x, wx)
    if (ibits(wy, 52, 11) == 2047_int64) call public_abort()
    if (ibits(wx, 52, 11) == 2047_int64) call public_abort()
    ay_bits = iand(wy, int(z'7FFFFFFFFFFFFFFF', int64))
    ax_bits = iand(wx, int(z'7FFFFFFFFFFFFFFF', int64))
    if (ior(ay_bits, ax_bits) == 0_int64) then
      if (get_private_math_library_mode() == 0_c_int) call public_abort()
    end if
    if (ay_bits == 0_int64) then
      if (btest(wx, 63)) then
        answer = copy_original_sign(opi, y)
      else
        answer = y
      end if
      return
    end if
    if (ax_bits == 0_int64) then
      answer = copy_original_sign(hpi, y)
      return
    end if
    difference = int(ibits(wy, 52, 11)) - int(ibits(wx, 52, 11))
    if (difference >= 57) then
      answer = copy_original_sign(hpi, y)
      return
    else if (difference <= -57) then
      if (btest(wx, 63)) then
        answer = copy_original_sign(opi, y)
        return
      end if
      ax = abs(x); ay = abs(y)
      answer = ay/ax
      if (answer < minnormal) then
        result_bits = transfer(answer, result_bits)
        if (result_bits == 0_int64) then
          underflow_operand = minnormal
          underflow_sink = underflow_operand*underflow_operand
          call set_private_math_range_error()
        else
          underflow_sink = answer*answer
        end if
      end if
      answer = copy_original_sign(answer, y)
      return
    end if
    ax = abs(x); ay = abs(y)
    if (ax < twom500 .or. ay < twom500) then
      ax = ax*two500
      ay = ay*two500
    end if
    if (ax > two500 .or. ay > two500) then
      ax = ax*twom500
      ay = ay*twom500
    end if
    if (ay < ax) then
      ratio = ay/ax
      product = ax*ratio
      temporary = rounded_product_sum(ax, ratio, -product)
      ratio_error = ay - product
      ratio_error = ratio_error - temporary
      ratio_error = ratio_error/ax
    else
      ratio = ax/ay
      product = ay*ratio
      temporary = rounded_product_sum(ay, ratio, -product)
      ratio_error = ax - product
      ratio_error = ratio_error - temporary
      ratio_error = ratio_error/ay
    end if
    if (x < 0.0_real64) then
      if (ax < ay) then
        quadrant = 2
      else
        quadrant = 3
      end if
    else
      if (ay < ax) then
        quadrant = 0
      else
        quadrant = 1
      end if
    end if
    if (ratio < inv16) then
      square = ratio*ratio
      cube = ratio*square
      poly = atan_polynomial(square)
      if (quadrant == 0) then
        low = rounded_product_sum(cube, poly, ratio_error)
        answer = ratio + low
      else
        poly = cube*poly
        if (quadrant == 3) then
          constant_high = opi; constant_low = opi1
        else
          constant_high = hpi; constant_low = hpi1
        end if
        if (quadrant == 2) then
          high = constant_high + ratio
          low = constant_high - high
          low = low + ratio
          low = constant_low + low
          low = low + ratio_error
          low = low + poly
        else
          high = constant_high - ratio
          low = constant_high - high
          low = low - ratio
          low = constant_low + low
          low = low - ratio_error
          low = low - poly
        end if
        answer = high + low
      end if
    else
      index = atan_table_index(ratio)
      offset = ratio - atan_table(0, index)
      if (quadrant == 0) then
        sum_value = offset + ratio_error
        if (abs(offset) > abs(ratio_error)) then
          low = offset - sum_value
          low = low + ratio_error
        else
          low = ratio_error - sum_value
          low = low + offset
        end if
        poly = atan_table_polynomial(sum_value, index, .true.)
        square = sum_value*sum_value
        square = square*poly
        square = rounded_product_sum(low, atan_table(2, index), square)
        square = rounded_product_sum(sum_value, atan_table(2, index), square)
        answer = atan_table(1, index) + square
      else
        offset = offset + ratio_error
        poly = atan_table_polynomial(offset, index, .false.)
        if (quadrant == 3) then
          constant_high = opi; constant_low = opi1
        else
          constant_high = hpi; constant_low = hpi1
        end if
        if (quadrant == 2) then
          low = rounded_product_sum(offset, poly, constant_low)
          high = constant_high + atan_table(1, index)
        else
          low = rounded_product_sum(-offset, poly, constant_low)
          high = constant_high - atan_table(1, index)
        end if
        answer = high + low
      end if
    end if
    answer = copy_original_sign(answer, y)
  end function
end module forecast_original_rounding_direction
