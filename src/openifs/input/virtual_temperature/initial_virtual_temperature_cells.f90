module initial_virtual_temperature_cells_port
  !! Convert physical temperature T to virtual temperature (T*R)/RD.
  !! Virtual temperature describes air density using the dry-air gas constant.
  !! Temperature is in kelvin. R and RD are gas constants in J/(kg K).
  !! Multiplication is rounded before division, in source level/cell order.
  use, intrinsic :: iso_fortran_env, only: int32, real64
  implicit none
  private
  public :: initial_virtual_temperature_cells
  public :: operational_virtual_temperature_cells, runtime_virtual_temperature_cells
contains
  integer(int32) function initial_virtual_temperature_cells(temperature, gas, active, dry_gas) result(status)
    !! Selected T21 entry owns no allocation. Both complete arrays have
    !! shape(24,19) and are disjoint;only active rows1..active change.
    !! gas is readonly;temperature padding and both owners outside bounds
    !! remain untouched. IEEE arithmetic and errno follow the declared calls.
    real(real64), intent(inout) :: temperature(24, 19)
    real(real64), intent(in) :: gas(24, 19), dry_gas
    integer(int32), intent(in) :: active
    status = 2
    if (active < 1 .or. active > 24) return
    call convert_cells(temperature, gas, active, dry_gas)
    status = 0
  end function
  integer(int32) function operational_virtual_temperature_cells(temperature, gas, active, dry_gas) result(status)
    !! Fixed operational entry uses17 rows and137levels. Only active rows
    !! change. Inputs are complete,disjoint native arrays and a gas scalar.
    real(real64), intent(inout) :: temperature(17, 137)
    real(real64), intent(in) :: gas(17, 137), dry_gas
    integer(int32), intent(in) :: active
    status = 2
    if (active < 1 .or. active > 17) return
    call convert_cells(temperature, gas, active, dry_gas)
    status = 0
  end function
  integer(int32) function runtime_virtual_temperature_cells(temperature, gas, active, dry_gas) result(status)
    !! Runtime shape is(P,137),withP1..1024 and active1..P. No array changes
    !! on refusal2;success0 applies ordered FP64 multiplication, then division.
    !! Values,including signed zero and exceptional IEEE inputs,are passed
    !! to those same arithmetic operations without clipping or replacement.
    real(real64), contiguous, intent(inout) :: temperature(:, :)
    real(real64), contiguous, intent(in) :: gas(:, :)
    real(real64), intent(in) :: dry_gas
    integer(int32), intent(in) :: active
    status = 2
    if (size(temperature, 1) < 1 .or. size(temperature, 1) > 1024) return
    if (size(temperature, 2) /= 137 .or. any(shape(gas) /= shape(temperature))) return
    if (active < 1 .or. active > size(temperature, 1)) return
    call convert_cells(temperature, gas, active, dry_gas)
    status = 0
  end function
  subroutine convert_cells(temperature, gas, active, dry_gas)
    real(real64), contiguous, intent(inout) :: temperature(:, :)
    real(real64), contiguous, intent(in) :: gas(:, :)
    real(real64), intent(in) :: dry_gas
    integer(int32), intent(in) :: active
    real(real64), volatile :: product
    integer :: level, cell
    do level = 1, size(temperature, 2)
      do cell = 1, active
        product = gas(cell, level)*temperature(cell, level)
        temperature(cell, level) = product/dry_gas
      end do
    end do
  end subroutine
end module
