!> Read the live operational NAMDYNA controls and publish native source fields.
module forecast_operational_dynamics
  use iso_c_binding, only: c_int
  use forecast_dynamics_control_defaults, only: native_dynamics_controls, native_dynamics_upstream, &
                                                initialize_selected_dynamics_defaults
  use physics_configuration_text_port, only: find_physics_group, skip_physics_space, physics_space, &
                                             physics_key_character, physics_fold_equal, parse_physics_boolean
  implicit none
  private
  public :: native_dynamics_controls, native_dynamics_upstream, initialize_operational_dynamics_controls
contains
!> Initialize named SUDYNA controls without allocating a numerical field.
!! TEXT is read-only bounded ASCII. UPSTREAM has8 named INT32 source controls.
!! STATE is a caller-owned native record with INOUT intent. Source logicals
!! are native LOGICAL, numeric fields INT32/FP64 and all map entries INT32.
!! Counts and map entries are dimensionless. Pressure thresholds are in Pa.
!! The caller establishes ECMWF global hydrostatic mode, finite elements,
!! disabled plane/2D/single-column modes and print level zero. It establishes
!! nearest-even rounding with gradual underflow; no FP probe is introduced.
!! Runtime horizontal bounds follow the existing qualified source branch.
!! Status0 publishes all source fields; status2 leaves STATE unchanged.
!! Padding remains at its incoming value. No original object or method is used.
  integer(c_int) function initialize_operational_dynamics_controls(text, upstream, state) result(status)
    character(len=*), intent(in) :: text
    type(native_dynamics_upstream), intent(in) :: upstream
    type(native_dynamics_controls), intent(inout) :: state
    logical :: values(4), valid
    integer :: cursor, key_start, key_end, value_start, value_end, slot, ignored
    status = 2_c_int
    if (len(text) < 1 .or. len(text) > 262144) return
    if (upstream%ndlon < 1 .or. upstream%ndlon > 32768) return
    if (upstream%ndglg < 2 .or. upstream%ndglg > 8192) return
    if (upstream%nsmax < 1 .or. upstream%nsmax > 4096) return
    if (upstream%nmsmax /= upstream%nsmax) return
    if (upstream%lvertfe /= 1 .or. upstream%ndlnpr /= 0 .or. upstream%lnonhyd_geom /= 0 .or. upstream%nconf /= 1) return
    values = [.true., .false., .false., .true.]
    cursor = find_physics_group(text, 'NAMDYNA', .false.)
    if (cursor == 0) return
    do
      call skip_physics_space(text, cursor)
      if (cursor > len(text)) return
      if (text(cursor:cursor) == ',') then
        cursor = cursor + 1
        cycle
      end if
      if (text(cursor:cursor) == '/') exit
      key_start = cursor
      do while (cursor <= len(text))
        if (.not. physics_key_character(text(cursor:cursor), .true.)) exit
        cursor = cursor + 1
      end do
      key_end = cursor - 1
      if (key_end < key_start) return
      slot = 0
      if (physics_fold_equal(text(key_start:key_end), 'LSLAG')) slot = 1
      if (physics_fold_equal(text(key_start:key_end), 'LNHEE')) slot = 2
      if (physics_fold_equal(text(key_start:key_end), 'LNHQE')) slot = 3
      if (physics_fold_equal(text(key_start:key_end), 'LGRADSP')) slot = 4
      if (slot == 0) return
      call skip_physics_space(text, cursor)
      if (cursor > len(text)) return
      if (text(cursor:cursor) /= '=') return
      cursor = cursor + 1
      call skip_physics_space(text, cursor)
      if (cursor > len(text)) return
      value_start = cursor
      do while (cursor <= len(text))
        if (physics_space(text(cursor:cursor))) exit
        if (index(',!/', text(cursor:cursor)) /= 0) exit
        cursor = cursor + 1
      end do
      if (cursor > len(text)) return
      value_end = cursor - 1
      if (value_end < value_start) return
      ! The retained bounded reader requires full TRUE/FALSE names, optionally
      ! dotted. Its shorter T/F forms are outside this source's admitted syntax.
      valid = physics_fold_equal(text(value_start:value_end), 'TRUE') .or. &
              physics_fold_equal(text(value_start:value_end), 'FALSE') .or. &
              physics_fold_equal(text(value_start:value_end), '.TRUE.') .or. &
              physics_fold_equal(text(value_start:value_end), '.FALSE.')
      if (.not. valid) return
      call parse_physics_boolean(text(value_start:value_end), values(slot), valid)
      if (.not. valid) return
    end do
    if (.not. values(1) .or. values(2) .or. values(3)) return
    ignored = initialize_selected_dynamics_defaults(state)
    state%lslag = values(1)
    state%lnhee = values(2)
    state%lnhqe = values(3)
    state%lgradsp = values(4)
    status = 0_c_int
  end function
end module forecast_operational_dynamics
