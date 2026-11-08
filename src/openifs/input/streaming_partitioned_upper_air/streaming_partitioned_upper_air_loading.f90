module streaming_partitioned_upper_air_loading_port
  !! Decode complete global messages into one reusable field buffer. Private
  !! local staging preserves every destination byte on any file failure.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: iso_c_binding, only: c_ptr, c_int, c_long, c_size_t, c_char, c_null_ptr, c_null_char, c_associated, c_f_pointer
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use initial_grib_field_reader_port, only: initial_field_schema, file_open, file_close, file_error, file_eof, &
                   new_message, delete_message, get_long, get_size, get_values, validate_initial_grid, validate_runtime_initial_grid
  use runtime_partitioned_upper_air_placement_port, only: runtime_partitioned_upper_air_shape
  use streamed_upper_air_record_placement_port, only: validate_streamed_upper_air_destination, &
                            scatter_streamed_upper_air_record, publish_streamed_upper_air_fields, streamed_upper_air_workspace_bytes
  implicit none
  private
  public :: load_streaming_partitioned_upper_air_fields
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  integer(int32) function load_streaming_partitioned_upper_air_fields(path, schema, partition, byte_limit, fields) result(status)
    !! schema owns readonly labels(4,7*levels); rows are parameter, level,
    !! date and time. The partition borrows the accepted source global map.
    !! byte_limit bounds only two private FP64 allocations. Codec memory and
    !! complete final-owner payloads require the enclosing process admission.
    !! Status1 refuses shape/schema/cap,2 reports allocation failure,
    !! 16+reader status reports file/codec failure,32+placement status reports
    !! map/publication refusal. Every failure preserves the complete fields.
    !! Every return preserves incoming IEEE state and errno.
    character(len=*), intent(in) :: path
    type(initial_field_schema), intent(in) :: schema
    type(runtime_partitioned_upper_air_shape), intent(in) :: partition
    integer(int64), intent(in) :: byte_limit
    real(real64), contiguous, intent(inout) :: fields(:, :, :, :)
    real(real64), allocatable :: staged(:, :), values(:)
    type(c_ptr) :: stream, handle
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno, error, ignored, reader_status
    integer(c_long) :: parameter, level, date, time
    integer(c_size_t) :: count
    integer(int32), parameter :: codes(7) = [133, 203, 75, 76, 246, 247, 248]
    integer(int32) :: child_status
    integer(int64) :: required
    integer :: levels, records, record, completed, q, family, wanted_level, ios
    logical :: opened
    character(c_char) :: path_bytes(4096)
    integer :: path_index
    status = 1
    if (len(path) < 1 .or. len(path) > 4095 .or. index(path, c_null_char) /= 0) return
    child_status = validate_streamed_upper_air_destination(partition, fields)
    if (child_status /= 0) return
    levels = partition%fields%levels; records = 7*levels
    if (schema%value_count /= int(partition%global_points, int64) .or. schema%metadata_words /= 5) return
    if (.not. allocated(schema%labels)) return
    if (any(shape(schema%labels) /= [4, records])) return
    do record = 1, records
      q = record - 1
      if (q < 2*levels) then
        wanted_level = q/2 + 1; family = mod(q, 2) + 1
      else
        q = q - 2*levels; wanted_level = q/5 + 1; family = mod(q, 5) + 3
      end if
      if (schema%labels(1, record) /= int(codes(family), int64) .or. schema%labels(2, record) /= int(wanted_level, int64)) return
    end do
    required = streamed_upper_air_workspace_bytes(partition)
    if (required < 1 .or. byte_limit < required) return
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    stream = c_null_ptr; handle = c_null_ptr; opened = .false.
    status = 2
    allocate (staged(partition%local_points, records), stat=ios)
    if (ios /= 0) goto 900
    allocate (values(partition%global_points), stat=ios)
    if (ios /= 0) goto 900
    do path_index = 1, len(path)
      path_bytes(path_index) = path(path_index:path_index)
    end do
    path_bytes(len(path) + 1) = c_null_char
    stream = file_open(path_bytes, 'rb'//c_null_char)
    reader_status = 2
    if (.not. c_associated(stream)) goto 800
    opened = .true.; completed = 0
    do
      error = 0
      handle = new_message(c_null_ptr, stream, error)
      reader_status = 3
      if (error /= 0) exit
      if (.not. c_associated(handle)) then
        if (file_error(stream) /= 0) exit
        if (file_eof(stream) == 0) exit
        reader_status = 4
        if (completed /= records) exit
        reader_status = 0
        exit
      end if
      reader_status = 4
      if (completed >= records) exit
      record = completed + 1
      reader_status = 3
      if (get_long(handle, 'paramId'//c_null_char, parameter) /= 0) exit
      if (get_long(handle, 'level'//c_null_char, level) /= 0) exit
      if (get_size(handle, 'values'//c_null_char, count) /= 0) exit
      reader_status = 4
      if (count /= schema%value_count) exit
      if (parameter /= schema%labels(1, record) .or. level /= schema%labels(2, record)) exit
      reader_status = 3
      if (get_long(handle, 'dataDate'//c_null_char, date) /= 0) exit
      if (get_long(handle, 'dataTime'//c_null_char, time) /= 0) exit
      reader_status = 4
      if (date /= schema%labels(3, record) .or. time /= schema%labels(4, record)) exit
      if (schema%runtime_grid) then
        reader_status = validate_runtime_initial_grid(handle, schema)
      else
        reader_status = validate_initial_grid(handle, schema%gaussian_order)
      end if
      if (reader_status /= 0) exit
      reader_status = 3
      if (get_values(handle, 'values'//c_null_char, values, count) /= 0) exit
      reader_status = 4
      if (count /= schema%value_count) exit
      error = delete_message(handle); handle = c_null_ptr
      reader_status = 3
      if (error /= 0) exit
      child_status = scatter_streamed_upper_air_record(int(record, int32), values, partition, staged)
      if (child_status /= 0) then
        status = 32 + child_status
        goto 900
      end if
      completed = completed + 1
    end do
800 status = 16 + reader_status
    if (c_associated(handle)) then
      ignored = delete_message(handle); handle = c_null_ptr
    end if
    if (opened) then
      error = file_close(stream); opened = .false.
      if (status == 16 .and. error /= 0) status = 21
    end if
    if (status /= 16) goto 900
    child_status = publish_streamed_upper_air_fields(staged, partition, fields)
    status = 32 + child_status
    if (child_status == 0) status = 0
900 if (c_associated(handle)) ignored = delete_message(handle)
    if (opened) ignored = file_close(stream)
    if (allocated(values)) deallocate (values)
    if (allocated(staged)) deallocate (staged)
    error_number = saved_errno
    call ieee_set_status(saved)
  end function
end module streaming_partitioned_upper_air_loading_port
