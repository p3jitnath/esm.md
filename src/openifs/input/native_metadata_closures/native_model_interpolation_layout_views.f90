!> Borrow actual model interpolation maps and their produced control record.
!! All integer indices are dimensionless; parity array bounds stay native.
!! MODEL remains the sole TARGET owner. No map, flag or payload is copied.
!! The complete native model is also available for the remaining source
!! geometry, field, dynamics and physics member paths in the historical include.
module forecast_native_model_interpolation_layout_views
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_semi_lagrangian_buffer_types, only: native_semi_lagrangian_buffers, native_interpolation_controls
  implicit none
  private
  public :: borrow_native_model_interpolation_layout
contains
  subroutine borrow_native_model_interpolation_layout(model, view, buffers, controls)
    type(native_operational_model_configuration), target, intent(inout) :: model
    type(native_operational_model_configuration), pointer, intent(out) :: view
    type(native_semi_lagrangian_buffers), pointer, intent(out) :: buffers
    type(native_interpolation_controls), pointer, intent(out) :: controls
    view => model
    buffers => model%buffers
    controls => model%interpolation_controls
  end subroutine
end module
