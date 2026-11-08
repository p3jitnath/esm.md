module vertical_spline_owner_port
  use iso_c_binding, only: c_int, c_double, c_int64_t, c_ptr, c_f_pointer
  use ieee_arithmetic, only: ieee_is_finite
  use selected_spline_operators, only: selected_spline_operator
  implicit none
  private
  public :: initialize_vertical_spline_owners, release_vertical_spline_copy
  interface
    function errno_location() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  integer(c_int) function initialize_vertical_spline_owners(n, eta, integral, derivative00, derivative01, &
                                                            derivative10, derivative11, derivative_copy) result(status)
    !! Fill the five caller-owned dimensionless operators in their source order.
    !! Eta has bounds 0:n+1. Integral has shape (n+1,n+2).
    !! Each derivative has shape (n,n+2) and remains caller-owned on every exit.
    !! The independent derivative copy is allocated after derivative00 completes.
    !! The caller supplies disjoint contiguous arrays and an unallocated copy.
    !! Return one means allocation failure, two means refusal and three means a child failure.
    integer(c_int), intent(in) :: n
    real(c_double), intent(in) :: eta(0:n + 1)
    real(c_double), intent(inout) :: integral(n + 1, n + 2)
    real(c_double), intent(inout) :: derivative00(n, n + 2), derivative01(n, n + 2)
    real(c_double), intent(inout) :: derivative10(n, n + 2), derivative11(n, n + 2)
    real(c_double), allocatable, intent(inout) :: derivative_copy(:, :)
    integer(c_int) :: controls(6), child_status
    integer :: i, j, allocation_status
    type(c_ptr) :: errno_address
    integer(c_int), pointer :: errno_value
    integer(c_int) :: saved_errno
    status = 2
    if (n /= 19 .and. n /= 137) return
    if (allocated(derivative_copy)) return
    if (transfer(eta(0), 0_c_int64_t) /= 0_c_int64_t) return
    if (eta(n + 1) /= 1.0_c_double) return
    do i = 1, n + 1
      if (.not. ieee_is_finite(eta(i))) return
      if (eta(i) <= eta(i - 1)) return
    end do
    errno_address = errno_location()
    call c_f_pointer(errno_address, errno_value)
    saved_errno = errno_value
    controls = [-1_c_int, n + 1, 1_c_int, 0_c_int, 1_c_int, 1_c_int]
    child_status = selected_spline_operator(controls, eta, eta(1:), integral)
    if (child_status /= 0) then
      status = 3
      goto 900
    end if
    controls = [1_c_int, n, 0_c_int, 0_c_int, 0_c_int, 0_c_int]
    child_status = selected_spline_operator(controls, eta, eta(1:), derivative00)
    if (child_status /= 0) then
      status = 3
      goto 900
    end if
    allocate (derivative_copy(n, n + 2), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      goto 900
    end if
    do j = 1, n + 2
      do i = 1, n
        derivative_copy(i, j) = derivative00(i, j)
      end do
    end do
    controls = [1_c_int, n, 0_c_int, 1_c_int, 0_c_int, 1_c_int]
    child_status = selected_spline_operator(controls, eta, eta(1:), derivative01)
    if (child_status == 0) then
      controls = [1_c_int, n, 1_c_int, 0_c_int, 1_c_int, 0_c_int]
      child_status = selected_spline_operator(controls, eta, eta(1:), derivative10)
    end if
    if (child_status == 0) then
      controls = [1_c_int, n, 0_c_int, 0_c_int, 1_c_int, 1_c_int]
      child_status = selected_spline_operator(controls, eta, eta(1:), derivative11)
    end if
    if (child_status /= 0) then
      status = 3
      goto 900
    end if
    status = 0
900 continue
    if (status /= 0 .and. allocated(derivative_copy)) deallocate (derivative_copy)
    errno_value = saved_errno
  end function

  subroutine release_vertical_spline_copy(derivative_copy)
    !! Release only the separately owned copy and permit repeated release.
    real(c_double), allocatable, intent(inout) :: derivative_copy(:, :)
    if (allocated(derivative_copy)) deallocate (derivative_copy)
  end subroutine
end module
