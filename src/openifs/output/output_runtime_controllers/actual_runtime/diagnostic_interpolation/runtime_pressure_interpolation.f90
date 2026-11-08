!> Preserve all four source pressure-coordinate interpolation methods.
module forecast_runtime_pressure_interpolation
  use iso_fortran_env, only: int32, real64
  use yomhook, only: lhook, dr_hook
  implicit none
  private
  public :: ppintp
contains
  !> Interpolate only active rows not marked below the lowest model level.
 !! Methods1/2 use Pa at half/full levels;3/4use log pressure there.
 !! Coordinate/input lower bounds are0; output inactive cells stay unchanged.
  subroutine ppintp(p, first, last, l, t, lo, methods, kbelow, selector, below, anybelow, &
                    target, xp, xpd, input, output, status)
    integer(int32), intent(in) :: p, first, last, l, t, lo, methods, selector
    integer(int32), intent(in) :: kbelow(:, :, :)
    logical, intent(in) :: below(:, :), anybelow(:)
    real(real64), intent(in) :: target(:, :), xp(:, 0:, :), xpd(:, 0:, :), input(:, 0:)
    real(real64), intent(inout) :: output(:, :)
    integer(int32), intent(out) :: status
    integer :: i, j, k
    real(real64) :: difference, delta, value, handle
    status = 2
    if (p < 1 .or. p > 4096 .or. l < 1 .or. l > 512 .or. t < 1 .or. t > 4096) return
    if (first < 1 .or. first > p + 1 .or. last < 0 .or. last > p .or. first > last + 1) return
    if (lo < 1 .or. lo > t + 1 .or. methods /= 4 .or. selector < 1 .or. selector > 4) return
    if (size(kbelow, 1) /= p .or. size(kbelow, 2) < t .or. size(kbelow, 3) < 4) return
    if (size(below, 1) /= p .or. size(below, 2) < t .or. size(anybelow) < t) return
    if (size(target, 1) /= p .or. size(target, 2) < t) return
    if (size(xp, 1) /= p .or. size(xp, 2) < l + 1 .or. size(xp, 3) < 4) return
    if (size(xpd, 1) /= p .or. size(xpd, 2) < l + 1 .or. size(xpd, 3) < 4) return
    if (size(input, 1) /= p .or. size(input, 2) < l + 1 .or. size(output, 1) /= p .or. size(output, 2) < t) return
    do j = lo, t
      do i = first, last
        if (anybelow(j)) then
          if (below(i, j)) cycle
        end if
        k = kbelow(i, j, selector)
        if (k < 1 .or. k > l) return
      end do
    end do
    if (lhook) call dr_hook('PPINTP', 0, handle)
    do j = lo, t
      do i = first, last
        if (anybelow(j)) then
          if (below(i, j)) cycle
        end if
        k = kbelow(i, j, selector)
        difference = input(i, k) - input(i, k - 1)
        delta = target(i, j) - xp(i, k, selector)
        value = difference*delta
        value = value*xpd(i, k - 1, selector)
        output(i, j) = input(i, k) + value
      end do
    end do
    if (lhook) call dr_hook('PPINTP', 1, handle)
    status = 0
  end subroutine
end module
