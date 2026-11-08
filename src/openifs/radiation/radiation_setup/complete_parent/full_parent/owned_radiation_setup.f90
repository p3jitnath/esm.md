!> Own the complete selected radiation setup call order in native Fortran.
!! Child modules supply the generated calculations and their native owners.
!! Public file and ecRad services remain external. No original OpenIFS body
!! or verification wrapper supplies a missing stage.
module forecast_owned_radiation_setup
  use iso_fortran_env, only: int32, int64, real64
  use native_radiation_setup_state, only: owned_radiation_setup_state
  use native_radiation_setup_lifetime, only: release_owned_radiation_setup
  use native_radiation_coefficient_storage, only: initialize_radiation_coefficient_storage
  use forecast_grid_dimensions, only: native_grid_dimensions
  use forecast_distributed_partition_types, only: native_distributed_partition
  use forecast_controls_state_types, only: native_forecast_control_namespace
  use physics_configuration_state_port, only: physics_configuration_state
  use physical_constant_setup_port, only: forecast_physical_constants
  use yomrip, only: trip
  use yomsta, only: tsta
  use selected_radiation_control_setup_port, only: radiation_control_upstream_record, &
                                                   initialize_selected_radiation_controls, initialize_runtime_radiation_controls
  use longwave_reference_parameter_setup_mod, only: initialize_longwave_reference_parameters
  use cloud_optical_parameter_fields_mod, only: initialize_cloud_optical_fields, initialize_cloud_optical_550_fields
  use absorption_file_setup, only: read_longwave_absorption_file, read_shortwave_absorption_file
  use native_longwave_absorption_reduction, only: reduce_longwave_absorption
  use native_spectral_band_setup, only: initialize_selected_spectral_radiation_tables
  use shortwave_auxiliary_parameter_setup_mod, only: initialize_shortwave_auxiliary_parameters
  use aerosol_distribution_setup_mod, only: initialize_selected_aerosol_distribution, initialize_runtime_aerosol_distribution
  use selected_aerosol_parameter_fields_mod, only: aerosol_parameter_control_record
  use selected_aerosol_parameter_setup_mod, only: initialize_selected_aerosol_parameters
  use cloud_overlap_setup_port, only: initialize_cloud_overlap_profile
  use radiation_flux_parameter_setup_port, only: initialize_selected_radiation_fluxes, create_runtime_radiation_flux_owners
  use runtime_radiation_frequency_text_port, only: initialize_runtime_radiation_frequencies
  use native_radiation_climate_setup, only: create_radiation_climate_context
  use selected_ecrad_configuration_port, only: initialize_selected_ecrad_configuration
  use ecmwf_physics_control_fields_port, only: selected_composition_aerosol_flags
  use native_ozone_climatology, only: read_ozone_climatology_file
  use native_owned_tegen_aerosol_setup, only: initialize_tegen_aerosol_climatology
  use native_owned_cams_climatology_setup, only: initialize_cams_climatology
  implicit none
  private
  public :: initialize_owned_radiation_setup
