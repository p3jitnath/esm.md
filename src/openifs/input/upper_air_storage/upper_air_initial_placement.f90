module upper_air_initial_placement_port
  !! Place complete decoded upper-air fields in owned blocked arrays.
  !! Values retain encoded physical units and raw bits. Metadata columns are
  !! (parameter,level,point count[,date,time]); only the first three are read.
  !! Ports: upper_air_initial_state_placement.S and its operational sibling.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  implicit none
  private
  public :: place_initial_upper_air_fields, place_operational_upper_air_fields
contains
  integer(int32) function place_initial_upper_air_fields(values, metadata, fields) result(status)
    !! values(2048,at least76), metadata(3,at least76), fields(24,19,8,86).
    !! All owners are contiguous and disjoint. Validate the whole label set
    !! before any write. Return1 for shape,2 for labels,0 on success.
    !! Slots1,2,3,6 receive physical values; slots4,5,7,8 become positive zero
    !! including their padding. Copied-field padding remains unchanged.
    real(real64), contiguous, intent(in) :: values(:, :)
    integer(int64), contiguous, intent(in) :: metadata(:, :)
    real(real64), contiguous, intent(inout) :: fields(:, :, :, :)
    integer, parameter :: codes(4) = [133, 246, 247, 248], slots(4) = [1, 2, 3, 6]
    integer :: record, family, level, block, cell, point, cells
    status = 1_int32
    if (size(values, 1) /= 2048 .or. size(values, 2) < 76) return
    if (size(metadata, 1) /= 3 .or. size(metadata, 2) < 76) return
    if (any(shape(fields) /= [24, 19, 8, 86])) return
    status = 2_int32
    do record = 1, 76
      if (record <= 19) then
        family = 1; level = record
      else
        family = mod(record - 20, 3) + 2
        level = (record - 20)/3 + 1
      end if
      if (metadata(1, record) /= codes(family) .or. metadata(2, record) /= level) return
      if (metadata(3, record) /= 2048_int64) return
    end do
    do block = 1, 86
      fields(:, :, 4, block) = 0.0_real64
      fields(:, :, 5, block) = 0.0_real64
      fields(:, :, 7, block) = 0.0_real64
      fields(:, :, 8, block) = 0.0_real64
    end do
    do family = 1, 4
      do level = 1, 19
        if (family == 1) then
          record = level
        else
          record = 19 + 3*(level - 1) + family - 1
        end if
        point = 0
        do block = 1, 86
          cells = 24
          if (block == 86) cells = 8
          do cell = 1, cells
            point = point + 1
            fields(cell, level, slots(family), block) = values(point, record)
          end do
        end do
      end do
    end do
    status = 0_int32
  end function

  integer(int32) function place_operational_upper_air_fields(values, metadata, fields) result(status)
    !! values(6599680,at least959), metadata(5,at least959), and
    !! fields(17,137,9,388217) are complete disjoint contiguous native owners.
    !! Check every label before writes. Seven physical slots retain their
    !! copied padding, while diagnostic slots8:9 become complete positive zero.
    !! Return1 for shape,2 for metadata,0 success, with no FP arithmetic.
    real(real64), contiguous, intent(in) :: values(:, :)
    integer(int64), contiguous, intent(in) :: metadata(:, :)
    real(real64), contiguous, intent(inout) :: fields(:, :, :, :)
    integer, parameter :: codes(7) = [133, 203, 75, 76, 246, 247, 248]
    integer, parameter :: slots(7) = [1, 7, 5, 4, 2, 3, 6]
    integer :: record, family, level, block, cell, point, cells
    status = 1_int32
    if (size(values, 1) /= 6599680 .or. size(values, 2) < 959) return
    if (size(metadata, 1) /= 5 .or. size(metadata, 2) < 959) return
    if (any(shape(fields) /= [17, 137, 9, 388217])) return
    status = 2_int32
    do record = 1, 959
      call locate_operational_record(record, level, family)
      if (metadata(1, record) /= codes(family) .or. metadata(2, record) /= level) return
      if (metadata(3, record) /= 6599680_int64) return
    end do
    do block = 1, 388217
      fields(:, :, 8:9, block) = 0.0_real64
    end do
    do record = 1, 959
      call locate_operational_record(record, level, family)
      point = 0
      do block = 1, 388217
        cells = min(17, 6599680 - point)
        do cell = 1, cells
          point = point + 1
          fields(cell, level, slots(family), block) = values(point, record)
        end do
      end do
    end do
    status = 0_int32
  end function

  pure subroutine locate_operational_record(record, level, family)
    integer, intent(in) :: record
    integer, intent(out) :: level, family
    if (record <= 274) then
      level = (record - 1)/2 + 1
      family = mod(record - 1, 2) + 1
    else
      level = (record - 275)/5 + 1
      family = mod(record - 275, 5) + 3
    end if
  end subroutine
end module upper_air_initial_placement_port
