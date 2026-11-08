!> Copy wave-return values into the actual blocked surface owner.
module forecast_wave_surface_return
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_int, c_intptr_t, c_loc
  implicit none
  private
  public :: store_operational_wave_surface_fields, return_runtime_wave_surface_fields
  interface
    subroutine public_statistics(event, switch) bind(C, name='gstats_')
      import c_int
      integer(c_int), intent(in) :: event, switch
    end subroutine
  end interface
contains
  !> Copy POINT_COUNT physical values in each returned field without arithmetic.
 !! DESTINATION has shape(block_width,1:9 stored fields,blocks), with blocks>=1.
 !! FIELD_MAP contains the one-based stored column of each returned field.
 !! FIELDS has shape(point_count,at least field_count), in dense column order.
 !! All three arrays must be contiguous and have disjoint writable/source spans.
 !! Support field_count1:9, point_count0:6599680 and block_width1:1024.
 !! Values retain their units and complete FP64 bit patterns. Inactive columns
 !! and the final block's padding remain unchanged. Status2 is atomic refusal.
 !! Caller establishes nearest-even/gradual-underflow before entering this API.
 integer(int32)function store_operational_wave_surface_fields(destination,field_map,fields,field_count,point_count,block_width)result(status)
  real(real64), target, intent(inout) :: destination(:, :, :)
  integer(int32), target, intent(in) :: field_map(:)
  real(real64), target, intent(in) :: fields(:, :)
  integer(int32), intent(in) :: field_count, point_count, block_width
  integer :: column, block, row, physical, position
  integer(c_intptr_t) :: destination_base, source_base, map_base, destination_bytes, source_bytes, map_bytes
  status = 2_int32
  if (field_count < 1 .or. field_count > 9) return
  if (point_count < 0 .or. point_count > 6599680) return
  if (block_width < 1 .or. block_width > 1024) return
  if (size(destination, 1) /= block_width) return
  if (size(destination, 2) < 1 .or. size(destination, 2) > 9) return
  if (size(destination, 3) < 1 .or. size(destination, 3) > 6599680) return
  if (int(point_count, int64) > int(block_width, int64)*size(destination, 3, kind=int64)) return
  if (size(field_map) < field_count) return
  if (size(fields, 1) /= point_count .or. size(fields, 2) < field_count) return
  if (.not. is_contiguous(destination) .or. .not. is_contiguous(field_map) .or. .not. is_contiguous(fields)) return
  do column = 1, field_count
    if (field_map(column) < 1 .or. field_map(column) > size(destination, 2)) return
  end do
  destination_bytes = 8_c_intptr_t*size(destination, kind=c_intptr_t)
  map_bytes = 4_c_intptr_t*int(field_count, c_intptr_t)
  source_bytes = 8_c_intptr_t*int(point_count, c_intptr_t)*int(field_count, c_intptr_t)
  destination_base = transfer(c_loc(destination(1, 1, 1)), 0_c_intptr_t)
  map_base = transfer(c_loc(field_map(1)), 0_c_intptr_t)
  if (mod(destination_base, 8_c_intptr_t) /= 0 .or. mod(map_base, 4_c_intptr_t) /= 0) return
  if (.not. separate_spans(destination_base, destination_bytes, map_base, map_bytes)) return
  if (point_count > 0) then
    source_base = transfer(c_loc(fields(1, 1)), 0_c_intptr_t)
    if (mod(source_base, 8_c_intptr_t) /= 0) return
    if (.not. separate_spans(destination_base, destination_bytes, source_base, source_bytes)) return
  end if
  do column = 1, field_count
    position = 0
    do block = 1, size(destination, 3)
      physical = min(block_width, point_count - position)
      if (physical <= 0) exit
      do row = 1, physical
        destination(row, field_map(column), block) = fields(position + row, column)
      end do
      position = position + physical
    end do
  end do
  status = 0_int32
  end function

  !> Retain both original public profiling boundaries around the same copy.
 !! HOOK_POLICY is the actual readonly int32 hook word; only0 is admitted.
 !! Leaf refusal still receives both calls, as in the source wrapper.
 integer(int32)function return_runtime_wave_surface_fields(destination,field_map,fields,field_count,point_count,block_width,hook_policy)result(status)
  real(real64), target, intent(inout) :: destination(:, :, :)
  integer(int32), target, intent(in) :: field_map(:)
  real(real64), target, intent(in) :: fields(:, :)
  integer(int32), intent(in) :: field_count, point_count, block_width, hook_policy
  status = 2_int32
  if (hook_policy /= 0_int32) return
  call public_statistics(1426_c_int, 0_c_int)
  status = store_operational_wave_surface_fields(destination, field_map, fields, field_count, point_count, block_width)
  call public_statistics(1426_c_int, 1_c_int)
end function

logical function separate_spans(first, first_bytes, second, second_bytes) result(separate)
  integer(c_intptr_t), intent(in) :: first, first_bytes, second, second_bytes
  separate = .false.
  if (first <= 0_c_intptr_t .or. second <= 0_c_intptr_t) return
  if (first_bytes < 0_c_intptr_t .or. second_bytes < 0_c_intptr_t) return
  if (first > huge(first) - first_bytes .or. second > huge(second) - second_bytes) return
  separate = first + first_bytes <= second .or. second + second_bytes <= first
end function
end module forecast_wave_surface_return
