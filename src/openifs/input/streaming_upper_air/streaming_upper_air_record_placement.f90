module streaming_upper_air_record_placement_port
  !! Copy one decoded record into private local upper-air fields.
  !! Source leaf: md2asm_place_streamed_upper_air_record in streaming_upper_air_loading.S.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use initial_field_placement_port, only: upper_air_initial_partition
  implicit none
  private
  public :: place_streamed_upper_air_record
contains
  integer(int32) function place_streamed_upper_air_record(partition, row, record, fields) result(status)
    !! The parent has validated every map, bound and owner. record starts at
    !! zero. Fields have shape(block_width,levels,9,blocks), in source units.
    !! Only physical cells of one selected field change; padding is retained.
    type(upper_air_initial_partition), intent(in) :: partition
    real(real64), intent(in) :: row(:)
    integer(int64), intent(in) :: record
    real(real64), intent(inout) :: fields(:, :, :, :)
    integer, parameter :: slots(7) = [1, 7, 5, 4, 2, 3, 6]
    integer :: family, level, point, block, cell, cells
    integer(int64) :: cloud_record
    status = 1_int32
    if (record < 0_int64 .or. record >= 7_int64*partition%levels) return
    if (record < 2_int64*partition%levels) then
      level = int(record/2_int64) + 1
      family = int(mod(record, 2_int64)) + 1
    else
      cloud_record = record - 2_int64*partition%levels
      level = int(cloud_record/5_int64) + 1
      family = int(mod(cloud_record, 5_int64)) + 3
    end if
    point = 0
    do block = 1, partition%blocks
      cells = min(partition%block_width, partition%local_points - point)
      do cell = 1, cells
        point = point + 1
        fields(cell, level, slots(family), block) = row(partition%global_index(point))
      end do
    end do
    status = 0_int32
  end function
end module streaming_upper_air_record_placement_port
