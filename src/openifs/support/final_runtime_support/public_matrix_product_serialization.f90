!> Serialize public matrix products with one portable process-wide lock.
module forecast_public_matrix_product_serialization
  use iso_fortran_env, only: int32, real64
  implicit none
  private
  public :: public_dgemm_serialized
  interface
    subroutine dgemm(transa, transb, m, n, k, alpha, a, lda, b, ldb, beta, c, ldc)
      import int32, real64
      character(*), intent(in) :: transa, transb
      integer(int32), intent(in) :: m, n, k, lda, ldb, ldc
      real(real64), intent(in) :: alpha, beta
      real(real64), intent(in) :: a(lda, *), b(ldb, *)
      real(real64), intent(inout) :: c(ldc, *)
    end subroutine
  end interface
contains
  !> Forward one complete public DGEMM call while retaining mutual exclusion.
 !! DGEMM computes C=alpha*op(A)*op(B)+beta*C. Matrix units are unchanged.
 !! Shapes, transpose flags and leading dimensions follow the public service.
 !! The compiler supplies both character lengths. No matrix is packed here.
 !! All callers using this service share one named OpenMP critical region.
 !! The linked public provider retains its own qualified arithmetic contract.
  subroutine public_dgemm_serialized(transa, transb, m, n, k, alpha, a, lda, b, ldb, beta, c, ldc)
    character(*), intent(in) :: transa, transb
    integer(int32), intent(in) :: m, n, k, lda, ldb, ldc
    real(real64), intent(in) :: alpha, beta
    real(real64), intent(in) :: a(lda, *), b(ldb, *)
    real(real64), intent(inout) :: c(ldc, *)
!$omp critical(md2asm_public_matrix_serialization)
    call dgemm(transa, transb, m, n, k, alpha, a, lda, b, ldb, beta, c, ldc)
!$omp end critical(md2asm_public_matrix_serialization)
  end subroutine
end module forecast_public_matrix_product_serialization
