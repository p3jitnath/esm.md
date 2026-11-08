module initial_virtual_temperature_gas_port
  !! Reuse the complete accepted owned GPRCP implementation under the
  !! initial-input name. This file replaces the generated include alias;
  !! it adds no coefficient arithmetic and imports no original data.
  use md2asm_moist_air_gas_properties, only: moist_air_constants, thermal_constituent, &
                                             initial_virtual_temperature_gas => compute_moist_air_properties
  implicit none
  private
  public :: moist_air_constants, thermal_constituent, initial_virtual_temperature_gas
end module
