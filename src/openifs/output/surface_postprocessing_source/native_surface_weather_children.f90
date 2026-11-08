!> Surface weather profiles, wind gusts and the ocean skin temperature.
module forecast_native_surface_weather_children
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double
  use yos_cst, only: tcst
  use yos_exc, only: texc
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record, stability_parameter_record
  implicit none
  private
  public :: sppcfl, sppgust, voskin
  interface
    function public_exp(x) bind(c, name='exp') result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function public_log(x) bind(c, name='log') result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function public_atan(x) bind(c, name='atan') result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function public_power(x, y) bind(c, name='pow') result(z)
      import c_double
      real(c_double), value :: x, y
      real(c_double) :: z
    end function
  end interface
contains
  !> Interpolate wind, temperature and humidity to screen heights.
  !! All real values are FP64. Vectors own at least KLON elements and have
  !! positive strides. Only KIDIA:KFDIA changes; outputs are disjoint INOUT
  !! owners so inactive columns and tails remain unchanged. Winds are m/s,
  !! pressure is Pa, lengths are m, geopotential is m2/s2, static energy J/kg,
  !! humidity kg/kg and temperature K. PRPLRG is a positive dimensionless
  !! planet scale. Canonical thermal and stability records are readonly.
  !! Widths 1:4096 and empty intervals are supported. Status is 0 or 2.
  subroutine sppcfl(thermal, stability, kidia, kfdia, klon, pumlev, pvmlev, pqmlev, pgeomlev, pcpts, pcptgzlev, &
                    paphms, pz0mm, pz0hm, pz0qm, pzdl, pqsa, pblend, pfblend, pucurr, pvcurr, ydcst, ydexc, &
                    pu10, pv10, p10nu, p10nv, pust, pt2, pd2, pq2, prplrg, status)
    type(thermal_parameter_record), intent(in) :: thermal
    type(stability_parameter_record), intent(in) :: stability
    integer(int32), intent(in) :: kidia, kfdia, klon
    real(real64), intent(in) :: pumlev(:), pvmlev(:), pqmlev(:), pgeomlev(:), pcpts(:), pcptgzlev(:)
    real(real64), intent(in) :: paphms(:), pz0mm(:), pz0hm(:), pz0qm(:), pzdl(:), pqsa(:)
    real(real64), intent(in) :: pblend(:), pfblend(:), pucurr(:), pvcurr(:), prplrg
    type(tcst), intent(in) :: ydcst
    type(texc), intent(in) :: ydexc
    real(real64), intent(inout) :: pu10(:), pv10(:), p10nu(:), p10nv(:), pust(:), pt2(:), pd2(:), pq2(:)
    integer(int32), intent(out) :: status
    real(real64), parameter :: qmin = transfer(int(z'3d19000000000000', int64), 0.0_real64)
    real(real64), volatile :: height10, height2, height_energy, pm1
    real(real64) :: height, original_height, zdl, obukhov, z2, z10, blend_height, argument
    real(real64) :: ph2, ph1, ph0, pq0, pmb, pm10, pm0, factor, neutral_factor, wind
    real(real64) :: q, energy, numerator, denominator, work, work2, vapour, frac
    integer :: j
    logical :: stable
    status = 2
    if (.not. valid_interval(kidia, kfdia, klon, 4096)) return
    if (min(size(pumlev), size(pvmlev), size(pqmlev), size(pgeomlev), size(pcpts), size(pcptgzlev)) < klon) return
    if (min(size(paphms), size(pz0mm), size(pz0hm), size(pz0qm), size(pzdl), size(pqsa)) < klon) return
    if (min(size(pblend), size(pfblend), size(pucurr), size(pvcurr)) < klon) return
    if (min(size(pu10), size(pv10), size(p10nu), size(p10nv), size(pust), size(pt2), size(pd2), size(pq2)) < klon) return
    if (prplrg <= 0.0_real64) return
    height10 = 10.0_real64/prplrg
    height2 = 2.0_real64/prplrg
    height_energy = height2*ydcst%rg
    do j = kidia, kfdia
      height = pgeomlev(j)/ydcst%rg
      height = height + pz0mm(j)
      original_height = height
      zdl = sign(max(abs(pzdl(j)), qmin), pzdl(j))
      obukhov = height/zdl
      if (zdl > stability%rchbhdl) then
        height = obukhov*stability%rchbhdl
        work = max(pz0mm(j), pz0hm(j))
        height = height + work
        zdl = height*zdl
        zdl = zdl/original_height
      end if
      z2 = height2 + pz0mm(j)
      work = z2/obukhov
      if (work > stability%rchbhdl) then
        z2 = stability%rchbhdl*obukhov
        z2 = z2 + max(pz0mm(j), pz0hm(j))
      end if
      z10 = height10 + pz0mm(j)
      work = z10/obukhov
      if (work > stability%rchbhdl) then
        z10 = stability%rchbhdl*obukhov
        z10 = z10 + max(pz0mm(j), pz0hm(j))
      end if
      blend_height = pblend(j) + pz0mm(j)
      work = blend_height/obukhov
      if (work > stability%rchbhdl) then
        blend_height = stability%rchbhdl*obukhov
        blend_height = blend_height + max(pz0mm(j), pz0hm(j))
      end if
      stable = pzdl(j) > 0.0_real64
      argument = zdl*z2
      argument = argument/height
      ph2 = psi_heat(argument, stable, stability)
      ph1 = psi_heat(zdl, stable, stability)
      argument = zdl*pz0hm(j)
      argument = argument/height
      ph0 = psi_heat(argument, stable, stability)
      argument = zdl*pz0qm(j)
      argument = argument/height
      pq0 = psi_heat(argument, stable, stability)
      argument = zdl*blend_height
      argument = argument/height
      pmb = psi_momentum(argument, stable, stability)
      argument = zdl*z10
      argument = argument/height
      pm10 = psi_momentum(argument, stable, stability)
      pm1 = psi_momentum(zdl, stable, stability)
      argument = zdl*pz0mm(j)
      argument = argument/height
      pm0 = psi_momentum(argument, stable, stability)
      work = z10/pz0mm(j)
      numerator = public_log(work)
      numerator = numerator - pm10
      numerator = numerator + pm0
      work = blend_height/pz0mm(j)
      denominator = public_log(work)
      denominator = denominator - pmb
      denominator = denominator + pm0
      factor = numerator/denominator
      work = pumlev(j) - pucurr(j)
      work = work*work
      work2 = pvmlev(j) - pvcurr(j)
      work2 = work2*work2
      wind = work + work2
      wind = sqrt(wind)
      wind = max(wind, 0.1_real64)
      work = pumlev(j) - pucurr(j)
      work = work*factor
      work = work*pfblend(j)
      work = work/wind
      pu10(j) = work + pucurr(j)
      work = pvmlev(j) - pvcurr(j)
      work = work*factor
      work = work*pfblend(j)
      work = work/wind
      pv10(j) = work + pvcurr(j)
      work = z10/pz0mm(j)
      numerator = public_log(work)
      work = blend_height/pz0mm(j)
      denominator = public_log(work)
      denominator = denominator - pmb
      denominator = denominator + pm0
      neutral_factor = numerator/denominator
      work = pumlev(j) - pucurr(j)
      work = work*neutral_factor
      work = work*pfblend(j)
      p10nu(j) = work/wind
      work = pvmlev(j) - pvcurr(j)
      work = work*neutral_factor
      work = work*pfblend(j)
      p10nv(j) = work/wind
      work = blend_height/pz0mm(j)
      denominator = public_log(work)
      denominator = denominator - pmb
      denominator = denominator + pm0
      work = pfblend(j)*ydexc%rkap
      pust(j) = work/denominator
      q = max(pqmlev(j), qmin)
      work = z2/pz0hm(j)
      numerator = public_log(work)
      numerator = numerator - ph2
      numerator = numerator + ph0
      work = height/pz0hm(j)
      denominator = public_log(work)
      denominator = denominator - ph1
      denominator = denominator + ph0
      energy = pcptgzlev(j) - pcpts(j)
      energy = energy*numerator
      energy = energy/denominator
      energy = pcpts(j) + energy
      work = z2/pz0qm(j)
      numerator = public_log(work)
      numerator = numerator - ph2
      numerator = numerator + pq0
      work = height/pz0qm(j)
      denominator = public_log(work)
      denominator = denominator - ph1
      denominator = denominator + pq0
      work = q - pqsa(j)
      work = work*numerator
      work = work/denominator
      pq2(j) = pqsa(j) + work
      work = ydcst%rg*height2
      energy = energy - work
      work = thermal%rvtmp2*q
      work = 1.0_real64 + work
      work = ydcst%rcpd*work
      pt2(j) = energy/work
    end do
    do j = kidia, kfdia
      q = max(pqmlev(j), qmin)
      work = ydcst%retv*q
      work = 1.0_real64 + work
      work2 = ydcst%rd*pt2(j)
      work = work2*work
      work = height_energy/work
      work = 1.0_real64 - work
      vapour = paphms(j)*work
      work = ydcst%retv*pq2(j)
      work = 1.0_real64 + work
      denominator = thermal%r2es*work
      work = vapour*pq2(j)
      work = work/denominator
      frac = public_log(work)
      frac = frac/thermal%r3les
      work = frac*thermal%r4les
      numerator = ydcst%rtt - work
      denominator = 1.0_real64 - frac
      work = numerator/denominator
      pd2(j) = min(pt2(j), work)
    end do
    status = 0
  end subroutine sppcfl

  !> Calculate wind gust speed in m/s for the active columns.
  !! The readonly TCST/TEXC records supply gravity and the von Karman constant.
  !! All vectors have at least KLON FP64 elements, width 1:4096. PZ0MM is
  !! retained but not read by this frozen body. PGUST is a disjoint INOUT owner.
  subroutine sppgust(kidia, kfdia, klon, pz0mm, pbuom, pustar, pu10m, pv10m, ydcst, ydexc, pgust, status)
    integer(int32), intent(in) :: kidia, kfdia, klon
    real(real64), intent(in) :: pz0mm(:), pbuom(:), pustar(:), pu10m(:), pv10m(:)
    type(tcst), intent(in) :: ydcst
    type(texc), intent(in) :: ydexc
    real(real64), intent(inout) :: pgust(:)
    integer(int32), intent(out) :: status
    real(real64), parameter :: czi = transfer(int(z'3fa5555555555555', int64), 0.0_real64)
    real(real64), parameter :: third = transfer(int(z'3fd5555555555555', int64), 0.0_real64)
    real(real64) :: cube, stability, wind, work, work2
    integer :: j
    status = 2
    if (.not. valid_interval(kidia, kfdia, klon, 4096)) return
    if (min(size(pz0mm), size(pbuom), size(pustar), size(pu10m), size(pv10m), size(pgust)) < klon) return
    do j = kidia, kfdia
      cube = pustar(j)*pustar(j)
      cube = cube*pustar(j)
      work = -ydexc%rkap
      work = work*ydcst%rg
      work = work*pbuom(j)
      stability = work/cube
      work = pu10m(j)*pu10m(j)
      work2 = pv10m(j)*pv10m(j)
      wind = work + work2
      wind = sqrt(wind)
      if (stability < 0.0_real64) then
        work = czi*stability
        work = 1.0_real64 - work
        work2 = public_power(work, third)
        work = pustar(j)*7.2_real64
        work = work*work2
      else
        work = pustar(j)*7.2_real64
      end if
      pgust(j) = wind + work
    end do
    status = 0
  end subroutine sppgust

  !> Advance the ocean warm layer and cool skin, returning temperature in K.
  !! All thirteen field owners are contiguous FP64 vectors of exactly KLON
  !! elements. Inputs may share storage; the output must be separate. Width is
  !! 1:512. PTMST is seconds and PRPLRG is a positive dimensionless scale.
  !! Heat fluxes are W/m2, stress is N/m2, winds are m/s and temperature is K.
  !! TCST/TEXC are initialized canonical readonly parameter records. Status 0
  !! means success and 2 means refusal before writes. Formulation C is fixed.
  subroutine voskin(kidia, kfdia, klon, ptmst, pssrfl, pslrfl, pahfs, pahfl, pustr, pvstr, &
                    pumlev, pvmlev, ptskm1m, psst, pustokes, pvstokes, ydcst, ydexc, ptsk, prplrg, status)
    integer(int32), intent(in) :: kidia, kfdia, klon
    real(real64), intent(in) :: ptmst, prplrg, pssrfl(:), pslrfl(:), pahfs(:), pahfl(:), pustr(:), pvstr(:)
    real(real64), intent(in) :: pumlev(:), pvmlev(:), ptskm1m(:), psst(:), pustokes(:), pvstokes(:)
    type(tcst), intent(in) :: ydcst
    type(texc), intent(in) :: ydexc
    real(real64), intent(inout) :: ptsk(:)
    integer(int32), intent(out) :: status
    real(real64), parameter :: roa = 1.2_real64, roc = 4294750.0_real64, kw = 0.6_real64
    real(real64), parameter :: two_thirds = transfer(int(z'3fe5555555555555', int64), 0.0_real64)
    real(real64), parameter :: minus_third = transfer(int(z'bfd5555555555555', int64), 0.0_real64)
    real(real64), parameter :: minus_two_thirds = transfer(int(z'bfe5555555555555', int64), 0.0_real64)
    real(real64), parameter :: melting = transfer(int(z'4071128f60000000', int64), 0.0_real64)
    real(real64), parameter :: nua = transfer(int(z'3ebd81fd00000000', int64), 0.0_real64)
    real(real64), parameter :: nub = transfer(int(z'3e6b655f60000000', int64), 0.0_real64)
    real(real64), parameter :: nuc = transfer(int(z'3e06497f60000000', int64), 0.0_real64)
    real(real64), volatile :: ratio, depth, boundary_depth, con3, con4, con5, absorption, csah, cra, csa
    real(real64) :: work, work2, work3, buoyancy, gust2, wind2, ustar, expansion, cool, warm
    real(real64) :: nu, con2, ustw2, heat, delta, solar, old_excess, forcing, dl, dl2, phi, mixing
    integer :: j
    status = 2
    if (.not. valid_interval(kidia, kfdia, klon, 512)) return
    if (kfdia < kidia - 1) return
    if (min(size(pssrfl), size(pslrfl), size(pahfs), size(pahfl), size(pustr), size(pvstr)) /= klon) return
    if (max(size(pssrfl), size(pslrfl), size(pahfs), size(pahfl), size(pustr), size(pvstr)) /= klon) return
    if (min(size(pumlev), size(pvmlev), size(ptskm1m), size(psst), size(pustokes), size(pvstokes), size(ptsk)) /= klon) return
    if (max(size(pumlev), size(pvmlev), size(ptskm1m), size(psst), size(pustokes), size(pvstokes), size(ptsk)) /= klon) return
    if (.not. is_contiguous(pssrfl) .or. .not. is_contiguous(pslrfl) .or. .not. is_contiguous(pahfs)) return
    if (.not. is_contiguous(pahfl) .or. .not. is_contiguous(pustr) .or. .not. is_contiguous(pvstr)) return
    if (.not. is_contiguous(pumlev) .or. .not. is_contiguous(pvmlev) .or. .not. is_contiguous(ptskm1m)) return
    if(.not.is_contiguous(psst).or..not.is_contiguous(pustokes).or..not.is_contiguous(pvstokes).or..not.is_contiguous(ptsk))return
    if (prplrg <= 0.0_real64) return
    ratio = transfer(int(z'3f532e67994cdffb', int64), 0.0_real64)
    depth = 3.0_real64/prplrg
    boundary_depth = 1000.0_real64/prplrg
    work = -71.5_real64*depth
    work = public_exp(work)
    work = 0.28_real64*work
    absorption = 1.0_real64 - work
    work = -2.8_real64*depth
    work = public_exp(work)
    work = 0.27_real64*work
    absorption = absorption - work
    work = -0.07_real64*depth
    work = public_exp(work)
    work = 0.45_real64*work
    absorption = absorption - work
    work = public_power(ratio, 1.5_real64)
    work2 = depth*ydexc%rkap
    work2 = work2*ydcst%rg
    con3 = work2/work
    work = 1.3_real64*ydexc%rkap
    work2 = sqrt(ratio)
    work = work*work2
    con4 = work/depth
    work = 0.3_real64*depth
    con5 = 1.3_real64/work
    csa = 6.0_real64
    cra = transfer(int(z'3fcd70a3e0000000', int64), 0.0_real64)
    work = csa*csa
    work = work*work
    work2 = cra*cra
    work2 = work2*cra
    csah = work*work2
    do j = kidia, kfdia
      cool = 0.0_real64
      warm = 0.0_real64
      if (ydexc%leocwa .or. ydexc%leocco) then
        work = pahfl(j)/ydcst%rlvtt
        work2 = -ydcst%retv
        work = work2*work
        work2 = pahfs(j)/ydcst%rcpd
        work2 = work2/ptskm1m(j)
        work = work - work2
        work = ydcst%rg*work
        buoyancy = work/roa
        if (buoyancy >= 0.0_real64) then
          work = buoyancy*boundary_depth
          gust2 = public_power(work, two_thirds)
        else
          gust2 = 0.0_real64
        end if
        work = pumlev(j)*pumlev(j)
        work2 = pvmlev(j)*pvmlev(j)
        wind2 = work + work2
        wind2 = max(0.01_real64, wind2)
        work = pustr(j)*pustr(j)
        work2 = pvstr(j)*pvstr(j)
        work = work + work2
        work = sqrt(work)
        work = work/roa
        work2 = wind2 + gust2
        work2 = work2/wind2
        work = work*work2
        work = sqrt(work)
        ustar = max(work, 0.0001_real64)
        work = psst(j) - 273.0_real64
        work = 1.e-5_real64*work
        expansion = max(1.e-5_real64, work)
        if (ydexc%leocco) then
          work = psst(j) - melting
          work2 = nub*work
          nu = nua - work2
          work2 = work*work
          work2 = nuc*work2
          nu = nu + work2
          work = csah*ydcst%rg
          work = work*roc
          work2 = nu*nu
          work2 = work2*nu
          work = work*work2
          work2 = kw*kw
          con2 = work/work2
          work = ustar*ustar
          ustw2 = ratio*work
          work = -pslrfl(j)
          work = work - pahfs(j)
          work = work - pahfl(j)
          heat = max(1.0_real64, work)
          work = heat*expansion
          work = work*con2
          work2 = ustw2*ustw2
          work = work/work2
          work = public_power(work, 0.75_real64)
          work = 1.0_real64 + work
          work = public_power(work, minus_third)
          work = csa*work
          work = work*nu
          work2 = sqrt(ustw2)
          delta = work/work2
          work = -delta
          work = work/8.e-4_real64
          work = public_exp(work)
          work = 1.0_real64 - work
          work2 = 6.6e-5_real64/delta
          work = work2*work
          work2 = 11.0_real64*delta
          work2 = 0.065_real64 + work2
          solar = work2 - work
          solar = max(solar, 0.01_real64)
          work = -solar
          work = work*pssrfl(j)
          work = work + heat
          work = max(1.0_real64, work)
          work2 = -delta
          work = work2*work
          cool = work/kw
        end if
        if (ydexc%leocwa) then
          old_excess = ptskm1m(j) - psst(j)
          old_excess = old_excess - cool
          work = pssrfl(j)*absorption
          work = work + pslrfl(j)
          work = work + pahfs(j)
          work = work + pahfl(j)
          forcing = work/roc
          dl = forcing
          if (old_excess > 0.0_real64 .and. forcing < 0.0_real64) then
            work = 5.0_real64*depth
            work = work*ydcst%rg
            work = work*expansion
            work = work/0.3_real64
            work = old_excess/work
            work = sqrt(work)
            work2 = ustar*ustar
            work2 = work2*ratio
            dl = work2*work
          end if
          work = con3*expansion
          work = work*dl
          work2 = ustar*ustar
          work2 = work2*ustar
          dl = work/work2
          if (dl > 0.0_real64) then
            dl2 = dl*dl
            work = 5.0_real64*dl
            work2 = 4.0_real64*dl2
            work = work + work2
            work2 = 3.0_real64*dl
            work2 = 1.0_real64 + work2
            work3 = 0.25_real64*dl2
            work2 = work2 + work3
            work = work/work2
            phi = 1.0_real64 + work
            mixing = 1.0_real64
            if (ydexc%leocla) then
              work = ustar*ustar
              work = ratio*work
              work2 = pustokes(j)*pustokes(j)
              work3 = pvstokes(j)*pvstokes(j)
              work2 = work2 + work3
              work2 = max(work2, 1.e-8_real64)
              work = work/work2
              work = public_power(work, 0.25_real64)
              work = public_power(work, minus_two_thirds)
              work = max(work, 1.0_real64)
              mixing = min(work, 10.0_real64)
            end if
          else
            work = 16.0_real64*dl
            work = 1.0_real64 - work
            work = sqrt(work)
            phi = 1.0_real64/work
            mixing = 1.0_real64
          end if
          work = con4*ptmst
          work = work*ustar
          work = work*mixing
          work = work/phi
          work2 = 1.0_real64 + work
          work = con5*forcing
          work = work*ptmst
          work = old_excess + work
          work = work/work2
          warm = max(0.0_real64, work)
        end if
      end if
      work = psst(j) + warm
      ptsk(j) = work + cool
    end do
    status = 0
  end subroutine voskin

  !> Integrated heat stability correction in the retained scalar order.
  function psi_heat(z, stable, s) result(value)
    real(real64), intent(in) :: z
    logical, intent(in) :: stable
    type(stability_parameter_record), intent(in) :: s
    real(real64) :: value, work, term
    if (stable) then
      term = z - s%rchbcd
      work = -s%rchbb
      term = work*term
      work = -s%rchbd
      work = work*z
      work = public_exp(work)
      term = term*work
      work = s%rchb23a*z
      work = 1.0_real64 + work
      value = sqrt(work)
      work = work*value
      value = term - work
      value = value - s%rchbbcd
      value = value + 1.0_real64
    else
      work = s%rcdhalf*z
      work = 1.0_real64 - work
      work = sqrt(work)
      work = 1.0_real64 + work
      work = work*0.5_real64
      value = public_log(work)
      value = 2.0_real64*value
    end if
  end function psi_heat

  !> Integrated momentum stability correction in the retained scalar order.
  function psi_momentum(z, stable, s) result(value)
    real(real64), intent(in) :: z
    logical, intent(in) :: stable
    type(stability_parameter_record), intent(in) :: s
    real(real64) :: value, work, term, root
    if (stable) then
      term = z - s%rchbcd
      work = -s%rchbb
      term = work*term
      work = -s%rchbd
      work = work*z
      work = public_exp(work)
      term = term*work
      work = s%rchba*z
      value = term - work
      value = value - s%rchbbcd
    else
      work = s%rcdhalf*z
      work = 1.0_real64 - work
      term = sqrt(work)
      root = sqrt(term)
      work = 1.0_real64 + root
      work = work*work
      value = 1.0_real64 + term
      work = work*value
      work = work*0.125_real64
      term = public_log(work)
      work = public_atan(root)
      work = 2.0_real64*work
      value = term - work
      value = value + s%rcdhpi2
    end if
  end function psi_momentum

  !> Check source-supported column bounds without reading field values.
  pure logical function valid_interval(first, last, width, maximum)
    integer(int32), intent(in) :: first, last, width, maximum
    valid_interval = width >= 1 .and. width <= maximum .and. first >= 1 .and. first <= width + 1 .and. last >= 0 .and. last <= width
  end function valid_interval
end module forecast_native_surface_weather_children
