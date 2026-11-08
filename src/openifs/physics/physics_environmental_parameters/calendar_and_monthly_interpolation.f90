!> Gregorian dates and monthly field interpolation from UPDCAL and UPDATE_ARR.
!! Native arrays own their storage. Callers keep input and output arrays disjoint.
!! Calendar values are integers; monthly fields retain the units of their inputs.
module forecast_calendar_and_monthly_fields
  use iso_fortran_env, only: int32, int64, real64
  implicit none
  private
  public :: update_calendar, interpolate_monthly_field
  interface interpolate_monthly_field
    module procedure interpolate_monthly_2d, interpolate_monthly_3d
  end interface
contains
  !> Advance a valid Gregorian date by a nonnegative number of days.
  !! The three date outputs and twelve month lengths change only on success.
  !! Years 1 through 9999 are supported; the final year must remain below 10000.
  subroutine update_calendar(day, month, year, increment, out_day, out_month, out_year, month_lengths, status)
    integer(int32), intent(in) :: day, month, year, increment
    integer(int32), intent(inout) :: out_day, out_month, out_year, month_lengths(12)
    integer(int32), intent(out) :: status
    integer(int32) :: dd, mm, yy, md(12), i
    integer(int64) :: available
    status = 2
    if (year < 1 .or. year > 9999 .or. month < 1 .or. month > 12 .or. increment < 0) return
    md = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    if (is_leap(year)) md(2) = 29
    if (day < 1 .or. day > md(month)) return
    available = int(md(month) - day, int64)
    do mm = month + 1, 12
      available = available + md(mm)
    end do
    do yy = year + 1, 9999
      available = available + 365
      if (is_leap(yy)) available = available + 1
    end do
    if (int(increment, int64) > available) return
    dd = day; mm = month; yy = year
    do i = 1, increment
      dd = dd + 1
      if (dd <= md(mm)) cycle
      dd = 1; mm = mm + 1
      if (mm <= 12) cycle
      mm = 1; yy = yy + 1; md(2) = 28
      if (is_leap(yy)) md(2) = 29
    end do
    out_day = dd; out_month = mm; out_year = yy; month_lengths = md
    status = 0
  end subroutine

  pure logical function is_leap(year)
    integer(int32), intent(in) :: year
    is_leap = mod(year, 4) == 0 .and. (mod(year, 100) /= 0 .or. mod(year, 400) == 0)
  end function

  !> Interpolate a two-dimensional monthly field with separate FP64 operations.
  !! monthly(x,y,month) is read-only; field(x,y) retains its physical units.
  !! Empty fields perform no arithmetic and do not consume month or weight.
  subroutine interpolate_monthly_2d(monthly, month1, month2, weight, field, status)
    real(real64), intent(in), contiguous :: monthly(:, :, :)
    integer(int32), intent(in) :: month1, month2
    real(real64), intent(in) :: weight
    real(real64), intent(inout), contiguous :: field(:, :)
    integer(int32), intent(out) :: status
    integer :: i, j
    real(real64) :: difference, product
    status = 2
    if (size(monthly, 1) /= size(field, 1) .or. size(monthly, 2) /= size(field, 2)) return
    if (any(shape(field) > 4096) .or. size(field, kind=int64) > 16777216_int64) return
    if (size(field) == 0) then
      status = 0; return
    end if
    if (size(monthly, 3) < 12 .or. min(month1, month2) < 1 .or. max(month1, month2) > 12) return
    do j = 1, size(field, 2)
      do i = 1, size(field, 1)
        difference = monthly(i, j, month1) - monthly(i, j, month2)
        product = difference*weight
        field(i, j) = monthly(i, j, month2) + product
      end do
    end do
    status = 0
  end subroutine

  !> Interpolate a three-dimensional monthly field in Fortran element order.
  !! monthly(x,y,z,month) is read-only; field(x,y,z) is changed on success.
  subroutine interpolate_monthly_3d(monthly, month1, month2, weight, field, status)
    real(real64), intent(in), contiguous :: monthly(:, :, :, :)
    integer(int32), intent(in) :: month1, month2
    real(real64), intent(in) :: weight
    real(real64), intent(inout), contiguous :: field(:, :, :)
    integer(int32), intent(out) :: status
    integer :: i, j, k
    real(real64) :: difference, product
    status = 2
    if (size(monthly, 1) /= size(field, 1) .or. size(monthly, 2) /= size(field, 2) .or. size(monthly, 3) /= size(field, 3)) return
    if (any(shape(field) > 4096) .or. size(field, kind=int64) > 16777216_int64) return
    if (size(field) == 0) then
      status = 0; return
    end if
    if (size(monthly, 4) < 12 .or. min(month1, month2) < 1 .or. max(month1, month2) > 12) return
    do k = 1, size(field, 3)
      do j = 1, size(field, 2)
        do i = 1, size(field, 1)
          difference = monthly(i, j, k, month1) - monthly(i, j, k, month2)
          product = difference*weight
          field(i, j, k) = monthly(i, j, k, month2) + product
        end do
      end do
    end do
    status = 0
  end subroutine
end module
