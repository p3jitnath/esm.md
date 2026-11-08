!> Borrow canonical loop, runtime and output-common records without a new owner.
!! Each incoming owner is a live TARGET. Detach its view before owner release.
!! Array bounds and absent owners remain the compiler's native descriptors.
!! These entries do not write payloads, perform arithmetic or call a service.
module forecast_native_loop_and_physics_layout_views
  use forecast_native_loop_data, only: native_loop_data
  use forecast_ecmwf_physics_field_types, only: native_physics_runtime_data
  use forecast_output_request_preparation, only: native_output_common_metadata
  implicit none
  private
  public :: borrow_loop_data_layout, borrow_physics_runtime_layout, borrow_output_common_layout
  public :: borrow_output_ocean_delay
contains
  subroutine borrow_loop_data_layout(owner, view)
    type(native_loop_data), target, intent(inout) :: owner
    type(native_loop_data), pointer, intent(out) :: view
    view => owner
  end subroutine
  subroutine borrow_physics_runtime_layout(owner, view)
    type(native_physics_runtime_data), target, intent(inout) :: owner
    type(native_physics_runtime_data), pointer, intent(out) :: view
    view => owner
  end subroutine
  subroutine borrow_output_common_layout(owner, view)
    type(native_output_common_metadata), target, intent(inout) :: owner
    type(native_output_common_metadata), pointer, intent(out) :: view
    view => owner
  end subroutine
  subroutine borrow_output_ocean_delay(owner, view)
    type(native_output_common_metadata), target, intent(inout) :: owner
    logical, pointer, intent(out) :: view
    view => owner%locedelay
  end subroutine
end module
