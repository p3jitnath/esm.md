module physics_configuration_text_port
  !! Read the bounded ASCII syntax shared by the selected physics utilities.
  !! Cursors count bytes from one. No helper changes input text or FP state.
  use, intrinsic :: iso_fortran_env, only: int32
  implicit none
  private
  public :: find_physics_group, skip_physics_space, physics_space, physics_key_character
  public :: physics_fold_equal, parse_physics_boolean, parse_physics_small_integer
contains
  pure logical function physics_space(letter) result(space)
    character, intent(in) :: letter
    integer :: code
    code = iachar(letter)
    space = code == 32 .or. code == 9 .or. code == 10 .or. code == 13
  end function
  pure logical function physics_key_character(letter, allow_percent) result(valid)
    character, intent(in) :: letter
    logical, intent(in) :: allow_percent
    integer :: code
    code = iachar(letter)
    valid = (code >= 65 .and. code <= 90) .or. (code >= 97 .and. code <= 122) .or. &
            (code >= 48 .and. code <= 57) .or. code == 95
    if (allow_percent .and. code == 37) valid = .true.
  end function
  pure logical function physics_fold_equal(left, right) result(equal)
    character(len=*), intent(in) :: left, right
    integer :: i, a, b
    equal = .false.
    if (len(left) /= len(right)) return
    do i = 1, len(left)
      a = iachar(left(i:i)); b = iachar(right(i:i))
      if (a >= 65 .and. a <= 90) a = a + 32
      if (b >= 65 .and. b <= 90) b = b + 32
      if (a /= b) return
    end do
    equal = .true.
  end function
  integer function find_physics_group(text, name, allow_comma) result(cursor)
    !! Find the first uppercase exact marker at the first nonblank byte,
    !! within the first ten byte columns. A tab occupies one source column.
    character(len=*), intent(in) :: text, name
    logical, intent(in) :: allow_comma
    integer :: i, n, column, last, code
    cursor = 0
    n = len(text)
    if (n < 1 .or. n > 262144) return
    i = 1; column = 0
    do while (i <= n)
      code = iachar(text(i:i))
      if (code == 10) then
        column = 0; i = i + 1
        cycle
      end if
      column = column + 1
      if (code == 32 .or. code == 9 .or. code == 13) then
        i = i + 1
        cycle
      end if
      if (code == 38 .and. column <= 10) then
        last = i + len(name)
        if (last >= n) return
        if (text(i + 1:last) == name) then
          if (physics_space(text(last + 1:last + 1)) .or. text(last + 1:last + 1) == '/' .or. &
              (allow_comma .and. text(last + 1:last + 1) == ',')) then
            cursor = last + 1
            return
          end if
        end if
      end if
      do while (i <= n)
        if (iachar(text(i:i)) == 10) exit
        i = i + 1
      end do
      i = i + 1; column = 0
    end do
  end function
  subroutine skip_physics_space(text, cursor)
    !! Skip source whitespace and exclamation comments ending at LF.
    character(len=*), intent(in) :: text
    integer, intent(inout) :: cursor
    integer :: n
    n = len(text)
    do while (cursor <= n)
      if (physics_space(text(cursor:cursor))) then
        cursor = cursor + 1
      else if (text(cursor:cursor) == '!') then
        do while (cursor <= n)
          if (iachar(text(cursor:cursor)) == 10) exit
          cursor = cursor + 1
        end do
      else
        return
      end if
    end do
  end subroutine
  subroutine parse_physics_boolean(token, value, valid)
    !! Accept T, F, TRUE or FALSE, optionally between dots, in either case.
    character(len=*), intent(in) :: token
    logical, intent(out) :: value, valid
    integer :: first, last, n
    value = .false.; valid = .false.
    n = len(token)
    if (n == 0) return
    first = 1; last = n
    if (token(1:1) == '.') then
      if (n < 3) return
      if (token(n:n) /= '.') return
      first = 2; last = n - 1
    end if
    if (physics_fold_equal(token(first:last), 't') .or. &
        physics_fold_equal(token(first:last), 'true')) then
      value = .true.; valid = .true.
    else if (physics_fold_equal(token(first:last), 'f') .or. &
             physics_fold_equal(token(first:last), 'false')) then
      valid = .true.
    end if
  end subroutine
  subroutine parse_physics_small_integer(token, value, valid)
    !! Accept one digit from zero through two, with an optional plus sign.
    character(len=*), intent(in) :: token
    integer(int32), intent(out) :: value
    logical, intent(out) :: valid
    integer :: i, code
    value = 0_int32; valid = .false.
    i = 1
    if (len(token) == 2) then
      if (token(1:1) /= '+') return
      i = 2
    else if (len(token) /= 1) then
      return
    end if
    code = iachar(token(i:i)) - 48
    if (code < 0 .or. code > 2) return
    value = int(code, int32); valid = .true.
  end subroutine
end module physics_configuration_text_port
