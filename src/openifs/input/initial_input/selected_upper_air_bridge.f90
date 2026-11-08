module forecast_selected_upper_air_bridge
  !! Native SUGRIDUG input bridge. Historical raw machine-counter storage stays
  !! with the assembly interface record; this module owns portable named counts.
  use, intrinsic :: iso_fortran_env, only: int32, int64
  use, intrinsic :: iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use gridpoint_field_storage_port, only: gridpoint_field_state
  use grid_field_configuration_types_port, only: grid_field_configuration
  use forecast_selected_upper_air_context, only: selected_upper_air_context, project_selected_upper_air_context
  use upper_air_initial_loading_port, only: load_initial_upper_air_state
  implicit none
  private
  public :: sugridug, upper_air_input_statistics, get_upper_air_input_statistics
  type :: upper_air_input_statistics
    integer(int64) :: revision = 1, entries = 0, completions = 0, failures = 0
    integer(int32) :: rejection = 0
  end type
  type(upper_air_input_statistics), save :: counts
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  integer(int32) function sugridug(pitch,levels,local_points,fields,configuration,linear_physics,trajectory_replay,low_resolution,base_filename,kfile) result(status)
    !! The source filename is its first12 characters followed by UA.
    !! KFILE must be0. A failed native bridge returns116 for the owning
    !! controller to stop collectively; no original numerical fallback exists.
    !! Every return preserves whole incoming IEEE state and errno.
    integer(int32), intent(in) :: pitch, levels, local_points, linear_physics, trajectory_replay, low_resolution, kfile
    type(gridpoint_field_state), target, intent(inout) :: fields
    type(grid_field_configuration), intent(in) :: configuration
    character(len=*), intent(in) :: base_filename
    type(selected_upper_air_context) :: context
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    character(len=14) :: path
    integer(int32) :: child
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    counts%entries = counts%entries + 1
    status = 116; child = 1
    if (kfile /= 0 .or. len(base_filename) < 12) goto 900
    child=project_selected_upper_air_context(pitch,levels,local_points,fields,configuration,linear_physics,trajectory_replay,low_resolution,context)
    if (child /= 0) goto 900
    path = base_filename(1:12)//'UA'
    child = load_initial_upper_air_state(path, context%values)
    if (child /= 0) goto 900
    counts%completions = counts%completions + 1; counts%rejection = 0
    status = 0
900 if (status /= 0) then
      counts%failures = counts%failures + 1; counts%rejection = child
    end if
    error_number = saved_errno
    call ieee_set_status(saved)
  end function

  function get_upper_air_input_statistics() result(output)
    !! Return a value copy; callers cannot mutate the single owned count state.
    type(upper_air_input_statistics) :: output
    output = counts
  end function
end module forecast_selected_upper_air_bridge
