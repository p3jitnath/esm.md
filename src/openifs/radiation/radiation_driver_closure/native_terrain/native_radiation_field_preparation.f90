!> Own the complete selected outer radiation column and its six records.
!! Arrays use(column,level), Pa, kelvin, kg/kg and returned flux W/m2.
!! Native allocation, gas insertion, overlap and release supply every stage.
!! ECMWF science is retained under the Apache2 source attribution.
module native_radiation_field_preparation
  use iso_fortran_env, only: JPIM => int32, JPRB => real64, JPRD => real64, int32, real64
  use yomhook, only: lhook, dr_hook, jphook
  use radiation_config, only: config_type
  use radiation_single_level, only: single_level_type
  use radiation_thermodynamics, only: thermodynamics_type
  use radiation_gas,only:gas_type,IMassMixingRatio,IVolumeMixingRatio,IH2O,ICO2,ICH4,IN2O,ICFC11,ICFC12,IHCFC22,ICCL4,IO3,IO2
  use radiation_cloud, only: cloud_type
  use radiation_aerosol, only: aerosol_type
  use radiation_flux, only: flux_type
  use native_radiation_forecast_driver, only: native_radiation_driver_context
  use native_radiation_record_preparation
  use saturation_humidity_mod, only: satur
  use forecast_environmental_radius_support, only: liquid_radius_controls, ice_radius_controls, radius_perturbation_view
  use forecast_cloud_droplet_radius, only: liquid_effective_radius
  use forecast_ice_effective_radius, only: ice_effective_radius
  use native_radiation_cloud_diagnostics_without_clock, only: cloud_overlap_decorr_len
  use native_radiation_column_physics, only: radiation
  use native_radiation_clock_views, only: radiation_clock_is_ready
  implicit none
  private
  public :: radiation_scheme
