!> Expose every named radiation coefficient field on its canonical owner.
module forecast_owned_radiation_coefficient_namespace
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_int64_t
  use native_radiation_setup_state, only: owned_radiation_setup_state
  use forecast_radiation_namespace_views, only: native_radiation_namespace_field
  implicit none
  private
  public :: initialize_owned_radiation_coefficient_namespace, get_owned_radiation_coefficient_field
contains
!> Initialize source zero-born fields before any setup producer is active.
!! STATE is the actual native owner. Live context or storage is refused.
  integer(int32) function initialize_owned_radiation_coefficient_namespace(state) result(status)
    type(owned_radiation_setup_state), intent(inout) :: state
    status = 2
    if (state%context_ready .or. state%storage_ready .or. state%setup_complete) return
    state%longwave_input%b1_fracrefao = 0.0_real64
    state%longwave_input%b1_fracrefbo = 0.0_real64
    state%longwave_input%b1_kao = 0.0_real64
    state%longwave_input%b1_kbo = 0.0_real64
    state%longwave_input%b1_kao_d = 0.0_real64
    state%longwave_input%b1_kbo_d = 0.0_real64
    state%longwave_input%b1_kao_mn2 = 0.0_real64
    state%longwave_input%b1_kbo_mn2 = 0.0_real64
    state%longwave_input%b1_selfrefo = 0.0_real64
    state%longwave_input%b1_forrefo = 0.0_real64
    state%longwave_input%b2_fracrefao = 0.0_real64
    state%longwave_input%b2_fracrefbo = 0.0_real64
    state%longwave_input%b2_kao = 0.0_real64
    state%longwave_input%b2_kbo = 0.0_real64
    state%longwave_input%b2_kao_d = 0.0_real64
    state%longwave_input%b2_kbo_d = 0.0_real64
    state%longwave_input%b2_selfrefo = 0.0_real64
    state%longwave_input%b2_forrefo = 0.0_real64
    state%longwave_input%b3_fracrefao = 0.0_real64
    state%longwave_input%b3_fracrefbo = 0.0_real64
    state%longwave_input%b3_kao_mn2o = 0.0_real64
    state%longwave_input%b3_kbo_mn2o = 0.0_real64
    state%longwave_input%b3_kao = 0.0_real64
    state%longwave_input%b3_kbo = 0.0_real64
    state%longwave_input%b3_kao_d = 0.0_real64
    state%longwave_input%b3_kbo_d = 0.0_real64
    state%longwave_input%b3_selfrefo = 0.0_real64
    state%longwave_input%b3_forrefo = 0.0_real64
    state%longwave_input%b4_fracrefao = 0.0_real64
    state%longwave_input%b4_fracrefbo = 0.0_real64
    state%longwave_input%b4_kao = 0.0_real64
    state%longwave_input%b4_kbo = 0.0_real64
    state%longwave_input%b4_kao_d = 0.0_real64
    state%longwave_input%b4_kbo_d = 0.0_real64
    state%longwave_input%b4_selfrefo = 0.0_real64
    state%longwave_input%b4_forrefo = 0.0_real64
    state%longwave_input%b5_fracrefao = 0.0_real64
    state%longwave_input%b5_fracrefbo = 0.0_real64
    state%longwave_input%b5_ccl4o = 0.0_real64
    state%longwave_input%b5_kao_mo3 = 0.0_real64
    state%longwave_input%b5_kao = 0.0_real64
    state%longwave_input%b5_kbo = 0.0_real64
    state%longwave_input%b5_kao_d = 0.0_real64
    state%longwave_input%b5_kbo_d = 0.0_real64
    state%longwave_input%b5_selfrefo = 0.0_real64
    state%longwave_input%b5_forrefo = 0.0_real64
    state%longwave_input%b6_fracrefao = 0.0_real64
    state%longwave_input%b6_cfc11adjo = 0.0_real64
    state%longwave_input%b6_cfc12o = 0.0_real64
    state%longwave_input%b6_kao = 0.0_real64
    state%longwave_input%b6_kao_d = 0.0_real64
    state%longwave_input%b6_selfrefo = 0.0_real64
    state%longwave_input%b6_kao_mco2 = 0.0_real64
    state%longwave_input%b6_forrefo = 0.0_real64
    state%longwave_input%b7_fracrefao = 0.0_real64
    state%longwave_input%b7_fracrefbo = 0.0_real64
    state%longwave_input%b7_kao = 0.0_real64
    state%longwave_input%b7_kbo = 0.0_real64
    state%longwave_input%b7_kao_d = 0.0_real64
    state%longwave_input%b7_kbo_d = 0.0_real64
    state%longwave_input%b7_selfrefo = 0.0_real64
    state%longwave_input%b7_kao_mco2 = 0.0_real64
    state%longwave_input%b7_kbo_mco2 = 0.0_real64
    state%longwave_input%b7_forrefo = 0.0_real64
    state%longwave_input%b8_fracrefao = 0.0_real64
    state%longwave_input%b8_fracrefbo = 0.0_real64
    state%longwave_input%b8_cfc12o = 0.0_real64
    state%longwave_input%b8_cfc22adjo = 0.0_real64
    state%longwave_input%b8_kao = 0.0_real64
    state%longwave_input%b8_kbo = 0.0_real64
    state%longwave_input%b8_kao_d = 0.0_real64
    state%longwave_input%b8_kbo_d = 0.0_real64
    state%longwave_input%b8_selfrefo = 0.0_real64
    state%longwave_input%b8_kao_mco2 = 0.0_real64
    state%longwave_input%b8_kao_mn2o = 0.0_real64
    state%longwave_input%b8_kao_mo3 = 0.0_real64
    state%longwave_input%b8_kbo_mco2 = 0.0_real64
    state%longwave_input%b8_kbo_mn2o = 0.0_real64
    state%longwave_input%b8_forrefo = 0.0_real64
    state%longwave_input%b9_fracrefao = 0.0_real64
    state%longwave_input%b9_fracrefbo = 0.0_real64
    state%longwave_input%b9_kao = 0.0_real64
    state%longwave_input%b9_kbo = 0.0_real64
    state%longwave_input%b9_kao_d = 0.0_real64
    state%longwave_input%b9_kbo_d = 0.0_real64
    state%longwave_input%b9_kao_mn2o = 0.0_real64
    state%longwave_input%b9_kbo_mn2o = 0.0_real64
    state%longwave_input%b9_selfrefo = 0.0_real64
    state%longwave_input%b9_forrefo = 0.0_real64
    state%longwave_input%b10_fracrefao = 0.0_real64
    state%longwave_input%b10_fracrefbo = 0.0_real64
    state%longwave_input%b10_kao = 0.0_real64
    state%longwave_input%b10_kbo = 0.0_real64
    state%longwave_input%b10_kao_d = 0.0_real64
    state%longwave_input%b10_kbo_d = 0.0_real64
    state%longwave_input%b10_selfrefo = 0.0_real64
    state%longwave_input%b10_forrefo = 0.0_real64
    state%longwave_input%b11_fracrefao = 0.0_real64
    state%longwave_input%b11_fracrefbo = 0.0_real64
    state%longwave_input%b11_kao = 0.0_real64
    state%longwave_input%b11_kbo = 0.0_real64
    state%longwave_input%b11_kao_d = 0.0_real64
    state%longwave_input%b11_kbo_d = 0.0_real64
    state%longwave_input%b11_kao_mo2 = 0.0_real64
    state%longwave_input%b11_kbo_mo2 = 0.0_real64
    state%longwave_input%b11_selfrefo = 0.0_real64
    state%longwave_input%b11_forrefo = 0.0_real64
    state%longwave_input%b12_fracrefao = 0.0_real64
    state%longwave_input%b12_kao = 0.0_real64
    state%longwave_input%b12_kao_d = 0.0_real64
    state%longwave_input%b12_selfrefo = 0.0_real64
    state%longwave_input%b12_forrefo = 0.0_real64
    state%longwave_input%b13_fracrefao = 0.0_real64
    state%longwave_input%b13_fracrefbo = 0.0_real64
    state%longwave_input%b13_kao = 0.0_real64
    state%longwave_input%b13_kao_d = 0.0_real64
    state%longwave_input%b13_selfrefo = 0.0_real64
    state%longwave_input%b13_kao_mco2 = 0.0_real64
    state%longwave_input%b13_kao_mco = 0.0_real64
    state%longwave_input%b13_kbo_mo3 = 0.0_real64
    state%longwave_input%b13_forrefo = 0.0_real64
    state%longwave_input%b14_fracrefao = 0.0_real64
    state%longwave_input%b14_fracrefbo = 0.0_real64
    state%longwave_input%b14_kao = 0.0_real64
    state%longwave_input%b14_kbo = 0.0_real64
    state%longwave_input%b14_kao_d = 0.0_real64
    state%longwave_input%b14_kbo_d = 0.0_real64
    state%longwave_input%b14_selfrefo = 0.0_real64
    state%longwave_input%b14_forrefo = 0.0_real64
    state%longwave_input%b15_fracrefao = 0.0_real64
    state%longwave_input%b15_kao = 0.0_real64
    state%longwave_input%b15_kao_d = 0.0_real64
    state%longwave_input%b15_selfrefo = 0.0_real64
    state%longwave_input%b15_forrefo = 0.0_real64
    state%longwave_input%b15_kao_mn2 = 0.0_real64
    state%longwave_input%b16_fracrefao = 0.0_real64
    state%longwave_input%b16_fracrefbo = 0.0_real64
    state%longwave_input%b16_kao = 0.0_real64
    state%longwave_input%b16_kbo = 0.0_real64
    state%longwave_input%b16_kao_d = 0.0_real64
    state%longwave_input%b16_kbo_d = 0.0_real64
    state%longwave_input%b16_selfrefo = 0.0_real64
    state%longwave_input%b16_forrefo = 0.0_real64
    state%longwave_reduced%ngc = 0_int32
    state%longwave_reduced%ngs = 0_int32
    state%longwave_reduced%ngn = 0_int32
    state%longwave_reduced%ngb = 0_int32
    state%longwave_reduced%ngm = 0_int32
    state%longwave_reduced%wt = 0.0_real64
    state%longwave_reduced%corr1 = 0.0_real64
    state%longwave_reduced%corr2 = 0.0_real64
    state%longwave_reduced%rwgt = 0.0_real64
    state%longwave_reduced%frefa = 0.0_real64
    state%longwave_reduced%frefb = 0.0_real64
    state%longwave_reduced%frefadf = 0.0_real64
    state%longwave_reduced%frefbdf = 0.0_real64
    state%longwave_reduced%b1_fracrefa = 0.0_real64
    state%longwave_reduced%b1_fracrefb = 0.0_real64
    state%longwave_reduced%b1_ka = 0.0_real64
    state%longwave_reduced%b1_kb = 0.0_real64
    state%longwave_reduced%b1_ka_mn2 = 0.0_real64
    state%longwave_reduced%b1_kb_mn2 = 0.0_real64
    state%longwave_reduced%b1_selfref = 0.0_real64
    state%longwave_reduced%b1_forref = 0.0_real64
    state%longwave_reduced%b2_fracrefa = 0.0_real64
    state%longwave_reduced%b2_fracrefb = 0.0_real64
    state%longwave_reduced%b2_ka = 0.0_real64
    state%longwave_reduced%b2_kb = 0.0_real64
    state%longwave_reduced%b2_selfref = 0.0_real64
    state%longwave_reduced%b2_forref = 0.0_real64
    state%longwave_reduced%b3_fracrefa = 0.0_real64
    state%longwave_reduced%b3_fracrefb = 0.0_real64
    state%longwave_reduced%b3_ka_mn2o = 0.0_real64
    state%longwave_reduced%b3_kb_mn2o = 0.0_real64
    state%longwave_reduced%b3_ka = 0.0_real64
    state%longwave_reduced%b3_kb = 0.0_real64
    state%longwave_reduced%b3_selfref = 0.0_real64
    state%longwave_reduced%b3_forref = 0.0_real64
    state%longwave_reduced%b4_fracrefa = 0.0_real64
    state%longwave_reduced%b4_fracrefb = 0.0_real64
    state%longwave_reduced%b4_ka = 0.0_real64
    state%longwave_reduced%b4_kb = 0.0_real64
    state%longwave_reduced%b4_selfref = 0.0_real64
    state%longwave_reduced%b4_forref = 0.0_real64
    state%longwave_reduced%b5_fracrefa = 0.0_real64
    state%longwave_reduced%b5_fracrefb = 0.0_real64
    state%longwave_reduced%b5_ccl4 = 0.0_real64
    state%longwave_reduced%b5_ka = 0.0_real64
    state%longwave_reduced%b5_kb = 0.0_real64
    state%longwave_reduced%b5_ka_mo3 = 0.0_real64
    state%longwave_reduced%b5_selfref = 0.0_real64
    state%longwave_reduced%b5_forref = 0.0_real64
    state%longwave_reduced%b6_fracrefa = 0.0_real64
    state%longwave_reduced%b6_cfc11adj = 0.0_real64
    state%longwave_reduced%b6_cfc12 = 0.0_real64
    state%longwave_reduced%b6_ka = 0.0_real64
    state%longwave_reduced%b6_selfref = 0.0_real64
    state%longwave_reduced%b6_ka_mco2 = 0.0_real64
    state%longwave_reduced%b6_forref = 0.0_real64
    state%longwave_reduced%b7_fracrefa = 0.0_real64
    state%longwave_reduced%b7_fracrefb = 0.0_real64
    state%longwave_reduced%b7_ka = 0.0_real64
    state%longwave_reduced%b7_kb = 0.0_real64
    state%longwave_reduced%b7_selfref = 0.0_real64
    state%longwave_reduced%b7_ka_mco2 = 0.0_real64
    state%longwave_reduced%b7_kb_mco2 = 0.0_real64
    state%longwave_reduced%b7_forref = 0.0_real64
    state%longwave_reduced%b8_fracrefa = 0.0_real64
    state%longwave_reduced%b8_fracrefb = 0.0_real64
    state%longwave_reduced%b8_cfc12 = 0.0_real64
    state%longwave_reduced%b8_cfc22adj = 0.0_real64
    state%longwave_reduced%b8_ka = 0.0_real64
    state%longwave_reduced%b8_kb = 0.0_real64
    state%longwave_reduced%b8_ka_mco2 = 0.0_real64
    state%longwave_reduced%b8_ka_mn2o = 0.0_real64
    state%longwave_reduced%b8_ka_mo3 = 0.0_real64
    state%longwave_reduced%b8_kb_mco2 = 0.0_real64
    state%longwave_reduced%b8_kb_mn2o = 0.0_real64
    state%longwave_reduced%b8_selfref = 0.0_real64
    state%longwave_reduced%b8_forref = 0.0_real64
    state%longwave_reduced%b9_fracrefa = 0.0_real64
    state%longwave_reduced%b9_fracrefb = 0.0_real64
    state%longwave_reduced%b9_ka = 0.0_real64
    state%longwave_reduced%b9_kb = 0.0_real64
    state%longwave_reduced%b9_ka_mn2o = 0.0_real64
    state%longwave_reduced%b9_kb_mn2o = 0.0_real64
    state%longwave_reduced%b9_selfref = 0.0_real64
    state%longwave_reduced%b9_forref = 0.0_real64
    state%longwave_reduced%b10_fracrefa = 0.0_real64
    state%longwave_reduced%b10_fracrefb = 0.0_real64
    state%longwave_reduced%b10_ka = 0.0_real64
    state%longwave_reduced%b10_kb = 0.0_real64
    state%longwave_reduced%b10_selfref = 0.0_real64
    state%longwave_reduced%b10_forref = 0.0_real64
    state%longwave_reduced%b11_fracrefa = 0.0_real64
    state%longwave_reduced%b11_fracrefb = 0.0_real64
    state%longwave_reduced%b11_ka = 0.0_real64
    state%longwave_reduced%b11_kb = 0.0_real64
    state%longwave_reduced%b11_ka_mo2 = 0.0_real64
    state%longwave_reduced%b11_kb_mo2 = 0.0_real64
    state%longwave_reduced%b11_selfref = 0.0_real64
    state%longwave_reduced%b11_forref = 0.0_real64
    state%longwave_reduced%b12_fracrefa = 0.0_real64
    state%longwave_reduced%b12_ka = 0.0_real64
    state%longwave_reduced%b12_selfref = 0.0_real64
    state%longwave_reduced%b12_forref = 0.0_real64
    state%longwave_reduced%b12_strrat = 0.0_real64
    state%longwave_reduced%b13_fracrefa = 0.0_real64
    state%longwave_reduced%b13_fracrefb = 0.0_real64
    state%longwave_reduced%b13_ka = 0.0_real64
    state%longwave_reduced%b13_selfref = 0.0_real64
    state%longwave_reduced%b13_forref = 0.0_real64
    state%longwave_reduced%b13_ka_mco2 = 0.0_real64
    state%longwave_reduced%b13_ka_mco = 0.0_real64
    state%longwave_reduced%b13_kb_mo3 = 0.0_real64
    state%longwave_reduced%b14_fracrefa = 0.0_real64
    state%longwave_reduced%b14_fracrefb = 0.0_real64
    state%longwave_reduced%b14_ka = 0.0_real64
    state%longwave_reduced%b14_kb = 0.0_real64
    state%longwave_reduced%b14_selfref = 0.0_real64
    state%longwave_reduced%b14_forref = 0.0_real64
    state%longwave_reduced%b15_fracrefa = 0.0_real64
    state%longwave_reduced%b15_ka = 0.0_real64
    state%longwave_reduced%b15_ka_mn2 = 0.0_real64
    state%longwave_reduced%b15_selfref = 0.0_real64
    state%longwave_reduced%b15_forref = 0.0_real64
    state%longwave_reduced%b16_fracrefa = 0.0_real64
    state%longwave_reduced%b16_fracrefb = 0.0_real64
    state%longwave_reduced%b16_ka = 0.0_real64
    state%longwave_reduced%b16_kb = 0.0_real64
    state%longwave_reduced%b16_selfref = 0.0_real64
    state%longwave_reduced%b16_forref = 0.0_real64
    state%longwave_reference%trans = 0.0_real64
    state%longwave_reference%bpade = 0.0_real64
    state%longwave_reference%ng = 0_int32
    state%longwave_reference%nspa = 0_int32
    state%longwave_reference%nspb = 0_int32
    state%longwave_reference%delwave = 0.0_real64
    state%longwave_reference%totplnk = 0.0_real64
    state%longwave_reference%pref = 0.0_real64
    state%longwave_reference%preflog = 0.0_real64
    state%longwave_reference%tref = 0.0_real64
    state%longwave_reference%chi_mls = 0.0_real64
    state%shortwave_absorption%ng = 0_int32
    state%shortwave_absorption%nspa = 0_int32
    state%shortwave_absorption%nspb = 0_int32
    state%shortwave_absorption%nmpsrtm = 0_int32
    state%shortwave_absorption%pref = 0.0_real64
    state%shortwave_absorption%preflog = 0.0_real64
    state%shortwave_absorption%tref = 0.0_real64
    state%shortwave_absorption%ngm = 0_int32
    state%shortwave_absorption%ngc = 0_int32
    state%shortwave_absorption%ngs = 0_int32
    state%shortwave_absorption%wt = 0.0_real64
    state%shortwave_absorption%wtsm = 0.0_real64
    state%shortwave_absorption%rwgt = 0.0_real64
    state%shortwave_absorption%ngn = 0_int32
    state%shortwave_absorption%ngbsw = 0_int32
    state%shortwave_absorption%b16_ka = 0.0_real64
    state%shortwave_absorption%b16_kb = 0.0_real64
    state%shortwave_absorption%b16_ka_d = 0.0_real64
    state%shortwave_absorption%b16_kb_d = 0.0_real64
    state%shortwave_absorption%b16_selfref = 0.0_real64
    state%shortwave_absorption%b16_forref = 0.0_real64
    state%shortwave_absorption%b16_sfluxref = 0.0_real64
    state%shortwave_absorption%b16_rayl = 0.0_real64
    state%shortwave_absorption%b16_strrat1 = 0.0_real64
    state%shortwave_absorption%b16_layreffr = 0_int32
    state%shortwave_absorption%b16_kac = 0.0_real64
    state%shortwave_absorption%b16_kbc = 0.0_real64
    state%shortwave_absorption%b16_selfrefc = 0.0_real64
    state%shortwave_absorption%b16_forrefc = 0.0_real64
    state%shortwave_absorption%b16_sfluxrefc = 0.0_real64
    state%shortwave_absorption%b17_ka = 0.0_real64
    state%shortwave_absorption%b17_kb = 0.0_real64
    state%shortwave_absorption%b17_ka_d = 0.0_real64
    state%shortwave_absorption%b17_kb_d = 0.0_real64
    state%shortwave_absorption%b17_selfref = 0.0_real64
    state%shortwave_absorption%b17_forref = 0.0_real64
    state%shortwave_absorption%b17_sfluxref = 0.0_real64
    state%shortwave_absorption%b17_rayl = 0.0_real64
    state%shortwave_absorption%b17_strrat = 0.0_real64
    state%shortwave_absorption%b17_layreffr = 0_int32
    state%shortwave_absorption%b17_kac = 0.0_real64
    state%shortwave_absorption%b17_kbc = 0.0_real64
    state%shortwave_absorption%b17_selfrefc = 0.0_real64
    state%shortwave_absorption%b17_forrefc = 0.0_real64
    state%shortwave_absorption%b17_sfluxrefc = 0.0_real64
    state%shortwave_absorption%b18_ka = 0.0_real64
    state%shortwave_absorption%b18_kb = 0.0_real64
    state%shortwave_absorption%b18_ka_d = 0.0_real64
    state%shortwave_absorption%b18_kb_d = 0.0_real64
    state%shortwave_absorption%b18_selfref = 0.0_real64
    state%shortwave_absorption%b18_forref = 0.0_real64
    state%shortwave_absorption%b18_sfluxref = 0.0_real64
    state%shortwave_absorption%b18_rayl = 0.0_real64
    state%shortwave_absorption%b18_strrat = 0.0_real64
    state%shortwave_absorption%b18_layreffr = 0_int32
    state%shortwave_absorption%b18_kac = 0.0_real64
    state%shortwave_absorption%b18_kbc = 0.0_real64
    state%shortwave_absorption%b18_selfrefc = 0.0_real64
    state%shortwave_absorption%b18_forrefc = 0.0_real64
    state%shortwave_absorption%b18_sfluxrefc = 0.0_real64
    state%shortwave_absorption%b19_ka = 0.0_real64
    state%shortwave_absorption%b19_kb = 0.0_real64
    state%shortwave_absorption%b19_ka_d = 0.0_real64
    state%shortwave_absorption%b19_kb_d = 0.0_real64
    state%shortwave_absorption%b19_selfref = 0.0_real64
    state%shortwave_absorption%b19_forref = 0.0_real64
    state%shortwave_absorption%b19_sfluxref = 0.0_real64
    state%shortwave_absorption%b19_rayl = 0.0_real64
    state%shortwave_absorption%b19_strrat = 0.0_real64
    state%shortwave_absorption%b19_layreffr = 0_int32
    state%shortwave_absorption%b19_kac = 0.0_real64
    state%shortwave_absorption%b19_kbc = 0.0_real64
    state%shortwave_absorption%b19_selfrefc = 0.0_real64
    state%shortwave_absorption%b19_forrefc = 0.0_real64
    state%shortwave_absorption%b19_sfluxrefc = 0.0_real64
    state%shortwave_absorption%b20_ka = 0.0_real64
    state%shortwave_absorption%b20_kb = 0.0_real64
    state%shortwave_absorption%b20_ka_d = 0.0_real64
    state%shortwave_absorption%b20_kb_d = 0.0_real64
    state%shortwave_absorption%b20_selfref = 0.0_real64
    state%shortwave_absorption%b20_forref = 0.0_real64
    state%shortwave_absorption%b20_sfluxref = 0.0_real64
    state%shortwave_absorption%b20_absch4 = 0.0_real64
    state%shortwave_absorption%b20_rayl = 0.0_real64
    state%shortwave_absorption%b20_layreffr = 0_int32
    state%shortwave_absorption%b20_kac = 0.0_real64
    state%shortwave_absorption%b20_kbc = 0.0_real64
    state%shortwave_absorption%b20_selfrefc = 0.0_real64
    state%shortwave_absorption%b20_forrefc = 0.0_real64
    state%shortwave_absorption%b20_sfluxrefc = 0.0_real64
    state%shortwave_absorption%b20_absch4c = 0.0_real64
    state%shortwave_absorption%b21_ka = 0.0_real64
    state%shortwave_absorption%b21_kb = 0.0_real64
    state%shortwave_absorption%b21_ka_d = 0.0_real64
    state%shortwave_absorption%b21_kb_d = 0.0_real64
    state%shortwave_absorption%b21_selfref = 0.0_real64
    state%shortwave_absorption%b21_forref = 0.0_real64
    state%shortwave_absorption%b21_sfluxref = 0.0_real64
    state%shortwave_absorption%b21_rayl = 0.0_real64
    state%shortwave_absorption%b21_strrat = 0.0_real64
    state%shortwave_absorption%b21_layreffr = 0_int32
    state%shortwave_absorption%b21_kac = 0.0_real64
    state%shortwave_absorption%b21_kbc = 0.0_real64
    state%shortwave_absorption%b21_selfrefc = 0.0_real64
    state%shortwave_absorption%b21_forrefc = 0.0_real64
    state%shortwave_absorption%b21_sfluxrefc = 0.0_real64
    state%shortwave_absorption%b22_ka = 0.0_real64
    state%shortwave_absorption%b22_kb = 0.0_real64
    state%shortwave_absorption%b22_ka_d = 0.0_real64
    state%shortwave_absorption%b22_kb_d = 0.0_real64
    state%shortwave_absorption%b22_selfref = 0.0_real64
    state%shortwave_absorption%b22_forref = 0.0_real64
    state%shortwave_absorption%b22_sfluxref = 0.0_real64
    state%shortwave_absorption%b22_rayl = 0.0_real64
    state%shortwave_absorption%b22_strrat = 0.0_real64
    state%shortwave_absorption%b22_layreffr = 0_int32
    state%shortwave_absorption%b22_kac = 0.0_real64
    state%shortwave_absorption%b22_kbc = 0.0_real64
    state%shortwave_absorption%b22_selfrefc = 0.0_real64
    state%shortwave_absorption%b22_forrefc = 0.0_real64
    state%shortwave_absorption%b22_sfluxrefc = 0.0_real64
    state%shortwave_absorption%b23_ka = 0.0_real64
    state%shortwave_absorption%b23_ka_d = 0.0_real64
    state%shortwave_absorption%b23_selfref = 0.0_real64
    state%shortwave_absorption%b23_forref = 0.0_real64
    state%shortwave_absorption%b23_sfluxref = 0.0_real64
    state%shortwave_absorption%b23_rayl = 0.0_real64
    state%shortwave_absorption%b23_givfac = 0.0_real64
    state%shortwave_absorption%b23_layreffr = 0_int32
    state%shortwave_absorption%b23_kac = 0.0_real64
    state%shortwave_absorption%b23_selfrefc = 0.0_real64
    state%shortwave_absorption%b23_forrefc = 0.0_real64
    state%shortwave_absorption%b23_sfluxrefc = 0.0_real64
    state%shortwave_absorption%b23_raylc = 0.0_real64
    state%shortwave_absorption%b24_ka = 0.0_real64
    state%shortwave_absorption%b24_kb = 0.0_real64
    state%shortwave_absorption%b24_ka_d = 0.0_real64
    state%shortwave_absorption%b24_kb_d = 0.0_real64
    state%shortwave_absorption%b24_selfref = 0.0_real64
    state%shortwave_absorption%b24_forref = 0.0_real64
    state%shortwave_absorption%b24_sfluxref = 0.0_real64
    state%shortwave_absorption%b24_abso3a = 0.0_real64
    state%shortwave_absorption%b24_abso3b = 0.0_real64
    state%shortwave_absorption%b24_rayla = 0.0_real64
    state%shortwave_absorption%b24_raylb = 0.0_real64
    state%shortwave_absorption%b24_strrat = 0.0_real64
    state%shortwave_absorption%b24_layreffr = 0_int32
    state%shortwave_absorption%b24_kac = 0.0_real64
    state%shortwave_absorption%b24_kbc = 0.0_real64
    state%shortwave_absorption%b24_selfrefc = 0.0_real64
    state%shortwave_absorption%b24_forrefc = 0.0_real64
    state%shortwave_absorption%b24_sfluxrefc = 0.0_real64
    state%shortwave_absorption%b24_abso3ac = 0.0_real64
    state%shortwave_absorption%b24_abso3bc = 0.0_real64
    state%shortwave_absorption%b24_raylac = 0.0_real64
    state%shortwave_absorption%b24_raylbc = 0.0_real64
    state%shortwave_absorption%b25_ka = 0.0_real64
    state%shortwave_absorption%b25_ka_d = 0.0_real64
    state%shortwave_absorption%b25_sfluxref = 0.0_real64
    state%shortwave_absorption%b25_rayl = 0.0_real64
    state%shortwave_absorption%b25_abso3a = 0.0_real64
    state%shortwave_absorption%b25_abso3b = 0.0_real64
    state%shortwave_absorption%b25_layreffr = 0_int32
    state%shortwave_absorption%b25_kac = 0.0_real64
    state%shortwave_absorption%b25_sfluxrefc = 0.0_real64
    state%shortwave_absorption%b25_raylc = 0.0_real64
    state%shortwave_absorption%b25_abso3ac = 0.0_real64
    state%shortwave_absorption%b25_abso3bc = 0.0_real64
    state%shortwave_absorption%b26_sfluxref = 0.0_real64
    state%shortwave_absorption%b26_rayl = 0.0_real64
    state%shortwave_absorption%b26_sfluxrefc = 0.0_real64
    state%shortwave_absorption%b26_raylc = 0.0_real64
    state%shortwave_absorption%b27_ka = 0.0_real64
    state%shortwave_absorption%b27_kb = 0.0_real64
    state%shortwave_absorption%b27_ka_d = 0.0_real64
    state%shortwave_absorption%b27_kb_d = 0.0_real64
    state%shortwave_absorption%b27_sfluxref = 0.0_real64
    state%shortwave_absorption%b27_rayl = 0.0_real64
    state%shortwave_absorption%b27_scalekur = 0.0_real64
    state%shortwave_absorption%b27_layreffr = 0_int32
    state%shortwave_absorption%b27_kac = 0.0_real64
    state%shortwave_absorption%b27_kbc = 0.0_real64
    state%shortwave_absorption%b27_sfluxrefc = 0.0_real64
    state%shortwave_absorption%b27_raylc = 0.0_real64
    state%shortwave_absorption%b28_ka = 0.0_real64
    state%shortwave_absorption%b28_kb = 0.0_real64
    state%shortwave_absorption%b28_ka_d = 0.0_real64
    state%shortwave_absorption%b28_kb_d = 0.0_real64
    state%shortwave_absorption%b28_sfluxref = 0.0_real64
    state%shortwave_absorption%b28_rayl = 0.0_real64
    state%shortwave_absorption%b28_strrat = 0.0_real64
    state%shortwave_absorption%b28_layreffr = 0_int32
    state%shortwave_absorption%b28_kac = 0.0_real64
    state%shortwave_absorption%b28_kbc = 0.0_real64
    state%shortwave_absorption%b28_sfluxrefc = 0.0_real64
    state%shortwave_absorption%b29_ka = 0.0_real64
    state%shortwave_absorption%b29_kb = 0.0_real64
    state%shortwave_absorption%b29_ka_d = 0.0_real64
    state%shortwave_absorption%b29_kb_d = 0.0_real64
    state%shortwave_absorption%b29_selfref = 0.0_real64
    state%shortwave_absorption%b29_forref = 0.0_real64
    state%shortwave_absorption%b29_sfluxref = 0.0_real64
    state%shortwave_absorption%b29_absh2o = 0.0_real64
    state%shortwave_absorption%b29_absco2 = 0.0_real64
    state%shortwave_absorption%b29_rayl = 0.0_real64
    state%shortwave_absorption%b29_layreffr = 0_int32
    state%shortwave_absorption%b29_kac = 0.0_real64
    state%shortwave_absorption%b29_kbc = 0.0_real64
    state%shortwave_absorption%b29_selfrefc = 0.0_real64
    state%shortwave_absorption%b29_forrefc = 0.0_real64
    state%shortwave_absorption%b29_sfluxrefc = 0.0_real64
    state%shortwave_absorption%b29_absh2oc = 0.0_real64
    state%shortwave_absorption%b29_absco2c = 0.0_real64
    state%longwave_bands%mxixt = 0_int32
    state%longwave_bands%nsil = 0_int32
    state%longwave_bands%nipd = 0_int32
    state%longwave_bands%ntra = 0_int32
    state%longwave_bands%nua = 0_int32
    state%longwave_bands%ng1 = 0_int32
    state%longwave_bands%ng1p1 = 0_int32
    state%longwave_bands%alwt = 0.0_real64
    state%longwave_bands%blwt = 0.0_real64
    state%longwave_bands%pdga = 0.0_real64
    state%longwave_bands%pdgb = 0.0_real64
    state%longwave_bands%rptype = 0.0_real64
    state%longwave_bands%retype = 0.0_real64
    state%longwave_bands%ro1h = 0.0_real64
    state%longwave_bands%ro2h = 0.0_real64
    state%longwave_bands%ro3t = 0.0_real64
    state%longwave_bands%rpialf0 = 0.0_real64
    state%longwave_bands%rt1 = 0.0_real64
    state%longwave_bands%tintp = 0.0_real64
    state%longwave_bands%tref = 0.0_real64
    state%longwave_bands%tstand = 0.0_real64
    state%longwave_bands%tstp = 0.0_real64
    state%longwave_bands%wg1 = 0.0_real64
    state%longwave_bands%xp = 0.0_real64
    state%longwave_bands%rvgco2 = 0.0_real64
    state%longwave_bands%rvgh2o = 0.0_real64
    state%longwave_bands%rvgo3 = 0.0_real64
    status = 0
  end function
