!> Public scalar aliases and explicit caller-owned private counters.
module forecast_exponential_native_aliases
  use iso_c_binding, only: c_double, c_int64_t
  use forecast_scalar_exponential, only: original_rounding_exp
  use forecast_original_math_status, only: native_math_counters, bump_math_counter, global_exp_calls
  implicit none
  private
  public :: counted_original_exp, cloud_private_exp, exponential_native_count_get
contains
  real(c_double) function counted_original_exp(x, counters) result(value)
    real(c_double), intent(in) :: x
    type(native_math_counters), intent(inout), optional :: counters
    call bump_math_counter(3, 1_c_int64_t, counters)
    value = original_rounding_exp(x)
  end function
  real(c_double) function cloud_private_exp(x, counters) result(value)
    real(c_double), intent(in) :: x
    type(native_math_counters), intent(inout) :: counters
    value = counted_original_exp(x, counters)
  end function
  integer(c_int64_t) function exponential_native_count_get() bind(C, name='md2asm_exponential_native_count_get') result(value)
    value = global_exp_calls
  end function
  real(c_double) function native_exp(x) bind(C, name='exp') result(value)
    real(c_double), value :: x
    value = counted_original_exp(x)
  end function
  real(c_double) function native_exp_finite(x) bind(C, name='__exp_finite') result(value)
    real(c_double), value :: x
    value = counted_original_exp(x)
  end function
end module
