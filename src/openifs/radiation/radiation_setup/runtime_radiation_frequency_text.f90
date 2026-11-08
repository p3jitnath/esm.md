!> Read all runtime NAERAD frequency keys and update native schedule fields.
!! NAERAD is the radiation input group. Its full supported text is read twice
!! without rewriting, filtering or changing the separate frozen climate ABI.
module runtime_radiation_frequency_text_port
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_intptr_t
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use ieee_exceptions, only: ieee_get_flag, ieee_set_flag, ieee_underflow, ieee_inexact
  use yoerad, only: terad
  use yoe_uvrad, only: teuvrad
  use physical_constant_setup_port, only: forecast_physical_constants
  use selected_radiation_control_fields_mod, only: radiation_control_selection_record
  use radiation_flux_parameter_setup_port, only: radiation_frequency_choices, &
                                                 radiation_frequency_counts, calculate_radiation_frequency_counts
  implicit none
  private
  public :: runtime_radiation_frequency_selection
  public :: apply_runtime_radiation_frequency_namelist
  public :: initialize_runtime_radiation_frequencies

  !> Hold every supported member without retaining a private machine layout.
  !! VALUES carries the sixteen climate and owner keys, including its three
  !! file names. CRTABLEDIR is the fourth 256-character string. FREQUENCIES
  !! carries NRADFR, NRADPFR, NRADPLA, NRADUV and NLNGR1H as int32 choices.
  !! Negative frequency periods denote hours; positive periods count steps.
  type :: runtime_radiation_frequency_selection
    type(radiation_control_selection_record) :: values
    character(len=256) :: crtabledir
    type(radiation_frequency_choices) :: frequencies
  end type

