!> Typed borrowed context targets and original ordered child argument views.
module physics_context_child_helpers_mod
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_null_ptr, c_loc, c_f_pointer, c_int
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_grid_motion_types, only: native_grid_motion_state
  use forecast_native_field_variable_types, only: native_field_variables, native_surface_variables
  use forecast_physics_field_views, only: physics_field_view_3d, physics_field_view_4d
  use surface_field_configuration_port, only: surface_field_registry
  use forecast_physics_work_types, only: dimension_type, state_type, aux_type, aux_rad_type, aux_diag_type, &
                                      aux_diag_local_type, ddh_surf_type, flux_type, surf_and_more_type, surf_and_more_local_type, &
                                         keys_local_type, perturb_type, perturb_local_type
  use yomphyder, only: model_state_type
  use yomtraj, only: traj_phys_type
  use physics_grid_dimension_helpers_mod, only: surface_group_index
  use physics_context_helper_counters_mod, only: increment_context_helper_count
  implicit none
  private
  public :: physics_context_record_targets, physics_context_array_targets, physics_storage_child_table
  !> Every pointer borrows an existing canonical target. This type owns no payload.
  !! The caller keeps all targets stable until the corresponding block finishes.
  type :: physics_context_record_targets
    type(native_geometry_state), pointer :: geometry => null()
    type(native_field_variables), pointer :: variables => null()
    type(native_grid_motion_state), pointer :: motion => null()
    type(surface_field_registry), pointer :: surface_metadata => null()
    type(native_operational_model_configuration), pointer :: model => null()
    type(dimension_type), pointer :: dimensions => null()
    type(aux_type), pointer :: auxiliary => null()
    type(surf_and_more_type), pointer :: surface => null()
    type(aux_rad_type), pointer :: radiation => null()
    type(perturb_type), pointer :: perturbation => null()
    type(flux_type), pointer :: flux => null()
    type(aux_diag_type), pointer :: diagnostics => null()
    type(ddh_surf_type), pointer :: surface_diagnostics => null()
    type(aux_diag_local_type), pointer :: auxiliary_local => null()
    type(surf_and_more_local_type), pointer :: surface_local => null()
    type(keys_local_type), pointer :: keys => null()
    type(perturb_local_type), pointer :: perturbation_local => null()
    type(model_state_type), pointer :: previous_state => null()
    type(state_type), pointer :: state_t0 => null()
    type(state_type), pointer :: tendency_dyn => null()
    type(state_type), pointer :: tendency_cml => null()
    type(state_type), pointer :: state_tmp => null()
    type(state_type), pointer :: tendency_tmp => null()
    type(state_type), pointer :: tendency_vdf => null()
    type(state_type), pointer :: tendency_satadj => null()
    type(state_type), pointer :: tendency_loc => null()
    character(len=1), pointer :: configuration => null()
    type(state_type), pointer :: tendency_phy(:) => null()
    type(traj_phys_type), pointer :: trajectory_primary(:) => null(), trajectory_oops(:) => null()
    type(traj_phys_type), pointer :: trajectory_physics => null()
  end type
  !> Source array views are borrowed. Rank4 uses(cell,level,component,block),
  !! rank3 uses(cell,level-or-component,block), and rank2 uses(cell,block).
  !! Observation buffers instead retain their original complete global shapes.
  type :: physics_context_array_targets
    real(real64), pointer :: pbup9(:, :, :) => null()
    real(real64), pointer :: pbvp9(:, :, :) => null()
    real(real64), pointer :: pbtp9(:, :, :) => null()
    real(real64), pointer :: pb2(:, :, :) => null()
    real(real64), pointer :: convectivity(:, :, :) => null()
    real(real64), pointer :: smos_observations(:, :, :) => null()
    real(real64), pointer :: smos_brightness(:, :, :) => null()
    real(real64), pointer :: smos_angle(:, :, :) => null()
    real(real64), pointer :: smos_faraday(:, :, :) => null()
    real(real64), pointer :: smos_geometry(:, :, :) => null()
    real(real64), pointer :: gflt1(:, :, :, :) => null()
    real(real64), pointer :: gfl(:, :, :, :) => null()
    real(real64), pointer :: gflslp(:, :, :, :) => null()
    real(real64), pointer :: phys_mwave(:, :, :, :) => null()
    real(real64), pointer :: saved_tendencies(:, :, :, :) => null()
    real(real64), pointer :: pbgflp9(:, :, :, :) => null()
    real(real64), pointer :: extra_dynamics(:, :, :, :) => null()
    real(real64), pointer :: coverage(:, :, :, :) => null()
    real(real64), pointer :: cgpp(:, :) => null()
    real(real64), pointer :: crec(:, :) => null()
    real(real64), pointer :: smap_observations(:, :) => null()
    real(real64), pointer :: smap_brightness(:, :) => null()
    real(real64), pointer :: smap_angle(:, :) => null()
    real(real64), pointer :: pgmvt1(:, :, :, :) => null(), pgmv(:, :, :, :) => null(), zgfl_dyn(:, :, :, :) => null()
    integer(int32), pointer :: smos_keys(:, :, :) => null(), smap_keys(:, :) => null()
  end type
  interface
    function errno_address() bind(c, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
    subroutine abort_allocation() bind(c, name="abort")
    end subroutine
  end interface
contains
  !> Bind source-selected block views and the55 transient C argument addresses.
  !! RECORDS and ARRAY_TARGETS borrow the caller's one native context. TABLE
  !! is address metadata only; the parent calls numerical children through
  !! these same typed targets. SURFACE_VARIABLES is the canonical registry.
  !! FALLBACK_OWNED(17) records only the17 newly allocated surface fallbacks,
  !! in the frozen source order. Parent cleanup releases exactly those views.
  !! New fallback values are undefined; no zeroing or physical stage is added.
  !! VERTICAL_VELOCITY_FIRST is the actual source MSLB2VVEL selector.
  !! Counts and indices are dimensionless; no numerical field value changes.
  !! Caller supplies the admitted complete contiguous one-origin owners and
  !! valid selected block. Status2 is an interface refusal; allocation failure
  !! invokes the retained nonreturning public C abort boundary.
  integer(int32) function physics_storage_child_table(records, array_targets, surface_variables, surface_metadata, &
                                                      block, vertical_velocity_first, table, fallback_owned) result(status)
    type(physics_context_record_targets), intent(inout) :: records
    type(physics_context_array_targets), intent(in) :: array_targets
    type(native_surface_variables), intent(in) :: surface_variables
    type(surface_field_registry), intent(in) :: surface_metadata
    integer(int32), intent(in) :: block, vertical_velocity_first
    type(c_ptr), intent(inout) :: table(:)
    logical, intent(inout) :: fallback_owned(:)
    type(ieee_status_type) :: saved_ieee
    integer(c_int), pointer, volatile :: saved_errno_target
    integer(c_int) :: saved_errno
    integer :: group, allocation_status, rows, levels, j
    type(c_ptr) :: arguments(55)
    status = 2
    if (size(table) /= 55 .or. size(fallback_owned) /= 17) return
    if (any(fallback_owned)) return
    if (.not. associated(records%geometry)) return
    if (.not. associated(records%variables)) return
    if (.not. associated(records%motion)) return
    if (.not. associated(records%surface_metadata)) return
    if (.not. associated(records%model)) return
    if (.not. associated(records%dimensions)) return
    if (.not. associated(records%auxiliary)) return
    if (.not. associated(records%surface)) return
    if (.not. associated(records%radiation)) return
    if (.not. associated(records%perturbation)) return
    if (.not. associated(records%flux)) return
    if (.not. associated(records%diagnostics)) return
    if (.not. associated(records%surface_diagnostics)) return
    if (.not. associated(records%auxiliary_local)) return
    if (.not. associated(records%surface_local)) return
    if (.not. associated(records%keys)) return
    if (.not. associated(records%perturbation_local)) return
    if (.not. associated(records%previous_state)) return
    if (.not. associated(records%configuration)) return
    if (.not. associated(records%state_t0)) return
    if (.not. associated(records%tendency_dyn)) return
    if (.not. associated(records%tendency_cml)) return
    if (.not. associated(records%state_tmp)) return
    if (.not. associated(records%tendency_tmp)) return
    if (.not. associated(records%tendency_vdf)) return
    if (.not. associated(records%tendency_satadj)) return
    if (.not. associated(records%tendency_loc)) return
    if (.not. associated(records%tendency_phy)) return
    rows = records%geometry%dimensions%nproma; levels = records%geometry%dimensions%nflevg
    if (block < 1 .or. block > records%geometry%partition%ngpblks .or. rows < 1 .or. levels < 0) return
    if (vertical_velocity_first < 1) return
    if (.not. associated(array_targets%gflt1)) return
    if (.not. associated(array_targets%gfl)) return
    if (.not. associated(array_targets%gflslp)) return
    if (.not. associated(array_targets%convectivity)) return
    if (.not. associated(array_targets%phys_mwave)) return
    if (.not. associated(array_targets%cgpp)) return
    if (.not. associated(array_targets%crec)) return
    if (.not. associated(array_targets%saved_tendencies)) return
    if (.not. associated(array_targets%pbup9)) return
    if (.not. associated(array_targets%pbvp9)) return
    if (.not. associated(array_targets%pbtp9)) return
    if (.not. associated(array_targets%pbgflp9)) return
    if (.not. associated(array_targets%pb2)) return
    if (.not. associated(array_targets%extra_dynamics)) return
    if (.not. associated(array_targets%coverage)) return
    if (size(array_targets%gflt1, 4) < block) return
    if (size(array_targets%gfl, 4) < block) return
    if (size(array_targets%gflslp, 4) < block) return
    if (size(array_targets%phys_mwave, 4) < block) return
    if (size(array_targets%saved_tendencies, 4) < block) return
    if (size(array_targets%pbgflp9, 4) < block) return
    if (size(array_targets%extra_dynamics, 4) < block) return
    if (size(array_targets%coverage, 4) < block) return
    if (size(array_targets%convectivity, 3) < block) return
    if (size(array_targets%pbup9, 3) < block) return
    if (size(array_targets%pbvp9, 3) < block) return
    if (size(array_targets%pbtp9, 3) < block) return
    if (size(array_targets%pb2, 3) < block) return
    if (size(array_targets%cgpp, 2) < block) return
    if (size(array_targets%crec, 2) < block) return
    if (size(array_targets%coverage, 3) < 1) return
    if (int(vertical_velocity_first, int64) + int(levels, int64) - 1_int64 > size(array_targets%pb2, 2, kind=int64)) return
    if (associated(records%trajectory_primary)) then
      if (block < lbound(records%trajectory_primary, 1) .or. block > ubound(records%trajectory_primary, 1)) return
    else
      if (.not. associated(records%trajectory_oops)) return
      if (block < lbound(records%trajectory_oops, 1) .or. block > ubound(records%trajectory_oops, 1)) return
    end if
    ! Validate every named surface metadata group before any fallback allocation.
    if (surface_group_index(surface_metadata, 'YSP_SBD') == 0) return
    if (surface_group_index(surface_metadata, 'YSP_SGD') == 0) return
    if (surface_group_index(surface_metadata, 'YSP_SLD') == 0) return
    if (surface_group_index(surface_metadata, 'YSP_RRD') == 0) return
    if (surface_group_index(surface_metadata, 'YSP_EPD') == 0) return
    if (surface_group_index(surface_metadata, 'YSP_X2D') == 0) return
    if (surface_group_index(surface_metadata, 'YSP_OMD') == 0) return
    if (surface_group_index(surface_metadata, 'YSD_VFD') == 0) return
    if (surface_group_index(surface_metadata, 'YSD_VND') == 0) return
    if (surface_group_index(surface_metadata, 'YSD_VDD') == 0) return
    if (surface_group_index(surface_metadata, 'YSD_WSD') == 0) return
    if (surface_group_index(surface_metadata, 'YSD_WWD') == 0) return
    if (surface_group_index(surface_metadata, 'YSD_XAD') == 0) return
    if (surface_group_index(surface_metadata, 'YSD_X2D') == 0) return
    if (surface_group_index(surface_metadata, 'YSD_SMD') == 0) return
    if (surface_group_index(surface_metadata, 'YSD_V2D') == 0) return
    if (surface_group_index(surface_metadata, 'YSD_V3D') == 0) return
    call increment_context_helper_count(3, 2)
    call ieee_get_status(saved_ieee)
    call c_f_pointer(errno_address(), saved_errno_target); saved_errno = saved_errno_target
    group = surface_group_index(surface_metadata, 'YSP_SBD')
    if (surface_metadata%groups(group)%metadata%registered_fields > 0) then
      status = physics_field_view_4d(records%surface%psp_sb, surface_variables%gsp_sb%f_group, block)
      if (status /= 0) then
        call ieee_set_status(saved_ieee); saved_errno_target = saved_errno; return
      end if
    else
      allocate (records%surface%psp_sb(rows, max(1, surface_metadata%groups(group)%metadata%layers), 1), stat=allocation_status)
      if (allocation_status /= 0) call abort_allocation()
      fallback_owned(1) = .true.
    end if
    group = surface_group_index(surface_metadata, 'YSP_SGD')
    if (surface_metadata%groups(group)%metadata%registered_fields > 0) then
      status = physics_field_view_4d(records%surface%psp_sg, surface_variables%gsp_sg%f_group, block)
      if (status /= 0) then
        call ieee_set_status(saved_ieee); saved_errno_target = saved_errno; return
      end if
    else
      allocate (records%surface%psp_sg(rows, max(1, surface_metadata%groups(group)%metadata%layers), 1), stat=allocation_status)
      if (allocation_status /= 0) call abort_allocation()
      fallback_owned(2) = .true.
    end if
    group = surface_group_index(surface_metadata, 'YSP_SLD')
    if (surface_metadata%groups(group)%metadata%registered_fields > 0) then
      status = physics_field_view_3d(records%surface%psp_sl, surface_variables%gsp_sl%f_group, block)
      if (status /= 0) then
        call ieee_set_status(saved_ieee); saved_errno_target = saved_errno; return
      end if
    else
      allocate (records%surface%psp_sl(rows, 1), stat=allocation_status)
      if (allocation_status /= 0) call abort_allocation()
      fallback_owned(3) = .true.
    end if
    group = surface_group_index(surface_metadata, 'YSP_RRD')
    if (surface_metadata%groups(group)%metadata%registered_fields > 0) then
      status = physics_field_view_3d(records%surface%psp_rr, surface_variables%gsp_rr%f_group, block)
      if (status /= 0) then
        call ieee_set_status(saved_ieee); saved_errno_target = saved_errno; return
      end if
    else
      allocate (records%surface%psp_rr(rows, 1), stat=allocation_status)
      if (allocation_status /= 0) call abort_allocation()
      fallback_owned(4) = .true.
    end if
    group = surface_group_index(surface_metadata, 'YSP_EPD')
    if (surface_metadata%groups(group)%metadata%registered_fields > 0) then
      status = physics_field_view_4d(records%surface%psp_ep, surface_variables%gsp_ep%f_group, block)
      if (status /= 0) then
        call ieee_set_status(saved_ieee); saved_errno_target = saved_errno; return
      end if
    else
      allocate (records%surface%psp_ep(rows, max(1, surface_metadata%groups(group)%metadata%layers), 1), stat=allocation_status)
      if (allocation_status /= 0) call abort_allocation()
      fallback_owned(5) = .true.
    end if
    group = surface_group_index(surface_metadata, 'YSP_X2D')
    if (surface_metadata%groups(group)%metadata%registered_fields > 0) then
      status = physics_field_view_3d(records%surface%psp_x2, surface_variables%gsp_x2%f_group, block)
      if (status /= 0) then
        call ieee_set_status(saved_ieee); saved_errno_target = saved_errno; return
      end if
    else
      allocate (records%surface%psp_x2(rows, 1), stat=allocation_status)
      if (allocation_status /= 0) call abort_allocation()
      fallback_owned(6) = .true.
    end if
    group = surface_group_index(surface_metadata, 'YSP_OMD')
    if (surface_metadata%groups(group)%metadata%registered_fields > 0) then
      status = physics_field_view_4d(records%surface%psp_om, surface_variables%gsp_om%f_group, block)
      if (status /= 0) then
        call ieee_set_status(saved_ieee); saved_errno_target = saved_errno; return
      end if
    else
      allocate (records%surface%psp_om(rows, max(1, surface_metadata%groups(group)%metadata%layers), 1), stat=allocation_status)
      if (allocation_status /= 0) call abort_allocation()
      fallback_owned(7) = .true.
    end if
    group = surface_group_index(surface_metadata, 'YSD_VFD')
    if (surface_metadata%groups(group)%metadata%registered_fields > 0) then
      status = physics_field_view_3d(records%surface%psd_vf, surface_variables%gsd_vf%f_group, block)
      if (status /= 0) then
        call ieee_set_status(saved_ieee); saved_errno_target = saved_errno; return
      end if
    else
      allocate (records%surface%psd_vf(rows, 1), stat=allocation_status)
      if (allocation_status /= 0) call abort_allocation()
      fallback_owned(8) = .true.
    end if
    group = surface_group_index(surface_metadata, 'YSD_VND')
    if (surface_metadata%groups(group)%metadata%registered_fields > 0) then
      status = physics_field_view_3d(records%surface%psd_vn, surface_variables%gsd_vn%f_group, block)
      if (status /= 0) then
        call ieee_set_status(saved_ieee); saved_errno_target = saved_errno; return
      end if
    else
      allocate (records%surface%psd_vn(rows, 1), stat=allocation_status)
      if (allocation_status /= 0) call abort_allocation()
      fallback_owned(9) = .true.
    end if
    group = surface_group_index(surface_metadata, 'YSD_VDD')
    if (surface_metadata%groups(group)%metadata%registered_fields > 0) then
      status = physics_field_view_3d(records%surface%psd_vd, surface_variables%gsd_vd%f_group, block)
      if (status /= 0) then
        call ieee_set_status(saved_ieee); saved_errno_target = saved_errno; return
      end if
    else
      allocate (records%surface%psd_vd(rows, 1), stat=allocation_status)
      if (allocation_status /= 0) call abort_allocation()
      fallback_owned(10) = .true.
    end if
    group = surface_group_index(surface_metadata, 'YSD_WSD')
    if (surface_metadata%groups(group)%metadata%registered_fields > 0) then
      status = physics_field_view_3d(records%surface%psd_ws, surface_variables%gsd_ws%f_group, block)
      if (status /= 0) then
        call ieee_set_status(saved_ieee); saved_errno_target = saved_errno; return
      end if
    else
      allocate (records%surface%psd_ws(rows, 1), stat=allocation_status)
      if (allocation_status /= 0) call abort_allocation()
      fallback_owned(11) = .true.
    end if
    group = surface_group_index(surface_metadata, 'YSD_WWD')
    if (surface_metadata%groups(group)%metadata%registered_fields > 0) then
      status = physics_field_view_3d(records%surface%psd_ww, surface_variables%gsd_ww%f_group, block)
      if (status /= 0) then
        call ieee_set_status(saved_ieee); saved_errno_target = saved_errno; return
      end if
    else
      allocate (records%surface%psd_ww(rows, 1), stat=allocation_status)
      if (allocation_status /= 0) call abort_allocation()
      fallback_owned(12) = .true.
    end if
    group = surface_group_index(surface_metadata, 'YSD_XAD')
    if (surface_metadata%groups(group)%metadata%registered_fields > 0) then
      status = physics_field_view_4d(records%surface%psd_xa, surface_variables%gsd_xa%f_group, block)
      if (status /= 0) then
        call ieee_set_status(saved_ieee); saved_errno_target = saved_errno; return
      end if
    else
      allocate (records%surface%psd_xa(rows, max(1, surface_metadata%groups(group)%metadata%layers), 1), stat=allocation_status)
      if (allocation_status /= 0) call abort_allocation()
      fallback_owned(13) = .true.
    end if
    group = surface_group_index(surface_metadata, 'YSD_X2D')
    if (surface_metadata%groups(group)%metadata%registered_fields > 0) then
      status = physics_field_view_3d(records%surface%psd_x2, surface_variables%gsd_x2%f_group, block)
      if (status /= 0) then
        call ieee_set_status(saved_ieee); saved_errno_target = saved_errno; return
      end if
    else
      allocate (records%surface%psd_x2(rows, 1), stat=allocation_status)
      if (allocation_status /= 0) call abort_allocation()
      fallback_owned(14) = .true.
    end if
    group = surface_group_index(surface_metadata, 'YSD_SMD')
    if (surface_metadata%groups(group)%metadata%registered_fields > 0) then
      status = physics_field_view_4d(records%surface%psd_sm, surface_variables%gsd_sm%f_group, block)
      if (status /= 0) then
        call ieee_set_status(saved_ieee); saved_errno_target = saved_errno; return
      end if
    else
      allocate (records%surface%psd_sm(rows, max(1, surface_metadata%groups(group)%metadata%layers), 1), stat=allocation_status)
      if (allocation_status /= 0) call abort_allocation()
      fallback_owned(15) = .true.
    end if
    group = surface_group_index(surface_metadata, 'YSD_V2D')
    if (surface_metadata%groups(group)%metadata%registered_fields > 0) then
      status = physics_field_view_3d(records%surface%psd_v2, surface_variables%gsd_v2%f_group, block)
      if (status /= 0) then
        call ieee_set_status(saved_ieee); saved_errno_target = saved_errno; return
      end if
    else
      allocate (records%surface%psd_v2(rows, 1), stat=allocation_status)
      if (allocation_status /= 0) call abort_allocation()
      fallback_owned(16) = .true.
    end if
    group = surface_group_index(surface_metadata, 'YSD_V3D')
    if (surface_metadata%groups(group)%metadata%registered_fields > 0) then
      status = physics_field_view_4d(records%surface%psd_v3, surface_variables%gsd_v3%f_group, block)
      if (status /= 0) then
        call ieee_set_status(saved_ieee); saved_errno_target = saved_errno; return
      end if
    else
      allocate (records%surface%psd_v3(rows, max(1, surface_metadata%groups(group)%metadata%layers), 1), stat=allocation_status)
      if (allocation_status /= 0) call abort_allocation()
      fallback_owned(17) = .true.
    end if
    records%surface%pextrd => array_targets%extra_dynamics(:, :, :, block)
    records%surface%pcovptot => array_targets%coverage(:, :, 1, block)
    records%previous_state%u => array_targets%pbup9(:, :, block)
    records%previous_state%v => array_targets%pbvp9(:, :, block)
    records%previous_state%t => array_targets%pbtp9(:, :, block)
    records%previous_state%gfl => array_targets%pbgflp9(:, :, :, block)
    records%auxiliary%pvervel => array_targets%pb2(:, vertical_velocity_first:vertical_velocity_first + levels - 1, block)
    if (associated(records%trajectory_primary)) then
      records%trajectory_physics => records%trajectory_primary(block)
    else
      records%trajectory_physics => records%trajectory_oops(block)
    end if
    arguments(1) = c_loc(records%geometry)
    arguments(2) = c_loc(records%variables)
    arguments(3) = c_loc(records%motion)
    arguments(4) = c_loc(records%surface_metadata)
    arguments(5) = c_loc(records%model)
    arguments(6) = c_loc(records%configuration)
    arguments(7) = c_loc(records%dimensions)
    arguments(8) = c_loc(records%variables%u)
    arguments(9) = c_loc(records%variables%v)
    arguments(10) = c_loc(records%variables%t)
    arguments(11) = c_loc(records%variables%sp)
    arguments(12) = c_loc(records%variables%q)
    arguments(13) = c_loc(records%variables%i)
    arguments(14) = c_loc(records%variables%l)
    arguments(15) = c_loc(records%variables%a)
    arguments(16) = c_loc(array_targets%gflt1(:, :, :, block))
    arguments(17) = c_loc(array_targets%gfl(:, :, :, block))
    arguments(18) = c_loc(array_targets%gflslp(:, :, :, block))
    arguments(19) = c_loc(array_targets%convectivity(:, :, block))
    arguments(20) = c_loc(array_targets%phys_mwave(:, :, :, block))
    arguments(21) = c_loc(records%auxiliary)
    arguments(22) = c_loc(records%surface)
    arguments(23) = c_loc(array_targets%cgpp(:, block))
    arguments(24) = c_loc(array_targets%crec(:, block))
    arguments(25) = c_loc(records%radiation)
    arguments(26) = c_loc(records%perturbation)
    arguments(27) = c_loc(records%flux)
    arguments(28) = c_loc(records%diagnostics)
    arguments(29) = c_loc(records%surface_diagnostics)
    arguments(30) = c_loc(records%auxiliary_local)
    arguments(31) = c_loc(records%surface_local)
    arguments(32) = c_loc(records%keys)
    arguments(33) = c_loc(records%perturbation_local)
    arguments(34) = c_loc(records%previous_state)
    arguments(35) = c_loc(array_targets%saved_tendencies(:, :, :, block))
    arguments(36) = c_loc(records%trajectory_physics)
    arguments(37) = c_null_ptr
    if (associated(array_targets%smos_observations)) arguments(37) = c_loc(array_targets%smos_observations)
    arguments(38) = c_null_ptr
    if (associated(array_targets%smos_brightness)) arguments(38) = c_loc(array_targets%smos_brightness)
    arguments(39) = c_null_ptr
    if (associated(array_targets%smos_angle)) arguments(39) = c_loc(array_targets%smos_angle)
    arguments(40) = c_null_ptr
    if (associated(array_targets%smos_faraday)) arguments(40) = c_loc(array_targets%smos_faraday)
    arguments(41) = c_null_ptr
    if (associated(array_targets%smos_geometry)) arguments(41) = c_loc(array_targets%smos_geometry)
    arguments(42) = c_null_ptr
    if (associated(array_targets%smos_keys)) arguments(42) = c_loc(array_targets%smos_keys)
    arguments(43) = c_null_ptr
    if (associated(array_targets%smap_observations)) arguments(43) = c_loc(array_targets%smap_observations)
    arguments(44) = c_null_ptr
    if (associated(array_targets%smap_brightness)) arguments(44) = c_loc(array_targets%smap_brightness)
    arguments(45) = c_null_ptr
    if (associated(array_targets%smap_angle)) arguments(45) = c_loc(array_targets%smap_angle)
    arguments(46) = c_null_ptr
    if (associated(array_targets%smap_keys)) arguments(46) = c_loc(array_targets%smap_keys)
    arguments(47) = c_loc(records%state_t0)
    arguments(48) = c_loc(records%tendency_dyn)
    arguments(49) = c_loc(records%tendency_cml)
    arguments(50) = c_loc(records%state_tmp)
    arguments(51) = c_loc(records%tendency_tmp)
    arguments(52) = c_loc(records%tendency_vdf)
    arguments(53) = c_loc(records%tendency_satadj)
    arguments(54) = c_loc(records%tendency_loc)
    arguments(55) = c_loc(records%tendency_phy)
    table = arguments
    call ieee_set_status(saved_ieee); saved_errno_target = saved_errno
    status = 0
  end function physics_storage_child_table
end module physics_context_child_helpers_mod
