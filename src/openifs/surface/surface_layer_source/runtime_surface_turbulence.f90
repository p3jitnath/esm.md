!> Complete native typed entry names for this selected source expansion.
!! The unchanged provider defines types, shapes, physical units and mutation.
!! Calls use compiler interfaces directly, with no payload copy or callback.
module forecast_runtime_surface_turbulence
  use forecast_selected_surface_layer_adapters, only: surface_turbulence_layer
 use forecast_selected_surface_layer_adapters, only: md2asm_surface_turbulence_layer_sea_r2_layout_r2_7358525 => surface_turbulence_layer
  implicit none
  private
  public :: surface_turbulence_layer
  public :: md2asm_surface_turbulence_layer_sea_r2_layout_r2_7358525
end module forecast_runtime_surface_turbulence