contains
subroutine radiation_scheme(context,KIDIA,KFDIA,KLON,KLEV,KAEROSOL,PSOLAR_IRRADIANCE,PMU0,PTEMPERATURE_SKIN,PALBEDO_DIF,PALBEDO_DIR,PSPECTRALEMISS,PCCN_LAND,PCCN_SEA,PGELAM,PGEMU,PLAND_SEA_MASK,PPRESSURE,PTEMPERATURE,PPRESSURE_H,PTEMPERATURE_H,PQ,PCO2,PCH4,PN2O,PNO2,PCFC11,PCFC12,PHCFC22,PCCL4,PO3_DP,PCLOUD_FRAC,PQ_LIQUID,PQ_ICE,PQ_RAIN,PQ_SNOW,PAEROSOL_OLD,PAEROSOL,PFLUX_SW,PFLUX_LW,PFLUX_SW_CLEAR,PFLUX_LW_CLEAR,PFLUX_SW_DN,PFLUX_LW_DN,PFLUX_SW_DN_CLEAR,PFLUX_LW_DN_CLEAR,PFLUX_DIR,PFLUX_DIR_CLEAR,PFLUX_DIR_INTO_SUN,PFLUX_UV,PFLUX_PAR,PFLUX_PAR_CLEAR,PFLUX_SW_DN_TOA,PEMIS_OUT,PLWDERIVATIVE,PSWDIFFUSEBAND,PSWDIRECTBAND,PPERT,PFSD,status)
    type(native_radiation_driver_context), intent(inout) :: context
    INTEGER(KIND=JPIM), INTENT(IN) :: KIDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KFDIA
    INTEGER(KIND=JPIM), INTENT(IN) :: KLON
    INTEGER(KIND=JPIM), INTENT(IN) :: KLEV
    INTEGER(KIND=JPIM), INTENT(IN) :: KAEROSOL
    REAL(KIND=JPRB), INTENT(IN) :: PSOLAR_IRRADIANCE
    REAL(KIND=JPRB), INTENT(IN) :: PMU0(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PTEMPERATURE_SKIN(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PALBEDO_DIF(KLON, context%setup%radiation%NSW)
    REAL(KIND=JPRB), INTENT(IN) :: PALBEDO_DIR(KLON, context%setup%radiation%NSW)
    REAL(KIND=JPRB), INTENT(IN) :: PSPECTRALEMISS(KLON, context%setup%radiation%NLWEMISS)
    REAL(KIND=JPRB), INTENT(IN) :: PGELAM(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PGEMU(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PLAND_SEA_MASK(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PPRESSURE(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PTEMPERATURE(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PPRESSURE_H(KLON, KLEV + 1)
    REAL(KIND=JPRB), INTENT(IN) :: PTEMPERATURE_H(KLON, KLEV + 1)
    REAL(KIND=JPRB), INTENT(IN) :: PQ(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PCO2(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PCH4(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PN2O(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PNO2(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PCFC11(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PCFC12(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PHCFC22(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PCCL4(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PO3_DP(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PCLOUD_FRAC(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PQ_LIQUID(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PQ_ICE(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PQ_RAIN(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PQ_SNOW(KLON, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PAEROSOL_OLD(KLON, 6, KLEV)
    REAL(KIND=JPRB), INTENT(IN) :: PAEROSOL(KLON, KLEV, KAEROSOL)
    REAL(KIND=JPRB), INTENT(IN) :: PCCN_LAND(KLON)
    REAL(KIND=JPRB), INTENT(IN) :: PCCN_SEA(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFLUX_SW(KLON, KLEV + 1)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFLUX_LW(KLON, KLEV + 1)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFLUX_SW_CLEAR(KLON, KLEV + 1)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFLUX_LW_CLEAR(KLON, KLEV + 1)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFLUX_SW_DN(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFLUX_LW_DN(KLON, context%setup%radiation%NLWOUT)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFLUX_SW_DN_CLEAR(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFLUX_LW_DN_CLEAR(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFLUX_DIR(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFLUX_DIR_CLEAR(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFLUX_DIR_INTO_SUN(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFLUX_UV(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFLUX_PAR(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFLUX_PAR_CLEAR(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PFLUX_SW_DN_TOA(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PEMIS_OUT(KLON)
    REAL(KIND=JPRB), INTENT(INOUT) :: PLWDERIVATIVE(KLON, KLEV + 1)
    REAL(KIND=JPRB), INTENT(INOUT) :: PSWDIFFUSEBAND(KLON, context%setup%radiation%NSW)
    REAL(KIND=JPRB), INTENT(INOUT) :: PSWDIRECTBAND(KLON, context%setup%radiation%NSW)
    REAL(KIND=JPRB), INTENT(IN), OPTIONAL :: PPERT(:, :)
    REAL(KIND=JPRB), INTENT(IN), OPTIONAL :: PFSD(KLON, KLEV)
    integer(int32), intent(out) :: status
    type(single_level_type) :: single_level
    type(thermodynamics_type) :: thermodynamics
    type(gas_type) :: gas
    type(cloud_type) :: ylcloud
    type(aerosol_type) :: aerosol
    type(flux_type) :: flux
    type(config_type), target :: rad_config
    type(liquid_radius_controls) :: liquid_controls
    type(ice_radius_controls) :: ice_controls
    type(radius_perturbation_view) :: perturb
    real(real64) :: zo3(KLON, KLEV), re_liquid(KLON, KLEV), re_ice(KLON, KLEV), decorr(KLON), ratio
    real(real64) :: layer_mass(KIDIA:KFDIA, KLEV), ZBLACK_BODY_NET_LW(KIDIA:KFDIA)
    real(jphook) :: hook
    integer :: iday, itim, jlon, jlev, jband, jaer
    status = 2
    if (.not. radiation_clock_is_ready(context%clock)) return
    if (.not. associated(context%setup) .or. .not. associated(context%constants) .or. .not. associated(context%thermal)) return
    if (.not. associated(context%configuration) .or. .not. associated(context%cloud_parameters)) return
    if (klon < 1 .or. klon > 2048 .or. klev < 3 .or. klev > 256 .or. kidia < 1 .or. kfdia > klon .or. kidia > kfdia) return
    if (context%stochastic_enabled .or. context%setup%radiation%NSOLARSPECTRUM /= 0) return
    if (context%configuration%ecmwf_physics%LRAD_CLOUD_INHOMOG) return
    if (context%setup%radiation%NDUMPBADINPUTS /= 0 .or. context%setup%radiation%NDUMPINPUTS /= 0) return
    if (context%setup%radiation%NAERMACC /= 1 .or. kaerosol /= 12) return
    if (.not. context%setup%aerosol_atmosphere%LAERRRTM) return
    if (context%setup%radiation%NSW /= 6 .or. context%setup%radiation%NLWEMISS /= 2 .or. context%setup%radiation%NLWOUT /= 1) return
    rad_config = context%setup%ecrad%config
    if (lhook) call dr_hook('RADIATION_SCHEME', 0, hook)
call allocate_owned(single_level,klon,context%setup%radiation%NSW,context%setup%radiation%NLWEMISS,use_sw_albedo_direct=.true.,status=status)
    if (status /= 0) return
    call allocate_owned(thermodynamics, klon, klev, use_h2o_sat=.true., status=status)
    if (status /= 0) return
    call allocate_owned(gas, klon, klev, status)
    if (status /= 0) return
    call allocate_owned(ylcloud, klon, klev, status=status)
    if (status /= 0) return
    call allocate_owned(aerosol, klon, 1, klev, kaerosol, status)
    if (status /= 0) return
    call allocate_owned(flux, rad_config, 1, klon, klev, status)
    if (status /= 0) return
    thermodynamics%pressure_hl(kidia:kfdia, :) = ppressure_h(kidia:kfdia, :)
    thermodynamics%temperature_hl(kidia:kfdia, :) = ptemperature_h(kidia:kfdia, :)
thermodynamics%temperature_hl(kidia:kfdia,klev+1)=ptemperature(kidia:kfdia,klev)+0.5_real64*(ptemperature_h(kidia:kfdia,klev+1)-ptemperature_h(kidia:kfdia,klev))
status=satur(context%constants,context%thermal,kidia,kfdia,klon,1,klev,context%configuration%linear_ecmwf%LPHYLIN,ppressure,ptemperature,thermodynamics%h2o_sat_liq,2)
    if (status /= 0) return
    single_level%solar_irradiance = psolar_irradiance
    single_level%cos_sza(kidia:kfdia) = pmu0(kidia:kfdia)
    single_level%skin_temperature(kidia:kfdia) = ptemperature_skin(kidia:kfdia)
    single_level%sw_albedo(kidia:kfdia, :) = palbedo_dif(kidia:kfdia, :)
    single_level%sw_albedo_direct(kidia:kfdia, :) = palbedo_dir(kidia:kfdia, :)
    single_level%lw_emissivity(kidia:kfdia, :) = pspectralemiss(kidia:kfdia, :)
    iday = mod(context%clock%initial_date, 100)
    itim = nint(context%clock%step*context%clock%TSTEP/60.0_real64)
    do jlon = kidia, kfdia
      single_level%iseed(jlon) = itim + iday + nint(pgelam(jlon)*108000000.0_real64 + asin(pgemu(jlon))*6000.0_real64)
    end do
    ylcloud%q_liq(kidia:kfdia, :) = pq_liquid(kidia:kfdia, :)
    ylcloud%q_ice(kidia:kfdia, :) = pq_ice(kidia:kfdia, :) + pq_snow(kidia:kfdia, :)
    ylcloud%fraction(kidia:kfdia, :) = pcloud_frac(kidia:kfdia, :)
    perturb%enabled = .false.; perturb%selected_entry = 0; perturb%pattern_count = 0
liquid_controls=liquid_radius_controls(context%setup%radiation%NRADLP,context%active_aerosols,context%setup%radiation%NAERMACC,context%setup%radiation%NMCVAR,context%configuration%cloud%NAERCLD,context%setup%radiation%LCCNL,context%setup%radiation%LCCNO,context%setup%radiation%RCCNLND,context%setup%radiation%RCCNSEA)
call liquid_effective_radius(liquid_controls,perturb,kidia,kfdia,klon,klev,ppressure,ptemperature,pcloud_frac,pq_liquid,pq_rain,pland_sea_mask,pccn_land,pccn_sea,re_liquid,context%constants%rd,context%constants%rpi,context%setup%scalars%replog,context%setup%scalars%repscw,status)
    if (status /= 0) return
    ylcloud%re_liq(kidia:kfdia, :) = re_liquid(kidia:kfdia, :)*1.0e-6_real64
ice_controls=ice_radius_controls(context%setup%radiation%NRADIP,context%setup%radiation%NMINICE/=0,context%setup%radiation%RRE2DE,context%setup%radiation%RMINICE)
call ice_effective_radius(ice_controls,perturb,kidia,kfdia,klon,klev,ppressure,ptemperature,pcloud_frac,pq_ice,pq_snow,pgemu,re_ice,context%constants%rd,context%constants%rtt,status)
    if (status /= 0) return
    ylcloud%re_ice(kidia:kfdia, :) = re_ice(kidia:kfdia, :)*1.0e-6_real64
call cloud_overlap_decorr_len(context%constants,context%cloud_parameters,kidia,kfdia,klon,pgemu,context%setup%radiation%NDECOLAT,edge_km=decorr,ratio=ratio)
    rad_config%cloud_inhom_decorr_scaling = ratio
    do jlon = kidia, kfdia
      call owned_set_overlap_param(ylcloud, thermodynamics, decorr(jlon)*1000.0_real64, istartcol=jlon, iendcol=jlon)
    end do
    call owned_create_fractional_std(ylcloud, klon, klev, context%setup%radiation%RCLOUD_FRAC_STD)
    call owned_get_layer_mass(thermodynamics, kidia, kfdia, layer_mass)
    do jaer = 1, kaerosol
      do jlev = 1, klev
        do jlon = kidia, kfdia
          aerosol%mixing_ratio(jlon, jlev, jaer) = max(paerosol(jlon, jlev, jaer), 0.0_real64)
        end do
      end do
    end do
    if (context%setup%ecrad%trop_bg_aer_mass_ext > 0.0_real64) then
 aerosol%mixing_ratio(kidia:kfdia,:,8)=aerosol%mixing_ratio(kidia:kfdia,:,8)+paerosol_old(kidia:kfdia,1,:)/(layer_mass*context%setup%ecrad%trop_bg_aer_mass_ext)
    end if
    if (context%setup%ecrad%strat_bg_aer_mass_ext > 0.0_real64) then
 aerosol%mixing_ratio(kidia:kfdia,:,12)=aerosol%mixing_ratio(kidia:kfdia,:,12)+paerosol_old(kidia:kfdia,6,:)/(layer_mass*context%setup%ecrad%strat_bg_aer_mass_ext)
    end if
    do jlev = 1, klev
      do jlon = kidia, kfdia
        zo3(jlon, jlev) = po3_dp(jlon, jlev)/(ppressure_h(jlon, jlev + 1) - ppressure_h(jlon, jlev))
      end do
    end do
    call owned_put_gas(gas, IH2O, IMassMixingRatio, PQ)
    call owned_put_gas(gas, ICO2, IMassMixingRatio, PCO2)
    call owned_put_gas(gas, ICH4, IMassMixingRatio, PCH4)
    call owned_put_gas(gas, IN2O, IMassMixingRatio, PN2O)
    call owned_put_gas(gas, ICFC11, IMassMixingRatio, PCFC11)
    call owned_put_gas(gas, ICFC12, IMassMixingRatio, PCFC12)
    call owned_put_gas(gas, IHCFC22, IMassMixingRatio, PHCFC22)
    call owned_put_gas(gas, ICCL4, IMassMixingRatio, PCCL4)
    call owned_put_gas(gas, IO3, IMassMixingRatio, ZO3)
    call owned_put_well_mixed_gas(gas, IO2, IVolumeMixingRatio, 0.20944_real64)
    call owned_set_units_gas(gas, IMassMixingRatio)
    call radiation(context, klon, klev, kidia, kfdia, rad_config, single_level, thermodynamics, gas, ylcloud, aerosol, flux, status)
    if (status /= 0) return
    PFLUX_SW(KIDIA:KFDIA, :) = FLUX%SW_DN(KIDIA:KFDIA, :) - FLUX%SW_UP(KIDIA:KFDIA, :)
    PFLUX_LW(KIDIA:KFDIA, :) = FLUX%LW_DN(KIDIA:KFDIA, :) - FLUX%LW_UP(KIDIA:KFDIA, :)
    PFLUX_SW_CLEAR(KIDIA:KFDIA, :) = FLUX%SW_DN_CLEAR(KIDIA:KFDIA, :) - FLUX%SW_UP_CLEAR(KIDIA:KFDIA, :)
    PFLUX_LW_CLEAR(KIDIA:KFDIA, :) = FLUX%LW_DN_CLEAR(KIDIA:KFDIA, :) - FLUX%LW_UP_CLEAR(KIDIA:KFDIA, :)
    PFLUX_SW_DN(KIDIA:KFDIA) = FLUX%SW_DN(KIDIA:KFDIA, KLEV + 1)
    IF (context%setup%radiation%NLWOUT == 1) THEN
      PFLUX_LW_DN(KIDIA:KFDIA, 1) = FLUX%LW_DN(KIDIA:KFDIA, KLEV + 1)
    ELSE
      PFLUX_LW_DN(KIDIA:KFDIA, :) = TRANSPOSE(FLUX%LW_DN_SURF_CANOPY(:, KIDIA:KFDIA))
    END IF
    PFLUX_SW_DN_CLEAR(KIDIA:KFDIA) = FLUX%SW_DN_CLEAR(KIDIA:KFDIA, KLEV + 1)
    PFLUX_LW_DN_CLEAR(KIDIA:KFDIA) = FLUX%LW_DN_CLEAR(KIDIA:KFDIA, KLEV + 1)
    PFLUX_DIR(KIDIA:KFDIA) = FLUX%SW_DN_DIRECT(KIDIA:KFDIA, KLEV + 1)
    PFLUX_DIR_CLEAR(KIDIA:KFDIA) = FLUX%SW_DN_DIRECT_CLEAR(KIDIA:KFDIA, KLEV + 1)
    PFLUX_DIR_INTO_SUN(KIDIA:KFDIA) = 0.0_JPRB
    WHERE (PMU0(KIDIA:KFDIA) > EPSILON(1.0_JPRB))
      PFLUX_DIR_INTO_SUN(KIDIA:KFDIA) = PFLUX_DIR(KIDIA:KFDIA)/PMU0(KIDIA:KFDIA)
    END WHERE
    PFLUX_SW_DN_TOA(KIDIA:KFDIA) = FLUX%SW_DN(KIDIA:KFDIA, 1)
    PFLUX_UV(KIDIA:KFDIA) = 0.0_JPRB
    DO JBAND = 1, context%setup%ecrad%nweight_uv
PFLUX_UV(KIDIA:KFDIA) = PFLUX_UV(KIDIA:KFDIA) + context%setup%ecrad%weight_uv(JBAND) * FLUX%SW_DN_SURF_BAND(context%setup%ecrad%iband_uv(JBAND),KIDIA:KFDIA)
    END DO
    PFLUX_PAR(KIDIA:KFDIA) = 0.0_JPRB
    PFLUX_PAR_CLEAR(KIDIA:KFDIA) = 0.0_JPRB
    DO JBAND = 1, context%setup%ecrad%nweight_par
PFLUX_PAR(KIDIA:KFDIA) = PFLUX_PAR(KIDIA:KFDIA) + context%setup%ecrad%weight_par(JBAND) * FLUX%SW_DN_SURF_BAND(context%setup%ecrad%iband_par(JBAND),KIDIA:KFDIA)
PFLUX_PAR_CLEAR(KIDIA:KFDIA) = PFLUX_PAR_CLEAR(KIDIA:KFDIA) + context%setup%ecrad%weight_par(JBAND) * FLUX%SW_DN_SURF_CLEAR_BAND(context%setup%ecrad%iband_par(JBAND),KIDIA:KFDIA)
    END DO
    IF (context%setup%radiation%NLWOUT == 1) THEN
      ZBLACK_BODY_NET_LW = PFLUX_LW_DN(KIDIA:KFDIA, 1) - context%constants%rsigma*PTEMPERATURE_SKIN(KIDIA:KFDIA)**4
      PEMIS_OUT(KIDIA:KFDIA) = PSPECTRALEMISS(KIDIA:KFDIA, 1)
      WHERE (ABS(ZBLACK_BODY_NET_LW) > 1.0E-5)
        PEMIS_OUT(KIDIA:KFDIA) = MAX(0.8_JPRB, MIN(0.99_JPRB, PFLUX_LW(KIDIA:KFDIA, KLEV + 1)/ZBLACK_BODY_NET_LW))
      END WHERE
    ELSE
     PEMIS_OUT(KIDIA:KFDIA) = SUM(PSPECTRALEMISS(KIDIA:KFDIA, :)*PFLUX_LW_DN(KIDIA:KFDIA, :), 2)/SUM(PFLUX_LW_DN(KIDIA:KFDIA, :), 2)
    END IF
    IF (context%setup%radiation%LAPPROXLWUPDATE) THEN
      PLWDERIVATIVE(KIDIA:KFDIA, :) = FLUX%LW_DERIVATIVES(KIDIA:KFDIA, :)
    END IF
    IF (context%setup%radiation%LAPPROXSWUPDATE) THEN
      PSWDIFFUSEBAND(KIDIA:KFDIA, :) = TRANSPOSE(FLUX%SW_DN_DIFFUSE_SURF_CANOPY(:, KIDIA:KFDIA))
      PSWDIRECTBAND(KIDIA:KFDIA, :) = TRANSPOSE(FLUX%SW_DN_DIRECT_SURF_CANOPY(:, KIDIA:KFDIA))
    END IF
    call release_owned(single_level)
    call release_owned(thermodynamics)
    call release_owned(gas)
    call release_owned(ylcloud)
    call release_owned(aerosol)
    call release_owned(flux)
    context%setup%ecrad%config%cloud_inhom_decorr_scaling = ratio
    if (lhook) call dr_hook('RADIATION_SCHEME', 1, hook)
    status = 0
  end subroutine
end module
