!> Make surface variables and their three source time-level fields.
module forecast_registry_surface
  use iso_fortran_env, only: int32, real64
  use forecast_registry_field_types
  use forecast_registry_motion, only: slice_registry_field_2d, slice_registry_field_3d
  use forecast_registry_storage
  use forecast_registry_runtime_groups
  use forecast_native_field_variable_types
  use surface_field_registration_port, only: surface_field_metadata
  use surface_field_configuration_port, only: surface_field_registry, surface_metadata_alias
  use surface_field_storage_port, only: surface_field_state
  implicit none
contains
  integer(int32) function create_registry_surface_variable_2d(output, name, array, indices, points, layers) result(status)
    type(native_registry_variable_2d), intent(inout) :: output
    character(*), intent(in) :: name
    real(real64), pointer, intent(in) :: array(:, :, :)
    integer(int32), intent(in) :: indices(3), points, layers
    real(real64), pointer :: section(:, :)
    type(native_registry_field_2d), pointer :: pending
    status = initialize_registry_variable(output, name)
    if (status /= 0) return
    output%lactive = indices(1) > 0; output%lt1 = indices(2) > 0; output%lt9 = indices(3) > 0
    allocate (pending, stat=status)
    if (status /= 0) then
      status = 1; return
    end if
    if (indices(1) > 0) then
      call slice_registry_field_2d(section, array, indices(1))
      status = wrap_registry_field_2d(pending, section)
    else
      status = allocate_registry_field_2d(pending, [points, 1_int32], .true.)
    end if
    if (status /= 0) return
    output%ft0 => pending
    allocate (pending, stat=status)
    if (status /= 0) then
      status = 1; return
    end if
    if (indices(2) > 0) then
      call slice_registry_field_2d(section, array, indices(2))
      status = wrap_registry_field_2d(pending, section)
    else
      status = allocate_registry_field_2d(pending, [points, 1_int32], .true.)
    end if
    if (status /= 0) return
    output%ft1 => pending
    allocate (pending, stat=status)
    if (status /= 0) then
      status = 1; return
    end if
    if (indices(3) > 0) then
      call slice_registry_field_2d(section, array, indices(3))
      status = wrap_registry_field_2d(pending, section)
    else
      status = allocate_registry_field_2d(pending, [points, 1_int32], .true.)
    end if
    if (status /= 0) return
    output%ft9 => pending
    status = 0
  end function
  integer(int32) function create_registry_surface_array1_2d(output, name, array, metadata, alias, points, layers) result(status)
    type(native_registry_variable_2d), allocatable, intent(inout) :: output(:)
    character(*), intent(in) :: name
    real(real64), pointer, intent(in) :: array(:, :, :)
    type(surface_field_registry), intent(in) :: metadata
    type(surface_metadata_alias), intent(in) :: alias
    integer(int32), intent(in) :: points, layers
    integer :: first, second, allocation_status, index
    integer(int32) :: indices(3)
    character(16) :: field_name
    status = 2
    if (allocated(output)) return
    if (alias%extent1 < 0 .or. alias%extent1 > 255) return
    allocate (output(alias%extent1), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    do first = 1, alias%extent1
      field_name = name
      if (len(name) < 16) field_name(len(name) + 1:len(name) + 1) = "_"
      if (len(name) + 1 < 16) field_name(len(name) + 2:len(name) + 2) = achar(first)
      index = alias%first_field + first - 1
      indices = metadata%groups(alias%group)%fields(index)%indices([1, 4, 3])
      status = create_registry_surface_variable_2d(output(first), field_name, array, indices, points, layers)
      if (status /= 0) return
    end do
    status = 0
  end function
  integer(int32) function create_registry_surface_array2_2d(output, name, array, metadata, alias, points, layers) result(status)
    type(native_registry_variable_2d), allocatable, intent(inout) :: output(:, :)
    character(*), intent(in) :: name
    real(real64), pointer, intent(in) :: array(:, :, :)
    type(surface_field_registry), intent(in) :: metadata
    type(surface_metadata_alias), intent(in) :: alias
    integer(int32), intent(in) :: points, layers
    integer :: first, second, allocation_status, index
    integer(int32) :: indices(3)
    character(16) :: field_name
    status = 2
    if (allocated(output)) return
    if (alias%extent1 < 0 .or. alias%extent1 > 255) return
    if (alias%extent2 < 0 .or. alias%extent2 > 255) return
    allocate (output(alias%extent1, alias%extent2), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    do second = 1, alias%extent2
    do first = 1, alias%extent1
      field_name = name
      if (len(name) < 16) field_name(len(name) + 1:len(name) + 1) = "_"
      if (len(name) + 1 < 16) field_name(len(name) + 2:len(name) + 2) = achar(first)
      if (len(name) + 2 < 16) field_name(len(name) + 3:len(name) + 3) = "_"
      if (len(name) + 3 < 16) field_name(len(name) + 4:len(name) + 4) = achar(second)
      index = alias%first_field + first - 1 + (second - 1)*alias%extent1
      indices = metadata%groups(alias%group)%fields(index)%indices([1, 4, 3])
      status = create_registry_surface_variable_2d(output(first, second), field_name, array, indices, points, layers)
      if (status /= 0) return
    end do
    end do
    status = 0
  end function
  integer(int32) function create_registry_surface_variable_3d(output, name, array, indices, points, layers) result(status)
    type(native_registry_variable_3d), intent(inout) :: output
    character(*), intent(in) :: name
    real(real64), pointer, intent(in) :: array(:, :, :, :)
    integer(int32), intent(in) :: indices(3), points, layers
    real(real64), pointer :: section(:, :, :)
    type(native_registry_field_3d), pointer :: pending
    status = initialize_registry_variable(output, name)
    if (status /= 0) return
    output%lactive = indices(1) > 0; output%lt1 = indices(2) > 0; output%lt9 = indices(3) > 0
    allocate (pending, stat=status)
    if (status /= 0) then
      status = 1; return
    end if
    if (indices(1) > 0) then
      call slice_registry_field_3d(section, array, indices(1))
      status = wrap_registry_field_3d(pending, section)
    else
      status = allocate_registry_field_3d(pending, [points, layers, 1_int32], .true.)
    end if
    if (status /= 0) return
    output%ft0 => pending
    allocate (pending, stat=status)
    if (status /= 0) then
      status = 1; return
    end if
    if (indices(2) > 0) then
      call slice_registry_field_3d(section, array, indices(2))
      status = wrap_registry_field_3d(pending, section)
    else
      status = allocate_registry_field_3d(pending, [points, layers, 1_int32], .true.)
    end if
    if (status /= 0) return
    output%ft1 => pending
    allocate (pending, stat=status)
    if (status /= 0) then
      status = 1; return
    end if
    if (indices(3) > 0) then
      call slice_registry_field_3d(section, array, indices(3))
      status = wrap_registry_field_3d(pending, section)
    else
      status = allocate_registry_field_3d(pending, [points, layers, 1_int32], .true.)
    end if
    if (status /= 0) return
    output%ft9 => pending
    status = 0
  end function
  integer(int32) function create_registry_surface_array1_3d(output, name, array, metadata, alias, points, layers) result(status)
    type(native_registry_variable_3d), allocatable, intent(inout) :: output(:)
    character(*), intent(in) :: name
    real(real64), pointer, intent(in) :: array(:, :, :, :)
    type(surface_field_registry), intent(in) :: metadata
    type(surface_metadata_alias), intent(in) :: alias
    integer(int32), intent(in) :: points, layers
    integer :: first, second, allocation_status, index
    integer(int32) :: indices(3)
    character(16) :: field_name
    status = 2
    if (allocated(output)) return
    if (alias%extent1 < 0 .or. alias%extent1 > 255) return
    allocate (output(alias%extent1), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    do first = 1, alias%extent1
      field_name = name
      if (len(name) < 16) field_name(len(name) + 1:len(name) + 1) = "_"
      if (len(name) + 1 < 16) field_name(len(name) + 2:len(name) + 2) = achar(first)
      index = alias%first_field + first - 1
      indices = metadata%groups(alias%group)%fields(index)%indices([1, 4, 3])
      status = create_registry_surface_variable_3d(output(first), field_name, array, indices, points, layers)
      if (status /= 0) return
    end do
    status = 0
  end function
  integer(int32) function create_registry_surface_array2_3d(output, name, array, metadata, alias, points, layers) result(status)
    type(native_registry_variable_3d), allocatable, intent(inout) :: output(:, :)
    character(*), intent(in) :: name
    real(real64), pointer, intent(in) :: array(:, :, :, :)
    type(surface_field_registry), intent(in) :: metadata
    type(surface_metadata_alias), intent(in) :: alias
    integer(int32), intent(in) :: points, layers
    integer :: first, second, allocation_status, index
    integer(int32) :: indices(3)
    character(16) :: field_name
    status = 2
    if (allocated(output)) return
    if (alias%extent1 < 0 .or. alias%extent1 > 255) return
    if (alias%extent2 < 0 .or. alias%extent2 > 255) return
    allocate (output(alias%extent1, alias%extent2), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    do second = 1, alias%extent2
    do first = 1, alias%extent1
      field_name = name
      if (len(name) < 16) field_name(len(name) + 1:len(name) + 1) = "_"
      if (len(name) + 1 < 16) field_name(len(name) + 2:len(name) + 2) = achar(first)
      if (len(name) + 2 < 16) field_name(len(name) + 3:len(name) + 3) = "_"
      if (len(name) + 3 < 16) field_name(len(name) + 4:len(name) + 4) = achar(second)
      index = alias%first_field + first - 1 + (second - 1)*alias%extent1
      indices = metadata%groups(alias%group)%fields(index)%indices([1, 4, 3])
      status = create_registry_surface_variable_3d(output(first, second), field_name, array, indices, points, layers)
      if (status /= 0) return
    end do
    end do
    status = 0
  end function
  integer(int32) function create_registry_surface_extra_array1_2d(output, name, array, metadata, points, layers) result(status)
    type(native_registry_variable_2d), allocatable, intent(inout) :: output(:)
    character(*), intent(in) :: name
    real(real64), pointer, intent(in) :: array(:, :, :)
    type(surface_field_metadata), pointer, intent(in) :: metadata(:)
    integer(int32), intent(in) :: points, layers
    integer :: first, second, allocation_status
    integer(int32) :: indices(3)
    character(16) :: field_name
    status = 2
    if (allocated(output)) return
    if (size(metadata, 1) > 255) return
    allocate (output(size(metadata, 1)), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    do first = 1, size(metadata, 1)
      field_name = name
      if (len(name) < 16) field_name(len(name) + 1:len(name) + 1) = "_"
      if (len(name) + 1 < 16) field_name(len(name) + 2:len(name) + 2) = achar(first)
      indices = metadata(first)%indices([1, 4, 3])
      status = create_registry_surface_variable_2d(output(first), field_name, array, indices, points, layers)
      if (status /= 0) return
    end do
    status = 0
  end function
  integer(int32) function create_registry_surface_extra_array2_2d(output, name, array, metadata, points, layers) result(status)
    type(native_registry_variable_2d), allocatable, intent(inout) :: output(:, :)
    character(*), intent(in) :: name
    real(real64), pointer, intent(in) :: array(:, :, :)
    type(surface_field_metadata), pointer, intent(in) :: metadata(:, :)
    integer(int32), intent(in) :: points, layers
    integer :: first, second, allocation_status
    integer(int32) :: indices(3)
    character(16) :: field_name
    status = 2
    if (allocated(output)) return
    if (size(metadata, 1) > 255) return
    if (size(metadata, 2) > 255) return
    allocate (output(size(metadata, 1), size(metadata, 2)), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    do second = 1, size(metadata, 2)
    do first = 1, size(metadata, 1)
      field_name = name
      if (len(name) < 16) field_name(len(name) + 1:len(name) + 1) = "_"
      if (len(name) + 1 < 16) field_name(len(name) + 2:len(name) + 2) = achar(first)
      if (len(name) + 2 < 16) field_name(len(name) + 3:len(name) + 3) = "_"
      if (len(name) + 3 < 16) field_name(len(name) + 4:len(name) + 4) = achar(second)
      indices = metadata(first, second)%indices([1, 4, 3])
      status = create_registry_surface_variable_2d(output(first, second), field_name, array, indices, points, layers)
      if (status /= 0) return
    end do
    end do
    status = 0
  end function
  integer function find_surface_alias(metadata, name) result(index)
    type(surface_field_registry), intent(in) :: metadata
    character(*), intent(in) :: name
    integer :: i
    index = 0
    do i = 1, size(metadata%aliases)
      if (metadata%aliases(i)%name == name) then
        index = i; return
      end if
    end do
  end function
  subroutine surface_alias_indices(metadata, alias, indices)
    type(surface_field_registry), intent(in) :: metadata
    type(surface_metadata_alias), intent(in) :: alias
    integer(int32), intent(out) :: indices(3)
    indices = 0
    if (alias%group < 1 .or. alias%group > size(metadata%groups)) return
    if (.not. allocated(metadata%groups(alias%group)%fields)) return
    if (alias%first_field < 1 .or. alias%first_field > size(metadata%groups(alias%group)%fields)) return
    indices = metadata%groups(alias%group)%fields(alias%first_field)%indices([1, 4, 3])
  end subroutine
  integer(int32) function register_registry_surface(output, metadata, arrays, points, runtime_groups, extra_aliases) result(status)
    type(native_surface_variables), pointer, intent(inout) :: output
    type(surface_field_registry), intent(in) :: metadata
    type(surface_field_state), target, intent(in) :: arrays
    integer(int32), intent(in) :: points
    logical, intent(in) :: runtime_groups
    type(native_registry_extra_aliases), intent(in) :: extra_aliases
    integer :: allocation_status, alias_index, group_index, first, second, k
    integer(int32) :: indices(3), layers
    real(real64), pointer :: data3(:, :, :), data4(:, :, :, :)
    type(surface_metadata_alias) :: alias
    status = 1
    if (.not. associated(output)) then
      allocate (output, stat=allocation_status)
      if (allocation_status /= 0) return
    end if
    group_index = 0
    do k = 1, size(metadata%groups)
      if (trim(metadata%groups(k)%key) == "YSP_SBD") group_index = k
    end do
    status = 2
    if (group_index == 0) return
    layers = metadata%groups(group_index)%metadata%layers
    data4 => arrays%sp_sb
    alias_index = find_surface_alias(metadata, 'YSP_SB%YT')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_3d(output%gsp_sb%vt, 'SP_SB_T', data4, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSP_SB%YQ')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_3d(output%gsp_sb%vq, 'SP_SB_Q', data4, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSP_SB%YTL')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_3d(output%gsp_sb%vtl, 'SP_SB_TL', data4, indices, points, layers)
    if (status /= 0) return
    if (metadata%groups(group_index)%metadata%stored_fields /= 0) then
      status = wrap_registry_field_4d(output%gsp_sb%f_group, data4)
    else
      if (runtime_groups) then
   status = allocate_runtime_registry_surface_group(output%gsp_sb%f_group, [points, max(1_int32, layers), 1_int32, 1_int32], .true.)
      else
        status = allocate_registry_field_4d(output%gsp_sb%f_group, [points, max(1_int32, layers), 1_int32, 1_int32], .true.)
      end if
    end if
    if (status /= 0) return
    group_index = 0
    do k = 1, size(metadata%groups)
      if (trim(metadata%groups(k)%key) == "YSP_SGD") group_index = k
    end do
    status = 2
    if (group_index == 0) return
    layers = metadata%groups(group_index)%metadata%layers
    data4 => arrays%sp_sg
    alias_index = find_surface_alias(metadata, 'YSP_SG%YF')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_3d(output%gsp_sg%vf, 'SP_SG_F', data4, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSP_SG%YA')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_3d(output%gsp_sg%va, 'SP_SG_A', data4, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSP_SG%YR')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_3d(output%gsp_sg%vr, 'SP_SG_R', data4, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSP_SG%YT')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_3d(output%gsp_sg%vt, 'SP_SG_T', data4, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSP_SG%YW')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_3d(output%gsp_sg%vw, 'SP_SG_W', data4, indices, points, layers)
    if (status /= 0) return
    if (metadata%groups(group_index)%metadata%stored_fields /= 0) then
      status = wrap_registry_field_4d(output%gsp_sg%f_group, data4)
    else
      if (runtime_groups) then
   status = allocate_runtime_registry_surface_group(output%gsp_sg%f_group, [points, max(1_int32, layers), 1_int32, 1_int32], .true.)
      else
        status = allocate_registry_field_4d(output%gsp_sg%f_group, [points, max(1_int32, layers), 1_int32, 1_int32], .true.)
      end if
    end if
    if (status /= 0) return
    group_index = 0
    do k = 1, size(metadata%groups)
      if (trim(metadata%groups(k)%key) == "YSP_SLD") group_index = k
    end do
    status = 2
    if (group_index == 0) return
    layers = metadata%groups(group_index)%metadata%layers
    data3 => arrays%sp_sl
    alias_index = find_surface_alias(metadata, 'YSP_SL%YLICT')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsp_sl%vlict, 'SP_SL_LICT', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSP_SL%YLMLT')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsp_sl%vlmlt, 'SP_SL_LMLT', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSP_SL%YLTLT')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsp_sl%vltlt, 'SP_SL_LTLT', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSP_SL%YLBLT')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsp_sl%vlblt, 'SP_SL_LBLT', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSP_SL%YLSHF')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsp_sl%vlshf, 'SP_SL_LSHF', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSP_SL%YLICD')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsp_sl%vlicd, 'SP_SL_LICD', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSP_SL%YLMLD')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsp_sl%vlmld, 'SP_SL_LMLD', data3, indices, points, layers)
    if (status /= 0) return
    if (metadata%groups(group_index)%metadata%stored_fields /= 0) then
      status = wrap_registry_field_3d(output%gsp_sl%f_group, data3)
    else
      if (runtime_groups) then
        status = allocate_runtime_registry_surface_group(output%gsp_sl%f_group, [points, 1_int32, 1_int32], .true.)
      else
        status = allocate_registry_field_3d(output%gsp_sl%f_group, [points, 1_int32, 1_int32], .true.)
      end if
    end if
    if (status /= 0) return
    group_index = 0
    do k = 1, size(metadata%groups)
      if (trim(metadata%groups(k)%key) == "YSP_RRD") group_index = k
    end do
    status = 2
    if (group_index == 0) return
    layers = metadata%groups(group_index)%metadata%layers
    data3 => arrays%sp_rr
    alias_index = find_surface_alias(metadata, 'YSP_RR%YT')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsp_rr%vt, 'SP_RR_T', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSP_RR%YW')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsp_rr%vw, 'SP_RR_W', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSP_RR%YFC')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsp_rr%vfc, 'SP_RR_FC', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSP_RR%YIC')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsp_rr%vic, 'SP_RR_IC', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSP_RR%YFP1')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsp_rr%vfp1, 'SP_RR_FP1', data3, indices, points, layers)
    if (status /= 0) return
    if (metadata%groups(group_index)%metadata%stored_fields /= 0) then
      status = wrap_registry_field_3d(output%gsp_rr%f_group, data3)
    else
      if (runtime_groups) then
        status = allocate_runtime_registry_surface_group(output%gsp_rr%f_group, [points, 1_int32, 1_int32], .true.)
      else
        status = allocate_registry_field_3d(output%gsp_rr%f_group, [points, 1_int32, 1_int32], .true.)
      end if
    end if
    if (status /= 0) return
    group_index = 0
    do k = 1, size(metadata%groups)
      if (trim(metadata%groups(k)%key) == "YSP_CLD") group_index = k
    end do
    status = 2
    if (group_index == 0) return
    layers = metadata%groups(group_index)%metadata%layers
    data3 => arrays%sp_cl
    alias_index = find_surface_alias(metadata, 'YSP_CL%YTCLS')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsp_cl%vtcls, 'SP_CL_TCLS', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSP_CL%YHUCLS')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsp_cl%vhucls, 'SP_CL_HUCLS', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSP_CL%YUCLS')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsp_cl%vucls, 'SP_CL_UCLS', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSP_CL%YVCLS')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsp_cl%vvcls, 'SP_CL_VCLS', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSP_CL%YNUCLS')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsp_cl%vnucls, 'SP_CL_NUCLS', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSP_CL%YNVCLS')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsp_cl%vnvcls, 'SP_CL_NVCLS', data3, indices, points, layers)
    if (status /= 0) return
    if (metadata%groups(group_index)%metadata%stored_fields /= 0) then
      status = wrap_registry_field_3d(output%gsp_cl%f_group, data3)
    else
      if (runtime_groups) then
        status = allocate_runtime_registry_surface_group(output%gsp_cl%f_group, [points, 1_int32, 1_int32], .true.)
      else
        status = allocate_registry_field_3d(output%gsp_cl%f_group, [points, 1_int32, 1_int32], .true.)
      end if
    end if
    if (status /= 0) return
    group_index = 0
    do k = 1, size(metadata%groups)
      if (trim(metadata%groups(k)%key) == "YSP_OMD") group_index = k
    end do
    status = 2
    if (group_index == 0) return
    layers = metadata%groups(group_index)%metadata%layers
    data4 => arrays%sp_om
    alias_index = find_surface_alias(metadata, 'YSP_OM%YTO')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_3d(output%gsp_om%vto, 'SP_OM_TO', data4, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSP_OM%YSO')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_3d(output%gsp_om%vso, 'SP_OM_SO', data4, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSP_OM%YUO')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_3d(output%gsp_om%vuo, 'SP_OM_UO', data4, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSP_OM%YVO')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_3d(output%gsp_om%vvo, 'SP_OM_VO', data4, indices, points, layers)
    if (status /= 0) return
    if (metadata%groups(group_index)%metadata%stored_fields /= 0) then
      status = wrap_registry_field_4d(output%gsp_om%f_group, data4)
    else
      if (runtime_groups) then
   status = allocate_runtime_registry_surface_group(output%gsp_om%f_group, [points, max(1_int32, layers), 1_int32, 1_int32], .true.)
      else
        status = allocate_registry_field_4d(output%gsp_om%f_group, [points, max(1_int32, layers), 1_int32, 1_int32], .true.)
      end if
    end if
    if (status /= 0) return
    group_index = 0
    do k = 1, size(metadata%groups)
      if (trim(metadata%groups(k)%key) == "YSP_EPD") group_index = k
    end do
    status = 2
    if (group_index == 0) return
    layers = metadata%groups(group_index)%metadata%layers
    data4 => arrays%sp_ep
    if (metadata%groups(group_index)%metadata%stored_fields /= 0) then
      status = wrap_registry_field_4d(output%gsp_ep%f_group, data4)
    else
      if (runtime_groups) then
   status = allocate_runtime_registry_surface_group(output%gsp_ep%f_group, [points, max(1_int32, layers), 1_int32, 1_int32], .true.)
      else
        status = allocate_registry_field_4d(output%gsp_ep%f_group, [points, max(1_int32, layers), 1_int32, 1_int32], .true.)
      end if
    end if
    if (status /= 0) return
    group_index = 0
    do k = 1, size(metadata%groups)
      if (trim(metadata%groups(k)%key) == "YSP_X2D") group_index = k
    end do
    status = 2
    if (group_index == 0) return
    layers = metadata%groups(group_index)%metadata%layers
    data3 => arrays%sp_x2
    if (metadata%groups(group_index)%metadata%stored_fields /= 0) then
      status = wrap_registry_field_3d(output%gsp_x2%f_group, data3)
    else
      if (runtime_groups) then
        status = allocate_runtime_registry_surface_group(output%gsp_x2%f_group, [points, 1_int32, 1_int32], .true.)
      else
        status = allocate_registry_field_3d(output%gsp_x2%f_group, [points, 1_int32, 1_int32], .true.)
      end if
    end if
    if (status /= 0) return
    group_index = 0
    do k = 1, size(metadata%groups)
      if (trim(metadata%groups(k)%key) == "YSP_CID") group_index = k
    end do
    status = 2
    if (group_index == 0) return
    layers = metadata%groups(group_index)%metadata%layers
    data3 => arrays%sp_ci
    if (metadata%groups(group_index)%metadata%stored_fields /= 0) then
      status = wrap_registry_field_3d(output%gsp_ci%f_group, data3)
    else
      if (runtime_groups) then
        status = allocate_runtime_registry_surface_group(output%gsp_ci%f_group, [points, 1_int32, 1_int32], .true.)
      else
        status = allocate_registry_field_3d(output%gsp_ci%f_group, [points, 1_int32, 1_int32], .true.)
      end if
    end if
    if (status /= 0) return
    group_index = 0
    do k = 1, size(metadata%groups)
      if (trim(metadata%groups(k)%key) == "YSD_VFD") group_index = k
    end do
    status = 2
    if (group_index == 0) return
    layers = metadata%groups(group_index)%metadata%layers
    data3 => arrays%sd_vf
    alias_index = find_surface_alias(metadata, 'YSD_VF%YZ0F')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vz0f, 'SD_VF_Z0F', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YALBF')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%valbf, 'SD_VF_ALBF', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YEMISF')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vemisf, 'SD_VF_EMISF', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YGETRL')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vgetrl, 'SD_VF_GETRL', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YLSM')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vlsm, 'SD_VF_LSM', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YVEG')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vveg, 'SD_VF_VEG', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YVRLAN')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vvrlan, 'SD_VF_VRLAN', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YVRLDI')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vvrldi, 'SD_VF_VRLDI', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YSIG')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vsig, 'SD_VF_SIG', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YALBSF')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%valbsf, 'SD_VF_ALBSF', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YLAN')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vlan, 'SD_VF_LAN', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YSST')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vsst, 'SD_VF_SST', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YSSS')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vsss, 'SD_VF_SSS', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YLZ0H')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vlz0h, 'SD_VF_LZ0H', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YCVL')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vcvl, 'SD_VF_CVL', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YCO2TYP')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vco2typ, 'SD_VF_CO2TYP', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YCVH')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vcvh, 'SD_VF_CVH', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YCUR')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vcur, 'SD_VF_CUR', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YTVL')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vtvl, 'SD_VF_TVL', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YTVH')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vtvh, 'SD_VF_TVH', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YLAIL')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vlail, 'SD_VF_LAIL', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YLAIH')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vlaih, 'SD_VF_LAIH', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YFWET')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vfwet, 'SD_VF_FWET', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YSOTY')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vsoty, 'SD_VF_SOTY', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YCLK')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vclk, 'SD_VF_CLK', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YDL')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vdl, 'SD_VF_DL', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YCI')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vci, 'SD_VF_CI', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YUCUR')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vucur, 'SD_VF_UCUR', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YVCUR')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vvcur, 'SD_VF_VCUR', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YZ0RLF')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vz0rlf, 'SD_VF_Z0RLF', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YCGPP')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vcgpp, 'SD_VF_CGPP', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YCREC')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vcrec, 'SD_VF_CREC', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YSDFOR')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vsdfor, 'SD_VF_SDFOR', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YALUVP')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%valuvp, 'SD_VF_ALUVP', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YALUVD')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%valuvd, 'SD_VF_ALUVD', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YALNIP')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%valnip, 'SD_VF_ALNIP', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YALNID')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%valnid, 'SD_VF_ALNID', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YFP1')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vfp1, 'SD_VF_FP1', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YSO2DD')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vso2dd, 'SD_VF_SO2DD', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YDMSO')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vdmso, 'SD_VF_DMSO', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YURBF')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vurbf, 'SD_VF_URBF', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YFCA1')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vfca1, 'SD_VF_FCA1', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YFCA2')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vfca2, 'SD_VF_FCA2', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YAERDEP')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vaerdep, 'SD_VF_AERDEP', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YAERLTS')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vaerlts, 'SD_VF_AERLTS', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YAERSCC')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vaerscc, 'SD_VF_AERSCC', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YDSF')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vdsf, 'SD_VF_DSF', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YCHEMFLXO')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    if (allocated(metadata%groups(alias%group)%fields)) then
    if (metadata%groups(alias%group)%fields(alias%first_field)%initialized /= 0) then
      status = create_registry_surface_array1_2d(output%gsd_vf%vchemflxo, 'SD_VF_CHEMFLXO', data3, metadata, alias, points, layers)
      if (status /= 0) return
    end if
    end if
    alias_index = find_surface_alias(metadata, 'YSD_VF%YCHEMWDFLX')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    if (allocated(metadata%groups(alias%group)%fields)) then
    if (metadata%groups(alias%group)%fields(alias%first_field)%initialized /= 0) then
     status = create_registry_surface_array1_2d(output%gsd_vf%vchemwdflx, 'SD_VF_CHEMWDFLX', data3, metadata, alias, points, layers)
      if (status /= 0) return
    end if
    end if
    alias_index = find_surface_alias(metadata, 'YSD_VF%YCHEMDDFLX')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    if (allocated(metadata%groups(alias%group)%fields)) then
    if (metadata%groups(alias%group)%fields(alias%first_field)%initialized /= 0) then
     status = create_registry_surface_array1_2d(output%gsd_vf%vchemddflx, 'SD_VF_CHEMDDFLX', data3, metadata, alias, points, layers)
      if (status /= 0) return
    end if
    end if
    alias_index = find_surface_alias(metadata, 'YSD_VF%YCHEMDV')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    if (allocated(metadata%groups(alias%group)%fields)) then
    if (metadata%groups(alias%group)%fields(alias%first_field)%initialized /= 0) then
      status = create_registry_surface_array1_2d(output%gsd_vf%vchemdv, 'SD_VF_CHEMDV', data3, metadata, alias, points, layers)
      if (status /= 0) return
    end if
    end if
    alias_index = find_surface_alias(metadata, 'YSD_VF%YNUDM')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vf%vnudm, 'SD_VF_NUDM', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VF%YEMIS2D')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    if (allocated(metadata%groups(alias%group)%fields)) then
    if (metadata%groups(alias%group)%fields(alias%first_field)%initialized /= 0) then
      status = create_registry_surface_array1_2d(output%gsd_vf%vemis2d, 'SD_VF_EMIS2D', data3, metadata, alias, points, layers)
      if (status /= 0) return
    end if
    end if
    alias_index = find_surface_alias(metadata, 'YSD_VF%YEMIS2DAUX')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    if (allocated(metadata%groups(alias%group)%fields)) then
    if (metadata%groups(alias%group)%fields(alias%first_field)%initialized /= 0) then
     status = create_registry_surface_array1_2d(output%gsd_vf%vemis2daux, 'SD_VF_EMIS2DAUX', data3, metadata, alias, points, layers)
      if (status /= 0) return
    end if
    end if
    if (metadata%groups(group_index)%metadata%stored_fields /= 0) then
      status = wrap_registry_field_3d(output%gsd_vf%f_group, data3)
    else
      if (runtime_groups) then
        status = allocate_runtime_registry_surface_group(output%gsd_vf%f_group, [points, 1_int32, 1_int32], .true.)
      else
        status = allocate_registry_field_3d(output%gsd_vf%f_group, [points, 1_int32, 1_int32], .true.)
      end if
    end if
    if (status /= 0) return
    group_index = 0
    do k = 1, size(metadata%groups)
      if (trim(metadata%groups(k)%key) == "YSD_VND") group_index = k
    end do
    status = 2
    if (group_index == 0) return
    layers = metadata%groups(group_index)%metadata%layers
    data3 => arrays%sd_vn
    alias_index = find_surface_alias(metadata, 'YSD_VN%YTOP')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vn%vtop, 'SD_VN_TOP', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VN%YBAS')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vn%vbas, 'SD_VN_BAS', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VN%YACPR')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vn%vacpr, 'SD_VN_ACPR', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VN%YACCPR')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vn%vaccpr, 'SD_VN_ACCPR', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VN%YACCPR5')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vn%vaccpr5, 'SD_VN_ACCPR5', data3, indices, points, layers)
    if (status /= 0) return
    if (metadata%groups(group_index)%metadata%stored_fields /= 0) then
      status = wrap_registry_field_3d(output%gsd_vn%f_group, data3)
    else
      if (runtime_groups) then
        status = allocate_runtime_registry_surface_group(output%gsd_vn%f_group, [points, 1_int32, 1_int32], .true.)
      else
        status = allocate_registry_field_3d(output%gsd_vn%f_group, [points, 1_int32, 1_int32], .true.)
      end if
    end if
    if (status /= 0) return
    group_index = 0
    do k = 1, size(metadata%groups)
      if (trim(metadata%groups(k)%key) == "YSD_V2D") group_index = k
    end do
    status = 2
    if (group_index == 0) return
    layers = metadata%groups(group_index)%metadata%layers
    data3 => arrays%sd_v2
    alias_index = find_surface_alias(metadata, 'YSD_V2%YOCDEP')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_v2%vocdep, 'SD_V2_OCDEP', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_V2%YUSTRC')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_v2%vustrc, 'SD_V2_USTRC', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_V2%YVSTRC')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_v2%vvstrc, 'SD_V2_VSTRC', data3, indices, points, layers)
    if (status /= 0) return
    if (metadata%groups(group_index)%metadata%stored_fields /= 0) then
      status = wrap_registry_field_3d(output%gsd_v2%f_group, data3)
    else
      if (runtime_groups) then
        status = allocate_runtime_registry_surface_group(output%gsd_v2%f_group, [points, 1_int32, 1_int32], .true.)
      else
        status = allocate_registry_field_3d(output%gsd_v2%f_group, [points, 1_int32, 1_int32], .true.)
      end if
    end if
    if (status /= 0) return
    group_index = 0
    do k = 1, size(metadata%groups)
      if (trim(metadata%groups(k)%key) == "YSD_V3D") group_index = k
    end do
    status = 2
    if (group_index == 0) return
    layers = metadata%groups(group_index)%metadata%layers
    data4 => arrays%sd_v3
    alias_index = find_surface_alias(metadata, 'YSD_V3%YDIFM')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_3d(output%gsd_v3%vdifm, 'SD_V3_DIFM', data4, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_V3%YDIFT')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_3d(output%gsd_v3%vdift, 'SD_V3_DIFT', data4, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_V3%YDIFS')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_3d(output%gsd_v3%vdifs, 'SD_V3_DIFS', data4, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_V3%YADVT')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_3d(output%gsd_v3%vadvt, 'SD_V3_ADVT', data4, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_V3%YADVS')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_3d(output%gsd_v3%vadvs, 'SD_V3_ADVS', data4, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_V3%YTRI0')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_3d(output%gsd_v3%vtri0, 'SD_V3_TRI0', data4, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_V3%YTRI1')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_3d(output%gsd_v3%vtri1, 'SD_V3_TRI1', data4, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_V3%YSWDK')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_3d(output%gsd_v3%vswdk, 'SD_V3_SWDK', data4, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_V3%YZO')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_3d(output%gsd_v3%vzo, 'SD_V3_ZO', data4, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_V3%YHO')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_3d(output%gsd_v3%vho, 'SD_V3_HO', data4, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_V3%YDO')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_3d(output%gsd_v3%vdo, 'SD_V3_DO', data4, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_V3%YHO_INV')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_3d(output%gsd_v3%vho_inv, 'SD_V3_HO_INV', data4, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_V3%YUOC')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_3d(output%gsd_v3%vuoc, 'SD_V3_UOC', data4, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_V3%YVOC')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_3d(output%gsd_v3%vvoc, 'SD_V3_VOC', data4, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_V3%YOTKE')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_3d(output%gsd_v3%votke, 'SD_V3_OTKE', data4, indices, points, layers)
    if (status /= 0) return
    if (metadata%groups(group_index)%metadata%stored_fields /= 0) then
      status = wrap_registry_field_4d(output%gsd_v3%f_group, data4)
    else
      if (runtime_groups) then
   status = allocate_runtime_registry_surface_group(output%gsd_v3%f_group, [points, max(1_int32, layers), 1_int32, 1_int32], .true.)
      else
        status = allocate_registry_field_4d(output%gsd_v3%f_group, [points, max(1_int32, layers), 1_int32, 1_int32], .true.)
      end if
    end if
    if (status /= 0) return
    group_index = 0
    do k = 1, size(metadata%groups)
      if (trim(metadata%groups(k)%key) == "YSD_VDD") group_index = k
    end do
    status = 2
    if (group_index == 0) return
    layers = metadata%groups(group_index)%metadata%layers
    data3 => arrays%sd_vd
    alias_index = find_surface_alias(metadata, 'YSD_VD%YLSP')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vlsp, 'SD_VD_LSP', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YCP')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vcp, 'SD_VD_CP', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YSF')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vsf, 'SD_VD_SF', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YFZRA')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vfzra, 'SD_VD_FZRA', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YBLD')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vbld, 'SD_VD_BLD', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YSSHF')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vsshf, 'SD_VD_SSHF', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YSLHF')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vslhf, 'SD_VD_SLHF', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YNEE')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vnee, 'SD_VD_NEE', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YGPP')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vgpp, 'SD_VD_GPP', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YREC')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vrec, 'SD_VD_REC', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YMSL')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vmsl, 'SD_VD_MSL', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YSP')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vsp, 'SD_VD_SP', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YTCC')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vtcc, 'SD_VD_TCC', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%Y10U')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%v10u, 'SD_VD_10U', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%Y10V')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%v10v, 'SD_VD_10V', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%Y2T')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%v2t, 'SD_VD_2T', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%Y2D')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%v2d, 'SD_VD_2D', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%Y2SH')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%v2sh, 'SD_VD_2SH', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YSSR')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vssr, 'SD_VD_SSR', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YSTR')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vstr, 'SD_VD_STR', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YTSR')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vtsr, 'SD_VD_TSR', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YTTR')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vttr, 'SD_VD_TTR', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YEWSS')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vewss, 'SD_VD_EWSS', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YNSSS')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vnsss, 'SD_VD_NSSS', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YE')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%ve, 'SD_VD_E', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YPEV')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vpev, 'SD_VD_PEV', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YCCC')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vccc, 'SD_VD_CCC', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YLCC')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vlcc, 'SD_VD_LCC', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YMCC')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vmcc, 'SD_VD_MCC', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YHCC')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vhcc, 'SD_VD_HCC', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YLGWS')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vlgws, 'SD_VD_LGWS', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YMGWS')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vmgws, 'SD_VD_MGWS', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YGWD')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vgwd, 'SD_VD_GWD', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YMX2T')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vmx2t, 'SD_VD_MX2T', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YMN2T')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vmn2t, 'SD_VD_MN2T', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YMX2T6')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    if (allocated(metadata%groups(alias%group)%fields)) then
    if (metadata%groups(alias%group)%fields(alias%first_field)%initialized /= 0) then
      status = create_registry_surface_array1_2d(output%gsd_vd%vmx2t6, 'SD_VD_MX2T6', data3, metadata, alias, points, layers)
      if (status /= 0) return
    end if
    end if
    alias_index = find_surface_alias(metadata, 'YSD_VD%YMN2T6')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    if (allocated(metadata%groups(alias%group)%fields)) then
    if (metadata%groups(alias%group)%fields(alias%first_field)%initialized /= 0) then
      status = create_registry_surface_array1_2d(output%gsd_vd%vmn2t6, 'SD_VD_MN2T6', data3, metadata, alias, points, layers)
      if (status /= 0) return
    end if
    end if
    alias_index = find_surface_alias(metadata, 'YSD_VD%YRO')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vro, 'SD_VD_RO', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YSRO')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vsro, 'SD_VD_SRO', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YSSRO')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vssro, 'SD_VD_SSRO', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YALB')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%valb, 'SD_VD_ALB', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YIEWSS')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%viewss, 'SD_VD_IEWSS', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YINSSS')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vinsss, 'SD_VD_INSSS', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YISSHF')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%visshf, 'SD_VD_ISSHF', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YIE')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vie, 'SD_VD_IE', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YINEE')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vinee, 'SD_VD_INEE', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YIGPP')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vigpp, 'SD_VD_IGPP', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YIREC')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%virec, 'SD_VD_IREC', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YICH4')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vich4, 'SD_VD_ICH4', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YCSF')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vcsf, 'SD_VD_CSF', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YLSSF')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vlssf, 'SD_VD_LSSF', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YMXTPR')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vmxtpr, 'SD_VD_MXTPR', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YMNTPR')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vmntpr, 'SD_VD_MNTPR', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YMXTPR6')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    if (allocated(metadata%groups(alias%group)%fields)) then
    if (metadata%groups(alias%group)%fields(alias%first_field)%initialized /= 0) then
      status = create_registry_surface_array1_2d(output%gsd_vd%vmxtpr6, 'SD_VD_MXTPR6', data3, metadata, alias, points, layers)
      if (status /= 0) return
    end if
    end if
    alias_index = find_surface_alias(metadata, 'YSD_VD%YMNTPR6')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    if (allocated(metadata%groups(alias%group)%fields)) then
    if (metadata%groups(alias%group)%fields(alias%first_field)%initialized /= 0) then
      status = create_registry_surface_array1_2d(output%gsd_vd%vmntpr6, 'SD_VD_MNTPR6', data3, metadata, alias, points, layers)
      if (status /= 0) return
    end if
    end if
    alias_index = find_surface_alias(metadata, 'YSD_VD%YTPR')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vtpr, 'SD_VD_TPR', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YLSRR')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vlsrr, 'SD_VD_LSRR', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YCRR')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vcrr, 'SD_VD_CRR', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YLSSFR')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vlssfr, 'SD_VD_LSSFR', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YCSFR')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vcsfr, 'SD_VD_CSFR', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YPTYPE')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vptype, 'SD_VD_PTYPE', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YILSPF')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vilspf, 'SD_VD_ILSPF', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YZ0F')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vz0f, 'SD_VD_Z0F', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YLZ0H')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vlz0h, 'SD_VD_LZ0H', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YVIWVE')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vviwve, 'SD_VD_VIWVE', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YVIWVN')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vviwvn, 'SD_VD_VIWVN', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YTCW')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vtcw, 'SD_VD_TCW', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YTCWV')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vtcwv, 'SD_VD_TCWV', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YTCLW')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vtclw, 'SD_VD_TCLW', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YTCIW')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vtciw, 'SD_VD_TCIW', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YTCRW')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vtcrw, 'SD_VD_TCRW', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YTCSW')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vtcsw, 'SD_VD_TCSW', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YTCSLW')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vtcslw, 'SD_VD_TCSLW', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YSSRD')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vssrd, 'SD_VD_SSRD', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YSTRD')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vstrd, 'SD_VD_STRD', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YSSRDC')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vssrdc, 'SD_VD_SSRDC', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YSTRDC')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vstrdc, 'SD_VD_STRDC', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YBLH')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vblh, 'SD_VD_BLH', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YSUND')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vsund, 'SD_VD_SUND', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YSPAR')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vspar, 'SD_VD_SPAR', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YSUVB')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vsuvb, 'SD_VD_SUVB', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YSFDIR')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vsfdir, 'SD_VD_SFDIR', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YSCDIR')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vscdir, 'SD_VD_SCDIR', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YSDSRP')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vsdsrp, 'SD_VD_SDSRP', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YCAPE')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vcape, 'SD_VD_CAPE', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YMUCAPE')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vmucape, 'SD_VD_MUCAPE', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YMLCAPE50')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vmlcape50, 'SD_VD_MLCAPE50', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YMLCAPE100')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vmlcape100, 'SD_VD_MLCAPE100', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YPDEPL')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vpdepl, 'SD_VD_PDEPL', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YCAPES')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vcapes, 'SD_VD_CAPES', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YMXCAP6')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    if (allocated(metadata%groups(alias%group)%fields)) then
    if (metadata%groups(alias%group)%fields(alias%first_field)%initialized /= 0) then
      status = create_registry_surface_array1_2d(output%gsd_vd%vmxcap6, 'SD_VD_MXCAP6', data3, metadata, alias, points, layers)
      if (status /= 0) return
    end if
    end if
    alias_index = find_surface_alias(metadata, 'YSD_VD%YMXCAPS6')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    if (allocated(metadata%groups(alias%group)%fields)) then
    if (metadata%groups(alias%group)%fields(alias%first_field)%initialized /= 0) then
      status = create_registry_surface_array1_2d(output%gsd_vd%vmxcaps6, 'SD_VD_MXCAPS6', data3, metadata, alias, points, layers)
      if (status /= 0) return
    end if
    end if
    alias_index = find_surface_alias(metadata, 'YSD_VD%YTROPOTP')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vtropotp, 'SD_VD_TROPOTP', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YTSRC')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vtsrc, 'SD_VD_TSRC', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YTTRC')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vttrc, 'SD_VD_TTRC', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YSSRC')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vssrc, 'SD_VD_SSRC', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YSTRC')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vstrc, 'SD_VD_STRC', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YES')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%ves, 'SD_VD_ES', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YSMLT')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vsmlt, 'SD_VD_SMLT', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%Y10FG')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%v10fg, 'SD_VD_10FG', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%Y10FG6')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    if (allocated(metadata%groups(alias%group)%fields)) then
    if (metadata%groups(alias%group)%fields(alias%first_field)%initialized /= 0) then
      status = create_registry_surface_array1_2d(output%gsd_vd%v10fg6, 'SD_VD_10FG6', data3, metadata, alias, points, layers)
      if (status /= 0) return
    end if
    end if
    alias_index = find_surface_alias(metadata, 'YSD_VD%Y10FGCV')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%v10fgcv, 'SD_VD_10FGCV', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YI10FG')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vi10fg, 'SD_VD_I10FG', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YLSPF')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vlspf, 'SD_VD_LSPF', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YTCO3')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vtco3, 'SD_VD_TCO3', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YVIMD')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vvimd, 'SD_VD_VIMD', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YSPARC')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vsparc, 'SD_VD_SPARC', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YSTINC')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vstinc, 'SD_VD_STINC', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YCBASE')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vcbase, 'SD_VD_CBASE', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%Y0DEGL')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%v0degl, 'SD_VD_0DEGL', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YM10DEGL')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vm10degl, 'SD_VD_M10DEGL', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YVISIH')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vvisih, 'SD_VD_VISIH', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YCIN')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vcin, 'SD_VD_CIN', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YMLCIN50')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vmlcin50, 'SD_VD_MLCIN50', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YMLCIN100')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vmlcin100, 'SD_VD_MLCIN100', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YKINDEX')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vkindex, 'SD_VD_KINDEX', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YTTINDEX')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vttindex, 'SD_VD_TTINDEX', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YCBASEA')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vcbasea, 'SD_VD_CBASEA', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YCTOPC')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vctopc, 'SD_VD_CTOPC', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YZTWETB0')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vztwetb0, 'SD_VD_ZTWETB0', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YZTWETB1')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vztwetb1, 'SD_VD_ZTWETB1', data3, indices, points, layers)
    if (status /= 0) return
    if (associated(extra_aliases%tcghg)) then
   status = create_registry_surface_extra_array1_2d(output%gsd_vd%vtcghg, 'SD_VD_TCGHG', data3, extra_aliases%tcghg, points, layers)
      if (status /= 0) return
    end if
    if (associated(extra_aliases%tcchem)) then
