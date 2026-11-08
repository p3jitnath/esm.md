!> Own the forecast-loop scalar namespace and four spectral filter arrays.
module forecast_native_loop_data
  use iso_fortran_env, only: int32, int64, real64
  implicit none
!> Named source values. Arrays use native bounds and descriptors.
  type native_loop_data
    logical :: lejk = .false., lgwdiags_on = .false., liau = .false.
    integer(int32) :: mysetv = 0, nouttype = 0, nprtrn = 0, nprtrv = 0
    logical :: lnudg = .false.
    integer(int32) :: nrsaccfrq = 0, nfrres = 0
    logical :: lrlxg = .false.
    character :: restart = achar(0)
    integer(int32) :: npromatr = 0
    logical :: lecv = .false., lmoderr = .false., lvareps = .false.
    real(real64) :: vp00 = 0.0_real64
    real(real64), allocatable :: spvor_flt(:, :), spdiv_flt(:, :)
    integer(int32) :: nrests(0:40) = 0
    real(real64), allocatable :: spub_flt(:), spvb_flt(:)
    integer(int64) :: owned_mask = 0_int64
  end type
  type(native_loop_data), save, target :: owned_loop_data
!> Readonly values borrowed from the same vertical, transform, control and clock owners.
  type native_loop_upstream
    integer(int32) :: nconf, lelam, larpegef, lecmwf, lgradsp
    integer(int32) :: nproc, myproc, nprtrv, mysetv, npromatr
    integer(int32) :: nflsur, nflevl, nspec2
    real(real64) :: vp00, tstep
  end type
contains
!> Free only the four owned arrays in source reverse order, retaining other values.
  integer(int32) function release_selected_loop_data(state) result(status)
    type(native_loop_data), intent(inout) :: state
    status = 0
    if (state%owned_mask == 0_int64) return
    status = 2
    if (state%owned_mask /= 15_int64) return
    if (allocated(state%spvb_flt)) deallocate (state%spvb_flt)
    if (allocated(state%spub_flt)) deallocate (state%spub_flt)
    if (allocated(state%spdiv_flt)) deallocate (state%spdiv_flt)
    if (allocated(state%spvor_flt)) deallocate (state%spvor_flt)
    state%owned_mask = 0_int64
    status = 0
  end function
!> Release the module-owned namespace through the same typed lifetime operation.
  integer(int32) function release_owned_selected_loop_data() result(status)
    status = release_selected_loop_data(owned_loop_data)
  end function
end module
