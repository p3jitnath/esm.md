!> Bind the runtime CALLPAR lease to the actual final execution targets.
module forecast_execution_runtime_callpar_lease
  use iso_fortran_env, only: int32
  use forecast_native_execution_state, only: native_forecast_execution_state
  use forecast_runtime_callpar_context_lease, only: initialize_runtime_callpar_context_lease
  implicit none
  private
  public :: bind_execution_runtime_callpar_lease
contains
  !> Delegate to the complete lease core with the one actual clock and hook.
 !! execution is the existing mutable TARGET. Its provider record, startup,
 !! physics inputs and produced hook holder remain at their final addresses.
 !! The source CNT4 stage writes current_step before this actual consumer.
 !! The wrapper does not refresh the hook or change scientific pointers.
 !! It preserves the core's late step refusal and all returned status values.
  integer(int32) function bind_execution_runtime_callpar_lease(execution) result(status)
    type(native_forecast_execution_state), target, intent(inout) :: execution
    status = 2_int32
    if (.not. allocated(execution%startup)) return
    if (.not. allocated(execution%startup%initial)) return
    status = initialize_runtime_callpar_context_lease(execution%physics_factory%providers, &
                                                      execution%startup, execution%physics, execution%hook_control, &
                                                      execution%startup%initial%controls%clock%current_step)
  end function
end module forecast_execution_runtime_callpar_lease
