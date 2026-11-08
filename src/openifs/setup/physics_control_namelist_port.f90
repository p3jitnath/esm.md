module physics_control_namelist_port
  !! Apply the eight admitted NAEPHY controls to an owned native TEPHY.
  use, intrinsic :: iso_fortran_env, only: int32
  use yoephy, only: tephy
  use physics_configuration_text_port
  implicit none
  private
  public :: apply_selected_physics_namelist
contains
  integer(int32) function apply_selected_physics_namelist(text, output) result(status)
    !! Return zero on success or two before any destination mutation.
    !! Logical and scheme controls are dimensionless. Text and output are
    !! complete disjoint native owners. The first selected group is used.
    character(len=*), intent(in) :: text
    type(tephy), intent(inout) :: output
    type(tephy) :: staged
    integer :: cursor, first, last, key, n
    integer(int32) :: integer_value
    logical :: logical_value, valid
    character(len=13), parameter :: keys(8) = [character(len=13) :: &
                                               'nalbedoscheme', 'lephys', 'lslphy', 'leradi', 'lelaiv', 'leo3ch', &
                                               'lesnml', 'nsnmlws']
    status = 2_int32
    n = len(text)
    if (n < 1 .or. n > 262144) return
    cursor = find_physics_group(text, 'NAEPHY', .true.)
    if (cursor == 0) return
    staged = output
    do
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      if (text(cursor:cursor) == ',') then
        cursor = cursor + 1
        cycle
      end if
      if (text(cursor:cursor) == '/') then
        output = staged
        status = 0_int32
        return
      end if
      first = cursor
      do while (cursor <= n)
        if (.not. physics_key_character(text(cursor:cursor), .true.)) exit
        cursor = cursor + 1
      end do
      if (cursor > n) return
      last = cursor - 1
      key = 0
      do key = 1, 8
        if (physics_fold_equal(text(first:last), trim(keys(key)))) exit
      end do
      if (key > 8) return
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      if (text(cursor:cursor) /= '=') return
      cursor = cursor + 1
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      first = cursor
      do while (cursor <= n)
        if (physics_space(text(cursor:cursor))) exit
        if (index(',!/', text(cursor:cursor)) /= 0) exit
        cursor = cursor + 1
      end do
      if (cursor > n) return
      last = cursor - 1
      if (key == 1 .or. key == 8) then
        call parse_physics_small_integer(text(first:last), integer_value, valid)
      else
        call parse_physics_boolean(text(first:last), logical_value, valid)
      end if
      if (.not. valid) return
      select case (key)
      case (1); staged%nalbedoscheme = integer_value
      case (2); staged%lephys = logical_value
      case (3); staged%lslphy = logical_value
      case (4); staged%leradi = logical_value
      case (5); staged%lelaiv = logical_value
      case (6); staged%leo3ch = logical_value
      case (7); staged%lesnml = logical_value
      case (8); staged%nsnmlws = integer_value
      end select
    end do
  end function
end module physics_control_namelist_port
