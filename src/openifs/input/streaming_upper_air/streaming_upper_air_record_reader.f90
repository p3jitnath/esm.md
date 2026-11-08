module streaming_upper_air_record_reader_port
  !! Decode and place one upper-air record at a time through public ecCodes.
  !! Port: src/openifs/input/streaming_runtime_upper_air_records.S.
  use, intrinsic :: iso_c_binding
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use initial_grib_field_reader_port, only: initial_field_schema
  use initial_field_placement_port, only: upper_air_initial_partition
  use streaming_upper_air_record_placement_port, only: place_streamed_upper_air_record
  implicit none
  private
  public :: read_streaming_runtime_upper_air_records
  interface
    function file_open(path, mode) bind(C, name="fopen") result(stream)
      import
      character(c_char), intent(in) :: path(*), mode(*)
      type(c_ptr) :: stream
    end function
    function file_close(stream) bind(C, name="fclose") result(status)
      import
      type(c_ptr), value :: stream
      integer(c_int) :: status
    end function
    function file_error(stream) bind(C, name="ferror") result(status)
      import
      type(c_ptr), value :: stream
      integer(c_int) :: status
    end function
    function file_eof(stream) bind(C, name="feof") result(status)
      import
      type(c_ptr), value :: stream
      integer(c_int) :: status
    end function
    function errno_address() bind(C, name="__errno_location") result(address)
      import
      type(c_ptr) :: address
    end function
    function new_message(context, stream, error) bind(C, name="codes_grib_handle_new_from_file") result(handle)
      import
      type(c_ptr), value :: context, stream
      integer(c_int), intent(out) :: error
      type(c_ptr) :: handle
    end function
    function delete_message(handle) bind(C, name="codes_handle_delete") result(status)
      import
      type(c_ptr), value :: handle
      integer(c_int) :: status
    end function
    function get_long(handle, key, value) bind(C, name="codes_get_long") result(status)
      import
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      integer(c_long), intent(out) :: value
      integer(c_int) :: status
    end function
    function get_size(handle, key, length) bind(C, name="codes_get_size") result(status)
      import
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      integer(c_size_t), intent(out) :: length
      integer(c_int) :: status
    end function
    function get_values(handle, key, values, length) bind(C, name="codes_get_double_array") result(status)
      import
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      real(c_double), intent(inout) :: values(*)
      integer(c_size_t), intent(inout) :: length
      integer(c_int) :: status
    end function
    function set_long(handle, key, value) bind(C, name="codes_set_long") result(status)
      import
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      integer(c_long), value :: value
      integer(c_int) :: status
    end function
    function get_longs(handle, key, values, length) bind(C, name="codes_get_long_array") result(status)
      import
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      integer(c_long), intent(out) :: values(*)
      integer(c_size_t), intent(inout) :: length
      integer(c_int) :: status
    end function
    function is_missing(handle, key, error) bind(C, name="codes_is_missing") result(missing)
      import
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      integer(c_int), intent(out) :: error
      integer(c_int) :: missing
    end function
  end interface
