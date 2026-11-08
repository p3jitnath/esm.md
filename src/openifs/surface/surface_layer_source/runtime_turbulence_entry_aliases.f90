!> Native typed names for the complete selected surface tail-entry family.
!! Each public name refers directly to its unchanged typed provider. Arguments,
!! units, ownership, mutation and admitted bounds are those of that provider.
!! The compiler owns calling conventions; no raw address or old ABI is used.
module forecast_turbulence_private_entries
  use forecast_native_surface_weather_children, only: md2asm_ocean_skin_temperature_private_entry => voskin
  use forecast_native_surface_energy_balance, only: md2asm_surface_energy_private_7358525 => surfseb_ctl
  use forecast_surface_evaporation, only: md2asm_surface_evaporation_private_7358525 => vevap
  use forecast_native_surface_postprocessing, only: md2asm_surfpp_ctl_7240564 => surfpp_ctl
  use forecast_native_surface_energy_balance, only: md2asm_surfseb_ctl_7240564 => surfseb_ctl
  use forecast_native_heat_water_diffusion, only: md2asm_vdfdifh_7240564 => vdfdifh
  use forecast_momentum_diffusion, only: md2asm_vdfdifm_7240564 => vdfdifm
  use forecast_boundary_layer_helpers, only: md2asm_vdfdpbl_7240564 => vdfdpbl
  use forecast_turbulent_exchange, only: md2asm_vdfexcu_7240564 => vdfexcu
  use forecast_boundary_layer_helpers, only: md2asm_vdffblend_7240564 => vdffblend
  use boundary_layer_parcel_height_mod, only: md2asm_vdfhghtn_7240564 => vdfhghtn
  use forecast_momentum_diffusion, only: md2asm_vdfincr_7240564 => vdfincr
  use forecast_turbulent_terrain_drag, only: md2asm_vdftofdc_7240564 => vdftofdc
  implicit none
  private
  public :: md2asm_ocean_skin_temperature_private_entry
  public :: md2asm_surface_energy_private_7358525
  public :: md2asm_surface_evaporation_private_7358525
  public :: md2asm_surfpp_ctl_7240564
  public :: md2asm_surfseb_ctl_7240564
  public :: md2asm_vdfdifh_7240564
  public :: md2asm_vdfdifm_7240564
  public :: md2asm_vdfdpbl_7240564
  public :: md2asm_vdfexcu_7240564
  public :: md2asm_vdffblend_7240564
  public :: md2asm_vdfhghtn_7240564
  public :: md2asm_vdfincr_7240564
  public :: md2asm_vdftofdc_7240564
end module forecast_turbulence_private_entries
