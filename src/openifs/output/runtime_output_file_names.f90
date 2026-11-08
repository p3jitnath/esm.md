!> Structured ports of the generated output-name routines.
!! Prefixes and results contain 256 characters. Time steps are dimensionless;
!! the optional time step has units of seconds. All failure returns leave
!! the output unchanged. The caller supplies nearest-even FP64 arithmetic.
module runtime_output_file_names_port
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  implicit none
  private
  public :: make_output_name, make_fullpos_output_file_names, output_header_count
  integer(int64), save :: header_counts(0:1) = 0_int64
contains
  !> Write decimal digits in source order, retaining the source overflow rule.
  subroutine decimal_part(value, width, starred, text)
    integer(int32), intent(in) :: value, width
    logical, intent(in) :: starred
    character(*), intent(out) :: text
    integer(int32) :: remaining, k, digit
    text = ' '
    remaining = value
    do k = width, 1, -1
      if (starred) then
        text(k:k) = '*'
      else
        digit = modulo(remaining, 10_int32)
        text(k:k) = achar(iachar('0') + digit)
        remaining = remaining/10_int32
      end if
    end do
  end subroutine decimal_part

  !> Build the generated no-time-step-argument SUFPOFNAME name.
  !! digits>0 adds '+' and the selected zero minute/second suffix.
  !! digits<=0 adds raw step digits. The accepted width is at most 16.
  subroutine make_output_name(prefix, step, digits, time_format, filename, status)
    character(*), intent(in) :: prefix
    integer(int32), intent(in) :: step, digits, time_format
    character(*), intent(inout) :: filename
    integer(int32), intent(out) :: status
    character(23) :: increment
    character(16) :: decimal
    integer :: width, used, prefix_length
    logical :: positive, starred
    status = 2_int32
    if (len(prefix) /= 256 .or. len(filename) /= 256) return
    positive = digits > 0
    if (abs(int(digits, int64)) > 16_int64) return
    width = int(abs(int(digits, int64)))
    if (positive) then
      if (width > 6 .or. time_format < 0 .or. time_format > 2) return
      used = 1 + width + 3*time_format
    else
      used = width
    end if
    prefix_length = len_trim(prefix)
    if (prefix_length + used > 256) return
    starred = step < 0
    if (positive .and. step > 999999_int32) starred = .true.
    call decimal_part(step, int(width, int32), starred, decimal)
    increment = ' '
    if (positive) then
      increment(1:1) = '+'
      if (width > 0) increment(2:1 + width) = decimal(1:width)
      if (time_format > 0) increment(2 + width:4 + width) = ':00'
      if (time_format == 2) increment(5 + width:7 + width) = ':00'
    else if (width > 0) then
      increment(1:width) = decimal(1:width)
    end if
    filename = ' '
    if (prefix_length > 0) filename(1:prefix_length) = prefix(1:prefix_length)
    if (used > 0) filename(prefix_length + 1:prefix_length + used) = increment(1:used)
    if (header_counts(1) == huge(0_int64)) then
      header_counts(1) = -huge(0_int64) - 1_int64
    else
      header_counts(1) = header_counts(1) + 1_int64
    end if
    status = 0_int32
  end subroutine make_output_name

  !> Return one of the two retained zero-based diagnostic counts.
  function output_header_count(index) result(count)
    integer(int64), intent(in) :: index
    integer(int64) :: count
    count = 0_int64
    if (index >= 0_int64 .and. index < 2_int64) count = header_counts(index)
  end function output_header_count

  !> Build one to eight names from typed prefix and clock metadata.
  !! step absent selects INIT. A positive digit count and a present time_step
  !! select the ordered hour/minute/second calculation. A negative count
  !! writes raw step digits. extension has at most 256 characters.
  !! The typed metadata replaces the old character-array descriptors.
  subroutine make_fullpos_output_file_names(prefixes, filenames, time_format, status, step, extension, digits, time_step)
    character(*), intent(in) :: prefixes(:)
    character(*), intent(inout) :: filenames(:)
    integer(int32), intent(in) :: time_format
    integer(int32), intent(out) :: status
    integer(int32), intent(in), optional :: step, digits
    character(*), intent(in), optional :: extension
    real(real64), intent(in), optional :: time_step
    character(23) :: increment
    character(16) :: decimal
    integer(int32) :: selected_digits, hours, minutes, seconds, width
    integer :: used, n, k, prefix_lengths(8), extension_length
    integer(int64) :: time_word
    real(real64) :: elapsed, quotient, temporary
    status = 2_int32
    n = size(prefixes)
    if (n < 1 .or. n > 8 .or. size(filenames) /= n) return
    if (len(prefixes) /= 256 .or. len(filenames) /= 256) return
    if (time_format < 0 .or. time_format > 2) return
    selected_digits = 3_int32
    if (present(digits)) selected_digits = digits
    if (selected_digits == 0) return
    if (abs(int(selected_digits, int64)) > 16_int64) return
    width = int(abs(int(selected_digits, int64)), int32)
    if (selected_digits > 0 .and. width > 6) return
    extension_length = 0
    if (present(extension)) then
      if (len(extension) > 256) return
      extension_length = len_trim(extension)
    end if
    increment = ' '
    if (.not. present(step)) then
      increment(1:4) = 'INIT'
      used = 4
    else
      if (step < 0) return
      hours = step
      minutes = 0_int32
      seconds = 0_int32
      if (selected_digits > 0 .and. present(time_step)) then
        time_word = transfer(time_step, time_word)
        if (time_word <= 0_int64) return
        if (iand(time_word, int(z'7ff0000000000000', int64)) == int(z'7ff0000000000000', int64)) return
        elapsed = real(step, real64)*time_step
        quotient = elapsed/3600.0_real64
        if (quotient > 2147483647.0_real64) return
        if (time_format == 0) then
          hours = nint(quotient, int32)
        else
          hours = int(quotient, int32)
          temporary = real(hours, real64)*3600.0_real64
          elapsed = elapsed - temporary
          quotient = elapsed/60.0_real64
          if (time_format == 1) then
            minutes = nint(quotient, int32)
          else
            minutes = int(quotient, int32)
            temporary = real(minutes, real64)*60.0_real64
            elapsed = elapsed - temporary
            seconds = nint(elapsed, int32)
          end if
        end if
      end if
      if (selected_digits > 0) then
        increment(1:1) = '+'
        call decimal_part(hours, width, hours > 999999_int32, decimal)
        increment(2:1 + width) = decimal(1:width)
        used = 1 + width
        if (time_format > 0) then
          increment(used + 1:used + 1) = ':'
          increment(used + 2:used + 2) = achar(iachar('0') + minutes/10_int32)
          increment(used + 3:used + 3) = achar(iachar('0') + modulo(minutes, 10_int32))
          used = used + 3
          if (time_format == 2) then
            increment(used + 1:used + 1) = ':'
            increment(used + 2:used + 2) = achar(iachar('0') + seconds/10_int32)
            increment(used + 3:used + 3) = achar(iachar('0') + modulo(seconds, 10_int32))
            used = used + 3
          end if
        end if
      else
        call decimal_part(hours, width, .false., decimal)
        increment(1:width) = decimal(1:width)
        used = width
      end if
    end if
    do k = 1, n
      prefix_lengths(k) = len_trim(prefixes(k))
      if (prefix_lengths(k) + used + extension_length > 256) return
    end do
    do k = 1, n
      filenames(k) = ' '
      if (prefix_lengths(k) > 0) filenames(k) (1:prefix_lengths(k)) = prefixes(k) (1:prefix_lengths(k))
      filenames(k) (prefix_lengths(k) + 1:prefix_lengths(k) + used) = increment(1:used)
 if(extension_length>0) filenames(k)(prefix_lengths(k)+used+1:prefix_lengths(k)+used+extension_length)=extension(1:extension_length)
    end do
    status = 0_int32
  end subroutine make_fullpos_output_file_names
end module runtime_output_file_names_port
