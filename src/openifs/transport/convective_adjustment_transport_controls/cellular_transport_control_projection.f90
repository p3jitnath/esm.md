!> Project the source convective-copy condition from its one produced owner.
module forecast_cellular_transport_control_projection
  use iso_fortran_env, only: int32
  use forecast_physics_readonly_control_producers, only: native_physics_readonly_controls
  implicit none
  private
  public :: project_cellular_departure_copy
contains
  !> Return LCUCONV_CA AND LCA_ADVECT after genuine cellular setup succeeds.
 !! controls is the existing read-only factory record after NAMCA and the
 !! source LSLAG adjustment. departure_copy is the caller's mutable logical
 !! result and remains unchanged on refusal. No source owner is copied.
 !! Return 0 succeeds. Return 2 refuses an unproduced source record.
  integer(int32) function project_cellular_departure_copy(controls, departure_copy) result(status)
    type(native_physics_readonly_controls), intent(in) :: controls
    logical, intent(inout) :: departure_copy
    status = 2_int32
    if (.not. controls%cellular_ready) return
    departure_copy = controls%cellular%lcuconv_ca .and. controls%cellular%lca_advect
    status = 0_int32
  end function
end module forecast_cellular_transport_control_projection
