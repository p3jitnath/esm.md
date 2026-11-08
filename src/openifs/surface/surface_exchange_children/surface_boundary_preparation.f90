!> Native VSURF surface boundary preparation and direct canopy child.
!! The thermal record precedes the original51arguments; INT32status follows.
!! Temperatures use K, pressure Pa, specific humidity kg/kg and soil water
!! m3/m3. Native readonly surface parameter records retain their identity.
!! All mutable arrays are INOUT to preserve inactive and unwritten values.
!! VSURF selects the corrected sea derivative. The explicitly named
!! VSURF_ORIGINAL_SOURCE_SEA retains the extra source salinity factor.
!! Both support the same direct native C3/C4 child, actual LEFARQUHAR
!! selection and selected four-soil-layer/nine-tile controls.
module forecast_surface_boundary_preparation
  use iso_fortran_env, only: int32, real64
  use forecast_surface_scalar_math, only: surface_sin, surface_exp
  use forecast_canopy_water_stress, only: cotworestress
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use yos_cst, only: tcst
  use yos_veg, only: tveg
  use yos_exc, only: texc
  use yos_ags, only: tags
  use yos_agf, only: tagf
  use yos_soil, only: tsoil
  use yos_flake, only: tflake
  use yos_urb, only: turb
  implicit none
  private
  integer, parameter :: jpim = int32, jprb = real64
  public :: vsurf, vsurf_original_source_sea
