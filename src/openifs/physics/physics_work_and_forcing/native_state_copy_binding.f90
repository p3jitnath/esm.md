!> Project one actual canonical STATE onto the unchanged numeric copy entry.
!> These temporary records contain borrowed pointer metadata, never field data.
module forecast_native_state_copy_binding
  use iso_fortran_env, only: int32
  use forecast_physics_work_types, only: STATE_TYPE, DIMENSION_TYPE
  use forecast_physics_state_views, only: physics_state_views, copy_runtime_physics_state
  implicit none
  private
  public :: copy_native_runtime_physics_state
contains
  integer(int32) function copy_native_runtime_physics_state(d, input, output, profiling) result(status)
    type(DIMENSION_TYPE), intent(in) :: d
    type(STATE_TYPE), intent(in) :: input
    type(STATE_TYPE), intent(inout) :: output
    logical, intent(in) :: profiling
    type(physics_state_views) :: source, destination
    call borrow_state(input, source)
    call borrow_state(output, destination)
    status = copy_runtime_physics_state(d%klon, d%kidia, d%kfdia, d%klev, source, destination, profiling)
  end function
  subroutine borrow_state(state, view)
    type(STATE_TYPE), intent(in) :: state
    type(physics_state_views), intent(out) :: view
    view%u => state%u; view%v => state%v; view%t => state%t
    view%q => state%q; view%o3 => state%o3; view%a => state%a
    view%ect => state%tke; view%clv => state%cld
    view%lq = state%keymask%q; view%lo3 = state%keymask%o3; view%la = state%keymask%a
    view%lliquid = state%keymask%ql; view%lice = state%keymask%qi
    view%lrain = state%keymask%qr; view%lsnow = state%keymask%qs; view%lect = state%keymask%tke
  end subroutine
end module forecast_native_state_copy_binding
