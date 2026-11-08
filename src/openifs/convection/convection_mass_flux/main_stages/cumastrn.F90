! (C) Copyright 1989- ECMWF.
! This software is licensed under the terms of the Apache Licence Version 2.0
! which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
!
! In applying this licence, ECMWF does not waive the privileges and immunities
! granted to it by virtue of its status as an intergovernmental organisation
! nor does it submit to any jurisdiction

!> Complete nonlinear weather convection from shared native parameter records.
!! Borrow the single owned ECMWF parameter state and the canonical seventeen
!! physics records. No original composite model, GFL namespace or chemistry
!! object is recreated. NACTAERO is the readonly active-aerosol count and
!! CHEM_LIGHT_ACTIVE is the explicit source chemistry choice.
!! The caller establishes nearest-even, gradual underflow, finite physical
!! inputs/intermediates, disjoint outputs and sufficient native stack storage.
module convection_column_update_mod
  use iso_fortran_env, only: JPIM => int32, JPRB => real64, int64
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use forecast_ecmwf_physics_state, only: native_ecmwf_physics_state
  use physics_configuration_state_port, only: physics_configuration_state
  use convective_initial_state_mod, only: cuinin
  use convection_cloud_base_search_mod, only: cubasen
  use convection_downdraft_descent_mod, only: cuddrafn
  use moist_cloud_ascent_mod, only: cuascn
  use convection_downdraft_start_mod, only: cudlfsn
  use convection_final_fluxes_mod, only: cuflxn
  use convective_heat_moisture_mod, only: cudtdqn
  use convection_wind_transport_mod, only: cududv
  use convection_source_math_mod, only: source_power, source_exp, source_log
  USE SPP_MOD, ONLY: TSPP_CONFIG
  USE SPP_GEN_MOD, ONLY: SPP_PERT
  implicit none
  private
  public :: cumastrn
