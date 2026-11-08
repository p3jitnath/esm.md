!> Forward live source counts to the canonical physics work owners.
module runtime_physics_work_shape_counts_mod
  use iso_fortran_env, only: int32
  use yomphyder, only: dimension_type
  use yoerad, only: terad
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_operational_model_types, only: native_operational_model_configuration
  use surface_field_configuration_port, only: surface_field_registry
  use physics_grid_dimension_helpers_mod, only: surface_group_index
  implicit none
  private
  public :: bind_runtime_physics_work_shape_counts
contains
  !> COUNTS has exactly8 int32 elements in original work-constructor order.
  !! They are NLEV,NLEVS,NACTAERO,NPAERODIAG,NLEVSN,NTILES,NTSW,NLWEMISS.
  !! All are dimensionless. Only NPAERODIAG is the source parameter8.
  !! All other words come from the actual readonly native owners. The caller
  !! validates later allocation products and retains these same owners.
  integer(int32) function bind_runtime_physics_work_shape_counts(counts,geometry,model,surface,dimensions,radiation) result(status)
    integer(int32), intent(inout) :: counts(:)
    type(native_geometry_state), target, intent(in) :: geometry
    type(native_operational_model_configuration), intent(in) :: model
    type(surface_field_registry), intent(in) :: surface
    type(dimension_type), intent(in) :: dimensions
    type(terad), intent(in) :: radiation
    type(native_geometry_state), pointer :: model_geometry
    integer(int32) :: values(8)
    integer :: soil
    status = 2
    if (size(counts) /= 8) return
    if (.not. associated(model%initial)) return
    if (.not. allocated(model%initial%geometry)) return
    model_geometry => model%initial%geometry
    if (.not. associated(model_geometry, geometry)) return
    if (model%initial%controls%namespace%lecmwf /= 1_int32) return
    soil = surface_group_index(surface, 'YSP_SBD')
    if (soil == 0) return
    values = [geometry%dimensions%nflevg, surface%groups(soil)%metadata%layers, &
              model%fields%settings%nactaero, 8_int32, model%physics_dimensions%ncsnec, model%physics_dimensions%ntiles, &
              radiation%ntsw, radiation%nlwemiss]
    if (any(values < 0)) return
    if (dimensions%klev /= values(1) .or. dimensions%klevs /= values(2)) return
    if (dimensions%klevsn /= values(5) .or. dimensions%ktiles /= values(6)) return
    counts = values
    status = 0
  end function
end module runtime_physics_work_shape_counts_mod
