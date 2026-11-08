program native_operational_forecast
  !! Run the actual owned forecast through its concrete CNT4 provider.
  !! This separate observation variant retains the complete production stages.
  !! Its read-only checkpoint service cannot supply a weather calculation.
  use iso_fortran_env, only: int32, int64, real64, error_unit
  use ieee_arithmetic, only: ieee_nearest, ieee_set_rounding_mode, ieee_support_underflow_control, &
                             ieee_set_underflow_mode, ieee_support_datatype
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use mpi_f08
  use omp_lib, only: omp_get_max_threads
  use forecast_native_execution_state, only: native_forecast_execution_state
  use forecast_native_execution_setup, only: native_forecast_execution_budget, &
                                             initialize_native_forecast_execution, release_native_forecast_execution
  use forecast_native_time_loop, only: run_native_forecast_loop
  use forecast_native_weather_checkpoint, only: register_native_weather_capture, unregister_native_weather_capture
  use forecast_native_input_memory, only: native_input_memory_policy, minimum_codec_reserve_bytes, minimum_node_reserve_bytes
  implicit none
  type(native_forecast_execution_state), allocatable, target :: execution
  type(native_forecast_execution_budget) :: budget
  type(native_input_memory_policy) :: memory_policy
  character(4096) :: spectral_path, surface_path, upper_air_path, configuration_path, resource_path, journal_prefix, data_directory
  integer(int64) :: norm_work_bytes
  integer(int32) :: status, child_status, failed_stage, common_status, ignored
  integer :: error, rank, provided, threads, n, world_size
  logical :: message_passing_live

  message_passing_live = .false.
  call establish_initial_floating_environment(status)
  if (status /= 0) then
    write (error_unit, '(a)') 'Unsupported floating-point startup mode.'
    stop 2
  end if
  call MPI_Init_thread(MPI_THREAD_FUNNELED, provided, error)
  if (error /= MPI_SUCCESS) stop 3
  message_passing_live = .true.
  call MPI_Comm_rank(MPI_COMM_WORLD, rank, error)
  call require_message_passing(error)
  call MPI_Comm_size(MPI_COMM_WORLD, world_size, error)
  call require_message_passing(error)
  status = 2
  if (command_argument_count() == 7 .and. world_size == 32 .and. provided >= MPI_THREAD_FUNNELED) status = 0
  call MPI_Allreduce(status, common_status, 1, MPI_INTEGER4, MPI_MAX, MPI_COMM_WORLD, error)
  call require_message_passing(error)
  if (common_status /= 0) then
    if (rank == 0) write (error_unit, '(a)') &
      'Usage: native_forecast SPECTRAL SURFACE UPPER_AIR CONFIGURATION RESOURCE_LIMITS JOURNAL_DIRECTORY DATA_DIRECTORY'
    call fail_stage('arguments', 0_int32, common_status, 0_int32)
  end if
  call get_path(1, spectral_path, status)
  call get_path(2, surface_path, child_status); status = max(status, child_status)
  call get_path(3, upper_air_path, child_status); status = max(status, child_status)
  call get_path(4, configuration_path, child_status); status = max(status, child_status)
  call get_path(5, resource_path, child_status); status = max(status, child_status)
  call get_path(6, journal_prefix, child_status); status = max(status, child_status)
  call get_path(7, data_directory, child_status); status = max(status, child_status)
  if (len_trim(data_directory) > 480) status = 2
  threads = omp_get_max_threads()
  if (threads /= 1) status = 2
  call agree_or_fail('paths and thread admission', status, 0_int32, 0_int32)
  call read_resource_limits(trim(resource_path), budget, memory_policy, norm_work_bytes, status)
  call agree_or_fail('resource configuration', status, 0_int32, 0_int32)

  status = initialize_native_forecast_execution(execution, MPI_COMM_WORLD, trim(spectral_path), trim(surface_path), &
                trim(upper_air_path), trim(configuration_path), budget, memory_policy, trim(journal_prefix), trim(data_directory), &
                                                child_status, failed_stage)
  call agree_or_fail('complete native forecast startup', status, child_status, failed_stage)
  call register_native_weather_capture(execution, MPI_COMM_WORLD, status)
  call agree_or_fail('weather observation registration', status, 0_int32, 0_int32)
  status = run_native_forecast_loop(execution%loop, failed_stage)
  call agree_or_fail('native forecast loop', status, 0_int32, failed_stage)
  status = 2
  if (execution%loop%weather_calls == int(execution%startup%initial%controls%clock%integration%total_steps, int64)) status = 0
  call agree_or_fail('completed weather-step count', status, 0_int32, 0_int32)
  if (rank == 0) write (6, '(a,i0,a,i0)') 'Native forecast completed weather steps ', execution%loop%weather_calls, &
    ' at input date ', execution%startup%initial%prefix%headers%spectral%date
  call unregister_native_weather_capture(status)
  call agree_or_fail('weather observation retirement', status, 0_int32, 0_int32)
  status = release_native_forecast_execution(execution)
  call agree_or_fail('complete native forecast release', status, 0_int32, 0_int32)
  call MPI_Finalize(error)
  message_passing_live = .false.
  if (error /= MPI_SUCCESS) stop 3

