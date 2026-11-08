!> Run the selected CPG column update through complete own native children.
module forecast_grid_point_update
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_int, c_int64_t
  use yomphy2, only: tphy2
  use md2asm_moist_air_gas_properties, only: moist_air_constants, thermal_constituent
  use md2asm_two_part_time_filter, only: filter_field_pair
  use md2asm_vertical_operators, only: vertical_operator_matrices
  use md2asm_spectral_implicit_update, only: spectral_implicit_coefficients
  use md2asm_lagrangian_work_initialization, only: lagrangian_component, lagrangian_source_fields, lagrangian_work_fields
  use md2asm_lagrangian_grid_update, only: lagrangian_grid_controls, lagrangian_linear_inputs
  use md2asm_trajectory_wind_preparation, only: trajectory_wind_outputs
  use md2asm_transport_equation_parent, only: transport_parent_fields, transport_constituent
  use md2asm_surface_pressure_transport, only: surface_pressure_transport_fields
  use md2asm_interpolation_boundary_values, only: interpolation_boundary_map
  use md2asm_departure_field_transport, only: constituent_transport_map
  use forecast_grid_calculations, only: forecast_grid_calculation_controls, forecast_grid_vertical_inputs, &
                                        forecast_grid_surface_map, compute_forecast_grid_calculations
  use forecast_hydrostatic_grid_calculations, only: hydrostatic_motion_map, hydrostatic_grid_outputs, &
                          native_hydrostatic_pressure_terms, allocate_hydrostatic_pressure_terms, release_hydrostatic_pressure_terms
  use forecast_grid_point_dynamics_caller, only: gridpoint_dynamics_caller_controls, compute_gridpoint_dynamics
  use forecast_grid_point_diagnostic_caller, only: native_grid_diagnostic_controls, cpg_dia
  use forecast_grid_point_end_caller, only: native_grid_end_controls, cpg_end
  use forecast_physics_interval_controller, only: apply_lagged_physics_increment
  use forecast_physics_tendency_increment, only: saved_physics_tendency_indices, physical_tracer_increment_map
  use md2asm_transform_profile_policy, only: transform_profile_policy, transform_profile_event, increment_source_counter
  use forecast_lagged_grid_update, only: grid_update_environment_supported
  implicit none
  private
  public :: grid_point_update_controls, grid_point_column_views, update_grid_point_column
  public :: grid_point_update_call_count, grid_point_update_stage_count
  integer(int64), save :: completed_calls = 0_int64
  integer(int64), save :: returned_stage_calls(1:5) = 0_int64
  !> Values come from initialized grid,model,clock and buffer-map owners.
  !! Intervals are seconds;slot values are one-based native field positions.
  type :: grid_point_update_controls
    type(forecast_grid_calculation_controls) :: grid
    type(gridpoint_dynamics_caller_controls) :: dynamics
    type(lagrangian_grid_controls) :: lagrangian
    type(native_grid_diagnostic_controls) :: diagnostic
    type(native_grid_end_controls) :: finish
    type(saved_physics_tendency_indices) :: saved_indices
    integer(int32) :: first_fields = 0, input_first_level = 0, input_last_level = 0
    integer(int32) :: physics_u = 0, physics_v = 0, physics_t = 0, physics_tracers = 0
    integer(int32) :: current_iteration = 0, last_iteration = 0
    real(real64) :: time_step = 0.0_real64, beta_time = 0.0_real64
    real(real64) :: model_interval = 0.0_real64, physics_interval = 0.0_real64
    logical :: first_step = .false., use_first_buffer = .false., split_physics = .false.
    logical :: full_corrector = .false., rhs_curvature = .false., reuse_pressure = .false.
    logical :: diabatic = .false., limited_area_tendencies = .false., extra_diagnostics = .false.
    logical :: trajectory_diagnostics = .false., surface_flux_diagnostics = .false.
  end type
  !> Borrow real native field owners and column workspace without copying them.
  !! P is the column capacity,L the layer count,F a live field count.
  !! motion(P,L,F),surface(P,1,F),tracers(P,L,F) keep their full owners.
  !! first_buffer(P,F1) is private column workspace;global_first_buffer(R,F1)
  !! is the interpolation owner indexed by the native NSLCORE map.
  !! auxiliary(P,NGPAR+1) is the original private ZGPAR array.
  !! hydro and the two gradient pairs are workspace outputs of this parent.
  !! Child view records retain actual native buffer aliases and live bounds.
  !! They contain no prepared numerical result,private model offset or callback.
  !! Every target remains alive for the entire call. Input/output aliases must
  !! be exactly those in the original selected call;all other owners are disjoint.
  type :: grid_point_column_views
    real(real64), pointer, contiguous :: motion(:, :, :) => null(), surface(:, :, :) => null(), tracers(:, :, :) => null()
    real(real64), pointer, contiguous :: terrain(:) => null(), raw_terrain_x(:) => null(), raw_terrain_y(:) => null()
    real(real64), pointer, contiguous :: map_metric(:) => null(), coriolis(:) => null()
    real(real64), pointer, contiguous :: terrain_x(:) => null(), terrain_y(:) => null()
    real(real64), pointer, contiguous :: pressure_x(:) => null(), pressure_y(:) => null()
   real(real64), pointer, contiguous :: first_buffer(:, :) => null(), global_first_buffer(:, :) => null(), auxiliary(:, :) => null()
    real(real64), pointer, contiguous :: saved_tendencies(:, :, :) => null(), tracer_rates(:, :, :) => null()
    real(real64), pointer, contiguous :: eta(:) => null(), sin_latitude(:) => null(), cos_latitude(:) => null()
    real(real64), pointer, contiguous :: cos_longitude(:) => null(), sin_longitude(:) => null()
    real(real64), pointer, contiguous :: previous_eta_rate(:, :) => null()
    real(real64), pointer, contiguous :: full_level_correction(:) => null(), half_level_correction(:) => null()
    real(real64), pointer, contiguous :: layer_weight(:) => null(), inverse_eta_thickness(:) => null()
    real(real64), pointer, contiguous :: gm(:) => null(), extended_multiplier(:) => null()
    type(hydrostatic_grid_outputs) :: hydro
    type(lagrangian_source_fields) :: previous
    type(lagrangian_work_fields) :: work
    type(lagrangian_linear_inputs) :: linear
    type(trajectory_wind_outputs) :: wind
    type(transport_parent_fields) :: transport
    type(surface_pressure_transport_fields) :: surface_transport
  end type
