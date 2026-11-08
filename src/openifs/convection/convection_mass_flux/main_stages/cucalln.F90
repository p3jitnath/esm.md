! (C) Copyright 1989- ECMWF.
! This software is licensed under the terms of the Apache Licence Version 2.0
! which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
!
! In applying this licence, ECMWF does not waive the privileges and immunities
! granted to it by virtue of its status as an intergovernmental organisation
! nor does it submit to any jurisdiction

!> Complete normal-physics convection controller on canonical borrowed state.
!! Physical parameters and the shared seventeen-record configuration retain
!! one owner each. Tendency view pointers borrow real caller-owned arrays;
!! this procedure neither allocates nor releases those physical fields.
!! CURRENT_STEP is the source NSTEP value from the canonical live clock.
!! Temperature uses K, pressure Pa, humidity kg/kg and timestep seconds.
!! The caller supplies nearest-even, gradual underflow, finite physical
!! values, disjoint writable/read-only owners and sufficient native stack.
module convection_controller_mod
  use iso_fortran_env, only: JPIM => int32, JPRB => real64, int64
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use forecast_ecmwf_physics_state, only: native_ecmwf_physics_state
  use physics_configuration_state_port, only: physics_configuration_state
  use forecast_convection_tendency_views, only: convection_tendency_views
  use saturation_humidity_mod, only: satur
  use convection_column_update_mod, only: cumastrn
  use convection_parcel_diffusion_mod, only: custrat
  use convection_cloud_diagnostics_mod, only: cuccdia
  use convection_source_math_mod, only: source_power, source_exp, source_log
  USE YOERAD, ONLY: TERAD
  USE SPP_MOD, ONLY: TSPP_CONFIG
  implicit none
  private
  public :: cucalln
