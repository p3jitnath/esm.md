!> Source launch scaling from the actual horizontal cell area.
module md2asm_wave_launch_grid
  use iso_fortran_env, only: int64, real64
  use iso_c_binding, only: c_double
  implicit none
  private
  public :: wave_launch_grid_factor
  interface
    function public_atan(x) bind(C, name="atan") result(y)
      import :: c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
  end interface
contains
!> Return the dimensionless launch factor for one positive area weight.
!! AREA_WEIGHT is the fractional cell-area weight; PI is dimensionless and
!! PLANET_RADIUS is metres. The caller supplies positive finite inputs and
!! nearest-even FP64 with gradual underflow. Each named operation rounds.
!! Public ATAN retains the selected system mathematical-service identity;
!! independent byte qualification of this newly consumed domain is pending.
  function wave_launch_grid_factor(area_weight, pi, planet_radius) result(factor)
    real(real64), intent(in) :: area_weight, pi, planet_radius
    real(real64) :: factor, diameter, spacing, inverse_spacing, coordinate, angle
    real(real64), parameter :: inverse_coarse = transfer(int(z'3F021432907D6C1F', int64), 0.0_real64)
    real(real64), parameter :: inverse_interval = transfer(int(z'3F3076F7314DA70A', int64), 0.0_real64)
    diameter = 2.0_real64*planet_radius
    spacing = pi*area_weight; spacing = sqrt(spacing); spacing = diameter*spacing
    spacing = max(spacing, 100.0_real64)
    inverse_spacing = 1.0_real64/spacing; inverse_spacing = max(inverse_spacing, inverse_coarse)
    coordinate = inverse_spacing - inverse_coarse; coordinate = coordinate/inverse_interval
    angle = public_atan(coordinate); angle = min(1.0_real64, angle)
    factor = 1.0_real64 - angle
  end function
end module
