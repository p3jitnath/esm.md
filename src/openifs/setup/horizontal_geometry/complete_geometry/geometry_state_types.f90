!> Canonical native geometry ownership shared by setup and forecast callers.
module forecast_geometry_state_types
  use iso_c_binding, only: c_int, c_double
  use forecast_grid_dimensions, only: native_grid_dimensions
  use forecast_spherical_grid_configuration, only: native_spherical_grid_configuration
  use forecast_global_grid_cutoffs, only: native_global_grid_cutoffs
  use forecast_public_transform, only: native_transform_control, native_transform_resolution
  use forecast_distributed_partition_types, only: native_distributed_partition
  use forecast_geometry_stream, only: native_geometry_stream
  use forecast_latitude_geometry, only: native_latitude_geometry
  use forecast_laplacian_geometry, only: native_laplacian_geometry
  use forecast_standard_atmosphere_setup, only: standard_atmosphere_state
  use forecast_spherical_grid_setup, only: native_spherical_grid_state
  use forecast_spectral_geometry_maps, only: native_spectral_geometry_maps
  use forecast_spherical_geometry_setup, only: native_spherical_geometry
  use forecast_orography_storage, only: native_orography_storage
  use forecast_vertical_coordinate_storage, only: native_vertical_state
  implicit none
  private
  public :: native_geometry_state
  !> Own native horizontal state while borrowing the live vertical state.
  !! dimensions holds global SUDIM counts. partition owns the separate local
  !! process, level, wave, row and point maps. No second grid schema is defined.
  !! Each nested type retains its own array bounds, units and lifetime contract.
  !! The caller declares this owner TARGET and keeps its address stable while
  !! spherical block views or the borrowed vertical pointer remain in use.
  !! escgmap(3) is the named TYPE_SPGEOM declaration. Its global route is
  !! source-unwritten and remains outside the spectral-map child.
  type :: native_geometry_state
    type(native_grid_dimensions) :: dimensions
    type(native_spherical_grid_configuration) :: configuration
    type(native_global_grid_cutoffs) :: cutoffs
    type(native_transform_control) :: transform_control
    type(native_transform_resolution) :: transform_resolution
    type(native_distributed_partition) :: partition
    type(native_geometry_stream) :: stream
    type(native_latitude_geometry) :: latitudes
    type(native_laplacian_geometry) :: laplacian
    type(standard_atmosphere_state) :: atmosphere
    type(native_spherical_grid_state) :: grid
    type(native_spectral_geometry_maps) :: spectral_maps
    type(native_spherical_geometry) :: spherical
    type(native_orography_storage) :: terrain
    type(native_vertical_state), pointer :: vertical => null()
    real(c_double) :: escgmap(3)
    integer(c_int) :: latitude_first = 0, latitude_last = -1
    logical :: initialized = .false.
  end type
end module forecast_geometry_state_types
