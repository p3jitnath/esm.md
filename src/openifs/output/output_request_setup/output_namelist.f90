!> Read the first bounded NAMFPC group with the original integer-only token rules.
!! Text is a byte character string, with at most 262144 characters.
!! Output is committed only after all selected keys and field-code relations pass.
!! Integer encoding preserves signed zero without floating-point arithmetic or I/O.
module forecast_output_namelist
  use iso_fortran_env, only: int32, int64, real64
  use forecast_output_request_types, only: native_output_request_input
  implicit none
  private
  public :: native_selected_output_namelist, native_runtime_output_namelist
  public :: parse_selected_output_namfpc, parse_runtime_output_namfpc
  type :: native_selected_output_namelist
    type(native_output_request_input) :: request
    character(8) :: cfpfmt = 'GAUSS   '
  end type
  type :: native_runtime_output_namelist
    integer(int32) :: field_count(9) = 0, field_code(256, 9) = 0, nrfp3s(200) = -9
    character(8) :: cfpfmt = 'GAUSS   '
    integer(int32) :: nfpcli = 0
    logical :: lfpq = .false., ltracefp = .true.
    real(real64) :: rfpcorr = 2943.0_real64
    real(real64) :: levels(256, 6) = 0.0_real64
  end type
  character(8), parameter :: keys(30) = [character(8) :: &
                                  'nfp3dfs', 'nfp3dfp', 'nfp3dfh', 'nfp3dft', 'nfp3dfv', 'nfp3dfi', 'nfp3dff', 'nfp2df', 'nfpphy', &
                                  'mfp3dfs', 'mfp3dfp', 'mfp3dfh', 'mfp3dft', 'mfp3dfv', 'mfp3dfi', 'mfp3dff', 'mfp2df', 'mfpphy', &
                'nrfp3s', 'rfp3p', 'rfp3h', 'rfp3th', 'rfp3pv', 'rfp3i', 'rfp3f', 'cfpfmt', 'nfpcli', 'lfpq', 'ltracefp', 'rfpcorr']
  integer, parameter :: runtime_real_capacity(6) = [75, 127, 75, 75, 75, 75]
  integer(int64), parameter :: real_default_bits(6) = [int(z'C022000000000000', int64), &
                                int(z'C022000000000000', int64), int(z'C022000000000000', int64), int(z'42029FE50E000000', int64), &
                                                       int(z'C0C3878000000000', int64), int(z'C022000000000000', int64)]
