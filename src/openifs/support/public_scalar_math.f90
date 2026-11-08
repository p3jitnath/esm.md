!> Bind our typed scalar calls to the admitted public GNU math service.
!! Arguments and results use FP64. Power arguments have caller-defined units;
!! inverse tangent takes a dimensionless argument and returns radians.
!! The caller supplies nearest-even rounding and gradual underflow.
!! This module performs no numerical calculation and owns no coefficient table.
module forecast_public_scalar_math
  use, intrinsic :: iso_c_binding, only: c_double
  implicit none
  private
  public :: power_original_rounding, atan_original_rounding
  interface
    function public_power(x, y) bind(C, name="pow") result(value)
      import c_double
      real(c_double), value :: x, y
      real(c_double) :: value
    end function public_power
    function public_inverse_tangent(x) bind(C, name="atan") result(value)
      import c_double
      real(c_double), value :: x
      real(c_double) :: value
    end function public_inverse_tangent
  end interface
contains
  !> Return the public power result, including its natural flags and errno.
  !! This C-value interface has no buffers or hidden numerical work.
  !! Private diagnostic counters from the replaced helper are not public state.
  function power_original_rounding(x, y) bind(C, name="md2asm_pow_original_rounding_candidate") result(value)
    real(c_double), value, intent(in) :: x, y
    real(c_double) :: value
    value = public_power(x, y)
  end function power_original_rounding

  !> Return the public inverse tangent for a finite FP64 argument.
  !! The accepted caller domain is finite x with FPCR zero on the Arm target.
  !! Domain and machine-mode validation belong to the typed caller contract.
  function atan_original_rounding(x) bind(C, name="md2asm_atan_original_rounding") result(value)
    real(c_double), value, intent(in) :: x
    real(c_double) :: value
    value = public_inverse_tangent(x)
  end function atan_original_rounding
end module forecast_public_scalar_math