!> Borrow a complete named field by its frozen source-map index.
!! The caller keeps the actual TARGET owner alive. No scientific value is read.
  integer(int32) function get_owned_radiation_coefficient_field(state, index, field) result(status)
    type(owned_radiation_setup_state), target, intent(in) :: state
    integer(int32), intent(in) :: index
    type(native_radiation_namespace_field), intent(inout) :: field
    type(native_radiation_namespace_field) :: pending
    status = 2
    select case (index)
    case (1) ! __yoerrto1_MOD_fracrefao
      pending%address = c_loc(state%longwave_input%b1_fracrefao(lbound(state%longwave_input%b1_fracrefao, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_input%b1_fracrefao), int64)
      pending%upper(1:1) = int(ubound(state%longwave_input%b1_fracrefao), int64)
    case (2) ! __yoerrto1_MOD_fracrefbo
      pending%address = c_loc(state%longwave_input%b1_fracrefbo(lbound(state%longwave_input%b1_fracrefbo, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_input%b1_fracrefbo), int64)
      pending%upper(1:1) = int(ubound(state%longwave_input%b1_fracrefbo), int64)
    case (3) ! __yoerrto1_MOD_kao
pending%address=c_loc(state%longwave_input%b1_kao(lbound(state%longwave_input%b1_kao,1),lbound(state%longwave_input%b1_kao,2),lbound(state%longwave_input%b1_kao,3)))
      pending%bytes = 8320_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b1_kao), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b1_kao), int64)
    case (4) ! __yoerrto1_MOD_kbo
pending%address=c_loc(state%longwave_input%b1_kbo(lbound(state%longwave_input%b1_kbo,1),lbound(state%longwave_input%b1_kbo,2),lbound(state%longwave_input%b1_kbo,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b1_kbo), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b1_kbo), int64)
    case (5) ! __yoerrto1_MOD_kao_d
pending%address=c_loc(state%longwave_input%b1_kao_d(lbound(state%longwave_input%b1_kao_d,1),lbound(state%longwave_input%b1_kao_d,2),lbound(state%longwave_input%b1_kao_d,3)))
      pending%bytes = 8320_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b1_kao_d), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b1_kao_d), int64)
    case (6) ! __yoerrto1_MOD_kbo_d
pending%address=c_loc(state%longwave_input%b1_kbo_d(lbound(state%longwave_input%b1_kbo_d,1),lbound(state%longwave_input%b1_kbo_d,2),lbound(state%longwave_input%b1_kbo_d,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b1_kbo_d), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b1_kbo_d), int64)
    case (7) ! __yoerrto1_MOD_kao_mn2
pending%address=c_loc(state%longwave_input%b1_kao_mn2(lbound(state%longwave_input%b1_kao_mn2,1),lbound(state%longwave_input%b1_kao_mn2,2)))
      pending%bytes = 2432_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b1_kao_mn2), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b1_kao_mn2), int64)
    case (8) ! __yoerrto1_MOD_kbo_mn2
pending%address=c_loc(state%longwave_input%b1_kbo_mn2(lbound(state%longwave_input%b1_kbo_mn2,1),lbound(state%longwave_input%b1_kbo_mn2,2)))
      pending%bytes = 2432_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b1_kbo_mn2), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b1_kbo_mn2), int64)
    case (9) ! __yoerrto1_MOD_selfrefo
pending%address=c_loc(state%longwave_input%b1_selfrefo(lbound(state%longwave_input%b1_selfrefo,1),lbound(state%longwave_input%b1_selfrefo,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b1_selfrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b1_selfrefo), int64)
    case (10) ! __yoerrto1_MOD_forrefo
pending%address=c_loc(state%longwave_input%b1_forrefo(lbound(state%longwave_input%b1_forrefo,1),lbound(state%longwave_input%b1_forrefo,2)))
      pending%bytes = 512_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b1_forrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b1_forrefo), int64)
    case (11) ! __yoerrto2_MOD_fracrefao
      pending%address = c_loc(state%longwave_input%b2_fracrefao(lbound(state%longwave_input%b2_fracrefao, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_input%b2_fracrefao), int64)
      pending%upper(1:1) = int(ubound(state%longwave_input%b2_fracrefao), int64)
    case (12) ! __yoerrto2_MOD_fracrefbo
      pending%address = c_loc(state%longwave_input%b2_fracrefbo(lbound(state%longwave_input%b2_fracrefbo, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_input%b2_fracrefbo), int64)
      pending%upper(1:1) = int(ubound(state%longwave_input%b2_fracrefbo), int64)
    case (13) ! __yoerrto2_MOD_kao
pending%address=c_loc(state%longwave_input%b2_kao(lbound(state%longwave_input%b2_kao,1),lbound(state%longwave_input%b2_kao,2),lbound(state%longwave_input%b2_kao,3)))
      pending%bytes = 8320_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b2_kao), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b2_kao), int64)
    case (14) ! __yoerrto2_MOD_kbo
pending%address=c_loc(state%longwave_input%b2_kbo(lbound(state%longwave_input%b2_kbo,1),lbound(state%longwave_input%b2_kbo,2),lbound(state%longwave_input%b2_kbo,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b2_kbo), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b2_kbo), int64)
    case (15) ! __yoerrto2_MOD_kao_d
pending%address=c_loc(state%longwave_input%b2_kao_d(lbound(state%longwave_input%b2_kao_d,1),lbound(state%longwave_input%b2_kao_d,2),lbound(state%longwave_input%b2_kao_d,3)))
      pending%bytes = 8320_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b2_kao_d), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b2_kao_d), int64)
    case (16) ! __yoerrto2_MOD_kbo_d
pending%address=c_loc(state%longwave_input%b2_kbo_d(lbound(state%longwave_input%b2_kbo_d,1),lbound(state%longwave_input%b2_kbo_d,2),lbound(state%longwave_input%b2_kbo_d,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b2_kbo_d), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b2_kbo_d), int64)
    case (17) ! __yoerrto2_MOD_selfrefo
pending%address=c_loc(state%longwave_input%b2_selfrefo(lbound(state%longwave_input%b2_selfrefo,1),lbound(state%longwave_input%b2_selfrefo,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b2_selfrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b2_selfrefo), int64)
    case (18) ! __yoerrto2_MOD_forrefo
pending%address=c_loc(state%longwave_input%b2_forrefo(lbound(state%longwave_input%b2_forrefo,1),lbound(state%longwave_input%b2_forrefo,2)))
      pending%bytes = 512_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b2_forrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b2_forrefo), int64)
    case (19) ! __yoerrto3_MOD_fracrefao
pending%address=c_loc(state%longwave_input%b3_fracrefao(lbound(state%longwave_input%b3_fracrefao,1),lbound(state%longwave_input%b3_fracrefao,2)))
      pending%bytes = 1152_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b3_fracrefao), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b3_fracrefao), int64)
    case (20) ! __yoerrto3_MOD_fracrefbo
pending%address=c_loc(state%longwave_input%b3_fracrefbo(lbound(state%longwave_input%b3_fracrefbo,1),lbound(state%longwave_input%b3_fracrefbo,2)))
      pending%bytes = 640_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b3_fracrefbo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b3_fracrefbo), int64)
    case (21) ! __yoerrto3_MOD_kao_mn2o
pending%address=c_loc(state%longwave_input%b3_kao_mn2o(lbound(state%longwave_input%b3_kao_mn2o,1),lbound(state%longwave_input%b3_kao_mn2o,2),lbound(state%longwave_input%b3_kao_mn2o,3)))
      pending%bytes = 21888_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b3_kao_mn2o), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b3_kao_mn2o), int64)
    case (22) ! __yoerrto3_MOD_kbo_mn2o
pending%address=c_loc(state%longwave_input%b3_kbo_mn2o(lbound(state%longwave_input%b3_kbo_mn2o,1),lbound(state%longwave_input%b3_kbo_mn2o,2),lbound(state%longwave_input%b3_kbo_mn2o,3)))
      pending%bytes = 12160_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b3_kbo_mn2o), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b3_kbo_mn2o), int64)
    case (23) ! __yoerrto3_MOD_kao
pending%address=c_loc(state%longwave_input%b3_kao(lbound(state%longwave_input%b3_kao,1),lbound(state%longwave_input%b3_kao,2),lbound(state%longwave_input%b3_kao,3),lbound(state%longwave_input%b3_kao,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_input%b3_kao), int64)
      pending%upper(1:4) = int(ubound(state%longwave_input%b3_kao), int64)
    case (24) ! __yoerrto3_MOD_kbo
pending%address=c_loc(state%longwave_input%b3_kbo(lbound(state%longwave_input%b3_kbo,1),lbound(state%longwave_input%b3_kbo,2),lbound(state%longwave_input%b3_kbo,3),lbound(state%longwave_input%b3_kbo,4)))
      pending%bytes = 150400_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_input%b3_kbo), int64)
      pending%upper(1:4) = int(ubound(state%longwave_input%b3_kbo), int64)
    case (25) ! __yoerrto3_MOD_kao_d
pending%address=c_loc(state%longwave_input%b3_kao_d(lbound(state%longwave_input%b3_kao_d,1),lbound(state%longwave_input%b3_kao_d,2),lbound(state%longwave_input%b3_kao_d,3),lbound(state%longwave_input%b3_kao_d,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_input%b3_kao_d), int64)
      pending%upper(1:4) = int(ubound(state%longwave_input%b3_kao_d), int64)
    case (26) ! __yoerrto3_MOD_kbo_d
pending%address=c_loc(state%longwave_input%b3_kbo_d(lbound(state%longwave_input%b3_kbo_d,1),lbound(state%longwave_input%b3_kbo_d,2),lbound(state%longwave_input%b3_kbo_d,3),lbound(state%longwave_input%b3_kbo_d,4)))
      pending%bytes = 150400_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_input%b3_kbo_d), int64)
      pending%upper(1:4) = int(ubound(state%longwave_input%b3_kbo_d), int64)
    case (27) ! __yoerrto3_MOD_selfrefo
pending%address=c_loc(state%longwave_input%b3_selfrefo(lbound(state%longwave_input%b3_selfrefo,1),lbound(state%longwave_input%b3_selfrefo,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b3_selfrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b3_selfrefo), int64)
    case (28) ! __yoerrto3_MOD_forrefo
pending%address=c_loc(state%longwave_input%b3_forrefo(lbound(state%longwave_input%b3_forrefo,1),lbound(state%longwave_input%b3_forrefo,2)))
      pending%bytes = 512_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b3_forrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b3_forrefo), int64)
    case (29) ! __yoerrto4_MOD_fracrefao
pending%address=c_loc(state%longwave_input%b4_fracrefao(lbound(state%longwave_input%b4_fracrefao,1),lbound(state%longwave_input%b4_fracrefao,2)))
      pending%bytes = 1152_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b4_fracrefao), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b4_fracrefao), int64)
    case (30) ! __yoerrto4_MOD_fracrefbo
pending%address=c_loc(state%longwave_input%b4_fracrefbo(lbound(state%longwave_input%b4_fracrefbo,1),lbound(state%longwave_input%b4_fracrefbo,2)))
      pending%bytes = 640_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b4_fracrefbo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b4_fracrefbo), int64)
    case (31) ! __yoerrto4_MOD_kao
pending%address=c_loc(state%longwave_input%b4_kao(lbound(state%longwave_input%b4_kao,1),lbound(state%longwave_input%b4_kao,2),lbound(state%longwave_input%b4_kao,3),lbound(state%longwave_input%b4_kao,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_input%b4_kao), int64)
      pending%upper(1:4) = int(ubound(state%longwave_input%b4_kao), int64)
    case (32) ! __yoerrto4_MOD_kbo
pending%address=c_loc(state%longwave_input%b4_kbo(lbound(state%longwave_input%b4_kbo,1),lbound(state%longwave_input%b4_kbo,2),lbound(state%longwave_input%b4_kbo,3),lbound(state%longwave_input%b4_kbo,4)))
      pending%bytes = 150400_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_input%b4_kbo), int64)
      pending%upper(1:4) = int(ubound(state%longwave_input%b4_kbo), int64)
    case (33) ! __yoerrto4_MOD_kao_d
pending%address=c_loc(state%longwave_input%b4_kao_d(lbound(state%longwave_input%b4_kao_d,1),lbound(state%longwave_input%b4_kao_d,2),lbound(state%longwave_input%b4_kao_d,3),lbound(state%longwave_input%b4_kao_d,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_input%b4_kao_d), int64)
      pending%upper(1:4) = int(ubound(state%longwave_input%b4_kao_d), int64)
    case (34) ! __yoerrto4_MOD_kbo_d
pending%address=c_loc(state%longwave_input%b4_kbo_d(lbound(state%longwave_input%b4_kbo_d,1),lbound(state%longwave_input%b4_kbo_d,2),lbound(state%longwave_input%b4_kbo_d,3),lbound(state%longwave_input%b4_kbo_d,4)))
      pending%bytes = 150400_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_input%b4_kbo_d), int64)
      pending%upper(1:4) = int(ubound(state%longwave_input%b4_kbo_d), int64)
    case (35) ! __yoerrto4_MOD_selfrefo
pending%address=c_loc(state%longwave_input%b4_selfrefo(lbound(state%longwave_input%b4_selfrefo,1),lbound(state%longwave_input%b4_selfrefo,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b4_selfrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b4_selfrefo), int64)
    case (36) ! __yoerrto4_MOD_forrefo
pending%address=c_loc(state%longwave_input%b4_forrefo(lbound(state%longwave_input%b4_forrefo,1),lbound(state%longwave_input%b4_forrefo,2)))
      pending%bytes = 512_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b4_forrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b4_forrefo), int64)
    case (37) ! __yoerrto5_MOD_fracrefao
pending%address=c_loc(state%longwave_input%b5_fracrefao(lbound(state%longwave_input%b5_fracrefao,1),lbound(state%longwave_input%b5_fracrefao,2)))
      pending%bytes = 1152_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b5_fracrefao), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b5_fracrefao), int64)
    case (38) ! __yoerrto5_MOD_fracrefbo
pending%address=c_loc(state%longwave_input%b5_fracrefbo(lbound(state%longwave_input%b5_fracrefbo,1),lbound(state%longwave_input%b5_fracrefbo,2)))
      pending%bytes = 640_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b5_fracrefbo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b5_fracrefbo), int64)
    case (39) ! __yoerrto5_MOD_ccl4o
      pending%address = c_loc(state%longwave_input%b5_ccl4o(lbound(state%longwave_input%b5_ccl4o, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_input%b5_ccl4o), int64)
      pending%upper(1:1) = int(ubound(state%longwave_input%b5_ccl4o), int64)
    case (40) ! __yoerrto5_MOD_kao_mo3
pending%address=c_loc(state%longwave_input%b5_kao_mo3(lbound(state%longwave_input%b5_kao_mo3,1),lbound(state%longwave_input%b5_kao_mo3,2),lbound(state%longwave_input%b5_kao_mo3,3)))
      pending%bytes = 21888_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b5_kao_mo3), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b5_kao_mo3), int64)
    case (41) ! __yoerrto5_MOD_kao
pending%address=c_loc(state%longwave_input%b5_kao(lbound(state%longwave_input%b5_kao,1),lbound(state%longwave_input%b5_kao,2),lbound(state%longwave_input%b5_kao,3),lbound(state%longwave_input%b5_kao,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_input%b5_kao), int64)
      pending%upper(1:4) = int(ubound(state%longwave_input%b5_kao), int64)
    case (42) ! __yoerrto5_MOD_kbo
pending%address=c_loc(state%longwave_input%b5_kbo(lbound(state%longwave_input%b5_kbo,1),lbound(state%longwave_input%b5_kbo,2),lbound(state%longwave_input%b5_kbo,3),lbound(state%longwave_input%b5_kbo,4)))
      pending%bytes = 150400_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_input%b5_kbo), int64)
      pending%upper(1:4) = int(ubound(state%longwave_input%b5_kbo), int64)
    case (43) ! __yoerrto5_MOD_kao_d
pending%address=c_loc(state%longwave_input%b5_kao_d(lbound(state%longwave_input%b5_kao_d,1),lbound(state%longwave_input%b5_kao_d,2),lbound(state%longwave_input%b5_kao_d,3),lbound(state%longwave_input%b5_kao_d,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_input%b5_kao_d), int64)
      pending%upper(1:4) = int(ubound(state%longwave_input%b5_kao_d), int64)
    case (44) ! __yoerrto5_MOD_kbo_d
pending%address=c_loc(state%longwave_input%b5_kbo_d(lbound(state%longwave_input%b5_kbo_d,1),lbound(state%longwave_input%b5_kbo_d,2),lbound(state%longwave_input%b5_kbo_d,3),lbound(state%longwave_input%b5_kbo_d,4)))
      pending%bytes = 150400_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_input%b5_kbo_d), int64)
      pending%upper(1:4) = int(ubound(state%longwave_input%b5_kbo_d), int64)
    case (45) ! __yoerrto5_MOD_selfrefo
