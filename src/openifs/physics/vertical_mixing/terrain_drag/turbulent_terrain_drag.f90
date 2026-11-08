!> Turbulent drag from unresolved terrain, with the frozen scalar order.
module forecast_turbulent_terrain_drag
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double
  use yoevdf, only: tvdf
  implicit none
  private
  public :: vdftofdc
  interface
    function public_power(base, exponent) bind(C, name='pow') result(value)
      import c_double
      real(c_double), value :: base, exponent
      real(c_double) :: value
    end function
    function public_exponential(argument) bind(C, name='exp') result(value)
      import c_double
      real(c_double), value :: argument
      real(c_double) :: value
    end function
  end interface
contains
  !> Fill the complete terrain-drag matrix, including unselected columns.
  !! VDF is the caller's native diffusion parameter record. Winds and
  !! geopotential are readonly (KLON,KLEV), terrain variation is (KLON), and
  !! DRAG is caller-owned INOUT (KLON,KLEV). RG is m/s**2, RPLRG is a
  !! dimensionless planetary scale, and terrain variation is metres.
  !! Support KLON0:4096, KLEV0:1024 and a possibly empty selected interval.
  !! Inputs may alias each other. DRAG must be disjoint from every input.
  !! The caller establishes nearest-even, gradual underflow and the finite
  !! physical domain in the frozen VDFTOFDC contract. Return2 before writes
  !! for unsupported shapes/strides/bounds,0 on completion. Public C POW
  !! and EXP must have qualified consumed-domain bytes and natural status.
  integer(int32) function vdftofdc(vdf, kidia, kfdia, klon, klev, pum1, pvm1, pgeom1, psigflt, ptofdc, rg, rplrg) result(status)
    type(tvdf), intent(in) :: vdf
    integer(int32), intent(in) :: kidia, kfdia, klon, klev
    real(real64), intent(in) :: pum1(:, :), pvm1(:, :), pgeom1(:, :), psigflt(:), rg, rplrg
    real(real64), intent(inout) :: ptofdc(:, :)
    real(real64) :: coefficient(max(1, min(klon, 4096))), selected(max(1, min(klon, 4096)))
    real(real64) :: factor, height_scale, cutoff, height, speed, temporary, first_power, decay, last_power
    real(real64), parameter :: cmd = transfer(int(z'3f747ae140000000', int64), 0.0_real64)
    real(real64), parameter :: correction = transfer(int(z'3fe3333340000000', int64), 0.0_real64)
    real(real64), parameter :: integral = transfer(int(z'4000df3b60000000', int64), 0.0_real64)
    real(real64), parameter :: fact1 = transfer(int(z'3eb7f28871d058fb', int64), 0.0_real64)
    real(real64), parameter :: speed_floor = transfer(int(z'3f847ae147ae147c', int64), 0.0_real64)
    real(real64), parameter :: exponent = transfer(int(z'bff3333340000000', int64), 0.0_real64)
    integer :: j, k
    status = 2_int32
    if (klon < 0 .or. klon > 4096 .or. klev < 0 .or. klev > 1024) return
    if (kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon) return
    if (.not. is_contiguous(pum1) .or. .not. is_contiguous(pvm1)) return
    if (.not. is_contiguous(pgeom1) .or. .not. is_contiguous(psigflt) .or. .not. is_contiguous(ptofdc)) return
    if (size(pum1, 1) < klon .or. size(pum1, 2) < klev .or. size(pvm1, 1) < klon .or. size(pvm1, 2) < klev) return
    if (size(pgeom1, 1) < klon .or. size(pgeom1, 2) < klev .or. size(ptofdc, 1) < klon .or. size(ptofdc, 2) < klev) return
    if (size(psigflt) < klon) return
    factor = vdf%rtofdalpha*cmd
    factor = factor*correction
    factor = factor*integral
    factor = factor*fact1
    height_scale = 1500.0_real64/rplrg
    cutoff = 5000.0_real64/rplrg
    do j = kidia, kfdia
      temporary = psigflt(j)*psigflt(j)
      coefficient(j) = factor*temporary
    end do
    do k = 1, klev
      do j = kidia, kfdia
        height = pgeom1(j, k)/rg
        if (height <= cutoff) then
          ! Repeat the admitted height division as in the source gather/body.
          height = pgeom1(j, k)/rg
          speed = pum1(j, k)*pum1(j, k)
          temporary = pvm1(j, k)*pvm1(j, k)
          speed = speed + temporary
          speed = max(speed, speed_floor)
          speed = sqrt(speed)
          temporary = height/height_scale
          first_power = public_power(temporary, 1.5_real64)
          decay = public_exponential(-first_power)
          last_power = public_power(height, exponent)
          temporary = speed*coefficient(j)
          temporary = temporary*decay
          selected(j) = temporary*last_power
        else
          selected(j) = 0.0_real64
        end if
      end do
      do j = 1, klon
        ptofdc(j, k) = 0.0_real64
      end do
      do j = kidia, kfdia
        ptofdc(j, k) = selected(j)
      end do
    end do
    status = 0_int32
  end function vdftofdc
end module forecast_turbulent_terrain_drag
