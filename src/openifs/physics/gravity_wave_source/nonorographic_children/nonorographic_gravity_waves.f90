!> Complete four-direction, twenty-phase non-orographic gravity-wave drag.
!! Explicit native parameters replace original module-global constants.
module md2asm_nonorographic_gravity_waves
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double
  use yoegwd, only: tegwd
  use yoegwwms, only: tegwwms
  use physical_constant_setup_port, only: forecast_physical_constants
  use forecast_standard_atmosphere_setup, only: standard_atmosphere_state
  use md2asm_wave_launch_grid, only: wave_launch_grid_factor
  implicit none
  private
  public :: gwdrag_wms, admit_nonorographic_wave_parameters
  interface
    function public_exp(x) bind(C, name="exp") result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function public_log(x) bind(C, name="log") result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
  end interface
  integer(int64),parameter :: cosine_words(4)=[int(z'3ff0000000000000',int64),int(z'3c91a62633145c07',int64),int(z'bff0000000000000',int64),int(z'bcaa79394c9e8a0a',int64)]
  integer(int64),parameter :: sine_words(4)=[int(z'0000000000000000',int64),int(z'3ff0000000000000',int64),int(z'3ca1a62633145c07',int64),int(z'bff0000000000000',int64)]
  real(real64), parameter :: cosine(4) = transfer(cosine_words, [0.0_real64], 4), sine(4) = transfer(sine_words, [0.0_real64], 4)
