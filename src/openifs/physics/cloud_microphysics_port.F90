!> Compute the selected five-species cloud update in frozen arithmetic order.
!! Temperature uses K, pressure uses Pa, and water amounts use kg/kg.
!! Each column retains its ordered vertical updates and phase reductions.
!! The complete native argument interface lives in cloud_microphysics_interface.F90.
submodule(cloud_microphysics_mod) cloud_microphysics_implementation
  use iso_c_binding, only: c_double, c_int, c_ptr, c_f_pointer
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use yomcst, only: &
    constant_rg => rg, &
    constant_rd => rd, &
    constant_rv => rv, &
    constant_rcpd => rcpd, &
    constant_retv => retv, &
    constant_rtt => rtt, &
    constant_rlvtt => rlvtt, &
    constant_rlstt => rlstt, &
    constant_rpi => rpi, &
    constant_rpi => rpi
  use yoethf, only: &
    constant_r2es => r2es, &
    constant_r3les => r3les, &
    constant_r3ies => r3ies, &
    constant_r4les => r4les, &
    constant_r4ies => r4ies, &
    constant_r5les => r5les, &
    constant_r5ies => r5ies, &
    constant_ralvdcp => ralvdcp, &
    constant_ralsdcp => ralsdcp, &
    constant_ralfdcp => ralfdcp, &
    constant_rtwat => rtwat, &
    constant_rtice => rtice, &
    constant_rtwat_rtice_r => rtwat_rtice_r, &
    constant_rkoop1 => rkoop1, &
    constant_rkoop2 => rkoop2
  use yommp0, only: lscmec
  implicit none
  interface
    function selected_exp(x) bind(c, name="exp") result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function selected_exp
    function selected_pow(x, power) bind(c, name="pow") result(y)
      import c_double
      real(c_double), value :: x, power
      real(c_double) :: y
    end function selected_pow
    function errno_address() bind(c, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function errno_address
    subroutine reject_contract() bind(c, name="abort")
    end subroutine reject_contract
    subroutine cloud_supersatcheck(ydecldp, kidia, kfdia, klon, klev, kftliqice, &
                                   pt, pq, pa, pp, psurf, pt_adj, pq_adj, pa_adj, pl_adj, pi_adj)
      import tecldp, int32, real64
      type(tecldp), intent(in) :: ydecldp
      integer(int32), intent(in) :: kidia, kfdia, klon, klev, kftliqice
      real(real64), intent(in) :: pt(klon), pq(klon), pa(klon), pp(klon), psurf(klon)
      real(real64), intent(inout) :: pt_adj(klon), pq_adj(klon), pa_adj(klon), pl_adj(klon), pi_adj(klon)
    end subroutine cloud_supersatcheck
  end interface
contains
  module procedure cloudsc
  real(real64) :: v_zero, v_one, v_half, v_eps, v_small, v_dt
  real(real64) :: v_invdt, v_rg, v_rd, v_cp, v_rv, v_retv
  real(real64) :: v_rtt, v_lv, v_ls, v_alv, v_als, v_alf
  real(real64) :: v_r2es, v_r3l, v_r3i, v_r4l, v_r4i, v_r5l
  real(real64) :: v_r5i, v_rtwat, v_rtice, v_rtinv, v_koop1, v_koop2
  real(real64) :: v_gdcp, v_rdcp, v_rgr, v_rldcp, v_advw, v_advwd
  real(real64) :: v_trpaus, v_psurfinv, v_covptot, v_covpclr, v_covpmax, v_cldtopdist
  real(real64) :: v_anewm1, v_da, v_llrain, v_tmp0, v_tmp1, v_tmp2
  real(real64) :: v_tmp3, v_tmp4, v_tmp5, v_tmp6, v_tmp7, v_t
  real(real64) :: v_a, v_aor, v_ql, v_qi, v_qr, v_qs
  real(real64) :: v_qv, v_ql0, v_qi0, v_qr0, v_qs0, v_qv0
  real(real64) :: v_alfa, v_qsm, v_qsl, v_qsi, v_fom, v_foi
  real(real64) :: v_fol, v_li, v_lif, v_iif, v_p, v_ph
  real(real64) :: v_phnext, v_phm1, v_pm1, v_tm1, v_am1, v_dtgdp
  real(real64) :: v_rdtgdp, v_dtgdpf, v_dp, v_gdp, v_rho, v_facw
  real(real64) :: v_faci, v_cor, v_dqsl, v_dqsi, v_dqsm, v_corqsl
  real(real64) :: v_corqsi, v_corqsm, v_evapm, v_evapl, v_evapi, v_liqcld
  real(real64) :: v_icecld, v_licld, v_solab, v_solac, v_mf, v_acust
  real(real64) :: v_lcustl, v_lcusti, v_lfinal, v_lfinalsum, v_dtdp, v_wtot
  real(real64) :: v_dtforc, v_dqs, v_evap, v_mfdn, v_ldifdt, v_qe
  real(real64) :: v_e, v_leros, v_aeros, v_fallcorr, v_temp, v_rlambda
  real(real64) :: v_pretot, v_raincld, v_raincldm1, v_snowcld, v_snowcldm1, v_rainaut
  real(real64) :: v_rainacc, v_lcrit, v_factor, v_ind, v_rh0, v_qclr
  real(real64) :: v_corr, v_rainevap, v_beta, v_lambda, v_denom, v_vpd
  real(real64) :: v_vtemp, v_iceinit, v_cvds, v_icedep, v_iget, v_ice0
  real(real64) :: v_iceafter, v_deprate, v_icetot, v_grow, v_rate, v_remainder
  real(real64) :: v_tc, v_fac, v_freeze, v_melt, v_maxmelt, v_wetbulb
  real(real64) :: v_rr, v_raci, v_racr, v_rics, v_praci, v_psacr
  real(real64) :: v_rimeliq, v_rimesnow, v_rime, v_qpre, v_qprenew, v_rhlimit
  real(real64) :: v_rhnew, v_rainflux, v_qnew, v_sumrhs, v_sinksum, v_ratio
  real(real64) :: v_rat, v_maxval, v_zzratio, v_da0, v_tup, v_qup
  real(real64) :: v_aup, v_tadj, v_qadj, v_aadj, v_ladj, v_iadj
  real(real64) :: v_fluxq, v_aqnew, v_gdphr, v_dt_temp, v_waterloss, v_hloss
  real(real64) :: v_signtmp, v_qlneg, v_qineg, v_qrneg, v_qsneg, v_qlxn
  real(real64) :: v_qixn, v_qrxn, v_qsxn, v_pval, v_pval2, v_pval3
  real(real64) :: v_fg1, v_fg2, v_fg3, v_fg4, v_fg5, v_prev1
  real(real64) :: v_prev2, v_prev3, v_prev4, v_prev5, v_fallspd1, v_fallspd2
  real(real64) :: v_fallspd3, v_fallspd4, v_fallspd5, v_fallsrc1, v_fallsrc2, v_fallsrc3
  real(real64) :: v_fallsrc4, v_fallsrc5, v_fallsink1, v_fallsink2, v_fallsink3, v_fallsink4
  real(real64) :: v_fallsink5, v_convsrc1, v_convsrc2, v_convsrc3, v_convsrc4, v_convsrc5
  real(real64) :: v_convsink1, v_convsink2, v_convsink3, v_convsink4, v_convsink5, v_rhs1
  real(real64) :: v_rhs2, v_rhs3, v_rhs4, v_rhs5, v_lamr, v_lams
  real(real64) :: v_lami, v_n0r, v_n0s, v_n0i, v_falldiff, v_transport1
  real(real64) :: v_transport2, v_transport3, v_transport4, v_transport5, v_pi, v_psurf
  real(real64) :: v_p_laericeauto
  real(real64), parameter :: lcone = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
  real(real64), parameter :: lchalf = transfer(int(z'3FE0000000000000', int64), 0.0_real64)
  real(real64), parameter :: lceps = transfer(int(z'3D19000000000000', int64), 0.0_real64)
  real(real64), parameter :: lcsmall = transfer(int(z'3D06849B86A12B9B', int64), 0.0_real64)
  real(real64), parameter :: lc01 = transfer(int(z'3FB999999999999A', int64), 0.0_real64)
  real(real64), parameter :: lc04 = transfer(int(z'3FD999999999999A', int64), 0.0_real64)
  real(real64), parameter :: lc001 = transfer(int(z'3F847AE147AE147B', int64), 0.0_real64)
  real(real64), parameter :: lc0001 = transfer(int(z'3F50624DD2F1A9FC', int64), 0.0_real64)
  real(real64), parameter :: lcten = transfer(int(z'4024000000000000', int64), 0.0_real64)
  real(real64), parameter :: lctwenty = transfer(int(z'4034000000000000', int64), 0.0_real64)
  real(real64), parameter :: lctwo = transfer(int(z'4000000000000000', int64), 0.0_real64)
  real(real64), parameter :: lcfive = transfer(int(z'4014000000000000', int64), 0.0_real64)
  real(real64), parameter :: lc0333 = transfer(int(z'3FD54FDF3B645A1D', int64), 0.0_real64)
  real(real64), parameter :: lcone_less_micro = transfer(int(z'3FEFFFFDE7210BE9', int64), 0.0_real64)
  real(real64), parameter :: lc08 = transfer(int(z'3FE999999999999A', int64), 0.0_real64)
  real(real64), parameter :: lc02 = transfer(int(z'3FC999999999999A', int64), 0.0_real64)
  real(real64), parameter :: lc09 = transfer(int(z'3FECCCCCCCCCCCCD', int64), 0.0_real64)
  real(real64), parameter :: lc04single = transfer(int(z'3FD99999A0000000', int64), 0.0_real64)
  real(real64), parameter :: lc08single = transfer(int(z'3FE99999A0000000', int64), 0.0_real64)
  real(real64), parameter :: lc273 = transfer(int(z'4071100000000000', int64), 0.0_real64)
  real(real64), parameter :: lc15 = transfer(int(z'3FF8000000000000', int64), 0.0_real64)
  real(real64), parameter :: lcthree = transfer(int(z'4008000000000000', int64), 0.0_real64)
  real(real64), parameter :: lc393 = transfer(int(z'4078900000000000', int64), 0.0_real64)
  real(real64), parameter :: lc120 = transfer(int(z'405E000000000000', int64), 0.0_real64)
  real(real64), parameter :: lc015 = transfer(int(z'3FC3333333333333', int64), 0.0_real64)
  real(real64), parameter :: lc078 = transfer(int(z'3FE8F5C28F5C28F6', int64), 0.0_real64)
  real(real64), parameter :: lc1296 = transfer(int(z'4029EB851EB851EC', int64), 0.0_real64)
  real(real64), parameter :: lc0639 = transfer(int(z'3FE472B020C49BA6', int64), 0.0_real64)
  real(real64), parameter :: lcthousand = transfer(int(z'408F400000000000', int64), 0.0_real64)
  real(real64), parameter :: lc0024 = transfer(int(z'3F989374BC6A7EFA', int64), 0.0_real64)
  real(real64), parameter :: lc221 = transfer(int(z'4001AE147AE147AE', int64), 0.0_real64)
  real(real64), parameter :: lc0666 = transfer(int(z'3FE54FDF3B645A1D', int64), 0.0_real64)
  real(real64), parameter :: lc78 = transfer(int(z'401F333333333333', int64), 0.0_real64)
  real(real64), parameter :: lc887 = transfer(int(z'4021BD70A3D70A3D', int64), 0.0_real64)
  real(real64), parameter :: lc15000 = transfer(int(z'40CD4C0000000000', int64), 0.0_real64)
  real(real64), parameter :: lc065 = transfer(int(z'3FE4CCCCCCCCCCCD', int64), 0.0_real64)
  real(real64), parameter :: lcfifty = transfer(int(z'4049000000000000', int64), 0.0_real64)
  real(real64), parameter :: lctw1 = transfer(int(z'4094C53D70A3D70A', int64), 0.0_real64)
  real(real64), parameter :: lctw2 = transfer(int(z'3F7E8FF327AA68F5', int64), 0.0_real64)
  real(real64), parameter :: lctw3 = transfer(int(z'40F4C08000000000', int64), 0.0_real64)
  real(real64), parameter :: lctw4 = transfer(int(z'40445189374BC6A8', int64), 0.0_real64)
  real(real64), parameter :: lctw5 = transfer(int(z'4071300000000000', int64), 0.0_real64)
  real(real64), parameter :: lceight = transfer(int(z'4020000000000000', int64), 0.0_real64)
  real(real64), parameter :: lc05777 = transfer(int(z'3FE27C84B5DCC63F', int64), 0.0_real64)
  real(real64), allocatable :: column_state(:, :)
  real(real64) :: explicit_exchange(5, 5), implicit_exchange(5, 5), system_matrix(5, 5)
  real(real64) :: solution(5), sink_ratios(5), phase_amount(5), product, sink, available, fraction, floating_temporary
  real(real64) :: temperature_trial(1), vapour_trial(1), cloud_trial(1), pressure_trial(1), surface_trial(1)
  real(real64) :: temperature_adjust(1), vapour_adjust(1), cloud_adjust(1), liquid_adjust(1), ice_adjust(1)
  integer(int32) :: column, level, selection, comparison_index, convection_type, allocation_status
  integer(int32) :: species_order(5), species, insertion, previous_species, ordered_species, other_species
  integer(int32) :: pivot, matrix_row, matrix_column
  integer(c_int), pointer :: errno_value
  integer(c_int) :: saved_errno
  logical :: outgoing(5)
  call require_ieee_mode()
  if (klon < 1 .or. klon > 4096 .or. klev < 2 .or. klev > 256) call reject_contract()
  if (kidia /= 1 .or. kfdia < 0 .or. kfdia > klon) call reject_contract()
  if (ydecldp%ncldtop < 2 .or. ydecldp%ncldtop > klev .or. ydecldp%nssopt /= 1) call reject_contract()
  if (ydecldp%laericeauto .or. ydecldp%laericesed .or. ydecldp%laerliqautolsp) call reject_contract()
  if (ydecldp%laerliqcoll .or. ydecldp%lcloud_inhomog .or. ydecldp%lcldbudget) call reject_contract()
  if (ydecldp%lcldbudc .or. ydecldp%lcldbudl .or. ydecldp%lcldbudi .or. ydecldp%lcldbudt) call reject_contract()
  if (ydecldp%lcldbud_vertint .or. ydephy%lbud23 .or. ydephy%lrad_cloud_inhomog) call reject_contract()
  if (ydspp_config%lspp .or. ydspp_config%sm%nrftotal /= 0 .or. kfldx /= 0 .or. lscmec) call reject_contract()
  if (.not. (ptsphy > 0.0_real64)) call reject_contract()
  call c_f_pointer(errno_address(), errno_value)
  saved_errno = errno_value
  allocate (column_state(40, klev + 1), stat=allocation_status)
  if (allocation_status /= 0) call reject_contract()
  v_dt = ptsphy
  v_zero = 0.0_real64
  v_one = lcone
  v_half = lchalf
  v_eps = lceps
  v_small = lcsmall
  v_rg = constant_rg
  v_rd = constant_rd
  v_rv = constant_rv
  v_cp = constant_rcpd
  v_retv = constant_retv
  v_rtt = constant_rtt
  v_lv = constant_rlvtt
  v_ls = constant_rlstt
  v_r2es = constant_r2es
  v_r3l = constant_r3les
  v_r3i = constant_r3ies
  v_r4l = constant_r4les
  v_r4i = constant_r4ies
  v_r5l = constant_r5les
  v_r5i = constant_r5ies
  v_alv = constant_ralvdcp
  v_als = constant_ralsdcp
  v_alf = constant_ralfdcp
  v_rtwat = constant_rtwat
  v_rtice = constant_rtice
  v_rtinv = constant_rtwat_rtice_r
  v_koop1 = constant_rkoop1
  v_koop2 = constant_rkoop2
  v_invdt = v_one/v_dt
  v_gdcp = v_rg/v_cp
  v_rdcp = v_rd/v_cp
  v_rgr = v_one/v_rg
  v_tmp0 = v_als - v_alv
  v_rldcp = v_one/v_tmp0
  prainfrac_toprfz = 0.0_real64
! The controller cleared the complete rain-fraction owner once.
! The original initialises the entire rain-fraction owner, including inactive columns.
  do column = kidia, kfdia
    column_state = 0.0_real64
    v_advw = v_one
    v_advwd = v_one
    selection = ktype(column)
    if (selection /= 1) goto 1875
    v_tmp0 = ydecumf%rmfadvw
    if (v_tmp0 <= v_zero) goto 1875
    v_advw = v_one - v_tmp0
    v_tmp1 = ydecumf%rmfadvwdd
    v_tmp0 = v_tmp0*v_tmp1
    v_advwd = v_one - v_tmp0
1875 continue
    v_anewm1 = 0.0_real64
    v_covptot = 0.0_real64
    v_covpclr = 0.0_real64
    v_covpmax = 0.0_real64
    v_cldtopdist = 0.0_real64
    v_llrain = v_one
    v_prev1 = 0.0_real64
    v_prev2 = 0.0_real64
    v_prev3 = 0.0_real64
    v_prev4 = 0.0_real64
    v_prev5 = 0.0_real64
    v_transport1 = 0.0_real64
    v_transport2 = 0.0_real64
    v_transport3 = 0.0_real64
    v_transport4 = 0.0_real64
    v_transport5 = 0.0_real64
    do level = 1, klev
1894  continue
      v_tmp0 = 0.0_real64
      ptendency_loc_t(column, level) = v_tmp0
      ptendency_loc_q(column, level) = v_tmp0
      ptendency_loc_a(column, level) = v_tmp0
      ptendency_loc_cld(column, level, 1) = v_tmp0
      ptendency_loc_cld(column, level, 2) = v_tmp0
      ptendency_loc_cld(column, level, 3) = v_tmp0
      ptendency_loc_cld(column, level, 4) = v_tmp0
      v_t = pt(column, level)
      v_tmp0 = ptendency_cml_t(column, level)
      v_tmp0 = v_dt*v_tmp0
      v_t = v_t + v_tmp0
      column_state(1, level) = v_t
      v_qv = pq(column, level)
      v_tmp0 = ptendency_cml_q(column, level)
      v_tmp0 = v_dt*v_tmp0
      v_qv = v_qv + v_tmp0
      column_state(8, level) = v_qv
      column_state(13, level) = v_qv
      v_a = pa(column, level)
      v_tmp0 = ptendency_cml_a(column, level)
      v_tmp0 = v_dt*v_tmp0
      v_a = v_a + v_tmp0
      column_state(2, level) = v_a
      column_state(3, level) = v_a
      v_ql = pclv(column, level, 1)
      v_tmp0 = ptendency_cml_cld(column, level, 1)
      v_tmp0 = v_dt*v_tmp0
      v_ql = v_ql + v_tmp0
      column_state(4, level) = v_ql
      column_state(9, level) = v_ql
      v_qi = pclv(column, level, 2)
      v_tmp0 = ptendency_cml_cld(column, level, 2)
      v_tmp0 = v_dt*v_tmp0
      v_qi = v_qi + v_tmp0
      column_state(5, level) = v_qi
      column_state(10, level) = v_qi
      v_qr = pclv(column, level, 3)
      v_tmp0 = ptendency_cml_cld(column, level, 3)
      v_tmp0 = v_dt*v_tmp0
      v_qr = v_qr + v_tmp0
      column_state(6, level) = v_qr
      column_state(11, level) = v_qr
      v_qs = pclv(column, level, 4)
      v_tmp0 = ptendency_cml_cld(column, level, 4)
      v_tmp0 = v_dt*v_tmp0
      v_qs = v_qs + v_tmp0
      column_state(7, level) = v_qs
      column_state(12, level) = v_qs
    end do
! Surface pressure and tropopause diagnostic keep the source pressure ordering.
    v_ph = paph(column, klev + 1)
    v_psurfinv = v_one/v_ph
    v_trpaus = lc01
    do level = 1, klev - 1
1958  continue
      v_t = column_state(1, level)
      v_tmp0 = column_state(1, level + 1)
      v_p = pap(column, level)
      v_tmp1 = v_p*v_psurfinv
      v_tmp2 = lc01
      if (v_tmp1 <= v_tmp2) goto 1974
      v_tmp2 = lc04
      if (v_tmp1 >= v_tmp2) goto 1974
      if (v_t <= v_tmp0) goto 1974
      v_trpaus = v_tmp1
1974  continue
    end do
    do level = 1, klev
1982  continue
      v_t = column_state(1, level)
      v_p = pap(column, level)
      v_tmp0 = min(v_rtwat, v_t)
      v_tmp0 = max(v_rtice, v_tmp0)
      v_tmp0 = v_tmp0 - v_rtice
      v_tmp0 = v_tmp0*v_rtinv
      v_tmp0 = v_tmp0*v_tmp0
      v_alfa = min(v_one, v_tmp0)
      column_state(14, level) = v_alfa
      v_tmp0 = v_t - v_rtt
      v_tmp0 = v_r3l*v_tmp0
      v_tmp1 = v_t - v_r4l
      v_tmp0 = v_tmp0/v_tmp1
      v_tmp4 = selected_exp(v_tmp0)
      v_tmp0 = v_t - v_rtt
      v_tmp0 = v_r3i*v_tmp0
      v_tmp1 = v_t - v_r4i
      v_tmp0 = v_tmp0/v_tmp1
      v_tmp5 = selected_exp(v_tmp0)
      v_tmp0 = v_alfa*v_tmp4
      v_tmp1 = v_one - v_alfa
      v_tmp1 = v_tmp1*v_tmp5
      v_tmp0 = v_tmp0 + v_tmp1
      v_tmp0 = v_r2es*v_tmp0
      v_tmp0 = v_tmp0/v_p
      v_fom = min(v_tmp0, v_half)
      column_state(32, level) = v_fom
      v_tmp0 = v_retv*v_fom
      v_tmp0 = v_one - v_tmp0
      v_qsm = v_fom/v_tmp0
      column_state(15, level) = v_qsm
! FOEDELTA selects liquid at and above the triple-point temperature.
      if (v_t >= v_rtt) goto 2020
      v_tmp2 = v_zero
      goto 2022
2020  continue
      v_tmp2 = v_one
2022  continue
      v_tmp4 = v_r2es*v_tmp4
      v_tmp5 = v_r2es*v_tmp5
      v_tmp0 = v_tmp2*v_tmp4
      v_tmp1 = v_one - v_tmp2
      v_tmp1 = v_tmp1*v_tmp5
      v_tmp0 = v_tmp0 + v_tmp1
      v_tmp0 = v_tmp0/v_p
      v_foi = min(v_tmp0, v_half)
      v_foi = min(v_half, v_foi)
      column_state(33, level) = v_foi
      v_tmp0 = v_retv*v_foi
      v_tmp0 = v_one - v_tmp0
      v_qsi = v_foi/v_tmp0
      column_state(17, level) = v_qsi
      v_tmp0 = v_tmp4/v_p
      v_fol = min(v_tmp0, v_half)
      column_state(34, level) = v_fol
      v_tmp0 = v_retv*v_fol
      v_tmp0 = v_one - v_tmp0
      v_qsl = v_fol/v_tmp0
      column_state(16, level) = v_qsl
    end do
    do level = 1, klev
2050  continue
      v_ql = column_state(4, level)
      v_qi = column_state(5, level)
      v_qr = column_state(6, level)
      v_qs = column_state(7, level)
      v_qv = column_state(8, level)
      v_a = column_state(2, level)
      v_li = v_ql + v_qi
      v_tmp0 = ydecldp%rlmin
      if (v_li < v_tmp0) goto 2065
      v_tmp0 = ydecldp%ramin
      if (v_a >= v_tmp0) goto 2094
2065  continue
! Evaporate liquid before ice, preserving both temperature increments.
      v_tmp0 = column_state(18, level)
      v_tmp0 = v_tmp0 + v_ql
      column_state(18, level) = v_tmp0
      v_qadj = v_ql*v_invdt
      v_tmp0 = ptendency_loc_q(column, level)
      v_tmp0 = v_tmp0 + v_qadj
      ptendency_loc_q(column, level) = v_tmp0
      v_tmp0 = v_alv*v_qadj
      v_tmp1 = ptendency_loc_t(column, level)
      v_tmp1 = v_tmp1 - v_tmp0
      ptendency_loc_t(column, level) = v_tmp1
      v_qv = v_qv + v_ql
      v_ql = 0.0_real64
      v_tmp0 = column_state(19, level)
      v_tmp0 = v_tmp0 + v_qi
      column_state(19, level) = v_tmp0
      v_qadj = v_qi*v_invdt
      v_tmp0 = ptendency_loc_q(column, level)
      v_tmp0 = v_tmp0 + v_qadj
      ptendency_loc_q(column, level) = v_tmp0
      v_tmp0 = v_als*v_qadj
      v_tmp1 = ptendency_loc_t(column, level)
      v_tmp1 = v_tmp1 - v_tmp0
      ptendency_loc_t(column, level) = v_tmp1
      v_qv = v_qv + v_qi
      v_qi = 0.0_real64
      v_a = 0.0_real64
2094  continue
! The following four distinct phase transfers match the species order.
      v_tmp0 = ydecldp%rlmin
      if (v_ql >= v_tmp0) goto 2112
      v_tmp0 = column_state(18, level)
      v_tmp0 = v_tmp0 + v_ql
      column_state(18, level) = v_tmp0
      v_qadj = v_ql*v_invdt
      v_tmp0 = ptendency_loc_q(column, level)
      v_tmp0 = v_tmp0 + v_qadj
      ptendency_loc_q(column, level) = v_tmp0
      v_tmp0 = v_alv*v_qadj
      v_tmp1 = ptendency_loc_t(column, level)
      v_tmp1 = v_tmp1 - v_tmp0
      ptendency_loc_t(column, level) = v_tmp1
      v_qv = v_qv + v_ql
      v_ql = 0.0_real64
2112  continue
      column_state(4, level) = v_ql
      v_tmp0 = ydecldp%rlmin
      if (v_qi >= v_tmp0) goto 2130
      v_tmp0 = column_state(19, level)
      v_tmp0 = v_tmp0 + v_qi
      column_state(19, level) = v_tmp0
      v_qadj = v_qi*v_invdt
      v_tmp0 = ptendency_loc_q(column, level)
      v_tmp0 = v_tmp0 + v_qadj
      ptendency_loc_q(column, level) = v_tmp0
      v_tmp0 = v_als*v_qadj
      v_tmp1 = ptendency_loc_t(column, level)
      v_tmp1 = v_tmp1 - v_tmp0
      ptendency_loc_t(column, level) = v_tmp1
      v_qv = v_qv + v_qi
      v_qi = 0.0_real64
2130  continue
      column_state(5, level) = v_qi
      v_tmp0 = ydecldp%rlmin
      if (v_qr >= v_tmp0) goto 2148
      v_tmp0 = column_state(20, level)
      v_tmp0 = v_tmp0 + v_qr
      column_state(20, level) = v_tmp0
      v_qadj = v_qr*v_invdt
      v_tmp0 = ptendency_loc_q(column, level)
      v_tmp0 = v_tmp0 + v_qadj
      ptendency_loc_q(column, level) = v_tmp0
      v_tmp0 = v_alv*v_qadj
      v_tmp1 = ptendency_loc_t(column, level)
      v_tmp1 = v_tmp1 - v_tmp0
      ptendency_loc_t(column, level) = v_tmp1
      v_qv = v_qv + v_qr
      v_qr = 0.0_real64
2148  continue
      column_state(6, level) = v_qr
      v_tmp0 = ydecldp%rlmin
      if (v_qs >= v_tmp0) goto 2166
      v_tmp0 = column_state(21, level)
      v_tmp0 = v_tmp0 + v_qs
      column_state(21, level) = v_tmp0
      v_qadj = v_qs*v_invdt
      v_tmp0 = ptendency_loc_q(column, level)
      v_tmp0 = v_tmp0 + v_qadj
      ptendency_loc_q(column, level) = v_tmp0
      v_tmp0 = v_als*v_qadj
      v_tmp1 = ptendency_loc_t(column, level)
      v_tmp1 = v_tmp1 - v_tmp0
      ptendency_loc_t(column, level) = v_tmp1
      v_qv = v_qv + v_qs
      v_qs = 0.0_real64
2166  continue
      column_state(7, level) = v_qs
      column_state(8, level) = v_qv
      v_a = min(v_one, v_a)
      v_a = max(v_zero, v_a)
      column_state(2, level) = v_a
      v_li = v_ql + v_qi
      column_state(35, level) = v_li
      v_tmp0 = ydecldp%rlmin
      if (v_li <= v_tmp0) goto 2180
      v_lif = v_ql/v_li
      v_iif = v_one - v_lif
      goto 2183
2180  continue
      v_lif = 0.0_real64
      v_iif = 0.0_real64
2183  continue
      column_state(36, level) = v_lif
      column_state(37, level) = v_iif
    end do
    do level = ydecldp%ncldtop, klev
2195  continue
! Each column has the same ordered local calculation as the source row.
      v_t = column_state(1, level)
      v_a = column_state(2, level)
      v_aor = column_state(3, level)
      v_ql = column_state(4, level)
      v_qi = column_state(5, level)
      v_qr = column_state(6, level)
      v_qs = column_state(7, level)
      v_qv = column_state(8, level)
      v_ql0 = column_state(9, level)
      v_qi0 = column_state(10, level)
      v_qr0 = column_state(11, level)
      v_qs0 = column_state(12, level)
      v_qv0 = column_state(13, level)
      v_alfa = column_state(14, level)
      v_qsm = column_state(15, level)
      v_qsl = column_state(16, level)
      v_qsi = column_state(17, level)
      v_fom = column_state(32, level)
      v_foi = column_state(33, level)
      v_fol = column_state(34, level)
      v_li = column_state(35, level)
      v_lif = column_state(36, level)
      v_iif = column_state(37, level)
      v_fg1 = v_ql
      v_fg2 = v_qi
      v_fg3 = v_qr
      v_fg4 = v_qs
      v_fg5 = v_qv
      v_pretot = 0.0_real64
      v_lfinalsum = 0.0_real64
      v_solab = 0.0_real64
      v_solac = 0.0_real64
      v_rainaut = 0.0_real64
      v_rainacc = 0.0_real64
      v_icetot = 0.0_real64
      v_fallspd1 = 0.0_real64
      v_fallspd2 = 0.0_real64
      v_fallspd3 = 0.0_real64
      v_fallspd4 = 0.0_real64
      v_fallspd5 = 0.0_real64
      v_fallsrc1 = 0.0_real64
      v_fallsrc2 = 0.0_real64
      v_fallsrc3 = 0.0_real64
      v_fallsrc4 = 0.0_real64
      v_fallsrc5 = 0.0_real64
      v_fallsink1 = 0.0_real64
      v_fallsink2 = 0.0_real64
      v_fallsink3 = 0.0_real64
      v_fallsink4 = 0.0_real64
      v_fallsink5 = 0.0_real64
      v_convsrc1 = 0.0_real64
      v_convsrc2 = 0.0_real64
      v_convsrc3 = 0.0_real64
      v_convsrc4 = 0.0_real64
      v_convsrc5 = 0.0_real64
      v_convsink1 = 0.0_real64
      v_convsink2 = 0.0_real64
      v_convsink3 = 0.0_real64
      v_convsink4 = 0.0_real64
      v_convsink5 = 0.0_real64
      explicit_exchange = 0.0_real64
      implicit_exchange = 0.0_real64
      v_p = pap(column, level)
      v_ph = paph(column, level)
      v_phnext = paph(column, level + 1)
      v_pm1 = pap(column, level - 1)
      v_tm1 = column_state(1, level - 1)
      v_am1 = column_state(2, level - 1)
      v_dp = v_phnext - v_ph
      v_gdp = v_rg/v_dp
      v_tmp0 = v_rd*v_t
      v_rho = v_p/v_tmp0
      v_dtgdp = v_dt*v_gdp
      v_tmp0 = v_dt*v_rg
      v_tmp0 = v_one/v_tmp0
      v_rdtgdp = v_dp*v_tmp0
      v_tmp0 = v_dt*v_rg
      v_tmp1 = v_p - v_pm1
      v_dtgdpf = v_tmp0/v_tmp1
      v_tmp0 = v_t - v_r4l
      v_tmp0 = v_tmp0*v_tmp0
      v_facw = v_r5l/v_tmp0
      v_tmp0 = v_retv*v_fol
      v_tmp0 = v_one - v_tmp0
      v_cor = v_one/v_tmp0
      v_dqsl = v_facw*v_cor
      v_dqsl = v_dqsl*v_qsl
      v_tmp0 = v_alv*v_dqsl
      v_corqsl = v_one + v_tmp0
      v_tmp0 = v_t - v_r4i
      v_tmp0 = v_tmp0*v_tmp0
      v_faci = v_r5i/v_tmp0
      v_tmp0 = v_retv*v_foi
      v_tmp0 = v_one - v_tmp0
      v_cor = v_one/v_tmp0
      v_dqsi = v_faci*v_cor
      v_dqsi = v_dqsi*v_qsi
      v_tmp0 = v_als*v_dqsi
      v_corqsi = v_one + v_tmp0
      v_tmp0 = v_alfa*v_facw
      v_tmp1 = v_one - v_alfa
      v_tmp1 = v_tmp1*v_faci
      v_tmp2 = v_tmp0 + v_tmp1
      v_tmp0 = v_retv*v_fom
      v_tmp0 = v_one - v_tmp0
      v_cor = v_one/v_tmp0
      v_dqsm = v_tmp2*v_cor
      v_dqsm = v_dqsm*v_qsm
      v_tmp0 = v_alfa*v_alv
      v_tmp1 = v_one - v_alfa
      v_tmp1 = v_tmp1*v_als
      v_tmp0 = v_tmp0 + v_tmp1
      v_tmp0 = v_tmp0*v_dqsm
      v_corqsm = v_one + v_tmp0
      v_tmp0 = v_qsm - v_qv
      v_tmp0 = v_tmp0/v_corqsm
      v_evapm = max(v_tmp0, v_zero)
      v_tmp0 = v_qsl - v_qv
      v_tmp0 = v_tmp0/v_corqsl
      v_evapl = max(v_tmp0, v_zero)
      v_tmp0 = v_qsi - v_qv
      v_tmp0 = v_tmp0/v_corqsi
      v_evapi = max(v_tmp0, v_zero)
      v_tmp0 = lc001
      v_tmp0 = max(v_a, v_tmp0)
      v_tmp0 = v_one/v_tmp0
      v_liqcld = v_ql*v_tmp0
      v_icecld = v_qi*v_tmp0
      v_licld = v_liqcld + v_icecld
      v_tmp0 = ydecldp%rlmin
      if (v_ql >= v_tmp0) goto 2336
      explicit_exchange(5, 1) = v_ql
      explicit_exchange(1, 5) = -v_ql
2336  continue
      if (v_qi >= v_tmp0) goto 2341
      explicit_exchange(5, 2) = v_qi
      explicit_exchange(2, 5) = -v_qi
2341  continue
! Source 3.2. Convective detrainment is admitted before downward transport.
      selection = level
      if (selection >= klev) goto 2378
      v_tmp0 = plude(column, level)
      v_tmp0 = v_tmp0*v_dtgdp
      plude(column, level) = v_tmp0
      selection = merge(1_int32, 0_int32, ldcum(column))
      if (selection == 0) goto 2365
      if (v_tmp0 <= v_small) goto 2365
      v_tmp1 = plu(column, level + 1)
      if (v_tmp1 <= v_small) goto 2365
      v_tmp0 = v_tmp0/v_tmp1
      v_solac = v_solac + v_tmp0
      v_tmp0 = pludeli(column, level, 1)
      v_convsrc1 = v_tmp0*v_dtgdp
      v_tmp0 = pludeli(column, level, 2)
      v_convsrc2 = v_tmp0*v_dtgdp
      explicit_exchange(1, 1) = explicit_exchange(1, 1) + v_convsrc1
      explicit_exchange(2, 2) = explicit_exchange(2, 2) + v_convsrc2
      goto 2368
2365  continue
      v_tmp0 = 0.0_real64
      plude(column, level) = v_tmp0
2368  continue
      selection = merge(1_int32, 0_int32, ydecumf%lmfdsnow)
      if (selection == 0) goto 2378
      v_tmp0 = psnde(column, level, 1)
      v_convsrc3 = v_tmp0*v_dtgdp
      v_tmp0 = psnde(column, level, 2)
      v_convsrc4 = v_tmp0*v_dtgdp
      explicit_exchange(3, 3) = explicit_exchange(3, 3) + v_convsrc3
      explicit_exchange(4, 4) = explicit_exchange(4, 4) + v_convsrc4
2378  continue
! Source 3.3. Downward cloud imports use the previously solved upper layer.
      selection = level
      comparison_index = ydecldp%ncldtop
      if (selection <= comparison_index) goto 2435
      v_tmp0 = pmfu(column, level)
      v_tmp0 = v_tmp0*v_advw
      v_tmp1 = pmfd(column, level)
      v_tmp1 = v_tmp1*v_advwd
      v_mf = v_tmp0 + v_tmp1
      v_mf = v_mf*v_dtgdp
      v_mf = max(v_zero, v_mf)
      v_acust = v_mf*v_anewm1
      v_lcustl = v_mf*v_transport1
      v_lcusti = v_mf*v_transport2
      v_convsrc1 = v_convsrc1 + v_lcustl
      v_convsrc2 = v_convsrc2 + v_lcusti
      v_dtdp = v_rdcp*v_half
      v_tmp0 = v_tm1 + v_t
      v_dtdp = v_dtdp*v_tmp0
      v_dtdp = v_dtdp/v_ph
      v_tmp0 = pmfu(column, level)
      v_tmp0 = v_tmp0*v_advw
      v_tmp1 = pmfd(column, level)
      v_tmp1 = v_tmp1*v_advwd
      v_tmp0 = v_tmp0 + v_tmp1
      v_tmp0 = v_rg*v_tmp0
      v_tmp1 = v_p - v_pm1
      v_tmp1 = v_tmp1/v_dt
      v_wtot = min(v_tmp0, v_tmp1)
      v_dtforc = v_dtdp*v_dt
      v_dtforc = v_dtforc*v_wtot
      v_dqs = v_anewm1*v_dtforc
      v_dqs = v_dqs*v_dqsm
      v_lfinal = v_lcustl - v_dqs
      v_lfinal = max(v_zero, v_lfinal)
      v_evap = v_lcustl - v_lfinal
      v_evap = min(v_evap, v_evapm)
      v_lfinal = v_lcustl - v_evap
      v_lfinalsum = v_lfinalsum + v_lfinal
      explicit_exchange(1, 1) = explicit_exchange(1, 1) + v_lcustl
      explicit_exchange(5, 1) = explicit_exchange(5, 1) + v_evap
      explicit_exchange(1, 5) = explicit_exchange(1, 5) - v_evap
      v_lfinal = v_lcusti - v_dqs
      v_lfinal = max(v_zero, v_lfinal)
      v_evap = v_lcusti - v_lfinal
      v_evap = min(v_evap, v_evapm)
      v_lfinal = v_lcusti - v_evap
      v_lfinalsum = v_lfinalsum + v_lfinal
      explicit_exchange(2, 2) = explicit_exchange(2, 2) + v_lcusti
      explicit_exchange(5, 2) = explicit_exchange(5, 2) + v_evap
      explicit_exchange(2, 5) = explicit_exchange(2, 5) - v_evap
      v_solac = v_solac + v_acust
      if (v_lfinalsum >= v_small) goto 2435
      v_solac = v_solac - v_acust
2435  continue
      selection = level
      if (selection >= klev) goto 2451
      v_tmp0 = pmfu(column, level + 1)
      v_tmp0 = v_tmp0*v_advw
      v_tmp1 = pmfd(column, level + 1)
      v_tmp1 = v_tmp1*v_advwd
      v_mfdn = v_tmp0 + v_tmp1
      v_mfdn = v_mfdn*v_dtgdp
      v_mfdn = max(v_zero, v_mfdn)
      v_solab = v_solab + v_mfdn
      implicit_exchange(1, 1) = implicit_exchange(1, 1) + v_mfdn
      implicit_exchange(2, 2) = implicit_exchange(2, 2) + v_mfdn
      v_convsink1 = v_mfdn
      v_convsink2 = v_mfdn
2451  continue
! Source 3.4. Mixed-phase cloud-edge erosion.
      v_ldifdt = ydecldp%rcldiff
      v_ldifdt = v_ldifdt*v_dt
      convection_type = ktype(column)
      v_tmp0 = plude(column, level)
      if (v_tmp0 <= v_small) goto 2477
      if (convection_type < 2) goto 2470
      v_tmp1 = peis(column)
      v_tmp2 = lcten
      if (v_tmp1 >= v_tmp2) goto 2477
      v_tmp0 = lctwenty
      v_tmp1 = ydecldp%rcldiff_convi
      v_tmp0 = v_tmp0*v_tmp1
      v_ldifdt = v_tmp0*v_ldifdt
      goto 2477
2470  continue
      if (convection_type /= 1) goto 2477
      v_tmp0 = lctwo
      v_tmp1 = ydecldp%rcldiff_convi
      v_tmp0 = v_tmp0*v_tmp1
      v_ldifdt = v_tmp0*v_ldifdt
2477  continue
      if (v_li <= v_small) goto 2504
      v_tmp0 = v_a*v_qsm
      v_tmp0 = v_qv - v_tmp0
      v_tmp1 = v_one - v_a
      v_tmp1 = max(v_small, v_tmp1)
      v_qe = v_tmp0/v_tmp1
      v_e = v_qsm - v_qe
      v_e = max(v_e, v_zero)
      v_tmp0 = lc0333
      v_leros = v_tmp0*v_a
      v_tmp0 = v_one - v_a
      v_leros = v_leros*v_tmp0
      v_leros = v_leros*v_ldifdt
      v_leros = v_leros*v_e
      v_leros = min(v_leros, v_evapm)
      v_leros = min(v_leros, v_li)
      v_aeros = v_half*v_leros
      v_aeros = v_aeros/v_licld
      v_solac = v_solac - v_aeros
      v_tmp0 = v_lif*v_leros
      explicit_exchange(5, 1) = explicit_exchange(5, 1) + v_tmp0
      explicit_exchange(1, 5) = explicit_exchange(1, 5) - v_tmp0
      v_tmp0 = v_iif*v_leros
      explicit_exchange(5, 2) = explicit_exchange(5, 2) + v_tmp0
      explicit_exchange(2, 5) = explicit_exchange(2, 5) - v_tmp0
2504  continue
! Source 4.1. Falling particles use the frozen variable-speed rain route.
      v_fallspd1 = 0.0_real64
      v_fallspd2 = ydecldp%rvice
      v_fallspd4 = ydecldp%rvsnow
      v_tmp0 = ydecldp%rdensref
      v_tmp0 = v_tmp0/v_rho
      v_tmp1 = lc04
      v_fallcorr = selected_pow(v_tmp0, v_tmp1)
      v_temp = v_qr + v_prev3
      v_temp = v_half*v_temp
      v_tmp0 = v_rho*v_temp
      v_tmp1 = ydecldp%rcl_lam1r
      v_tmp0 = v_tmp0/v_tmp1
      v_tmp1 = ydecldp%rcl_lam2r
      v_rlambda = selected_pow(v_tmp0, v_tmp1)
      v_tmp0 = ydecldp%rcl_const7r
      v_fallspd3 = v_fallcorr*v_tmp0
      v_tmp1 = ydecldp%rcl_dr
      v_tmp0 = selected_pow(v_rlambda, v_tmp1)
      v_fallspd3 = v_fallspd3*v_tmp0
      v_tmp0 = ydecldp%rvice
      if (v_tmp0 <= v_zero) goto 2540
      selection = level
      comparison_index = ydecldp%ncldtop
      if (selection <= comparison_index) goto 2537
      v_tmp0 = column_state(28, level)
      v_fallsrc2 = v_tmp0*v_dtgdp
      explicit_exchange(2, 2) = explicit_exchange(2, 2) + v_fallsrc2
      v_fg2 = v_fg2 + v_fallsrc2
      v_pretot = v_pretot + v_fg2
2537  continue
      v_fallsink2 = v_dtgdp*v_rho
      v_fallsink2 = v_fallsink2*v_fallspd2
2540  continue
      v_tmp0 = ydecldp%rvrain
      if (v_tmp0 <= v_zero) goto 2556
      selection = level
      comparison_index = ydecldp%ncldtop
      if (selection <= comparison_index) goto 2553
      v_tmp0 = column_state(29, level)
      v_fallsrc3 = v_tmp0*v_dtgdp
      explicit_exchange(3, 3) = explicit_exchange(3, 3) + v_fallsrc3
      v_fg3 = v_fg3 + v_fallsrc3
      v_pretot = v_pretot + v_fg3
2553  continue
      v_fallsink3 = v_dtgdp*v_rho
      v_fallsink3 = v_fallsink3*v_fallspd3
2556  continue
      v_tmp0 = ydecldp%rvsnow
      if (v_tmp0 <= v_zero) goto 2572
      selection = level
      comparison_index = ydecldp%ncldtop
      if (selection <= comparison_index) goto 2569
      v_tmp0 = column_state(30, level)
      v_fallsrc4 = v_tmp0*v_dtgdp
      explicit_exchange(4, 4) = explicit_exchange(4, 4) + v_fallsrc4
      v_fg4 = v_fg4 + v_fallsrc4
      v_pretot = v_pretot + v_fg4
2569  continue
      v_fallsink4 = v_dtgdp*v_rho
      v_fallsink4 = v_fallsink4*v_fallspd4
2572  continue
! Source 4.2. Precipitation coverage retains vertical maximum-random overlap.
      if (v_pretot <= v_small) goto 2605
      v_tmp0 = v_one - v_covptot
      v_tmp1 = max(v_a, v_am1)
      v_tmp1 = v_one - v_tmp1
      v_tmp0 = v_tmp0*v_tmp1
      v_tmp1 = lcone_less_micro
      v_tmp1 = min(v_am1, v_tmp1)
      v_tmp1 = v_one - v_tmp1
      v_tmp0 = v_tmp0/v_tmp1
      v_covptot = v_one - v_tmp0
      v_tmp0 = ydecldp%rcovpmin
      v_covptot = max(v_covptot, v_tmp0)
      v_tmp0 = v_covptot - v_a
      v_covpclr = max(v_zero, v_tmp0)
      v_tmp0 = column_state(6, level - 1)
      v_raincld = v_qr + v_tmp0
      v_raincld = v_half*v_raincld
      v_raincld = v_raincld/v_covptot
      v_raincldm1 = v_qr + v_prev3
      v_raincldm1 = v_half*v_raincldm1
      v_raincldm1 = v_raincldm1/v_covptot
      v_tmp0 = column_state(7, level - 1)
      v_snowcld = v_qs + v_tmp0
      v_snowcld = v_half*v_snowcld
      v_snowcld = v_snowcld/v_covptot
      v_snowcldm1 = v_qs + v_prev4
      v_snowcldm1 = v_half*v_snowcldm1
      v_snowcldm1 = v_snowcldm1/v_covptot
      v_covpmax = max(v_covptot, v_covpmax)
      goto 2613
2605  continue
      v_raincld = 0.0_real64
      v_raincldm1 = 0.0_real64
      v_snowcld = 0.0_real64
      v_snowcldm1 = 0.0_real64
      v_covptot = 0.0_real64
      v_covpclr = 0.0_real64
      v_covpmax = 0.0_real64
2613  continue
! Source 4.3. Implicit warm rain, with unchanged constant cloud variability factors.
      if (v_liqcld <= v_small) goto 2654
      v_tmp0 = plsm(column)
      if (v_tmp0 <= v_half) goto 2623
      v_temp = ydecldp%rcl_kk_cloud_num_land
      v_lcrit = ydecldp%rclcrit_land
      goto 2626
2623  continue
      v_temp = ydecldp%rcl_kk_cloud_num_sea
      v_lcrit = ydecldp%rclcrit_sea
2626  continue
      v_factor = ydecldp%rcl_inhomogaut
      v_rainaut = v_factor*v_dt
      v_tmp0 = ydecldp%rcl_kkaau
      v_rainaut = v_rainaut*v_tmp0
      v_tmp1 = ydecldp%rcl_kkbauq
      v_tmp1 = v_tmp1 - v_one
      v_tmp0 = selected_pow(v_liqcld, v_tmp1)
      v_rainaut = v_rainaut*v_tmp0
      v_tmp1 = ydecldp%rcl_kkbaun
      v_tmp0 = selected_pow(v_temp, v_tmp1)
      v_rainaut = v_rainaut*v_tmp0
      implicit_exchange(3, 1) = implicit_exchange(3, 1) + v_rainaut
      if (v_raincld <= v_small) goto 2652
      v_factor = ydecldp%rcl_inhomogacc
      v_rainacc = v_factor*v_dt
      v_tmp0 = ydecldp%rcl_kkaac
      v_rainacc = v_rainacc*v_tmp0
      v_tmp1 = ydecldp%rcl_kkbac
      v_tmp1 = v_tmp1 - v_one
      v_tmp0 = selected_pow(v_liqcld, v_tmp1)
      v_rainacc = v_rainacc*v_tmp0
      v_tmp1 = ydecldp%rcl_kkbac
      v_tmp0 = selected_pow(v_raincld, v_tmp1)
      v_rainacc = v_rainacc*v_tmp0
2652  continue
      implicit_exchange(3, 1) = implicit_exchange(3, 1) + v_rainacc
2654  continue
! Source 4.4. Rain evaporates only in the qualifying clear part of a cell.
      v_rhlimit = ydecldp%rprecrhmax
      v_tmp0 = v_one - v_rhlimit
      v_tmp0 = v_tmp0*v_covpmax
      v_tmp1 = v_one - v_a
      v_tmp1 = max(v_small, v_tmp1)
      v_tmp0 = v_tmp0/v_tmp1
      v_rhlimit = v_rhlimit + v_tmp0
      v_tmp0 = ydecldp%rprecrhmax
      v_rhlimit = max(v_rhlimit, v_tmp0)
      v_rhlimit = min(v_rhlimit, v_one)
      v_rh0 = ydecldp%ramid
      v_tmp0 = paph(column, klev + 1)
      v_tmp0 = v_p/v_tmp0
      v_tmp1 = lc08
      if (v_tmp0 <= v_tmp1) goto 2682
      v_tmp0 = v_tmp0 - v_tmp1
      v_tmp1 = lc02
      v_tmp0 = v_tmp0/v_tmp1
      v_tmp0 = v_tmp0*v_tmp0
      v_tmp1 = v_one - v_rh0
      v_tmp0 = v_tmp1*v_tmp0
      v_rh0 = v_rh0 + v_tmp0
2682  continue
      v_rhlimit = min(v_rh0, v_rhlimit)
      v_tmp0 = lc09
      v_rhlimit = min(v_tmp0, v_rhlimit)
      v_qe = min(v_qv, v_qsl)
      v_qe = max(v_zero, v_qe)
      if (v_covpclr <= v_small) goto 2777
      if (v_raincldm1 <= v_small) goto 2777
      v_tmp0 = v_rhlimit*v_qsl
      if (v_qe >= v_tmp0) goto 2777
! A bare 0.4 source literal rounds in single precision before widening.
      v_tmp0 = ydecldp%rdensref
      v_tmp0 = v_tmp0/v_rho
      v_tmp1 = lc04single
      v_fallcorr = selected_pow(v_tmp0, v_tmp1)
      v_tmp0 = v_t - v_rtt
      v_tmp0 = v_r3l*v_tmp0
      v_tmp1 = v_t - v_r4l
      v_tmp0 = v_tmp0/v_tmp1
      v_tmp0 = selected_exp(v_tmp0)
      v_tmp0 = v_r2es*v_tmp0
      v_vpd = v_rv/v_rd
      v_vpd = v_vpd*v_tmp0
      v_tmp0 = v_rho*v_raincldm1
      v_tmp1 = ydecldp%rcl_lam1r
      v_tmp0 = v_tmp1/v_tmp0
      v_tmp1 = ydecldp%rcl_lam2r
      v_lambda = selected_pow(v_tmp0, v_tmp1)
      v_tmp0 = ydecldp%rcl_cdenom1
      v_denom = v_tmp0*v_vpd
      v_tmp0 = ydecldp%rcl_cdenom2
      v_tmp0 = v_tmp0*v_t
      v_tmp0 = v_tmp0*v_vpd
      v_denom = v_denom - v_tmp0
      v_tmp0 = ydecldp%rcl_cdenom3
      v_tmp1 = lcthree
      v_tmp1 = selected_pow(v_t, v_tmp1)
      v_tmp0 = v_tmp0*v_tmp1
      v_tmp0 = v_tmp0*v_p
      v_denom = v_denom + v_tmp0
      v_tmp0 = lc273
      v_tmp0 = v_t/v_tmp0
      v_tmp1 = lc15
      v_corr = selected_pow(v_tmp0, v_tmp1)
      v_tmp0 = lc393
      v_corr = v_corr*v_tmp0
      v_tmp0 = lc120
      v_tmp0 = v_t + v_tmp0
      v_corr = v_corr/v_tmp0
! The source's conductivity local is retained even though this route uses CORR directly.
      v_tmp0 = ydecldp%rcl_ka273
      v_tmp0 = v_tmp0*v_corr
      v_tmp0 = v_rhlimit*v_qsl
      v_tmp0 = v_tmp0 - v_qe
      v_waterloss = max(v_tmp0, v_zero)
      v_tmp0 = lc015
      v_beta = v_tmp0/v_qsl
      v_tmp0 = v_t*v_t
      v_beta = v_beta*v_tmp0
      v_beta = v_beta*v_vpd
      v_tmp0 = ydecldp%rcl_const1r
      v_beta = v_beta*v_tmp0
      v_tmp0 = v_corr/v_denom
      v_beta = v_beta*v_tmp0
      v_tmp1 = ydecldp%rcl_const4r
      v_tmp0 = selected_pow(v_lambda, v_tmp1)
      v_tmp1 = lc078
      v_tmp4 = v_tmp1/v_tmp0
      v_tmp0 = v_rho*v_fallcorr
      v_tmp1 = lchalf
      v_tmp0 = selected_pow(v_tmp0, v_tmp1)
      v_tmp1 = ydecldp%rcl_const2r
      v_tmp5 = v_tmp1*v_tmp0
      v_tmp1 = lchalf
      v_tmp6 = selected_pow(v_corr, v_tmp1)
      v_tmp1 = ydecldp%rcl_const3r
      v_tmp0 = selected_pow(v_lambda, v_tmp1)
      v_tmp6 = v_tmp6*v_tmp0
      v_tmp5 = v_tmp5/v_tmp6
      v_tmp4 = v_tmp4 + v_tmp5
      v_beta = v_beta*v_tmp4
      v_tmp0 = v_beta*v_dt
      v_tmp0 = v_tmp0*v_corqsl
      v_denom = v_one + v_tmp0
      v_rainevap = v_covpclr*v_beta
      v_rainevap = v_rainevap*v_dt
      v_rainevap = v_rainevap*v_waterloss
      v_rainevap = v_rainevap/v_denom
      v_evap = min(v_rainevap, v_fg3)
      explicit_exchange(5, 3) = explicit_exchange(5, 3) + v_evap
      explicit_exchange(3, 5) = explicit_exchange(3, 5) - v_evap
      v_fg3 = v_fg3 - v_evap
2777  continue
! Source 4.5. Liquid supplies the Rotstayn depositional ice growth.
      v_tmp0 = ydecldp%rcldtopcf
      if (v_am1 >= v_tmp0) goto 2786
      if (v_a < v_tmp0) goto 2786
      v_cldtopdist = 0.0_real64
      goto 2790
2786  continue
      v_tmp0 = v_rho*v_rg
      v_tmp0 = v_dp/v_tmp0
      v_cldtopdist = v_cldtopdist + v_tmp0
2790  continue
      v_factor = v_qsl - v_qsi
      v_factor = v_factor/v_qsi
      v_tmp0 = lcfive
      v_tmp0 = v_rtt - v_tmp0
      if (v_t >= v_tmp0) goto 2870
      v_tmp0 = ydecldp%rlmin
      if (v_fg1 <= v_tmp0) goto 2870
      v_tmp0 = v_t - v_rtt
      v_tmp0 = v_r3i*v_tmp0
      v_tmp1 = v_t - v_r4i
      v_tmp0 = v_tmp0/v_tmp1
      v_vpd = selected_exp(v_tmp0)
      v_vpd = v_r2es*v_vpd
      v_vpd = v_vpd*v_rv
      v_vpd = v_vpd/v_rd
      v_tmp0 = lc1296
      v_tmp0 = v_tmp0*v_factor
      v_tmp1 = lc0639
      v_tmp0 = v_tmp0 - v_tmp1
      v_iceinit = selected_exp(v_tmp0)
      v_tmp0 = lcthousand
      v_iceinit = v_tmp0*v_iceinit
      v_tmp0 = v_rv*v_t
      v_tmp0 = v_ls/v_tmp0
      v_tmp0 = v_tmp0 - v_one
      v_tmp4 = v_ls*v_tmp0
      v_tmp0 = lc0024
      v_tmp0 = v_tmp0*v_t
      v_tmp4 = v_tmp4/v_tmp0
      v_tmp5 = v_rv*v_t
      v_tmp5 = v_tmp5*v_p
      v_tmp0 = lc221
      v_tmp0 = v_tmp0*v_vpd
      v_tmp5 = v_tmp5/v_tmp0
      v_tmp0 = v_iceinit/v_rho
      v_tmp1 = lc0666
      v_cvds = selected_pow(v_tmp0, v_tmp1)
      v_tmp0 = lc78
      v_cvds = v_tmp0*v_cvds
      v_cvds = v_cvds*v_factor
      v_tmp0 = v_tmp4 + v_tmp5
      v_tmp1 = lc887
      v_tmp0 = v_tmp1*v_tmp0
      v_cvds = v_cvds/v_tmp0
      v_tmp0 = ydecldp%riceinit
      v_tmp0 = v_iceinit*v_tmp0
      v_tmp0 = v_tmp0/v_rho
      v_ice0 = max(v_icecld, v_tmp0)
      v_tmp0 = lc0666
      v_iceafter = v_tmp0*v_cvds
      v_iceafter = v_iceafter*v_dt
      v_tmp0 = selected_pow(v_ice0, v_tmp0)
      v_iceafter = v_iceafter + v_tmp0
      v_tmp1 = lc15
      v_iceafter = selected_pow(v_iceafter, v_tmp1)
      v_icedep = ydecldp%rcl_overlapliqice
      v_icedep = v_icedep*v_a
      v_tmp0 = v_iceafter - v_ice0
      v_icedep = v_icedep*v_tmp0
      v_icedep = max(v_icedep, v_zero)
      v_icedep = min(v_icedep, v_fg1)
      v_tmp0 = lc15000
      v_factor = v_iceinit/v_tmp0
      v_factor = min(v_factor, v_one)
      v_tmp0 = ydecldp%rdepliqrefdepth
      v_tmp0 = v_cldtopdist/v_tmp0
      v_tmp1 = ydecldp%rdepliqrefrate
      v_tmp0 = v_tmp1 + v_tmp0
      v_tmp1 = v_one - v_factor
      v_tmp0 = v_tmp1*v_tmp0
      v_tmp0 = v_factor + v_tmp0
      v_tmp0 = min(v_tmp0, v_one)
      v_icedep = v_icedep*v_tmp0
      explicit_exchange(2, 1) = explicit_exchange(2, 1) + v_icedep
      explicit_exchange(1, 2) = explicit_exchange(1, 2) - v_icedep
      v_fg2 = v_fg2 + v_icedep
      v_fg1 = v_fg1 - v_icedep
2870  continue
! Source 4.7. Snow gains water from the excess over mixed-phase saturation.
      v_factor = v_qv - v_qsm
      v_factor = v_factor/v_qsm
      v_factor = max(v_factor, v_zero)
      if (v_t >= v_rtt) goto 2958
      if (v_snowcld <= v_small) goto 2958
      if (v_factor <= v_zero) goto 2958
      v_tmp0 = v_t - v_rtt
      v_tmp0 = v_r3i*v_tmp0
      v_tmp1 = v_t - v_r4i
      v_tmp0 = v_tmp0/v_tmp1
      v_vpd = selected_exp(v_tmp0)
      v_vpd = v_r2es*v_vpd
      v_vpd = v_vpd*v_rv
      v_vpd = v_vpd/v_rd
      v_tmp0 = ydecldp%rcl_apb1
      v_denom = v_tmp0*v_vpd
      v_tmp0 = ydecldp%rcl_apb2
      v_tmp0 = v_tmp0*v_vpd
      v_tmp0 = v_tmp0*v_t
      v_denom = v_denom - v_tmp0
      v_tmp0 = ydecldp%rcl_apb3
      v_tmp0 = v_p*v_tmp0
      v_tmp1 = v_t*v_t
      v_tmp1 = v_tmp1*v_t
      v_tmp0 = v_tmp0*v_tmp1
      v_denom = v_denom + v_tmp0
      v_tmp0 = v_one/v_rho
      v_tmp1 = lchalf
      v_fallcorr = selected_pow(v_tmp0, v_tmp1)
      v_tmp0 = lc273
      v_tmp0 = v_t/v_tmp0
      v_tmp1 = lc15
      v_corr = selected_pow(v_tmp0, v_tmp1)
      v_tmp0 = lc120
      v_tmp0 = v_t + v_tmp0
      v_tmp1 = lc393
      v_tmp0 = v_tmp1/v_tmp0
      v_corr = v_corr*v_tmp0
      v_temp = v_rho*v_snowcld
      v_tmp0 = ydecldp%rcl_const1s
      v_temp = v_temp*v_tmp0
! ZTCG and ZFACX1S are both exactly one in this selected source route.
      v_tmp0 = v_one*v_one
      v_temp = v_temp/v_tmp0
      v_deprate = v_t*v_t
      v_deprate = v_factor*v_deprate
      v_deprate = v_deprate*v_vpd
      v_deprate = v_deprate*v_corr
      v_deprate = v_deprate*v_one
      v_tmp0 = ydecldp%rcl_const2s
      v_deprate = v_deprate*v_tmp0
      v_deprate = v_deprate*v_one
      v_tmp0 = v_rho*v_denom
      v_deprate = v_deprate/v_tmp0
      v_tmp0 = lc065
      v_tmp1 = ydecldp%rcl_const6s
      v_grow = v_tmp0*v_tmp1
      v_tmp1 = ydecldp%rcl_const4s
      v_tmp0 = selected_pow(v_temp, v_tmp1)
      v_grow = v_grow*v_tmp0
      v_tmp0 = ydecldp%rcl_const3s
      v_tmp1 = lchalf
      v_tmp1 = selected_pow(v_fallcorr, v_tmp1)
      v_rate = v_tmp0*v_tmp1
      v_tmp1 = lchalf
      v_tmp0 = selected_pow(v_rho, v_tmp1)
      v_rate = v_rate*v_tmp0
      v_tmp1 = ydecldp%rcl_const5s
      v_tmp0 = selected_pow(v_temp, v_tmp1)
      v_rate = v_rate*v_tmp0
      v_tmp1 = lchalf
      v_tmp0 = selected_pow(v_corr, v_tmp1)
      v_rate = v_rate/v_tmp0
      v_grow = v_grow + v_rate
      v_deprate = v_covptot*v_deprate
      v_deprate = v_deprate*v_grow
      v_deprate = v_deprate*v_dt
      v_deprate = max(v_deprate, v_zero)
      v_tmp0 = v_qv - v_qsm
      v_deprate = min(v_deprate, v_tmp0)
      v_deprate = v_deprate/v_corqsm
      explicit_exchange(4, 5) = explicit_exchange(4, 5) + v_deprate
      explicit_exchange(5, 4) = explicit_exchange(5, 4) - v_deprate
2958  continue
! The revised in-cloud amounts use the process first guess, not the initial state.
      v_tmp0 = lc001
      v_tmp0 = max(v_a, v_tmp0)
      v_tmp0 = v_one/v_tmp0
      v_liqcld = v_fg1*v_tmp0
      v_icecld = v_fg2*v_tmp0
! Source 4.8. Cloud ice converts implicitly to snow.
      if (v_t > v_rtt) goto 2992
      if (v_icecld <= v_small) goto 2992
      v_tmp0 = ydecldp%rsnowlin1
      v_factor = v_dt*v_tmp0
      v_tmp0 = v_t - v_rtt
      v_tmp1 = ydecldp%rsnowlin2
      v_tmp0 = v_tmp1*v_tmp0
      v_tmp0 = selected_exp(v_tmp0)
      v_factor = v_factor*v_tmp0
      v_tmp0 = ydecldp%rlcritsnow
      v_temp = v_icecld/v_tmp0
      v_temp = v_temp*v_temp
      v_temp = -v_temp
      v_tmp0 = lcfifty
      if (v_temp >= v_tmp0) goto 2988
      v_tmp0 = selected_exp(v_temp)
      v_tmp0 = v_one - v_tmp0
      v_temp = v_factor*v_tmp0
      goto 2990
2988  continue
      v_temp = v_factor
2990  continue
      implicit_exchange(4, 2) = implicit_exchange(4, 2) + v_temp
2992  continue
! Source 4.12. Melt ice and snow into rain at the wet-bulb melting limit.
      v_icetot = v_fg2 + v_fg4
      v_maxmelt = 0.0_real64
      if (v_icetot <= v_small) goto 3025
      if (v_t <= v_rtt) goto 3025
      v_waterloss = v_qsi - v_qv
      v_waterloss = max(v_waterloss, v_zero)
      v_tmp0 = lctw3
      v_tmp0 = v_p - v_tmp0
      v_tmp1 = lctw2
      v_tmp0 = v_tmp1*v_tmp0
      v_tmp1 = lctw1
      v_tmp0 = v_tmp1 + v_tmp0
      v_tmp1 = lctw5
      v_tmp1 = v_t - v_tmp1
      v_tmp2 = lctw4
      v_tmp1 = v_tmp2*v_tmp1
      v_tmp0 = v_tmp0 - v_tmp1
      v_tmp0 = v_waterloss*v_tmp0
      v_wetbulb = v_t - v_rtt
      v_wetbulb = v_wetbulb - v_tmp0
      v_factor = v_half*v_wetbulb
      v_factor = v_one + v_factor
      v_factor = v_dt*v_factor
      v_tmp0 = ydecldp%rtaumel
      v_factor = v_factor/v_tmp0
      v_factor = abs(v_factor)
      v_maxmelt = v_wetbulb*v_factor
      v_maxmelt = v_maxmelt*v_rldcp
      v_maxmelt = max(v_maxmelt, v_zero)
3025  continue
      if (v_maxmelt <= v_small) goto 3044
      if (v_icetot <= v_small) goto 3044
      v_factor = v_fg2/v_icetot
      v_melt = v_factor*v_maxmelt
      v_melt = min(v_fg2, v_melt)
      v_fg2 = v_fg2 - v_melt
      v_fg3 = v_fg3 + v_melt
      explicit_exchange(3, 2) = explicit_exchange(3, 2) + v_melt
      explicit_exchange(2, 3) = explicit_exchange(2, 3) - v_melt
      v_factor = v_fg4/v_icetot
      v_melt = v_factor*v_maxmelt
      v_melt = min(v_fg4, v_melt)
      v_fg4 = v_fg4 - v_melt
      v_fg3 = v_fg3 + v_melt
      explicit_exchange(3, 4) = explicit_exchange(3, 4) + v_melt
      explicit_exchange(4, 3) = explicit_exchange(4, 3) - v_melt
3044  continue
! Source 4.13. Diagnose rain fraction and retain the source single-precision threshold.
      if (v_qr <= v_small) goto 3108
      if (v_t > v_rtt) goto 3065
      if (v_tm1 <= v_rtt) goto 3065
      v_pretot = v_qs + v_qr
      v_pretot = max(v_pretot, v_small)
      v_tmp0 = v_qr/v_pretot
      prainfrac_toprfz(column) = v_tmp0
      v_tmp1 = lc08single
      if (v_tmp0 <= v_tmp1) goto 3063
      v_llrain = v_one
      goto 3065
3063  continue
      v_llrain = 0.0_real64
3065  continue
      if (v_t >= v_rtt) goto 3108
      if (v_llrain == v_zero) goto 3091
      v_tmp0 = v_rho*v_qr
      v_tmp1 = ydecldp%rcl_lam1r
      v_tmp0 = v_tmp1/v_tmp0
      v_tmp1 = ydecldp%rcl_lam2r
      v_lambda = selected_pow(v_tmp0, v_tmp1)
      v_tmp0 = v_t - v_rtt
      v_tmp1 = ydecldp%rcl_fzrab
      v_temp = v_tmp1*v_tmp0
      v_tmp0 = lcfifty
      v_temp = min(v_temp, v_tmp0)
      v_tmp0 = ydecldp%rcl_const5r
      v_tmp0 = v_tmp0/v_rho
      v_freeze = v_dt*v_tmp0
      v_tmp0 = selected_exp(v_temp)
      v_tmp0 = v_tmp0 - v_one
      v_freeze = v_freeze*v_tmp0
      v_tmp1 = ydecldp%rcl_const6r
      v_tmp0 = selected_pow(v_lambda, v_tmp1)
      v_freeze = v_freeze*v_tmp0
      v_freeze = max(v_freeze, v_zero)
      goto 3102
3091  continue
      v_tmp0 = v_rtt - v_t
      v_factor = v_half*v_tmp0
      v_factor = v_one + v_factor
      v_factor = v_dt*v_factor
      v_tmp1 = ydecldp%rtaumel
      v_factor = v_factor/v_tmp1
      v_factor = abs(v_factor)
      v_freeze = v_tmp0*v_factor
      v_freeze = v_freeze*v_rldcp
      v_freeze = max(v_freeze, v_zero)
3102  continue
      if (v_freeze <= v_small) goto 3108
      v_freeze = min(v_qr, v_freeze)
      explicit_exchange(4, 3) = explicit_exchange(4, 3) + v_freeze
      explicit_exchange(3, 4) = explicit_exchange(3, 4) - v_freeze
3108  continue
! Source 4.14. Liquid freezes below the homogeneous freezing temperature.
      v_tmp0 = ydecldp%rthomo
      v_tmp0 = v_tmp0 - v_t
      v_freeze = v_tmp0*v_rldcp
      v_freeze = max(v_freeze, v_zero)
      if (v_freeze <= v_small) goto 3121
      if (v_fg1 <= v_small) goto 3121
      v_freeze = min(v_fg1, v_freeze)
      explicit_exchange(2, 1) = explicit_exchange(2, 1) + v_freeze
      explicit_exchange(1, 2) = explicit_exchange(1, 2) - v_freeze
3121  continue
! Source 4.9. Snow collects supercooled liquid, implicitly in its liquid amount.
      if (v_t > v_rtt) goto 3150
      if (v_liqcld <= v_small) goto 3150
      v_tmp0 = ydecldp%rdensref
      v_tmp0 = v_tmp0/v_rho
      v_tmp1 = lc04single
      v_fallcorr = selected_pow(v_tmp0, v_tmp1)
      if (v_snowcld <= v_small) goto 3150
      v_tmp0 = lc001
      if (v_covptot <= v_tmp0) goto 3150
      v_rimeliq = ydecldp%rcl_effrime
      v_rimeliq = v_rimeliq*v_covptot
      v_rimeliq = v_rimeliq*v_dt
      v_tmp0 = ydecldp%rcl_const7s
      v_rimeliq = v_rimeliq*v_tmp0
      v_rimeliq = v_rimeliq*v_fallcorr
      v_tmp0 = v_rho*v_snowcld
      v_tmp1 = ydecldp%rcl_const1s
      v_tmp0 = v_tmp0*v_tmp1
      v_tmp1 = ydecldp%rcl_const8s
      v_tmp0 = selected_pow(v_tmp0, v_tmp1)
      v_rimeliq = v_rimeliq*v_tmp0
      v_rimeliq = min(v_rimeliq, v_one)
      implicit_exchange(4, 1) = implicit_exchange(4, 1) + v_rimeliq
3150  continue
      if (v_raincld <= v_small) goto 3163
      v_tmp0 = v_rho*v_raincld
      v_tmp1 = ydecldp%rcl_lam1r
      v_tmp0 = v_tmp1/v_tmp0
      v_tmp1 = ydecldp%rcl_lam2r
      v_lamr = selected_pow(v_tmp0, v_tmp1)
      v_n0r = ydecldp%rcl_x1r
      v_tmp1 = ydecldp%rcl_x2r
      v_tmp0 = selected_pow(v_lamr, v_tmp1)
      v_n0r = v_n0r*v_tmp0
      goto 3166
3163  continue
      v_lamr = 0.0_real64
      v_n0r = 0.0_real64
3166  continue
      if (v_snowcld <= v_small) goto 3176
      v_tmp0 = v_rho*v_snowcld
      v_tmp1 = ydecldp%rcl_lam1s
      v_tmp0 = v_tmp1/v_tmp0
      v_tmp1 = ydecldp%rcl_lam2s
      v_lams = selected_pow(v_tmp0, v_tmp1)
      v_n0s = ydecldp%rcl_x1s
      goto 3179
3176  continue
      v_lams = 0.0_real64
      v_n0s = 0.0_real64
3179  continue
      if (v_icecld <= v_small) goto 3189
      v_tmp0 = v_rho*v_icecld
      v_tmp1 = ydecldp%rcl_lam1s
      v_tmp0 = v_tmp1/v_tmp0
      v_tmp1 = ydecldp%rcl_lam2s
      v_lami = selected_pow(v_tmp0, v_tmp1)
      v_n0i = ydecldp%rcl_x1s
      goto 3192
3189  continue
      v_lami = 0.0_real64
      v_n0i = 0.0_real64
3192  continue
! Source collection of rain by snow.
      if (v_t > v_rtt) goto 3237
      v_tmp0 = prainfrac_toprfz(column)
      if (v_tmp0 >= v_small) goto 3237
      if (v_raincld <= v_small) goto 3237
      if (v_snowcld <= v_small) goto 3237
      v_tmp0 = v_fallspd3 - v_fallspd4
      v_tmp0 = abs(v_tmp0)
      v_tmp1 = v_fallspd3 + v_fallspd4
      v_tmp2 = lceight
      v_tmp1 = v_tmp1/v_tmp2
      v_falldiff = max(v_tmp0, v_tmp1)
      v_pi = constant_rpi
      v_factor = v_pi*v_pi
      v_tmp0 = ydecldp%rdenswat
      v_factor = v_factor*v_tmp0
      v_factor = v_factor*v_one
      v_factor = v_factor*v_rho
      v_factor = v_factor*v_n0r
      v_factor = v_factor*v_n0s
      v_tmp0 = v_lamr*v_lamr
      v_tmp0 = v_tmp0*v_lamr
      v_tmp0 = v_lams*v_tmp0
      v_factor = v_factor/v_tmp0
      v_rat = v_lamr/v_lams
      v_raci = v_covptot*v_dt
      v_raci = v_raci*v_factor
      v_raci = v_raci*v_falldiff
      v_tmp0 = v_half*v_rat
      v_tmp1 = lctwo
      v_tmp0 = v_tmp0 + v_tmp1
      v_tmp0 = v_tmp0*v_rat
      v_tmp1 = lcfive
      v_tmp0 = v_tmp0 + v_tmp1
      v_raci = v_raci*v_tmp0
      v_tmp0 = v_lamr*v_lamr
      v_tmp0 = v_tmp0*v_lamr
      v_raci = v_raci/v_tmp0
      explicit_exchange(4, 3) = explicit_exchange(4, 3) + v_raci
      explicit_exchange(3, 4) = explicit_exchange(3, 4) - v_raci
3237  continue
! Source collection of rain by ice.
      if (v_t > v_rtt) goto 3283
      v_tmp0 = prainfrac_toprfz(column)
      if (v_tmp0 >= v_small) goto 3283
      if (v_raincld <= v_small) goto 3283
      if (v_icecld <= v_small) goto 3283
      v_tmp0 = v_fallspd3 - v_fallspd2
      v_tmp0 = abs(v_tmp0)
      v_tmp1 = v_fallspd3 + v_fallspd2
      v_tmp2 = lceight
      v_tmp1 = v_tmp1/v_tmp2
      v_falldiff = max(v_tmp0, v_tmp1)
      v_pi = constant_rpi
      v_factor = v_pi*v_pi
      v_tmp0 = ydecldp%rdenswat
      v_factor = v_factor*v_tmp0
      v_tmp0 = lc01
      v_factor = v_factor*v_tmp0
      v_factor = v_factor*v_rho
      v_factor = v_factor*v_n0r
      v_factor = v_factor*v_n0i
      v_tmp0 = v_lamr*v_lamr
      v_tmp0 = v_tmp0*v_lamr
      v_tmp0 = v_lami*v_tmp0
      v_factor = v_factor/v_tmp0
      v_rat = v_lamr/v_lami
      v_raci = v_covptot*v_dt
      v_raci = v_raci*v_factor
      v_raci = v_raci*v_falldiff
      v_tmp0 = v_half*v_rat
      v_tmp1 = lctwo
      v_tmp0 = v_tmp0 + v_tmp1
      v_tmp0 = v_tmp0*v_rat
      v_tmp1 = lcfive
      v_tmp0 = v_tmp0 + v_tmp1
      v_raci = v_raci*v_tmp0
      v_tmp0 = v_lamr*v_lamr
      v_tmp0 = v_tmp0*v_lamr
      v_raci = v_raci/v_tmp0
      explicit_exchange(2, 3) = explicit_exchange(2, 3) + v_raci
      explicit_exchange(3, 2) = explicit_exchange(3, 2) - v_raci
3283  continue
! Source 4.15. Snow sublimation uses the source signed denominator and coverage reduction.
      v_rhlimit = ydecldp%rprecrhmax
      v_tmp0 = v_one - v_rhlimit
      v_tmp0 = v_tmp0*v_covpmax
      v_tmp1 = v_one - v_a
      v_tmp1 = max(v_small, v_tmp1)
      v_tmp0 = v_tmp0/v_tmp1
      v_rhlimit = v_rhlimit + v_tmp0
      v_tmp0 = ydecldp%rprecrhmax
      v_rhlimit = max(v_rhlimit, v_tmp0)
      v_rhlimit = min(v_rhlimit, v_one)
      v_tmp0 = v_a*v_qsi
      v_tmp0 = v_qv - v_tmp0
      v_tmp1 = v_one - v_a
      v_tmp1 = max(v_small, v_tmp1)
      v_qe = v_tmp0/v_tmp1
      v_qe = min(v_qe, v_qsi)
      v_qe = max(v_zero, v_qe)
      if (v_covpclr <= v_small) goto 3359
      if (v_fg4 <= v_small) goto 3359
      v_tmp0 = v_rhlimit*v_qsi
      if (v_qe >= v_tmp0) goto 3359
      v_signtmp = v_covptot*v_dtgdp
      v_tmp0 = abs(v_signtmp)
      v_tmp0 = max(v_tmp0, v_eps)
      v_tmp0 = copy_sign(v_tmp0, v_signtmp)
      v_tmp0 = v_tmp0
      v_qpre = v_fg4*v_covpclr
      v_qpre = v_qpre/v_tmp0
      v_tmp0 = paph(column, klev + 1)
      v_tmp0 = v_p/v_tmp0
      v_beta = sqrt(v_tmp0)
      v_tmp0 = ydecldp%rvrfactor
      v_beta = v_beta/v_tmp0
      v_beta = v_beta*v_qpre
      v_tmp0 = max(v_covpclr, v_small)
      v_beta = v_beta/v_tmp0
      v_tmp1 = lc05777
      v_beta = selected_pow(v_beta, v_tmp1)
      v_tmp0 = ydecldp%rpecons
      v_tmp0 = v_rg*v_tmp0
      v_beta = v_tmp0*v_beta
      v_denom = v_beta*v_dt
      v_denom = v_denom*v_corqsi
      v_denom = v_one + v_denom
      v_evap = v_covpclr*v_beta
      v_tmp0 = v_qsi - v_qe
      v_evap = v_evap*v_tmp0
      v_evap = v_evap/v_denom
      v_evap = v_evap*v_dp
      v_evap = v_evap*v_rgr
      v_evap = v_evap*v_dtgdp
      v_evap = min(v_evap, v_fg4)
      explicit_exchange(5, 4) = explicit_exchange(5, 4) + v_evap
      explicit_exchange(4, 5) = explicit_exchange(4, 5) - v_evap
      v_tmp0 = v_covptot - v_a
      v_tmp0 = v_tmp0*v_evap
      v_tmp0 = v_tmp0/v_fg4
      v_tmp0 = max(v_zero, v_tmp0)
      v_tmp0 = v_covptot - v_tmp0
      v_tmp1 = ydecldp%rcovpmin
      v_covptot = max(v_tmp1, v_tmp0)
      v_fg4 = v_fg4 - v_evap
3359  continue
      v_tmp0 = ydecldp%rvice
      if (v_tmp0 <= v_zero) goto 3368
      v_tmp0 = ydecldp%rlmin
      if (v_fg2 >= v_tmp0) goto 3368
      explicit_exchange(5, 2) = explicit_exchange(5, 2) + v_fg2
      explicit_exchange(2, 5) = explicit_exchange(2, 5) - v_fg2
3368  continue
      v_tmp0 = ydecldp%rvrain
      if (v_tmp0 <= v_zero) goto 3377
      v_tmp0 = ydecldp%rlmin
      if (v_fg3 >= v_tmp0) goto 3377
      explicit_exchange(5, 3) = explicit_exchange(5, 3) + v_fg3
      explicit_exchange(3, 5) = explicit_exchange(3, 5) - v_fg3
3377  continue
      v_tmp0 = ydecldp%rvsnow
      if (v_tmp0 <= v_zero) goto 3386
      v_tmp0 = ydecldp%rlmin
      if (v_fg4 >= v_tmp0) goto 3386
      explicit_exchange(5, 4) = explicit_exchange(5, 4) + v_fg4
      explicit_exchange(4, 5) = explicit_exchange(4, 5) - v_fg4
3386  continue
! Source 5.1. Cloud fraction retains the implicit downward transport sink.
      v_anewm1 = v_a + v_solac
      v_tmp0 = v_one + v_solab
      v_anewm1 = v_anewm1/v_tmp0
      v_anewm1 = min(v_anewm1, v_one)
      v_tmp0 = ydecldp%ramin
      if (v_anewm1 >= v_tmp0) goto 3396
      v_anewm1 = 0.0_real64
3396  continue
      v_da = v_anewm1 - v_aor
! Source 5.2.1. Calculate explicit sink limits in the original species order.
      v_sinksum = 0.0_real64
      v_sinksum = v_sinksum - explicit_exchange(1, 1)
      v_sinksum = v_sinksum - explicit_exchange(1, 2)
      v_sinksum = v_sinksum - explicit_exchange(1, 3)
      v_sinksum = v_sinksum - explicit_exchange(1, 4)
      v_sinksum = v_sinksum - explicit_exchange(1, 5)
      v_maxval = max(v_ql, v_small)
      v_rat = max(v_sinksum, v_maxval)
      sink_ratios(1) = v_maxval/v_rat
      v_sinksum = 0.0_real64
      v_sinksum = v_sinksum - explicit_exchange(2, 1)
      v_sinksum = v_sinksum - explicit_exchange(2, 2)
      v_sinksum = v_sinksum - explicit_exchange(2, 3)
      v_sinksum = v_sinksum - explicit_exchange(2, 4)
      v_sinksum = v_sinksum - explicit_exchange(2, 5)
      v_maxval = max(v_qi, v_small)
      v_rat = max(v_sinksum, v_maxval)
      sink_ratios(2) = v_maxval/v_rat
      v_sinksum = 0.0_real64
      v_sinksum = v_sinksum - explicit_exchange(3, 1)
      v_sinksum = v_sinksum - explicit_exchange(3, 2)
      v_sinksum = v_sinksum - explicit_exchange(3, 3)
      v_sinksum = v_sinksum - explicit_exchange(3, 4)
      v_sinksum = v_sinksum - explicit_exchange(3, 5)
      v_maxval = max(v_qr, v_small)
      v_rat = max(v_sinksum, v_maxval)
      sink_ratios(3) = v_maxval/v_rat
      v_sinksum = 0.0_real64
      v_sinksum = v_sinksum - explicit_exchange(4, 1)
      v_sinksum = v_sinksum - explicit_exchange(4, 2)
      v_sinksum = v_sinksum - explicit_exchange(4, 3)
      v_sinksum = v_sinksum - explicit_exchange(4, 4)
      v_sinksum = v_sinksum - explicit_exchange(4, 5)
      v_maxval = max(v_qs, v_small)
      v_rat = max(v_sinksum, v_maxval)
      sink_ratios(4) = v_maxval/v_rat
      v_sinksum = 0.0_real64
      v_sinksum = v_sinksum - explicit_exchange(5, 1)
      v_sinksum = v_sinksum - explicit_exchange(5, 2)
      v_sinksum = v_sinksum - explicit_exchange(5, 3)
      v_sinksum = v_sinksum - explicit_exchange(5, 4)
      v_sinksum = v_sinksum - explicit_exchange(5, 5)
      v_maxval = max(v_qv, v_small)
      v_rat = max(v_sinksum, v_maxval)
      sink_ratios(5) = v_maxval/v_rat
! Stable insertion sort. An equal ratio retains its original species position.
      species_order(1) = 1
      do species = 2, 5
        insertion = species - 1
        do while (insertion >= 1)
          previous_species = species_order(insertion)
          if (sink_ratios(previous_species) <= sink_ratios(species)) exit
          species_order(insertion + 1) = previous_species
          insertion = insertion - 1
        end do
        species_order(insertion + 1) = species
      end do
      phase_amount = [v_ql, v_qi, v_qr, v_qs, v_qv]
      do ordered_species = 1, 5
        species = species_order(ordered_species)
        sink = 0.0_real64
        do other_species = 1, 5
          sink = sink - explicit_exchange(species, other_species)
          outgoing(other_species) = explicit_exchange(species, other_species) < 0.0_real64
        end do
        available = max(phase_amount(species), v_small)
        sink = max(sink, available)
        fraction = available/sink
        do other_species = 1, 5
          if (outgoing(other_species)) then
            explicit_exchange(species, other_species) = explicit_exchange(species, other_species)*fraction
            explicit_exchange(other_species, species) = explicit_exchange(other_species, species)*fraction
          end if
        end do
      end do
! Source 5.2.2. Form each matrix column and each right-hand side in source order.
      system_matrix(1, 1) = v_one + v_fallsink1
      system_matrix(1, 1) = system_matrix(1, 1) + implicit_exchange(1, 1)
      system_matrix(1, 1) = system_matrix(1, 1) + implicit_exchange(2, 1)
      system_matrix(1, 1) = system_matrix(1, 1) + implicit_exchange(3, 1)
      system_matrix(1, 1) = system_matrix(1, 1) + implicit_exchange(4, 1)
      system_matrix(1, 1) = system_matrix(1, 1) + implicit_exchange(5, 1)
      system_matrix(2, 1) = -implicit_exchange(2, 1)
      system_matrix(3, 1) = -implicit_exchange(3, 1)
      system_matrix(4, 1) = -implicit_exchange(4, 1)
      system_matrix(5, 1) = -implicit_exchange(5, 1)
      system_matrix(1, 2) = -implicit_exchange(1, 2)
      system_matrix(2, 2) = v_one + v_fallsink2
      system_matrix(2, 2) = system_matrix(2, 2) + implicit_exchange(1, 2)
      system_matrix(2, 2) = system_matrix(2, 2) + implicit_exchange(2, 2)
      system_matrix(2, 2) = system_matrix(2, 2) + implicit_exchange(3, 2)
      system_matrix(2, 2) = system_matrix(2, 2) + implicit_exchange(4, 2)
      system_matrix(2, 2) = system_matrix(2, 2) + implicit_exchange(5, 2)
      system_matrix(3, 2) = -implicit_exchange(3, 2)
      system_matrix(4, 2) = -implicit_exchange(4, 2)
      system_matrix(5, 2) = -implicit_exchange(5, 2)
      system_matrix(1, 3) = -implicit_exchange(1, 3)
      system_matrix(2, 3) = -implicit_exchange(2, 3)
      system_matrix(3, 3) = v_one + v_fallsink3
      system_matrix(3, 3) = system_matrix(3, 3) + implicit_exchange(1, 3)
      system_matrix(3, 3) = system_matrix(3, 3) + implicit_exchange(2, 3)
      system_matrix(3, 3) = system_matrix(3, 3) + implicit_exchange(3, 3)
      system_matrix(3, 3) = system_matrix(3, 3) + implicit_exchange(4, 3)
      system_matrix(3, 3) = system_matrix(3, 3) + implicit_exchange(5, 3)
      system_matrix(4, 3) = -implicit_exchange(4, 3)
      system_matrix(5, 3) = -implicit_exchange(5, 3)
      system_matrix(1, 4) = -implicit_exchange(1, 4)
      system_matrix(2, 4) = -implicit_exchange(2, 4)
      system_matrix(3, 4) = -implicit_exchange(3, 4)
      system_matrix(4, 4) = v_one + v_fallsink4
      system_matrix(4, 4) = system_matrix(4, 4) + implicit_exchange(1, 4)
      system_matrix(4, 4) = system_matrix(4, 4) + implicit_exchange(2, 4)
      system_matrix(4, 4) = system_matrix(4, 4) + implicit_exchange(3, 4)
      system_matrix(4, 4) = system_matrix(4, 4) + implicit_exchange(4, 4)
      system_matrix(4, 4) = system_matrix(4, 4) + implicit_exchange(5, 4)
      system_matrix(5, 4) = -implicit_exchange(5, 4)
      system_matrix(1, 5) = -implicit_exchange(1, 5)
      system_matrix(2, 5) = -implicit_exchange(2, 5)
      system_matrix(3, 5) = -implicit_exchange(3, 5)
      system_matrix(4, 5) = -implicit_exchange(4, 5)
      system_matrix(5, 5) = v_one + v_fallsink5
      system_matrix(5, 5) = system_matrix(5, 5) + implicit_exchange(1, 5)
      system_matrix(5, 5) = system_matrix(5, 5) + implicit_exchange(2, 5)
      system_matrix(5, 5) = system_matrix(5, 5) + implicit_exchange(3, 5)
      system_matrix(5, 5) = system_matrix(5, 5) + implicit_exchange(4, 5)
      system_matrix(5, 5) = system_matrix(5, 5) + implicit_exchange(5, 5)
      v_sumrhs = 0.0_real64
      v_sumrhs = v_sumrhs + explicit_exchange(1, 1)
      v_sumrhs = v_sumrhs + explicit_exchange(1, 2)
      v_sumrhs = v_sumrhs + explicit_exchange(1, 3)
      v_sumrhs = v_sumrhs + explicit_exchange(1, 4)
      v_sumrhs = v_sumrhs + explicit_exchange(1, 5)
      solution(1) = v_ql + v_sumrhs
      v_sumrhs = 0.0_real64
      v_sumrhs = v_sumrhs + explicit_exchange(2, 1)
      v_sumrhs = v_sumrhs + explicit_exchange(2, 2)
      v_sumrhs = v_sumrhs + explicit_exchange(2, 3)
      v_sumrhs = v_sumrhs + explicit_exchange(2, 4)
      v_sumrhs = v_sumrhs + explicit_exchange(2, 5)
      solution(2) = v_qi + v_sumrhs
      v_sumrhs = 0.0_real64
      v_sumrhs = v_sumrhs + explicit_exchange(3, 1)
      v_sumrhs = v_sumrhs + explicit_exchange(3, 2)
      v_sumrhs = v_sumrhs + explicit_exchange(3, 3)
      v_sumrhs = v_sumrhs + explicit_exchange(3, 4)
      v_sumrhs = v_sumrhs + explicit_exchange(3, 5)
      solution(3) = v_qr + v_sumrhs
      v_sumrhs = 0.0_real64
      v_sumrhs = v_sumrhs + explicit_exchange(4, 1)
      v_sumrhs = v_sumrhs + explicit_exchange(4, 2)
      v_sumrhs = v_sumrhs + explicit_exchange(4, 3)
      v_sumrhs = v_sumrhs + explicit_exchange(4, 4)
      v_sumrhs = v_sumrhs + explicit_exchange(4, 5)
      solution(4) = v_qs + v_sumrhs
      v_sumrhs = 0.0_real64
      v_sumrhs = v_sumrhs + explicit_exchange(5, 1)
      v_sumrhs = v_sumrhs + explicit_exchange(5, 2)
      v_sumrhs = v_sumrhs + explicit_exchange(5, 3)
      v_sumrhs = v_sumrhs + explicit_exchange(5, 4)
      v_sumrhs = v_sumrhs + explicit_exchange(5, 5)
      solution(5) = v_qv + v_sumrhs
! No-pivot LU factorisation. Every product rounds before its subtraction.
! Keep the fixed five-species solve in registers, with the same FP64 order.
! d0..d24 hold LHS, d25..d29 hold XN, and d30 holds rounded TMP0.
      do pivot = 1, 4
        do matrix_row = pivot + 1, 5
          system_matrix(matrix_row, pivot) = system_matrix(matrix_row, pivot)/system_matrix(pivot, pivot)
          do matrix_column = pivot + 1, 5
            product = system_matrix(matrix_row, pivot)*system_matrix(pivot, matrix_column)
            system_matrix(matrix_row, matrix_column) = system_matrix(matrix_row, matrix_column) - product
          end do
        end do
      end do
      do matrix_row = 2, 5
        do matrix_column = 1, matrix_row - 1
          product = system_matrix(matrix_row, matrix_column)*solution(matrix_column)
          solution(matrix_row) = solution(matrix_row) - product
        end do
      end do
      do matrix_row = 5, 1, -1
        do matrix_column = matrix_row + 1, 5
          product = system_matrix(matrix_row, matrix_column)*solution(matrix_column)
          solution(matrix_row) = solution(matrix_row) - product
        end do
        solution(matrix_row) = solution(matrix_row)/system_matrix(matrix_row, matrix_row)
      end do
      v_tmp0 = product
! Snapshot transport before the local phase cleanup.
      v_transport1 = solution(1)
      v_transport2 = solution(2)
      v_transport3 = solution(3)
      v_transport4 = solution(4)
      v_transport5 = solution(5)
! Keep physical transport nonnegative and retain the signed water debit.
      if (solution(1) >= v_zero) goto 3797
      v_transport1 = 0.0_real64
      v_tmp1 = v_fallsink1 + v_convsink1
      v_tmp1 = v_tmp1*solution(1)
      solution(5) = solution(5) + v_tmp1
3797  continue
      if (solution(1) >= v_small) goto 3802
      solution(5) = solution(5) + solution(1)
      solution(1) = 0.0_real64
3802  continue
! Keep physical transport nonnegative and retain the signed water debit.
      if (solution(2) >= v_zero) goto 3810
      v_transport2 = 0.0_real64
      v_tmp1 = v_fallsink2 + v_convsink2
      v_tmp1 = v_tmp1*solution(2)
      solution(5) = solution(5) + v_tmp1
3810  continue
      if (solution(2) >= v_small) goto 3815
      solution(5) = solution(5) + solution(2)
      solution(2) = 0.0_real64
3815  continue
! Keep physical transport nonnegative and retain the signed water debit.
      if (solution(3) >= v_zero) goto 3823
      v_transport3 = 0.0_real64
      v_tmp1 = v_fallsink3 + v_convsink3
      v_tmp1 = v_tmp1*solution(3)
      solution(5) = solution(5) + v_tmp1
3823  continue
      if (solution(3) >= v_small) goto 3828
      solution(5) = solution(5) + solution(3)
      solution(3) = 0.0_real64
3828  continue
! Keep physical transport nonnegative and retain the signed water debit.
      if (solution(4) >= v_zero) goto 3836
      v_transport4 = 0.0_real64
      v_tmp1 = v_fallsink4 + v_convsink4
      v_tmp1 = v_tmp1*solution(4)
      solution(5) = solution(5) + v_tmp1
3836  continue
      if (solution(4) >= v_small) goto 3841
      solution(5) = solution(5) + solution(4)
      solution(4) = 0.0_real64
3841  continue
      v_prev1 = solution(1)
      column_state(22, level) = solution(1)
      v_tmp0 = v_fallsink1*v_transport1
      v_tmp0 = v_tmp0*v_rdtgdp
      column_state(27, level + 1) = v_tmp0
      v_prev2 = solution(2)
      column_state(23, level) = solution(2)
      v_tmp0 = v_fallsink2*v_transport2
      v_tmp0 = v_tmp0*v_rdtgdp
      column_state(28, level + 1) = v_tmp0
      v_prev3 = solution(3)
      column_state(24, level) = solution(3)
      v_tmp0 = v_fallsink3*v_transport3
      v_tmp0 = v_tmp0*v_rdtgdp
      column_state(29, level + 1) = v_tmp0
      v_prev4 = solution(4)
      column_state(25, level) = solution(4)
      v_tmp0 = v_fallsink4*v_transport4
      v_tmp0 = v_tmp0*v_rdtgdp
      column_state(30, level + 1) = v_tmp0
      v_prev5 = solution(5)
      v_tmp0 = v_fallsink5*v_transport5
      v_tmp0 = v_tmp0*v_rdtgdp
      column_state(31, level + 1) = v_tmp0
      floating_temporary = column_state(30, level + 1) + column_state(29, level + 1)
      v_pretot = floating_temporary
      if (v_pretot >= v_small) goto 3878
      v_covptot = 0.0_real64
3878  continue
! Source 6.1. Account for transport before each phase latent-heat increment.
      v_fluxq = v_convsrc1 + v_fallsrc1
      v_tmp0 = v_fallsink1 + v_convsink1
      v_tmp0 = v_tmp0*v_transport1
      v_fluxq = v_fluxq - v_tmp0
      v_tmp0 = solution(1) - v_ql
      v_tmp0 = v_tmp0 - v_fluxq
      v_tmp0 = v_alv*v_tmp0
      v_tmp0 = v_tmp0*v_invdt
      v_tmp1 = ptendency_loc_t(column, level)
      v_tmp1 = v_tmp1 + v_tmp0
      ptendency_loc_t(column, level) = v_tmp1
      v_tmp0 = solution(1) - v_ql0
      v_tmp0 = v_tmp0*v_invdt
      v_tmp1 = ptendency_loc_cld(column, level, 1)
      v_tmp1 = v_tmp1 + v_tmp0
      ptendency_loc_cld(column, level, 1) = v_tmp1
      v_fluxq = v_convsrc2 + v_fallsrc2
      v_tmp0 = v_fallsink2 + v_convsink2
      v_tmp0 = v_tmp0*v_transport2
      v_fluxq = v_fluxq - v_tmp0
      v_tmp0 = solution(2) - v_qi
      v_tmp0 = v_tmp0 - v_fluxq
      v_tmp0 = v_als*v_tmp0
      v_tmp0 = v_tmp0*v_invdt
      v_tmp1 = ptendency_loc_t(column, level)
      v_tmp1 = v_tmp1 + v_tmp0
      ptendency_loc_t(column, level) = v_tmp1
      v_tmp0 = solution(2) - v_qi0
      v_tmp0 = v_tmp0*v_invdt
      v_tmp1 = ptendency_loc_cld(column, level, 2)
      v_tmp1 = v_tmp1 + v_tmp0
      ptendency_loc_cld(column, level, 2) = v_tmp1
      v_fluxq = v_convsrc3 + v_fallsrc3
      v_tmp0 = v_fallsink3 + v_convsink3
      v_tmp0 = v_tmp0*v_transport3
      v_fluxq = v_fluxq - v_tmp0
      v_tmp0 = solution(3) - v_qr
      v_tmp0 = v_tmp0 - v_fluxq
      v_tmp0 = v_alv*v_tmp0
      v_tmp0 = v_tmp0*v_invdt
      v_tmp1 = ptendency_loc_t(column, level)
      v_tmp1 = v_tmp1 + v_tmp0
      ptendency_loc_t(column, level) = v_tmp1
      v_tmp0 = solution(3) - v_qr0
      v_tmp0 = v_tmp0*v_invdt
      v_tmp1 = ptendency_loc_cld(column, level, 3)
      v_tmp1 = v_tmp1 + v_tmp0
      ptendency_loc_cld(column, level, 3) = v_tmp1
      v_fluxq = v_convsrc4 + v_fallsrc4
      v_tmp0 = v_fallsink4 + v_convsink4
      v_tmp0 = v_tmp0*v_transport4
      v_fluxq = v_fluxq - v_tmp0
      v_tmp0 = solution(4) - v_qs
      v_tmp0 = v_tmp0 - v_fluxq
      v_tmp0 = v_als*v_tmp0
      v_tmp0 = v_tmp0*v_invdt
      v_tmp1 = ptendency_loc_t(column, level)
      v_tmp1 = v_tmp1 + v_tmp0
      ptendency_loc_t(column, level) = v_tmp1
      v_tmp0 = solution(4) - v_qs0
      v_tmp0 = v_tmp0*v_invdt
      v_tmp1 = ptendency_loc_cld(column, level, 4)
      v_tmp1 = v_tmp1 + v_tmp0
      ptendency_loc_cld(column, level, 4) = v_tmp1
! Source 6.2 through 6.4. Construct the actual updated state for the accepted child.
      v_tmp0 = solution(5) - v_qv
      v_tmp0 = v_tmp0*v_invdt
      v_tmp1 = ptendency_loc_q(column, level)
      v_tmp1 = v_tmp1 + v_tmp0
      ptendency_loc_q(column, level) = v_tmp1
      v_tmp0 = v_da*v_invdt
      v_tmp1 = ptendency_loc_a(column, level)
      v_tmp1 = v_tmp1 + v_tmp0
      ptendency_loc_a(column, level) = v_tmp1
      v_tmp0 = ptendency_loc_q(column, level)
      v_tmp1 = ptendency_cml_q(column, level)
      v_tmp0 = v_tmp0 + v_tmp1
      v_tmp0 = v_dt*v_tmp0
      v_tmp1 = pq(column, level)
      v_qup = v_tmp1 + v_tmp0
      v_tmp0 = ptendency_loc_t(column, level)
      v_tmp1 = ptendency_cml_t(column, level)
      v_tmp0 = v_tmp0 + v_tmp1
      v_tmp0 = v_dt*v_tmp0
      v_tmp1 = pt(column, level)
      v_tup = v_tmp1 + v_tmp0
      v_tmp0 = ptendency_loc_a(column, level)
      v_tmp1 = ptendency_cml_a(column, level)
      v_tmp0 = v_tmp0 + v_tmp1
      v_tmp0 = v_dt*v_tmp0
      v_tmp1 = pa(column, level)
      v_aup = v_tmp1 + v_tmp0
      v_psurf = paph(column, klev + 1)
      temperature_trial(1) = v_tup
      vapour_trial(1) = v_qup
      cloud_trial(1) = v_aup
      pressure_trial(1) = v_p
      surface_trial(1) = v_psurf
      call cloud_supersatcheck(ydecldp, 1_int32, 1_int32, 1_int32, klev, 1_int32, &
                               temperature_trial, vapour_trial, cloud_trial, pressure_trial, surface_trial, &
                               temperature_adjust, vapour_adjust, cloud_adjust, liquid_adjust, ice_adjust)
      v_tadj = temperature_adjust(1)
      v_qadj = vapour_adjust(1)
      v_aadj = cloud_adjust(1)
      v_ladj = liquid_adjust(1)
      v_iadj = ice_adjust(1)
      v_tmp0 = v_qadj*v_invdt
      v_tmp1 = ptendency_loc_q(column, level)
      v_tmp1 = v_tmp1 + v_tmp0
      ptendency_loc_q(column, level) = v_tmp1
      v_tmp0 = v_tadj*v_invdt
      v_tmp1 = ptendency_loc_t(column, level)
      v_tmp1 = v_tmp1 + v_tmp0
      ptendency_loc_t(column, level) = v_tmp1
      v_tmp0 = v_aadj*v_invdt
      v_tmp1 = ptendency_loc_a(column, level)
      v_tmp1 = v_tmp1 + v_tmp0
      ptendency_loc_a(column, level) = v_tmp1
      v_tmp0 = v_ladj*v_invdt
      v_tmp1 = ptendency_loc_cld(column, level, 1)
      v_tmp1 = v_tmp1 + v_tmp0
      ptendency_loc_cld(column, level, 1) = v_tmp1
      v_tmp0 = v_iadj*v_invdt
      v_tmp1 = ptendency_loc_cld(column, level, 2)
      v_tmp1 = v_tmp1 + v_tmp0
      ptendency_loc_cld(column, level, 2) = v_tmp1
      v_tmp0 = ptendency_loc_cld(column, level, 1)
      v_tmp0 = v_tmp0*v_dt
      v_ladj = v_ql0 + v_tmp0
      if (v_ladj >= v_zero) goto 4042
      v_tmp0 = v_ladj*v_invdt
      v_tmp1 = ptendency_loc_cld(column, level, 1)
      v_tmp1 = v_tmp1 - v_tmp0
      ptendency_loc_cld(column, level, 1) = v_tmp1
      v_tmp1 = ptendency_loc_q(column, level)
      v_tmp1 = v_tmp1 + v_tmp0
      ptendency_loc_q(column, level) = v_tmp1
      v_tmp0 = v_alv*v_ladj
      v_tmp0 = v_tmp0*v_invdt
      v_tmp1 = ptendency_loc_t(column, level)
      v_tmp1 = v_tmp1 - v_tmp0
      ptendency_loc_t(column, level) = v_tmp1
4042  continue
      v_tmp0 = ptendency_loc_cld(column, level, 2)
      v_tmp0 = v_tmp0*v_dt
      v_iadj = v_qi0 + v_tmp0
      if (v_iadj >= v_zero) goto 4060
      v_tmp0 = v_iadj*v_invdt
      v_tmp1 = ptendency_loc_cld(column, level, 2)
      v_tmp1 = v_tmp1 - v_tmp0
      ptendency_loc_cld(column, level, 2) = v_tmp1
      v_tmp1 = ptendency_loc_q(column, level)
      v_tmp1 = v_tmp1 + v_tmp0
      ptendency_loc_q(column, level) = v_tmp1
      v_tmp0 = v_als*v_iadj
      v_tmp0 = v_tmp0*v_invdt
      v_tmp1 = ptendency_loc_t(column, level)
      v_tmp1 = v_tmp1 - v_tmp0
      ptendency_loc_t(column, level) = v_tmp1
4060  continue
      pcovptot(column, level) = v_covptot
      v_tmp0 = pa(column, level)
      v_tmp0 = v_tmp0 + v_da
      v_tmp1 = lc0001
      if (v_tmp0 <= v_tmp1) goto 4071
      v_tmp0 = max(v_tmp0, v_covptot)
      v_tmp1 = lc01
      v_tmp0 = max(v_tmp0, v_tmp1)
      column_state(38, level) = v_tmp0
4071  continue
    end do
    do level = 1, klev + 1
4080  continue
      v_tmp0 = column_state(29, level)
      v_tmp1 = column_state(27, level)
      v_tmp0 = v_tmp0 + v_tmp1
      pfplsl(column, level) = v_tmp0
      v_tmp0 = column_state(30, level)
      v_tmp1 = column_state(28, level)
      v_tmp0 = v_tmp0 + v_tmp1
      pfplsn(column, level) = v_tmp0
    end do
    level = 1
    v_tmp0 = 0.0_real64
    pfsqlf(column, level) = v_tmp0
    pfsqif(column, level) = v_tmp0
    pfcqnng(column, level) = v_tmp0
    pfcqlng(column, level) = v_tmp0
    pfsqrf(column, level) = v_tmp0
    pfsqsf(column, level) = v_tmp0
    pfcqrng(column, level) = v_tmp0
    pfcqsng(column, level) = v_tmp0
    pfsqltur(column, level) = v_tmp0
    pfsqitur(column, level) = v_tmp0
    do level = 1, klev
4108  continue
      v_ph = paph(column, level)
      v_phnext = paph(column, level + 1)
      v_dp = v_phnext - v_ph
      v_gdphr = -v_rgr
      v_gdphr = v_gdphr*v_dp
      v_gdphr = v_gdphr*v_invdt
      v_tmp0 = pfsqlf(column, level)
      pfsqlf(column, level + 1) = v_tmp0
      v_tmp0 = pfsqif(column, level)
      pfsqif(column, level + 1) = v_tmp0
      v_tmp0 = pfsqlf(column, level)
      pfsqrf(column, level + 1) = v_tmp0
      v_tmp0 = pfsqif(column, level)
      pfsqsf(column, level + 1) = v_tmp0
      v_tmp0 = pfcqlng(column, level)
      pfcqlng(column, level + 1) = v_tmp0
      v_tmp0 = pfcqnng(column, level)
      pfcqnng(column, level + 1) = v_tmp0
      v_tmp0 = pfcqlng(column, level)
      pfcqrng(column, level + 1) = v_tmp0
      v_tmp0 = pfcqnng(column, level)
      pfcqsng(column, level + 1) = v_tmp0
      v_tmp0 = pfsqltur(column, level)
      pfsqltur(column, level + 1) = v_tmp0
      v_tmp0 = pfsqitur(column, level)
      pfsqitur(column, level + 1) = v_tmp0
      v_tmp0 = column_state(14, level)
      v_alfa = v_tmp0
      v_qlxn = column_state(22, level)
      v_ql0 = column_state(9, level)
      v_tmp0 = pvfl(column, level)
      v_tmp0 = v_tmp0*v_dt
      v_tmp1 = v_qlxn - v_ql0
      v_tmp1 = v_tmp1 + v_tmp0
      v_tmp1 = v_tmp1*v_gdphr
      v_tmp2 = pfsqlf(column, level + 1)
      v_tmp2 = v_tmp2 + v_tmp1
      v_tmp1 = pludeli(column, level, 1)
      v_tmp2 = v_tmp2 + v_tmp1
      pfsqlf(column, level + 1) = v_tmp2
      v_qlneg = column_state(18, level)
      v_tmp0 = v_qlneg*v_gdphr
      v_tmp1 = pfcqlng(column, level + 1)
      v_tmp1 = v_tmp1 + v_tmp0
      pfcqlng(column, level + 1) = v_tmp1
      v_tmp0 = pvfl(column, level)
      v_tmp0 = v_tmp0*v_dt
      v_tmp0 = v_tmp0*v_gdphr
      v_tmp1 = pfsqltur(column, level + 1)
      v_tmp1 = v_tmp1 + v_tmp0
      pfsqltur(column, level + 1) = v_tmp1
      v_qrxn = column_state(24, level)
      v_qr0 = column_state(11, level)
      v_tmp0 = v_qrxn - v_qr0
      v_tmp0 = v_tmp0*v_gdphr
      v_tmp1 = pfsqrf(column, level + 1)
      v_tmp1 = v_tmp1 + v_tmp0
      pfsqrf(column, level + 1) = v_tmp1
      v_qrneg = column_state(20, level)
      v_tmp0 = v_qrneg*v_gdphr
      v_tmp1 = pfcqrng(column, level + 1)
      v_tmp1 = v_tmp1 + v_tmp0
      pfcqrng(column, level + 1) = v_tmp1
      v_qixn = column_state(23, level)
      v_qi0 = column_state(10, level)
      v_tmp0 = pvfi(column, level)
      v_tmp0 = v_tmp0*v_dt
      v_tmp1 = v_qixn - v_qi0
      v_tmp1 = v_tmp1 + v_tmp0
      v_tmp1 = v_tmp1*v_gdphr
      v_tmp2 = pfsqif(column, level + 1)
      v_tmp2 = v_tmp2 + v_tmp1
      v_tmp1 = pludeli(column, level, 2)
      v_tmp2 = v_tmp2 + v_tmp1
      pfsqif(column, level + 1) = v_tmp2
      v_qineg = column_state(19, level)
      v_tmp0 = v_qineg*v_gdphr
      v_tmp1 = pfcqnng(column, level + 1)
      v_tmp1 = v_tmp1 + v_tmp0
      pfcqnng(column, level + 1) = v_tmp1
      v_tmp0 = pvfi(column, level)
      v_tmp0 = v_tmp0*v_dt
      v_tmp0 = v_tmp0*v_gdphr
      v_tmp1 = pfsqitur(column, level + 1)
      v_tmp1 = v_tmp1 + v_tmp0
      pfsqitur(column, level + 1) = v_tmp1
      v_qsxn = column_state(25, level)
      v_qs0 = column_state(12, level)
      v_tmp0 = v_qsxn - v_qs0
      v_tmp0 = v_tmp0*v_gdphr
      v_tmp1 = pfsqsf(column, level + 1)
      v_tmp1 = v_tmp1 + v_tmp0
      pfsqsf(column, level + 1) = v_tmp1
      v_qsneg = column_state(21, level)
      v_tmp0 = v_qsneg*v_gdphr
      v_tmp1 = pfcqsng(column, level + 1)
      v_tmp1 = v_tmp1 + v_tmp0
      pfcqsng(column, level + 1) = v_tmp1
    end do
    do level = 1, klev + 1
4213  continue
      v_tmp0 = -v_lv
      v_tmp1 = pfplsl(column, level)
      v_tmp0 = v_tmp0*v_tmp1
      pfhpsl(column, level) = v_tmp0
      v_tmp0 = -v_ls
      v_tmp1 = pfplsn(column, level)
      v_tmp0 = v_tmp0*v_tmp1
      pfhpsn(column, level) = v_tmp0
    end do
  end do
  deallocate (column_state)
  errno_value = saved_errno
  end procedure cloudsc

  !> Copy a floating-point sign bit without changing the magnitude bits.
  pure function copy_sign(magnitude, sign_source) result(answer)
    real(real64), intent(in) :: magnitude, sign_source
    real(real64) :: answer
    integer(int64) :: bits, sign_bits
    bits = ibclr(transfer(magnitude, 0_int64), 63)
    sign_bits = iand(transfer(sign_source, 0_int64), int(z'8000000000000000', int64))
    answer = transfer(ior(bits, sign_bits), answer)
  end function copy_sign

  !> Check nearest rounding and an exact gradual-underflow result.
  subroutine require_ieee_mode()
    type(ieee_round_type) :: rounding
    real(real64), volatile :: normal, half, subnormal
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) call reject_contract()
    normal = tiny(0.0_real64)
    half = 0.5_real64
    subnormal = normal*half
    if (transfer(subnormal, 0_int64) /= int(z'0008000000000000', int64)) call reject_contract()
  end subroutine require_ieee_mode
end submodule cloud_microphysics_implementation