contains
  !> Produce the complete selected64-entry named record; status2 leaves it unchanged.
  integer(int32) function parse_selected_output_namfpc(text, output) result(status)
    character(*), intent(in) :: text
    type(native_selected_output_namelist), intent(inout) :: output
    type(native_runtime_output_namelist) :: work
    type(native_selected_output_namelist) :: selected
    status = parse_namfpc_body(text, work, .false., .true.)
    if (status /= 0) return
    selected%cfpfmt = work%cfpfmt
    selected%request%field_count = work%field_count
    selected%request%field_code = work%field_code(1:64, :)
    selected%request%nrfp3s = work%nrfp3s(1:64)
    selected%request%rfp3p = work%levels(1:64, 1)
    selected%request%rfp3h = work%levels(1:64, 2)
    selected%request%rfp3th = work%levels(1:64, 3)
    selected%request%rfp3pv = work%levels(1:64, 4)
    selected%request%rfp3i = work%levels(1:64, 5)
    selected%request%rfp3f = work%levels(1:64, 6)
    output = selected
  end function
  !> Produce the complete runtime record; optional trace_default selects the frozen source include.
  integer(int32) function parse_runtime_output_namfpc(text, output, trace_default) result(status)
    character(*), intent(in) :: text
    type(native_runtime_output_namelist), intent(inout) :: output
    logical, intent(in), optional :: trace_default
    type(native_runtime_output_namelist) :: work
    logical :: trace
    trace = .true.
    if (present(trace_default)) trace = trace_default
    status = parse_namfpc_body(text, work, .true., trace)
    if (status == 0) output = work
  end function
  integer(int32) function parse_namfpc_body(text, work, runtime, trace_default) result(status)
    character(*), intent(in) :: text
    type(native_runtime_output_namelist), intent(out) :: work
    logical, intent(in) :: runtime, trace_default
    logical :: seen(30), negative, ok, logic
    integer :: cursor, first, last, key, kind, capacity, index, family, k, n, key_count, limit
    integer(int64) :: value
    character :: quote, c
    status = 2
    n = len(text)
    if (n < 1 .or. n > 262144) return
    work%field_count = 0
    work%field_code = 0
    work%field_code(:, 9) = -9999
    work%nrfp3s = -9
    work%cfpfmt = 'GAUSS   '
    work%nfpcli = 0
    work%lfpq = .false.
    work%ltracefp = trace_default
    work%rfpcorr = transfer(int(z'40A6FE0000000000', int64), 0.0_real64)
    work%levels = 0.0_real64
    do family = 1, 6
      limit = 64
      if (runtime) limit = runtime_real_capacity(family)
      do k = 1, limit
        work%levels(k, family) = transfer(real_default_bits(family), 0.0_real64)
      end do
    end do
    cursor = find_namfpc_group(text)
    if (cursor == 0) return
    seen = .false.
    key_count = 26
    if (runtime) key_count = 30
    do
      call skip_space(text, cursor)
      if (cursor > n) return
      if (text(cursor:cursor) == '/') exit
      first = cursor
      do while (cursor <= n)
        if (.not. key_character(text(cursor:cursor))) exit
        cursor = cursor + 1
      end do
      last = cursor - 1
      if (last < first) return
      key = 0
      do k = 1, key_count
        if (last - first + 1 == len_trim(keys(k))) then
          if (.not. key_matches(text(first:last), keys(k))) cycle
          key = k
          exit
        end if
      end do
      if (key == 0) return
      if (seen(key)) return
      seen(key) = .true.
      kind = 0
      capacity = 1
      if (key >= 10 .and. key <= 18) then
        kind = 1
        capacity = 64
        if (runtime) capacity = 256
        if (runtime .and. key == 17) capacity = 212
      elseif (key == 19) then
        kind = 2
        capacity = 64
        if (runtime) capacity = 200
      elseif (key >= 20 .and. key <= 25) then
        kind = 3
        capacity = 64
        if (runtime) capacity = runtime_real_capacity(key - 19)
      elseif (key == 26) then
        kind = 4
      elseif (key == 27) then
        kind = 6
      elseif (key == 28 .or. key == 29) then
        kind = 5
      elseif (key == 30) then
        kind = 3
      end if
      call skip_space(text, cursor)
      if (cursor > n) return
      if (text(cursor:cursor) == '(') then
        if (.not. runtime .or. capacity <= 1) return
        cursor = cursor + 1
        call skip_space(text, cursor)
        if (cursor > n) return
        if (text(cursor:cursor) /= ':') return
        cursor = cursor + 1
        call skip_space(text, cursor)
        if (cursor > n) return
        if (text(cursor:cursor) /= ')') return
        cursor = cursor + 1
        call skip_space(text, cursor)
      end if
      if (cursor > n) return
      if (text(cursor:cursor) /= '=') return
      cursor = cursor + 1
      call skip_space(text, cursor)
      if (kind == 4) then
        if (cursor > n) return
        quote = text(cursor:cursor)
        if (quote /= "'" .and. quote /= '"') return
        cursor = cursor + 1
        if (cursor + 5 > n) return
        if (text(cursor:cursor + 4) /= 'MODEL') return
        cursor = cursor + 5
        if (text(cursor:cursor) /= quote) return
        cursor = cursor + 1
        work%cfpfmt = 'MODEL   '
        call skip_space(text, cursor)
        if (cursor > n) return
        if (text(cursor:cursor) == ',') cursor = cursor + 1
        cycle
      end if
      index = 0
      do
        if (index >= capacity) return
        if (kind == 5) then
          call parse_logical(text, cursor, logic, ok)
          if (.not. ok) return
          value = 0
          if (logic) value = 1
          negative = .false.
        else
          call parse_integer_token(text, cursor, kind == 3, value, negative, ok)
          if (.not. ok) return
        end if
        index = index + 1
        select case (kind)
        case (0)
          limit = 64
          if (runtime) limit = 256
          if (runtime .and. key == 8) limit = 212
          if (value < 0 .or. value > limit) return
          if (.not. runtime .and. key == 9 .and. value /= 0) return
          work%field_count(key) = int(value, int32)
        case (1)
          limit = 686
          if (runtime .and. key == 18) limit = huge(0_int32)
          if (value < 0 .or. value > limit) return
          work%field_code(index, key - 9) = int(value, int32)
        case (2)
          limit = 64
          if (runtime) limit = 200
          if (.not. ((value >= 0 .and. value <= limit) .or. value == -99 .or. value == -9)) return
          work%nrfp3s(index) = int(value, int32)
        case (3)
          if (key == 30) then
            work%rfpcorr = transfer(integer_real_bits(value, negative), 0.0_real64)
          else
            work%levels(index, key - 19) = transfer(integer_real_bits(value, negative), 0.0_real64)
          end if
        case (5)
          if (key == 28) work%lfpq = logic
          if (key == 29) work%ltracefp = logic
        case (6)
          if (value /= 0) return
          work%nfpcli = 0
        end select
        call skip_space(text, cursor)
        if (cursor > n) return
        c = text(cursor:cursor)
        if (c == ',') then
          cursor = cursor + 1
          call skip_space(text, cursor)
          if (cursor > n) return
          c = text(cursor:cursor)
        end if
        if (c == '/') exit
        if (letter(c)) exit
      end do
      if (text(cursor:cursor) == '/') exit
    end do
    if (work%cfpfmt /= 'MODEL   ') return
    do family = 1, 9
      do k = 1, work%field_count(family)
        value = work%field_code(k, family)
        if (value <= 0) return
        if (family /= 9 .or. .not. runtime) then
          if (value > 686) return
        end if
      end do
    end do
    status = 0
  end function
  integer function find_namfpc_group(text) result(cursor)
    character(*), intent(in) :: text
    integer :: p, n
    cursor = 0
    n = len(text)
    p = 1
    do while (p <= n)
      do while (p <= n)
        if (index(' '//achar(9)//achar(13)//achar(10), text(p:p)) == 0) exit
        p = p + 1
      end do
      if (p > n) return
      if (text(p:p) == '&') then
        if (p + 7 <= n) then
          if (fold_equal(text(p + 1:p + 6), 'namfpc')) then
            if (index(' '//achar(9)//achar(13)//achar(10)//'/', text(p + 7:p + 7)) /= 0) then
              cursor = p + 7
              return
            end if
          end if
        end if
      end if
      do while (p <= n)
        if (text(p:p) == achar(10)) exit
        p = p + 1
      end do
      p = p + 1
    end do
  end function
  subroutine skip_space(text, cursor)
    character(*), intent(in) :: text
    integer, intent(inout) :: cursor
    do while (cursor <= len(text))
      if (index(' '//achar(9)//achar(10)//achar(13), text(cursor:cursor)) /= 0) then
        cursor = cursor + 1
      elseif (text(cursor:cursor) == '!') then
        do while (cursor <= len(text))
          if (text(cursor:cursor) == achar(10)) exit
          cursor = cursor + 1
        end do
      else
        return
      end if
    end do
  end subroutine
  logical function letter(c)
    character, intent(in) :: c
    integer :: v
    v = ior(iachar(c), 32)
    letter = v >= iachar('a') .and. v <= iachar('z')
  end function
  logical function key_character(c)
    character, intent(in) :: c
    key_character = letter(c) .or. (c >= '0' .and. c <= '9') .or. c == '_'
  end function
  logical function key_matches(left, right)
    character(*), intent(in) :: left, right
    integer :: i
    key_matches = .false.
    do i = 1, len(left)
      if (ior(iachar(left(i:i)), 32) /= iachar(right(i:i))) return
    end do
    key_matches = .true.
  end function
  logical function fold_equal(left, right)
    character(*), intent(in) :: left, right
    integer :: i
    fold_equal = .false.
    if (len(left) /= len(right)) return
    do i = 1, len(left)
      if (ior(iachar(left(i:i)), 32) /= iachar(right(i:i))) return
    end do
    fold_equal = .true.
  end function
  logical function delimiter(c)
    character, intent(in) :: c
    delimiter = index(' '//achar(9)//achar(10)//achar(13)//',/!', c) /= 0
  end function
  subroutine parse_integer_token(text, cursor, real_token, value, negative, ok)
    character(*), intent(in) :: text
    integer, intent(inout) :: cursor
    logical, intent(in) :: real_token
    integer(int64), intent(out) :: value
    logical, intent(out) :: negative, ok
    integer :: n, digit, digits, exponent, k
    integer(int64) :: magnitude
    logical :: exponent_negative
    ok = .false.
    negative = .false.
    value = 0
    n = len(text)
    if (cursor > n) return
    if (text(cursor:cursor) == '-') then
      negative = .true.
      cursor = cursor + 1
    elseif (text(cursor:cursor) == '+') then
      cursor = cursor + 1
    end if
    magnitude = 0
    digits = 0
    do while (cursor <= n)
      digit = iachar(text(cursor:cursor)) - iachar('0')
      if (digit < 0 .or. digit > 9) exit
      if (magnitude > (9007199254740992_int64 - digit)/10_int64) return
      magnitude = magnitude*10_int64 + digit
      digits = digits + 1
      cursor = cursor + 1
    end do
    if (digits == 0) return
    if (real_token .and. cursor <= n) then
      if (text(cursor:cursor) == '.') then
        cursor = cursor + 1
        do while (cursor <= n)
          digit = iachar(text(cursor:cursor)) - iachar('0')
          if (digit < 0 .or. digit > 9) exit
          if (digit /= 0) return
          cursor = cursor + 1
        end do
      end if
      if (cursor <= n) then
        if (index('eEdD', text(cursor:cursor)) /= 0) then
          cursor = cursor + 1
          if (cursor > n) return
          exponent_negative = .false.
          if (text(cursor:cursor) == '-') then
            exponent_negative = .true.
            cursor = cursor + 1
          elseif (text(cursor:cursor) == '+') then
            cursor = cursor + 1
          end if
          exponent = 0
          digits = 0
          do while (cursor <= n)
            digit = iachar(text(cursor:cursor)) - iachar('0')
            if (digit < 0 .or. digit > 9) exit
            exponent = exponent*10 + digit
            if (exponent > 15) return
            digits = digits + 1
            cursor = cursor + 1
          end do
          if (digits == 0) return
          do k = 1, exponent
            if (exponent_negative) then
              if (mod(magnitude, 10_int64) /= 0) return
              magnitude = magnitude/10_int64
            else
              if (magnitude > 9007199254740992_int64/10_int64) return
              magnitude = magnitude*10_int64
            end if
          end do
        end if
      end if
    end if
    if (cursor <= n) then
      if (.not. delimiter(text(cursor:cursor))) return
    end if
    value = magnitude
    if (negative) value = -value
    ok = .true.
  end subroutine
  subroutine parse_logical(text, cursor, value, ok)
    character(*), intent(in) :: text
    integer, intent(inout) :: cursor
    logical, intent(out) :: value, ok
    logical :: dots
    integer :: length
    character(5) :: token
    ok = .false.
    value = .false.
    if (cursor > len(text)) return
    dots = text(cursor:cursor) == '.'
    if (dots) cursor = cursor + 1
    if (cursor > len(text)) return
    length = 4
    token = 'true '
    if (ior(iachar(text(cursor:cursor)), 32) == iachar('f')) then
      length = 5
      token = 'false'
    end if
    if (cursor + length - 1 > len(text)) return
    if (.not. fold_equal(text(cursor:cursor + length - 1), token(1:length))) return
    value = length == 4
    cursor = cursor + length
    if (dots) then
      if (cursor > len(text)) return
      if (text(cursor:cursor) /= '.') return
      cursor = cursor + 1
    end if
    if (cursor <= len(text)) then
      if (.not. delimiter(text(cursor:cursor))) return
    end if
    ok = .true.
  end subroutine
  pure integer(int64) function integer_real_bits(value, negative) result(bits)
    integer(int64), intent(in) :: value
    logical, intent(in) :: negative
    integer(int64) :: magnitude, fraction
    integer :: exponent, highest
    magnitude = abs(value)
    bits = 0
    if (magnitude /= 0) then
      highest = 63 - leadz(magnitude)
      exponent = highest + 1023
      fraction = iand(ishft(magnitude, 52 - highest), int(z'000FFFFFFFFFFFFF', int64))
      bits = ior(ishft(int(exponent, int64), 52), fraction)
    end if
    if (negative) bits = ibset(bits, 63)
  end function
end module forecast_output_namelist
