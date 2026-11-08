!> Native corrected C4 gross polynomial and physical interval roots.
!! Coefficients are in increasing power order. Roots retain FP64 Horner
!! arithmetic, stable turning points and ordered bisection from the contract.
module forecast_plant_physical_roots
  use iso_fortran_env, only: int32, real64
  implicit none
  private
  integer, parameter :: jpim = int32, jprd = real64
  public :: c4_gross_coefficients, c4_physical_roots
contains
  SUBROUTINE C4_GROSS_COEFFICIENTS(CA, GB, G0, PHI, RD, RM, STAR, PA, PB, X1, X2, X3, GBS, OI, ALPHA, GAMMA, COEF)
    REAL(KIND=JPRD), INTENT(IN) :: CA, GB, G0, PHI, RD, RM, STAR, PA, PB, X1, X2, X3, GBS, OI, ALPHA, GAMMA
    REAL(KIND=JPRD), INTENT(OUT) :: COEF(4)
    REAL(KIND=JPRD) :: C0, M, D, X0, N0, N1, N2, O0, O1, B0, Y0, Y1, Y2, E0, E1, E2, H0, H1, H2
    X0 = CA + RD/GB
    C0 = X0 - STAR
    M = PHI - G0/GB
    D = G0*C0
    N0 = X0*D + RD*C0
    N1 = X0*M - D/GB - C0 - RD/GB
    N2 = (1._JPRD - M)/GB
    O1 = ALPHA/(0.047_JPRD*GBS)
    O0 = OI - O1*RD
    B0 = PB + RD - RM
    Y0 = PA*GBS*N0 + B0*D
    Y1 = PA*GBS*N1 + B0*M - D
    Y2 = PA*GBS*N2 - M
    E0 = (GBS*X2*O0 + GBS*X3)*D
    E1 = (GBS*X2*O0 + GBS*X3)*M + (GBS*X2*O1)*D
    E2 = (GBS*X2*O1)*M
    H0 = (GBS*GAMMA*O0)*D
    H1 = (GBS*GAMMA*O0)*M + (GBS*GAMMA*O1)*D
    H2 = (GBS*GAMMA*O1)*M
    COEF(1) = -X1*(Y0 - H0)
    COEF(2) = Y0 + E0 - X1*(Y1 - H1)
    COEF(3) = Y1 + E1 - X1*(Y2 - H2)
    COEF(4) = (ALPHA*X2/0.047_JPRD - 1._JPRD)*M - (PA*GBS*(M - 1._JPRD))/GB
  END SUBROUTINE C4_GROSS_COEFFICIENTS

  SUBROUTINE C4_PHYSICAL_ROOTS(COEF, LOWER, UPPER, ROOTS, NROOT)
    REAL(KIND=JPRD), INTENT(IN) :: COEF(4), LOWER, UPPER
    REAL(KIND=JPRD), INTENT(OUT) :: ROOTS(3)
    INTEGER(KIND=JPIM), INTENT(OUT) :: NROOT
    REAL(KIND=JPRD) :: POINTS(4), VALUES(4), DA, DB, DC, DISC, RAD, QROOT
    REAL(KIND=JPRD) :: TEMP, LO, HI, FLO, FHI, MID, FMID, CANDIDATE
    INTEGER(KIND=JPIM) :: NPOINT, I, J, ITER
    ROOTS = 0._JPRD
    NROOT = 0
    IF (UPPER .LT. LOWER) RETURN
    POINTS(1) = LOWER
    POINTS(2) = UPPER
    NPOINT = 2
    DA = 3._JPRD*COEF(4)
    DB = 2._JPRD*COEF(3)
    DC = COEF(2)
    IF (DA .EQ. 0._JPRD) THEN
      IF (DB .NE. 0._JPRD) CALL ADD_POINT(-DC/DB)
    ELSE
      DISC = DB*DB - 4._JPRD*DA*DC
      IF (DISC .GE. 0._JPRD) THEN
        RAD = SQRT(DISC)
        IF (DB .GE. 0._JPRD) THEN
          QROOT = -0.5_JPRD*(DB + RAD)
        ELSE
          QROOT = -0.5_JPRD*(DB - RAD)
        END IF
        IF (QROOT .EQ. 0._JPRD) THEN
          CALL ADD_POINT(-DB/(2._JPRD*DA))
        ELSE
          CALL ADD_POINT(QROOT/DA)
          CALL ADD_POINT(DC/QROOT)
        END IF
      END IF
    END IF
    DO I = 2, NPOINT
      TEMP = POINTS(I)
      J = I - 1
      DO WHILE (J .GE. 1)
        IF (POINTS(J) .LE. TEMP) EXIT
        POINTS(J + 1) = POINTS(J)
        J = J - 1
      END DO
      POINTS(J + 1) = TEMP
    END DO
    DO I = 1, NPOINT
      VALUES(I) = POLY(POINTS(I))
      IF (VALUES(I) .EQ. 0._JPRD) CALL ADD_ROOT(POINTS(I))
    END DO
    DO I = 1, NPOINT - 1
      LO = POINTS(I)
      HI = POINTS(I + 1)
      FLO = VALUES(I)
      FHI = VALUES(I + 1)
      IF (.NOT. ((FLO .LT. 0._JPRD .AND. FHI .GT. 0._JPRD) .OR. &
                & (FLO .GT. 0._JPRD .AND. FHI .LT. 0._JPRD))) CYCLE
      DO ITER = 1, 2200
        MID = 0.5_JPRD*LO + 0.5_JPRD*HI
        IF (MID .LE. LO .OR. MID .GE. HI) EXIT
        FMID = POLY(MID)
        IF (FMID .EQ. 0._JPRD) THEN
          LO = MID
          HI = MID
          FLO = 0._JPRD
          FHI = 0._JPRD
          EXIT
        END IF
        IF ((FLO .LT. 0._JPRD .AND. FMID .LT. 0._JPRD) .OR. &
            & (FLO .GT. 0._JPRD .AND. FMID .GT. 0._JPRD)) THEN
          LO = MID
          FLO = FMID
        ELSE
          HI = MID
          FHI = FMID
        END IF
      END DO
      CANDIDATE = LO
      IF (ABS(FHI) .LT. ABS(FLO)) CANDIDATE = HI
      CALL ADD_ROOT(CANDIDATE)
    END DO
    DO I = 2, NROOT
      TEMP = ROOTS(I)
      J = I - 1
      DO WHILE (J .GE. 1)
        IF (ROOTS(J) .LE. TEMP) EXIT
        ROOTS(J + 1) = ROOTS(J)
        J = J - 1
      END DO
      ROOTS(J + 1) = TEMP
    END DO
  CONTAINS
    FUNCTION POLY(X) RESULT(VALUE)
      REAL(KIND=JPRD), INTENT(IN) :: X
      REAL(KIND=JPRD) :: VALUE
      VALUE = ((COEF(4)*X + COEF(3))*X + COEF(2))*X + COEF(1)
    END FUNCTION POLY
    SUBROUTINE ADD_POINT(X)
      REAL(KIND=JPRD), INTENT(IN) :: X
      INTEGER(KIND=JPIM) :: K
      IF (X .LE. LOWER .OR. X .GE. UPPER) RETURN
      DO K = 1, NPOINT
        IF (POINTS(K) .EQ. X) RETURN
      END DO
      NPOINT = NPOINT + 1
      POINTS(NPOINT) = X
    END SUBROUTINE ADD_POINT
    SUBROUTINE ADD_ROOT(X)
      REAL(KIND=JPRD), INTENT(IN) :: X
      INTEGER(KIND=JPIM) :: K
      DO K = 1, NROOT
        IF (ROOTS(K) .EQ. X) RETURN
      END DO
      IF (NROOT .GE. 3) ERROR STOP 'C4 polynomial root count exceeds degree'
      NROOT = NROOT + 1
      ROOTS(NROOT) = X
    END SUBROUTINE ADD_ROOT
  END SUBROUTINE C4_PHYSICAL_ROOTS
end module