contains
  integer(c_int) function read_streaming_runtime_upper_air_records(path, schema, partition, row, &
                                                                   fields, metadata, messages_read) result(status)
    !! The parent supplies a validated runtime grid schema and point map.
    !! row is one global FP64 record. metadata has shape(5,at least records).
    !! The local fields argument is a private staged owner.
    !! A failure may leave their decoded prefix and row changed; the owning
    !! parent discards them. Every file and message closes before return.
    !! Status is 0 success, 1 bounds, 2 open, 3 codec, 4 file scope or 5 close.
    character(len=*), intent(in) :: path
    type(initial_field_schema), intent(in) :: schema
    type(upper_air_initial_partition), intent(in) :: partition
    real(c_double), contiguous, intent(inout) :: row(:), fields(:, :, :, :)
    integer(c_int64_t), contiguous, intent(inout) :: metadata(:, :)
    integer(c_int64_t), intent(inout) :: messages_read
    integer(c_int), pointer :: error_number
    integer(c_int) :: saved_errno, error, ignored
    type(ieee_status_type) :: saved_status
    type(c_ptr) :: stream, handle
    integer(c_long) :: parameter_id, level, date, time
    integer(c_size_t) :: count
    integer :: record, records
    status = 1_c_int
    if (.not. allocated(schema%labels)) return
    if (size(schema%labels, 1) /= 4 .or. schema%metadata_words /= 5) return
    records = size(schema%labels, 2)
    if (records < 1 .or. schema%value_count < 1_c_int64_t) return
    if (size(row, kind=c_int64_t) < schema%value_count) return
    if (size(metadata, 1) /= 5 .or. size(metadata, 2) < records) return
    if (.not. schema%runtime_grid) return
    if (.not. allocated(schema%north_rows)) return
    call ieee_get_status(saved_status)
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    stream = file_open(path//c_null_char, 'rb'//c_null_char)
    handle = c_null_ptr
    messages_read = 0_c_int64_t
    status = 2_c_int
    if (.not. c_associated(stream)) goto 900
    do
      error = 0_c_int
      handle = new_message(c_null_ptr, stream, error)
      status = 3_c_int
      if (error /= 0_c_int) exit
      if (.not. c_associated(handle)) then
        if (file_error(stream) /= 0_c_int) exit
        if (file_eof(stream) == 0_c_int) exit
        status = 4_c_int
        if (messages_read /= int(records, c_int64_t)) exit
        status = 0_c_int
        exit
      end if
      status = 4_c_int
      if (messages_read >= int(records, c_int64_t)) exit
      record = int(messages_read) + 1
      status = 3_c_int
      if (get_long(handle, 'paramId'//c_null_char, parameter_id) /= 0_c_int) exit
      if (get_long(handle, 'level'//c_null_char, level) /= 0_c_int) exit
      if (get_size(handle, 'values'//c_null_char, count) /= 0_c_int) exit
      status = 4_c_int
      if (count /= schema%value_count) exit
      if (parameter_id /= schema%labels(1, record) .or. level /= schema%labels(2, record)) exit
      status = 3_c_int
      if (get_long(handle, 'dataDate'//c_null_char, date) /= 0_c_int) exit
      if (get_long(handle, 'dataTime'//c_null_char, time) /= 0_c_int) exit
      status = 4_c_int
      if (date /= schema%labels(3, record) .or. time /= schema%labels(4, record)) exit
      status = validate_runtime_grid(handle, schema)
      if (status /= 0_c_int) exit
      status = 3_c_int
      if (get_values(handle, 'values'//c_null_char, row, count) /= 0_c_int) exit
      status = 4_c_int
      if (count /= schema%value_count) exit
      error = delete_message(handle)
      handle = c_null_ptr
      status = 3_c_int
      if (error /= 0_c_int) exit
      metadata(1, record) = parameter_id
      metadata(2, record) = level
      metadata(3, record) = schema%value_count
      metadata(4, record) = date
      metadata(5, record) = time
      if (place_streamed_upper_air_record(partition, row, messages_read, fields) /= 0_c_int) then
        status = 4_c_int
        exit
      end if
      messages_read = messages_read + 1_c_int64_t
    end do
    if (c_associated(handle)) ignored = delete_message(handle)
    error = file_close(stream)
    if (status == 0_c_int .and. error /= 0_c_int) status = 5_c_int
900 error_number = saved_errno
    call ieee_set_status(saved_status)
  end function
  integer(c_int) function validate_runtime_grid(handle, schema) result(status)
    !! Retain the public decoder's complete Gaussian grid checks in order.
    !! The schema was built from positive northern row counts. The fixed
    !! protocol buffer holds at most twice the admitted order 1280.
    type(c_ptr), intent(in) :: handle
    type(initial_field_schema), intent(in) :: schema
    integer, parameter :: maximum_order = 1280
    integer(c_long) :: value, ni, rows(2*maximum_order)
    integer(c_int) :: missing, error
    integer(c_size_t) :: row_count
    integer :: order, j, north
    order = schema%gaussian_order
    status = 4_c_int
    if (order < 1 .or. order > maximum_order) return
    if (size(schema%north_rows) /= order) return
    status = 3_c_int
    if (get_long(handle, 'gridDefinitionTemplateNumber'//c_null_char, value) /= 0_c_int) return
    status = 4_c_int
    if (value /= 40_c_long) return
    status = 3_c_int
    if (get_long(handle, 'N'//c_null_char, value) /= 0_c_int) return
    status = 4_c_int
    if (value /= int(order, c_long)) return
    status = 3_c_int
    if (get_long(handle, 'Nj'//c_null_char, value) /= 0_c_int) return
    status = 4_c_int
    if (value /= 2_c_long*order) return
    status = 3_c_int
    if (get_long(handle, 'scanningMode'//c_null_char, value) /= 0_c_int) return
    status = 4_c_int
    if (value /= 0_c_long) return
    status = 3_c_int
    if (get_long(handle, 'numberOfDataPoints'//c_null_char, value) /= 0_c_int) return
    status = 4_c_int
    if (value /= schema%value_count) return
    error = 0_c_int
    missing = is_missing(handle, 'Ni'//c_null_char, error)
    status = 3_c_int
    if (error /= 0_c_int) return
    if (missing == 0_c_int) then
      status = 4_c_int
      if (order > 256) return
      status = 3_c_int
      if (get_long(handle, 'Ni'//c_null_char, ni) /= 0_c_int) return
      status = 4_c_int
      if (ni /= schema%maximum_longitudes) return
      if (ni*2_c_long*order /= schema%value_count) return
      do j = 1, order
        if (schema%north_rows(j) /= ni) return
      end do
    else if (missing == 1_c_int) then
      status = 3_c_int
      if (get_size(handle, 'pl'//c_null_char, row_count) /= 0_c_int) return
      status = 4_c_int
      if (row_count /= 2_c_size_t*order) return
      status = 3_c_int
      if (get_longs(handle, 'pl'//c_null_char, rows, row_count) /= 0_c_int) return
      status = 4_c_int
      if (row_count /= 2_c_size_t*order) return
      do j = 1, 2*order
        north = min(j, 2*order - j + 1)
        if (rows(j) /= schema%north_rows(north)) return
      end do
    else
      status = 4_c_int
      return
    end if
    status = 3_c_int
    if (set_long(handle, 'missingValue'//c_null_char, -9999_c_long) /= 0_c_int) return
    status = 0_c_int
  end function
end module streaming_upper_air_record_reader_port
