!> Complete native fixed-control C3/C4 Farquhar leaf and canopy calculation.
!! This body preserves the frozen corrected gross-root C4 reference and
!! the existing C3/dark stages; it does not call that reference library.
!! The original 24 arguments retain their order, followed by INT32 status.
!! Radiation uses W/m2, pressure Pa, temperature K, humidity kg/kg,
!! CO2 kgCO2/kgAir and returned ground-area carbon rates kgCO2/(m2 s).
!! Four output arrays are INOUT so inactive values remain defined.
!! Status0 succeeds,1 reports private allocation failure,2 refuses shape,
!! and3 reports a source-forbidden numerical state. Controls/positive C4
!! capacity and nonoverlapping-owner conditions remain caller preconditions.
module forecast_plant_photosynthesis
  use iso_fortran_env, only: int32, real32, real64
  use forecast_surface_scalar_math
  use forecast_plant_temperature_response, only: arrhenius, arrhenius_fn, arrhenius_modified_fn
  use forecast_plant_physical_roots, only: c4_gross_coefficients, c4_physical_roots
  use yos_ags, only: tags
  use yos_agf, only: tagf
  use yos_cst, only: tcst
  implicit none
  private
  integer, parameter :: jpim = int32, jprb = real64, jprm = real32, jprd = real64
  public :: farquhar
