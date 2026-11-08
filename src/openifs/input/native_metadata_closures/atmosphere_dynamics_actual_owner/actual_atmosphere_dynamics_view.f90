!> Borrow the existing produced atmosphere tables and the one actual GP map.
module forecast_actual_atmosphere_dynamics_view
  use iso_fortran_env, only: int32
  use forecast_standard_atmosphere, only: atmosphere_layers
  use forecast_dynamics_field_maps, only: native_dynamics_field_maps
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_native_gp_factory_types, only: native_gp_factory_work
  implicit none
  private
  public :: native_actual_atmosphere_dynamics_view, project_actual_atmosphere_dynamics
  public :: release_actual_atmosphere_dynamics_view, actual_atmosphere_dynamics_view_matches
  !> Read-only aliases to existing canonical records; this type owns no payload.
 !! The caller must not write through, deallocate or rebind these targets.
 !! Reference heights use metres, gradients K/m, temperatures K and pressures Pa.
 !! The 28 dynamics records contain dimensionless int32 field selectors.
 !! Targets must remain at their final addresses until this view is released.
  type :: native_actual_atmosphere_dynamics_view
    type(atmosphere_layers), pointer, contiguous :: references(:) => null()
    type(native_dynamics_field_maps), pointer :: maps => null()
  end type
contains
  !> Bind the actual produced targets without allocation, copying or calculation.
 !! view is fresh on entry and acquires only read-only aliases on success.
 !! geometry and work are read-only TARGET owners. work%maps_bound is published
 !! by the real GP factory only after its genuine map initializer succeeds.
 !! Return0 succeeds. Return2 refuses without changing owners or the view.
  integer(int32) function project_actual_atmosphere_dynamics(view, geometry, work) result(status)
    type(native_actual_atmosphere_dynamics_view), intent(inout) :: view
    type(native_geometry_state), target, intent(in) :: geometry
    type(native_gp_factory_work), target, intent(in) :: work
    status = 2
    if (associated(view%references) .or. associated(view%maps)) return
    if (.not. geometry%initialized .or. .not. work%maps_bound) return
    view%references => geometry%atmosphere%reference_tables
    view%maps => work%dynamics_maps
    status = 0
  end function
  !> Identify the exact current targets; no scientific value or owner changes.
  logical function actual_atmosphere_dynamics_view_matches(view, geometry, work) result(matches)
    type(native_actual_atmosphere_dynamics_view), intent(in) :: view
    type(native_geometry_state), target, intent(in) :: geometry
    type(native_gp_factory_work), target, intent(in) :: work
    matches = .false.
    if (.not. associated(view%references) .or. .not. associated(view%maps)) return
    if (.not. work%maps_bound .or. .not. geometry%initialized) return
    if (.not. associated(view%references, geometry%atmosphere%reference_tables)) return
    if (.not. associated(view%maps, work%dynamics_maps)) return
    matches = .true.
  end function
  !> Retire aliases before either upstream target is moved or released.
  subroutine release_actual_atmosphere_dynamics_view(view)
    type(native_actual_atmosphere_dynamics_view), intent(inout) :: view
    nullify (view%references, view%maps)
  end subroutine
end module forecast_actual_atmosphere_dynamics_view
