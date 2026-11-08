!> Complete selected inactive CPG_END caller.
module forecast_grid_point_end_caller
  use iso_fortran_env, only: int32, int64, real64
  use md2asm_transform_profile_policy, only: transform_profile_policy, transform_profile_event, increment_source_counter
  implicit none
  private
  public :: native_grid_end_controls, cpg_end
  type :: native_grid_end_controls
    logical :: lagphy = .false., ltrajps = .false., lmse = .false.
    integer(int32) :: ngpar = 0_int32
    real(real64) :: rstret = 0.0_real64
  end type
contains
!> Admit source-inactive final grid work without modifying numerical owners.
!! CONTROLS, LDTENC and LDLDIAB are read-only native model controls. RSTRET is
!! the dimensionless stretch factor and must have the exact +1.0 bit pattern.
!! COUNTER is a borrowed INT64 word. STATUS is 0 on success or 2 before hooks
!! or counter mutation on refusal. PROFILE optionally enables real FIAT.
!! No current-iteration value, field array or optional trajectory is consumed
!! by this selected body; the caller keeps these complete owners unchanged.
  subroutine cpg_end(controls, ldtenc, ldldiab, counter, status, profile)
    type(native_grid_end_controls), intent(in) :: controls
    logical, intent(in) :: ldtenc, ldldiab
    integer(int64), intent(inout) :: counter
    integer(int32), intent(out) :: status
    type(transform_profile_policy), intent(in), optional :: profile
    real(real64) :: hook_handle
    status = 2_int32
    if (.not. controls%lagphy) return
    if (controls%ltrajps) return
    if (controls%lmse) return
    if (controls%ngpar /= 0_int32) return
    if (ldtenc) return
    if (ldldiab) return
    if (transfer(controls%rstret, 0_int64) /= int(z'3ff0000000000000', int64)) return
    call transform_profile_event('CPG_END', 0_int32, hook_handle, profile)
    call transform_profile_event('CPG_END', 1_int32, hook_handle, profile)
    call increment_source_counter(counter)
    status = 0_int32
  end subroutine
end module
