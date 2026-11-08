!> Reuse complete native parameter producers for the assigned source includes.
!! Each entry keeps the canonical record types, argument intent and shapes.
!! Pressure is Pa, lengths are metres, temperature is K and time is seconds;
!! switches, counts and other scale factors are dimensionless. Natural
!! child status and arithmetic remain visible. No record or payload is copied.
module forecast_include_alternative_parameters
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double, c_loc, c_intptr_t
  use yomparar, only: tparar
  use forecast_empty_physics_configuration, only: require_empty_physics_group
 use alternative_physics_parameter_setup_port,only:source_initialize_alternative_physics_parameters=>initialize_alternative_physics_parameters, &
                                         source_set_alternative_parameter_literal_fields => set_alternative_parameter_literal_fields
  use alternative_physics_parameter_setup_port, only: selected_alternative_physics_inputs
  implicit none
  private
  public :: forward_initialize_alternative_physics_parameters
  public :: forward_set_alternative_parameter_literal_fields
contains
  !> Forward the complete source producer over its actual caller-owned records.
 !! Raw field entries require the same already-admitted domain as their child.
  integer(int32) function forward_initialize_alternative_physics_parameters(text, output, inputs) result(status)
    character(len=*), intent(in), target :: text
    type(tparar), intent(inout), target :: output
    type(selected_alternative_physics_inputs), intent(in), target :: inputs
    status = source_initialize_alternative_physics_parameters(text, output, inputs)
  end function
  !> Forward the complete source producer over its actual caller-owned records.
 !! Raw field entries require the same already-admitted domain as their child.
  subroutine forward_set_alternative_parameter_literal_fields(output)
    type(tparar), intent(inout) :: output
    call source_set_alternative_parameter_literal_fields(output)
  end subroutine
end module
