module convection_leaf_contract_mod
  !! Metadata checks for admitted native views; no floating-mode arithmetic.
  use iso_c_binding, only: c_double, c_int
  use saturation_humidity_mod, only: valid_real_matrix, valid_real_vector
  implicit none
  private
  public :: require, real_matrix, real_vector
  interface
    subroutine reject_contract() bind(c, name="abort")
    end subroutine
  end interface
contains
  subroutine require(condition)
    logical, intent(in) :: condition
    if (.not. condition) call reject_contract()
  end subroutine
  subroutine real_matrix(x, p, l)
    real(c_double), intent(in) :: x(:, :)
    integer(c_int), intent(in) :: p, l
    call require(valid_real_matrix(x, p, l))
  end subroutine
  subroutine real_vector(x, p)
    real(c_double), intent(in) :: x(:)
    integer(c_int), intent(in) :: p
    call require(valid_real_vector(x, p))
  end subroutine
end module
!> Complete regularised lower-bidiagonal solve.
module convection_bidiagonal_mod
  use iso_c_binding, only: c_double, c_int, c_int64_t
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use convection_leaf_contract_mod, only: require, real_matrix, real_vector
  implicit none
  private
  public :: cubidiag, cubidiag_raw
  interface cubidiag_raw
    module procedure cubidiag
  end interface
contains
  !> Solve selected equations and zero the complete declared output plane.
  !! Providers are readonly; this helper does not consume either record.
  !! Arguments after them retain original order. KCTOP has KLON integers,
  !! LD_LCUMASK and all real fields have at least(KLON,KLEV), contiguous.
  !! Inputs and output are separate. PA/PB are dimensionless, PR/PU share
  !! the caller's wind, temperature or humidity unit. All input tails remain
  !! readonly and extra PU planes remain unchanged. Caller admits finite,
  !! nonsingular used rows and the frozen nearest-even/gradual environment.
  subroutine cubidiag(constants, thermal, kidia, kfdia, klon, klev, kctop, ld_lcumask, pa, pb, pr, pu)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    integer(c_int), intent(in) :: kidia, kfdia, klon, klev, kctop(:)
    logical, intent(in) :: ld_lcumask(:, :)
    real(c_double), intent(in) :: pa(:, :), pb(:, :), pr(:, :)
    real(c_double), intent(inout) :: pu(:, :)
    integer(c_int) :: jl, jk
    real(c_double) :: diagonal, inverse_diagonal, forcing, product
    real(c_double), parameter :: regulariser = transfer(int(z'38aa95a5b7f87a0f', c_int64_t), 0.0_c_double)
    call require(klon > 0 .and. klev >= 0 .and. klev <= huge(klev) - 2)
    call require(kidia >= 1 .and. kidia <= klon .and. kfdia >= kidia - 1 .and. kfdia <= klon)
    call require(is_contiguous(kctop) .and. size(kctop) >= klon)
    call require(is_contiguous(ld_lcumask) .and. size(ld_lcumask, 1) == klon .and. size(ld_lcumask, 2) >= klev)
    call real_matrix(pa, klon, klev); call real_matrix(pb, klon, klev)
    call real_matrix(pr, klon, klev); call real_matrix(pu, klon, klev)
    pu(1:klon, 1:klev) = 0.0_c_double
    do jk = 2, klev
      do jl = kidia, kfdia
        if (.not. ld_lcumask(jl, jk)) cycle
        if (jk + 1 < kctop(jl)) cycle
        diagonal = pb(jl, jk) + regulariser
        inverse_diagonal = 1.0_c_double/diagonal
        forcing = pr(jl, jk)
        if (jk + 1 /= kctop(jl)) then
          product = pa(jl, jk)*pu(jl, jk - 1)
          forcing = forcing - product
        end if
        pu(jl, jk) = forcing*inverse_diagonal
      end do
    end do
  end subroutine
end module
