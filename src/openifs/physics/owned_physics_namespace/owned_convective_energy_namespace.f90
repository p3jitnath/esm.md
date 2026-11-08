!> Establish fresh source storage through the canonical convective_energy record.
module forecast_owned_convective_energy_namespace
  use iso_fortran_env, only: int32, real64
  use iso_c_binding, only: c_int8_t, c_loc, c_sizeof, c_f_pointer
  use upper_atmosphere_setup_port, only: native_convective_energy_controls
  implicit none
  private
  public :: native_convective_energy_controls, initialize_fresh_convective_energy_namespace
contains
  !> Write only the source zero-born named values before the physical producer.
 !! STATE is the existing caller-owned record, never a copied live namespace.
 !! Invoke this once at fresh allocation, before any source setup or consumer.
  integer(int32) function initialize_fresh_convective_energy_namespace(state) result(status)
    type(native_convective_energy_controls), target, intent(inout) :: state
    integer(c_int8_t), pointer :: bytes(:)
    call c_f_pointer(c_loc(state), bytes, [int(c_sizeof(state))])
    bytes = 0_c_int8_t
    state%ncapeiter = 0_int32
    state%netapes = 0_int32
    state%ncapepsd = 0_int32
    state%gcaperet = 0.0_real64
    state%gcapepsd = 0.0_real64
    status = 0
  end function
end module
