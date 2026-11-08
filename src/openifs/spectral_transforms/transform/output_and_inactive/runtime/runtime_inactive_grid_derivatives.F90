!> Complete live-count GP_DERIVATIVES no-gradient route with no requested gradients.
module md2asm_runtime_inactive_grid_derivatives
  use iso_fortran_env, only: int32, int64, real64
  use md2asm_inactive_grid_derivatives, only: gradient_component_control
  use md2asm_transform_profile_policy, only: transform_profile_policy, transform_profile_event, increment_source_counter
  implicit none
  private
  public :: gradient_component_control, gp_derivatives
contains
!> Admit the complete inactive route and retain its source hook/counter order.
!! LGRADGP and the two logical fields in each component are read-only native
!! controls. NUMFLDS is the live registered count1:2163; COMPONENTS contains
!! at least that many actual records. The selected eight-field entry is unchanged.
!! Geometry and field payloads are not consumed or changed by this route.
!! COUNTER is a borrowed INT64 word; every successful call increments it.
!! STATUS is 0 on completion or 2 before hooks/counter changes on refusal.
!! Optional PROFILE enables actual paired FIAT hooks. No floating-point
!! calculation or gradient implementation is required on this admitted route.
  subroutine gp_derivatives(lgradgp, numflds, components, counter, status, profile)
    logical, intent(in) :: lgradgp
    integer(int32), intent(in) :: numflds
    type(gradient_component_control), intent(in) :: components(:)
    integer(int64), intent(inout) :: counter
    integer(int32), intent(out) :: status
    type(transform_profile_policy), intent(in), optional :: profile
    real(real64) :: hook_handle
    integer :: j
    status = 2_int32
    if (lgradgp) return
    if (numflds < 1_int32 .or. numflds > 2163_int32) return
    if (size(components) < numflds) return
    do j = 1, numflds
      if (components(j)%lgp .and. components(j)%lcders) return
    end do
    call transform_profile_event('GP_DERIVATIVES', 0_int32, hook_handle, profile)
    call increment_source_counter(counter)
    call transform_profile_event('GP_DERIVATIVES', 1_int32, hook_handle, profile)
    status = 0_int32
  end subroutine
end module
