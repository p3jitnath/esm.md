module initial_grib_field_reader_port
  !! Decode initial weather fields without changing their physical units.
  !! Public ecCodes supplies decoding. This module owns files, message handles,
  !! ordered label checks, output placement and cleanup.
  use, intrinsic :: iso_c_binding
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  implicit none
  private
  public :: initial_field_schema, read_initial_fields
  public :: make_initial_spectral_schema, make_initial_upper_air_schema
  public :: make_initial_surface_schema, make_operational_spectral_schema
  public :: make_operational_surface_schema, make_operational_upper_air_schema

  type :: initial_field_schema
    integer(c_int64_t) :: value_count = 0
    integer :: metadata_words = 3, gaussian_order = 0
    integer(c_int64_t), allocatable :: labels(:, :)
  end type

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
  end interface

contains

  function read_initial_fields(path, schema, values, metadata, messages_read) result(status)
    !! values has shape(value_count,at least record_count), in message order.
    !! metadata has three or five int64 rows and at least record_count columns.
    !! Its rows are parameter, level, value count and optional date/time.
    !! On failure, only committed metadata/count and any partially decoded
    !! current value record may change. All resources close on valid exits.
    !! The caller owns disjoint buffers and the qualified input file. It
    !! establishes the declared nearest-rounding, gradual-underflow environment.
    character(*), intent(in) :: path
    type(initial_field_schema), intent(in) :: schema
    real(c_double), contiguous, intent(inout) :: values(:, :)
    integer(c_int64_t), contiguous, intent(inout) :: metadata(:, :)
    integer(c_int64_t), intent(inout) :: messages_read
    integer(c_int) :: status, error, ignored
    integer(c_int), pointer :: error_number
    integer(c_int) :: saved_errno
    type(ieee_status_type) :: saved_ieee_status
    type(c_ptr) :: stream, handle
    integer(c_long) :: parameter_id, level, date, time
    integer(c_size_t) :: count
    integer :: record, records

    status = 1
    if (.not. allocated(schema%labels)) return
    if (size(schema%labels, 1) /= 4) return
    records = size(schema%labels, 2)
    if (records < 1 .or. schema%value_count < 1) return
    if (schema%metadata_words /= 3 .and. schema%metadata_words /= 5) return
    if (size(values, 1, kind=c_int64_t) /= schema%value_count .or. size(values, 2) < records) return
    if (size(metadata, 1) /= schema%metadata_words .or. size(metadata, 2) < records) return
    call ieee_get_status(saved_ieee_status)
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    stream = file_open(path//c_null_char, 'rb'//c_null_char)
    handle = c_null_ptr
    messages_read = 0
    status = 2
    if (.not. c_associated(stream)) goto 900
    do
      error = 0
      handle = new_message(c_null_ptr, stream, error)
      status = 3
      if (error /= 0) exit
      if (.not. c_associated(handle)) then
        if (file_error(stream) /= 0) exit
        if (file_eof(stream) == 0) exit
        status = 4
        if (messages_read /= records) exit
        status = 0
        exit
      end if
      status = 4
      if (messages_read >= records) exit
      record = int(messages_read) + 1
      status = 3
      if (get_long(handle, 'paramId'//c_null_char, parameter_id) /= 0) exit
      if (get_long(handle, 'level'//c_null_char, level) /= 0) exit
      if (get_size(handle, 'values'//c_null_char, count) /= 0) exit
      status = 4
      if (count /= schema%value_count) exit
      if (parameter_id /= schema%labels(1, record) .or. level /= schema%labels(2, record)) exit
      if (schema%metadata_words == 5) then
        status = 3
        if (get_long(handle, 'dataDate'//c_null_char, date) /= 0) exit
        if (get_long(handle, 'dataTime'//c_null_char, time) /= 0) exit
        status = 4
        if (date /= schema%labels(3, record) .or. time /= schema%labels(4, record)) exit
        status = validate_initial_grid(handle, schema%gaussian_order)
        if (status /= 0) exit
      end if
      status = 3
      if (get_values(handle, 'values'//c_null_char, values(:, record), count) /= 0) exit
      status = 4
      if (count /= schema%value_count) exit
      error = delete_message(handle)
      handle = c_null_ptr
      status = 3
      if (error /= 0) exit
      metadata(1, record) = parameter_id
      metadata(2, record) = level
      metadata(3, record) = schema%value_count
      if (schema%metadata_words == 5) then
        metadata(4, record) = date
        metadata(5, record) = time
      end if
      messages_read = messages_read + 1
    end do
    if (c_associated(handle)) ignored = delete_message(handle)
    error = file_close(stream)
    if (status == 0 .and. error /= 0) status = 5
900 error_number = saved_errno
    call ieee_set_status(saved_ieee_status)
  end function

  function validate_initial_grid(handle, order) result(status)
    !! Retain the two fixed grid checks from initial_spectral_field_reader.S.
    type(c_ptr), intent(in) :: handle
    integer, intent(in) :: order
    integer(c_int) :: status, error, missing
    integer(c_long) :: value, rows(2560)
    integer(c_size_t) :: count
    integer :: j, expected
    status = 3
    if (order == 1280) then
      if (get_long(handle, 'N'//c_null_char, value) /= 0) return
      status = 4
      if (value /= 1280) return
      status = 3
      if (get_long(handle, 'Nj'//c_null_char, value) /= 0) return
      status = 4
      if (value /= 2560) return
      status = 3
      if (get_long(handle, 'scanningMode'//c_null_char, value) /= 0) return
      status = 4
      if (value /= 0) return
      error = 0
      missing = is_missing(handle, 'Ni'//c_null_char, error)
      status = 3
      if (error /= 0) return
      status = 4
      if (missing /= 1) return
      status = 3
      if (get_size(handle, 'pl'//c_null_char, count) /= 0) return
      status = 4
      if (count /= 2560) return
      status = 3
      if (get_longs(handle, 'pl'//c_null_char, rows, count) /= 0) return
      status = 4
      if (count /= 2560) return
      do j = 1, 2560
        expected = 4*min(j - 1, 2560 - j) + 20
        if (rows(j) /= expected) return
      end do
    else
      status = 3
      if (get_long(handle, 'Ni'//c_null_char, value) /= 0) return
      status = 4
      if (value /= 64) return
      status = 3
      if (get_long(handle, 'Nj'//c_null_char, value) /= 0) return
      status = 4
      if (value /= 32) return
      status = 3
      if (get_long(handle, 'N'//c_null_char, value) /= 0) return
      status = 4
      if (value /= 16) return
      status = 3
      if (get_long(handle, 'scanningMode'//c_null_char, value) /= 0) return
      status = 4
      if (value /= 0) return
    end if
    status = 3
    if (set_long(handle, 'missingValue'//c_null_char, -9999_c_long) /= 0) return
    status = 0
  end function

  function make_initial_spectral_schema() result(schema)
    type(initial_field_schema) :: schema
    schema%value_count = 506_c_int64_t
    schema%metadata_words = 3
    schema%gaussian_order = 0
    schema%labels = reshape([integer(c_int64_t) :: &
                             152, 1, 0, 0, 138, 1, 0, 0, &
                             155, 1, 0, 0, 130, 1, 0, 0, &
                             138, 2, 0, 0, 155, 2, 0, 0, &
                             130, 2, 0, 0, 138, 3, 0, 0, &
                             155, 3, 0, 0, 130, 3, 0, 0, &
                             138, 4, 0, 0, 155, 4, 0, 0, &
                             130, 4, 0, 0, 138, 5, 0, 0, &
                             155, 5, 0, 0, 130, 5, 0, 0, &
                             138, 6, 0, 0, 155, 6, 0, 0, &
                             130, 6, 0, 0, 138, 7, 0, 0, &
                             155, 7, 0, 0, 130, 7, 0, 0, &
                             138, 8, 0, 0, 155, 8, 0, 0, &
                             130, 8, 0, 0, 138, 9, 0, 0, &
                             155, 9, 0, 0, 130, 9, 0, 0, &
                             138, 10, 0, 0, 155, 10, 0, 0, &
                             130, 10, 0, 0, 138, 11, 0, 0, &
                             155, 11, 0, 0, 130, 11, 0, 0, &
                             138, 12, 0, 0, 155, 12, 0, 0, &
                             130, 12, 0, 0, 138, 13, 0, 0, &
                             155, 13, 0, 0, 130, 13, 0, 0, &
                             138, 14, 0, 0, 155, 14, 0, 0, &
                             130, 14, 0, 0, 138, 15, 0, 0, &
                             155, 15, 0, 0, 130, 15, 0, 0, &
                             138, 16, 0, 0, 155, 16, 0, 0, &
                             130, 16, 0, 0, 138, 17, 0, 0, &
                             155, 17, 0, 0, 130, 17, 0, 0, &
                             138, 18, 0, 0, 155, 18, 0, 0, &
                             130, 18, 0, 0, 138, 19, 0, 0, &
                             155, 19, 0, 0, 130, 19, 0, 0, &
                             129, 0, 0, 0, 133, 1, 0, 0, &
                             133, 2, 0, 0, 133, 3, 0, 0, &
                             133, 4, 0, 0, 133, 5, 0, 0, &
                             133, 6, 0, 0, 133, 7, 0, 0, &
                             133, 8, 0, 0, 133, 9, 0, 0, &
                             133, 10, 0, 0, 133, 11, 0, 0, &
                             133, 12, 0, 0, 133, 13, 0, 0, &
                             133, 14, 0, 0, 133, 15, 0, 0, &
                             133, 16, 0, 0, 133, 17, 0, 0, &
                             133, 18, 0, 0, 133, 19, 0, 0 &
                             ], [4, 78])
  end function

  function make_initial_upper_air_schema() result(schema)
    type(initial_field_schema) :: schema
    schema%value_count = 2048_c_int64_t
    schema%metadata_words = 3
    schema%gaussian_order = 0
    schema%labels = reshape([integer(c_int64_t) :: &
                             133, 1, 0, 0, 133, 2, 0, 0, &
                             133, 3, 0, 0, 133, 4, 0, 0, &
                             133, 5, 0, 0, 133, 6, 0, 0, &
                             133, 7, 0, 0, 133, 8, 0, 0, &
                             133, 9, 0, 0, 133, 10, 0, 0, &
                             133, 11, 0, 0, 133, 12, 0, 0, &
                             133, 13, 0, 0, 133, 14, 0, 0, &
                             133, 15, 0, 0, 133, 16, 0, 0, &
                             133, 17, 0, 0, 133, 18, 0, 0, &
                             133, 19, 0, 0, 246, 1, 0, 0, &
                             247, 1, 0, 0, 248, 1, 0, 0, &
                             246, 2, 0, 0, 247, 2, 0, 0, &
                             248, 2, 0, 0, 246, 3, 0, 0, &
                             247, 3, 0, 0, 248, 3, 0, 0, &
                             246, 4, 0, 0, 247, 4, 0, 0, &
                             248, 4, 0, 0, 246, 5, 0, 0, &
                             247, 5, 0, 0, 248, 5, 0, 0, &
                             246, 6, 0, 0, 247, 6, 0, 0, &
                             248, 6, 0, 0, 246, 7, 0, 0, &
                             247, 7, 0, 0, 248, 7, 0, 0, &
                             246, 8, 0, 0, 247, 8, 0, 0, &
                             248, 8, 0, 0, 246, 9, 0, 0, &
                             247, 9, 0, 0, 248, 9, 0, 0, &
                             246, 10, 0, 0, 247, 10, 0, 0, &
                             248, 10, 0, 0, 246, 11, 0, 0, &
                             247, 11, 0, 0, 248, 11, 0, 0, &
                             246, 12, 0, 0, 247, 12, 0, 0, &
                             248, 12, 0, 0, 246, 13, 0, 0, &
                             247, 13, 0, 0, 248, 13, 0, 0, &
                             246, 14, 0, 0, 247, 14, 0, 0, &
                             248, 14, 0, 0, 246, 15, 0, 0, &
                             247, 15, 0, 0, 248, 15, 0, 0, &
                             246, 16, 0, 0, 247, 16, 0, 0, &
                             248, 16, 0, 0, 246, 17, 0, 0, &
                             247, 17, 0, 0, 248, 17, 0, 0, &
                             246, 18, 0, 0, 247, 18, 0, 0, &
                             248, 18, 0, 0, 246, 19, 0, 0, &
                             247, 19, 0, 0, 248, 19, 0, 0 &
                             ], [4, 76])
  end function

  function make_initial_surface_schema() result(schema)
    type(initial_field_schema) :: schema
    schema%value_count = 2048_c_int64_t
    schema%metadata_words = 5
    schema%gaussian_order = 16
    schema%labels = reshape([integer(c_int64_t) :: &
                             32, 1, 20041015, 1200, 32, 2, 20041015, 1200, &
                             32, 3, 20041015, 1200, 32, 4, 20041015, 1200, &
                             32, 5, 20041015, 1200, 238, 1, 20041015, 0, &
                             238, 2, 20041015, 0, 238, 3, 20041015, 0, &
                             238, 4, 20041015, 0, 238, 5, 20041015, 0, &
                             33, 1, 20041015, 0, 33, 2, 20041015, 0, &
                             33, 3, 20041015, 0, 33, 4, 20041015, 0, &
                             33, 5, 20041015, 0, 139, 0, 20041015, 1200, &
                             170, 7, 20041015, 1200, 183, 28, 20041015, 1200, &
                             236, 100, 20041015, 1200, 39, 0, 20041015, 1200, &
                             40, 7, 20041015, 1200, 41, 28, 20041015, 1200, &
                             42, 100, 20041015, 1200, 198, 0, 20041015, 1200, &
                             235, 0, 20041015, 1200, 31, 0, 20041015, 1200, &
                             34, 0, 20041015, 1200, 35, 0, 20041015, 1200, &
                             36, 7, 20041015, 1200, 37, 28, 20041015, 1200, &
                             38, 100, 20041015, 1200, 148, 0, 20041015, 1200, &
                             172, 0, 20041015, 1200, 173, 0, 20041015, 1200, &
                             174, 0, 20041015, 1200, 160, 0, 20041015, 1200, &
                             161, 0, 20041015, 1200, 162, 0, 20041015, 1200, &
                             163, 0, 20041015, 1200, 234, 0, 20041015, 1200, &
                             28, 0, 20041015, 1200, 27, 0, 20041015, 1200, &
                             30, 0, 20041015, 1200, 29, 0, 20041015, 1200, &
                             74, 0, 19960101, 0, 18, 0, 99990115, 0, &
                             18, 0, 99990215, 0, 18, 0, 99990315, 0, &
                             18, 0, 99990415, 0, 18, 0, 99990515, 0, &
                             18, 0, 99990615, 0, 18, 0, 99990715, 0, &
                             18, 0, 99990815, 0, 18, 0, 99990915, 0, &
                             18, 0, 99991015, 0, 18, 0, 99991115, 0, &
                             18, 0, 99991215, 0, 17, 0, 99990115, 0, &
                             17, 0, 99990215, 0, 17, 0, 99990315, 0, &
                             17, 0, 99990415, 0, 17, 0, 99990515, 0, &
                             17, 0, 99990615, 0, 17, 0, 99990715, 0, &
                             17, 0, 99990815, 0, 17, 0, 99990915, 0, &
                             17, 0, 99991015, 0, 17, 0, 99991115, 0, &
                             17, 0, 99991215, 0, 16, 0, 99990115, 0, &
                             16, 0, 99990215, 0, 16, 0, 99990315, 0, &
                             16, 0, 99990415, 0, 16, 0, 99990515, 0, &
                             16, 0, 99990615, 0, 16, 0, 99990715, 0, &
                             16, 0, 99990815, 0, 16, 0, 99990915, 0, &
                             16, 0, 99991015, 0, 16, 0, 99991115, 0, &
                             16, 0, 99991215, 0, 15, 0, 99990115, 0, &
                             15, 0, 99990215, 0, 15, 0, 99990315, 0, &
                             15, 0, 99990415, 0, 15, 0, 99990515, 0, &
                             15, 0, 99990615, 0, 15, 0, 99990715, 0, &
                             15, 0, 99990815, 0, 15, 0, 99990915, 0, &
                             15, 0, 99991015, 0, 15, 0, 99991115, 0, &
                             15, 0, 99991215, 0, 43, 0, 19950101, 0, &
                             66, 0, 99990115, 0, 66, 0, 99990215, 0, &
                             66, 0, 99990315, 0, 66, 0, 99990415, 0, &
                             66, 0, 99990515, 0, 66, 0, 99990615, 0, &
                             66, 0, 99990715, 0, 66, 0, 99990815, 0, &
                             66, 0, 99990915, 0, 66, 0, 99991015, 0, &
                             66, 0, 99991115, 0, 66, 0, 99991215, 0, &
                             67, 0, 99990115, 0, 67, 0, 99990215, 0, &
                             67, 0, 99990315, 0, 67, 0, 99990415, 0, &
                             67, 0, 99990515, 0, 67, 0, 99990615, 0, &
                             67, 0, 99990715, 0, 67, 0, 99990815, 0, &
                             67, 0, 99990915, 0, 67, 0, 99991015, 0, &
                             67, 0, 99991115, 0, 67, 0, 99991215, 0, &
                             228007, 0, 99990115, 0, 26, 0, 20140331, 0, &
                             228011, 0, 20041015, 0, 228012, 0, 20041015, 0, &
                             228008, 0, 20041015, 0, 228009, 0, 20041015, 0, &
                             228013, 0, 20041015, 0, 228014, 0, 20041015, 0, &
                             228010, 0, 20041015, 0, 228141, 1, 20041015, 0, &
                             228141, 2, 20041015, 0, 228141, 3, 20041015, 0, &
                             228141, 4, 20041015, 0, 228141, 5, 20041015, 0, &
                             228038, 1, 20041015, 0, 228038, 2, 20041015, 0, &
                             228038, 3, 20041015, 0, 228038, 4, 20041015, 0, &
                             228038, 5, 20041015, 0, 200199, 0, 99990615, 0, &
                             129172, 0, 20110131, 0, 200026, 0, 99990615, 0 &
                             ], [4, 140])
  end function

  function make_operational_spectral_schema() result(schema)
    type(initial_field_schema) :: schema
    schema%value_count = 1639680_c_int64_t
    schema%metadata_words = 3
    schema%gaussian_order = 0
    schema%labels = reshape([integer(c_int64_t) :: &
                             152, 1, 0, 0, 138, 1, 0, 0, &
                             155, 1, 0, 0, 130, 1, 0, 0, &
                             138, 2, 0, 0, 155, 2, 0, 0, &
                             130, 2, 0, 0, 138, 3, 0, 0, &
                             155, 3, 0, 0, 130, 3, 0, 0, &
                             138, 4, 0, 0, 155, 4, 0, 0, &
                             130, 4, 0, 0, 138, 5, 0, 0, &
                             155, 5, 0, 0, 130, 5, 0, 0, &
                             138, 6, 0, 0, 155, 6, 0, 0, &
                             130, 6, 0, 0, 138, 7, 0, 0, &
                             155, 7, 0, 0, 130, 7, 0, 0, &
                             138, 8, 0, 0, 155, 8, 0, 0, &
                             130, 8, 0, 0, 138, 9, 0, 0, &
                             155, 9, 0, 0, 130, 9, 0, 0, &
                             138, 10, 0, 0, 155, 10, 0, 0, &
                             130, 10, 0, 0, 138, 11, 0, 0, &
                             155, 11, 0, 0, 130, 11, 0, 0, &
                             138, 12, 0, 0, 155, 12, 0, 0, &
                             130, 12, 0, 0, 138, 13, 0, 0, &
                             155, 13, 0, 0, 130, 13, 0, 0, &
                             138, 14, 0, 0, 155, 14, 0, 0, &
                             130, 14, 0, 0, 138, 15, 0, 0, &
                             155, 15, 0, 0, 130, 15, 0, 0, &
                             138, 16, 0, 0, 155, 16, 0, 0, &
                             130, 16, 0, 0, 138, 17, 0, 0, &
                             155, 17, 0, 0, 130, 17, 0, 0, &
                             138, 18, 0, 0, 155, 18, 0, 0, &
                             130, 18, 0, 0, 138, 19, 0, 0, &
                             155, 19, 0, 0, 130, 19, 0, 0, &
                             138, 20, 0, 0, 155, 20, 0, 0, &
                             130, 20, 0, 0, 138, 21, 0, 0, &
                             155, 21, 0, 0, 130, 21, 0, 0, &
                             138, 22, 0, 0, 155, 22, 0, 0, &
                             130, 22, 0, 0, 138, 23, 0, 0, &
                             155, 23, 0, 0, 130, 23, 0, 0, &
                             138, 24, 0, 0, 155, 24, 0, 0, &
                             130, 24, 0, 0, 138, 25, 0, 0, &
                             155, 25, 0, 0, 130, 25, 0, 0, &
                             138, 26, 0, 0, 155, 26, 0, 0, &
                             130, 26, 0, 0, 138, 27, 0, 0, &
                             155, 27, 0, 0, 130, 27, 0, 0, &
                             138, 28, 0, 0, 155, 28, 0, 0, &
                             130, 28, 0, 0, 138, 29, 0, 0, &
                             155, 29, 0, 0, 130, 29, 0, 0, &
                             138, 30, 0, 0, 155, 30, 0, 0, &
                             130, 30, 0, 0, 138, 31, 0, 0, &
                             155, 31, 0, 0, 130, 31, 0, 0, &
                             138, 32, 0, 0, 155, 32, 0, 0, &
                             130, 32, 0, 0, 138, 33, 0, 0, &
                             155, 33, 0, 0, 130, 33, 0, 0, &
                             138, 34, 0, 0, 155, 34, 0, 0, &
                             130, 34, 0, 0, 138, 35, 0, 0, &
                             155, 35, 0, 0, 130, 35, 0, 0, &
                             138, 36, 0, 0, 155, 36, 0, 0, &
                             130, 36, 0, 0, 138, 37, 0, 0, &
                             155, 37, 0, 0, 130, 37, 0, 0, &
                             138, 38, 0, 0, 155, 38, 0, 0, &
                             130, 38, 0, 0, 138, 39, 0, 0, &
                             155, 39, 0, 0, 130, 39, 0, 0, &
                             138, 40, 0, 0, 155, 40, 0, 0, &
                             130, 40, 0, 0, 138, 41, 0, 0, &
                             155, 41, 0, 0, 130, 41, 0, 0, &
                             138, 42, 0, 0, 155, 42, 0, 0, &
                             130, 42, 0, 0, 138, 43, 0, 0, &
                             155, 43, 0, 0, 130, 43, 0, 0, &
                             138, 44, 0, 0, 155, 44, 0, 0, &
                             130, 44, 0, 0, 138, 45, 0, 0, &
                             155, 45, 0, 0, 130, 45, 0, 0, &
                             138, 46, 0, 0, 155, 46, 0, 0, &
                             130, 46, 0, 0, 138, 47, 0, 0, &
                             155, 47, 0, 0, 130, 47, 0, 0, &
                             138, 48, 0, 0, 155, 48, 0, 0, &
                             130, 48, 0, 0, 138, 49, 0, 0, &
                             155, 49, 0, 0, 130, 49, 0, 0, &
                             138, 50, 0, 0, 155, 50, 0, 0, &
                             130, 50, 0, 0, 138, 51, 0, 0, &
                             155, 51, 0, 0, 130, 51, 0, 0, &
                             138, 52, 0, 0, 155, 52, 0, 0, &
                             130, 52, 0, 0, 138, 53, 0, 0, &
                             155, 53, 0, 0, 130, 53, 0, 0, &
                             138, 54, 0, 0, 155, 54, 0, 0, &
                             130, 54, 0, 0, 138, 55, 0, 0, &
                             155, 55, 0, 0, 130, 55, 0, 0, &
                             138, 56, 0, 0, 155, 56, 0, 0, &
                             130, 56, 0, 0, 138, 57, 0, 0, &
                             155, 57, 0, 0, 130, 57, 0, 0, &
                             138, 58, 0, 0, 155, 58, 0, 0, &
                             130, 58, 0, 0, 138, 59, 0, 0, &
                             155, 59, 0, 0, 130, 59, 0, 0, &
                             138, 60, 0, 0, 155, 60, 0, 0, &
                             130, 60, 0, 0, 138, 61, 0, 0, &
                             155, 61, 0, 0, 130, 61, 0, 0, &
                             138, 62, 0, 0, 155, 62, 0, 0, &
                             130, 62, 0, 0, 138, 63, 0, 0, &
                             155, 63, 0, 0, 130, 63, 0, 0, &
                             138, 64, 0, 0, 155, 64, 0, 0, &
                             130, 64, 0, 0, 138, 65, 0, 0, &
                             155, 65, 0, 0, 130, 65, 0, 0, &
                             138, 66, 0, 0, 155, 66, 0, 0, &
                             130, 66, 0, 0, 138, 67, 0, 0, &
                             155, 67, 0, 0, 130, 67, 0, 0, &
                             138, 68, 0, 0, 155, 68, 0, 0, &
                             130, 68, 0, 0, 138, 69, 0, 0, &
                             155, 69, 0, 0, 130, 69, 0, 0, &
                             138, 70, 0, 0, 155, 70, 0, 0, &
                             130, 70, 0, 0, 138, 71, 0, 0, &
                             155, 71, 0, 0, 130, 71, 0, 0, &
                             138, 72, 0, 0, 155, 72, 0, 0, &
                             130, 72, 0, 0, 138, 73, 0, 0, &
                             155, 73, 0, 0, 130, 73, 0, 0, &
                             138, 74, 0, 0, 155, 74, 0, 0, &
                             130, 74, 0, 0, 138, 75, 0, 0, &
                             155, 75, 0, 0, 130, 75, 0, 0, &
                             138, 76, 0, 0, 155, 76, 0, 0, &
                             130, 76, 0, 0, 138, 77, 0, 0, &
                             155, 77, 0, 0, 130, 77, 0, 0, &
                             138, 78, 0, 0, 155, 78, 0, 0, &
                             130, 78, 0, 0, 138, 79, 0, 0, &
                             155, 79, 0, 0, 130, 79, 0, 0, &
                             138, 80, 0, 0, 155, 80, 0, 0, &
                             130, 80, 0, 0, 138, 81, 0, 0, &
                             155, 81, 0, 0, 130, 81, 0, 0, &
                             138, 82, 0, 0, 155, 82, 0, 0, &
                             130, 82, 0, 0, 138, 83, 0, 0, &
                             155, 83, 0, 0, 130, 83, 0, 0, &
                             138, 84, 0, 0, 155, 84, 0, 0, &
                             130, 84, 0, 0, 138, 85, 0, 0, &
                             155, 85, 0, 0, 130, 85, 0, 0, &
                             138, 86, 0, 0, 155, 86, 0, 0, &
                             130, 86, 0, 0, 138, 87, 0, 0, &
                             155, 87, 0, 0, 130, 87, 0, 0, &
                             138, 88, 0, 0, 155, 88, 0, 0, &
                             130, 88, 0, 0, 138, 89, 0, 0, &
                             155, 89, 0, 0, 130, 89, 0, 0, &
                             138, 90, 0, 0, 155, 90, 0, 0, &
                             130, 90, 0, 0, 138, 91, 0, 0, &
                             155, 91, 0, 0, 130, 91, 0, 0, &
                             138, 92, 0, 0, 155, 92, 0, 0, &
                             130, 92, 0, 0, 138, 93, 0, 0, &
                             155, 93, 0, 0, 130, 93, 0, 0, &
                             138, 94, 0, 0, 155, 94, 0, 0, &
                             130, 94, 0, 0, 138, 95, 0, 0, &
                             155, 95, 0, 0, 130, 95, 0, 0, &
                             138, 96, 0, 0, 155, 96, 0, 0, &
                             130, 96, 0, 0, 138, 97, 0, 0, &
                             155, 97, 0, 0, 130, 97, 0, 0, &
                             138, 98, 0, 0, 155, 98, 0, 0, &
                             130, 98, 0, 0, 138, 99, 0, 0, &
                             155, 99, 0, 0, 130, 99, 0, 0, &
                             138, 100, 0, 0, 155, 100, 0, 0, &
                             130, 100, 0, 0, 138, 101, 0, 0, &
                             155, 101, 0, 0, 130, 101, 0, 0, &
                             138, 102, 0, 0, 155, 102, 0, 0, &
                             130, 102, 0, 0, 138, 103, 0, 0, &
                             155, 103, 0, 0, 130, 103, 0, 0, &
                             138, 104, 0, 0, 155, 104, 0, 0, &
                             130, 104, 0, 0, 138, 105, 0, 0, &
                             155, 105, 0, 0, 130, 105, 0, 0, &
                             138, 106, 0, 0, 155, 106, 0, 0, &
                             130, 106, 0, 0, 138, 107, 0, 0, &
                             155, 107, 0, 0, 130, 107, 0, 0, &
                             138, 108, 0, 0, 155, 108, 0, 0, &
                             130, 108, 0, 0, 138, 109, 0, 0, &
                             155, 109, 0, 0, 130, 109, 0, 0, &
                             138, 110, 0, 0, 155, 110, 0, 0, &
                             130, 110, 0, 0, 138, 111, 0, 0, &
                             155, 111, 0, 0, 130, 111, 0, 0, &
                             138, 112, 0, 0, 155, 112, 0, 0, &
                             130, 112, 0, 0, 138, 113, 0, 0, &
                             155, 113, 0, 0, 130, 113, 0, 0, &
                             138, 114, 0, 0, 155, 114, 0, 0, &
                             130, 114, 0, 0, 138, 115, 0, 0, &
                             155, 115, 0, 0, 130, 115, 0, 0, &
                             138, 116, 0, 0, 155, 116, 0, 0, &
                             130, 116, 0, 0, 138, 117, 0, 0, &
                             155, 117, 0, 0, 130, 117, 0, 0, &
                             138, 118, 0, 0, 155, 118, 0, 0, &
                             130, 118, 0, 0, 138, 119, 0, 0, &
                             155, 119, 0, 0, 130, 119, 0, 0, &
                             138, 120, 0, 0, 155, 120, 0, 0, &
                             130, 120, 0, 0, 138, 121, 0, 0, &
                             155, 121, 0, 0, 130, 121, 0, 0, &
                             138, 122, 0, 0, 155, 122, 0, 0, &
                             130, 122, 0, 0, 138, 123, 0, 0, &
                             155, 123, 0, 0, 130, 123, 0, 0, &
                             138, 124, 0, 0, 155, 124, 0, 0, &
                             130, 124, 0, 0, 138, 125, 0, 0, &
                             155, 125, 0, 0, 130, 125, 0, 0, &
                             138, 126, 0, 0, 155, 126, 0, 0, &
                             130, 126, 0, 0, 138, 127, 0, 0, &
                             155, 127, 0, 0, 130, 127, 0, 0, &
                             138, 128, 0, 0, 155, 128, 0, 0, &
                             130, 128, 0, 0, 138, 129, 0, 0, &
                             155, 129, 0, 0, 130, 129, 0, 0, &
                             138, 130, 0, 0, 155, 130, 0, 0, &
                             130, 130, 0, 0, 138, 131, 0, 0, &
                             155, 131, 0, 0, 130, 131, 0, 0, &
                             138, 132, 0, 0, 155, 132, 0, 0, &
                             130, 132, 0, 0, 138, 133, 0, 0, &
                             155, 133, 0, 0, 130, 133, 0, 0, &
                             138, 134, 0, 0, 155, 134, 0, 0, &
                             130, 134, 0, 0, 138, 135, 0, 0, &
                             155, 135, 0, 0, 130, 135, 0, 0, &
                             138, 136, 0, 0, 155, 136, 0, 0, &
                             130, 136, 0, 0, 138, 137, 0, 0, &
                             155, 137, 0, 0, 130, 137, 0, 0, &
                             129, 0, 0, 0 &
                             ], [4, 413])
  end function

  function make_operational_surface_schema() result(schema)
    type(initial_field_schema) :: schema
    schema%value_count = 6599680_c_int64_t
    schema%metadata_words = 5
    schema%gaussian_order = 1280
    schema%labels = reshape([integer(c_int64_t) :: &
                             172, 0, 20110131, 0, 32, 1, 20260621, 0, &
                             32, 2, 20260621, 0, 32, 3, 20260621, 0, &
                             32, 4, 20260621, 0, 32, 5, 20260621, 0, &
                             139, 0, 20260621, 0, 170, 7, 20260621, 0, &
                             183, 28, 20260621, 0, 236, 100, 20260621, 0, &
                             39, 0, 20260621, 0, 40, 7, 20260621, 0, &
                             41, 28, 20260621, 0, 42, 100, 20260621, 0, &
                             198, 0, 20260621, 0, 235, 0, 20260621, 0, &
                             31, 0, 20260621, 0, 228008, 0, 20260621, 0, &
                             228009, 0, 20260621, 0, 228010, 0, 20260621, 0, &
                             228011, 0, 20260621, 0, 228012, 0, 20260621, 0, &
                             228013, 0, 20260621, 0, 228014, 0, 20260621, 0, &
                             34, 0, 20260621, 0, 35, 0, 20260621, 0, &
                             36, 7, 20260621, 0, 37, 28, 20260621, 0, &
                             38, 100, 20260621, 0, 148, 0, 20260621, 0, &
                             228141, 1, 20260621, 0, 238, 1, 20260621, 0, &
                             33, 1, 20260621, 0, 228038, 1, 20260621, 0, &
                             228141, 2, 20260621, 0, 238, 2, 20260621, 0, &
                             33, 2, 20260621, 0, 228038, 2, 20260621, 0, &
                             228141, 3, 20260621, 0, 238, 3, 20260621, 0, &
                             33, 3, 20260621, 0, 228038, 3, 20260621, 0, &
                             228141, 4, 20260621, 0, 238, 4, 20260621, 0, &
                             33, 4, 20260621, 0, 228038, 4, 20260621, 0, &
                             228141, 5, 20260621, 0, 238, 5, 20260621, 0, &
                             33, 5, 20260621, 0, 228038, 5, 20260621, 0, &
                             172, 0, 20260621, 0, 173, 0, 20260621, 0, &
                             174, 0, 20260621, 0, 15, 0, 20260621, 0, &
                             17, 0, 20260621, 0, 16, 0, 20260621, 0, &
                             18, 0, 20260621, 0, 210186, 0, 20260621, 0, &
                             210187, 0, 20260621, 0, 210188, 0, 20260621, 0, &
                             210189, 0, 20260621, 0, 210190, 0, 20260621, 0, &
                             210191, 0, 20260621, 0, 66, 0, 20260621, 0, &
                             67, 0, 20260621, 0, 74, 0, 20260621, 0, &
                             43, 0, 20260621, 0, 160, 0, 20260621, 0, &
                             161, 0, 20260621, 0, 162, 0, 20260621, 0, &
                             163, 0, 20260621, 0, 234, 0, 20260621, 0, &
                             28, 0, 20260621, 0, 27, 0, 20260621, 0, &
                             30, 0, 20260621, 0, 29, 0, 20260621, 0, &
                             26, 0, 20260621, 0, 228007, 0, 20260621, 0, &
                             200199, 0, 99990615, 0, 129172, 0, 20110131, 0, &
                             200026, 0, 20260621, 0 &
                             ], [4, 81])
  end function

  function make_operational_upper_air_schema() result(schema)
    type(initial_field_schema) :: schema
    schema%value_count = 6599680_c_int64_t
    schema%metadata_words = 5
    schema%gaussian_order = 1280
    schema%labels = reshape([integer(c_int64_t) :: &
                             133, 1, 20260621, 0, 203, 1, 20260621, 0, &
                             133, 2, 20260621, 0, 203, 2, 20260621, 0, &
                             133, 3, 20260621, 0, 203, 3, 20260621, 0, &
                             133, 4, 20260621, 0, 203, 4, 20260621, 0, &
                             133, 5, 20260621, 0, 203, 5, 20260621, 0, &
                             133, 6, 20260621, 0, 203, 6, 20260621, 0, &
                             133, 7, 20260621, 0, 203, 7, 20260621, 0, &
                             133, 8, 20260621, 0, 203, 8, 20260621, 0, &
                             133, 9, 20260621, 0, 203, 9, 20260621, 0, &
                             133, 10, 20260621, 0, 203, 10, 20260621, 0, &
                             133, 11, 20260621, 0, 203, 11, 20260621, 0, &
                             133, 12, 20260621, 0, 203, 12, 20260621, 0, &
                             133, 13, 20260621, 0, 203, 13, 20260621, 0, &
                             133, 14, 20260621, 0, 203, 14, 20260621, 0, &
                             133, 15, 20260621, 0, 203, 15, 20260621, 0, &
                             133, 16, 20260621, 0, 203, 16, 20260621, 0, &
                             133, 17, 20260621, 0, 203, 17, 20260621, 0, &
                             133, 18, 20260621, 0, 203, 18, 20260621, 0, &
                             133, 19, 20260621, 0, 203, 19, 20260621, 0, &
                             133, 20, 20260621, 0, 203, 20, 20260621, 0, &
                             133, 21, 20260621, 0, 203, 21, 20260621, 0, &
                             133, 22, 20260621, 0, 203, 22, 20260621, 0, &
                             133, 23, 20260621, 0, 203, 23, 20260621, 0, &
                             133, 24, 20260621, 0, 203, 24, 20260621, 0, &
                             133, 25, 20260621, 0, 203, 25, 20260621, 0, &
                             133, 26, 20260621, 0, 203, 26, 20260621, 0, &
                             133, 27, 20260621, 0, 203, 27, 20260621, 0, &
                             133, 28, 20260621, 0, 203, 28, 20260621, 0, &
                             133, 29, 20260621, 0, 203, 29, 20260621, 0, &
                             133, 30, 20260621, 0, 203, 30, 20260621, 0, &
                             133, 31, 20260621, 0, 203, 31, 20260621, 0, &
                             133, 32, 20260621, 0, 203, 32, 20260621, 0, &
                             133, 33, 20260621, 0, 203, 33, 20260621, 0, &
                             133, 34, 20260621, 0, 203, 34, 20260621, 0, &
                             133, 35, 20260621, 0, 203, 35, 20260621, 0, &
                             133, 36, 20260621, 0, 203, 36, 20260621, 0, &
                             133, 37, 20260621, 0, 203, 37, 20260621, 0, &
                             133, 38, 20260621, 0, 203, 38, 20260621, 0, &
                             133, 39, 20260621, 0, 203, 39, 20260621, 0, &
                             133, 40, 20260621, 0, 203, 40, 20260621, 0, &
                             133, 41, 20260621, 0, 203, 41, 20260621, 0, &
                             133, 42, 20260621, 0, 203, 42, 20260621, 0, &
                             133, 43, 20260621, 0, 203, 43, 20260621, 0, &
                             133, 44, 20260621, 0, 203, 44, 20260621, 0, &
                             133, 45, 20260621, 0, 203, 45, 20260621, 0, &
                             133, 46, 20260621, 0, 203, 46, 20260621, 0, &
                             133, 47, 20260621, 0, 203, 47, 20260621, 0, &
                             133, 48, 20260621, 0, 203, 48, 20260621, 0, &
                             133, 49, 20260621, 0, 203, 49, 20260621, 0, &
                             133, 50, 20260621, 0, 203, 50, 20260621, 0, &
                             133, 51, 20260621, 0, 203, 51, 20260621, 0, &
                             133, 52, 20260621, 0, 203, 52, 20260621, 0, &
                             133, 53, 20260621, 0, 203, 53, 20260621, 0, &
                             133, 54, 20260621, 0, 203, 54, 20260621, 0, &
                             133, 55, 20260621, 0, 203, 55, 20260621, 0, &
                             133, 56, 20260621, 0, 203, 56, 20260621, 0, &
                             133, 57, 20260621, 0, 203, 57, 20260621, 0, &
                             133, 58, 20260621, 0, 203, 58, 20260621, 0, &
                             133, 59, 20260621, 0, 203, 59, 20260621, 0, &
                             133, 60, 20260621, 0, 203, 60, 20260621, 0, &
                             133, 61, 20260621, 0, 203, 61, 20260621, 0, &
                             133, 62, 20260621, 0, 203, 62, 20260621, 0, &
                             133, 63, 20260621, 0, 203, 63, 20260621, 0, &
                             133, 64, 20260621, 0, 203, 64, 20260621, 0, &
                             133, 65, 20260621, 0, 203, 65, 20260621, 0, &
                             133, 66, 20260621, 0, 203, 66, 20260621, 0, &
                             133, 67, 20260621, 0, 203, 67, 20260621, 0, &
                             133, 68, 20260621, 0, 203, 68, 20260621, 0, &
                             133, 69, 20260621, 0, 203, 69, 20260621, 0, &
                             133, 70, 20260621, 0, 203, 70, 20260621, 0, &
                             133, 71, 20260621, 0, 203, 71, 20260621, 0, &
                             133, 72, 20260621, 0, 203, 72, 20260621, 0, &
                             133, 73, 20260621, 0, 203, 73, 20260621, 0, &
                             133, 74, 20260621, 0, 203, 74, 20260621, 0, &
                             133, 75, 20260621, 0, 203, 75, 20260621, 0, &
                             133, 76, 20260621, 0, 203, 76, 20260621, 0, &
                             133, 77, 20260621, 0, 203, 77, 20260621, 0, &
                             133, 78, 20260621, 0, 203, 78, 20260621, 0, &
                             133, 79, 20260621, 0, 203, 79, 20260621, 0, &
                             133, 80, 20260621, 0, 203, 80, 20260621, 0, &
                             133, 81, 20260621, 0, 203, 81, 20260621, 0, &
                             133, 82, 20260621, 0, 203, 82, 20260621, 0, &
                             133, 83, 20260621, 0, 203, 83, 20260621, 0, &
                             133, 84, 20260621, 0, 203, 84, 20260621, 0, &
                             133, 85, 20260621, 0, 203, 85, 20260621, 0, &
                             133, 86, 20260621, 0, 203, 86, 20260621, 0, &
                             133, 87, 20260621, 0, 203, 87, 20260621, 0, &
                             133, 88, 20260621, 0, 203, 88, 20260621, 0, &
                             133, 89, 20260621, 0, 203, 89, 20260621, 0, &
                             133, 90, 20260621, 0, 203, 90, 20260621, 0, &
                             133, 91, 20260621, 0, 203, 91, 20260621, 0, &
                             133, 92, 20260621, 0, 203, 92, 20260621, 0, &
                             133, 93, 20260621, 0, 203, 93, 20260621, 0, &
                             133, 94, 20260621, 0, 203, 94, 20260621, 0, &
                             133, 95, 20260621, 0, 203, 95, 20260621, 0, &
                             133, 96, 20260621, 0, 203, 96, 20260621, 0, &
                             133, 97, 20260621, 0, 203, 97, 20260621, 0, &
                             133, 98, 20260621, 0, 203, 98, 20260621, 0, &
                             133, 99, 20260621, 0, 203, 99, 20260621, 0, &
                             133, 100, 20260621, 0, 203, 100, 20260621, 0, &
                             133, 101, 20260621, 0, 203, 101, 20260621, 0, &
                             133, 102, 20260621, 0, 203, 102, 20260621, 0, &
                             133, 103, 20260621, 0, 203, 103, 20260621, 0, &
                             133, 104, 20260621, 0, 203, 104, 20260621, 0, &
                             133, 105, 20260621, 0, 203, 105, 20260621, 0, &
                             133, 106, 20260621, 0, 203, 106, 20260621, 0, &
                             133, 107, 20260621, 0, 203, 107, 20260621, 0, &
                             133, 108, 20260621, 0, 203, 108, 20260621, 0, &
                             133, 109, 20260621, 0, 203, 109, 20260621, 0, &
                             133, 110, 20260621, 0, 203, 110, 20260621, 0, &
                             133, 111, 20260621, 0, 203, 111, 20260621, 0, &
                             133, 112, 20260621, 0, 203, 112, 20260621, 0, &
                             133, 113, 20260621, 0, 203, 113, 20260621, 0, &
                             133, 114, 20260621, 0, 203, 114, 20260621, 0, &
                             133, 115, 20260621, 0, 203, 115, 20260621, 0, &
                             133, 116, 20260621, 0, 203, 116, 20260621, 0, &
                             133, 117, 20260621, 0, 203, 117, 20260621, 0, &
                             133, 118, 20260621, 0, 203, 118, 20260621, 0, &
                             133, 119, 20260621, 0, 203, 119, 20260621, 0, &
                             133, 120, 20260621, 0, 203, 120, 20260621, 0, &
                             133, 121, 20260621, 0, 203, 121, 20260621, 0, &
                             133, 122, 20260621, 0, 203, 122, 20260621, 0, &
                             133, 123, 20260621, 0, 203, 123, 20260621, 0, &
                             133, 124, 20260621, 0, 203, 124, 20260621, 0, &
                             133, 125, 20260621, 0, 203, 125, 20260621, 0, &
                             133, 126, 20260621, 0, 203, 126, 20260621, 0, &
                             133, 127, 20260621, 0, 203, 127, 20260621, 0, &
                             133, 128, 20260621, 0, 203, 128, 20260621, 0, &
                             133, 129, 20260621, 0, 203, 129, 20260621, 0, &
                             133, 130, 20260621, 0, 203, 130, 20260621, 0, &
                             133, 131, 20260621, 0, 203, 131, 20260621, 0, &
                             133, 132, 20260621, 0, 203, 132, 20260621, 0, &
                             133, 133, 20260621, 0, 203, 133, 20260621, 0, &
                             133, 134, 20260621, 0, 203, 134, 20260621, 0, &
                             133, 135, 20260621, 0, 203, 135, 20260621, 0, &
                             133, 136, 20260621, 0, 203, 136, 20260621, 0, &
                             133, 137, 20260621, 0, 203, 137, 20260621, 0, &
                             75, 1, 20260621, 0, 76, 1, 20260621, 0, &
                             246, 1, 20260621, 0, 247, 1, 20260621, 0, &
                             248, 1, 20260621, 0, 75, 2, 20260621, 0, &
                             76, 2, 20260621, 0, 246, 2, 20260621, 0, &
                             247, 2, 20260621, 0, 248, 2, 20260621, 0, &
                             75, 3, 20260621, 0, 76, 3, 20260621, 0, &
                             246, 3, 20260621, 0, 247, 3, 20260621, 0, &
                             248, 3, 20260621, 0, 75, 4, 20260621, 0, &
                             76, 4, 20260621, 0, 246, 4, 20260621, 0, &
                             247, 4, 20260621, 0, 248, 4, 20260621, 0, &
                             75, 5, 20260621, 0, 76, 5, 20260621, 0, &
                             246, 5, 20260621, 0, 247, 5, 20260621, 0, &
                             248, 5, 20260621, 0, 75, 6, 20260621, 0, &
                             76, 6, 20260621, 0, 246, 6, 20260621, 0, &
                             247, 6, 20260621, 0, 248, 6, 20260621, 0, &
                             75, 7, 20260621, 0, 76, 7, 20260621, 0, &
                             246, 7, 20260621, 0, 247, 7, 20260621, 0, &
                             248, 7, 20260621, 0, 75, 8, 20260621, 0, &
                             76, 8, 20260621, 0, 246, 8, 20260621, 0, &
                             247, 8, 20260621, 0, 248, 8, 20260621, 0, &
                             75, 9, 20260621, 0, 76, 9, 20260621, 0, &
                             246, 9, 20260621, 0, 247, 9, 20260621, 0, &
                             248, 9, 20260621, 0, 75, 10, 20260621, 0, &
                             76, 10, 20260621, 0, 246, 10, 20260621, 0, &
                             247, 10, 20260621, 0, 248, 10, 20260621, 0, &
                             75, 11, 20260621, 0, 76, 11, 20260621, 0, &
                             246, 11, 20260621, 0, 247, 11, 20260621, 0, &
                             248, 11, 20260621, 0, 75, 12, 20260621, 0, &
                             76, 12, 20260621, 0, 246, 12, 20260621, 0, &
                             247, 12, 20260621, 0, 248, 12, 20260621, 0, &
                             75, 13, 20260621, 0, 76, 13, 20260621, 0, &
                             246, 13, 20260621, 0, 247, 13, 20260621, 0, &
                             248, 13, 20260621, 0, 75, 14, 20260621, 0, &
                             76, 14, 20260621, 0, 246, 14, 20260621, 0, &
                             247, 14, 20260621, 0, 248, 14, 20260621, 0, &
                             75, 15, 20260621, 0, 76, 15, 20260621, 0, &
                             246, 15, 20260621, 0, 247, 15, 20260621, 0, &
                             248, 15, 20260621, 0, 75, 16, 20260621, 0, &
                             76, 16, 20260621, 0, 246, 16, 20260621, 0, &
                             247, 16, 20260621, 0, 248, 16, 20260621, 0, &
                             75, 17, 20260621, 0, 76, 17, 20260621, 0, &
                             246, 17, 20260621, 0, 247, 17, 20260621, 0, &
                             248, 17, 20260621, 0, 75, 18, 20260621, 0, &
                             76, 18, 20260621, 0, 246, 18, 20260621, 0, &
                             247, 18, 20260621, 0, 248, 18, 20260621, 0, &
                             75, 19, 20260621, 0, 76, 19, 20260621, 0, &
                             246, 19, 20260621, 0, 247, 19, 20260621, 0, &
                             248, 19, 20260621, 0, 75, 20, 20260621, 0, &
                             76, 20, 20260621, 0, 246, 20, 20260621, 0, &
                             247, 20, 20260621, 0, 248, 20, 20260621, 0, &
                             75, 21, 20260621, 0, 76, 21, 20260621, 0, &
                             246, 21, 20260621, 0, 247, 21, 20260621, 0, &
                             248, 21, 20260621, 0, 75, 22, 20260621, 0, &
                             76, 22, 20260621, 0, 246, 22, 20260621, 0, &
                             247, 22, 20260621, 0, 248, 22, 20260621, 0, &
                             75, 23, 20260621, 0, 76, 23, 20260621, 0, &
                             246, 23, 20260621, 0, 247, 23, 20260621, 0, &
                             248, 23, 20260621, 0, 75, 24, 20260621, 0, &
                             76, 24, 20260621, 0, 246, 24, 20260621, 0, &
                             247, 24, 20260621, 0, 248, 24, 20260621, 0, &
                             75, 25, 20260621, 0, 76, 25, 20260621, 0, &
                             246, 25, 20260621, 0, 247, 25, 20260621, 0, &
                             248, 25, 20260621, 0, 75, 26, 20260621, 0, &
                             76, 26, 20260621, 0, 246, 26, 20260621, 0, &
                             247, 26, 20260621, 0, 248, 26, 20260621, 0, &
                             75, 27, 20260621, 0, 76, 27, 20260621, 0, &
                             246, 27, 20260621, 0, 247, 27, 20260621, 0, &
                             248, 27, 20260621, 0, 75, 28, 20260621, 0, &
                             76, 28, 20260621, 0, 246, 28, 20260621, 0, &
                             247, 28, 20260621, 0, 248, 28, 20260621, 0, &
                             75, 29, 20260621, 0, 76, 29, 20260621, 0, &
                             246, 29, 20260621, 0, 247, 29, 20260621, 0, &
                             248, 29, 20260621, 0, 75, 30, 20260621, 0, &
                             76, 30, 20260621, 0, 246, 30, 20260621, 0, &
                             247, 30, 20260621, 0, 248, 30, 20260621, 0, &
                             75, 31, 20260621, 0, 76, 31, 20260621, 0, &
                             246, 31, 20260621, 0, 247, 31, 20260621, 0, &
                             248, 31, 20260621, 0, 75, 32, 20260621, 0, &
                             76, 32, 20260621, 0, 246, 32, 20260621, 0, &
                             247, 32, 20260621, 0, 248, 32, 20260621, 0, &
                             75, 33, 20260621, 0, 76, 33, 20260621, 0, &
                             246, 33, 20260621, 0, 247, 33, 20260621, 0, &
                             248, 33, 20260621, 0, 75, 34, 20260621, 0, &
                             76, 34, 20260621, 0, 246, 34, 20260621, 0, &
                             247, 34, 20260621, 0, 248, 34, 20260621, 0, &
                             75, 35, 20260621, 0, 76, 35, 20260621, 0, &
                             246, 35, 20260621, 0, 247, 35, 20260621, 0, &
                             248, 35, 20260621, 0, 75, 36, 20260621, 0, &
                             76, 36, 20260621, 0, 246, 36, 20260621, 0, &
                             247, 36, 20260621, 0, 248, 36, 20260621, 0, &
                             75, 37, 20260621, 0, 76, 37, 20260621, 0, &
                             246, 37, 20260621, 0, 247, 37, 20260621, 0, &
                             248, 37, 20260621, 0, 75, 38, 20260621, 0, &
                             76, 38, 20260621, 0, 246, 38, 20260621, 0, &
                             247, 38, 20260621, 0, 248, 38, 20260621, 0, &
                             75, 39, 20260621, 0, 76, 39, 20260621, 0, &
                             246, 39, 20260621, 0, 247, 39, 20260621, 0, &
                             248, 39, 20260621, 0, 75, 40, 20260621, 0, &
                             76, 40, 20260621, 0, 246, 40, 20260621, 0, &
                             247, 40, 20260621, 0, 248, 40, 20260621, 0, &
                             75, 41, 20260621, 0, 76, 41, 20260621, 0, &
                             246, 41, 20260621, 0, 247, 41, 20260621, 0, &
                             248, 41, 20260621, 0, 75, 42, 20260621, 0, &
                             76, 42, 20260621, 0, 246, 42, 20260621, 0, &
                             247, 42, 20260621, 0, 248, 42, 20260621, 0, &
                             75, 43, 20260621, 0, 76, 43, 20260621, 0, &
                             246, 43, 20260621, 0, 247, 43, 20260621, 0, &
                             248, 43, 20260621, 0, 75, 44, 20260621, 0, &
                             76, 44, 20260621, 0, 246, 44, 20260621, 0, &
                             247, 44, 20260621, 0, 248, 44, 20260621, 0, &
                             75, 45, 20260621, 0, 76, 45, 20260621, 0, &
                             246, 45, 20260621, 0, 247, 45, 20260621, 0, &
                             248, 45, 20260621, 0, 75, 46, 20260621, 0, &
                             76, 46, 20260621, 0, 246, 46, 20260621, 0, &
                             247, 46, 20260621, 0, 248, 46, 20260621, 0, &
                             75, 47, 20260621, 0, 76, 47, 20260621, 0, &
                             246, 47, 20260621, 0, 247, 47, 20260621, 0, &
                             248, 47, 20260621, 0, 75, 48, 20260621, 0, &
                             76, 48, 20260621, 0, 246, 48, 20260621, 0, &
                             247, 48, 20260621, 0, 248, 48, 20260621, 0, &
                             75, 49, 20260621, 0, 76, 49, 20260621, 0, &
                             246, 49, 20260621, 0, 247, 49, 20260621, 0, &
                             248, 49, 20260621, 0, 75, 50, 20260621, 0, &
                             76, 50, 20260621, 0, 246, 50, 20260621, 0, &
                             247, 50, 20260621, 0, 248, 50, 20260621, 0, &
                             75, 51, 20260621, 0, 76, 51, 20260621, 0, &
                             246, 51, 20260621, 0, 247, 51, 20260621, 0, &
                             248, 51, 20260621, 0, 75, 52, 20260621, 0, &
                             76, 52, 20260621, 0, 246, 52, 20260621, 0, &
                             247, 52, 20260621, 0, 248, 52, 20260621, 0, &
                             75, 53, 20260621, 0, 76, 53, 20260621, 0, &
                             246, 53, 20260621, 0, 247, 53, 20260621, 0, &
                             248, 53, 20260621, 0, 75, 54, 20260621, 0, &
                             76, 54, 20260621, 0, 246, 54, 20260621, 0, &
                             247, 54, 20260621, 0, 248, 54, 20260621, 0, &
                             75, 55, 20260621, 0, 76, 55, 20260621, 0, &
                             246, 55, 20260621, 0, 247, 55, 20260621, 0, &
                             248, 55, 20260621, 0, 75, 56, 20260621, 0, &
                             76, 56, 20260621, 0, 246, 56, 20260621, 0, &
                             247, 56, 20260621, 0, 248, 56, 20260621, 0, &
                             75, 57, 20260621, 0, 76, 57, 20260621, 0, &
                             246, 57, 20260621, 0, 247, 57, 20260621, 0, &
                             248, 57, 20260621, 0, 75, 58, 20260621, 0, &
                             76, 58, 20260621, 0, 246, 58, 20260621, 0, &
                             247, 58, 20260621, 0, 248, 58, 20260621, 0, &
                             75, 59, 20260621, 0, 76, 59, 20260621, 0, &
                             246, 59, 20260621, 0, 247, 59, 20260621, 0, &
                             248, 59, 20260621, 0, 75, 60, 20260621, 0, &
                             76, 60, 20260621, 0, 246, 60, 20260621, 0, &
                             247, 60, 20260621, 0, 248, 60, 20260621, 0, &
                             75, 61, 20260621, 0, 76, 61, 20260621, 0, &
                             246, 61, 20260621, 0, 247, 61, 20260621, 0, &
                             248, 61, 20260621, 0, 75, 62, 20260621, 0, &
                             76, 62, 20260621, 0, 246, 62, 20260621, 0, &
                             247, 62, 20260621, 0, 248, 62, 20260621, 0, &
                             75, 63, 20260621, 0, 76, 63, 20260621, 0, &
                             246, 63, 20260621, 0, 247, 63, 20260621, 0, &
                             248, 63, 20260621, 0, 75, 64, 20260621, 0, &
                             76, 64, 20260621, 0, 246, 64, 20260621, 0, &
                             247, 64, 20260621, 0, 248, 64, 20260621, 0, &
                             75, 65, 20260621, 0, 76, 65, 20260621, 0, &
                             246, 65, 20260621, 0, 247, 65, 20260621, 0, &
                             248, 65, 20260621, 0, 75, 66, 20260621, 0, &
                             76, 66, 20260621, 0, 246, 66, 20260621, 0, &
                             247, 66, 20260621, 0, 248, 66, 20260621, 0, &
                             75, 67, 20260621, 0, 76, 67, 20260621, 0, &
                             246, 67, 20260621, 0, 247, 67, 20260621, 0, &
                             248, 67, 20260621, 0, 75, 68, 20260621, 0, &
                             76, 68, 20260621, 0, 246, 68, 20260621, 0, &
                             247, 68, 20260621, 0, 248, 68, 20260621, 0, &
                             75, 69, 20260621, 0, 76, 69, 20260621, 0, &
                             246, 69, 20260621, 0, 247, 69, 20260621, 0, &
                             248, 69, 20260621, 0, 75, 70, 20260621, 0, &
                             76, 70, 20260621, 0, 246, 70, 20260621, 0, &
                             247, 70, 20260621, 0, 248, 70, 20260621, 0, &
                             75, 71, 20260621, 0, 76, 71, 20260621, 0, &
                             246, 71, 20260621, 0, 247, 71, 20260621, 0, &
                             248, 71, 20260621, 0, 75, 72, 20260621, 0, &
                             76, 72, 20260621, 0, 246, 72, 20260621, 0, &
                             247, 72, 20260621, 0, 248, 72, 20260621, 0, &
                             75, 73, 20260621, 0, 76, 73, 20260621, 0, &
                             246, 73, 20260621, 0, 247, 73, 20260621, 0, &
                             248, 73, 20260621, 0, 75, 74, 20260621, 0, &
                             76, 74, 20260621, 0, 246, 74, 20260621, 0, &
                             247, 74, 20260621, 0, 248, 74, 20260621, 0, &
                             75, 75, 20260621, 0, 76, 75, 20260621, 0, &
                             246, 75, 20260621, 0, 247, 75, 20260621, 0, &
                             248, 75, 20260621, 0, 75, 76, 20260621, 0, &
                             76, 76, 20260621, 0, 246, 76, 20260621, 0, &
                             247, 76, 20260621, 0, 248, 76, 20260621, 0, &
                             75, 77, 20260621, 0, 76, 77, 20260621, 0, &
                             246, 77, 20260621, 0, 247, 77, 20260621, 0, &
                             248, 77, 20260621, 0, 75, 78, 20260621, 0, &
                             76, 78, 20260621, 0, 246, 78, 20260621, 0, &
                             247, 78, 20260621, 0, 248, 78, 20260621, 0, &
                             75, 79, 20260621, 0, 76, 79, 20260621, 0, &
                             246, 79, 20260621, 0, 247, 79, 20260621, 0, &
                             248, 79, 20260621, 0, 75, 80, 20260621, 0, &
                             76, 80, 20260621, 0, 246, 80, 20260621, 0, &
                             247, 80, 20260621, 0, 248, 80, 20260621, 0, &
                             75, 81, 20260621, 0, 76, 81, 20260621, 0, &
                             246, 81, 20260621, 0, 247, 81, 20260621, 0, &
                             248, 81, 20260621, 0, 75, 82, 20260621, 0, &
                             76, 82, 20260621, 0, 246, 82, 20260621, 0, &
                             247, 82, 20260621, 0, 248, 82, 20260621, 0, &
                             75, 83, 20260621, 0, 76, 83, 20260621, 0, &
                             246, 83, 20260621, 0, 247, 83, 20260621, 0, &
                             248, 83, 20260621, 0, 75, 84, 20260621, 0, &
                             76, 84, 20260621, 0, 246, 84, 20260621, 0, &
                             247, 84, 20260621, 0, 248, 84, 20260621, 0, &
                             75, 85, 20260621, 0, 76, 85, 20260621, 0, &
                             246, 85, 20260621, 0, 247, 85, 20260621, 0, &
                             248, 85, 20260621, 0, 75, 86, 20260621, 0, &
                             76, 86, 20260621, 0, 246, 86, 20260621, 0, &
                             247, 86, 20260621, 0, 248, 86, 20260621, 0, &
                             75, 87, 20260621, 0, 76, 87, 20260621, 0, &
                             246, 87, 20260621, 0, 247, 87, 20260621, 0, &
                             248, 87, 20260621, 0, 75, 88, 20260621, 0, &
                             76, 88, 20260621, 0, 246, 88, 20260621, 0, &
                             247, 88, 20260621, 0, 248, 88, 20260621, 0, &
                             75, 89, 20260621, 0, 76, 89, 20260621, 0, &
                             246, 89, 20260621, 0, 247, 89, 20260621, 0, &
                             248, 89, 20260621, 0, 75, 90, 20260621, 0, &
                             76, 90, 20260621, 0, 246, 90, 20260621, 0, &
                             247, 90, 20260621, 0, 248, 90, 20260621, 0, &
                             75, 91, 20260621, 0, 76, 91, 20260621, 0, &
                             246, 91, 20260621, 0, 247, 91, 20260621, 0, &
                             248, 91, 20260621, 0, 75, 92, 20260621, 0, &
                             76, 92, 20260621, 0, 246, 92, 20260621, 0, &
                             247, 92, 20260621, 0, 248, 92, 20260621, 0, &
                             75, 93, 20260621, 0, 76, 93, 20260621, 0, &
                             246, 93, 20260621, 0, 247, 93, 20260621, 0, &
                             248, 93, 20260621, 0, 75, 94, 20260621, 0, &
                             76, 94, 20260621, 0, 246, 94, 20260621, 0, &
                             247, 94, 20260621, 0, 248, 94, 20260621, 0, &
                             75, 95, 20260621, 0, 76, 95, 20260621, 0, &
                             246, 95, 20260621, 0, 247, 95, 20260621, 0, &
                             248, 95, 20260621, 0, 75, 96, 20260621, 0, &
                             76, 96, 20260621, 0, 246, 96, 20260621, 0, &
                             247, 96, 20260621, 0, 248, 96, 20260621, 0, &
                             75, 97, 20260621, 0, 76, 97, 20260621, 0, &
                             246, 97, 20260621, 0, 247, 97, 20260621, 0, &
                             248, 97, 20260621, 0, 75, 98, 20260621, 0, &
                             76, 98, 20260621, 0, 246, 98, 20260621, 0, &
                             247, 98, 20260621, 0, 248, 98, 20260621, 0, &
                             75, 99, 20260621, 0, 76, 99, 20260621, 0, &
                             246, 99, 20260621, 0, 247, 99, 20260621, 0, &
                             248, 99, 20260621, 0, 75, 100, 20260621, 0, &
                             76, 100, 20260621, 0, 246, 100, 20260621, 0, &
                             247, 100, 20260621, 0, 248, 100, 20260621, 0, &
                             75, 101, 20260621, 0, 76, 101, 20260621, 0, &
                             246, 101, 20260621, 0, 247, 101, 20260621, 0, &
                             248, 101, 20260621, 0, 75, 102, 20260621, 0, &
                             76, 102, 20260621, 0, 246, 102, 20260621, 0, &
                             247, 102, 20260621, 0, 248, 102, 20260621, 0, &
                             75, 103, 20260621, 0, 76, 103, 20260621, 0, &
                             246, 103, 20260621, 0, 247, 103, 20260621, 0, &
                             248, 103, 20260621, 0, 75, 104, 20260621, 0, &
                             76, 104, 20260621, 0, 246, 104, 20260621, 0, &
                             247, 104, 20260621, 0, 248, 104, 20260621, 0, &
                             75, 105, 20260621, 0, 76, 105, 20260621, 0, &
                             246, 105, 20260621, 0, 247, 105, 20260621, 0, &
                             248, 105, 20260621, 0, 75, 106, 20260621, 0, &
                             76, 106, 20260621, 0, 246, 106, 20260621, 0, &
                             247, 106, 20260621, 0, 248, 106, 20260621, 0, &
                             75, 107, 20260621, 0, 76, 107, 20260621, 0, &
                             246, 107, 20260621, 0, 247, 107, 20260621, 0, &
                             248, 107, 20260621, 0, 75, 108, 20260621, 0, &
                             76, 108, 20260621, 0, 246, 108, 20260621, 0, &
                             247, 108, 20260621, 0, 248, 108, 20260621, 0, &
                             75, 109, 20260621, 0, 76, 109, 20260621, 0, &
                             246, 109, 20260621, 0, 247, 109, 20260621, 0, &
                             248, 109, 20260621, 0, 75, 110, 20260621, 0, &
                             76, 110, 20260621, 0, 246, 110, 20260621, 0, &
                             247, 110, 20260621, 0, 248, 110, 20260621, 0, &
                             75, 111, 20260621, 0, 76, 111, 20260621, 0, &
                             246, 111, 20260621, 0, 247, 111, 20260621, 0, &
                             248, 111, 20260621, 0, 75, 112, 20260621, 0, &
                             76, 112, 20260621, 0, 246, 112, 20260621, 0, &
                             247, 112, 20260621, 0, 248, 112, 20260621, 0, &
                             75, 113, 20260621, 0, 76, 113, 20260621, 0, &
                             246, 113, 20260621, 0, 247, 113, 20260621, 0, &
                             248, 113, 20260621, 0, 75, 114, 20260621, 0, &
                             76, 114, 20260621, 0, 246, 114, 20260621, 0, &
                             247, 114, 20260621, 0, 248, 114, 20260621, 0, &
                             75, 115, 20260621, 0, 76, 115, 20260621, 0, &
                             246, 115, 20260621, 0, 247, 115, 20260621, 0, &
                             248, 115, 20260621, 0, 75, 116, 20260621, 0, &
                             76, 116, 20260621, 0, 246, 116, 20260621, 0, &
                             247, 116, 20260621, 0, 248, 116, 20260621, 0, &
                             75, 117, 20260621, 0, 76, 117, 20260621, 0, &
                             246, 117, 20260621, 0, 247, 117, 20260621, 0, &
                             248, 117, 20260621, 0, 75, 118, 20260621, 0, &
                             76, 118, 20260621, 0, 246, 118, 20260621, 0, &
                             247, 118, 20260621, 0, 248, 118, 20260621, 0, &
                             75, 119, 20260621, 0, 76, 119, 20260621, 0, &
                             246, 119, 20260621, 0, 247, 119, 20260621, 0, &
                             248, 119, 20260621, 0, 75, 120, 20260621, 0, &
                             76, 120, 20260621, 0, 246, 120, 20260621, 0, &
                             247, 120, 20260621, 0, 248, 120, 20260621, 0, &
                             75, 121, 20260621, 0, 76, 121, 20260621, 0, &
                             246, 121, 20260621, 0, 247, 121, 20260621, 0, &
                             248, 121, 20260621, 0, 75, 122, 20260621, 0, &
                             76, 122, 20260621, 0, 246, 122, 20260621, 0, &
                             247, 122, 20260621, 0, 248, 122, 20260621, 0, &
                             75, 123, 20260621, 0, 76, 123, 20260621, 0, &
                             246, 123, 20260621, 0, 247, 123, 20260621, 0, &
                             248, 123, 20260621, 0, 75, 124, 20260621, 0, &
                             76, 124, 20260621, 0, 246, 124, 20260621, 0, &
                             247, 124, 20260621, 0, 248, 124, 20260621, 0, &
                             75, 125, 20260621, 0, 76, 125, 20260621, 0, &
                             246, 125, 20260621, 0, 247, 125, 20260621, 0, &
                             248, 125, 20260621, 0, 75, 126, 20260621, 0, &
                             76, 126, 20260621, 0, 246, 126, 20260621, 0, &
                             247, 126, 20260621, 0, 248, 126, 20260621, 0, &
                             75, 127, 20260621, 0, 76, 127, 20260621, 0, &
                             246, 127, 20260621, 0, 247, 127, 20260621, 0, &
                             248, 127, 20260621, 0, 75, 128, 20260621, 0, &
                             76, 128, 20260621, 0, 246, 128, 20260621, 0, &
                             247, 128, 20260621, 0, 248, 128, 20260621, 0, &
                             75, 129, 20260621, 0, 76, 129, 20260621, 0, &
                             246, 129, 20260621, 0, 247, 129, 20260621, 0, &
                             248, 129, 20260621, 0, 75, 130, 20260621, 0, &
                             76, 130, 20260621, 0, 246, 130, 20260621, 0, &
                             247, 130, 20260621, 0, 248, 130, 20260621, 0, &
                             75, 131, 20260621, 0, 76, 131, 20260621, 0, &
                             246, 131, 20260621, 0, 247, 131, 20260621, 0, &
                             248, 131, 20260621, 0, 75, 132, 20260621, 0, &
                             76, 132, 20260621, 0, 246, 132, 20260621, 0, &
                             247, 132, 20260621, 0, 248, 132, 20260621, 0, &
                             75, 133, 20260621, 0, 76, 133, 20260621, 0, &
                             246, 133, 20260621, 0, 247, 133, 20260621, 0, &
                             248, 133, 20260621, 0, 75, 134, 20260621, 0, &
                             76, 134, 20260621, 0, 246, 134, 20260621, 0, &
                             247, 134, 20260621, 0, 248, 134, 20260621, 0, &
                             75, 135, 20260621, 0, 76, 135, 20260621, 0, &
                             246, 135, 20260621, 0, 247, 135, 20260621, 0, &
                             248, 135, 20260621, 0, 75, 136, 20260621, 0, &
                             76, 136, 20260621, 0, 246, 136, 20260621, 0, &
                             247, 136, 20260621, 0, 248, 136, 20260621, 0, &
                             75, 137, 20260621, 0, 76, 137, 20260621, 0, &
                             246, 137, 20260621, 0, 247, 137, 20260621, 0, &
                             248, 137, 20260621, 0 &
                             ], [4, 959])
  end function
end module
