!> Expose the canonical native SUPHEC context and its complete typed entry.
!! The actual scientific parent receives constants, dynamics, clock, thermal,
!! runtime and output owners directly. Historical address/capacity pairs are
!! replaced by its explicit Fortran types and array bounds, with no new schema.
!! VIEW borrows the actual state; detach it before the parent's release entry.
module forecast_native_suphec_context_interfaces
  use forecast_ecmwf_physics_state, only: native_ecmwf_physics_state
  use ecmwf_physics_control_fields_port, only: physics_runtime_inputs
 use forecast_owned_ecmwf_physics_setup_native_clock,only:initialize_owned_ecmwf_physics_from_native_clock,release_owned_ecmwf_physics_from_native_clock
  implicit none
  private
  public :: native_ecmwf_physics_state, physics_runtime_inputs
  public :: initialize_owned_ecmwf_physics_from_native_clock, release_owned_ecmwf_physics_from_native_clock
  public :: borrow_native_suphec_state
contains
  subroutine borrow_native_suphec_state(owner, view)
    type(native_ecmwf_physics_state), target, intent(inout) :: owner
    type(native_ecmwf_physics_state), pointer, intent(out) :: view
    view => owner
  end subroutine
end module
