// Contract: skills/md2asm/references/openifs/support/shared_hook_snow_providers.md.
// Keep the existing grid body and expose both names for its one tail branch.
#define ORIGINAL_SYMBOL md2asm_snow_grid_private_entry
#include "snow_grid.S"
.global __srfsn_vgrid_mod_MOD_srfsn_vgrid
.type __srfsn_vgrid_mod_MOD_srfsn_vgrid,%function
.set __srfsn_vgrid_mod_MOD_srfsn_vgrid,md2asm_snow_grid_private_entry
.size __srfsn_vgrid_mod_MOD_srfsn_vgrid,4
