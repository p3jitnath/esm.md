!> Admit an absent optional dynamic_namespace file in the current directory.
module forecast_default_field_namespace
  use iso_c_binding, only: c_int, c_char, c_null_char, c_ptr, c_f_pointer
  implicit none
  interface
    function faccessat(dir, path, mode, flags) bind(C, name="faccessat") result(value)
      import c_int, c_char
      integer(c_int), value :: dir, mode, flags
      character(c_char), intent(in) :: path(*)
      integer(c_int) :: value
    end function
    function errno_location() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  integer(c_int) function require_default_field_namespace(count) result(status)
    integer(c_int), intent(inout) :: count
    integer(c_int), pointer, volatile :: error
    integer(c_int) :: saved, result_value, observed
    call c_f_pointer(errno_location(), error)
    saved = error
    do
      result_value = faccessat(-100_c_int, 'dynamic_namespace'//c_null_char, 0_c_int, 0_c_int)
      observed = error
      if (result_value /= -1 .or. observed /= 4) exit
    end do
    status = 2
    if (result_value == -1 .and. observed == 2) then
      count = 0
      status = 0
    end if
    error = saved
  end function
end module
