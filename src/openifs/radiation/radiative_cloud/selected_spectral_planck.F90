!> Selected two-band Planck lookup with explicit native table ownership.
module md2asm_selected_spectral_planck
  use iso_fortran_env, only: int32, int64, real64
  use ieee_arithmetic, only: ieee_is_finite
  use yoe_spectral_planck, only: tspectralplanck
  use physical_constant_setup_port, only: forecast_physical_constants
  implicit none
  private
  public :: calculate_selected_spectral_planck
contains
!> Convert produced spectral fractions to thermal irradiance in W/m2.
!! TABLE is the unchanged selected150:350K table(2,201). Temperature(:)
!! contains kelvin; output(:,2) stores band1thenband2. Only first:last changes.
!! Input arrays and table are separate from output and remain unchanged.
!! Status2 refuses metadata or the original unsafe half-row interval.
  subroutine calculate_selected_spectral_planck(table, temperature, constants, first, last, output, status)
    type(tspectralplanck), intent(in) :: table
    real(real64), intent(in) :: temperature(:)
    type(forecast_physical_constants), intent(in) :: constants
    integer(int32), intent(in) :: first, last
    real(real64), intent(inout) :: output(:, :)
    integer(int32), intent(out) :: status
    integer :: i, row
    real(real64) :: upper, t, fraction, rounded, a, c, d, e, total, t2, t4
    status = 2
    if (size(temperature) < 1 .or. size(temperature) > 4096) return
    if (first < 1 .or. last < first .or. last > size(temperature)) return
    if (size(output, 1) < size(temperature) .or. size(output, 2) < 2) return
    if (table%nintervals /= 2 .or. table%ntemps /= 201) return
    if (transfer(table%temp1, 0_int64) /= int(z'4062C00000000000', int64)) return
    if (transfer(table%dtemp, 0_int64) /= int(z'3FF0000000000000', int64)) return
    if (.not. allocated(table%planck_lut)) return
    if (size(table%planck_lut, 1) /= 2 .or. size(table%planck_lut, 2) /= 201) return
    if (.not. ieee_is_finite(constants%rsigma) .or. constants%rsigma <= 0.0_real64) return
    do i = first, last
      t = temperature(i)
      if (.not. ieee_is_finite(t) .or. t <= 0.0_real64 .or. t > 1000.0_real64) return
      if (t >= 349.5_real64 .and. t < 350.0_real64) return
    end do
    upper = table%dtemp*200.0_real64; upper = table%temp1 + upper
    do i = first, last
      t = temperature(i)
      if (t <= table%temp1) then
        row = 1; fraction = 0.0_real64
      else
        fraction = t - table%temp1; fraction = fraction/table%dtemp; fraction = 1.0_real64 + fraction
        if (t >= upper) then
          row = 200; rounded = 200.0_real64
        else
          row = nint(fraction); rounded = real(row, real64)
        end if
        fraction = fraction - rounded
      end if
      a = table%planck_lut(1, row); c = table%planck_lut(2, row)
      d = table%planck_lut(1, row + 1) - a; e = table%planck_lut(2, row + 1) - c
      d = fraction*d; e = fraction*e; a = a + d; c = c + e
      total = 0.0_real64 + a; total = total + c
      t2 = t*t; t4 = t2*t2
      a = a*constants%rsigma; a = a*t4; a = a/total
      c = c*constants%rsigma; c = c*t4; c = c/total
      output(i, 1) = a; output(i, 2) = c
    end do
    status = 0
  end subroutine
end module
