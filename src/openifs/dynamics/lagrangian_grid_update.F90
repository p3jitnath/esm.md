!> Complete selected native LACDYN grid-point preparation.
!! Own children prepare time factors, linear terms, trajectory winds,
!! transport terms, continuity and interpolation boundaries in source order.
module md2asm_lagrangian_grid_update
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
  implicit none
  private
  public :: lagrangian_grid_controls, lagrangian_linear_inputs, prepare_lagrangian_grid_update

  !> Native controls for the selected hydrostatic, two-time-level route.
  !! Separate child controls retain their named physical values. Unsupported
  !! nonhydrostatic, extra-diffusion, mixed extrapolation and COMAD calculations
  !! refuse explicitly. COMAD means a correction of modified advection.
  type :: lagrangian_grid_controls
    type(time_map_controls) :: time
    type(trajectory_wind_controls) :: wind
    type(transport_parent_controls) :: transport
    type(surface_pressure_transport_controls) :: surface
    type(interpolation_boundary_controls) :: boundary
    logical :: moist_temperature = .false., implicit_coriolis = .false.
    logical :: finite_elements = .true., two_time_levels = .true.
    logical :: nonhydrostatic_euler = .false., nonhydrostatic_quasi = .false., nonhydrostatic = .false.
    logical :: mixed_extrapolation = .false., full_corrector = .false., cheap_corrector = .false.
    logical :: horizontal_diffusion = .false., modified_advection = .false., wave_advection = .false.
    logical :: diagnostic_bottom_boundary = .false., extra_linear_term = .false.
    integer :: integral_bc = 3, derivative_bc = 3
  end type

  !> Immutable current/previous fields for the own linear-term child.
  !! Three-dimensional views have shape(pitch,levels,time), with current time1
  !! and previous time2. Surface views have shape(pitch,time); Coriolis is1/s.
  !! Temperature derivatives are K/m; wind is m/s; divergence is1/s.
  !! The producer owns their live field and time mapping.
  type :: lagrangian_linear_inputs
    real(real64), pointer, contiguous :: divergence(:, :, :) => null()
    real(real64), pointer, contiguous :: temperature_l(:, :, :) => null(), temperature_m(:, :, :) => null()
    real(real64), pointer, contiguous :: surface_l(:, :) => null(), surface_m(:, :) => null()
    real(real64), pointer, contiguous :: wind_u(:, :, :) => null(), wind_v(:, :, :) => null()
    real(real64), pointer, contiguous :: coriolis(:) => null()
  end type
