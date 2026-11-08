!> Bind the selected persistent-grid lifetime to the sole canonical work owner.
module forecast_operational_persistent_grid_work
  use iso_fortran_env, only: int32, int64
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_grid_work_state, only: native_grid_work_state
  use forecast_grid_storage, only: initialize_forecast_grid_work, release_forecast_grid_work, forecast_grid_work_sizes
  implicit none
  private
  public :: create_operational_grid_work, release_operational_grid_work
contains
  !> Allocate the four source arrays through their canonical native allocator.
 !! MODEL is a live produced TARGET. WORK is caller-owned TARGET storage and
 !! stays at its final address until every borrowed array view has expired.
 !! IL0(P,L,0:3,B), ZLSCAW(P,L,S,B), SLBUF1(N,F1), SLBUF2(P,F2,B)
 !! retain their numerical field units. No payload is read or initialized.
 !! This selected entry retains P17/L137/B97055/S12/F13337/F21097.
 !! BYTE_QUOTA is a nonnegative capacity in bytes; no duplicate owner is made.
  integer(int32) function create_operational_grid_work(model, work, byte_quota) result(status)
    type(native_operational_model_configuration), target, intent(in) :: model
    type(native_grid_work_state), target, intent(inout) :: work
    integer(int64), intent(in) :: byte_quota
    integer(int32) :: p, l, b, s, f1, f2
    integer(int64) :: n, spans(4), total
    status = 2
    if (.not. model%ready .or. .not. associated(model%initial)) return
    if (.not. allocated(model%initial%geometry)) return
    p = model%initial%geometry%dimensions%nproma
    l = model%initial%geometry%dimensions%nflevg
    b = model%initial%geometry%partition%ngpblks
    s = model%linear_full%ndim
    f1 = model%buffers%first%nfldslb1; f2 = model%buffers%second%nfldslb2
    n = int(model%interpolation%naslb1, int64)
    if (p /= 17 .or. l /= 137 .or. b /= 97055 .or. s /= 12 .or. f1 /= 3337 .or. f2 /= 1097) return
    if (n < 1_int64 .or. n > 2000000_int64) return
    if (allocated(work%il0) .or. allocated(work%zlscaw) .or. allocated(work%zslbuf1) .or. allocated(work%zslbuf2)) return
    status = forecast_grid_work_sizes(p, l, b, s, n, f1, f2, spans, total)
    if (status /= 0) return
    status = 2
    if (byte_quota < total) return
    status = initialize_forecast_grid_work(work, p, l, b, s, n, f1, f2, byte_quota)
  end function
  !> Free only the four canonical payloads, in reverse acquisition order.
 !! WORK is the original successful owner; every borrower is already detached.
  integer(int32) function release_operational_grid_work(work) result(status)
    type(native_grid_work_state), target, intent(inout) :: work
    status = release_forecast_grid_work(work)
  end function
end module
