!> Native VUPDZ0 complete eight/nine-tile roughness calculation.
!! Surface types and stability constants are borrowed readonly native records.
!! FP64 arrays retain the original column-first shapes and inactive values.
!! All original arguments retain their order after the stability record.
!! Status0 is success and status2 refuses shape or unsupported urban tiles.
module forecast_surface_roughness
  use iso_fortran_env, only: int32, real64
  use forecast_surface_scalar_math
  use forecast_neutral_ocean_roughness, only: pz0wn
  use owned_ecmwf_thermal_state_port, only: stability_parameter_record
  use yos_cst, only: tcst
  use yos_exc, only: texc
  use yos_veg, only: tveg
  use yos_flake, only: tflake
  use yos_urb, only: turb
  implicit none
  private
  integer, parameter :: jpim = int32, jprb = real64, jprd = real64
  public :: vupdz0
contains
subroutine vupdz0(ydstability,KIDIA,KFDIA,KLON,KTILES,KSTEP,CDCONF,KTVL,KTVH,PCVL,PCVH,PCUR,PUMLEV,PVMLEV,PTMLEV,PQMLEV,PAPHMS,PGEOMLEV,PDSN,PUSTRTI,PVSTRTI,PAHFSTI,PEVAPTI,PHLICE,PTSKTI,PCHAR,PCHARHQ,PFRTI,PUCURR,PVCURR,YDCST,YDEXC,YDVEG,YDFLAKE,YDURB,PZ0MTI,PZ0HTI,PZ0QTI,PBUOMTI,PZDLTI,PRAQTI,status)
    type(stability_parameter_record), intent(in) :: ydstability
    integer(int32), intent(out) :: status

    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KTILES
    INTEGER(KIND=JPIM), INTENT(IN) :: KSTEP

    CHARACTER(LEN=1), INTENT(IN), OPTIONAL :: CDCONF

    INTEGER(KIND=JPIM), INTENT(IN) :: KTVL(KLON)
    INTEGER(KIND=JPIM), INTENT(IN) :: KTVH(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PCVL(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PCVH(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PCUR(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PHLICE(:)
    REAL(KIND=JPRB), INTENT(IN) :: PUMLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PVMLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTMLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PQMLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PAPHMS(:)
    REAL(KIND=JPRB), INTENT(IN) :: PGEOMLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PDSN(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PUSTRTI(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PVSTRTI(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PAHFSTI(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PEVAPTI(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PTSKTI(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PCHAR(:)
    REAL(KIND=JPRB), INTENT(IN) :: PCHARHQ(:)
    REAL(KIND=JPRB), INTENT(IN), OPTIONAL :: PUCURR(:)
    REAL(KIND=JPRB), INTENT(IN), OPTIONAL :: PVCURR(:)
    REAL(KIND=JPRB), INTENT(IN) :: PFRTI(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PZ0MTI(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PZ0HTI(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PZ0QTI(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PBUOMTI(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PZDLTI(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PRAQTI(:, :)
    TYPE(TCST), INTENT(IN) :: YDCST
    TYPE(TEXC), INTENT(IN) :: YDEXC
    TYPE(TVEG), INTENT(IN) :: YDVEG
    TYPE(TFLAKE), INTENT(IN) :: YDFLAKE
    TYPE(TURB), INTENT(IN) :: YDURB

    INTEGER(KIND=JPIM) :: JL, JTILE

    REAL(KIND=JPRB) :: Z1DZ0Q, ZCON2, ZIPBL, ZNLEV, ZPRH1,&
     & ZPRQ, ZPRQ0, ZROWQ, ZROWT, &
     & ZWST2, &
     & ZXLNQ, ZZCDN, ZCDFC
    REAL(KIND=JPRB) :: Z0M, Z0H, Z0Q, Z0WHQ
    REAL(KIND=JPRB) :: Z0W(KLON), USTM1(KLON)
    REAL(KIND=JPRB) :: ZUST(KLON, KTILES), ZUST2(KLON, KTILES)
    REAL(KIND=JPRB) :: ZDUA(KLON), ZDU2(KLON), ZRHO(KLON), ZSNWGHT(KLON), ZMLOW, ZHLOW

    REAL(KIND=JPRB) :: ZLICE(KLON), ZLWAT(KLON)
    REAL(KIND=JPRD) :: ZDUMMY
    REAL(KIND=JPRB) :: ZURBF

    LOGICAL :: LLCURR, LLINIT

    status = 2
    if (klon < 1 .or. klon > 512 .or. ktiles < 8 .or. ktiles > 9) return
    if (kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon) return
    if (ydflake%leflake .and. ktiles /= 9) return
    if (present(pucurr) .and. present(pvcurr)) then
      if (size(pucurr, 1) /= klon .or. size(pvcurr, 1) /= klon) return
    end if
    if (.not. allocated(ydveg%rvz0m) .or. .not. allocated(ydveg%rvz0h)) return
    if (lbound(ydveg%rvz0m, 1) > 0 .or. ubound(ydveg%rvz0m, 1) < 20) return
    if (lbound(ydveg%rvz0h, 1) > 0 .or. ubound(ydveg%rvz0h, 1) < 20) return
    if (any(ktvl(kidia:kfdia) < 0) .or. any(ktvl(kidia:kfdia) > 20)) return
    if (any(ktvh(kidia:kfdia) < 0) .or. any(ktvh(kidia:kfdia) > 20)) return
    if (size(PHLICE, 1) /= klon) return
    if (size(PUMLEV, 1) /= klon) return
    if (size(PVMLEV, 1) /= klon) return
    if (size(PTMLEV, 1) /= klon) return
    if (size(PQMLEV, 1) /= klon) return
    if (size(PAPHMS, 1) /= klon) return
    if (size(PGEOMLEV, 1) /= klon) return
    if (size(PDSN, 1) /= klon) return
    if (size(PUSTRTI, 1) /= klon) return
    if (size(PUSTRTI, 2) /= ktiles) return
    if (size(PVSTRTI, 1) /= klon) return
    if (size(PVSTRTI, 2) /= ktiles) return
    if (size(PAHFSTI, 1) /= klon) return
    if (size(PAHFSTI, 2) /= ktiles) return
    if (size(PEVAPTI, 1) /= klon) return
    if (size(PEVAPTI, 2) /= ktiles) return
    if (size(PTSKTI, 1) /= klon) return
    if (size(PTSKTI, 2) /= ktiles) return
    if (size(PCHAR, 1) /= klon) return
    if (ydexc%lwcou2w .and. ydexc%lwcouhmf) then
      if (size(PCHARHQ, 1) /= klon) return
    end if

    if (size(PFRTI, 1) /= klon) return
    if (size(PFRTI, 2) /= ktiles) return
    if (size(PZ0MTI, 1) /= klon) return
    if (size(PZ0MTI, 2) /= ktiles) return
    if (size(PZ0HTI, 1) /= klon) return
    if (size(PZ0HTI, 2) /= ktiles) return
    if (size(PZ0QTI, 1) /= klon) return
    if (size(PZ0QTI, 2) /= ktiles) return
    if (size(PBUOMTI, 1) /= klon) return
    if (size(PBUOMTI, 2) /= ktiles) return
    if (size(PZDLTI, 1) /= klon) return
    if (size(PZDLTI, 2) /= ktiles) return
    if (size(PRAQTI, 1) /= klon) return
    if (size(PRAQTI, 2) /= ktiles) return
    ASSOCIATE (RCPD => YDCST%RCPD, RD => YDCST%RD, RETV => YDCST%RETV, RG => YDCST%RG, &
     & LROUGH => YDEXC%LROUGH, LSCMEC => YDEXC%LSCMEC, REPDU2 => YDEXC%REPDU2, &
     & REPUST => YDEXC%REPUST, REXTZ0H => YDEXC%REXTZ0H, REXTZ0M => YDEXC%REXTZ0M, &
     & RKAP => YDEXC%RKAP, RNUH => YDEXC%RNUH, RNUM => YDEXC%RNUM, RNUQ => YDEXC%RNUQ, &
     & RPARZI => YDEXC%RPARZI, RZ0ICE => YDEXC%RZ0ICE, &
     & LEFLAKE => YDFLAKE%LEFLAKE, RH_ICE_MIN_FLK => YDFLAKE%RH_ICE_MIN_FLK, &
     & LWCOU2W => YDEXC%LWCOU2W, LWCOUHMF => YDEXC%LWCOUHMF, &
     & RVZ0H => YDVEG%RVZ0H, RVZ0M => YDVEG%RVZ0M, &
     & RURBZTM => YDURB%RURBZTM, RURBZTH => YDURB%RURBZTH)

      IF (KTILES .LT. 8) THEN
        STOP "Wrong number of tiles in VDFUPDZ0"
      END IF
      IF (LEFLAKE .OR. KTILES .GT. 8) THEN
        DO JL = KIDIA, KFDIA
          IF (PHLICE(JL) > RH_ICE_MIN_FLK) THEN
            ZLICE(JL) = 1._JPRB
            ZLWAT(JL) = 0._JPRB
          ELSE
            ZLICE(JL) = 0._JPRB
            ZLWAT(JL) = 1._JPRB
          END IF
        END DO
      END IF

      ZURBF = 0._JPRB

      ZCON2 = 2.0_JPRB/3._JPRB

      ZIPBL = RPARZI

      IF (PRESENT(PUCURR) .AND. PRESENT(PVCURR)) THEN
        LLCURR = .TRUE.
      ELSE
        LLCURR = .FALSE.
      END IF

      LLINIT = (KSTEP == 0)

      DO JL = KIDIA, KFDIA
        ZRHO(JL) = PAPHMS(JL)/(RD*PTMLEV(JL)*(1.0_JPRB + RETV*PQMLEV(JL)))
        IF (LLCURR) THEN
          ZDU2(JL) = MAX(REPDU2, (PUMLEV(JL) - PUCURR(JL))**2 +&
           & (PVMLEV(JL) - PVCURR(JL))**2)
        ELSE
          ZDU2(JL) = MAX(REPDU2, PUMLEV(JL)**2 + PVMLEV(JL)**2)
        END IF
        ZSNWGHT(JL) = MIN(MAX(PDSN(JL), 0.0_JPRB)/0.25_JPRB, 1.0_JPRB)
        ZDUA(JL) = SQRT(ZDU2(JL))
      END DO
      IF (LLINIT) THEN
        DO JL = KIDIA, KFDIA
          ZDUA(JL) = SQRT(ZDU2(JL))
          PZ0MTI(JL, 1) = PZ0WN(ZDUA(JL), PGEOMLEV(JL), PCHAR(JL), RG, RNUM, RKAP)
          PZ0MTI(JL, 2) = PZ0ICE(RZ0ICE, PFRTI(JL, 2))
          PZ0MTI(JL, 3) = PCVL(JL)*RVZ0M(KTVL(JL)) + PCVH(JL)*RVZ0M(KTVH(JL))&
            & + (1.-PCVL(JL) - PCVH(JL))*RVZ0M(0)
          PZ0MTI(JL, 4) = RVZ0M(KTVL(JL))
          ZMLOW = PCVL(JL)/(1.0_JPRB - PCVH(JL))*RVZ0M(KTVL(JL)) + (1.0_JPRB - PCVL(JL) - PCVH(JL))/(1.0_JPRB - PCVH(JL))*RVZ0M(0)
          PZ0MTI(JL, 5) = ZSNWGHT(JL)*RVZ0M(12) + (1.0_JPRB - ZSNWGHT(JL))*ZMLOW
          PZ0MTI(JL, 6) = RVZ0M(KTVH(JL))
          PZ0MTI(JL, 7) = RVZ0M(KTVH(JL))
          PZ0MTI(JL, 8) = RVZ0M(0)
          IF (LEFLAKE .OR. KTILES .GT. 8) THEN
            PZ0MTI(JL, 9) = PZ0MTI(JL, 1)*ZLWAT(JL) + PZ0MTI(JL, 2)*ZLICE(JL)
          END IF
          IF (KTILES .GT. 9) THEN
            ZURBF = PCUR(JL)
            IF (ZURBF .GT. 0.0_JPRB) THEN
              PZ0MTI(JL, 3) = PZ0MTI(JL, 3)*(1.0_JPRB - ZURBF) + RURBZTM*ZURBF
              IF (PCVH(JL) + ZURBF .GT. 0.0_JPRB) THEN
                PZ0MTI(JL, 7) = (RVZ0M(KTVH(JL))*PCVH(JL) + RURBZTM*ZURBF)/(PCVH(JL) + ZURBF)
              END IF
            END IF
            PZ0MTI(JL, 10) = RURBZTM
          END IF
        END DO

        DO JTILE = 1, KTILES
          DO JL = KIDIA, KFDIA
            ZZCDN = (RKAP/surface_log(1.0_JPRB + PGEOMLEV(JL)/(RG*PZ0MTI(JL, JTILE))))**2
            PUSTRTI(JL, JTILE) = ZRHO(JL)*PUMLEV(JL)*ZDUA(JL)*ZZCDN
            PVSTRTI(JL, JTILE) = ZRHO(JL)*PVMLEV(JL)*ZDUA(JL)*ZZCDN
            PAHFSTI(JL, JTILE) = 0.0_JPRB
            PEVAPTI(JL, JTILE) = 0.0_JPRB
          END DO
        END DO
      END IF

      ZCDFC = 2.E-3_JPRB
      DO JTILE = 1, KTILES
        DO JL = KIDIA, KFDIA
          ZROWQ = PEVAPTI(JL, JTILE)
          ZROWT = PAHFSTI(JL, JTILE)/RCPD
          PBUOMTI(JL, JTILE) = RG*(-RETV*ZROWQ - ZROWT/PTSKTI(JL, JTILE))/ZRHO(JL)
          ZUST2(JL, JTILE) = SQRT(PUSTRTI(JL, JTILE)**2 + PVSTRTI(JL, JTILE)**2)/ZRHO(JL)

          IF (PBUOMTI(JL, JTILE) > 0.0_JPRB) THEN
            ZWST2 = surface_power((PBUOMTI(JL, JTILE)*ZIPBL), ZCON2)
            ZUST2(JL, JTILE) = ZUST2(JL, JTILE) + ZCDFC*ZWST2
          END IF

          ZUST(JL, JTILE) = MAX(SQRT(ZUST2(JL, JTILE)), REPUST)
          PZDLTI(JL, JTILE) = -PGEOMLEV(JL)*RKAP*PBUOMTI(JL, JTILE)/(RG*ZUST(JL, JTILE)**3)
        END DO
      END DO

      JTILE = 1
      DO JL = KIDIA, KFDIA
        USTM1(JL) = 1.0_JPRB/ZUST(JL, JTILE)
        Z0M = RNUM*USTM1(JL)
        Z0W(JL) = PZ0SEA(RG, PCHAR(JL), ZUST2(JL, JTILE))
        PZ0MTI(JL, JTILE) = Z0M + Z0W(JL)
      END DO

      IF (LWCOU2W .AND. LWCOUHMF) THEN
        DO JL = KIDIA, KFDIA
          Z0WHQ = PZ0SEA(RG, PCHARHQ(JL), ZUST2(JL, JTILE))
          Z0H = RNUH*USTM1(JL)
          PZ0HTI(JL, JTILE) = PZNSEA(Z0WHQ, Z0H, Z0W(JL), ZUST2(JL, JTILE))
          Z0Q = RNUQ*USTM1(JL)
          PZ0QTI(JL, JTILE) = PZNSEA(Z0WHQ, Z0Q, Z0W(JL), ZUST2(JL, JTILE))
        END DO
      ELSE
        DO JL = KIDIA, KFDIA
          PZ0HTI(JL, JTILE) = RNUH*USTM1(JL)
          PZ0QTI(JL, JTILE) = RNUQ*USTM1(JL)
        END DO
      END IF

      JTILE = 2
      DO JL = KIDIA, KFDIA
        PZ0MTI(JL, JTILE) = PZ0ICE(RZ0ICE, PFRTI(JL, JTILE))
        PZ0HTI(JL, JTILE) = RZ0ICE
        PZ0QTI(JL, JTILE) = RZ0ICE
      END DO

      JTILE = 3
      DO JL = KIDIA, KFDIA
        PZ0MTI(JL, JTILE) = PCVL(JL)*RVZ0M(KTVL(JL)) + PCVH(JL)*RVZ0M(KTVH(JL)) + (1.-PCVL(JL) - PCVH(JL))*RVZ0M(0)
        PZ0HTI(JL, JTILE) = PCVL(JL)*RVZ0H(KTVL(JL)) + PCVH(JL)*RVZ0H(KTVH(JL)) + (1.-PCVL(JL) - PCVH(JL))*RVZ0H(0)
        PZ0QTI(JL, JTILE) = PZ0HTI(JL, JTILE)
        IF (KTILES .GT. 9) THEN
          ZURBF = PCUR(JL)
          PZ0MTI(JL, JTILE) = PZ0MTI(JL, JTILE)*(1.0_JPRB - ZURBF) + RURBZTM*ZURBF
          PZ0HTI(JL, JTILE) = PZ0HTI(JL, JTILE)*(1.0_JPRB - ZURBF) + RURBZTH*ZURBF
          PZ0QTI(JL, JTILE) = PZ0QTI(JL, JTILE)*(1.0_JPRB - ZURBF) + RURBZTH*ZURBF
        END IF
      END DO

      JTILE = 4
      DO JL = KIDIA, KFDIA
        PZ0MTI(JL, JTILE) = RVZ0M(KTVL(JL))
        PZ0HTI(JL, JTILE) = RVZ0H(KTVL(JL))
        PZ0QTI(JL, JTILE) = PZ0HTI(JL, JTILE)
      END DO

      JTILE = 5
      DO JL = KIDIA, KFDIA
        ZMLOW = PCVL(JL)/(1.0_JPRB - PCVH(JL))*RVZ0M(KTVL(JL)) + (1.0_JPRB - PCVL(JL) - PCVH(JL))/(1.0_JPRB - PCVH(JL))*RVZ0M(0)
        ZHLOW = PCVL(JL)/(1.0_JPRB - PCVH(JL))*RVZ0H(KTVL(JL)) + (1.0_JPRB - PCVL(JL) - PCVH(JL))/(1.0_JPRB - PCVH(JL))*RVZ0H(0)
        PZ0MTI(JL, JTILE) = ZSNWGHT(JL)*RVZ0M(12) + (1.0_JPRB - ZSNWGHT(JL))*ZMLOW
        PZ0HTI(JL, JTILE) = ZSNWGHT(JL)*RVZ0H(12) + (1.0_JPRB - ZSNWGHT(JL))*ZHLOW
        PZ0QTI(JL, JTILE) = PZ0HTI(JL, JTILE)
      END DO

      JTILE = 6
      DO JL = KIDIA, KFDIA
        PZ0MTI(JL, JTILE) = RVZ0M(KTVH(JL))
        PZ0HTI(JL, JTILE) = RVZ0H(KTVH(JL))
        PZ0QTI(JL, JTILE) = PZ0HTI(JL, JTILE)
      END DO

      JTILE = 7
      DO JL = KIDIA, KFDIA
        PZ0MTI(JL, JTILE) = RVZ0M(KTVH(JL))
        PZ0HTI(JL, JTILE) = RVZ0H(KTVH(JL))
        PZ0QTI(JL, JTILE) = PZ0HTI(JL, JTILE)
        IF (KTILES .GT. 9 .AND. PCVH(JL) + ZURBF .GT. 0.0_JPRB) THEN
          PZ0MTI(JL, JTILE) = (RVZ0M(KTVH(JL))*PCVH(JL) + RURBZTM*ZURBF)/(PCVH(JL) + ZURBF)
          PZ0HTI(JL, JTILE) = (RVZ0H(KTVH(JL))*PCVH(JL) + RURBZTH*ZURBF)/(PCVH(JL) + ZURBF)
          PZ0QTI(JL, JTILE) = PZ0HTI(JL, JTILE)
        END IF
      END DO

      JTILE = 8
      DO JL = KIDIA, KFDIA
        PZ0MTI(JL, JTILE) = RVZ0M(0)
        PZ0HTI(JL, JTILE) = RVZ0H(0)
        PZ0QTI(JL, JTILE) = PZ0HTI(JL, JTILE)
      END DO

      IF (LEFLAKE .OR. KTILES .GT. 8) THEN
        JTILE = 9
        DO JL = KIDIA, KFDIA
          PZ0MTI(JL, JTILE) = PZ0MTI(JL, 1)*ZLWAT(JL) + PZ0MTI(JL, 2)*ZLICE(JL)
          PZ0HTI(JL, JTILE) = PZ0HTI(JL, 1)*ZLWAT(JL) + PZ0HTI(JL, 2)*ZLICE(JL)
          PZ0QTI(JL, JTILE) = PZ0QTI(JL, 1)*ZLWAT(JL) + PZ0QTI(JL, 2)*ZLICE(JL)
        END DO
      END IF
      IF (KTILES .GT. 9) THEN
        JTILE = 10
        DO JL = KIDIA, KFDIA
          PZ0MTI(JL, JTILE) = RURBZTM
          PZ0HTI(JL, JTILE) = RURBZTH
          PZ0QTI(JL, JTILE) = RURBZTH
        END DO
      END IF

      IF (LSCMEC .AND. LROUGH) THEN
        PZ0MTI(:, :) = REXTZ0M
        PZ0HTI(:, :) = REXTZ0H
      END IF

      DO JTILE = 1, KTILES
        DO JL = KIDIA, KFDIA
          ZNLEV = PGEOMLEV(JL)/RG + PZ0MTI(JL, JTILE)
          ZXLNQ = surface_log(ZNLEV/PZ0QTI(JL, JTILE))
          Z1DZ0Q = ZNLEV/PZ0QTI(JL, JTILE)
          IF (PZDLTI(JL, JTILE) > 0.0_JPRB) THEN
            ZDUMMY = PZDLTI(JL, JTILE)
            ZPRH1 = PSIHS(ZDUMMY)
            ZDUMMY = PZDLTI(JL, JTILE)/Z1DZ0Q
            ZPRQ0 = PSIHS(ZDUMMY)
          ELSE
            ZDUMMY = PZDLTI(JL, JTILE)
            ZPRH1 = PSIHU(ZDUMMY)
            ZDUMMY = PZDLTI(JL, JTILE)/Z1DZ0Q
            ZPRQ0 = PSIHU(ZDUMMY)
          END IF
          ZPRQ = ZXLNQ - ZPRH1 + ZPRQ0
          PRAQTI(JL, JTILE) = (ZXLNQ - ZPRH1 + ZPRQ0)/(ZUST(JL, JTILE)*RKAP)
        END DO
      END DO
    END ASSOCIATE
    status = 0
  contains
    real(real64) function psihs(x) result(y)
      real(real64), intent(in) :: x
      y = -ydstability%rchbb*(x - ydstability%rchbcd)*surface_exp(-ydstability%rchbd*x) &
          - (1.0_real64 + ydstability%rchb23a*x)*sqrt(1.0_real64 + ydstability%rchb23a*x) - ydstability%rchbbcd + 1.0_real64
    end function
    real(real64) function psihu(x) result(y)
      real(real64), intent(in) :: x
      y = 2.0_real64*surface_log((1.0_real64 + sqrt(1.0_real64 - ydstability%rcdhalf*x))*0.5_real64)
    end function
    real(real64) function pz0sea(g, ch, ust2) result(y)
      real(real64), intent(in) :: g, ch, ust2
      y = (ch/g)*ust2
    end function
    real(real64) function pz0ice(floor, cover) result(y)
      real(real64), intent(in) :: floor, cover
      y = max(floor, (1.0_real64 - cover)*0.00093_real64 + 0.00605_real64*surface_exp(-17.0_real64*(cover - 0.5_real64)**2))
    end function
    real(real64) function pznsea(wave, viscous, unused_wave, unused_ust2) result(y)
      real(real64), intent(in) :: wave, viscous, unused_wave, unused_ust2
      real(real64) :: plus, minus, first, second
      plus = -(wave + 0.5_real64*viscous) + sqrt(wave**2 + 0.25_real64*viscous**2)
      minus = -(wave + 0.5_real64*viscous) - sqrt(wave**2 + 0.25_real64*viscous**2)
      first = surface_power(abs(plus), (wave + plus)/(plus - minus))
      second = surface_power(abs(minus), (wave + minus)/(minus - plus))
      y = max(first*second, 0.0000001_real64)
    end function

  end subroutine vupdz0
end module
