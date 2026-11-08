!> Complete mountain-wave drag with native setup and stress-profile children.
!! Pressure uses Pa, wind m/s, temperature K, geopotential m2/s2 and height m.
!! The three output coefficient fields and shape ratio retain inactive bytes.
!! The canonical physical/linear/gravity records are readonly. The complete
!! finite physical and derived-index domain is retained from gwdrag.md.
module md2asm_mountain_wave_drag
  use iso_c_binding, only: c_double
  use md2asm_mountain_wave_setup, only: gwsetup
  use md2asm_gravity_wave_stress_profile, only: gwprofil
  implicit none
  private
  public :: gwdrag
  interface
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
  ! TENDENCY COEFFICIENTS (OUTPUT)
  SUBROUTINE GWDRAG(physical, YDEPHLI, YDEGWD, KIDIA, KFDIA, KLON, KLEV,&
   & PAPHM1, PAPM1, PGEOM1,&
   & PTM1, PUM1, PVM1,&
   & PHSTD, PGAMMA, PTHETA, PSIG,&
   & PSOTEU, PSOTEV, PSOBETA, status)

!**** *GWDRAG* - DOES THE GRAVITY WAVE PARAMETRIZATION.

!     PURPOSE.
!     --------

!          COMPUTES THE COEFFICIENTS FOR COMPUTATION OF THE
!          PHYSICAL TENDENCIES OF THE PROGNOSTIC VARIABLES U,V  AND T DUE TO
!          VERTICAL TRANSPORTS BY SUBGRIDSCALE OROGRAPHICALLY EXCITED GRAVITY WAVES
!          THE TENDENCIES AND OTHER DIAGNOSTIC QUANTITIES ARE THEN COMPUTER
!          IN CALLPAR.

!          NOTE THAT THE VERTICAL INDEXING OF PAPHM1 IS FROM 0:KLEV TO MAKE IT
!          COMPATIBLE WITH CALLPAR

!**   INTERFACE.
!     ----------
!          CALLED FROM *CALLPAR*.

!          THE ROUTINE TAKES ITS INPUT FROM THE LONG-TERM STORAGE:
!          U,V,T AND P AT T-1.

!        EXPLICIT ARGUMENTS :
!        --------------------
!     ==== INPUTS ===

!        *KIDIA*       START POINT
!        *KFDIA*       END POINT
!        *KLON*        NUMBER OF GRID POINTS PER PACKET
!        *KLEV*        NUMBER OF VERTICAL LEVELS
!        *KGL1*        ROW NUMBER FOR PRINTINGS  (UNSUED)
!        *PHSTD*       STANDARD DEVIATION OF THE SUBGRID SCALE OROGRAPHY
!        *PTHETA*      GEOGRAPHICAL ORIENTATION
!                      OF THE SUBGRID SCALE OROGRAPHY
!        *PGAMMA*      ANISOTROPY OF THE SUBGRID SCALE OROGRAPHY
!        *PSIG*        MEAN SLOPE OF THE SUBGRID SCALE OROGRAPHY
!        *PAPHM1*      PRESSURE AT HALF LEVELS AT T-1
!        *PAPM1*       PRESSURE AT FULL LEVELS AT T-1
!        *PGEOM1*      GEOPOTENTIAL AT T-1
!        *PTM1*        TEMPERATURE AT T-1
!        *PUM1*        X-VELOCITY COMPONENT AT T-1
!        *PVM1*        Y-VELOCITY COMPONENT AT T-1

!     ==== OUTPUTS ===

!        *PSOTEU*     EXPLICIT TENDENCY COEFFICIENT OF U-COMP OF WIND
!        *PSOTEV*     EXPLICIT TENDENCY COEFFICIENT OF V-COMP OF WIND
!        *PSOBETA*    IMPLICIT TENDENCY COEFFICIENT OF U,V-COMP OF WIND
!        *LLGWD*      TRUE IF PHSTD > 50 (IE GWDRAG SCHEME ACTIVE)

!        IMPLICIT ARGUMENTS :   NONE
!        --------------------

