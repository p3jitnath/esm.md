!> Complete deterministic convective wind transport and implicit solve.
module convection_wind_transport_mod
  use iso_c_binding, only: c_double, c_int, c_int64_t
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use convection_leaf_contract_mod, only: require, real_matrix, real_vector
  use yoecumf, only: tecumf
  use spp_mod, only: tspp_config
  use convection_bidiagonal_mod, only: cubidiag
  implicit none
  private
  public :: cududv, cududv_raw
  interface cududv_raw
    module procedure cududv
  end interface
contains
  !> Return one ordered plume momentum flux in kg/(m s2).
  pure function momentum_flux(mass, plume, environment, remainder) result(flux)
    real(c_double), intent(in) :: mass, plume, environment, remainder
    real(c_double) :: flux, work
    work = remainder*environment
    work = plume - work
    flux = mass*work
  end function
  !> Change only admitted convective wind tendencies, in m/s2.
  !! Providers precede the27 original arguments in unchanged order. All
  !! layer arrays have first extent KLON and at least KLEV levels; PAPH has
  !! at least KLEV+1. Native TSPP_CONFIG must have LSPP=false.
  !! KTOPM2 is2:KLEV+1; LDCUM selects columns. The caller admits positive
  !! pressure differences, finite source arithmetic and disjoint contiguous
  !! output owners. Gravity is m/s2, winds m/s, pressure Pa, PTSPHY seconds.
  !! Caller establishes the FP environment. Raw arrays retain extra tails.
