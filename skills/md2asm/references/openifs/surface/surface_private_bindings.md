# Published Surface Function Bindings

This packet makes the accepted private surface function graph buildable from public assembly. It reuses each existing published numerical body through a transparent tail branch when that body has the same register and stack interface. These branches have no frame, storage, arithmetic or observation call. They preserve all incoming argument addresses and return directly from the same owned numerical child. Existing declared buffer limits and numerical contracts remain unchanged.

Two private surface radiation controller instances retain their separate child names through small preprocessor wrappers around the existing surfrad_ctl.S source. Two matching canopy-light instances use the existing canalb.S source and retain separate local activity-counter words. This preserves the accepted private call graph and counter storage without publishing another numerical source copy. Both controller families keep the existing four transparent child tail calls.

Four retained numerical bodies are now published: selected surface layer adapters, apparent soil energy support, surface exchange ABI adapter and surface postprocessing ABI adapter. The selected layer's small assembly includes preserve its declared field offsets. The layer source uses the accepted inactive-Stokes R8 route, with its ITRAC pointer dereference and source sentinel view helper. Its successful instruction source equals the selected guarded provider; diagnostic failure stubs and their C report are not production dependencies. Source-unwritten, zero-consumed Stokes views remain inactive under the accepted physical predicate. No replacement numerical value is introduced.

All original source and saved-output evidence is reused. The focused publication gate assembles every new file, proves the four retained bodies' instruction, constant and relocation sections, checks each transparent tail's unique destination, and verifies the four preprocessor wrappers against their qualified private bodies. There is no new numerical suite or forecast execution. Root owns final publication, complete link and model comparison. All files in the public source map are Markdown or assembly; retained build tools and binary evidence stay local.

The added interfaces use the original GNU Fortran convention: x0 through x7 carry the first eight addresses, and later addresses occupy consecutive eight-byte words on the incoming stack. A descriptor is an array record containing its base address, element width, shape and stride. The caller supplies complete mapped scalar records, descriptors and active numerical owners, keeps them live through the call, and obeys each reused child's disjoint-range rules. These interfaces keep 16-byte stack alignment, x18, all required saved integer registers and the required halves of the saved floating-point registers. External math calls retain their existing canonical providers and every separate FP64 rounding point.

| New source | Interface and selected bounds | Private frame |
| --- | --- | ---: |
| selected_surface_layer_adapters.S | Surface boundary layer: 7 addresses; snow initialization layer: 6; turbulence layer: 18. Actual owned grid has 24 columns, 19 atmosphere levels, 4 soil layers, 5 snow layers and 9 tiles. The source-typed state and work records remain caller-owned. |16384, 16384, 32768 bytes |
| soil_energy_support.S | SRFENE: 13 addresses, 4 soil layers and the requested active column interval. Input temperatures are kelvin, layer depths metres, and output apparent soil energy joules per square metre. Land precedes ice and ocean exactly as in the source. |1024 bytes |
| surface_exchange_adapter.S | SURFEXCDRIVER: 131 addresses and hidden character length 1. It validates declared bounds and forwards unchanged arrays plus eight live surface parameter records to the owned controller. |4096 bytes |
| surface_postprocessing_adapter.S | SURFPP: 61 ordinary addresses. It retains original bounds and forwards unchanged descriptors plus live surface parameters to the owned weather-output child. |4096 bytes |

The selected surface record layout is owned by the accepted complete SUSURF parent. Its lifetime and parameter offsets stay fixed by that parent contract. GET_SURF is resolved by the owned metadata getter in the autonomous graph. No original registry or constructor supplies any new body. The inactive view helper retains the source markers `-99999` for an owner with one field and `-999999` for an owner with three fields, with both descriptor lower bounds equal to one. It preserves the computed source address only while the selected consumer reads zero payload bytes. That address can lie outside the payload and is not a mapped vector. For operational PCHARHQ, false LWCOUHMF in the owned constructor prevents the consumer's coupled read; this is a caller prerequisite, not a guard added to this helper. Ordinary selector bounds, active allocations and all numerical instructions are unchanged. The caller still supplies the complete mapped array descriptor and its live source owner.

The transparent private names and their existing owned destinations are listed below. A tail branch changes only instruction flow and keeps the original return address, so it adds no outgoing stack words or private storage.

| Private entry | Existing owned destination |
| --- | --- |
| md2asm_canalb_wrapper_child | md2asm_canalb_wrapper_body |
| md2asm_driver_asn | __srfsn_asn_mod_MOD_srfsn_asn |
| md2asm_driver_grid | __srfsn_vgrid_mod_MOD_srfsn_vgrid |
| md2asm_driver_regrid | __srfsn_regrid_mod_MOD_srfsn_regrid |
| md2asm_driver_rsn | __srfsn_rsn_mod_MOD_srfsn_rsn |
| md2asm_driver_ssrabs | __srfsn_ssrabs_mod_MOD_srfsn_ssrabs |
| md2asm_driver_webal | __srfsn_webal_mod_MOD_srfsn_webal |
| md2asm_layer_canalb_child | md2asm_layer_canalb_body |
| md2asm_layer_ctl_child | md2asm_layer_ctl_body |
| md2asm_ocean_skin_temperature_private_entry | md2asm_ocean_skin_temperature |
| md2asm_sea_ice_temperature_private_7358525 | __srfi_mod_MOD_srfi |
| md2asm_snow_mass_private_entry | md2asm_snow_mass_adjustment |
| md2asm_soil_column_private_entry | md2asm_soil_column_diffusion |
| md2asm_surface_energy_private_7358525 | __surfseb_ctl_mod_MOD_surfseb_ctl |
| md2asm_surface_evaporation_private_7358525 | __vevap_mod_MOD_vevap |
| md2asm_surface_interception_private_7358525 | __srfwl_mod_MOD_srfwl |
| md2asm_surface_soil_diffusion_private_7358525 | md2asm_soil_column_diffusion |
| md2asm_surface_soil_increment_private_7358525 | md2asm_soil_water_increment |
| md2asm_surface_water_correction_private_7358525 | __srfwng_mod_MOD_srfwng |
| md2asm_surfpp_ctl_7240564 | __surfpp_ctl_mod_MOD_surfpp_ctl |
| md2asm_surfrad_ctl_wrapper_child | md2asm_surfrad_ctl_wrapper_body |
| md2asm_surfseb_ctl_7240564 | __surfseb_ctl_mod_MOD_surfseb_ctl |
| md2asm_vdfdifh_7240564 | vdfdifh_ |
| md2asm_vdfdifm_7240564 | vdfdifm_ |
| md2asm_vdfdpbl_7240564 | vdfdpbl_ |
| md2asm_vdfexcu_7240564 | vdfexcu_ |
| md2asm_vdffblend_7240564 | vdffblend_ |
| md2asm_vdfhghtn_7240564 | vdfhghtn_ |
| md2asm_vdfincr_7240564 | vdfincr_ |
| md2asm_vdftofdc_7240564 | vdftofdc_ |

The publication build passes all four retained bodies and all four preprocessor wrappers with exact instruction and constant sections. Every relocation denotes the same section, byte offset or external symbol. The two local canopy counters retain separate data words; their symbol records now name the corresponding local data section directly, with the same address expression. All 30 tail entries have exactly one four-byte branch and the required destination. The actual complete extracted forecast graph links with this nine-object source-built archive replacing all four prior ignored surface archives, with no missing name or duplicate definition. No numerical or model run was performed for this mechanical publication change. The final full-forecast admission remains root's separate gate.
