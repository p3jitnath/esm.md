!> Complete fixed operational GP_MODEL second-buffer initialization.
module forecast_operational_grid_work_initialization
  use iso_fortran_env, only: int32, int64, real64
  use forecast_grid_work_state, only: native_grid_work_state
  implicit none
  private
  public :: initialize_operational_grid_work
contains
!> Clear the complete owned ZSLBUF2 payload to positive zero.
!! WORK owns native, disjoint IL0, ZLSCAW, ZSLBUF1 and ZSLBUF2 allocations;
!! its producer establishes their complete source shapes before this call.
!! NSLPAD is the live INT32 interpolation padding count and must be zero.
!! Only ZSLBUF2 is mutated. All inactive rows are included. Other payloads,
!! owner descriptors and metadata remain incoming. STATUS is 0 on completion
!! or 2 before mutation for unsupported metadata or missing ownership.
  subroutine initialize_operational_grid_work(work, nslpad, status)
    type(native_grid_work_state), intent(inout) :: work
    integer(int32), intent(in) :: nslpad
    integer(int32), intent(out) :: status
    status = 2_int32
    if (work%columns /= 17_int32) return
    if (work%levels /= 137_int32) return
    if (work%blocks /= 97055_int32) return
    if (work%scalar_fields /= 12_int32) return
    if (work%first_fields /= 3337_int32) return
    if (work%second_fields /= 1097_int32) return
    if (nslpad /= 0_int32) return
    if (.not. allocated(work%il0)) return
    if (.not. allocated(work%zlscaw)) return
    if (.not. allocated(work%zslbuf1)) return
    if (.not. allocated(work%zslbuf2)) return
    if (size(work%zslbuf2, 1) /= work%columns) return
    if (size(work%zslbuf2, 2) /= work%second_fields) return
    if (size(work%zslbuf2, 3) /= work%blocks) return
    work%zslbuf2(:, :, :) = 0.0_real64
    status = 0_int32
  end subroutine
end module
