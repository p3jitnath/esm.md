!> Stage all seventeen native surface block views before publishing their metadata.
module forecast_physics_surface_block_views
  use iso_fortran_env, only: int32, int64
  use iso_c_binding, only: c_int, c_ptr, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_native_field_variable_types, only: native_surface_variables
  use forecast_physics_work_types, only: surf_and_more_type
  use forecast_physics_field_views, only: physics_field_view_3d, physics_field_view_4d
  use surface_field_configuration_port, only: surface_field_registry
  use physics_grid_dimension_helpers_mod, only: surface_group_index
  implicit none
  private
  public :: prepare_physics_surface_block_views, release_physics_surface_block_views
  interface
    function errno_address() bind(C, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Borrow each populated source block or acquire an undefined fallback array.
 !! SURF owns only fallbacks identified by its same canonical OWNED mask.
 !! VARIABLES and METADATA borrow the live surface owners. GEOMETRY supplies
 !! P columns, N local points and B=ceil(N/P); BLOCK0 is a zero-based block.
 !! Native inputs are distinct, stable TARGET records and dense source groups.
 !! Empty source groups are not read. Payload units remain source field units.
 !! BYTE_BUDGET bounds fallback allocations in bytes. Status0 commits only the
 !! seventeen pointer components,1 rolls back a failed allocation prefix,
 !! and2 refuses before allocation or public mutation. IEEE is preserved;
 !! successful/refused calls preserve errno, failed allocation retains its errno.
 integer(int32)function prepare_physics_surface_block_views(surf,variables,metadata,geometry,block0,byte_budget,owned)result(status)
  type(surf_and_more_type), intent(inout) :: surf
  type(native_surface_variables), intent(in) :: variables
  type(surface_field_registry), intent(in) :: metadata
  type(native_geometry_state), intent(in) :: geometry
  integer(int32), intent(in) :: block0
  integer(int64), intent(in) :: byte_budget
  logical, intent(inout) :: owned(17)
  type(surf_and_more_type) :: pending
  type(ieee_status_type) :: incoming, reached
  integer(c_int), pointer, volatile :: error_number
  integer(c_int) :: incoming_errno, failed_errno
  integer(int32) :: groups(17), counts(17), layers(17), p, n, b, block
  integer(int64) :: total, requested
  integer :: j, allocation_status
  logical :: acquired(17)
  status = 2
  p = geometry%dimensions%nproma; n = geometry%partition%ngptot; b = geometry%partition%ngpblks
  if (p < 1 .or. p > 1024 .or. n < 1 .or. b /= (int(n, int64) - 1_int64)/p + 1_int64) return
  if (block0 < 0 .or. int(block0, int64) >= int(b, int64) .or. byte_budget < 0_int64) return
  if (any(owned)) return
  block = block0 + 1
  pending = surf; acquired = .false.; total = 0_int64
  groups(1) = surface_group_index(metadata, 'YSP_SBD')
  if (groups(1) == 0) return
  counts(1) = metadata%groups(groups(1))%metadata%registered_fields
  layers(1) = metadata%groups(groups(1))%metadata%layers
  if (counts(1) > 0) then
    status = physics_field_view_4d(pending%psp_sb, variables%gsp_sb%f_group, block)
    if (status /= 0) return
    status = 2
    if (size(pending%psp_sb, 1) /= p) return
    if (size(pending%psp_sb, 3) /= counts(1)) return
    if (size(pending%psp_sb, 2) /= layers(1)) return
  else
    if (associated(surf%psp_sb)) return
    requested = 8_int64*p*max(1_int64, int(layers(1), int64))
    if (total > byte_budget - requested) return
    total = total + requested
  end if
  groups(2) = surface_group_index(metadata, 'YSP_SGD')
  if (groups(2) == 0) return
  counts(2) = metadata%groups(groups(2))%metadata%registered_fields
  layers(2) = metadata%groups(groups(2))%metadata%layers
  if (counts(2) > 0) then
    status = physics_field_view_4d(pending%psp_sg, variables%gsp_sg%f_group, block)
    if (status /= 0) return
    status = 2
    if (size(pending%psp_sg, 1) /= p) return
    if (size(pending%psp_sg, 3) /= counts(2)) return
    if (size(pending%psp_sg, 2) /= layers(2)) return
  else
    if (associated(surf%psp_sg)) return
    requested = 8_int64*p*max(1_int64, int(layers(2), int64))
    if (total > byte_budget - requested) return
    total = total + requested
  end if
  groups(3) = surface_group_index(metadata, 'YSP_SLD')
  if (groups(3) == 0) return
  counts(3) = metadata%groups(groups(3))%metadata%registered_fields
  layers(3) = metadata%groups(groups(3))%metadata%layers
  if (counts(3) > 0) then
    status = physics_field_view_3d(pending%psp_sl, variables%gsp_sl%f_group, block)
    if (status /= 0) return
    status = 2
    if (size(pending%psp_sl, 1) /= p) return
    if (size(pending%psp_sl, 2) /= counts(3)) return
  else
    if (associated(surf%psp_sl)) return
    requested = 8_int64*p
    if (total > byte_budget - requested) return
    total = total + requested
  end if
  groups(4) = surface_group_index(metadata, 'YSP_RRD')
  if (groups(4) == 0) return
  counts(4) = metadata%groups(groups(4))%metadata%registered_fields
  layers(4) = metadata%groups(groups(4))%metadata%layers
  if (counts(4) > 0) then
    status = physics_field_view_3d(pending%psp_rr, variables%gsp_rr%f_group, block)
    if (status /= 0) return
    status = 2
    if (size(pending%psp_rr, 1) /= p) return
    if (size(pending%psp_rr, 2) /= counts(4)) return
  else
    if (associated(surf%psp_rr)) return
    requested = 8_int64*p
    if (total > byte_budget - requested) return
    total = total + requested
  end if
  groups(5) = surface_group_index(metadata, 'YSP_EPD')
  if (groups(5) == 0) return
  counts(5) = metadata%groups(groups(5))%metadata%registered_fields
  layers(5) = metadata%groups(groups(5))%metadata%layers
  if (counts(5) > 0) then
    status = physics_field_view_4d(pending%psp_ep, variables%gsp_ep%f_group, block)
    if (status /= 0) return
    status = 2
    if (size(pending%psp_ep, 1) /= p) return
    if (size(pending%psp_ep, 3) /= counts(5)) return
    if (size(pending%psp_ep, 2) /= layers(5)) return
  else
    if (associated(surf%psp_ep)) return
    requested = 8_int64*p*max(1_int64, int(layers(5), int64))
    if (total > byte_budget - requested) return
    total = total + requested
  end if
  groups(6) = surface_group_index(metadata, 'YSP_X2D')
  if (groups(6) == 0) return
  counts(6) = metadata%groups(groups(6))%metadata%registered_fields
  layers(6) = metadata%groups(groups(6))%metadata%layers
  if (counts(6) > 0) then
    status = physics_field_view_3d(pending%psp_x2, variables%gsp_x2%f_group, block)
    if (status /= 0) return
    status = 2
    if (size(pending%psp_x2, 1) /= p) return
    if (size(pending%psp_x2, 2) /= counts(6)) return
  else
    if (associated(surf%psp_x2)) return
    requested = 8_int64*p
    if (total > byte_budget - requested) return
    total = total + requested
  end if
  groups(7) = surface_group_index(metadata, 'YSP_OMD')
  if (groups(7) == 0) return
  counts(7) = metadata%groups(groups(7))%metadata%registered_fields
  layers(7) = metadata%groups(groups(7))%metadata%layers
  if (counts(7) > 0) then
    status = physics_field_view_4d(pending%psp_om, variables%gsp_om%f_group, block)
    if (status /= 0) return
    status = 2
    if (size(pending%psp_om, 1) /= p) return
    if (size(pending%psp_om, 3) /= counts(7)) return
    if (size(pending%psp_om, 2) /= layers(7)) return
  else
    if (associated(surf%psp_om)) return
    requested = 8_int64*p*max(1_int64, int(layers(7), int64))
    if (total > byte_budget - requested) return
    total = total + requested
  end if
  groups(8) = surface_group_index(metadata, 'YSD_VFD')
  if (groups(8) == 0) return
  counts(8) = metadata%groups(groups(8))%metadata%registered_fields
  layers(8) = metadata%groups(groups(8))%metadata%layers
  if (counts(8) > 0) then
    status = physics_field_view_3d(pending%psd_vf, variables%gsd_vf%f_group, block)
    if (status /= 0) return
    status = 2
    if (size(pending%psd_vf, 1) /= p) return
    if (size(pending%psd_vf, 2) /= counts(8)) return
  else
    if (associated(surf%psd_vf)) return
    requested = 8_int64*p
    if (total > byte_budget - requested) return
    total = total + requested
  end if
  groups(9) = surface_group_index(metadata, 'YSD_VND')
  if (groups(9) == 0) return
  counts(9) = metadata%groups(groups(9))%metadata%registered_fields
  layers(9) = metadata%groups(groups(9))%metadata%layers
  if (counts(9) > 0) then
    status = physics_field_view_3d(pending%psd_vn, variables%gsd_vn%f_group, block)
    if (status /= 0) return
    status = 2
    if (size(pending%psd_vn, 1) /= p) return
    if (size(pending%psd_vn, 2) /= counts(9)) return
  else
    if (associated(surf%psd_vn)) return
    requested = 8_int64*p
    if (total > byte_budget - requested) return
    total = total + requested
  end if
  groups(10) = surface_group_index(metadata, 'YSD_VDD')
  if (groups(10) == 0) return
  counts(10) = metadata%groups(groups(10))%metadata%registered_fields
  layers(10) = metadata%groups(groups(10))%metadata%layers
  if (counts(10) > 0) then
    status = physics_field_view_3d(pending%psd_vd, variables%gsd_vd%f_group, block)
    if (status /= 0) return
    status = 2
    if (size(pending%psd_vd, 1) /= p) return
    if (size(pending%psd_vd, 2) /= counts(10)) return
  else
    if (associated(surf%psd_vd)) return
    requested = 8_int64*p
    if (total > byte_budget - requested) return
    total = total + requested
  end if
  groups(11) = surface_group_index(metadata, 'YSD_WSD')
  if (groups(11) == 0) return
  counts(11) = metadata%groups(groups(11))%metadata%registered_fields
  layers(11) = metadata%groups(groups(11))%metadata%layers
  if (counts(11) > 0) then
    status = physics_field_view_3d(pending%psd_ws, variables%gsd_ws%f_group, block)
    if (status /= 0) return
    status = 2
    if (size(pending%psd_ws, 1) /= p) return
    if (size(pending%psd_ws, 2) /= counts(11)) return
  else
    if (associated(surf%psd_ws)) return
    requested = 8_int64*p
    if (total > byte_budget - requested) return
    total = total + requested
  end if
  groups(12) = surface_group_index(metadata, 'YSD_WWD')
  if (groups(12) == 0) return
  counts(12) = metadata%groups(groups(12))%metadata%registered_fields
  layers(12) = metadata%groups(groups(12))%metadata%layers
  if (counts(12) > 0) then
    status = physics_field_view_3d(pending%psd_ww, variables%gsd_ww%f_group, block)
    if (status /= 0) return
    status = 2
    if (size(pending%psd_ww, 1) /= p) return
    if (size(pending%psd_ww, 2) /= counts(12)) return
  else
    if (associated(surf%psd_ww)) return
    requested = 8_int64*p
    if (total > byte_budget - requested) return
    total = total + requested
  end if
  groups(13) = surface_group_index(metadata, 'YSD_XAD')
  if (groups(13) == 0) return
  counts(13) = metadata%groups(groups(13))%metadata%registered_fields
  layers(13) = metadata%groups(groups(13))%metadata%layers
  if (counts(13) > 0) then
    status = physics_field_view_4d(pending%psd_xa, variables%gsd_xa%f_group, block)
    if (status /= 0) return
    status = 2
    if (size(pending%psd_xa, 1) /= p) return
    if (size(pending%psd_xa, 3) /= counts(13)) return
    if (size(pending%psd_xa, 2) /= layers(13)) return
  else
    if (associated(surf%psd_xa)) return
    requested = 8_int64*p*max(1_int64, int(layers(13), int64))
    if (total > byte_budget - requested) return
    total = total + requested
  end if
  groups(14) = surface_group_index(metadata, 'YSD_X2D')
  if (groups(14) == 0) return
  counts(14) = metadata%groups(groups(14))%metadata%registered_fields
  layers(14) = metadata%groups(groups(14))%metadata%layers
  if (counts(14) > 0) then
    status = physics_field_view_3d(pending%psd_x2, variables%gsd_x2%f_group, block)
    if (status /= 0) return
    status = 2
    if (size(pending%psd_x2, 1) /= p) return
    if (size(pending%psd_x2, 2) /= counts(14)) return
  else
    if (associated(surf%psd_x2)) return
    requested = 8_int64*p
    if (total > byte_budget - requested) return
    total = total + requested
  end if
  groups(15) = surface_group_index(metadata, 'YSD_SMD')
  if (groups(15) == 0) return
  counts(15) = metadata%groups(groups(15))%metadata%registered_fields
  layers(15) = metadata%groups(groups(15))%metadata%layers
  if (counts(15) > 0) then
    status = physics_field_view_4d(pending%psd_sm, variables%gsd_sm%f_group, block)
    if (status /= 0) return
    status = 2
    if (size(pending%psd_sm, 1) /= p) return
    if (size(pending%psd_sm, 3) /= counts(15)) return
    if (size(pending%psd_sm, 2) /= layers(15)) return
  else
    if (associated(surf%psd_sm)) return
    requested = 8_int64*p*max(1_int64, int(layers(15), int64))
    if (total > byte_budget - requested) return
    total = total + requested
  end if
  groups(16) = surface_group_index(metadata, 'YSD_V2D')
  if (groups(16) == 0) return
  counts(16) = metadata%groups(groups(16))%metadata%registered_fields
  layers(16) = metadata%groups(groups(16))%metadata%layers
  if (counts(16) > 0) then
    status = physics_field_view_3d(pending%psd_v2, variables%gsd_v2%f_group, block)
    if (status /= 0) return
    status = 2
    if (size(pending%psd_v2, 1) /= p) return
    if (size(pending%psd_v2, 2) /= counts(16)) return
  else
    if (associated(surf%psd_v2)) return
    requested = 8_int64*p
    if (total > byte_budget - requested) return
    total = total + requested
  end if
  groups(17) = surface_group_index(metadata, 'YSD_V3D')
  if (groups(17) == 0) return
  counts(17) = metadata%groups(groups(17))%metadata%registered_fields
  layers(17) = metadata%groups(groups(17))%metadata%layers
  if (counts(17) > 0) then
    status = physics_field_view_4d(pending%psd_v3, variables%gsd_v3%f_group, block)
    if (status /= 0) return
    status = 2
    if (size(pending%psd_v3, 1) /= p) return
    if (size(pending%psd_v3, 3) /= counts(17)) return
    if (size(pending%psd_v3, 2) /= layers(17)) return
  else
    if (associated(surf%psd_v3)) return
    requested = 8_int64*p*max(1_int64, int(layers(17), int64))
    if (total > byte_budget - requested) return
    total = total + requested
  end if
  call ieee_get_status(incoming)
  call c_f_pointer(errno_address(), error_number); incoming_errno = error_number
  status = 1
  if (counts(1) <= 0) then
    allocate (pending%psp_sb(p, max(1, layers(1)), 1), stat=allocation_status)
    if (allocation_status /= 0) goto800
    acquired(1) = .true.
  end if
  if (counts(2) <= 0) then
    allocate (pending%psp_sg(p, max(1, layers(2)), 1), stat=allocation_status)
    if (allocation_status /= 0) goto800
    acquired(2) = .true.
  end if
  if (counts(3) <= 0) then
    allocate (pending%psp_sl(p, 1), stat=allocation_status)
    if (allocation_status /= 0) goto800
    acquired(3) = .true.
  end if
  if (counts(4) <= 0) then
    allocate (pending%psp_rr(p, 1), stat=allocation_status)
    if (allocation_status /= 0) goto800
    acquired(4) = .true.
  end if
  if (counts(5) <= 0) then
    allocate (pending%psp_ep(p, max(1, layers(5)), 1), stat=allocation_status)
    if (allocation_status /= 0) goto800
    acquired(5) = .true.
  end if
  if (counts(6) <= 0) then
    allocate (pending%psp_x2(p, 1), stat=allocation_status)
    if (allocation_status /= 0) goto800
    acquired(6) = .true.
  end if
  if (counts(7) <= 0) then
    allocate (pending%psp_om(p, max(1, layers(7)), 1), stat=allocation_status)
    if (allocation_status /= 0) goto800
    acquired(7) = .true.
  end if
  if (counts(8) <= 0) then
    allocate (pending%psd_vf(p, 1), stat=allocation_status)
    if (allocation_status /= 0) goto800
    acquired(8) = .true.
  end if
  if (counts(9) <= 0) then
    allocate (pending%psd_vn(p, 1), stat=allocation_status)
    if (allocation_status /= 0) goto800
    acquired(9) = .true.
  end if
  if (counts(10) <= 0) then
    allocate (pending%psd_vd(p, 1), stat=allocation_status)
    if (allocation_status /= 0) goto800
    acquired(10) = .true.
  end if
  if (counts(11) <= 0) then
    allocate (pending%psd_ws(p, 1), stat=allocation_status)
    if (allocation_status /= 0) goto800
    acquired(11) = .true.
  end if
  if (counts(12) <= 0) then
    allocate (pending%psd_ww(p, 1), stat=allocation_status)
    if (allocation_status /= 0) goto800
    acquired(12) = .true.
  end if
  if (counts(13) <= 0) then
    allocate (pending%psd_xa(p, max(1, layers(13)), 1), stat=allocation_status)
    if (allocation_status /= 0) goto800
    acquired(13) = .true.
  end if
  if (counts(14) <= 0) then
    allocate (pending%psd_x2(p, 1), stat=allocation_status)
    if (allocation_status /= 0) goto800
    acquired(14) = .true.
  end if
  if (counts(15) <= 0) then
    allocate (pending%psd_sm(p, max(1, layers(15)), 1), stat=allocation_status)
    if (allocation_status /= 0) goto800
    acquired(15) = .true.
  end if
  if (counts(16) <= 0) then
    allocate (pending%psd_v2(p, 1), stat=allocation_status)
    if (allocation_status /= 0) goto800
    acquired(16) = .true.
  end if
  if (counts(17) <= 0) then
    allocate (pending%psd_v3(p, max(1, layers(17)), 1), stat=allocation_status)
    if (allocation_status /= 0) goto800
    acquired(17) = .true.
  end if
  surf%psp_sb => pending%psp_sb
  surf%psp_sg => pending%psp_sg
  surf%psp_sl => pending%psp_sl
  surf%psp_rr => pending%psp_rr
  surf%psp_ep => pending%psp_ep
  surf%psp_x2 => pending%psp_x2
  surf%psp_om => pending%psp_om
  surf%psd_vf => pending%psd_vf
  surf%psd_vn => pending%psd_vn
  surf%psd_vd => pending%psd_vd
  surf%psd_ws => pending%psd_ws
  surf%psd_ww => pending%psd_ww
  surf%psd_xa => pending%psd_xa
  surf%psd_x2 => pending%psd_x2
  surf%psd_sm => pending%psd_sm
  surf%psd_v2 => pending%psd_v2
  surf%psd_v3 => pending%psd_v3
  owned = acquired; status = 0
  call ieee_set_status(incoming); error_number = incoming_errno
  return
800 call ieee_get_status(reached); failed_errno = error_number
  if (acquired(1)) deallocate (pending%psp_sb)
  if (acquired(2)) deallocate (pending%psp_sg)
  if (acquired(3)) deallocate (pending%psp_sl)
  if (acquired(4)) deallocate (pending%psp_rr)
  if (acquired(5)) deallocate (pending%psp_ep)
  if (acquired(6)) deallocate (pending%psp_x2)
  if (acquired(7)) deallocate (pending%psp_om)
  if (acquired(8)) deallocate (pending%psd_vf)
  if (acquired(9)) deallocate (pending%psd_vn)
  if (acquired(10)) deallocate (pending%psd_vd)
  if (acquired(11)) deallocate (pending%psd_ws)
  if (acquired(12)) deallocate (pending%psd_ww)
  if (acquired(13)) deallocate (pending%psd_xa)
  if (acquired(14)) deallocate (pending%psd_x2)
  if (acquired(15)) deallocate (pending%psd_sm)
  if (acquired(16)) deallocate (pending%psd_v2)
  if (acquired(17)) deallocate (pending%psd_v3)
  call ieee_set_status(reached); error_number = failed_errno
  end function
  !> Release only owned fallbacks, in source order, after all block readers return.
 !! Counts and native owners are unchanged since preparation. Borrowed positive
 !! groups and every unrelated component remain attached. Repeated release is safe.
  integer(int32) function release_physics_surface_block_views(surf, metadata, owned) result(status)
    type(surf_and_more_type), intent(inout) :: surf
    type(surface_field_registry), intent(in) :: metadata
    logical, intent(inout) :: owned(17)
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer :: groups(17)
    status = 2
    groups(1) = surface_group_index(metadata, 'YSP_SBD')
    if (groups(1) == 0) return
    if (owned(1) .and. metadata%groups(groups(1))%metadata%registered_fields > 0) return
    groups(2) = surface_group_index(metadata, 'YSP_SGD')
    if (groups(2) == 0) return
    if (owned(2) .and. metadata%groups(groups(2))%metadata%registered_fields > 0) return
    groups(3) = surface_group_index(metadata, 'YSP_SLD')
    if (groups(3) == 0) return
    if (owned(3) .and. metadata%groups(groups(3))%metadata%registered_fields > 0) return
    groups(4) = surface_group_index(metadata, 'YSP_RRD')
    if (groups(4) == 0) return
    if (owned(4) .and. metadata%groups(groups(4))%metadata%registered_fields > 0) return
    groups(5) = surface_group_index(metadata, 'YSP_EPD')
    if (groups(5) == 0) return
    if (owned(5) .and. metadata%groups(groups(5))%metadata%registered_fields > 0) return
    groups(6) = surface_group_index(metadata, 'YSP_X2D')
    if (groups(6) == 0) return
    if (owned(6) .and. metadata%groups(groups(6))%metadata%registered_fields > 0) return
    groups(7) = surface_group_index(metadata, 'YSP_OMD')
    if (groups(7) == 0) return
    if (owned(7) .and. metadata%groups(groups(7))%metadata%registered_fields > 0) return
    groups(8) = surface_group_index(metadata, 'YSD_VFD')
    if (groups(8) == 0) return
    if (owned(8) .and. metadata%groups(groups(8))%metadata%registered_fields > 0) return
    groups(9) = surface_group_index(metadata, 'YSD_VND')
    if (groups(9) == 0) return
    if (owned(9) .and. metadata%groups(groups(9))%metadata%registered_fields > 0) return
    groups(10) = surface_group_index(metadata, 'YSD_VDD')
    if (groups(10) == 0) return
    if (owned(10) .and. metadata%groups(groups(10))%metadata%registered_fields > 0) return
    groups(11) = surface_group_index(metadata, 'YSD_WSD')
    if (groups(11) == 0) return
    if (owned(11) .and. metadata%groups(groups(11))%metadata%registered_fields > 0) return
    groups(12) = surface_group_index(metadata, 'YSD_WWD')
    if (groups(12) == 0) return
    if (owned(12) .and. metadata%groups(groups(12))%metadata%registered_fields > 0) return
    groups(13) = surface_group_index(metadata, 'YSD_XAD')
    if (groups(13) == 0) return
    if (owned(13) .and. metadata%groups(groups(13))%metadata%registered_fields > 0) return
    groups(14) = surface_group_index(metadata, 'YSD_X2D')
    if (groups(14) == 0) return
    if (owned(14) .and. metadata%groups(groups(14))%metadata%registered_fields > 0) return
    groups(15) = surface_group_index(metadata, 'YSD_SMD')
    if (groups(15) == 0) return
    if (owned(15) .and. metadata%groups(groups(15))%metadata%registered_fields > 0) return
    groups(16) = surface_group_index(metadata, 'YSD_V2D')
    if (groups(16) == 0) return
    if (owned(16) .and. metadata%groups(groups(16))%metadata%registered_fields > 0) return
    groups(17) = surface_group_index(metadata, 'YSD_V3D')
    if (groups(17) == 0) return
    if (owned(17) .and. metadata%groups(groups(17))%metadata%registered_fields > 0) return
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    if (owned(1)) then
      if (associated(surf%psp_sb)) deallocate (surf%psp_sb)
      nullify (surf%psp_sb); owned(1) = .false.
    end if
    if (owned(2)) then
      if (associated(surf%psp_sg)) deallocate (surf%psp_sg)
      nullify (surf%psp_sg); owned(2) = .false.
    end if
    if (owned(3)) then
      if (associated(surf%psp_sl)) deallocate (surf%psp_sl)
      nullify (surf%psp_sl); owned(3) = .false.
    end if
    if (owned(4)) then
      if (associated(surf%psp_rr)) deallocate (surf%psp_rr)
      nullify (surf%psp_rr); owned(4) = .false.
    end if
    if (owned(5)) then
      if (associated(surf%psp_ep)) deallocate (surf%psp_ep)
      nullify (surf%psp_ep); owned(5) = .false.
    end if
    if (owned(6)) then
      if (associated(surf%psp_x2)) deallocate (surf%psp_x2)
      nullify (surf%psp_x2); owned(6) = .false.
    end if
    if (owned(7)) then
      if (associated(surf%psp_om)) deallocate (surf%psp_om)
      nullify (surf%psp_om); owned(7) = .false.
    end if
    if (owned(8)) then
      if (associated(surf%psd_vf)) deallocate (surf%psd_vf)
      nullify (surf%psd_vf); owned(8) = .false.
    end if
    if (owned(9)) then
      if (associated(surf%psd_vn)) deallocate (surf%psd_vn)
      nullify (surf%psd_vn); owned(9) = .false.
    end if
    if (owned(10)) then
      if (associated(surf%psd_vd)) deallocate (surf%psd_vd)
      nullify (surf%psd_vd); owned(10) = .false.
    end if
    if (owned(11)) then
      if (associated(surf%psd_ws)) deallocate (surf%psd_ws)
      nullify (surf%psd_ws); owned(11) = .false.
    end if
    if (owned(12)) then
      if (associated(surf%psd_ww)) deallocate (surf%psd_ww)
      nullify (surf%psd_ww); owned(12) = .false.
    end if
    if (owned(13)) then
      if (associated(surf%psd_xa)) deallocate (surf%psd_xa)
      nullify (surf%psd_xa); owned(13) = .false.
    end if
    if (owned(14)) then
      if (associated(surf%psd_x2)) deallocate (surf%psd_x2)
      nullify (surf%psd_x2); owned(14) = .false.
    end if
    if (owned(15)) then
      if (associated(surf%psd_sm)) deallocate (surf%psd_sm)
      nullify (surf%psd_sm); owned(15) = .false.
    end if
    if (owned(16)) then
      if (associated(surf%psd_v2)) deallocate (surf%psd_v2)
      nullify (surf%psd_v2); owned(16) = .false.
    end if
    if (owned(17)) then
      if (associated(surf%psd_v3)) deallocate (surf%psd_v3)
      nullify (surf%psd_v3); owned(17) = .false.
    end if
    call ieee_set_status(saved); error_number = saved_errno; status = 0
  end function
end module
