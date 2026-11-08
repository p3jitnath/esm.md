!> Read public floating-point control and the actual public math-library mode.
!! No numerical body or private model layout is supplied by this support module.
module forecast_private_math_environment
  use iso_c_binding, only: c_int, c_char, c_ptr, c_null_ptr, c_null_char, c_associated, c_f_pointer
  use iso_fortran_env, only: int32, real64, int64
#ifndef MD2ASM_PUBLIC_AARCH64_FENV_ABI
  use, intrinsic :: ieee_arithmetic
  use, intrinsic :: ieee_exceptions
#endif
  implicit none
  private
  public :: require_private_math_environment, get_private_math_library_mode, set_private_math_range_error
  interface
    subroutine public_abort() bind(C, name='abort')
    end subroutine
#ifdef MD2ASM_PUBLIC_AARCH64_FENV_ABI
    integer(c_int) function public_get_control_modes(mode) bind(C, name='fegetmode')
      import :: c_int
      integer(c_int), intent(out) :: mode
    end function
#endif
    function public_errno_location() bind(C, name='__errno_location') result(address)
      import :: c_ptr
      type(c_ptr) :: address
    end function
    function public_symbol_address(handle, name) bind(C, name='dlsym') result(address)
      import :: c_ptr, c_char
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: name(*)
      type(c_ptr) :: address
    end function
#ifdef MD2ASM_PUBLIC_MATH_POLICY_VERSION
    function public_versioned_symbol_address(handle, name, version) bind(C, name='dlvsym') result(address)
      import :: c_ptr, c_char
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: name(*), version(*)
      type(c_ptr) :: address
    end function
#endif
  end interface
contains
!> Require the source control modes without changing incoming status flags.
!! On Arm Linux, public femode_t is an unsigned32-bit integer and fegetmode
!! reads the complete control word. The build explicitly selects this public
!! ABI because GNU Fortran does not predefine the C architecture macro. Other targets use portable IEEE mode
!! queries until their public control-word ABI has separate qualification.
  subroutine require_private_math_environment()
#ifdef MD2ASM_PUBLIC_AARCH64_FENV_ABI
    integer(c_int) :: mode, code
    mode = -1_c_int
    code = public_get_control_modes(mode)
    if (code /= 0_c_int) call public_abort()
    if (mode /= 0_c_int) call public_abort()
#else
    type(ieee_round_type) :: rounding
    logical :: gradual, halting
    integer :: index
    real(real64), volatile :: normal, half_value, subnormal
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) call public_abort()
    if (ieee_support_underflow_control(0.0_real64)) then
      call ieee_get_underflow_mode(gradual)
      if (.not. gradual) call public_abort()
    else
      normal = tiny(1.0_real64)
      half_value = 0.5_real64
      subnormal = normal*half_value
      if (transfer(subnormal, 0_int64) /= int(z'0008000000000000', int64)) call public_abort()
    end if
    do index = 1, size(ieee_all)
      if (.not. ieee_support_halting(ieee_all(index))) cycle
      call ieee_get_halting_mode(ieee_all(index), halting)
      if (halting) call public_abort()
    end do
#endif
  end subroutine
!> Read _LIB_VERSION only when the original both-zero direction branch needs it.
!! The public loader resolves data, not a numerical function. Keep errno
!! unchanged across lookup, then borrow the actual integer owner immediately.
  integer(c_int) function get_private_math_library_mode() result(mode)
    integer(c_int), pointer :: error_word, library_mode
    integer(c_int) :: saved_errno
    type(c_ptr) :: address
    call c_f_pointer(public_errno_location(), error_word)
    saved_errno = error_word
#ifdef MD2ASM_PUBLIC_MATH_POLICY_VERSION
    address = public_versioned_symbol_address(c_null_ptr, '_LIB_VERSION'//c_null_char, &
                                              MD2ASM_PUBLIC_MATH_POLICY_VERSION//c_null_char)
#else
    address = public_symbol_address(c_null_ptr, '_LIB_VERSION'//c_null_char)
#endif
    error_word = saved_errno
    if (.not. c_associated(address)) call public_abort()
    call c_f_pointer(address, library_mode)
    mode = library_mode
  end function
!> Set the exact source ERANGE code34 only for a nonzero ratio rounded to zero.
  subroutine set_private_math_range_error()
    integer(c_int), pointer :: error_word
    call c_f_pointer(public_errno_location(), error_word)
    error_word = 34_c_int
  end subroutine
end module forecast_private_math_environment
