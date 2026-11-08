!> Source-ordered transient tendency addresses from native named targets.
module physics_context_tendency_helpers_mod
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_loc
  use yoecldp, only: tecldp
  use physics_context_child_helpers_mod, only: physics_context_record_targets, physics_context_array_targets
  use physics_context_helper_counters_mod, only: increment_context_helper_count
  implicit none
  private
  public :: physics_driver_tendency_table
  integer(int32), save, target, protected :: source_first_column = 1_int32
contains
  !> Select GPMKTEND(mode0) or CPQTUV(other mode) argument targets.
  !! ACTIVE is the selected row count. T1_COMPONENTS and PH9_COMPONENTS
  !! each have exactly3 readonly int32 values ordered MU,MV,MT from the
  !! actual motion metadata. CLOUD and LNODRYFLX are the actual readonly
  !! source parameters, kept explicit because their producers are separate.
  !! Array ranks retain(cell,level,component,block). TABLE has18 addresses,
  !! is metadata only, and owns no payload. Mode0 writes words1:14 and
  !! preserves words15:18. Every other mode writes all18 words.
  !! The saved readonly first-column target has program lifetime.
  !! No field value, incoming record or source selector is changed.
  integer(int32) function physics_driver_tendency_table(records, array_targets, block, active, mode, &
                                                        t1_components, ph9_components, cloud, lnodryflx, table) result(status)
    type(physics_context_record_targets), intent(in) :: records
    type(physics_context_array_targets), intent(in) :: array_targets
    integer(int32), intent(in) :: block, mode, t1_components(:), ph9_components(:)
    integer(int32), target, intent(in) :: active
    type(tecldp), target, intent(in) :: cloud
    logical, target, intent(in) :: lnodryflx
    type(c_ptr), intent(inout) :: table(:)
    integer :: j, rows, levels
    type(c_ptr) :: arguments(18)
    status = 2
    if (size(table) /= 18 .or. size(t1_components) /= 3 .or. size(ph9_components) /= 3) return
    if (.not. associated(records%geometry) .or. .not. associated(records%model)) return
    if (.not. associated(array_targets%pgmvt1) .or. .not. associated(array_targets%pgmv)) return
    if (.not. associated(array_targets%gflt1) .or. .not. associated(array_targets%gfl)) return
    if (.not. associated(array_targets%zgfl_dyn) .or. .not. associated(array_targets%convectivity)) return
    rows = records%geometry%dimensions%nproma; levels = records%geometry%dimensions%nflevg
    if (block < 1 .or. block > records%geometry%partition%ngpblks) return
    if (rows < 0 .or. levels < 0 .or. active < 0 .or. active > rows) return
    if (size(array_targets%pgmvt1, 1) /= rows .or. size(array_targets%pgmvt1, 2) /= levels) return
    if (size(array_targets%pgmv, 1) /= rows .or. size(array_targets%pgmv, 2) /= levels) return
    if (size(array_targets%pgmvt1, 4) < block .or. size(array_targets%pgmv, 4) < block) return
    if (size(array_targets%gflt1, 4) < block .or. size(array_targets%gfl, 4) < block) return
    if (size(array_targets%zgfl_dyn, 4) < block .or. size(array_targets%convectivity, 3) < block) return
    do j = 1, 3
      if (t1_components(j) < 1 .or. t1_components(j) > size(array_targets%pgmvt1, 3)) return
      if (ph9_components(j) < 1 .or. ph9_components(j) > size(array_targets%pgmv, 3)) return
    end do
    call increment_context_helper_count(3, 4)
    if (mode == 0) then
      arguments(1) = c_loc(records%geometry)
      arguments(2) = c_loc(records%model%fields)
      arguments(3) = c_loc(source_first_column)
      arguments(4) = c_loc(active)
      arguments(5) = c_loc(records%model%physics_auxiliary%tsphy)
      arguments(6) = c_loc(array_targets%pgmvt1(:, :, t1_components(1), block))
      arguments(7) = c_loc(array_targets%pgmvt1(:, :, t1_components(2), block))
      arguments(8) = c_loc(array_targets%pgmvt1(:, :, t1_components(3), block))
      arguments(9) = c_loc(array_targets%gflt1(:, :, :, block))
      arguments(10) = c_loc(array_targets%pgmv(:, :, ph9_components(1), block))
      arguments(11) = c_loc(array_targets%pgmv(:, :, ph9_components(2), block))
      arguments(12) = c_loc(array_targets%pgmv(:, :, ph9_components(3), block))
      arguments(13) = c_loc(array_targets%gfl(:, :, :, block))
      arguments(14) = c_loc(array_targets%zgfl_dyn(:, :, :, block))
      table(1:14) = arguments(1:14)
    else
      arguments(1) = c_loc(cloud)
      arguments(2) = c_loc(records%model%fields)
      arguments(3) = c_loc(records%geometry%dimensions%nproma)
      arguments(4) = c_loc(source_first_column)
      arguments(5) = c_loc(active)
      arguments(6) = c_loc(records%geometry%dimensions%nflevg)
      arguments(7) = c_loc(records%model%physics_auxiliary%tsphy)
      arguments(8) = c_loc(lnodryflx)
      arguments(9) = c_loc(array_targets%pgmv(:, :, ph9_components(1), block))
      arguments(10) = c_loc(array_targets%pgmv(:, :, ph9_components(2), block))
      arguments(11) = c_loc(array_targets%pgmv(:, :, ph9_components(3), block))
      arguments(12) = c_loc(array_targets%gfl(:, :, :, block))
      arguments(13) = c_loc(array_targets%zgfl_dyn(:, :, :, block))
      arguments(14) = c_loc(array_targets%convectivity(:, :, block))
      arguments(15) = c_loc(array_targets%pgmvt1(:, :, t1_components(1), block))
      arguments(16) = c_loc(array_targets%pgmvt1(:, :, t1_components(2), block))
      arguments(17) = c_loc(array_targets%pgmvt1(:, :, t1_components(3), block))
      arguments(18) = c_loc(array_targets%gflt1(:, :, :, block))
      table = arguments
    end if
    status = 0
  end function physics_driver_tendency_table
end module physics_context_tendency_helpers_mod
