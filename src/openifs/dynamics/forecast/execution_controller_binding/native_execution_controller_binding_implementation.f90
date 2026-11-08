!> Bind the actual forecast controllers to one stable execution owner.
!! This support performs metadata setup only; it executes no weather stage.
submodule(forecast_native_execution_controller_binding) actual_execution_controller_binding_implementation
  use iso_fortran_env, only: int32, int64
  use mpi_f08
  use forecast_native_execution_state, only: native_forecast_execution_state
  use forecast_native_execution_setup, only: native_forecast_execution_budget
  use forecast_loaded_operational_model, only: agree_input_controller_status
  use forecast_actual_controller_control_projection, only: project_actual_controller_controls
  use forecast_source_diagnostic_schedule_controls, only: project_empty_source_diagnostic_schedule
  use forecast_operational_schedule, only: initialize_operational_output_switches
  use forecast_runtime_output_configuration, only: borrow_runtime_physical_output_requests
  use forecast_live_model_transform_binding, only: bind_live_model_transform_state
  use forecast_native_grid_scan, only: bind_forecast_grid_scan_context
  use forecast_native_time_step, only: bind_forecast_step_context
  use forecast_native_time_loop, only: bind_native_forecast_loop_context, prepare_native_forecast_events
  use forecast_output_controller, only: bind_actual_fullpos_driver
  use forecast_actual_output_policy_projection, only: project_actual_output_policy
  use forecast_grib_field_writers, only: native_grib_writer_policy
  use forecast_runtime_physical_output_block, only: native_physical_output_controls
  implicit none
contains
  !> Borrow the completed phase80 owners and construct the actual event tables.
  !!
  !! STATE is the final TARGET execution allocation and remains at this
  !! address until release. WORLD is its live MPI world. BUDGET contains
  !! immutable per-rank byte ceilings; these values do not set dimensions.
  !! CHILD_STATUS returns the natural local child result. FAILED_STAGE
  !! identifies the first failed stage. All ranks agree the status between
  !! stages, so a failed rank cannot leave peers entering a later collective.
  !! Return0 publishes phase90 only after every real binding succeeds.
  !! A failed prefix keeps its reached aliases and allocations for the
  !! existing execution release owner. No MODEL or field is copied here.
  !! The canonical clock, including its initial current-step sentinel,
  !! remains unchanged. LFINDVSEP is borrowed before CNT4 produces it;
  !! this support does not read it or supply an initial separation value.
  module procedure bind_actual_forecast_controllers
  integer(int32), pointer :: accumulation_reset => null()
  integer(int32) :: local
  integer :: configuration_bytes
  logical :: time_loop_ready
  type(native_grib_writer_policy) :: writer_policy
  type(native_physical_output_controls) :: physical_controls
  character(4095) :: output_directory

  status = 2_int32; child_status = 2_int32; failed_stage = 801_int32
  if (world == MPI_COMM_NULL) return
  state%last_failed_stage = 801_int32
  local = preflight()
  if (.not. reached(local, 801_int32)) return
  configuration_bytes = state%startup%initial%prefix%configuration_bytes

  state%last_failed_stage = 802_int32
  local = project_actual_controller_controls(state)
  if (.not. reached(local, 802_int32)) return

  state%last_failed_stage = 803_int32
  local = project_empty_source_diagnostic_schedule( &
          state%startup%initial%prefix%configuration_text(1:configuration_bytes), state%loop%stage_controls)
  if (.not. reached(local, 803_int32)) return

  state%last_failed_stage = 804_int32
  local = initialize_operational_output_switches( &
          state%startup%initial%prefix%configuration_text(1:configuration_bytes), &
          state%startup%initial%controls%namespace, state%loop%switches)
  if (.not. reached(local, 804_int32)) return

  state%last_failed_stage = 805_int32
  local = borrow_runtime_physical_output_requests(state%output_configuration, &
                                                  state%physical_count, state%physical_codes, accumulation_reset)
  if (.not. reached(local, 805_int32)) return
  state%scan%output%fields => state%fullpos
  state%scan%output%buffer => state%fullpos_data
  state%scan%output%physical_count => state%physical_count
  state%scan%output%physical_codes => state%physical_codes
  ! Both profile policies borrow the actual FIAT hook producer's value.
  state%scan%profile%enabled = state%hook_control%enabled
  state%step%profile%enabled = state%hook_control%enabled

  state%last_failed_stage = 806_int32
  local = bind_live_model_transform_state(state%startup%loaded%storage%model, &
                                          state%startup%loaded%input%spectral, state%startup%loop_data, budget%transform_bytes, &
                                          state%diagnostic_controls%lrhdddh, state%transform, state%transform_fields)
  if (.not. reached(local, 806_int32)) return

  state%last_failed_stage = 807_int32
  local = bind_forecast_grid_scan_context(state%scan, state%startup%loaded%storage%model, &
                                       state%startup%loaded%fields, state%startup%loaded%input, state%startup%scalars, state%grid, &
                                          state%loop%lfindvsep, state%hook_control)
  if (.not. reached(local, 807_int32)) return

  state%last_failed_stage = 808_int32
  local = bind_forecast_step_context(state%step, state%startup%loaded%storage%model, state%scan, &
                               state%transform, state%transform_fields, state%spectral_setup%context, state%spectral_setup%fields, &
                                     state%step_controls, state%inverse_flags, state%loop%implicit_weights, state%startup%loop_data)
  if (.not. reached(local, 808_int32)) return

  state%last_failed_stage = 809_int32
  local = bind_native_forecast_loop_context(state%loop, state%startup%loaded%storage, state%startup%loaded%input, &
                         state%step, state%startup%forcing, state%startup%norms, state%mass, state%spectral_setup%pressure%layout, &
                                         state%startup%initial%geometry%spherical%spherical%gm, state%fullpos, state%fullpos_data, &
                                         state%physical_count, state%physical_codes, state%loop_controls, state%startup%loop_data, &
                                            budget%norm_bytes, budget%mass_bytes)
  if (.not. reached(local, 809_int32)) return

  state%last_failed_stage = 810_int32
  local = prepare_native_forecast_events(state%loop, budget%event_bytes, state%fullpos%yfpcnt%nfrfpos, &
                                         state%fullpos%yfpcnt%nfposts, state%fullpos%yfpcnt%nfpostsmin)
  if (.not. reached(local, 810_int32)) return
  time_loop_ready = associated(state%loop%storage, state%startup%loaded%storage) .and. &
                    associated(state%loop%input, state%startup%loaded%input) .and. &
                    associated(state%loop%step, state%step) .and. state%loop%events%ready == 1_int32

  state%last_failed_stage = 811_int32
  output_directory = ' '
  local = project_actual_output_policy(state%startup%loaded%storage%model, &
                                       state%startup%loaded%input%surface_arrays, state%parallel_policy, state%parallel_admitted, &
                                       state%flux_controls, state%io_server, state%hook_control%enabled, state%output_common, &
                                 budget%fullpos_bytes, state%scan%output%driver, writer_policy, physical_controls, output_directory)
  if (.not. reached(local, 811_int32)) return

  state%last_failed_stage = 812_int32
  local = bind_actual_fullpos_driver(state%scan%output%driver, state%startup%loaded%storage%model, &
                                     state%startup%loaded%fields, state%startup%loaded%input%spectral, &
                                     state%startup%loaded%input%surface_metadata, state%startup%loaded%input%surface_arrays, &
                                     state%output_common, state%startup%scalars, state%startup%loaded%storage%model%physics%cloud, &
                                     state%thermal%thermal, state%output_metadata, physical_controls, writer_policy, world, &
                                     state%startup%loaded%storage%ecmwf%surface%ysoil%rdat, &
                                     state%startup%loaded%storage%ecmwf%surface%ysoil%rdaw, output_directory, &
                                     budget%fullpos_bytes, time_loop_ready)
  if (.not. reached(local, 812_int32)) return

  state%phase = 90_int32
  state%last_child_status = 0_int32; state%last_failed_stage = 0_int32
  child_status = 0_int32; failed_stage = 0_int32; status = 0_int32
