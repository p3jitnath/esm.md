!> Own the selected OpenIFS ecRad settings and native allocation transfers.
!! Public ecRad supplies radiation-library services through config_type.
!! The native adapter owns defaults, selection, gas maps and call order.
module selected_ecrad_configuration_port
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_intptr_t
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use ieee_exceptions, only: ieee_get_flag, ieee_set_flag, ieee_underflow, ieee_inexact
  use radiation_config, only: config_type
  use radiation_cloud_optics, only: setup_cloud_optics
  use radiation_aerosol_optics, only: setup_aerosol_optics, dry_aerosol_sw_mass_extinction
  use yoerad, only: terad
  use yoephy, only: tephy
  use yoeaeratm, only: teaeratm
  use ecmwf_physics_control_fields_port, only: selected_composition_aerosol_flags
  use ecrad_configuration_defaults_mod, only: initialize_ecrad_configuration_defaults
  implicit none
  private
  public :: selected_ecrad_configuration_record
  public :: initialize_selected_ecrad_configuration, release_selected_ecrad_configuration
  public :: setup_ecrad_gas_band_maps, release_ecrad_gas_band_maps
  public :: require_optional_empty_radiation_group

  !> Hold the public configuration and source-owned spectral query outputs.
  !! CONFIG is the public ecRad config_type, with native descriptors.
  !! UV and PAR mean ultraviolet and photosynthetically active radiation.
  !! Band indices/counts are int32; weights are dimensionless real64 values.
  !! Both mass-extinction coefficients have units m**2/kg. Each fixed query
  !! array has100slots; only the first returned count changes on success.
  !! The caller initializes incoming scalar/fixed-array values and explicitly
  !! disassociates CONFIG's two I_SPEC pointer aliases. All44allocatable
  !! components must be absent before initialization. The caller retains
  !! every resulting owner until RELEASE_SELECTED_ECRAD_CONFIGURATION.
  type :: selected_ecrad_configuration_record
    type(config_type) :: config
    integer(int32) :: nweight_uv, iband_uv(100)
    real(real64) :: weight_uv(100)
    integer(int32) :: nweight_par, iband_par(100)
    real(real64) :: weight_par(100)
    real(real64) :: trop_bg_aer_mass_ext, strat_bg_aer_mass_ext
  end type

