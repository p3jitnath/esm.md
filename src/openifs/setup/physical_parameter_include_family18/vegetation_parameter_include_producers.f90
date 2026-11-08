!> Reuse complete native parameter producers for the assigned source includes.
!! Each entry keeps the canonical record types, argument intent and shapes.
!! Pressure is Pa, lengths are metres, temperature is K and time is seconds;
!! switches, counts and other scale factors are dimensionless. Natural
!! child status and arithmetic remain visible. No record or payload is copied.
module forecast_include_vegetation_parameters
  use iso_fortran_env, only: int32, int64, real64
  use yos_dim, only: tdim
  use yos_cst, only: tcst
  use yos_soil, only: tsoil
  use yos_veg, only: tveg
  use srfrootfr_mod, only: srfrootfr
  use susveg_mod, only: source_susveg => susveg
  implicit none
  private
  public :: forward_susveg
contains
  !> Forward the complete source producer over its actual caller-owned records.
 !! Raw field entries require the same already-admitted domain as their child.
 subroutine forward_susveg(ld_lelaiv, ld_lectessel, ld_leags, ld_lefarquhar, ld_leairco2coup, prlaiint, yddim, ydcst, ydsoil, ydveg)
    logical(int32), intent(in) :: ld_lelaiv, ld_lectessel, ld_leags, ld_lefarquhar, ld_leairco2coup
    real(real64), intent(in) :: prlaiint
    type(tdim), intent(in) :: yddim
    type(tcst), intent(in) :: ydcst
    type(tsoil), intent(in) :: ydsoil
    type(tveg), intent(inout) :: ydveg
    call source_susveg(ld_lelaiv, ld_lectessel, ld_leags, ld_lefarquhar, ld_leairco2coup, prlaiint, yddim, ydcst, ydsoil, ydveg)
  end subroutine
end module