pending%address=c_loc(state%longwave_input%b5_selfrefo(lbound(state%longwave_input%b5_selfrefo,1),lbound(state%longwave_input%b5_selfrefo,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b5_selfrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b5_selfrefo), int64)
    case (46) ! __yoerrto5_MOD_forrefo
pending%address=c_loc(state%longwave_input%b5_forrefo(lbound(state%longwave_input%b5_forrefo,1),lbound(state%longwave_input%b5_forrefo,2)))
      pending%bytes = 512_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b5_forrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b5_forrefo), int64)
    case (47) ! __yoerrto6_MOD_fracrefao
      pending%address = c_loc(state%longwave_input%b6_fracrefao(lbound(state%longwave_input%b6_fracrefao, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_input%b6_fracrefao), int64)
      pending%upper(1:1) = int(ubound(state%longwave_input%b6_fracrefao), int64)
    case (48) ! __yoerrto6_MOD_cfc11adjo
      pending%address = c_loc(state%longwave_input%b6_cfc11adjo(lbound(state%longwave_input%b6_cfc11adjo, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_input%b6_cfc11adjo), int64)
      pending%upper(1:1) = int(ubound(state%longwave_input%b6_cfc11adjo), int64)
    case (49) ! __yoerrto6_MOD_cfc12o
      pending%address = c_loc(state%longwave_input%b6_cfc12o(lbound(state%longwave_input%b6_cfc12o, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_input%b6_cfc12o), int64)
      pending%upper(1:1) = int(ubound(state%longwave_input%b6_cfc12o), int64)
    case (50) ! __yoerrto6_MOD_kao
pending%address=c_loc(state%longwave_input%b6_kao(lbound(state%longwave_input%b6_kao,1),lbound(state%longwave_input%b6_kao,2),lbound(state%longwave_input%b6_kao,3)))
      pending%bytes = 8320_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b6_kao), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b6_kao), int64)
    case (51) ! __yoerrto6_MOD_kao_d
pending%address=c_loc(state%longwave_input%b6_kao_d(lbound(state%longwave_input%b6_kao_d,1),lbound(state%longwave_input%b6_kao_d,2),lbound(state%longwave_input%b6_kao_d,3)))
      pending%bytes = 8320_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b6_kao_d), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b6_kao_d), int64)
    case (52) ! __yoerrto6_MOD_selfrefo
pending%address=c_loc(state%longwave_input%b6_selfrefo(lbound(state%longwave_input%b6_selfrefo,1),lbound(state%longwave_input%b6_selfrefo,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b6_selfrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b6_selfrefo), int64)
    case (53) ! __yoerrto6_MOD_kao_mco2
pending%address=c_loc(state%longwave_input%b6_kao_mco2(lbound(state%longwave_input%b6_kao_mco2,1),lbound(state%longwave_input%b6_kao_mco2,2)))
      pending%bytes = 2432_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b6_kao_mco2), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b6_kao_mco2), int64)
    case (54) ! __yoerrto6_MOD_forrefo
pending%address=c_loc(state%longwave_input%b6_forrefo(lbound(state%longwave_input%b6_forrefo,1),lbound(state%longwave_input%b6_forrefo,2)))
      pending%bytes = 512_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b6_forrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b6_forrefo), int64)
    case (55) ! __yoerrto7_MOD_fracrefao
pending%address=c_loc(state%longwave_input%b7_fracrefao(lbound(state%longwave_input%b7_fracrefao,1),lbound(state%longwave_input%b7_fracrefao,2)))
      pending%bytes = 1152_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b7_fracrefao), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b7_fracrefao), int64)
    case (56) ! __yoerrto7_MOD_fracrefbo
      pending%address = c_loc(state%longwave_input%b7_fracrefbo(lbound(state%longwave_input%b7_fracrefbo, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_input%b7_fracrefbo), int64)
      pending%upper(1:1) = int(ubound(state%longwave_input%b7_fracrefbo), int64)
    case (57) ! __yoerrto7_MOD_kao
pending%address=c_loc(state%longwave_input%b7_kao(lbound(state%longwave_input%b7_kao,1),lbound(state%longwave_input%b7_kao,2),lbound(state%longwave_input%b7_kao,3),lbound(state%longwave_input%b7_kao,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_input%b7_kao), int64)
      pending%upper(1:4) = int(ubound(state%longwave_input%b7_kao), int64)
    case (58) ! __yoerrto7_MOD_kbo
pending%address=c_loc(state%longwave_input%b7_kbo(lbound(state%longwave_input%b7_kbo,1),lbound(state%longwave_input%b7_kbo,2),lbound(state%longwave_input%b7_kbo,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b7_kbo), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b7_kbo), int64)
    case (59) ! __yoerrto7_MOD_kao_d
pending%address=c_loc(state%longwave_input%b7_kao_d(lbound(state%longwave_input%b7_kao_d,1),lbound(state%longwave_input%b7_kao_d,2),lbound(state%longwave_input%b7_kao_d,3),lbound(state%longwave_input%b7_kao_d,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_input%b7_kao_d), int64)
      pending%upper(1:4) = int(ubound(state%longwave_input%b7_kao_d), int64)
    case (60) ! __yoerrto7_MOD_kbo_d
pending%address=c_loc(state%longwave_input%b7_kbo_d(lbound(state%longwave_input%b7_kbo_d,1),lbound(state%longwave_input%b7_kbo_d,2),lbound(state%longwave_input%b7_kbo_d,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b7_kbo_d), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b7_kbo_d), int64)
    case (61) ! __yoerrto7_MOD_selfrefo
pending%address=c_loc(state%longwave_input%b7_selfrefo(lbound(state%longwave_input%b7_selfrefo,1),lbound(state%longwave_input%b7_selfrefo,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b7_selfrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b7_selfrefo), int64)
    case (62) ! __yoerrto7_MOD_kao_mco2
pending%address=c_loc(state%longwave_input%b7_kao_mco2(lbound(state%longwave_input%b7_kao_mco2,1),lbound(state%longwave_input%b7_kao_mco2,2),lbound(state%longwave_input%b7_kao_mco2,3)))
      pending%bytes = 21888_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b7_kao_mco2), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b7_kao_mco2), int64)
    case (63) ! __yoerrto7_MOD_kbo_mco2
pending%address=c_loc(state%longwave_input%b7_kbo_mco2(lbound(state%longwave_input%b7_kbo_mco2,1),lbound(state%longwave_input%b7_kbo_mco2,2)))
      pending%bytes = 2432_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b7_kbo_mco2), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b7_kbo_mco2), int64)
    case (64) ! __yoerrto7_MOD_forrefo
pending%address=c_loc(state%longwave_input%b7_forrefo(lbound(state%longwave_input%b7_forrefo,1),lbound(state%longwave_input%b7_forrefo,2)))
      pending%bytes = 512_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b7_forrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b7_forrefo), int64)
    case (65) ! __yoerrto8_MOD_fracrefao
      pending%address = c_loc(state%longwave_input%b8_fracrefao(lbound(state%longwave_input%b8_fracrefao, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_input%b8_fracrefao), int64)
      pending%upper(1:1) = int(ubound(state%longwave_input%b8_fracrefao), int64)
    case (66) ! __yoerrto8_MOD_fracrefbo
      pending%address = c_loc(state%longwave_input%b8_fracrefbo(lbound(state%longwave_input%b8_fracrefbo, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_input%b8_fracrefbo), int64)
      pending%upper(1:1) = int(ubound(state%longwave_input%b8_fracrefbo), int64)
    case (67) ! __yoerrto8_MOD_cfc12o
      pending%address = c_loc(state%longwave_input%b8_cfc12o(lbound(state%longwave_input%b8_cfc12o, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_input%b8_cfc12o), int64)
      pending%upper(1:1) = int(ubound(state%longwave_input%b8_cfc12o), int64)
    case (68) ! __yoerrto8_MOD_cfc22adjo
      pending%address = c_loc(state%longwave_input%b8_cfc22adjo(lbound(state%longwave_input%b8_cfc22adjo, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_input%b8_cfc22adjo), int64)
      pending%upper(1:1) = int(ubound(state%longwave_input%b8_cfc22adjo), int64)
    case (69) ! __yoerrto8_MOD_kao
pending%address=c_loc(state%longwave_input%b8_kao(lbound(state%longwave_input%b8_kao,1),lbound(state%longwave_input%b8_kao,2),lbound(state%longwave_input%b8_kao,3)))
      pending%bytes = 8320_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b8_kao), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b8_kao), int64)
    case (70) ! __yoerrto8_MOD_kbo
pending%address=c_loc(state%longwave_input%b8_kbo(lbound(state%longwave_input%b8_kbo,1),lbound(state%longwave_input%b8_kbo,2),lbound(state%longwave_input%b8_kbo,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b8_kbo), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b8_kbo), int64)
    case (71) ! __yoerrto8_MOD_kao_d
pending%address=c_loc(state%longwave_input%b8_kao_d(lbound(state%longwave_input%b8_kao_d,1),lbound(state%longwave_input%b8_kao_d,2),lbound(state%longwave_input%b8_kao_d,3)))
      pending%bytes = 8320_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b8_kao_d), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b8_kao_d), int64)
    case (72) ! __yoerrto8_MOD_kbo_d
pending%address=c_loc(state%longwave_input%b8_kbo_d(lbound(state%longwave_input%b8_kbo_d,1),lbound(state%longwave_input%b8_kbo_d,2),lbound(state%longwave_input%b8_kbo_d,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b8_kbo_d), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b8_kbo_d), int64)
    case (73) ! __yoerrto8_MOD_selfrefo
pending%address=c_loc(state%longwave_input%b8_selfrefo(lbound(state%longwave_input%b8_selfrefo,1),lbound(state%longwave_input%b8_selfrefo,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b8_selfrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b8_selfrefo), int64)
    case (74) ! __yoerrto8_MOD_kao_mco2
pending%address=c_loc(state%longwave_input%b8_kao_mco2(lbound(state%longwave_input%b8_kao_mco2,1),lbound(state%longwave_input%b8_kao_mco2,2)))
      pending%bytes = 2432_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b8_kao_mco2), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b8_kao_mco2), int64)
    case (75) ! __yoerrto8_MOD_kao_mn2o
pending%address=c_loc(state%longwave_input%b8_kao_mn2o(lbound(state%longwave_input%b8_kao_mn2o,1),lbound(state%longwave_input%b8_kao_mn2o,2)))
      pending%bytes = 2432_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b8_kao_mn2o), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b8_kao_mn2o), int64)
    case (76) ! __yoerrto8_MOD_kao_mo3
pending%address=c_loc(state%longwave_input%b8_kao_mo3(lbound(state%longwave_input%b8_kao_mo3,1),lbound(state%longwave_input%b8_kao_mo3,2)))
      pending%bytes = 2432_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b8_kao_mo3), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b8_kao_mo3), int64)
    case (77) ! __yoerrto8_MOD_kbo_mco2
pending%address=c_loc(state%longwave_input%b8_kbo_mco2(lbound(state%longwave_input%b8_kbo_mco2,1),lbound(state%longwave_input%b8_kbo_mco2,2)))
      pending%bytes = 2432_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b8_kbo_mco2), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b8_kbo_mco2), int64)
    case (78) ! __yoerrto8_MOD_kbo_mn2o
pending%address=c_loc(state%longwave_input%b8_kbo_mn2o(lbound(state%longwave_input%b8_kbo_mn2o,1),lbound(state%longwave_input%b8_kbo_mn2o,2)))
      pending%bytes = 2432_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b8_kbo_mn2o), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b8_kbo_mn2o), int64)
    case (79) ! __yoerrto8_MOD_forrefo
pending%address=c_loc(state%longwave_input%b8_forrefo(lbound(state%longwave_input%b8_forrefo,1),lbound(state%longwave_input%b8_forrefo,2)))
      pending%bytes = 512_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b8_forrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b8_forrefo), int64)
    case (80) ! __yoerrto9_MOD_fracrefao
pending%address=c_loc(state%longwave_input%b9_fracrefao(lbound(state%longwave_input%b9_fracrefao,1),lbound(state%longwave_input%b9_fracrefao,2)))
      pending%bytes = 1152_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b9_fracrefao), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b9_fracrefao), int64)
    case (81) ! __yoerrto9_MOD_fracrefbo
      pending%address = c_loc(state%longwave_input%b9_fracrefbo(lbound(state%longwave_input%b9_fracrefbo, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_input%b9_fracrefbo), int64)
      pending%upper(1:1) = int(ubound(state%longwave_input%b9_fracrefbo), int64)
    case (82) ! __yoerrto9_MOD_kao
pending%address=c_loc(state%longwave_input%b9_kao(lbound(state%longwave_input%b9_kao,1),lbound(state%longwave_input%b9_kao,2),lbound(state%longwave_input%b9_kao,3),lbound(state%longwave_input%b9_kao,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_input%b9_kao), int64)
      pending%upper(1:4) = int(ubound(state%longwave_input%b9_kao), int64)
    case (83) ! __yoerrto9_MOD_kbo
pending%address=c_loc(state%longwave_input%b9_kbo(lbound(state%longwave_input%b9_kbo,1),lbound(state%longwave_input%b9_kbo,2),lbound(state%longwave_input%b9_kbo,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b9_kbo), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b9_kbo), int64)
    case (84) ! __yoerrto9_MOD_kao_d
pending%address=c_loc(state%longwave_input%b9_kao_d(lbound(state%longwave_input%b9_kao_d,1),lbound(state%longwave_input%b9_kao_d,2),lbound(state%longwave_input%b9_kao_d,3),lbound(state%longwave_input%b9_kao_d,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_input%b9_kao_d), int64)
      pending%upper(1:4) = int(ubound(state%longwave_input%b9_kao_d), int64)
    case (85) ! __yoerrto9_MOD_kbo_d
pending%address=c_loc(state%longwave_input%b9_kbo_d(lbound(state%longwave_input%b9_kbo_d,1),lbound(state%longwave_input%b9_kbo_d,2),lbound(state%longwave_input%b9_kbo_d,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b9_kbo_d), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b9_kbo_d), int64)
    case (86) ! __yoerrto9_MOD_kao_mn2o
pending%address=c_loc(state%longwave_input%b9_kao_mn2o(lbound(state%longwave_input%b9_kao_mn2o,1),lbound(state%longwave_input%b9_kao_mn2o,2),lbound(state%longwave_input%b9_kao_mn2o,3)))
      pending%bytes = 21888_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b9_kao_mn2o), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b9_kao_mn2o), int64)
    case (87) ! __yoerrto9_MOD_kbo_mn2o
pending%address=c_loc(state%longwave_input%b9_kbo_mn2o(lbound(state%longwave_input%b9_kbo_mn2o,1),lbound(state%longwave_input%b9_kbo_mn2o,2)))
      pending%bytes = 2432_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b9_kbo_mn2o), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b9_kbo_mn2o), int64)
    case (88) ! __yoerrto9_MOD_selfrefo
pending%address=c_loc(state%longwave_input%b9_selfrefo(lbound(state%longwave_input%b9_selfrefo,1),lbound(state%longwave_input%b9_selfrefo,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b9_selfrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b9_selfrefo), int64)
    case (89) ! __yoerrto9_MOD_forrefo
pending%address=c_loc(state%longwave_input%b9_forrefo(lbound(state%longwave_input%b9_forrefo,1),lbound(state%longwave_input%b9_forrefo,2)))
      pending%bytes = 512_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b9_forrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b9_forrefo), int64)
    case (90) ! __yoerrto10_MOD_fracrefao
      pending%address = c_loc(state%longwave_input%b10_fracrefao(lbound(state%longwave_input%b10_fracrefao, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_input%b10_fracrefao), int64)
      pending%upper(1:1) = int(ubound(state%longwave_input%b10_fracrefao), int64)
    case (91) ! __yoerrto10_MOD_fracrefbo
      pending%address = c_loc(state%longwave_input%b10_fracrefbo(lbound(state%longwave_input%b10_fracrefbo, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_input%b10_fracrefbo), int64)
      pending%upper(1:1) = int(ubound(state%longwave_input%b10_fracrefbo), int64)
    case (92) ! __yoerrto10_MOD_kao
pending%address=c_loc(state%longwave_input%b10_kao(lbound(state%longwave_input%b10_kao,1),lbound(state%longwave_input%b10_kao,2),lbound(state%longwave_input%b10_kao,3)))
      pending%bytes = 8320_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b10_kao), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b10_kao), int64)
    case (93) ! __yoerrto10_MOD_kbo
pending%address=c_loc(state%longwave_input%b10_kbo(lbound(state%longwave_input%b10_kbo,1),lbound(state%longwave_input%b10_kbo,2),lbound(state%longwave_input%b10_kbo,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b10_kbo), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b10_kbo), int64)
    case (94) ! __yoerrto10_MOD_kao_d
pending%address=c_loc(state%longwave_input%b10_kao_d(lbound(state%longwave_input%b10_kao_d,1),lbound(state%longwave_input%b10_kao_d,2),lbound(state%longwave_input%b10_kao_d,3)))
      pending%bytes = 8320_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b10_kao_d), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b10_kao_d), int64)
    case (95) ! __yoerrto10_MOD_kbo_d
pending%address=c_loc(state%longwave_input%b10_kbo_d(lbound(state%longwave_input%b10_kbo_d,1),lbound(state%longwave_input%b10_kbo_d,2),lbound(state%longwave_input%b10_kbo_d,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b10_kbo_d), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b10_kbo_d), int64)
    case (96) ! __yoerrto10_MOD_selfrefo
pending%address=c_loc(state%longwave_input%b10_selfrefo(lbound(state%longwave_input%b10_selfrefo,1),lbound(state%longwave_input%b10_selfrefo,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b10_selfrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b10_selfrefo), int64)
    case (97) ! __yoerrto10_MOD_forrefo
pending%address=c_loc(state%longwave_input%b10_forrefo(lbound(state%longwave_input%b10_forrefo,1),lbound(state%longwave_input%b10_forrefo,2)))
      pending%bytes = 512_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b10_forrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b10_forrefo), int64)
    case (98) ! __yoerrto11_MOD_fracrefao
      pending%address = c_loc(state%longwave_input%b11_fracrefao(lbound(state%longwave_input%b11_fracrefao, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_input%b11_fracrefao), int64)
      pending%upper(1:1) = int(ubound(state%longwave_input%b11_fracrefao), int64)
    case (99) ! __yoerrto11_MOD_fracrefbo
      pending%address = c_loc(state%longwave_input%b11_fracrefbo(lbound(state%longwave_input%b11_fracrefbo, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_input%b11_fracrefbo), int64)
      pending%upper(1:1) = int(ubound(state%longwave_input%b11_fracrefbo), int64)
    case (100) ! __yoerrto11_MOD_kao
pending%address=c_loc(state%longwave_input%b11_kao(lbound(state%longwave_input%b11_kao,1),lbound(state%longwave_input%b11_kao,2),lbound(state%longwave_input%b11_kao,3)))
      pending%bytes = 8320_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b11_kao), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b11_kao), int64)
    case (101) ! __yoerrto11_MOD_kbo
pending%address=c_loc(state%longwave_input%b11_kbo(lbound(state%longwave_input%b11_kbo,1),lbound(state%longwave_input%b11_kbo,2),lbound(state%longwave_input%b11_kbo,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b11_kbo), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b11_kbo), int64)
    case (102) ! __yoerrto11_MOD_kao_d
pending%address=c_loc(state%longwave_input%b11_kao_d(lbound(state%longwave_input%b11_kao_d,1),lbound(state%longwave_input%b11_kao_d,2),lbound(state%longwave_input%b11_kao_d,3)))
      pending%bytes = 8320_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b11_kao_d), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b11_kao_d), int64)
    case (103) ! __yoerrto11_MOD_kbo_d
pending%address=c_loc(state%longwave_input%b11_kbo_d(lbound(state%longwave_input%b11_kbo_d,1),lbound(state%longwave_input%b11_kbo_d,2),lbound(state%longwave_input%b11_kbo_d,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b11_kbo_d), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b11_kbo_d), int64)
    case (104) ! __yoerrto11_MOD_kao_mo2
pending%address=c_loc(state%longwave_input%b11_kao_mo2(lbound(state%longwave_input%b11_kao_mo2,1),lbound(state%longwave_input%b11_kao_mo2,2)))
      pending%bytes = 2432_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b11_kao_mo2), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b11_kao_mo2), int64)
    case (105) ! __yoerrto11_MOD_kbo_mo2
pending%address=c_loc(state%longwave_input%b11_kbo_mo2(lbound(state%longwave_input%b11_kbo_mo2,1),lbound(state%longwave_input%b11_kbo_mo2,2)))
      pending%bytes = 2432_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b11_kbo_mo2), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b11_kbo_mo2), int64)
    case (106) ! __yoerrto11_MOD_selfrefo
pending%address=c_loc(state%longwave_input%b11_selfrefo(lbound(state%longwave_input%b11_selfrefo,1),lbound(state%longwave_input%b11_selfrefo,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b11_selfrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b11_selfrefo), int64)
    case (107) ! __yoerrto11_MOD_forrefo
pending%address=c_loc(state%longwave_input%b11_forrefo(lbound(state%longwave_input%b11_forrefo,1),lbound(state%longwave_input%b11_forrefo,2)))
      pending%bytes = 512_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b11_forrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b11_forrefo), int64)
    case (108) ! __yoerrto12_MOD_fracrefao
pending%address=c_loc(state%longwave_input%b12_fracrefao(lbound(state%longwave_input%b12_fracrefao,1),lbound(state%longwave_input%b12_fracrefao,2)))
      pending%bytes = 1152_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b12_fracrefao), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b12_fracrefao), int64)
    case (109) ! __yoerrto12_MOD_kao
pending%address=c_loc(state%longwave_input%b12_kao(lbound(state%longwave_input%b12_kao,1),lbound(state%longwave_input%b12_kao,2),lbound(state%longwave_input%b12_kao,3),lbound(state%longwave_input%b12_kao,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_input%b12_kao), int64)
      pending%upper(1:4) = int(ubound(state%longwave_input%b12_kao), int64)
    case (110) ! __yoerrto12_MOD_kao_d
pending%address=c_loc(state%longwave_input%b12_kao_d(lbound(state%longwave_input%b12_kao_d,1),lbound(state%longwave_input%b12_kao_d,2),lbound(state%longwave_input%b12_kao_d,3),lbound(state%longwave_input%b12_kao_d,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_input%b12_kao_d), int64)
      pending%upper(1:4) = int(ubound(state%longwave_input%b12_kao_d), int64)
    case (111) ! __yoerrto12_MOD_selfrefo
pending%address=c_loc(state%longwave_input%b12_selfrefo(lbound(state%longwave_input%b12_selfrefo,1),lbound(state%longwave_input%b12_selfrefo,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b12_selfrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b12_selfrefo), int64)
    case (112) ! __yoerrto12_MOD_forrefo
pending%address=c_loc(state%longwave_input%b12_forrefo(lbound(state%longwave_input%b12_forrefo,1),lbound(state%longwave_input%b12_forrefo,2)))
      pending%bytes = 512_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b12_forrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b12_forrefo), int64)
    case (113) ! __yoerrto13_MOD_fracrefao
pending%address=c_loc(state%longwave_input%b13_fracrefao(lbound(state%longwave_input%b13_fracrefao,1),lbound(state%longwave_input%b13_fracrefao,2)))
      pending%bytes = 1152_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b13_fracrefao), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b13_fracrefao), int64)
    case (114) ! __yoerrto13_MOD_fracrefbo
      pending%address = c_loc(state%longwave_input%b13_fracrefbo(lbound(state%longwave_input%b13_fracrefbo, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_input%b13_fracrefbo), int64)
      pending%upper(1:1) = int(ubound(state%longwave_input%b13_fracrefbo), int64)
    case (115) ! __yoerrto13_MOD_kao
pending%address=c_loc(state%longwave_input%b13_kao(lbound(state%longwave_input%b13_kao,1),lbound(state%longwave_input%b13_kao,2),lbound(state%longwave_input%b13_kao,3),lbound(state%longwave_input%b13_kao,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_input%b13_kao), int64)
      pending%upper(1:4) = int(ubound(state%longwave_input%b13_kao), int64)
    case (116) ! __yoerrto13_MOD_kao_d
pending%address=c_loc(state%longwave_input%b13_kao_d(lbound(state%longwave_input%b13_kao_d,1),lbound(state%longwave_input%b13_kao_d,2),lbound(state%longwave_input%b13_kao_d,3),lbound(state%longwave_input%b13_kao_d,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_input%b13_kao_d), int64)
      pending%upper(1:4) = int(ubound(state%longwave_input%b13_kao_d), int64)
    case (117) ! __yoerrto13_MOD_selfrefo
pending%address=c_loc(state%longwave_input%b13_selfrefo(lbound(state%longwave_input%b13_selfrefo,1),lbound(state%longwave_input%b13_selfrefo,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b13_selfrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b13_selfrefo), int64)
    case (118) ! __yoerrto13_MOD_kao_mco2
pending%address=c_loc(state%longwave_input%b13_kao_mco2(lbound(state%longwave_input%b13_kao_mco2,1),lbound(state%longwave_input%b13_kao_mco2,2),lbound(state%longwave_input%b13_kao_mco2,3)))
      pending%bytes = 21888_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b13_kao_mco2), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b13_kao_mco2), int64)
    case (119) ! __yoerrto13_MOD_kao_mco
pending%address=c_loc(state%longwave_input%b13_kao_mco(lbound(state%longwave_input%b13_kao_mco,1),lbound(state%longwave_input%b13_kao_mco,2),lbound(state%longwave_input%b13_kao_mco,3)))
      pending%bytes = 21888_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b13_kao_mco), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b13_kao_mco), int64)
    case (120) ! __yoerrto13_MOD_kbo_mo3
pending%address=c_loc(state%longwave_input%b13_kbo_mo3(lbound(state%longwave_input%b13_kbo_mo3,1),lbound(state%longwave_input%b13_kbo_mo3,2)))
      pending%bytes = 2432_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b13_kbo_mo3), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b13_kbo_mo3), int64)
    case (121) ! __yoerrto13_MOD_forrefo
