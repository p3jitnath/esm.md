!> Shared native storage operations for the three physics work records.
module physics_work_record_support_mod
  use iso_fortran_env, only: int32, int64
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use forecast_registry_field_types, only: field_2d => native_registry_field_2d, field_3d => native_registry_field_3d
  use forecast_registry_storage, only: allocate_registry_field_2d, allocate_registry_field_3d
  use forecast_integer_logical_work_fields, only: field_int2d => native_integer_work_field, allocate_integer_work_field
  implicit none
  private
  public :: work_record_status_snapshot, capture_work_record_status, restore_work_record_status
  public :: create_work_field, delete_work_field, increment_work_word, abort_storage_failure
  type :: work_record_status_snapshot
    type(ieee_status_type) :: floating_status
    type(c_ptr) :: errno_pointer
    integer(c_int) :: errno_value
  end type
  interface create_work_field
    module procedure create_real_2d, create_real_3d, create_integer_2d
  end interface
  interface delete_work_field
    module procedure delete_real_2d, delete_real_3d, delete_integer_2d
  end interface
  interface
    function errno_address() bind(c, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
    subroutine abort_storage_failure() bind(c, name="abort")
    end subroutine
  end interface
contains
  subroutine capture_work_record_status(snapshot)
    type(work_record_status_snapshot), intent(out) :: snapshot
    integer(c_int), pointer, volatile :: target_errno
    call ieee_get_status(snapshot%floating_status)
    snapshot%errno_pointer = errno_address()
    call c_f_pointer(snapshot%errno_pointer, target_errno)
    snapshot%errno_value = target_errno
  end subroutine
  subroutine restore_work_record_status(snapshot)
    type(work_record_status_snapshot), intent(in) :: snapshot
    integer(c_int), pointer, volatile :: target_errno
    call c_f_pointer(snapshot%errno_pointer, target_errno)
    target_errno = snapshot%errno_value
    call ieee_set_status(snapshot%floating_status)
  end subroutine
  subroutine increment_work_word(word)
    integer(int64), intent(inout) :: word
    if (word == huge(word)) then
      word = -huge(word) - 1_int64
    else
      word = word + 1_int64
    end if
  end subroutine
  !> Acquire metadata before its uninitialized native payload; status1 is OOM.
  integer(int32) function create_real_2d(output, shape, thread_buffer) result(status)
    type(field_2d), pointer, intent(inout) :: output
    integer(int32), intent(in) :: shape(2)
    logical, intent(in) :: thread_buffer
    type(field_2d), pointer :: pending
    integer :: allocation_status
    nullify (pending)
    allocate (pending, stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    status = allocate_registry_field_2d(pending, shape, thread_buffer)
    if (status /= 0) then
      deallocate (pending); return
    end if
    output => pending
    status = 0
  end function
  !> Release only the source-owned DATA and metadata; public views stay.
  subroutine delete_real_2d(output)
    type(field_2d), pointer, intent(inout) :: output
    if (.not. associated(output)) return
    if (associated(output%data)) deallocate (output%data)
    deallocate (output)
    nullify (output)
  end subroutine
  !> Acquire metadata before its uninitialized native payload; status1 is OOM.
  integer(int32) function create_real_3d(output, shape, thread_buffer) result(status)
    type(field_3d), pointer, intent(inout) :: output
    integer(int32), intent(in) :: shape(3)
    logical, intent(in) :: thread_buffer
    type(field_3d), pointer :: pending
    integer :: allocation_status
    nullify (pending)
    allocate (pending, stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    status = allocate_registry_field_3d(pending, shape, thread_buffer)
    if (status /= 0) then
      deallocate (pending); return
    end if
    output => pending
    status = 0
  end function
  !> Release only the source-owned DATA and metadata; public views stay.
  subroutine delete_real_3d(output)
    type(field_3d), pointer, intent(inout) :: output
    if (.not. associated(output)) return
    if (associated(output%data)) deallocate (output%data)
    deallocate (output)
    nullify (output)
  end subroutine
  !> Acquire metadata before its uninitialized native payload; status1 is OOM.
  integer(int32) function create_integer_2d(output, shape, thread_buffer) result(status)
    type(field_int2d), pointer, intent(inout) :: output
    integer(int32), intent(in) :: shape(2)
    logical, intent(in) :: thread_buffer
    type(field_int2d), pointer :: pending
    integer :: allocation_status
    nullify (pending)
    allocate (pending, stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    status = allocate_integer_work_field(pending, shape, thread_buffer)
    if (status /= 0) then
      deallocate (pending); return
    end if
    output => pending
    status = 0
  end function
  !> Release only the source-owned DATA and metadata; public views stay.
  subroutine delete_integer_2d(output)
    type(field_int2d), pointer, intent(inout) :: output
    if (.not. associated(output)) return
    if (associated(output%data)) deallocate (output%data)
    deallocate (output)
    nullify (output)
  end subroutine
end module physics_work_record_support_mod
