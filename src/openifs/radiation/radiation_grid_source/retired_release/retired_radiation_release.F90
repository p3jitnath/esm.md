!> Release the actual radiation owners after the one ZMU retirement.
!! The source storage-only entry follows release of the five point arrays.
!! All WORLD processes enter with the live public message context.
module forecast_retired_radiation_release
  use iso_fortran_env, only: int32
  use iso_c_binding, only: c_ptr, c_int, c_null_ptr, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use mpi_f08, only: MPI_Allreduce, MPI_INTEGER, MPI_MAX, MPI_COMM_WORLD, MPI_SUCCESS
  use forecast_native_radiation_transform_storage, only: native_radiation_transform_storage
  use forecast_live_radiation_setup, only: validate_live_radiation_storage, release_live_radiation_point_setup
  implicit none
  private
  public :: release_retired_radiation_setup, release_retired_radiation_transform_storage
#include "trans_release.h"
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import :: c_ptr
      type(c_ptr) :: address
    end function
    subroutine public_abort() bind(C, name="abort")
    end subroutine
  end interface
contains
  !> Agree the extra native lifetime test without changing numerical status.
  integer(int32) function agree_retired(local) result(status)
    integer(int32), intent(in) :: local
    type(ieee_status_type) :: incoming
    integer(c_int), pointer, volatile :: system_error
    integer(c_int) :: saved_error
    integer :: error
    call c_f_pointer(errno_address(), system_error)
    saved_error = system_error; call ieee_get_status(incoming)
    call MPI_Allreduce(local, status, 1, MPI_INTEGER, MPI_MAX, MPI_COMM_WORLD, error)
    if (error /= MPI_SUCCESS) call public_abort()
    call ieee_set_status(incoming); system_error = saved_error
  end function
  !> Release five actual point arrays, then public transform and storage8.
 !! Native state4 identifies a complete point state whose ZMU was retired.
 !! Readonly admission precedes any free. Refusal2 preserves all owners.
 !! Success0 clears this lifetime; a repeated release is refused.
  integer(int32) function release_retired_radiation_setup(owner) result(status)
    type(native_radiation_transform_storage), target, intent(inout) :: owner
    integer(int32) :: local
    local = 2_int32
    if (owner%state == 4) local = 0_int32
    status = agree_retired(local); if (status /= 0) return
    status = validate_live_radiation_storage(owner, .true.); if (status /= 0) return
    status = release_live_radiation_point_setup(owner)
  end function
  !> Release only the eight storage arrays left after point fields were freed.
 !! Caller retains the borrowed grid and row targets through this call.
 !! Source release order is public handle, RLATIG, RSQM2, RMU, NLSTLAT,
 !! NFRSTLAT, NPTRFRSTLAT, NONL and NSTA. This entry never frees ZMU twice.
 !! Five point fields must already be absent, as in its actual caller.
 !! Incoming IEEE state and errno survive complete release and refusals.
  integer(int32) function release_retired_radiation_transform_storage(owner) result(status)
    type(native_radiation_transform_storage), target, intent(inout) :: owner
    type(ieee_status_type) :: incoming
    integer(c_int), pointer, volatile :: system_error
    integer(c_int) :: saved_error
    integer(int32) :: local
    call c_f_pointer(errno_address(), system_error)
    saved_error = system_error; call ieee_get_status(incoming)
    local = 2_int32
    if (owner%state == 4) local = 0_int32
    status = agree_retired(local); if (status /= 0) goto900
    status = validate_live_radiation_storage(owner, .false.); if (status /= 0) goto900
    local = 0_int32
    if (allocated(owner%grid%gelam)) local = 2_int32
    if (allocated(owner%grid%gelat)) local = 2_int32
    if (allocated(owner%grid%geslo)) local = 2_int32
    if (allocated(owner%grid%geclo)) local = 2_int32
    if (allocated(owner%grid%gemu)) local = 2_int32
    status = agree_retired(local); if (status /= 0) goto900
    call trans_release(owner%resolution%resolution)
    deallocate (owner%grid%rlatig)
    deallocate (owner%grid%rsqm2)
    deallocate (owner%grid%rmu)
    nullify (owner%points%first_latitude, owner%points%last_latitude, owner%points%longitude_count, &
             owner%points%start, owner%points%count)
    deallocate (owner%nlstlat)
    deallocate (owner%nfrstlat)
    deallocate (owner%nptrfrstlat)
    deallocate (owner%nonl)
    deallocate (owner%nsta)
    owner%resolution%resolution = 0; owner%resolution%truncation = 0; owner%resolution%row_count = 0
    owner%state = 0
    owner%points%n_regions_ns = 0; owner%points%n_regions_ew = 0
    owner%points%my_region_ns = 0; owner%points%my_region_ew = 0; owner%points%nstencilwide = 0
    owner%allocation_address = c_null_ptr; owner%halo_address = c_null_ptr
    nullify (owner%grid, owner%row_lengths)
    status = 0
900 continue
    call ieee_set_status(incoming); system_error = saved_error
  end function
end module
