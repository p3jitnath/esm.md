module runtime_streaming_partitioned_upper_air_loading_port
  !! Fixed operational labels with bounded local staging and one decoded field.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: iso_c_binding, only: c_ptr, c_int, c_f_pointer, c_null_char
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use initial_grib_field_reader_port, only: initial_field_schema
  use runtime_partitioned_upper_air_placement_port, only: runtime_partitioned_upper_air_shape
  use streamed_upper_air_record_placement_port, only: streamed_upper_air_workspace_bytes, validate_streamed_upper_air_destination
  use streaming_partitioned_upper_air_loading_port, only: load_streaming_partitioned_upper_air_fields
  implicit none
  private
  public :: load_runtime_streaming_partitioned_upper_air_state, runtime_streaming_upper_air_private_bytes
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  integer(int64) function runtime_streaming_upper_air_private_bytes(partition) result(bytes)
    type(runtime_partitioned_upper_air_shape), intent(in) :: partition
    bytes = streamed_upper_air_workspace_bytes(partition)
    if (bytes > 0) bytes = bytes + 32_int64*7_int64*partition%fields%levels
  end function

  integer(int32) function load_runtime_streaming_partitioned_upper_air_state(path, partition, byte_limit, fields) result(status)
    !! Preserve the frozen N1280/L137 date20260621/time0 route and all959
    !! parameter/level labels. Three checked owners are labels, local staging
    !! and one global decoded field. Final fields change only after valid EOF
    !! and successful fclose. Every exit restores incoming IEEE and errno.
    character(len=*), intent(in) :: path
    type(runtime_partitioned_upper_air_shape), intent(in) :: partition
    integer(int64), intent(in) :: byte_limit
    real(real64), contiguous, intent(inout) :: fields(:, :, :, :)
    type(initial_field_schema) :: schema
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer(int32), parameter :: codes(5) = [75, 76, 246, 247, 248]
    integer(int64) :: required
    integer :: ios, record, level, family
    status = 1
    if (len(path) < 1 .or. len(path) > 4095 .or. index(path, c_null_char) /= 0) return
    if (partition%fields%levels /= 137 .or. partition%global_points /= 6599680) return
    if (validate_streamed_upper_air_destination(partition, fields) /= 0) return
    required = runtime_streaming_upper_air_private_bytes(partition)
    if (required < 1 .or. byte_limit < required) return
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    status = 2
    allocate (schema%labels(4, 959), stat=ios)
    if (ios /= 0) goto 900
    schema%value_count = 6599680_int64; schema%metadata_words = 5; schema%gaussian_order = 1280
    record = 0
    do level = 1, 137
      record = record + 1; schema%labels(:, record) = [133_int64, int(level, int64), 20260621_int64, 0_int64]
      record = record + 1; schema%labels(:, record) = [203_int64, int(level, int64), 20260621_int64, 0_int64]
    end do
    do level = 1, 137
      do family = 1, 5
        record = record + 1
        schema%labels(:, record) = [int(codes(family), int64), int(level, int64), 20260621_int64, 0_int64]
      end do
    end do
    status = load_streaming_partitioned_upper_air_fields(path, schema, partition, byte_limit - 30688_int64, fields)
900 if (allocated(schema%labels)) deallocate (schema%labels)
    error_number = saved_errno
    call ieee_set_status(saved)
  end function
end module runtime_streaming_partitioned_upper_air_loading_port
