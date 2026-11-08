!> Complete radiation namespaces for the unchanged native pressure/gas bodies.
!! Each original generated file is a renamed include with one scientific
!! export. These procedures forward the complete canonical typed interface,
!! including absent optional arguments, without another numerical algorithm.
module forecast_native_radiation_pressure_and_gas
  use iso_fortran_env, only: int32, real64
  use md2asm_hybrid_pressure_and_gradients, only: hybrid_pressure_controls, compute_hybrid_pressure
  use md2asm_moist_air_gas_properties, only: moist_air_constants, thermal_constituent, compute_moist_air_properties
  implicit none
  private
  public :: radiation_grid_pressure_child, radiation_grid_gas_child
  public :: hybrid_pressure_controls, moist_air_constants, thermal_constituent
contains
  subroutine radiation_grid_pressure_child(c, pitch, first, last, levels, a_half, b_half, &
                                          half_pressure, status, number_fields, field_index, vc, full_a, full_b, delta_a, delta_b, &
                                           coefficients, full_pressure)
    !! Complete GPHPRE. The final half-pressure row supplies surface pressure.
    !!
    !! half_pressure has bounds(1:pitch,0:levels). Only rows0:levels-1 are
    !! written. Optional full_pressure has shape(pitch,levels). The seven
    !! coefficient indices name delta pressure, its reciprocal, pressure
    !! ratio/log term, alpha, beta, reciprocal half pressure and reciprocal
    !! adjacent-pressure product. Their source field order is supplied by
    !! initialized typed metadata, not by compiler-specific object offsets.
    type(hybrid_pressure_controls), intent(in) :: c
    integer(int32), intent(in) :: pitch, first, last, levels
    real(real64), intent(in) :: a_half(0:), b_half(0:)
    real(real64), intent(inout) :: half_pressure(:, 0:)
    integer(int32), intent(out) :: status
    integer(int32), intent(in), optional :: number_fields, field_index(:)
    real(real64), intent(in), optional :: vc(0:), full_a(0:), full_b(0:)
    real(real64), intent(in), optional :: delta_a(0:), delta_b(0:)
    real(real64), intent(inout), optional :: coefficients(:, :, :), full_pressure(:, :)
    call compute_hybrid_pressure(c=c,pitch=pitch,first=first,last=last,levels=levels,a_half=a_half,b_half=b_half,half_pressure=half_pressure,status=status,number_fields=number_fields,field_index=field_index,vc=vc,full_a=full_a,full_b=full_b,delta_a=delta_a,delta_b=delta_b,coefficients=coefficients,full_pressure=full_pressure)
  end subroutine
  subroutine radiation_grid_gas_child(c, pitch, first, last, levels, water_enabled, &
                                      status, heat_capacity, gas_constant, kappa, vapour, liquid, ice, rain, snow, graupel, &
                                      generic_fields, constituents, layout_code, common_water_thermal)
    !! Change only cells first:last in each of levels rows.
    !!
    !! Arrays use (horizontal cell, vertical level). The optional generic
    !! array adds a constituent-field dimension. Input fractions are read
    !! without mutation. Output owners must be independent of input owners.
    !! Each optional output preserves its inactive cells and stored padding.
    type(moist_air_constants), intent(in) :: c
    integer(int32), intent(in) :: pitch, first, last, levels
    logical, intent(in) :: water_enabled(6)
    integer(int32), intent(out) :: status
    real(real64), intent(inout), optional :: heat_capacity(:, :), gas_constant(:, :), kappa(:, :)
    real(real64), intent(in), optional :: vapour(:, :), liquid(:, :), ice(:, :)
    real(real64), intent(in), optional :: rain(:, :), snow(:, :), graupel(:, :)
    real(real64), intent(in), optional :: generic_fields(:, :, :)
    type(thermal_constituent), intent(in), optional :: constituents(:)
    integer(int32), intent(in), optional :: layout_code
    logical, intent(in), optional :: common_water_thermal
    call compute_moist_air_properties(c=c,pitch=pitch,first=first,last=last,levels=levels,water_enabled=water_enabled,status=status,heat_capacity=heat_capacity,gas_constant=gas_constant,kappa=kappa,vapour=vapour,liquid=liquid,ice=ice,rain=rain,snow=snow,graupel=graupel,generic_fields=generic_fields,constituents=constituents,layout_code=layout_code,common_water_thermal=common_water_thermal)
  end subroutine

end module
