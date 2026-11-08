!> Interpolate wind at an explicitly supplied height using geopotential.
module forecast_height_wind_interpolation
  use iso_fortran_env, only: int32, real64
  implicit none
  private
  public :: vdfvint
contains
  !> Profiles have shape(KLON,KLEV), wind is m/s and geopotential m2/s2.
  !! PZZ is m; RG is m/s2 and RPLRG dimensionless. Both length-KLON outputs
  !! are INOUT and retain unmatched/inactive cells. All owners are disjoint.
  subroutine vdfvint(kidia, kfdia, klon, klev, pum1, pvm1, pgeom1, pzz, puz, pvz, rg, rplrg, status)
    integer(int32), intent(in) :: kidia, kfdia, klon, klev
    real(real64), intent(in) :: pum1(:, :), pvm1(:, :), pgeom1(:, :), pzz, rg, rplrg
    real(real64), intent(inout) :: puz(:), pvz(:)
    integer(int32), intent(out) :: status
    real(real64), volatile :: scaled_gravity, target
    real(real64) :: low_distance, high_distance, denominator, upper, lower, value
    integer :: j, k
    status = 2
    if (klon < 1 .or. klon > 4096 .or. klev < 2 .or. klev > 512) return
    if (kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon) return
    if (any(shape(pum1) /= [klon, klev]) .or. any(shape(pvm1) /= [klon, klev])) return
    if (any(shape(pgeom1) /= [klon, klev]) .or. size(puz) /= klon .or. size(pvz) /= klon) return
    scaled_gravity = rg/rplrg
    target = pzz*scaled_gravity
    do j = kidia, kfdia
      do k = klev, 2, -1
        if (.not. (target < pgeom1(j, k - 1))) cycle
        if (target < pgeom1(j, k)) cycle
        low_distance = target - pgeom1(j, k)
        high_distance = pgeom1(j, k - 1) - target
        denominator = pgeom1(j, k - 1) - pgeom1(j, k)
        upper = pum1(j, k - 1)*low_distance
        lower = pum1(j, k)*high_distance
        value = upper + lower
        puz(j) = value/denominator
        upper = pvm1(j, k - 1)*low_distance
        lower = pvm1(j, k)*high_distance
        value = upper + lower
        pvz(j) = value/denominator
        exit
      end do
    end do
    status = 0
  end subroutine
end module