status = create_registry_surface_extra_array1_2d(output%gsd_vd%vtcchem, 'SD_VD_TCCHEM', data3, extra_aliases%tcchem, points, layers)
      if (status /= 0) return
    end if
    if (associated(extra_aliases%aerodiag)) then
 status=create_registry_surface_extra_array2_2d(output%gsd_vd%vaerodiag,'SD_VD_AERODIAG',data3,extra_aliases%aerodiag,points,layers)
      if (status /= 0) return
    end if
    alias_index = find_surface_alias(metadata, 'YSD_VD%YAERO_WVL_DIAG')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    if (allocated(metadata%groups(alias%group)%fields)) then
    if (metadata%groups(alias%group)%fields(alias%first_field)%initialized /= 0) then
status = create_registry_surface_array2_2d(output%gsd_vd%vaero_wvl_diag, 'SD_VD_AERO_WVL_D', data3, metadata, alias, points, layers)
      if (status /= 0) return
    end if
    end if
    alias_index = find_surface_alias(metadata, 'YSD_VD%Y100U')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%v100u, 'SD_VD_100U', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%Y100V')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%v100v, 'SD_VD_100V', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%Y200U')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%v200u, 'SD_VD_200U', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%Y200V')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%v200v, 'SD_VD_200V', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YZUST')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vzust, 'SD_VD_ZUST', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%Y10NU')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%v10nu, 'SD_VD_10NU', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%Y10NV')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%v10nv, 'SD_VD_10NV', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YDNDZN')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vdndzn, 'SD_VD_DNDZN', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YDNDZA')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vdndza, 'SD_VD_DNDZA', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YDCTB')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vdctb, 'SD_VD_DCTB', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YTPLB')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vtplb, 'SD_VD_TPLB', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YTPLT')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vtplt, 'SD_VD_TPLT', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YODSS')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vodss, 'SD_VD_ODSS', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YODDU')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%voddu, 'SD_VD_ODDU', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YODOM')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vodom, 'SD_VD_ODOM', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YODBC')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vodbc, 'SD_VD_ODBC', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YODSU')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vodsu, 'SD_VD_ODSU', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YODNI')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vodni, 'SD_VD_ODNI', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YODAM')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vodam, 'SD_VD_ODAM', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YODSOA')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vodsoa, 'SD_VD_ODSOA', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YODVFA')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vodvfa, 'SD_VD_ODVFA', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YODVSU')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vodvsu, 'SD_VD_ODVSU', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YODTOACC')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vodtoacc, 'SD_VD_ODTOACC', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YAEPM1')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vaepm1, 'SD_VD_AEPM1', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YAEPM25')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vaepm25, 'SD_VD_AEPM25', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YAEPM10')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vaepm10, 'SD_VD_AEPM10', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YUVBED')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vuvbed, 'SD_VD_UVBED', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YUVBEDCS')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vuvbedcs, 'SD_VD_UVBEDCS', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YLITOTI')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vlitoti, 'SD_VD_LITOTI', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YLICGI')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_vd%vlicgi, 'SD_VD_LICGI', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_VD%YLITOTA6')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    if (allocated(metadata%groups(alias%group)%fields)) then
    if (metadata%groups(alias%group)%fields(alias%first_field)%initialized /= 0) then
      status = create_registry_surface_array1_2d(output%gsd_vd%vlitota6, 'SD_VD_LITOTA6', data3, metadata, alias, points, layers)
      if (status /= 0) return
    end if
    end if
    alias_index = find_surface_alias(metadata, 'YSD_VD%YLICGA6')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    if (allocated(metadata%groups(alias%group)%fields)) then
    if (metadata%groups(alias%group)%fields(alias%first_field)%initialized /= 0) then
      status = create_registry_surface_array1_2d(output%gsd_vd%vlicga6, 'SD_VD_LICGA6', data3, metadata, alias, points, layers)
      if (status /= 0) return
    end if
    end if
    alias_index = find_surface_alias(metadata, 'YSD_VD%YPTYPEOCC6')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    if (allocated(metadata%groups(alias%group)%fields)) then
    if (metadata%groups(alias%group)%fields(alias%first_field)%initialized /= 0) then
     status = create_registry_surface_array2_2d(output%gsd_vd%vptypeocc6, 'SD_VD_PTYPEOCC6', data3, metadata, alias, points, layers)
      if (status /= 0) return
    end if
    end if
    if (metadata%groups(group_index)%metadata%stored_fields /= 0) then
      status = wrap_registry_field_3d(output%gsd_vd%f_group, data3)
    else
      if (runtime_groups) then
        status = allocate_runtime_registry_surface_group(output%gsd_vd%f_group, [points, 1_int32, 1_int32], .true.)
      else
        status = allocate_registry_field_3d(output%gsd_vd%f_group, [points, 1_int32, 1_int32], .true.)
      end if
    end if
    if (status /= 0) return
    group_index = 0
    do k = 1, size(metadata%groups)
      if (trim(metadata%groups(k)%key) == "YSD_SMD") group_index = k
    end do
    status = 2
    if (group_index == 0) return
    layers = metadata%groups(group_index)%metadata%layers
    data4 => arrays%sd_sm
    alias_index = find_surface_alias(metadata, 'YSD_SM%YCLBT')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_3d(output%gsd_sm%vclbt, 'SD_SM_CLBT', data4, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_SM%YCSBT')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_3d(output%gsd_sm%vcsbt, 'SD_SM_CSBT', data4, indices, points, layers)
    if (status /= 0) return
    if (metadata%groups(group_index)%metadata%stored_fields /= 0) then
      status = wrap_registry_field_4d(output%gsd_sm%f_group, data4)
    else
      if (runtime_groups) then
   status = allocate_runtime_registry_surface_group(output%gsd_sm%f_group, [points, max(1_int32, layers), 1_int32, 1_int32], .true.)
      else
        status = allocate_registry_field_4d(output%gsd_sm%f_group, [points, max(1_int32, layers), 1_int32, 1_int32], .true.)
      end if
    end if
    if (status /= 0) return
    group_index = 0
    do k = 1, size(metadata%groups)
      if (trim(metadata%groups(k)%key) == "YSD_WSD") group_index = k
    end do
    status = 2
    if (group_index == 0) return
    layers = metadata%groups(group_index)%metadata%layers
    data3 => arrays%sd_ws
    alias_index = find_surface_alias(metadata, 'YSD_WS%YCHAR')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_ws%vchar, 'SD_WS_CHAR', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_WS%YCHARHQ')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_ws%vcharhq, 'SD_WS_CHARHQ', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_WS%YUSTOKES')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_ws%vustokes, 'SD_WS_USTOKES', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_WS%YVSTOKES')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_ws%vvstokes, 'SD_WS_VSTOKES', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_WS%YTAUOCX')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_ws%vtauocx, 'SD_WS_TAUOCX', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_WS%YTAUOCY')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_ws%vtauocy, 'SD_WS_TAUOCY', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_WS%YPHIOC')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_ws%vphioc, 'SD_WS_PHIOC', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_WS%YWSEMEAN')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_ws%vwsemean, 'SD_WS_WSEMEAN', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_WS%YWSFMEAN')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_ws%vwsfmean, 'SD_WS_WSFMEAN', data3, indices, points, layers)
    if (status /= 0) return
    if (metadata%groups(group_index)%metadata%stored_fields /= 0) then
      status = wrap_registry_field_3d(output%gsd_ws%f_group, data3)
    else
      if (runtime_groups) then
        status = allocate_runtime_registry_surface_group(output%gsd_ws%f_group, [points, 1_int32, 1_int32], .true.)
      else
        status = allocate_registry_field_3d(output%gsd_ws%f_group, [points, 1_int32, 1_int32], .true.)
      end if
    end if
    if (status /= 0) return
    group_index = 0
    do k = 1, size(metadata%groups)
      if (trim(metadata%groups(k)%key) == "YSD_WWD") group_index = k
    end do
    status = 2
    if (group_index == 0) return
    layers = metadata%groups(group_index)%metadata%layers
    data3 => arrays%sd_ww
    alias_index = find_surface_alias(metadata, 'YSD_WW%YU10N')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_ww%vu10n, 'SD_WW_U10N', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_WW%YV10N')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_ww%vv10n, 'SD_WW_V10N', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_WW%YRHO')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_ww%vrho, 'SD_WW_RHO', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_WW%YZIL')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_ww%vzil, 'SD_WW_ZIL', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_WW%YCIF')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_ww%vcif, 'SD_WW_CIF', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_WW%YCLK')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_ww%vclk, 'SD_WW_CLK', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_WW%YUCURW')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_ww%vucurw, 'SD_WW_UCURW', data3, indices, points, layers)
    if (status /= 0) return
    alias_index = find_surface_alias(metadata, 'YSD_WW%YVCURW')
    status = 2
    if (alias_index == 0) return
    alias = metadata%aliases(alias_index)
    call surface_alias_indices(metadata, alias, indices)
    status = create_registry_surface_variable_2d(output%gsd_ww%vvcurw, 'SD_WW_VCURW', data3, indices, points, layers)
    if (status /= 0) return
    if (metadata%groups(group_index)%metadata%stored_fields /= 0) then
      status = wrap_registry_field_3d(output%gsd_ww%f_group, data3)
    else
      if (runtime_groups) then
        status = allocate_runtime_registry_surface_group(output%gsd_ww%f_group, [points, 1_int32, 1_int32], .true.)
      else
        status = allocate_registry_field_3d(output%gsd_ww%f_group, [points, 1_int32, 1_int32], .true.)
      end if
    end if
    if (status /= 0) return
    group_index = 0
    do k = 1, size(metadata%groups)
      if (trim(metadata%groups(k)%key) == "YSD_XAD") group_index = k
    end do
    status = 2
    if (group_index == 0) return
    layers = metadata%groups(group_index)%metadata%layers
    data4 => arrays%sd_xa
    if (metadata%groups(group_index)%metadata%stored_fields /= 0) then
      status = wrap_registry_field_4d(output%gsd_xa%f_group, data4)
    else
      if (runtime_groups) then
   status = allocate_runtime_registry_surface_group(output%gsd_xa%f_group, [points, max(1_int32, layers), 1_int32, 1_int32], .true.)
      else
        status = allocate_registry_field_4d(output%gsd_xa%f_group, [points, max(1_int32, layers), 1_int32, 1_int32], .true.)
      end if
    end if
    if (status /= 0) return
    group_index = 0
    do k = 1, size(metadata%groups)
      if (trim(metadata%groups(k)%key) == "YSD_X2D") group_index = k
    end do
    status = 2
    if (group_index == 0) return
    layers = metadata%groups(group_index)%metadata%layers
    data3 => arrays%sd_x2
    if (metadata%groups(group_index)%metadata%stored_fields /= 0) then
      status = wrap_registry_field_3d(output%gsd_x2%f_group, data3)
    else
      if (runtime_groups) then
        status = allocate_runtime_registry_surface_group(output%gsd_x2%f_group, [points, 1_int32, 1_int32], .true.)
      else
        status = allocate_registry_field_3d(output%gsd_x2%f_group, [points, 1_int32, 1_int32], .true.)
      end if
    end if
    if (status /= 0) return
    status = 0
  end function
end module forecast_registry_surface
