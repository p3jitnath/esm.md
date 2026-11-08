!> Allocate missing next-time fields in their original source order.
!! This later stage reuses canonical GMV owners and keeps GFLT1 separate
!! from the four initial grid-point owners. It performs no weather equation.
module forecast_next_time_field_storage
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use forecast_grid_motion_types, only: native_grid_motion_state
  implicit none
  private
  public :: next_time_field_shape, native_next_time_gridpoint_state
  public :: prepare_next_time_fields, prepare_operational_next_time_fields, prepare_runtime_next_time_fields
  public :: release_next_time_fields, release_operational_next_time_fields
  !> Live integer counts from geometry and GFL registration.
  !! pitch is points per block;levels and blocks count full levels and blocks.
  !! constituent_fields is the original NDIM1,including a valid zero extent.
  !! GMV full/surface field counts come from motion%YT1%NDIM/%NDIMS.
  type :: next_time_field_shape
    integer(int32) :: pitch = 0, levels = 0, blocks = 0, constituent_fields = 0
  end type
  !> Own only the independent later GFLT1(P,L,NDIM1,B) FP64 array.
  !! Field units are those of the registered constituents. Newly allocated
  !! logical cells contain positive zero. This state is not GFLPT or GFLSLP
  !! and does not change the accepted initial gridpoint_field_state type.
  type :: native_next_time_gridpoint_state
    real(real64), allocatable :: gflt1(:, :, :, :)
  end type
  interface
    function next_time_errno_location() bind(C, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Prepare the historical selected shape domain.
  !! pitch/levels are1:64,blocks1:128,and all three field counts0:64.
  !! Existing allocated owners must already obey their declared source shape.
  !! They retain every bit and address;the entry neither resizes nor clears
  !! them. byte_limit optionally bounds only newly requested logical bytes.
  !! Status0 succeeds,1 rolls back only this call's acquired owners after an
  !! allocation failure,and2 refuses metadata or floating-point environment.
  !! Full FP64 environment qualification remains the caller's responsibility:
  !! on the current Arm target it includes the existing exact FPCR0 guard.
  !! Portable checks require nearest rounding and gradual underflow. Source
  !! IEEE status and Linux errno are preserved on every supported return.
  integer(int32) function prepare_next_time_fields(motion, next, shape, byte_limit) result(status)
    type(native_grid_motion_state), intent(inout) :: motion
    type(native_next_time_gridpoint_state), intent(inout) :: next
    type(next_time_field_shape), intent(in) :: shape
    integer(int64), intent(in), optional :: byte_limit
    status = prepare_selected_next_time_fields(motion, next, shape, 64_int32, 64_int32, 128_int32, byte_limit)
  end function

  !> Prepare the historical operational profile without the live-pitch flag.
  !! pitch is1:64,levels1:137,blocks1:388217;field counts remain0:64.
  !! Allocation,value,preservation and failure rules match the selected entry.
  integer(int32) function prepare_operational_next_time_fields(motion, next, shape, byte_limit) result(status)
    type(native_grid_motion_state), intent(inout) :: motion
    type(native_next_time_gridpoint_state), intent(inout) :: next
    type(next_time_field_shape), intent(in) :: shape
    integer(int64), intent(in), optional :: byte_limit
    status = prepare_selected_next_time_fields(motion, next, shape, 64_int32, 137_int32, 388217_int32, byte_limit)
  end function

  !> Prepare the operational MD2ASM_RUNTIME_INPUT_DIMENSIONS profile.
  !! This distinct native entry admits live pitch1:1024 with the same137-level
  !! and388217-block bounds. It changes no field order,value or calculation.
  !! Dimensions remain runtime inputs;no grid size is compiled into an array.
  integer(int32) function prepare_runtime_next_time_fields(motion, next, shape, byte_limit) result(status)
    type(native_grid_motion_state), intent(inout) :: motion
    type(native_next_time_gridpoint_state), intent(inout) :: next
    type(next_time_field_shape), intent(in) :: shape
    integer(int64), intent(in), optional :: byte_limit
    status = prepare_selected_next_time_fields(motion, next, shape, 1024_int32, 137_int32, 388217_int32, byte_limit)
  end function

  integer(int32) function prepare_selected_next_time_fields(motion, next, shape, max_pitch, max_levels, max_blocks, &
                                                            byte_limit) result(status)
    type(native_grid_motion_state), intent(inout) :: motion
    type(native_next_time_gridpoint_state), intent(inout) :: next
    type(next_time_field_shape), intent(in) :: shape
    integer(int32), intent(in) :: max_pitch, max_levels, max_blocks
    integer(int64), intent(in), optional :: byte_limit
    type(ieee_status_type) :: saved_fp
    type(ieee_round_type) :: rounding
    integer(c_int), pointer :: errno_pointer
    integer(c_int) :: saved_errno
    integer(int64) :: cells, requested, budget
    integer(int32) :: general_fields, surface_fields
    integer :: allocation_status
    logical :: acquired(3)
    real(real64), volatile :: normal_minimum, half_subnormal
    call c_f_pointer(next_time_errno_location(), errno_pointer)
    saved_errno = errno_pointer
    call ieee_get_status(saved_fp)
    status = 2
    acquired = .false.
    if (shape%pitch < 1 .or. shape%pitch > max_pitch) goto 900
    if (shape%levels < 1 .or. shape%levels > max_levels) goto 900
    if (shape%blocks < 1 .or. shape%blocks > max_blocks) goto 900
    general_fields = motion%yt1%ndim
    surface_fields = motion%yt1%ndims
    if (general_fields < 0 .or. general_fields > 64) goto 900
    if (surface_fields < 0 .or. surface_fields > 64) goto 900
    if (shape%constituent_fields < 0 .or. shape%constituent_fields > 64) goto 900
    cells = int(shape%pitch, int64)*int(shape%levels, int64)*int(shape%blocks, int64)
    requested = 0
    if (.not. allocated(motion%gmvt1)) requested = requested + 8_int64*cells*int(general_fields, int64)
    if (.not. allocated(motion%gmvt1s)) requested = requested + &
                                                    8_int64*int(shape%pitch, int64)*int(surface_fields, &
                                                                                        int64)*int(shape%blocks, int64)
    if (.not. allocated(next%gflt1)) requested = requested + 8_int64*cells*int(shape%constituent_fields, int64)
    budget = huge(0_int64)
    if (present(byte_limit)) budget = byte_limit
    if (budget < 0 .or. requested > budget) goto 900
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) goto 900
    normal_minimum = tiny(0.0_real64)
    half_subnormal = normal_minimum*0.5_real64
    if (transfer(half_subnormal, 0_int64) /= int(z'0008000000000000', int64)) goto 900
    ! GP_MODEL creates and zeroes missing GMVT1,GMVT1S,GFLT1 in that order.
    if (.not. allocated(motion%gmvt1)) then
      allocate (motion%gmvt1(shape%pitch, shape%levels, general_fields, shape%blocks), stat=allocation_status)
      if (allocation_status /= 0) goto 800
      acquired(1) = .true.
      motion%gmvt1 = 0.0_real64
    end if
    if (.not. allocated(motion%gmvt1s)) then
      allocate (motion%gmvt1s(shape%pitch, surface_fields, shape%blocks), stat=allocation_status)
      if (allocation_status /= 0) goto 800
      acquired(2) = .true.
      motion%gmvt1s = 0.0_real64
    end if
    if (.not. allocated(next%gflt1)) then
      allocate (next%gflt1(shape%pitch, shape%levels, shape%constituent_fields, shape%blocks), stat=allocation_status)
      if (allocation_status /= 0) goto 800
      acquired(3) = .true.
      next%gflt1 = 0.0_real64
    end if
    status = 0
    goto 900
