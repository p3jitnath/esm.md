!> Extend the real radiation point lifetime through exact ZMU retirement.
!! All borrowed TARGET arrays retain their caller-owned storage until release.
module forecast_radiation_retirement
  use iso_fortran_env, only: int32
  use iso_c_binding, only: c_int
  use physical_constant_setup_port, only: forecast_physical_constants
  use forecast_native_radiation_grid, only: native_radiation_grid
  use forecast_native_radiation_transform_storage, only: native_radiation_transform_storage
  use forecast_live_radiation_setup, only: create_live_radiation_point_setup, retire_radiation_zmu
  use forecast_public_transform, only: native_transform_control
  use forecast_distributed_partition_types, only: native_distributed_partition
  implicit none
  private
  public :: create_live_radiation_setup_through_zmu_retirement, retire_live_radiation_zmu
  interface
    subroutine public_abort() bind(C, name="abort")
    end subroutine
  end interface
contains
  !> Call every actual point stage, then free its actual temporary ZMU once.
 !! ROWS is readonly int32(-1:N+2); physical values and controls are borrowed.
 !! G and OWNER mutate through their real native create/retirement entries.
 !! The original source aborts an impossible retirement failure after a
 !! successful complete create. No callback or caller-provided stage exists.
  integer(int32) function create_live_radiation_setup_through_zmu_retirement(owner, g, rows, &
                                                                 control, partition, physical, nradint, nstencilwide) result(status)
    type(native_radiation_transform_storage), target, intent(inout) :: owner
    type(native_radiation_grid), target, intent(inout) :: g
    integer(int32), target, intent(in) :: rows(-1:)
    type(native_transform_control), intent(in) :: control
    type(native_distributed_partition), intent(in) :: partition
    type(forecast_physical_constants), intent(in) :: physical
    integer(int32), intent(in) :: nradint, nstencilwide
    status = create_live_radiation_point_setup(owner, g, rows, control, partition, physical, nradint, nstencilwide)
    if (status /= 0) return
    status = retire_radiation_zmu(owner)
    if (status /= 0) call public_abort()
  end function
  !> Retire only a complete point state; repeated retirement refuses prewrite.
 !! The existing canonical child agrees actual ownership on all processes,
 !! deallocates its real ZMU owner and leaves all thirteen other owners live.
  integer(int32) function retire_live_radiation_zmu(owner) result(status)
    type(native_radiation_transform_storage), target, intent(inout) :: owner
    status = retire_radiation_zmu(owner)
  end function
end module
