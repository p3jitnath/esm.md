!> Native private-context GPRCP/GPHPRE entries reuse exact owned calculations.
module forecast_operational_hydrostatic_children
  use iso_fortran_env, only: int32, real64
  use physical_constant_setup_port, only: forecast_physical_constants
  use md2asm_moist_air_gas_properties, only: moist_air_constants, thermal_constituent, compute_moist_air_properties
  use md2asm_hybrid_pressure_and_gradients, only: hybrid_pressure_controls, compute_hybrid_pressure
  use md2asm_hybrid_pressure_one_based, only: compute_hybrid_pressure_one_based
  implicit none
  private
  public :: thermal_constituent, hybrid_pressure_controls
  public :: compute_operational_mixture_gas_properties, compute_operational_pressure_factors
  public :: compute_operational_pressure_factors_padded
contains
  !> Borrow real constants and constituent metadata rather than a byte context.
 !! Fields use (pitch,level); generic fields add the constituent index.
 !! Fractions are kg/kg. Output gas/heat capacities are J/(kg K).
 !! Only FIRST:LAST cells change; optional outputs preserve all other words.
  subroutine compute_operational_mixture_gas_properties(constants, pitch, first, last, levels, water_enabled, status, &
  heat_capacity,gas_constant,kappa,vapour,liquid,ice,rain,snow,graupel,generic_fields,constituents,layout_code,common_water_thermal)
    type(forecast_physical_constants), intent(in) :: constants
    integer(int32), intent(in) :: pitch, first, last, levels
    logical, intent(in) :: water_enabled(6)
    integer(int32), intent(out) :: status
    real(real64), intent(inout), optional :: heat_capacity(:, :), gas_constant(:, :), kappa(:, :)
    real(real64), intent(in), optional :: vapour(:, :), liquid(:, :), ice(:, :), rain(:, :), snow(:, :), graupel(:, :)
    real(real64), intent(in), optional :: generic_fields(:, :, :)
    type(thermal_constituent), intent(in), optional :: constituents(:)
    integer(int32), intent(in), optional :: layout_code
    logical, intent(in), optional :: common_water_thermal
    type(moist_air_constants) :: c
    c%dry_gas_constant = constants%rd
    c%dry_heat_capacity = constants%rcpd
    c%vapour_gas_constant = constants%rv
    c%vapour_heat_capacity = constants%rcpv
    c%liquid_heat_capacity = constants%rcw
    c%ice_heat_capacity = constants%rcs
    call compute_moist_air_properties(c, pitch, first, last, levels, water_enabled, status, heat_capacity, gas_constant, kappa, &
                          vapour, liquid, ice, rain, snow, graupel, generic_fields, constituents, layout_code, common_water_thermal)
  end subroutine
  !> Use the produced1:L full/delta coordinates without a fabricated zero row.
 !! Half coefficients and pressure retain0:L bounds, in Pa/dimensionless B.
 !! Controls and field indices are the existing canonical native declarations.
  subroutine compute_operational_pressure_factors(c, pitch, first, last, levels, a_half, b_half, half_pressure, status, &
                                      number_fields, field_index, vc, full_a, full_b, delta_a, delta_b, coefficients, full_pressure)
    type(hybrid_pressure_controls), intent(in) :: c
    integer(int32), intent(in) :: pitch, first, last, levels
    real(real64), intent(in) :: a_half(0:), b_half(0:)
    real(real64), intent(inout) :: half_pressure(:, 0:)
    integer(int32), intent(out) :: status
    integer(int32), intent(in), optional :: number_fields, field_index(:)
    real(real64), intent(in), optional :: vc(1:), full_a(1:), full_b(1:), delta_a(1:), delta_b(1:)
    real(real64), intent(inout), optional :: coefficients(:, :, :), full_pressure(:, :)
    call compute_hybrid_pressure_one_based(c, pitch, first, last, levels, a_half, b_half, half_pressure, status, number_fields, &
                                           field_index, vc, full_a, full_b, delta_a, delta_b, coefficients, full_pressure)
  end subroutine
  !> Preserve the distinct previously qualified padded0:L auxiliary route.
  subroutine compute_operational_pressure_factors_padded(c, pitch, first, last, levels, a_half, b_half, half_pressure, status, &
                                      number_fields, field_index, vc, full_a, full_b, delta_a, delta_b, coefficients, full_pressure)
    type(hybrid_pressure_controls), intent(in) :: c
    integer(int32), intent(in) :: pitch, first, last, levels
    real(real64), intent(in) :: a_half(0:), b_half(0:)
    real(real64), intent(inout) :: half_pressure(:, 0:)
    integer(int32), intent(out) :: status
    integer(int32), intent(in), optional :: number_fields, field_index(:)
    real(real64), intent(in), optional :: vc(0:), full_a(0:), full_b(0:), delta_a(0:), delta_b(0:)
    real(real64), intent(inout), optional :: coefficients(:, :, :), full_pressure(:, :)
    call compute_hybrid_pressure(c, pitch, first, last, levels, a_half, b_half, half_pressure, status, number_fields, &
                                 field_index, vc, full_a, full_b, delta_a, delta_b, coefficients, full_pressure)
  end subroutine
end module forecast_operational_hydrostatic_children
