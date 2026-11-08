!> Own the selected empty aerosol descriptor and ordered parameter setup.
module selected_aerosol_parameter_setup_mod
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_intptr_t, c_int, c_ptr, c_f_pointer
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use ieee_exceptions, only: ieee_get_flag, ieee_set_flag, ieee_underflow, ieee_inexact
  use yoeaeratm, only: teaeratm, type_aero_desc
  use yoeaerlid, only: teaerlid
  use yoeaermap, only: teaermap
  use yoeaersnk, only: teaersnk
  use yoeaersrc, only: teaersrc
  use yoeaervol, only: teaervol
  use yoedbug, only: tedbug
  use selected_aerosol_parameter_fields_mod, only: aerosol_optical_parameter_record, &
                                                   aerosol_parameter_control_record, initialize_selected_aerosol_parameter_fields
  implicit none
  private
  public :: initialize_selected_aerosol_parameters, release_selected_aerosol_parameters
  interface
    function errno_address() bind(C, name='__errno_location') result(address)
      import :: c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Create the empty native descriptor, then set selected aerosol parameters.
  !! CONTROLS contains zero NAERO/NACTAERO, NAERMACC one and LESO4HIS false.
  !! NINDAT is the current model date; NSSSSS is seconds in 0:86399.
  !! All eight caller-owned records and CONTROLS have separate native storage.
  !! YAERO_DESC must be disassociated. Other owners and source-unwritten
  !! members stay incoming. NINIDAY has no invented default.
  !! A private native TYPE_AERO_DESC array with bounds 1:0 owns the compiler's
  !! empty-allocation token. No element is accessed. The compiler constructs
  !! its descriptor. Success publishes it before the source field sequence.
  !! Return 0 on completion, 1 on allocation failure with public records
  !! unchanged, or 2 before mutation for unsupported input. Success preserves
  !! incoming errno and FP flags; allocator failure retains its actual errno.
  integer(int32) function initialize_selected_aerosol_parameters(controls,atmosphere,lidar,mapping,sinks,sources,volume,debug,optical) result(status)
    type(aerosol_parameter_control_record), intent(in), target :: controls
    type(teaeratm), intent(inout), target :: atmosphere
    type(teaerlid), intent(inout), target :: lidar
    type(teaermap), intent(inout), target :: mapping
    type(teaersnk), intent(inout), target :: sinks
    type(teaersrc), intent(inout), target :: sources
    type(teaervol), intent(inout), target :: volume
    type(tedbug), intent(inout), target :: debug
    type(aerosol_optical_parameter_record), intent(inout), target :: optical
    type(type_aero_desc), pointer :: empty_owner(:)
    integer(c_int), pointer :: errno_value
    integer(c_int) :: incoming_errno
    integer(c_intptr_t) :: address(9)
    integer(int64) :: extent(9)
    integer :: first, second, allocation_status
    status = 2_int32
    if (controls%naero /= 0 .or. controls%nactaero /= 0 .or. controls%naermacc /= 1) return
    if (controls%leso4his) return
    if (controls%nsssss < 0 .or. controls%nsssss > 86399) return
    if (associated(atmosphere%yaero_desc)) return
    address(1) = transfer(c_loc(controls), 0_c_intptr_t)
    extent(1) = storage_size(controls, kind=int64)/8_int64
    address(2) = transfer(c_loc(atmosphere), 0_c_intptr_t)
    extent(2) = storage_size(atmosphere, kind=int64)/8_int64
    address(3) = transfer(c_loc(lidar), 0_c_intptr_t)
    extent(3) = storage_size(lidar, kind=int64)/8_int64
    address(4) = transfer(c_loc(mapping), 0_c_intptr_t)
    extent(4) = storage_size(mapping, kind=int64)/8_int64
    address(5) = transfer(c_loc(sinks), 0_c_intptr_t)
    extent(5) = storage_size(sinks, kind=int64)/8_int64
    address(6) = transfer(c_loc(sources), 0_c_intptr_t)
    extent(6) = storage_size(sources, kind=int64)/8_int64
    address(7) = transfer(c_loc(volume), 0_c_intptr_t)
    extent(7) = storage_size(volume, kind=int64)/8_int64
    address(8) = transfer(c_loc(debug), 0_c_intptr_t)
    extent(8) = storage_size(debug, kind=int64)/8_int64
    address(9) = transfer(c_loc(optical), 0_c_intptr_t)
    extent(9) = storage_size(optical, kind=int64)/8_int64
    do first = 1, 9
      if (address(first) <= 0_c_intptr_t) return
      if (address(first) > huge(address(first)) - extent(first)) return
      do second = 1, first - 1
        if (address(first) <= address(second)) then
          if (address(second) - address(first) < extent(first)) return
        else
          if (address(first) - address(second) < extent(second)) return
        end if
      end do
    end do
    if (.not. supported_floating_mode()) return
    call c_f_pointer(errno_address(), errno_value)
    incoming_errno = errno_value
    nullify (empty_owner)
    allocate (empty_owner(0), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1_int32
      return
    end if
    atmosphere%yaero_desc => empty_owner
    nullify (empty_owner)
    errno_value = incoming_errno
    call initialize_selected_aerosol_parameter_fields(controls, atmosphere, lidar, mapping, sinks, sources, volume, debug, optical)
    status = 0_int32
  end function

  !> Release only the zero-element native array owned by this setup.
  !! ATMOSPHERE remains caller owned. Its other members remain unchanged.
  !! Repeated release succeeds. Natural allocation metadata is compiler owned.
  !! Return 0 after release, 1 on deallocation failure, or 2 for an associated
  !! nonempty array that does not belong to this selected source branch.
  !! Incoming errno is retained, and no FP operation or flag change is needed.
  integer(int32) function release_selected_aerosol_parameters(atmosphere) result(status)
    type(teaeratm), intent(inout) :: atmosphere
    integer(c_int), pointer :: errno_value
    integer(c_int) :: incoming_errno
    integer :: release_status
    status = 2_int32
    if (associated(atmosphere%yaero_desc)) then
      if (size(atmosphere%yaero_desc) /= 0) return
    end if
    call c_f_pointer(errno_address(), errno_value)
    incoming_errno = errno_value
    status = 0_int32
    if (associated(atmosphere%yaero_desc)) then
      deallocate (atmosphere%yaero_desc, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    errno_value = incoming_errno
  end function

  !> Require nearest rounding and gradual underflow without changing flags.
  !! The launcher establishes the complete target floating-point contract.
  logical function supported_floating_mode() result(supported)
    type(ieee_round_type) :: rounding
    real(real64), volatile :: smallest_normal, half, subnormal
    logical :: incoming_underflow, incoming_inexact
    supported = .false.
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) return
    call ieee_get_flag(ieee_underflow, incoming_underflow)
    call ieee_get_flag(ieee_inexact, incoming_inexact)
    smallest_normal = tiny(0.0_real64)
    half = 0.5_real64
    subnormal = smallest_normal*half
    supported = transfer(subnormal, 0_int64) == int(z'0008000000000000', int64)
    call ieee_set_flag(ieee_underflow, incoming_underflow)
    call ieee_set_flag(ieee_inexact, incoming_inexact)
  end function
end module selected_aerosol_parameter_setup_mod
