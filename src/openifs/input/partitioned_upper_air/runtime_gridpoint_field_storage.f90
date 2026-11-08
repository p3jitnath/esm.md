module runtime_gridpoint_field_storage_port
  !! Bind live counts and own four distributed atmospheric field arrays.
  !! Counts are dimensionless. Payload values retain their physical units.
  !! Native field storage and its borrowed thermal metadata use the existing
  !! gridpoint_field_state identity; this module creates no Geometry owner.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use gridpoint_field_storage_port, only: gridpoint_field_state, gridpoint_field_storage_is_fresh, &
                                          gridpoint_field_storage_mode_supported, release_gridpoint_field
  use md2asm_moist_air_gas_properties, only: thermal_constituent
  implicit none
  private
  public :: runtime_gridpoint_shape, bind_runtime_distributed_gridpoint_shape
  public :: initialize_runtime_distributed_gridpoint_field
  type :: runtime_gridpoint_shape
    integer(int32) :: pitch = 0, levels = 0, blocks = 0
    integer(int32) :: main_fields = 0, physics_fields = 0, tendency_fields = 0, iteration_fields = 0
  end type
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  integer(int32) function bind_runtime_distributed_gridpoint_shape(output,pitch,levels,blocks,local_points,global_points,field_counts) result(status)
    !! Publish7 native counts only after validating the complete live tuple.
    !! local/global counts are positive signed-int32 values; fields are0..512.
    !! The caller reads these arguments from its canonical Geometry/namespace.
    type(runtime_gridpoint_shape), intent(inout) :: output
    integer(int32), intent(in) :: pitch, levels, blocks, local_points, global_points
    integer(int32), intent(in) :: field_counts(4)
    integer(int64) :: expected_blocks
    status = 2_int32
    if (pitch < 1 .or. pitch > 1024 .or. levels < 1 .or. levels > 256) return
    if (local_points < 1 .or. global_points < 1 .or. local_points > global_points) return
    expected_blocks = (int(local_points, int64) + int(pitch, int64) - 1_int64)/int(pitch, int64)
    if (int(blocks, int64) /= expected_blocks) return
    if (any(field_counts < 0) .or. any(field_counts > 512)) return
    output = runtime_gridpoint_shape(pitch, levels, blocks, field_counts(1), field_counts(2), field_counts(3), field_counts(4))
    status = 0_int32
  end function

  integer(int32) function initialize_runtime_distributed_gridpoint_field(output,pitch,levels,blocks,local_points,global_points,field_counts,constituents,byte_cap) result(status)
    !! Allocate GFL,GFLSLP,GFLPT,GFLPC in source order, with no payload fill.
    !! A positive signed-int64 byte_cap bounds all four source reservations;
    !! an empty owner contributes1 byte to this admission calculation. Native
    !! empty-array address identity is compiler-owned and is not compared.
    !! The readonly constituent target remains live until output is released.
    !! Return0 success,1 allocation failure,2 atomic admission refusal.
    type(gridpoint_field_state), intent(inout) :: output
    integer(int32), intent(in) :: pitch, levels, blocks, local_points, global_points
    integer(int32), intent(in) :: field_counts(4)
    type(thermal_constituent), target, intent(in) :: constituents(:)
    integer(int64), intent(in) :: byte_cap
    type(runtime_gridpoint_shape) :: shape
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer(int32) :: rc, ignored
    integer(int64) :: plane, reservations
    integer :: j, allocation_status
    status = 2_int32
    if (.not. gridpoint_field_storage_is_fresh(output)) return
    if (.not. gridpoint_field_storage_mode_supported()) return
    rc = bind_runtime_distributed_gridpoint_shape(shape, pitch, levels, blocks, local_points, global_points, field_counts)
    if (rc /= 0 .or. byte_cap <= 0_int64) return
    plane = 8_int64*int(pitch, int64)*int(levels, int64)*int(blocks, int64)
    reservations = 0_int64
    do j = 1, 4
      reservations = reservations + max(1_int64, plane*int(field_counts(j), int64))
    end do
    if (reservations > byte_cap) return
    if (all([pitch, levels, blocks, field_counts] == [17, 137, 97055, 9, 3, 0, 0])) then
      status = allocate_runtime_fields(output, 17_int32, 137_int32, 97055_int32, [9_int32, 3_int32, 0_int32, 0_int32], constituents)
    else
      status = allocate_runtime_fields(output, pitch, levels, blocks, field_counts, constituents)
    end if
  end function

  integer(int32) function allocate_runtime_fields(output, pitch, levels, blocks, field_counts, constituents) result(status)
    !! Preserve the fixed operational partition dispatch and general source
    !! allocation order through one native owner calculation.
    type(gridpoint_field_state), intent(inout) :: output
    integer(int32), intent(in) :: pitch, levels, blocks, field_counts(4)
    type(thermal_constituent), target, intent(in) :: constituents(:)
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer(int32) :: ignored
    integer :: allocation_status
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    status = 1_int32
    allocate (output%gfl(pitch, levels, field_counts(1), blocks), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    allocate (output%gflslp(pitch, levels, field_counts(2), blocks), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    allocate (output%gflpt(pitch, levels, field_counts(3), blocks), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    allocate (output%gflpc(pitch, levels, field_counts(4), blocks), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    output%pitch = pitch; output%levels = levels; output%blocks = blocks
    output%constituents => constituents
    output%ready = .true.
    status = 0_int32
    goto 900
800 ignored = release_gridpoint_field(output)
900 error_number = saved_errno
    call ieee_set_status(saved)
  end function
end module runtime_gridpoint_field_storage_port
