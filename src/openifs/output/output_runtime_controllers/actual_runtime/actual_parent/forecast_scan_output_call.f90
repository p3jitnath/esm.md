!> Invoke the own output stage at the original SCAN2M position.
module forecast_scan_output_call
  use iso_fortran_env, only: int8, int32, int64, real64
  use forecast_fullpos_state_types, only: native_fullpos_state, native_fullpos_data
  use forecast_output_controller, only: native_fullpos_driver_context, execute_fullpos_driver
  use forecast_output_request_types, only: increment_output_counter
  use yomhook, only: dr_hook
  use runtime_output_field_gather_port, only: agree_output_status
  implicit none
  private
  public :: native_scan_output_context, scan_selected_output_call
  !> fields and buffer are genuine optional TFPOS/TFPDATA replacements.
  !! They are not the temporary TFPFIELDS request or FPOSBUF leaf.
  !! Root binds physical_count/codes to the actual persistent NFPPHY/MFPPHY
  !! owners. Their values and driver inputs are unread on the absence branch.
  !! The caller admits the same optional-presence branch on every live rank.
  type :: native_scan_output_context
    type(native_fullpos_state), pointer :: fields => null()
    type(native_fullpos_data), pointer :: buffer => null()
    type(native_fullpos_driver_context) :: driver
    integer(int32), pointer :: physical_count => null(), physical_codes(:) => null()
    integer(int64) :: calls = 0
  end type
contains
  !> Always enter this function from SCAN2M, including no-output forecasts.
  !! If either optional owner is absent, only the observation count changes.
  !! Active execution requires the same canonical MODEL/FIELDS/SP/surface
  !! owners used by SCAN2M and invokes the complete own Fullpos controller.
  integer(int32) function scan_selected_output_call(context) result(status)
    type(native_scan_output_context), intent(inout) :: context
    integer(int8), allocatable :: token(:)
    integer :: allocation_status
    integer(int32) :: local_status
    real(real64) :: hook_handle
    status = 0
    if (.not. associated(context%fields) .or. .not. associated(context%buffer)) then
      call increment_output_counter(context%calls)
      return
    end if
    local_status = 2
    if (associated(context%driver%common) .and. associated(context%physical_count) .and. &
        associated(context%physical_codes)) then
      if (.not. context%driver%common%lfppacking .and. .not. context%driver%cumulative_flux_active) then
        if (context%physical_count >= 0 .and. context%physical_count <= size(context%physical_codes)) local_status = 0
      end if
    end if
    call agree_output_status(context%driver%actual_writer%distribution, local_status, status)
    if (status /= 0) return
    call gstats(30, 0)
    allocate (token(1), stat=allocation_status)
    local_status = 0
    if (allocation_status /= 0) local_status = 1
    call agree_output_status(context%driver%actual_writer%distribution, local_status, status)
    if (status /= 0) then
      if (allocated(token)) deallocate (token)
      call gstats(30, 1)
      return
    end if
    if (context%driver%hook_enabled) then
      call dr_hook('SP2GPMCUF', 0, hook_handle)
      call dr_hook('SP2GPMCUF', 1, hook_handle)
    end if
    status = execute_fullpos_driver(context%driver, context%fields, context%buffer, 1_int32, .true., .false., &
                                    context%physical_count, context%physical_codes)
    deallocate (token)
    call gstats(30, 1)
    if (status == 0) call increment_output_counter(context%calls)
  end function
end module
