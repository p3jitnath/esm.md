!> Mixed-phase saturation diagnostic from the generated ordered calculation.
!! Inputs are temperature in K, trial humidity in kg/kg and pressure in Pa.
!! The return is trial humidity after two latent-heat feedback iterations.
!! Optional trace owns five values per iteration: temperature, humidity,
!! transferred water, saturation humidity and the feedback denominator.
!! The diagnostic does not replace the parent's actual phase or heat update.
module mixed_phase_saturation_mod
  use iso_fortran_env, only: real64, int32, int64
  use iso_c_binding, only: c_double
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use yomcst, only: retv, rtt
  use yoethf, only: r2es, r3les, r4les, r3ies, r4ies, rtwat, rtice, rtwat_rtice_r, &
                    r5alvcp, r5alscp, ralvdcp, ralsdcp
  implicit none
  private
  public :: qsatmixadj
  interface
    function scalar_exp(argument) bind(C, name="exp") result(value)
      import c_double
      real(c_double), value :: argument
      real(c_double) :: value
    end function scalar_exp
  end interface
contains
  !> Preserve the generated two-iteration calculation and intermediate rounding.
  function qsatmixadj(pt, pq, pp, trace) result(humidity)
    real(real64), intent(in) :: pt, pq, pp
    real(real64), optional, intent(out) :: trace(5, 2)
    real(real64) :: humidity, temperature, reciprocal_pressure
    real(real64) :: fraction, water_exp, ice_exp, argument, denominator
    real(real64) :: vapour_factor, correction, saturation, feedback, transfer_water
    real(real64) :: water_feedback, ice_feedback, temporary, heating
    integer(int32) :: iteration
    real(real64), volatile :: smallest_normal, half, subnormal
    type(ieee_round_type) :: rounding
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) call abort()
    smallest_normal = tiny(0.0_real64)
    half = 0.5_real64
    subnormal = smallest_normal*half
    if (transfer(subnormal, 0_int64) /= int(z'0008000000000000', int64)) call abort()
    temperature = pt
    humidity = pq
    reciprocal_pressure = 1.0_real64/pp
    do iteration = 1, 2
      fraction = min(rtwat, temperature)
      fraction = max(rtice, fraction)
      fraction = fraction - rtice
      fraction = fraction*rtwat_rtice_r
      fraction = fraction*fraction
      fraction = min(1.0_real64, fraction)
      argument = temperature - rtt
      argument = r3les*argument
      denominator = temperature - r4les
      argument = argument/denominator
      water_exp = scalar_exp(argument)
      argument = temperature - rtt
      argument = r3ies*argument
      denominator = temperature - r4ies
      argument = argument/denominator
      ice_exp = scalar_exp(argument)
      vapour_factor = fraction*water_exp
      temporary = 1.0_real64 - fraction
      temporary = temporary*ice_exp
      vapour_factor = vapour_factor + temporary
      vapour_factor = r2es*vapour_factor
      vapour_factor = vapour_factor*reciprocal_pressure
      vapour_factor = min(0.5_real64, vapour_factor)
      correction = retv*vapour_factor
      correction = 1.0_real64 - correction
      correction = 1.0_real64/correction
      saturation = vapour_factor*correction
      water_feedback = temperature - r4les
      water_feedback = water_feedback*water_feedback
      water_feedback = 1.0_real64/water_feedback
      temporary = fraction*r5alvcp
      water_feedback = temporary*water_feedback
      ice_feedback = temperature - r4ies
      ice_feedback = ice_feedback*ice_feedback
      ice_feedback = 1.0_real64/ice_feedback
      temporary = 1.0_real64 - fraction
      temporary = temporary*r5alscp
      ice_feedback = temporary*ice_feedback
      feedback = water_feedback + ice_feedback
      denominator = saturation*correction
      denominator = denominator*feedback
      denominator = 1.0_real64 + denominator
      transfer_water = humidity - saturation
      transfer_water = transfer_water/denominator
      heating = fraction*ralvdcp
      temporary = 1.0_real64 - fraction
      temporary = temporary*ralsdcp
      heating = heating + temporary
      heating = heating*transfer_water
      temperature = temperature + heating
      humidity = humidity - transfer_water
      if (present(trace)) trace(:, iteration) = [temperature, humidity, transfer_water, saturation, denominator]
    end do
  end function qsatmixadj
end module mixed_phase_saturation_mod
