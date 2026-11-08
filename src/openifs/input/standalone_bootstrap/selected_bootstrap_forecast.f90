!> Own the selected twenty-five-step forecast call after genuine startup.
module forecast_selected_bootstrap_forecast
  use iso_fortran_env, only: int32, int64
  use mpi_f08, only: MPI_Comm, MPI_Comm_size, MPI_SUCCESS
  use omp_lib, only: omp_get_max_threads
  use forecast_native_execution_state, only: native_forecast_execution_state
  use forecast_native_time_loop, only: run_native_forecast_loop
  implicit none
  private
  public :: run_selected_bootstrap_forecast
contains
  !> Advance the one live MODEL/FIELDS owner through its real CNT4 time loop.
 !! STATE is a final-address TARGET. Startup must already have produced every
 !! controller and scientific owner. This routine supplies no omitted stage.
 !! On success, exactly twenty-five STEPO calls have returned successfully.
 !! Child failure preserves the reached clock and payload for the caller.
  integer(int32) function run_selected_bootstrap_forecast(state, world, failed_stage) result(status)
    type(native_forecast_execution_state), target, intent(inout) :: state
    type(MPI_Comm), intent(in) :: world
    integer(int32), intent(out) :: failed_stage
    integer :: processes, error
    status = 2; failed_stage = 1
    if (state%phase /= 100) return
    if (.not. allocated(state%startup)) return
    if (.not. allocated(state%startup%initial)) return
    if (.not. state%startup%initial%ready) return
    if (.not. allocated(state%startup%initial%geometry)) return
    if (state%startup%initial%geometry%dimensions%nflevg /= 19) return
    if (state%startup%initial%geometry%dimensions%nsmax /= 21) return
    if (state%startup%initial%geometry%partition%ngptot /= 2048) return
    if (state%startup%initial%controls%clock%integration%total_steps /= 25) return
    if (state%loop%weather_calls /= 0_int64 .or. state%step%completed /= 0_int64) return
    if (omp_get_max_threads() /= 1) return
    call MPI_Comm_size(world, processes, error)
    if (error /= MPI_SUCCESS .or. processes /= 1) return
    failed_stage = 2
    status = run_native_forecast_loop(state%loop, failed_stage)
    if (status /= 0) return
    failed_stage = 3; status = 2
    if (state%loop%weather_calls /= 25_int64 .or. state%step%completed /= 25_int64) return
    state%phase = 110; failed_stage = 0; status = 0
  end function
end module forecast_selected_bootstrap_forecast
