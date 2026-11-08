!> Complete source-ordered mountain-wave state and level preparation.
!! Inputs use pressure Pa, temperature K, velocity m/s, geopotential m2/s2
!! and mountain height metres. Outputs retain the original named shapes.
!! Physical constants are borrowed from the produced canonical native record.
!! The caller admits the complete finite physical and derived-index domain
!! in gwsetup.md. New-route byte/status/buffer verification remains pending.
module md2asm_mountain_wave_setup
  use iso_c_binding, only: c_double
  implicit none
  private
  public :: gwsetup
  interface
    function source_atan(x) bind(C, name="atan") result(y)
      import :: c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function source_sine(x) bind(C, name="sin") result(y)
      import :: c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function source_cosine(x) bind(C, name="cos") result(y)
      import :: c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
  end interface
contains
! (C) Copyright 1989- ECMWF.
! This software is licensed under the terms of the Apache Licence Version 2.0
! which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
!
! In applying this licence, ECMWF does not waive the privileges and immunities
! granted to it by virtue of its status as an intergovernmental organisation
! nor does it submit to any jurisdiction

!OPTIONS XOPT(HSFUN)
  SUBROUTINE GWSETUP &
   & (physical, YDEGWD, KIDIA, KFDIA, KLON, KLEV, LDGWD,&
   & KKCRITH, KCRIT,&
   & KKENVH, KKNU, KKNU2,&
   & PAPHM1, PAPM1, PUM1, PVM1, PTM1, PGEOM1, PHSTD,&
   & PRHO, PRI, PSTAB, PTAU, PVPH, PPSI, PZDEP,&
   & PULOW, PVLOW,&
   & PTHETA, PGAMMA, PNU, PD1, PD2, PDMOD, status)

!**** *GWSETUP*

!     PURPOSE.

!**   INTERFACE.
!     ----------
!          FROM *GWDRAG*

!        EXPLICIT ARGUMENTS :
!        --------------------

!     ==== INPUTS ===

!        *KIDIA*       START POINT
!        *KFDIA*       END POINT
!        *KLON*        NUMBER OF GRID POINTS PER PACKET
!        *KLEV*        NUMBER OF VERTICAL LEVELS
!        *LDGWD*       TRUE IF SSO ACTIVE
!        *PAPHM1*      PRESSURE AT HALF LEVELS AT T-1
!        *PAPM1*       PRESSURE AT FULL LEVELS AT T-1
!        *PUM1*        X-VELOCITY COMPONENT AT T-1
!        *PVM1*        Y-VELOCITY COMPONENT AT T-1
!        *PTM1*        TEMPERATURE AT T-1
!        *PGEOM1*      GEOPOTENTIAL AT T-1
!        *PHSTD*       STANDARD DEVIATION OF THE OROGRAPHY
!        *PTHETA*      GEOGRAPHICAL ORIENTATION OF THE OROGRAPHY
!        *PGAMMA*      ANISOTROPY OF THE OROGRAPHY

!     ==== OUTPUTS ===

!        *KKCRITH*     MAXIMUM LEVEL FOR WAVE BREAKING
!        *KCRIT*       CRITICAL LEVEL
!        *KKENVH*      BLOCKING LEVEL (TOP OF ENVELOPE LAYER)
!        *KKNU*        MODEL LEVEL AT 4*PHSTD HEIGHT
!        *KKNU2*       MODEL LEVEL AT 3*PHSTD HEIGHT
!        *PRHO*        AIR DENSITY
!        *PRI*         MEAN FLOW RICHARDSON NUMBER
!        *PSTAB*       SQUARE OF THE BRUNT-VAISALA FREQUENCY
!        *PTAU*        STRESS PRODUCED BY GRAVITY WAVES
!        *PVPH*        WIND PROJECTION ALONG SURFACE STRESS AT HALF LEVELS
!        *PPSI*        ANGLE BETWEEN THE LOW-LEVEL WIND DIRECTION
!                      AND THE PRINCIPAL AXIS OF TOPOGRAPHY
!        *PZDEP*       VERTICAL LEAKINESS (LENGTH OF THE MOUNTAIN SEEN
!                      BY THE FLOW)
!        *PULOW*       LOW-LEVEL BLOCKED FLOW X-COMPONENT
!        *PVLOW*       LOW-LEVEL BLOCKED FLOW Y-COMPONENT
!        *PNU*         NON-DIMENSIONAL HEIGHT
!        *PD1*         X-DIRECTION OF THE SURFACE STRESS
!        *PD2*         Y-DIRECTION OF THE SURFACE STRESS
!        *PDMOD*       MODULUS OF THE SURFACE STRESS (PART)

