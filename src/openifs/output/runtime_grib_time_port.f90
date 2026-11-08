module runtime_grib_time_port
  !! Set GRIB forecast times through the public ecCodes interface.
  !! Time step dt is in seconds. The previous table has five parameter IDs
  !! followed by their five previous model-step indices.
  use, intrinsic :: iso_c_binding
  implicit none
  private
  public :: set_runtime_grib_time

  interface
    function codes_set_long(handle, key, value) bind(c, name="codes_set_long") result(status)
      import
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      integer(c_long), value :: value
      integer(c_int) :: status
    end function
    function codes_set_string(handle, key, text, length) bind(c, name="codes_set_string") result(status)
      import
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*), text(*)
      integer(c_size_t), intent(inout) :: length
      integer(c_int) :: status
    end function
  end interface

contains

  function set_runtime_grib_time(handle, parameter_id, nstep, dt, hours_mode, previous, valid_output) &
    bind(c, name="md2asm_set_runtime_grib_time_fortran") result(status)
    !! Port runtime_grib_time.S without private OpenIFS object layouts.
    !! Inputs use the compiler C ABI. The caller owns the borrowed handle
    !! and the ten int32 table entries. valid_output changes only on success.
    !! The caller selects nearest rounding and gradual underflow.
    type(c_ptr), value :: handle
    integer(c_int), value :: parameter_id, nstep, hours_mode
    real(c_double), value :: dt
    integer(c_int), intent(in) :: previous(10)
    integer(c_int), intent(inout) :: valid_output
    integer(c_int) :: status, previous_step, seconds, start, type_index, valid
    integer :: j
    integer(c_int64_t) :: dt_bits, difference
    real(c_double) :: elapsed, previous_elapsed
    logical :: zero_interval, found
    integer(c_int), parameter :: cases(4, 24) = reshape([ &
                                                        228026, 10800, 0, 1, 228027, 10800, 0, 1, 228028, 10800, 0, 1, &
                                                        228222, 10800, 0, 1, 228223, 10800, 0, 1, 121, 21600, 0, 1, &
                                                        122, 21600, 0, 1, 123, 21600, 0, 1, 228224, 21600, 0, 1, &
                                                        228225, 21600, 0, 1, 228051, 3600, 1, 0, 228053, 3600, 1, 0, &
                                                        228057, 10800, 1, 0, 228059, 10800, 1, 0, 228058, 21600, 1, 0, &
                                                        228060, 21600, 1, 0, 228035, 21600, 0, 0, 228036, 21600, 0, 0, &
                                                        260320, 3600, 2, 0, 260321, 10800, 2, 0, 260339, 21600, 2, 0, &
                                                        260318, 3600, 3, 0, 260319, 10800, 3, 0, 260338, 21600, 3, 0], [4, 24])
    character(8), parameter :: types(0:5) = [character(8) :: &
                                             'max', 'avg', 'mode', 'severity', 'accum', 'instant']

    status = 2
    if (.not. c_associated(handle)) return
    if (parameter_id < 0 .or. nstep < 0 .or. hours_mode < 0 .or. hours_mode > 1) return
    dt_bits = transfer(dt, dt_bits)
    if (btest(dt_bits, 63) .or. dt_bits == 0_c_int64_t) return
    if (ibits(dt_bits, 52, 11) == 2047_c_int64_t) return

    previous_step = -1
    do j = 1, 5
      if (previous(j) == parameter_id) then
        previous_step = previous(5 + j)
        exit
      end if
    end do
    if (hours_mode == 0) then
      elapsed = real(nstep, c_double)*dt
    else
      elapsed = real(nstep, c_double)*3600.0_c_double
    end if
    if (elapsed >= 2147483648.0_c_double) return
    seconds = int(elapsed, c_int)
    valid = 1
    zero_interval = .true.
    start = -9999
    type_index = 5
    if (previous_step >= 0) then
      if (.not. previous_time_fits(previous_step, dt_bits)) return
    else
      found = .false.
      do j = 1, 24
        if (cases(1, j) /= parameter_id) cycle
        found = .true.
        type_index = cases(3, j)
        if (modulo(seconds, 3600_c_int) /= 0) return
        start = seconds - cases(2, j)
        if (cases(4, j) /= 0) then
          start = max(start, 0_c_int)
        else
          if (start < 0) valid = 0
        end if
        exit
      end do
      if (.not. found) then
        difference = int(parameter_id, c_int64_t) - 222001_c_int64_t
        if (difference < 0 .or. difference > 255) difference = int(parameter_id, c_int64_t) - 223001_c_int64_t
        if (difference >= 0 .and. difference <= 255) then
          type_index = 4
          start = 0
          zero_interval = .false.
        end if
      end if
    end if

    status = 0
    call put_long('timeRangeIndicator', 0_c_int)
    if (status /= 0) return
    if (previous_step >= 0) then
      previous_elapsed = real(previous_step, c_double)*dt
      previous_elapsed = previous_elapsed + 0.0_c_double
      start = int(previous_elapsed, c_int)
      call put_string('stepType', 'max')
      call put_string('stepUnits', 's')
      call put_long('startStep', start)
      call put_long('endStep', seconds)
    else
      call put_string('stepType', trim(types(type_index)))
      call put_string('stepUnits', 's')
      if (valid /= 0 .and. start >= 0) call put_long('startStep', start)
      call put_long('endStep', seconds)
    end if
    if (seconds == 0 .and. valid /= 0 .and. zero_interval) then
      call put_string('stepType', 'instant')
      call put_long('timeRangeIndicator', 1_c_int)
    end if
    if (seconds /= 0) then
      if (modulo(seconds, 3600_c_int) == 0) call put_string('stepUnits', 'h')
    end if
    if (status == 0) valid_output = valid

  contains

    subroutine put_long(key, value)
      character(*), intent(in) :: key
      integer(c_int), intent(in) :: value
      if (status /= 0) return
      status = codes_set_long(handle, key//c_null_char, int(value, c_long))
    end subroutine

    subroutine put_string(key, value)
      character(*), intent(in) :: key, value
      integer(c_size_t) :: length
      if (status /= 0) return
      length = int(len(value), c_size_t)
      status = codes_set_string(handle, key//c_null_char, value//c_null_char, length)
    end subroutine
  end function

  pure logical function previous_time_fits(step, dt_bits) result(fits)
    !! Admit the rounded int32 conversion without moving FP arithmetic
    !! before the first ecCodes setter. Two 64-bit limbs hold the product.
    integer(c_int), intent(in) :: step
    integer(c_int64_t), intent(in) :: dt_bits
    integer(c_int64_t), parameter :: mask32 = int(z'00000000ffffffff', c_int64_t)
    integer(c_int64_t), parameter :: sign_bit = int(z'8000000000000000', c_int64_t)
    integer(c_int64_t), parameter :: bound = int(z'003fffffffffffff', c_int64_t)
    integer(c_int64_t) :: exponent, mantissa, low_product, high_product, low, high
    integer(c_int64_t) :: low_bound, high_bound
    integer :: shift
    fits = .true.
    if (step == 0) return
    exponent = ibits(dt_bits, 52, 11)
    if (exponent <= 1022) return
    fits = .false.
    if (exponent >= 1054) return
    mantissa = ibset(ibits(dt_bits, 0, 52), 52)
    low_product = iand(mantissa, mask32)*int(step, c_int64_t)
    high_product = shiftr(mantissa, 32)*int(step, c_int64_t) + shiftr(low_product, 32)
    low = ior(iand(low_product, mask32), shiftl(iand(high_product, mask32), 32))
    high = shiftr(high_product, 32)
    if (exponent == 1053) then
      fits = high == 0 .and. shiftr(low, 53) == 0
      return
    end if
    shift = 1052 - int(exponent)
    low_bound = shiftl(bound, shift)
    high_bound = 0
    if (shift /= 0) high_bound = shiftr(bound, 64 - shift)
    if (high < high_bound) then
      fits = .true.
    else if (high == high_bound) then
      fits = ieor(low, sign_bit) < ieor(low_bound, sign_bit)
    end if
  end function
end module
