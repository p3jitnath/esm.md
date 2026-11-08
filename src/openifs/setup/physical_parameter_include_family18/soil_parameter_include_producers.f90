!> Reuse complete native parameter producers for the assigned source includes.
!! Each entry keeps the canonical record types, argument intent and shapes.
!! Pressure is Pa, lengths are metres, temperature is K and time is seconds;
!! switches, counts and other scale factors are dimensionless. Natural
!! child status and arithmetic remain visible. No record or payload is copied.
module forecast_include_soil_parameters
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double
  use ieee_arithmetic, only: ieee_get_rounding_mode, ieee_round_type, ieee_nearest, operator(/=)
  use yos_dim, only: tdim
  use yos_cst, only: tcst
  use yos_soil, only: tsoil
  use cptave_mod, only: cptave
  use sussoil_mod, only: source_sussoil => sussoil
  implicit none
  private
  public :: forward_sussoil
contains
  !> Forward the complete source producer over its actual caller-owned records.
 !! Raw field entries require the same already-admitted domain as their child.
  subroutine forward_sussoil(pthrfrti, ld_levgen, ld_lessro, ld_lesn09, ld_lesnml, pnsnmlws, &
                             yddim, ydcst, ydsoil, pralfminpsn, prcimin)
    real(real64), intent(in) :: pthrfrti, pralfminpsn
    logical(int32), intent(in) :: ld_levgen, ld_lessro, ld_lesn09, ld_lesnml
    integer(int32), intent(in) :: pnsnmlws
    type(tdim), intent(in) :: yddim
    type(tcst), intent(in) :: ydcst
    type(tsoil), intent(inout) :: ydsoil
    real(real64), intent(in), optional :: prcimin
    call source_sussoil(pthrfrti, ld_levgen, ld_lessro, ld_lesn09, ld_lesnml, pnsnmlws, yddim, ydcst, ydsoil, pralfminpsn, prcimin)
  end subroutine
end module
