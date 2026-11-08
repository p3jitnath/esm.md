module streamed_upper_air_record_placement_port
  !! Stage decoded FP64 words in message order, then publish one complete owner.
  !! The caller owns all arrays. Integer maps use one-based packed global cells.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use runtime_partitioned_upper_air_placement_port, only: runtime_partitioned_upper_air_shape
  implicit none
  private
  public :: validate_streamed_upper_air_destination, scatter_streamed_upper_air_record
  public :: publish_streamed_upper_air_fields, streamed_upper_air_workspace_bytes
contains
  integer(int32) function validate_streamed_upper_air_destination(partition, fields) result(status)
    !! fields(pitch,levels,9,blocks) is mutated only by successful publication.
    type(runtime_partitioned_upper_air_shape), intent(in) :: partition
    real(real64), contiguous, intent(in) :: fields(:, :, :, :)
    integer :: pitch, levels, j
    status = 1
    pitch = partition%fields%pitch; levels = partition%fields%levels
    if (pitch < 1 .or. pitch > 1024 .or. levels < 1 .or. levels > 256) return
    if (partition%fields%main_fields /= 9) return
    if (partition%global_points < 1 .or. partition%global_points > 6599680) return
    if (partition%local_points < 1 .or. partition%local_points > partition%global_points) return
    if (int(partition%fields%blocks, int64) /= (int(partition%local_points, int64) + pitch - 1)/pitch) return
    if (any(shape(fields) /= [pitch, levels, 9, partition%fields%blocks])) return
    if (.not. associated(partition%global_index)) return
    if (size(partition%global_index) /= partition%local_points) return
    status = 3
    do j = 1, partition%local_points
      if (partition%global_index(j) < 1 .or. partition%global_index(j) > partition%global_points) return
    end do
    status = 0
  end function

  integer(int64) function streamed_upper_air_workspace_bytes(partition) result(bytes)
    !! Two checked payloads: local_points by 7*levels, and one global field.
    !! The result excludes the caller's small schema labels and codec reserve.
    type(runtime_partitioned_upper_air_shape), intent(in) :: partition
    bytes = 0
    if (partition%local_points < 1 .or. partition%global_points < partition%local_points) return
    if (partition%global_points > 6599680 .or. partition%fields%levels < 1 .or. partition%fields%levels > 256) return
    bytes = 8_int64*(int(partition%local_points, int64)*7_int64*partition%fields%levels + partition%global_points)
  end function

  integer(int32) function scatter_streamed_upper_air_record(record, values, partition, staged) result(status)
    !! values(global_points) is one decoded field. staged(local_points,7*levels)
    !! receives only column record. The complete map is admitted before writes.
    integer(int32), intent(in) :: record
    real(real64), contiguous, intent(in) :: values(:)
    type(runtime_partitioned_upper_air_shape), intent(in) :: partition
    real(real64), contiguous, intent(inout) :: staged(:, :)
    integer :: point
    status = 1
    if (partition%fields%levels < 1 .or. partition%fields%levels > 256) return
    if (record < 1 .or. record > 7*partition%fields%levels) return
    if (size(values) /= partition%global_points) return
    if (any(shape(staged) /= [partition%local_points, 7*partition%fields%levels])) return
    if (.not. associated(partition%global_index)) return
    if (size(partition%global_index) /= partition%local_points) return
    status = 3
    do point = 1, partition%local_points
      if (partition%global_index(point) < 1 .or. partition%global_index(point) > partition%global_points) return
    end do
    do point = 1, partition%local_points
      staged(point, record) = values(partition%global_index(point))
    end do
    status = 0
  end function

  integer(int32) function publish_streamed_upper_air_fields(staged, partition, fields) result(status)
    !! Preserve copied-field padding and set both diagnostic fields to positive
    !! zero, including padding. This is the accepted whole-placement loop order.
    real(real64), contiguous, intent(in) :: staged(:, :)
    type(runtime_partitioned_upper_air_shape), intent(in) :: partition
    real(real64), contiguous, intent(inout) :: fields(:, :, :, :)
    integer(int32), parameter :: slots(7) = [1, 7, 5, 4, 2, 3, 6]
    integer :: pitch, levels, block, family, level, column, record, q, point
    status = validate_streamed_upper_air_destination(partition, fields)
    if (status /= 0) return
    status = 1
    levels = partition%fields%levels; pitch = partition%fields%pitch
    if (any(shape(staged) /= [partition%local_points, 7*levels])) return
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
      do point = 1, partition%local_points
        block = (point - 1)/pitch + 1; column = mod(point - 1, pitch) + 1
        fields(column, level, slots(family), block) = staged(point, record)
      end do
    end do
    status = 0
  end function
end module streamed_upper_air_record_placement_port
