!> Own the forecast's declared variational simulation counter.
!! The original getter returns NGRADIENTS_COMPUTED, whose declaration
!! initializes it to zero. The original reset also stores zero.
module forecast_variational_simulation_control
  use iso_fortran_env, only: int32
  implicit none
  private
  public :: native_variational_simulation_control
  public :: initialize_variational_simulation_control
  !> Retain the dimensionless gradient count at a final caller-owned address.
  !! ready is false until setup has published nsim4d. The caller supplies
  !! TARGET storage when another record retains a readonly pointer to it.
  type :: native_variational_simulation_control
    logical :: ready = .false.
    integer(int32) :: nsim4d
  end type
contains
  !> Publish the original initial gradient count for a fresh forecast owner.
  !! nconf is the readonly actual produced configuration number. Only1,
  !! the supported forecast route, is admitted. output is INOUT owned
  !! storage: refusal2 changes nothing; success0 writes nsim4d then ready.
  !! Variational minimisation and a reused owner are refused. The counter
  !! comes from the original declaration and reset, not trajectory shape.
  integer(int32) function initialize_variational_simulation_control(nconf, output) result(status)
    integer(int32), intent(in) :: nconf
    type(native_variational_simulation_control), intent(inout) :: output
    status = 2_int32
    if (output%ready) return
    if (nconf /= 1_int32) return
    output%nsim4d = 0_int32
    output%ready = .true.
    status = 0_int32
  end function
end module forecast_variational_simulation_control
