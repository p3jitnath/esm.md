!> Set the two source-defined large-scale condensation limits.
module condensation_parameter_setup_mod
  use iso_fortran_env, only: real64, int32, int64
  use yoecnd, only: tecnd
  implicit none
  private
  public :: initialize_condensation_parameters
contains
  !> Store SUCOND literals in the complete native TECND output record.
  !! OUTPUT receives REPFLM, whose source flux unit remains unspecified,
  !! and REPQMI in kg kg^-1. The compiler owns its bounds and alignment.
  !! Return 0 after both stores. There is no allocation, input pointer,
  !! formatted output or floating-point arithmetic in this selected entry.
  integer(int32) function initialize_condensation_parameters(output) result(status)
    type(tecnd), intent(inout) :: output
    output%repflm = transfer(int(z'3af357c299a88ea7', int64), 0.0_real64)
    output%repqmi = transfer(int(z'3e45798ee2308c3a', int64), 0.0_real64)
    status = 0_int32
  end function
end module
