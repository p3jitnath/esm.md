!> Source-ordered scalar POWER with literal GLIBC 2.38 tables.
! Copyright (C) 2018-2023 Free Software Foundation, Inc.
! SPDX-License-Identifier: LGPL-2.1-or-later
module forecast_original_rounding_power
  use iso_c_binding, only: c_int, c_int64_t, c_double
  use forecast_original_math_status
  use forecast_power_coefficient_tables
  use forecast_power_integer_rounding, only: power_product_sum_deferred
  use forecast_power_deferred_product_sum
  implicit none
  private
  integer(c_int64_t), parameter :: magnitude_mask = int(z'7FFFFFFFFFFFFFFF', c_int64_t)
  integer(c_int64_t), parameter :: one_word = int(z'3FF0000000000000', c_int64_t)
  public :: original_rounding_power, cloud_original_rounding_power, power_integer_class
contains
  pure integer(c_int) function power_integer_class(word) result(classification)
    integer(c_int64_t), intent(in) :: word
    integer :: exponent, shift
    integer(c_int64_t) :: bit, mask
    classification = 0; exponent = int(ibits(word, 52, 11))
    if (exponent < 1023) return
    if (exponent > 1075) then
      classification = 2; return
    end if
    shift = 1075 - exponent; bit = shiftl(1_c_int64_t, shift); mask = bit - 1
    if (iand(word, mask) /= 0) return
    classification = 2
    if (iand(word, bit) /= 0) classification = 1
  end function
  pure logical function signalling_nan(word) result(is_signal)
    integer(c_int64_t), intent(in) :: word
    is_signal = ibits(word, 52, 11) == 2047 .and. ibits(word, 0, 52) /= 0 .and. .not. btest(word, 51)
  end function
  real(c_double) function original_rounding_power(x, y, counters) result(value)
    real(c_double), intent(in) :: x, y
    type(native_math_counters), intent(inout), optional :: counters
    value = power_body(x, y, .false., counters)
  end function
  real(c_double) function cloud_original_rounding_power(x, y, counters) result(value)
    real(c_double), intent(in) :: x, y
    type(native_math_counters), intent(inout), optional :: counters
    value = power_body(x, y, .true., counters)
  end function
  real(c_double) function power_body(x, y, cloud, counters) result(value)
    real(c_double), intent(in) :: x, y
    logical, intent(in) :: cloud
    type(native_math_counters), intent(inout), optional :: counters
    integer(c_int64_t) :: wx, wy, ax, ay, tmp, iz, ki, scale_word, sign_bias, word
    integer(c_int) :: ex, ey, k, index, offset, ic, pending, mask, status
    real(c_double) :: kr, z, r, t1, t2, lo1, lo2, a, ar, ar3, h, lo3, lo4, seeds(3), u, poly, w, lo, lh, lt
    real(c_double) :: eh, el, residual, d, first_remainder, tail, r2, exp_seeds(2), b, scale, product, hi, one, rounded, err
    real(c_double), volatile :: force_operand, force_other, force_result, zero
    pending = 0; sign_bias = 0
    wx = transfer(x, wx); wy = transfer(y, wy)
    ax = iand(wx, magnitude_mask); ay = iand(wy, magnitude_mask)
    ex = int(ibits(wx, 52, 11)); ey = int(ibits(wy, 52, 11))
    if (.not. math_environment_ready()) call math_domain_exit()
    if (.not. (.not. btest(wx, 63) .and. ex >= 1 .and. ex <= 2046 .and. ey >= 958 .and. ey < 1086)) then
      if (ay == 0) then
        if (signalling_nan(wx)) then
          value = x + y
        else
          value = 1.0_c_double
        end if
        goto 900
      end if
      if (ey == 2047) then
        if (wx == one_word) then
          if (signalling_nan(wy)) then
            value = x + y
          else
            value = 1.0_c_double
          end if
        else if (ax > int(z'7FF0000000000000', c_int64_t) .or. ay > int(z'7FF0000000000000', c_int64_t)) then
          value = x + y
        else if (ax == one_word) then
          value = 1.0_c_double
        else if ((ax < one_word) .eqv. (.not. btest(wy, 63))) then
          value = word_value(0_c_int64_t)
        else
          value = y*y
        end if
        goto 900
      end if
      if (ax == 0 .or. ex == 2047) then
        hi = x*x
        if (btest(wx, 63)) then
          if (power_integer_class(wy) == 1) then
            hi = -hi; sign_bias = 1
          end if
        end if
        if (ax == 0 .and. btest(wy, 63)) then
          one = 1.0_c_double
          if (sign_bias /= 0) one = -one
          zero = 0.0_c_double
          value = one/zero
          call with_errno(34_c_int, pending)
        else if (btest(wy, 63)) then
          value = 1.0_c_double/hi
        else
          value = hi
        end if
        goto 900
      end if
      if (btest(wx, 63)) then
        ic = power_integer_class(wy)
        if (ic == 0) then
          force_operand = x
          force_other = force_operand - force_operand
          value = force_other/force_other
          call with_errno(33_c_int, pending)
          goto 900
        end if
        if (ic == 1) sign_bias = int(z'40000', c_int64_t)
        wx = ax
      end if
      if (ey < 958 .or. ey >= 1086) then
        if (wx == one_word) then
          value = 1.0_c_double
        else if (ey < 958) then
          if (wx > one_word) then
            value = 1.0_c_double + y
          else
            value = 1.0_c_double - y
          end if
        else
          value = range_flow((wx > one_word) .eqv. (.not. btest(wy, 63)), .false., pending)
        end if
        goto 900
      end if
      if (ex == 0) then
        force_operand = word_value(int(z'4330000000000000', c_int64_t))
        z = x*force_operand
        wx = iand(transfer(z, wx), magnitude_mask)
        wx = subtract_words(wx, int(z'0340000000000000', c_int64_t))
      end if
    end if
    ! Logarithm reduction uses the exact raw word even after subnormal scaling.
    tmp = subtract_words(wx, int(z'3FE6955500000000', c_int64_t))
    index = int(ibits(tmp, 45, 7)); k = int(shifta(tmp, 52), c_int)
    kr = real(k, c_double)
    iz = subtract_words(wx, iand(tmp, int(z'FFF0000000000000', c_int64_t)))
    z = word_value(iz); offset = 9 + 4*index
    r = ps(z, word_value(pow_log_words(offset)), -1.0_c_double, pending, counters)
    if (cloud) then
      t1 = ps(kr, word_value(pow_log_words(0)), word_value(pow_log_words(offset + 2)), pending, counters)
    else
      t1 = kr*word_value(pow_log_words(0))
      t1 = t1 + word_value(pow_log_words(offset + 2))
      call bump_math_counter(1_c_int, 1_c_int64_t, counters)
    end if
    t2 = t1 + r
    if (.not. cloud .and. iand(transfer(kr, word), int(z'1FFFFFFFFFFFF', c_int64_t)) == 0) then
      lo1 = kr*word_value(pow_log_words(1))
      lo1 = lo1 + word_value(pow_log_words(offset + 3))
      call bump_math_counter(1_c_int, 1_c_int64_t, counters)
    else
      lo1 = ps(kr, word_value(pow_log_words(1)), word_value(pow_log_words(offset + 3)), pending, counters)
    end if
    lo2 = t1 - t2; lo2 = lo2 + r
    a = word_value(pow_log_words(2))*r
    ar = r*a; ar3 = r*ar; h = t2 + ar
    if (cloud) then
      lo3 = ps(a, r, -ar, pending, counters)
    else
      lo3 = square_residual(a, r, -ar, pending, mask, counters)
      pending = ior(pending, mask)
    end if
    lo4 = t2 - h; lo4 = lo4 + ar
    if (cloud) then
      seeds(1) = ps(r, word_value(pow_log_words(8)), word_value(pow_log_words(7)), pending, counters)
      seeds(2) = ps(r, word_value(pow_log_words(6)), word_value(pow_log_words(5)), pending, counters)
      seeds(3) = ps(r, word_value(pow_log_words(4)), word_value(pow_log_words(3)), pending, counters)
    else
      status = log_seed_triplet(r, seeds, mask, counters)
      if (status == 0) then
        pending = ior(pending, mask)
      else
        seeds(1) = cs(r, word_value(pow_log_words(8)), word_value(pow_log_words(7)), 1, pending, counters)
        seeds(2) = cs(r, word_value(pow_log_words(6)), word_value(pow_log_words(5)), 2, pending, counters)
        seeds(3) = cs(r, word_value(pow_log_words(4)), word_value(pow_log_words(3)), 3, pending, counters)
      end if
    end if
    if (cloud) then
      u = ps(ar, seeds(1), seeds(2), pending, counters)
      poly = ps(ar, u, seeds(3), pending, counters)
    else
      u = log_polynomial_merge(ar, seeds(1), seeds(2), pending, mask, counters)
      pending = ior(pending, mask)
      poly = log_polynomial_merge(ar, u, seeds(3), pending, mask, counters)
      pending = ior(pending, mask)
    end if
    w = lo1 + lo2; w = w + lo3; w = w + lo4
    lo = ps(ar3, poly, w, pending, counters)
    lh = h + lo; lt = h - lh; lt = lt + lo
    eh = y*lh
    if (cloud) then
      residual = ps(y, lh, -eh, pending, counters)
    else
      residual = product_rounding_residual(y, lh, -eh, pending, mask, counters)
      pending = ior(pending, mask)
    end if
    el = ps(y, lt, residual, pending, counters)
    word = transfer(eh, word); ex = int(ibits(word, 52, 11))
    if (ex < 969) then
      value = 1.0_c_double + eh
      if (sign_bias /= 0) value = -value
      goto 900
    else if (ex >= 1033) then
      value = range_flow(.not. btest(word, 63), sign_bias /= 0, pending)
      goto 900
    end if
    z = word_value(pow_exp_words(0))*eh
    ! NINT rounds halfway values away from zero, as source FCVTAS does.
    ki = nint(z, kind=c_int64_t); d = real(ki, c_double)
    if (ki == 0) d = word_value(iand(transfer(z, word), int(z'8000000000000000', c_int64_t)))
    if (.not. cloud .and. abs(ki) < 131072_c_int64_t) then
      first_remainder = d*word_value(pow_exp_words(2))
      first_remainder = first_remainder + eh
      call bump_math_counter(1_c_int, 1_c_int64_t, counters)
    else
      first_remainder = ps(d, word_value(pow_exp_words(2)), eh, pending, counters)
    end if
    r = ps(d, word_value(pow_exp_words(3)), first_remainder, pending, counters)
    r = r + el
    index = int(iand(ki, 127_c_int64_t))
    tail = word_value(pow_exp_words(14 + 2*index))
    scale_word = add_words(pow_exp_words(15 + 2*index), shiftl(add_words(ki, sign_bias), 45))
    r2 = r*r
    if (cloud) then
      exp_seeds(1) = ps(r, word_value(pow_exp_words(5)), word_value(pow_exp_words(4)), pending, counters)
      exp_seeds(2) = ps(r, word_value(pow_exp_words(7)), word_value(pow_exp_words(6)), pending, counters)
    else
      status = exponential_seed_pair(r, exp_seeds, mask, counters)
      if (status == 0) then
        pending = ior(pending, mask)
      else
        exp_seeds(1) = cs(r, word_value(pow_exp_words(5)), word_value(pow_exp_words(4)), 4, pending, counters)
        exp_seeds(2) = cs(r, word_value(pow_exp_words(7)), word_value(pow_exp_words(6)), 5, pending, counters)
      end if
    end if
    b = tail + r; b = ps(r2, exp_seeds(1), b, pending, counters)
    a = r2*r2; a = ps(a, exp_seeds(2), b, pending, counters)
    if (ex < 1032) then
      scale = word_value(scale_word)
      value = ps(scale, a, scale, pending, counters)
    else if (.not. btest(ki, 31)) then
      scale_word = subtract_words(scale_word, int(z'3F10000000000000', c_int64_t))
      scale = word_value(scale_word)
      value = ps(scale, a, scale, pending, counters)
      value = word_value(int(z'7F00000000000000', c_int64_t))*value
      if (iand(transfer(value, word), magnitude_mask) == int(z'7FF0000000000000', c_int64_t)) call with_errno(34_c_int, pending)
    else
      scale_word = add_words(scale_word, int(z'3FE0000000000000', c_int64_t))
      scale = word_value(scale_word)
      product = scale*a; hi = scale + product
      if (abs(hi) < 1.0_c_double) then
        one = 1.0_c_double
        if (hi < 0.0_c_double) one = -one
        lo = scale - hi
        product = scale*a
        lo = lo + product
        rounded = one + hi; err = one - rounded; err = err + hi
        lo = err + lo; hi = rounded + lo; hi = hi - one
        if (hi == 0.0_c_double) hi = word_value(iand(scale_word, int(z'8000000000000000', c_int64_t)))
        force_operand = word_value(int(z'0010000000000000', c_int64_t))
        force_result = force_operand*force_operand
      end if
      value = word_value(int(z'0010000000000000', c_int64_t))*hi
      if (value == 0.0_c_double) call with_errno(34_c_int, pending)
    end if