pending%address=c_loc(state%longwave_input%b13_forrefo(lbound(state%longwave_input%b13_forrefo,1),lbound(state%longwave_input%b13_forrefo,2)))
      pending%bytes = 512_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b13_forrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b13_forrefo), int64)
    case (122) ! __yoerrto14_MOD_fracrefao
      pending%address = c_loc(state%longwave_input%b14_fracrefao(lbound(state%longwave_input%b14_fracrefao, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_input%b14_fracrefao), int64)
      pending%upper(1:1) = int(ubound(state%longwave_input%b14_fracrefao), int64)
    case (123) ! __yoerrto14_MOD_fracrefbo
      pending%address = c_loc(state%longwave_input%b14_fracrefbo(lbound(state%longwave_input%b14_fracrefbo, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_input%b14_fracrefbo), int64)
      pending%upper(1:1) = int(ubound(state%longwave_input%b14_fracrefbo), int64)
    case (124) ! __yoerrto14_MOD_kao
pending%address=c_loc(state%longwave_input%b14_kao(lbound(state%longwave_input%b14_kao,1),lbound(state%longwave_input%b14_kao,2),lbound(state%longwave_input%b14_kao,3)))
      pending%bytes = 8320_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b14_kao), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b14_kao), int64)
    case (125) ! __yoerrto14_MOD_kbo
pending%address=c_loc(state%longwave_input%b14_kbo(lbound(state%longwave_input%b14_kbo,1),lbound(state%longwave_input%b14_kbo,2),lbound(state%longwave_input%b14_kbo,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b14_kbo), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b14_kbo), int64)
    case (126) ! __yoerrto14_MOD_kao_d
pending%address=c_loc(state%longwave_input%b14_kao_d(lbound(state%longwave_input%b14_kao_d,1),lbound(state%longwave_input%b14_kao_d,2),lbound(state%longwave_input%b14_kao_d,3)))
      pending%bytes = 8320_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b14_kao_d), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b14_kao_d), int64)
    case (127) ! __yoerrto14_MOD_kbo_d
pending%address=c_loc(state%longwave_input%b14_kbo_d(lbound(state%longwave_input%b14_kbo_d,1),lbound(state%longwave_input%b14_kbo_d,2),lbound(state%longwave_input%b14_kbo_d,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b14_kbo_d), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b14_kbo_d), int64)
    case (128) ! __yoerrto14_MOD_selfrefo
pending%address=c_loc(state%longwave_input%b14_selfrefo(lbound(state%longwave_input%b14_selfrefo,1),lbound(state%longwave_input%b14_selfrefo,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b14_selfrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b14_selfrefo), int64)
    case (129) ! __yoerrto14_MOD_forrefo
pending%address=c_loc(state%longwave_input%b14_forrefo(lbound(state%longwave_input%b14_forrefo,1),lbound(state%longwave_input%b14_forrefo,2)))
      pending%bytes = 512_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b14_forrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b14_forrefo), int64)
    case (130) ! __yoerrto15_MOD_fracrefao
pending%address=c_loc(state%longwave_input%b15_fracrefao(lbound(state%longwave_input%b15_fracrefao,1),lbound(state%longwave_input%b15_fracrefao,2)))
      pending%bytes = 1152_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b15_fracrefao), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b15_fracrefao), int64)
    case (131) ! __yoerrto15_MOD_kao
pending%address=c_loc(state%longwave_input%b15_kao(lbound(state%longwave_input%b15_kao,1),lbound(state%longwave_input%b15_kao,2),lbound(state%longwave_input%b15_kao,3),lbound(state%longwave_input%b15_kao,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_input%b15_kao), int64)
      pending%upper(1:4) = int(ubound(state%longwave_input%b15_kao), int64)
    case (132) ! __yoerrto15_MOD_kao_d
pending%address=c_loc(state%longwave_input%b15_kao_d(lbound(state%longwave_input%b15_kao_d,1),lbound(state%longwave_input%b15_kao_d,2),lbound(state%longwave_input%b15_kao_d,3),lbound(state%longwave_input%b15_kao_d,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_input%b15_kao_d), int64)
      pending%upper(1:4) = int(ubound(state%longwave_input%b15_kao_d), int64)
    case (133) ! __yoerrto15_MOD_selfrefo
pending%address=c_loc(state%longwave_input%b15_selfrefo(lbound(state%longwave_input%b15_selfrefo,1),lbound(state%longwave_input%b15_selfrefo,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b15_selfrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b15_selfrefo), int64)
    case (134) ! __yoerrto15_MOD_forrefo
pending%address=c_loc(state%longwave_input%b15_forrefo(lbound(state%longwave_input%b15_forrefo,1),lbound(state%longwave_input%b15_forrefo,2)))
      pending%bytes = 512_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b15_forrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b15_forrefo), int64)
    case (135) ! __yoerrto15_MOD_kao_mn2
pending%address=c_loc(state%longwave_input%b15_kao_mn2(lbound(state%longwave_input%b15_kao_mn2,1),lbound(state%longwave_input%b15_kao_mn2,2),lbound(state%longwave_input%b15_kao_mn2,3)))
      pending%bytes = 21888_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b15_kao_mn2), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b15_kao_mn2), int64)
    case (136) ! __yoerrto16_MOD_fracrefao
pending%address=c_loc(state%longwave_input%b16_fracrefao(lbound(state%longwave_input%b16_fracrefao,1),lbound(state%longwave_input%b16_fracrefao,2)))
      pending%bytes = 1152_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b16_fracrefao), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b16_fracrefao), int64)
    case (137) ! __yoerrto16_MOD_fracrefbo
      pending%address = c_loc(state%longwave_input%b16_fracrefbo(lbound(state%longwave_input%b16_fracrefbo, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_input%b16_fracrefbo), int64)
      pending%upper(1:1) = int(ubound(state%longwave_input%b16_fracrefbo), int64)
    case (138) ! __yoerrto16_MOD_kao
pending%address=c_loc(state%longwave_input%b16_kao(lbound(state%longwave_input%b16_kao,1),lbound(state%longwave_input%b16_kao,2),lbound(state%longwave_input%b16_kao,3),lbound(state%longwave_input%b16_kao,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_input%b16_kao), int64)
      pending%upper(1:4) = int(ubound(state%longwave_input%b16_kao), int64)
    case (139) ! __yoerrto16_MOD_kbo
pending%address=c_loc(state%longwave_input%b16_kbo(lbound(state%longwave_input%b16_kbo,1),lbound(state%longwave_input%b16_kbo,2),lbound(state%longwave_input%b16_kbo,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b16_kbo), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b16_kbo), int64)
    case (140) ! __yoerrto16_MOD_kao_d
pending%address=c_loc(state%longwave_input%b16_kao_d(lbound(state%longwave_input%b16_kao_d,1),lbound(state%longwave_input%b16_kao_d,2),lbound(state%longwave_input%b16_kao_d,3),lbound(state%longwave_input%b16_kao_d,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_input%b16_kao_d), int64)
      pending%upper(1:4) = int(ubound(state%longwave_input%b16_kao_d), int64)
    case (141) ! __yoerrto16_MOD_kbo_d
pending%address=c_loc(state%longwave_input%b16_kbo_d(lbound(state%longwave_input%b16_kbo_d,1),lbound(state%longwave_input%b16_kbo_d,2),lbound(state%longwave_input%b16_kbo_d,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_input%b16_kbo_d), int64)
      pending%upper(1:3) = int(ubound(state%longwave_input%b16_kbo_d), int64)
    case (142) ! __yoerrto16_MOD_selfrefo
pending%address=c_loc(state%longwave_input%b16_selfrefo(lbound(state%longwave_input%b16_selfrefo,1),lbound(state%longwave_input%b16_selfrefo,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b16_selfrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b16_selfrefo), int64)
    case (143) ! __yoerrto16_MOD_forrefo
pending%address=c_loc(state%longwave_input%b16_forrefo(lbound(state%longwave_input%b16_forrefo,1),lbound(state%longwave_input%b16_forrefo,2)))
      pending%bytes = 512_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_input%b16_forrefo), int64)
      pending%upper(1:2) = int(ubound(state%longwave_input%b16_forrefo), int64)
    case (144) ! __yoerrtftr_MOD_ngc
      pending%address = c_loc(state%longwave_reduced%ngc(lbound(state%longwave_reduced%ngc, 1)))
      pending%bytes = 64_c_int64_t
      pending%rank = 1; pending%element_bytes = 4; pending%type_code = 1
      pending%lower(1:1) = int(lbound(state%longwave_reduced%ngc), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%ngc), int64)
    case (145) ! __yoerrtftr_MOD_ngs
      pending%address = c_loc(state%longwave_reduced%ngs(lbound(state%longwave_reduced%ngs, 1)))
      pending%bytes = 64_c_int64_t
      pending%rank = 1; pending%element_bytes = 4; pending%type_code = 1
      pending%lower(1:1) = int(lbound(state%longwave_reduced%ngs), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%ngs), int64)
    case (146) ! __yoerrtftr_MOD_ngn
      pending%address = c_loc(state%longwave_reduced%ngn(lbound(state%longwave_reduced%ngn, 1)))
      pending%bytes = 1024_c_int64_t
      pending%rank = 1; pending%element_bytes = 4; pending%type_code = 1
      pending%lower(1:1) = int(lbound(state%longwave_reduced%ngn), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%ngn), int64)
    case (147) ! __yoerrtftr_MOD_ngb
      pending%address = c_loc(state%longwave_reduced%ngb(lbound(state%longwave_reduced%ngb, 1)))
      pending%bytes = 1024_c_int64_t
      pending%rank = 1; pending%element_bytes = 4; pending%type_code = 1
      pending%lower(1:1) = int(lbound(state%longwave_reduced%ngb), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%ngb), int64)
    case (148) ! __yoerrtftr_MOD_ngm
      pending%address = c_loc(state%longwave_reduced%ngm(lbound(state%longwave_reduced%ngm, 1)))
      pending%bytes = 1024_c_int64_t
      pending%rank = 1; pending%element_bytes = 4; pending%type_code = 1
      pending%lower(1:1) = int(lbound(state%longwave_reduced%ngm), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%ngm), int64)
    case (149) ! __yoerrtftr_MOD_wt
      pending%address = c_loc(state%longwave_reduced%wt(lbound(state%longwave_reduced%wt, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reduced%wt), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%wt), int64)
    case (150) ! __yoerrtbg2_MOD_corr1
      pending%address = c_loc(state%longwave_reduced%corr1(lbound(state%longwave_reduced%corr1, 1)))
      pending%bytes = 1608_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reduced%corr1), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%corr1), int64)
    case (151) ! __yoerrtbg2_MOD_corr2
      pending%address = c_loc(state%longwave_reduced%corr2(lbound(state%longwave_reduced%corr2, 1)))
      pending%bytes = 1608_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reduced%corr2), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%corr2), int64)
    case (152) ! __yoerrtrwt_MOD_rwgt
      pending%address = c_loc(state%longwave_reduced%rwgt(lbound(state%longwave_reduced%rwgt, 1)))
      pending%bytes = 2048_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reduced%rwgt), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%rwgt), int64)
    case (153) ! __yoerrtrwt_MOD_frefa
  pending%address=c_loc(state%longwave_reduced%frefa(lbound(state%longwave_reduced%frefa,1),lbound(state%longwave_reduced%frefa,2)))
      pending%bytes = 26624_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%frefa), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%frefa), int64)
    case (154) ! __yoerrtrwt_MOD_frefb
  pending%address=c_loc(state%longwave_reduced%frefb(lbound(state%longwave_reduced%frefb,1),lbound(state%longwave_reduced%frefb,2)))
      pending%bytes = 12288_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%frefb), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%frefb), int64)
    case (155) ! __yoerrtrwt_MOD_frefadf
pending%address=c_loc(state%longwave_reduced%frefadf(lbound(state%longwave_reduced%frefadf,1),lbound(state%longwave_reduced%frefadf,2)))
      pending%bytes = 26624_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%frefadf), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%frefadf), int64)
    case (156) ! __yoerrtrwt_MOD_frefbdf
pending%address=c_loc(state%longwave_reduced%frefbdf(lbound(state%longwave_reduced%frefbdf,1),lbound(state%longwave_reduced%frefbdf,2)))
      pending%bytes = 12288_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%frefbdf), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%frefbdf), int64)
    case (157) ! __yoerrta1_MOD_fracrefa
      pending%address = c_loc(state%longwave_reduced%b1_fracrefa(lbound(state%longwave_reduced%b1_fracrefa, 1)))
      pending%bytes = 80_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reduced%b1_fracrefa), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%b1_fracrefa), int64)
    case (158) ! __yoerrta1_MOD_fracrefb
      pending%address = c_loc(state%longwave_reduced%b1_fracrefb(lbound(state%longwave_reduced%b1_fracrefb, 1)))
      pending%bytes = 80_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reduced%b1_fracrefb), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%b1_fracrefb), int64)
    case (159) ! yoerrta1.eq.1_
pending%address=c_loc(state%longwave_reduced%b1_ka(lbound(state%longwave_reduced%b1_ka,1),lbound(state%longwave_reduced%b1_ka,2),lbound(state%longwave_reduced%b1_ka,3)))
      pending%bytes = 5200_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_reduced%b1_ka), int64)
      pending%upper(1:3) = int(ubound(state%longwave_reduced%b1_ka), int64)
    case (160) ! yoerrta1.eq.0_
pending%address=c_loc(state%longwave_reduced%b1_kb(lbound(state%longwave_reduced%b1_kb,1),lbound(state%longwave_reduced%b1_kb,2),lbound(state%longwave_reduced%b1_kb,3)))
      pending%bytes = 18800_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_reduced%b1_kb), int64)
      pending%upper(1:3) = int(ubound(state%longwave_reduced%b1_kb), int64)
    case (161) ! __yoerrta1_MOD_ka_mn2
pending%address=c_loc(state%longwave_reduced%b1_ka_mn2(lbound(state%longwave_reduced%b1_ka_mn2,1),lbound(state%longwave_reduced%b1_ka_mn2,2)))
      pending%bytes = 1520_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b1_ka_mn2), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b1_ka_mn2), int64)
    case (162) ! __yoerrta1_MOD_kb_mn2
pending%address=c_loc(state%longwave_reduced%b1_kb_mn2(lbound(state%longwave_reduced%b1_kb_mn2,1),lbound(state%longwave_reduced%b1_kb_mn2,2)))
      pending%bytes = 1520_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b1_kb_mn2), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b1_kb_mn2), int64)
    case (163) ! __yoerrta1_MOD_selfref
pending%address=c_loc(state%longwave_reduced%b1_selfref(lbound(state%longwave_reduced%b1_selfref,1),lbound(state%longwave_reduced%b1_selfref,2)))
      pending%bytes = 800_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b1_selfref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b1_selfref), int64)
    case (164) ! __yoerrta1_MOD_forref
pending%address=c_loc(state%longwave_reduced%b1_forref(lbound(state%longwave_reduced%b1_forref,1),lbound(state%longwave_reduced%b1_forref,2)))
      pending%bytes = 320_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b1_forref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b1_forref), int64)
    case (165) ! __yoerrta2_MOD_fracrefa
      pending%address = c_loc(state%longwave_reduced%b2_fracrefa(lbound(state%longwave_reduced%b2_fracrefa, 1)))
      pending%bytes = 96_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reduced%b2_fracrefa), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%b2_fracrefa), int64)
    case (166) ! __yoerrta2_MOD_fracrefb
      pending%address = c_loc(state%longwave_reduced%b2_fracrefb(lbound(state%longwave_reduced%b2_fracrefb, 1)))
      pending%bytes = 96_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reduced%b2_fracrefb), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%b2_fracrefb), int64)
    case (167) ! yoerrta2.eq.1_
pending%address=c_loc(state%longwave_reduced%b2_ka(lbound(state%longwave_reduced%b2_ka,1),lbound(state%longwave_reduced%b2_ka,2),lbound(state%longwave_reduced%b2_ka,3)))
      pending%bytes = 6240_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_reduced%b2_ka), int64)
      pending%upper(1:3) = int(ubound(state%longwave_reduced%b2_ka), int64)
    case (168) ! yoerrta2.eq.0_
pending%address=c_loc(state%longwave_reduced%b2_kb(lbound(state%longwave_reduced%b2_kb,1),lbound(state%longwave_reduced%b2_kb,2),lbound(state%longwave_reduced%b2_kb,3)))
      pending%bytes = 22560_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_reduced%b2_kb), int64)
      pending%upper(1:3) = int(ubound(state%longwave_reduced%b2_kb), int64)
    case (169) ! __yoerrta2_MOD_selfref
pending%address=c_loc(state%longwave_reduced%b2_selfref(lbound(state%longwave_reduced%b2_selfref,1),lbound(state%longwave_reduced%b2_selfref,2)))
      pending%bytes = 960_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b2_selfref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b2_selfref), int64)
    case (170) ! __yoerrta2_MOD_forref
pending%address=c_loc(state%longwave_reduced%b2_forref(lbound(state%longwave_reduced%b2_forref,1),lbound(state%longwave_reduced%b2_forref,2)))
      pending%bytes = 384_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b2_forref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b2_forref), int64)
    case (171) ! __yoerrta3_MOD_fracrefa
pending%address=c_loc(state%longwave_reduced%b3_fracrefa(lbound(state%longwave_reduced%b3_fracrefa,1),lbound(state%longwave_reduced%b3_fracrefa,2)))
      pending%bytes = 1152_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b3_fracrefa), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b3_fracrefa), int64)
    case (172) ! __yoerrta3_MOD_fracrefb
pending%address=c_loc(state%longwave_reduced%b3_fracrefb(lbound(state%longwave_reduced%b3_fracrefb,1),lbound(state%longwave_reduced%b3_fracrefb,2)))
      pending%bytes = 640_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b3_fracrefb), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b3_fracrefb), int64)
    case (173) ! __yoerrta3_MOD_ka_mn2o
pending%address=c_loc(state%longwave_reduced%b3_ka_mn2o(lbound(state%longwave_reduced%b3_ka_mn2o,1),lbound(state%longwave_reduced%b3_ka_mn2o,2),lbound(state%longwave_reduced%b3_ka_mn2o,3)))
      pending%bytes = 21888_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_reduced%b3_ka_mn2o), int64)
      pending%upper(1:3) = int(ubound(state%longwave_reduced%b3_ka_mn2o), int64)
    case (174) ! __yoerrta3_MOD_kb_mn2o
pending%address=c_loc(state%longwave_reduced%b3_kb_mn2o(lbound(state%longwave_reduced%b3_kb_mn2o,1),lbound(state%longwave_reduced%b3_kb_mn2o,2),lbound(state%longwave_reduced%b3_kb_mn2o,3)))
      pending%bytes = 12160_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_reduced%b3_kb_mn2o), int64)
      pending%upper(1:3) = int(ubound(state%longwave_reduced%b3_kb_mn2o), int64)
    case (175) ! yoerrta3.eq.1_
pending%address=c_loc(state%longwave_reduced%b3_ka(lbound(state%longwave_reduced%b3_ka,1),lbound(state%longwave_reduced%b3_ka,2),lbound(state%longwave_reduced%b3_ka,3),lbound(state%longwave_reduced%b3_ka,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_reduced%b3_ka), int64)
      pending%upper(1:4) = int(ubound(state%longwave_reduced%b3_ka), int64)
    case (176) ! yoerrta3.eq.0_
pending%address=c_loc(state%longwave_reduced%b3_kb(lbound(state%longwave_reduced%b3_kb,1),lbound(state%longwave_reduced%b3_kb,2),lbound(state%longwave_reduced%b3_kb,3),lbound(state%longwave_reduced%b3_kb,4)))
      pending%bytes = 150400_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_reduced%b3_kb), int64)
      pending%upper(1:4) = int(ubound(state%longwave_reduced%b3_kb), int64)
    case (177) ! __yoerrta3_MOD_selfref
pending%address=c_loc(state%longwave_reduced%b3_selfref(lbound(state%longwave_reduced%b3_selfref,1),lbound(state%longwave_reduced%b3_selfref,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b3_selfref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b3_selfref), int64)
    case (178) ! __yoerrta3_MOD_forref
pending%address=c_loc(state%longwave_reduced%b3_forref(lbound(state%longwave_reduced%b3_forref,1),lbound(state%longwave_reduced%b3_forref,2)))
      pending%bytes = 512_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b3_forref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b3_forref), int64)
    case (179) ! __yoerrta4_MOD_fracrefa
pending%address=c_loc(state%longwave_reduced%b4_fracrefa(lbound(state%longwave_reduced%b4_fracrefa,1),lbound(state%longwave_reduced%b4_fracrefa,2)))
      pending%bytes = 1008_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b4_fracrefa), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b4_fracrefa), int64)
    case (180) ! __yoerrta4_MOD_fracrefb
pending%address=c_loc(state%longwave_reduced%b4_fracrefb(lbound(state%longwave_reduced%b4_fracrefb,1),lbound(state%longwave_reduced%b4_fracrefb,2)))
      pending%bytes = 560_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b4_fracrefb), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b4_fracrefb), int64)
    case (181) ! yoerrta4.eq.1_
pending%address=c_loc(state%longwave_reduced%b4_ka(lbound(state%longwave_reduced%b4_ka,1),lbound(state%longwave_reduced%b4_ka,2),lbound(state%longwave_reduced%b4_ka,3),lbound(state%longwave_reduced%b4_ka,4)))
      pending%bytes = 65520_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_reduced%b4_ka), int64)
      pending%upper(1:4) = int(ubound(state%longwave_reduced%b4_ka), int64)
    case (182) ! yoerrta4.eq.0_
pending%address=c_loc(state%longwave_reduced%b4_kb(lbound(state%longwave_reduced%b4_kb,1),lbound(state%longwave_reduced%b4_kb,2),lbound(state%longwave_reduced%b4_kb,3),lbound(state%longwave_reduced%b4_kb,4)))
      pending%bytes = 131600_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_reduced%b4_kb), int64)
      pending%upper(1:4) = int(ubound(state%longwave_reduced%b4_kb), int64)
    case (183) ! __yoerrta4_MOD_selfref
pending%address=c_loc(state%longwave_reduced%b4_selfref(lbound(state%longwave_reduced%b4_selfref,1),lbound(state%longwave_reduced%b4_selfref,2)))
      pending%bytes = 1120_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b4_selfref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b4_selfref), int64)
    case (184) ! __yoerrta4_MOD_forref
pending%address=c_loc(state%longwave_reduced%b4_forref(lbound(state%longwave_reduced%b4_forref,1),lbound(state%longwave_reduced%b4_forref,2)))
      pending%bytes = 448_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b4_forref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b4_forref), int64)
    case (185) ! __yoerrta5_MOD_fracrefa
pending%address=c_loc(state%longwave_reduced%b5_fracrefa(lbound(state%longwave_reduced%b5_fracrefa,1),lbound(state%longwave_reduced%b5_fracrefa,2)))
      pending%bytes = 1152_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b5_fracrefa), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b5_fracrefa), int64)
    case (186) ! __yoerrta5_MOD_fracrefb
pending%address=c_loc(state%longwave_reduced%b5_fracrefb(lbound(state%longwave_reduced%b5_fracrefb,1),lbound(state%longwave_reduced%b5_fracrefb,2)))
      pending%bytes = 640_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b5_fracrefb), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b5_fracrefb), int64)
    case (187) ! __yoerrta5_MOD_ccl4
      pending%address = c_loc(state%longwave_reduced%b5_ccl4(lbound(state%longwave_reduced%b5_ccl4, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reduced%b5_ccl4), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%b5_ccl4), int64)
    case (188) ! yoerrta5.eq.1_
pending%address=c_loc(state%longwave_reduced%b5_ka(lbound(state%longwave_reduced%b5_ka,1),lbound(state%longwave_reduced%b5_ka,2),lbound(state%longwave_reduced%b5_ka,3),lbound(state%longwave_reduced%b5_ka,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_reduced%b5_ka), int64)
      pending%upper(1:4) = int(ubound(state%longwave_reduced%b5_ka), int64)
    case (189) ! yoerrta5.eq.0_
pending%address=c_loc(state%longwave_reduced%b5_kb(lbound(state%longwave_reduced%b5_kb,1),lbound(state%longwave_reduced%b5_kb,2),lbound(state%longwave_reduced%b5_kb,3),lbound(state%longwave_reduced%b5_kb,4)))
      pending%bytes = 150400_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_reduced%b5_kb), int64)
      pending%upper(1:4) = int(ubound(state%longwave_reduced%b5_kb), int64)
    case (190) ! __yoerrta5_MOD_ka_mo3
pending%address=c_loc(state%longwave_reduced%b5_ka_mo3(lbound(state%longwave_reduced%b5_ka_mo3,1),lbound(state%longwave_reduced%b5_ka_mo3,2),lbound(state%longwave_reduced%b5_ka_mo3,3)))
      pending%bytes = 21888_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_reduced%b5_ka_mo3), int64)
      pending%upper(1:3) = int(ubound(state%longwave_reduced%b5_ka_mo3), int64)
    case (191) ! __yoerrta5_MOD_selfref
pending%address=c_loc(state%longwave_reduced%b5_selfref(lbound(state%longwave_reduced%b5_selfref,1),lbound(state%longwave_reduced%b5_selfref,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b5_selfref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b5_selfref), int64)
    case (192) ! __yoerrta5_MOD_forref
pending%address=c_loc(state%longwave_reduced%b5_forref(lbound(state%longwave_reduced%b5_forref,1),lbound(state%longwave_reduced%b5_forref,2)))
      pending%bytes = 512_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b5_forref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b5_forref), int64)
    case (193) ! __yoerrta6_MOD_fracrefa
      pending%address = c_loc(state%longwave_reduced%b6_fracrefa(lbound(state%longwave_reduced%b6_fracrefa, 1)))
      pending%bytes = 64_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reduced%b6_fracrefa), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%b6_fracrefa), int64)
    case (194) ! __yoerrta6_MOD_cfc11adj
      pending%address = c_loc(state%longwave_reduced%b6_cfc11adj(lbound(state%longwave_reduced%b6_cfc11adj, 1)))
      pending%bytes = 64_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reduced%b6_cfc11adj), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%b6_cfc11adj), int64)
    case (195) ! __yoerrta6_MOD_cfc12
      pending%address = c_loc(state%longwave_reduced%b6_cfc12(lbound(state%longwave_reduced%b6_cfc12, 1)))
      pending%bytes = 64_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reduced%b6_cfc12), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%b6_cfc12), int64)
    case (196) ! yoerrta6.eq.0_
