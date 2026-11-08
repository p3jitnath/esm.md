!> Reuse complete native parameter producers for the assigned source includes.
!! Each entry keeps the canonical record types, argument intent and shapes.
!! Pressure is Pa, lengths are metres, temperature is K and time is seconds;
!! switches, counts and other scale factors are dimensionless. Natural
!! child status and arithmetic remain visible. No record or payload is copied.
module forecast_include_cumulus_parameters
  use iso_fortran_env, only: real64, int32, int64
  use iso_c_binding, only: c_double
  use yoecumf, only: tecumf
  use convection_parameter_fields_mod, only: source_initialize_cumulus_convection_fields => initialize_cumulus_convection_fields
  use convection_parameter_fields_mod, only: convection_thermal_parameter_record
  implicit none
  private
  public :: forward_initialize_cumulus_convection_fields
contains
  !> Forward the complete source producer over its actual caller-owned records.
 !! Raw field entries require the same already-admitted domain as their child.
  subroutine forward_initialize_cumulus_convection_fields(output, thermal, pressure, rg, rtt, rplrg, rpldare)
    type(tecumf), intent(inout) :: output
    type(convection_thermal_parameter_record), intent(inout) :: thermal
    real(real64), intent(in) :: pressure(:), rg, rtt, rplrg, rpldare
    call source_initialize_cumulus_convection_fields(output, thermal, pressure, rg, rtt, rplrg, rpldare)
  end subroutine
end module
