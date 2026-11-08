!> Reuse the sole native trajectory owner for the source-empty namespace.
module forecast_owned_trajectory_namespace
  use iso_fortran_env, only: int32
  use forecast_native_trajectory_types, only: native_empty_trajectory_state
  implicit none
  private
  public :: native_empty_trajectory_state, initialize_owned_trajectory_namespace
contains
  !> Admit the three compiler-created absent source owners without a copy.
 !! The caller supplies its actual final trajectory record. A fresh declaration
 !! gives MSTEPTRAJW, MSTEPTRAJR and TRAJEC unallocated descriptors. No data,
 !! array bounds or extra trajectory owner are manufactured or released here.
  integer(int32) function initialize_owned_trajectory_namespace(state) result(status)
    type(native_empty_trajectory_state), intent(in) :: state
    status = 2
    if (allocated(state%msteptrajw) .or. allocated(state%msteptrajr) .or. allocated(state%trajec)) return
    status = 0
  end function
end module
