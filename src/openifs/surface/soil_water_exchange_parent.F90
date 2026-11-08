module srfwexc_vg_mod
  use iso_fortran_env, only: int32, int64, real32, real64
  use iso_c_binding, only: c_double
  use ieee_arithmetic, only: ieee_is_nan, ieee_is_finite
  use yos_soil, only: tsoil
  use yos_veg, only: tveg
  use yos_urb, only: turb
  use yos_thf, only: rhoh2o
  implicit none
  private
  public :: srfwexc_vg
  real(real64), parameter :: one = 1.0_real64, zero = 0.0_real64, density = 1000.0_real64
  real(real64), parameter :: small = 100.0_real64*epsilon(one)
  interface
    function selected_power(base, exponent) bind(c, name="pow") result(answer)
      import c_double
      real(c_double), value :: base, exponent
      real(c_double) :: answer
    end function selected_power
    function selected_sine(angle) bind(c, name="sin") result(answer)
      import c_double
      real(c_double), value :: angle
      real(c_double) :: answer
    end function selected_sine
    subroutine reject_contract() bind(c, name="abort")
    end subroutine reject_contract
  end interface
contains
  !> Preserve the assembly minimum, including both zero signs.
  pure function minimum(a, b) result(v)
    real(real64), intent(in) :: a, b
    real(real64) :: v
    if (ieee_is_nan(a)) then
      v = a
    else if (ieee_is_nan(b)) then
      v = b
    else if (a == zero .and. b == zero) then
      v = transfer(ior(transfer(a, 0_int64), transfer(b, 0_int64)), zero)
    else if (a < b) then
      v = a
    else
      v = b
    end if
  end function minimum
  !> Preserve the assembly maximum, including both zero signs.
  pure function maximum(a, b) result(v)
    real(real64), intent(in) :: a, b
    real(real64) :: v
    if (ieee_is_nan(a)) then
      v = a
    else if (ieee_is_nan(b)) then
      v = b
    else if (a == zero .and. b == zero) then
      v = transfer(iand(transfer(a, 0_int64), transfer(b, 0_int64)), zero)
    else if (a > b) then
      v = a
    else
      v = b
    end if
  end function maximum

  !> Calculate one face in the order of assembly hydraulic labels5420--5621.
  !! Mode0 is the top outgoing face,1 is a deeper outgoing face,2 is the previous face.
  subroutine hydraulic(water, mode, layer, tiles, urban, sat, residual, dmin, dmax, lambda, m, alpha, &
                       saturated_conductivity, width, inverse_m, conductivity, diffusivity)
    real(real64), intent(in) :: water, urban, sat, residual, dmin, dmax, lambda, m, alpha
    real(real64), intent(in) :: saturated_conductivity, width, inverse_m
    integer(int32), intent(in) :: mode, layer, tiles
    real(real64), intent(out) :: conductivity, diffusivity
    real(real64) :: se, threshold, a, b, c, d, denominator, denominator_size, power_value
    se = water - residual
    se = se/width
    threshold = 1.001_real64
    if (mode == 1 .or. (mode == 2 .and. layer /= 2)) threshold = real(1.001_real32, real64)
    threshold = threshold*residual
    if (water <= threshold) then
      conductivity = zero
      diffusivity = dmin
      if (mode == 1 .and. tiles >= 10) then
        a = one - urban
        diffusivity = dmin*a
        a = urban*1.0e-4_real64
        diffusivity = diffusivity + a
      end if
      return
    end if
    threshold = 0.999_real64*sat
    if (water > threshold) then
      conductivity = saturated_conductivity
      diffusivity = dmax
      return
    end if

    a = selected_power(se, inverse_m)
    a = one - a
    b = selected_power(a, m)
    b = one - b
    b = b*b
    c = selected_power(se, lambda)
    conductivity = saturated_conductivity*c
    conductivity = conductivity*b
    if (mode == 2) return
    a = one - m
    a = a*saturated_conductivity
    denominator = alpha*m
    denominator = denominator*width
    denominator_size = abs(denominator)
    denominator_size = maximum(denominator_size, small)
    if (denominator < zero) denominator_size = -denominator_size
    a = a/denominator_size
    b = lambda - inverse_m
    c = selected_power(se, b)
    a = a*c
    b = selected_power(se, inverse_m)
    b = one - b
    c = selected_power(b, m)
    b = selected_power(se, inverse_m)
    b = one - b
    d = -m
    power_value = selected_power(b, d)
    c = c + power_value
    c = c - 2.0_real64
    diffusivity = a*c
  end subroutine hydraulic

  !> Transfer water using the structured column order of soil_water_exchange.S.
  !! Time is in s, layer depths in m, water fractions in m3/m3 and fluxes in kg/m2/s.
  !! The source's corrected symmetric dry thresholds are retained in hydraulic.
  !! The compiler owns descriptors and type layout; no Arm byte offsets are used.
  subroutine srfwexc_vg(kidia, kfdia, klon, klevs, ktiles, ptmst, ktvl, ktvh, ksoty, psdor, pfrti, pevapti, &
                        pwsam1m, ptsam1m, pcur, ptsfc, ptsfl, pmsn, pemssn, peintti, pevapsnw, ydsoil, ydveg, ydurb, &
                        pros, pcfw, prhsw, psawgfl, pfwel1, pfwe234, ldland, pdhwls)
    integer(int32), intent(in) :: kidia, kfdia, klon, klevs, ktiles, ktvl(:), ktvh(:), ksoty(:)
    real(real64), intent(in) :: ptmst, psdor(:), pfrti(:, :), pevapti(:, :), pwsam1m(:, :), ptsam1m(:, :)
    real(real64), intent(in) :: pcur(:), ptsfc(:), ptsfl(:), pmsn(:), pemssn(:), peintti(:, :), pevapsnw(:)
    type(tsoil), intent(in) :: ydsoil
    type(tveg), intent(in) :: ydveg
    type(turb), intent(in) :: ydurb
    logical, intent(in) :: ldland(:)
    real(real64), intent(inout) :: pros(:), pcfw(:, :), prhsw(:, :), psawgfl(:, :)
    real(real64), intent(inout) :: pfwel1(:), pfwe234(:), pdhwls(:, :, :)
    real(real64) :: frozen(klevs), liquid(klevs), roots(klevs, 3), root_totals(3), extraction(klevs)
    real(real64) :: inverse_time, inverse_density, inverse_rain_scale, epsilon_add
    real(real64) :: sat, capacity, wilt, residual, dmax, dmin, lambda, m, alpha, kconst, width, inverse_m, urban
    real(real64) :: conductivity, diffusivity, previous_conductivity, ignored_diffusivity
    real(real64) :: fraction, root_value, condensation, extracted, water, phase, previous_phase
    real(real64) :: a, b, c, d, e, top_flux, total_rain, runoff, infiltration, terrain_ratio, bshape, inverse_bshape
    real(real64) :: depth_sum, previous_depth, root_fraction, total_water, total_capacity, pore
    real(real64) :: scaled_capacity, excess, runoff_limit, relative_water, volume, runoff_volume
    integer(int32) :: column, layer, tile_index, tile, vegetation, soil_type, mode
    integer(int32), parameter :: root_tiles(3) = [4, 6, 7]
    logical :: diagnostics

    if (rhoh2o /= density) call reject_contract()
    if (klon < 1 .or. klon > 4096 .or. klevs < 2 .or. klevs > 512) call reject_contract()
    if (ktiles < 8 .or. ktiles > 10 .or. kidia < 1 .or. kidia > klon) call reject_contract()
    if (kfdia < kidia - 1 .or. kfdia > klon) call reject_contract()
    if (.not. ieee_is_finite(ptmst) .or. ptmst < 1.0e-9_real64 .or. ptmst > 1.0e9_real64) call reject_contract()
    if (min(size(ktvl), size(ktvh), size(ksoty), size(ldland)) < klon) call reject_contract()
    if (min(size(pwsam1m, 1), size(ptsam1m, 1), size(pcfw, 1), size(prhsw, 1), size(psawgfl, 1)) < klon) call reject_contract()
    if (min(size(pwsam1m, 2), size(ptsam1m, 2), size(pcfw, 2), size(prhsw, 2), size(psawgfl, 2)) < klevs) call reject_contract()
    if (min(size(pfrti, 1), size(pevapti, 1), size(peintti, 1)) < klon) call reject_contract()
    if (min(size(pfrti, 2), size(pevapti, 2), size(peintti, 2)) < ktiles) call reject_contract()
    if (min(size(psdor), size(pcur), size(ptsfc), size(ptsfl), size(pmsn), size(pemssn), size(pevapsnw), &
            size(pros), size(pfwel1), size(pfwe234)) < klon) call reject_contract()
    diagnostics = size(pdhwls) /= 0
    if (diagnostics) then
      if (size(pdhwls, 1) < klon .or. size(pdhwls, 2) < klevs .or. size(pdhwls, 3) < 10) call reject_contract()
    end if
    inverse_time = one/ptmst
    inverse_density = one/density
    inverse_rain_scale = one/ydsoil%rpsfr
    epsilon_add = zero
    if (ydsoil%lewbsoilfix) epsilon_add = small
    do column = kidia, kfdia
      soil_type = ksoty(column)
      sat = ydsoil%rwsatm(soil_type)
      capacity = ydsoil%rwcapm(soil_type)
      wilt = ydsoil%rwpwpm(soil_type)
      residual = ydsoil%rwrestm(soil_type)
      dmax = ydsoil%rdmaxm(soil_type)
      dmin = ydsoil%rdminm(soil_type)
      lambda = ydsoil%rlambdam(soil_type)
      m = ydsoil%rmfacm(soil_type)
      alpha = ydsoil%rmvgalpha(soil_type)
      kconst = ydsoil%rwconsm(soil_type)
      urban = pcur(column)
      condensation = zero
      do layer = 1, klevs
        a = ptsam1m(column, layer)
        if (a <= ydsoil%rtf2) then
          fraction = one
        else if (a >= ydsoil%rtf1) then
          fraction = zero
        else
          a = a - ydsoil%rtf3
          a = ydsoil%rtf4*a
          b = selected_sine(a)
          fraction = one - b
          fraction = 0.5_real64*fraction
        end if
        frozen(layer) = fraction
        a = one - fraction
        a = pwsam1m(column, layer)*a
        a = minimum(capacity, a)
        liquid(layer) = maximum(wilt, a)
      end do
      do tile_index = 1, 3
        tile = root_tiles(tile_index)
        a = pevapti(column, tile)
        if (tile == 7) a = a - pevapsnw(column)
        a = pfrti(column, tile)*a
        root_totals(tile_index) = zero
        vegetation = ktvh(column)
        if (tile == 4) vegetation = ktvl(column)
        do layer = 1, klevs
          if (a > zero) then
            root_value = zero
            if (layer == 1) root_value = one
          else
            b = liquid(layer) - wilt
            b = b + epsilon_add
            root_value = ydveg%rvrootsa(layer, vegetation)*b
          end if
          roots(layer, tile_index) = root_value
          root_totals(tile_index) = root_totals(tile_index) + root_value
        end do
        root_totals(tile_index) = maximum(small, root_totals(tile_index))
      end do
      if (ldland(column)) then
        width = sat - residual
        inverse_m = one/m
        do layer = 1, klevs
          water = pwsam1m(column, layer)
          if (layer < klevs) water = maximum(water, pwsam1m(column, layer + 1))
          water = maximum(water, residual)
          mode = 1
          if (layer == 1) mode = 0
          call hydraulic(water, mode, layer, ktiles, urban, sat, residual, dmin, dmax, lambda, m, alpha, kconst, &
                         width, inverse_m, conductivity, diffusivity)
          previous_conductivity = zero
          if (layer > 1) then
            water = maximum(pwsam1m(column, layer - 1), pwsam1m(column, layer))
            water = maximum(water, residual)
            call hydraulic(water, 2_int32, layer, ktiles, urban, sat, residual, dmin, dmax, lambda, m, alpha, kconst, &
                           width, inverse_m, previous_conductivity, ignored_diffusivity)
          end if
          phase = frozen(layer)
          if (layer < klevs) then
            phase = minimum(phase, frozen(layer + 1))
            a = phase*dmin
            b = one - phase
            b = b*diffusivity
            diffusivity = a + b
          else
            diffusivity = zero
          end if
          a = one - phase
          b = phase*zero
          a = a*conductivity
          conductivity = b + a
          if (layer > 1) then
            previous_phase = minimum(frozen(layer), frozen(layer - 1))
            a = one - previous_phase
            b = previous_phase*zero
            a = a*previous_conductivity
            previous_conductivity = b + a
          end if
          extracted = zero
          do tile_index = 1, 3
            tile = root_tiles(tile_index)
            a = pevapti(column, tile)
            if (tile == 7) a = a - pevapsnw(column)
            a = pfrti(column, tile)*a
            a = a - peintti(column, tile)
            b = a*roots(layer, tile_index)
            b = b/root_totals(tile_index)
            if (tile_index == 1) then
              extracted = b
            else
              extracted = extracted + b
            end if
            if (layer == 1) condensation = condensation + maximum(a, zero)
          end do
          extraction(layer) = extracted
          if (layer < klevs) then
            a = ydsoil%rdaw(layer) + ydsoil%rdaw(layer + 1)
            a = 0.5_real64*a
            b = diffusivity*ptmst
            b = b*ydsoil%rsimp
            pcfw(column, layer) = b/a
          else
            pcfw(column, layer) = zero
          end if
          if (layer == 1) then
            total_rain = ptsfl(column) + pmsn(column)
            total_rain = total_rain + ptsfc(column)
            if (ydsoil%lessro) then
              runoff = zero
              if (total_rain > zero) then
                a = psdor(column) - ydsoil%rsigormin
                a = maximum(zero, a)
                b = psdor(column) + ydsoil%rsigormax
                terrain_ratio = a/b
                bshape = minimum(terrain_ratio, 0.5_real64)
                bshape = maximum(bshape, 0.01_real64)
                bshape = one + bshape
                inverse_bshape = one/bshape
                depth_sum = zero
                total_water = zero
                total_capacity = zero
                do tile = 1, klevs
                  previous_depth = depth_sum
                  depth_sum = depth_sum + ydsoil%rdaw(tile)
                  a = minimum(ydsoil%rsrdep, depth_sum)
                  a = a - previous_depth
                  a = a/ydsoil%rdaw(tile)
                  root_fraction = maximum(zero, a)
                  a = pwsam1m(column, tile) - wilt
                  a = maximum(zero, a)
                  b = one - frozen(tile)
                  a = a*b
                  a = a + wilt
                  c = root_fraction*a
                  c = c*ydsoil%rdaw(tile)
                  total_water = total_water + c
                  pore = sat
                  if (ktiles >= 10) then
                    c = one - urban
                    c = c*sat
                    d = urban*ydurb%rurbsat
                    pore = c + d
                  end if
                  a = pore - wilt
                  a = a*b
                  a = a + wilt
                  c = root_fraction*a
                  c = c*ydsoil%rdaw(tile)
                  total_capacity = total_capacity + c
                end do
                scaled_capacity = total_capacity*bshape
                a = total_water - total_capacity
                excess = maximum(zero, a)
                runoff_limit = -one*excess
                a = 0.1_real64*total_capacity
                if (excess > a) runoff_limit = zero
                a = total_water - excess
                a = a/total_capacity
                a = maximum(zero, a)
                relative_water = minimum(one, a)
                a = one - relative_water
                volume = selected_power(a, inverse_bshape)
                a = inverse_time*density
                b = a*scaled_capacity
                b = total_rain/b
                volume = volume - b
                volume = maximum(zero, volume)
                runoff_volume = total_rain/a
                b = total_capacity - total_water
                b = maximum(b, runoff_limit)
                runoff_volume = runoff_volume - b
                if (volume > zero) then
                  b = selected_power(volume, bshape)
                  b = total_capacity*b
                  runoff_volume = runoff_volume + b
                end if
                runoff_volume = maximum(runoff_volume, zero)
                runoff = runoff_volume*density
                runoff = runoff*inverse_time
              end if
            else
              a = one - frozen(1)
              b = frozen(1)*dmin
              c = a*dmax
              b = b + c
              c = frozen(1)*zero
              a = a*kconst
              c = c + a
              pore = sat
              if (ktiles >= 10) then
                a = one - urban
                a = a*sat
                d = urban*ydurb%rurbsat
                pore = a + d
              end if
              a = pore - pwsam1m(column, 1)
              a = b*a
              d = 0.5_real64*ydsoil%rdaw(1)
              a = a/d
              a = a + c
              infiltration = a*density
              a = ptsfl(column) + pmsn(column)
              a = a - infiltration
              a = maximum(zero, a)
              b = ydsoil%rpsfr*ptsfc(column)
              b = b - infiltration
              b = maximum(zero, b)
              b = b*inverse_rain_scale
              runoff = a + b
            end if
            top_flux = total_rain - runoff
            a = pfrti(column, 3)*pevapti(column, 3)
            top_flux = top_flux + a
            top_flux = top_flux - peintti(column, 3)
            do tile_index = 1, 3
              tile = root_tiles(tile_index)
              a = pevapti(column, tile)
              if (tile == 7) a = a - pevapsnw(column)
              a = pfrti(column, tile)*a
              a = a - peintti(column, tile)
              a = a*roots(1, tile_index)
              a = a/root_totals(tile_index)
              top_flux = top_flux + a
            end do
            a = pfrti(column, 8)*pevapti(column, 8)
            a = a + pemssn(column)
            a = a - peintti(column, 8)
            top_flux = top_flux + a
            condensation = condensation + maximum(a, zero)
            if (ktiles >= 10) then
              a = pfrti(column, 10)*pevapti(column, 10)
              a = a + pemssn(column)
              a = a - peintti(column, 10)
              top_flux = top_flux + a
              condensation = condensation + maximum(a, zero)
            end if
            a = top_flux*inverse_density
            b = -conductivity
            b = b + a
            b = ptmst*b
            prhsw(column, layer) = b/ydsoil%rdaw(1)
            pros(column) = ptmst*runoff
            a = pfrti(column, 3)*pevapti(column, 3)
            a = a - peintti(column, 3)
            a = a + extraction(1)
            b = pfrti(column, 8)*pevapti(column, 8)
            a = a + b
            a = a - peintti(column, 8)
            a = pfwel1(column) + a
            if (ktiles >= 10) then
              b = pfrti(column, 10)*pevapti(column, 10)
              b = b - peintti(column, 10)
              a = a + b
            end if
            pfwel1(column) = a
          else
            a = previous_conductivity - conductivity
            b = extracted*inverse_density
            a = a + b
            a = ptmst*a
            prhsw(column, layer) = a/ydsoil%rdaw(layer)
            pfwe234(column) = pfwe234(column) + extracted
          end if
          psawgfl(column, layer) = density*conductivity
        end do
      else
        pros(column) = zero
        do layer = 1, klevs
          pcfw(column, layer) = zero
          prhsw(column, layer) = zero
          psawgfl(column, layer) = zero
          extraction(layer) = zero
        end do
      end if
      if (diagnostics) then
        do layer = 1, klevs
          a = density*ydsoil%rdaw(layer)
          a = a*pwsam1m(column, layer)
          pdhwls(column, layer, 1) = a
          pdhwls(column, layer, 2) = frozen(layer)*a
          pdhwls(column, layer, 3) = zero
          pdhwls(column, layer, 4) = zero
          pdhwls(column, layer, 5) = zero
          pdhwls(column, layer, 6) = zero
          pdhwls(column, layer, 10) = zero
          if (layer == 1) then
            pdhwls(column, layer, 3) = ptsfl(column)
            pdhwls(column, layer, 4) = ptsfc(column)
            pdhwls(column, layer, 5) = pmsn(column)
            a = inverse_time*pros(column)
            pdhwls(column, layer, 6) = zero - a
            pdhwls(column, layer, 7) = extraction(layer) - condensation
            a = pfrti(column, 8)*pevapti(column, 8)
            a = a - peintti(column, 8)
            a = a + pemssn(column)
            b = pfrti(column, 3)*pevapti(column, 3)
            a = a + b
            a = a - peintti(column, 3)
            pdhwls(column, layer, 9) = a
            pdhwls(column, layer, 10) = condensation
          else
            pdhwls(column, layer, 7) = extraction(layer)
            pdhwls(column, layer, 9) = zero
          end if
        end do
      end if
    end do
  end subroutine srfwexc_vg
end module srfwexc_vg_mod
