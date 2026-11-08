!> Select the source minimum sea-ice fraction without floating arithmetic.
module minimum_surface_ice_fraction_port
  use iso_fortran_env, only: int32, int64, real64
  implicit none
  private
  public :: initialize_minimum_surface_ice_fraction
contains
  !> Replace a negative automatic-control value by its selected fraction.
  !! VALUE is a caller-owned dimensionless real64 fraction in [-1,1].
  !! DYNAMIC_SEA_ICE and ONE_WAY_COUPLING are readonly native logicals.
  !! A negative nonzero value becomes 0.005 for dynamic sea ice without
  !! one-way coupling, or 0.02 otherwise. Both signed zeros and positive
  !! values retain every input bit. Return 2 without mutation for a NaN,
  !! an infinity or a magnitude greater than one. Otherwise return 0.
  !! The native compiler supplies storage bounds and argument alignment.
  integer(int32) function initialize_minimum_surface_ice_fraction( &
    value, dynamic_sea_ice, one_way_coupling) result(status)
    real(real64), intent(inout) :: value
    logical, intent(in) :: dynamic_sea_ice, one_way_coupling
    integer(int64) :: word, magnitude
    status = 2_int32
    word = transfer(value, word)
    magnitude = iand(word, int(z'7fffffffffffffff', int64))
    if (magnitude > int(z'3ff0000000000000', int64)) return
    if (magnitude /= 0_int64 .and. word < 0_int64) then
      if (dynamic_sea_ice .and. .not. one_way_coupling) then
        value = 0.005_real64
      else
        value = 0.02_real64
      end if
    end if
    status = 0_int32
  end function
end module