pending%address=c_loc(state%longwave_reduced%b6_ka(lbound(state%longwave_reduced%b6_ka,1),lbound(state%longwave_reduced%b6_ka,2),lbound(state%longwave_reduced%b6_ka,3)))
      pending%bytes = 4160_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_reduced%b6_ka), int64)
      pending%upper(1:3) = int(ubound(state%longwave_reduced%b6_ka), int64)
    case (197) ! __yoerrta6_MOD_selfref
pending%address=c_loc(state%longwave_reduced%b6_selfref(lbound(state%longwave_reduced%b6_selfref,1),lbound(state%longwave_reduced%b6_selfref,2)))
      pending%bytes = 640_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b6_selfref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b6_selfref), int64)
    case (198) ! __yoerrta6_MOD_ka_mco2
pending%address=c_loc(state%longwave_reduced%b6_ka_mco2(lbound(state%longwave_reduced%b6_ka_mco2,1),lbound(state%longwave_reduced%b6_ka_mco2,2)))
      pending%bytes = 1216_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b6_ka_mco2), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b6_ka_mco2), int64)
    case (199) ! __yoerrta6_MOD_forref
pending%address=c_loc(state%longwave_reduced%b6_forref(lbound(state%longwave_reduced%b6_forref,1),lbound(state%longwave_reduced%b6_forref,2)))
      pending%bytes = 256_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b6_forref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b6_forref), int64)
    case (200) ! __yoerrta7_MOD_fracrefa
pending%address=c_loc(state%longwave_reduced%b7_fracrefa(lbound(state%longwave_reduced%b7_fracrefa,1),lbound(state%longwave_reduced%b7_fracrefa,2)))
      pending%bytes = 864_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b7_fracrefa), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b7_fracrefa), int64)
    case (201) ! __yoerrta7_MOD_fracrefb
      pending%address = c_loc(state%longwave_reduced%b7_fracrefb(lbound(state%longwave_reduced%b7_fracrefb, 1)))
      pending%bytes = 96_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reduced%b7_fracrefb), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%b7_fracrefb), int64)
    case (202) ! yoerrta7.eq.1_
pending%address=c_loc(state%longwave_reduced%b7_ka(lbound(state%longwave_reduced%b7_ka,1),lbound(state%longwave_reduced%b7_ka,2),lbound(state%longwave_reduced%b7_ka,3),lbound(state%longwave_reduced%b7_ka,4)))
      pending%bytes = 56160_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_reduced%b7_ka), int64)
      pending%upper(1:4) = int(ubound(state%longwave_reduced%b7_ka), int64)
    case (203) ! yoerrta7.eq.0_
pending%address=c_loc(state%longwave_reduced%b7_kb(lbound(state%longwave_reduced%b7_kb,1),lbound(state%longwave_reduced%b7_kb,2),lbound(state%longwave_reduced%b7_kb,3)))
      pending%bytes = 22560_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_reduced%b7_kb), int64)
      pending%upper(1:3) = int(ubound(state%longwave_reduced%b7_kb), int64)
    case (204) ! __yoerrta7_MOD_selfref
pending%address=c_loc(state%longwave_reduced%b7_selfref(lbound(state%longwave_reduced%b7_selfref,1),lbound(state%longwave_reduced%b7_selfref,2)))
      pending%bytes = 960_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b7_selfref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b7_selfref), int64)
    case (205) ! __yoerrta7_MOD_ka_mco2
pending%address=c_loc(state%longwave_reduced%b7_ka_mco2(lbound(state%longwave_reduced%b7_ka_mco2,1),lbound(state%longwave_reduced%b7_ka_mco2,2),lbound(state%longwave_reduced%b7_ka_mco2,3)))
      pending%bytes = 16416_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_reduced%b7_ka_mco2), int64)
      pending%upper(1:3) = int(ubound(state%longwave_reduced%b7_ka_mco2), int64)
    case (206) ! __yoerrta7_MOD_kb_mco2
pending%address=c_loc(state%longwave_reduced%b7_kb_mco2(lbound(state%longwave_reduced%b7_kb_mco2,1),lbound(state%longwave_reduced%b7_kb_mco2,2)))
      pending%bytes = 1824_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b7_kb_mco2), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b7_kb_mco2), int64)
    case (207) ! __yoerrta7_MOD_forref
pending%address=c_loc(state%longwave_reduced%b7_forref(lbound(state%longwave_reduced%b7_forref,1),lbound(state%longwave_reduced%b7_forref,2)))
      pending%bytes = 384_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b7_forref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b7_forref), int64)
    case (208) ! __yoerrta8_MOD_fracrefa
      pending%address = c_loc(state%longwave_reduced%b8_fracrefa(lbound(state%longwave_reduced%b8_fracrefa, 1)))
      pending%bytes = 64_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reduced%b8_fracrefa), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%b8_fracrefa), int64)
    case (209) ! __yoerrta8_MOD_fracrefb
      pending%address = c_loc(state%longwave_reduced%b8_fracrefb(lbound(state%longwave_reduced%b8_fracrefb, 1)))
      pending%bytes = 64_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reduced%b8_fracrefb), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%b8_fracrefb), int64)
    case (210) ! __yoerrta8_MOD_cfc12
      pending%address = c_loc(state%longwave_reduced%b8_cfc12(lbound(state%longwave_reduced%b8_cfc12, 1)))
      pending%bytes = 64_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reduced%b8_cfc12), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%b8_cfc12), int64)
    case (211) ! __yoerrta8_MOD_cfc22adj
      pending%address = c_loc(state%longwave_reduced%b8_cfc22adj(lbound(state%longwave_reduced%b8_cfc22adj, 1)))
      pending%bytes = 64_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reduced%b8_cfc22adj), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%b8_cfc22adj), int64)
    case (212) ! yoerrta8.eq.1_
pending%address=c_loc(state%longwave_reduced%b8_ka(lbound(state%longwave_reduced%b8_ka,1),lbound(state%longwave_reduced%b8_ka,2),lbound(state%longwave_reduced%b8_ka,3)))
      pending%bytes = 4160_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_reduced%b8_ka), int64)
      pending%upper(1:3) = int(ubound(state%longwave_reduced%b8_ka), int64)
    case (213) ! yoerrta8.eq.0_
pending%address=c_loc(state%longwave_reduced%b8_kb(lbound(state%longwave_reduced%b8_kb,1),lbound(state%longwave_reduced%b8_kb,2),lbound(state%longwave_reduced%b8_kb,3)))
      pending%bytes = 15040_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_reduced%b8_kb), int64)
      pending%upper(1:3) = int(ubound(state%longwave_reduced%b8_kb), int64)
    case (214) ! __yoerrta8_MOD_ka_mco2
pending%address=c_loc(state%longwave_reduced%b8_ka_mco2(lbound(state%longwave_reduced%b8_ka_mco2,1),lbound(state%longwave_reduced%b8_ka_mco2,2)))
      pending%bytes = 1216_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b8_ka_mco2), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b8_ka_mco2), int64)
    case (215) ! __yoerrta8_MOD_ka_mn2o
pending%address=c_loc(state%longwave_reduced%b8_ka_mn2o(lbound(state%longwave_reduced%b8_ka_mn2o,1),lbound(state%longwave_reduced%b8_ka_mn2o,2)))
      pending%bytes = 1216_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b8_ka_mn2o), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b8_ka_mn2o), int64)
    case (216) ! __yoerrta8_MOD_ka_mo3
pending%address=c_loc(state%longwave_reduced%b8_ka_mo3(lbound(state%longwave_reduced%b8_ka_mo3,1),lbound(state%longwave_reduced%b8_ka_mo3,2)))
      pending%bytes = 1216_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b8_ka_mo3), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b8_ka_mo3), int64)
    case (217) ! __yoerrta8_MOD_kb_mco2
pending%address=c_loc(state%longwave_reduced%b8_kb_mco2(lbound(state%longwave_reduced%b8_kb_mco2,1),lbound(state%longwave_reduced%b8_kb_mco2,2)))
      pending%bytes = 1216_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b8_kb_mco2), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b8_kb_mco2), int64)
    case (218) ! __yoerrta8_MOD_kb_mn2o
pending%address=c_loc(state%longwave_reduced%b8_kb_mn2o(lbound(state%longwave_reduced%b8_kb_mn2o,1),lbound(state%longwave_reduced%b8_kb_mn2o,2)))
      pending%bytes = 1216_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b8_kb_mn2o), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b8_kb_mn2o), int64)
    case (219) ! __yoerrta8_MOD_selfref
pending%address=c_loc(state%longwave_reduced%b8_selfref(lbound(state%longwave_reduced%b8_selfref,1),lbound(state%longwave_reduced%b8_selfref,2)))
      pending%bytes = 640_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b8_selfref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b8_selfref), int64)
    case (220) ! __yoerrta8_MOD_forref
pending%address=c_loc(state%longwave_reduced%b8_forref(lbound(state%longwave_reduced%b8_forref,1),lbound(state%longwave_reduced%b8_forref,2)))
      pending%bytes = 256_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b8_forref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b8_forref), int64)
    case (221) ! __yoerrta9_MOD_fracrefa
pending%address=c_loc(state%longwave_reduced%b9_fracrefa(lbound(state%longwave_reduced%b9_fracrefa,1),lbound(state%longwave_reduced%b9_fracrefa,2)))
      pending%bytes = 864_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b9_fracrefa), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b9_fracrefa), int64)
    case (222) ! __yoerrta9_MOD_fracrefb
      pending%address = c_loc(state%longwave_reduced%b9_fracrefb(lbound(state%longwave_reduced%b9_fracrefb, 1)))
      pending%bytes = 96_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reduced%b9_fracrefb), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%b9_fracrefb), int64)
    case (223) ! yoerrta9.eq.1_
pending%address=c_loc(state%longwave_reduced%b9_ka(lbound(state%longwave_reduced%b9_ka,1),lbound(state%longwave_reduced%b9_ka,2),lbound(state%longwave_reduced%b9_ka,3),lbound(state%longwave_reduced%b9_ka,4)))
      pending%bytes = 56160_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_reduced%b9_ka), int64)
      pending%upper(1:4) = int(ubound(state%longwave_reduced%b9_ka), int64)
    case (224) ! yoerrta9.eq.0_
pending%address=c_loc(state%longwave_reduced%b9_kb(lbound(state%longwave_reduced%b9_kb,1),lbound(state%longwave_reduced%b9_kb,2),lbound(state%longwave_reduced%b9_kb,3)))
      pending%bytes = 22560_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_reduced%b9_kb), int64)
      pending%upper(1:3) = int(ubound(state%longwave_reduced%b9_kb), int64)
    case (225) ! __yoerrta9_MOD_ka_mn2o
pending%address=c_loc(state%longwave_reduced%b9_ka_mn2o(lbound(state%longwave_reduced%b9_ka_mn2o,1),lbound(state%longwave_reduced%b9_ka_mn2o,2),lbound(state%longwave_reduced%b9_ka_mn2o,3)))
      pending%bytes = 16416_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_reduced%b9_ka_mn2o), int64)
      pending%upper(1:3) = int(ubound(state%longwave_reduced%b9_ka_mn2o), int64)
    case (226) ! __yoerrta9_MOD_kb_mn2o
pending%address=c_loc(state%longwave_reduced%b9_kb_mn2o(lbound(state%longwave_reduced%b9_kb_mn2o,1),lbound(state%longwave_reduced%b9_kb_mn2o,2)))
      pending%bytes = 1824_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b9_kb_mn2o), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b9_kb_mn2o), int64)
    case (227) ! __yoerrta9_MOD_selfref
pending%address=c_loc(state%longwave_reduced%b9_selfref(lbound(state%longwave_reduced%b9_selfref,1),lbound(state%longwave_reduced%b9_selfref,2)))
      pending%bytes = 960_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b9_selfref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b9_selfref), int64)
    case (228) ! __yoerrta9_MOD_forref
pending%address=c_loc(state%longwave_reduced%b9_forref(lbound(state%longwave_reduced%b9_forref,1),lbound(state%longwave_reduced%b9_forref,2)))
      pending%bytes = 384_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b9_forref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b9_forref), int64)
    case (229) ! __yoerrta10_MOD_fracrefa
      pending%address = c_loc(state%longwave_reduced%b10_fracrefa(lbound(state%longwave_reduced%b10_fracrefa, 1)))
      pending%bytes = 48_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reduced%b10_fracrefa), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%b10_fracrefa), int64)
    case (230) ! __yoerrta10_MOD_fracrefb
      pending%address = c_loc(state%longwave_reduced%b10_fracrefb(lbound(state%longwave_reduced%b10_fracrefb, 1)))
      pending%bytes = 48_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reduced%b10_fracrefb), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%b10_fracrefb), int64)
    case (231) ! yoerrta10.eq.1_
pending%address=c_loc(state%longwave_reduced%b10_ka(lbound(state%longwave_reduced%b10_ka,1),lbound(state%longwave_reduced%b10_ka,2),lbound(state%longwave_reduced%b10_ka,3)))
      pending%bytes = 3120_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_reduced%b10_ka), int64)
      pending%upper(1:3) = int(ubound(state%longwave_reduced%b10_ka), int64)
    case (232) ! yoerrta10.eq.0_
pending%address=c_loc(state%longwave_reduced%b10_kb(lbound(state%longwave_reduced%b10_kb,1),lbound(state%longwave_reduced%b10_kb,2),lbound(state%longwave_reduced%b10_kb,3)))
      pending%bytes = 11280_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_reduced%b10_kb), int64)
      pending%upper(1:3) = int(ubound(state%longwave_reduced%b10_kb), int64)
    case (233) ! __yoerrta10_MOD_selfref
pending%address=c_loc(state%longwave_reduced%b10_selfref(lbound(state%longwave_reduced%b10_selfref,1),lbound(state%longwave_reduced%b10_selfref,2)))
      pending%bytes = 480_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b10_selfref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b10_selfref), int64)
    case (234) ! __yoerrta10_MOD_forref
pending%address=c_loc(state%longwave_reduced%b10_forref(lbound(state%longwave_reduced%b10_forref,1),lbound(state%longwave_reduced%b10_forref,2)))
      pending%bytes = 192_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b10_forref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b10_forref), int64)
    case (235) ! __yoerrta11_MOD_fracrefa
      pending%address = c_loc(state%longwave_reduced%b11_fracrefa(lbound(state%longwave_reduced%b11_fracrefa, 1)))
      pending%bytes = 64_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reduced%b11_fracrefa), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%b11_fracrefa), int64)
    case (236) ! __yoerrta11_MOD_fracrefb
      pending%address = c_loc(state%longwave_reduced%b11_fracrefb(lbound(state%longwave_reduced%b11_fracrefb, 1)))
      pending%bytes = 64_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reduced%b11_fracrefb), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%b11_fracrefb), int64)
    case (237) ! yoerrta11.eq.1_
pending%address=c_loc(state%longwave_reduced%b11_ka(lbound(state%longwave_reduced%b11_ka,1),lbound(state%longwave_reduced%b11_ka,2),lbound(state%longwave_reduced%b11_ka,3)))
      pending%bytes = 4160_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_reduced%b11_ka), int64)
      pending%upper(1:3) = int(ubound(state%longwave_reduced%b11_ka), int64)
    case (238) ! yoerrta11.eq.0_
pending%address=c_loc(state%longwave_reduced%b11_kb(lbound(state%longwave_reduced%b11_kb,1),lbound(state%longwave_reduced%b11_kb,2),lbound(state%longwave_reduced%b11_kb,3)))
      pending%bytes = 15040_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_reduced%b11_kb), int64)
      pending%upper(1:3) = int(ubound(state%longwave_reduced%b11_kb), int64)
    case (239) ! __yoerrta11_MOD_ka_mo2
pending%address=c_loc(state%longwave_reduced%b11_ka_mo2(lbound(state%longwave_reduced%b11_ka_mo2,1),lbound(state%longwave_reduced%b11_ka_mo2,2)))
      pending%bytes = 1216_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b11_ka_mo2), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b11_ka_mo2), int64)
    case (240) ! __yoerrta11_MOD_kb_mo2
pending%address=c_loc(state%longwave_reduced%b11_kb_mo2(lbound(state%longwave_reduced%b11_kb_mo2,1),lbound(state%longwave_reduced%b11_kb_mo2,2)))
      pending%bytes = 1216_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b11_kb_mo2), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b11_kb_mo2), int64)
    case (241) ! __yoerrta11_MOD_selfref
pending%address=c_loc(state%longwave_reduced%b11_selfref(lbound(state%longwave_reduced%b11_selfref,1),lbound(state%longwave_reduced%b11_selfref,2)))
      pending%bytes = 640_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b11_selfref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b11_selfref), int64)
    case (242) ! __yoerrta11_MOD_forref
pending%address=c_loc(state%longwave_reduced%b11_forref(lbound(state%longwave_reduced%b11_forref,1),lbound(state%longwave_reduced%b11_forref,2)))
      pending%bytes = 256_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b11_forref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b11_forref), int64)
    case (243) ! __yoerrta12_MOD_fracrefa
pending%address=c_loc(state%longwave_reduced%b12_fracrefa(lbound(state%longwave_reduced%b12_fracrefa,1),lbound(state%longwave_reduced%b12_fracrefa,2)))
      pending%bytes = 576_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b12_fracrefa), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b12_fracrefa), int64)
    case (244) ! yoerrta12.eq.0_
pending%address=c_loc(state%longwave_reduced%b12_ka(lbound(state%longwave_reduced%b12_ka,1),lbound(state%longwave_reduced%b12_ka,2),lbound(state%longwave_reduced%b12_ka,3),lbound(state%longwave_reduced%b12_ka,4)))
      pending%bytes = 37440_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_reduced%b12_ka), int64)
      pending%upper(1:4) = int(ubound(state%longwave_reduced%b12_ka), int64)
    case (245) ! __yoerrta12_MOD_selfref
pending%address=c_loc(state%longwave_reduced%b12_selfref(lbound(state%longwave_reduced%b12_selfref,1),lbound(state%longwave_reduced%b12_selfref,2)))
      pending%bytes = 640_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b12_selfref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b12_selfref), int64)
    case (246) ! __yoerrta12_MOD_forref
pending%address=c_loc(state%longwave_reduced%b12_forref(lbound(state%longwave_reduced%b12_forref,1),lbound(state%longwave_reduced%b12_forref,2)))
      pending%bytes = 256_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b12_forref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b12_forref), int64)
    case (247) ! __yoerrta12_MOD_strrat
      pending%address = c_loc(state%longwave_reduced%b12_strrat)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (248) ! __yoerrta13_MOD_fracrefa
pending%address=c_loc(state%longwave_reduced%b13_fracrefa(lbound(state%longwave_reduced%b13_fracrefa,1),lbound(state%longwave_reduced%b13_fracrefa,2)))
      pending%bytes = 288_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b13_fracrefa), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b13_fracrefa), int64)
    case (249) ! __yoerrta13_MOD_fracrefb
      pending%address = c_loc(state%longwave_reduced%b13_fracrefb(lbound(state%longwave_reduced%b13_fracrefb, 1)))
      pending%bytes = 32_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reduced%b13_fracrefb), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%b13_fracrefb), int64)
    case (250) ! yoerrta13.eq.0_
pending%address=c_loc(state%longwave_reduced%b13_ka(lbound(state%longwave_reduced%b13_ka,1),lbound(state%longwave_reduced%b13_ka,2),lbound(state%longwave_reduced%b13_ka,3),lbound(state%longwave_reduced%b13_ka,4)))
      pending%bytes = 18720_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_reduced%b13_ka), int64)
      pending%upper(1:4) = int(ubound(state%longwave_reduced%b13_ka), int64)
    case (251) ! __yoerrta13_MOD_selfref
pending%address=c_loc(state%longwave_reduced%b13_selfref(lbound(state%longwave_reduced%b13_selfref,1),lbound(state%longwave_reduced%b13_selfref,2)))
      pending%bytes = 320_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b13_selfref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b13_selfref), int64)
    case (252) ! __yoerrta13_MOD_forref
pending%address=c_loc(state%longwave_reduced%b13_forref(lbound(state%longwave_reduced%b13_forref,1),lbound(state%longwave_reduced%b13_forref,2)))
      pending%bytes = 128_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b13_forref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b13_forref), int64)
    case (253) ! __yoerrta13_MOD_ka_mco2
pending%address=c_loc(state%longwave_reduced%b13_ka_mco2(lbound(state%longwave_reduced%b13_ka_mco2,1),lbound(state%longwave_reduced%b13_ka_mco2,2),lbound(state%longwave_reduced%b13_ka_mco2,3)))
      pending%bytes = 5472_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_reduced%b13_ka_mco2), int64)
      pending%upper(1:3) = int(ubound(state%longwave_reduced%b13_ka_mco2), int64)
    case (254) ! __yoerrta13_MOD_ka_mco
pending%address=c_loc(state%longwave_reduced%b13_ka_mco(lbound(state%longwave_reduced%b13_ka_mco,1),lbound(state%longwave_reduced%b13_ka_mco,2),lbound(state%longwave_reduced%b13_ka_mco,3)))
      pending%bytes = 5472_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_reduced%b13_ka_mco), int64)
      pending%upper(1:3) = int(ubound(state%longwave_reduced%b13_ka_mco), int64)
    case (255) ! __yoerrta13_MOD_kb_mo3
pending%address=c_loc(state%longwave_reduced%b13_kb_mo3(lbound(state%longwave_reduced%b13_kb_mo3,1),lbound(state%longwave_reduced%b13_kb_mo3,2)))
      pending%bytes = 608_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b13_kb_mo3), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b13_kb_mo3), int64)
    case (256) ! __yoerrta14_MOD_fracrefa
      pending%address = c_loc(state%longwave_reduced%b14_fracrefa(lbound(state%longwave_reduced%b14_fracrefa, 1)))
      pending%bytes = 16_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reduced%b14_fracrefa), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%b14_fracrefa), int64)
    case (257) ! __yoerrta14_MOD_fracrefb
      pending%address = c_loc(state%longwave_reduced%b14_fracrefb(lbound(state%longwave_reduced%b14_fracrefb, 1)))
      pending%bytes = 16_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reduced%b14_fracrefb), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%b14_fracrefb), int64)
    case (258) ! yoerrta14.eq.1_
pending%address=c_loc(state%longwave_reduced%b14_ka(lbound(state%longwave_reduced%b14_ka,1),lbound(state%longwave_reduced%b14_ka,2),lbound(state%longwave_reduced%b14_ka,3)))
      pending%bytes = 1040_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_reduced%b14_ka), int64)
      pending%upper(1:3) = int(ubound(state%longwave_reduced%b14_ka), int64)
    case (259) ! yoerrta14.eq.0_
pending%address=c_loc(state%longwave_reduced%b14_kb(lbound(state%longwave_reduced%b14_kb,1),lbound(state%longwave_reduced%b14_kb,2),lbound(state%longwave_reduced%b14_kb,3)))
      pending%bytes = 3760_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_reduced%b14_kb), int64)
      pending%upper(1:3) = int(ubound(state%longwave_reduced%b14_kb), int64)
    case (260) ! __yoerrta14_MOD_selfref
pending%address=c_loc(state%longwave_reduced%b14_selfref(lbound(state%longwave_reduced%b14_selfref,1),lbound(state%longwave_reduced%b14_selfref,2)))
      pending%bytes = 160_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b14_selfref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b14_selfref), int64)
    case (261) ! __yoerrta14_MOD_forref
pending%address=c_loc(state%longwave_reduced%b14_forref(lbound(state%longwave_reduced%b14_forref,1),lbound(state%longwave_reduced%b14_forref,2)))
      pending%bytes = 64_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b14_forref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b14_forref), int64)
    case (262) ! __yoerrta15_MOD_fracrefa
pending%address=c_loc(state%longwave_reduced%b15_fracrefa(lbound(state%longwave_reduced%b15_fracrefa,1),lbound(state%longwave_reduced%b15_fracrefa,2)))
      pending%bytes = 144_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b15_fracrefa), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b15_fracrefa), int64)
    case (263) ! yoerrta15.eq.0_
pending%address=c_loc(state%longwave_reduced%b15_ka(lbound(state%longwave_reduced%b15_ka,1),lbound(state%longwave_reduced%b15_ka,2),lbound(state%longwave_reduced%b15_ka,3),lbound(state%longwave_reduced%b15_ka,4)))
      pending%bytes = 9360_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_reduced%b15_ka), int64)
      pending%upper(1:4) = int(ubound(state%longwave_reduced%b15_ka), int64)
    case (264) ! __yoerrta15_MOD_ka_mn2
pending%address=c_loc(state%longwave_reduced%b15_ka_mn2(lbound(state%longwave_reduced%b15_ka_mn2,1),lbound(state%longwave_reduced%b15_ka_mn2,2),lbound(state%longwave_reduced%b15_ka_mn2,3)))
      pending%bytes = 2736_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_reduced%b15_ka_mn2), int64)
      pending%upper(1:3) = int(ubound(state%longwave_reduced%b15_ka_mn2), int64)
    case (265) ! __yoerrta15_MOD_selfref
pending%address=c_loc(state%longwave_reduced%b15_selfref(lbound(state%longwave_reduced%b15_selfref,1),lbound(state%longwave_reduced%b15_selfref,2)))
      pending%bytes = 160_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b15_selfref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b15_selfref), int64)
    case (266) ! __yoerrta15_MOD_forref
pending%address=c_loc(state%longwave_reduced%b15_forref(lbound(state%longwave_reduced%b15_forref,1),lbound(state%longwave_reduced%b15_forref,2)))
      pending%bytes = 64_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b15_forref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b15_forref), int64)
    case (267) ! __yoerrta16_MOD_fracrefa
