!> Neutral ocean roughness in metres from the source Newton iteration.
!! Inputs are wind(m/s), geopotential(m2/s2), dimensionless Charnock value,
!! gravity(m/s2), viscosity(m2/s) and dimensionless von Karman constant.
!! All inputs are finite, wind/geopotential/gravity/viscosity are positive,
!! and Charnock is nonnegative. The caller admits the source domain.
module forecast_neutral_ocean_roughness
  use iso_fortran_env, only: int32, real64
  use forecast_surface_scalar_math, only: surface_log
  implicit none
  private
  integer, parameter :: jpim = int32, jprb = real64
  public :: pz0wn
contains

  FUNCTION PZ0WN(PWIND, PGEO, PCHAR, PG, PNUM, PKAP)

    IMPLICIT NONE

    REAL(KIND=JPRB) :: PZ0WN

    REAL(KIND=JPRB), intent(in) :: PWIND, PGEO, PCHAR, PG, PNUM, PKAP

    INTEGER(KIND=JPIM), PARAMETER :: NITER = 15

    REAL(KIND=JPRB), PARAMETER :: ACD = 0.0008_JPRB
    REAL(KIND=JPRB), PARAMETER :: BCD = 0.00008_JPRB

    REAL(KIND=JPRB), PARAMETER :: XEPS = 0.00001_JPRB
    REAL(KIND=JPRB), PARAMETER :: USTMIN = 0.000001_JPRB
    REAL(KIND=JPRB), PARAMETER :: PCHARMAX = 0.1_JPRB
    REAL(KIND=JPRB), PARAMETER :: Z0FG = 0.01_JPRB

    INTEGER(KIND=JPIM) :: ITER
    REAL(KIND=JPRB) :: ZLEV, XZLEV, PCHAROG, XKPWIND, XOLOGZ0
    REAL(KIND=JPRB) :: UST, USTOLD, Z0, Z0CH, Z0VIS, F, DELF

    ZLEV = PGEO/PG

    XKPWIND = PKAP*PWIND
    PCHAROG = MIN(PCHAR, PCHARMAX)/PG

    UST = PWIND*SQRT(ACD + BCD*PWIND)

    DO ITER = 1, NITER
      USTOLD = MAX(UST, USTMIN)
      Z0CH = PCHAROG*UST**2
      Z0VIS = PNUM/UST
      Z0 = Z0CH + Z0VIS
      XZLEV = ZLEV/(ZLEV + Z0)
      XOLOGZ0 = 1.0_JPRB/surface_log(1.0_JPRB + ZLEV/Z0)
      F = UST - XKPWIND*XOLOGZ0
      DELF = 1.0_JPRB - XKPWIND*XOLOGZ0**2*XZLEV*(2.0_JPRB*Z0CH - Z0VIS)/(UST*Z0)
      IF (DELF /= 0.0_JPRB) UST = UST - F/DELF
      IF (ABS(UST - USTOLD) <= UST*XEPS .AND. ABS(F) <= XEPS) EXIT
    END DO

    IF (ITER > NITER) THEN
      PZ0WN = Z0FG
    ELSE
      UST = MAX(UST, USTMIN)
      PZ0WN = PNUM/UST + PCHAROG*UST**2
    END IF

  END FUNCTION PZ0WN
end module
