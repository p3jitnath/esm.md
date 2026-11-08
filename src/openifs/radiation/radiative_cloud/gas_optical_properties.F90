!> Complete native gas absorption, emission and incoming solar column.
!! Gravity is m/s2 and planet_scale is the dimensionless produced RPLDARE.
!! Readonly reference/coefficient records replace original table globals.
!! Original native config, single-level, thermodynamics and gas records supply
!! named fields only. No original type-bound method supplies a stage.
! Copyright(C)2014-2017 ECMWF. Original author Robin Hogan.
module md2asm_gas_optical_properties
  use iso_fortran_env, only: int32, real64
  use native_absorption_records, only: longwave_absorption_reduced_record, shortwave_absorption_record
  use longwave_reference_parameter_fields_mod, only: longwave_reference_parameter_record
  use native_radiation_gas_preparation, only: rrtm_prepare_gases, srtm_setcoef
  use native_shortwave_gas_inputs, only: shortwave_layer_inputs
  use native_longwave_coefficient_preparation, only: rrtm_setcoef_140gp
  use native_longwave_gas_optical_depth, only: rrtm_gas_optical_depth
  use native_shortwave_gas_optical_depth, only: srtm_gas_optical_depth
  use native_radiation_planck_emission, only: tabulated_planck_function_atmos, tabulated_planck_function_surf
  use radiation_config, only: config_type
  use radiation_thermodynamics, only: thermodynamics_type
  implicit none
  private
  public :: gas_optics
