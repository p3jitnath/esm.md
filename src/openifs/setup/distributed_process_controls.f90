!> Read the thirteen source process controls through bounded native text.
module forecast_distributed_process_controls
  use iso_c_binding, only: c_int, c_int64_t
  use physics_configuration_text_port, only: skip_physics_space, physics_space, physics_key_character, &
                                             physics_fold_equal, parse_physics_boolean
  implicit none
  private
  public :: native_process_control, read_distributed_process_controls
!> Original NAMPAR0 switches and counts, with no global module state.
  type :: native_process_control
    logical :: lxml_stats, lstats, ldetailed_stats, lsyncstats, lstatscpu
    integer(c_int) :: nprnt_stats
    logical :: lbarrier_stats, lbarrier_stats2
    integer(c_int) :: nproc, nspecresmin, noutput, mp_type, mbx_size
  end type
contains
!> Read the first exact NAMPAR0 group and commit OUTPUT only on success.
!! TEXT is1:262144ASCIIbytes. EXPECTED_WORLD is1:65536processes.
!! Counts are int32 and unitless. OUTPUT is caller-owned and INOUT.
!! NPRNT_STATS alone can be omitted,retaining its source default of2.
  integer(c_int) function read_distributed_process_controls(text, expected_world, output) result(status)
    character(len=*), intent(in) :: text
    integer(c_int), intent(in) :: expected_world
    type(native_process_control), intent(inout) :: output
    type(native_process_control) :: pending
    character(len=15), parameter :: keys(13) = [character(len=15) :: &
                                                'LXML_STATS', 'LSTATS', 'LDETAILED_STATS', 'LSYNCSTATS', 'LSTATSCPU', &
                                                'NPRNT_STATS', &
                                                'LBARRIER_STATS', 'LBARRIER_STATS2', 'NPROC', 'NSPECRESMIN', 'NOUTPUT', 'MP_TYPE', &
                                                'MBX_SIZE']
    integer :: cursor, first, last, key, n, seen
    integer(c_int) :: value, effective
    logical :: logical_value, valid, is_logical
    status = 2_c_int
    n = len(text)
    if (n < 1 .or. n > 262144 .or. expected_world < 1 .or. expected_world > 65536) return
    cursor = find_process_group(text)
    if (cursor == 0) return
    pending%nprnt_stats = 2
    seen = 0
    do
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      if (text(cursor:cursor) == '/') then
        if (ior(seen, 32) /= 8191) return
        output = pending
        status = 0_c_int
        return
      end if
      first = cursor
      do while (cursor <= n)
        if (.not. physics_key_character(text(cursor:cursor), .false.)) exit
        cursor = cursor + 1
      end do
      last = cursor - 1
      if (last < first .or. cursor > n) return
      do key = 1, 13
        if (physics_fold_equal(text(first:last), trim(keys(key)))) exit
      end do
      if (key > 13) return
      if (btest(seen, key - 1)) return
      seen = ibset(seen, key - 1)
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      if (text(cursor:cursor) /= '=') return
      cursor = cursor + 1
      call skip_physics_space(text, cursor)
      first = cursor
      do while (cursor <= n)
        if (physics_space(text(cursor:cursor))) exit
        if (index(',!/', text(cursor:cursor)) /= 0) exit
        cursor = cursor + 1
      end do
      last = cursor - 1
      if (last < first .or. cursor > n) return
      is_logical = key <= 5 .or. key == 7 .or. key == 8
      if (is_logical) then
        call parse_physics_boolean(text(first:last), logical_value, valid)
        if (.not. valid) return
        if (.not. (physics_fold_equal(text(first:last), 'TRUE') .or. &
                   physics_fold_equal(text(first:last), 'FALSE') .or. &
                   physics_fold_equal(text(first:last), '.TRUE.') .or. &
                   physics_fold_equal(text(first:last), '.FALSE.'))) return
        if (logical_value .neqv. (key == 2)) return
        select case (key)
        case (1); pending%lxml_stats = logical_value
        case (2); pending%lstats = logical_value
        case (3); pending%ldetailed_stats = logical_value
        case (4); pending%lsyncstats = logical_value
        case (5); pending%lstatscpu = logical_value
        case (7); pending%lbarrier_stats = logical_value
        case (8); pending%lbarrier_stats2 = logical_value
        end select
      else
        call parse_process_integer(text(first:last), key == 6, value, valid)
        if (.not. valid) return
        select case (key)
        case (6); pending%nprnt_stats = value
        case (9)
          effective = value
          if (effective == 0) effective = 1
          if (effective /= expected_world) return
          pending%nproc = value
        case (10)
          if (value < 0 .or. value > 1000000) return
          pending%nspecresmin = value
        case (11)
          if (value /= 1) return
          pending%noutput = value
        case (12)
          if (value /= 1) return
          pending%mp_type = value
        case (13)
          if (value /= 0) return
          pending%mbx_size = value
        end select
      end if
      if (text(cursor:cursor) == ',') cursor = cursor + 1
    end do
  end function
  integer function find_process_group(text) result(cursor)
    character(len=*), intent(in) :: text
    integer :: i, n, column, last, code
    cursor = 0
    n = len(text)
    i = 1
    column = 0
    do while (i <= n)
      code = iachar(text(i:i))
      if (code == 10) then
        column = 0
        i = i + 1
        cycle
      end if
      column = column + 1
      if (code == 32 .or. code == 9 .or. code == 13) then
        i = i + 1
        cycle
      end if
      if (code == 38 .and. column <= 10) then
        last = i + 7
        if (last >= n) return
        if (text(i + 1:last) == 'NAMPAR0') then
          if (physics_space(text(last + 1:last + 1)) .or. text(last + 1:last + 1) == '/' .or. &
              text(last + 1:last + 1) == '!') then
            cursor = last + 1
            return
          end if
        end if
      end if
      do while (i <= n)
        if (iachar(text(i:i)) == 10) exit
        i = i + 1
      end do
      i = i + 1
      column = 0
    end do
  end function
  subroutine parse_process_integer(token, allow_sign, value, valid)
    character(len=*), intent(in) :: token
    logical, intent(in) :: allow_sign
    integer(c_int), intent(out) :: value
    logical, intent(out) :: valid
    integer :: i, digit, sign
    integer(c_int64_t) :: magnitude, limit
    valid = .false.
    value = 0
    i = 1
    sign = 1
    if (len(token) < 1) return
    if (token(i:i) == '-' .or. token(i:i) == '+') then
      if (.not. allow_sign) return
      if (token(i:i) == '-') sign = -1
      i = i + 1
    end if
    if (i > len(token)) return
    magnitude = 0_c_int64_t
    limit = 2147483647_c_int64_t
    if (sign < 0) limit = limit + 1
    do while (i <= len(token))
      digit = iachar(token(i:i)) - 48
      if (digit < 0 .or. digit > 9) return
      if (magnitude > (limit - int(digit, c_int64_t))/10_c_int64_t) return
      magnitude = magnitude*10_c_int64_t + digit
      i = i + 1
    end do
    value = int(int(sign, c_int64_t)*magnitude, c_int)
    valid = .true.
  end subroutine
end module forecast_distributed_process_controls
