!> Own grid-motion fields and source-named integer maps.
!! Arrays use FP64 values and one-based Fortran bounds when allocated.
!! Their dimensions are points per block, levels, fields and blocks.
!! This data-only type has no original model method or global dependency.
module forecast_grid_motion_types
  use iso_fortran_env, only: int32, real64
  use type_gmvs, only: type_t0, type_t9, type_t1, type_ph9, type_gp
  implicit none
  private
  public :: native_grid_motion_state, type_t0, type_t9, type_t1, type_ph9, type_gp
  type :: native_grid_motion_state
    real(real64), allocatable :: gmv(:, :, :, :), gmvs(:, :, :)
    real(real64), allocatable :: gmvt1(:, :, :, :), gmvt1s(:, :, :)
    real(real64), allocatable :: gmv5(:, :, :, :), gmv5s(:, :, :)
    real(real64), allocatable :: gmv_depart(:, :, :, :), gmvs_depart(:, :, :)
    integer(int32) :: ndimgmv = 0, ndimgmvs = 0
    type(type_t0) :: yt0
    type(type_t9) :: yt9
    type(type_t1) :: yt1
    type(type_ph9) :: yph9
    type(type_gp) :: ygp
    type(type_t0) :: yt5
  end type
end module forecast_grid_motion_types
