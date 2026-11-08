!> Bind the actual block latitude view using live native geometry counts.
module runtime_physics_dimension_binding_mod
  use iso_fortran_env, only: int32, int64
  use iso_c_binding, only: c_loc, c_associated
  use yomphyder, only: dimension_type
  use forecast_geometry_state_types, only: native_geometry_state
  use physics_grid_dimension_helpers_mod, only: update_physics_dimensions
  implicit none
  private
  public :: update_runtime_physics_dimensions
contains
  !> BLOCK0 is zero-origin; OWNER and VIEW are the actual latitude pointers.
  !! Geometry supplies P,N,B. The selected VIEW must name OWNER(bP+1:bP+A),
  !! with one-origin bounds and unit stride. A is the active row count.
  !! Only KBL,KFDIA,KSTGLO and KGPLAT change. Status2 is prewrite refusal.
  integer(int32) function update_runtime_physics_dimensions(dimensions,geometry,block0,latitude_owner,latitude_view) result(status)
    type(dimension_type), intent(inout) :: dimensions
    type(native_geometry_state), intent(in) :: geometry
    integer(int32), intent(in) :: block0
    integer(int32), pointer, intent(in) :: latitude_owner(:), latitude_view(:)
    integer(int32) :: p, n, b, active, block, first
    integer(int64) :: start
    status = 2
    p = geometry%dimensions%nproma; n = geometry%partition%ngptot; b = geometry%partition%ngpblks
    if (p <= 0 .or. n <= 0 .or. b <= 0) return
    if (dimensions%klon /= p) return
    if (1_int64 + (int(n, int64) - 1_int64)/int(p, int64) /= int(b, int64)) return
    if (block0 < 0 .or. block0 >= b) return
    if (.not. associated(latitude_owner) .or. .not. associated(latitude_view)) return
    if (.not. is_contiguous(latitude_owner) .or. .not. is_contiguous(latitude_view)) return
    if (lbound(latitude_owner, 1) /= 1 .or. size(latitude_owner, kind=int64) /= int(n, int64)) return
    start = int(block0, int64)*int(p, int64)
    if (start >= int(n, int64)) return
    active = int(min(int(p, int64), int(n, int64) - start), int32)
    if (lbound(latitude_view, 1) /= 1 .or. size(latitude_view) /= active) return
    first = int(start + 1_int64, int32); block = block0 + 1_int32
    if (.not. c_associated(c_loc(latitude_owner(first)), c_loc(latitude_view(1)))) return
    status = update_physics_dimensions(dimensions, block, active, first, latitude_view)
  end function
end module runtime_physics_dimension_binding_mod
