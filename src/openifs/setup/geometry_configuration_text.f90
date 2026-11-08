!> Read bounded geometry configuration text without file or numeric-library calls.
module forecast_geometry_configuration_text
  use iso_c_binding, only: c_int32_t, c_int64_t
  implicit none
  private
  public :: read_grid_dimension_overrides, require_grid_configuration_group
contains
  !> Recognize the four source whitespace characters.
  logical function space(character)
    character(len=1), intent(in) :: character
    space = index(' '//achar(9)//achar(10)//achar(13), character) > 0
  end function
  !> Fold ASCII letters only, preserving underscores and punctuation.
  function lower(text) result(value)
    character(len=*), intent(in) :: text
    character(len=len(text)) :: value
    integer :: j, code
    value = text
    do j = 1, len(text)
      code = iachar(text(j:j))
      if (code >= 65 .and. code <= 90) value(j:j) = achar(code + 32)
    end do
  end function
  !> Skip source whitespace and exclamation comments at the current cursor.
  subroutine skip_space(text, cursor)
    character(len=*), intent(in) :: text
    integer, intent(inout) :: cursor
    do while (cursor <= len(text))
      if (space(text(cursor:cursor))) then
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
  !> Find the first exact line-leading group with its source boundary rule.
  integer function first_group(text, name) result(cursor)
    character(len=*), intent(in) :: text, name
    integer :: i, j, k, n, last
    cursor = 0; n = len(text)
    if (n < 1 .or. n > 262144) return
    i = 1
    do while (i <= n)
      j = i
      do while (j <= n)
        if (text(j:j) == achar(10)) exit
        if (.not. space(text(j:j))) exit
        j = j + 1
      end do
      last = j + len(name)
      if (last < n .and. j <= n) then
        if (text(j:j) == '&') then
          if (lower(text(j + 1:last)) == lower(name)) then
            k = last + 1
            if (space(text(k:k)) .or. text(k:k) == '/' .or. text(k:k) == '!') then
              cursor = k
              return
            end if
          end if
        end if
      end if
      do while (i <= n)
        if (text(i:i) == achar(10)) exit
        i = i + 1
      end do
      i = i + 1
    end do
  end function
  !> Read a complete scalar key and its required equal sign.
  logical function read_key(text, cursor, key)
    character(len=*), intent(in) :: text
    integer, intent(inout) :: cursor
    character(len=*), intent(out) :: key
    integer :: first, code
    read_key = .false.; key = ''
    call skip_space(text, cursor)
    first = cursor
    do while (cursor <= len(text))
      code = iachar(text(cursor:cursor))
      if (.not. ((code >= 65 .and. code <= 90) .or. (code >= 97 .and. code <= 122) .or. &
                 (code >= 48 .and. code <= 57) .or. code == 95)) exit
      cursor = cursor + 1
    end do
    if (cursor == first .or. cursor - first > len(key)) return
    key = lower(text(first:cursor - 1))
    call skip_space(text, cursor)
    if (cursor > len(text)) return
    if (text(cursor:cursor) /= '=') return
    cursor = cursor + 1
    call skip_space(text, cursor)
    read_key = .true.
  end function
  !> Return the next complete scalar token and leave its delimiter in place.
  logical function read_token(text, cursor, token)
    character(len=*), intent(in) :: text
    integer, intent(inout) :: cursor
    character(len=*), intent(out) :: token
    integer :: first
    token = ''; read_token = .false.; first = cursor
    do while (cursor <= len(text))
      if (space(text(cursor:cursor)) .or. index(',/!', text(cursor:cursor)) > 0) exit
      cursor = cursor + 1
    end do
    if (cursor > len(text) .or. cursor == first .or. cursor - first > len(token)) return
    token = text(first:cursor - 1)
    read_token = .true.
  end function
  !> Decode an exact signed decimal int32 with checked int64 intermediates.
  logical function integer_token(token, value)
    character(len=*), intent(in) :: token
    integer(c_int32_t), intent(out) :: value
    integer(c_int64_t) :: magnitude, limit
    integer :: j, n, negative, digit
    integer_token = .false.; value = 0; n = len_trim(token)
    if (n < 1) return
    j = 1; negative = 0
    if (token(j:j) == '-' .or. token(j:j) == '+') then
      if (token(j:j) == '-') negative = 1
      j = j + 1
    end if
    if (j > n) return
    magnitude = 0; limit = 2147483647_c_int64_t + negative
    do while (j <= n)
      digit = iachar(token(j:j)) - 48
      if (digit < 0 .or. digit > 9) return
      if (magnitude > (limit - digit)/10_c_int64_t) return
      magnitude = 10_c_int64_t*magnitude + digit
      j = j + 1
    end do
    if (negative == 1) magnitude = -magnitude
    value = int(magnitude, c_int32_t)
    integer_token = .true.
  end function
  !> Read the first NAMDIM into twelve values and a twelve-bit presence mask.
  !! Outputs change only after complete first-group acceptance. Repeated
  !! fields retain the last value; unsupported names/expressions refuse.
  recursive integer(c_int32_t) function read_grid_dimension_overrides(text, values, presence) result(status)
    character(len=*), intent(in) :: text
    integer(c_int32_t), intent(inout) :: values(12), presence
    character(len=12), parameter :: names(12) = [character(len=12) :: &
                                                 'ndglg', 'ndlon', 'ndguxg', 'ndluxg', 'nflevg', 'niolevg', 'nvarmax', &
                                                 'nmsmax', 'nsmax', 'ncmax', 'nproma', 'nstencilwide']
    character(len=32) :: key
    character(len=262144) :: token
    integer(c_int32_t) :: work(12), mask, parsed
    integer :: cursor, j, which
    status = 2
    cursor = first_group(text, 'namdim')
    if (cursor == 0) return
    work = 0; mask = 0
    do
      call skip_space(text, cursor)
      if (cursor > len(text)) return
      if (text(cursor:cursor) == '/') exit
      if (text(cursor:cursor) == ',') then
        cursor = cursor + 1
        cycle
      end if
      if (.not. read_key(text, cursor, key)) return
      which = 0
      do j = 1, 12
        if (key == names(j)) then
          which = j
          exit
        end if
      end do
      if (which == 0) return
      if (.not. read_token(text, cursor, token)) return
      if (.not. integer_token(token, parsed)) return
      work(which) = parsed
      mask = ibset(mask, which - 1)
    end do
    values = work
    presence = mask
    status = 0
  end function
  !> Require the selected first NAMGEM, preserving its original accepted tokens.
  !! grid_type0 admits only signed all-zero NHTYP values; grid_type2 admits
  !! literal NHTYP=2 and FALSE or .FALSE. for LNONHYD_GEOM.
  recursive integer(c_int32_t) function require_grid_configuration_group(text, grid_type) result(status)
    character(len=*), intent(in) :: text
    integer(c_int32_t), intent(in) :: grid_type
    character(len=32) :: key
    character(len=262144) :: token
    integer(c_int32_t) :: parsed
    integer :: cursor
    status = 2
    if (grid_type /= 0 .and. grid_type /= 2) return
    cursor = first_group(text, 'namgem')
    if (cursor == 0) return
    do
      call skip_space(text, cursor)
      if (cursor > len(text)) return
      if (text(cursor:cursor) == '/') exit
      if (text(cursor:cursor) == ',') then
        cursor = cursor + 1
        cycle
      end if
      if (.not. read_key(text, cursor, key)) return
      if (.not. read_token(text, cursor, token)) return
      if (key == 'nhtyp') then
        if (grid_type == 0) then
          if (.not. integer_token(token, parsed)) return
          if (parsed /= 0) return
        else
          if (trim(token) /= '2') return
        end if
      else if (grid_type == 2 .and. key == 'lnonhyd_geom') then
        if (len_trim(token) > 7) return
        if (lower(trim(token)) /= 'false' .and. lower(trim(token)) /= '.false.') return
      else
        return
      end if
    end do
    status = 0
  end function
end module forecast_geometry_configuration_text
