!> Bind empty trajectory storage to the actual borrowed forecast owners.
module forecast_runtime_trajectory_binding
  use iso_fortran_env, only: int32, int64
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_empty_trajectory_storage
  implicit none
contains
!> Read live counts, the same clock and initialization flags without copying owners.
!! MODEL and its initial Geometry remain at stable addresses for the storage lifetime.
  integer(int32) function initialize_runtime_empty_trajectory_state(state, model, byte_limit) result(status)
    type(native_empty_trajectory_state), intent(inout) :: state
    type(native_operational_model_configuration), intent(in) :: model
    integer(int64), intent(in) :: byte_limit
    integer(int32) :: first, last, points, width, blocks
    status = 2
    if (.not. model%ready .or. .not. associated(model%initial)) return
    if (.not. model%initial%ready) return
    if (.not. allocated(model%initial%geometry)) return
    if (.not. model%initial%geometry%initialized) return
    if (.not. allocated(model%initial%prefix)) return
    if (.not. associated(model%initial%geometry%vertical, model%initial%prefix%vertical)) return
    first = model%initial%controls%clock%integration%first_step
    last = model%initial%controls%clock%integration%total_steps
    points = model%initial%geometry%partition%ngptot
    width = model%initial%geometry%dimensions%nproma
    blocks = model%initial%geometry%partition%ngpblks
    status = initialize_runtime_empty_trajectory_from_dimensions(state, first, last, points, width, blocks, &
                                       model%initial%initialization%ldfi /= 0, model%initial%initialization%ljcdfi /= 0, byte_limit)
  end function
end module
