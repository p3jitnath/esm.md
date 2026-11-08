!> Preserve scalar power, exponential and logarithm boundaries for convection.
module convection_source_math_mod
  use iso_fortran_env, only: int32, real32, real64
  use iso_c_binding, only: c_double
  use forecast_public_scalar_math, only: power_original_rounding
  implicit none
  private
  public :: source_power, source_exp, source_log
  interface source_power
    module procedure integer_power, real_power, real32_power
  end interface
  interface
    function source_exp(x) bind(C, name='exp') result(value)
      import c_double
      real(c_double), value :: x
      real(c_double) :: value
    end function
    function source_log(x) bind(C, name='log') result(value)
      import c_double
      real(c_double), value :: x
      real(c_double) :: value
    end function
  end interface
contains
  real(real64) function integer_power(base, exponent) result(value)
    real(real64), intent(in) :: base
    integer(int32), intent(in) :: exponent
    real(real64) :: temporary
    select case (exponent)
    case (0); value = 1.0_real64
    case (1); value = base
    case (2); value = base*base
    case (3); temporary = base*base; value = temporary*base
    case (4); temporary = base*base; value = temporary*temporary
    case (-1); value = 1.0_real64/base
    case (-2); temporary = base*base; value = 1.0_real64/temporary
    case (-3); temporary = base*base; temporary = temporary*base; value = 1.0_real64/temporary
    case (-4); temporary = base*base; temporary = temporary*temporary; value = 1.0_real64/temporary
    case default; value = base**exponent
    end select
  end function
  real(real64) function real_power(base, exponent) result(value)
    real(real64), intent(in) :: base, exponent
    value = power_original_rounding(base, exponent)
  end function
  real(real64) function real32_power(base, exponent) result(value)
    real(real64), intent(in) :: base
    real(real32), intent(in) :: exponent
    ! Preserve the original widened single-precision exponent word.
    value = power_original_rounding(base, real(exponent, real64))
  end function
end module convection_source_math_mod
