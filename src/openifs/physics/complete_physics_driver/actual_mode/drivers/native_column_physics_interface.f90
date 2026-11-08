!> Native column interface; its source body is compiled separately.
module forecast_native_column_physics
  use iso_fortran_env, only: int32
  use forecast_complete_physics_context_types, only: native_complete_physics_context, native_complete_physics_driver_inputs
  implicit none
  private
  public :: ec_phys
  interface
    module integer(int32) function ec_phys(context, inputs) result(status)
      type(native_complete_physics_context), target, intent(inout) :: context
      type(native_complete_physics_driver_inputs), target, intent(inout) :: inputs
    end function
  end interface
end module
