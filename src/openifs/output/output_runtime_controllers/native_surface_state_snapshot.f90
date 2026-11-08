!> Write a versioned native snapshot of the complete live surface ownership graph.
!! This diagnostic format records compiler-owned outer representations and full payloads.
!! It is separate from canonical forecast GRIB and from the historical private Arm image.
module forecast_native_surface_snapshot
  use iso_fortran_env, only: int32, int64
  use iso_c_binding, only: c_ptr, c_loc, c_null_ptr, c_size_t, c_char
  use surface_field_storage_port, only: surface_field_state
  use surface_field_configuration_port, only: surface_field_registry, surface_physics_descriptions
  use surface_field_registration_port, only: surface_trajectory_metadata
  use forecast_output_stream_services, only: write_output_bytes
  implicit none
  private
  public :: write_native_surface_state
contains
  !> Emit SS104NW2, eight int64 header words, four outer records and104 owners.
  !! Header words are version2, endian marker0102030405060708, outer count4,
  !! owner count104, then the compiler-derived registry/state/trajectory/description bytes.
  !! Each owner has its actual native address and logical byte extent, then its full bytes.
  !! Metadata follows source group order, each layered field followed by its four owners.
  !! Numerical owners follow source allocation order. All inputs and errno remain unchanged.
  !! Return0 on success,1 on write failure or2 before output for an unsupported live graph.
  integer(int32) function write_native_surface_state(fd, registry, state, trajectory, descriptions) result(status)
    integer(int32), intent(in) :: fd
    type(surface_field_registry), target, intent(in) :: registry
    type(surface_field_state), target, intent(in) :: state
    type(surface_trajectory_metadata), target, intent(in) :: trajectory
    type(surface_physics_descriptions), target, intent(in) :: descriptions
    character(kind=c_char, len=8), target :: magic
    integer(int64), target :: header(8)
    integer :: group, field, count
    integer(c_size_t) :: bytes
    type(c_ptr) :: address
    status = 2
    if (fd < 0) return
    count = 68
    do group = 1, 34
      if (registry%groups(group)%metadata%registered_fields < 0) return
      if (registry%groups(group)%metadata%layered == 0) cycle
      if (registry%groups(group)%metadata%registered_fields > 0) then
        if (.not. allocated(registry%groups(group)%fields)) return
        if (size(registry%groups(group)%fields) < registry%groups(group)%metadata%registered_fields) return
      end if
      count = count + 4*registry%groups(group)%metadata%registered_fields
      do field = 1, registry%groups(group)%metadata%registered_fields
        if (.not. allocated(registry%groups(group)%fields(field)%layer_parameters)) return
        if (.not. allocated(registry%groups(group)%fields(field)%layer_names)) return
        if (.not. allocated(registry%groups(group)%fields(field)%layer_defaults)) return
        if (.not. allocated(registry%groups(group)%fields(field)%layer_source_flags)) return
      end do
    end do
    if (count /= 104) return
    if (.not. allocated(state%sp_sb)) return
    if (.not. allocated(state%sp_sg)) return
    if (.not. allocated(state%sp_sl)) return
    if (.not. allocated(state%sp_rr)) return
    if (.not. allocated(state%sp_cl)) return
    if (.not. allocated(state%sp_om)) return
    if (.not. allocated(state%sp_ep)) return
    if (.not. allocated(state%sp_x2)) return
    if (.not. allocated(state%sp_ci)) return
    if (.not. allocated(state%sd_vf)) return
    if (.not. allocated(state%sd_vp)) return
    if (.not. allocated(state%sd_vv)) return
    if (.not. allocated(state%sd_vn)) return
    if (.not. allocated(state%sd_vh)) return
    if (.not. allocated(state%sd_vk)) return
    if (.not. allocated(state%sd_va)) return
    if (.not. allocated(state%sd_vc)) return
    if (.not. allocated(state%sd_v2)) return
    if (.not. allocated(state%sd_v3)) return
    if (.not. allocated(state%sd_vd)) return
    if (.not. allocated(state%sd_sm)) return
    if (.not. allocated(state%sd_ws)) return
    if (.not. allocated(state%sd_ww)) return
    if (.not. allocated(state%sd_vx)) return
    if (.not. allocated(state%sd_xa)) return
    if (.not. allocated(state%sd_xr)) return
    if (.not. allocated(state%sd_x2)) return
    if (.not. allocated(state%sd_sfl)) return
    if (.not. allocated(state%sd_sfo)) return
    if (.not. allocated(state%sd_pf)) return
    if (.not. allocated(state%sd_di)) return
    if (.not. allocated(state%sd_oc)) return
    if (.not. allocated(state%sd_xp)) return
    if (.not. allocated(state%sd_xp2)) return
    magic = 'SS104NW2'
    header = [2_int64, int(z'0102030405060708', int64), 4_int64, 104_int64, &
              int(storage_size(registry), int64)/8, int(storage_size(state), int64)/8, &
              int(storage_size(trajectory), int64)/8, int(storage_size(descriptions), int64)/8]
    status = write_output_bytes(fd, c_loc(magic), 8_c_size_t, .false.)
    if (status /= 0) return
    status = write_output_bytes(fd, c_loc(header), 64_c_size_t, .false.)
    if (status /= 0) return
    status = write_output_bytes(fd, c_loc(registry), int(header(5), c_size_t), .false.)
    if (status /= 0) return
    status = write_output_bytes(fd, c_loc(state), int(header(6), c_size_t), .false.)
    if (status /= 0) return
    status = write_output_bytes(fd, c_loc(trajectory), int(header(7), c_size_t), .false.)
    if (status /= 0) return
    status = write_output_bytes(fd, c_loc(descriptions), int(header(8), c_size_t), .false.)
    if (status /= 0) return
    do group = 1, 34
      address = c_null_ptr
      bytes = 0
      if (allocated(registry%groups(group)%fields)) then
        address = c_loc(registry%groups(group)%fields)
        bytes = int(storage_size(registry%groups(group)%fields), c_size_t)/8_c_size_t
        bytes = bytes*size(registry%groups(group)%fields, kind=c_size_t)
      end if
      status = write_owner(fd, address, bytes)
      if (status /= 0) return
      if (registry%groups(group)%metadata%layered == 0) cycle
      do field = 1, registry%groups(group)%metadata%registered_fields
        bytes = int(storage_size(registry%groups(group)%fields(field)%layer_parameters), c_size_t)/8_c_size_t
        bytes = bytes*size(registry%groups(group)%fields(field)%layer_parameters, kind=c_size_t)
        status = write_owner(fd, c_loc(registry%groups(group)%fields(field)%layer_parameters), bytes)
        if (status /= 0) return
        bytes = int(storage_size(registry%groups(group)%fields(field)%layer_names), c_size_t)/8_c_size_t
        bytes = bytes*size(registry%groups(group)%fields(field)%layer_names, kind=c_size_t)
        status = write_owner(fd, c_loc(registry%groups(group)%fields(field)%layer_names), bytes)
        if (status /= 0) return
        bytes = int(storage_size(registry%groups(group)%fields(field)%layer_defaults), c_size_t)/8_c_size_t
        bytes = bytes*size(registry%groups(group)%fields(field)%layer_defaults, kind=c_size_t)
        status = write_owner(fd, c_loc(registry%groups(group)%fields(field)%layer_defaults), bytes)
        if (status /= 0) return
        bytes = int(storage_size(registry%groups(group)%fields(field)%layer_source_flags), c_size_t)/8_c_size_t
        bytes = bytes*size(registry%groups(group)%fields(field)%layer_source_flags, kind=c_size_t)
        status = write_owner(fd, c_loc(registry%groups(group)%fields(field)%layer_source_flags), bytes)
        if (status /= 0) return
      end do
    end do
    bytes = int(storage_size(state%sp_sb), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sp_sb, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sp_sb), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sp_sg), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sp_sg, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sp_sg), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sp_sl), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sp_sl, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sp_sl), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sp_rr), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sp_rr, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sp_rr), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sp_cl), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sp_cl, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sp_cl), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sp_om), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sp_om, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sp_om), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sp_ep), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sp_ep, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sp_ep), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sp_x2), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sp_x2, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sp_x2), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sp_ci), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sp_ci, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sp_ci), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sd_vf), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sd_vf, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sd_vf), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sd_vp), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sd_vp, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sd_vp), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sd_vv), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sd_vv, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sd_vv), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sd_vn), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sd_vn, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sd_vn), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sd_vh), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sd_vh, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sd_vh), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sd_vk), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sd_vk, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sd_vk), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sd_va), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sd_va, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sd_va), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sd_vc), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sd_vc, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sd_vc), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sd_v2), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sd_v2, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sd_v2), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sd_v3), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sd_v3, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sd_v3), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sd_vd), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sd_vd, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sd_vd), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sd_sm), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sd_sm, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sd_sm), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sd_ws), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sd_ws, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sd_ws), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sd_ww), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sd_ww, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sd_ww), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sd_vx), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sd_vx, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sd_vx), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sd_xa), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sd_xa, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sd_xa), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sd_xr), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sd_xr, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sd_xr), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sd_x2), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sd_x2, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sd_x2), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sd_sfl), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sd_sfl, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sd_sfl), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sd_sfo), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sd_sfo, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sd_sfo), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sd_pf), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sd_pf, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sd_pf), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sd_di), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sd_di, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sd_di), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sd_oc), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sd_oc, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sd_oc), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sd_xp), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sd_xp, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sd_xp), bytes)
    if (status /= 0) return
    bytes = int(storage_size(state%sd_xp2), c_size_t)/8_c_size_t
    bytes = bytes*size(state%sd_xp2, kind=c_size_t)
    status = write_owner(fd, c_loc(state%sd_xp2), bytes)
    if (status /= 0) return
    status = 0
  end function
  !> Write one source-ordered owner identity and payload without copying the payload.
  integer(int32) function write_owner(fd, address, bytes) result(status)
    integer(int32), intent(in) :: fd
    type(c_ptr), intent(in) :: address
    integer(c_size_t), intent(in) :: bytes
    integer(int64), target :: identity(2)
    identity(1) = transfer(address, identity(1))
    identity(2) = bytes
    status = write_output_bytes(fd, c_loc(identity), 16_c_size_t, .false.)
    if (status /= 0) return
    status = write_output_bytes(fd, address, bytes, .false.)
  end function
end module forecast_native_surface_snapshot
