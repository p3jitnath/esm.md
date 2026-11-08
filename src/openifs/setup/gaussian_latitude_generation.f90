!> Calculate the selected Gaussian grid through the frozen Fourier/Newton route.
module forecast_gaussian_latitude_generation
  use iso_c_binding, only: c_int, c_int64_t, c_double
  implicit none
  private
  public :: initialize_selected_gaussian_latitudes, legendre_fourier_coefficients
  public :: legendre_newton_step, refine_gaussian_latitude
  interface
    function public_sine(x) bind(C, name="sin") result(value)
      import c_double
      real(c_double), value :: x
      real(c_double) :: value
    end function
    function public_cosine(x) bind(C, name="cos") result(value)
      import c_double
      real(c_double), value :: x
      real(c_double) :: value
    end function
    function public_tangent(x) bind(C, name="tan") result(value)
      import c_double
      real(c_double), value :: x
      real(c_double) :: value
    end function
  end interface
contains
  !> Form the seventeen dimensionless Fourier coefficients for degree 32.
  !! Output coefficients have bounds 0:16; every rounded recurrence is retained.
  subroutine legendre_fourier_coefficients(coefficients)
    real(c_double), intent(out) :: coefficients(0:16)
    real(c_double) :: value, temporary
    integer :: j, k, numerator, denominator
    value = 2.0_c_double
    do j = 1, 32
      temporary = 0.25_c_double/real(j*j, c_double)
      temporary = 1.0_c_double - temporary
      temporary = sqrt(temporary)
      value = value*temporary
    end do
    coefficients(16) = value
    k = 15
    do j = 2, 32, 2
      numerator = (j - 1)*(66 - j)
      value = value*real(numerator, c_double)
      denominator = j*(65 - j)
      value = value/real(denominator, c_double)
      coefficients(k) = value
      k = k - 1
    end do
  end subroutine

  !> Perform one degree-32 Newton or final weight calculation.
  !! theta/new_theta/correction use radians, while weight is dimensionless.
  !! weight_mode false changes new_theta/correction only; true changes weight
  !! only. The Fourier coefficient and trigonometric call order stays fixed.
  subroutine legendre_newton_step(coefficients, theta, weight_mode, weight, new_theta, correction)
    real(c_double), intent(in) :: coefficients(0:16), theta
    logical, intent(in) :: weight_mode
    real(c_double), intent(inout) :: weight, new_theta, correction
    real(c_double) :: polynomial, derivative, angle, term, frequency
    integer :: j
    polynomial = 0.5_c_double*coefficients(0)
    derivative = 0.0_c_double
    do j = 1, 16
      frequency = real(2*j, c_double)
      angle = frequency*theta
      if (.not. weight_mode) then
        term = public_cosine(angle)
        term = coefficients(j)*term
        polynomial = polynomial + term
      end if
      term = public_sine(angle)
      frequency = coefficients(j)*frequency
      term = frequency*term
      derivative = derivative - term
    end do
    if (weight_mode) then
      term = derivative*derivative
      weight = 65.0_c_double/term
    else
      term = -polynomial
      correction = term/derivative
      new_theta = theta + correction
    end if
  end subroutine

  !> Refine one northern angle, including the separate final weight iteration.
  !! The degree-32 source permits at most 21 iterations and uses 1000*epsilon.
  !! Return zero after the final weight step or three outside that convergence
  !! domain. An ordinary source-angle input converges before this bound.
  integer(c_int) function refine_gaussian_latitude(coefficients, theta, weight) result(status)
    real(c_double), intent(in) :: coefficients(0:16)
    real(c_double), intent(inout) :: theta, weight
    real(c_double) :: current, new_theta, correction, threshold, temporary_weight
    logical :: weight_mode
    integer :: iteration
    current = theta
    threshold = epsilon(1.0_c_double)*1000.0_c_double
    weight_mode = .false.
    status = 3
    do iteration = 1, 21
      call legendre_newton_step(coefficients, current, weight_mode, temporary_weight, new_theta, correction)
      current = new_theta
      if (weight_mode) then
        theta = new_theta
        weight = temporary_weight
        status = 0
        return
      end if
      if (abs(correction) <= threshold) weight_mode = .true.
    end do
  end function

  !> Construct all 32 sine values and half-integral Gaussian weights.
  !! Outputs are two disjoint caller-owned FP64 arrays with 32 entries.
  !! There is no stored grid, input packet or original numerical callable.
  integer(c_int) function initialize_selected_gaussian_latitudes(sines, weights) &
    bind(C, name="md2asm_initialize_selected_gaussian_latitudes_fortran") result(status)
    real(c_double), intent(inout) :: sines(32), weights(32)
    real(c_double) :: coefficients(0:16), theta(16), pi, angle, temporary
    real(c_double), volatile :: diagnostic_cosine
    integer :: j
    call legendre_fourier_coefficients(coefficients)
    pi = transfer(int(z'400921fb54442d18', c_int64_t), pi)
    do j = 1, 16
      angle = real(4*j - 1, c_double)*pi
      angle = angle/130.0_c_double
      temporary = public_tangent(angle)
      temporary = temporary*8192.0_c_double
      temporary = 1.0_c_double/temporary
      theta(j) = angle + temporary
      diagnostic_cosine = public_cosine(angle)
      diagnostic_cosine = public_cosine(theta(j))
    end do
    do j = 16, 1, -1
      status = refine_gaussian_latitude(coefficients, theta(j), weights(j))
      if (status /= 0) return
    end do
    do j = 1, 16
      sines(j) = public_cosine(theta(j))
    end do
    do j = 1, 16
      sines(33 - j) = -sines(j)
      weights(33 - j) = weights(j)
    end do
    status = 0
  end function
end module forecast_gaussian_latitude_generation
