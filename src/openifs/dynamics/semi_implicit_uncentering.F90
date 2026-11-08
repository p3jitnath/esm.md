!> Set the selected hydrostatic two-time-level semi-implicit time factors.
!! A small uncentering weight changes the implicit time average.
module md2asm_semi_implicit_uncentering
  use iso_fortran_env, only: int32, real64
  use ieee_arithmetic, only: ieee_is_finite
  use md2asm_semi_implicit_mode_storage, only: semi_implicit_environment_supported
  implicit none
  private
  public :: semi_implicit_time_factors, initialize_semi_implicit_uncentering
  type :: semi_implicit_time_factors
    real(real64) :: explicit_weight = 0.0_real64, implicit_weight = 0.0_real64
    real(real64) :: full_factor = 0.0_real64, half_factor = 0.0_real64
  end type
contains
  !> Initialize factors from the first half-level pressure(Pa) and dimensionless BETADT.
  !! The route is ECMWF three-dimensional, hydrostatic, semi-Lagrangian and2TL.
  !! Other branches refuse before mutating the caller-owned output record.
  !! Negative zero pressure and time retain their original comparison behaviour.
  subroutine initialize_semi_implicit_uncentering(first_half_pressure, beta_time, &
                                                  finite_elements, ecmwf, three_dimensional, hydrostatic, two_time_levels, &
                                                  semi_lagrangian, factors, status)
    real(real64), intent(in) :: first_half_pressure, beta_time
    logical, intent(in) :: finite_elements, ecmwf, three_dimensional, hydrostatic
    logical, intent(in) :: two_time_levels, semi_lagrangian
    type(semi_implicit_time_factors), intent(inout) :: factors
    integer(int32), intent(out) :: status
    real(real64) :: pressure, explicit_weight, implicit_weight, value, half_value
    status = 2
    if (.not. ecmwf .or. .not. three_dimensional .or. .not. hydrostatic) return
    if (.not. two_time_levels .or. .not. semi_lagrangian) return
    if (.not. semi_implicit_environment_supported()) return
    if (.not. ieee_is_finite(first_half_pressure) .or. .not. ieee_is_finite(beta_time)) return
    if (first_half_pressure < 0.0_real64) return
    pressure = first_half_pressure*0.5_real64
    explicit_weight = 0.0_real64
    implicit_weight = 0.05_real64
    if (pressure < 100.0_real64 .or. finite_elements) implicit_weight = 0.0_real64
    value = 1.0_real64 + explicit_weight
    value = value*beta_time
    half_value = 1.0_real64 + implicit_weight
    value = value*half_value
    half_value = value*0.5_real64
    factors%explicit_weight = explicit_weight
    factors%implicit_weight = implicit_weight
    factors%full_factor = value
    factors%half_factor = half_value
    status = 0
  end subroutine
end module
