!> Apply the complete runtime sixteen-key NAERAD source parser.
!! The first uppercase group marker, token order, last assignment and bounded
!! text/string rules are unchanged. The caller establishes floating mode.
module forecast_runtime_radiation_owner_namelist
  use iso_fortran_env, only: int32, int64
  use radiation_climate_selection_port, only: radiation_climate_selection_record
  implicit none
  private
  public :: apply_radiation_owner_namelist
contains
  integer(int32) function apply_radiation_owner_namelist(text, output) result(status)
    character(len=*), intent(in) :: text
    type(radiation_climate_selection_record), intent(inout) :: output
    type(radiation_climate_selection_record) :: staged
    integer :: cursor, ending, key_start, value_start, key, length, parsed
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
        if (key == 2 .or. key == 6 .or. key == 10 .or. key >= 14) then
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
          end select
        end if
      end if
    end do
    output = staged
    status = 0_int32
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
    character(len=32) :: lower
    integer :: position, code
    lower = text
    do position = 1, len(text)
      code = iachar(text(position:position))
      if (code >= 65 .and. code <= 90) lower(position:position) = achar(code + 32)
    end do
  end function
  integer function key_number(name) result(key)
    character(len=*), intent(in) :: name
    character(len=20), parameter :: names(16) = [character(len=20) :: &
                        'nrproma', 'laer3d', 'crtabledir', 'nhincsol', 'nghgrad', 'lhghg', 'nghgcmip', 'nrcp', 'nscen', 'lepo3ra', &
                             'csolarirradiancefile', 'cghgclimfile', 'cghgtimeseriesfile', 'lapproxlwupdate', 'lecompgrid', 'lsrtm']
    integer :: position, limit
    limit = 16
    key = 0
    do position = 1, limit
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
    character(len=7) :: lower
    character(len=32) :: folded
    value = .false.; valid = .false.
    last = len(token)
    if (last < 1 .or. last > 7) return
    folded = lowercase(token); lower = folded(:7); first = 1
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
end module forecast_runtime_radiation_owner_namelist
