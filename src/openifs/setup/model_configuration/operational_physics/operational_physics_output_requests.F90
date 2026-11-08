!> Read the complete137-slot operational NAMFPC request record.
module forecast_operational_physics_requests
  use iso_c_binding, only: c_int, c_int64_t, c_double, c_char
  use iso_fortran_env, only: int32, int64, real64
  use physics_configuration_text_port, only: find_physics_group, skip_physics_space, physics_space, &
                                             physics_key_character, physics_fold_equal, parse_physics_boolean
  implicit none
  private
  public :: native_operational_physics_output_requests, parse_operational_physics_output_requests
!> Own source-named request counts,codes,levels and explicit reserved header words.
!! Counts,codes and integer model levels are dimensionless. Real level values
!! retain the units of their source NAMFPC members. The three reserved header
!! components are source-defined zero output words,not numerical storage.
!! BIND(C) gives explicit INT32/FP64/character shapes without a private descriptor.
  type, bind(C) :: native_operational_physics_output_requests
    integer(c_int) :: nfp3dfs, nfp3dfp, nfp3dfh, nfp3dft, nfp3dfv, nfp3dfi, nfp3dff, nfp2df, nfpphy
    integer(c_int) :: reserved_header_word
    character(c_char) :: cfpfmt(8)
    integer(c_int) :: nfpcli, lfpq, ltracefp, reserved_header_flag
    real(c_double) :: rfpcorr
    integer(c_int64_t) :: reserved_header_extension(3)
    integer(c_int) :: mfp3dfs(137)
    integer(c_int) :: mfp3dfp(137)
    integer(c_int) :: mfp3dfh(137)
    integer(c_int) :: mfp3dft(137)
    integer(c_int) :: mfp3dfv(137)
    integer(c_int) :: mfp3dfi(137)
    integer(c_int) :: mfp3dff(137)
    integer(c_int) :: mfp2df(137)
    integer(c_int) :: mfpphy(137)
    integer(c_int) :: nrfp3s(137)
    real(c_double) :: rfp3p(137)
    real(c_double) :: rfp3h(137)
    real(c_double) :: rfp3th(137)
    real(c_double) :: rfp3pv(137)
    real(c_double) :: rfp3i(137)
    real(c_double) :: rfp3f(137)
  end type
  character(c_char), parameter :: model_format(8) = ['M', 'O', 'D', 'E', 'L', ' ', ' ', ' ']
  character(c_char), parameter :: gauss_format(8) = ['G', 'A', 'U', 'S', 'S', ' ', ' ', ' ']
