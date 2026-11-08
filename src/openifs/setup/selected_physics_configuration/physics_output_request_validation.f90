module physics_output_request_validation_port
  !! Read the request-only NAMFPC group into native owned arrays.
  !! The parser uses integer operations so that it does not change FP flags.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use physics_configuration_text_port
  implicit none
  private
  public :: physics_output_requests, parse_physics_output_requests
  type physics_output_requests
    !! Counts and codes follow the nine selected output families.
    !! The six real level arrays retain their family-specific units.
    integer(int32) :: counts(9), codes(64, 9), model_levels(64)
    real(real64) :: levels(64, 6)
    character(len=8) :: format
  end type
contains
  integer(int32) function parse_physics_output_requests(text, output) result(status)
    !! Return zero on success or two without changing output.
    !! text contains 1 to 262144 ASCII bytes. The output and text are
    !! complete disjoint native owners. Each array admits at most 64 values.
    character(len=*), intent(in) :: text
    type(physics_output_requests), intent(inout) :: output
    type(physics_output_requests) :: staged
    character(len=7), parameter :: keys(26) = [character(len=7) :: &
                                  'nfp3dfs', 'nfp3dfp', 'nfp3dfh', 'nfp3dft', 'nfp3dfv', 'nfp3dfi', 'nfp3dff', 'nfp2df', 'nfpphy', &
                                  'mfp3dfs', 'mfp3dfp', 'mfp3dfh', 'mfp3dft', 'mfp3dfv', 'mfp3dfi', 'mfp3dff', 'mfp2df', 'mfpphy', &
                                               'nrfp3s', 'rfp3p', 'rfp3h', 'rfp3th', 'rfp3pv', 'rfp3i', 'rfp3f', 'cfpfmt']
    integer(int64), parameter :: default_bits(6) = [ &
                                 int(z'C022000000000000', int64), int(z'C022000000000000', int64), &
                                 int(z'C022000000000000', int64), int(z'42029FE50E000000', int64), &
                                 int(z'C0C3878000000000', int64), int(z'C022000000000000', int64)]
    integer :: n, cursor, first, last, key, family, count, capacity, code
    integer(int64) :: number, bits
    logical :: seen(26), valid, negative
    character :: quote
    status = 2_int32
    n = len(text)
    if (n < 1 .or. n > 262144) return
    cursor = find_physics_group(text, 'NAMFPC', .false.)
    if (cursor == 0) return
    staged%counts = 0_int32; staged%codes = 0_int32
    staged%codes(:, 9) = -9999_int32; staged%model_levels = -9_int32
    do family = 1, 6
      staged%levels(:, family) = transfer(default_bits(family), 0.0_real64)
    end do
    staged%format = 'GAUSS   '
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
      do key = 1, 26
        if (physics_fold_equal(text(first:last), trim(keys(key)))) exit
      end do
      if (key > 26) return
      if (seen(key)) return
      seen(key) = .true.
      call skip_physics_space(text, cursor)
      if (cursor > n) return
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
        staged%format = 'MODEL   '
        call skip_physics_space(text, cursor)
        if (cursor > n) return
        if (text(cursor:cursor) == ',') cursor = cursor + 1
        cycle
      end if
      capacity = 64
      if (key <= 9) capacity = 1
      count = 0
      do
        if (count >= capacity) return
        first = cursor
        do while (cursor <= n)
          if (physics_space(text(cursor:cursor))) exit
          if (index(',/!', text(cursor:cursor)) /= 0) exit
          cursor = cursor + 1
        end do
        last = cursor - 1
        call parse_integral_token(text(first:last), key >= 20, number, negative, valid)
        if (.not. valid) return
        count = count + 1
        select case (key)
        case (1:9)
          if (number < 0_int64 .or. number > 64_int64) return
          if (key == 9 .and. number /= 0_int64) return
          staged%counts(key) = int(number, int32)
        case (10:18)
          if (number < 0_int64 .or. number > 686_int64) return
          staged%codes(count, key - 9) = int(number, int32)
        case (19)
          if (number < 0_int64 .or. number > 64_int64) then
            if (number /= -99_int64 .and. number /= -9_int64) return
          end if
          staged%model_levels(count) = int(number, int32)
        case (20:25)
          bits = exact_integer_bits(number, negative)
          staged%levels(count, key - 19) = transfer(bits, 0.0_real64)
        end select
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
    if (staged%format /= 'MODEL   ') return
    do family = 1, 9
      do count = 1, staged%counts(family)
        if (staged%codes(count, family) < 1 .or. staged%codes(count, family) > 686) return
      end do
    end do
    output = staged
    status = 0_int32
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
end module physics_output_request_validation_port
