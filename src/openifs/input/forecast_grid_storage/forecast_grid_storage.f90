!> Allocate the four canonical GP_MODEL work arrays without writing their payloads.
module forecast_grid_storage
  use iso_fortran_env, only: int32, int64, real64
  use ieee_exceptions, only: ieee_status_type
  use forecast_grid_work_state, only: native_grid_work_state
  use forecast_lifetime_status, only: save_lifetime_status, restore_lifetime_status
  implicit none
  private
  public :: initialize_forecast_grid_work, release_forecast_grid_work
  public :: forecast_grid_work_sizes, forecast_grid_work_matches
contains
  !> Calculate complete allocation spans before any owner is changed.
  !! P,L,B are points per block, vertical layers and local blocks.
  !! S,F1,F2 are the source interpolation work and buffer field counts.
  !! N is NASLB1, the number of first-buffer cells. All counts are positive.
  !! SPANS and TOTAL are byte counts. Status2 refuses an invalid count or overflow.
  integer(int32) function forecast_grid_work_sizes(p, l, b, s, n, f1, f2, spans, total) result(status)
    integer(int32), intent(in) :: p, l, b, s, f1, f2
    integer(int64), intent(in) :: n
    integer(int64), intent(out) :: spans(4), total
    integer(int64) :: factors(5, 4), value
    integer :: i, j
    status = 2_int32
    spans = 0_int64
    total = 0_int64
    if (min(p, l, b, s, f1, f2) < 1 .or. n < 1_int64 .or. n > int(huge(0_int32), int64)) return
    factors(:, 1) = [4_int64, int(p, int64), int(l, int64), 4_int64, int(b, int64)]
    factors(:, 2) = [8_int64, int(p, int64), int(l, int64), int(s, int64), int(b, int64)]
    factors(:, 3) = [8_int64, n, int(f1, int64), 1_int64, 1_int64]
    factors(:, 4) = [8_int64, int(p, int64), int(f2, int64), int(b, int64), 1_int64]
    do i = 1, 4
      value = 1_int64
      do j = 1, 5
        if (value > huge(value)/factors(j, i)) return
        value = value*factors(j, i)
      end do
      if (total > huge(total) - value) return
      spans(i) = value
      total = total + value
    end do
    status = 0_int32
  end function

  !> Allocate IL0, ZLSCAW, ZSLBUF1 and ZSLBUF2 in their source order.
  !! WORK is the sole caller-owned TARGET and stays fixed while views are live.
  !! The arrays have shapes (P,L,0:3,B), (P,L,S,B), (N,F1), (P,F2,B).
  !! Values retain the source field units and every payload word is unwritten.
  !! BYTE_QUOTA bounds their aggregate bytes, separately from runtime metadata.
  !! A complete matching owner is reused without allocation or payload writes.
  !! Status0 publishes all four owners,1 reports allocation failure,2 refuses input.
  !! Failure releases only this call's acquired prefix and preserves its IEEE/errno.
  integer(int32) function initialize_forecast_grid_work(work, p, l, b, s, n, f1, f2, byte_quota) result(status)
    type(native_grid_work_state), target, intent(inout) :: work
    integer(int32), intent(in) :: p, l, b, s, f1, f2
    integer(int64), intent(in) :: n, byte_quota
    integer(int64) :: spans(4), total
    type(ieee_status_type) :: fp
    integer(int32) :: saved_errno, cleanup_status
    integer :: allocation_status
    status = forecast_grid_work_sizes(p, l, b, s, n, f1, f2, spans, total)
    if (status /= 0_int32) return
    status = 2_int32
    if (byte_quota < total) return
    if (allocated(work%il0) .or. allocated(work%zlscaw) .or. allocated(work%zslbuf1) .or. allocated(work%zslbuf2)) then
      if (forecast_grid_work_matches(work, p, l, b, s, n, f1, f2)) status = 0_int32
      return
    end if
    if (any([work%columns, work%levels, work%blocks, work%scalar_fields, work%first_fields, work%second_fields] /= 0)) return
    if (work%first_extent /= 0_int64) return
    allocate (work%il0(p, l, 0:3, b), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (work%zlscaw(p, l, s, b), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (work%zslbuf1(n, f1), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (work%zslbuf2(p, f2, b), stat=allocation_status)
    if (allocation_status /= 0) goto900
    work%columns = p
    work%levels = l
    work%blocks = b
    work%scalar_fields = s
    work%first_extent = n
    work%first_fields = f1
    work%second_fields = f2
    status = 0_int32
    return
900 continue
    call save_lifetime_status(fp, saved_errno)
    cleanup_status = release_forecast_grid_work(work)
    call restore_lifetime_status(fp, saved_errno)
    status = 1_int32
  end function

  !> Check complete owner identity, exact shapes and lower bounds without writes.
  logical function forecast_grid_work_matches(work, p, l, b, s, n, f1, f2) result(matches)
    type(native_grid_work_state), intent(in) :: work
    integer(int32), intent(in) :: p, l, b, s, f1, f2
    integer(int64), intent(in) :: n
    matches = .false.
    if (.not. allocated(work%il0) .or. .not. allocated(work%zlscaw)) return
    if (.not. allocated(work%zslbuf1) .or. .not. allocated(work%zslbuf2)) return
    if (any([work%columns, work%levels, work%blocks, work%scalar_fields, work%first_fields, work%second_fields] /= &
            [p, l, b, s, f1, f2])) return
    if (work%first_extent /= n) return
    if (any(shape(work%il0, kind=int64) /= [int(p, int64), int(l, int64), 4_int64, int(b, int64)])) return
    if (any(lbound(work%il0) /= [1, 1, 0, 1])) return
    if (any(shape(work%zlscaw, kind=int64) /= [int(p, int64), int(l, int64), int(s, int64), int(b, int64)])) return
    if (any(lbound(work%zlscaw) /= 1)) return
    if (any(shape(work%zslbuf1, kind=int64) /= [n, int(f1, int64)])) return
    if (any(lbound(work%zslbuf1) /= 1)) return
    if (any(shape(work%zslbuf2, kind=int64) /= [int(p, int64), int(f2, int64), int(b, int64)])) return
    if (any(lbound(work%zslbuf2) /= 1)) return
    matches = .true.
  end function

  !> Release the actual owners in allocation order after all borrowers close.
  !! WORK remains allocated at its caller-owned address. Repeated release is safe.
  !! This explicit lifetime operation preserves entry IEEE status and errno.
  integer(int32) function release_forecast_grid_work(work) result(status)
    type(native_grid_work_state), target, intent(inout) :: work
    type(ieee_status_type) :: fp
    integer(int32) :: saved_errno
    integer :: allocation_status
    call save_lifetime_status(fp, saved_errno)
    status = 0_int32
    if (allocated(work%il0)) then
      deallocate (work%il0, stat=allocation_status)
      if (allocation_status /= 0) status = 3_int32
    end if
    if (allocated(work%zlscaw)) then
      deallocate (work%zlscaw, stat=allocation_status)
      if (allocation_status /= 0) status = 3_int32
    end if
    if (allocated(work%zslbuf1)) then
      deallocate (work%zslbuf1, stat=allocation_status)
      if (allocation_status /= 0) status = 3_int32
    end if
    if (allocated(work%zslbuf2)) then
      deallocate (work%zslbuf2, stat=allocation_status)
      if (allocation_status /= 0) status = 3_int32
    end if
    if (status == 0_int32) then
      work%columns = 0
      work%levels = 0
      work%blocks = 0
      work%scalar_fields = 0
      work%first_extent = 0_int64
      work%first_fields = 0
      work%second_fields = 0
    end if
    call restore_lifetime_status(fp, saved_errno)
  end function
end module forecast_grid_storage
