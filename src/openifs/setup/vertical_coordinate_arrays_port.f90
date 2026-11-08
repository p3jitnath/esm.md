!> Build dimensionless vertical coordinates from the owned hybrid pressure arrays.
!! The caller owns all arrays and supplies nearest-even rounding and gradual underflow.
module forecast_vertical_coordinate_arrays
  use iso_c_binding, only: c_int, c_int64_t, c_double
  implicit none
  private
  public :: initialize_vertical_eta_arrays, fill_hybrid_coordinate_arrays
  interface
    function public_power(x, y) bind(C, name="pow") result(value)
      import c_double
      real(c_double), value :: x, y
      real(c_double) :: value
    end function
    function public_cosine(x) bind(C, name="cos") result(value)
      import c_double
      real(c_double), value :: x
      real(c_double) :: value
    end function
  end interface
contains
  !> Return whether a complete FP64 word is finite without changing FP flags.
  logical function finite_word(x)
    real(c_double), intent(in) :: x
    integer(c_int64_t) :: bits
    bits = transfer(x, bits)
    finite_word = ibits(bits, 52, 11) /= 2047
  end function

  !> Fill the eight hybrid-coordinate array owners without allocating storage.
  !! n is the layer count, 0..256; reference_pressure and A use Pa, B is dimensionless.
  !! Inputs A/B have bounds0:n. Outputs normalized_a,half_a,half_b,full_a/full_b
  !! have bounds0:n; C,delta_a/delta_b have bounds1:n. Full_a(0) and full_b(0)
  !! retain their incoming bytes. All buffers are complete, disjoint and aligned
  !! for FP64. Return2 leaves all arrays unchanged; return0 fills defined words.
  integer(c_int) function fill_hybrid_coordinate_arrays(n, reference_pressure, a, b, &
                                                        normalized_a, half_a, half_b, c, full_a, full_b, delta_a, delta_b) &
    bind(C, name="md2asm_fill_hybrid_coordinate_arrays_fortran") result(status)
    integer(c_int), value, intent(in) :: n
    real(c_double), value, intent(in) :: reference_pressure
    real(c_double), intent(in) :: a(0:n), b(0:n)
    real(c_double), intent(inout) :: normalized_a(0:n), half_a(0:n), half_b(0:n)
    real(c_double), intent(inout) :: c(1:n), full_a(0:n), full_b(0:n), delta_a(1:n), delta_b(1:n)
    integer :: j
    real(c_double) :: left, right, temporary
    status = 2
    if (n < 0 .or. n > 256) return
    if (.not. finite_word(reference_pressure)) return
    if (reference_pressure <= 0.0_c_double) return
    do j = 0, n
      if (.not. finite_word(a(j)) .or. .not. finite_word(b(j))) return
    end do
    do j = 0, n
      half_a(j) = a(j)
      half_b(j) = b(j)
      normalized_a(j) = a(j)/reference_pressure
    end do
    do j = 1, n
      left = half_a(j)*half_b(j - 1)
      right = half_a(j - 1)*half_b(j)
      c(j) = left - right
      temporary = half_a(j) + half_a(j - 1)
      full_a(j) = 0.5_c_double*temporary
      temporary = half_b(j) + half_b(j - 1)
      full_b(j) = 0.5_c_double*temporary
      delta_a(j) = half_a(j) - half_a(j - 1)
      delta_b(j) = half_b(j) - half_b(j - 1)
    end do
    status = 0
  end function

  !> Construct the selected19- or137-layer eta arrays and the two interval bounds.
  !! All eta, inverse-depth, knot and bound values are dimensionless; A is in Pa.
  !! The caller has admitted the noniterative order4 finite-element controls.
  !! alpha is exactly+0, beta exactly0.5 and pi exactly400921fb54442d18hex.
  !! Half arrays use0:n; full arrays use0:n+1; inverse_depth uses1:n and knots
  !! uses1:n-2. All buffers are disjoint, complete and aligned for FP64.
  !! Return2 preserves every output; numerical finite positive layer pressures
  !! and nonzero final cumulative depth are caller preconditions.
  integer(c_int) function initialize_vertical_eta_arrays(n, reference_pressure, pi, alpha, beta, &
                                                         half_a, half_b, normalized_a, eta_half, eta_full, vfe_half, vfe_full, &
                                                         inverse_depth, knots, bounds) &
    bind(C, name="md2asm_initialize_vertical_eta_arrays_fortran") result(status)
    integer(c_int), value, intent(in) :: n
    real(c_double), value, intent(in) :: reference_pressure, pi, alpha, beta
    real(c_double), intent(in) :: half_a(0:n), half_b(0:n), normalized_a(0:n)
    real(c_double), intent(inout) :: eta_half(0:n), eta_full(0:n + 1)
    real(c_double), intent(inout) :: vfe_half(0:n), vfe_full(0:n + 1)
    real(c_double), intent(inout) :: inverse_depth(1:n), knots(1:n - 2), bounds(2)
    real(c_double) :: cumulative(0:137), left, right, difference, value, cosine_value
    real(c_double) :: chebyshev, ordinary_part, chebyshev_part, temporary, denominator
    integer(c_int64_t) :: bits
    integer :: j
    status = 2
    if (n /= 19 .and. n /= 137) return
    if (.not. finite_word(reference_pressure)) return
    if (reference_pressure <= 0.0_c_double) return
    bits = transfer(pi, bits)
    if (bits /= int(z'400921fb54442d18', c_int64_t)) return
    bits = transfer(alpha, bits)
    if (bits /= 0_c_int64_t) return
    bits = transfer(beta, bits)
    if (bits /= int(z'3fe0000000000000', c_int64_t)) return
    do j = 0, n
      eta_half(j) = normalized_a(j) + half_b(j)
      if (j /= 0) then
        temporary = eta_half(j) + eta_half(j - 1)
        eta_full(j) = temporary*0.5_c_double
      end if
    end do
    eta_full(0) = eta_half(0)
    eta_full(n + 1) = eta_half(n)
    bounds(1) = interval_coordinate(0.0_c_double, 1.0_c_double, 0.0_c_double)
    bounds(2) = interval_coordinate(0.0_c_double, 1.0_c_double, 1.0_c_double)
    cumulative(0) = 0.0_c_double
    do j = 1, n
      temporary = half_b(j - 1)*reference_pressure
      left = half_a(j - 1) + temporary
      temporary = half_b(j)*reference_pressure
      right = half_a(j) + temporary
      difference = right - left
      value = public_power(difference, alpha)
      cumulative(j) = cumulative(j - 1) + value
    end do
    denominator = cumulative(n)
    do j = 0, n
      vfe_half(j) = cumulative(j)/denominator
    end do
    do j = 0, n
      value = vfe_half(j)
      temporary = pi*value
      cosine_value = public_cosine(temporary)
      temporary = 0.5_c_double*cosine_value
      chebyshev = 0.5_c_double - temporary
      temporary = 1.0_c_double - beta
      ordinary_part = temporary*value
      chebyshev_part = beta*chebyshev
      vfe_half(j) = ordinary_part + chebyshev_part
    end do
    vfe_half(0) = 0.0_c_double
    vfe_half(n) = 1.0_c_double
    do j = 1, n
      temporary = vfe_half(j) + vfe_half(j - 1)
      vfe_full(j) = temporary*0.5_c_double
    end do
    vfe_full(0) = vfe_half(0)
    vfe_full(n + 1) = vfe_half(n)
    do j = 1, n
      temporary = vfe_half(j) - vfe_half(j - 1)
      inverse_depth(j) = 1.0_c_double/temporary
    end do
    do j = 1, n - 2
      knots(j) = vfe_full(j + 1)
    end do
    status = 0
  end function

  !> Map x from the dimensionless interval[a,b] to its dimensionless coordinate.
  !! Each difference rounds before division; no array or global state changes.
  function interval_coordinate(a, b, x) result(value)
    real(c_double), intent(in) :: a, b, x
    real(c_double) :: value, numerator, denominator
    numerator = x - a
    denominator = b - a
    value = numerator/denominator
  end function
end module forecast_vertical_coordinate_arrays
