!> Compose native radiation context, early storage and explicit cleanup.
module native_radiation_setup_lifetime
  use iso_fortran_env, only: int32, int64, real64
  use native_radiation_setup_state, only: owned_radiation_setup_state, initialize_radiation_fresh_preimage
  use forecast_grid_dimensions, only: native_grid_dimensions
  use yomrip, only: trip
  use radiation_record_defaults_mod, only: initialize_radiation_record_defaults
  use ecrad_configuration_defaults_mod, only: initialize_ecrad_configuration_defaults
  use aerosol_vertical_storage_port, only: create_runtime_aerosol_vertical_storage, &
                                           release_selected_aerosol_vertical_storage
  use cloud_overlap_setup_port, only: create_cloud_overlap_storage, release_cloud_overlap_storage
  use spectral_planck_parameter_setup_port, only: release_selected_spectral_planck
  use native_spectral_band_setup, only: release_selected_spectral_radiation_tables
  use selected_aerosol_parameter_setup_mod, only: release_selected_aerosol_parameters
  use radiation_flux_parameter_setup_port, only: release_selected_radiation_fluxes
  use native_radiation_climate_setup, only: release_radiation_climate_context
  use selected_ecrad_configuration_port, only: release_selected_ecrad_configuration
  use native_ozone_climatology, only: release_ozone_climatology
  use native_owned_tegen_aerosol_setup, only: initialize_tegen_record_defaults, release_tegen_aerosol_climatology
  use native_owned_cams_climatology_setup, only: release_cams_climatology
  implicit none
  private
  public :: initialize_radiation_setup_context, create_radiation_setup_storage
  public :: release_owned_radiation_setup
