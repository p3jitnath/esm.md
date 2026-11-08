!> Borrow the complete produced forecast namespace and its one model clock.
!! Counts are dimensionless and clock values use seconds. No data is copied.
!! STATE must remain a live TARGET until both returned pointers are detached.
!! The compiler owns all component offsets; historical ELF aliases stay recorded.
module forecast_native_forecast_control_aliases
  use forecast_controls_state_types, only: native_forecast_controls_state, native_forecast_control_namespace
  use forecast_model_clock_port, only: forecast_clock
  implicit none
  private
  public :: bind_native_forecast_control_aliases
contains
  subroutine bind_native_forecast_control_aliases(state, namespace, clock)
    type(native_forecast_controls_state), target, intent(inout) :: state
    type(native_forecast_control_namespace), pointer, intent(out) :: namespace
    type(forecast_clock), pointer, intent(out) :: clock
    namespace => state%namespace
    clock => state%clock
  end subroutine
end module
