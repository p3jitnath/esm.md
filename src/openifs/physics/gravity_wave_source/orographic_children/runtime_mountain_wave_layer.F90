!> Forward actual native mountain-wave fields to the complete owned calculation.
module md2asm_runtime_mountain_wave_layer
  use iso_fortran_env, only: int32, real64
  use yoegwd, only: tegwd
  use yoephli, only: tephli
  use physical_constant_setup_port, only: forecast_physical_constants
  use forecast_physics_work_types, only: dimension_type, aux_type, state_type, surf_and_more_type, aux_diag_local_type
  use forecast_native_field_variable_types, only: native_surface_variables
  use md2asm_mountain_wave_drag, only: gwdrag
  implicit none
  private
  public :: runtime_mountain_wave_layer
contains
!> Bind surface variance, anisotropy and direction to the native registry block.
!! Read-only STATE T/U/V use K and m/s; pressures use Pa and geopotential m2/s2.
!! SURFACE gamma and AUXL coefficients are INOUT as in the complete source.
!! The child retains the empty-interval scalar prefix and inactive cells.
!! Columns1:128,levels6:512 and empty/full/cropped intervals are supported.
!! Caller supplies source-admitted parameters, disjoint fields and FP mode.
  subroutine runtime_mountain_wave_layer(physical, surface, linear, parameters, dim, aux, state, surfwork, auxl, status)
    type(forecast_physical_constants), intent(in) :: physical
    type(native_surface_variables), intent(inout) :: surface
    type(tephli), intent(in) :: linear
    type(tegwd), intent(in) :: parameters
    type(dimension_type), intent(in) :: dim
    type(aux_type), intent(in) :: aux
    type(state_type), intent(in) :: state
    type(surf_and_more_type), intent(in) :: surfwork
    type(aux_diag_local_type), intent(inout) :: auxl
    integer(int32), intent(out) :: status
    integer :: p, l
    status = 2; p = dim%klon; l = dim%klev
    if (p < 1 .or. p > 128 .or. l < 6 .or. l > 512) return
    if (dim%kidia < 1 .or. dim%kidia > p + 1 .or. dim%kfdia < dim%kidia - 1 .or. dim%kfdia > p) return
    if (.not. associated(aux%paprs) .or. .not. associated(aux%paprsf) .or. .not. associated(aux%pgeom1)) return
    if (.not. associated(state%t) .or. .not. associated(state%u) .or. .not. associated(state%v)) return
    if (.not. associated(surfwork%phstd)) return
    if (.not. associated(surface%gsd_vf%vvrlan%p) .or. .not. associated(surface%gsd_vf%vvrldi%p)) return
    if (.not. associated(surface%gsd_vf%vsig%p)) return
    if (.not. associated(auxl%zsoteu) .or. .not. associated(auxl%zsotev) .or. .not. associated(auxl%zsobeta)) return
    if (lbound(aux%paprs, 2) /= 0 .or. ubound(aux%paprs, 2) < l .or. size(aux%paprs, 1) /= p) return
    if (.not. full_field(aux%paprsf, p, l) .or. .not. full_field(aux%pgeom1, p, l)) return
    if (.not. full_field(state%t, p, l) .or. .not. full_field(state%u, p, l) .or. .not. full_field(state%v, p, l)) return
  if (.not. full_field(auxl%zsoteu, p, l) .or. .not. full_field(auxl%zsotev, p, l) .or. .not. full_field(auxl%zsobeta, p, l)) return
if (min(size(surfwork%phstd), size(surface%gsd_vf%vvrlan%p), size(surface%gsd_vf%vvrldi%p), size(surface%gsd_vf%vsig%p)) < p) return
    call gwdrag(physical, linear, parameters, dim%kidia, dim%kfdia, dim%klon, dim%klev, &
                aux%paprs, aux%paprsf, aux%pgeom1, state%t, state%u, state%v, surfwork%phstd, &
                surface%gsd_vf%vvrlan%p, surface%gsd_vf%vvrldi%p, surface%gsd_vf%vsig%p, &
                auxl%zsoteu, auxl%zsotev, auxl%zsobeta, status)
  end subroutine
  logical function full_field(a, p, l)
    real(real64), intent(in) :: a(:, :)
    integer, intent(in) :: p, l
    full_field = size(a, 1) == p .and. size(a, 2) >= l
  end function
end module
