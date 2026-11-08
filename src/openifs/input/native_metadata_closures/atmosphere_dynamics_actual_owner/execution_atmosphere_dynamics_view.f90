!> Project only the canonical execution object's existing atmosphere and maps.
module forecast_execution_atmosphere_dynamics_view
  use iso_fortran_env, only: int32
  use forecast_native_execution_state, only: native_forecast_execution_state
  use forecast_actual_atmosphere_dynamics_view, only: native_actual_atmosphere_dynamics_view, &
                                                      project_actual_atmosphere_dynamics
  implicit none
  private
  public :: project_execution_atmosphere_dynamics
contains
  !> Borrow actual final-address owners after startup and GP metadata production.
 !! execution is a read-only TARGET. Its startup owns the actual geometry;
 !! gp_work owns the only produced 28-record dynamics map. No owner is created.
 !! view follows the core read-only lifetime contract. Return0 succeeds;
 !! Return2 refuses before any owner or existing view changes.
  integer(int32) function project_execution_atmosphere_dynamics(view, execution) result(status)
    type(native_actual_atmosphere_dynamics_view), intent(inout) :: view
    type(native_forecast_execution_state), target, intent(in) :: execution
    status = 2
    if (.not. allocated(execution%startup)) return
    if (.not. allocated(execution%startup%initial)) return
    if (.not. execution%startup%initial%ready) return
    status = project_actual_atmosphere_dynamics(view, execution%startup%initial%geometry, execution%gp_work)
  end function
end module forecast_execution_atmosphere_dynamics_view