contains
  !> Complete grid calculations,lagged physics,diagnostics,dynamics and PB1 copy.
  !!
  !! pitch1:256,levels4:256 and global counts are live integer dimensions.
  !! The frozen generated counterpart is pitch24,levels19,global_count2048.
  !! Other admitted dimensions are compiled extensions,not accepted forecasts.
  !! global_first starts a full-capacity block;the final block can be shorter.
  !! core_index(1:global_count) is the actual NSLCORE interpolation map.
  !! Eta and half-level corrections retain physical lower bound0.
  !!
  !! Wind is m/s,temperature K,pressure Pa and geopotential m**2/s**2.
  !! Saved tendencies are rates per second. model_interval is the actual TDT;
  !! physics_interval is the source PDTPHY. Neither is inferred from grid size.
  !! physics_time borrows the one canonical TPHY2 record;only TSPHY can change.
  !! Buffer field maps and all component records preserve source order.
  !!
  !! The caller allocates ordinary native column workspace and binds its views.
  !! This parent computes every scientific workspace output through own calls.
  !! It allocates and releases the five persistent pressure terms in source
  !! order. The original heap-frame byte layout is not part of this interface.
  !! Status0 completes the update,1 reports allocation failure and2 refuses a
  !! shape,control or child. A late refusal can follow source output mutation.
  subroutine update_grid_point_column(c, pitch, levels, global_count, global_first, &
                                      constants, thermal_components, work_components, tracer_pairs, physics_components, &
                                      transport_components, boundary_components, tables, coef, vertical, surface_map, motion_map, &
                             boundary_maps, core_index, physics_time, views, counters, diagnostic_count, end_count, status, profile)
    type(grid_point_update_controls), intent(in) :: c
    integer(int32), intent(in) :: pitch, levels, global_count, global_first
    type(moist_air_constants), intent(in) :: constants
    type(thermal_constituent), intent(in) :: thermal_components(:)
    type(lagrangian_component), intent(in) :: work_components(:)
    type(filter_field_pair), intent(in) :: tracer_pairs(:)
    type(physical_tracer_increment_map), intent(in) :: physics_components(:)
    type(transport_constituent), intent(inout) :: transport_components(:)
    type(constituent_transport_map), intent(in) :: boundary_components(:)
    type(vertical_operator_matrices), intent(in) :: tables
    type(spectral_implicit_coefficients), intent(in) :: coef
    type(forecast_grid_vertical_inputs), intent(in) :: vertical
    type(forecast_grid_surface_map), intent(in) :: surface_map
    type(hydrostatic_motion_map), intent(in) :: motion_map
    type(interpolation_boundary_map), intent(in) :: boundary_maps
    integer(int32), intent(in) :: core_index(:)
    type(tphy2), intent(inout) :: physics_time
    type(grid_point_column_views), intent(inout) :: views
    integer(int32), intent(inout) :: counters(:)
    integer(int64), intent(inout) :: diagnostic_count, end_count
    integer(int32), intent(out) :: status
    type(transform_profile_policy), intent(in), optional :: profile
    type(native_hydrostatic_pressure_terms) :: terms
    real(real64), pointer, contiguous :: physical_u(:, :), physical_v(:, :), physical_t(:, :), physical_tracers(:, :, :)
    integer :: i, field, active, stored, lower, upper, fields, slot
    integer(int64) :: last_global, need
    real(real64) :: profile_handle
    status = 2
    if (pitch < 1 .or. pitch > 256 .or. levels < 4 .or. levels > 256) return
    if (global_count < 1 .or. global_first < 1 .or. global_first > global_count) return
    if (mod(global_first - 1, pitch) /= 0) return
    if (c%first_fields < 1 .or. c%first_fields > 65536) return
    if (.not. c%use_first_buffer .or. .not. c%split_physics) return
    if (c%full_corrector .or. c%rhs_curvature .or. c%reuse_pressure) return
    if (c%diabatic .or. c%limited_area_tendencies .or. c%extra_diagnostics) return
    if (c%trajectory_diagnostics .or. c%surface_flux_diagnostics) return
    if (c%current_iteration < 0 .or. c%last_iteration < c%current_iteration) return
    if (c%grid%current_iteration /= c%current_iteration) return
    if (c%grid%first_step .neqv. c%first_step) return
    if (c%grid%hydrostatic%reuse_pressure) return
    if (c%lagrangian%wind%curved_rhs) return
    if (.not. grid_update_environment_supported()) return
    active = min(pitch, global_count - global_first + 1)
    last_global = int(global_first, int64) + int(active, int64) - 1_int64
    if (size(core_index, kind=int64) < last_global) return
    if (.not. views_supported(views, pitch, levels, c%first_fields)) return
    if (any(core_index(global_first:int(last_global)) < 1)) return
    if (any(core_index(global_first:int(last_global)) > size(views%global_first_buffer, 1))) return
    lower = c%input_first_level; upper = c%input_last_level
    if (lower > 1 .or. upper < levels) return
    if (int(upper, int64) - int(lower, int64) + 1_int64 > 1024_int64) return
    stored = upper - lower + 1
    if (stored < 1) return
    fields = 0
    if (associated(views%tracer_rates)) fields = size(views%tracer_rates, 3)
    if (fields < 0 .or. fields > 2163) return
    if (.not. c%first_step) then
      if (.not. associated(views%saved_tendencies) .or. .not. associated(views%tracer_rates)) return
    end if
    do i = 1, 4
      select case (i)
      case (1); slot = c%physics_u
      case (2); slot = c%physics_v
      case (3); slot = c%physics_t
      case (4); slot = c%physics_tracers
      end select
      need = int(slot, int64) + int(stored, int64) - 1_int64
      if (i == 4) need = int(slot, int64) + int(stored, int64)*int(fields, int64) - 1_int64
      if (slot < 1 .or. need > c%first_fields) return
    end do
    physical_u(1:pitch, lower:upper) => views%first_buffer(:, c%physics_u:c%physics_u + stored - 1)
    physical_v(1:pitch, lower:upper) => views%first_buffer(:, c%physics_v:c%physics_v + stored - 1)
    physical_t(1:pitch, lower:upper) => views%first_buffer(:, c%physics_t:c%physics_t + stored - 1)
    physical_tracers(1:pitch, lower:upper, 1:fields) => &
      views%first_buffer(:, c%physics_tracers:c%physics_tracers + stored*fields - 1)
    call transform_profile_event("CPG", 0_int32, profile_handle, profile)
    call allocate_hydrostatic_pressure_terms(terms, pitch, levels, status)
    if (status /= 0) goto900
    views%auxiliary = 0.0_real64
    call compute_forecast_grid_calculations(c%grid, surface_map, motion_map, pitch, 1_int32, int(active, int32), levels, &
                      tracer_pairs, constants, thermal_components, work_components, tables, vertical, views%motion, views%surface, &
                         views%tracers, views%terrain, views%raw_terrain_x, views%raw_terrain_y, views%map_metric, views%coriolis, &
       views%terrain_x, views%terrain_y, views%pressure_x, views%pressure_y, terms, views%hydro, views%previous, views%work, status)
    call increment_source_counter(returned_stage_calls(1))
    if (status /= 0) goto900
    do field = 1, c%first_fields
      do i = 1, active
        views%first_buffer(i, field) = 0.0_real64
      end do
    end do
    status = apply_lagged_physics_increment(c%first_step, pitch, levels, int(lower, int32), int(upper, int32), &
                                 1_int32, int(active, int32), c%model_interval, c%physics_interval, physics_time, c%saved_indices, &
               physics_components, views%saved_tendencies, views%tracer_rates, physical_u, physical_v, physical_t, physical_tracers)
    call increment_source_counter(returned_stage_calls(2))
    if (status /= 0) goto900
    if (c%current_iteration == 0) then
      call cpg_dia(c%diagnostic, c%diabatic, diagnostic_count, status, profile)
      call increment_source_counter(returned_stage_calls(3))
      if (status /= 0) goto900
    end if
    ! LATTEX consumes M_TNDU_NOC/M_TNDV_NOC and adds its own Coriolis term.
    call compute_gridpoint_dynamics(c%dynamics, pitch, levels, 1_int32, int(active, int32), &
                       1_int32, int(active, int32), c%beta_time, c%time_step, c%lagrangian, coef, tables, constants, views%linear, &
                                    views%tracers, thermal_components, views%eta, views%sin_latitude, views%cos_latitude, &
                                    views%cos_longitude, views%sin_longitude, views%hydro%continuity(:, :, 1), &
                                    views%hydro%pressure_weights(:, :, c%grid%hydrostatic%pressure_fields(2)), &
                                   views%previous_eta_rate, views%wind, counters, views%terrain, views%terrain_x, views%terrain_y, &
                                    views%full_level_correction, views%half_level_correction, &
                                    views%hydro%wind_u_no_coriolis, views%hydro%wind_v_no_coriolis, &
                                    views%hydro%temperature_rate, views%transport, transport_components, &
                                    views%hydro%continuity(:, levels, 4), views%hydro%half_pressure(:, levels), views%terrain, &
                     views%layer_weight, views%inverse_eta_thickness, views%surface_transport, boundary_maps, boundary_components, &
                                    views%first_buffer, status, views%gm, views%extended_multiplier, profile)
    call increment_source_counter(returned_stage_calls(4))
    if (status /= 0) goto900
    do field = 1, c%first_fields
      do i = 1, active
        views%global_first_buffer(core_index(global_first + i - 1), field) = views%first_buffer(i, field)
      end do
    end do
    call cpg_end(c%finish, c%limited_area_tendencies, c%diabatic, end_count, status, profile)
    call increment_source_counter(returned_stage_calls(5))
