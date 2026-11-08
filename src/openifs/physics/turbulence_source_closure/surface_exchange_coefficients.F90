!> Complete scalar surface transfer with explicit produced thermal/stability records.
!! Temperatures use K, pressures Pa, wind m/s and roughness m. Coefficients
!! use kg/m2/s; returned scalar transfer velocities use m/s. Arrays are native
!! real64 vectors. Only active columns change. No original global is read.
!! The caller supplies finite admitted fields, actual produced records, nearest
!! rounding and gradual underflow. Vector-MASS is outside this scalar route.
MODULE forecast_native_surface_exchange
  USE iso_c_binding, ONLY: c_double
  implicit none
  private
  public :: vexcs
  interface
    function source_log(x) bind(C, name="log") result(y)
      import :: c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function source_exp(x) bind(C, name="exp") result(y)
      import :: c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function source_atan(x) bind(C, name="atan") result(y)
      import :: c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function source_pow(x, p) bind(C, name="pow") result(y)
      import :: c_double
      real(c_double), value :: x, p
      real(c_double) :: y
    end function
  end interface
CONTAINS

  SUBROUTINE VEXCS(thermal, stability, KIDIA, KFDIA, KLON, KITT, K_VMASS, LDINIT,&
   & PUMLEV, PVMLEV, PTMLEV, PQMLEV, PAPHMS, PGEOMLEV, PCPTGZLEV,&
   & PCPTS, PQSAM, PZ0MM, PZ0HM, PZ0QM, PZDL, PBUOM, PUCURR, PVCURR, PI10FGCV,&
   & YDCST, YDEXC,&
   & PCFM, PCFH, PCFQ, PKH, PKC, status)

    USE PARKIND1, ONLY: JPIM, JPRB, JPRD
    USE owned_ecmwf_thermal_state_port, ONLY: thermal_parameter_record, stability_parameter_record
    USE YOS_CST, ONLY: TCST
    USE YOS_EXC, ONLY: TEXC

! (C) Copyright 1990- ECMWF.
!
! This software is licensed under the terms of the Apache Licence Version 2.0
! which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
! In applying this licence, ECMWF does not waive the privileges and immunities
! granted to it by virtue of its status as an intergovernmental organisation
! nor does it submit to any jurisdiction.

!     ------------------------------------------------------------------

!**   *VEXCS* - DETERMINES THE EXCHANGE COEFFICIENTS BETWEEN THE
!                 SURFACE AND THE LOWEST MODEL LEVEL WITH HELP OF
!                 STABILITY AS FUNCTION OF OBUKHOV-L.

!     Original A.C.M. BELJAARS       E.C.M.W.F.    26/03/90.
!     Modified A.C.M. BELJAARS   26/03/99 Tiling of the land surface.
!     Modified J. HAGUE          13/01/03 MASS Vector Functions
!     Modified   P. Viterbo ECMWF 12/05/2005 Externalize SURF
!                                   (based on vdfexcs)
!     Modified A. Beljaars       30/10/2013 Change scaling of transfer coeff.
!     Modified A. Beljaars       02/02/2017 Introduction of tracer transfer coeff.

!     PURPOSE
!     -------

!     DETERMINE EXCHANGE COEFFICIENTS BETWEEN THE SURFACE AND THE
!     LOWEST MODEL LEVEL

!     INTERFACE
!     ---------

!     *VEXCS* IS CALLED BY *SURFEXCDRIVER*

!     INPUT PARAMETERS (INTEGER):

