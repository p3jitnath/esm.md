!> Compute the source Sun-Earth distance, declination and clock correction.
!! Seconds are measured from the source epoch. Outputs are metres, radians and seconds.
!! Each intermediate uses FP64 with the source operation order. The caller establishes
!! nearest rounding and gradual underflow. Only OUTPUT(1:3) changes on success.
module forecast_orbital_illumination
  use iso_fortran_env, only: int32, int64, real64
  use forecast_source_rounding_trigonometry, only: original_rounding_sine, original_rounding_cosine
  use forecast_source_rounding_inverse_trigonometry, only: original_rounding_asine
  use physical_constant_setup_port, only: forecast_physical_constants
  implicit none
  private
  public :: calculate_orbital_illumination, calculate_runtime_orbital_illumination
contains
!> Retain the selected source interval, zero to ten Julian years in seconds.
  integer(int32) function calculate_orbital_illumination(seconds, output) result(status)
    real(real64), intent(in) :: seconds
    real(real64), intent(inout) :: output(3)
    status = 2
    if (.not. finite_nonnegative(seconds, 315576000.0_real64)) return
    call orbital_values(seconds, 86400.0_real64, 149597870000.0_real64, 0.409093_real64, output)
    status = 0
  end function
!> Use the same equations with the actual physical record and a bounded runtime epoch.
!! RDAY is seconds/day, REA is metres and REPSM is radians. This route admits up to
!! one thousand Julian years; its angles remain within the shared trigonometric bounds.
!! This larger input domain is source-ready and has no new numerical qualification.
  integer(int32) function calculate_runtime_orbital_illumination(seconds, constants, output) result(status)
    real(real64), intent(in) :: seconds
    type(forecast_physical_constants), intent(in) :: constants
    real(real64), intent(inout) :: output(3)
    status = 2
    if (.not. finite_nonnegative(seconds, 31557600000.0_real64)) return
    if (constants%rday /= 86400.0_real64 .or. constants%rea /= 149597870000.0_real64 .or. constants%repsm /= 0.409093_real64) return
    call orbital_values(seconds, constants%rday, constants%rea, constants%repsm, output)
    status = 0
  end function
  logical function finite_nonnegative(value, maximum) result(ok)
    real(real64), intent(in) :: value, maximum
    integer(int64) :: bits
    bits = iand(transfer(value, 0_int64), int(z'7fffffffffffffff', int64))
    ok = .false.
    if (bits >= int(z'7ff0000000000000', int64)) return
    if (value < 0.0_real64 .or. value > maximum) return
    ok = .true.
  end function
  recursive subroutine orbital_values(seconds, day_seconds, earth_distance, obliquity, output)
    real(real64), intent(in) :: seconds, day_seconds, earth_distance, obliquity
    real(real64), intent(inout) :: output(3)
    real(real64), volatile :: year, anomaly, mean, longitude, s, c, phase, t, u, v, clock, tilt
    t = day_seconds*365.25_real64; year = seconds/t
    t = 6.283076_real64*year; anomaly = 1.7535_real64 + t
    t = 6.283020_real64*year; mean = 6.240075_real64 + t
    t = 6.283076_real64*year; longitude = 4.8951_real64 + t
    s = original_rounding_sine(anomaly); c = original_rounding_cosine(anomaly)
    t = 0.0163_real64*s; t = 1.0001_real64 - t
    u = 0.0037_real64*c; t = t + u; t = earth_distance*t; output(1) = t
    t = 6.283320_real64*year; phase = 4.8952_real64 + t
    t = 0.0075_real64*s; phase = phase - t
    t = 0.0326_real64*c; phase = phase - t
    t = 2.0_real64*anomaly; t = original_rounding_sine(t)
    t = 0.0003_real64*t; phase = phase - t
    t = 2.0_real64*anomaly; t = original_rounding_cosine(t)
    t = 0.0002_real64*t; phase = phase + t
    tilt = original_rounding_sine(obliquity)
    t = original_rounding_sine(phase); t = tilt*t
    output(2) = original_rounding_asine(t)
    t = 2.0_real64*longitude; t = original_rounding_sine(t)
    clock = 591.8_real64*t
    v = original_rounding_sine(mean); t = 459.4_real64*v; clock = clock - t
    t = 2.0_real64*longitude; t = original_rounding_cosine(t)
    u = 39.5_real64*v; u = u*t; clock = clock + u
    t = 4.0_real64*longitude; t = original_rounding_sine(t)
    t = 12.7_real64*t; clock = clock - t
    t = 2.0_real64*mean; t = original_rounding_sine(t)
    t = 4.8_real64*t; clock = clock - t
    output(3) = clock
  end subroutine
end module
