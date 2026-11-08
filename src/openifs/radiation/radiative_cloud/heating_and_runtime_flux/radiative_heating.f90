!> Complete broadband radiative heating in source operation order.
!! Pressure is in Pa, temperature in K, humidity in kg/kg and flux in W/m^2.
module forecast_radiative_heating
  use iso_fortran_env, only: int32, int64, real64
  use yoerad, only: terad
  use yoerdi, only: terdi
  use yomphy2, only: tphy2
  use yomphy3, only: tphy3
  use spp_mod, only: tspp_config
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use dynamical_configuration_port, only: native_dynamical_configuration
  use forecast_public_scalar_math, only: power_original_rounding
  implicit none
  private
  public :: radheatn
contains
  !> Update selected radiative fluxes, heating rates and temperature tendency.
  !! The original 57 arguments keep their order; explicit owned constants follow.
  !! All arrays are ordinary assumed-shape views, with the column index first.
  !! Full levels have KLEV elements and half levels have KLEV+1 elements.
  !! Boundary arrays have two levels. One broadband longwave interval is used.
  !! Outputs are INOUT so inactive elements and complete owner padding survive.
  !! Status 2 refuses metadata before stores; status 3 reports workspace failure.
  !! The caller provides distinct owners and nearest-even, gradual arithmetic.
  subroutine radheatn( &
    yderad, yderdi, ydphy2, ydphy3, ydspp_config, kidia, kfdia, klon, klev, &
    paphm1, pemis, pspectralemiss, pemtd, pmu0, pmu0m, pqm1, pte, ptrsol, ptrsod, &
    ptrthd, ptrsodc, ptrthdc, ptsm1m, phrsw, phrlw, phrsc, phrlc, pfrso, pfrth, &
    pfrsod, pfrsodc, pfrthd, pfrthdc, pemtec, ptrsoc, pfrsoc, pfrthc, pincsr, psudu, &
    psdur, pdsrp, puvdfi, pparfi, pparcfi, ptincfi, pfdiri, pcdiri, puvdf, pparf, &
    pparcf, ptincf, pfdir, pcdir, plwderivative, pneb, pap, pgp2dspp, physical, dynamics, thermal, status)
    type(terad), intent(in) :: yderad
    type(terdi), intent(in) :: yderdi
    type(tphy2), intent(in) :: ydphy2
    type(tphy3), intent(in) :: ydphy3
    type(tspp_config), intent(in) :: ydspp_config
    integer(int32), intent(in) :: kidia, kfdia, klon, klev
    real(real64), intent(in) :: paphm1(:, :)
    real(real64), intent(in) :: pemis(:)
    real(real64), intent(in) :: pspectralemiss(:, :)
    real(real64), intent(in) :: pemtd(:, :)
    real(real64), intent(in) :: pmu0(:)
    real(real64), intent(in) :: pmu0m(:)
    real(real64), intent(in) :: pqm1(:, :)
    real(real64), intent(inout) :: pte(:, :)
    real(real64), intent(in) :: ptrsol(:, :)
    real(real64), intent(in) :: ptrsod(:)
    real(real64), intent(in) :: ptrthd(:, :)
    real(real64), intent(in) :: ptrsodc(:)
    real(real64), intent(in) :: ptrthdc(:)
    real(real64), intent(in) :: ptsm1m(:)
    real(real64), intent(inout) :: phrsw(:, :)
    real(real64), intent(inout) :: phrlw(:, :)
    real(real64), intent(inout) :: phrsc(:, :)
    real(real64), intent(inout) :: phrlc(:, :)
    real(real64), intent(inout) :: pfrso(:, :)
    real(real64), intent(inout) :: pfrth(:, :)
    real(real64), intent(inout) :: pfrsod(:)
    real(real64), intent(inout) :: pfrsodc(:)
    real(real64), intent(inout) :: pfrthd(:)
    real(real64), intent(inout) :: pfrthdc(:)
    real(real64), intent(in) :: pemtec(:, :)
    real(real64), intent(in) :: ptrsoc(:, :)
    real(real64), intent(inout) :: pfrsoc(:, :)
    real(real64), intent(inout) :: pfrthc(:, :)
    real(real64), intent(inout) :: pincsr(:)
    real(real64), intent(in) :: psudu(:)
    real(real64), intent(inout) :: psdur(:)
    real(real64), intent(inout) :: pdsrp(:)
    real(real64), intent(in) :: puvdfi(:)
    real(real64), intent(in) :: pparfi(:)
    real(real64), intent(in) :: pparcfi(:)
    real(real64), intent(in) :: ptincfi(:)
    real(real64), intent(in) :: pfdiri(:)
    real(real64), intent(in) :: pcdiri(:)
    real(real64), intent(inout) :: puvdf(:)
    real(real64), intent(inout) :: pparf(:)
    real(real64), intent(inout) :: pparcf(:)
    real(real64), intent(inout) :: ptincf(:)
    real(real64), intent(inout) :: pfdir(:)
    real(real64), intent(inout) :: pcdir(:)
    real(real64), intent(in) :: plwderivative(:, :)
    real(real64), intent(in), optional :: pneb(:, :)
    real(real64), intent(in), optional :: pap(:, :)
    real(real64), intent(in), optional :: pgp2dspp(:, :)
    type(forecast_physical_constants), intent(in) :: physical
    type(native_dynamical_configuration), intent(in) :: dynamics
    type(thermal_parameter_record), intent(in) :: thermal
    integer(int32), intent(out) :: status
    real(real64), allocatable, volatile :: work(:, :)
    real(real64), volatile :: one, two, half, down_response, epsilon, epsilon1
    real(real64), volatile :: rrae, rsundur, rii0, heating_coefficient, rvtmp2, sigma, curvature
    real(real64), volatile :: a, b, c, d, e, f, g, mu_new, mu_old, ratio, new_direct, old_direct, difference, factor
    integer :: j, k, allocation_status
    status = 2
    if (yderad%nlwout /= 1 .or. ydspp_config%lspp) return
    if (physical%initialized /= 1) return
    if (klon < 1 .or. klon > 2048 .or. klev < 1 .or. klev > 512) return
    if (kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon) return
    if (.not. fits2(paphm1, klon, klev + 1)) return
    if (.not. fits1(pemis, klon)) return
    if (.not. fits2(pemtd, klon, klev + 1)) return
    if (.not. fits1(pmu0, klon)) return
    if (.not. fits1(pmu0m, klon)) return
    if (.not. fits2(pqm1, klon, klev)) return
    if (.not. fits2(pte, klon, klev)) return
    if (.not. fits2(ptrsol, klon, klev + 1)) return
    if (.not. fits1(ptrsod, klon)) return
    if (.not. fits2(ptrthd, klon, 1)) return
    if (.not. fits1(ptrsodc, klon)) return
    if (.not. fits1(ptrthdc, klon)) return
    if (.not. fits1(ptsm1m, klon)) return
    if (.not. fits2(phrsw, klon, klev)) return
    if (.not. fits2(phrlw, klon, klev)) return
    if (.not. fits2(phrsc, klon, klev)) return
    if (.not. fits2(phrlc, klon, klev)) return
    if (.not. fits2(pfrso, klon, klev + 1)) return
    if (.not. fits2(pfrth, klon, klev + 1)) return
    if (.not. fits1(pfrsod, klon)) return
    if (.not. fits1(pfrsodc, klon)) return
    if (.not. fits1(pfrthd, klon)) return
    if (.not. fits1(pfrthdc, klon)) return
    if (.not. fits2(pemtec, klon, klev + 1)) return
    if (.not. fits2(ptrsoc, klon, klev + 1)) return
    if (.not. fits2(pfrsoc, klon, 2)) return
    if (.not. fits2(pfrthc, klon, 2)) return
    if (.not. fits1(pincsr, klon)) return
    if (.not. fits1(psudu, klon)) return
    if (.not. fits1(psdur, klon)) return
    if (.not. fits1(pdsrp, klon)) return
    if (.not. fits1(puvdfi, klon)) return
    if (.not. fits1(pparfi, klon)) return
    if (.not. fits1(pparcfi, klon)) return
    if (.not. fits1(ptincfi, klon)) return
    if (.not. fits1(pfdiri, klon)) return
    if (.not. fits1(pcdiri, klon)) return
    if (.not. fits1(puvdf, klon)) return
    if (.not. fits1(pparf, klon)) return
    if (.not. fits1(pparcf, klon)) return
    if (.not. fits1(ptincf, klon)) return
    if (.not. fits1(pfdir, klon)) return
    if (.not. fits1(pcdir, klon)) return
    if (.not. fits2(plwderivative, klon, klev + 1)) return
    ! Scalar preparation precedes a valid empty return in the generated body.
    one = 1.0_real64
    two = 2.0_real64
    half = 0.5_real64
    down_response = 0.20000000298023224_real64
    epsilon = 2.220446049250313e-14_real64
    epsilon1 = 2.220446049250313e-12_real64
    rrae = yderdi%rrae
    rsundur = yderdi%rsundur
    a = rrae + two
    curvature = rrae*a
    rii0 = ydphy3%rii0
    a = physical%rg*dynamics%rpldare
    heating_coefficient = a/physical%rcpd
    rvtmp2 = thermal%rvtmp2
    sigma = physical%rsigma
    status = 0
    if (kidia > kfdia) return
    allocate (work(klon, 9), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 3
      return
    end if
    work = 0.0_real64
    ! Work columns: incident, LW up/down, SW net/down/direct, clear equivalents.
    do j = kidia, kfdia
      if (pmu0(j) >= epsilon) then
        a = rii0*pmu0(j)
        b = one
      else
        a = 0.0_real64
        b = 0.0_real64
      end if
      work(j, 1) = a
      pincsr(j) = a
      pdsrp(j) = b
      work(j, 4) = 0.0_real64
      work(j, 7) = 0.0_real64
      work(j, 5) = one
      work(j, 6) = one
      work(j, 8) = one
      work(j, 9) = one
      if (yderad%lapproxlwupdate) then
        a = ptsm1m(j)*ptsm1m(j)
        a = a*a
        a = sigma*a
        a = a - ptrthd(j, 1)
        a = pemis(j)*a
        a = pemtd(j, klev + 1) + a
        work(j, 2) = a
        a = down_response*a
        work(j, 3) = a
      end if
    end do
    do k = 1, klev + 1
      do j = kidia, kfdia
        a = pemtd(j, k)
        if (yderad%lapproxlwupdate) then
          b = plwderivative(j, k)
          c = plwderivative(j, 1)
          d = b - c
          e = one - c
          d = d/e
          f = work(j, 3)
          d = f*d
          a = a + d
          f = work(j, 2)
          b = f*b
          a = a - b
        end if
        pfrth(j, k) = a
      end do
    end do
    do j = kidia, kfdia
      a = ptrthd(j, 1)
      b = 0.0_real64
      a = b + a
      if (yderad%lapproxlwupdate) then
        b = work(j, 3)
        a = a + b
      end if
      pfrthd(j) = a
    end do
    if (yderad%lmannersswupdate) then
      do j = kidia, kfdia
        a = pmu0(j)
        if (a >= epsilon1) then
          b = a*a
          b = b + curvature
          b = sqrt(b)
          b = b - a
          mu_new = rrae/b
        else
          b = sqrt(curvature)
          mu_new = rrae/b
        end if
        a = pmu0m(j)
        if (a >= epsilon1) then
          b = a*a
          b = b + curvature
          b = sqrt(b)
          b = b - a
          mu_old = rrae/b
        else
          b = sqrt(curvature)
          mu_old = rrae/b
        end if
        ratio = mu_old/mu_new
        if (pmu0(j) < epsilon1) cycle
        if (pfdiri(j) >= epsilon1) then
          if (ptrsod(j) >= epsilon1) then
            new_direct = power_original_rounding(pfdiri(j), ratio)
            old_direct = pfdiri(j)
            difference = new_direct - old_direct
            a = work(j, 1)
            a = half*a
            a = a*difference
            a = a*ptrsol(j, klev + 1)
            a = a/ptrsod(j)
            work(j, 4) = a
            a = new_direct/old_direct
            work(j, 6) = a
            a = half*difference
            a = a/ptrsod(j)
            a = one + a
            work(j, 5) = a
          end if
        end if
        if (pcdiri(j) >= epsilon1) then
          if (ptrsodc(j) >= epsilon1) then
            new_direct = power_original_rounding(pcdiri(j), ratio)
            old_direct = pcdiri(j)
            difference = new_direct - old_direct
            a = work(j, 1)
            a = half*a
            a = a*difference
            a = a*ptrsoc(j, klev + 1)
            a = a/ptrsodc(j)
            work(j, 7) = a
            a = new_direct/old_direct
            work(j, 9) = a
            a = half*difference
            a = a/ptrsodc(j)
            a = one + a
            work(j, 8) = a
          end if
        end if
      end do
    end if
    do k = 1, klev + 1
      do j = kidia, kfdia
        a = work(j, 1)
        b = ptrsol(j, k)
        a = a*b
        b = work(j, 4)
        a = a + b
        pfrso(j, k) = a
      end do
    end do
    do j = kidia, kfdia
      g = work(j, 1)
      a = ptrsoc(j, 1)
      a = g*a
      b = work(j, 7)
      a = a + b
      pfrsoc(j, 1) = a
      a = ptrsoc(j, klev + 1)
      a = g*a
      b = work(j, 7)
      a = a + b
      pfrsoc(j, 2) = a
      a = ptrsod(j)
      a = g*a
      b = work(j, 5)
      a = a*b
      pfrsod(j) = a
      a = ptrsodc(j)
      a = g*a
      b = work(j, 8)
      a = a*b
      pfrsodc(j) = a
      if (pfrso(j, klev + 1) < epsilon) pfrso(j, klev + 1) = epsilon
      a = pemtec(j, 1)
      pfrthc(j, 1) = a
    end do
    do k = 1, klev
      do j = kidia, kfdia
        a = paphm1(j, k + 1)
        b = paphm1(j, k)
        a = a - b
        c = pqm1(j, k)
        c = rvtmp2*c
        c = one + c
        a = a*c
        factor = -heating_coefficient
        factor = factor/a
        a = pfrso(j, k)
        b = pfrso(j, k + 1)
        c = pfrth(j, k)
        d = pfrth(j, k + 1)
        e = b + d
        f = a + c
        e = e - f
        e = factor*e
        f = pte(j, k)
        e = f + e
        pte(j, k) = e
        a = b - a
        a = factor*a
        phrsw(j, k) = a
        c = d - c
        c = factor*c
        phrlw(j, k) = c
        c = work(j, 1)
        a = ptrsoc(j, k)
        b = ptrsoc(j, k + 1)
        a = c*a
        b = c*b
        a = b - a
        a = factor*a
        phrsc(j, k) = a
        a = pemtec(j, k)
        b = pemtec(j, k + 1)
        a = b - a
        a = factor*a
        phrlc(j, k) = a
      end do
    end do
    do j = kidia, kfdia
      a = pemtec(j, klev + 1)
      pfrthc(j, 2) = a
      a = ptrthdc(j)
      pfrthdc(j) = a
      g = work(j, 1)
      a = puvdfi(j)
      a = g*a
      b = work(j, 5)
      a = a*b
      puvdf(j) = a
      a = pparfi(j)
      a = g*a
      b = work(j, 5)
      a = a*b
      pparf(j) = a
      a = pparcfi(j)
      a = g*a
      b = work(j, 8)
      a = a*b
      pparcf(j) = a
      a = ptincfi(j)
      a = g*a
      ptincf(j) = a
      a = pfdiri(j)
      a = g*a
      b = work(j, 6)
      a = a*b
      pfdir(j) = a
      a = pcdiri(j)
      a = g*a
      b = work(j, 9)
      a = a*b
      pcdir(j) = a
      a = pdsrp(j)
      a = a*rii0
      b = pfdiri(j)
      a = a*b
      b = work(j, 6)
      a = a*b
      pdsrp(j) = a
      if (a >= rsundur) then
        a = one
      else
        a = 0.0_real64
      end if
      psdur(j) = a
    end do
    deallocate (work)
    status = 0
  end subroutine

  logical function fits1(field, p)
    real(real64), intent(in) :: field(:)
    integer(int32), intent(in) :: p
    fits1 = is_contiguous(field) .and. size(field, kind=int64) >= int(p, int64)
  end function

  logical function fits2(field, p, levels)
    real(real64), intent(in) :: field(:, :)
    integer(int32), intent(in) :: p, levels
    fits2 = is_contiguous(field) .and. size(field, 1, kind=int64) == int(p, int64) .and. &
            size(field, 2, kind=int64) >= int(levels, int64)
  end function
end module
