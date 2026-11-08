!> Source-ordered N128/order5 scalar exponential with explicit range effects.
module forecast_scalar_exponential
  use iso_c_binding, only: c_double, c_int, c_int64_t
  use forecast_exponential_tables
  use forecast_original_math_status, only: word_value, add_words, subtract_words, set_math_errno
  implicit none
  private
  public :: original_rounding_exp, ordinary_exponential, ordinary_exp_admitted
contains
  pure logical function ordinary_exp_admitted(x) result(admitted)
    real(c_double), intent(in) :: x
    integer(c_int64_t) :: word, magnitude, exponent
    word = transfer(x, word)
    magnitude = iand(word, int(z'7FFFFFFFFFFFFFFF', c_int64_t))
    exponent = ibits(word, 52, 11)
    admitted = magnitude == 0 .or. (exponent >= int(z'3C9', c_int64_t) .and. exponent < int(z'408', c_int64_t))
  end function
  real(c_double) function ordinary_exponential(x) result(value)
    real(c_double), intent(in) :: x
    value = reduce_exponential(x, .false.)
  end function
  real(c_double) function original_rounding_exp(x) result(value)
    real(c_double), intent(in) :: x
    integer(c_int64_t) :: word, exponent
    real(c_double), volatile :: operand
    word = transfer(x, word)
    exponent = ibits(word, 52, 11)
    if (exponent < int(z'3C9', c_int64_t)) then
      value = word_value(exp_constants_words(8)) + x
    else if (exponent < int(z'408', c_int64_t)) then
      value = reduce_exponential(x, .false.)
    else if (exponent < int(z'409', c_int64_t)) then
      value = reduce_exponential(x, .true.)
    else if (word == int(z'FFF0000000000000', c_int64_t)) then
      value = word_value(0_c_int64_t)
    else if (exponent >= 2047_c_int64_t) then
      value = word_value(exp_constants_words(8)) + x
    else
      if (btest(word, 63)) then
        operand = word_value(exp_constants_words(12))
      else
        operand = word_value(exp_constants_words(11))
      end if
      value = operand*operand
      call set_math_errno(34_c_int)
    end if
  end function
  real(c_double) function reduce_exponential(x, special) result(value)
    real(c_double), intent(in) :: x
    logical, intent(in) :: special
    real(c_double) :: z, k, r, r2, tail, scale, tmp, t, u, v, w, shift, one
    real(c_double), volatile :: underflow_operand, underflow_probe
    integer(c_int64_t) :: ki, scale_word, word
    integer :: index
    shift = word_value(exp_constants_words(3))
    z = x*word_value(exp_constants_words(0))
    z = z + shift
    ki = transfer(z, ki)
    k = z - shift
    t = k*word_value(exp_constants_words(1))
    r = x + t
    t = k*word_value(exp_constants_words(2))
    r = r + t
    index = int(iand(ki, 127_c_int64_t))
    tail = word_value(exp_scale_words(2*index))
    scale_word = add_words(exp_scale_words(2*index + 1), shiftl(ki, 45))
    r2 = r*r
    tmp = tail + r
    t = r*word_value(exp_constants_words(5))
    t = word_value(exp_constants_words(4)) + t
    t = r2*t
    tmp = tmp + t
    t = r*word_value(exp_constants_words(7))
    t = word_value(exp_constants_words(6)) + t
    u = r2*r2
    t = u*t
    tmp = tmp + t
    if (.not. special) then
      scale = word_value(scale_word)
      t = scale*tmp
      value = scale + t
      return
    end if
    if (.not. btest(ki, 31)) then
      scale_word = subtract_words(scale_word, shiftl(1009_c_int64_t, 52))
      scale = word_value(scale_word)
      t = scale*tmp
      value = scale + t
      value = word_value(exp_constants_words(9))*value
      word = transfer(value, word)
      if (ibits(word, 52, 11) == 2047_c_int64_t) call set_math_errno(34_c_int)
    else
      scale_word = add_words(scale_word, shiftl(1022_c_int64_t, 52))
      scale = word_value(scale_word)
      t = scale*tmp
      value = scale + t
      one = word_value(exp_constants_words(8))
      if (value < one) then
        u = scale - value
        u = u + t
        v = one + value
        w = one - v
        w = w + value
        u = w + u
        value = v + u
        value = value - one
        if (value == 0.0_c_double) value = word_value(0_c_int64_t)
        underflow_operand = word_value(exp_constants_words(10))
        underflow_probe = underflow_operand*underflow_operand
      end if
      value = word_value(exp_constants_words(10))*value
      if (value == 0.0_c_double) call set_math_errno(34_c_int)
    end if
  end function
  real(c_double) function c_original_exp(x) bind(C, name='md2asm_exp_original_rounding') result(value)
    real(c_double), value :: x
    value = original_rounding_exp(x)
  end function
end module forecast_scalar_exponential
