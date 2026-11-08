!> Initialize the owned timer data through the public FIAT clock.
module forecast_timer_initialization_port
  use iso_c_binding, only: c_int, c_double
  use forecast_timer_state_types, only: owned_forecast_timer_state
  implicit none
  private
  public :: initialize_forecast_timers
  ! This is the official FIAT USER_CLOCK optional-argument interface.
  interface
    subroutine user_clock(pelapsed_time, pelapsed_time_since, pvector_cp, ptotal_cp)
      import c_double
      real(c_double), intent(out), optional :: pelapsed_time, pvector_cp, ptotal_cp
      real(c_double), intent(inout), optional :: pelapsed_time_since
    end subroutine
  end interface
contains
  !> Observe one public clock call into the three named timer fields.
  !! TIMERS is stable writable INOUT native storage, separate from live
  !! external service state. All three values use FP64 seconds.
  !! The second optional elapsed-since argument is absent. The remaining
  !! arguments point directly to RTIMEF, RVSTART and RSTART respectively.
  !! Return 0 means the public call completed. Its natural floating-point
  !! flags and errno remain visible; no value or status is substituted.
  !! The enclosing caller establishes the floating-point mode once.
  integer(c_int) function initialize_forecast_timers(timers) result(status)
    type(owned_forecast_timer_state), intent(inout) :: timers
    call user_clock(pelapsed_time=timers%rtimef, pvector_cp=timers%rvstart, ptotal_cp=timers%rstart)
    status = 0_c_int
  end function
end module forecast_timer_initialization_port
