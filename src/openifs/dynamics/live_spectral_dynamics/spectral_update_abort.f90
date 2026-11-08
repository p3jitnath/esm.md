!> Preserve the source public-world spectral fatal-error route.
module forecast_spectral_update_abort
  use mpi_f08, only: MPI_Abort, MPI_COMM_WORLD
  implicit none
  private
  public :: abort_runtime_spectral_update
contains
  !> Abort the initialized public MPI world with the source error code3.
 !! The public runtime owns communicator lifetime. This procedure cannot
 !! return normally and performs no numerical calculation.
  subroutine abort_runtime_spectral_update()
    integer :: ierr
    call MPI_Abort(MPI_COMM_WORLD, 3, ierr)
    error stop 3
  end subroutine
end module forecast_spectral_update_abort
