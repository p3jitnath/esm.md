!> Own the two source-required arguments of inactive horizontal diffusion.
module forecast_diffusion_argument_storage
  use iso_c_binding, only: c_int, c_double
  implicit none
  private
  public :: native_diffusion_argument_storage, allocate_diffusion_argument_storage
  public :: release_diffusion_argument_storage
  !> FP64 arrays have bounds1:point_count and retain unwritten payload values.
  type :: native_diffusion_argument_storage
    real(c_double), allocatable :: slhda(:), slhdd0(:)
  end type
contains
  !> Allocate SLHDA then SLHDD0, publishing both only after success.
  !! POINT_COUNT is dimensionless in1:1048576 and LSLHD must be false.
  !! Status2 refuses unchanged;1 releases pending owners;0 transfers ownership.
  integer(c_int) function allocate_diffusion_argument_storage(state, point_count, lslhd) result(status)
    type(native_diffusion_argument_storage), intent(inout) :: state
    integer(c_int), intent(in) :: point_count
    logical, intent(in) :: lslhd
    real(c_double), allocatable :: pending_a(:), pending_d0(:)
    integer :: allocation_status
    status = 2
    if (transfer(lslhd, 0_c_int) /= 0) return
    if (point_count < 1 .or. point_count > 1048576) return
    if (allocated(state%slhda) .or. allocated(state%slhdd0)) return
    allocate (pending_a(point_count), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    allocate (pending_d0(point_count), stat=allocation_status)
    if (allocation_status /= 0) then
      deallocate (pending_a)
      status = 1; return
    end if
    call move_alloc(pending_a, state%slhda)
    call move_alloc(pending_d0, state%slhdd0)
    status = 0
  end function
  !> Release SLHDD0 before SLHDA; empty and repeated release are valid.
  subroutine release_diffusion_argument_storage(state)
    type(native_diffusion_argument_storage), intent(inout) :: state
    real(c_double), allocatable :: detached(:)
    if (allocated(state%slhdd0)) then
      call move_alloc(state%slhdd0, detached)
      deallocate (detached)
    end if
    if (allocated(state%slhda)) then
      call move_alloc(state%slhda, detached)
      deallocate (detached)
    end if
  end subroutine
end module forecast_diffusion_argument_storage
