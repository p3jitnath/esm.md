!> Private power seeds and exact residuals with a deferred exception mask.
module forecast_power_deferred_product_sum
  use iso_c_binding, only: c_int, c_double, c_int64_t
  use forecast_original_math_status
  use forecast_exact_product_sum, only: exact_product_sum
  use forecast_power_integer_rounding, only: power_product_sum_deferred
  use forecast_power_coefficient_tables
  implicit none
  private
  type, bind(C), public :: power_coefficient_record
    integer(c_int64_t) :: significand_b, significand_c
    integer(c_int) :: exponent_b, exponent_c, sign_b, sign_c
  end type
  type(power_coefficient_record), parameter, public :: power_coefficient_records(5) = [ &
                 power_coefficient_record(int(z'10002B8B263FC3', c_int64_t), int(z'12495B9B4845E9', c_int64_t), 1023, 1023, 0, 1), &
                 power_coefficient_record(int(z'1555555529A47A', c_int64_t), int(z'1999999959554E', c_int64_t), 1022, 1022, 1, 0), &
                 power_coefficient_record(int(z'10000000000006', c_int64_t), int(z'15555555555560', c_int64_t), 1022, 1022, 0, 1), &
                 power_coefficient_record(int(z'1555555555543C', c_int64_t), int(z'1FFFFFFFFFFDBD', c_int64_t), 1020, 1021, 0, 0), &
                   power_coefficient_record(int(z'11111167A4D017', c_int64_t), int(z'155555CF172B91', c_int64_t), 1016, 1018, 0, 0)]
  public :: coefficient_product_sum, log_seed_triplet, square_residual, product_rounding_residual
  public :: exponential_seed_pair, log_polynomial_merge, cloud_power_product_sum_deferred
contains
  real(c_double) function coefficient_product_sum(a, b, c, pending, record, mask, counters) result(value)
    real(c_double), intent(in) :: a, b, c
    integer(c_int), intent(in) :: pending
    type(power_coefficient_record), intent(in) :: record
    integer(c_int), intent(out) :: mask
    type(native_math_counters), intent(inout), optional :: counters
    ! The immutable record proves the parent's coefficient relation; raw operands
    ! remain the authority for every general replay.
    value = power_product_sum_deferred(a, b, c, pending, mask, counters)
  end function
  integer(c_int) function log_seed_triplet(r, values, mask, counters) result(status)
    real(c_double), intent(in) :: r
    real(c_double), intent(inout) :: values(3)
    integer(c_int), intent(out) :: mask
    type(native_math_counters), intent(inout), optional :: counters
    integer(c_int) :: m, classification, exponent, i
    integer(c_int64_t) :: word, e
    real(c_double) :: v(3)
    status = 1; mask = 0
    if (.not. math_environment_ready()) return
    word = transfer(r, word); e = ibits(word, 52, 11)
    if (iand(word, int(z'7FFFFFFFFFFFFFFF', c_int64_t)) /= 0) then
      if (e == 0 .or. e >= 1016) return
    end if
    do i = 1, 3
   v(i) = exact_product_sum(r, word_value(pow_log_words(10 - 2*i)), word_value(pow_log_words(9 - 2*i)), m, classification, exponent)
      call bump_math_counter(classification, 1_c_int64_t, counters)
      mask = ior(mask, m)
    end do
    values = v; status = 0
  end function
  real(c_double) function square_residual(a, b, c, pending, mask, counters) result(value)
    real(c_double), intent(in) :: a, b, c
    integer(c_int), intent(in) :: pending
    integer(c_int), intent(out) :: mask
    type(native_math_counters), intent(inout), optional :: counters
    value = power_product_sum_deferred(a, b, c, pending, mask, counters)
  end function
  real(c_double) function product_rounding_residual(a, b, c, pending, mask, counters) result(value)
    real(c_double), intent(in) :: a, b, c
    integer(c_int), intent(in) :: pending
    integer(c_int), intent(out) :: mask
    type(native_math_counters), intent(inout), optional :: counters
    value = power_product_sum_deferred(a, b, c, pending, mask, counters)
  end function
  integer(c_int) function exponential_seed_pair(r, values, mask, counters) result(status)
    real(c_double), intent(in) :: r
    real(c_double), intent(inout) :: values(2)
    integer(c_int), intent(out) :: mask
    type(native_math_counters), intent(inout), optional :: counters
    integer(c_int) :: m, classification, exponent, i
    integer(c_int64_t) :: word, e
    real(c_double) :: v(2)
    status = 1; mask = 0
    if (.not. math_environment_ready()) return
    word = transfer(r, word); e = ibits(word, 52, 11)
    if (iand(word, int(z'7FFFFFFFFFFFFFFF', c_int64_t)) /= 0) then
      if (e < 963 .or. e > 1015) return
    end if
    do i = 1, 2
    v(i) = exact_product_sum(r, word_value(pow_exp_words(2*i + 3)), word_value(pow_exp_words(2*i + 2)), m, classification, exponent)
      call bump_math_counter(classification, 1_c_int64_t, counters)
      mask = ior(mask, m)
    end do
    values = v; status = 0
  end function
  real(c_double) function log_polynomial_merge(a, b, c, pending, mask, counters) result(value)
    real(c_double), intent(in) :: a, b, c
    integer(c_int), intent(in) :: pending
    integer(c_int), intent(out) :: mask
    type(native_math_counters), intent(inout), optional :: counters
    value = power_product_sum_deferred(a, b, c, pending, mask, counters)
  end function
  real(c_double) function cloud_power_product_sum_deferred(a, b, c, pending, mask, counters) result(value)
    real(c_double), intent(in) :: a, b, c
    integer(c_int), intent(in) :: pending
    integer(c_int), intent(out) :: mask
    type(native_math_counters), intent(inout), optional :: counters
    value = power_product_sum_deferred(a, b, c, pending, mask, counters)
  end function
end module
