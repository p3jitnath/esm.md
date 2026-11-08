!> Execute one complete STEPO call through concrete native providers.
!! All scientific arrays remain in the canonical model and field owners.
module forecast_native_time_step
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double
  use mpi_f08
  use yomhook, only: lhook, dr_hook
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_implicit_time_weights, only: native_implicit_time_weight_state
  use forecast_native_loop_data, only: native_loop_data
  use forecast_native_grid_scan, only: native_forecast_grid_scan_context, scan2m
  use md2asm_model_transform_callers, only: model_transform_context, model_transform_state, &
                                            transform_inverse_high_level, transform_direct_high_level
  use forecast_selected_output_controllers, only: native_output_controller_policy, run_runtime_forecast_file_control
  use forecast_spectral_calculation_driver, only: native_spectral_calculation_context, &
                                                  native_spectral_calculation_fields, advance_spectral_calculations
  use md2asm_transform_profile_policy, only: transform_profile_policy, transform_profile_event, increment_source_counter
  implicit none
  private
  public :: native_forecast_step_context, native_step_excluded_controls, native_step_transform_flags
  public :: bind_forecast_step_context, advance_forecast_step, advance_selected_forecast_step
  public :: forecast_step_completed_count
  !> Borrow source controls for branches excluded by the generated STEPO entry.
  !! These fields require their actual producer; this record provides no defaults.
  !! NSITER is a dimensionless implicit-iteration count. The other fields are
  !! dimensionless source logical switches, stored as ordinary Fortran values.
  type :: native_step_excluded_controls
    logical :: lnsponge, lspsdt, lspp, lrddhdyn, lrhdddh, lsidg, lstrhd
    integer(int32) :: nsiter
  end type
  !> Source TRANSINVH requests, bound by the real model setup and field metadata.
  !! No derivative is produced or omitted by a verification adapter.
  type :: native_step_transform_flags
    logical :: rayleigh
  end type
  !> Borrow stable targets through one native step, without another model owner.
  !! RSTART,RVSTART,RTIMEF are source timing values in seconds. Their ordered
  !! differences and additions do not enter any weather field.
  type :: native_forecast_step_context
    type(native_operational_model_configuration), pointer :: model => null()
    type(native_forecast_grid_scan_context), pointer :: scan => null()
    type(model_transform_context), pointer :: transform => null()
    type(model_transform_state), pointer :: transform_fields => null()
    type(native_spectral_calculation_context), pointer :: spectral => null()
    type(native_spectral_calculation_fields), pointer :: spectral_fields => null()
    type(native_step_excluded_controls), pointer :: excluded => null()
    type(native_step_transform_flags), pointer :: inverse_flags => null()
    type(native_implicit_time_weight_state), pointer :: implicit_weights => null()
    type(native_loop_data), pointer :: loop_data => null()
    type(native_output_controller_policy) :: output
    type(transform_profile_policy) :: profile
    real(real64) :: rstart = 0.0_real64, rvstart = 0.0_real64, rtimef = 0.0_real64
    integer(int32) :: report_unit = 6
    integer(int64) :: completed = 0_int64, stage_calls(4) = 0_int64
  end type
  interface
    subroutine user_clock(pelapsed_time, knsec, pvector_cp, ptotal_cp)
      import :: int32, real64
      real(real64), optional, intent(out) :: pelapsed_time, pvector_cp, ptotal_cp
      integer(int32), optional, intent(out) :: knsec
    end subroutine
    real(c_double) function public_step_log10(value) bind(C, name="log10")
      import :: c_double
      real(c_double), value :: value
    end function
  end interface
