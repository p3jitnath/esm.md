!> Source-ordered pressure, moist-air and hydrostatic preparations for EC_PHYS.
!! All numerical fields remain with the caller. These three support entries
!! add no original source counterpart. The caller owns scratch XYB and R
!! arrays and supplies nearest-even rounding with gradual underflow.
module forecast_column_physics_preparations
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double
  use forecast_physics_work_types, only: DIMENSION_TYPE, AUX_TYPE
  use physical_constant_setup_port, only: forecast_physical_constants
  use grid_field_configuration_types_port, only: grid_field_configuration
  use grid_field_native_thermal_metadata_port, only: export_grid_field_thermal_constituents, &
                                                     export_native_moist_air_constants
  use md2asm_hybrid_pressure_one_based, only: hybrid_pressure_controls, compute_hybrid_pressure_one_based
  use md2asm_moist_air_gas_properties, only: moist_air_constants, thermal_constituent, compute_moist_air_properties
  use md2asm_geopotential_and_column_water, only: compute_geopotential
  use md2asm_vertical_operators, only: vertical_operator_matrices
  implicit none
  private
  public :: ec_pressure, ec_mixture, ec_geopotential
  interface
    function public_exp(value) bind(C, name='exp') result(answer)
      import :: c_double
      real(c_double), value :: value
      real(c_double) :: answer
    end function
  end interface
