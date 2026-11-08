module streaming_spectral_record_reader_port
  !! Decode and place one spectral record at a time through public ecCodes.
  !! Port: src/openifs/input/streaming_runtime_spectral_records.S.
  use, intrinsic :: iso_c_binding
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use initial_grib_field_reader_port, only: initial_field_schema
  use initial_field_placement_port, only: spectral_initial_partition
  use streaming_spectral_record_placement_port, only: scatter_streamed_spectral_record
  implicit none
  private
  public :: read_streaming_spectral_records
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
  end interface
contains
  integer(c_int) function read_streaming_spectral_records(path, schema, partition, row, &
                                                          spectral, surface, metadata, messages_read) result(status)
    !! The parent supplies a validated three-word spectral schema and maps.
    !! row is one global FP64 record. metadata has shape(3,at least records).
    !! The local spectral and surface arguments are private staged owners.
    !! A failure may leave their decoded prefix and row changed; the owning
    !! parent discards them. Every file and message closes before return.
    !! Status is 0 success, 1 bounds, 2 open, 3 codec, 4 file scope or 5 close.
    character(len=*), intent(in) :: path
    type(initial_field_schema), intent(in) :: schema
    type(spectral_initial_partition), intent(in) :: partition
    real(c_double), contiguous, intent(inout) :: row(:), spectral(:, :, :), surface(:, :)
    integer(c_int64_t), contiguous, intent(inout) :: metadata(:, :)
    integer(c_int64_t), intent(inout) :: messages_read
    integer(c_int), pointer :: error_number
    integer(c_int) :: saved_errno, error, ignored
    type(ieee_status_type) :: saved_status
    type(c_ptr) :: stream, handle
    integer(c_long) :: parameter_id, level
    integer(c_size_t) :: count
    integer :: record, records
    status = 1_c_int
    if (.not. allocated(schema%labels)) return
    if (size(schema%labels, 1) /= 4 .or. schema%metadata_words /= 3) return
    records = size(schema%labels, 2)
    if (records < 1 .or. schema%value_count < 1_c_int64_t) return
    if (size(row, kind=c_int64_t) < schema%value_count) return
    if (size(metadata, 1) /= 3 .or. size(metadata, 2) < records) return
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
      call scatter_streamed_spectral_record(partition, row, messages_read, spectral, surface)
      messages_read = messages_read + 1_c_int64_t
    end do
    if (c_associated(handle)) ignored = delete_message(handle)
    error = file_close(stream)
    if (status == 0_c_int .and. error /= 0_c_int) status = 5_c_int
900 error_number = saved_errno
    call ieee_set_status(saved_status)
  end function
end module streaming_spectral_record_reader_port
