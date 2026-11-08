!> Apply the exact five-key selected first NAMPAR1 scanner.
module forecast_selected_parallel_namelist
  use iso_fortran_env, only: int32
  use ieee_exceptions, only: ieee_status_type
  use forecast_lifetime_status, only: save_lifetime_status, restore_lifetime_status
  use forecast_parallel_interpolation_controls, only: first_parallel_namelist_values
  use physics_configuration_text_port, only: find_physics_group, skip_physics_space, physics_space, &
                                             physics_key_character, physics_fold_equal, parse_physics_boolean
  implicit none
  private
  public :: apply_selected_parallel_namelist, first_parallel_namelist_values
contains
  integer(int32) function apply_selected_parallel_namelist(text, output) result(status)
    character(*), intent(in) :: text
    type(first_parallel_namelist_values), intent(inout) :: output
    type(ieee_status_type) :: saved
    integer(int32) :: saved_error
    call save_lifetime_status(saved, saved_error)
    status = parse_selected_parallel_body(text, output)
    call restore_lifetime_status(saved, saved_error)
  end function

  !> Mutate only LSPLIT,NFLDIN,NSTRIN,NSTROUT,NOUTTYPE in the existing record.
 !! Text is1:262144 source characters. First uppercase NAMPAR1 starts within
 !! columns1:10. Keys/logical tokens ignore case. Integers are0:2 with optional
 !! plus. Unknown keys, any invalid token and a missing slash return2 without
 !! changing output; repeated valid keys retain the last first-group value.
  integer(int32) function parse_selected_parallel_body(text, output) result(status)
    character(*), intent(in) :: text
    type(first_parallel_namelist_values), intent(inout) :: output
    type(first_parallel_namelist_values) :: pending
    character(8), parameter :: keys(5) = [character(8) :: 'LSPLIT', 'NFLDIN', 'NSTRIN', 'NSTROUT', 'NOUTTYPE']
    integer :: cursor, first, last, row, key, code
    integer(int32) :: number
    logical :: value, valid
    status = 2
    if (len(text) < 1 .or. len(text) > 262144) return
    cursor = find_physics_group(text, 'NAMPAR1', .true.)
    if (cursor == 0) return
    pending = output
    do
      call skip_physics_space(text, cursor)
      if (cursor > len(text)) return
      if (text(cursor:cursor) == ',') then
        cursor = cursor + 1; cycle
      end if
      if (text(cursor:cursor) == '/') exit
      first = cursor
      do while (cursor <= len(text))
        if (.not. physics_key_character(text(cursor:cursor), .true.)) exit
        cursor = cursor + 1
      end do
      if (cursor > len(text)) return
      last = cursor - 1; key = 0
      do row = 1, 5
      if (physics_fold_equal(text(first:last), trim(keys(row)))) then
        key = row; exit
      end if
      end do
      if (key == 0) return
      call skip_physics_space(text, cursor)
      if (cursor > len(text)) return
      if (text(cursor:cursor) /= '=') return
      cursor = cursor + 1
      call skip_physics_space(text, cursor)
      if (cursor > len(text)) return
      first = cursor
      do while (cursor <= len(text))
        if (physics_space(text(cursor:cursor)) .or. index(',!/', text(cursor:cursor)) /= 0) exit
        cursor = cursor + 1
      end do
      if (cursor > len(text)) return
      last = cursor - 1
      if (key == 1) then
        call parse_physics_boolean(text(first:last), value, valid)
        if (.not. valid) return
        pending%lsplit = value
      else
        if (last - first + 1 == 2) then
          if (text(first:first) /= '+') return
          first = first + 1
        elseif (last - first + 1 /= 1) then
          return
        end if
        code = iachar(text(first:first)) - 48
        if (code < 0 .or. code > 2) return
        number = int(code, int32)
        select case (key)
        case (2); pending%nfldin = number
        case (3); pending%nstrin = number
        case (4); pending%nstrout = number
        case (5); pending%nouttype = number
        end select
      end if
    end do
    output = pending
    status = 0
  end function
end module
