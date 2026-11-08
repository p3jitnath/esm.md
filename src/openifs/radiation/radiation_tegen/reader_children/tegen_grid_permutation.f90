!> Preserve original optical-thickness words during the selected grid change.
module native_tegen_grid_permutation
  use iso_c_binding, only: c_double, c_int64_t
  implicit none
  private
  public :: copy_tegen_grid
contains
  !> Rotate longitude by 36 cells and reverse the 46 stored latitude rows.
  !! source and output have shape (72,46,12), with longitude first and month last.
  !! Optical thickness is dimensionless. Source is read-only; output is replaced.
  !! The caller owns disjoint contiguous arrays and admits their complete shapes.
  !! Transfer copies FP64 bits without floating-point arithmetic or flag changes.
  subroutine copy_tegen_grid(source, output)
    real(c_double), intent(in) :: source(72, 46, 12)
    real(c_double), contiguous, intent(inout) :: output(:, :, :)
    integer :: month, source_latitude, destination_latitude, longitude
    integer(c_int64_t) :: word
    do month = 1, 12
      do source_latitude = 1, 46
        destination_latitude = 47 - source_latitude
        do longitude = 1, 36
          word = transfer(source(longitude + 36, source_latitude, month), word)
          output(longitude, destination_latitude, month) = transfer(word, 0.0_c_double)
        end do
        do longitude = 1, 36
          word = transfer(source(longitude, source_latitude, month), word)
          output(longitude + 36, destination_latitude, month) = transfer(word, 0.0_c_double)
        end do
      end do
    end do
  end subroutine copy_tegen_grid
end module native_tegen_grid_permutation
