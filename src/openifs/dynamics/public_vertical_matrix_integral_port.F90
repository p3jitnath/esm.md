!> Public matrix boundary for the operational vertical integral.
!! This entry preserves the original N,T call shape and column chunking.
!! It is separate from the accepted increasing-order scalar reduction.
module md2asm_public_vertical_matrix_integral
  use iso_fortran_env, only: int32, int64, real64
  use omp_lib, only: omp_in_parallel
  implicit none
  private
  public :: integrate_public_vertical_matrix
  interface
    subroutine dgemm(transa, transb, m, n, k, alpha, a, lda, b, ldb, beta, c, ldc)
      import :: real64
      character(len=1), intent(in) :: transa, transb
      integer, intent(in) :: m, n, k, lda, ldb, ldc
      real(real64), intent(in) :: alpha, beta, a(lda, *), b(ldb, *)
      real(real64), intent(inout) :: c(ldc, *)
    end subroutine
  end interface
contains
  !> Integrate input(pitch,n) with coefficient(m,n).
  !! Input and coefficients are read only, contiguous and disjoint from output.
  !! Only columns start:last of output(pitch,m) change. Here columns are
  !! horizontal points; the second array dimension is the vertical level.
  !! kind0 integrates from the top. kind1 subtracts the final vertical row.
  !! chunk is the initialized NPROMA value, rather than an inferred row count.
  !! Public BLAS owns its declared reduction. Its instructions are not claimed
  !! to use the scalar route's unfused arithmetic.
  !! Status0 succeeds,1 refuses allocation and2 refuses metadata or storage.
  subroutine integrate_public_vertical_matrix(pitch, start, last, n, m, coefficient, input, output, kind, chunk, status)
    integer, intent(in) :: pitch, start, last, n, m, kind, chunk
    real(real64), intent(in) :: coefficient(m, n), input(pitch, n)
    real(real64), intent(inout) :: output(pitch, m)
    integer(int32), intent(out) :: status
    real(real64), allocatable :: product(:, :)
    integer :: first, count, row, point, allocation_status
    logical :: parallel
    status = 2
    if (pitch < 1 .or. n < 1 .or. m < 1 .or. chunk < 1) return
    if (start < 1 .or. start > pitch .or. last < start - 1 .or. last > pitch) return
    if (kind < 0 .or. kind > 1) return
    parallel = omp_in_parallel()
    if (parallel .and. start /= 1) return
    status = 0
    if (last < start) return
    status = 2
    if (int(pitch, int64) > huge(0_int64)/(8_int64*int(m, int64))) return
    allocate (product(pitch, m), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    if (parallel) then
      count = last - start + 1
      call dgemm('N', 'T', count, m, n, 1.0_real64, input, pitch, coefficient, m, 0.0_real64, product, pitch)
    else
!$omp parallel do private(count)
      do first = start, last, chunk
        count = min(chunk, last - first + 1)
        call dgemm('N', 'T', count, m, n, 1.0_real64, input(first, 1), pitch, coefficient, m, &
                   0.0_real64, product(first, 1), pitch)
      end do
!$omp end parallel do
    end if
    if (kind == 1) then
      do row = 1, m
        do point = start, last
          output(point, row) = product(point, row) - product(point, m)
        end do
      end do
    else
      do row = 1, m
        do point = start, last
          output(point, row) = product(point, row)
        end do
      end do
    end if
    status = 0
  end subroutine
end module