contains
  !> Decode the already-read DATA value into the four source table paths.
  !! STATE is a caller-owned native record. DATA_DIRECTORY is readonly text,
  !! length0:512 with no zero byte; its trimmed nonblank length is at most256.
  !! A nonblank directory gains /ifsdata. The four files are RADRRTM,
  !! RADSRTM, ECOZC and aerosol_cams_climatology_43R3a.nc. Blank DATA gives
  !! bare table names and the ecRad directory '.'. Paths use at most511bytes.
  !! Fresh query values and compiler-derived scalar padding are initialized
  !! before metadata commits. No model array or file is read.
  !! All resources must be absent. Return0 or2. No heap allocation occurs.
  integer(int32) function initialize_radiation_setup_context(state, data_directory) result(status)
    type(owned_radiation_setup_state), intent(inout), target :: state
    character(len=*), intent(in) :: data_directory
    character(len=33), parameter :: basenames(4) = [character(len=33) :: &
                                                    'RADRRTM', 'RADSRTM', 'ECOZC', 'aerosol_cams_climatology_43R3a.nc']
    character(len=264) :: directory
    character(len=512) :: paths(4)
    integer(int64) :: lengths(4)
    integer :: data_length, directory_length, path_length, name_length, file, position, prefix
    status = 2_int32
    if (state%storage_ready .or. state%setup_complete .or. has_resource(state)) return
    if (len(data_directory) > 512) return
    do position = 1, len(data_directory)
      if (data_directory(position:position) == achar(0)) return
    end do
    data_length = len_trim(data_directory)
    if (data_length > 256) return
    directory = repeat(achar(0), 264)
    paths = repeat(achar(0), 512)
    if (data_length == 0) then
      directory(1:1) = '.'
      directory_length = 1
    else
      directory(:data_length) = data_directory(:data_length)
      directory(data_length + 1:data_length + 8) = '/ifsdata'
      directory_length = data_length + 8
    end if
    do file = 1, 4
      name_length = len_trim(basenames(file))
      prefix = 0
      if (data_length /= 0) then
        prefix = directory_length + 1
        paths(file) (:directory_length) = directory(:directory_length)
        paths(file) (directory_length + 1:directory_length + 1) = '/'
      end if
      path_length = prefix + name_length
      if (path_length > 511) return
      paths(file) (prefix + 1:path_length) = basenames(file) (:name_length)
      lengths(file) = int(path_length, int64)
    end do
    status = initialize_radiation_fresh_preimage(state)
    if (status /= 0_int32) return
    state%coefficient_directory = directory
    state%table_paths = paths
    state%table_path_lengths = lengths
    call initialize_private_scalar_defaults(state)
    state%context_ready = .true.
    state%last_stage = 0_int32
    state%last_status = 0_int32
    status = 0_int32
  end function

  !> Admit named defaults and the nine aerosol plus one overlap owner first.
  !! DIMENSIONS is the produced canonical grid record. Its live NFLEVG is
  !!1:256. TIME is the shared TRIP record; only its named YRECMIP declaration
  !! defaults change. The native state owns every newly acquired resource.
  !! Existing array owners are never copied. Failure retains the original
  !! partial-record semantics: cleanup runs, and the caller discards the
  !! incomplete scientific state. Return0,1 for allocation,or2 for admission.
  integer(int32) function create_radiation_setup_storage(state, dimensions, time) result(status)
    type(owned_radiation_setup_state), intent(inout) :: state
    type(native_grid_dimensions), intent(in) :: dimensions
    type(trip), intent(inout) :: time
    integer(int32) :: cleanup_status
    status = 2_int32
    if (.not. state%context_ready .or. state%storage_ready .or. has_resource(state)) return
    if (dimensions%nflevg < 1 .or. dimensions%nflevg > 256) return
    call initialize_radiation_record_defaults(state%radiation, time%yrecmip, state%ozone, &
                                              state%input_interpolation, state%output_interpolation)
    status = initialize_tegen_record_defaults(state%tegen)
    if (status /= 0) return
    nullify (state%ecrad%config%i_spec_from_reordered_g_lw, state%ecrad%config%i_spec_from_reordered_g_sw)
    call initialize_ecrad_configuration_defaults(state%ecrad%config)
    status = create_runtime_aerosol_vertical_storage(state%aerosol_distribution, state%radiation, dimensions%nflevg)
    if (status /= 0) return
    state%aerosol_storage_acquired = .true.
    status = create_cloud_overlap_storage(state%cloud_overlap, dimensions%nflevg)
    if (status /= 0) then
      cleanup_status = release_owned_radiation_setup(state)
      return
    end if
    state%overlap_acquired = .true.
    state%storage_ready = .true.
    status = 0_int32
  end function

  !> Release exactly the acquired groups in the original reverse stage order.
  !! STATE is INOUT and remains the caller's owner. Repeated release succeeds.
  !! Borrowed time, physics, geometry and input records are untouched. File
  !! handles belong to children and are already closed before stage commit.
  !! Native failure flags remain set if a child cannot release its resource.
  integer(int32) function release_owned_radiation_setup(state) result(status)
    type(owned_radiation_setup_state), intent(inout) :: state
    integer(int32) :: child
    status = 0_int32
    if (state%cams_acquired) then
      child = release_cams_climatology(state%cams)
      if (status == 0_int32 .and. child /= 0_int32) status = child
      if (child == 0_int32) state%cams_acquired = .false.
    end if
    if (state%tegen_acquired) then
      child = release_tegen_aerosol_climatology(state%tegen, state%tegen_cache)
      if (status == 0_int32 .and. child /= 0_int32) status = child
      if (child == 0_int32) state%tegen_acquired = .false.
    end if
    if (state%ozone_acquired) then
      child = release_ozone_climatology(state%ozone)
      if (status == 0_int32 .and. child /= 0_int32) status = child
      if (child == 0_int32) state%ozone_acquired = .false.
    end if
    if (state%ecrad_acquired) then
      child = release_selected_ecrad_configuration(state%ecrad)
      if (status == 0_int32 .and. child /= 0_int32) status = child
      if (child == 0_int32) state%ecrad_acquired = .false.
    end if
    if (state%climate_acquired) then
      child = release_radiation_climate_context(state%climate)
      if (status == 0_int32 .and. child /= 0_int32) status = child
      if (child == 0_int32) state%climate_acquired = .false.
    end if
    if (state%flux_acquired) then
      child = release_selected_radiation_fluxes(state%fluxes)
      if (status == 0_int32 .and. child /= 0_int32) status = child
      if (child == 0_int32) state%flux_acquired = .false.
    end if
    if (state%aerosol_parameters_acquired) then
      child = release_selected_aerosol_parameters(state%aerosol_atmosphere)
      if (status == 0_int32 .and. child /= 0_int32) status = child
      if (child == 0_int32) state%aerosol_parameters_acquired = .false.
    end if
    if (state%bands_acquired) then
      child = release_selected_spectral_radiation_tables(state%shortwave)
      if (status == 0_int32 .and. child /= 0_int32) status = child
      if (child == 0_int32) state%bands_acquired = .false.
    end if
    if (state%planck_acquired) then
      child = release_selected_spectral_planck(state%radiation%yspectplanck)
      if (status == 0_int32 .and. child /= 0_int32) status = child
      if (child == 0_int32) state%planck_acquired = .false.
    end if
    if (state%overlap_acquired) then
      child = release_cloud_overlap_storage(state%cloud_overlap)
      if (status == 0_int32 .and. child /= 0_int32) status = child
      if (child == 0_int32) state%overlap_acquired = .false.
    end if
    if (state%aerosol_storage_acquired) then
      child = release_selected_aerosol_vertical_storage(state%aerosol_distribution, state%radiation)
      if (status == 0_int32 .and. child /= 0_int32) status = child
      if (child == 0_int32) state%aerosol_storage_acquired = .false.
    end if
    state%storage_ready = .false.
    state%setup_complete = .false.
  end function

  logical function has_resource(state) result(live)
    type(owned_radiation_setup_state), intent(in) :: state
    live = state%aerosol_storage_acquired .or. state%overlap_acquired .or. state%planck_acquired .or. &
           state%bands_acquired .or. state%aerosol_parameters_acquired .or. state%flux_acquired .or. &
           state%climate_acquired .or. state%ecrad_acquired .or. state%ozone_acquired .or. &
           state%tegen_acquired .or. state%cams_acquired
  end function

  !> Set the source context's zero-born private scalar namespace by name.
  !! These values are private setup state, not a copied constructed record.
  !! Later source stages assign their selected physical values.
  subroutine initialize_private_scalar_defaults(state)
    type(owned_radiation_setup_state), intent(inout) :: state
    state%scalars%nuaer = 0_int32
    state%scalars%ntraer = 0_int32
    state%scalars%r10e = 0.0_real64
    state%scalars%replog = 0.0_real64
    state%scalars%repsc = 0.0_real64
    state%scalars%repsca = 0.0_real64
    state%scalars%repsco = 0.0_real64
    state%scalars%repscq = 0.0_real64
    state%scalars%repsct = 0.0_real64
    state%scalars%repscw = 0.0_real64
    state%scalars%diff = 0.0_real64
    state%scalars%rdumulf = 0.0_real64
    state%scalars%rwghtdu = 0.0_real64
    state%scalars%rch4a = 0.0_real64
    state%scalars%rch4b = 0.0_real64
    state%scalars%rcn2oa = 0.0_real64
    state%scalars%rcn2ob = 0.0_real64
    state%scalars%naeradjdu = 0_int32
    state%scalars%lvolcdata = .false.
    state%scalars%clistso4 = repeat(achar(0), 260)
    state%scalars%cvolcdata = repeat(achar(0), 260)
    state%scalars%input_interpolation%nslwiden = 0_int32
    state%scalars%input_interpolation%nslwides = 0_int32
    state%scalars%input_interpolation%nslwidew = 0_int32
    state%scalars%input_interpolation%nslwidee = 0_int32
    state%scalars%input_interpolation%lslondem = .false.
    state%scalars%input_interpolation%naslb1 = 0_int32
    state%scalars%output_interpolation = state%scalars%input_interpolation
    state%scalars%ngptot = 0_int32
    state%scalars%ngptotmx = 0_int32
  end subroutine
end module native_radiation_setup_lifetime