contains
  subroutine gas_optics(gravity,planet_scale,owned_reference,owned_lw_coefficients,owned_sw_coefficients,ncol,nlev,istartcol,iendcol, &
       &  config, single_level, thermodynamics, gas, &
       &  od_lw, od_sw, ssa_sw, lw_albedo, planck_hl, lw_emission, &
       &  incoming_sw, status)

    use parkind1, only: jprb, jpim

    USE PARRRTM, ONLY: JPBAND, JPXSEC, JPINPX
    USE YOERRTM, ONLY: JPGPT_LW => JPGPT
    USE YOESRTM, ONLY: JPGPT_SW => JPGPT
    USE YOMDIMV, ONLY: TDIMV

    use radiation_config, only: config_type, ISolverSpartacus
    use radiation_thermodynamics, only: thermodynamics_type
    use radiation_single_level, only: single_level_type
    use radiation_gas

    real(real64), intent(in) :: gravity, planet_scale
    type(longwave_reference_parameter_record), intent(in) :: owned_reference
    type(longwave_absorption_reduced_record), intent(in), target :: owned_lw_coefficients
    type(shortwave_absorption_record), intent(in), target :: owned_sw_coefficients
    integer(int32), intent(out) :: status
    integer, intent(in) :: ncol               ! number of columns
    integer, intent(in) :: nlev               ! number of model levels
    integer, intent(in) :: istartcol, iendcol ! range of columns to process
    type(config_type), intent(in) :: config
    type(single_level_type), intent(in), target :: single_level
    type(thermodynamics_type), intent(in) :: thermodynamics
    type(gas_type), intent(in) :: gas

    ! Longwave albedo of the surface
    real(jprb), dimension(config%n_g_lw, istartcol:iendcol), &
         &  intent(in), optional :: lw_albedo

    ! Gaseous layer optical depth in longwave and shortwave, and
    ! shortwave single scattering albedo (i.e. fraction of extinction
    ! due to Rayleigh scattering) at each g-point
    real(jprb), dimension(config%n_g_lw, nlev, istartcol:iendcol), intent(inout) :: &
         &   od_lw
    real(jprb), dimension(config%n_g_sw, nlev, istartcol:iendcol), intent(inout) :: &
         &   od_sw, ssa_sw

    ! The Planck function (emitted flux from a black body) at half
    ! levels at each longwave g-point
    real(jprb), dimension(config%n_g_lw, nlev + 1, istartcol:iendcol), &
         &   intent(inout), optional :: planck_hl
    ! Planck function for the surface (W m-2)
    real(jprb), dimension(config%n_g_lw, istartcol:iendcol), &
         &   intent(inout), optional :: lw_emission

    ! The incoming shortwave flux into a plane perpendicular to the
    ! incoming radiation at top-of-atmosphere in each of the shortwave
    ! g-points
    real(jprb), dimension(config%n_g_sw, istartcol:iendcol), &
         &   intent(inout), optional :: incoming_sw

    ! Structure holding number of levels
    TYPE(TDIMV) :: YDDIMV

    real(jprb), target :: incoming_sw_scale(istartcol:iendcol)

    ! The variables in capitals are used in the same way as the
    ! equivalent routine in the IFS

    real(jprb), target :: ZOD_LW(JPGPT_LW, nlev, istartcol:iendcol) ! Note ordering of dimensions
    real(jprb), target :: ZOD_SW(istartcol:iendcol, nlev, JPGPT_SW)
    real(jprb), target :: ZSSA_SW(istartcol:iendcol, nlev, JPGPT_SW)
    real(jprb), target :: ZINCSOL(istartcol:iendcol, JPGPT_SW)

    real(jprb), target :: ZCOLMOL(istartcol:iendcol, nlev)
    real(jprb), target :: ZCOLDRY(istartcol:iendcol, nlev)
    real(jprb), target :: ZWBRODL(istartcol:iendcol, nlev) !BROADENING GASES,column density (mol/cm2)
    real(jprb), target :: ZCOLBRD(istartcol:iendcol, nlev) !BROADENING GASES, column amount
    real(jprb), target :: ZWKL(istartcol:iendcol, JPINPX, nlev)

    real(jprb), target :: ZWX(istartcol:iendcol, JPXSEC, nlev) ! Amount of trace gases

    real(jprb), target :: ZFLUXFAC, ZPI

    ! - from AER
    real(jprb), target :: ZTAUAERL(istartcol:iendcol, nlev, JPBAND)

    !- from INTFAC
    real(jprb), target :: ZFAC00(istartcol:iendcol, nlev)
    real(jprb), target :: ZFAC01(istartcol:iendcol, nlev)
    real(jprb), target :: ZFAC10(istartcol:iendcol, nlev)
    real(jprb), target :: ZFAC11(istartcol:iendcol, nlev)

    !- from FOR
    real(jprb), target :: ZFORFAC(istartcol:iendcol, nlev)
    real(jprb), target :: ZFORFRAC(istartcol:iendcol, nlev)
    integer, target :: INDFOR(istartcol:iendcol, nlev)

    !- from MINOR
    integer, target :: INDMINOR(istartcol:iendcol, nlev)
    real(jprb), target :: ZSCALEMINOR(istartcol:iendcol, nlev)
    real(jprb), target :: ZSCALEMINORN2(istartcol:iendcol, nlev)
    real(jprb), target :: ZMINORFRAC(istartcol:iendcol, nlev)

    real(jprb), target :: &
         &  ZRAT_H2OCO2(istartcol:iendcol, nlev), ZRAT_H2OCO2_1(istartcol:iendcol, nlev), &
         &  ZRAT_H2OO3(istartcol:iendcol, nlev), ZRAT_H2OO3_1(istartcol:iendcol, nlev), &
         &  ZRAT_H2ON2O(istartcol:iendcol, nlev), ZRAT_H2ON2O_1(istartcol:iendcol, nlev), &
         &  ZRAT_H2OCH4(istartcol:iendcol, nlev), ZRAT_H2OCH4_1(istartcol:iendcol, nlev), &
         &  ZRAT_N2OCO2(istartcol:iendcol, nlev), ZRAT_N2OCO2_1(istartcol:iendcol, nlev), &
         &  ZRAT_O3CO2(istartcol:iendcol, nlev), ZRAT_O3CO2_1(istartcol:iendcol, nlev)

    !- from INTIND
    integer, target :: JP(istartcol:iendcol, nlev)
    integer, target :: JT(istartcol:iendcol, nlev)
    integer, target :: JT1(istartcol:iendcol, nlev)

    !- from PRECISE
    real(jprb), target :: ZONEMINUS, ZONEMINUS_ARRAY(istartcol:iendcol)

    !- from PROFDATA
    real(jprb), target :: ZCOLH2O(istartcol:iendcol, nlev)
    real(jprb), target :: ZCOLCO2(istartcol:iendcol, nlev)
    real(jprb), target :: ZCOLO3(istartcol:iendcol, nlev)
    real(jprb), target :: ZCOLN2O(istartcol:iendcol, nlev)
    real(jprb), target :: ZCOLCH4(istartcol:iendcol, nlev)
    real(jprb), target :: ZCOLO2(istartcol:iendcol, nlev)
    real(jprb), target :: ZCO2MULT(istartcol:iendcol, nlev)
    integer, target :: ILAYTROP(istartcol:iendcol)
    integer, target :: ILAYSWTCH(istartcol:iendcol)
    integer, target :: ILAYLOW(istartcol:iendcol)

    !- from PROFILE
    real(jprb), target :: ZPAVEL(istartcol:iendcol, nlev)
    real(jprb), target :: ZTAVEL(istartcol:iendcol, nlev)
    real(jprb), target :: ZPZ(istartcol:iendcol, 0:nlev)
    real(jprb), target :: ZTZ(istartcol:iendcol, 0:nlev)

    !- from SELF
    real(jprb), target :: ZSELFFAC(istartcol:iendcol, nlev)
    real(jprb), target :: ZSELFFRAC(istartcol:iendcol, nlev)
    integer, target :: INDSELF(istartcol:iendcol, nlev)

    !- from SP
    real(jprb), target :: ZPFRAC(istartcol:iendcol, JPGPT_LW, nlev)

    !- from SURFACE
    integer, target :: IREFLECT(istartcol:iendcol)

    real(jprb), target :: pressure_fl(ncol, nlev), temperature_fl(ncol, nlev)

    ! If nlev is less than the number of heights at which gas mixing
    ! ratios are stored, then we assume that the lower part of the
    ! atmosphere is required. This enables nlev=1 to be passed in to
    ! the routine, in which case the gas properties of the lowest
    ! layer are provided, useful for canopy radiative transfer.
    integer, target :: istartlev, iendlev

    integer, target :: jlev, jgreorder, jg, ig, iband, jcol

    type(shortwave_layer_inputs) :: sw_input
    real(real64), target :: sw_species(iendcol - istartcol + 1, nlev, 5)
    integer :: index_gas
    real(real64) :: sum_solar

    status = 2
    if (ncol < 1 .or. ncol > 4096 .or. nlev < 1 .or. nlev > 512) return
    if (istartcol < 1 .or. iendcol < istartcol - 1 .or. iendcol > ncol) return
    if (config%n_g_lw /= 140 .or. config%n_g_sw /= 112 .or. config%n_bands_lw /= 16 .or. config%n_bands_sw /= 14) return
    if (.not. allocated(gas%mixing_ratio)) return
    if (present(lw_albedo) .and. (.not. present(planck_hl) .or. .not. present(lw_emission))) return
    if (gas%ntype < 0 .or. gas%ntype > 12) return
    do index_gas = 1, gas%ntype
      ig = gas%icode(index_gas)
      if (ig < 1 .or. ig > 12) return
      if (gas%is_present(ig)) then
        if (gas%iunits(ig) /= IMassMixingRatio .or. gas%scale_factor(ig) /= 1.0_real64) return
      end if
    end do
    if (nlev > size(gas%mixing_ratio, 2)) return
    if (present(incoming_sw) .and. nlev < 2) return
    ! Compute start and end levels for indexing the gas mixing ratio
    ! and thermodynamics arrays
    iendlev = ubound(gas%mixing_ratio, 2)
    istartlev = iendlev - nlev + 1

    ZPI = 2.0_jprb*ASIN(1.0_jprb)
    ZFLUXFAC = ZPI*1.E+4
    ZONEMINUS = 1.0_jprb - 1.0e-6_jprb
    ZONEMINUS_ARRAY = ZONEMINUS

    ! RRTM/SRTM levels indicated, strangely, in two ways
    YDDIMV%NFLEVG = nlev

    pressure_fl(istartcol:iendcol, :) &
         &  = 0.5_jprb*(thermodynamics%pressure_hl(istartcol:iendcol, istartlev:iendlev) &
         &               + thermodynamics%pressure_hl(istartcol:iendcol, istartlev + 1:iendlev + 1))
    temperature_fl(istartcol:iendcol, :) &
         &  = 0.5_jprb*(thermodynamics%temperature_hl(istartcol:iendcol, istartlev:iendlev) &
         &               + thermodynamics%temperature_hl(istartcol:iendcol, istartlev + 1:iendlev + 1))

    ! Check we have gas mixing ratios in the right units
    ! The complete native unit admission above replaces this type-bound check.

    call rrtm_prepare_gases(istartcol, iendcol, ncol, nlev, &
                            thermodynamics%pressure_hl(:, istartlev:iendlev + 1), pressure_fl, &
                            thermodynamics%temperature_hl(:, istartlev:iendlev + 1), temperature_fl, &
                            gas%mixing_ratio(:, istartlev:iendlev, IH2O), gas%mixing_ratio(:, istartlev:iendlev, ICO2), &
                            gas%mixing_ratio(:, istartlev:iendlev, ICH4), gas%mixing_ratio(:, istartlev:iendlev, IN2O), &
                            gas%mixing_ratio(:, istartlev:iendlev, IO3), gas%mixing_ratio(:, istartlev:iendlev, ICFC11), &
                            gas%mixing_ratio(:, istartlev:iendlev, ICFC12), gas%mixing_ratio(:, istartlev:iendlev, IHCFC22), &
                            gas%mixing_ratio(:, istartlev:iendlev, ICCl4), gravity, planet_scale, &
                            ZCOLDRY, ZWBRODL, ZWKL, ZWX, ZPAVEL, ZTAVEL, ZPZ, ZTZ, IREFLECT)

    CALL RRTM_SETCOEF_140GP &
         &(owned_reference, YDDIMV, istartcol, iendcol, nlev, ZCOLDRY, ZWBRODL, ZWKL, &
         &  ZFAC00, ZFAC01, ZFAC10, ZFAC11, ZFORFAC, ZFORFRAC, INDFOR, JP, JT, JT1, &
         &  ZCOLH2O, ZCOLCO2, ZCOLO3, ZCOLN2O, ZCOLCH4, ZCOLO2, ZCO2MULT, ZCOLBRD, &
         &  ILAYTROP, ILAYSWTCH, ILAYLOW, ZPAVEL, ZTAVEL, ZSELFFAC, ZSELFFRAC, INDSELF, &
         &  INDMINOR, ZSCALEMINOR, ZSCALEMINORN2, ZMINORFRAC,&
         &  ZRAT_H2OCO2, ZRAT_H2OCO2_1, ZRAT_H2OO3, ZRAT_H2OO3_1, &
         &  ZRAT_H2ON2O, ZRAT_H2ON2O_1, ZRAT_H2OCH4, ZRAT_H2OCH4_1, &
         &  ZRAT_N2OCO2, ZRAT_N2OCO2_1, ZRAT_O3CO2, ZRAT_O3CO2_1)

    ZTAUAERL = 0.0_jprb

    CALL RRTM_GAS_OPTICAL_DEPTH &
         &(owned_reference, owned_lw_coefficients, YDDIMV, istartcol, iendcol, nlev, ZOD_LW, ZPAVEL, ZCOLDRY, ZCOLBRD, ZWX,&
         &  ZTAUAERL, ZFAC00, ZFAC01, ZFAC10, ZFAC11, ZFORFAC, ZFORFRAC, INDFOR, &
         &  JP, JT, JT1, ZONEMINUS,&
         &  ZCOLH2O, ZCOLCO2, ZCOLO3, ZCOLN2O, ZCOLCH4, ZCOLO2, ZCO2MULT,&
         &  ILAYTROP, ILAYSWTCH, ILAYLOW, ZSELFFAC, ZSELFFRAC, INDSELF, ZPFRAC, &
         &  INDMINOR, ZSCALEMINOR, ZSCALEMINORN2, ZMINORFRAC,&
         &  ZRAT_H2OCO2, ZRAT_H2OCO2_1, ZRAT_H2OO3, ZRAT_H2OO3_1, &
         &  ZRAT_H2ON2O, ZRAT_H2ON2O_1, ZRAT_H2OCH4, ZRAT_H2OCH4_1, &
         &  ZRAT_N2OCO2, ZRAT_N2OCO2_1, ZRAT_O3CO2, ZRAT_O3CO2_1)

    if (present(lw_albedo)) then

      call calculate_planck_atmos(owned_reference, nlev, istartcol, iendcol, config, &
           &                     thermodynamics, ZPFRAC, planck_hl)

      if (single_level%is_simple_surface) then
        call calculate_planck_surface(owned_reference, istartcol, iendcol, config, &
             &                    single_level%skin_temperature, ZPFRAC(:, :, 1), &
             &                    lw_emission)

        ! The following can be used to extract the parameters defined at
        ! the top of the planck_function routine below:
        !write(*,'(a,140(e12.5,","),a)') 'ZPFRAC_surf=[', &
        !&  sum(ZPFRAC(istartcol:iendcol,:,1),1) / (iendcol+1-istartcol), ']'

        ! lw_emission at this point is actually the planck function of
        ! the surface
        lw_emission = lw_emission*(1.0_jprb - lw_albedo)
      else
        ! Longwave emission has already been computed
        if (config%use_canopy_full_spectrum_lw) then
          lw_emission = transpose(single_level%lw_emission(istartcol:iendcol, :))
        else
          lw_emission = transpose(single_level%lw_emission(istartcol:iendcol, &
               & config%i_emiss_from_band_lw(config%i_band_from_reordered_g_lw)))
        end if
      end if

    end if

    if (config%i_solver_lw == ISolverSpartacus) then
      !    if (.true.) then
      ! We need to rearrange the gas optics info in memory: reordering
      ! the g points in order of approximately increasing optical
      ! depth (for efficient 3D processing on only the regions of the
      ! spectrum that are optically thin for gases) and reorder in
      ! pressure since the the functions above treat pressure
      ! decreasing with increasing index.  Note that the output gas
      ! arrays have dimensions in a different order to the inputs,
      ! so there is some inefficiency here.
      do jgreorder = 1, config%n_g_lw
        iband = config%i_band_from_reordered_g_lw(jgreorder)
        ig = config%i_g_from_reordered_g_lw(jgreorder)

        ! Top-of-atmosphere half level
        do jlev = 1, nlev
          do jcol = istartcol, iendcol
            ! Some g points can return negative optical depths;
            ! specifically original g points 54-56 which causes
            ! unphysical single-scattering albedo when combined with
            ! aerosol
            od_lw(jgreorder, jlev, jcol) &
                 &   = max(config%min_gas_od_lw, ZOD_LW(ig, nlev + 1 - jlev, jcol))
          end do
        end do
      end do
    else
      ! G points have not been reordered
      do jcol = istartcol, iendcol
        do jlev = 1, nlev
          ! Check for negative optical depth
          od_lw(:, jlev, jcol) = max(config%min_gas_od_lw, ZOD_LW(:, nlev + 1 - jlev, jcol))
        end do
      end do
    end if

    sw_input%levels = nlev
    sw_input%fac00(1:, 1:) => ZFAC00
    sw_input%fac01(1:, 1:) => ZFAC01
    sw_input%fac10(1:, 1:) => ZFAC10
    sw_input%fac11(1:, 1:) => ZFAC11
    sw_input%pressure_index(1:, 1:) => JP
    sw_input%temperature_index(1:, 1:) => JT
    sw_input%next_temperature_index(1:, 1:) => JT1
    sw_input%self_factor(1:, 1:) => ZSELFFAC
    sw_input%self_fraction(1:, 1:) => ZSELFFRAC
    sw_input%self_index(1:, 1:) => INDSELF
    sw_input%foreign_factor(1:, 1:) => ZFORFAC
    sw_input%foreign_fraction(1:, 1:) => ZFORFRAC
    sw_input%foreign_index(1:, 1:) => INDFOR
    sw_input%molecules(1:, 1:) => ZCOLMOL
    sw_input%gas(1:, 1:, 1:) => sw_species
    sw_input%tropopause(1:) => ILAYTROP
    sw_input%mixture_cap(1:) => ZONEMINUS_ARRAY
    sw_input%solar_cosine(1:) => single_level%cos_sza(istartcol:iendcol)
    call srtm_setcoef(owned_sw_coefficients, ZPAVEL, ZTAVEL, ZCOLDRY, ZWKL, sw_input)

    ! SRTM_GAS_OPTICAL_DEPTH will not initialize profiles when the sun
    ! is below the horizon, so we do it here
    ZOD_SW(istartcol:iendcol, :, :) = 0.0_jprb
    ZSSA_SW(istartcol:iendcol, :, :) = 0.0_jprb
    ZINCSOL(istartcol:iendcol, :) = 0.0_jprb

    call srtm_gas_optical_depth(owned_sw_coefficients, sw_input, ZINCSOL, ZOD_SW, ZSSA_SW)

    ! Scale the incoming solar per band, if requested
    if (config%use_spectral_solar_scaling) then
      ZINCSOL(istartcol:iendcol, :) = ZINCSOL(istartcol:iendcol, :) &
         & *spread(single_level%spectral_solar_scaling(config%i_band_from_reordered_g_sw), &
         &                                              1, iendcol - istartcol + 1)
    end if

    ! Scaling factor to ensure that the total solar irradiance is as
    ! requested.  Note that if the sun is below the horizon then
    ! ZINCSOL will be zero.
    if (present(incoming_sw)) then
      incoming_sw_scale = 1.0_jprb
      do jcol = istartcol, iendcol
        if (single_level%cos_sza(jcol) > 0.0_jprb) then
          sum_solar = 0.0_real64
          do jg = 1, 112
            sum_solar = sum_solar + ZINCSOL(jcol, jg)
          end do
          incoming_sw_scale(jcol) = single_level%solar_irradiance/sum_solar
        end if
      end do
    end if

    if (config%i_solver_sw == ISolverSpartacus) then
