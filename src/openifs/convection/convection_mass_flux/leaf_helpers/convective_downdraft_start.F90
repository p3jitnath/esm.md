!> Complete downdraft initiation with the owned saturation-adjustment child.
module convection_downdraft_start_mod
  use iso_c_binding, only: c_double, c_int, c_int64_t
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use convection_leaf_contract_mod, only: require, real_matrix, real_vector
  use yoecumf, only: tecumf
  use yoephli, only: tephli
  use saturation_humidity_mod, only: ordered_minimum, ordered_maximum
  use convective_saturation_adjustment_mod, only: cuadjtq
  implicit none
  private
  public :: cudlfsn, cudlfsn_raw
  interface cudlfsn_raw
    module procedure cudlfsn
  end interface
contains
  !> Select the first supported downdraft and preserve all other owner bytes.
  !! Readonly providers precede the28 original arguments. Layer arrays are
  !! contiguous(KLON,at least KLEV); PGEOH/PAPH have at least KLEV+1.
  !! Temperature uses K, humidity kg/kg, pressure Pa, geopotential m2/s2,
  !! and mass/rain flux kg/(m2 s). All mutable owners are INOUT/disjoint.
  !! Caller admits the frozen finite domain, native logical flags and FP
  !! environment. LPHYLIN is false. Private row scratch stays below1MiB.
  subroutine cudlfsn(constants, thermal, ydephli, ydecumf, kidia, kfdia, klon, klev, kcbot, kctop, ldcum, &
           ptenh, pqenh, pten, pqsen, pgeo, pgeoh, paph, ptu, pqu, pmfub, prfl, ptd, pqd, pmfd, pmfds, pmfdq, pdmfdp, kdtop, lddraf)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    type(tephli), intent(in) :: ydephli
    type(tecumf), intent(in) :: ydecumf
    integer(c_int), intent(in) :: kidia, kfdia, klon, klev, kcbot(:), kctop(:)
    logical, intent(in) :: ldcum(:)
    real(c_double), intent(in) :: ptenh(:, :), pqenh(:, :), pten(:, :), pqsen(:, :), pgeo(:, :), pgeoh(:, :), paph(:, :)
    real(c_double), intent(in) :: ptu(:, :), pqu(:, :), pmfub(:)
    real(c_double), intent(inout) :: prfl(:), ptd(:, :), pqd(:, :), pmfd(:, :), pmfds(:, :), pmfdq(:, :), pdmfdp(:, :)
    integer(c_int), intent(inout) :: kdtop(:)
    logical, intent(inout) :: lddraf(:)
    integer(c_int) :: jl, jk, child_status, count
    integer(c_int64_t) :: arena_bytes
    real(c_double) :: t, alpha, w0, w1, w2, w3, energy, ttest, qtest, cond, mass_top, rain_change, old_rain
    call require(.not. ydephli%lphylin)
    call require(klon > 0 .and. klev > 0 .and. klev < huge(klev))
    call require(kidia >= 1 .and. kfdia >= kidia - 1 .and. kfdia <= klon)
    call require(is_contiguous(kdtop) .and. size(kdtop) >= klon .and. is_contiguous(lddraf) .and. size(lddraf) >= klon)
    if (kidia > kfdia) return
    do jl = kidia, kfdia
      kdtop(jl) = klev + 1; lddraf(jl) = .false.
    end do
    if (.not. ydecumf%lmfdd) return
    call require(is_contiguous(kcbot) .and. size(kcbot) >= klon .and. is_contiguous(kctop) .and. size(kctop) >= klon)
    call require(is_contiguous(ldcum) .and. size(ldcum) >= klon)
    call real_matrix(ptenh, klon, klev); call real_matrix(pqenh, klon, klev)
    call real_matrix(pten, klon, klev); call real_matrix(pqsen, klon, klev); call real_matrix(pgeo, klon, klev)
    call real_matrix(pgeoh, klon, klev + 1); call real_matrix(paph, klon, klev + 1)
    call real_matrix(ptu, klon, klev); call real_matrix(pqu, klon, klev)
    call real_vector(pmfub, klon); call real_vector(prfl, klon)
    call real_matrix(ptd, klon, klev); call real_matrix(pqd, klon, klev); call real_matrix(pmfd, klon, klev)
    call real_matrix(pmfds, klon, klev); call real_matrix(pmfdq, klon, klev); call real_matrix(pdmfdp, klon, klev)
    arena_bytes = iand(40_c_int64_t*int(klon, c_int64_t) + 47_c_int64_t, -16_c_int64_t)
    call require(arena_bytes <= 1048576_c_int64_t)
    block
      real(c_double) :: wet_t(klon, 1), wet_q(klon, 1), pressure(klon), minimum_energy(klon)
      integer(c_int) :: minimum_level(klon)
      logical :: enabled(klon)
      do jl = kidia, kfdia
        minimum_energy(jl) = 1.0e8_c_double; minimum_level(jl) = klev + 1
      end do
      do jk = 3, klev - 2
        do jl = kidia, kfdia
          t = pten(jl, jk)
          alpha = ordered_minimum(thermal%rtwat, t)
          alpha = ordered_maximum(thermal%rticecu, alpha)
          alpha = alpha - thermal%rticecu; alpha = alpha*thermal%rtwat_rticecu_r
          alpha = alpha*alpha; alpha = ordered_minimum(1.0_c_double, alpha)
          w2 = 1.0_c_double - alpha
          w1 = alpha*constants%rlvtt; w2 = w2*constants%rlstt; w1 = w1 + w2
          w1 = w1*pqsen(jl, jk)
          w0 = constants%rcpd*t; w0 = w0 + pgeo(jl, jk); energy = w0 + w1
          if (energy >= minimum_energy(jl)) cycle
          minimum_energy(jl) = energy; minimum_level(jl) = jk
        end do
      end do
      do jk = 3, klev - 3
        count = 0
        do jl = kidia, kfdia
          wet_t(jl, 1) = ptenh(jl, jk); wet_q(jl, 1) = pqenh(jl, jk); pressure(jl) = paph(jl, jk)
          enabled(jl) = .false.
          if (.not. ldcum(jl)) cycle
          if (prfl(jl) <= 0.0_c_double) cycle
          if (lddraf(jl)) cycle
          if (jk >= kcbot(jl) .or. jk <= kctop(jl) .or. jk < minimum_level(jl)) cycle
          enabled(jl) = .true.; count = count + 1
        end do
        if (count == 0) cycle
 child_status = cuadjtq(constants, thermal, ydephli, kidia, kfdia, klon, 1_c_int, 1_c_int, pressure, wet_t, wet_q, enabled, 2_c_int)
        call require(child_status == 0)
        do jl = kidia, kfdia
          if (.not. enabled(jl)) cycle
          w0 = ptu(jl, jk) + wet_t(jl, 1); ttest = 0.5_c_double*w0
          w0 = pqu(jl, jk) + wet_q(jl, 1); qtest = 0.5_c_double*w0
          cond = pqenh(jl, jk) - wet_q(jl, 1)
          w0 = constants%retv*qtest; w0 = 1.0_c_double + w0; w0 = ttest*w0
          w2 = constants%retv*pqenh(jl, jk); w2 = 1.0_c_double + w2; w2 = ptenh(jl, jk)*w2
          w0 = w0 - w2
          w2 = -ydecumf%rmfdeps; mass_top = w2*pmfub(jl)
          if (w0 >= 0.0_c_double) cycle
          w3 = 10.0_c_double*mass_top; w3 = w3*cond
          old_rain = prfl(jl)
          if (old_rain <= w3) cycle
          kdtop(jl) = jk; lddraf(jl) = .true.
          ptd(jl, jk) = ttest; pqd(jl, jk) = qtest; pmfd(jl, jk) = mass_top
          w0 = constants%rcpd*ttest; w0 = w0 + pgeoh(jl, jk); pmfds(jl, jk) = mass_top*w0
          pmfdq(jl, jk) = mass_top*qtest
          w0 = -0.5_c_double*mass_top; rain_change = w0*cond
          pdmfdp(jl, jk - 1) = rain_change
          prfl(jl) = old_rain + rain_change
        end do
      end do
    end block
  end subroutine
end module
