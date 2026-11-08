!> Read the supported transform groups from bounded configuration text.
!! The input is ASCII text of at most262144bytes. The first uppercase group
!! marker must start in columns1 through10. No input byte is changed.
module forecast_transform_configuration
  use iso_fortran_env, only: int32
  implicit none
  private
  public :: require_empty_transform_group, require_operational_transform_group
contains
  !> Return0 for the selected empty group and2 for unsupported text.
  !! selector0 reads NAMTRANS0 and selector1 reads NAMTRANS. Comments end at LF.
  integer(int32) function require_empty_transform_group(text, selector) result(status)
    character(len=*), intent(in) :: text
    integer(int32), intent(in) :: selector
    integer :: position
    status = 2
    if (selector /= 0 .and. selector /= 1) return
    if (selector == 0) then
      position = find_group_body(text, 'NAMTRANS0')
    else
      position = find_group_body(text, 'NAMTRANS')
    end if
    if (position == 0) return
    call skip_space_and_comments(text, position)
    if (position > len(text)) return
    if (text(position:position) == '/') status = 0
  end function

  !> Accept the first NAMTRANS with empty body or source false assignments.
  !! LUSEFLT and LFFTW names and FALSE values allow either letter case.
  !! The uppercase group name, first-group choice and separators are retained.
  integer(int32) function require_operational_transform_group(text) result(status)
    character(len=*), intent(in) :: text
    integer :: position, n, start, stop
    logical :: dotted
    status = 2
    position = find_group_body(text, 'NAMTRANS')
    if (position == 0) return
    n = len(text)
    do
      call skip_space_and_comments(text, position)
      if (position > n) return
      if (text(position:position) == '/') then
        status = 0
        return
      end if
      start = position
      do while (position <= n)
        if (.not. letter(text(position:position))) exit
        position = position + 1
      end do
      stop = position - 1
      if (stop < start) return
      if (.not. same_letters(text(start:stop), 'LUSEFLT') .and. &
          .not. same_letters(text(start:stop), 'LFFTW')) return
      call skip_space_and_comments(text, position)
      if (position > n) return
      if (text(position:position) /= '=') return
      position = position + 1
      call skip_space_and_comments(text, position)
      if (position > n) return
      dotted = text(position:position) == '.'
      if (dotted) position = position + 1
      if (position + 4 > n) return
      if (.not. same_letters(text(position:position + 4), 'FALSE')) return
      position = position + 5
      if (dotted) then
        if (position > n) return
        if (text(position:position) /= '.') return
        position = position + 1
      end if
      if (position > n) return
      select case (iachar(text(position:position)))
      case (47)
        status = 0
        return
      case (44, 9, 10, 13, 32)
        position = position + 1
      case (33)
        ! Leave the comment marker for the next bounded whitespace scan.
      case default
        return
      end select
    end do
  end function

  integer function find_group_body(text, name) result(position)
    character(len=*), intent(in) :: text, name
    integer :: i, column, j, n, g, code
    position = 0
    n = len(text)
    g = len(name)
    if (n < 1 .or. n > 262144) return
    i = 1
    column = 0
    do while (i <= n)
      code = iachar(text(i:i))
      if (code == 10) then
        column = 0
        i = i + 1
        cycle
      end if
      if (code == 9 .or. code == 13 .or. code == 32) then
        column = column + 1
        i = i + 1
        cycle
      end if
      if (code == 38 .and. column < 10) then
        j = i + 1
        if (j + g > n) return
        if (text(j:j + g - 1) == name) then
          j = j + g
          code = iachar(text(j:j))
          if (space(code) .or. code == 47 .or. code == 33) then
            position = j
            return
          end if
        end if
      end if
      do while (i <= n)
        if (iachar(text(i:i)) == 10) exit
        i = i + 1
      end do
      if (i <= n) i = i + 1
      column = 0
    end do
  end function

  subroutine skip_space_and_comments(text, position)
    character(len=*), intent(in) :: text
    integer, intent(inout) :: position
    integer :: n, code
    n = len(text)
    do while (position <= n)
      code = iachar(text(position:position))
      if (space(code)) then
        position = position + 1
      else if (code == 33) then
        do while (position <= n)
          if (iachar(text(position:position)) == 10) exit
          position = position + 1
        end do
      else
        return
      end if
    end do
  end subroutine

  logical function space(code)
    integer, intent(in) :: code
    space = code == 9 .or. code == 10 .or. code == 13 .or. code == 32
  end function

  logical function letter(value)
    character, intent(in) :: value
    integer :: code
    code = iachar(value)
    letter = (code >= 65 .and. code <= 90) .or. (code >= 97 .and. code <= 122)
  end function

  logical function same_letters(left, right)
    character(len=*), intent(in) :: left, right
    integer :: i, a, c
    same_letters = .false.
    if (len(left) /= len(right)) return
    do i = 1, len(left)
      a = iachar(left(i:i))
      c = iachar(right(i:i))
      if (a >= 97 .and. a <= 122) a = a - 32
      if (c >= 97 .and. c <= 122) c = c - 32
      if (a /= c) return
    end do
    same_letters = .true.
  end function
end module forecast_transform_configuration
