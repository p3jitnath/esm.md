!> Preserve the selected CPG_DYN admission,own child call and completion count.
module forecast_grid_point_dynamics_caller_strided
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
 use md2asm_lagrangian_grid_update_strided, only: lagrangian_grid_controls, lagrangian_linear_inputs, prepare_lagrangian_grid_update
  use md2asm_transform_profile_policy, only: transform_profile_policy, transform_profile_event, increment_source_counter
  use forecast_lagged_grid_update, only: grid_update_environment_supported
  implicit none
  private
  public :: gridpoint_dynamics_caller_controls, compute_gridpoint_dynamics, gridpoint_dynamics_call_count
  integer(int64), save :: completed_calls = 0
  !> These values come from the actual model and trajectory configuration.
  type :: gridpoint_dynamics_caller_controls
    logical :: semi_lagrangian = .false., ecmwf_physics = .false., meteofrance_physics = .false.
    logical :: surface_linear_physics = .false., trajectory_save = .false., trajectory_lag = .false.
  end type
contains
  !> Retain the complete selected LACDYN argument graph through native types.
  !! Array shapes,units,intents and mutations match prepare_lagrangian_grid_update.
  !! The caller forwards actual metadata and owners;no numerical stage is a callback.
  !! Only successful complete child returns increment the source word counter.
  !! An optional profiling policy calls the actual public FIAT hook.
  !! Status0 succeeds,1 reports allocation failure and2 refuses the selected route.
  subroutine compute_gridpoint_dynamics(caller_controls, &
                                        pitch, levels, first, last, transport_first, transport_last, beta_time, &
                                        time_step, c, coef, tables, moist_constants, linear, generic_fields, &
                                 thermal_components, eta, sin_latitude, cos_latitude, cos_longitude, sin_longitude, pressure_flux, &
                 inverse_pressure_depth, previous_eta_rate, wind_fields, counters, surface_geopotential, orography_l, orography_m, &
     full_level_correction,half_level_correction,tendency_u,tendency_v,tendency_temperature,transport_fields,transport_components, &
           bottom_column_divergence, bottom_pressure, terrain, layer_weight, inverse_eta_thickness, surface_fields, boundary_maps, &
                                        boundary_components, boundary_buffer, status, gm, extended_multiplier, profile)
    type(gridpoint_dynamics_caller_controls), intent(in) :: caller_controls
    type(transform_profile_policy), intent(in), optional :: profile
    integer(int32), intent(in) :: pitch, levels, first, last, transport_first, transport_last
    real(real64), intent(in) :: beta_time, time_step
    type(lagrangian_grid_controls), intent(in) :: c
    type(spectral_implicit_coefficients), intent(in) :: coef
    type(vertical_operator_matrices), intent(in) :: tables
    type(moist_air_constants), intent(in) :: moist_constants
    type(lagrangian_linear_inputs), intent(in) :: linear
    real(real64), intent(in) :: generic_fields(:, :, :)
    type(thermal_constituent), intent(in) :: thermal_components(:)
    real(real64), intent(in) :: eta(0:), sin_latitude(:), cos_latitude(:), cos_longitude(:), sin_longitude(:)
    real(real64), intent(in) :: pressure_flux(:, 0:), inverse_pressure_depth(:, :)
    real(real64), intent(inout) :: previous_eta_rate(:, :)
    type(trajectory_wind_outputs), intent(inout) :: wind_fields
    integer(int32), intent(inout) :: counters(:)
    real(real64), intent(in) :: surface_geopotential(:), orography_l(:), orography_m(:)
    real(real64), intent(in) :: full_level_correction(:), half_level_correction(0:)
    real(real64), intent(in) :: tendency_u(:, :), tendency_v(:, :), tendency_temperature(:, :)
    type(transport_parent_fields), intent(inout) :: transport_fields
    type(transport_constituent), intent(inout) :: transport_components(:)
    real(real64), intent(in) :: bottom_column_divergence(:), bottom_pressure(:), terrain(:)
    real(real64), intent(in) :: layer_weight(:), inverse_eta_thickness(:)
    type(surface_pressure_transport_fields), intent(inout) :: surface_fields
    type(interpolation_boundary_map), intent(in) :: boundary_maps
    type(constituent_transport_map), intent(in) :: boundary_components(:)
    real(real64), contiguous, target, intent(inout) :: boundary_buffer(:, :)
    integer(int32), intent(out) :: status
    real(real64), optional, intent(in) :: gm(:), extended_multiplier(:)
    real(real64) :: profile_handle
    status = 2
    if (.not. caller_controls%semi_lagrangian .or. .not. caller_controls%ecmwf_physics) return
    if (caller_controls%meteofrance_physics .or. caller_controls%surface_linear_physics) return
    if (caller_controls%trajectory_save .or. caller_controls%trajectory_lag) return
    if (.not. grid_update_environment_supported()) return
    call transform_profile_event("CPG_DYN", 0_int32, profile_handle, profile)
    call prepare_lagrangian_grid_update( &
      pitch, levels, first, last, transport_first, transport_last, beta_time, &
      time_step, c, coef, tables, moist_constants, linear, generic_fields, &
      thermal_components, eta, sin_latitude, cos_latitude, cos_longitude, sin_longitude, pressure_flux, &
      inverse_pressure_depth, previous_eta_rate, wind_fields, counters, surface_geopotential, orography_l, orography_m, &
     full_level_correction,half_level_correction,tendency_u,tendency_v,tendency_temperature,transport_fields,transport_components, &
      bottom_column_divergence, bottom_pressure, terrain, layer_weight, inverse_eta_thickness, surface_fields, boundary_maps, &
      boundary_components, boundary_buffer, status, gm, extended_multiplier)
    if (status == 0) call increment_source_counter(completed_calls)
    call transform_profile_event("CPG_DYN", 1_int32, profile_handle, profile)
  end subroutine
  integer(int64) function gridpoint_dynamics_call_count() result(value)
    value = completed_calls
  end function
end module forecast_grid_point_dynamics_caller_strided
