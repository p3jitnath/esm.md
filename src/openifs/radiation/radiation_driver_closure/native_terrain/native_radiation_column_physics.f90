!> Own the complete selected gas, cloud, aerosol and flux call order.
!! Canonical ecRad record declarations supply data only. All eight numerical
!! stages bind directly to the native port objects. Fluxes use W/m2.
!! Scientific source attribution: ECMWF radiation_interface.
module native_radiation_column_physics
  use iso_fortran_env, only: real64, int32
  use yomhook, only: lhook, dr_hook, jphook
  use radiation_config, only: config_type, IGasModelIFSRRTMG, ISolverMcICA
  use radiation_single_level, only: single_level_type
  use radiation_thermodynamics, only: thermodynamics_type
  use radiation_gas, only: gas_type
  use radiation_cloud, only: cloud_type
  use radiation_aerosol, only: aerosol_type
  use radiation_flux, only: flux_type
  use native_radiation_forecast_driver, only: native_radiation_driver_context
  use native_radiation_surface_spectra, only: get_albedos, calc_surface_spectral
  use native_radiation_optical_helpers, only: crop_cloud_fraction
  use md2asm_gas_optical_properties, only: gas_optics
  use md2asm_cloud_optical_mixture, only: cloud_optics
  use md2asm_aerosol_optical_mixture, only: add_aerosol_optics
  use native_longwave_cloud_transport, only: solver_mcica_lw
  use md2asm_shortwave_cloud_solver, only: solver_mcica_sw
  implicit none
  private
  public :: radiation
contains
!> Run all selected stages privately and commit only complete mutable arrays.
!! Each live record is borrowed. A separate native cloud/flux copy retains
!! inactive cells and source-unwritten owners until the ordered stages finish.
!! Status0 completes,1 is allocation failure,2 refuses an unsupported input.
  subroutine radiation(context,ncol,nlev,istartcol,iendcol,config,single_level,thermodynamics,gas,cloud,aerosol,flux,status)
    type(native_radiation_driver_context), intent(in) :: context
    integer, intent(in) :: ncol, nlev, istartcol, iendcol
    type(config_type), target, intent(in) :: config
    type(single_level_type), intent(in) :: single_level
    type(thermodynamics_type), intent(in) :: thermodynamics
    type(gas_type), intent(in) :: gas
    type(cloud_type), intent(inout) :: cloud
    type(aerosol_type), intent(in) :: aerosol
    type(flux_type), intent(inout) :: flux
    integer(int32), intent(out) :: status
    type(cloud_type) :: private_cloud
    type(flux_type) :: private_flux
    integer :: error
    real(jphook) :: hook
    real(real64), allocatable :: od_lw(:, :, :)
    real(real64), allocatable :: ssa_lw(:, :, :), g_lw(:, :, :)
    real(real64), allocatable :: od_lw_cloud(:, :, :)
    real(real64), allocatable :: ssa_lw_cloud(:, :, :), g_lw_cloud(:, :, :)
    real(real64), allocatable :: od_sw(:, :, :), ssa_sw(:, :, :), g_sw(:, :, :)
    real(real64), allocatable :: od_sw_cloud(:, :, :), ssa_sw_cloud(:, :, :), g_sw_cloud(:, :, :)
    real(real64), allocatable :: planck_hl(:, :, :)
    real(real64), allocatable :: lw_emission(:, :)
    real(real64), allocatable :: lw_albedo(:, :)
    real(real64), allocatable :: sw_albedo_direct(:, :)
    real(real64), allocatable :: sw_albedo_diffuse(:, :)
    real(real64), allocatable :: incoming_sw(:, :)

    status = 2
    if (.not. associated(context%constants) .or. .not. associated(context%setup)) return
    if (ncol < 1 .or. ncol > 4096 .or. nlev < 1 .or. nlev > 512 .or. istartcol /= 1 .or. iendcol < 1 .or. iendcol > ncol) return
 if (config%i_gas_model /= IGasModelIFSRRTMG .or. config%i_solver_lw /= ISolverMcICA .or. config%i_solver_sw /= ISolverMcICA) return
    if (.not. config%do_lw .or. .not. config%do_sw .or. .not. config%do_clouds .or. .not. config%use_aerosols) return
    if (config%do_save_radiative_properties .or. config%do_lw_aerosol_scattering) return
    if (thermodynamics%pressure_hl(1, 2) < thermodynamics%pressure_hl(1, 1)) return
    if (context%planet_area_scale <= 0.0_real64) return
    if (lhook) call dr_hook('radiation_interface:radiation', 0, hook)
    private_cloud = cloud
    private_flux = flux
    allocate (od_lw(config%n_g_lw, nlev, istartcol:iendcol), stat=error)
    if (error /= 0) then; status = 1; return; end if
