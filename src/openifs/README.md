# OpenIFS Assembly

These direct assembly routines calculate atmospheric motion, heating, radiation and surface changes. They are grouped by physical theme. A routine body means one original function or subroutine. Each accepted body has independent critical checks and exact comparisons within its declared input range.

## Coverage

The table describes the audited coarse T21 global forecast. Its groups overlap and must not be added. The latest checkpoint adds six selected startup entries and complete selected output request preparation, scans and header metadata.

| Scope | Original bodies | Accepted assembly | Remaining |
| --- | ---: | ---: | ---: |
| Main forecast phase | 711 | 353 | 358 |
| Local calculations | 356 | 265 | 91 |
| Weather calculations | 255 | 255 | 0 |

There are 373 accepted original bodies overall, including VERDER outside the main forecast phase. Seven field-registry methods from the original template source are recorded separately from this inventory. Completing the weather list does not cover every model branch, setup routine or external dependency.

## Verification

The joint checkpoint uses one direct forecast time loop and 25 direct time updates. Its private update path writes each scheduled output once. Separate source and assembly forecasts start from the same binary inputs. Existing checks of unchanged children and completed numerical source-first/native stage pairs are reused. The 25 native update calls show completion; this gate does not compare raw state after every step.

| Compared output | Complete scope | Differing bytes |
| --- | ---: | ---: |
| Final state | 685 buffer owners, 27,486,113 bytes | 0 |
| Saved forecast files | 10 files, 618,140 bytes | 0 |
| Numerical status and step controls | 56 status bytes and 8 control bytes | 0 |

A buffer owner is a complete retained array or record in model memory. The final-state gate compares its numerical bytes and checks the recorded array layout. It applies the existing rules for address metadata without changing numerical values. The source archive fixes unused incoming storage before the first calculation. Both sea-ice albedo tables retain their 576 initialized bytes and bind their 768 unused bytes. The solar-fraction table retains 48 initialized bytes and binds 64 unused bytes. Each of the two terrain tables retains 16,384 initialized bytes and binds its 128-byte final-block tail. Four spherical-geometry tables each retain 16,384 initialized bytes and bind a 128-byte final-block tail. Source allocation and consumer bounds establish that these tails are unused. Complete before and after packets are retained, and every final byte remains compared. The status gate checks floating-point controls, exception flags and the system error value. The assembly also preserves the registers required by its application binary interface, or ABI. The original source's documented use of register x18 remains a separate source limit.

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

In a tested ice-formation call, the original lake update stores an average water temperature of 277.13 K, while its limited temperature profile can represent at most 276.334 K. The profile describes temperature changes with depth. The original lake equations remain unchanged. Complete forecast water and heat balances, whole-process byte identity and comparative forecast speed remain unverified.

The executable still uses OpenIFS Fortran for model startup, remaining setup, typed metadata and retained reference forwards. The [direct power routine](../../skills/md2asm/references/openifs/support/power_original_rounding.md) now replaces the frozen C power helper and passes this same complete forecast gate. Other declared numerical and runtime boundaries remain. It is not an autonomous assembly forecast. Autonomous input loading, initialisation, complete calculation ownership and output remain a separate phase.

The separate [standalone initial-state executable](../../skills/md2asm/references/openifs/input/owned_working_initial_state.md) reads the original GRIB files and live configuration through assembly. It constructs selected records at their final MODEL and FIELDS addresses, including live physics time controls, prognostic-cloud parameters and nine new working arrays. Complete source-state comparisons pass for both declared allocation policies. Permitted file-format, transform, mathematical and runtime services remain explicit, with no original OpenIFS library or harness. Remaining physics, field containers and controller integration are required before a full autonomous forecast.

## Remaining OpenIFS Autonomy Work

External libraries and their public interfaces may remain, including ecCodes, ECTRANS, ecRad, Atlas, FFT, BLAS, mathematical functions, FIAT and their required runtimes. Assembly must own the OpenIFS configuration, state, calculation sequence and original numerical bodies. Calling an original OpenIFS routine through a library remains an ownership gap.

| Area | Current state | Remaining work |
| --- | --- | --- |
| Initial files | Original GRIB loading, complete surface state and selected final-address initial records are verified from an assembly entry | Finish the remaining physics and working-state producers |
| Vertical setup and Geometry | Complete selected coordinates, maps, transform interfaces and orography owners are connected | Complete remaining caller progression and output-coordinate attachment |
| Model and fields | Final MODEL and FIELDS storage, 22 field owners and several complete parameter families are owned | Finish remaining consumed records, field containers and diagnostic flux state |
| Physics setup | Cloud, convection, exchange and stability components pass complete source comparisons | Complete radiation inputs, land parameters and their enclosing setup callers |
| Runtime and output | Direct loop, updates, metadata and writers pass the comparison forecast | Connect the complete owned state and remove remaining original forwards |
| Complete acceptance | The autonomous forecast has not run | Require exact complete outputs and independent whole-forecast physical checks before optimisation |

All 255 audited weather calculations are admitted. Remaining work lies in setup, ownership and complete forecast composition. Earlier bounded startup lists do not provide a current global count or an autonomy percentage. The separate 24-hour optimisation phase and filename cleanup have not started.

