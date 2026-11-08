!> Preserve the source's empty-work setup before the complete QM3D child.
module forecast_empty_work_vertical_interpolation
  use iso_fortran_env, only: int32, real64
  use md2asm_bounded_three_dimensional_transport, only: interpolate_bounded_thirty_two_neighbours
  implicit none
  private
  public :: interpolate_bounded_fields_with_empty_vertical_setup
contains
  !> EMPTY_VERTICAL_TRIGGER is the explicit original second scalar input word.
 !! Its association to a higher owner remains caller-owned and is not inferred
 !! from SOURCE_PITCH or VERTICAL_CONSERVATION. The half-coordinate is
 !! dimensionless, indexed0:LEVELS. Fractions are dimensionless; outputs retain
 !! FIELD units. Read-only shape and all child bounds remain explicit.
  subroutine interpolate_bounded_fields_with_empty_vertical_setup(empty_vertical_trigger, source_pitch, pitch, first, last, &
                      levels, first_plane, last_plane, limiter, vertical_conservation, latitude, latitude_coefficients, longitude, &
            longitude_coefficients, indices, vertical_coefficients, field, result, status, vertical_fraction, half_level_coordinate)
    integer(int32), intent(in) :: empty_vertical_trigger, source_pitch, pitch, first, last, levels, first_plane, last_plane, limiter
    logical, intent(in) :: vertical_conservation
    real(real64), intent(in) :: latitude(:, :), latitude_coefficients(:, :, :), longitude(:, :, 0:)
    real(real64), intent(in) :: longitude_coefficients(:, :, :, :), vertical_coefficients(:, :, :), field(:)
    integer(int32), intent(in) :: indices(:, :, 0:)
    real(real64), intent(inout) :: result(:, :)
    integer(int32), intent(out) :: status
    real(real64), intent(in), optional :: vertical_fraction(:, :), half_level_coordinate(0:)
    real(real64) :: next_depth, previous_depth
    real(real64), volatile :: ratio
    integer :: level
    status = 2
    if (first > last .and. levels >= 2 .and. empty_vertical_trigger /= 0 .and. limiter == 2) then
      if (levels > 512) return
      if (.not. present(half_level_coordinate)) return
      if (ubound(half_level_coordinate, 1) < levels) return
      do level = 2, levels
        next_depth = half_level_coordinate(level) - half_level_coordinate(level - 1)
        previous_depth = half_level_coordinate(level - 1) - half_level_coordinate(level - 2)
        ratio = next_depth/previous_depth
      end do
    end if
    call interpolate_bounded_thirty_two_neighbours(source_pitch, pitch, first, last, levels, first_plane, last_plane, &
                      limiter, vertical_conservation, latitude, latitude_coefficients, longitude, longitude_coefficients, indices, &
                                             vertical_coefficients, field, result, status, vertical_fraction, half_level_coordinate)
  end subroutine
end module forecast_empty_work_vertical_interpolation
