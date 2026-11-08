!> Own output switches and select the ordered forecast stages.
!! Times are in seconds. Integer switches use zero for false and one for true.
!! The caller supplies nearest-even rounding and gradual underflow, and owns
!! disjoint native inputs and output. No original model record is imported.
module forecast_operational_policy
  use, intrinsic :: iso_c_binding
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
  public :: forecast_output_switches, forecast_schedule_namespace
  public :: forecast_schedule_controls, forecast_stage_decision
  public :: initialize_forecast_switches, initialize_owned_forecast_switches
  public :: select_forecast_stage, owned_forecast_schedule
  type, bind(c) :: forecast_output_switches
    integer(c_int32_t) :: n1pos = 0, n1his = 0, n1gdi = 0, n1sdi = 0, n1dhp = 0
    integer(c_int32_t) :: n1res = 0, n1xfu = 0, n1dhfg = 0, n1dhfz = 0, n1dhfd = 0
    integer(c_int32_t) :: n1cfu = 0, n1sfxhis = 0, n1masscon = 0, lrfilaf = 0, lwrspec = 0
  end type
  type, bind(c) :: forecast_schedule_namespace
    type(forecast_output_switches) :: switches
    integer(c_int32_t) :: reserved = 0
  end type
  type(forecast_schedule_namespace), bind(c, name="md2asm_owned_forecast_schedule_native"), &
    protected, save :: owned_forecast_schedule
  type, bind(c) :: forecast_schedule_controls
    integer(c_int32_t) :: grib_file_count, start_step, stop_step
    integer(c_int32_t) :: single_interval_after_start, surface_history_enabled
    integer(c_int32_t) :: diagnostics_collection_enabled, diagnostic_print_enabled
    integer(c_int32_t) :: global_diagnostics_enabled, zonal_diagnostics_enabled
    integer(c_int32_t) :: regional_diagnostics_enabled, wave_collection_enabled
    ! Order: post-processing, history, surface history, grid norms, spectral
    ! norms, global, zonal, regional, printed diagnostics and mass correction.
    integer(c_int32_t) :: regular_frequency(10), explicit_date_count(10)
    real(c_double) :: timestep_seconds
  end type
  type, bind(c) :: forecast_stage_decision
    integer(c_int32_t) :: step = 0, stop_step = 0, postprocessing = 0, history = 0
    integer(c_int32_t) :: surface_history = 0, grid_norms = 0, spectral_norms = 0
    integer(c_int32_t) :: global_diagnostics = 0, zonal_diagnostics = 0
    integer(c_int32_t) :: regional_diagnostics = 0, diagnostic_printing = 0, mass_correction = 0
    real(c_double) :: interval_seconds = 0.0_c_double, event_seconds = 0.0_c_double
    character(kind=c_char) :: stage_code(9) = c_null_char, padding(7) = c_null_char
    integer(c_int32_t) :: output_active = 0, collection_active = 0, reserved(2) = 0
  end type
