!> Bind the real GP, EC physics and radiation owners in dependency order.
!! Every target belongs to the final execution record. This source creates
!! descriptor metadata through actual producers and calculates no weather.
module forecast_native_execution_physics_binding
  use iso_fortran_env, only: int32
  use mpi_f08, only: MPI_Comm
  use forecast_native_execution_state, only: native_forecast_execution_state
  use forecast_native_execution_setup, only: native_forecast_execution_budget
  use forecast_loaded_operational_model, only: agree_input_controller_status
  use forecast_cellular_transport_control_projection, only: project_cellular_departure_copy
  use forecast_actual_registry_metadata_aliases, only: bind_actual_registry_extra_aliases
  use forecast_native_gp_input_factory, only: prepare_native_gp_weather_bindings
  use forecast_native_gp_model_input_initialization, only: initialize_native_gp_model_inputs
  use forecast_native_cellular_text_adapter, only: prepare_native_cellular_controls_from_text
  use forecast_native_physics_context_bindings, only: bind_native_physics_providers, bind_native_post_controls, &
                                                      bind_native_ec_physics_inputs
  use forecast_native_runtime_physics_control_binding, only: bind_native_runtime_physics_input_controls, &
                                                             bind_native_public_hook_control
  use forecast_native_radiation_context_factory, only: bind_native_radiation_context
  implicit none
  private
  public :: bind_actual_forecast_physics
contains
  !> Prepare real weather views, then bind physics and publish GP readiness.
  !! BUDGET contains byte ceilings only. All ranks enter each status agreement.
  !! PHASE80 means this complete binding stage succeeded; it does not verify
  !! a forecast result. A failure keeps reached views for the real release.
  integer(int32) function bind_actual_forecast_physics(state, world, budget, child_status, failed_stage) result(status)
    type(native_forecast_execution_state), target, intent(inout) :: state
    type(MPI_Comm), intent(in) :: world
    type(native_forecast_execution_budget), intent(in) :: budget
    integer(int32), intent(out) :: child_status, failed_stage
    integer(int32) :: local
    logical :: cellular_departure_copy
    local = 2; child_status = 2; failed_stage = 1
    admission: block
      if (state%phase /= 70 .or. .not. allocated(state%startup)) exit admission
      if (.not. state%startup%loaded%ready .or. .not. allocated(state%fullpos)) exit admission
      if (.not. state%output_setup%ready .or. .not. state%single_column_control%ready) exit admission
      if (.not. state%spectral_setup%context%ready .or. .not. state%remaining%ready) exit admission
      local = 0
    end block admission
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 2
    local = bind_actual_registry_extra_aliases(state%startup%loaded%storage%model%fields, &
                                               state%startup%loaded%input%surface_metadata, state%registry_aliases)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 3
    call prepare_native_gp_weather_bindings(state%gp_work, state%grid, state%startup, state%spectral_setup, &
                                            state%physics, state%radiation, state%grid_work, budget%grid_bytes, world, local)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 4
    local = prepare_native_cellular_controls_from_text(state%physics_factory, state%startup)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 41
    local = project_cellular_departure_copy(state%physics_factory%readonly, cellular_departure_copy)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 5
    local = bind_native_physics_providers(state%physics_factory, state%startup, state%thermal, state%spp_configuration, &
                       state%chemistry, state%hook_control%enabled, state%single_column_control%scmec_enabled, budget%physics_bytes)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 6
    local = bind_native_post_controls(state%physics_factory, state%startup, state%output_configuration, &
                                      state%surface_selectors%no2dgg, state%surface_selectors%m2dggp)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 7
    local = bind_native_ec_physics_inputs(state%physics_factory, state%startup, state%physics_runtime, &
                                    state%sppt_configuration, state%stochastic_physics, state%output_setup%lnodryflx, state%physics)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 8
    local = bind_native_runtime_physics_input_controls(state%startup, state%soil_classes, state%sppt_data, &
                                                       state%sppt_configuration, state%output_setup, state%physics)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 9
    local = bind_native_public_hook_control(state%hook_control, state%physics)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 10
    local = bind_native_radiation_context(state%physics_factory, state%startup, state%thermal, state%chemistry, &
                                          state%spp_configuration, state%physics, state%radiation)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    failed_stage = 11
    call initialize_native_gp_model_inputs(state%gp_work, state%grid, state%startup, state%spectral_setup, state%remaining, &
                           state%physics, state%radiation, state%grid_work, state%interpolation_tables, state%diagnostic_controls, &
      state%diagnostic_storage,state%registry_aliases,state%parallel_policy,state%flux_controls,state%lnsponge,cellular_departure_copy,budget%grid_bytes,world,local)
    status = agree_input_controller_status(world, local); child_status = local
    if (status /= 0) return
    state%phase = 80; failed_stage = 0
  end function
end module forecast_native_execution_physics_binding
