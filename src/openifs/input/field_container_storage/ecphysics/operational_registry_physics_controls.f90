!> Apply the five source-selected false physics-runtime assignments.
module forecast_ecmwf_physics_runtime_controls
  use, intrinsic :: iso_c_binding, only: c_int
  use forecast_ecmwf_physics_field_types, only: native_physics_runtime_data
  use forecast_controls_state_types, only: native_forecast_control_namespace
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
  public :: initialize_actual_registry_physics_data, operational_controls
  interface operational_controls
    module procedure initialize_actual_registry_physics_data
  end interface
contains
  !> TEXT and the actual control NAMESPACE are borrowed and unchanged.
  !> STATE is the single caller-owned TARGET runtime record shared by readers.
  !> Status2 rejects the source controls, nonfresh BSS policy or either group
  !> before mutation. Status0 assigns only five named logical members false.
  integer(c_int) function initialize_actual_registry_physics_data(text, namespace, state) result(status)
    character(len=*), intent(in) :: text
    type(native_forecast_control_namespace), intent(in) :: namespace
    type(native_physics_runtime_data), target, intent(inout) :: state
    status = 2_c_int
    if (len(text) < 1 .or. len(text) > 262144) return
    if (namespace%nconf /= 1_c_int) return
    if (namespace%larpegef /= 0_c_int) return
    if (namespace%lelam /= 0_c_int) return
    if (namespace%lifstraj /= 0_c_int) return
    if (namespace%lifsmin /= 0_c_int) return
    if (namespace%lsforc /= 0_c_int) return
    if (namespace%lecmwf /= 1_c_int) return
    ! These source BSS-policy values are preconditions, not repaired outputs.
    if (state%lbfasecv .or. state%lusekf_ref .or. state%luse_smos_tb) return
    if (state%npol_max /= 0_c_int .or. state%nang_max /= 0_c_int) return
    if (state%lesmos_active .or. state%lesmap_active .or. state%lesmos_sekf) return
    if (state%legbrad_active .or. state%leraingg_active) return
    if (allocated(state%gpforceu) .or. allocated(state%gpforcev)) return
    if (allocated(state%gpforcet) .or. allocated(state%gpforceq)) return
    if (require_empty_physics_group(text, 'NAMDYNA_STATIC') /= 0_c_int) return
    if (require_empty_physics_group(text, 'NAMTESTVAR') /= 0_c_int) return
    state%lgradgp = .false.
    state%ldry_ecmwf = .false.
    state%lmusclfa = .false.
    state%lforcewr = .false.
    state%ltestinc = .false.
    status = 0_c_int
  end function initialize_actual_registry_physics_data
end module forecast_ecmwf_physics_runtime_controls
