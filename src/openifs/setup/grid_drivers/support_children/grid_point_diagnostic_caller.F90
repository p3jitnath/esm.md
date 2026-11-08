!> Complete selected inactive CPG_DIA caller.
module forecast_grid_point_diagnostic_caller
  use iso_fortran_env, only: int32, int64, real64
  use md2asm_transform_profile_policy, only: transform_profile_policy, transform_profile_event, increment_source_counter
  implicit none
  private
  public :: native_grid_diagnostic_controls, cpg_dia
  type :: native_grid_diagnostic_controls
    logical :: lsddh = .false., lflexdia = .false., lagphy = .false., lsimph = .false., ldirclsmod = .false.
  end type
contains
!> Retain the guarded diagnostic route, its fourteen view hooks and counter.
!! CONTROLS and LDLDIAB are read-only native logical values from the live model.
!! COUNTER is a borrowed INT64 call count; no field or surface payload is used
!! on this selected inactive route. STATUS is 0 on success or 2 on refusal
!! before hooks or counter mutation. PROFILE optionally enables real FIAT.
!! The caller establishes nearest-even rounding and gradual underflow.
  subroutine cpg_dia(controls, ldldiab, counter, status, profile)
    type(native_grid_diagnostic_controls), intent(in) :: controls
    logical, intent(in) :: ldldiab
    integer(int64), intent(inout) :: counter
    integer(int32), intent(out) :: status
    type(transform_profile_policy), intent(in), optional :: profile
    real(real64) :: hook_handle, view_handle
    integer :: j
    status = 2_int32
    if (controls%lsddh) return
    if (controls%lflexdia) return
    if (.not. controls%lagphy) return
    if (controls%lsimph) return
    if (controls%ldirclsmod) return
    if (ldldiab) return
    call transform_profile_event('CPG_DIA', 0_int32, hook_handle, profile)
    do j = 1, 14
      call transform_profile_event('SC2PRG_MOD:SC2PRG', 0_int32, view_handle, profile)
      call transform_profile_event('SC2PRG_MOD:SC2PRG', 1_int32, view_handle, profile)
    end do
    call transform_profile_event('CPG_DIA', 1_int32, hook_handle, profile)
    call increment_source_counter(counter)
    status = 0_int32
  end subroutine
end module
