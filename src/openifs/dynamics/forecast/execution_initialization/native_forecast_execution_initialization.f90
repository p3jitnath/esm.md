!> Compose the actual native initialization chain at final TARGET addresses.
!! Paths refer to the unchanged spectral, surface, upper-air and configuration
!! inputs. Budgets are per-rank byte capacities, not scientific parameters.
!! Each completed real stage agrees its status across the same MPI world.
!! A failure retains acquired owners for the concrete execution release.
submodule(forecast_native_execution_setup) forecast_native_execution_initialization
  use forecast_native_execution_state, only: create_native_forecast_execution_storage
  use forecast_native_scientific_setup_steps, only: prepare_actual_forecast_spectral_setup, &
                                                prepare_actual_forecast_physics_setup, prepare_actual_forecast_diagnostic_storage, &
                      load_actual_forecast_input_fields, prepare_actual_forecast_interpolation, prepare_actual_forecast_grid_work, &
                                                    prepare_actual_forecast_fullpos
  use forecast_native_execution_physics_binding, only: bind_actual_forecast_physics
  use forecast_native_execution_controller_binding, only: bind_actual_forecast_controllers
contains
  module function initialize_native_forecast_execution(output, world, spectral_path, surface_path, &
       upper_air_path,configuration_path,budget,memory_policy,journal_prefix,data_directory,child_status,failed_stage)result(status)
    integer(int32) :: status
    type(native_forecast_execution_state), allocatable, target, intent(inout) :: output
    type(MPI_Comm), intent(in) :: world
    character(*), intent(in) :: spectral_path, surface_path, upper_air_path, configuration_path, journal_prefix, data_directory
    type(native_forecast_execution_budget), intent(in) :: budget
    type(native_input_memory_policy), intent(in) :: memory_policy
    integer(int32), intent(out) :: child_status, failed_stage
    status = create_native_forecast_execution_storage(world, spectral_path, surface_path, upper_air_path, &
         configuration_path, budget%input, budget%loop_bytes, budget%norm_bytes, data_directory, output, child_status, failed_stage)
    if (status /= 0) return
    status = prepare_actual_forecast_spectral_setup(output, world, budget%spectral_setup_bytes, child_status, failed_stage)
    if (status /= 0) return
 status = prepare_actual_forecast_physics_setup(output, world, budget%physics_bytes, budget%ozone_bytes, child_status, failed_stage)
    if (status /= 0) return
    status = prepare_actual_forecast_diagnostic_storage(output, world, child_status, failed_stage)
    if (status /= 0) return
    status = load_actual_forecast_input_fields(output, world, spectral_path, surface_path, upper_air_path, &
                                         budget%input, memory_policy, journal_prefix, budget%norm_bytes, child_status, failed_stage)
    if (status /= 0) return
    status = prepare_actual_forecast_interpolation(output, world, budget%halo_bytes, child_status, failed_stage)
    if (status /= 0) return
    status = prepare_actual_forecast_grid_work(output, world, budget%grid_bytes, child_status, failed_stage)
    if (status /= 0) return
    status = prepare_actual_forecast_fullpos(output, world, spectral_path, budget%fullpos_bytes, child_status, failed_stage)
    if (status /= 0) return
    status = bind_actual_forecast_physics(output, world, budget, child_status, failed_stage)
    if (status /= 0) return
    status = bind_actual_forecast_controllers(output, world, budget, child_status, failed_stage)
    if (status /= 0) return
    output%phase = 100
    output%last_failed_stage = 0; output%last_child_status = 0
    child_status = 0; failed_stage = 0
  end function
end submodule forecast_native_execution_initialization
