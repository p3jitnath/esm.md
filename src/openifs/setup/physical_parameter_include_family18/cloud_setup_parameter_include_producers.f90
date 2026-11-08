!> Reuse complete native parameter producers for the assigned source includes.
!! Each entry keeps the canonical record types, argument intent and shapes.
!! Pressure is Pa, lengths are metres, temperature is K and time is seconds;
!! switches, counts and other scale factors are dimensionless. Natural
!! child status and arithmetic remain visible. No record or payload is copied.
module forecast_include_cloud_setup_parameters
  use iso_fortran_env, only: real64, int32, int64
  use iso_c_binding, only: c_loc, c_intptr_t
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use ieee_exceptions, only: ieee_get_flag, ieee_set_flag, ieee_underflow, ieee_inexact
  use yoecldp, only: tecldp
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  use prognostic_cloud_parameter_fields_mod, only: prognostic_cloud_parameter_fields
 use prognostic_cloud_parameter_setup_mod,only:source_initialize_prognostic_cloud_parameters=>initialize_prognostic_cloud_parameters, &
                             source_initialize_runtime_prognostic_cloud_parameters => initialize_runtime_prognostic_cloud_parameters
  implicit none
  private
  public :: forward_initialize_prognostic_cloud_parameters
  public :: forward_initialize_runtime_prognostic_cloud_parameters
contains
  !> Forward the complete source producer over its actual caller-owned records.
 !! Raw field entries require the same already-admitted domain as their child.
  integer(int32) function forward_initialize_prognostic_cloud_parameters(text,output,pressure,rpi,rg,rtt,scalings,tsphy) result(status)
    character(len=*), intent(in), target :: text
    type(tecldp), intent(inout), target :: output
    real(real64), intent(in), target :: pressure(:), rpi, rg, rtt, scalings(2), tsphy
    status = source_initialize_prognostic_cloud_parameters(text, output, pressure, rpi, rg, rtt, scalings, tsphy)
  end function
  !> Forward the complete source producer over its actual caller-owned records.
 !! Raw field entries require the same already-admitted domain as their child.
  integer(int32) function forward_initialize_runtime_prognostic_cloud_parameters( &
    text, output, pressure, levels, rpi, rg, rtt, scalings, tsphy) result(status)
    character(len=*), intent(in), target :: text
    type(tecldp), intent(inout), target :: output
    real(real64), intent(in), target :: pressure(:), rpi, rg, rtt, scalings(2), tsphy
    integer(int32), intent(in), target :: levels
    status = source_initialize_runtime_prognostic_cloud_parameters(text, output, pressure, levels, rpi, rg, rtt, scalings, tsphy)
  end function
end module
