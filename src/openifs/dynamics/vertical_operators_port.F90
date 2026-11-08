!> Typed port of generated VERDISINT, VERINT, VERDER and strict N,T reduction.
!! Named coefficient arrays replace compiler-private record offsets.
!! No original OpenIFS numerical entry is called.
module md2asm_vertical_operators
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: ieee_arithmetic
  use omp_lib, only: omp_in_parallel
  implicit none
  private
  public :: vertical_operator_matrices, apply_vertical_operator
  public :: apply_vertical_integral, apply_vertical_derivative
  type :: vertical_operator_matrices
    real(real64), pointer :: rinte(:, :) => null()
    real(real64), pointer :: rintbf00(:, :) => null()
    real(real64), pointer :: rintbf11(:, :) => null()
    real(real64), pointer :: rderi(:, :) => null()
    real(real64), pointer :: rderbf00(:, :) => null()
    real(real64), pointer :: rderbf01(:, :) => null()
    real(real64), pointer :: rderbf10(:, :) => null()
    real(real64), pointer :: rderbf11(:, :) => null()
    real(real64), pointer :: rderbh00(:, :) => null()
    real(real64), pointer :: rderbh01(:, :) => null()
    real(real64), pointer :: rdderi(:, :) => null()
    real(real64), pointer :: rdderbf01(:, :) => null()
    real(real64), pointer :: rdderbf11(:, :) => null()
    real(real64), pointer :: rintbf11_impl(:, :) => null()
    real(real64), pointer :: rderbf01_impl(:, :) => null()
    real(real64), pointer :: rderbf10_impl(:, :) => null()
    real(real64), pointer :: rderbf11_impl(:, :) => null()
    real(real64), pointer :: rderbh01_impl(:, :) => null()
    real(real64), pointer :: rdderbf11_impl(:, :) => null()
    real(real64), pointer :: rintgw(:, :) => null()
    real(real64), pointer :: rdergw(:, :) => null()
  end type vertical_operator_matrices
  ! Six columns: named matrix ID, input origin, extra inputs/outputs, type, class.
  ! Classes0/1/2 retain defined/undefined/source-abort selections.
  integer, parameter :: dispatch(6, 4, 4, 7) = reshape([ &
                                                       1, 0, 2, 1, 0, 1, &
                                                       1, 1, 0, 1, 0, 0, &
                                                       1, 1, 0, 1, 0, 0, &
                                                       1, 1, 0, 1, 0, 0, &
                                                       2, 0, 2, 1, 0, 1, &
                                                       3, 0, 2, 1, 0, 0, &
                                                       3, 0, 2, 1, 0, 0, &
                                                       3, 0, 2, 1, 0, 0, &
                                                       2, 0, 2, 1, 0, 1, &
                                                       14, 1, 0, 1, 0, 0, &
                                                       14, 1, 0, 1, 0, 0, &
                                                       14, 1, 0, 1, 0, 0, &
                                                       2, 0, 2, 1, 0, 1, &
                                                       3, 0, 2, 1, 0, 0, &
                                                       3, 0, 2, 1, 0, 0, &
                                                       3, 0, 2, 1, 0, 0, &
                                                       1, 0, 2, 1, 1, 1, &
                                                       1, 1, 0, 1, 1, 0, &
                                                       1, 1, 0, 1, 1, 0, &
                                                       1, 1, 0, 1, 1, 0, &
                                                       2, 0, 2, 1, 1, 1, &
                                                       3, 0, 2, 1, 1, 0, &
                                                       3, 0, 2, 1, 1, 0, &
                                                       3, 0, 2, 1, 1, 0, &
                                                       2, 0, 2, 1, 1, 1, &
                                                       14, 1, 0, 1, 1, 0, &
                                                       14, 1, 0, 1, 1, 0, &
                                                       14, 1, 0, 1, 1, 0, &
                                                       2, 0, 2, 1, 1, 1, &
                                                       3, 0, 2, 1, 1, 0, &
                                                       3, 0, 2, 1, 1, 0, &
                                                       3, 0, 2, 1, 1, 0, &
                                                       1, 0, 2, 1, 1, 1, &
                                                       1, 0, 1, 1, 1, 1, &
                                                       1, 0, 1, 1, 1, 1, &
                                                       1, 0, 1, 1, 1, 1, &
                                                       20, 0, 2, 1, 0, 1, &
                                                       20, 0, 2, 1, 0, 1, &
                                                       20, 0, 2, 1, 0, 1, &
                                                       20, 0, 2, 1, 0, 1, &
                                                       20, 0, 2, 1, 0, 1, &
                                                       20, 0, 1, 1, 0, 1, &
                                                       20, 0, 1, 1, 0, 1, &
                                                       20, 0, 1, 1, 0, 1, &
                                                       20, 0, 2, 1, 0, 1, &
                                                       20, 0, 2, 1, 0, 1, &
                                                       20, 0, 2, 1, 0, 1, &
                                                       20, 0, 2, 1, 0, 1, &
                                                       21, 0, 2, 1, 0, 1, &
                                                       21, 0, 1, 1, 0, 0, &
                                                       21, 0, 1, 1, 0, 0, &
                                                       21, 0, 1, 1, 0, 0, &
                                                       21, 0, 2, 1, 0, 1, &
                                                       21, 0, 2, 1, 0, 1, &
                                                       21, 0, 2, 1, 0, 1, &
                                                       21, 0, 2, 1, 0, 1, &
                                                       21, 0, 2, 1, 0, 1, &
                                                       21, 0, 1, 1, 0, 0, &
                                                       21, 0, 1, 1, 0, 0, &
                                                       21, 0, 1, 1, 0, 0, &
                                                       21, 0, 2, 1, 0, 1, &
                                                       21, 0, 2, 1, 0, 1, &
                                                       21, 0, 2, 1, 0, 1, &
                                                       21, 0, 2, 1, 0, 1, &
                                                       9, 0, 2, 1, 0, 0, &
                                                       9, 1, 0, 1, 0, 2, &
                                                       9, 1, 0, 1, 0, 2, &
                                                       9, 1, 0, 1, 0, 2, &
                                                       9, 0, 2, 1, 0, 0, &
                                                       9, 0, 2, 1, 0, 2, &
                                                       9, 0, 2, 1, 0, 2, &
                                                       9, 0, 2, 1, 0, 2, &
                                                       9, 0, 2, 1, 0, 0, &
                                                       18, 1, 0, 1, 0, 0, &
                                                       9, 1, 0, 1, 0, 2, &
                                                       9, 1, 0, 1, 0, 2, &
                                                       9, 0, 2, 1, 0, 0, &
                                                       10, 0, 2, 1, 0, 0, &
                                                       9, 0, 2, 1, 0, 2, &
                                                       9, 0, 2, 1, 0, 2, &
                                                       4, 0, 2, 0, 0, 1, &
                                                       4, 1, 0, 0, 0, 0, &
                                                       4, 1, 0, 0, 0, 0, &
                                                       4, 1, 0, 0, 0, 0, &
                                                       5, 0, 2, 0, 0, 0, &
                                                       6, 0, 2, 0, 0, 0, &
                                                       7, 0, 2, 0, 0, 0, &
                                                       8, 0, 2, 0, 0, 0, &
                                                       0, 0, 2, 0, 0, 2, &
                                                       15, 1, 0, 0, 0, 0, &
                                                       16, 1, 0, 0, 0, 0, &
                                                       17, 1, 0, 0, 0, 0, &
                                                       5, 0, 2, 0, 0, 0, &
                                                       6, 0, 2, 0, 0, 0, &
                                                       7, 0, 2, 0, 0, 0, &
                                                       8, 0, 2, 0, 0, 0, &
                                                       11, 0, 2, 0, 0, 1, &
                                                       11, 1, 0, 0, 0, 0, &
                                                       11, 1, 0, 0, 0, 0, &
                                                       11, 1, 0, 0, 0, 0, &
                                                       11, 0, 2, 0, 0, 1, &
                                                       12, 0, 2, 0, 0, 0, &
                                                       0, 0, 2, 0, 0, 2, &
                                                       0, 0, 2, 0, 0, 2, &
                                                       0, 0, 2, 0, 0, 2, &
                                                       0, 1, 0, 0, 0, 2, &
                                                       0, 1, 0, 0, 0, 2, &
                                                       19, 1, 0, 0, 0, 0, &
                                                       0, 0, 2, 0, 0, 2, &
                                                       12, 0, 2, 0, 0, 0, &
                                                       0, 0, 2, 0, 0, 2, &
                                                       13, 0, 2, 0, 0, 0 &
                                                       ], [6, 4, 4, 7])
