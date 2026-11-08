# OpenIFS Forecast Sources

The CPU calculations are written in portable Fortran, and the compiler generates assembly and machine code for the selected processor. All 1,203 source roles have compiled Fortran replacements under the current scope, which omits eight retired private bootstrap diagnostic streams. The [selected bootstrap](input/standalone_bootstrap/README.md) describes the completed entry, and the [Fortran port record](../../skills/md2asm/references/openifs/portable_fortran_forecast_port.md) distinguishes compiled source from accepted numerical results. There are 471 component checks with limited accepted inputs. The current target is step 0 only: the reference step and its three saved files are complete, while comparison with the native Fortran remains pending.

The 1,203 old CPU assembly files are retained locally under .archive/openifs_assembly/, with their original relative paths and file identities. They are removed from the active source tree. GPU assembly and sources for other physical models are unchanged.

The historical assembly results below retain their earlier scope and do not establish acceptance of the new Fortran forecast. A routine body means one original function or subroutine, and each accepted historical body has independent critical checks and exact comparisons within its declared input range.

The coverage and complete autonomy checks below describe the Arm CPU forecast. The GPU extension has a separate acceptance record.

## Coverage

The table describes the audited coarse T21 global forecast. Its groups overlap and must not be added. The selected original-file forecast now has complete assembly ownership, while the broader inventories include unselected branches and configurations.

| Scope | Original bodies | Accepted assembly | Remaining |
| --- | ---: | ---: | ---: |
| Main forecast phase | 711 | 353 | 358 |
| Local calculations | 356 | 265 | 91 |
| Weather calculations | 255 | 255 | 0 |

There are 373 accepted original bodies overall, including VERDER outside the main forecast phase. Seven field-registry methods from the original template source are recorded separately from this inventory. Completing the weather list does not cover every model branch, setup routine or external dependency.

## Verification

The autonomous entry runs one direct forecast time loop with 25 direct time updates and writes each scheduled output once. Its separate original OpenIFS reference is used only for verification. Existing accepted component checks are reused. Final state and every saved file match exactly. This gate does not compare raw state after every step.

| Compared output | Complete scope | Differing bytes |
| --- | ---: | ---: |
| Final state with matched unused inputs | 685 buffer owners, 27,486,113 bytes | 0 |
| Saved forecast files | 10 files, 618,140 bytes | 0 |

A buffer owner is a complete retained array or record in model memory. The final-state gate compares its numerical bytes and checks its array layout. Existing rules describe address relationships without changing numerical values. A separate verification input revision matches 7,744 incoming bytes in source-unused table bands and final-block padding before the first forecast calculation. It preserves 2,368 earlier frozen bytes and assigns positive zero to 5,376 newly specified padding bytes. Complete before-and-after records confirm that the other 787,632 bytes in these twelve input owners remain unchanged. Every returned byte remains compared. The production forecast runs from original files without this verification initializer.

Both runs naturally return floating-point control zero, floating-point status 25 and system error value zero, without resets. Incoming status and five inactive optional arguments remain different and visible. Model-state and saved-file identity therefore do not establish whole-process identity. The assembly preserves its Arm application binary interface, or ABI, with an observed violation mask of zero. The original source's documented use of register x18 remains a separate source limit.

Two complete recorded call sets also pass exact replay. The cloud calculation matches all 2,150 calls across 561,408,000 complete buffer bytes. The lake calculation matches all 2,150 calls across 17,105,400 bytes. These checks include actual numerical status and the final partial block. They cover the original source calls through step 24 and retain raw unused storage. The [cloud contract](../../skills/md2asm/references/openifs/cloud_microphysics_contract.md) and [lake contract](../../skills/md2asm/references/openifs/surface/lake_temperature_profile.md) state their arithmetic and scientific limits.

## Reference and limits

The comparison uses a reviewed OpenIFS 48.1.1 reference with frozen inputs and arithmetic. Earlier reference versions and their different outputs remain local. Its essential qualifications are retained below.

| Reference area | Frozen qualification |
| --- | --- |
| Continuity | Assign positive zero to unused output slots while preserving every defined calculation. |
| Spectral and latitude transforms | Use independently checked matrix products with separate rounding after multiplication and addition. |
| Trajectory wind weights | Use the separately verified hyperbolic tangent function. |
| C4 leaf photosynthesis | Use physically valid equation roots and retain small carbon uptake in the canopy sum. |
| Radiation | Use fresh complete call pairs under the same runtime setup. An older cold replay has a recorded setup limit. |

The [numerical contracts](../../skills/md2asm/references/openifs/) define the supported branches, buffers, arithmetic and independent checks. A separate observer checks the humidity floor and finite ordered rates. Exact agreement can reproduce a shared scientific defect, so it does not establish independent physics of the whole forecast.

In a tested ice-formation call, the original lake update stores an average water temperature of 277.13 K, while its limited temperature profile can represent at most 276.334 K. The profile describes temperature changes with depth. The original lake equations remain unchanged. Complete forecast water and heat balances and whole-process byte identity remain unverified. The [README](../../README.md) reports matched complete-process timings with exact saved outputs.

## Autonomous Forecast

The [complete assembly entry](../../skills/md2asm/references/openifs/input/standalone_weather_forecast.md) owns loading, configuration, setup, storage, all selected OpenIFS forecast calculations, time updates and output. It constructs and releases its own model and field records. The selected T21 case starts on 15 October 2004 and advances 24 hours over 2,048 horizontal points and 19 atmospheric layers. Its production executable starts without `ifsMASTER`, `ifs-run`, `ifs_env`, original OpenIFS numerical bodies or verification wrappers.

