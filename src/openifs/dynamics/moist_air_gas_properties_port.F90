module md2asm_moist_air_gas_properties
  !! Complete typed port of generated GPRCP, also used by initialization.
  !!
  !! A mass fraction is the constituent mass divided by the total mass.
  !! Gas constants and heat capacities have units J kg**(-1) K**(-1).
  !! Kappa is the gas constant divided by the heat capacity, with no units.
  use iso_fortran_env, only: int32, int64, real64
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(==)
  implicit none
  private
  public :: moist_air_constants, thermal_constituent, compute_moist_air_properties
  type :: moist_air_constants
    real(real64) :: dry_gas_constant = 0.0_real64, dry_heat_capacity = 0.0_real64
    real(real64) :: vapour_gas_constant = 0.0_real64, vapour_heat_capacity = 0.0_real64
    real(real64) :: liquid_heat_capacity = 0.0_real64, ice_heat_capacity = 0.0_real64
  end type
  type :: thermal_constituent
    logical :: thermal_active = .false.
    real(real64) :: gas_constant = 0.0_real64, heat_capacity = 0.0_real64
    ! The five initialized source field maps correspond to default,1,5,9,101.
    integer(int32) :: field_index_by_layout(5) = 0
  end type
contains
  subroutine compute_moist_air_properties(c, pitch, first, last, levels, water_enabled, &
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
    logical :: active(6), found, need_gas, need_heat, active_cells
    real(real64), volatile :: gas_coeff(6), heat_coeff(6)
    real(real64), allocatable, volatile :: component_gas(:), component_heat(:)
    real(real64) :: gas_value, heat_value
    real(real64) :: fraction, gas_product, heat_product, part_gas, part_heat
    integer :: cell, level, field, j, map, allocation_status
    status = 2
    if (.not. present(heat_capacity) .and. .not. present(gas_constant) .and. .not. present(kappa)) then
      status = 0
      return
    end if
    if (pitch < 1 .or. levels < 0 .or. first < 1 .or. last > pitch) return
    need_gas = present(gas_constant) .or. present(kappa)
    need_heat = present(heat_capacity) .or. present(kappa)
    active_cells = levels > 0 .and. first <= last
    if (.not. floating_environment_ready()) return
    if (present(heat_capacity)) then
      if (.not. valid_array(heat_capacity, pitch, levels)) return
    end if
    if (present(gas_constant)) then
      if (.not. valid_array(gas_constant, pitch, levels)) return
    end if
    if (present(kappa)) then
      if (.not. valid_array(kappa, pitch, levels)) return
    end if
    if (present(generic_fields)) then
      if (.not. present(constituents)) return
      if (size(generic_fields, 1) /= pitch .or. size(generic_fields, 2) < levels) return
      map = 1
      if (present(layout_code)) then
        select case (layout_code)
        case (1); map = 2
        case (5); map = 3
        case (9); map = 4
        case (101); map = 5
        end select
      end if
      do j = 1, size(constituents)
        if (.not. constituents(j)%thermal_active) cycle
        field = constituents(j)%field_index_by_layout(map)
        if (field < 1 .or. field > size(generic_fields, 3)) return
      end do
      allocate (component_gas(size(constituents)), component_heat(size(constituents)), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1
        return
      end if
      ! Requested coefficient preparation also occurs for an empty cell loop.
      if (need_gas) then
        do j = 1, size(constituents)
          if (constituents(j)%thermal_active) component_gas(j) = constituents(j)%gas_constant - c%dry_gas_constant
        end do
      end if
      if (need_heat) then
        do j = 1, size(constituents)
          if (constituents(j)%thermal_active) component_heat(j) = constituents(j)%heat_capacity - c%dry_heat_capacity
        end do
      end if
    else
      active = water_enabled
      if (present(common_water_thermal)) active = common_water_thermal
      if (present(vapour)) then
        if (active(1) .and. .not. valid_array(vapour, pitch, levels)) return
      end if
      if (present(liquid)) then
        if (active(2) .and. .not. valid_array(liquid, pitch, levels)) return
      end if
      if (present(ice)) then
        if (active(3) .and. .not. valid_array(ice, pitch, levels)) return
      end if
      if (present(rain)) then
        if (active(4) .and. .not. valid_array(rain, pitch, levels)) return
      end if
      if (present(snow)) then
        if (active(5) .and. .not. valid_array(snow, pitch, levels)) return
      end if
      if (present(graupel)) then
        if (active(6) .and. .not. valid_array(graupel, pitch, levels)) return
      end if
      active = active .and. [present(vapour), present(liquid), present(ice), present(rain), present(snow), present(graupel)]
      if (active(1)) then
        if (need_gas) gas_coeff(1) = c%vapour_gas_constant - c%dry_gas_constant
        if (need_heat) heat_coeff(1) = c%vapour_heat_capacity - c%dry_heat_capacity
      end if
      if (active(2)) then
        if (need_gas) gas_coeff(2) = -c%dry_gas_constant
        if (need_heat) heat_coeff(2) = c%liquid_heat_capacity - c%dry_heat_capacity
      end if
      if (active(3)) then
        if (need_gas) gas_coeff(3) = -c%dry_gas_constant
        if (need_heat) heat_coeff(3) = c%ice_heat_capacity - c%dry_heat_capacity
      end if
      if (active(4)) then
        if (need_gas) gas_coeff(4) = -c%dry_gas_constant
        if (need_heat) heat_coeff(4) = c%liquid_heat_capacity - c%dry_heat_capacity
      end if
      if (active(5)) then
        if (need_gas) gas_coeff(5) = -c%dry_gas_constant
        if (need_heat) heat_coeff(5) = c%ice_heat_capacity - c%dry_heat_capacity
      end if
      if (active(6)) then
        if (need_gas) gas_coeff(6) = -c%dry_gas_constant
        if (need_heat) heat_coeff(6) = c%ice_heat_capacity - c%dry_heat_capacity
      end if
    end if
    if (.not. active_cells) then
      status = 0
      return
    end if
    do level = 1, levels
      do cell = first, last
        if (present(generic_fields)) then
          found = .false.
          do j = 1, size(constituents)
            if (.not. constituents(j)%thermal_active) cycle
            field = constituents(j)%field_index_by_layout(map)
            fraction = generic_fields(cell, level, field)
            if (need_gas) then
              gas_product = component_gas(j)*fraction
              if (found) then
                gas_value = gas_value + gas_product
              else
                gas_value = gas_product
              end if
            end if
            if (need_heat) then
              heat_product = component_heat(j)*fraction
              if (found) then
                heat_value = heat_value + heat_product
              else
                heat_value = heat_product
              end if
            end if
            found = .true.
          end do
          if (found) then
            if (need_gas) gas_value = c%dry_gas_constant + gas_value
            if (need_heat) heat_value = c%dry_heat_capacity + heat_value
          else
            gas_value = c%dry_gas_constant
            heat_value = c%dry_heat_capacity
          end if
        else
          gas_value = c%dry_gas_constant
          heat_value = c%dry_heat_capacity
          ! Source order is vapour, liquid, ice, rain, snow, graupel.
          if (active(1) .and. present(vapour)) call add_water(vapour(cell, level), 1)
          if (active(2) .and. present(liquid)) call add_water(liquid(cell, level), 2)
          if (active(3) .and. present(ice)) call add_water(ice(cell, level), 3)
          if (active(4) .and. present(rain)) call add_water(rain(cell, level), 4)
          if (active(5) .and. present(snow)) call add_water(snow(cell, level), 5)
          if (active(6) .and. present(graupel)) call add_water(graupel(cell, level), 6)
        end if
        if (present(heat_capacity)) heat_capacity(cell, level) = heat_value
        if (present(gas_constant)) gas_constant(cell, level) = gas_value
        if (present(kappa)) kappa(cell, level) = gas_value/heat_value
      end do
    end do
    status = 0
  contains
    subroutine add_water(q, index)
      !! Preserve the separate gas and heat product and accumulation order.
      real(real64), intent(in) :: q
      integer, intent(in) :: index
      real(real64) :: r_product, cp_product
      if (need_gas) then
        r_product = gas_coeff(index)*q
        gas_value = gas_value + r_product
      end if
      if (need_heat) then
        cp_product = heat_coeff(index)*q
        heat_value = heat_value + cp_product
      end if
    end subroutine
  end subroutine

  logical function valid_array(a, pitch, levels) result(valid)
    real(real64), intent(in) :: a(:, :)
    integer(int32), intent(in) :: pitch, levels
    valid = size(a, 1) == pitch .and. size(a, 2) >= levels
  end function

  logical function floating_environment_ready() result(ready)
    type(ieee_round_type) :: rounding
    real(real64), volatile :: minimum_normal, half_value, subnormal_probe
    ready = .false.
    call ieee_get_rounding_mode(rounding)
    if (.not. (rounding == ieee_nearest)) return
    minimum_normal = tiny(0.0_real64)
    half_value = 0.5_real64
    subnormal_probe = minimum_normal*half_value
    if (transfer(subnormal_probe, 0_int64) /= ibset(0_int64, 51)) return
    ready = .true.
  end function
end module md2asm_moist_air_gas_properties
