!> Register the actual loaded array owners once without copying weather fields.
module forecast_actual_native_registry_acquisition
  use iso_fortran_env, only: int32, real64
  use forecast_complete_forecast_grid_driver_strided, only: native_forecast_grid_inputs
  use forecast_native_startup_storage, only: native_forecast_startup_storage
  use forecast_native_registry_geometry_binding, only: bind_native_registry_geometry_inputs
  use forecast_actual_registry_metadata_aliases, only: bind_actual_registry_extra_aliases
  use forecast_actual_native_registry_science_views, only: bind_native_registry_science_inputs
  use forecast_native_field_registry, only: bind_native_field_registry_model, prepare_runtime_native_field_registry
  implicit none
  private
  public :: prepare_actual_native_registry
contains
  !> Acquire the one registry over the actual startup arrays and metadata.
  !! GRID and STARTUP remain TARGET at their final addresses until registry
  !! readers close. REGISTRY_READY is the dedicated canonical GP-work marker.
  !! Only this complete successful constructor may publish that marker true.
  !! False plus an existing variables or surface graph means a fatal partial
  !! acquisition; this entry refuses it without freeing or reacquiring owners.
  !! A true marker admits reuse only for the same model, geometry and registry.
  !! Numerical arrays keep their original units, shapes and source bounds.
  !! This entry borrows their existing storage; registry children own metadata.
  !! Return0 completes or reuses the registry. Return2 refuses a missing owner
  !! or partial graph; other nonzero child statuses are returned unchanged.
  integer(int32) function prepare_actual_native_registry(grid, startup, registry_ready) result(status)
    type(native_forecast_grid_inputs), target, intent(inout) :: grid
    type(native_forecast_startup_storage), target, intent(inout) :: startup
    logical, intent(inout) :: registry_ready
    real(real64), pointer :: gfl(:, :, :, :), gflt1(:, :, :, :)
    status = 2_int32
    if (.not. allocated(startup%initial)) return
    if (.not. startup%initial%ready) return
    if (.not. allocated(startup%initial%geometry)) return
    if (.not. allocated(startup%loaded%storage)) return
    if (.not. startup%loaded%storage%model%ready) return
    if (.not. associated(startup%loaded%fields)) return
    if (.not. allocated(startup%loaded%input)) return
    if (.not. allocated(startup%loaded%input%upper%fields%gfl)) return
    if (.not. allocated(startup%loaded%next%gflt1)) return
    if (.not. associated(startup%loaded%fields%state_model, startup%loaded%storage%model)) return
    if (.not. associated(startup%loaded%fields%geometry, startup%initial%geometry)) return
    if (registry_ready) then
      if (.not. associated(startup%loaded%fields%registry%variables)) return
      if (.not. associated(startup%loaded%fields%registry%surface)) return
      if (.not. associated(startup%loaded%fields%registry%model, startup%loaded%storage%model)) return
      if (.not. associated(startup%loaded%fields%registry%geometry, startup%initial%geometry)) return
      if (startup%loaded%fields%registry%nproma /= startup%initial%geometry%dimensions%nproma) return
      if (startup%loaded%fields%registry%nblocks /= startup%initial%geometry%partition%ngpblks) return
    else
      if (associated(startup%loaded%fields%registry%variables)) return
      if (associated(startup%loaded%fields%registry%surface)) return
    end if
    ! Bind only pointer heads. No global ready flag or payload owner changes.
    grid%model => startup%loaded%storage%model
    grid%fields => startup%loaded%input%upper%fields
    grid%next => startup%loaded%next
    grid%registry => startup%loaded%fields%registry
    grid%surface_metadata => startup%loaded%input%surface_metadata
    grid%surface_arrays => startup%loaded%input%surface_arrays
    if (registry_ready) then
      status = 0_int32
      return
    end if
    status = bind_native_registry_geometry_inputs(grid, startup)
    if (status /= 0_int32) return
    status = bind_actual_registry_extra_aliases(grid%model%fields, grid%surface_metadata, grid%registry_aliases)
    if (status /= 0_int32) return
    status = bind_native_registry_science_inputs(startup, grid%registry_physics, grid%registry_radiation)
    if (status /= 0_int32) return
    status = bind_native_field_registry_model(grid%registry, grid%model)
    if (status /= 0_int32) return
    gfl => grid%fields%gfl
    gflt1 => grid%next%gflt1
    status = prepare_runtime_native_field_registry(grid%registry, startup%initial%geometry, grid%model, &
                                                   grid%registry_geometry, gfl, gflt1, grid%surface_metadata, grid%surface_arrays, &
                                                   grid%registry_physics, grid%registry_radiation, grid%registry_aliases)
    if (status /= 0_int32) return
    registry_ready = .true.
  end function prepare_actual_native_registry
end module forecast_actual_native_registry_acquisition