External public services remain explicit, including ecCodes, ECTRANS, Atlas, NetCDF, linear algebra, mathematical functions, profiling and required runtimes. Assembly owns their arguments and call order. The [transform bindings](../../skills/md2asm/references/openifs/dynamics/inverse_legendre_reconstruction.md) keep callbacks on the accepted arithmetic route. The [direct power routine](../../skills/md2asm/references/openifs/support/power_original_rounding.md) replaces the earlier original C helper.

| Phase | Status |
| --- | --- |
| Autonomous selected forecast | Complete, with exact saved outputs, complete final-state comparison and the stated physical checks |
| Full 24-hour optimisation | In progress |
| Descriptive filename cleanup | Follows optimisation |

All 255 audited weather calculations are accepted. The broader inventory counts include other model paths and do not give an autonomy percentage for this selected configuration.

## Input And Setup Components

The assembly readers use the declared C ecCodes file-format library. A record contains one decoded field and its identifying labels. Separate controls check each stage, including malformed input, buffer bounds, final partial blocks and the Arm ABI. The original input files supply every decoded value. Storage-child counts follow the checked, fixed call sequence inside the enclosing context. This run directly observes 25 context constructions and releases, with 2,150 balanced block calls.

| Accepted component | Complete comparison scope | Contract |
| --- | --- | --- |
| Owned surface coupling diagnostics | Two setup pairs match 57393632 defined payload bytes and all 46 descriptor relations, with independent initial-value and allocation/release checks; production lifetime remains pending | [Diagnostic storage](../../skills/md2asm/references/openifs/setup/surface_coupling_diagnostics_storage.md) |
| Coupled surface flux accumulation | Six component pairs match 456432 complete payload bytes, with 1936 independent integral relations and before-write bounds checks; operational caller integration remains pending | [Surface flux totals](../../skills/md2asm/references/openifs/physics/coupled_surface_flux_accumulation.md) |
| Wave surface calculations | Ten source/native pairs match 47840 complete bytes with 1624 independent physical relations; complete caller integration remains pending | [Wave fields](../../skills/md2asm/references/openifs/physics/wave_surface_fields.md) |
| Typed wave field selection | Three source/native pairs match 232000 complete backing-array bytes, including 137 levels; 182 independent relations and thirteen before-write refusals pass | [Typed wave fields](../../skills/md2asm/references/openifs/physics/typed_wave_surface_fields.md) |
| Standalone selected initial state | Final-address MODEL and FIELDS, Geometry, 94 field owners and connected physics parameters match their source gates | [Attached initial state](../../skills/md2asm/references/openifs/input/owned_trajectory_initial_state.md) |
| Owned norm loop bindings | Spectral and grid-point calls use live caller-owned controls and exact complete diagnostic results | [Norm interfaces](../../skills/md2asm/references/openifs/dynamics/norm_loop_bindings.md) |
| Owned forecast controls and timers | All 15 selected schedule switches match the source, with three live times from public FIAT | [Schedule](../../skills/md2asm/references/openifs/setup/forecast_schedule_configuration.md) and [timers](../../skills/md2asm/references/openifs/support/forecast_timer_initialization.md) |
| Owned reporting bindings | Original call interfaces preserve complete context, formatted output and status from accepted direct utilities | [Reporting interfaces](../../skills/md2asm/references/openifs/output/execution_reporting_bindings.md) |
| Owned ozone and aerosol climate inputs | Original ozone and CAMS files load into source-exact owned records | [Ozone](../../skills/md2asm/references/openifs/radiation/ozone_climatology_setup.md) and [CAMS](../../skills/md2asm/references/openifs/radiation/cams_climatology_setup.md) |
| Owned ecRad configuration | Complete selected setup, gas maps and optical inputs agree with the source | [ecRad setup](../../skills/md2asm/references/openifs/radiation/ecrad_configuration.md) |
| Owned TEGEN climatology | Source tables, seven arrays and shared storage agree with the source | [TEGEN setup](../../skills/md2asm/references/openifs/radiation/tegen_aerosol_setup.md) |
| Owned cloud-overlap setup | Complete selected profile matches all checked source bytes and 301 independent linear relations | [Overlap profile](../../skills/md2asm/references/openifs/radiation/cloud_overlap_setup.md) |
| Owned loop data and filter storage | Source checks cover serial controls, four filter buffers, all 28 dynamics maps, live atmosphere values and selected physics data | [Loop data](../../skills/md2asm/references/openifs/setup/loop_data_bindings.md), [Process binding](../../skills/md2asm/references/openifs/setup/loop_process_bindings.md), [Atmosphere and maps](../../skills/md2asm/references/openifs/setup/atmosphere_dynamics_data_bindings.md), [Physics data](../../skills/md2asm/references/openifs/setup/physics_runtime_data_bindings.md) |
| Forecast input and static data | Live header values, 22 selected control values and the complete I/O-server record match focused source checks | [Input bindings](../../skills/md2asm/references/openifs/runtime/initial_input_data_bindings.md), [control values](../../skills/md2asm/references/openifs/setup/forecast_scalar_data.md), [I/O state](../../skills/md2asm/references/openifs/setup/io_server_namespace.md) |
| Fresh-start continuation | Five real forcing buffers, separate clock updates and the second spectral norm call follow source order | [Fresh preparation](../../skills/md2asm/references/openifs/setup/fresh_forecast_continuation.md), [initialization tail](../../skills/md2asm/references/openifs/runtime/post_csta_continuation.md) |
| Complete selected output setup | Whole constructor matches 1,046,504 bytes across 23 owned buffers, with checked cleanup and allocation failures | [Output constructor](../../skills/md2asm/references/openifs/setup/complete_fullpos_setup.md) |
| Distributed GRIB file writers | Nine assembly sources match complete files and saved state across 3,346,076 bytes at one and four processes. Operational output and forecast remain pending | [File writers](../../skills/md2asm/references/openifs/output/runtime_fullpos_file_writers.md) |
| Owned output distribution | Complete serial grid partition matches three source profiles and all three storage owners | [Output blocks](../../skills/md2asm/references/openifs/fullpos/fullpos_distribution_setup.md) |
| Owned output configuration | Selected GRIB naming, stream dimensions and output schedules match the original source | [GRIB setup](../../skills/md2asm/references/openifs/fullpos/fullpos_grib_setup.md), [schedules](../../skills/md2asm/references/openifs/fullpos/fullpos_output_control_setup.md) |
| Owned shortwave input and reduction | Complete selected SRTM_INIT matches 4,059,736 bytes across 213 typed fields | [Shortwave input](../../skills/md2asm/references/openifs/radiation/shortwave_absorption_setup.md) |
| Owned shortwave auxiliary tables | Complete transmission, aerosol and cloud tables match all 86,752 source bytes | [Shortwave tables](../../skills/md2asm/references/openifs/radiation/shortwave_auxiliary_setup.md) |
| Owned output vertical setup | Selected SUFPV and SUFPVERT match complete records and all eight coordinate owners | [Output coordinates](../../skills/md2asm/references/openifs/fullpos/fullpos_vertical_setup.md) |
| Owned empty trajectory | Six owners and shared time-level descriptions, with runtime block counts 128, 129 and 257 checked, exact native storage and an explicit source representation limit | [Trajectory storage](../../skills/md2asm/references/openifs/setup/empty_trajectory_state.md), [runtime storage](../../skills/md2asm/references/openifs/setup/runtime_empty_trajectory_state.md) |
| Owned original longwave input | Assembly reads RADRRTM and constructs all 143 typed original-band arrays, matching 3,148,928 bytes | [Longwave input](../../skills/md2asm/references/openifs/radiation/longwave_absorption_inputs.md) |
| Owned longwave reduction | All 16 band reductions and common tables match 1,229,352 bytes, preserving source-unwritten storage | [Longwave reduction](../../skills/md2asm/references/openifs/radiation/longwave_gpoint_reduction.md) |
| Owned aerosol distributions | Four complete numerical children and nine earlier allocations match source order and complete records | [Aerosol distributions](../../skills/md2asm/references/openifs/radiation/aerosol_distribution_setup.md) |
| Owned selected spectral norms | Qualified wave and mean reductions use explicit owned state and a shared divergence-reporting value | [Spectral norms](../../skills/md2asm/references/openifs/dynamics/selected_spectral_norms.md) |
| Owned diagnostic flux configuration | Two complete source profiles match all initialized and released TCFU, TXFU and TMCUF bytes, including two empty owners | [Flux configuration](../../skills/md2asm/references/openifs/setup/selected_flux_configuration.md) |
| Owned selected aerosol parameters | Complete selected SU_AERW and its two active children match 581,388 bytes | [Aerosol parameters](../../skills/md2asm/references/openifs/radiation/selected_aerosol_setup.md) |
| Selected disabled physics controls | Cellular and stochastic setup retain complete source records and arithmetic, with checked bounds and preserved other bytes | [Cellular controls](../../skills/md2asm/references/openifs/setup/inactive_convective_cellular_controls.md), [stochastic controls](../../skills/md2asm/references/openifs/setup/disabled_stochastic_physics_setup.md), [Live forwarding](../../skills/md2asm/references/openifs/setup/live_disabled_stochastic_physics_forwarding.md), [inactive pattern records and empty grids](../../skills/md2asm/references/openifs/setup/disabled_stochastic_pattern_setup.md) |
| Owned ECMWF physics tail | Selected wave, linearized-physics and methane setup matches 5,392 complete bytes | [Physics tail](../../skills/md2asm/references/openifs/setup/ecmwf_physics_tail.md) |
| Owned longwave reference setup | Complete SURDI, SURRTAB, SURRTPK and SURRTRF match 205,200 source bytes, with live gas forwarding and one shared table owner | [Longwave setup](../../skills/md2asm/references/openifs/radiation/longwave_reference_setup.md), [runtime forwarding](../../skills/md2asm/references/openifs/setup/runtime_longwave_reference_owner_forwarding.md) |
| Owned spectral radiation tables | Complete SULWN and selected SUSWN match 61,224 created bytes and all released records, with six MODEL forwarding and lifetime checks | [Band tables](../../skills/md2asm/references/openifs/radiation/band_radiation_setup.md), [Runtime owners](../../skills/md2asm/references/openifs/setup/runtime_band_radiation_owner_forwarding.md) |
| Owned initial virtual temperature | Complete selected SPECRT matches 2,748,656 field bytes through public ECTRANS transforms and direct mixture arithmetic | [Initial temperature](../../skills/md2asm/references/openifs/input/initial_virtual_temperature_conversion.md) |
| Owned next-time field storage | Fresh, repeated and mixed owner states match complete source records and arrays, with source-defined zero initialization | [Next-time storage](../../skills/md2asm/references/openifs/setup/next_time_field_storage.md) |
| Owned ECMWF physics working fields | Three complete source shapes match 4,224 metadata bytes and 3,568,048 zeroed numerical bytes across six owners | [Physics field storage](../../skills/md2asm/references/openifs/setup/ecmwf_physics_field_storage.md) |
| Runtime input shapes | Reader, storage and placement children pass two small grids and layer counts, with exact fields, metadata and mapped model buffers | [Upper-air reader](../../skills/md2asm/references/openifs/input/runtime_initial_upper_air_field_reader.md), [field storage](../../skills/md2asm/references/openifs/setup/runtime_distributed_gridpoint_field_storage.md), [partitioned placement](../../skills/md2asm/references/openifs/input/runtime_partitioned_upper_air_placement.md) |
| Actual operational ownership | Four ranks pass association with 87 arrays, exact context publication, normal release and the isolated fatal setup policy | [Owner lifetime](../../skills/md2asm/references/openifs/input/operational_registry_owner_lease.md), [CALLPAR context](../../skills/md2asm/references/openifs/support/runtime_callpar_context_lease.md) |
| Owned grid-point and surface allocations | Four tracer owners and 34 surface owners, with exact complete-record checks | [Grid-point storage](../../skills/md2asm/references/openifs/setup/grid_point_field_storage.md), [surface storage](../../skills/md2asm/references/openifs/setup/surface_field_storage.md) |
| Owned surface group initialization | Complete group and field records, including inactive zero-layer groups | [Group initialization](../../skills/md2asm/references/openifs/setup/surface_group_initialization.md) |
| Owned surface field registration | All 32 optional-input combinations and complete trajectory records | [Field registration](../../skills/md2asm/references/openifs/setup/surface_field_registration.md) |
| Owned layered surface field registration | All 32 optional-input combinations, complete allocated arrays and paired release | [Layered registration](../../skills/md2asm/references/openifs/setup/layered_surface_field_registration.md) |
| Owned surface group finalization | Complete field indices and totals for both group kinds and all time-level choices | [Group finalization](../../skills/md2asm/references/openifs/setup/surface_group_finalization.md) |
| Owned complete vertical setup | Three complete SUVERT cases match all 28 numerical owners and metadata | [Vertical setup](../../skills/md2asm/references/openifs/setup/owned_vertical_system_contract.md) |
| Owned complete Geometry continuation | Two full source profiles match 2,312,192 bytes across new horizontal arrays and metadata, while all 28 vertical owners stay unchanged | [Complete Geometry](../../skills/md2asm/references/openifs/setup/owned_geometry_system.md), [stream copies](../../skills/md2asm/references/openifs/setup/stream_geometry_values.md) |
| Owned terrain-array storage | 86 block records and 258 arrays retain the source physical extents, including the last eight points | [Orography storage](../../skills/md2asm/references/openifs/setup/orography_owner_storage.md) |
| Owned spectral geometry maps | Thirty source cases match complete map owners and records, with independent high-precision checks | [Spectral maps](../../skills/md2asm/references/openifs/setup/spectral_geometry_maps.md) |
| Owned transform setup controls | Three complete composed source profiles match 53,760 bytes and natural returned status | [Owned transform setup](../../skills/md2asm/references/openifs/setup/owned_transform_setup_contract.md) |
| Owned serial partition maps and transform interfaces | Complete 36-owner source comparison and live external transform setup/query checks | [Partition maps](../../skills/md2asm/references/openifs/setup/serial_partition_map_contract.md), [global cutoffs](../../skills/md2asm/references/openifs/setup/global_grid_cutoff_contract.md) |
| Runtime process configuration and factors | Exact selected input parsing and factor selection from live process and thread counts, including source defaults and the requested 768-process layout | [Configuration](../../skills/md2asm/references/openifs/setup/runtime_process_configuration.md), [Process factors](../../skills/md2asm/references/openifs/setup/runtime_process_partition_factors.md) |
| Owned serial partition allocations | All 34 owners and complete metadata match the original allocation stages | [Partition storage](../../skills/md2asm/references/openifs/setup/partition_array_storage.md) |
| Owned complete surface startup | Two complete source cases match 18,696,912 bytes across 104 owners, with matched incoming storage | [Surface startup](../../skills/md2asm/references/openifs/setup/owned_surface_state_startup.md), [state stream](../../skills/md2asm/references/openifs/output/surface_state_stream_writing.md) |
| Owned complete surface metadata | Two complete source cases match 4,397,520 bytes across 70 owners | [Surface configuration](../../skills/md2asm/references/openifs/setup/selected_surface_configuration.md) |
| Owned complete grid-field configuration | Three complete original setup cases match all 4,077,408 namespace bytes | [Grid-field configuration](../../skills/md2asm/references/openifs/setup/selected_grid_field_configuration.md) |
| Owned selected forecast controls | Four complete source cases match 206,048 bytes across 108 named controls, all 13 schedules and the connected clock | [Forecast controls](../../skills/md2asm/references/openifs/setup/selected_forecast_controls.md) |
| Owned complete surface parameters | Complete SUSURF and SUSURF_CTL match 27,436 source bytes across the object, globals and 79 numerical owners | [Surface parameters](../../skills/md2asm/references/openifs/setup/complete_surface_parameter_setup.md) |
| Owned surface radiation parameters | Three complete SUSRAD and SURWN cases match 13,944 bytes, retaining source-unwritten tails | [Surface radiation](../../skills/md2asm/references/openifs/setup/surface_radiation_parameter_setup.md) |
| Complete owned physics setup | All selected source-order SUPHEC children and live surface/thermal state match 34,471,264 bytes | [Complete physics](../../skills/md2asm/references/openifs/setup/ecmwf_physics_setup.md) |
| Complete owned radiation setup | Original coefficient and climate inputs, all selected children and owner release match 30,160,836 bytes | [Complete radiation](../../skills/md2asm/references/openifs/radiation/selected_radiation_setup.md) |
| Owned radiation control and flux-storage stages | Three control profiles and three allocation profiles match complete source records and all 21 flux owners | [Radiation stages](../../skills/md2asm/references/openifs/radiation/radiation_control_setup.md) |
| Owned cloud optical parameters | Source checks cover 19, 31 and 137 layers, complete records and the qualified physical curves | [Cloud optics](../../skills/md2asm/references/openifs/setup/cloud_optical_parameter_setup.md), [runtime layers](../../skills/md2asm/references/openifs/setup/runtime_cloud_optical_parameter_setup.md), [live-owner forwarding](../../skills/md2asm/references/openifs/setup/runtime_cloud_optical_owner_forwarding.md) |
| Owned spectral Planck lookup | Four complete two-band cases match 1,952 bytes with independent blackbody-energy checks | [Planck lookup](../../skills/md2asm/references/openifs/radiation/spectral_planck_lookup.md) |
| Owned selected Meteo-France physics setup | The complete SUPHMF parent matches 28,416 parameter and scalar bytes at final MODEL addresses | [Selected physics setup](../../skills/md2asm/references/openifs/setup/meteo_france_physics_setup.md) |
| Owned physical constant names | 65 original names refer to the existing complete physical-constant producer, with no copied state | [Constant names](../../skills/md2asm/references/openifs/setup/physical_constant_aliases.md) |
| Owned forecast control names | 116 original names refer to existing control and clock bytes, with no copied state or new calculations | [Control names](../../skills/md2asm/references/openifs/setup/forecast_control_aliases.md) |
| Owned convection parameters | Three complete SUCUMF/SUCUMF2 profiles match 1,860 bytes, including source thermal transitions and retained threshold words | [Convection parameters](../../skills/md2asm/references/openifs/setup/convection_parameter_setup.md) |
| Owned physics time and cloud-level controls | Four complete SUPHY2 cases match 640 bytes, including live transition levels 10 and 14 and exact threshold ties | [Physics time controls](../../skills/md2asm/references/openifs/setup/physics_time_controls.md) |
| Owned field-container attachment | Three complete container records and 63 new arrays match 3,729,391 source bytes | [Container lifetime](../../skills/md2asm/references/openifs/setup/field_container_attachment.md) |
| Owned live field maps | Three complete source profiles match 504,000 bytes from live records | [Contract](../../skills/md2asm/references/openifs/setup/live_field_maps.md) |
| Owned field membership | Complete source membership cases match 151,212 bytes | [Contract](../../skills/md2asm/references/openifs/setup/field_membership.md) |
| Owned photosynthesis setup | Complete carbon-assimilation and Farquhar setup matches 37,084 bytes across 41 owners, with the accepted EXP binding | [Photosynthesis setup](../../skills/md2asm/references/openifs/setup/photosynthesis_parameter_setup.md) |
| Owned surface optimisation parameters | Three complete SUOPTSURF cases match 17,280 bytes across eighteen array owners | [Contract](../../skills/md2asm/references/openifs/setup/surface_optimization_parameters.md) |
| Owned main field metadata | Three complete 4,200-record namespaces match 2,318,400 bytes with live physical attributes | [Field metadata](../../skills/md2asm/references/openifs/setup/field_namespace_metadata.md) |
| Owned alternative physics parameters | Three complete SUPARAR profiles match 2,712 bytes with exact literal kinds and logarithm binding | [Contract](../../skills/md2asm/references/openifs/setup/alternative_physics_parameters.md) |
| Owned land reference parameters | Both VAL923 choices match all 544 named scalar bytes, with 36 owned global aliases | [Contract](../../skills/md2asm/references/openifs/setup/land_surface_reference_parameters.md) |
| Owned atmospheric physics parameters | Six complete SUPHY0 records match 20,736 bytes, including retained fields and ordered turbulence arithmetic | [Atmospheric parameters](../../skills/md2asm/references/openifs/setup/atmospheric_physics_parameters.md) |
| Owned upper-atmosphere controls | Complete SUTOPH, SUNORGWD and SUCAPE cases match 2,064 bytes, with exact pressure and coefficient ties | [Upper-atmosphere setup](../../skills/md2asm/references/openifs/setup/upper_atmosphere_setup.md) |
| Owned legacy radiation parameters | Three complete SUPHY3 cases match 16,128 bytes, including all 270 literal stores and retained fields | [Legacy radiation parameters](../../skills/md2asm/references/openifs/setup/legacy_radiation_parameters.md) |
| Owned radiation forcing and filenames | Eight complete gas and solar updates match 1408 bytes through an assembly-owned forecast caller, and thirteen filename cases match 34,320 bytes | [Forcing](../../skills/md2asm/references/openifs/radiation/owned_radiation_forcing.md), [Caller](../../skills/md2asm/references/openifs/radiation/forcing_caller_binding.md), [File selection](../../skills/md2asm/references/openifs/radiation/radiation_climate_files.md) |
| Owned spectral Planck tables | Three source construction cases match 10,452 bytes, with independent thermal-energy and band-integral checks | [Planck setup](../../skills/md2asm/references/openifs/radiation/spectral_planck_setup.md) |
| Owned radiation climate inputs | Four records and all 32 owners match two complete source cases, including 5,621,016 numerical bytes per case | [Radiation climate input](../../skills/md2asm/references/openifs/radiation/radiation_climate_inputs.md) |
| Owned prognostic-cloud parameters | Three complete SUCLDP cases match 8,328 bytes, with independent beta/gamma accuracy and parameter checks | [Prognostic-cloud setup](../../skills/md2asm/references/openifs/setup/prognostic_cloud_parameter_setup.md) |
| Owned cloud and gravity-wave parameters | Three complete source profiles match 2,040 bytes, including the allocated cloud profile | [Cloud and gravity-wave setup](../../skills/md2asm/references/openifs/setup/cloud_gravity_wave_setup.md) |
| Owned dynamical configuration | Four complete SUDYNCORE cases match 1,280 bytes, with 43 owned scalar aliases and preserved unwritten fields | [Dynamical configuration](../../skills/md2asm/references/openifs/setup/dynamical_configuration.md) |
| Owned selected dynamics controls | Three complete original setup cases match all 1,368 record bytes and embedded field maps | [Dynamics controls](../../skills/md2asm/references/openifs/setup/selected_dynamics_controls.md) |
| Owned urban parameter setup | Three complete SUSURB records match 1,416 bytes, with the original inactive radiation-constant limit retained | [Urban setup](../../skills/md2asm/references/openifs/setup/urban_surface_parameter_setup.md) |
| Owned soil, vegetation and exchange setup | Complete source cases match 20,784 bytes, including all 35 owners, with independent soil and root checks | [Land parameters](../../skills/md2asm/references/openifs/setup/surface_land_parameters.md) |
| Owned surface constant family | Complete SUSCST, SUSTHF, SUVEXCS and SUSFLAKE match 10,000 source bytes, with independent physical checks | [Surface and lake constants](../../skills/md2asm/references/openifs/setup/surface_constant_family.md) |
| Owned surface exchange parameters | Three complete SUPHY1 cases match 52,680 bytes, including soil and ozone tables | [Surface exchange parameters](../../skills/md2asm/references/openifs/setup/surface_exchange_parameters.md) |
| Owned thermal and stability tables | Complete thermal and SUVDFS tables match 3,840 source bytes, with 816 independent thermal and spline checks | [Thermal and stability setup](../../skills/md2asm/references/openifs/setup/thermal_diffusion_parameter_setup.md) |
| Owned diffusion and condensation parameters | Three source cases per record match 264 bytes, with independent coefficient checks | [Diffusion parameters](../../skills/md2asm/references/openifs/setup/selected_diffusion_parameters.md), [condensation parameters](../../skills/md2asm/references/openifs/setup/condensation_parameters.md) |
| Runtime spectral diffusion fields | Six grid and layer cases pass 42 calls with exact output bytes and independent pressure-damping checks | [Runtime fields](../../skills/md2asm/references/openifs/setup/spectral_diffusion_setup.md#runtime-coefficient-and-storage-mode) |
| Owned complete selected physics configuration | Six whole SU0PHY cases match 45,792 record bytes and 120 count bytes | [Physics configuration](../../skills/md2asm/references/openifs/setup/selected_physics_configuration.md) |
| Owned selected physics controls | Six complete original setup cases match all 2,808 record and count bytes | [Physics controls](../../skills/md2asm/references/openifs/setup/selected_physics_controls.md) |
| Owned physical constants | All 64 values match 512 genuine source bytes, with independent physical identities | [Constant setup](../../skills/md2asm/references/openifs/setup/physical_constant_setup.md) |
| Owned inactive startup controls | Complete SUNUD, SUMCC and SUTRAJP match 28,248 source bytes, with 7,584 declaration bytes checked separately | [Nudging and coupling controls](../../skills/md2asm/references/openifs/setup/inactive_startup_controls.md) |
| Owned grid-motion storage | Four complete source profiles match 18,720 record bytes and 11,400,432 payload bytes through construction, zeroing and release | [Grid-motion fields](../../skills/md2asm/references/openifs/setup/grid_motion_field_storage.md) |
| Owned field dimensions | Six complete SUDIMF1/SUDIMF2 cases match all 2,640 output bytes and retain source layer-count precedence | [Field dimensions](../../skills/md2asm/references/openifs/setup/field_dimension_setup.md) |
| Owned time-integration record | Three complete SURIP cases match 527,928 bytes, retaining all source-unwritten storage | [Time-integration configuration](../../skills/md2asm/references/openifs/setup/time_integration_configuration.md) |
| Owned clock fields | Six complete source-field cases and independent calendar checks | [Model clock](../../skills/md2asm/references/openifs/setup/model_clock_initialization.md) |
| Owned surface-input configuration | Complete 2,304-byte source record, including both 21-entry vegetation tables | [Owned surface configuration](../../skills/md2asm/references/openifs/input/owned_surface_input_configuration.md) |
| Upper-air decoding and placement | 76 records and 2,509,824 model bytes, including padding | [Upper-air loading](../../skills/md2asm/references/openifs/input/upper_air_initial_state_loading.md) |
| Surface decoding, selection and conversion | 140 records, with 52 selected fields in original order | [Surface loading](../../skills/md2asm/references/openifs/input/initial_surface_state_loading.md) |
| Surface placement | Five complete owners containing 2,146,560 bytes | [Surface placement](../../skills/md2asm/references/openifs/input/initial_surface_state_placement.md) |
| Physics grid dimensions | Complete 192-byte records and 25 initialization / 2,150 update calls | [Grid dimensions](../../skills/md2asm/references/openifs/support/physics_grid_dimensions.md) |
| Physics state storage | 200 initializations, 200 finalizations and 25 mask calls | [State storage](../../skills/md2asm/references/openifs/support/physics_state_storage.md) |
| Physics state block views | 17,200 calls with complete final-owner and saved-file agreement | [Block binding](../../skills/md2asm/references/openifs/support/physics_state_block_binding.md) |
| Field-variable arrays | 2,150 clone, update and reset calls with exact final states | [Private arrays](../../skills/md2asm/references/openifs/support/field_variable_arrays.md) |
| Physics work records | Each of three record types has 25 initializations, 2,150 view updates and 25 releases | [Auxiliary](../../skills/md2asm/references/openifs/support/auxiliary_physics_work_records.md), [radiation](../../skills/md2asm/references/openifs/support/radiation_physics_work_records.md), [surface](../../skills/md2asm/references/openifs/support/surface_physics_work_records.md) |
| Complete spherical geometry | One selected SUGEM2 setup and exact complete final owners | [Spherical geometry](../../skills/md2asm/references/openifs/setup/spherical_geometry_setup.md) |
| Complete physics-call context | 25 constructions and releases, 2,150 blocks and 4,300 tendency tables | [Construction](../../skills/md2asm/references/openifs/support/physics_context_construction.md), [block services](../../skills/md2asm/references/openifs/support/physics_context_block_services.md), [address services](../../skills/md2asm/references/openifs/support/physics_context_address_services.md) |
| Additional physics work records | 20 forecast-used methods and the selected perturbation views, including disabled cellular metadata | [Work records](../../skills/md2asm/references/openifs/support/additional_physics_work_records.md), [perturbation views](../../skills/md2asm/references/openifs/support/physics_perturbation_views.md), [Global owner](../../skills/md2asm/references/openifs/support/global_perturbation_storage_owner.md) |
| Local maps and standard atmosphere | One SUGEM3 and one complete selected SUSTA call | [Local maps](../../skills/md2asm/references/openifs/setup/local_geometry_maps.md), [standard atmosphere](../../skills/md2asm/references/openifs/setup/standard_atmosphere_native_entry.md) |
| Owned execution reporting | Twelve complete source calls match 1,082 diagnostic bytes, with genuine GNU and FIAT service checks | [Execution reporting](../../skills/md2asm/references/openifs/output/execution_progress_reporting.md) |
| Owned forecast progress listing | Four complete original/native lines match all 132 bytes with native ABI/status checks | [Step listing](../../skills/md2asm/references/openifs/support/forecast_step_listing.md) |
| Owned selected forecast runtime | Genuine simulation-index and inactive output-signal calls match state, ABI and status | [Runtime state](../../skills/md2asm/references/openifs/support/selected_forecast_runtime.md) |
| Scalar exponential | Exact complete forecast outputs through the direct original-name interface | [Exponential](../../skills/md2asm/references/openifs/support/scalar_exponential.md), [interface](../../skills/md2asm/references/openifs/support/exponential_native_binding.md) |
| Selected output metadata | All eight new routes execute, with 35 balanced request allocations and releases | [Read-only views](../../skills/md2asm/references/openifs/output/output_request_views.md), [release](../../skills/md2asm/references/openifs/output/output_request_release.md), [allocation](../../skills/md2asm/references/openifs/output/output_request_allocation.md), [auxiliary data](../../skills/md2asm/references/openifs/output/output_auxiliary_metadata.md) |
| Vertical configuration and coordinates | One configuration and default setup, with two distinct model/output coordinate owners | [Configuration](../../skills/md2asm/references/openifs/setup/vertical_coordinate_configuration.md), [storage](../../skills/md2asm/references/openifs/setup/hybrid_coordinate_storage.md), [defaults](../../skills/md2asm/references/openifs/setup/hybrid_coordinate_defaults.md) |
| Grid and trajectory dimensions | One selected call for each entry | [Grid dimensions](../../skills/md2asm/references/openifs/setup/grid_dimension_setup.md), [spherical configuration](../../skills/md2asm/references/openifs/setup/spherical_geometry_configuration.md), [trajectory dimensions](../../skills/md2asm/references/openifs/setup/trajectory_dimension_setup.md) |
| Live output preparation and scans | 15 preparations, 35 balanced scans and 10 balanced spectral/grid request lists | [Preparation](../../skills/md2asm/references/openifs/output/output_request_preparation.md), [parser](../../skills/md2asm/references/openifs/output/selected_output_namfpc.md), [scans](../../skills/md2asm/references/openifs/output/output_scan_metadata.md), [request lists](../../skills/md2asm/references/openifs/output/output_io_requests.md) |
| Output header and names | 15 headers and 45 names, with complete associated descriptors | [Headers](../../skills/md2asm/references/openifs/output/output_header_metadata.md), [names](../../skills/md2asm/references/openifs/output/output_file_names.md) |

The current [autonomous forecast contract](../../skills/md2asm/references/openifs/input/standalone_weather_forecast.md) describes assembly ownership from loading through output. The component records above show how each stage was checked.

## GPU extension

The PTX extension has 257 distinct component-qualified originals. Six complete ordinary forecasts with combined CPU/GPU assembly match all ten saved files and 59 final numerical views. The latest run also matches both complete model-history buffers across 1,882,368 bytes. The separate complete-owner GPU gate remains unfinished. The complete required-routine total and live GPU coverage remain under review. A full autonomous GPU numerical forecast and comparative timing are not yet accepted.

These recent contracts describe complete device stages and their declared limits. Parent and child entries overlap, so their counts must not be added.

| Calculation | GPU contract |
| --- | --- |
| Complete parcel transport | [Semi-Lagrangian transport](../../skills/md2asm-gpu/references/openifs/transport/semi_lagrangian_transport.md) |
| Vertical mixing | [Complete mixing](../../skills/md2asm-gpu/references/openifs/physics/vertical_mixing_main.md) |
| Mixing tendency increments | [Tendency update](../../skills/md2asm-gpu/references/openifs/physics/vertical_diffusion_tendencies.md) |
| Interpolation boundary layers | [Boundary values](../../skills/md2asm-gpu/references/openifs/dynamics/interpolation_boundary_values.md) |
| Gas profiles on pressure layers | [Gas interpolation](../../skills/md2asm-gpu/references/openifs/radiation/greenhouse_gas_interpolation.md) |
| Seasonal ozone | [Ozone coefficients](../../skills/md2asm-gpu/references/openifs/physics/seasonal_ozone_coefficients.md) |
| Ozone on model pressure layers | [Ozone mapping](../../skills/md2asm-gpu/references/openifs/radiation/ozone_pressure_layers.md) |
| Monthly pressure-weighted gas amounts | [Monthly layers](../../skills/md2asm-gpu/references/openifs/physics/monthly_gas_layer_amounts.md) |
| Complete convective downdraft | [Downdraft descent](../../skills/md2asm-gpu/references/openifs/physics/convective_downdraft_descent.md) |
| Complete greenhouse gas profiles | [Gas-profile parent](../../skills/md2asm-gpu/references/openifs/radiation/greenhouse_profile_parent.md) |
| Wind for parcel trajectories | [Trajectory wind](../../skills/md2asm-gpu/references/openifs/trajectories/trajectory_wind_preparation.md) |
| Complete convective cloud ascent | [Cloud ascent](../../skills/md2asm-gpu/references/openifs/physics/convective_cloud_ascent.md) |
| Complete monthly gas update | [Monthly update](../../skills/md2asm-gpu/references/openifs/physics/monthly_gas_update.md) |
| Complete monthly ozone update | [Ozone update](../../skills/md2asm-gpu/references/openifs/physics/monthly_ozone_update.md) |
| Complete Lagrangian Grid Update on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/dynamics/lagrangian_grid_update.md) |
| Complete Tracer Mass Correction on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/transport/tracer_mass_correction.md) |
| Complete Aerosol Climatology Preparation on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/radiation/aerosol_climatology_preparation.md) |
| Complete Monthly Aerosol Update on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/physics/monthly_aerosol_update.md) |
| Final Convective Fluxes on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/physics/convective_final_flux.md) |
| Convective Heat and Moisture Tendencies on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/physics/convective_heat_moisture.md) |
| Complete Slow-Physics Interval Controller on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/physics/physics_interval_controller.md) |
| Complete Convective Column Update on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/physics/convective_column_update.md) |
| Complete Model Clock and Forcing on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/physics/model_time_and_forcing.md) |
| Complete Radiation Grid on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/radiation/radiation_grid_parent.md) |
| Solar Zenith Geometry on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/physics/solar_zenith_geometry.md) |
| Methane Humidity Tendency On A GPU | [Contract](../../skills/md2asm-gpu/references/openifs/physics/methane_humidity_tendency.md) |
| Convective Cloud And Rain Diagnostics On A GPU | [Contract](../../skills/md2asm-gpu/references/openifs/physics/convective_cloud_rain_diagnostics.md) |
| Stratocumulus diffusion on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/convection/stratocumulus_diffusion.md) |
| Height wind interpolation on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/physics/height_wind_interpolation.md) |
| Quadratic pressure wind interpolation on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/physics/pressure_wind_quadratic.md) |
| Linear pressure wind interpolation on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/physics/pressure_wind_linear.md) |
| Complete pressure wind interpolation on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/physics/pressure_wind_interpolation.md) |
| Wind pressure brackets on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/physics/wind_pressure_brackets.md) |
| Pressure interpolation coordinates on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/physics/pressure_coordinates.md) |
| Convective energy and wind shear on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/physics/convective_wind_shear.md) |
| Convective Column Controller On A GPU | [Contract](../../skills/md2asm-gpu/references/openifs/convection/convective_column_controller.md) |
| Nitrogen decline on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/surface/nitrogen_decline.md) |
| Aerosol Visibility Extinction On A GPU | [Contract](../../skills/md2asm-gpu/references/openifs/radiation/aerosol_visibility_extinction.md) |
| Cloud Cover Diagnostics on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/physics/cloud_cover_diagnostics.md) |
| GPU Tropopause Level | [Contract](../../skills/md2asm-gpu/references/openifs/physics/tropopause_level.md) |
| Vegetation Evolution on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/surface/vegetation_evolution.md) |
| Soil Water Exchange on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/surface/soil_water_exchange.md) |
| Gravity-Wave Stress Profile on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/physics/gravity_wave_stress_profile.md) |
| Cloud and aerosol visibility on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/physics/cloud_aerosol_visibility.md) |
| Soil Temperature Step on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/surface/soil_temperature_step.md) |
| Private Supersaturation GPU Route | [Contract](../../skills/md2asm-gpu/references/openifs/physics/private_supersaturation_route.md) |
| Gravity-Wave Momentum Drag on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/physics/gravity_wave_momentum_drag.md) |
| Slow-Physics Averaging on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/physics/slow_physics_averaging.md) |
| RADACT Private Legendre Basis | [Contract](../../skills/md2asm-gpu/references/openifs/radiation/private_legendre_basis.md) |
| Lake Energy Profile Update on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/surface/lake_energy_profile_update.md) |
| Aerosol and Ozone Visibility Climatology on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/physics/aerosol_visibility_climatology.md) |
| Complete cloud weather diagnostics on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/physics/cloud_weather_diagnostics.md) |
| Snow Mass Adjustment on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/surface/snow_mass_adjustment.md) |
| Snow Warm Start on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/surface/snow_warm_start.md) |
| Multilayer Snow Driver on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/surface/multilayer_snow_driver.md) |
| Convective Energy Diagnostics on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/physics/convective_energy_diagnostics.md) |
| Climatological Aerosol Visibility Layer on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/physics/climatological_aerosol_visibility_layer.md) |
| Surface Boundary Adapter on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/surface/surface_boundary_adapter.md) |
| Surface Temperature Extrapolation on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/physics/surface_temperature_extrapolation.md) |
| Mean Sea Level Pressure on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/physics/mean_sea_level_pressure.md) |
| Complete Physics Diagnostics on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/physics/complete_physics_diagnostics.md) |
| Surface Tile Boundary on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/surface/surface_tile_boundary.md) |
| Complete surface radiation layer on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/surface/surface_radiation_layer.md) |
| Complete private urban canyon light on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/surface/private_canopy_light.md) |
| Private surface radiation controllers on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/surface/private_radiation_controller.md) |
| Bounded original-compatible tangent on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/support/bounded_tangent.md) |
| Radiation base-ten logarithm on the GPU | [Contract](../../skills/md2asm-gpu/references/openifs/support/radiation_base_ten_logarithm.md) |

## Local records

The exact ordered routine list, original source paths, build commands, critical checks and raw comparison records remain under ignored `.agents/` and `.runtime/` directories. The source audit covers 5,238 built Fortran bodies, including setup, input/output, support and disabled features. This total is not the number of weather routines that remain.

## Shared Coarse-Forecast Evidence

The routine-level acceptance tables refer to the combined coarse forecast in exclusive allocation 7240564 on nid010555. Their actual calls have zero differing bytes, and each table states the complete compared owners. All ten saved files match across 618,140 bytes. The accepted critical physics and interface checks are reused.

Those historical tables establish the declared routine domains and saved files. They did not establish whole-forecast physical verification, whole-process byte identity or comparative timing. The [current forecast status](../../README.md#openifs-forecasts) records subsequent evidence and its limits.
