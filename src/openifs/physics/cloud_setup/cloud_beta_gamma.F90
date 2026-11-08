!> Ordered gamma and incomplete-beta calculations used by cloud setup.
!! Inputs and results are dimensionless. Gamma operands use the accepted
!! positive interval2:8. Beta shapes and coordinates follow the setup contract.
!! Every arithmetic statement retains one source FP64 rounding point.
module cloud_beta_gamma_mod
  use iso_fortran_env, only: real64, int32, int64
  use iso_c_binding, only: c_double
  implicit none
  private
  public :: cloud_gamma_log, cloud_generalized_gamma, cloud_beta_continued_fraction, cloud_incomplete_beta
  real(real64), parameter :: coefficients64(8) = [76.18009172947146_real64, -86.50532032941677_real64, &
                                                 24.01409824083091_real64, -1.231739572450155_real64, 0.001208650973866179_real64, &
                                                  -0.000005395239384953_real64, 1.000000000190015_real64, 2.5066282746310005_real64]
  integer(int64), parameter :: coefficient_words32(8) = [int(z'40530b86a0000000', int64), &
                                int(z'c055a05720000000', int64), int(z'4038039c00000000', int64), int(z'bff3b53480000000', int64), &
                                int(z'3f53cd7320000000', int64), int(z'bed6a11820000000', int64), int(z'3ff0000000000000', int64), &
                                                         int(z'40040d9320000000', int64)]
  real(real64), parameter :: coefficients32(8) = transfer(coefficient_words32, [0.0_real64], 8)
  interface
    function scalar_log(argument) bind(C, name="log") result(value)
      import c_double
      real(c_double), value :: argument
      real(c_double) :: value
    end function scalar_log
    function scalar_exp(argument) bind(C, name="exp") result(value)
      import c_double
      real(c_double), value :: argument
      real(c_double) :: value
    end function scalar_exp
    function scalar_sin(argument) bind(C, name="sin") result(value)
      import c_double
      real(c_double), value :: argument
      real(c_double) :: value
    end function scalar_sin
  end interface
contains
  !> Evaluate the selected log-gamma series at a positive scalar.
  !! Mode0 uses full FP64 source coefficients and successive denominators;
  !! mode1 uses the source default-REAL coefficients widened to FP64.
  function cloud_gamma_log(x, mode) result(value)
    real(real64), intent(in) :: x
    integer(int32), intent(in) :: mode
    real(real64) :: value, shifted, weight, series, denominator, term, coefficients(8)
    integer(int32) :: index
    shifted = x + 5.5_real64
    weight = x + 0.5_real64
    value = scalar_log(shifted)
    value = weight*value
    shifted = value - shifted
    if (mode == 0) then
      coefficients = coefficients64
    else
      coefficients = coefficients32
    end if
    series = coefficients(7)
    denominator = x
    do index = 1, 6
      if (mode == 0) then
        denominator = denominator + 1.0_real64
      else
        denominator = real(index, real64) + x
      end if
      term = coefficients(index)/denominator
      series = series + term
    end do
    series = coefficients(8)*series
    series = series/x
    value = scalar_log(series)
    value = shifted + value
  end function cloud_gamma_log

  !> Retain the complete positive-domain gamma and evaluated reflection.
  !! RPI is the owned upstream value of pi. Volatile weights preserve the
  !! source reflection operations, including their natural exception flags.
  function cloud_generalized_gamma(x, rpi) result(value)
    real(real64), intent(in) :: x, rpi
    real(real64) :: value, argument, reflection, gamma
    real(real64), volatile :: zero_weight, one_weight
    zero_weight = 0.0_real64
    one_weight = 1.0_real64
    argument = 1.0_real64 - x
    argument = argument*zero_weight
    value = x*one_weight
    argument = argument + value
    value = cloud_gamma_log(argument, 1_int32)
    gamma = scalar_exp(value)
    argument = rpi*x
    reflection = scalar_sin(argument)
    reflection = rpi/reflection
    reflection = reflection/gamma
    reflection = reflection*zero_weight
    value = gamma*one_weight
    value = value + reflection
  end function cloud_generalized_gamma

  !> Evaluate the complete100-iteration bounded continued fraction.
  function cloud_beta_continued_fraction(p, q, x) result(value)
    real(real64), intent(in) :: p, q, x
    real(real64) :: value, pq, pplus, pminus, c, d, coefficient, delta, step, twice, temporary, denominator
    integer(int32) :: iteration
    real(real64), parameter :: minimum_denominator = 1.0e-30_real64, tolerance = 3.0e-7_real64
    pq = p + q
    pplus = p + 1.0_real64
    pminus = p - 1.0_real64
    c = 1.0_real64
    d = pq*x
    d = d/pplus
    d = 1.0_real64 - d
    if (abs(d) < minimum_denominator) d = minimum_denominator
    d = 1.0_real64/d
    value = d
    do iteration = 1, 100
      step = real(iteration, real64)
      twice = real(2*iteration, real64)
      temporary = q - step
      coefficient = step*temporary
      coefficient = coefficient*x
      denominator = pminus + twice
      temporary = p + twice
      denominator = denominator*temporary
      coefficient = coefficient/denominator
      d = coefficient*d
      d = 1.0_real64 + d
      if (abs(d) < minimum_denominator) d = minimum_denominator
      temporary = coefficient/c
      c = 1.0_real64 + temporary
      if (abs(c) < minimum_denominator) c = minimum_denominator
      d = 1.0_real64/d
      value = value*d
      value = value*c
      temporary = p + step
      coefficient = -temporary
      temporary = pq + step
      coefficient = coefficient*temporary
      coefficient = coefficient*x
      denominator = p + twice
      temporary = pplus + twice
      denominator = denominator*temporary
      coefficient = coefficient/denominator
      d = coefficient*d
      d = 1.0_real64 + d
      if (abs(d) < minimum_denominator) d = minimum_denominator
      temporary = coefficient/c
      c = 1.0_real64 + temporary
      if (abs(c) < minimum_denominator) c = minimum_denominator
      d = 1.0_real64/d
      delta = d*c
      value = value*delta
      if (iteration == 100) exit
      temporary = delta - 1.0_real64
      if (abs(temporary) <= tolerance) exit
    end do
  end function cloud_beta_continued_fraction

  !> Evaluate the direct or symmetric incomplete-beta expression.
  function cloud_incomplete_beta(p, q, x) result(value)
    real(real64), intent(in) :: p, q, x
    real(real64) :: value, factor, argument, temporary, threshold
    if (x > 0.0_real64 .and. x < 1.0_real64) then
      argument = p + q
      factor = cloud_gamma_log(argument, 0_int32)
      temporary = cloud_gamma_log(p, 0_int32)
      factor = factor - temporary
      temporary = cloud_gamma_log(q, 0_int32)
      factor = factor - temporary
      temporary = scalar_log(x)
      temporary = p*temporary
      factor = factor + temporary
      argument = 1.0_real64 - x
      temporary = scalar_log(argument)
      temporary = q*temporary
      factor = factor + temporary
      factor = scalar_exp(factor)
    else
      factor = 0.0_real64
    end if
    threshold = p + q
    threshold = threshold + 2.0_real64
    temporary = p + 1.0_real64
    threshold = temporary/threshold
    if (x < threshold) then
      value = cloud_beta_continued_fraction(p, q, x)
      value = factor*value
      value = value/p
    else
      argument = 1.0_real64 - x
      value = cloud_beta_continued_fraction(q, p, argument)
      value = factor*value
      value = value/q
      value = 1.0_real64 - value
    end if
  end function cloud_incomplete_beta
end module cloud_beta_gamma_mod
