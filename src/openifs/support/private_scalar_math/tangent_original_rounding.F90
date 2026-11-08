!> Complete bounded original-rounding tangent, with an explicit C scalar ABI.
!! This port follows src/openifs/support/tan_original_rounding.S. The retained
!! GNU tangent constants/table keep their LGPL-2.1-or-later attribution in the
!! shared constants module. No public TAN or original numerical helper is used.
module forecast_original_rounding_tangent
  use iso_c_binding, only: c_double
  use iso_fortran_env, only: int64
  use forecast_gaussian_tangent_constants, only: tangent_table, tan_e0, tan_e1, tan_g2, tan_g3, &
                               tan_mp1, tan_mp2, tan_mp3, tan_hpinv, tan_toint, tan_mfftnhf, tan_d3, tan_d5, tan_d7, tan_d9, tan_d11
  use forecast_spline_scalar_inverse, only: rps => rounded_product_sum
  use forecast_private_math_environment, only: require_private_math_environment
  implicit none
  private
  public :: original_rounding_tangent
  integer(int64), parameter :: magnitude_mask = int(z'7fffffffffffffff', int64)
  integer(int64), parameter :: maximum_angle_word = int(z'400921fb54442d18', int64)
  integer(int64), parameter :: tiny_angle_word = int(z'3e4b096c00000000', int64)
  integer(int64), parameter :: smallest_normal_word = int(z'0010000000000000', int64)
  real(c_double), parameter :: one = transfer(int(z'3ff0000000000000', int64), 0.0_c_double)
  real(c_double), parameter :: positive_zero = transfer(0_int64, 0.0_c_double)
  real(c_double), parameter :: table_scale = transfer(int(z'4070000000000000', int64), 0.0_c_double)
  interface
    subroutine abort_unsupported() bind(c, name="abort")
    end subroutine
  end interface
contains
  !> Return tangent for one FP64 angle in radians within the closed source
 !! interval[-pi,pi], including both zero signs and subnormal values.
 !! ANGLE is passed by VALUE and the dimensionless FP64 result uses the
 !! compiler C ABI. There are no array, owner, alignment or lifetime inputs.
 !! The exact source FPCR0 environment and angle bound are required before
 !! arithmetic; unsupported input aborts without replacing it by another math
 !! provider. Natural floating flags and errno are never restored or repaired.
  function original_rounding_tangent(angle) bind(c, name="md2asm_tan_original_rounding") result(value)
    real(c_double), value, intent(in) :: angle
    real(c_double) :: value
    integer(int64) :: word, magnitude, parity, table_index
    real(c_double) :: absolute, xx, x3, polynomial, shifted, turns, negative_turns, b, a, da
    real(c_double) :: residual, absolute_a, absolute_da, delta, tangent, low_delta
    real(c_double) :: reciprocal, product, product_error, correction, high, low
    real(c_double) :: row_angle, row_tangent, row_cotangent, z, z2, z3, u, v, denominator, quotient
    real(c_double), volatile :: tiny_square
    logical :: reduction_negative, reduced
    call require_private_math_environment()
    word = transfer(angle, 0_int64)
    magnitude = iand(word, magnitude_mask)
    if (magnitude > maximum_angle_word) call abort_unsupported()
    if (magnitude <= tiny_angle_word) then
      if (magnitude /= 0_int64 .and. magnitude < smallest_normal_word) then
        ! The otherwise unused source square deliberately exposes underflow.
        tiny_square = angle*angle
      end if
      value = angle
      return
    end if
    absolute = transfer(magnitude, 0.0_c_double)
    if (absolute <= tan_g2) then
      xx = angle*angle
      x3 = angle*xx
      polynomial = rps(xx, tan_d11, tan_d9)
      polynomial = rps(xx, polynomial, tan_d7)
      polynomial = rps(xx, polynomial, tan_d5)
      polynomial = rps(xx, polynomial, tan_d3)
      value = rps(x3, polynomial, angle)
      return
    end if
    parity = 0_int64
    reduction_negative = .false.
    reduced = absolute > tan_g3
    if (.not. reduced) then
      absolute_a = absolute
    else
      shifted = rps(angle, tan_hpinv, tan_toint)
      parity = iand(transfer(shifted, 0_int64), 1_int64)
      turns = shifted - tan_toint
      negative_turns = -turns
      b = rps(negative_turns, tan_mp1, angle)
      b = rps(negative_turns, tan_mp2, b)
      a = rps(negative_turns, tan_mp3, b)
      residual = b - a
      da = rps(negative_turns, tan_mp3, residual)
      reduction_negative = a < positive_zero
      absolute_a = a
      absolute_da = da
      if (reduction_negative) then
        absolute_a = -a
        absolute_da = -da
      end if
      if (absolute_a <= tan_g2) then
        xx = a*a
        x3 = a*xx
        polynomial = rps(xx, tan_d11, tan_d9)
        polynomial = rps(xx, polynomial, tan_d7)
        polynomial = rps(xx, polynomial, tan_d5)
        polynomial = rps(xx, polynomial, tan_d3)
        delta = rps(x3, polynomial, da)
        tangent = a + delta
        if (parity == 0_int64) then
          value = tangent
          return
        end if
        ! Source tie order chooses the second error formula for equal magnitudes.
        if (abs(a) > abs(delta)) then
          residual = a - tangent
          low_delta = residual + delta
        else
          residual = delta - tangent
          low_delta = residual + a
        end if
        reciprocal = one/tangent
        product = reciprocal*tangent
        residual = -product
        product_error = rps(reciprocal, tangent, residual)
        residual = one - product
        residual = residual - product_error
        correction = residual + positive_zero
        residual = -low_delta
        correction = rps(residual, reciprocal, correction)
        correction = correction/tangent
        high = reciprocal + correction
        residual = reciprocal - high
        low = residual + correction
        high = high + low
        value = -high
        return
      end if
    end if
    shifted = rps(absolute_a, table_scale, tan_mfftnhf)
    ! FCVTZS in the source truncates this finite value toward zero.
    table_index = int(shifted, int64)
    if (table_index < 0_int64 .or. table_index > 185_int64) call abort_unsupported()
    row_angle = tangent_table(1, table_index)
    row_tangent = tangent_table(2, table_index)
    row_cotangent = tangent_table(3, table_index)
    ! The shared table retains every fourth source word; this source does not
    ! read that fourth word in either table branch.
    z = absolute_a - row_angle
    if (reduced) z = z + absolute_da
    z2 = z*z
    z3 = z*z2
    polynomial = rps(z2, tan_e1, tan_e0)
    u = rps(z3, polynomial, z)
    v = row_tangent + row_cotangent
    product = u*v
    if (parity == 0_int64) then
      denominator = row_cotangent - u
      quotient = product/denominator
      value = row_tangent + quotient
    else
      denominator = row_tangent + u
      quotient = product/denominator
      high = row_cotangent - quotient
      value = -high
    end if
    if (reduced) then
      if (reduction_negative) value = -value
    else
      if (btest(word, 63)) value = -value
    end if
  end function original_rounding_tangent
end module forecast_original_rounding_tangent
