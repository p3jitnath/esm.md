!> Cumulative optical-depth profiles from original SU_AERV.
!! Heights are metres. Eta is a dimensionless increasing boundary coordinate.
module forecast_aerosol_vertical_profiles
  use iso_fortran_env, only: int32, real64
  use yoerad, only: terad
  use forecast_public_scalar_math, only: power_original_rounding
  implicit none
  private
  public :: initialize_aerosol_vertical_profiles, initialize_aerosol_record_profiles
  public :: initialize_aerosol_profile_arrays
contains
  !> Fill five profiles stored as columns in one contiguous native matrix.
  !! Only the first L+1 rows and first five species change.
  subroutine initialize_aerosol_vertical_profiles(levels, heights, eta, profiles, status)
    integer(int32), intent(in) :: levels
    real(real64), intent(in) :: heights(5), eta(:)
    real(real64), intent(inout) :: profiles(:, :)
    integer(int32), intent(out) :: status
    status = 2
    if (size(profiles, 2) < 5) return
    call initialize_aerosol_profile_arrays(levels,heights,eta,profiles(:,1),profiles(:,2),profiles(:,3),profiles(:,4),profiles(:,5),status)
  end subroutine

  !> Write directly into the native radiation record's five profile owners.
  !! The record's heights are read-only; allocation and every other field stay unchanged.
  subroutine initialize_aerosol_record_profiles(levels, eta, record, status)
    integer(int32), intent(in) :: levels
    real(real64), intent(in) :: eta(:)
    type(terad), intent(inout) :: record
    integer(int32), intent(out) :: status
    real(real64) :: heights(5)
    status = 2
    if(.not.allocated(record%cvdaess).or..not.allocated(record%cvdaedu).or..not.allocated(record%cvdaeom).or..not.allocated(record%cvdaebc).or..not.allocated(record%cvdaesu)) return
    heights = [record%raeshss, record%raeshdu, record%raeshom, record%raeshbc, record%raeshsu]
    call initialize_aerosol_profile_arrays(levels,heights,eta,record%cvdaess,record%cvdaedu,record%cvdaeom,record%cvdaebc,record%cvdaesu,status)
  end subroutine

  !> Fill separate sea-salt,dust,organic,black-carbon,sulphate native owners.
  !! Each array owns at least L+1 values. Levels0:512 are supported.
  !! The caller establishes the FP mode and keeps outputs disjoint from inputs.
  subroutine initialize_aerosol_profile_arrays(levels, heights, eta, sea_salt, dust, organic, black_carbon, sulphate, status)
    integer(int32), intent(in) :: levels
    real(real64), intent(in) :: heights(5), eta(:)
    real(real64), intent(inout) :: sea_salt(:), dust(:), organic(:), black_carbon(:), sulphate(:)
    integer(int32), intent(out) :: status
    real(real64), volatile :: exponents(5)
    real(real64) :: previous
    integer :: species, k
    status = 2
    if (levels < 0 .or. levels > 512) return
    if (min(size(eta), size(sea_salt), size(dust), size(organic), size(black_carbon), size(sulphate)) < levels + 1) return
    do species = 1, 5
      if (.not. (heights(species) >= 1.0_real64 .and. heights(species) <= 1000000.0_real64)) return
      exponents(species) = 8434.0_real64/heights(species)
      exponents(species) = max(1.0_real64, exponents(species))
    end do
    previous = 0.0_real64
    do k = 1, levels + 1
      if (.not. (eta(k) >= 0.0_real64 .and. eta(k) <= 1.0_real64 .and. eta(k) >= previous)) return
      previous = eta(k)
    end do
    sea_salt(1) = 0.0_real64; dust(1) = 0.0_real64; organic(1) = 0.0_real64
    black_carbon(1) = 0.0_real64; sulphate(1) = 0.0_real64
    if (eta(1) /= 0.0_real64) then
      sea_salt(1) = power_original_rounding(eta(1), exponents(1))
      dust(1) = power_original_rounding(eta(1), exponents(2))
      organic(1) = power_original_rounding(eta(1), exponents(3))
      black_carbon(1) = power_original_rounding(eta(1), exponents(4))
      sulphate(1) = power_original_rounding(eta(1), exponents(5))
    end if
    do k = 2, levels + 1
      sea_salt(k) = power_original_rounding(eta(k), exponents(1))
      dust(k) = power_original_rounding(eta(k), exponents(2))
      organic(k) = power_original_rounding(eta(k), exponents(3))
      black_carbon(k) = power_original_rounding(eta(k), exponents(4))
      sulphate(k) = power_original_rounding(eta(k), exponents(5))
    end do
    status = 0
  end subroutine
end module
