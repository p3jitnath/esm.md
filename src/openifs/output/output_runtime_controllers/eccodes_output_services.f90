!> Declare only official ecCodes C file-format services.
module forecast_eccodes_output_services
  use iso_c_binding
  implicit none
  private
  public :: codes_clone, codes_delete, codes_sample, codes_message, codes_message_copy
  public :: codes_get_long, codes_get_string, codes_set_double_array
  public :: set_grib_long, set_grib_double, set_grib_string, codes_samples_path, codes_default_context
  interface
    function codes_clone(handle) bind(c, name='codes_handle_clone') result(copy)
      import c_ptr
      type(c_ptr), value :: handle
      type(c_ptr) :: copy
    end function
    function codes_delete(handle) bind(c, name='codes_handle_delete') result(status)
      import c_ptr, c_int
      type(c_ptr), value :: handle
      integer(c_int) :: status
    end function
    function codes_sample(context, name) bind(c, name='codes_handle_new_from_samples') result(handle)
      import c_ptr, c_char
      type(c_ptr), value :: context
      character(c_char), intent(in) :: name(*)
      type(c_ptr) :: handle
    end function
    function codes_message(handle, message, bytes) bind(c, name='codes_get_message') result(status)
      import c_ptr, c_size_t, c_int
      type(c_ptr), value :: handle
      type(c_ptr), intent(out) :: message
      integer(c_size_t), intent(out) :: bytes
      integer(c_int) :: status
    end function
    function codes_message_copy(context, message, bytes) bind(c, name='codes_handle_new_from_message_copy') result(handle)
      import c_ptr, c_size_t
      type(c_ptr), value :: context, message
      integer(c_size_t), value :: bytes
      type(c_ptr) :: handle
    end function
    function codes_get_long(handle, key, value) bind(c, name='codes_get_long') result(status)
      import c_ptr, c_char, c_long, c_int
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      integer(c_long), intent(out) :: value
      integer(c_int) :: status
    end function
    function codes_get_string(handle, key, value, bytes) bind(c, name='codes_get_string') result(status)
      import c_ptr, c_char, c_size_t, c_int
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      character(c_char), intent(out) :: value(*)
      integer(c_size_t), intent(inout) :: bytes
      integer(c_int) :: status
    end function
    function codes_set_long(handle, key, value) bind(c, name='codes_set_long') result(status)
      import c_ptr, c_char, c_long, c_int
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      integer(c_long), value :: value
      integer(c_int) :: status
    end function
    function codes_set_double(handle, key, value) bind(c, name='codes_set_double') result(status)
      import c_ptr, c_char, c_double, c_int
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      real(c_double), value :: value
      integer(c_int) :: status
    end function
    function codes_set_string(handle, key, value, bytes) bind(c, name='codes_set_string') result(status)
      import c_ptr, c_char, c_size_t, c_int
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*), value(*)
      integer(c_size_t), intent(inout) :: bytes
      integer(c_int) :: status
    end function
    function codes_set_double_array(handle, key, value, count) bind(c, name='codes_set_double_array') result(status)
      import c_ptr, c_char, c_double, c_size_t, c_int
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      real(c_double), intent(in) :: value(*)
      integer(c_size_t), value :: count
      integer(c_int) :: status
    end function
    subroutine codes_samples_path(context, path) bind(c, name='codes_context_set_samples_path')
      import c_ptr, c_char
      type(c_ptr), value :: context
      character(c_char), intent(in) :: path(*)
    end subroutine
    function codes_default_context() bind(c, name='codes_context_get_default') result(context)
      import c_ptr
      type(c_ptr) :: context
    end function
  end interface
contains
  !> Forward one exact source key and signed64-bit integer value.
  integer(c_int) function set_grib_long(handle, key, value) result(status)
    type(c_ptr), intent(in) :: handle
    character(*), intent(in) :: key
    integer(c_long), intent(in) :: value
    status = codes_set_long(handle, key//c_null_char, value)
  end function
  !> Forward one exact source key and FP64 value without arithmetic.
  integer(c_int) function set_grib_double(handle, key, value) result(status)
    type(c_ptr), intent(in) :: handle
    character(*), intent(in) :: key
    real(c_double), intent(in) :: value
    status = codes_set_double(handle, key//c_null_char, value)
  end function
  !> Supply the source string length, excluding its final C zero.
  integer(c_int) function set_grib_string(handle, key, value) result(status)
    type(c_ptr), intent(in) :: handle
    character(*), intent(in) :: key, value
    integer(c_size_t) :: bytes
    bytes = len(value, kind=c_size_t)
    status = codes_set_string(handle, key//c_null_char, value//c_null_char, bytes)
  end function
end module
