!> Complete plume entrainment/detrainment with native stochastic settings.
module convection_entrainment_mod
  use iso_c_binding, only: c_double, c_int, c_int64_t
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use convection_leaf_contract_mod, only: require, real_matrix, real_vector
  use yoecumf, only: tecumf
  use spp_mod, only: tspp_config
  use saturation_humidity_mod, only: public_exp
  implicit none
  private
  public :: cuentr, cuentr_raw
  interface cuentr_raw
    module procedure cuentr
  end interface
contains
  !> Mutate only the two selected exchange vectors in kg/(m2 s).
  !! All18 original arguments follow the explicit readonly providers.
  !! Layer/face arrays have first extent KLON, at least KLEV/KLEV+1 levels.
  !! PGP2DSPP has native random-field columns selected by SM%PN%MP.
  !! Readonly arrays may share storage; outputs are separate and contiguous.
  !! LDWORK=false consumes no numerical input and keeps all output bytes.
  !! Caller supplies complete valid native SPP owners/indices, finite source
  !! arithmetic, the retained physical domain and established FP mode.
  subroutine cuentr(constants, thermal, ydecumf, ydspp_config, kidia, kfdia, klon, klev, kk, kcbot, ktype, ldcum, ldwork, &
                    pqsen, paph, pgeoh, pmfu, pgp2dspp, pdmfen, pdmfde)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    type(tecumf), intent(in) :: ydecumf
    type(tspp_config), intent(in) :: ydspp_config
    integer(c_int), intent(in) :: kidia, kfdia, klon, klev, kk, kcbot(:), ktype(:)
    logical, intent(in) :: ldcum(:), ldwork
    real(c_double), intent(in) :: pqsen(:, :), paph(:, :), pgeoh(:, :), pmfu(:, :), pgp2dspp(:, :)
    real(c_double), intent(inout) :: pdmfen(:), pdmfde(:)
    integer(c_int) :: jl, ipn, random_column
    logical :: perturb
    real(c_double), volatile :: inverse_g, positive_zero
    real(c_double) :: mu, magnitude, w0, coefficient
    real(c_double), volatile :: thickness, mass
    if (.not. ldwork) return
    call require(klon >= 0 .and. klon <= 4096 .and. klev >= 2 .and. klev <= 1024 .and. kk >= 1 .and. kk < klev)
    call require(kidia >= 1 .and. kfdia >= kidia - 1 .and. kfdia <= klon)
    call require(is_contiguous(kcbot) .and. size(kcbot) >= klon .and. is_contiguous(ldcum) .and. size(ldcum) >= klon)
    call real_matrix(pgeoh, klon, klev + 1); call real_matrix(pmfu, klon, klev)
    call real_vector(pdmfen, klon); call real_vector(pdmfde, klon)
    inverse_g = 1.0_c_double/constants%rg
    positive_zero = 0.0_c_double
    perturb = .false.
    if (ydspp_config%lspp) then
      ipn = ydspp_config%pptr%detrpen
      if (ipn > 0) then
        mu = ydspp_config%sm%pn(ipn)%mu(1)
        magnitude = ydspp_config%sm%pn(ipn)%xmag(1)
        random_column = ydspp_config%sm%pn(ipn)%mp
        call require(is_contiguous(pgp2dspp).and.size(pgp2dspp,1)==klon.and.random_column>=1.and.random_column<=size(pgp2dspp,2))
        perturb = .true.
      end if
    end if
    do jl = kidia, kfdia
      pdmfen(jl) = 0.0_c_double; pdmfde(jl) = 0.0_c_double
      if (.not. ldcum(jl)) cycle
      w0 = pgeoh(jl, kk) - pgeoh(jl, kk + 1)
      thickness = w0*inverse_g
      mass = pmfu(jl, kk + 1)*thickness
      if (kk >= kcbot(jl)) cycle
      coefficient = ydecumf%detrpen
      if (perturb) then
        w0 = magnitude*pgp2dspp(jl, random_column)
        w0 = mu + w0
        w0 = public_exp(w0)
        coefficient = ydecumf%detrpen*w0
      end if
      pdmfen(jl) = positive_zero*mass
      pdmfde(jl) = coefficient*mass
    end do
  end subroutine
end module
