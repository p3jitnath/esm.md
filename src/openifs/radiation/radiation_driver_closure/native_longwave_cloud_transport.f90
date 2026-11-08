!> Complete selected longwave cloud solver over canonical native ecRad records.
!! Native gas/cloud arrays use spectral point, level and column order.
!! The source-selected route has clear sky and cloud scattering enabled,
!! aerosol scattering disabled, overlap one and beta overlap disabled.
!! All numerical children are own static providers; public types supply data only.
!! Scientific source attribution: Robin Hogan and ECMWF radiation_mcica_lw.
module native_longwave_cloud_transport
  use iso_fortran_env, only: jprb => real64, int32, real64
  use yomhook, only: lhook, dr_hook, jphook
  use radiation_config, only: config_type
  use radiation_single_level, only: single_level_type
  use radiation_cloud, only: cloud_type
  use radiation_flux, only: flux_type
  use native_radiation_optical_helpers, only: calc_two_stream_gammas_lw, calc_fluxes_no_scattering_lw
  use native_radiation_column_transport, only: calc_no_scattering_transmittance_lw, fast_adding_ica_lw
  use native_longwave_layer_transport, only: calc_reflectance_transmittance_lw
  use md2asm_longwave_surface_derivatives, only: calc_lw_derivatives_ica, modify_lw_derivatives_ica
  use md2asm_cloud_generator, only: cloud_generator
  implicit none
  private
  public :: solver_mcica_lw
  interface
    subroutine public_abort() bind(C, name="abort")
    end subroutine
  end interface
contains
!> Preserve complete flux owners, inactive cells and public descriptors.
!! Numerical work uses a private native flux copy and commits after all columns.
!! Caller establishes nearest-even and gradual underflow once.
subroutine solver_mcica_lw(nlev,istartcol,iendcol, config, single_level, cloud, od, ssa, g, od_cloud, ssa_cloud, g_cloud, planck_hl, emission, albedo, flux)
    integer, intent(in) :: nlev
    integer, intent(in) :: istartcol, iendcol
    type(config_type), intent(in) :: config
    type(single_level_type), intent(in) :: single_level
    type(cloud_type), intent(in) :: cloud
    real(jprb), intent(in), dimension(config%n_g_lw, nlev, istartcol:iendcol) :: od
    real(jprb), intent(in), dimension(config%n_g_lw_if_scattering, nlev, istartcol:iendcol) :: ssa, g
    real(jprb), intent(in), dimension(config%n_bands_lw, nlev, istartcol:iendcol) :: od_cloud
    real(jprb), intent(in), dimension(config%n_bands_lw_if_scattering, nlev, istartcol:iendcol) :: ssa_cloud, g_cloud
    real(jprb), intent(in), dimension(config%n_g_lw, nlev + 1, istartcol:iendcol) :: planck_hl
    real(jprb), intent(in), dimension(config%n_g_lw, istartcol:iendcol) :: emission, albedo
    type(flux_type), intent(inout) :: flux
    real(jprb), dimension(config%n_g_lw, nlev) :: ref_clear, trans_clear, reflectance, transmittance
    real(jprb), dimension(config%n_g_lw, nlev) :: source_up_clear, source_dn_clear, source_up, source_dn
    real(jprb), dimension(config%n_g_lw, nlev + 1) :: flux_up, flux_dn
    real(jprb), dimension(config%n_g_lw, nlev + 1) :: flux_up_clear, flux_dn_clear
    real(jprb), dimension(config%n_g_lw) :: od_total, ssa_total, g_total
    real(jprb), dimension(config%n_g_lw) :: gamma1, gamma2
    real(jprb), dimension(config%n_g_lw, nlev) :: od_scaling
    real(jprb), dimension(config%n_g_lw) :: od_cloud_new
    real(jprb) :: total_cloud_cover
    logical :: is_clear_sky_layer(nlev)
    integer :: i_cloud_top
    integer :: ng
    integer :: jlev, jcol
    real(jphook) :: hook_handle
    type(flux_type) :: private_flux
    integer(int32) :: child_status
    if (nlev < 1 .or. nlev > 512 .or. istartcol /= 1 .or. iendcol < 0 .or. iendcol > 4096) call public_abort()
    if (.not. config%do_clear .or. .not. config%do_lw_cloud_scattering .or. config%do_lw_aerosol_scattering) call public_abort()
    if (config%i_overlap_scheme /= 1 .or. config%use_beta_overlap) call public_abort()
    if (config%n_g_lw /= 140 .or. config%n_bands_lw /= 16) call public_abort()
    private_flux = flux
    if (lhook) call dr_hook('radiation_mcica_lw:solver_mcica_lw', 0, hook_handle)
    if (.not. config%do_clear) then
      call public_abort()
    end if
    ng = config%n_g_lw
    do jcol = istartcol, iendcol
    if (config%do_lw_aerosol_scattering) then
    do jlev = 1, nlev
      ssa_total = ssa(:, jlev, jcol)
      g_total = g(:, jlev, jcol)
      call calc_two_stream_gammas_lw(ng, ssa_total, g_total, gamma1, gamma2)
