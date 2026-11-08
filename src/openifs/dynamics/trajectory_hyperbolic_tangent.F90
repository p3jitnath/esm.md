!> Ordered FP64-pair hyperbolic tangent used by the frozen LAVENT route.
!! A pair stores a leading FP64 value and its small rounding correction.
!! This is a port of the existing generated revision3 calculation.
module md2asm_trajectory_hyperbolic_tangent
  use iso_fortran_env, only: int32, int64, real64
  implicit none
  private
  public :: evaluate_trajectory_tanh
  type :: fp64_pair
    real(real64) :: leading = 0.0_real64, correction = 0.0_real64
  end type
contains
  !> Evaluate the existing finite-input trajectory tangent.
  !! x and value are dimensionless FP64 scalars. The caller establishes
  !! round-to-nearest with gradual underflow. Status0 succeeds;2 rejects a
  !! nonfinite input without changing value. Signed zero is preserved.
  !! Inputs with magnitude at most2**(-27) return unchanged; magnitudes
  !! at least20 return signed1. The interior calculation forms exp(2*abs(x))
  !! with24 ordered series terms and seven pair squarings, then its ratio.
  !! The retained contract requires at most one FP64 spacing of error;
  !! it does not claim globally correct rounding or vendor TANH identity.
  subroutine evaluate_trajectory_tanh(x, value, status)
    real(real64), intent(in) :: x
    real(real64), intent(inout) :: value
    integer(int32), intent(out) :: status
    type(fp64_pair) :: argument, term, total, numerator, denominator, result
    integer(int64) :: raw, magnitude, result_raw
    integer :: j
    real(real64) :: rounded
    status = 2_int32
    raw = transfer(x, raw)
    magnitude = iand(raw, int(z'7FFFFFFFFFFFFFFF', int64))
    if (magnitude >= int(z'7FF0000000000000', int64)) return
    if (magnitude <= int(z'3E40000000000000', int64)) then
      value = x
      status = 0_int32
      return
    end if
    if (magnitude >= int(z'4034000000000000', int64)) then
      result_raw = ior(int(z'3FF0000000000000', int64), iand(raw, int(z'8000000000000000', int64)))
      value = transfer(result_raw, value)
      status = 0_int32
      return
    end if
    argument%leading = transfer(magnitude, rounded)*transfer(int(z'3F90000000000000', int64), rounded)
    argument%correction = 0.0_real64
    term = fp64_pair(1.0_real64, 0.0_real64)
    total = fp64_pair(1.0_real64, 0.0_real64)
    do j = 1, 24
      term = multiply_pairs(term, argument)
      term = divide_integer(term, real(j, real64))
      total = add_pairs(total, term)
    end do
    do j = 1, 7
      total = multiply_pairs(total, total)
    end do
    numerator = add_pairs(total, fp64_pair(-1.0_real64, 0.0_real64))
    denominator = add_pairs(total, fp64_pair(1.0_real64, 0.0_real64))
    result = divide_pairs(numerator, denominator)
    rounded = result%leading + result%correction
    result_raw = ior(transfer(rounded, result_raw), iand(raw, int(z'8000000000000000', int64)))
    value = transfer(result_raw, value)
    status = 0_int32
  end subroutine

  function sum_two(a, b) result(c)
    real(real64), intent(in) :: a, b
    type(fp64_pair) :: c
    real(real64) :: s, v, w, x, y
    s = a + b
    v = s - a
    w = s - v
    x = a - w
    y = b - v
    c%correction = x + y
    c%leading = s
  end function

  function add_pairs(a, b) result(c)
    type(fp64_pair), intent(in) :: a, b
    type(fp64_pair) :: c, first
    real(real64) :: low
    first = sum_two(a%leading, b%leading)
    low = a%correction + b%correction
    low = low + first%correction
    c = sum_two(first%leading, low)
  end function

  function product_two(a, b) result(c)
    real(real64), intent(in) :: a, b
    type(fp64_pair) :: c
    real(real64) :: splitter, t, e, ah, al, bh, bl, r, p
    splitter = transfer(int(z'41A0000002000000', int64), splitter)
    p = a*b
    t = splitter*a
    e = t - a
    ah = t - e
    al = a - ah
    t = splitter*b
    e = t - b
    bh = t - e
    bl = b - bh
    r = ah*bh
    r = r - p
    e = ah*bl
    r = r + e
    e = al*bh
    r = r + e
    e = al*bl
    c%correction = r + e
    c%leading = p
  end function

  function multiply_pairs(a, b) result(c)
    type(fp64_pair), intent(in) :: a, b
    type(fp64_pair) :: c, product
    real(real64) :: x, y
    product = product_two(a%leading, b%leading)
    x = a%leading*b%correction
    y = a%correction*b%leading
    x = x + y
    x = x + product%correction
    c = sum_two(product%leading, x)
  end function

  function divide_integer(a, b) result(c)
    type(fp64_pair), intent(in) :: a
    real(real64), intent(in) :: b
    type(fp64_pair) :: c, product, residual
    real(real64) :: q, correction
    q = a%leading/b
    product = product_two(q, b)
    product%leading = -product%leading
    product%correction = -product%correction
    residual = add_pairs(a, product)
    correction = residual%leading/b
    c = sum_two(q, correction)
  end function

  function divide_pairs(a, b) result(c)
    type(fp64_pair), intent(in) :: a, b
    type(fp64_pair) :: c, product, residual
    real(real64) :: q, correction
    q = a%leading/b%leading
    product = multiply_pairs(fp64_pair(q, 0.0_real64), b)
    product%leading = -product%leading
    product%correction = -product%correction
    residual = add_pairs(a, product)
    correction = residual%leading/b%leading
    c = sum_two(q, correction)
  end function
end module md2asm_trajectory_hyperbolic_tangent
