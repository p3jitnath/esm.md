!> Set the selected explicit declaration values of public ecRad config_type.
!! This source owns the 90 named default assignments in
!! ecrad_configuration_defaults.S. It imports the permitted ecRad type only;
!! it calls no OpenIFS constructor or numerical setup function.
module ecrad_configuration_defaults_mod
  use iso_fortran_env, only: int32, int64, real64
  use radiation_config, only: config_type
  implicit none
  private
  public :: initialize_ecrad_configuration_defaults

contains

  !> Apply the selected defaults to an admitted caller-owned public ecRad record.
  !! CONFIG has type radiation_config::config_type and intent INOUT. Its
  !! forty-six allocation and pointer bases must meet the enclosing parent's
  !! fresh-owner contract. This leaf changes only the 90 selected members;
  !! other members, descriptor metadata, pointer associations and padding
  !! remain unchanged. Native character assignments retain source padding.
  !! Wavelengths are in metres and optical depths/fractions are dimensionless.
  !! The fixed spectral bound/index arrays use their native declared size.
  subroutine initialize_ecrad_configuration_defaults(config)
    type(config_type), intent(inout) :: config
    config%use_spectral_solar_scaling = .false.
    config%directory_name = '.'
    config%cloud_fraction_threshold = transfer(int(z'3eb0c6f7a0b5ed8d', int64), 0.0_real64)
    config%cloud_mixing_ratio_threshold = transfer(int(z'3e112e0be826d695', int64), 0.0_real64)
    config%i_overlap_scheme = int(z'00000001', int32)
    config%use_beta_overlap = .false.
    config%i_cloud_pdf_shape = int(z'00000001', int32)
    config%cloud_inhom_decorr_scaling = transfer(int(z'3fe0000000000000', int64), 0.0_real64)
    config%clear_to_thick_fraction = transfer(int(z'0000000000000000', int64), 0.0_real64)
    config%overhead_sun_factor = transfer(int(z'0000000000000000', int64), 0.0_real64)
    config%min_gas_od_lw = transfer(int(z'3cd203af9ee75616', int64), 0.0_real64)
    config%min_gas_od_sw = transfer(int(z'0000000000000000', int64), 0.0_real64)
    config%max_gas_od_3d = transfer(int(z'4020000000000000', int64), 0.0_real64)
    config%max_cloud_od = transfer(int(z'4030000000000000', int64), 0.0_real64)
    config%do_lw_cloud_scattering = .true.
    config%do_lw_aerosol_scattering = .true.
    config%nregions = int(z'00000003', int32)
    config%i_solver_sw = int(z'00000002', int32)
    config%i_solver_lw = int(z'00000002', int32)
    config%do_sw_delta_scaling_with_gases = .false.
    config%i_gas_model = int(z'00000001', int32)
    config%mono_lw_wavelength = transfer(int(z'bff0000000000000', int64), 0.0_real64)
    config%mono_lw_total_od = transfer(int(z'0000000000000000', int64), 0.0_real64)
    config%mono_sw_total_od = transfer(int(z'0000000000000000', int64), 0.0_real64)
    config%mono_sw_single_scattering_albedo = transfer(int(z'3feffffde7210be9', int64), 0.0_real64)
    config%mono_sw_asymmetry_factor = transfer(int(z'3feb851eb851eb85', int64), 0.0_real64)
    config%mono_lw_single_scattering_albedo = transfer(int(z'3fe1374bc6a7ef9e', int64), 0.0_real64)
    config%mono_lw_asymmetry_factor = transfer(int(z'3fed99999999999a', int64), 0.0_real64)
    config%i_liq_model = int(z'00000002', int32)
    config%i_ice_model = int(z'00000003', int32)
    config%use_psrad_cloud_optics = .false.
    config%do_nearest_spectral_sw_albedo = .true.
    config%do_nearest_spectral_lw_emiss = .true.
    config%sw_albedo_wavelength_bound = transfer(int(z'bff0000000000000', int64), 0.0_real64)
    config%lw_emiss_wavelength_bound = transfer(int(z'bff0000000000000', int64), 0.0_real64)
    config%i_sw_albedo_index = int(z'00000000', int32)
    config%i_lw_emiss_index = int(z'00000000', int32)
    config%do_lw = .true.
    config%do_sw = .true.
    config%do_clear = .true.
    config%do_sw_direct = .true.
    config%do_3d_effects = .true.
    config%i_3d_sw_entrapment = int(z'00000002', int32)
    config%do_3d_lw_multilayer_effects = .false.
    config%do_lw_side_emissivity = .true.
    config%max_3d_transfer_rate = transfer(int(z'4024000000000000', int64), 0.0_real64)
    config%min_cloud_effective_size = transfer(int(z'4059000000000000', int64), 0.0_real64)
    config%overhang_factor = transfer(int(z'0000000000000000', int64), 0.0_real64)
    config%use_expm_everywhere = .false.
    config%use_aerosols = .false.
    config%n_aerosol_types = int(z'00000000', int32)
    config%do_save_radiative_properties = .false.
    config%do_save_spectral_flux = .false.
    config%do_surface_sw_spectral_flux = .true.
    config%do_lw_derivatives = .false.
    config%do_save_gpoint_flux = .false.
    config%do_setup_ifsrrtm = .true.
    config%do_fu_lw_ice_optics_bug = .false.
    config%iverbosesetup = int(z'00000002', int32)
    config%iverbose = int(z'00000001', int32)
    config%do_canopy_fluxes_sw = .false.
    config%do_canopy_fluxes_lw = .false.
    config%use_canopy_full_spectrum_sw = .false.
    config%use_canopy_full_spectrum_lw = .false.
    config%do_canopy_gases_sw = .false.
    config%do_canopy_gases_lw = .false.
    config%ice_optics_override_file_name = ''
    config%liq_optics_override_file_name = ''
    config%aerosol_optics_override_file_name = ''
    config%cloud_pdf_override_file_name = ''
    config%is_consolidated = .false.
    config%n_canopy_bands_sw = int(z'00000001', int32)
    config%n_canopy_bands_lw = int(z'00000001', int32)
    config%aerosol_optics%description_phobic_str = ' '
    config%aerosol_optics%description_philic_str = ' '
    config%aerosol_optics%n_bands_lw = int(z'00000000', int32)
    config%aerosol_optics%n_bands_sw = int(z'00000000', int32)
    config%aerosol_optics%n_mono_wl = int(z'00000000', int32)
    config%aerosol_optics%use_hydrophilic = .true.
    config%aerosol_optics%use_monochromatic = .false.
    config%n_g_sw = int(z'00000000', int32)
    config%n_g_lw = int(z'00000000', int32)
    config%n_bands_sw = int(z'00000000', int32)
    config%n_bands_lw = int(z'00000000', int32)
    config%n_spec_sw = int(z'00000000', int32)
    config%n_spec_lw = int(z'00000000', int32)
    config%n_g_lw_if_scattering = int(z'00000000', int32)
    config%n_bands_lw_if_scattering = int(z'00000000', int32)
    config%is_homogeneous = .false.
    config%do_clouds = .true.
  end subroutine initialize_ecrad_configuration_defaults

end module ecrad_configuration_defaults_mod
