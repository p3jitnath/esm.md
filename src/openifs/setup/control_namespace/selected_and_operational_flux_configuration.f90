!> Own every selected and operational flux configuration export.
module forecast_selected_flux_configuration
  use iso_fortran_env, only: int32
  use ieee_exceptions, only: ieee_status_type
  use forecast_lifetime_status, only: save_lifetime_status, restore_lifetime_status
  use forecast_native_flux_storage, only: native_forecast_flux_controls
  use forecast_native_flux_controls, only: initialize_inactive_flux_source_values, release_native_forecast_flux_controls
  use forecast_output_namelist, only: native_selected_output_namelist, native_runtime_output_namelist, &
                                      parse_selected_output_namfpc, parse_runtime_output_namfpc
  use physics_configuration_text_port, only: find_physics_group
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
  public :: native_flux_configuration_controls, native_forecast_flux_controls
  public :: initialize_selected_flux_configuration, release_selected_flux_configuration
  public :: initialize_operational_flux_configuration, release_operational_flux_configuration
  type :: native_flux_configuration_controls
    integer(int32) :: nproma, ngpblks, lecmwf, nfpos, lmphys, ldprecips, ldprecips2, nconf
  end type
contains
  !> Initialize the complete selected source record and its two empty arrays.
 !! Output is the sole final TARGET CFU/XFU/MCUF owner. Controls are the eight
 !! source words, with NPROMA24 and NGPBLKS86. First NAMCFU/XFU/MCUF groups
 !! must be empty. The exact selected NAMFPC value parser validates26keys.
 !! No inactive reset flag, family descriptor or wind array is overwritten.
  integer(int32) function initialize_selected_flux_configuration(text, controls, output) result(status)
    character(*), intent(in) :: text
    type(native_flux_configuration_controls), intent(in) :: controls
    type(native_forecast_flux_controls), target, intent(inout) :: output
    type(ieee_status_type) :: saved
    integer(int32) :: saved_error
    call save_lifetime_status(saved, saved_error)
    status = initialize_flux_configuration_body(text, controls, output, .false.)
    call restore_lifetime_status(saved, saved_error)
  end function
  !> Initialize the separate source operational17-by0-by97055 domain.
 !! The runtime NAMFPC parser preserves its30keys and larger source bounds.
  integer(int32) function initialize_operational_flux_configuration(text, controls, output) result(status)
    character(*), intent(in) :: text
    type(native_flux_configuration_controls), intent(in) :: controls
    type(native_forecast_flux_controls), target, intent(inout) :: output
    type(ieee_status_type) :: saved
    integer(int32) :: saved_error
    call save_lifetime_status(saved, saved_error)
    status = initialize_flux_configuration_body(text, controls, output, .true.)
    call restore_lifetime_status(saved, saved_error)
  end function
  integer(int32) function initialize_flux_configuration_body(text, controls, output, operational) result(status)
    character(*), intent(in) :: text
    type(native_flux_configuration_controls), intent(in) :: controls
    type(native_forecast_flux_controls), target, intent(inout) :: output
    logical, intent(in) :: operational
    type(native_selected_output_namelist) :: selected
    type(native_runtime_output_namelist) :: runtime
    integer :: cursor
    status = 2
    if (len(text) < 1 .or. len(text) > 262144) return
    if (controls%lecmwf /= 1 .or. controls%nfpos /= 2 .or. controls%nconf /= 1) return
    if (controls%lmphys /= 0 .or. controls%ldprecips /= 0 .or. controls%ldprecips2 /= 0) return
    if (operational) then
      if (controls%nproma /= 17 .or. controls%ngpblks /= 97055) return
    else
      if (controls%nproma /= 24 .or. controls%ngpblks /= 86) return
    end if
    if (allocated(output%cfu%gfubuf) .or. allocated(output%xfu%xfubuf)) return
    if (allocated(output%xfu%rmwindcalc) .or. allocated(output%xfu%rmnwindcalc)) return
    if (allocated(output%mcuf%rmcufsp) .or. allocated(output%mcuf%rmcuffp)) return
    ! Select the exact original uppercase first group before reusing the value parser.
    cursor = find_physics_group(text, 'NAMFPC', .false.)
    if (cursor == 0) return
    if (operational) then
      status = parse_runtime_output_namfpc('&NAMFPC'//text(cursor:), runtime)
    else
      status = parse_selected_output_namfpc('&NAMFPC'//text(cursor:), selected)
    end if
    if (status /= 0) return
    status = require_empty_physics_group(text, 'NAMCFU')
    if (status /= 0) return
    status = require_empty_physics_group(text, 'NAMXFU')
    if (status /= 0) return
    status = require_empty_physics_group(text, 'NAMMCUF')
    if (status /= 0) return
    status = initialize_inactive_flux_source_values(controls%nproma, controls%ngpblks, output)
  end function
  !> Release only these two selected source allocations and preserve status.
  integer(int32) function release_selected_flux_configuration(output) result(status)
    type(native_forecast_flux_controls), target, intent(inout) :: output
    type(ieee_status_type) :: saved
    integer(int32) :: saved_error
    call save_lifetime_status(saved, saved_error)
    status = release_native_forecast_flux_controls(output)
    call restore_lifetime_status(saved, saved_error)
  end function
  !> Retain the separate operational release entry over the same native owner.
  integer(int32) function release_operational_flux_configuration(output) result(status)
    type(native_forecast_flux_controls), target, intent(inout) :: output
    type(ieee_status_type) :: saved
    integer(int32) :: saved_error
    call save_lifetime_status(saved, saved_error)
    status = release_native_forecast_flux_controls(output)
    call restore_lifetime_status(saved, saved_error)
  end function
end module