contains

  !> Select and apply the complete source-defined finite-element operator.
  !! pin(P,0:L+1) includes physical top and bottom input columns.
  !! pout(P,:) preserves points outside start:last and any extra columns.
  !! Matrices are immutable, independent of pin and pout, and have exact shapes.
  !! Operation is ITOP,IBOT,INGW,DEGW,HDER,FDER or DDER; boundary is two binary digits.
  !! Defaults select the initialized integral or derivative boundary condition.
  !! Refusal returns2 before output mutation; source_class distinguishes the table.
  subroutine apply_vertical_operator(tables, finite_elements, default_integral_bc, &
                                     default_derivative_bc, operation, boundary, pitch, start, last, levels, &
                                     pin, pout, status, boundary_condition, chunk, source_class)
    type(vertical_operator_matrices), intent(in) :: tables
    logical, intent(in) :: finite_elements
    integer, intent(in) :: default_integral_bc, default_derivative_bc
    character(len=*), intent(in) :: operation, boundary
    integer, intent(in) :: pitch, start, last, levels
    real(real64), intent(in) :: pin(:, 0:)
    real(real64), intent(inout) :: pout(:, :)
    integer(int32), intent(out) :: status
    integer, intent(in), optional :: boundary_condition, chunk
    integer, intent(out), optional :: source_class
    real(real64), pointer :: a(:, :)
    real(real64), allocatable :: scratch(:, :)
    integer :: op, bc, selector, ind, n, m, kind, step, allocation_status
    integer :: j, point, row(6)
    status = 2_int32
    if (present(source_class)) source_class = 2
    if (len(operation) /= 4 .or. len(boundary) /= 2) return
    if (.not. finite_elements) return
    if (pitch < 1 .or. levels < 1 .or. levels > huge(levels) - 2) return
    if (start < 1 .or. start > pitch .or. last < start - 1 .or. last > pitch) return
    select case (operation)
    case ('ITOP'); op = 1
    case ('IBOT'); op = 2
    case ('INGW'); op = 3
    case ('DEGW'); op = 4
    case ('HDER'); op = 5
    case ('FDER'); op = 6
    case ('DDER'); op = 7
    case default; return
    end select
    if (boundary(1:1) /= '0' .and. boundary(1:1) /= '1') return
    if (boundary(2:2) /= '0' .and. boundary(2:2) /= '1') return
    selector = 2*(iachar(boundary(1:1)) - iachar('0')) + iachar(boundary(2:2)) - iachar('0')
    if (op <= 3) then
      bc = default_integral_bc
    else
      bc = default_derivative_bc
    end if
    if (present(boundary_condition)) bc = boundary_condition
    if (bc < 0 .or. bc > 3) return
    step = 1
    if (present(chunk)) step = chunk
    if (op <= 3) then
      if (step < 1) return
    else
      if (start /= 1) return
    end if
    if (op == 5) then
      if (.not. associated(tables%rderbh00)) return
    end if
    row = dispatch(:, selector + 1, bc + 1, op)
    if (present(source_class)) source_class = row(6)
    if (row(6) /= 0) return
    ind = row(2); n = levels + row(3); m = levels + row(4); kind = row(5)
    a => selected_matrix(tables, row(1))
    if (.not. associated(a)) return
    if (size(a, 1) /= m .or. size(a, 2) /= n) return
    if (.not. is_contiguous(a) .or. .not. is_contiguous(pin)) return
    if (.not. is_contiguous(pout)) return
    if (size(pin, 1) /= pitch .or. ubound(pin, 2) < levels + 1) return
    if (size(pout, 1) /= pitch .or. size(pout, 2) < m) return
    if (op <= 3) then
      if (last < start) then
        status = 0_int32
        return
      end if
      if (int(pitch, int64) > huge(0_int64)/(8_int64*int(levels + 2, int64))) return
      allocate (scratch(pitch, 0:levels + 1), stat=allocation_status)
      if (allocation_status /= 0) return
      do j = 1, levels
        do point = start, last
          scratch(point, j) = pin(point, j)
        end do
      end do
      if (n /= levels) then
        do point = start, last
          scratch(point, 0) = 0.0_real64
          scratch(point, levels + 1) = 0.0_real64
        end do
      end if
      call apply_vertical_integral(pitch, start, last, n, m, a, scratch(:, ind:ind + n - 1), &
                                   pout, kind, step, status)
      deallocate (scratch)
    else
      call apply_vertical_derivative(pitch, start, last, n, m, a, pin(:, ind:ind + n - 1), pout, status)
    end if
  end subroutine apply_vertical_operator

  !> Form all ordered matrix sums, then subtract the final row for type1.
  !! A has shape(M,N), input(P,N), output(P,M); only start:last is written.
  !! Inside an existing team the complete active range is one chunk and start=1.
  subroutine apply_vertical_integral(pitch, start, last, n, m, a, pin, pout, kind, chunk, status)
    integer, intent(in) :: pitch, start, last, n, m, kind, chunk
    real(real64), intent(in) :: a(:, :), pin(:, :)
    real(real64), intent(inout) :: pout(:, :)
    integer(int32), intent(out) :: status
    integer :: first, final, row, point, column, count
    real(real64) :: total, product
    logical :: parallel
    status = 2_int32
    if (.not. valid_views(pitch, start, last, n, m, a, pin, pout)) return
    if (kind < 0 .or. kind > 1 .or. chunk < 1) return
    parallel = omp_in_parallel()
    if (parallel .and. start /= 1) return
    if (.not. floating_point_ready()) return
    first = start
    do while (first <= last)
      count = last - first + 1
      if (.not. parallel) count = min(count, chunk)
      final = first + count - 1
      do row = 1, m
        do point = first, final
          total = 0.0_real64
          do column = 1, n
            product = pin(point, column)*a(row, column)
            total = total + product
          end do
          pout(point, row) = total
        end do
      end do
      first = final + 1
    end do
    if (kind == 1) then
      do row = 1, m
        do point = start, last
          pout(point, row) = pout(point, row) - pout(point, m)
        end do
      end do
    end if
    status = 0_int32
  end subroutine apply_vertical_integral

  !> Apply the same complete ordered matrix reduction without bottom subtraction.
  subroutine apply_vertical_derivative(pitch, start, last, n, m, a, pin, pout, status)
    integer, intent(in) :: pitch, start, last, n, m
    real(real64), intent(in) :: a(:, :), pin(:, :)
    real(real64), intent(inout) :: pout(:, :)
    integer(int32), intent(out) :: status
    integer :: row, point, column
    real(real64) :: total, product
    status = 2_int32
    if (start /= 1) return
    if (.not. valid_views(pitch, start, last, n, m, a, pin, pout)) return
    if (.not. floating_point_ready()) return
    do row = 1, m
      do point = start, last
        total = 0.0_real64
        do column = 1, n
          product = pin(point, column)*a(row, column)
          total = total + product
        end do
        pout(point, row) = total
      end do
    end do
    status = 0_int32
  end subroutine apply_vertical_derivative

  logical function valid_views(pitch, start, last, n, m, a, pin, pout)
    integer, intent(in) :: pitch, start, last, n, m
    real(real64), intent(in) :: a(:, :), pin(:, :), pout(:, :)
    valid_views = .false.
    if (pitch < 1 .or. n < 1 .or. m < 1) return
    if (start < 1 .or. start > pitch .or. last < start - 1 .or. last > pitch) return
    if (size(a, 1) /= m .or. size(a, 2) /= n) return
    if (size(pin, 1) /= pitch .or. size(pin, 2) < n) return
    if (size(pout, 1) /= pitch .or. size(pout, 2) < m) return
    valid_views = is_contiguous(a) .and. is_contiguous(pin) .and. is_contiguous(pout)
  end function valid_views

  logical function floating_point_ready()
    type(ieee_round_type) :: rounding
    logical :: gradual
    real(real64), volatile :: minimum_normal, half_value, subnormal_probe
    floating_point_ready = .false.
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) return
    if (ieee_support_underflow_control(0.0_real64)) then
      call ieee_get_underflow_mode(gradual)
      if (.not. gradual) return
    else
      minimum_normal = tiny(0.0_real64)
      half_value = 0.5_real64
      subnormal_probe = minimum_normal*half_value
      if (transfer(subnormal_probe, 0_int64) /= ibset(0_int64, 51)) return
    end if
    floating_point_ready = .true.
  end function floating_point_ready

  function selected_matrix(tables, id) result(a)
    type(vertical_operator_matrices), intent(in) :: tables
    integer, intent(in) :: id
    real(real64), pointer :: a(:, :)
    nullify (a)
    select case (id)
    case (1); a => tables%rinte
    case (2); a => tables%rintbf00
    case (3); a => tables%rintbf11
    case (4); a => tables%rderi
    case (5); a => tables%rderbf00
    case (6); a => tables%rderbf01
    case (7); a => tables%rderbf10
    case (8); a => tables%rderbf11
    case (9); a => tables%rderbh00
    case (10); a => tables%rderbh01
    case (11); a => tables%rdderi
    case (12); a => tables%rdderbf01
    case (13); a => tables%rdderbf11
    case (14); a => tables%rintbf11_impl
    case (15); a => tables%rderbf01_impl
    case (16); a => tables%rderbf10_impl
    case (17); a => tables%rderbf11_impl
    case (18); a => tables%rderbh01_impl
    case (19); a => tables%rdderbf11_impl
    case (20); a => tables%rintgw
    case (21); a => tables%rdergw
    end select
  end function selected_matrix
end module md2asm_vertical_operators
