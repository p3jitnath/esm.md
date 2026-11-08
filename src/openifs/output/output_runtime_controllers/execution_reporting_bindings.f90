!> Bind one actual caller-owned reporting context with explicit native lifetime.
!! The root owns this binding. It contains no original module alias or hidden context.
module forecast_execution_reporting_bindings
  use iso_fortran_env, only: int32, real64
  use forecast_execution_reporting
  implicit none
  private
  public :: native_execution_reporting_binding, attach_execution_reporting_context
  public :: detach_execution_reporting_context, logdis, opdis
  type :: native_execution_reporting_binding
    type(native_execution_reporting_context), pointer :: context => null()
  end type
contains
  integer(int32) function attach_execution_reporting_context(binding, context) result(status)
    type(native_execution_reporting_binding), intent(inout) :: binding
    type(native_execution_reporting_context), target, intent(in) :: context
    status = admit_reporting_context(context, .true.)
    if (status /= 0) return
    if (associated(binding%context)) then
      if (.not. associated(binding%context, context)) then
        status = 2
        return
      end if
    end if
    binding%context => context
  end function
  !> Forward the original six scalar inputs; optional CDSTEP must remain absent.
  integer(int32)function logdis(binding,step,model_seconds,cpu_first,cpu_second,timer_enabled,date_enabled,cdstep)result(status)
  type(native_execution_reporting_binding), intent(in) :: binding
  integer(int32), intent(in) :: step
  real(real64), intent(in) :: model_seconds, cpu_first, cpu_second
  logical, intent(in) :: timer_enabled, date_enabled
  character(*), intent(in), optional :: cdstep
  status = 2
  if (present(cdstep) .or. .not. associated(binding%context)) return
  status = report_execution_progress(binding%context, step, model_seconds, cpu_first, cpu_second, timer_enabled, date_enabled)
  end function
  !> Forward complete nine-byte configuration and actual caller text to OPDIS.
  integer(int32) function opdis(binding, configuration, caller, cpu, pv_cpu, real_time, accumulated_cpu, &
                                accumulated_real, step, nonhydrostatic) result(status)
    type(native_execution_reporting_binding), intent(inout) :: binding
    character(9), intent(in) :: configuration
    character(*), intent(in) :: caller
    real(real64), intent(in) :: cpu, pv_cpu, real_time, accumulated_cpu, accumulated_real
    integer(int32), intent(in) :: step
    logical, intent(in) :: nonhydrostatic
    status = 2
    if (.not. associated(binding%context)) return
    status = report_execution_status(binding%context, configuration, caller, cpu, pv_cpu, real_time, &
                                     accumulated_cpu, accumulated_real, step, nonhydrostatic)
  end function
  integer(int32) function detach_execution_reporting_context(binding, context) result(status)
    type(native_execution_reporting_binding), intent(inout) :: binding
    type(native_execution_reporting_context), target, intent(inout) :: context
    status = 2
    if (.not. associated(binding%context, context)) return
    status = close_execution_reporting_status(context)
    if (status == 0) nullify (binding%context)
  end function
end module forecast_execution_reporting_bindings
