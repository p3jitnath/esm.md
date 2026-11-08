!> Own native radiation setup records while borrowing shared forecast state.
module native_radiation_setup_state
  use iso_fortran_env, only: int32, int64
  use yoerad, only: terad
  use yoerdi, only: terdi
  use yoe_uvrad, only: teuvrad
  use yoesw, only: teswrt
  use yoeaerd, only: teaerd
  use yoeovlp, only: teovlp
  use yomradf, only: tradf
  use yoeozoc, only: teozoc
  use owned_aerosol_climatology_records, only: teaerc_tegen, teaerc_macc
  use yoeaeratm, only: teaeratm
  use yoeaerlid, only: teaerlid
  use yoeaermap, only: teaermap
  use yoeaersnk, only: teaersnk
  use yoeaersrc, only: teaersrc
  use yoeaervol, only: teaervol
  use yoedbug, only: tedbug
  use eint_mod, only: sl_struct
  use longwave_reference_parameter_fields_mod, only: longwave_reference_parameter_record
  use shortwave_auxiliary_parameter_fields_mod, only: shortwave_transmission_parameter_record, &
                                                      shortwave_aerosol_parameter_record, shortwave_cloud_parameter_record
  use native_absorption_records, only: longwave_absorption_input_record, &
                                       longwave_absorption_reduced_record, shortwave_absorption_record
  use native_longwave_band_record, only: longwave_band_parameter_record
  use cloud_optical_parameter_fields_mod, only: cloud_optical_550_parameter_record
  use selected_aerosol_parameter_fields_mod, only: aerosol_optical_parameter_record
  use native_owned_tegen_aerosol_setup, only: tegen_shared_cache
  use native_radiation_climate_records, only: radiation_climate_context
  use selected_ecrad_configuration_port, only: selected_ecrad_configuration_record
  use selected_radiation_control_fields_mod, only: radiation_scalar_parameter_record
  use radiation_climate_selection_port, only: radiation_climate_selection_record
  implicit none
  private
  public :: owned_radiation_setup_state
  !> Native owner for the SUECRAD records, tables and acquired resources.
  !! Allocate this large record through a caller-owned allocatable forecast
  !! state. Do not copy a live state: its native pointer views borrow the
  !! explicit TEGEN cache. All record types use their actual public/native
  !! declarations; the compiler owns component and array representation.
  !! TRIP including YRECMIP, the shared TEPHY and TELWRAD records, constants,
  !! native_grid_dimensions and native_distributed_partition are borrowed
  !! by the parent interfaces rather than duplicated in this owner.
  !! Resource flags belong only to the setup/release call order. Source-
  !! unwritten numerical members and padding retain their incoming state.
  type :: owned_radiation_setup_state
    type(terad) :: radiation
    type(terdi) :: gases
    type(teuvrad) :: ultraviolet
    type(teswrt) :: shortwave
    type(teaerd) :: aerosol_distribution
    type(teovlp) :: cloud_overlap
    type(tradf) :: fluxes
    type(teozoc) :: ozone
    type(teaerc_tegen) :: tegen
    type(teaerc_macc) :: cams
    type(teaeratm) :: aerosol_atmosphere
    type(teaerlid) :: aerosol_lidar
    type(teaermap) :: aerosol_mapping
    type(teaersnk) :: aerosol_sinks
    type(teaersrc) :: aerosol_sources
    type(teaervol) :: aerosol_volume
    type(tedbug) :: aerosol_debug
    type(sl_struct) :: input_interpolation, output_interpolation
    type(longwave_reference_parameter_record) :: longwave_reference
    type(shortwave_transmission_parameter_record) :: shortwave_transmission
    type(shortwave_aerosol_parameter_record) :: shortwave_auxiliary_aerosol
    type(shortwave_cloud_parameter_record) :: shortwave_auxiliary_cloud
    type(longwave_absorption_input_record) :: longwave_input
    type(longwave_absorption_reduced_record) :: longwave_reduced
    type(shortwave_absorption_record) :: shortwave_absorption
    type(longwave_band_parameter_record) :: longwave_bands
    type(cloud_optical_550_parameter_record) :: cloud_optical_550
    type(aerosol_optical_parameter_record) :: aerosol_optical
    type(tegen_shared_cache) :: tegen_cache
    type(radiation_climate_context), allocatable :: climate
    type(selected_ecrad_configuration_record) :: ecrad
    type(radiation_scalar_parameter_record) :: scalars
    type(radiation_climate_selection_record) :: selection
    logical :: context_ready = .false., storage_ready = .false., setup_complete = .false.
    logical :: aerosol_storage_acquired = .false., overlap_acquired = .false.
    logical :: planck_acquired = .false., bands_acquired = .false.
    logical :: aerosol_parameters_acquired = .false., flux_acquired = .false.
    logical :: climate_acquired = .false., ecrad_acquired = .false.
    logical :: ozone_acquired = .false., tegen_acquired = .false., cams_acquired = .false.
    integer(int32) :: last_stage = 0_int32, last_status = 0_int32
    character(len=264) :: coefficient_directory
    character(len=512) :: table_paths(4)
    integer(int64) :: table_path_lengths(4)
  end type owned_radiation_setup_state
end module native_radiation_setup_state
