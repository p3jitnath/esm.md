!> Fresh model trajectory metadata, separate from empty time-record storage.
module forecast_model_trajectory_metadata
  use iso_fortran_env, only: int32, real64
  use forecast_grid_motion_types, only: native_grid_motion_state
  use grid_field_configuration_types_port, only: grid_field_configuration
  implicit none
!> Eight unallocated field owners and one borrowed metadata pointer.
  type native_trajectory_grid_fields
    real(real64), allocatable :: gfl(:, :, :, :), gflt1(:, :, :, :), gflslp(:, :, :, :), gflpt(:, :, :, :), gflpc(:, :, :, :)
    real(real64), allocatable :: gfl5(:, :, :, :), gflslp5(:, :, :, :), gfl_depart(:, :, :, :)
    type(grid_field_configuration), pointer :: ygfl => null()
  end type
  type native_model_trajectory_metadata
    type(native_grid_motion_state) :: yrgmv5
    type(native_trajectory_grid_fields) :: yrgfl5
  end type
contains
!> Establish source-defined null associations without changing motion-map scalars.
!! STATE is caller-owned valid native storage with no live field allocation.
  integer(int32) function initialize_fresh_model_trajectory(state) result(status)
    type(native_model_trajectory_metadata), intent(inout) :: state
    status = 2
    associate (m => state%yrgmv5, g => state%yrgfl5)
      if (allocated(m%gmv) .or. allocated(m%gmvs) .or. allocated(m%gmvt1) .or. allocated(m%gmvt1s)) return
      if (allocated(m%gmv5) .or. allocated(m%gmv5s) .or. allocated(m%gmv_depart) .or. allocated(m%gmvs_depart)) return
      if (allocated(g%gfl) .or. allocated(g%gflt1) .or. allocated(g%gflslp) .or. allocated(g%gflpt)) return
      if (allocated(g%gflpc) .or. allocated(g%gfl5) .or. allocated(g%gflslp5) .or. allocated(g%gfl_depart)) return
      nullify (g%ygfl)
    end associate
    status = 0
  end function
end module
