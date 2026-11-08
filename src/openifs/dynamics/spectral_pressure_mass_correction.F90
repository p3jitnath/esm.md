!> Structured port of the generated SPCMASCOR leaf.
!! The supplied mass increment is dimensionless.
!! The caller retains the complete scheduling condition and independent owners.
module md2asm_spectral_pressure_mass_correction
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: ieee_arithmetic
  implicit none
  private
  public :: apply_spectral_pressure_mass_correction
contains
  !> Subtract the supplied increment from exactly one constant coefficient.
  !! nasm0 has zero origin, at most8192 entries, and one-based pressure indices.
  !! pressure is a separate dense FP64 owner with1..134217728 elements.
  !! status=2 preserves pressure; status=0 changes only pressure(nasm0(0)).
  !! NaNs, infinities and signed zeros retain the subtraction's natural status.
  subroutine apply_spectral_pressure_mass_correction(nasm0, mass_increment, pressure, status)
    integer(int32), intent(in) :: nasm0(0:)
    real(real64), intent(in) :: mass_increment
    real(real64), intent(inout) :: pressure(:)
    integer(int32), intent(out) :: status
    type(ieee_round_type) :: rounding
    logical :: gradual
    real(real64), volatile :: minimum_normal, half_value, subnormal_probe
    integer :: coefficient
    real(real64) :: value
    status = 2_int32
    if (storage_size(0.0_real64) /= 64 .or. storage_size(0_int32) /= 32) return
    if (size(nasm0) < 1 .or. size(nasm0) > 8192) return
    if (size(pressure) < 1 .or. size(pressure) > 134217728) return
    if (.not. is_contiguous(nasm0) .or. .not. is_contiguous(pressure)) return
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) return
    if (ieee_support_underflow_control(0.0_real64)) then
      call ieee_get_underflow_mode(gradual)
      if (.not. gradual) return
    else
      minimum_normal = tiny(0.0_real64)
      half_value = 0.5_real64
      subnormal_probe = minimum_normal*half_value
      if (transfer(subnormal_probe, 0_int64) /= ibset(0_int64, 51)) return
    end if
    coefficient = nasm0(0)
    if (coefficient < 1 .or. coefficient > size(pressure)) return
    value = pressure(coefficient) - mass_increment
    pressure(coefficient) = value
    status = 0_int32
  end subroutine apply_spectral_pressure_mass_correction
end module md2asm_spectral_pressure_mass_correction
