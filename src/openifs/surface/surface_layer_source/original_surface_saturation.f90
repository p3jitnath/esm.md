!> Complete native typed entry names for this selected source expansion.
!! The unchanged provider defines types, shapes, physical units and mutation.
!! Calls use compiler interfaces directly, with no payload copy or callback.
!! The original sea derivative retains its separate 0.98 multiplication.
module forecast_original_surface_saturation
  use forecast_surface_boundary_preparation, only: vsurf_original_source_sea
  use forecast_surface_boundary_preparation, only: md2asm_vsurf_original_sea_derivative_7358525 => vsurf_original_source_sea
  implicit none
  private
  public :: vsurf_original_source_sea
  public :: md2asm_vsurf_original_sea_derivative_7358525
end module forecast_original_surface_saturation
