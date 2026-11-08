!> Resolve a named field in the actual produced native surface catalog.
!! This helper reads metadata only and owns no field or calculated value.
module forecast_surface_catalog_lookup
  use iso_fortran_env, only: int32
  use surface_field_configuration_port, only: surface_field_registry
  implicit none
  private
  public :: surface_catalog_index
contains
  !> Select one real field through the actual catalog alias and its native index.
  integer(int32) function surface_catalog_index(catalog, name, index_kind, i, j) result(column)
    type(surface_field_registry), intent(in) :: catalog
    character(len=*), intent(in) :: name
    integer(int32), intent(in) :: index_kind
    integer(int32), optional, intent(in) :: i, j
    integer :: a, g, f, ii, jj
    column = 0_int32; ii = 1; jj = 1
    if (present(i)) ii = i
    if (present(j)) jj = j
    do a = 1, size(catalog%aliases)
      if (catalog%aliases(a)%name /= name) cycle
      g = catalog%aliases(a)%group
      if (g < 1 .or. g > size(catalog%groups)) return
      if (.not. allocated(catalog%groups(g)%fields)) return
      if (ii < 1 .or. ii > catalog%aliases(a)%extent1 .or. jj < 1 .or. jj > catalog%aliases(a)%extent2) return
      f = catalog%aliases(a)%first_field + ii - 1 + (jj - 1)*catalog%aliases(a)%extent1
      if (f < 1 .or. f > size(catalog%groups(g)%fields)) return
      if (index_kind < 1 .or. index_kind > size(catalog%groups(g)%fields(f)%indices)) return
      column = catalog%groups(g)%fields(f)%indices(index_kind)
      return
    end do
  end function

end module forecast_surface_catalog_lookup
