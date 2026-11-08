! (C) Copyright 1989- ECMWF.
! This software is licensed under the terms of the Apache Licence Version 2.0
! which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
!
! In applying this licence, ECMWF does not waive the privileges and immunities
! granted to it by virtue of its status as an intergovernmental organisation
! nor does it submit to any jurisdiction

!> Complete cloud-base search and parcel buoyancy from explicit native inputs.
!! The caller establishes nearest-even, gradual underflow, finite physical
!! values and disjoint writable owners. Pressure is Pa, temperature K,
!! geopotential m**2/s**2, humidity kg/kg and planetary scales dimensionless.
module convection_cloud_base_search_mod
  use iso_fortran_env, only: JPIM => int32, JPRB => real64, int64
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use convective_saturation_adjustment_mod, only: cuadjtq
  use convection_source_math_mod, only: source_power, source_exp, source_log
  USE YOEPHLI, ONLY: TEPHLI
  USE YOECUMF, ONLY: TECUMF
  USE YOECLDP, ONLY: TECLDP
  USE SPP_MOD, ONLY: TSPP_CONFIG
  USE SPP_GEN_MOD, ONLY: SPP_PERT
  implicit none
  private
  public :: cubasen
  real(JPRB), parameter :: RKAP = 0.4_JPRB
