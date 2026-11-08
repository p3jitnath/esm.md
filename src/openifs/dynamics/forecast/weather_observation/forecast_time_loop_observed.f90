!> CNT4: own the forecast visit order around the actual canonical clock.
!! This source uses explicit native owners and concrete scientific providers.
module forecast_native_time_loop
  use iso_c_binding, only: c_int32_t
  use iso_fortran_env, only: int32, int64, real64
  use mpi_f08
  use forecast_selected_model_storage, only: native_selected_model_storage
  use forecast_native_loop_data, only: native_loop_data
  use forecast_implicit_time_weights, only: native_implicit_time_weight_state, initialize_implicit_time_weights
  use forecast_native_time_step, only: native_forecast_step_context, advance_forecast_step
  use forecast_runtime_operational_input, only: native_runtime_operational_input_state
  use forecast_initial_spectral_norm_join, only: native_initial_spectral_norm_state, compute_initial_input_spectral_norms
  use forecast_runtime_event_tables
  use forecast_operational_schedule, only: forecast_output_switches, forecast_stage_controls, forecast_stage_result, &
                                           select_runtime_regular_forecast_stage
  use forecast_model_time_and_forcing, only: native_time_and_forcing_context, update_runtime_model_time_and_forcing
  use forecast_initial_step_diagnostics, only: run_initial_step_diagnostics
  use forecast_source_dry_mass_reference, only: native_dry_mass_reference, calculate_source_dry_mass_reference
  use md2asm_spectral_transposes, only: spectral_transpose_layout
 use forecast_grid_field_norms,only:selected_gridpoint_norm_result,compute_selected_gridpoint_norms,compute_runtime_grid_field_norms
  use forecast_output_controller, only: native_fullpos_driver_context, execute_fullpos_driver
  use forecast_fullpos_state_types, only: native_fullpos_state, native_fullpos_data
  use runtime_grib_file_services_port, only: flush_grib_output
  use md2asm_transform_profile_policy, only: transform_profile_policy, transform_profile_event, increment_source_counter
  implicit none
  private
  public :: native_forecast_loop_context, native_loop_excluded_controls, bind_native_forecast_loop_context
  public :: prepare_native_forecast_implicit_weights
  public::run_native_forecast_loop,run_selected_native_forecast_loop,prepare_native_forecast_events,release_native_forecast_events
  public :: forecast_loop_completed_count
  !> Required source switches for excluded branches; no defaults are invented.
  !! The owning setup must provide these values before the loop is bound.
  type :: native_loop_excluded_controls
    logical :: ljcdfi, ldfi, lscrini, locedelay
    integer(int32) :: nsim4d
    logical :: lmasdry, ldgpmascor, lxfu, lcumfu
    logical :: lchem_dia, lstoph_casbs, lstoph_spbs
  end type
  !> Borrow exactly one model, clock, numerical input and each active child.
  !! No weather state is copied. Fixed small norm results are diagnostic
  !! outputs; their values never replace a model field. LFINDVSEP is the one source-named
  !! word written by CNT4 before its first scientific consumer.
  type :: native_forecast_loop_context
    type(native_selected_model_storage), pointer :: storage => null()
    type(native_runtime_operational_input_state), pointer :: input => null()
    type(native_forecast_step_context), pointer :: step => null()
    type(native_time_and_forcing_context), pointer :: forcing => null()
    type(native_initial_spectral_norm_state), pointer :: spectral_norms => null()
    type(native_dry_mass_reference), pointer :: mass => null()
    type(spectral_transpose_layout), pointer :: spectral_layout => null()
    real(real64), pointer, contiguous :: map_factor(:) => null()
    type(native_fullpos_driver_context), pointer :: output => null()
    type(native_fullpos_state), pointer :: fullpos => null()
    type(native_fullpos_data), pointer :: fullpos_data => null()
    integer(int32), pointer :: physical_count => null(), physical_codes(:) => null()
    type(native_loop_excluded_controls), pointer :: excluded => null()
    type(native_loop_data), pointer :: loop_data => null()
    logical :: lfindvsep
    type(native_implicit_time_weight_state) :: implicit_weights
    type(forecast_output_switches) :: switches
    type(forecast_stage_controls) :: stage_controls
    type(native_forecast_event_tables) :: events
    type(transform_profile_policy) :: profile
    type(selected_gridpoint_norm_result) :: selected_grid_result
    real(real64) :: grid_results(4, 16)
    integer(int32) :: grid_selected_count = 0, report_unit = 6, last_signal_seconds = 0
    integer(int64) :: norm_budget = 0, mass_budget = 0, completed = 0, visit_calls = 0, weather_calls = 0
  end type
  interface
    ! The observer is a separate read-only service, so no execution-type
    ! module enters this controller's dependency graph.
  function native_weather_boundary_c(snapshot_index) bind(C, name='md2asm_observe_native_forecast_boundary') result(boundary_status)
      import :: c_int32_t
      integer(c_int32_t), value, intent(in) :: snapshot_index
      integer(c_int32_t) :: boundary_status
    end function
    subroutine loop_statistics(event, phase) bind(C, name='gstats_')
      import :: int32
      integer(int32), intent(in) :: event, phase
    end subroutine
  end interface
