!> Standalone owner for operational field metadata and its constants.
!> Actual forecast integration borrows the existing root fields/constants
!> instead of calling this separate factory and duplicating production state.
module forecast_owned_operational_field_namespace
  use, intrinsic :: iso_c_binding, only: c_int, c_double, c_int64_t, c_ptr, c_f_pointer
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use grid_field_configuration_types_port, only: grid_field_configuration
  use grid_field_configuration_port, only: initialize_operational_grid_field_configuration
  use physical_constant_setup_port, only: forecast_physical_constants, initialize_physical_constants
  implicit none
  private
  public :: native_operational_field_namespace, create_operational_field_namespace, release_operational_field_namespace
  integer(c_int64_t), parameter :: owner_marker = int(z'47464C4F574E5231', c_int64_t)
  type :: native_operational_field_namespace
    type(grid_field_configuration) :: fields
    type(forecast_physical_constants) :: constants
    integer(c_int) :: controls(9) = 0_c_int, effects(10) = 0_c_int
    integer(c_int64_t) :: lifetime_marker = 0_c_int64_t
  end type native_operational_field_namespace
  interface
    function errno_address() bind(c, name='__errno_location') result(address)
      import :: c_ptr
      type(c_ptr) :: address
    end function errno_address
  end interface
contains
  !> Own one final-address context from borrowed TEXT and a positive NSTOP.
  !> OUTPUT must be an absent native pointer; inputs remain unchanged.
  !> Status0 publishes,1 reports allocation failure,2 refuses before mutation,
  !> and3 releases a private context after an admitted child refusal.
  !> The caller establishes the existing qualified floating-point environment.
  integer(c_int) function create_operational_field_namespace(text, stop_count, output) result(status)
    character(len=*), intent(in) :: text
    integer(c_int), intent(in) :: stop_count
    type(native_operational_field_namespace), pointer, intent(inout) :: output
    type(native_operational_field_namespace), pointer :: pending
    integer(c_int), pointer, volatile :: errno_word
    integer(c_int) :: incoming_errno, child_status
    integer :: allocation_status
    type(ieee_status_type) :: entry_status, child_status_flags
    status = 2_c_int
    if (len(text) < 1 .or. len(text) > 262144) return
    if (stop_count <= 0_c_int) return
    if (associated(output)) return
    call c_f_pointer(errno_address(), errno_word)
    incoming_errno = errno_word
    call ieee_get_status(entry_status)
    allocate (pending, stat=allocation_status)
    ! Suppress only allocation-service effects, before the accepted arithmetic.
    call ieee_set_status(entry_status)
    errno_word = incoming_errno
    if (allocation_status /= 0) then
      status = 1_c_int
      return
    end if
    ! Canonical field declaration defaults define source-fresh named storage.
    ! Define all native constant words through their source member names.

    pending%constants%rpi = 0.0_c_double
    pending%constants%rclum = 0.0_c_double
    pending%constants%rhpla = 0.0_c_double
    pending%constants%rkbol = 0.0_c_double
    pending%constants%rnavo = 0.0_c_double
    pending%constants%rday = 0.0_c_double
    pending%constants%rdayi = 0.0_c_double
    pending%constants%rhour = 0.0_c_double
    pending%constants%rea = 0.0_c_double
    pending%constants%repsm = 0.0_c_double
    pending%constants%rsiyea = 0.0_c_double
    pending%constants%rsiday = 0.0_c_double
    pending%constants%romega = 0.0_c_double
    pending%constants%ra = 0.0_c_double
    pending%constants%rg = 0.0_c_double
    pending%constants%r1sa = 0.0_c_double
    pending%constants%deg2rad = 0.0_c_double
    pending%constants%rsigma = 0.0_c_double
    pending%constants%ri0 = 0.0_c_double
    pending%constants%r = 0.0_c_double
    pending%constants%rmd = 0.0_c_double
    pending%constants%rmv = 0.0_c_double
    pending%constants%rmo3 = 0.0_c_double
    pending%constants%rd = 0.0_c_double
    pending%constants%rv = 0.0_c_double
    pending%constants%rcpd = 0.0_c_double
    pending%constants%rcpv = 0.0_c_double
    pending%constants%rcvd = 0.0_c_double
    pending%constants%rcvv = 0.0_c_double
    pending%constants%rkappa = 0.0_c_double
    pending%constants%retv = 0.0_c_double
    pending%constants%rmco2 = 0.0_c_double
    pending%constants%rmch4 = 0.0_c_double
    pending%constants%rmn2o = 0.0_c_double
    pending%constants%rmco = 0.0_c_double
    pending%constants%rmhcho = 0.0_c_double
    pending%constants%rmno2 = 0.0_c_double
    pending%constants%rmso2 = 0.0_c_double
    pending%constants%rmso4 = 0.0_c_double
    pending%constants%rmcfc11 = 0.0_c_double
    pending%constants%rmcfc12 = 0.0_c_double
    pending%constants%rmhcfc22 = 0.0_c_double
    pending%constants%rmccl4 = 0.0_c_double
    pending%constants%rcw = 0.0_c_double
    pending%constants%rcs = 0.0_c_double
    pending%constants%ratm = 0.0_c_double
    pending%constants%rtt = 0.0_c_double
    pending%constants%rlvtt = 0.0_c_double
    pending%constants%rlstt = 0.0_c_double
    pending%constants%rlvzer = 0.0_c_double
    pending%constants%rlszer = 0.0_c_double
    pending%constants%rlmlt = 0.0_c_double
    pending%constants%rdt = 0.0_c_double
    pending%constants%restt = 0.0_c_double
    pending%constants%rgamw = 0.0_c_double
    pending%constants%rbetw = 0.0_c_double
    pending%constants%ralpw = 0.0_c_double
    pending%constants%rgams = 0.0_c_double
    pending%constants%rbets = 0.0_c_double
    pending%constants%ralps = 0.0_c_double
    pending%constants%ralpd = 0.0_c_double
    pending%constants%rbetd = 0.0_c_double
    pending%constants%rgamd = 0.0_c_double
    pending%constants%rsnan = 0.0_c_double
    pending%constants%initialized = 0_c_int
    pending%constants%reserved = 0_c_int
    child_status = initialize_physical_constants(pending%constants)
    if (child_status /= 0_c_int) goto 900
    pending%controls = [137_c_int, 0_c_int, stop_count, 1_c_int, 1_c_int, 0_c_int, 1_c_int, 1_c_int, 1_c_int]
    child_status = initialize_operational_grid_field_configuration(pending%fields, pending%constants, &
                                                                   text, pending%controls, pending%effects)
    if (child_status /= 0_c_int) goto 900
    pending%lifetime_marker = owner_marker
    output => pending
    status = 0_c_int
    return
900 continue
    ! Retain numerical child flags while removing incidental free effects.
    call ieee_get_status(child_status_flags)
    deallocate (pending)
    call ieee_set_status(child_status_flags)
    errno_word = incoming_errno
    status = 3_c_int
  end function create_operational_field_namespace

  !> Release only a live context returned by this factory, after all borrowers.
  !> Clear the source lifetime marker before free, preserving IEEE and errno.
  !> The native caller pointer becomes absent. An absent or wrong marker is2.
  integer(c_int) function release_operational_field_namespace(context) result(status)
    type(native_operational_field_namespace), pointer, intent(inout) :: context
    integer(c_int), pointer, volatile :: errno_word
    integer(c_int) :: incoming_errno
    type(ieee_status_type) :: entry_status
    status = 2_c_int
    if (.not. associated(context)) return
    if (context%lifetime_marker /= owner_marker) return
    context%lifetime_marker = 0_c_int64_t
    call c_f_pointer(errno_address(), errno_word)
    incoming_errno = errno_word
    call ieee_get_status(entry_status)
    deallocate (context)
    nullify (context)
    call ieee_set_status(entry_status)
    errno_word = incoming_errno
    status = 0_c_int
  end function release_operational_field_namespace
end module forecast_owned_operational_field_namespace
