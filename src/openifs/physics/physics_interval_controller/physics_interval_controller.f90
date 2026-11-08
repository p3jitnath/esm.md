!> Select the physics interval, then apply the saved physical rates.
!! Wind is in m s**(-1), temperature is in K and tracer units follow each field.
!! Intervals are in seconds. The caller owns every state and rate array.
module forecast_physics_interval_controller
  use iso_fortran_env, only: int32, int64, real64
  use yomphy2, only: tphy2
  use forecast_physics_tendency_increment, only: saved_physics_tendency_indices, &
                                                 physical_tracer_increment_map, add_physics_tendencies
  implicit none
  private
  public :: apply_lagged_physics_increment
contains
  !> Preserve the complete EC_PHYS_LSLPHY interval decision and child call.
  !!
  !! Parameters
  !! ----------
  !! first_step : logical, input
  !!     True on the first transport step. The interval decision still occurs.
  !! pitch, levels, lower_level, upper_level : integer(int32), input
  !!     Live columns, active layers and inclusive stored vertical bounds.
  !! first, last : integer(int32), input
  !!     Inclusive active columns. last=first-1 represents an empty interval.
  !! model_interval, requested_interval : real(real64), input
  !!     Actual model interval and requested physics interval, in seconds.
  !! physics_time : type(TPHY2), input/output
  !!     The one canonical physics-time record. Only TSPHY may change here.
  !! indices : type(saved_physics_tendency_indices), input
  !!     Named saved-rate indices for the two winds and temperature.
  !! components : type(physical_tracer_increment_map)(:), input
  !!     Source-ordered tracer controls; repeated destination indices are valid.
  !! saved, tracer_rates : real(real64)(pitch,levels,fields), input
  !!     Saved wind/temperature and tracer rates per second, in separate owners.
  !! u, v, temperature : real(real64)(pitch,lower_level:upper_level), input/output
  !!     Complete borrowed wind and temperature owners, including inactive cells.
  !! tracers : real(real64)(pitch,lower_level:upper_level,fields), input/output
  !!     Complete borrowed tracer owner. Only selected mapped cells may change.
  !!
  !! Returns
  !! -------
  !! status : integer(int32)
  !!     Zero succeeds. Two refuses unsupported metadata or child arguments.
  !!
  !! Notes
  !! -----
  !! The caller qualifies round-to-nearest, gradual underflow and the exact
  !! machine-control precondition once before entry. Source first-step and
  !! empty-array behavior is delegated to the complete own numerical child.
  !! There is no allocation, original numerical routine or original global.
  !! Finite checks use integer bits before ordered floating-point comparisons.
  !! A child refusal can follow the source-defined TSPHY update.
  integer(int32) function apply_lagged_physics_increment(first_step, pitch, levels, &
                                                        lower_level, upper_level, first, last, model_interval, requested_interval, &
                                  physics_time, indices, components, saved, tracer_rates, u, v, temperature, tracers) result(status)
    logical, intent(in) :: first_step
    integer(int32), intent(in) :: pitch, levels, lower_level, upper_level, first, last
    real(real64), intent(in) :: model_interval, requested_interval
    type(tphy2), intent(inout) :: physics_time
    type(saved_physics_tendency_indices), intent(in) :: indices
    type(physical_tracer_increment_map), intent(in) :: components(:)
    real(real64), intent(in), optional :: saved(:, :, :), tracer_rates(:, :, :)
    real(real64), intent(inout), optional :: u(:, lower_level:), v(:, lower_level:), temperature(:, lower_level:)
    real(real64), intent(inout), optional :: tracers(:, lower_level:, :)
    integer(int64) :: stored_levels
    status = 2
    if (pitch < 1 .or. pitch > 4096) return
    if (levels < 0 .or. levels > 512) return
    if (lower_level > 1 .or. upper_level < levels) return
    stored_levels = int(upper_level, int64) - int(lower_level, int64) + 1_int64
    if (stored_levels < 1_int64 .or. stored_levels > 1024_int64) return
    if (first < 1 .or. first > pitch + 1) return
    if (last > pitch .or. last < first - 1) return
    if (.not. finite_word(requested_interval)) return
    if (.not. finite_word(model_interval)) return
    if (.not. finite_word(physics_time%tsphy)) return
    if (requested_interval < 0.0_real64) return
    if (model_interval < 0.0_real64) return
    if (physics_time%tsphy < 0.0_real64) return
    if (requested_interval /= model_interval) then
      if (requested_interval >= 1.0_real64) then
        physics_time%tsphy = requested_interval
      else
        physics_time%tsphy = 1.0_real64
      end if
    end if
    status = add_physics_tendencies(first_step, pitch, first, last, levels, lower_level, &
                                    physics_time%tsphy, indices, components, saved, tracer_rates, u, v, temperature, tracers)
  end function

  !> Test the exponent bits without changing floating-point exception flags.
  logical function finite_word(value)
    real(real64), intent(in) :: value
    integer(int64) :: bits
    bits = transfer(value, 0_int64)
    finite_word = iand(ishft(bits, -52), 2047_int64) /= 2047_int64
  end function
end module forecast_physics_interval_controller
