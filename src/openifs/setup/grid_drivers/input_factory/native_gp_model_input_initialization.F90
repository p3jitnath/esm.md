!> Compose the actual GP input descriptors from one forecast execution's owners.
!! This module owns no weather payload or second model. Temporary filter scalars
!! are produced by the real SUDYN source and copied into their actual consumers.
module forecast_native_gp_model_input_initialization
  use iso_fortran_env, only: int32, int64
  use mpi_f08, only: MPI_Comm
  use forecast_native_gp_factory_types, only: native_gp_factory_work
  use forecast_native_gp_input_factory, only: prepare_native_gp_weather_bindings
  use forecast_complete_forecast_grid_driver_strided, only: native_forecast_grid_inputs
  use forecast_native_startup_storage, only: native_forecast_startup_storage
  use forecast_spectral_setup_state, only: native_spectral_calculation_state
  use forecast_remaining_dynamics_controls, only: native_remaining_dynamics_controls
  use forecast_complete_physics_context_types, only: native_complete_physics_driver_inputs
  use native_radiation_forecast_driver, only: native_radiation_driver_context
  use forecast_grid_work_state, only: native_grid_work_state
  use forecast_interpolation_coefficient_table_types, only: native_interpolation_coefficient_tables
  use forecast_dynamical_diagnostic_storage, only: native_dynamical_diagnostic_controls, native_dynamical_diagnostic_storage
  use forecast_native_field_variable_types, only: native_registry_extra_aliases
  use forecast_parallel_interpolation_controls, only: parallel_interpolation_controls
  use forecast_native_flux_storage, only: native_forecast_flux_controls
  use forecast_source_time_filter_weights, only: native_time_filter_weights, initialize_source_time_filter_weights
  use forecast_native_cpg_control_binding, only: bind_native_cpg_controls, bind_native_cpg_flux_controls
  use forecast_native_transport_input_binding, only: bind_native_transport_inputs
  use forecast_actual_native_registry_acquisition, only: prepare_actual_native_registry
  implicit none
  private
  public :: prepare_native_gp_model_input_bindings, initialize_native_gp_model_inputs
