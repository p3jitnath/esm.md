module gridpoint_field_context_port
  !! Create an owned native grid-point context around its four arrays.
  !! Ports: grid_point_field_context.S and operational_grid_point_field_context.S.
  !! The compiler owns the outer record and array descriptions. The native
  !! allocation does not claim the old context's marker or address identity.
  use, intrinsic :: iso_fortran_env, only: int32
  use, intrinsic :: iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use md2asm_moist_air_gas_properties, only: thermal_constituent
  use gridpoint_field_storage_port, only: gridpoint_field_state, &
                                          initialize_gridpoint_field, initialize_operational_gridpoint_field, &
                                          release_gridpoint_field, gridpoint_field_storage_mode_supported
  implicit none
  private
  public :: create_gridpoint_field_context, create_operational_gridpoint_field_context
  public :: release_gridpoint_field_context
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  integer(int32) function create_gridpoint_field_context(pitch, levels, blocks, constituents, context) result(status)
    !! The output must be unallocated. On success it owns all storage, while
    !! constituents remains a read-only borrowed array with caller lifetime.
    !! The selected bounds are pitch/levels1..64 and blocks1..128.
    !! Return0 success,1 allocation failure,2 admission refusal; no failed
    !! path publishes the output or changes incoming IEEE status and errno.
    integer(int32), intent(in) :: pitch, levels, blocks
    type(thermal_constituent), target, intent(in) :: constituents(:)
    type(gridpoint_field_state), allocatable, intent(inout) :: context
    if (pitch < 1 .or. pitch > 64 .or. levels < 1 .or. levels > 64 .or. blocks < 1 .or. blocks > 128) then
      status = 2_int32
      return
    end if
    status = create_context(pitch, levels, blocks, constituents, context, .false.)
  end function

  integer(int32) function create_operational_gridpoint_field_context(constituents, context) result(status)
    !! Create the fixed (17,137,388217,9,3,0,0) operational owner.
    !! The whole live state is published only after four successful owners.
    type(thermal_constituent), target, intent(in) :: constituents(:)
    type(gridpoint_field_state), allocatable, intent(inout) :: context
    status = create_context(17_int32, 137_int32, 388217_int32, constituents, context, .true.)
  end function

  integer(int32) function create_context(pitch, levels, blocks, constituents, context, operational) result(status)
    integer(int32), intent(in) :: pitch, levels, blocks
    type(thermal_constituent), target, intent(in) :: constituents(:)
    type(gridpoint_field_state), allocatable, intent(inout) :: context
    logical, intent(in) :: operational
    type(gridpoint_field_state), allocatable :: staged
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer :: allocation_status
    integer(int32) :: ignored
    status = 2_int32
    if (allocated(context)) return
    if (.not. gridpoint_field_storage_mode_supported()) return
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    status = 1_int32
    allocate (staged, stat=allocation_status)
    if (allocation_status /= 0) goto 900
    if (operational) then
      status = initialize_operational_gridpoint_field(staged, constituents)
    else
      status = initialize_gridpoint_field(staged, pitch, levels, blocks, constituents)
    end if
    if (status /= 0_int32) then
      ignored = release_gridpoint_field(staged)
      deallocate (staged)
      goto 900
    end if
    call move_alloc(staged, context)
900 error_number = saved_errno
    call ieee_set_status(saved)
  end function

  integer(int32) function release_gridpoint_field_context(context) result(status)
    !! Release only a context returned by a successful constructor.
    !! This invalidates all borrowed numerical views, but not constituents.
    !! A missing or unpublished context returns2 without mutation.
    type(gridpoint_field_state), allocatable, intent(inout) :: context
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer(int32) :: ignored
    status = 2_int32
    if (.not. allocated(context)) return
    if (.not. context%ready) return
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    ignored = release_gridpoint_field(context)
    deallocate (context)
    error_number = saved_errno
    call ieee_set_status(saved)
    status = 0_int32
  end function
end module gridpoint_field_context_port
