!> Derive the spherical transport halo from its actual native producers.
module forecast_spherical_interpolation_halo
  use iso_fortran_env, only: int32, int64, real64
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_controls_state_types, only: native_forecast_controls_state, native_forecast_control_namespace
  use forecast_operational_dynamics, only: native_dynamics_controls
  use forecast_semi_lagrangian_buffer_types, only: native_interpolation_controls
  use physical_constant_setup_port, only: forecast_physical_constants
  use forecast_interpolation_state_types, only: native_interpolation_state
  implicit none
  private
  public :: initialize_native_spherical_interpolation_halo, initialize_native_selected_spherical_halo_controls
contains
  !> Produce the historical selected SUMP0 default after NAMPAR1 admission.
  !! NAMESPACE is the source-owned SUCT0 record. LELAM and LSLONDEM are the
  !! caller's two scalar output fields. The admitted selected first NAMPAR1
  !! has no LSLONDEM override. The operational policy reader is separate and
  !! can override the default before the numerical halo function is called.
  !! Status2 preserves both outputs. Status0 writes LELAM=0, LSLONDEM=true.
  integer(int32) function initialize_native_selected_spherical_halo_controls(namespace, lelam, lslondem) result(status)
    type(native_forecast_control_namespace), intent(in) :: namespace
    integer(int32), intent(inout) :: lelam
    logical, intent(inout) :: lslondem
    status = 2
    if (namespace%lelam /= 0) return
    lelam = namespace%lelam
    lslondem = .true.
    status = 0
  end function

  !> Run the generated spherical SUSC2B calculation and commit its five fields.
  !! GEOMETRY supplies global latitude count, boundary rows and grid stretch.
  !! FORECAST supplies the accepted time step in seconds and global-grid flag.
  !! CONSTANTS supplies Earth radius in metres and pi. CONTROLS holds the two
  !! speed limits in metres per second and is changed only after admission.
  !! DYNAMICS supplies the two source transport switches. LSLONDEM is the
  !! actual first-NAMPAR1 result of the parallel-control producer.
  !! STATE owns the source SL_STRUCT; only CVER, LSLONDEM and NSLWIDE change.
  !! Inputs and outputs must be disjoint. Counts are NDGLG=2:65536 and
  !! NDGSUR=1:1024. Radius, pi, stretch and speeds must be positive and finite.
  !! The time step is finite and nonnegative, with either signed zero allowed.
  !! The caller supplies nearest-even rounding and gradual underflow.
  !! Status 0 commits; status 2 preserves both output records. There is no
  !! allocation or I/O. The source numerical status is retained naturally.
  !! The separate component reference omits the informational source WRITE.
  integer(int32) function initialize_native_spherical_interpolation_halo(geometry, forecast, dynamics, &
                                                                         controls, constants, lslondem, state) result(status)
    type(native_geometry_state), intent(in) :: geometry
    type(native_forecast_controls_state), intent(in) :: forecast
    type(native_dynamics_controls), intent(in) :: dynamics
    type(native_interpolation_controls), intent(inout) :: controls
    type(forecast_physical_constants), intent(in) :: constants
    logical, intent(in) :: lslondem
    type(native_interpolation_state), intent(inout) :: state
    integer(int32) :: n, boundary, rows, width, on_demand
    integer(int64) :: step_word
    real(real64) :: step, stretch, angle, half_pi, latitude_count, row_estimate
    real(real64) :: new_vmax1, new_vmax2, numerator, denominator
    ! VOLATILE preserves the source's unconditional rounded calculations
    ! before its zero-time-step branch, including their floating flags.
    real(real64), volatile :: speed_ratio, covered_angle
    status = 2
    if (forecast%namespace%lelam /= 0) return
    if (transfer(dynamics%lslag, 0_int32) /= 1) return
    if (transfer(dynamics%ltwotl, 0_int32) /= 1) return
    on_demand = transfer(lslondem, 0_int32)
    if (on_demand < 0 .or. on_demand > 1) return
    n = geometry%dimensions%ndglg
    boundary = geometry%dimensions%ndgsur
    if (n < 2 .or. n > 65536 .or. boundary < 1 .or. boundary > 1024) return
    if (.not. positive_finite(constants%ra)) return
    if (.not. positive_finite(constants%rpi)) return
    stretch = geometry%configuration%values%rstret
    if (.not. positive_finite(stretch)) return
    if (.not. positive_finite(controls%vmax1)) return
    if (.not. positive_finite(controls%vmax2)) return
    step = forecast%clock%dt
    step_word = transfer(step, 0_int64)
    if (iand(step_word, int(z'7fffffffffffffff', int64)) /= 0_int64) then
      if (step_word < 0_int64) return
      if (ibits(step_word, 52, 11) == 2047_int64) return
    end if

    ! Each statement is one source FP64 rounding point.
    angle = 1.0_real64*controls%vmax2
    angle = angle*step
    angle = angle*stretch
    angle = angle/constants%ra
    half_pi = 0.5_real64*constants%rpi
    if (angle > half_pi) return
    latitude_count = real(n, real64) + 0.5_real64
    row_estimate = angle*latitude_count
    row_estimate = row_estimate/constants%rpi
    rows = ceiling(row_estimate, int32)
    speed_ratio = controls%vmax1/controls%vmax2
    covered_angle = real(rows, real64)*constants%rpi
    covered_angle = covered_angle/latitude_count
    new_vmax1 = controls%vmax1
    new_vmax2 = controls%vmax2
    if (step /= 0.0_real64) then
      numerator = covered_angle*constants%ra
      denominator = 1.0_real64*step
      denominator = denominator*stretch
      new_vmax2 = numerator/denominator
      new_vmax1 = speed_ratio*new_vmax2
      new_vmax1 = min(new_vmax1, 250.0_real64)
    end if
    width = rows + boundary
    width = width - 1
    if (step /= 0.0_real64) then
      controls%vmax2 = new_vmax2
      controls%vmax1 = new_vmax1
    end if
    state%nslwide = width
    state%lslondem = lslondem
    state%cver = 'SL'
    status = 0
  end function

  !> Inspect the FP64 exponent and sign without changing floating status.
  pure logical function positive_finite(value) result(admitted)
    real(real64), intent(in) :: value
    integer(int64) :: word
    word = transfer(value, 0_int64)
    admitted = word > 0_int64 .and. ibits(word, 52, 11) /= 2047_int64
  end function
end module forecast_spherical_interpolation_halo
