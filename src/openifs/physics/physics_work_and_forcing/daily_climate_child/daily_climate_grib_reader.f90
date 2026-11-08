!> Read one actual daily climate snapshot using the public ecCodes service.
module forecast_daily_climate_grib
  use iso_c_binding
  use iso_fortran_env, only: int32, int64, real64
  implicit none
  private
  public :: read_daily_climate_snapshot, source_climate_julian_day
  interface
    function file_open(path, mode) bind(c, name="fopen") result(stream)
      import
      character(c_char), intent(in) :: path(*), mode(*)
      type(c_ptr) :: stream
    end function
    function file_close(stream) bind(c, name="fclose") result(status)
      import
      type(c_ptr), value :: stream
      integer(c_int) :: status
    end function
    function file_error(stream) bind(c, name="ferror") result(status)
      import
      type(c_ptr), value :: stream
      integer(c_int) :: status
    end function
    function file_eof(stream) bind(c, name="feof") result(status)
      import
      type(c_ptr), value :: stream
      integer(c_int) :: status
    end function
    function errno_address() bind(c, name="__errno_location") result(address)
      import
      type(c_ptr) :: address
    end function
    function new_message(context, stream, error) bind(c, name="codes_grib_handle_new_from_file") result(handle)
      import
      type(c_ptr), value :: context, stream
      integer(c_int), intent(out) :: error
      type(c_ptr) :: handle
    end function
    function delete_message(handle) bind(c, name="codes_handle_delete") result(status)
      import
      type(c_ptr), value :: handle
      integer(c_int) :: status
    end function
    function get_long(handle, key, value) bind(c, name="codes_get_long") result(status)
      import
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      integer(c_long), intent(out) :: value
      integer(c_int) :: status
    end function
    function set_long(handle, key, value) bind(c, name="codes_set_long") result(status)
      import
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      integer(c_long), value :: value
      integer(c_int) :: status
    end function
    function get_size(handle, key, length) bind(c, name="codes_get_size") result(status)
      import
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      integer(c_size_t), intent(out) :: length
      integer(c_int) :: status
    end function
    function get_values(handle, key, values, length) bind(c, name="codes_get_double_array") result(status)
      import
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      real(c_double), intent(inout) :: values(*)
      integer(c_size_t), intent(inout) :: length
      integer(c_int) :: status
    end function
    function get_longs(handle, key, values, length) bind(c, name="codes_get_long_array") result(status)
      import
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      integer(c_long), intent(out) :: values(*)
      integer(c_size_t), intent(inout) :: length
      integer(c_int) :: status
    end function
    function is_missing(handle, key, error) bind(c, name="codes_is_missing") result(missing)
      import
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      integer(c_int), intent(out) :: error
      integer(c_int) :: missing
    end function
    function set_double(handle, key, value) bind(c, name="codes_set_double") result(status)
      import
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      real(c_double), value :: value
      integer(c_int) :: status
    end function
    function get_string(handle, key, value, length) bind(c, name="codes_get_string") result(status)
      import
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      character(c_char), intent(out) :: value(*)
      integer(c_size_t), intent(inout) :: length
      integer(c_int) :: status
    end function
    function file_tell(stream) bind(c, name="ftello") result(offset)
      import
      type(c_ptr), value :: stream
      integer(c_int64_t) :: offset
    end function
    function file_seek(stream, offset, origin) bind(c, name="fseeko") result(status)
      import
      type(c_ptr), value :: stream
      integer(c_int64_t), value :: offset
      integer(c_int), value :: origin
      integer(c_int) :: status
    end function
  end interface
