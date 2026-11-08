!> Expose the actual typed producer and consumers of the two transform layouts.
!! The old include files supplied private record offsets, not mathematics.
!! These module imports retain one canonical state and the actual procedures.
!! No object image, offset constant, parameter clone or callback is introduced.
module forecast_complete_transform_include_contexts
use forecast_native_transform_controller_state,only:native_transform_controller_state,serial_transform_ready,ensure_transform_buffer
  use forecast_native_grid_transform_copies, only: trltog, trgtol, grid_transform_copy_count
  use forecast_native_legendre_controllers, only: ltinv_ctl, ltdir_ctl, legendre_controllers_count
  use forecast_native_legendre_controller_support, only: copy_legendre_partition, analyse_spectral_order
  use md2asm_transform_types, only: transform_fourier_layout, transform_spectral_tables
  use md2asm_inverse_spectral_transform, only: inverse_spectral_preparation, reconstruct_spectral_order
  implicit none
  private
  public :: native_transform_controller_state, serial_transform_ready, ensure_transform_buffer
  public :: trltog, trgtol, grid_transform_copy_count, ltinv_ctl, ltdir_ctl, legendre_controllers_count
  public :: copy_legendre_partition, analyse_spectral_order
  public :: transform_fourier_layout, transform_spectral_tables, inverse_spectral_preparation, reconstruct_spectral_order
end module forecast_complete_transform_include_contexts
