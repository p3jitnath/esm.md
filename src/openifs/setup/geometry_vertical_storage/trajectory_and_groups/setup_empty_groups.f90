!> Read empty setup groups with the exact source marker policies.
module forecast_setup_empty_groups
  use, intrinsic :: iso_c_binding, only: c_int, c_char
  implicit none
  private
  public :: require_empty_trajectory_dimension_group
  public :: require_empty_vertical_configuration_group, require_empty_geometry_group
  public :: require_empty_trajectory_dimension_bytes
contains
  !> Match the first line-leading NAMDIM_TRAJ marker, ignoring ASCII case.
  integer(c_int) function require_empty_trajectory_dimension_group(text) result(status)
    character(len=*), intent(in) :: text
    status = empty_group_text(text, 'namdim_traj', .true., 0)
  end function
  !> Match uppercase NAMCVER exactly, with unrestricted leading whitespace.
  integer(c_int) function require_empty_vertical_configuration_group(text) result(status)
    character(len=*), intent(in) :: text
    status = empty_group_text(text, 'NAMCVER', .false., 0)
  end function
  !> Match NAME exactly. The marker must start within columns one through ten.
  integer(c_int) function require_empty_geometry_group(text, name) result(status)
    character(len=*), intent(in) :: text, name
    status = empty_group_text(text, name, .false., 10)
  end function
  !> Same trajectory marker rules for a native one-character file byte array.
  integer(c_int) function require_empty_trajectory_dimension_bytes(text) result(status)
    character(kind=c_char), intent(in) :: text(:)
    status = empty_group_bytes(text, 'namdim_traj', .true., 0)
  end function

  !> Scan line starts only. Comments end only at LF, as in the source.
  integer(c_int) function empty_group_text(text, name, fold_case, column_limit) result(status)
    character(len=*), intent(in) :: text
    character(len=*), intent(in) :: name
    logical, intent(in) :: fold_case
    integer, intent(in) :: column_limit
    integer :: position, candidate, k, n, leading, code
    character :: ch, expected
    logical :: matches
    status = 2_c_int
    n = len(text)
    if (n == 0 .or. len(name) == 0) return
    position = 1
    leading = 0
    do while (position <= n)
      if (column_limit > 0) then
        if (leading >= column_limit) then
          call skip_line()
          cycle
        end if
      end if
      ch = text(position:position)
      if (is_space(ch)) then
        position = position + 1
        leading = leading + 1
        if (iachar(ch) == 10) leading = 0
        cycle
      end if
      if (ch /= '&') then
        call skip_line()
        cycle
      end if
      candidate = position + 1
      matches = .true.
      do k = 1, len(name)
        if (candidate > n) return
        ch = text(candidate:candidate)
        if (fold_case) then
          code = iachar(ch)
          if (code >= 65 .and. code <= 90) ch = achar(code + 32)
        end if
        expected = name(k:k)
        if (ch /= expected) then
          matches = .false.
          exit
        end if
        candidate = candidate + 1
      end do
      if (.not. matches) then
        call skip_line()
        cycle
      end if
      if (candidate > n) return
      ch = text(candidate:candidate)
      if (.not. is_space(ch) .and. ch /= '/' .and. ch /= '!') then
        call skip_line()
        cycle
      end if
      position = candidate
      do while (position <= n)
        ch = text(position:position)
        if (ch == '/') then
          status = 0_c_int
          return
        end if
        if (ch == '!') then
          position = position + 1
          do while (position <= n)
            if (iachar(text(position:position)) == 10) exit
            position = position + 1
          end do
          if (position > n) return
        else if (.not. is_space(ch)) then
          return
        end if
        position = position + 1
      end do
      return
    end do
  contains
    subroutine skip_line()
      ! The first unmatched line is skipped through its LF, not its CR.
      do while (position <= n)
        ch = text(position:position)
        position = position + 1
        if (iachar(ch) == 10) exit
      end do
      leading = 0
    end subroutine skip_line
  end function empty_group_text

  !> Scan line starts only. Comments end only at LF, as in the source.
  integer(c_int) function empty_group_bytes(text, name, fold_case, column_limit) result(status)
    character(kind=c_char), intent(in) :: text(:)
    character(len=*), intent(in) :: name
    logical, intent(in) :: fold_case
    integer, intent(in) :: column_limit
    integer :: position, candidate, k, n, leading, code
    character :: ch, expected
    logical :: matches
    status = 2_c_int
    n = size(text)
    if (n == 0 .or. len(name) == 0) return
    position = 1
    leading = 0
    do while (position <= n)
      if (column_limit > 0) then
        if (leading >= column_limit) then
          call skip_line()
          cycle
        end if
      end if
      ch = text(position)
      if (is_space(ch)) then
        position = position + 1
        leading = leading + 1
        if (iachar(ch) == 10) leading = 0
        cycle
      end if
      if (ch /= '&') then
        call skip_line()
        cycle
      end if
      candidate = position + 1
      matches = .true.
      do k = 1, len(name)
        if (candidate > n) return
        ch = text(candidate)
        if (fold_case) then
          code = iachar(ch)
          if (code >= 65 .and. code <= 90) ch = achar(code + 32)
        end if
        expected = name(k:k)
        if (ch /= expected) then
          matches = .false.
          exit
        end if
        candidate = candidate + 1
      end do
      if (.not. matches) then
        call skip_line()
        cycle
      end if
      if (candidate > n) return
      ch = text(candidate)
      if (.not. is_space(ch) .and. ch /= '/' .and. ch /= '!') then
        call skip_line()
        cycle
      end if
      position = candidate
      do while (position <= n)
        ch = text(position)
        if (ch == '/') then
          status = 0_c_int
          return
        end if
        if (ch == '!') then
          position = position + 1
          do while (position <= n)
            if (iachar(text(position)) == 10) exit
            position = position + 1
          end do
          if (position > n) return
        else if (.not. is_space(ch)) then
          return
        end if
        position = position + 1
      end do
      return
    end do
  contains
    subroutine skip_line()
      ! The first unmatched line is skipped through its LF, not its CR.
      do while (position <= n)
        ch = text(position)
        position = position + 1
        if (iachar(ch) == 10) exit
      end do
      leading = 0
    end subroutine skip_line
  end function empty_group_bytes

  logical function is_space(ch) result(space)
    character, intent(in) :: ch
    integer :: code
    code = iachar(ch)
    space = code == 32 .or. code == 9 .or. code == 10 .or. code == 13
  end function is_space
end module forecast_setup_empty_groups
