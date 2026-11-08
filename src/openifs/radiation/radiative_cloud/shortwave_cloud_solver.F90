!> Complete source-ordered shortwave independent-column cloud transport.
!! The original ECMWF comments and numerical body below retain source meaning.
!! Native canonical records own all arrays. Inputs use dimensionless optical
!! properties and W/m2 fluxes; only the selected columns of FLUX may change.
!! Private spectral arrays retain the original complete call order. Public
!! EXP/POW providers remain explicit dependencies with new domains unverified.
! Copyright (C)2015-2017 ECMWF. Original author Robin Hogan.
module md2asm_shortwave_cloud_solver
  use iso_fortran_env, only: int32, real64
  use native_radiation_optical_helpers, only: calc_two_stream_gammas_sw
  use native_radiation_layer_transport, only: calc_reflectance_transmittance_sw
  use native_radiation_column_transport, only: adding_ica_sw
  use md2asm_cloud_generator, only: cloud_generator
  implicit none
  private
  public :: solver_mcica_sw
contains
  subroutine solver_mcica_sw(nlev, istartcol, iendcol, &
       &  config, single_level, cloud, &
       &  od, ssa, g, od_cloud, ssa_cloud, g_cloud, &
       &  albedo_direct, albedo_diffuse, incoming_sw, &
       &  flux, status)

    use parkind1, only: jprb
    use radiation_config, only: config_type
    use radiation_single_level, only: single_level_type
    use radiation_cloud, only: cloud_type
    use radiation_flux, only: flux_type

    implicit none

    ! Inputs
    integer, intent(in) :: nlev               ! number of model levels
    integer, intent(in) :: istartcol, iendcol ! range of columns to process
    type(config_type), intent(in), target :: config
    type(single_level_type), intent(in) :: single_level
    type(cloud_type), intent(in) :: cloud

    ! Gas and aerosol optical depth, single-scattering albedo and
    ! asymmetry factor at each shortwave g-point
    real(jprb), intent(in), dimension(config%n_g_sw, nlev, istartcol:iendcol) :: &
         &  od, ssa, g

    ! Cloud and precipitation optical depth, single-scattering albedo and
    ! asymmetry factor in each shortwave band
    real(jprb), intent(in), dimension(config%n_bands_sw, nlev, istartcol:iendcol) :: &
         &  od_cloud, ssa_cloud, g_cloud

    ! Direct and diffuse surface albedos, and the incoming shortwave
    ! flux into a plane perpendicular to the incoming radiation at
    ! top-of-atmosphere in each of the shortwave g points
    real(jprb), intent(in), dimension(config%n_g_sw, istartcol:iendcol) :: &
         &  albedo_direct, albedo_diffuse, incoming_sw

    ! Output
    type(flux_type), intent(inout) :: flux
    integer(int32), intent(out) :: status

    ! Local variables

    ! Cosine of solar zenith angle
    real(jprb) :: cos_sza

    ! Diffuse reflectance and transmittance for each layer in clear
    ! and all skies
    real(jprb), dimension(config%n_g_sw, nlev) :: ref_clear, trans_clear, reflectance, transmittance

    ! Fraction of direct beam scattered by a layer into the upwelling
    ! or downwelling diffuse streams, in clear and all skies
    real(jprb), dimension(config%n_g_sw, nlev) :: ref_dir_clear, trans_dir_diff_clear, ref_dir, trans_dir_diff

    ! Transmittance for the direct beam in clear and all skies
    real(jprb), dimension(config%n_g_sw, nlev) :: trans_dir_dir_clear, trans_dir_dir

    ! Fluxes per g point
    real(jprb), dimension(config%n_g_sw, nlev + 1) :: flux_up, flux_dn_diffuse, flux_dn_direct

    ! Combined gas+aerosol+cloud optical depth, single scattering
    ! albedo and asymmetry factor
    real(jprb), dimension(config%n_g_sw) :: od_total, ssa_total, g_total

    ! Two-stream coefficients
    real(jprb), dimension(config%n_g_sw) :: gamma1, gamma2, gamma3

    ! Optical depth scaling from the cloud generator, zero indicating
    ! clear skies
    real(jprb), dimension(config%n_g_sw, nlev) :: od_scaling

    ! Modified optical depth after McICA scaling to represent cloud
    ! inhomogeneity
    real(jprb), dimension(config%n_g_sw) :: od_cloud_new

    ! Total cloud cover output from the cloud generator
    real(jprb) :: total_cloud_cover

    ! Number of g points
    integer :: ng

    ! Loop indices for level and column
    integer :: jlev, jcol

    status = 2
    if (nlev < 1 .or. nlev > 512 .or. istartcol < 1 .or. iendcol < istartcol - 1) return
    if (config%n_g_sw < 1 .or. config%n_g_sw > 4096) return
    if (config%i_overlap_scheme /= 1 .or. .not. config%do_clear) return

    ng = config%n_g_sw

    ! Loop through columns
    do jcol = istartcol, iendcol
      ! Only perform calculation if sun above the horizon
      if (single_level%cos_sza(jcol) > 0.0_jprb) then
        cos_sza = single_level%cos_sza(jcol)

        ! Clear-sky calculation - first compute clear-sky reflectance,
        ! transmittance etc at each model level
        if (.not. config%do_sw_delta_scaling_with_gases) then
          ! Delta-Eddington scaling has already been performed to the
          ! aerosol part of od, ssa and g
          do jlev = 1, nlev
            call calc_two_stream_gammas_sw(ng, &
                 &  cos_sza, ssa(:, jlev, jcol), g(:, jlev, jcol), &
                 &  gamma1, gamma2, gamma3)
            call calc_reflectance_transmittance_sw(ng, &
                 &  cos_sza, od(:, jlev, jcol), ssa(:, jlev, jcol), &
                 &  gamma1, gamma2, gamma3, &
                 &  ref_clear(:, jlev), trans_clear(:, jlev), &
                 &  ref_dir_clear(:, jlev), trans_dir_diff_clear(:, jlev), &
                 &  trans_dir_dir_clear(:, jlev))
          end do
        else
          ! Apply delta-Eddington scaling to the aerosol-gas mixture
          do jlev = 1, nlev
            od_total = od(:, jlev, jcol)
            ssa_total = ssa(:, jlev, jcol)
            g_total = g(:, jlev, jcol)
            call delta_eddington(od_total, ssa_total, g_total)
            call calc_two_stream_gammas_sw(ng, &
                 &  cos_sza, ssa_total, g_total, &
                 &  gamma1, gamma2, gamma3)
            call calc_reflectance_transmittance_sw(ng, &
                 &  cos_sza, od_total, ssa_total, &
                 &  gamma1, gamma2, gamma3, &
                 &  ref_clear(:, jlev), trans_clear(:, jlev), &
                 &  ref_dir_clear(:, jlev), trans_dir_diff_clear(:, jlev), &
                 &  trans_dir_dir_clear(:, jlev))
          end do
        end if

        ! Use adding method to compute fluxes
        call adding_ica_sw(ng, nlev, incoming_sw(:, jcol), &
             &  albedo_diffuse(:, jcol), albedo_direct(:, jcol), spread(cos_sza, 1, ng), &
             &  ref_clear, trans_clear, ref_dir_clear, trans_dir_diff_clear, &
             &  trans_dir_dir_clear, flux_up, flux_dn_diffuse, flux_dn_direct)

        ! Sum over g-points to compute and save clear-sky broadband
        ! fluxes
        flux%sw_up_clear(jcol, :) = ordered_spectral_sum(flux_up)
        if (allocated(flux%sw_dn_direct_clear)) then
          flux%sw_dn_direct_clear(jcol, :) &
               &  = ordered_spectral_sum(flux_dn_direct)
          flux%sw_dn_clear(jcol, :) = ordered_spectral_sum(flux_dn_diffuse) &
               &  + flux%sw_dn_direct_clear(jcol, :)
        else
          flux%sw_dn_clear(jcol, :) = ordered_spectral_sum(flux_dn_diffuse) &
               &  + ordered_spectral_sum(flux_dn_direct)
        end if
        ! Store spectral downwelling fluxes at surface
        flux%sw_dn_diffuse_surf_clear_g(:, jcol) = flux_dn_diffuse(:, nlev + 1)
        flux%sw_dn_direct_surf_clear_g(:, jcol) = flux_dn_direct(:, nlev + 1)

        ! Do cloudy-sky calculation
        call cloud_generator(ng, nlev, config%i_overlap_scheme, &
             &  single_level%iseed(jcol), &
             &  config%cloud_fraction_threshold, &
             &  cloud%fraction(jcol, :), cloud%overlap_param(jcol, :), &
             &  config%cloud_inhom_decorr_scaling, cloud%fractional_std(jcol, :), &
             &  config%pdf_sampler, od_scaling, total_cloud_cover, &
             &  is_beta_overlap=config%use_beta_overlap, status=status)
        if (status /= 0) return

        ! Store total cloud cover
        flux%cloud_cover_sw(jcol) = total_cloud_cover

        if (total_cloud_cover >= config%cloud_fraction_threshold) then
          ! Total-sky calculation
          do jlev = 1, nlev
            ! Compute combined gas+aerosol+cloud optical properties
            if (cloud%fraction(jcol, jlev) >= config%cloud_fraction_threshold) then
              od_cloud_new = od_scaling(:, jlev) &
                            &  *od_cloud(config%i_band_from_reordered_g_sw, jlev, jcol)
              od_total = od(:, jlev, jcol) + od_cloud_new
              ssa_total = 0.0_jprb
              g_total = 0.0_jprb
              where (od_total > 0.0_jprb)
                ssa_total = (ssa(:, jlev, jcol)*od(:, jlev, jcol) &
                     &     + ssa_cloud(config%i_band_from_reordered_g_sw, jlev, jcol) &
                     &     *od_cloud_new) &
                     &     /od_total
              end where
              where (ssa_total*od_total > 0.0_jprb)
                g_total = (g(:, jlev, jcol)*ssa(:, jlev, jcol)*od(:, jlev, jcol) &
                     &     + g_cloud(config%i_band_from_reordered_g_sw, jlev, jcol) &
                     &     *ssa_cloud(config%i_band_from_reordered_g_sw, jlev, jcol) &
                     &     *od_cloud_new) &
                     &     /(ssa_total*od_total)
              end where

              ! Apply delta-Eddington scaling to the cloud-aerosol-gas
              ! mixture
              if (config%do_sw_delta_scaling_with_gases) then
                call delta_eddington(od_total, ssa_total, g_total)
              end if

              ! Compute cloudy-sky reflectance, transmittance etc at
              ! each model level
              call calc_two_stream_gammas_sw(ng, &
                   &  cos_sza, ssa_total, g_total, &
                   &  gamma1, gamma2, gamma3)

              call calc_reflectance_transmittance_sw(ng, &
                   &  cos_sza, od_total, ssa_total, &
                   &  gamma1, gamma2, gamma3, &
                   &  reflectance(:, jlev), transmittance(:, jlev), &
                   &  ref_dir(:, jlev), trans_dir_diff(:, jlev), &
                   &  trans_dir_dir(:, jlev))

            else
              ! Clear-sky layer: copy over clear-sky values
              reflectance(:, jlev) = ref_clear(:, jlev)
              transmittance(:, jlev) = trans_clear(:, jlev)
              ref_dir(:, jlev) = ref_dir_clear(:, jlev)
              trans_dir_diff(:, jlev) = trans_dir_diff_clear(:, jlev)
              trans_dir_dir(:, jlev) = trans_dir_dir_clear(:, jlev)
            end if
          end do

          ! Use adding method to compute fluxes for an overcast sky
          call adding_ica_sw(ng, nlev, incoming_sw(:, jcol), &
               &  albedo_diffuse(:, jcol), albedo_direct(:, jcol), spread(cos_sza, 1, ng), &
               &  reflectance, transmittance, ref_dir, trans_dir_diff, &
               &  trans_dir_dir, flux_up, flux_dn_diffuse, flux_dn_direct)

          ! Store overcast broadband fluxes
          flux%sw_up(jcol, :) = ordered_spectral_sum(flux_up)
          if (allocated(flux%sw_dn_direct)) then
            flux%sw_dn_direct(jcol, :) = ordered_spectral_sum(flux_dn_direct)
            flux%sw_dn(jcol, :) = ordered_spectral_sum(flux_dn_diffuse) &
                 &  + flux%sw_dn_direct(jcol, :)
          else
            flux%sw_dn(jcol, :) = ordered_spectral_sum(flux_dn_diffuse) &
                 &  + ordered_spectral_sum(flux_dn_direct)
          end if

          ! Cloudy flux profiles currently assume completely overcast
          ! skies; perform weighted average with clear-sky profile
          flux%sw_up(jcol, :) = total_cloud_cover*flux%sw_up(jcol, :) &
               &  + (1.0_jprb - total_cloud_cover)*flux%sw_up_clear(jcol, :)
          flux%sw_dn(jcol, :) = total_cloud_cover*flux%sw_dn(jcol, :) &
               &  + (1.0_jprb - total_cloud_cover)*flux%sw_dn_clear(jcol, :)
          if (allocated(flux%sw_dn_direct)) then
            flux%sw_dn_direct(jcol, :) = total_cloud_cover*flux%sw_dn_direct(jcol, :) &
                 &  + (1.0_jprb - total_cloud_cover)*flux%sw_dn_direct_clear(jcol, :)
          end if
          ! Likewise for surface spectral fluxes
          flux%sw_dn_diffuse_surf_g(:, jcol) = flux_dn_diffuse(:, nlev + 1)
          flux%sw_dn_direct_surf_g(:, jcol) = flux_dn_direct(:, nlev + 1)
          flux%sw_dn_diffuse_surf_g(:, jcol) = total_cloud_cover*flux%sw_dn_diffuse_surf_g(:, jcol) &
               &     + (1.0_jprb - total_cloud_cover)*flux%sw_dn_diffuse_surf_clear_g(:, jcol)
          flux%sw_dn_direct_surf_g(:, jcol) = total_cloud_cover*flux%sw_dn_direct_surf_g(:, jcol) &
               &     + (1.0_jprb - total_cloud_cover)*flux%sw_dn_direct_surf_clear_g(:, jcol)

        else
          ! No cloud in profile and clear-sky fluxes already
          ! calculated: copy them over
          flux%sw_up(jcol, :) = flux%sw_up_clear(jcol, :)
          flux%sw_dn(jcol, :) = flux%sw_dn_clear(jcol, :)
          if (allocated(flux%sw_dn_direct)) then
            flux%sw_dn_direct(jcol, :) = flux%sw_dn_direct_clear(jcol, :)
          end if
          flux%sw_dn_diffuse_surf_g(:, jcol) = flux%sw_dn_diffuse_surf_clear_g(:, jcol)
          flux%sw_dn_direct_surf_g(:, jcol) = flux%sw_dn_direct_surf_clear_g(:, jcol)

        end if ! Cloud is present in profile

      else
        ! Set fluxes to zero if sun is below the horizon
        flux%sw_up(jcol, :) = 0.0_jprb
        flux%sw_dn(jcol, :) = 0.0_jprb
        if (allocated(flux%sw_dn_direct)) then
          flux%sw_dn_direct(jcol, :) = 0.0_jprb
        end if
        flux%sw_up_clear(jcol, :) = 0.0_jprb
        flux%sw_dn_clear(jcol, :) = 0.0_jprb
        if (allocated(flux%sw_dn_direct_clear)) then
          flux%sw_dn_direct_clear(jcol, :) = 0.0_jprb
        end if
        flux%sw_dn_diffuse_surf_g(:, jcol) = 0.0_jprb
        flux%sw_dn_direct_surf_g(:, jcol) = 0.0_jprb
        flux%sw_dn_diffuse_surf_clear_g(:, jcol) = 0.0_jprb
        flux%sw_dn_direct_surf_clear_g(:, jcol) = 0.0_jprb
      end if ! Sun above horizon

    end do ! Loop over columns

    status = 0
  end subroutine solver_mcica_sw
!> Sum spectral samples in increasing index order from positive zero.
  function ordered_spectral_sum(field) result(value)
    real(real64), intent(in) :: field(:, :)
    real(real64) :: value(size(field, 2))
    integer :: i, k
    do k = 1, size(field, 2)
      value(k) = 0.0_real64
      do i = 1, size(field, 1)
        value(k) = value(k) + field(i, k)
      end do
    end do
  end function
!> Apply the unchanged separately rounded gas-inclusive delta adjustment.
  subroutine delta_eddington(tau, omega, direction)
    real(real64), intent(inout) :: tau(:), omega(:), direction(:)
    real(real64) :: f, d, a, v
    integer :: i
    do i = 1, size(tau)
      f = direction(i)*direction(i); a = omega(i)*f; d = 1.0_real64 - a
      tau(i) = tau(i)*d
      a = 1.0_real64 - f; v = omega(i)*a; omega(i) = v/d
      a = 1.0_real64 + direction(i); direction(i) = direction(i)/a
    end do
  end subroutine
end module
