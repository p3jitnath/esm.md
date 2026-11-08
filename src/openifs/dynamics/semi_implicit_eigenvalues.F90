!> Native wrapper for the independently sourced public Netlib EISPACK service.
!! The service finds real and imaginary eigenvalues and their right vectors.
module md2asm_semi_implicit_eigenvalues
  use iso_fortran_env, only: int32, real64
  implicit none
  private
  public :: compute_mode_eigenvalues
  interface
    subroutine md2asm_netlib_rg(nm, n, a, wr, wi, matz, z, iv1, fv1, ierr)
      import :: int32, real64
      integer(int32), intent(in) :: nm, n, matz
      real(real64), intent(inout) :: a(nm, *)
      real(real64), intent(out) :: wr(*), wi(*), z(nm, *), fv1(*)
      integer(int32), intent(out) :: iv1(*), ierr
    end subroutine
  end interface
contains
  !> Find every mode of a dense dimensionless or squared-speed matrix.
  !! matrix(n,n) is overwritten; real/imaginary values(n), vectors(n,n),
  !! integer_work(n) and real_work(n) are writable caller-owned arrays.
  !! Complex pairs retain the public EISPACK column convention.
  !! Status0 succeeds,2 refuses bounds,3 reports the public solver failure.
  !! No original OpenIFS numerical routine is called.
  subroutine compute_mode_eigenvalues(matrix, real_values, imaginary_values, vectors, &
                                      integer_work, real_work, status, solver_info)
    real(real64), contiguous, intent(inout) :: matrix(:, :)
    real(real64), contiguous, intent(inout) :: real_values(:), imaginary_values(:), vectors(:, :), real_work(:)
    integer(int32), contiguous, intent(inout) :: integer_work(:)
    integer(int32), intent(out) :: status
    integer(int32), optional, intent(out) :: solver_info
    integer(int32) :: n, matz, info
    status = 2
    n = size(matrix, 1)
    if (n < 1 .or. n > 255 .or. size(matrix, 2) /= n) return
    if (size(real_values) < n .or. size(imaginary_values) < n .or. size(real_work) < n) return
    if (size(integer_work) < n .or. any(shape(vectors) /= [n, n])) return
    matz = 1
    call md2asm_netlib_rg(n, n, matrix, real_values, imaginary_values, matz, vectors, integer_work, real_work, info)
    if (present(solver_info)) solver_info = info
    status = 0
    if (info /= 0) status = 3
  end subroutine
end module
