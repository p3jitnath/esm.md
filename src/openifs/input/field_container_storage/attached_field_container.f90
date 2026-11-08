!> Own the selected FIELD_CONTAINER_GP metadata and attached-storage maps.
!! Arrays are one-based. The caller keeps all borrowed records at stable addresses.
!! Numerical field payloads remain with their existing motion, GFL and surface owners.
module forecast_attached_field_container
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_int, c_ptr, c_f_pointer
  use forecast_grid_motion_types, only: native_grid_motion_state
  use grid_field_configuration_types_port, only: grid_field_configuration
  use surface_field_configuration_port, only: surface_field_registry
  use forecast_main_field_metadata
  use forecast_live_field_maps
  use forecast_field_membership
  implicit none
  private
  public :: native_field_index_base, native_attached_field_index, native_attached_field_container
  public :: attached_field_container_is_empty, create_attached_field_container, create_runtime_attached_field_container
  public :: release_attached_field_container
  type :: native_field_index_base
    integer(int32) :: l_on = 0, l_active = 0
  end type
  type :: native_attached_field_index
    integer(int32) :: l_on = 0, l_active = 0, istart = -1, iend = -1, l_hders = 0
    type(native_attached_field_index), pointer :: dm => null(), dl => null()
  end type
  type :: native_attached_field_container
    logical :: lcreated = .false.
    integer(int32) :: mstortype = 0, m_attach = 0, nfields = 0, nfields_on = 0
    integer(int32) :: nleveltypes = 0, ndim3types = 0, npoints = 0, ilen_storage1d = 0
    integer(int32) :: nhders = 0, nblocks = 0, l_attach_gfl_nproma_fixed = 0, lhders = 0
    type(native_main_field_metadata), allocatable :: metadata(:)
    integer(int32), allocatable :: nlevels(:), ndim3s(:), npoints_block(:), mall_fields(:), index_last_block(:)
    character(3), allocatable :: clevtype(:)
    type(native_field_index_base), allocatable :: field_index(:)
    type(native_attached_field_index), allocatable :: index_gp(:)
    real(real64), allocatable :: storage_last_block(:, :, :), unassigned_gfl(:, :, :)
    integer(int32), allocatable :: mt9_map(:)
    integer(int32), allocatable :: mt1_map(:)
    integer(int32), allocatable :: mt0_map(:)
    integer(int32), allocatable :: mpc_map(:)
    integer(int32), allocatable :: mpt_map(:)
    integer(int32), allocatable :: mt0_dl_map(:)
    integer(int32), allocatable :: mt0_dm_map(:)
    integer(int32), allocatable :: mt9_dl_map(:)
    integer(int32), allocatable :: mt9_dm_map(:)
    integer(int32), allocatable :: mt0_size(:)
    type(native_grid_motion_state), pointer :: motion => null()
    type(grid_field_configuration), pointer :: configuration => null()
    type(surface_field_registry), pointer :: surface => null()
  end type
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  logical function attached_field_container_is_empty(state) result(empty)
    type(native_attached_field_container), intent(in) :: state
    empty = .false.
    if (state%lcreated) return
    if (allocated(state%storage_last_block)) return
    if (allocated(state%index_last_block)) return
    if (allocated(state%unassigned_gfl)) return
    if (allocated(state%index_gp)) return
    if (allocated(state%mall_fields)) return
    if (allocated(state%nlevels)) return
    if (allocated(state%metadata)) return
    if (allocated(state%npoints_block)) return
    if (allocated(state%field_index)) return
    if (allocated(state%clevtype)) return
    if (allocated(state%ndim3s)) return
    if (allocated(state%mt0_map)) return
    if (allocated(state%mt0_size)) return
    if (allocated(state%mt9_map)) return
    if (allocated(state%mt1_map)) return
    if (allocated(state%mpc_map)) return
    if (allocated(state%mpt_map)) return
    if (allocated(state%mt0_dl_map)) return
    if (allocated(state%mt0_dm_map)) return
    if (allocated(state%mt9_dl_map)) return
    if (allocated(state%mt9_dm_map)) return
    empty = .true.
  end function
  !> Preserve the original selected bounds: points1:4096 and block width1:64.
 integer(int32) function create_attached_field_container(state,motion,configuration,grid_configuration,surface,attributes,levels,controls)result(status)
    type(native_attached_field_container), intent(inout) :: state
    type(native_grid_motion_state), target, intent(in) :: motion
    type(grid_field_configuration), target, intent(in) :: configuration
    type(grid_field_configuration), pointer, intent(in) :: grid_configuration
    type(surface_field_registry), target, intent(in) :: surface
    real(real64), intent(in) :: attributes(4)
    integer(int32), intent(in) :: levels(11), controls(8)
    status = 2
    if (controls(1) < 1 .or. controls(1) > 4096) return
    status = create_container(state, motion, configuration, grid_configuration, surface, attributes, levels, controls)
  end function
  !> Extend only the point-count admission to the actual live int32 local grid.
 !! This extra native route has the same source order and remains separately unqualified.
 integer(int32) function create_runtime_attached_field_container(state,motion,configuration,grid_configuration,surface,attributes,levels,controls)result(status)
    type(native_attached_field_container), intent(inout) :: state
    type(native_grid_motion_state), target, intent(in) :: motion
    type(grid_field_configuration), target, intent(in) :: configuration
    type(grid_field_configuration), pointer, intent(in) :: grid_configuration
    type(surface_field_registry), target, intent(in) :: surface
    real(real64), intent(in) :: attributes(4)
    integer(int32), intent(in) :: levels(11), controls(8)
    status = create_container(state, motion, configuration, grid_configuration, surface, attributes, levels, controls)
  end function
 integer(int32) function create_container(state,motion,configuration,grid_configuration,surface,attributes,levels,controls)result(status)
    type(native_attached_field_container), intent(inout) :: state
    type(native_grid_motion_state), target, intent(in) :: motion
    type(grid_field_configuration), target, intent(in) :: configuration
    type(grid_field_configuration), pointer, intent(in) :: grid_configuration
    type(surface_field_registry), target, intent(in) :: surface
    real(real64), intent(in) :: attributes(4)
    integer(int32), intent(in) :: levels(11), controls(8)
    type(native_live_field_maps), allocatable :: temporary_maps
    integer(int32), allocatable :: temporary_on(:), temporary_active(:)
    integer(c_int), pointer, volatile :: error
    integer(c_int) :: saved_errno
    integer(int32) :: dimensions(2), ignored
    integer :: allocation_status, i, rank_two_count, number, selected_map
    status = 2
    if (.not. attached_field_container_is_empty(state)) return
    if (controls(1) < 1 .or. controls(2) < 1 .or. controls(2) > 64) return
    if (controls(3) < 1 .or. controls(3) > 3) return
    if (controls(4) < 0 .or. controls(4) > 1) return
    if (any(controls(5:6) < 0) .or. any(controls(5:6) > 4200)) return
    if (controls(8) /= 0) return
    if (any(levels < 0) .or. any(levels > 256) .or. levels(1) == 0) return
    if(configuration%alias_controls%nghg/=0.or.configuration%alias_controls%nchem/=0.or.configuration%alias_controls%naero/=0)return
    if (.not. associated(grid_configuration)) return
    if (.not. associated(grid_configuration, configuration)) return
    call c_f_pointer(errno_address(), error)
    saved_errno = error
    state%lcreated = .true.; state%mstortype = 3; state%m_attach = controls(3)
    state%nfields = 4200; state%nleveltypes = 11; state%ndim3types = 2; state%npoints = controls(1)
    status = 1
    allocate (state%metadata(4200), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    ignored = initialize_main_field_metadata(state%metadata, attributes, dimensions, 0_int32)
    if (ignored /= 0) goto 800
    allocate (state%nlevels(11), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    state%nlevels = levels
    allocate (state%clevtype(11), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    state%clevtype = [character(3) :: 'ML ', 'ML ', 'SFC', 'SFC', 'SFC', 'SFC', 'SFC', 'SFC', 'SFC', 'SFC', 'SFC']
    allocate (state%field_index(4200), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    state%field_index%l_on = 0; state%field_index%l_active = 0
    allocate (state%ndim3s(2), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    state%ndim3s = 0
    if (controls(3) == 2) state%ndim3s = controls(5:6)
    state%nblocks = (controls(1) - 1)/controls(2) + 1
    allocate (state%npoints_block(state%nblocks), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    state%npoints_block = controls(2)
    if (mod(controls(1), state%nblocks) /= 0) then
      state%npoints_block(state%nblocks) = min(controls(1) - (state%nblocks - 1)*controls(2), controls(2))
    end if
    allocate (state%index_gp(4200), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    do i = 1, 4200
      state%index_gp(i)%l_on = 0; state%index_gp(i)%l_active = 0
      state%index_gp(i)%istart = -1; state%index_gp(i)%iend = -1
      state%index_gp(i)%l_hders = 0
      nullify (state%index_gp(i)%dl)
    end do
    state%motion => motion; state%configuration => grid_configuration; state%surface => surface
    state%nhders = 0; state%lhders = controls(4); state%l_attach_gfl_nproma_fixed = 1
    allocate (state%mt0_map(4200), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    allocate (state%mt0_size(4200), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    allocate (state%mt9_map(4200), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    allocate (state%mt1_map(4200), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    allocate (state%mpc_map(4200), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    allocate (state%mpt_map(4200), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    allocate (state%mt0_dl_map(4200), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    allocate (state%mt0_dm_map(4200), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    allocate (state%mt9_dl_map(4200), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    allocate (state%mt9_dm_map(4200), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    allocate (temporary_maps, stat=allocation_status)
    if (allocation_status /= 0) goto 800
    ignored = initialize_live_field_maps(temporary_maps, motion, configuration, surface, controls(7))
    if (ignored /= 0) goto 800
    state%mt9_map = temporary_maps%mt9_map
    state%mt1_map = temporary_maps%mt1_map
    state%mt0_map = temporary_maps%mt0_map
    state%mpc_map = temporary_maps%mpc_map
    state%mpt_map = temporary_maps%mpt_map
    state%mt0_dl_map = temporary_maps%mt0_dl_map
    state%mt0_dm_map = temporary_maps%mt0_dm_map
    state%mt9_dl_map = temporary_maps%mt9_dl_map
    state%mt9_dm_map = temporary_maps%mt9_dm_map
    state%mt0_size = temporary_maps%mt0_size
    allocate (temporary_on(4200), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    allocate (temporary_active(4200), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    temporary_on = 0; temporary_active = 0
    select case (controls(3))
    case (1); number = count(state%mt9_map /= 0)
    case (2); number = count(state%mt0_map /= 0)
    case (3); number = count(state%mt1_map /= 0)
    end select
    state%nfields_on = number
    allocate (state%mall_fields(number), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    select case (controls(3))
    case (1); ignored=initialize_field_membership(state%mt9_map,4200_int32,temporary_on,temporary_active,state%mall_fields,state%nfields_on)
    case (2); ignored=initialize_field_membership(state%mt0_map,4200_int32,temporary_on,temporary_active,state%mall_fields,state%nfields_on)
    case (3); ignored=initialize_field_membership(state%mt1_map,4200_int32,temporary_on,temporary_active,state%mall_fields,state%nfields_on)
    end select
    if (ignored /= 0) goto 800
    do i = 1, 4200
      state%field_index(i)%l_on = temporary_on(i); state%field_index(i)%l_active = temporary_active(i)
      if (controls(4) /= 0) then
        state%index_gp(i)%l_hders = temporary_on(i)
      else
        state%index_gp(i)%l_hders = 0
      end if
    end do
    rank_two_count = 0
    do i = 1, 4200
      if (state%metadata(i)%ndims == 2 .and. state%field_index(i)%l_on /= 0) rank_two_count = rank_two_count + 1
    end do
    allocate (state%storage_last_block(state%npoints_block(state%nblocks), levels(1), rank_two_count), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    allocate (state%index_last_block(4200), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    number = 1
    do i = 1, 4200
      state%index_last_block(i) = -1
      if (state%metadata(i)%ndims == 2 .and. state%field_index(i)%l_on /= 0) then
        state%index_last_block(i) = number
        number = number + 1
      end if
    end do
    allocate (state%unassigned_gfl(controls(2), levels(1), 1), stat=allocation_status)
    if (allocation_status /= 0) goto 800
    state%unassigned_gfl = transfer(int(z'FFEFFFFFFFFFFFFF', int64), 0.0_real64)
    status = 0
    goto 900
800 call free_container_owners(state)
900 if (allocated(temporary_maps)) deallocate (temporary_maps)
    if (allocated(temporary_on)) deallocate (temporary_on)
    if (allocated(temporary_active)) deallocate (temporary_active)
    error = saved_errno
  end function
  subroutine free_container_owners(state)
    type(native_attached_field_container), intent(inout) :: state
    if (allocated(state%storage_last_block)) deallocate (state%storage_last_block)
    if (allocated(state%index_last_block)) deallocate (state%index_last_block)
    if (allocated(state%unassigned_gfl)) deallocate (state%unassigned_gfl)
    if (allocated(state%index_gp)) deallocate (state%index_gp)
    if (allocated(state%mall_fields)) deallocate (state%mall_fields)
    if (allocated(state%nlevels)) deallocate (state%nlevels)
    if (allocated(state%metadata)) deallocate (state%metadata)
    if (allocated(state%npoints_block)) deallocate (state%npoints_block)
    if (allocated(state%field_index)) deallocate (state%field_index)
    if (allocated(state%clevtype)) deallocate (state%clevtype)
    if (allocated(state%ndim3s)) deallocate (state%ndim3s)
    if (allocated(state%mt0_map)) deallocate (state%mt0_map)
    if (allocated(state%mt0_size)) deallocate (state%mt0_size)
    if (allocated(state%mt9_map)) deallocate (state%mt9_map)
    if (allocated(state%mt1_map)) deallocate (state%mt1_map)
    if (allocated(state%mpc_map)) deallocate (state%mpc_map)
    if (allocated(state%mpt_map)) deallocate (state%mpt_map)
    if (allocated(state%mt0_dl_map)) deallocate (state%mt0_dl_map)
    if (allocated(state%mt0_dm_map)) deallocate (state%mt0_dm_map)
    if (allocated(state%mt9_dl_map)) deallocate (state%mt9_dl_map)
    if (allocated(state%mt9_dm_map)) deallocate (state%mt9_dm_map)
    state%lcreated = .false.
  end subroutine
  integer(int32) function release_attached_field_container(state) result(status)
    type(native_attached_field_container), intent(inout) :: state
    integer(c_int), pointer, volatile :: error
    integer(c_int) :: saved_errno
    integer :: i, j, k
    status = 0
    if (.not. state%lcreated) return
    status = 2
    if (.not. allocated(state%unassigned_gfl)) return
    do k = 1, size(state%unassigned_gfl, 3)
    do j = 1, size(state%unassigned_gfl, 2)
    do i = 1, size(state%unassigned_gfl, 1)
      if (transfer(state%unassigned_gfl(i, j, k), 0_int64) /= int(z'FFEFFFFFFFFFFFFF', int64)) then
        status = 3; return
      end if
    end do
    end do
    end do
    call c_f_pointer(errno_address(), error)
    saved_errno = error
    call free_container_owners(state)
    error = saved_errno
    status = 0
  end function
end module
