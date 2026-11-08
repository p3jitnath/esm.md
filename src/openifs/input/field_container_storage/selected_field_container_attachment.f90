!> Attach the three source time levels to actual model and field-storage owners.
module forecast_selected_field_container_attachment
  use iso_fortran_env, only: int32, real64
  use iso_c_binding, only: c_int, c_ptr, c_f_pointer
  use forecast_initial_fields_storage, only: native_initial_fields_state
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_geometry_state_types, only: native_geometry_state
  use physical_constant_setup_port, only: forecast_physical_constants
  use surface_field_configuration_port, only: surface_field_registry
  use forecast_attached_field_container
  implicit none
  private
  public :: attach_selected_field_containers, attach_runtime_field_containers, release_selected_field_containers
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  integer(int32) function attach_selected_field_containers(state, geometry, model, constants, controls) result(status)
    type(native_initial_fields_state), target, intent(inout) :: state
    type(native_geometry_state), target, intent(in) :: geometry
    type(native_operational_model_configuration), target, intent(in) :: model
    type(forecast_physical_constants), intent(in) :: constants
    integer(int32), intent(in) :: controls(2)
    status = attach_containers(state, geometry, model, constants, controls, .false.)
  end function
  !> Use the same source calculation with live point counts beyond the old selected bound.
 !! Runtime-domain numerical qualification is separate from the retained small source bank.
  integer(int32) function attach_runtime_field_containers(state, geometry, model, constants, controls) result(status)
    type(native_initial_fields_state), target, intent(inout) :: state
    type(native_geometry_state), target, intent(in) :: geometry
    type(native_operational_model_configuration), target, intent(in) :: model
    type(forecast_physical_constants), intent(in) :: constants
    integer(int32), intent(in) :: controls(2)
    status = attach_containers(state, geometry, model, constants, controls, .true.)
  end function
  integer(int32) function attach_containers(state, geometry, model, constants, controls, runtime) result(status)
    type(native_initial_fields_state), target, intent(inout) :: state
    type(native_geometry_state), target, intent(in) :: geometry
    type(native_operational_model_configuration), target, intent(in) :: model
    type(forecast_physical_constants), intent(in) :: constants
    integer(int32), intent(in) :: controls(2)
    logical, intent(in) :: runtime
    integer(c_int), pointer, volatile :: error
    integer(c_int) :: saved_errno
    integer(int32) :: levels(11), settings(8), ignored
    real(real64) :: attributes(4)
    integer :: soil_group, snow_group, ocean_group
    status = 2
    if (controls(2) /= 0) return
    if (.not. associated(state%state_model, model)) return
    if (associated(state%field)) return
    if (.not. associated(state%grid_configuration, model%fields)) return
    if (.not. associated(state%motion, model%motion)) return
    if (.not. associated(state%surface_metadata)) return
    if (.not. model%dynamics%ltwotl .or. .not. model%dynamics%lslag) return
    if (model%dynamics%lpc_full) return
    if (.not. model%physics%ecmwf_physics%lephys .or. model%physics%phy%lmphys) return
    if (state%field_t1%lcreated .or. state%field_t0%lcreated .or. state%field_t9%lcreated) return
    soil_group = surface_group_for_alias(state%surface_metadata, 'YSP_SB%YT')
    snow_group = surface_group_for_alias(state%surface_metadata, 'YSP_SG%YA')
    ocean_group = surface_group_for_alias(state%surface_metadata, 'YSP_OM%YTO')
    if (min(soil_group, snow_group, ocean_group) < 1) return
    levels = [geometry%dimensions%nflevg, geometry%dimensions%nflevg + 1, &
              state%surface_metadata%groups(soil_group)%metadata%layers, &
              state%surface_metadata%groups(snow_group)%metadata%layers, &
              state%surface_metadata%groups(ocean_group)%metadata%layers, &
              model%fields%settings%nchem_flxo, model%fields%settings%nchem_wdflx, model%fields%settings%nchem_ddflx, &
              model%fields%settings%nchem_dv, model%fields%settings%nemis2d, model%fields%settings%nemis2daux]
    attributes = [constants%rv, constants%rcpv, constants%rcw, constants%rcs]
    settings = [geometry%partition%ngptot, geometry%dimensions%nproma, 3_int32, 0_int32, &
                model%fields%alias_controls%ngfl_ext, model%fields%alias_controls%ngfl_ezdiag, controls(1), controls(2)]
    call c_f_pointer(errno_address(), error)
    saved_errno = error
    if (runtime) then
   status=create_runtime_attached_field_container(state%field_t1,state%motion,model%fields,state%grid_configuration,state%surface_metadata,attributes,levels,settings)
    else
   status=create_attached_field_container(state%field_t1,state%motion,model%fields,state%grid_configuration,state%surface_metadata,attributes,levels,settings)
    end if
    if (status /= 0) goto 800
    settings(3) = 2; settings(4) = 1
    if (runtime) then
   status=create_runtime_attached_field_container(state%field_t0,state%motion,model%fields,state%grid_configuration,state%surface_metadata,attributes,levels,settings)
    else
   status=create_attached_field_container(state%field_t0,state%motion,model%fields,state%grid_configuration,state%surface_metadata,attributes,levels,settings)
    end if
    if (status /= 0) goto 800
    settings(3) = 1
    if (runtime) then
   status=create_runtime_attached_field_container(state%field_t9,state%motion,model%fields,state%grid_configuration,state%surface_metadata,attributes,levels,settings)
    else
   status=create_attached_field_container(state%field_t9,state%motion,model%fields,state%grid_configuration,state%surface_metadata,attributes,levels,settings)
    end if
    if (status /= 0) goto 800
    state%field => state%field_t0
    goto 900
800 ignored = release_selected_field_containers(state)
900 error = saved_errno
  end function
  integer function surface_group_for_alias(surface, name) result(group)
    type(surface_field_registry), intent(in) :: surface
    character(*), intent(in) :: name
    integer :: i
    group = 0
    do i = 1, size(surface%aliases)
      if (surface%aliases(i)%name /= name) cycle
      if (surface%aliases(i)%group < 1 .or. surface%aliases(i)%group > size(surface%groups)) return
      group = surface%aliases(i)%group
      return
    end do
  end function
  integer(int32) function release_selected_field_containers(state) result(status)
    type(native_initial_fields_state), intent(inout) :: state
    integer(c_int), pointer, volatile :: error
    integer(c_int) :: saved_errno
    call c_f_pointer(errno_address(), error)
    saved_errno = error
    nullify (state%field)
    status = release_attached_field_container(state%field_t1)
    if (status /= 0) goto 900
    status = release_attached_field_container(state%field_t0)
    if (status /= 0) goto 900
    status = release_attached_field_container(state%field_t9)
900 error = saved_errno
  end function
end module
