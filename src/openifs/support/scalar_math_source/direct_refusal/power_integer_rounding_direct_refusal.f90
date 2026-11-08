!> Exact finite product and sum with source diagnostic counters.
module forecast_power_integer_rounding
  use iso_c_binding, only: c_double, c_int, c_int64_t
  use forecast_exact_product_sum
  use forecast_compact_product_sum, only: try_compact_product_sum
  use forecast_wide_product_sum, only: try_wide_product_sum
  use forecast_original_math_status
  implicit none
  private
  public :: original_general_product_sum, power_integer_product_sum, round_product_sum_direct
  public :: power_product_sum_deferred
  !> The standalone entry follows its original fatal-refusal contract.
  !! The C abort service takes no arguments and does not return.
  interface
    subroutine c_direct_abort() bind(C, name='abort')
    end subroutine
  end interface
contains
  real(c_double) function original_general_product_sum(a, b, c, counters) result(value)
    real(c_double), intent(in) :: a, b, c
    type(native_math_counters), intent(inout), optional :: counters
    integer(c_int) :: mask, classification, exponent
    value = exact_product_sum(a, b, c, mask, classification, exponent)
    call bump_math_counter(classification, 1_c_int64_t, counters)
    call commit_math_status(mask)
  end function
  real(c_double) function power_integer_product_sum(a, b, c, counters) result(value)
    real(c_double), intent(in) :: a, b, c
    type(native_math_counters), intent(inout), optional :: counters
    integer(c_int) :: status
    value = a
    status = try_compact_product_sum(a, b, c, value)
    if (status == 0) then
      call bump_math_counter(1_c_int, 1_c_int64_t, counters)
      return
    end if
    status = try_wide_product_sum(a, b, c, value)
    if (status == 0) then
      call bump_math_counter(2_c_int, 1_c_int64_t, counters)
      return
    end if
    value = original_general_product_sum(a, b, c, counters)
  end function
  real(c_double) function power_product_sum_deferred(a, b, c, pending, required_mask, counters) result(value)
    real(c_double), intent(in) :: a, b, c
    integer(c_int), intent(in) :: pending
    integer(c_int), intent(out) :: required_mask
    type(native_math_counters), intent(inout), optional :: counters
    integer(c_int) :: classification, exponent
    logical :: zero_product
    value = exact_product_sum(a, b, c, required_mask, classification, exponent)
    zero_product = iand(transfer(a, 0_c_int64_t), int(z'7FFFFFFFFFFFFFFF', c_int64_t)) == 0 .or. &
                   iand(transfer(b, 0_c_int64_t), int(z'7FFFFFFFFFFFFFFF', c_int64_t)) == 0
    call bump_math_counter(classification, 1_c_int64_t, counters)
    if (zero_product .or. exponent >= (-1022) .or. exponent == -huge(0)) return
    call commit_math_status(pending)
    call commit_math_status(required_mask)
    required_mask = 0_c_int
  end function
  real(c_double) function round_product_sum_direct(a, b, c) result(value)
    real(c_double), intent(in) :: a, b, c
    integer(c_int) :: mask, classification, exponent
    if (.not. math_environment_ready()) call c_direct_abort()
    if (.not. finite_product_inputs(a, b, c)) call c_direct_abort()
    value = exact_product_sum(a, b, c, mask, classification, exponent)
    call commit_math_status(mask)
  end function
  real(c_double) function c_candidate(a, b, c) bind(C, name='md2asm_round_product_sum_candidate') result(value)
    real(c_double), value :: a, b, c
    value = power_integer_product_sum(a, b, c)
  end function
  real(c_double) function c_direct(a, b, c) bind(C, name='md2asm_round_product_sum_direct') result(value)
    real(c_double), value :: a, b, c
    value = round_product_sum_direct(a, b, c)
  end function
  real(c_double) function c_general(a, b, c) bind(C, name='md2asm_private_original_general_product_sum') result(value)
    real(c_double), value :: a, b, c
    value = original_general_product_sum(a, b, c)
  end function
  subroutine c_status_clear() bind(C, name='md2asm_diagnostic_status_clear')
    call math_status_clear()
  end subroutine
  integer(c_int64_t) function c_status_read() bind(C, name='md2asm_diagnostic_status_read') result(value)
    value = iand(int(math_status_read(), c_int64_t), int(z'FFFFFFFF', c_int64_t))
  end function
end module forecast_power_integer_rounding
