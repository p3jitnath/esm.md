!> Compose the complete selected CPG_GP grid calculation from own children.
module forecast_grid_calculations
  use iso_fortran_env, only: int32, real64
  use md2asm_two_part_time_filter, only: time_filter_controls, time_filter_maps, filter_field_pair, apply_time_filter_second
  use md2asm_surface_pressure_and_spectral_filter, only: convert_surface_pressure
  use md2asm_moist_air_gas_properties, only: moist_air_constants, thermal_constituent
  use md2asm_vertical_operators, only: vertical_operator_matrices
  use md2asm_lagrangian_work_initialization, only: lagrangian_initialization_controls, lagrangian_component, &
                                 lagrangian_bank_slots, lagrangian_source_fields, lagrangian_work_fields, initialize_lagrangian_work
  use forecast_hydrostatic_grid_calculations, only: hydrostatic_grid_controls, hydrostatic_motion_map, &
                                               hydrostatic_grid_outputs, native_hydrostatic_pressure_terms, compute_hydrostatic_grid
  use forecast_lagged_grid_update, only: grid_update_environment_supported
  implicit none
  private
  public :: forecast_grid_calculation_controls, forecast_grid_vertical_inputs, forecast_grid_surface_map
  public :: compute_forecast_grid_calculations
  !> Controls are initialized model values. Inactive source branches refuse.
  type :: forecast_grid_calculation_controls
    type(time_filter_controls) :: filter
    type(time_filter_maps) :: filter_maps
    type(hydrostatic_grid_controls) :: hydrostatic
    type(lagrangian_initialization_controls) :: initialization
    type(lagrangian_bank_slots) :: bank_slots
    real(real64) :: filter_weights(4) = 0.0_real64, stretch = 0.0_real64, update_factor = 0.0_real64
    integer(int32) :: current_iteration = 0, water_components(4) = 0
    logical :: first_step = .false., semi_lagrangian = .false., two_time_levels = .false.
    logical :: boundary_coupling = .false., top_sponge = .false., nudging = .false., large_scale_forcing = .false.
    logical :: nonhydrostatic = .false., nonhydrostatic_euler = .false., nonhydrostatic_quasi = .false.
    logical :: alternative_acceleration = .false., finite_element_ecmwf = .false., full_corrector = .false.
    logical :: diabatic = .false., surface_physics = .false., simple_physics = .false., extra_diagnostics = .false.
    logical :: model_surface_equations = .false., linearized_model = .false.
  end type
  !> Borrow actual initialized vertical owners without copying or padding.
  !! Half coefficients are0:L;full and difference coefficients are1:L.
  !! inverse_coordinate_depth and metric retain the exact child source meaning.
  type :: forecast_grid_vertical_inputs
    real(real64), pointer :: vah(:) => null(), vbh(:) => null(), vc(:) => null(), vaf(:) => null(), vbf(:) => null()
    real(real64), pointer :: vdela(:) => null(), vdelb(:) => null(), inverse_coordinate_depth(:) => null(), metric(:) => null()
  end type
  !> Original current-surface YT0 MSP,MSPL,MSPM indices in the real owner.
  type :: forecast_grid_surface_map
    integer(int32) :: log_pressure = 0, log_gradient_x = 0, log_gradient_y = 0
  end type
