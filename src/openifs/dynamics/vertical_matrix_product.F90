!> Port of generated source-matched MXMAOP chunking around public DGEMM.
!! The compiler supplies Fortran character and array calling conventions.
module md2asm_vertical_matrix_product
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use omp_lib, only: omp_in_parallel, omp_get_max_threads, omp_get_num_threads, omp_get_thread_num
  implicit none
  private
  public :: apply_vertical_matrix_product
  interface
    subroutine dgemm(transa, transb, m, n, k, alpha, a, lda, b, ldb, beta, c, ldc)
      import :: real64
      character(len=1), intent(in) :: transa, transb
      integer, intent(in) :: m, n, k, lda, ldb, ldc
      real(real64), intent(in) :: alpha, beta, a(lda, *), b(ldb, *)
      real(real64), intent(inout) :: c(ldc, *)
    end subroutine dgemm
  end interface
contains
  !> Compute C=A*B with the original public-library shapes and static chunks.
  !! A(L,L), B(L,S), C(L,S), workspace(L*S) are dense independent owners.
  !! Existing source-library version, floating-point mode and thread controls apply.
  !! Empty S returns0; other unsupported shapes return2 before any output write.
  subroutine apply_vertical_matrix_product(a, b, c, workspace, status)
    real(real64), intent(in) :: a(:, :), b(:, :)
    real(real64), intent(inout) :: c(:, :), workspace(:)
    integer(int32), intent(out) :: status
    integer :: l, s, threads, axis, chunk
    integer(int64) :: needed
    logical :: rows
    status = 2_int32
    l = size(a, 1); s = size(b, 2)
    if (l < 1 .or. l > 512) return
    if (size(a, 2) /= l .or. size(b, 1) /= l) return
    if (size(c, 1) /= l .or. size(c, 2) < s) return
    if (.not. is_contiguous(a) .or. .not. is_contiguous(b)) return
    if (.not. is_contiguous(c) .or. .not. is_contiguous(workspace)) return
    needed = int(l, int64)*int(s, int64)
    if (size(workspace, kind=int64) < needed) return
    if (s == 0) then
      status = 0_int32
      return
    end if
    rows = l >= s
    axis = max(l, s)
    if (omp_in_parallel()) then
      call matrix_worker(l, s, a, b, c, workspace, axis, rows, 1, 0)
    else
      threads = omp_get_max_threads()
      if (threads < 1 .or. threads > 65536) return
      chunk = (axis - 1)/threads + 1
!$omp parallel default(shared)
      call matrix_worker(l, s, a, b, c, workspace, chunk, rows, &
                         omp_get_num_threads(), omp_get_thread_num())
!$omp end parallel
    end if
    status = 0_int32
  end subroutine apply_vertical_matrix_product

  !> Preserve source partitioning and exact private leading output dimensions.
  subroutine matrix_worker(l, s, a, b, c, workspace, chunk, rows, threads, thread)
    integer, intent(in) :: l, s, chunk, threads, thread
    real(real64), intent(in) :: a(l, l), b(l, s)
    real(real64), intent(inout) :: c(l, s), workspace(int(l, int64)*int(s, int64))
    logical, intent(in) :: rows
    integer :: axis, chunks, base, remainder, first_chunk, last_chunk, start, finish
    integer :: count, m, n, i, j
    integer(int64) :: offset, read_index
    if (rows) then
      axis = l
    else
      axis = s
    end if
    chunks = (axis - 1)/chunk + 1
    base = chunks/threads
    remainder = mod(chunks, threads)
    first_chunk = thread*base + min(thread, remainder)
    last_chunk = first_chunk + base
    if (thread < remainder) last_chunk = last_chunk + 1
    start = int(min(int(first_chunk, int64)*int(chunk, int64), int(axis, int64)))
    finish = int(min(int(last_chunk, int64)*int(chunk, int64), int(axis, int64)))
    do while (start < finish)
      count = min(axis - start, chunk)
      if (rows) then
        m = count; n = s
        offset = int(start, int64)*int(s, int64)
        call dgemm('N', 'N', m, n, l, 1.0_real64, a(start + 1, 1), l, b, l, &
                   0.0_real64, workspace(offset + 1), m)
        read_index = offset
        do j = 1, n
          do i = 1, m
            read_index = read_index + 1
            c(start + i, j) = workspace(read_index)
          end do
        end do
      else
        m = l; n = count
        offset = int(start, int64)*int(l, int64)
        call dgemm('N', 'N', m, n, l, 1.0_real64, a, l, b(1, start + 1), l, &
                   0.0_real64, workspace(offset + 1), m)
        read_index = offset
        do j = 1, n
          do i = 1, m
            read_index = read_index + 1
            c(i, start + j) = workspace(read_index)
          end do
        end do
      end if
      start = start + count
    end do
  end subroutine matrix_worker
end module md2asm_vertical_matrix_product