!     METHOD.
!     -------
!         THE SCHEME CONSISTS OF THREE PARTS,THE CALCULATION OF LOWLEVEL
!         DRAG DUE TO WAKE EFFECTS OF THE SUBGRID OROGRAPHY,THE GRAVITY
!         WAVE STRESS AND THE STRESS PROFILE IN THE VERTICAL.
!         THE STRESS IS COMPUTED USING A LOW-LEVEL WIND,STATIC STABILITY
!         AND  SUBGRID OROGRAPHIC PARAMETERS.THESE ARE THE STANDARD
!         DEVIATION OF THE HEIGHT,THE ANGLE RELATIVE TO EAST, THE
!         ANISOTROPY,AND THE SLOPE.
!         A WAV RICHARDSON NUMBER IS COMPUTED AT EACH LEVEL AND BY
!         REQUIRING THAT ITS VALUE IS NEVER LESS THAN A CRITICAL ONE
!         A VALUE OF STRESS IS DETERMINED AT EACH MODEL LEVEL.
!         THE CRITICAL FROUDE NUMBER OF THE FLOW DETERMINES THE DEPTH OF
!         THE LOWLEVEL DRAG.

!     EXTERNALS.
!     ----------

!     REFERENCE.
!     ----------
!         SEE MODEL DOCUMENTATION

!        SEE ECMWF RESEARCH DEPARTMENT DOCUMENTATION OF THE "I.F.S."

!     AUTHOR.
!     -------
!      M.MILLER + B.RITTER   E.C.M.W.F.     15/06/86.