contains
  !> Run GPTF2,scaled terrain gradients,surface pressure,hydrostatics and GPINISLB.
  !!
  !! Motion(P,L,F),surface(P,1,S) and tracers(P,L,C) are complete native owners.
  !! The inclusive active interval first:last can be empty. All counts and slot
  !! maps come from the live field and grid metadata. The selected source has
  !! P<=256,L19 and stretch1;larger L remains an unaccepted compiled extension.
  !! Terrain is geopotential in m**2/s**2;its raw gradients and metric produce
  !! the source map-scaled gradients. Current log-pressure is dimensionless;
  !! the pressure child returns Pa and its horizontal gradients.
  !!
  !! previous/work are the own GPINISLB native views of actual old and future
  !! field owners and the real PB2 bank. They contain no computed coefficients.
  !! This parent replaces previous full_pressure and vertical_velocity by the
  !! freshly computed hydrostatic outputs before initializing work. The caller
  !! binds only native metadata/owners;it supplies no omitted numerical stage.
  !! Hydrostatic output and pressure-term views retain their declared bounds.
  !! Only source outputs and filter/history destinations mutate. No original
  !! numerical routine,procedure callback or private Arm record is used.
  !!
  !! Status0 succeeds,1 reports allocation/child allocation failure and2 refuses
  !! unsupported metadata or a child. A late refusal is not a completed update.
  subroutine compute_forecast_grid_calculations(c, surface_map, motion_map, pitch, first, last, levels, &
                                            tracer_filter_pairs, constants, thermal_components, work_components, tables, vertical, &
                                            motion, surface, tracers, terrain, raw_terrain_x, raw_terrain_y, map_metric, coriolis, &
                                terrain_x, terrain_y, surface_pressure_x, surface_pressure_y, terms, output, previous, work, status)
    type(forecast_grid_calculation_controls), intent(in) :: c
    type(forecast_grid_surface_map), intent(in) :: surface_map
    type(hydrostatic_motion_map), intent(in) :: motion_map
    integer(int32), intent(in) :: pitch, first, last, levels
    type(filter_field_pair), intent(in) :: tracer_filter_pairs(:)
    type(moist_air_constants), intent(in) :: constants
    type(thermal_constituent), intent(in) :: thermal_components(:)
    type(lagrangian_component), intent(in) :: work_components(:)
    type(vertical_operator_matrices), intent(in) :: tables
    type(forecast_grid_vertical_inputs), intent(in) :: vertical
    real(real64), target, intent(inout) :: motion(:, :, :)
    real(real64), intent(inout) :: surface(:, :, :), tracers(:, :, :)
    real(real64), intent(in) :: terrain(:), raw_terrain_x(:), raw_terrain_y(:), map_metric(:), coriolis(:)
    real(real64), intent(inout) :: terrain_x(:), terrain_y(:), surface_pressure_x(:), surface_pressure_y(:)
    type(native_hydrostatic_pressure_terms), intent(inout) :: terms
    type(hydrostatic_grid_outputs), intent(inout) :: output
    type(lagrangian_source_fields), intent(in) :: previous
    type(lagrangian_work_fields), intent(inout) :: work
    integer(int32), intent(out) :: status
    type(lagrangian_source_fields) :: local_previous
    integer :: i
    integer(int32) :: surface_indices(3)
    status = 2
    if (pitch < 1 .or. pitch > 256 .or. levels < 1 .or. levels > 512) return
    if (first < 1 .or. first > pitch .or. last < first - 1 .or. last > pitch .or. c%current_iteration < 0) return
    if (.not. c%two_time_levels .or. .not. c%semi_lagrangian) return
    if (c%boundary_coupling .or. c%top_sponge .or. c%nudging .or. c%large_scale_forcing) return
    if (c%nonhydrostatic .or. c%nonhydrostatic_euler .or. c%nonhydrostatic_quasi) return
    if (c%alternative_acceleration .or. c%finite_element_ecmwf .or. c%full_corrector) return
    if (c%diabatic .or. c%surface_physics .or. c%simple_physics .or. c%extra_diagnostics) return
    if (c%model_surface_equations .or. c%linearized_model) return
    if (c%stretch /= 1.0_real64) return
    if (.not. c%hydrostatic%pressure%finite_elements) return
    if (.not. c%filter%two_time_levels .or. c%filter%nonhydrostatic) return
    if (c%initialization%iteration /= c%current_iteration) return
    if (.not. c%initialization%semi_lagrangian .or. c%initialization%nonhydrostatic) return
    if (c%initialization%two_time_levels .neqv. c%two_time_levels) return
    if (.not. c%initialization%finite_elements) return
    if (.not. grid_update_environment_supported()) return
    if (size(motion, 1) /= pitch .or. size(motion, 2) /= levels) return
    if (size(surface, 1) /= pitch .or. size(surface, 2) /= 1) return
    if (size(tracers, 1) /= pitch .or. size(tracers, 2) /= levels) return
    surface_indices = [surface_map%log_pressure, surface_map%log_gradient_x, surface_map%log_gradient_y]
    if (any(surface_indices < 1) .or. any(surface_indices > size(surface, 3))) return
    if (size(terrain) < pitch .or. size(raw_terrain_x) < pitch .or. size(raw_terrain_y) < pitch) return
    if (size(map_metric) < pitch .or. size(coriolis) < pitch) return
    if (size(terrain_x) < pitch .or. size(terrain_y) < pitch) return
    if (size(surface_pressure_x) < pitch .or. size(surface_pressure_y) < pitch) return
    if (.not. vertical_supported(vertical, levels)) return
    if (.not. associated(output%half_pressure) .or. .not. associated(output%full_pressure)) return
    if (.not. associated(output%continuity)) return
    if (.not. is_contiguous(output%full_pressure) .or. .not. is_contiguous(output%continuity)) return
    if (c%current_iteration == 0) then
      call apply_time_filter_second(c%filter, c%filter_maps, tracer_filter_pairs, c%first_step, &
                                    pitch, first, last, levels, c%filter_weights, motion, surface, tracers, status)
      if (status /= 0) return
    end if
    do i = first, last
      terrain_x(i) = raw_terrain_x(i)*map_metric(i)
      terrain_y(i) = raw_terrain_y(i)*map_metric(i)
    end do
    call convert_surface_pressure(pitch, first, last, levels, .false., &
                                  surface(:, 1, surface_map%log_pressure), surface(:, 1, surface_map%log_gradient_x), &
                    surface(:, 1, surface_map%log_gradient_y), output%half_pressure, surface_pressure_x, surface_pressure_y, status)
    if (status /= 0) return
    call compute_hydrostatic_grid(c%hydrostatic, motion_map, pitch, first, last, levels, constants, &
                                  thermal_components, tables, vertical%vah, vertical%vbh, vertical%vc, vertical%vaf, vertical%vbf, &
                                  vertical%vdela, vertical%vdelb, vertical%inverse_coordinate_depth, vertical%metric, &
            motion, tracers, terrain, terrain_x, terrain_y, surface_pressure_x, surface_pressure_y, coriolis, terms, output, status)
    if (status /= 0) return
    local_previous = previous
    local_previous%full_pressure%values => output%full_pressure
    local_previous%vertical_velocity%values => output%continuity(:, 1:levels, 2)
    call initialize_lagrangian_work(c%initialization, c%bank_slots, work_components, c%water_components, &
                                    pitch, first, last, levels, c%update_factor, .false., tracers, local_previous, work, status)
  end subroutine

  logical function vertical_supported(v, l) result(ok)
    type(forecast_grid_vertical_inputs), intent(in) :: v
    integer, intent(in) :: l
    ok = .false.
    if (.not. associated(v%vah) .or. .not. associated(v%vbh) .or. .not. associated(v%vc)) return
    if (.not. associated(v%vaf) .or. .not. associated(v%vbf)) return
    if (.not. associated(v%vdela) .or. .not. associated(v%vdelb)) return
    if (.not. associated(v%inverse_coordinate_depth) .or. .not. associated(v%metric)) return
    if (lbound(v%vah, 1) /= 0 .or. ubound(v%vah, 1) < l .or. lbound(v%vbh, 1) /= 0 .or. ubound(v%vbh, 1) < l) return
    if (lbound(v%vc, 1) /= 1 .or. size(v%vc) < l) return
    if (lbound(v%vaf, 1) /= 1 .or. size(v%vaf) < l .or. lbound(v%vbf, 1) /= 1 .or. size(v%vbf) < l) return
    if (lbound(v%vdela, 1) /= 1 .or. size(v%vdela) < l .or. lbound(v%vdelb, 1) /= 1 .or. size(v%vdelb) < l) return
    if (lbound(v%inverse_coordinate_depth, 1) /= 1 .or. size(v%inverse_coordinate_depth) < l) return
    if (lbound(v%metric, 1) /= 1 .or. size(v%metric) < l) return
    ok = .true.
  end function
end module forecast_grid_calculations