!     *KIDIA*        START POINT
!     *KFDIA*        END POINT
!     *KLON*         NUMBER OF GRID POINTS PER PACKET
!     *KITT*         NUMBER OF ITERATIONS (BACK SUBST. IS ALWAYS DONE) [#]
!     *K_VMASS*      Controls the use of vector functions in the IBM scientific
!                     library. Set K_VMASS=0 to use standard functions

!     INPUT PARAMETER (LOGICAL):

!     *LDINIT*       IF .T. : ROUTINE GENERATES ITS OWN INITIAL GUESS  [#]
!                    IF .F. : ROUTINE STARTS WITH PZDL  AS INITIAL GUESS

!     INPUT PARAMETERS (REAL):

!     *PUMLEV*      X-VELOCITY COMPONENT AT T-1, lowest model level
!     *PVMLEV*      Y-VELOCITY COMPONENT AT T-1, lowest model level
!     *PTMLEV*      TEMPERATURE AT T-1, lowest model level
!     *PQMLEV*      SPECIFIC HUMUDITY AT T-1, lowest model level
!     *PAPHMS*      PRESSURE AT T-1, surface
!     *PGEOMLEV*    GEOPOTENTIAL AT T-1, lowest model level
!     *PCPTGZLEV*    DRY STATIC ENERGY, LOWEST MODEL LEVEL
!     *PCPTS*        DRY STATIC ENERGY AT THE SURFACE
!     *PQSAM*        SPECIFIC HUMIDITY AT THE SURFACE
!     *PZ0MM*        AERODYNAMIC ROUGHNESS LENGTH
!     *PZ0HM*        ROUGHNESS LENGTH FOR TEMPERATURE
!     *PZ0QM*        ROUGHNESS LENGTH FOR MOISTURE
!     *PZDL*         ZNLEV DEVIDED BY OBUKHOV LENGTH                 [#]
!     *PBUOM*        BUOYANCE FLUX AT THE SURFACE
!     *PUCURR*       OCEAN CURRENT X-COMPONENT
!     *PVCURR*       OCEAN CURRENT Y-COMPONENT
!     *PI10FGCV*     CONVECTIVE GUST VELOCITY

!     OUTPUT PARAMETERS (REAL):

!     *PCFM*         Scaled Transfer Coeff. momentum Rho*Cm*U      [kgm-2s-1]
!     *PCFH*         Scaled Transfer Coeff. heat     Rho*Ch*U      [kgm-2s-1]
!     *PCFQ*         Scaled Transfer Coeff. moisture Rho*Cq*U      [kgm-2s-1]
!     *PKH*          Scaled Transfer Coeff. heat         Ch*U      [m/s]
!     *PKC*          Scaled Transfer Coeff. tracer       Cc*U      [m/s]
!                    (for tracers, the coefficient describes the transfer
!                     between the lowest model level and the roughness length
!                     for momentum, so it does not include the quasi-laminar
!                     resistance)

!     REMARK: [#] UNUSED PARAMETERS IN TANGENT LINEAR AND ADJOINT VERSIONS
!     ------

!     METHOD
!     ------

!     THE ALGEBRAIC RELATION BETWEEN Z/L AND THE RICHARDSON NUMBER
!     IS SOLVED ITERATIVELY. THE STABILITY FUNCTIONS ARE THE SO-CALLED
!     PROFILE PSI-FUNCTIONS.
!     THE INITIAL GUESS (E.G. FROM PREVIOUS TIMESTEP) IS BACK-
!     SUBSTITUTED TO OBTAIN A SECOND APPROXIMATION. FURTHER ITERATION
!     IS DONE BY LINEAR INTER(EXTRA)POLATION (NEWTON'S  METHOD WITH
!     THE DERIVATIVE FROM SUCCESSIVE APPROXIMATIONS). IF NO INITIAL
!     GUESS IS PROVIDED, THE ROUTINE CAN PRODUCE ITS OWN. IN THE LATTER
!     CASE LDINIT=.T. HAS TO BE SPECIFIED AND IT IS RECOMMENDED TO
!     CHOOSE KITT=3. WITH INITIAL GUESSES FROM THE PREVIOUS TIME STEP
!     0 OR 1 ITERATION SHOULD BE SUFFICIENT.

!     ------------------------------------------------------------------

    IMPLICIT NONE
    TYPE(thermal_parameter_record), INTENT(IN) :: thermal
    TYPE(stability_parameter_record), INTENT(IN) :: stability
    INTEGER(KIND=JPIM), INTENT(OUT) :: status
    INTEGER, PARAMETER :: JPRITBL = 101

    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KITT
    INTEGER(KIND=JPIM), INTENT(IN) :: K_VMASS
    LOGICAL, INTENT(IN) :: LDINIT
    REAL(KIND=JPRB), INTENT(IN) :: PUMLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PVMLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTMLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PQMLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PAPHMS(:)
    REAL(KIND=JPRB), INTENT(IN) :: PGEOMLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PCPTGZLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PCPTS(:)
    REAL(KIND=JPRB), INTENT(IN) :: PQSAM(:)
    REAL(KIND=JPRB), INTENT(IN) :: PZ0MM(:)
    REAL(KIND=JPRB), INTENT(IN) :: PZ0HM(:)
    REAL(KIND=JPRB), INTENT(IN) :: PZ0QM(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PZDL(:)
    REAL(KIND=JPRB), INTENT(IN) :: PBUOM(:)
    REAL(KIND=JPRB), INTENT(IN) :: PUCURR(:)
    REAL(KIND=JPRB), INTENT(IN) :: PVCURR(:)
    REAL(KIND=JPRB), INTENT(IN) :: PI10FGCV(:)
    TYPE(TCST), INTENT(IN) :: YDCST
    TYPE(TEXC), INTENT(IN) :: YDEXC
    REAL(KIND=JPRB), INTENT(INOUT) :: PCFM(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCFH(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCFQ(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PKH(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PKC(:)
!*            LOCAL STORAGE
!             ----- -------
    INTEGER(KIND=JPIM) :: JLEN

    REAL(KIND=JPRB) :: Z1DZ0M(KLON + MAX(K_VMASS, 0)), Z1DZ0H(KLON + MAX(K_VMASS, 0)),&
     & Z1DZ0Q(KLON + MAX(K_VMASS, 0)), ZXLNM(KLON + MAX(K_VMASS, 0)),&
     & Z1DZ0MD(KLON + MAX(K_VMASS, 0)), Z1DZ0HD(KLON + MAX(K_VMASS, 0)), Z1DZ0QD(KLON + MAX(K_VMASS, 0)),&
     & ZXLNH(KLON + MAX(K_VMASS, 0)), ZXLNQ(KLON + MAX(K_VMASS, 0)),&
     & ZF2(KLON), ZF3(KLON), ZDU2(KLON + MAX(K_VMASS, 0)),&
     & ZNLEV(KLON),&
     & Z1DZ1D(KLON + MAX(K_VMASS, 0)), ZRICLS(KLON + MAX(K_VMASS, 0)), ZETA2(KLON), ZETA3(KLON)
    REAL(KIND=JPRD) :: ZDUMMY
    REAL(KIND=JPRB) :: ZTMP1(KFDIA - KIDIA + 1 + MAX(K_VMASS, 0))
    REAL(KIND=JPRB) :: ZTMP2(KFDIA - KIDIA + 1 + MAX(K_VMASS, 0))
    REAL(KIND=JPRB) :: ZTMP3(KFDIA - KIDIA + 1 + MAX(K_VMASS, 0))
    REAL(KIND=JPRB) :: ZTMP4(KFDIA - KIDIA + 1 + MAX(K_VMASS, 0))

    INTEGER(KIND=JPIM) :: IRIB, JIT, JL

    REAL(KIND=JPRB) :: ZA, ZAUX1, ZAUX2, ZB, ZCDNH,&
     & ZCDNM, ZCDNQ, ZCH, ZCM, ZCON1, ZCON2, ZCON3,&
     & ZCQ, ZDRORO, ZETA, ZETA1, ZHU, ZIPBL, &
     & ZL, ZPRH, ZPRH0, ZPRH1, ZPRM, ZPRM0, ZPRM1, &
     & ZPRQ, ZPRQ0, ZRIB1, ZRHO, ZUABS, ZWST2, &
     & ZX2, ZPRC0, ZPRC

!             INCLUDE STABILITY FUNCTIONS
!             ------- --------- ---------

! (C) Copyright 1990- ECMWF.
!
! This software is licensed under the terms of the Apache Licence Version 2.0
! which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
! In applying this licence, ECMWF does not waive the privileges and immunities
! granted to it by virtue of its status as an intergovernmental organisation
! nor does it submit to any jurisdiction.

!     ------------------------------------------------------------------

!     *FCVDFS** CONTAINS STATEMENT FUNCTIONS DESCRIBING STAB. FUNCT.

!     A.C.M. BELJAARS    E.C.M.W.F.      26/03/90.

!     ------------------------------------------------------------------

!          *THE STABILITY FUNCTIONS ARE THE SO-CALLED *PHI* AND
!     *PSI*-FUNCTIONS. THE *PSI*-FUNCTIONS GIVE THE STABILITY
!     CORRECTIONS IN THE LOGARITHMIC PROFILES FOR
!     WIND, DRY STATIC ENERGY AND SPECIFIC HUMIDITY. THE FUNCTIONS
!     DEPEND ON THE RATIO OF HEIGHT AND *OBUKHOV LENGTH (*ETA*).
!          FOR THE UNSTABLE BOUNDARY LAYER, THE *DYER AND *HICKS
!     FORMULATIONS ARE USED (CF. *DYER, 1974; *HOGSTROM, 1988). IN
!     STABLE SITUATIONS, THE EMPIRICAL FORMS, PROPOSED BY *HOLTSLAG
!     AND *DEBRUIN ARE USED WITH A MODIFICATION TO SATISFY A CRITICAL
!     FLUX-*RICHARDSON NUMBER FOR LARGE *ETA*.
!          THE *PHI* AND *PSI* FUNCTIONS ARE INTERRELATED. THE *PSI*
!     FUNCTIONS CAN BE DERIVED FROM THE *PHI* FUNCTIONS BY INTEGRATION
!     OF (1.-PHI)/ETA OR *PHI* FROM *PSI* BY COMPUTING
!     (1.-ETA*DPSI/DETA) (SEE ALSO *HAUGEN, 1973; WORKSHOP ON
!     MICROMETEOROLOGY, P. 77).

!     ------------------------------------------------------------------

!        *PHI AND *PSI FUNCTIONS FOR UNSTABLE SITUATIONS ACCORDING
!        TO *DYER AND *HICKS
!        3/2/03 Modification, J.Hague  X**1.5 -> X*SQRT(X)

    REAL(KIND=JPRB) :: PHIHU, PHIMU
    REAL(KIND=JPRB) :: PETA
    PHIHU(PETA) = 1.0_JPRB/SQRT(1.0_JPRB - stability%RCDHALF*PETA)
    PHIMU(PETA) = 1.0_JPRB/SQRT(SQRT(1.0_JPRB - stability%RCDHALF*PETA))

    REAL(KIND=JPRD) :: PSIHU, PSIMU
    REAL(KIND=JPRD) :: DPETA

    PSIHU(DPETA) = 2.0_JPRD*source_log((1.0_JPRD + SQRT(1.0_JPRD - stability%RCDHALF*DPETA))*0.5_JPRD)
    PSIMU(DPETA) = source_log((1.0_JPRD + SQRT(SQRT(1.0_JPRD - stability%RCDHALF*DPETA)))**2 &
                      &*(1.0_JPRD + SQRT(1.0_JPRD - stability%RCDHALF*DPETA))*0.125_JPRD)&
                      &- 2.0_JPRD*source_atan(SQRT(SQRT(1.0_JPRD - stability%RCDHALF*DPETA)))&
                      &+ stability%RCDHPI2

!        *PHI AND *PSI FUNCTIONS FOR UNSTABLE SITUATIONS ACCORDING
!        TO HOGSTROM FOR MOMENTUM AND DERIVED FROM THE ELLISON AND
!        TURNER RELATION FOR THE RATIO OF PHIM AMD PHIH.

    REAL(KIND=JPRB) :: PHIMS, PHIHS
    PHIMS(PETA) = 1.0_JPRB + stability%RCHETA*PETA
    PHIHS(PETA) = (1.0_JPRB + stability%RCHETB*PETA)**2

!     PSI FUNCTIONS NOT COMPATIBLE WITH PHI FUNCTIONS IN THE STABLE CASE

    REAL(KIND=JPRD) :: PSIHS, PSIMS
!PSIHS(DPETA)= -stability%RCHBB*(DPETA-stability%RCHBCD)*source_exp(-stability%RCHBD*DPETA)&
!               &-(_ONE_+stability%RCHB23A*DPETA)**1.5_JPRD - stability%RCHBBCD + _ONE_
    PSIHS(DPETA) = -stability%RCHBB*(DPETA - stability%RCHBCD)*source_exp(-stability%RCHBD*DPETA)&
                  &- (1.0_JPRD + stability%RCHB23A*DPETA)*SQRT(1.0_JPRD + stability%RCHB23A*DPETA) - stability%RCHBBCD + 1.0_JPRD
    PSIMS(DPETA) = -stability%RCHBB*(DPETA - stability%RCHBCD)*source_exp(-stability%RCHBD*DPETA)&
                   &- stability%RCHBA*DPETA - stability%RCHBBCD

!     ------------------------------------------------------------------

!*       1.   INITIALIZE CONSTANTS
!             ---------- ----------

    status = 2
    if (klon < 1 .or. klon > 4096 .or. kidia < 1 .or. kidia > klon + 1 .or. kfdia < kidia - 1 .or. kfdia > klon) return
    if (k_vmass > 0 .or. kitt < 0 .or. kitt > 64) return
    if (min(size(pumlev), size(pvmlev), size(ptmlev), size(pqmlev), size(paphms), size(pgeomlev), size(pcptgzlev)) < klon) return
if(min(size(pcpts),size(pqsam),size(pz0mm),size(pz0hm),size(pz0qm),size(pzdl),size(pbuom),size(pucurr),size(pvcurr),size(pi10fgcv))<klon)return
    if (min(size(pcfm), size(pcfh), size(pcfq), size(pkh), size(pkc)) < klon) return
    ASSOCIATE (RD => YDCST%RD, RETV => YDCST%RETV, RG => YDCST%RG, &
     & REPDU2 => YDEXC%REPDU2, RKAP => YDEXC%RKAP, RPARZI => YDEXC%RPARZI)

      ZCON1 = thermal%rvtmp2 - RETV
      ZCON2 = 2.0_JPRB/3._JPRB
      ZCON3 = RKAP**2

!     PBL HEIGHT FOR W* - EFFECT

      ZIPBL = RPARZI

!     ------------------------------------------------------------------

!*       2.   COMPUTATION OF BASIC QUANTITIES
!             ----------- -- ----- ----------

      DO JL = KIDIA, KFDIA

!             (W*)**2, WIND SHEAR, RICHARDSON NUMBER,

        IF (PBUOM(JL) <= 0.0_JPRB) THEN
          ZWST2 = 0.0_JPRB
        ELSE
          ZWST2 = source_pow(PBUOM(JL)*ZIPBL, ZCON2)
        END IF
        ZDU2(JL) = MAX(REPDU2, (PUMLEV(JL) - PUCURR(JL))**2&
         & + (PVMLEV(JL) - PVCURR(JL))**2 + ZWST2) !+PI10FGCV(JL)**2)
        ZDRORO = 2.0_JPRB*(PCPTGZLEV(JL) - PCPTS(JL))&
         & /(PCPTGZLEV(JL) + PCPTS(JL) - PGEOMLEV(JL))&
         & - ZCON1*(PQMLEV(JL) - MIN(PQSAM(JL), 0.1_JPRB))
        ZRICLS(JL) = PGEOMLEV(JL)*ZDRORO/ZDU2(JL)

!             COMMON FACTORS IN NEUTRAL FORMULAE AND
!             DRAG COEFFICIENTS.

        ZNLEV(JL) = PGEOMLEV(JL)/RG + PZ0MM(JL)
        Z1DZ0M(JL) = ZNLEV(JL)/PZ0MM(JL)
        Z1DZ0H(JL) = ZNLEV(JL)/PZ0HM(JL)
        Z1DZ0Q(JL) = ZNLEV(JL)/PZ0QM(JL)
        Z1DZ1D(JL) = Z1DZ0M(JL)/(Z1DZ0M(JL) - 1.0_JPRB)
        ZXLNM(JL) = source_log(Z1DZ0M(JL))
        ZXLNH(JL) = source_log(Z1DZ0H(JL))
        ZXLNQ(JL) = source_log(Z1DZ0Q(JL))
      END DO

!*       3. EXCHANGE COEFFIENTS DEPENDING UPON MONIN-OBUKHOV LENGTH
!           -------- ---------- --------- ---- ------------- ------

!           SOLVE Z/L ITERATIVELY
!           ----- --- -----------
      DO JL = KIDIA, KFDIA
        Z1DZ0MD(JL) = 1.0_JPRB/Z1DZ0M(JL)
        Z1DZ0HD(JL) = 1.0_JPRB/Z1DZ0H(JL)
      END DO

!        3.1  FIRST AND SECOND GUESS TO INITIALIZE
!             ----- --- ------ ----- -- ----------

      IF (LDINIT) THEN
        DO JL = KIDIA, KFDIA

!             FIRST GUESS: INTERPLOLATE ETA-TABLE FOR POS. RI
!             -----------

          IF (ZRICLS(JL) > 0.0_JPRB) THEN
            ZRIB1 = ZRICLS(JL)*ZXLNM(JL)/ZXLNH(JL)
            IRIB = INT(ZRIB1/stability%DRITBL) + 1
            IF (IRIB >= JPRITBL) THEN
              ZETA1 = stability%RITBL(JPRITBL)
            ELSE
              ZX2 = IRIB*stability%DRITBL
              ZA = (ZX2 - ZRIB1)/stability%DRITBL
              ZB = 1.0_JPRB - ZA
              ZETA1 = ZA*stability%RITBL(IRIB) + ZB*stability%RITBL(IRIB + 1)
            END IF
          ELSE
            ZETA1 = ZRICLS(JL)*ZXLNM(JL)/ZXLNH(JL)
          END IF

!             SECOND GUESS: WITH LOGARITHMIC TERMS
!             ------ -----

          ZETA2(JL) = ZETA1*ZXLNM(JL)*Z1DZ1D(JL)

        END DO
      ELSE
        DO JL = KIDIA, KFDIA
          ZETA2(JL) = PZDL(JL)
        END DO
      END IF

!        3.2  BACK SUBSTITUTION
!             ---- ------------

      DO JL = KIDIA, KFDIA
        IF (ZETA2(JL) > 0.0_JPRB) THEN
          ZDUMMY = ZETA2(JL)
          ZPRH1 = PSIHS(ZDUMMY)
          ZDUMMY = ZETA2(JL)*Z1DZ0HD(JL)
          ZPRH0 = PSIHS(ZDUMMY)
          ZDUMMY = ZETA2(JL)
          ZPRM1 = PSIMS(ZDUMMY)
          ZDUMMY = ZETA2(JL)*Z1DZ0MD(JL)
          ZPRM0 = PSIMS(ZDUMMY)
        ELSE
          ZDUMMY = ZETA2(JL)
          ZPRH1 = PSIHU(ZDUMMY)
          ZDUMMY = ZETA2(JL)*Z1DZ0HD(JL)
          ZPRH0 = PSIHU(ZDUMMY)
          ZDUMMY = ZETA2(JL)
          ZPRM1 = PSIMU(ZDUMMY)
          ZDUMMY = ZETA2(JL)*Z1DZ0MD(JL)
          ZPRM0 = PSIMU(ZDUMMY)
        END IF
        ZPRH = ZXLNH(JL) - ZPRH1 + ZPRH0
        ZPRM = ZXLNM(JL) - ZPRM1 + ZPRM0
        ZHU = ZPRM**2*Z1DZ1D(JL)/ZPRH
        ZETA3(JL) = ZRICLS(JL)*ZHU
        ZF2(JL) = ZRICLS(JL) - ZETA2(JL)/ZHU
      END DO

!        3.3  ITERATE KITT TIMES
!             ------- ---- -----

      DO JIT = 1, KITT
        DO JL = KIDIA, KFDIA
          IF (ZETA3(JL) > 0.0_JPRB) THEN
            ZDUMMY = ZETA3(JL)
            ZPRH1 = PSIHS(ZDUMMY)
            ZDUMMY = ZETA3(JL)*Z1DZ0HD(JL)
            ZPRH0 = PSIHS(ZDUMMY)
            ZDUMMY = ZETA3(JL)
            ZPRM1 = PSIMS(ZDUMMY)
            ZDUMMY = ZETA3(JL)*Z1DZ0MD(JL)
            ZPRM0 = PSIMS(ZDUMMY)
          ELSE
            ZDUMMY = ZETA3(JL)
            ZPRH1 = PSIHU(ZDUMMY)
            ZDUMMY = ZETA3(JL)*Z1DZ0HD(JL)
            ZPRH0 = PSIHU(ZDUMMY)
            ZDUMMY = ZETA3(JL)
            ZPRM1 = PSIMU(ZDUMMY)
            ZDUMMY = ZETA3(JL)*Z1DZ0MD(JL)
            ZPRM0 = PSIMU(ZDUMMY)
          END IF
          ZPRH = ZXLNH(JL) - ZPRH1 + ZPRH0
          ZPRM = ZXLNM(JL) - ZPRM1 + ZPRM0
          ZF3(JL) = ZRICLS(JL) - ZETA3(JL)*ZPRH/(Z1DZ1D(JL)*ZPRM**2)
          IF (ABS(ZF3(JL) - ZF2(JL)) > 1.E-25_JPRB) THEN
            ZETA = ZETA2(JL) - ZF2(JL)*(ZETA3(JL) - ZETA2(JL))/(ZF3(JL) - ZF2(JL))
          ELSE
            ZETA = ZETA3(JL)
          END IF

!             SAFETY PROVISION FOR DIVERGING ITERATIONS

          IF (ZETA*ZETA3(JL) < 0.0_JPRB) ZETA = ZETA3(JL)*0.5_JPRB
          ZETA2(JL) = ZETA3(JL)
          ZF2(JL) = ZF3(JL)
          ZETA3(JL) = ZETA
        END DO
      END DO

!        3.4  COPY ZNLEV/L TO OUTPUT ARRAY
!             ---- ------- -- ------ -----

      DO JL = KIDIA, KFDIA
        PZDL(JL) = ZETA3(JL)
      END DO

!        4.   COMPUTE EXCHANGE COEFFICIENTS
!             ------- -------- ------------

      DO JL = KIDIA, KFDIA

!             ASSUME MAXIMUM NOCTURNAL BOUNDARY LAYER HEIGHT
!             EQUAL TO stability%RCHBHDL*L (5 TIMES OBUKHOV LENGTH)
!             AND UNIFORM PROFILES FROM H TO ZNLEV

        IF (ZETA3(JL) > stability%RCHBHDL) THEN
          ZL = ZNLEV(JL)/ZETA3(JL)
          ZNLEV(JL) = stability%RCHBHDL*ZL + MAX(PZ0MM(JL), PZ0QM(JL))
          ZETA3(JL) = ZNLEV(JL)/ZL
          Z1DZ0M(JL) = ZNLEV(JL)/PZ0MM(JL)
          Z1DZ0H(JL) = ZNLEV(JL)/PZ0HM(JL)
          Z1DZ0Q(JL) = ZNLEV(JL)/PZ0QM(JL)
          ZXLNM(JL) = source_log(Z1DZ0M(JL))
          ZXLNH(JL) = source_log(Z1DZ0H(JL))
          ZXLNQ(JL) = source_log(Z1DZ0Q(JL))
        END IF
      END DO
      DO JL = KIDIA, KFDIA
        Z1DZ0MD(JL) = 1.0_JPRB/Z1DZ0M(JL)
        Z1DZ0HD(JL) = 1.0_JPRB/Z1DZ0H(JL)
        Z1DZ0QD(JL) = 1.0_JPRB/Z1DZ0Q(JL)
      END DO

      DO JL = KIDIA, KFDIA
        IF (ZETA3(JL) > 0.0_JPRB) THEN
          ZDUMMY = ZETA3(JL)
          ZPRM1 = PSIMS(ZDUMMY)
          ZDUMMY = ZETA3(JL)*Z1DZ0MD(JL)
          ZPRM0 = PSIMS(ZDUMMY)
          ZDUMMY = ZETA3(JL)
          ZPRH1 = PSIHS(ZDUMMY)
          ZDUMMY = ZETA3(JL)*Z1DZ0HD(JL)
          ZPRH0 = PSIHS(ZDUMMY)
          ZDUMMY = ZETA3(JL)*Z1DZ0QD(JL)
          ZPRQ0 = PSIHS(ZDUMMY)
          ZDUMMY = ZETA3(JL)*Z1DZ0MD(JL)
          ZPRC0 = PSIHS(ZDUMMY)
        ELSE
          ZDUMMY = ZETA3(JL)
          ZPRM1 = PSIMU(ZDUMMY)
          ZDUMMY = ZETA3(JL)*Z1DZ0MD(JL)
          ZPRM0 = PSIMU(ZDUMMY)
          ZDUMMY = ZETA3(JL)
          ZPRH1 = PSIHU(ZDUMMY)
          ZDUMMY = ZETA3(JL)*Z1DZ0HD(JL)
          ZPRH0 = PSIHU(ZDUMMY)
          ZDUMMY = ZETA3(JL)*Z1DZ0QD(JL)
          ZPRQ0 = PSIHU(ZDUMMY)
          ZDUMMY = ZETA3(JL)*Z1DZ0MD(JL)
          ZPRC0 = PSIHU(ZDUMMY)
        END IF
        ZPRM = ZXLNM(JL) - ZPRM1 + ZPRM0
        ZPRH = ZXLNH(JL) - ZPRH1 + ZPRH0
        ZPRQ = ZXLNQ(JL) - ZPRH1 + ZPRQ0
        ZPRC = ZXLNM(JL) - ZPRH1 + ZPRC0
        ZRHO = PAPHMS(JL)/(RD*PTMLEV(JL)*(1.0_JPRB + RETV*PQMLEV(JL)))
        ZUABS = SQRT(ZDU2(JL))
        ZAUX2 = ZUABS*ZRHO*ZCON3
        PCFM(JL) = ZAUX2/(ZPRM**2)
        PCFH(JL) = ZAUX2/(ZPRM*ZPRH)
        PCFQ(JL) = ZAUX2/(ZPRM*ZPRQ)
        PKH(JL) = PCFH(JL)/ZRHO
        PKC(JL) = ZUABS*ZCON3/(ZPRM*ZPRC)

      END DO

    END ASSOCIATE
    status = 0
  END SUBROUTINE VEXCS

END MODULE forecast_native_surface_exchange