allocate(ssa_lw(config%n_g_lw_if_scattering,nlev,istartcol:iendcol),g_lw(config%n_g_lw_if_scattering,nlev,istartcol:iendcol),stat=error)
    if (error /= 0) then; status = 1; return; end if
    allocate (od_lw_cloud(config%n_bands_lw, nlev, istartcol:iendcol), stat=error)
    if (error /= 0) then; status = 1; return; end if
allocate(ssa_lw_cloud(config%n_bands_lw_if_scattering,nlev,istartcol:iendcol),g_lw_cloud(config%n_bands_lw_if_scattering,nlev,istartcol:iendcol),stat=error)
    if (error /= 0) then; status = 1; return; end if
allocate(od_sw(config%n_g_sw,nlev,istartcol:iendcol),ssa_sw(config%n_g_sw,nlev,istartcol:iendcol),g_sw(config%n_g_sw,nlev,istartcol:iendcol),stat=error)
    if (error /= 0) then; status = 1; return; end if
allocate(od_sw_cloud(config%n_bands_sw,nlev,istartcol:iendcol),ssa_sw_cloud(config%n_bands_sw,nlev,istartcol:iendcol),g_sw_cloud(config%n_bands_sw,nlev,istartcol:iendcol),stat=error)
    if (error /= 0) then; status = 1; return; end if
    allocate (planck_hl(config%n_g_lw, nlev + 1, istartcol:iendcol), stat=error)
    if (error /= 0) then; status = 1; return; end if
    allocate (lw_emission(config%n_g_lw, istartcol:iendcol), stat=error)
    if (error /= 0) then; status = 1; return; end if
    allocate (lw_albedo(config%n_g_lw, istartcol:iendcol), stat=error)
    if (error /= 0) then; status = 1; return; end if
    allocate (sw_albedo_direct(config%n_g_sw, istartcol:iendcol), stat=error)
    if (error /= 0) then; status = 1; return; end if
    allocate (sw_albedo_diffuse(config%n_g_sw, istartcol:iendcol), stat=error)
    if (error /= 0) then; status = 1; return; end if
    allocate (incoming_sw(config%n_g_sw, istartcol:iendcol), stat=error)
    if (error /= 0) then; status = 1; return; end if

    call get_albedos(single_level, istartcol, iendcol, config, sw_albedo_direct, sw_albedo_diffuse, lw_albedo)
    call gas_optics(context%constants%rg, context%planet_area_scale, context%setup%longwave_reference, &
                    context%setup%longwave_reduced, context%setup%shortwave_absorption, ncol, nlev, istartcol, iendcol, &
            config, single_level, thermodynamics, gas, od_lw, od_sw, ssa_sw, lw_albedo, planck_hl, lw_emission, incoming_sw, status)
    if (status /= 0) return
    call crop_cloud_fraction(private_cloud%q_liq, private_cloud%q_ice, private_cloud%fraction, istartcol, iendcol, &
                             config%cloud_fraction_threshold, config%cloud_mixing_ratio_threshold)
    call cloud_optics(nlev, istartcol, iendcol, config, thermodynamics, private_cloud, &
                      od_lw_cloud, ssa_lw_cloud, g_lw_cloud, od_sw_cloud, ssa_sw_cloud, g_sw_cloud, status)
    if (status /= 0) return
    call add_aerosol_optics(nlev, istartcol, iendcol, config, thermodynamics, gas, aerosol, &
                            od_lw, ssa_lw, g_lw, od_sw, ssa_sw, g_sw, status)
    if (status /= 0) return
    call solver_mcica_lw(nlev, istartcol, iendcol, config, single_level, private_cloud, od_lw, ssa_lw, g_lw, &
                         od_lw_cloud, ssa_lw_cloud, g_lw_cloud, planck_hl, lw_emission, lw_albedo, private_flux)
    call solver_mcica_sw(nlev, istartcol, iendcol, config, single_level, private_cloud, od_sw, ssa_sw, g_sw, &
                      od_sw_cloud, ssa_sw_cloud, g_sw_cloud, sw_albedo_direct, sw_albedo_diffuse, incoming_sw, private_flux, status)
    if (status /= 0) return
    call calc_surface_spectral(private_flux, config, istartcol, iendcol)
    cloud%fraction = private_cloud%fraction
    if (allocated(flux%lw_up)) flux%lw_up = private_flux%lw_up
    if (allocated(flux%lw_dn)) flux%lw_dn = private_flux%lw_dn
    if (allocated(flux%sw_up)) flux%sw_up = private_flux%sw_up
    if (allocated(flux%sw_dn)) flux%sw_dn = private_flux%sw_dn
    if (allocated(flux%sw_dn_direct)) flux%sw_dn_direct = private_flux%sw_dn_direct
    if (allocated(flux%lw_up_clear)) flux%lw_up_clear = private_flux%lw_up_clear
    if (allocated(flux%lw_dn_clear)) flux%lw_dn_clear = private_flux%lw_dn_clear
    if (allocated(flux%sw_up_clear)) flux%sw_up_clear = private_flux%sw_up_clear
    if (allocated(flux%sw_dn_clear)) flux%sw_dn_clear = private_flux%sw_dn_clear
    if (allocated(flux%sw_dn_direct_clear)) flux%sw_dn_direct_clear = private_flux%sw_dn_direct_clear
    if (allocated(flux%lw_up_band)) flux%lw_up_band = private_flux%lw_up_band
    if (allocated(flux%lw_dn_band)) flux%lw_dn_band = private_flux%lw_dn_band
    if (allocated(flux%sw_up_band)) flux%sw_up_band = private_flux%sw_up_band
    if (allocated(flux%sw_dn_band)) flux%sw_dn_band = private_flux%sw_dn_band
    if (allocated(flux%sw_dn_direct_band)) flux%sw_dn_direct_band = private_flux%sw_dn_direct_band
    if (allocated(flux%lw_up_clear_band)) flux%lw_up_clear_band = private_flux%lw_up_clear_band
    if (allocated(flux%lw_dn_clear_band)) flux%lw_dn_clear_band = private_flux%lw_dn_clear_band
    if (allocated(flux%sw_up_clear_band)) flux%sw_up_clear_band = private_flux%sw_up_clear_band
    if (allocated(flux%sw_dn_clear_band)) flux%sw_dn_clear_band = private_flux%sw_dn_clear_band
    if (allocated(flux%sw_dn_direct_clear_band)) flux%sw_dn_direct_clear_band = private_flux%sw_dn_direct_clear_band
    if (allocated(flux%lw_dn_surf_g)) flux%lw_dn_surf_g = private_flux%lw_dn_surf_g
    if (allocated(flux%lw_dn_surf_clear_g)) flux%lw_dn_surf_clear_g = private_flux%lw_dn_surf_clear_g
    if (allocated(flux%sw_dn_diffuse_surf_g)) flux%sw_dn_diffuse_surf_g = private_flux%sw_dn_diffuse_surf_g
    if (allocated(flux%sw_dn_direct_surf_g)) flux%sw_dn_direct_surf_g = private_flux%sw_dn_direct_surf_g
    if (allocated(flux%sw_dn_diffuse_surf_clear_g)) flux%sw_dn_diffuse_surf_clear_g = private_flux%sw_dn_diffuse_surf_clear_g
    if (allocated(flux%sw_dn_direct_surf_clear_g)) flux%sw_dn_direct_surf_clear_g = private_flux%sw_dn_direct_surf_clear_g
    if (allocated(flux%sw_dn_surf_band)) flux%sw_dn_surf_band = private_flux%sw_dn_surf_band
    if (allocated(flux%sw_dn_direct_surf_band)) flux%sw_dn_direct_surf_band = private_flux%sw_dn_direct_surf_band
    if (allocated(flux%sw_dn_surf_clear_band)) flux%sw_dn_surf_clear_band = private_flux%sw_dn_surf_clear_band
    if (allocated(flux%sw_dn_direct_surf_clear_band)) flux%sw_dn_direct_surf_clear_band = private_flux%sw_dn_direct_surf_clear_band
    if (allocated(flux%lw_dn_surf_canopy)) flux%lw_dn_surf_canopy = private_flux%lw_dn_surf_canopy
    if (allocated(flux%sw_dn_diffuse_surf_canopy)) flux%sw_dn_diffuse_surf_canopy = private_flux%sw_dn_diffuse_surf_canopy
    if (allocated(flux%sw_dn_direct_surf_canopy)) flux%sw_dn_direct_surf_canopy = private_flux%sw_dn_direct_surf_canopy
    if (allocated(flux%cloud_cover_lw)) flux%cloud_cover_lw = private_flux%cloud_cover_lw
    if (allocated(flux%cloud_cover_sw)) flux%cloud_cover_sw = private_flux%cloud_cover_sw
    if (allocated(flux%lw_derivatives)) flux%lw_derivatives = private_flux%lw_derivatives
    if (lhook) call dr_hook("radiation_interface:radiation", 1, hook)
    status = 0
  end subroutine
end module
