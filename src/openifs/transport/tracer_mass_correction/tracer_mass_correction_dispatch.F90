!> Complete selected and runtime TRMFIXERS dispatchers.
module forecast_tracer_mass_correction_dispatch
  use iso_fortran_env, only: int32, real64
  use forecast_tracer_mass_correction_types, only: tracer_mass_grid, tracer_mass_layout
  use grid_field_configuration_types_port, only: grid_field_configuration
  use forecast_tracer_mass_correction, only: qmfixer_selected, qmfixer_runtime
  use md2asm_transform_profile_policy, only: transform_profile_policy, transform_profile_event
  implicit none
  private
  public :: trmfixers_selected, trmfixers_runtime
contains
!> Dispatch the complete selected tracer correction with actual source flags.
!! All arguments and units match QMFIXER_SELECTED; CALL_SL is a native
!! read-only logical and must be true. The canonical GFL controls must select
!! LTRCMFIX/LTRCMFBC and no alternate fixer. Unsupported selection returns2
!! before hooks or writes; otherwise the owned child's status is returned.
  subroutine trmfixers_selected(grid, layout, gfl, call_sl, kl0, plscaw, pb1, pgmvs, pgmvt1s, pgfl, pgflt1, status, profile)
    type(tracer_mass_grid), intent(in) :: grid
    type(tracer_mass_layout), intent(in) :: layout
    type(grid_field_configuration), intent(in) :: gfl
    logical, intent(in) :: call_sl
    integer(int32), intent(in) :: kl0(:, :, 0:, :)
    real(real64), intent(in) :: plscaw(:, :, :, :), pgmvs(:, :, :), pgfl(:, :, :, :)
    real(real64), target, intent(in) :: pb1(:, :)
    real(real64), target, intent(inout) :: pgmvt1s(:, :, :)
    real(real64), intent(inout) :: pgflt1(:, :, :, :)
    integer(int32), intent(out) :: status
    type(transform_profile_policy), intent(in), optional :: profile
    real(real64) :: hook_handle
    status = 2_int32
    if (.not. route_selected(gfl, call_sl)) return
    call transform_profile_event('TRMFIXERS', 0_int32, hook_handle, profile)
    call qmfixer_selected(grid, layout, gfl, kl0, plscaw, pb1, pgmvs, pgmvt1s, pgfl, pgflt1, status, profile)
    call transform_profile_event('TRMFIXERS', 1_int32, hook_handle, profile)
  end subroutine
!> Dispatch live source dimensions with source profiling disabled.
!! The runtime public transform, communicator and ownership context are
!! explicit native metadata. No original dependency record or callback is used.
  subroutine trmfixers_runtime(grid, layout, gfl, call_sl, kl0, plscaw, pb1, pgmvs, pgmvt1s, pgfl, pgflt1, status)
    type(tracer_mass_grid), intent(in) :: grid
    type(tracer_mass_layout), intent(in) :: layout
    type(grid_field_configuration), intent(in) :: gfl
    logical, intent(in) :: call_sl
    integer(int32), intent(in) :: kl0(:, :, 0:, :)
    real(real64), intent(in) :: plscaw(:, :, :, :), pgmvs(:, :, :), pgfl(:, :, :, :)
    real(real64), target, intent(in) :: pb1(:, :)
    real(real64), target, intent(inout) :: pgmvt1s(:, :, :)
    real(real64), intent(inout) :: pgflt1(:, :, :, :)
    integer(int32), intent(out) :: status
    status = 2_int32
    if (.not. route_selected(gfl, call_sl)) return
    call qmfixer_runtime(grid, layout, gfl, kl0, plscaw, pb1, pgmvs, pgmvt1s, pgfl, pgflt1, status)
  end subroutine
  logical function route_selected(gfl, call_sl) result(selected)
    type(grid_field_configuration), intent(in) :: gfl
    logical, intent(in) :: call_sl
    selected = .false.
    if (.not. call_sl) return
    if (gfl%settings%ltrcmfix /= 1 .or. gfl%settings%ltrcmfbc /= 1) return
    if (gfl%settings%ladvnegfix /= 0 .or. gfl%settings%ltrcmfpr /= 0) return
    if (gfl%settings%ltrcmfmg /= 0 .or. gfl%settings%ltrcmfp /= 0) return
    selected = .true.
  end function
end module
