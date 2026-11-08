!> Complete native mass-input and direct-input aerosol optical mixture.
!! Optical outputs are dimensionless (spectral point,level,selected column).
!! Original ECMWF comments below describe units and ordered component mixing.
!! Native records supply readonly tables and gas amounts; no original method
!! computes humidity indices, gas conversion or a numerical optical stage.
! Copyright(C)2014-2017 ECMWF. Original author Robin Hogan.
module md2asm_aerosol_optical_mixture
  use iso_fortran_env, only: int32, real64
  use radiation_aerosol_optics_data, only: aerosol_optics_type
  use radiation_gas, only: gas_type, IAirMolarMass, IGasMolarMass, IVolumeMixingRatio
  use native_radiation_optical_helpers, only: delta_scalar => delta_eddington_extensive
  implicit none
  private
  integer, parameter :: jprb = real64
  public :: add_aerosol_optics, add_aerosol_optics_direct, calc_rh_index
contains
  subroutine add_aerosol_optics(nlev, istartcol, iendcol, &
       &  config, thermodynamics, gas, aerosol, &
       &  od_lw, ssa_lw, g_lw, od_sw, ssa_sw, g_sw, status)

    use parkind1, only: jprb
    use radiation_config, only: config_type
    use radiation_thermodynamics, only: thermodynamics_type
    use radiation_gas, only: gas_type, IH2O, IMassMixingRatio
    use radiation_aerosol, only: aerosol_type
    use radiation_constants, only: AccelDueToGravity
    use radiation_aerosol_optics_data, only: aerosol_optics_type, &
         &  IAerosolClassUndefined, IAerosolClassIgnored, &
         &  IAerosolClassHydrophobic, IAerosolClassHydrophilic

    integer, intent(in) :: nlev               ! number of model levels
    integer, intent(in) :: istartcol, iendcol ! range of columns to process
    type(config_type), intent(in), target :: config
    type(thermodynamics_type), intent(in) :: thermodynamics
    type(gas_type), intent(in) :: gas
    type(aerosol_type), intent(in) :: aerosol
    integer(int32), intent(out) :: status
    ! Optical depth, single scattering albedo and asymmetry factor of
    ! the atmosphere (gases on input, gases and aerosols on output)
    ! for each g point. Note that longwave ssa and asymmetry and
    ! shortwave asymmetry are all zero for gases, so are not yet
    ! defined on input and are therefore intent(inout).
    real(jprb), dimension(config%n_g_lw, nlev, istartcol:iendcol), &
         &   intent(inout) :: od_lw
    real(jprb), dimension(config%n_g_lw_if_scattering, nlev, istartcol:iendcol), &
         &   intent(inout) :: ssa_lw, g_lw
    real(jprb), dimension(config%n_g_sw, nlev, istartcol:iendcol), &
         &   intent(inout) :: od_sw, ssa_sw
    real(jprb), dimension(config%n_g_sw, nlev, istartcol:iendcol), &
         &   intent(inout) :: g_sw

    ! Extinction optical depth, scattering optical depth and
    ! asymmetry-times-scattering-optical-depth for all the aerosols at
    ! a point in space for each spectral band of the shortwave and
    ! longwave spectrum
    real(jprb), dimension(config%n_bands_sw) &
         & :: od_sw_aerosol, scat_sw_aerosol, scat_g_sw_aerosol, local_od_sw
    real(jprb), dimension(config%n_bands_lw) :: od_lw_aerosol, local_od_lw
    real(jprb), dimension(config%n_bands_lw_if_scattering) &
         & :: scat_lw_aerosol, scat_g_lw_aerosol

    real(jprb) :: h2o_mmr(istartcol:iendcol, nlev)

    real(jprb) :: rh ! Relative humidity with respect to liquid water

    ! Factor (kg m-2) to convert mixing ratio (kg kg-1) to mass in
    ! path (kg m-2)
    real(jprb) :: factor

    ! Temporary extinction and scattering optical depths of aerosol
    ! plus gas
    real(jprb) :: local_od, local_scat

    ! Loop indices for column, level, g point, band and aerosol type
    integer :: jcol, jlev, jg, jtype

    ! Range of levels over which aerosols are present
    integer :: istartlev, iendlev

    ! Indices to spectral band and relative humidity look-up table
    integer :: iband, irh

    ! Pointer to the aerosol optics coefficients for brevity of access
    type(aerosol_optics_type), pointer :: ao

    status = 2
    if (nlev < 1 .or. nlev > 512 .or. istartcol < 1 .or. iendcol < istartcol - 1) return
    if (aerosol%is_direct) then
      ! Aerosol optical properties have been provided in each band
      ! directly by the user
      call add_aerosol_optics_direct(nlev, istartcol, iendcol, &
           &  config, aerosol, &
           &  od_lw, ssa_lw, g_lw, od_sw, ssa_sw, g_sw, status)
      if (status /= 0) return
    else
      ! Aerosol mixing ratios have been provided

      do jtype = 1, config%n_aerosol_types
        if (config%aerosol_optics%iclass(jtype) == IAerosolClassUndefined) then
          continue
          status = 2; return
        end if
      end do

      if (config%iverbose >= 2) then
        continue
      end if

      ao => config%aerosol_optics

      istartlev = lbound(aerosol%mixing_ratio, 2)
      iendlev = ubound(aerosol%mixing_ratio, 2)

      if (ubound(aerosol%mixing_ratio, 3) /= config%n_aerosol_types) then
        continue
        status = 2; return
      end if

      ! Set variables to zero that may not have been previously
      g_sw = 0.0_jprb
      if (config%do_lw_aerosol_scattering) then
        ssa_lw = 0.0_jprb
        g_lw = 0.0_jprb
      end if

      call get_water_mass_ratio(gas, istartcol, h2o_mmr, status)
      if (status /= 0) return

      ! Loop over position
      do jlev = istartlev, iendlev
        do jcol = istartcol, iendcol
          ! Compute relative humidity with respect to liquid
          ! saturation and the index to the relative-humidity index of
          ! hydrophilic-aerosol data
          rh = h2o_mmr(jcol, jlev)/thermodynamics%h2o_sat_liq(jcol, jlev)
          irh = calc_rh_index(ao, rh)

          factor = (thermodynamics%pressure_hl(jcol, jlev + 1) &
               &    - thermodynamics%pressure_hl(jcol, jlev)) &
               &   /AccelDueToGravity

          ! Reset temporary arrays
          od_sw_aerosol = 0.0_jprb
          scat_sw_aerosol = 0.0_jprb
          scat_g_sw_aerosol = 0.0_jprb
          od_lw_aerosol = 0.0_jprb
          scat_lw_aerosol = 0.0_jprb
          scat_g_lw_aerosol = 0.0_jprb

          do jtype = 1, config%n_aerosol_types
            ! Add the optical depth, scattering optical depth and
            ! scattering optical depth-weighted asymmetry factor for
            ! this aerosol type to the total for all aerosols.  Note
            ! that the following expressions are array-wise, the
            ! dimension being spectral band.
            if (ao%iclass(jtype) == IAerosolClassHydrophobic) then
              local_od_sw = factor*aerosol%mixing_ratio(jcol, jlev, jtype) &
                           &  *ao%mass_ext_sw_phobic(:, ao%itype(jtype))
              od_sw_aerosol = od_sw_aerosol + local_od_sw
              scat_sw_aerosol = scat_sw_aerosol &
                   &  + local_od_sw*ao%ssa_sw_phobic(:, ao%itype(jtype))
              scat_g_sw_aerosol = scat_g_sw_aerosol &
                   &  + local_od_sw*ao%ssa_sw_phobic(:, ao%itype(jtype)) &
                   &  *ao%g_sw_phobic(:, ao%itype(jtype))
              if (config%do_lw_aerosol_scattering) then
                local_od_lw = factor*aerosol%mixing_ratio(jcol, jlev, jtype) &
                             &  *ao%mass_ext_lw_phobic(:, ao%itype(jtype))
                od_lw_aerosol = od_lw_aerosol + local_od_lw
                scat_lw_aerosol = scat_lw_aerosol &
                     &  + local_od_lw*ao%ssa_lw_phobic(:, ao%itype(jtype))
                scat_g_lw_aerosol = scat_g_lw_aerosol &
                     &  + local_od_lw*ao%ssa_lw_phobic(:, ao%itype(jtype)) &
                     &  *ao%g_lw_phobic(:, ao%itype(jtype))
              else
                ! If aerosol longwave scattering is not included then we
                ! weight the optical depth by the single scattering
                ! co-albedo
                od_lw_aerosol = od_lw_aerosol &
                     &  + factor*aerosol%mixing_ratio(jcol, jlev, jtype) &
                     &  *ao%mass_ext_lw_phobic(:, ao%itype(jtype)) &
                     &  *(1.0_jprb - ao%ssa_lw_phobic(:, ao%itype(jtype)))
              end if
            else if (ao%iclass(jtype) == IAerosolClassHydrophilic) then
              ! Hydrophilic aerosols require the look-up tables to
              ! be indexed with irh
              local_od_sw = factor*aerosol%mixing_ratio(jcol, jlev, jtype) &
                           &  *ao%mass_ext_sw_philic(:, irh, ao%itype(jtype))
              od_sw_aerosol = od_sw_aerosol + local_od_sw
              scat_sw_aerosol = scat_sw_aerosol &
                   &  + local_od_sw*ao%ssa_sw_philic(:, irh, ao%itype(jtype))
              scat_g_sw_aerosol = scat_g_sw_aerosol &
                   &  + local_od_sw*ao%ssa_sw_philic(:, irh, ao%itype(jtype)) &
                   &  *ao%g_sw_philic(:, irh, ao%itype(jtype))
              if (config%do_lw_aerosol_scattering) then
                local_od_lw = factor*aerosol%mixing_ratio(jcol, jlev, jtype) &
                             &  *ao%mass_ext_lw_philic(:, irh, ao%itype(jtype))
                od_lw_aerosol = od_lw_aerosol + local_od_lw
                scat_lw_aerosol = scat_lw_aerosol &
                     &  + local_od_lw*ao%ssa_lw_philic(:, irh, ao%itype(jtype))
                scat_g_lw_aerosol = scat_g_lw_aerosol &
                     &  + local_od_lw*ao%ssa_lw_philic(:, irh, ao%itype(jtype)) &
                     &  *ao%g_lw_philic(:, irh, ao%itype(jtype))
              else
                ! If aerosol longwave scattering is not included then we
                ! weight the optical depth by the single scattering
                ! co-albedo
                od_lw_aerosol = od_lw_aerosol &
                     &  + factor*aerosol%mixing_ratio(jcol, jlev, jtype) &
                     &  *ao%mass_ext_lw_philic(:, irh, ao%itype(jtype)) &
                     &  *(1.0_jprb - ao%ssa_lw_philic(:, irh, ao%itype(jtype)))
              end if
            end if
            ! Implicitly, if ao%iclass(jtype) == IAerosolClassNone, then
            ! no aerosol scattering properties are added

          end do ! Loop over aerosol type

          if (.not. config%do_sw_delta_scaling_with_gases) then
            ! Delta-Eddington scaling on aerosol only.  Note that if
            ! do_sw_delta_scaling_with_gases==.true. then the delta
            ! scaling is done to the cloud-aerosol-gas mixture inside
            ! the solver
            call delta_eddington_extensive(od_sw_aerosol, scat_sw_aerosol, &
                 &                         scat_g_sw_aerosol)
          end if

          ! Combine aerosol shortwave scattering properties with gas
          ! properties (noting that any gas scattering will have an
          ! asymmetry factor of zero)
          if (od_sw_aerosol(1) > 0.0_jprb) then
            do jg = 1, config%n_g_sw
              iband = config%i_band_from_reordered_g_sw(jg)
              local_od = od_sw(jg, jlev, jcol) + od_sw_aerosol(iband)
              local_scat = ssa_sw(jg, jlev, jcol)*od_sw(jg, jlev, jcol) &
                   &  + scat_sw_aerosol(iband)
              ! Note that asymmetry_sw of gases is zero so the following
              ! simply weights the aerosol asymmetry by the scattering
              ! optical depth
              g_sw(jg, jlev, jcol) = scat_g_sw_aerosol(iband)/local_scat
              ssa_sw(jg, jlev, jcol) = local_scat/local_od
              od_sw(jg, jlev, jcol) = local_od
            end do
          end if

          ! Combine aerosol longwave scattering properties with gas
          ! properties, noting that in the longwave, gases do not
          ! scatter at all
          if (config%do_lw_aerosol_scattering) then

            call delta_eddington_extensive(od_lw_aerosol, scat_lw_aerosol, &
                 &                         scat_g_lw_aerosol)

            do jg = 1, config%n_g_lw
              iband = config%i_band_from_reordered_g_lw(jg)
              if (od_lw_aerosol(iband) > 0.0_jprb) then
                ! All scattering is due to aerosols, therefore the
                ! asymmetry factor is equal to the value for aerosols
                if (scat_lw_aerosol(iband) > 0.0_jprb) then
                  g_lw(jg, jlev, jcol) = scat_g_lw_aerosol(iband) &
                       &  /scat_lw_aerosol(iband)
                else
                  g_lw(jg, jlev, jcol) = 0.0_jprb
                end if
                local_od = od_lw(jg, jlev, jcol) + od_lw_aerosol(iband)
                ssa_lw(jg, jlev, jcol) = scat_lw_aerosol(iband)/local_od
                od_lw(jg, jlev, jcol) = local_od
              end if
            end do
          else
            do jg = 1, config%n_g_lw
              od_lw(jg, jlev, jcol) = od_lw(jg, jlev, jcol) &
                   &  + od_lw_aerosol(config%i_band_from_reordered_g_lw(jg))
            end do
          end if

        end do ! Loop over column
      end do ! Loop over level

    end if

    status = 0
  end subroutine add_aerosol_optics

  !---------------------------------------------------------------------
  ! Add precomputed optical properties to gas optical depth and
  ! scattering properties
  subroutine add_aerosol_optics_direct(nlev, istartcol, iendcol, &
       &  config, aerosol, &
       &  od_lw, ssa_lw, g_lw, od_sw, ssa_sw, g_sw, status)

    use parkind1, only: jprb
    use radiation_config, only: config_type
    use radiation_aerosol, only: aerosol_type

    integer, intent(in) :: nlev               ! number of model levels
    integer, intent(in) :: istartcol, iendcol ! range of columns to process
    type(config_type), intent(in), target :: config
    type(aerosol_type), intent(in) :: aerosol
    integer(int32), intent(out) :: status
    ! Optical depth, single scattering albedo and asymmetry factor of
    ! the atmosphere (gases on input, gases and aerosols on output)
    ! for each g point. Note that longwave ssa and asymmetry and
    ! shortwave asymmetry are all zero for gases, so are not yet
    ! defined on input and are therefore intent(inout).
    real(jprb), dimension(config%n_g_lw, nlev, istartcol:iendcol), &
         &   intent(inout) :: od_lw
    real(jprb), dimension(config%n_g_lw_if_scattering, nlev, istartcol:iendcol), &
         &   intent(inout) :: ssa_lw, g_lw
    real(jprb), dimension(config%n_g_sw, nlev, istartcol:iendcol), &
         &   intent(inout) :: od_sw, ssa_sw
    real(jprb), dimension(config%n_g_sw, nlev, istartcol:iendcol), &
         &   intent(inout) :: g_sw

    ! Temporary extinction and scattering optical depths of aerosol
    ! plus gas
    real(jprb) :: local_od, local_scat

    ! Extinction optical depth, scattering optical depth and
    ! asymmetry-times-scattering-optical-depth for all the aerosols at
    ! a point in space for each spectral band of the shortwave and
    ! longwave spectrum
    real(jprb), dimension(config%n_bands_sw) &
         & :: od_sw_aerosol, scat_sw_aerosol, scat_g_sw_aerosol
    real(jprb), dimension(config%n_bands_lw) :: od_lw_aerosol
    real(jprb), dimension(config%n_bands_lw_if_scattering) &
         & :: scat_lw_aerosol, scat_g_lw_aerosol

    ! Loop indices for column, level, g point and band
    integer :: jcol, jlev, jg

    ! Range of levels over which aerosols are present
    integer :: istartlev, iendlev

    ! Indices to spectral band
    integer :: iband

    status = 2
    if (nlev < 1 .or. nlev > 512 .or. istartcol < 1 .or. iendcol < istartcol - 1) return
    if (config%do_sw) then
      ! Check array dimensions
      if (ubound(aerosol%od_sw, 1) /= config%n_bands_sw) then
        continue
        status = 2; return
      end if

      istartlev = lbound(aerosol%od_sw, 2)
      iendlev = ubound(aerosol%od_sw, 2)

      ! Set variables to zero that may not have been previously
      g_sw = 0.0_jprb

      ! Loop over position
      do jcol = istartcol, iendcol
        do jlev = istartlev, iendlev
          od_sw_aerosol = aerosol%od_sw(:, jlev, jcol)
          scat_sw_aerosol = aerosol%ssa_sw(:, jlev, jcol)*od_sw_aerosol
          scat_g_sw_aerosol = aerosol%g_sw(:, jlev, jcol)*scat_sw_aerosol

          if (.not. config%do_sw_delta_scaling_with_gases) then
            ! Delta-Eddington scaling on aerosol only.  Note that if
            ! do_sw_delta_scaling_with_gases==.true. then the delta
            ! scaling is done to the cloud-aerosol-gas mixture inside
            ! the solver
            call delta_eddington_extensive(od_sw_aerosol, scat_sw_aerosol, &
                 &                         scat_g_sw_aerosol)
          end if

          ! Combine aerosol shortwave scattering properties with gas
          ! properties (noting that any gas scattering will have an
          ! asymmetry factor of zero)
          if (od_sw_aerosol(1) > 0.0_jprb) then
            do jg = 1, config%n_g_sw
              iband = config%i_band_from_reordered_g_sw(jg)
              local_od = od_sw(jg, jlev, jcol) + od_sw_aerosol(iband)
              local_scat = ssa_sw(jg, jlev, jcol)*od_sw(jg, jlev, jcol) &
                   &  + scat_sw_aerosol(iband)
              ! Note that asymmetry_sw of gases is zero so the following
              ! simply weights the aerosol asymmetry by the scattering
              ! optical depth
              g_sw(jg, jlev, jcol) = scat_g_sw_aerosol(iband)/local_scat
              ssa_sw(jg, jlev, jcol) = local_scat/local_od
              od_sw(jg, jlev, jcol) = local_od
            end do
          end if
        end do
      end do

    end if

    if (config%do_lw) then

      if (ubound(aerosol%od_lw, 1) /= config%n_bands_lw) then
        continue
        status = 2; return
      end if

      istartlev = lbound(aerosol%od_lw, 2)
      iendlev = ubound(aerosol%od_lw, 2)

      if (config%do_lw_aerosol_scattering) then
        ssa_lw = 0.0_jprb
        g_lw = 0.0_jprb

        ! Loop over position
        do jcol = istartcol, iendcol
          do jlev = istartlev, iendlev
            od_lw_aerosol = aerosol%od_lw(:, jlev, jcol)
            scat_lw_aerosol = aerosol%ssa_lw(:, jlev, jcol)*od_lw_aerosol
            scat_g_lw_aerosol = aerosol%g_lw(:, jlev, jcol)*scat_lw_aerosol

            call delta_eddington_extensive(od_lw_aerosol, scat_lw_aerosol, &
                 &                         scat_g_lw_aerosol)

            do jg = 1, config%n_g_lw
              iband = config%i_band_from_reordered_g_lw(jg)
              if (od_lw_aerosol(iband) > 0.0_jprb) then
                ! All scattering is due to aerosols, therefore the
                ! asymmetry factor is equal to the value for aerosols
                if (scat_lw_aerosol(iband) > 0.0_jprb) then
                  g_lw(jg, jlev, jcol) = scat_g_lw_aerosol(iband) &
                       &  /scat_lw_aerosol(iband)
                else
                  g_lw(jg, jlev, jcol) = 0.0_jprb
                end if
                local_od = od_lw(jg, jlev, jcol) + od_lw_aerosol(iband)
                ssa_lw(jg, jlev, jcol) = scat_lw_aerosol(iband)/local_od
                od_lw(jg, jlev, jcol) = local_od
              end if
            end do
          end do
        end do

      else ! No longwave scattering

        ! Loop over position
        do jcol = istartcol, iendcol
          do jlev = istartlev, iendlev
            ! If aerosol longwave scattering is not included then we
            ! weight the optical depth by the single scattering
            ! co-albedo
            od_lw_aerosol = aerosol%od_lw(:, jlev, jcol) &
                           &  *(1.0_jprb - aerosol%ssa_lw(:, jlev, jcol))
            do jg = 1, config%n_g_lw
              od_lw(jg, jlev, jcol) = od_lw(jg, jlev, jcol) &
                   &  + od_lw_aerosol(config%i_band_from_reordered_g_lw(jg))
            end do
          end do
        end do

      end if
    end if

    status = 0
  end subroutine add_aerosol_optics_direct
  function calc_rh_index(this, rh)

    type(aerosol_optics_type), intent(in) :: this
    real(jprb), intent(in) :: rh
    integer :: calc_rh_index

    if (.not. this%use_hydrophilic) then
      calc_rh_index = 0
    else if (rh > this%rh_lower(this%nrh)) then
      calc_rh_index = this%nrh
    else
      calc_rh_index = 1
      do while (rh > this%rh_lower(calc_rh_index + 1))
        calc_rh_index = calc_rh_index + 1
      end do
    end if

  end function calc_rh_index
