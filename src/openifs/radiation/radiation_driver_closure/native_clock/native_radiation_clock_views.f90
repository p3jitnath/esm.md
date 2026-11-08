!> Borrow the scalar time inputs used by the radiation calculation.
!! These pointers refer to the one canonical clock and namespace. They own
!! no copied TRIP/TERIP or changing clock values. The caller keeps targets live.
module native_radiation_clock_views
  use iso_fortran_env, only: int32, real64
  implicit none
  private
  public :: native_radiation_clock_view, radiation_clock_is_ready
  type :: native_radiation_clock_view
    ! Seconds: source TSTEP and TDT come from first_dt and second_dt.
    real(real64), pointer :: tstep => null(), tdt => null(), rstati => null()
    ! Dimensionless declination sine/cosine and hour angles in radians.
    real(real64), pointer :: rcodec => null(), rsidec => null(), rwsovr => null()
    real(real64), pointer :: rcodecm => null(), rsidecm => null(), rwsovrm => null()
    ! Step entries, encoded YYYYMMDD date and seconds since midnight.
    integer(int32), pointer :: nstart => null(), step => null(), initial_date => null(), initial_seconds => null()
  end type
contains
!> Check associations only; the canonical caller establishes the FP mode.
  logical function radiation_clock_is_ready(clock) result(ready)
    type(native_radiation_clock_view), intent(in) :: clock
    ready = associated(clock%tstep) .and. associated(clock%rstati)
    ready = ready .and. associated(clock%rcodec) .and. associated(clock%rsidec) .and. associated(clock%rwsovr)
    ready = ready .and. associated(clock%rcodecm) .and. associated(clock%rsidecm) .and. associated(clock%rwsovrm)
    ready = ready .and. associated(clock%nstart) .and. associated(clock%step)
    ready = ready .and. associated(clock%initial_date) .and. associated(clock%initial_seconds)
  end function
end module
