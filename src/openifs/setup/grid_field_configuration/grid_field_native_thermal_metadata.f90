module grid_field_native_thermal_metadata_port
  !! Copy own field metadata into the accepted thermodynamic interfaces.
  !! Gas constants and heat capacities use J/(kg K); field maps are one-based
  !! indices or the unchanged source undefined sentinel. This native join
  !! replaces a private-record projection, without original model globals.
  use, intrinsic :: iso_fortran_env, only: int32
  use grid_field_configuration_types_port, only: grid_field_configuration
  use md2asm_moist_air_gas_properties, only: thermal_constituent, moist_air_constants
  use physical_constant_setup_port, only: forecast_physical_constants
  implicit none
  private
  public :: export_grid_field_thermal_constituents, export_native_moist_air_constants
contains
  integer(int32) function export_grid_field_thermal_constituents(configuration, output) result(status)
    !! output(:) has8 selected or9 operational entries and stays caller-owned.
    !! Keep its target alive while a gridpoint_field_state borrows it. Output
    !! changes only after every consumed field passes its registration checks.
    !! No floating-point arithmetic or private descriptor interpretation occurs.
    type(grid_field_configuration), intent(in) :: configuration
    type(thermal_constituent), contiguous, intent(inout) :: output(:)
    integer(int32) :: n, j
    status = 2_int32
    n = configuration%registration%numflds
    if (n /= 8 .and. n /= 9) return
    if (size(output) /= n) return
    if (configuration%registration%numgpflds /= n .or. configuration%registration%ndim /= n) return
    do j = 1, n
      if (configuration%components(j)%lactive /= 1 .or. configuration%components(j)%mp /= j) return
      if (configuration%components(j)%lthermact < 0 .or. configuration%components(j)%lthermact > 1) return
    end do
    do j = 1, n
      output(j)%thermal_active = configuration%components(j)%lthermact /= 0
      output(j)%gas_constant = configuration%components(j)%r
      output(j)%heat_capacity = configuration%components(j)%rcp
      ! Layout101 uses the advection position, not the physics-owner index.
      output(j)%field_index_by_layout = [configuration%components(j)%mp, &
                                         configuration%components(j)%mp1, configuration%components(j)%mp5, &
                                         configuration%components(j)%mp9, configuration%components(j)%mp_sl1]
    end do
    status = 0_int32
  end function

  integer(int32) function export_native_moist_air_constants(constants, output) result(status)
    !! Copy all six requested constants from the accepted own constructor.
    !! The record initialized flag must be1; a refusal preserves output.
    type(forecast_physical_constants), intent(in) :: constants
    type(moist_air_constants), intent(inout) :: output
    status = 2_int32
    if (constants%initialized /= 1) return
    output%dry_gas_constant = constants%rd
    output%dry_heat_capacity = constants%rcpd
    output%vapour_gas_constant = constants%rv
    output%vapour_heat_capacity = constants%rcpv
    output%liquid_heat_capacity = constants%rcw
    output%ice_heat_capacity = constants%rcs
    status = 0_int32
  end function
end module grid_field_native_thermal_metadata_port