contains
subroutine farquhar(KIDIA,KFDIA,KLON,LDLAND,KVTYPE,KCO2TYP,YDAGS,YDAGF,YDCST,PSRFD,PAPHM,PQS,PQSURF,PQM,PTM,PTSKM,PTSOIL,PF2,PCO2,PLAI,PGSTOT,PGPP,PRD,PAN,status)
    integer(int32), intent(out) :: status
    integer :: allocation_status

    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    LOGICAL, INTENT(IN) :: LDLAND(:)
    INTEGER(KIND=JPIM), INTENT(IN) :: KVTYPE(:)
    INTEGER(KIND=JPIM), INTENT(IN) :: KCO2TYP(:)
    TYPE(TAGS), INTENT(IN) :: YDAGS
    TYPE(TAGF), INTENT(IN) :: YDAGF
    TYPE(TCST), INTENT(IN) :: YDCST
    REAL(KIND=JPRB), INTENT(IN) :: PSRFD(:)
    REAL(KIND=JPRB), INTENT(IN) :: PAPHM(:)
    REAL(KIND=JPRB), INTENT(IN) :: PQS(:)
    REAL(KIND=JPRB), INTENT(IN) :: PQSURF(:)
    REAL(KIND=JPRB), INTENT(IN) :: PQM(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTM(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTSKM(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTSOIL(:)
    REAL(KIND=JPRB), INTENT(IN) :: PCO2(:)
    REAL(KIND=JPRB), INTENT(IN) :: PF2(:)
    REAL(KIND=JPRB), INTENT(IN) :: PLAI(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PGSTOT(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PGPP(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PRD(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PAN(:)

    INTEGER(KIND=JPIM) :: JL
    INTEGER(KIND=JPIM) :: LIMIT_PHOTO, JLEVEL
    INTEGER(KIND=JPIM) :: ILAI(KLON)
    INTEGER(KIND=JPIM) :: KVTYPE_TEMPO(KLON)
    INTEGER(KIND=JPIM) :: NIC, INIC, ICINIC
    INTEGER(KIND=JPIM) :: INDEX_CALC(KLON)
    INTEGER(KIND=JPIM) :: NIA, INIA, NINA
    INTEGER(KIND=JPIM) :: ININA, IAINIA
    INTEGER(KIND=JPIM) :: INDEX_ASSI(KLON)
    INTEGER(KIND=JPIM) :: INDEX_NON_ASSI(KLON)
    INTEGER(KIND=JPIM) :: ZCTYPE(KLON)
    INTEGER(KIND=JPIM), ALLOCATABLE :: INFO_LIMITPHOTO(:, :)

    LOGICAL :: LACCLIMATION, LOSM_ACCLIMATION
    LOGICAL :: LDOWNREGULATION_CO2
    LOGICAL :: LSKIN_TEMP
    LOGICAL :: LASSIMILATE(KLON)
    LOGICAL :: LCALCULATE(KLON)

    REAL(KIND=JPRB) :: ZTEMP_GROWTH(KLON)
    REAL(KIND=JPRB) :: ZPB(KLON)
    REAL(KIND=JPRB) :: ZCO2(KLON)
    REAL(KIND=JPRB) :: ZRVEGET(KLON)
    REAL(KIND=JPRB) :: ZVCMAX25(KLON)
    REAL(KIND=JPRB) :: ZJMAX25(KLON)

    REAL(KIND=JPRB) :: ZGSTOP(KLON)
    REAL(KIND=JPRB) :: ZGAMMA_STAR(KLON)
    REAL(KIND=JPRB) :: ZVPD(KLON)
    REAL(KIND=JPRB) :: ZWATER_LIM(KLON)
    REAL(KIND=JPRB) :: ZASSIMTOT(KLON)
    REAL(KIND=JPRB) :: ZRDTOT(KLON)
    REAL(KIND=JPRB) :: ZLEAF_GS_TOP(KLON)
    REAL(KIND=JPRB) :: ZT_VCMAX
    REAL(KIND=JPRB) :: ZS_VCMAX_ACCLIMTEMP
    REAL(KIND=JPRB) :: ZT_GAMMA_STAR
    REAL(KIND=JPRB) :: ZT_JMAX
    REAL(KIND=JPRB) :: ZS_JMAX_ACCLIMTEMP
    REAL(KIND=JPRB) :: ZT_GM
    REAL(KIND=JPRB) :: ZT_RD
    REAL(KIND=JPRB) :: ZT_KMC
    REAL(KIND=JPRB) :: ZT_KMO
    REAL(KIND=JPRB) :: ZT_SCO
    REAL(KIND=JPRB) :: ZVC(KLON)
    REAL(KIND=JPRB) :: ZVJ(KLON)
    REAL(KIND=JPRB) :: ZGM(KLON)
    REAL(KIND=JPRB) :: ZG0VAR(KLON)
    REAL(KIND=JPRB) :: ZKMC(KLON)
    REAL(KIND=JPRB) :: ZKMO(KLON)
    REAL(KIND=JPRB) :: ZSCO(KLON)
    REAL(KIND=JPRB) :: ZGBCO2(KLON)
    REAL(KIND=JPRB) :: ZGBH2O(KLON)
    REAL(KIND=JPRB) :: ZFVPD(KLON)
    REAL(KIND=JPRB) :: ZLOW_GAMMA_STAR(KLON)
    REAL(KIND=JPRB) :: ZNITRO_VCMAX
    REAL(KIND=JPRB) :: ZIABS(KLON)
    REAL(KIND=JPRB) :: ZJMAX(KLON)
    REAL(KIND=JPRB) :: ZLEAF_TEMP(KLON)

    REAL(KIND=JPRD) :: ZFCYC
    REAL(KIND=JPRD) :: ZZ
    REAL(KIND=JPRD) :: ZRM
    REAL(KIND=JPRD) :: ZCS_STAR
    REAL(KIND=JPRD) :: ZJ2
    REAL(KIND=JPRD) :: ZVPJ2
    REAL(KIND=JPRD) :: ZA_1, ZA_3
    REAL(KIND=JPRD) :: ZA_1_tmp, ZA_3_tmp
    INTEGER(KIND=JPIM) :: IROOT_C4, IRUB_C4, IPEP_C4
    LOGICAL :: LFOUND_C4_ROOT
    REAL(KIND=JPRD) :: ZC4_ROOTS(3), ZC4_GROSS, ZC4_CS, ZC4_GS, ZC4_CI, ZC4_CC, ZC4_OBS
    REAL(KIND=JPRD) :: ZC4_RC, ZC4_RJ, ZC4_VP, ZC4_XJ, ZC4_X2J
    REAL(KIND=JPRD) :: ZC4_SAVED_A, ZC4_SAVED_B, ZC4_SAVED_X1, ZC4_SAVED_X2, ZC4_SAVED_X3
    REAL(KIND=JPRD) :: ZLEAF_CI
    REAL(KIND=JPRD) :: ZCC
    REAL(KIND=JPRD) :: ZOBS
    REAL(KIND=JPRD) :: ZCI_STAR
    REAL(KIND=JPRD) :: ZC4_SAVED_GROSS
    REAL(KIND=JPRD) :: ZC4_COEF(4), ZC4_LOWER, ZC4_UPPER
    INTEGER(KIND=JPIM) :: NROOT_C4
    REAL(KIND=JPRD) :: ZA, ZB, ZC, ZD, ZM, ZF, ZJ, ZG, ZH, ZI, ZL, ZP, ZQ, ZR
    REAL(KIND=JPRD) :: ZQQ, ZUU, ZPSI, ZX1, ZX2, ZX3

    REAL(KIND=JPRB), ALLOCATABLE :: ZVC2(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZVJ2(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZASSIMI(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZGS(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZLAITAB(:)
    REAL(KIND=JPRB), ALLOCATABLE :: ZLIGHT(:)
    REAL(KIND=JPRB), ALLOCATABLE :: ZRD(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZJJ(:, :)

    status = 2
    if (klon < 1 .or. klon > 4096) return
    if (kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon .or. kfdia < kidia - 1) return
    if (ydagf%nlai /= 20 .or. ydagf%nlai1 /= 21 .or. ydagf%npath /= 2) return
    if (size(LDLAND, 1) < klon) return
    if (size(KVTYPE, 1) < klon) return
    if (size(KCO2TYP, 1) < klon) return
    if (size(PSRFD, 1) < klon) return
    if (size(PAPHM, 1) < klon) return
    if (size(PQS, 1) < klon) return
    if (size(PQSURF, 1) < klon) return
    if (size(PQM, 1) < klon) return
    if (size(PTM, 1) < klon) return
    if (size(PTSKM, 1) < klon) return
    if (size(PTSOIL, 1) < klon) return
    if (size(PCO2, 1) < klon) return
    if (size(PF2, 1) < klon) return
    if (size(PLAI, 1) < klon) return
    if (size(PGSTOT, 1) < klon) return
    if (size(PGPP, 1) < klon) return
    if (size(PRD, 1) < klon) return
    if (size(PAN, 1) < klon) return
    if (any(kvtype(kidia:kfdia) < 0) .or. any(kvtype(kidia:kfdia) > 20)) return
    if (.not. allocated(ydagf%rvcmax25)) return
    if (size(ydagf%rvcmax25, 1) /= 20 .or. size(ydagf%rvcmax25, 2) /= 2) return
    if (.not. allocated(ydagf%rhumrel)) return
    if (size(ydagf%rhumrel, 1) /= 20 .or. size(ydagf%rhumrel, 2) /= 2) return
    if (.not. allocated(ydagf%ra1)) return
    if (size(ydagf%ra1, 1) /= 20 .or. size(ydagf%ra1, 2) /= 2) return
    if (.not. allocated(ydagf%rb1)) return
    if (size(ydagf%rb1, 1) /= 20 .or. size(ydagf%rb1, 2) /= 2) return
    if (.not. allocated(ydagf%rg0)) return
    if (size(ydagf%rg0, 1) /= 20 .or. size(ydagf%rg0, 2) /= 2) return
    if (.not. allocated(ydagf%rgm25)) return
    if (size(ydagf%rgm25, 1) /= 20 .or. size(ydagf%rgm25, 2) /= 2) return
    if (.not. allocated(ydagf%re_vcmax)) return
    if (size(ydagf%re_vcmax, 1) /= 20 .or. size(ydagf%re_vcmax, 2) /= 2) return
    if (.not. allocated(ydagf%re_jmax)) return
    if (size(ydagf%re_jmax, 1) /= 20 .or. size(ydagf%re_jmax, 2) /= 2) return
    if (.not. allocated(ydagf%rdownregulation_co2_coef)) return
    if (size(ydagf%rdownregulation_co2_coef, 1) /= 20 .or. size(ydagf%rdownregulation_co2_coef, 2) /= 2) return
    if (.not. allocated(ydagf%rstruct_const)) return
    if (size(ydagf%rstruct_const, 1) /= 20 .or. size(ydagf%rstruct_const, 2) /= 2) return

    ASSOCIATE (NLAI => YDAGF%NLAI, NLAI1 => YDAGF%NLAI1, NPATH => YDAGF%NPATH, &
     & RDOWNREGULATION_CO2_BASELEVEL => YDAGF%RDOWNREGULATION_CO2_BASELEVEL, &
     & RDOWNREGULATION_CO2_MINIMUM => YDAGF%RDOWNREGULATION_CO2_MINIMUM, &
     & RUNDEF_SECHIBA => YDAGF%RUNDEF_SECHIBA, RUNDEF => YDAGF%RUNDEF, NIUNDEF => YDAGF%NIUNDEF,&
     & RONE_MONTH => YDAGF%RONE_MONTH,  &
     & RA1 => YDAGF%RA1, RB1 => YDAGF%RB1, RARJV => YDAGF%RARJV, RBRJV => YDAGF%RBRJV, &
     & RASJ => YDAGF%RASJ, RBSJ => YDAGF%RBSJ, RASV => YDAGF%RASV, RBSV => YDAGF%RBSV, &
     & RD_VCMAX => YDAGF%RD_VCMAX, RD_JMAX => YDAGF%RD_JMAX, RE_GAMMA_STAR => YDAGF%RE_GAMMA_STAR, &
     & RE_GM => YDAGF%RE_GM, RS_GM => YDAGF%RS_GM, RS_JMAX => YDAGF%RS_JMAX,&
     & RD_GM => YDAGF%RD_GM, RE_VCMAX => YDAGF%RE_VCMAX, RE_JMAX => YDAGF%RE_JMAX, RE_KMC => YDAGF%RE_KMC, &
     & RE_KMO => YDAGF%RE_KMO, RE_RD => YDAGF%RE_RD, &
     & RE_SCO => YDAGF%RE_SCO, RG0 => YDAGF%RG0, RGAMMA_STAR25 => YDAGF%RGAMMA_STAR25, RGM25 => YDAGF%RGM25,&
     & RKMC25 => YDAGF%RKMC25, RKMO25 => YDAGF%RKMO25, &
     & RSCO25 => YDAGF%RSCO25, RSTRESS_GM => YDAGF%RSTRESS_GM, RSTRESS_GS => YDAGF%RSTRESS_GS, &
     & RSTRESS_VCMAX => YDAGF%RSTRESS_VCMAX, &
     & RTPHOTO_MAX => YDAGF%RTPHOTO_MAX, RTPHOTO_MIN => YDAGF%RTPHOTO_MIN, RVCMAX25 => YDAGF%RVCMAX25, &
     & RHUMREL => YDAGF%RHUMREL, &
     & RDOWNREGULATION_CO2_COEF => YDAGF%RDOWNREGULATION_CO2_COEF, RSTRUCT_CONST => YDAGF%RSTRUCT_CONST, &
     & RLAI_LEVEL_DEPTH => YDAGF%RLAI_LEVEL_DEPTH, RLAIMAX => YDAGF%RLAIMAX, &
     & REXT_COEFF => YDAGF%REXT_COEFF, RGB_REF => YDAGF%RGB_REF, &
     & RTP_00 => YDAGF%RTP_00, RPB_STD => YDAGF%RPB_STD, RRG_TO_PAR => YDAGF%RRG_TO_PAR, &
     & RW_TO_MOL => YDAGF%RW_TO_MOL, RALPHA_LL => YDAGF%RALPHA_LL, &
     & RTHETA => YDAGF%RTHETA, RFPSIR => YDAGF%RFPSIR, RFQ => YDAGF%RFQ, RFPSEUDO => YDAGF%RFPSEUDO,&
     & RH_PROTONS => YDAGF%RH_PROTONS, RGBS => YDAGF%RGBS, &
     & ROI => YDAGF%ROI, RALPHA => YDAGF%RALPHA, RKP => YDAGF%RKP, RTETENS_1 => YDAGF%RTETENS_1, &
     & RTETENS_2 => YDAGF%RTETENS_2, RREF_TEMP => YDAGF%RREF_TEMP, &
     & RMOL_TO_M_1 => YDAGF%RMOL_TO_M_1, RRATIO_H2O_TO_CO2 => YDAGF%RRATIO_H2O_TO_CO2, &
     & RN_VERT_ATT => YDAGF%RN_VERT_ATT, &
     & RTAU_TEMP_AIR_MONTH => YDAGF%RTAU_TEMP_AIR_MONTH, RPI => YDCST%RPI, &
     & RMAIR => YDAGS%RMAIR, RMCO2 => YDAGS%RMCO2, RRDCF => YDAGS%RRDCF)

      LACCLIMATION = .TRUE.
      LOSM_ACCLIMATION = .FALSE.
      LDOWNREGULATION_CO2 = .FALSE.
      LSKIN_TEMP = .FALSE.

      DO JL = KIDIA, KFDIA

        PGPP(JL) = 0._JPRB
        PRD(JL) = 0._JPRB
        PAN(JL) = 0._JPRB
        PGSTOT(JL) = 0._JPRB

      END DO

      allocate (INFO_LIMITPHOTO(KLON, NLAI1), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1
        return
      end if
      allocate (ZVC2(KLON, NLAI1), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1
        return
      end if
      allocate (ZVJ2(KLON, NLAI1), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1
        return
      end if
      allocate (ZASSIMI(KLON, NLAI1), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1
        return
      end if
      allocate (ZGS(KLON, NLAI1), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1
        return
      end if
      allocate (ZLAITAB(NLAI1), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1
        return
      end if
      allocate (ZLIGHT(NLAI), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1
        return
      end if
      allocate (ZRD(KLON, NLAI1), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1
        return
      end if
      allocate (ZJJ(KLON, NLAI1), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1
        return
      end if

      DO JL = KIDIA, KFDIA

        ZVCMAX25(JL) = 0._JPRB
        ZGAMMA_STAR(JL) = 0._JPRB
        ZKMO(JL) = 0._JPRB
        ZKMC(JL) = 0._JPRB
        ZGM(JL) = 0._JPRB
        ZG0VAR(JL) = 0._JPRB
        ZGSTOP(JL) = 0._JPRB
        ZASSIMTOT(JL) = 0._JPRB
        ZRDTOT(JL) = 0._JPRB
        ZLEAF_GS_TOP(JL) = 0._JPRB

        ZPB(JL) = PAPHM(JL)/100.0
        ZCO2(JL) = REAL(REAL(PCO2(JL), KIND=JPRD)*1.E6_JPRD*RMAIR/RMCO2, KIND=JPRB)
        IF ((ZCO2(JL) > 600.0_JPRB) .OR. (ZCO2(JL) < 200.0_JPRB)) THEN
! Source diagnostic output is outside this numerical API.
        END IF
        ZVC(JL) = 0._JPRB
        ZVJ(JL) = 0._JPRB
        LCALCULATE(JL) = .FALSE.

        ZCTYPE = 1
        IF (KCO2TYP(JL) .EQ. 4) THEN
          ZCTYPE(JL) = 2
        END IF

        DO JLEVEL = 1, NLAI + 1
          ZVC2(JL, JLEVEL) = 0._JPRB
          ZVJ2(JL, JLEVEL) = 0._JPRB
          ZJJ(JL, JLEVEL) = 0._JPRB
          INFO_LIMITPHOTO(JL, JLEVEL) = 0
          ZGS(JL, JLEVEL) = 0._JPRB
          ZASSIMI(JL, JLEVEL) = 0._JPRB
          ZRD(JL, JLEVEL) = 0._JPRB
        END DO

        IF (LSKIN_TEMP) THEN
          ZLEAF_TEMP(JL) = PTSKM(JL)
        ELSE
          ZLEAF_TEMP(JL) = PTM(JL)
        END IF

        ZTEMP_GROWTH(JL) = PTSOIL(JL) - RTP_00

      END DO

      DO JLEVEL = 1, NLAI + 1
        ZLAITAB(JLEVEL) = RLAIMAX*(surface_exp(RLAI_LEVEL_DEPTH*REAL(JLEVEL - 1._JPRB)) - 1._JPRB)/ &
           &                      (surface_exp(RLAI_LEVEL_DEPTH*REAL(NLAI, JPRB)) - 1._JPRB)
      END DO

      DO JLEVEL = 1, NLAI
        ZLIGHT(JLEVEL) = surface_exp(-REXT_COEFF*ZLAITAB(JLEVEL))
      END DO

      WHERE (KVTYPE(KIDIA:KFDIA) .GT. 0_JPIM)
        KVTYPE_TEMPO(KIDIA:KFDIA) = KVTYPE(KIDIA:KFDIA)
      ELSEWHERE
        KVTYPE_TEMPO(KIDIA:KFDIA) = 1_JPIM
      END WHERE

      IF (LDOWNREGULATION_CO2) THEN
        DO JL = KIDIA, KFDIA
          IF (LDLAND(JL)) THEN
            ZVCMAX25(JL) = RVCMAX25(KVTYPE_TEMPO(JL), ZCTYPE(JL))* &
     &                   (1._JPRB - RDOWNREGULATION_CO2_COEF(KVTYPE_TEMPO(JL), ZCTYPE(JL))* &
     &                       (MAX(ZCO2(JL), RDOWNREGULATION_CO2_MINIMUM) - RDOWNREGULATION_CO2_BASELEVEL)/ &
     &                       (MAX(ZCO2(JL), RDOWNREGULATION_CO2_MINIMUM) + 20._JPRB))
          END IF
        END DO
      ELSE
        DO JL = KIDIA, KFDIA
          IF (LDLAND(JL)) THEN
            ZVCMAX25(JL) = RVCMAX25(KVTYPE_TEMPO(JL), ZCTYPE(JL))
          END IF
        END DO
      END IF

      DO JL = KIDIA, KFDIA

        ZVPD(JL) = (PQS(JL)*ZPB(JL)/(RTETENS_1 + PQS(JL)*RTETENS_2)) &
                   - (PQM(JL)*ZPB(JL)/(RTETENS_1 + PQM(JL)*RTETENS_2))

        ZVPD(JL) = ZVPD(JL)/10._JPRB

        ZRVEGET(JL) = RUNDEF_SECHIBA

      END DO

      NIA = 0
      NINA = 0
      DO JL = KIDIA, KFDIA

        IF ((LDLAND(JL)) .AND. (PLAI(JL) .GT. 0.01_JPRB) .AND. (KVTYPE(JL) .GT. 0_JPIM)) THEN

          ZWATER_LIM(JL) = MIN(1._JPRB, PF2(JL)*RHUMREL(KVTYPE_TEMPO(JL), ZCTYPE(JL)))

          ZT_RD = ARRHENIUS_FN(ZLEAF_TEMP(JL), RREF_TEMP, RE_RD, YDAGF, YDCST)
          DO JLEVEL = 1, NLAI
            ZNITRO_VCMAX = (1._JPRB - RN_VERT_ATT*(1._JPRB - ZLIGHT(JLEVEL)))
            ZRD(JL, JLEVEL) = ZVCMAX25(JL)*ZNITRO_VCMAX*0.01_JPRB*ZT_RD &
                             &           *MAX(1._JPRB - RSTRESS_VCMAX, ZWATER_LIM(JL))
          END DO

          IF ((PSRFD(JL) .GT. EPSILON(1._JPRM)) .AND. &
              (PF2(JL) .GT. EPSILON(1._JPRM)) .AND. &
              (ZTEMP_GROWTH(JL) .GT. RTPHOTO_MIN) .AND. &
              (ZTEMP_GROWTH(JL) .LT. RTPHOTO_MAX)) THEN

            LASSIMILATE(JL) = .TRUE.
            NIA = NIA + 1
            INDEX_ASSI(NIA) = JL
            ILAI(JL) = 1

            ZT_KMC = ARRHENIUS_FN(ZLEAF_TEMP(JL), RREF_TEMP, RE_KMC, YDAGF, YDCST)
            ZT_KMO = ARRHENIUS_FN(ZLEAF_TEMP(JL), RREF_TEMP, RE_KMO, YDAGF, YDCST)
            ZT_SCO = ARRHENIUS_FN(ZLEAF_TEMP(JL), RREF_TEMP, RE_SCO, YDAGF, YDCST)
            ZT_GAMMA_STAR = ARRHENIUS_FN(ZLEAF_TEMP(JL), RREF_TEMP, RE_GAMMA_STAR, YDAGF, YDCST)

            IF (ZCTYPE(JL) .EQ. 1_JPIM) THEN
              IF (LACCLIMATION) THEN

                ZS_JMAX_ACCLIMTEMP = RASJ(1) + RBSJ(1)*MAX(11._JPRB, MIN(ZTEMP_GROWTH(JL), 35._JPRB))
                ZT_JMAX = ARRHENIUS_MODIFIED_FN(ZLEAF_TEMP(JL), RREF_TEMP,&
                             &              RE_JMAX(KVTYPE_TEMPO(JL), 1), RD_JMAX(1), &
                             &              ZS_JMAX_ACCLIMTEMP, YDAGF, YDCST)

                ZS_VCMAX_ACCLIMTEMP = RASV(1) + RBSV(1)*MAX(11._JPRB, MIN(ZTEMP_GROWTH(JL), 35._JPRB))
                ZT_VCMAX = ARRHENIUS_MODIFIED_FN(ZLEAF_TEMP(JL), RREF_TEMP, RE_VCMAX(KVTYPE_TEMPO(JL), 1), &
                             &              RD_VCMAX(1), ZS_VCMAX_ACCLIMTEMP, YDAGF, YDCST)

                ZJMAX25(JL) = (RARJV(1) + RBRJV(1)*MAX(11._JPRB, MIN(ZTEMP_GROWTH(JL), 35._JPRB)))*ZVCMAX25(JL)

              ELSE

                ZT_JMAX = ARRHENIUS_MODIFIED_FN(ZLEAF_TEMP(JL), RREF_TEMP, RE_JMAX(KVTYPE_TEMPO(JL), 1),&
                             &               RD_JMAX(1), RS_JMAX(1), YDAGF, YDCST)

                ZT_VCMAX = ARRHENIUS_FN(ZLEAF_TEMP(JL), RREF_TEMP, RE_VCMAX(KVTYPE_TEMPO(JL), 1), YDAGF, YDCST)

                ZJMAX25(JL) = (RARJV(1) + RBRJV(1)*25._JPRB)*ZVCMAX25(JL)

              END IF

              ZVJ(JL) = ZJMAX25(JL)*ZT_JMAX
              ZVC(JL) = ZVCMAX25(JL)*ZT_VCMAX

              ZT_GM = ARRHENIUS_MODIFIED_FN(ZLEAF_TEMP(JL), RREF_TEMP, RE_GM(1), RD_GM(1), RS_GM(1), YDAGF, YDCST)
              ZGM(JL) = RGM25(KVTYPE_TEMPO(JL), 1)*ZT_GM*MAX(1._JPRB - RSTRESS_GM, ZWATER_LIM(JL))

              ZG0VAR(JL) = RG0(KVTYPE_TEMPO(JL), 1)*MAX(1._JPRB - RSTRESS_GS, ZWATER_LIM(JL))
              ZKMC(JL) = RKMC25(1)*ZT_KMC
              ZKMO(JL) = RKMO25(1)*ZT_KMO
              ZSCO(JL) = RSCO25(1)*ZT_SCO
              ZFVPD(JL) = 1._JPRM/(1._JPRM/MIN(1._JPRM - EPSILON(1._JPRM), &
                       &    MAX(EPSILON(1._JPRM), (RA1(KVTYPE_TEMPO(JL), 1) - RB1(KVTYPE_TEMPO(JL), 1)* &
                       &      ZVPD(JL)))) - 1._JPRB) &
                       &     *MAX(1._JPRM - RSTRESS_GS, ZWATER_LIM(JL))

            ELSE IF (ZCTYPE(JL) .EQ. 2_JPIM) THEN
              IF (LACCLIMATION) THEN
                ZS_JMAX_ACCLIMTEMP = RASJ(2) + RBSJ(2)*MAX(11., MIN(ZTEMP_GROWTH(JL), 35.))
                ZT_JMAX = ARRHENIUS_MODIFIED_FN(ZLEAF_TEMP(JL), RREF_TEMP, RE_JMAX(KVTYPE_TEMPO(JL), 2),&
                   &                    RD_JMAX(2), ZS_JMAX_ACCLIMTEMP, YDAGF, YDCST)

                ZS_VCMAX_ACCLIMTEMP = RASV(2) + RBSV(2)*MAX(11., MIN(ZTEMP_GROWTH(JL), 35.))
                ZT_VCMAX = ARRHENIUS_MODIFIED_FN(ZLEAF_TEMP(JL), RREF_TEMP,&
                      &                      RE_VCMAX(KVTYPE_TEMPO(JL), 2), RD_VCMAX(2),&
                      &                      ZS_VCMAX_ACCLIMTEMP, YDAGF, YDCST)

                ZVJ(JL) = (RARJV(2) + RBRJV(2)*MAX(11., MIN(ZTEMP_GROWTH(JL), 35.)))*ZVCMAX25(JL)*ZT_JMAX
                ZVC(JL) = ZVCMAX25(JL)*ZT_VCMAX

              ELSE

                ZJMAX25(JL) = (RARJV(2) + RBRJV(2)*25._JPRB)*ZVCMAX25(JL)

                ZVJ(JL) = ZJMAX25(JL)*ARRHENIUS_MODIFIED_FN(ZLEAF_TEMP(JL), RREF_TEMP, &
                    & RE_JMAX(KVTYPE_TEMPO(JL), 2), RD_JMAX(2), RS_JMAX(2), YDAGF, YDCST)

                ZVC(JL) = ZVCMAX25(JL)*ARRHENIUS_FN(ZLEAF_TEMP(JL), RREF_TEMP,&
                         &                            RE_VCMAX(KVTYPE_TEMPO(JL), 2), YDAGF, YDCST)

              END IF

              ZG0VAR(JL) = RG0(KVTYPE_TEMPO(JL), 2)*MAX(1._JPRB - RSTRESS_GS, ZWATER_LIM(JL))
              ZKMC(JL) = RKMC25(2)*ZT_KMC
              ZKMO(JL) = RKMO25(2)*ZT_KMO
              ZSCO(JL) = RSCO25(2)*ZT_SCO
              ZFVPD(JL) = 1._JPRM/(1._JPRM/MIN(1._JPRM - EPSILON(1._JPRM), &
                        &      MAX(EPSILON(1._JPRM), (RA1(KVTYPE_TEMPO(JL), 2) - RB1(KVTYPE_TEMPO(JL), 2) &
                        &       *ZVPD(JL)))) - 1._JPRM) &
                        &      *MAX(1._JPRM - RSTRESS_GS, ZWATER_LIM(JL))
            ELSE

              ZSCO(JL) = RSCO25(2)

            END IF

            ZGAMMA_STAR(JL) = RGAMMA_STAR25*ZT_GAMMA_STAR

            ZLOW_GAMMA_STAR(JL) = 0.5_JPRB/ZSCO(JL)

            ZGBH2O(JL) = RGB_REF*44.6_JPRB*(RTP_00/PTM(JL))*(ZPB(JL)/RPB_STD)

            ZGBCO2(JL) = ZGBH2O(JL)/RRATIO_H2O_TO_CO2

            DO JLEVEL = 1, NLAI

              ZNITRO_VCMAX = (1._JPRB - RN_VERT_ATT*(1._JPRB - ZLIGHT(JLEVEL)))
              ZVC2(JL, JLEVEL) = ZVC(JL)*ZNITRO_VCMAX*MAX(1._JPRB - RSTRESS_VCMAX, ZWATER_LIM(JL))
              ZVJ2(JL, JLEVEL) = ZVJ(JL)*ZNITRO_VCMAX*MAX(1._JPRB - RSTRESS_VCMAX, ZWATER_LIM(JL))

              ZIABS(JL) = PSRFD(JL)*RW_TO_MOL*RRG_TO_PAR*REXT_COEFF*ZLIGHT(JLEVEL)

              ZJMAX(JL) = ZVJ2(JL, JLEVEL)
              ZJJ(JL, JLEVEL) = (RALPHA_LL*ZIABS(JL) + ZJMAX(JL) - &
                            &   SQRT((RALPHA_LL*ZIABS(JL) + ZJMAX(JL))**2._JPRB &
                            &   - 4._JPRB*RTHETA*ZJMAX(JL)*RALPHA_LL*ZIABS(JL))) &
                            &    /(2._JPRB*RTHETA)

            END DO
          ELSE
            LASSIMILATE(JL) = .FALSE.
            NINA = NINA + 1
            INDEX_NON_ASSI(NINA) = JL

          END IF

        ELSE
          LASSIMILATE(JL) = .FALSE.
          NINA = NINA + 1
          INDEX_NON_ASSI(NINA) = JL
        END IF

      END DO

      DO JLEVEL = 1, NLAI
        NIC = 0
        IF (NIA .GT. 0) then
          DO INIA = 1, NIA
            LCALCULATE(INDEX_ASSI(INIA)) = (ZLAITAB(JLEVEL) .LE. PLAI(INDEX_ASSI(INIA)))
            IF (LCALCULATE(INDEX_ASSI(INIA))) THEN
              NIC = NIC + 1
              INDEX_CALC(NIC) = INDEX_ASSI(INIA)
            END IF
          END DO
        END IF
        IF (NIC .GT. 0) THEN
          DO INIC = 1, NIC

            ICINIC = INDEX_CALC(INIC)

            IF (ZCTYPE(ICINIC) .EQ. 2_JPIM) THEN

              ZFCYC = 1._JPRD - (4._JPRD*(1._JPRD - REAL(RFPSIR, KIND=JPRD))* &
                  & (1._JPRD + REAL(RFQ, KIND=JPRD)) + 3._JPRD*REAL(RH_PROTONS, KIND=JPRD)* &
                  & REAL(RFPSEUDO, KIND=JPRD))/(3._JPRD*REAL(RH_PROTONS) - &
                  & 4._JPRD*(1._JPRD - REAL(RFPSIR, KIND=JPRD)))

              ZRM = REAL(ZRD(ICINIC, JLEVEL), KIND=JPRD)/2._JPRD

              ZCS_STAR = (REAL(RGBS, KIND=JPRD)*REAL(ZLOW_GAMMA_STAR(ICINIC), KIND=JPRD)* &
                       &  REAL(ROI, KIND=JPRD) - (1._JPRD + REAL(ZLOW_GAMMA_STAR(ICINIC), KIND=JPRD)* &
                       &  REAL(RALPHA, KIND=JPRD)/0.047_JPRD)*REAL(ZRD(ICINIC, JLEVEL), KIND=JPRD) + &
                       &  REAL(ZRM, KIND=JPRD))/(REAL(RGBS, KIND=JPRD) + REAL(RKP, KIND=JPRD))

              ZJ2 = REAL(ZJJ(ICINIC, JLEVEL), KIND=JPRD)/ &
                  & (1._JPRD - REAL(RFPSEUDO, KIND=JPRD)/(1._JPRD - ZFCYC))

              ZZ = (2._JPRD + REAL(RFQ, KIND=JPRD) - ZFCYC)/(REAL(RH_PROTONS, KIND=JPRD)*(1._JPRD - ZFCYC))

              ZVPJ2 = REAL(RFPSIR, KIND=JPRD)*ZJ2*ZZ/2._JPRD

              ZC4_XJ = (1._JPRD - REAL(RFPSIR, KIND=JPRD))*ZJ2*ZZ/3._JPRD
              ZC4_X2J = 7._JPRD*REAL(ZLOW_GAMMA_STAR(ICINIC), KIND=JPRD)/3._JPRD
              ZA_3 = 9999._JPRD
              LFOUND_C4_ROOT = .FALSE.
              DO LIMIT_PHOTO = 1, 4
                IF (LIMIT_PHOTO .EQ. 1 .OR. LIMIT_PHOTO .EQ. 3) THEN
                  IRUB_C4 = 1
                  ZX1 = REAL(ZVC2(ICINIC, JLEVEL), KIND=JPRD)
                  ZX2 = REAL(ZKMC(ICINIC)/ZKMO(ICINIC), KIND=JPRD)
                  ZX3 = REAL(ZKMC(ICINIC), KIND=JPRD)
                ELSE
                  IRUB_C4 = 2
                  ZX1 = ZC4_XJ
                  ZX2 = ZC4_X2J
                  ZX3 = 0._JPRD
                END IF
                IF (LIMIT_PHOTO .EQ. 1 .OR. LIMIT_PHOTO .EQ. 4) THEN
                  IPEP_C4 = 1
                  ZA = 1._JPRD + REAL(RKP, KIND=JPRD)/REAL(RGBS, KIND=JPRD)
                  ZB = 0._JPRD
                ELSE
                  IPEP_C4 = 2
                  ZA = 1._JPRD
                  ZB = ZVPJ2
                END IF
                CALL C4_GROSS_COEFFICIENTS(REAL(ZCO2(ICINIC), KIND=JPRD), &
                 & REAL(ZGBCO2(ICINIC), KIND=JPRD), REAL(ZG0VAR(ICINIC), KIND=JPRD), &
                 & REAL(ZFVPD(ICINIC), KIND=JPRD), REAL(ZRD(ICINIC, JLEVEL), KIND=JPRD), &
                 & ZRM, ZCS_STAR, ZA, ZB, ZX1, ZX2, ZX3, REAL(RGBS, KIND=JPRD), REAL(ROI, KIND=JPRD), &
                 & REAL(RALPHA, KIND=JPRD), REAL(ZLOW_GAMMA_STAR(ICINIC), KIND=JPRD), ZC4_COEF)
                ZC4_LOWER = 0._JPRD
                ZC4_UPPER = MIN(ZX1, REAL(ZGBCO2(ICINIC), KIND=JPRD)* &
                 & (REAL(ZCO2(ICINIC), KIND=JPRD) - ZCS_STAR) + REAL(ZRD(ICINIC, JLEVEL), KIND=JPRD))
                CALL C4_PHYSICAL_ROOTS(ZC4_COEF, ZC4_LOWER, ZC4_UPPER, ZC4_ROOTS, NROOT_C4)
                DO IROOT_C4 = 1, NROOT_C4
                  ZC4_GROSS = ZC4_ROOTS(IROOT_C4)
                  ZA_3_tmp = ZC4_GROSS - REAL(ZRD(ICINIC, JLEVEL), KIND=JPRD)
                  IF (ZC4_GROSS .LT. 0._JPRD .OR. ZC4_GROSS .GE. ZX1) CYCLE
                  ZC4_CS = REAL(ZCO2(ICINIC), KIND=JPRD) - ZA_3_tmp/REAL(ZGBCO2(ICINIC), KIND=JPRD)
                  IF (ZC4_CS .LE. ZCS_STAR) CYCLE
                  ZC4_GS = REAL(ZG0VAR(ICINIC), KIND=JPRD) + ZC4_GROSS/(ZC4_CS - ZCS_STAR)*REAL(ZFVPD(ICINIC), KIND=JPRD)
                  IF (ZC4_GS .LE. 0._JPRD) CYCLE
                  ZC4_CI = ZC4_CS - ZA_3_tmp/ZC4_GS
                  IF (ZC4_CI .LE. 0._JPRD) CYCLE
                  ZC4_OBS = REAL(RALPHA, KIND=JPRD)*ZA_3_tmp/(0.047_JPRD*REAL(RGBS, KIND=JPRD)) + REAL(ROI, KIND=JPRD)
                  ZC4_CC = (ZC4_GROSS*(ZX2*ZC4_OBS + ZX3) + REAL(ZLOW_GAMMA_STAR(ICINIC), KIND=JPRD)*ZC4_OBS*ZX1)/(ZX1 - ZC4_GROSS)
                  IF (ZC4_CC .LE. 0._JPRD) CYCLE
                  ZC4_RC = REAL(ZVC2(ICINIC, JLEVEL), KIND=JPRD)*(ZC4_CC - REAL(ZLOW_GAMMA_STAR(ICINIC), KIND=JPRD)*ZC4_OBS)/ &
                        & (ZC4_CC + REAL(ZKMC(ICINIC), KIND=JPRD)*(1._JPRD + ZC4_OBS/REAL(ZKMO(ICINIC), KIND=JPRD)))
                  ZC4_RJ = ZC4_XJ*(ZC4_CC - REAL(ZLOW_GAMMA_STAR(ICINIC), KIND=JPRD)*ZC4_OBS)/(ZC4_CC + ZC4_X2J*ZC4_OBS)
                  IF (IRUB_C4 .EQ. 1 .AND. ZC4_RC .GT. ZC4_RJ) CYCLE
                  IF (IRUB_C4 .EQ. 2 .AND. ZC4_RJ .GT. ZC4_RC) CYCLE
                  ZC4_VP = REAL(RKP, KIND=JPRD)*ZC4_CI
                  IF (IPEP_C4 .EQ. 1 .AND. ZC4_VP .GT. ZVPJ2) CYCLE
                  IF (IPEP_C4 .EQ. 2 .AND. ZVPJ2 .GT. ZC4_VP) CYCLE
                  IF (.NOT. LFOUND_C4_ROOT .OR. ZA_3_tmp .LT. ZA_3) THEN
                    ZC4_SAVED_GROSS = ZC4_GROSS
                    ZA_3 = ZA_3_tmp
                    ZC4_SAVED_A = ZA
                    ZC4_SAVED_B = ZB
                    ZC4_SAVED_X1 = ZX1
                    ZC4_SAVED_X2 = ZX2
                    ZC4_SAVED_X3 = ZX3
                    INFO_LIMITPHOTO(ICINIC, JLEVEL) = LIMIT_PHOTO
                    LFOUND_C4_ROOT = .TRUE.
                  END IF
                END DO
              END DO
              IF (.NOT. LFOUND_C4_ROOT) ERROR STOP "No admissible C4 root in source-control domain"
              ZA = ZC4_SAVED_A
              ZB = ZC4_SAVED_B
              ZX1 = ZC4_SAVED_X1
              ZX2 = ZC4_SAVED_X2
              ZX3 = ZC4_SAVED_X3
              ZASSIMI(ICINIC, JLEVEL) = REAL(ZA_3, KIND=JPRB)
              ZVJ2(ICINIC, JLEVEL) = REAL(ZC4_SAVED_GROSS, KIND=JPRB)
   ZOBS = REAL(RALPHA, KIND=JPRD)*REAL(ZASSIMI(ICINIC, JLEVEL), KIND=JPRD)/(0.047_JPRD*REAL(RGBS, KIND=JPRD)) + REAL(ROI, KIND=JPRD)
              ZCC = (ZC4_SAVED_GROSS*(ZX2*ZOBS + ZX3) + REAL(ZLOW_GAMMA_STAR(ICINIC), KIND=JPRD)*ZOBS*ZX1)/(ZX1 - ZC4_SAVED_GROSS)
              ZLEAF_CI = (ZCC - (ZB - REAL(ZASSIMI(ICINIC, JLEVEL), KIND=JPRD) - REAL(ZRM, KIND=JPRD))/REAL(RGBS, KIND=JPRD))/ZA
              ZGS(ICINIC, JLEVEL) = REAL(REAL(ZG0VAR(ICINIC), KIND=JPRD) + ZC4_SAVED_GROSS/ &
        & ((REAL(ZCO2(ICINIC), KIND=JPRD) - REAL(ZASSIMI(ICINIC, JLEVEL), KIND=JPRD)/REAL(ZGBCO2(ICINIC), KIND=JPRD)) - ZCS_STAR)* &
               & REAL(ZFVPD(ICINIC), KIND=JPRD), KIND=JPRB)

            ELSE IF (ZCTYPE(ICINIC) .EQ. 1_JPIM) THEN

              ZA_1 = 9999._JPRD

              DO LIMIT_PHOTO = 1, 2
                IF (LIMIT_PHOTO .EQ. 1) THEN
                  ZX1 = REAL(ZVC2(ICINIC, JLEVEL), KIND=JPRD)
                  ZX2 = REAL(ZKMC(ICINIC), KIND=JPRD)*(1._JPRD + 2._JPRD*REAL(ZGAMMA_STAR(ICINIC), KIND=JPRD)* &
                      & REAL(ZSCO(ICINIC), KIND=JPRD)/REAL(ZKMO(ICINIC), KIND=JPRD))

                ELSE
                  ZX1 = REAL(ZJJ(ICINIC, JLEVEL), KIND=JPRD)/4._JPRD
                  ZX2 = 2._JPRD*REAL(ZGAMMA_STAR(ICINIC), KIND=JPRD)
                END IF

                ZA = REAL(ZG0VAR(ICINIC), KIND=JPRD)*(ZX2 + REAL(ZGAMMA_STAR(ICINIC), KIND=JPRD)) + &
                   & (REAL(ZG0VAR(ICINIC), KIND=JPRD)/REAL(ZGM(ICINIC), KIND=JPRD) + &
                   & REAL(ZFVPD(ICINIC), KIND=JPRD))*(ZX1 - REAL(ZRD(ICINIC, JLEVEL), KIND=JPRD))
                ZB = REAL(ZCO2(ICINIC), KIND=JPRD)*(ZX1 - REAL(ZRD(ICINIC, JLEVEL), KIND=JPRD)) - &
                   & REAL(ZGAMMA_STAR(ICINIC), KIND=JPRD)*ZX1 - REAL(ZRD(ICINIC, JLEVEL), KIND=JPRD)*ZX2
                ZC = REAL(ZCO2(ICINIC), KIND=JPRD) + ZX2 + (1._JPRD/REAL(ZGM(ICINIC), KIND=JPRD) + &
                   & 1._JPRD/REAL(ZGBCO2(ICINIC), KIND=JPRD))*(ZX1 - REAL(ZRD(ICINIC, JLEVEL), KIND=JPRD))
                ZD = ZX2 + REAL(ZGAMMA_STAR(ICINIC), KIND=JPRD) + &
                   & (ZX1 - REAL(ZRD(ICINIC, JLEVEL), KIND=JPRD))/ &
                   &  REAL(ZGM(ICINIC), KIND=JPRD)
                ZM = 1._JPRD/REAL(ZGM(ICINIC), KIND=JPRD) + &
                   & (REAL(ZG0VAR(ICINIC), KIND=JPRD)/REAL(ZGM(ICINIC), KIND=JPRD) + &
                   & REAL(ZFVPD(ICINIC), KIND=JPRD))* &
                   &  (1._JPRD/REAL(ZGM(ICINIC), KIND=JPRD) + 1._JPRD/REAL(ZGBCO2(ICINIC), KIND=JPRD))

                ZP = -(ZD + (ZX1 - REAL(ZRD(ICINIC, JLEVEL), KIND=JPRD))/ &
                   & REAL(ZGM(ICINIC), KIND=JPRD) + ZA* &
                   & (1._JPRD/REAL(ZGM(ICINIC), KIND=JPRD) + 1._JPRD/REAL(ZGBCO2(ICINIC), KIND=JPRD)) + &
                   & (REAL(ZG0VAR(ICINIC), KIND=JPRD)/REAL(ZGM(ICINIC), KIND=JPRD) + &
                   & REAL(ZFVPD(ICINIC), KIND=JPRD))*ZC)/ZM

                ZQ = (ZD*(ZX1 - REAL(ZRD(ICINIC, JLEVEL), KIND=JPRD)) + ZA*ZC + &
                   & (REAL(ZG0VAR(ICINIC), KIND=JPRD)/REAL(ZGM(ICINIC), KIND=JPRD) + &
                  &  REAL(ZFVPD(ICINIC), KIND=JPRD))*ZB)/ZM
                ZR = -ZA*ZB/ZM

                ZQQ = ((ZP**2._JPRD) - 3._JPRD*ZQ)/9._JPRD
                ZUU = (2._JPRD*(ZP**3._JPRD) - 9._JPRD*ZP*ZQ + 27._JPRD*ZR)/54._JPRD

                IF (ZQQ .GE. 0._JPRD) THEN
                IF (ABS(ZUU/(surface_power(ZQQ, 1.5_JPRD))) .LE. 1._JPRD) THEN
                  ZPSI = surface_acos(ZUU/(surface_power(ZQQ, 1.5_JPRD)))
                  ZA_1_tmp = -2._JPRD*SQRT(ZQQ)*surface_cos(ZPSI/3._JPRD) - ZP/3._JPRD

                  IF ((ZA_1_tmp .LT. ZA_1)) THEN
                    ZA_1 = ZA_1_tmp
                    INFO_LIMITPHOTO(ICINIC, JLEVEL) = 2
                  ELSE
                    ZX1 = REAL(ZVC2(ICINIC, JLEVEL), KIND=JPRD)
                    ZX2 = REAL(ZKMC(ICINIC), KIND=JPRD)*(1._JPRD + 2._JPRD* &
                       &  REAL(ZGAMMA_STAR(ICINIC), KIND=JPRD)*REAL(ZSCO(ICINIC), KIND=JPRD)/REAL(ZKMO(ICINIC), KIND=JPRD))
                    INFO_LIMITPHOTO(ICINIC, JLEVEL) = 1
                  END IF
                END IF
                END IF
              END DO

              IF ((ZA_1 .EQ. 9999._JPRD) .OR. (ZA_1 .LT. (-REAL(ZRD(ICINIC, JLEVEL), KIND=JPRD)))) THEN
                ZA_1 = -REAL(ZRD(ICINIC, JLEVEL), KIND=JPRD)
              END IF
              ZASSIMI(ICINIC, JLEVEL) = REAL(ZA_1, KIND=JPRB)

              IF (ABS(ZASSIMI(ICINIC, JLEVEL) + ZRD(ICINIC, JLEVEL)) .LT. EPSILON(1._JPRM)) THEN
                ZGS(ICINIC, JLEVEL) = ZG0VAR(ICINIC)
              ELSE

                ZCC = (REAL(ZGAMMA_STAR(ICINIC), KIND=JPRD)*ZX1 + (REAL(ZASSIMI(ICINIC, JLEVEL), KIND=JPRD) + &
                    &  REAL(ZRD(ICINIC, JLEVEL), KIND=JPRD))*ZX2)  &
                    &  /MAX(EPSILON(1._JPRM), ZX1 - (REAL(ZASSIMI(ICINIC, JLEVEL), KIND=JPRD) +&
                    &  REAL(ZRD(ICINIC, JLEVEL), KIND=JPRD)))
                ZLEAF_CI = ZCC + REAL(ZASSIMI(ICINIC, JLEVEL), KIND=JPRD)/REAL(ZGM(ICINIC), KIND=JPRD)
                ZCI_STAR = REAL(ZGAMMA_STAR(ICINIC), KIND=JPRD) - &
                         & REAL(ZRD(ICINIC, JLEVEL), KIND=JPRD)/REAL(ZGM(ICINIC), KIND=JPRD)

                ZGS(ICINIC, JLEVEL) = REAL(REAL(ZG0VAR(ICINIC), KIND=JPRD) + &
                                   & (REAL(ZASSIMI(ICINIC, JLEVEL), KIND=JPRD) + &
                                   &  REAL(ZRD(ICINIC, JLEVEL), KIND=JPRD))/ &
                                   & (ZLEAF_CI - ZCI_STAR)*REAL(ZFVPD(ICINIC), KIND=JPRD), KIND=JPRB)

              END IF

            ELSE
! Source diagnostic output is outside this numerical API.
              ZASSIMI(ICINIC, JLEVEL) = 0._JPRB
              ZGS(ICINIC, JLEVEL) = ZG0VAR(ICINIC)
            END IF

          END DO
        END IF
        IF (NIC .GT. 0) THEN
          DO INIC = 1, NIC
            ICINIC = INDEX_CALC(INIC)
            IF (JLEVEL .EQ. 1) THEN
              ZLEAF_GS_TOP(ICINIC) = ZGS(ICINIC, JLEVEL)
            END IF
            IF (ZCTYPE(ICINIC) .EQ. 2_JPIM) THEN
              ZASSIMTOT(ICINIC) = ZASSIMTOT(ICINIC) + ZVJ2(ICINIC, JLEVEL)*(ZLAITAB(JLEVEL + 1) - ZLAITAB(JLEVEL))
            ELSE
              ZASSIMTOT(ICINIC) = ZASSIMTOT(ICINIC) + &
              &                   (ZASSIMI(ICINIC, JLEVEL) + ZRD(ICINIC, JLEVEL))*&
              &                   (ZLAITAB(JLEVEL + 1) - ZLAITAB(JLEVEL))
            END IF

            PGSTOT(ICINIC) = PGSTOT(ICINIC) + &
            & ZGS(ICINIC, JLEVEL)*(ZLAITAB(JLEVEL + 1) - ZLAITAB(JLEVEL))
            ILAI(ICINIC) = JLEVEL
          END DO
        END IF

        DO JL = KIDIA, KFDIA
          ZRDTOT(JL) = ZRDTOT(JL) + &
                       ZRD(JL, JLEVEL)*(ZLAITAB(JLEVEL + 1) - ZLAITAB(JLEVEL))
        END DO

      END DO

      IF (NIA .GT. 0) THEN
        DO INIA = 1, NIA
          IAINIA = INDEX_ASSI(INIA)

          PGPP(IAINIA) = ZASSIMTOT(IAINIA)*1E-6_JPRB*RMCO2

          PGSTOT(IAINIA) = RMOL_TO_M_1*(PTM(IAINIA)/RTP_00)* &
                           (RPB_STD/ZPB(IAINIA))*PGSTOT(IAINIA)*RRATIO_H2O_TO_CO2

          ZGSTOP(IAINIA) = RMOL_TO_M_1*(PTM(IAINIA)/RTP_00)* &
                           (RPB_STD/ZPB(IAINIA))*ZLEAF_GS_TOP(IAINIA)*RRATIO_H2O_TO_CO2* &
                           ZLAITAB(ILAI(IAINIA) + 1)

          IF (ZGSTOP(IAINIA) .LT. EPSILON(1._JPRM)) THEN
            ZRVEGET(IAINIA) = RUNDEF_SECHIBA
          ELSE
            ZRVEGET(IAINIA) = 1._JPRB/ZGSTOP(IAINIA)
          END IF

        END DO
      END IF

      DO JL = KIDIA, KFDIA
        PAN(JL) = (ZASSIMTOT(JL) - ZRDTOT(JL))*1E-6_JPRB*RMCO2
        PRD(JL) = ZRDTOT(JL)*1E-6_JPRB*RMCO2
      END DO

      IF (ALLOCATED(ZVC2)) DEALLOCATE (ZVC2)
      IF (ALLOCATED(ZVJ2)) DEALLOCATE (ZVJ2)
      IF (ALLOCATED(ZASSIMI)) DEALLOCATE (ZASSIMI)
      IF (ALLOCATED(ZGS)) DEALLOCATE (ZGS)
      IF (ALLOCATED(ZLAITAB)) DEALLOCATE (ZLAITAB)
      IF (ALLOCATED(ZLIGHT)) DEALLOCATE (ZLIGHT)
      IF (ALLOCATED(ZRD)) DEALLOCATE (ZRD)
      IF (ALLOCATED(ZJJ)) DEALLOCATE (ZJJ)

    END ASSOCIATE
    status = 0
  end subroutine farquhar
end module
