!> Reuse complete native parameter producers for the assigned source includes.
!! Each entry keeps the canonical record types, argument intent and shapes.
!! Pressure is Pa, lengths are metres, temperature is K and time is seconds;
!! switches, counts and other scale factors are dimensionless. Natural
!! child status and arithmetic remain visible. No record or payload is copied.
module forecast_include_diagnostic_cloud_parameters
  use iso_fortran_env, only: real64, int64
  use yoecld, only: tecld
  use diagnostic_cloud_parameter_fields_mod, only: source_initialize_diagnostic_cloud_fields => initialize_diagnostic_cloud_fields
  implicit none
  private
  public :: forward_initialize_diagnostic_cloud_fields
contains
  !> Forward the complete source producer over its actual caller-owned records.
 !! Raw field entries require the same already-admitted domain as their child.
  subroutine forward_initialize_diagnostic_cloud_fields(output, eta)
    type(tecld), intent(inout) :: output
    real(real64), intent(in) :: eta(:)
    call source_initialize_diagnostic_cloud_fields(output, eta)
  end subroutine
end module
