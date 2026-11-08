!> Pass the actual first NAMCA group to its unchanged source producer.
module forecast_native_cellular_text_adapter
  use iso_fortran_env, only: int32, int64
  use forecast_native_physics_factory_state, only: native_physics_context_factory_state
  use forecast_native_startup_storage, only: native_forecast_startup_storage
  use forecast_native_physics_context_bindings, only: prepare_native_cellular_controls
  use physics_configuration_text_port, only: find_physics_group
  implicit none
  private
  public :: prepare_native_cellular_controls_from_text
contains
  !> Split retained configuration bytes into native Fortran input records.
 !! FACTORY is the same final-address physics owner; STARTUP owns the genuine
 !! prefix text. Both remain at their final TARGET addresses. Only the existing
 !! child mutates the cellular controls. No scientific default is supplied here.
 !! At most262144 bytes of record storage are allocated. Source line contents,
 !! quotes, comments and the exact first NAMCA marker remain unchanged.
 !! Status1 is private allocation failure,2 is admission refusal; other child
 !! statuses pass through. The scratch records are released after that child.
  integer(int32) function prepare_native_cellular_controls_from_text(factory, startup) result(status)
    type(native_physics_context_factory_state), target, intent(inout) :: factory
    type(native_forecast_startup_storage), target, intent(in) :: startup
    character(len=:), allocatable :: records(:)
    integer :: n, cursor, first, last, nlines, width, line, start, code
    status = 2
    if (.not. allocated(startup%initial)) return
    if (.not. allocated(startup%initial%prefix)) return
    n = startup%initial%prefix%configuration_bytes
    if (n < 1 .or. n > 262144) return
    if (n > len(startup%initial%prefix%configuration_text)) return
    associate (text => startup%initial%prefix%configuration_text)
      cursor = find_physics_group(text(1:n), 'NAMCA', .false.)
      if (cursor == 0) return
      first = cursor - 6
      if (first < 1 .or. text(first:first) /= '&') return
      ! Keep all subsequent lines: the existing Fortran NAMELIST reader ends at
      ! this actual group's terminator, including quoted slashes and comments.
      nlines = 1; width = 1; start = first
      do cursor = first, n
        if (iachar(text(cursor:cursor)) == 10) then
          width = max(width, cursor - start)
          nlines = nlines + 1; start = cursor + 1
        end if
      end do
      width = max(width, n - start + 1)
      if (int(width, int64)*int(nlines, int64) > 262144_int64) return
      allocate (character(len=width) :: records(nlines), stat=code)
      if (code /= 0) then
        status = 1; return
      end if
      records = ' '; line = 1; start = first
      do cursor = first, n
        if (iachar(text(cursor:cursor)) == 10) then
          if (cursor > start) records(line) = text(start:cursor - 1)
          line = line + 1; start = cursor + 1
        end if
      end do
      if (start <= n) records(line) = text(start:n)
    end associate
    status = prepare_native_cellular_controls(factory, startup, records)
  end function
end module
