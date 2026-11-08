! (C) Copyright1989- ECMWF and Meteo-France. Apache Licence Version2.0.
!> Own the complete selected CPU physics diagnostics and accumulated fields.
!! Pressure is Pa, wind is m/s, temperature is kelvin, and flux is W/m2.
!! Time and output selectors borrow their actual produced native targets.
!! Only active columns change; all arrays retain native Fortran strides.
!! Composition counts and satellite count are zero in this selected branch.
module forecast_native_post_physics_diagnostics
  use iso_fortran_env, only: JPIM => int32, JPRB => real64, int32, real64
  use yomhook, only: lhook, dr_hook, jphook
  use yom_grib_codes, only: NGRBMX2T, NGRBMN2T, NGRB10FG, NGRBMXTPR, NGRBMNTPR, NGRBCAPES, NGRBMXCAPS6
  use forecast_complete_physics_context_types, only: native_complete_physics_context, native_complete_physics_driver_inputs
  use forecast_native_post_physics_control_targets, only: post_control_targets_ready
  use forecast_column_ozone_mass, only: integrate_column_ozone_mass
  use md2asm_geopotential_and_column_water, only: integrate_column_water
  use forecast_surface_temperature_extrapolation, only: ctstar
  use forecast_native_mean_sea_level_pressure, only: pppmer
  use forecast_native_cape_wind_diagnostics, only: capeshear
  implicit none
  private
  integer(int32), parameter :: NPRECTYPES = 12
  public :: cpedia
