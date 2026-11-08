!> Preserve the selected CPG_DRV block order and complete native column calls.
module forecast_grid_point_block_driver_strided
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_int
  use yomphy2, only: tphy2
  use forecast_grid_point_update_strided, only: grid_point_update_controls, grid_point_column_views, update_grid_point_column
  use md2asm_moist_air_gas_properties, only: moist_air_constants, thermal_constituent
  use md2asm_lagrangian_work_initialization, only: lagrangian_component
  use md2asm_two_part_time_filter, only: filter_field_pair
  use forecast_physics_tendency_increment, only: physical_tracer_increment_map
  use md2asm_transport_equation_parent, only: transport_constituent
  use md2asm_departure_field_transport, only: constituent_transport_map
  use md2asm_vertical_operators, only: vertical_operator_matrices
  use md2asm_spectral_implicit_update, only: spectral_implicit_coefficients
  use forecast_grid_calculations, only: forecast_grid_vertical_inputs, forecast_grid_surface_map
  use forecast_hydrostatic_grid_calculations, only: hydrostatic_motion_map
  use md2asm_interpolation_boundary_values, only: interpolation_boundary_map
  use forecast_periodic_output_schedule_port, only: select_periodic_output
  use md2asm_transform_profile_policy, only: transform_profile_policy, transform_profile_event, increment_source_counter
  use forecast_lagged_grid_update, only: grid_update_environment_supported
  implicit none
  private
  public :: grid_point_block_controls, run_grid_point_blocks, grid_point_block_call_count
  integer(int64), save :: stage_calls(0:3) = 0_int64
  !> Actual current-step,source schedule and selected forecast configuration.
  !! model_interval is source TDT;schedule_time_step is immutable source TSTEP.
  !! Both are seconds;step counts and event indices are dimensionless.
  type :: grid_point_block_controls
    type(grid_point_update_controls) :: column
    character(len=1) :: configuration = ' '
    integer(int32) :: step = -1, first_step = -1, last_step = -1, reset_frequency = 0, reset_value = 0
    real(real64) :: model_interval = 0.0_real64, schedule_time_step = 0.0_real64, beta_time = 0.0_real64
    logical :: semi_lagrangian = .false., ecmwf_physics = .false., lagged_physics = .false., split_physics = .false.
    logical :: full_corrector = .false., cheap_corrector = .false.
    logical :: gust_reset = .false., visibility_reset = .false., precipitation_reset = .false., mean_wind = .false.
    logical :: transport_statistics = .false., mixed_extrapolation_statistics = .false.
  end type
  interface
    subroutine public_grid_statistics(event, phase) bind(C, name="gstats_")
      import c_int
      integer(c_int), intent(in) :: event, phase
    end subroutine
  end interface
