!> Borrow actual radiation setup targets and own the two computed row arrays.
!! No second physical, radiation, geometry, interpolation or clock owner exists.
module forecast_runtime_radiation_prefix_types
  use iso_fortran_env, only: int32
  use iso_c_binding, only: c_ptr, c_null_ptr
  use native_radiation_setup_state, only: owned_radiation_setup_state
  use selected_radiation_control_setup_port, only: radiation_control_upstream_record
  use physical_constant_setup_port, only: forecast_physical_constants
  use yoelwrad, only: telwrad
  use yoecmip, only: tecmip
  use yoephy, only: tephy
  use forecast_grid_dimensions, only: native_grid_dimensions
  use forecast_native_radiation_grid, only: native_radiation_grid
  use forecast_native_radiation_transform_storage, only: native_radiation_transform_storage
  use forecast_interpolation_state_types, only: native_interpolation_state
  use forecast_public_transform, only: native_transform_control
  use forecast_distributed_partition_types, only: native_distributed_partition
  implicit none
  private
  public :: native_runtime_radiation_shape, native_runtime_radiation_prefix_context
  !> Own NRGRI and NLOENG once; the transform and validators borrow these arrays.
 !! NRGRI has bounds1:N. NLOENG has bounds-1:N+2. Global polar metadata is
 !! distinct from later local halo fields in GRID. Keep this owner TARGET
 !! and at a stable address until every borrower has finished.
  type :: native_runtime_radiation_shape
    type(native_radiation_grid), pointer :: grid => null()
    integer(int32), allocatable :: nrgri(:), nloeng(:)
    integer(int32) :: global_first = 0, global_last = 0, polar_rows = 0
    type(c_ptr) :: allocation_address(2) = c_null_ptr
  end type
  !> Readonly typed context replacing the old pointer/capacity argument table.
 !! Every pointer borrows an actual initialized canonical target. UPSTREAM
 !! holds the existing source input interface, never guessed/default flags.
 !! SETUP owns its records; TELWRAD and TECMIP remain their actual external
 !! caller owners. All targets outlive the complete setup/release sequence.
  type :: native_runtime_radiation_prefix_context
    type(owned_radiation_setup_state), pointer :: setup => null()
    type(radiation_control_upstream_record), pointer :: upstream => null()
    type(forecast_physical_constants), pointer :: constants => null()
    type(telwrad), pointer :: longwave => null()
    type(tecmip), pointer :: cmip => null()
    type(tephy), pointer :: physics => null()
    type(native_grid_dimensions), pointer :: dimensions => null()
    type(native_radiation_grid), pointer :: grid => null()
    type(native_runtime_radiation_shape), pointer :: shape => null()
    type(native_radiation_transform_storage), pointer :: storage => null()
    type(native_interpolation_state), pointer :: ri => null(), ro => null()
    type(native_transform_control), pointer :: control => null()
    type(native_distributed_partition), pointer :: partition => null()
  end type
end module forecast_runtime_radiation_prefix_types