contains
  !> Complete static source views after weather preparation,without READY.
 !! The same final-address TARGET records are used by the execution owner.
 !! Tables,diagnostic arrays,flux flags and alias records must come from their
 !! actual completed producers. Seconds remain in the canonical clock;its
 !! undefined constructor step is not read by any setup stage here.
  subroutine prepare_native_gp_model_input_bindings(work, grid, startup, spectral, remaining, physics, radiation, &
                       storage, tables, diagnostic_controls, diagnostic_storage, registry_aliases, parallel_policy, flux_controls, &
                                                    lnsponge, cellular_departure_copy, byte_quota, communicator, status)
    type(native_gp_factory_work), target, intent(inout) :: work
    type(native_forecast_grid_inputs), target, intent(inout) :: grid
    type(native_forecast_startup_storage), target, intent(inout) :: startup
    type(native_spectral_calculation_state), target, intent(inout) :: spectral
    type(native_remaining_dynamics_controls), intent(in) :: remaining
    type(native_complete_physics_driver_inputs), target, intent(inout) :: physics
    type(native_radiation_driver_context), target, intent(inout) :: radiation
    type(native_grid_work_state), target, intent(inout) :: storage
    type(native_interpolation_coefficient_tables), target, intent(inout) :: tables
    type(native_dynamical_diagnostic_controls), intent(in) :: diagnostic_controls
    type(native_dynamical_diagnostic_storage), target, intent(inout) :: diagnostic_storage
    type(native_registry_extra_aliases), intent(in) :: registry_aliases
    type(parallel_interpolation_controls), intent(in) :: parallel_policy
    type(native_forecast_flux_controls), target, intent(inout) :: flux_controls
    logical, intent(in) :: lnsponge, cellular_departure_copy
    integer(int64), intent(in) :: byte_quota
    type(MPI_Comm), intent(in) :: communicator
    integer(int32), intent(out) :: status
    type(native_time_filter_weights) :: time_weights
    integer :: n
    status = 2
    if (work%ready) return
    if (work%phase == 0) then
      call prepare_native_gp_weather_bindings(work, grid, startup, spectral, physics, radiation, storage, &
                                              byte_quota, communicator, status)
      if (status /= 0) return
    end if
    if (work%phase /= 3 .or. .not. work%maps_bound .or. .not. work%columns_bound) return
    if (.not. associated(grid%model, startup%loaded%storage%model)) return
    if (.not. associated(grid%physics, physics) .or. .not. associated(grid%radiation, radiation)) return
    if (.not. remaining%ready .or. .not. tables%ready .or. .not. parallel_policy%ready) return
    n = startup%initial%prefix%configuration_bytes
    if (n < 1 .or. n > len(startup%initial%prefix%configuration_text)) return
    status = initialize_source_time_filter_weights(startup%initial%prefix%configuration_text(1:n), &
                            startup%initial%controls%namespace%lecmwf == 1, grid%model%dynamics%lslag, grid%model%dynamics%ltwotl, &
                                       startup%loaded%input%lagrangian%nitmp, startup%loaded%input%lagrangian%lmascor, time_weights)
    if (status /= 0) return
    call bind_native_cpg_controls(grid, startup, remaining, work%dynamics_maps, diagnostic_controls, &
                                  time_weights, lnsponge, status)
    if (status /= 0) return
    call bind_native_cpg_flux_controls(grid, flux_controls, status)
    if (status /= 0) return
    call bind_native_transport_inputs(grid, startup, tables, spectral, diagnostic_storage, remaining, &
                                      diagnostic_controls, parallel_policy, cellular_departure_copy, status)
    if (status /= 0) return
    ! The shared stage owns geometry, science and extra-alias projection.
    ! It reuses the same completed registry when the dedicated marker is true.
    status = prepare_actual_native_registry(grid, startup, work%registry_ready)
    if (status /= 0) return
    work%transport_bound = .true.
    work%controls_bound = .true.
    work%phase = 4
    status = 0
  end subroutine

  !> Publish descriptor readiness only after real EC and radiation bindings.
 !! This calls no weather calculation. Matching existing FIELDS registry and
 !! GRIDWORK are reused;their constructors remain their sole payload owners.
 !! The actual SCAN call refreshes source visit controls before GP_MODEL.
  subroutine initialize_native_gp_model_inputs(work, grid, startup, spectral, remaining, physics, radiation, &
                       storage, tables, diagnostic_controls, diagnostic_storage, registry_aliases, parallel_policy, flux_controls, &
                                               lnsponge, cellular_departure_copy, byte_quota, communicator, status)
    type(native_gp_factory_work), target, intent(inout) :: work
    type(native_forecast_grid_inputs), target, intent(inout) :: grid
    type(native_forecast_startup_storage), target, intent(inout) :: startup
    type(native_spectral_calculation_state), target, intent(inout) :: spectral
    type(native_remaining_dynamics_controls), intent(in) :: remaining
    type(native_complete_physics_driver_inputs), target, intent(inout) :: physics
    type(native_radiation_driver_context), target, intent(inout) :: radiation
    type(native_grid_work_state), target, intent(inout) :: storage
    type(native_interpolation_coefficient_tables), target, intent(inout) :: tables
    type(native_dynamical_diagnostic_controls), intent(in) :: diagnostic_controls
    type(native_dynamical_diagnostic_storage), target, intent(inout) :: diagnostic_storage
    type(native_registry_extra_aliases), intent(in) :: registry_aliases
    type(parallel_interpolation_controls), intent(in) :: parallel_policy
    type(native_forecast_flux_controls), target, intent(inout) :: flux_controls
    logical, intent(in) :: lnsponge, cellular_departure_copy
    integer(int64), intent(in) :: byte_quota
    type(MPI_Comm), intent(in) :: communicator
    integer(int32), intent(out) :: status
    status = 2
    if (work%ready) return
    if (.not. work%controls_bound .or. .not. work%transport_bound) then
      call prepare_native_gp_model_input_bindings(work, grid, startup, spectral, remaining, physics, radiation, &
                       storage, tables, diagnostic_controls, diagnostic_storage, registry_aliases, parallel_policy, flux_controls, &
                                                  lnsponge, cellular_departure_copy, byte_quota, communicator, status)
      if (status /= 0) return
    end if
    if (work%phase /= 4 .or. .not. work%registry_ready) return
    if (.not. associated(physics%records%model, grid%model)) return
    if (.not. associated(physics%physics, startup%loaded%storage%ecmwf)) return
    if (.not. associated(physics%providers) .or. .not. associated(physics%post_controls)) return
    if (.not. associated(physics%runtime) .or. .not. associated(physics%lnodryflx)) return
    if (.not. associated(radiation%setup)) return
    if (.not. associated(grid%blocks%reset_requests) .or. .not. associated(grid%blocks%flux_reset)) return
    work%ready = .true.
    work%phase = 5
    status = 0
  end subroutine
end module forecast_native_gp_model_input_initialization