!> Apply the unchanged extensive delta child to each supplied band in order.
  subroutine delta_eddington_extensive(tau, scatter, moment)
    real(real64), intent(inout) :: tau(:), scatter(:), moment(:)
    integer :: i
    do i = 1, size(tau)
      call delta_scalar(tau(i), scatter(i), moment(i))
    end do
  end subroutine
!> Read water mass ratio from canonical gas fields in original rounded order.
!! The readonly gas owner remains unchanged. Output is selected_columns by
!! all native levels in kg/kg; absent water writes positive zero.
  subroutine get_water_mass_ratio(gas, first, output, status)
    type(gas_type), intent(in) :: gas
    integer(int32), intent(in) :: first
    real(real64), intent(inout) :: output(:, :)
    integer(int32), intent(out) :: status
    real(real64), volatile :: factor
    integer :: i, k
    status = 2
    if (first < 1 .or. first + size(output, 1) - 1 > gas%ncol .or. size(output, 2) /= gas%nlev) return
    if (.not. gas%is_present(1)) then
      output = 0.0_real64; status = 0; return
    end if
    if (.not. allocated(gas%mixing_ratio)) return
    factor = 1.0_real64
    if (gas%iunits(1) == IVolumeMixingRatio) then
      factor = factor*IGasMolarMass(1); factor = factor/IAirMolarMass
    end if
    factor = factor*gas%scale_factor(1)
    do k = 1, size(output, 2)
      do i = 1, size(output, 1)
        if (factor /= 1.0_real64) then
          output(i, k) = gas%mixing_ratio(first + i - 1, k, 1)*factor
        else
          output(i, k) = gas%mixing_ratio(first + i - 1, k, 1)
        end if
      end do
    end do
    status = 0
  end subroutine

end module