call calc_reflectance_transmittance_lw(ng, od(:,jlev,jcol), gamma1, gamma2, planck_hl(:,jlev,jcol), planck_hl(:,jlev+1,jcol), ref_clear(:,jlev), trans_clear(:,jlev), source_up_clear(:,jlev), source_dn_clear(:,jlev))
    end do
call adding_ica_lw(ng, nlev, ref_clear, trans_clear, source_up_clear, source_dn_clear, emission(:,jcol), albedo(:,jcol), flux_up_clear, flux_dn_clear)
    else
    do jlev = 1, nlev
call calc_no_scattering_transmittance_lw(ng, od(:,jlev,jcol), planck_hl(:,jlev,jcol), planck_hl(:,jlev+1, jcol), trans_clear(:,jlev), source_up_clear(:,jlev), source_dn_clear(:,jlev))
    end do
call calc_fluxes_no_scattering_lw(ng, nlev, trans_clear, source_up_clear, source_dn_clear, emission(:,jcol), albedo(:,jcol), flux_up_clear, flux_dn_clear)
    ref_clear = 0.0_jprb
    end if
    private_flux%lw_up_clear(jcol, :) = sum(flux_up_clear, 1)
    private_flux%lw_dn_clear(jcol, :) = sum(flux_dn_clear, 1)
    private_flux%lw_dn_surf_clear_g(:, jcol) = flux_dn_clear(:, nlev + 1)
call cloud_generator(ng, nlev, config%i_overlap_scheme, single_level%iseed(jcol) + 997, config%cloud_fraction_threshold, cloud%fraction(jcol,:), cloud%overlap_param(jcol,:), config%cloud_inhom_decorr_scaling, cloud%fractional_std(jcol,:), config%pdf_sampler, od_scaling, total_cloud_cover, is_beta_overlap=config%use_beta_overlap,status=child_status)
    if (child_status /= 0) call public_abort()
    private_flux%cloud_cover_lw(jcol) = total_cloud_cover
    if (total_cloud_cover >= config%cloud_fraction_threshold) then
      is_clear_sky_layer = .true.
      i_cloud_top = nlev + 1
      do jlev = 1, nlev
      if (cloud%fraction(jcol, jlev) >= config%cloud_fraction_threshold) then
        is_clear_sky_layer(jlev) = .false.
        if (i_cloud_top > jlev) then
          i_cloud_top = jlev
        end if
        od_cloud_new = od_scaling(:, jlev)*od_cloud(config%i_band_from_reordered_g_lw, jlev, jcol)
        od_total = od(:, jlev, jcol) + od_cloud_new
        ssa_total = 0.0_jprb
        g_total = 0.0_jprb
        if (config%do_lw_cloud_scattering) then
        if (config%do_lw_aerosol_scattering) then
          where (od_total > 0.0_jprb)
 ssa_total = (ssa(:, jlev, jcol)*od(:, jlev, jcol) + ssa_cloud(config%i_band_from_reordered_g_lw, jlev, jcol)*od_cloud_new)/od_total
          end where
          where (ssa_total*od_total > 0.0_jprb)
g_total = (g(:,jlev,jcol)*ssa(:,jlev,jcol)*od(:,jlev,jcol) +   g_cloud(config%i_band_from_reordered_g_lw,jlev,jcol) * ssa_cloud(config%i_band_from_reordered_g_lw,jlev,jcol) *  od_cloud_new) / (ssa_total*od_total)
          end where
        else
          where (od_total > 0.0_jprb)
            ssa_total = ssa_cloud(config%i_band_from_reordered_g_lw, jlev, jcol)*od_cloud_new/od_total
          end where
          where (ssa_total*od_total > 0.0_jprb)
g_total = g_cloud(config%i_band_from_reordered_g_lw,jlev,jcol) * ssa_cloud(config%i_band_from_reordered_g_lw,jlev,jcol) *  od_cloud_new / (ssa_total*od_total)
          end where
        end if
        call calc_two_stream_gammas_lw(ng, ssa_total, g_total, gamma1, gamma2)
call calc_reflectance_transmittance_lw(ng, od_total, gamma1, gamma2, planck_hl(:,jlev,jcol), planck_hl(:,jlev+1,jcol), reflectance(:,jlev), transmittance(:,jlev), source_up(:,jlev), source_dn(:,jlev))
        else
