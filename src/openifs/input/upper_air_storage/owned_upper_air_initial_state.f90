module owned_upper_air_initial_state_port
  !! Own the complete upper-air field context and load its initial file.
  !! Ports: owned_upper_air_initial_state.S and
  !! owned_operational_upper_air_initial_state.S.
  !! The numerical field owners and borrowed constituent metadata use the
  !! one native gridpoint_field_state identity; no private record is copied.
  use, intrinsic :: iso_fortran_env, only: int32, real64
  use, intrinsic :: iso_c_binding, only: c_null_char
  use md2asm_moist_air_gas_properties, only: thermal_constituent
  use gridpoint_field_storage_port, only: gridpoint_field_state, gridpoint_field_storage_mode_supported
  use gridpoint_field_context_port, only: create_gridpoint_field_context, &
                                          create_operational_gridpoint_field_context, release_gridpoint_field_context
  use upper_air_initial_loading_port, only: load_initial_upper_air_state, &
                                            load_operational_upper_air_initial_state
  implicit none
  private
  public :: create_loaded_upper_air_state, create_loaded_operational_upper_air_state
contains
  integer(int32) function create_loaded_upper_air_state(path, constituents, context) result(status)
    !! Create selected(24,19,8,86) fields and two physics fields. Before file
    !! placement, set only the copied fields'16unused rows in the last block
    !! to positive zero:4fields x19levels x16rows =9728bytes.
    !! constituents is borrowed read-only until the returned context is freed.
    !! context must be unallocated and is published only after full success.
    !! Return1 admission,16+constructor status,32+loader status,or0 success.
    character(len=*), intent(in) :: path
    type(thermal_constituent), target, intent(in) :: constituents(:)
    type(gridpoint_field_state), allocatable, intent(inout) :: context
    type(gridpoint_field_state), allocatable :: staged
    integer, parameter :: copied_fields(4) = [1, 2, 3, 6]
    integer :: family, level
    integer(int32) :: child_status, ignored
    status = 1_int32
    if (allocated(context)) return
    if (len(path) < 1 .or. len(path) > 4095) return
    if (index(path, c_null_char) /= 0) return
    if (.not. gridpoint_field_storage_mode_supported()) return
    child_status = create_gridpoint_field_context(24_int32, 19_int32, 86_int32, constituents, staged)
    status = 16_int32 + child_status
    if (child_status /= 0_int32) return
    do family = 1, 4
      do level = 1, 19
        staged%gfl(9:24, level, copied_fields(family), 86) = 0.0_real64
      end do
    end do
    child_status = load_initial_upper_air_state(path, staged%gfl)
    if (child_status /= 0_int32) then
      status = 32_int32 + child_status
      ignored = release_gridpoint_field_context(staged)
      return
    end if
    call move_alloc(staged, context)
    status = 0_int32
  end function

  integer(int32) function create_loaded_operational_upper_air_state(path, constituents, context) result(status)
    !! Create fixed operational(17,137,9,388217) fields and three physics
    !! fields. The7copied fields'9unused rows in the last block become +0
    !! before decoding:7x137x9 FP64 words =69048bytes. All other incoming
    !! numerical allocation bytes remain unchanged until file placement.
    !! Ownership, return codes and publication follow the selected entry.
    character(len=*), intent(in) :: path
    type(thermal_constituent), target, intent(in) :: constituents(:)
    type(gridpoint_field_state), allocatable, intent(inout) :: context
    type(gridpoint_field_state), allocatable :: staged
    integer :: family, level
    integer(int32) :: child_status, ignored
    status = 1_int32
    if (allocated(context)) return
    if (len(path) < 1 .or. len(path) > 4095) return
    if (index(path, c_null_char) /= 0) return
    if (.not. gridpoint_field_storage_mode_supported()) return
    child_status = create_operational_gridpoint_field_context(constituents, staged)
    status = 16_int32 + child_status
    if (child_status /= 0_int32) return
    do family = 1, 7
      do level = 1, 137
        staged%gfl(9:17, level, family, 388217) = 0.0_real64
      end do
    end do
    child_status = load_operational_upper_air_initial_state(path, staged%gfl)
    if (child_status /= 0_int32) then
      status = 32_int32 + child_status
      ignored = release_gridpoint_field_context(staged)
      return
    end if
    call move_alloc(staged, context)
    status = 0_int32
  end function
end module owned_upper_air_initial_state_port