contains
  !> Initialise the fifteen named SUCT1 switches from an empty NAMCT1 group.
  !! text is a bounded character input of at most 262,144 bytes. grib_file_count
  !! is 0 through 2; arpege_format is 0 or 1. On refusal, result retains all input bytes.
  !! No floating-point operation, formatted input or heap allocation is used.
  integer(c_int32_t) function initialize_forecast_switches(result, text, grib_file_count, arpege_format) result(status)
    type(forecast_output_switches), intent(inout) :: result
    character(len=*), intent(in) :: text
    integer(c_int32_t), intent(in) :: grib_file_count, arpege_format
    type(forecast_output_switches) :: work
    status = 2_c_int32_t
    if (grib_file_count < 0 .or. grib_file_count > 2) return
    if (arpege_format < 0 .or. arpege_format > 1) return
    if (require_empty_physics_group(text, 'NAMCT1') /= 0_c_int32_t) return
    work%n1pos = 1
    work%n1his = 1
    work%n1gdi = 1
    work%n1sdi = 1
    work%n1dhp = 1
    work%n1res = 1
    work%n1xfu = 1
    work%n1dhfg = 1
    work%n1dhfz = 1
    work%n1dhfd = 1
    work%n1cfu = 1
    work%n1sfxhis = 0
    work%n1masscon = 1
    work%lrfilaf = 0
    if (grib_file_count == 0) work%lrfilaf = arpege_format
    work%lwrspec = 1
    result = work
    status = 0_c_int32_t
  end function

  !> Initialise owned switch storage while preserving its reserved final word.
  !! This module supplies native storage. It declares no original GNU aliases.
  integer(c_int32_t) function initialize_owned_forecast_switches(text, grib_file_count, arpege_format) result(status)
    character(len=*), intent(in) :: text
    integer(c_int32_t), intent(in) :: grib_file_count, arpege_format
    status = initialize_forecast_switches(owned_forecast_schedule%switches, text, grib_file_count, arpege_format)
  end function

  !> Select one admitted operational visit from its actual current step.
  !! controls contains frequencies and source enable conditions; switches owns
  !! the named output flags. step is 0 through 8 and fullpos_eligible is 0 or 1.
  !! The selected route has start step 0, stop step 8, a 450 s time interval and no explicit dates.
  !! output is a complete 96-byte native C record and changes only on success.
  !! The output code keeps collection active at the closing visit when needed.
  integer(c_int32_t) function select_forecast_stage(controls, switches, step, fullpos_eligible, output) &
    bind(c, name="md2asm_select_forecast_stage_fortran") result(status)
    type(forecast_schedule_controls), intent(in) :: controls
    type(forecast_output_switches), intent(in) :: switches
    integer(c_int32_t), value :: step, fullpos_eligible
    type(forecast_stage_decision), intent(inout) :: output
    type(forecast_stage_decision) :: work
    integer(c_int32_t) :: model_enables(8), consumed_switches(6), enabled(10), selected(10)
    integer :: j
    real(c_double) :: event_time, interval
    status = 2_c_int32_t
    if (controls%grib_file_count /= 1) return
    if (controls%start_step /= 0 .or. controls%stop_step /= 8) return
    if (step < 0 .or. step > controls%stop_step) return
    if (fullpos_eligible < 0 .or. fullpos_eligible > 1) return
    if (transfer(controls%timestep_seconds, 0_c_int64_t) /= transfer(450.0_c_double, 0_c_int64_t)) return
    model_enables = [controls%single_interval_after_start, controls%surface_history_enabled, &
                     controls%diagnostics_collection_enabled, controls%diagnostic_print_enabled, &
                     controls%global_diagnostics_enabled, controls%zonal_diagnostics_enabled, &
                     controls%regional_diagnostics_enabled, controls%wave_collection_enabled]
    if (any(model_enables < 0) .or. any(model_enables > 1)) return
    if (any(controls%regular_frequency < 1) .or. any(controls%regular_frequency > 999999)) return
    if (any(controls%explicit_date_count /= 0)) return
    consumed_switches = [switches%n1pos, switches%n1his, switches%n1sfxhis, &
                         switches%n1gdi, switches%n1sdi, switches%n1masscon]
    if (any(consumed_switches < 0) .or. any(consumed_switches > 1)) return
    enabled(1) = switches%n1pos
    enabled(2) = switches%n1his
    enabled(3) = iand(switches%n1sfxhis, controls%surface_history_enabled)
    enabled(4) = switches%n1gdi
    enabled(5) = switches%n1sdi
    enabled(6) = iand(controls%diagnostics_collection_enabled, controls%global_diagnostics_enabled)
    enabled(7) = iand(controls%diagnostics_collection_enabled, controls%zonal_diagnostics_enabled)
    enabled(8) = iand(controls%diagnostics_collection_enabled, controls%regional_diagnostics_enabled)
    enabled(9) = iand(controls%diagnostics_collection_enabled, controls%diagnostic_print_enabled)
    enabled(10) = switches%n1masscon
    do j = 1, 10
      selected(j) = 0_c_int32_t
      if (mod(step, controls%regular_frequency(j)) == 0) selected(j) = enabled(j)
    end do
    if (controls%regular_frequency(10) > controls%stop_step) selected(10) = 0_c_int32_t
    work%step = step
    work%stop_step = controls%stop_step
    work%postprocessing = selected(1)
    work%history = selected(2)
    work%surface_history = selected(3)
    work%grid_norms = selected(4)
    work%spectral_norms = selected(5)
    work%global_diagnostics = selected(6)
    work%zonal_diagnostics = selected(7)
    work%regional_diagnostics = selected(8)
    work%diagnostic_printing = selected(9)
    work%mass_correction = selected(10)
    interval = controls%timestep_seconds
    if (step /= 0 .and. controls%single_interval_after_start == 0) interval = 2.0_c_double*interval
    work%interval_seconds = interval
    event_time = real(step, c_double)
    event_time = event_time*controls%timestep_seconds
    event_time = event_time + 0.5_c_double
    work%event_seconds = event_time
    work%output_active = iand(fullpos_eligible, work%postprocessing)
    work%collection_active = ior(controls%diagnostics_collection_enabled, controls%wave_collection_enabled)
    work%stage_code = '0'
    if (work%history /= 0) then
      work%stage_code(1) = 'A'
      if (work%surface_history /= 0) work%stage_code(1) = 'Q'
    else
      if (work%surface_history /= 0) work%stage_code(1) = 'S'
    end if
    if (step < controls%stop_step) then
      work%stage_code(2:4) = 'A'
      work%stage_code(7:9) = 'A'
    else
      if (ior(work%collection_active, work%output_active) /= 0) work%stage_code(2:4) = 'A'
    end if
    output = work
    status = 0_c_int32_t
  end function
end module
