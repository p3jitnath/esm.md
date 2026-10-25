/* Contract: skills/md2asm/references/openifs/surface/surface_private_bindings.md. */
// Transparent Arm tail calls to the existing owned numerical bodies.
// No frame, mutation, arithmetic or observation callback.
.text
.p2align 2
.macro SURFACE_TAIL name,target
.global \name
.type \name,%function
\name: b \target
.size \name,.-\name
.endm
#if !defined(MD2ASM_SURFACE_TIME_PRIVATE_ENTRIES) && !defined(MD2ASM_TURBULENCE_BINDINGS_ONLY)
SURFACE_TAIL md2asm_canalb_wrapper_child,md2asm_canalb_wrapper_body
#endif
#if !defined(MD2ASM_TURBULENCE_BINDINGS_ONLY)
SURFACE_TAIL md2asm_driver_asn,__srfsn_asn_mod_MOD_srfsn_asn
#endif
#if !defined(MD2ASM_TURBULENCE_BINDINGS_ONLY)
SURFACE_TAIL md2asm_driver_grid,__srfsn_vgrid_mod_MOD_srfsn_vgrid
#endif
#if !defined(MD2ASM_TURBULENCE_BINDINGS_ONLY)
SURFACE_TAIL md2asm_driver_regrid,__srfsn_regrid_mod_MOD_srfsn_regrid
#endif
#if !defined(MD2ASM_TURBULENCE_BINDINGS_ONLY)
SURFACE_TAIL md2asm_driver_rsn,__srfsn_rsn_mod_MOD_srfsn_rsn
#endif
#if !defined(MD2ASM_TURBULENCE_BINDINGS_ONLY)
SURFACE_TAIL md2asm_driver_ssrabs,__srfsn_ssrabs_mod_MOD_srfsn_ssrabs
#endif
#if !defined(MD2ASM_TURBULENCE_BINDINGS_ONLY)
SURFACE_TAIL md2asm_driver_webal,__srfsn_webal_mod_MOD_srfsn_webal
#endif
#if !defined(MD2ASM_SURFACE_TIME_PRIVATE_ENTRIES) && !defined(MD2ASM_TURBULENCE_BINDINGS_ONLY)
SURFACE_TAIL md2asm_layer_canalb_child,md2asm_layer_canalb_body
#endif
#if !defined(MD2ASM_SURFACE_TIME_PRIVATE_ENTRIES) && !defined(MD2ASM_TURBULENCE_BINDINGS_ONLY)
SURFACE_TAIL md2asm_layer_ctl_child,md2asm_layer_ctl_body
#endif
#if !defined(MD2ASM_SURFACE_TIME_PRIVATE_ENTRIES)
SURFACE_TAIL md2asm_ocean_skin_temperature_private_entry,md2asm_ocean_skin_temperature
#endif
#if !defined(MD2ASM_TURBULENCE_BINDINGS_ONLY)
SURFACE_TAIL md2asm_sea_ice_temperature_private_7358525,__srfi_mod_MOD_srfi
#endif
#if !defined(MD2ASM_SURFACE_TIME_PRIVATE_ENTRIES) && !defined(MD2ASM_TURBULENCE_BINDINGS_ONLY)
SURFACE_TAIL md2asm_snow_mass_private_entry,md2asm_snow_mass_adjustment
#endif
#if !defined(MD2ASM_TURBULENCE_BINDINGS_ONLY)
SURFACE_TAIL md2asm_soil_column_private_entry,md2asm_soil_column_diffusion
#endif
#if !defined(MD2ASM_SURFACE_TIME_PRIVATE_ENTRIES)
SURFACE_TAIL md2asm_surface_energy_private_7358525,__surfseb_ctl_mod_MOD_surfseb_ctl
#endif
#if !defined(MD2ASM_SURFACE_TIME_PRIVATE_ENTRIES)
SURFACE_TAIL md2asm_surface_evaporation_private_7358525,__vevap_mod_MOD_vevap
#endif
#if !defined(MD2ASM_TURBULENCE_BINDINGS_ONLY)
SURFACE_TAIL md2asm_surface_interception_private_7358525,__srfwl_mod_MOD_srfwl
#endif
#if !defined(MD2ASM_TURBULENCE_BINDINGS_ONLY)
SURFACE_TAIL md2asm_surface_soil_diffusion_private_7358525,md2asm_soil_column_diffusion
#endif
#if !defined(MD2ASM_TURBULENCE_BINDINGS_ONLY)
SURFACE_TAIL md2asm_surface_soil_increment_private_7358525,md2asm_soil_water_increment
#endif
#if !defined(MD2ASM_TURBULENCE_BINDINGS_ONLY)
SURFACE_TAIL md2asm_surface_water_correction_private_7358525,__srfwng_mod_MOD_srfwng
#endif
#if !defined(MD2ASM_SURFACE_TIME_PRIVATE_ENTRIES)
SURFACE_TAIL md2asm_surfpp_ctl_7240564,__surfpp_ctl_mod_MOD_surfpp_ctl
#endif
#if !defined(MD2ASM_SURFACE_TIME_PRIVATE_ENTRIES) && !defined(MD2ASM_TURBULENCE_BINDINGS_ONLY)
SURFACE_TAIL md2asm_surfrad_ctl_wrapper_child,md2asm_surfrad_ctl_wrapper_body
#endif
#if !defined(MD2ASM_SURFACE_TIME_PRIVATE_ENTRIES)
SURFACE_TAIL md2asm_surfseb_ctl_7240564,__surfseb_ctl_mod_MOD_surfseb_ctl
#endif
#if !defined(MD2ASM_SURFACE_TIME_PRIVATE_ENTRIES)
SURFACE_TAIL md2asm_vdfdifh_7240564,vdfdifh_
#endif
#if !defined(MD2ASM_SURFACE_TIME_PRIVATE_ENTRIES)
SURFACE_TAIL md2asm_vdfdifm_7240564,vdfdifm_
#endif
#if !defined(MD2ASM_SURFACE_TIME_PRIVATE_ENTRIES)
SURFACE_TAIL md2asm_vdfdpbl_7240564,vdfdpbl_
#endif
#if !defined(MD2ASM_SURFACE_TIME_PRIVATE_ENTRIES)
SURFACE_TAIL md2asm_vdfexcu_7240564,vdfexcu_
#endif
#if !defined(MD2ASM_SURFACE_TIME_PRIVATE_ENTRIES)
SURFACE_TAIL md2asm_vdffblend_7240564,vdffblend_
#endif
#if !defined(MD2ASM_SURFACE_TIME_PRIVATE_ENTRIES)
SURFACE_TAIL md2asm_vdfhghtn_7240564,vdfhghtn_
#endif
#if !defined(MD2ASM_SURFACE_TIME_PRIVATE_ENTRIES)
SURFACE_TAIL md2asm_vdfincr_7240564,vdfincr_
#endif
#if !defined(MD2ASM_SURFACE_TIME_PRIVATE_ENTRIES)
SURFACE_TAIL md2asm_vdftofdc_7240564,vdftofdc_
#endif
#if !defined(MD2ASM_SURFACE_TIME_PRIVATE_ENTRIES) && !defined(MD2ASM_TURBULENCE_BINDINGS_ONLY)
SURFACE_TAIL md2asm_layer_updcal_child,md2asm_layer_updcal_body
#endif
#if !defined(MD2ASM_SURFACE_TIME_PRIVATE_ENTRIES) && !defined(MD2ASM_TURBULENCE_BINDINGS_ONLY)
SURFACE_TAIL md2asm_layer_icestate_child,md2asm_layer_icestate_body
#endif
#if !defined(MD2ASM_SURFACE_TIME_PRIVATE_ENTRIES) && !defined(MD2ASM_TURBULENCE_BINDINGS_ONLY)
SURFACE_TAIL md2asm_layer_surfrad_child,md2asm_layer_surfrad_body
#endif
.section .note.GNU-stack,"",%progbits
