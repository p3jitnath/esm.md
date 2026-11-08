!> Borrow the live native radiation inputs and canonical forecast field owners.
!! Every pointer borrows an existing producer; this type owns no model image.
!! Coordinates use sine latitude, radians and Pa as named below.
!! These declarations supply no numerical stage or callback.
module native_radiation_forecast_driver
  use iso_fortran_env, only: int32, real64
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use physics_configuration_state_port, only: physics_configuration_state
  use native_radiation_setup_state, only: owned_radiation_setup_state
  use surface_field_storage_port, only: surface_field_state
  use surface_field_configuration_port, only: surface_field_registry
  use gridpoint_field_storage_port, only: gridpoint_field_state
  use forecast_grid_motion_types, only: native_grid_motion_state
  use md2asm_hybrid_pressure_one_based, only: hybrid_pressure_controls
  use yos_surf, only: TSURF
  use yomrip, only: TRIP
  use yoerip, only: TERIP
  use yomphy3, only: TPHY3
  use yomdphy, only: TDPHY
  use yoecld, only: TECLD
  use md2asm_moist_air_gas_properties, only: thermal_constituent
  use native_radiation_calendar_and_ice, only: native_sea_ice_state
  implicit none
  private
  public :: native_radiation_driver_context, raddrv, radiation_surface_index
!> Data-only join to the canonical setup, clock, field metadata and geometry.
!! The production caller keeps all pointed-to owners live and stationary.
!! Coordinate arrays have shape(block_columns,blocks). Half coefficients
!! retain lower bound0; layer coefficients start at physical level1.
!! Local point counts and selectors come from their live metadata producers.
  type :: native_radiation_driver_context
    type(forecast_physical_constants), pointer :: constants => null()
    type(thermal_parameter_record), pointer :: thermal => null()
    type(physics_configuration_state), pointer :: configuration => null()
    type(owned_radiation_setup_state), pointer :: setup => null()
    type(surface_field_state), pointer :: surface => null()
    type(surface_field_registry), pointer :: surface_catalog => null()
    type(TSURF), pointer :: surface_parameters => null()
    type(TRIP), pointer :: time => null()
    type(TERIP), pointer :: solar => null()
    type(TPHY3), pointer :: legacy_radiation => null()
    type(TDPHY), pointer :: physics_dimensions => null()
    type(TECLD), pointer :: cloud_parameters => null()
    type(hybrid_pressure_controls), pointer :: pressure_controls => null()
    real(real64), pointer :: latitude_sine(:, :) => null(), longitude(:, :) => null(), orography(:, :, :) => null()
    real(real64), pointer :: half_a(:) => null(), half_b(:) => null(), vc(:) => null()
    real(real64), pointer :: full_a(:) => null(), full_b(:) => null(), delta_a(:) => null(), delta_b(:) => null()
    type(thermal_constituent), pointer :: thermal_constituents(:) => null()
    integer(int32) :: pressure_field_indices(7) = 0
    integer(int32) :: water_plane = 0, liquid_plane = 0, ice_plane = 0, cloud_fraction_plane = 0
    integer(int32) :: rain_plane = 0, snow_plane = 0, ozone_plane = 0, spread_plane = 0, vertical_velocity_plane = 0
    integer(int32) :: active_aerosols = 0, aerosol_species = 0, chemistry_species = 0, spread_species = 0
    integer(int32) :: step = 0, initial_date = 0, initial_seconds = 0, global_latitude_count = 0
    integer(int32) :: local_points = 0, block_columns = 0, levels = 0
    real(real64) :: planet_area_scale = 0.0_real64, gravity_scale = 0.0_real64
    logical :: stochastic_enabled = .false., prognostic_ozone = .false., chemistry_ozone = .false.
    logical :: two_time_levels = .false., same_radiation_grid = .false.
    type(native_sea_ice_state) :: sea_ice
    logical :: sea_ice_albedo_enabled = .false.
    real(real64), pointer :: longitude_cosine(:, :) => null(), longitude_sine(:, :) => null()
    integer(int32), pointer :: latitude_first(:) => null(), latitude_points(:) => null()
  end type
  interface
    module function raddrv(context, fields, motion, local_points, pgpin) result(status)
      type(native_radiation_driver_context), intent(inout) :: context
      type(gridpoint_field_state), intent(inout) :: fields
      type(native_grid_motion_state), intent(inout) :: motion
      integer(int32), intent(in) :: local_points
      real(real64), intent(in) :: pgpin(:, :, :)
      integer(int32) :: status
    end function
    module function radiation_surface_index(context, name, variant) result(index)
      type(native_radiation_driver_context), intent(in) :: context
      character(*), intent(in) :: name
      integer(int32), intent(in) :: variant
      integer(int32) :: index
    end function
  end interface
end module
