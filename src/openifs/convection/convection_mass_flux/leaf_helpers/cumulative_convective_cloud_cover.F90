!> Complete exponential-random cloud-overlap accumulation.
module convection_cloud_cover_mod
  use iso_c_binding, only: c_double, c_int, c_int64_t
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use convection_leaf_contract_mod, only: require, real_matrix, real_vector
  use saturation_humidity_mod, only: numeric_maximum
  implicit none
  private
  public :: cum_cloud_cover_exp_ran, cum_cloud_cover_exp_ran_raw
  interface cum_cloud_cover_exp_ran_raw
    module procedure cum_cloud_cover_exp_ran
  end interface
contains
  !> Reuse the qualified default-beta sequence in a standalone native body.
  !! Providers are unconsumed. N positive levels have dimensionless cloud
  !! fractions. Overlap/pair have at least N-1 entries, cumulative N.
  !! Views are contiguous and separate. Optional USE_BETA retains its exact
  !! source conversion. Default-beta numerical evidence is reusable; the
  !! complete beta branch still requires its own independent byte gate.
  subroutine cum_cloud_cover_exp_ran(constants, thermal, n, fraction, overlap, cumulative, pair, use_beta)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    integer(c_int), intent(in) :: n
    real(c_double), intent(in) :: fraction(:), overlap(:)
    real(c_double), intent(inout) :: cumulative(:), pair(:)
    logical, intent(in), optional :: use_beta
    real(c_double) :: upper, lower, alpha, w0, w1, w2, w3, cover
    real(c_double), volatile :: clear
    integer(c_int) :: jk
    logical :: beta
    real(c_double), parameter :: covered = transfer(int(z'3fefffffffffffec', c_int64_t), 0.0_c_double)
    call require(n >= 1)
    call real_vector(fraction, n); call real_vector(cumulative, n)
    call real_vector(overlap, n - 1); call real_vector(pair, n - 1)
    upper = fraction(1)
    cumulative(1) = upper
    clear = 1.0_c_double - upper
    if (n == 1) return
    beta = .false.; if (present(use_beta)) beta = use_beta
    do jk = 1, n - 1
      lower = fraction(jk + 1); alpha = overlap(jk)
      if (beta) then
        if (alpha >= 1.0_c_double) then
          alpha = 1.0_c_double
        else
          w0 = upper - lower; w0 = abs(w0)
          w1 = 1.0_c_double - alpha; w1 = w1*w0
          w2 = 1.0_c_double/alpha; w2 = w0 + w2; w2 = w2 - 1.0_c_double
          w1 = w1/w2; alpha = alpha + w1
        end if
      end if
      w0 = numeric_maximum(upper, lower); w0 = alpha*w0
      w1 = 1.0_c_double - alpha
      w2 = upper + lower; w3 = upper*lower; w2 = w2 - w3
      w1 = w1*w2; cover = w0 + w1
      pair(jk) = cover
      if (upper >= covered) then
        clear = 0.0_c_double
      else
        w1 = 1.0_c_double - cover; clear = clear*w1
        w1 = 1.0_c_double - upper; clear = clear/w1
      end if
      cumulative(jk + 1) = 1.0_c_double - clear
      upper = lower
    end do
  end subroutine
end module
