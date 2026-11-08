!> Initiate midlevel plumes with the selected dry-static and mass-flux rules.
module convection_midlevel_base_mod
  use iso_c_binding, only: c_double, c_int, c_int64_t
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use convection_leaf_contract_mod, only: require, real_matrix, real_vector
  use yoecumf, only: tecumf
  use saturation_humidity_mod, only: ordered_minimum, ordered_maximum
  implicit none
  private
  public :: cubasmcn, cubasmcn_raw
  interface cubasmcn_raw
    module procedure cubasmcn
  end interface
contains
  !> Preserve each selected plume store and all inactive owner bytes.
  !! Providers/configuration are readonly. After providers the26 original
  !! arguments retain their names/order. Matrices have KLON columns and at
  !! least KLEV levels, PGEOH at least KLEV+1; vectors have at least KLON.
  !! All are contiguous and writable owners are disjoint. Temperature is K,
  !! water kg/kg, geopotential m2/s2 and mass flux kg/(m2 s).
  !! Caller supplies the frozen finite physical domain and FP environment.
  subroutine cubasmcn(constants, thermal, ydecumf, kidia, kfdia, klon, klev, kk, pten, pqen, pqsen, pvervel, pgeo, pgeoh, &
                      ldcum, ktype, klab, kcbot, pmfu, pmfub, plrain, ptu, pqu, plu, pmfus, pmfuq, pmful, pdmfup)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    type(tecumf), intent(in) :: ydecumf
    integer(c_int), intent(in) :: kidia, kfdia, klon, klev, kk
    real(c_double), intent(in) :: pten(:, :), pqen(:, :), pqsen(:, :), pvervel(:, :), pgeo(:, :), pgeoh(:, :)
    logical, intent(in) :: ldcum(:)
    integer(c_int), intent(inout) :: ktype(:), klab(:, :), kcbot(:)
    real(c_double),intent(inout) :: pmfu(:,:),pmfub(:),plrain(:,:),ptu(:,:),pqu(:,:),plu(:,:),pmfus(:,:),pmfuq(:,:),pmful(:,:),pdmfup(:,:)
    real(c_double), volatile :: inverse_g, inverse_cp
    real(c_double) :: t, q, mass, w0, w1
    integer(c_int) :: jl
    real(c_double), parameter :: humidity_threshold = transfer(int(z'3fe999999999999a', c_int64_t), 0.0_c_double)
    real(c_double), parameter :: minimum_flux = transfer(int(z'3eb0c6f7a0b5ed8d', c_int64_t), 0.0_c_double)
    call require(klon >= 0 .and. klon <= 4096 .and. klev >= 2 .and. klev <= 1024 .and. kk >= 1 .and. kk < klev)
    call require(kidia >= 1 .and. kfdia >= kidia - 1 .and. kfdia <= klon)
    call real_matrix(pten, klon, klev); call real_matrix(pqen, klon, klev); call real_matrix(pqsen, klon, klev)
    call real_matrix(pvervel, klon, klev); call real_matrix(pgeo, klon, klev); call real_matrix(pgeoh, klon, klev + 1)
    call require(is_contiguous(ldcum) .and. size(ldcum) >= klon)
    call require(is_contiguous(ktype) .and. size(ktype) >= klon .and. is_contiguous(kcbot) .and. size(kcbot) >= klon)
    call require(is_contiguous(klab) .and. size(klab, 1) == klon .and. size(klab, 2) >= klev)
    call real_vector(pmfub, klon)
    call real_matrix(pmfu, klon, klev); call real_matrix(plrain, klon, klev); call real_matrix(ptu, klon, klev)
    call real_matrix(pqu, klon, klev); call real_matrix(plu, klon, klev); call real_matrix(pmfus, klon, klev)
    call real_matrix(pmfuq, klon, klev); call real_matrix(pmful, klon, klev); call real_matrix(pdmfup, klon, klev)
    ! Both source reciprocals execute before empty/disabled physics branches.
    inverse_g = 1.0_c_double/constants%rg
    inverse_cp = 1.0_c_double/constants%rcpd
    if (kidia > kfdia .or. .not. ydecumf%lmfmid .or. kk <= ydecumf%njkt7) return
    do jl = kidia, kfdia
      if (ldcum(jl) .or. klab(jl, kk + 1) /= 0) cycle
      q = pqen(jl, kk)
      w0 = humidity_threshold*pqsen(jl, kk)
      if (q <= w0) cycle
      w0 = constants%rcpd*pten(jl, kk)
      w0 = w0 + pgeo(jl, kk)
      w0 = w0 - pgeoh(jl, kk + 1)
      t = w0*inverse_cp
      ptu(jl, kk + 1) = t; pqu(jl, kk + 1) = q; plu(jl, kk + 1) = 0.0_c_double
      w0 = -pvervel(jl, kk)
      w0 = w0*inverse_g
      w0 = ordered_maximum(minimum_flux, w0)
      mass = ordered_minimum(w0, ydecumf%rmflia)
      pmfub(jl) = mass; pmfu(jl, kk + 1) = mass
      w1 = constants%rcpd*t
      w1 = w1 + pgeoh(jl, kk + 1)
      pmfus(jl, kk + 1) = mass*w1
      pmfuq(jl, kk + 1) = mass*q
      pmful(jl, kk + 1) = 0.0_c_double; pdmfup(jl, kk + 1) = 0.0_c_double
      plrain(jl, kk + 1) = 0.0_c_double
      kcbot(jl) = kk; klab(jl, kk + 1) = 1_c_int; ktype(jl) = 3_c_int
    end do
  end subroutine
end module