contains
  !> Bind only existing model, scan, transform and coupled spectral targets.
  !! EXCLUDED and INVERSE_FLAGS are immutable source-produced controls. The
  !! caller retains every target until the final dependent step is released.
  integer(int32) function bind_forecast_step_context(context, model, scan, transform, transform_fields, &
                                     spectral, spectral_fields, excluded, inverse_flags, implicit_weights, loop_data) result(status)
    type(native_forecast_step_context), intent(inout) :: context
    type(native_operational_model_configuration), target, intent(inout) :: model
    type(native_forecast_grid_scan_context), target, intent(inout) :: scan
    type(model_transform_context), target, intent(inout) :: transform
    type(model_transform_state), target, intent(inout) :: transform_fields
    type(native_spectral_calculation_context), target, intent(inout) :: spectral
    type(native_spectral_calculation_fields), target, intent(inout) :: spectral_fields
    type(native_step_excluded_controls), target, intent(in) :: excluded
    type(native_step_transform_flags), target, intent(in) :: inverse_flags
    type(native_implicit_time_weight_state), target, intent(in) :: implicit_weights
    type(native_loop_data), target, intent(inout) :: loop_data
    status = 2
    if (associated(context%model) .or. associated(context%scan)) return
    if (.not. model%ready .or. .not. associated(model%initial)) return
    if (.not. associated(scan%model, model) .or. .not. implicit_weights%ready) return
    context%model => model; context%scan => scan
    context%transform => transform; context%transform_fields => transform_fields
    context%spectral => spectral; context%spectral_fields => spectral_fields
    context%excluded => excluded; context%inverse_flags => inverse_flags
    context%implicit_weights => implicit_weights; context%loop_data => loop_data
    status = 0
  end function
  !> Preserve the old one-process,25-step admission separately from live bounds.
  integer(int32) function advance_selected_forecast_step(context, configuration, failed_stage) result(status)
    type(native_forecast_step_context), target, intent(inout) :: context
    character(*), intent(in) :: configuration
    integer(int32), intent(out) :: failed_stage
    failed_stage = 0; status = 2
    if (.not. associated(context%model)) return
    if (.not. associated(context%model%initial)) return
    if (context%model%initial%geometry%transform_control%nproc /= 1) return
    if (context%model%initial%controls%clock%integration%total_steps /= 25) return
    status = advance_forecast_step(context, configuration, failed_stage)
  end function
  !> Execute IOPACK,TRANSINVH,SCAN2M,TRANSDIRH and SPCM in source order.
  !! CONFIGURATION is exactly nine source characters. A late child failure
  !! leaves a partial weather step and is fatal to the enclosing loop. STATUS
  !! is0 only after every stage succeeds. FAILED_STAGE is0 for admission and
  !! then1:5 for these five child calls; no complete-step counter changes on
  !! failure. The runtime extension uses live world1:32 and NSTART0,NSTOP1:576.
  integer(int32) function advance_forecast_step(context, configuration, failed_stage) result(status)
    type(native_forecast_step_context), target, intent(inout) :: context
    character(*), intent(in) :: configuration
    integer(int32), intent(out) :: failed_stage
    integer(int32) :: step, stop, digits, child, scan_stage, io_status
    logical :: post_output, step_grid_fields, digital_filter_step
    real(real64) :: wall, vector, total, hook_handle
    status = 2; failed_stage = 0
    if (.not. step_context_ready(context, configuration)) return
    step = context%model%initial%controls%clock%current_step
    stop = context%model%initial%controls%clock%integration%total_steps
    call transform_profile_event('STEPO', 0_int32, hook_handle, context%profile)
    call user_clock(pelapsed_time=wall, pvector_cp=vector, ptotal_cp=total)
    total = total - context%rstart
    context%rstart = context%rstart + total
    vector = vector - context%rvstart
    context%rvstart = context%rvstart + vector
    wall = wall - context%rtimef
    context%rtimef = context%rtimef + wall
    digits = int(public_step_log10(real(max(stop, 1_int32), real64)), int32) + 1_int32
    if (digits < 1 .or. digits > 3) return
    write (context%report_unit, '(" NSTEP =",I6," STEPO   ",A9)', iostat=io_status) step, configuration
    if (io_status /= 0) then
      status = 3
      return
    end if
    ! The source LOPDIS branch changes text only. Use named local values and
    ! the same source position instead of an original OpenIFS logging entry.
    if (context%model%initial%controls%namespace%lopdis /= 0) then
      write (context%report_unit, '(" STEPO CPU/vector/wall seconds ",3ES24.16)', iostat=io_status) total, vector, wall
      if (io_status /= 0) then
        status = 3
        return
      end if
    end if
    if (configuration(1:1) /= '0') then
      failed_stage = 1
      context%output%nconf = context%model%initial%controls%namespace%nconf
      context%output%nproc = context%model%initial%geometry%transform_control%nproc
      context%output%lelam = context%model%initial%controls%namespace%lelam /= 0
      context%output%larpegef = context%model%initial%controls%namespace%larpegef /= 0
      context%output%hook_enabled = lhook
      status = run_runtime_forecast_file_control(context%output, configuration(1:1))
      if (status /= 0) return
    end if
    failed_stage = 2
    context%transform%step = step
    post_output = associated(context%scan%output%fields) .and. associated(context%scan%output%buffer)
    call transform_inverse_high_level(context%transform, context%transform_fields, configuration, &
                             context%model%initial%controls%namespace%nconf, context%model%initial%controls%namespace%lecmwf /= 0, &
                                      context%model%dynamics%lslag, context%model%field_dimensions%lader, &
                                      context%model%field_dimensions%lvor, context%model%field_dimensions%luvder, &
                                      context%inverse_flags%rayleigh, child, post_output, public_transform_profile)
    status = child
    if (status /= 0) return
    call increment_source_counter(context%stage_calls(1))
    failed_stage = 3
    step_grid_fields = configuration(7:8) /= '00'
    digital_filter_step = configuration(7:7) == 'D'
    status = scan2m(context%scan, configuration, step_grid_fields, digital_filter_step, context%excluded%nsiter, scan_stage)
    if (status /= 0) return
    call increment_source_counter(context%stage_calls(2))
    failed_stage = 4
  call transform_direct_high_level(context%transform, context%transform_fields, configuration(8:8), child, public_transform_profile)
    status = child
    if (status /= 0) return
    call increment_source_counter(context%stage_calls(3))
    failed_stage = 5
    ! Refresh source control snapshots after the grid call,using its reached
    ! canonical state. Scientific coefficient arrays remain their real owners.
    context%spectral%vertical_chunk = context%model%initial%geometry%dimensions%nproma
    context%spectral%implicit_coefficients%implicit_coefficient = context%implicit_weights%rbts2
    context%spectral%pressure%beta_time = context%implicit_weights%rbts2
    context%spectral%implicit_coefficients%time_coefficient = &
      context%model%initial%controls%clock%integration%second_dt
    context%spectral%pressure%time_step = context%model%initial%controls%clock%integration%second_dt
    context%spectral%ncurrent_iter = context%scan%input%lagrangian%ncurrent_iter
    context%spectral%nsiter = context%excluded%nsiter
    context%spectral%lsidg = context%excluded%lsidg
    context%spectral%lr3d = context%model%initial%controls%namespace%lr3d /= 0
    context%spectral%limpf = context%scan%input%lagrangian%limpf
    context%spectral%lnhdyn = context%model%dynamics%lnhdyn
    context%spectral%lmascor = context%scan%input%lagrangian%lmascor
    context%spectral%lgradsp = context%model%dynamics%lgradsp
    context%spectral%lrsiddh = context%model%lrsiddh
    status = advance_spectral_calculations(context%spectral, context%spectral_fields, configuration(9:9), context%profile)
    if (status /= 0) return
    call increment_source_counter(context%stage_calls(4))
    call transform_profile_event('STEPO', 1_int32, hook_handle, context%profile)
    call increment_source_counter(context%completed)
    failed_stage = 0; status = 0
  end function
  !> Validate all excluded source branches before timing or a weather mutation.
  logical function step_context_ready(context, configuration) result(valid)
    type(native_forecast_step_context), intent(in) :: context
    character(*), intent(in) :: configuration
    integer(int32) :: step, stop, world
    valid = .false.
    if (len(configuration) /= 9) return
    if (index('A0', configuration(1:1)) == 0) return
    if (configuration(2:9) /= 'AAA00AAA') return
    if (.not. associated(context%model) .or. .not. associated(context%scan)) return
    if (.not. associated(context%transform) .or. .not. associated(context%transform_fields)) return
    if (.not. associated(context%spectral) .or. .not. associated(context%spectral_fields)) return
    if (.not. associated(context%spectral%pressure)) return
    if (.not. associated(context%excluded) .or. .not. associated(context%inverse_flags)) return
    if (.not. associated(context%implicit_weights)) return
    if (.not. context%implicit_weights%ready) return
    if (.not. context%model%ready .or. .not. associated(context%model%initial)) return
    if (.not. associated(context%scan%model, context%model)) return
    if (.not. context%model%initial%ready .or. .not. allocated(context%model%initial%geometry)) return
    if (context%model%initial%controls%namespace%nconf /= 1) return
    if (context%model%initial%controls%namespace%lelam /= 0 .or. context%model%initial%controls%namespace%lr2d /= 0) return
    if (.not. associated(context%loop_data)) return
    if (context%loop_data%lrlxg .or. context%loop_data%liau) return
    world = context%model%initial%geometry%transform_control%nproc
    if (world < 1 .or. world > 32) return
    if (context%excluded%lnsponge .or. context%excluded%lspsdt .or. context%excluded%lspp) return
    if (context%excluded%nsiter /= 0) return
    if (context%excluded%lrddhdyn .or. context%model%lrsiddh .or. context%excluded%lrhdddh) return
    if (context%model%initial%controls%clock%integration%first_step /= 0) return
    stop = context%model%initial%controls%clock%integration%total_steps
    step = context%model%initial%controls%clock%current_step
    if (stop < 1 .or. stop > 576 .or. step < 0 .or. step >= stop) return
    if (context%report_unit < 0) return
    valid = .true.
  end function
  !> Fixed public profiling bridge; it supplies no numerical stage or state.
  subroutine public_transform_profile(name, phase, handle)
    character(*), intent(in) :: name
    integer(int32), intent(in) :: phase
    real(real64), intent(inout) :: handle
    if (lhook) call dr_hook(name, phase, handle)
  end subroutine
  integer(int64) function forecast_step_completed_count(context) result(value)
    type(native_forecast_step_context), intent(in) :: context
    value = context%completed
  end function
end module forecast_native_time_step
