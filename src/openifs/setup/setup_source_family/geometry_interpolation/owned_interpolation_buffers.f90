!> Bind complete SL,RI,RO map setup to actual native geometry and row owners.
module forecast_owned_interpolation_buffers
  use iso_fortran_env, only: int32, int64
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_native_radiation_grid, only: native_radiation_grid
  use forecast_native_radiation_transform_storage, only: native_radiation_transform_storage
  use forecast_radiation_interpolation_context, only: native_radiation_main_grid_view
  use forecast_interpolation_state_types, only: native_interpolation_state
  use forecast_interpolation_buffer_setup, only: create_buffer => initialize_distributed_interpolation_buffer, &
                                      release_buffer => release_distributed_interpolation_buffer, interpolation_global_halo_capacity
  use forecast_live_interpolation_communication, only: initialize_live_distributed_interpolation_communication
  use forecast_public_transform, only: native_transform_control
  use forecast_distributed_partition_types, only: native_distributed_partition
  use forecast_distributed_partition_collectives, only: agree_distributed_partition_status
  implicit none
  interface
    function errno_address() bind(c, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
  private
  public :: bind_owned_geometry_interpolation_view
  public :: initialize_runtime_main_distributed_interpolation_buffer, release_runtime_main_distributed_interpolation_buffer
  public :: initialize_runtime_radiation_interpolation_buffer, release_runtime_radiation_interpolation_buffer
  public :: initialize_runtime_radiation_output_interpolation_buffer, release_runtime_radiation_output_interpolation_buffer
  public :: initialize_owned_runtime_radiation_interpolation_buffer, initialize_owned_radiation_output_interpolation_buffer
  public :: initialize_radiation_output_interpolation_communication
contains
  !> Preserve natural status around added integer admission agreement only.
  integer(int32) function agree_control(control, local) result(status)
    type(native_transform_control), intent(in) :: control
    integer(int32), intent(in) :: local
    type(ieee_status_type) :: floating
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number; call ieee_get_status(floating)
    status = agree_distributed_partition_status(control, local)
    call ieee_set_status(floating); error_number = saved_errno
  end function
  !> Borrow the actual eight integer map owners and project their named counts.
 !! GEOMETRY is a stable TARGET; VIEW owns no payload. Both stay live until
 !! setup returns. Source dimensions and selectors are taken from the actual
 !! final-address geometry, never from a copied private Geometry byte image.
  integer(int32) function bind_owned_geometry_interpolation_view(geometry, budget, view) result(status)
    type(native_geometry_state), target, intent(in) :: geometry
    integer(int64), intent(in) :: budget
    type(native_radiation_main_grid_view), intent(out) :: view
    status = 2
    if (.not. geometry%initialized .or. geometry%partition%phase /= 7 .or. budget < 1) return
    if (.not. allocated(geometry%configuration%nloeng)) return
    if (.not. allocated(geometry%partition%nsta) .or. .not. allocated(geometry%partition%nonl)) return
    if (.not. allocated(geometry%partition%nptrfrstlat)) return
    if (.not. allocated(geometry%partition%nfrstlat) .or. .not. allocated(geometry%partition%nlstlat)) return
    if (.not. allocated(geometry%partition%nprocm)) return
    view%row_lengths => geometry%configuration%nloeng
    view%starts => geometry%partition%nsta; view%counts => geometry%partition%nonl
    view%first_point => geometry%partition%nptrfrstlat
    view%first_latitude => geometry%partition%nfrstlat; view%last_latitude => geometry%partition%nlstlat
    view%process_ids => geometry%partition%nprocm
    view%grid%ndglg = geometry%dimensions%ndglg; view%grid%ndlon = geometry%dimensions%ndlon
    view%grid%ndgsag = geometry%dimensions%ndgsag; view%grid%ndgeng = geometry%dimensions%ndgeng
    view%grid%ndgsal = geometry%partition%ndgsal; view%grid%ndgenl = geometry%partition%ndgenl
    view%grid%ngptot = geometry%partition%ngptot; view%grid%ndguxl = geometry%partition%ndguxl
    view%grid%ndlung = geometry%dimensions%ndlung; view%grid%ndluxg = geometry%dimensions%ndluxg
    view%grid%ndgung = geometry%dimensions%ndgung; view%grid%ndguxg = geometry%dimensions%ndguxg
    view%grid%ndsur1 = geometry%dimensions%ndsur1; view%grid%ndlsur = geometry%dimensions%ndlsur
    view%grid%nptrfloff = geometry%partition%nptrfloff; view%grid%nfrstloff = geometry%partition%nfrstloff
    view%grid%myfrstactlat = geometry%partition%myfrstactlat; view%grid%mylstactlat = geometry%partition%mylstactlat
    view%grid%nstencilwide = geometry%dimensions%nstencilwide; view%grid%ndgsur = geometry%dimensions%ndgsur
    view%communication_budget = budget; view%report_unit = 6
    status = 0
  end function
  !> Complete main SL local maps, reporting and actual public communication.
  integer(int32)function initialize_runtime_main_distributed_interpolation_buffer(state,main,control,partition,child)result(status)
  type(native_interpolation_state), target, intent(inout) :: state
  type(native_radiation_main_grid_view), intent(in) :: main
  type(native_transform_control), intent(in) :: control
  type(native_distributed_partition), intent(in) :: partition
  integer(int32), intent(out) :: child
  status = run_buffer(state, main, control, partition, 'SL', child)
  end function
  !> Complete RI from its genuine main-grid maps, preserving foreign NSLMAP.
  integer(int32) function initialize_runtime_radiation_interpolation_buffer(state, main, control, partition, child) result(status)
    type(native_interpolation_state), target, intent(inout) :: state
    type(native_radiation_main_grid_view), intent(in) :: main
    type(native_transform_control), intent(in) :: control
    type(native_distributed_partition), intent(in) :: partition
    integer(int32), intent(out) :: child
    status = run_buffer(state, main, control, partition, 'RI', child)
  end function
  !> Project actual RADGRID/storage into readonly typed views, then complete RO.
 !! Source lower bounds and leading dimensions are retained. No numerical
 !! owner is copied; MAIN contributes only actual process IDs and I/O/budget.
 integer(int32)function initialize_runtime_radiation_output_interpolation_buffer(state,g,storage,main,control,partition,child)result(status)
  type(native_interpolation_state), target, intent(inout) :: state
  type(native_radiation_grid), target, intent(in) :: g
  type(native_radiation_transform_storage), target, intent(in) :: storage
  type(native_radiation_main_grid_view), intent(in) :: main
  type(native_transform_control), intent(in) :: control
  type(native_distributed_partition), intent(in) :: partition
  integer(int32), intent(out) :: child
  type(native_radiation_main_grid_view) :: rad
  integer(int32) :: local
  child = 2; status = 2
  if (.not. control%message_ready) return
  local = bind_radiation_view(g, storage, main, rad)
  child = agree_control(control, local)
  if (child /= 0) then
    status = child; return
  end if
  status = run_buffer(state, rad, control, partition, 'RO', child)
end function
!> Bind the canonical completed main partition before the complete RI child.
integer(int32) function initialize_owned_runtime_radiation_interpolation_buffer(state, geometry, budget, child) result(status)
  type(native_interpolation_state), target, intent(inout) :: state
  type(native_geometry_state), target, intent(in) :: geometry
  integer(int64), intent(in) :: budget
  integer(int32), intent(out) :: child
  type(native_radiation_main_grid_view) :: main
  integer(int32) :: local
  status = 2; child = 2
  if (.not. geometry%transform_control%message_ready) return
  local = bind_owned_geometry_interpolation_view(geometry, budget, main)
  child = agree_control(geometry%transform_control, local)
  if (child /= 0) then
    status = child; return
  end if
  status = initialize_runtime_radiation_interpolation_buffer(state, main, geometry%transform_control, geometry%partition, child)
end function
!> Bind the same final-address main partition and actual radiation owners to RO.
integer(int32)function initialize_owned_radiation_output_interpolation_buffer(state,geometry,g,storage,budget,child)result(status)
type(native_interpolation_state), target, intent(inout) :: state
type(native_geometry_state), target, intent(in) :: geometry
type(native_radiation_grid), target, intent(in) :: g
type(native_radiation_transform_storage), target, intent(in) :: storage
integer(int64), intent(in) :: budget
integer(int32), intent(out) :: child
type(native_radiation_main_grid_view) :: main
integer(int32) :: local
status = 2; child = 2
if (.not. geometry%transform_control%message_ready) return
local = bind_owned_geometry_interpolation_view(geometry, budget, main)
child = agree_control(geometry%transform_control, local)
if (child /= 0) then
  status = child; return
end if
status = initialize_runtime_radiation_output_interpolation_buffer(state, g, storage, main, &
                                                                  geometry%transform_control, geometry%partition, child)
end function
!> Complete the RO-expanded communication body through unchanged live SLRSET.
 !! Public messages, counts and maps are actual native producer outputs.
integer(int32) function initialize_radiation_output_interpolation_communication(state, rad, control) result(status)
  type(native_interpolation_state), intent(inout) :: state
  type(native_radiation_main_grid_view), intent(in) :: rad
  type(native_transform_control), intent(in) :: control
  integer(int32) :: local
  integer(int64) :: capacity
  status = 2
  if (.not. control%message_ready) return
  local = valid_view(rad, control)
  if (state%cver /= 'RO') local = 2
  status = agree_control(control, local); if (status /= 0) return
  capacity = interpolation_global_halo_capacity(rad%row_lengths, rad%grid%ndglg)
  status = initialize_live_distributed_interpolation_communication(state, rad%starts, rad%counts, &
               rad%first_point, rad%first_latitude, rad%last_latitude, rad%process_ids, control, capacity, rad%communication_budget)
end function
integer(int32) function release_runtime_main_distributed_interpolation_buffer(state) result(status)
  type(native_interpolation_state), intent(inout) :: state
  status = release_buffer(state)
end function
integer(int32) function release_runtime_radiation_interpolation_buffer(state) result(status)
  type(native_interpolation_state), intent(inout) :: state
  status = release_buffer(state)
end function
integer(int32) function release_runtime_radiation_output_interpolation_buffer(state) result(status)
  type(native_interpolation_state), intent(inout) :: state
  status = release_buffer(state)
end function
integer(int32) function run_buffer(state, view, control, partition, version, child) result(status)
  type(native_interpolation_state), target, intent(inout) :: state
  type(native_radiation_main_grid_view), intent(in) :: view
  type(native_transform_control), intent(in) :: control
  type(native_distributed_partition), intent(in) :: partition
  character(len=2), intent(in) :: version
  integer(int32), intent(out) :: child
  integer(int32) :: local
  integer(int64) :: capacity
  status = 2; child = 2
  if (.not. control%message_ready) return
  local = valid_view(view, control)
  if (state%cver /= version .or. partition%phase /= 7) local = 2
  if (partition%my_region_ns < 1 .or. partition%my_region_ns > control%regions_ns) local = 2
  if (partition%my_region_ew < 1 .or. partition%my_region_ew > control%regions_ew) local = 2
  child = agree_control(control, local)
  if (child /= 0) then
    status = child; return
  end if
  capacity = interpolation_global_halo_capacity(view%row_lengths, view%grid%ndglg)
  status = create_buffer(state, view%grid, view%starts, view%counts, view%row_lengths, &
                        view%first_point, view%first_latitude, view%last_latitude, partition%my_region_ns, partition%my_region_ew, &
                         view%process_ids, control, capacity, view%communication_budget, view%report_unit, child)
end function
integer(int32) function valid_view(v, c) result(status)
  type(native_radiation_main_grid_view), intent(in) :: v
  type(native_transform_control), intent(in) :: c
  status = 2
  if (.not. associated(v%row_lengths) .or. .not. associated(v%starts) .or. .not. associated(v%counts)) return
  if (.not. associated(v%first_point) .or. .not. associated(v%first_latitude) .or. .not. associated(v%last_latitude)) return
  if (.not. associated(v%process_ids) .or. v%communication_budget < 1 .or. v%report_unit /= 6) return
  if (.not. is_contiguous(v%row_lengths) .or. .not. is_contiguous(v%starts) .or. .not. is_contiguous(v%counts)) return
 if (.not. is_contiguous(v%first_point) .or. .not. is_contiguous(v%first_latitude) .or. .not. is_contiguous(v%last_latitude)) return
  if (.not. is_contiguous(v%process_ids)) return
  if (size(v%process_ids) /= c%nproc) return
  if (lbound(v%row_lengths, 1) /= -1 .or. lbound(v%starts, 1) /= -1 .or. lbound(v%counts, 1) /= -1) return
  status = 0
end function
integer(int32) function bind_radiation_view(g, o, main, rad) result(status)
  type(native_radiation_grid), target, intent(in) :: g
  type(native_radiation_transform_storage), target, intent(in) :: o
  type(native_radiation_main_grid_view), intent(in) :: main
  type(native_radiation_main_grid_view), intent(out) :: rad
  status = 2
  if (o%state < 3 .or. o%state > 5 .or. .not. associated(o%grid) .or. .not. associated(o%row_lengths)) return
  if (.not. associated(o%grid, g)) return
  if (.not. allocated(o%nsta) .or. .not. allocated(o%nonl) .or. .not. allocated(o%nptrfrstlat)) return
  if (.not. allocated(o%nfrstlat) .or. .not. allocated(o%nlstlat)) return
  if (.not. associated(main%process_ids)) return
  rad%row_lengths => o%row_lengths; rad%starts => o%nsta; rad%counts => o%nonl
  rad%first_point => o%nptrfrstlat; rad%first_latitude => o%nfrstlat; rad%last_latitude => o%nlstlat
  rad%process_ids => main%process_ids
  rad%grid%ndglg = g%ndglg; rad%grid%ndlon = g%ndlon
  rad%grid%ndgsag = -1; rad%grid%ndgeng = g%ndglg + 2; rad%grid%ndgsal = g%ndgsal; rad%grid%ndgenl = g%ndgenl
  rad%grid%ngptot = g%ngptot; rad%grid%ndguxl = 0; rad%grid%ndlung = 1
  rad%grid%ndluxg = 0; rad%grid%ndgung = 0; rad%grid%ndguxg = 0
  rad%grid%ndsur1 = 3; rad%grid%ndlsur = g%ndlon + 3
  rad%grid%nptrfloff = g%ndgsl; rad%grid%nfrstloff = g%nfrstloff
  rad%grid%myfrstactlat = g%myfrstlat; rad%grid%mylstactlat = g%mylstlat
  rad%grid%nstencilwide = main%grid%nstencilwide; rad%grid%ndgsur = main%grid%ndgsur
  rad%communication_budget = main%communication_budget; rad%report_unit = main%report_unit
  status = 0
end function
end module forecast_owned_interpolation_buffers
