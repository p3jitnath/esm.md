!> FP64 ordinary and modified Arrhenius temperature responses.
!! Temperatures use kelvin, activation/deactivation energies J/mol,
!! entropy J/(mol K), and returned multipliers are dimensionless.
!! TCST and TAGF are actual readonly parameter owners.
module forecast_plant_temperature_response
  use iso_fortran_env, only: real64
  use forecast_surface_scalar_math, only: surface_exp
  use yos_cst, only: tcst
  use yos_agf, only: tagf
  implicit none
  private
  integer, parameter :: jprb = real64
  public :: arrhenius, arrhenius_fn, arrhenius_modified_fn
  interface arrhenius
    module procedure arrhenius_fn, arrhenius_modified_fn
  end interface
contains
  FUNCTION ARRHENIUS_FN(PTEMP, PREF_TEMP, PENERGY_ACT, YDAGF, YDCST) RESULT(ARRHENIUS_VAL)

    IMPLICIT NONE
    REAL(KIND=JPRB), INTENT(IN) :: PTEMP
    REAL(KIND=JPRB), INTENT(IN) :: PREF_TEMP
    REAL(KIND=JPRB), INTENT(IN) :: PENERGY_ACT
    TYPE(TAGF), INTENT(IN) :: YDAGF
    TYPE(TCST), INTENT(IN) :: YDCST

    REAL(KIND=JPRB) :: ARRHENIUS_VAL

    ARRHENIUS_VAL = surface_exp(((PTEMP - PREF_TEMP)*PENERGY_ACT)/(PREF_TEMP*YDCST%R*(PTEMP)))

  END FUNCTION ARRHENIUS_FN

  FUNCTION ARRHENIUS_MODIFIED_FN(PTEMP, PREF_TEMP, PENERGY_ACT, PENERGY_DEACT, PENTROPY, YDAGF, YDCST) RESULT(VAL_ARRHENIUS)

    REAL(KIND=JPRB), INTENT(IN) :: PTEMP
    REAL(KIND=JPRB), INTENT(IN) :: PREF_TEMP
    REAL(KIND=JPRB), INTENT(IN) :: PENERGY_ACT
    REAL(KIND=JPRB), INTENT(IN) :: PENERGY_DEACT
    REAL(KIND=JPRB), INTENT(IN) :: PENTROPY
    TYPE(TAGF), INTENT(IN) :: YDAGF
    TYPE(TCST), INTENT(IN) :: YDCST

    REAL(KIND=JPRB) :: VAL_ARRHENIUS

    VAL_ARRHENIUS = surface_exp(((PTEMP - PREF_TEMP)*PENERGY_ACT)/(PREF_TEMP*YDCST%R*(PTEMP))) &
           &  *(1._JPRB + surface_exp((PREF_TEMP*PENTROPY - PENERGY_DEACT)/(PREF_TEMP*YDCST%R))) &
           &  /(1._JPRB + surface_exp((PTEMP*PENTROPY - PENERGY_DEACT)/(YDCST%R*PTEMP)))

  END FUNCTION ARRHENIUS_MODIFIED_FN
end module
