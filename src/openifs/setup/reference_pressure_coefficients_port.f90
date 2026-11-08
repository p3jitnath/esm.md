!> Construct the reference atmosphere and its seven pressure-coefficient arrays.
!! The owned pressure child supplies every hydrostatic calculation.
module forecast_reference_pressure_coefficients
  use iso_c_binding, only: c_int, c_int64_t, c_double
  use iso_fortran_env, only: int32, real64
  use md2asm_hybrid_pressure_and_gradients, only: hybrid_pressure_controls, compute_hybrid_pressure
  implicit none
  private
  public :: reference_atmosphere_values, initialize_reference_atmosphere_values
  public :: initialize_reference_pressure_arrays
  !> Named scalar state from the selected SUDYN assignments.
  !! Pressures use Pa; temperatures use K; gas_temperature uses J kg**(-1).
  !! inverse_pressure uses inverse Pa; normalisation and integer flags are dimensionless.
  type, bind(C) :: reference_atmosphere_values
    real(c_double) :: pressure, temperature, auxiliary_temperature
    real(c_double) :: gas_temperature, inverse_pressure, normalisation
    integer(c_int) :: temperature_option, stretched_grid, limited_area
  end type
contains
  !> Preserve finite-word classification without raising floating-point flags.
  logical function finite_word(x)
    real(c_double), intent(in) :: x
    integer(c_int64_t) :: bits
    bits = transfer(x, bits)
    finite_word = ibits(bits, 52, 11) /= 2047
  end function

  !> Select the reference temperature and compute the source scalar coefficients.
  !! half_a_first is A at level1 in Pa; finite_elements is canonical0 or1.
  !! stretch is the positive dimensionless grid stretch and dry_gas_constant
  !! is positive J kg**(-1) K**(-1). The parent admits NCONF1, positive NSTOP,
  !! LECMWF, hydrostatic two-time-level dynamics and a global domain.
  !! state owns the named scalar fields; its C padding remains unchanged.
  !! Return2 preserves state; return0 writes all named fields.
  integer(c_int) function initialize_reference_atmosphere_values(half_a_first, finite_elements, &
                                                                 stretch, dry_gas_constant, state) &
    bind(C, name="md2asm_initialize_reference_atmosphere_values_fortran") result(status)
    real(c_double), value, intent(in) :: half_a_first, stretch, dry_gas_constant
    integer(c_int), value, intent(in) :: finite_elements
    type(reference_atmosphere_values), intent(inout) :: state
    real(c_double) :: top_choice, temperature, temporary, threshold
    integer(c_int) :: stretched
    status = 2
    if (finite_elements /= 0 .and. finite_elements /= 1) return
    if (.not. finite_word(half_a_first)) return
    if (btest(transfer(half_a_first, 0_c_int64_t), 63)) return
    if (.not. finite_word(stretch) .or. .not. finite_word(dry_gas_constant)) return
    if (half_a_first < 0.0_c_double .or. stretch <= 0.0_c_double .or. dry_gas_constant <= 0.0_c_double) return
    top_choice = half_a_first*0.5_c_double
    temperature = 300.0_c_double
    if (top_choice < 100.0_c_double .or. finite_elements == 1) temperature = 350.0_c_double
    temporary = stretch - 1.0_c_double
    temporary = abs(temporary)
    threshold = transfer(int(z'0079000000000000', c_int64_t), threshold)
    stretched = 0
    if (temporary > threshold) stretched = 1
    state%pressure = 100000.0_c_double
    state%temperature = temperature
    state%auxiliary_temperature = temperature
    state%temperature_option = 0
    state%gas_temperature = dry_gas_constant*temperature
    state%inverse_pressure = 1.0_c_double/state%pressure
    state%normalisation = 0.04_c_double
    state%stretched_grid = stretched
    state%limited_area = 0
    status = 0
  end function

  !> Fill the seven reference-pressure owners after accepted native GPHPRE.
  !! n is1..255. Hybrid A/C/delta_a/full_a use Pa, B/delta_b/full_b are
  !! dimensionless. Half arrays have bounds0:n; other inputs have bounds1:n.
  !! source_controls names the selected public child controls and scalar state.
  !! Outputs alpha,log_pressure use dimensionless units, delta_pressure uses Pa,
  !! inverse_delta uses inverse Pa, half_pressure/full_pressure use Pa and
  !! geopotential uses m**2 s**(-2). All buffers are caller-owned and disjoint.
  !! The parent owns allocation. Child failure returns before output publication.
  subroutine initialize_reference_pressure_arrays(n, pressure_controls, state, half_a, half_b, &
                                                  vc, full_a, full_b, delta_a, delta_b, alpha, log_pressure, delta_pressure, &
                                                  inverse_delta, &
                                                  half_pressure, full_pressure, geopotential, status)
    integer(int32), intent(in) :: n
    type(hybrid_pressure_controls), intent(in) :: pressure_controls
    type(reference_atmosphere_values), intent(in) :: state
    real(real64), intent(in) :: half_a(0:n), half_b(0:n)
    real(real64), intent(in) :: vc(1:n), full_a(1:n), full_b(1:n), delta_a(1:n), delta_b(1:n)
    real(real64), intent(inout) :: alpha(n), log_pressure(n), delta_pressure(n), inverse_delta(n)
    real(real64), intent(inout) :: half_pressure(0:n), full_pressure(n), geopotential(n)
    integer(int32), intent(out) :: status
    real(real64) :: child_half(1, 0:255), child_full(1, 255), coefficients(1, 255, 7)
    real(real64) :: padded_vc(0:255), padded_a(0:255), padded_b(0:255), padded_da(0:255), padded_db(0:255)
    real(real64) :: temporary
    integer(int32), parameter :: indices(7) = [1, 2, 3, 4, 5, 6, 7]
    integer :: j
    status = 2
    if (n < 1 .or. n > 255) return
    if (.not. finite_word(state%pressure) .or. .not. finite_word(state%temperature)) return
    if (.not. finite_word(pressure_controls%dry_gas_constant)) return
    if (state%pressure <= 0.0_real64 .or. state%temperature <= 0.0_real64) return
    if (pressure_controls%dry_gas_constant <= 0.0_real64) return
    padded_vc(0) = 0.0_real64
    padded_a(0) = 0.0_real64
    padded_b(0) = 0.0_real64
    padded_da(0) = 0.0_real64
    padded_db(0) = 0.0_real64
    do j = 1, n
      padded_vc(j) = vc(j)
      padded_a(j) = full_a(j)
      padded_b(j) = full_b(j)
      padded_da(j) = delta_a(j)
      padded_db(j) = delta_b(j)
    end do
    child_half(1, n) = state%pressure
    call compute_hybrid_pressure(pressure_controls, 1_int32, 1_int32, 1_int32, n, half_a, half_b, &
                                 child_half(:, 0:n), status, 7_int32, indices, padded_vc, padded_a, padded_b, padded_da, &
                                 padded_db, &
                                 coefficients(:, 1:n, :), child_full(:, 1:n))
    if (status /= 0) return
    do j = 1, n
      delta_pressure(j) = coefficients(1, j, 1)
      inverse_delta(j) = coefficients(1, j, 2)
      log_pressure(j) = coefficients(1, j, 3)
      alpha(j) = coefficients(1, j, 4)
      half_pressure(j) = child_half(1, j)
    end do
    do j = 1, n
      full_pressure(j) = coefficients(1, j, 1)/coefficients(1, j, 3)
      temporary = pressure_controls%dry_gas_constant*state%temperature
      geopotential(j) = temporary*coefficients(1, j, 3)
    end do
    half_pressure(0) = child_half(1, 0)
    status = 0
  end subroutine
end module forecast_reference_pressure_coefficients
