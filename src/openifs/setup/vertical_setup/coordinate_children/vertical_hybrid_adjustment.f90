!> Preserve the selected noniterative A-weighted SUVFE_ADJUST_AB calculation.
module forecast_vertical_hybrid_adjustment
  use iso_c_binding, only: c_int, c_int64_t, c_double
  use forecast_vertical_spline_profile, only: integrate_vertical_spline_profile
  implicit none
  private
  public :: adjust_vertical_hybrid_arrays
contains
  !> Fill the five adjusted hybrid owners from explicit caller-owned arrays.
  !! Half A has Pa units and half B is dimensionless, both with bounds0:n.
  !! inverse_depth(1:n) and matrix(n+1,n+2) describe dimensionless eta.
  !! reference_pressure is positive finite Pa. Output delta_a,full_a,C use Pa;
  !! delta_b and full_b are dimensionless. Every output has bounds1:n.
  !! All buffers are complete, disjoint and aligned for FP64. The caller admits
  !! finite arithmetic and nonzero normalisation denominators.
  !! Return2 leaves outputs unchanged; return3 requires discarding partial work.
  integer(c_int) function adjust_vertical_hybrid_arrays(n, half_a, half_b, inverse_depth, matrix, &
                                                        reference_pressure, delta_b, delta_a, full_b, full_a, c) &
    bind(C, name="md2asm_adjust_vertical_hybrid_arrays_fortran") result(status)
    integer(c_int), value, intent(in) :: n
    real(c_double), intent(in) :: half_a(0:n), half_b(0:n), inverse_depth(n), matrix(n + 1, n + 2)
    real(c_double), value, intent(in) :: reference_pressure
    real(c_double), intent(inout) :: delta_b(n), delta_a(n), full_b(n), full_a(n), c(n)
    real(c_double) :: gradient(n), zone(n), surface, temporary, left, right
    real(c_double), volatile :: integrated(n + 1)
    integer(c_int64_t) :: bits
    integer(c_int) :: child_status
    integer :: j
    status = 2
    if (n /= 19 .and. n /= 137) return
    bits = transfer(reference_pressure, bits)
    if (ibits(bits, 52, 11) == 2047) return
    if (reference_pressure <= 0.0_c_double) return
    do j = 1, n
      delta_b(j) = half_b(j) - half_b(j - 1)
      gradient(j) = delta_b(j)*inverse_depth(j)
      delta_a(j) = half_a(j) - half_a(j - 1)
    end do
    child_status = integrate_vertical_spline_profile(n, matrix, gradient, integrated)
    if (child_status /= 0) then
      status = 3
      return
    end if
    surface = integrated(n + 1)
    do j = 1, n
      delta_b(j) = delta_b(j)/surface
      gradient(j) = delta_b(j)*inverse_depth(j)
    end do
    child_status = integrate_vertical_spline_profile(n, matrix, gradient, integrated)
    if (child_status /= 0) then
      status = 3
      return
    end if
    do j = 1, n
      full_b(j) = integrated(j)
    end do
    do j = 1, n
      gradient(j) = delta_b(j)*inverse_depth(j)
    end do
    child_status = integrate_vertical_spline_profile(n, matrix, gradient, integrated)
    if (child_status /= 0) then
      status = 3
      return
    end if
    surface = integrated(n + 1)
    do j = 1, n
      zone(j) = gradient(j)/surface
    end do
    child_status = integrate_vertical_spline_profile(n, matrix, zone, integrated)
    if (child_status /= 0) then
      status = 3
      return
    end if
    do j = 1, n
      temporary = delta_a(j)*inverse_depth(j)
      temporary = temporary/reference_pressure
      gradient(j) = temporary + zone(j)
    end do
    child_status = integrate_vertical_spline_profile(n, matrix, gradient, integrated)
    if (child_status /= 0) then
      status = 3
      return
    end if
    surface = integrated(n + 1)
    do j = 1, n
      temporary = gradient(j)/surface
      gradient(j) = temporary - zone(j)
    end do
    child_status = integrate_vertical_spline_profile(n, matrix, gradient, integrated)
    if (child_status /= 0) then
      status = 3
      return
    end if
    do j = 1, n
      temporary = gradient(j)*reference_pressure
      delta_a(j) = temporary/inverse_depth(j)
      gradient(j) = delta_a(j)*inverse_depth(j)
    end do
    child_status = integrate_vertical_spline_profile(n, matrix, gradient, integrated)
    if (child_status /= 0) then
      status = 3
      return
    end if
    do j = 1, n
      full_a(j) = integrated(j)
    end do
    do j = 1, n
      left = half_a(j)*half_b(j - 1)
      right = half_a(j - 1)*half_b(j)
      c(j) = left - right
    end do
    status = 0
  end function
end module forecast_vertical_hybrid_adjustment
