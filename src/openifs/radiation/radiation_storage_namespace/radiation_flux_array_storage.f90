!> Allocate one radiation flux array with its original lower-bound rule.
module forecast_radiation_flux_array_storage
  use iso_fortran_env, only: int32, int64, real64
  implicit none
  private
  public::allocate_radiation_flux_array,allocate_radiation_flux_pointer,release_radiation_flux_array,release_radiation_flux_pointer
  interface allocate_radiation_flux_array
    module procedure allocate_array1
    module procedure allocate_array2
    module procedure allocate_array3
    module procedure allocate_array4
  end interface
  interface allocate_radiation_flux_pointer
    module procedure allocate_pointer1
    module procedure allocate_pointer2
    module procedure allocate_pointer3
    module procedure allocate_pointer4
  end interface
  interface release_radiation_flux_array
    module procedure release_array1
    module procedure release_array2
    module procedure release_array3
    module procedure release_array4
  end interface
  interface release_radiation_flux_pointer
    module procedure release_pointer1
    module procedure release_pointer2
    module procedure release_pointer3
    module procedure release_pointer4
  end interface
contains
!> Bound each live extent and its complete byte count before allocation.
  logical function admitted_extents(extents, rank, first_lower) result(valid)
    integer(int32), intent(in) :: extents(:), rank, first_lower
    integer(int64) :: bytes
    integer :: i
    valid = .false.
    if (size(extents) /= rank .or. first_lower < 0 .or. first_lower > 1) return
    if (any(extents < 0)) return
    bytes = 8_int64
    do i = 1, rank
      if (extents(i) == 0) then
        bytes = 0
      else
        if (bytes > huge(bytes)/extents(i)) return
        bytes = bytes*extents(i)
      end if
    end do
    valid = .true.
  end function
!> Allocate rank1 FP64 fields; zero only when the caller selects it.
  integer(int32) function allocate_array1(values, extents, first_lower, zero_payload) result(status)
    real(real64), allocatable, intent(inout) :: values(:)
    integer(int32), intent(in) :: extents(:), first_lower
    logical, intent(in) :: zero_payload
    real(real64), allocatable :: pending(:)
    integer :: ios
    status = 2
    if (allocated(values)) return
    if (.not. admitted_extents(extents, 1_int32, first_lower)) return
    allocate (pending(first_lower:first_lower + extents(1) - 1), stat=ios)
    if (ios /= 0) then
      status = 1; return
    end if
    if (zero_payload) pending = 0.0_real64
    call move_alloc(pending, values)
    status = 0
  end function
!> Release exactly this native owner and retain other record members.
  subroutine release_array1(values)
    real(real64), allocatable, intent(inout) :: values(:)
    if (allocated(values)) deallocate (values)
  end subroutine
!> Allocate rank2 FP64 fields; zero only when the caller selects it.
  integer(int32) function allocate_array2(values, extents, first_lower, zero_payload) result(status)
    real(real64), allocatable, intent(inout) :: values(:, :)
    integer(int32), intent(in) :: extents(:), first_lower
    logical, intent(in) :: zero_payload
    real(real64), allocatable :: pending(:, :)
    integer :: ios
    status = 2
    if (allocated(values)) return
    if (.not. admitted_extents(extents, 2_int32, first_lower)) return
    allocate (pending(first_lower:first_lower + extents(1) - 1, 1:extents(2)), stat=ios)
    if (ios /= 0) then
      status = 1; return
    end if
    if (zero_payload) pending = 0.0_real64
    call move_alloc(pending, values)
    status = 0
  end function
!> Release exactly this native owner and retain other record members.
  subroutine release_array2(values)
    real(real64), allocatable, intent(inout) :: values(:, :)
    if (allocated(values)) deallocate (values)
  end subroutine
!> Allocate rank3 FP64 fields; zero only when the caller selects it.
  integer(int32) function allocate_array3(values, extents, first_lower, zero_payload) result(status)
    real(real64), allocatable, intent(inout) :: values(:, :, :)
    integer(int32), intent(in) :: extents(:), first_lower
    logical, intent(in) :: zero_payload
    real(real64), allocatable :: pending(:, :, :)
    integer :: ios
    status = 2
    if (allocated(values)) return
    if (.not. admitted_extents(extents, 3_int32, first_lower)) return
    allocate (pending(first_lower:first_lower + extents(1) - 1, 1:extents(2), 1:extents(3)), stat=ios)
    if (ios /= 0) then
      status = 1; return
    end if
    if (zero_payload) pending = 0.0_real64
    call move_alloc(pending, values)
    status = 0
  end function
!> Release exactly this native owner and retain other record members.
  subroutine release_array3(values)
    real(real64), allocatable, intent(inout) :: values(:, :, :)
    if (allocated(values)) deallocate (values)
  end subroutine
