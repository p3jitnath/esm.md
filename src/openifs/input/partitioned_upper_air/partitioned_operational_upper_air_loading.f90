module partitioned_operational_upper_air_loading_port
  !! Decode the fixed operational fields before placing any local value.
  !! The local int32 packed-point map is borrowed and readonly. This module
  !! does not own a Geometry, model controller or full operational field set.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: iso_c_binding, only: c_ptr, c_int, c_f_pointer, c_null_char
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use initial_grib_field_reader_port, only: initial_field_schema, read_initial_fields
  use gridpoint_field_storage_port, only: gridpoint_field_storage_mode_supported
  use runtime_partitioned_upper_air_placement_port, only: validate_partitioned_upper_air_destination,place_partitioned_operational_upper_air_fields
  implicit none
  private
  public :: load_partitioned_operational_upper_air_state
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  integer(int32) function load_partitioned_operational_upper_air_state(path, global_index, fields) result(status)
    !! fields(17,137,9,ceil(local_points/17)) is the caller's local owner.
    !! Private decoded values require50,632,744,960 bytes. Typed metadata
    !! and labels have separate checked allocations. No call is implied by
    !! compilation; a caller must first admit that complete memory demand.
    !! Return1 refuses admission,2 reports private allocation failure,
    !! 16+reader status reports decode failure,32+placement status reports
    !! placement refusal. Every exit restores incoming IEEE state and errno.
    character(len=*), intent(in) :: path
    integer(int32), contiguous, intent(in) :: global_index(:)
    real(real64), contiguous, intent(inout) :: fields(:, :, :, :)
    type(initial_field_schema) :: schema
    real(real64), allocatable :: values(:, :)
    integer(int64), allocatable :: metadata(:, :)
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer(int64) :: messages_read
    integer :: allocation_status, record, level, family
    integer(int32) :: child_status
    integer(int32), parameter :: cloud_codes(5) = [75, 76, 246, 247, 248]
    status = 1_int32
    if (len(path) < 1 .or. len(path) > 4095) return
    if (index(path, c_null_char) /= 0) return
    if (.not. gridpoint_field_storage_mode_supported()) return
    child_status = validate_partitioned_upper_air_destination(global_index, fields)
    if (child_status /= 0) return
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    schema%gaussian_order = 1280; schema%value_count = 6599680_int64; schema%metadata_words = 5
    status = 2_int32
    allocate (values(6599680, 959), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (metadata(5, 959), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (schema%labels(4, 959), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    record = 0
    do level = 1, 137
      record = record + 1; schema%labels(:, record) = [133_int64, int(level, int64), 20260621_int64, 0_int64]
      record = record + 1; schema%labels(:, record) = [203_int64, int(level, int64), 20260621_int64, 0_int64]
    end do
    do level = 1, 137
      do family = 1, 5
        record = record + 1
        schema%labels(:, record) = [int(cloud_codes(family), int64), int(level, int64), 20260621_int64, 0_int64]
      end do
    end do
    messages_read = 0_int64
    child_status = read_initial_fields(path, schema, values, metadata, messages_read)
    status = 16_int32 + child_status
    if (child_status /= 0) goto 900
    child_status = place_partitioned_operational_upper_air_fields(values, metadata, global_index, fields)
    status = 32_int32 + child_status
    if (child_status /= 0) goto 900
    status = 0_int32
900 if (allocated(schema%labels)) deallocate (schema%labels)
    if (allocated(metadata)) deallocate (metadata)
    if (allocated(values)) deallocate (values)
    error_number = saved_errno
    call ieee_set_status(saved)
  end function
end module partitioned_operational_upper_air_loading_port