contains
  !> Complete SUECRAD from fresh native storage and explicit produced inputs.
  !! STATE is INOUT and owns all radiation records and acquired arrays. Its
  !! context and early aerosol/overlap storage have already been created.
  !! TEXT is the complete readonly input,1:262144 characters. DATA_DIRECTORY
  !! is the explicit DATA value used to prepare the same state paths.
  !! CONSTANTS, CONTROLS, GRID and PARTITION are readonly produced records.
  !! CONTROLS owns the shared LECMWF and LARPEGEF source switches. The global
  !! grid owns levels and resolution; PARTITION owns the local point/block
  !! counts. CONFIGURATION is the shared seventeen-record physics carrier;
  !! only its longwave record is changed by the radiation control child.
  !! TIME is the shared TRIP, in seconds; its YRECMIP members are INOUT.
  !! ATMOSPHERE is readonly TSTA with native STZ(1:levels), in metres.
  !! ETA is readonly contiguous dimensionless half-level pressure,shape
  !! levels+1. RPLRG is the explicit upstream dimensionless dynamical scale.
  !! SEED supplies the remaining source controls; live shared/grid/time
  !! members replace their corresponding seed values before the first call.
  !! COMPOSITION contains the two readonly source aerosol switches.
  !! AEROSOL_COUNTS gives NAERO,NACTAERO. DATE_SECONDS gives NINDAT,NSSSSS.
  !! BYTE_QUOTA bounds the new flux payload,1:2**36 bytes.
  !! RUNTIME_GRID selects the existing live-grid children; their wider joined
  !! acceptance remains separate from this selected-source counterpart.
  !! Return0 after all eighteen stages; otherwise preserve the failed stage
  !! and status,release acquired owners,and leave the scientific state for
  !! the caller to discard. Borrowed scientific records can retain their
  !! already-completed source prefix. No whole-model atomicity is claimed.
  integer(int32) function initialize_owned_radiation_setup(state, text, data_directory, constants, controls, grid, partition, &
         configuration,time,atmosphere,eta,rplrg,seed,composition,aerosol_counts,date_seconds,byte_quota,runtime_grid)result(status)
    type(owned_radiation_setup_state), intent(inout) :: state
    character(len=*), intent(in) :: text, data_directory
    type(forecast_physical_constants), intent(in) :: constants
    type(native_forecast_control_namespace), intent(in) :: controls
    type(native_grid_dimensions), intent(in) :: grid
    type(native_distributed_partition), intent(in) :: partition
    type(physics_configuration_state), intent(inout) :: configuration
    type(trip), intent(inout) :: time
    type(tsta), intent(in) :: atmosphere
    real(real64), intent(in) :: eta(:), rplrg
    type(radiation_control_upstream_record), intent(in) :: seed
    type(selected_composition_aerosol_flags), intent(in) :: composition
    integer(int32), intent(in) :: aerosol_counts(2), date_seconds(2)
    integer(int64), intent(in) :: byte_quota
    logical, intent(in) :: runtime_grid
    type(radiation_control_upstream_record) :: live
    type(aerosol_parameter_control_record) :: aerosol_controls
    character(len=512) :: climate_paths(3)
    integer(int64) :: climate_lengths(3)
    integer(int32) :: cleanup_status
    integer :: directory_length
    status = 2_int32
    if (.not. state%context_ready .or. .not. state%storage_ready .or. state%setup_complete) return
    if (.not. state%aerosol_storage_acquired .or. .not. state%overlap_acquired) return
    if (state%planck_acquired .or. state%bands_acquired .or. state%aerosol_parameters_acquired .or. &
        state%flux_acquired .or. state%climate_acquired .or. state%ecrad_acquired .or. &
        state%ozone_acquired .or. state%tegen_acquired .or. state%cams_acquired) return
    if (len(text) < 1 .or. len(text) > 262144) return
    if (grid%nflevg < 1 .or. grid%nflevg > 256 .or. size(eta) /= grid%nflevg + 1) return
    if (.not. is_contiguous(eta)) return
    if (partition%ngpblks < 1 .or. partition%ngptot < 1 .or. partition%ngptotmx < partition%ngptot) return
    if (byte_quota < 1_int64 .or. byte_quota > shiftl(1_int64, 36)) return
    if (controls%lecmwf < 0 .or. controls%lecmwf > 1 .or. controls%larpegef < 0 .or. controls%larpegef > 1) return
    live = seed
    live%lecmwf = controls%lecmwf == 1_int32
    live%larpegef = controls%larpegef == 1_int32
    live%lephys = configuration%ecmwf_physics%lephys
    live%lrayfm = configuration%phy%lrayfm
    live%lhlradupd = configuration%phy%lhlradupd
    live%lray = configuration%phy%lray
    live%laeruvp = state%aerosol_atmosphere%laeruvp
    live%leradi = configuration%ecmwf_physics%leradi
    live%leradlw2 = configuration%nonlinear_physics%leradlw2
    live%nemissscheme = configuration%ecmwf_physics%nemissscheme
    live%leradn2 = configuration%nonlinear_physics%leradn2
    live%nproma = grid%nproma
    live%nsmax = grid%nsmax
    live%ndglg = grid%ndglg
    live%ngptot = partition%ngptot
    live%ngptotmx = partition%ngptotmx
    live%nflevg = grid%nflevg
    live%ngpblks = partition%ngpblks
    live%ndlon = grid%ndlon
    live%timestep = time%tstep
    call initialize_radiation_coefficient_storage(state)
    setup_sequence: block
      state%last_stage = 1_int32
      if (runtime_grid) then
        status = initialize_runtime_radiation_controls(text, data_directory, live, state%radiation, state%gases, &
                       state%ultraviolet, configuration%longwave_radiation, time%yrecmip, state%scalars, state%selection, constants)
      else
        status = initialize_selected_radiation_controls(text, data_directory, live, state%radiation, state%gases, &
                       state%ultraviolet, configuration%longwave_radiation, time%yrecmip, state%scalars, state%selection, constants)
      end if
      if (status /= 0_int32) exit setup_sequence
      state%planck_acquired = .true.
      status = 2_int32
      if (state%selection%values%nhincsol /= 4) exit setup_sequence
      if (state%selection%values%nghgrad /= 20 .and. state%selection%values%nghgrad /= 21) exit setup_sequence
      if (.not. state%selection%values%lhghg .or. state%selection%values%laer3d) exit setup_sequence
      if (configuration%linear_ecmwf%lphylin) exit setup_sequence
      call copy_interpolation_metadata(state)
      state%last_stage = 2_int32
      status = initialize_longwave_reference_parameters(state%longwave_reference, state%gases, constants)
      if (status /= 0_int32) exit setup_sequence
      if (state%radiation%ninhom == 0) then
        state%radiation%rlwinhf = 1.0_real64
        state%radiation%rswinhf = 1.0_real64
      end if
      state%last_stage = 3_int32
      call initialize_cloud_optical_550_fields(state%cloud_optical_550)
      state%last_stage = 4_int32
      status = read_longwave_absorption_file(state%table_paths(1) (:int(state%table_path_lengths(1))), state%longwave_input)
      if (status /= 0_int32) exit setup_sequence
      state%last_stage = 5_int32
      status = reduce_longwave_absorption(state%longwave_input, state%longwave_reduced)
      if (status /= 0_int32) exit setup_sequence
      state%last_stage = 6_int32
 status = initialize_selected_spectral_radiation_tables(state%longwave_bands, state%shortwave, state%radiation, constants%rg, rplrg)
      if (status /= 0_int32) exit setup_sequence
      state%bands_acquired = .true.
      state%last_stage = 7_int32
      call initialize_cloud_optical_fields(state%radiation, state%shortwave, grid%nflevg)
      state%radiation%ntsw = 14_int32
      state%last_stage = 8_int32
      status = read_shortwave_absorption_file(state%table_paths(2) (:int(state%table_path_lengths(2))), state%shortwave_absorption)
      if (status /= 0_int32) exit setup_sequence
      state%last_stage = 9_int32
      status = initialize_shortwave_auxiliary_parameters(state%shortwave_transmission, state%shortwave_auxiliary_aerosol, &
                                                         state%shortwave_auxiliary_cloud)
      if (status /= 0_int32) exit setup_sequence
      state%last_stage = 10_int32
      if (runtime_grid) then
        status = initialize_runtime_aerosol_distribution(eta, state%shortwave, state%aerosol_distribution, state%radiation)
      else
        status = initialize_selected_aerosol_distribution(eta, state%shortwave, state%aerosol_distribution, state%radiation)
      end if
      if (status /= 0_int32) exit setup_sequence
      state%radiation%laeradcli = .true.
      state%radiation%nmclat = 61_int32
      state%radiation%nmclon = 120_int32
      state%radiation%nmcvar = 12_int32
      state%radiation%nmclev = 1_int32
      state%last_stage = 11_int32
      aerosol_controls%naero = aerosol_counts(1)
      aerosol_controls%nactaero = aerosol_counts(2)
      aerosol_controls%naermacc = 1_int32
      aerosol_controls%leso4his = .false.
      aerosol_controls%nindat = date_seconds(1)
      aerosol_controls%nsssss = date_seconds(2)
      status = initialize_selected_aerosol_parameters(aerosol_controls, state%aerosol_atmosphere, state%aerosol_lidar, &
state%aerosol_mapping, state%aerosol_sinks, state%aerosol_sources, state%aerosol_volume, state%aerosol_debug, state%aerosol_optical)
      if (status /= 0_int32) exit setup_sequence
      state%aerosol_parameters_acquired = .true.
      state%last_stage = 12_int32
      status = initialize_cloud_overlap_profile(atmosphere, state%cloud_overlap, state%radiation, grid%nflevg)
      if (status /= 0_int32) exit setup_sequence
      state%last_stage = 13_int32
      if (runtime_grid) then
        status = initialize_runtime_radiation_frequencies(text, constants, time%tstep, state%radiation, state%ultraviolet)
        if (status /= 0_int32) exit setup_sequence
        status = create_runtime_radiation_flux_owners(state%fluxes, grid%nproma, grid%nflevg, partition%ngpblks, &
                                                      state%radiation%nlwout, state%radiation%lapproxlwupdate, byte_quota)
      else
        status = initialize_selected_radiation_fluxes(state%fluxes, state%radiation, state%ultraviolet, constants, live, byte_quota)
      end if
      if (status /= 0_int32) exit setup_sequence
      state%flux_acquired = .true.
      state%last_stage = 14_int32
      climate_paths = state%selection%paths
      climate_lengths = state%selection%path_lengths
      status = create_radiation_climate_context(state%climate, climate_paths, climate_lengths, constants)
      if (status /= 0_int32) exit setup_sequence
      state%climate_acquired = .true.
      state%last_stage = 15_int32
      directory_length = index(state%coefficient_directory, achar(0)) - 1
      if (directory_length < 0) directory_length = len(state%coefficient_directory)
      if (directory_length < 1) then
        status = 2_int32
        exit setup_sequence
      end if
      status = initialize_selected_ecrad_configuration(state%ecrad, state%radiation, configuration%ecmwf_physics, &
                                     state%aerosol_atmosphere, state%longwave_reduced%ngb, state%shortwave_absorption%ngbsw, text, &
                                                       state%coefficient_directory(:directory_length), composition)
      if (status /= 0_int32) exit setup_sequence
      state%ecrad_acquired = .true.
      state%last_stage = 16_int32
      status = read_ozone_climatology_file(state%table_paths(3) (:int(state%table_path_lengths(3))), state%ozone)
      if (status /= 0_int32) exit setup_sequence
      state%ozone_acquired = .true.
      state%last_stage = 17_int32
      status = initialize_tegen_aerosol_climatology(state%tegen, state%tegen_cache, state%scalars%cvolcdata, .true.)
      if (status /= 0_int32) exit setup_sequence
      state%tegen_acquired = .true.
      state%last_stage = 18_int32
      status = initialize_cams_climatology(state%table_paths(4) (:int(state%table_path_lengths(4))), state%cams)
      if (status /= 0_int32) exit setup_sequence
      state%cams_acquired = .true.
      state%setup_complete = .true.
      status = 0_int32
    end block setup_sequence
    state%last_status = status
    if (status /= 0_int32) cleanup_status = release_owned_radiation_setup(state)
  end function

  !> Copy only the twelve source interpolation words into the native records.
  !! Other SL_STRUCT members remain unchanged.
  subroutine copy_interpolation_metadata(state)
    type(owned_radiation_setup_state), intent(inout) :: state
    state%input_interpolation%nslwiden = state%scalars%input_interpolation%nslwiden
    state%input_interpolation%nslwides = state%scalars%input_interpolation%nslwides
    state%input_interpolation%nslwidew = state%scalars%input_interpolation%nslwidew
    state%input_interpolation%nslwidee = state%scalars%input_interpolation%nslwidee
    state%input_interpolation%lslondem = state%scalars%input_interpolation%lslondem
    state%input_interpolation%naslb1 = state%scalars%input_interpolation%naslb1
    state%output_interpolation%nslwiden = state%scalars%output_interpolation%nslwiden
    state%output_interpolation%nslwides = state%scalars%output_interpolation%nslwides
    state%output_interpolation%nslwidew = state%scalars%output_interpolation%nslwidew
    state%output_interpolation%nslwidee = state%scalars%output_interpolation%nslwidee
    state%output_interpolation%lslondem = state%scalars%output_interpolation%lslondem
    state%output_interpolation%naslb1 = state%scalars%output_interpolation%naslb1
  end subroutine
end module forecast_owned_radiation_setup
