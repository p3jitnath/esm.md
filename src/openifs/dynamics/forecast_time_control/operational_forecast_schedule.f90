!> Select source forecast visits from named native controls.
!! Time intervals are in seconds. Indices and event switches are dimensionless.
module forecast_operational_schedule
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_int32_t, c_int64_t, c_double, c_char
  use forecast_model_clock_port, only: forecast_clock
  use forecast_controls_state_types, only: native_forecast_control_namespace
  use physics_configuration_text_port, only: find_physics_group, skip_physics_space, &
                                             physics_space, physics_fold_equal, physics_key_character
  implicit none
  private
  public :: forecast_output_switches, forecast_stage_controls, forecast_stage_result
  public :: initialize_operational_output_switches, select_operational_forecast_stage
  public :: select_runtime_regular_forecast_stage

  !> Complete source NAMCT1 values, with one explicit zero padding word.
  type, bind(C) :: forecast_output_switches
    integer(c_int32_t) :: n1pos = 1, n1his = 1, n1sdi = 1, n1res = 1, n1sfxhis = 0
    integer(c_int32_t) :: n1gdi = 1, n1dhp = 1, n1dhfg = 1, n1dhfz = 1, n1dhfd = 1
    integer(c_int32_t) :: n1cfu = 1, n1xfu = 1, n1masscon = 1, lrfilaf = 1, lwrspec = 1, reserved = 0
  end type

  !> Borrow these actual source flag values from the one model.
  !! No model record, clock or numerical field is owned or copied here.
  type :: forecast_stage_controls
    logical :: ltwotl = .false., lmse = .false., lsddh = .false.
    logical :: lhdpr = .false., lhdefg = .false., lhdefz = .false., lhdefd = .false., lwcou = .false.
  end type

  !> Source 96-byte stage result, including every explicitly zero reserved byte.
  type, bind(C) :: forecast_stage_result
    integer(c_int32_t) :: step = 0, stop = 0, postprocessing = 0, history = 0, surface_history = 0
    integer(c_int32_t) :: grid_norm = 0, spectral_norm = 0, global_diagnostics = 0
    integer(c_int32_t) :: zonal_diagnostics = 0, regional_diagnostics = 0, diagnostic_print = 0, mass_check = 0
    real(c_double) :: interval = 0.0_c_double, event_time = 0.0_c_double
    character(kind=c_char) :: configuration(9) = '0', reserved_char(7) = achar(0, kind=c_char)
    integer(c_int32_t) :: output_active = 0, collection_active = 0
    integer(c_int64_t) :: reserved_tail = 0
  end type
