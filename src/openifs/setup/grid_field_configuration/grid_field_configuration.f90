module grid_field_configuration_port
  !! Construct the complete native selected or operational field namespace.
  !! text contains1..262144 namelist bytes. The controls are dimensionless
  !! source flags except levels and positive NSTOP, which count layers/steps.
  !! Output is a fresh caller-owned namespace; constants and text are readonly.
  !! Source order is profiles, NAMGFL, registration, then inactive defaults.
  !! Effects contains2 selected or10 operational output flags, all zero on
  !! success. The compiler owns all layout; original pointer bytes are absent.
  use, intrinsic :: iso_fortran_env, only: int32
  use grid_field_component_types_port, only: field_profile_metadata, grid_field_mode_supported
  use grid_field_component_defaults_port, only: initialize_selected_grid_field_profiles
  use selected_grid_field_namelist_port, only: apply_selected_grid_field_namelist
  use grid_field_configuration_types_port, only: grid_field_configuration
  use grid_field_registration_port, only: register_selected_grid_fields, register_operational_grid_fields
  use inactive_grid_field_defaults_port, only: initialize_selected_inactive_grid_defaults,initialize_operational_inactive_grid_defaults
  use physical_constant_setup_port, only: forecast_physical_constants
  implicit none
  private
  public :: initialize_selected_grid_field_configuration, initialize_operational_grid_field_configuration
contains
  integer(int32) function initialize_selected_grid_field_configuration(output, constants, text, controls, effects) result(status)
    type(grid_field_configuration), intent(inout) :: output
    type(forecast_physical_constants), intent(in) :: constants
    character(len=*), intent(in) :: text
    integer(int32), intent(in) :: controls(8)
    integer(int32), intent(inout) :: effects(2)
    type(field_profile_metadata) :: profiles(9)
    integer(int32), parameter :: required(8) = [19, 0, 25, 1, 1, 0, 1, 1]
    integer(int32) :: rc
    status = 2_int32
    if (len(text) < 1 .or. len(text) > 262144) return
    if (.not. grid_field_mode_supported()) return
    if (any(controls /= required)) return
    rc = initialize_selected_grid_field_profiles(profiles)
    if (rc /= 0) then
      status = 3_int32; return
    end if
    rc = apply_selected_grid_field_namelist(text, profiles)
    if (rc /= 0) return
    if (profiles(4)%nreqin /= -1 .or. profiles(5)%nreqin /= -1) return
    status = register_selected_grid_fields(output, profiles, constants, controls(1), controls(2), effects)
    if (status /= 0) return
    rc = initialize_selected_inactive_grid_defaults(output%registration, output%alias_controls, output%settings, output%inactive)
    if (rc /= 0) status = 3_int32
  end function
  integer(int32) function initialize_operational_grid_field_configuration(output, constants, text, controls, effects) result(status)
    type(grid_field_configuration), intent(inout) :: output
    type(forecast_physical_constants), intent(in) :: constants
    character(len=*), intent(in) :: text
    integer(int32), intent(in) :: controls(9)
    integer(int32), intent(inout) :: effects(10)
    type(field_profile_metadata) :: profiles(9)
    integer(int32) :: rc
    status = 2_int32
    if (len(text) < 1 .or. len(text) > 262144) return
    if (.not. grid_field_mode_supported()) return
    if (controls(1) /= 137 .or. controls(2) /= 0 .or. controls(3) <= 0) return
    if (controls(4) /= 1 .or. controls(5) /= 1 .or. controls(6) /= 0) return
    if (controls(7) /= 1 .or. controls(8) /= 1 .or. controls(9) /= 1) return
    rc = initialize_selected_grid_field_profiles(profiles)
    if (rc /= 0) then
      status = 3_int32; return
    end if
    rc = apply_selected_grid_field_namelist(text, profiles)
    if (rc /= 0) return
    if (profiles(7)%lgp /= 1 .or. profiles(4)%nreqin /= 1 .or. profiles(5)%nreqin /= 1) return
    status = register_operational_grid_fields(output, profiles, constants, controls(1), controls(2), effects(1:2))
    if (status /= 0) return
    rc = initialize_operational_inactive_grid_defaults(output%registration, output%alias_controls, output%settings, output%inactive)
    if (rc /= 0) then
      status = 3_int32; return
    end if
    effects(3:10) = 0_int32
  end function
end module grid_field_configuration_port
