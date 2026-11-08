!> Wide exact product-and-sum admission with complete preserved operands.
module forecast_wide_product_sum
  use iso_c_binding, only: c_double, c_int, c_int64_t
  use forecast_exact_product_sum
  use forecast_original_math_status, only: math_environment_ready, commit_math_status
  implicit none
  private
  public :: try_wide_product_sum, try_wide_product_sum_prepared, private_wide_deferred_prepared
contains
  integer(c_int) function try_wide_product_sum(a, b, c, value, required_mask, deferred) result(status)
    real(c_double), intent(in) :: a, b, c
    real(c_double), intent(inout) :: value
    integer(c_int), intent(out), optional :: required_mask
    logical, intent(in), optional :: deferred
    type(product_sum_preparation) :: prepared
    real(c_double) :: candidate
    integer(c_int) :: mask, classification, exponent
    logical :: defer
    status = 1_c_int
    if (present(required_mask)) required_mask = 0
    if (.not. math_environment_ready()) return
    if (.not. finite_product_inputs(a, b, c)) return
    call prepare_product_sum(a, b, c, prepared)
    if (prepared%classification /= 2_c_int) return
    candidate = exact_product_sum(a, b, c, mask, classification, exponent)
    if (exponent < (-1022)) return
    defer = .false.
    if (present(deferred)) defer = deferred
    if (.not. defer) call commit_math_status(mask)
    if (present(required_mask)) required_mask = mask
    value = candidate
    status = 0_c_int
  end function
  integer(c_int) function try_wide_product_sum_prepared(prepared, value, required_mask, deferred) result(status)
    type(product_sum_preparation), intent(in) :: prepared
    real(c_double), intent(inout) :: value
    integer(c_int), intent(out), optional :: required_mask
    logical, intent(in), optional :: deferred
    real(c_double) :: a, b, c
    status = 1_c_int
    if (present(required_mask)) required_mask = 0
    if (.not. prepared%ready .or. prepared%refusal_tag < 1 .or. prepared%refusal_tag > 2) return
    a = transfer(prepared%words(1), a)
    b = transfer(prepared%words(2), b)
    c = transfer(prepared%words(3), c)
    status = try_wide_product_sum(a, b, c, value, required_mask, deferred)
  end function
  integer(c_int) function private_wide_deferred_prepared(prepared, value, required_mask) result(status)
    type(product_sum_preparation), intent(in) :: prepared
    real(c_double), intent(inout) :: value
    integer(c_int), intent(out) :: required_mask
    status = try_wide_product_sum_prepared(prepared, value, required_mask, .true.)
  end function
end module forecast_wide_product_sum
