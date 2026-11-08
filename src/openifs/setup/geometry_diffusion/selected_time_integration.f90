!> Apply selected SURIP temporal stores to the one canonical model clock.
module forecast_selected_time_integration
  use iso_c_binding, only: c_int, c_int64_t, c_double
  use forecast_model_clock_port, only: forecast_clock_input, forecast_clock
  use forecast_operational_time_integration, only: native_time_integration_upstream
  implicit none
  private
  public :: initialize_time_integration_configuration
contains
  !> Consume the matching selected NAMRIP input and successful owned clock.
  !! Input and optional step use seconds. Only CLOCK%INTEGRATION changes.
  !! Its reserved word, retained solar values and every outer clock field
  !! stay unchanged. No calendar, clock or original TRIP owner is created.
  integer(c_int) function initialize_time_integration_configuration(input, clock, upstream, optional_step) result(status)
    type(forecast_clock_input), intent(in) :: input
    type(forecast_clock), intent(inout) :: clock
    type(native_time_integration_upstream), intent(in) :: upstream
    real(c_double), optional, intent(in) :: optional_step
    integer(c_int) :: j, digit, digits, steps
    integer(c_int64_t) :: word, required
    logical :: spaces
    status = 2
    if (upstream%nconf /= 1 .or. upstream%nsupersede /= 1 .or. upstream%l4dvar /= 0 .or. upstream%reserved /= 0) return
    required = transfer(3600.0_c_double, required)
    if (transfer(input%dt, 0_c_int64_t) /= required .or. transfer(clock%dt, 0_c_int64_t) /= required) return
    if (input%initial_condition /= 0) return
    word = transfer(input%trajectory_dt, word)
    if (word /= required .and. word /= int(z'bff0000000000000', c_int64_t)) return
    word = transfer(clock%initial_seconds_j2000, word)
    if (ibits(word, 52, 11) == 2047_c_int64_t) return
    if (present(optional_step)) then
      if (transfer(optional_step, 0_c_int64_t) /= required) return
    end if
    if (input%stop(1) /= 't') return
    steps = 0; digits = 0; spaces = .false.
    do j = 2, 8
      if (input%stop(j) == ' ') then
        spaces = .true.
      else
        if (spaces) return
        digit = iachar(input%stop(j)) - iachar('0')
        if (digit < 0 .or. digit > 9) return
        digits = digits + 1
        if (digits > 2) return
        steps = steps*10 + digit
      end if
    end do
    if (digits < 1 .or. steps < 1 .or. steps > 25 .or. clock%total_steps /= steps) return
    clock%integration%first_step = 0
    clock%integration%total_steps = steps
    clock%integration%stop = input%stop
    clock%integration%date_time_flags = 0
    clock%integration%initial_iteration = 0
    clock%integration%relative_seconds = 0.0_c_double
    clock%integration%initial_seconds_j2000 = clock%initial_seconds_j2000
    clock%integration%initial_solar = 0.0_c_double
    clock%integration%initial_orbit = 0.0_c_double
    clock%integration%first_dt = input%dt; clock%integration%second_dt = input%dt
    clock%integration%work = 0.0_c_double
    status = 0
  end function
end module forecast_selected_time_integration
