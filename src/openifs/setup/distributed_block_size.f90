!> Preserve or select the source one-thread block width from live controls.
module forecast_distributed_block_size
  use iso_c_binding, only: c_int
  use forecast_grid_dimensions, only: native_grid_dimensions
  implicit none
  private
  public :: initialize_operational_distributed_block_size
contains
!> DIMENSIONS is INOUT; only NPROMA changes. Other arguments are unitless.
!! NPROMM/NPROMNH are caller-owned INOUT and commit on success only.
!! The global route has one thread and hydrostatic geometry. A zero
!! LOPTPROMA leaves the live width unchanged, including a width of24.
!! Point counts come from the actual public partition, including world32.
  integer(c_int) function initialize_operational_distributed_block_size(dimensions, local_points, maximum_points, &
                                                                        nonhydrostatic, threads, npromm, npromnh) result(status)
    type(native_grid_dimensions), intent(inout) :: dimensions
    integer(c_int), intent(in) :: local_points, maximum_points, threads
    logical, intent(in) :: nonhydrostatic
    integer(c_int), intent(inout) :: npromm, npromnh
    integer(c_int) :: width, first, last, blocks, trial, next_blocks, next_width
    status = 2_c_int
    if (nonhydrostatic .or. threads /= 1) return
    if (dimensions%nproma < 1 .or. dimensions%nproma > 65536) return
    if (dimensions%loptproma < 0 .or. dimensions%loptproma > 1) return
    if (local_points < 0 .or. maximum_points < 1 .or. maximum_points < local_points) return
    width = dimensions%nproma
    if (dimensions%loptproma == 1) then
      first = width + 1
      last = first + (width*5)/100
      blocks = (maximum_points - 1)/width + 1
      width = (maximum_points - 1)/blocks + 1
      do trial = first, last
        next_blocks = (maximum_points - 1)/trial + 1
        next_width = (maximum_points - 1)/next_blocks + 1
        if (next_blocks < blocks) then
          blocks = next_blocks
          width = next_width
        end if
      end do
    end if
    dimensions%nproma = width
    npromm = width
    npromnh = 1
    status = 0_c_int
  end function
end module forecast_distributed_block_size