contains
!> Scan complete source record groups, then decode the required local snapshot.
!! PATH is a caller-owned filename; no original model routine is loaded.
!! ROWS is the complete north-to-south reduced-grid row vector. GLOBAL_INDEX
!! maps each local point to the genuine global GRIB order. STAGED(local,15)
!! is private caller work. It commits to CLIMR only after this entry succeeds.
!! The caller supplies public codec capacity separately from these named buffers.
  integer(int32) function read_daily_climate_snapshot(path, global_points, order, rows, global_index, parameters, &
                                                  initial_date, current_date, final_date, staged, interval, next_day) result(status)
    character(*), intent(in) :: path
    integer(int32), intent(in) :: global_points, order, rows(:), global_index(:), parameters(15)
    integer(int32), intent(in) :: initial_date, current_date, final_date
    real(real64), contiguous, intent(inout) :: staged(:, :)
    integer(int32), intent(out) :: interval, next_day
    real(real64), allocatable :: values(:)
    integer(c_long), allocatable :: message_rows(:)
    integer(c_int64_t) :: offsets(10000), start
    integer(int32) :: dates(10000), days(10000), groups, record, slot, selected, j, initial_day, current_day, final_day, error_alloc
    integer(c_int) :: error, ignored, close_status
    integer(c_long) :: parameter, date, n, value_count, bitmap
    integer(c_size_t) :: count
    type(c_ptr) :: stream, handle
    status = 2; interval = 0; next_day = 0
    if (len_trim(path) < 1 .or. len_trim(path) > 4095 .or. index(path, c_null_char) /= 0) return
    if (global_points < 1 .or. global_points > 6599680 .or. order < 1 .or. order > 1280) return
    if (size(rows) /= 2*order .or. any(rows < 1)) return
    if (sum(int(rows, int64)) /= int(global_points, int64)) return
    if (size(global_index) < 1 .or. size(global_index) > global_points) return
    if (any(global_index < 1) .or. any(global_index > global_points)) return
    if (size(staged, 1) /= size(global_index) .or. size(staged, 2) /= 15) return
    if (any(parameters /= [31, 139, 174, 15, 16, 17, 18, 210186, 210187, 210188, 210189, 210190, 210191, 66, 67])) return
    initial_day = source_climate_julian_day(initial_date)
    current_day = source_climate_julian_day(current_date)
    final_day = source_climate_julian_day(final_date)
    if (min(initial_day, current_day, final_day) < 1 .or. current_day < initial_day .or. final_day < current_day) return
    allocate (values(global_points), message_rows(size(rows)), stat=error_alloc)
    if (error_alloc /= 0) then
      status = 1
      return
    end if
    stream = file_open(trim(path)//c_null_char, 'rb'//c_null_char)
    handle = c_null_ptr
    status = 3
    if (.not. c_associated(stream)) return
    groups = 0; record = 0
    do
      start = file_tell(stream)
      if (start < 0) goto 900
      error = 0
      handle = new_message(c_null_ptr, stream, error)
      if (.not. c_associated(handle)) then
        if (file_error(stream) /= 0 .or. file_eof(stream) == 0) goto 900
        if (error /= 0 .and. error /= -1) goto 900
        exit
      end if
      if (error /= 0) goto 900
      slot = mod(record, 15) + 1
      status = 4
      if (slot == 1) then
        if (groups >= 10000) goto 900
        groups = groups + 1; offsets(groups) = start
      end if
      status = 3
      if (get_long(handle, 'paramId'//c_null_char, parameter) /= 0) goto 900
      if (get_long(handle, 'dataDate'//c_null_char, date) /= 0) goto 900
      status = 4
      if (parameter /= parameters(slot)) goto 900
      if (slot == 1) then
        if (date < 10101 .or. date > 99991231) goto 900
        dates(groups) = int(date, int32)
        days(groups) = source_climate_julian_day(dates(groups))
        if (days(groups) < 1) goto 900
      else
        if (date /= dates(groups)) goto 900
      end if
      status = validate_climate_grid(handle, global_points, order, rows, message_rows)
      if (status /= 0) goto 900
      status = 3
      error = delete_message(handle); handle = c_null_ptr
      if (error /= 0) goto 900
      record = record + 1
    end do
    status = 4
    if (mod(record, 15) /= 0 .or. groups < 2) goto 900
    interval = days(2) - days(1)
    if (interval < 1) goto 900
    do j = 2, groups
      if (days(j) - days(j - 1) /= interval) goto 900
    end do
! The original first scan requires an actual following group and enough coverage.
    if (initial_day < days(1) .or. initial_day >= days(groups)) goto 900
    if (final_day - days(groups) > interval) goto 900
    if (current_day >= days(groups) + interval) goto 900
    selected = 0
    do j = 1, groups
      if (days(j) > current_day) exit
      selected = j
    end do
    if (selected < 1) goto 900
    next_day = days(selected) + interval
    status = 3
    if (file_seek(stream, offsets(selected), 0_c_int) /= 0) goto 900
    do slot = 1, 15
      error = 0
      handle = new_message(c_null_ptr, stream, error)
      if (error /= 0 .or. .not. c_associated(handle)) goto 900
      if (get_long(handle, 'paramId'//c_null_char, parameter) /= 0) goto 900
      if (get_long(handle, 'dataDate'//c_null_char, date) /= 0) goto 900
      status = 4
      if (parameter /= parameters(slot) .or. date /= dates(selected)) goto 900
      status = 3
      if (set_double(handle, 'missingValue'//c_null_char, 19591204.0_real64) /= 0) goto 900
      count = int(global_points, c_size_t)
      if (get_values(handle, 'values'//c_null_char, values, count) /= 0) goto 900
      status = 4
      if (count /= global_points) goto 900
      status = 3
      if (get_long(handle, 'bitmapPresent'//c_null_char, bitmap) /= 0) goto 900
      if (bitmap == 1 .and. parameters(slot) == 31) then
        do j = 1, global_points
          if (values(j) == 19591204.0_real64) values(j) = 0.0_real64
        end do
      end if
      do j = 1, size(global_index)
        staged(j, slot) = values(global_index(j))
      end do
      error = delete_message(handle); handle = c_null_ptr
      if (error /= 0) goto 900
    end do
    status = 0
900 continue
    if (c_associated(handle)) ignored = delete_message(handle)
    close_status = file_close(stream)
    if (status == 0 .and. close_status /= 0) status = 3
  end function

!> Retain the source Gregorian date formula and its two FP64 products.
!! Return the same integer truncation of the source Julian day, or zero for
!! a refused calendar date. Input dates are YYYYMMDD; output uses source days.
  integer(int32) function source_climate_julian_day(date) result(day)
    integer(int32), intent(in) :: date
    integer(int32) :: year, month, d, yy, mm, whole, md(12)
    real(real64), volatile :: year_product, month_product, julian
    day = 0; year = date/10000; month = mod(date/100, 100); d = mod(date, 100)
    if (year < 1 .or. year > 9999 .or. month < 1 .or. month > 12) return
    md = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    if (mod(year, 4) == 0 .and. (mod(year, 100) /= 0 .or. mod(year, 400) == 0)) md(2) = 29
    if (d < 1 .or. d > md(month)) return
    yy = year - (1 - sign(1, month - 3))/2
    mm = month + 6*(1 - sign(1, month - 3))
    year_product = 365.25_real64*real(yy, real64)
    month_product = 30.601_real64*real(mm + 1, real64)
    whole = 2 - yy/100 + (yy/100)/4 + int(year_product, int32) + int(month_product, int32) + d
    julian = 1720994.5_real64 + real(whole, real64)
    day = int(julian, int32)
  end function

!> Compare every public Gaussian row and consumed level representation.
  integer(int32) function validate_climate_grid(handle, global_points, order, rows, scratch) result(status)
    type(c_ptr), intent(in) :: handle
    integer(int32), intent(in) :: global_points, order, rows(:)
    integer(c_long), intent(inout) :: scratch(:)
    integer(c_long) :: n
    integer(c_size_t) :: count, length
    character(c_char) :: grid(32), level(32)
    integer :: j, code
    status = 3
    length = 32
    if (get_string(handle, 'gridType'//c_null_char, grid, length) /= 0) return
    status = 4
    if (.not. same_c_string(grid, 'regular_gg') .and. .not. same_c_string(grid, 'reduced_gg')) return
    status = 3
    length = 32
    if (get_string(handle, 'typeOfLevel'//c_null_char, level, length) /= 0) return
    status = 4
    if (.not. same_c_string(level, 'surface') .and. .not. same_c_string(level, 'depthBelowLandLayer')) return
    status = 3
    if (get_long(handle, 'N'//c_null_char, n) /= 0) return
    status = 4
    if (n /= order) return
    status = 3
    if (get_size(handle, 'values'//c_null_char, count) /= 0) return
    status = 4
    if (count /= global_points) return
    if (same_c_string(grid, 'reduced_gg')) then
      status = 3
      if (get_size(handle, 'pl'//c_null_char, count) /= 0) return
      status = 4
      if (count /= size(rows)) return
      status = 3
      if (get_longs(handle, 'pl'//c_null_char, scratch, count) /= 0) return
      status = 4
      if (count /= size(rows)) return
      do j = 1, size(rows)
        if (scratch(j) /= rows(j)) return
      end do
    else
      if (any(rows /= 4*order)) return
    end if
    status = 0
  end function
  logical function same_c_string(value, expected) result(equal)
    character(c_char), intent(in) :: value(:)
    character(*), intent(in) :: expected
    integer :: j
    equal = .false.
    if (size(value) <= len(expected)) return
    do j = 1, len(expected)
      if (value(j) /= expected(j:j)) return
    end do
    equal = value(len(expected) + 1) == c_null_char
  end function
end module forecast_daily_climate_grib
