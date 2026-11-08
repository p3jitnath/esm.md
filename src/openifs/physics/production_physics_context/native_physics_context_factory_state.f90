!> Retain only factory-owned controls and borrowed final-address targets.
module forecast_native_physics_factory_state
  use iso_fortran_env, only: int32
  use forecast_physics_provider_targets, only: callpar_provider_targets
  use forecast_native_post_physics_control_targets, only: native_post_physics_control_targets
  use forecast_slow_physics_parameters, only: native_slow_physics_parameters
  use md2asm_hybrid_pressure_and_gradients, only: hybrid_pressure_controls
  use forecast_physics_readonly_control_producers, only: native_physics_readonly_controls
  implicit none
  private
  public :: native_physics_context_factory_state
  !> Keep this record TARGET and stationary until EC and radiation close.
  !! PROVIDERS and POST_CONTROLS borrow existing actual owners. SLOW owns the
  !! one source-produced RSLWX array. PRESSURE contains source metadata, not
  !! a pressure field. READONLY owns the genuine selected chemistry and NAMCA
  !! controls. The two integer PPVI values encode the actual logical flags
  !! for the existing declared post-processing interface; they are refreshed
  !! from those flags and never supply defaults. No weather state is copied.
  type :: native_physics_context_factory_state
    type(callpar_provider_targets) :: providers
    type(native_post_physics_control_targets) :: post_controls
    type(native_slow_physics_parameters) :: slow
    type(hybrid_pressure_controls) :: pressure
    type(native_physics_readonly_controls) :: readonly
    integer(int32) :: lrppuv_cstext_encoding = 0_int32
    integer(int32) :: lrppuv_callitpq_encoding = 0_int32
    integer(int32) :: phase = 0_int32, last_status = 0_int32
  end type
end module forecast_native_physics_factory_state
