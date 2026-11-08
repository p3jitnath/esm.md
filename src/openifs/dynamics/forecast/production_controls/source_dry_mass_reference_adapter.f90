!> Keep the original CORMASSDRY norm call free of a model-facing wrapper flag.
module forecast_source_dry_mass_reference
  use iso_fortran_env, only: int32, int64, real64
  use forecast_geometry_state_types, only: native_geometry_state
  use md2asm_spectral_transposes, only: spectral_transpose_layout
  use forecast_runtime_dry_mass_reference, only: native_dry_mass_reference, calculate_runtime_dry_mass_reference
  implicit none
  private
  public :: native_dry_mass_reference, calculate_source_dry_mass_reference
contains
  !> Compute source mass values through the unchanged native provider.
 !! Geometry and layout are readonly canonical owners. Spectral pressure has
 !! C words on the last vertical set and one dummy word elsewhere; map_factor
 !! has Q local points. Budget is bytes. State changes only on success.
 !! The child checks genuine geometry/layout readiness. Its internal FALSE
 !! word admits the implemented extra-mode branch; it is not a model control.
  integer(int32) function calculate_source_dry_mass_reference(geometry, layout, spectral_pressure, map_factor, step, &
                                                              ldgpmascor, lmasdry, budget, state) result(status)
    type(native_geometry_state), intent(in) :: geometry
    type(spectral_transpose_layout), intent(in) :: layout
    real(real64), target, contiguous, intent(in) :: spectral_pressure(:)
    real(real64), contiguous, intent(in) :: map_factor(:)
    integer(int32), intent(in) :: step
    logical, intent(in) :: ldgpmascor, lmasdry
    integer(int64), intent(in) :: budget
    type(native_dry_mass_reference), intent(inout) :: state
    status = calculate_runtime_dry_mass_reference(geometry, layout, spectral_pressure, map_factor, step, &
                                                  ldgpmascor, lmasdry, .false., budget, state)
  end function
end module
