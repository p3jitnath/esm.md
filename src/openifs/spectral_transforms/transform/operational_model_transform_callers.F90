!> Complete operational model wrapper entries using live native dimensions.
module md2asm_operational_model_transforms
  use iso_fortran_env, only: int32
  use md2asm_model_transform_callers, only: model_transform_context, model_transform_state, model_inverse_modes, &
                                            transform_inverse_model, transform_direct_model
  implicit none
  private
  public :: operational_inverse_model_transform, operational_direct_model_transform
contains
!> Reconstruct the admitted137-level operational current-state views.
!! Context and arrays come from live geometry and field owners. The block pitch,
!! local coefficient count, local spectral levels and final partial block are
!! derived from those owners. Scalar pressure keeps its one-row view on every rank.
  subroutine operational_inverse_model_transform(c, s, modes, status)
    type(model_transform_context), intent(in) :: c
    type(model_transform_state), intent(inout) :: s
    type(model_inverse_modes), intent(in) :: modes
    integer(int32), intent(out) :: status
    status = 2
    if (c%global_levels /= 137 .or. c%transform%latitude_longitude) return
    if (c%pressure_gradients .or. c%gradient_volume_fields) return
    if (c%current_wind_fields /= 4 .or. c%current_volume_fields /= 7 .or. c%current_surface_fields /= 3) return
    if (c%previous_volume_fields /= 3 .or. c%previous_surface_fields /= 1) return
    if (modes%wind_derivatives .or. .not. modes%derivatives .or. modes%friction) return
    call transform_inverse_model(c, s, modes, status, model_events=.false.)
  end subroutine
!> Analyse the previous-time operational winds,temperature and surface pressure.
!! Only the source pressure-owning vertical group copies the temporary result.
!! Source-inactive fields,padding and every unrelated state owner remain unchanged.
  subroutine operational_direct_model_transform(c, s, configuration, status)
    type(model_transform_context), intent(in) :: c
    type(model_transform_state), intent(inout) :: s
    character(len=1), intent(in) :: configuration
    integer(int32), intent(out) :: status
    status = 2
    if (c%global_levels /= 137 .or. c%transform%latitude_longitude) return
    if (c%pressure_gradients .or. c%gradient_volume_fields) return
    if (c%current_wind_fields /= 4 .or. c%current_volume_fields /= 7 .or. c%current_surface_fields /= 3) return
    if (c%previous_volume_fields /= 3 .or. c%previous_surface_fields /= 1) return
    if (configuration /= 'A') return
    call transform_direct_model(c, s, configuration, status, model_events=.false.)
  end subroutine
end module
