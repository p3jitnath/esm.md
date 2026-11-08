!> Own the named slow-physics parameters from SUSAVTEND and SUDYN.
!! RSLWX is a dimensionless weight for each global full model level.
!! The original logging and profiling calls are outside this parameter API.
module forecast_slow_physics_parameters
  use iso_fortran_env, only: int32, real64
  implicit none
  private
  public :: native_slow_physics_parameters
  public :: initialize_susavtend_parameters, initialize_slow_physics_parameters
  public :: release_slow_physics_weights
  !> Native data counterpart of YOMSLPHY::TSLPHY, without original methods.
  !! The caller owns this record at a stable address. RSLWX has bounds 1:L.
  !! SAVTEND and SAVTEND5 are later numerical owners and remain absent here.
  type :: native_slow_physics_parameters
    real(real64), allocatable :: rslwx(:)
    integer(int32) :: nvtend = 0
    real(real64), allocatable :: savtend(:, :, :, :), savtend5(:, :, :, :)
    integer(int32) :: mu_savtend = 0, mv_savtend = 0, mt_savtend = 0
  end type
contains
  !> Apply SUSAVTEND's index stores and optional RSLWX allocation.
  !!
  !! LEVEL_COUNT is the actual global number L of full vertical levels.
  !! LSLPHY is the caller's produced slow-physics logical control.
  !! NUNDEFLD is the caller's produced integer missing-field marker.
  !! STATE is fresh on entry: all three allocatable owners must be absent.
  !! The true branch admits 1:L:4096. The false branch does not use L.
  !! Return 0 on success, 1 on allocation failure, and 2 on refused input.
  !! A failed allocation retains the four source-ordered scalar stores.
  !! No floating-point arithmetic or diagnostic I/O is performed here.
  integer(int32) function initialize_susavtend_parameters(state, level_count, lslphy, nundefld) result(status)
    type(native_slow_physics_parameters), intent(inout) :: state
    integer(int32), intent(in) :: level_count, nundefld
    logical, intent(in) :: lslphy
    integer :: allocation_status
    status = 2
    if (allocated(state%rslwx) .or. allocated(state%savtend) .or. allocated(state%savtend5)) return
    if (lslphy) then
      if (level_count < 1 .or. level_count > 4096) return
      state%nvtend = 3
      state%mu_savtend = 1
      state%mv_savtend = 2
      state%mt_savtend = 3
      allocate (state%rslwx(level_count), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1
        return
      end if
    else
      state%nvtend = 0
      state%mu_savtend = nundefld
      state%mv_savtend = nundefld
      state%mt_savtend = nundefld
    end if
    status = 0
  end function initialize_susavtend_parameters

  !> Apply SUSAVTEND and the immediately following active SUDYN stores.
  !!
  !! This source revision writes exactly 0.5 to each active RSLWX level.
  !! The pressure-dependent mask in original SUDYN is commented out.
  !! The caller supplies actual vertical and configuration values; this
  !! routine does not derive controls, read a fixture or construct a clock.
  !! Nearest-even rounding and gradual underflow are caller preconditions.
  !! No full SAVTEND or SAVTEND5 numerical array is allocated or changed.
  integer(int32) function initialize_slow_physics_parameters(state, level_count, lslphy, nundefld) result(status)
    type(native_slow_physics_parameters), intent(inout) :: state
    integer(int32), intent(in) :: level_count, nundefld
    logical, intent(in) :: lslphy
    integer(int32) :: level
    status = initialize_susavtend_parameters(state, level_count, lslphy, nundefld)
    if (status /= 0) return
    if (lslphy) then
      do level = 1, level_count
        state%rslwx(level) = 0.5_real64
      end do
    end if
  end function initialize_slow_physics_parameters

  !> Release this constructor's RSLWX owner only.
  !!
  !! Later SAVTEND and SAVTEND5 owners, integer indices and all other
  !! caller state remain unchanged. The release can be repeated.
  subroutine release_slow_physics_weights(state)
    type(native_slow_physics_parameters), intent(inout) :: state
    if (allocated(state%rslwx)) deallocate (state%rslwx)
  end subroutine release_slow_physics_weights
end module forecast_slow_physics_parameters
