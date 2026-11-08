!> Reuse complete native parameter producers for the assigned source includes.
!! Each entry keeps the canonical record types, argument intent and shapes.
!! Pressure is Pa, lengths are metres, temperature is K and time is seconds;
!! switches, counts and other scale factors are dimensionless. Natural
!! child status and arithmetic remain visible. No record or payload is copied.
module forecast_include_urban_parameters
  use iso_fortran_env, only: int32, real64
  use iso_c_binding, only: c_int, c_double, c_ptr, c_f_pointer
  use yos_urb, only: turb
  use susurb_mod, only: source_susurb => susurb
  implicit none
  private
  public :: forward_susurb
contains
  !> Forward the complete source producer over its actual caller-owned records.
 !! Raw field entries require the same already-admitted domain as their child.
  subroutine forward_susurb(ydurb)
    type(turb), intent(inout) :: ydurb
    call source_susurb(ydurb)
  end subroutine
end module