pending%address=c_loc(state%longwave_reduced%b16_fracrefa(lbound(state%longwave_reduced%b16_fracrefa,1),lbound(state%longwave_reduced%b16_fracrefa,2)))
      pending%bytes = 144_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b16_fracrefa), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b16_fracrefa), int64)
    case (268) ! __yoerrta16_MOD_fracrefb
      pending%address = c_loc(state%longwave_reduced%b16_fracrefb(lbound(state%longwave_reduced%b16_fracrefb, 1)))
      pending%bytes = 16_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reduced%b16_fracrefb), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reduced%b16_fracrefb), int64)
    case (269) ! yoerrta16.eq.1_
pending%address=c_loc(state%longwave_reduced%b16_ka(lbound(state%longwave_reduced%b16_ka,1),lbound(state%longwave_reduced%b16_ka,2),lbound(state%longwave_reduced%b16_ka,3),lbound(state%longwave_reduced%b16_ka,4)))
      pending%bytes = 9360_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%longwave_reduced%b16_ka), int64)
      pending%upper(1:4) = int(ubound(state%longwave_reduced%b16_ka), int64)
    case (270) ! yoerrta16.eq.0_
pending%address=c_loc(state%longwave_reduced%b16_kb(lbound(state%longwave_reduced%b16_kb,1),lbound(state%longwave_reduced%b16_kb,2),lbound(state%longwave_reduced%b16_kb,3)))
      pending%bytes = 3760_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_reduced%b16_kb), int64)
      pending%upper(1:3) = int(ubound(state%longwave_reduced%b16_kb), int64)
    case (271) ! __yoerrta16_MOD_selfref
pending%address=c_loc(state%longwave_reduced%b16_selfref(lbound(state%longwave_reduced%b16_selfref,1),lbound(state%longwave_reduced%b16_selfref,2)))
      pending%bytes = 160_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b16_selfref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b16_selfref), int64)
    case (272) ! __yoerrta16_MOD_forref
pending%address=c_loc(state%longwave_reduced%b16_forref(lbound(state%longwave_reduced%b16_forref,1),lbound(state%longwave_reduced%b16_forref,2)))
      pending%bytes = 64_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reduced%b16_forref), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reduced%b16_forref), int64)
    case (273) ! __yoerrtab_MOD_trans
      pending%address = c_loc(state%longwave_reference%trans(lbound(state%longwave_reference%trans, 1)))
      pending%bytes = 40008_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reference%trans), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reference%trans), int64)
    case (274) ! __yoerrtab_MOD_bpade
      pending%address = c_loc(state%longwave_reference%bpade)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (275) ! __yoerrtwn_MOD_ng
      pending%address = c_loc(state%longwave_reference%ng(lbound(state%longwave_reference%ng, 1)))
      pending%bytes = 64_c_int64_t
      pending%rank = 1; pending%element_bytes = 4; pending%type_code = 1
      pending%lower(1:1) = int(lbound(state%longwave_reference%ng), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reference%ng), int64)
    case (276) ! __yoerrtwn_MOD_nspa
      pending%address = c_loc(state%longwave_reference%nspa(lbound(state%longwave_reference%nspa, 1)))
      pending%bytes = 64_c_int64_t
      pending%rank = 1; pending%element_bytes = 4; pending%type_code = 1
      pending%lower(1:1) = int(lbound(state%longwave_reference%nspa), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reference%nspa), int64)
    case (277) ! __yoerrtwn_MOD_nspb
      pending%address = c_loc(state%longwave_reference%nspb(lbound(state%longwave_reference%nspb, 1)))
      pending%bytes = 64_c_int64_t
      pending%rank = 1; pending%element_bytes = 4; pending%type_code = 1
      pending%lower(1:1) = int(lbound(state%longwave_reference%nspb), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reference%nspb), int64)
    case (278) ! __yoerrtwn_MOD_delwave
      pending%address = c_loc(state%longwave_reference%delwave(lbound(state%longwave_reference%delwave, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reference%delwave), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reference%delwave), int64)
    case (279) ! __yoerrtwn_MOD_totplnk
pending%address=c_loc(state%longwave_reference%totplnk(lbound(state%longwave_reference%totplnk,1),lbound(state%longwave_reference%totplnk,2)))
      pending%bytes = 23168_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reference%totplnk), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reference%totplnk), int64)
    case (280) ! __yoerrtrf_MOD_pref
      pending%address = c_loc(state%longwave_reference%pref(lbound(state%longwave_reference%pref, 1)))
      pending%bytes = 472_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reference%pref), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reference%pref), int64)
    case (281) ! __yoerrtrf_MOD_preflog
      pending%address = c_loc(state%longwave_reference%preflog(lbound(state%longwave_reference%preflog, 1)))
      pending%bytes = 472_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reference%preflog), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reference%preflog), int64)
    case (282) ! __yoerrtrf_MOD_tref
      pending%address = c_loc(state%longwave_reference%tref(lbound(state%longwave_reference%tref, 1)))
      pending%bytes = 472_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_reference%tref), int64)
      pending%upper(1:1) = int(ubound(state%longwave_reference%tref), int64)
    case (283) ! __yoerrtrf_MOD_chi_mls
pending%address=c_loc(state%longwave_reference%chi_mls(lbound(state%longwave_reference%chi_mls,1),lbound(state%longwave_reference%chi_mls,2)))
      pending%bytes = 3304_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_reference%chi_mls), int64)
      pending%upper(1:2) = int(ubound(state%longwave_reference%chi_mls), int64)
    case (284) ! __yoesrtwn_MOD_ng
      pending%address = c_loc(state%shortwave_absorption%ng(lbound(state%shortwave_absorption%ng, 1)))
      pending%bytes = 56_c_int64_t
      pending%rank = 1; pending%element_bytes = 4; pending%type_code = 1
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%ng), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%ng), int64)
    case (285) ! __yoesrtwn_MOD_nspa
      pending%address = c_loc(state%shortwave_absorption%nspa(lbound(state%shortwave_absorption%nspa, 1)))
      pending%bytes = 56_c_int64_t
      pending%rank = 1; pending%element_bytes = 4; pending%type_code = 1
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%nspa), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%nspa), int64)
    case (286) ! __yoesrtwn_MOD_nspb
      pending%address = c_loc(state%shortwave_absorption%nspb(lbound(state%shortwave_absorption%nspb, 1)))
      pending%bytes = 56_c_int64_t
      pending%rank = 1; pending%element_bytes = 4; pending%type_code = 1
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%nspb), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%nspb), int64)
    case (287) ! __yoesrtwn_MOD_nmpsrtm
      pending%address = c_loc(state%shortwave_absorption%nmpsrtm(lbound(state%shortwave_absorption%nmpsrtm, 1)))
      pending%bytes = 56_c_int64_t
      pending%rank = 1; pending%element_bytes = 4; pending%type_code = 1
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%nmpsrtm), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%nmpsrtm), int64)
    case (288) ! __yoesrtwn_MOD_pref
      pending%address = c_loc(state%shortwave_absorption%pref(lbound(state%shortwave_absorption%pref, 1)))
      pending%bytes = 472_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%pref), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%pref), int64)
    case (289) ! __yoesrtwn_MOD_preflog
      pending%address = c_loc(state%shortwave_absorption%preflog(lbound(state%shortwave_absorption%preflog, 1)))
      pending%bytes = 472_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%preflog), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%preflog), int64)
    case (290) ! __yoesrtwn_MOD_tref
      pending%address = c_loc(state%shortwave_absorption%tref(lbound(state%shortwave_absorption%tref, 1)))
      pending%bytes = 472_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%tref), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%tref), int64)
    case (291) ! __yoesrtwn_MOD_ngm
      pending%address = c_loc(state%shortwave_absorption%ngm(lbound(state%shortwave_absorption%ngm, 1)))
      pending%bytes = 896_c_int64_t
      pending%rank = 1; pending%element_bytes = 4; pending%type_code = 1
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%ngm), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%ngm), int64)
    case (292) ! __yoesrtwn_MOD_ngc
      pending%address = c_loc(state%shortwave_absorption%ngc(lbound(state%shortwave_absorption%ngc, 1)))
      pending%bytes = 56_c_int64_t
      pending%rank = 1; pending%element_bytes = 4; pending%type_code = 1
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%ngc), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%ngc), int64)
    case (293) ! __yoesrtwn_MOD_ngs
      pending%address = c_loc(state%shortwave_absorption%ngs(lbound(state%shortwave_absorption%ngs, 1)))
      pending%bytes = 56_c_int64_t
      pending%rank = 1; pending%element_bytes = 4; pending%type_code = 1
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%ngs), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%ngs), int64)
    case (294) ! __yoesrtwn_MOD_wt
      pending%address = c_loc(state%shortwave_absorption%wt(lbound(state%shortwave_absorption%wt, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%wt), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%wt), int64)
    case (295) ! __yoesrtwn_MOD_wtsm
      pending%address = c_loc(state%shortwave_absorption%wtsm(lbound(state%shortwave_absorption%wtsm, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%wtsm), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%wtsm), int64)
    case (296) ! __yoesrtwn_MOD_rwgt
      pending%address = c_loc(state%shortwave_absorption%rwgt(lbound(state%shortwave_absorption%rwgt, 1)))
      pending%bytes = 1792_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%rwgt), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%rwgt), int64)
    case (297) ! __yoesrtm_MOD_ngn
      pending%address = c_loc(state%shortwave_absorption%ngn(lbound(state%shortwave_absorption%ngn, 1)))
      pending%bytes = 896_c_int64_t
      pending%rank = 1; pending%element_bytes = 4; pending%type_code = 1
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%ngn), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%ngn), int64)
    case (298) ! __yoesrtm_MOD_ngbsw
      pending%address = c_loc(state%shortwave_absorption%ngbsw(lbound(state%shortwave_absorption%ngbsw, 1)))
      pending%bytes = 896_c_int64_t
      pending%rank = 1; pending%element_bytes = 4; pending%type_code = 1
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%ngbsw), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%ngbsw), int64)
    case (299) ! __yoesrta16_MOD_ka
pending%address=c_loc(state%shortwave_absorption%b16_ka(lbound(state%shortwave_absorption%b16_ka,1),lbound(state%shortwave_absorption%b16_ka,2),lbound(state%shortwave_absorption%b16_ka,3),lbound(state%shortwave_absorption%b16_ka,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b16_ka), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b16_ka), int64)
    case (300) ! __yoesrta16_MOD_kb
pending%address=c_loc(state%shortwave_absorption%b16_kb(lbound(state%shortwave_absorption%b16_kb,1),lbound(state%shortwave_absorption%b16_kb,2),lbound(state%shortwave_absorption%b16_kb,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b16_kb), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b16_kb), int64)
    case (301) ! __yoesrta16_MOD_ka_d
pending%address=c_loc(state%shortwave_absorption%b16_ka_d(lbound(state%shortwave_absorption%b16_ka_d,1),lbound(state%shortwave_absorption%b16_ka_d,2),lbound(state%shortwave_absorption%b16_ka_d,3),lbound(state%shortwave_absorption%b16_ka_d,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b16_ka_d), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b16_ka_d), int64)
    case (302) ! __yoesrta16_MOD_kb_d
pending%address=c_loc(state%shortwave_absorption%b16_kb_d(lbound(state%shortwave_absorption%b16_kb_d,1),lbound(state%shortwave_absorption%b16_kb_d,2),lbound(state%shortwave_absorption%b16_kb_d,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b16_kb_d), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b16_kb_d), int64)
    case (303) ! __yoesrta16_MOD_selfref
pending%address=c_loc(state%shortwave_absorption%b16_selfref(lbound(state%shortwave_absorption%b16_selfref,1),lbound(state%shortwave_absorption%b16_selfref,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b16_selfref), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b16_selfref), int64)
    case (304) ! __yoesrta16_MOD_forref
pending%address=c_loc(state%shortwave_absorption%b16_forref(lbound(state%shortwave_absorption%b16_forref,1),lbound(state%shortwave_absorption%b16_forref,2)))
      pending%bytes = 384_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b16_forref), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b16_forref), int64)
    case (305) ! __yoesrta16_MOD_sfluxref
      pending%address = c_loc(state%shortwave_absorption%b16_sfluxref(lbound(state%shortwave_absorption%b16_sfluxref, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b16_sfluxref), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b16_sfluxref), int64)
    case (306) ! __yoesrta16_MOD_rayl
      pending%address = c_loc(state%shortwave_absorption%b16_rayl)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (307) ! __yoesrta16_MOD_strrat1
      pending%address = c_loc(state%shortwave_absorption%b16_strrat1)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (308) ! __yoesrta16_MOD_layreffr
      pending%address = c_loc(state%shortwave_absorption%b16_layreffr)
      pending%bytes = 4_c_int64_t
      pending%rank = 0; pending%element_bytes = 4; pending%type_code = 1
    case (309) ! yoesrta16.eq.1_
pending%address=c_loc(state%shortwave_absorption%b16_kac(lbound(state%shortwave_absorption%b16_kac,1),lbound(state%shortwave_absorption%b16_kac,2),lbound(state%shortwave_absorption%b16_kac,3),lbound(state%shortwave_absorption%b16_kac,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b16_kac), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b16_kac), int64)
    case (310) ! yoesrta16.eq.0_
pending%address=c_loc(state%shortwave_absorption%b16_kbc(lbound(state%shortwave_absorption%b16_kbc,1),lbound(state%shortwave_absorption%b16_kbc,2),lbound(state%shortwave_absorption%b16_kbc,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b16_kbc), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b16_kbc), int64)
    case (311) ! __yoesrta16_MOD_selfrefc
pending%address=c_loc(state%shortwave_absorption%b16_selfrefc(lbound(state%shortwave_absorption%b16_selfrefc,1),lbound(state%shortwave_absorption%b16_selfrefc,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b16_selfrefc), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b16_selfrefc), int64)
    case (312) ! __yoesrta16_MOD_forrefc
pending%address=c_loc(state%shortwave_absorption%b16_forrefc(lbound(state%shortwave_absorption%b16_forrefc,1),lbound(state%shortwave_absorption%b16_forrefc,2)))
      pending%bytes = 384_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b16_forrefc), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b16_forrefc), int64)
    case (313) ! __yoesrta16_MOD_sfluxrefc
      pending%address = c_loc(state%shortwave_absorption%b16_sfluxrefc(lbound(state%shortwave_absorption%b16_sfluxrefc, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b16_sfluxrefc), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b16_sfluxrefc), int64)
    case (314) ! __yoesrta17_MOD_ka
pending%address=c_loc(state%shortwave_absorption%b17_ka(lbound(state%shortwave_absorption%b17_ka,1),lbound(state%shortwave_absorption%b17_ka,2),lbound(state%shortwave_absorption%b17_ka,3),lbound(state%shortwave_absorption%b17_ka,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b17_ka), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b17_ka), int64)
    case (315) ! __yoesrta17_MOD_kb
pending%address=c_loc(state%shortwave_absorption%b17_kb(lbound(state%shortwave_absorption%b17_kb,1),lbound(state%shortwave_absorption%b17_kb,2),lbound(state%shortwave_absorption%b17_kb,3),lbound(state%shortwave_absorption%b17_kb,4)))
      pending%bytes = 150400_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b17_kb), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b17_kb), int64)
    case (316) ! __yoesrta17_MOD_ka_d
pending%address=c_loc(state%shortwave_absorption%b17_ka_d(lbound(state%shortwave_absorption%b17_ka_d,1),lbound(state%shortwave_absorption%b17_ka_d,2),lbound(state%shortwave_absorption%b17_ka_d,3),lbound(state%shortwave_absorption%b17_ka_d,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b17_ka_d), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b17_ka_d), int64)
    case (317) ! __yoesrta17_MOD_kb_d
pending%address=c_loc(state%shortwave_absorption%b17_kb_d(lbound(state%shortwave_absorption%b17_kb_d,1),lbound(state%shortwave_absorption%b17_kb_d,2),lbound(state%shortwave_absorption%b17_kb_d,3),lbound(state%shortwave_absorption%b17_kb_d,4)))
      pending%bytes = 150400_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b17_kb_d), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b17_kb_d), int64)
    case (318) ! __yoesrta17_MOD_selfref
pending%address=c_loc(state%shortwave_absorption%b17_selfref(lbound(state%shortwave_absorption%b17_selfref,1),lbound(state%shortwave_absorption%b17_selfref,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b17_selfref), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b17_selfref), int64)
    case (319) ! __yoesrta17_MOD_forref
pending%address=c_loc(state%shortwave_absorption%b17_forref(lbound(state%shortwave_absorption%b17_forref,1),lbound(state%shortwave_absorption%b17_forref,2)))
      pending%bytes = 512_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b17_forref), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b17_forref), int64)
    case (320) ! __yoesrta17_MOD_sfluxref
pending%address=c_loc(state%shortwave_absorption%b17_sfluxref(lbound(state%shortwave_absorption%b17_sfluxref,1),lbound(state%shortwave_absorption%b17_sfluxref,2)))
      pending%bytes = 640_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b17_sfluxref), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b17_sfluxref), int64)
    case (321) ! __yoesrta17_MOD_rayl
      pending%address = c_loc(state%shortwave_absorption%b17_rayl)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (322) ! __yoesrta17_MOD_strrat
      pending%address = c_loc(state%shortwave_absorption%b17_strrat)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (323) ! __yoesrta17_MOD_layreffr
      pending%address = c_loc(state%shortwave_absorption%b17_layreffr)
      pending%bytes = 4_c_int64_t
      pending%rank = 0; pending%element_bytes = 4; pending%type_code = 1
    case (324) ! yoesrta17.eq.1_
pending%address=c_loc(state%shortwave_absorption%b17_kac(lbound(state%shortwave_absorption%b17_kac,1),lbound(state%shortwave_absorption%b17_kac,2),lbound(state%shortwave_absorption%b17_kac,3),lbound(state%shortwave_absorption%b17_kac,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b17_kac), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b17_kac), int64)
    case (325) ! yoesrta17.eq.0_
pending%address=c_loc(state%shortwave_absorption%b17_kbc(lbound(state%shortwave_absorption%b17_kbc,1),lbound(state%shortwave_absorption%b17_kbc,2),lbound(state%shortwave_absorption%b17_kbc,3),lbound(state%shortwave_absorption%b17_kbc,4)))
      pending%bytes = 150400_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b17_kbc), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b17_kbc), int64)
    case (326) ! __yoesrta17_MOD_selfrefc
pending%address=c_loc(state%shortwave_absorption%b17_selfrefc(lbound(state%shortwave_absorption%b17_selfrefc,1),lbound(state%shortwave_absorption%b17_selfrefc,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b17_selfrefc), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b17_selfrefc), int64)
    case (327) ! __yoesrta17_MOD_forrefc
pending%address=c_loc(state%shortwave_absorption%b17_forrefc(lbound(state%shortwave_absorption%b17_forrefc,1),lbound(state%shortwave_absorption%b17_forrefc,2)))
      pending%bytes = 512_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b17_forrefc), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b17_forrefc), int64)
    case (328) ! __yoesrta17_MOD_sfluxrefc
pending%address=c_loc(state%shortwave_absorption%b17_sfluxrefc(lbound(state%shortwave_absorption%b17_sfluxrefc,1),lbound(state%shortwave_absorption%b17_sfluxrefc,2)))
      pending%bytes = 640_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b17_sfluxrefc), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b17_sfluxrefc), int64)
    case (329) ! __yoesrta18_MOD_ka
pending%address=c_loc(state%shortwave_absorption%b18_ka(lbound(state%shortwave_absorption%b18_ka,1),lbound(state%shortwave_absorption%b18_ka,2),lbound(state%shortwave_absorption%b18_ka,3),lbound(state%shortwave_absorption%b18_ka,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b18_ka), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b18_ka), int64)
    case (330) ! __yoesrta18_MOD_kb
pending%address=c_loc(state%shortwave_absorption%b18_kb(lbound(state%shortwave_absorption%b18_kb,1),lbound(state%shortwave_absorption%b18_kb,2),lbound(state%shortwave_absorption%b18_kb,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b18_kb), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b18_kb), int64)
    case (331) ! __yoesrta18_MOD_ka_d
pending%address=c_loc(state%shortwave_absorption%b18_ka_d(lbound(state%shortwave_absorption%b18_ka_d,1),lbound(state%shortwave_absorption%b18_ka_d,2),lbound(state%shortwave_absorption%b18_ka_d,3),lbound(state%shortwave_absorption%b18_ka_d,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b18_ka_d), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b18_ka_d), int64)
    case (332) ! __yoesrta18_MOD_kb_d
pending%address=c_loc(state%shortwave_absorption%b18_kb_d(lbound(state%shortwave_absorption%b18_kb_d,1),lbound(state%shortwave_absorption%b18_kb_d,2),lbound(state%shortwave_absorption%b18_kb_d,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b18_kb_d), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b18_kb_d), int64)
    case (333) ! __yoesrta18_MOD_selfref
pending%address=c_loc(state%shortwave_absorption%b18_selfref(lbound(state%shortwave_absorption%b18_selfref,1),lbound(state%shortwave_absorption%b18_selfref,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b18_selfref), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b18_selfref), int64)
    case (334) ! __yoesrta18_MOD_forref
pending%address=c_loc(state%shortwave_absorption%b18_forref(lbound(state%shortwave_absorption%b18_forref,1),lbound(state%shortwave_absorption%b18_forref,2)))
      pending%bytes = 384_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b18_forref), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b18_forref), int64)
    case (335) ! __yoesrta18_MOD_sfluxref
pending%address=c_loc(state%shortwave_absorption%b18_sfluxref(lbound(state%shortwave_absorption%b18_sfluxref,1),lbound(state%shortwave_absorption%b18_sfluxref,2)))
      pending%bytes = 1152_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b18_sfluxref), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b18_sfluxref), int64)
    case (336) ! __yoesrta18_MOD_rayl
      pending%address = c_loc(state%shortwave_absorption%b18_rayl)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (337) ! __yoesrta18_MOD_strrat
      pending%address = c_loc(state%shortwave_absorption%b18_strrat)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (338) ! __yoesrta18_MOD_layreffr
      pending%address = c_loc(state%shortwave_absorption%b18_layreffr)
      pending%bytes = 4_c_int64_t
      pending%rank = 0; pending%element_bytes = 4; pending%type_code = 1
    case (339) ! yoesrta18.eq.1_
pending%address=c_loc(state%shortwave_absorption%b18_kac(lbound(state%shortwave_absorption%b18_kac,1),lbound(state%shortwave_absorption%b18_kac,2),lbound(state%shortwave_absorption%b18_kac,3),lbound(state%shortwave_absorption%b18_kac,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b18_kac), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b18_kac), int64)
    case (340) ! yoesrta18.eq.0_
pending%address=c_loc(state%shortwave_absorption%b18_kbc(lbound(state%shortwave_absorption%b18_kbc,1),lbound(state%shortwave_absorption%b18_kbc,2),lbound(state%shortwave_absorption%b18_kbc,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b18_kbc), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b18_kbc), int64)
    case (341) ! __yoesrta18_MOD_selfrefc
pending%address=c_loc(state%shortwave_absorption%b18_selfrefc(lbound(state%shortwave_absorption%b18_selfrefc,1),lbound(state%shortwave_absorption%b18_selfrefc,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b18_selfrefc), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b18_selfrefc), int64)
    case (342) ! __yoesrta18_MOD_forrefc
pending%address=c_loc(state%shortwave_absorption%b18_forrefc(lbound(state%shortwave_absorption%b18_forrefc,1),lbound(state%shortwave_absorption%b18_forrefc,2)))
      pending%bytes = 384_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b18_forrefc), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b18_forrefc), int64)
    case (343) ! __yoesrta18_MOD_sfluxrefc
pending%address=c_loc(state%shortwave_absorption%b18_sfluxrefc(lbound(state%shortwave_absorption%b18_sfluxrefc,1),lbound(state%shortwave_absorption%b18_sfluxrefc,2)))
      pending%bytes = 1152_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b18_sfluxrefc), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b18_sfluxrefc), int64)
    case (344) ! __yoesrta19_MOD_ka
pending%address=c_loc(state%shortwave_absorption%b19_ka(lbound(state%shortwave_absorption%b19_ka,1),lbound(state%shortwave_absorption%b19_ka,2),lbound(state%shortwave_absorption%b19_ka,3),lbound(state%shortwave_absorption%b19_ka,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b19_ka), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b19_ka), int64)
    case (345) ! __yoesrta19_MOD_kb
pending%address=c_loc(state%shortwave_absorption%b19_kb(lbound(state%shortwave_absorption%b19_kb,1),lbound(state%shortwave_absorption%b19_kb,2),lbound(state%shortwave_absorption%b19_kb,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b19_kb), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b19_kb), int64)
    case (346) ! __yoesrta19_MOD_ka_d
pending%address=c_loc(state%shortwave_absorption%b19_ka_d(lbound(state%shortwave_absorption%b19_ka_d,1),lbound(state%shortwave_absorption%b19_ka_d,2),lbound(state%shortwave_absorption%b19_ka_d,3),lbound(state%shortwave_absorption%b19_ka_d,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b19_ka_d), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b19_ka_d), int64)
    case (347) ! __yoesrta19_MOD_kb_d
pending%address=c_loc(state%shortwave_absorption%b19_kb_d(lbound(state%shortwave_absorption%b19_kb_d,1),lbound(state%shortwave_absorption%b19_kb_d,2),lbound(state%shortwave_absorption%b19_kb_d,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b19_kb_d), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b19_kb_d), int64)
    case (348) ! __yoesrta19_MOD_selfref
pending%address=c_loc(state%shortwave_absorption%b19_selfref(lbound(state%shortwave_absorption%b19_selfref,1),lbound(state%shortwave_absorption%b19_selfref,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b19_selfref), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b19_selfref), int64)
    case (349) ! __yoesrta19_MOD_forref
pending%address=c_loc(state%shortwave_absorption%b19_forref(lbound(state%shortwave_absorption%b19_forref,1),lbound(state%shortwave_absorption%b19_forref,2)))
      pending%bytes = 384_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b19_forref), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b19_forref), int64)
    case (350) ! __yoesrta19_MOD_sfluxref
