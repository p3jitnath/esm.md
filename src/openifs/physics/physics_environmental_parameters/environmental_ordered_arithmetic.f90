!> Preserve the source propagating maximum beside a finite floor.
module forecast_environmental_ordered_arithmetic
  use iso_fortran_env, only: int64, real64
  implicit none
  private
  public :: maximum_with_finite_floor
contains
  !> Return max(value,floor), preserving a NaN value and positive-zero ties.
  !! FLOOR is finite. A volatile addition quiets a signaling NaN and raises
  !! its natural invalid flag, matching the source comparison operation.
  real(real64) function maximum_with_finite_floor(value, floor) result(output)
    real(real64), intent(in) :: value, floor
    real(real64), volatile :: nan_operand
    integer(int64) :: value_bits, floor_bits
    value_bits = transfer(value, 0_int64)
    if (iand(value_bits, int(z'7fffffffffffffff', int64)) > int(z'7ff0000000000000', int64)) then
      nan_operand = value
      output = nan_operand + 0.0_real64
    else if (value > floor) then
      output = value
    else if (floor > value) then
      output = floor
    else if (value == 0.0_real64) then
      floor_bits = transfer(floor, 0_int64)
      output = transfer(iand(value_bits, floor_bits), 0.0_real64)
    else
      output = value
    end if
  end function
end module
