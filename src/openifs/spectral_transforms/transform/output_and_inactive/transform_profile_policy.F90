!> Public FIAT profiling and caller-owned source counters.
module md2asm_transform_profile_policy
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_char, c_int32_t, c_double, c_size_t
  implicit none
  private
  public :: transform_profile_policy, transform_profile_event, increment_source_counter
  type :: transform_profile_policy
    logical :: enabled = .false.
  end type
  interface
    subroutine fiat_dr_hook(label, phase, handle, label_bytes) bind(C, name="__yomhook_MOD_dr_hook_default8")
      import :: c_char, c_int32_t, c_double, c_size_t
      character(kind=c_char), intent(in) :: label(*)
      integer(c_int32_t), intent(in) :: phase
      real(c_double), intent(inout) :: handle
      integer(c_size_t), value :: label_bytes
    end subroutine
  end interface
contains
!> Issue a real public FIAT hook when the caller enables this optional policy.
!! LABEL names the source routine, PHASE is 0 on entry or 1 on exit, and
!! HANDLE is the same caller-owned REAL64 value in the paired calls.
!! An absent or disabled policy has no provider call or floating-point work.
  subroutine transform_profile_event(label, phase, handle, policy)
    character(len=*), intent(in) :: label
    integer(int32), intent(in) :: phase
    real(real64), intent(inout) :: handle
    type(transform_profile_policy), intent(in), optional :: policy
    if (.not. present(policy)) return
    if (.not. policy%enabled) return
    call fiat_dr_hook(label, phase, handle, int(len(label), c_size_t))
  end subroutine
!> Add one to an INT64 source counter with the source word's wrap rule.
  subroutine increment_source_counter(counter)
    integer(int64), intent(inout) :: counter
    if (counter == huge(counter)) then
      counter = -huge(counter) - 1_int64
    else
      counter = counter + 1_int64
    end if
  end subroutine
end module
