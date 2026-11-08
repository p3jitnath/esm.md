!> Complete native CPG_DYN followed by the ordered transport-field scatter.
module forecast_grid_point_transport_handoff
  use iso_fortran_env, only: int32, int64, real64
  use md2asm_time_and_map_factors, only: time_map_controls, form_time_and_map_factors
  use md2asm_linear_forecast_terms, only: form_linear_forecast_terms
  use md2asm_spectral_implicit_update, only: spectral_implicit_coefficients
  use md2asm_vertical_operators, only: vertical_operator_matrices
  use md2asm_moist_air_gas_properties, only: moist_air_constants, thermal_constituent
  use md2asm_trajectory_wind_preparation, only: trajectory_wind_controls, trajectory_wind_outputs, &
                                                prepare_trajectory_wind
  use md2asm_transport_equation_parent, only: transport_parent_controls, transport_parent_fields, &
                                              transport_constituent, prepare_transport_equation_terms
  use md2asm_surface_pressure_transport, only: surface_pressure_transport_controls, &
                                               surface_pressure_transport_fields, prepare_surface_pressure_transport
  use md2asm_interpolation_boundary_values, only: interpolation_boundary_controls, &
                                                  interpolation_boundary_map, initialize_interpolation_boundaries
  use md2asm_departure_field_transport, only: constituent_transport_map
  use md2asm_lagrangian_grid_update, only: lagrangian_grid_controls, lagrangian_linear_inputs, prepare_lagrangian_grid_update
  use md2asm_transform_profile_policy, only: transform_profile_policy, transform_profile_event, increment_source_counter
  use forecast_lagged_grid_update, only: grid_update_environment_supported
  use iso_c_binding, only: c_loc, c_f_pointer, c_intptr_t
  use forecast_grid_point_dynamics_caller, only: gridpoint_dynamics_caller_controls, compute_gridpoint_dynamics
  use forecast_transport_field_scatter, only: transport_scatter_layout, native_address_span, &
                native_buffer_span, checked_address_span, spans_disjoint, admit_transport_field_block, scatter_transport_field_block
  implicit none
  private
  public :: complete_grid_point_transport_handoff
