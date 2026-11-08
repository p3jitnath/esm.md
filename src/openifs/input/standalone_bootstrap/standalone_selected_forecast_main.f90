!> Own the selected T21/L19 forecast from seven paths through normal weather files.
!! The compiler supplies process startup. The program owns MPI, scientific
!! startup, all twenty-five weather calls, source-order release and finalization.
!! The eight retired diagnostic streams are outside this program's interface.
program standalone_selected_forecast
  use iso_fortran_env, only: int32, int64, real64, error_unit
  use iso_c_binding, only: c_int
  use ieee_arithmetic, only: ieee_round_type, ieee_nearest, ieee_get_rounding_mode, &
                             ieee_support_datatype, ieee_support_underflow_control, ieee_get_underflow_mode, operator(/=)
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status, ieee_all, ieee_get_halting_mode
  use mpi_f08
  use omp_lib, only: omp_get_max_threads
  use forecast_native_execution_state, only: native_forecast_execution_state
  use forecast_native_execution_setup, only: native_forecast_execution_budget
  use forecast_native_input_memory, only: native_input_memory_policy
  use forecast_selected_bootstrap_resource_policy, only: read_selected_bootstrap_resources
  use forecast_selected_bootstrap_execution, only: initialize_selected_bootstrap_execution
  use forecast_selected_bootstrap_forecast, only: run_selected_bootstrap_forecast
  use forecast_selected_bootstrap_release, only: release_selected_bootstrap_execution
  implicit none
  type(native_forecast_execution_state), allocatable, target :: state
  type(native_forecast_execution_budget) :: budget
  type(native_input_memory_policy) :: policy
  character(4095) :: paths(7)
  integer(int32) :: status, child, stage, cleanup_status
  integer :: io, provided, world_size, rank, j, n
  logical :: mpi_live
  interface
    subroutine process_exit(code) bind(C, name='exit')
      import c_int
      integer(c_int), value :: code
    end subroutine
  end interface

  mpi_live = .false.; rank = 0
  if (command_argument_count() /= 7) then
  write(error_unit,'(a)')'Usage: selected_forecast SPECTRAL SURFACE UPPER_AIR CONFIGURATION RESOURCES JOURNAL_PREFIX DATA_DIRECTORY'
    call process_exit(64_c_int)
  end if
  do j = 1, size(paths)
    call get_command_argument(j, length=n, status=io)
    if (io /= 0 .or. n < 1 .or. n > len(paths(j))) call process_exit(64_c_int)
    call get_command_argument(j, value=paths(j), status=io)
    if (io /= 0 .or. index(paths(j) (1:n), achar(0)) /= 0) call process_exit(64_c_int)
  end do
  if (len_trim(paths(7)) > 480) call process_exit(64_c_int)
  call require_initial_ieee_mode(status)
  if (status /= 0) call process_exit(65_c_int)
  call MPI_Init_thread(MPI_THREAD_FUNNELED, provided, io)
  if (io /= MPI_SUCCESS) call process_exit(3_c_int)
  mpi_live = .true.
  call MPI_Comm_rank(MPI_COMM_WORLD, rank, io)
  if (io /= MPI_SUCCESS) call fail('MPI rank', 3_int32, io, 0_int32)
  call MPI_Comm_size(MPI_COMM_WORLD, world_size, io)
  if (io /= MPI_SUCCESS) call fail('MPI size', 3_int32, io, 0_int32)
  if (world_size /= 1 .or. provided < MPI_THREAD_FUNNELED .or. omp_get_max_threads() /= 1) &
    call fail('selected one-process and one-thread profile', 2_int32, 0_int32, 0_int32)
  call read_selected_bootstrap_resources(trim(paths(5)), budget, policy, status)
  if (status /= 0) call fail('resource limits', status, 0_int32, 0_int32)

  status = initialize_selected_bootstrap_execution(state, MPI_COMM_WORLD, trim(paths(1)), trim(paths(2)), &
                                       trim(paths(3)), trim(paths(4)), budget, policy, trim(paths(6)), trim(paths(7)), child, stage)
  if (status /= 0) call fail('selected scientific startup', status, child, stage)
  status = run_selected_bootstrap_forecast(state, MPI_COMM_WORLD, stage)
  if (status /= 0) call fail('selected forecast', status, 0_int32, stage)
  if (state%loop%weather_calls /= 25_int64 .or. state%step%completed /= 25_int64) &
    call fail('complete selected trajectory', 2_int32, 0_int32, 0_int32)
  status = release_selected_bootstrap_execution(state)
  if (status /= 0) call fail('selected release', status, 0_int32, 0_int32)
  call MPI_Finalize(io)
  mpi_live = .false.
  if (io /= MPI_SUCCESS) call process_exit(3_c_int)

contains
  !> Check nearest-even, gradual underflow and disabled IEEE traps without changing them.
  !! This uses compiler IEEE facilities rather than a processor register layout.
  subroutine require_initial_ieee_mode(status)
    integer(int32), intent(out) :: status
    type(ieee_round_type) :: rounding
    type(ieee_status_type) :: saved
    logical :: gradual, halting(size(ieee_all))
    real(real64), volatile :: minimum_normal, half, probe
    status = 2
    if (.not. ieee_support_datatype(0.0_real64)) return
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) return
    call ieee_get_halting_mode(ieee_all, halting)
    if (any(halting)) return
    if (ieee_support_underflow_control(0.0_real64)) then
      call ieee_get_underflow_mode(gradual)
      if (.not. gradual) return
    else
      call ieee_get_status(saved)
      minimum_normal = tiny(0.0_real64); half = 0.5_real64
      probe = minimum_normal*half
      if (transfer(probe, 0_int64) /= int(z'0008000000000000', int64)) then
        call ieee_set_status(saved)
        return
      end if
      call ieee_set_status(saved)
    end if
    status = 0
  end subroutine

  !> Preserve the first natural failure while closing the reached owned prefix.
  subroutine fail(label, code, detail, where)
    character(*), intent(in) :: label
    integer(int32), intent(in) :: code, detail, where
    integer :: finalize_status
    if (rank == 0) write (error_unit, '(a,a,a,i0,a,i0,a,i0)') &
      'Selected forecast: ', label, ' status=', code, ' child=', detail, ' stage=', where
    if (allocated(state)) cleanup_status = release_selected_bootstrap_execution(state)
    if (mpi_live) then
      call MPI_Finalize(finalize_status)
      mpi_live = .false.
    end if
    call process_exit(int(max(1_int32, code), c_int))
  end subroutine
end program standalone_selected_forecast
