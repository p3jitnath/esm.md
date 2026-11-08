!> Build all seven registry methods over live native forecast arrays.
!! Registration changes metadata only. Numerical owners remain with the caller.
module forecast_native_field_registry
  use iso_fortran_env, only: int32, real64
  use forecast_native_field_registry_types
  use forecast_native_field_variable_types
  use forecast_registry_registration
  use forecast_registry_motion
  use forecast_registry_constituents
  use forecast_registry_surface
  use forecast_registry_release, only: release_registry_graph
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_operational_model_types, only: native_operational_model_configuration
  use surface_field_configuration_port, only: surface_field_registry
  use surface_field_storage_port, only: surface_field_state
  implicit none
  private
  public :: initialize_native_field_registry, bind_native_field_registry_model
  public :: prepare_native_field_registry, prepare_runtime_native_field_registry
  public :: release_native_field_registry
contains
  !> Establish the existing field-to-model relationship before registration.
  !! This association owns no model data and must remain valid until release.
  integer(int32) function bind_native_field_registry_model(registry, model) result(status)
    type(native_field_registry), intent(inout) :: registry
    type(native_operational_model_configuration), target, intent(in) :: model
    status = 2
    if (associated(registry%variables) .or. associated(registry%surface)) return
    registry%model => model
    status = 0
  end function

  !> Borrow the source geometry and its actual block width and block count.
  integer(int32) function initialize_native_field_registry(registry, geometry) result(status)
    type(native_field_registry), intent(inout) :: registry
    type(native_geometry_state), target, intent(in) :: geometry
    registry%geometry => geometry
    registry%nproma = geometry%dimensions%nproma
    registry%nblocks = geometry%partition%ngpblks
    status = 0
  end function

  !> Register geometry, motion, constituents, surface, EC physics and radiation.
  !! All array inputs borrow live numerical owners with stable TARGET storage.
  !! The registry keeps earlier metadata allocations live after a failure.
  integer(int32) function prepare_registry(registry, geometry, model, geometry_inputs, gfl, gflt1, &
                 surface_metadata, surface_arrays, ecphysics_inputs, radiation_inputs, extra_aliases, runtime_groups) result(status)
    type(native_field_registry), intent(inout) :: registry
    type(native_geometry_state), target, intent(in) :: geometry
    type(native_operational_model_configuration), target, intent(in) :: model
    type(native_registry_geometry_inputs), intent(in) :: geometry_inputs
    real(real64), pointer, intent(in) :: gfl(:, :, :, :), gflt1(:, :, :, :)
    type(surface_field_registry), intent(in) :: surface_metadata
    type(surface_field_state), target, intent(in) :: surface_arrays
    type(native_registry_ecphysics_inputs), intent(in) :: ecphysics_inputs
    type(native_registry_radiation_inputs), intent(in) :: radiation_inputs
    type(native_registry_extra_aliases), intent(in) :: extra_aliases
    logical, intent(in) :: runtime_groups
    integer(int32) :: child_status
    status = 0
    if (associated(registry%variables)) return
    status = 1
    if (.not. associated(registry%model, model)) return
    child_status = initialize_native_field_registry(registry, geometry)
    child_status = register_registry_geometry(registry%variables, geometry_inputs)
    if (child_status /= 0) goto 900
    child_status = register_registry_gmv(registry%variables, model%motion)
    if (child_status /= 0) goto 900
    child_status = register_registry_gfl(registry%variables, model%fields, gfl, gflt1, extra_aliases)
    if (child_status /= 0) goto 900
    child_status=register_registry_surface(registry%surface,surface_metadata,surface_arrays,registry%nproma,runtime_groups,extra_aliases)
    if (child_status /= 0) goto 900
    child_status = register_registry_ec_physics(registry%variables, ecphysics_inputs)
    if (child_status /= 0) goto 900
    child_status = register_registry_radiation(registry%variables, radiation_inputs)
    if (child_status /= 0) goto 900
    status = 0
    return
900 status = 2
  end function

  integer(int32) function prepare_native_field_registry(registry, geometry, model, geometry_inputs, gfl, gflt1, &
                                 surface_metadata, surface_arrays, ecphysics_inputs, radiation_inputs, extra_aliases) result(status)
    type(native_field_registry), intent(inout) :: registry
    type(native_geometry_state), target, intent(in) :: geometry
    type(native_operational_model_configuration), target, intent(in) :: model
    type(native_registry_geometry_inputs), intent(in) :: geometry_inputs
    real(real64), pointer, intent(in) :: gfl(:, :, :, :), gflt1(:, :, :, :)
    type(surface_field_registry), intent(in) :: surface_metadata
    type(surface_field_state), target, intent(in) :: surface_arrays
    type(native_registry_ecphysics_inputs), intent(in) :: ecphysics_inputs
    type(native_registry_radiation_inputs), intent(in) :: radiation_inputs
    type(native_registry_extra_aliases), intent(in) :: extra_aliases
    status = prepare_registry(registry, geometry, model, geometry_inputs, gfl, gflt1, surface_metadata, surface_arrays, &
                              ecphysics_inputs, radiation_inputs, extra_aliases, .false.)
  end function

  integer(int32) function prepare_runtime_native_field_registry(registry, geometry, model, geometry_inputs, gfl, gflt1, &
                                 surface_metadata, surface_arrays, ecphysics_inputs, radiation_inputs, extra_aliases) result(status)
    type(native_field_registry), intent(inout) :: registry
    type(native_geometry_state), target, intent(in) :: geometry
    type(native_operational_model_configuration), target, intent(in) :: model
    type(native_registry_geometry_inputs), intent(in) :: geometry_inputs
    real(real64), pointer, intent(in) :: gfl(:, :, :, :), gflt1(:, :, :, :)
    type(surface_field_registry), intent(in) :: surface_metadata
    type(surface_field_state), target, intent(in) :: surface_arrays
    type(native_registry_ecphysics_inputs), intent(in) :: ecphysics_inputs
    type(native_registry_radiation_inputs), intent(in) :: radiation_inputs
    type(native_registry_extra_aliases), intent(in) :: extra_aliases
    status = prepare_registry(registry, geometry, model, geometry_inputs, gfl, gflt1, surface_metadata, surface_arrays, &
                              ecphysics_inputs, radiation_inputs, extra_aliases, .true.)
  end function

  !> Release registry metadata before any borrowed numerical owner is released.
  integer(int32) function release_native_field_registry(registry) result(status)
    type(native_field_registry), intent(inout) :: registry
    status = release_registry_graph(registry%variables, registry%surface)
  end function
end module forecast_native_field_registry
