!> Bound the memory that one active upper-air decoder can touch.
!! All sizes are bytes. Existing resident owners remain in the sampled charge.
!! Five page covers include labels, staging, global values, GFL and point indices.
module forecast_upper_air_resident_memory_bounds
  use iso_fortran_env, only: int32, int64
  implicit none
  private
  public :: compute_upper_air_resident_bounds
contains
  !> Return the node headroom and complete cost of one active decoder.
 !! Integer inputs are readonly. HEADROOM and COST change only on status0.
 !! No owner is allocated, copied, touched or credited as resident.
  integer(int32) function compute_upper_air_resident_bounds(node_limit, other_live, available, reserve, codec, &
                               local_points, global_points, levels, gfl_bytes, map_bytes, page_bytes, headroom, cost) result(status)
    integer(int64), intent(in) :: node_limit, other_live, available, reserve, codec, gfl_bytes, map_bytes, page_bytes
    integer(int32), intent(in) :: local_points, global_points, levels
    integer(int64), intent(inout) :: headroom, cost
    integer(int64) :: candidate_headroom, candidate_cost, records, staged, values, labels, minimum_gfl, minimum_map, term
    status = 2
    if (node_limit <= 0 .or. other_live < 0 .or. available < 0 .or. reserve < 0 .or. codec <= 0) return
    if (other_live > node_limit) return
    if (local_points < 1 .or. global_points < local_points .or. levels < 1 .or. levels > 4096) return
    if (page_bytes < 512 .or. page_bytes > 2097152) return
    if (iand(page_bytes, page_bytes - 1_int64) /= 0) return
    if (gfl_bytes < 1 .or. map_bytes < 1) return
    records = 7_int64*int(levels, int64)
    if (.not. product_ok(records, int(local_points, int64), term)) return
    if (.not. product_ok(term, 8_int64, staged)) return
    if (.not. product_ok(int(global_points, int64), 8_int64, values)) return
    if (.not. product_ok(records, 32_int64, labels)) return
    if (.not. product_ok(int(local_points, int64), int(levels, int64), term)) return
    if (.not. product_ok(term, 72_int64, minimum_gfl)) return
    minimum_map = 4_int64*int(local_points, int64)
    if (gfl_bytes < minimum_gfl .or. map_bytes < minimum_map) return
    candidate_headroom = min(node_limit - other_live, available)
    if (reserve > candidate_headroom) return
    candidate_headroom = candidate_headroom - reserve
    candidate_cost = codec
    if (.not. add_cover(labels, page_bytes, candidate_cost)) return
    if (.not. add_cover(staged, page_bytes, candidate_cost)) return
    if (.not. add_cover(values, page_bytes, candidate_cost)) return
    if (.not. add_cover(gfl_bytes, page_bytes, candidate_cost)) return
    if (.not. add_cover(map_bytes, page_bytes, candidate_cost)) return
    headroom = candidate_headroom
    cost = candidate_cost
    status = 0
  end function
  !> Multiply nonnegative byte counts without overflowing an int64 word.
  logical function product_ok(left, right, output) result(ok)
    integer(int64), intent(in) :: left, right
    integer(int64), intent(out) :: output
    ok = .false.
    if (left < 0 .or. right < 0) return
    if (right > 0) then
      if (left > huge(0_int64)/right) return
    end if
    output = left*right
    ok = .true.
  end function
  !> Add a complete page cover when an array's page offset is unknown.
 !! One additional page covers every possible starting byte offset.
  logical function add_cover(bytes, page_bytes, total) result(ok)
    integer(int64), intent(in) :: bytes, page_bytes
    integer(int64), intent(inout) :: total
    integer(int64) :: pages, cover
    ok = .false.
    if (bytes < 0 .or. total < 0) return
    if (bytes == 0) then
      ok = .true.; return
    end if
    pages = (bytes - 1_int64)/page_bytes + 2_int64
    if (pages > huge(0_int64)/page_bytes) return
    cover = pages*page_bytes
    if (cover > huge(0_int64) - total) return
    total = total + cover
    ok = .true.
  end function
end module
