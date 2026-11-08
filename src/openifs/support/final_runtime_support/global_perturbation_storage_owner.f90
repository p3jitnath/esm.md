!> Own one outer canonical perturbation record for a runtime physics lane.
module forecast_global_perturbation_storage
  use iso_fortran_env, only: int32
  use iso_c_binding, only: c_int, c_ptr, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use forecast_physics_work_types, only: perturb_type
  implicit none
  private
  public :: create_global_perturbation_owner, release_global_perturbation_owner
  interface
    function errno_address() bind(C, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Allocate only the outer record; native default initialization nulls its views.
 !! OWNER must be unallocated. No weather array is acquired or initialized.
 !! A live owner remains at a stable allocation address through all block views.
 !! Status0 publishes it,1 reports allocation failure and2 refuses a live owner.
 !! Floating status and errno retain their incoming values on allocation paths.
  integer(int32) function create_global_perturbation_owner(owner) result(status)
    type(perturb_type), allocatable, intent(inout) :: owner
    type(ieee_status_type) :: saved_status
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer :: allocation_status
    status = 2_int32
    if (allocated(owner)) return
    call ieee_get_status(saved_status)
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    allocate (owner, stat=allocation_status)
    status = 0_int32
    if (allocation_status /= 0) status = 1_int32
    call ieee_set_status(saved_status)
    error_number = saved_errno
  end function
  !> Free only the outer metadata after its last per-block FINAL.
 !! A live PTEMP causes atomic status2. Other borrowed views are opaque and
 !! their targets are never inspected, freed or repaired by this routine.
 !! Null release returns0. Caller retires registry/model storage afterward.
  integer(int32) function release_global_perturbation_owner(owner) result(status)
    type(perturb_type), allocatable, intent(inout) :: owner
    type(ieee_status_type) :: saved_status
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer :: allocation_status
    status = 0_int32
    if (.not. allocated(owner)) return
    status = 2_int32
    if (associated(owner%ptemp)) return
    call ieee_get_status(saved_status)
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    deallocate (owner, stat=allocation_status)
    status = 0_int32
    if (allocation_status /= 0) status = 2_int32
    call ieee_set_status(saved_status)
    error_number = saved_errno
  end function
end module forecast_global_perturbation_storage
