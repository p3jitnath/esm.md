!> Forward the two source scan bridges through complete native argument interfaces.
!! The compiler owns saved registers and outgoing optional argument representation.
module forecast_grid_native_bridges
  use iso_fortran_env, only: int32, real64
  use md2asm_moist_air_gas_properties, only: moist_air_constants, thermal_constituent, compute_moist_air_properties
  use md2asm_virtual_temperature_conversion, only: convert_virtual_to_temperature
  implicit none
  private
  public :: scan_convert_virtual_temperature, scan_moist_air_properties
contains
!> Convert active virtual temperatures to kelvin; preserve unused temperature cells.
  subroutine scan_convert_virtual_temperature(c, pitch, first, last, levels, constituents, tracers, temperature, status)
    type(moist_air_constants), intent(in) :: c
    integer(int32), intent(in) :: pitch, first, last, levels
    type(thermal_constituent), intent(in) :: constituents(:)
    real(real64), intent(in) :: tracers(:, :, :)
    real(real64), intent(inout) :: temperature(:, :)
    integer(int32), intent(out) :: status
    call convert_virtual_to_temperature(c, pitch, first, last, levels, constituents, tracers, temperature, status)
  end subroutine
!> Forward the full gas/heat-capacity interface, including all absent optional arrays.
!! Fractions are kg/kg; gas constants and capacities are J/(kg K); kappa has no units.
  subroutine scan_moist_air_properties(c, pitch, first, last, levels, water_enabled, status, &
                                     heat_capacity, gas_constant, kappa, vapour, liquid, ice, rain, snow, graupel, generic_fields, &
                                       constituents, layout_code, common_water_thermal)
    type(moist_air_constants), intent(in) :: c
    integer(int32), intent(in) :: pitch, first, last, levels
    logical, intent(in) :: water_enabled(6)
    integer(int32), intent(out) :: status
    real(real64), intent(inout), optional :: heat_capacity(:, :), gas_constant(:, :), kappa(:, :)
    real(real64), intent(in), optional :: vapour(:, :), liquid(:, :), ice(:, :), rain(:, :), snow(:, :), graupel(:, :)
    real(real64), intent(in), optional :: generic_fields(:, :, :)
    type(thermal_constituent), intent(in), optional :: constituents(:)
    integer(int32), intent(in), optional :: layout_code
    logical, intent(in), optional :: common_water_thermal
    call compute_moist_air_properties(c, pitch, first, last, levels, water_enabled, status, &
                                     heat_capacity, gas_constant, kappa, vapour, liquid, ice, rain, snow, graupel, generic_fields, &
                                      constituents, layout_code, common_water_thermal)
  end subroutine
end module
