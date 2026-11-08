!> Reuse complete native parameter producers for the assigned source includes.
!! Each entry keeps the canonical record types, argument intent and shapes.
!! Pressure is Pa, lengths are metres, temperature is K and time is seconds;
!! switches, counts and other scale factors are dimensionless. Natural
!! child status and arithmetic remain visible. No record or payload is copied.
module forecast_include_cloud_fields_parameters
  use iso_fortran_env, only: real32, real64, int32, int64
  use iso_c_binding, only: c_double
  use yoecldp, only: tecldp
  use cloud_beta_gamma_mod, only: cloud_generalized_gamma, cloud_incomplete_beta
  use prognostic_cloud_parameter_fields_mod, only: source_prognostic_cloud_parameter_fields => prognostic_cloud_parameter_fields
  implicit none
  private
  public :: forward_prognostic_cloud_parameter_fields
contains
  !> Forward the complete source producer over its actual caller-owned records.
 !! Raw field entries require the same already-admitted domain as their child.
  subroutine forward_prognostic_cloud_parameter_fields(ydecldp, pressure, rpi, rg, rtt, scalings, tsphy)
    type(tecldp), intent(inout) :: ydecldp
    real(real64), intent(in) :: pressure(:), rpi, rg, rtt, scalings(2), tsphy
    call source_prognostic_cloud_parameter_fields(ydecldp, pressure, rpi, rg, rtt, scalings, tsphy)
  end subroutine
end module