900 continue
    call commit_math_status(pending)
  end function
  real(c_double) function ps(aa, bb, cc, pending, counters) result(v)
    real(c_double), intent(in) :: aa, bb, cc
    integer(c_int), intent(inout) :: pending
    type(native_math_counters), intent(inout), optional :: counters
    integer(c_int) :: required
    v = power_product_sum_deferred(aa, bb, cc, pending, required, counters)
    pending = ior(pending, required)
  end function
  real(c_double) function cs(aa, bb, cc, record_index, pending, counters) result(v)
    real(c_double), intent(in) :: aa, bb, cc
    integer(c_int), intent(inout) :: pending
    type(native_math_counters), intent(inout), optional :: counters
    integer, intent(in) :: record_index
    integer(c_int) :: required
    v = coefficient_product_sum(aa, bb, cc, pending, power_coefficient_records(record_index), required, counters)
    pending = ior(pending, required)
  end function
  subroutine with_errno(code, pending)
    integer(c_int), intent(in) :: code
    integer(c_int), intent(inout) :: pending
    call commit_math_status(pending)
    pending = 0
    call set_math_errno(code)
  end subroutine
  real(c_double) function range_flow(overflow, negative, pending) result(v)
    logical, intent(in) :: overflow, negative
    integer(c_int), intent(inout) :: pending
    real(c_double), volatile :: left, right
    if (overflow) then
      left = word_value(int(z'7000000000000000', c_int64_t))
    else
      left = word_value(int(z'1000000000000000', c_int64_t))
    end if
    right = left
    if (negative) left = -left
    v = left*right
    call with_errno(34_c_int, pending)
  end function
  real(c_double) function c_original_power(x, y) bind(C, name='md2asm_pow_original_rounding_candidate') result(value)
    real(c_double), value :: x, y
    value = original_rounding_power(x, y)
  end function
  real(c_double) function c_cloud_power(x, y) bind(C, name='md2asm_r4_cloud_pow_original_rounding_candidate') result(value)
    real(c_double), value :: x, y
    value = cloud_original_rounding_power(x, y)
  end function
end module
