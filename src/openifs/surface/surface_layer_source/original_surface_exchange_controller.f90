!> Complete native typed entry names for this selected source expansion.
!! The unchanged provider defines types, shapes, physical units and mutation.
!! Calls use compiler interfaces directly, with no payload copy or callback.
!! The original sea derivative retains its separate 0.98 multiplication.
module forecast_original_surface_exchange_controller
  use forecast_native_surface_exchange_controller, only: surface_exchange_controller => surfexcdriver_ctl
 use forecast_native_surface_exchange_controller, only: md2asm_surface_exchange_controller_original_sea_7358525 => surfexcdriver_ctl
  implicit none
  private
  public :: surface_exchange_controller
  public :: md2asm_surface_exchange_controller_original_sea_7358525
end module forecast_original_surface_exchange_controller
