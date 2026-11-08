module runtime_partitioned_upper_air_placement_port
  !! Map decoded upper-air words into a process-local native field owner.
  !! Live geometry counts and the int32 map remain caller-owned/read only.
  !! There is no duplicate Geometry or map owner. The borrowed view must not
  !! outlive its map target, and all inputs are disjoint from the destination.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use runtime_gridpoint_field_storage_port, only: runtime_gridpoint_shape, bind_runtime_distributed_gridpoint_shape
  use runtime_initial_upper_air_reader_port, only: runtime_initial_grid_metadata
  implicit none
  private
  public :: runtime_partitioned_upper_air_shape, bind_runtime_partitioned_upper_air_shape
  public :: place_runtime_partitioned_upper_air_fields
  public :: place_partitioned_operational_upper_air_fields, validate_partitioned_upper_air_destination
  type :: runtime_partitioned_upper_air_shape
    type(runtime_gridpoint_shape) :: fields
    integer(int32) :: local_points = 0, global_points = 0
    integer(int32), pointer, contiguous :: global_index(:) => null()
  end type
contains
  integer(int32) function bind_runtime_partitioned_upper_air_shape(output,pitch,levels,blocks,local_points,global_points,field_counts,headers,global_index) result(status)
    !! Validate the canonical grid metadata and borrow exactly local_points
    !! one-based packed-point indices. Map values are checked by placement.
    !! Return2 leaves the complete previous output association unchanged.
    type(runtime_partitioned_upper_air_shape), intent(inout) :: output
    integer(int32), intent(in) :: pitch, levels, blocks, local_points, global_points
    integer(int32), intent(in) :: field_counts(4)
    type(runtime_initial_grid_metadata), intent(in) :: headers
    integer(int32), target, contiguous, intent(in) :: global_index(:)
    type(runtime_partitioned_upper_air_shape) :: proposed
    integer(int32) :: rc, largest, north
    integer(int64) :: sum_north
    integer :: j
    status = 2_int32
    rc = bind_runtime_distributed_gridpoint_shape(proposed%fields, pitch, levels, blocks, local_points, global_points, field_counts)
    if (rc /= 0 .or. field_counts(1) /= 9) return
    if (headers%levels /= levels) return
    north = headers%gaussian_order
    if (north < 1 .or. north > 1280 .or. headers%row_count /= 2*north) return
    if (.not. allocated(headers%north_rows)) return
    if (size(headers%north_rows) /= north) return
    sum_north = 0_int64; largest = 0
    do j = 1, north
      if (headers%north_rows(j) < 1) return
      sum_north = sum_north + int(headers%north_rows(j), int64)
      largest = max(largest, headers%north_rows(j))
    end do
    if (2_int64*sum_north /= int(global_points, int64)) return
    if (headers%maximum_longitudes /= largest) return
    if (size(global_index, kind=int64) /= int(local_points, int64)) return
    proposed%local_points = local_points; proposed%global_points = global_points
    proposed%global_index => global_index
    output = proposed
    status = 0_int32
  end function

  integer(int32) function place_runtime_partitioned_upper_air_fields(values, metadata, fields, partition) result(status)
    !! values(global_points,7*levels) retain decoded FP64 words.
    !! metadata(5,7*levels) holds parameter,level,count,date,time int64 words.
    !! fields(pitch,levels,9,blocks) retains copied-field final padding and
    !! receives positive zero in both diagnostic fields, including padding.
    real(real64), contiguous, intent(in) :: values(:, :)
    integer(int64), contiguous, intent(in) :: metadata(:, :)
    real(real64), contiguous, intent(inout) :: fields(:, :, :, :)
    type(runtime_partitioned_upper_air_shape), intent(in) :: partition
    integer(int32) :: pitch, levels, blocks, local_points, global_points
    integer(int64) :: expected_blocks
    status = 1_int32
    pitch = partition%fields%pitch; levels = partition%fields%levels; blocks = partition%fields%blocks
    local_points = partition%local_points; global_points = partition%global_points
    if (partition%fields%main_fields /= 9) return
    if (pitch < 1 .or. pitch > 1024 .or. levels < 1 .or. levels > 256) return
    if (local_points < 1 .or. global_points < 1 .or. local_points > global_points) return
    expected_blocks = (int(local_points, int64) + int(pitch, int64) - 1_int64)/int(pitch, int64)
    if (int(blocks, int64) /= expected_blocks) return
    if (.not. associated(partition%global_index)) return
    if (size(partition%global_index, kind=int64) /= int(local_points, int64)) return
    if (any(shape(fields) /= [pitch, levels, 9, blocks])) return
    if (size(values, 1, kind=int64) /= int(global_points, int64) .or. size(values, 2) < 7*levels) return
    if (size(metadata, 1) /= 5 .or. size(metadata, 2) < 7*levels) return
    if (pitch == 17 .and. levels == 137 .and. global_points == 6599680) then
      status = place_partitioned_operational_upper_air_fields(values, metadata, partition%global_index, fields)
      return
    end if
    status = place_upper_air_words(values, metadata, partition%global_index, fields, global_points, levels)
  end function

  integer(int32) function validate_partitioned_upper_air_destination(global_index, fields) result(status)
    !! The fixed operational partition has17 columns,137 layers,9 fields.
    !! Return1 rejects dimensions and3 rejects an out-of-range map element.
    integer(int32), contiguous, intent(in) :: global_index(:)
    real(real64), contiguous, intent(in) :: fields(:, :, :, :)
    integer(int64) :: local_points, blocks
    integer :: j
    status = 1_int32
    local_points = size(global_index, kind=int64)
    if (local_points < 1_int64 .or. local_points > 6599680_int64) return
    blocks = (local_points + 16_int64)/17_int64
    if (size(fields, 1) /= 17 .or. size(fields, 2) /= 137 .or. size(fields, 3) /= 9) return
    if (size(fields, 4, kind=int64) /= blocks) return
    status = 3_int32
    do j = 1, size(global_index)
      if (global_index(j) < 1 .or. global_index(j) > 6599680) return
    end do
    status = 0_int32
  end function

  integer(int32) function place_partitioned_operational_upper_air_fields(values, metadata, global_index, fields) result(status)
    !! Fixed operational source specialization; no decoded owner is created.
    real(real64), contiguous, intent(in) :: values(:, :)
    integer(int64), contiguous, intent(in) :: metadata(:, :)
    integer(int32), contiguous, intent(in) :: global_index(:)
    real(real64), contiguous, intent(inout) :: fields(:, :, :, :)
    status = 1_int32
    if (size(values, 1, kind=int64) /= 6599680_int64 .or. size(values, 2) < 959) return
    if (size(metadata, 1) /= 5 .or. size(metadata, 2) < 959) return
    status = validate_partitioned_upper_air_destination(global_index, fields)
    if (status /= 0) return
    status = place_upper_air_words(values, metadata, global_index, fields, 6599680_int32, 137_int32)
  end function

  integer(int32) function place_upper_air_words(values, metadata, global_index, fields, global_points, levels) result(status)
    real(real64), contiguous, intent(in) :: values(:, :)
    integer(int64), contiguous, intent(in) :: metadata(:, :)
    integer(int32), contiguous, intent(in) :: global_index(:)
    real(real64), contiguous, intent(inout) :: fields(:, :, :, :)
    integer(int32), intent(in) :: global_points, levels
    integer(int32), parameter :: codes(7) = [133, 203, 75, 76, 246, 247, 248]
    integer(int32), parameter :: slots(7) = [1, 7, 5, 4, 2, 3, 6]
    integer :: j, record, level, family, point, block, column, pitch, q
    status = 3_int32
    do j = 1, size(global_index)
      if (global_index(j) < 1 .or. global_index(j) > global_points) return
    end do
    status = 2_int32
    do record = 1, 7*levels
      q = record - 1
      if (q < 2*levels) then
        level = q/2 + 1; family = mod(q, 2) + 1
      else
        q = q - 2*levels; level = q/5 + 1; family = mod(q, 5) + 3
      end if
      if (metadata(1, record) /= int(codes(family), int64)) return
      if (metadata(2, record) /= int(level, int64)) return
      if (metadata(3, record) /= int(global_points, int64)) return
    end do
    pitch = size(fields, 1)
    do block = 1, size(fields, 4)
      do family = 8, 9
        do level = 1, levels
          do column = 1, pitch
            fields(column, level, family, block) = 0.0_real64
          end do
        end do
      end do
    end do
    do record = 1, 7*levels
      q = record - 1
      if (q < 2*levels) then
        level = q/2 + 1; family = mod(q, 2) + 1
      else
        q = q - 2*levels; level = q/5 + 1; family = mod(q, 5) + 3
      end if
      do point = 1, size(global_index)
        block = (point - 1)/pitch + 1; column = mod(point - 1, pitch) + 1
        fields(column, level, slots(family), block) = values(global_index(point), record)
      end do
    end do
    status = 0_int32
  end function
end module runtime_partitioned_upper_air_placement_port
