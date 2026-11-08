!> Prepare the actual radiation owner before the scientific setup parent.
module forecast_native_radiation_preparation
  use iso_fortran_env, only: int32
  use forecast_native_startup_storage, only: native_forecast_startup_storage
  use forecast_grid_dimensions, only: native_grid_dimensions
  use native_radiation_setup_state, only: owned_radiation_setup_state
  use native_radiation_setup_lifetime, only: initialize_radiation_setup_context
  use forecast_owned_radiation_setup_from_native_clock, only: release_owned_actual_radiation_setup
  use yoecmip, only: tecmip
  use radiation_record_defaults_mod, only: initialize_radiation_record_defaults
  use ecrad_configuration_defaults_mod, only: initialize_ecrad_configuration_defaults
  use native_owned_tegen_aerosol_setup, only: initialize_tegen_record_defaults
  use aerosol_vertical_storage_port, only: create_runtime_aerosol_vertical_storage
  use cloud_overlap_setup_port, only: create_cloud_overlap_storage
  implicit none
  private
  public :: prepare_native_radiation_setup, create_native_radiation_setup_storage
contains
  !> Prepare the one final-address radiation owner and the actual CMIP record.
  !! STARTUP is TARGET and stays at its address until all borrowers close.
  !! The genuine input prefix and model storage must already exist. DATA comes
  !! from the actual forcing context. This entry reads no coefficient file.
  !! Its successful children own the early aerosol and overlap arrays. Return
  !! values are unchanged child results; partial source writes remain visible.
  integer(int32) function prepare_native_radiation_setup(startup) result(status)
    type(native_forecast_startup_storage), target, intent(inout) :: startup
    status = 2_int32
    if (.not. allocated(startup%initial)) return
    if (.not. allocated(startup%initial%geometry)) return
    if (.not. allocated(startup%loaded%storage)) return
    if (.not. associated(startup%loaded%storage%model%initial, startup%initial)) return
    status = initialize_radiation_setup_context(startup%loaded%storage%ecmwf%radiation, &
                                                trim(startup%forcing%data_directory))
    if (status /= 0_int32) return
    status = create_native_radiation_setup_storage(startup%loaded%storage%ecmwf%radiation, &
                                                   startup%initial%geometry%dimensions, startup%forcing%cmip)
  end function

  !> Keep the source storage order while accepting the separate CMIP target.
  !! STATE owns its arrays. DIMENSIONS is readonly, with levels1:256. CMIP is
  !! the actual scientific record later passed to SUPHEC and time update.
  !! No model clock or CMIP copy is constructed. The original default writers
  !! and allocation children are unchanged. The caller establishes FP mode.
  integer(int32) function create_native_radiation_setup_storage(state, dimensions, cmip) result(status)
    type(owned_radiation_setup_state), intent(inout) :: state
    type(native_grid_dimensions), intent(in) :: dimensions
    type(tecmip), intent(inout) :: cmip
    integer(int32) :: cleanup_status
    status = 2_int32
    if (.not. state%context_ready .or. state%storage_ready .or. has_resource(state)) return
    if (dimensions%nflevg < 1 .or. dimensions%nflevg > 256) return
    call initialize_radiation_record_defaults(state%radiation, cmip, state%ozone, &
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
      cleanup_status = release_owned_actual_radiation_setup(state)
      return
    end if
    state%overlap_acquired = .true.
    state%storage_ready = .true.
    status = 0_int32
  end function

  logical function has_resource(state) result(live)
    type(owned_radiation_setup_state), intent(in) :: state
    live = state%aerosol_storage_acquired .or. state%overlap_acquired .or. state%planck_acquired .or. &
           state%bands_acquired .or. state%aerosol_parameters_acquired .or. state%flux_acquired .or. &
           state%climate_acquired .or. state%ecrad_acquired .or. state%ozone_acquired .or. &
           state%tegen_acquired .or. state%cams_acquired
  end function
end module forecast_native_radiation_preparation
