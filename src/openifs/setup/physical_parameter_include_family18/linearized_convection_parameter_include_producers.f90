!> Reuse complete native parameter producers for the assigned source includes.
!! Each entry keeps the canonical record types, argument intent and shapes.
!! Pressure is Pa, lengths are metres, temperature is K and time is seconds;
!! switches, counts and other scale factors are dimensionless. Natural
!! child status and arithmetic remain visible. No record or payload is copied.
module forecast_include_linearized_convection_parameters
  use iso_fortran_env, only: real64, int32, int64
  use yoecumf2, only: tecumf2
  use yomcumfs, only: tcumfs
 use convection_linearized_parameter_fields_mod,only:source_initialize_linearized_convection_fields=>initialize_linearized_convection_fields
  implicit none
  private
  public :: forward_initialize_linearized_convection_fields
contains
  !> Forward the complete source producer over its actual caller-owned records.
 !! Raw field entries require the same already-admitted domain as their child.
  subroutine forward_initialize_linearized_convection_fields(output, switches, pressure, rg, rplrg, rplradi, timestep)
    type(tecumf2), intent(inout) :: output
    type(tcumfs), intent(inout) :: switches
    real(real64), intent(in) :: pressure(:), rg, rplrg, rplradi, timestep
    call source_initialize_linearized_convection_fields(output, switches, pressure, rg, rplrg, rplradi, timestep)
  end subroutine
end module
