! (C) Copyright 1989- ECMWF.
! This software is licensed under the terms of the Apache Licence Version 2.0
! which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
!
! In applying this licence, ECMWF does not waive the privileges and immunities
! granted to it by virtue of its status as an intergovernmental organisation
! nor does it submit to any jurisdiction

!OPTIONS XOPT(HSFUN)
!> Complete boundary-layer height, parcel state and dry updraft flux.
!! Borrow canonical physical/thermal and input parameter records. Half-level
!! arrays retain the original1:KLEV+1 bounds. Pressures are Pa, temperatures K,
!! geopotential m**2/s**2, humidity kg/kg and timestep seconds.
!! The caller supplies nearest-even, gradual underflow, finite physical
!! values, disjoint returned owners and enough stack for live scratch/children.
module boundary_layer_parcel_height_mod
  use iso_fortran_env, only: JPIM => int32, JPRB => real64, JPRD => real64, int64
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use saturation_humidity_mod, only: satur
  use convective_initial_state_mod, only: cuinin
  use convection_cloud_base_search_mod, only: cubasen
  use convection_source_math_mod, only: source_power, source_exp, source_log
  USE YOEPHLI, ONLY: TEPHLI
  USE YOECLDP, ONLY: TECLDP
  USE YOECUMF, ONLY: TECUMF
  USE YOEVDF, ONLY: TVDF
  USE SPP_MOD, ONLY: TSPP_CONFIG
  implicit none
  private
  public :: vdfhghtn
  real(JPRB), parameter :: RKAP = 0.4_JPRB
  real(JPRB), parameter :: REPDU2 = 0.010000000000000002_JPRB