contains
  !> Forward actual native numerical owners, then scatter the completed boundary tile.
  !! Units and numerical owner bounds are those of compute_gridpoint_dynamics.
  !! Transport copies retain each field's physical unit and every real64 bit.
  !! All metadata and active mappings are admitted before the numerical child.
  !! No copied field owner, callback, raw argument table or numerical stage is used.
  integer(int32) function complete_grid_point_transport_handoff( &
    caller_controls, pitch, levels, first, last, transport_first, transport_last, &
    beta_time, time_step, c, coef, tables, moist_constants, linear, &
    generic_fields, thermal_components, eta, sin_latitude, cos_latitude, cos_longitude, sin_longitude, &
    pressure_flux, inverse_pressure_depth, previous_eta_rate, wind_fields, counters, surface_geopotential, orography_l, &
    orography_m, full_level_correction, half_level_correction, tendency_u, tendency_v, tendency_temperature, transport_fields, &
    transport_components, bottom_column_divergence, bottom_pressure, terrain, layer_weight, inverse_eta_thickness, surface_fields, &
    boundary_maps, boundary_components, boundary_buffer, block, scatter, map, destination, &
    gm, extended_multiplier, profile) result(status)
    type(gridpoint_dynamics_caller_controls), target, intent(in) :: caller_controls
    type(transform_profile_policy), target, intent(in), optional :: profile
    integer(int32), target, intent(in) :: pitch, levels, first, last, transport_first, transport_last
    real(real64), target, intent(in) :: beta_time, time_step
    type(lagrangian_grid_controls), target, intent(in) :: c
    type(spectral_implicit_coefficients), target, intent(in) :: coef
    type(vertical_operator_matrices), target, intent(in) :: tables
    type(moist_air_constants), target, intent(in) :: moist_constants
    type(lagrangian_linear_inputs), target, intent(in) :: linear
    real(real64), target, intent(in) :: generic_fields(:, :, :)
    type(thermal_constituent), target, intent(in) :: thermal_components(:)
    real(real64), target, intent(in) :: eta(0:), sin_latitude(:), cos_latitude(:), cos_longitude(:), sin_longitude(:)
    real(real64), target, intent(in) :: pressure_flux(:, 0:), inverse_pressure_depth(:, :)
    real(real64), target, intent(inout) :: previous_eta_rate(:, :)
    type(trajectory_wind_outputs), target, intent(inout) :: wind_fields
    integer(int32), target, intent(inout) :: counters(:)
    real(real64), target, intent(in) :: surface_geopotential(:), orography_l(:), orography_m(:)
    real(real64), target, intent(in) :: full_level_correction(:), half_level_correction(0:)
    real(real64), target, intent(in) :: tendency_u(:, :), tendency_v(:, :), tendency_temperature(:, :)
    type(transport_parent_fields), target, intent(inout) :: transport_fields
    type(transport_constituent), target, intent(inout) :: transport_components(:)
    real(real64), target, intent(in) :: bottom_column_divergence(:), bottom_pressure(:), terrain(:)
    real(real64), target, intent(in) :: layer_weight(:), inverse_eta_thickness(:)
    type(surface_pressure_transport_fields), target, intent(inout) :: surface_fields
    type(interpolation_boundary_map), target, intent(in) :: boundary_maps
    type(constituent_transport_map), target, intent(in) :: boundary_components(:)
    real(real64), target, intent(inout) :: boundary_buffer(:, :)
    integer(int32) :: child_status
    real(real64), optional, target, intent(in) :: gm(:), extended_multiplier(:)
    integer(int32), target, intent(in) :: block
    type(transport_scatter_layout), target, intent(in) :: scatter
    integer(int32), target, intent(in) :: map(:)
    real(real64), target, intent(inout) :: destination(:, :)
    real(real64), pointer, contiguous :: boundary_view(:, :)
    type(native_address_span) :: protected(32), destination_span, map_span, layout_span
    integer :: protected_count, component
    integer(int64) :: block_first, block_offset
    interface owner_apart
      procedure owner_apart1, owner_apart2, owner_apart3, owner_apart_int
    end interface
    status = 2
    if (block < 1 .or. pitch < 1 .or. pitch > 1024) return
    if (.not. is_contiguous(thermal_components)) return
    if (.not. is_contiguous(transport_components)) return
    if (.not. is_contiguous(boundary_components)) return
    block_offset = int(block, int64) - 1
    if (block_offset > (huge(block_first) - 1)/int(pitch, int64)) return
    block_first = block_offset*int(pitch, int64) + 1
    if (scatter%pitch /= pitch .or. scatter%first /= first .or. scatter%last /= last) return
    if (scatter%global_first /= block_first) return
    status = admit_transport_field_block(scatter, map, boundary_buffer, destination)
    if (status /= 0) return
    status = 2
    if (.not. native_buffer_span(destination, destination_span)) return
    if (.not. native_buffer_span(map, map_span)) return
    if (.not. checked_address_span(transfer(c_loc(scatter), 0_c_intptr_t), 1_int64, &
                                   int(storage_size(scatter, kind=int64)/8, int64), layout_span)) return
    protected_count = 3
    protected(1) = destination_span
    protected(2) = map_span
    protected(3) = layout_span
    if (.not. remember(transfer(c_loc(caller_controls), 0_c_intptr_t), 1_int64, &
                       int(storage_size(caller_controls, kind=int64)/8, int64), .false.)) return
    if (.not. remember(transfer(c_loc(pitch), 0_c_intptr_t), 1_int64, &
                       int(storage_size(pitch, kind=int64)/8, int64), .false.)) return
    if (.not. remember(transfer(c_loc(levels), 0_c_intptr_t), 1_int64, &
                       int(storage_size(levels, kind=int64)/8, int64), .false.)) return
    if (.not. remember(transfer(c_loc(first), 0_c_intptr_t), 1_int64, &
                       int(storage_size(first, kind=int64)/8, int64), .false.)) return
    if (.not. remember(transfer(c_loc(last), 0_c_intptr_t), 1_int64, &
                       int(storage_size(last, kind=int64)/8, int64), .false.)) return
    if (.not. remember(transfer(c_loc(transport_first), 0_c_intptr_t), 1_int64, &
                       int(storage_size(transport_first, kind=int64)/8, int64), .false.)) return
    if (.not. remember(transfer(c_loc(transport_last), 0_c_intptr_t), 1_int64, &
                       int(storage_size(transport_last, kind=int64)/8, int64), .false.)) return
    if (.not. remember(transfer(c_loc(beta_time), 0_c_intptr_t), 1_int64, &
                       int(storage_size(beta_time, kind=int64)/8, int64), .false.)) return
    if (.not. remember(transfer(c_loc(time_step), 0_c_intptr_t), 1_int64, &
                       int(storage_size(time_step, kind=int64)/8, int64), .false.)) return
    if (.not. remember(transfer(c_loc(c), 0_c_intptr_t), 1_int64, &
                       int(storage_size(c, kind=int64)/8, int64), .false.)) return
    if (.not. remember(transfer(c_loc(coef), 0_c_intptr_t), 1_int64, &
                       int(storage_size(coef, kind=int64)/8, int64), .false.)) return
    if (.not. remember(transfer(c_loc(tables), 0_c_intptr_t), 1_int64, &
                       int(storage_size(tables, kind=int64)/8, int64), .false.)) return
    if (.not. remember(transfer(c_loc(moist_constants), 0_c_intptr_t), 1_int64, &
                       int(storage_size(moist_constants, kind=int64)/8, int64), .false.)) return
    if (.not. remember(transfer(c_loc(linear), 0_c_intptr_t), 1_int64, &
                       int(storage_size(linear, kind=int64)/8, int64), .false.)) return
    if (.not. remember(transfer(c_loc(block), 0_c_intptr_t), 1_int64, &
                       int(storage_size(block, kind=int64)/8, int64), .false.)) return
    if (.not. remember(transfer(c_loc(boundary_maps), 0_c_intptr_t), 1_int64, &
                       int(storage_size(boundary_maps, kind=int64)/8, int64), .false.)) return
    if (.not. remember(transfer(c_loc(wind_fields), 0_c_intptr_t), 1_int64, &
                       int(storage_size(wind_fields, kind=int64)/8, int64), .true.)) return
    if (.not. remember(transfer(c_loc(transport_fields), 0_c_intptr_t), 1_int64, &
                       int(storage_size(transport_fields, kind=int64)/8, int64), .true.)) return
    if (.not. remember(transfer(c_loc(surface_fields), 0_c_intptr_t), 1_int64, &
                       int(storage_size(surface_fields, kind=int64)/8, int64), .true.)) return
    if (size(thermal_components) > 0) then
      if (.not. remember(transfer(c_loc(thermal_components(1)), 0_c_intptr_t), size(thermal_components, kind=int64), &
                         int(storage_size(thermal_components(1), kind=int64)/8, int64), .false.)) return
    end if
    if (size(transport_components) > 0) then
      if (.not. remember(transfer(c_loc(transport_components(1)), 0_c_intptr_t), size(transport_components, kind=int64), &
                         int(storage_size(transport_components(1), kind=int64)/8, int64), .true.)) return
    end if
    if (size(boundary_components) > 0) then
      if (.not. remember(transfer(c_loc(boundary_components(1)), 0_c_intptr_t), size(boundary_components, kind=int64), &
                         int(storage_size(boundary_components(1), kind=int64)/8, int64), .false.)) return
    end if
    if (present(profile)) then
      if (.not. remember(transfer(c_loc(profile), 0_c_intptr_t), 1_int64, &
                         int(storage_size(profile, kind=int64)/8, int64), .false.)) return
    end if
    if (.not. owner_apart(generic_fields)) return
    if (.not. owner_apart(eta)) return
    if (.not. owner_apart(sin_latitude)) return
    if (.not. owner_apart(cos_latitude)) return
    if (.not. owner_apart(cos_longitude)) return
    if (.not. owner_apart(sin_longitude)) return
    if (.not. owner_apart(pressure_flux)) return
    if (.not. owner_apart(inverse_pressure_depth)) return
    if (.not. owner_apart(previous_eta_rate)) return
    if (.not. owner_apart(counters)) return
    if (.not. owner_apart(surface_geopotential)) return
    if (.not. owner_apart(orography_l)) return
    if (.not. owner_apart(orography_m)) return
    if (.not. owner_apart(full_level_correction)) return
    if (.not. owner_apart(half_level_correction)) return
    if (.not. owner_apart(tendency_u)) return
    if (.not. owner_apart(tendency_v)) return
    if (.not. owner_apart(tendency_temperature)) return
    if (.not. owner_apart(bottom_column_divergence)) return
    if (.not. owner_apart(bottom_pressure)) return
    if (.not. owner_apart(terrain)) return
    if (.not. owner_apart(layer_weight)) return
    if (.not. owner_apart(inverse_eta_thickness)) return
    if (.not. owner_apart(boundary_buffer)) return
    if (present(gm)) then
      if (.not. owner_apart(gm)) return
    end if
    if (present(extended_multiplier)) then
      if (.not. owner_apart(extended_multiplier)) return
    end if
    if (associated(coef%alpha)) then
      if (.not. owner_apart(coef%alpha)) return
    end if
    if (associated(coef%delta)) then
      if (.not. owner_apart(coef%delta)) return
    end if
    if (associated(coef%metric)) then
      if (.not. owner_apart(coef%metric)) return
    end if
    if (associated(coef%accumulation_weight)) then
      if (.not. owner_apart(coef%accumulation_weight)) return
    end if
    if (associated(coef%mean_weight)) then
      if (.not. owner_apart(coef%mean_weight)) return
    end if
    if (associated(coef%full_level_weight)) then
      if (.not. owner_apart(coef%full_level_weight)) return
    end if
    if (associated(coef%laplacian)) then
      if (.not. owner_apart(coef%laplacian)) return
    end if
    if (associated(coef%simi)) then
      if (.not. owner_apart(coef%simi)) return
    end if
    if (associated(coef%simo)) then
      if (.not. owner_apart(coef%simo)) return
    end if
    if (associated(tables%rinte)) then
      if (.not. owner_apart(tables%rinte)) return
    end if
    if (associated(tables%rintbf00)) then
      if (.not. owner_apart(tables%rintbf00)) return
    end if
    if (associated(tables%rintbf11)) then
      if (.not. owner_apart(tables%rintbf11)) return
    end if
    if (associated(tables%rderi)) then
      if (.not. owner_apart(tables%rderi)) return
    end if
    if (associated(tables%rderbf00)) then
      if (.not. owner_apart(tables%rderbf00)) return
    end if
    if (associated(tables%rderbf01)) then
      if (.not. owner_apart(tables%rderbf01)) return
    end if
    if (associated(tables%rderbf10)) then
      if (.not. owner_apart(tables%rderbf10)) return
    end if
    if (associated(tables%rderbf11)) then
      if (.not. owner_apart(tables%rderbf11)) return
    end if
    if (associated(tables%rderbh00)) then
      if (.not. owner_apart(tables%rderbh00)) return
    end if
    if (associated(tables%rderbh01)) then
      if (.not. owner_apart(tables%rderbh01)) return
    end if
    if (associated(tables%rdderi)) then
      if (.not. owner_apart(tables%rdderi)) return
    end if
    if (associated(tables%rdderbf01)) then
      if (.not. owner_apart(tables%rdderbf01)) return
    end if
    if (associated(tables%rdderbf11)) then
      if (.not. owner_apart(tables%rdderbf11)) return
    end if
    if (associated(tables%rintbf11_impl)) then
      if (.not. owner_apart(tables%rintbf11_impl)) return
    end if
    if (associated(tables%rderbf01_impl)) then
      if (.not. owner_apart(tables%rderbf01_impl)) return
    end if
    if (associated(tables%rderbf10_impl)) then
      if (.not. owner_apart(tables%rderbf10_impl)) return
    end if
    if (associated(tables%rderbf11_impl)) then
      if (.not. owner_apart(tables%rderbf11_impl)) return
    end if
    if (associated(tables%rderbh01_impl)) then
      if (.not. owner_apart(tables%rderbh01_impl)) return
    end if
    if (associated(tables%rdderbf11_impl)) then
      if (.not. owner_apart(tables%rdderbf11_impl)) return
    end if
    if (associated(tables%rintgw)) then
      if (.not. owner_apart(tables%rintgw)) return
    end if
    if (associated(tables%rdergw)) then
      if (.not. owner_apart(tables%rdergw)) return
    end if
    if (associated(linear%divergence)) then
      if (.not. owner_apart(linear%divergence)) return
    end if
    if (associated(linear%temperature_l)) then
      if (.not. owner_apart(linear%temperature_l)) return
    end if
    if (associated(linear%temperature_m)) then
      if (.not. owner_apart(linear%temperature_m)) return
    end if
    if (associated(linear%surface_l)) then
      if (.not. owner_apart(linear%surface_l)) return
    end if
    if (associated(linear%surface_m)) then
      if (.not. owner_apart(linear%surface_m)) return
    end if
    if (associated(linear%wind_u)) then
      if (.not. owner_apart(linear%wind_u)) return
    end if
    if (associated(linear%wind_v)) then
      if (.not. owner_apart(linear%wind_v)) return
    end if
    if (associated(linear%coriolis)) then
      if (.not. owner_apart(linear%coriolis)) return
    end if
    if (associated(wind_fields%predicted_x)) then
      if (.not. owner_apart(wind_fields%predicted_x)) return
    end if
    if (associated(wind_fields%predicted_y)) then
      if (.not. owner_apart(wind_fields%predicted_y)) return
    end if
    if (associated(wind_fields%predicted_z)) then
      if (.not. owner_apart(wind_fields%predicted_z)) return
    end if
    if (associated(wind_fields%predicted_eta)) then
      if (.not. owner_apart(wind_fields%predicted_eta)) return
    end if
    if (associated(wind_fields%current_x)) then
      if (.not. owner_apart(wind_fields%current_x)) return
    end if
    if (associated(wind_fields%current_y)) then
      if (.not. owner_apart(wind_fields%current_y)) return
    end if
    if (associated(wind_fields%current_z)) then
      if (.not. owner_apart(wind_fields%current_z)) return
    end if
    if (associated(wind_fields%current_eta)) then
      if (.not. owner_apart(wind_fields%current_eta)) return
    end if
    if (associated(wind_fields%history)) then
      if (.not. owner_apart(wind_fields%history)) return
    end if
    if (associated(wind_fields%mixing)) then
      if (.not. owner_apart(wind_fields%mixing)) return
    end if
    if (associated(surface_fields%wind_u)) then
      if (.not. owner_apart(surface_fields%wind_u)) return
    end if
    if (associated(surface_fields%wind_v)) then
      if (.not. owner_apart(surface_fields%wind_v)) return
    end if
    if (associated(surface_fields%log_gradient_l)) then
      if (.not. owner_apart(surface_fields%log_gradient_l)) return
    end if
    if (associated(surface_fields%log_gradient_m)) then
      if (.not. owner_apart(surface_fields%log_gradient_m)) return
    end if
    if (associated(surface_fields%current_surface)) then
      if (.not. owner_apart(surface_fields%current_surface)) return
    end if
    if (associated(surface_fields%saved_surface)) then
      if (.not. owner_apart(surface_fields%saved_surface)) return
    end if
    if (associated(surface_fields%mixing)) then
      if (.not. owner_apart(surface_fields%mixing)) return
    end if
    if (associated(surface_fields%residual_history)) then
      if (.not. owner_apart(surface_fields%residual_history)) return
    end if
    if (associated(surface_fields%nonlinear_history)) then
      if (.not. owner_apart(surface_fields%nonlinear_history)) return
    end if
    if (associated(surface_fields%new_surface)) then
      if (.not. owner_apart(surface_fields%new_surface)) return
    end if
    if (associated(surface_fields%linear_buffer)) then
      if (.not. owner_apart(surface_fields%linear_buffer)) return
    end if
    if (associated(surface_fields%surface_buffer)) then
      if (.not. owner_apart(surface_fields%surface_buffer)) return
    end if
    if (associated(surface_fields%outgoing)) then
      if (.not. owner_apart(surface_fields%outgoing)) return
    end if
    if (associated(surface_fields%cheap_correction)) then
      if (.not. owner_apart(surface_fields%cheap_correction)) return
    end if
    if (associated(transport_fields%wind_u%pxt0%values)) then
      if (.not. owner_apart(transport_fields%wind_u%pxt0%values)) return
    end if
    if (associated(transport_fields%wind_u%pxt9%values)) then
      if (.not. owner_apart(transport_fields%wind_u%pxt9%values)) return
    end if
    if (associated(transport_fields%wind_u%pmoy1x%values)) then
      if (.not. owner_apart(transport_fields%wind_u%pmoy1x%values)) return
    end if
    if (associated(transport_fields%wind_u%pmixnl%values)) then
      if (.not. owner_apart(transport_fields%wind_u%pmixnl%values)) return
    end if
    if (associated(transport_fields%wind_u%pxsi%values)) then
      if (.not. owner_apart(transport_fields%wind_u%pxsi%values)) return
    end if
    if (associated(transport_fields%wind_u%pxnlt9%values)) then
      if (.not. owner_apart(transport_fields%wind_u%pxnlt9%values)) return
    end if
    if (associated(transport_fields%wind_u%pxt1%values)) then
      if (.not. owner_apart(transport_fields%wind_u%pxt1%values)) return
    end if
    if (associated(transport_fields%wind_u%pxl0%values)) then
      if (.not. owner_apart(transport_fields%wind_u%pxl0%values)) return
    end if
    if (associated(transport_fields%wind_u%pxl9%values)) then
      if (.not. owner_apart(transport_fields%wind_u%pxl9%values)) return
    end if
    if (associated(transport_fields%wind_u%pxlf9%values)) then
      if (.not. owner_apart(transport_fields%wind_u%pxlf9%values)) return
    end if
    if (associated(transport_fields%wind_u%pcxnlt9%values)) then
      if (.not. owner_apart(transport_fields%wind_u%pcxnlt9%values)) return
    end if
    if (associated(transport_fields%wind_u%psiddhxt1%values)) then
      if (.not. owner_apart(transport_fields%wind_u%psiddhxt1%values)) return
    end if
    if (associated(transport_fields%wind_u%psiddhxt9%values)) then
      if (.not. owner_apart(transport_fields%wind_u%psiddhxt9%values)) return
    end if
    if (associated(transport_fields%wind_u%psiddhxl0%values)) then
      if (.not. owner_apart(transport_fields%wind_u%psiddhxl0%values)) return
    end if
    if (associated(transport_fields%wind_u%pxlf0%values)) then
      if (.not. owner_apart(transport_fields%wind_u%pxlf0%values)) return
    end if
    if (associated(transport_fields%wind_v%pxt0%values)) then
      if (.not. owner_apart(transport_fields%wind_v%pxt0%values)) return
    end if
    if (associated(transport_fields%wind_v%pxt9%values)) then
      if (.not. owner_apart(transport_fields%wind_v%pxt9%values)) return
    end if
    if (associated(transport_fields%wind_v%pmoy1x%values)) then
      if (.not. owner_apart(transport_fields%wind_v%pmoy1x%values)) return
    end if
    if (associated(transport_fields%wind_v%pmixnl%values)) then
      if (.not. owner_apart(transport_fields%wind_v%pmixnl%values)) return
    end if
    if (associated(transport_fields%wind_v%pxsi%values)) then
      if (.not. owner_apart(transport_fields%wind_v%pxsi%values)) return
    end if
    if (associated(transport_fields%wind_v%pxnlt9%values)) then
      if (.not. owner_apart(transport_fields%wind_v%pxnlt9%values)) return
    end if
    if (associated(transport_fields%wind_v%pxt1%values)) then
      if (.not. owner_apart(transport_fields%wind_v%pxt1%values)) return
    end if
    if (associated(transport_fields%wind_v%pxl0%values)) then
      if (.not. owner_apart(transport_fields%wind_v%pxl0%values)) return
    end if
    if (associated(transport_fields%wind_v%pxl9%values)) then
      if (.not. owner_apart(transport_fields%wind_v%pxl9%values)) return
    end if
    if (associated(transport_fields%wind_v%pxlf9%values)) then
      if (.not. owner_apart(transport_fields%wind_v%pxlf9%values)) return
    end if
    if (associated(transport_fields%wind_v%pcxnlt9%values)) then
      if (.not. owner_apart(transport_fields%wind_v%pcxnlt9%values)) return
    end if
    if (associated(transport_fields%wind_v%psiddhxt1%values)) then
      if (.not. owner_apart(transport_fields%wind_v%psiddhxt1%values)) return
    end if
    if (associated(transport_fields%wind_v%psiddhxt9%values)) then
      if (.not. owner_apart(transport_fields%wind_v%psiddhxt9%values)) return
    end if
    if (associated(transport_fields%wind_v%psiddhxl0%values)) then
      if (.not. owner_apart(transport_fields%wind_v%psiddhxl0%values)) return
    end if
    if (associated(transport_fields%wind_v%pxlf0%values)) then
      if (.not. owner_apart(transport_fields%wind_v%pxlf0%values)) return
    end if
    if (associated(transport_fields%temperature%pxt0%values)) then
      if (.not. owner_apart(transport_fields%temperature%pxt0%values)) return
    end if
    if (associated(transport_fields%temperature%pxt9%values)) then
      if (.not. owner_apart(transport_fields%temperature%pxt9%values)) return
    end if
    if (associated(transport_fields%temperature%pmoy1x%values)) then
      if (.not. owner_apart(transport_fields%temperature%pmoy1x%values)) return
    end if
    if (associated(transport_fields%temperature%pmixnl%values)) then
      if (.not. owner_apart(transport_fields%temperature%pmixnl%values)) return
    end if
    if (associated(transport_fields%temperature%pxsi%values)) then
      if (.not. owner_apart(transport_fields%temperature%pxsi%values)) return
    end if
    if (associated(transport_fields%temperature%pxnlt9%values)) then
      if (.not. owner_apart(transport_fields%temperature%pxnlt9%values)) return
    end if
    if (associated(transport_fields%temperature%pxt1%values)) then
      if (.not. owner_apart(transport_fields%temperature%pxt1%values)) return
    end if
    if (associated(transport_fields%temperature%pxl0%values)) then
      if (.not. owner_apart(transport_fields%temperature%pxl0%values)) return
    end if
    if (associated(transport_fields%temperature%pxl9%values)) then
      if (.not. owner_apart(transport_fields%temperature%pxl9%values)) return
    end if
    if (associated(transport_fields%temperature%pxlf9%values)) then
      if (.not. owner_apart(transport_fields%temperature%pxlf9%values)) return
    end if
    if (associated(transport_fields%temperature%pcxnlt9%values)) then
      if (.not. owner_apart(transport_fields%temperature%pcxnlt9%values)) return
    end if
    if (associated(transport_fields%temperature%psiddhxt1%values)) then
      if (.not. owner_apart(transport_fields%temperature%psiddhxt1%values)) return
    end if
    if (associated(transport_fields%temperature%psiddhxt9%values)) then
      if (.not. owner_apart(transport_fields%temperature%psiddhxt9%values)) return
    end if
    if (associated(transport_fields%temperature%psiddhxl0%values)) then
      if (.not. owner_apart(transport_fields%temperature%psiddhxl0%values)) return
    end if
    if (associated(transport_fields%temperature%pxlf0%values)) then
      if (.not. owner_apart(transport_fields%temperature%pxlf0%values)) return
    end if
    do component = 1, size(transport_components)
      if (associated(transport_components(component)%current)) then
        if (.not. owner_apart(transport_components(component)%current)) return
      end if
      if (associated(transport_components(component)%transported)) then
        if (.not. owner_apart(transport_components(component)%transported)) return
      end if
    end do
    ! Admission proves the original target is contiguous. This local native
    ! pointer borrows the same typed owner and prevents compiler copy-in/out.
    call c_f_pointer(c_loc(boundary_buffer(1, 1)), boundary_view, &
                     [size(boundary_buffer, 1, kind=int64), size(boundary_buffer, 2, kind=int64)])
    call compute_gridpoint_dynamics( &
      caller_controls, pitch, levels, first, last, transport_first, transport_last, &
      beta_time, time_step, c, coef, tables, moist_constants, linear, &
      generic_fields, thermal_components, eta, sin_latitude, cos_latitude, cos_longitude, sin_longitude, &
      pressure_flux, inverse_pressure_depth, previous_eta_rate, wind_fields, counters, surface_geopotential, orography_l, &
      orography_m, full_level_correction, half_level_correction, tendency_u, tendency_v, tendency_temperature, transport_fields, &
    transport_components, bottom_column_divergence, bottom_pressure, terrain, layer_weight, inverse_eta_thickness, surface_fields, &
      boundary_maps, boundary_components, boundary_view, child_status, gm, extended_multiplier, profile)
    if (child_status /= 0) then
      status = child_status
      return
    end if
    status = scatter_transport_field_block(scatter, map, boundary_buffer, destination)
  contains
    logical function remember(address, count, width, mutable_record) result(valid)
      integer(c_intptr_t), intent(in) :: address
      integer(int64), intent(in) :: count, width
      logical, intent(in) :: mutable_record
      type(native_address_span) :: span
      valid = .false.
      if (.not. checked_address_span(address, count, width, span)) return
      if (.not. spans_disjoint(span, destination_span)) return
      if (mutable_record) then
        if (.not. spans_disjoint(span, map_span) .or. .not. spans_disjoint(span, layout_span)) return
      end if
      if (protected_count == size(protected)) return
      protected_count = protected_count + 1
      protected(protected_count) = span
      valid = .true.
    end function

    logical function owner_apart1(field) result(valid)
      real(real64), target, intent(in) :: field(:)
      type(native_address_span) :: span
      valid = native_buffer_span(field, span)
      if (valid) valid = apart_from_metadata(span)
    end function
    logical function owner_apart2(field) result(valid)
      real(real64), target, intent(in) :: field(:, :)
      type(native_address_span) :: span
      valid = native_buffer_span(field, span)
      if (valid) valid = apart_from_metadata(span)
    end function
    logical function owner_apart3(field) result(valid)
      real(real64), target, intent(in) :: field(:, :, :)
      type(native_address_span) :: span
      valid = native_buffer_span(field, span)
      if (valid) valid = apart_from_metadata(span)
    end function
    logical function owner_apart_int(field) result(valid)
      integer(int32), target, intent(in) :: field(:)
      type(native_address_span) :: span
      valid = native_buffer_span(field, span)
      if (valid) valid = apart_from_metadata(span)
    end function
    logical function apart_from_metadata(span) result(valid)
      type(native_address_span), intent(in) :: span
      integer :: item
      valid = .false.
      do item = 1, protected_count
        if (.not. spans_disjoint(span, protected(item))) return
      end do
      valid = .true.
    end function
  end function
end module
