!> Static native interface for the complete post-physics layer.
!! This declaration supplies no calculation and earns no source completion.
!! The final submodule owns field projection and the complete child call order.
module forecast_native_post_physics
  use iso_fortran_env, only: int32, real64
  use forecast_complete_physics_context_types, only: native_complete_physics_context, native_complete_physics_driver_inputs
  implicit none
  private
  public :: postphy_layer
  interface
module integer(int32) function postphy_layer(context,inputs,put9,pvt9,ptt9,pgfl,tenq,first_step,mlpp,rs6,reset,lrsacc)result(status)
      type(native_complete_physics_context), target, intent(inout) :: context
      type(native_complete_physics_driver_inputs), intent(inout) :: inputs
      real(real64), intent(in) :: put9(:, :), pvt9(:, :), ptt9(:, :), tenq(:, :)
      real(real64), intent(inout) :: pgfl(:, :, :)
      logical, intent(in) :: first_step, mlpp, rs6, reset, lrsacc
    end function
  end interface
end module
