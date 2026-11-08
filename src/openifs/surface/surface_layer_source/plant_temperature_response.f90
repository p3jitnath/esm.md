!> Source-ordered ordinary and modified Arrhenius temperature responses.
!! Temperatures are K, energies J/mol and entropy J/(mol K).
!! The unused TAGF record remains a readonly argument; output is dimensionless.
module forecast_ordered_plant_temperature_response
  use iso_fortran_env, only: real64
  use yos_cst, only: tcst
  use yos_agf, only: tagf
  use forecast_surface_scalar_math, only: surface_exp
  implicit none
  private
  public :: arrhenius_fn, arrhenius_modified_fn
contains
  function arrhenius_fn(temperature, reference, energy, parameters, constants) result(value)
    real(real64), intent(in) :: temperature, reference, energy
    type(tagf), intent(in) :: parameters
    type(tcst), intent(in) :: constants
    real(real64) :: value
    real(real64), volatile :: numerator, denominator
    numerator = temperature - reference
    numerator = numerator*energy
    denominator = reference*constants%r
    denominator = denominator*temperature
    numerator = numerator/denominator
    value = surface_exp(numerator)
  end function arrhenius_fn
  function arrhenius_modified_fn(temperature, reference, energy, deactivation, entropy, parameters, constants) result(value)
    real(real64), intent(in) :: temperature, reference, energy, deactivation, entropy
    type(tagf), intent(in) :: parameters
    type(tcst), intent(in) :: constants
    real(real64) :: value
    real(real64), volatile :: numerator, denominator, a, b, base
    numerator = temperature - reference
    numerator = numerator*energy
    denominator = reference*constants%r
    denominator = denominator*temperature
    numerator = numerator/denominator
    base = surface_exp(numerator)
    a = reference*entropy
    a = a - deactivation
    b = reference*constants%r
    a = a/b
    a = surface_exp(a)
    a = 1.0_real64 + a
    base = base*a
    a = temperature*entropy
    a = a - deactivation
    b = constants%r*temperature
    a = a/b
    a = surface_exp(a)
    a = 1.0_real64 + a
    value = base/a
  end function arrhenius_modified_fn
end module forecast_ordered_plant_temperature_response
