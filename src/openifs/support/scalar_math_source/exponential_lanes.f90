!> Independent exponential lanes with complete integer admission before mutation.
module forecast_exponential_lanes
  use iso_c_binding, only: c_double, c_int, c_int64_t
  use forecast_scalar_exponential, only: ordinary_exponential, ordinary_exp_admitted
  use forecast_original_math_status, only: native_math_counters, bump_math_counter
  implicit none
  private
  public :: try_exp_pair, exp_pair_integer_guard, exp_pair_normal_body
  public :: try_exp_four_counted, try_exp_eight_counted, try_exp_pair_counted
  public :: exp_pair_counted_admitted, exp_pair_guard_and_dispatch
contains
  logical function exp_pair_integer_guard(values) result(admitted)
    real(c_double), intent(in) :: values(2)
    admitted = ordinary_exp_admitted(values(1)) .and. ordinary_exp_admitted(values(2))
  end function
  subroutine exp_pair_normal_body(values)
    real(c_double), intent(inout) :: values(2)
    integer :: i
    do i = 1, 2
      values(i) = ordinary_exponential(values(i))
    end do
  end subroutine
  integer(c_int) function try_exp_pair(values) result(status)
    real(c_double), intent(inout) :: values(2)
    status = 1
    if (.not. exp_pair_integer_guard(values)) return
    call exp_pair_normal_body(values)
    status = 0
  end function
  integer(c_int) function exp_pair_counted_admitted(values, counters) result(status)
    real(c_double), intent(inout) :: values(2)
    type(native_math_counters), intent(inout), optional :: counters
    call bump_math_counter(3_c_int, 2_c_int64_t, counters)
    call exp_pair_normal_body(values)
    status = 0
  end function
  integer(c_int) function try_exp_pair_counted(values, counters) result(status)
    real(c_double), intent(inout) :: values(2)
    type(native_math_counters), intent(inout), optional :: counters
    status = 1
    if (.not. exp_pair_integer_guard(values)) return
    status = exp_pair_counted_admitted(values, counters)
  end function
  integer(c_int) function try_exp_four_counted(values, counters) result(status)
    real(c_double), intent(inout) :: values(4)
    type(native_math_counters), intent(inout), optional :: counters
    integer :: i
    status = 1
    do i = 1, 4
      if (.not. ordinary_exp_admitted(values(i))) return
    end do
    call bump_math_counter(3_c_int, 4_c_int64_t, counters)
    do i = 1, 4
      values(i) = ordinary_exponential(values(i))
    end do
    status = 0
  end function
  integer(c_int) function try_exp_eight_counted(values, counters) result(status)
    real(c_double), intent(inout) :: values(8)
    type(native_math_counters), intent(inout), optional :: counters
    integer :: i
    status = 1
    do i = 1, 8
      if (.not. ordinary_exp_admitted(values(i))) return
    end do
    call bump_math_counter(3_c_int, 8_c_int64_t, counters)
    do i = 1, 8
      values(i) = ordinary_exponential(values(i))
    end do
    status = 0
  end function
  integer(c_int) function exp_pair_guard_and_dispatch(values, counted, counters) result(status)
    real(c_double), intent(inout) :: values(2)
    logical, intent(in) :: counted
    type(native_math_counters), intent(inout), optional :: counters
    status = 1
    if (.not. exp_pair_integer_guard(values)) return
    if (counted) then
      status = exp_pair_counted_admitted(values, counters)
    else
      call exp_pair_normal_body(values)
      status = 0
    end if
  end function
  integer(c_int) function c_try_pair(values) bind(C, name='md2asm_try_exp_pair') result(status)
    real(c_double), intent(inout) :: values(2)
    status = try_exp_pair(values)
  end function
  integer(c_int) function c_guard_pair(values, counted) bind(C, name='md2asm_exp_pair_integer_guard') result(status)
    real(c_double), intent(inout) :: values(2)
    integer(c_int), value :: counted
    status = exp_pair_guard_and_dispatch(values, counted /= 0)
  end function
  integer(c_int) function c_pair_body(values) bind(C, name='md2asm_exp_pair_normal_body') result(status)
    real(c_double), intent(inout) :: values(2)
    call exp_pair_normal_body(values)
    status = 0
  end function
  integer(c_int) function c_count_pair(values) bind(C, name='md2asm_try_exp_pair_counted') result(status)
    real(c_double), intent(inout) :: values(2)
    status = try_exp_pair_counted(values)
  end function
  integer(c_int) function c_admitted_pair(values) bind(C, name='md2asm_exp_pair_counted_admitted') result(status)
    real(c_double), intent(inout) :: values(2)
    status = exp_pair_counted_admitted(values)
  end function
  integer(c_int) function c_count_four(values) bind(C, name='md2asm_try_exp_four_counted') result(status)
    real(c_double), intent(inout) :: values(4)
    status = try_exp_four_counted(values)
  end function
  integer(c_int) function c_count_eight(values) bind(C, name='md2asm_try_exp_eight_counted') result(status)
    real(c_double), intent(inout) :: values(8)
    status = try_exp_eight_counted(values)
  end function
end module