pending%address=c_loc(state%shortwave_absorption%b19_sfluxref(lbound(state%shortwave_absorption%b19_sfluxref,1),lbound(state%shortwave_absorption%b19_sfluxref,2)))
      pending%bytes = 1152_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b19_sfluxref), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b19_sfluxref), int64)
    case (351) ! __yoesrta19_MOD_rayl
      pending%address = c_loc(state%shortwave_absorption%b19_rayl)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (352) ! __yoesrta19_MOD_strrat
      pending%address = c_loc(state%shortwave_absorption%b19_strrat)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (353) ! __yoesrta19_MOD_layreffr
      pending%address = c_loc(state%shortwave_absorption%b19_layreffr)
      pending%bytes = 4_c_int64_t
      pending%rank = 0; pending%element_bytes = 4; pending%type_code = 1
    case (354) ! yoesrta19.eq.1_
pending%address=c_loc(state%shortwave_absorption%b19_kac(lbound(state%shortwave_absorption%b19_kac,1),lbound(state%shortwave_absorption%b19_kac,2),lbound(state%shortwave_absorption%b19_kac,3),lbound(state%shortwave_absorption%b19_kac,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b19_kac), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b19_kac), int64)
    case (355) ! yoesrta19.eq.0_
pending%address=c_loc(state%shortwave_absorption%b19_kbc(lbound(state%shortwave_absorption%b19_kbc,1),lbound(state%shortwave_absorption%b19_kbc,2),lbound(state%shortwave_absorption%b19_kbc,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b19_kbc), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b19_kbc), int64)
    case (356) ! __yoesrta19_MOD_selfrefc
pending%address=c_loc(state%shortwave_absorption%b19_selfrefc(lbound(state%shortwave_absorption%b19_selfrefc,1),lbound(state%shortwave_absorption%b19_selfrefc,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b19_selfrefc), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b19_selfrefc), int64)
    case (357) ! __yoesrta19_MOD_forrefc
pending%address=c_loc(state%shortwave_absorption%b19_forrefc(lbound(state%shortwave_absorption%b19_forrefc,1),lbound(state%shortwave_absorption%b19_forrefc,2)))
      pending%bytes = 384_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b19_forrefc), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b19_forrefc), int64)
    case (358) ! __yoesrta19_MOD_sfluxrefc
pending%address=c_loc(state%shortwave_absorption%b19_sfluxrefc(lbound(state%shortwave_absorption%b19_sfluxrefc,1),lbound(state%shortwave_absorption%b19_sfluxrefc,2)))
      pending%bytes = 1152_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b19_sfluxrefc), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b19_sfluxrefc), int64)
    case (359) ! __yoesrta20_MOD_ka
pending%address=c_loc(state%shortwave_absorption%b20_ka(lbound(state%shortwave_absorption%b20_ka,1),lbound(state%shortwave_absorption%b20_ka,2),lbound(state%shortwave_absorption%b20_ka,3)))
      pending%bytes = 8320_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b20_ka), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b20_ka), int64)
    case (360) ! __yoesrta20_MOD_kb
pending%address=c_loc(state%shortwave_absorption%b20_kb(lbound(state%shortwave_absorption%b20_kb,1),lbound(state%shortwave_absorption%b20_kb,2),lbound(state%shortwave_absorption%b20_kb,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b20_kb), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b20_kb), int64)
    case (361) ! __yoesrta20_MOD_ka_d
pending%address=c_loc(state%shortwave_absorption%b20_ka_d(lbound(state%shortwave_absorption%b20_ka_d,1),lbound(state%shortwave_absorption%b20_ka_d,2),lbound(state%shortwave_absorption%b20_ka_d,3)))
      pending%bytes = 8320_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b20_ka_d), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b20_ka_d), int64)
    case (362) ! __yoesrta20_MOD_kb_d
pending%address=c_loc(state%shortwave_absorption%b20_kb_d(lbound(state%shortwave_absorption%b20_kb_d,1),lbound(state%shortwave_absorption%b20_kb_d,2),lbound(state%shortwave_absorption%b20_kb_d,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b20_kb_d), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b20_kb_d), int64)
    case (363) ! __yoesrta20_MOD_selfref
pending%address=c_loc(state%shortwave_absorption%b20_selfref(lbound(state%shortwave_absorption%b20_selfref,1),lbound(state%shortwave_absorption%b20_selfref,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b20_selfref), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b20_selfref), int64)
    case (364) ! __yoesrta20_MOD_forref
pending%address=c_loc(state%shortwave_absorption%b20_forref(lbound(state%shortwave_absorption%b20_forref,1),lbound(state%shortwave_absorption%b20_forref,2)))
      pending%bytes = 512_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b20_forref), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b20_forref), int64)
    case (365) ! __yoesrta20_MOD_sfluxref
      pending%address = c_loc(state%shortwave_absorption%b20_sfluxref(lbound(state%shortwave_absorption%b20_sfluxref, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b20_sfluxref), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b20_sfluxref), int64)
    case (366) ! __yoesrta20_MOD_absch4
      pending%address = c_loc(state%shortwave_absorption%b20_absch4(lbound(state%shortwave_absorption%b20_absch4, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b20_absch4), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b20_absch4), int64)
    case (367) ! __yoesrta20_MOD_rayl
      pending%address = c_loc(state%shortwave_absorption%b20_rayl)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (368) ! __yoesrta20_MOD_layreffr
      pending%address = c_loc(state%shortwave_absorption%b20_layreffr)
      pending%bytes = 4_c_int64_t
      pending%rank = 0; pending%element_bytes = 4; pending%type_code = 1
    case (369) ! yoesrta20.eq.1_
pending%address=c_loc(state%shortwave_absorption%b20_kac(lbound(state%shortwave_absorption%b20_kac,1),lbound(state%shortwave_absorption%b20_kac,2),lbound(state%shortwave_absorption%b20_kac,3)))
      pending%bytes = 8320_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b20_kac), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b20_kac), int64)
    case (370) ! yoesrta20.eq.0_
pending%address=c_loc(state%shortwave_absorption%b20_kbc(lbound(state%shortwave_absorption%b20_kbc,1),lbound(state%shortwave_absorption%b20_kbc,2),lbound(state%shortwave_absorption%b20_kbc,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b20_kbc), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b20_kbc), int64)
    case (371) ! __yoesrta20_MOD_selfrefc
pending%address=c_loc(state%shortwave_absorption%b20_selfrefc(lbound(state%shortwave_absorption%b20_selfrefc,1),lbound(state%shortwave_absorption%b20_selfrefc,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b20_selfrefc), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b20_selfrefc), int64)
    case (372) ! __yoesrta20_MOD_forrefc
pending%address=c_loc(state%shortwave_absorption%b20_forrefc(lbound(state%shortwave_absorption%b20_forrefc,1),lbound(state%shortwave_absorption%b20_forrefc,2)))
      pending%bytes = 512_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b20_forrefc), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b20_forrefc), int64)
    case (373) ! __yoesrta20_MOD_sfluxrefc
      pending%address = c_loc(state%shortwave_absorption%b20_sfluxrefc(lbound(state%shortwave_absorption%b20_sfluxrefc, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b20_sfluxrefc), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b20_sfluxrefc), int64)
    case (374) ! __yoesrta20_MOD_absch4c
      pending%address = c_loc(state%shortwave_absorption%b20_absch4c(lbound(state%shortwave_absorption%b20_absch4c, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b20_absch4c), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b20_absch4c), int64)
    case (375) ! __yoesrta21_MOD_ka
pending%address=c_loc(state%shortwave_absorption%b21_ka(lbound(state%shortwave_absorption%b21_ka,1),lbound(state%shortwave_absorption%b21_ka,2),lbound(state%shortwave_absorption%b21_ka,3),lbound(state%shortwave_absorption%b21_ka,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b21_ka), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b21_ka), int64)
    case (376) ! __yoesrta21_MOD_kb
pending%address=c_loc(state%shortwave_absorption%b21_kb(lbound(state%shortwave_absorption%b21_kb,1),lbound(state%shortwave_absorption%b21_kb,2),lbound(state%shortwave_absorption%b21_kb,3),lbound(state%shortwave_absorption%b21_kb,4)))
      pending%bytes = 150400_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b21_kb), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b21_kb), int64)
    case (377) ! __yoesrta21_MOD_ka_d
pending%address=c_loc(state%shortwave_absorption%b21_ka_d(lbound(state%shortwave_absorption%b21_ka_d,1),lbound(state%shortwave_absorption%b21_ka_d,2),lbound(state%shortwave_absorption%b21_ka_d,3),lbound(state%shortwave_absorption%b21_ka_d,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b21_ka_d), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b21_ka_d), int64)
    case (378) ! __yoesrta21_MOD_kb_d
pending%address=c_loc(state%shortwave_absorption%b21_kb_d(lbound(state%shortwave_absorption%b21_kb_d,1),lbound(state%shortwave_absorption%b21_kb_d,2),lbound(state%shortwave_absorption%b21_kb_d,3),lbound(state%shortwave_absorption%b21_kb_d,4)))
      pending%bytes = 150400_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b21_kb_d), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b21_kb_d), int64)
    case (379) ! __yoesrta21_MOD_selfref
pending%address=c_loc(state%shortwave_absorption%b21_selfref(lbound(state%shortwave_absorption%b21_selfref,1),lbound(state%shortwave_absorption%b21_selfref,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b21_selfref), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b21_selfref), int64)
    case (380) ! __yoesrta21_MOD_forref
pending%address=c_loc(state%shortwave_absorption%b21_forref(lbound(state%shortwave_absorption%b21_forref,1),lbound(state%shortwave_absorption%b21_forref,2)))
      pending%bytes = 512_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b21_forref), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b21_forref), int64)
    case (381) ! __yoesrta21_MOD_sfluxref
pending%address=c_loc(state%shortwave_absorption%b21_sfluxref(lbound(state%shortwave_absorption%b21_sfluxref,1),lbound(state%shortwave_absorption%b21_sfluxref,2)))
      pending%bytes = 1152_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b21_sfluxref), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b21_sfluxref), int64)
    case (382) ! __yoesrta21_MOD_rayl
      pending%address = c_loc(state%shortwave_absorption%b21_rayl)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (383) ! __yoesrta21_MOD_strrat
      pending%address = c_loc(state%shortwave_absorption%b21_strrat)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (384) ! __yoesrta21_MOD_layreffr
      pending%address = c_loc(state%shortwave_absorption%b21_layreffr)
      pending%bytes = 4_c_int64_t
      pending%rank = 0; pending%element_bytes = 4; pending%type_code = 1
    case (385) ! yoesrta21.eq.1_
pending%address=c_loc(state%shortwave_absorption%b21_kac(lbound(state%shortwave_absorption%b21_kac,1),lbound(state%shortwave_absorption%b21_kac,2),lbound(state%shortwave_absorption%b21_kac,3),lbound(state%shortwave_absorption%b21_kac,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b21_kac), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b21_kac), int64)
    case (386) ! yoesrta21.eq.0_
pending%address=c_loc(state%shortwave_absorption%b21_kbc(lbound(state%shortwave_absorption%b21_kbc,1),lbound(state%shortwave_absorption%b21_kbc,2),lbound(state%shortwave_absorption%b21_kbc,3),lbound(state%shortwave_absorption%b21_kbc,4)))
      pending%bytes = 150400_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b21_kbc), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b21_kbc), int64)
    case (387) ! __yoesrta21_MOD_selfrefc
pending%address=c_loc(state%shortwave_absorption%b21_selfrefc(lbound(state%shortwave_absorption%b21_selfrefc,1),lbound(state%shortwave_absorption%b21_selfrefc,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b21_selfrefc), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b21_selfrefc), int64)
    case (388) ! __yoesrta21_MOD_forrefc
pending%address=c_loc(state%shortwave_absorption%b21_forrefc(lbound(state%shortwave_absorption%b21_forrefc,1),lbound(state%shortwave_absorption%b21_forrefc,2)))
      pending%bytes = 512_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b21_forrefc), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b21_forrefc), int64)
    case (389) ! __yoesrta21_MOD_sfluxrefc
pending%address=c_loc(state%shortwave_absorption%b21_sfluxrefc(lbound(state%shortwave_absorption%b21_sfluxrefc,1),lbound(state%shortwave_absorption%b21_sfluxrefc,2)))
      pending%bytes = 1152_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b21_sfluxrefc), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b21_sfluxrefc), int64)
    case (390) ! __yoesrta22_MOD_ka
pending%address=c_loc(state%shortwave_absorption%b22_ka(lbound(state%shortwave_absorption%b22_ka,1),lbound(state%shortwave_absorption%b22_ka,2),lbound(state%shortwave_absorption%b22_ka,3),lbound(state%shortwave_absorption%b22_ka,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b22_ka), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b22_ka), int64)
    case (391) ! __yoesrta22_MOD_kb
pending%address=c_loc(state%shortwave_absorption%b22_kb(lbound(state%shortwave_absorption%b22_kb,1),lbound(state%shortwave_absorption%b22_kb,2),lbound(state%shortwave_absorption%b22_kb,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b22_kb), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b22_kb), int64)
    case (392) ! __yoesrta22_MOD_ka_d
pending%address=c_loc(state%shortwave_absorption%b22_ka_d(lbound(state%shortwave_absorption%b22_ka_d,1),lbound(state%shortwave_absorption%b22_ka_d,2),lbound(state%shortwave_absorption%b22_ka_d,3),lbound(state%shortwave_absorption%b22_ka_d,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b22_ka_d), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b22_ka_d), int64)
    case (393) ! __yoesrta22_MOD_kb_d
pending%address=c_loc(state%shortwave_absorption%b22_kb_d(lbound(state%shortwave_absorption%b22_kb_d,1),lbound(state%shortwave_absorption%b22_kb_d,2),lbound(state%shortwave_absorption%b22_kb_d,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b22_kb_d), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b22_kb_d), int64)
    case (394) ! __yoesrta22_MOD_selfref
pending%address=c_loc(state%shortwave_absorption%b22_selfref(lbound(state%shortwave_absorption%b22_selfref,1),lbound(state%shortwave_absorption%b22_selfref,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b22_selfref), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b22_selfref), int64)
    case (395) ! __yoesrta22_MOD_forref
pending%address=c_loc(state%shortwave_absorption%b22_forref(lbound(state%shortwave_absorption%b22_forref,1),lbound(state%shortwave_absorption%b22_forref,2)))
      pending%bytes = 384_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b22_forref), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b22_forref), int64)
    case (396) ! __yoesrta22_MOD_sfluxref
pending%address=c_loc(state%shortwave_absorption%b22_sfluxref(lbound(state%shortwave_absorption%b22_sfluxref,1),lbound(state%shortwave_absorption%b22_sfluxref,2)))
      pending%bytes = 1152_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b22_sfluxref), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b22_sfluxref), int64)
    case (397) ! __yoesrta22_MOD_rayl
      pending%address = c_loc(state%shortwave_absorption%b22_rayl)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (398) ! __yoesrta22_MOD_strrat
      pending%address = c_loc(state%shortwave_absorption%b22_strrat)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (399) ! __yoesrta22_MOD_layreffr
      pending%address = c_loc(state%shortwave_absorption%b22_layreffr)
      pending%bytes = 4_c_int64_t
      pending%rank = 0; pending%element_bytes = 4; pending%type_code = 1
    case (400) ! yoesrta22.eq.1_
pending%address=c_loc(state%shortwave_absorption%b22_kac(lbound(state%shortwave_absorption%b22_kac,1),lbound(state%shortwave_absorption%b22_kac,2),lbound(state%shortwave_absorption%b22_kac,3),lbound(state%shortwave_absorption%b22_kac,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b22_kac), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b22_kac), int64)
    case (401) ! yoesrta22.eq.0_
pending%address=c_loc(state%shortwave_absorption%b22_kbc(lbound(state%shortwave_absorption%b22_kbc,1),lbound(state%shortwave_absorption%b22_kbc,2),lbound(state%shortwave_absorption%b22_kbc,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b22_kbc), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b22_kbc), int64)
    case (402) ! __yoesrta22_MOD_selfrefc
pending%address=c_loc(state%shortwave_absorption%b22_selfrefc(lbound(state%shortwave_absorption%b22_selfrefc,1),lbound(state%shortwave_absorption%b22_selfrefc,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b22_selfrefc), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b22_selfrefc), int64)
    case (403) ! __yoesrta22_MOD_forrefc
pending%address=c_loc(state%shortwave_absorption%b22_forrefc(lbound(state%shortwave_absorption%b22_forrefc,1),lbound(state%shortwave_absorption%b22_forrefc,2)))
      pending%bytes = 384_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b22_forrefc), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b22_forrefc), int64)
    case (404) ! __yoesrta22_MOD_sfluxrefc
pending%address=c_loc(state%shortwave_absorption%b22_sfluxrefc(lbound(state%shortwave_absorption%b22_sfluxrefc,1),lbound(state%shortwave_absorption%b22_sfluxrefc,2)))
      pending%bytes = 1152_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b22_sfluxrefc), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b22_sfluxrefc), int64)
    case (405) ! __yoesrta23_MOD_ka
pending%address=c_loc(state%shortwave_absorption%b23_ka(lbound(state%shortwave_absorption%b23_ka,1),lbound(state%shortwave_absorption%b23_ka,2),lbound(state%shortwave_absorption%b23_ka,3)))
      pending%bytes = 8320_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b23_ka), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b23_ka), int64)
    case (406) ! __yoesrta23_MOD_ka_d
pending%address=c_loc(state%shortwave_absorption%b23_ka_d(lbound(state%shortwave_absorption%b23_ka_d,1),lbound(state%shortwave_absorption%b23_ka_d,2),lbound(state%shortwave_absorption%b23_ka_d,3)))
      pending%bytes = 8320_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b23_ka_d), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b23_ka_d), int64)
    case (407) ! __yoesrta23_MOD_selfref
pending%address=c_loc(state%shortwave_absorption%b23_selfref(lbound(state%shortwave_absorption%b23_selfref,1),lbound(state%shortwave_absorption%b23_selfref,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b23_selfref), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b23_selfref), int64)
    case (408) ! __yoesrta23_MOD_forref
pending%address=c_loc(state%shortwave_absorption%b23_forref(lbound(state%shortwave_absorption%b23_forref,1),lbound(state%shortwave_absorption%b23_forref,2)))
      pending%bytes = 384_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b23_forref), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b23_forref), int64)
    case (409) ! __yoesrta23_MOD_sfluxref
      pending%address = c_loc(state%shortwave_absorption%b23_sfluxref(lbound(state%shortwave_absorption%b23_sfluxref, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b23_sfluxref), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b23_sfluxref), int64)
    case (410) ! __yoesrta23_MOD_rayl
      pending%address = c_loc(state%shortwave_absorption%b23_rayl(lbound(state%shortwave_absorption%b23_rayl, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b23_rayl), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b23_rayl), int64)
    case (411) ! __yoesrta23_MOD_givfac
      pending%address = c_loc(state%shortwave_absorption%b23_givfac)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (412) ! __yoesrta23_MOD_layreffr
      pending%address = c_loc(state%shortwave_absorption%b23_layreffr)
      pending%bytes = 4_c_int64_t
      pending%rank = 0; pending%element_bytes = 4; pending%type_code = 1
    case (413) ! yoesrta23.eq.0_
pending%address=c_loc(state%shortwave_absorption%b23_kac(lbound(state%shortwave_absorption%b23_kac,1),lbound(state%shortwave_absorption%b23_kac,2),lbound(state%shortwave_absorption%b23_kac,3)))
      pending%bytes = 8320_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b23_kac), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b23_kac), int64)
    case (414) ! __yoesrta23_MOD_selfrefc
pending%address=c_loc(state%shortwave_absorption%b23_selfrefc(lbound(state%shortwave_absorption%b23_selfrefc,1),lbound(state%shortwave_absorption%b23_selfrefc,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b23_selfrefc), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b23_selfrefc), int64)
    case (415) ! __yoesrta23_MOD_forrefc
pending%address=c_loc(state%shortwave_absorption%b23_forrefc(lbound(state%shortwave_absorption%b23_forrefc,1),lbound(state%shortwave_absorption%b23_forrefc,2)))
      pending%bytes = 384_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b23_forrefc), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b23_forrefc), int64)
    case (416) ! __yoesrta23_MOD_sfluxrefc
      pending%address = c_loc(state%shortwave_absorption%b23_sfluxrefc(lbound(state%shortwave_absorption%b23_sfluxrefc, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b23_sfluxrefc), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b23_sfluxrefc), int64)
    case (417) ! __yoesrta23_MOD_raylc
      pending%address = c_loc(state%shortwave_absorption%b23_raylc(lbound(state%shortwave_absorption%b23_raylc, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b23_raylc), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b23_raylc), int64)
    case (418) ! __yoesrta24_MOD_ka
pending%address=c_loc(state%shortwave_absorption%b24_ka(lbound(state%shortwave_absorption%b24_ka,1),lbound(state%shortwave_absorption%b24_ka,2),lbound(state%shortwave_absorption%b24_ka,3),lbound(state%shortwave_absorption%b24_ka,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b24_ka), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b24_ka), int64)
    case (419) ! __yoesrta24_MOD_kb
pending%address=c_loc(state%shortwave_absorption%b24_kb(lbound(state%shortwave_absorption%b24_kb,1),lbound(state%shortwave_absorption%b24_kb,2),lbound(state%shortwave_absorption%b24_kb,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b24_kb), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b24_kb), int64)
    case (420) ! __yoesrta24_MOD_ka_d
pending%address=c_loc(state%shortwave_absorption%b24_ka_d(lbound(state%shortwave_absorption%b24_ka_d,1),lbound(state%shortwave_absorption%b24_ka_d,2),lbound(state%shortwave_absorption%b24_ka_d,3),lbound(state%shortwave_absorption%b24_ka_d,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b24_ka_d), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b24_ka_d), int64)
    case (421) ! __yoesrta24_MOD_kb_d
pending%address=c_loc(state%shortwave_absorption%b24_kb_d(lbound(state%shortwave_absorption%b24_kb_d,1),lbound(state%shortwave_absorption%b24_kb_d,2),lbound(state%shortwave_absorption%b24_kb_d,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b24_kb_d), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b24_kb_d), int64)
    case (422) ! __yoesrta24_MOD_selfref
pending%address=c_loc(state%shortwave_absorption%b24_selfref(lbound(state%shortwave_absorption%b24_selfref,1),lbound(state%shortwave_absorption%b24_selfref,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b24_selfref), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b24_selfref), int64)
    case (423) ! __yoesrta24_MOD_forref
pending%address=c_loc(state%shortwave_absorption%b24_forref(lbound(state%shortwave_absorption%b24_forref,1),lbound(state%shortwave_absorption%b24_forref,2)))
      pending%bytes = 384_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b24_forref), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b24_forref), int64)
    case (424) ! __yoesrta24_MOD_sfluxref
pending%address=c_loc(state%shortwave_absorption%b24_sfluxref(lbound(state%shortwave_absorption%b24_sfluxref,1),lbound(state%shortwave_absorption%b24_sfluxref,2)))
      pending%bytes = 1152_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b24_sfluxref), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b24_sfluxref), int64)
    case (425) ! __yoesrta24_MOD_abso3a
      pending%address = c_loc(state%shortwave_absorption%b24_abso3a(lbound(state%shortwave_absorption%b24_abso3a, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b24_abso3a), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b24_abso3a), int64)
    case (426) ! __yoesrta24_MOD_abso3b
      pending%address = c_loc(state%shortwave_absorption%b24_abso3b(lbound(state%shortwave_absorption%b24_abso3b, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b24_abso3b), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b24_abso3b), int64)
    case (427) ! __yoesrta24_MOD_rayla
pending%address=c_loc(state%shortwave_absorption%b24_rayla(lbound(state%shortwave_absorption%b24_rayla,1),lbound(state%shortwave_absorption%b24_rayla,2)))
      pending%bytes = 1152_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b24_rayla), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b24_rayla), int64)
    case (428) ! __yoesrta24_MOD_raylb
      pending%address = c_loc(state%shortwave_absorption%b24_raylb(lbound(state%shortwave_absorption%b24_raylb, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b24_raylb), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b24_raylb), int64)
    case (429) ! __yoesrta24_MOD_strrat
      pending%address = c_loc(state%shortwave_absorption%b24_strrat)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (430) ! __yoesrta24_MOD_layreffr
      pending%address = c_loc(state%shortwave_absorption%b24_layreffr)
      pending%bytes = 4_c_int64_t
      pending%rank = 0; pending%element_bytes = 4; pending%type_code = 1
    case (431) ! yoesrta24.eq.1_
pending%address=c_loc(state%shortwave_absorption%b24_kac(lbound(state%shortwave_absorption%b24_kac,1),lbound(state%shortwave_absorption%b24_kac,2),lbound(state%shortwave_absorption%b24_kac,3),lbound(state%shortwave_absorption%b24_kac,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b24_kac), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b24_kac), int64)
    case (432) ! yoesrta24.eq.0_
pending%address=c_loc(state%shortwave_absorption%b24_kbc(lbound(state%shortwave_absorption%b24_kbc,1),lbound(state%shortwave_absorption%b24_kbc,2),lbound(state%shortwave_absorption%b24_kbc,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b24_kbc), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b24_kbc), int64)
    case (433) ! __yoesrta24_MOD_selfrefc
pending%address=c_loc(state%shortwave_absorption%b24_selfrefc(lbound(state%shortwave_absorption%b24_selfrefc,1),lbound(state%shortwave_absorption%b24_selfrefc,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b24_selfrefc), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b24_selfrefc), int64)
    case (434) ! __yoesrta24_MOD_forrefc
pending%address=c_loc(state%shortwave_absorption%b24_forrefc(lbound(state%shortwave_absorption%b24_forrefc,1),lbound(state%shortwave_absorption%b24_forrefc,2)))
      pending%bytes = 384_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b24_forrefc), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b24_forrefc), int64)
    case (435) ! __yoesrta24_MOD_sfluxrefc