contains
  !> Run the complete selected grid-point preparation without original stages.
  !! All dimensions come from live native fields. pitch is column capacity,
  !! levels is physical-level count, and first:last is inclusive. The selected
  !! historical source has24columns/19levels; wider live shapes remain
  !! unaccepted until a matching component comparison. beta_time has no unit
  !! and time_step is in seconds. transport_first/last retain padded levels.
  !! Geometry, vertical arrays and physical constants retain each child's units.
  !! State/output views point into caller-owned native arrays and remain alive.
  !! boundary_buffer is the complete shared transport owner; the child views
  !! preserve its actual aliases and plane offsets. No numerical driver fills
  !! a time factor, linear term, wind prediction, mixing value or boundary.
  !! LAVENT's temporary PALPHA and the all-ones nonlinear mixing field are owned
  !! here. Only the supplied state, wind, diagnostic and boundary views change.
  !! Status0 succeeds;1 refuses private allocation;2 refuses controls, owners
  !! or a child. A late child refusal makes the complete return unaccepted.
  subroutine prepare_lagrangian_grid_update(pitch, levels, first, last, transport_first, transport_last, &
                               beta_time, time_step, c, coef, tables, moist_constants, linear, generic_fields, thermal_components, &
                             eta, sin_latitude, cos_latitude, cos_longitude, sin_longitude, pressure_flux, inverse_pressure_depth, &
                                         previous_eta_rate, wind_fields, counters, surface_geopotential, orography_l, orography_m, &
                                       full_level_correction, half_level_correction, tendency_u, tendency_v, tendency_temperature, &
                                       transport_fields, transport_components, bottom_column_divergence, bottom_pressure, terrain, &
                                          layer_weight, inverse_eta_thickness, surface_fields, boundary_maps, boundary_components, &
                                            boundary_buffer, status, gm, extended_multiplier)
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
    real(real64), allocatable :: map_time_factor(:), map_multiplier(:), pressure_rate(:, :)
    real(real64), allocatable :: thermal_rate(:, :, :), gradient_l(:, :, :), gradient_m(:, :, :)
    real(real64), allocatable, target :: nonlinear_mixing(:, :), wind_mixing(:, :)
    type(trajectory_wind_outputs) :: local_wind
    type(transport_parent_fields) :: local_transport
    type(surface_pressure_transport_fields) :: local_surface
    real(real64) :: half_time_step, weighted_half_time_step, plus_factor, minus_factor
    integer(int64) :: private_bytes
    integer :: allocation_status
    logical :: two_level_force

    status = 2_int32
    if (pitch < 1 .or. pitch > 1024 .or. levels < 4 .or. levels > 256) return
    if (first < 1 .or. first > pitch .or. last < first - 1 .or. last > pitch) return
    if (.not. c%finite_elements .or. .not. c%two_time_levels) return
    if (c%nonhydrostatic_euler .or. c%nonhydrostatic_quasi .or. c%nonhydrostatic) return
    if (c%mixed_extrapolation .or. c%full_corrector .or. c%cheap_corrector) return
    if (c%horizontal_diffusion .or. c%modified_advection .or. c%wave_advection) return
    if (c%diagnostic_bottom_boundary .or. c%extra_linear_term) return
    if (c%time%two_level_first_force .and. (c%time%model_physics .or. c%time%external_physics) .and. &
        .not. c%time%lagged_physics) return
    if (c%wind%step /= c%transport%term%step .or. c%wind%step /= c%surface%step) return
    if (c%transport%term%implicit_time_weight /= c%surface%time_bias) return
    if (c%integral_bc /= 3 .or. c%surface%integral_bc /= c%integral_bc) return
    if (.not. c%transport%two_time_levels .or. .not. c%transport%finite_element) return
    if (.not. c%surface%two_time_levels .or. .not. c%surface%finite_elements) return
    if (c%surface%continuity_points /= 3) return
    if (.not. associated(linear%divergence)) return
    if (.not. associated(linear%temperature_l) .or. .not. associated(linear%temperature_m)) return
    if (.not. associated(linear%surface_l) .or. .not. associated(linear%surface_m)) return
    if (.not. associated(linear%wind_u) .or. .not. associated(linear%wind_v)) return
    if (.not. associated(linear%coriolis)) return
    if (size(linear%wind_u, 3) < 2 .or. size(linear%wind_v, 3) < 2) return
    private_bytes = 8_int64*int(pitch, int64)*(8_int64*int(levels, int64) + 4_int64)
    if (private_bytes > 536870912_int64) return
    allocate (map_time_factor(pitch), map_multiplier(pitch), pressure_rate(pitch, 2), &
              thermal_rate(pitch, levels, 2), gradient_l(pitch, levels, 2), gradient_m(pitch, levels, 2), &
              nonlinear_mixing(pitch, levels), wind_mixing(pitch, levels), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1_int32
      return
    end if

    ! LASURE: all time and map coefficients are private parent results.
    call form_time_and_map_factors(pitch, first, last, beta_time, time_step, c%time, half_time_step, &
                             weighted_half_time_step, two_level_force, map_time_factor, map_multiplier, plus_factor, minus_factor, &
                                   status, gm, extended_multiplier)
    if (status /= 0) return
    if (two_level_force) then
      status = 2_int32
      return
    end if

    ! LASSIE: complete current linear terms; old terms are unconsumed in2TL.
    call form_linear_forecast_terms(pitch, levels, first, last, c%two_time_levels, c%moist_temperature, &
                            c%implicit_coriolis, c%finite_elements, c%integral_bc, c%derivative_bc, coef, tables, moist_constants, &
                                linear%divergence, linear%temperature_l, linear%temperature_m, linear%surface_l, linear%surface_m, &
                               linear%wind_u, linear%wind_v, linear%coriolis, thermal_rate, pressure_rate, gradient_l, gradient_m, &
                                    status, generic_fields, thermal_components)
    if (status /= 0) return

    ! LAVENT: output views retain their real PB1/PB2 and GMV owner aliases.
    local_wind = wind_fields
    local_wind%mixing => wind_mixing
    call prepare_trajectory_wind(pitch, levels, first, last, c%wind, eta, sin_latitude, cos_latitude, &
                                 cos_longitude, sin_longitude, linear%wind_u(:, :, 1), linear%wind_v(:, :, 1), &
                                 linear%wind_u(:, :, 2), linear%wind_v(:, :, 2), pressure_flux, inverse_pressure_depth, &
                                 previous_eta_rate, local_wind, counters, status)
    if (status /= 0) return

    ! The selected source disables LATTE_NL and initializes all mixing values.
    nonlinear_mixing = 1.0_real64
    local_transport = transport_fields
    local_transport%wind_u%pxt0%values => linear%wind_u(:, :, 1)
    local_transport%wind_u%pxt9%values => linear%wind_u(:, :, 2)
    local_transport%wind_v%pxt0%values => linear%wind_v(:, :, 1)
    local_transport%wind_v%pxt9%values => linear%wind_v(:, :, 2)
    local_transport%wind_u%pmixnl%values => nonlinear_mixing
    local_transport%wind_v%pmixnl%values => nonlinear_mixing
    local_transport%temperature%pmixnl%values => nonlinear_mixing
    call prepare_transport_equation_terms(pitch, levels, first, last, transport_first, transport_last, &
                                 half_time_step, weighted_half_time_step, map_time_factor, plus_factor, minus_factor, c%transport, &
                                          linear%coriolis, surface_geopotential, orography_l, orography_m, full_level_correction, &
                                          half_level_correction, gradient_l(:, :, 1), gradient_m(:, :, 1), thermal_rate(:, :, 1), &
                                          tendency_u, tendency_v, tendency_temperature, inverse_pressure_depth, pressure_flux, &
                                          local_transport, transport_components, status)
    if (status /= 0) return

    ! LATTES follows the three-dimensional equations and precedes boundaries.
    local_surface = surface_fields
    local_surface%wind_u => linear%wind_u(:, :, 1)
    local_surface%wind_v => linear%wind_v(:, :, 1)
    local_surface%log_gradient_l => linear%surface_l(:, 1)
    local_surface%log_gradient_m => linear%surface_m(:, 1)
    local_surface%mixing => nonlinear_mixing
    call prepare_surface_pressure_transport(pitch, levels, first, last, transport_first, transport_last, &
                                  half_time_step, map_time_factor, plus_factor, minus_factor, c%surface, orography_l, orography_m, &
                                     pressure_rate(:, 1), pressure_rate(:, 2), bottom_column_divergence, bottom_pressure, terrain, &
                                            layer_weight, inverse_eta_thickness, tables, local_surface, status)
    if (status /= 0) return
    call initialize_interpolation_boundaries(pitch, levels, first, last, c%boundary, boundary_maps, &
                                             boundary_components, boundary_buffer, status)
  end subroutine
end module md2asm_lagrangian_grid_update