call calc_no_scattering_transmittance_lw(ng, od_total, planck_hl(:,jlev,jcol), planck_hl(:,jlev+1, jcol), transmittance(:,jlev), source_up(:,jlev), source_dn(:,jlev))
        end if
      else
        reflectance(:, jlev) = ref_clear(:, jlev)
        transmittance(:, jlev) = trans_clear(:, jlev)
        source_up(:, jlev) = source_up_clear(:, jlev)
        source_dn(:, jlev) = source_dn_clear(:, jlev)
      end if
      end do
      if (config%do_lw_aerosol_scattering) then
call adding_ica_lw(ng, nlev, reflectance, transmittance, source_up, source_dn, emission(:, jcol), albedo(:, jcol), flux_up, flux_dn)
      else if (config%do_lw_cloud_scattering) then
call fast_adding_ica_lw(ng, nlev, reflectance, transmittance, source_up, source_dn, emission(:,jcol), albedo(:,jcol), is_clear_sky_layer, i_cloud_top, flux_dn_clear, flux_up, flux_dn)
      else
call calc_fluxes_no_scattering_lw(ng, nlev, transmittance, source_up, source_dn, emission(:,jcol), albedo(:,jcol), flux_up, flux_dn)
      end if
      private_flux%lw_up(jcol, :) = sum(flux_up, 1)
      private_flux%lw_dn(jcol, :) = sum(flux_dn, 1)
private_flux%lw_up(jcol,:) =  total_cloud_cover *private_flux%lw_up(jcol,:) + (1.0_jprb - total_cloud_cover)*private_flux%lw_up_clear(jcol,:)
private_flux%lw_dn(jcol,:) =  total_cloud_cover *private_flux%lw_dn(jcol,:) + (1.0_jprb - total_cloud_cover)*private_flux%lw_dn_clear(jcol,:)
private_flux%lw_dn_surf_g(:,jcol) = total_cloud_cover*flux_dn(:,nlev+1) + (1.0_jprb - total_cloud_cover)*private_flux%lw_dn_surf_clear_g(:,jcol)
      if (config%do_lw_derivatives) then
 call calc_lw_derivatives_ica(ng, nlev, jcol, transmittance, flux_up(:, nlev + 1), private_flux%lw_derivatives, status=child_status)
        if (child_status /= 0) call public_abort()
        if (total_cloud_cover < 1.0_jprb - config%cloud_fraction_threshold) then
call modify_lw_derivatives_ica(ng, nlev, jcol, trans_clear, flux_up_clear(:,nlev+1), 1.0_jprb-total_cloud_cover, private_flux%lw_derivatives,status=child_status)
          if (child_status /= 0) call public_abort()
        end if
      end if
    else
      private_flux%lw_up(jcol, :) = private_flux%lw_up_clear(jcol, :)
      private_flux%lw_dn(jcol, :) = private_flux%lw_dn_clear(jcol, :)
      private_flux%lw_dn_surf_g(:, jcol) = private_flux%lw_dn_surf_clear_g(:, jcol)
      if (config%do_lw_derivatives) then
 call calc_lw_derivatives_ica(ng, nlev, jcol, trans_clear, flux_up_clear(:,nlev+1), private_flux%lw_derivatives,status=child_status)
        if (child_status /= 0) call public_abort()
      end if
    end if
    end do
    if (lhook) call dr_hook('radiation_mcica_lw:solver_mcica_lw', 1, hook_handle)
    flux%lw_up = private_flux%lw_up
    flux%lw_dn = private_flux%lw_dn
    flux%lw_up_clear = private_flux%lw_up_clear
    flux%lw_dn_clear = private_flux%lw_dn_clear
    flux%lw_dn_surf_g = private_flux%lw_dn_surf_g
    flux%lw_dn_surf_clear_g = private_flux%lw_dn_surf_clear_g
    flux%cloud_cover_lw = private_flux%cloud_cover_lw
    flux%lw_derivatives = private_flux%lw_derivatives
  end subroutine solver_mcica_lw

!> Unreachable guard for a branch excluded by the complete selected contract.
  subroutine adding_ica_lw(ng, nlev, reflectance, transmittance, source_up, source_dn, emission, albedo, up, dn)
    integer, intent(in) :: ng, nlev
    real(jprb), intent(in) :: reflectance(ng, nlev), transmittance(ng, nlev), source_up(ng, nlev), source_dn(ng, nlev)
    real(jprb), intent(in) :: emission(ng), albedo(ng)
    real(jprb), intent(inout) :: up(ng, nlev + 1), dn(ng, nlev + 1)
    call public_abort()
  end subroutine

end module
