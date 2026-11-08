!> Native auxiliary work-record storage, views and source-ordered release.
#include "work_record_storage_support.inc.f90"
module forecast_auxiliary_work_record
  use iso_fortran_env, only: int32, int64
  use forecast_physics_work_types, only: aux_type
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_native_field_variable_types, only: native_field_variables
  use forecast_physics_field_views, only: physics_field_view_2d, physics_field_view_3d, physics_field_view_4d
  use forecast_integer_logical_work_fields, only: integer_work_field_view_2d
  use physics_work_record_support_mod
  implicit none
  private
  public :: initialize_auxiliary_work_record, update_auxiliary_work_views, finalize_auxiliary_work_record
  public :: aux_type_init, aux_type_update_view, aux_type_final, auxiliary_work_record_call_count_get
  integer(int64), save :: native_call_counts(3) = 0_int64
contains
  !> Allocate source-owned fields while borrowing the existing canonical fields.
  !! STATE is the unique mutable AUX_TYPE; GEOMETRY and VARIABLES stay readonly.
  !! Counts are dimensionless; field values keep their original physical units.
  !! PERSISTENT defaults false: one thread buffer, otherwise actual grid blocks.
  !! New values are undefined. Incoming public views and all source-unwritten
  !! members remain unchanged. Status0 succeeds,1 releases a failed prefix,
  !! and2 refuses unsupported native metadata before ownership mutation.
  integer(int32) function initialize_auxiliary_work_record(state, geometry, variables, levels, persistent) result(status)
    type(aux_type), intent(inout) :: state
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
    if (levels == huge(0_int32)) return
    if (associated(state%f_pmu0)) return
    if (associated(state%f_pmu0m)) return
    if (associated(state%f_pmu0t)) return
    if (associated(state%f_paphi)) return
    if (associated(state%f_paprs)) return
    if (associated(state%f_pgeomh)) return
    if (associated(state%f_prs1)) return
    if (associated(state%f_paphif)) return
    if (associated(state%f_paprsf)) return
    if (associated(state%f_pgeom1)) return
    if (associated(state%f_prsf1)) return
    keep = .false.
    if (present(persistent)) keep = persistent
    if (.not. keep) blocks = 1
    call capture_work_record_status(snapshot)
    nullify (state%f_pmu0)
    nullify (state%f_pmu0m)
    nullify (state%f_pmu0t)
    nullify (state%f_paphi)
    nullify (state%f_paprs)
    nullify (state%f_pgeomh)
    nullify (state%f_prs1)
    nullify (state%f_paphif)
    nullify (state%f_paprsf)
    nullify (state%f_pgeom1)
    nullify (state%f_prsf1)
    state%f_pgelam => variables%geometry%gelam%ft0
    state%f_pgelat => variables%geometry%gelat%ft0
    state%f_pgaw => variables%geometry%gaw%ft0
    state%f_pclon => variables%geometry%geclo%ft0
    state%f_pslon => variables%geometry%geslo%ft0
    state%f_pgemu => variables%geometry%gemu%ft0
    state%f_porog => variables%geometry%orog%ft0
    state%f_pgnordl => variables%geometry%gnordl%ft0
    state%f_pgnordm => variables%geometry%gnordm%ft0
    state%f_pgsqm2 => variables%geometry%gsqm2%ft0
    status = create_work_field(state%f_pmu0, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pmu0m, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pmu0t, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_paphi, [rows, levels + 1_int32, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_paprs, [rows, levels + 1_int32, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pgeomh, [rows, levels + 1_int32, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_prs1, [rows, levels + 1_int32, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_paphif, [rows, levels, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_paprsf, [rows, levels, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pgeom1, [rows, levels, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_prsf1, [rows, levels, blocks],.not. keep)
    if (status /= 0) goto 900
    call restore_work_record_status(snapshot)
    status = 0
    return
900 cleanup_status = finalize_auxiliary_work_record(state)
    call restore_work_record_status(snapshot)
    status = 1
  end function initialize_auxiliary_work_record
  !> Associate source-ordered block views; never read or write a field value.
  !! BLOCK is one-origin. Every required field remains live. Optional absent
  !! group fields retain their incoming view. Native strides and bounds stay.
  integer(int32) function update_auxiliary_work_views(state, block) result(status)
    type(aux_type), intent(inout) :: state
    integer(int32), intent(in) :: block
    type(work_record_status_snapshot) :: snapshot
    call capture_work_record_status(snapshot)
    status = 0
    status = physics_field_view_2d(state%pgelam, state%f_pgelam, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pgelat, state%f_pgelat, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pgaw, state%f_pgaw, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pclon, state%f_pclon, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pslon, state%f_pslon, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pgemu, state%f_pgemu, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%porog, state%f_porog, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pgnordl, state%f_pgnordl, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pgnordm, state%f_pgnordm, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pgsqm2, state%f_pgsqm2, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pmu0, state%f_pmu0, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pmu0m, state%f_pmu0m, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pmu0t, state%f_pmu0t, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%paphi, state%f_paphi, block)
    if (status /= 0) goto 900
    state%paphi(1:, 0:) => state%paphi
    status = physics_field_view_3d(state%paprs, state%f_paprs, block)
    if (status /= 0) goto 900
    state%paprs(1:, 0:) => state%paprs
    status = physics_field_view_3d(state%pgeomh, state%f_pgeomh, block)
    if (status /= 0) goto 900
    state%pgeomh(1:, 0:) => state%pgeomh
    status = physics_field_view_3d(state%prs1, state%f_prs1, block)
    if (status /= 0) goto 900
    state%prs1(1:, 0:) => state%prs1
    status = physics_field_view_3d(state%paphif, state%f_paphif, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%paprsf, state%f_paprsf, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%pgeom1, state%f_pgeom1, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%prsf1, state%f_prsf1, block)
    if (status /= 0) goto 900
900 call restore_work_record_status(snapshot)
  end function update_auxiliary_work_views
  !> Free only source-owned payloads and metadata, including a partial prefix.
  !! Borrowed fields, public array views and all other members remain unchanged.
  integer(int32) function finalize_auxiliary_work_record(state) result(status)
    type(aux_type), intent(inout) :: state
    type(work_record_status_snapshot) :: snapshot
    call capture_work_record_status(snapshot)
    call delete_work_field(state%f_pmu0)
    call delete_work_field(state%f_pmu0m)
    call delete_work_field(state%f_pmu0t)
    call delete_work_field(state%f_paphi)
    call delete_work_field(state%f_paprs)
    call delete_work_field(state%f_pgeomh)
    call delete_work_field(state%f_prs1)
    call delete_work_field(state%f_paphif)
    call delete_work_field(state%f_paprsf)
    call delete_work_field(state%f_pgeom1)
    call delete_work_field(state%f_prsf1)
    call restore_work_record_status(snapshot)
    status = 0
  end function finalize_auxiliary_work_record
  !> Retain the original method's counter and nonreturning failure boundary.
  subroutine aux_type_init(state, geometry, variables, levels, persistent)
    type(aux_type), intent(inout) :: state
    type(native_geometry_state), intent(in) :: geometry
    type(native_field_variables), intent(in) :: variables
    integer(int32), intent(in) :: levels
    logical, optional, intent(in) :: persistent
    integer(int32) :: status
    call increment_work_word(native_call_counts(1))
    status = initialize_auxiliary_work_record(state, geometry, variables, levels, persistent)
    if (status /= 0) call abort_storage_failure()
  end subroutine
  subroutine aux_type_update_view(state, block)
    type(aux_type), intent(inout) :: state
    integer(int32), intent(in) :: block
    integer(int32) :: status
    call increment_work_word(native_call_counts(2))
    status = update_auxiliary_work_views(state, block)
    if (status /= 0) call abort_storage_failure()
  end subroutine
  subroutine aux_type_final(state)
    type(aux_type), intent(inout) :: state
    integer(int32) :: status
    call increment_work_word(native_call_counts(3))
    status = finalize_auxiliary_work_record(state)
  end subroutine
  integer(int64) function auxiliary_work_record_call_count_get(index) result(count)
    integer(int32), intent(in) :: index
    count = 0_int64
    if (index >= 0 .and. index < 3) count = native_call_counts(index + 1)
  end function
end module forecast_auxiliary_work_record
