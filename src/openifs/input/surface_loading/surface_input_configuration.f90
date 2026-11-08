module surface_input_configuration_port
  !! Own the constants and table values used when surface input is converted.
  !! The caller provides an initialized physical-constant record. This module
  !! owns no model global and does not change that input record.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use physical_constant_setup_port, only: forecast_physical_constants
  implicit none
  private
  public :: surface_input_configuration, initialize_surface_input_configuration
  type :: surface_input_configuration
    integer(int64) :: invalid = 0, points = 0, maximum_vegetation = 0
    logical :: ecmwf = .false., currents = .false., ocean_coupling = .false.
    logical :: ocean_wave = .false., wave_coupling = .false.
    real(real64) :: gravity = 0.0_real64, freezing_temperature = 0.0_real64
    real(real64) :: water_density = 0.0_real64, water_capacity = 0.0_real64, ice_minimum = 0.0_real64
    integer(int64) :: cover_lower = 0, cover_upper = 0, leaf_lower = 0, leaf_upper = 0, revision = 0
    real(real64) :: cover(0:127) = 0.0_real64, leaf_area(0:127) = 0.0_real64
  end type
contains
  integer(int32) function initialize_surface_input_configuration(constants, points, configuration) result(status)
    !! Create one selected configuration without an allocation.
    !! points is2048 or6599680. Gravity is in m/s**2, temperatures in K,
    !! water density in kg/m**3 and the two vegetation tables are dimensionless.
    !! Refusal returns2 and leaves configuration unchanged. Success returns0.
    type(forecast_physical_constants), intent(in) :: constants
    integer(int64), intent(in) :: points
    type(surface_input_configuration), intent(inout) :: configuration
    type(surface_input_configuration) :: staged
    real(real64), volatile :: divisor
    status = 2
    if (points /= 2048_int64 .and. points /= 6599680_int64) return
    if (constants%initialized /= 1) return
    staged%points = points
    staged%maximum_vegetation = 20
    staged%cover_upper = 20
    staged%leaf_upper = 20
    staged%ecmwf = .true.
    staged%ocean_coupling = .true.
    staged%ocean_wave = .true.
    staged%revision = 1
    staged%gravity = constants%rg
    staged%freezing_temperature = constants%rtt
    divisor = 100.0_real64
    staged%water_density = constants%ratm/divisor
    staged%water_capacity = transfer(int(z'3fc999999999999a', int64), 0.0_real64)
    staged%ice_minimum = transfer(int(z'3f947ae147ae147b', int64), 0.0_real64)
    staged%cover(0) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    staged%cover(1) = transfer(int(z'3feccccccccccccd', int64), 0.0_real64)
    staged%cover(2) = transfer(int(z'3feb333333333333', int64), 0.0_real64)
    staged%cover(3) = transfer(int(z'3feccccccccccccd', int64), 0.0_real64)
    staged%cover(4) = transfer(int(z'3feccccccccccccd', int64), 0.0_real64)
    staged%cover(5) = transfer(int(z'3feccccccccccccd', int64), 0.0_real64)
    staged%cover(6) = transfer(int(z'3fefae147ae147ae', int64), 0.0_real64)
    staged%cover(7) = transfer(int(z'3fe6666666666666', int64), 0.0_real64)
    staged%cover(8) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    staged%cover(9) = transfer(int(z'3fe0000000000000', int64), 0.0_real64)
    staged%cover(10) = transfer(int(z'3feccccccccccccd', int64), 0.0_real64)
    staged%cover(11) = transfer(int(z'3fb999999999999a', int64), 0.0_real64)
    staged%cover(12) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    staged%cover(13) = transfer(int(z'3fe3333333333333', int64), 0.0_real64)
    staged%cover(14) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    staged%cover(15) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    staged%cover(16) = transfer(int(z'3fe0000000000000', int64), 0.0_real64)
    staged%cover(17) = transfer(int(z'3fe0000000000000', int64), 0.0_real64)
    staged%cover(18) = transfer(int(z'3feccccccccccccd', int64), 0.0_real64)
    staged%cover(19) = transfer(int(z'3feccccccccccccd', int64), 0.0_real64)
    staged%cover(20) = transfer(int(z'3fe3333333333333', int64), 0.0_real64)
    staged%leaf_area(0) = transfer(int(z'3fe0000000000000', int64), 0.0_real64)
    staged%leaf_area(1) = transfer(int(z'4008000000000000', int64), 0.0_real64)
    staged%leaf_area(2) = transfer(int(z'4000000000000000', int64), 0.0_real64)
    staged%leaf_area(3) = transfer(int(z'4014000000000000', int64), 0.0_real64)
    staged%leaf_area(4) = transfer(int(z'4014000000000000', int64), 0.0_real64)
    staged%leaf_area(5) = transfer(int(z'4014000000000000', int64), 0.0_real64)
    staged%leaf_area(6) = transfer(int(z'4018000000000000', int64), 0.0_real64)
    staged%leaf_area(7) = transfer(int(z'4000000000000000', int64), 0.0_real64)
    staged%leaf_area(8) = transfer(int(z'3fe0000000000000', int64), 0.0_real64)
    staged%leaf_area(9) = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    staged%leaf_area(10) = transfer(int(z'4008000000000000', int64), 0.0_real64)
    staged%leaf_area(11) = transfer(int(z'3fe0000000000000', int64), 0.0_real64)
    staged%leaf_area(12) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    staged%leaf_area(13) = transfer(int(z'4010000000000000', int64), 0.0_real64)
    staged%leaf_area(14) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    staged%leaf_area(15) = transfer(int(z'0000000000000000', int64), 0.0_real64)
    staged%leaf_area(16) = transfer(int(z'4008000000000000', int64), 0.0_real64)
    staged%leaf_area(17) = transfer(int(z'3ff8000000000000', int64), 0.0_real64)
    staged%leaf_area(18) = transfer(int(z'4014000000000000', int64), 0.0_real64)
    staged%leaf_area(19) = transfer(int(z'4004000000000000', int64), 0.0_real64)
    staged%leaf_area(20) = transfer(int(z'4010000000000000', int64), 0.0_real64)
    configuration = staged
    status = 0
  end function
end module
