module spectral_field_context_port
  !! Own a serial spectral record at a stable native address.
  use, intrinsic :: iso_fortran_env, only: int32,int64
  use, intrinsic :: iso_c_binding, only: c_ptr,c_int,c_f_pointer
  use, intrinsic :: ieee_exceptions, only: ieee_status_type,ieee_get_status,ieee_set_status
  use spectral_field_storage_port, only: spectral_field_state,initialize_serial_spectral_field, &
    release_spectral_field,spectral_storage_mode_supported
  implicit none
  private
  public :: serial_spectral_field_context,create_serial_spectral_field,release_serial_spectral_field_context
  type :: serial_spectral_field_context
    !! This field pointer owns its target. Do not copy an active context.
    type(spectral_field_state), pointer :: field=>null()
    logical :: ready=.false.
  end type
  interface
    function errno_address() bind(C,name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  integer(int32) function create_serial_spectral_field(output,levels,n,identifiers,byte_cap) result(status)
    !! output must have no owned target. The child retains all shape, field
    !! identifier and payload-cap admission. A failure publishes no owner.
    type(serial_spectral_field_context), intent(inout) :: output
    integer(int32), intent(in) :: levels,n,identifiers(5)
    integer(int64), intent(in) :: byte_cap
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer :: ios
    integer(int32) :: ignored
    status=2
    if(output%ready.or.associated(output%field)) return
    if(.not.((levels>=1.and.levels<=64.and.n>=0.and.n<=63).or.(levels==137.and.n==1279))) return
    if(.not.spectral_storage_mode_supported()) return
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(),error_number)
    saved_errno=error_number
    status=1
    allocate(output%field,stat=ios)
    if(ios/=0) goto 900
    status=initialize_serial_spectral_field(output%field,levels,n,identifiers,byte_cap)
    if(status/=0) then
      ignored=release_spectral_field(output%field)
      deallocate(output%field)
      nullify(output%field)
    else
      output%ready=.true.
    end if
900 error_number=saved_errno
    call ieee_set_status(saved)
  end function
  integer(int32) function release_serial_spectral_field_context(output) result(status)
    !! Release the complete inner record, then the outer native target.
    !! An already empty context is harmless under the new native interface.
    type(serial_spectral_field_context), intent(inout) :: output
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(),error_number)
    saved_errno=error_number
    status=0
    if(associated(output%field)) then
      status=release_spectral_field(output%field)
      deallocate(output%field)
      nullify(output%field)
    end if
    output%ready=.false.
    error_number=saved_errno
    call ieee_set_status(saved)
  end function
end module spectral_field_context_port
