!> Own complete selected radiation preparation on explicit native parameters.
!! Native surface parameter, clock, cloud and constant owners remain canonical.
!! Inputs use Pa, kelvin, kg/kg, metres and surface fractions as source named.
!! Scientific source attribution: ECMWF RADPAR.
module native_radiation_parameter_preparation
  use iso_fortran_env, only: JPIM => int32, JPRB => real64, JPRD => real64, int32, real64
  use yomhook, only: lhook, dr_hook, jphook
  use native_radiation_forecast_driver, only: native_radiation_driver_context
  use forecast_native_surface_boundary, only: surfbc
  use forecast_native_surface_radiation, only: surfrad
  use native_radiation_calendar_and_ice, only: updcal, icestatenemo
  use saturation_humidity_mod, only: satur
  use native_radiation_cloud_diagnostics, only: cldpp
  implicit none
  private
  public :: radpar
contains
!> Call surface boundary, calendar, surface radiation, saturation and cloud
!! diagnostics in frozen order. Status0 completes; nonzero stops propagation.
SUBROUTINE RADPAR ( context,KIDIA,  KFDIA,  KLON,   KLEVS, KLEVSN, KSTGLO, KTDIA,  KLEV,   KSTART, KSTEP, PAPRS,  PAPRSF, PT,     PQ  ,  PU    , PV, PL,     PI,     PA, PSNS,   PRSN, PTL,    PWL,    PWSA,   PVERVEL, PHLICE, PTLICE, PCLAKE, PALBF, PALCOEFF, PASN,   PEMISF, PLSM   , PMU0M,  PGEMU,  PGZ0MCL, PTVL,   PCO2TYP, PTVH,   PCVL,   PCVH ,PCUR, PLAILC, PLAIHC, PSOTY, PHSTD,  PCI, PNTOP,  PNBAS,  PACPR, LDLAND, PALBD,  PALBP,  PCCNL,  PCCNO, PNEB,   PQICE,  PQLI,   PQSAT, PCCC,   PHCC,   PLCC,   PMCC,   PTCC,   PSPECTRALEMISS, PEMIT, PGZ0M ,status)
    type(native_radiation_driver_context), intent(inout) :: context
    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEVS
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEVSN
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEV
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KSTGLO
    INTEGER(KIND=JPIM), INTENT(IN) :: KTDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KSTART
    INTEGER(KIND=JPIM), INTENT(IN) :: KSTEP
    REAL(KIND=JPRB), INTENT(IN) :: PAPRS(KLON, 0:KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PAPRSF(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PT(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PQ(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PU(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PV(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PL(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PI(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PA(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PSNS(KLON, KLEVSN)
    REAL(KIND=JPRB), INTENT(IN) :: PRSN(KLON, KLEVSN)
    REAL(KIND=JPRB), INTENT(IN) :: PTL(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PWL(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PWSA(KLON, KLEVS)
    REAL(KIND=JPRB), INTENT(IN) :: PVERVEL(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PHLICE(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PTLICE(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PCLAKE(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PALBF(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PALCOEFF(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PASN(KLON, KLEVSN)
    REAL(KIND=JPRB), INTENT(IN) :: PEMISF(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PLSM(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PMU0M(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PGEMU(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PGZ0MCL(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PTVH(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PTVL(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PCO2TYP(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PCVH(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PCVL(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PCUR(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PLAILC(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PLAIHC(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PSOTY(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PHSTD(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PCI(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PNTOP(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PNBAS(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PACPR(KLON)
    LOGICAL, INTENT(INOUT) :: LDLAND(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PALBD(KLON, context%setup%radiation%NTSW)
    REAL(KIND=JPRB), INTENT(INOUT) :: PALBP(KLON, context%setup%radiation%NTSW)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCCNL(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCCNO(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PNEB(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(INOUT) :: PQICE(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(INOUT) :: PQLI(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(INOUT) :: PQSAT(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCCC(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PHCC(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PLCC(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMCC(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTCC(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PSPECTRALEMISS(KLON, context%setup%radiation%NLWEMISS)
    REAL(KIND=JPRB), INTENT(INOUT) :: PEMIT(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PGZ0M(KLON)
    INTEGER(KIND=JPIM), volatile :: ITOPC(KLON), IBASC(KLON)
    INTEGER(KIND=JPIM) :: ITVH(KLON), ITVL(KLON), ISOTY(KLON), ICO2TYP(KLON)
    INTEGER(KIND=JPIM) :: ID0, IM0, IY0, IDINCR, ISEC, IDD, IMM, IYY, ILMON(12)
    LOGICAL :: LLSICE(KLON), LLNH(KLON)
    LOGICAL :: LLLAKE(KLON)
    LOGICAL :: LLOCN_KPP(KLON)
    REAL(KIND=JPRB) :: ZAZ0M(KLON), ZWLM1M(KLON)
    REAL(KIND=JPRB) :: ZHSTD(KLON), ZWLMX(KLON), ZALB(KLON), ZWND(KLON)
    REAL(KIND=JPRB) :: ZFRTI(KLON, context%physics_dimensions%NTILES), ZCVH(KLON), ZCVL(KLON), ZCUR(KLON)
    REAL(KIND=JPRB) :: ZALBTI(KLON, context%physics_dimensions%NTILES)
    REAL(KIND=JPRB) :: ZLAIL(KLON), ZLAIH(KLON)
    REAL(KIND=JPRB) :: ZPA(KLON, KLEV)
    REAL(KIND=JPRB) :: ZPL(KLON, KLEV)
    REAL(KIND=JPRB) :: ZPI(KLON, KLEV)
    REAL(KIND=JPRB) :: ZALBICE(KLON)
    REAL(KIND=JPRB) :: ZLAILI(KLON)
    REAL(KIND=JPRB) :: ZLAIHI(KLON)
    INTEGER(KIND=JPIM) :: IFLAG, JK, JL, JSW
    LOGICAL :: LLCLDCOVER
    REAL(KIND=JPHOOK) :: ZHOOK_HANDLE
    integer(int32), intent(out) :: status
    integer(int32) :: child_status
    status = 2
    if (.not. associated(context%configuration) .or. .not. associated(context%surface_parameters)) return
    if (.not. associated(context%constants) .or. .not. associated(context%thermal) .or. .not. associated(context%time)) return
if(.not.associated(context%setup).or..not.associated(context%physics_dimensions).or..not.associated(context%cloud_parameters))return
    if (context%configuration%ecmwf_physics%LEDCLD .and. .not. context%configuration%ecmwf_physics%LEPCLD) return
    IF (LHOOK) CALL DR_HOOK('RADPAR', 0, ZHOOK_HANDLE)
    LLOCN_KPP(:) = .FALSE.
    ZLAILI(:) = 0.0_JPRB
    ZLAIHI(:) = 0.0_JPRB
    IF (KSTEP == KSTART) THEN
      PNTOP(KIDIA:KFDIA) = 1.0_JPRB
      PNBAS(KIDIA:KFDIA) = 1.0_JPRB
      PACPR(KIDIA:KFDIA) = 0.0_JPRB
      PGZ0M(KIDIA:KFDIA) = PGZ0MCL(KIDIA:KFDIA)
    END IF
    DO JL = KIDIA, KFDIA
    IF (PLSM(JL) > 0.5_JPRB) THEN
      ZHSTD(JL) = PHSTD(JL)/context%constants%RG
    ELSE
      ZHSTD(JL) = 0._JPRB
    END IF
    END DO
    ZAZ0M(KIDIA:KFDIA) = PGZ0M(KIDIA:KFDIA)/context%constants%RG
    ZWLM1M(KIDIA:KFDIA) = PWL(KIDIA:KFDIA)
CALL SURFBC (YDSURF=context%surface_parameters,KIDIA=KIDIA,KFDIA=KFDIA,KLON=KLON,KTILES=context%physics_dimensions%NTILES,KLEVSN=context%physics_dimensions%NCSNEC, PTVL=PTVL,PCO2TYP=PCO2TYP,PTVH=PTVH,PSOTY=PSOTY,PSDOR=ZHSTD,PCVLC=PCVL,PCVHC=PCVH,PCURC=PCUR, PLAILC=PLAILC,PLAIHC=PLAIHC,PLAILI=ZLAILI,PLAIHI=ZLAIHI, PLSM=PLSM,PCI=PCI,PCLAKE=PCLAKE,PHLICE=PHLICE, PGEMU=PGEMU,PSNM1M=PSNS,PWLM1M=ZWLM1M,PRSNM1M=PRSN, LDLAND=LDLAND,LDSICE=LLSICE,LDLAKE=LLLAKE,LDNH=LLNH,LDOCN_KPP=LLOCN_KPP, KTVL=ITVL,KCO2TYP=ICO2TYP,KTVH=ITVH,KSOTY=ISOTY, PCVL=ZCVL,PCVH=ZCVH,PCUR=ZCUR,PLAIL=ZLAIL,PLAIH=ZLAIH, PWLMX=ZWLMX,PFRTI=ZFRTI,status=child_status)
    if (child_status /= 0) then; status = child_status; return; end if
    DO JL = KIDIA, KFDIA
      ITOPC(JL) = INT(PNTOP(JL) + 0.01_JPRB)
      IBASC(JL) = INT(PNBAS(JL) + 0.01_JPRB)
    END DO
    IF (context%configuration%ecmwf_physics%LERADS) THEN
    DO JL = KIDIA, KFDIA
      ZWND(JL) = SQRT(PU(JL, KLEV)*PU(JL, KLEV) + PV(JL, KLEV)*PV(JL, KLEV))
    END DO
    IY0 = context%initial_date/10000
    IM0 = MOD(context%initial_date/100, 100)
    ID0 = MOD(context%initial_date, 100)
    IDINCR = (context%initial_seconds + NINT(context%time%RSTATI))/NINT(context%constants%RDAY)
    ISEC = MOD(context%initial_seconds + NINT(context%time%RSTATI), NINT(context%constants%RDAY))
    ZALBICE(KIDIA:KFDIA) = 0.0_JPRB
    IF (context%sea_ice_albedo_enabled) THEN
      CALL ICESTATENEMO(context%sea_ice, KSTGLO, KIDIA, KFDIA, albedo=ZALBICE(KIDIA:KFDIA))
    END IF
    CALL UPDCAL(ID0, IM0, IY0, IDINCR, IDD, IMM, IYY, ILMON, -1)
CALL SURFRAD(YDSURF=context%surface_parameters,KDD=IDD,KMM=IMM,KMON=ILMON,KSECO=ISEC, KIDIA=KIDIA,KFDIA=KFDIA,KLON=KLON,KTILES=context%physics_dimensions%NTILES,KSW=context%setup%radiation%NSW,KLW=context%setup%radiation%NLWEMISS, LDNH=LLNH, PALBF=PALBF,PALBICEF=ZALBICE,PTVH=PTVH, PALCOEFF=PALCOEFF,PCURC=PCUR,PCVH=PCVH, PASN=PASN(:,1),PMU0=PMU0M,PTS=PTL,PWND=ZWND, PWS1=PWSA(:,1),KSOTY=ISOTY,PFRTI=ZFRTI,PHLICE=PHLICE,PTLICE=PTLICE, PALBD=PALBD(:,1:context%setup%radiation%NSW),PALBP=PALBP(:,1:context%setup%radiation%NSW),PALB=ZALB, PSPECTRALEMISS=PSPECTRALEMISS,PEMIT=PEMIT, PALBTI=ZALBTI,PCCNL=PCCNL,PCCNO=PCCNO,LNEMOLIMALB=context%sea_ice_albedo_enabled ,status=child_status)
    if (child_status /= 0) then; status = child_status; return; end if
    DO JSW = context%setup%radiation%NSW + 1, context%setup%radiation%NTSW
      PALBD(KIDIA:KFDIA, JSW) = PALBF(KIDIA:KFDIA)
      PALBP(KIDIA:KFDIA, JSW) = PALBF(KIDIA:KFDIA)
    END DO
    ELSE
    DO JSW = 1, context%setup%radiation%NTSW
    DO JL = KIDIA, KFDIA
      PALBD(JL, JSW) = PALBF(JL)
      PALBP(JL, JSW) = PALBF(JL)
    END DO
    END DO
    DO JL = KIDIA, KFDIA
      PSPECTRALEMISS(JL, :) = PEMISF(JL)
      PEMIT(JL) = PEMISF(JL)
      PCCNL(JL) = context%setup%radiation%RCCNLND
      PCCNO(JL) = context%setup%radiation%RCCNSEA
    END DO
    END IF
    IFLAG = 2
child_status=satur(context%constants,context%thermal,KIDIA , KFDIA , KLON  , KTDIA , KLEV, context%configuration%linear_ecmwf%LPHYLIN, PAPRSF, PT    , PQSAT , IFLAG)
    if (child_status /= 0) then; status = child_status; return; end if
    LLCLDCOVER = (context%setup%radiation%NRADPFR /= 0)
    IF (context%configuration%ecmwf_physics%LEDCLD) THEN
CALL  CLDPP (context%constants, context%setup%ecrad%config,context%setup%radiation,context%setup%gases,context%cloud_parameters,context%time, KIDIA , KFDIA , KLON   , KLEV, PAPRS , PAPRSF, PA    , PL     , PI    , PT, PGEMU, PGEMU, LLCLDCOVER  , PCCC  , PHCC  , PLCC   , PMCC  , PTCC, PNEB  , PQICE , PQLI )
      DO JL = KIDIA, KFDIA
        IBASC(JL) = 1
        ITOPC(JL) = 1
      END DO
    ELSE
      DO JK = 1, KLEV
      DO JL = KIDIA, KFDIA
        PNEB(JL, JK) = 0.0_JPRB
        PQLI(JL, JK) = 0.0_JPRB
        PQICE(JL, JK) = 0.0_JPRB
      END DO
      END DO
      DO JL = KIDIA, KFDIA
        PCCC(JL) = 0.0_JPRB
        PHCC(JL) = 0.0_JPRB
        PLCC(JL) = 0.0_JPRB
        PMCC(JL) = 0.0_JPRB
        PTCC(JL) = 0.0_JPRB
      END DO
    END IF
    status = 0
  end subroutine radpar
end module
