!> Declare the portable CLOUDSC interface used by the column layer.
!! Temperature is in K, pressure in Pa, and water amounts in kg/kg.
!! Calculations live in the separate generated implementation submodule.
module md2asm_record_cloud_microphysics_mod
  use iso_fortran_env, only: int32, int64, real64
  use yoecldp, only: tecldp, nclv
  use yoecumf, only: tecumf
  use yoephli, only: tephli
  use yoerad, only: terad
  use yoephy, only: tephy
  use yoevdf, only: tvdf
  use spp_mod, only: tspp_config
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  implicit none
  private
  integer, parameter :: jpim = int32, jprb = real64
  public :: cloudsc
  interface
    module subroutine cloudsc(physical, thermal, scmec_enabled, &
                              ydecldp, ydecumf, ydephli, yderad, &
                              ydephy, ydvdf, ydspp_config, kidia, &
                              kfdia, klon, klev, ptsphy, &
                              pt, pq, ptendency_cml_t, ptendency_cml_q, &
                              ptendency_cml_a, ptendency_cml_cld, ptendency_loc_t, ptendency_loc_q, &
                              ptendency_loc_a, ptendency_loc_cld, pvfa, pvfl, &
                              pvfi, pdyna, pdynl, pdyni, &
                              pdynr, pdyns, phrsw, phrlw, &
                              pvervel, pap, paph, plsm, &
                              pgaw, ldcum, kctop, ktype, &
                              kpbltype, peis, plu, plude, &
                              pludeli, psnde, pmfu, pmfd, &
                              pgp2dspp, ldslphy, pa, pclv, &
                              plcrit_aer, picrit_aer, pre_ice, pccn, &
                              pnice, pcovptot, pfsd, prainfrac_toprfz, &
                              pfsqlf, pfsqif, pfcqnng, pfcqlng, &
                              pfsqrf, pfsqsf, pfcqrng, pfcqsng, &
                              pfsqltur, pfsqitur, pfplsl, pfplsn, &
                              pfhpsl, pfhpsn, pextra, kfldx)
      type(forecast_physical_constants), intent(in) :: physical
      type(thermal_parameter_record), intent(in) :: thermal
      logical, intent(in) :: scmec_enabled
      type(tecldp), intent(inout) :: ydecldp
      type(tecumf), intent(inout) :: ydecumf
      type(tephli), intent(inout) :: ydephli
      type(terad), intent(inout) :: yderad
      type(tephy), intent(inout) :: ydephy
      type(tvdf), intent(in) :: ydvdf
      type(tspp_config), intent(in) :: ydspp_config
      integer(kind=jpim), intent(in) :: kidia
      integer(kind=jpim), intent(in) :: kfdia
      integer(kind=jpim), intent(in) :: klon
      integer(kind=jpim), intent(in) :: klev
      real(kind=jprb), intent(in) :: ptsphy
      real(kind=jprb), intent(in) :: pt(klon, klev)
      real(kind=jprb), intent(in) :: pq(klon, klev)
      real(kind=jprb), intent(in) :: ptendency_cml_t(klon, klev)
      real(kind=jprb), intent(in) :: ptendency_cml_q(klon, klev)
      real(kind=jprb), intent(in) :: ptendency_cml_a(klon, klev)
      real(kind=jprb), intent(in) :: ptendency_cml_cld(klon, klev, nclv)
      real(kind=jprb), intent(inout) :: ptendency_loc_t(klon, klev)
      real(kind=jprb), intent(inout) :: ptendency_loc_q(klon, klev)
      real(kind=jprb), intent(inout) :: ptendency_loc_a(klon, klev)
      real(kind=jprb), intent(inout) :: ptendency_loc_cld(klon, klev, nclv)
      real(kind=jprb), intent(in) :: pvfa(klon, klev)
      real(kind=jprb), intent(in) :: pvfl(klon, klev)
      real(kind=jprb), intent(in) :: pvfi(klon, klev)
      real(kind=jprb), intent(in) :: pdyna(klon, klev)
      real(kind=jprb), intent(in) :: pdynl(klon, klev)
      real(kind=jprb), intent(in) :: pdyni(klon, klev)
      real(kind=jprb), intent(in) :: pdynr(klon, klev)
      real(kind=jprb), intent(in) :: pdyns(klon, klev)
      real(kind=jprb), intent(in) :: phrsw(klon, klev)
      real(kind=jprb), intent(in) :: phrlw(klon, klev)
      real(kind=jprb), intent(in) :: pvervel(klon, klev)
      real(kind=jprb), intent(in) :: pap(klon, klev)
      real(kind=jprb), intent(in) :: paph(klon, klev + 1)
      real(kind=jprb), intent(in) :: plsm(klon)
      real(kind=jprb), intent(in) :: pgaw(klon)
      logical, intent(in) :: ldcum(klon)
      integer(kind=jpim), intent(in) :: kctop(klon)
      integer(kind=jpim), intent(in) :: ktype(klon)
      integer(kind=jpim), intent(in) :: kpbltype(klon)
      real(kind=jprb), intent(in) :: peis(klon)
      real(kind=jprb), intent(in) :: plu(klon, klev)
      real(kind=jprb), intent(inout) :: plude(klon, klev)
      real(kind=jprb), intent(in) :: pludeli(klon, klev, 4)
      real(kind=jprb), intent(in) :: psnde(klon, klev, 2)
      real(kind=jprb), intent(in) :: pmfu(klon, klev)
      real(kind=jprb), intent(in) :: pmfd(klon, klev)
      real(kind=jprb), intent(in) :: pgp2dspp(klon, ydspp_config%sm%nrftotal)
      logical, intent(in) :: ldslphy
      real(kind=jprb), intent(in) :: pa(klon, klev)
      real(kind=jprb), intent(in) :: pclv(klon, klev, nclv)
      real(kind=jprb), intent(in) :: plcrit_aer(klon, klev)
      real(kind=jprb), intent(in) :: picrit_aer(klon, klev)
      real(kind=jprb), intent(in) :: pre_ice(klon, klev)
      real(kind=jprb), intent(in) :: pccn(klon, klev)
      real(kind=jprb), intent(in) :: pnice(klon, klev)
      real(kind=jprb), intent(inout) :: pcovptot(klon, klev)
      real(kind=jprb), intent(inout) :: prainfrac_toprfz(klon)
      real(kind=jprb), intent(inout) :: pfsqlf(klon, klev + 1)
      real(kind=jprb), intent(inout) :: pfsqif(klon, klev + 1)
      real(kind=jprb), intent(inout) :: pfcqlng(klon, klev + 1)
      real(kind=jprb), intent(inout) :: pfcqnng(klon, klev + 1)
      real(kind=jprb), intent(inout) :: pfsqrf(klon, klev + 1)
      real(kind=jprb), intent(inout) :: pfsqsf(klon, klev + 1)
      real(kind=jprb), intent(inout) :: pfcqrng(klon, klev + 1)
      real(kind=jprb), intent(inout) :: pfcqsng(klon, klev + 1)
      real(kind=jprb), intent(inout) :: pfsqltur(klon, klev + 1)
      real(kind=jprb), intent(inout) :: pfsqitur(klon, klev + 1)
      real(kind=jprb), intent(inout) :: pfplsl(klon, klev + 1)
      real(kind=jprb), intent(inout) :: pfplsn(klon, klev + 1)
      real(kind=jprb), intent(inout) :: pfhpsl(klon, klev + 1)
      real(kind=jprb), intent(inout) :: pfhpsn(klon, klev + 1)
      real(kind=jprb), intent(inout) :: pextra(klon, klev, kfldx)
      integer(kind=jpim), intent(in) :: kfldx
      real(kind=jprb), intent(inout) :: pfsd(klon, klev)
    end subroutine cloudsc
  end interface
end module md2asm_record_cloud_microphysics_mod
