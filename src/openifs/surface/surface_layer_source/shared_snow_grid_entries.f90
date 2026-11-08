!> Complete native typed entry names for this selected source expansion.
!! The unchanged provider defines types, shapes, physical units and mutation.
!! Calls use compiler interfaces directly, with no payload copy or callback.
module forecast_shared_snow_grid_entries
  use srfsn_vgrid_mod, only: srfsn_vgrid
  use srfsn_vgrid_mod, only: md2asm_snow_grid_private_entry => srfsn_vgrid
  implicit none
  private
  public :: srfsn_vgrid
  public :: md2asm_snow_grid_private_entry
end module forecast_shared_snow_grid_entries