subroutine cududv(constants, thermal, ydecumf, ydspp_config, kidia, kfdia, klon, klev, ktopm2, ktype, kcbot, kctop, ldcum, ptsphy, &
                    paph, pap, puen, pven, pmfu, pmfd, pmfuo, pmfdo, puu, pud, pvu, pvd, pgp2dspp, ptenu, ptenv)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    type(tecumf), intent(in) :: ydecumf
    type(tspp_config), intent(in) :: ydspp_config
    integer(c_int), intent(in) :: kidia, kfdia, klon, klev, ktopm2, ktype(:), kcbot(:), kctop(:)
    logical, intent(in) :: ldcum(:)
    real(c_double), intent(in) :: ptsphy, paph(:, :), pap(:, :), puen(:, :), pven(:, :), pmfu(:, :), pmfd(:, :)
    real(c_double), intent(in) :: pmfuo(:, :), pmfdo(:, :), puu(:, :), pud(:, :), pvu(:, :), pvd(:, :), pgp2dspp(:, :)
    real(c_double), intent(inout) :: ptenu(:, :), ptenv(:, :)
    integer(c_int) :: jl, jk, base
    integer(c_int64_t) :: arena_bytes
    real(c_double) :: remainder, inverse_time, w0, w1, w2, scale, weight, correction_u, correction_v
    real(c_double), volatile :: advection_factor
    call require(.not. ydspp_config%lspp)
    call require(klon > 0 .and. klev >= 1 .and. ktopm2 >= 2 .and. int(ktopm2, c_int64_t) <= int(klev, c_int64_t) + 1)
    call require(kidia >= 1 .and. kfdia >= kidia - 1 .and. kfdia <= klon)
    if (kidia > kfdia .or. ktopm2 > klev) return
    call require(is_contiguous(ldcum) .and. size(ldcum) >= klon)
    call require(is_contiguous(ktype) .and. size(ktype) >= klon .and. is_contiguous(kcbot) .and. size(kcbot) >= klon)
    call require(is_contiguous(kctop) .and. size(kctop) >= klon)
    call real_matrix(paph, klon, klev + 1); call real_matrix(pap, klon, klev)
    call real_matrix(puen, klon, klev); call real_matrix(pven, klon, klev)
    call real_matrix(pmfu, klon, klev); call real_matrix(pmfd, klon, klev)
    call real_matrix(pmfuo, klon, klev); call real_matrix(pmfdo, klon, klev)
    call real_matrix(puu, klon, klev); call real_matrix(pud, klon, klev); call real_matrix(pvu, klon, klev); call real_matrix(pvd, klon, klev)
    call real_matrix(ptenu, klon, klev); call real_matrix(ptenv, klon, klev)
    arena_bytes = iand(60_c_int64_t*int(klon, c_int64_t)*int(klev, c_int64_t) + 31_c_int64_t, -16_c_int64_t)
    call require(arena_bytes <= 1048576_c_int64_t)
    remainder = 1.0_c_double - ydecumf%rmfsoluv
    inverse_time = 1.0_c_double/ptsphy
    block
      ! Four flux arrays later become lower, two solutions and diagonal.
      real(c_double) :: up_u(klon, klev), up_v(klon, klev), down_u(klon, klev), down_v(klon, klev)
      real(c_double) :: force_u(klon, klev), force_v(klon, klev), gravity_dp(klon, klev)
      logical :: used(klon, klev)
      do jk = 1, klev
        do jl = kidia, kfdia
          if (.not. ldcum(jl)) cycle
          w0 = paph(jl, jk + 1) - paph(jl, jk)
          gravity_dp(jl, jk) = constants%rg/w0
        end do
      end do
      do jk = ktopm2, klev
        do jl = kidia, kfdia
          if (.not. ldcum(jl)) cycle
          up_u(jl, jk) = momentum_flux(pmfu(jl, jk), puu(jl, jk), puen(jl, jk - 1), remainder)
          up_v(jl, jk) = momentum_flux(pmfu(jl, jk), pvu(jl, jk), pven(jl, jk - 1), remainder)
          down_u(jl, jk) = momentum_flux(pmfd(jl, jk), pud(jl, jk), puen(jl, jk - 1), remainder)
          down_v(jl, jk) = momentum_flux(pmfd(jl, jk), pvd(jl, jk), pven(jl, jk - 1), remainder)
        end do
      end do
      if (ydecumf%rmfsoluv == 0.0_c_double) then
        do jk = ktopm2, klev
          do jl = kidia, kfdia
            if (.not. ldcum(jl)) cycle
            base = kcbot(jl)
            if (jk <= base) cycle
            w0 = paph(jl, klev + 1)
            w1 = w0 - paph(jl, jk)
            w2 = w0 - paph(jl, base)
            w0 = w1/w2
            if (ktype(jl) == 3) w0 = w0*w0
            up_u(jl, jk) = up_u(jl, base)*w0
            up_v(jl, jk) = up_v(jl, base)*w0
            down_u(jl, jk) = down_u(jl, base)*w0
            down_v(jl, jk) = down_v(jl, base)*w0
          end do
        end do
      end if
      do jk = ktopm2, klev
        do jl = kidia, kfdia
          if (.not. ldcum(jl)) cycle
          w0 = gravity_dp(jl, jk)
          if (jk < klev) then
            w1 = up_u(jl, jk + 1) - up_u(jl, jk)
            w1 = w1 + down_u(jl, jk + 1); w1 = w1 - down_u(jl, jk)
            force_u(jl, jk) = w0*w1
            w1 = up_v(jl, jk + 1) - up_v(jl, jk)
            w1 = w1 + down_v(jl, jk + 1); w1 = w1 - down_v(jl, jk)
            force_v(jl, jk) = w0*w1
          else
            w0 = -w0
            w1 = up_u(jl, jk) + down_u(jl, jk); force_u(jl, jk) = w0*w1
            w1 = up_v(jl, jk) + down_v(jl, jk); force_v(jl, jk) = w0*w1
          end if
        end do
      end do
      if (ydecumf%rmfsoluv == 0.0_c_double) then
        do jk = ktopm2, klev
          do jl = kidia, kfdia
            if (.not. ldcum(jl)) cycle
            ptenu(jl, jk) = ptenu(jl, jk) + force_u(jl, jk)
            ptenv(jl, jk) = ptenv(jl, jk) + force_v(jl, jk)
          end do
        end do
        return
      end if
      up_u = 0.0_c_double; down_v = 1.0_c_double; used = .false.
      do jk = ktopm2, klev
        do jl = kidia, kfdia
          if (.not. ldcum(jl)) cycle
          if (jk + 1 < kctop(jl)) cycle
          used(jl, jk) = .true.
          scale = ydecumf%rmfsoluv*gravity_dp(jl, jk)
          scale = scale*ptsphy
          w1 = pmfu(jl, jk) + pmfd(jl, jk)
          w2 = -scale
          up_u(jl, jk) = w2*w1
          if (jk < klev) then
            w1 = pmfu(jl, jk + 1) + pmfd(jl, jk + 1)
            w1 = scale*w1
            down_v(jl, jk) = 1.0_c_double + w1
          end if
          w0 = ydecumf%rmfadvwdd*pmfdo(jl, jk)
          w0 = pmfuo(jl, jk) + w0
          w0 = constants%rg*w0
          w1 = pap(jl, jk) - pap(jl, jk - 1)
          w0 = w0/w1
          advection_factor = w0*ptsphy
          weight = 0.0_c_double
          if (ktype(jl) == 1) weight = ydecumf%rmfadvw
          w0 = advection_factor*weight
          w1 = puen(jl, jk - 1) - puen(jl, jk); correction_u = w0*w1
          w1 = pven(jl, jk - 1) - pven(jl, jk); correction_v = w0*w1
          w1 = ptenu(jl, jk)*ydecumf%rmfsolrhs
          w0 = force_u(jl, jk) + w1
          w0 = w0*ptsphy; w0 = w0 + puen(jl, jk)
          force_u(jl, jk) = w0 - correction_u
          w1 = ptenv(jl, jk)*ydecumf%rmfsolrhs
          w0 = force_v(jl, jk) + w1
          w0 = w0*ptsphy; w0 = w0 + pven(jl, jk)
          force_v(jl, jk) = w0 - correction_v
        end do
      end do
      call cubidiag(constants, thermal, kidia, kfdia, klon, klev, kctop, used, up_u, down_v, force_u, up_v)
      call cubidiag(constants, thermal, kidia, kfdia, klon, klev, kctop, used, up_u, down_v, force_v, down_u)
      remainder = 1.0_c_double - ydecumf%rmfsolrhs
      do jk = ktopm2, klev
        do jl = kidia, kfdia
          if (.not. used(jl, jk)) cycle
          w0 = ptenu(jl, jk)*remainder
          w1 = up_v(jl, jk) - puen(jl, jk); w1 = w1*inverse_time
          ptenu(jl, jk) = w0 + w1
          w0 = ptenv(jl, jk)*remainder
          w1 = down_u(jl, jk) - pven(jl, jk); w1 = w1*inverse_time
          ptenv(jl, jk) = w0 + w1
        end do
      end do
    end block
  end subroutine
end module
