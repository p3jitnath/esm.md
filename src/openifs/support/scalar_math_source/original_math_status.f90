!> Public language-runtime status and explicit native mathematical counters.
!! The arithmetic modules are portable Fortran. The fenv record below follows
!! this target's public AArch64 GNU C fenv.h declaration, not a model byte layout.
module forecast_original_math_status
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_int, c_ptr, c_f_pointer
  implicit none
  private
  public :: native_math_counters, math_environment_ready, math_status_read, math_status_clear
  public :: commit_math_status, set_math_errno, add_counter, bump_math_counter
  public :: global_fast_calls, global_wide_calls, global_exp_calls, word_value, add_words, subtract_words
  public :: math_domain_exit
  type native_math_counters
    integer(int64) :: fast = 0_int64, wide = 0_int64, exponential = 0_int64
  end type
  type, bind(C) :: public_c_fenv
    integer(c_int) :: fpcr, fpsr
  end type
  integer(int64), target, save, bind(C, name='md2asm_product_sum_fast_calls') :: global_fast_calls = 0_int64
  integer(int64), target, save, bind(C, name='md2asm_product_sum_wide_calls') :: global_wide_calls = 0_int64
  integer(int64), target, save, bind(C, name='md2asm_exponential_native_calls_storage') :: global_exp_calls = 0_int64
  interface
    integer(c_int) function c_fegetenv(environment) bind(C, name='fegetenv')
      import :: c_int, public_c_fenv
      type(public_c_fenv), intent(out) :: environment
    end function
    integer(c_int) function c_fesetenv(environment) bind(C, name='fesetenv')
      import :: c_int, public_c_fenv
      type(public_c_fenv), intent(in) :: environment
    end function
    function c_errno_location() bind(C, name='__errno_location') result(address)
      import :: c_ptr
      type(c_ptr) :: address
    end function
    subroutine c_exit(code) bind(C, name='_exit')
      import :: c_int
      integer(c_int), value :: code
    end subroutine
  end interface
contains
  pure real(real64) function word_value(word) result(value)
    integer(int64), intent(in) :: word
    value = transfer(word, value)
  end function
  pure integer(int64) function add_words(a, b) result(value)
    integer(int64), intent(in) :: a, b
    integer(int64), parameter :: mask = int(z'FFFFFFFF', int64)
    integer(int64) :: lo, hi
    lo = iand(a, mask) + iand(b, mask)
    hi = iand(shiftr(a, 32) + shiftr(b, 32) + shiftr(lo, 32), mask)
    value = ior(iand(lo, mask), shiftl(hi, 32))
  end function
  pure integer(int64) function subtract_words(a, b) result(value)
    integer(int64), intent(in) :: a, b
    value = add_words(a, add_words(not(b), 1_int64))
  end function
  subroutine add_counter(counter, amount)
    integer(int64), intent(inout) :: counter
    integer(int64), intent(in) :: amount
    counter = add_words(counter, amount)
  end subroutine
  subroutine bump_math_counter(which, amount, counters)
    integer(int32), intent(in) :: which
    integer(int64), intent(in) :: amount
    type(native_math_counters), intent(inout), optional :: counters
    if (present(counters)) then
      select case (which)
      case (1); call add_counter(counters%fast, amount)
      case (2); call add_counter(counters%wide, amount)
      case (3); call add_counter(counters%exponential, amount)
      end select
    else
      select case (which)
      case (1); call add_counter(global_fast_calls, amount)
      case (2); call add_counter(global_wide_calls, amount)
      case (3); call add_counter(global_exp_calls, amount)
      end select
    end if
  end subroutine
  subroutine read_environment(environment)
    type(public_c_fenv), intent(out) :: environment
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved, code
    call c_f_pointer(c_errno_location(), error_number)
    saved = error_number
    code = c_fegetenv(environment)
    error_number = saved
    if (code /= 0_c_int) call c_exit(116_c_int)
  end subroutine
  subroutine write_environment(environment)
    type(public_c_fenv), intent(in) :: environment
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved, code
    call c_f_pointer(c_errno_location(), error_number)
    saved = error_number
    code = c_fesetenv(environment)
    error_number = saved
    if (code /= 0_c_int) call c_exit(116_c_int)
  end subroutine
  logical function math_environment_ready() result(ready)
    type(public_c_fenv) :: environment
    call read_environment(environment)
    ready = environment%fpcr == 0_c_int
  end function
  integer(int32) function math_status_read() result(mask)
    type(public_c_fenv) :: environment
    call read_environment(environment)
    mask = environment%fpsr
  end function
  subroutine math_status_clear()
    type(public_c_fenv) :: environment
    call read_environment(environment)
    environment%fpsr = 0_c_int
    call write_environment(environment)
  end subroutine
  subroutine commit_math_status(mask)
    integer(int32), intent(in) :: mask
    type(public_c_fenv) :: environment
    if (mask == 0_int32) return
    call read_environment(environment)
    if (iand(mask, not(environment%fpsr)) == 0_c_int) return
    environment%fpsr = ior(environment%fpsr, mask)
    call write_environment(environment)
  end subroutine
  subroutine set_math_errno(code)
    integer(c_int), intent(in) :: code
    integer(c_int), pointer, volatile :: error_number
    type(public_c_fenv) :: environment
    call read_environment(environment)
    call c_f_pointer(c_errno_location(), error_number)
    error_number = code
    call write_environment(environment)
  end subroutine
  subroutine math_domain_exit()
    call c_exit(116_c_int)
  end subroutine
end module forecast_original_math_status
