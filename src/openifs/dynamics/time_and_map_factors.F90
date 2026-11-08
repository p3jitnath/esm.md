!> Complete LASURE scalar and grid-map factors from the generated source.
!! Fields use FP64 and named controls; native optional map arrays replace private
!! descriptors. The caller retains every inactive output column.
module md2asm_time_and_map_factors
  use iso_fortran_env, only: int32, real64
  use, intrinsic :: ieee_arithmetic, only: ieee_is_finite
  implicit none
  private
  public :: time_map_controls, form_time_and_map_factors
  !> Configuration values are dimensionless; only a consumed stretch is read.
  type :: time_map_controls
    logical :: implicit_map = .false., extended_map = .false.
    logical :: two_level_first_force = .false., model_physics = .false.
    logical :: external_physics = .false., lagged_physics = .false.
    real(real64) :: off_centering = 0.0_real64, stretch = 1.0_real64
  end type
contains
  !> Form the seven complete returned scalar and column owners.
  !! time_step and half_time_step are in seconds; beta_time is dimensionless.
  !! weighted_half_time_step and map_time_factor are in seconds.
  !! plus_factor,minus_factor,map_multiplier and all map inputs are dimensionless.
  !! pitch is 0:4096; first:last is inclusive and may be empty.
  !! gm and extended_multiplier are consumed only by their selected map branch.
  !! Inputs and outputs are disjoint. Status2 rejects an owner or input condition
  !! before any output change; status0 completes the selected ordered update.
  !! The caller admits finite intermediate products and positive finite gm**2.
  subroutine form_time_and_map_factors(pitch, first, last, beta_time, time_step, c, &
                                       half_time_step, weighted_half_time_step, two_level_force, map_time_factor, &
                                       map_multiplier, plus_factor, minus_factor, status, gm, extended_multiplier)
    integer(int32), intent(in) :: pitch, first, last
    real(real64), intent(in) :: beta_time, time_step
    type(time_map_controls), intent(in) :: c
    real(real64), intent(inout) :: half_time_step, weighted_half_time_step
    logical, intent(inout) :: two_level_force
    real(real64), intent(inout) :: map_time_factor(:), map_multiplier(:)
    real(real64), intent(inout) :: plus_factor, minus_factor
    integer(int32), intent(out) :: status
    real(real64), optional, intent(in) :: gm(:), extended_multiplier(:)
    real(real64) :: half, weighted, denominator, numerator, stretch_square
    integer :: i
    status = 2
    if (pitch < 0 .or. pitch > 4096) return
    if (first < 1 .or. first > pitch + 1 .or. last < 0 .or. last > pitch) return
    if (size(map_time_factor) < pitch .or. size(map_multiplier) < pitch) return
    if (.not. ieee_is_finite(beta_time) .or. .not. ieee_is_finite(time_step)) return
    if (beta_time < 0.0_real64 .or. time_step < 0.0_real64) return
    if (.not. ieee_is_finite(c%off_centering)) return
    if (c%off_centering < -1.0_real64 .or. c%off_centering > 1.0_real64) return
    if (first <= last .and. .not. c%implicit_map) then
      if (.not. present(gm)) return
      if (size(gm) < last) return
      do i = first, last
        if (.not. ieee_is_finite(gm(i))) return
        if (gm(i) <= 0.0_real64) return
      end do
      if (c%extended_map) then
        if (.not. present(extended_multiplier)) return
        if (size(extended_multiplier) < last) return
        do i = first, last
          if (.not. ieee_is_finite(extended_multiplier(i))) return
          if (extended_multiplier(i) <= 0.0_real64) return
        end do
      else
        if (.not. ieee_is_finite(c%stretch)) return
        if (c%stretch <= 0.0_real64) return
      end if
    end if
    half = 0.5_real64*time_step
    weighted = half*beta_time
    half_time_step = half
    weighted_half_time_step = weighted
    plus_factor = 1.0_real64 + c%off_centering
    minus_factor = 1.0_real64 - c%off_centering
    two_level_force = c%two_level_first_force .and. (c%model_physics .or. c%external_physics) .and. .not. c%lagged_physics
    if (first > last) then
      status = 0
      return
    end if
    if (c%implicit_map) then
      do i = first, last
        map_time_factor(i) = weighted
        map_multiplier(i) = 1.0_real64
      end do
    else if (c%extended_map) then
      do i = first, last
        denominator = gm(i)*gm(i)
        numerator = weighted*extended_multiplier(i)
        map_time_factor(i) = numerator/denominator
        map_multiplier(i) = extended_multiplier(i)/denominator
      end do
    else
      numerator = weighted*c%stretch
      numerator = numerator*c%stretch
      stretch_square = c%stretch*c%stretch
      do i = first, last
        denominator = gm(i)*gm(i)
        map_time_factor(i) = numerator/denominator
        map_multiplier(i) = stretch_square/denominator
      end do
    end if
    status = 0
  end subroutine
end module
