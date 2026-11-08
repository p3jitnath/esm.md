!> Form the source periodic-output schedule from the actual root clock.
!! A schedule element is an integer event value. The caller owns the output view.
module forecast_periodic_output_schedule
  use iso_fortran_env, only: int32, int64
  use forecast_model_clock_port, only: forecast_clock
  use forecast_output_request_types, only: increment_output_counter
  use yomhook, only: dr_hook
  implicit none
  private
  public :: make_periodic_output_schedule
contains
  !> Clear the full view, then assign events in increasing source-step order.
  !! start_index is the reset-index of schedule(1); interval is positive, in time steps.
  !! Optional condition defaults true. Optional active=false publishes zero event values.
  !! The unsupported source last-step mode returns 2 before writes. No clock field mutates.
  integer(int32) function make_periodic_output_schedule(start_index, clock, schedule, event_value, interval, &
                                                        last_step, hook_enabled, calls, condition, active) result(status)
    integer(int32), intent(in) :: start_index, event_value, interval
    type(forecast_clock), intent(in) :: clock
    integer(int32), intent(inout) :: schedule(:)
    logical, intent(in) :: last_step, hook_enabled
    integer(int64), intent(inout) :: calls
    logical, intent(in), optional :: condition, active
    integer(int64) :: first, last, k, index, quotient, dt_bits, exponent
    integer(int32) :: value
    real(kind(1.0d0)) :: hook_handle
    logical :: enabled
    status = 2
    first = clock%first_step
    last = clock%total_steps
    if (start_index < 0 .or. first < 0 .or. last > 1000000 .or. interval < 1 .or. last_step) return
    if (size(schedule, kind=int64) > 1000000) return
    dt_bits = transfer(clock%dt, dt_bits)
    exponent = ibits(dt_bits, 52, 11)
    if (exponent == 0 .or. exponent == 2047) return
    enabled = .true.
    if (present(condition)) enabled = condition
    value = event_value
    if (present(active)) then
      if (.not. active) value = 0
    end if
    if (hook_enabled) call dr_hook('MONIO_T', 0, hook_handle)
    schedule = 0
    if (enabled .and. first <= last) then
      do k = first, last
        quotient = k/int(interval, int64)
        if (mod(k, int(interval, int64)) /= 0) cycle
        index = quotient - int(start_index, int64) + 1
        if (index < 1 .or. index > size(schedule, kind=int64)) cycle
        schedule(index) = value
      end do
    end if
    call increment_output_counter(calls)
    if (hook_enabled) call dr_hook('MONIO_T', 1, hook_handle)
    status = 0
  end function
end module forecast_periodic_output_schedule
