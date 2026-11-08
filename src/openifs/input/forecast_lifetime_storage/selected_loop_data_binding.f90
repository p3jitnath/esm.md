!> Produce loop values from explicit startup views and the selected text groups.
module forecast_selected_loop_binding
  use iso_fortran_env, only: int32, int64, real64
  use forecast_native_loop_data
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  use physics_configuration_text_port, only: find_physics_group, skip_physics_space, physics_space, &
                                             physics_key_character, physics_fold_equal, parse_physics_boolean
  implicit none
  private
  public :: initialize_selected_loop_data, initialize_owned_selected_loop_data
contains
!> The inputs come from one completed vertical, transform, control and clock context.
!! This selected dispatch keeps the19-level,506-real-coefficient spectral specialization.
!! STATE changes only after all admissions and four private allocations succeed.
  integer(int32) function initialize_selected_loop_data(state, up, text) result(status)
    type(native_loop_data), intent(inout) :: state
    type(native_loop_upstream), intent(in) :: up
    character(len=*), intent(in) :: text
    type(native_loop_data) :: pending
    integer(int32) :: nouttype
    integer(int64) :: word
    integer :: allocation_status
    real(real64) :: restart_seconds
    status = 2
    if (up%nconf /= 1 .or. up%lelam /= 0 .or. up%larpegef /= 0 .or. up%lecmwf /= 1 .or. up%lgradsp /= 1) return
    if (up%nproc /= 1 .or. up%myproc /= 1 .or. up%nprtrv /= 1 .or. up%mysetv /= 1 .or. up%npromatr < 0) return
    if (up%nflsur /= 19 .or. up%nflevl /= 19 .or. up%nspec2 /= 506) return
    if (len(text) < 1 .or. len(text) > 262144) return
    if (state%owned_mask /= 0 .or. allocated(state%spvor_flt) .or. allocated(state%spdiv_flt)) return
    if (allocated(state%spub_flt) .or. allocated(state%spvb_flt)) return
    word = transfer(up%vp00, 0_int64)
    if (word <= 0_int64 .or. word > int(z'41cdcd6500000000', int64)) return
    word = transfer(up%tstep, 0_int64)
    if (word < int(z'3ff0000000000000', int64) .or. word > int(z'40f5180000000000', int64)) return
    if (.not. read_parallel_group(text, nouttype)) return
    if (require_empty_physics_group(text, 'NAMGWDIAG') /= 0) return
    if (require_empty_physics_group(text, 'NAMIAU') /= 0) return
    if (require_empty_physics_group(text, 'NAMRLX') /= 0) return
    if (require_empty_physics_group(text, 'NAMVAR') /= 0) return
    if (require_empty_physics_group(text, 'NAMVAREPS') /= 0) return
    if (require_empty_physics_group(text, 'NAMPPC') /= 0) return
    if (require_empty_physics_group(text, 'NAMRES') /= 0) return
    allocate (pending%spvor_flt(up%nflsur, up%nspec2), stat=allocation_status)
    if (allocation_status /= 0) goto900
    pending%spvor_flt = 0.0_real64
    allocate (pending%spdiv_flt(up%nflsur, up%nspec2), stat=allocation_status)
    if (allocation_status /= 0) goto900
    pending%spdiv_flt = 0.0_real64
    allocate (pending%spub_flt(up%nflevl), stat=allocation_status)
    if (allocation_status /= 0) goto900
    pending%spub_flt = 0.0_real64
    allocate (pending%spvb_flt(up%nflevl), stat=allocation_status)
    if (allocation_status /= 0) goto900
    pending%spvb_flt = 0.0_real64
! Keep the ordered source expression and its integer truncation.
    restart_seconds = 48.0_real64*3600.0_real64
    restart_seconds = restart_seconds + 0.5_real64
    restart_seconds = restart_seconds/up%tstep
    pending%nfrres = int(restart_seconds, int32)
    pending%mysetv = up%mysetv
    pending%nouttype = nouttype
    pending%nprtrn = up%nprtrv
    pending%nprtrv = up%nprtrv
    pending%npromatr = up%npromatr
    pending%restart = '0'
    pending%vp00 = up%vp00
    state%lejk = pending%lejk
    state%lgwdiags_on = pending%lgwdiags_on
    state%liau = pending%liau
    state%mysetv = pending%mysetv
    state%nouttype = pending%nouttype
    state%nprtrn = pending%nprtrn
    state%nprtrv = pending%nprtrv
    state%lnudg = pending%lnudg
    state%nrsaccfrq = pending%nrsaccfrq
    state%nfrres = pending%nfrres
    state%lrlxg = pending%lrlxg
    state%restart = pending%restart
    state%npromatr = pending%npromatr
    state%lecv = pending%lecv
    state%lmoderr = pending%lmoderr
    state%lvareps = pending%lvareps
    state%vp00 = pending%vp00
    state%nrests = pending%nrests
    call move_alloc(pending%spvor_flt, state%spvor_flt)
    call move_alloc(pending%spdiv_flt, state%spdiv_flt)
    call move_alloc(pending%spub_flt, state%spub_flt)
    call move_alloc(pending%spvb_flt, state%spvb_flt)
    state%owned_mask = 15_int64
    status = 0
    return
