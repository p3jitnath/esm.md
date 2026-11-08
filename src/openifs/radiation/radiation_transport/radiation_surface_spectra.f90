!> Surface reflection and spectral flux projections on canonical native records.
!! Array ownership stays with the caller. No private descriptor bytes or original
!! numerical method calls are used. Fluxes have units W/m2; albedos are fractions.
module native_radiation_surface_spectra
  use iso_fortran_env, only: real64, int32
  use radiation_config, only: config_type
  use radiation_single_level, only: single_level_type
  use radiation_flux, only: flux_type
  use native_radiation_optical_helpers, only: indexed_sum
  implicit none
  private
  public :: get_albedos, calc_surface_spectral
contains
  !> Map each selected surface column to all configured spectral samples.
  !! Native single-level arrays are readonly (all_columns,surface_intervals).
  !! Output shapes are (configured_samples,last-first+1), with no allocation.
  !! An absent direct input leaves its full-spectrum output unchanged; other
  !! branches copy diffuse reflection. Longwave output is optional.
  subroutine get_albedos(this, first, last, config, sw_direct, sw_diffuse, lw_albedo)
    type(single_level_type), intent(in) :: this
    integer(int32), intent(in) :: first, last
    type(config_type), intent(in) :: config
    real(real64), intent(inout) :: sw_direct(:, :), sw_diffuse(:, :)
    real(real64), optional, intent(inout) :: lw_albedo(:, :)
    integer :: swmode, lwmode, i, j
    swmode = 1
    if (config%use_canopy_full_spectrum_sw) then
      swmode = 0
    elseif (config%do_nearest_spectral_sw_albedo) then
      swmode = 2
    end if
    call map_spectrum(this%sw_albedo, first, last, config, .false., swmode, sw_diffuse)
    if (allocated(this%sw_albedo_direct)) then
      call map_spectrum(this%sw_albedo_direct, first, last, config, .false., swmode, sw_direct)
    elseif (swmode /= 0) then
      do i = 1, last - first + 1
        do j = 1, config%n_g_sw
          sw_direct(j, i) = sw_diffuse(j, i)
        end do
      end do
    end if
    if (present(lw_albedo)) then
      lwmode = 1
      if (config%use_canopy_full_spectrum_lw) then
        lwmode = 0
      elseif (config%do_nearest_spectral_lw_emiss) then
        lwmode = 2
      end if
      call map_spectrum(this%lw_emissivity, first, last, config, .true., lwmode, lw_albedo)
    end if
  end subroutine
  !> Map full, weighted-band or nearest-interval spectra in the source order.
  !! A weight equal to either signed zero skips the corresponding input read.
  subroutine map_spectrum(input, first, last, config, longwave, mode, output)
    real(real64), intent(in) :: input(:, :)
    type(config_type), intent(in) :: config
    integer, intent(in) :: first, last, mode
    logical, intent(in) :: longwave
    real(real64), intent(inout) :: output(:, :)
    real(real64) :: bands(max(config%n_bands_sw, config%n_bands_lw)), v, p, weight
    integer :: i, b, a, j, interval, ng, nband, ninterval, band
    if (longwave) then
      ng = config%n_g_lw; nband = config%n_bands_lw
    else
      ng = config%n_g_sw; nband = config%n_bands_sw
    end if
    do i = first, last
      if (mode == 1) then
        if (longwave) then
          ninterval = size(config%lw_emiss_weights, 1)
        else
          ninterval = size(config%sw_albedo_weights, 1)
        end if
        do b = 1, nband
          bands(b) = 0.0_real64
          do a = 1, ninterval
            if (longwave) then
              weight = config%lw_emiss_weights(a, b)
            else
              weight = config%sw_albedo_weights(a, b)
            end if
            if (weight == 0.0_real64) cycle
            v = input(i, a)
            if (longwave) v = 1.0_real64 - v
            p = weight*v
            bands(b) = bands(b) + p
          end do
        end do
      end if
      do j = 1, ng
        if (mode == 0) then
          v = input(i, j)
          if (longwave) v = 1.0_real64 - v
        else
          if (longwave) then
            band = config%i_band_from_reordered_g_lw(j)
          else
            band = config%i_band_from_reordered_g_sw(j)
          end if
          if (mode == 1) then
            v = bands(band)
          else
            if (longwave) then
              interval = config%i_emiss_from_band_lw(band)
            else
              interval = config%i_albedo_from_band_sw(band)
            end if
            v = input(i, interval)
            if (longwave) v = 1.0_real64 - v
          end if
        end if
        output(j, i - first + 1) = v
      end do
    end do
  end subroutine
  !> Compute selected surface-band and canopy fluxes in place.
  !! Canonical flux fields have shape (spectral_intervals,all_columns).
  !! Configuration and map/weight owners are readonly. Only requested outputs
  !! in first:last change; all unrelated native fields and descriptors remain.
  subroutine calc_surface_spectral(this, config, first, last)
    type(flux_type), intent(inout) :: this
    type(config_type), intent(in) :: config
    integer(int32), intent(in) :: first, last
    integer :: i, j
    integer :: swmap(max(0, config%n_g_sw))
    integer :: lwmap(max(0, config%n_g_lw))
    real(real64) :: lw_bands(config%n_bands_lw)
    if (first > last) return
    if (config%do_sw) then
      if (config%do_surface_sw_spectral_flux) then
        do i = first, last
          call indexed_sum(this%sw_dn_direct_surf_g(:, i), config%i_band_from_reordered_g_sw, &
                           this%sw_dn_direct_surf_band(:, i))
          call indexed_sum(this%sw_dn_diffuse_surf_g(:, i), config%i_band_from_reordered_g_sw, &
                           this%sw_dn_surf_band(:, i))
          do j = 1, size(this%sw_dn_surf_band, 1)
            this%sw_dn_surf_band(j, i) = this%sw_dn_surf_band(j, i) + this%sw_dn_direct_surf_band(j, i)
          end do
        end do
        if (config%do_clear) then
          do i = first, last
            call indexed_sum(this%sw_dn_direct_surf_clear_g(:, i), config%i_band_from_reordered_g_sw, &
                             this%sw_dn_direct_surf_clear_band(:, i))
            call indexed_sum(this%sw_dn_diffuse_surf_clear_g(:, i), config%i_band_from_reordered_g_sw, &
                             this%sw_dn_surf_clear_band(:, i))
            do j = 1, size(this%sw_dn_surf_clear_band, 1)
              this%sw_dn_surf_clear_band(j, i) = this%sw_dn_surf_clear_band(j, i) + this%sw_dn_direct_surf_clear_band(j, i)
            end do
          end do
        end if
      end if
      if (config%do_canopy_fluxes_sw) then
        if (config%use_canopy_full_spectrum_sw) then
          do i = first, last
            call copy_values(this%sw_dn_diffuse_surf_g(:, i), this%sw_dn_diffuse_surf_canopy(:, i))
            call copy_values(this%sw_dn_direct_surf_g(:, i), this%sw_dn_direct_surf_canopy(:, i))
          end do
        elseif (config%do_nearest_spectral_sw_albedo) then
          do j = 1, size(swmap)
            swmap(j) = config%i_albedo_from_band_sw(config%i_band_from_reordered_g_sw(j))
          end do
          do i = first, last
            call indexed_sum(this%sw_dn_direct_surf_g(:, i), swmap, this%sw_dn_direct_surf_canopy(:, i))
            call indexed_sum(this%sw_dn_diffuse_surf_g(:, i), swmap, this%sw_dn_diffuse_surf_canopy(:, i))
          end do
        else
          do i = first, last
            call weighted_sum(config%sw_albedo_weights, this%sw_dn_surf_band(:, i), this%sw_dn_diffuse_surf_canopy(:, i))
            call weighted_sum(config%sw_albedo_weights, this%sw_dn_direct_surf_band(:, i), this%sw_dn_direct_surf_canopy(:, i))
            do j = 1, size(this%sw_dn_diffuse_surf_canopy, 1)
              this%sw_dn_diffuse_surf_canopy(j, i) = this%sw_dn_diffuse_surf_canopy(j, i) - this%sw_dn_direct_surf_canopy(j, i)
            end do
          end do
        end if
      end if
    end if
    if (config%do_lw .and. config%do_canopy_fluxes_lw) then
      if (config%use_canopy_full_spectrum_lw) then
        do i = first, last
          call copy_values(this%lw_dn_surf_g(:, i), this%lw_dn_surf_canopy(:, i))
        end do
      elseif (config%do_nearest_spectral_lw_emiss) then
        do j = 1, size(lwmap)
          lwmap(j) = config%i_emiss_from_band_lw(config%i_band_from_reordered_g_lw(j))
        end do
        do i = first, last
          call indexed_sum(this%lw_dn_surf_g(:, i), lwmap, this%lw_dn_surf_canopy(:, i))
        end do
      else
        do i = first, last
          call indexed_sum(this%lw_dn_surf_g(:, i), config%i_band_from_reordered_g_lw, lw_bands)
          call weighted_sum(config%lw_emiss_weights, lw_bands, this%lw_dn_surf_canopy(:, i))
        end do
      end if
    end if
  end subroutine
  !> Copy complete native vector values without evaluating arithmetic.
  subroutine copy_values(source, destination)
    real(real64), intent(in) :: source(:)
    real(real64), intent(inout) :: destination(:)
    integer :: j
    do j = 1, size(source)
      destination(j) = source(j)
    end do
  end subroutine
  !> Apply nonzero weights in increasing source-band order.
  subroutine weighted_sum(weights, source, destination)
    real(real64), intent(in) :: weights(:, :), source(:)
    real(real64), intent(inout) :: destination(:)
    real(real64) :: p
    integer :: j, i
    do i = 1, size(destination)
      destination(i) = 0.0_real64
    end do
    do j = 1, size(source)
      do i = 1, size(destination)
        if (weights(i, j) == 0.0_real64) cycle
        p = weights(i, j)*source(j)
        destination(i) = destination(i) + p
      end do
    end do
  end subroutine
end module
