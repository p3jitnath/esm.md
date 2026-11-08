!> Initial STEPX diagnostics retain their public profiling service calls.
module forecast_initial_step_diagnostics
  use iso_fortran_env, only: int32, real64
  use yomhook, only: lhook, dr_hook
  implicit none
  private
  public :: run_initial_step_diagnostics
contains
  !> Admit the two inactive source accumulated-diagnostic switches.
 !! FLAGS is read-only, with the first and second tested source switches in
 !! that order. The public hook control is read separately at entry and exit.
 !! Native status2 replaces the old unsupported-branch process trap.
  integer(int32) function run_initial_step_diagnostics(flags) result(status)
    logical, intent(in) :: flags(2)
    real(real64) :: handle
    integer(int32) :: hook_bits, j
    status = 2
    do j = 1, 2
      if (transfer(flags(j), 0_int32) /= 0) return
    end do
    hook_bits = transfer(lhook, 0_int32)
    if (hook_bits < 0 .or. hook_bits > 1) return
    if (hook_bits == 1) call dr_hook('STEPX', 0, handle)
    hook_bits = transfer(lhook, 0_int32)
    if (hook_bits < 0 .or. hook_bits > 1) return
    if (hook_bits == 1) call dr_hook('STEPX', 1, handle)
    status = 0
  end function
end module forecast_initial_step_diagnostics
