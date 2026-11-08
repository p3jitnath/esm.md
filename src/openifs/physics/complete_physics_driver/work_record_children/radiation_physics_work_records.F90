!> Native radiation work-record storage, views and source-ordered release.
module forecast_radiation_work_record
  use iso_fortran_env, only: int32, int64
  use forecast_physics_work_types, only: aux_rad_type
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_native_field_variable_types, only: native_field_variables
  use forecast_physics_field_views, only: physics_field_view_2d, physics_field_view_3d, physics_field_view_4d
  use forecast_integer_logical_work_fields, only: integer_work_field_view_2d
  use physics_work_record_support_mod
  implicit none
  private
  public :: initialize_radiation_work_record, update_radiation_work_views, finalize_radiation_work_record
  public :: aux_rad_type_init, aux_rad_type_update_view, aux_rad_type_final, radiation_work_record_call_count_get
  integer(int64), save :: native_call_counts(3) = 0_int64
contains
  !> Allocate source-owned fields while borrowing the existing canonical fields.
  !! STATE is the unique mutable AUX_RAD_TYPE; GEOMETRY and VARIABLES stay readonly.
  !! Counts are dimensionless; field values keep their original physical units.
  !! PERSISTENT defaults false: one thread buffer, otherwise actual grid blocks.
  !! New values are undefined. Incoming public views and all source-unwritten
  !! members remain unchanged. Status0 succeeds,1 releases a failed prefix,
  !! and2 refuses unsupported native metadata before ownership mutation.
  integer(int32) function initialize_radiation_work_record(state, geometry, variables, levels, persistent) result(status)
    type(aux_rad_type), intent(inout) :: state
    type(native_geometry_state), intent(in) :: geometry
    type(native_field_variables), intent(in) :: variables
    integer(int32), intent(in) :: levels
    logical, optional, intent(in) :: persistent
    logical :: keep
    integer(int32) :: rows, blocks, cleanup_status
    type(work_record_status_snapshot) :: snapshot
    status = 2
    rows = geometry%dimensions%nproma; blocks = geometry%partition%ngpblks
    if (rows < 1 .or. blocks < 1) return
    if (levels < 0) return
    if (associated(state%f_ptincf)) return
    if (associated(state%f_pdsrp)) return
    if (associated(state%f_pfdir)) return
    if (associated(state%f_pcdir)) return
    if (associated(state%f_pisund)) return
    if (associated(state%f_pincsr)) return
    if (associated(state%f_pincsr0)) return
    if (associated(state%f_pneb)) return
    if (associated(state%f_pqice)) return
    if (associated(state%f_pqli)) return
    if (associated(state%f_phrsw)) return
    if (associated(state%f_phrlw)) return
    if (associated(state%f_phrsc)) return
    if (associated(state%f_phrlc)) return
    keep = .false.
    if (present(persistent)) keep = persistent
    if (.not. keep) blocks = 1
    call capture_work_record_status(snapshot)
    nullify (state%f_ptincf)
    nullify (state%f_pdsrp)
    nullify (state%f_pfdir)
    nullify (state%f_pcdir)
    nullify (state%f_pisund)
    nullify (state%f_pincsr)
    nullify (state%f_pincsr0)
    nullify (state%f_pneb)
    nullify (state%f_pqice)
    nullify (state%f_pqli)
    nullify (state%f_phrsw)
    nullify (state%f_phrlw)
    nullify (state%f_phrsc)
    nullify (state%f_phrlc)
    state%f_pemtd => variables%radiation%emtd%ft0
    state%f_ptrsw => variables%radiation%trsw%ft0
    state%f_pemtc => variables%radiation%emtc%ft0
    state%f_ptrsc => variables%radiation%trsc%ft0
    state%f_ptauaer => variables%radiation%tauaer%ft0
    state%f_psrlwd => variables%radiation%srlwd%ft0
    state%f_psrlwdc => variables%radiation%srlwdc%ft0
    state%f_psrswd => variables%radiation%srswd%ft0
    state%f_psrswdc => variables%radiation%srswdc%ft0
    state%f_psrswdcs => variables%radiation%srswdcs%ft0
    state%f_pedro => variables%radiation%edro%ft0
    state%f_psrswpar => variables%radiation%srswpar%ft0
    state%f_psrswuvb => variables%radiation%srswuvb%ft0
    state%f_psrswparc => variables%radiation%srswparc%ft0
    state%f_psrswtinc => variables%radiation%srswtinc%ft0
    state%f_psrfdir => variables%radiation%srfdir%ft0
    state%f_psrcdir => variables%radiation%srcdir%ft0
    state%f_derivativelw => variables%radiation%derivativelw%ft0
    status = create_work_field(state%f_ptincf, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pdsrp, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfdir, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pcdir, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pisund, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pincsr, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pincsr0, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pneb, [rows, levels, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pqice, [rows, levels, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pqli, [rows, levels, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_phrsw, [rows, levels, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_phrlw, [rows, levels, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_phrsc, [rows, levels, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_phrlc, [rows, levels, blocks],.not. keep)
    if (status /= 0) goto 900
    call restore_work_record_status(snapshot)
    status = 0
    return
900 cleanup_status = finalize_radiation_work_record(state)
    call restore_work_record_status(snapshot)
    status = 1
  end function initialize_radiation_work_record
  !> Associate source-ordered block views; never read or write a field value.
  !! BLOCK is one-origin. Every required field remains live. Optional absent
  !! group fields retain their incoming view. Native strides and bounds stay.
  integer(int32) function update_radiation_work_views(state, block) result(status)
    type(aux_rad_type), intent(inout) :: state
    integer(int32), intent(in) :: block
    type(work_record_status_snapshot) :: snapshot
    call capture_work_record_status(snapshot)
    status = 0
    status = physics_field_view_3d(state%pemtd, state%f_pemtd, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%ptrsw, state%f_ptrsw, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%pemtc, state%f_pemtc, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%ptrsc, state%f_ptrsc, block)
    if (status /= 0) goto 900
    status = physics_field_view_4d(state%ptauaer, state%f_ptauaer, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%psrlwd, state%f_psrlwd, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%psrlwdc, state%f_psrlwdc, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%psrswd, state%f_psrswd, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%psrswdc, state%f_psrswdc, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%psrswdcs, state%f_psrswdcs, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pedro, state%f_pedro, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%psrswpar, state%f_psrswpar, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%psrswuvb, state%f_psrswuvb, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%psrswparc, state%f_psrswparc, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%psrswtinc, state%f_psrswtinc, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%psrfdir, state%f_psrfdir, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%psrcdir, state%f_psrcdir, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%derivativelw, state%f_derivativelw, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%ptincf, state%f_ptincf, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pdsrp, state%f_pdsrp, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pfdir, state%f_pfdir, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pcdir, state%f_pcdir, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pisund, state%f_pisund, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pincsr, state%f_pincsr, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pincsr0, state%f_pincsr0, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%pneb, state%f_pneb, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%pqice, state%f_pqice, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%pqli, state%f_pqli, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%phrsw, state%f_phrsw, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%phrlw, state%f_phrlw, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%phrsc, state%f_phrsc, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%phrlc, state%f_phrlc, block)
    if (status /= 0) goto 900
900 call restore_work_record_status(snapshot)
  end function update_radiation_work_views
  !> Free only source-owned payloads and metadata, including a partial prefix.
  !! Borrowed fields, public array views and all other members remain unchanged.
  integer(int32) function finalize_radiation_work_record(state) result(status)
    type(aux_rad_type), intent(inout) :: state
    type(work_record_status_snapshot) :: snapshot
    call capture_work_record_status(snapshot)
    call delete_work_field(state%f_ptincf)
    call delete_work_field(state%f_pdsrp)
    call delete_work_field(state%f_pfdir)
    call delete_work_field(state%f_pcdir)
    call delete_work_field(state%f_pisund)
    call delete_work_field(state%f_pincsr)
    call delete_work_field(state%f_pincsr0)
    call delete_work_field(state%f_pneb)
    call delete_work_field(state%f_pqice)
    call delete_work_field(state%f_pqli)
    call delete_work_field(state%f_phrsw)
    call delete_work_field(state%f_phrlw)
    call delete_work_field(state%f_phrsc)
    call delete_work_field(state%f_phrlc)
    call restore_work_record_status(snapshot)
    status = 0
  end function finalize_radiation_work_record
  !> Retain the original method's counter and nonreturning failure boundary.
  subroutine aux_rad_type_init(state, geometry, variables, levels, persistent)
    type(aux_rad_type), intent(inout) :: state
    type(native_geometry_state), intent(in) :: geometry
    type(native_field_variables), intent(in) :: variables
    integer(int32), intent(in) :: levels
    logical, optional, intent(in) :: persistent
    integer(int32) :: status
    call increment_work_word(native_call_counts(1))
    status = initialize_radiation_work_record(state, geometry, variables, levels, persistent)
    if (status /= 0) call abort_storage_failure()
  end subroutine
  subroutine aux_rad_type_update_view(state, block)
    type(aux_rad_type), intent(inout) :: state
    integer(int32), intent(in) :: block
    integer(int32) :: status
    call increment_work_word(native_call_counts(2))
    status = update_radiation_work_views(state, block)
    if (status /= 0) call abort_storage_failure()
  end subroutine
  subroutine aux_rad_type_final(state)
    type(aux_rad_type), intent(inout) :: state
    integer(int32) :: status
    call increment_work_word(native_call_counts(3))
    status = finalize_radiation_work_record(state)
  end subroutine
  integer(int64) function radiation_work_record_call_count_get(index) result(count)
    integer(int32), intent(in) :: index
    count = 0_int64
    if (index >= 0 .and. index < 3) count = native_call_counts(index + 1)
  end function
end module forecast_radiation_work_record