pending%address=c_loc(state%shortwave_absorption%b24_sfluxrefc(lbound(state%shortwave_absorption%b24_sfluxrefc,1),lbound(state%shortwave_absorption%b24_sfluxrefc,2)))
      pending%bytes = 1152_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b24_sfluxrefc), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b24_sfluxrefc), int64)
    case (436) ! __yoesrta24_MOD_abso3ac
      pending%address = c_loc(state%shortwave_absorption%b24_abso3ac(lbound(state%shortwave_absorption%b24_abso3ac, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b24_abso3ac), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b24_abso3ac), int64)
    case (437) ! __yoesrta24_MOD_abso3bc
      pending%address = c_loc(state%shortwave_absorption%b24_abso3bc(lbound(state%shortwave_absorption%b24_abso3bc, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b24_abso3bc), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b24_abso3bc), int64)
    case (438) ! __yoesrta24_MOD_raylac
pending%address=c_loc(state%shortwave_absorption%b24_raylac(lbound(state%shortwave_absorption%b24_raylac,1),lbound(state%shortwave_absorption%b24_raylac,2)))
      pending%bytes = 1152_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b24_raylac), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b24_raylac), int64)
    case (439) ! __yoesrta24_MOD_raylbc
      pending%address = c_loc(state%shortwave_absorption%b24_raylbc(lbound(state%shortwave_absorption%b24_raylbc, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b24_raylbc), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b24_raylbc), int64)
    case (440) ! __yoesrta25_MOD_ka
pending%address=c_loc(state%shortwave_absorption%b25_ka(lbound(state%shortwave_absorption%b25_ka,1),lbound(state%shortwave_absorption%b25_ka,2),lbound(state%shortwave_absorption%b25_ka,3)))
      pending%bytes = 8320_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b25_ka), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b25_ka), int64)
    case (441) ! __yoesrta25_MOD_ka_d
pending%address=c_loc(state%shortwave_absorption%b25_ka_d(lbound(state%shortwave_absorption%b25_ka_d,1),lbound(state%shortwave_absorption%b25_ka_d,2),lbound(state%shortwave_absorption%b25_ka_d,3)))
      pending%bytes = 8320_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b25_ka_d), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b25_ka_d), int64)
    case (442) ! __yoesrta25_MOD_sfluxref
      pending%address = c_loc(state%shortwave_absorption%b25_sfluxref(lbound(state%shortwave_absorption%b25_sfluxref, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b25_sfluxref), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b25_sfluxref), int64)
    case (443) ! __yoesrta25_MOD_rayl
      pending%address = c_loc(state%shortwave_absorption%b25_rayl(lbound(state%shortwave_absorption%b25_rayl, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b25_rayl), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b25_rayl), int64)
    case (444) ! __yoesrta25_MOD_abso3a
      pending%address = c_loc(state%shortwave_absorption%b25_abso3a(lbound(state%shortwave_absorption%b25_abso3a, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b25_abso3a), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b25_abso3a), int64)
    case (445) ! __yoesrta25_MOD_abso3b
      pending%address = c_loc(state%shortwave_absorption%b25_abso3b(lbound(state%shortwave_absorption%b25_abso3b, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b25_abso3b), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b25_abso3b), int64)
    case (446) ! __yoesrta25_MOD_layreffr
      pending%address = c_loc(state%shortwave_absorption%b25_layreffr)
      pending%bytes = 4_c_int64_t
      pending%rank = 0; pending%element_bytes = 4; pending%type_code = 1
    case (447) ! yoesrta25.eq.0_
pending%address=c_loc(state%shortwave_absorption%b25_kac(lbound(state%shortwave_absorption%b25_kac,1),lbound(state%shortwave_absorption%b25_kac,2),lbound(state%shortwave_absorption%b25_kac,3)))
      pending%bytes = 8320_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b25_kac), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b25_kac), int64)
    case (448) ! __yoesrta25_MOD_sfluxrefc
      pending%address = c_loc(state%shortwave_absorption%b25_sfluxrefc(lbound(state%shortwave_absorption%b25_sfluxrefc, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b25_sfluxrefc), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b25_sfluxrefc), int64)
    case (449) ! __yoesrta25_MOD_raylc
      pending%address = c_loc(state%shortwave_absorption%b25_raylc(lbound(state%shortwave_absorption%b25_raylc, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b25_raylc), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b25_raylc), int64)
    case (450) ! __yoesrta25_MOD_abso3ac
      pending%address = c_loc(state%shortwave_absorption%b25_abso3ac(lbound(state%shortwave_absorption%b25_abso3ac, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b25_abso3ac), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b25_abso3ac), int64)
    case (451) ! __yoesrta25_MOD_abso3bc
      pending%address = c_loc(state%shortwave_absorption%b25_abso3bc(lbound(state%shortwave_absorption%b25_abso3bc, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b25_abso3bc), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b25_abso3bc), int64)
    case (452) ! __yoesrta26_MOD_sfluxref
      pending%address = c_loc(state%shortwave_absorption%b26_sfluxref(lbound(state%shortwave_absorption%b26_sfluxref, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b26_sfluxref), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b26_sfluxref), int64)
    case (453) ! __yoesrta26_MOD_rayl
      pending%address = c_loc(state%shortwave_absorption%b26_rayl(lbound(state%shortwave_absorption%b26_rayl, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b26_rayl), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b26_rayl), int64)
    case (454) ! __yoesrta26_MOD_sfluxrefc
      pending%address = c_loc(state%shortwave_absorption%b26_sfluxrefc(lbound(state%shortwave_absorption%b26_sfluxrefc, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b26_sfluxrefc), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b26_sfluxrefc), int64)
    case (455) ! __yoesrta26_MOD_raylc
      pending%address = c_loc(state%shortwave_absorption%b26_raylc(lbound(state%shortwave_absorption%b26_raylc, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b26_raylc), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b26_raylc), int64)
    case (456) ! __yoesrta27_MOD_ka
pending%address=c_loc(state%shortwave_absorption%b27_ka(lbound(state%shortwave_absorption%b27_ka,1),lbound(state%shortwave_absorption%b27_ka,2),lbound(state%shortwave_absorption%b27_ka,3)))
      pending%bytes = 8320_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b27_ka), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b27_ka), int64)
    case (457) ! __yoesrta27_MOD_kb
pending%address=c_loc(state%shortwave_absorption%b27_kb(lbound(state%shortwave_absorption%b27_kb,1),lbound(state%shortwave_absorption%b27_kb,2),lbound(state%shortwave_absorption%b27_kb,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b27_kb), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b27_kb), int64)
    case (458) ! __yoesrta27_MOD_ka_d
pending%address=c_loc(state%shortwave_absorption%b27_ka_d(lbound(state%shortwave_absorption%b27_ka_d,1),lbound(state%shortwave_absorption%b27_ka_d,2),lbound(state%shortwave_absorption%b27_ka_d,3)))
      pending%bytes = 8320_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b27_ka_d), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b27_ka_d), int64)
    case (459) ! __yoesrta27_MOD_kb_d
pending%address=c_loc(state%shortwave_absorption%b27_kb_d(lbound(state%shortwave_absorption%b27_kb_d,1),lbound(state%shortwave_absorption%b27_kb_d,2),lbound(state%shortwave_absorption%b27_kb_d,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b27_kb_d), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b27_kb_d), int64)
    case (460) ! __yoesrta27_MOD_sfluxref
      pending%address = c_loc(state%shortwave_absorption%b27_sfluxref(lbound(state%shortwave_absorption%b27_sfluxref, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b27_sfluxref), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b27_sfluxref), int64)
    case (461) ! __yoesrta27_MOD_rayl
      pending%address = c_loc(state%shortwave_absorption%b27_rayl(lbound(state%shortwave_absorption%b27_rayl, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b27_rayl), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b27_rayl), int64)
    case (462) ! __yoesrta27_MOD_scalekur
      pending%address = c_loc(state%shortwave_absorption%b27_scalekur)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (463) ! __yoesrta27_MOD_layreffr
      pending%address = c_loc(state%shortwave_absorption%b27_layreffr)
      pending%bytes = 4_c_int64_t
      pending%rank = 0; pending%element_bytes = 4; pending%type_code = 1
    case (464) ! yoesrta27.eq.1_
pending%address=c_loc(state%shortwave_absorption%b27_kac(lbound(state%shortwave_absorption%b27_kac,1),lbound(state%shortwave_absorption%b27_kac,2),lbound(state%shortwave_absorption%b27_kac,3)))
      pending%bytes = 8320_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b27_kac), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b27_kac), int64)
    case (465) ! yoesrta27.eq.0_
pending%address=c_loc(state%shortwave_absorption%b27_kbc(lbound(state%shortwave_absorption%b27_kbc,1),lbound(state%shortwave_absorption%b27_kbc,2),lbound(state%shortwave_absorption%b27_kbc,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b27_kbc), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b27_kbc), int64)
    case (466) ! __yoesrta27_MOD_sfluxrefc
      pending%address = c_loc(state%shortwave_absorption%b27_sfluxrefc(lbound(state%shortwave_absorption%b27_sfluxrefc, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b27_sfluxrefc), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b27_sfluxrefc), int64)
    case (467) ! __yoesrta27_MOD_raylc
      pending%address = c_loc(state%shortwave_absorption%b27_raylc(lbound(state%shortwave_absorption%b27_raylc, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b27_raylc), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b27_raylc), int64)
    case (468) ! __yoesrta28_MOD_ka
pending%address=c_loc(state%shortwave_absorption%b28_ka(lbound(state%shortwave_absorption%b28_ka,1),lbound(state%shortwave_absorption%b28_ka,2),lbound(state%shortwave_absorption%b28_ka,3),lbound(state%shortwave_absorption%b28_ka,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b28_ka), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b28_ka), int64)
    case (469) ! __yoesrta28_MOD_kb
pending%address=c_loc(state%shortwave_absorption%b28_kb(lbound(state%shortwave_absorption%b28_kb,1),lbound(state%shortwave_absorption%b28_kb,2),lbound(state%shortwave_absorption%b28_kb,3),lbound(state%shortwave_absorption%b28_kb,4)))
      pending%bytes = 150400_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b28_kb), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b28_kb), int64)
    case (470) ! __yoesrta28_MOD_ka_d
pending%address=c_loc(state%shortwave_absorption%b28_ka_d(lbound(state%shortwave_absorption%b28_ka_d,1),lbound(state%shortwave_absorption%b28_ka_d,2),lbound(state%shortwave_absorption%b28_ka_d,3),lbound(state%shortwave_absorption%b28_ka_d,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b28_ka_d), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b28_ka_d), int64)
    case (471) ! __yoesrta28_MOD_kb_d
pending%address=c_loc(state%shortwave_absorption%b28_kb_d(lbound(state%shortwave_absorption%b28_kb_d,1),lbound(state%shortwave_absorption%b28_kb_d,2),lbound(state%shortwave_absorption%b28_kb_d,3),lbound(state%shortwave_absorption%b28_kb_d,4)))
      pending%bytes = 150400_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b28_kb_d), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b28_kb_d), int64)
    case (472) ! __yoesrta28_MOD_sfluxref
pending%address=c_loc(state%shortwave_absorption%b28_sfluxref(lbound(state%shortwave_absorption%b28_sfluxref,1),lbound(state%shortwave_absorption%b28_sfluxref,2)))
      pending%bytes = 640_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b28_sfluxref), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b28_sfluxref), int64)
    case (473) ! __yoesrta28_MOD_rayl
      pending%address = c_loc(state%shortwave_absorption%b28_rayl)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (474) ! __yoesrta28_MOD_strrat
      pending%address = c_loc(state%shortwave_absorption%b28_strrat)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (475) ! __yoesrta28_MOD_layreffr
      pending%address = c_loc(state%shortwave_absorption%b28_layreffr)
      pending%bytes = 4_c_int64_t
      pending%rank = 0; pending%element_bytes = 4; pending%type_code = 1
    case (476) ! yoesrta28.eq.1_
pending%address=c_loc(state%shortwave_absorption%b28_kac(lbound(state%shortwave_absorption%b28_kac,1),lbound(state%shortwave_absorption%b28_kac,2),lbound(state%shortwave_absorption%b28_kac,3),lbound(state%shortwave_absorption%b28_kac,4)))
      pending%bytes = 74880_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b28_kac), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b28_kac), int64)
    case (477) ! yoesrta28.eq.0_
pending%address=c_loc(state%shortwave_absorption%b28_kbc(lbound(state%shortwave_absorption%b28_kbc,1),lbound(state%shortwave_absorption%b28_kbc,2),lbound(state%shortwave_absorption%b28_kbc,3),lbound(state%shortwave_absorption%b28_kbc,4)))
      pending%bytes = 150400_c_int64_t
      pending%rank = 4; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:4) = int(lbound(state%shortwave_absorption%b28_kbc), int64)
      pending%upper(1:4) = int(ubound(state%shortwave_absorption%b28_kbc), int64)
    case (478) ! __yoesrta28_MOD_sfluxrefc
pending%address=c_loc(state%shortwave_absorption%b28_sfluxrefc(lbound(state%shortwave_absorption%b28_sfluxrefc,1),lbound(state%shortwave_absorption%b28_sfluxrefc,2)))
      pending%bytes = 640_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b28_sfluxrefc), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b28_sfluxrefc), int64)
    case (479) ! __yoesrta29_MOD_ka
pending%address=c_loc(state%shortwave_absorption%b29_ka(lbound(state%shortwave_absorption%b29_ka,1),lbound(state%shortwave_absorption%b29_ka,2),lbound(state%shortwave_absorption%b29_ka,3)))
      pending%bytes = 8320_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b29_ka), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b29_ka), int64)
    case (480) ! __yoesrta29_MOD_kb
pending%address=c_loc(state%shortwave_absorption%b29_kb(lbound(state%shortwave_absorption%b29_kb,1),lbound(state%shortwave_absorption%b29_kb,2),lbound(state%shortwave_absorption%b29_kb,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b29_kb), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b29_kb), int64)
    case (481) ! __yoesrta29_MOD_ka_d
pending%address=c_loc(state%shortwave_absorption%b29_ka_d(lbound(state%shortwave_absorption%b29_ka_d,1),lbound(state%shortwave_absorption%b29_ka_d,2),lbound(state%shortwave_absorption%b29_ka_d,3)))
      pending%bytes = 8320_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b29_ka_d), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b29_ka_d), int64)
    case (482) ! __yoesrta29_MOD_kb_d
pending%address=c_loc(state%shortwave_absorption%b29_kb_d(lbound(state%shortwave_absorption%b29_kb_d,1),lbound(state%shortwave_absorption%b29_kb_d,2),lbound(state%shortwave_absorption%b29_kb_d,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b29_kb_d), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b29_kb_d), int64)
    case (483) ! __yoesrta29_MOD_selfref
pending%address=c_loc(state%shortwave_absorption%b29_selfref(lbound(state%shortwave_absorption%b29_selfref,1),lbound(state%shortwave_absorption%b29_selfref,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b29_selfref), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b29_selfref), int64)
    case (484) ! __yoesrta29_MOD_forref
pending%address=c_loc(state%shortwave_absorption%b29_forref(lbound(state%shortwave_absorption%b29_forref,1),lbound(state%shortwave_absorption%b29_forref,2)))
      pending%bytes = 512_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b29_forref), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b29_forref), int64)
    case (485) ! __yoesrta29_MOD_sfluxref
      pending%address = c_loc(state%shortwave_absorption%b29_sfluxref(lbound(state%shortwave_absorption%b29_sfluxref, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b29_sfluxref), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b29_sfluxref), int64)
    case (486) ! __yoesrta29_MOD_absh2o
      pending%address = c_loc(state%shortwave_absorption%b29_absh2o(lbound(state%shortwave_absorption%b29_absh2o, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b29_absh2o), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b29_absh2o), int64)
    case (487) ! __yoesrta29_MOD_absco2
      pending%address = c_loc(state%shortwave_absorption%b29_absco2(lbound(state%shortwave_absorption%b29_absco2, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b29_absco2), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b29_absco2), int64)
    case (488) ! __yoesrta29_MOD_rayl
      pending%address = c_loc(state%shortwave_absorption%b29_rayl)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (489) ! __yoesrta29_MOD_layreffr
      pending%address = c_loc(state%shortwave_absorption%b29_layreffr)
      pending%bytes = 4_c_int64_t
      pending%rank = 0; pending%element_bytes = 4; pending%type_code = 1
    case (490) ! yoesrta29.eq.1_
pending%address=c_loc(state%shortwave_absorption%b29_kac(lbound(state%shortwave_absorption%b29_kac,1),lbound(state%shortwave_absorption%b29_kac,2),lbound(state%shortwave_absorption%b29_kac,3)))
      pending%bytes = 8320_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b29_kac), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b29_kac), int64)
    case (491) ! yoesrta29.eq.0_
pending%address=c_loc(state%shortwave_absorption%b29_kbc(lbound(state%shortwave_absorption%b29_kbc,1),lbound(state%shortwave_absorption%b29_kbc,2),lbound(state%shortwave_absorption%b29_kbc,3)))
      pending%bytes = 30080_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%shortwave_absorption%b29_kbc), int64)
      pending%upper(1:3) = int(ubound(state%shortwave_absorption%b29_kbc), int64)
    case (492) ! __yoesrta29_MOD_selfrefc
pending%address=c_loc(state%shortwave_absorption%b29_selfrefc(lbound(state%shortwave_absorption%b29_selfrefc,1),lbound(state%shortwave_absorption%b29_selfrefc,2)))
      pending%bytes = 1280_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b29_selfrefc), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b29_selfrefc), int64)
    case (493) ! __yoesrta29_MOD_forrefc
pending%address=c_loc(state%shortwave_absorption%b29_forrefc(lbound(state%shortwave_absorption%b29_forrefc,1),lbound(state%shortwave_absorption%b29_forrefc,2)))
      pending%bytes = 512_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%shortwave_absorption%b29_forrefc), int64)
      pending%upper(1:2) = int(ubound(state%shortwave_absorption%b29_forrefc), int64)
    case (494) ! __yoesrta29_MOD_sfluxrefc
      pending%address = c_loc(state%shortwave_absorption%b29_sfluxrefc(lbound(state%shortwave_absorption%b29_sfluxrefc, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b29_sfluxrefc), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b29_sfluxrefc), int64)
    case (495) ! __yoesrta29_MOD_absh2oc
      pending%address = c_loc(state%shortwave_absorption%b29_absh2oc(lbound(state%shortwave_absorption%b29_absh2oc, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b29_absh2oc), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b29_absh2oc), int64)
    case (496) ! __yoesrta29_MOD_absco2c
      pending%address = c_loc(state%shortwave_absorption%b29_absco2c(lbound(state%shortwave_absorption%b29_absco2c, 1)))
      pending%bytes = 128_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%shortwave_absorption%b29_absco2c), int64)
      pending%upper(1:1) = int(ubound(state%shortwave_absorption%b29_absco2c), int64)
    case (497) ! __yoelw_MOD_mxixt
      pending%address = c_loc(state%longwave_bands%mxixt)
      pending%bytes = 4_c_int64_t
      pending%rank = 0; pending%element_bytes = 4; pending%type_code = 1
    case (498) ! __yoelw_MOD_nsil
      pending%address = c_loc(state%longwave_bands%nsil)
      pending%bytes = 4_c_int64_t
      pending%rank = 0; pending%element_bytes = 4; pending%type_code = 1
    case (499) ! __yoelw_MOD_nipd
      pending%address = c_loc(state%longwave_bands%nipd)
      pending%bytes = 4_c_int64_t
      pending%rank = 0; pending%element_bytes = 4; pending%type_code = 1
    case (500) ! __yoelw_MOD_ntra
      pending%address = c_loc(state%longwave_bands%ntra)
      pending%bytes = 4_c_int64_t
      pending%rank = 0; pending%element_bytes = 4; pending%type_code = 1
    case (501) ! __yoelw_MOD_nua
      pending%address = c_loc(state%longwave_bands%nua)
      pending%bytes = 4_c_int64_t
      pending%rank = 0; pending%element_bytes = 4; pending%type_code = 1
    case (502) ! __yoelw_MOD_ng1
      pending%address = c_loc(state%longwave_bands%ng1)
      pending%bytes = 4_c_int64_t
      pending%rank = 0; pending%element_bytes = 4; pending%type_code = 1
    case (503) ! __yoelw_MOD_ng1p1
      pending%address = c_loc(state%longwave_bands%ng1p1)
      pending%bytes = 4_c_int64_t
      pending%rank = 0; pending%element_bytes = 4; pending%type_code = 1
    case (504) ! __yoelw_MOD_alwt
      pending%address = c_loc(state%longwave_bands%alwt(lbound(state%longwave_bands%alwt, 1), lbound(state%longwave_bands%alwt, 2)))
      pending%bytes = 192_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_bands%alwt), int64)
      pending%upper(1:2) = int(ubound(state%longwave_bands%alwt), int64)
    case (505) ! __yoelw_MOD_blwt
      pending%address = c_loc(state%longwave_bands%blwt(lbound(state%longwave_bands%blwt, 1), lbound(state%longwave_bands%blwt, 2)))
      pending%bytes = 192_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_bands%blwt), int64)
      pending%upper(1:2) = int(ubound(state%longwave_bands%blwt), int64)
    case (506) ! __yoelw_MOD_pdga
pending%address=c_loc(state%longwave_bands%pdga(lbound(state%longwave_bands%pdga,1),lbound(state%longwave_bands%pdga,2),lbound(state%longwave_bands%pdga,3)))
      pending%bytes = 4224_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_bands%pdga), int64)
      pending%upper(1:3) = int(ubound(state%longwave_bands%pdga), int64)
    case (507) ! __yoelw_MOD_pdgb
pending%address=c_loc(state%longwave_bands%pdgb(lbound(state%longwave_bands%pdgb,1),lbound(state%longwave_bands%pdgb,2),lbound(state%longwave_bands%pdgb,3)))
      pending%bytes = 4224_c_int64_t
      pending%rank = 3; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:3) = int(lbound(state%longwave_bands%pdgb), int64)
      pending%upper(1:3) = int(ubound(state%longwave_bands%pdgb), int64)
    case (508) ! __yoelw_MOD_rptype
      pending%address = c_loc(state%longwave_bands%rptype(lbound(state%longwave_bands%rptype, 1)))
      pending%bytes = 32_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_bands%rptype), int64)
      pending%upper(1:1) = int(ubound(state%longwave_bands%rptype), int64)
    case (509) ! __yoelw_MOD_retype
      pending%address = c_loc(state%longwave_bands%retype(lbound(state%longwave_bands%retype, 1)))
      pending%bytes = 32_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_bands%retype), int64)
      pending%upper(1:1) = int(ubound(state%longwave_bands%retype), int64)
    case (510) ! __yoelw_MOD_ro1h
      pending%address = c_loc(state%longwave_bands%ro1h)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (511) ! __yoelw_MOD_ro2h
      pending%address = c_loc(state%longwave_bands%ro2h)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (512) ! __yoelw_MOD_ro3t
      pending%address = c_loc(state%longwave_bands%ro3t(lbound(state%longwave_bands%ro3t, 1)))
      pending%bytes = 32_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_bands%ro3t), int64)
      pending%upper(1:1) = int(ubound(state%longwave_bands%ro3t), int64)
    case (513) ! __yoelw_MOD_rpialf0
      pending%address = c_loc(state%longwave_bands%rpialf0)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (514) ! __yoelw_MOD_rt1
      pending%address = c_loc(state%longwave_bands%rt1(lbound(state%longwave_bands%rt1, 1)))
      pending%bytes = 16_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_bands%rt1), int64)
      pending%upper(1:1) = int(ubound(state%longwave_bands%rt1), int64)
    case (515) ! __yoelw_MOD_tintp
      pending%address = c_loc(state%longwave_bands%tintp(lbound(state%longwave_bands%tintp, 1)))
      pending%bytes = 88_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_bands%tintp), int64)
      pending%upper(1:1) = int(ubound(state%longwave_bands%tintp), int64)
    case (516) ! __yoelw_MOD_tref
      pending%address = c_loc(state%longwave_bands%tref)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (517) ! __yoelw_MOD_tstand
      pending%address = c_loc(state%longwave_bands%tstand)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (518) ! __yoelw_MOD_tstp
      pending%address = c_loc(state%longwave_bands%tstp)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (519) ! __yoelw_MOD_wg1
      pending%address = c_loc(state%longwave_bands%wg1(lbound(state%longwave_bands%wg1, 1)))
      pending%bytes = 16_c_int64_t
      pending%rank = 1; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:1) = int(lbound(state%longwave_bands%wg1), int64)
      pending%upper(1:1) = int(ubound(state%longwave_bands%wg1), int64)
    case (520) ! __yoelw_MOD_xp
      pending%address = c_loc(state%longwave_bands%xp(lbound(state%longwave_bands%xp, 1), lbound(state%longwave_bands%xp, 2)))
      pending%bytes = 288_c_int64_t
      pending%rank = 2; pending%element_bytes = 8; pending%type_code = 2
      pending%lower(1:2) = int(lbound(state%longwave_bands%xp), int64)
      pending%upper(1:2) = int(ubound(state%longwave_bands%xp), int64)
    case (521) ! __yoelw_MOD_rvgco2
      pending%address = c_loc(state%longwave_bands%rvgco2)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (522) ! __yoelw_MOD_rvgh2o
      pending%address = c_loc(state%longwave_bands%rvgh2o)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case (523) ! __yoelw_MOD_rvgo3
      pending%address = c_loc(state%longwave_bands%rvgo3)
      pending%bytes = 8_c_int64_t
      pending%rank = 0; pending%element_bytes = 8; pending%type_code = 2
    case default
      return
    end select
    field = pending
    status = 0
  end function
end module forecast_owned_radiation_coefficient_namespace
