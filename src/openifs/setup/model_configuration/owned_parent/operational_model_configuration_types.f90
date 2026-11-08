!> Own model metadata while borrowing the one initial forecast context.
!! The caller retains INITIAL at a stable address until this owner is released.
!! Model field storage and physics setup consume these same named components.
module forecast_operational_model_types
  use iso_fortran_env, only: int32
  use forecast_initial_geometry_state, only: native_initial_geometry_state
  use forecast_distributed_partition_types, only: native_distributed_partition
  use dynamical_configuration_port, only: native_dynamical_configuration
  use forecast_operational_dynamics, only: native_dynamics_controls
  use physics_configuration_state_port, only: physics_configuration_state
  use forecast_operational_physics_configuration, only: native_operational_physics_output_requests
  use grid_field_configuration_types_port, only: grid_field_configuration
  use yomdimf, only: tdimf
  use yomdphy, only: tdphy
  use yomphy2, only: tphy2
  use native_inactive_startup_controls, only: native_nudging_controls, native_climate_coupling_controls
  use forecast_grid_motion_types, only: native_grid_motion_state
  use forecast_interpolation_state_types, only: native_interpolation_state
  use forecast_semi_lagrangian_buffer_types, only: native_interpolation_controls, native_semi_lagrangian_buffers
  use md2asm_internal_interpolation_plane_maps, only: linear_weight_plane_map, nonlinear_weight_plane_map, &
                                                      spherical_coordinate_plane_map, cartesian_coordinate_plane_map
  implicit none
  private
  public :: native_operational_model_configuration, native_surface_model_controls
  !> Source surface inputs: dimensionless counts, switches and missing marker.
  type :: native_surface_model_controls
    integer(int32) :: nflevg = 0, nundefld = 0, nstop = 0
    integer(int32) :: lwcou = 0, lwcou2w = 0, lwcouhmf = 0, lwcur = 0, lwstokes = 0, lwflux = 0
    integer(int32) :: laqua = 0, lifstraj = 0, lecmwf = 0
  end type
  !> Own configuration values, small parity arrays and the canonical motion owner.
  !! INITIAL owns constants, the only clock, initialization switches and geometry.
  !! FIELDS is GFL metadata; numerical GFL arrays have a separate storage owner.
  !! MOTION starts with maps only. Its runtime allocator later owns the FP64 fields.
  !! TPHY2 starts as fresh storage and is physically initialized later by SUPHY2.
  !! All allocatable owners must be released at their source positions before
  !! this configuration is released. This type has no original model finalizer.
  type :: native_operational_model_configuration
    type(native_initial_geometry_state), pointer :: initial => null()
    type(native_distributed_partition), pointer :: partition => null()
    type(native_dynamical_configuration) :: dynamical_core
    type(native_dynamics_controls) :: dynamics
    type(physics_configuration_state) :: physics
    type(native_operational_physics_output_requests) :: output_requests
    type(native_nudging_controls) :: nudging
    type(native_climate_coupling_controls) :: climate
    type(tdimf) :: field_dimensions
    type(tdphy) :: physics_dimensions
    type(tphy2) :: physics_auxiliary
    type(grid_field_configuration) :: fields
    type(native_grid_motion_state) :: motion
    type(native_interpolation_state) :: interpolation
    type(native_interpolation_controls) :: interpolation_controls
    type(native_semi_lagrangian_buffers) :: buffers
    type(linear_weight_plane_map) :: linear_full, linear_half
    type(nonlinear_weight_plane_map) :: nonlinear_full, nonlinear_half
    type(spherical_coordinate_plane_map) :: spherical_planes
    type(cartesian_coordinate_plane_map) :: cartesian_planes
    type(native_surface_model_controls) :: surface_controls
    integer(int32) :: physics_counts(5) = 0, field_effects(10) = 0
    integer(int32) :: trajectory_count = 0, packing_word = 0, nsupersede = 1
    integer(int32) :: terrain_vertical_index = 0, terrain_vertical_count = 0
    logical :: lrsiddh = .false., packing_controls_ready = .false., terrain_controls_ready = .false.
    logical :: ready = .false.
  end type
end module forecast_operational_model_types
