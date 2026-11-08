!> Scale and invert a vertical mode matrix through the public LAPACK interface.
!! Own scalar loops retain the original diagonal mean and column-sum order.
module md2asm_scaled_mode_matrix_inverse
  use iso_fortran_env, only: int32, real64
  implicit none
  private
  public :: invert_scaled_mode_matrix
  interface
    subroutine dgetrf(m, n, a, lda, ipiv, info)
      import :: int32, real64
      integer(int32), intent(in) :: m, n, lda
      real(real64), intent(inout) :: a(lda, *)
      integer(int32), intent(out) :: ipiv(*), info
    end subroutine
    subroutine dgecon(norm, n, a, lda, anorm, rcond, work, iwork, info)
      import :: int32, real64
      character(len=1), intent(in) :: norm
      integer(int32), intent(in) :: n, lda
      real(real64), intent(in) :: a(lda, *), anorm
      real(real64), intent(out) :: rcond, work(*)
      integer(int32), intent(out) :: iwork(*), info
    end subroutine
    subroutine dgetri(n, a, lda, ipiv, work, lwork, info)
      import :: int32, real64
      integer(int32), intent(in) :: n, lda, ipiv(*), lwork
      real(real64), intent(inout) :: a(lda, *)
      real(real64), intent(out) :: work(*)
      integer(int32), intent(out) :: info
    end subroutine
  end interface
contains
  !> Invert matrix(n,n), where1<=n<=255, into a separate output owner.
  !! Both arrays are contiguous and use the caller's reciprocal units.
  !! Output is untouched until LAPACK and the condition bound succeed.
  !! Status0 succeeds,1 refuses allocation,2 refuses shape,3 refuses inversion.
  subroutine invert_scaled_mode_matrix(matrix, inverse, status)
    real(real64), contiguous, intent(in) :: matrix(:, :)
    real(real64), contiguous, intent(inout) :: inverse(:, :)
    integer(int32), intent(out) :: status
    real(real64), allocatable :: scratch(:, :), work(:)
    integer(int32), allocatable :: pivots(:), condition_work(:)
    integer(int32) :: n, info, lwork
    integer :: row, column, code
    real(real64) :: diagonal_mean, norm, column_sum, condition, value
    status = 2
    n = size(matrix, 1)
    if (n < 1 .or. n > 255 .or. size(matrix, 2) /= n) return
    if (any(shape(inverse) /= [n, n])) return
    lwork = 4*n
    allocate (scratch(n, n), work(lwork), pivots(n), condition_work(n), stat=code)
    if (code /= 0) then
      status = 1
      return
    end if
    diagonal_mean = 0.0_real64
    do row = 1, n
      value = abs(matrix(row, row))
      diagonal_mean = diagonal_mean + value
    end do
    diagonal_mean = diagonal_mean/real(n, real64)
    do row = 1, n
      do column = 1, n
        value = matrix(row, column)
        if (diagonal_mean > 0.0_real64) value = value/diagonal_mean
        scratch(row, column) = value
      end do
    end do
    norm = 0.0_real64
    do column = 1, n
      column_sum = 0.0_real64
      do row = 1, n
        value = abs(scratch(row, column))
        column_sum = column_sum + value
      end do
      if (.not. (norm >= column_sum)) norm = column_sum
    end do
    status = 3
    call dgetrf(n, n, scratch, n, pivots, info)
    if (info < 0) return
    call dgecon('1', n, scratch, n, norm, condition, work, condition_work, info)
    if (info /= 0) return
    if (condition <= 100.0_real64*tiny(1.0_real64)) return
    call dgetri(n, scratch, n, pivots, work, lwork, info)
    if (info /= 0) return
    do row = 1, n
      do column = 1, n
        value = scratch(row, column)
        if (diagonal_mean > 0.0_real64) value = value/diagonal_mean
        inverse(row, column) = value
      end do
    end do
    status = 0
  end subroutine
end module