900 continue
! The original failure path visits all four private owners in forward order.
    if (allocated(pending%spvor_flt)) deallocate (pending%spvor_flt)
    if (allocated(pending%spdiv_flt)) deallocate (pending%spdiv_flt)
    if (allocated(pending%spub_flt)) deallocate (pending%spub_flt)
    if (allocated(pending%spvb_flt)) deallocate (pending%spvb_flt)
    status = 1
  end function
  integer(int32) function initialize_owned_selected_loop_data(up, text) result(status)
    type(native_loop_upstream), intent(in) :: up
    character(len=*), intent(in) :: text
    status = initialize_selected_loop_data(owned_loop_data, up, text)
  end function
!> Read the first source-selected uppercase NAMPAR1 and retain member order.
  logical function read_parallel_group(text, nouttype) result(valid)
    character(len=*), intent(in) :: text
    integer(int32), intent(out) :: nouttype
    integer(int32) :: values(5), value
    integer :: cursor, first, last, token_first, key, j
    logical :: good, boolean
    character(len=8), parameter :: keys(5) = [character(len=8) :: 'LSPLIT', 'NFLDIN', 'NSTRIN', 'NSTROUT', 'NOUTTYPE']
    valid = .false.; nouttype = -1; values = [1, 0, 1, 0, -1]
    cursor = find_physics_group(text, 'NAMPAR1', .false.)
    if (cursor == 0) return
    do
      call skip_physics_space(text, cursor)
      if (cursor > len(text)) return
      if (text(cursor:cursor) == ',') then
        cursor = cursor + 1; cycle
      end if
      if (text(cursor:cursor) == '/') then
        if (any(values /= [1, 0, 1, 0, 1])) return
        nouttype = values(5); valid = .true.; return
      end if
      first = cursor
      do while (cursor <= len(text))
        if (.not. physics_key_character(text(cursor:cursor), .false.)) exit
        cursor = cursor + 1
      end do
      last = cursor - 1
      if (last < first) return
      key = 0
      do j = 1, 5
        if (physics_fold_equal(text(first:last), keys(j) (:len_trim(keys(j))))) key = j
      end do
      if (key == 0) return
      call skip_physics_space(text, cursor)
      if (cursor > len(text)) return
      if (text(cursor:cursor) /= '=') return
      cursor = cursor + 1
      call skip_physics_space(text, cursor)
      token_first = cursor
      do while (cursor <= len(text))
        if (physics_space(text(cursor:cursor)) .or. index(',!/', text(cursor:cursor)) /= 0) exit
        cursor = cursor + 1
      end do
      if (cursor == token_first .or. cursor > len(text)) return
      if (key == 1) then
        call parse_physics_boolean(text(token_first:cursor - 1), boolean, good)
        value = merge(1_int32, 0_int32, boolean)
      else
        call read_loop_integer(text(token_first:cursor - 1), value, good)
      end if
      if (.not. good) return
      values(key) = value
    end do
  end function
  subroutine read_loop_integer(token, value, valid)
    character(len=*), intent(in) :: token
    integer(int32), intent(out) :: value
    logical, intent(out) :: valid
    integer(int64) :: magnitude, limit
    integer :: j, digit
    logical :: negative
    valid = .false.; value = 0; magnitude = 0; negative = .false.; j = 1
    if (len(token) < 1) return
    if (token(1:1) == '-') then
      negative = .true.; j = 2
    else if (token(1:1) == '+') then
      j = 2
    end if
    if (j > len(token)) return
    limit = 2147483647_int64
    if (negative) limit = 2147483648_int64
    do while (j <= len(token))
      digit = iachar(token(j:j)) - iachar('0')
      if (digit < 0 .or. digit > 9) return
      if (magnitude > (limit - digit)/10_int64) return
      magnitude = magnitude*10_int64 + digit
      j = j + 1
    end do
    if (negative) magnitude = -magnitude
    value = int(magnitude, int32); valid = .true.
  end subroutine
end module forecast_selected_loop_binding
