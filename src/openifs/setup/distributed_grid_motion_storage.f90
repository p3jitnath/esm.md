!> Allocate source-owned live distributed wind and temperature storage.
!! This is the runtime-dimension branch of distributed_grid_motion_field_allocation.S.
!! The caller supplies the live Geometry counts and preserves the canonical GMV owner.
module forecast_distributed_grid_motion_storage
  use iso_fortran_env, only: int32, int64
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use forecast_grid_motion_types, only: native_grid_motion_state
  use forecast_grid_motion_setup, only: native_grid_motion_controls, initialize_grid_motion_index_maps
  use yomdimf, only: tdimf
  use yomdyna, only: tdyna
  implicit none
  private
  public :: allocate_distributed_grid_motion_fields
  interface
    function errno_address() bind(C, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Allocate GMV(P,137,F,B), then GMVS(P,S,B), preserving source order.
  !! P, B and LOCAL_POINTS are live dimensionless counts from the same Geometry.
  !! OUTPUT owns the two payloads; every other array owner must be absent.
  !! The already-produced map counts are checked before any mutation.
  !! New FP64 payloads remain source-uninitialized. Status is 0, 1 or 2.
  integer(int32) function allocate_distributed_grid_motion_fields(output, points, levels, blocks, &
                                                                  local_points, dimensions, dynamics, controls) result(status)
    type(native_grid_motion_state), intent(inout) :: output
    integer(int32), intent(in) :: points, levels, blocks, local_points
    type(tdimf), intent(in) :: dimensions
    type(tdyna), intent(in) :: dynamics
    type(native_grid_motion_controls), intent(in) :: controls
    integer(c_int), pointer, volatile :: error
    integer(c_int) :: saved_error
    integer :: allocation_status
    integer(int64) :: expected_blocks
    status = 2
    if (points < 1 .or. points > 1024 .or. levels /= 137 .or. blocks < 1 .or. blocks > 388217) return
    if (local_points < 1) return
    expected_blocks = (int(local_points, int64) + points - 1_int64)/points
    if (expected_blocks /= blocks) return
    if (controls%nconf /= 1 .or. controls%lecmwf /= 1 .or. controls%lrshw /= 0) return
    if (controls%nundefld >= 0 .or. controls%ldtenc /= 0 .or. controls%nprintlev /= 0) return
    if (dimensions%nfther /= 1) return
    if (.not. dynamics%ltwotl) return
    if (dynamics%lnhee .or. dynamics%lnhqe .or. dynamics%lnhdyn .or. dynamics%lnhx .or. &
        dynamics%lnhxder .or. dynamics%lgwadv .or. dynamics%lrdbbc .or. dynamics%lnhqe_sihyd .or. &
        dynamics%lnesc .or. dynamics%lslinlc2 .or. dynamics%lslinl .or. dynamics%lrubc .or. dynamics%lpc_full) return
    if (allocated(output%gmv) .or. allocated(output%gmvs) .or. allocated(output%gmvt1) .or. &
        allocated(output%gmvt1s) .or. allocated(output%gmv5) .or. allocated(output%gmv5s) .or. &
        allocated(output%gmv_depart) .or. allocated(output%gmvs_depart)) return
    if (output%ndimgmv /= 14 .or. output%ndimgmvs /= 3) return
    if (output%yt1%ndim /= 3 .or. output%yt1%ndims /= 1) return
    call c_f_pointer(errno_address(), error)
    saved_error = error
    status = initialize_grid_motion_index_maps(output, dimensions, dynamics, controls%nundefld)
    allocate (output%gmv(points, levels, output%ndimgmv, blocks), stat=allocation_status)
    if (allocation_status /= 0) then
      error = saved_error
      status = 1
      return
    end if
    allocate (output%gmvs(points, output%ndimgmvs, blocks), stat=allocation_status)
    if (allocation_status /= 0) then
      deallocate (output%gmv)
      error = saved_error
      status = 1
      return
    end if
    error = saved_error
    status = 0
  end function
end module forecast_distributed_grid_motion_storage