!> Allocate rank4 FP64 fields; zero only when the caller selects it.
  integer(int32) function allocate_array4(values, extents, first_lower, zero_payload) result(status)
    real(real64), allocatable, intent(inout) :: values(:, :, :, :)
    integer(int32), intent(in) :: extents(:), first_lower
    logical, intent(in) :: zero_payload
    real(real64), allocatable :: pending(:, :, :, :)
    integer :: ios
    status = 2
    if (allocated(values)) return
    if (.not. admitted_extents(extents, 4_int32, first_lower)) return
    allocate (pending(first_lower:first_lower + extents(1) - 1, 1:extents(2), 1:extents(3), 1:extents(4)), stat=ios)
    if (ios /= 0) then
      status = 1; return
    end if
    if (zero_payload) pending = 0.0_real64
    call move_alloc(pending, values)
    status = 0
  end function
!> Release exactly this native owner and retain other record members.
  subroutine release_array4(values)
    real(real64), allocatable, intent(inout) :: values(:, :, :, :)
    if (allocated(values)) deallocate (values)
  end subroutine
!> Allocate rank1 FP64 fields; zero only when the caller selects it.
  integer(int32) function allocate_pointer1(values, extents, first_lower, zero_payload) result(status)
    real(real64), pointer, intent(inout) :: values(:)
    integer(int32), intent(in) :: extents(:), first_lower
    logical, intent(in) :: zero_payload
    real(real64), pointer :: pending(:) => null()
    integer :: ios
    status = 2
    if (associated(values)) return
    if (.not. admitted_extents(extents, 1_int32, first_lower)) return
    allocate (pending(first_lower:first_lower + extents(1) - 1), stat=ios)
    if (ios /= 0) then
      status = 1; return
    end if
    if (zero_payload) pending = 0.0_real64
    values => pending
    status = 0
  end function
!> Release exactly this native owner and retain other record members.
  subroutine release_pointer1(values)
    real(real64), pointer, intent(inout) :: values(:)
    if (associated(values)) deallocate (values)
    nullify (values)
  end subroutine
!> Allocate rank2 FP64 fields; zero only when the caller selects it.
  integer(int32) function allocate_pointer2(values, extents, first_lower, zero_payload) result(status)
    real(real64), pointer, intent(inout) :: values(:, :)
    integer(int32), intent(in) :: extents(:), first_lower
    logical, intent(in) :: zero_payload
    real(real64), pointer :: pending(:, :) => null()
    integer :: ios
    status = 2
    if (associated(values)) return
    if (.not. admitted_extents(extents, 2_int32, first_lower)) return
    allocate (pending(first_lower:first_lower + extents(1) - 1, 1:extents(2)), stat=ios)
    if (ios /= 0) then
      status = 1; return
    end if
    if (zero_payload) pending = 0.0_real64
    values => pending
    status = 0
  end function
!> Release exactly this native owner and retain other record members.
  subroutine release_pointer2(values)
    real(real64), pointer, intent(inout) :: values(:, :)
    if (associated(values)) deallocate (values)
    nullify (values)
  end subroutine
!> Allocate rank3 FP64 fields; zero only when the caller selects it.
  integer(int32) function allocate_pointer3(values, extents, first_lower, zero_payload) result(status)
    real(real64), pointer, intent(inout) :: values(:, :, :)
    integer(int32), intent(in) :: extents(:), first_lower
    logical, intent(in) :: zero_payload
    real(real64), pointer :: pending(:, :, :) => null()
    integer :: ios
    status = 2
    if (associated(values)) return
    if (.not. admitted_extents(extents, 3_int32, first_lower)) return
    allocate (pending(first_lower:first_lower + extents(1) - 1, 1:extents(2), 1:extents(3)), stat=ios)
    if (ios /= 0) then
      status = 1; return
    end if
    if (zero_payload) pending = 0.0_real64
    values => pending
    status = 0
  end function
!> Release exactly this native owner and retain other record members.
  subroutine release_pointer3(values)
    real(real64), pointer, intent(inout) :: values(:, :, :)
    if (associated(values)) deallocate (values)
    nullify (values)
  end subroutine
!> Allocate rank4 FP64 fields; zero only when the caller selects it.
  integer(int32) function allocate_pointer4(values, extents, first_lower, zero_payload) result(status)
    real(real64), pointer, intent(inout) :: values(:, :, :, :)
    integer(int32), intent(in) :: extents(:), first_lower
    logical, intent(in) :: zero_payload
    real(real64), pointer :: pending(:, :, :, :) => null()
    integer :: ios
    status = 2
    if (associated(values)) return
    if (.not. admitted_extents(extents, 4_int32, first_lower)) return
    allocate (pending(first_lower:first_lower + extents(1) - 1, 1:extents(2), 1:extents(3), 1:extents(4)), stat=ios)
    if (ios /= 0) then
      status = 1; return
    end if
    if (zero_payload) pending = 0.0_real64
    values => pending
    status = 0
  end function
!> Release exactly this native owner and retain other record members.
  subroutine release_pointer4(values)
    real(real64), pointer, intent(inout) :: values(:, :, :, :)
    if (associated(values)) deallocate (values)
    nullify (values)
  end subroutine
end module
