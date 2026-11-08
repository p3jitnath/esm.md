!> Complete selected SOCRATES/Fu cloud optical mixture.
module md2asm_cloud_optical_mixture
  use iso_fortran_env, only: int32, real64
  use radiation_config, only: config_type
  use radiation_thermodynamics, only: thermodynamics_type
  use radiation_cloud, only: cloud_type
use native_radiation_optical_helpers,only:calc_liq_optics_socrates,calc_ice_optics_fu_lw,calc_ice_optics_fu_sw,delta_eddington_scat_od
  implicit none
  private
  public :: cloud_optics
contains
!> Produce complete selected-column cloud optical properties in band order.
!! Pressure is Pa, water mixing ratio kg/kg and effective radius metres.
!! Optical depths, scattering fractions and direction factors are dimensionless.
!! Inputs are canonical readonly records; output owners have (band,level,column)
!! order and may not overlap. Inactive longwave scattering owners are untouched.
!! Model2 for both liquid and ice is the frozen supported source domain.
  subroutine cloud_optics(nlev, first, last, config, thermodynamics, cloud, od_lw, ssa_lw, g_lw, od_sw, ssa_sw, g_sw, status)
    integer(int32), intent(in) :: nlev, first, last
    type(config_type), intent(in) :: config
    type(thermodynamics_type), intent(in) :: thermodynamics
    type(cloud_type), intent(in) :: cloud
    real(real64), intent(inout) :: od_lw(config%n_bands_lw, nlev, first:last)
 real(real64),intent(inout)::ssa_lw(config%n_bands_lw_if_scattering,nlev,first:last),g_lw(config%n_bands_lw_if_scattering,nlev,first:last)
 real(real64),intent(inout)::od_sw(config%n_bands_sw,nlev,first:last),ssa_sw(config%n_bands_sw,nlev,first:last),g_sw(config%n_bands_sw,nlev,first:last)
    integer(int32), intent(out) :: status
    real(real64) :: lt(config%n_bands_lw), ls(config%n_bands_lw), lg(config%n_bands_lw)
    real(real64) :: it(config%n_bands_lw), is(config%n_bands_lw), ig(config%n_bands_lw)
    real(real64) :: st(config%n_bands_sw), ss(config%n_bands_sw), sg(config%n_bands_sw)
    real(real64) :: ut(config%n_bands_sw), us(config%n_bands_sw), ug(config%n_bands_sw)
    real(real64) :: factor, lwp, iwp, t, s, g, a, c
    integer :: j, k, band
    status = 2
    if (nlev < 1 .or. nlev > 512 .or. first < 1 .or. last < first - 1) return
    if (config%i_liq_model /= 2 .or. config%i_ice_model /= 2) return
    if (config%n_bands_lw < 1 .or. config%n_bands_sw < 1) return
    if (config%do_lw_cloud_scattering .and. config%n_bands_lw_if_scattering /= config%n_bands_lw) return
    od_lw = 0.0_real64; od_sw = 0.0_real64; ssa_sw = 0.0_real64; g_sw = 0.0_real64
    if (config%do_lw_cloud_scattering) then
      ssa_lw = 0.0_real64; g_lw = 0.0_real64
    end if
    do k = 1, nlev
      do j = first, last
        if (cloud%fraction(j, k) <= 0.0_real64) cycle
        factor = thermodynamics%pressure_hl(j, k + 1) - thermodynamics%pressure_hl(j, k)
        if (config%is_homogeneous) then
          factor = factor/9.80665_real64
        else
          a = 9.80665_real64*cloud%fraction(j, k); factor = factor/a
        end if
        lwp = factor*cloud%q_liq(j, k); iwp = factor*cloud%q_ice(j, k)
        if (lwp > 0.0_real64) then
          call calc_liq_optics_socrates(config%n_bands_lw, config%cloud_optics%liq_coeff_lw, lwp, cloud%re_liq(j, k), lt, ls, lg)
          call calc_liq_optics_socrates(config%n_bands_sw, config%cloud_optics%liq_coeff_sw, lwp, cloud%re_liq(j, k), st, ss, sg)
          if (.not. config%do_sw_delta_scaling_with_gases) then
            do band = 1, config%n_bands_sw
              call delta_eddington_scat_od(st(band), ss(band), sg(band))
            end do
          end if
        else
          lt = 0.0_real64; ls = 0.0_real64; lg = 0.0_real64; st = 0.0_real64; ss = 0.0_real64; sg = 0.0_real64
        end if
        if (iwp > 0.0_real64) then
          call calc_ice_optics_fu_lw(config%n_bands_lw, config%cloud_optics%ice_coeff_lw, iwp, cloud%re_ice(j, k), it, is, ig)
          if (config%do_fu_lw_ice_optics_bug) then
            do band = 1, config%n_bands_lw
              is(band) = it(band) - is(band)
            end do
          end if
          call calc_ice_optics_fu_sw(config%n_bands_sw, config%cloud_optics%ice_coeff_sw, iwp, cloud%re_ice(j, k), ut, us, ug)
          if (.not. config%do_sw_delta_scaling_with_gases) then
            do band = 1, config%n_bands_sw
              call delta_eddington_scat_od(ut(band), us(band), ug(band))
            end do
          end if
          do band = 1, config%n_bands_lw
            call delta_eddington_scat_od(it(band), is(band), ig(band))
          end do
        else
          it = 0.0_real64; is = 0.0_real64; ig = 0.0_real64; ut = 0.0_real64; us = 0.0_real64; ug = 0.0_real64
        end if
        do band = 1, config%n_bands_lw
          if (config%do_lw_cloud_scattering) then
            t = lt(band) + it(band); s = ls(band) + is(band)
            a = lg(band)*ls(band); c = ig(band)*is(band); g = a + c
            if (s > 0.0_real64) then
              g = g/s
            else
              g = 0.0_real64
            end if
            s = s/t; ssa_lw(band, k, j) = s; g_lw(band, k, j) = g
          else
            t = lt(band) - ls(band); t = t + it(band); t = t - is(band)
          end if
          od_lw(band, k, j) = t
        end do
        do band = 1, config%n_bands_sw
          t = st(band) + ut(band); s = ss(band) + us(band)
          a = sg(band)*ss(band); c = ug(band)*us(band); g = a + c; g = g/s; s = s/t
          od_sw(band, k, j) = t; ssa_sw(band, k, j) = s; g_sw(band, k, j) = g
        end do
      end do
    end do
    status = 0
  end subroutine
end module