contains
subroutine vsurf(ydthermal,KIDIA,KFDIA,KLON,KTILES,KLEVS,KTILE,KTVL,KCO2TYP,KTVH,JVTTL,KVEG,PLAI,PMU0,PCO2FLUX,PFRTI,PLAIL,PLAIH,PTMLEV,PQMLEV,PCMLEV,PAPHMS,PTSKM1M,PWSAM1M,PTSAM1M,KSOTY,PSRFD,PRAQ,PQSAM,PQS,PDQS,PWETB,PCPTS,PWETL,PWETLU,PWETH,PWETHS,PEVAP,PAN,PAG,PRD,PPWLIQ,PDHVEGS,PEXDIAG,YDCST,YDVEG,YDEXC,YDAGS,YDAGF,YDSOIL,YDFLAKE,YDURB,status)

    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KTILES
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEVS
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KTILE
    INTEGER(KIND=JPIM), INTENT(IN) :: KTVL(:)
    INTEGER(KIND=JPIM), INTENT(IN) :: KCO2TYP(:)
    INTEGER(KIND=JPIM), INTENT(IN) :: KTVH(:)

    INTEGER(KIND=JPIM), INTENT(IN) :: JVTTL
    INTEGER(KIND=JPIM), INTENT(IN) :: KVEG(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PLAI(:)
    REAL(KIND=JPRB), INTENT(IN) :: PMU0(:)
    REAL(KIND=JPRB), INTENT(IN) :: PEVAP(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PAN(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PAG(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PRD(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDHVEGS(:, :, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PEXDIAG(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PCO2FLUX(:)

    REAL(KIND=JPRB), INTENT(IN) :: PLAIL(:)
    REAL(KIND=JPRB), INTENT(IN) :: PLAIH(:)
    INTEGER(KIND=JPIM), INTENT(IN) :: KSOTY(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTMLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PFRTI(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PQMLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PCMLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PAPHMS(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTSKM1M(:)
    REAL(KIND=JPRB), INTENT(IN) :: PWSAM1M(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PTSAM1M(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PSRFD(:)
    REAL(KIND=JPRB), INTENT(IN) :: PRAQ(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PQSAM(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PQS(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDQS(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PWETB(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCPTS(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PWETL(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PWETLU(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PWETH(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PWETHS(:)

    REAL(KIND=JPRB), INTENT(INOUT) :: PPWLIQ(KLON, KLEVS)

    TYPE(TCST), INTENT(IN) :: YDCST
    TYPE(TVEG), INTENT(IN) :: YDVEG
    TYPE(TEXC), INTENT(IN) :: YDEXC
    TYPE(TAGS), INTENT(IN) :: YDAGS
    TYPE(TAGF), INTENT(IN) :: YDAGF
    TYPE(TSOIL), INTENT(IN) :: YDSOIL
    TYPE(TFLAKE), INTENT(IN) :: YDFLAKE
    TYPE(TURB), INTENT(IN) :: YDURB

    type(thermal_parameter_record), intent(in) :: ydthermal
    integer(int32), intent(out) :: status
call vsurf_core(ydthermal,.false.,KIDIA,KFDIA,KLON,KTILES,KLEVS,KTILE,KTVL,KCO2TYP,KTVH,JVTTL,KVEG,PLAI,PMU0,PCO2FLUX,PFRTI,PLAIL,PLAIH,PTMLEV,PQMLEV,PCMLEV,PAPHMS,PTSKM1M,PWSAM1M,PTSAM1M,KSOTY,PSRFD,PRAQ,PQSAM,PQS,PDQS,PWETB,PCPTS,PWETL,PWETLU,PWETH,PWETHS,PEVAP,PAN,PAG,PRD,PPWLIQ,PDHVEGS,PEXDIAG,YDCST,YDVEG,YDEXC,YDAGS,YDAGF,YDSOIL,YDFLAKE,YDURB,status)
  end subroutine vsurf
subroutine vsurf_original_source_sea(ydthermal,KIDIA,KFDIA,KLON,KTILES,KLEVS,KTILE,KTVL,KCO2TYP,KTVH,JVTTL,KVEG,PLAI,PMU0,PCO2FLUX,PFRTI,PLAIL,PLAIH,PTMLEV,PQMLEV,PCMLEV,PAPHMS,PTSKM1M,PWSAM1M,PTSAM1M,KSOTY,PSRFD,PRAQ,PQSAM,PQS,PDQS,PWETB,PCPTS,PWETL,PWETLU,PWETH,PWETHS,PEVAP,PAN,PAG,PRD,PPWLIQ,PDHVEGS,PEXDIAG,YDCST,YDVEG,YDEXC,YDAGS,YDAGF,YDSOIL,YDFLAKE,YDURB,status)

    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KTILES
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEVS
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KTILE
    INTEGER(KIND=JPIM), INTENT(IN) :: KTVL(:)
    INTEGER(KIND=JPIM), INTENT(IN) :: KCO2TYP(:)
    INTEGER(KIND=JPIM), INTENT(IN) :: KTVH(:)

    INTEGER(KIND=JPIM), INTENT(IN) :: JVTTL
    INTEGER(KIND=JPIM), INTENT(IN) :: KVEG(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PLAI(:)
    REAL(KIND=JPRB), INTENT(IN) :: PMU0(:)
    REAL(KIND=JPRB), INTENT(IN) :: PEVAP(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PAN(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PAG(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PRD(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDHVEGS(:, :, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PEXDIAG(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PCO2FLUX(:)

    REAL(KIND=JPRB), INTENT(IN) :: PLAIL(:)
    REAL(KIND=JPRB), INTENT(IN) :: PLAIH(:)
    INTEGER(KIND=JPIM), INTENT(IN) :: KSOTY(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTMLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PFRTI(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PQMLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PCMLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PAPHMS(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTSKM1M(:)
    REAL(KIND=JPRB), INTENT(IN) :: PWSAM1M(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PTSAM1M(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PSRFD(:)
    REAL(KIND=JPRB), INTENT(IN) :: PRAQ(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PQSAM(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PQS(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDQS(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PWETB(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCPTS(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PWETL(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PWETLU(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PWETH(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PWETHS(:)

    REAL(KIND=JPRB), INTENT(INOUT) :: PPWLIQ(KLON, KLEVS)

    TYPE(TCST), INTENT(IN) :: YDCST
    TYPE(TVEG), INTENT(IN) :: YDVEG
    TYPE(TEXC), INTENT(IN) :: YDEXC
    TYPE(TAGS), INTENT(IN) :: YDAGS
    TYPE(TAGF), INTENT(IN) :: YDAGF
    TYPE(TSOIL), INTENT(IN) :: YDSOIL
    TYPE(TFLAKE), INTENT(IN) :: YDFLAKE
    TYPE(TURB), INTENT(IN) :: YDURB

    type(thermal_parameter_record), intent(in) :: ydthermal
    integer(int32), intent(out) :: status
call vsurf_core(ydthermal,.true.,KIDIA,KFDIA,KLON,KTILES,KLEVS,KTILE,KTVL,KCO2TYP,KTVH,JVTTL,KVEG,PLAI,PMU0,PCO2FLUX,PFRTI,PLAIL,PLAIH,PTMLEV,PQMLEV,PCMLEV,PAPHMS,PTSKM1M,PWSAM1M,PTSAM1M,KSOTY,PSRFD,PRAQ,PQSAM,PQS,PDQS,PWETB,PCPTS,PWETL,PWETLU,PWETH,PWETHS,PEVAP,PAN,PAG,PRD,PPWLIQ,PDHVEGS,PEXDIAG,YDCST,YDVEG,YDEXC,YDAGS,YDAGF,YDSOIL,YDFLAKE,YDURB,status)
  end subroutine vsurf_original_source_sea
subroutine vsurf_core(ydthermal,original_source_sea,KIDIA,KFDIA,KLON,KTILES,KLEVS,KTILE,KTVL,KCO2TYP,KTVH,JVTTL,KVEG,PLAI,PMU0,PCO2FLUX,PFRTI,PLAIL,PLAIH,PTMLEV,PQMLEV,PCMLEV,PAPHMS,PTSKM1M,PWSAM1M,PTSAM1M,KSOTY,PSRFD,PRAQ,PQSAM,PQS,PDQS,PWETB,PCPTS,PWETL,PWETLU,PWETH,PWETHS,PEVAP,PAN,PAG,PRD,PPWLIQ,PDHVEGS,PEXDIAG,YDCST,YDVEG,YDEXC,YDAGS,YDAGF,YDSOIL,YDFLAKE,YDURB,status)
    type(thermal_parameter_record), intent(in) :: ydthermal
    logical, intent(in) :: original_source_sea
    integer(int32), intent(out) :: status
    integer(int32) :: child_status
    real(real64) :: zderivative_correction

    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KTILES
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEVS
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KTILE
    INTEGER(KIND=JPIM), INTENT(IN) :: KTVL(:)
    INTEGER(KIND=JPIM), INTENT(IN) :: KCO2TYP(:)
    INTEGER(KIND=JPIM), INTENT(IN) :: KTVH(:)

    INTEGER(KIND=JPIM), INTENT(IN) :: JVTTL
    INTEGER(KIND=JPIM), INTENT(IN) :: KVEG(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PLAI(:)
    REAL(KIND=JPRB), INTENT(IN) :: PMU0(:)
    REAL(KIND=JPRB), INTENT(IN) :: PEVAP(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PAN(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PAG(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PRD(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDHVEGS(:, :, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PEXDIAG(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PCO2FLUX(:)

    REAL(KIND=JPRB), INTENT(IN) :: PLAIL(:)
    REAL(KIND=JPRB), INTENT(IN) :: PLAIH(:)
    INTEGER(KIND=JPIM), INTENT(IN) :: KSOTY(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTMLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PFRTI(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PQMLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PCMLEV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PAPHMS(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTSKM1M(:)
    REAL(KIND=JPRB), INTENT(IN) :: PWSAM1M(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PTSAM1M(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PSRFD(:)
    REAL(KIND=JPRB), INTENT(IN) :: PRAQ(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PQSAM(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PQS(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDQS(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PWETB(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCPTS(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PWETL(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PWETLU(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PWETH(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PWETHS(:)

    REAL(KIND=JPRB), INTENT(INOUT) :: PPWLIQ(KLON, KLEVS)

    TYPE(TCST), INTENT(IN) :: YDCST
    TYPE(TVEG), INTENT(IN) :: YDVEG
    TYPE(TEXC), INTENT(IN) :: YDEXC
    TYPE(TAGS), INTENT(IN) :: YDAGS
    TYPE(TAGF), INTENT(IN) :: YDAGF
    TYPE(TSOIL), INTENT(IN) :: YDSOIL
    TYPE(TFLAKE), INTENT(IN) :: YDFLAKE
    TYPE(TURB), INTENT(IN) :: YDURB

    INTEGER(KIND=JPIM) :: JK, JL, JS
    REAL(KIND=JPRB) :: ZLIQ(KLON, KLEVS), ZLIQR(KLON, KLEVS), ZF2(KLON), ZWROOT(KLON)
    REAL(KIND=JPRB) :: ZDSP(KLON), ZDMAXT(KLON)
    REAL(KIND=JPRB) :: ZWET(KLON)
    REAL(KIND=JPRB) :: ZTSK(KLON)
    REAL(KIND=JPRB) :: ZEPSILON

    REAL(KIND=JPRB) :: ZTSOIL(KLON)
    REAL(KIND=JPRB) :: ZCOR, ZEPSF3, ZF, ZF1H, ZF1L, ZF2H, ZF2L, ZF2B, &
     & ZF3H, ZF3L, ZHSTRH, ZHSTRL, ZLAIH, ZLAIL, ZQSAIR, &
     & ZRSMINH, ZRSMINL, ZRSMINB, ZRVA, ZRVB, ZSRFL, ZWROOTH, ZWROOTL, &
     & ZQWEVAP, ZWPWP, ZQWEVAPBARE, ZBARE, ZWPBARE,&
     & ZSALIN, ZRCLU

    status = 2
    if (klon < 1 .or. klon > 4096 .or. ktiles /= 9 .or. klevs /= 4 .or. ktile < 1 .or. ktile > 9) return
    if (kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon .or. kfdia < kidia - 1) return
    if (ydveg%leairco2coup) return
    if (size(pfrti, 2) < ktiles .or. size(kveg, 2) < ktiles) return
    if (size(pwsam1m, 2) < klevs .or. size(ptsam1m, 2) < klevs) return
    if (size(pdhvegs, 2) < 2 .or. size(pdhvegs, 3) < 7 .or. size(pexdiag, 2) < 10) return
    if (ktile == 4 .or. ktile == 6 .or. ktile == 7) then
      if (jvttl < 1 .or. jvttl > size(pdhvegs, 2)) return
    end if
    if (size(KTVL, 1) < klon) return
    if (size(KCO2TYP, 1) < klon) return
    if (size(KTVH, 1) < klon) return
    if (size(KVEG, 1) < klon) return
    if (size(PLAI, 1) < klon) return
    if (size(PMU0, 1) < klon) return
    if (size(PEVAP, 1) < klon) return
    if (size(PAN, 1) < klon) return
    if (size(PAG, 1) < klon) return
    if (size(PRD, 1) < klon) return
    if (size(PDHVEGS, 1) < klon) return
    if (size(PEXDIAG, 1) < klon) return
    if (size(PCO2FLUX, 1) < klon) return
    if (size(PLAIL, 1) < klon) return
    if (size(PLAIH, 1) < klon) return
    if (size(KSOTY, 1) < klon) return
    if (size(PTMLEV, 1) < klon) return
    if (size(PFRTI, 1) < klon) return
    if (size(PQMLEV, 1) < klon) return
    if (size(PCMLEV, 1) < klon) return
    if (size(PAPHMS, 1) < klon) return
    if (size(PTSKM1M, 1) < klon) return
    if (size(PWSAM1M, 1) < klon) return
    if (size(PTSAM1M, 1) < klon) return
    if (size(PSRFD, 1) < klon) return
    if (size(PRAQ, 1) < klon) return
    if (size(PQSAM, 1) < klon) return
    if (size(PQS, 1) < klon) return
    if (size(PDQS, 1) < klon) return
    if (size(PWETB, 1) < klon) return
    if (size(PCPTS, 1) < klon) return
    if (size(PWETL, 1) < klon) return
    if (size(PWETLU, 1) < klon) return
    if (size(PWETH, 1) < klon) return
    if (size(PWETHS, 1) < klon) return
    if (any(ktvl(kidia:kfdia) < 0) .or. any(ktvl(kidia:kfdia) > 20)) return
    if (any(ktvh(kidia:kfdia) < 0) .or. any(ktvh(kidia:kfdia) > 20)) return
    if (any(ksoty(kidia:kfdia) < 0) .or. any(ksoty(kidia:kfdia) > 7)) return
    ASSOCIATE (RCPD => YDCST%RCPD, RETV => YDCST%RETV, RLSTT => YDCST%RLSTT, &
     & RLVTT => YDCST%RLVTT, RTT => YDCST%RTT, &
     & LEOCSA => YDEXC%LEOCSA, &
     & LEVGEN => YDSOIL%LEVGEN, RQWEVAP => YDSOIL%RQWEVAP, RQWEVAPM => YDSOIL%RQWEVAPM, &
     & RTF1 => YDSOIL%RTF1, RTF2 => YDSOIL%RTF2, RTF3 => YDSOIL%RTF3, RTF4 => YDSOIL%RTF4, &
     & RWCAP => YDSOIL%RWCAP, RWCAPM => YDSOIL%RWCAPM, RWPWP => YDSOIL%RWPWP, &
     & RWPWPM => YDSOIL%RWPWPM, RWRESTM => YDSOIL%RWRESTM, &
     & LEAGS => YDVEG%LEAGS, LECTESSEL => YDVEG%LECTESSEL, RCEPSW => YDVEG%RCEPSW, &
     & LEFARQUHAR => YDVEG%LEFARQUHAR, LEAIRCO2COUP => YDVEG%LEAIRCO2COUP, &
     & RVHSTR => YDVEG%RVHSTR, RVLAI => YDVEG%RVLAI, RVROOTSA => YDVEG%RVROOTSA, &
     & RVRSMIN => YDVEG%RVRSMIN, RURBRES => YDURB%RURBRES)

      ZDSP(:) = 0.0_JPRB
      ZDMAXT(:) = 0.0_JPRB

      ZRVA = 5000._JPRB
      ZRVB = 10._JPRB
      ZEPSF3 = 0.00001_JPRB
      ZRSMINB = 50._JPRB
      ZRCLU = 50._JPRB

      ZEPSILON = EPSILON(ZEPSILON)

      IF (LEOCSA .AND. KTILE == 1) THEN
        ZSALIN = 0.98_JPRB
      ELSE
        ZSALIN = 1.0_JPRB
      END IF

      ZTSK(KIDIA:KFDIA) = PTSKM1M(KIDIA:KFDIA)
      IF (KTILE == 7) THEN
        WHERE (PFRTI(KIDIA:KFDIA, KTILE) <= ZEPSILON .AND. ZTSK(KIDIA:KFDIA) > RTT + 100._JPRB*ZEPSILON)
          ZTSK(KIDIA:KFDIA) = RTT
        END WHERE
      END IF
      DO JL = KIDIA, KFDIA
        PQS(JL) = FOEEW(ZTSK(JL))/PAPHMS(JL)
        ZCOR = ZSALIN/(1.0_JPRB - RETV*PQS(JL))
        if (.not. original_source_sea) zderivative_correction = 1.0_JPRB/(1.0_JPRB - RETV*PQS(JL))
        PQS(JL) = PQS(JL)*ZCOR
        if (original_source_sea) then
          PDQS(JL) = PQS(JL)*ZCOR*FOEDESU(ZTSK(JL))
        else
          PDQS(JL) = PQS(JL)*zderivative_correction*FOEDESU(ZTSK(JL))
        end if
      END DO

      IF (KTILE == 4) THEN

        DO JK = 1, KLEVS
          DO JL = KIDIA, KFDIA
            IF (PTSAM1M(JL, JK) < RTF1 .AND. PTSAM1M(JL, JK) > RTF2) THEN
              ZF = 0.5_JPRB*(1.0_JPRB - surface_sin(RTF4*(PTSAM1M(JL, JK) - RTF3)))
            ELSEIF (PTSAM1M(JL, JK) <= RTF2) THEN
              ZF = 1.0_JPRB
            ELSE
              ZF = 0.0_JPRB
            END IF
            IF (LEVGEN) THEN
              JS = KSOTY(JL)
              ZLIQ(JL, JK) = MAX(RWPWPM(JS), MIN(RWCAPM(JS), PWSAM1M(JL, JK)*(1.0_JPRB - ZF)))
              ZLIQR(JL, JK) = MAX(RWRESTM(JS), MIN(RWCAPM(JS), PWSAM1M(JL, JK)*(1.0_JPRB - ZF)))
            ELSE
              ZLIQ(JL, JK) = MAX(RWPWP, MIN(RWCAP, PWSAM1M(JL, JK)*(1.0_JPRB - ZF)))
              ZLIQR(JL, JK) = MAX(0.05_JPRB, MIN(RWCAP, PWSAM1M(JL, JK)*(1.0_JPRB - ZF)))
            END IF
          END DO
        END DO

        DO JL = KIDIA, KFDIA

          ZRSMINL = RVRSMIN(KTVL(JL))
          ZRSMINH = RVRSMIN(KTVH(JL))

          ZLAIL = PLAIL(JL)
          ZLAIH = PLAIH(JL)

          ZBARE = PFRTI(JL, 8)
          IF (KTILES .GT. 9) THEN
            ZBARE = PFRTI(JL, 8) + PFRTI(JL, 9)
          END IF
          ZWROOTL = 0.0_JPRB
          ZWROOTH = 0.0_JPRB
          DO JK = 1, KLEVS
            ZWROOTL = ZWROOTL + ZLIQ(JL, JK)*RVROOTSA(JK, KTVL(JL))
            ZWROOTH = ZWROOTH + ZLIQ(JL, JK)*RVROOTSA(JK, KTVH(JL))
          END DO
          IF (LEVGEN) THEN
            JS = KSOTY(JL)
            ZWPWP = RWPWPM(JS)
            ZQWEVAP = RQWEVAPM(JS)
            ZWPBARE = (RWPWPM(JS)*(1.0_JPRB - ZBARE) + RWRESTM(JS)*ZBARE)
            IF (JS >= 1) THEN
              ZQWEVAPBARE = 1._JPRB/(RWCAPM(JS) - ZWPBARE)
            ELSE
              ZQWEVAPBARE = 0._JPRB
            END IF
            ZF2B = MAX(RCEPSW, MIN(1.0_JPRB, (ZLIQR(JL, 1) - ZWPBARE)*ZQWEVAPBARE))
          ELSE
            ZWPWP = RWPWP
            ZQWEVAP = RQWEVAP
            ZWPBARE = (RWPWP*(1.0_JPRB - ZBARE) + 0.05_JPRB*ZBARE)
            ZQWEVAPBARE = 1._JPRB/(RWCAP - ZWPBARE)
            ZF2B = MAX(RCEPSW, MIN(1.0_JPRB, (ZLIQ(JL, 1) - ZWPWP)*ZQWEVAP))
          END IF

          IF (PTSAM1M(JL, 1) <= RTT) THEN
            ZF2L = RCEPSW
            ZF2H = RCEPSW
          ELSE
            ZF2L = MAX(RCEPSW, MIN(1.0_JPRB, (ZWROOTL - ZWPWP)*ZQWEVAP))
            ZF2H = MAX(RCEPSW, MIN(1.0_JPRB, (ZWROOTH - ZWPWP)*ZQWEVAP))
          END IF

          ZSRFL = PSRFD(JL)/250._JPRB
          ZF1L = 1.0_JPRB/MAX(1.0_JPRB, 0.81_JPRB*(1.+ZSRFL)/(ZSRFL + 0.05_JPRB))
          ZF1H = ZF1L

          ZHSTRL = RVHSTR(KTVL(JL))
          ZHSTRH = RVHSTR(KTVH(JL))
          ZQSAIR = FOEEW(PTMLEV(JL))/PAPHMS(JL)
          ZCOR = 1.0_JPRB/(1.0_JPRB - RETV*ZQSAIR)
          ZQSAIR = ZQSAIR*ZCOR
          ZF3L = surface_exp(-ZHSTRL*(ZQSAIR - PQMLEV(JL)))
          ZF3H = surface_exp(-ZHSTRH*(ZQSAIR - PQMLEV(JL)))
          ZF3L = MAX(ZEPSF3, MIN(1.0_JPRB, ZF3L))
          ZF3H = MAX(ZEPSF3, MIN(1.0_JPRB, ZF3H))

          IF (ZLAIL /= 0.0_JPRB) THEN
            PWETL(JL) = ZRSMINL/(ZLAIL*ZF1L*ZF2L*ZF3L)
          ELSE
            PWETL(JL) = 1.0E+6_JPRB
          END IF

          PWETLU(JL) = ZRCLU/(ZF1L*ZF3L)

          IF (ZLAIH /= 0.0_JPRB) THEN
            PWETH(JL) = ZRSMINH/(ZLAIH*ZF1H*ZF2H*ZF3H)
          ELSE
            PWETH(JL) = 1.0E+6_JPRB
          END IF

          PWETHS(JL) = PWETH(JL)
          PWETB(JL) = ZRSMINB/ZF2B

          PEXDIAG(JL, 1) = PWETL(JL)
          PEXDIAG(JL, 2) = ZF1L
          PEXDIAG(JL, 3) = ZF2L
          PEXDIAG(JL, 4) = ZF3L
          PEXDIAG(JL, 5) = ZLAIL
          PEXDIAG(JL, 6) = PWETH(JL)
          PEXDIAG(JL, 7) = ZF1H
          PEXDIAG(JL, 8) = ZF2H
          PEXDIAG(JL, 9) = ZF3H
          PEXDIAG(JL, 10) = ZLAIH
        END DO

      END IF

      IF (KTILE == 1 .OR. KTILE == 2 .OR. KTILE == 3 .OR. KTILE == 5 .OR. KTILE == 9) THEN
        DO JL = KIDIA, KFDIA
          PQSAM(JL) = PQS(JL)
        END DO
      ELSEIF (KTILE == 8) THEN
        DO JL = KIDIA, KFDIA
          PQSAM(JL) = PQS(JL) + MIN(0.0_JPRB, (PQMLEV(JL) - PQS(JL)))*PWETB(JL)/(PWETB(JL) + PRAQ(JL))
        END DO
      ELSEIF (KTILE == 4) THEN
        DO JL = KIDIA, KFDIA
          PQSAM(JL) = PQS(JL) + MIN(0.0_JPRB, (PQMLEV(JL) - PQS(JL)))*PWETL(JL)/(PWETL(JL) + PRAQ(JL))
        END DO
      ELSEIF (KTILE == 6) THEN
        DO JL = KIDIA, KFDIA
          PQSAM(JL) = PQS(JL) + MIN(0.0_JPRB, (PQMLEV(JL) - PQS(JL)))*PWETH(JL)/(PWETH(JL) + PRAQ(JL))
        END DO
      ELSEIF (KTILE == 10) THEN
        DO JL = KIDIA, KFDIA
          PQSAM(JL) = PQS(JL) + MIN(0.0_JPRB, (PQMLEV(JL) - PQS(JL)))*RURBRES/(RURBRES + PRAQ(JL))
        END DO
      ELSE
        DO JL = KIDIA, KFDIA
          PQSAM(JL) = PQS(JL) + MIN(0.0_JPRB, (PQMLEV(JL) - PQS(JL)))*PWETHS(JL)/(PWETHS(JL) + PRAQ(JL))
        END DO
      END IF

      IF (LECTESSEL) THEN
      IF (KTILE == 4 .OR. KTILE == 6 .OR. KTILE == 7 .OR. KTILE == 8 .OR. KTILE == 10) THEN

        DO JK = 1, KLEVS
          DO JL = KIDIA, KFDIA
            IF (PTSAM1M(JL, JK) < RTF1 .AND. PTSAM1M(JL, JK) > RTF2) THEN
              ZF = 0.5_JPRB*(1.0_JPRB - surface_sin(RTF4*(PTSAM1M(JL, JK) - RTF3)))
            ELSEIF (PTSAM1M(JL, JK) <= RTF2) THEN
              ZF = 1.0_JPRB
            ELSE
              ZF = 0.0_JPRB
            END IF
            IF (LEVGEN) THEN
              JS = KSOTY(JL)
              ZLIQ(JL, JK) = MAX(RWPWPM(JS), MIN(RWCAPM(JS), PWSAM1M(JL, JK)*(1.0_JPRB - ZF)))
              ZLIQR(JL, JK) = MAX(RWRESTM(JS), MIN(RWCAPM(JS), PWSAM1M(JL, JK)*(1.0_JPRB - ZF)))
            ELSE
              ZLIQ(JL, JK) = MAX(RWPWP, MIN(RWCAP, PWSAM1M(JL, JK)*(1.0_JPRB - ZF)))
              ZLIQR(JL, JK) = MAX(0.05_JPRB, MIN(RWCAP, PWSAM1M(JL, JK)*(1.0_JPRB - ZF)))
            END IF
          END DO
        END DO

        DO JL = KIDIA, KFDIA
          ZBARE = PFRTI(JL, 8)
          IF (KTILES .GT. 9) THEN
            ZBARE = PFRTI(JL, 8) + PFRTI(JL, 9)
          END IF
          ZWROOTL = 0.0_JPRB
          ZWROOTH = 0.0_JPRB
          DO JK = 1, KLEVS
            ZWROOTL = ZWROOTL + ZLIQ(JL, JK)*RVROOTSA(JK, KTVL(JL))
            ZWROOTH = ZWROOTH + ZLIQ(JL, JK)*RVROOTSA(JK, KTVH(JL))
          END DO
          IF (LEVGEN) THEN
            JS = KSOTY(JL)
            ZWPWP = RWPWPM(JS)
            ZQWEVAP = RQWEVAPM(JS)
            ZWPBARE = (RWPWPM(JS)*(1.0_JPRB - ZBARE) + RWRESTM(JS)*ZBARE)
            IF (JS >= 1) THEN
              ZQWEVAPBARE = 1._JPRB/(RWCAPM(JS) - ZWPBARE)
            ELSE
              ZQWEVAPBARE = 0._JPRB
            END IF
            ZF2B = MAX(RCEPSW, MIN(1.0_JPRB, (ZLIQR(JL, 1) - ZWPBARE)*ZQWEVAPBARE))
          ELSE
            ZWPWP = RWPWP
            ZQWEVAP = RQWEVAP
            ZWPBARE = (RWPWP*(1.0_JPRB - ZBARE) + 0.05_JPRB*ZBARE)
            ZQWEVAPBARE = 1._JPRB/(RWCAP - ZWPBARE)
            ZF2B = MAX(RCEPSW, MIN(1.0_JPRB, (ZLIQ(JL, 1) - ZWPWP)*ZQWEVAP))
          END IF

          IF (PTSAM1M(JL, 1) <= RTT) THEN
            ZF2L = RCEPSW
            ZF2H = RCEPSW
          ELSE
            ZF2L = MAX(RCEPSW, MIN(1.0_JPRB, (ZWROOTL - ZWPWP)*ZQWEVAP))
            ZF2H = MAX(RCEPSW, MIN(1.0_JPRB, (ZWROOTH - ZWPWP)*ZQWEVAP))
          END IF

          ZSRFL = PSRFD(JL)/250._JPRB
          ZF1L = 1.0_JPRB/MAX(1.0_JPRB, 0.81_JPRB*(1.+ZSRFL)/(ZSRFL + 0.05_JPRB))
          ZF1H = ZF1L
          ZHSTRL = RVHSTR(KTVL(JL))
          ZHSTRH = RVHSTR(KTVH(JL))
          ZQSAIR = FOEEW(PTMLEV(JL))/PAPHMS(JL)
          ZCOR = 1.0_JPRB/(1.0_JPRB - RETV*ZQSAIR)
          ZQSAIR = ZQSAIR*ZCOR
          ZF3L = surface_exp(-ZHSTRL*(ZQSAIR - PQMLEV(JL)))
          ZF3H = surface_exp(-ZHSTRH*(ZQSAIR - PQMLEV(JL)))
          ZF3L = MAX(ZEPSF3, MIN(1.0_JPRB, ZF3L))
          ZF3H = MAX(ZEPSF3, MIN(1.0_JPRB, ZF3H))
        END DO
      END IF

      IF (KTILE == 1 .OR. KTILE == 2 .OR. KTILE == 3 .OR. KTILE == 5 .OR. KTILE == 9) THEN
        DO JL = KIDIA, KFDIA
          DO JK = 1, KLEVS
            PPWLIQ(JL, JK) = 0.0_JPRB
          END DO
        END DO
      END IF

      IF (KTILE == 4 .OR. KTILE == 6 .OR. KTILE == 7 .OR. KTILE == 8 .OR. KTILE == 10) THEN

        DO JL = KIDIA, KFDIA
          ZWET(JL) = 0.0_JPRB
          ZF2(JL) = 1._JPRB
        END DO

        IF (KTILE == 4 .OR. KTILE == 6 .OR. KTILE == 7) THEN
          DO JL = KIDIA, KFDIA
            ZWROOT(JL) = 0._JPRB
            DO JK = 1, KLEVS
              ZWROOT(JL) = ZWROOT(JL) + ZLIQ(JL, JK)*RVROOTSA(JK, KVEG(JL, KTILE))
            END DO
            IF (LEVGEN) THEN
              JS = KSOTY(JL)
              ZWPWP = RWPWPM(JS)
              ZQWEVAP = RQWEVAPM(JS)
            ELSE
              ZWPWP = RWPWP
              ZQWEVAP = RQWEVAP
            END IF

            IF (PTSAM1M(JL, 1) <= RTT) THEN
              ZF2(JL) = RCEPSW
            ELSE
              ZF2(JL) = MAX(RCEPSW, MIN(1.0_JPRB, (ZWROOT(JL) - ZWPWP)*ZQWEVAP))
            END IF

            IF (KTILE == 4 .OR. KTILE == 6) THEN
              PDHVEGS(JL, JVTTL, 5) = ZF2(JL)
            END IF
          END DO

          DO JL = KIDIA, KFDIA
            DO JK = 1, KLEVS
              PPWLIQ(JL, JK) = ZLIQ(JL, JK)
            END DO
          END DO

          DO JL = KIDIA, KFDIA
            ZTSOIL(JL) = PTSAM1M(JL, 3)
          END DO

          CALL COTWORESTRESS(KIDIA, KFDIA, KLON, KVEG(:, KTILE), KCO2TYP, PFRTI,&
               & PTMLEV, PQMLEV, PCMLEV, PAPHMS,&
               & ZTSK, ZTSOIL,&
               & PEVAP, PLAI,&
               & PSRFD, PRAQ, PMU0,&
               & ZF2, PQS,&
               & YDCST, YDAGS, YDAGF, YDVEG, YDFLAKE, &
               & PAN, PAG, PRD,&
               & ZWET, ZDSP, ZDMAXT, child_status)
          if (child_status /= 0) then
            status = 100 + child_status
            return
          end if

          DO JL = KIDIA, KFDIA
            IF (PQMLEV(JL) > PQS(JL)) ZWET(JL) = 0.0_JPRB
            PDHVEGS(JL, JVTTL, 6) = ZDSP(JL)
            PDHVEGS(JL, JVTTL, 7) = ZDMAXT(JL)
          END DO
        END IF

        IF (KTILE == 8 .OR. KTILE == 10) THEN
          DO JL = KIDIA, KFDIA
            ZBARE = PFRTI(JL, 8)
            IF (KTILES .GT. 9) THEN
              ZBARE = PFRTI(JL, 8) + PFRTI(JL, 9)
            END IF
            IF (LEVGEN) THEN
              JS = KSOTY(JL)
              ZWPWP = RWPWPM(JS)
              ZQWEVAP = RQWEVAPM(JS)
              ZWPBARE = (RWPWPM(JS)*(1.0_JPRB - ZBARE) + RWRESTM(JS)*ZBARE)
              IF (JS >= 1) THEN
                ZQWEVAPBARE = 1._JPRB/(RWCAPM(JS) - ZWPBARE)
              ELSE
                ZQWEVAPBARE = 0._JPRB
              END IF
              ZF2B = MAX(RCEPSW, MIN(1.0_JPRB, (ZLIQR(JL, 1) - ZWPBARE)*ZQWEVAPBARE))
            ELSE
              ZWPWP = RWPWP
              ZQWEVAP = RQWEVAP
              ZWPBARE = (RWPWP*(1.0_JPRB - ZBARE) + 0.05_JPRB*ZBARE)
              ZQWEVAPBARE = 1._JPRB/(RWCAP - ZWPBARE)
              ZF2B = MAX(RCEPSW, MIN(1.0_JPRB, (ZLIQ(JL, 1) - ZWPWP)*ZQWEVAP))
            END IF
            ZWET(JL) = ZRSMINB/ZF2B
          END DO

        END IF
        IF (LEAGS) THEN
          IF (KTILE == 4) THEN
            DO JL = KIDIA, KFDIA
              PWETL(JL) = ZWET(JL)
            END DO
          ELSEIF (KTILE == 6) THEN
            DO JL = KIDIA, KFDIA
              PWETH(JL) = ZWET(JL)
            END DO
          ELSEIF (KTILE == 7) THEN
            DO JL = KIDIA, KFDIA
              PWETHS(JL) = ZWET(JL)
            END DO
          ELSEIF (KTILE == 8) THEN
            DO JL = KIDIA, KFDIA
              PWETB(JL) = ZWET(JL)
            END DO
          ELSEIF (KTILE == 10) THEN
            DO JL = KIDIA, KFDIA
              PWETB(JL) = ZWET(JL)
            END DO
          END IF
        END IF

      END IF

      IF (LEAGS) THEN
        DO JL = KIDIA, KFDIA
          IF (PQMLEV(JL) > PQS(JL)) ZWET(JL) = 0.0_JPRB
          IF (KTILE == 8 .OR. KTILE == 4 .OR. KTILE == 6 .OR. KTILE == 7 .OR. KTILE == 10) THEN
            PQSAM(JL) = PQS(JL) + (PQMLEV(JL) - PQS(JL))*ZWET(JL)/(ZWET(JL) + PRAQ(JL))
          ELSE
            PQSAM(JL) = PQS(JL)
          END IF
        END DO
      END IF
      END IF

      DO JL = KIDIA, KFDIA
        PCPTS(JL) = PTSKM1M(JL)*RCPD*(1.0_JPRB + ydthermal%rvtmp2*PQSAM(JL))
      END DO

    END ASSOCIATE
    status = 0
  contains
    real(real64) function foedelta(x) result(y)
      real(real64), intent(in) :: x
      y = max(0.0_real64, sign(1.0_real64, x - ydcst%rtt))
    end function
    real(real64) function foeew(x) result(y)
      real(real64), intent(in) :: x
      y = ydthermal%r2es*surface_exp((ydthermal%r3les*foedelta(x) + ydthermal%r3ies*(1.0_real64 - foedelta(x))) &
                                  *(x - ydcst%rtt)/(x - (ydthermal%r4les*foedelta(x) + ydthermal%r4ies*(1.0_real64 - foedelta(x)))))
    end function
    real(real64) function foedesu(x) result(y)
      real(real64), intent(in) :: x
      y = (foedelta(x)*ydthermal%r5les + (1.0_real64 - foedelta(x))*ydthermal%r5ies) &
          /(x - (ydthermal%r4les*foedelta(x) + ydthermal%r4ies*(1.0_real64 - foedelta(x))))**2
    end function

  end subroutine vsurf_core
end module
