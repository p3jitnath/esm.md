module srft_mod
  use iso_fortran_env, only: int32, real64
  use iso_c_binding, only: c_double
  use ieee_arithmetic, only: ieee_is_finite, ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use yos_cst, only: tcst
  use yos_soil, only: tsoil
  use yos_flake, only: tflake
  use yos_urb, only: turb
  use srfwdif_mod, only: srfwdif
  implicit none
  private
  public :: srft
  interface
    function selected_sine(angle) bind(c, name="sin") result(value)
      import c_double
      real(c_double), value :: angle
      real(c_double) :: value
    end function selected_sine
    function selected_power(base, exponent) bind(c, name="pow") result(value)
      import c_double
      real(c_double), value :: base, exponent
      real(c_double) :: value
    end function selected_power
    function selected_logarithm(value) bind(c, name="log10") result(answer)
      import c_double
      real(c_double), value :: value
      real(c_double) :: answer
    end function selected_logarithm
    subroutine reject_contract() bind(c, name="abort")
    end subroutine reject_contract
  end interface
contains
  !> Advance soil temperature with the ordered body of soil_temperature_step.S.
  !!
  !! All arrays use native Fortran interfaces. KIDIA:KFDIA selects active columns.
  !! PTMST is in seconds; temperatures are in kelvin; surface fluxes are in W m^-2.
  !! PCTSA is volumetric heat capacity in J m^-3 K^-1. Only PTSA, PTSDFL and selected
  !! PDHTTS diagnostic fields change. Empty diagnostic arrays are allowed.
  subroutine srft(kidia,kfdia,klon,ktiles,klevs,ptmst,ptsam1m,pwsam1m,ksoty,pfrti,pahfsti,pevapti,pslrflti,pssrflti,pgsn,pctsa,ldland,ydcst,ydsoil,ydflake,ydurb,ptsa,ptsdfl,pdhtts)
    integer(int32), intent(in) :: kidia, kfdia, klon, ktiles, klevs, ksoty(:)
    real(real64), intent(in) :: ptmst,ptsam1m(:,:),pwsam1m(:,:),pfrti(:,:),pahfsti(:,:),pevapti(:,:),pslrflti(:,:),pssrflti(:,:),pgsn(:),pctsa(:,:)
    logical(int32), intent(in) :: ldland(:)
    type(tcst), intent(in) :: ydcst
    type(tsoil), intent(in) :: ydsoil
    type(tflake), intent(in) :: ydflake
    type(turb), intent(in) :: ydurb
    real(real64), intent(inout) :: ptsa(:, :), ptsdfl(:), pdhtts(:, :, :)
  real(real64), allocatable :: conductivity(:, :), factor(:, :), capacity_area(:, :), rhs(:, :), intermediate(:, :), surface_flux(:)
    logical, allocatable :: soil_mask(:)
    integer(int32) :: column, layer, tile, soil_kind, allocation_status, number_tiles
    integer(int32), parameter :: surface_tiles(5) = [3, 4, 6, 8, 10]
    real(real64) :: inverse_step, step_implicit, recovery_weight, water_capacity, dry, saturated, shortwave, longwave, turbulent
  real(real64) :: term,temporary,value,land_fraction,phase,unfrozen,water_power,inverse_capacity,ice_power,saturated_mixture,kersten
    real(real64) :: old_conductivity, old_thickness, ordinary_area, thickness, urban_fraction
    real(real64), volatile :: smallest, subnormal
    logical :: diagnostics
    type(ieee_round_type) :: rounding
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) call reject_contract()
    smallest = tiny(1.0_real64)
    subnormal = smallest*0.5_real64
    if (subnormal == 0.0_real64) call reject_contract()
    if (klon < 1 .or. klon > 4096 .or. klevs < 2 .or. klevs > 512) call reject_contract()
    if (kidia < 1 .or. kidia > klon .or. kfdia < 0 .or. kfdia > klon .or. kfdia < kidia - 1) call reject_contract()
    if (ktiles < 8 .or. ktiles > 16) call reject_contract()
    if (min(size(ksoty), size(ldland), size(pgsn), size(ptsdfl)) < klon) call reject_contract()
    if (min(size(ptsam1m, 1), size(pwsam1m, 1), size(pctsa, 1), size(ptsa, 1)) < klon) call reject_contract()
    if (min(size(ptsam1m, 2), size(pwsam1m, 2), size(pctsa, 2), size(ptsa, 2)) < klevs) call reject_contract()
    if (min(size(pfrti, 1), size(pahfsti, 1), size(pevapti, 1), size(pslrflti, 1), size(pssrflti, 1)) < klon) call reject_contract()
  if (min(size(pfrti, 2), size(pahfsti, 2), size(pevapti, 2), size(pslrflti, 2), size(pssrflti, 2)) < ktiles) call reject_contract()
    diagnostics = size(pdhtts) > 0
    if (diagnostics) then
 if (size(pdhtts, 1) < klon .or. size(pdhtts, 2) < klevs .or. size(pdhtts, 3) < 15 .or. size(pdhtts, 3) > 32) call reject_contract()
    end if
    if (.not. allocated(ydsoil%rdat)) call reject_contract()
    if (lbound(ydsoil%rdat, 1) > 1 .or. ubound(ydsoil%rdat, 1) < klevs) call reject_contract()
    if (ydsoil%levgen) then
      if (.not.allocated(ydsoil%rwsatm) .or. .not.allocated(ydsoil%rlambdadrym) .or. .not.allocated(ydsoil%rlamsat1m)) call reject_contract()
    end if
    if (ydflake%leflake .and. ktiles < 9) call reject_contract()
    if (.not. in_range(ydsoil%rsimp, 0.5_real64, 1.0_real64)) call reject_contract()
    if (.not. in_range(ptmst, 1.0e-9_real64, 1.0e9_real64)) call reject_contract()
    if (.not. in_range(ydcst%rlvtt, 1.0_real64, 1.0e9_real64)) call reject_contract()
    if (ydsoil%rtf1 /= 274.16_real64 .or. ydsoil%rtf2 /= 270.16_real64) call reject_contract()
    if (ydsoil%rtf3 /= 272.16_real64 .or. ydsoil%rtf4 /= 0.7853981633974483_real64) call reject_contract()
    if (.not. in_range(ydsoil%rkerst1, 2.0_real64**(-40), 1.0_real64)) call reject_contract()
    if (.not.in_range(ydsoil%rkerst2,0.0_real64,16.0_real64) .or. .not.in_range(ydsoil%rkerst3,0.0_real64,16.0_real64)) call reject_contract()
    if (.not.in_range(ydsoil%rlambdaice,0.1_real64,10.0_real64) .or. .not.in_range(ydsoil%rlambdawat,0.1_real64,10.0_real64)) call reject_contract()
    if (.not.in_range(ydsoil%rrcsoil,1.0_real64,1.0e12_real64) .or. .not.in_range(ydsoil%rfrsmall,0.0_real64,1.0_real64)) call reject_contract()
    if (ktiles > 9) then
      if (.not.in_range(ydurb%rurbtc1,1.0e-6_real64,1.0e12_real64) .or. .not.in_range(ydurb%rurbvhc,1.0_real64,1.0e12_real64)) call reject_contract()
    end if
    if (.not. ydsoil%levgen) then
      if (.not. in_range(ydsoil%rwsat, 0.03125_real64, 1.0_real64)) call reject_contract()
      if (.not.in_range(ydsoil%rlambdadry,1.0e-6_real64,1.0e6_real64) .or. .not.in_range(ydsoil%rlamsat1,1.0e-6_real64,1.0e6_real64)) call reject_contract()
    end if
    do layer = 1, klevs
      if (.not. in_range(ydsoil%rdat(layer), 1.0e-9_real64, 1.0e6_real64)) call reject_contract()
    end do
    do column = kidia, kfdia
      if (.not. ldland(column)) cycle
      if (ydsoil%levgen) then
        soil_kind = ksoty(column)
        if (soil_kind < lbound(ydsoil%rwsatm, 1) .or. soil_kind > ubound(ydsoil%rwsatm, 1)) call reject_contract()
        if (soil_kind < lbound(ydsoil%rlambdadrym, 1) .or. soil_kind > ubound(ydsoil%rlambdadrym, 1)) call reject_contract()
        if (soil_kind < lbound(ydsoil%rlamsat1m, 1) .or. soil_kind > ubound(ydsoil%rlamsat1m, 1)) call reject_contract()
        if (.not. in_range(ydsoil%rwsatm(soil_kind), 0.03125_real64, 1.0_real64)) call reject_contract()
        if (.not. in_range(ydsoil%rlambdadrym(soil_kind), 1.0e-6_real64, 1.0e6_real64)) call reject_contract()
        if (.not. in_range(ydsoil%rlamsat1m(soil_kind), 1.0e-6_real64, 1.0e6_real64)) call reject_contract()
      end if
      if (.not. in_range(pgsn(column), -1.0e7_real64, 1.0e7_real64)) call reject_contract()
      do layer = 1, klevs
        if (.not. in_range(ptsam1m(column, layer), 100.0_real64, 500.0_real64)) call reject_contract()
        if (.not. in_range(pwsam1m(column, layer), 0.0_real64, 1.0_real64)) call reject_contract()
        if (.not. in_range(pctsa(column, layer), 1.0_real64, 1.0e12_real64)) call reject_contract()
      end do
      do tile = 1, ktiles
        if (.not. in_range(pfrti(column, tile), 0.0_real64, 1.0_real64)) call reject_contract()
        if (.not. in_range(pahfsti(column, tile), -1.0e7_real64, 1.0e7_real64)) call reject_contract()
        if (.not. in_range(pevapti(column, tile), -1.0_real64, 1.0_real64)) call reject_contract()
        if (.not. in_range(pslrflti(column, tile), -1.0e7_real64, 1.0e7_real64)) call reject_contract()
        if (.not. in_range(pssrflti(column, tile), -1.0e7_real64, 1.0e7_real64)) call reject_contract()
      end do
      if (ktiles > 9 .and. diagnostics) then
        if (pevapti(column, 10) /= 0.0_real64) call reject_contract()
      end if
    end do
    inverse_step = 1.0_real64/ptmst
    step_implicit = ptmst*ydsoil%rsimp
    recovery_weight = 1.0_real64/ydsoil%rsimp
    recovery_weight = 1.0_real64 - recovery_weight
    allocate(conductivity(klon,klevs),factor(klon,klevs),capacity_area(klon,klevs),rhs(klon,klevs),intermediate(klon,klevs),surface_flux(klon),soil_mask(klon),stat=allocation_status)
    if (allocation_status /= 0) call reject_contract()
    conductivity = 0.0_real64; factor = 0.0_real64; capacity_area = 0.0_real64; rhs = 0.0_real64
    intermediate = 0.0_real64; surface_flux = 0.0_real64; soil_mask = .false.
    number_tiles = 4
    if (ktiles > 9) number_tiles = 5
    do column = kidia, kfdia
      soil_mask(column) = ldland(column)
      if (.not. ldland(column)) cycle
      shortwave = pfrti(column, 3)*pssrflti(column, 3)
      do tile = 2, number_tiles
        term = pfrti(column, surface_tiles(tile))*pssrflti(column, surface_tiles(tile))
        shortwave = shortwave + term
      end do
      longwave = pfrti(column, 3)*pslrflti(column, 3)
      do tile = 2, number_tiles
        term = pfrti(column, surface_tiles(tile))*pslrflti(column, surface_tiles(tile))
        longwave = longwave + term
      end do
      term = ydcst%rlvtt*pevapti(column, 3)
      term = pahfsti(column, 3) + term
      turbulent = pfrti(column, 3)*term
      do tile = 2, number_tiles
        term = ydcst%rlvtt*pevapti(column, surface_tiles(tile))
        term = pahfsti(column, surface_tiles(tile)) + term
        term = pfrti(column, surface_tiles(tile))*term
        turbulent = turbulent + term
      end do
      temporary = shortwave + longwave
      value = temporary + turbulent
      surface_flux(column) = value + pgsn(column)
      if (ydflake%leflake) then
        if (pfrti(column, 9) > ydsoil%rfrsmall) then
          surface_flux(column) = pgsn(column)
          land_fraction = pfrti(column, 3) + pfrti(column, 4)
          land_fraction = land_fraction + pfrti(column, 6)
          land_fraction = land_fraction + pfrti(column, 8)
          if (land_fraction > ydsoil%rfrsmall) then
            temporary = value/land_fraction
            surface_flux(column) = pgsn(column) + temporary
          end if
          if (ktiles > 9) then
            land_fraction = land_fraction + pfrti(column, 10)
            if (land_fraction > ydsoil%rfrsmall) then
              temporary = value/land_fraction
              surface_flux(column) = pgsn(column) + temporary
            end if
          end if
        end if
      end if
      if (ydsoil%levgen) then
        soil_kind = ksoty(column)
        water_capacity = ydsoil%rwsatm(soil_kind)
        dry = ydsoil%rlambdadrym(soil_kind)
        saturated = ydsoil%rlamsat1m(soil_kind)
      else
        water_capacity = ydsoil%rwsat
        dry = ydsoil%rlambdadry
        saturated = ydsoil%rlamsat1
      end if
      do layer = 1, klevs
        if (ptsam1m(column, layer) >= ydsoil%rtf1) then
          phase = 0.0_real64
        else if (ptsam1m(column, layer) <= ydsoil%rtf2) then
          phase = 1.0_real64
        else
          temporary = ptsam1m(column, layer) - ydsoil%rtf3
          temporary = ydsoil%rtf4*temporary
          phase = selected_sine(temporary)
          phase = 1.0_real64 - phase
          phase = 0.5_real64*phase
        end if
        temporary = 1.0_real64 - phase
        unfrozen = water_capacity*temporary
        water_power = selected_power(ydsoil%rlambdawat, unfrozen)
        inverse_capacity = 1.0_real64/water_capacity
        temporary = water_capacity - unfrozen
        ice_power = selected_power(ydsoil%rlambdaice, temporary)
        saturated_mixture = saturated*ice_power
        saturated_mixture = saturated_mixture*water_power
        temporary = pwsam1m(column, layer)*inverse_capacity
        temporary = max(temporary, ydsoil%rkerst1)
        kersten = selected_logarithm(temporary)
        kersten = ydsoil%rkerst2*kersten
        kersten = kersten + ydsoil%rkerst3
        temporary = saturated_mixture - dry
        temporary = kersten*temporary
        value = dry + temporary
        if (ydsoil%levgen) then
          if (ydsoil%lesoilcond) then
            temporary = pwsam1m(column, layer)/water_capacity
            temporary = max(temporary, ydsoil%rkerst1)
            kersten = selected_logarithm(temporary)
            kersten = ydsoil%rkerst2*kersten
            kersten = kersten + ydsoil%rkerst3
            temporary = water_capacity*phase
            ice_power = selected_power(ydsoil%rlambdaice, temporary)
            water_power = selected_power(ydsoil%rlambdawat, unfrozen)
            temporary = saturated*ice_power
            temporary = temporary*water_power
            temporary = temporary - dry
            temporary = kersten*temporary
            value = dry + temporary
          end if
          if (layer == 1 .and. ktiles > 9) then
            urban_fraction = pfrti(column, 10)
            temporary = 1.0_real64 - urban_fraction
            temporary = temporary*value
            term = urban_fraction*ydurb%rurbtc1
            value = temporary + term
          end if
        end if
        if (.not. in_range(value, 1.0e-30_real64, 1.0e12_real64)) call reject_contract()
        conductivity(column, layer) = value
      end do
    end do
    do column = kidia, kfdia
      if (.not. ldland(column)) cycle
      do layer = 1, klevs
        old_conductivity = conductivity(column, layer)
        old_thickness = ydsoil%rdat(layer)
        capacity_area(column, layer) = pctsa(column, layer)*old_thickness
        if (layer < klevs) then
          value = old_conductivity + conductivity(column, layer + 1)
          value = step_implicit*value
          temporary = old_thickness + ydsoil%rdat(layer + 1)
          value = value/temporary
        else
          value = 0.0_real64
        end if
        factor(column, layer) = value
        value = 0.0_real64
        if (layer == 1) then
          value = ptmst*surface_flux(column)
          value = value/capacity_area(column, layer)
        end if
        rhs(column, layer) = value
      end do
    end do
    call srfwdif(kidia, kfdia, klon, klevs, ptsam1m, factor, rhs, capacity_area, ydsoil, intermediate, soil_mask)
    do column = kidia, kfdia
      if (.not. ldland(column)) cycle
      do layer = 1, klevs
        value = ptsam1m(column, layer)*recovery_weight
        value = value + intermediate(column, layer)
        if (.not. in_range(value, tiny(1.0_real64), 1.0e300_real64)) call reject_contract()
      end do
    end do
    do column = kidia, kfdia
      value = 0.0_real64
      if (ldland(column)) then
        value = intermediate(column, 2) - intermediate(column, 1)
        value = value*factor(column, 1)
        value = value*inverse_step
      end if
      ptsdfl(column) = value
      do layer = 1, klevs
        value = ptsam1m(column, layer)
        if (ldland(column)) then
          value = value*recovery_weight
          value = value + intermediate(column, layer)
        end if
        ptsa(column, layer) = value
      end do
      if (.not. diagnostics) cycle
      do layer = 1, klevs
        if (ldland(column)) then
          thickness = ydsoil%rdat(layer)
          ordinary_area = ydsoil%rrcsoil*thickness
          value = ordinary_area
          if (ktiles > 9) then
            urban_fraction = pfrti(column, 10)
            temporary = 1.0_real64 - urban_fraction
            value = ydsoil%rrcsoil*temporary
            temporary = urban_fraction*ydurb%rurbvhc
            value = value + temporary
            value = value*thickness
          end if
          pdhtts(column, layer, 1) = value
          pdhtts(column, layer, 2) = ptsam1m(column, layer)
          value = ordinary_area*ptsam1m(column, layer)
          pdhtts(column, layer, 3) = value
          pdhtts(column, layer, 4) = thickness
          value = pctsa(column, layer) - ydsoil%rrcsoil
          value = -value
          value = value*thickness
          temporary = ptsa(column, layer) - ptsam1m(column, layer)
          value = value*temporary
          value = value*inverse_step
          pdhtts(column, layer, 12) = value
          value = intermediate(column, layer) - ptsam1m(column, layer)
          value = ordinary_area*value
          value = value/ptmst
          pdhtts(column, layer, 15) = value
          if (layer == 1) then
            value = pfrti(column, 3)*pahfsti(column, 3)
            do tile = 2, number_tiles
              temporary = pfrti(column, surface_tiles(tile))*pahfsti(column, surface_tiles(tile))
              value = value + temporary
            end do
            pdhtts(column, layer, 9) = value
            value = pfrti(column, 3)*pevapti(column, 3)
            do tile = 2, 4
              temporary = pfrti(column, surface_tiles(tile))*pevapti(column, surface_tiles(tile))
              value = value + temporary
            end do
            value = ydcst%rlvtt*value
            if (ktiles > 9) then
              temporary = pfrti(column, 10)*pevapti(column, 10)
              value = value + temporary
            end if
            pdhtts(column, layer, 10) = value
            pdhtts(column, layer, 13) = pgsn(column)
            pdhtts(column, layer, 14) = -surface_flux(column)
          else
            pdhtts(column, layer, 9) = 0.0_real64
            pdhtts(column, layer, 10) = 0.0_real64
            pdhtts(column, layer, 13) = 0.0_real64
            pdhtts(column, layer, 14) = 0.0_real64
          end if
          if (layer < klevs) then
            value = intermediate(column, layer) - intermediate(column, layer + 1)
            value = ydsoil%rsimp*value
            value = value*factor(column, layer)
            value = value*inverse_step
          else
            value = 0.0_real64
          end if
          pdhtts(column, layer, 11) = value
        else
          pdhtts(column, layer, 1) = 0.0_real64
          pdhtts(column, layer, 2) = 0.0_real64
          pdhtts(column, layer, 3) = 0.0_real64
          pdhtts(column, layer, 4) = 0.0_real64
          pdhtts(column, layer, 9) = 0.0_real64
          pdhtts(column, layer, 10) = 0.0_real64
          pdhtts(column, layer, 11) = 0.0_real64
          pdhtts(column, layer, 12) = 0.0_real64
          pdhtts(column, layer, 13) = 0.0_real64
          pdhtts(column, layer, 14) = 0.0_real64
          pdhtts(column, layer, 15) = 0.0_real64
        end if
      end do
    end do
  end subroutine srft
  !> Check a finite physical interval without changing the supplied value.
  pure logical function in_range(value, low, high)
    real(real64), intent(in) :: value, low, high
    in_range = ieee_is_finite(value) .and. value >= low .and. value <= high
  end function in_range
end module srft_mod