contains
  !> Build the selected configuration without changing caller outputs on refusal.
  !! All input records, arrays and strings are read only. OUTPUT is caller
  !! owned INOUT storage and must have the fresh owners stated by its type.
  !! LONGWAVE_BANDS and SHORTWAVE_BANDS are contiguous int32 arrays with at
  !! least256and224source band labels. The complete arrays are disjoint from
  !! each other and OUTPUT. OUTPUT is disjoint from every other input span,
  !! including the two allocated Planck interval arrays in RADIATION.
  !! TEXT has1:262144characters. DIRECTORY has1:511characters, no zero byte
  !! and no trailing space. Both composition flags must be false.
  !! The selected native TERAD, TEPHY and TEAERATM choices are admitted before
  !! any public library call. The launcher supplies the declared target
  !! floating controls, with nearest-even rounding and gradual underflow.
  !! Return0commits the complete selected result;1reports owned allocation
  !! failure after cleanup;2refuses without public mutation. Public ecRad
  !! file-error exits and natural arithmetic/errno effects remain visible.
  integer(int32) function initialize_selected_ecrad_configuration(output, radiation, physics, aerosols, &
                                                       longwave_bands, shortwave_bands, text, directory, composition) result(status)
    type(selected_ecrad_configuration_record), intent(inout), target :: output
    type(terad), intent(in), target :: radiation
    type(tephy), intent(in), target :: physics
    type(teaeratm), intent(in), target :: aerosols
    integer(int32), intent(in), target :: longwave_bands(:), shortwave_bands(:)
    character(len=*), intent(in), target :: text, directory
    type(selected_composition_aerosol_flags), intent(in), target :: composition
    type(config_type) :: staged, owner_carrier
    integer(int32) :: nweight_uv, nweight_par, iband_uv(100), iband_par(100)
    real(real64) :: weight_uv(100), weight_par(100), trop_extinction, strat_extinction
    real(real64) :: shortwave_bounds(5)
    integer(int32), parameter :: six_indices(6) = [1_int32, 2_int32, 3_int32, 4_int32, 5_int32, 6_int32]
    integer(int32), parameter :: aerosol_map(12) = [-1_int32, -2_int32, -3_int32, 7_int32, 8_int32, 9_int32, &
                                                    -4_int32, 13_int32, 15_int32, 15_int32, -6_int32, 18_int32]
    integer(c_intptr_t) :: output_address, addresses(10)
    integer(int64) :: output_bytes, lengths(10)
    integer(int32) :: child_status, release_status
    integer :: span_index

    status = 2_int32
    if (len(text) < 1 .or. len(text) > 262144) return
    if (len(directory) < 1 .or. len(directory) > 511) return
    if (index(directory, achar(0)) /= 0) return
    if (directory(len(directory):len(directory)) == ' ') return
    if (composition%laernitrate .or. composition%laersoa) return
    if (size(longwave_bands) < 256 .or. size(shortwave_bands) < 224) return
    if (.not. is_contiguous(longwave_bands) .or. .not. is_contiguous(shortwave_bands)) return
    if (.not. fresh_configuration(output%config)) return
    if (radiation%naermacc /= 1 .or. radiation%nliqopt /= 4 .or. radiation%niceopt /= 3) return
    if (radiation%nlwscattering /= 1 .or. radiation%nswsolver /= 0 .or. radiation%nlwsolver /= 0) return
    if (radiation%nsolarspectrum /= 0 .or. radiation%ncloudoverlap /= 3 .or. radiation%nlwout /= 1) return
    if (physics%nalbedoscheme /= 1 .or. physics%nemissscheme /= 0) return
    if (aerosols%laerrad .or. aerosols%laerccn .or. aerosols%laervol .or. .not. aerosols%laerrrtm) return
    if (.not. allocated(radiation%yspectplanck%wavlen_bound)) return
    if (.not. allocated(radiation%yspectplanck%interval_map)) return
    if (size(radiation%yspectplanck%wavlen_bound) /= 2 .or. size(radiation%yspectplanck%interval_map) /= 3) return
    if (lbound(radiation%yspectplanck%wavlen_bound, 1) /= 1) return
    if (lbound(radiation%yspectplanck%interval_map, 1) /= 1) return
    output_address = transfer(c_loc(output), 0_c_intptr_t)
    output_bytes = storage_size(output, kind=int64)/8_int64
    addresses = [transfer(c_loc(radiation), 0_c_intptr_t), transfer(c_loc(physics), 0_c_intptr_t), &
                 transfer(c_loc(aerosols), 0_c_intptr_t), transfer(c_loc(longwave_bands(1)), 0_c_intptr_t), &
                 transfer(c_loc(shortwave_bands(1)), 0_c_intptr_t), transfer(c_loc(text), 0_c_intptr_t), &
                 transfer(c_loc(directory), 0_c_intptr_t), transfer(c_loc(composition), 0_c_intptr_t), &
                 transfer(c_loc(radiation%yspectplanck%wavlen_bound(1)), 0_c_intptr_t), &
                 transfer(c_loc(radiation%yspectplanck%interval_map(1)), 0_c_intptr_t)]
    lengths = [storage_size(radiation, kind=int64)/8_int64, storage_size(physics, kind=int64)/8_int64, &
               storage_size(aerosols, kind=int64)/8_int64, int(size(longwave_bands), int64)*4_int64, &
               int(size(shortwave_bands), int64)*4_int64, int(len(text), int64), int(len(directory), int64), &
               storage_size(composition, kind=int64)/8_int64, 16_int64, 12_int64]
    if (iand(output_address, 7_c_intptr_t) /= 0_c_intptr_t) return
    do span_index = 1, 3
      if (iand(addresses(span_index), 7_c_intptr_t) /= 0_c_intptr_t) return
    end do
    if (iand(addresses(9), 7_c_intptr_t) /= 0_c_intptr_t) return
    if (iand(addresses(10), 3_c_intptr_t) /= 0_c_intptr_t) return
    do span_index = 1, 10
      if (.not. disjoint(output_address, output_bytes, addresses(span_index), lengths(span_index))) return
    end do
    if (.not. disjoint(addresses(4), lengths(4), addresses(5), lengths(5))) return
    if (.not. supported_floating_mode()) return
    child_status = require_optional_empty_radiation_group(text, 'RADIATION')
    if (child_status /= 0_int32) return

    ! All owners are absent, so this native assignment copies no payload.
    staged = output%config
    call initialize_ecrad_configuration_defaults(staged)
    staged%iverbosesetup = 1_int32
    staged%iverbose = 1_int32
    staged%directory_name = directory
    staged%do_lw_derivatives = radiation%lapproxlwupdate
    staged%do_canopy_fluxes_sw = radiation%lapproxswupdate
    staged%do_surface_sw_spectral_flux = .true.
    staged%do_setup_ifsrrtm = .false.
    staged%i_liq_model = 2_int32
    staged%i_ice_model = 2_int32
    staged%do_fu_lw_ice_optics_bug = radiation%lfu_lw_ice_optics_bug
    staged%do_sw_delta_scaling_with_gases = .false.
    staged%use_aerosols = .true.
    staged%n_aerosol_types = 12_int32
    staged%i_aerosol_type_map = 0_int32
    staged%i_aerosol_type_map(1:12) = aerosol_map
    staged%aerosol_optics_override_file_name = 'aerosol_ifs_rrtm_48R1_v2.nc'
    staged%do_3d_effects = .false.
    staged%i_solver_lw = 2_int32
    staged%i_solver_sw = 2_int32
    staged%min_cloud_effective_size = transfer(int(z'407F400000000000', int64), 0.0_real64)
    staged%do_lw_cloud_scattering = .true.
    staged%do_lw_aerosol_scattering = .false.
    staged%i_overlap_scheme = 1_int32
    shortwave_bounds(1) = transfer(int(z'3E90C6F7A0B5ED8D', int64), 0.0_real64)
    shortwave_bounds(2) = transfer(int(z'3E9D87247702C0D0', int64), 0.0_real64)
    shortwave_bounds(3) = transfer(int(z'3EA7270E0BDC572E', int64), 0.0_real64)
    shortwave_bounds(4) = transfer(int(z'3EB3F702D649225E', int64), 0.0_real64)
    shortwave_bounds(5) = transfer(int(z'3EC3F702D649225E', int64), 0.0_real64)
    call staged%define_sw_albedo_intervals(6, shortwave_bounds, six_indices, .true.)
    call staged%define_lw_emiss_intervals(3, radiation%yspectplanck%wavlen_bound, &
                                          radiation%yspectplanck%interval_map, .true.)
    call staged%consolidate()
    child_status = setup_ecrad_gas_band_maps(staged, longwave_bands, shortwave_bands)
    if (child_status /= 0_int32) then
      call release_configuration_owners(staged)
      status = child_status
      return
    end if
    staged%n_g_lw_if_scattering = 140_int32
    staged%n_bands_lw_if_scattering = 16_int32
    call staged%consolidate_intervals(.true., staged%do_nearest_spectral_sw_albedo, &
                                      staged%sw_albedo_wavelength_bound, staged%i_sw_albedo_index, staged%wavenumber1_sw, &
                                      staged%wavenumber2_sw, staged%i_albedo_from_band_sw, staged%sw_albedo_weights)
    call staged%consolidate_intervals(.false., staged%do_nearest_spectral_lw_emiss, &
                                      staged%lw_emiss_wavelength_bound, staged%i_lw_emiss_index, staged%wavenumber1_lw, &
                                      staged%wavenumber2_lw, staged%i_emiss_from_band_lw, staged%lw_emiss_weights)
    call setup_cloud_optics(staged)
    call setup_aerosol_optics(staged)
    call staged%pdf_sampler%setup(staged%cloud_pdf_file_name, staged%iverbosesetup)
    call staged%get_sw_weights(transfer(int(z'3E8AD7F29ABCAF48', int64), 0.0_real64), &
                              transfer(int(z'3E9DA0E988DEFB11', int64), 0.0_real64), nweight_uv, iband_uv, weight_uv, 'ultraviolet')
    call staged%get_sw_weights(transfer(int(z'3E9AD7F29ABCAF48', int64), 0.0_real64), &
                               transfer(int(z'3EA77CF44765195F', int64), 0.0_real64), nweight_par, iband_par, weight_par, &
                               'photosynthetically active radiation, PAR')
    trop_extinction = dry_aerosol_sw_mass_extinction(staged, 8, 10)
    strat_extinction = dry_aerosol_sw_mass_extinction(staged, 12, 10)

    ! Detach owners before scalar assignment, then adopt them without copying.
    nullify (owner_carrier%i_spec_from_reordered_g_lw, owner_carrier%i_spec_from_reordered_g_sw)
    call move_configuration_owners(staged, owner_carrier)
    output%config = staged
    call move_configuration_owners(owner_carrier, output%config)
    output%nweight_uv = nweight_uv
    output%iband_uv(1:nweight_uv) = iband_uv(1:nweight_uv)
    output%weight_uv(1:nweight_uv) = weight_uv(1:nweight_uv)
    output%nweight_par = nweight_par
    output%iband_par(1:nweight_par) = iband_par(1:nweight_par)
    output%weight_par(1:nweight_par) = weight_par(1:nweight_par)
    output%trop_bg_aer_mass_ext = trop_extinction
    output%strat_bg_aer_mass_ext = strat_extinction
    status = 0_int32
  end function

  !> Set the ten source gas-band owners in a public ecRad CONFIG.
  !! LONGWAVE_BANDS(:) and SHORTWAVE_BANDS(:) are read-only contiguous int32
  !! arrays, with at least256and224elements. Complete spans are disjoint
  !! from CONFIG and each other. Both solver codes are2; IFS setup and
  !! spectral-flux output are false. The ten destination owners are absent.
  !! Four wavenumber vectors use exact FP64 literals in cm**(-1); the six
  !! integer maps retain complete source extents and source integer order.
  !! Return0commits ten owners and the source dimensions. Return1cleans all
  !! private owners after allocation failure. Return2refuses without mutation.
  !! This child performs no floating arithmetic and accepts any rounding mode.
  integer(int32) function setup_ecrad_gas_band_maps(config, longwave_bands, shortwave_bands) result(status)
    type(config_type), intent(inout), target :: config
    integer(int32), intent(in), target :: longwave_bands(:), shortwave_bands(:)
    type(config_type) :: staged
    integer :: allocation_status, index
    integer(c_intptr_t) :: config_address, longwave_address, shortwave_address
    integer(int64) :: config_bytes, longwave_bytes, shortwave_bytes

    status = 2_int32
    if (config%i_solver_sw /= 2 .or. config%i_solver_lw /= 2) return
    if (config%do_setup_ifsrrtm .or. config%do_save_spectral_flux) return
    if (size(longwave_bands) < 256 .or. size(shortwave_bands) < 224) return
    if (.not. is_contiguous(longwave_bands) .or. .not. is_contiguous(shortwave_bands)) return
    if (allocated(config%wavenumber1_sw)) return
    if (allocated(config%wavenumber2_sw)) return
    if (allocated(config%wavenumber1_lw)) return
    if (allocated(config%wavenumber2_lw)) return
    if (allocated(config%i_band_from_g_sw)) return
    if (allocated(config%i_band_from_g_lw)) return
    if (allocated(config%i_band_from_reordered_g_sw)) return
    if (allocated(config%i_band_from_reordered_g_lw)) return
    if (allocated(config%i_g_from_reordered_g_sw)) return
    if (allocated(config%i_g_from_reordered_g_lw)) return
    config_address = transfer(c_loc(config), 0_c_intptr_t)
    longwave_address = transfer(c_loc(longwave_bands(1)), 0_c_intptr_t)
    shortwave_address = transfer(c_loc(shortwave_bands(1)), 0_c_intptr_t)
    config_bytes = storage_size(config, kind=int64)/8_int64
    longwave_bytes = int(size(longwave_bands), int64)*4_int64
    shortwave_bytes = int(size(shortwave_bands), int64)*4_int64
    if (iand(config_address, 7_c_intptr_t) /= 0_c_intptr_t) return
    if (iand(longwave_address, 3_c_intptr_t) /= 0_c_intptr_t) return
    if (iand(shortwave_address, 3_c_intptr_t) /= 0_c_intptr_t) return
    if (.not. disjoint(config_address, config_bytes, longwave_address, longwave_bytes)) return
    if (.not. disjoint(config_address, config_bytes, shortwave_address, shortwave_bytes)) return
    if (.not. disjoint(longwave_address, longwave_bytes, shortwave_address, shortwave_bytes)) return

    acquire: block
      allocate (staged%wavenumber1_sw(14), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      staged%wavenumber1_sw(1) = transfer(int(z'40A4500000000000', int64), 0.0_real64)
      staged%wavenumber1_sw(2) = transfer(int(z'40A9640000000000', int64), 0.0_real64)
      staged%wavenumber1_sw(3) = transfer(int(z'40AF400000000000', int64), 0.0_real64)
      staged%wavenumber1_sw(4) = transfer(int(z'40B22A0000000000', int64), 0.0_real64)
      staged%wavenumber1_sw(5) = transfer(int(z'40B41E0000000000', int64), 0.0_real64)
      staged%wavenumber1_sw(6) = transfer(int(z'40B8060000000000', int64), 0.0_real64)
      staged%wavenumber1_sw(7) = transfer(int(z'40BE140000000000', int64), 0.0_real64)
      staged%wavenumber1_sw(8) = transfer(int(z'40BF720000000000', int64), 0.0_real64)
      staged%wavenumber1_sw(9) = transfer(int(z'40C9190000000000', int64), 0.0_real64)
      staged%wavenumber1_sw(10) = transfer(int(z'40CF400000000000', int64), 0.0_real64)
      staged%wavenumber1_sw(11) = transfer(int(z'40D61E8000000000', int64), 0.0_real64)
      staged%wavenumber1_sw(12) = transfer(int(z'40DC520000000000', int64), 0.0_real64)
      staged%wavenumber1_sw(13) = transfer(int(z'40E28E0000000000', int64), 0.0_real64)
      staged%wavenumber1_sw(14) = transfer(int(z'4089A00000000000', int64), 0.0_real64)
      allocate (staged%wavenumber2_sw(14), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      staged%wavenumber2_sw(1) = transfer(int(z'40A9640000000000', int64), 0.0_real64)
      staged%wavenumber2_sw(2) = transfer(int(z'40AF400000000000', int64), 0.0_real64)
      staged%wavenumber2_sw(3) = transfer(int(z'40B22A0000000000', int64), 0.0_real64)
      staged%wavenumber2_sw(4) = transfer(int(z'40B41E0000000000', int64), 0.0_real64)
      staged%wavenumber2_sw(5) = transfer(int(z'40B8060000000000', int64), 0.0_real64)
      staged%wavenumber2_sw(6) = transfer(int(z'40BE140000000000', int64), 0.0_real64)
      staged%wavenumber2_sw(7) = transfer(int(z'40BF720000000000', int64), 0.0_real64)
      staged%wavenumber2_sw(8) = transfer(int(z'40C9190000000000', int64), 0.0_real64)
      staged%wavenumber2_sw(9) = transfer(int(z'40CF400000000000', int64), 0.0_real64)
      staged%wavenumber2_sw(10) = transfer(int(z'40D61E8000000000', int64), 0.0_real64)
      staged%wavenumber2_sw(11) = transfer(int(z'40DC520000000000', int64), 0.0_real64)
      staged%wavenumber2_sw(12) = transfer(int(z'40E28E0000000000', int64), 0.0_real64)
      staged%wavenumber2_sw(13) = transfer(int(z'40E86A0000000000', int64), 0.0_real64)
      staged%wavenumber2_sw(14) = transfer(int(z'40A4500000000000', int64), 0.0_real64)
      allocate (staged%wavenumber1_lw(16), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      staged%wavenumber1_lw(1) = transfer(int(z'4024000000000000', int64), 0.0_real64)
      staged%wavenumber1_lw(2) = transfer(int(z'4075E00000000000', int64), 0.0_real64)
      staged%wavenumber1_lw(3) = transfer(int(z'407F400000000000', int64), 0.0_real64)
      staged%wavenumber1_lw(4) = transfer(int(z'4083B00000000000', int64), 0.0_real64)
      staged%wavenumber1_lw(5) = transfer(int(z'4085E00000000000', int64), 0.0_real64)
      staged%wavenumber1_lw(6) = transfer(int(z'4089A00000000000', int64), 0.0_real64)
      staged%wavenumber1_lw(7) = transfer(int(z'408EA00000000000', int64), 0.0_real64)
      staged%wavenumber1_lw(8) = transfer(int(z'4090E00000000000', int64), 0.0_real64)
      staged%wavenumber1_lw(9) = transfer(int(z'4092700000000000', int64), 0.0_real64)
      staged%wavenumber1_lw(10) = transfer(int(z'4095B80000000000', int64), 0.0_real64)
      staged%wavenumber1_lw(11) = transfer(int(z'4097200000000000', int64), 0.0_real64)
      staged%wavenumber1_lw(12) = transfer(int(z'409C200000000000', int64), 0.0_real64)
      staged%wavenumber1_lw(13) = transfer(int(z'40A0400000000000', int64), 0.0_real64)
      staged%wavenumber1_lw(14) = transfer(int(z'40A1940000000000', int64), 0.0_real64)
      staged%wavenumber1_lw(15) = transfer(int(z'40A2980000000000', int64), 0.0_real64)
      staged%wavenumber1_lw(16) = transfer(int(z'40A4500000000000', int64), 0.0_real64)
      allocate (staged%wavenumber2_lw(16), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      staged%wavenumber2_lw(1) = transfer(int(z'4075E00000000000', int64), 0.0_real64)
      staged%wavenumber2_lw(2) = transfer(int(z'407F400000000000', int64), 0.0_real64)
      staged%wavenumber2_lw(3) = transfer(int(z'4083B00000000000', int64), 0.0_real64)
      staged%wavenumber2_lw(4) = transfer(int(z'4085E00000000000', int64), 0.0_real64)
      staged%wavenumber2_lw(5) = transfer(int(z'4089A00000000000', int64), 0.0_real64)
      staged%wavenumber2_lw(6) = transfer(int(z'408EA00000000000', int64), 0.0_real64)
      staged%wavenumber2_lw(7) = transfer(int(z'4090E00000000000', int64), 0.0_real64)
      staged%wavenumber2_lw(8) = transfer(int(z'4092700000000000', int64), 0.0_real64)
      staged%wavenumber2_lw(9) = transfer(int(z'4095B80000000000', int64), 0.0_real64)
      staged%wavenumber2_lw(10) = transfer(int(z'4097200000000000', int64), 0.0_real64)
      staged%wavenumber2_lw(11) = transfer(int(z'409C200000000000', int64), 0.0_real64)
      staged%wavenumber2_lw(12) = transfer(int(z'40A0400000000000', int64), 0.0_real64)
      staged%wavenumber2_lw(13) = transfer(int(z'40A1940000000000', int64), 0.0_real64)
      staged%wavenumber2_lw(14) = transfer(int(z'40A2980000000000', int64), 0.0_real64)
      staged%wavenumber2_lw(15) = transfer(int(z'40A4500000000000', int64), 0.0_real64)
      staged%wavenumber2_lw(16) = transfer(int(z'40A9640000000000', int64), 0.0_real64)
      allocate (staged%i_band_from_g_sw(224), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      do index = 1, 224
        staged%i_band_from_g_sw(index) = band_difference_plus_one(shortwave_bands(index), shortwave_bands(1))
      end do
      allocate (staged%i_band_from_g_lw(256), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      staged%i_band_from_g_lw = longwave_bands(1:256)
      allocate (staged%i_band_from_reordered_g_sw(112), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      do index = 1, 112
        staged%i_band_from_reordered_g_sw(index) = band_difference_plus_one(shortwave_bands(index), shortwave_bands(1))
      end do
      allocate (staged%i_band_from_reordered_g_lw(140), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      staged%i_band_from_reordered_g_lw = longwave_bands(1:140)
      allocate (staged%i_g_from_reordered_g_sw(112), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      do index = 1, 112
        staged%i_g_from_reordered_g_sw(index) = int(index, int32)
      end do
      allocate (staged%i_g_from_reordered_g_lw(140), stat=allocation_status)
      if (allocation_status /= 0) exit acquire
      do index = 1, 140
        staged%i_g_from_reordered_g_lw(index) = int(index, int32)
      end do
      call move_alloc(staged%wavenumber1_sw, config%wavenumber1_sw)
      call move_alloc(staged%wavenumber2_sw, config%wavenumber2_sw)
      call move_alloc(staged%wavenumber1_lw, config%wavenumber1_lw)
      call move_alloc(staged%wavenumber2_lw, config%wavenumber2_lw)
      call move_alloc(staged%i_band_from_g_sw, config%i_band_from_g_sw)
      call move_alloc(staged%i_band_from_g_lw, config%i_band_from_g_lw)
      call move_alloc(staged%i_band_from_reordered_g_sw, config%i_band_from_reordered_g_sw)
      call move_alloc(staged%i_band_from_reordered_g_lw, config%i_band_from_reordered_g_lw)
      call move_alloc(staged%i_g_from_reordered_g_sw, config%i_g_from_reordered_g_sw)
      call move_alloc(staged%i_g_from_reordered_g_lw, config%i_g_from_reordered_g_lw)
      config%n_g_sw = 112_int32
      config%n_g_lw = 140_int32
      config%n_bands_sw = 14_int32
      config%n_bands_lw = 16_int32
      config%n_spec_sw = 0_int32
      config%n_spec_lw = 0_int32
      nullify (config%i_spec_from_reordered_g_lw, config%i_spec_from_reordered_g_sw)
      status = 0_int32
      return
    end block acquire
    if (allocated(staged%wavenumber1_sw)) deallocate (staged%wavenumber1_sw)
    if (allocated(staged%wavenumber2_sw)) deallocate (staged%wavenumber2_sw)
    if (allocated(staged%wavenumber1_lw)) deallocate (staged%wavenumber1_lw)
    if (allocated(staged%wavenumber2_lw)) deallocate (staged%wavenumber2_lw)
    if (allocated(staged%i_band_from_g_sw)) deallocate (staged%i_band_from_g_sw)
    if (allocated(staged%i_band_from_g_lw)) deallocate (staged%i_band_from_g_lw)
    if (allocated(staged%i_band_from_reordered_g_sw)) deallocate (staged%i_band_from_reordered_g_sw)
    if (allocated(staged%i_band_from_reordered_g_lw)) deallocate (staged%i_band_from_reordered_g_lw)
    if (allocated(staged%i_g_from_reordered_g_sw)) deallocate (staged%i_g_from_reordered_g_sw)
    if (allocated(staged%i_g_from_reordered_g_lw)) deallocate (staged%i_g_from_reordered_g_lw)
    status = 1_int32
  end function

  !> Release only the ten valid gas-map owners, retaining all other fields.
  !! CONFIG is caller owned. Repeated release succeeds without allocation.
  !! Native descriptor changes belong to the Fortran compiler.
  integer(int32) function release_ecrad_gas_band_maps(config) result(status)
    type(config_type), intent(inout) :: config
    if (allocated(config%wavenumber1_sw)) deallocate (config%wavenumber1_sw)
    if (allocated(config%wavenumber2_sw)) deallocate (config%wavenumber2_sw)
    if (allocated(config%wavenumber1_lw)) deallocate (config%wavenumber1_lw)
    if (allocated(config%wavenumber2_lw)) deallocate (config%wavenumber2_lw)
    if (allocated(config%i_band_from_g_sw)) deallocate (config%i_band_from_g_sw)
    if (allocated(config%i_band_from_g_lw)) deallocate (config%i_band_from_g_lw)
    if (allocated(config%i_band_from_reordered_g_sw)) deallocate (config%i_band_from_reordered_g_sw)
    if (allocated(config%i_band_from_reordered_g_lw)) deallocate (config%i_band_from_reordered_g_lw)
    if (allocated(config%i_g_from_reordered_g_sw)) deallocate (config%i_g_from_reordered_g_sw)
    if (allocated(config%i_g_from_reordered_g_lw)) deallocate (config%i_g_from_reordered_g_lw)
    status = 0_int32
  end function

  !> Release this selected result's44allocatable components in source order.
  !! OUTPUT remains caller owned; scalar fields, query values and fixed
  !! arrays remain unchanged. The two nonowning pointer aliases must be null.
  !! Repeated release succeeds. Return2refuses unsupported pointer ownership.
  integer(int32) function release_selected_ecrad_configuration(output) result(status)
    type(selected_ecrad_configuration_record), intent(inout) :: output
    status = 2_int32
    if (associated(output%config%i_spec_from_reordered_g_lw)) return
    if (associated(output%config%i_spec_from_reordered_g_sw)) return
    call release_configuration_owners(output%config)
    status = 0_int32
  end function

  !> Accept an absent group or the first exact named group with an empty body.
  !! TEXT is read only, with1:262144characters; GROUP has1:16characters.
  !! Its first uppercase-exact marker must be a line's first nonblank token
  !! within columns1:10. Only whitespace and comments can precede its slash.
  !! Missing closure, a truncated eligible marker or a nonempty body returns2.
  !! Absence or a complete empty first group returns0, with no mutation.
  integer(int32) function require_optional_empty_radiation_group(text, group) result(status)
    character(len=*), intent(in) :: text, group
    integer :: cursor, ending, column, index, after_name
    character(len=1) :: character
    status = 2_int32
    ending = len(text)
    if (ending < 1 .or. ending > 262144 .or. len(group) < 1 .or. len(group) > 16) return
    cursor = 1
    column = 0
    do
      if (cursor > ending) then
        status = 0_int32
        return
      end if
      character = text(cursor:cursor)
      cursor = cursor + 1
      if (character == achar(10)) then
        column = 0
        cycle
      end if
      column = column + 1
      if (character == ' ' .or. character == achar(9) .or. character == achar(13)) cycle
      if (character == '&' .and. column <= 10) then
        after_name = cursor + len(group)
        if (after_name > ending) return
        if (text(cursor:after_name - 1) == group) then
          cursor = after_name
          character = text(cursor:cursor)
          if (whitespace(character) .or. character == '/') then
            do
              if (cursor > ending) return
              character = text(cursor:cursor)
              cursor = cursor + 1
              if (character == '/') then
                status = 0_int32
                return
              end if
              if (whitespace(character)) cycle
              if (character /= '!') return
              do
                if (cursor > ending) return
                character = text(cursor:cursor)
                cursor = cursor + 1
                if (character == achar(10)) exit
              end do
            end do
          end if
        end if
      end if
      do
        if (cursor > ending) then
          status = 0_int32
          return
        end if
        character = text(cursor:cursor)
        cursor = cursor + 1
        if (character == achar(10)) exit
      end do
      column = 0
    end do
  end function

  !> Test the complete native fresh-owner condition without changing CONFIG.
  logical function fresh_configuration(config) result(fresh)
    type(config_type), intent(in) :: config
    fresh = .false.
    if (allocated(config%wavenumber1_sw)) return
    if (allocated(config%wavenumber2_sw)) return
    if (allocated(config%wavenumber1_lw)) return
    if (allocated(config%wavenumber2_lw)) return
    if (allocated(config%i_albedo_from_band_sw)) return
    if (allocated(config%i_emiss_from_band_lw)) return
    if (allocated(config%sw_albedo_weights)) return
    if (allocated(config%lw_emiss_weights)) return
    if (allocated(config%i_band_from_g_lw)) return
    if (allocated(config%i_band_from_g_sw)) return
    if (allocated(config%i_g_from_reordered_g_lw)) return
    if (allocated(config%i_g_from_reordered_g_sw)) return
    if (allocated(config%i_band_from_reordered_g_lw)) return
    if (allocated(config%i_band_from_reordered_g_sw)) return
    if (allocated(config%cloud_optics%liq_coeff_lw)) return
    if (allocated(config%cloud_optics%liq_coeff_sw)) return
    if (allocated(config%cloud_optics%ice_coeff_lw)) return
    if (allocated(config%cloud_optics%ice_coeff_sw)) return
    if (allocated(config%cloud_optics%liq_coeff_gen)) return
    if (allocated(config%cloud_optics%ice_coeff_gen)) return
    if (allocated(config%aerosol_optics%iclass)) return
    if (allocated(config%aerosol_optics%itype)) return
    if (allocated(config%aerosol_optics%mass_ext_sw_phobic)) return
    if (allocated(config%aerosol_optics%ssa_sw_phobic)) return
    if (allocated(config%aerosol_optics%g_sw_phobic)) return
    if (allocated(config%aerosol_optics%mass_ext_lw_phobic)) return
    if (allocated(config%aerosol_optics%ssa_lw_phobic)) return
    if (allocated(config%aerosol_optics%g_lw_phobic)) return
    if (allocated(config%aerosol_optics%mass_ext_sw_philic)) return
    if (allocated(config%aerosol_optics%ssa_sw_philic)) return
    if (allocated(config%aerosol_optics%g_sw_philic)) return
    if (allocated(config%aerosol_optics%mass_ext_lw_philic)) return
    if (allocated(config%aerosol_optics%ssa_lw_philic)) return
    if (allocated(config%aerosol_optics%g_lw_philic)) return
    if (allocated(config%aerosol_optics%mass_ext_mono_phobic)) return
    if (allocated(config%aerosol_optics%ssa_mono_phobic)) return
    if (allocated(config%aerosol_optics%g_mono_phobic)) return
    if (allocated(config%aerosol_optics%lidar_ratio_mono_phobic)) return
    if (allocated(config%aerosol_optics%mass_ext_mono_philic)) return
    if (allocated(config%aerosol_optics%ssa_mono_philic)) return
    if (allocated(config%aerosol_optics%g_mono_philic)) return
    if (allocated(config%aerosol_optics%lidar_ratio_mono_philic)) return
    if (allocated(config%aerosol_optics%rh_lower)) return
    if (allocated(config%pdf_sampler%val)) return
    if (associated(config%i_spec_from_reordered_g_lw)) return
    if (associated(config%i_spec_from_reordered_g_sw)) return
    fresh = .true.
  end function

  !> Move each native allocatable component once, in source declaration order.
  !! SOURCE and DESTINATION are disjoint. Destination owners must be absent.
  !! Scalar values and the two null pointer aliases are not changed.
  subroutine move_configuration_owners(source, destination)
    type(config_type), intent(inout) :: source, destination
    call move_alloc(source%wavenumber1_sw, destination%wavenumber1_sw)
    call move_alloc(source%wavenumber2_sw, destination%wavenumber2_sw)
    call move_alloc(source%wavenumber1_lw, destination%wavenumber1_lw)
    call move_alloc(source%wavenumber2_lw, destination%wavenumber2_lw)
    call move_alloc(source%i_albedo_from_band_sw, destination%i_albedo_from_band_sw)
    call move_alloc(source%i_emiss_from_band_lw, destination%i_emiss_from_band_lw)
    call move_alloc(source%sw_albedo_weights, destination%sw_albedo_weights)
    call move_alloc(source%lw_emiss_weights, destination%lw_emiss_weights)
    call move_alloc(source%i_band_from_g_lw, destination%i_band_from_g_lw)
    call move_alloc(source%i_band_from_g_sw, destination%i_band_from_g_sw)
    call move_alloc(source%i_g_from_reordered_g_lw, destination%i_g_from_reordered_g_lw)
    call move_alloc(source%i_g_from_reordered_g_sw, destination%i_g_from_reordered_g_sw)
    call move_alloc(source%i_band_from_reordered_g_lw, destination%i_band_from_reordered_g_lw)
    call move_alloc(source%i_band_from_reordered_g_sw, destination%i_band_from_reordered_g_sw)
    call move_alloc(source%cloud_optics%liq_coeff_lw, destination%cloud_optics%liq_coeff_lw)
    call move_alloc(source%cloud_optics%liq_coeff_sw, destination%cloud_optics%liq_coeff_sw)
    call move_alloc(source%cloud_optics%ice_coeff_lw, destination%cloud_optics%ice_coeff_lw)
    call move_alloc(source%cloud_optics%ice_coeff_sw, destination%cloud_optics%ice_coeff_sw)
    call move_alloc(source%cloud_optics%liq_coeff_gen, destination%cloud_optics%liq_coeff_gen)
    call move_alloc(source%cloud_optics%ice_coeff_gen, destination%cloud_optics%ice_coeff_gen)
    call move_alloc(source%aerosol_optics%iclass, destination%aerosol_optics%iclass)
    call move_alloc(source%aerosol_optics%itype, destination%aerosol_optics%itype)
    call move_alloc(source%aerosol_optics%mass_ext_sw_phobic, destination%aerosol_optics%mass_ext_sw_phobic)
    call move_alloc(source%aerosol_optics%ssa_sw_phobic, destination%aerosol_optics%ssa_sw_phobic)
    call move_alloc(source%aerosol_optics%g_sw_phobic, destination%aerosol_optics%g_sw_phobic)
    call move_alloc(source%aerosol_optics%mass_ext_lw_phobic, destination%aerosol_optics%mass_ext_lw_phobic)
    call move_alloc(source%aerosol_optics%ssa_lw_phobic, destination%aerosol_optics%ssa_lw_phobic)
    call move_alloc(source%aerosol_optics%g_lw_phobic, destination%aerosol_optics%g_lw_phobic)
    call move_alloc(source%aerosol_optics%mass_ext_sw_philic, destination%aerosol_optics%mass_ext_sw_philic)
    call move_alloc(source%aerosol_optics%ssa_sw_philic, destination%aerosol_optics%ssa_sw_philic)
    call move_alloc(source%aerosol_optics%g_sw_philic, destination%aerosol_optics%g_sw_philic)
    call move_alloc(source%aerosol_optics%mass_ext_lw_philic, destination%aerosol_optics%mass_ext_lw_philic)
    call move_alloc(source%aerosol_optics%ssa_lw_philic, destination%aerosol_optics%ssa_lw_philic)
    call move_alloc(source%aerosol_optics%g_lw_philic, destination%aerosol_optics%g_lw_philic)
    call move_alloc(source%aerosol_optics%mass_ext_mono_phobic, destination%aerosol_optics%mass_ext_mono_phobic)
    call move_alloc(source%aerosol_optics%ssa_mono_phobic, destination%aerosol_optics%ssa_mono_phobic)
    call move_alloc(source%aerosol_optics%g_mono_phobic, destination%aerosol_optics%g_mono_phobic)
    call move_alloc(source%aerosol_optics%lidar_ratio_mono_phobic, destination%aerosol_optics%lidar_ratio_mono_phobic)
    call move_alloc(source%aerosol_optics%mass_ext_mono_philic, destination%aerosol_optics%mass_ext_mono_philic)
    call move_alloc(source%aerosol_optics%ssa_mono_philic, destination%aerosol_optics%ssa_mono_philic)
    call move_alloc(source%aerosol_optics%g_mono_philic, destination%aerosol_optics%g_mono_philic)
    call move_alloc(source%aerosol_optics%lidar_ratio_mono_philic, destination%aerosol_optics%lidar_ratio_mono_philic)
    call move_alloc(source%aerosol_optics%rh_lower, destination%aerosol_optics%rh_lower)
    call move_alloc(source%pdf_sampler%val, destination%pdf_sampler%val)
  end subroutine

  !> Free every present owned component in the source release order.
  subroutine release_configuration_owners(config)
    type(config_type), intent(inout) :: config
    if (allocated(config%wavenumber1_sw)) deallocate (config%wavenumber1_sw)
    if (allocated(config%wavenumber2_sw)) deallocate (config%wavenumber2_sw)
    if (allocated(config%wavenumber1_lw)) deallocate (config%wavenumber1_lw)
    if (allocated(config%wavenumber2_lw)) deallocate (config%wavenumber2_lw)
    if (allocated(config%i_albedo_from_band_sw)) deallocate (config%i_albedo_from_band_sw)
    if (allocated(config%i_emiss_from_band_lw)) deallocate (config%i_emiss_from_band_lw)
    if (allocated(config%sw_albedo_weights)) deallocate (config%sw_albedo_weights)
    if (allocated(config%lw_emiss_weights)) deallocate (config%lw_emiss_weights)
    if (allocated(config%i_band_from_g_lw)) deallocate (config%i_band_from_g_lw)
    if (allocated(config%i_band_from_g_sw)) deallocate (config%i_band_from_g_sw)
    if (allocated(config%i_g_from_reordered_g_lw)) deallocate (config%i_g_from_reordered_g_lw)
    if (allocated(config%i_g_from_reordered_g_sw)) deallocate (config%i_g_from_reordered_g_sw)
    if (allocated(config%i_band_from_reordered_g_lw)) deallocate (config%i_band_from_reordered_g_lw)
    if (allocated(config%i_band_from_reordered_g_sw)) deallocate (config%i_band_from_reordered_g_sw)
    if (allocated(config%cloud_optics%liq_coeff_lw)) deallocate (config%cloud_optics%liq_coeff_lw)
    if (allocated(config%cloud_optics%liq_coeff_sw)) deallocate (config%cloud_optics%liq_coeff_sw)
    if (allocated(config%cloud_optics%ice_coeff_lw)) deallocate (config%cloud_optics%ice_coeff_lw)
    if (allocated(config%cloud_optics%ice_coeff_sw)) deallocate (config%cloud_optics%ice_coeff_sw)
    if (allocated(config%cloud_optics%liq_coeff_gen)) deallocate (config%cloud_optics%liq_coeff_gen)
    if (allocated(config%cloud_optics%ice_coeff_gen)) deallocate (config%cloud_optics%ice_coeff_gen)
    if (allocated(config%aerosol_optics%iclass)) deallocate (config%aerosol_optics%iclass)
    if (allocated(config%aerosol_optics%itype)) deallocate (config%aerosol_optics%itype)
    if (allocated(config%aerosol_optics%mass_ext_sw_phobic)) deallocate (config%aerosol_optics%mass_ext_sw_phobic)
    if (allocated(config%aerosol_optics%ssa_sw_phobic)) deallocate (config%aerosol_optics%ssa_sw_phobic)
    if (allocated(config%aerosol_optics%g_sw_phobic)) deallocate (config%aerosol_optics%g_sw_phobic)
    if (allocated(config%aerosol_optics%mass_ext_lw_phobic)) deallocate (config%aerosol_optics%mass_ext_lw_phobic)
    if (allocated(config%aerosol_optics%ssa_lw_phobic)) deallocate (config%aerosol_optics%ssa_lw_phobic)
    if (allocated(config%aerosol_optics%g_lw_phobic)) deallocate (config%aerosol_optics%g_lw_phobic)
    if (allocated(config%aerosol_optics%mass_ext_sw_philic)) deallocate (config%aerosol_optics%mass_ext_sw_philic)
    if (allocated(config%aerosol_optics%ssa_sw_philic)) deallocate (config%aerosol_optics%ssa_sw_philic)
    if (allocated(config%aerosol_optics%g_sw_philic)) deallocate (config%aerosol_optics%g_sw_philic)
    if (allocated(config%aerosol_optics%mass_ext_lw_philic)) deallocate (config%aerosol_optics%mass_ext_lw_philic)
    if (allocated(config%aerosol_optics%ssa_lw_philic)) deallocate (config%aerosol_optics%ssa_lw_philic)
    if (allocated(config%aerosol_optics%g_lw_philic)) deallocate (config%aerosol_optics%g_lw_philic)
    if (allocated(config%aerosol_optics%mass_ext_mono_phobic)) deallocate (config%aerosol_optics%mass_ext_mono_phobic)
    if (allocated(config%aerosol_optics%ssa_mono_phobic)) deallocate (config%aerosol_optics%ssa_mono_phobic)
    if (allocated(config%aerosol_optics%g_mono_phobic)) deallocate (config%aerosol_optics%g_mono_phobic)
    if (allocated(config%aerosol_optics%lidar_ratio_mono_phobic)) deallocate (config%aerosol_optics%lidar_ratio_mono_phobic)
    if (allocated(config%aerosol_optics%mass_ext_mono_philic)) deallocate (config%aerosol_optics%mass_ext_mono_philic)
    if (allocated(config%aerosol_optics%ssa_mono_philic)) deallocate (config%aerosol_optics%ssa_mono_philic)
    if (allocated(config%aerosol_optics%g_mono_philic)) deallocate (config%aerosol_optics%g_mono_philic)
    if (allocated(config%aerosol_optics%lidar_ratio_mono_philic)) deallocate (config%aerosol_optics%lidar_ratio_mono_philic)
    if (allocated(config%aerosol_optics%rh_lower)) deallocate (config%aerosol_optics%rh_lower)
    if (allocated(config%pdf_sampler%val)) deallocate (config%pdf_sampler%val)
  end subroutine

  !> Keep the generated32-bit subtract-then-add band rule on its full domain.
  !! Wider exact integer work retains the source wrap without signed overflow.
  integer(int32) function band_difference_plus_one(value, first) result(band)
    integer(int32), intent(in) :: value, first
    integer(int64) :: temporary
    temporary = int(value, int64) - int(first, int64)
    temporary = temporary + 1_int64
    if (temporary > int(huge(0_int32), int64)) temporary = temporary - 4294967296_int64
    if (temporary < -2147483648_int64) temporary = temporary + 4294967296_int64
    band = int(temporary, int32)
  end function

  !> Compare valid native spans without constructing a wrapping end address.
  logical function disjoint(first, first_bytes, second, second_bytes) result(separate)
    integer(c_intptr_t), intent(in) :: first, second
    integer(int64), intent(in) :: first_bytes, second_bytes
    if (first <= second) then
      separate = second - first >= first_bytes
    else
      separate = first - second >= second_bytes
    end if
  end function

  !> Recognize the exact source whitespace bytes.
  logical function whitespace(character) result(blank)
    character(len=1), intent(in) :: character
    blank = character == ' ' .or. character == achar(9) .or. character == achar(10) .or. character == achar(13)
  end function

  !> Admit nearest rounding and gradual underflow while retaining entry flags.
  logical function supported_floating_mode() result(supported)
    type(ieee_round_type) :: rounding
    real(real64), volatile :: smallest_normal, half, subnormal
    logical :: incoming_underflow, incoming_inexact
    supported = .false.
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) return
    call ieee_get_flag(ieee_underflow, incoming_underflow)
    call ieee_get_flag(ieee_inexact, incoming_inexact)
    smallest_normal = tiny(0.0_real64)
    half = 0.5_real64
    subnormal = smallest_normal*half
    supported = transfer(subnormal, 0_int64) == int(z'0008000000000000', int64)
    call ieee_set_flag(ieee_underflow, incoming_underflow)
    call ieee_set_flag(ieee_inexact, incoming_inexact)
  end function
end module selected_ecrad_configuration_port
