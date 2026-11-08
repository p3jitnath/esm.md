module forecast_periodic_output_schedule_port
  !! Select saved-output visits from explicit steps, times or a frequency.
  !! The calculation retains the generated MONIO_T order and rounding.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  implicit none
  private
  public :: select_periodic_output
contains

  subroutine select_periodic_output(first_output_index, first_step, last_step, dt, output, &
                                    output_value, frequency, requests, status, minutes, condition, active)
    !! output(i) represents index first_output_index+i-1 and changes only
    !! after all inputs pass. requests(1) is a signed count, followed by
    !! that many values. Positive counts select explicit indices. Negative
    !! counts select negative hours, with optional nonnegative minutes.
    !! dt is seconds per step. frequency converts selected indices to model
    !! steps. Optional condition and active flags default to true.
    integer(int32), intent(in) :: first_output_index, first_step, last_step
    real(real64), intent(in) :: dt
    integer(int32), intent(inout) :: output(:)
    integer(int32), intent(in) :: output_value, frequency, requests(:)
    integer(int32), intent(out) :: status
    integer(int32), optional, intent(in) :: minutes(:)
    logical, optional, intent(in) :: condition, active
    integer(int64) :: word, product, request_count, last_output_index
    integer(int32) :: count, value, effective_frequency, step, index, selected_value
    integer :: j
    real(real64) :: bounded_dt, minute_value, time_value
    logical :: select_condition

    status = 2
    if (first_output_index < 0 .or. first_output_index > 1000000) return
    if (first_step < 0 .or. last_step < first_step .or. last_step > 1000000) return
    word = transfer(dt, word)
    if (ibits(word, 52, 11) == 2047) return
    if (size(output, kind=int64) > 1000000_int64) return
    last_output_index = int(first_output_index, int64) + size(output, kind=int64) - 1
    if (size(output) == 0 .and. first_output_index == 0) return
    if (size(requests) < 1) return
    count = requests(1)
    if (count < (-1000000) .or. count > 1000000) return
    request_count = abs(int(count, int64))
    if (size(requests, kind=int64) < request_count + 1) return
    if (count < 0) then
      if (frequency < 0) return
      if (present(minutes)) then
        if (size(minutes, kind=int64) < request_count + 1) return
      end if
    end if
    do j = 1, int(request_count)
      value = requests(j + 1)
      if (count >= 0) then
        product = int(value, int64)*int(frequency, int64)
        if (product < (-2147483647_int64 - 1_int64) .or. product > 2147483647_int64) return
      else
        if (value > 0 .or. value == (-2147483647_int32 - 1_int32)) return
        if (present(minutes)) then
          if (minutes(j + 1) < 0) return
        end if
      end if
    end do

    bounded_dt = abs(dt)
    if (bounded_dt < tiny(0.0_real64)) bounded_dt = tiny(0.0_real64)
    selected_value = output_value
    if (present(active)) then
      if (.not. active) selected_value = 0
    end if
    select_condition = .true.
    if (present(condition)) select_condition = condition
    output = 0
    effective_frequency = max(frequency, 1_int32)
    if (count == 0) then
      if (select_condition) then
        do step = first_step, last_step
          if (mod(step, effective_frequency) /= 0) cycle
          index = step/effective_frequency
          call store(index)
        end do
      end if
    else if (count > 0) then
      do j = 1, count
        value = requests(j + 1)
        step = value*frequency
        if (step < first_step .or. step > last_step) cycle
        call store(value)
      end do
    else
      do j = 1, int(request_count)
        minute_value = 0.0_real64
        if (present(minutes)) minute_value = real(minutes(j + 1), real64)/60.0_real64
        time_value = real(-requests(j + 1), real64)
        time_value = time_value + minute_value
        time_value = time_value*3600.0_real64
        time_value = time_value*real(frequency, real64)
        time_value = time_value/bounded_dt
        time_value = min(time_value, 2147483647.0_real64)
        step = nint(time_value, int32)
        if (step < first_step .or. step > last_step) cycle
        index = step/effective_frequency
        call store(index)
      end do
    end if
    status = 0
  contains
    subroutine store(requested_index)
      integer(int32), intent(in) :: requested_index
      integer(int64) :: position
      if (requested_index < first_output_index .or. int(requested_index, int64) > last_output_index) return
      position = int(requested_index, int64) - first_output_index + 1
      output(position) = selected_value
    end subroutine
  end subroutine
end module
