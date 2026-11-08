!> Complete convective flux finalisation, precipitation and evaporation.
module convection_final_fluxes_mod
  use iso_c_binding, only: c_double, c_int, c_int64_t
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use yoephli, only: tephli
  use yoecumf, only: tecumf
  use convection_leaf_contract_mod, only: require, real_matrix, real_vector
  use saturation_humidity_mod, only: ordered_minimum, numeric_maximum, public_exp
  use convective_energy_diagnostics_mod, only: energy_pow
  implicit none
  private
  public :: cuflxn, cuflxn_raw
  interface cuflxn_raw
    module procedure cuflxn
  end interface
  real(c_double), parameter :: land_humidity = transfer(int(z'3fe8000000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: deep_land_humidity = transfer(int(z'3fe6666666666666', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: deep_sea_humidity = transfer(int(z'3feb333333333333', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: one = transfer(int(z'3ff0000000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: downdraft_fraction = transfer(int(z'3fef5c28f5c28f5c', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: mass_tolerance = transfer(int(z'3cd203af9ee75616', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: wet_pressure_reference = transfer(int(z'40f4c08000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: wet_pressure_slope = transfer(int(z'3f7e8ff327aa68f5', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: wet_intercept = transfer(int(z'4094c53d70a3d70a', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: wet_temperature_reference = transfer(int(z'4071300000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: wet_temperature_slope = transfer(int(z'40445189374bc6a8', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: half = transfer(int(z'3fe0000000000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: area_humidity_floor = transfer(int(z'3fe999999999999a', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: area_humidity_scale = transfer(int(z'3f9999999999999a', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: shallow_area_factor = transfer(int(z'3fe3333340000000', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: precipitation_cutoff = transfer(int(z'3d719799812dea11', c_int64_t), 0.0_c_double)
  real(c_double), parameter :: evaporation_power = transfer(int(z'3fe27c84b5dcc63f', c_int64_t), 0.0_c_double)
contains
  !> Numeric minimum retains the finite operand beside a quiet NaN.
  pure function numeric_minimum(x, y) result(z)
    real(c_double), intent(in) :: x, y
    real(c_double) :: z
    integer(c_int64_t) :: bx, by
    logical :: nx, ny
    bx = iand(transfer(x, 0_c_int64_t), int(z'7fffffffffffffff', c_int64_t))
    by = iand(transfer(y, 0_c_int64_t), int(z'7fffffffffffffff', c_int64_t))
    nx = bx > int(z'7ff0000000000000', c_int64_t)
    ny = by > int(z'7ff0000000000000', c_int64_t)
    if (nx) then
      if (ny) then
        z = x
      else
        z = y
      end if
    elseif (ny) then
      z = x
    else
      z = ordered_minimum(x, y)
    end if
  end function
  !> Return the complete numeric mixed-phase fraction for normal physics.
  function phase_fraction(thermal, t) result(alpha)
    type(thermal_parameter_record), intent(in) :: thermal
    real(c_double), intent(in) :: t
    real(c_double) :: alpha
    alpha = numeric_minimum(thermal%rtwat, t)
    alpha = numeric_maximum(thermal%rticecu, alpha)
    alpha = alpha - thermal%rticecu
    alpha = alpha*thermal%rtwat_rticecu_r
    alpha = alpha*alpha
    alpha = numeric_minimum(one, alpha)
  end function
  !> Return latent heat in J/kg with separate liquid and ice products.
  function latent_heat(constants, thermal, t) result(answer)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    real(c_double), intent(in) :: t
    real(c_double) :: answer, alpha, w0, w1
    alpha = phase_fraction(thermal, t)
    w0 = alpha*constants%rlvtt
    w1 = one - alpha
    w1 = w1*constants%rlstt
    answer = w0 + w1
  end function
  !> Return the ordered convective saturation pressure, in Pa.
  function saturation_pressure(constants, thermal, t) result(answer)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    real(c_double), intent(in) :: t
    real(c_double) :: answer, alpha, water, solid, w0, w1, w2
    alpha = phase_fraction(thermal, t)
    w0 = t - constants%rtt; w0 = thermal%r3les*w0
    w1 = t - thermal%r4les; w0 = w0/w1
    water = public_exp(w0)
    w0 = t - constants%rtt; w0 = thermal%r3ies*w0
    w1 = t - thermal%r4ies; w0 = w0/w1
    solid = public_exp(w0)
    w2 = alpha*water
    w1 = one - alpha; w0 = w1*solid
    w0 = w2 + w0
    answer = thermal%r2es*w0
  end function
  !> Admit phase planes with the source's exact species stride.
  subroutine phase_matrix(x, p, l)
    real(c_double), intent(in) :: x(:, :, :)
    integer(c_int), intent(in) :: p, l
    call require(is_contiguous(x) .and. size(x, 1) == p .and. size(x, 2) == l .and. size(x, 3) >= 2)
  end subroutine
  !> Complete every selected source flux pass without changing unused bytes.
  !! Explicit readonly providers precede all43 original arguments. Native
  !! TEPHLI/TECUMF remain readonly. Layer arrays have first extent KLON,
  !! at least KLEV levels; face arrays at least KLEV+1. Phase arrays have
  !! exact(KLON,KLEV) leading dimensions and at least two components.
  !! All views are contiguous; mutable owners are disjoint. Pressure uses
  !! Pa, temperature K, humidity kg/kg, mass/precipitation kg/(m2 s),
  !! geopotential m2/s2 and PTSPHY seconds. Raw caller admits the retained
  !! finite normal-physics domain, valid indices and floating environment.
  !! LMFDSNOW/LMFWETB/LMFGLAC keep both branches. The scalar KTOPM2 is
  !! always set to2. Source boundary clears include every column even for
  !! empty selected ranges. PRAIN remains the original pre-evaporation
  !! diagnostic. Compiler-owned native work vectors replace the old calloc.
  subroutine cuflxn(constants, thermal, ydephli, ydecumf, kidia, kfdia, klon, klev, ptsphy, pten, pqen, pqsen, ptenh, pqenh, &
              paph, pap, pgeoh, ldland, ldcum, kcbot, kctop, kdtop, ktopm2, ktype, lddraf, pmfu, pmfd, pmfus, pmfds, pmfuq, pmfdq, &
              pmful, plude, pludeli, plrain, psnde, pdmfup, pdmfdp, pdpmel, plglac, pmflxr, pmflxs, prain, pmfude_rate, pmfdde_rate)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    type(tephli), intent(in) :: ydephli
    type(tecumf), intent(in) :: ydecumf
    integer(c_int), intent(in) :: kidia, kfdia, klon, klev, kcbot(:), kctop(:), kdtop(:)
    integer(c_int), intent(inout) :: ktopm2, ktype(:)
    logical, intent(in) :: ldland(:), ldcum(:)
    logical, intent(inout) :: lddraf(:)
    real(c_double), intent(in) :: ptsphy, pten(:, :), pqen(:, :), ptenh(:, :), pqenh(:, :), paph(:, :), pap(:, :), pgeoh(:, :)
    real(c_double), intent(in) :: plrain(:, :), pmfude_rate(:, :)
    real(c_double), intent(inout) :: pqsen(:, :), pmfu(:, :), pmfd(:, :), pmfus(:, :), pmfds(:, :), pmfuq(:, :), pmfdq(:, :)
    real(c_double),intent(inout) :: pmful(:,:),plude(:,:),pludeli(:,:,:),psnde(:,:,:),pdmfup(:,:),pdmfdp(:,:),pdpmel(:,:)
    real(c_double), intent(inout) :: plglac(:, :), pmflxr(:, :), pmflxs(:, :), prain(:), pmfdde_rate(:, :)
    integer(c_int) :: jl, jk, base, top, next, stop_level
    real(c_double), volatile :: melting_scale, mass_scale, wet_switch, glaciation_remainder
    real(c_double) :: w0, w1, w2, w3, w4, w5, environment_energy, environment_q, fraction, latent, wet_t, cooled_t
    real(c_double) :: melt_capacity, alpha, total_source, liquid_source, ice_source, liquid_detrain, ice_detrain
    real(c_double) :: rain_next, snow_next, total_next, total_incoming, power_value, remaining, evaporation, inverse_incoming
    call require(.not. ydephli%lphylin)
    call require(klon >= 1 .and. klon <= 2048 .and. klev >= 1 .and. klev <= 512)
    call require(kidia >= 1 .and. kfdia >= kidia - 1 .and. kfdia <= klon)
    call require(is_contiguous(ldland) .and. size(ldland) >= klon .and. is_contiguous(ldcum) .and. size(ldcum) >= klon)
    call require(is_contiguous(lddraf) .and. size(lddraf) >= klon .and. is_contiguous(ktype) .and. size(ktype) >= klon)
    call require(is_contiguous(kcbot) .and. size(kcbot) >= klon .and. is_contiguous(kctop) .and. size(kctop) >= klon)
    call require(is_contiguous(kdtop) .and. size(kdtop) >= klon)
    call real_matrix(pten, klon, klev); call real_matrix(pqen, klon, klev); call real_matrix(pqsen, klon, klev)
    call real_matrix(ptenh, klon, klev); call real_matrix(pqenh, klon, klev)
    call real_matrix(paph, klon, klev + 1); call real_matrix(pap, klon, klev); call real_matrix(pgeoh, klon, klev + 1)
    call real_matrix(pmfu, klon, klev); call real_matrix(pmfd, klon, klev); call real_matrix(pmfus, klon, klev)
    call real_matrix(pmfds, klon, klev); call real_matrix(pmfuq, klon, klev); call real_matrix(pmfdq, klon, klev)
    call real_matrix(pmful, klon, klev); call real_matrix(plude, klon, klev); call phase_matrix(pludeli, klon, klev)
    call real_matrix(plrain, klon, klev); call phase_matrix(psnde, klon, klev)
    call real_matrix(pdmfup, klon, klev); call real_matrix(pdmfdp, klon, klev); call real_matrix(pdpmel, klon, klev)
    call real_matrix(plglac, klon, klev); call real_matrix(pmflxr, klon, klev + 1); call real_matrix(pmflxs, klon, klev + 1)
    call real_vector(prain, klon); call real_matrix(pmfude_rate, klon, klev); call real_matrix(pmfdde_rate, klon, klev)
    do jl = kidia, kfdia
      if (.not. ldcum(jl)) cycle
      call require(kcbot(jl) >= 1 .and. kcbot(jl) < klev .and. kctop(jl) >= 1 .and. kctop(jl) <= klev)
      call require(kdtop(jl) >= 0 .and. kdtop(jl) <= klev + 1)
      if (kdtop(jl) == klev + 1) call require(.not. lddraf(jl))
    end do
    w0 = constants%rlmlt*constants%rg
    w0 = w0*ydecumf%rtaumel
    melting_scale = constants%rcpd/w0
    w0 = constants%rg*ptsphy
    mass_scale = ydecumf%rmfcfl/w0
    wet_switch = 0.0_c_double
    if (ydecumf%lmfwetb) wet_switch = one
    glaciation_remainder = one
    if (ydecumf%lmfglac) glaciation_remainder = 0.0_c_double
    block
      real(c_double) :: humidity_limit(klon), downdraft_scale(klon), cloud_area(klon)
      integer(c_int) :: termination(klon)
      do jl = kidia, kfdia
        prain(jl) = 0.0_c_double
        if (.not. ldcum(jl)) then
          lddraf(jl) = .false.; ktype(jl) = 0
        elseif (kdtop(jl) < kctop(jl)) then
          lddraf(jl) = .false.
        end if
        termination(jl) = klev
        if (ldland(jl)) then
          humidity_limit(jl) = land_humidity
          if (ktype(jl) == 1) humidity_limit(jl) = deep_land_humidity
        else
          humidity_limit(jl) = ydecumf%rhebc
          if (ktype(jl) == 1) humidity_limit(jl) = deep_sea_humidity
        end if
      end do
      ktopm2 = 2_c_int
      do jk = 2, klev
        do jl = kidia, kfdia
          pmflxr(jl, jk) = 0.0_c_double; pmflxs(jl, jk) = 0.0_c_double
          pdpmel(jl, jk) = 0.0_c_double
          psnde(jl, jk, 1) = 0.0_c_double; psnde(jl, jk, 2) = 0.0_c_double
          if (ldcum(jl)) then
            if (jk >= kctop(jl)) then
              w0 = constants%rcpd*ptenh(jl, jk)
              environment_energy = w0 + pgeoh(jl, jk)
              w1 = pmfu(jl, jk)*environment_energy
              pmfus(jl, jk) = pmfus(jl, jk) - w1
              environment_q = pqenh(jl, jk)
              w1 = pmfu(jl, jk)*environment_q
              pmfuq(jl, jk) = pmfuq(jl, jk) - w1
              plglac(jl, jk) = pmfu(jl, jk)*plglac(jl, jk)
              if (lddraf(jl)) then
                if (jk >= kdtop(jl)) then
                  w1 = pmfd(jl, jk)*environment_energy
                  pmfds(jl, jk) = pmfds(jl, jk) - w1
                  w1 = pmfd(jl, jk)*environment_q
                  pmfdq(jl, jk) = pmfdq(jl, jk) - w1
                  if (pmfd(jl, jk) < 0.0_c_double) then
                    next = jk + 1; if (jk == klev) next = jk
                    if (pmfd(jl, next) == 0.0_c_double) termination(jl) = jk
                  end if
                  cycle
                end if
              end if
              pmfd(jl, jk) = 0.0_c_double; pmfds(jl, jk) = 0.0_c_double; pmfdq(jl, jk) = 0.0_c_double
              pdmfdp(jl, jk - 1) = 0.0_c_double
              cycle
            end if
          end if
          pmfu(jl, jk) = 0.0_c_double; pmfd(jl, jk) = 0.0_c_double
          pmfus(jl, jk) = 0.0_c_double; pmfds(jl, jk) = 0.0_c_double
          pmfuq(jl, jk) = 0.0_c_double; pmfdq(jl, jk) = 0.0_c_double
          pmful(jl, jk) = 0.0_c_double; plglac(jl, jk) = 0.0_c_double
          pdmfup(jl, jk - 1) = 0.0_c_double; pdmfdp(jl, jk - 1) = 0.0_c_double
          plude(jl, jk - 1) = 0.0_c_double
          pludeli(jl, jk - 1, 1) = 0.0_c_double; pludeli(jl, jk - 1, 2) = 0.0_c_double
        end do
      end do
      do jl = 1, klon
        pmflxr(jl, 1) = 0.0_c_double; pmflxr(jl, klev + 1) = 0.0_c_double
        pmflxs(jl, 1) = 0.0_c_double; pmflxs(jl, klev + 1) = 0.0_c_double
        psnde(jl, 1, 1) = 0.0_c_double; psnde(jl, 1, 2) = 0.0_c_double
      end do
      do jl = kidia, kfdia
        if (.not. ldcum(jl)) cycle
        base = kcbot(jl)
        w0 = paph(jl, klev + 1)
        w1 = w0 - paph(jl, base + 1); w2 = w0 - paph(jl, base)
        fraction = w1/w2
        if (ktype(jl) == 3) fraction = fraction*fraction
        pmfu(jl, base + 1) = pmfu(jl, base)*fraction
        latent = latent_heat(constants, thermal, ptenh(jl, base))
        w0 = latent*pmful(jl, base)
        w2 = pmfus(jl, base) - w0
        pmfus(jl, base + 1) = w2*fraction
        w2 = pmfuq(jl, base) + pmful(jl, base)
        pmfuq(jl, base + 1) = w2*fraction
        pmful(jl, base + 1) = 0.0_c_double
      end do
      do jk = 2, klev
        do jl = kidia, kfdia
          if (ldcum(jl)) then
            base = kcbot(jl) + 1
            if (jk > base) then
              w0 = paph(jl, klev + 1)
              w1 = w0 - paph(jl, jk); w2 = w0 - paph(jl, base)
              fraction = w1/w2
              if (ktype(jl) == 3) fraction = fraction*fraction
              pmfu(jl, jk) = pmfu(jl, base)*fraction
              pmfus(jl, jk) = pmfus(jl, base)*fraction
              pmfuq(jl, jk) = pmfuq(jl, base)*fraction
              pmful(jl, jk) = 0.0_c_double
            end if
          end if
          if (.not. lddraf(jl)) cycle
          stop_level = termination(jl)
          if (jk <= stop_level .or. stop_level >= klev) cycle
          if (stop_level == kcbot(jl) + 1) then
            w0 = paph(jl, klev + 1)
            w1 = w0 - paph(jl, jk); w2 = w0 - paph(jl, stop_level)
            fraction = w1/w2
            if (ktype(jl) == 3) fraction = fraction*fraction
            pmfd(jl, jk) = pmfd(jl, stop_level)*fraction
            pmfds(jl, jk) = pmfds(jl, stop_level)*fraction
            pmfdq(jl, jk) = pmfdq(jl, stop_level)*fraction
          elseif (jk /= stop_level + 1) then
            cycle
          end if
          w0 = pmfd(jl, jk - 1) - pmfd(jl, jk)
          pmfdde_rate(jl, jk) = -w0
        end do
      end do
      downdraft_scale = one
      do jk = 2, klev
        do jl = kidia, kfdia
          if (.not. lddraf(jl)) cycle
          if (jk < kdtop(jl) - 1) cycle
          w0 = abs(pmfu(jl, jk)); w0 = w0*downdraft_fraction
          w3 = pmfd(jl, jk) + w0; w3 = w3 + mass_tolerance
          if (w3 >= 0.0_c_double) cycle
          w0 = -w0; w0 = w0/pmfd(jl, jk)
          downdraft_scale(jl) = numeric_minimum(downdraft_scale(jl), w0)
        end do
      end do
      do jk = 2, klev
        do jl = kidia, kfdia
          fraction = downdraft_scale(jl)
          if (fraction >= one) cycle
          if (jk < kdtop(jl) - 1) cycle
          pmfd(jl, jk) = pmfd(jl, jk)*fraction
          pmfds(jl, jk) = pmfds(jl, jk)*fraction
          pmfdq(jl, jk) = pmfdq(jl, jk)*fraction
          pmfdde_rate(jl, jk) = pmfdde_rate(jl, jk)*fraction
          pdmfdp(jl, jk) = pdmfdp(jl, jk)*fraction
        end do
      end do
      do jk = 2, klev
        do jl = kidia, kfdia
          if (.not. ldcum(jl)) cycle
          if (jk < kctop(jl) - 1) cycle
          prain(jl) = prain(jl) + pdmfup(jl, jk)
          wet_t = pten(jl, jk)
          w1 = pqsen(jl, jk) - pqen(jl, jk)
          w1 = numeric_maximum(0.0_c_double, w1)
          w2 = pap(jl, jk) - wet_pressure_reference
          w2 = wet_pressure_slope*w2; w2 = wet_intercept + w2
          w3 = wet_t - wet_temperature_reference
          w3 = wet_temperature_slope*w3
          w2 = w2 - w3; w1 = w1*w2; w1 = wet_t - w1
          w1 = w1*wet_switch
          w2 = one - wet_switch; w0 = w2*wet_t
          wet_t = w1 + w0
          if (pmflxs(jl, jk) > 0.0_c_double) then
            if (wet_t > constants%rtt) then
              w3 = wet_t - constants%rtt; w3 = half*w3; w3 = one + w3
              w3 = melting_scale*w3
              w4 = paph(jl, jk + 1) - paph(jl, jk)
              melt_capacity = w3*w4
              w4 = wet_t - constants%rtt; w4 = melt_capacity*w4
              pdpmel(jl, jk) = numeric_minimum(pmflxs(jl, jk), w4)
              w1 = pdpmel(jl, jk)/melt_capacity
              cooled_t = wet_t - w1
              w0 = saturation_pressure(constants, thermal, cooled_t)
              pqsen(jl, jk) = w0/pap(jl, jk)
            end if
          end if
          alpha = phase_fraction(thermal, wet_t)
          if (pten(jl, jk) <= constants%rtt) then
            if (alpha > 0.0_c_double) then
              w1 = glaciation_remainder*alpha; w1 = w1*pdmfup(jl, jk)
              w3 = plglac(jl, jk) + w1
              w2 = alpha*pdmfdp(jl, jk)
              plglac(jl, jk) = w3 + w2
              alpha = 0.0_c_double
            end if
          end if
          if (ydecumf%lmfdsnow) then
            if (jk <= kcbot(jl)) then
              w0 = plrain(jl, jk + 1)*pmfude_rate(jl, jk)
              liquid_detrain = w0*alpha
              w3 = one - alpha; ice_detrain = w0*w3
              w4 = pdmfup(jl, jk) + pdmfdp(jl, jk)
              w1 = alpha*w4
              liquid_detrain = numeric_minimum(liquid_detrain, w1)
              w3 = w3*w4; w3 = w3 - pdpmel(jl, jk)
              ice_detrain = numeric_minimum(ice_detrain, w3)
              psnde(jl, jk, 1) = numeric_maximum(liquid_detrain, 0.0_c_double)
              psnde(jl, jk, 2) = numeric_maximum(ice_detrain, 0.0_c_double)
            end if
          end if
          total_source = pdmfup(jl, jk) + pdmfdp(jl, jk)
          liquid_source = alpha*total_source
          rain_next = pmflxr(jl, jk) + liquid_source
          rain_next = rain_next + pdpmel(jl, jk); rain_next = rain_next - psnde(jl, jk, 1)
          pmflxr(jl, jk + 1) = rain_next
          w2 = one - alpha; ice_source = w2*total_source
          snow_next = pmflxs(jl, jk) + ice_source
          snow_next = snow_next - pdpmel(jl, jk); snow_next = snow_next - psnde(jl, jk, 2)
          pmflxs(jl, jk + 1) = snow_next
          total_next = rain_next + snow_next
          if (total_next < 0.0_c_double) then
            w0 = pmflxr(jl, jk) + pmflxs(jl, jk)
            w0 = w0 + pdmfup(jl, jk); pdmfdp(jl, jk) = -w0
            pmflxr(jl, jk + 1) = 0.0_c_double; pmflxs(jl, jk + 1) = 0.0_c_double; pdpmel(jl, jk) = 0.0_c_double
          elseif (rain_next < 0.0_c_double) then
            pmflxs(jl, jk + 1) = snow_next + rain_next; pmflxr(jl, jk + 1) = 0.0_c_double
          elseif (snow_next < 0.0_c_double) then
            pmflxr(jl, jk + 1) = rain_next + snow_next; pmflxs(jl, jk + 1) = 0.0_c_double
          end if
        end do
      end do
      ! The production route has no verification snapshot call.
      do jl = kidia, kfdia
        if (ktype(jl) >= 2) then
          base = kcbot(jl); top = kctop(jl)
          w0 = pqen(jl, base)/pqsen(jl, base)
          w2 = pqen(jl, top)/pqsen(jl, top)
          w0 = w0 + w2; w0 = half*w0
          w0 = numeric_maximum(area_humidity_floor, w0)
          w0 = w0 - area_humidity_floor; w0 = w0/area_humidity_scale
          w0 = one + w0
          cloud_area(jl) = ydecumf%rcucov*w0
        else
          cloud_area(jl) = ydecumf%rcucov*shallow_area_factor
        end if
      end do
      do jk = 2, klev
        do jl = kidia, kfdia
          if (.not. ldcum(jl)) cycle
          if (jk < kcbot(jl)) cycle
          total_incoming = pmflxr(jl, jk) + pmflxs(jl, jk)
          if (total_incoming <= precipitation_cutoff) then
            pmflxr(jl, jk + 1) = 0.0_c_double; pmflxs(jl, jk + 1) = 0.0_c_double
            pdmfdp(jl, jk) = 0.0_c_double; pdpmel(jl, jk) = 0.0_c_double
            cycle
          end if
          w0 = paph(jl, jk)/paph(jl, klev + 1)
          w0 = sqrt(w0); w0 = w0/ydecumf%rcvrfactor
          w0 = w0*total_incoming; w0 = w0/cloud_area(jl)
          power_value = energy_pow(w0, evaporation_power)
          w0 = pqsen(jl, jk) - pqen(jl, jk)
          w0 = numeric_maximum(0.0_c_double, w0)
          w0 = ydecumf%rcpecons*w0
          w0 = w0*cloud_area(jl); w0 = w0*power_value
          w2 = paph(jl, jk + 1) - paph(jl, jk)
          w0 = w0*w2
          w4 = total_incoming - w0
          w0 = humidity_limit(jl)*pqsen(jl, jk); w0 = w0 - pqen(jl, jk)
          w0 = numeric_maximum(0.0_c_double, w0)
          w0 = cloud_area(jl)*w0; w0 = w0*mass_scale; w0 = w0*w2
          w0 = total_incoming - w0
          w0 = numeric_maximum(w4, w0); w0 = numeric_maximum(w0, 0.0_c_double)
          w0 = w0 - total_incoming
          evaporation = numeric_minimum(0.0_c_double, w0)
          alpha = phase_fraction(thermal, pten(jl, jk))
          if (pten(jl, jk) < constants%rtt) alpha = 0.0_c_double
          liquid_source = alpha*pdmfdp(jl, jk)
          w0 = one - alpha; ice_source = w0*pdmfdp(jl, jk)
          w0 = pmflxr(jl, jk) + pmflxs(jl, jk)
          w0 = numeric_maximum(precipitation_cutoff, w0)
          inverse_incoming = one/w0
          rain_next = pmflxr(jl, jk) + liquid_source
          rain_next = rain_next + pdpmel(jl, jk)
          w4 = evaporation*pmflxr(jl, jk); w4 = w4*inverse_incoming
          rain_next = rain_next + w4
          pmflxr(jl, jk + 1) = rain_next
          snow_next = pmflxs(jl, jk) + ice_source; snow_next = snow_next - pdpmel(jl, jk)
          w5 = evaporation*pmflxs(jl, jk); w5 = w5*inverse_incoming
          snow_next = snow_next + w5
          pmflxs(jl, jk + 1) = snow_next
          pdmfup(jl, jk) = pdmfup(jl, jk) + evaporation
          total_next = rain_next + snow_next
          if (total_next < 0.0_c_double) then
            pdmfup(jl, jk) = pdmfup(jl, jk) - total_next
            pmflxr(jl, jk + 1) = 0.0_c_double; pmflxs(jl, jk + 1) = 0.0_c_double; pdpmel(jl, jk) = 0.0_c_double
          elseif (rain_next < 0.0_c_double) then
            pmflxs(jl, jk + 1) = snow_next + rain_next; pmflxr(jl, jk + 1) = 0.0_c_double
          elseif (snow_next < 0.0_c_double) then
            pmflxr(jl, jk + 1) = rain_next + snow_next; pmflxs(jl, jk + 1) = 0.0_c_double
          end if
        end do
      end do
    end block
  end subroutine
end module convection_final_fluxes_mod
