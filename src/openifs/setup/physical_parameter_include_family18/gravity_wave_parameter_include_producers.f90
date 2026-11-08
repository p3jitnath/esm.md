!> Reuse complete native parameter producers for the assigned source includes.
!! Each entry keeps the canonical record types, argument intent and shapes.
!! Pressure is Pa, lengths are metres, temperature is K and time is seconds;
!! switches, counts and other scale factors are dimensionless. Natural
!! child status and arithmetic remain visible. No record or payload is copied.
module forecast_include_gravity_wave_parameters
  use iso_fortran_env, only: real64, int32
  use yoegwd, only: tegwd
  use yoegwwms, only: tegwwms
 use gravity_wave_parameter_fields_mod,only:source_initialize_orographic_gravity_wave_fields=>initialize_orographic_gravity_wave_fields, &
                                 source_initialize_nonorographic_gravity_wave_fields => initialize_nonorographic_gravity_wave_fields
  implicit none
  private
  public :: forward_initialize_orographic_gravity_wave_fields
  public :: forward_initialize_nonorographic_gravity_wave_fields
contains
  !> Forward the complete source producer over its actual caller-owned records.
 !! Raw field entries require the same already-admitted domain as their child.
  subroutine forward_initialize_orographic_gravity_wave_fields( &
    output, pressure, vah, vbh, rhour, lephys)
    type(tegwd), intent(inout) :: output
    real(real64), intent(in) :: pressure(:), vah(:), vbh(:), rhour
    logical, intent(in) :: lephys
    call source_initialize_orographic_gravity_wave_fields(output, pressure, vah, vbh, rhour, lephys)
  end subroutine
  !> Forward the complete source producer over its actual caller-owned records.
 !! Raw field entries require the same already-admitted domain as their child.
  subroutine forward_initialize_nonorographic_gravity_wave_fields( &
    output, pressure, rhour, timestep)
    type(tegwwms), intent(inout) :: output
    real(real64), intent(in) :: pressure(:), rhour, timestep
    call source_initialize_nonorographic_gravity_wave_fields(output, pressure, rhour, timestep)
  end subroutine
end module
