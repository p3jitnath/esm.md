!> Own the selected simulation index and scheduler signalling switch.
module forecast_selected_runtime_state
  use iso_c_binding, only: c_int, c_ptr
  implicit none
  private
  public :: initialize_selected_forecast_runtime, get_nsim4d, sigpost
  public :: native_selected_forecast_runtime, owned_selected_runtime
  !> Dimensionless signed words, with source defaults zero.
  type, bind(C) :: native_selected_forecast_runtime
    integer(c_int) :: simulation_index = 0_c_int, scheduler_signals = 0_c_int
  end type
  type(native_selected_forecast_runtime), save, protected :: owned_selected_runtime
  interface
    subroutine exit_process(status) bind(C, name='_exit')
      import c_int
      integer(c_int), value :: status
    end subroutine
  end interface
contains
  !> Read both input words before committing the two-word selected state.
 !! CONTROLS is a complete int32 pair. Only [0,0] is admitted.
  integer(c_int) function initialize_selected_forecast_runtime(controls) result(status)
    integer(c_int), intent(in) :: controls(2)
    integer(c_int) :: simulation, signals
    simulation = controls(1); signals = controls(2); status = 2_c_int
    if (simulation /= 0 .or. signals /= 0) return
    owned_selected_runtime%simulation_index = simulation
    owned_selected_runtime%scheduler_signals = signals
    status = 0_c_int
  end function
  !> Return the live owned signed simulation index without a constant substitute.
  integer(c_int) function get_nsim4d() bind(C, name='__algorithm_state_mod_MOD_get_nsim4d') result(value)
    value = owned_selected_runtime%simulation_index
  end function
  !> Preserve the source unused time pointer and disabled signalling behaviour.
 !! TIME may be null because this selected branch never reads it.
 !! An unsupported enabled signal exits through the public operating system.
  subroutine sigpost(time) bind(C, name='sigpost_')
    type(c_ptr), value :: time
    if (owned_selected_runtime%scheduler_signals /= 0_c_int) call exit_process(125_c_int)
  end subroutine
end module
