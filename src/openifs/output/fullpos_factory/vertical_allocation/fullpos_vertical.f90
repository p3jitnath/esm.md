!> Construct Fullpos hybrid coordinates from live model coefficients.
module forecast_fullpos_vertical
  use iso_fortran_env, only: int32, int64, real64
  use yomvert, only: tvab
  use yomfpg, only: tnamfpv
  use forecast_vertical_coordinate_arrays, only: fill_hybrid_coordinate_arrays
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
  public :: initialize_native_fullpos_vertical, release_native_fullpos_vertical, initialize_native_fullpos_vertical_configuration
contains
  !> Write only NFPLEV and the active0:levels coefficient interval.
 !! The fixed-array tails retain their incoming source words.
  integer(int32) function initialize_native_fullpos_vertical_configuration(text, a, b, record) result(status)
    character(*), intent(in) :: text
    real(real64), intent(in) :: a(0:), b(0:)
    type(tnamfpv), intent(inout) :: record
    integer :: n, j
    status = 2; n = size(a) - 1
    if (n < 1 .or. n > ubound(record%fpvalh, 1) .or. size(b) /= n + 1) return
    status = require_empty_physics_group(text, 'NAMFPG'); if (status /= 0) return
    record%nfplev = n
    do j = 0, n
      record%fpvalh(j) = a(j); record%fpvbh(j) = b(j)
    end do
    status = 0
  end function
  !> The eight arrays retain the TVAB bounds and source allocation order.
 !! A is in Pa, B dimensionless, and reference_pressure in Pa. Both inputs have
 !! bounds0:levels. Levels1:200 fit the original Fullpos namelist coefficient table.
 !! Full-level index0 remains source-unwritten. No original numerical method runs.
integer(int32) function initialize_native_fullpos_vertical(text,a,b,reference_pressure,check_endpoints,output,budget) result(status)
    character(*), intent(in) :: text
    real(real64), intent(in) :: a(0:), b(0:), reference_pressure
    logical, intent(in) :: check_endpoints
    type(tvab), intent(inout) :: output
    integer(int64), intent(in) :: budget
    integer :: n, ierr
    real(real64) :: tolerance, difference
    status = 2; n = size(a) - 1
    if (n < 1 .or. n > 200 .or. size(b) /= n + 1) return
    if (8_int64*(8_int64*n + 5_int64) > budget) return
    if (allocated(output%valh) .or. allocated(output%vbh) .or. allocated(output%vah)) return
    if (allocated(output%vc) .or. allocated(output%vaf) .or. allocated(output%vbf)) return
    if (allocated(output%vdela) .or. allocated(output%vdelb)) return
    status = require_empty_physics_group(text, 'NAMFPG'); if (status /= 0) return
    allocate (output%vah(0:n), stat=ierr); if (ierr /= 0) goto900
    allocate (output%vbh(0:n), stat=ierr); if (ierr /= 0) goto900
    allocate (output%valh(0:n), stat=ierr); if (ierr /= 0) goto900
    allocate (output%vc(1:n), stat=ierr); if (ierr /= 0) goto900
    allocate (output%vdela(1:n), stat=ierr); if (ierr /= 0) goto900
    allocate (output%vdelb(1:n), stat=ierr); if (ierr /= 0) goto900
    allocate (output%vaf(0:n), stat=ierr); if (ierr /= 0) goto900
    allocate (output%vbf(0:n), stat=ierr); if (ierr /= 0) goto900
    status = fill_hybrid_coordinate_arrays(n, reference_pressure, a, b, output%valh, output%vah, output%vbh, &
                                           output%vc, output%vaf, output%vbf, output%vdela, output%vdelb)
    if (status /= 0) goto910
    if (check_endpoints) then
      tolerance = epsilon(1.0_real64)*10000.0_real64
      if (abs(output%vbh(0)) > tolerance) goto920
      if (abs(output%vah(n)) > tolerance) goto920
      difference = output%vbh(n) - 1.0_real64
      if (abs(difference) > tolerance) goto920
    end if
    status = 0; return
920 status = 3; goto910
900 status = 1
910 call release_native_fullpos_vertical(output)
  end function
  !> Release each acquired coordinate owner, leaving other state unchanged.
  subroutine release_native_fullpos_vertical(output)
    type(tvab), intent(inout) :: output
    if (allocated(output%valh)) deallocate (output%valh)
    if (allocated(output%vbh)) deallocate (output%vbh)
    if (allocated(output%vah)) deallocate (output%vah)
    if (allocated(output%vc)) deallocate (output%vc)
    if (allocated(output%vaf)) deallocate (output%vaf)
    if (allocated(output%vbf)) deallocate (output%vbf)
    if (allocated(output%vdela)) deallocate (output%vdela)
    if (allocated(output%vdelb)) deallocate (output%vdelb)
  end subroutine
end module
