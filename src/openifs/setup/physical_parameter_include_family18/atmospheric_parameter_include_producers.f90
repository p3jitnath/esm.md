!> Reuse complete native parameter producers for the assigned source includes.
!! Each entry keeps the canonical record types, argument intent and shapes.
!! Pressure is Pa, lengths are metres, temperature is K and time is seconds;
!! switches, counts and other scale factors are dimensionless. Natural
!! child status and arithmetic remain visible. No record or payload is copied.
module forecast_include_atmospheric_parameters
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_intptr_t
  use yomphy0, only: tphy0
  use yomphy, only: tphy
  use forecast_empty_physics_configuration, only: require_empty_physics_group
 use atmospheric_physics_parameter_setup_port,only:source_initialize_atmospheric_physics_parameters=>initialize_atmospheric_physics_parameters, &
                                                 source_apply_atmospheric_parameter_literals => apply_atmospheric_parameter_literals
  implicit none
  private
  public :: forward_initialize_atmospheric_physics_parameters
  public :: forward_apply_atmospheric_parameter_literals
contains
  !> Forward the complete source producer over its actual caller-owned records.
 !! Raw field entries require the same already-admitted domain as their child.
  integer(int32) function forward_initialize_atmospheric_physics_parameters(text, output, physics, &
                                                                          rotation_rate, grid_length, lsimph, lecmwf) result(status)
    character(len=*), intent(in), target :: text
    type(tphy0), intent(inout), target :: output
    type(tphy), intent(in), target :: physics
    real(real64), intent(in), target :: rotation_rate, grid_length
    logical, intent(in), target :: lsimph, lecmwf
    status = source_initialize_atmospheric_physics_parameters(text, output, physics, rotation_rate, grid_length, lsimph, lecmwf)
  end function
  !> Forward the complete source producer over its actual caller-owned records.
 !! Raw field entries require the same already-admitted domain as their child.
  subroutine forward_apply_atmospheric_parameter_literals(output)
    type(tphy0), intent(inout) :: output
    call source_apply_atmospheric_parameter_literals(output)
  end subroutine
end module