contains
  subroutine establish_initial_floating_environment(status)
    !! Establish nearest-even once before model entry. Request gradual
    !! underflow only through supported compiler control. On a compiler
    !! without that control,one exact subnormal product checks the mode.
    !! This check restores the reached startup flags and never repairs a
    !! numerical result. The launch record separately observes exact Arm FPCR0.
    integer(int32), intent(out) :: status
    real(real64), volatile :: minimum_normal, half_value, probe
    type(ieee_status_type) :: reached
    status = 2
    if (.not. ieee_support_datatype(0.0_real64)) return
    call ieee_set_rounding_mode(ieee_nearest)
    if (ieee_support_underflow_control(0.0_real64)) then
      call ieee_set_underflow_mode(.true.)
    else
      call ieee_get_status(reached)
      minimum_normal = tiny(0.0_real64); half_value = 0.5_real64
      probe = minimum_normal*half_value
      if (transfer(probe, 0_int64) /= int(z'0008000000000000', int64)) then
        call ieee_set_status(reached)
        return
      end if
      call ieee_set_status(reached)
    end if
    status = 0
  end subroutine

  subroutine get_path(index, path, status)
    integer, intent(in) :: index
    character(4096), intent(out) :: path
    integer(int32), intent(out) :: status
    integer :: length, io
    path = ' '; status = 2
    call get_command_argument(index, length=length, status=io)
    if (io /= 0 .or. length < 1 .or. length > 4095) return
    call get_command_argument(index, value=path, status=io)
    if (io /= 0 .or. index_nul(path(:length))) return
    status = 0
  end subroutine

  pure logical function index_nul(text)
    character(*), intent(in) :: text
    index_nul = index(text, achar(0)) /= 0
  end function

  subroutine read_resource_limits(path, budget, policy, norm_limit, status)
    !! The separate resource file sets explicit byte capacities. It cannot
    !! change physics,dates,field ordering or configuration-file controls.
    !! Every large child samples its actual process,cgroup and allowed memory
    !! nodes again. The journal directory must already exist and be writable.
    character(*), intent(in) :: path
    type(native_forecast_execution_budget), intent(out) :: budget
    type(native_input_memory_policy), intent(out) :: policy
    integer(int64), intent(out) :: norm_limit
    integer(int32), intent(out) :: status
    integer(int64) :: node_budget_bytes, other_live_bytes, future_reserve_bytes, codec_reserve_bytes, &
          maximum_age_seconds, gridpoint_bytes, spectral_bytes, spectral_map_bytes, interpolation_bytes, work_bytes, norm_work_bytes
    integer(int64)::loop_bytes,spectral_setup_bytes,mass_bytes,transform_bytes,physics_bytes,ozone_bytes,fullpos_bytes,grid_bytes,halo_bytes,event_bytes
    integer(int32) :: memory_node_count, memory_nodes(64)
    integer :: unit, io, close_status, j
    namelist /native_forecast_resources/ node_budget_bytes, other_live_bytes, future_reserve_bytes, codec_reserve_bytes, &
      maximum_age_seconds, memory_node_count, memory_nodes, gridpoint_bytes, spectral_bytes, spectral_map_bytes, &
      interpolation_bytes, work_bytes, norm_work_bytes, loop_bytes, spectral_setup_bytes, mass_bytes, transform_bytes, &
      physics_bytes, ozone_bytes, fullpos_bytes, grid_bytes, halo_bytes, event_bytes
    loop_bytes = 0; spectral_setup_bytes = 0; mass_bytes = 0; transform_bytes = 0; physics_bytes = 0; ozone_bytes = 0
    fullpos_bytes = 0; grid_bytes = 0; halo_bytes = 0; event_bytes = 0
    node_budget_bytes = 0; other_live_bytes = -1
    future_reserve_bytes = minimum_node_reserve_bytes; codec_reserve_bytes = minimum_codec_reserve_bytes
    maximum_age_seconds = 120; memory_node_count = 0; memory_nodes = -1
    gridpoint_bytes = 0; spectral_bytes = 0; spectral_map_bytes = 0; interpolation_bytes = 0; work_bytes = 0; norm_work_bytes = 0
    status = 2; norm_limit = 0
    open (newunit=unit, file=path, status='old', action='read', form='formatted', iostat=io)
    if (io /= 0) return
    read (unit, nml=native_forecast_resources, iostat=io)
    close (unit, iostat=close_status)
    if (io /= 0 .or. close_status /= 0) return
    if (node_budget_bytes < 1 .or. other_live_bytes < 0) return
    if (future_reserve_bytes < minimum_node_reserve_bytes .or. codec_reserve_bytes < minimum_codec_reserve_bytes) return
    if (maximum_age_seconds < 1 .or. maximum_age_seconds > 120) return
    if (memory_node_count < 1 .or. memory_node_count > 64) return
    do j = 1, memory_node_count
      if (memory_nodes(j) < 0 .or. memory_nodes(j) > 4095) return
      if (j > 1) then
        if (memory_nodes(j) <= memory_nodes(j - 1)) return
      end if
    end do
    if (min(gridpoint_bytes, spectral_bytes, spectral_map_bytes, interpolation_bytes, work_bytes, norm_work_bytes) < 1) return
    if (min(loop_bytes, spectral_setup_bytes, mass_bytes, transform_bytes, physics_bytes, ozone_bytes, &
            fullpos_bytes, grid_bytes, halo_bytes, event_bytes) < 1) return
    budget%loop_bytes = loop_bytes; budget%norm_bytes = norm_work_bytes; budget%spectral_setup_bytes = spectral_setup_bytes
    budget%mass_bytes = mass_bytes; budget%transform_bytes = transform_bytes; budget%physics_bytes = physics_bytes
    budget%ozone_bytes = ozone_bytes; budget%fullpos_bytes = fullpos_bytes; budget%grid_bytes = grid_bytes; budget%halo_bytes = halo_bytes; budget%event_bytes = event_bytes
    policy%node_budget_bytes = node_budget_bytes; policy%other_live_bytes = other_live_bytes
    policy%future_reserve_bytes = future_reserve_bytes; policy%codec_reserve_bytes = codec_reserve_bytes
    policy%maximum_age_seconds = maximum_age_seconds
    policy%memory_node_count = memory_node_count; policy%memory_nodes = memory_nodes
    budget%input%input%fields%gridpoint_bytes = gridpoint_bytes
    budget%input%input%fields%spectral_bytes = spectral_bytes; budget%input%input%fields%spectral_map_bytes = spectral_map_bytes
    budget%input%input%interpolation_bytes = interpolation_bytes; budget%input%work_bytes = work_bytes
    norm_limit = norm_work_bytes
    status = 0
  end subroutine

  subroutine agree_or_fail(label, status, child, stage)
    character(*), intent(in) :: label
    integer(int32), intent(in) :: status, child, stage
    integer(int32) :: common
    integer :: error
    call MPI_Allreduce(status, common, 1, MPI_INTEGER4, MPI_MAX, MPI_COMM_WORLD, error)
    call require_message_passing(error)
    if (common /= 0) call fail_stage(label, stage, status, child)
  end subroutine

  subroutine fail_stage(label, stage, status, child)
    character(*), intent(in) :: label
    integer(int32), intent(in) :: stage, status, child
    integer :: error
    write (error_unit, '(a,i0,2a,3(a,i0))') 'Rank ', rank, ': ', label, ' stage=', stage, ' status=', status, ' child=', child
    if (message_passing_live) call MPI_Abort(MPI_COMM_WORLD, 1, error)
    stop 1
  end subroutine

  subroutine require_message_passing(code)
    integer, intent(in) :: code
    integer :: error
    if (code /= MPI_SUCCESS) then
      if (message_passing_live) call MPI_Abort(MPI_COMM_WORLD, 3, error)
      stop 3
    end if
  end subroutine
end program native_operational_forecast
