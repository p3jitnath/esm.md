!> Compose the complete operational physics configuration with native records.
module forecast_operational_physics_configuration
  use iso_fortran_env, only: int32
  use yoephy, only: tephy
  use physics_configuration_state_port, only: physics_configuration_state
  use physics_configuration_defaults_port, only: apply_remaining_physics_configuration
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  use forecast_operational_physics_requests, only: native_operational_physics_output_requests, &
                                                   parse_operational_physics_output_requests
  use forecast_operational_physics_controls, only: initialize_operational_physics_controls
  implicit none
  private
  public :: initialize_operational_physics_configuration, native_operational_physics_output_requests
contains
!> Validate privately,then apply the17-record source defaults and live overrides.
!! TEXT is read-only bounded ASCII. STATE is the canonical17-record native
!! physics_configuration_state with INOUT intent. Existing array owners and
!! inactive fields remain owned by STATE. CONTROLS is read-only INT32(2),
!! [LSLAG,LUVPOUT]. COUNTS is INOUT INT32(5),and REQUESTS is an INOUT complete
!! native_operational_physics_output_requests. All objects are disjoint.
!! Flags/counts are dimensionless; source physical coefficients retain their
!! units. The caller establishes the same qualified global hydrostatic mode
!! and floating-point environment as the unchanged selected defaults.
!! Status2 preserves STATE,COUNTS and REQUESTS. Status0 publishes the source
!! stores,including eight named canonical TEWCOU fields in original order.
  integer(int32) function initialize_operational_physics_configuration(text, state, controls, counts, requests) result(status)
    character(len=*), intent(in) :: text
    type(physics_configuration_state), intent(inout) :: state
    integer(int32), intent(in) :: controls(2)
    integer(int32), intent(inout) :: counts(5)
    type(native_operational_physics_output_requests), intent(inout) :: requests
    type(native_operational_physics_output_requests) :: staged_requests
    type(tephy) :: staged_physics
    integer(int32) :: staged_counts(5), staged_waves(8)
    character(len=9), parameter :: empty_groups(8) = [character(len=9) :: &
                                          'NAMPHY', 'NAMDVISI', 'NAMARPHY', 'NAPHLC', 'NAMTRAJP', 'NAMSIMPHL', 'NAMRCOEF', 'NAMSCM']
    integer, parameter :: group_lengths(8) = [6, 8, 8, 6, 8, 9, 8, 6]
    integer :: group
    status = 2_int32
    if (len(text) < 1 .or. len(text) > 262144) return
    if (any(controls < 0_int32) .or. any(controls > 1_int32)) return
    do group = 1, 8
      status = require_empty_physics_group(text, empty_groups(group) (1:group_lengths(group)))
      if (status /= 0) return
    end do
    status = parse_operational_physics_output_requests(text, staged_requests)
    if (status /= 0) return
    staged_physics = state%ecmwf_physics
    status = initialize_operational_physics_controls(text, staged_physics, controls, staged_counts, staged_waves)
    if (status /= 0) return
    ! Every fallible reader has succeeded;the retained source stores cannot fail.
    call apply_remaining_physics_configuration(state)
    state%ecmwf_physics = staged_physics
    counts = staged_counts
    state%wave_coupling%lwcou = staged_waves(1) == 1_int32
    state%wave_coupling%lwcou2w = staged_waves(2) == 1_int32
    state%wave_coupling%lwcur = staged_waves(3) == 1_int32
    state%wave_coupling%lwcournw = staged_waves(4) == 1_int32
    state%wave_coupling%lwcouhmf = staged_waves(5) == 1_int32
    state%wave_coupling%lwstokes = staged_waves(6) == 1_int32
    state%wave_coupling%lwflux = staged_waves(7) == 1_int32
    state%wave_coupling%nstpw = staged_waves(8)
    requests = staged_requests
    status = 0_int32
  end function
end module forecast_operational_physics_configuration
