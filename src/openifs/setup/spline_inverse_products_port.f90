!> Native inverse and product entries for dimensionless vertical spline matrices.
!! The caller owns disjoint contiguous FP64 arrays and establishes nearest
!! rounding with gradual underflow. The compiler owns every machine interface.
module forecast_spline_inverse_products
  use iso_c_binding, only: c_int, c_int64_t, c_double, c_ptr, c_f_pointer, c_associated, c_intptr_t
  use forecast_spline_scalar_inverse, only: spline_lu_factor, spline_inverse_from_lu
  use forecast_spline_public_matrix, only: library_spline_matrix_inverse, spline_matrix_product
  implicit none
  private
  public :: selected_spline_inverse, spline_matrix_product
  public :: md2asm_selected_spline_inverse_fortran
contains
  !> Compute a qualified inverse with source-ordered FP64 scaling.
  !! scale is zero or one for dimensions4 and21, and one for dimension139.
  !! Input and output have equal square shapes, with dimensionless entries.
  !! Input is read-only; output changes only on completion. Return0 completes,
  !! return2 refuses a shape/domain, and return3 reports a numerical failure.
  recursive integer(c_int) function selected_spline_inverse(scale, input, output) result(status)
    integer(c_int), intent(in) :: scale
    real(c_double), contiguous, intent(in) :: input(:, :)
    real(c_double), contiguous, intent(inout) :: output(:, :)
    real(c_double), target :: storage(441)
    real(c_double), pointer, contiguous :: matrix(:, :)
    integer(c_int) :: pivots(21), info, child_status
    integer(c_int64_t) :: bits
    real(c_double) :: average, value
    integer :: n, row, column
    logical :: apply_scale
    status = 2_c_int
    n = size(input, 1)
    if (size(input, 2) /= n .or. size(output, 1) /= n .or. size(output, 2) /= n) return
    if (n == 139) then
      status = library_spline_matrix_inverse(scale, input, output)
      return
    end if
    if (n /= 4 .and. n /= 21) return
    if (scale < 0_c_int .or. scale > 1_c_int) return
    do column = 1, n
      do row = 1, n
        bits = transfer(input(row, column), bits)
        if (ibits(bits, 52, 11) == 2047_c_int64_t) return
      end do
    end do
    matrix(1:n, 1:n) => storage(1:n*n)
    average = 0.0_c_double
    apply_scale = scale == 1_c_int
    if (apply_scale) then
      do row = 1, n
        value = abs(input(row, row))
        average = average + value
      end do
      average = average/real(n, c_double)
      apply_scale = average > 0.0_c_double
    end if
    do column = 1, n
      do row = 1, n
        value = input(row, column)
        if (apply_scale) value = value/average
        matrix(row, column) = value
      end do
    end do
    info = 0_c_int
    child_status = spline_lu_factor(matrix, pivots(1:n), info)
    status = 3_c_int
    if (child_status /= 0_c_int .or. info /= 0_c_int) return
    child_status = spline_inverse_from_lu(matrix, pivots(1:n), info)
    if (child_status /= 0_c_int .or. info /= 0_c_int) return
    do column = 1, n
      do row = 1, n
        value = matrix(row, column)
        if (apply_scale) value = value/average
        output(row, column) = value
      end do
    end do
    status = 0_c_int
  end function

  !> C boundary: four C pointers to scale, dimension, input and output.
  !! Scale and dimension are int32 words with four-byte alignment. The two
  !! matrices own dimension squared FP64 values with eight-byte alignment.
  !! All complete spans are disjoint. Dimensions4,21 and139 select native routes.
  integer(c_int) function md2asm_selected_spline_inverse_fortran(scale_pointer, n_pointer, input_pointer, output_pointer) &
    bind(C, name="md2asm_selected_spline_inverse_fortran") result(status)
    type(c_ptr), value :: scale_pointer, n_pointer, input_pointer, output_pointer
    integer(c_int), pointer :: scale, n
    real(c_double), pointer, contiguous :: input(:, :), output(:, :)
    integer(c_intptr_t) :: first(4), last(4), bytes
    integer :: i, j
    status = 2_c_int
    if (.not. complete_span(scale_pointer, 4_c_intptr_t, 4_c_intptr_t, first(1), last(1))) return
    if (.not. complete_span(n_pointer, 4_c_intptr_t, 4_c_intptr_t, first(2), last(2))) return
    call c_f_pointer(scale_pointer, scale)
    call c_f_pointer(n_pointer, n)
    if (n /= 4_c_int .and. n /= 21_c_int .and. n /= 139_c_int) return
    if (scale < 0_c_int .or. scale > 1_c_int) return
    if (n == 139_c_int .and. scale /= 1_c_int) return
    bytes = int(n, c_intptr_t)*int(n, c_intptr_t)*8_c_intptr_t
    if (.not. complete_span(input_pointer, bytes, 8_c_intptr_t, first(3), last(3))) return
    if (.not. complete_span(output_pointer, bytes, 8_c_intptr_t, first(4), last(4))) return
    do i = 1, 3
      do j = i + 1, 4
        if (first(i) < last(j) .and. first(j) < last(i)) return
      end do
    end do
    call c_f_pointer(input_pointer, input, [int(n), int(n)])
    call c_f_pointer(output_pointer, output, [int(n), int(n)])
    status = selected_spline_inverse(scale, input, output)
  end function

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
end module forecast_spline_inverse_products
