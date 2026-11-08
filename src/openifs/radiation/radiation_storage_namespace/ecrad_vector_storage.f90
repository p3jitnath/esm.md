!> Allocate one fresh ecRad vector without initializing its payload.
module forecast_ecrad_vector_storage
  use iso_fortran_env, only: int32, real64
  implicit none
  private
  public :: allocate_ecrad_vector, release_ecrad_vector
  interface allocate_ecrad_vector
    module procedure allocate_integer_vector, allocate_real_vector
  end interface
  interface release_ecrad_vector
    module procedure release_integer_vector, release_real_vector
  end interface
contains
!> Allocate count elements with lower bound1; preserve the owner on failure.
  integer(int32) function allocate_integer_vector(values, count) result(status)
    integer(int32), allocatable, intent(inout) :: values(:)
    integer(int32), intent(in) :: count
    integer(int32), allocatable :: pending(:)
    integer :: ios
    status = 2
    if (allocated(values) .or. count < 1) return
    allocate (pending(1:count), stat=ios)
    if (ios /= 0) then
      status = 1; return
    end if
    call move_alloc(pending, values)
    status = 0
  end function
!> Release this native vector once; absent storage remains valid.
  subroutine release_integer_vector(values)
    integer(int32), allocatable, intent(inout) :: values(:)
    if (allocated(values)) deallocate (values)
  end subroutine
!> Allocate count elements with lower bound1; preserve the owner on failure.
  integer(int32) function allocate_real_vector(values, count) result(status)
    real(real64), allocatable, intent(inout) :: values(:)
    integer(int32), intent(in) :: count
    real(real64), allocatable :: pending(:)
    integer :: ios
    status = 2
    if (allocated(values) .or. count < 1) return
    allocate (pending(1:count), stat=ios)
    if (ios /= 0) then
      status = 1; return
    end if
    call move_alloc(pending, values)
    status = 0
  end function
!> Release this native vector once; absent storage remains valid.
  subroutine release_real_vector(values)
    real(real64), allocatable, intent(inout) :: values(:)
    if (allocated(values)) deallocate (values)
  end subroutine
end module
