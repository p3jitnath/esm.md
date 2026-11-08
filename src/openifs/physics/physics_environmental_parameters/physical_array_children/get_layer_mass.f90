!> Convert a pressure difference in Pa to dry layer mass in kg/m2.
module forecast_dry_layer_mass
  use iso_fortran_env, only: int32, int64, real64
  implicit none
  private
  public :: get_layer_mass
contains
  !> Preserve the full INOUT owner outside the inclusive selected columns.
  !! Native signed-stride views are supported; all owners are disjoint.
  subroutine get_layer_mass(pressure_hl, istartcol, iendcol, layer_mass, status)
    real(real64), intent(in) :: pressure_hl(:, :)
    integer(int32), intent(in) :: istartcol, iendcol
    real(real64), intent(inout) :: layer_mass(:, :)
    integer(int32), intent(out) :: status
    integer :: j, k, layers
    real(real64) :: difference
    real(real64), parameter :: inverse_g = transfer(int(z'3fba1acfea981812', int64), 0.0_real64)
    status = 2
    layers = max(0, size(pressure_hl, 2) - 1)
    if (istartcol < 1 .or. istartcol > size(pressure_hl, 1) + 1) return
    if (iendcol < 0 .or. iendcol > size(pressure_hl, 1)) return
    if (size(layer_mass, 1) < iendcol .or. size(layer_mass, 2) < layers) return
    do k = 1, layers
      do j = istartcol, iendcol
        difference = pressure_hl(j, k + 1) - pressure_hl(j, k)
        layer_mass(j, k) = difference*inverse_g
      end do
    end do
    status = 0
  end subroutine
end module