contains
  !> Apply one complete twenty-one-key NAERAD read to caller-owned OUTPUT.
  !! TEXT is read only, with length one through 262144. The uppercase group
  !! marker must be its line's first token within columns one through ten.
  !! Member names ignore ASCII letter case. Later assignments replace earlier
  !! values. A slash ends the first group; later groups are not consumed.
  !! Integers have an optional sign, at most five digits and magnitude at most
  !! 65535. Logical and quoted-string rules match the frozen source scanner.
  !! All sixteen earlier keys and five frequency keys remain visible. Unknown
  !! names or malformed text return two without changing OUTPUT. Return zero
  !! commits all named values. The enclosing caller establishes the complete
  !! floating environment; this raw parser performs only character/integer work.
  integer(int32) function apply_runtime_radiation_frequency_namelist(text, output) result(status)
    character(len=*), intent(in) :: text
    type(runtime_radiation_frequency_selection), intent(inout) :: output
    type(runtime_radiation_frequency_selection) :: staged
    integer :: cursor, ending, key_start, value_start, key, index, length, parsed
    logical :: valid, logical_value
    character(len=256) :: string_value
    character(len=32) :: name
    status = 2_int32
    ending = len(text)
    if (ending < 1 .or. ending > 262144) return
    cursor = find_group(text)
    if (cursor == 0) return
    staged = output
    do
      call skip_blank(text, cursor)
      if (cursor > ending) return
      if (text(cursor:cursor) == ',') then
        cursor = cursor + 1
        cycle
      end if
      if (text(cursor:cursor) == '/') exit
      key_start = cursor
      do while (cursor <= ending)
        if (.not. key_character(text(cursor:cursor))) exit
        cursor = cursor + 1
      end do
      length = cursor - key_start
      if (length < 1 .or. length > 32) return
      name = lowercase(text(key_start:cursor - 1))
      key = key_number(trim(name))
      if (key == 0) return
      call skip_blank(text, cursor)
      if (cursor > ending) return
      if (text(cursor:cursor) /= '=') return
      cursor = cursor + 1
      call skip_blank(text, cursor)
      if (cursor > ending) return
      if (key == 3 .or. key >= 11 .and. key <= 13) then
        call quoted_string(text, cursor, string_value, valid)
        if (.not. valid) return
        select case (key)
        case (3); staged%crtabledir = string_value
        case (11); staged%values%csolarirradiancefile = string_value
        case (12); staged%values%cghgclimfile = string_value
        case (13); staged%values%cghgtimeseriesfile = string_value
        end select
      else
        value_start = cursor
        do while (cursor <= ending)
          if (delimiter(text(cursor:cursor))) exit
          cursor = cursor + 1
        end do
        if (cursor > ending .or. cursor == value_start) return
        if (key == 2 .or. key == 6 .or. key == 10 .or. (key >= 14 .and. key <= 16)) then
          call logical_token(text(value_start:cursor - 1), logical_value, valid)
          if (.not. valid) return
          select case (key)
          case (2); staged%values%laer3d = logical_value
          case (6); staged%values%lhghg = logical_value
          case (10); staged%values%lepo3ra = logical_value
          case (14); staged%values%lapproxlwupdate = logical_value
          case (15); staged%values%lecompgrid = logical_value
          case (16); staged%values%lsrtm = logical_value
          end select
        else
          call integer_token(text(value_start:cursor - 1), parsed, valid)
          if (.not. valid) return
          select case (key)
          case (1); staged%values%nrproma = parsed
          case (4); staged%values%nhincsol = parsed
          case (5); staged%values%nghgrad = parsed
          case (7); staged%values%nghgcmip = parsed
          case (8); staged%values%nrcp = parsed
          case (9); staged%values%nscen = parsed
          case (17); staged%frequencies%nradfr = int(parsed, int32)
          case (18); staged%frequencies%nradpfr = int(parsed, int32)
          case (19); staged%frequencies%nradpla = int(parsed, int32)
          case (20); staged%frequencies%nraduv = int(parsed, int32)
          case (21); staged%frequencies%nlngr1h = int(parsed, int32)
          end select
        end if
      end if
    end do
    output = staged
    status = 0_int32
  end function

  !> Read source defaults twice and commit the complete runtime frequencies.
  !! TEXT and the native CONSTANTS record are read only. TIMESTEP is the live
  !! model time interval in seconds, finite and between one and 3600.
  !! CONSTANTS%RHOUR must have the exact FP64 value 3600 seconds.
  !! RADIATION and UV are caller-owned native TERAD and TEUVRAD records.
  !! All five argument spans must be disjoint; word-bearing arguments have
  !! eight-byte alignment. The caller supplies valid complete native objects.
  !! Nearest-even rounding and gradual underflow are required. The launcher
  !! establishes the remaining target floating controls before model entry.
  !! Return two refuses with public records unchanged. A schedule refusal
  !! retains its arithmetic-prefix flags. Return zero changes only eight
  !! TERAD int32 fields and UV%NRADUV, without model-array allocation or status forcing.
  integer(int32) function initialize_runtime_radiation_frequencies(text, constants, timestep, radiation, uv) result(status)
    character(len=*), intent(in), target :: text
    type(forecast_physical_constants), intent(in), target :: constants
    real(real64), intent(in), target :: timestep
    type(terad), intent(inout), target :: radiation
    type(teuvrad), intent(inout), target :: uv
    type(runtime_radiation_frequency_selection) :: staged
    type(radiation_frequency_counts) :: counts
    integer(c_intptr_t) :: addresses(5)
    integer(int64) :: lengths(5), timestep_word
    integer :: first, second
    integer(int32) :: parse_status

    status = 2_int32
    if (len(text) < 1 .or. len(text) > 262144) return
    addresses = [transfer(c_loc(radiation), 0_c_intptr_t), transfer(c_loc(uv), 0_c_intptr_t), &
                 transfer(c_loc(constants), 0_c_intptr_t), transfer(c_loc(timestep), 0_c_intptr_t), &
                 transfer(c_loc(text), 0_c_intptr_t)]
    lengths = [storage_size(radiation, kind=int64)/8_int64, storage_size(uv, kind=int64)/8_int64, &
               storage_size(constants, kind=int64)/8_int64, 8_int64, int(len(text), int64)]
    do first = 1, 4
      if (iand(addresses(first), 7_c_intptr_t) /= 0_c_intptr_t) return
    end do
    do first = 1, 4
      do second = first + 1, 5
        if (.not. disjoint(addresses(first), lengths(first), addresses(second), lengths(second))) return
      end do
    end do
    if (.not. supported_floating_mode()) return
    timestep_word = transfer(timestep, 0_int64)
    if (timestep_word < int(z'3FF0000000000000', int64) .or. timestep_word > int(z'40AC200000000000', int64)) return
    if (transfer(constants%rhour, 0_int64) /= int(z'40AC200000000000', int64)) return

    ! The source clears its complete temporary record before setting these defaults.
    staged%values%nhincsol = 0_int32
    staged%values%nghgrad = 0_int32
    staged%values%nscen = 0_int32
    staged%values%nrproma = 0_int32
    staged%values%nrcp = 0_int32
    staged%values%nghgcmip = 0_int32
    staged%values%lhghg = .false.
    staged%values%laer3d = .false.
    staged%values%lepo3ra = .false.
    staged%values%lapproxlwupdate = .true.
    staged%values%lecompgrid = .false.
    staged%values%lsrtm = .true.
    staged%values%cghgclimfile = repeat(achar(0), 256)
    staged%values%cghgtimeseriesfile = repeat(achar(0), 256)
    staged%values%csolarirradiancefile = repeat(achar(0), 256)
    staged%crtabledir = repeat(achar(0), 256)
    staged%frequencies%nradfr = -1_int32
    staged%frequencies%nradpfr = 0_int32
    staged%frequencies%nradpla = 15_int32
    staged%frequencies%nraduv = -1_int32
    staged%frequencies%nlngr1h = 12_int32

    parse_status = apply_runtime_radiation_frequency_namelist(text, staged)
    if (parse_status /= 0_int32) return
    parse_status = apply_runtime_radiation_frequency_namelist(text, staged)
    if (parse_status /= 0_int32) return
    if (.not. staged%values%lsrtm) return
    status = calculate_radiation_frequency_counts(constants%rhour, timestep, staged%frequencies, counts, .true.)
    if (status /= 0_int32) return
    radiation%nradfr = counts%nradfr
    radiation%nradpfr = counts%nradpfr
    radiation%nradpla = counts%nradpla
    radiation%nradnfr = counts%nradnfr
    radiation%nradsfr = counts%nradsfr
    radiation%nrade1h = counts%nrade1h
    radiation%nrade3h = counts%nrade3h
    radiation%nlngr1h = counts%nlngr1h
    uv%nraduv = counts%nraduv
    status = 0_int32
  end function

  !> Compare valid native spans without forming a wrapping end address.
  logical function disjoint(first, first_bytes, second, second_bytes) result(separate)
    integer(c_intptr_t), intent(in) :: first, second
    integer(int64), intent(in) :: first_bytes, second_bytes
    if (first <= second) then
      separate = second - first >= first_bytes
    else
      separate = first - second >= second_bytes
    end if
  end function

  !> Admit nearest rounding and gradual underflow while retaining entry flags.
  logical function supported_floating_mode() result(supported)
    type(ieee_round_type) :: rounding
    real(real64), volatile :: smallest_normal, half, subnormal
    logical :: incoming_underflow, incoming_inexact
    supported = .false.
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) return
    call ieee_get_flag(ieee_underflow, incoming_underflow)
    call ieee_get_flag(ieee_inexact, incoming_inexact)
    smallest_normal = tiny(0.0_real64)
    half = 0.5_real64
    subnormal = smallest_normal*half
    supported = transfer(subnormal, 0_int64) == int(z'0008000000000000', int64)
    call ieee_set_flag(ieee_underflow, incoming_underflow)
    call ieee_set_flag(ieee_inexact, incoming_inexact)
  end function

  integer function find_group(text) result(cursor)
    character(len=*), intent(in) :: text
    integer :: line_start, first, last, ending
    ending = len(text); line_start = 1; cursor = 0
    do while (line_start <= ending)
      first = line_start
      do while (first <= ending)
        if (.not. blank(text(first:first))) exit
        first = first + 1
      end do
      if (first <= ending) then
        if (first - line_start < 10 .and. first + 7 <= ending) then
          if (text(first:first + 6) == '&NAERAD') then
            if (blank(text(first + 7:first + 7)) .or. text(first + 7:first + 7) == ',' .or. text(first + 7:first + 7) == '/') then
              cursor = first + 7
              return
            end if
          end if
        end if
      end if
      last = line_start
      do while (last <= ending)
        if (text(last:last) == achar(10)) exit
        last = last + 1
      end do
      line_start = last + 1
    end do
  end function

  subroutine skip_blank(text, cursor)
    character(len=*), intent(in) :: text
    integer, intent(inout) :: cursor
    do while (cursor <= len(text))
      if (blank(text(cursor:cursor))) then
        cursor = cursor + 1
      else if (text(cursor:cursor) == '!') then
        do while (cursor <= len(text))
          if (text(cursor:cursor) == achar(10)) exit
          cursor = cursor + 1
        end do
      else
        return
      end if
    end do
  end subroutine

  logical function blank(character)
    character(len=1), intent(in) :: character
    blank = character == ' ' .or. character == achar(9) .or. character == achar(10) .or. character == achar(13)
  end function
  logical function delimiter(character)
    character(len=1), intent(in) :: character
    delimiter = blank(character) .or. character == ',' .or. character == '!' .or. character == '/'
  end function
  logical function key_character(character)
    character(len=1), intent(in) :: character
    integer :: code
    code = iachar(character)
    key_character = code >= 65 .and. code <= 90 .or. code >= 97 .and. code <= 122 .or. code >= 48 .and. code <= 57 .or. &
                    character == '_' .or. character == '%'
  end function
  function lowercase(text) result(lower)
    character(len=*), intent(in) :: text
    character(len=len(text)) :: lower
    integer :: position, code
    lower = text
    do position = 1, len(text)
      code = iachar(text(position:position))
      if (code >= 65 .and. code <= 90) lower(position:position) = achar(code + 32)
    end do
  end function
  integer function key_number(name) result(key)
    character(len=*), intent(in) :: name
    character(len=20), parameter :: names(21) = [character(len=20) :: &
                        'nrproma', 'laer3d', 'crtabledir', 'nhincsol', 'nghgrad', 'lhghg', 'nghgcmip', 'nrcp', 'nscen', 'lepo3ra', &
                           'csolarirradiancefile', 'cghgclimfile', 'cghgtimeseriesfile', 'lapproxlwupdate', 'lecompgrid', 'lsrtm', &
                                                 'nradfr', 'nradpfr', 'nradpla', 'nraduv', 'nlngr1h']
    integer :: position
    key = 0
    do position = 1, 21
      if (name == trim(names(position))) then
        key = position
        return
      end if
    end do
  end function
  subroutine integer_token(token, value, valid)
    character(len=*), intent(in) :: token
    integer, intent(out) :: value
    logical, intent(out) :: valid
    integer :: position, sign, digit, first
    value = 0; valid = .false.; first = 1; sign = 1
    if (len(token) < 1) return
    if (token(1:1) == '-' .or. token(1:1) == '+') then
      first = 2
      if (token(1:1) == '-') sign = -1
    end if
    if (len(token) - first + 1 < 1 .or. len(token) - first + 1 > 5) return
    do position = first, len(token)
      digit = iachar(token(position:position)) - 48
      if (digit < 0 .or. digit > 9) return
      value = value*10 + digit
      if (value > 65535) return
    end do
    value = sign*value
    valid = .true.
  end subroutine
  subroutine logical_token(token, value, valid)
    character(len=*), intent(in) :: token
    logical, intent(out) :: value, valid
    integer :: first, last
    character(len=len(token)) :: lower
    lower = lowercase(token); first = 1; last = len(token)
    value = .false.; valid = .false.
    if (last < 1) return
    if (lower(1:1) == '.') then
      if (last < 3) return
      if (lower(last:last) /= '.') return
      first = 2; last = last - 1
    end if
    select case (lower(first:last))
    case ('t', 'true'); value = .true.; valid = .true.
    case ('f', 'false'); value = .false.; valid = .true.
    end select
  end subroutine
  subroutine quoted_string(text, cursor, value, valid)
    character(len=*), intent(in) :: text
    integer, intent(inout) :: cursor
    character(len=256), intent(out) :: value
    logical, intent(out) :: valid
    character(len=1) :: quote, character
    integer :: count
    valid = .false.; value = ''; count = 0
    quote = text(cursor:cursor)
    if (quote /= "'" .and. quote /= '"') return
    cursor = cursor + 1
    do while (cursor <= len(text))
      character = text(cursor:cursor); cursor = cursor + 1
      if (character == achar(0) .or. character == achar(10) .or. character == achar(13)) return
      if (character == quote) then
        if (cursor > len(text)) return
        if (text(cursor:cursor) /= quote) then
          if (.not. delimiter(text(cursor:cursor))) return
          valid = .true.
          return
        end if
        cursor = cursor + 1
      end if
      if (count == 256) return
      count = count + 1
      value(count:count) = character
    end do
  end subroutine
end module runtime_radiation_frequency_text_port