!    if (.true.) then
      ! Account for reordered g points
      do jgreorder = 1, config%n_g_sw
        ig = config%i_g_from_reordered_g_sw(jgreorder)
        do jlev = 1, nlev
          do jcol = istartcol, iendcol
            ! Check for negative optical depth
            od_sw(jgreorder, nlev + 1 - jlev, jcol) &
                 &  = max(config%min_gas_od_sw, ZOD_SW(jcol, jlev, ig))
            ssa_sw(jgreorder, nlev + 1 - jlev, jcol) = ZSSA_SW(jcol, jlev, ig)
          end do
        end do
        if (present(incoming_sw)) then
          incoming_sw(jgreorder, :) &
               &  = incoming_sw_scale(:)*ZINCSOL(:, ig)
        end if
      end do
    else
      ! G points have not been reordered
      do jg = 1, config%n_g_sw
        do jlev = 1, nlev
          do jcol = istartcol, iendcol
            ! Check for negative optical depth
            od_sw(jg, nlev + 1 - jlev, jcol) = max(config%min_gas_od_sw, ZOD_SW(jcol, jlev, jg))
            ssa_sw(jg, nlev + 1 - jlev, jcol) = ZSSA_SW(jcol, jlev, jg)
          end do
        end do
        if (present(incoming_sw)) then
          incoming_sw(jg, :) &
               &  = incoming_sw_scale(:)*ZINCSOL(:, jg)
        end if
      end do
    end if

    status = 0
  end subroutine gas_optics
