!> Borrow one physical block without reading or changing a field value.
module forecast_physics_field_views
  use iso_fortran_env, only: int32, real64
  use forecast_registry_field_types
  implicit none
contains
  integer(int32) function physics_field_view_2d(output, field, block) result(status)
    real(real64), pointer, intent(inout) :: output(:)
    type(native_registry_field_2d), intent(in) :: field
    integer(int32), intent(in) :: block
    integer :: selected
    status = 0
    if (.not. field%active) then
      output => field%view
      return
    end if
    selected = block
    if (field%thread_buffer) selected = 1
    status = 2
    if (field%owned) then
      if (.not. associated(field%data)) return
      if (selected < lbound(field%data, 2) .or. selected > ubound(field%data, 2)) return
      output => field%data(:, selected)
    else
      if (.not. associated(field%ptr)) return
      if (selected < lbound(field%ptr, 2) .or. selected > ubound(field%ptr, 2)) return
      output => field%ptr(:, selected)
    end if
    status = 0
  end function
  integer(int32) function physics_field_view_3d(output, field, block) result(status)
    real(real64), pointer, intent(inout) :: output(:, :)
    type(native_registry_field_3d), intent(in) :: field
    integer(int32), intent(in) :: block
    integer :: selected
    status = 0
    if (.not. field%active) then
      output => field%view
      return
    end if
    selected = block
    if (field%thread_buffer) selected = 1
    status = 2
    if (field%owned) then
      if (.not. associated(field%data)) return
      if (selected < lbound(field%data, 3) .or. selected > ubound(field%data, 3)) return
      output => field%data(:, :, selected)
    else
      if (.not. associated(field%ptr)) return
      if (selected < lbound(field%ptr, 3) .or. selected > ubound(field%ptr, 3)) return
      output => field%ptr(:, :, selected)
    end if
    status = 0
  end function
  integer(int32) function physics_field_view_4d(output, field, block) result(status)
    real(real64), pointer, intent(inout) :: output(:, :, :)
    type(native_registry_field_4d), intent(in) :: field
    integer(int32), intent(in) :: block
    integer :: selected
    status = 0
    if (.not. field%active) then
      output => field%view
      return
    end if
    selected = block
    if (field%thread_buffer) selected = 1
    status = 2
    if (field%owned) then
      if (.not. associated(field%data)) return
      if (selected < lbound(field%data, 4) .or. selected > ubound(field%data, 4)) return
      output => field%data(:, :, :, selected)
    else
      if (.not. associated(field%ptr)) return
      if (selected < lbound(field%ptr, 4) .or. selected > ubound(field%ptr, 4)) return
      output => field%ptr(:, :, :, selected)
    end if
    status = 0
  end function
end module forecast_physics_field_views
