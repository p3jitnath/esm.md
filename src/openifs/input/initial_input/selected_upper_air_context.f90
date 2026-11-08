module forecast_selected_upper_air_context
  !! Project the selected upper-air request from owned native field metadata.
  !! Ports upper_air_initial_context.S without GNU descriptor byte offsets.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use gridpoint_field_storage_port, only: gridpoint_field_state
  use grid_field_configuration_types_port, only: grid_field_configuration
  implicit none
  private
  public :: selected_upper_air_context, project_selected_upper_air_context
  type :: selected_upper_air_context
    integer(int32) :: invalid = 1, pitch = 0, levels = 0, local_points = 0, field_count = 0, component_count = 0
    integer(int32) :: linear_description_change = 0, low_resolution_constructor = 0
    integer(int32) :: actions(8) = 0, parameters(4) = 0, slots(4) = 0
    real(real64), pointer, contiguous :: values(:, :, :, :) => null()
  end type
contains
  integer(int32) function project_selected_upper_air_context(pitch,levels,local_points,fields,configuration,linear_physics,trajectory_replay,low_resolution,output) result(status)
    !! fields owns GFL(24,19,8,86) and remains a stable TARGET through use.
    !! configuration is the accepted GFL metadata owner. Integer flags come
    !! from the caller's real linear-physics/replay/low-resolution producers.
    !! Output is cleared then populated like the source metadata getter.
    integer(int32), intent(in) :: pitch, levels, local_points
    type(gridpoint_field_state), target, intent(inout) :: fields
    type(grid_field_configuration), intent(in) :: configuration
    integer(int32), intent(in) :: linear_physics, trajectory_replay, low_resolution
    type(selected_upper_air_context), intent(out) :: output
    integer(int32), parameter :: expected_actions(8) = [1, 1, 1, 2, 2, 1, 2, 2]
    integer(int32), parameter :: expected_parameters(4) = [133, 246, 247, 248], expected_slots(4) = [1, 2, 3, 6]
    integer :: j, slot, requested
    integer(int32) :: actions(8), parameters(4), slots(4)
    output = selected_upper_air_context()
    output%pitch = pitch; output%levels = levels; output%local_points = local_points
    output%field_count = configuration%registration%ndim
    output%component_count = configuration%registration%numflds
    status = 1
    if (pitch /= 24 .or. levels /= 19 .or. local_points /= 2048 .or. output%field_count /= 8) return
    if (output%component_count < 1 .or. output%component_count > size(configuration%components)) return
    if (.not. allocated(fields%gfl)) return
    if (any(shape(fields%gfl) /= [24, 19, 8, 86])) return
    output%values => fields%gfl
    output%linear_description_change = iand(linear_physics, trajectory_replay)
    output%low_resolution_constructor = low_resolution
    if (output%linear_description_change /= 0 .or. low_resolution /= 0) return
    requested = 0; actions = 0; parameters = 0; slots = 0
    do j = 1, output%component_count
      if (configuration%components(j)%lgp == 0) cycle
      slot = configuration%components(j)%mp
      if (slot < 1 .or. slot > 8) return
      if (actions(slot) /= 0) return
      if (configuration%components(j)%nreqin == 1) then
        if (configuration%components(j)%lgpingp /= 0) then
          if (requested >= 4) return
          requested = requested + 1
          parameters(requested) = configuration%components(j)%igrbcode
          slots(requested) = slot
          actions(slot) = 1
          cycle
        end if
        if (configuration%components(j)%ltrajio == 0) return
      end if
      actions(slot) = 2
    end do
    if (requested /= 4) return
    if (any(actions /= expected_actions) .or. any(parameters /= expected_parameters) .or. any(slots /= expected_slots)) return
    output%actions = actions; output%parameters = parameters; output%slots = slots
    output%invalid = 0
    status = 0
  end function
end module forecast_selected_upper_air_context