contains
!> Parse the exact existing operational request domain before publishing.
!! TEXT is read-only bounded ASCII of1:262144 characters. OUTPUT is an INOUT
!! caller-owned native record,disjoint from TEXT. Each array holds137 entries.
!! The30 source keys and duplicate/subscript rules follow the frozen parser.
!! Active request codes are positive INT32 values; current code260123 and
!! NFPPHY103 are already within this original operational domain.
!! Status2 preserves OUTPUT;status0 publishes every defined internal field.
!! All real values use exact integral encodings of magnitude at most2**53,
!! including negative zero. No FP conversion,arithmetic or guard is used.
  integer(int32) function parse_operational_physics_output_requests(text, output) result(status)
    character(len=*), intent(in) :: text
    type(native_operational_physics_output_requests), intent(inout) :: output
    type(native_operational_physics_output_requests) :: staged
    character(len=8), parameter :: keys(30) = [character(len=8) :: &
                                               'nfp3dfs', &
                                               'nfp3dfp', &
                                               'nfp3dfh', &
                                               'nfp3dft', &
                                               'nfp3dfv', &
                                               'nfp3dfi', &
                                               'nfp3dff', &
                                               'nfp2df', &
                                               'nfpphy', &
                                               'mfp3dfs', &
                                               'mfp3dfp', &
                                               'mfp3dfh', &
                                               'mfp3dft', &
                                               'mfp3dfv', &
                                               'mfp3dfi', &
                                               'mfp3dff', &
                                               'mfp2df', &
                                               'mfpphy', &
                                               'nrfp3s', &
                                               'rfp3p', &
                                               'rfp3h', &
                                               'rfp3th', &
                                               'rfp3pv', &
                                               'rfp3i', &
                                               'rfp3f', &
                                               'cfpfmt', &
                                               'nfpcli', &
                                               'lfpq', &
                                               'ltracefp', &
                                               'rfpcorr']
  integer, parameter :: key_lengths(30) = [7, 7, 7, 7, 7, 7, 7, 6, 6, 7, 7, 7, 7, 7, 7, 7, 6, 6, 6, 5, 5, 6, 6, 5, 5, 6, 6, 4, 8, 7]
    integer :: n, cursor, first, last, key, capacity, count, family, code
    integer(int64) :: number, bits
    logical :: seen(30), valid, negative, boolean
    character :: quote
    status = 2_int32
    n = len(text)
    if (n < 1 .or. n > 262144) return
    cursor = find_physics_group(text, 'NAMFPC', .false.)
    if (cursor == 0) return
    call initialize_request_defaults(staged)
    seen = .false.
    do
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      if (text(cursor:cursor) == '/') exit
      first = cursor
      do while (cursor <= n)
        if (.not. physics_key_character(text(cursor:cursor), .false.)) exit
        cursor = cursor + 1
      end do
      if (cursor > n) return
      last = cursor - 1
      if (last < first) return
      do key = 1, 30
        if (physics_fold_equal(text(first:last), keys(key) (1:key_lengths(key)))) exit
      end do
      if (key > 30) return
      if (seen(key)) return
      seen(key) = .true.
      capacity = 137
      if (key <= 9 .or. key >= 26) capacity = 1
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      if (text(cursor:cursor) == '(') then
        if (capacity <= 1) return
        cursor = cursor + 1
        call skip_physics_space(text, cursor)
        if (cursor > n) return
        if (text(cursor:cursor) /= ':') return
        cursor = cursor + 1
        call skip_physics_space(text, cursor)
        if (cursor > n) return
        if (text(cursor:cursor) /= ')') return
        cursor = cursor + 1
        call skip_physics_space(text, cursor)
        if (cursor > n) return
      end if
      if (text(cursor:cursor) /= '=') return
      cursor = cursor + 1
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      if (key == 26) then
        quote = text(cursor:cursor)
        if (quote /= "'" .and. quote /= '"') return
        cursor = cursor + 1
        if (cursor + 5 > n) return
        if (text(cursor:cursor + 4) /= 'MODEL') return
        if (text(cursor + 5:cursor + 5) /= quote) return
        cursor = cursor + 6
        staged%cfpfmt = model_format
        call skip_physics_space(text, cursor)
        if (cursor > n) return
        if (text(cursor:cursor) == ',') cursor = cursor + 1
        cycle
      end if
      count = 0
      do
        if (count >= capacity) return
        first = cursor
        do while (cursor <= n)
          if (physics_space(text(cursor:cursor))) exit
          if (index(',/!', text(cursor:cursor)) /= 0) exit
          cursor = cursor + 1
        end do
        if (cursor > n) return
        last = cursor - 1
        if (last < first) return
        count = count + 1
        if (key == 28 .or. key == 29) then
          call parse_physics_boolean(text(first:last), boolean, valid)
          if (.not. valid) return
          if (boolean) return
          if (key == 28) staged%lfpq = 0_c_int
          if (key == 29) staged%ltracefp = 0_c_int
        else
          call parse_integral_token(text(first:last), (key >= 20 .and. key <= 25) .or. key == 30, number, negative, valid)
          if (.not. valid) return
          select case (key)
          case (1:9, 27)
            if (number < 0_int64 .or. number > 137_int64) return
            if (key == 27 .and. number /= 0_int64) return
            call set_integer_request(staged, key, count, int(number, int32))
          case (10:18)
            if (number < 0_int64 .or. number > 2147483647_int64) return
            call set_integer_request(staged, key, count, int(number, int32))
          case (19)
            if (number < 0_int64 .or. number > 137_int64) then
              if (number /= -99_int64 .and. number /= -9_int64) return
            end if
            staged%nrfp3s(count) = int(number, int32)
          case (20:25, 30)
            if (key == 30 .and. number /= 60000_int64) return
            bits = exact_integer_bits(number, negative)
            call set_real_request(staged, key, count, transfer(bits, 0.0_real64))
          end select
        end if
        call skip_physics_space(text, cursor)
        if (cursor > n) return
        if (text(cursor:cursor) == ',') then
          cursor = cursor + 1
          call skip_physics_space(text, cursor)
          if (cursor > n) return
        end if
        if (text(cursor:cursor) == '/') exit
        code = iachar(text(cursor:cursor))
        if ((code >= 65 .and. code <= 90) .or. (code >= 97 .and. code <= 122)) exit
      end do
    end do
    if (any(staged%cfpfmt /= model_format)) return
    do family = 1, 9
      do count = 1, request_count(staged, family)
        if (request_code(staged, family, count) < 1) return
      end do
    end do
    output = staged
    status = 0_int32
  end function
