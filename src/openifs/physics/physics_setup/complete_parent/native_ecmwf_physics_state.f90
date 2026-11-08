!> Own the parameter records acquired by the native SUPHEC call order.
!! Shared physics configuration, time, thermal parameters and geometry stay
!! with their existing produced owners. This declaration supplies no physics.
module forecast_ecmwf_physics_state
  use iso_fortran_env, only: int32
  use yoecld, only: tecld
  use yoecnd, only: tecnd
  use yoecumf, only: tecumf
  use yoecumf2, only: tecumf2
  use yomcumfs, only: tcumfs
  use yoegwd, only: tegwd
  use yoegwwms, only: tegwwms
  use yoevdf, only: tvdf
  use convection_parameter_fields_mod, only: convection_thermal_parameter_record
  use ecmwf_physics_tail_fields_mod, only: methane_oxidation_parameter_record
  use native_radiation_setup_state, only: owned_radiation_setup_state
  use yos_surf, only: tsurf
  implicit none
  private
  public :: native_ecmwf_physics_state
  !> Native parameters and resources that remain live through the forecast.
  !! CLOUD owns CETA(1:levels). RADIATION owns its complete native tables and
  !! arrays. SURFACE is an exclusive native pointer to fifteen parameter
  !! records; it is never copied from a constructed original object.
  !! OPTIMIZATION_ACQUIRED tracks the accepted source module's eighteen
  !! private native table owners. The parent releases only resources that it
  !! acquired. Scalar parameter fields preserve their incoming source
  !! preimages until their corresponding numerical child assigns them.
  !! Allocate this large state once. Do not copy a live state with pointers.
  type :: native_ecmwf_physics_state
    type(tecld) :: cloud
    type(tecnd) :: condensation
    type(tecumf) :: convection
    type(tecumf2) :: linearized_convection
    type(tcumfs) :: convection_switches
    type(convection_thermal_parameter_record) :: convection_thermal
    type(tegwd) :: orographic_gravity_wave
    type(tegwwms) :: nonorographic_gravity_wave
    type(tvdf) :: diffusion
    type(owned_radiation_setup_state) :: radiation
    type(methane_oxidation_parameter_record) :: methane
    type(tsurf), pointer :: surface => null()
    logical :: cloud_eta_acquired = .false.
    logical :: optimization_acquired = .false.
    logical :: radiation_attempted = .false.
    logical :: surface_acquired = .false.
    logical :: setup_complete = .false.
    integer(int32) :: last_stage = 0_int32, last_status = 0_int32
  end type native_ecmwf_physics_state
end module forecast_ecmwf_physics_state