contains
  !> Refuse an unsupported or already-bound owner before publishing aliases.
  integer(int32) function preflight() result(code)
    code = 2_int32
    if (state%phase /= 80_int32) return
    if (.not. allocated(state%startup)) return
    if (.not. allocated(state%startup%initial)) return
    if (.not. state%startup%initial%ready) return
    if (.not. allocated(state%startup%initial%prefix)) return
    if (.not. allocated(state%startup%initial%geometry)) return
    if (.not. state%startup%initial%geometry%initialized) return
    if (.not. allocated(state%startup%loaded%storage)) return
    if (.not. state%startup%loaded%storage%model%ready) return
    if (.not. associated(state%startup%loaded%storage%model%initial, state%startup%initial)) return
    if (.not. associated(state%startup%loaded%fields)) return
    if (.not. allocated(state%startup%loaded%input)) return
    if (.not. state%startup%loaded%input%ready) return
    if (state%startup%loaded%input%world /= world) return
    if (.not. associated(state%startup%loaded%input%model, state%startup%loaded%storage%model)) return
    if (.not. associated(state%startup%loaded%input%field_context, state%startup%loaded%fields)) return
    if (.not. associated(state%grid%model, state%startup%loaded%storage%model)) return
    if (.not. state%gp_work%registry_ready) return
    if (.not. state%spectral_setup%ready .or. .not. state%spectral_setup%context%ready) return
    if (.not. state%loop%implicit_weights%ready) return
    if (.not. allocated(state%fullpos)) return
    if (.not. state%output_configuration%ready) return
    if (.not. associated(state%fullpos_data%yfpos, state%fullpos)) return
    if (.not. allocated(state%fullpos%yfpcnt%nfposts)) return
    if (.not. allocated(state%fullpos%yfpcnt%nfpostsmin)) return
    if (.not. allocated(state%startup%initial%geometry%spherical%spherical%gm)) return
    if (associated(state%scan%model) .or. associated(state%step%model)) return
    if (associated(state%loop%storage) .or. associated(state%loop%input)) return
    if (state%loop%events%ready /= 0_int32 .or. allocated(state%loop%events%storage)) return
    if (state%scan%output%driver%actual_writer%ready) return
    configuration_bytes = state%startup%initial%prefix%configuration_bytes
    if (configuration_bytes < 1 .or. configuration_bytes > len(state%startup%initial%prefix%configuration_text)) return
    code = 0_int32
  end function

  !> Retain each child's local result while agreeing the return on all ranks.
  logical function reached(code, stage)
    integer(int32), intent(in) :: code, stage
    child_status = code
    status = agree_input_controller_status(world, code)
    state%last_child_status = code
    reached = status == 0_int32
    if (.not. reached) then
      failed_stage = stage
      state%last_failed_stage = stage
    end if
  end function
  end procedure bind_actual_forecast_controllers
end submodule actual_execution_controller_binding_implementation
