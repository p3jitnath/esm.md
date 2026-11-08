!> Source-ordered orographic gravity-wave stress profile.
!! Stress is in Pa, pressure in Pa, density in kg/m3 and projected wind in m/s.
!! Stability is frequency squared in s-2; terrain height is m and slope has no units.
module md2asm_gravity_wave_stress_profile
  use iso_fortran_env, only: int32, real64
  use yoephli, only: tephli
  use yoegwd, only: tegwd
  implicit none
  private
  public :: gwprofil
contains
  !> Change only selected active stress columns, retaining all other owner words.
  !! Native int32/logical(int32) vectors have KLON entries. Real64 matrices have
  !! first extent KLON and at least KLEV+1 rows; half pressure has lower bound0,
  !! while density, stability, wind, Richardson number and stress start at1.
  !! Supports KLON0:4096,KLEV2:1024 and any valid empty active interval.
  !! Caller supplies positive security values and the source-admitted physical
  !! inputs, disjoint output, aligned owners and the established FP mode.
  !! Status0 completes;2 refuses metadata before mutation. Records stay input-only.
  subroutine gwprofil(ydephli,ydegwd,kidia,kfdia,klon,klev,ldgwd,kkcrith,kcrit,kkenvh,kknu,kknu2,paphm1,prho,pstab,pvph,pri,ptau,pdmod,psig,phstd,status)
    type(tephli), intent(in) :: ydephli
    type(tegwd), intent(in) :: ydegwd
    integer(int32), intent(in) :: kidia, kfdia, klon, klev, kkcrith(:), kcrit(:), kkenvh(:), kknu(:), kknu2(:)
    logical(int32), intent(in) :: ldgwd(:)
    real(real64), intent(in) :: paphm1(:, 0:), prho(:, :), pstab(:, :), pvph(:, :), pri(:, :), pdmod(:), psig(:), phstd(:)
    real(real64), intent(inout) :: ptau(:, :)
    integer(int32), intent(out) :: status
    integer :: j, k
    real(real64) :: drag, orography, ground, normal, displacement, lower, richardson_root, amplitude, riwave
    real(real64) :: discriminant, quadratic_b, alpha, candidate, a, b, c, upper_tau, lower_tau, lower_pressure, span, stress_span
    status = 2
    if (klon < 0 .or. klon > 4096 .or. klev < 2 .or. klev > 1024) return
    if (kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon) return
   if(min(size(ldgwd),size(kkcrith),size(kcrit),size(kkenvh),size(kknu),size(kknu2),size(pdmod),size(psig),size(phstd))<klon) return
    if (size(paphm1, 1) /= klon .or. size(paphm1, 2) < klev + 1 .or. size(prho, 1) /= klon .or. size(prho, 2) < klev + 1) return
    if (size(pstab, 1) /= klon .or. size(pstab, 2) < klev + 1 .or. size(pvph, 1) /= klon .or. size(pvph, 2) < klev + 1) return
    if (size(pri, 1) /= klon .or. size(pri, 2) < klev + 1 .or. size(ptau, 1) /= klon .or. size(ptau, 2) < klev + 1) return
    do j = kidia, kfdia
      if (.not. ldgwd(j)) cycle
      if (kkcrith(j) < 1 .or. kkenvh(j) > klev + 1 .or. kkcrith(j) > kkenvh(j)) return
      if (kcrit(j) < 0 .or. kcrit(j) > klev .or. kknu(j) < 1 .or. kknu(j) > klev .or. kknu2(j) < 2 .or. kknu2(j) > klev + 1) return
    end do
    drag = ydegwd%gkdrag
    if (ydephli%lphylin) drag = ydephli%rlpdrag
    do j = kidia, kfdia
      if (.not. ldgwd(j)) cycle
      a = psig(j)*pdmod(j); a = a/4.0_real64
      b = max(phstd(j), 1.0_real64); orography = a/b
      ground = ptau(j, klev + 1)
      do k = klev, 2, -1
        if (k >= kknu2(j)) then
          ptau(j, k) = ground
        else
          a = drag*prho(j, k); b = sqrt(pstab(j, k)); a = a*b
          a = a*pvph(j, k); normal = a*orography
          lower = ptau(j, k + 1); a = max(normal, ydegwd%gssec); displacement = lower/a
          if (lower < ydegwd%gtsec .or. k <= kcrit(j)) then
            ptau(j, k) = 0.0_real64
          else
            richardson_root = sqrt(pri(j, k))
            a = pstab(j, k)*displacement; a = sqrt(a); amplitude = a/pvph(j, k)
            a = amplitude*richardson_root; a = 1.0_real64 + a; b = a*a
            a = 1.0_real64 - amplitude; a = pri(j, k)*a; riwave = a/b
            if (riwave < ydegwd%grcrit) then
              a = 4.0_real64/richardson_root; discriminant = a/ydegwd%grcrit
              a = ydegwd%grcrit*ydegwd%grcrit; a = 1.0_real64/a; discriminant = discriminant + a
              a = 4.0_real64/ydegwd%grcrit; discriminant = discriminant + a
              quadratic_b = 1.0_real64/ydegwd%grcrit; a = 2.0_real64/richardson_root; quadratic_b = quadratic_b + a
              quadratic_b = -quadratic_b; a = sqrt(discriminant); alpha = quadratic_b + a; alpha = 0.5_real64*alpha
              a = pvph(j, k)*alpha; a = a*a; a = a/pstab(j, k); candidate = normal*a
            else
              candidate = normal*displacement
            end if
            ptau(j, k) = min(candidate, lower)
          end if
        end if
      end do
      if (kkcrith(j) + 1 >= kkenvh(j)) cycle
      lower_tau = ptau(j, kkenvh(j)); upper_tau = ptau(j, kkcrith(j))
      lower_pressure = paphm1(j, kkenvh(j) - 1)
      span = paphm1(j, kkcrith(j) - 1) - lower_pressure; stress_span = upper_tau - lower_tau
      do k = kkcrith(j) + 1, kkenvh(j) - 1
        a = paphm1(j, k - 1) - lower_pressure; a = stress_span*a; a = a/span
        ptau(j, k) = lower_tau + a
      end do
    end do
    status = 0
  end subroutine
end module
