!> Native typed names for the complete selected surface tail-entry family.
!! Each public name refers directly to its unchanged typed provider. Arguments,
!! units, ownership, mutation and admitted bounds are those of that provider.
!! The compiler owns calling conventions; no raw address or old ABI is used.
module forecast_surface_time_private_entries
  use srfsn_asn_mod, only: md2asm_driver_asn => srfsn_asn
  use srfsn_vgrid_mod, only: md2asm_driver_grid => srfsn_vgrid
  use srfsn_regrid_mod, only: md2asm_driver_regrid => srfsn_regrid
  use srfsn_rsn_mod, only: md2asm_driver_rsn => srfsn_rsn
  use srfsn_ssrabs_mod, only: md2asm_driver_ssrabs => srfsn_ssrabs
  use srfsn_webal_mod, only: md2asm_driver_webal => srfsn_webal
  use srfi_mod, only: md2asm_sea_ice_temperature_private_7358525 => srfi
  use srfwdif_mod, only: md2asm_soil_column_private_entry => srfwdif
  use srfwl_mod, only: md2asm_surface_interception_private_7358525 => srfwl
  use srfwdif_mod, only: md2asm_surface_soil_diffusion_private_7358525 => srfwdif
  use forecast_explicit_surface_water_increment, only: md2asm_surface_soil_increment_private_7358525 => srfwinc
  use forecast_explicit_surface_water_correction, only: md2asm_surface_water_correction_private_7358525 => srfwng
  implicit none
  private
  public :: md2asm_driver_asn
  public :: md2asm_driver_grid
  public :: md2asm_driver_regrid
  public :: md2asm_driver_rsn
  public :: md2asm_driver_ssrabs
  public :: md2asm_driver_webal
  public :: md2asm_sea_ice_temperature_private_7358525
  public :: md2asm_soil_column_private_entry
  public :: md2asm_surface_interception_private_7358525
  public :: md2asm_surface_soil_diffusion_private_7358525
  public :: md2asm_surface_soil_increment_private_7358525
  public :: md2asm_surface_water_correction_private_7358525
end module forecast_surface_time_private_entries
