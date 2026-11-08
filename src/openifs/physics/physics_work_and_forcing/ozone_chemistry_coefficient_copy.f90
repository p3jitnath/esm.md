!> Copy monthly ozone coefficients into each active physical column.
module forecast_ozone_coefficient_copy
  use iso_fortran_env, only: int32, real64
  implicit none
  private
  public :: ozone_coefficient_options, copy_runtime_ozone_chemistry_fields
  type ozone_coefficient_options
    integer(int32) :: coefficient_count = 7, monthly_groups = 1, three_dimensional_groups = 0
  end type
contains
!> Copy unchanged FP64 coefficient bits; this entry calculates no reaction.
!! MONTHLY has shape(7*L,-1:N+2); LATITUDES gives physical row1:N.
!! OUTPUT has shape(P,L,7). Only inclusive active rows FIRST:LAST change.
!! The output and complete borrowed owners are disjoint and contiguous.
  integer(int32) function copy_runtime_ozone_chemistry_fields(pitch, first, last, levels, rows, options, &
                                                              latitudes, monthly, output) result(status)
    integer(int32), intent(in) :: pitch, first, last, levels, rows
    type(ozone_coefficient_options), intent(in) :: options
    integer(int32), intent(in) :: latitudes(:)
    real(real64), intent(in) :: monthly(:, -1:)
    real(real64), intent(inout) :: output(:, :, :)
    integer :: column, level, coefficient, source_plane
    status = 2
    if (pitch < 1 .or. pitch > 1024 .or. levels < 1 .or. levels > 512 .or. rows < 1 .or. rows > 65536) return
    if (first < 1 .or. first > pitch + 1 .or. last < first - 1 .or. last > pitch) return
    if (options%coefficient_count /= 7 .or. options%monthly_groups /= 1 .or. options%three_dimensional_groups /= 0) return
    if (size(latitudes) /= pitch .or. size(monthly, 1) /= 7*levels .or. size(monthly, 2) /= rows + 4) return
    if (size(output, 1) /= pitch .or. size(output, 2) /= levels .or. size(output, 3) /= 7) return
    do column = first, last
      if (latitudes(column) < 1 .or. latitudes(column) > rows) return
    end do
    do coefficient = 1, 7
      do level = 1, levels
        source_plane = (coefficient - 1)*levels + level
        do column = first, last
          output(column, level, coefficient) = monthly(source_plane, latitudes(column))
        end do
      end do
    end do
    status = 0
  end function
end module