contains
  !> Exponentiate surface log-pressure, then call the complete native GPHPRE.
  !! A_HALF/B_HALF use half levels0:L; other coefficient arrays use levels1:L.
  !! LOG_SURFACE is readonly. HALF_PRESSURE(P,0:L), XYB(P,L,N) and
  !! FULL_PRESSURE(P,L or greater) are mutable independent caller owners.
  !! A and pressures use Pa; B and XYB coefficient units follow GPHPRE.
  !! FIELD_INDEX names its seven source planes, in their initialized order.
  !! On child failure, preceding EXP and half-pressure stores remain visible.
  integer(int32) function ec_pressure(dims, controls, a_half, b_half, vc, full_a, full_b, &
                                      delta_a, delta_b, field_index, log_surface, half_pressure, xyb, full_pressure) result(status)
    type(DIMENSION_TYPE), intent(in) :: dims
    type(hybrid_pressure_controls), intent(in) :: controls
    real(real64), intent(in) :: a_half(0:), b_half(0:), vc(:), full_a(:), full_b(:), delta_a(:), delta_b(:)
    integer(int32), intent(in) :: field_index(:)
    real(real64), intent(in) :: log_surface(:)
    real(real64), intent(inout) :: half_pressure(:, 0:), xyb(:, :, :), full_pressure(:, :)
    integer(int32) :: cell, nfields, used_fields, j, k
    status = 2_int32
    if (.not. valid_dimensions(dims)) return
    if (.not. is_contiguous(a_half) .or. .not. is_contiguous(b_half)) return
    if (.not. is_contiguous(vc) .or. .not. is_contiguous(full_a) .or. .not. is_contiguous(full_b)) return
    if (.not. is_contiguous(delta_a) .or. .not. is_contiguous(delta_b)) return
    if (.not. is_contiguous(field_index) .or. .not. is_contiguous(log_surface)) return
    if (.not. is_contiguous(half_pressure) .or. .not. is_contiguous(xyb)) return
    if (.not. is_contiguous(full_pressure)) return
    if (ubound(a_half, 1) < dims%KLEV - 1 .or. ubound(b_half, 1) < dims%KLEV - 1) return
    if (size(vc) < dims%KLEV .or. size(full_a) < dims%KLEV .or. size(full_b) < dims%KLEV) return
    if (size(delta_a) < dims%KLEV .or. size(delta_b) < dims%KLEV) return
    if (size(log_surface) < dims%KLON) return
    if (size(half_pressure, 1) /= dims%KLON .or. ubound(half_pressure, 2) < dims%KLEV) return
    if (size(full_pressure, 1) /= dims%KLON .or. size(full_pressure, 2) < dims%KLEV) return
    if (size(xyb, 1) /= dims%KLON .or. size(xyb, 2) /= dims%KLEV) return
    nfields = size(xyb, 3)
    used_fields = 7_int32
    if (controls%finite_elements) used_fields = 5_int32
    if (nfields < used_fields .or. size(field_index) < used_fields) return
    do j = 1, used_fields
      if (field_index(j) < 1 .or. field_index(j) > nfields) return
      do k = 1, j - 1
        if (field_index(j) == field_index(k)) return
      end do
    end do
    if (.not. controls%finite_elements) then
      if (controls%approximate_mode /= 0 .and. controls%approximate_mode /= 1 .and. dims%KLEV < 2) return
    end if

    do cell = dims%KIDIA, dims%KFDIA
      half_pressure(cell, dims%KLEV) = public_exp(log_surface(cell))
    end do
    call compute_hybrid_pressure_one_based(controls, dims%KLON, dims%KIDIA, dims%KFDIA, &
                                 dims%KLEV, a_half, b_half, half_pressure, status, number_fields=nfields, field_index=field_index, &
                                           vc=vc, full_a=full_a, full_b=full_b, delta_a=delta_a, delta_b=delta_b, &
                                           coefficients=xyb, full_pressure=full_pressure)
  end function ec_pressure

  !> Compute only R from the actual generic constituent fields, with layout9.
  !! Constants and GFL are the existing canonical records. GENERIC_FIELDS is
  !! readonly(P,L,F), with mass fractions in kg/kg. GAS_CONSTANT is mutable
  !! (P,at least L), in J/(kg K), and preserves inactive cells and extra levels.
  !! The inherited child prepares gas differences even for an empty interval.
  integer(int32) function ec_mixture(dims, constants, gfl, generic_fields, gas_constant) result(status)
    type(DIMENSION_TYPE), intent(in) :: dims
    type(forecast_physical_constants), intent(in) :: constants
    type(grid_field_configuration), intent(in) :: gfl
    real(real64), intent(in) :: generic_fields(:, :, :)
    real(real64), intent(inout) :: gas_constant(:, :)
    type(moist_air_constants) :: air_constants
    type(thermal_constituent) :: constituents(9)
    integer(int32) :: count
    logical :: unused_water_flags(6)
    status = 2_int32
    if (.not. valid_dimensions(dims)) return
    if (.not. is_contiguous(generic_fields) .or. .not. is_contiguous(gas_constant)) return
    if (size(generic_fields, 1) /= dims%KLON .or. size(generic_fields, 2) < dims%KLEV) return
    if (size(gas_constant, 1) /= dims%KLON .or. size(gas_constant, 2) < dims%KLEV) return
    count = gfl%registration%numflds
    if (count /= 8 .and. count /= 9) return
    status = export_grid_field_thermal_constituents(gfl, constituents(:count))
    if (status /= 0_int32) return
    status = export_native_moist_air_constants(constants, air_constants)
    if (status /= 0_int32) return
    ! The generic-fields route never consumes these standalone-water flags.
    ! Their copied source metadata adds no scientific constant or new choice.
    unused_water_flags = constituents(1:6)%thermal_active
    call compute_moist_air_properties(air_constants, dims%KLON, dims%KIDIA, dims%KFDIA, &
                                      dims%KLEV, unused_water_flags, status, gas_constant=gas_constant, &
                                      generic_fields=generic_fields, constituents=constituents(:count), layout_code=9_int32)
  end function ec_mixture

  !> Seed surface geopotential, integrate hydrostatics, then subtract its surface.
  !! Temperature is K; gas constants J/(kg K); geopotential m**2/s**2.
  !! XYB and FIELD_INDEX borrow the earlier pressure preparation. METRIC and
  !! TABLES borrow the actual vertical producer on the finite-element route.
  !! AUXILIARY owns none of its pointer targets. PAPHI/PGEOMH use levels0:L;
  !! PAPHIF/PGEOM1 use levels1:L. Every first-axis bound is1:P.
  !! LSACC=true needs the distinct original accelerated path and is refused.
  integer(int32) function ec_geopotential(dims, lsacc, finite_elements, tables, integral_bc, &
                                       derivative_bc, temperature, gas_constant, xyb, field_index, metric, auxiliary) result(status)
    type(DIMENSION_TYPE), intent(in) :: dims
    logical, intent(in) :: lsacc, finite_elements
    type(vertical_operator_matrices), intent(in) :: tables
    integer(int32), intent(in) :: integral_bc, derivative_bc
    real(real64), intent(in) :: temperature(:, :), gas_constant(:, :), xyb(:, :, :), metric(:)
    integer(int32), intent(in) :: field_index(:)
    type(AUX_TYPE), intent(inout) :: auxiliary
    integer(int32) :: cell, level
    real(real64) :: surface
    status = 2_int32
    if (.not. valid_dimensions(dims)) return
    if (lsacc) return
    if (.not. is_contiguous(temperature) .or. .not. is_contiguous(gas_constant)) return
    if (.not. is_contiguous(xyb) .or. .not. is_contiguous(metric)) return
    if (.not. is_contiguous(field_index)) return
    if (size(temperature, 1) /= dims%KLON .or. size(temperature, 2) < dims%KLEV) return
    if (size(gas_constant, 1) /= dims%KLON .or. size(gas_constant, 2) < dims%KLEV) return
    if (size(xyb, 1) /= dims%KLON .or. size(xyb, 2) < dims%KLEV) return
    if (size(field_index) < 4) return
    if (field_index(3) < 1 .or. field_index(3) > size(xyb, 3)) return
    if (field_index(4) < 1 .or. field_index(4) > size(xyb, 3)) return
    if (finite_elements .and. size(metric) < dims%KLEV) return
    if (.not. associated(auxiliary%POROG)) return
    if (.not. associated(auxiliary%PAPHI)) return
    if (.not. associated(auxiliary%PAPHIF)) return
    if (.not. associated(auxiliary%PGEOM1)) return
    if (.not. associated(auxiliary%PGEOMH)) return
    if (.not. is_contiguous(auxiliary%POROG)) return
    if (.not. is_contiguous(auxiliary%PAPHI) .or. .not. is_contiguous(auxiliary%PAPHIF)) return
    if (.not. is_contiguous(auxiliary%PGEOM1) .or. .not. is_contiguous(auxiliary%PGEOMH)) return
    if (lbound(auxiliary%POROG, 1) /= 1 .or. size(auxiliary%POROG) < dims%KLON) return
    if (.not. valid_half_owner(auxiliary%PAPHI, dims)) return
    if (.not. valid_full_owner(auxiliary%PAPHIF, dims)) return
    if (.not. valid_full_owner(auxiliary%PGEOM1, dims)) return
    if (.not. valid_half_owner(auxiliary%PGEOMH, dims)) return
    ! Pointer lower bounds are part of this native record's level semantics.
    if (lbound(auxiliary%PAPHI, 1) /= 1 .or. lbound(auxiliary%PAPHI, 2) /= 0) return
    if (lbound(auxiliary%PGEOMH, 1) /= 1 .or. lbound(auxiliary%PGEOMH, 2) /= 0) return
    if (lbound(auxiliary%PAPHIF, 1) /= 1 .or. lbound(auxiliary%PAPHIF, 2) /= 1) return
    if (lbound(auxiliary%PGEOM1, 1) /= 1 .or. lbound(auxiliary%PGEOM1, 2) /= 1) return

    do cell = dims%KIDIA, dims%KFDIA
      auxiliary%PAPHI(cell, dims%KLEV) = auxiliary%POROG(cell)
    end do
    call compute_geopotential(dims%KLON, dims%KIDIA, dims%KFDIA, dims%KLEV, finite_elements, &
                              tables, integral_bc, derivative_bc, gas_constant, temperature, xyb(:, :, field_index(3)), &
                              auxiliary%PAPHI, auxiliary%PAPHIF, status, alpha=xyb(:, :, field_index(4)), metric=metric)
    if (status /= 0_int32) return
    do level = 1, dims%KLEV
      do cell = dims%KIDIA, dims%KFDIA
        surface = auxiliary%PAPHI(cell, dims%KLEV)
        auxiliary%PGEOM1(cell, level) = auxiliary%PAPHIF(cell, level) - surface
        auxiliary%PGEOMH(cell, level) = auxiliary%PAPHI(cell, level) - surface
      end do
    end do
    do cell = dims%KIDIA, dims%KFDIA
      auxiliary%PGEOMH(cell, 0) = auxiliary%PAPHI(cell, 0) - auxiliary%PAPHI(cell, dims%KLEV)
    end do
  end function ec_geopotential

  !> Check the live column/level interval using only integer metadata.
  logical function valid_dimensions(dims) result(valid)
    type(DIMENSION_TYPE), intent(in) :: dims
    valid = .false.
    if (dims%KLON < 1 .or. dims%KLON > 4096) return
    if (dims%KLEV < 1 .or. dims%KLEV > 137) return
    if (int(dims%KLON, int64)*int(dims%KLEV, int64) > 65536_int64) return
    if (dims%KIDIA < 1 .or. dims%KIDIA > dims%KLON) return
    if (dims%KFDIA < 0 .or. dims%KFDIA > dims%KLON) return
    valid = .true.
  end function valid_dimensions
  logical function valid_half_owner(a, dims) result(valid)
    real(real64), intent(in) :: a(:, 0:)
    type(DIMENSION_TYPE), intent(in) :: dims
    valid = size(a, 1) == dims%KLON .and. ubound(a, 2) >= dims%KLEV
  end function valid_half_owner
  logical function valid_full_owner(a, dims) result(valid)
    real(real64), intent(in) :: a(:, :)
    type(DIMENSION_TYPE), intent(in) :: dims
    valid = size(a, 1) == dims%KLON .and. size(a, 2) >= dims%KLEV
  end function valid_full_owner
end module forecast_column_physics_preparations
