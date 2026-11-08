module upper_air_initial_loading_port
  !! Decode every selected upper-air record before publishing field values.
  !! Ports: upper_air_initial_state_loading.S and
  !! operational_upper_air_initial_state_loading.S.
  !! Public ecCodes is reached only through the accepted native reader.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: iso_c_binding, only: c_ptr, c_int, c_f_pointer, c_null_char
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use initial_grib_field_reader_port, only: initial_field_schema, read_initial_fields
  use gridpoint_field_storage_port, only: gridpoint_field_storage_mode_supported
  use upper_air_initial_placement_port, only: place_initial_upper_air_fields, place_operational_upper_air_fields
  implicit none
  private
  public :: load_initial_upper_air_state, load_operational_upper_air_initial_state
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  integer(int32) function load_initial_upper_air_state(path, fields) result(status)
    !! fields(24,19,8,86) is owned by the caller and keeps decoded units.
    !! A file or metadata failure preserves every incoming output value.
    character(len=*), intent(in) :: path
    real(real64), contiguous, intent(inout) :: fields(:, :, :, :)
    status = 1_int32
    if (any(shape(fields) /= [24, 19, 8, 86])) return
    status = load_fields(path, fields, .false.)
  end function

  integer(int32) function load_operational_upper_air_initial_state(path, fields) result(status)
    !! fields(17,137,9,388217) owns the fixed operational physical state.
    !! The complete959-record decoder and placement stages precede success.
    character(len=*), intent(in) :: path
    real(real64), contiguous, intent(inout) :: fields(:, :, :, :)
    status = 1_int32
    if (any(shape(fields) /= [17, 137, 9, 388217])) return
    status = load_fields(path, fields, .true.)
  end function

  integer(int32) function load_fields(path, fields, operational) result(status)
    !! Return0 success,1 admission refusal,2 private allocation failure,
    !! 16+reader status or32+placement status. The new native schema and
    !! metadata are separate typed private arrays; no old packed ABI remains.
    !! Every exit preserves incoming IEEE status and TLS errno, and releases
    !! all private owners. File/message lifetime is owned by the native reader.
    character(len=*), intent(in) :: path
    real(real64), contiguous, intent(inout) :: fields(:, :, :, :)
    logical, intent(in) :: operational
    type(initial_field_schema) :: schema
    real(real64), allocatable :: values(:, :)
    integer(int64), allocatable :: metadata(:, :)
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer(int64) :: points, messages_read
    integer :: records, metadata_words, allocation_status, record, level, family
    integer(int32) :: child_status
    integer, parameter :: cloud_codes(5) = [75, 76, 246, 247, 248]
    status = 1_int32
    if (len(path) < 1 .or. len(path) > 4095) return
    if (index(path, c_null_char) /= 0) return
    if (.not. gridpoint_field_storage_mode_supported()) return
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    if (operational) then
      points = 6599680_int64
      records = 959
      metadata_words = 5
      schema%gaussian_order = 1280
    else
      points = 2048_int64
      records = 76
      metadata_words = 3
      schema%gaussian_order = 0
    end if
    schema%value_count = points
    schema%metadata_words = metadata_words
    status = 2_int32
    allocate (values(points, records), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (metadata(metadata_words, records), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (schema%labels(4, records), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    if (operational) then
      record = 0
      do level = 1, 137
        record = record + 1
        schema%labels(:, record) = [133_int64, int(level, int64), 20260621_int64, 0_int64]
        record = record + 1
        schema%labels(:, record) = [203_int64, int(level, int64), 20260621_int64, 0_int64]
      end do
      do level = 1, 137
        do family = 1, 5
          record = record + 1
          schema%labels(:, record) = [int(cloud_codes(family), int64), int(level, int64), 20260621_int64, 0_int64]
        end do
      end do
    else
      record = 0
      do level = 1, 19
        record = record + 1
        schema%labels(:, record) = [133_int64, int(level, int64), 0_int64, 0_int64]
      end do
      do level = 1, 19
        do family = 1, 3
          record = record + 1
          schema%labels(:, record) = [int(245 + family, int64), int(level, int64), 0_int64, 0_int64]
        end do
      end do
    end if
    messages_read = 0_int64
    child_status = read_initial_fields(path, schema, values, metadata, messages_read)
    status = 16_int32 + int(child_status, int32)
    if (child_status /= 0_c_int) goto 900
    if (operational) then
      child_status = place_operational_upper_air_fields(values, metadata, fields)
    else
      child_status = place_initial_upper_air_fields(values, metadata, fields)
    end if
    status = 32_int32 + int(child_status, int32)
    if (child_status /= 0_c_int) goto 900
    status = 0_int32
900 if (allocated(schema%labels)) deallocate (schema%labels)
    if (allocated(metadata)) deallocate (metadata)
    if (allocated(values)) deallocate (values)
    error_number = saved_errno
    call ieee_set_status(saved)
  end function
end module upper_air_initial_loading_port
