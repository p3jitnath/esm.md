!> Own only the optional daily CLIMR array in the canonical TMCC record.
module forecast_optional_daily_climate_storage
  use iso_fortran_env, only: int32, int64, real64
  use native_inactive_startup_controls, only: native_climate_coupling_controls
  use yoephy, only: tephy
  implicit none
  private
  public :: initialize_optional_daily_climate_storage, release_optional_daily_climate_storage
contains
  !> Q and G are local and global point counts. NSTOP is the caller's
  !! completed clock step count. CLIMR has shape(Q,1,15), in source order.
  !! The disabled route preserves every member after checking its inputs.
  !! Enabled allocation precedes scalar stores; failure1 is atomic.
  integer(int32) function initialize_optional_daily_climate_storage(state, physics, q, g, nstop) result(status)
    type(native_climate_coupling_controls), intent(inout) :: state
    type(tephy), intent(in) :: physics
    integer(int32), intent(in) :: q, g, nstop
    real(real64), allocatable :: pending(:, :, :)
    integer :: error
    integer(int32), parameter :: ids(15) = [31, 139, 174, 15, 16, 17, 18, 210186, 210187, 210188, 210189, 210190, 210191, 66, 67]
    status = 2
    if (state%lmcc04 .or. state%lmcciec .or. state%lnemocoup .or. state%lnemo1way) return
    if (state%lmcc_compo .or. state%lmcc05) return
    if (physics%nalbedoscheme /= 2) return
    if (physics%lecurr .or. physics%leobc .or. physics%leobcice .or. physics%leoclake) return
    if (allocated(state%climr)) return
    if (q < 1 .or. g < 1 .or. q > g .or. nstop < 0 .or. nstop == huge(nstop)) return
    if (.not. state%lmccec) then
      status = 0
      return
    end if
    allocate (pending(q, 1, 15), stat=error)
    if (error /= 0) then
      status = 1
      return
    end if
    pending = transfer(int(z'C08F380000000000', int64), 0.0_real64)
    if (state%nfrcpl <= 0) state%nfrcpl = nstop + 1
    state%nclimtot = 15
    state%nclimr = 15
    state%np1 = 1
    state%np2 = 1
    state%njdcr1 = -999
    state%ncligc = -999
    state%ncligc(1:15) = ids
    call move_alloc(pending, state%climr)
    status = 0
  end function
  !> Release CLIMR only; all scalar and unrelated array values survive.
  integer(int32) function release_optional_daily_climate_storage(state) result(status)
    type(native_climate_coupling_controls), intent(inout) :: state
    if (allocated(state%climr)) deallocate (state%climr)
    status = 0
  end function
end module
