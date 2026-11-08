!> Extrapolate the lowest atmospheric temperature to the surface and sea level.
module forecast_surface_temperature_extrapolation
  use iso_fortran_env, only: int32, real64
  implicit none
  private
  public :: ctstar
contains
  !> Arrays have length KPROMA. Temperature is K, pressure is Pa, and orography
  !! is geopotential in m2/s2. RDTDZ1 is K/m, RG is m/s2 and RD is J/(kg K).
  !! Only KSTART:KPROF changes. Both complete outputs are disjoint INOUT owners.
  subroutine ctstar(kproma, kstart, kprof, ptb, presbh, presbf, porog, ptstar, pt0, rdtdz1, rg, rd, status)
    integer(int32), intent(in) :: kproma, kstart, kprof
    real(real64), intent(in) :: ptb(:), presbh(:), presbf(:), porog(:), rdtdz1, rg, rd
    real(real64), intent(inout) :: ptstar(:), pt0(:)
    integer(int32), intent(out) :: status
    real(real64), volatile :: lapse_over_g, alpha
    real(real64) :: value, pressure_ratio, orography_term
    integer :: j
    status = 2
    if (kproma < 1 .or. kproma > 24 .or. kstart < 1 .or. kstart > kproma + 1) return
    if (kprof < kstart - 1 .or. kprof > kproma) return
    if (size(ptb) /= kproma .or. size(presbh) /= kproma .or. size(presbf) /= kproma) return
    if (size(porog) /= kproma .or. size(ptstar) /= kproma .or. size(pt0) /= kproma) return
    lapse_over_g = -rdtdz1
    lapse_over_g = lapse_over_g/rg
    alpha = lapse_over_g*rd
    do j = kstart, kprof
      pressure_ratio = presbh(j)/presbf(j)
      pressure_ratio = pressure_ratio - 1.0_real64
      value = alpha*pressure_ratio
      value = 1.0_real64 + value
      value = ptb(j)*value
      ptstar(j) = value
      orography_term = porog(j)*lapse_over_g
      pt0(j) = value + orography_term
    end do
    status = 0
  end subroutine
end module