contains
  !> Update the flux-reset event,then visit every live block in ascending order.
  !!
  !! columns(:) borrows each block's real field and workspace views. No driver
  !! prepares a numerical tendency,pressure value or interpolation stage.
  !! All metadata tables/component maps retain their original source order.
  !! transport_components(component,block) borrows each block's actual aliases.
  !! counters(level,block) is the original KSETTLOFF owner;each complete active
  !! level column is cleared immediately before its own CPG call.
  !!
  !! The retained generated body is P24,L19,N2048,B86. Native bounds follow
  !! the complete column provider(P1:256,L4:256),with B=ceiling(N/P).
  !! Other dimensions need independent complete-parent proof before selection.
  !! The last block uses its physical active prefix while preserving padding.
  !!
  !! reset_requests is the actual NRAZTS request vector. Optional reset_minutes
  !! preserves the full MONIO_T time selector with source TSTEP,not TDT. The one reset word represents
  !! index STEP/RESET_FREQUENCY,so both slice bounds use that quotient. This is
  !! the reviewed correction of the historical unequal-index source slice.
  !! Canonical select_periodic_output owns all event arithmetic unchanged.
  !! flux_reset is the only reset-control mutation. Physics TSPHY and field
  !! outputs change only through complete own column calls.
  !!
  !! The public FIAT statistics and hook interfaces are profiling services.
  !! Status0 completes all blocks,1 reports a child allocation failure and2
  !! refuses unsupported controls,shapes or a child. No numerical fallback,
  !! weather callback or original private model layout occurs.
  subroutine run_grid_point_blocks(c, pitch, levels, global_count, reset_requests, flux_reset, &
                                   constants, thermal_components, work_components, tracer_pairs, physics_components, &
                                   transport_components, boundary_components, tables, coef, vertical, surface_map, motion_map, &
                                  boundary_maps, core_index, physics_time, columns, counters, diagnostic_count, end_count, status, &
                                   reset_minutes, profile)
    type(grid_point_block_controls), intent(in) :: c
    integer(int32), intent(in) :: pitch, levels, global_count, reset_requests(:)
    logical, intent(inout) :: flux_reset
    type(moist_air_constants), intent(in) :: constants
    type(thermal_constituent), intent(in) :: thermal_components(:)
    type(lagrangian_component), intent(in) :: work_components(:)
    type(filter_field_pair), intent(in) :: tracer_pairs(:)
    type(physical_tracer_increment_map), intent(in) :: physics_components(:)
    type(transport_constituent), intent(inout) :: transport_components(:, :)
    type(constituent_transport_map), intent(in) :: boundary_components(:)
    type(vertical_operator_matrices), intent(in) :: tables
    type(spectral_implicit_coefficients), intent(in) :: coef
    type(forecast_grid_vertical_inputs), intent(in) :: vertical
    type(forecast_grid_surface_map), intent(in) :: surface_map
    type(hydrostatic_motion_map), intent(in) :: motion_map
    type(interpolation_boundary_map), intent(in) :: boundary_maps
    integer(int32), intent(in) :: core_index(:)
    type(tphy2), intent(inout) :: physics_time
    type(grid_point_column_views), intent(inout) :: columns(:)
    integer(int32), intent(inout) :: counters(:, :)
    integer(int64), intent(inout) :: diagnostic_count, end_count
    integer(int32), intent(out) :: status
    integer(int32), intent(in), optional :: reset_minutes(:)
    type(transform_profile_policy), intent(in), optional :: profile
    type(grid_point_update_controls) :: local
    integer(int32) :: reset_word(1), reset_index, first_global, block, blocks, level
    integer(c_int) :: statistics_event, statistics_phase
    integer(int64) :: wide_blocks
    real(real64) :: profile_handle, selector_handle, pointer_handle
    status = 2
    if (pitch < 1 .or. pitch > 256 .or. levels < 4 .or. levels > 256 .or. global_count < 1) return
    wide_blocks = (int(global_count, int64) + int(pitch, int64) - 1_int64)/int(pitch, int64)
    if (wide_blocks < 1 .or. wide_blocks > 1000000_int64) return
    blocks = int(wide_blocks, int32)
    if (size(columns) /= blocks .or. size(transport_components, 2) /= blocks) return
    if (size(counters, 1) /= levels .or. size(counters, 2) /= blocks) return
    if (size(core_index) < global_count) return
    if (c%configuration /= 'A' .and. c%configuration /= 'B') return
    if (c%step < 0 .or. c%first_step < 0 .or. c%last_step < c%step .or. c%step < c%first_step) return
    if (c%last_step > 1000000 .or. c%reset_frequency < 1) return
    if (.not. c%semi_lagrangian .or. .not. c%ecmwf_physics .or. .not. c%lagged_physics .or. .not. c%split_physics) return
    if (c%full_corrector .or. c%cheap_corrector) return
    if (c%gust_reset .or. c%visibility_reset .or. c%precipitation_reset .or. c%mean_wind) return
    if (c%transport_statistics .or. c%mixed_extrapolation_statistics) return
    if (c%column%current_iteration /= 0) return
    if (.not. grid_update_environment_supported()) return
    local = c%column
    local%first_step = c%step <= 0
    local%grid%first_step = local%first_step
    local%split_physics = .true.; local%use_first_buffer = .true.
    local%time_step = c%model_interval; local%model_interval = c%model_interval
    local%physics_interval = c%model_interval; local%beta_time = c%beta_time
    local%grid%update_factor = 1.0_real64
    reset_index = c%step/c%reset_frequency
    call transform_profile_event("CPG_DRV", 0_int32, profile_handle, profile)
    call transform_profile_event("MONIO_T", 0_int32, selector_handle, profile)
    call select_periodic_output(reset_index, c%first_step, c%last_step, c%schedule_time_step, reset_word, &
                                c%reset_value, c%reset_frequency, reset_requests, status, reset_minutes)
    call transform_profile_event("MONIO_T", 1_int32, selector_handle, profile)
    if (status /= 0) goto900
    call increment_source_counter(stage_calls(2))
    flux_reset = local%first_step .or. (reset_word(1) == 1 .and. mod(c%step, c%reset_frequency) == 0)
    statistics_event = 1025_c_int; statistics_phase = 0_c_int
    call public_grid_statistics(statistics_event, statistics_phase)
    do block = 1, blocks
      first_global = 1 + (block - 1)*pitch
      do level = 1, levels
        counters(level, block) = 0_int32
      end do
      call transform_profile_event("SC2PRG_MOD:SC2PRG", 0_int32, pointer_handle, profile)
      call transform_profile_event("SC2PRG_MOD:SC2PRG", 1_int32, pointer_handle, profile)
      call increment_source_counter(stage_calls(3))
      call transform_profile_event("SC2PRG_MOD:SC2PRG", 0_int32, pointer_handle, profile)
      call transform_profile_event("SC2PRG_MOD:SC2PRG", 1_int32, pointer_handle, profile)
      call increment_source_counter(stage_calls(3))
      call update_grid_point_column(local, pitch, levels, global_count, first_global, constants, thermal_components, &
             work_components, tracer_pairs, physics_components, transport_components(:, block), boundary_components, tables, coef, &
                   vertical, surface_map, motion_map, boundary_maps, core_index, physics_time, columns(block), counters(:, block), &
                                    diagnostic_count, end_count, status, profile)
      if (status /= 0) exit
      call increment_source_counter(stage_calls(1))
    end do
    statistics_phase = 1_c_int
    call public_grid_statistics(statistics_event, statistics_phase)
    if (status == 0) call increment_source_counter(stage_calls(0))
900 continue
    call transform_profile_event("CPG_DRV", 1_int32, profile_handle, profile)
  end subroutine

  integer(int64) function grid_point_block_call_count(index) result(value)
    integer, intent(in) :: index
    value = 0_int64
    if (index >= 0 .and. index <= 3) value = stage_calls(index)
  end function
end module forecast_grid_point_block_driver_strided
