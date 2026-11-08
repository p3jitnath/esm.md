!> Own the selected Meteo-France setup records through one native state.
!! The unique model owner retains TPHY2 and the shared physics, geometry
!! and clock records. This state does not duplicate those borrowed inputs.
module forecast_meteo_france_physics_state
  use iso_fortran_env, only: int32, int64, real64
  use yomphy0, only: tphy0
  use yomphy1, only: tphy1
  use yomphy3, only: tphy3
  use yomvdoz, only: tvdoz
  use yomtoph, only: ttoph
  use yomnorgwd, only: tnorgwd
  use yomparar, only: tparar
  use upper_atmosphere_setup_port, only: native_convective_energy_controls
  use land_surface_reference_setup_port, only: land_surface_reference_record
  implicit none
  private
  !> Keep the exact named parameter owners used by the native SUPHMF parent.
  !! Each component retains the canonical type and its original field units.
  !! The compiler owns storage, alignment and allocatable descriptors.
  !! No finalizer or original module method is imported.
  type, public :: owned_meteo_france_physics_state
    type(tphy0) :: atmospheric_parameters
    type(tphy1) :: surface_exchange_parameters
    type(tphy3) :: legacy_radiation_parameters
    type(tvdoz) :: ozone_deposition_parameters
    type(ttoph) :: top_atmosphere_parameters
    type(tnorgwd) :: nonorographic_wave_parameters
    type(tparar) :: alternative_parameters
    type(native_convective_energy_controls) :: convective_energy_controls
    type(land_surface_reference_record) :: land_reference_parameters
    logical :: setup_complete = .false.
    integer(int32) :: last_stage = 0_int32, status = 0_int32
  end type
  public :: initialize_fresh_meteo_france_physics_state
  interface
    !> Prepare a fresh caller-owned state before the numerical setup parent.
    !! STATE is INOUT native storage. Return 2 preserves a state with any live
    !! profile or shortwave-band owner; return 0 establishes named zero-born
    !! values and canonical declaration defaults. A separate implementation
    !! owns this constructor so this shared type declaration remains stable.
    module integer(int32) function initialize_fresh_meteo_france_physics_state(state) result(status)
      type(owned_meteo_france_physics_state), intent(inout) :: state
    end function
  end interface
end module forecast_meteo_france_physics_state
