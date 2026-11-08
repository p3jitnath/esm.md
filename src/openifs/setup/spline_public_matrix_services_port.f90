!> Native matrix services for the dimensionless vertical spline operators.
!! Inputs use FP64 and column-major order. The caller establishes nearest
!! rounding with gradual underflow and supplies disjoint complete arrays.
!! Array outputs retain their incoming bytes when a reported error occurs.
!! Public LAPACK and GNU MATMUL keep their separately qualified arithmetic.
module forecast_spline_public_matrix
  use iso_c_binding, only: c_int, c_int64_t, c_double, c_ptr, c_f_pointer, c_associated, c_intptr_t
  implicit none
  private
  public :: library_spline_matrix_inverse, spline_matrix_product
  public :: md2asm_library_spline_inverse_fortran, md2asm_spline_product_fortran
  interface
    subroutine dgetrf(m, n, a, lda, ipiv, info)
      import c_int, c_double
      integer(c_int), intent(in) :: m, n, lda
      real(c_double), intent(inout) :: a(lda, *)
      integer(c_int), intent(out) :: ipiv(*), info
    end subroutine
    subroutine dgecon(norm, n, a, lda, anorm, rcond, work, iwork, info)
      import c_int, c_double
      character(len=1), intent(in) :: norm
      integer(c_int), intent(in) :: n, lda
      real(c_double), intent(in) :: a(lda, *), anorm
      real(c_double), intent(out) :: rcond
      real(c_double), intent(inout) :: work(*)
      integer(c_int), intent(out) :: iwork(*), info
    end subroutine
    subroutine dgetri(n, a, lda, ipiv, work, lwork, info)
      import c_int, c_double
      integer(c_int), intent(in) :: n, lda, lwork, ipiv(*)
      real(c_double), intent(inout) :: a(lda, *), work(*)
      integer(c_int), intent(out) :: info
    end subroutine
    function errno_location() result(address) bind(C, name="__errno_location")
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Test finite words without floating-point comparisons or exceptions.
  logical function finite_matrix(matrix) result(valid)
    real(c_double), contiguous, intent(in) :: matrix(:, :)
    integer :: row, column
    integer(c_int64_t) :: bits
    valid = .false.
    do column = 1, size(matrix, 2)
      do row = 1, size(matrix, 1)
        bits = transfer(matrix(row, column), bits)
        if (ibits(bits, 52, 11) == 2047_c_int64_t) return
      end do
    end do
    valid = .true.
  end function

  !> Invert one qualified 139-by-139 spline matrix through public LAPACK.
  !! scale is one; input and output each have shape (139,139), dimensionless.
  !! Input is unchanged; output changes only after all numerical checks pass.
  !! Returns 0 for completion, 2 for shape/domain refusal or 3 for LAPACK failure.
  recursive integer(c_int) function library_spline_matrix_inverse(scale, input, output) result(status)
    integer(c_int), intent(in) :: scale
    real(c_double), contiguous, intent(in) :: input(:, :)
    real(c_double), contiguous, intent(inout) :: output(:, :)
    integer(c_int), parameter :: n = 139_c_int, lwork = 556_c_int
    real(c_double) :: scaled(n, n), factor(n, n), work(lwork), average, anorm, column_sum, rcond, value
    integer(c_int) :: pivots(n), iwork(n), info
    integer(c_int), pointer :: error_number
    integer(c_int) :: saved_errno
    integer :: row, column
    logical :: apply_scale
    status = 2_c_int
    if (scale /= 1_c_int) return
    if (size(input, 1) /= n .or. size(input, 2) /= n) return
    if (size(output, 1) /= n .or. size(output, 2) /= n) return
    if (.not. finite_matrix(input)) return
    call c_f_pointer(errno_location(), error_number)
    saved_errno = error_number
    average = 0.0_c_double
    do row = 1, n
      value = abs(input(row, row))
      average = average + value
    end do
    average = average/real(n, c_double)
    apply_scale = average > 0.0_c_double
    do row = 1, n
      do column = 1, n
        value = input(row, column)
        if (apply_scale) value = value/average
        scaled(row, column) = value
      end do
    end do
    do row = 1, n
      do column = 1, n
        factor(row, column) = scaled(row, column)
      end do
    end do
    anorm = 0.0_c_double
    do column = 1, n
      column_sum = 0.0_c_double
      do row = 1, n
        value = abs(factor(row, column))
        column_sum = column_sum + value
      end do
      anorm = max(anorm, column_sum)
    end do
    status = 3_c_int
    call dgetrf(n, n, factor, n, pivots, info)
    if (info < 0_c_int) then
      error_number = saved_errno
      return
    end if
    call dgecon('1', n, factor, n, anorm, rcond, work, iwork, info)
    if (info /= 0_c_int) then
      error_number = saved_errno
      return
    end if
    if (rcond <= transfer(int(z'0079000000000000', c_int64_t), 0.0_c_double)) then
      error_number = saved_errno
      return
    end if
    call dgetri(n, factor, n, pivots, work, lwork, info)
    if (info /= 0_c_int) then
      error_number = saved_errno
      return
    end if
    do row = 1, n
      do column = 1, n
        scaled(row, column) = factor(row, column)
      end do
    end do
    do row = 1, n
      do column = 1, n
        value = scaled(row, column)
        if (apply_scale) value = value/average
        output(row, column) = value
      end do
    end do
    error_number = saved_errno
    status = 0_c_int
  end function

  !> Multiply native dimensionless spline matrices without changing their route.
  !! The small route accepts left(rows,21), right(21,21), rows in 19:21.
  !! The public runtime route accepts left(rows,139), right(139,139),
  !! rows in 137:139. Output has the left shape and is disjoint from both inputs.
  !! Returns 0 for completion or 2 before any output mutation for invalid input.
  integer(c_int) function spline_matrix_product(left, right, output) result(status)
    real(c_double), contiguous, intent(in) :: left(:, :), right(:, :)
    real(c_double), contiguous, intent(inout) :: output(:, :)
    real(c_double), allocatable :: temporary(:, :)
    real(c_double) :: total, product
    integer :: rows, n, row, column, k
    integer(c_int), pointer :: error_number
    integer(c_int) :: saved_errno
    rows = size(left, 1)
    n = size(left, 2)
    status = 2_c_int
    if (.not. ((n == 21 .and. rows >= 19 .and. rows <= 21) .or. (n == 139 .and. rows >= 137 .and. rows <= 139))) return
    if (size(right, 1) /= n .or. size(right, 2) /= n) return
    if (size(output, 1) /= rows .or. size(output, 2) /= n) return
    if (n == 139) then
      if (.not. finite_matrix(left)) return
      if (.not. finite_matrix(right)) return
      call c_f_pointer(errno_location(), error_number)
      saved_errno = error_number
      if (rows == 139) then
        temporary = matmul(left, right)
        output = temporary
        deallocate (temporary)
      else
        output = matmul(left, right)
      end if
      error_number = saved_errno
    else
      do column = 1, 21
        do row = 1, rows
          total = 0.0_c_double
          do k = 1, 21
            product = left(row, k)*right(k, column)
            total = total + product
          end do
          output(row, column) = total
        end do
      end do
    end if
    status = 0_c_int
  end function

  !> Check an aligned complete C span before constructing a native array view.
  logical function complete_span(pointer, bytes, alignment, first, last) result(valid)
    type(c_ptr), value :: pointer
    integer(c_intptr_t), intent(in) :: bytes, alignment
    integer(c_intptr_t), intent(out) :: first, last
    valid = .false.
    first = transfer(pointer, first)
    last = first
    if (.not. c_associated(pointer)) return
    if (first < 0_c_intptr_t) return
    if (mod(first, alignment) /= 0_c_intptr_t) return
    if (bytes <= 0_c_intptr_t .or. first > huge(first) - bytes) return
    last = first + bytes
    valid = .true.
  end function

  logical function overlaps(first_a, last_a, first_b, last_b) result(shared)
    integer(c_intptr_t), intent(in) :: first_a, last_a, first_b, last_b
    shared = first_a < last_b .and. first_b < last_a
  end function

  !> C boundary with explicit int32 scale and dimension words and two FP64 spans.
  !! Each argument is a C pointer. Scale and dimension own four bytes; each
  !! matrix owns n*n*8 bytes. All four complete spans must be disjoint.
  integer(c_int) function md2asm_library_spline_inverse_fortran(scale_pointer, n_pointer, input_pointer, output_pointer) &
    bind(C, name="md2asm_library_spline_matrix_inverse_fortran") result(status)
    type(c_ptr), value :: scale_pointer, n_pointer, input_pointer, output_pointer
    integer(c_int), pointer :: scale, n
    real(c_double), pointer, contiguous :: input(:, :), output(:, :)
    integer(c_intptr_t) :: first(4), last(4)
    integer :: i, j
    status = 2_c_int
    if (.not. complete_span(scale_pointer, 4_c_intptr_t, 4_c_intptr_t, first(1), last(1))) return
    if (.not. complete_span(n_pointer, 4_c_intptr_t, 4_c_intptr_t, first(2), last(2))) return
    call c_f_pointer(scale_pointer, scale)
    call c_f_pointer(n_pointer, n)
    if (n /= 139_c_int .or. scale /= 1_c_int) return
    if (.not. complete_span(input_pointer, 154568_c_intptr_t, 8_c_intptr_t, first(3), last(3))) return
    if (.not. complete_span(output_pointer, 154568_c_intptr_t, 8_c_intptr_t, first(4), last(4))) return
    do i = 1, 3
      do j = i + 1, 4
        if (overlaps(first(i), last(i), first(j), last(j))) return
      end do
    end do
    call c_f_pointer(input_pointer, input, [139, 139])
    call c_f_pointer(output_pointer, output, [139, 139])
    status = library_spline_matrix_inverse(scale, input, output)
  end function

  !> C product boundary with explicit int32 rows and shared-dimension words.
  !! Arguments are rows pointer, n pointer, left pointer, right pointer, output
  !! pointer. All arrays use column-major FP64. Scalars and inputs are unchanged.
  !! Output owns rows*n*8 bytes and must not overlap either input or scalar.
  integer(c_int) function md2asm_spline_product_fortran(rows_pointer, n_pointer, left_pointer, right_pointer, output_pointer) &
    bind(C, name="md2asm_spline_matrix_product_fortran") result(status)
    type(c_ptr), value :: rows_pointer, n_pointer, left_pointer, right_pointer, output_pointer
    integer(c_int), pointer :: rows, n
    real(c_double), pointer, contiguous :: left(:, :), right(:, :), output(:, :)
    integer(c_intptr_t) :: first(5), last(5), left_bytes, right_bytes
    integer :: i
    status = 2_c_int
    if (.not. complete_span(rows_pointer, 4_c_intptr_t, 4_c_intptr_t, first(1), last(1))) return
    if (.not. complete_span(n_pointer, 4_c_intptr_t, 4_c_intptr_t, first(2), last(2))) return
    call c_f_pointer(rows_pointer, rows)
    call c_f_pointer(n_pointer, n)
    if (.not. ((n == 21 .and. rows >= 19 .and. rows <= 21) .or. (n == 139 .and. rows >= 137 .and. rows <= 139))) return
    left_bytes = int(rows, c_intptr_t)*int(n, c_intptr_t)*8_c_intptr_t
    right_bytes = int(n, c_intptr_t)*int(n, c_intptr_t)*8_c_intptr_t
    if (.not. complete_span(left_pointer, left_bytes, 8_c_intptr_t, first(3), last(3))) return
    if (.not. complete_span(right_pointer, right_bytes, 8_c_intptr_t, first(4), last(4))) return
    if (.not. complete_span(output_pointer, left_bytes, 8_c_intptr_t, first(5), last(5))) return
    do i = 1, 4
      if (overlaps(first(5), last(5), first(i), last(i))) return
    end do
    call c_f_pointer(left_pointer, left, [int(rows), int(n)])
    call c_f_pointer(right_pointer, right, [int(n), int(n)])
    call c_f_pointer(output_pointer, output, [int(rows), int(n)])
    status = spline_matrix_product(left, right, output)
  end function
end module forecast_spline_public_matrix