## Input And Setup Components

The assembly readers use the declared C ecCodes file-format library. A record contains one decoded field and its identifying labels. Separate controls check each stage, including malformed input, buffer bounds, final partial blocks and the Arm ABI. The original input files supply every decoded value. Storage-child counts follow the checked, fixed call sequence inside the enclosing context. This run directly observes 25 context constructions and releases, with 2,150 balanced block calls.

| Accepted component | Complete comparison scope | Contract |
| --- | --- | --- |
| Standalone complete selected initial state | Final-address MODEL and FIELDS, Geometry, 31 field owners and connected physics parameters match their source gates | [Owned working state](../../skills/md2asm/references/openifs/input/owned_working_initial_state.md) |
| Owned next-time field storage | Fresh, repeated and mixed owner states match complete source records and arrays, with source-defined zero initialization | [Next-time storage](../../skills/md2asm/references/openifs/setup/next_time_field_storage.md) |
| Owned ECMWF physics working fields | Three complete source shapes match 4,224 metadata bytes and 3,568,048 zeroed numerical bytes across six owners | [Physics field storage](../../skills/md2asm/references/openifs/setup/ecmwf_physics_field_storage.md) |
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
| Owned serial partition allocations | All 34 owners and complete metadata match the original allocation stages | [Partition storage](../../skills/md2asm/references/openifs/setup/partition_array_storage.md) |
| Owned complete surface startup | Two complete source cases match 18,696,912 bytes across 104 owners, with matched incoming storage | [Surface startup](../../skills/md2asm/references/openifs/setup/owned_surface_state_startup.md), [state stream](../../skills/md2asm/references/openifs/output/surface_state_stream_writing.md) |
| Owned complete surface metadata | Two complete source cases match 4,397,520 bytes across 70 owners | [Surface configuration](../../skills/md2asm/references/openifs/setup/selected_surface_configuration.md) |
| Owned complete grid-field configuration | Three complete original setup cases match all 4,077,408 namespace bytes | [Grid-field configuration](../../skills/md2asm/references/openifs/setup/selected_grid_field_configuration.md) |
| Owned selected forecast controls | Four complete source cases match 206,048 bytes across 108 named controls, all 13 schedules and the connected clock | [Forecast controls](../../skills/md2asm/references/openifs/setup/selected_forecast_controls.md) |
| Owned convection parameters | Three complete SUCUMF/SUCUMF2 profiles match 1,860 bytes, including source thermal transitions and retained threshold words | [Convection parameters](../../skills/md2asm/references/openifs/setup/convection_parameter_setup.md) |
| Owned physics time and cloud-level controls | Four complete SUPHY2 cases match 640 bytes, including live transition levels 10 and 14 and exact threshold ties | [Physics time controls](../../skills/md2asm/references/openifs/setup/physics_time_controls.md) |
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
| Owned radiation forcing and filenames | Eight complete gas and solar updates match 1,408 bytes, and thirteen filename cases match 34,320 bytes | [Forcing](../../skills/md2asm/references/openifs/radiation/owned_radiation_forcing.md), [File selection](../../skills/md2asm/references/openifs/radiation/radiation_climate_files.md) |
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
| Additional physics work records | 20 forecast-used methods and the selected perturbation views | [Work records](../../skills/md2asm/references/openifs/support/additional_physics_work_records.md), [perturbation views](../../skills/md2asm/references/openifs/support/physics_perturbation_views.md) |
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

The latest complete forecast uses the direct surface and upper-air loading routes. It also uses seven direct field-registry methods and direct serial Laplacian, Gaussian-latitude and spherical-grid setup. These routes pass the complete final-state and saved-file gate above. The [assembly surface startup stage](../../skills/md2asm/references/openifs/input/initial_surface_state_startup.md) now owns the earlier defaults across all allocated rows, with every one of 7,149,696 bytes in ten captured owners checked. The [surface metadata readers](../../skills/md2asm/references/openifs/input/initial_surface_metadata.md) and [upper-air metadata reader](../../skills/md2asm/references/openifs/input/upper_air_initial_metadata.md) now read existing initialized objects directly in assembly. Constructing those original objects remains separate work.

The [latitude geometry constructor](../../skills/md2asm/references/openifs/setup/latitude_geometry_setup.md) also passes this forecast. The [spectral packing fit](../../skills/md2asm/references/openifs/output/spectral_packing_fit.md) runs 120 times with 5,280 direct logarithm calls and exact saved files. The [direct GRIB writers](../../skills/md2asm/references/openifs/output/grib_field_writers.md) now write all 220 records and 618,140 bytes through assembly and the declared ecCodes format library. Their selected flush path also uses assembly. The complete physics-call context now creates, binds and releases its own storage through assembly. Standard-atmosphere setup and the selected output request, scan and header services also pass. Complete model-object construction and the remaining startup and runtime services still need assembly.

## Local records

The exact ordered routine list, original source paths, build commands, critical checks and raw comparison records remain under ignored `.agents/` and `.runtime/` directories. The source audit covers 5,238 built Fortran bodies, including setup, input/output, support and disabled features. This total is not the number of weather routines that remain.
