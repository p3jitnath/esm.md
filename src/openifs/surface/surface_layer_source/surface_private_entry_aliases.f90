!> Native typed names for the complete selected surface tail-entry family.
!! Each public name refers directly to its unchanged typed provider. Arguments,
!! units, ownership, mutation and admitted bounds are those of that provider.
!! The compiler owns calling conventions; no raw address or old ABI is used.
module forecast_surface_private_entries
  use forecast_radiation_private_canopy, only: md2asm_canalb_wrapper_child => canalb
  use srfsn_asn_mod, only: md2asm_driver_asn => srfsn_asn
  use srfsn_vgrid_mod, only: md2asm_driver_grid => srfsn_vgrid
  use srfsn_regrid_mod, only: md2asm_driver_regrid => srfsn_regrid
  use srfsn_rsn_mod, only: md2asm_driver_rsn => srfsn_rsn
  use srfsn_ssrabs_mod, only: md2asm_driver_ssrabs => srfsn_ssrabs
  use srfsn_webal_mod, only: md2asm_driver_webal => srfsn_webal
  use forecast_layer_private_canopy, only: md2asm_layer_canalb_child => canalb
  use forecast_layer_private_radiation_controller, only: md2asm_layer_ctl_child => surfrad_ctl
  use forecast_native_surface_weather_children, only: md2asm_ocean_skin_temperature_private_entry => voskin
  use srfi_mod, only: md2asm_sea_ice_temperature_private_7358525 => srfi
  use forecast_snow_mass_adjustment, only: md2asm_snow_mass_private_entry => adjust_snow_mass
  use srfwdif_mod, only: md2asm_soil_column_private_entry => srfwdif
  use forecast_native_surface_energy_balance, only: md2asm_surface_energy_private_7358525 => surfseb_ctl
  use forecast_surface_evaporation, only: md2asm_surface_evaporation_private_7358525 => vevap
  use srfwl_mod, only: md2asm_surface_interception_private_7358525 => srfwl
  use srfwdif_mod, only: md2asm_surface_soil_diffusion_private_7358525 => srfwdif
  use forecast_explicit_surface_water_increment, only: md2asm_surface_soil_increment_private_7358525 => srfwinc
  use forecast_explicit_surface_water_correction, only: md2asm_surface_water_correction_private_7358525 => srfwng
  use forecast_native_surface_postprocessing, only: md2asm_surfpp_ctl_7240564 => surfpp_ctl
  use forecast_radiation_private_controller, only: md2asm_surfrad_ctl_wrapper_child => surfrad_ctl
  use forecast_native_surface_energy_balance, only: md2asm_surfseb_ctl_7240564 => surfseb_ctl
  use forecast_native_heat_water_diffusion, only: md2asm_vdfdifh_7240564 => vdfdifh
  use forecast_momentum_diffusion, only: md2asm_vdfdifm_7240564 => vdfdifm
  use forecast_boundary_layer_helpers, only: md2asm_vdfdpbl_7240564 => vdfdpbl
  use forecast_turbulent_exchange, only: md2asm_vdfexcu_7240564 => vdfexcu
  use forecast_boundary_layer_helpers, only: md2asm_vdffblend_7240564 => vdffblend
  use boundary_layer_parcel_height_mod, only: md2asm_vdfhghtn_7240564 => vdfhghtn
  use forecast_momentum_diffusion, only: md2asm_vdfincr_7240564 => vdfincr
  use forecast_turbulent_terrain_drag, only: md2asm_vdftofdc_7240564 => vdftofdc
  use native_radiation_calendar_and_ice, only: md2asm_layer_updcal_child => updcal
  use native_radiation_calendar_and_ice, only: md2asm_layer_icestate_child => icestatenemo
  use forecast_layer_private_surface_radiation, only: md2asm_layer_surfrad_child => surfrad
  implicit none
  private
  public :: md2asm_canalb_wrapper_child
  public :: md2asm_driver_asn
  public :: md2asm_driver_grid
  public :: md2asm_driver_regrid
  public :: md2asm_driver_rsn
  public :: md2asm_driver_ssrabs
  public :: md2asm_driver_webal
  public :: md2asm_layer_canalb_child
  public :: md2asm_layer_ctl_child
  public :: md2asm_ocean_skin_temperature_private_entry
  public :: md2asm_sea_ice_temperature_private_7358525
  public :: md2asm_snow_mass_private_entry
  public :: md2asm_soil_column_private_entry
  public :: md2asm_surface_energy_private_7358525
  public :: md2asm_surface_evaporation_private_7358525
  public :: md2asm_surface_interception_private_7358525
  public :: md2asm_surface_soil_diffusion_private_7358525
  public :: md2asm_surface_soil_increment_private_7358525
  public :: md2asm_surface_water_correction_private_7358525
  public :: md2asm_surfpp_ctl_7240564
  public :: md2asm_surfrad_ctl_wrapper_child
  public :: md2asm_surfseb_ctl_7240564
  public :: md2asm_vdfdifh_7240564
  public :: md2asm_vdfdifm_7240564
  public :: md2asm_vdfdpbl_7240564
  public :: md2asm_vdfexcu_7240564
  public :: md2asm_vdffblend_7240564
  public :: md2asm_vdfhghtn_7240564
  public :: md2asm_vdfincr_7240564
  public :: md2asm_vdftofdc_7240564
  public :: md2asm_layer_updcal_child
  public :: md2asm_layer_icestate_child
  public :: md2asm_layer_surfrad_child
end module forecast_surface_private_entries
