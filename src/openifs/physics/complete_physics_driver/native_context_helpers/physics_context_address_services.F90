!> Read native driver dimensions and select private registry block views.
module physics_context_address_services_mod
  use iso_fortran_env, only: int32, real64
  use iso_c_binding, only: c_ptr, c_null_ptr, c_loc
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_native_field_variable_types, only: native_field_variables
  use forecast_field_variable_arrays, only: clone_field_variable_arrays, update_field_variable_views
  use physics_context_helper_counters_mod, only: increment_context_helper_count
  implicit none
  private
  public :: physics_driver_shape, physics_storage_zero_view, physics_storage_begin_block
contains
  !> SHAPE has exactly8 int32 counts; NVTEND and NRFRAD stay source inputs.
  integer(int32) function physics_driver_shape(geometry, model, nvtend, nrfrad, shape) result(status)
    type(native_geometry_state), intent(in) :: geometry
    type(native_operational_model_configuration), intent(in) :: model
    integer(int32), intent(in) :: nvtend, nrfrad
    integer(int32), intent(inout) :: shape(:)
    status = 2
    if (size(shape) /= 8) return
    call increment_context_helper_count(2, 1)
    shape = [geometry%dimensions%nproma, geometry%dimensions%nflevg, geometry%partition%ngpblks, &
             geometry%partition%ngptot, model%fields%registration%ndim, model%fields%registration%ndimslp, nvtend, nrfrad]
    status = 0
  end function
  !> Return the full native data address of ZDISSGW, or null if absent.
  !! The actual readonly rank2 pointer is borrowed; no value is changed.
  function physics_storage_zero_view(dissipation) result(address)
    real(real64), pointer, intent(in) :: dissipation(:, :)
    type(c_ptr) :: address
    call increment_context_helper_count(2, 2)
    address = c_null_ptr
    if (associated(dissipation)) address = c_loc(dissipation)
  end function
  !> Clone private variable metadata before updating the selected block view.
  !! STATE is the canonical registry graph. Borrowed payloads stay unchanged.
  integer(int32) function physics_storage_begin_block(state, block) result(status)
    type(native_field_variables), intent(inout) :: state
    integer(int32), intent(in) :: block
    call increment_context_helper_count(2, 3)
    status = clone_field_variable_arrays(state)
    if (status /= 0) return
    status = update_field_variable_views(state, block)
  end function
end module physics_context_address_services_mod
