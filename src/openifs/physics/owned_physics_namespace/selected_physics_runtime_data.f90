!> Initialize exactly the five selected source runtime switches.
module forecast_selected_physics_runtime_data
  use iso_fortran_env, only: int32
  use forecast_controls_state_types, only: native_forecast_control_namespace
  use forecast_ecmwf_physics_field_types, only: native_physics_runtime_data
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
  public :: initialize_selected_physics_data
contains
  !> Check the actual forecast controls and inactive owners before any mutation.
 !! Text is the real full namelist input. Output is the unique608B-equivalent
 !! native owner shared with field storage and the later forcing stage.
 !! The first five words may have incoming values; all other source BSS-policy
 !! fields must remain false/zero and all four native forcing owners absent.
  integer(int32) function initialize_selected_physics_data(controls, text, output) result(status)
    type(native_forecast_control_namespace), intent(in) :: controls
    character(*), intent(in) :: text
    type(native_physics_runtime_data), intent(inout) :: output
    status = 2
    if (len(text) < 1 .or. len(text) > 262144) return
    if (controls%nconf /= 1 .or. controls%larpegef /= 0 .or. controls%lelam /= 0) return
    if (controls%lifstraj /= 0 .or. controls%lifsmin /= 0 .or. controls%lsforc /= 0 .or. controls%lecmwf /= 1) return
    if (output%lbfasecv .or. output%lusekf_ref .or. output%luse_smos_tb) return
    if (output%npol_max /= 0 .or. output%nang_max /= 0) return
    if (output%lesmos_active .or. output%lesmap_active .or. output%lesmos_sekf) return
    if (output%legbrad_active .or. output%leraingg_active) return
    if (allocated(output%gpforceu) .or. allocated(output%gpforcev)) return
    if (allocated(output%gpforcet) .or. allocated(output%gpforceq)) return
    status = require_empty_physics_group(text, 'NAMDYNA_STATIC'); if (status /= 0) return
    status = require_empty_physics_group(text, 'NAMTESTVAR'); if (status /= 0) return
    output%lgradgp = .false.; output%ldry_ecmwf = .false.
    output%lmusclfa = .false.; output%lforcewr = .false.; output%ltestinc = .false.
    status = 0
  end function
end module
