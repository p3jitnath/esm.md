!> Own initial field metadata while borrowing one stable model and its payload owners.
!! This is the FIELDS storage lifetime. Each numerical array keeps its existing owner.
module forecast_initial_fields_storage
  use iso_fortran_env, only: int32
  use iso_c_binding, only: c_int, c_ptr, c_f_pointer
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_grid_motion_types, only: native_grid_motion_state
  use grid_field_configuration_types_port, only: grid_field_configuration
  use gridpoint_field_storage_port, only: gridpoint_field_state
  use surface_field_configuration_port, only: surface_field_registry
  use surface_field_storage_port, only: surface_field_state
  use forecast_next_time_field_storage, only: native_next_time_gridpoint_state
  use forecast_attached_field_container, only: native_attached_field_container, attached_field_container_is_empty
  use forecast_native_field_registry_types, only: native_field_registry
  use forecast_ecmwf_physics_field_types, only: native_ecmwf_physics_fields, native_physics_runtime_data
  implicit none
  private
  public::native_initial_fields_state,create_initial_fields_storage,bind_initial_field_storage_owners,release_initial_fields_storage
  type :: native_initial_fields_state
    type(native_operational_model_configuration), pointer :: state_model => null()
    type(native_geometry_state), pointer :: geometry => null()
    type(native_grid_motion_state), pointer :: motion => null()
    type(grid_field_configuration), pointer :: grid_configuration => null()
    type(gridpoint_field_state), pointer :: grid_fields => null()
    type(surface_field_registry), pointer :: surface_metadata => null()
    type(surface_field_state), pointer :: surface_arrays => null()
    type(native_next_time_gridpoint_state), pointer :: next_time => null()
    type(native_physics_runtime_data), pointer :: runtime_physics => null()
    type(native_attached_field_container) :: field_t0, field_t1, field_t9, field_pc, field_pt
    type(native_attached_field_container), pointer :: field => null()
    type(native_field_registry) :: registry
    type(native_ecmwf_physics_fields) :: ecphysics
  end type
  interface
    function fields_errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Allocate one fresh outer record and retain the actual model identity.
  integer(int32) function create_initial_fields_storage(model, output) result(status)
    type(native_operational_model_configuration), target, intent(inout) :: model
    type(native_initial_fields_state), pointer, intent(inout) :: output
    integer(c_int), pointer, volatile :: error
    integer(c_int) :: saved_errno
    integer :: allocation_status
    status = 2
    if (associated(output)) return
    call c_f_pointer(fields_errno_address(), error)
    saved_errno = error
    allocate (output, stat=allocation_status)
    if (allocation_status == 0) then
      output%state_model => model
      status = 0
    else
      status = 1
    end if
    error = saved_errno
  end function
  !> Bind already-owned native inputs; no missing allocation or numerical stage is supplied.
 !! The caller keeps these TARGET objects alive and fixed until all field views are released.
 integer(int32) function bind_initial_field_storage_owners(state,geometry,grid_fields,surface_metadata,surface_arrays,next_time,runtime_physics)result(status)
    type(native_initial_fields_state), intent(inout) :: state
    type(native_geometry_state), target, intent(inout) :: geometry
    type(gridpoint_field_state), target, intent(inout) :: grid_fields
    type(surface_field_registry), target, intent(inout) :: surface_metadata
    type(surface_field_state), target, intent(inout) :: surface_arrays
    type(native_next_time_gridpoint_state), target, optional, intent(inout) :: next_time
    type(native_physics_runtime_data), target, optional, intent(inout) :: runtime_physics
    type(native_geometry_state), pointer :: model_geometry
    status = 2
    if (.not. associated(state%state_model)) return
    if (.not. associated(state%state_model%initial)) return
    if (.not. allocated(state%state_model%initial%geometry)) return
    model_geometry => state%state_model%initial%geometry
    if (.not. associated(model_geometry, geometry)) return
    if (associated(state%field)) return
    state%geometry => geometry
    state%motion => state%state_model%motion
    state%grid_configuration => state%state_model%fields
    state%grid_fields => grid_fields
    state%surface_metadata => surface_metadata
    state%surface_arrays => surface_arrays
    if (present(next_time)) state%next_time => next_time
    if (present(runtime_physics)) state%runtime_physics => runtime_physics
    status = 0
  end function
  !> Release only the outer record after its embedded owners have been released in source order.
  integer(int32) function release_initial_fields_storage(output) result(status)
    type(native_initial_fields_state), pointer, intent(inout) :: output
    integer(c_int), pointer, volatile :: error
    integer(c_int) :: saved_errno
    status = 0
    if (.not. associated(output)) return
    status = 2
    if (associated(output%field)) return
    if (.not. attached_field_container_is_empty(output%field_t0)) return
    if (.not. attached_field_container_is_empty(output%field_t1)) return
    if (.not. attached_field_container_is_empty(output%field_t9)) return
    if (.not. attached_field_container_is_empty(output%field_pc)) return
    if (.not. attached_field_container_is_empty(output%field_pt)) return
    if (associated(output%registry%variables) .or. associated(output%registry%surface)) return
    if (allocated(output%ecphysics%rustrti) .or. allocated(output%ecphysics%rvstrti)) return
    if (allocated(output%ecphysics%rahfsti) .or. allocated(output%ecphysics%revapti)) return
    if (allocated(output%ecphysics%rtskti) .or. allocated(output%ecphysics%phys_mwave)) return
    call c_f_pointer(fields_errno_address(), error)
    saved_errno = error
    deallocate (output)
    nullify (output)
    error = saved_errno
    status = 0
  end function
end module
