!> Own the two Fullpos event schedules with named controller storage.
module forecast_fullpos_output_control
  use iso_fortran_env, only: int32
  use yomfpc, only: tnamfpobj
  use yomfpcnt, only: tfpcnt
  implicit none
  private
  public :: initialize_native_fullpos_output_control, release_native_fullpos_output_control
contains
  !> Copy source schedule bounds0:ABS(count), retaining signed count at index0.
 !! Only the declared no-monitor-directory route is supported. Monitor basename
 !! is explicit source data; configuration0 denotes the MODEL output geometry.
  integer(int32) function initialize_native_fullpos_output_control(object, monitor_name, output) result(status)
    type(tnamfpobj), intent(in) :: object
    character(*), intent(in) :: monitor_name
    type(tfpcnt), intent(inout) :: output
    integer(int32), allocatable :: events(:), minutes(:)
    integer :: n, m, ierr
    status = 2
    if (allocated(output%nfposts) .or. allocated(output%nfpostsmin)) return
    if (object%cfpmonipath_in /= '.' .or. object%cfpmonipath_out /= '.') return
    if (object%cfpfmt /= 'MODEL') return
    n = object%nfposts(0); m = object%nfpostsmin(0)
    if (n == -huge(n) - 1 .or. m == -huge(m) - 1) return
    n = abs(n); m = abs(m)
    if (n > ubound(object%nfposts, 1) .or. m > ubound(object%nfpostsmin, 1)) return
    allocate (events(0:n), stat=ierr); if (ierr /= 0) goto900
    allocate (minutes(0:m), stat=ierr); if (ierr /= 0) goto900
    events = object%nfposts(0:n); minutes = object%nfpostsmin(0:m)
    output%nfpconf = 0; output%lfpcnt = .false.; output%lfpnamelist = .false.
    output%cfpncf = ' '; output%cnam = ' '
    if (len_trim(monitor_name) > 0) output%cfpncf = './'//trim(monitor_name)
    output%nfrfpos = object%nfrfpos
    call move_alloc(events, output%nfposts); call move_alloc(minutes, output%nfpostsmin)
    status = 0; return
900 status = 1
  end function
  subroutine release_native_fullpos_output_control(output)
    type(tfpcnt), intent(inout) :: output
    if (allocated(output%nfposts)) deallocate (output%nfposts)
    if (allocated(output%nfpostsmin)) deallocate (output%nfpostsmin)
  end subroutine
end module
