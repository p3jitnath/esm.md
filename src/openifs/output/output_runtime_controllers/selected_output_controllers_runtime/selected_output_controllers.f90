!> Port the selected IOPACK and WRMLPP call order with caller-owned controls.
!! This route has one process, configuration A, no limited area and no LTLEVOL output.
!! The public FIAT services retain their actual natural status and message lifetime.
module forecast_selected_output_controllers
  use iso_fortran_env, only: int32, real64
  use yomhook, only: dr_hook
  implicit none
  private
  public :: native_output_controller_policy, run_forecast_file_control, run_model_level_output_controller
  public :: run_runtime_forecast_file_control, run_runtime_model_level_output_controller
  type :: native_output_controller_policy
    integer(int32) :: nconf = 1, nproc = 1
    logical :: lelam = .false., larpegef = .false., lecfpos = .true., ltlevol = .false., hook_enabled = .false.
  end type
  interface
    subroutine gstats(tag, switch)
      import :: int32
      integer(int32), intent(in) :: tag, switch
    end subroutine
  end interface
contains
  !> Retain the complete empty WRMLPP source branch, including both profiling boundaries.
  integer(int32) function run_model_level_output_controller(policy, configuration) result(status)
    type(native_output_controller_policy), intent(in) :: policy
    character(*), intent(in) :: configuration
    real(real64) :: handle
    status = 2
    if (policy%nproc /= 1 .or. len(configuration) /= 1) return
    if (policy%larpegef .or. .not. policy%lecfpos .or. policy%ltlevol) return
    if (policy%hook_enabled) call dr_hook('WRMLPP', 0, handle)
    if (policy%hook_enabled) call dr_hook('WRMLPP', 1, handle)
    status = 0
  end function
  !> Keep source IOPACK profiling, GSTATS and child order for the selected A route.
  integer(int32) function run_forecast_file_control(policy, configuration) result(status)
    type(native_output_controller_policy), intent(in) :: policy
    character(*), intent(in) :: configuration
    real(real64) :: handle
    status = 2
    if (policy%nproc /= 1 .or. len(configuration) /= 1) return
    if (configuration /= 'A' .or. policy%nconf /= 1 .or. policy%lelam) return
    if (policy%hook_enabled) call dr_hook('IOPACK', 0, handle)
    call gstats(11_int32, 0_int32)
    status = run_model_level_output_controller(policy, configuration)
    if (status /= 0) return
    call gstats(11_int32, 1_int32)
    if (policy%hook_enabled) call dr_hook('IOPACK<A>', 1, handle)
    status = 0
  end function
  !> Keep the same public-service body for live process counts1:32.
  integer(int32) function run_runtime_model_level_output_controller(policy, configuration) result(status)
    type(native_output_controller_policy), intent(in) :: policy
    character(*), intent(in) :: configuration
    real(real64) :: handle
    status = 2
    if (policy%nproc < 1 .or. policy%nproc > 32 .or. len(configuration) /= 1) return
    if (policy%larpegef .or. .not. policy%lecfpos .or. policy%ltlevol) return
    if (policy%hook_enabled) call dr_hook('WRMLPP', 0, handle)
    if (policy%hook_enabled) call dr_hook('WRMLPP', 1, handle)
    status = 0
  end function
  !> Keep source IOPACK profiling, GSTATS and child order for the selected A route.
  integer(int32) function run_runtime_forecast_file_control(policy, configuration) result(status)
    type(native_output_controller_policy), intent(in) :: policy
    character(*), intent(in) :: configuration
    real(real64) :: handle
    status = 2
    if (policy%nproc < 1 .or. policy%nproc > 32 .or. len(configuration) /= 1) return
    if (configuration /= 'A' .or. policy%nconf /= 1 .or. policy%lelam) return
    if (policy%hook_enabled) call dr_hook('IOPACK', 0, handle)
    call gstats(11_int32, 0_int32)
    status = run_runtime_model_level_output_controller(policy, configuration)
    if (status /= 0) return
    call gstats(11_int32, 1_int32)
    if (policy%hook_enabled) call dr_hook('IOPACK<A>', 1, handle)
    status = 0
  end function
end module forecast_selected_output_controllers