900 continue
    call release_hydrostatic_pressure_terms(terms)
    if (status == 0) call increment_source_counter(completed_calls)
    call transform_profile_event("CPG", 1_int32, profile_handle, profile)
  end subroutine

  logical function views_supported(v, p, l, f) result(ok)
    type(grid_point_column_views), intent(in) :: v
    integer, intent(in) :: p, l, f
    ok = .false.
    if (.not. associated(v%motion) .or. .not. associated(v%surface) .or. .not. associated(v%tracers)) return
    if (size(v%motion, 1) /= p .or. size(v%motion, 2) /= l) return
    if (size(v%surface, 1) /= p .or. size(v%surface, 2) /= 1) return
    if (size(v%tracers, 1) /= p .or. size(v%tracers, 2) /= l) return
    if (.not. associated(v%terrain) .or. .not. associated(v%raw_terrain_x) .or. .not. associated(v%raw_terrain_y)) return
    if (.not. associated(v%map_metric) .or. .not. associated(v%coriolis)) return
    if (.not. associated(v%terrain_x) .or. .not. associated(v%terrain_y)) return
    if (.not. associated(v%pressure_x) .or. .not. associated(v%pressure_y)) return
    if (.not. associated(v%first_buffer) .or. .not. associated(v%global_first_buffer) .or. .not. associated(v%auxiliary)) return
    if (size(v%first_buffer, 1) /= p .or. size(v%first_buffer, 2) < f) return
    if (size(v%global_first_buffer, 2) < f .or. size(v%auxiliary, 1) /= p) return
    if (.not. associated(v%eta) .or. .not. associated(v%sin_latitude) .or. .not. associated(v%cos_latitude)) return
    if (.not. associated(v%cos_longitude) .or. .not. associated(v%sin_longitude)) return
    if (.not. associated(v%previous_eta_rate)) return
    if (.not. associated(v%full_level_correction) .or. .not. associated(v%half_level_correction)) return
    if (.not. associated(v%layer_weight) .or. .not. associated(v%inverse_eta_thickness)) return
    if (lbound(v%eta, 1) /= 0 .or. ubound(v%eta, 1) < l) return
    if (lbound(v%half_level_correction, 1) /= 0 .or. ubound(v%half_level_correction, 1) < l) return
    ok = .true.
  end function

  integer(int64) function grid_point_update_call_count() result(value)
    value = completed_calls
  end function
  !> Read one source-stage counter without changing the numerical state.
  !! Index 0 counts completed calls after pressure-work release. Indices 1:5
  !! count returned grid, lagged-physics, diagnostic, dynamics and end stages.
  !! The C argument is a value integer; indices outside 0:5 return zero.
  integer(c_int64_t) function grid_point_update_stage_count(index) &
    bind(C, name="md2asm_cpg_stage_count_get") result(value)
    integer(c_int), value, intent(in) :: index
    value = 0_c_int64_t
    select case (index)
    case (0)
      value = int(completed_calls, c_int64_t)
    case (1:5)
      value = int(returned_stage_calls(index), c_int64_t)
    end select
  end function
end module forecast_grid_point_update
