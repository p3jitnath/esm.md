!> Complete scoped ordered matrix provider for the vertical operators.
!! Each product and increasing-column sum reuses the unchanged accepted
!! native vertical kernel. This entry never calls a public BLAS reduction.
module md2asm_strict_matrix_provider
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_int, c_ptr, c_f_pointer, c_associated
  use ieee_arithmetic, only: ieee_round_type, ieee_nearest, ieee_get_rounding_mode, &
                             ieee_support_underflow_control, ieee_get_underflow_mode, operator(/=)
  use md2asm_vertical_operators, only: apply_vertical_derivative
  implicit none
  private
  public :: multiply_strict_nt
  interface
    function matrix_errno_location() bind(C, name='__errno_location') result(p)
      import c_ptr
      type(c_ptr) :: p
    end function
  end interface
contains
  !> Compute C(i,r)=sum over increasing j of A(i,j)*B(r,j).
  !! m,n,k are nonnegative int32 counts. A has at least(m,k), B(n,k)
  !! and C(m,n) real64 entries. Units are [A]*[B] in C; counts have no unit.
  !! Each finite product and sum has its own FP64 rounding point, starting
  !! with positive zero. All consumed products and sums must remain finite.
  !! Native array views may be strided. They borrow complete live storage;
  !! the compiler handles their strides. Active C is disjoint from A and B.
  !! The exact flags are one-character N,T; alpha is positive one and beta
  !! positive zero by their FP64 bits. Incoming C is never read.
  !! m=0 or n=0 consumes no array byte; k=0 writes active positive zeros.
  !! Padding and all read-only inputs remain unchanged. Contiguous exact
  !! views call the accepted kernel directly. Other views are packed into
  !! owned arrays, then only active result cells are returned.
  !! workspace_limit, when present, bounds packing bytes; it may be zero for
  !! a direct or zero-sized operation. No allocation is needed by that route.
  !! Status0 succeeds,1 refuses allocation and2 refuses flags,shapes,budget
  !! or environment. Admission and allocation refusals precede public writes.
  !! The outer target contract still requires FPCR0,disabled traps and
  !! preserved signed zeros. The portable guard checks rounding and underflow.
  !! Successful packed calls restore errno after releasing their own storage.
  subroutine multiply_strict_nt(transa, transb, m, n, k, alpha, a, b, beta, c, status, workspace_limit)
    character(len=*), intent(in) :: transa, transb
    integer(int32), intent(in) :: m, n, k
    real(real64), intent(in) :: alpha, beta, a(:, :), b(:, :)
    real(real64), intent(inout) :: c(:, :)
    integer(int32), intent(out) :: status
    integer(int64), intent(in), optional :: workspace_limit
    real(real64), allocatable :: packed_a(:, :), packed_b(:, :), packed_c(:, :)
    integer(int64) :: cells_a, cells_b, cells_c, total_cells, total_bytes, budget
    integer :: i, r, j, allocation_status
    integer(c_int), pointer :: errno_pointer
    integer(c_int) :: saved_errno
    type(c_ptr) :: errno_address
    status = 2
    if (len(transa) /= 1 .or. len(transb) /= 1) return
    if (transa /= 'N' .or. transb /= 'T') return
    if (transfer(alpha, 0_int64) /= int(z'3FF0000000000000', int64)) return
    if (transfer(beta, 0_int64) /= 0_int64) return
    if (m < 0 .or. n < 0 .or. k < 0) return
    budget = huge(0_int64)
    if (present(workspace_limit)) then
      if (workspace_limit < 0) return
      budget = workspace_limit
    end if
    if (.not. matrix_environment_ready()) return
    if (m == 0 .or. n == 0) then
      status = 0
      return
    end if
    if (size(c, 1, kind=int64) < int(m, int64) .or. size(c, 2, kind=int64) < int(n, int64)) return
    if (k == 0) then
      do r = 1, n
        do i = 1, m
          c(i, r) = 0.0_real64
        end do
      end do
      status = 0
      return
    end if
    if (size(a, 1, kind=int64) < int(m, int64) .or. size(a, 2, kind=int64) < int(k, int64)) return
    if (size(b, 1, kind=int64) < int(n, int64) .or. size(b, 2, kind=int64) < int(k, int64)) return
    if (size(a, 1) == m .and. size(b, 1) == n .and. size(c, 1) == m) then
      if (is_contiguous(a) .and. is_contiguous(b) .and. is_contiguous(c)) then
        call apply_vertical_derivative(int(m), 1, int(m), int(k), int(n), &
                                       b(:, 1:k), a(:, 1:k), c(:, 1:n), status)
        return
      end if
    end if
    cells_a = int(m, int64)*int(k, int64)
    cells_b = int(n, int64)*int(k, int64)
    cells_c = int(m, int64)*int(n, int64)
    if (cells_a > huge(0_int64) - cells_b) return
    total_cells = cells_a + cells_b
    if (total_cells > huge(0_int64) - cells_c) return
    total_cells = total_cells + cells_c
    if (total_cells > huge(0_int64)/8_int64) return
    total_bytes = 8_int64*total_cells
    if (total_bytes > budget) return
    errno_address = matrix_errno_location()
    if (.not. c_associated(errno_address)) return
    call c_f_pointer(errno_address, errno_pointer)
    saved_errno = errno_pointer
    allocate (packed_a(m, k), packed_b(n, k), packed_c(m, n), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ! These are byte-preserving field moves, with no numerical reduction.
    do j = 1, k
      do i = 1, m
        packed_a(i, j) = a(i, j)
      end do
      do r = 1, n
        packed_b(r, j) = b(r, j)
      end do
    end do
    call apply_vertical_derivative(int(m), 1, int(m), int(k), int(n), packed_b, packed_a, packed_c, status)
    if (status /= 0) return
    do r = 1, n
      do i = 1, m
        c(i, r) = packed_c(i, r)
      end do
    end do
    deallocate (packed_a, packed_b, packed_c)
    errno_pointer = saved_errno
    status = 0
  end subroutine
  logical function matrix_environment_ready()
    type(ieee_round_type) :: rounding
    logical :: gradual
    real(real64), volatile :: minimum_normal, half_value, subnormal_probe
    matrix_environment_ready = .false.
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
    matrix_environment_ready = .true.
  end function
end module

!> Compiler-owned standard Fortran compatibility entry for the old private name.
!! Character lengths,integer references and real array arguments use the
!! selected Fortran compiler ABI. No register or private descriptor is emulated.
!! lda/ldc are at least max(1,m); ldb is at least max(1,n).
!! The caller owns aligned separate buffers through the last consumed element,
!! including source chunk calls whose array base begins inside a larger owner.
!! Only exact consumed sections enter the typed provider, so padded tail rows
!! are never read. The native status API is preferred by new callers.
!! Unsupported legacy calls terminate through the public language runtime.
subroutine verdisint_strict_nt_fp64(transa, transb, m, n, k, alpha, a, lda, b, ldb, beta, c, ldc)
  use iso_fortran_env, only: int32, real64, error_unit
  use md2asm_strict_matrix_provider, only: multiply_strict_nt
  implicit none
  character(len=*), intent(in) :: transa, transb
  integer(int32), intent(in) :: m, n, k, lda, ldb, ldc
  real(real64), intent(in) :: alpha, beta, a(lda, *), b(ldb, *)
  real(real64), intent(inout) :: c(ldc, *)
  integer(int32) :: status
  interface
    subroutine stop_invalid_matrix() bind(C, name='abort')
    end subroutine
  end interface
  if (m < 0 .or. n < 0 .or. k < 0) then
    call invalid_call()
    return
  end if
  if (lda < max(1_int32, m) .or. ldc < max(1_int32, m) .or. ldb < max(1_int32, n)) then
    call invalid_call()
    return
  end if
  call multiply_strict_nt(transa, transb, m, n, k, alpha, a(1:m, 1:k), b(1:n, 1:k), beta, c(1:m, 1:n), status)
  if (status /= 0) call invalid_call()
contains
  subroutine invalid_call()
    write (error_unit, '(A)') 'STRICT VERTICAL MATRIX: UNSUPPORTED CONTRACT'
    call stop_invalid_matrix()
  end subroutine
end subroutine
