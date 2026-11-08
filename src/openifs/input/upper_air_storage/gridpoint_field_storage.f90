module gridpoint_field_storage_port
  !! Own grid-point fields in native Fortran arrays.
  !! GFL contains transported fields and GFLSLP contains physics fields.
  !! Their shape is (positions,levels,fields,blocks), with encoded units.
  !! GFLPT and GFLPC are allocated empty companions in the admitted routes.
  !! Port: src/openifs/setup/grid_point_field_storage.S, including its
  !! operational entry. Historical descriptor bytes are not a native ABI.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use, intrinsic :: ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, &
                                                 ieee_nearest, ieee_support_underflow_control, ieee_get_underflow_mode, operator(/=)
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use md2asm_moist_air_gas_properties, only: thermal_constituent
  implicit none
  private
  public :: gridpoint_field_state, initialize_gridpoint_field
  public :: initialize_operational_gridpoint_field, zero_gridpoint_field
  public :: release_gridpoint_field, gridpoint_field_storage_is_fresh
  public :: gridpoint_field_storage_mode_supported

  type :: gridpoint_field_state
    !! The caller owns this record. Each allocated array has one owner.
    !! Constituents is a read-only borrowed view; its target must remain live
    !! until release. It does not duplicate the caller's field configuration.
    real(real64), allocatable :: gfl(:, :, :, :), gflslp(:, :, :, :)
    real(real64), allocatable :: gflpt(:, :, :, :), gflpc(:, :, :, :)
    type(thermal_constituent), pointer :: constituents(:) => null()
    integer(int32) :: pitch = 0, levels = 0, blocks = 0
    logical :: ready = .false.
  end type

  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  logical function gridpoint_field_storage_is_fresh(state) result(fresh)
    !! A fresh destination has no owner or published metadata.
    type(gridpoint_field_state), intent(in) :: state
    fresh = .false.
    if (allocated(state%gfl) .or. allocated(state%gflslp)) return
    if (allocated(state%gflpt) .or. allocated(state%gflpc)) return
    if (associated(state%constituents) .or. state%ready) return
    if (state%pitch /= 0 .or. state%levels /= 0 .or. state%blocks /= 0) return
    fresh = .true.
  end function

  logical function gridpoint_field_storage_mode_supported() result(supported)
    !! Require nearest rounding and gradual underflow. GNU Arm can report
    !! that underflow control is unavailable; then test the exact subnormal
    !! tiny(real64)/2. Restore incoming flags on every result.
    type(ieee_round_type) :: rounding
    type(ieee_status_type) :: saved
    real(real64), volatile :: minimum_normal, half_value, subnormal_probe
    logical :: gradual
    call ieee_get_status(saved)
    supported = .false.
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) goto 900
    if (ieee_support_underflow_control(0.0_real64)) then
      call ieee_get_underflow_mode(gradual)
      if (.not. gradual) goto 900
    else
      minimum_normal = tiny(0.0_real64)
      half_value = 0.5_real64
      subnormal_probe = minimum_normal*half_value
      if (transfer(subnormal_probe, 0_int64) /= ibset(0_int64, 51)) goto 900
    end if
    supported = .true.
900 call ieee_set_status(saved)
  end function

  integer(int32) function initialize_gridpoint_field(state, pitch, levels, blocks, constituents) result(status)
    !! Allocate the selected eight main and two physics fields.
    !! pitch and levels are 1..64; blocks is 1..128. Values are not filled.
    !! Return 0 on success, 1 on allocation failure, or 2 on admission refusal.
    !! Every failure leaves a fresh state, and preserves IEEE status and errno.
    type(gridpoint_field_state), intent(inout) :: state
    integer(int32), intent(in) :: pitch, levels, blocks
    type(thermal_constituent), target, intent(in) :: constituents(:)
    status = 2_int32
    if (pitch < 1 .or. pitch > 64 .or. levels < 1 .or. levels > 64) return
    if (blocks < 1 .or. blocks > 128) return
    if (.not. gridpoint_field_storage_is_fresh(state)) return
    if (.not. gridpoint_field_storage_mode_supported()) return
    status = allocate_fields(state, pitch, levels, blocks, 8_int32, 2_int32, constituents)
  end function

  integer(int32) function initialize_operational_gridpoint_field(state, constituents) result(status)
    !! Allocate the fixed operational tuple (17,137,388217,9,3,0,0).
    !! The live native dimensions are published after all four owners exist.
    !! This entry has the same status and ownership rules as the selected one.
    type(gridpoint_field_state), intent(inout) :: state
    type(thermal_constituent), target, intent(in) :: constituents(:)
    status = 2_int32
    if (.not. gridpoint_field_storage_is_fresh(state)) return
    if (.not. gridpoint_field_storage_mode_supported()) return
    status = allocate_fields(state, 17_int32, 137_int32, 388217_int32, 9_int32, 3_int32, constituents)
  end function

  integer(int32) function allocate_fields(state, pitch, levels, blocks, main_fields, physics_fields, constituents) result(status)
    !! Allocate in source order without reading or changing payload preimages.
    !! Standard Fortran owns empty arrays; their old one-byte address identity
    !! and the old 1096-byte descriptor representation are not claimed.
    type(gridpoint_field_state), intent(inout) :: state
    integer(int32), intent(in) :: pitch, levels, blocks, main_fields, physics_fields
    type(thermal_constituent), target, intent(in) :: constituents(:)
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer :: allocation_status
    integer(int32) :: ignored
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    status = 1_int32
    allocate (state%gfl(pitch, levels, main_fields, blocks), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    allocate (state%gflslp(pitch, levels, physics_fields, blocks), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    allocate (state%gflpt(pitch, levels, 0, blocks), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    allocate (state%gflpc(pitch, levels, 0, blocks), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    state%pitch = pitch
    state%levels = levels
    state%blocks = blocks
    state%constituents => constituents
    state%ready = .true.
    status = 0_int32
    goto 900
800 ignored = release_gridpoint_field(state)
900 error_number = saved_errno
    call ieee_set_status(saved)
  end function

  integer(int32) function zero_gridpoint_field(state) result(status)
    !! Set every logical element of the four owners to positive zero.
    !! Empty arrays and absent owners are not read. This adds no FP operation.
    type(gridpoint_field_state), intent(inout) :: state
    if (allocated(state%gfl)) state%gfl = 0.0_real64
    if (allocated(state%gflslp)) state%gflslp = 0.0_real64
    if (allocated(state%gflpt)) state%gflpt = 0.0_real64
    if (allocated(state%gflpc)) state%gflpc = 0.0_real64
    status = 0_int32
  end function

  integer(int32) function release_gridpoint_field(state) result(status)
    !! Release GFL, GFLSLP, GFLPT and GFLPC in source order.
    !! The borrowed constituent target stays live and unchanged. A second raw
    !! release succeeds and has no effect. No stale native views may be used.
    type(gridpoint_field_state), intent(inout) :: state
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    if (allocated(state%gfl)) deallocate (state%gfl)
    if (allocated(state%gflslp)) deallocate (state%gflslp)
    if (allocated(state%gflpt)) deallocate (state%gflpt)
    if (allocated(state%gflpc)) deallocate (state%gflpc)
    nullify (state%constituents)
    state%pitch = 0
    state%levels = 0
    state%blocks = 0
    state%ready = .false.
    error_number = saved_errno
    call ieee_set_status(saved)
    status = 0_int32
  end function
end module gridpoint_field_storage_port