contains
  !> Complete all selected source stages and preserve every inactive cell.
  !! Provider records precede the original remaining argument order. Shapes
  !! use exact KLON leading extents, KLEV layers and KLEV+1 faces; pressure
  !! is Pa, temperature K, humidity kg/kg and timestep seconds.
  !! Support KLON1:4096, KLEV4:1024 and KLON*KLEV<=65536. LSPP is false,
  !! LMFDD true, and chemical tracer transport inactive, as in the frozen
  !! weather contract. LMFTRAC=true with KTRAC=0 remains supported.
  !! Return0 after work,2 before writes for unsupported metadata or a child
  !! status after its preceding source stages. No numerical driver fills a stage.
  integer(JPIM) function cumastrn(constants,thermal,rplrg,rpldare,parameters,configuration,NACTAERO,chem_light_active,YDSPP_CONFIG,KIDIA,KFDIA,KLON,KLEV,LDLAND,PTSPHY,PTEN,PQEN,PUEN,PVEN,PLITOT,PVERVEL,PQSEN,PQHFL,PAHFS,PAP,PAPH,PGEO,PGEOH,PGAW,PCUCONVCA,PGP2DSPP,PTENT,PTENQ,PTENU,PTENV,PTENTA,PTENQA,LDCUM,KTYPE,KCBOT,KCTOP,LDCUM_LIG,KCBOT_LIG,KCTOP_LIG,KBOTSC,LDSC,LDSHCV,PLCRIT_AER,PTU,PQU,PLU,PLUDE,PLUDELI,PSNDE,PENTH,PMFLXR,PMFLXS,PRAIN,PLRAIN,PRSUD,PMFU,PMFD,PMFUDE_RATE,PMFDDE_RATE,PCAPE,PWMEAN,PVDISCU,PDISS,KTRAC,PCEN,PTENC,PSCAV)result(status)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    real(JPRB), intent(in) :: rplrg, rpldare
    type(native_ecmwf_physics_state), intent(inout) :: parameters
    type(physics_configuration_state), intent(inout) :: configuration
    integer(JPIM), intent(in) :: NACTAERO
    logical, intent(in) :: chem_light_active
    TYPE(TSPP_CONFIG), INTENT(IN) :: YDSPP_CONFIG
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEV
    LOGICAL, INTENT(IN) :: LDLAND(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTSPHY
    REAL(KIND=JPRB), INTENT(INOUT) :: PTEN(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PQEN(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PUEN(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PVEN(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PLITOT(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PVERVEL(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PQSEN(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PQHFL(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PAHFS(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PAP(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PAPH(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PGEO(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PGEOH(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PGAW(:)
    REAL(KIND=JPRB), INTENT(IN) :: PCUCONVCA(:)
    REAL(KIND=JPRB), INTENT(IN) :: PGP2DSPP(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTENT(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTENQ(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTENU(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTENV(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PTENTA(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PTENQA(:, :)
    LOGICAL, INTENT(INOUT) :: LDCUM(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KTYPE(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KCBOT(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KCTOP(:)
    LOGICAL, INTENT(INOUT) :: LDCUM_LIG(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KCBOT_LIG(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KCTOP_LIG(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KBOTSC(:)
    LOGICAL, INTENT(INOUT) :: LDSC(:)
    LOGICAL, INTENT(IN) :: LDSHCV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PLCRIT_AER(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTU(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PQU(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PLU(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PLUDE(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PLUDELI(:, :, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PSNDE(:, :, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PENTH(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMFLXR(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMFLXS(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PRAIN(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PLRAIN(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PRSUD(:, :, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMFU(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMFD(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMFUDE_RATE(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMFDDE_RATE(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCAPE(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PWMEAN(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PVDISCU(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDISS(:, :)
    INTEGER(KIND=JPIM), INTENT(IN) :: KTRAC
    REAL(KIND=JPRB), INTENT(IN) :: PCEN(:, :, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTENC(:, :, :)
    REAL(KIND=JPRB), INTENT(IN) :: PSCAV(:)
    status = 2_JPIM
    if (KLON < 1 .or. KLON > 4096 .or. KLEV < 4 .or. KLEV > 1024) return
    if (int(KLON, int64)*int(KLEV, int64) > 65536_int64) return
    if (KIDIA < 1 .or. KIDIA > KLON + 1 .or. KFDIA < 0 .or. KFDIA > KLON) return
    if (configuration%linear_ecmwf%LPHYLIN .or. YDSPP_CONFIG%LSPP) return
    if (.not. parameters%convection%LMFDD) return
    if (configuration%ecmwf_physics%LMFTRAC .and. KTRAC > 0) return
    if (KTRAC < 0 .or. NACTAERO < 0 .or. YDSPP_CONFIG%SM%NRFTOTAL < 0) return
    if (.not. is_contiguous(LDLAND)) return
    if (size(LDLAND, 1) /= KLON) return
    if (.not. is_contiguous(PTEN)) return
    if (size(PTEN, 1) /= KLON) return
    if (size(PTEN, 2) < KLEV) return
    if (.not. is_contiguous(PQEN)) return
    if (size(PQEN, 1) /= KLON) return
    if (size(PQEN, 2) < KLEV) return
    if (.not. is_contiguous(PUEN)) return
    if (size(PUEN, 1) /= KLON) return
    if (size(PUEN, 2) < KLEV) return
    if (.not. is_contiguous(PVEN)) return
    if (size(PVEN, 1) /= KLON) return
    if (size(PVEN, 2) < KLEV) return
    if (.not. is_contiguous(PLITOT)) return
    if (size(PLITOT, 1) /= KLON) return
    if (size(PLITOT, 2) < KLEV) return
    if (.not. is_contiguous(PVERVEL)) return
    if (size(PVERVEL, 1) /= KLON) return
    if (size(PVERVEL, 2) < KLEV) return
    if (.not. is_contiguous(PQSEN)) return
    if (size(PQSEN, 1) /= KLON) return
    if (size(PQSEN, 2) < KLEV) return
    if (.not. is_contiguous(PQHFL)) return
    if (size(PQHFL, 1) /= KLON) return
    if (size(PQHFL, 2) < KLEV + 1) return
    if (.not. is_contiguous(PAHFS)) return
    if (size(PAHFS, 1) /= KLON) return
    if (size(PAHFS, 2) < KLEV + 1) return
    if (.not. is_contiguous(PAP)) return
    if (size(PAP, 1) /= KLON) return
    if (size(PAP, 2) < KLEV) return
    if (.not. is_contiguous(PAPH)) return
    if (size(PAPH, 1) /= KLON) return
    if (size(PAPH, 2) < KLEV + 1) return
    if (.not. is_contiguous(PGEO)) return
    if (size(PGEO, 1) /= KLON) return
    if (size(PGEO, 2) < KLEV) return
    if (.not. is_contiguous(PGEOH)) return
    if (size(PGEOH, 1) /= KLON) return
    if (size(PGEOH, 2) < KLEV + 1) return
    if (.not. is_contiguous(PGAW)) return
    if (size(PGAW, 1) /= KLON) return
    if (.not. is_contiguous(PCUCONVCA)) return
    if (size(PCUCONVCA, 1) /= KLON) return
    if (.not. is_contiguous(PGP2DSPP)) return
    if (size(PGP2DSPP, 1) /= KLON) return
    if (size(PGP2DSPP, 2) < YDSPP_CONFIG%SM%NRFTOTAL) return
    if (.not. is_contiguous(PTENT)) return
    if (size(PTENT, 1) /= KLON) return
    if (size(PTENT, 2) < KLEV) return
    if (.not. is_contiguous(PTENQ)) return
    if (size(PTENQ, 1) /= KLON) return
    if (size(PTENQ, 2) < KLEV) return
    if (.not. is_contiguous(PTENU)) return
    if (size(PTENU, 1) /= KLON) return
    if (size(PTENU, 2) < KLEV) return
    if (.not. is_contiguous(PTENV)) return
    if (size(PTENV, 1) /= KLON) return
    if (size(PTENV, 2) < KLEV) return
    if (.not. is_contiguous(PTENTA)) return
    if (size(PTENTA, 1) /= KLON) return
    if (size(PTENTA, 2) < KLEV) return
    if (.not. is_contiguous(PTENQA)) return
    if (size(PTENQA, 1) /= KLON) return
    if (size(PTENQA, 2) < KLEV) return
    if (.not. is_contiguous(LDCUM)) return
    if (size(LDCUM, 1) /= KLON) return
    if (.not. is_contiguous(KTYPE)) return
    if (size(KTYPE, 1) /= KLON) return
    if (.not. is_contiguous(KCBOT)) return
    if (size(KCBOT, 1) /= KLON) return
    if (.not. is_contiguous(KCTOP)) return
    if (size(KCTOP, 1) /= KLON) return
    if (.not. is_contiguous(LDCUM_LIG)) return
    if (size(LDCUM_LIG, 1) /= KLON) return
    if (.not. is_contiguous(KCBOT_LIG)) return
    if (size(KCBOT_LIG, 1) /= KLON) return
    if (.not. is_contiguous(KCTOP_LIG)) return
    if (size(KCTOP_LIG, 1) /= KLON) return
    if (.not. is_contiguous(KBOTSC)) return
    if (size(KBOTSC, 1) /= KLON) return
    if (.not. is_contiguous(LDSC)) return
    if (size(LDSC, 1) /= KLON) return
    if (.not. is_contiguous(LDSHCV)) return
    if (size(LDSHCV, 1) /= KLON) return
    if (.not. is_contiguous(PLCRIT_AER)) return
    if (size(PLCRIT_AER, 1) /= KLON) return
    if (size(PLCRIT_AER, 2) < KLEV) return
    if (.not. is_contiguous(PTU)) return
    if (size(PTU, 1) /= KLON) return
    if (size(PTU, 2) < KLEV) return
    if (.not. is_contiguous(PQU)) return
    if (size(PQU, 1) /= KLON) return
    if (size(PQU, 2) < KLEV) return
    if (.not. is_contiguous(PLU)) return
    if (size(PLU, 1) /= KLON) return
    if (size(PLU, 2) < KLEV) return
    if (.not. is_contiguous(PLUDE)) return
    if (size(PLUDE, 1) /= KLON) return
    if (size(PLUDE, 2) < KLEV) return
    if (.not. is_contiguous(PLUDELI)) return
    if (size(PLUDELI, 1) /= KLON) return
    if (size(PLUDELI, 2) < KLEV) return
    if (size(PLUDELI, 3) < 4) return
    if (.not. is_contiguous(PSNDE)) return
    if (size(PSNDE, 1) /= KLON) return
    if (size(PSNDE, 2) < KLEV) return
    if (size(PSNDE, 3) < 2) return
    if (.not. is_contiguous(PENTH)) return
    if (size(PENTH, 1) /= KLON) return
    if (size(PENTH, 2) < KLEV) return
    if (.not. is_contiguous(PMFLXR)) return
    if (size(PMFLXR, 1) /= KLON) return
    if (size(PMFLXR, 2) < KLEV + 1) return
    if (.not. is_contiguous(PMFLXS)) return
    if (size(PMFLXS, 1) /= KLON) return
    if (size(PMFLXS, 2) < KLEV + 1) return
    if (.not. is_contiguous(PRAIN)) return
    if (size(PRAIN, 1) /= KLON) return
    if (.not. is_contiguous(PLRAIN)) return
    if (size(PLRAIN, 1) /= KLON) return
    if (size(PLRAIN, 2) < KLEV) return
    if (.not. is_contiguous(PRSUD)) return
    if (size(PRSUD, 1) /= KLON) return
    if (size(PRSUD, 2) < KLEV) return
    if (size(PRSUD, 3) < 2) return
    if (.not. is_contiguous(PMFU)) return
    if (size(PMFU, 1) /= KLON) return
    if (size(PMFU, 2) < KLEV) return
    if (.not. is_contiguous(PMFD)) return
    if (size(PMFD, 1) /= KLON) return
    if (size(PMFD, 2) < KLEV) return
    if (.not. is_contiguous(PMFUDE_RATE)) return
    if (size(PMFUDE_RATE, 1) /= KLON) return
    if (size(PMFUDE_RATE, 2) < KLEV) return
    if (.not. is_contiguous(PMFDDE_RATE)) return
    if (size(PMFDDE_RATE, 1) /= KLON) return
    if (size(PMFDDE_RATE, 2) < KLEV) return
    if (.not. is_contiguous(PCAPE)) return
    if (size(PCAPE, 1) /= KLON) return
    if (.not. is_contiguous(PWMEAN)) return
    if (size(PWMEAN, 1) /= KLON) return
    if (.not. is_contiguous(PVDISCU)) return
    if (size(PVDISCU, 1) /= KLON) return
    if (.not. is_contiguous(PDISS)) return
    if (size(PDISS, 1) /= KLON) return
    if (size(PDISS, 2) < KLEV) return
    if (.not. is_contiguous(PCEN)) return
    if (size(PCEN, 1) /= KLON) return
    if (size(PCEN, 2) < KLEV) return
    if (size(PCEN, 3) < KTRAC) return
    if (.not. is_contiguous(PTENC)) return
    if (size(PTENC, 1) /= KLON) return
    if (size(PTENC, 2) < KLEV) return
    if (size(PTENC, 3) < KTRAC) return
    if (.not. is_contiguous(PSCAV)) return
    if (size(PSCAV, 1) /= KTRAC) return
    status=cumastrn_body(constants,thermal,rplrg,rpldare,parameters,configuration,NACTAERO,chem_light_active,YDSPP_CONFIG,KIDIA,KFDIA,KLON,KLEV,LDLAND(1:KLON),PTSPHY,PTEN(1:KLON,1:KLEV),PQEN(1:KLON,1:KLEV),PUEN(1:KLON,1:KLEV),PVEN(1:KLON,1:KLEV),PLITOT(1:KLON,1:KLEV),PVERVEL(1:KLON,1:KLEV),PQSEN(1:KLON,1:KLEV),PQHFL(1:KLON,1:KLEV+1),PAHFS(1:KLON,1:KLEV+1),PAP(1:KLON,1:KLEV),PAPH(1:KLON,1:KLEV+1),PGEO(1:KLON,1:KLEV),PGEOH(1:KLON,1:KLEV+1),PGAW(1:KLON),PCUCONVCA(1:KLON),PGP2DSPP(1:KLON,1:YDSPP_CONFIG%SM%NRFTOTAL),PTENT(1:KLON,1:KLEV),PTENQ(1:KLON,1:KLEV),PTENU(1:KLON,1:KLEV),PTENV(1:KLON,1:KLEV),PTENTA(1:KLON,1:KLEV),PTENQA(1:KLON,1:KLEV),LDCUM(1:KLON),KTYPE(1:KLON),KCBOT(1:KLON),KCTOP(1:KLON),LDCUM_LIG(1:KLON),KCBOT_LIG(1:KLON),KCTOP_LIG(1:KLON),KBOTSC(1:KLON),LDSC(1:KLON),LDSHCV(1:KLON),PLCRIT_AER(1:KLON,1:KLEV),PTU(1:KLON,1:KLEV),PQU(1:KLON,1:KLEV),PLU(1:KLON,1:KLEV),PLUDE(1:KLON,1:KLEV),PLUDELI(1:KLON,1:KLEV,1:4),PSNDE(1:KLON,1:KLEV,1:2),PENTH(1:KLON,1:KLEV),PMFLXR(1:KLON,1:KLEV+1),PMFLXS(1:KLON,1:KLEV+1),PRAIN(1:KLON),PLRAIN(1:KLON,1:KLEV),PRSUD(1:KLON,1:KLEV,1:2),PMFU(1:KLON,1:KLEV),PMFD(1:KLON,1:KLEV),PMFUDE_RATE(1:KLON,1:KLEV),PMFDDE_RATE(1:KLON,1:KLEV),PCAPE(1:KLON),PWMEAN(1:KLON),PVDISCU(1:KLON),PDISS(1:KLON,1:KLEV),KTRAC,PCEN(1:KLON,1:KLEV,1:KTRAC),PTENC(1:KLON,1:KLEV,1:KTRAC),PSCAV(1:KTRAC))
  end function cumastrn
  integer(JPIM) function cumastrn_body(constants,thermal,rplrg,rpldare,parameters,configuration,NACTAERO,chem_light_active,YDSPP_CONFIG,KIDIA,KFDIA,KLON,KLEV,LDLAND,PTSPHY,PTEN,PQEN,PUEN,PVEN,PLITOT,PVERVEL,PQSEN,PQHFL,PAHFS,PAP,PAPH,PGEO,PGEOH,PGAW,PCUCONVCA,PGP2DSPP,PTENT,PTENQ,PTENU,PTENV,PTENTA,PTENQA,LDCUM,KTYPE,KCBOT,KCTOP,LDCUM_LIG,KCBOT_LIG,KCTOP_LIG,KBOTSC,LDSC,LDSHCV,PLCRIT_AER,PTU,PQU,PLU,PLUDE,PLUDELI,PSNDE,PENTH,PMFLXR,PMFLXS,PRAIN,PLRAIN,PRSUD,PMFU,PMFD,PMFUDE_RATE,PMFDDE_RATE,PCAPE,PWMEAN,PVDISCU,PDISS,KTRAC,PCEN,PTENC,PSCAV)result(status)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    real(JPRB), intent(in) :: rplrg, rpldare
    type(native_ecmwf_physics_state), intent(inout) :: parameters
    type(physics_configuration_state), intent(inout) :: configuration
    integer(JPIM), intent(in) :: NACTAERO
    logical, intent(in) :: chem_light_active
    TYPE(TSPP_CONFIG), INTENT(IN) :: YDSPP_CONFIG
    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEV
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KTRAC
    LOGICAL, INTENT(IN) :: LDLAND(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTSPHY
    REAL(KIND=JPRB), INTENT(IN) :: PLCRIT_AER(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTEN(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PQEN(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PUEN(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PVEN(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PLITOT(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PVERVEL(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PQSEN(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PQHFL(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PAHFS(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PAP(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PAPH(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PGEO(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PGEOH(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PGAW(:)
    REAL(KIND=JPRB), INTENT(IN) :: PCUCONVCA(:)
    REAL(KIND=JPRB), INTENT(IN) :: PGP2DSPP(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PCEN(:, :, :)
    REAL(KIND=JPRB), INTENT(IN) :: PSCAV(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTENT(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTENQ(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTENU(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTENV(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PTENTA(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PTENQA(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTENC(:, :, :)
    LOGICAL, INTENT(INOUT) :: LDCUM(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KTYPE(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KCBOT(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KCTOP(:)
    LOGICAL, INTENT(INOUT) :: LDCUM_LIG(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KCBOT_LIG(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KCTOP_LIG(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KBOTSC(:)
    LOGICAL, INTENT(INOUT) :: LDSC(:)
    LOGICAL, INTENT(IN) :: LDSHCV(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTU(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PQU(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PLU(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PLUDE(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PLUDELI(:, :, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PSNDE(:, :, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PENTH(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMFLXR(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMFLXS(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PRAIN(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PLRAIN(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PRSUD(:, :, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMFU(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMFD(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMFUDE_RATE(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMFDDE_RATE(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCAPE(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PWMEAN(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PVDISCU(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDISS(:, :)
    REAL(KIND=JPRB) ::     ZTENH(KLON,KLEV),       ZQENH(KLON,KLEV), ZTENH2(KLON,KLEV),      ZQENH2(KLON,KLEV), ZQSENH(KLON,KLEV), ZTD(KLON,KLEV),         ZQD(KLON,KLEV), ZMFUS(KLON,KLEV),       ZMFDS(KLON,KLEV), ZMFUQ(KLON,KLEV),       ZMFDQ(KLON,KLEV), ZDMFUP(KLON,KLEV),      ZDMFDP(KLON,KLEV), ZMFUL(KLON,KLEV),       ZRFL(KLON), ZUU(KLON,KLEV),         ZVU(KLON,KLEV), ZUD(KLON,KLEV),         ZVD(KLON,KLEV), ZKINEU(KLON,KLEV),      ZKINED(KLON,KLEV)
    REAL(KIND=JPRB) :: ZMFUB(KLON), ZMFUB1(KLON), ZKHVFL(KLON), ZKHFL(KLON), ZDQCV(KLON), ZFACCA(KLON), ZMFCFL(KLON), ZSATFR(KLON)
    REAL(KIND=JPRB) :: ZDPMEL(KLON, KLEV), ZLGLAC(KLON, KLEV)
    REAL(KIND=JPRB) :: ZDHPBL(KLON), ZWUBASE(KLON)
    REAL(KIND=JPRB) :: ZDMFEN(KLON, KLEV), ZDMFDE(KLON, KLEV), ZDX(KLON)
    INTEGER(KIND=JPIM) :: ILAB(KLON, KLEV), IDTOP(KLON), ICTOP0(KLON)
    INTEGER(KIND=JPIM) :: IDPL(KLON)
    REAL(KIND=JPRB) :: ZCAPE(KLON), ZCAPE2(KLON), ZHEAT(KLON), ZCAPPBL(KLON), ZCAPDCYCL(KLON)
    LOGICAL :: LLDDRAF(KLON), LLDDRAF3(KLON), LLDCUM(KLON), LLSCVFLAG(KLON)
    LOGICAL :: LLO1, LLO2(KLON), LLO3
    INTEGER(KIND=JPIM) :: IKB, IKD, ITOPM2, JK, IK, JL
    REAL(KIND=JPRB) ::   ZCONS2, ZCONS, ZDH, ZDH2, ZDQMIN, ZDZ, ZEPS, ZFAC, ZMFMAX, ZPBMPT, ZQUMQE, ZRO, ZMFA, ZERATE, ZDERATE, ZORCPD, ZRDOCPD, ZDUTEN, ZDVTEN, ZTDIS, ZTAURES, ZAR, ZAS, ZBR, ZBS, ZAK, ZRG
    REAL(KIND=JPRB) :: ZTAU(KLON), ZTAUPBL(KLON)
    REAL(KIND=JPRB) :: ZXTAU(KLON)
    LOGICAL :: LLPERT_RTAU
    INTEGER(KIND=JPIM) :: IPRTAU
    INTEGER(KIND=JPIM) :: IPN
    TYPE(SPP_PERT) :: PN1
    REAL(KIND=JPRB) :: ZMFS(KLON),  ZMFUUS(KLON,KLEV), ZMFDUS(KLON,KLEV) , ZMFUDR(KLON,KLEV), ZMFDDR(KLON,KLEV) , ZTENU(KLON,KLEV),  ZTENV(KLON,KLEV) , ZMFUUB(KLON), ZMFUVB(KLON), ZMF_SHAL(KLON), ZKMFL(KLON), ZDMFUPC(KLON,KLEV), ZDMFDPC(KLON,KLEV), ZSCAV(KTRAC), ZUV2(KLON,KLEV), ZSUM12(KLON), ZSUM22(KLON)
    integer(JPIM) :: native_child_status
    REAL(KIND=JPRB) :: FOEDELTA
    REAL(KIND=JPRB) :: PTARE
    FOEDELTA(PTARE) = MAX(0.0_JPRB, SIGN(1.0_JPRB, PTARE - constants%rtt))
    REAL(KIND=JPRB) :: FOEEW, FOEDE, FOEDESU, FOELH, FOELDCP
    FOEEW ( PTARE ) = thermal%r2es*source_exp( (thermal%r3les*FOEDELTA(PTARE)+thermal%r3ies*(1.0_JPRB-FOEDELTA(PTARE)))*(PTARE-constants%rtt) / (PTARE-(thermal%r4les*FOEDELTA(PTARE)+thermal%r4ies*(1.0_JPRB-FOEDELTA(PTARE)))))
    FOEDE ( PTARE ) = (FOEDELTA(PTARE)*thermal%r5alvcp+(1.0_JPRB-FOEDELTA(PTARE))*thermal%r5alscp) / source_power((PTARE-(thermal%r4les*FOEDELTA(PTARE)+thermal%r4ies*(1.0_JPRB-FOEDELTA(PTARE)))),2)
    FOEDESU ( PTARE ) = (FOEDELTA(PTARE)*thermal%r5les+(1.0_JPRB-FOEDELTA(PTARE))*thermal%r5ies) / source_power((PTARE-(thermal%r4les*FOEDELTA(PTARE)+thermal%r4ies*(1.0_JPRB-FOEDELTA(PTARE)))),2)
    FOELH(PTARE) = FOEDELTA(PTARE)*constants%rlvtt + (1.0_JPRB - FOEDELTA(PTARE))*constants%rlstt
    FOELDCP(PTARE) = FOEDELTA(PTARE)*thermal%ralvdcp + (1.0_JPRB - FOEDELTA(PTARE))*thermal%ralsdcp
    REAL(KIND=JPRB) :: FOEALFA
FOEALFA (PTARE) = MIN(1.0_JPRB,source_power(((MAX(thermal%rtice,MIN(thermal%rtwat,PTARE))-thermal%rtice) *thermal%rtwat_rtice_r),2))
    REAL(KIND=JPRB) :: FOEEWM, FOEDEM, FOELDCPM, FOELHM, FOE_DEWM_DT
    FOEEWM ( PTARE ) = thermal%r2es * (FOEALFA(PTARE)*source_exp(thermal%r3les*(PTARE-constants%rtt)/(PTARE-thermal%r4les))+ (1.0_JPRB-FOEALFA(PTARE))*source_exp(thermal%r3ies*(PTARE-constants%rtt)/(PTARE-thermal%r4ies)))
    FOE_DEWM_DT( PTARE ) = thermal%r2es * ( thermal%r3les*FOEALFA(PTARE)*source_exp(thermal%r3les*(PTARE-constants%rtt)/(PTARE-thermal%r4les)) *(constants%rtt-thermal%r4les)/source_power((PTARE-thermal%r4les),2)+ thermal%r3ies*(1.0-FOEALFA(PTARE))*source_exp(thermal%r3ies*(PTARE-constants%rtt)/(PTARE-thermal%r4ies)) *(constants%rtt-thermal%r4ies)/source_power((PTARE-thermal%r4ies),2))
    FOEDEM ( PTARE ) = FOEALFA(PTARE)*thermal%r5alvcp*(1.0_JPRB/source_power((PTARE-thermal%r4les),2))+ (1.0_JPRB-FOEALFA(PTARE))*thermal%r5alscp*(1.0_JPRB/source_power((PTARE-thermal%r4ies),2))
    FOELDCPM(PTARE) = FOEALFA(PTARE)*thermal%ralvdcp + (1.0_JPRB - FOEALFA(PTARE))*thermal%ralsdcp
    FOELHM(PTARE) = FOEALFA(PTARE)*constants%rlvtt + (1.0_JPRB - FOEALFA(PTARE))*constants%rlstt
    REAL(KIND=JPRB) :: FOETB
    FOETB ( PTARE )=FOEALFA(PTARE)*thermal%r3les*(constants%rtt-thermal%r4les)*(1.0_JPRB/source_power((PTARE-thermal%r4les),2))+ (1.0_JPRB-FOEALFA(PTARE))*thermal%r3ies*(constants%rtt-thermal%r4ies)*(1.0_JPRB/source_power((PTARE-thermal%r4ies),2))
    REAL(KIND=JPRB) :: FOEALFCU
    FOEALFCU (PTARE) = MIN(1.0_JPRB,source_power(((MAX(thermal%rticecu,MIN(thermal%rtwat,PTARE)) -thermal%rticecu)*thermal%rtwat_rticecu_r),2))
    REAL(KIND=JPRB) :: FOEEWMCU, FOEDEMCU, FOELDCPMCU, FOELHMCU
    FOEEWMCU ( PTARE ) = thermal%r2es * (FOEALFCU(PTARE)*source_exp(thermal%r3les*(PTARE-constants%rtt)/(PTARE-thermal%r4les))+ (1.0_JPRB-FOEALFCU(PTARE))*source_exp(thermal%r3ies*(PTARE-constants%rtt)/(PTARE-thermal%r4ies)))
    FOEDEMCU ( PTARE )=FOEALFCU(PTARE)*thermal%r5alvcp*(1.0_JPRB/source_power((PTARE-thermal%r4les),2))+ (1.0_JPRB-FOEALFCU(PTARE))*thermal%r5alscp*(1.0_JPRB/source_power((PTARE-thermal%r4ies),2))
    FOELDCPMCU(PTARE) = FOEALFCU(PTARE)*thermal%ralvdcp + (1.0_JPRB - FOEALFCU(PTARE))*thermal%ralsdcp
    FOELHMCU(PTARE) = FOEALFCU(PTARE)*constants%rlvtt + (1.0_JPRB - FOEALFCU(PTARE))*constants%rlstt
    REAL(KIND=JPRB) :: FOEEWMO, FOEELIQ, FOEEICE, FOEELIQ2ICE, FOELSON
    FOEEWMO(PTARE) = thermal%r2es*source_exp(thermal%r3les*(PTARE - constants%rtt)/(PTARE - thermal%r4les))
    FOEELIQ(PTARE) = thermal%r2es*source_exp(thermal%r3les*(PTARE - constants%rtt)/(PTARE - thermal%r4les))
    FOEEICE(PTARE) = thermal%r2es*source_exp(thermal%r3ies*(PTARE - constants%rtt)/(PTARE - thermal%r4ies))
    FOEELIQ2ICE( PTARE )  = source_exp(      (PTARE-constants%rtt)*(thermal%r3les/(PTARE-thermal%r4les) - thermal%r3ies/(PTARE-thermal%r4ies)))
    FOELSON( PTARE ) = source_exp( -6096.9385_JPRB/PTARE + 21.2409642_JPRB - 2.711193E-2_JPRB * PTARE + 1.673952E-5_JPRB * source_power(PTARE,2)+ 2.433502_JPRB * source_log(PTARE))
    REAL(KIND=JPRB) :: FOEEWM_V, FOEEWMCU_V, FOELES_V, FOEIES_V
    REAL(KIND=JPRB) :: EXP1, EXP2
    FOELES_V(PTARE) = thermal%r3les*(PTARE - constants%rtt)/(PTARE - thermal%r4les)
    FOEIES_V(PTARE) = thermal%r3ies*(PTARE - constants%rtt)/(PTARE - thermal%r4ies)
    FOEEWM_V(PTARE, EXP1, EXP2) = thermal%r2es*(FOEALFA(PTARE)*EXP1 + (1.0_JPRB - FOEALFA(PTARE))*EXP2)
    FOEEWMCU_V(PTARE, EXP1, EXP2) = thermal%r2es*(FOEALFCU(PTARE)*EXP1 + (1.0_JPRB - FOEALFCU(PTARE))*EXP2)
    status = 0_JPIM
    ASSOCIATE(LMFCUCA=>parameters%convection%LMFCUCA, LMFDD=>parameters%convection%LMFDD, LMFDUDV=>parameters%convection%LMFDUDV, LMFPEN=>parameters%convection%LMFPEN, LMFSCV=>parameters%convection%LMFSCV, LMFSMOOTH=>parameters%convection%LMFSMOOTH, LMFUVDIS=>parameters%convection%LMFUVDIS, LMFWSTAR=>parameters%convection%LMFWSTAR, NJKT1=>parameters%convection%NJKT1, NJKT2=>parameters%convection%NJKT2, NJKT3=>parameters%convection%NJKT3, NJKT5=>parameters%convection%NJKT5, RCAPDCYCL=>parameters%convection%RCAPDCYCL, RDEPTHS=>parameters%convection%RDEPTHS, RCUCOV =>parameters%convection%RCUCOV, RMFCFL=>parameters%convection%RMFCFL, RMFCMIN=>parameters%convection%RMFCMIN, RMFLIA=>parameters%convection%RMFLIA, RMFSOLCT=>parameters%convection%RMFSOLCT, RCAPQADV=>parameters%convection%RCAPQADV, RMFSOLTQ=>parameters%convection%RMFSOLTQ, RMFSOLUV=>parameters%convection%RMFSOLUV, RMINCAPE=>parameters%convection%RMINCAPE, RTAUA=>parameters%convection%RTAUA, RUVPER=>parameters%convection%RUVPER, RMFADVW=>parameters%convection%RMFADVW,RMFADVWDD=>parameters%convection%RMFADVWDD, LMFSCAV=>configuration%ecmwf_physics%LMFSCAV, LMFTRAC=>configuration%ecmwf_physics%LMFTRAC, LELIGHT=>configuration%ecmwf_physics%LELIGHT, LCHEM_LIGHT=>chem_light_active)
      ZCONS2 = RMFCFL/(constants%rg*PTSPHY)
      ZCONS = 1.0_JPRB/(constants%rg*PTSPHY)
      ZORCPD = 1.0_JPRB/constants%rcpd
      ZRDOCPD = constants%rd*ZORCPD
      ZRG = 1.0_JPRB/constants%rg
      ZTAU(:) = 0.0
      IF (YDSPP_CONFIG%LSPP) THEN
        IPN = YDSPP_CONFIG%PPTR%RTAU
        LLPERT_RTAU = IPN > 0
        IF (LLPERT_RTAU) THEN
          PN1 = YDSPP_CONFIG%SM%PN(IPN)
          IPRTAU = PN1%MP
        END IF
      ELSE
        LLPERT_RTAU = .FALSE.
      END IF
      DO JL = KIDIA, KFDIA
        PCAPE(JL) = 0.0_JPRB
        PVDISCU(JL) = 0.0_JPRB
        LDCUM(JL) = .FALSE.
      END DO
    native_child_status=cuinin(constants,thermal, configuration%linear_ecmwf,  parameters%convection, KIDIA,    KFDIA,    KLON,     KLEV, PTEN,     PQEN,     PQSEN,    PUEN,     PVEN, PGEO,     PAPH, ILAB, ZTENH,    ZQENH,    ZQSENH,   PGEOH, PTU,      PQU,      ZTD,      ZQD, ZUU,      ZVU,      ZUD,      ZVD, PLU     )
      if (native_child_status /= 0) then
        status = native_child_status
        return
      end if
      ZKMFL(:) = 0.0_JPRB
    native_child_status=cubasen(constants,thermal,rplrg,rpldare, configuration%linear_ecmwf,configuration%cloud,parameters%convection, YDSPP_CONFIG, KIDIA,    KFDIA,    KLON,     KLEV,     NJKT1,  .FALSE., ZTENH,    ZQENH,    PGEOH,    PAPH, PQHFL,    PAHFS,    PGP2DSPP, ZKMFL, PTEN,     PQEN,     PQSEN,    PGEO, PTU,      PQU,      PLU,      ZKINEU,   ZWUBASE, ILAB,     LDCUM,    LDSC,     KCBOT,    KBOTSC, ICTOP0,   IDPL,     PCAPE )
      if (native_child_status /= 0) then
        status = native_child_status
        return
      end if
      DO JL = KIDIA, KFDIA
        ZDHPBL(JL) = 0.0_JPRB
        IDTOP(JL) = 0
        ZCAPPBL(JL) = 0.
        ZKHVFL(JL) = (-PAHFS(JL, KLEV + 1)*ZORCPD - constants%retv*PTEN(JL, KLEV)*PQHFL(JL, KLEV + 1))/(RPLRG*RPLDARE)
        ZKHFL(JL) = (-PAHFS(JL, KLEV + 1) - constants%rlvtt*PQHFL(JL, KLEV + 1))/(RPLRG*RPLDARE)
      END DO
      DO JK = NJKT2, KLEV
      DO JL = KIDIA, KFDIA
      IF (LDCUM(JL) .AND. JK >= KCBOT(JL)) THEN
        ZDZ = (PAPH(JL, JK + 1) - PAPH(JL, JK))
        ZDHPBL(JL) = ZDHPBL(JL) + (constants%rlvtt*PTENQ(JL, JK) + constants%rcpd*PTENT(JL, JK))*ZDZ
        ZCAPPBL(JL) = ZCAPPBL(JL) + (PTENT(JL, JK) + constants%retv*PTEN(JL, JK)*PTENQ(JL, JK))*ZDZ
      END IF
      END DO
      END DO
      DO JL = KIDIA, KFDIA
      IF (LDCUM(JL)) THEN
        IKB = KCBOT(JL)
        ITOPM2 = ICTOP0(JL)
        ZPBMPT = PAPH(JL, IKB) - PAPH(JL, ITOPM2)
        IF (ZPBMPT >= RDEPTHS) THEN
          KTYPE(JL) = 1
        ELSE
          KTYPE(JL) = 2
        END IF
      ELSE
        KTYPE(JL) = 0
      END IF
      END DO
      IF (LMFWSTAR) THEN
      DO JL = KIDIA, KFDIA
      IF (LDCUM(JL)) THEN
        IKB = KCBOT(JL)
        ZDZ = MAX(0.0_JPRB, MIN(1.5E3_JPRB, (PGEOH(JL, IKB) - PGEOH(JL, KLEV + 1))/constants%rg))
        ZMF_SHAL(JL) = 0.07_JPRB*source_power((constants%rg/PTEN(JL, KLEV)*ZDZ*MAX(0.0_JPRB, ZKHVFL(JL))), .3333)
        ZMFMAX = (PAPH(JL, IKB) - PAPH(JL, IKB - 1))*ZCONS2
        ZMF_SHAL(JL) = MIN(ZMF_SHAL(JL), ZMFMAX)
      END IF
      END DO
      END IF
      DO JL = KIDIA, KFDIA
      IF (LDCUM(JL)) THEN
        IKB = KCBOT(JL)
        ZMFMAX = (PAPH(JL, IKB) - PAPH(JL, IKB - 1))*ZCONS2
        IF (KTYPE(JL) == 1) THEN
          ZMFUB(JL) = ZMFMAX*0.1_JPRB
        ELSEIF (KTYPE(JL) == 2) THEN
          ZQUMQE = PQU(JL, IKB) + PLU(JL, IKB) - ZQENH(JL, IKB)
          ZDQMIN = MAX(0.01_JPRB*ZQENH(JL, IKB), 1.E-10_JPRB)
          ZDH = constants%rcpd*(PTU(JL, IKB) - ZTENH(JL, IKB)) + constants%rlvtt*ZQUMQE
          ZDH = constants%rg*MAX(ZDH, 1.E5_JPRB*ZDQMIN)
          IF (ZDHPBL(JL) > 0.0_JPRB) THEN
            ZMFUB(JL) = ZDHPBL(JL)/ZDH
            ZMFUB(JL) = MIN(ZMFUB(JL), ZMFMAX)
          ELSE
            ZMFUB(JL) = ZMFMAX*0.1_JPRB
            LDCUM(JL) = .FALSE.
          END IF
          IF (LMFWSTAR) ZMFUB(JL) = ZMF_SHAL(JL)
        END IF
      ELSE
        ZMFUB(JL) = 0.0_JPRB
      END IF
      END DO
    call cuascn(constants,thermal, configuration%linear_ecmwf,configuration%cloud,parameters%convection,YDSPP_CONFIG,NACTAERO, KIDIA,    KFDIA,    KLON,    KLEV, PTSPHY, ZTENH,    ZQENH,    PUEN,     PVEN, PTEN,     PQEN,     PQSEN,    PLITOT, PGEO,     PGEOH,    PAP,      PAPH, PVERVEL,  ZWUBASE,  PGP2DSPP, LDLAND,   LDCUM,    KTYPE,    ILAB,     LLSCVFLAG, PTU,      PQU,      PLU,      PLRAIN, PMFU,     ZMFUB,    ZLGLAC, ZMFUS,    ZMFUQ,    ZMFUL,    PLUDE,    PLUDELI,       ZDMFUP, PLCRIT_AER, ZDMFEN, KCBOT,    KCTOP,    ICTOP0,   IDPL,     PMFUDE_RATE,   ZKINEU,   PWMEAN )
      DO JL = KIDIA, KFDIA
      IF (LDCUM(JL)) THEN
        IKB = KCBOT(JL)
        ITOPM2 = KCTOP(JL)
        ZPBMPT = PAPH(JL, IKB) - PAPH(JL, ITOPM2)
        IF (KTYPE(JL) == 1 .AND. ZPBMPT < RDEPTHS) KTYPE(JL) = 2
        IF (KTYPE(JL) == 2 .AND. ZPBMPT >= RDEPTHS) KTYPE(JL) = 1
        ICTOP0(JL) = KCTOP(JL)
      END IF
      ZRFL(JL) = ZDMFUP(JL, 1)
      END DO
      DO JK = 2, KLEV
      DO JL = KIDIA, KFDIA
        ZRFL(JL) = ZRFL(JL) + ZDMFUP(JL, JK)
      END DO
      END DO
      DO JK = 1, KLEV
      DO JL = KIDIA, KFDIA
        PMFD(JL, JK) = 0.0_JPRB
        ZMFDS(JL, JK) = 0.0_JPRB
        ZMFDQ(JL, JK) = 0.0_JPRB
        ZDMFDP(JL, JK) = 0.0_JPRB
        ZDPMEL(JL, JK) = 0.0_JPRB
      END DO
      END DO
      DO JK = 1, KLEV
      DO JL = KIDIA, KFDIA
        ZTENU(JL, JK) = PTENU(JL, JK)
        ZTENV(JL, JK) = PTENV(JL, JK)
      END DO
      END DO
      IF (LMFDD) THEN
    call cudlfsn(constants,thermal, configuration%linear_ecmwf,parameters%convection, KIDIA,    KFDIA,    KLON,     KLEV, KCBOT,    KCTOP,    LDCUM, ZTENH,    ZQENH,    PTEN,     PQSEN,    PGEO, PGEOH,    PAPH,     PTU,      PQU, ZMFUB,    ZRFL, ZTD,      ZQD, PMFD,     ZMFDS,    ZMFDQ,    ZDMFDP, IDTOP,    LLDDRAF )
    native_child_status=cuddrafn(constants,thermal, configuration%linear_ecmwf,parameters%convection, KIDIA,    KFDIA,    KLON,    KLEV, LLDDRAF, ZTENH,    ZQENH,    PQSEN, PGEO,     PGEOH,    PAPH,     ZRFL, ZTD,      ZQD,      PMFU, PMFD,     ZMFDS,    ZMFDQ,    ZDMFDP, ZDMFDE,   PMFDDE_RATE,        ZKINED )
        if (native_child_status /= 0) then
          status = native_child_status
          return
        end if
      END IF
      DO JL = KIDIA, KFDIA
        ZHEAT(JL) = 0.0_JPRB
        ZCAPE(JL) = 0.0_JPRB
        ZCAPE2(JL) = 0.0_JPRB
        ZMFUB1(JL) = ZMFUB(JL)
        ZDQCV(JL) = 0.0_JPRB
        ZSATFR(JL) = 0.0_JPRB
        ZDX(JL) = 2*constants%ra*SQRT(constants%rpi*PGAW(JL))
        ZDX(JL) = MAX(ZDX(JL), 1.E2_JPRB)
      END DO
      DO JK = NJKT2, KLEV
      DO JL = KIDIA, KFDIA
        LLO1 = LDCUM(JL) .AND. KTYPE(JL) == 1
        LLO3 = LLO1 .AND. JK <= KCBOT(JL) .AND. JK > KCTOP(JL)
        IF (LLO3) THEN
          ZDZ = (PGEO(JL, JK - 1) - PGEO(JL, JK))
    ZHEAT(JL)=ZHEAT(JL) +MAX(0.0_JPRB, (  (PTEN(JL,JK-1)-PTEN(JL,JK) + ZDZ*ZORCPD)/ZTENH(JL,JK) +  constants%retv*(PQEN(JL,JK-1)-PQEN(JL,JK))  ) * (constants%rg*(PMFU(JL,JK)+PMFD(JL,JK))) )
          ZDZ = (PAP(JL, JK) - PAP(JL, JK - 1))
         ZCAPE(JL)=ZCAPE(JL) + ((PTU(JL,JK)-ZTENH(JL,JK))/ZTENH(JL,JK) +constants%retv*(PQU(JL,JK)-ZQENH(JL,JK)) -PLU(JL,JK) ) * ZDZ
        END IF
        IF (LLO3 .AND. RCAPQADV > 0.0_JPRB) THEN
          ZTENH2(JL, JK) = ZTENH(JL, JK) - 0.5_JPRB*(PTENTA(JL, JK) + PTENTA(JL, JK - 1))*PTSPHY
          ZQENH2(JL, JK) = ZQENH(JL, JK) - 0.5_JPRB*(PTENQA(JL, JK) + PTENQA(JL, JK - 1))*PTSPHY
    ZCAPE2(JL)=ZCAPE2(JL) + ((PTU(JL,JK)-ZTENH2(JL,JK))/ZTENH2(JL,JK) +constants%retv*(PQU(JL,JK)-ZQENH2(JL,JK)) -PLU(JL,JK) ) * ZDZ
        END IF
        IF (LLO1) THEN
          ZDZ = (PAPH(JL, JK + 1) - PAPH(JL, JK))
          ZDQCV(JL) = ZDQCV(JL) + PTENQA(JL, JK)*ZDZ*(PQEN(JL, JK)/PQSEN(JL, JK))
        END IF
        IF (LLO1 .AND. JK >= KCTOP(JL)) THEN
          ZDZ = (PAPH(JL, JK + 1) - PAPH(JL, JK))
          ZSATFR(JL) = ZSATFR(JL) + (PQEN(JL, JK)/PQSEN(JL, JK))*ZDZ
        END IF
      END DO
      END DO
      DO JL = KIDIA, KFDIA
        ZCAPDCYCL(JL) = 0.0_JPRB
        ZTAU(JL) = 0.0_JPRB
        IF (LDCUM(JL) .AND. KTYPE(JL) == 1) THEN
          ZTAURES = 1.0_JPRB + 1.60_JPRB*ZDX(JL)/125.E3_JPRB
          IF (ZDX(JL) < 8.E3_JPRB) THEN
            ZTAURES = 1.0_JPRB + source_power((source_log(8.E3_JPRB/ZDX(JL))), 2)
          END IF
          IF (ZDX(JL) > 125.E3_JPRB) ZTAURES = MIN(3.0_JPRB, ZTAURES)
          IKD = IDPL(JL)
          IKB = KCBOT(JL)
          IK = KCTOP(JL)
          ZTAU(JL) = (PGEOH(JL, IK) - PGEOH(JL, IKB))/((2.0_JPRB + MIN(15.0_JPRB, PWMEAN(JL)))*constants%rg)*ZTAURES*RTAUA
          IF (LLPERT_RTAU) THEN
            ZXTAU(JL) = ZTAU(JL)*source_exp(PN1%MU(1) + PN1%XMAG(1)*PGP2DSPP(JL, IPRTAU))
          ELSE
            ZXTAU(JL) = ZTAU(JL)
          END IF
          LLO1 = PAPH(JL, KLEV + 1) - PAPH(JL, IKD) < 50.E2_JPRB
          IF (LLO1 .AND. LDLAND(JL) .AND. RCAPDCYCL == 1.0_JPRB) THEN
            ZDZ = MIN(1.E4_JPRB, PGEOH(JL, IKB) - PGEOH(JL, KLEV + 1))/constants%rg
            ZCAPDCYCL(JL) = ZXTAU(JL)*MAX(0.0_JPRB, ZKHVFL(JL))*constants%rcpd/ZDZ
          END IF
          IF (LLO1 .AND. RCAPDCYCL == 2.0_JPRB) THEN
          IF (LDLAND(JL)) THEN
            ZCAPDCYCL(JL) = ZCAPPBL(JL)*ZTAU(JL)/ZTAURES
          ELSE
    ZDUTEN=2.0_JPRB+SQRT(0.5*(source_power(PUEN(JL,IKB),2)+source_power(PVEN(JL,IKB),2)+source_power(PUEN(JL,NJKT3),2)+source_power(PVEN(JL,NJKT3),2)))
            ZTAUPBL(JL) = MIN(1.E4_JPRB, PGEOH(JL, IKB) - PGEOH(JL, KLEV + 1))/(constants%rg*ZDUTEN)
            ZCAPDCYCL(JL) = ZCAPPBL(JL)*ZTAUPBL(JL)
          END IF
          END IF
          ZDQCV(JL) = ZDQCV(JL)*constants%rlvtt/PGEOH(JL, IK)*ZXTAU(JL)/MAX(1.25_JPRB, ZTAURES)*RCAPQADV
          ZSATFR(JL) = ZSATFR(JL)/(PAPH(JL, KLEV + 1) - PAPH(JL, IK))
        ELSE
          ZTAU(JL) = 0.0_JPRB
        END IF
      END DO
      IF (LMFCUCA) THEN
      DO JL = KIDIA, KFDIA
        ZFACCA(JL) = MAX(0.3_JPRB, MIN(1.8_JPRB, PCUCONVCA(JL)))
      END DO
      ELSE
      ZFACCA(KIDIA:KFDIA) = 1.0_JPRB
      END IF
      DO JL = KIDIA, KFDIA
      IF (LDCUM(JL) .AND. KTYPE(JL) == 1) THEN
        IKB = KCBOT(JL)
        ZCAPE2(JL) = RCAPQADV*ZCAPE2(JL) + (1.0_JPRB - RCAPQADV)*ZCAPE(JL)
        ZCAPDCYCL(JL) = MAX(ZCAPDCYCL(JL), -2*ZCAPE2(JL))
        IF (ZSATFR(JL) <= 0.94 .OR. PVERVEL(JL, NJKT5) < -100._JPRB) THEN
          ZCAPE(JL) = MAX(RMINCAPE*ZCAPE(JL), ZCAPE2(JL) - ZCAPDCYCL(JL) + ZDQCV(JL))
        ELSE
          ZCAPE(JL) = MAX(RMINCAPE*ZCAPE(JL), ZCAPE(JL) - ZCAPDCYCL(JL))
        END IF
        ZCAPE(JL) = MIN(ZCAPE(JL), 5000.0_JPRB)
        ZHEAT(JL) = MAX(1.E-4_JPRB, ZHEAT(JL))
        ZXTAU(JL) = MAX(3.6E3_JPRB/(5.0_JPRB*RPLRG*RPLDARE), MIN(3.0_JPRB*3.6E3_JPRB/(RPLRG*RPLDARE), ZXTAU(JL)))
        ZMFUB1(JL) = (ZCAPE(JL)*ZMFUB(JL))/(ZHEAT(JL)*ZXTAU(JL))
        ZMFUB1(JL) = MAX(ZMFUB1(JL), 0.001_JPRB)*ZFACCA(JL)
        ZMFMAX = (PAPH(JL, IKB) - PAPH(JL, IKB - 1))*ZCONS2
        ZMFUB1(JL) = MIN(ZMFUB1(JL), ZMFMAX)
      END IF
      END DO
      DO JL = KIDIA, KFDIA
      IF (LDCUM(JL) .AND. KTYPE(JL) >= 2) THEN
        IKB = KCBOT(JL)
        IF (PMFD(JL, IKB) < 0.0_JPRB) THEN
          ZEPS = -PMFD(JL, IKB)/MAX(ZMFUB(JL), 1.E-10_JPRB)
        ELSE
          ZEPS = 0.0_JPRB
        END IF
        ZMFMAX = (PAPH(JL, IKB) - PAPH(JL, IKB - 1))*ZCONS2
        IF (KTYPE(JL) == 2) THEN
        IF (ZDHPBL(JL) > 0.0_JPRB) THEN
          ZQUMQE = PQU(JL, IKB) + PLU(JL, IKB) - ZEPS*ZQD(JL, IKB) - (1.0_JPRB - ZEPS)*ZQENH(JL, IKB)
          ZDH = constants%rcpd*(PTU(JL, IKB) - ZEPS*ZTD(JL, IKB) - (1.0_JPRB - ZEPS)*ZTENH(JL, IKB)) + constants%rlvtt*ZQUMQE
    ZDH2 = constants%rcpd*(PTU(JL, IKB - 1) - ZEPS*ZTD(JL, IKB - 1) - (1.0_JPRB - ZEPS)*ZTENH(JL, IKB - 1)) + constants%rlvtt*ZQUMQE
          ZDH = 0.5_JPRB*(ZDH + ZDH2)
          ZDH = constants%rg*MAX(ZDH, 0.1_JPRB*constants%rcpd)
          ZMFUB1(JL) = ZDHPBL(JL)/ZDH
          IF (ZMFUB1(JL) > 0.9_JPRB*ZMFMAX/RMFCFL .AND. ZDH < 0.5_JPRB*constants%rg*constants%rcpd) THEN
            ZDH = 0.75_JPRB*constants%rcpd*constants%rg
            ZMFUB1(JL) = ZDHPBL(JL)/ZDH
          END IF
        ELSE
          ZMFUB1(JL) = ZMFUB(JL)
        END IF
        IF (LMFWSTAR) ZMFUB1(JL) = ZMF_SHAL(JL)
        ZMFUB1(JL) = MIN(ZMFUB1(JL), ZMFMAX)
        END IF
        IF (KTYPE(JL) == 3) THEN
          ZMFUB1(JL) = MAX(ZMFUB(JL), 5*ZKHFL(JL)/MAX(1.E2_JPRB, PGEOH(JL, IKB)))*(1.0_JPRB + ZEPS)
          IF (PGEOH(JL, IKB) < 1.5E3_JPRB) THEN
            ZMFUB1(JL) = MIN(ZMFUB1(JL), ZMFMAX/(1.05_JPRB*RMFCFL))
          ELSE
            ZMFUB1(JL) = MIN(ZMFUB1(JL), ZMFMAX)
          END IF
        END IF
      END IF
      END DO
      DO JK = 1, KLEV
      DO JL = KIDIA, KFDIA
      IF (LLDDRAF(JL) .AND. (KTYPE(JL) == 1 .OR. KTYPE(JL) == 2)) THEN
        ZFAC = ZMFUB1(JL)/MAX(ZMFUB(JL), 1.E-10_JPRB)
        PMFD(JL, JK) = PMFD(JL, JK)*ZFAC
        ZMFDS(JL, JK) = ZMFDS(JL, JK)*ZFAC
        ZMFDQ(JL, JK) = ZMFDQ(JL, JK)*ZFAC
        ZDMFDP(JL, JK) = ZDMFDP(JL, JK)*ZFAC
        PMFDDE_RATE(JL, JK) = PMFDDE_RATE(JL, JK)*ZFAC
      END IF
      END DO
      END DO
      DO JL = KIDIA, KFDIA
      IF (LDCUM(JL)) THEN
        ZMFS(JL) = ZMFUB1(JL)/MAX(RMFCMIN, ZMFUB(JL))
      END IF
      END DO
      DO JK = 2, KLEV
      DO JL = KIDIA, KFDIA
      IF (LDCUM(JL) .AND. JK >= KCTOP(JL) - 1) THEN
        IKB = KCBOT(JL)
        IF (JK > IKB) THEN
          ZDZ = ((PAPH(JL, KLEV + 1) - PAPH(JL, JK))/(PAPH(JL, KLEV + 1) - PAPH(JL, IKB)))
          PMFU(JL, JK) = PMFU(JL, IKB)*ZDZ
        END IF
        ZMFMAX = (PAPH(JL, JK) - PAPH(JL, JK - 1))*ZCONS2
        ZMFMAX = MIN(ZMFMAX, RMFLIA)
        IF (PMFU(JL, JK)*ZMFS(JL) > ZMFMAX) THEN
          ZMFS(JL) = MIN(ZMFS(JL), ZMFMAX/PMFU(JL, JK))
          ZMFS(JL) = MAX(ZMFS(JL), 1.E-10_JPRB)
        END IF
      END IF
      END DO
      END DO
      IF (RMFADVW > 0.0_JPRB) THEN
      DO JK = 2, KLEV - 1
      DO JL = KIDIA, KFDIA
      IF (KTYPE(JL) == 1 .AND. JK >= KCTOP(JL) - 1) THEN
    ZFAC=ZMFS(JL)*constants%rg*RMFADVW*(PMFU(JL,JK)-PMFU(JL,JK+1)+RMFADVWDD*(PMFD(JL,JK)-PMFD(JL,JK+1)))/ (PAPH(JL,JK)-PAPH(JL,JK+1))*PTSPHY
        IF (ABS(ZFAC) > 0.98_JPRB) ZMFS(JL) = ZMFS(JL)/MAX(1.02_JPRB, ABS(ZFAC))
      END IF
      END DO
      END DO
      JK = KLEV
      DO JL = KIDIA, KFDIA
      IF (KTYPE(JL) == 1) THEN
        ZFAC = ZMFS(JL)*constants%rg*RMFADVW*(PMFU(JL, JK) + RMFADVWDD*PMFD(JL, JK))/(PAPH(JL, JK) - PAPH(JL, JK + 1))*PTSPHY
        IF (ABS(ZFAC) > 0.98_JPRB) ZMFS(JL) = ZMFS(JL)/MAX(1.02_JPRB, ABS(ZFAC))
      END IF
      END DO
      END IF
      DO JK = 2, KLEV
      DO JL = KIDIA, KFDIA
      IF (LDCUM(JL) .AND. JK <= KCBOT(JL) .AND. JK >= KCTOP(JL) - 1) THEN
        PMFU(JL, JK) = PMFU(JL, JK)*ZMFS(JL)
        ZMFUS(JL, JK) = ZMFUS(JL, JK)*ZMFS(JL)
        ZMFUQ(JL, JK) = ZMFUQ(JL, JK)*ZMFS(JL)
        ZMFUL(JL, JK) = ZMFUL(JL, JK)*ZMFS(JL)
        ZDMFUP(JL, JK) = ZDMFUP(JL, JK)*ZMFS(JL)
        ZDMFEN(JL, JK) = ZDMFEN(JL, JK)*ZMFS(JL)
        PLUDE(JL, JK) = PLUDE(JL, JK)*ZMFS(JL)
        PLUDELI(JL, JK, 1) = PLUDELI(JL, JK, 1)*ZMFS(JL)
        PLUDELI(JL, JK, 2) = PLUDELI(JL, JK, 2)*ZMFS(JL)
        PMFUDE_RATE(JL, JK) = PMFUDE_RATE(JL, JK)*ZMFS(JL)
      END IF
      END DO
      END DO
      DO JL = KIDIA, KFDIA
      IF (KTYPE(JL) == 2 .AND. KCBOT(JL) == KCTOP(JL) .AND. KCBOT(JL) >= KLEV - 1) THEN
        LDCUM(JL) = .FALSE.
        KTYPE(JL) = 0
      END IF
      END DO
      DO JL = KIDIA, KFDIA
        LLO2(JL) = .FALSE.
        IF ((.NOT. LDSHCV(JL) .AND. KTYPE(JL) == 2)) THEN
          LLO2(JL) = .TRUE.
          LDCUM(JL) = .FALSE.
        END IF
      END DO
      IF (LELIGHT .OR. LCHEM_LIGHT) THEN
      DO JL = KIDIA, KFDIA
        LDCUM_LIG(JL) = LDCUM(JL)
        KCTOP_LIG(JL) = KCTOP(JL)
        KCBOT_LIG(JL) = KCBOT(JL)
      END DO
      END IF
      IF (.NOT. LMFSCV .OR. .NOT. LMFPEN) THEN
      DO JL = KIDIA, KFDIA
      IF ((.NOT. LMFSCV .AND. KTYPE(JL) == 2) .OR. (.NOT. LMFPEN .AND. KTYPE(JL) == 1)) THEN
        LLO2(JL) = .TRUE.
        LDCUM(JL) = .FALSE.
      END IF
      END DO
      END IF
      DO JL = KIDIA, KFDIA
      IF (LLDDRAF(JL) .AND. IDTOP(JL) <= KCTOP(JL)) THEN
        IDTOP(JL) = KCTOP(JL) + 1
      END IF
      END DO
      DO JK = 2, KLEV
      DO JL = KIDIA, KFDIA
      IF (LLDDRAF(JL)) THEN
      IF (JK < IDTOP(JL)) THEN
        PMFD(JL, JK) = 0.0_JPRB
        ZMFDS(JL, JK) = 0.0_JPRB
        ZMFDQ(JL, JK) = 0.0_JPRB
        PMFDDE_RATE(JL, JK) = 0.0_JPRB
        ZDMFDP(JL, JK) = 0.0_JPRB
      ELSEIF (JK == IDTOP(JL)) THEN
        PMFDDE_RATE(JL, JK) = 0.0_JPRB
      END IF
      END IF
      END DO
      END DO
    call cuflxn(constants,thermal, configuration%linear_ecmwf,parameters%convection, KIDIA,    KFDIA,    KLON,     KLEV, PTSPHY, PTEN,     PQEN,     PQSEN,    ZTENH,    ZQENH, PAPH,     PAP,      PGEOH,    LDLAND,   LDCUM, KCBOT,    KCTOP,    IDTOP,    ITOPM2, KTYPE,    LLDDRAF, PMFU,     PMFD,     ZMFUS,    ZMFDS, ZMFUQ,    ZMFDQ,    ZMFUL,    PLUDE,    PLUDELI,   PLRAIN,  PSNDE, ZDMFUP,   ZDMFDP,   ZDPMEL,   ZLGLAC, PMFLXR,   PMFLXS,   PRAIN,    PMFUDE_RATE,  PMFDDE_RATE )
      DO JK = 2, KLEV - 1
      DO JL = KIDIA, KFDIA
      IF (LLDDRAF(JL) .AND. JK >= IDTOP(JL) - 1) THEN
        ZERATE = -PMFD(JL, JK) + PMFD(JL, JK - 1) + PMFDDE_RATE(JL, JK)
        IF (ZERATE < 0.0_JPRB) THEN
          PMFDDE_RATE(JL, JK) = PMFDDE_RATE(JL, JK) - ZERATE
        END IF
      END IF
      IF (LDCUM(JL) .AND. JK >= KCTOP(JL) - 1) THEN
        ZERATE = PMFU(JL, JK) - PMFU(JL, JK + 1) + PMFUDE_RATE(JL, JK)
        IF (ZERATE < 0.0_JPRB) THEN
          PMFUDE_RATE(JL, JK) = PMFUDE_RATE(JL, JK) - ZERATE
        END IF
        ZDMFUP(JL, JK) = PMFLXR(JL, JK + 1) + PMFLXS(JL, JK + 1) - PMFLXR(JL, JK) - PMFLXS(JL, JK)
        ZDMFDP(JL, JK) = 0.0_JPRB
      END IF
      END DO
      END DO
      DO JL = KIDIA, KFDIA
      IF (LLDDRAF(JL)) THEN
        JK = IDTOP(JL)
        IK = MIN(JK + 1, KLEV)
        IF (ZMFDQ(JL, JK) < 0.3_JPRB*ZMFDQ(JL, IK)) THEN
        IF (RMFSOLTQ == 0.0_JPRB) THEN
          ZMFDQ(JL, JK) = 0.3_JPRB*ZMFDQ(JL, IK)
        ELSE
          PMFD(JL, JK) = 0.3_JPRB*PMFD(JL, IK)
        END IF
        END IF
      END IF
      END DO
      DO JK = 2, KLEV
      DO JL = KIDIA, KFDIA
      IF (LDCUM(JL) .AND. JK >= KCTOP(JL) - 1 .AND. JK < KCBOT(JL)) THEN
        ZDZ = PTSPHY*constants%rg/(PAPH(JL, JK + 1) - PAPH(JL, JK))
    ZMFA=ZMFUQ(JL,JK+1)+ZMFDQ(JL,JK+1)-ZMFUQ(JL,JK)-ZMFDQ(JL,JK)+ ZMFUL(JL,JK+1)-ZMFUL(JL,JK)+ZDMFUP(JL,JK)-PSNDE(JL,JK,1)-PSNDE(JL,JK,2)
        ZMFA = (ZMFA - PLUDE(JL, JK))*ZDZ
        IF (PQEN(JL, JK) + ZMFA < 0.0_JPRB .AND. PLUDE(JL, JK) > 0.0_JPRB) THEN
          ZFAC = MIN(-(PQEN(JL, JK) + ZMFA)/ZDZ, PLUDE(JL, JK))
          PLUDE(JL, JK) = PLUDE(JL, JK) + ZFAC
          PLUDELI(JL, JK, 1) = PLUDELI(JL, JK, 1) + ZFAC*PLUDELI(JL, JK, 1)/PLUDE(JL, JK)
          PLUDELI(JL, JK, 2) = PLUDELI(JL, JK, 2) + ZFAC*PLUDELI(JL, JK, 2)/PLUDE(JL, JK)
        END IF
        IF (PLUDE(JL, JK) < 0.0_JPRB) THEN
          PLUDE(JL, JK) = 0.0_JPRB
          PLUDELI(JL, JK, 1) = 0.0_JPRB
          PLUDELI(JL, JK, 2) = 0.0_JPRB
        END IF
      END IF
      IF (.NOT. LDCUM(JL)) THEN
        PMFUDE_RATE(JL, JK) = 0.0_JPRB
      END IF
      IF (PMFD(JL, JK - 1) == 0.0_JPRB) THEN
        PMFDDE_RATE(JL, JK) = 0.0_JPRB
      END IF
      END DO
      END DO
      IF (RMFSOLTQ > 0.0_JPRB) THEN
      DO JK = KLEV, 2, -1
      DO JL = KIDIA, KFDIA
      IF (LDCUM(JL)) THEN
      IF (JK > KCBOT(JL)) THEN
        ZMFA = 1.0_JPRB/MAX(1.E-15_JPRB, PMFU(JL, JK))
        PQU(JL, JK) = ZQENH(JL, JK) + ZMFUQ(JL, JK)*ZMFA
        PTU(JL, JK) = ZTENH(JL, JK) + ZMFUS(JL, JK)*ZMFA*ZORCPD
        ZMFUS(JL, JK) = PMFU(JL, JK)*(constants%rcpd*PTU(JL, JK) + PGEOH(JL, JK))
        ZMFUQ(JL, JK) = PMFU(JL, JK)*PQU(JL, JK)
        IF (LLDDRAF(JL)) THEN
          ZMFA = 1.0_JPRB/MIN(-1.E-15_JPRB, PMFD(JL, JK))
          ZQD(JL, JK) = ZQENH(JL, JK) + ZMFDQ(JL, JK)*ZMFA
          ZTD(JL, JK) = ZTENH(JL, JK) + ZMFDS(JL, JK)*ZMFA*ZORCPD
          ZMFDQ(JL, JK) = PMFD(JL, JK)*ZQD(JL, JK)
          ZMFDS(JL, JK) = PMFD(JL, JK)*(constants%rcpd*ZTD(JL, JK) + PGEOH(JL, JK))
        END IF
      ELSEIF (JK <= KCBOT(JL) .AND. JK >= KCTOP(JL)) THEN
        ZMFUS(JL, JK) = PMFU(JL, JK)*(constants%rcpd*PTU(JL, JK) + PGEOH(JL, JK))
        ZMFUQ(JL, JK) = PMFU(JL, JK)*PQU(JL, JK)
        ZMFDS(JL, JK) = PMFD(JL, JK)*(constants%rcpd*ZTD(JL, JK) + PGEOH(JL, JK))
        ZMFDQ(JL, JK) = PMFD(JL, JK)*ZQD(JL, JK)
      END IF
      END IF
      END DO
      END DO
      END IF
    call cudtdqn(constants,thermal, configuration%linear_ecmwf,configuration%nonlinear_physics,parameters%convection,configuration%ecmwf_physics, KIDIA,    KFDIA,    KLON,     KLEV, ITOPM2,   KTYPE,    KCTOP,    KCBOT,    IDTOP,    LDCUM,    LLDDRAF,   LLSCVFLAG,   PTSPHY, PAPH,     PAP,      PGEOH,    PGEO, PTEN,     ZTENH,    PQEN,     ZQENH,    PQSEN, ZLGLAC,   PLUDE,    PLUDELI,  PSNDE,    PMFU,     PMFD, ZMFUS,    ZMFDS,    ZMFUQ,    ZMFDQ, ZMFUL,    ZDMFUP,   ZDPMEL,   PMFLXR,   PMFLXS, PTENT,    PTENQ,    PENTH )
      IF (LMFDUDV) THEN
      DO JK = KLEV - 1, 2, -1
        IK = JK + 1
        DO JL = KIDIA, KFDIA
        IF (LDCUM(JL)) THEN
        IF (JK == KCBOT(JL) .AND. KTYPE(JL) < 3) THEN
          IKB = IDPL(JL)
          ZUU(JL, JK) = PUEN(JL, IKB - 1)
          ZVU(JL, JK) = PVEN(JL, IKB - 1)
        ELSEIF (JK == KCBOT(JL) .AND. KTYPE(JL) == 3) THEN
          ZUU(JL, JK) = PUEN(JL, JK - 1)
          ZVU(JL, JK) = PVEN(JL, JK - 1)
        END IF
        IF (JK < KCBOT(JL) .AND. JK >= KCTOP(JL)) THEN
          ZFAC = 0.0_JPRB
          ZERATE = PMFU(JL, JK) - PMFU(JL, IK) + (1.0_JPRB + ZFAC)*PMFUDE_RATE(JL, JK)
          ZDERATE = (1.0_JPRB + ZFAC)*PMFUDE_RATE(JL, JK)
          ZMFA = 1.0_JPRB/MAX(RMFCMIN, PMFU(JL, JK))
          ZUU(JL, JK) = (ZUU(JL, IK)*PMFU(JL, IK) + ZERATE*PUEN(JL, JK) - ZDERATE*ZUU(JL, IK))*ZMFA
          ZVU(JL, JK) = (ZVU(JL, IK)*PMFU(JL, IK) + ZERATE*PVEN(JL, JK) - ZDERATE*ZVU(JL, IK))*ZMFA
        END IF
        END IF
        END DO
      END DO
      DO JK = 3, KLEV
        IK = JK - 1
        DO JL = KIDIA, KFDIA
        IF (LDCUM(JL)) THEN
        IF (JK == IDTOP(JL)) THEN
          ZUD(JL, JK) = 0.5_JPRB*(ZUU(JL, JK) + PUEN(JL, IK))
          ZVD(JL, JK) = 0.5_JPRB*(ZVU(JL, JK) + PVEN(JL, IK))
        ELSEIF (JK > IDTOP(JL)) THEN
          ZERATE = -PMFD(JL, JK) + PMFD(JL, IK) + PMFDDE_RATE(JL, JK)
          ZMFA = 1.0_JPRB/MIN(-RMFCMIN, PMFD(JL, JK))
          ZUD(JL, JK) = (ZUD(JL, IK)*PMFD(JL, IK) - ZERATE*PUEN(JL, IK) + PMFDDE_RATE(JL, JK)*ZUD(JL, IK))*ZMFA
          ZVD(JL, JK) = (ZVD(JL, IK)*PMFD(JL, IK) - ZERATE*PVEN(JL, IK) + PMFDDE_RATE(JL, JK)*ZVD(JL, IK))*ZMFA
        END IF
        END IF
        END DO
      END DO
      ZMFS(:) = 1.0_JPRB
      IF (RMFSOLUV <= 1.0_JPRB) THEN
      DO JK = 2, KLEV
      DO JL = KIDIA, KFDIA
      IF (LDCUM(JL) .AND. JK >= KCTOP(JL) - 1) THEN
        ZMFMAX = (PAPH(JL, JK) - PAPH(JL, JK - 1))*ZCONS
        IF (PMFU(JL, JK) > ZMFMAX .AND. JK >= KCTOP(JL)) ZMFS(JL) = MIN(ZMFS(JL), ZMFMAX/PMFU(JL, JK))
      END IF
      END DO
      END DO
      END IF
      DO JK = 1, KLEV
      DO JL = KIDIA, KFDIA
        ZMFUUS(JL, JK) = PMFU(JL, JK)
        ZMFDUS(JL, JK) = PMFD(JL, JK)
        IF (LDCUM(JL) .AND. JK >= KCTOP(JL) - 1) THEN
          ZMFUUS(JL, JK) = PMFU(JL, JK)*ZMFS(JL)
          ZMFDUS(JL, JK) = PMFD(JL, JK)*ZMFS(JL)
        END IF
      END DO
      END DO
      IF (RMFSOLUV > 0.0_JPRB) THEN
      DO JL = KIDIA, KFDIA
      IF (LDCUM(JL)) THEN
        JK = KCBOT(JL)
        IK = JK - 1
        ZMFUUB(JL) = ZMFUUS(JL, JK)*(ZUU(JL, JK) - PUEN(JL, IK))
        ZMFUVB(JL) = ZMFUUS(JL, JK)*(ZVU(JL, JK) - PVEN(JL, IK))
      END IF
      END DO
      DO JK = 2, KLEV
        IK = JK - 1
        DO JL = KIDIA, KFDIA
        IF (LDCUM(JL) .AND. JK > KCBOT(JL)) THEN
          IKB = KCBOT(JL)
          ZDZ = ((PAPH(JL, KLEV + 1) - PAPH(JL, JK))/(PAPH(JL, KLEV + 1) - PAPH(JL, IKB)))
          IF (KTYPE(JL) == 3) THEN
            ZDZ = ZDZ*ZDZ
          END IF
          ZMFA = 1.0_JPRB/MAX(RMFCMIN, ZMFUUS(JL, JK))
          ZUU(JL, JK) = PUEN(JL, IK) + ZMFUUB(JL)*ZDZ*ZMFA
          ZVU(JL, JK) = PVEN(JL, IK) + ZMFUVB(JL)*ZDZ*ZMFA
          ZMFDUS(JL, JK) = ZMFDUS(JL, IKB)*ZDZ
          ZUD(JL, JK) = PUEN(JL, IK) + ZUD(JL, IKB) - PUEN(JL, IKB - 1)
          ZVD(JL, JK) = PVEN(JL, IK) + ZVD(JL, IKB) - PVEN(JL, IKB - 1)
        END IF
        IF (LDCUM(JL) .AND. JK >= KCTOP(JL)) THEN
          ZUU(JL, JK) = ZUU(JL, JK) - MIN(ABS(ZUU(JL, JK)), RUVPER)*SIGN(1.0_JPRB, ZUU(JL, JK))
          ZVU(JL, JK) = ZVU(JL, JK) - MIN(ABS(ZVU(JL, JK)), RUVPER)*SIGN(1.0_JPRB, ZVU(JL, JK))
        END IF
        END DO
      END DO
      END IF
    call cududv(constants,thermal, parameters%convection, YDSPP_CONFIG, KIDIA,    KFDIA,    KLON,     KLEV, ITOPM2,   KTYPE,    KCBOT,    KCTOP,    LDCUM,    PTSPHY, PAPH,     PAP,      PUEN,     PVEN,     ZMFUUS,   ZMFDUS, PMFU,     PMFD,     ZUU,      ZUD,      ZVU,      ZVD,    PGP2DSPP, PTENU,    PTENV     )
      IF (LMFUVDIS) THEN
      DO JL = KIDIA, KFDIA
        ZSUM12(JL) = 0.0_JPRB
        ZSUM22(JL) = 0.0_JPRB
      END DO
      DO JK = 1, KLEV
      DO JL = KIDIA, KFDIA
        ZUV2(JL, JK) = 0.0_JPRB
        IF (LDCUM(JL) .AND. JK >= KCTOP(JL) - 1) THEN
          ZDZ = (PAPH(JL, JK + 1) - PAPH(JL, JK))
          ZDUTEN = PTENU(JL, JK) - ZTENU(JL, JK)
          ZDVTEN = PTENV(JL, JK) - ZTENV(JL, JK)
          ZUV2(JL, JK) = SQRT(source_power(ZDUTEN, 2) + source_power(ZDVTEN, 2))
          ZSUM22(JL) = ZSUM22(JL) + ZUV2(JL, JK)*ZDZ
          ZSUM12(JL) = ZSUM12(JL) - (PUEN(JL, JK)*ZDUTEN + PVEN(JL, JK)*ZDVTEN)*ZDZ
        END IF
      END DO
      END DO
      DO JL = KIDIA, KFDIA
        PVDISCU(JL) = ZSUM12(JL)*ZRG
      END DO
      DO JK = 1, KLEV
      DO JL = KIDIA, KFDIA
      IF (LDCUM(JL) .AND. JK >= KCTOP(JL) - 1) THEN
        ZTDIS = ZORCPD*ZSUM12(JL)*ZUV2(JL, JK)/MAX(1.E-15_JPRB, ZSUM22(JL))
        PTENT(JL, JK) = PTENT(JL, JK) + ZTDIS
      END IF
      END DO
      END DO
      END IF
      END IF
      IF (.NOT. LMFSCV .OR. .NOT. LMFPEN) THEN
      DO JK = 2, KLEV
      DO JL = KIDIA, KFDIA
      IF (LLO2(JL) .AND. JK >= KCTOP(JL) - 1) THEN
        PMFUDE_RATE(JL, JK) = 0.0_JPRB
        PMFDDE_RATE(JL, JK) = 0.0_JPRB
      END IF
      END DO
      END DO
      DO JL = KIDIA, KFDIA
      IF (LLO2(JL)) THEN
        KCTOP(JL) = KLEV - 1
        KCBOT(JL) = KLEV - 1
      END IF
      END DO
      END IF
      IF (LMFTRAC .AND. KTRAC > 0) THEN
      DO JL = KIDIA, KFDIA
      IF (LDCUM(JL) .AND. KTYPE(JL) /= 3 .AND. KCBOT(JL) - KCTOP(JL) >= 1) THEN
        LLDCUM(JL) = .TRUE.
        LLDDRAF3(JL) = LLDDRAF(JL)
      ELSE
        LLDCUM(JL) = .FALSE.
        LLDDRAF3(JL) = .FALSE.
      END IF
      END DO
      ZMFS(:) = 1.0_JPRB
      IF (RMFSOLCT <= 3.0_JPRB) THEN
      DO JK = 2, KLEV
      DO JL = KIDIA, KFDIA
      IF (LLDCUM(JL) .AND. JK >= KCTOP(JL)) THEN
        ZMFMAX = (PAPH(JL, JK) - PAPH(JL, JK - 1))*0.8_JPRB*ZCONS
        IF (PMFU(JL, JK) > ZMFMAX) ZMFS(JL) = MIN(ZMFS(JL), ZMFMAX/PMFU(JL, JK))
      END IF
      END DO
      END DO
      END IF
      DO JK = 1, KLEV
      DO JL = KIDIA, KFDIA
      IF (LLDCUM(JL) .AND. JK >= KCTOP(JL) - 1) THEN
        ZMFUUS(JL, JK) = PMFU(JL, JK)*ZMFS(JL)
        ZMFUDR(JL, JK) = PMFUDE_RATE(JL, JK)*ZMFS(JL)
        ZDMFUPC(JL, JK) = (PMFLXR(JL, JK) + PMFLXS(JL, JK))*ZMFS(JL)
        IKB = KCBOT(JL)
        IF (JK > IKB) THEN
          ZDMFUPC(JL, JK) = ZDMFUPC(JL, IKB)
        END IF
      ELSE
        ZMFUUS(JL, JK) = 0._JPRB
        ZMFUDR(JL, JK) = 0._JPRB
      END IF
      IF (LLDDRAF3(JL) .AND. JK >= IDTOP(JL) - 1) THEN
        ZMFDUS(JL, JK) = PMFD(JL, JK)*ZMFS(JL)
        ZMFDDR(JL, JK) = PMFDDE_RATE(JL, JK)*ZMFS(JL)
        ZDMFDPC(JL, JK) = 0.0_JPRB
      ELSE
        ZMFDUS(JL, JK) = 0._JPRB
        ZMFDDR(JL, JK) = 0._JPRB
      END IF
      END DO
      END DO
      IF (LMFSMOOTH) THEN
      DO JK = 2, KLEV - 1
      DO JL = KIDIA, KFDIA
      IF (LLDDRAF3(JL) .AND. ZMFDUS(JL, JK) < 0.0_JPRB .AND. ZMFDUS(JL, JK + 1) == 0.0_JPRB) THEN
        ZERATE = MIN(0._JPRB, ZMFDUS(JL, JK) - 0.5*ZMFDUS(JL, JK - 1))
        ZMFDUS(JL, JK) = ZMFDUS(JL, JK) - ZERATE
        ZMFDDR(JL, JK) = ZMFDDR(JL, JK) - ZERATE
        ZMFDDR(JL, JK + 1) = -ZMFDUS(JL, JK)
      END IF
      IF (LLDCUM(JL) .AND. JK == KCTOP(JL)) THEN
        ZERATE = MAX(0.0_JPRB, ZMFUUS(JL, JK) - 0.5_JPRB*ZMFUUS(JL, JK + 1))
        ZMFUUS(JL, JK) = ZMFUUS(JL, JK) - ZERATE
        ZMFUDR(JL, JK) = ZMFUDR(JL, JK) + ZERATE
        ZMFUDR(JL, JK - 1) = ZMFUUS(JL, JK)
      END IF
      END DO
      END DO
      DO JK = KLEV - 1, 2, -1
      DO JL = KIDIA, KFDIA
      IF (LLDCUM(JL)) THEN
      IF (ZMFUDR(JL, JK) == 0.0_JPRB .AND. ZMFUDR(JL, JK - 1) > 0.0_JPRB) THEN
        ZMFUDR(JL, JK) = 0.5_JPRB*ZMFUDR(JL, JK - 1)
      END IF
      END IF
      END DO
      END DO
      END IF
      IF (LMFSCAV) THEN
        ZSCAV(:) = PSCAV(:)
      ELSE
        ZSCAV(:) = 0.0_JPRB
        ZDMFUPC(:, :) = 0.0_JPRB
      END IF
      status = 2_JPIM
      return
      END IF
      PDISS(:, 1) = 0.0_JPRB
      ZAR = 1.0_JPRB/20.89_JPRB
      ZAS = 1.0_JPRB/29.51_JPRB
      ZBR = 1.0_JPRB/1.15_JPRB
      ZBS = 1.0_JPRB/1.10_JPRB
      ZAK = 1.0_JPRB/5.09E-3_JPRB
      DO JK = 1, KLEV
        IK = MIN(JK + 1, KLEV)
        IKD = MAX(JK - 1, 1)
        DO JL = KIDIA, KFDIA
          PDISS(JL, JK) = 0.0_JPRB
          PRSUD(JL, JK, 1) = 0.0_JPRB
          PRSUD(JL, JK, 2) = 0.0_JPRB
          IF (LDCUM(JL) .AND. JK >= KCTOP(JL) - 1) THEN
        PLUDELI(JL, JK, 3) = PMFUDE_RATE(JL, JK)*(PQU(JL, IK) - ZQENH(JL, IK)) + PMFDDE_RATE(JL, JK)*(ZQD(JL, IKD) - ZQENH(JL, IKD))
        PLUDELI(JL, JK, 4) = PMFUDE_RATE(JL, JK)*(PTU(JL, IK) - ZTENH(JL, IK)) + PMFDDE_RATE(JL, JK)*(ZTD(JL, IKD) - ZTENH(JL, IKD))
            ZRO = constants%rg/(PGEOH(JL, JK) - PGEOH(JL, JK + 1))
            PMFUDE_RATE(JL, JK) = PMFUDE_RATE(JL, JK)*ZRO
            PMFDDE_RATE(JL, JK) = PMFDDE_RATE(JL, JK)*ZRO
            ZRO = constants%rd*PTEN(JL, JK)*(1.0_JPRB + constants%retv*PQEN(JL, JK))/PAP(JL, JK)
            ZDUTEN = PTENU(JL, JK) - ZTENU(JL, JK)
            ZDVTEN = PTENV(JL, JK) - ZTENV(JL, JK)
            PDISS(JL, JK) = source_power(ABS(PUEN(JL, JK)*ZDUTEN + PVEN(JL, JK)*ZDVTEN), 0.3333)
            PRSUD(JL, JK, 1) = 1.E-3_JPRB*ZRO*source_power((PMFLXR(JL, JK)*3600._JPRB*ZAR), ZBR)
            PRSUD(JL, JK, 2) = 0.5*1.E-3_JPRB*ZRO*source_power((10.0_JPRB*PMFLXS(JL, JK)*3600._JPRB*ZAS), ZBS)
          ELSE
            PMFU(JL, JK) = 0.0_JPRB
            PMFD(JL, JK) = 0.0_JPRB
            PLUDE(JL, JK) = 0.0_JPRB
            PLUDELI(JL, JK, 1) = 0.0_JPRB
            PLUDELI(JL, JK, 2) = 0.0_JPRB
            PLUDELI(JL, JK, 3) = 0.0_JPRB
            PLUDELI(JL, JK, 4) = 0.0_JPRB
            PSNDE(JL, JK, 1) = 0.0_JPRB
            PSNDE(JL, JK, 2) = 0.0_JPRB
            PTU(JL, JK) = PTEN(JL, JK)
            PQU(JL, JK) = PQEN(JL, JK)
            PLU(JL, JK) = 0.0_JPRB
            PENTH(JL, JK) = 0.0_JPRB
            PMFUDE_RATE(JL, JK) = 0.0_JPRB
            PMFDDE_RATE(JL, JK) = 0.0_JPRB
          END IF
        END DO
      END DO
    END ASSOCIATE
  end function cumastrn_body
end module convection_column_update_mod
