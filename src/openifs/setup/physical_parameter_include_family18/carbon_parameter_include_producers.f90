!> Reuse complete native parameter producers for the assigned source includes.
!! Each entry keeps the canonical record types, argument intent and shapes.
!! Pressure is Pa, lengths are metres, temperature is K and time is seconds;
!! switches, counts and other scale factors are dimensionless. Natural
!! child status and arithmetic remain visible. No record or payload is copied.
module forecast_include_carbon_parameters
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use yos_veg, only: TVEG
  use yos_cst, only: TCST
  use yos_ags, only: TAGS
  use photosynthesis_parameter_numerics
  use sucotwo_mod, only: source_sucotwo => sucotwo
  implicit none
  private
  public :: forward_sucotwo
contains
  !> Forward the complete source producer over its actual caller-owned records.
 !! Raw field entries require the same already-admitted domain as their child.
  subroutine forward_sucotwo(PRVR0VT, YDVEG, YDCST, YDAGS)
    real(real64), intent(in) :: PRVR0VT(:, :)
    type(TVEG), intent(in) :: YDVEG
    type(TCST), intent(in) :: YDCST
    type(TAGS), intent(inout) :: YDAGS
    call source_sucotwo(PRVR0VT, YDVEG, YDCST, YDAGS)
  end subroutine
end module
