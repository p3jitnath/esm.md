!> Native surface work-record storage, views and source-ordered release.
module forecast_surface_work_record
  use iso_fortran_env, only: int32, int64
  use forecast_physics_work_types, only: surf_and_more_type
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_native_field_variable_types, only: native_field_variables, native_surface_variables
  use forecast_physics_field_views, only: physics_field_view_2d, physics_field_view_3d, physics_field_view_4d
  use forecast_integer_logical_work_fields, only: integer_work_field_view_2d
  use physics_work_record_support_mod
  implicit none
  private
  public :: initialize_surface_work_record, update_surface_work_views, finalize_surface_work_record
  public :: surf_and_more_type_init, surf_and_more_type_update_view, surf_and_more_type_final, surface_work_record_call_count_get
  integer(int64), save :: native_call_counts(3) = 0_int64
contains
  !> Allocate source-owned fields while borrowing the existing canonical fields.
  !! STATE is the unique mutable SURF_AND_MORE_TYPE; GEOMETRY and VARIABLES stay readonly.
  !! Counts are dimensionless; field values keep their original physical units.
  !! PERSISTENT defaults false: one thread buffer, otherwise actual grid blocks.
  !! New values are undefined. Incoming public views and all source-unwritten
  !! members remain unchanged. Status0 succeeds,1 releases a failed prefix,
  !! and2 refuses unsupported native metadata before ownership mutation.
 integer(int32) function initialize_surface_work_record(state,geometry,variables,surface_variables,levels,persistent) result(status)
    type(surf_and_more_type), intent(inout) :: state
    type(native_geometry_state), intent(in) :: geometry
    type(native_field_variables), intent(in) :: variables
    type(native_surface_variables), target, intent(in) :: surface_variables
    integer(int32), intent(in) :: levels(:)
    logical, optional, intent(in) :: persistent
    logical :: keep
    integer(int32) :: rows, blocks, cleanup_status
    type(work_record_status_snapshot) :: snapshot
    status = 2
    rows = geometry%dimensions%nproma; blocks = geometry%partition%ngpblks
    if (rows < 1 .or. blocks < 1) return
    if (size(levels) /= 3) return
    if (any(levels < 0)) return
    if (associated(state%f_pemis)) return
    if (associated(state%f_psnse1)) return
    if (associated(state%f_pasne1)) return
    if (associated(state%f_prsne1)) return
    if (associated(state%f_ptsne1)) return
    if (associated(state%f_pwsne1)) return
    if (associated(state%f_pwle1)) return
    if (associated(state%f_ptle1)) return
    if (associated(state%f_phstd)) return
    if (associated(state%f_pcvl)) return
    if (associated(state%f_pco2typ)) return
    if (associated(state%f_pcvh)) return
    if (associated(state%f_pcur)) return
    if (associated(state%f_plail)) return
    if (associated(state%f_plaih)) return
    if (associated(state%f_pfwet)) return
    if (associated(state%f_pevapmu)) return
    if (associated(state%f_ptlicee1)) return
    if (associated(state%f_ptlmnwe1)) return
    if (associated(state%f_ptlwmle1)) return
    if (associated(state%f_ptlbote1)) return
    if (associated(state%f_ptlsfe1)) return
    if (associated(state%f_phlicee1)) return
    if (associated(state%f_phlmle1)) return
    if (associated(state%f_ptsae1)) return
    if (associated(state%f_pwsae1)) return
    if (associated(state%f_ptiae1)) return
    if (associated(state%f_puoe1)) return
    if (associated(state%f_pvoe1)) return
    if (associated(state%f_ptoe1)) return
    if (associated(state%f_psoe1)) return
    if (associated(state%f_itvh)) return
    if (associated(state%f_itvl)) return
    if (associated(state%f_ico2typ)) return
    if (associated(state%f_isoty)) return
    keep = .false.
    if (present(persistent)) keep = persistent
    if (.not. keep) blocks = 1
    call capture_work_record_status(snapshot)
    nullify (state%f_pemis)
    nullify (state%f_psnse1)
    nullify (state%f_pasne1)
    nullify (state%f_prsne1)
    nullify (state%f_ptsne1)
    nullify (state%f_pwsne1)
    nullify (state%f_pwle1)
    nullify (state%f_ptle1)
    nullify (state%f_phstd)
    nullify (state%f_pcvl)
    nullify (state%f_pco2typ)
    nullify (state%f_pcvh)
    nullify (state%f_pcur)
    nullify (state%f_plail)
    nullify (state%f_plaih)
    nullify (state%f_pfwet)
    nullify (state%f_pevapmu)
    nullify (state%f_ptlicee1)
    nullify (state%f_ptlmnwe1)
    nullify (state%f_ptlwmle1)
    nullify (state%f_ptlbote1)
    nullify (state%f_ptlsfe1)
    nullify (state%f_phlicee1)
    nullify (state%f_phlmle1)
    nullify (state%f_ptsae1)
    nullify (state%f_pwsae1)
    nullify (state%f_ptiae1)
    nullify (state%f_puoe1)
    nullify (state%f_pvoe1)
    nullify (state%f_ptoe1)
    nullify (state%f_psoe1)
    nullify (state%f_itvh)
    nullify (state%f_itvl)
    nullify (state%f_ico2typ)
    nullify (state%f_isoty)
    state%gsp_sb%f_t_t0 => surface_variables%gsp_sb%vt%ft0
    state%gsp_sb%f_t_t1 => surface_variables%gsp_sb%vt%ft1
    state%gsp_sb%f_t_t9 => surface_variables%gsp_sb%vt%ft9
    state%gsp_sb%f_q_t0 => surface_variables%gsp_sb%vq%ft0
    state%gsp_sb%f_q_t1 => surface_variables%gsp_sb%vq%ft1
    state%gsp_sb%f_q_t9 => surface_variables%gsp_sb%vq%ft9
    state%gsp_sb%f_tl_t0 => surface_variables%gsp_sb%vtl%ft0
    state%gsp_sb%f_tl_t1 => surface_variables%gsp_sb%vtl%ft1
    state%gsp_sb%f_tl_t9 => surface_variables%gsp_sb%vtl%ft9
    state%gsp_sb%variable_group => surface_variables
    state%gsp_sb%group_code = 1_int32
    state%gsp_sb%f_group => surface_variables%gsp_sb%f_group
    state%gsp_sg%f_f_t0 => surface_variables%gsp_sg%vf%ft0
    state%gsp_sg%f_f_t1 => surface_variables%gsp_sg%vf%ft1
    state%gsp_sg%f_f_t9 => surface_variables%gsp_sg%vf%ft9
    state%gsp_sg%f_a_t0 => surface_variables%gsp_sg%va%ft0
    state%gsp_sg%f_a_t1 => surface_variables%gsp_sg%va%ft1
    state%gsp_sg%f_a_t9 => surface_variables%gsp_sg%va%ft9
    state%gsp_sg%f_r_t0 => surface_variables%gsp_sg%vr%ft0
    state%gsp_sg%f_r_t1 => surface_variables%gsp_sg%vr%ft1
    state%gsp_sg%f_r_t9 => surface_variables%gsp_sg%vr%ft9
    state%gsp_sg%f_t_t0 => surface_variables%gsp_sg%vt%ft0
    state%gsp_sg%f_t_t1 => surface_variables%gsp_sg%vt%ft1
    state%gsp_sg%f_t_t9 => surface_variables%gsp_sg%vt%ft9
    state%gsp_sg%f_w_t0 => surface_variables%gsp_sg%vw%ft0
    state%gsp_sg%f_w_t1 => surface_variables%gsp_sg%vw%ft1
    state%gsp_sg%f_w_t9 => surface_variables%gsp_sg%vw%ft9
    state%gsp_sg%variable_group => surface_variables
    state%gsp_sg%group_code = 2_int32
    state%gsp_sg%f_group => surface_variables%gsp_sg%f_group
    state%gsp_sl%f_lict_t0 => surface_variables%gsp_sl%vlict%ft0
    state%gsp_sl%f_lict_t1 => surface_variables%gsp_sl%vlict%ft1
    state%gsp_sl%f_lict_t9 => surface_variables%gsp_sl%vlict%ft9
    state%gsp_sl%f_lmlt_t0 => surface_variables%gsp_sl%vlmlt%ft0
    state%gsp_sl%f_lmlt_t1 => surface_variables%gsp_sl%vlmlt%ft1
    state%gsp_sl%f_lmlt_t9 => surface_variables%gsp_sl%vlmlt%ft9
    state%gsp_sl%f_ltlt_t0 => surface_variables%gsp_sl%vltlt%ft0
    state%gsp_sl%f_ltlt_t1 => surface_variables%gsp_sl%vltlt%ft1
    state%gsp_sl%f_ltlt_t9 => surface_variables%gsp_sl%vltlt%ft9
    state%gsp_sl%f_lblt_t0 => surface_variables%gsp_sl%vlblt%ft0
    state%gsp_sl%f_lblt_t1 => surface_variables%gsp_sl%vlblt%ft1
    state%gsp_sl%f_lblt_t9 => surface_variables%gsp_sl%vlblt%ft9
    state%gsp_sl%f_lshf_t0 => surface_variables%gsp_sl%vlshf%ft0
    state%gsp_sl%f_lshf_t1 => surface_variables%gsp_sl%vlshf%ft1
    state%gsp_sl%f_lshf_t9 => surface_variables%gsp_sl%vlshf%ft9
    state%gsp_sl%f_licd_t0 => surface_variables%gsp_sl%vlicd%ft0
    state%gsp_sl%f_licd_t1 => surface_variables%gsp_sl%vlicd%ft1
    state%gsp_sl%f_licd_t9 => surface_variables%gsp_sl%vlicd%ft9
    state%gsp_sl%f_lmld_t0 => surface_variables%gsp_sl%vlmld%ft0
    state%gsp_sl%f_lmld_t1 => surface_variables%gsp_sl%vlmld%ft1
    state%gsp_sl%f_lmld_t9 => surface_variables%gsp_sl%vlmld%ft9
    state%gsp_sl%variable_group => surface_variables
    state%gsp_sl%group_code = 3_int32
    state%gsp_sl%f_group => surface_variables%gsp_sl%f_group
    state%gsp_rr%f_t_t0 => surface_variables%gsp_rr%vt%ft0
    state%gsp_rr%f_t_t1 => surface_variables%gsp_rr%vt%ft1
    state%gsp_rr%f_t_t9 => surface_variables%gsp_rr%vt%ft9
    state%gsp_rr%f_w_t0 => surface_variables%gsp_rr%vw%ft0
    state%gsp_rr%f_w_t1 => surface_variables%gsp_rr%vw%ft1
    state%gsp_rr%f_w_t9 => surface_variables%gsp_rr%vw%ft9
    state%gsp_rr%f_fc_t0 => surface_variables%gsp_rr%vfc%ft0
    state%gsp_rr%f_fc_t1 => surface_variables%gsp_rr%vfc%ft1
    state%gsp_rr%f_fc_t9 => surface_variables%gsp_rr%vfc%ft9
    state%gsp_rr%f_ic_t0 => surface_variables%gsp_rr%vic%ft0
    state%gsp_rr%f_ic_t1 => surface_variables%gsp_rr%vic%ft1
    state%gsp_rr%f_ic_t9 => surface_variables%gsp_rr%vic%ft9
    state%gsp_rr%f_fp1_t0 => surface_variables%gsp_rr%vfp1%ft0
    state%gsp_rr%f_fp1_t1 => surface_variables%gsp_rr%vfp1%ft1
    state%gsp_rr%f_fp1_t9 => surface_variables%gsp_rr%vfp1%ft9
    state%gsp_rr%variable_group => surface_variables
    state%gsp_rr%group_code = 4_int32
    state%gsp_rr%f_group => surface_variables%gsp_rr%f_group
    state%gsp_cl%f_tcls_t0 => surface_variables%gsp_cl%vtcls%ft0
    state%gsp_cl%f_tcls_t1 => surface_variables%gsp_cl%vtcls%ft1
    state%gsp_cl%f_tcls_t9 => surface_variables%gsp_cl%vtcls%ft9
    state%gsp_cl%f_hucls_t0 => surface_variables%gsp_cl%vhucls%ft0
    state%gsp_cl%f_hucls_t1 => surface_variables%gsp_cl%vhucls%ft1
    state%gsp_cl%f_hucls_t9 => surface_variables%gsp_cl%vhucls%ft9
    state%gsp_cl%f_ucls_t0 => surface_variables%gsp_cl%vucls%ft0
    state%gsp_cl%f_ucls_t1 => surface_variables%gsp_cl%vucls%ft1
    state%gsp_cl%f_ucls_t9 => surface_variables%gsp_cl%vucls%ft9
    state%gsp_cl%f_vcls_t0 => surface_variables%gsp_cl%vvcls%ft0
    state%gsp_cl%f_vcls_t1 => surface_variables%gsp_cl%vvcls%ft1
    state%gsp_cl%f_vcls_t9 => surface_variables%gsp_cl%vvcls%ft9
    state%gsp_cl%f_nucls_t0 => surface_variables%gsp_cl%vnucls%ft0
    state%gsp_cl%f_nucls_t1 => surface_variables%gsp_cl%vnucls%ft1
    state%gsp_cl%f_nucls_t9 => surface_variables%gsp_cl%vnucls%ft9
    state%gsp_cl%f_nvcls_t0 => surface_variables%gsp_cl%vnvcls%ft0
    state%gsp_cl%f_nvcls_t1 => surface_variables%gsp_cl%vnvcls%ft1
    state%gsp_cl%f_nvcls_t9 => surface_variables%gsp_cl%vnvcls%ft9
    state%gsp_cl%variable_group => surface_variables
    state%gsp_cl%group_code = 5_int32
    state%gsp_cl%f_group => surface_variables%gsp_cl%f_group
    state%gsp_om%f_to_t0 => surface_variables%gsp_om%vto%ft0
    state%gsp_om%f_to_t1 => surface_variables%gsp_om%vto%ft1
    state%gsp_om%f_to_t9 => surface_variables%gsp_om%vto%ft9
    state%gsp_om%f_so_t0 => surface_variables%gsp_om%vso%ft0
    state%gsp_om%f_so_t1 => surface_variables%gsp_om%vso%ft1
    state%gsp_om%f_so_t9 => surface_variables%gsp_om%vso%ft9
    state%gsp_om%f_uo_t0 => surface_variables%gsp_om%vuo%ft0
    state%gsp_om%f_uo_t1 => surface_variables%gsp_om%vuo%ft1
    state%gsp_om%f_uo_t9 => surface_variables%gsp_om%vuo%ft9
    state%gsp_om%f_vo_t0 => surface_variables%gsp_om%vvo%ft0
    state%gsp_om%f_vo_t1 => surface_variables%gsp_om%vvo%ft1
    state%gsp_om%f_vo_t9 => surface_variables%gsp_om%vvo%ft9
    state%gsp_om%variable_group => surface_variables
    state%gsp_om%group_code = 6_int32
    state%gsp_om%f_group => surface_variables%gsp_om%f_group
    state%gsp_ep%variable_group => surface_variables
    state%gsp_ep%group_code = 7_int32
    state%gsp_ep%f_group => surface_variables%gsp_ep%f_group
    state%gsp_x2%variable_group => surface_variables
    state%gsp_x2%group_code = 8_int32
    state%gsp_x2%f_group => surface_variables%gsp_x2%f_group
    state%gsp_ci%variable_group => surface_variables
    state%gsp_ci%group_code = 9_int32
    state%gsp_ci%f_group => surface_variables%gsp_ci%f_group
    state%f_pustrti => variables%ecphys%ustrti%ft0
    state%f_pvstrti => variables%ecphys%vstrti%ft0
    state%f_pahfsti => variables%ecphys%ahfsti%ft0
    state%f_pevapti => variables%ecphys%evapti%ft0
    state%f_ptskti => variables%ecphys%tskti%ft0
    status = create_work_field(state%f_pemis, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_psnse1, [rows, levels(2), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pasne1, [rows, levels(2), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_prsne1, [rows, levels(2), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_ptsne1, [rows, levels(2), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pwsne1, [rows, levels(2), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pwle1, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_ptle1, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_phstd, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pcvl, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pco2typ, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pcvh, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pcur, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_plail, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_plaih, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfwet, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pevapmu, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_ptlicee1, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_ptlmnwe1, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_ptlwmle1, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_ptlbote1, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_ptlsfe1, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_phlicee1, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_phlmle1, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_ptsae1, [rows, levels(1), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pwsae1, [rows, levels(1), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_ptiae1, [rows, levels(1), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_puoe1, [rows, levels(3), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pvoe1, [rows, levels(3), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_ptoe1, [rows, levels(3), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_psoe1, [rows, levels(3), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_itvh, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_itvl, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_ico2typ, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_isoty, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    call restore_work_record_status(snapshot)
    status = 0
    return
900 cleanup_status = finalize_surface_work_record(state)
    call restore_work_record_status(snapshot)
    status = 1
  end function initialize_surface_work_record
  !> Associate source-ordered block views; never read or write a field value.
  !! BLOCK is one-origin. Every required field remains live. Optional absent
  !! group fields retain their incoming view. Native strides and bounds stay.
  integer(int32) function update_surface_work_views(state, block) result(status)
    type(surf_and_more_type), intent(inout) :: state
    integer(int32), intent(in) :: block
    type(work_record_status_snapshot) :: snapshot
    call capture_work_record_status(snapshot)
    status = 0
    status = physics_field_view_3d(state%gsp_sb%pt_t0, state%gsp_sb%f_t_t0, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_sb%pt_t1, state%gsp_sb%f_t_t1, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_sb%pt_t9, state%gsp_sb%f_t_t9, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_sb%pq_t0, state%gsp_sb%f_q_t0, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_sb%pq_t1, state%gsp_sb%f_q_t1, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_sb%pq_t9, state%gsp_sb%f_q_t9, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_sb%ptl_t0, state%gsp_sb%f_tl_t0, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_sb%ptl_t1, state%gsp_sb%f_tl_t1, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_sb%ptl_t9, state%gsp_sb%f_tl_t9, block)
    if (status /= 0) goto 900
    if (associated(state%gsp_sb%f_group)) then
      status = physics_field_view_4d(state%gsp_sb%pgroup, state%gsp_sb%f_group, block)
      if (status /= 0) goto 900
    end if
    status = physics_field_view_3d(state%gsp_sg%pf_t0, state%gsp_sg%f_f_t0, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_sg%pf_t1, state%gsp_sg%f_f_t1, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_sg%pf_t9, state%gsp_sg%f_f_t9, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_sg%pa_t0, state%gsp_sg%f_a_t0, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_sg%pa_t1, state%gsp_sg%f_a_t1, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_sg%pa_t9, state%gsp_sg%f_a_t9, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_sg%pr_t0, state%gsp_sg%f_r_t0, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_sg%pr_t1, state%gsp_sg%f_r_t1, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_sg%pr_t9, state%gsp_sg%f_r_t9, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_sg%pt_t0, state%gsp_sg%f_t_t0, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_sg%pt_t1, state%gsp_sg%f_t_t1, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_sg%pt_t9, state%gsp_sg%f_t_t9, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_sg%pw_t0, state%gsp_sg%f_w_t0, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_sg%pw_t1, state%gsp_sg%f_w_t1, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_sg%pw_t9, state%gsp_sg%f_w_t9, block)
    if (status /= 0) goto 900
    if (associated(state%gsp_sg%f_group)) then
      status = physics_field_view_4d(state%gsp_sg%pgroup, state%gsp_sg%f_group, block)
      if (status /= 0) goto 900
    end if
    status = physics_field_view_2d(state%gsp_sl%plict_t0, state%gsp_sl%f_lict_t0, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_sl%plict_t1, state%gsp_sl%f_lict_t1, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_sl%plict_t9, state%gsp_sl%f_lict_t9, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_sl%plmlt_t0, state%gsp_sl%f_lmlt_t0, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_sl%plmlt_t1, state%gsp_sl%f_lmlt_t1, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_sl%plmlt_t9, state%gsp_sl%f_lmlt_t9, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_sl%pltlt_t0, state%gsp_sl%f_ltlt_t0, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_sl%pltlt_t1, state%gsp_sl%f_ltlt_t1, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_sl%pltlt_t9, state%gsp_sl%f_ltlt_t9, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_sl%plblt_t0, state%gsp_sl%f_lblt_t0, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_sl%plblt_t1, state%gsp_sl%f_lblt_t1, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_sl%plblt_t9, state%gsp_sl%f_lblt_t9, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_sl%plshf_t0, state%gsp_sl%f_lshf_t0, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_sl%plshf_t1, state%gsp_sl%f_lshf_t1, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_sl%plshf_t9, state%gsp_sl%f_lshf_t9, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_sl%plicd_t0, state%gsp_sl%f_licd_t0, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_sl%plicd_t1, state%gsp_sl%f_licd_t1, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_sl%plicd_t9, state%gsp_sl%f_licd_t9, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_sl%plmld_t0, state%gsp_sl%f_lmld_t0, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_sl%plmld_t1, state%gsp_sl%f_lmld_t1, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_sl%plmld_t9, state%gsp_sl%f_lmld_t9, block)
    if (status /= 0) goto 900
    if (associated(state%gsp_sl%f_group)) then
      status = physics_field_view_3d(state%gsp_sl%pgroup, state%gsp_sl%f_group, block)
      if (status /= 0) goto 900
    end if
    status = physics_field_view_2d(state%gsp_rr%pt_t0, state%gsp_rr%f_t_t0, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_rr%pt_t1, state%gsp_rr%f_t_t1, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_rr%pt_t9, state%gsp_rr%f_t_t9, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_rr%pw_t0, state%gsp_rr%f_w_t0, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_rr%pw_t1, state%gsp_rr%f_w_t1, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_rr%pw_t9, state%gsp_rr%f_w_t9, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_rr%pfc_t0, state%gsp_rr%f_fc_t0, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_rr%pfc_t1, state%gsp_rr%f_fc_t1, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_rr%pfc_t9, state%gsp_rr%f_fc_t9, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_rr%pic_t0, state%gsp_rr%f_ic_t0, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_rr%pic_t1, state%gsp_rr%f_ic_t1, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_rr%pic_t9, state%gsp_rr%f_ic_t9, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_rr%pfp1_t0, state%gsp_rr%f_fp1_t0, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_rr%pfp1_t1, state%gsp_rr%f_fp1_t1, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_rr%pfp1_t9, state%gsp_rr%f_fp1_t9, block)
    if (status /= 0) goto 900
    if (associated(state%gsp_rr%f_group)) then
      status = physics_field_view_3d(state%gsp_rr%pgroup, state%gsp_rr%f_group, block)
      if (status /= 0) goto 900
    end if
    status = physics_field_view_2d(state%gsp_cl%ptcls_t0, state%gsp_cl%f_tcls_t0, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_cl%ptcls_t1, state%gsp_cl%f_tcls_t1, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_cl%ptcls_t9, state%gsp_cl%f_tcls_t9, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_cl%phucls_t0, state%gsp_cl%f_hucls_t0, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_cl%phucls_t1, state%gsp_cl%f_hucls_t1, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_cl%phucls_t9, state%gsp_cl%f_hucls_t9, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_cl%pucls_t0, state%gsp_cl%f_ucls_t0, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_cl%pucls_t1, state%gsp_cl%f_ucls_t1, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_cl%pucls_t9, state%gsp_cl%f_ucls_t9, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_cl%pvcls_t0, state%gsp_cl%f_vcls_t0, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_cl%pvcls_t1, state%gsp_cl%f_vcls_t1, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_cl%pvcls_t9, state%gsp_cl%f_vcls_t9, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_cl%pnucls_t0, state%gsp_cl%f_nucls_t0, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_cl%pnucls_t1, state%gsp_cl%f_nucls_t1, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_cl%pnucls_t9, state%gsp_cl%f_nucls_t9, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_cl%pnvcls_t0, state%gsp_cl%f_nvcls_t0, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_cl%pnvcls_t1, state%gsp_cl%f_nvcls_t1, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%gsp_cl%pnvcls_t9, state%gsp_cl%f_nvcls_t9, block)
    if (status /= 0) goto 900
    if (associated(state%gsp_cl%f_group)) then
      status = physics_field_view_3d(state%gsp_cl%pgroup, state%gsp_cl%f_group, block)
      if (status /= 0) goto 900
    end if
    status = physics_field_view_3d(state%gsp_om%pto_t0, state%gsp_om%f_to_t0, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_om%pto_t1, state%gsp_om%f_to_t1, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_om%pto_t9, state%gsp_om%f_to_t9, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_om%pso_t0, state%gsp_om%f_so_t0, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_om%pso_t1, state%gsp_om%f_so_t1, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_om%pso_t9, state%gsp_om%f_so_t9, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_om%puo_t0, state%gsp_om%f_uo_t0, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_om%puo_t1, state%gsp_om%f_uo_t1, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_om%puo_t9, state%gsp_om%f_uo_t9, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_om%pvo_t0, state%gsp_om%f_vo_t0, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_om%pvo_t1, state%gsp_om%f_vo_t1, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%gsp_om%pvo_t9, state%gsp_om%f_vo_t9, block)
    if (status /= 0) goto 900
    if (associated(state%gsp_om%f_group)) then
      status = physics_field_view_4d(state%gsp_om%pgroup, state%gsp_om%f_group, block)
      if (status /= 0) goto 900
    end if
    if (associated(state%gsp_ep%f_group)) then
      status = physics_field_view_4d(state%gsp_ep%pgroup, state%gsp_ep%f_group, block)
      if (status /= 0) goto 900
    end if
    if (associated(state%gsp_x2%f_group)) then
      status = physics_field_view_3d(state%gsp_x2%pgroup, state%gsp_x2%f_group, block)
      if (status /= 0) goto 900
    end if
    if (associated(state%gsp_ci%f_group)) then
      status = physics_field_view_3d(state%gsp_ci%pgroup, state%gsp_ci%f_group, block)
      if (status /= 0) goto 900
    end if
    status = physics_field_view_3d(state%pustrti, state%f_pustrti, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%pvstrti, state%f_pvstrti, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%pahfsti, state%f_pahfsti, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%pevapti, state%f_pevapti, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%ptskti, state%f_ptskti, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pemis, state%f_pemis, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%psnse1, state%f_psnse1, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%pasne1, state%f_pasne1, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%prsne1, state%f_prsne1, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%ptsne1, state%f_ptsne1, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%pwsne1, state%f_pwsne1, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pwle1, state%f_pwle1, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%ptle1, state%f_ptle1, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%phstd, state%f_phstd, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pcvl, state%f_pcvl, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pco2typ, state%f_pco2typ, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pcvh, state%f_pcvh, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pcur, state%f_pcur, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%plail, state%f_plail, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%plaih, state%f_plaih, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pfwet, state%f_pfwet, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pevapmu, state%f_pevapmu, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%ptlicee1, state%f_ptlicee1, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%ptlmnwe1, state%f_ptlmnwe1, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%ptlwmle1, state%f_ptlwmle1, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%ptlbote1, state%f_ptlbote1, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%ptlsfe1, state%f_ptlsfe1, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%phlicee1, state%f_phlicee1, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%phlmle1, state%f_phlmle1, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%ptsae1, state%f_ptsae1, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%pwsae1, state%f_pwsae1, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%ptiae1, state%f_ptiae1, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%puoe1, state%f_puoe1, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%pvoe1, state%f_pvoe1, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%ptoe1, state%f_ptoe1, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%psoe1, state%f_psoe1, block)
    if (status /= 0) goto 900
    status = integer_work_field_view_2d(state%itvh, state%f_itvh, block)
    if (status /= 0) goto 900
    status = integer_work_field_view_2d(state%itvl, state%f_itvl, block)
    if (status /= 0) goto 900
    status = integer_work_field_view_2d(state%ico2typ, state%f_ico2typ, block)
    if (status /= 0) goto 900
    status = integer_work_field_view_2d(state%isoty, state%f_isoty, block)
    if (status /= 0) goto 900
900 call restore_work_record_status(snapshot)
  end function update_surface_work_views
  !> Free only source-owned payloads and metadata, including a partial prefix.
  !! Borrowed fields, public array views and all other members remain unchanged.
  integer(int32) function finalize_surface_work_record(state) result(status)
    type(surf_and_more_type), intent(inout) :: state
    type(work_record_status_snapshot) :: snapshot
    call capture_work_record_status(snapshot)
    call delete_work_field(state%f_pemis)
    call delete_work_field(state%f_psnse1)
    call delete_work_field(state%f_pasne1)
    call delete_work_field(state%f_prsne1)
    call delete_work_field(state%f_ptsne1)
    call delete_work_field(state%f_pwsne1)
    call delete_work_field(state%f_pwle1)
    call delete_work_field(state%f_ptle1)
    call delete_work_field(state%f_phstd)
    call delete_work_field(state%f_pcvl)
    call delete_work_field(state%f_pco2typ)
    call delete_work_field(state%f_pcvh)
    call delete_work_field(state%f_pcur)
    call delete_work_field(state%f_plail)
    call delete_work_field(state%f_plaih)
    call delete_work_field(state%f_pfwet)
    call delete_work_field(state%f_pevapmu)
    call delete_work_field(state%f_ptlicee1)
    call delete_work_field(state%f_ptlmnwe1)
    call delete_work_field(state%f_ptlwmle1)
    call delete_work_field(state%f_ptlbote1)
    call delete_work_field(state%f_ptlsfe1)
    call delete_work_field(state%f_phlicee1)
    call delete_work_field(state%f_phlmle1)
    call delete_work_field(state%f_ptsae1)
    call delete_work_field(state%f_pwsae1)
    call delete_work_field(state%f_ptiae1)
    call delete_work_field(state%f_puoe1)
    call delete_work_field(state%f_pvoe1)
    call delete_work_field(state%f_ptoe1)
    call delete_work_field(state%f_psoe1)
    call delete_work_field(state%f_itvh)
    call delete_work_field(state%f_itvl)
    call delete_work_field(state%f_ico2typ)
    call delete_work_field(state%f_isoty)
    call restore_work_record_status(snapshot)
    status = 0
  end function finalize_surface_work_record
  !> Retain the original method's counter and nonreturning failure boundary.
  subroutine surf_and_more_type_init(state,geometry,variables,surface_variables,soil_levels,snow_levels,ocean_levels,persistent)
    type(surf_and_more_type), intent(inout) :: state
    type(native_geometry_state), intent(in) :: geometry
    type(native_field_variables), intent(in) :: variables
    type(native_surface_variables), target, intent(in) :: surface_variables
    integer(int32), intent(in) :: soil_levels, snow_levels, ocean_levels
    logical, optional, intent(in) :: persistent
    integer(int32) :: status
    call increment_work_word(native_call_counts(1))
 status=initialize_surface_work_record(state,geometry,variables,surface_variables,[soil_levels,snow_levels,ocean_levels],persistent)
    if (status /= 0) call abort_storage_failure()
  end subroutine
  subroutine surf_and_more_type_update_view(state, block)
    type(surf_and_more_type), intent(inout) :: state
    integer(int32), intent(in) :: block
    integer(int32) :: status
    call increment_work_word(native_call_counts(2))
    status = update_surface_work_views(state, block)
    if (status /= 0) call abort_storage_failure()
  end subroutine
  subroutine surf_and_more_type_final(state)
    type(surf_and_more_type), intent(inout) :: state
    integer(int32) :: status
    call increment_work_word(native_call_counts(3))
    status = finalize_surface_work_record(state)
  end subroutine
  integer(int64) function surface_work_record_call_count_get(index) result(count)
    integer(int32), intent(in) :: index
    count = 0_int64
    if (index >= 0 .and. index < 3) count = native_call_counts(index + 1)
  end function
end module forecast_surface_work_record
