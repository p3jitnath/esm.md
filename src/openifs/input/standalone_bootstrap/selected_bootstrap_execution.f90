!> Selected numerical route with retired diagnostic observers removed.
!> Complete selected startup using real, stable native forecast owners.
module forecast_selected_bootstrap_execution
  use iso_fortran_env, only: int32
  use mpi_f08, only: MPI_Comm, MPI_Comm_size, MPI_SUCCESS
  use forecast_native_execution_state, only: native_forecast_execution_state, &
                                             initialize_fresh_execution_mass, prepare_actual_execution_angle_preimages, &
                                            prepare_actual_execution_dynamics_controls, prepare_actual_execution_machine_controls, &
                 prepare_actual_execution_composition, prepare_actual_execution_radiation_storage, prepare_actual_execution_metadata
  use forecast_native_execution_setup, only: native_forecast_execution_budget
  use forecast_selected_bootstrap_startup, only: create_selected_bootstrap_startup
  use forecast_selected_bootstrap_scientific_setup, only: prepare_selected_forecast_spectral_setup, &
                                            prepare_selected_forecast_physics_setup, prepare_selected_forecast_diagnostic_storage, &
                load_selected_forecast_input_fields, prepare_selected_forecast_interpolation, prepare_selected_forecast_grid_work, &
                                                          prepare_selected_forecast_fullpos
  use forecast_native_execution_physics_binding, only: bind_actual_forecast_physics
  use forecast_native_execution_controller_binding, only: bind_actual_forecast_controllers
  use forecast_native_input_memory, only: native_input_memory_policy
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
  public :: initialize_selected_bootstrap_execution
contains
  !> Build the selected one-process graph from its four original input paths.
 !! OUTPUT is an absent ALLOCATABLE TARGET. Its canonical MODEL/FIELDS/clock
 !! remain at their allocated addresses through all later consumers.
 !! BUDGET holds byte capacities only. Natural child failure keeps the reached
 !! prefix for release; no failed stage is replaced by a ready assignment.
 !! This constructor runs no forecast step and writes no diagnostic stream.
  integer(int32) function initialize_selected_bootstrap_execution(output, world, spectral_path, surface_path, &
   upper_path, configuration_path, budget, memory_policy, journal_prefix, data_directory, child_status, failed_stage) result(status)
    type(native_forecast_execution_state), allocatable, target, intent(inout) :: output
    type(MPI_Comm), intent(in) :: world
    character(*), intent(in) :: spectral_path, surface_path, upper_path, configuration_path, journal_prefix, data_directory
    type(native_forecast_execution_budget), intent(in) :: budget
    type(native_input_memory_policy), intent(in) :: memory_policy
    integer(int32), intent(out) :: child_status, failed_stage
    integer :: io, processes, n
    status = 2; child_status = 2; failed_stage = 1
    if (allocated(output)) return
    call MPI_Comm_size(world, processes, io)
    if (io /= MPI_SUCCESS .or. processes /= 1) return
    allocate (output, stat=io)
    if (io /= 0) then
      status = 1; child_status = 1; return
    end if
    ! The selected source fresh MODEL is calloc-born. This named zero preimage
    ! is retained by the admitted empty NAMDYN branch until TRANSINV consumes it.
    output%inverse_flags%rayleigh = .false.
    failed_stage = 2
    status = create_selected_bootstrap_startup(world, spectral_path, surface_path, upper_path, configuration_path, &
                     budget%input, budget%loop_bytes, budget%norm_bytes, data_directory, output%startup, child_status, failed_stage)
    if (status /= 0) return
    failed_stage = 3
    status = initialize_fresh_execution_mass(output)
    if (status /= 0) goto900
    status = prepare_actual_execution_angle_preimages(output)
    if (status /= 0) goto900
    failed_stage = 4
    status = prepare_actual_execution_dynamics_controls(output)
    if (status /= 0) goto900
    ! Selected NAMDYN is empty. Rayleigh flags retain their source fresh false
    ! values, matching the selected zero-born MODEL words. No operational137
    ! parser is called and no unrelated physical switch supplies their values.
    n = output%startup%initial%prefix%configuration_bytes
    status = require_empty_physics_group(output%startup%initial%prefix%configuration_text(1:n), 'NAMDYN')
    if (status /= 0) goto900
    if (output%inverse_flags%rayleigh) then
      status = 2; goto900
    end if
    failed_stage = 5
    status = prepare_actual_execution_machine_controls(output)
    if (status /= 0) goto900
    status = prepare_actual_execution_composition(output)
    if (status /= 0) goto900
    status = prepare_actual_execution_radiation_storage(output)
    if (status /= 0) goto900
    status = prepare_actual_execution_metadata(output)
    if (status /= 0) goto900
    failed_stage = 6
    status = prepare_selected_forecast_spectral_setup(output, world, budget%spectral_setup_bytes, child_status, failed_stage)
    if (status /= 0) return
    status = prepare_selected_forecast_physics_setup(output, world, budget%physics_bytes, budget%ozone_bytes, &
                                                     child_status, failed_stage)
    if (status /= 0) return
    status = prepare_selected_forecast_diagnostic_storage(output, world, child_status, failed_stage)
    if (status /= 0) return
    status = load_selected_forecast_input_fields(output, world, spectral_path, surface_path, upper_path, &
                                         budget%input, memory_policy, journal_prefix, budget%norm_bytes, child_status, failed_stage)
    if (status /= 0) return
    status = prepare_selected_forecast_interpolation(output, world, budget%halo_bytes, child_status, failed_stage)
    if (status /= 0) return
    status = prepare_selected_forecast_grid_work(output, world, budget%grid_bytes, child_status, failed_stage)
    if (status /= 0) return
    status = prepare_selected_forecast_fullpos(output, world, spectral_path, budget%fullpos_bytes, child_status, failed_stage)
    if (status /= 0) return
    status = bind_actual_forecast_physics(output, world, budget, child_status, failed_stage)
    if (status /= 0) return
    status = bind_actual_forecast_controllers(output, world, budget, child_status, failed_stage)
    if (status /= 0) return
    output%phase = 100; output%last_child_status = 0; output%last_failed_stage = 0
    child_status = 0; failed_stage = 0
    return
900 child_status = status
  end function
end module forecast_selected_bootstrap_execution
