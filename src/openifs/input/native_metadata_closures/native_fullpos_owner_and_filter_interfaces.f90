!> Share the produced Fullpos owner and field lists through their native types.
!! These borrowed views retain every array bound, allocation and unwritten member.
!! They acquire no storage. Detach them before the canonical factory releases.
module forecast_native_fullpos_metadata_interfaces
  use forecast_fullpos_state_types, only: native_fullpos_state
  use type_fpfields, only: tfpfields
  use forecast_fullpos_field_construction, only: initialize_fullpos_fields, release_fullpos_fields
  use forecast_fullpos_filter_parent, only: initialize_fullpos_filters, release_fullpos_filters
  use forecast_runtime_fullpos_factory, only: initialize_runtime_fullpos_factory, release_runtime_fullpos_factory
  implicit none
  private
  public :: borrow_fullpos_owner_layout, borrow_fullpos_field_layout
  public :: initialize_fullpos_fields, release_fullpos_fields, initialize_fullpos_filters, release_fullpos_filters
  public :: initialize_runtime_fullpos_factory, release_runtime_fullpos_factory
contains
  subroutine borrow_fullpos_owner_layout(owner, view)
    type(native_fullpos_state), target, intent(inout) :: owner
    type(native_fullpos_state), pointer, intent(out) :: view
    view => owner
  end subroutine
  subroutine borrow_fullpos_field_layout(owner, view)
    type(tfpfields), target, intent(inout) :: owner
    type(tfpfields), pointer, intent(out) :: view
    view => owner
  end subroutine
end module