800 continue
    call free_selected_next_time_fields(motion, next, acquired)
    status = 1
900 continue
    call ieee_set_status(saved_fp)
    errno_pointer = saved_errno
  end function

  !> Release next-time owners in source FIELDS_DELETE order.
  !! Free GMVT1,then GMVT1S,then GFLT1,leaving all other canonical motion and
  !! initial grid-point owners unchanged. Unallocated owners are valid no-ops.
  !! Views into these arrays must already have expired. Release precedes the
  !! enclosing GMV/GFL/outer-state release. IEEE status and errno are retained.
  integer(int32) function release_next_time_fields(motion, next) result(status)
    type(native_grid_motion_state), intent(inout) :: motion
    type(native_next_time_gridpoint_state), intent(inout) :: next
    type(ieee_status_type) :: saved_fp
    integer(c_int), pointer :: errno_pointer
    integer(c_int) :: saved_errno
    call c_f_pointer(next_time_errno_location(), errno_pointer)
    saved_errno = errno_pointer
    call ieee_get_status(saved_fp)
    call free_selected_next_time_fields(motion, next, [.true., .true., .true.])
    call ieee_set_status(saved_fp)
    errno_pointer = saved_errno
    status = 0
  end function

  !> The operational release has the same owner order and empty-state rule.
  integer(int32) function release_operational_next_time_fields(motion, next) result(status)
    type(native_grid_motion_state), intent(inout) :: motion
    type(native_next_time_gridpoint_state), intent(inout) :: next
    status = release_next_time_fields(motion, next)
  end function

  !> Release only the declared acquired set;keep every previous owner intact.
  subroutine free_selected_next_time_fields(motion, next, acquired)
    type(native_grid_motion_state), intent(inout) :: motion
    type(native_next_time_gridpoint_state), intent(inout) :: next
    logical, intent(in) :: acquired(3)
    if (acquired(1)) then
      if (allocated(motion%gmvt1)) deallocate (motion%gmvt1)
    end if
    if (acquired(2)) then
      if (allocated(motion%gmvt1s)) deallocate (motion%gmvt1s)
    end if
    if (acquired(3)) then
      if (allocated(next%gflt1)) deallocate (next%gflt1)
    end if
  end subroutine
end module forecast_next_time_field_storage
