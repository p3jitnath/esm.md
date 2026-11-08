!> Declare the final typed controller binding without a callable placeholder.
!! The real implementation is a separate submodule with concrete native children.
module forecast_native_execution_controller_binding
  use iso_fortran_env, only: int32
  use mpi_f08, only: MPI_Comm
  use forecast_native_execution_state, only: native_forecast_execution_state
  use forecast_native_execution_setup, only: native_forecast_execution_budget
  implicit none
  private
  public :: bind_actual_forecast_controllers
  interface
    !> Borrow the final phase80 TARGET owners and publish phase90 on success.
    !! WORLD is the actual communicator. BUDGET contains per-rank byte limits.
    !! No MODEL, field or clock is copied. CHILD_STATUS preserves the local
    !! child result; FAILED_STAGE identifies the first failed source stage.
    !! A failure keeps reached aliases and event owners for execution release.
    !! The caller retains STATE at the same address until that release ends.
    module function bind_actual_forecast_controllers(state, world, budget, child_status, failed_stage) result(status)
      integer(int32) :: status
      type(native_forecast_execution_state), target, intent(inout) :: state
      type(MPI_Comm), intent(in) :: world
      type(native_forecast_execution_budget), intent(in) :: budget
      integer(int32), intent(out) :: child_status, failed_stage
    end function
  end interface
end module forecast_native_execution_controller_binding