contains
  !> Complete the source search for the supplied KINDEX and LDMIXS choices.
  !! Original array arguments/order follow the four readonly providers.
  !! Native descriptors replace original private views. Return0 after work,
  !!2 for unsupported metadata before writes, or the owned child status.
  integer(JPIM) function cubasen(constants,thermal,rplrg,rpldare,YDEPHLI,YDECLDP,YDECUMF,YDSPP_CONFIG,KIDIA,KFDIA,KLON,KLEV,KINDEX,LDMIXS,PTENH,PQENH,PGEOH,PAPH,PQHFL,PAHFS,PGP2DSPP,PKMFL,PTEN,PQEN,PQSEN,PGEO,PTU,PQU,PLU,PWU2H,PWUBASE,KLAB,LDCUM,LDSC,KCBOT,KBOTSC,KCTOP,KDPL,PCAPE)result(status)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    real(JPRB), intent(in) :: rplrg, rpldare
    TYPE(TEPHLI), INTENT(IN) :: YDEPHLI
    TYPE(TECLDP), INTENT(IN) :: YDECLDP
    TYPE(TECUMF), INTENT(IN) :: YDECUMF
    TYPE(TSPP_CONFIG), INTENT(IN) :: YDSPP_CONFIG
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEV
    INTEGER(KIND=JPIM), INTENT(IN) :: KINDEX
    LOGICAL, INTENT(IN) :: LDMIXS
    REAL(KIND=JPRB), INTENT(IN) :: PTENH(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PQENH(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PGEOH(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PAPH(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PQHFL(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PAHFS(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PGP2DSPP(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PKMFL(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTEN(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PQEN(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PQSEN(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PGEO(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTU(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PQU(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PLU(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PWU2H(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PWUBASE(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KLAB(:, :)
    LOGICAL, INTENT(INOUT) :: LDCUM(:)
    LOGICAL, INTENT(INOUT) :: LDSC(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KCBOT(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KBOTSC(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KCTOP(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KDPL(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCAPE(:)
    integer :: selection(2), selected, index
    status = 2_JPIM
    if (KLON < 0 .or. KLON > 4096 .or. KLEV < 3 .or. KLEV > 1024) return
    if (KIDIA < 1 .or. KIDIA > KLON + 1 .or. KFDIA < 0 .or. KFDIA > KLON) return
    if (YDEPHLI%LPHYLIN) return
    if (YDSPP_CONFIG%SM%NRFTOTAL < 0) return
    if (112_int64*int(KLON, int64)*int(KLEV + 1, int64) + 128_int64*KLON > 2097152_int64) return
    if (.not. is_contiguous(PTENH)) return
    if (size(PTENH, 1) /= KLON) return
    if (size(PTENH, 2) < KLEV) return
    if (.not. is_contiguous(PQENH)) return
    if (size(PQENH, 1) /= KLON) return
    if (size(PQENH, 2) < KLEV) return
    if (.not. is_contiguous(PGEOH)) return
    if (size(PGEOH, 1) /= KLON) return
    if (size(PGEOH, 2) < KLEV + 1) return
    if (.not. is_contiguous(PAPH)) return
    if (size(PAPH, 1) /= KLON) return
    if (size(PAPH, 2) < KLEV + 1) return
    if (.not. is_contiguous(PQHFL)) return
    if (size(PQHFL, 1) /= KLON) return
    if (size(PQHFL, 2) < KLEV + 1) return
    if (.not. is_contiguous(PAHFS)) return
    if (size(PAHFS, 1) /= KLON) return
    if (size(PAHFS, 2) < KLEV + 1) return
    if (.not. is_contiguous(PGP2DSPP)) return
    if (size(PGP2DSPP, 1) /= KLON) return
    if (size(PGP2DSPP, 2) < YDSPP_CONFIG%SM%NRFTOTAL) return
    if (.not. is_contiguous(PKMFL)) return
    if (size(PKMFL, 1) /= KLON) return
    if (.not. is_contiguous(PTEN)) return
    if (size(PTEN, 1) /= KLON) return
    if (size(PTEN, 2) < KLEV) return
    if (.not. is_contiguous(PQEN)) return
    if (size(PQEN, 1) /= KLON) return
    if (size(PQEN, 2) < KLEV) return
    if (.not. is_contiguous(PQSEN)) return
    if (size(PQSEN, 1) /= KLON) return
    if (size(PQSEN, 2) < KLEV) return
    if (.not. is_contiguous(PGEO)) return
    if (size(PGEO, 1) /= KLON) return
    if (size(PGEO, 2) < KLEV) return
    if (.not. is_contiguous(PTU)) return
    if (size(PTU, 1) /= KLON) return
    if (size(PTU, 2) < KLEV) return
    if (.not. is_contiguous(PQU)) return
    if (size(PQU, 1) /= KLON) return
    if (size(PQU, 2) < KLEV) return
    if (.not. is_contiguous(PLU)) return
    if (size(PLU, 1) /= KLON) return
    if (size(PLU, 2) < KLEV) return
    if (.not. is_contiguous(PWU2H)) return
    if (size(PWU2H, 1) /= KLON) return
    if (size(PWU2H, 2) < KLEV) return
    if (.not. is_contiguous(PWUBASE)) return
    if (size(PWUBASE, 1) /= KLON) return
    if (.not. is_contiguous(KLAB)) return
    if (size(KLAB, 1) /= KLON) return
    if (size(KLAB, 2) < KLEV) return
    if (.not. is_contiguous(LDCUM)) return
    if (size(LDCUM, 1) /= KLON) return
    if (.not. is_contiguous(LDSC)) return
    if (size(LDSC, 1) /= KLON) return
    if (.not. is_contiguous(KCBOT)) return
    if (size(KCBOT, 1) /= KLON) return
    if (.not. is_contiguous(KBOTSC)) return
    if (size(KBOTSC, 1) /= KLON) return
    if (.not. is_contiguous(KCTOP)) return
    if (size(KCTOP, 1) /= KLON) return
    if (.not. is_contiguous(KDPL)) return
    if (size(KDPL, 1) /= KLON) return
    if (.not. is_contiguous(PCAPE)) return
    if (size(PCAPE, 1) /= KLON) return
    if (YDSPP_CONFIG%LSPP) then
      selection = [YDSPP_CONFIG%PPTR%ENTRORG, YDSPP_CONFIG%PPTR%ENTSTPC1]
      do index = 1, 2
        selected = selection(index)
        if (selected <= 0) cycle
        if (.not. allocated(YDSPP_CONFIG%SM%PN)) return
        if (selected < lbound(YDSPP_CONFIG%SM%PN, 1) .or. selected > ubound(YDSPP_CONFIG%SM%PN, 1)) return
        if (YDSPP_CONFIG%SM%PN(selected)%MP < 1 .or. YDSPP_CONFIG%SM%PN(selected)%MP > YDSPP_CONFIG%SM%NRFTOTAL) return
      end do
    end if
    status=cubasen_body(constants,thermal,rplrg,rpldare,YDEPHLI,YDECLDP,YDECUMF,YDSPP_CONFIG,KIDIA,KFDIA,KLON,KLEV,KINDEX,LDMIXS,PTENH(1:KLON,1:KLEV),PQENH(1:KLON,1:KLEV),PGEOH(1:KLON,1:KLEV+1),PAPH(1:KLON,1:KLEV+1),PQHFL(1:KLON,1:KLEV+1),PAHFS(1:KLON,1:KLEV+1),PGP2DSPP(1:KLON,1:YDSPP_CONFIG%SM%NRFTOTAL),PKMFL(1:KLON),PTEN(1:KLON,1:KLEV),PQEN(1:KLON,1:KLEV),PQSEN(1:KLON,1:KLEV),PGEO(1:KLON,1:KLEV),PTU(1:KLON,1:KLEV),PQU(1:KLON,1:KLEV),PLU(1:KLON,1:KLEV),PWU2H(1:KLON,1:KLEV),PWUBASE(1:KLON),KLAB(1:KLON,1:KLEV),LDCUM(1:KLON),LDSC(1:KLON),KCBOT(1:KLON),KBOTSC(1:KLON),KCTOP(1:KLON),KDPL(1:KLON),PCAPE(1:KLON))
  end function cubasen
  integer(JPIM) function cubasen_body(constants,thermal,rplrg,rpldare,YDEPHLI,YDECLDP,YDECUMF,YDSPP_CONFIG,KIDIA,KFDIA,KLON,KLEV,KINDEX,LDMIXS,PTENH,PQENH,PGEOH,PAPH,PQHFL,PAHFS,PGP2DSPP,PKMFL,PTEN,PQEN,PQSEN,PGEO,PTU,PQU,PLU,PWU2H,PWUBASE,KLAB,LDCUM,LDSC,KCBOT,KBOTSC,KCTOP,KDPL,PCAPE)result(status)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    real(JPRB), intent(in) :: rplrg, rpldare
    TYPE(TECLDP), INTENT(IN) :: YDECLDP
    TYPE(TECUMF), INTENT(IN) :: YDECUMF
    TYPE(TEPHLI), INTENT(IN) :: YDEPHLI
    TYPE(TSPP_CONFIG), INTENT(IN) :: YDSPP_CONFIG
    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEV
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KINDEX
    LOGICAL, INTENT(IN) :: LDMIXS
    REAL(KIND=JPRB), INTENT(IN) :: PTENH(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PQENH(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PGEOH(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PAPH(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PQHFL(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PAHFS(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PGP2DSPP(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PKMFL(:)
    REAL(KIND=JPRB), INTENT(IN) :: PTEN(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PQEN(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PQSEN(:, :)
    REAL(KIND=JPRB), INTENT(IN) :: PGEO(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTU(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PQU(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PLU(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PWU2H(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PWUBASE(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KLAB(:, :)
    LOGICAL, INTENT(INOUT) :: LDCUM(:)
    LOGICAL, INTENT(INOUT) :: LDSC(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KCBOT(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KBOTSC(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KCTOP(:)
    INTEGER(KIND=JPIM), INTENT(INOUT) :: KDPL(:)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCAPE(:)
    INTEGER(KIND=JPIM) :: ICTOP(KLON), ICBOT(KLON), IBOTSC(KLON), ILAB(KLON, KLEV), IDPL(KLON)
    LOGICAL :: LL_LDBASE(KLON), LLGO_ON(KLON), LLDEEP(KLON), LLDCUM(KLON), LLDSC(KLON), LLFIRST(KLON)
    LOGICAL :: LLRESET, LLRESETJL(KLON)
    LOGICAL :: LLPERT_ENTRORG, LLPERT_ENTSTPC1
    INTEGER(KIND=JPIM) :: ICALL, IK, IS, JK, JL, JKK, JKT1, JKT2, JKT, JKB
    INTEGER(KIND=JPIM) :: IPENTRORG, IPENTSTPC1
   REAL(KIND=JPRB)    :: ZS(KLON,KLEV), ZSENH(KLON,KLEV+1), ZQENH(KLON,KLEV+1), ZSUH (KLON,KLEV), ZBUOH(KLON,KLEV), ZWU2H(KLON,KLEV)
    REAL(KIND=JPRB) :: ZQOLD(KLON), ZPH(KLON)
    REAL(KIND=JPRB) :: ZMIX(KLON)
    REAL(KIND=JPRB) :: ZDZ(KLON), ZCBASE(KLON)
    REAL(KIND=JPRB) :: ZLU(KLON, KLEV), ZQU(KLON, KLEV), ZTU(KLON, KLEV)
    REAL(KIND=JPRB) :: ZCAPE(KLON, KLEV)
    REAL(KIND=JPRB) :: ZBUOF
    REAL(KIND=JPRB) :: ZRHO
    REAL(KIND=JPRB) :: ZKHVFL
    REAL(KIND=JPRB) :: ZWS
    REAL(KIND=JPRB) :: ZUST
    REAL(KIND=JPRB) :: ZQEX(KLON), ZQEXC
    REAL(KIND=JPRB) :: ZTEX(KLON), ZTEXC
    REAL(KIND=JPRB) :: ZEPS
    REAL(KIND=JPRB) :: ZTVENH
    REAL(KIND=JPRB) :: ZTVUH
    REAL(KIND=JPRB) :: ZLGLAC
 REAL(KIND=JPRB) :: ZQSU, ZCOR, ZDQ, ZALFAW, ZFACW, ZFACI, ZFAC, ZESDP, ZDQSDT, ZDTDP, ZDP, ZPDIFFTOP, ZPDIFFBOT, ZSF, ZQF, ZAW, ZBW
    REAL(KIND=JPRB) :: ZWORK1, ZWORK2
    REAL(KIND=JPRB) :: ZRCPD, ZRG, ZTMP
    REAL(KIND=JPRB) :: ZXENTRORG, ZXENTSTPC1
    INTEGER(KIND=JPIM) :: IPN
    TYPE(SPP_PERT) :: PN1, PN2
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
    ASSOCIATE(RLMIN=>YDECLDP%RLMIN, ENTRORG=>YDECUMF%ENTRORG, ENTSTPC1=>YDECUMF%ENTSTPC1, ENTSTPC2=>YDECUMF%ENTSTPC2, ENTSTPC3=>YDECUMF%ENTSTPC3, NJKT2=>YDECUMF%NJKT2, RDEPTHS=>YDECUMF%RDEPTHS)
      ZAW = 1.0_JPRB
      ZBW = 1.0_JPRB
      DO JL = KIDIA, KFDIA
        PWUBASE(JL) = 0.0_JPRB
        LLGO_ON(JL) = .TRUE.
        LLFIRST(JL) = .TRUE.
        KDPL(JL) = KLEV
      END DO
      JKT1 = KINDEX
      JKT2 = NJKT2
      ZRG = 1.0_JPRB/constants%rg
      ZRCPD = 1.0_JPRB/constants%rcpd
      DO JK = 1, KLEV
      DO JL = KIDIA, KFDIA
        ZTU(JL, JK) = PTU(JL, JK)
        ZQU(JL, JK) = PQU(JL, JK)
        ZLU(JL, JK) = PLU(JL, JK)
        ILAB(JL, JK) = KLAB(JL, JK)
        ZCAPE(JL, JK) = 0.0_JPRB
      END DO
      END DO
      IF (YDSPP_CONFIG%LSPP) THEN
        IPN = YDSPP_CONFIG%PPTR%ENTRORG
        LLPERT_ENTRORG = IPN > 0
        IF (LLPERT_ENTRORG) THEN
          PN1 = YDSPP_CONFIG%SM%PN(IPN)
          IPENTRORG = PN1%MP
        END IF
        IPN = YDSPP_CONFIG%PPTR%ENTSTPC1
        LLPERT_ENTSTPC1 = IPN > 0
        IF (LLPERT_ENTSTPC1) THEN
          PN2 = YDSPP_CONFIG%SM%PN(IPN)
          IPENTSTPC1 = PN2%MP
        END IF
      ELSE
        LLPERT_ENTSTPC1 = .FALSE.
        LLPERT_ENTRORG = .FALSE.
      END IF
      DO JK = 1, KLEV
      DO JL = KIDIA, KFDIA
        PWU2H(JL, JK) = 0.0_JPRB
        ZWU2H(JL, JK) = 0.0_JPRB
        ZS(JL, JK) = constants%rcpd*PTEN(JL, JK) + PGEO(JL, JK)
        ZQENH(JL, JK) = PQENH(JL, JK)
        ZSENH(JL, JK) = constants%rcpd*PTENH(JL, JK) + PGEOH(JL, JK)
      END DO
      END DO
      DO JKK = KLEV, JKT1, -1
        IS = 0
        DO JL = KIDIA, KFDIA
        IF (LLGO_ON(JL)) THEN
          IS = IS + 1
          IDPL(JL) = JKK
          ICBOT(JL) = JKK
          IBOTSC(JL) = KLEV - 1
          ICTOP(JL) = KLEV - 1
          LLDCUM(JL) = .FALSE.
          LLDSC(JL) = .FALSE.
          LL_LDBASE(JL) = .FALSE.
        END IF
        END DO
        IF (IS /= 0) THEN
        IF (JKK == KLEV) THEN
          ZTEXC = 0.2_JPRB
          ZQEXC = 1.E-4_JPRB
          DO JL = KIDIA, KFDIA
          IF (LLGO_ON(JL)) THEN
            ZRHO = PAPH(JL, JKK + 1)/(constants%rd*(PTEN(JL, JKK)*(1.0_JPRB + constants%retv*PQEN(JL, JKK))))
            ZKHVFL = (PAHFS(JL, JKK + 1)*ZRCPD + constants%retv*PTEN(JL, JKK)*PQHFL(JL, JKK + 1))/(ZRHO*RPLRG*RPLDARE)
            ZUST = MAX(SQRT(PKMFL(JL)), 0.1_JPRB)
            ZWS = source_power(ZUST, 3) - 1.5_JPRB*RKAP*ZKHVFL*(PGEOH(JL, KLEV) - PGEOH(JL, KLEV + 1))/PTEN(JL, KLEV)
            ZTEX(JL) = 0.0_JPRB
            ZQEX(JL) = 0.0_JPRB
            IF (ZKHVFL < 0.0_JPRB) THEN
              ZWS = 1.2_JPRB*source_power(ZWS, .3333_JPRB)
              ILAB(JL, JKK) = 1
              ZTEX(JL) = MAX(-1.5_JPRB*PAHFS(JL, JKK + 1)/(ZRHO*ZWS*constants%rcpd*RPLRG*RPLDARE), ZTEXC)
              ZQEX(JL) = MAX(-1.5_JPRB*PQHFL(JL, JKK + 1)/(ZRHO*ZWS*RPLRG*RPLDARE), ZQEXC)
              ZQU(JL, JKK) = ZQENH(JL, JKK) + ZQEX(JL)
              ZSUH(JL, JKK) = ZSENH(JL, JKK) + constants%rcpd*ZTEX(JL)
              ZTU(JL, JKK) = (ZSENH(JL, JKK) - PGEOH(JL, JKK))*ZRCPD + ZTEX(JL)
              ZLU(JL, JKK) = 0.0_JPRB
              ZWU2H(JL, JKK) = source_power(ZWS, 2) + 0.1_JPRB
              PWU2H(JL, JKK) = ZWU2H(JL, JKK)
              ZTVENH = (1.0_JPRB + constants%retv*ZQENH(JL, JKK))*(ZSENH(JL, JKK) - PGEOH(JL, JKK))*ZRCPD
              ZTVUH = (1.0_JPRB + constants%retv*ZQU(JL, JKK))*ZTU(JL, JKK)
              ZBUOH(JL, JKK) = (ZTVUH - ZTVENH)*constants%rg/ZTVENH
            ELSE
              LLGO_ON(JL) = .FALSE.
            END IF
          END IF
          END DO
        ELSE
          DO JL = KIDIA, KFDIA
          IF (LLGO_ON(JL)) THEN
            ZRHO = PAPH(JL, JKK + 1)/(constants%rd*(PTEN(JL, JKK)*(1.+constants%retv*PQEN(JL, JKK))))
            ILAB(JL, JKK) = 1
            ZTEXC = 0.2_JPRB
            ZQEXC = 1.E-4_JPRB
            IF (JKK == KLEV - 1) THEN
              ZTEXC = MAX(ZTEXC, ZTEX(JL))
              ZTEXC = MIN(ZTEXC, 1.0_JPRB)
              ZQEXC = MAX(ZQEXC, ZQEX(JL))
              ZQEXC = MIN(ZQEXC, 5.E-4_JPRB)
            END IF
            ZQU(JL, JKK) = ZQENH(JL, JKK) + ZQEXC
            ZSUH(JL, JKK) = ZSENH(JL, JKK) + constants%rcpd*ZTEXC
            ZTU(JL, JKK) = (ZSENH(JL, JKK) - PGEOH(JL, JKK))*ZRCPD + ZTEXC
            ZLU(JL, JKK) = 0.0_JPRB
            IF (PAPH(JL, KLEV + 1) - PAPH(JL, JKK - 1) < 60.E2_JPRB) THEN
              ZQU(JL, JKK) = 0.0_JPRB
              ZSUH(JL, JKK) = 0.0_JPRB
              ZWORK1 = 0.0_JPRB
              DO JK = JKK + 1, JKK - 1, -1
              IF (ZWORK1 < 50.E2_JPRB) THEN
                ZWORK2 = PAPH(JL, JK) - PAPH(JL, JK - 1)
                ZWORK1 = ZWORK1 + ZWORK2
                ZQU(JL, JKK) = ZQU(JL, JKK) + ZQENH(JL, JK)*ZWORK2
                ZSUH(JL, JKK) = ZSUH(JL, JKK) + ZSENH(JL, JK)*ZWORK2
              END IF
              END DO
              ZQU(JL, JKK) = ZQU(JL, JKK)/ZWORK1 + ZQEXC
              ZSUH(JL, JKK) = ZSUH(JL, JKK)/ZWORK1 + constants%rcpd*ZTEXC
              ZTU(JL, JKK) = (ZSUH(JL, JKK) - PGEOH(JL, JKK))*ZRCPD + ZTEXC
            END IF
            ZWU2H(JL, JKK) = 1.0_JPRB
            ZTVENH = (1.0_JPRB + constants%retv*ZQENH(JL, JKK))*(ZSENH(JL, JKK) - PGEOH(JL, JKK))*ZRCPD
            ZTVUH = (1.0_JPRB + constants%retv*ZQU(JL, JKK))*ZTU(JL, JKK)
            ZBUOH(JL, JKK) = (ZTVUH - ZTVENH)*constants%rg/ZTVENH
          END IF
          END DO
        END IF
        END IF
        DO JK = JKK - 1, JKT2, -1
          IS = 0
          IF (JKK == KLEV .OR. KINDEX == KLEV - 1) THEN
          DO JL = KIDIA, KFDIA
          IF (LLPERT_ENTSTPC1) THEN
            ZXENTSTPC1 = ENTSTPC1*source_exp(PN2%MU(1) + PN2%XMAG(1)*PGP2DSPP(JL, IPENTSTPC1))
          ELSE
            ZXENTSTPC1 = ENTSTPC1
          END IF
          IF (LLGO_ON(JL)) THEN
            IS = IS + 1
            ZDZ(JL) = (PGEOH(JL, JK) - PGEOH(JL, JK + 1))*ZRG
            ZEPS = ZXENTSTPC1/((PGEO(JL, JK) - PGEOH(JL, KLEV + 1))*ZRG*RPLRG) + ENTSTPC2
            IF (LDMIXS .AND. KINDEX == KLEV .AND. ZLU(JL, JK + 1) > 0.0_JPRB) ZEPS = ZEPS*ENTSTPC3
            ZMIX(JL) = 0.5_JPRB*ZDZ(JL)*RPLRG*ZEPS
            ZMIX(JL) = MIN(1.0_JPRB, ZMIX(JL))
            ZQF = (PQENH(JL, JK + 1) + PQENH(JL, JK))*0.5_JPRB
            ZSF = (ZSENH(JL, JK + 1) + ZSENH(JL, JK))*0.5_JPRB
            ZTMP = 1.0_JPRB/(1.0_JPRB + ZMIX(JL))
            ZQU(JL, JK) = (ZQU(JL, JK + 1)*(1.0_JPRB - ZMIX(JL)) + 2.0_JPRB*ZMIX(JL)*ZQF)*ZTMP
            ZSUH(JL, JK) = (ZSUH(JL, JK + 1)*(1.0_JPRB - ZMIX(JL)) + 2.0_JPRB*ZMIX(JL)*ZSF)*ZTMP
            ZQOLD(JL) = ZQU(JL, JK)
            ZTU(JL, JK) = (ZSUH(JL, JK) - PGEOH(JL, JK))*ZRCPD
            ZPH(JL) = PAPH(JL, JK)
          END IF
          END DO
          ELSE
          ZXENTRORG = ENTRORG
          DO JL = KIDIA, KFDIA
          IF (LLGO_ON(JL)) THEN
          IF (LLPERT_ENTRORG) THEN
            ZXENTRORG = ENTRORG*source_exp(PN1%MU(1) + PN1%XMAG(1)*PGP2DSPP(JL, IPENTRORG))
          END IF
          ZDZ(JL) = (PGEOH(JL, JK) - PGEOH(JL, JK + 1))*ZRG
          ZMIX(JL) = 0.4_JPRB*ZXENTRORG*ZDZ(JL)*MIN(1.0_JPRB, source_power((PQSEN(JL, JK)/PQSEN(JL, KLEV)), 3))
          END IF
          END DO
          DO JL = KIDIA, KFDIA
          IF (LLGO_ON(JL)) THEN
            IS = IS + 1
            ZMIX(JL) = MIN(1.0_JPRB, ZMIX(JL))
            ZQF = (PQENH(JL, JK + 1) + PQENH(JL, JK))*0.5_JPRB
            ZSF = (ZSENH(JL, JK + 1) + ZSENH(JL, JK))*0.5_JPRB
            ZQU(JL, JK) = ZQU(JL, JK + 1)*(1.0_JPRB - ZMIX(JL)) + ZQF*ZMIX(JL)
            ZSUH(JL, JK) = ZSUH(JL, JK + 1)*(1.0_JPRB - ZMIX(JL)) + ZSF*ZMIX(JL)
            ZQOLD(JL) = ZQU(JL, JK)
            ZTU(JL, JK) = (ZSUH(JL, JK) - PGEOH(JL, JK))*ZRCPD
            ZPH(JL) = PAPH(JL, JK)
          END IF
          END DO
          END IF
          IF (IS == 0) EXIT
          IK = JK
          ICALL = 1
          native_child_status = cuadjtq(constants, thermal, YDEPHLI, KIDIA, KFDIA, KLON, KLEV, IK, ZPH, ZTU, ZQU, LLGO_ON, ICALL)
          if (native_child_status /= 0) then
            status = native_child_status
            return
          end if
          DO JL = KIDIA, KFDIA
          IF (LLGO_ON(JL)) THEN
            ZDQ = MAX(ZQOLD(JL) - ZQU(JL, JK), 0.0_JPRB)
            ZLU(JL, JK) = ZLU(JL, JK + 1) + ZDQ
            ZLGLAC = ZDQ*((1.0_JPRB - FOEALFCU(ZTU(JL, JK))) - (1.0_JPRB - FOEALFCU(ZTU(JL, JK + 1))))
            ZLU(JL, JK) = 0.5_JPRB*ZLU(JL, JK)
            ZTU(JL, JK) = ZTU(JL, JK) + thermal%ralfdcp*ZLGLAC
            ZSUH(JL, JK) = constants%rcpd*ZTU(JL, JK) + PGEOH(JL, JK)
            ZTVUH = (1.0_JPRB + constants%retv*ZQU(JL, JK) - ZLU(JL, JK))*ZTU(JL, JK) + thermal%ralfdcp*ZLGLAC
            ZTVENH = (1.0_JPRB + constants%retv*ZQENH(JL, JK))*(ZSENH(JL, JK) - PGEOH(JL, JK))*ZRCPD
            ZBUOH(JL, JK) = (ZTVUH - ZTVENH)*constants%rg/ZTVENH
            ZBUOF = (ZBUOH(JL, JK) + ZBUOH(JL, JK + 1))*0.5_JPRB
            ZTMP = 1.0_JPRB/(1.0_JPRB + 2.0_JPRB*ZBW*ZMIX(JL))
            ZWU2H(JL, JK) = (ZWU2H(JL, JK + 1)*(1.0_JPRB - 2.0_JPRB*ZBW*ZMIX(JL)) + 2.0_JPRB*ZAW*ZBUOF*ZDZ(JL))*ZTMP
            IF (JKK == KLEV) THEN
              PWU2H(JL, JK) = ZWU2H(JL, JK)
            END IF
            ZCAPE(JL, JKK) = ZCAPE(JL, JKK) + MAX(0.0_JPRB, ZBUOF*ZDZ(JL))
            IF (ZLU(JL, JK) > 0.0_JPRB .AND. ILAB(JL, JK + 1) == 1) THEN
              IK = JK + 1
              ZQSU = FOEEWM(ZTU(JL, IK))/PAPH(JL, IK)
              ZESDP = ZQSU
              ZQSU = MIN(0.5_JPRB, ZQSU)
              ZCOR = 1.0_JPRB/(1.0_JPRB - constants%retv*ZQSU)
              ZQSU = ZQSU*ZCOR
              ZDQ = MIN(0._JPRB, ZQU(JL, IK) - ZQSU)
              ZALFAW = FOEALFA(ZTU(JL, IK))
              ZFACW = thermal%r5les/(source_power((ZTU(JL, IK) - thermal%r4les), 2))
              ZFACI = thermal%r5ies/(source_power((ZTU(JL, IK) - thermal%r4ies), 2))
              ZFAC = ZALFAW*ZFACW + (1.-ZALFAW)*ZFACI
              ZCOR = 1.0_JPRB/(1.0_JPRB - constants%retv*ZESDP)
              ZDQSDT = ZFAC*ZCOR*ZQSU
              ZDTDP = constants%rd*ZTU(JL, IK)/(constants%rcpd*PAPH(JL, IK))
              ZDP = ZDQ/(ZDQSDT*ZDTDP)
              ZCBASE(JL) = PAPH(JL, IK) + ZDP
              ZPDIFFTOP = ZCBASE(JL) - PAPH(JL, JK)
              ZPDIFFBOT = PAPH(JL, JK + 1) - ZCBASE(JL)
              IF (ZPDIFFTOP > ZPDIFFBOT .AND. ZWU2H(JL, JK + 1) > 0.0_JPRB) THEN
                JKB = MIN(KLEV - 1, JK + 1)
                ILAB(JL, JKB) = 2
                ILAB(JL, JK) = 2
                LL_LDBASE(JL) = .TRUE.
                LLDSC(JL) = .TRUE.
                IBOTSC(JL) = JKB
                ICBOT(JL) = JKB
                ZLU(JL, JK + 1) = RLMIN
              ELSEIF (ZPDIFFTOP <= ZPDIFFBOT .AND. ZWU2H(JL, JK) > 0.0_JPRB) THEN
                ILAB(JL, JK) = 2
                LL_LDBASE(JL) = .TRUE.
                LLDSC(JL) = .TRUE.
                IBOTSC(JL) = JK
                ICBOT(JL) = JK
              END IF
            END IF
            IF (ZWU2H(JL, JK) < 0.0_JPRB) THEN
              LLGO_ON(JL) = .FALSE.
              IF (ZLU(JL, JK + 1) > 0.0_JPRB) THEN
                ICTOP(JL) = JK
                LLDCUM(JL) = .TRUE.
              ELSE
                LLDCUM(JL) = .FALSE.
              END IF
            ELSE
              IF (ZLU(JL, JK) > 0.0_JPRB) THEN
                ILAB(JL, JK) = 2
              ELSE
                ILAB(JL, JK) = 1
              END IF
            END IF
          END IF
          END DO
        END DO
        IF (JKK == KLEV .OR. (JKK == KLEV - 1 .AND. KINDEX == KLEV - 1)) THEN
        DO JL = KIDIA, KFDIA
          LDSC(JL) = LLDSC(JL)
          IF (LDSC(JL)) THEN
            KBOTSC(JL) = IBOTSC(JL)
          ELSE
            KBOTSC(JL) = -1
          END IF
          JKT = ICTOP(JL)
          JKB = ICBOT(JL)
          LLDEEP(JL) = PAPH(JL, JKB) - PAPH(JL, JKT) > RDEPTHS
          IF (LLDEEP(JL) .AND. KINDEX < KLEV - 1) LLDCUM(JL) = .FALSE.
          LLDEEP(JL) = .FALSE.
          LLGO_ON(JL) = .NOT. LLDEEP(JL)
          IF (KINDEX == KLEV - 1) LLGO_ON(JL) = .NOT. LLDCUM(JL)
          IF (LLDCUM(JL)) THEN
            KCBOT(JL) = ICBOT(JL)
            KCTOP(JL) = ICTOP(JL)
            KDPL(JL) = IDPL(JL)
            LDCUM(JL) = LLDCUM(JL)
            PWUBASE(JL) = SQRT(MAX(ZWU2H(JL, JKB), 0.0_JPRB))
          ELSE
            KCTOP(JL) = -1
            KCBOT(JL) = -1
            KDPL(JL) = KLEV - 1
            LDCUM(JL) = .FALSE.
            PWUBASE(JL) = 0.0_JPRB
          END IF
        END DO
        DO JK = KLEV, 1, -1
        DO JL = KIDIA, KFDIA
          JKT = ICTOP(JL)
          IF (JK >= JKT .OR. (KINDEX >= KLEV - 1 .AND. JKK == KLEV)) THEN
            KLAB(JL, JK) = ILAB(JL, JK)
            PTU(JL, JK) = ZTU(JL, JK)
            PQU(JL, JK) = ZQU(JL, JK)
            PLU(JL, JK) = ZLU(JL, JK)
          END IF
        END DO
        END DO
        END IF
        IF (JKK < KLEV) THEN
          LLRESET = .FALSE.
          DO JL = KIDIA, KFDIA
          IF (.NOT. LLDEEP(JL)) THEN
            JKT = ICTOP(JL)
            JKB = ICBOT(JL)
            LLDEEP(JL) = PAPH(JL, JKB) - PAPH(JL, JKT) >= RDEPTHS
          END IF
          LLRESETJL(JL) = LLDEEP(JL) .AND. LLFIRST(JL)
          LLRESET = LLRESET .OR. LLRESETJL(JL)
          END DO
          IF (LLRESET) THEN
          DO JK = KLEV, 1, -1
          DO JL = KIDIA, KFDIA
          IF (LLRESETJL(JL)) THEN
            JKT = ICTOP(JL)
            JKB = IDPL(JL)
            IF (JK <= JKB .AND. JK >= JKT) THEN
              KLAB(JL, JK) = ILAB(JL, JK)
              PTU(JL, JK) = ZTU(JL, JK)
              PQU(JL, JK) = ZQU(JL, JK)
              PLU(JL, JK) = ZLU(JL, JK)
            ELSE
              KLAB(JL, JK) = 1
              PTU(JL, JK) = PTENH(JL, JK)
              PQU(JL, JK) = PQENH(JL, JK)
              PLU(JL, JK) = 0.0_JPRB
            END IF
            IF (JK < JKT) KLAB(JL, JK) = 0
          END IF
          END DO
          END DO
          END IF
          DO JL = KIDIA, KFDIA
          IF (LLDEEP(JL) .AND. LLFIRST(JL)) THEN
            KDPL(JL) = IDPL(JL)
            KCTOP(JL) = ICTOP(JL)
            KCBOT(JL) = ICBOT(JL)
            LDCUM(JL) = LLDCUM(JL)
            LDSC(JL) = .FALSE.
            KBOTSC(JL) = -1
            JKB = KCBOT(JL)
            PWUBASE(JL) = SQRT(MAX(ZWU2H(JL, JKB), 0.0_JPRB))
            LLFIRST(JL) = .FALSE.
          END IF
          LLGO_ON(JL) = .NOT. LLDEEP(JL)
          END DO
        END IF
      END DO
      DO JL = KIDIA, KFDIA
        PCAPE(JL) = MAXVAL(ZCAPE(JL, :))
      END DO
    END ASSOCIATE
  end function cubasen_body
end module convection_cloud_base_search_mod