contains
  !> Preserve the complete normal-physics source stages and inactive tails.
  !! Original arguments/order follow the four readonly providers. Return0
  !! after work,2 for unsupported metadata, or the owned child's status.
  !! No original/model numerical routine supplies an omitted calculation.
  integer(JPIM) function vdfhghtn(constants,thermal,rplrg,rpldare,YDEPHLI,YDECLDP,YDECUMF,YDVDF,YDSPP_CONFIG,KIDIA,KFDIA,KLON,KLEV,PTMST,LDLAND,PTM1,PQM1,PSLGSM1,PUM1,PVM1,PCPTGZ,PAPHM1,PAPM1,PGEOM1,PGEOH,PBLH,PKMFL,PKHFL,PKQFL,PGP2DSPP,PKHVFL,PMFLX,PSLGUH,PQTUH,PUUH,PVUH,PZINV,KINV,KCLDBASE,KCLDTOP,PZCLDBASE,PRI,PEIS,KPBLTYPE)result(status)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    real(JPRB), intent(in) :: rplrg, rpldare
    TYPE(TEPHLI), INTENT(IN) :: YDEPHLI
    TYPE(TECLDP), INTENT(IN) :: YDECLDP
    TYPE(TECUMF), INTENT(IN) :: YDECUMF
    TYPE(TVDF), INTENT(IN) :: YDVDF
    TYPE(TSPP_CONFIG), INTENT(IN) :: YDSPP_CONFIG
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEV
    REAL(KIND=JPRB), INTENT(IN) :: PTMST
    LOGICAL, INTENT(IN) :: LDLAND(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTM1(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PQM1(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PSLGSM1(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PUM1(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PVM1(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PCPTGZ(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PAPHM1(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PAPM1(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PGEOM1(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PGEOH(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PBLH(:)
    REAL(KIND=JPRB), INTENT(IN) :: PKMFL(:)
    REAL(KIND=JPRB), INTENT(IN) :: PKHFL(:)
    REAL(KIND=JPRB), INTENT(IN) :: PKQFL(:)
    REAL(KIND=JPRB), INTENT(IN) :: PGP2DSPP(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PKHVFL(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMFLX(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PSLGUH(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PQTUH(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PUUH(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PVUH(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PZINV(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KINV(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KCLDBASE(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KCLDTOP(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PZCLDBASE(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PRI(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PEIS(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KPBLTYPE(:)
    status = 2_JPIM
    if (KLON < 1 .or. KLON > 4096 .or. KLEV < 4 .or. KLEV > 1024) return
    if (int(KLON, int64)*int(KLEV, int64) > 65536_int64) return
    if (KIDIA < 1 .or. KIDIA > KLON + 1 .or. KFDIA < 0 .or. KFDIA > KLON) return
    if (YDEPHLI%LPHYLIN .or. YDSPP_CONFIG%SM%NRFTOTAL < 0) return
    if (.not. is_contiguous(LDLAND)) return
    if (size(LDLAND, 1) /= KLON) return
    if (.not. is_contiguous(PTM1)) return
    if (size(PTM1, 1) /= KLON) return
    if (size(PTM1, 2) < KLEV) return
    if (.not. is_contiguous(PQM1)) return
    if (size(PQM1, 1) /= KLON) return
    if (size(PQM1, 2) < KLEV) return
    if (.not. is_contiguous(PSLGSM1)) return
    if (size(PSLGSM1, 1) /= KLON) return
    if (size(PSLGSM1, 2) < KLEV) return
    if (.not. is_contiguous(PUM1)) return
    if (size(PUM1, 1) /= KLON) return
    if (size(PUM1, 2) < KLEV) return
    if (.not. is_contiguous(PVM1)) return
    if (size(PVM1, 1) /= KLON) return
    if (size(PVM1, 2) < KLEV) return
    if (.not. is_contiguous(PCPTGZ)) return
    if (size(PCPTGZ, 1) /= KLON) return
    if (size(PCPTGZ, 2) < KLEV) return
    if (.not. is_contiguous(PAPHM1)) return
    if (size(PAPHM1, 1) /= KLON) return
    if (size(PAPHM1, 2) < KLEV + 1) return
    if (.not. is_contiguous(PAPM1)) return
    if (size(PAPM1, 1) /= KLON) return
    if (size(PAPM1, 2) < KLEV) return
    if (.not. is_contiguous(PGEOM1)) return
    if (size(PGEOM1, 1) /= KLON) return
    if (size(PGEOM1, 2) < KLEV) return
    if (.not. is_contiguous(PGEOH)) return
    if (size(PGEOH, 1) /= KLON) return
    if (size(PGEOH, 2) < KLEV + 1) return
    if (.not. is_contiguous(PBLH)) return
    if (size(PBLH, 1) /= KLON) return
    if (.not. is_contiguous(PKMFL)) return
    if (size(PKMFL, 1) /= KLON) return
    if (.not. is_contiguous(PKHFL)) return
    if (size(PKHFL, 1) /= KLON) return
    if (.not. is_contiguous(PKQFL)) return
    if (size(PKQFL, 1) /= KLON) return
    if (.not. is_contiguous(PGP2DSPP)) return
    if (size(PGP2DSPP, 1) /= KLON) return
    if (size(PGP2DSPP, 2) < YDSPP_CONFIG%SM%NRFTOTAL) return
    if (.not. is_contiguous(PKHVFL)) return
    if (size(PKHVFL, 1) /= KLON) return
    if (.not. is_contiguous(PMFLX)) return
    if (size(PMFLX, 1) /= KLON) return
    if (size(PMFLX, 2) < KLEV + 1) return
    if (.not. is_contiguous(PSLGUH)) return
    if (size(PSLGUH, 1) /= KLON) return
    if (size(PSLGUH, 2) < KLEV + 1) return
    if (.not. is_contiguous(PQTUH)) return
    if (size(PQTUH, 1) /= KLON) return
    if (size(PQTUH, 2) < KLEV + 1) return
    if (.not. is_contiguous(PUUH)) return
    if (size(PUUH, 1) /= KLON) return
    if (size(PUUH, 2) < KLEV + 1) return
    if (.not. is_contiguous(PVUH)) return
    if (size(PVUH, 1) /= KLON) return
    if (size(PVUH, 2) < KLEV + 1) return
    if (.not. is_contiguous(PZINV)) return
    if (size(PZINV, 1) /= KLON) return
    if (.not. is_contiguous(KINV)) return
    if (size(KINV, 1) /= KLON) return
    if (.not. is_contiguous(KCLDBASE)) return
    if (size(KCLDBASE, 1) /= KLON) return
    if (.not. is_contiguous(KCLDTOP)) return
    if (size(KCLDTOP, 1) /= KLON) return
    if (.not. is_contiguous(PZCLDBASE)) return
    if (size(PZCLDBASE, 1) /= KLON) return
    if (.not. is_contiguous(PRI)) return
    if (size(PRI, 1) /= KLON) return
    if (size(PRI, 2) < KLEV) return
    if (.not. is_contiguous(PEIS)) return
    if (size(PEIS, 1) /= KLON) return
    if (.not. is_contiguous(KPBLTYPE)) return
    if (size(KPBLTYPE, 1) /= KLON) return
    status=vdfhghtn_body(constants,thermal,rplrg,rpldare,YDEPHLI,YDECLDP,YDECUMF,YDVDF,YDSPP_CONFIG,KIDIA,KFDIA,KLON,KLEV,PTMST,LDLAND(1:KLON),PTM1(1:KLON,1:KLEV),PQM1(1:KLON,1:KLEV),PSLGSM1(1:KLON,1:KLEV),PUM1(1:KLON,1:KLEV),PVM1(1:KLON,1:KLEV),PCPTGZ(1:KLON,1:KLEV),PAPHM1(1:KLON,1:KLEV+1),PAPM1(1:KLON,1:KLEV),PGEOM1(1:KLON,1:KLEV),PGEOH(1:KLON,1:KLEV+1),PBLH(1:KLON),PKMFL(1:KLON),PKHFL(1:KLON),PKQFL(1:KLON),PGP2DSPP(1:KLON,1:YDSPP_CONFIG%SM%NRFTOTAL),PKHVFL(1:KLON),PMFLX(1:KLON,1:KLEV+1),PSLGUH(1:KLON,1:KLEV+1),PQTUH(1:KLON,1:KLEV+1),PUUH(1:KLON,1:KLEV+1),PVUH(1:KLON,1:KLEV+1),PZINV(1:KLON),KINV(1:KLON),KCLDBASE(1:KLON),KCLDTOP(1:KLON),PZCLDBASE(1:KLON),PRI(1:KLON,1:KLEV),PEIS(1:KLON),KPBLTYPE(1:KLON))
  end function vdfhghtn
  integer(JPIM) function vdfhghtn_body(constants,thermal,rplrg,rpldare,YDEPHLI,YDECLDP,YDECUMF,YDVDF,YDSPP_CONFIG,KIDIA,KFDIA,KLON,KLEV,PTMST,LDLAND,PTM1,PQM1,PSLGSM1,PUM1,PVM1,PCPTGZ,PAPHM1,PAPM1,PGEOM1,PGEOH,PBLH,PKMFL,PKHFL,PKQFL,PGP2DSPP,PKHVFL,PMFLX,PSLGUH,PQTUH,PUUH,PVUH,PZINV,KINV,KCLDBASE,KCLDTOP,PZCLDBASE,PRI,PEIS,KPBLTYPE)result(status)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    real(JPRB), intent(in) :: rplrg, rpldare
    TYPE(TEPHLI), INTENT(IN) :: YDEPHLI
    TYPE(TECLDP), INTENT(IN) :: YDECLDP
    TYPE(TECUMF), INTENT(IN) :: YDECUMF
    TYPE(TVDF), INTENT(IN) :: YDVDF
    TYPE(TSPP_CONFIG), INTENT(IN) :: YDSPP_CONFIG
    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEV
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    REAL(KIND=JPRB), INTENT(IN) :: PTMST
    LOGICAL, INTENT(IN) :: LDLAND(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTM1(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PQM1(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PSLGSM1(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PUM1(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PVM1(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PCPTGZ(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PAPHM1(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PAPM1(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PGEOM1(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PGEOH(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PBLH(:)
    REAL(KIND=JPRB), INTENT(IN) :: PKMFL(:)
    REAL(KIND=JPRB), INTENT(IN) :: PKHFL(:)
    REAL(KIND=JPRB), INTENT(IN) :: PKQFL(:)
    REAL(KIND=JPRB), INTENT(IN) :: PGP2DSPP(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMFLX(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PKHVFL(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PSLGUH(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PQTUH(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PUUH(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PVUH(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PZINV(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KPBLTYPE(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PZCLDBASE(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PEIS(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PRI(:, :)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KINV(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KCLDBASE(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KCLDTOP(:)
    LOGICAL :: LLCUM(KLON), LLSC(KLON), LLCONV(KLON)
    LOGICAL :: LLEIS = .false.
    INTEGER(KIND=JPIM) :: JK, JL, JKM, IKB, IKDT, IKT
    INTEGER(KIND=JPIM) :: ILAB(KLON, KLEV)
    INTEGER(KIND=JPIM) :: IDPL(KLON), IBOTSC(KLON), IINV(KLON), ICLDTOP2(KLON)
    REAL(KIND=JPRB) ::    ZQSAT(KLON,KLEV), ZKHFL(KLON,KLEV+1), ZKQFL(KLON,KLEV+1), ZTENH(KLON,KLEV), ZQENH(KLON,KLEV), ZQSENH(KLON,KLEV), ZTU(KLON,KLEV), ZQU(KLON,KLEV), ZLU(KLON,KLEV), ZTD(KLON,KLEV), ZQD(KLON,KLEV), ZWU2H(KLON,KLEV), ZUD(KLON,KLEV), ZVD(KLON,KLEV), ZCAPE(KLON), ZWUBASE(KLON), ZRICRI(KLON), ZINV(KLON), ZLCL(KLON), ZDPSUM(KLON)
    REAL(KIND=JPRB) :: ZDZ, ZZ, ZCPM, ZCONS10, ZRG, ZRGOCPD, ZRCPD, ZMFMAX, ZRHO, ZENTR, ZCM, ZDMFN, ZFAC, ZDU2, ZDRORO
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
    ASSOCIATE(  NJKT1=>YDECUMF%NJKT1, NJKT2=>YDECUMF%NJKT2,NJKT5=>YDECUMF%NJKT5, NJKT6=>YDECUMF%NJKT6, NJKT3=>YDECUMF%NJKT3,NJKT4=>YDECUMF%NJKT4, ENTRDD=>YDECUMF%ENTRDD, ENTSTPC1=>YDECUMF%ENTSTPC1, ENTSTPC2=>YDECUMF%ENTSTPC2, RDEPTHS=>YDECUMF%RDEPTHS, RMFCMIN=>YDECUMF%RMFCMIN, REISTHSC=>YDVDF%REISTHSC )
      IKDT = KLEV
      ZCM = 0.1_JPRB
      ZRG = 1.0_JPRB/constants%rg
      ZRCPD = 1.0_JPRB/constants%rcpd
      ZRGOCPD = constants%rg/constants%rcpd
      DO JL = KIDIA, KFDIA
        PZCLDBASE(JL) = -100._JPRB
        PZINV(JL) = 0.0_JPRB
        ZLCL(JL) = PBLH(JL)
        KPBLTYPE(JL) = 0
        KINV(JL) = KLEV
        IINV(JL) = KLEV
        PEIS(JL) = -999_JPRB
        ZDPSUM(JL) = 0.0_JPRB
        ZRICRI(JL) = 50.0_JPRB
      END DO
      DO JK = 1, KLEV
      DO JL = KIDIA, KFDIA
        ZKHFL(JL, JK) = 0.0_JPRB
        ZKQFL(JL, JK) = 0.0_JPRB
        ZQSAT(JL, JK) = PQM1(JL, JK)
        PRI(JL, JK) = 0.0_JPRB
      END DO
      END DO
      DO JK = 1, KLEV - 1
      DO JL = KIDIA, KFDIA
        ZDZ = PGEOM1(JL, JK) - PGEOM1(JL, JK + 1)
        ZDU2 = MAX(REPDU2, source_power((PUM1(JL, JK) - PUM1(JL, JK + 1)), 2) + source_power((PVM1(JL, JK) - PVM1(JL, JK + 1)), 2))
    ZDRORO= 2.0_JPRB * (PCPTGZ(JL,JK)-PCPTGZ(JL,JK+1)) / ( PCPTGZ(JL,JK)+PCPTGZ(JL,JK+1) - PGEOM1(JL,JK)-PGEOM1(JL,JK+1)) + constants%retv*(PQM1(JL,JK)-PQM1(JL,JK+1))
        PRI(JL, JK) = ZDZ*ZDRORO/ZDU2
      END DO
      END DO
      native_child_status = satur(constants, thermal, KIDIA, KFDIA, KLON, NJKT2, KLEV, YDEPHLI%LPHYLIN, PAPM1, PTM1, ZQSAT, 1)
      if (native_child_status /= 0) then
        status = native_child_status
        return
      end if
    native_child_status=cuinin(constants,thermal, YDEPHLI, YDECUMF, KIDIA,    KFDIA,    KLON,    KLEV, PTM1,     PQM1,     ZQSAT,    PUM1,     PVM1, PGEOM1,   PAPHM1, ILAB, ZTENH,    ZQENH,    ZQSENH,   PGEOH, ZTU,      ZQU,      ZTD,      ZQD, PUUH(:,1:KLEV),     PVUH(:,1:KLEV),      ZUD,      ZVD, ZLU     )
      if (native_child_status /= 0) then
        status = native_child_status
        return
      end if
      JK = KLEV + 1
      JKM = JK - 1
      DO JL = KIDIA, KFDIA
        ZRHO = PAPHM1(JL, JK)/(constants%rd*PTM1(JL, JKM)*(1.0_JPRB + constants%retv*PQM1(JL, JKM)))
        ZKHFL(JL, JK) = PKHFL(JL)*constants%rcpd*ZRHO
        ZKQFL(JL, JK) = PKQFL(JL)*ZRHO
      END DO
      if (.false.) then
    native_child_status=cubasen(constants,thermal,rplrg,rpldare, YDEPHLI, YDECLDP, YDECUMF,  YDSPP_CONFIG, KIDIA,    KFDIA,    KLON,    KLEV,   IKDT,  .false., ZTENH,    ZQENH,    PGEOH,    PAPHM1, ZKQFL,    ZKHFL,    PGP2DSPP, PKMFL, PTM1,     PQM1,     ZQSAT,    PGEOM1, ZTU,      ZQU,      ZLU,      ZWU2H,  ZWUBASE, ILAB,     LLCUM,    LLSC,     KCLDBASE,    IBOTSC, KCLDTOP,  IDPL,     ZCAPE )
        if (native_child_status /= 0) then
          status = native_child_status
          return
        end if
      end if
    native_child_status=cubasen(constants,thermal,rplrg,rpldare, YDEPHLI, YDECLDP, YDECUMF,  YDSPP_CONFIG, KIDIA,    KFDIA,    KLON,    KLEV,    IKDT,  .true., ZTENH,    ZQENH,    PGEOH,    PAPHM1, ZKQFL,    ZKHFL,    PGP2DSPP, PKMFL, PTM1,     PQM1,     ZQSAT,    PGEOM1, ZTU,      ZQU,      ZLU,      ZWU2H,  ZWUBASE, ILAB,     LLCUM,    LLSC,     KCLDBASE,    IBOTSC, KCLDTOP,  IDPL,     ZCAPE )
      if (native_child_status /= 0) then
        status = native_child_status
        return
      end if
      DO JK = 1, KLEV
      DO JL = KIDIA, KFDIA
        ZCPM = constants%rcpd*(1.0_JPRB + thermal%rvtmp2*ZQU(JL, JK))
        PSLGUH(JL, JK) = ZCPM*ZTU(JL, JK) + PGEOH(JL, JK) - FOELH(ZTU(JL, JK))*ZLU(JL, JK)
        PQTUH(JL, JK) = ZQU(JL, JK) + ZLU(JL, JK)
        PMFLX(JL, JK) = 0.0_JPRB
      END DO
      END DO
      JK = KLEV + 1
      JKM = JK - 1
      DO JL = KIDIA, KFDIA
        PSLGUH(JL, JK) = PSLGUH(JL, JKM)
        PQTUH(JL, JK) = PQTUH(JL, JKM)
        PMFLX(JL, JK) = 0.0_JPRB
        PUUH(Jl, JK) = PUM1(JL, JKM)
        PVUH(Jl, JK) = PVM1(JL, JKM)
      END DO
      DO JL = KIDIA, KFDIA
        LLCONV(JL) = .FALSE.
        PKHVFL(JL) = (PKHFL(JL) + constants%retv*PTM1(JL, KLEV)*PKQFL(JL))
        IF (PKHVFL(JL) < 0.0_JPRB) THEN
          LLCONV(JL) = .TRUE.
        END IF
      END DO
      IF (LLEIS) THEN
        ! The source LLEIS choice is immutable false. No alternate stage is called.
        status = 2_JPIM
        return
      ELSE
        DO JL = KIDIA, KFDIA
          PEIS(JL) = MAX(PSLGSM1(JL, NJKT6) - PSLGSM1(JL, NJKT3), PSLGSM1(JL, NJKT3) - PSLGSM1(JL, KLEV))*ZRCPD
        END DO
      END IF
      DO JK = KLEV, 2, -1
      DO JL = KIDIA, KFDIA
      IF (LLCONV(JL) .AND. ZWU2H(JL, JK) > 0.0_JPRB) THEN
        IF (PRI(JL, JK) < ZRICRI(JL)) IINV(JL) = JK
      END IF
      END DO
      END DO
      DO JL = KIDIA, KFDIA
        ZINV(JL) = PZINV(JL)
        IF (LLCONV(JL)) THEN
          IKB = KCLDBASE(JL)
          IKT = KCLDTOP(JL) + 1
          IF (KCLDBASE(JL) == KCLDTOP(JL)) IKT = IKB
          PZINV(JL) = PGEOH(JL, IINV(JL))*ZRG
          ZINV(JL) = PZINV(JL)
          KPBLTYPE(JL) = 1
          IF (IKB > 0) THEN
            KPBLTYPE(JL) = 3
            PZCLDBASE(JL) = PGEOH(JL, IKB)*ZRG
            ZINV(JL) = PGEOH(JL, IKB)*ZRG
            IF (PEIS(JL) > REISTHSC .AND. (PAPHM1(JL, IKB) - PAPHM1(JL, IKT) <= RDEPTHS)) THEN
              KPBLTYPE(JL) = 2
              IINV(JL) = IKT
              PZINV(JL) = PGEOH(JL, IINV(JL))*ZRG
            END IF
          END IF
          PZINV(JL) = MIN(PGEOH(JL, NJKT5)*ZRG, PZINV(JL))
          ZINV(JL) = MIN(PGEOH(JL, NJKT5)*ZRG, ZINV(JL))
        END IF
        KINV(JL) = MAX(NJKT5, IINV(JL))
      END DO
      ZCONS10 = 3.0_JPRB/(constants%rg*PTMST)
      DO JL = KIDIA, KFDIA
        ZZ = PGEOH(JL, KLEV)*ZRG
        IF (ZINV(JL) > ZZ .AND. KPBLTYPE(JL) <= 1) THEN
          ZRHO = PAPM1(JL, KLEV)/(constants%rd*PTM1(JL, KLEV)*(1.0_JPRB + constants%retv*PQM1(JL, KLEV)))
    PMFLX(JL,KLEV) = ZCM * 1.2_JPRB * source_power((  1.5_JPRB * RKAP * MAX(0.0_JPRB,-PKHVFL(JL)) * constants%rg * ZZ / PTM1(JL,KLEV) ),0.33333_JPRB)* source_power(( 1.0_JPRB - ZZ / ZINV(JL) ),0.5_JPRB)* ZRHO
          ZMFMAX = (PAPM1(JL, KLEV) - PAPM1(JL, KLEV - 1))*ZCONS10
          PMFLX(JL, KLEV) = MIN(PMFLX(JL, KLEV), ZMFMAX)
        END IF
      END DO
      DO JK = KLEV - 1, 1, -1
      DO JL = KIDIA, KFDIA
        ZZ = PGEOH(JL, KLEV)*ZRG
        IF (ZINV(JL) > ZZ .AND. PGEOH(JL, JK)*ZRG < ZINV(JL) .AND. KPBLTYPE(JL) <= 1) THEN
          ZMFMAX = (PAPM1(JL, JK) - PAPM1(JL, JK - 1))*ZCONS10
          PMFLX(JL, JK) = PMFLX(JL, KLEV)*PGEOH(JL, JK)/PGEOH(JL, KLEV)*source_power((1.0_JPRB - PGEOH(JL, JK)*ZRG/ZINV(JL)), 2)
          PMFLX(JL, JK) = MIN(PMFLX(JL, JK), ZMFMAX)
          ZDMFN = PMFLX(JL, JK) - PMFLX(JL, JK + 1)
          ZFAC = SIGN(1.0_JPRB, ZDMFN)
          ZENTR = MAX(0.0_JPRB, 0.9_JPRB*ZFAC) + MAX(0.0_JPRB, -0.1_JPRB*ZFAC)*0.5_JPRB
          ZENTR = ZENTR*ABS(ZDMFN/(PMFLX(JL, JK) + 1.E-10_JPRB))
          PUUH(JL, JK) = (PUUH(JL, JK + 1)*(1.0_JPRB - ZENTR) + 2.0_JPRB*ZENTR*PUM1(JL, JK))/(1.0_JPRB + ZENTR)
          PVUH(JL, JK) = (PVUH(JL, JK + 1)*(1.0_JPRB - ZENTR) + 2.0_JPRB*ZENTR*PVM1(JL, JK))/(1.0_JPRB + ZENTR)
        END IF
      END DO
      END DO
    END ASSOCIATE
  end function vdfhghtn_body
end module boundary_layer_parcel_height_mod
