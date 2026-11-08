!> Bind all21 registry geometry inputs to their actual produced owners.
!! No numerical array is packed, allocated, initialized or copied.
!! Geometry owns18 padded spherical arrays; the actual runtime input stage8
!! owns the3 padded orography arrays. Their final-block tails stay untouched.
!! STARTUP remains a live TARGET until registry metadata is released.
module forecast_native_registry_geometry_binding
  use iso_fortran_env, only: int32
  use forecast_native_startup_storage, only: native_forecast_startup_storage
  use forecast_complete_forecast_grid_driver_strided, only: native_forecast_grid_inputs
  use forecast_native_field_variable_types, only: native_registry_geometry_inputs
  implicit none
  private
  public :: bind_native_registry_geometry_inputs
contains
  !> Return2 before pointer publication for a missing producer or wrong bounds.
 !! Success0 publishes only REGISTRY_GEOMETRY. It does not mark registry,
 !! physics,aliases or the complete GP input factory ready.
  integer(int32) function bind_native_registry_geometry_inputs(grid, startup) result(status)
    type(native_forecast_grid_inputs), target, intent(inout) :: grid
    type(native_forecast_startup_storage), target, intent(inout) :: startup
    type(native_registry_geometry_inputs) :: pending
    integer(int32) :: p, b, n
    status = 2
    if (.not. allocated(startup%initial)) return
    if (.not. allocated(startup%initial%geometry)) return
    if (.not. allocated(startup%loaded%storage)) return
    if (.not. allocated(startup%loaded%input)) return
    if (.not. associated(grid%model, startup%loaded%storage%model)) return
    if (startup%loaded%input%phase < 9) return
    associate (g => startup%initial%geometry)
      if (.not. g%initialized) return
      p = g%dimensions%nproma; b = g%partition%ngpblks; n = g%partition%ngptot
      if (p < 1 .or. p > 1024 .or. b < 1 .or. n < 1) return
      if (b /= (n - 1)/p + 1) return
      if (.not. allocated(g%spherical%blocked%rcori)) return
      if (any(shape(g%spherical%blocked%rcori) /= [p, b])) return
      if (any(lbound(g%spherical%blocked%rcori) /= [1, 1])) return
      if (.not. allocated(g%spherical%blocked%rcoric)) return
      if (any(shape(g%spherical%blocked%rcoric) /= [p, b])) return
      if (any(lbound(g%spherical%blocked%rcoric) /= [1, 1])) return
      if (.not. allocated(g%spherical%blocked%gemu)) return
      if (any(shape(g%spherical%blocked%gemu) /= [p, b])) return
      if (any(lbound(g%spherical%blocked%gemu) /= [1, 1])) return
      if (.not. allocated(g%spherical%blocked%gsqm2)) return
      if (any(shape(g%spherical%blocked%gsqm2) /= [p, b])) return
      if (any(lbound(g%spherical%blocked%gsqm2) /= [1, 1])) return
      if (.not. allocated(g%spherical%blocked%gelam)) return
      if (any(shape(g%spherical%blocked%gelam) /= [p, b])) return
      if (any(lbound(g%spherical%blocked%gelam) /= [1, 1])) return
      if (.not. allocated(g%spherical%blocked%gelat)) return
      if (any(shape(g%spherical%blocked%gelat) /= [p, b])) return
      if (any(lbound(g%spherical%blocked%gelat) /= [1, 1])) return
      if (.not. allocated(g%spherical%blocked%geclo)) return
      if (any(shape(g%spherical%blocked%geclo) /= [p, b])) return
      if (any(lbound(g%spherical%blocked%geclo) /= [1, 1])) return
      if (.not. allocated(g%spherical%blocked%geslo)) return
      if (any(shape(g%spherical%blocked%geslo) /= [p, b])) return
      if (any(lbound(g%spherical%blocked%geslo) /= [1, 1])) return
      if (.not. allocated(g%spherical%blocked%gm)) return
      if (any(shape(g%spherical%blocked%gm) /= [p, b])) return
      if (any(lbound(g%spherical%blocked%gm) /= [1, 1])) return
      if (.not. allocated(g%spherical%blocked%gmappa)) return
      if (any(shape(g%spherical%blocked%gmappa) /= [p, b])) return
      if (any(lbound(g%spherical%blocked%gmappa) /= [1, 1])) return
      if (.not. allocated(g%spherical%blocked%gomvrl)) return
      if (any(shape(g%spherical%blocked%gomvrl) /= [p, b])) return
      if (any(lbound(g%spherical%blocked%gomvrl) /= [1, 1])) return
      if (.not. allocated(g%spherical%blocked%gomvrm)) return
      if (any(shape(g%spherical%blocked%gomvrm) /= [p, b])) return
      if (any(lbound(g%spherical%blocked%gomvrm) /= [1, 1])) return
      if (.not. allocated(g%spherical%blocked%gnordl)) return
      if (any(shape(g%spherical%blocked%gnordl) /= [p, b])) return
      if (any(lbound(g%spherical%blocked%gnordl) /= [1, 1])) return
      if (.not. allocated(g%spherical%blocked%gnordm)) return
      if (any(shape(g%spherical%blocked%gnordm) /= [p, b])) return
      if (any(lbound(g%spherical%blocked%gnordm) /= [1, 1])) return
      if (.not. allocated(g%spherical%blocked%gnordlcl)) return
      if (any(shape(g%spherical%blocked%gnordlcl) /= [p, b])) return
      if (any(lbound(g%spherical%blocked%gnordlcl) /= [1, 1])) return
      if (.not. allocated(g%spherical%blocked%gnordmcl)) return
      if (any(shape(g%spherical%blocked%gnordmcl) /= [p, b])) return
      if (any(lbound(g%spherical%blocked%gnordmcl) /= [1, 1])) return
      if (.not. allocated(g%spherical%blocked%gnordmcm)) return
      if (any(shape(g%spherical%blocked%gnordmcm) /= [p, b])) return
      if (any(lbound(g%spherical%blocked%gnordmcm) /= [1, 1])) return
      if (.not. allocated(g%spherical%blocked%gaw)) return
      if (any(shape(g%spherical%blocked%gaw) /= [p, b])) return
      if (any(lbound(g%spherical%blocked%gaw) /= [1, 1])) return
      if (.not. allocated(startup%loaded%input%terrain%orog)) return
      if (any(shape(startup%loaded%input%terrain%orog) /= [p, b])) return
      if (any(lbound(startup%loaded%input%terrain%orog) /= [1, 1])) return
      if (.not. allocated(startup%loaded%input%terrain%orogl)) return
      if (any(shape(startup%loaded%input%terrain%orogl) /= [p, b])) return
      if (any(lbound(startup%loaded%input%terrain%orogl) /= [1, 1])) return
      if (.not. allocated(startup%loaded%input%terrain%orogm)) return
      if (any(shape(startup%loaded%input%terrain%orogm) /= [p, b])) return
      if (any(lbound(startup%loaded%input%terrain%orogm) /= [1, 1])) return
      pending%rcori => g%spherical%blocked%rcori
      pending%rcoric => g%spherical%blocked%rcoric
      pending%gemu => g%spherical%blocked%gemu
      pending%gsqm2 => g%spherical%blocked%gsqm2
      pending%gelam => g%spherical%blocked%gelam
      pending%gelat => g%spherical%blocked%gelat
      pending%geclo => g%spherical%blocked%geclo
      pending%geslo => g%spherical%blocked%geslo
      pending%gm => g%spherical%blocked%gm
      pending%gmappa => g%spherical%blocked%gmappa
      pending%gomvrl => g%spherical%blocked%gomvrl
      pending%gomvrm => g%spherical%blocked%gomvrm
      pending%gnordl => g%spherical%blocked%gnordl
      pending%gnordm => g%spherical%blocked%gnordm
      pending%gnordlcl => g%spherical%blocked%gnordlcl
      pending%gnordmcl => g%spherical%blocked%gnordmcl
      pending%gnordmcm => g%spherical%blocked%gnordmcm
      pending%gaw => g%spherical%blocked%gaw
      pending%orog => startup%loaded%input%terrain%orog
      pending%orogl => startup%loaded%input%terrain%orogl
      pending%orogm => startup%loaded%input%terrain%orogm
      grid%registry_geometry = pending
    end associate
    status = 0
  end function
end module forecast_native_registry_geometry_binding
