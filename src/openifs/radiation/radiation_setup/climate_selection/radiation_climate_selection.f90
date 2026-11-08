!> Read the selected NAERAD controls and resolve their climate file names.
module radiation_climate_selection_port
  use iso_fortran_env, only: int32, int64
  use selected_radiation_control_fields_mod, only: radiation_control_selection_record
  implicit none
  private
  public :: radiation_climate_selection_record, radiation_climate_upstream_record
  public :: apply_selected_radiation_namelist, select_radiation_climate_files

  !> Readonly source flags used to select climate defaults.
  type :: radiation_climate_upstream_record
    logical :: lephys, larpegef, lrayfm, ozone_lgp, lopt_scalar
  end type
  !> Native selected values and three explicitly bounded resolved file paths.
  !! File names have256characters. Paths have512characters with a zero-byte
  !! tail; PATH_LENGTHS gives the consumed characters, excluding that tail.
  type :: radiation_climate_selection_record
    type(radiation_control_selection_record) :: values
    character(len=256) :: crtabledir
    character(len=512) :: paths(3)
    integer(int64) :: path_lengths(3)
  end type
contains
  !> Parse the first literal uppercase NAERAD marker in source columns1:10.
  !! TEXT is readonly, length1:262144. Member names ignore ASCII letter case.
  !! OUTPUT is caller-owned INOUT and changes only after a complete parse.
  !! The selected13keys are admitted; RUNTIME_PREFIX adds the three source
  !! owner switches. Integers have optional sign, at most5digits and magnitude
  !! at most65535. Logical tokens are T,F,TRUE,FALSE, optionally dot-bounded.
  !! Quoted strings admit doubled quotes, at most256characters and no line
  !! break or zero byte. Unknown keys and malformed tokens return2 without
  !! changing OUTPUT. A closing slash returns0; later groups are ignored.
  !! These are integer and character operations. The enclosing setup admits
  !! its complete floating environment before invoking this raw parser.
  integer(int32) function apply_selected_radiation_namelist(text, output, runtime_prefix) result(status)
    character(len=*), intent(in) :: text
    type(radiation_climate_selection_record), intent(inout) :: output
    logical, intent(in) :: runtime_prefix
    type(radiation_climate_selection_record) :: staged
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
      key = key_number(trim(name), runtime_prefix)
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

  !> Apply climate defaults,one NAERAD read,and source DATA path selection.
  !! DATA_DIRECTORY is the readonly decoded DATA environment value, with
  !! length0:512 and no zero byte. Its trailing spaces are removed. UPSTREAM
  !! holds five live native logicals. OUTPUT is caller-owned and commits
  !! only after parsing and all path bounds succeed; failure returns2.
  !! Source defaults and file strings are explicit assignments. No captured
  !! constructed record, original module data or numerical body is used.
  integer(int32) function select_radiation_climate_files(text, data_directory, upstream, output, runtime_prefix) result(status)
    character(len=*), intent(in) :: text, data_directory
    type(radiation_climate_upstream_record), intent(in) :: upstream
    type(radiation_climate_selection_record), intent(inout) :: output
    logical, intent(in) :: runtime_prefix
    type(radiation_climate_selection_record) :: staged
    integer(int32) :: parse_status, default_nrproma
    integer :: file_index, scenario, name_length, data_length, path_length
    character(len=256) :: names(3)
    character(len=80), parameter :: series_names(11) = [character(len=80) :: &
                                                        'greenhouse_gas_timeseries_CMIP3_A1B_46r1.nc', &
                                                        'greenhouse_gas_timeseries_CMIP3_A2_46r1.nc', &
                                                        'greenhouse_gas_timeseries_CMIP3_B1_46r1.nc', &
                                                        'greenhouse_gas_timeseries_CMIP5_RCP3PD_46r1.nc', &
                                                        'greenhouse_gas_timeseries_CMIP5_RCP45_46r1.nc', &
                                                        'greenhouse_gas_timeseries_CMIP5_RCP6_46r1.nc', &
                                                        'greenhouse_gas_timeseries_CMIP5_RCP85_46r1.nc', &
                                                        'greenhouse_gas_timeseries_CMIP6_SSP126_CFC11equiv_47r1.nc', &
                                                        'greenhouse_gas_timeseries_CMIP6_SSP245_CFC11equiv_47r1.nc', &
                                                        'greenhouse_gas_timeseries_CMIP6_SSP370_CFC11equiv_47r1.nc', &
                                                        'greenhouse_gas_timeseries_CMIP6_SSP585_CFC11equiv_47r1.nc']
    status = 2_int32
    if (len(data_directory) > 512) return
    if (index(data_directory, achar(0)) /= 0) return
    staged%values%lhghg = upstream%lephys .and. .not. upstream%larpegef
    staged%values%nhincsol = merge(4_int32, 0_int32, staged%values%lhghg)
    staged%values%nghgcmip = merge(6_int32, 0_int32, staged%values%lhghg)
    staged%values%nghgrad = -1_int32
    staged%values%nrcp = 3_int32
    staged%values%nscen = 1_int32
    staged%values%laer3d = .true.
    staged%values%lepo3ra = upstream%ozone_lgp
    default_nrproma = merge(-8_int32, 511_int32, upstream%lopt_scalar)
    staged%values%nrproma = default_nrproma
    staged%values%lapproxlwupdate = .true.
    staged%values%lecompgrid = .true.
    staged%values%lsrtm = .true.
    staged%values%csolarirradiancefile = ''
    staged%values%cghgclimfile = ''
    staged%values%cghgtimeseriesfile = ''
    staged%crtabledir = './'
    staged%paths = repeat(achar(0), 512)
    staged%path_lengths = 0_int64
    parse_status = apply_selected_radiation_namelist(text, staged, runtime_prefix)
    if (parse_status /= 0_int32) return
    if (staged%values%nghgrad < 0) then
      if ((upstream%lephys .and. .not. upstream%larpegef) .or. upstream%lrayfm) then
        staged%values%nghgrad = merge(20_int32, 21_int32, staged%values%lepo3ra)
      else
        staged%values%nghgrad = 0_int32
      end if
    end if
    if (staged%values%nrproma == 0) staged%values%nrproma = default_nrproma
    staged%values%nrproma = abs(staged%values%nrproma)
    if (staged%values%csolarirradiancefile == '') &
      staged%values%csolarirradiancefile = 'total_solar_irradiance_CMIP6_47r1.nc'
    if (staged%values%cghgclimfile == '') staged%values%cghgclimfile = 'greenhouse_gas_climatology_48r1.nc'
    if (staged%values%cghgtimeseriesfile == '') then
      select case (staged%values%nghgcmip)
      case (0)
        if (staged%values%nscen < 1 .or. staged%values%nscen > 3) return
        scenario = staged%values%nscen
      case (5, 6)
        if (staged%values%nrcp < 1 .or. staged%values%nrcp > 4) return
        scenario = merge(3, 7, staged%values%nghgcmip == 5) + staged%values%nrcp
      case default
        return
      end select
      staged%values%cghgtimeseriesfile = trim(series_names(scenario))
    end if
    names = [staged%values%csolarirradiancefile, staged%values%cghgclimfile, staged%values%cghgtimeseriesfile]
    data_length = len_trim(data_directory)
    do file_index = 1, 3
      name_length = len_trim(names(file_index))
      if (name_length < 1) return
      if (names(file_index) (1:1) == '.' .or. names(file_index) (1:1) == '/' .or. data_length == 0) then
        path_length = name_length
        staged%paths(file_index) (:path_length) = names(file_index) (:name_length)
      else
        path_length = data_length + 9 + name_length
        if (path_length > 511) return
        staged%paths(file_index) (:data_length) = data_directory(:data_length)
        staged%paths(file_index) (data_length + 1:data_length + 9) = '/ifsdata/'
        staged%paths(file_index) (data_length + 10:path_length) = names(file_index) (:name_length)
      end if
      staged%path_lengths(file_index) = int(path_length, int64)
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
  integer function key_number(name, runtime_prefix) result(key)
    character(len=*), intent(in) :: name
    logical, intent(in) :: runtime_prefix
    character(len=20), parameter :: names(16) = [character(len=20) :: &
                        'nrproma', 'laer3d', 'crtabledir', 'nhincsol', 'nghgrad', 'lhghg', 'nghgcmip', 'nrcp', 'nscen', 'lepo3ra', &
                             'csolarirradiancefile', 'cghgclimfile', 'cghgtimeseriesfile', 'lapproxlwupdate', 'lecompgrid', 'lsrtm']
    integer :: position, limit
    limit = 13
    if (runtime_prefix) limit = 16
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
    value = .false.; valid = .false.
    last = len(token)
    if (last < 1 .or. last > 7) return
    lower = lowercase(token); first = 1
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
end module