!        IMPLICIT ARGUMENTS :   NONE
!        --------------------

!     METHOD.
!     -------

!     EXTERNALS.
!     ----------

!     REFERENCE.
!     ----------

!        SEE ECMWF RESEARCH DEPARTMENT DOCUMENTATION OF THE "I.F.S."

!     AUTHOR.
!     -------
!      M.MILLER

!     MODIFICATIONS.
!     --------------
!      M.Hamrud      01-Oct-2003 CY28 Cleaning
!      A. Beljaars   15-Jun-2012 suppressing some resolution dependence
!-----------------------------------------------------------------------

    USE PARKIND1, ONLY: JPIM, JPRB

    USE YOEGWD, ONLY: TEGWD

    USE physical_constant_setup_port, ONLY: forecast_physical_constants
    IMPLICIT NONE
    TYPE(forecast_physical_constants), INTENT(IN) :: physical
    INTEGER(KIND=JPIM), INTENT(OUT) :: status

    TYPE(TEGWD), INTENT(IN) :: YDEGWD
    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEV
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    LOGICAL, INTENT(IN) :: LDGWD(KLON)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KKCRITH(KLON)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KCRIT(KLON)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KKENVH(KLON)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KKNU(KLON)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KKNU2(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PAPHM1(KLON, 0:KLEV) !note callpar indexing convention
    REAL(KIND=JPRB), INTENT(IN) :: PAPM1(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PUM1(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PVM1(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PTM1(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PGEOM1(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PHSTD(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PRHO(KLON, KLEV + 1)
    REAL(KIND=JPRB), INTENT(INOUT) :: PRI(KLON, KLEV + 1)
    REAL(KIND=JPRB), INTENT(INOUT) :: PSTAB(KLON, KLEV + 1)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTAU(KLON, KLEV + 1)
    REAL(KIND=JPRB), INTENT(INOUT) :: PVPH(KLON, KLEV + 1)
    REAL(KIND=JPRB), INTENT(INOUT) :: PPSI(KLON, KLEV + 1)
    REAL(KIND=JPRB), INTENT(INOUT) :: PZDEP(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(INOUT) :: PULOW(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PVLOW(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PTHETA(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PGAMMA(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PNU(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PD1(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PD2(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDMOD(KLON)

!-----------------------------------------------------------------------

    LOGICAL :: LL1(KLON, KLEV + 1)
    INTEGER(KIND=JPIM) :: IKNUB(KLON), IKNUL(KLON)

    REAL(KIND=JPRB) :: ZHCRIT(KLON, KLEV), ZVPF(KLON, KLEV), ZDP(KLON, KLEV), ZSQST(KLON, KLEV)
    REAL(KIND=JPRB) :: ZNORM(KLON), ZB(KLON), ZC(KLON),&
     & ZULOW(KLON), ZVLOW(KLON), ZNUP(KLON), ZNUM(KLON)

    INTEGER(KIND=JPIM) :: ILEVH, JK, JL

    LOGICAL :: LLO

    REAL(KIND=JPRB) :: ZCONS1, ZCONS2, ZDELP, ZDWIND, ZGGEENV, ZGGEOM1,&
     & ZGVAR, ZHGEO, ZPHI, ZRHOM, ZRHOP, ZST, ZSTABM, &
     & ZSTABP, ZU, ZVT1, ZVT2, ZWIND, Z1D2RG

    VOLATILE :: ZCONS1, ZCONS2, Z1D2RG

!     ------------------------------------------------------------------

!*         1.    INITIALIZATION
!                --------------

!     ------------------------------------------------------------------

!*         1.1   COMPUTATIONAL CONSTANTS
!                -----------------------

    ASSOCIATE (GFRCRIT => YDEGWD%GFRCRIT, GRCRIT => YDEGWD%GRCRIT, GSSEC => YDEGWD%GSSEC, &
     & GTSEC => YDEGWD%GTSEC, GVSEC => YDEGWD%GVSEC, NKTOPG => YDEGWD%NKTOPG)
      status = 2
      IF (KLON < 1 .OR. KLON > 4096 .OR. KLEV < 6 .OR. KLEV > 512) RETURN
      IF (KIDIA < 1 .OR. KIDIA > KLON + 1 .OR. KFDIA < KIDIA - 1 .OR. KFDIA > KLON) RETURN
      IF (physical%initialized /= 1) RETURN
      IF (NKTOPG < KLEV/3 .OR. NKTOPG > KLEV) RETURN
      ILEVH = KLEV/3

      ZCONS1 = 1.0_JPRB/physical%rd
      ZCONS2 = physical%rg**2/physical%rcpd
      Z1D2RG = 1.0_JPRB/(2.0_JPRB*physical%rg)

!     ------------------------------------------------------------------

!*         2.
!                --------------

!     ------------------------------------------------------------------
!C*     INITIALIZE VARIOUS ARRAYS

      DO JL = KIDIA, KFDIA
        KKNU(JL) = KLEV
        KKNU2(JL) = KLEV
        IKNUB(JL) = KLEV
        IKNUL(JL) = KLEV
        KKCRITH(JL) = KLEV
        KKENVH(JL) = KLEV
        KCRIT(JL) = 1
        PGAMMA(JL) = MAX(PGAMMA(JL), GTSEC)
        PULOW(JL) = 0.0_JPRB
        PVLOW(JL) = 0.0_JPRB
        ZULOW(JL) = 0.0_JPRB
        ZVLOW(JL) = 0.0_JPRB
        PNU(JL) = 0.0_JPRB
        ZNUM(JL) = 0.0_JPRB
        PTAU(JL, :) = 0.0_JPRB
        PRHO(JL, :) = 0.0_JPRB
        PSTAB(JL, :) = 0.0_JPRB
        PRI(JL, :) = 9999.0_JPRB
        PVPH(JL, :) = 0.0_JPRB
        PZDEP(JL, :) = 0.0_JPRB
        PPSI(JL, :) = 0.0_JPRB
        LL1(JL, :) = .FALSE.
      END DO

!*         2.1     DEFINE LOW LEVEL WIND, PROJECT WINDS IN PLANE OF
!*                 LOW LEVEL WIND AND SET INDICATOR FOR CRITICAL LEVELS.

!*      DEFINE VARIOUS LEVELS IN THE FLOW
!       ----------------------------
      DO JK = KLEV, ILEVH, -1
        DO JL = KIDIA, KFDIA
          IF (LDGWD(JL)) THEN
            ZHCRIT(JL, JK) = 4.0_JPRB*PHSTD(JL)
            ZHGEO = (PGEOM1(JL, JK) + PGEOM1(JL, JK - 1))*Z1D2RG
            LL1(JL, JK) = (ZHGEO > ZHCRIT(JL, JK))
            IF (LL1(JL, JK) .NEQV. LL1(JL, JK + 1)) THEN
              KKNU(JL) = JK
            END IF
          END IF
        END DO
      END DO
      DO JK = KLEV, ILEVH, -1
        DO JL = KIDIA, KFDIA
          IF (LDGWD(JL)) THEN
            ZHCRIT(JL, JK) = 3.0_JPRB*PHSTD(JL)
            ZHGEO = (PGEOM1(JL, JK) + PGEOM1(JL, JK - 1))*Z1D2RG
            LL1(JL, JK) = (ZHGEO > ZHCRIT(JL, JK))
            IF (LL1(JL, JK) .NEQV. LL1(JL, JK + 1)) THEN
              KKNU2(JL) = JK
            END IF
          END IF
        END DO
      END DO
      DO JK = KLEV, ILEVH, -1
        DO JL = KIDIA, KFDIA
          IF (LDGWD(JL)) THEN
            ZHCRIT(JL, JK) = 2.0_JPRB*PHSTD(JL)
            ZHGEO = (PGEOM1(JL, JK) + PGEOM1(JL, JK - 1))*Z1D2RG
            LL1(JL, JK) = (ZHGEO > ZHCRIT(JL, JK))
            IF (LL1(JL, JK) .NEQV. LL1(JL, JK + 1)) THEN
              IKNUB(JL) = JK
            END IF
          END IF
        END DO
      END DO
      DO JK = KLEV, ILEVH, -1
        DO JL = KIDIA, KFDIA
          IF (LDGWD(JL)) THEN
            ZHCRIT(JL, JK) = 1.0_JPRB*PHSTD(JL)
            ZHGEO = (PGEOM1(JL, JK) + PGEOM1(JL, JK - 1))*Z1D2RG
            LL1(JL, JK) = (ZHGEO > ZHCRIT(JL, JK))
            IF (LL1(JL, JK) .NEQV. LL1(JL, JK + 1)) THEN
              IKNUL(JL) = JK
            END IF
          END IF
        END DO
      END DO

      DO JL = KIDIA, KFDIA
        KKNU(JL) = MIN(KKNU(JL), NKTOPG)
        IKNUB(JL) = MIN(IKNUB(JL), NKTOPG)
        IF (IKNUB(JL) == NKTOPG) IKNUL(JL) = KLEV
        IF (IKNUB(JL) == IKNUL(JL)) IKNUL(JL) = IKNUL(JL) + 1
      END DO

!*       DEFINE STATIC STABILITY AND AIR DENSITY
!*       ---------------------------------------

      DO JK = KLEV, 2, -1
        DO JL = KIDIA, KFDIA
          IF (LDGWD(JL)) THEN
            ZDP(JL, JK) = PAPM1(JL, JK) - PAPM1(JL, JK - 1)
            PRHO(JL, JK) = 2.0_JPRB*PAPHM1(JL, JK - 1)*ZCONS1/(PTM1(JL, JK) + PTM1(JL, JK - 1))
            PSTAB(JL, JK) = 2.0_JPRB*ZCONS2/(PTM1(JL, JK) + PTM1(JL, JK - 1))*&
             & (1.0_JPRB - physical%rcpd*PRHO(JL, JK)*(PTM1(JL, JK) - PTM1(JL, JK - 1))/ZDP(JL,&
             & JK))
            PSTAB(JL, JK) = MAX(PSTAB(JL, JK), GSSEC)
            ZSQST(JL, JK) = SQRT(PSTAB(JL, JK))
          END IF
        END DO
      END DO

!*         2.2     MEAN BRUNT-VAISALA FREQUENCY
!                  AND DENSITY FOR WAVE STRESS

      DO JK = ILEVH, KLEV
        DO JL = KIDIA, KFDIA
          IF (LDGWD(JL)) THEN
            IF (JK >= (IKNUB(JL) + 1) .AND. JK <= IKNUL(JL)) THEN
              ZST = ZCONS2/PTM1(JL, JK)*(1.0_JPRB - physical%rcpd*PRHO(JL, JK)*&
               & (PTM1(JL, JK) - PTM1(JL, JK - 1))/ZDP(JL, JK))
              PSTAB(JL, KLEV + 1) = PSTAB(JL, KLEV + 1) + ZST*ZDP(JL, JK)
              PSTAB(JL, KLEV + 1) = MAX(PSTAB(JL, KLEV + 1), GSSEC)
              PRHO(JL, KLEV + 1) = PRHO(JL, KLEV + 1) + PAPHM1(JL, JK - 1)*2.0_JPRB*ZDP(JL,&
               & JK)&
               & *ZCONS1/(PTM1(JL, JK) + PTM1(JL, JK - 1))
            END IF
          END IF
        END DO
      END DO

      DO JL = KIDIA, KFDIA
        IF (LDGWD(JL)) THEN
          PSTAB(JL, KLEV + 1) = PSTAB(JL, KLEV + 1)/(PAPM1(JL, IKNUL(JL)) - PAPM1(JL, IKNUB(JL)))
          PRHO(JL, KLEV + 1) = PRHO(JL, KLEV + 1)/(PAPM1(JL, IKNUL(JL)) - PAPM1(JL, IKNUB(JL)))
        END IF
      END DO

!********************************************************************

!*     DEFINE LOW LEVEL FLOW FOR WAVE STRESS
!      -------------------------------------

      DO JK = KLEV, ILEVH, -1
        DO JL = KIDIA, KFDIA
          IF (LDGWD(JL)) THEN
            IF (JK >= IKNUB(JL) .AND. JK <= IKNUL(JL)) THEN
              PULOW(JL) = PULOW(JL) + PUM1(JL, JK)*(PAPHM1(JL, JK) - PAPHM1(JL, JK - 1))
              PVLOW(JL) = PVLOW(JL) + PVM1(JL, JK)*(PAPHM1(JL, JK) - PAPHM1(JL, JK - 1))
            END IF
          END IF
        END DO
      END DO
      DO JL = KIDIA, KFDIA
        IF (LDGWD(JL)) THEN
          PULOW(JL) = PULOW(JL)/(PAPHM1(JL, IKNUL(JL)) - PAPHM1(JL, IKNUB(JL) - 1))
          PVLOW(JL) = PVLOW(JL)/(PAPHM1(JL, IKNUL(JL)) - PAPHM1(JL, IKNUB(JL) - 1))
          ZNORM(JL) = MAX(SQRT(PULOW(JL)**2 + PVLOW(JL)**2), GVSEC)
          PVPH(JL, KLEV + 1) = ZNORM(JL)
        END IF
      END DO

!*******  SETUP OROGRAPHY AXES AND DEFINE PLANE OF PROFILES  *******

      DO JL = KIDIA, KFDIA
        IF (LDGWD(JL)) THEN
          LLO = (PULOW(JL) < GVSEC) .AND. (PULOW(JL) >= -GVSEC)
          IF (LLO) THEN
            ZU = PULOW(JL) + 2.0_JPRB*GVSEC
          ELSE
            ZU = PULOW(JL)
          END IF
          ZPHI = source_atan(PVLOW(JL)/ZU)
          PPSI(JL, KLEV + 1) = PTHETA(JL) - ZPHI
          ZB(JL) = 1.0_JPRB - 0.18_JPRB*PGAMMA(JL) - 0.04_JPRB*PGAMMA(JL)**2
          ZC(JL) = 0.48_JPRB*PGAMMA(JL) + 0.3_JPRB*PGAMMA(JL)**2
          PD1(JL) = ZB(JL) - (ZB(JL) - ZC(JL))*(source_sine(PPSI(JL, KLEV + 1))**2)
          PD2(JL) = (ZB(JL) - ZC(JL))*source_sine(PPSI(JL, KLEV + 1))*source_cosine(PPSI(JL, KLEV + 1))
          PDMOD(JL) = SQRT(PD1(JL)**2 + PD2(JL)**2)
        END IF
      END DO

!  ************ DEFINE FLOW IN PLANE OF LOWLEVEL STRESS *************

      DO JK = 1, KLEV
        DO JL = KIDIA, KFDIA
          IF (LDGWD(JL)) THEN
            ZVT1 = PULOW(JL)*PUM1(JL, JK) + PVLOW(JL)*PVM1(JL, JK)
            ZVT2 = -PVLOW(JL)*PUM1(JL, JK) + PULOW(JL)*PVM1(JL, JK)
            ZVPF(JL, JK) = (ZVT1*PD1(JL) + ZVT2*PD2(JL))/(ZNORM(JL)*PDMOD(JL))
          END IF

          LL1(JL, JK) = .FALSE.
        END DO
      END DO

      DO JK = 2, KLEV
!DIR$ novector
        DO JL = KIDIA, KFDIA
          IF (LDGWD(JL)) THEN
            ZDP(JL, JK) = PAPM1(JL, JK) - PAPM1(JL, JK - 1)
            PVPH(JL, JK) = ((PAPHM1(JL, JK - 1) - PAPM1(JL, JK - 1))*ZVPF(JL, JK) +&
             & (PAPM1(JL, JK) - PAPHM1(JL, JK - 1))*ZVPF(JL, JK - 1))&
             & /ZDP(JL, JK)
            IF (PVPH(JL, JK) < GVSEC) THEN
              PVPH(JL, JK) = GVSEC
!U            KCRIT(JL)=JK     !BUGFIX
              IF (JK <= IKNUL(JL)) KCRIT(JL) = JK
            END IF
          END IF
        END DO
      END DO
!DIR$ vector

!*         2.3     MEAN FLOW RICHARDSON NUMBER.

      DO JK = 2, KLEV
        DO JL = KIDIA, KFDIA
          IF (LDGWD(JL)) THEN
            ZDWIND = MAX(ABS(ZVPF(JL, JK) - ZVPF(JL, JK - 1)), GVSEC)
            PRI(JL, JK) = PSTAB(JL, JK)*(ZDP(JL, JK)/(physical%rg*PRHO(JL, JK)*ZDWIND))**2
            PRI(JL, JK) = MAX(PRI(JL, JK), GRCRIT)
          END IF
        END DO
      END DO

!*      DEFINE TOP OF BLOCKED LAYER
!       ----------------------------

      DO JK = 2, KLEV - 1
        DO JL = KIDIA, KFDIA

          IF (LDGWD(JL)) THEN

            IF (JK == KKNU2(JL)) THEN

!       first level: integrate half layer only (below full level)
              ZNUM(JL) = PNU(JL)
              ZWIND = (PULOW(JL)*PUM1(JL, JK) + PVLOW(JL)*PVM1(JL, JK))/&
               & MAX(SQRT(PULOW(JL)**2 + PVLOW(JL)**2), GVSEC)
              ZWIND = MAX(ABS(ZWIND), GVSEC)
              ZDELP = PAPHM1(JL, JK) - PAPM1(JL, JK)
              ZSTABP = ZSQST(JL, JK + 1)
              ZRHOP = PRHO(JL, JK + 1)
              PNU(JL) = PNU(JL) + (ZDELP/physical%rg)*&
               & (ZSTABP/ZRHOP)/ZWIND
              IF ((ZNUM(JL) <= GFRCRIT) .AND. (PNU(JL) > GFRCRIT)&
               & .AND. (KKENVH(JL) == KLEV))&
               & KKENVH(JL) = JK

            ELSEIF (JK > KKNU2(JL)) THEN

!       first level: integrate full layer (half above, half below full level)
              ZNUM(JL) = PNU(JL)
              ZWIND = (PULOW(JL)*PUM1(JL, JK) + PVLOW(JL)*PVM1(JL, JK))/&
               & MAX(SQRT(PULOW(JL)**2 + PVLOW(JL)**2), GVSEC)
              ZWIND = MAX(ABS(ZWIND), GVSEC)
              ZDELP = PAPHM1(JL, JK) - PAPHM1(JL, JK - 1)
              ZSTABM = ZSQST(JL, JK)
              ZSTABP = ZSQST(JL, JK + 1)
              ZRHOM = PRHO(JL, JK)
              ZRHOP = PRHO(JL, JK + 1)
              PNU(JL) = PNU(JL) + (ZDELP/physical%rg)*&
               & ((ZSTABP/ZRHOP + ZSTABM/ZRHOM)/2.0_JPRB)/ZWIND
              IF ((ZNUM(JL) <= GFRCRIT) .AND. (PNU(JL) > GFRCRIT)&
               & .AND. (KKENVH(JL) == KLEV))&
               & KKENVH(JL) = JK

            END IF

          END IF
        END DO
      END DO

!  CALCULATION OF A DYNAMICAL MIXING HEIGHT FOR THE BREAKING
!  OF GRAVITY WAVES:

      DO JL = KIDIA, KFDIA
        ZNUP(JL) = 0.0_JPRB
        ZNUM(JL) = 0.0_JPRB
      END DO

      DO JK = KLEV - 1, 2, -1
        DO JL = KIDIA, KFDIA

          IF (LDGWD(JL)) THEN

            IF (JK < KKENVH(JL)) THEN

              ZNUM(JL) = ZNUP(JL)
              ZWIND = (PULOW(JL)*PUM1(JL, JK) + PVLOW(JL)*PVM1(JL, JK))/&
               & MAX(SQRT(PULOW(JL)**2 + PVLOW(JL)**2), GVSEC)
              ZWIND = MAX(ABS(ZWIND), GVSEC)
              ZDELP = PAPHM1(JL, JK) - PAPHM1(JL, JK - 1)
              ZSTABM = ZSQST(JL, JK)
              ZSTABP = ZSQST(JL, JK + 1)
              ZRHOM = PRHO(JL, JK)
              ZRHOP = PRHO(JL, JK + 1)
              ZNUP(JL) = ZNUP(JL) + (ZDELP/physical%rg)*&
               & ((ZSTABP/ZRHOP + ZSTABM/ZRHOM)/2.0_JPRB)/ZWIND
              IF ((ZNUM(JL) <= 1.5_JPRB) .AND. (ZNUP(JL) > 1.5_JPRB)&
               & .AND. (KKCRITH(JL) == KLEV))&
               & KKCRITH(JL) = JK

            END IF

          END IF

        END DO
      END DO

      DO JL = KIDIA, KFDIA
        IF (LDGWD(JL)) THEN
          KKCRITH(JL) = MIN(KKCRITH(JL), KKNU(JL))
        END IF
      END DO

!     DIRECTIONAL INFO FOR FLOW BLOCKING *************************

      DO JK = ILEVH, KLEV
        DO JL = KIDIA, KFDIA
          IF (LDGWD(JL)) THEN
            IF (JK >= KKENVH(JL)) THEN
              LLO = (PUM1(JL, JK) < GVSEC) .AND. (PUM1(JL, JK) >= -GVSEC)
              IF (LLO) THEN
                ZU = PUM1(JL, JK) + 2.0_JPRB*GVSEC
              ELSE
                ZU = PUM1(JL, JK)
              END IF
              ZPHI = source_atan(PVM1(JL, JK)/ZU)
              PPSI(JL, JK) = PTHETA(JL) - ZPHI
            END IF
          END IF
        END DO
      END DO
!      FORMS THE VERTICAL 'LEAKINESS' **************************

      DO JK = ILEVH, KLEV
        DO JL = KIDIA, KFDIA
          IF (LDGWD(JL)) THEN
            IF (JK >= KKENVH(JL)) THEN
              ZGGEENV = MAX(1.0_JPRB,&
                   & (PGEOM1(JL, KKENVH(JL)) + PGEOM1(JL, KKENVH(JL) - 1))/2.0_JPRB)
              ZGGEOM1 = MAX(PGEOM1(JL, JK), 1.0_JPRB)
              ZGVAR = MAX(PHSTD(JL)*physical%rg, 1.0_JPRB)
              PZDEP(JL, JK) = SQRT((ZGGEENV - ZGGEOM1)/(ZGGEOM1 + ZGVAR))
            END IF
          END IF
        END DO
      END DO

    END ASSOCIATE
    status = 0
  END SUBROUTINE GWSETUP

end module
