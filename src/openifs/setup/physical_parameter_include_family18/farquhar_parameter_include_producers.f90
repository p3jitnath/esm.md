!> Reuse complete native parameter producers for the assigned source includes.
!! Each entry keeps the canonical record types, argument intent and shapes.
!! Pressure is Pa, lengths are metres, temperature is K and time is seconds;
!! switches, counts and other scale factors are dimensionless. Natural
!! child status and arithmetic remain visible. No record or payload is copied.
module forecast_include_farquhar_parameters
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use yos_veg, only: TVEG
  use yos_ags, only: TAGS
  use yos_agf, only: TAGF
  use sufarquhar_mod, only: source_sufarquhar => sufarquhar
  implicit none
  private
  public :: forward_sufarquhar
contains
  !> Forward the complete source producer over its actual caller-owned records.
 !! Raw field entries require the same already-admitted domain as their child.
  subroutine forward_sufarquhar(PRVCMAX25, PRHUMREL, PRA1, PRB1, PRG0, PRGM25, PRE_VCMAX, PRE_JMAX, YDVEG, YDAGS, YDAGF)
    real(real64), intent(in) :: PRVCMAX25(:, :), PRHUMREL(:, :), PRA1(:, :), PRB1(:, :)
    real(real64), intent(in) :: PRG0(:, :), PRGM25(:, :), PRE_VCMAX(:, :), PRE_JMAX(:, :)
    type(TVEG), intent(in) :: YDVEG
    type(TAGS), intent(in) :: YDAGS
    type(TAGF), intent(inout) :: YDAGF
    call source_sufarquhar(PRVCMAX25, PRHUMREL, PRA1, PRB1, PRG0, PRGM25, PRE_VCMAX, PRE_JMAX, YDVEG, YDAGS, YDAGF)
  end subroutine
end module
