!> Save the actual post-processing physics request list into its own owner.
module forecast_fullpos_physics_backup
  use iso_fortran_env, only: int32
  use type_fpfields, only: tfpfields
  use forecast_fullpos_result_types, only: native_fullpos_physics_backup
  implicit none
  private
  public :: backup_fullpos_physics_requests, backup_owned_fullpos_physics_requests
contains
  !> Copy NFPPHY and only its active MFPPHY prefix; retain the remaining words.
 !! FIELDS is readonly canonical Fullpos metadata. OUTPUT remains caller-owned.
  integer(int32) function backup_fullpos_physics_requests(fields, output) result(status)
    type(tfpfields), intent(in) :: fields
    type(native_fullpos_physics_backup), intent(inout) :: output
    integer :: n, j
    status = 2; n = fields%nfpphy
    if (n < 0 .or. n > 1639) return
    if (n > 0) then
      if (.not. allocated(fields%mfpphy)) return
      if (lbound(fields%mfpphy, 1) /= 1 .or. size(fields%mfpphy) /= n) return
    end if
    output%nfpphy = n
    do j = 1, n
      output%mfpphy(j) = fields%mfpphy(j)
    end do
    status = 0
  end function
  !> The former global namespace is an explicit caller-owned native object.
  integer(int32) function backup_owned_fullpos_physics_requests(fields, output) result(status)
    type(tfpfields), intent(in) :: fields
    type(native_fullpos_physics_backup), intent(inout) :: output
    status = backup_fullpos_physics_requests(fields, output)
  end function
end module