contains
  !> Run the genuine SUDYN weight producer after the real trajectory setup.
  !! CONTEXT remains at its final TARGET address. STEPO later borrows these
  !! exact RBT/RBTS2 words; no startup fixture or copied time step is used.
  integer(int32) function prepare_native_forecast_implicit_weights(context, input) result(status)
    type(native_forecast_loop_context), target, intent(inout) :: context
    type(native_runtime_operational_input_state), intent(in) :: input
    status = 2
    if (context%implicit_weights%ready) return
    if (.not. input%ready .or. .not. associated(input%model)) return
    if (.not. associated(input%model%initial)) return
    status = initialize_implicit_time_weights(input%lagrangian, input%model%initial%controls%namespace%lr2d /= 0, &
                                              input%model%dynamics%lslag, input%model%dynamics%ltwotl, context%implicit_weights)
  end function

  !> Associate the existing source lifetimes at their final native addresses.
  !! STORAGE owns one MODEL,INPUT owns its loaded fields,and STEP already
  !! borrows both. FORCING owns real scientific records,not a second clock.
  !! MASS is the same mutable target consumed later by SPCM. LAYOUT and
  !! MAP_FACTOR borrow actual geometry maps; MAP_FACTOR has Q local entries.
  !! FULLPOS and DATA are the actual parsed request and cached scientific data.
  !! PHYSICAL_CODES is the source parameter list,not an encoded argument table.
  !! This routine allocates nothing and supplies no missing numerical stage.
  integer(int32) function bind_native_forecast_loop_context(context, storage, input, step, forcing, norms, &
         mass,layout,map_factor,fullpos,data,physical_count,physical_codes,excluded,loop_data,norm_budget,mass_budget)result(status)
    type(native_forecast_loop_context), target, intent(inout) :: context
    type(native_selected_model_storage), target, intent(inout) :: storage
    type(native_runtime_operational_input_state), target, intent(inout) :: input
    type(native_forecast_step_context), target, intent(inout) :: step
    type(native_time_and_forcing_context), target, intent(inout) :: forcing
    type(native_initial_spectral_norm_state), target, intent(inout) :: norms
    type(native_dry_mass_reference), target, intent(inout) :: mass
    type(spectral_transpose_layout), target, intent(in) :: layout
    real(real64), target, contiguous, intent(in) :: map_factor(:)
    type(native_fullpos_state), target, intent(in) :: fullpos
    type(native_fullpos_data), target, intent(inout) :: data
    integer(int32), target, intent(inout) :: physical_count, physical_codes(:)
    type(native_loop_excluded_controls), target, intent(in) :: excluded
    type(native_loop_data), target, intent(inout) :: loop_data
    integer(int64), intent(in) :: norm_budget, mass_budget
    status = 2
    if (associated(context%storage) .or. associated(context%input) .or. associated(context%step)) return
    if (.not. storage%model%ready .or. .not. associated(storage%model%initial)) return
    if (.not. associated(input%model, storage%model)) return
    if (.not. associated(step%model, storage%model) .or. .not. associated(step%scan)) return
    if (.not. associated(step%scan%input, input)) return
    if (.not. associated(step%spectral)) return
    if (.not. associated(step%spectral%mass, mass)) return
    if (.not. associated(step%implicit_weights, context%implicit_weights)) return
    if (.not. associated(step%loop_data, loop_data)) return
    if (norm_budget < 1_int64 .or. norm_budget > 2_int64**36 .or. mass_budget < 1_int64 .or. mass_budget > 2_int64**36) return
    if (.not. associated(forcing%surface_arrays, input%surface_arrays)) return
    if (.not. associated(forcing%surface_catalog, input%surface_metadata)) return
    context%storage => storage; context%input => input; context%step => step
    context%forcing => forcing; context%spectral_norms => norms; context%mass => mass
    context%spectral_layout => layout; context%map_factor => map_factor
    context%output => step%scan%output%driver
    context%fullpos => fullpos; context%fullpos_data => data
    context%physical_count => physical_count; context%physical_codes => physical_codes
    context%excluded => excluded; context%loop_data => loop_data
    context%norm_budget = norm_budget; context%mass_budget = mass_budget
    context%profile = step%profile
    status = 0
  end function

  !> Construct the actual twelve schedules before the first forecast visit.
  !! Fullpos frequency and lists borrow the real parsed request owner. Optional
  !! presence is retained, including a present zero frequency. Bytes are
  !! explicit resource capacities. Failed construction publishes no table.
  integer(int32) function prepare_native_forecast_events(context, budget, &
                                                         fullpos_frequency, fullpos_requests, fullpos_minutes) result(status)
    type(native_forecast_loop_context), intent(inout) :: context
    integer(int64), intent(in) :: budget
    integer(int32), optional, intent(in) :: fullpos_frequency, fullpos_requests(:), fullpos_minutes(:)
    status = 2
    if (.not. associated(context%storage) .or. .not. associated(context%loop_data)) return
    if (.not. associated(context%storage%model%initial)) return
    ! Copy only the source snapshot values which already have canonical owners.
    context%stage_controls%ltwotl = context%storage%model%dynamics%ltwotl
    context%stage_controls%lmse = context%storage%model%physics%arpege_physics%lmse
    context%stage_controls%lwcou = context%storage%model%physics%wave_coupling%lwcou
    status = initialize_runtime_forecast_events(context%storage%model%initial%controls%namespace, &
                                           context%storage%model%initial%controls%clock, context%stage_controls, context%switches, &
   context%loop_data%nfrres, context%loop_data%nrests, budget, context%events, fullpos_frequency, fullpos_requests, fullpos_minutes)
  end function

  !> Retain the old25-step,one-process and six-step Fullpos source domain.
  !! The separate runtime entry derives its stop and event frequency from
  !! the actual producers. This wrapper never substitutes a smaller grid.
  integer(int32) function run_selected_native_forecast_loop(context, failed_stage) result(status)
    type(native_forecast_loop_context), target, intent(inout) :: context
    integer(int32), intent(out) :: failed_stage
    status = 2; failed_stage = 0
    if (.not. associated(context%storage) .or. .not. associated(context%input)) return
    if (.not. associated(context%storage%model%initial) .or. .not. associated(context%fullpos)) return
    if (.not. allocated(context%storage%model%initial%geometry)) return
    if (context%storage%model%initial%geometry%transform_control%nproc /= 1) return
    if (context%storage%model%initial%controls%clock%integration%total_steps /= 25) return
    if (context%input%lagrangian%lmascor) return
    if (context%fullpos%yfpcnt%nfrfpos /= 6) return
    status = run_native_forecast_loop(context, failed_stage)
  end function

  !> Execute every visit0:NSTOP, including the final diagnostics-only visit.
  !! The actual clock owns TSTEP as FIRST_DT and TDT as SECOND_DT, in seconds.
  !! Copy TSTEP to TDT before each concrete time-update call, publish NSTEP
  !! afterwards, then form REAL(NSTEP)*TSTEP and add0.5 in separate FP64 steps.
  !! Late failure stops with its real partial state; no completed forecast or
  !! rollback is claimed. FAILED_STAGE identifies admission0,STEPX1,time2,
  !! mass3,spectralnorm4,gridnorm5,STEPO6 or Fullpos/flush7.
  integer(int32) function run_native_forecast_loop(context, failed_stage) result(status)
    type(native_forecast_loop_context), target, intent(inout) :: context
    integer(int32), intent(out) :: failed_stage
    type(forecast_stage_result) :: selected
    integer(int32) :: visit, stop, child, step_stage, io_status
    integer(int32) :: observation_status
    logical :: post_event, mass_event
    logical :: diagnostic_flags(2)
    real(real64) :: begin_time, end_time, product, event_time, hook_handle
    character(len=9) :: configuration
    character(len=128) :: environment
    logical :: timer_text, date_text
    status = 2; failed_stage = 0
    if (.not. loop_context_ready(context)) return
    stop = context%storage%model%initial%controls%clock%integration%total_steps
    call transform_profile_event('CNT4', 0_int32, hook_handle, context%profile)
    call loop_statistics(1845_int32, 0_int32)
    call loop_statistics(1845_int32, 1_int32)
    call get_environment_variable('EC_DATE_AND_TIME', environment)
    timer_text = environment /= '0' .and. environment /= '-1'
    date_text = environment /= '0' .and. environment /= '1'
    context%storage%model%physics%ecmwf_physics%lfpos_acc_reset = .false.
    failed_stage = 1
    diagnostic_flags = [context%excluded%lxfu, context%excluded%lcumfu]
    status = run_initial_step_diagnostics(diagnostic_flags)
    if (status /= 0) return
    call loop_statistics(737_int32, 0_int32)
    if (context%storage%model%initial%geometry%transform_control%nproc > 1) then
      call MPI_Barrier(context%input%world, io_status)
      if (io_status /= MPI_SUCCESS) then
        status = 3; return
      end if
    end if
    call loop_statistics(737_int32, 1_int32)
    call loop_statistics(1_int32, 0_int32)
    context%lfindvsep = .false.
    do visit = 0, stop
      call user_clock_at_visit(begin_time)
      context%storage%model%initial%controls%clock%integration%second_dt = &
        context%storage%model%initial%controls%clock%integration%first_dt
      failed_stage = 2
      status = update_runtime_model_time_and_forcing(context%storage, visit, &
                                                     context%storage%model%initial%controls%clock%integration%second_dt, &
                                         context%storage%model%initial%controls%clock%integration%first_dt, .true., context%forcing)
      if (status /= 0) return
      context%storage%model%initial%controls%clock%current_step = visit
      product = real(visit, real64)*context%storage%model%initial%controls%clock%integration%first_dt
      event_time = product + 0.5_real64
      status = select_runtime_regular_forecast_stage(context%storage%model%initial%controls%namespace, &
                                    context%storage%model%initial%controls%clock, context%stage_controls, context%switches, visit, &
                                                     associated(context%fullpos), selected)
      if (status /= 0) return
      post_event = .false.; mass_event = .false.
      status = runtime_event_selected(context%events, event_fullpos, visit, post_event)
      if (status /= 0) return
      status = runtime_event_selected(context%events, event_mass_check, visit, mass_event)
      if (status /= 0) return
      context%storage%model%physics%ecmwf_physics%lfpos_acc_reset = .false.
      context%storage%model%physics%ecmwf_physics%lfpos_ec_phys = post_event
      failed_stage = 3
      if (context%input%lagrangian%lmascor .and. mass_event) then
        status = calculate_loop_dry_mass(context, visit)
        if (status /= 0) return
      else
        context%mass%gmassinc = 0.0_real64
      end if
      failed_stage = 4
      status = compute_initial_input_spectral_norms(context%storage%model, context%input%spectral, &
                                                    context%input%world, context%norm_budget, context%spectral_norms)
      if (status /= 0) return
      failed_stage = 5
      status = calculate_loop_grid_norm(context)
      if (status /= 0) return
      context%input%lagrangian%ncurrent_iter = 0
      if (visit < stop) then
        ! Preserve actual optional presence for both inverse transforms and
        ! the SCAN2M output call. The targets remain owned by this caller.
        if (post_event) then
          context%step%scan%output%fields => context%fullpos
          context%step%scan%output%buffer => context%fullpos_data
        else
          nullify (context%step%scan%output%fields, context%step%scan%output%buffer)
        end if
        configuration = transfer(selected%configuration, configuration)
        ! Capture the initialized weather after the complete CNT4 prologue.
        if (visit == 0) then
          observation_status = native_weather_boundary_c(0_int32)
          if (observation_status /= 0) then
            status = observation_status; failed_stage = 8; return
          end if
        end if
        failed_stage = 6
        status = advance_forecast_step(context%step, configuration, step_stage)
        if (status /= 0) return
        ! STEPO has returned success and incremented its own completed count.
        if (visit == 0 .or. visit == 1) then
          observation_status = native_weather_boundary_c(visit + 1_int32)
          if (observation_status /= 0) then
            status = observation_status; failed_stage = 8; return
          end if
        end if
        call increment_source_counter(context%weather_calls)
      end if
      if (post_event .and. visit < stop) then
        context%fullpos_data%lfpupdsuw = .false.
        context%fullpos_data%lfpupdcli = .false.
      end if
      failed_stage = 7
      if (post_event) then
        status = execute_fullpos_driver(context%output, context%fullpos, context%fullpos_data, &
                                        2_int32, .true., .false., context%physical_count, context%physical_codes)
        if (status /= 0) return
        call flush_grib_output(1_int32)
        context%last_signal_seconds = int(event_time, int32)
        status = execute_fullpos_driver(context%output, context%fullpos, context%fullpos_data, &
                                        0_int32, .true., .true., context%physical_count, context%physical_codes)
        if (status /= 0) return
      end if
      call flush_grib_output(1_int32)
      call user_clock_at_visit(end_time)
      write (context%report_unit, '(" NSTEP =",I6," model seconds ",F16.3," elapsed ",ES24.16)', iostat=io_status) &
        visit, event_time, end_time - begin_time
      if (io_status /= 0) then
        status = 3; return
      end if
      call increment_source_counter(context%visit_calls)
    end do
    context%lfindvsep = .false.
    call loop_statistics(1_int32, 1_int32)
    context%loop_data%restart = '0'
    call transform_profile_event('CNT4', 1_int32, hook_handle, context%profile)
    call increment_source_counter(context%completed)
    failed_stage = 0; status = 0
  end function

  !> Calculate dry mass with the real phase7 layout and spectral pressure owner.
  integer(int32) function calculate_loop_dry_mass(context, visit) result(status)
    type(native_forecast_loop_context), intent(inout) :: context
    integer(int32), intent(in) :: visit
    if (context%spectral_layout%vertical_index == context%spectral_layout%vertical_peers) then
      status = calculate_source_dry_mass_reference(context%storage%model%initial%geometry, context%spectral_layout, &
                                        context%input%spectral%sp2d(:, 1), context%map_factor, visit, context%excluded%ldgpmascor, &
                                                   context%excluded%lmasdry, context%mass_budget, context%mass)
    else
      status = calculate_source_dry_mass_reference(context%storage%model%initial%geometry, context%spectral_layout, &
                                      context%input%spectral%sp2d(1:1, 1), context%map_factor, visit, context%excluded%ldgpmascor, &
                                                   context%excluded%lmasdry, context%mass_budget, context%mass)
    end if
  end function

  !> Resolve numerical GFL columns from actual component MP metadata once per call.
  !! Ordinary FP64 owners remain dense(P,L,C,B); inactive component records do
  !! not invent columns. This wrapper changes no field or descriptor.
  integer(int32) function calculate_loop_grid_norm(context) result(status)
    type(native_forecast_loop_context), intent(inout) :: context
    logical :: selected(2048)
    integer(int32) :: controls(4), j, mp, columns, numflds, world
    status = 2
    if (.not. allocated(context%input%upper%fields%gfl)) return
    columns = size(context%input%upper%fields%gfl, 3)
    if (columns < 1 .or. columns > 2048) return
    numflds = context%storage%model%fields%registration%numflds
    if (numflds < 1 .or. numflds > size(context%storage%model%fields%components)) return
    selected = .false.
    do j = 1, numflds
      if (context%storage%model%fields%components(j)%lgp == 0) cycle
      if (context%storage%model%fields%components(j)%lgp /= 1) return
      mp = context%storage%model%fields%components(j)%mp
      if (mp < 1 .or. mp > columns) return
      selected(mp) = .true.
    end do
    world = context%storage%model%initial%geometry%transform_control%nproc
    if (world == 1 .and. context%storage%model%initial%geometry%dimensions%nflevg == 19 .and. &
        context%storage%model%initial%geometry%dimensions%nproma == 24 .and. columns == 8) then
      call compute_selected_gridpoint_norms(context%storage%model%initial%geometry, context%input%upper%fields%gfl, &
                                            selected(1:columns), [0_int32, 0_int32, 1_int32], context%selected_grid_result, status)
    else
      controls = [0_int32, 0_int32, world, 0_int32]
      call compute_runtime_grid_field_norms(context%input%world, context%storage%model%initial%geometry, &
                             context%input%upper%fields%gfl, selected(1:columns), controls, context%storage%model%dynamics%lnhdyn, &
                                          context%grid_results, context%grid_selected_count, 520_int64, context%norm_budget, status)
    end if
  end function

  !> Refuse missing actual owners before any timing, allocation or model change.
  logical function loop_context_ready(context) result(valid)
    type(native_forecast_loop_context), target, intent(in) :: context
    valid = .false.
    if (.not. associated(context%storage) .or. .not. associated(context%input) .or. .not. associated(context%step)) return
    if (.not. associated(context%forcing) .or. .not. associated(context%spectral_norms)) return
    if (.not. associated(context%mass) .or. .not. associated(context%excluded)) return
    if (.not. associated(context%loop_data)) return
    if (.not. associated(context%step%loop_data, context%loop_data)) return
    if (.not. associated(context%storage%model%initial)) return
    if (.not. allocated(context%storage%model%initial%geometry)) return
    if (.not. associated(context%input%model, context%storage%model)) return
    if (.not. associated(context%step%model, context%storage%model)) return
    if (context%input%world == MPI_COMM_NULL) return
    if (.not. associated(context%step%implicit_weights, context%implicit_weights)) return
    if (.not. associated(context%step%excluded)) return
    if (context%step%excluded%lsidg .or. context%step%excluded%lstrhd .or. context%step%excluded%nsiter /= 0) return
    if (.not. associated(context%step%spectral)) return
    if (.not. associated(context%step%spectral%mass, context%mass)) return
    if (context%events%ready /= 1) return
    if (context%events%last_step /= context%storage%model%initial%controls%clock%integration%total_steps) return
    if (context%storage%model%initial%controls%clock%integration%first_step /= 0) return
    if (context%storage%model%initial%controls%namespace%nconf /= 1) return
    if (context%storage%model%initial%controls%namespace%lnf /= 1) return
    if (context%storage%model%initial%controls%namespace%lelam /= 0 .or. &
        context%storage%model%initial%controls%namespace%lr2d /= 0) return
    if (context%storage%model%initial%controls%namespace%lifsmin /= 0 .or. &
        context%storage%model%initial%controls%namespace%lobsc1 /= 0 .or. &
        context%storage%model%initial%controls%namespace%lobsref /= 0 .or. &
        context%storage%model%initial%controls%namespace%l_oops /= 0) return
    if (context%storage%model%initial%controls%namespace%lconserv /= 0 .or. &
        context%storage%model%initial%controls%namespace%lcorwat /= 0 .or. &
        context%storage%model%initial%controls%namespace%nfrcorm /= 0 .or. &
        context%storage%model%initial%controls%namespace%nfrco /= 0 .or. &
        context%storage%model%initial%controls%namespace%larpegef /= 0) return
    if (.not. context%storage%model%dynamics%ltwotl .or. context%storage%model%dynamics%lpc_full) return
    if (context%storage%model%fields%alias_controls%nchem /= 0) return
    if (.not. context%storage%model%physics%ecmwf_physics%lephys .or. &
        .not. context%storage%model%physics%ecmwf_physics%lagphy) return
    if (context%storage%model%physics%phy%lmphys .or. context%storage%model%physics%arpege_physics%lmse) return
    if (context%storage%model%physics%wave_coupling%lwcou) return
    if (context%storage%model%climate%lmcc04 .or. context%storage%model%climate%lnemocoup .or. context%excluded%lchem_dia) return
    if (context%excluded%lstoph_casbs .or. context%excluded%lstoph_spbs) return
    if (context%excluded%ljcdfi .or. context%loop_data%lecv .or. context%loop_data%lmoderr) return
    if (context%excluded%ldfi .or. context%excluded%lscrini .or. .not. context%excluded%locedelay) return
    if (context%loop_data%lejk .or. context%loop_data%lgwdiags_on .or. context%loop_data%lvareps) return
    if (context%loop_data%nrsaccfrq /= 0 .or. context%excluded%nsim4d /= 0) return
    if (context%norm_budget < 1 .or. context%mass_budget < 1) return
    if (.not. associated(context%fullpos) .or. .not. associated(context%fullpos_data) .or. .not. associated(context%output)) return
    if (context%fullpos%yfpcnt%nfpconf /= 0 .or. context%fullpos%yfpgeometry%lfposhor) return
    if (.not. associated(context%step%scan)) return
    if (.not. associated(context%output, context%step%scan%output%driver)) return
    if (.not. associated(context%physical_count) .or. .not. associated(context%physical_codes)) return
    if (context%input%lagrangian%lmascor) then
      if (.not. associated(context%spectral_layout) .or. .not. associated(context%map_factor)) return
    end if
    valid = .true.
  end function
  !> Public timing service; omitted optional integer/vector/CPU slots stay absent.
  subroutine user_clock_at_visit(value)
    real(real64), intent(out) :: value
    interface
      subroutine user_clock(pelapsed_time, knsec, pvector_cp, ptotal_cp)
        import :: int32, real64
        real(real64), optional, intent(out) :: pelapsed_time, pvector_cp, ptotal_cp
        integer(int32), optional, intent(out) :: knsec
      end subroutine
    end interface
    call user_clock(pelapsed_time=value)
  end subroutine
  integer(int32) function release_native_forecast_events(context) result(status)
    type(native_forecast_loop_context), intent(inout) :: context
    status = release_runtime_forecast_events(context%events)
  end function
  integer(int64) function forecast_loop_completed_count(context) result(value)
    type(native_forecast_loop_context), intent(in) :: context
    value = context%completed
  end function
end module forecast_native_time_loop
