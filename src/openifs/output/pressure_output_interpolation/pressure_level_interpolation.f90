module forecast_pressure_level_interpolation
  !! Form pressure coordinates and interpolate model fields for output.
  !!
  !! Pressure is in Pa, temperature in K, geopotential in m**2/s**2 and
  !! specific gas constants in J/(kg K). Every output is INOUT so inactive
  !! cells, levels and method tails retain their incoming bytes.
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double
  use yomhook, only: lhook, dr_hook
  use physical_constant_setup_port, only: forecast_physical_constants
  use forecast_standard_atmosphere, only: atmosphere_layers
  implicit none
  private
  public :: ppinit, ppflev, ppsta, ppintp, ppt
  integer, parameter :: maximum_pitch = 4096, maximum_levels = 512, maximum_targets = 4096
  interface
    function public_log(x) bind(C, name="log") result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function public_power(x, a) bind(C, name="pow") result(y)
      import c_double
      real(c_double), value :: x, a
      real(c_double) :: y
    end function
  end interface
contains
  !> PPINIT forms half/full pressure, both logarithms and their differences.
  !! The method dimension is4; coordinates(:,0:L,:) include the top row.
  !! Differences(:,L,:) remain untouched. Return0/2 for success/refusal.
  subroutine ppinit(kproma, kstart, kprof, kflev, kppm, prpresh, prpresf, prxp, prxpd, status)
    integer(int32), intent(in) :: kproma, kstart, kprof, kflev, kppm
    real(real64), intent(in) :: prpresh(:, 0:), prpresf(:, :)
    real(real64), intent(inout) :: prxp(:, 0:, :), prxpd(:, 0:, :)
    integer(int32), intent(out) :: status
    integer :: k, j, m
    real(real64) :: difference, handle
    real(real64), parameter :: top_full = transfer(int(z'3fb999999999999a', int64), 0.0_real64)
    real(real64), parameter :: top_log = transfer(int(z'c0026bb1bbb55515', int64), 0.0_real64)
    status = 2
    if (.not. valid_grid(kproma, kstart, kprof, kflev)) return
    if (kppm /= 4) return
    if (size(prpresh, 1) < kproma .or. size(prpresh, 2) < kflev + 1) return
    if (size(prpresf, 1) < kproma .or. size(prpresf, 2) < kflev) return
    if (.not. valid_coordinates(prxp, kproma, kflev)) return
    if (.not. valid_coordinates(prxpd, kproma, kflev)) return
    if (lhook) call dr_hook('PPINIT', 0, handle)
    do k = 1, kflev
      do j = kstart, kprof
        prxp(j, k, 1) = prpresh(j, k)
        prxp(j, k, 2) = prpresf(j, k)
        prxp(j, k, 3) = public_log(prpresh(j, k))
        prxp(j, k, 4) = public_log(prpresf(j, k))
      end do
    end do
    do j = kstart, kprof
      prxp(j, 0, 1) = prpresh(j, 0)
      prxp(j, 0, 2) = top_full
      prxp(j, 0, 3) = top_log
      prxp(j, 0, 4) = top_log
    end do
    do m = 1, 4
      do k = 0, kflev - 1
        do j = kstart, kprof
          difference = prxp(j, k + 1, m) - prxp(j, k, m)
          prxpd(j, k, m) = 1.0_real64/difference
        end do
      end do
    end do
    if (lhook) call dr_hook('PPINIT', 1, handle)
    status = 0
  end subroutine

  !> PPFLEV locates bracketing model levels and flags targets below the model.
  !! KLEVB(:,:,1:4) are1:L indices. Logical outputs use native logical words.
  subroutine ppflev(kproma, kstart, kprof, kflev, klevp, kppm, prpres, prpresh, prpresf, &
                    klevb, ldbelo, ldbels, ldblow, ldbles, status)
    integer(int32), intent(in) :: kproma, kstart, kprof, kflev, klevp, kppm
    real(real64), intent(in) :: prpres(:, :), prpresh(:, 0:), prpresf(:, :)
    integer(int32), intent(inout) :: klevb(:, :, :)
    logical, intent(inout) :: ldbelo(:, :), ldbels(:, :), ldblow(:), ldbles(:)
    integer(int32), intent(out) :: status
    real(real64) :: maximum_pressure(maximum_levels), minimum_target, difference, handle, value
    integer :: k, t, j, done, below
    logical :: any_full, any_surface
    status = 2
    if (.not. valid_grid(kproma, kstart, kprof, kflev)) return
    if (.not. valid_target_count(klevp) .or. kppm /= 4) return
    if (size(prpres, 1) < kproma .or. size(prpres, 2) < klevp) return
    if (size(prpresh, 1) < kproma .or. size(prpresh, 2) < kflev + 1) return
    if (size(prpresf, 1) < kproma .or. size(prpresf, 2) < kflev) return
    if (size(klevb, 1) < kproma .or. size(klevb, 2) < klevp .or. size(klevb, 3) < 4) return
    if (size(ldbelo, 1) < kproma .or. size(ldbelo, 2) < klevp) return
    if (size(ldbels, 1) < kproma .or. size(ldbels, 2) < klevp) return
    if (size(ldblow) < klevp .or. size(ldbles) < klevp) return
    if (lhook) call dr_hook('PPFLEV', 0, handle)
    do k = 1, kflev
      value = prpresh(kstart, k)
      do j = kstart + 1, kprof
        value = max(value, prpresh(j, k))
      end do
      maximum_pressure(k) = value
    end do
    do t = 1, klevp
      minimum_target = prpres(kstart, t)
      do j = kstart + 1, kprof
        minimum_target = min(minimum_target, prpres(j, t))
      end do
      do j = kstart, kprof
        klevb(j, t, 1) = kflev + 1
      end do
      done = 0
      do k = 1, kflev
        if (maximum_pressure(k) > minimum_target) then
          do j = kstart, kprof
            if (klevb(j, t, 1) /= kflev + 1) cycle
            if (prpresh(j, k) > prpres(j, t)) then
              klevb(j, t, 1) = k
              done = done + 1
            end if
          end do
        end if
        if (done == kprof - kstart + 1) exit
      end do
    end do
    do t = 1, klevp
      do j = kstart, kprof
        below = min(klevb(j, t, 1), kflev)
        klevb(j, t, 1) = below
        difference = prpresf(j, below) - prpres(j, t)
        if (difference >= 0.0_real64) then
          ! The source keeps this index, including the equality branch.
        else
          below = below + 1
        end if
        below = min(below, kflev)
        klevb(j, t, 2) = below
        klevb(j, t, 3) = klevb(j, t, 1)
        klevb(j, t, 4) = below
      end do
    end do
    do t = 1, klevp
      any_full = .false.; any_surface = .false.
      do j = kstart, kprof
        ldbelo(j, t) = prpres(j, t) > prpresf(j, kflev)
        ldbels(j, t) = prpres(j, t) > prpresh(j, kflev)
        any_full = any_full .or. ldbelo(j, t)
        any_surface = any_surface .or. ldbels(j, t)
      end do
      ldblow(t) = any_full; ldbles(t) = any_surface
    end do
    if (lhook) call dr_hook('PPFLEV', 1, handle)
    status = 0
  end subroutine

  !> PPSTA integrates the actual post-processing reference table.
  !! REFERENCE is the canonical second atmosphere table. No global record is
  !! read. Its height1 is source-defined positive zero; pressure1 is VP00.
  !! Return1 for private classification allocation failure,0/2 otherwise.
  subroutine ppsta(constants, reference, cdatm, kproma, kstart, kprof, klevp, klolev, &
                   prpres, plnpres, pstt, pstfi, status)
    type(forecast_physical_constants), intent(in) :: constants
    type(atmosphere_layers), intent(in) :: reference
    character(*), intent(in) :: cdatm
    integer(int32), intent(in) :: kproma, kstart, kprof, klevp, klolev
    real(real64), intent(in) :: prpres(:, :), plnpres(:, :)
    real(real64), intent(inout) :: pstt(:, :), pstfi(:, :)
    integer(int32), intent(out) :: status
    integer, allocatable :: layer_index(:, :)
    real(real64) :: height(9), gradient(9), temperature(9), pressure(9)
    real(real64) :: layer_log(9), inverse_pressure(9), inverse_gradient(9)
    real(real64) :: ratio, exponent, base, power, term, change, z, height_delta, value, handle
    integer :: alloc_status, k, t, j
    status = 2
    if (cdatm /= 'PPREF') return
    if (.not. valid_horizontal(kproma, kstart, kprof)) return
    if (.not. valid_targets(klevp, klolev)) return
    if (size(prpres, 1) < kproma .or. size(prpres, 2) < klevp) return
    if (size(plnpres, 1) < kproma .or. size(plnpres, 2) < klevp) return
    if (size(pstt, 1) < kproma .or. size(pstt, 2) < klevp) return
    if (size(pstfi, 1) < kproma .or. size(pstfi, 2) < klevp) return
    allocate (layer_index(kproma, klevp), stat=alloc_status)
    if (alloc_status /= 0) then
      status = 1
      return
    end if
    if (lhook) call dr_hook('PPSTA', 0, handle)
    height = reference%height; gradient = reference%gradient
    temperature = reference%temperature; pressure = reference%pressure
    height(1) = 0.0_real64
    do k = 1, 9
      layer_log(k) = public_log(pressure(k))
      inverse_pressure(k) = 1.0_real64/pressure(k)
      inverse_gradient(k) = 0.0_real64
      if (gradient(k) /= 0.0_real64) inverse_gradient(k) = 1.0_real64/gradient(k)
    end do
    do t = klolev, klevp
      do j = kstart, kprof
        k = 1
        do while (k < 9)
          if (prpres(j, t) >= pressure(k + 1)) exit
          k = k + 1
        end do
        layer_index(j, t) = k
      end do
    end do
    ratio = constants%rd/constants%rg
    do t = klolev, klevp
      do j = kstart, kprof
        k = layer_index(j, t)
        if (gradient(k) /= 0.0_real64) then
          exponent = -gradient(k)
          exponent = exponent*ratio
          base = prpres(j, t)*inverse_pressure(k)
          power = public_power(base, exponent)
          change = power - 1.0_real64
          term = temperature(k)*inverse_gradient(k)
          term = term*change
          z = height(k) + term
          height_delta = z - height(k)
          value = gradient(k)*height_delta
          value = temperature(k) + value
        else
          term = temperature(k)*ratio
          change = plnpres(j, t) - layer_log(k)
          term = term*change
          z = height(k) - term
          value = temperature(k)
        end if
        pstt(j, t) = value
        pstfi(j, t) = z*constants%rg
      end do
    end do
    if (lhook) call dr_hook('PPSTA', 1, handle)
    deallocate (layer_index)
    status = 0
  end subroutine

  !> PPINTP interpolates an explicit field linearly in full-level pressure.
  !! ISLCT2 is the exact generated route. FIELD includes the caller's top row.
  !! Cells flagged below the model retain their incoming output value.
  subroutine ppintp(kproma, kstart, kprof, kflev, klevp, klolev, kppm, klevb, islct, &
                    ldbelo, ldblow, prpres, prxp, prxpd, pf, pp, status)
    integer(int32), intent(in) :: kproma, kstart, kprof, kflev, klevp, klolev, kppm, islct
    integer(int32), intent(in) :: klevb(:, :, :)
    logical, intent(in) :: ldbelo(:, :), ldblow(:)
    real(real64), intent(in) :: prpres(:, :), prxp(:, 0:, :), prxpd(:, 0:, :), pf(:, 0:)
    real(real64), intent(inout) :: pp(:, :)
    integer(int32), intent(out) :: status
    real(real64) :: upper, difference, coordinate_delta, term, handle
    integer :: t, j, k
    status = 2
    if (.not. valid_grid(kproma, kstart, kprof, kflev)) return
    if (.not. valid_targets(klevp, klolev)) return
    if (kppm /= 4 .or. islct /= 2) return
    if (.not. valid_interpolation_inputs(kproma, kstart, kprof, kflev, klevp, klolev, klevb, &
                                         ldbelo, ldblow, prpres, prxp, prxpd, pf, pp, 2)) return
    if (lhook) call dr_hook('PPINTP', 0, handle)
    do t = klolev, klevp
      do j = kstart, kprof
        if (ldblow(t)) then
          if (ldbelo(j, t)) cycle
        end if
        k = klevb(j, t, 2)
        upper = pf(j, k)
        difference = upper - pf(j, k - 1)
        coordinate_delta = prpres(j, t) - prxp(j, k, 2)
        term = difference*coordinate_delta
        term = term*prxpd(j, k - 1, 2)
        pp(j, t) = upper + term
      end do
    end do
    if (lhook) call dr_hook('PPINTP', 1, handle)
    status = 0
  end subroutine

  !> PPT retains the generated temperature departure and extrapolation route.
  !! PSTTF is required and has bounds(:,0:L). Optional PR2/PRTPP routes are
  !! refused. All scalar controls are actual caller-produced source values.
  subroutine ppt(constants, reference, surface_lapse, old_postprocessing, no_surface_temperature, &
                 kproma, kstart, kprof, kflev, klevp, klolev, kppm, klevb, pres, plnpres, &
                 ldbelo, ldbels, ldblow, ldbles, ldextr, porog, prxp, prxpd, ptstar, pt0, pr0, ptf, ptpp, &
                 psttf, pr2, prtpp, status)
    type(forecast_physical_constants), intent(in) :: constants
    type(atmosphere_layers), intent(in) :: reference
    real(real64), intent(in) :: surface_lapse
    logical, intent(in) :: old_postprocessing, no_surface_temperature
    integer(int32), intent(in) :: kproma, kstart, kprof, kflev, klevp, klolev, kppm
    integer(int32), intent(in) :: klevb(:, :, :)
    logical, intent(in) :: ldbelo(:, :), ldbels(:, :), ldblow(:), ldbles(:), ldextr
    real(real64), intent(in) :: pres(:, :), plnpres(:, :), porog(:), prxp(:, 0:, :), prxpd(:, 0:, :)
    real(real64), intent(in) :: ptstar(:), pt0(:), pr0(:, :), ptf(:, :)
    real(real64), intent(inout) :: ptpp(:, :)
    real(real64), optional, intent(in) :: psttf(:, 0:), pr2(:, :)
    real(real64), optional, intent(inout) :: prtpp(:, :)
    integer(int32), intent(out) :: status
    real(real64), allocatable, target :: storage(:)
    real(real64), pointer, contiguous :: departure(:, :), gas(:, :), interpolated_gas(:, :), &
                                         reference_geopotential(:, :), original_temperature(:, :), alpha(:)
    integer(int64) :: model_words, target_words, words, offset
    integer :: alloc_status, k, t, j, below
    real(real64) :: a, b, c, d, e, x, gamma, factor, value, fi2000, fi2500, inverse_range, base_alpha, alp
    real(real64) :: handle
    real(real64), volatile :: six
    status = 2
    if (.not. valid_grid(kproma, kstart, kprof, kflev)) return
    if (kflev < 2) return
    if (.not. valid_targets(klevp, klolev) .or. kppm /= 4) return
    if (.not. canonical_logical(old_postprocessing)) return
    if (old_postprocessing) return
    if (.not. canonical_logical(no_surface_temperature)) return
    if (.not. canonical_logical(ldextr)) return
    if (.not. present(psttf)) return
    if (present(pr2) .or. present(prtpp)) return
    if (size(psttf, 1) < kproma .or. size(psttf, 2) < kflev + 1) return
    if (size(pres, 1) < kproma .or. size(pres, 2) < klevp) return
    if (size(plnpres, 1) < kproma .or. size(plnpres, 2) < klevp) return
    if (size(ptpp, 1) < kproma .or. size(ptpp, 2) < klevp) return
    if (.not. valid_coordinates(prxp, kproma, kflev)) return
    if (.not. valid_coordinates(prxpd, kproma, kflev)) return
    if (size(klevb, 1) < kproma .or. size(klevb, 2) < klevp .or. size(klevb, 3) < 4) return
    if (size(ldbelo, 1) < kproma .or. size(ldbelo, 2) < klevp) return
    if (size(ldbels, 1) < kproma .or. size(ldbels, 2) < klevp) return
    if (size(ldblow) < klevp .or. size(ldbles) < klevp) return
    if (size(porog) < kproma .or. size(ptstar) < kproma .or. size(pt0) < kproma) return
    if (size(pr0, 1) < kproma .or. size(pr0, 2) < kflev) return
    if (size(ptf, 1) < kproma .or. size(ptf, 2) < kflev) return
    do t = klolev, klevp
      if (.not. canonical_logical(ldblow(t))) return
      if (.not. canonical_logical(ldbles(t))) return
      do j = kstart, kprof
        if (.not. canonical_logical(ldbelo(j, t))) return
        if (.not. canonical_logical(ldbels(j, t))) return
        if (ldblow(t)) then
          if (ldbelo(j, t)) cycle
        end if
        if (klevb(j, t, 2) < 1 .or. klevb(j, t, 2) > kflev) return
        if (klevb(j, t, 4) < 1 .or. klevb(j, t, 4) > kflev) return
      end do
    end do
    model_words = int(kproma, int64)*(kflev + 1)
    target_words = int(kproma, int64)*klevp
    words = 3*model_words + 2*target_words + kproma
    if (words > 268435456_int64) return
    allocate (storage(words), stat=alloc_status)
    if (alloc_status /= 0) then
      status = 1
      return
    end if
    offset = 0
    departure(1:kproma, 0:kflev) => storage(offset + 1:offset + model_words); offset = offset + model_words
    gas(1:kproma, 0:kflev) => storage(offset + 1:offset + model_words); offset = offset + model_words
    original_temperature(1:kproma, 0:kflev) => storage(offset + 1:offset + model_words); offset = offset + model_words
    interpolated_gas(1:kproma, 1:klevp) => storage(offset + 1:offset + target_words); offset = offset + target_words
    reference_geopotential(1:kproma, 1:klevp) => storage(offset + 1:offset + target_words); offset = offset + target_words
    alpha(1:kproma) => storage(offset + 1:offset + kproma)
    if (lhook) call dr_hook('PPT', 0, handle)
    do k = 1, kflev
      do j = kstart, kprof
        value = ptf(j, k)
        original_temperature(j, k) = value
        a = psttf(j, k)*constants%rd
        a = a/pr0(j, k)
        departure(j, k) = value - a
        gas(j, k) = pr0(j, k)
      end do
    end do
    call ppsta(constants, reference, 'PPREF', kproma, kstart, kprof, klevp, klolev, &
               pres, plnpres, ptpp, reference_geopotential, status)
    if (status /= 0) return
    do j = kstart, kprof
      departure(j, 0) = departure(j, 1)
      gas(j, 0) = gas(j, 1)
    end do
    call ppintp(kproma, kstart, kprof, kflev, klevp, klolev, kppm, klevb, 2_int32, &
                ldbelo, ldblow, pres, prxp, prxpd, gas, interpolated_gas, status)
    if (status /= 0) return
    do t = klolev, klevp
      do j = kstart, kprof
        if (ldblow(t)) then
          if (ldbelo(j, t)) then
            if (ldbels(j, t)) cycle
            if (no_surface_temperature) then
              a = plnpres(j, t) - prxp(j, kflev, 4)
              b = prxp(j, kflev, 4) - prxp(j, kflev - 1, 4)
              x = a/b
              a = original_temperature(j, kflev) - original_temperature(j, kflev - 1)
              a = x*a
              value = original_temperature(j, kflev) + a
            else
              a = prxp(j, kflev, 3) - plnpres(j, t)
              b = prxp(j, kflev, 3) - prxp(j, kflev, 4)
              x = a/b
              a = original_temperature(j, kflev) - ptstar(j)
              a = x*a
              value = ptstar(j) + a
            end if
            ptpp(j, t) = value
            cycle
          end if
        end if
        below = klevb(j, t, 4)
        a = prxp(j, below, 4) - plnpres(j, t)
        b = prxp(j, below, 4) - prxp(j, below - 1, 4)
        x = a/b
        a = prxp(j, below - 1, 4) + prxp(j, below, 4)
        c = 2.0_real64*prxp(j, below - 1, 3)
        a = a - c
        gamma = a/b
        factor = 3.0_real64*gamma
        factor = factor*x
        a = x - 1.0_real64
        factor = factor*a
        factor = x + factor
        a = departure(j, below - 1) - departure(j, below)
        factor = a*factor
        value = ptpp(j, t)*constants%rd
        value = value/interpolated_gas(j, t)
        value = value + departure(j, below)
        ptpp(j, t) = value + factor
      end do
    end do
    if (ldextr) then
      fi2000 = 2000.0_real64*constants%rg
      fi2500 = 2500.0_real64*constants%rg
      a = fi2500 - fi2000
      inverse_range = 1.0_real64/a
      base_alpha = -surface_lapse
      base_alpha = base_alpha*constants%rd
      base_alpha = base_alpha/constants%rg
      do j = kstart, kprof
        a = porog(j) - fi2000
        a = a*inverse_range
        a = max(0.0_real64, a)
        a = min(1.0_real64, a)
        a = constants%rd*a
        b = 298.0_real64 - pt0(j)
        b = min(0.0_real64, b)
        a = a*b
        b = max(porog(j), fi2000)
        a = a/b
        a = base_alpha + a
        alpha(j) = max(0.0_real64, a)
      end do
      six = 6.0_real64
      do t = klolev, klevp
        if (.not. ldbles(t)) cycle
        do j = kstart, kprof
          if (.not. ldbels(j, t)) cycle
          a = plnpres(j, t) - prxp(j, kflev, 3)
          alp = alpha(j)*a
          a = alp/six
          a = 0.5_real64 + a
          a = a*alp
          a = 1.0_real64 + a
          a = a*alp
          a = 1.0_real64 + a
          ptpp(j, t) = ptstar(j)*a
        end do
      end do
    else
      do t = klolev, klevp
        if (.not. ldbles(t)) cycle
        do j = kstart, kprof
          if (ldbels(j, t)) ptpp(j, t) = original_temperature(j, kflev)
        end do
      end do
    end if
    if (lhook) call dr_hook('PPT', 1, handle)
    deallocate (storage)
    status = 0
  end subroutine

  logical function valid_horizontal(pitch, first, last) result(ok)
    integer, intent(in) :: pitch, first, last
    ok = pitch >= 1 .and. pitch <= maximum_pitch .and. first >= 1 .and. first <= last .and. last <= pitch
  end function
  logical function valid_grid(pitch, first, last, levels) result(ok)
    integer, intent(in) :: pitch, first, last, levels
    ok = valid_horizontal(pitch, first, last) .and. levels >= 1 .and. levels <= maximum_levels
  end function
  logical function valid_target_count(targets) result(ok)
    integer, intent(in) :: targets
    ok = targets >= 1 .and. targets <= maximum_targets
  end function
  logical function valid_targets(targets, first) result(ok)
    integer, intent(in) :: targets, first
    ok = valid_target_count(targets) .and. first >= 1 .and. first <= targets
  end function
  logical function valid_coordinates(values, pitch, levels) result(ok)
    real(real64), intent(in) :: values(:, 0:, :)
    integer, intent(in) :: pitch, levels
    ok = size(values, 1) >= pitch .and. size(values, 2) >= levels + 1 .and. size(values, 3) >= 4
  end function
  logical function canonical_logical(value) result(ok)
    logical, intent(in) :: value
    integer(int32) :: word
    word = transfer(value, 0_int32)
    ok = word == 0 .or. word == 1
  end function
  logical function valid_interpolation_inputs(pitch, first, last, levels, targets, first_target, &
                             indices, below, any_below, target_pressure, coordinates, differences, field, result, method) result(ok)
    integer, intent(in) :: pitch, first, last, levels, targets, first_target, method
    integer(int32), intent(in) :: indices(:, :, :)
    logical, intent(in) :: below(:, :), any_below(:)
    real(real64), intent(in) :: target_pressure(:, :), coordinates(:, 0:, :), differences(:, 0:, :), field(:, 0:)
    real(real64), intent(in) :: result(:, :)
    integer :: j, t
    ok = .false.
    if (size(indices, 1) < pitch .or. size(indices, 2) < targets .or. size(indices, 3) < 4) return
    if (size(below, 1) < pitch .or. size(below, 2) < targets .or. size(any_below) < targets) return
    if (size(target_pressure, 1) < pitch .or. size(target_pressure, 2) < targets) return
    if (.not. valid_coordinates(coordinates, pitch, levels)) return
    if (.not. valid_coordinates(differences, pitch, levels)) return
    if (size(field, 1) < pitch .or. size(field, 2) < levels + 1) return
    if (size(result, 1) < pitch .or. size(result, 2) < targets) return
    do t = first_target, targets
      if (.not. canonical_logical(any_below(t))) return
      do j = first, last
        if (.not. canonical_logical(below(j, t))) return
        if (any_below(t)) then
          if (below(j, t)) cycle
        end if
        if (indices(j, t, method) < 1 .or. indices(j, t, method) > levels) return
      end do
    end do
    ok = .true.
  end function
end module
