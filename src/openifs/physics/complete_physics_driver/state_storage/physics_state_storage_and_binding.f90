! (C) Copyright 1989- ECMWF.
! This software is licensed under the terms of the Apache Licence Version 2.0
! which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
! In applying this licence, ECMWF does not waive the privileges and immunities
! granted to it by virtue of its status as an intergovernmental organisation
! nor does it submit to any jurisdiction.
!
!> Source-owned physics state fields and block views on one native registry.
!! STATE_TYPE comes from forecast_physics_work_types. Its numerical arrays
!! borrow the actual registry targets; only source-selected temporary fields
!! and the five-plane cloud field are created here. Counts have no unit.
!! Array values retain their physical units. New numerical payloads remain
!! uninitialised until a physical producer writes them.
module forecast_native_physics_state_storage
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_int, c_ptr, c_f_pointer, c_size_t
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use forecast_physics_work_types, only: STATE_TYPE, MASK_GFL_TYPE
  use forecast_registry_field_types, only: native_registry_field_3d, native_registry_field_4d
  use forecast_registry_storage, only: allocate_registry_field_3d, allocate_registry_field_4d, valid_registry_allocation_shape
  use forecast_physics_field_views, only: physics_field_view_3d, physics_field_view_4d
  implicit none
  private
  public :: initialize_physics_state, finalize_physics_state, update_physics_state, bind_physics_state_block
  public :: initialize_physics_state_native, finalize_physics_state_native
  public :: copy_physics_field_mask, initialize_mask_gfl_type, physics_state_call_count
  public :: state_type_init, state_type_final, mask_gfl_type_init
  integer(int64), save :: native_calls(0:2) = 0_int64, block_view_calls = 0_int64
  interface state_type_final
    module procedure finalize_physics_state_native
  end interface
  interface mask_gfl_type_init
    module procedure initialize_mask_gfl_type
  end interface
  interface
    subroutine source_state_exit(code) bind(C, name='_exit')
      import c_int
      integer(c_int), value :: code
    end subroutine
    function state_errno_address() bind(C, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Create source-selected temporary fields without initialising their values.
  !! NPROMA is the allocated column width, LEVELS the live layer count, and
  !! BLOCKS the persistent block count. PERSISTENT=false selects one local
  !! buffer, matching the qualified one-thread source route. Optional field
  !! pointers preserve presence separately from association; a present null
  !! field remains null. Caller retains every supplied field through FINAL.
  !! KEYMASK is copied by value, preserving an exact incoming STATE mask alias.
  !! Status0 succeeds,1 reports allocation failure after source-order cleanup,
  !! and2 refuses invalid metadata before state mutation. FP status and errno
  !! are preserved. Incoming array views and source-unwritten fields survive.
  integer(int32) function initialize_physics_state(state,nproma,levels,blocks,keymask,persistent,u,v,t,o3,q,a,ql,qi,qr,qs,tke)result(status)
    type(STATE_TYPE), intent(inout) :: state
    integer(int32), intent(in) :: nproma, levels, blocks
    type(MASK_GFL_TYPE), intent(in), value :: keymask
    logical, intent(in) :: persistent
    type(native_registry_field_3d), pointer, optional, intent(in) :: u, v, t, o3, q, a, ql, qi, qr, qs, tke
    integer(int32) :: local_blocks, allocation_status
    integer(c_size_t) :: bytes
    integer(c_int), pointer, volatile :: errno_word
    integer(c_int) :: incoming_errno
    type(ieee_status_type) :: incoming_fp
    status = 2_int32
    if (nproma < 1 .or. levels < 0 .or. blocks < 1) return
    local_blocks = 1
    if (persistent) local_blocks = blocks
    if (.not. valid_registry_allocation_shape([nproma, levels, local_blocks], bytes)) return
    if (.not. valid_registry_allocation_shape([nproma, levels, 5_int32, local_blocks], bytes)) return
    call c_f_pointer(state_errno_address(), errno_word)
    incoming_errno = errno_word
    call ieee_get_status(incoming_fp)
    state%keymask = keymask
    nullify (state%f_u, state%f_v, state%f_t, state%f_o3, state%f_q, state%f_a)
    nullify (state%f_ql, state%f_qi, state%f_qr, state%f_qs, state%f_tke, state%f_cld)
    ! Ownership flags and slots are assigned in source field order.
    state%field_owned%u = .not. (present(u))
    if (present(u)) then
      state%f_u => u
    else
      allocate (state%f_u, stat=allocation_status)
      if (allocation_status /= 0) goto 900
      status = allocate_registry_field_3d(state%f_u, [nproma, levels, local_blocks],.not. persistent)
      if (status /= 0) goto 900
    end if
    state%field_owned%v = .not. (present(v))
    if (present(v)) then
      state%f_v => v
    else
      allocate (state%f_v, stat=allocation_status)
      if (allocation_status /= 0) goto 900
      status = allocate_registry_field_3d(state%f_v, [nproma, levels, local_blocks],.not. persistent)
      if (status /= 0) goto 900
    end if
    state%field_owned%t = .not. (present(t))
    if (present(t)) then
      state%f_t => t
    else
      allocate (state%f_t, stat=allocation_status)
      if (allocation_status /= 0) goto 900
      status = allocate_registry_field_3d(state%f_t, [nproma, levels, local_blocks],.not. persistent)
      if (status /= 0) goto 900
    end if
    state%field_owned%o3 = .not. (present(o3) .and. keymask%o3)
    if (present(o3) .and. keymask%o3) then
      state%f_o3 => o3
    else
      allocate (state%f_o3, stat=allocation_status)
      if (allocation_status /= 0) goto 900
      status = allocate_registry_field_3d(state%f_o3, [nproma, levels, local_blocks],.not. persistent)
      if (status /= 0) goto 900
    end if
    state%field_owned%q = .not. (present(q) .and. keymask%q)
    if (present(q) .and. keymask%q) then
      state%f_q => q
    else
      allocate (state%f_q, stat=allocation_status)
      if (allocation_status /= 0) goto 900
      status = allocate_registry_field_3d(state%f_q, [nproma, levels, local_blocks],.not. persistent)
      if (status /= 0) goto 900
    end if
    state%field_owned%a = .not. (present(a) .and. keymask%a)
    if (present(a) .and. keymask%a) then
      state%f_a => a
    else
      allocate (state%f_a, stat=allocation_status)
      if (allocation_status /= 0) goto 900
      status = allocate_registry_field_3d(state%f_a, [nproma, levels, local_blocks],.not. persistent)
      if (status /= 0) goto 900
    end if
    if (present(ql)) state%f_ql => ql
    if (present(qi)) state%f_qi => qi
    if (present(qr)) state%f_qr => qr
    if (present(qs)) state%f_qs => qs
    state%field_owned%tke = .not. (present(tke) .and. keymask%tke)
    if (present(tke) .and. keymask%tke) then
      state%f_tke => tke
    else
      allocate (state%f_tke, stat=allocation_status)
      if (allocation_status /= 0) goto 900
      status = allocate_registry_field_3d(state%f_tke, [nproma, levels, local_blocks],.not. persistent)
      if (status /= 0) goto 900
    end if
    allocate (state%f_cld, stat=allocation_status)
    if (allocation_status /= 0) goto 900
    status = allocate_registry_field_4d(state%f_cld, [nproma, levels, 5_int32, local_blocks],.not. persistent)
    if (status /= 0) goto 900
    status = 0_int32
    goto 910
900 continue
    call finalize_physics_state(state)
    status = 1_int32
910 continue
    errno_word = incoming_errno
    call ieee_set_status(incoming_fp)
  end function initialize_physics_state

  !> Release only the seven flagged fields and the always-owned cloud field.
  !! Borrowed fields, numerical views, masks and ownership flags remain as
  !! source-defined. Released field slots become absent. Repeated cleanup
  !! is safe for slots already released. The caller ends all views first.
  subroutine finalize_physics_state(state)
    type(STATE_TYPE), intent(inout) :: state
    integer(c_int), pointer, volatile :: errno_word
    integer(c_int) :: incoming_errno
    type(ieee_status_type) :: incoming_fp
    call c_f_pointer(state_errno_address(), errno_word)
    incoming_errno = errno_word
    call ieee_get_status(incoming_fp)
    if (state%field_owned%u) call release_state_field_3d(state%f_u)
    if (state%field_owned%v) call release_state_field_3d(state%f_v)
    if (state%field_owned%t) call release_state_field_3d(state%f_t)
    if (state%field_owned%o3) call release_state_field_3d(state%f_o3)
    if (state%field_owned%q) call release_state_field_3d(state%f_q)
    if (state%field_owned%a) call release_state_field_3d(state%f_a)
    if (state%field_owned%tke) call release_state_field_3d(state%f_tke)
    call release_state_field_4d(state%f_cld)
    errno_word = incoming_errno
    call ieee_set_status(incoming_fp)
  end subroutine finalize_physics_state

  subroutine release_state_field_3d(field)
    type(native_registry_field_3d), pointer, intent(inout) :: field
    if (.not. associated(field)) return
    if (field%owned .and. associated(field%data)) deallocate (field%data)
    deallocate (field)
    nullify (field)
  end subroutine

  subroutine release_state_field_4d(field)
    type(native_registry_field_4d), pointer, intent(inout) :: field
    if (.not. associated(field)) return
    if (field%owned .and. associated(field%data)) deallocate (field%data)
    deallocate (field)
    nullify (field)
  end subroutine

  !> Select every source view and copy four complete cloud-phase planes.
  !! BLOCK is one-based. The selected plane has native column/level order.
  !! Metadata admission precedes every state/payload store. Only associated
  !! fields change their views; unassociated fields preserve incoming views.
  !! Copying uses no FP arithmetic, preserving NaN payloads and signed zeros.
  !! The fifth cloud plane and all unrelated backing bytes remain untouched.
  integer(int32) function update_physics_state(state, block) result(status)
    type(STATE_TYPE), intent(inout) :: state
    integer(int32), intent(in) :: block
    real(real64), pointer :: probe(:, :), cloud(:, :, :)
    logical :: valid
    integer(int32) :: child_status
    status = 1_int32
    if (block < 1) return
    nullify (probe, cloud)
    if (associated(state%f_cld)) then
      call preview_field_4d(state%f_cld, block, cloud, valid)
      if (.not. valid) return
    end if
    if (associated(state%f_u)) then
      call preview_field_3d(state%f_u, block, probe, valid)
      if (.not. valid) return
    end if
    if (associated(state%f_v)) then
      call preview_field_3d(state%f_v, block, probe, valid)
      if (.not. valid) return
    end if
    if (associated(state%f_t)) then
      call preview_field_3d(state%f_t, block, probe, valid)
      if (.not. valid) return
    end if
    if (associated(state%f_o3)) then
      call preview_field_3d(state%f_o3, block, probe, valid)
      if (.not. valid) return
    end if
    if (associated(state%f_q)) then
      call preview_field_3d(state%f_q, block, probe, valid)
      if (.not. valid) return
    end if
    if (associated(state%f_a)) then
      call preview_field_3d(state%f_a, block, probe, valid)
      if (.not. valid) return
    end if
    if (associated(state%f_tke)) then
      call preview_field_3d(state%f_tke, block, probe, valid)
      if (.not. valid) return
    end if
    if (associated(state%f_ql)) then
      call preview_field_3d(state%f_ql, block, probe, valid)
      if (.not. valid) return
      if (state%keymask%ql) then
        if (.not. associated(cloud) .or. .not. associated(probe)) return
        if (size(cloud, 1) /= size(probe, 1) .or. size(cloud, 2) /= size(probe, 2) .or. size(cloud, 3) < 4) return
      end if
    end if
    if (associated(state%f_qi)) then
      call preview_field_3d(state%f_qi, block, probe, valid)
      if (.not. valid) return
      if (state%keymask%qi) then
        if (.not. associated(cloud) .or. .not. associated(probe)) return
        if (size(cloud, 1) /= size(probe, 1) .or. size(cloud, 2) /= size(probe, 2) .or. size(cloud, 3) < 4) return
      end if
    end if
    if (associated(state%f_qr)) then
      call preview_field_3d(state%f_qr, block, probe, valid)
      if (.not. valid) return
      if (state%keymask%qr) then
        if (.not. associated(cloud) .or. .not. associated(probe)) return
        if (size(cloud, 1) /= size(probe, 1) .or. size(cloud, 2) /= size(probe, 2) .or. size(cloud, 3) < 4) return
      end if
    end if
    if (associated(state%f_qs)) then
      call preview_field_3d(state%f_qs, block, probe, valid)
      if (.not. valid) return
      if (state%keymask%qs) then
        if (.not. associated(cloud) .or. .not. associated(probe)) return
        if (size(cloud, 1) /= size(probe, 1) .or. size(cloud, 2) /= size(probe, 2) .or. size(cloud, 3) < 4) return
      end if
    end if
    if (associated(state%f_u)) then
      child_status = physics_field_view_3d(state%u, state%f_u, block)
      if (child_status /= 0) return
    end if
    if (associated(state%f_v)) then
      child_status = physics_field_view_3d(state%v, state%f_v, block)
      if (child_status /= 0) return
    end if
    if (associated(state%f_t)) then
      child_status = physics_field_view_3d(state%t, state%f_t, block)
      if (child_status /= 0) return
    end if
    if (associated(state%f_o3)) then
      child_status = physics_field_view_3d(state%o3, state%f_o3, block)
      if (child_status /= 0) return
    end if
    if (associated(state%f_q)) then
      child_status = physics_field_view_3d(state%q, state%f_q, block)
      if (child_status /= 0) return
    end if
    if (associated(state%f_a)) then
      child_status = physics_field_view_3d(state%a, state%f_a, block)
      if (child_status /= 0) return
    end if
    if (associated(state%f_tke)) then
      child_status = physics_field_view_3d(state%tke, state%f_tke, block)
      if (child_status /= 0) return
    end if
    if (associated(state%f_cld)) then
      child_status = physics_field_view_4d(state%cld, state%f_cld, block)
      if (child_status /= 0) return
    end if
    if (associated(state%f_ql)) then
      child_status = physics_field_view_3d(state%ql, state%f_ql, block)
      if (child_status /= 0) return
      if (state%keymask%ql) state%cld(:, :, 1) = state%ql
    end if
    if (associated(state%f_qi)) then
      child_status = physics_field_view_3d(state%qi, state%f_qi, block)
      if (child_status /= 0) return
      if (state%keymask%qi) state%cld(:, :, 2) = state%qi
    end if
    if (associated(state%f_qr)) then
      child_status = physics_field_view_3d(state%qr, state%f_qr, block)
      if (child_status /= 0) return
      if (state%keymask%qr) state%cld(:, :, 3) = state%qr
    end if
    if (associated(state%f_qs)) then
      child_status = physics_field_view_3d(state%qs, state%f_qs, block)
      if (child_status /= 0) return
      if (state%keymask%qs) state%cld(:, :, 4) = state%qs
    end if
    status = 0_int32
  end function update_physics_state

  !> Bind one of the eight source-ordered physics states for a live block.
  !! STATES borrows the context's eight actual state records; it is not a copy.
  integer(int32) function bind_physics_state_block(states, state_number, block) result(status)
    type(STATE_TYPE), intent(inout) :: states(:)
    integer(int32), intent(in) :: state_number, block
    status = 1_int32
    if (state_number < 1 .or. state_number > 8 .or. state_number > size(states) .or. block < 1) return
    block_view_calls = block_view_calls + 1_int64
    status = update_physics_state(states(state_number), block)
  end function

  subroutine preview_field_3d(field, block, view, valid)
    type(native_registry_field_3d), intent(in) :: field
    integer(int32), intent(in) :: block
    real(real64), pointer, intent(out) :: view(:, :)
    logical, intent(out) :: valid
    integer :: selected
    valid = .false.
    nullify (view)
    if (.not. field%active) then
      view => field%view
      valid = .true.
      if (associated(view)) valid = is_contiguous(view)
      return
    end if
    selected = block
    if (field%thread_buffer) selected = 1
    if (field%owned) then
      if (.not. associated(field%data)) return
      if (selected < lbound(field%data, 3) .or. selected > ubound(field%data, 3)) return
      view => field%data(:, :, selected)
    else
      if (.not. associated(field%ptr)) return
      if (selected < lbound(field%ptr, 3) .or. selected > ubound(field%ptr, 3)) return
      view => field%ptr(:, :, selected)
    end if
    valid = is_contiguous(view)
  end subroutine

  subroutine preview_field_4d(field, block, view, valid)
    type(native_registry_field_4d), intent(in) :: field
    integer(int32), intent(in) :: block
    real(real64), pointer, intent(out) :: view(:, :, :)
    logical, intent(out) :: valid
    integer :: selected
    valid = .false.
    nullify (view)
    if (.not. field%active) then
      view => field%view
      valid = .true.
      if (associated(view)) valid = is_contiguous(view)
      return
    end if
    selected = block
    if (field%thread_buffer) selected = 1
    if (field%owned) then
      if (.not. associated(field%data)) return
      if (selected < lbound(field%data, 4) .or. selected > ubound(field%data, 4)) return
      view => field%data(:, :, :, selected)
    else
      if (.not. associated(field%ptr)) return
      if (selected < lbound(field%ptr, 4) .or. selected > ubound(field%ptr, 4)) return
      view => field%ptr(:, :, :, selected)
    end if
    valid = is_contiguous(view)
  end subroutine

  subroutine copy_physics_field_mask(output, input)
    type(MASK_GFL_TYPE), intent(inout) :: output
    type(MASK_GFL_TYPE), intent(in), value :: input
    output = input
  end subroutine

  subroutine initialize_mask_gfl_type(mask, o3, q, a, ql, qi, qr, qs, tke)
    type(MASK_GFL_TYPE), intent(inout) :: mask
    logical, intent(in) :: o3, q, a, ql, qi, qr, qs, tke
    mask%q = q
    mask%o3 = o3
    mask%a = a
    mask%ql = ql
    mask%qi = qi
    mask%qr = qr
    mask%qs = qs
    mask%tke = tke
    native_calls(2) = native_calls(2) + 1_int64
  end subroutine

  integer(int32) function initialize_physics_state_native(state,nproma,levels,blocks,keymask,persistent,u,v,t,o3,q,a,ql,qi,qr,qs,tke)result(status)
    type(STATE_TYPE), intent(inout) :: state
    integer(int32), intent(in) :: nproma, levels, blocks
    type(MASK_GFL_TYPE), intent(in), value :: keymask
    logical, intent(in) :: persistent
    type(native_registry_field_3d), pointer, optional, intent(in) :: u, v, t, o3, q, a, ql, qi, qr, qs, tke
    status = initialize_physics_state(state, nproma, levels, blocks, keymask, persistent, u, v, t, o3, q, a, ql, qi, qr, qs, tke)
    if (status == 0) native_calls(0) = native_calls(0) + 1_int64
  end function

  !> Preserve the original native INIT adapter's nonreturning failure branch.
  subroutine state_type_init(state, nproma, levels, blocks, keymask, persistent, u, v, t, o3, q, a, ql, qi, qr, qs, tke)
    type(STATE_TYPE), intent(inout) :: state
    integer(int32), intent(in) :: nproma, levels, blocks
    type(MASK_GFL_TYPE), intent(in), value :: keymask
    logical, intent(in) :: persistent
    type(native_registry_field_3d), pointer, optional, intent(in) :: u, v, t, o3, q, a, ql, qi, qr, qs, tke
    integer(int32) :: status
status = initialize_physics_state_native(state, nproma, levels, blocks, keymask, persistent, u, v, t, o3, q, a, ql, qi, qr, qs, tke)
    if (status /= 0_int32) call source_state_exit(116_c_int)
  end subroutine

  subroutine finalize_physics_state_native(state)
    type(STATE_TYPE), intent(inout) :: state
    call finalize_physics_state(state)
    native_calls(1) = native_calls(1) + 1_int64
  end subroutine

  integer(int64) function physics_state_call_count(index) result(value)
    integer(int32), intent(in) :: index
    value = -1_int64
    if (index >= 0 .and. index <= 2) value = native_calls(index)
    if (index == 3) value = block_view_calls
  end function
end module forecast_native_physics_state_storage