contains
  !> Admit the shared source controls and selected spacing before output writes.
  !! PGAW is the dimensionless normalized grid-cell area. The selected route
  !! requires source-rounded spacing at least29000m. The runtime route uses
  !! the complete separate grid factor and its declared default controls.
 logical function admit_nonorographic_wave_parameters(constants,ydegwwms,kidia,kfdia,klon,klev,pgaw,runtime_grid_spacing) result(ok)
    type(forecast_physical_constants), intent(in) :: constants
    type(tegwwms), intent(in) :: ydegwwms
    integer(int32), intent(in) :: kidia, kfdia, klon, klev
    real(real64), intent(in) :: pgaw(:)
    logical, intent(in) :: runtime_grid_spacing
    real(real64), volatile :: a, b
    integer :: j, n
    ok = .false.
    if (klon < 1 .or. klon > 2048 .or. klev < 2 .or. klev > 512) return
    if (kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon) return
    if (size(pgaw) < klon .or. constants%initialized /= 1) return
    if (runtime_grid_spacing) then
      if (.not. ydegwwms%lozpr .or. ydegwwms%lgacalc .or. ydegwwms%lgsatl .or. ydegwwms%lgindl) return
      if (ydegwwms%nslope /= 1 .or. ydegwwms%ngauss /= 2 .or. ydegwwms%gptwo /= 2.0_real64) return
    end if
    if (ydegwwms%nslope < -1 .or. ydegwwms%nslope > 2) return
    if (ydegwwms%gptwo /= 2.0_real64 .and. ydegwwms%gptwo /= 3.0_real64) return
    if (transfer(constants%rpi, 0_int64) /= int(z'400921fb54442d18', int64)) return
    do j = kidia, kfdia
      if (.not. (pgaw(j) > 0.0_real64)) return
      a = constants%rpi*pgaw(j); a = sqrt(a); b = 2.0_real64*constants%ra; a = b*a; a = max(a, 100.0_real64)
      if (.not. runtime_grid_spacing) then
        if (.not. (a >= 29000.0_real64)) return
      end if
    end do
    ok = .true.
  end function

  !> Return complete source tendencies and selected momentum fluxes.
  !! Original22-argument order follows CONSTANTS, followed by STATUS and an
  !! optional runtime-grid selector. Records stay read-only. PTM1 is K,
  !! winds are m/s, pressure Pa, geopotential m2/s2, latitude rad, precipitation
  !! kg/m2/s, tendencies m/s2 and fluxes Pa. Native matrices are real64 with
  !! first extent KLON; full fields have KLEV levels, half pressure and
  !! flux owners have levels0:KLEV. All tendency cells are cleared, including
  !! inactive columns; only active flux columns change. Extra owner tails stay.
  !! Caller establishes nearest-even/gradual underflow, source-admitted finite
  !! physical fields and disjoint mutable owners. Status0 completes,1 reports
  !! storage failure and2 refuses metadata before mutation.
  subroutine gwdrag_wms(constants,ydsta,ydegwd,ydegwwms,kidia,kfdia,klon,klev,klaunch,ptstep,ptm1,pum1,pvm1,papm1,paphm1,pgeo1,pgelat,pgaw,pprecip,ptenu,ptenv,pfluxu,pfluxv,status,runtime_grid_spacing)
    type(forecast_physical_constants), intent(in) :: constants
    type(standard_atmosphere_state), intent(in) :: ydsta
    type(tegwd), intent(in) :: ydegwd
    type(tegwwms), intent(in) :: ydegwwms
    integer(int32), intent(in) :: kidia, kfdia, klon, klev, klaunch
    real(real64),intent(in) :: ptstep,ptm1(:,:),pum1(:,:),pvm1(:,:),papm1(:,:),paphm1(:,0:),pgeo1(:,:),pgelat(:),pgaw(:),pprecip(:)
    real(real64), intent(inout) :: ptenu(:, :), ptenv(:, :), pfluxu(:, 0:), pfluxv(:, 0:)
    integer(int32), intent(out) :: status
    logical, intent(in), optional :: runtime_grid_spacing
    logical :: use_runtime
    real(real64), allocatable, target :: arena(:)
    real(real64), pointer, contiguous :: thm(:, :), uhm(:, :), vhm(:, :), bvf(:, :), rho(:, :), factor(:, :)
    real(real64), pointer, contiguous :: intrinsic(:, :, :), momentum(:, :, :), deposited(:, :, :), phase(:, :, :)
    real(real64), pointer, contiguous :: launch_wind(:, :), minimum_phase(:, :), spectrum(:, :, :), activity(:, :, :), lost(:, :, :)
    real(real64), pointer, contiguous :: launch_bvf(:), normalisation(:), launch_flux(:), carried(:), ci(:), dci(:)
    real(real64), volatile :: one, half, two, three, hundred, nineteen, quarter
    real(real64), volatile :: reciprocal_rd, gravity_heat, vertical_wavenumber, inverse_gravity_step
    real(real64) :: span, dx, xmin, gamma, x1, x2, global_flux, gaussian_amplitude, ms, a, b, c, e, h
    real(real64) :: temperature_mean, geopotential_difference, temperature_difference, density_std, frequency_std, standard_factor
    real(real64) :: wavenumber_phase, launch_frequency, launch_factor, phase_value, delta, cap, removed, mixture, limit
    integer(int64) :: cells, offset, length
    integer :: j, k, az, inc, ilaunch, allocation_status
    status = 2; use_runtime = .false.
    if (present(runtime_grid_spacing)) use_runtime = runtime_grid_spacing
    if (klon < 1 .or. klon > 2048 .or. klev < 2 .or. klev > 512 .or. klaunch < 1 .or. klaunch > 3) return
    if (kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon) return
    if (constants%initialized /= 1) return
    ilaunch = ydegwwms%nlaunchl(klaunch)
    if (ilaunch < 2 .or. ilaunch > klev) return
    if (min(size(pgelat), size(pgaw), size(pprecip)) < klon) return
    if (size(ptm1, 1) /= klon .or. size(ptm1, 2) < klev .or. size(pum1, 1) /= klon .or. size(pum1, 2) < klev) return
    if (size(pvm1, 1) /= klon .or. size(pvm1, 2) < klev .or. size(papm1, 1) /= klon .or. size(papm1, 2) < klev) return
    if (size(paphm1, 1) /= klon .or. size(paphm1, 2) < klev + 1 .or. size(pgeo1, 1) /= klon .or. size(pgeo1, 2) < klev) return
    if (size(ptenu, 1) /= klon .or. size(ptenu, 2) < klev .or. size(ptenv, 1) /= klon .or. size(ptenv, 2) < klev) return
    if (size(pfluxu, 1) /= klon .or. size(pfluxu, 2) < klev + 1 .or. size(pfluxv, 1) /= klon .or. size(pfluxv, 2) < klev + 1) return
    if (ydegwwms%lgindl) then
   if (.not. allocated(ydsta%half_pressure) .or. .not. allocated(ydsta%temperature) .or. .not. allocated(ydsta%geopotential)) return
      if (lbound(ydsta%half_pressure, 1) /= 0 .or. ubound(ydsta%half_pressure, 1) < ilaunch - 1) return
      if (lbound(ydsta%temperature, 1) /= 1 .or. lbound(ydsta%geopotential, 1) /= 1) return
      if (min(size(ydsta%temperature), size(ydsta%geopotential)) < ilaunch) return
    end if
    ! Source control refusals precede every floating setup operation.
    if (use_runtime) then
      if (.not. ydegwwms%lozpr .or. ydegwwms%lgacalc .or. ydegwwms%lgsatl .or. ydegwwms%lgindl) return
      if (ydegwwms%nslope /= 1 .or. ydegwwms%ngauss /= 2 .or. ydegwwms%gptwo /= 2.0_real64) return
    end if
    if (ydegwwms%nslope < -1 .or. ydegwwms%nslope > 2) return
    if (ydegwwms%gptwo /= 2.0_real64 .and. ydegwwms%gptwo /= 3.0_real64) return
    if (transfer(constants%rpi, 0_int64) /= int(z'400921fb54442d18', int64)) return
    ! These four setup operations precede the source spacing loop and storage.
    one = 1.0_real64; half = 0.5_real64; two = 2.0_real64; three = 3.0_real64
    hundred = 100.0_real64; nineteen = 19.0_real64; quarter = 0.25_real64
    reciprocal_rd = one/constants%rd
    gravity_heat = constants%rg*constants%rg; gravity_heat = gravity_heat/constants%rcpd
    a = two*constants%rpi; vertical_wavenumber = a/ydegwwms%gmstar_l(klaunch)
    if (.not. admit_nonorographic_wave_parameters(constants, ydegwwms, kidia, kfdia, klon, klev, pgaw, use_runtime)) return
    global_flux = ydegwwms%gfluxlaunl(klaunch); gaussian_amplitude = ydegwwms%ggaussb(klaunch)
    cells = int(klon, int64)*int(klev, int64); length = 22_int64*cells + 252_int64*klon + 48_int64
    allocate (arena(length), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    arena = 0.0_real64; offset = 1
    thm(1:klon, 1:klev) => arena(offset:offset + cells - 1); offset = offset + cells
    uhm(1:klon, 1:klev) => arena(offset:offset + cells - 1); offset = offset + cells
    vhm(1:klon, 1:klev) => arena(offset:offset + cells - 1); offset = offset + cells
    bvf(1:klon, 1:klev) => arena(offset:offset + cells - 1); offset = offset + cells
    rho(1:klon, 1:klev) => arena(offset:offset + cells - 1); offset = offset + cells
    factor(1:klon, 1:klev) => arena(offset:offset + cells - 1); offset = offset + cells
    intrinsic(1:klon, 1:klev, 1:4) => arena(offset:offset + 4*cells - 1); offset = offset + 4*cells
    momentum(1:klon, 1:klev, 1:4) => arena(offset:offset + 4*cells - 1); offset = offset + 4*cells
    deposited(1:klon, 1:klev, 1:4) => arena(offset:offset + 4*cells - 1); offset = offset + 4*cells
    phase(1:klon, 1:klev, 1:4) => arena(offset:offset + 4*cells - 1); offset = offset + 4*cells
    launch_wind(1:klon, 1:4) => arena(offset:offset + 4*klon - 1); offset = offset + 4*klon
    minimum_phase(1:klon, 1:4) => arena(offset:offset + 4*klon - 1); offset = offset + 4*klon
    spectrum(1:klon, 1:20, 1:4) => arena(offset:offset + 80*klon - 1); offset = offset + 80*klon
    activity(1:klon, 1:20, 1:4) => arena(offset:offset + 80*klon - 1); offset = offset + 80*klon
    lost(1:klon, 1:20, 1:4) => arena(offset:offset + 80*klon - 1); offset = offset + 80*klon
    launch_bvf(1:klon) => arena(offset:offset + klon - 1); offset = offset + klon
    normalisation(1:klon) => arena(offset:offset + klon - 1); offset = offset + klon
    launch_flux(1:klon) => arena(offset:offset + klon - 1); offset = offset + klon
    carried(1:klon) => arena(offset:offset + klon - 1); offset = offset + klon
    ci(1:20) => arena(offset:offset + 19); offset = offset + 20
    dci(1:20) => arena(offset:offset + 19)
    ptenu(:, 1:klev) = 0.0_real64; ptenv(:, 1:klev) = 0.0_real64
    pfluxu(kidia:kfdia, 0:klev) = 0.0_real64; pfluxv(kidia:kfdia, 0:klev) = 0.0_real64
    if (kidia > kfdia) then
      status = 0; return
    end if
    minimum_phase(kidia:kfdia, :) = half
    do k = 1, klev
      do j = kidia, kfdia
        a = ptm1(j, k); b = pum1(j, k); c = pvm1(j, k)
        if (k > 1) then
          a = ptm1(j, k - 1) + a; b = pum1(j, k - 1) + b; c = pvm1(j, k - 1) + c
          a = half*a; b = half*b; c = half*c
        end if
        thm(j, k) = a; uhm(j, k) = b; vhm(j, k) = c
      end do
    end do
    do k = klev, 2, -1
      do j = kidia, kfdia
        geopotential_difference = pgeo1(j, k) - pgeo1(j, k - 1)
        a = paphm1(j, k - 1)*reciprocal_rd; rho(j, k) = a/thm(j, k)
        b = gravity_heat/thm(j, k); a = ptm1(j, k) - ptm1(j, k - 1)
        a = constants%rcpd*a; a = a/geopotential_difference; a = one + a; a = b*a
        a = max(a, ydegwd%gssec); bvf(j, k) = sqrt(a)
      end do
    end do
    a = one/half; xmin = one/hundred; span = a - xmin; dx = span/nineteen; gamma = quarter
    if (ydegwwms%lgacalc) then
      a = a/xmin; a = public_log(a); gamma = span/a
    end if
    a = span/gamma; a = public_exp(a); a = a - one; x1 = span/a; x2 = xmin - x1
    do inc = 1, 20
      a = real(inc - 1, real64)*dx; a = a + xmin; a = a - xmin; a = a/gamma; e = public_exp(a)
      b = x1*e; b = b + x2; ci(inc) = one/b
      b = ci(inc)*ci(inc); a = x1/gamma; b = b*a; b = b*e; dci(inc) = b*dx
    end do
    do az = 1, 4
      do j = kidia, kfdia
        a = cosine(az)*uhm(j, ilaunch); b = sine(az)*vhm(j, ilaunch); launch_wind(j, az) = a + b
        launch_bvf(j) = bvf(j, ilaunch)
      end do
      do k = 2, ilaunch
        do j = kidia, kfdia
          a = cosine(az)*uhm(j, k); b = sine(az)*vhm(j, k); a = a + b; intrinsic(j, k, az) = a - launch_wind(j, az)
        end do
      end do
    end do
    do k = 2, ilaunch
      do j = kidia, kfdia
        factor(j, k) = rho(j, k)/bvf(j, k)
      end do
    end do
    if (ydegwwms%lgindl) then
      geopotential_difference = ydsta%geopotential(ilaunch) - ydsta%geopotential(ilaunch - 1)
      temperature_difference = ydsta%temperature(ilaunch) - ydsta%temperature(ilaunch - 1)
      a = ydsta%temperature(ilaunch - 1) + ydsta%temperature(ilaunch); temperature_mean = half*a
      a = ydsta%half_pressure(ilaunch - 1)*reciprocal_rd; density_std = a/temperature_mean
      a = gravity_heat/temperature_mean; b = constants%rcpd*temperature_difference
      b = b/geopotential_difference; b = one + b; a = a*b; a = max(a, ydegwd%gssec)
      frequency_std = sqrt(a); standard_factor = density_std/frequency_std
      factor(kidia:kfdia, ilaunch) = standard_factor
    end if
    do inc = 1, 20
      do j = kidia, kfdia
        a = ci(inc); b = vertical_wavenumber*a; c = launch_bvf(j); h = factor(j, ilaunch)
        select case (ydegwwms%nslope)
        case (-1)
          b = b*b; c = c*c; h = h*c; a = h*a; c = c + b; a = a/c
        case (0)
          e = b*b; b = e*b; e = c*c; c = e*c; h = h*c; a = h*a; c = c + b; a = a/c
        case default
          b = b*b; b = b*b; e = c*c; e = e*e; h = h*e
          if (ydegwwms%nslope == 1) then
            if (ydegwwms%lgsatl) then
              b = a/b; c = a/e; b = min(b, c); a = h*b
            else
              a = h*a; b = e + b; a = a/b
            end if
          else
            c = c/vertical_wavenumber
            if (ydegwwms%lgsatl) then
              b = c/b; a = a/e; b = min(b, a); a = h*b
            else
              h = h*a; h = h*c; e = e*c; b = b*a; e = e + b; a = h/e
            end if
          end if
        end select
        spectrum(j, inc, 1) = a; activity(j, inc, 1) = one; lost(j, inc, 1) = one
      end do
    end do
    do inc = 1, 20
      do j = kidia, kfdia
        a = spectrum(j, inc, 1)*dci(inc); momentum(j, ilaunch, 1) = momentum(j, ilaunch, 1) + a
      end do
    end do
    do j = kidia, kfdia
      if (use_runtime) then
        a = wave_launch_grid_factor(pgaw(j), constants%rpi, constants%ra); a = global_flux*a
      else
        a = global_flux*one
      end if
      launch_flux(j) = a; normalisation(j) = a/momentum(j, ilaunch, 1)
      if (ydegwwms%lozpr) then
        select case (ydegwwms%ngauss)
        case (2, 4)
          a = pgelat(j)*57.29577951_real64
          if (ydegwwms%ngauss == 4) a = a - (-50.0_real64)
          b = -a; a = b*a; b = two*ydegwwms%ggaussa; b = b*ydegwwms%ggaussa
          a = a/b; a = public_exp(a); a = gaussian_amplitude*a; a = one + a; a = a*launch_flux(j)
          launch_flux(j) = a; normalisation(j) = a/momentum(j, ilaunch, 1)
        case (1)
          a = ydegwwms%gcoeff*pprecip(j); a = min(half, a); a = one + a; a = launch_flux(j)*a
          launch_flux(j) = a; normalisation(j) = a/momentum(j, ilaunch, 1)
        end select
      end if
    end do
    do az = 1, 4
      momentum(kidia:kfdia, ilaunch, az) = launch_flux(kidia:kfdia)
    end do
    do k = 2, ilaunch
      do j = kidia, kfdia
        factor(j, k) = normalisation(j)*factor(j, k)
      end do
    end do
    do inc = 1, 20
      do j = kidia, kfdia
        spectrum(j, inc, 1) = normalisation(j)*spectrum(j, inc, 1)
      end do
    end do
    do az = 2, 4
      do inc = 1, 20
        do j = kidia, kfdia
          spectrum(j, inc, az) = spectrum(j, inc, 1); activity(j, inc, az) = one; lost(j, inc, az) = one
        end do
      end do
    end do
    do az = 1, 4
      do k = ilaunch - 1, 2, -1
        do j = kidia, kfdia
          minimum_phase(j, az) = max(minimum_phase(j, az), intrinsic(j, k, az))
        end do
        do inc = 1, 20
          do j = kidia, kfdia
            a = ci(inc) - minimum_phase(j, az)
            b = real(1 - ibits(transfer(a, 0_int64), 63, 1), real64)
            lost(j, inc, az) = activity(j, inc, az) - b; activity(j, inc, az) = b
          end do
        end do
        do inc = 1, 20
          do j = kidia, kfdia
            a = lost(j, inc, az)*spectrum(j, inc, az); a = a*dci(inc)
            deposited(j, k, az) = deposited(j, k, az) + a
          end do
        end do
        do j = kidia, kfdia
          removed = deposited(j, k, az)
          if (removed > 0.0_real64) then
            mixture = phase(j, k, az)
            do inc = 1, 20
              a = ci(inc)*lost(j, inc, az); a = a*spectrum(j, inc, az); a = a*dci(inc); mixture = mixture + a
            end do
            phase(j, k, az) = mixture/removed
          else
            phase(j, k, az) = phase(j, k + 1, az)
          end if
        end do
        do inc = 1, 20
          do j = kidia, kfdia
            a = one/ci(inc); b = ci(inc) - intrinsic(j, k, az); cap = ydegwwms%gcstar*factor(j, k)
            if (ydegwwms%gptwo == three) then
              cap = cap*b; cap = cap*cap; cap = cap*b; cap = cap*a
              c = spectrum(j, inc, az)*spectrum(j, inc, az); c = c - cap; c = activity(j, inc, az)*c
              if (c > 0.0_real64) spectrum(j, inc, az) = sqrt(cap)
            else
              b = b*b; cap = cap*b; cap = cap*a
              c = spectrum(j, inc, az) - cap; c = activity(j, inc, az)*c
              if (c > 0.0_real64) spectrum(j, inc, az) = cap
            end if
          end do
        end do
        do inc = 1, 20
          do j = kidia, kfdia
            a = activity(j, inc, az)*spectrum(j, inc, az); a = a*dci(inc)
            momentum(j, k, az) = momentum(j, k, az) + a
          end do
        end do
      end do
    end do
    a = constants%rg*ptstep; inverse_gravity_step = one/a
    do az = 1, 4
      carried(kidia:kfdia) = 0.0_real64
      do k = 2, ilaunch
        do j = kidia, kfdia
          a = cosine(az)*pum1(j, k); b = sine(az)*pvm1(j, k); a = a + b; delta = a - launch_wind(j, az)
          removed = deposited(j, k - 1, az) + carried(j); deposited(j, k - 1, az) = removed
          a = papm1(j, k - 1) - papm1(j, k); a = two*a; b = phase(j, k - 1, az) - delta
          a = a*b; a = a*inverse_gravity_step; a = min(removed, a); a = max(a, 0.0_real64)
          carried(j) = removed - a; momentum(j, k, az) = momentum(j, k, az) - carried(j)
        end do
      end do
    end do
    do az = 1, 4
      do k = ilaunch, 2, -1
        do j = kidia, kfdia
          a = momentum(j, k, az)*one; b = a*cosine(az); c = a*sine(az)
          pfluxu(j, k - 1) = pfluxu(j, k - 1) + b; pfluxv(j, k - 1) = pfluxv(j, k - 1) + c
        end do
      end do
    end do
    do k = 1, ilaunch
      do j = kidia, kfdia
        a = paphm1(j, k) - paphm1(j, k - 1); b = constants%rg/a
        a = pfluxu(j, k) - pfluxu(j, k - 1); ptenu(j, k) = a*b
        a = pfluxv(j, k) - pfluxv(j, k - 1); ptenv(j, k) = a*b
      end do
    end do
    status = 0
  end subroutine
end module
