!> Preserve floating-point status and the operating-system error number.
module forecast_lifetime_status
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  implicit none
  interface
    function lifetime_errno_address() bind(C, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  subroutine save_lifetime_status(flags, error)
    type(ieee_status_type), intent(out) :: flags
    integer(c_int), intent(out) :: error
    integer(c_int), pointer, volatile :: value
    call c_f_pointer(lifetime_errno_address(), value)
    error = value
    call ieee_get_status(flags)
  end subroutine
  subroutine restore_lifetime_status(flags, error)
    type(ieee_status_type), intent(in) :: flags
    integer(c_int), intent(in) :: error
    integer(c_int), pointer, volatile :: value
    call c_f_pointer(lifetime_errno_address(), value)
    call ieee_set_status(flags)
    value = error
  end subroutine
end module
