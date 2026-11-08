module spline_polynomial_operations
  !! Ordered cubic-polynomial operations on dimensionless spline coordinates.
  use iso_c_binding, only: c_int, c_double, c_int64_t
  implicit none
  private
  public :: spline_sample_position, coordinate_from_local, polynomial_value
  public :: polynomial_derivative, polynomial_integral, polynomial_product
  public :: local_polynomial, interval_contribution
contains
  function spline_sample_position(order, sample, bounds) result(value)
    integer(c_int), intent(in) :: order, sample
    real(c_double), intent(in) :: bounds(2)
    real(c_double) :: value, fraction, width
    fraction = real(sample - 1, c_double)/real(order - 1, c_double)
    width = bounds(2) - bounds(1)
    value = fraction*width
    value = bounds(1) + value
  end function
  function coordinate_from_local(lower, upper, coordinate) result(value)
    real(c_double), intent(in) :: lower, upper, coordinate
    real(c_double) :: value, width
    width = upper - lower
    value = coordinate*width
    value = lower + value
  end function
  function polynomial_value(coefficients, coordinate) result(value)
    real(c_double), intent(in) :: coefficients(:), coordinate
    real(c_double) :: value, product
    integer :: j
    value = coefficients(size(coefficients))
    do j = size(coefficients) - 1, 1, -1
      product = coordinate*value
      value = product + coefficients(j)
    end do
  end function
  subroutine polynomial_derivative(coefficients, derivative)
    real(c_double), intent(in) :: coefficients(:)
    real(c_double), intent(inout) :: derivative(:)
    integer :: j
    do j = 2, size(coefficients)
      derivative(j - 1) = coefficients(j)*real(j - 1, c_double)
    end do
  end subroutine
  subroutine polynomial_integral(coefficients, constant, integral)
    real(c_double), intent(in) :: coefficients(:), constant
    real(c_double), intent(inout) :: integral(:)
    integer :: j
    integral(1) = constant
    do j = 1, size(coefficients)
      integral(j + 1) = coefficients(j)/real(j, c_double)
    end do
  end subroutine
  subroutine polynomial_product(left, right, product)
    real(c_double), intent(in) :: left(:), right(:)
    real(c_double), intent(inout) :: product(:)
    integer :: j, k, l
    real(c_double) :: value, term
    do j = 0, size(product) - 1
      value = 0.0_c_double
      do k = 0, j
        l = j - k
        if (k < size(left) .and. l < size(right)) then
          term = left(k + 1)*right(l + 1)
          value = value + term
        end if
      end do
      product(j + 1) = value
    end do
  end subroutine
  function local_polynomial(transform, lower, upper, global, local) result(status)
    !! Read a 4-by-4 sampling transform and four coefficients; replace four local coefficients.
    real(c_double), intent(in) :: transform(4, 4), lower, upper, global(4)
    real(c_double), intent(inout) :: local(4)
    integer(c_int) :: status
    real(c_double) :: samples(4), coordinate, value, term
    integer :: i, j
    status = 2
    if (.not. finite_real(lower) .or. .not. finite_real(upper)) return
    if (upper <= lower) return
    do i = 1, 4
      coordinate = spline_sample_position(4_c_int, int(i, c_int), [0.0_c_double, 1.0_c_double])
      coordinate = coordinate_from_local(lower, upper, coordinate)
      samples(i) = polynomial_value(global, coordinate)
    end do
    do i = 1, 4
      value = 0.0_c_double
      do j = 1, 4
        term = transform(i, j)*samples(j)
        value = value + term
      end do
      local(i) = value
    end do
    status = 0
  end function
  function interval_contribution(kind, input, weight, width, contribution) result(status)
    !! Integrate a product, an integrated product, or a first derivative over one interval.
    integer(c_int), intent(in) :: kind
    real(c_double), intent(in) :: input(4), weight(4), width
    real(c_double), intent(inout) :: contribution
    integer(c_int) :: status
    integer :: n
    real(c_double) :: work(5), product(8), integral(9), scale, lower, upper, difference
    status = 2
    if (kind < -1 .or. kind > 1) return
    if (.not. finite_real(width)) return
    if (width <= 0.0_c_double) return
    if (any(.not. finite_real(input)) .or. any(.not. finite_real(weight))) return
    if (kind == -1) then
      n = 5
      scale = width
      call polynomial_integral(input, 0.0_c_double, work)
      scale = scale*scale
    else if (kind == 0) then
      n = 4
      work(1:4) = input
      scale = width
    else
      n = 3
      scale = 1.0_c_double
      call polynomial_derivative(input, work)
    end if
    call polynomial_product(work(1:n), weight, product(1:n + 3))
    call polynomial_integral(product(1:n + 3), 0.0_c_double, integral(1:n + 4))
    lower = polynomial_value(integral(1:n + 4), 0.0_c_double)
    upper = polynomial_value(integral(1:n + 4), 1.0_c_double)
    difference = upper - lower
    contribution = scale*difference
    status = 0
  end function
  elemental function finite_real(value) result(finite)
    real(c_double), intent(in) :: value
    logical :: finite
    integer(c_int64_t) :: bits
    bits = transfer(value, bits)
    finite = ibits(bits, 52, 11) /= 2047_c_int64_t
  end function
end module