!> Reuse complete owned atmospheric Planck lookup on the source lower levels.
  subroutine calculate_planck_atmos(reference, levels, first, last, config, thermodynamics, fraction, emission)
    type(longwave_reference_parameter_record), intent(in) :: reference
    integer(int32), intent(in) :: levels, first, last
    type(config_type), intent(in) :: config
    type(thermodynamics_type), intent(in) :: thermodynamics
    real(real64), intent(in) :: fraction(last - first + 1, 140, levels)
    real(real64), intent(inout) :: emission(config%n_g_lw, levels + 1, last - first + 1)
    integer :: start
    start = ubound(thermodynamics%temperature_hl, 2) - levels
    if (config%i_solver_lw == 3) then
      call tabulated_planck_function_atmos(levels, first, last, config%n_g_lw, config%n_bands_lw, config%i_solver_lw, &
        config%i_band_from_reordered_g_lw, config%i_g_from_reordered_g_lw, thermodynamics%temperature_hl(:, start:start + levels), &
                                           fraction, reference%totplnk, reference%delwave, emission)
    else
      call tabulated_planck_function_atmos(levels, first, last, config%n_g_lw, config%n_bands_lw, config%i_solver_lw, &
                  config%i_band_from_g_lw, config%i_g_from_reordered_g_lw, thermodynamics%temperature_hl(:, start:start + levels), &
                                           fraction, reference%totplnk, reference%delwave, emission)
    end if
  end subroutine
!> Reuse complete owned surface Planck lookup without changing input owners.
  subroutine calculate_planck_surface(reference, first, last, config, temperature, fraction, emission)
    type(longwave_reference_parameter_record), intent(in) :: reference
    integer(int32), intent(in) :: first, last
    type(config_type), intent(in) :: config
    real(real64), intent(in) :: temperature(:), fraction(last - first + 1, 140)
    real(real64), intent(inout) :: emission(config%n_g_lw, last - first + 1)
    if (config%i_solver_lw == 3) then
      call tabulated_planck_function_surf(first, last, config%n_g_lw, config%n_bands_lw, config%i_solver_lw, &
 config%i_band_from_reordered_g_lw,config%i_g_from_reordered_g_lw,temperature,fraction,reference%totplnk,reference%delwave,emission)
    else
      call tabulated_planck_function_surf(first, last, config%n_g_lw, config%n_bands_lw, config%i_solver_lw, &
     config%i_band_from_g_lw, config%i_g_from_reordered_g_lw, temperature, fraction, reference%totplnk, reference%delwave, emission)
    end if
  end subroutine
end module
