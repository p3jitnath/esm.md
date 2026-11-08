!> Own all forecast controls and connect the live configuration to the clock.
module forecast_control_configuration
  use iso_c_binding, only: c_int32_t, c_int64_t, c_double, c_char
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use ieee_exceptions, only: ieee_get_flag, ieee_set_flag, ieee_underflow, ieee_inexact
  use physics_configuration_text_port, only: find_physics_group, skip_physics_space, &
                                             physics_key_character, physics_space, physics_fold_equal, parse_physics_boolean
  use forecast_controls_state_types, only: native_forecast_control_namespace, &
                                           native_forecast_controls_state, native_forecast_control_upstream
  use forecast_control_defaults, only: initialize_forecast_control_defaults
  use forecast_model_clock_port, only: forecast_clock_input, forecast_clock, &
                                       initialize_model_clock, initialize_operational_model_clock
  implicit none
  private
  public :: initialize_selected_forecast_controls, initialize_operational_forecast_controls
contains
  !> Construct selected controls for a3600-second step and t1 through t25.
  !! text is a bounded byte string with1 through262144 characters.
  !! upstream contains the file date, seconds in the day and nonnegative print
  !! level. Its GRIB-file count is0 or1. Status0 publishes all named controls
  !! and written clock values. Status2 preserves the complete incoming output.
  !! The caller supplies valid preimages for source-unwritten clock members.
  integer(c_int32_t) function initialize_selected_forecast_controls(text, upstream, output) result(status)
    character(*), intent(in) :: text
    type(native_forecast_control_upstream), intent(in) :: upstream
    type(native_forecast_controls_state), intent(inout) :: output
    status = initialize_controls(text, upstream, output, .false.)
  end function

  !> Construct operational controls for a450-second step.
  !! Historical h1 through h72 stops retain the accepted clock child.
  !! The current t1 through t25 route uses its accepted calendar and step-count
  !! calculation, then stores the actual450-second step in the three source
  !! time-step members. It introduces no new rounded arithmetic. This added
  !! domain requires its own original-source comparison before acceptance.
  integer(c_int32_t) function initialize_operational_forecast_controls(text, upstream, output) result(status)
    character(*), intent(in) :: text
    type(native_forecast_control_upstream), intent(in) :: upstream
    type(native_forecast_controls_state), intent(inout) :: output
    status = initialize_controls(text, upstream, output, .true.)
  end function

  integer(c_int32_t) function initialize_controls(text, upstream, output, operational) result(status)
    character(*), intent(in) :: text
    type(native_forecast_control_upstream), intent(in) :: upstream
    type(native_forecast_controls_state), intent(inout) :: output
    logical, intent(in) :: operational
    type(native_forecast_control_namespace) :: controls
    type(forecast_clock_input) :: input, calendar_input
    type(forecast_clock) :: clock
    character(8) :: stop
    integer :: mask, j
    status = 2
    if (len(text) < 1 .or. len(text) > 262144) return
    if (upstream%nprintlev < 0 .or. upstream%ngribfile < 0 .or. upstream%ngribfile > 1) return
    if (.not. supported_floating_mode()) return
    call initialize_forecast_control_defaults(controls)
    stop = '-9'; mask = 0
    if (.not. read_control_group(text, 'NAMARG', controls, stop, mask, operational)) return
    if (.not. read_control_group(text, 'NAMCT0', controls, stop, mask, operational)) return
    if (.not. read_control_group(text, 'NAMRIP', controls, stop, mask, operational)) return
    if (mask /= 3) return
    controls%lecfpos = 0
    if (controls%nfpos /= 0) controls%lecfpos = 1
    input = output%clock_input
    clock = output%clock
    input%date = upstream%date; input%seconds = upstream%seconds
    input%dt = 3600.0_c_double
    if (operational) input%dt = 450.0_c_double
    do j = 1, 8
      input%stop(j) = stop(j:j)
    end do
    input%initial_condition = 0
    input%trajectory_dt = -1.0_c_double
    if (operational .and. stop(1:1) == 't') then
      calendar_input = input
      calendar_input%dt = 3600.0_c_double
      status = initialize_model_clock(calendar_input, clock)
      if (status /= 0) return
      clock%dt = input%dt
      clock%integration%first_dt = input%dt
      clock%integration%second_dt = input%dt
    else if (operational) then
      status = initialize_operational_model_clock(input, clock)
      if (status /= 0) return
    else
      status = initialize_model_clock(input, clock)
      if (status /= 0) return
    end if
    output%namespace = controls
    output%clock_input = input
    output%clock = clock
    status = 0
  end function

  !> Read one first matching source group into private named storage.
  !! Each assignment is admitted in source order, and later duplicate groups
  !! are ignored. Unknown keys and incomplete values refuse before publication.
  logical function read_control_group(text, name, controls, stop, mask, operational) result(valid)
    character(*), intent(in) :: text, name
    type(native_forecast_control_namespace), intent(inout) :: controls
    character(8), intent(inout) :: stop
    integer, intent(inout) :: mask
    logical, intent(in) :: operational
    integer :: cursor, n, first, last, j, code, width, value
    character(16) :: key
    character :: quote
    character(25) :: string
    logical :: boolean, parsed
    valid = .false.
    cursor = find_physics_group(text, name, .false.)
    if (cursor == 0) return
    n = len(text)
    do
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      if (text(cursor:cursor) == ',') then
        cursor = cursor + 1
        cycle
      end if
      if (text(cursor:cursor) == '/') then
        valid = .true.
        return
      end if
      first = cursor
      do while (cursor <= n)
        if (.not. physics_key_character(text(cursor:cursor), .true.)) then
          if (index('()', text(cursor:cursor)) == 0) exit
        end if
        cursor = cursor + 1
      end do
      last = cursor - 1
      if (last < first .or. last - first + 1 > len(key)) return
      key = ' '
      do j = first, last
        code = iachar(text(j:j))
        if (code >= 97 .and. code <= 122) code = code - 32
        key(j - first + 1:j - first + 1) = achar(code)
      end do
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      if (text(cursor:cursor) /= '=') return
      cursor = cursor + 1
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      width = 0
      if (name == 'NAMARG' .and. key == 'CNMEXP') width = 4
      if (name == 'NAMRIP' .and. key == 'CSTOP') width = 8
      if (operational .and. name == 'NAMCT0' .and. (key == 'CMETER' .or. key == 'CEVENT')) width = 25
      if (width /= 0) then
        quote = text(cursor:cursor)
        if (quote /= "'" .and. quote /= '"') return
        cursor = cursor + 1; first = cursor
        string = ' '
        do while (cursor <= n)
          if (text(cursor:cursor) == quote) exit
          if (iachar(text(cursor:cursor)) == 10 .or. iachar(text(cursor:cursor)) == 13) return
          if (cursor - first >= width) return
          string(cursor - first + 1:cursor - first + 1) = text(cursor:cursor)
          cursor = cursor + 1
        end do
        if (cursor > n) return
        cursor = cursor + 1
      else
        first = cursor
        do while (cursor <= n)
          if (physics_space(text(cursor:cursor))) exit
          if (index(',!/', text(cursor:cursor)) /= 0) exit
          cursor = cursor + 1
        end do
        last = cursor - 1
        if (last < first .or. cursor > n) return
      end if
      select case (name)
      case ('NAMARG')
        select case (key)
        case ('NCONF')
          call read_integer(text(first:last), value, parsed)
          if (.not. parsed) return
          if (value < 1 .or. value > 1) return
          controls%nconf = value
        case ('LECMWF')
          if (.not. full_logical(text(first:last))) return
          call parse_physics_boolean(text(first:last), boolean, parsed)
          if (.not. parsed) return
          value = 0
          if (boolean) value = 1
          if (value < 1 .or. value > 1) return
          controls%lecmwf = value
        case ('CNMEXP')
          controls%cnmexp = string(1:4)
        case default
          return
        end select
      case ('NAMCT0')
        select case (key)
        case ('NFRSDI')
          call read_integer(text(first:last), value, parsed)
          if (.not. parsed) return
          if (value < 1 .or. value > 999999) return
          controls%nfrsdi = value
        case ('N3DINI')
          call read_integer(text(first:last), value, parsed)
          if (.not. parsed) return
          if (value < 0 .or. value > 0) return
          controls%n3dini = value
        case ('LREFOUT')
          if (.not. full_logical(text(first:last))) return
          call parse_physics_boolean(text(first:last), boolean, parsed)
          if (.not. parsed) return
          value = 0
          if (boolean) value = 1
          if (value < 0 .or. value > 0) return
          controls%lrefout = value
        case ('LFDBOP')
          if (.not. full_logical(text(first:last))) return
          call parse_physics_boolean(text(first:last), boolean, parsed)
          if (.not. parsed) return
          value = 0
          if (boolean) value = 1
          if (value < 0 .or. value > 1) return
          controls%lfdbop = value
        case ('NFRHIS')
          call read_integer(text(first:last), value, parsed)
          if (.not. parsed) return
          if (value < 1 .or. value > 999999) return
          controls%nfrhis = value
        case ('NFRPOS')
          call read_integer(text(first:last), value, parsed)
          if (.not. parsed) return
          if (value < 1 .or. value > 999999) return
          controls%nfrpos = value
        case ('NFPOS')
          call read_integer(text(first:last), value, parsed)
          if (.not. parsed) return
          if (value < 0 .or. value > 2) return
          controls%nfpos = value
        case ('NFRDHP')
          call read_integer(text(first:last), value, parsed)
          if (.not. parsed) return
          if (value < 1 .or. value > 999999) return
          controls%nfrdhp = value
        case ('NFRDHFD')
          call read_integer(text(first:last), value, parsed)
          if (.not. parsed) return
          if (value < 1 .or. value > 999999) return
          controls%nfrdhfd = value
        case ('NUNDEFLD')
          call read_integer(text(first:last), value, parsed)
          if (.not. parsed) return
          if (value < -99999999 .or. value > -1) return
          controls%nundefld = value
        case ('LSMSSIG')
          if (.not. full_logical(text(first:last))) return
          call parse_physics_boolean(text(first:last), boolean, parsed)
          if (.not. parsed) return
          value = 0
          if (boolean) value = 1
          if (value < 0 .or. value > 0) return
          controls%lsmssig = value
        case ('LARPEGEF')
          if (.not. operational) return
          if (.not. full_logical(text(first:last))) return
          call parse_physics_boolean(text(first:last), boolean, parsed)
          if (.not. parsed) return
          value = 0
          if (boolean) value = 1
          if (value < 0 .or. value > 0) return
          controls%larpegef = value
        case ('NFRMASSCON')
          if (.not. operational) return
          call read_integer(text(first:last), value, parsed)
          if (.not. parsed) return
          if (value < 1 .or. value > 999999) return
          controls%nfrmasscon = value
        case ('NPOSTS')
          if (.not. operational) return
          call read_integer(text(first:last), value, parsed)
          if (.not. parsed) return
          if (value < 0 .or. value > 0) return
          controls%nposts(0) = value
        case ('NHISTS')
          if (.not. operational) return
          call read_integer(text(first:last), value, parsed)
          if (.not. parsed) return
          if (value < 0 .or. value > 0) return
          controls%nhists(0) = value
        case ('NMASSCONS')
          if (.not. operational) return
          call read_integer(text(first:last), value, parsed)
          if (.not. parsed) return
          if (value < 0 .or. value > 0) return
          controls%nmasscons(0) = value
        case ('NFRCO')
          if (.not. operational) return
          call read_integer(text(first:last), value, parsed)
          if (.not. parsed) return
          if (value < 0 .or. value > 999999) return
          controls%nfrco = value
        case ('NFRDHFZ')
          if (.not. operational) return
          call read_integer(text(first:last), value, parsed)
          if (.not. parsed) return
          if (value < 1 .or. value > 999999) return
          controls%nfrdhfz = value
        case ('NDHFZTS')
          if (.not. operational) return
          call read_integer(text(first:last), value, parsed)
          if (.not. parsed) return
          if (value < 0 .or. value > 0) return
          controls%ndhfzts(0) = value
        case ('NDHFDTS')
          if (.not. operational) return
          call read_integer(text(first:last), value, parsed)
          if (.not. parsed) return
          if (value < 0 .or. value > 0) return
          controls%ndhfdts(0) = value
        case ('CMETER')
          if (.not. operational) return
          controls%cmeter = string(1:25)
        case ('CEVENT')
          if (.not. operational) return
          controls%cevent = string(1:25)
        case default
          return
        end select
      case ('NAMRIP')
        select case (key)
        case ('TSTEP')
          if (.not. admitted_timestep(text(first:last), operational)) return
          mask = ior(mask, 1)
        case ('CSTOP')
          stop = string(1:8)
          mask = ior(mask, 2)
        case default
          return
        end select
      case default
        return
      end select
      if (cursor > n) return
      if (.not. physics_space(text(cursor:cursor))) then
        if (index(',!/', text(cursor:cursor)) == 0) return
      end if
    end do
  end function

  !> Parse the source's signed decimal range without integer overflow.
  subroutine read_integer(token, value, valid)
    character(*), intent(in) :: token
    integer, intent(out) :: value
    logical, intent(out) :: valid
    integer(c_int64_t) :: magnitude
    integer :: cursor, digit, sign
    value = 0; valid = .false.; cursor = 1; sign = 1; magnitude = 0
    if (len(token) == 0) return
    if (token(1:1) == '-' .or. token(1:1) == '+') then
      if (token(1:1) == '-') sign = -1
      cursor = 2
    end if
    if (cursor > len(token)) return
    do while (cursor <= len(token))
      digit = iachar(token(cursor:cursor)) - 48
      if (digit < 0 .or. digit > 9) return
      magnitude = magnitude*10 + digit
      if (magnitude > 99999999_c_int64_t) return
      cursor = cursor + 1
    end do
    value = int(magnitude)*sign
    valid = .true.
  end subroutine

  logical function full_logical(token) result(valid)
    character(*), intent(in) :: token
    valid = .false.
    select case (len(token))
    case (4, 5)
      if (token(1:1) == '.') return
    case (6, 7)
      if (token(1:1) /= '.' .or. token(len(token):len(token)) /= '.') return
    case default
      return
    end select
    valid = .true.
  end function

  logical function admitted_timestep(token, operational) result(valid)
    character(*), intent(in) :: token
    logical, intent(in) :: operational
    integer :: prefix, j
    valid = .false.
    prefix = 4
    if (operational) prefix = 3
    if (len(token) < prefix) return
    if (operational) then
      if (token(1:3) /= '450') return
    else
      if (token(1:4) /= '3600') return
    end if
    if (len(token) > prefix) then
      if (token(prefix + 1:prefix + 1) /= '.') return
      do j = prefix + 2, len(token)
        if (token(j:j) /= '0') return
      end do
    end if
    valid = .true.
  end function

  !> Reuse the accepted exact-subnormal admission without changing flags.
  !! The launcher owns the complete target floating-point environment.
  logical function supported_floating_mode() result(supported)
    type(ieee_round_type) :: rounding
    real(c_double), volatile :: smallest_normal, half, subnormal
    logical :: incoming_underflow, incoming_inexact
    supported = .false.
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) return
    call ieee_get_flag(ieee_underflow, incoming_underflow)
    call ieee_get_flag(ieee_inexact, incoming_inexact)
    smallest_normal = tiny(0.0_c_double)
    half = 0.5_c_double
    subnormal = smallest_normal*half
    supported = transfer(subnormal, 0_c_int64_t) == int(z'0008000000000000', c_int64_t)
    call ieee_set_flag(ieee_underflow, incoming_underflow)
    call ieee_set_flag(ieee_inexact, incoming_inexact)
  end function
end module forecast_control_configuration
