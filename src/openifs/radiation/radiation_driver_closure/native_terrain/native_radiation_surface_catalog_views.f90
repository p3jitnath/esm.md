!> Resolve native surface metadata by its exact source alias.
!! Variants1:4 are MP,MP0,MP9,MP1 in TYPE_SURF_MTL declaration order.
submodule(native_radiation_forecast_driver) native_radiation_surface_catalog_views
  implicit none
contains
  module procedure radiation_surface_index
  integer :: i, g, f
  index = 0
  if (.not. associated(context%surface_catalog)) return
  if (variant < 1 .or. variant > 4) return
  do i = 1, size(context%surface_catalog%aliases)
    if (trim(context%surface_catalog%aliases(i)%name) /= name) cycle
    g = context%surface_catalog%aliases(i)%group
    f = context%surface_catalog%aliases(i)%first_field
    if (g < 1 .or. g > size(context%surface_catalog%groups)) return
    if (.not. allocated(context%surface_catalog%groups(g)%fields)) return
    if (f < 1 .or. f > size(context%surface_catalog%groups(g)%fields)) return
    index = context%surface_catalog%groups(g)%fields(f)%indices(variant)
    return
  end do
  end procedure
end submodule
