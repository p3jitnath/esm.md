!> Read the first NAMCOM group into the caller's canonical coupling record.
!> Only NVCOM and LOMLDTH change. The five existing array owners stay untouched.
module forecast_runtime_coupling_common
  use iso_fortran_env, only: int32, int64
  use yomcom, only: TCOM
  use physics_configuration_text_port, only: physics_space, physics_key_character, physics_fold_equal, &
                                             skip_physics_space, parse_physics_boolean
  implicit none
  private
  public :: initialize_runtime_coupling_common_controls
contains
  integer(int32) function initialize_runtime_coupling_common_controls(text, state) result(status)
    character(len=*), intent(in) :: text
    type(TCOM), intent(inout) :: state
    integer :: i, n, end_name, cursor, first, last, key, j
    integer(int32) :: nvcom, value
    logical :: lomldth, valid, found
    status = 2; n = len(text)
    if (n < 1 .or. n > 262144) return
    i = 1; cursor = 0
    do while (i <= n)
      do while (i <= n)
        if (.not. physics_space(text(i:i))) exit
        i = i + 1
      end do
      if (i > n) return
      if (text(i:i) == '&') then
        end_name = i + 6
        if (end_name >= n) return
        if (physics_fold_equal(text(i + 1:end_name), 'NAMCOM')) then
          if (physics_space(text(end_name + 1:end_name + 1)) .or. index('!/', text(end_name + 1:end_name + 1)) /= 0) then
            cursor = end_name + 1; exit
          end if
          if (.not. physics_key_character(text(end_name + 1:end_name + 1), .false.)) return
        end if
      end if
      do while (i <= n)
        if (iachar(text(i:i)) == 10) exit
        i = i + 1
      end do
      i = i + 1
    end do
    if (cursor == 0) return
    nvcom = 2_int32; lomldth = .false.
    do
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      if (text(cursor:cursor) == '/') exit
      if (text(cursor:cursor) == ',') then
        cursor = cursor + 1; cycle
      end if
      first = cursor
      do while (cursor <= n)
        if (.not. physics_key_character(text(cursor:cursor), .false.)) exit
        cursor = cursor + 1
      end do
      last = cursor - 1
      if (last < first) return
      key = 0
      if (physics_fold_equal(text(first:last), 'NVCOM')) key = 1
      if (physics_fold_equal(text(first:last), 'LOMLDTH')) key = 2
      if (key == 0) return
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      if (text(cursor:cursor) /= '=') return
      cursor = cursor + 1
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      if (text(cursor:cursor) == '/') exit
      if (text(cursor:cursor) == ',') then
        cursor = cursor + 1; cycle
      end if
      first = cursor
      do while (cursor <= n)
        if (physics_space(text(cursor:cursor)) .or. index(',!/', text(cursor:cursor)) /= 0) exit
        cursor = cursor + 1
      end do
      if (first == cursor .or. cursor > n) return
      if (key == 1) then
        call parse_integer(text(first:cursor - 1), value, valid)
        if (.not. valid) return
        nvcom = value
      else
        call parse_physics_boolean(text(first:cursor - 1), found, valid)
        if (.not. valid) return
        lomldth = found
      end if
    end do
    state%nvcom = nvcom; state%lomldth = lomldth
    status = 0
  end function
  subroutine parse_integer(token, value, valid)
    character(len=*), intent(in) :: token
    integer(int32), intent(out) :: value
    logical, intent(out) :: valid
    integer(int64) :: magnitude, limit
    integer :: j, digit
    logical :: negative
    magnitude = 0_int64; value = 0_int32; valid = .false.; negative = .false.; j = 1
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
      digit = iachar(token(j:j)) - 48
      if (digit < 0 .or. digit > 9) return
      if (magnitude > (limit - digit)/10_int64) return
      magnitude = magnitude*10_int64 + digit; j = j + 1
    end do
    if (negative) magnitude = -magnitude
    value = int(magnitude, int32); valid = .true.
  end subroutine
end module forecast_runtime_coupling_common