!     MODIFICATIONS.
!     --------------
!      D.Salmond  15-Oct-01 FULLIMP mods
!      M.Hamrud   01-Oct-2003 CY28 Cleaning
!      A.Brown    17-Aug-2004 Introduction of cutoff moutain
!      A. Orr     01-Nov-2005 Subgrid oro and vdf integrated together
!      P.Bechtold 14-Jan-2009 move IKTOP computation to setup routine
!-----------------------------------------------------------------------

    USE PARKIND1, ONLY: JPIM, JPRB

    USE YOEGWD, ONLY: TEGWD
    USE YOEPHLI, ONLY: TEPHLI

    USE physical_constant_setup_port, ONLY: forecast_physical_constants
    IMPLICIT NONE
    TYPE(forecast_physical_constants), INTENT(IN) :: physical
    INTEGER(KIND=JPIM), INTENT(OUT) :: status

    TYPE(TEGWD), INTENT(IN) :: YDEGWD
    TYPE(TEPHLI), INTENT(IN) :: YDEPHLI
    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEV
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    REAL(KIND=JPRB), INTENT(IN) :: PAPHM1(KLON, 0:KLEV) !note callpar indexing convention
    REAL(KIND=JPRB), INTENT(IN) :: PAPM1(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PGEOM1(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PTM1(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PUM1(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PVM1(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PHSTD(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PGAMMA(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PTHETA(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PSIG(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PSOTEU(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(INOUT) :: PSOTEV(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(INOUT) :: PSOBETA(KLON, KLEV)

!-----------------------------------------------------------------------

    INTEGER(KIND=JPIM) ::  &
     & ICRIT(KLON),&
     & IKCRITH(KLON),&
     & IKENVH(KLON),&
     & IKNU(KLON),&
     & IKNU2(KLON)

    REAL(KIND=JPRB) :: ZTAU(KLON, KLEV + 1),&
     & ZSTAB(KLON, KLEV + 1),&
     & ZVPH(KLON, KLEV + 1),&
     & ZRHO(KLON, KLEV + 1),&
     & ZRI(KLON, KLEV + 1),&
     & ZPSI(KLON, KLEV + 1),&
     & ZZDEP(KLON, KLEV)
    REAL(KIND=JPRB) :: ZULOW(KLON),&
     & ZVLOW(KLON),&
     & ZNU(KLON),&
     & ZD1(KLON),&
     & ZD2(KLON),&
     & ZDMOD(KLON)

    INTEGER(KIND=JPIM) :: ILEVP1, ILONS, JK, JL, IKTOP

    REAL(KIND=JPRB) :: ZABSV, ZB, ZBLOCK, ZC, ZCONB,&
     & ZCS, ZDELP, ZDELP0, ZEFF, ZKDRAG, &
     & ZRATIO, ZSS, ZSTD, ZTEMP, ZZD1

    LOGICAL :: LLGWD(KLON)

!*************************************************************

!     ------------------------------------------------------------------

!*         1.    INITIALIZATION
!                --------------

    ASSOCIATE (GKDRAG => YDEGWD%GKDRAG, GKWAKE => YDEGWD%GKWAKE, GRFPLM => YDEGWD%GRFPLM, &
     & GTENLIM => YDEGWD%GTENLIM, NGWDLIM => YDEGWD%NGWDLIM, NGWDTOP => YDEGWD%NGWDTOP, &
     & LPHYLIN => YDEPHLI%LPHYLIN, RLPDRAG => YDEPHLI%RLPDRAG)
      status = 2
      IF (KLON < 1 .OR. KLON > 4096 .OR. KLEV < 6 .OR. KLEV > 512) RETURN
      IF (KIDIA < 1 .OR. KIDIA > KLON + 1 .OR. KFDIA < KIDIA - 1 .OR. KFDIA > KLON) RETURN
      IF (NGWDTOP < 1 .OR. NGWDTOP > KLEV .OR. NGWDLIM < 0 .OR. NGWDLIM > KLEV + 1) RETURN
      IF (physical%initialized /= 1) RETURN
      ILONS = KFDIA - KIDIA + 1
!     ------------------------------------------------------------------

!       SELECT POINTS FOR SCHEME TO OPERATE(SGS OROG >50METRES)  ****

      DO JL = KIDIA, KFDIA
        IF (PHSTD(JL) > 50._JPRB) THEN
          LLGWD(JL) = .TRUE.
        ELSE
          LLGWD(JL) = .FALSE.
        END IF
      END DO

!       Constant for surface stress

      IF (LPHYLIN) THEN
        ZKDRAG = RLPDRAG
      ELSE
        ZKDRAG = GKDRAG
      END IF

!     ------------------------------------------------------------------

!*         2.     PRECOMPUTE BASIC STATE VARIABLES.
!*                ---------- ----- ----- ----------

      CALL GWSETUP &
       & (physical, YDEGWD, KIDIA, KFDIA, KLON, KLEV, LLGWD,&
       & IKCRITH, ICRIT,&
       & IKENVH, IKNU, IKNU2,&
       & PAPHM1, PAPM1, PUM1, PVM1, PTM1, PGEOM1, PHSTD,&
       & ZRHO, ZRI, ZSTAB, ZTAU, ZVPH, ZPSI, ZZDEP,&
       & ZULOW, ZVLOW,&
       & PTHETA, PGAMMA, ZNU, ZD1, ZD2, ZDMOD, status)
      IF (status /= 0) RETURN

!***********************************************************

!*         3.      COMPUTE THE SURFACE GRAVITY WAVE STRESS
!                  ---------------------------------------

      ZBLOCK = 0.0_JPRB

      DO JL = KIDIA, KFDIA
        IF (LLGWD(JL)) THEN

          ZBLOCK = (PGEOM1(JL, IKENVH(JL))/physical%rg)
          ZSTD = PHSTD(JL)
          ZEFF = MAX(0.0_JPRB, 3._JPRB*ZSTD - ZBLOCK)*2.0_JPRB
          ZTAU(JL, KLEV + 1) = ZKDRAG*ZRHO(JL, KLEV + 1)*PSIG(JL)*ZEFF**2 &
           &/9._JPRB/ZSTD*ZVPH(JL, KLEV + 1)*ZDMOD(JL)*SQRT(ZSTAB(JL, KLEV + 1))

        ELSE
          ZTAU(JL, KLEV + 1) = 0.0_JPRB
        END IF

      END DO

!*         4.      COMPUTE GRAVITY WAVE STRESS PROFILE.
!*                 -----------------------------------

      CALL GWPROFIL &
       & (YDEPHLI, YDEGWD, KIDIA, KFDIA, KLON, KLEV,&
       & LLGWD,&
       & IKCRITH, ICRIT, IKENVH, IKNU,&
       & IKNU2, PAPHM1, ZRHO, ZSTAB, ZVPH,&
       & ZRI, ZTAU, ZDMOD, PSIG, PHSTD, status)
      IF (status /= 0) RETURN

!*         5.      COMPUTE TENDENCY COEFFICIENTS.
!*                 -----------------------------

      DO JK = 1, KLEV
        DO JL = KIDIA, KFDIA
          PSOTEU(JL, JK) = 0.0_JPRB
          PSOTEV(JL, JK) = 0.0_JPRB
          PSOBETA(JL, JK) = 0.0_JPRB
        END DO
      END DO

      ILEVP1 = KLEV + 1

      IKTOP = NGWDTOP

      DO JK = 1, KLEV
!OCL  VCT(CEX)
        DO JL = KIDIA, KFDIA
          IF (LLGWD(JL)) THEN
!      COMPUTE EXPLICIT COEFFICENTS FOR GRAVITY WAVE PORTION
!      INITIALLY SET IMPLICIT BLOCKING COEFFICENTS TO ZERO

            ZDELP = PAPHM1(JL, JK) - PAPHM1(JL, JK - 1)
! adjust in pressure < 0.1hPa
            IF (PAPM1(JL, JK) < GRFPLM) THEN
              ZDELP0 = PAPHM1(JL, IKTOP) - PAPHM1(JL, 0)
              ZTEMP = -physical%rg*(ZTAU(JL, IKTOP + 1) - ZTAU(JL, 1))*ZDELP/ &
               &        (ZVPH(JL, ILEVP1)*ZDELP0**2)
            ELSE
              ZTEMP = -physical%rg*(ZTAU(JL, JK + 1) - ZTAU(JL, JK))/(ZDELP*ZVPH(JL, ILEVP1))
            END IF
            PSOTEU(JL, JK) = (ZULOW(JL)*ZD1(JL) - ZVLOW(JL)*ZD2(JL))*ZTEMP/ZDMOD(JL)
            PSOTEV(JL, JK) = (ZVLOW(JL)*ZD1(JL) + ZULOW(JL)*ZD2(JL))*ZTEMP/ZDMOD(JL)
            PSOBETA(JL, JK) = 0.0_JPRB

!      LIMIT THE WIND TENDENCIES IN THE STRATOSPHERE (probably not necessary now ?)
            IF (JK < NGWDLIM) THEN
              PSOTEU(JL, JK) = SIGN(MIN(ABS(PSOTEU(JL, JK)), GTENLIM), PSOTEU(JL, JK))
              PSOTEV(JL, JK) = SIGN(MIN(ABS(PSOTEV(JL, JK)), GTENLIM), PSOTEV(JL, JK))
            END IF

!     FOR BLOCKING LEVELS RECALCULATE THE IMPLICIT COEFFICIENTS
!     AND SET EXPLICIT GRAVITY WAVE COEFFICIENTS TO ZERO
            IF (JK >= IKENVH(JL)) THEN
              ZB = 1.0_JPRB - 0.18_JPRB*PGAMMA(JL) - 0.04_JPRB*PGAMMA(JL)**2
              ZC = 0.48_JPRB*PGAMMA(JL) + 0.3_JPRB*PGAMMA(JL)**2
              ZCS = source_cosine(ZPSI(JL, JK))**2
              ZSS = 1.0_JPRB - ZCS
              ZCONB = GKWAKE*PSIG(JL)/(2.0_JPRB*PHSTD(JL)) !  ZCONB INDEPENDENT OF ZTMST
              ZABSV = 0.5_JPRB*SQRT(PUM1(JL, JK)**2 + PVM1(JL, JK)**2)
              ZZD1 = ZB*ZCS + ZC*ZSS
              ZRATIO = SQRT((ZCS + PGAMMA(JL)**2*ZSS)/(PGAMMA(JL)**2*ZCS + ZSS))
              PSOBETA(JL, JK) = MAX(0.0_JPRB, 2.0_JPRB - 1.0_JPRB/ZRATIO)*ZCONB*ZZDEP(JL, JK)*ZZD1*ZABSV
              PSOTEU(JL, JK) = 0.0_JPRB
              PSOTEV(JL, JK) = 0.0_JPRB
            END IF

          END IF
        END DO
      END DO
    END ASSOCIATE
    status = 0
  END SUBROUTINE GWDRAG

end module
