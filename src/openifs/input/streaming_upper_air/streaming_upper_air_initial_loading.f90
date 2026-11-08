module streaming_upper_air_initial_loading_port
  !! Own the initial upper-air file transaction with native arrays and maps.
  !! Port: src/openifs/input/streaming_upper_air_loading.S.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: iso_c_binding, only: c_ptr, c_int, c_f_pointer, c_null_char
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use initial_grib_field_reader_port, only: initial_field_schema
  use initial_field_placement_port, only: upper_air_initial_partition
  use runtime_initial_upper_air_reader_port, only: runtime_initial_grid_metadata, make_runtime_upper_air_schema
  use streaming_upper_air_record_reader_port, only: read_streaming_runtime_upper_air_records
  implicit none
  private
  public :: load_streaming_runtime_upper_air_state
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  integer(int32) function load_streaming_runtime_upper_air_state(path, partition, grid, fields) result(status)
    !! fields has shape(block_width,levels,9,blocks) and retains its encoded
    !! physical units: water and ozone are kg/kg mass ratios, and cloud cover
    !! is dimensionless. The seven input families fill slots1,7,5,4,2,3,6.
    !! Only active points change in those slots. On success, slots8 and9
    !! become positive zero over all cells, including final-block padding.
    !! path, maps, grid metadata and fields are complete disjoint native owners.
    !! The caller keeps the borrowed point map alive and already sets grid's
    !! date/seconds to the selected initial spectral identity. It supplies
    !! nearest rounding, gradual underflow and FPCR zero.
    !! Status0 succeeds,1 refuses shape,2 refuses allocation, and16 plus
    !! the private reader code reports file or complete-header failure.
    !! Every failure preserves the complete public fields, incoming flags and errno.
    character(len=*), intent(in) :: path
    type(upper_air_initial_partition), intent(in) :: partition
    type(runtime_initial_grid_metadata), intent(in) :: grid
    real(real64), contiguous, intent(inout) :: fields(:, :, :, :)
    real(real64), allocatable, target :: workspace(:)
    real(real64), pointer :: staged_fields(:, :, :, :)
    integer(int64), allocatable :: metadata(:, :)
    integer(int64) :: local_words, total_words, points, messages_read, records
    type(initial_field_schema) :: schema
    type(ieee_status_type) :: saved_status
    integer(c_int), pointer :: error_number
    integer(c_int) :: saved_errno, child_status
    integer :: width, levels, blocks, q, j, allocation_status
    status = 1_int32
    if (len(path) < 1 .or. len(path) > 4095) return
    if (index(path, c_null_char) /= 0) return
    width = partition%block_width; levels = partition%levels
    blocks = partition%blocks; q = partition%local_points
    if (width < 1 .or. width > 1024 .or. levels < 1 .or. levels > 256) return
    if (q < 1 .or. partition%global_points < 1 .or. q > partition%global_points) return
    if (blocks /= (q - 1)/width + 1) return
    if (any(shape(fields) /= [width, levels, 9, blocks])) return
    if (.not. associated(partition%global_index)) return
    if (size(partition%global_index) /= q) return
    if (.not. is_contiguous(partition%global_index)) return
    if (grid%levels /= levels) return
    if (grid%gaussian_order < 1 .or. grid%gaussian_order > 1280) return
    do j = 1, q
      if (partition%global_index(j) < 1 .or. partition%global_index(j) > partition%global_points) return
    end do
    call ieee_get_status(saved_status)
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    ! These are the private reader's complete-header checks. A malformed
    ! header retains reader code1, which the owner publishes as17.
    status = 17_int32
    if (grid%row_count /= 2*grid%gaussian_order) goto 900
    if (.not. allocated(grid%north_rows)) goto 900
    if (size(grid%north_rows) /= grid%gaussian_order) goto 900
    points = 0_int64
    do j = 1, grid%gaussian_order
      if (grid%north_rows(j) < 1) goto 900
      points = points + int(grid%north_rows(j), int64)
    end do
    points = 2_int64*points
    if (points /= int(partition%global_points, int64) .or. points > 2147483647_int64) goto 900
    if (maxval(grid%north_rows) /= grid%maximum_longitudes) goto 900
    if (grid%date < 1 .or. grid%date > 99991231) goto 900
    if (grid%seconds < 0 .or. grid%seconds > 86340) goto 900
    if (mod(grid%seconds, 60) /= 0) goto 900
    local_words = int(width, int64)*levels*9_int64*blocks
    total_words = points + local_words
    records = 7_int64*levels
    status = 2_int32
    allocate (workspace(total_words), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    call make_runtime_upper_air_schema(grid, schema, child_status)
    ! All metadata bounds were admitted above, so a remaining constructor
    ! refusal is its checked allocation failure.
    if (child_status /= 0_c_int) goto 900
    allocate (metadata(5, records), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    staged_fields(1:width, 1:levels, 1:9, 1:blocks) => workspace(points + 1:total_words)
    staged_fields = fields
    child_status = read_streaming_runtime_upper_air_records(path, schema, partition, &
                                                            workspace(1:points), staged_fields, metadata, messages_read)
    if (child_status /= 0_c_int) then
      status = 16_int32 + int(child_status, int32)
      goto 900
    end if
    staged_fields(:, :, 8:9, :) = 0.0_real64
    fields = staged_fields
    status = 0_int32
900 if (allocated(metadata)) deallocate (metadata)
    if (allocated(schema%labels)) deallocate (schema%labels)
    if (allocated(schema%north_rows)) deallocate (schema%north_rows)
    if (allocated(workspace)) deallocate (workspace)
    error_number = saved_errno
    call ieee_set_status(saved_status)
  end function
end module streaming_upper_air_initial_loading_port
