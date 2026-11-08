module srfsn_webal_mod
  use iso_fortran_env, only: int32, int64, real64
  use ieee_arithmetic, only: ieee_is_nan
  use yos_soil, only: tsoil
  use yos_cst, only: tcst
  implicit none
  private
  public :: srfsn_webal, trisolver
  interface
    subroutine reject_contract() bind(c, name="abort")
    end subroutine reject_contract
  end interface
contains
  !> Advance layered snow water and heat in the order of snow_water_energy.S.
  !!
  !! Mass and water use kg m^-2, density uses kg m^-3, temperature uses kelvin,
  !! time uses seconds, and heat rates use W m^-2. Only the nine returned owners change.
  !! Native Fortran vectors retain separately rounded stages and call our own column solver.
  subroutine srfsn_webal(kidia,kfdia,klon,klevsn,ptmst,llnosnow,pfrsn,pssnm1m,pwsnm1m,prsnm1m,ptsnm1m,ptsurf,phflux,zsnotrs,psnowf,prainf,pevapsn,psurfcond,paprs,ydsoil,ydcst,pssn,pwsn,ptsn,pgsn,prusn,pmeltsn,pfrezsn,pdhtss,pdhsss)
    integer(int32), intent(in) :: kidia, kfdia, klon, klevsn
    real(real64), intent(in) :: ptmst,pfrsn(:),pssnm1m(:,:),pwsnm1m(:,:),prsnm1m(:,:),ptsnm1m(:,:),ptsurf(:),phflux(:),zsnotrs(:,:),psnowf(:),prainf(:),pevapsn(:),psurfcond(:),paprs(:)
    logical(int32), intent(in) :: llnosnow(:)
    type(tsoil), intent(in) :: ydsoil
    type(tcst), intent(in) :: ydcst
 real(real64), intent(inout) :: pssn(:,:),pwsn(:,:),ptsn(:,:),pgsn(:),prusn(:),pmeltsn(:,:),pfrezsn(:,:),pdhtss(:,:,:),pdhsss(:,:,:)
    real(real64) :: depth(klevsn), heat_capacity(klevsn), ice(klevsn), conductivity(klevsn), interface(0:klevsn)
    real(real64) :: lower(klevsn),diagonal(klevsn),upper(klevsn),rhs(klevsn),temperature(klevsn),new_ice(klevsn),new_water(klevsn),liquid_flux(0:klevsn)
    real(real64), parameter :: threshold = 10.0_real64*epsilon(1.0_real64)
    real(real64) :: ice_capacity, inverse_step, soil_depth, ground_flux, residual, water, phase_energy, melt, freeze
    real(real64) :: value, temporary, term, numerator, denominator, change, retained_capacity
    integer(int32) :: column, layer, active
    logical :: diagnostics
    if (klon < 1 .or. klon > 4096 .or. klevsn < 1 .or. klevsn > 4096 .or. kidia < 1 .or. kfdia > klon) call reject_contract()
    if (min(size(llnosnow),size(pfrsn),size(pssnm1m,1),size(pwsnm1m,1),size(prsnm1m,1),size(ptsnm1m,1),size(ptsurf),size(phflux),size(zsnotrs,1),size(psnowf),size(prainf),size(pevapsn),size(psurfcond),size(paprs),size(pssn,1),size(pwsn,1),size(ptsn,1),size(pgsn),size(prusn),size(pmeltsn,1),size(pfrezsn,1))<klon) call reject_contract()
    if (min(size(pssnm1m,2),size(pwsnm1m,2),size(prsnm1m,2),size(ptsnm1m,2),size(pssn,2),size(pwsn,2),size(ptsn,2),size(pmeltsn,2),size(pfrezsn,2))<klevsn .or. size(zsnotrs,2)<klevsn+1) call reject_contract()
    diagnostics = size(pdhtss) > 0 .and. size(pdhsss) > 0
    if (diagnostics) then
      if (min(size(pdhtss, 1), size(pdhsss, 1)) < klon .or. min(size(pdhtss, 2), size(pdhsss, 2)) < klevsn) call reject_contract()
      if (size(pdhtss, 3) < 15 .or. size(pdhsss, 3) < 5) call reject_contract()
    end if
    if (.not. allocated(ydsoil%rdaw)) call reject_contract()
    if (lbound(ydsoil%rdaw, 1) > 1 .or. ubound(ydsoil%rdaw, 1) < 1) call reject_contract()
    ice_capacity = ydsoil%rhoci/ydsoil%rhoice
    inverse_step = 1.0_real64/ptmst
    soil_depth = ydsoil%rdaw(1)
    do column = kidia, kfdia
      if (llnosnow(column)) then
        value = psnowf(column) + pevapsn(column)
        value = ptmst*value
        value = pssnm1m(column, 1) + value
        pssn(column, 1) = maximum(0.0_real64, value)
        do layer = 1, klevsn
          if (layer > 1) pssn(column, layer) = 0.0_real64
          ptsn(column, layer) = ydcst%rtt
          pwsn(column, layer) = 0.0_real64
          pmeltsn(column, layer) = 0.0_real64
          pfrezsn(column, layer) = 0.0_real64
          if (diagnostics) then
            pdhtss(column, layer, 1) = 0.0_real64
            pdhtss(column, layer, 2) = ydcst%rtt
            pdhtss(column, layer, 3) = 0.0_real64
            pdhtss(column, layer, 4) = 0.0_real64
            pdhtss(column, layer, 13) = 0.0_real64
            pdhtss(column, layer, 14) = 0.0_real64
            pdhtss(column, layer, 15) = 0.0_real64
            pdhsss(column, layer, 1) = 0.0_real64
            pdhsss(column, layer, 4) = 0.0_real64
            pdhsss(column, layer, 5) = 0.0_real64
          end if
        end do
        pgsn(column) = 0.0_real64
        prusn(column) = 0.0_real64
        cycle
      end if
      active = 0
      do layer = 1, klevsn
        if (pssnm1m(column, layer) > threshold) active = layer
      end do
      if (active < 1) call reject_contract()
      do layer = 1, klevsn
        ice(layer) = pssnm1m(column, layer) - pwsnm1m(column, layer)
        value = pssnm1m(column, layer)/prsnm1m(column, layer)
        depth(layer) = minimum(ydsoil%rdsnmax, value)
        value = ice(layer)/prsnm1m(column, layer)
        value = minimum(value, ydsoil%rdsnmax)
        temporary = ice_capacity*prsnm1m(column, layer)
        temporary = temporary*value
        term = 4180.0_real64*pwsnm1m(column, layer)
        temporary = temporary + term
        heat_capacity(layer) = temporary*inverse_step
        value = ptsnm1m(column, layer) - ydsoil%snhcondcv
        value = ydsoil%snhcondbv/value
        value = ydsoil%snhcondav - value
        value = maximum(0.0_real64, value)
        temporary = ydsoil%snhcondpov/paprs(column)
        value = temporary*value
        temporary = 2.5e-6_real64*prsnm1m(column, layer)
        temporary = temporary*prsnm1m(column, layer)
        term = 1.23e-4_real64*prsnm1m(column, layer)
        temporary = temporary - term
        temporary = temporary + 0.024_real64
        conductivity(layer) = temporary + value
      end do
      if (active == 1) heat_capacity(1) = maximum(threshold, heat_capacity(1))
      numerator = pfrsn(column)*conductivity(1)
      denominator = 0.5_real64*depth(1)
      denominator = denominator*denominator
      denominator = maximum(denominator, threshold)
      interface(0) = numerator/denominator
      do layer = 2, active
        numerator = depth(layer - 1)*conductivity(layer - 1)
        temporary = depth(layer)*conductivity(layer)
        numerator = numerator + temporary
        temporary = pfrsn(column)*2.0_real64
        numerator = temporary*numerator
        denominator = depth(layer - 1) + depth(layer)
        denominator = denominator*denominator
        denominator = maximum(denominator, threshold)
        interface(layer - 1) = numerator/denominator
      end do
      numerator = depth(active)*conductivity(active)
      temporary = soil_depth*psurfcond(column)
      numerator = numerator + temporary
      numerator = pfrsn(column)*numerator
      denominator = depth(active) + soil_depth
      denominator = denominator*denominator
      denominator = maximum(denominator, threshold)
      interface(active) = numerator/denominator
      if (active > 1) then
        do layer = 1, active
          lower(layer) = 0.0_real64
          if (layer > 1) lower(layer) = -interface(layer - 1)
          value = heat_capacity(layer)
          if (layer > 1) value = value + interface(layer - 1)
          diagonal(layer) = value + interface(layer)
          upper(layer) = 0.0_real64
          if (layer < active) upper(layer) = -interface(layer)
          value = heat_capacity(layer)*ptsnm1m(column, layer)
          if (layer == 1) then
            temporary = phflux(column) - zsnotrs(column, layer)
            rhs(layer) = temporary + value
          else
            if (layer == active) then
              temporary = interface(active)*ptsurf(column)
              value = value + temporary
            end if
            rhs(layer) = value + zsnotrs(column, layer)
          end if
        end do
        do layer = 1, klevsn
          temperature(layer) = ptsnm1m(column, layer)
        end do
        call trisolver(active, lower, diagonal, upper, rhs, temperature)
        value = temperature(active) - ptsurf(column)
        ground_flux = interface(active)*value
      else
        do layer = 1, klevsn
          temperature(layer) = ptsnm1m(column, layer)
        end do
        diagonal(1) = heat_capacity(1) + interface(1)
        value = phflux(column) - zsnotrs(column, 1)
        temporary = heat_capacity(1)*ptsnm1m(column, 1)
        value = value + temporary
        temporary = interface(1)*ptsurf(column)
        rhs(1) = value + temporary
        temperature(1) = rhs(1)/diagonal(1)
        value = temperature(1) - ptsurf(column)
        ground_flux = interface(1)*value
      end if
      if (temperature(1) > ydcst%rtt) then
        if (active > 1) then
          diagonal(1) = 1.0_real64
          upper(1) = 0.0_real64
          rhs(1) = ydcst%rtt
          do layer = 1, klevsn
            temperature(layer) = ptsnm1m(column, layer)
          end do
          call trisolver(active, lower, diagonal, upper, rhs, temperature)
          value = temperature(active) - ptsurf(column)
          ground_flux = interface(active)*value
          value = temperature(1) - temperature(2)
          value = interface(1)*value
        else
          value = ydcst%rtt - ptsurf(column)
          value = interface(1)*value
          ground_flux = value
        end if
        temporary = phflux(column) - zsnotrs(column, 1)
        term = heat_capacity(1)*ptsnm1m(column, 1)
        temporary = temporary + term
        value = temporary - value
        denominator = maximum(threshold, heat_capacity(1))
        temperature(1) = value/denominator
      end if
      do layer = 1, klevsn
        new_ice(layer) = ice(layer)
        new_water(layer) = pwsnm1m(column, layer)
        liquid_flux(layer - 1) = 0.0_real64
        pmeltsn(column, layer) = 0.0_real64
        pfrezsn(column, layer) = 0.0_real64
      end do
      liquid_flux(klevsn) = 0.0_real64
      value = psnowf(column) + pevapsn(column)
      value = ptmst*value
      new_ice(1) = ice(1) + value
      liquid_flux(0) = ptmst*prainf(column)
      residual = 0.0_real64
      do layer = 1, active
        water = pwsnm1m(column, layer) + liquid_flux(layer - 1)
        new_water(layer) = water
        phase_energy = temperature(layer) - ydcst%rtt
        phase_energy = heat_capacity(layer)*phase_energy
        value = ydcst%rlmlt*inverse_step
        value = value*new_ice(layer)
        value = minimum(phase_energy, value)
        melt = maximum(value, 0.0_real64)
        pmeltsn(column, layer) = melt
        value = -ydcst%rlmlt
        value = value*inverse_step
        value = value*water
        value = maximum(phase_energy, value)
        freeze = minimum(value, 0.0_real64)
        pfrezsn(column, layer) = freeze
        phase_energy = melt + freeze
        value = phase_energy + residual
        denominator = maximum(threshold, heat_capacity(layer))
        value = value/denominator
        temperature(layer) = temperature(layer) - value
        if (temperature(layer) > ydcst%rtt) then
          value = ydcst%rtt - temperature(layer)
          residual = heat_capacity(layer)*value
          temperature(layer) = ydcst%rtt
        else
          residual = 0.0_real64
        end if
        change = phase_energy/ydcst%rlmlt
        change = change*ptmst
        water = water + change
        new_water(layer) = water
        new_ice(layer) = new_ice(layer) - change
        value = ydsoil%rlwcswea - prsnm1m(column, layer)
        value = maximum(value, 0.0_real64)
        temporary = ydsoil%rlwcswec - ydsoil%rlwcsweb
        value = temporary*value
        value = value/ydsoil%rlwcswea
        value = ydsoil%rlwcsweb + value
        retained_capacity = new_ice(layer)*value
        value = water - retained_capacity
        liquid_flux(layer) = maximum(value, 0.0_real64)
        new_water(layer) = water - liquid_flux(layer)
      end do
      value = temperature(active)
      do layer = active + 1, klevsn
        temperature(layer) = value
      end do
      do layer = 1, klevsn
        ptsn(column, layer) = minimum(ydcst%rtt, temperature(layer))
        value = new_water(layer) + new_ice(layer)
        value = maximum(value, 0.0_real64)
        pssn(column, layer) = value
        temporary = maximum(new_water(layer), 0.0_real64)
        pwsn(column, layer) = minimum(temporary, value)
      end do
      prusn(column) = liquid_flux(active)*inverse_step
      value = ground_flux - residual
      pgsn(column) = value + zsnotrs(column, active + 1)
      if (diagnostics) then
        do layer = 1, klevsn
          value = heat_capacity(layer)*ptmst
          pdhtss(column, layer, 1) = value
          pdhtss(column, layer, 2) = ptsnm1m(column, layer)
          temporary = value*ptsnm1m(column, layer)
          pdhtss(column, layer, 3) = temporary
          temporary = pssnm1m(column, layer)/prsnm1m(column, layer)
          pdhtss(column, layer, 4) = temporary
          pdhtss(column, 1, 13) = pgsn(column)
          phase_energy = pmeltsn(column, layer) + pfrezsn(column, layer)
          pdhtss(column, layer, 14) = phase_energy
          temporary = ptsn(column, layer) - ptsnm1m(column, layer)
          temporary = value*temporary
          pdhtss(column, layer, 15) = temporary
          pdhsss(column, layer, 1) = pssnm1m(column, layer)
          pdhsss(column, layer, 4) = pevapsn(column)
          pdhsss(column, layer, 5) = phase_energy/ydcst%rlmlt
        end do
      end if
    end do
  end subroutine srfsn_webal
  !> Solve a snow heat column with the operation order of snow_trisolver.S.
  !!
  !! KSNLAC is the active layer count, from one to 4096. ZA, ZB and ZC are
  !! lower, central and upper matrix coefficients; ZF is the heat input.
  !! Each assumed-shape vector keeps its own stride. Only active ZTSTAR cells change.
  !! The caller supplies finite coefficients and nonzero finite elimination pivots.
  subroutine trisolver(ksnlac, za, zb, zc, zf, ztstar)
    integer(int32), intent(in) :: ksnlac
    real(real64), intent(in) :: za(:), zb(:), zc(:), zf(:)
    real(real64), intent(inout) :: ztstar(:)
    real(real64) :: gamma(4096), pivot, returned, coefficient, temporary, ratio
    integer(int32) :: layer
    if (ksnlac < 1 .or. ksnlac > 4096) call reject_contract()
    if (min(size(za), size(zb), size(zf), size(ztstar)) < ksnlac) call reject_contract()
    if (size(zc) < ksnlac - 1) call reject_contract()
    pivot = zb(1)
    returned = zf(1)/pivot
    ztstar(1) = returned
    do layer = 2, ksnlac
      ratio = zc(layer - 1)/pivot
      gamma(layer) = ratio
      coefficient = za(layer)
      temporary = coefficient*ratio
      pivot = zb(layer) - temporary
      temporary = coefficient*returned
      returned = zf(layer) - temporary
      returned = returned/pivot
      ztstar(layer) = returned
    end do
    do layer = ksnlac - 1, 1, -1
      temporary = gamma(layer + 1)*returned
      returned = ztstar(layer) - temporary
      ztstar(layer) = returned
    end do
  end subroutine trisolver
  !> Preserve minimum and maximum signed zeros.
  pure function minimum(a, b) result(value)
    real(real64), intent(in) :: a, b
    real(real64) :: value
    if (ieee_is_nan(a)) then
      value = a
    else if (ieee_is_nan(b)) then
      value = b
    else if (a == 0.0_real64 .and. b == 0.0_real64) then
      value = transfer(ior(transfer(a, 0_int64), transfer(b, 0_int64)), value)
    else if (a < b) then
      value = a
    else
      value = b
    end if
  end function minimum
  !> Preserve the assembly maximum, including both signs of zero.
  pure function maximum(a, b) result(value)
    real(real64), intent(in) :: a, b
    real(real64) :: value
    if (ieee_is_nan(a)) then
      value = a
    else if (ieee_is_nan(b)) then
      value = b
    else if (a == 0.0_real64 .and. b == 0.0_real64) then
      value = transfer(iand(transfer(a, 0_int64), transfer(b, 0_int64)), value)
    else if (a > b) then
      value = a
    else
      value = b
    end if
  end function maximum
end module srfsn_webal_mod
