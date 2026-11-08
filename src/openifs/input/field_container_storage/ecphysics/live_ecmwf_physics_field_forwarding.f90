!> Forward actual native model and geometry owners to EC physics storage.
module forecast_live_ecmwf_physics_fields
  use, intrinsic :: iso_c_binding, only: c_int
  use forecast_ecmwf_physics_field_types, only: native_ecmwf_physics_fields
  use forecast_ecmwf_physics_fields, only: initialize_runtime_ecmwf_physics_fields, release_runtime_ecmwf_physics_fields
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_operational_model_types, only: native_operational_model_configuration
  implicit none
  private
  public :: create_runtime_ecmwf_physics_fields_from_owners
  public :: release_runtime_ecmwf_physics_fields_from_owners
contains
  !> STATE is the mutable EC physics component of the caller's fields owner.
  !> STATE_MODEL is its borrowed typed model association. It must name MODEL.
  !> GEOMETRY and MODEL remain live at stable TARGET addresses through readers.
  !> All switches and counts come from these actual producers, without copies.
  !> Status0 succeeds,1 is clean storage failure,2 refuses before mutation.
integer(c_int) function create_runtime_ecmwf_physics_fields_from_owners(state,state_model,geometry,model,owned_count) result(status)
    type(native_ecmwf_physics_fields), intent(inout) :: state
    type(native_operational_model_configuration), pointer, intent(in) :: state_model
    type(native_geometry_state), target, intent(in) :: geometry
    type(native_operational_model_configuration), target, intent(in) :: model
    integer(c_int), intent(inout) :: owned_count
    type(native_geometry_state), pointer :: model_geometry
    integer(c_int) :: shape(4)
    status = 2_c_int
    if (.not. associated(state_model, model)) return
    if (.not. associated(model%initial)) return
    if (.not. allocated(model%initial%geometry)) return
    model_geometry => model%initial%geometry
    if (.not. associated(model_geometry, geometry)) return
    if (model%initial%controls%namespace%lr2d /= 0_c_int) return
    if (model%initial%controls%namespace%lecmwf /= 1_c_int) return
    shape(1) = geometry%dimensions%nproma
    shape(2) = geometry%dimensions%nflevg
    shape(3) = geometry%partition%ngpblks
    ! The exact original declaration is TDPHY::NTILES, not TEPHY.
    shape(4) = model%physics_dimensions%ntiles
    status = initialize_runtime_ecmwf_physics_fields(state, shape, owned_count)
  end function create_runtime_ecmwf_physics_fields_from_owners

  !> Release the embedded state before its outer owner. Count is unchanged.
  integer(c_int) function release_runtime_ecmwf_physics_fields_from_owners(state) result(status)
    type(native_ecmwf_physics_fields), intent(inout) :: state
    status = release_runtime_ecmwf_physics_fields(state)
  end function release_runtime_ecmwf_physics_fields_from_owners
end module forecast_live_ecmwf_physics_fields
