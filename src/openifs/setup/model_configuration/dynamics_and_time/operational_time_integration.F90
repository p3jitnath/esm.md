!> Apply the selected operational SURIP stores to the canonical live clock.
module forecast_operational_time_integration
  use iso_c_binding, only: c_int, c_int64_t, c_double
  use forecast_model_clock_port, only: forecast_clock_input, forecast_clock
  implicit none
  private
  public :: native_time_integration_upstream, initialize_operational_time_integration_configuration
!> Store the four source upstream words; switches use canonical0 or1.
  type, bind(C) :: native_time_integration_upstream
    integer(c_int) :: nconf, nsupersede, l4dvar, reserved
  end type
contains
!> Initialize only the existing clock's temporal integration fields.
!! INPUT is the read-only canonical40-byte clock input. CLOCK is the existing
!! caller-owned forecast_clock with INOUT intent; only its INTEGRATION changes.
!! UPSTREAM supplies NCONF=1,NSUPERSEDE=1,L4DVAR=0 and reserved0. OPTIONAL_STEP
!! is absent or a read-only FP64 value equal in bits to the live450-second step.
!! Times are in seconds; total_steps and iteration flags are dimensionless.
!! INPUT and CLOCK come from the same successful live forecast-control setup.
!! Current t1:t25 and historical h1:h72 require that producer's matching count.
!! The original formatted internal I5 READ uses the public Fortran runtime.
!! The caller establishes nearest-even rounding with gradual underflow.
!! Status2 refuses unsupported input before mutation; status0 applies every
!! source temporal store. Integration%reserved and retained_solar stay intact.
!! No second clock, calendar calculation, climatology owner or original module
!! is created. The parent borrows this same integration record for YRRIP users.
 integer(c_int) function initialize_operational_time_integration_configuration(input, clock, upstream, optional_step) result(status)
    type(forecast_clock_input), intent(in) :: input
    type(forecast_clock), intent(inout) :: clock
    type(native_time_integration_upstream), intent(in) :: upstream
    real(c_double), optional, intent(in) :: optional_step
    integer(c_int64_t) :: step_word, word
    integer(c_int) :: hours, digits, digit, j, stop_steps, admitted_stop, source_stop_value
    character(len=8) :: source_stop
    logical :: spaces
    status = 2_c_int
    if (upstream%nconf /= 1 .or. upstream%nsupersede /= 1 .or. upstream%l4dvar /= 0 .or. upstream%reserved /= 0) return
    step_word = int(z'407c200000000000', c_int64_t)
    if (transfer(input%dt, 0_c_int64_t) /= step_word) return
    if (input%initial_condition /= 0) return
    word = transfer(input%trajectory_dt, 0_c_int64_t)
    if (word /= step_word .and. word /= int(z'bff0000000000000', c_int64_t)) return
    if (transfer(clock%dt, 0_c_int64_t) /= step_word) return
    word = transfer(clock%initial_seconds_j2000, 0_c_int64_t)
    if (iand(shiftr(word, 52), int(z'7ff', c_int64_t)) == int(z'7ff', c_int64_t)) return
    if (present(optional_step)) then
      if (transfer(optional_step, 0_c_int64_t) /= step_word) return
    end if
    ! Validate the bounded spelling and clock agreement before the runtime read.
    ! The same original I5 conversion then supplies the admitted integer value.
    admitted_stop = 0_c_int
    digits = 0_c_int
    spaces = .false.
    do j = 2, 8
      if (input%stop(j) == ' ') then
        spaces = .true.
      else
        if (spaces) return
        digit = iachar(input%stop(j)) - iachar('0')
        if (digit < 0 .or. digit > 9) return
        digits = digits + 1_c_int
        if (digits > 2) return
        admitted_stop = admitted_stop*10_c_int + digit
      end if
    end do
    if (digits == 0) return
    if (input%stop(1) == 't') then
      if (admitted_stop < 1 .or. admitted_stop > 25) return
      if (clock%total_steps /= admitted_stop) return
      if (clock%integration%total_steps /= clock%total_steps) return
      if (any(clock%integration%stop /= input%stop)) return
    else
      if (input%stop(1) /= 'h') return
      if (admitted_stop < 1 .or. admitted_stop > 72) return
      if (clock%total_steps /= ishft(admitted_stop, 3)) return
    end if
    do j = 1, 8
      source_stop(j:j) = input%stop(j)
    end do
    ! Original SURIP lines149/152 use this public formatted internal I/O operation.
    ! Its runtime effects are natural; there is no errno or floating-status repair.
    read (unit=source_stop(2:), fmt='(I5)') source_stop_value
    if (input%stop(1) == 't') then
      stop_steps = source_stop_value
    else
      hours = source_stop_value
      stop_steps = ishft(hours, 3)
    end if
    ! These groups map exactly to the original TRIP temporal prefix. The four
    ! retained next-step solar values and the explicit reserved word are unwritten.
    clock%integration%first_step = 0_c_int
    clock%integration%total_steps = stop_steps
    clock%integration%stop = input%stop
    clock%integration%date_time_flags = 0_c_int
    clock%integration%initial_iteration = 0_c_int
    clock%integration%relative_seconds = 0.0_c_double
    clock%integration%initial_seconds_j2000 = clock%initial_seconds_j2000
    clock%integration%initial_solar = 0.0_c_double
    clock%integration%initial_orbit = 0.0_c_double
    clock%integration%first_dt = input%dt
    clock%integration%second_dt = input%dt
    clock%integration%work = 0.0_c_double
    status = 0_c_int
  end function
end module forecast_operational_time_integration
