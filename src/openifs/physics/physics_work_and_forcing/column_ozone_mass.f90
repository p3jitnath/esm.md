!> Integrate ozone mass through source pressure layers in increasing level order.
module forecast_column_ozone_mass
  use iso_fortran_env, only: int32, int64, real64
  implicit none
  private
  public :: integrate_column_ozone_mass
contains
!> Return column ozone in kg/m2 from mass fraction kg/kg and pressure depth Pa.
!! GRAVITY is m/s2. Ordinary arrays are(P,L); OUTPUT is(P).
!! The active interval FIRST:LAST is inclusive; inactive rows retain every bit.
!! Zero levels still calculate1/GRAVITY and zero the active output, as the source does.
!! Empty intervals return before numerical work. Rates can be absent for zero levels.
  integer(int32)function integrate_column_ozone_mass(gravity,pitch,first,last,levels,pressure_depth,ozone,output)result(status)
  real(real64), intent(in) :: gravity
  integer(int32), intent(in) :: pitch, first, last, levels
  real(real64), intent(in), optional :: pressure_depth(:, :), ozone(:, :)
  real(real64), intent(inout) :: output(:)
  real(real64), volatile :: inverse_gravity, term
  integer(int64) :: bits
  integer :: level, column
  status = 2
  if (pitch < 1 .or. levels < 0 .or. first < 1 .or. first > pitch + 1 .or. last < first - 1 .or. last > pitch) return
  if (size(output) /= pitch) return
  if (last < first) then
    status = 0; return
  end if
  bits = transfer(gravity, bits)
  if (bits <= 0_int64 .or. bits >= int(z'7ff0000000000000', int64)) return
  if (levels > 0) then
    if (.not. present(pressure_depth) .or. .not. present(ozone)) return
    if (size(pressure_depth, 1) /= pitch .or. size(pressure_depth, 2) /= levels) return
    if (size(ozone, 1) /= pitch .or. size(ozone, 2) /= levels) return
  end if
  inverse_gravity = 1.0_real64/gravity
  do column = first, last
    output(column) = 0.0_real64
  end do
  do level = 1, levels
    do column = first, last
      term = ozone(column, level)*pressure_depth(column, level)
      term = term*inverse_gravity
      output(column) = output(column) + term
    end do
  end do
  status = 0
  end function
end module