contains
integer(int32) function cpedia(context,inputs,pgfl_fields,KPROMA,KIDIA,KFDIA,KFLEVG,KSATSIM,LDFSTEP,LDMLPP,LDRS6,LDRSACC,LDACCRS,PGELAM,PGELAT,PFPLCL,PFPLCN,PFPLSL,PFPLSN,PFRSO,PFRSOD,PFRSODC,PFRTH,PFRTHD,PFRTHDC,PUVDF,PPARF,PCAPE,PPARCF,PTINCF,PFDIR,PDSRP,PCDIR,PCBASE,PPDEPL,P0DEGL,PM10DEGL,PVISIH,PCIN,PCONVIND,PLIGH_TOT,PLIGH_CTG,PCBASEA,PCTOPC,PTROPOTP,PZTWETB,PDIFTS,PDIFTQ,PSTRTU,PSTRTV,PFCLL,PFCLN,PTCLS,PQCLS,PUCLS,PVCLS,PTRENU,PQLINU,PLSM,PCI,PISUND,PVDIS,PVDISG,PUSTRG,PVSTRG,PRUISS,PRUISP,PINEE,PIGPP,PIREC,PRESH,PRESF,PDELP,PU,PV,PT,PGHG,PCHEM,PAERO,PTENQ,POROG,PDLSP,PDCP,PDSF,PDFZRA,PDBLD,PSUND,PITTRC,PITSRC,PISTRC,PISSRC,PIES,PISMLT,PI10FG,PILSPF,PPRECTYPE,PFZRA,PIVIMD,PEVAPMU,PVTTRC,PVTSRC,PVSTRC,PVSSRC,PVES,PVSMLT,PV10FG,PV10FG6,PVI10FG,PVLSPF,PVVIMD,PDSSHF,PDSLHF,PDSP,PDMSL,PDSSR,PDSTR,PDSSRD,PDSTRD,PDSSRDC,PDSTRDC,PDTSR,PDTTR,PDUVDF,PDPARF,PDCAPE,PDCAPES,PDMXCAP6,PDMXCAPS6,PDPARCF,PDTINCF,PDFDIR,PDDSRP,PDCDIR,PDCBASE,PD0DEGL,PDM10DEGL,PDVISIH,PDCIN,PDKINDEX,PDTTINDEX,PDPDEPL,PDMUCAPE,PDMLCAPE50,PDMLCAPE100,PDMLCIN50,PDMLCIN100,PDCBASEA,PDCTOPC,PDTROPOTP,PDZTWETB0,PDZTWETB1,PDEWSS,PDNSSS,PDE,PDPEV,PDLGWS,PDMGWS,PDGWD,PDMX2T,PDMN2T,PDMX2T6,PDMN2T6,PDRO,PDSSRO,PDSRO,PDNEE,PDGPP,PDREC,PDCSF,PDLSSF,PDMXTPR,PDMNTPR,PDMXTPR6,PDMNTPR6,PDTPR,PDLSRR,PDCRR,PDLSSFR,PDCSFR,PDPTYPE,PVILSPF,PDIEWSS,PDINSSS,PDISSHF,PDIE,PDVIWVE,PDVIWVN,PDTCW,PDTCWV,PDTCLW,PDTCIW,PDTCRW,PDTCSW,PDTCSLW,PDTCO3,PDTCGHG,PDTCCHEM,PDTCAERO,PDLITOTI,PDLITOTA6,PDLICGI,PDLICGA6,PDPTYPEOCC6,PDCLBT,PDCSBT)result(status)
    type(native_complete_physics_context), intent(inout) :: context
    type(native_complete_physics_driver_inputs), intent(inout) :: inputs
    INTEGER(KIND=JPIM), INTENT(IN) :: KPROMA
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFLEVG
    INTEGER(KIND=JPIM), INTENT(IN) :: KSATSIM
    LOGICAL, INTENT(IN) :: LDFSTEP
    LOGICAL, INTENT(IN) :: LDMLPP
    LOGICAL, INTENT(IN) :: LDRSACC
    LOGICAL, INTENT(IN) :: LDACCRS
    LOGICAL, INTENT(IN) :: LDRS6
    REAL(KIND=JPRB), INTENT(IN) :: PGELAM(:)
    REAL(KIND=JPRB), INTENT(IN) :: PGELAT(:)
    REAL(KIND=JPRB), INTENT(IN) :: PFPLCL(:, 0:)
    REAL(KIND=JPRB), INTENT(IN) :: PFPLCN(:, 0:)
    REAL(KIND=JPRB), INTENT(IN) :: PFPLSL(:, 0:)
    REAL(KIND=JPRB), INTENT(IN) :: PFPLSN(:, 0:)
    REAL(KIND=JPRB), INTENT(IN) :: PFZRA(:)
    REAL(KIND=JPRB), INTENT(IN) :: PFRSO(:, 0:)
    REAL(KIND=JPRB), INTENT(IN) :: PFRSOD(:)
    REAL(KIND=JPRB), INTENT(IN) :: PFRSODC(:)
    REAL(KIND=JPRB), INTENT(IN) :: PFRTH(:, 0:)
    REAL(KIND=JPRB), INTENT(IN) :: PFRTHD(:)
    REAL(KIND=JPRB), INTENT(IN) :: PFRTHDC(:)
    REAL(KIND=JPRB), INTENT(IN) :: PUVDF(:)
    REAL(KIND=JPRB), INTENT(IN) :: PPARF(:)
    REAL(KIND=JPRB), INTENT(IN) :: PCAPE(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PPDEPL(:)
    REAL(KIND=JPRB), INTENT(IN) :: PPARCF(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTINCF(:)
    REAL(KIND=JPRB), INTENT(IN) :: PCIN(:, :), PCONVIND(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PLIGH_TOT(:)
    REAL(KIND=JPRB), INTENT(IN) :: PCBASE(:), PVISIH(:)
    REAL(KIND=JPRB), INTENT(IN) :: P0DEGL(:), PM10DEGL(:)
    REAL(KIND=JPRB), INTENT(IN) :: PLIGH_CTG(:)
    REAL(KIND=JPRB), INTENT(IN) :: PCBASEA(:), PCTOPC(:), PZTWETB(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PTROPOTP(:)
    REAL(KIND=JPRB), INTENT(IN) :: PFDIR(:), PDSRP(:), PCDIR(:)
    REAL(KIND=JPRB), INTENT(IN) :: PDIFTS(:, 0:)
    REAL(KIND=JPRB), INTENT(IN) :: PDIFTQ(:, 0:)
    REAL(KIND=JPRB), INTENT(IN) :: PSTRTU(:, 0:)
    REAL(KIND=JPRB), INTENT(IN) :: PSTRTV(:, 0:)
    REAL(KIND=JPRB), INTENT(IN) :: PFCLL(:)
    REAL(KIND=JPRB), INTENT(IN) :: PFCLN(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTCLS(:)
    REAL(KIND=JPRB), INTENT(IN) :: PQCLS(:)
    REAL(KIND=JPRB), INTENT(IN) :: PUCLS(:)
    REAL(KIND=JPRB), INTENT(IN) :: PVCLS(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTRENU(:)
    REAL(KIND=JPRB), INTENT(IN) :: PQLINU(:)
    REAL(KIND=JPRB), INTENT(IN) :: PLSM(:)
    REAL(KIND=JPRB), INTENT(IN) :: PCI(:)
    REAL(KIND=JPRB), INTENT(IN) :: PISUND(:)
    REAL(KIND=JPRB), INTENT(IN) :: PVDIS(:)
    REAL(KIND=JPRB), INTENT(IN) :: PVDISG(:)
    REAL(KIND=JPRB), INTENT(IN) :: PUSTRG(:)
    REAL(KIND=JPRB), INTENT(IN) :: PVSTRG(:)
    REAL(KIND=JPRB), INTENT(IN) :: PRUISS(:)
    REAL(KIND=JPRB), INTENT(IN) :: PRUISP(:)
    REAL(KIND=JPRB), INTENT(IN) :: PINEE(:)
    REAL(KIND=JPRB), INTENT(IN) :: PIGPP(:)
    REAL(KIND=JPRB), INTENT(IN) :: PIREC(:)
    REAL(KIND=JPRB), INTENT(IN) :: PRESH(:, 0:)
    REAL(KIND=JPRB), INTENT(IN) :: PRESF(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PDELP(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PU(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PV(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PT(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PGHG(:, :, :)
    REAL(KIND=JPRB), INTENT(IN) :: PCHEM(:, :, :)
    REAL(KIND=JPRB), INTENT(IN) :: PAERO(:, :, :)
    REAL(KIND=JPRB), INTENT(IN) :: PTENQ(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: POROG(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDLSP(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDCP(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDSF(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDFZRA(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDBLD(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PSUND(:)
    REAL(KIND=JPRB), INTENT(IN) :: PITTRC(:)
    REAL(KIND=JPRB), INTENT(IN) :: PITSRC(:)
    REAL(KIND=JPRB), INTENT(IN) :: PISTRC(:)
    REAL(KIND=JPRB), INTENT(IN) :: PISSRC(:)
    REAL(KIND=JPRB), INTENT(IN) :: PIES(:)
    REAL(KIND=JPRB), INTENT(IN) :: PISMLT(:)
    REAL(KIND=JPRB), INTENT(IN) :: PI10FG(:)
    REAL(KIND=JPRB), INTENT(IN) :: PILSPF(:)
    REAL(KIND=JPRB), INTENT(IN) :: PPRECTYPE(:)
    REAL(KIND=JPRB), INTENT(IN) :: PEVAPMU(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PIVIMD(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PVTTRC(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PVTSRC(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PVSTRC(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PVSSRC(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PVES(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PVSMLT(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PV10FG(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PV10FG6(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PVI10FG(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PVLSPF(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDSSHF(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDSLHF(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PVVIMD(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDSP(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDMSL(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDSSR(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDSTR(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDSSRD(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDSTRD(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDSSRDC(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDSTRDC(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDTSR(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDTTR(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDUVDF(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDPARF(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDCAPE(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDPDEPL(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDMUCAPE(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDMLCAPE50(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDMLCAPE100(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDCAPES(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDMXCAP6(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDMXCAPS6(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDPARCF(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDTINCF(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDCIN(:), PDKINDEX(:), PDTTINDEX(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDMLCIN50(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDMLCIN100(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDCBASEA(:), PDCTOPC(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDCBASE(:), PDVISIH(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDTROPOTP(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PD0DEGL(:), PDM10DEGL(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDZTWETB0(:), PDZTWETB1(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDFDIR(:), PDDSRP(:), PDCDIR(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDEWSS(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDNSSS(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDE(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDPEV(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDLGWS(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDMGWS(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDGWD(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDMX2T(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDMN2T(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDMX2T6(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDMN2T6(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDRO(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDSRO(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDSSRO(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDNEE(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDGPP(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDREC(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDCSF(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDLSSF(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDMXTPR(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDMNTPR(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDMXTPR6(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDMNTPR6(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDTPR(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDLSRR(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDCRR(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDLSSFR(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDCSFR(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDPTYPE(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PVILSPF(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDIEWSS(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDINSSS(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDISSHF(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDIE(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDVIWVE(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDVIWVN(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDTCW(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDTCWV(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDTCLW(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDTCIW(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDTCRW(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDTCSW(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDTCSLW(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDTCO3(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDTCGHG(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDTCCHEM(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDTCAERO(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDLITOTI(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDLITOTA6(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDLICGI(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDLICGA6(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDPTYPEOCC6(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDCLBT(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDCSBT(:, :)
    REAL(KIND=JPRB) :: ZTB(KPROMA), ZPRESBH(KPROMA), ZPRESBF(KPROMA)
    REAL(KIND=JPRB) :: ZTSTAR(KPROMA), ZT0(KPROMA), ZCAPES(KPROMA)
    REAL(KIND=JPRB) :: ZWCH(KPROMA, 0:KFLEVG)
    REAL(KIND=JPRB) :: ZWVLI(KPROMA, KFLEVG)
    REAL(KIND=JPRB) :: ZCLD(KPROMA, KFLEVG)
    REAL(KIND=JPRB) :: ZTOTPREC
    INTEGER(KIND=JPIM) :: IMN2T, IMX2T, I10FG, IMNTPR, IMXTPR, ICAPES, IMXCAPS6
    INTEGER(KIND=JPIM) :: ICLBT, ICSBT, IPRECTYPE
    INTEGER(KIND=JPIM) :: JK, JROF, JGHG, JCHEM, JAERO
    LOGICAL :: LLMN2TPP, LLMX2TPP, LL10FGPP, LLMNTPRPP, LLMXTPRPP, LLCAPES
    REAL(KIND=JPRB) :: ZTSTEP, ZTSTEP_IN_HOURS
    REAL(KIND=JPHOOK) :: ZHOOK_HANDLE
    real(real64), target, intent(in) :: pgfl_fields(:, :, :)
    real(real64),pointer::PQ(:,:)=>null(),PO3(:,:)=>null(),PL(:,:)=>null(),PR(:,:)=>null(),PI(:,:)=>null(),PS(:,:)=>null()
    logical :: ice_active, liquid_active, rain_active, snow_active, ozone_active
    integer :: indices(6), i, plane
    status = 2
    if (.not. associated(inputs%post_controls)) return
    if (.not. post_control_targets_ready(inputs%post_controls)) return
    if (.not. associated(inputs%providers)) return
    if (.not. associated(inputs%providers%physical)) return
    if (.not. associated(inputs%physics)) return
    if (.not. associated(inputs%records%model)) return
    if (.not. associated(inputs%solar_clock%tstep)) return
    if (KPROMA < 1 .or. KPROMA > 24 .or. KFLEVG /= 19 .or. KSATSIM /= 0) return
    if (KIDIA < 1 .or. KFDIA > KPROMA .or. KFDIA < KIDIA - 1) return
    if (inputs%post_controls%nlextrap < 1 .or. inputs%post_controls%nlextrap > KFLEVG) return
if(inputs%records%model%fields%alias_controls%nghg/=0.or.inputs%records%model%fields%settings%nchem_tc/=0.or.inputs%records%model%fields%settings%nactaero/=0)return
indices=[inputs%records%model%fields%aliases%yi,inputs%records%model%fields%aliases%yl,inputs%records%model%fields%aliases%yr,inputs%records%model%fields%aliases%ys,inputs%records%model%fields%aliases%yo3,inputs%records%model%fields%aliases%yq]
    if (any(indices < 1) .or. any(indices > size(inputs%records%model%fields%components))) return
    ice_active = inputs%records%model%fields%components(indices(1))%lactive /= 0
    liquid_active = inputs%records%model%fields%components(indices(2))%lactive /= 0
    rain_active = inputs%records%model%fields%components(indices(3))%lactive /= 0
    snow_active = inputs%records%model%fields%components(indices(4))%lactive /= 0
    ozone_active = inputs%records%model%fields%components(indices(5))%lactive /= 0
    if (size(pgfl_fields, 1) /= KPROMA .or. size(pgfl_fields, 2) /= KFLEVG) return
    if (LDMLPP) then
      plane = inputs%records%model%fields%components(indices(6))%mp9_ph
      if (plane < 1 .or. plane > size(pgfl_fields, 3)) return
      PQ => pgfl_fields(:, :, plane)
    end if
    if (LDMLPP .and. ice_active) then
      plane = inputs%records%model%fields%components(indices(1))%mp9_ph
      if (plane < 1 .or. plane > size(pgfl_fields, 3)) return
      PI => pgfl_fields(:, :, plane)
    end if
    if (LDMLPP .and. liquid_active) then
      plane = inputs%records%model%fields%components(indices(2))%mp9_ph
      if (plane < 1 .or. plane > size(pgfl_fields, 3)) return
      PL => pgfl_fields(:, :, plane)
    end if
    if (LDMLPP .and. rain_active) then
      plane = inputs%records%model%fields%components(indices(3))%mp9_ph
      if (plane < 1 .or. plane > size(pgfl_fields, 3)) return
      PR => pgfl_fields(:, :, plane)
    end if
    if (LDMLPP .and. snow_active) then
      plane = inputs%records%model%fields%components(indices(4))%mp9_ph
      if (plane < 1 .or. plane > size(pgfl_fields, 3)) return
      PS => pgfl_fields(:, :, plane)
    end if
    if (LDMLPP .and. ozone_active) then
      plane = inputs%records%model%fields%components(indices(5))%mp9_ph
      if (plane < 1 .or. plane > size(pgfl_fields, 3)) return
      PO3 => pgfl_fields(:, :, plane)
    end if
    IF (LHOOK) CALL DR_HOOK('CPEDIA', 0, ZHOOK_HANDLE)
    ZTSTEP = inputs%solar_clock%tstep
    ZTSTEP_IN_HOURS = inputs%solar_clock%tstep/3600._JPRB
    status = integrate_column_ozone_mass(inputs%providers%physical%rg, KPROMA, KIDIA, KFDIA, KFLEVG, PDELP, PTENQ, PIVIMD)
    if (status /= 0) return
    IF ((LDRSACC .AND. (LDFSTEP .OR. LDMLPP)) .OR. LDACCRS) THEN
    DO JROF = KIDIA, KFDIA
      PDCP(JROF) = (PFPLCL(JROF, KFLEVG) + PFPLCN(JROF, KFLEVG))*ZTSTEP
      PDLSP(JROF) = (PFPLSL(JROF, KFLEVG) + PFPLSN(JROF, KFLEVG))*ZTSTEP
      PDSF(JROF) = (PFPLCN(JROF, KFLEVG) + PFPLSN(JROF, KFLEVG))*ZTSTEP
      PDFZRA(JROF) = PFZRA(JROF)*ZTSTEP
      PDCSF(JROF) = PFPLCN(JROF, KFLEVG)*ZTSTEP
      PDLSSF(JROF) = PFPLSN(JROF, KFLEVG)*ZTSTEP
      PDSLHF(JROF) = (PFCLL(JROF) + PFCLN(JROF))*ZTSTEP
      PDSSHF(JROF) = PDIFTS(JROF, KFLEVG)*ZTSTEP
      PDE(JROF) = PDIFTQ(JROF, KFLEVG)*ZTSTEP
      PDPEV(JROF) = PEVAPMU(JROF)*ZTSTEP
      PDBLD(JROF) = PVDIS(JROF)*ZTSTEP
      PDEWSS(JROF) = PSTRTU(JROF, KFLEVG)*ZTSTEP
      PDNSSS(JROF) = PSTRTV(JROF, KFLEVG)*ZTSTEP
      PDGWD(JROF) = PVDISG(JROF)*ZTSTEP
      PDLGWS(JROF) = PUSTRG(JROF)*ZTSTEP
      PDMGWS(JROF) = PVSTRG(JROF)*ZTSTEP
      PDRO(JROF) = (PRUISS(JROF) + PRUISP(JROF))*ZTSTEP
      PDSSRO(JROF) = (PRUISP(JROF))*ZTSTEP
      PDSRO(JROF) = (PRUISS(JROF))*ZTSTEP
      PDNEE(JROF) = (PINEE(JROF))*ZTSTEP
      PDGPP(JROF) = (PIGPP(JROF))*ZTSTEP
      PDREC(JROF) = (PIREC(JROF))*ZTSTEP
      PDSSR(JROF) = PFRSO(JROF, KFLEVG)*ZTSTEP
      PDSSRD(JROF) = PFRSOD(JROF)*ZTSTEP
      PDSSRDC(JROF) = PFRSODC(JROF)*ZTSTEP
      PDSTR(JROF) = PFRTH(JROF, KFLEVG)*ZTSTEP
      PDSTRD(JROF) = PFRTHD(JROF)*ZTSTEP
      PDSTRDC(JROF) = PFRTHDC(JROF)*ZTSTEP
      PDTSR(JROF) = PFRSO(JROF, 0)*ZTSTEP
      PDTTR(JROF) = PFRTH(JROF, 0)*ZTSTEP
      PSUND(JROF) = PISUND(JROF)*ZTSTEP
      PDUVDF(JROF) = PUVDF(JROF)*ZTSTEP
      PDPARF(JROF) = PPARF(JROF)*ZTSTEP
      PDPARCF(JROF) = PPARCF(JROF)*ZTSTEP
      PDTINCF(JROF) = PTINCF(JROF)*ZTSTEP
      PDFDIR(JROF) = PFDIR(JROF)*ZTSTEP
      PDCDIR(JROF) = PCDIR(JROF)*ZTSTEP
      PDDSRP(JROF) = PDSRP(JROF)*ZTSTEP
      PVTTRC(JROF) = PITTRC(JROF)*ZTSTEP
      PVTSRC(JROF) = PITSRC(JROF)*ZTSTEP
      PVSTRC(JROF) = PISTRC(JROF)*ZTSTEP
      PVSSRC(JROF) = PISSRC(JROF)*ZTSTEP
      PVES(JROF) = PIES(JROF)*ZTSTEP
      PVSMLT(JROF) = PISMLT(JROF)*ZTSTEP
      PVLSPF(JROF) = PILSPF(JROF)*ZTSTEP
      PVVIMD(JROF) = PIVIMD(JROF)*ZTSTEP
    END DO
    ELSE
    DO JROF = KIDIA, KFDIA
      PDCP(JROF) = PDCP(JROF) + (PFPLCL(JROF, KFLEVG) + PFPLCN(JROF, KFLEVG))*ZTSTEP
      PDLSP(JROF) = PDLSP(JROF) + (PFPLSL(JROF, KFLEVG) + PFPLSN(JROF, KFLEVG))*ZTSTEP
      PDSF(JROF) = PDSF(JROF) + (PFPLCN(JROF, KFLEVG) + PFPLSN(JROF, KFLEVG))*ZTSTEP
      PDFZRA(JROF) = PDFZRA(JROF) + PFZRA(JROF)*ZTSTEP
      PDCSF(JROF) = PDCSF(JROF) + PFPLCN(JROF, KFLEVG)*ZTSTEP
      PDLSSF(JROF) = PDLSSF(JROF) + PFPLSN(JROF, KFLEVG)*ZTSTEP
      PDSLHF(JROF) = PDSLHF(JROF) + (PFCLL(JROF) + PFCLN(JROF))*ZTSTEP
      PDSSHF(JROF) = PDSSHF(JROF) + PDIFTS(JROF, KFLEVG)*ZTSTEP
      PDE(JROF) = PDE(JROF) + PDIFTQ(JROF, KFLEVG)*ZTSTEP
      PDPEV(JROF) = PDPEV(JROF) + PEVAPMU(JROF)*ZTSTEP
      PDBLD(JROF) = PDBLD(JROF) + PVDIS(JROF)*ZTSTEP
      PDEWSS(JROF) = PDEWSS(JROF) + PSTRTU(JROF, KFLEVG)*ZTSTEP
      PDNSSS(JROF) = PDNSSS(JROF) + PSTRTV(JROF, KFLEVG)*ZTSTEP
      PDGWD(JROF) = PDGWD(JROF) + PVDISG(JROF)*ZTSTEP
      PDLGWS(JROF) = PDLGWS(JROF) + PUSTRG(JROF)*ZTSTEP
      PDMGWS(JROF) = PDMGWS(JROF) + PVSTRG(JROF)*ZTSTEP
      PDRO(JROF) = PDRO(JROF) + (PRUISS(JROF) + PRUISP(JROF))*ZTSTEP
      PDSSRO(JROF) = PDSSRO(JROF) + (PRUISP(JROF))*ZTSTEP
      PDSRO(JROF) = PDSRO(JROF) + (PRUISS(JROF))*ZTSTEP
      PDNEE(JROF) = PDNEE(JROF) + (PINEE(JROF))*ZTSTEP
      PDGPP(JROF) = PDGPP(JROF) + (PIGPP(JROF))*ZTSTEP
      PDREC(JROF) = PDREC(JROF) + (PIREC(JROF))*ZTSTEP
      PDSSR(JROF) = PDSSR(JROF) + PFRSO(JROF, KFLEVG)*ZTSTEP
      PDSSRD(JROF) = PDSSRD(JROF) + PFRSOD(JROF)*ZTSTEP
      PDSSRDC(JROF) = PDSSRDC(JROF) + PFRSODC(JROF)*ZTSTEP
      PDSTR(JROF) = PDSTR(JROF) + PFRTH(JROF, KFLEVG)*ZTSTEP
      PDSTRD(JROF) = PDSTRD(JROF) + PFRTHD(JROF)*ZTSTEP
      PDSTRDC(JROF) = PDSTRDC(JROF) + PFRTHDC(JROF)*ZTSTEP
      PDTSR(JROF) = PDTSR(JROF) + PFRSO(JROF, 0)*ZTSTEP
      PDTTR(JROF) = PDTTR(JROF) + PFRTH(JROF, 0)*ZTSTEP
      PSUND(JROF) = PSUND(JROF) + PISUND(JROF)*ZTSTEP
      PDUVDF(JROF) = PDUVDF(JROF) + PUVDF(JROF)*ZTSTEP
      PDPARF(JROF) = PDPARF(JROF) + PPARF(JROF)*ZTSTEP
      PDPARCF(JROF) = PDPARCF(JROF) + PPARCF(JROF)*ZTSTEP
      PDTINCF(JROF) = PDTINCF(JROF) + PTINCF(JROF)*ZTSTEP
      PDFDIR(JROF) = PDFDIR(JROF) + PFDIR(JROF)*ZTSTEP
      PDCDIR(JROF) = PDCDIR(JROF) + PCDIR(JROF)*ZTSTEP
      PDDSRP(JROF) = PDDSRP(JROF) + PDSRP(JROF)*ZTSTEP
      PVTTRC(JROF) = PVTTRC(JROF) + PITTRC(JROF)*ZTSTEP
      PVTSRC(JROF) = PVTSRC(JROF) + PITSRC(JROF)*ZTSTEP
      PVSTRC(JROF) = PVSTRC(JROF) + PISTRC(JROF)*ZTSTEP
      PVSSRC(JROF) = PVSSRC(JROF) + PISSRC(JROF)*ZTSTEP
      PVES(JROF) = PVES(JROF) + PIES(JROF)*ZTSTEP
      PVSMLT(JROF) = PVSMLT(JROF) + PISMLT(JROF)*ZTSTEP
      PVLSPF(JROF) = PVLSPF(JROF) + PILSPF(JROF)*ZTSTEP
      PVVIMD(JROF) = PVVIMD(JROF) + PIVIMD(JROF)*ZTSTEP
    END DO
    END IF
    LLMX2TPP = .FALSE.
    LLMN2TPP = .FALSE.
    LL10FGPP = .FALSE.
    LLMXTPRPP = .FALSE.
    LLMNTPRPP = .FALSE.
    LLCAPES = .FALSE.
    IF (LDMLPP) THEN
    IF ((inputs%post_controls%lecfpos /= 0)) THEN
      IMX2T = local_isrcheq(inputs%post_controls%nfpphy, inputs%post_controls%mfpphy, 1, NGRBMX2T)
      IF (IMX2T <= inputs%post_controls%nfpphy) LLMX2TPP = .TRUE.
      IMN2T = local_isrcheq(inputs%post_controls%nfpphy, inputs%post_controls%mfpphy, 1, NGRBMN2T)
      IF (IMN2T <= inputs%post_controls%nfpphy) LLMN2TPP = .TRUE.
      I10FG = local_isrcheq(inputs%post_controls%nfpphy, inputs%post_controls%mfpphy, 1, NGRB10FG)
      IF (I10FG <= inputs%post_controls%nfpphy) LL10FGPP = .TRUE.
      IMXTPR = local_isrcheq(inputs%post_controls%nfpphy, inputs%post_controls%mfpphy, 1, NGRBMXTPR)
      IF (IMXTPR <= inputs%post_controls%nfpphy) LLMXTPRPP = .TRUE.
      IMNTPR = local_isrcheq(inputs%post_controls%nfpphy, inputs%post_controls%mfpphy, 1, NGRBMNTPR)
      IF (IMNTPR <= inputs%post_controls%nfpphy) LLMNTPRPP = .TRUE.
      ICAPES = local_isrcheq(inputs%post_controls%nfpphy, inputs%post_controls%mfpphy, 1, NGRBCAPES)
      IF (ICAPES <= inputs%post_controls%nfpphy) LLCAPES = .TRUE.
    ELSE
      IMX2T = local_isrcheq(inputs%post_controls%no2dgg, inputs%post_controls%m2dggp, 1, NGRBMX2T)
      IF (IMX2T <= inputs%post_controls%no2dgg) LLMX2TPP = .TRUE.
      IMN2T = local_isrcheq(inputs%post_controls%no2dgg, inputs%post_controls%m2dggp, 1, NGRBMN2T)
      IF (IMN2T <= inputs%post_controls%no2dgg) LLMN2TPP = .TRUE.
      I10FG = local_isrcheq(inputs%post_controls%no2dgg, inputs%post_controls%m2dggp, 1, NGRB10FG)
      IF (I10FG <= inputs%post_controls%no2dgg) LL10FGPP = .TRUE.
      IMXTPR = local_isrcheq(inputs%post_controls%no2dgg, inputs%post_controls%m2dggp, 1, NGRBMXTPR)
      IF (IMXTPR <= inputs%post_controls%no2dgg) LLMXTPRPP = .TRUE.
      IMNTPR = local_isrcheq(inputs%post_controls%no2dgg, inputs%post_controls%m2dggp, 1, NGRBMNTPR)
      IF (IMNTPR <= inputs%post_controls%no2dgg) LLMNTPRPP = .TRUE.
      ICAPES = local_isrcheq(inputs%post_controls%no2dgg, inputs%post_controls%m2dggp, 1, NGRBCAPES)
      IF (ICAPES <= inputs%post_controls%no2dgg) LLCAPES = .TRUE.
    END IF
    END IF
    IF ((inputs%post_controls%lecfpos /= 0)) THEN
      IMXCAPS6 = local_isrcheq(inputs%post_controls%nfpphy, inputs%post_controls%mfpphy, 1, NGRBMXCAPS6)
      IF (IMXCAPS6 <= inputs%post_controls%nfpphy) LLCAPES = .TRUE.
    ELSE
      IMXCAPS6 = local_isrcheq(inputs%post_controls%no2dgg, inputs%post_controls%m2dggp, 1, NGRBMXCAPS6)
      IF (IMXCAPS6 <= inputs%post_controls%no2dgg) LLCAPES = .TRUE.
    END IF
    DO JROF = KIDIA, KFDIA
      ZTOTPREC = MAX(PFPLSL(JROF, KFLEVG) + PFPLSN(JROF, KFLEVG) + PFPLCL(JROF, KFLEVG) + PFPLCN(JROF, KFLEVG), 0._JPRB)
      IF (LLMX2TPP .OR. LDFSTEP) THEN
        PDMX2T(JROF) = PTCLS(JROF)
      ELSE
        PDMX2T(JROF) = MAX(PTCLS(JROF), PDMX2T(JROF))
      END IF
      IF (LLMN2TPP .OR. LDFSTEP) THEN
        PDMN2T(JROF) = PTCLS(JROF)
      ELSE
        PDMN2T(JROF) = MIN(PTCLS(JROF), PDMN2T(JROF))
      END IF
      IF (LL10FGPP .OR. LDFSTEP) THEN
        PV10FG(JROF) = PI10FG(JROF)
      ELSE
        PV10FG(JROF) = MAX(PI10FG(JROF), PV10FG(JROF))
      END IF
      IF (LLMXTPRPP .OR. LDFSTEP) THEN
        PDMXTPR(JROF) = ZTOTPREC
      ELSE
        PDMXTPR(JROF) = MAX(ZTOTPREC, PDMXTPR(JROF))
      END IF
      IF (LLMNTPRPP .OR. LDFSTEP) THEN
        PDMNTPR(JROF) = ZTOTPREC
      ELSE
        PDMNTPR(JROF) = MIN(ZTOTPREC, PDMNTPR(JROF))
      END IF
      PDIE(JROF) = PDIFTQ(JROF, KFLEVG)
      PDISSHF(JROF) = PDIFTS(JROF, KFLEVG)
      PDIEWSS(JROF) = PSTRTU(JROF, KFLEVG)
      PDINSSS(JROF) = PSTRTV(JROF, KFLEVG)
      PDSP(JROF) = PRESH(JROF, KFLEVG)
      PVI10FG(JROF) = PI10FG(JROF)
      PDTPR(JROF) = PFPLSL(JROF, KFLEVG) + PFPLSN(JROF, KFLEVG) + PFPLCL(JROF, KFLEVG) + PFPLCN(JROF, KFLEVG)
      PDLSRR(JROF) = PFPLSL(JROF, KFLEVG)
      PDLSSFR(JROF) = PFPLSN(JROF, KFLEVG)
      PDCRR(JROF) = PFPLCL(JROF, KFLEVG)
      PDCSFR(JROF) = PFPLCN(JROF, KFLEVG)
      PVILSPF(JROF) = PILSPF(JROF)
      PDPTYPE(JROF) = PPRECTYPE(JROF)
      IF (LDRS6 .OR. LDFSTEP) THEN
        PDMX2T6(JROF) = PTCLS(JROF)
        PDMN2T6(JROF) = PTCLS(JROF)
        PV10FG6(JROF) = PI10FG(JROF)
        PDMXTPR6(JROF) = ZTOTPREC
        PDMNTPR6(JROF) = ZTOTPREC
        PDLITOTA6(JROF) = PLIGH_TOT(JROF)*ZTSTEP_IN_HOURS
        PDLICGA6(JROF) = PLIGH_CTG(JROF)*ZTSTEP_IN_HOURS
        PDPTYPEOCC6(JROF, :) = 0
      ELSE
        PDMX2T6(JROF) = MAX(PTCLS(JROF), PDMX2T6(JROF))
        PDMN2T6(JROF) = MIN(PTCLS(JROF), PDMN2T6(JROF))
        PV10FG6(JROF) = MAX(PI10FG(JROF), PV10FG6(JROF))
        PDMXTPR6(JROF) = MAX(ZTOTPREC, PDMXTPR6(JROF))
        PDMNTPR6(JROF) = MIN(ZTOTPREC, PDMNTPR6(JROF))
        PDLITOTA6(JROF) = PDLITOTA6(JROF) + PLIGH_TOT(JROF)*ZTSTEP_IN_HOURS
        PDLICGA6(JROF) = PDLICGA6(JROF) + PLIGH_CTG(JROF)*ZTSTEP_IN_HOURS
      END IF
      IPRECTYPE = INT(PPRECTYPE(JROF))
      IF (IPRECTYPE > 0) PDPTYPEOCC6(JROF, IPRECTYPE) = PDPTYPEOCC6(JROF, IPRECTYPE) + 1._JPRB
    END DO
    DO JROF = KIDIA, KFDIA
      ZTB(JROF) = PT(JROF, inputs%post_controls%nlextrap)
      ZPRESBH(JROF) = PRESH(JROF, KFLEVG)
      ZPRESBF(JROF) = PRESF(JROF, inputs%post_controls%nlextrap)
    END DO
CALL CTSTAR(KPROMA,KIDIA,KFDIA,ZTB,ZPRESBH,ZPRESBF,POROG,ZTSTAR,ZT0,inputs%post_controls%rdtdz1,inputs%providers%physical%rg,inputs%providers%physical%rd,status)
    if (status /= 0) return
status=pppmer(KPROMA,KIDIA,KFDIA,ZPRESBH,POROG,ZTSTAR,ZT0,PDMSL,inputs%post_controls%rdtdz1,inputs%providers%physical%rg,inputs%providers%physical%rd)
    if (status /= 0) return
    IF (LLCAPES) THEN
status=capeshear(KPROMA,KIDIA,KFDIA,KFLEVG,PRESH,PRESF,PU,PV,PCAPE(:,2),ZCAPES,inputs%post_controls%lrppuv_cstext/=0,inputs%post_controls%lrppuv_callitpq/=0)
      if (status /= 0) return
    ELSE
      ZCAPES(:) = 0._JPRB
    END IF
    DO JROF = KIDIA, KFDIA
    IF (LDRS6 .OR. LDFSTEP) THEN
      PDMXCAP6(JROF) = PCAPE(JROF, 2)
      IF (LLCAPES) PDMXCAPS6(JROF) = ZCAPES(JROF)
    ELSE
      PDMXCAP6(JROF) = MAX(PCAPE(JROF, 2), PDMXCAP6(JROF))
      IF (LLCAPES) PDMXCAPS6(JROF) = MAX(ZCAPES(JROF), PDMXCAPS6(JROF))
    END IF
    END DO
    IF (LDMLPP) THEN
      call integrate_column_water(KPROMA, KIDIA, KFDIA, KFLEVG, inputs%providers%physical%rg, PQ, PRESH, ZWCH, status)
      if (status /= 0) return
      DO JROF = KIDIA, KFDIA
        PDTCWV(JROF) = ZWCH(JROF, KFLEVG)
        PDCAPE(JROF) = PCAPE(JROF, 1)
        PDMUCAPE(JROF) = PCAPE(JROF, 2)
        PDMLCAPE50(JROF) = PCAPE(JROF, 3)
        PDMLCAPE100(JROF) = PCAPE(JROF, 4)
        PDPDEPL(JROF) = PPDEPL(JROF)
        PDCAPES(JROF) = ZCAPES(JROF)
        PDCBASE(JROF) = PCBASE(JROF)
        PD0DEGL(JROF) = P0DEGL(JROF)
        PDM10DEGL(JROF) = PM10DEGL(JROF)
        PDVISIH(JROF) = PVISIH(JROF)
        PDCIN(JROF) = PCIN(JROF, 1)
        PDMLCIN50(JROF) = PCIN(JROF, 2)
        PDMLCIN100(JROF) = PCIN(JROF, 3)
        PDTTINDEX(JROF) = PCONVIND(JROF, 1)
        PDKINDEX(JROF) = PCONVIND(JROF, 2)
        PDCBASEA(JROF) = PCBASEA(JROF)
        PDCTOPC(JROF) = PCTOPC(JROF)
        PDTROPOTP(JROF) = PTROPOTP(JROF)
        PDZTWETB0(JROF) = PZTWETB(JROF, 1)
        PDZTWETB1(JROF) = PZTWETB(JROF, 2)
      END DO
      DO JROF = KIDIA, KFDIA
        IF (PCBASE(JROF) == inputs%physics%convection%rbase0) PDCBASE(JROF) = inputs%post_controls%rmdi
        IF (PCBASEA(JROF) == inputs%physics%convection%rbase0) PDCBASEA(JROF) = inputs%post_controls%rmdi
        IF (PCTOPC(JROF) == inputs%physics%convection%rbase0) PDCTOPC(JROF) = inputs%post_controls%rmdi
        IF (PCIN(JROF, 1) == -inputs%physics%convection%rmincin) PDCIN(JROF) = inputs%post_controls%rmdi
        IF (PCIN(JROF, 2) == -inputs%physics%convection%rmincin) PDMLCIN50(JROF) = inputs%post_controls%rmdi
        IF (PCIN(JROF, 3) == -inputs%physics%convection%rmincin) PDMLCIN100(JROF) = inputs%post_controls%rmdi
      END DO
      DO JK = 1, KFLEVG
      DO JROF = KIDIA, KFDIA
        ZCLD(JROF, JK) = PQ(JROF, JK)*PU(JROF, JK)
      END DO
      END DO
      call integrate_column_water(KPROMA, KIDIA, KFDIA, KFLEVG, inputs%providers%physical%rg, ZCLD, PRESH, ZWCH, status)
      if (status /= 0) return
      DO JROF = KIDIA, KFDIA
        PDVIWVE(JROF) = ZWCH(JROF, KFLEVG)
      END DO
      DO JK = 1, KFLEVG
      DO JROF = KIDIA, KFDIA
        ZCLD(JROF, JK) = PQ(JROF, JK)*PV(JROF, JK)
      END DO
      END DO
      call integrate_column_water(KPROMA, KIDIA, KFDIA, KFLEVG, inputs%providers%physical%rg, ZCLD, PRESH, ZWCH, status)
      if (status /= 0) return
      DO JROF = KIDIA, KFDIA
        PDVIWVN(JROF) = ZWCH(JROF, KFLEVG)
      END DO
      IF (liquid_active) THEN
      DO JK = 1, KFLEVG
      DO JROF = KIDIA, KFDIA
        ZCLD(JROF, JK) = PL(JROF, JK)
        IF (ZCLD(JROF, JK) < 1.E-12_JPRB) ZCLD(JROF, JK) = 0.0_JPRB
      END DO
      END DO
      call integrate_column_water(KPROMA, KIDIA, KFDIA, KFLEVG, inputs%providers%physical%rg, ZCLD, PRESH, ZWCH, status)
      if (status /= 0) return
      DO JROF = KIDIA, KFDIA
        PDTCLW(JROF) = ZWCH(JROF, KFLEVG)
      END DO
      END IF
      IF (rain_active) THEN
      DO JK = 1, KFLEVG
      DO JROF = KIDIA, KFDIA
        ZCLD(JROF, JK) = PR(JROF, JK)
        IF (ZCLD(JROF, JK) < 1.E-12_JPRB) ZCLD(JROF, JK) = 0.0_JPRB
      END DO
      END DO
      call integrate_column_water(KPROMA, KIDIA, KFDIA, KFLEVG, inputs%providers%physical%rg, ZCLD, PRESH, ZWCH, status)
      if (status /= 0) return
      DO JROF = KIDIA, KFDIA
        PDTCRW(JROF) = ZWCH(JROF, KFLEVG)
      END DO
      END IF
      IF (ice_active) THEN
      DO JK = 1, KFLEVG
      DO JROF = KIDIA, KFDIA
        ZCLD(JROF, JK) = PI(JROF, JK)
        IF (ZCLD(JROF, JK) < 1.E-12_JPRB) ZCLD(JROF, JK) = 0.0_JPRB
      END DO
      END DO
      call integrate_column_water(KPROMA, KIDIA, KFDIA, KFLEVG, inputs%providers%physical%rg, ZCLD, PRESH, ZWCH, status)
      if (status /= 0) return
      DO JROF = KIDIA, KFDIA
        PDTCIW(JROF) = ZWCH(JROF, KFLEVG)
      END DO
      END IF
      IF (snow_active) THEN
      DO JK = 1, KFLEVG
      DO JROF = KIDIA, KFDIA
        ZCLD(JROF, JK) = PS(JROF, JK)
        IF (ZCLD(JROF, JK) < 1.E-12_JPRB) ZCLD(JROF, JK) = 0.0_JPRB
      END DO
      END DO
      call integrate_column_water(KPROMA, KIDIA, KFDIA, KFLEVG, inputs%providers%physical%rg, ZCLD, PRESH, ZWCH, status)
      if (status /= 0) return
      DO JROF = KIDIA, KFDIA
        PDTCSW(JROF) = ZWCH(JROF, KFLEVG)
      END DO
      END IF
      IF (liquid_active) THEN
      DO JK = 1, KFLEVG
      DO JROF = KIDIA, KFDIA
        ZCLD(JROF, JK) = PL(JROF, JK)
        IF (ZCLD(JROF, JK) < 1.E-12_JPRB .OR. PT(JROF, JK) > inputs%providers%physical%rtt) ZCLD(JROF, JK) = 0.0_JPRB
      END DO
      END DO
      call integrate_column_water(KPROMA, KIDIA, KFDIA, KFLEVG, inputs%providers%physical%rg, ZCLD, PRESH, ZWCH, status)
      if (status /= 0) return
      DO JROF = KIDIA, KFDIA
        PDTCSLW(JROF) = ZWCH(JROF, KFLEVG)
      END DO
      END IF
      IF (liquid_active .AND. ice_active .AND. .NOT. snow_active .AND. .NOT. rain_active) THEN
      DO JK = 1, KFLEVG
      DO JROF = KIDIA, KFDIA
        ZWVLI(JROF, JK) = ((PI(JROF, JK)) + PL(JROF, JK)) + PQ(JROF, JK)
      END DO
      END DO
      call integrate_column_water(KPROMA, KIDIA, KFDIA, KFLEVG, inputs%providers%physical%rg, ZWVLI, PRESH, ZWCH, status)
      if (status /= 0) return
      END IF
      IF (liquid_active .AND. ice_active .AND. snow_active .AND. .NOT. rain_active) THEN
      DO JK = 1, KFLEVG
      DO JROF = KIDIA, KFDIA
        ZWVLI(JROF, JK) = (((PI(JROF, JK)) + PS(JROF, JK)) + PL(JROF, JK)) + PQ(JROF, JK)
      END DO
      END DO
      call integrate_column_water(KPROMA, KIDIA, KFDIA, KFLEVG, inputs%providers%physical%rg, ZWVLI, PRESH, ZWCH, status)
      if (status /= 0) return
      END IF
      IF (liquid_active .AND. ice_active .AND. snow_active .AND. rain_active) THEN
      DO JK = 1, KFLEVG
      DO JROF = KIDIA, KFDIA
        ZWVLI(JROF, JK) = ((((PI(JROF, JK)) + PS(JROF, JK)) + PL(JROF, JK)) + PR(JROF, JK)) + PQ(JROF, JK)
      END DO
      END DO
      call integrate_column_water(KPROMA, KIDIA, KFDIA, KFLEVG, inputs%providers%physical%rg, ZWVLI, PRESH, ZWCH, status)
      if (status /= 0) return
      END IF
      DO JROF = KIDIA, KFDIA
        PDTCW(JROF) = ZWCH(JROF, KFLEVG)
      END DO
      DO JROF = KIDIA, KFDIA
        PDLITOTI(JROF) = PLIGH_TOT(JROF)
        PDLICGI(JROF) = PLIGH_CTG(JROF)
      END DO
    END IF
    IF (LDMLPP .AND. ozone_active) THEN
      status = integrate_column_ozone_mass(inputs%providers%physical%rg, KPROMA, KIDIA, KFDIA, KFLEVG, PDELP, PO3, PDTCO3)
      if (status /= 0) return
    END IF
    status = 0
  end function
!> Return the first matching source code or count+1; a zero count reads no list.
  integer(int32) function local_isrcheq(count, list, stride, value) result(index)
    integer(int32), intent(in) :: count, stride, value
    integer(int32), pointer, intent(in) :: list(:)
    integer :: j, position
    index = count + 1
    do j = 1, count
      position = lbound(list, 1) + (j - 1)*stride
      if (list(position) == value) then
        index = j
        return
      end if
    end do
  end function
end module