!> Define every source output field,including its explicit zero header words.
  subroutine initialize_request_defaults(state)
    type(native_operational_physics_output_requests), intent(out) :: state
    state%nfp3dfs = 0_c_int
    state%nfp3dfp = 0_c_int
    state%nfp3dfh = 0_c_int
    state%nfp3dft = 0_c_int
    state%nfp3dfv = 0_c_int
    state%nfp3dfi = 0_c_int
    state%nfp3dff = 0_c_int
    state%nfp2df = 0_c_int
    state%nfpphy = 0_c_int
    state%reserved_header_word = 0_c_int
    state%cfpfmt = gauss_format
    state%nfpcli = 0_c_int
    state%lfpq = 0_c_int
    state%ltracefp = 0_c_int
    state%reserved_header_flag = 0_c_int
    state%rfpcorr = transfer(int(z'40a6fe0000000000', int64), 0.0_real64)
    state%reserved_header_extension = 0_c_int64_t
    state%mfp3dfs = 0_c_int
    state%mfp3dfp = 0_c_int
    state%mfp3dfh = 0_c_int
    state%mfp3dft = 0_c_int
    state%mfp3dfv = 0_c_int
    state%mfp3dfi = 0_c_int
    state%mfp3dff = 0_c_int
    state%mfp2df = 0_c_int
    state%mfpphy = -9999_c_int
    state%nrfp3s = -9_c_int
    state%rfp3p = transfer(int(z'c022000000000000', int64), 0.0_real64)
    state%rfp3h = transfer(int(z'c022000000000000', int64), 0.0_real64)
    state%rfp3th = transfer(int(z'c022000000000000', int64), 0.0_real64)
    state%rfp3pv = transfer(int(z'42029fe50e000000', int64), 0.0_real64)
    state%rfp3i = transfer(int(z'c0c3878000000000', int64), 0.0_real64)
    state%rfp3f = transfer(int(z'c022000000000000', int64), 0.0_real64)
  end subroutine
  subroutine set_integer_request(state, key, element, value)
    type(native_operational_physics_output_requests), intent(inout) :: state
    integer, intent(in) :: key, element
    integer(int32), intent(in) :: value
    select case (key)
    case (1); state%nfp3dfs = value
    case (2); state%nfp3dfp = value
    case (3); state%nfp3dfh = value
    case (4); state%nfp3dft = value
    case (5); state%nfp3dfv = value
    case (6); state%nfp3dfi = value
    case (7); state%nfp3dff = value
    case (8); state%nfp2df = value
    case (9); state%nfpphy = value
    case (10); state%mfp3dfs(element) = value
    case (11); state%mfp3dfp(element) = value
    case (12); state%mfp3dfh(element) = value
    case (13); state%mfp3dft(element) = value
    case (14); state%mfp3dfv(element) = value
    case (15); state%mfp3dfi(element) = value
    case (16); state%mfp3dff(element) = value
    case (17); state%mfp2df(element) = value
    case (18); state%mfpphy(element) = value
    case (27); state%nfpcli = value
    end select
  end subroutine
  subroutine set_real_request(state, key, element, value)
    type(native_operational_physics_output_requests), intent(inout) :: state
    integer, intent(in) :: key, element
    real(real64), intent(in) :: value
    select case (key)
    case (20); state%rfp3p(element) = value
    case (21); state%rfp3h(element) = value
    case (22); state%rfp3th(element) = value
    case (23); state%rfp3pv(element) = value
    case (24); state%rfp3i(element) = value
    case (25); state%rfp3f(element) = value
    case (30); state%rfpcorr = value
    end select
  end subroutine
  integer(int32) function request_count(state, family) result(value)
    type(native_operational_physics_output_requests), intent(in) :: state
    integer, intent(in) :: family
    value = 0_int32
    select case (family)
    case (1); value = state%nfp3dfs
    case (2); value = state%nfp3dfp
    case (3); value = state%nfp3dfh
    case (4); value = state%nfp3dft
    case (5); value = state%nfp3dfv
    case (6); value = state%nfp3dfi
    case (7); value = state%nfp3dff
    case (8); value = state%nfp2df
    case (9); value = state%nfpphy
    end select
  end function
  integer(int32) function request_code(state, family, element) result(value)
    type(native_operational_physics_output_requests), intent(in) :: state
    integer, intent(in) :: family, element
    value = 0_int32
    select case (family)
    case (1); value = state%mfp3dfs(element)
    case (2); value = state%mfp3dfp(element)
    case (3); value = state%mfp3dfh(element)
    case (4); value = state%mfp3dft(element)
    case (5); value = state%mfp3dfv(element)
    case (6); value = state%mfp3dfi(element)
    case (7); value = state%mfp3dff(element)
    case (8); value = state%mfp2df(element)
    case (9); value = state%mfpphy(element)
    end select
  end function
  subroutine parse_integral_token(token, allow_real, number, negative, valid)
    !! Parse a signed integer of magnitude at most 2**53. A real token
    !! admits only zero fractional digits and exact decimal scaling.
    character(len=*), intent(in) :: token
    logical, intent(in) :: allow_real
    integer(int64), intent(out) :: number
    logical, intent(out) :: negative, valid
    integer(int64), parameter :: limit = 9007199254740992_int64
    integer(int64) :: magnitude
    integer :: i, n, digit, digits, power, power_sign
    number = 0_int64; negative = .false.; valid = .false.; magnitude = 0_int64
    n = len(token); i = 1
    if (n < 1) return
    if (token(i:i) == '-') then
      negative = .true.; i = i + 1
    else if (token(i:i) == '+') then
      i = i + 1
    end if
    digits = 0
    do while (i <= n)
      digit = iachar(token(i:i)) - 48
      if (digit < 0 .or. digit > 9) exit
      if (magnitude > (limit - int(digit, int64))/10_int64) return
      magnitude = 10_int64*magnitude + int(digit, int64)
      digits = digits + 1; i = i + 1
    end do
    if (digits == 0) return
    if (allow_real) then
      if (i <= n) then
        if (token(i:i) == '.') then
          i = i + 1
          do while (i <= n)
            digit = iachar(token(i:i)) - 48
            if (digit < 0 .or. digit > 9) exit
            if (digit /= 0) return
            i = i + 1
          end do
        end if
      end if
      if (i <= n) then
        if (index('eEdD', token(i:i)) /= 0) then
          i = i + 1; power_sign = 1
          if (i > n) return
          if (token(i:i) == '-') then
            power_sign = -1; i = i + 1
          else if (token(i:i) == '+') then
            i = i + 1
          end if
          power = 0; digits = 0
          do while (i <= n)
            digit = iachar(token(i:i)) - 48
            if (digit < 0 .or. digit > 9) exit
            power = 10*power + digit
            if (power > 15) return
            digits = digits + 1; i = i + 1
          end do
          if (digits == 0) return
          do while (power > 0)
            if (power_sign == 1) then
              if (magnitude > limit/10_int64) return
              magnitude = magnitude*10_int64
            else
              if (mod(magnitude, 10_int64) /= 0_int64) return
              magnitude = magnitude/10_int64
            end if
            power = power - 1
          end do
        end if
      end if
    end if
    if (i <= n) return
    number = magnitude
    if (negative) number = -magnitude
    valid = .true.
  end subroutine

  pure integer(int64) function exact_integer_bits(number, negative) result(bits)
    !! Construct FP64 bits without a floating-point conversion. This also
    !! retains a minus sign on zero in the source token.
    integer(int64), intent(in) :: number
    logical, intent(in) :: negative
    integer(int64) :: magnitude, fraction
    integer :: exponent, shift
    magnitude = abs(number); bits = 0_int64
    if (magnitude /= 0_int64) then
      exponent = 63 - leadz(magnitude)
      shift = 52 - exponent
      if (shift >= 0) then
        fraction = shiftl(magnitude, shift)
      else
        fraction = shiftr(magnitude, -shift)
      end if
      bits = ior(shiftl(int(exponent + 1023, int64), 52), iand(fraction, int(z'000FFFFFFFFFFFFF', int64)))
    end if
    if (negative) bits = ibset(bits, 63)
  end function
end module forecast_operational_physics_requests