contains
  !> Run the complete source child order, local increments and flux diagnostics.
  !! Providers precede original remaining arguments. Original composite model
  !! objects become borrowed canonical records; YGFL becomes NACTAERO and
  !! chemistry becomes its explicit readonly light-production choice.
  !! Return0 after work,2 before unsupported metadata writes, or child status
  !! after preceding source stages. No original numerical calculation is called.
  integer(JPIM) function cucalln(constants,thermal,rplrg,rpldare,parameters,configuration,current_step,YDERAD,NACTAERO,chem_light_active,YDSPP_CONFIG,KIDIA,KFDIA,KLON,KSMAX,KLEV,LDLAND,LDSLPHY,PTSPHY,PVDIFTS,PTM1,PQM1,PUM1,PVM1,PLITOT,PVERVEL,PQHFL,PAHFS,PAPHM1,PAP,PAPH,PGEO,PGEOH,PGAW,PCUCONVCA,PGP2DSPP,TENDENCY_CML,TENDENCY_LOC,TENDENCY_DYN,PARPRC,KTOPC,KBASEC,KTYPE,KCBOT,KCTOP,KBOTSC,LDCUM,LDSC,KCBOT_LIG,KCTOP_LIG,LDCUM_LIG,LDSHCV,PLCRIT_AER,PLU,PLUDE,PLUDELI,PSNDE,PMFU,PMFD,PDIFCQ,PDIFCS,PFHPCL,PFHPCN,PFPLCL,PFPLCN,PLRAIN,PRSUD,PSTRCU,PSTRCV,PFCQLF,PFCQIF,PMFUDE_RATE,PMFDDE_RATE,PCAPE,PWMEAN,PVDISCU,PDISS,KTRAC,PCM1,PTENC,PSCAV)result(status)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    real(JPRB), intent(in) :: rplrg, rpldare
    type(native_ecmwf_physics_state), intent(inout) :: parameters
    type(physics_configuration_state), intent(inout) :: configuration
    integer(JPIM), intent(in) :: current_step
    TYPE(TERAD), INTENT(INOUT) :: YDERAD
    integer(JPIM), intent(in) :: NACTAERO
    logical, intent(in) :: chem_light_active
    TYPE(TSPP_CONFIG), INTENT(IN) :: YDSPP_CONFIG
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KSMAX
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEV
    LOGICAL, INTENT(IN) :: LDLAND(:)
    LOGICAL, INTENT(IN) :: LDSLPHY
    REAL(KIND=JPRB), INTENT(IN) :: PTSPHY
    REAL(KIND=JPRB), INTENT(IN) :: PVDIFTS
    REAL(KIND=JPRB), INTENT(IN) :: PTM1(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PQM1(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PUM1(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PVM1(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PLITOT(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PVERVEL(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PQHFL(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PAHFS(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PAPHM1(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PAP(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PAPH(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PGEO(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PGEOH(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PGAW(:)
    REAL(KIND=JPRB), INTENT(IN) :: PCUCONVCA(:)
    REAL(KIND=JPRB), INTENT(IN) :: PGP2DSPP(:, :)
    type(convection_tendency_views), INTENT(IN) :: TENDENCY_CML
    type(convection_tendency_views), INTENT(INOUT) :: TENDENCY_LOC
    type(convection_tendency_views), INTENT(IN) :: TENDENCY_DYN
    REAL(KIND=JPRB), INTENT(INOUT) :: PARPRC(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KTOPC(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KBASEC(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KTYPE(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KCBOT(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KCTOP(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KBOTSC(:)
    LOGICAL, INTENT(INOUT) :: LDCUM(:)
    LOGICAL, INTENT(INOUT) :: LDSC(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KCBOT_LIG(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KCTOP_LIG(:)
    LOGICAL, INTENT(INOUT) :: LDCUM_LIG(:)
    LOGICAL, INTENT(IN) :: LDSHCV(:)
    REAL(KIND=JPRB), INTENT(IN) :: PLCRIT_AER(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PLU(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PLUDE(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PLUDELI(:, :, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PSNDE(:, :, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMFU(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMFD(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDIFCQ(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDIFCS(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFHPCL(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFHPCN(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFPLCL(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFPLCN(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PLRAIN(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PRSUD(:, :, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PSTRCU(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PSTRCV(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFCQLF(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFCQIF(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMFUDE_RATE(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMFDDE_RATE(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCAPE(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PWMEAN(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PVDISCU(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDISS(:, :)
    INTEGER(KIND=JPIM), INTENT(IN) :: KTRAC
    REAL(KIND=JPRB), INTENT(IN) :: PCM1(:, :, :)
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
    if (.not. is_contiguous(PTM1)) return
    if (size(PTM1, 1) /= KLON) return
    if (size(PTM1, 2) < KLEV) return
    if (.not. is_contiguous(PQM1)) return
    if (size(PQM1, 1) /= KLON) return
    if (size(PQM1, 2) < KLEV) return
    if (.not. is_contiguous(PUM1)) return
    if (size(PUM1, 1) /= KLON) return
    if (size(PUM1, 2) < KLEV) return
    if (.not. is_contiguous(PVM1)) return
    if (size(PVM1, 1) /= KLON) return
    if (size(PVM1, 2) < KLEV) return
    if (.not. is_contiguous(PLITOT)) return
    if (size(PLITOT, 1) /= KLON) return
    if (size(PLITOT, 2) < KLEV) return
    if (.not. is_contiguous(PVERVEL)) return
    if (size(PVERVEL, 1) /= KLON) return
    if (size(PVERVEL, 2) < KLEV) return
    if (.not. is_contiguous(PQHFL)) return
    if (size(PQHFL, 1) /= KLON) return
    if (size(PQHFL, 2) < KLEV + 1) return
    if (.not. is_contiguous(PAHFS)) return
    if (size(PAHFS, 1) /= KLON) return
    if (size(PAHFS, 2) < KLEV + 1) return
    if (.not. is_contiguous(PAPHM1)) return
    if (size(PAPHM1, 1) /= KLON) return
    if (size(PAPHM1, 2) < KLEV + 1) return
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
    if (.not. is_contiguous(PARPRC)) return
    if (size(PARPRC, 1) /= KLON) return
    if (.not. is_contiguous(KTOPC)) return
    if (size(KTOPC, 1) /= KLON) return
    if (.not. is_contiguous(KBASEC)) return
    if (size(KBASEC, 1) /= KLON) return
    if (.not. is_contiguous(KTYPE)) return
    if (size(KTYPE, 1) /= KLON) return
    if (.not. is_contiguous(KCBOT)) return
    if (size(KCBOT, 1) /= KLON) return
    if (.not. is_contiguous(KCTOP)) return
    if (size(KCTOP, 1) /= KLON) return
    if (.not. is_contiguous(KBOTSC)) return
    if (size(KBOTSC, 1) /= KLON) return
    if (.not. is_contiguous(LDCUM)) return
    if (size(LDCUM, 1) /= KLON) return
    if (.not. is_contiguous(LDSC)) return
    if (size(LDSC, 1) /= KLON) return
    if (.not. is_contiguous(KCBOT_LIG)) return
    if (size(KCBOT_LIG, 1) /= KLON) return
    if (.not. is_contiguous(KCTOP_LIG)) return
    if (size(KCTOP_LIG, 1) /= KLON) return
    if (.not. is_contiguous(LDCUM_LIG)) return
    if (size(LDCUM_LIG, 1) /= KLON) return
    if (.not. is_contiguous(LDSHCV)) return
    if (size(LDSHCV, 1) /= KLON) return
    if (.not. is_contiguous(PLCRIT_AER)) return
    if (size(PLCRIT_AER, 1) /= KLON) return
    if (size(PLCRIT_AER, 2) < KLEV) return
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
    if (.not. is_contiguous(PMFU)) return
    if (size(PMFU, 1) /= KLON) return
    if (size(PMFU, 2) < KLEV) return
    if (.not. is_contiguous(PMFD)) return
    if (size(PMFD, 1) /= KLON) return
    if (size(PMFD, 2) < KLEV) return
    if (.not. is_contiguous(PDIFCQ)) return
    if (size(PDIFCQ, 1) /= KLON) return
    if (size(PDIFCQ, 2) < KLEV + 1) return
    if (.not. is_contiguous(PDIFCS)) return
    if (size(PDIFCS, 1) /= KLON) return
    if (size(PDIFCS, 2) < KLEV + 1) return
    if (.not. is_contiguous(PFHPCL)) return
    if (size(PFHPCL, 1) /= KLON) return
    if (size(PFHPCL, 2) < KLEV + 1) return
    if (.not. is_contiguous(PFHPCN)) return
    if (size(PFHPCN, 1) /= KLON) return
    if (size(PFHPCN, 2) < KLEV + 1) return
    if (.not. is_contiguous(PFPLCL)) return
    if (size(PFPLCL, 1) /= KLON) return
    if (size(PFPLCL, 2) < KLEV + 1) return
    if (.not. is_contiguous(PFPLCN)) return
    if (size(PFPLCN, 1) /= KLON) return
    if (size(PFPLCN, 2) < KLEV + 1) return
    if (.not. is_contiguous(PLRAIN)) return
    if (size(PLRAIN, 1) /= KLON) return
    if (size(PLRAIN, 2) < KLEV) return
    if (.not. is_contiguous(PRSUD)) return
    if (size(PRSUD, 1) /= KLON) return
    if (size(PRSUD, 2) < KLEV) return
    if (size(PRSUD, 3) < 2) return
    if (.not. is_contiguous(PSTRCU)) return
    if (size(PSTRCU, 1) /= KLON) return
    if (size(PSTRCU, 2) < KLEV + 1) return
    if (.not. is_contiguous(PSTRCV)) return
    if (size(PSTRCV, 1) /= KLON) return
    if (size(PSTRCV, 2) < KLEV + 1) return
    if (.not. is_contiguous(PFCQLF)) return
    if (size(PFCQLF, 1) /= KLON) return
    if (size(PFCQLF, 2) < KLEV + 1) return
    if (.not. is_contiguous(PFCQIF)) return
    if (size(PFCQIF, 1) /= KLON) return
    if (size(PFCQIF, 2) < KLEV + 1) return
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
    if (.not. is_contiguous(PCM1)) return
    if (size(PCM1, 1) /= KLON) return
    if (size(PCM1, 2) < KLEV) return
    if (size(PCM1, 3) < KTRAC) return
    if (.not. is_contiguous(PTENC)) return
    if (size(PTENC, 1) /= KLON) return
    if (size(PTENC, 2) < KLEV) return
    if (size(PTENC, 3) < KTRAC) return
    if (.not. is_contiguous(PSCAV)) return
    if (size(PSCAV, 1) /= KTRAC) return
    if (.not. associated(TENDENCY_CML%T)) return
    if (.not. is_contiguous(TENDENCY_CML%T)) return
    if (size(TENDENCY_CML%T, 1) /= KLON .or. size(TENDENCY_CML%T, 2) < KLEV) return
    if (.not. associated(TENDENCY_CML%Q)) return
    if (.not. is_contiguous(TENDENCY_CML%Q)) return
    if (size(TENDENCY_CML%Q, 1) /= KLON .or. size(TENDENCY_CML%Q, 2) < KLEV) return
    if (.not. associated(TENDENCY_CML%U)) return
    if (.not. is_contiguous(TENDENCY_CML%U)) return
    if (size(TENDENCY_CML%U, 1) /= KLON .or. size(TENDENCY_CML%U, 2) < KLEV) return
    if (.not. associated(TENDENCY_CML%V)) return
    if (.not. is_contiguous(TENDENCY_CML%V)) return
    if (size(TENDENCY_CML%V, 1) /= KLON .or. size(TENDENCY_CML%V, 2) < KLEV) return
    if (.not. associated(TENDENCY_DYN%T)) return
    if (.not. is_contiguous(TENDENCY_DYN%T)) return
    if (size(TENDENCY_DYN%T, 1) /= KLON .or. size(TENDENCY_DYN%T, 2) < KLEV) return
    if (.not. associated(TENDENCY_DYN%Q)) return
    if (.not. is_contiguous(TENDENCY_DYN%Q)) return
    if (size(TENDENCY_DYN%Q, 1) /= KLON .or. size(TENDENCY_DYN%Q, 2) < KLEV) return
    if (.not. associated(TENDENCY_LOC%T)) return
    if (.not. is_contiguous(TENDENCY_LOC%T)) return
    if (size(TENDENCY_LOC%T, 1) /= KLON .or. size(TENDENCY_LOC%T, 2) < KLEV) return
    if (.not. associated(TENDENCY_LOC%Q)) return
    if (.not. is_contiguous(TENDENCY_LOC%Q)) return
    if (size(TENDENCY_LOC%Q, 1) /= KLON .or. size(TENDENCY_LOC%Q, 2) < KLEV) return
    if (.not. associated(TENDENCY_LOC%U)) return
    if (.not. is_contiguous(TENDENCY_LOC%U)) return
    if (size(TENDENCY_LOC%U, 1) /= KLON .or. size(TENDENCY_LOC%U, 2) < KLEV) return
    if (.not. associated(TENDENCY_LOC%V)) return
    if (.not. is_contiguous(TENDENCY_LOC%V)) return
    if (size(TENDENCY_LOC%V, 1) /= KLON .or. size(TENDENCY_LOC%V, 2) < KLEV) return
    status=cucalln_body(constants,thermal,rplrg,rpldare,parameters,configuration,current_step,YDERAD,NACTAERO,chem_light_active,YDSPP_CONFIG,KIDIA,KFDIA,KLON,KSMAX,KLEV,LDLAND(1:KLON),LDSLPHY,PTSPHY,PVDIFTS,PTM1(1:KLON,1:KLEV),PQM1(1:KLON,1:KLEV),PUM1(1:KLON,1:KLEV),PVM1(1:KLON,1:KLEV),PLITOT(1:KLON,1:KLEV),PVERVEL(1:KLON,1:KLEV),PQHFL(1:KLON,1:KLEV+1),PAHFS(1:KLON,1:KLEV+1),PAPHM1(1:KLON,1:KLEV+1),PAP(1:KLON,1:KLEV),PAPH(1:KLON,1:KLEV+1),PGEO(1:KLON,1:KLEV),PGEOH(1:KLON,1:KLEV+1),PGAW(1:KLON),PCUCONVCA(1:KLON),PGP2DSPP(1:KLON,1:YDSPP_CONFIG%SM%NRFTOTAL),TENDENCY_CML,TENDENCY_LOC,TENDENCY_DYN,PARPRC(1:KLON),KTOPC(1:KLON),KBASEC(1:KLON),KTYPE(1:KLON),KCBOT(1:KLON),KCTOP(1:KLON),KBOTSC(1:KLON),LDCUM(1:KLON),LDSC(1:KLON),KCBOT_LIG(1:KLON),KCTOP_LIG(1:KLON),LDCUM_LIG(1:KLON),LDSHCV(1:KLON),PLCRIT_AER(1:KLON,1:KLEV),PLU(1:KLON,1:KLEV),PLUDE(1:KLON,1:KLEV),PLUDELI(1:KLON,1:KLEV,1:4),PSNDE(1:KLON,1:KLEV,1:2),PMFU(1:KLON,1:KLEV),PMFD(1:KLON,1:KLEV),PDIFCQ(1:KLON,1:KLEV+1),PDIFCS(1:KLON,1:KLEV+1),PFHPCL(1:KLON,1:KLEV+1),PFHPCN(1:KLON,1:KLEV+1),PFPLCL(1:KLON,1:KLEV+1),PFPLCN(1:KLON,1:KLEV+1),PLRAIN(1:KLON,1:KLEV),PRSUD(1:KLON,1:KLEV,1:2),PSTRCU(1:KLON,1:KLEV+1),PSTRCV(1:KLON,1:KLEV+1),PFCQLF(1:KLON,1:KLEV+1),PFCQIF(1:KLON,1:KLEV+1),PMFUDE_RATE(1:KLON,1:KLEV),PMFDDE_RATE(1:KLON,1:KLEV),PCAPE(1:KLON),PWMEAN(1:KLON),PVDISCU(1:KLON),PDISS(1:KLON,1:KLEV),KTRAC,PCM1(1:KLON,1:KLEV,1:KTRAC),PTENC(1:KLON,1:KLEV,1:KTRAC),PSCAV(1:KTRAC))
  end function cucalln
  integer(JPIM) function cucalln_body(constants,thermal,rplrg,rpldare,parameters,configuration,current_step,YDERAD,NACTAERO,chem_light_active,YDSPP_CONFIG,KIDIA,KFDIA,KLON,KSMAX,KLEV,LDLAND,LDSLPHY,PTSPHY,PVDIFTS,PTM1,PQM1,PUM1,PVM1,PLITOT,PVERVEL,PQHFL,PAHFS,PAPHM1,PAP,PAPH,PGEO,PGEOH,PGAW,PCUCONVCA,PGP2DSPP,TENDENCY_CML,TENDENCY_LOC,TENDENCY_DYN,PARPRC,KTOPC,KBASEC,KTYPE,KCBOT,KCTOP,KBOTSC,LDCUM,LDSC,KCBOT_LIG,KCTOP_LIG,LDCUM_LIG,LDSHCV,PLCRIT_AER,PLU,PLUDE,PLUDELI,PSNDE,PMFU,PMFD,PDIFCQ,PDIFCS,PFHPCL,PFHPCN,PFPLCL,PFPLCN,PLRAIN,PRSUD,PSTRCU,PSTRCV,PFCQLF,PFCQIF,PMFUDE_RATE,PMFDDE_RATE,PCAPE,PWMEAN,PVDISCU,PDISS,KTRAC,PCM1,PTENC,PSCAV)result(status)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    real(JPRB), intent(in) :: rplrg, rpldare
    type(native_ecmwf_physics_state), intent(inout) :: parameters
    type(physics_configuration_state), intent(inout) :: configuration
    integer(JPIM), intent(in) :: current_step
    TYPE(TERAD), INTENT(INOUT) :: YDERAD
    integer(JPIM), intent(in) :: NACTAERO
    logical, intent(in) :: chem_light_active
    TYPE(TSPP_CONFIG), INTENT(IN) :: YDSPP_CONFIG
    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KSMAX
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEV
    INTEGER(KIND=JPIM), INTENT(IN) :: KTRAC
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    LOGICAL, INTENT(IN) :: LDLAND(:)
    LOGICAL, INTENT(IN) :: LDSLPHY
    REAL(KIND=JPRB), INTENT(IN) :: PTSPHY
    REAL(KIND=JPRB), INTENT(IN) :: PVDIFTS
    REAL(KIND=JPRB), INTENT(IN) :: PLCRIT_AER(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PTM1(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PQM1(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PUM1(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PVM1(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PCM1(:, :, :)
    REAL(KIND=JPRB), INTENT(IN) :: PLITOT(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PVERVEL(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PQHFL(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PAHFS(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PAPHM1(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PAP(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PAPH(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PGEO(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PGEOH(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PGAW(:)
    REAL(KIND=JPRB), INTENT(IN) :: PCUCONVCA(:)
    REAL(KIND=JPRB), INTENT(IN) :: PGP2DSPP(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PSCAV(:)
    type(convection_tendency_views), INTENT(IN) :: TENDENCY_CML
    type(convection_tendency_views), INTENT(INOUT) :: TENDENCY_LOC
    type(convection_tendency_views), INTENT(IN) :: TENDENCY_DYN
    REAL(KIND=JPRB), INTENT(INOUT) :: PTENC(:, :, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PARPRC(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KTOPC(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KBASEC(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KTYPE(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KCBOT(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KCTOP(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KCBOT_LIG(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KCTOP_LIG(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KBOTSC(:)
    LOGICAL, INTENT(INOUT) :: LDCUM(:)
    LOGICAL, INTENT(INOUT) :: LDCUM_LIG(:)
    LOGICAL, INTENT(INOUT) :: LDSC(:)
    LOGICAL, INTENT(IN) :: LDSHCV(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PLU(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PLUDE(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PLUDELI(:, :, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PSNDE(:, :, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMFU(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMFD(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDIFCQ(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDIFCS(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFHPCL(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFHPCN(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFPLCL(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFPLCN(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PLRAIN(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PRSUD(:, :, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PSTRCU(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PSTRCV(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFCQLF(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFCQIF(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMFUDE_RATE(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMFDDE_RATE(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCAPE(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PWMEAN(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PVDISCU(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDISS(:, :)
    REAL(KIND=JPRB) ::     ZTP1(KLON,KLEV),        ZQP1(KLON,KLEV), ZUP1(KLON,KLEV),        ZVP1(KLON,KLEV), ZTU(KLON,KLEV),         ZQU(KLON,KLEV), ZQSAT(KLON,KLEV),       ZRAIN(KLON)
    REAL(KIND=JPRB) :: ZCP1(KLON, KLEV, KTRAC)
    REAL(KIND=JPRB) :: ZENTHD(KLON, KLEV), ZENTHS(KLON, KLEV)
    REAL(KIND=JPRB) :: ZCONDFLL(KLON), ZCONDFLN(KLON)
    INTEGER(KIND=JPIM) :: IFLAG, JK, JL, JN
    REAL(KIND=JPRB) :: ZCP, ZGDPH
    LOGICAL :: LLTEST
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
    REAL(KIND=JPRB) :: RLV, RLS, RLF, ESW, ESS, ES
    REAL(KIND=JPRB) :: PTARG
    RLV(PTARG) = constants%rlvtt + (constants%rcpv - constants%rcw)*(PTARG - constants%rtt)
    RLS(PTARG) = constants%rlstt + (constants%rcpv - constants%rcs)*(PTARG - constants%rtt)
    RLF(PTARG) = RLS(PTARG) - RLV(PTARG)
    ESW(PTARG) = source_exp(constants%ralpw - constants%rbetw/PTARG - constants%rgamw*source_log(PTARG))
    ESS(PTARG) = source_exp(constants%ralps - constants%rbets/PTARG - constants%rgams*source_log(PTARG))
    ES (PTARG)=source_exp( (constants%ralpw+constants%ralpd*MAX(0.0_JPRB,SIGN(1.0_JPRB,constants%rtt-PTARG))) -(constants%rbetw+constants%rbetd*MAX(0.0_JPRB,SIGN(1.0_JPRB,constants%rtt-PTARG)))/PTARG -(constants%rgamw+constants%rgamd*MAX(0.0_JPRB,SIGN(1.0_JPRB,constants%rtt-PTARG)))*source_log(PTARG))
    REAL(KIND=JPRB) :: FOEW
    REAL(KIND=JPRB) :: PDELARG
    FOEW ( PTARG,PDELARG ) = source_exp( ( constants%ralpw+PDELARG*constants%ralpd ) - ( constants%rbetw+PDELARG*constants%rbetd ) / PTARG - ( constants%rgamw+PDELARG*constants%rgamd ) * source_log(PTARG) )
    REAL(KIND=JPRB) :: FODLEW
    FODLEW ( PTARG,PDELARG ) = ( ( constants%rbetw+PDELARG*constants%rbetd ) - ( constants%rgamw+PDELARG*constants%rgamd ) * PTARG ) / ( PTARG*PTARG )
    REAL(KIND=JPRB) :: FOQS
    REAL(KIND=JPRB) :: PESPFAR
    FOQS(PESPFAR) = PESPFAR/(1.0_JPRB + constants%retv*MAX(0.0_JPRB, (1.0_JPRB - PESPFAR)))
    REAL(KIND=JPRB) :: FOQSTP
    REAL(KIND=JPRB) :: PPRESS
    FOQSTP(PTARG, PPRESS) = FOQS(FOEW(PTARG, MAX(0.0_JPRB, SIGN(1.0_JPRB, constants%rtt - PTARG)))/PPRESS)
    REAL(KIND=JPRB) :: FODQS
    REAL(KIND=JPRB) :: PQSFARG, PDLEFAR
    FODQS(PQSFARG, PESPFAR, PDLEFAR) = (PQSFARG*(1.0_JPRB - PQSFARG)*PDLEFAR)/(1.0_JPRB - PESPFAR)
    REAL(KIND=JPRB) :: FDQW
    FDQW (PESPFAR, PDLEFAR) = PDLEFAR * PESPFAR * (1.0_JPRB+constants%retv) / source_power(( 1.0_JPRB+constants%retv*MAX(0.0_JPRB,(1.0_JPRB-PESPFAR)) ),2)
    REAL(KIND=JPRB) :: FOLH
    FOLH ( PTARG,PDELARG ) =  constants%rv * ( ( constants%rbetw+PDELARG*constants%rbetd ) - ( constants%rgamw+PDELARG*constants%rgamd ) * PTARG )
    status = 0_JPIM
    ASSOCIATE(NJKT2=>parameters%convection%NJKT2, LPHYLIN=>configuration%linear_ecmwf%LPHYLIN, RLPTRC=>configuration%linear_ecmwf%RLPTRC, LEPCLD=>configuration%ecmwf_physics%LEPCLD, LMFTRAC=>configuration%ecmwf_physics%LMFTRAC, LENCLD2=>configuration%nonlinear_physics%LENCLD2,LEPCLD2=>configuration%nonlinear_physics%LEPCLD2, REPQMI=>parameters%condensation%REPQMI)
    DO JK = 1, KLEV
    DO JL = KIDIA, KFDIA
      TENDENCY_LOC%Q(JL, JK) = TENDENCY_CML%Q(JL, JK)
      TENDENCY_LOC%T(JL, JK) = TENDENCY_CML%T(JL, JK)
      TENDENCY_LOC%V(JL, JK) = TENDENCY_CML%V(JL, JK)
      TENDENCY_LOC%U(JL, JK) = TENDENCY_CML%U(JL, JK)
      ZENTHD(JL, JK) = 0.0_JPRB
      ZENTHS(JL, JK) = 0.0_JPRB
    END DO
    END DO
    DO JK = 1, KLEV
    DO JL = KIDIA, KFDIA
      ZUP1(JL, JK) = PUM1(JL, JK) + TENDENCY_CML%U(JL, JK)*PTSPHY
      ZVP1(JL, JK) = PVM1(JL, JK) + TENDENCY_CML%V(JL, JK)*PTSPHY
      ZTP1(JL, JK) = PTM1(JL, JK) + TENDENCY_CML%T(JL, JK)*PTSPHY
      ZQP1(JL, JK) = MAX(REPQMI, PQM1(JL, JK) + TENDENCY_CML%Q(JL, JK)*PTSPHY)
      ZQSAT(JL, JK) = ZQP1(JL, JK)
    END DO
    END DO
    IF (LDSLPHY) THEN
    IF (KTRAC > 0 .AND. LMFTRAC) THEN
    DO JN = 1, KTRAC
    DO JK = 1, KLEV
    DO JL = KIDIA, KFDIA
      ZCP1(JL, JK, JN) = PCM1(JL, JK, JN)
    END DO
    END DO
    END DO
    END IF
    ELSE
    IF (KTRAC > 0 .AND. LMFTRAC) THEN
    DO JN = 1, KTRAC
    DO JK = 1, KLEV
    DO JL = KIDIA, KFDIA
      ZCP1(JL, JK, JN) = PCM1(JL, JK, JN) + PTENC(JL, JK, JN)*PTSPHY
    END DO
    END DO
    END DO
    END IF
    END IF
    IFLAG = 1
    native_child_status=satur(constants,thermal,KIDIA , KFDIA , KLON  , NJKT2 , KLEV, configuration%linear_ecmwf%LPHYLIN, PAP   , ZTP1  , ZQSAT , IFLAG  )
    if (native_child_status /= 0) then
      status = native_child_status
      return
    end if
    native_child_status=cumastrn(constants,thermal,rplrg,rpldare,parameters,configuration,NACTAERO,chem_light_active,YDSPP_CONFIG,KIDIA,KFDIA,KLON,KLEV,LDLAND,PTSPHY,ZTP1,ZQP1,ZUP1,ZVP1,PLITOT,PVERVEL,ZQSAT,PQHFL,PAHFS,PAP,PAPH,PGEO,PGEOH,PGAW,PCUCONVCA,PGP2DSPP,TENDENCY_LOC%T,TENDENCY_LOC%Q,TENDENCY_LOC%U,TENDENCY_LOC%V,TENDENCY_DYN%T,TENDENCY_DYN%Q,LDCUM,KTYPE,KCBOT,KCTOP,LDCUM_LIG,KCBOT_LIG,KCTOP_LIG,KBOTSC,LDSC,LDSHCV,PLCRIT_AER,ZTU,ZQU,PLU,PLUDE,PLUDELI,PSNDE,ZENTHD,PFPLCL,PFPLCN,ZRAIN,PLRAIN,PRSUD,PMFU,PMFD,PMFUDE_RATE,PMFDDE_RATE,PCAPE,PWMEAN,PVDISCU,PDISS,KTRAC,ZCP1,PTENC,PSCAV)
    if (native_child_status /= 0) then
      status = native_child_status
      return
    end if
    call cuccdia(constants,thermal,YDERAD,  configuration%linear_ecmwf,  configuration%ecmwf_physics, KIDIA,    KFDIA,    KLON,   KLEV, current_step,    KCBOT,    KCTOP, LDCUM,    ZQU,      PLU,      PMFU,    ZRAIN, PARPRC,   KTOPC,    KBASEC                   )
    LLTEST = (.NOT. LEPCLD .AND. .NOT. LENCLD2 .AND. .NOT. LEPCLD2) .OR. (LPHYLIN .AND. .NOT. LENCLD2 .AND. .NOT. LEPCLD2)
    IF (LLTEST) THEN
    native_child_status=custrat(constants,thermal,  configuration%linear_ecmwf, KIDIA,    KFDIA,    KLON,   KLEV, LDCUM,    PTSPHY,   PVDIFTS, PAP,      PAPH,     PGEO, ZTP1,     ZQP1,     ZQSAT,   ZENTHS, TENDENCY_LOC%T,    TENDENCY_LOC%Q)
      if (native_child_status /= 0) then
        status = native_child_status
        return
      end if
    END IF
    DO JL = KIDIA, KFDIA
      PDIFCQ(JL, 1) = 0.0_JPRB
      PDIFCS(JL, 1) = 0.0_JPRB
      PSTRCU(JL, 1) = 0.0_JPRB
      PSTRCV(JL, 1) = 0.0_JPRB
      PFCQLF(JL, 1) = 0.0_JPRB
      PFCQIF(JL, 1) = 0.0_JPRB
      PFHPCL(JL, 1) = 0.0_JPRB
      PFHPCN(JL, 1) = 0.0_JPRB
      PDIFCS(JL, 1) = 0.0_JPRB
      PDIFCQ(JL, 1) = 0.0_JPRB
      ZCONDFLL(JL) = 0.0_JPRB
      ZCONDFLN(JL) = 0.0_JPRB
    END DO
    DO JK = 1, KLEV
    DO JL = KIDIA, KFDIA
      ZGDPH = -constants%rg/(PAPHM1(JL, JK + 1) - PAPHM1(JL, JK))
      ZCP = constants%rcpd*(1 + thermal%rvtmp2*ZQP1(JL, JK))
      PDIFCS(JL, JK + 1) = (TENDENCY_LOC%T(JL, JK) - TENDENCY_CML%T(JL, JK))/ZGDPH*ZCP + PDIFCS(JL, JK)
      PSTRCU(JL, JK + 1) = (TENDENCY_LOC%U(JL, JK) - TENDENCY_CML%U(JL, JK))/ZGDPH + PSTRCU(JL, JK)
      PSTRCV(JL, JK + 1) = (TENDENCY_LOC%V(JL, JK) - TENDENCY_CML%V(JL, JK))/ZGDPH + PSTRCV(JL, JK)
      PDIFCQ(JL, JK + 1) = (TENDENCY_LOC%Q(JL, JK) - TENDENCY_CML%Q(JL, JK))/ZGDPH + PDIFCQ(JL, JK)
    END DO
    END DO
    DO JK = 1, KLEV
    DO JL = KIDIA, KFDIA
      PFHPCL(JL, JK + 1) = -PFPLCL(JL, JK + 1)*constants%rlvtt
      PFHPCN(JL, JK + 1) = -PFPLCN(JL, JK + 1)*constants%rlstt
      ZCONDFLL(JL) = ZCONDFLL(JL) + PLUDELI(JL, JK, 1)
      ZCONDFLN(JL) = ZCONDFLN(JL) + PLUDELI(JL, JK, 2)
  PDIFCS(JL,JK+1)=PDIFCS(JL,JK+1)-PFHPCL(JL,JK+1)-PFHPCN(JL,JK+ 1) + constants%rlvtt * ZCONDFLL(JL) + constants%rlstt * ZCONDFLN(JL)
      PDIFCQ(JL, JK + 1) = PDIFCQ(JL, JK + 1) - PFPLCL(JL, JK + 1) - PFPLCN(JL, JK + 1) - ZCONDFLL(JL) - ZCONDFLN(JL)
      PFCQLF(JL, JK + 1) = ZCONDFLL(JL)
      PFCQIF(JL, JK + 1) = ZCONDFLN(JL)
    END DO
    END DO
    DO JK = 1, KLEV
    DO JL = KIDIA, KFDIA
      TENDENCY_LOC%Q(JL, JK) = TENDENCY_LOC%Q(JL, JK) - TENDENCY_CML%Q(JL, JK)
      TENDENCY_LOC%T(JL, JK) = TENDENCY_LOC%T(JL, JK) - TENDENCY_CML%T(JL, JK)
      TENDENCY_LOC%V(JL, JK) = TENDENCY_LOC%V(JL, JK) - TENDENCY_CML%V(JL, JK)
      TENDENCY_LOC%U(JL, JK) = TENDENCY_LOC%U(JL, JK) - TENDENCY_CML%U(JL, JK)
    END DO
    END DO
    END ASSOCIATE
  end function cucalln_body
end module convection_controller_mod
