!> Keep the three forecast timers in stable caller-owned native storage.
module forecast_timer_state_types
  use iso_c_binding, only: c_double
  implicit none
  private
  public :: owned_forecast_timer_state
  !> Own CPU, vector CPU and elapsed wall times, all in seconds.
  !! Fresh values are positive zero, as in the generated owned namespace.
  !! The caller initializes this record once from FIAT before forecast use.
  !! Native named members replace original global object aliases.
  type, bind(c) :: owned_forecast_timer_state
    real(c_double) :: rstart = 0.0_c_double
    real(c_double) :: rvstart = 0.0_c_double
    real(c_double) :: rtimef = 0.0_c_double
  end type
end module forecast_timer_state_types
