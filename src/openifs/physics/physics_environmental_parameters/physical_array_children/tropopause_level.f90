!> Select the source thermal or humidity tropopause model level.
module forecast_tropopause_level
  use iso_fortran_env, only: int32, real64
  implicit none
  private
  public :: troplev
contains
  !> Profiles have shape(KPROMA,KFLEV), pressure is Pa, temperature K and
  !! humidity kg/kg. RG/RD/RKAPPA are explicit original physical constants.
  !! Only selected int32 output words change. No input aliases the output.
  subroutine troplev(kproma, kstart, kprof, kflev, ldtrophum, pt, pq, presf, kltrop, rd, rg, rkappa, status)
    integer(int32), intent(in) :: kproma, kstart, kprof, kflev
    logical, intent(in) :: ldtrophum
    real(real64), intent(in) :: pt(:, :), pq(:, :), presf(:, :), rd, rg, rkappa
    integer(int32), intent(inout) :: kltrop(:)
    integer(int32), intent(out) :: status
    integer :: j, k, last_level
    real(real64) :: numerator, denominator, term, correction, gravity_square
    real(real64), volatile :: stability
    status = 2
    if (kproma < 1 .or. kproma > 4096 .or. kflev < 3 .or. kflev > 512) return
    if (kstart < 1 .or. kstart > kproma + 1 .or. kprof < 0 .or. kprof > kproma) return
    if (any(shape(pt) /= [kproma, kflev]) .or. any(shape(pq) /= [kproma, kflev])) return
    if (any(shape(presf) /= [kproma, kflev]) .or. size(kltrop) /= kproma) return
    last_level = kflev - 2
    do j = kstart, kprof
      kltrop(j) = last_level
    end do
    do k = 1, last_level
      do j = kstart, kprof
        if (presf(j, k) >= 7000.0_real64 .and. presf(j, k) <= 50000.0_real64) then
          if (ldtrophum) then
            if (kltrop(j) == last_level) then
              if (pq(j, k) > 0.000003_real64) then
                if (pq(j, k + 2) > 0.000005_real64) kltrop(j) = k
              end if
            end if
          else
            numerator = pt(j, k + 2) - pt(j, k)
            numerator = presf(j, k + 1)*numerator
            denominator = presf(j, k + 2) - presf(j, k)
            denominator = pt(j, k + 1)*denominator
            term = numerator/denominator
            correction = rd*pt(j, k + 1)
            correction = correction*0.00025_real64
            gravity_square = rg*rg
            correction = correction/gravity_square
            stability = term + correction
            if (kltrop(j) == last_level) then
              if (stability > rkappa) kltrop(j) = k
            end if
          end if
        else if (presf(j, k) > 50000.0_real64) then
          if (kltrop(j) == last_level) kltrop(j) = k - 1
        end if
      end do
    end do
    status = 0
  end subroutine
end module
