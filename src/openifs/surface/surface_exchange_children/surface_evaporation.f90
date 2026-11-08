!> Native VEVAP calculation from the frozen source dependencies.
!! Numerical arrays use FP64 in SI units; the original comments name each field.
!! Readonly records are borrowed. Returned arrays are INOUT to retain inactive cells.
!! Status0 means success; status2 refuses shape or unsupported source controls.
!! The caller establishes the frozen IEEE environment and nonoverlapping owners.
module forecast_surface_evaporation
  use iso_fortran_env, only: int32, int64, real64
  use forecast_surface_scalar_math
  use yos_cst, only: tcst
  use yos_veg, only: tveg
  use yos_soil, only: tsoil
  use yos_urb, only: turb
  use yos_ags, only: tags
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  implicit none
  private
  integer, parameter :: jpim = int32, jprb = real64, jprd = real64
  public :: vevap
contains
subroutine vevap(ydthermal,KIDIA,KFDIA,KLON,PTMST,KTILE,PWLMX,PTMLEV,PQMLEV,PAPHMS,PTSKM1M,PTSAM1M,PQS,PCFQ,PWETB,PWETL,PWETLU,PWETH,PWETHS,YDCST,YDVEG,YDURB,PCPTS,PCSAT,PCAIR,PCPTSU,PCSATU,PCAIRU,PCSNW,PDHVEGS,status)
    integer(int32), intent(out) :: status
    type(thermal_parameter_record), intent(in) :: ydthermal

    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    REAL(KIND=JPRB), INTENT(IN) :: PTMST
    INTEGER(KIND=JPIM), INTENT(IN) :: KTILE
    REAL(KIND=JPRB), INTENT(IN) :: PWLMX(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTMLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PQMLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PAPHMS(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTSKM1M(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTSAM1M(:)
    REAL(KIND=JPRB), INTENT(IN) :: PQS(:)
    REAL(KIND=JPRB), INTENT(IN) :: PCFQ(:)
    REAL(KIND=JPRB), INTENT(IN) :: PWETB(:)
    REAL(KIND=JPRB), INTENT(IN) :: PWETL(:)
    REAL(KIND=JPRB), INTENT(IN) :: PWETLU(:)
    REAL(KIND=JPRB), INTENT(IN) :: PWETH(:)
    REAL(KIND=JPRB), INTENT(IN) :: PWETHS(:)
    TYPE(TCST), INTENT(IN) :: YDCST
    TYPE(TVEG), INTENT(IN) :: YDVEG
    TYPE(TURB), INTENT(IN) :: YDURB

    REAL(KIND=JPRB), INTENT(INOUT) :: PCPTS(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCSAT(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCAIR(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCPTSU(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCSATU(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCAIRU(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCSNW(:)

    REAL(KIND=JPRB), INTENT(INOUT) :: PDHVEGS(:, :, :)

    INTEGER(KIND=JPIM) :: JL

    REAL(KIND=JPRB) :: ZZWET, ZZWETS, ZRAS, ZEP, ZEMAX, ZRHO, ZZWETU

    status = 2
    if (klon < 1 .or. klon > 4096) return
    if (kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon) return
    if (size(pdhvegs, 1) < klon .or. size(pdhvegs, 2) < 2 .or. size(pdhvegs, 3) < 4) return
    if (ktile == 3) then
      if (ptmst <= 0.0_real64) return
    end if
    if (size(PWLMX, 1) < klon) return
    if (size(PTMLEV, 1) < klon) return
    if (size(PQMLEV, 1) < klon) return
    if (size(PAPHMS, 1) < klon) return
    if (size(PTSKM1M, 1) < klon) return
    if (size(PTSAM1M, 1) < klon) return
    if (size(PQS, 1) < klon) return
    if (size(PCFQ, 1) < klon) return
    if (size(PWETB, 1) < klon) return
    if (size(PWETL, 1) < klon) return
    if (size(PWETLU, 1) < klon) return
    if (size(PWETH, 1) < klon) return
    if (size(PWETHS, 1) < klon) return
    if (size(PCPTS, 1) < klon) return
    if (size(PCSAT, 1) < klon) return
    if (size(PCAIR, 1) < klon) return
    if (size(PCPTSU, 1) < klon) return
    if (size(PCSATU, 1) < klon) return
    if (size(PCAIRU, 1) < klon) return
    if (size(PCSNW, 1) < klon) return
    if (size(PDHVEGS, 1) < klon) return
    ASSOCIATE (RCPD => YDCST%RCPD, RD => YDCST%RD, RETV => YDCST%RETV, RG => YDCST%RG, &
     & RLHAERO => YDVEG%RLHAERO, RLHAEROS => YDVEG%RLHAEROS, RURBRES => YDURB%RURBRES)

      PCSAT(KIDIA:KFDIA) = 1.0_JPRB
      PCSATU(KIDIA:KFDIA) = 1.0_JPRB
      PCAIR(KIDIA:KFDIA) = 1.0_JPRB
      PCAIRU(KIDIA:KFDIA) = 1.0_JPRB

      IF (KTILE == 3) THEN
        DO JL = KIDIA, KFDIA
          ZEP = PCFQ(JL)*(PQMLEV(JL) - PQS(JL))
          ZEMAX = -PWLMX(JL)/PTMST
          IF (ZEP < 0.0_JPRB .AND. ZEMAX < 0.0_JPRB .AND. ZEP < ZEMAX) THEN
            PCAIR(JL) = MIN(1.0_JPRB, ZEMAX/ZEP)
            PCSAT(JL) = PCAIR(JL)
            PCAIRU(JL) = PCAIR(JL)
            PCSATU(JL) = PCSAT(JL)
          END IF
        END DO
      END IF

      IF (KTILE == 4) THEN
        DO JL = KIDIA, KFDIA
          IF (PQMLEV(JL) <= PQS(JL)) THEN
            ZRHO = PAPHMS(JL)/(RD*PTMLEV(JL)*(1.0_JPRB + RETV*PQMLEV(JL)))
            ZZWET = PWETL(JL)/ZRHO
            ZZWETU = PWETLU(JL)/ZRHO
            PCSAT(JL) = 1.0_JPRB/(1.0_JPRB + PCFQ(JL)*ZZWET)
            PCAIR(JL) = 1.0_JPRB/(1.0_JPRB + PCFQ(JL)*ZZWET)
            PCSATU(JL) = 1.0_JPRB/(1.0_JPRB + PCFQ(JL)*ZZWETU)
            PCAIRU(JL) = 1.0_JPRB/(1.0_JPRB + PCFQ(JL)*ZZWETU)

            PDHVEGS(JL, 1, 3) = PWETL(JL)
            PDHVEGS(JL, 1, 4) = ZRHO/PCFQ(JL)

          END IF
        END DO
      END IF

      IF (KTILE == 6) THEN
        DO JL = KIDIA, KFDIA
          IF (PQMLEV(JL) <= PQS(JL)) THEN
            ZRHO = PAPHMS(JL)/(RD*PTMLEV(JL)*(1.0_JPRB + RETV*PQMLEV(JL)))
            ZZWET = PWETH(JL)/ZRHO
            PCSAT(JL) = 1.0_JPRB/(1.0_JPRB + PCFQ(JL)*ZZWET)
            PCAIR(JL) = PCSAT(JL)
            PCAIRU(JL) = PCAIR(JL)
            PCSATU(JL) = PCSAT(JL)

            PDHVEGS(JL, 2, 3) = PWETH(JL)
            PDHVEGS(JL, 2, 4) = ZRHO/PCFQ(JL)
          END IF
        END DO
      END IF

      IF (KTILE == 7) THEN
        PCSNW(KIDIA:KFDIA) = 0.0_JPRB
        DO JL = KIDIA, KFDIA
          IF (PQMLEV(JL) <= PQS(JL)) THEN
            IF (PTSKM1M(JL) > PTSAM1M(JL)) THEN
              ZRAS = 1200._JPRB/RLHAEROS
            ELSE
              ZRAS = 1200._JPRB/RLHAERO
            END IF
            ZRHO = PAPHMS(JL)/(RD*PTMLEV(JL)*(1.0_JPRB + RETV*PQMLEV(JL)))
            ZZWET = PWETHS(JL)/ZRHO
            ZZWETS = ZRAS/ZRHO
            PCSAT(JL) = 1.0_JPRB/(1.0_JPRB + ZZWET*PCFQ(JL) + ZZWET/ZZWETS)
            PCAIR(JL) = PCSAT(JL)
            IF (PWETHS(JL) > 1.0_JPRB) &
             & PCSNW(JL) = 1.0_JPRB/(1.0_JPRB + ZZWETS*PCFQ(JL) + ZZWETS/ZZWET)
            PCAIRU(JL) = PCAIR(JL)
            PCSATU(JL) = PCSAT(JL)
          END IF
        END DO
      END IF

      IF (KTILE == 8) THEN
        DO JL = KIDIA, KFDIA
          IF (PQMLEV(JL) <= PQS(JL)) THEN
            ZRHO = PAPHMS(JL)/(RD*PTMLEV(JL)*(1.0_JPRB + RETV*PQMLEV(JL)))
            ZZWET = PWETB(JL)/ZRHO
            PCSAT(JL) = 1.0_JPRB/(1.0_JPRB + PCFQ(JL)*ZZWET)
            PCAIR(JL) = PCSAT(JL)
            PCAIRU(JL) = PCAIR(JL)
            PCSATU(JL) = PCSAT(JL)
          END IF
        END DO
      END IF

      IF (KTILE == 10) THEN
        DO JL = KIDIA, KFDIA
          IF (PQMLEV(JL) <= PQS(JL)) THEN
            ZRHO = PAPHMS(JL)/(RD*PTMLEV(JL)*(1.0_JPRB + RETV*PQMLEV(JL)))
            ZZWET = PWETB(JL)/ZRHO
            PCSAT(JL) = 1.0_JPRB/(1.0_JPRB + PCFQ(JL)*ZZWET)
            PCAIR(JL) = PCSAT(JL)
            PCAIRU(JL) = PCAIR(JL)
            PCSATU(JL) = PCSAT(JL)
          END IF
        END DO
      END IF

      DO JL = KIDIA, KFDIA
        PCPTS(JL) = PTSKM1M(JL)*RCPD*(1.0_JPRB + ydthermal%rvtmp2*&
         & (PCSAT(JL)*PQS(JL) + (1.0_JPRB - PCAIR(JL))*PQMLEV(JL)))
        PCPTSU(JL) = PTSKM1M(JL)*RCPD*(1.0_JPRB + ydthermal%rvtmp2*&
         & (PCSATU(JL)*PQS(JL) + (1.0_JPRB - PCAIRU(JL))*PQMLEV(JL)))
      END DO

    END ASSOCIATE
    status = 0
  end subroutine vevap
end module forecast_surface_evaporation
