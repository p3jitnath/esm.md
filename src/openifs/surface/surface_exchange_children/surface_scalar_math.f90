!> Public scalar mathematical boundaries used by the surface children.
!! Arguments and results are FP64 scalar values. No model state is imported.
module forecast_surface_scalar_math
  use iso_c_binding, only: c_double
  implicit none
  private
  public :: surface_sin, surface_log10, surface_power, surface_exp, surface_log, surface_acos, surface_cos
  interface
    function surface_sin(x) bind(C, name='sin') result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function surface_log10(x) bind(C, name='log10') result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function surface_power(x, a) bind(C, name='md2asm_pow_original_rounding_candidate') result(y)
      import c_double
      real(c_double), value :: x, a
      real(c_double) :: y
    end function
    function surface_exp(x) bind(C, name='exp') result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function surface_log(x) bind(C, name='log') result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function surface_acos(x) bind(C, name='acos') result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function surface_cos(x) bind(C, name='cos') result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
  end interface
end module
