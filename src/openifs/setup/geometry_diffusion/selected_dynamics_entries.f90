!> Native selected setup entries reuse the canonical dynamics owners.
module forecast_selected_dynamics_entries
  use iso_c_binding, only: c_int
  use forecast_dynamics_control_defaults, only: native_dynamics_controls, native_dynamics_upstream, &
                                                initialize_selected_dynamics_defaults
  use dynamical_configuration_port, only: native_dynamical_configuration, &
                                          initialize_operational_dynamical_configuration
  use forecast_setup_empty_groups, only: require_empty_geometry_group
  implicit none
  private
  public :: require_empty_dynamics_namelist, initialize_selected_dynamics_controls, initialize_operational_dynamics_core
contains
  !> Require the first uppercase empty NAMDYNA within ten source columns.
  integer(c_int) function require_empty_dynamics_namelist(text) result(status)
    character(*), intent(in) :: text
    status = 2
    if (len(text) < 1 .or. len(text) > 262144) return
    status = require_empty_geometry_group(text, 'NAMDYNA')
  end function
  !> Preserve the selected32-row21-wave source entry and its complete defaults.
  !! UPSTREAM is the existing canonical data-only eight-word native input.
  !! STATE is the same caller-owned TDYNA replacement, with native descriptors.
  integer(c_int) function initialize_selected_dynamics_controls(text, upstream, state) result(status)
    character(*), intent(in) :: text
    type(native_dynamics_upstream), intent(in) :: upstream
    type(native_dynamics_controls), intent(inout) :: state
    status = 2
    if (upstream%ndlon /= 64 .or. upstream%ndglg /= 32 .or. upstream%nsmax /= 21 .or. upstream%nmsmax /= 21) return
    if (upstream%lvertfe /= 1 .or. upstream%ndlnpr /= 0 .or. upstream%lnonhyd_geom /= 0 .or. upstream%nconf /= 1) return
    status = require_empty_dynamics_namelist(text)
    if (status /= 0) return
    status = initialize_selected_dynamics_defaults(state)
  end function
  !> Reuse the owned SUDYNCORE provider with actual first-group LAQUA admission.
  !! The canonical320-byte configuration type remains the only owner.
  integer(c_int) function initialize_operational_dynamics_core(text, state) result(status)
    character(*), intent(in) :: text
    type(native_dynamical_configuration), intent(inout) :: state
    status = 2
    if (len(text) < 1 .or. len(text) > 262144) return
    status = initialize_operational_dynamical_configuration(text, state)
  end function
end module forecast_selected_dynamics_entries
