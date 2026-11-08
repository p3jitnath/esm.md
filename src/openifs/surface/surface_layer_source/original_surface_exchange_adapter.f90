!> Complete native typed entry names for this selected source expansion.
!! The unchanged provider defines types, shapes, physical units and mutation.
!! Calls use compiler interfaces directly, with no payload copy or callback.
!! The original sea derivative retains its separate 0.98 multiplication.
module forecast_original_surface_exchange_adapter
  use surfexcdriver_native_selector, only: surface_exchange_adapter => surfexcdriver
  use surfexcdriver_native_selector, only: md2asm_surface_exchange_adapter_sea_r2_7358525 => surfexcdriver
  implicit none
  private
  public :: surface_exchange_adapter
  public :: md2asm_surface_exchange_adapter_sea_r2_7358525
end module forecast_original_surface_exchange_adapter
