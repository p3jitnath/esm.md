!> Own integer and logical work arrays and borrow their block views.
module forecast_integer_logical_work_fields
  use iso_fortran_env, only: int32, int64
  implicit none
  private
  public :: native_integer_work_field, allocate_integer_work_field, integer_work_field_view_2d, release_integer_work_field
  public :: native_logical_work_field, allocate_logical_work_field, logical_work_field_view_2d, release_logical_work_field
  !> Values are dimensionless source work values and remain uninitialized.
  type :: native_integer_work_field
    integer(int32), pointer :: view(:) => null(), ptr(:, :) => null(), data(:, :) => null()
    integer(int32) :: nblocks = 0
    logical :: active = .false., thread_buffer = .false., owned = .true.
  end type
  !> Values are dimensionless source work values and remain uninitialized.
  type :: native_logical_work_field
    logical, pointer :: view(:) => null(), ptr(:, :) => null(), data(:, :) => null()
    integer(int32) :: nblocks = 0
    logical :: active = .false., thread_buffer = .false., owned = .true.
  end type
contains
  integer(int32) function allocate_integer_work_field(output, shape, thread_buffer) result(status)
    type(native_integer_work_field), intent(inout) :: output
    integer(int32), intent(in) :: shape(2)
    logical, intent(in) :: thread_buffer
    integer(int32), pointer :: pending(:, :)
    integer(int64) :: elements
    integer :: allocation_status
    status = 2
    if (associated(output%data) .or. associated(output%ptr)) return
    if (any(shape < 0)) return
    elements = int(shape(1), int64)*int(shape(2), int64)
    if (elements > huge(0_int64)/4_int64) return
    allocate (pending(shape(1), shape(2)), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    nullify (output%view)
    output%data => pending; output%ptr => pending
    output%nblocks = shape(2)
    output%active = .true.; output%thread_buffer = thread_buffer; output%owned = .true.
    status = 0
  end function
  integer(int32) function integer_work_field_view_2d(output, field, block) result(status)
    integer(int32), pointer, intent(inout) :: output(:)
    type(native_integer_work_field), intent(in) :: field
    integer(int32), intent(in) :: block
    integer :: selected
    status = 0
    if (.not. field%active) then
      output => field%view; return
    end if
    selected = block
    if (field%thread_buffer) selected = 1
    status = 2
    if (field%owned) then
      if (.not. associated(field%data)) return
      if (selected < lbound(field%data, 2) .or. selected > ubound(field%data, 2)) return
      output => field%data(:, selected)
    else
      if (.not. associated(field%ptr)) return
      if (selected < lbound(field%ptr, 2) .or. selected > ubound(field%ptr, 2)) return
      output => field%ptr(:, selected)
    end if
    status = 0
  end function
  subroutine release_integer_work_field(field)
    type(native_integer_work_field), intent(inout) :: field
    if (field%owned .and. associated(field%data)) deallocate (field%data)
    nullify (field%data, field%ptr, field%view)
  end subroutine
  integer(int32) function allocate_logical_work_field(output, shape, thread_buffer) result(status)
    type(native_logical_work_field), intent(inout) :: output
    integer(int32), intent(in) :: shape(2)
    logical, intent(in) :: thread_buffer
    logical, pointer :: pending(:, :)
    integer(int64) :: elements
    integer :: allocation_status
    status = 2
    if (associated(output%data) .or. associated(output%ptr)) return
    if (any(shape < 0)) return
    elements = int(shape(1), int64)*int(shape(2), int64)
    if (elements > huge(0_int64)/4_int64) return
    allocate (pending(shape(1), shape(2)), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    nullify (output%view)
    output%data => pending; output%ptr => pending
    output%nblocks = shape(2)
    output%active = .true.; output%thread_buffer = thread_buffer; output%owned = .true.
    status = 0
  end function
  integer(int32) function logical_work_field_view_2d(output, field, block) result(status)
    logical, pointer, intent(inout) :: output(:)
    type(native_logical_work_field), intent(in) :: field
    integer(int32), intent(in) :: block
    integer :: selected
    status = 0
    if (.not. field%active) then
      output => field%view; return
    end if
    selected = block
    if (field%thread_buffer) selected = 1
    status = 2
    if (field%owned) then
      if (.not. associated(field%data)) return
      if (selected < lbound(field%data, 2) .or. selected > ubound(field%data, 2)) return
      output => field%data(:, selected)
    else
      if (.not. associated(field%ptr)) return
      if (selected < lbound(field%ptr, 2) .or. selected > ubound(field%ptr, 2)) return
      output => field%ptr(:, selected)
    end if
    status = 0
  end function
  subroutine release_logical_work_field(field)
    type(native_logical_work_field), intent(inout) :: field
    if (field%owned .and. associated(field%data)) deallocate (field%data)
    nullify (field%data, field%ptr, field%view)
  end subroutine
end module forecast_integer_logical_work_fields
