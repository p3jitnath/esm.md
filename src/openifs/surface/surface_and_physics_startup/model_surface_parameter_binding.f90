!> Attach and recover the one borrowed surface parameter owner.
module forecast_model_surface_parameter_binding
  use iso_fortran_env, only: int32
  use iso_c_binding, only: c_intptr_t, c_loc
  use forecast_operational_model_types, only: native_operational_model_configuration
  use yos_surf, only: tsurf
  implicit none
  private
  public :: attach_model_surface_parameters, detach_model_surface_parameters, lookup_owned_surface_parameters
  interface
    subroutine reject_handle() bind(C, name='abort')
    end subroutine
  end interface
contains
  !> MODEL is the actual application owner. SURFACE is its completed native
 !! parameter object. Only its opaque YSURF handle changes; no payload copies.
  integer(int32) function attach_model_surface_parameters(model, surface) result(status)
    type(native_operational_model_configuration), intent(inout) :: model
    type(tsurf), pointer, intent(in) :: surface
    status = 2
    if (.not. associated(model%initial) .or. .not. associated(surface)) return
    if (transfer(model%physics%ecmwf_physics%ysurf, 0_c_intptr_t) /= 0_c_intptr_t) return
    model%physics%ecmwf_physics%ysurf = transfer(c_loc(surface), model%physics%ecmwf_physics%ysurf)
    status = 0
  end function
  !> Clear only the matching live handle; SURFACE remains caller-owned.
  integer(int32) function detach_model_surface_parameters(model, surface) result(status)
    type(native_operational_model_configuration), intent(inout) :: model
    type(tsurf), pointer, intent(in) :: surface
    status = 2
    if (.not. associated(model%initial) .or. .not. associated(surface)) return
    if (transfer(model%physics%ecmwf_physics%ysurf, 0_c_intptr_t) /= transfer(c_loc(surface), 0_c_intptr_t)) return
    model%physics%ecmwf_physics%ysurf = transfer(0_c_intptr_t, model%physics%ecmwf_physics%ysurf)
    status = 0
  end function
  !> Return the actual caller-owned surface target for its exact live handle.
 !! Supplying the explicit canonical owners replaces the old global lookup.
 !! Invalid ownership retains the original fatal policy through public abort.
  function lookup_owned_surface_parameters(model, surface_owner, handle) result(surface)
    type(native_operational_model_configuration), intent(in) :: model
    type(tsurf), pointer, intent(in) :: surface_owner
    integer(c_intptr_t), intent(in) :: handle
    type(tsurf), pointer :: surface
    nullify (surface)
    if (.not. associated(model%initial)) call reject_handle()
    if (.not. associated(surface_owner)) call reject_handle()
    if (handle == 0_c_intptr_t) call reject_handle()
    if (handle /= transfer(model%physics%ecmwf_physics%ysurf, 0_c_intptr_t)) call reject_handle()
    if (handle /= transfer(c_loc(surface_owner), 0_c_intptr_t)) call reject_handle()
    surface => surface_owner
  end function
end module
