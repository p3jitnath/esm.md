!> Complete normal-physics convective heat and moisture transport.
module convective_heat_moisture_mod
  use iso_c_binding, only: c_double, c_int, c_int64_t
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use yoephli, only: tephli
  use yophnc, only: tphnc
  use yoecumf, only: tecumf
  use yoephy, only: tephy
  use convection_leaf_contract_mod, only: require, real_matrix
  use convection_bidiagonal_mod, only: cubidiag
  use saturation_humidity_mod, only: ordered_minimum, ordered_maximum
  implicit none
  private
  public :: cudtdqn, cudtdqn_raw
  interface cudtdqn_raw
    module procedure cudtdqn
  end interface
contains
  !> Return latent heat in J/kg with the source convective phase fraction.
  function latent_heat(constants, thermal, t) result(answer)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    real(c_double), intent(in) :: t
    real(c_double) :: answer, alpha, ice
    alpha = ordered_minimum(thermal%rtwat, t)
    alpha = ordered_maximum(thermal%rticecu, alpha)
    alpha = alpha - thermal%rticecu
    alpha = alpha*thermal%rtwat_rticecu_r
    alpha = alpha*alpha
    alpha = ordered_minimum(1.0_c_double, alpha)
    ice = 1.0_c_double - alpha
    alpha = alpha*constants%rlvtt
    ice = ice*constants%rlstt
    answer = alpha + ice
  end function
  !> Preserve original heat/moisture tendencies and branch-specific diagnostic.
  !! Readonly providers precede all44 original arguments. Canonical native
  !! parameter records remain readonly. Layer arrays have first extent KLON
  !! and at least KLEV levels; face arrays at least KLEV+1, phase arrays
  !! two species. All views are contiguous and mutable owners are disjoint.
  !! Temperature is K, humidity kg/kg, pressure Pa, geopotential m2/s2,
  !! mass flux kg/(m2 s) and PTSPHY seconds. PTENT/PTENQ have K/s and
  !! kg/(kg s). PENTH preserves the original differing branch units.
  !! Caller admits the finite source domain, indices, implicit diagonals,
  !! normal physics and nearest-even/gradual floating environment.
  !! Raw entry preserves inactive bytes and changes no LDCUM flag.
  subroutine cudtdqn(constants, thermal, ydephli, ydphnc, ydecumf, ydephy, kidia, kfdia, klon, klev, ktopm2, &
             ktype, kctop, kcbot, kdtop, ldcum, lddraf, lscvflag, ptsphy, paph, pap, pgeoh, pgeo, pten, ptenh, pqen, pqenh, pqsen, &
  plglac, plude, pludeli, psnde, pmfu, pmfd, pmfus, pmfds, pmfuq, pmfdq, pmful, pdmfup, pdpmel, pmflxr, pmflxs, ptent, ptenq, penth)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    type(tephli), intent(in) :: ydephli
    type(tphnc), intent(in) :: ydphnc
    type(tecumf), intent(in) :: ydecumf
    type(tephy), intent(in) :: ydephy
    integer(c_int), intent(in) :: kidia, kfdia, klon, klev, ktopm2, ktype(:), kctop(:), kcbot(:), kdtop(:)
    logical, intent(inout) :: ldcum(:)
    logical, intent(in) :: lddraf(:), lscvflag(:)
    real(c_double),intent(in) :: ptsphy,paph(:,:),pap(:,:),pgeoh(:,:),pgeo(:,:),pten(:,:),ptenh(:,:),pqen(:,:),pqenh(:,:),pqsen(:,:)
 real(c_double), intent(in) :: plglac(:, :), pmfu(:, :), pmfd(:, :), pmfus(:, :), pmfds(:, :), pmfuq(:, :), pmfdq(:, :), pmful(:, :)
    real(c_double), intent(in) :: pdmfup(:, :), pdpmel(:, :), pmflxr(:, :), pmflxs(:, :)
    real(c_double), intent(inout) :: plude(:, :), pludeli(:, :, :), psnde(:, :, :), ptent(:, :), ptenq(:, :), penth(:, :)
    integer(c_int) :: jl, jk
    integer(c_int64_t) :: arena_bytes
    real(c_double), volatile :: inverse_dt, inverse_cp, remainder, integral_residual, advection_factor
    real(c_double) :: w0, w1, w2, w3, w4, w5, humidity_ratio, energy_ratio, half_energy, half_humidity
    real(c_double) :: original_latent,transport_latent,integral,total_heat,total_water,scale,weight,heat_advection,water_advection
    call require(.not. ydephli%lphylin)
    call require(klon >= 1 .and. klev >= 1 .and. klev < huge(klev))
    call require(ktopm2 >= 2 .and. ktopm2 <= klev + 1)
    call require(kidia >= 1 .and. kfdia >= kidia - 1 .and. kfdia <= klon)
    if (kidia > kfdia) return
    call require(is_contiguous(ldcum) .and. size(ldcum) >= klon .and. is_contiguous(lddraf) .and. size(lddraf) >= klon)
    call require(is_contiguous(lscvflag) .and. size(lscvflag) >= klon)
    call require(is_contiguous(ktype) .and. size(ktype) >= klon .and. is_contiguous(kctop) .and. size(kctop) >= klon)
    call require(is_contiguous(kdtop) .and. size(kdtop) >= klon)
    call real_matrix(paph, klon, klev + 1); call real_matrix(pap, klon, klev)
    call real_matrix(pgeoh, klon, klev + 1); call real_matrix(pgeo, klon, klev)
    call real_matrix(pten, klon, klev); call real_matrix(ptenh, klon, klev)
    call real_matrix(pqen, klon, klev); call real_matrix(pqenh, klon, klev); call real_matrix(pqsen, klon, klev)
    call real_matrix(plglac, klon, klev); call real_matrix(plude, klon, klev)
    call require(is_contiguous(pludeli) .and. size(pludeli, 1) == klon .and. size(pludeli, 2) == klev .and. size(pludeli, 3) >= 2)
    call require(is_contiguous(psnde) .and. size(psnde, 1) == klon .and. size(psnde, 2) == klev .and. size(psnde, 3) >= 2)
    call real_matrix(pmfu, klon, klev); call real_matrix(pmfd, klon, klev); call real_matrix(pmfus, klon, klev)
    call real_matrix(pmfds, klon, klev); call real_matrix(pmfuq, klon, klev); call real_matrix(pmfdq, klon, klev)
    call real_matrix(pmful, klon, klev); call real_matrix(pdmfup, klon, klev); call real_matrix(pdpmel, klon, klev)
    call real_matrix(pmflxr, klon, klev + 1); call real_matrix(pmflxs, klon, klev + 1)
    call real_matrix(ptent, klon, klev); call real_matrix(ptenq, klon, klev); call real_matrix(penth, klon, klev)
    arena_bytes = 60_c_int64_t*int(klon, c_int64_t)*int(klev, c_int64_t) + 8_c_int64_t*int(klon, c_int64_t) + 31_c_int64_t
    arena_bytes = iand(arena_bytes, -16_c_int64_t)
    call require(arena_bytes <= 1048576_c_int64_t)
    remainder = 1.0_c_double - ydecumf%rmfsoltq
    inverse_dt = 1.0_c_double/ptsphy
    inverse_cp = 1.0_c_double/constants%rcpd
    block
      real(c_double) :: flux_heat_up(klon, klev), flux_heat_down(klon, klev), flux_water_up(klon, klev), flux_water_down(klon, klev)
      real(c_double) :: gravity_dp(klon, klev), heat_source(klon, klev), water_source(klon, klev), energy_correction(klon)
      logical :: used(klon, klev)
      do jk = 1, klev
        do jl = kidia, kfdia
          penth(jl, jk) = 0.0_c_double
          if (ydephy%lepcld .or. ydphnc%lencld2 .or. ydphnc%lepcld2) cycle
          plude(jl, jk) = 0.0_c_double
          pludeli(jl, jk, 1) = 0.0_c_double; pludeli(jl, jk, 2) = 0.0_c_double
        end do
      end do
      do jk = 1, klev
        do jl = kidia, kfdia
          if (.not. ldcum(jl)) cycle
          w1 = paph(jl, jk + 1) - paph(jl, jk)
          gravity_dp(jl, jk) = constants%rg/w1
          flux_heat_up(jl, jk) = pmfus(jl, jk); flux_heat_down(jl, jk) = pmfds(jl, jk)
          flux_water_up(jl, jk) = pmfuq(jl, jk); flux_water_down(jl, jk) = pmfdq(jl, jk)
        end do
      end do
      if (ydecumf%rmfsoltq > 0.0_c_double) then
        do jk = ktopm2, klev
          do jl = kidia, kfdia
            if (.not. ldcum(jl)) cycle
            if (jk < kctop(jl) - 1) cycle
            w0 = pqenh(jl, jk) - pqen(jl, jk - 1)
            humidity_ratio = w0/pqsen(jl, jk)
            w3 = constants%rcpd*pten(jl, jk)
            w3 = w3 + pgeo(jl, jk)
            w0 = ptenh(jl, jk) - pten(jl, jk - 1)
            w0 = constants%rcpd*w0
            w0 = w0 + pgeoh(jl, jk); w0 = w0 - pgeo(jl, jk - 1)
            energy_ratio = w0/w3
            w1 = remainder*pten(jl, jk - 1)
            w0 = energy_ratio*pten(jl, jk)
            w0 = w1 + w0
            w0 = w0*constants%rcpd
            w0 = w0 + pgeo(jl, jk - 1)
            w4 = energy_ratio*pgeo(jl, jk)
            half_energy = w0 + w4
            w0 = remainder*pqen(jl, jk - 1)
            w1 = humidity_ratio*pqsen(jl, jk)
            half_humidity = w0 + w1
            w2 = pmfu(jl, jk)*half_energy
            flux_heat_up(jl, jk) = pmfus(jl, jk) - w2
            w2 = pmfu(jl, jk)*half_humidity
            flux_water_up(jl, jk) = pmfuq(jl, jk) - w2
            if (.not. lddraf(jl)) cycle
            if (jk < kdtop(jl)) cycle
            w2 = pmfd(jl, jk)*half_energy
            flux_heat_down(jl, jk) = pmfds(jl, jk) - w2
            w2 = pmfd(jl, jk)*half_humidity
            flux_water_down(jl, jk) = pmfdq(jl, jk) - w2
          end do
        end do
      end if
      do jl = kidia, kfdia
        integral = 0.0_c_double
        if (ydecumf%lmfenthcons) then
          do jk = ktopm2, klev
            original_latent = latent_heat(constants, thermal, pten(jl, jk))
            transport_latent = original_latent
            if (lscvflag(jl)) transport_latent = constants%rlvtt
            w0 = plglac(jl, jk) - pdpmel(jl, jk)
            w0 = constants%rlmlt*w0
            integral = integral + w0
            if (jk < klev) then
              w1 = pmful(jl, jk + 1) - pmful(jl, jk)
              w1 = transport_latent*w1
              integral = integral - w1
            else
              w0 = transport_latent*pmful(jl, jk)
              integral = integral + w0
            end if
            w0 = original_latent*pdmfup(jl, jk)
            integral = integral + w0
          end do
          w0 = constants%rlvtt*pmflxr(jl, klev + 1)
          w0 = integral - w0
          w1 = constants%rlstt*pmflxs(jl, klev + 1)
          integral_residual = w0 - w1
          if (abs(integral) > 0.1_c_double) then
            w1 = integral + 0.001_c_double
            integral = integral_residual/w1
            if (abs(integral) > 2.0_c_double) integral = 0.0_c_double
          else
            integral = 0.0_c_double
          end if
        end if
        energy_correction(jl) = integral
      end do
      do jk = ktopm2, klev
        do jl = kidia, kfdia
          if (.not. ldcum(jl)) cycle
          original_latent = latent_heat(constants, thermal, pten(jl, jk))
          transport_latent = original_latent
          if (ydecumf%lmfenthcons) then
            if (lscvflag(jl)) transport_latent = constants%rlvtt
          end if
          w3 = 1.0_c_double - energy_correction(jl)
          if (jk < klev) then
            w0 = plglac(jl, jk) - pdpmel(jl, jk)
            w0 = constants%rlmlt*w0
            w1 = pmful(jl, jk + 1) - pmful(jl, jk)
            w1 = transport_latent*w1
            w0 = w0 - w1
            w1 = original_latent*pdmfup(jl, jk)
            w0 = w0 + w1
            total_heat = w0*w3
            w0 = flux_heat_up(jl, jk + 1) - flux_heat_up(jl, jk)
            w0 = w0 + flux_heat_down(jl, jk + 1); w0 = w0 - flux_heat_down(jl, jk)
            total_heat = w0 + total_heat
            w0 = pludeli(jl, jk, 1) + psnde(jl, jk, 1); w0 = constants%rlvtt*w0
            total_heat = total_heat + w0
            w0 = pludeli(jl, jk, 2) + psnde(jl, jk, 2); w0 = constants%rlstt*w0
            total_heat = total_heat + w0
            w0 = gravity_dp(jl, jk)*inverse_cp
            total_heat = w0*total_heat
            w0 = flux_water_up(jl, jk + 1) - flux_water_up(jl, jk)
            w0 = w0 + flux_water_down(jl, jk + 1); w0 = w0 - flux_water_down(jl, jk)
            w0 = w0 + pmful(jl, jk + 1); w0 = w0 - pmful(jl, jk)
            w0 = w0 - plude(jl, jk); w0 = w0 - pdmfup(jl, jk)
            w0 = w0 - psnde(jl, jk, 1); w0 = w0 - psnde(jl, jk, 2)
            total_water = gravity_dp(jl, jk)*w0
          else
            w0 = pdpmel(jl, jk) - plglac(jl, jk)
            w0 = constants%rlmlt*w0
            w1 = transport_latent*pmful(jl, jk)
            w0 = w0 - w1
            w1 = original_latent*pdmfup(jl, jk)
            w0 = w0 - w1
            total_heat = w0*w3
            w0 = flux_heat_up(jl, jk) + flux_heat_down(jl, jk)
            total_heat = w0 + total_heat
            w0 = -gravity_dp(jl, jk); w0 = w0*inverse_cp
            total_heat = w0*total_heat
            w0 = flux_water_up(jl, jk) + flux_water_down(jl, jk)
            w1 = pmful(jl, jk) + pdmfup(jl, jk)
            w0 = w0 + w1
            w1 = -gravity_dp(jl, jk)
            total_water = w1*w0
          end if
          heat_source(jl, jk) = total_heat; water_source(jl, jk) = total_water
        end do
      end do
      if (ydecumf%rmfsoltq == 0.0_c_double) then
        do jk = ktopm2, klev
          do jl = kidia, kfdia
            if (.not. ldcum(jl)) cycle
            ptent(jl, jk) = ptent(jl, jk) + heat_source(jl, jk)
            penth(jl, jk) = heat_source(jl, jk)*constants%rcpd
            ptenq(jl, jk) = ptenq(jl, jk) + water_source(jl, jk)
          end do
        end do
        return
      end if
      flux_heat_up = 0.0_c_double; flux_heat_down = 1.0_c_double; used = .false.
      do jk = ktopm2, klev
        do jl = kidia, kfdia
          if (.not. ldcum(jl)) cycle
          if (jk < kctop(jl) - 1) cycle
          used(jl, jk) = .true.
          w0 = ydecumf%rmfsoltq*gravity_dp(jl, jk)
          scale = w0*ptsphy
          w0 = pmfu(jl, jk) + pmfd(jl, jk)
          w1 = -scale
          flux_heat_up(jl, jk) = w1*w0
          if (jk < klev) then
            w0 = pmfu(jl, jk + 1) + pmfd(jl, jk + 1)
            w0 = scale*w0
            flux_heat_down(jl, jk) = 1.0_c_double + w0
          end if
          w0 = ydecumf%rmfadvwdd*pmfd(jl, jk)
          w0 = pmfu(jl, jk) + w0
          w0 = constants%rg*w0
          w1 = pap(jl, jk) - pap(jl, jk - 1)
          w0 = w0/w1
          advection_factor = w0*ptsphy
          weight = 0.0_c_double
          if (ktype(jl) == 1) weight = ydecumf%rmfadvw
          w3 = advection_factor*weight
          w0 = pten(jl, jk - 1) - pten(jl, jk)
          w1 = pgeo(jl, jk - 1) - pgeo(jl, jk)
          w1 = inverse_cp*w1
          w0 = w0 + w1
          heat_advection = w3*w0
          w0 = pqen(jl, jk - 1) - pqen(jl, jk)
          water_advection = w3*w0
          w0 = ptent(jl, jk)*ydecumf%rmfsolrhs
          w0 = heat_source(jl, jk) + w0
          w0 = w0*ptsphy; w0 = w0 + pten(jl, jk)
          heat_source(jl, jk) = w0 - heat_advection
          w0 = ptenq(jl, jk)*ydecumf%rmfsolrhs
          w0 = water_source(jl, jk) + w0
          w0 = w0*ptsphy; w0 = w0 + pqen(jl, jk)
          water_source(jl, jk) = w0 - water_advection
        end do
      end do
  call cubidiag(constants, thermal, kidia, kfdia, klon, klev, kctop, used, flux_heat_up, flux_heat_down, heat_source, flux_water_up)
      call cubidiag(constants,thermal,kidia,kfdia,klon,klev,kctop,used,flux_heat_up,flux_heat_down,water_source,flux_water_down)
      do jk = ktopm2, klev
        do jl = kidia, kfdia
          if (.not. used(jl, jk)) cycle
          w0 = flux_water_up(jl, jk) - pten(jl, jk)
          w0 = w0*inverse_dt
          penth(jl, jk) = w0
          w2 = 1.0_c_double - ydecumf%rmfsolrhs
          w1 = ptent(jl, jk)*w2
          ptent(jl, jk) = w1 + w0
          w0 = flux_water_down(jl, jk) - pqen(jl, jk)
          w0 = w0*inverse_dt
          w1 = ptenq(jl, jk)*w2
          ptenq(jl, jk) = w1 + w0
        end do
      end do
    end block
  end subroutine
end module convective_heat_moisture_mod