contains
  !> Read the bounded source NAMCT1 scalar subset and publish only on success.
  !! TEXT is immutable ASCII,1:262144 bytes. CONFIGURATION supplies NCONF=1
  !! and the actual dimensionless LARPEGEF word,0 or1. OUTPUT is a disjoint
  !! complete64-byte owner. Source defaults, duplicate assignments, exact
  !! uppercase group matching, case-insensitive keys and boolean spellings
  !! are retained. Unknown keys and unsupported values return2 atomically.
  integer(int32) function initialize_operational_output_switches(text, configuration, output) result(status)
    character(len=*), intent(in) :: text
    type(native_forecast_control_namespace), intent(in) :: configuration
    type(forecast_output_switches), intent(inout) :: output
    type(forecast_output_switches) :: pending
    integer(int32) :: values(15), value
    integer :: cursor, key_start, key_end, value_start, value_end, key, n, i, code, digit, sign
    integer(int64) :: magnitude
    character(len=9), parameter :: keys(15) = [character(len=9) :: &
                                               'N1POS', 'N1HIS', 'N1SDI', 'N1RES', 'N1SFXHIS', 'N1GDI', 'N1DHP', 'N1DHFG', &
                                               'N1DHFZ', 'N1DHFD', 'N1CFU', 'N1XFU', 'N1MASSCON', 'LRFILAF', 'LWRSPEC']
    status = 2
    n = len(text)
    if (n < 1 .or. n > 262144) return
    if (configuration%nconf /= 1) return
    if (configuration%larpegef < 0 .or. configuration%larpegef > 1) return
    values = [1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    cursor = find_physics_group(text, 'NAMCT1', .false.)
    if (cursor == 0) return
    do
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      if (text(cursor:cursor) == ',') then
        cursor = cursor + 1
        cycle
      end if
      if (text(cursor:cursor) == '/') exit
      key_start = cursor
      do while (cursor <= n)
        if (.not. physics_key_character(text(cursor:cursor), .true.) .and. &
            text(cursor:cursor) /= '(' .and. text(cursor:cursor) /= ')') exit
        cursor = cursor + 1
      end do
      key_end = cursor - 1
      if (key_end < key_start) return
      key = 0
      do i = 1, 15
        if (physics_fold_equal(text(key_start:key_end), trim(keys(i)))) then
          key = i
          exit
        end if
      end do
      if (key == 0) return
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      if (text(cursor:cursor) /= '=') return
      cursor = cursor + 1
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      value_start = cursor
      do while (cursor <= n)
        if (physics_space(text(cursor:cursor)) .or. text(cursor:cursor) == ',' .or. &
            text(cursor:cursor) == '!' .or. text(cursor:cursor) == '/') exit
        cursor = cursor + 1
      end do
      if (cursor > n) return
      value_end = cursor - 1
      if (value_end < value_start) return
      if (key <= 13) then
        i = value_start
        sign = 1
        if (text(i:i) == '-' .or. text(i:i) == '+') then
          if (text(i:i) == '-') sign = -1
          i = i + 1
        end if
        if (i > value_end) return
        magnitude = 0_int64
        do while (i <= value_end)
          digit = iachar(text(i:i)) - iachar('0')
          if (digit < 0 .or. digit > 9) return
          magnitude = magnitude*10_int64 + int(digit, int64)
          if (magnitude > 99999999_int64) return
          i = i + 1
        end do
        value = int(magnitude, int32)*sign
        if (value < 0 .or. value > 1) return
      else
        i = value_start
        code = value_end
        if (text(i:i) == '.') then
          if (code - i + 1 < 3) return
          if (text(code:code) /= '.') return
          i = i + 1
          code = code - 1
        end if
        if (physics_fold_equal(text(i:code), 'TRUE')) then
          value = 1
        else if (physics_fold_equal(text(i:code), 'FALSE')) then
          value = 0
        else
          return
        end if
      end if
      values(key) = value
    end do
    pending%n1pos = values(1); pending%n1his = values(2); pending%n1sdi = values(3)
    pending%n1res = values(4); pending%n1sfxhis = values(5); pending%n1gdi = values(6)
    pending%n1dhp = values(7); pending%n1dhfg = values(8); pending%n1dhfz = values(9)
    pending%n1dhfd = values(10); pending%n1cfu = values(11); pending%n1xfu = values(12)
    pending%n1masscon = values(13)
    pending%lrfilaf = iand(values(14), configuration%larpegef)
    pending%lwrspec = values(15); pending%reserved = 0
    output = pending
    status = 0
  end function

  !> Preserve the existing source-qualified eight-step,450-second selection.
  !! The current STEP is separate from immutable source NSTART in CLOCK.
  !! Only regular events with empty explicit lists are admitted. Flags and
  !! intervals are source-ordered; complete output is unchanged on refusal.
  integer(int32) function select_operational_forecast_stage(configuration, clock, model, &
                                                            switches, step, fullpos_eligible, output) result(status)
    type(native_forecast_control_namespace), intent(in) :: configuration
    type(forecast_clock), intent(in) :: clock
    type(forecast_stage_controls), intent(in) :: model
    type(forecast_output_switches), intent(in) :: switches
    integer(int32), intent(in) :: step
    logical, intent(in) :: fullpos_eligible
    type(forecast_stage_result), intent(inout) :: output
    status = 2
    if (clock%integration%first_step /= 0 .or. clock%integration%total_steps /= 8) return
    if (transfer(clock%integration%first_dt, 0_int64) /= transfer(450.0_real64, 0_int64)) return
    status = select_regular_stage(configuration, clock, model, switches, step, fullpos_eligible, output)
  end function

  !> Extend only live stop/time metadata while preserving the same regular policy.
  !! CLOCK contains actual NSTART,NSTOP,TSTEP; the supported stop is0:576.
  !! This source-only runtime extension does not qualify an operational forecast.
  integer(int32) function select_runtime_regular_forecast_stage(configuration, clock, model, &
                                                                switches, step, fullpos_eligible, output) result(status)
    type(native_forecast_control_namespace), intent(in) :: configuration
    type(forecast_clock), intent(in) :: clock
    type(forecast_stage_controls), intent(in) :: model
    type(forecast_output_switches), intent(in) :: switches
    integer(int32), intent(in) :: step
    logical, intent(in) :: fullpos_eligible
    type(forecast_stage_result), intent(inout) :: output
    status = 2
    if (clock%integration%first_step /= 0) return
    if (clock%integration%total_steps < 0 .or. clock%integration%total_steps > 576) return
    if (iand(ishft(transfer(clock%integration%first_dt, 0_int64), -52), 2047_int64) == 2047_int64) return
    if (.not. (clock%integration%first_dt > 0.0_real64)) return
    status = select_regular_stage(configuration, clock, model, switches, step, fullpos_eligible, output)
  end function

  integer(int32) function select_regular_stage(configuration, clock, model, switches, step, &
                                               fullpos_eligible, output) result(status)
    type(native_forecast_control_namespace), intent(in) :: configuration
    type(forecast_clock), intent(in) :: clock
    type(forecast_stage_controls), intent(in) :: model
    type(forecast_output_switches), intent(in) :: switches
    integer(int32), intent(in) :: step
    logical, intent(in) :: fullpos_eligible
    type(forecast_stage_result), intent(inout) :: output
    type(forecast_stage_result) :: pending
    integer(int32) :: frequency(10), enabled(10), events(10), stop
    integer :: i
    real(real64) :: base, product
    status = 2
    stop = clock%integration%total_steps
    if (configuration%nconf /= 1 .or. step < 0 .or. step > stop) return
    frequency = [configuration%nfrpos, configuration%nfrhis, configuration%nfrsfxhis, &
                 configuration%nfrgdi, configuration%nfrsdi, configuration%nfrdhfg, configuration%nfrdhfz, &
                 configuration%nfrdhfd, configuration%nfrdhp, configuration%nfrmasscon]
    if (any(frequency < 1) .or. any(frequency > 999999)) return
    if (configuration%nposts(0) /= 0 .or. configuration%nhists(0) /= 0 .or. &
        configuration%nsfxhists(0) /= 0 .or. configuration%ngdits(0) /= 0 .or. &
        configuration%nsdits(0) /= 0 .or. configuration%ndhfgts(0) /= 0 .or. &
        configuration%ndhfzts(0) /= 0 .or. configuration%ndhfdts(0) /= 0 .or. &
        configuration%ndhpts(0) /= 0 .or. configuration%nmasscons(0) /= 0) return
    enabled = [switches%n1pos, switches%n1his, switches%n1sfxhis, switches%n1gdi, switches%n1sdi, &
               1_c_int32_t, 1_c_int32_t, 1_c_int32_t, 1_c_int32_t, switches%n1masscon]
    if (any(enabled < 0) .or. any(enabled > 1)) return
    if (.not. model%lmse) enabled(3) = 0
    enabled(6) = merge(1, 0, model%lsddh .and. model%lhdefg)
    enabled(7) = merge(1, 0, model%lsddh .and. model%lhdefz)
    enabled(8) = merge(1, 0, model%lsddh .and. model%lhdefd)
    enabled(9) = merge(1, 0, model%lsddh .and. model%lhdpr)
    do i = 1, 10
      events(i) = 0
      if (mod(step, frequency(i)) == 0) events(i) = enabled(i)
    end do
    if (frequency(10) > stop) events(10) = 0
    pending%step = step; pending%stop = stop
    pending%postprocessing = events(1); pending%history = events(2); pending%surface_history = events(3)
    pending%grid_norm = events(4); pending%spectral_norm = events(5)
    pending%global_diagnostics = events(6); pending%zonal_diagnostics = events(7)
    pending%regional_diagnostics = events(8); pending%diagnostic_print = events(9); pending%mass_check = events(10)
    base = clock%integration%first_dt
    pending%interval = base
    if (step /= 0 .and. .not. model%ltwotl) pending%interval = 2.0_real64*base
    product = real(step, real64)*base
    pending%event_time = product + 0.5_real64
    pending%configuration = '0'
    if (events(2) /= 0) then
      pending%configuration(1) = 'A'
      if (events(3) /= 0) pending%configuration(1) = 'Q'
    else if (events(3) /= 0) then
      pending%configuration(1) = 'S'
    end if
    pending%reserved_char = achar(0, kind=c_char)
    pending%output_active = merge(1, 0, fullpos_eligible .and. events(1) /= 0)
    pending%collection_active = merge(1, 0, model%lsddh .or. model%lwcou)
    if (step < stop) then
      pending%configuration(2:4) = 'A'
      pending%configuration(7:9) = 'A'
    else if (pending%collection_active /= 0 .or. pending%output_active /= 0) then
      pending%configuration(2:4) = 'A'
    end if
    pending%reserved_tail = 0
    output = pending
    status = 0
  end function
end module forecast_operational_schedule
