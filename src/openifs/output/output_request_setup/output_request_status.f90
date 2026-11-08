!> Preserve the caller's IEEE status and C error value across storage services.
!! The caller establishes nearest rounding and gradual underflow once before use.
module forecast_output_request_status
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  implicit none
  private
  public :: save_output_status, restore_output_status, ieee_status_type, c_int
  interface
    function output_errno_address() bind(c, name='__errno_location') result(address)
      import :: c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  subroutine save_output_status(saved, error_slot, error_before)
    type(ieee_status_type), intent(out) :: saved
    integer(c_int), pointer, volatile, intent(out) :: error_slot
    integer(c_int), intent(out) :: error_before
    call c_f_pointer(output_errno_address(), error_slot)
    error_before = error_slot
    call ieee_get_status(saved)
  end subroutine
  subroutine restore_output_status(saved, error_slot, error_before)
    type(ieee_status_type), intent(in) :: saved
    integer(c_int), pointer, volatile, intent(inout) :: error_slot
    integer(c_int), intent(in) :: error_before
    call ieee_set_status(saved)
    error_slot = error_before
  end subroutine
end module forecast_output_request_status
