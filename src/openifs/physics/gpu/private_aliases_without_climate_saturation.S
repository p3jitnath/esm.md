// Contract: skills/md2asm-gpu/references/openifs/physics/climatological_aerosol_visibility_layer.md.
/* Private function names for identical qualified direct-assembly bodies.
 * Tail branches preserve registers, stack arguments and numerical status. */
.arch armv8.2-a
.text
.p2align 2
.global md2asm_ec_private_gpaddslphy
.type md2asm_ec_private_gpaddslphy,%function
md2asm_ec_private_gpaddslphy:
 b gpaddslphy_
.size md2asm_ec_private_gpaddslphy,.-md2asm_ec_private_gpaddslphy
.global md2asm_forecast_grid_7259755
.type md2asm_forecast_grid_7259755,%function
md2asm_forecast_grid_7259755:
 b cpg_gp_
.size md2asm_forecast_grid_7259755,.-md2asm_forecast_grid_7259755
.global md2asm_ftcontroller_fsc
.type md2asm_ftcontroller_fsc,%function
md2asm_ftcontroller_fsc:
 b __fsc_mod_MOD_fsc
.size md2asm_ftcontroller_fsc,.-md2asm_ftcontroller_fsc
.global md2asm_gwdragwms_layer
.type md2asm_gwdragwms_layer,%function
md2asm_gwdragwms_layer:
 b gwdragwms_layer_
.size md2asm_gwdragwms_layer,.-md2asm_gwdragwms_layer
.global md2asm_gwprofil_drag_child
.type md2asm_gwprofil_drag_child,%function
md2asm_gwprofil_drag_child:
 b gwprofil_
.size md2asm_gwprofil_drag_child,.-md2asm_gwprofil_drag_child
.global md2asm_gwsetup_drag_child
.type md2asm_gwsetup_drag_child,%function
md2asm_gwsetup_drag_child:
 b md2asm_gwsetup
.size md2asm_gwsetup_drag_child,.-md2asm_gwsetup_drag_child
.global md2asm_lagged_grid_update_private_entry
.type md2asm_lagged_grid_update_private_entry,%function
md2asm_lagged_grid_update_private_entry:
 b cpglag_
.size md2asm_lagged_grid_update_private_entry,.-md2asm_lagged_grid_update_private_entry
.global md2asm_layer_radheatn_7358525
.type md2asm_layer_radheatn_7358525,%function
md2asm_layer_radheatn_7358525:
 b radheatn_
.size md2asm_layer_radheatn_7358525,.-md2asm_layer_radheatn_7358525
.global md2asm_outer_decorrelation
.type md2asm_outer_decorrelation,%function
md2asm_outer_decorrelation:
 b cloud_overlap_decorr_len_
.size md2asm_outer_decorrelation,.-md2asm_outer_decorrelation
.global md2asm_outer_gas_set
.type md2asm_outer_gas_set,%function
md2asm_outer_gas_set:
 b __radiation_gas_MOD_set_units_gas
.size md2asm_outer_gas_set,.-md2asm_outer_gas_set
.global md2asm_outer_ice_radius
.type md2asm_outer_ice_radius,%function
md2asm_outer_ice_radius:
 b ice_effective_radius_
.size md2asm_outer_ice_radius,.-md2asm_outer_ice_radius
.global md2asm_outer_inner_child_count_get
.type md2asm_outer_inner_child_count_get,%function
md2asm_outer_inner_child_count_get:
 b md2asm_radiation_column_child_count_get
.size md2asm_outer_inner_child_count_get,.-md2asm_outer_inner_child_count_get
.global md2asm_outer_inner_radiation
.type md2asm_outer_inner_radiation,%function
md2asm_outer_inner_radiation:
 b md2asm_radiation_column_physics
.size md2asm_outer_inner_radiation,.-md2asm_outer_inner_radiation
.global md2asm_outer_layer_mass
.type md2asm_outer_layer_mass,%function
md2asm_outer_layer_mass:
 b md2asm_openifs_get_layer_mass
.size md2asm_outer_layer_mass,.-md2asm_outer_layer_mass
.global md2asm_outer_liquid_radius
.type md2asm_outer_liquid_radius,%function
md2asm_outer_liquid_radius:
 b liquid_effective_radius_
.size md2asm_outer_liquid_radius,.-md2asm_outer_liquid_radius
.global md2asm_outer_overlap
.type md2asm_outer_overlap,%function
md2asm_outer_overlap:
 b __radiation_cloud_MOD_set_overlap_param
.size md2asm_outer_overlap,.-md2asm_outer_overlap
.global md2asm_outer_satur
.type md2asm_outer_satur,%function
md2asm_outer_satur:
 b satur_
.size md2asm_outer_satur,.-md2asm_outer_satur
.global md2asm_post_surface_update_7358525
.type md2asm_post_surface_update_7358525,%function
md2asm_post_surface_update_7358525:
 b cpspe_
.size md2asm_post_surface_update_7358525,.-md2asm_post_surface_update_7358525
.section .note.GNU-stack,"",%progbits
