!> Compact exact product-and-sum admission with unchanged refusal and status rules.
module forecast_compact_product_sum
  use iso_c_binding, only: c_double, c_int, c_int64_t
  use forecast_exact_product_sum
  use forecast_original_math_status, only: math_environment_ready, commit_math_status
  implicit none
  private
  public :: try_compact_product_sum, try_compact_product_sum_preclassified
contains
  integer(c_int) function try_compact_product_sum(a, b, c, value, tag, required_mask, prepared, deferred) result(status)
    real(c_double), intent(in) :: a, b, c
    real(c_double), intent(inout) :: value
    integer(c_int), intent(out), optional :: tag, required_mask
    type(product_sum_preparation), intent(out), optional :: prepared
    logical, intent(in), optional :: deferred
    type(product_sum_preparation) :: state
    real(c_double) :: candidate
    integer(c_int) :: mask, classification, exponent
    logical :: defer, zero_product
    status = 1_c_int
    if (present(tag)) tag = 0_c_int
    if (present(required_mask)) required_mask = 0_c_int
    if (present(prepared)) prepared = product_sum_preparation()
    if (.not. math_environment_ready()) return
    if (.not. finite_product_inputs(a, b, c)) return
    call prepare_product_sum(a, b, c, state)
    if (present(prepared)) prepared = state
    if (state%classification == 2_c_int) then
      if (present(tag)) tag = state%refusal_tag
      return
    end if
    candidate = exact_product_sum(a, b, c, mask, classification, exponent)
    zero_product = iand(state%words(1), int(z'7FFFFFFFFFFFFFFF', c_int64_t)) == 0 .or. &
                   iand(state%words(2), int(z'7FFFFFFFFFFFFFFF', c_int64_t)) == 0
    if (.not. zero_product .and. exponent < (-1022) .and. exponent /= -huge(0)) return
    defer = .false.
    if (present(deferred)) defer = deferred
    if (.not. defer) call commit_math_status(mask)
    if (present(required_mask)) required_mask = mask
    value = candidate
    status = 0_c_int
  end function
  integer(c_int) function try_compact_product_sum_preclassified(prepared, value, required_mask, deferred) result(status)
    type(product_sum_preparation), intent(in) :: prepared
    real(c_double), intent(inout) :: value
    integer(c_int), intent(out), optional :: required_mask
    logical, intent(in), optional :: deferred
    real(c_double) :: a, b, c
    status = 1_c_int
    if (present(required_mask)) required_mask = 0
    if (.not. prepared%ready) return
    a = transfer(prepared%words(1), a)
    b = transfer(prepared%words(2), b)
    c = transfer(prepared%words(3), c)
    status = try_compact_product_sum(a, b, c, value, required_mask=required_mask, deferred=deferred)
  end function
end module forecast_compact_product_sum
