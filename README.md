# esm.md

esm.md generates Arm assembly directly from physics and mathematics in Markdown. Assembly is the processor’s low-level instruction language. The models use ordered 64-bit floating-point calculations, with independent physical checks and exact output comparisons.

Start with the [short template](formulations/TEMPLATE.md), [shallow-water formulation](formulations/sw/2d_periodic.md) or [energy-balance formulation](formulations/ebm/budyko_sellers.md). The [md2asm skill](skills/md2asm/SKILL.md) supplies numerical methods, assembly interfaces, verification and optimisation guidance. Published files are Markdown and assembly. Comparison tools, language controls, data and poster drafts stay local. [AGENTS.md](AGENTS.md) defines the writing and development rules.

## CPU Solvers

These tables compare optimised solvers on one Neoverse V2 processor. Values are median million complete cell updates per second across twelve quiet-node runs. Higher is faster. An update advances every field in one cell through a full time step. All seven variants, including vanilla Fortran, Julia and compiled Python controls, pass physical checks and produce identical output bytes. Detailed controls and timing variation remain in the local research records.

### Shallow Water

The model follows water depth and horizontal flow over a flat bottom with periodic boundaries. Gravity produces waves from uneven depth. Each grid has the stated number of cells in both directions.

| Grid | Assembly | Fortran | Julia | Python |
| --- | ---: | ---: | ---: | ---: |
| 64² | 89.80 | 84.94 | 78.39 | 56.40 |
| 256² | 95.31 | 81.51 | 77.00 | 56.42 |
| 1024² | 82.66 | 72.23 | 70.77 | 52.61 |

### Budyko–Sellers Energy Balance

Each latitude band has one average temperature. The Sun’s radiation warms the surface, radiation cools it, and heat moves between neighbouring bands. The grid is the number of bands between the poles.

| Grid | Assembly | Fortran | Julia | Python |
| --- | ---: | ---: | ---: | ---: |
| 128 | 650.56 | 510.74 | 531.46 | 548.93 |
| 4096 | 599.68 | 498.27 | 509.81 | 493.75 |
| 65536 | 590.51 | 488.69 | 489.47 | 514.88 |

## GPU Solvers

The same models run on one NVIDIA GH200 GPU. The LLM emits PTX, NVIDIA’s virtual assembly language, and NVIDIA’s assembler creates machine code. The [GPU skill](skills/md2asm-gpu/SKILL.md) and [execution contract](skills/md2asm-gpu/references/gpu-contract.md) describe this route. Sources are [shallow water](src/sw/gpu/2d_rusanov_ssprk2.ptx) and [energy balance](src/ebm/gpu/budyko_sellers.ptx).

Rates are million complete cell updates per second, shown as the median [minimum–maximum] across twelve accepted repetitions on one quiet exclusive GPU. Water updates include all three fields, both stages and periodic boundaries. Energy-balance updates include both stages and pole boundaries.

| Shallow-Water Implementation | 64² Cells | 256² Cells | 1024² Cells |
| --- | ---: | ---: | ---: |
| Direct PTX assembly | 672.9 [669.9–673.9] | 5820.4 [5803.9–5843.5] | 8706.4 [8661.6–8724.8] |
| Fortran tuned | 538.8 [536.7–539.7] | 5495.3 [5472.7–5510.7] | 7951.1 [7890.2–7974.8] |
| Fortran vanilla | 319.5 [318.1–320.4] | 4000.2 [3990.6–4008.8] | 5809.1 [5804.8–5818.2] |
| Julia tuned | 515.5 [514.1–516.6] | 4917.5 [4900.9–4928.4] | 5782.1 [5757.8–5796.2] |
| Julia vanilla | 276.1 [275.7–277.2] | 3303.7 [3300.7–3317.6] | 5179.1 [5168.3–5193.8] |
| Python tuned | 473.3 [471.1–473.7] | 4179.4 [4160.8–4188.6] | 5181.7 [5157.8–5202.3] |
| Python vanilla | 269.6 [268.4–269.9] | 3060.8 [3042.9–3067.7] | 4423.0 [4387.7–4445.8] |

| Energy-Balance Implementation | 128 Bands | 4096 Bands | 65536 Bands |
| --- | ---: | ---: | ---: |
| Direct PTX assembly | 749.9 [740.2–753.5] | 5023.8 [4980.7–5048.2] | 62023.9 [61291.6–62281.8] |
| Fortran tuned | 518.9 [513.9–524.3] | 2058.0 [2052.1–2065.6] | 29312.8 [29227.8–29378.5] |
| Fortran vanilla | 15.7 [15.7–15.8] | 473.5 [471.6–475.8] | 7076.0 [7063.8–7096.7] |
| Julia tuned | 532.4 [530.3–536.3] | 2101.1 [2097.3–2107.4] | 29549.0 [29378.5–29667.7] |
| Julia vanilla | 16.2 [16.1–16.2] | 482.9 [482.1–484.4] | 7082.3 [7067.8–7101.7] |
| Python tuned | 492.0 [490.9–495.4] | 1862.1 [1860.0–1870.2] | 25329.1 [25296.1–25396.6] |
| Python vanilla | 15.5 [15.5–15.6] | 464.8 [464.4–466.4] | 6783.8 [6772.5–6810.3] |

The timer replays a prepared sequence of GPU launches. It excludes compilation, startup, allocation, transfers, graph construction and verification. Julia uses separate sequential processes on the same GPU. All seven variants pass physical, trajectory, boundary and buffer checks with zero differing output bytes. The water check has 34 scientific cases and energy balance has 28, including 1,000-step trajectories. These archived steady-computation rates are separate from complete-process forecast timings.

## OpenIFS Forecasts

The OpenIFS 48.1.1 work has two distinct scopes. The coarse autonomous CPU forecast has completed. The operational 9 km CPU forecast remains unverified. Component checks do not establish a complete operational forecast.

### Coarse CPU Forecast

The [autonomous forecast](skills/md2asm/references/openifs/input/standalone_weather_forecast.md) advances 24 hours from 15 October 2004 on 2,048 horizontal points and 19 atmospheric layers. Assembly owns loading, configuration, setup, storage, the time loop, weather calculations, state updates and output. It runs without original OpenIFS routines or its harness. Public file-format, transform, mathematical and runtime services remain explicit.

| Check | Coverage | Differing bytes |
| --- | --- | ---: |
| Radiation-field preparation | 6,400 complete calls | 0 |
| Plant photosynthesis | 6,450 complete C3/C4 calls | 0 |
| Interpolation boundaries | 2,150 complete calls | 0 |
| Fourier coefficient transfer | 352 complete field-count/latitude pairs | 0 |
| Spectral forecast step | 25 complete calls and seven direct stages | 0 |
| Complete final state | 685 buffers across 27,486,113 bytes | 0 |
| Saved forecast files | 10 files across 618,140 bytes | 0 |

The saved files match directly. The separate complete-state check matches incoming bytes in source-unused storage before comparing all 685 buffers. Production uses only the original input files. Physical checks cover humidity, finite spectral values, mean temperature and pressure, grid metadata and time schedules. Whole water and heat budgets remain unverified. See the [coverage record](src/openifs/README.md) for accepted domains and limits.

The accepted complete-process CPU median is **14.13 seconds**, with runs of 14.13, 14.11 and 14.13 seconds. The timer includes loading, setup, calculations and output. Both matched variants have eight available CPUs, eight cloud workers and eight shortwave workers, with other threaded services set to one thread. All timed runs preserve the ten saved files and 59 observed final fields. Performance on other forecast inputs remains unmeasured.

<details>

<summary>Matched CPU Optimisation Results</summary>

Each row is a separate matched batch of three runs per variant on a quiet exclusive Grace node. Times are median [minimum–maximum] seconds. Earlier rows use one pinned CPU. Worker comparisons give both variants the same four or eight available CPUs.

| Matched Change | Before (s) | After (s) | Speedup |
| --- | ---: | ---: | ---: |
| Compact exact arithmetic | 76.98 [76.64–83.88] | 37.75 [37.23–44.64] | 2.04× |
| Wider clears, status writes and grouped integer sequences | 37.47 [37.42–37.50] | 31.49 [31.19–31.64] | 1.19× |
| Bounded exact integers for widely separated terms | 31.15 [30.91–31.68] | 26.65 [26.58–26.70] | 1.17× |
| Four-cell reflection with eight-value exponentials | 22.48 [22.23–22.64] | 22.04 [21.63–22.43] | 1.020× |

The runtime setting `EC_PMON=0` disables hardware energy monitoring, making energy and power diagnostic columns zero. Weather calculations and canonical output files remain. Its contrast uses a rotated nine-run batch, with three runs per variant. The other contrasts use three alternating matched pairs with monitoring disabled for both variants.

| Matched Change | Before (s) | After (s) | Speedup |
| --- | ---: | ---: | ---: |
| Same solver, energy monitoring disabled | 22.11 [21.84–22.39] | 20.59 [20.58–20.61] | 1.074× |
| Bounded integer rounding and grouped polynomial seeds, monitoring disabled for both | 19.72 [19.71–19.73] | 19.32 [19.30–19.33] | 1.021× |
| Variable product remainders and zero identities, monitoring disabled for both | 19.31 [19.31–19.35] | 19.23 [19.23–19.23] | 1.004× |
| Grouped exponential seeds and logarithm polynomial updates, monitoring disabled for both | 19.24 [19.23–19.38] | 18.88 [18.88–18.89] | 1.019× |
| One to four cloud workers with private counters, monitoring disabled for both | 18.90 [18.87–18.99] | 17.92 [17.91–17.93] | 1.055× |
| Four to eight cloud workers, monitoring disabled for both | 17.94 [17.93–17.98] | 17.77 [17.75–17.77] | 1.010× |
| Carried pressure intervals and independent ordered sums, monitoring disabled for both | 17.77 [17.76–17.78] | 17.32 [17.32–17.37] | 1.026× |
| Complete shortwave column team, monitoring disabled for both | 17.35 [17.34–17.61] | 14.24 [14.23–14.53] | 1.218× |
| Reused shortwave workspace and required copies, monitoring disabled for both | 14.28 [14.23–14.60] | 14.13 [14.11–14.13] | 1.011× |

</details>

### Coarse GPU Forecast

Six complete 24-hour runs use combined CPU/GPU assembly without the OpenIFS harness. Each matches all ten saved files across 618,140 bytes and 59 overlapping final views across 18,971,680 bytes. The latest also matches both complete model-history buffers across 1,882,368 bytes.

The latest complete GPU run finishes 25 steps in **464.19 seconds**, including input, setup and output. This single measurement is about 33 times the CPU median. Complete internal-state and counter checks remain pending for that image, so no GPU speedup is accepted. The [mathematical support](skills/md2asm-gpu/references/openifs/mathematical_support.md) and [assembly launcher](skills/md2asm-gpu/references/openifs/cuda_runtime.md) state its numerical and storage rules.

<details>

<summary>Accepted GPU Component Checks</summary>

| Component | Accepted scope |
| --- | --- |
| [Radiation input bounds](skills/md2asm-gpu/references/openifs/radiation/radiation_log_domain_batch.md) | Complete parent, first rejected value, saved registers and actual counters |
| [Radiation climatology](skills/md2asm-gpu/references/openifs/radiation/parallel_radiation_climatology.md) | Complete stage and recovery after a missing worker |
| [Atmospheric radiation columns](skills/md2asm-gpu/references/openifs/radiation/radiation_grid_parent.md) | Complete saved state, actual counters and serial recovery |
| [Surface radiation columns](skills/md2asm-gpu/references/openifs/surface/parallel_surface_radiation_columns.md) | Complete parent outputs, saved state and diagnostics |
| [Tile-fraction validation](skills/md2asm-gpu/references/openifs/radiation/surface_tile_validation.md) | Complete parent outputs and first error state |
| [Gravity-wave columns](skills/md2asm-gpu/references/openifs/physics/gravity_wave_momentum_drag.md) | Complete outputs, scratch and actual counters |
| [Turbulence columns](skills/md2asm-gpu/references/openifs/surface/turbulence_diffusion_entry.md) | Complete model owners, parallel buffer copies, ordered error events, actual counters and serial recovery |
| [Convective columns](skills/md2asm-gpu/references/openifs/convection/parallel_convective_columns.md) | Complete owners, shared integer decisions, physical checks and actual counters |
| [Cloud microphysics columns](skills/md2asm-gpu/references/openifs/physics/cloud_microphysics_columns.md) | Complete parent across 32 blocks, checked arithmetic in each caller, protected owners and actual counters |
| [Convective parcel ascent](skills/md2asm-gpu/references/openifs/physics/convective_energy_diagnostics.md) | Complete parent, three ordered parcel launches, exact counters and fatal-prefix checks |

These are component acceptance results, with the scope in each linked contract. They do not establish full operational GPU acceptance.

</details>

### Operational 9 km Forecast

The target has 6,599,680 horizontal points, 137 atmospheric layers and 192 steps of 450 seconds for a 24-hour forecast. A supplied Fortran reference completes that workload with 32 MPI processes and 32 OpenMP threads per process, using strict arithmetic and single-threaded OpenBLAS. Its effective block size is 24 points. MPI exchanges data between processes, while OpenMP shares work between threads.

The standalone CPU executable starts without the OpenIFS harness. The matching 32-process assembly run has no confirmed completed model step or complete saved-output acceptance. The earlier **14.13-second result is for the coarse model**, and is not a 9 km timing. Complete raw-state comparison, independent physical acceptance and full output agreement remain required. Memory and supported runtime shapes remain limited by the linked contracts.

<details>

<summary>Accepted Operational Component Checks</summary>

Each row retains its original tested extent. Earlier checks include serial and four-process cases. These complete component comparisons and connected input checks do not establish acceptance of the current 32-process forecast.

| Accepted component | Checked extent or result |
| --- | --- |
| [File headers](src/openifs/input/initial_model_file_headers.S) and [hybrid coordinates](skills/md2asm/references/openifs/setup/hybrid_coordinate_storage.md) | Actual grid metadata and all 137-layer coefficients |
| [Spectral storage](skills/md2asm/references/openifs/setup/spectral_field_storage.md) and [complete loading](skills/md2asm/references/openifs/input/operational_spectral_initial_state_loading.md) | All 413 fields and 5.42 GB of coefficients |
| [Distributed spectral storage](skills/md2asm/references/openifs/setup/distributed_spectral_field_storage.md) and [file loading](skills/md2asm/references/openifs/input/partitioned_operational_spectral_loading.md) | All four local wave and level layouts, 5.42 GB of exact loaded values, empty surface arrays, live setup connections and release |
| [Grid-point readers](skills/md2asm/references/openifs/input/operational_gridpoint_field_readers.md) and [upper-air loading](skills/md2asm/references/openifs/input/operational_upper_air_initial_state_loading.md) | All 81 surface and 959 upper-air records decoded, with the complete 65.1 GB upper-air model buffer loaded |
| [Owned upper-air startup](skills/md2asm/references/openifs/input/owned_operational_upper_air_initial_state.md) and [live field namespace](skills/md2asm/references/openifs/setup/owned_operational_field_namespace.md) | Assembly owns the field namespace storage and complete loaded context, with all 65.1 GB of GFL bytes exact and source-unwritten padding defined before loading |
| [Live physics controls](skills/md2asm/references/openifs/setup/operational_physics_controls.md) and [dynamics controls](skills/md2asm/references/openifs/setup/operational_dynamics_controls.md) | Actual configuration groups, complete records, source consistency rules and exact reference agreement |
| [Forecast work storage](skills/md2asm/references/openifs/setup/operational_forecast_work_storage.md) | All six saved and next-time owners, 115.8 GB of exact payloads, source order, live counts and release |
| [Surface field selection](skills/md2asm/references/openifs/input/operational_surface_field_selection.md) | All 75 requested fields, 3.96 GB of raw values and the actual six-component albedo requests |
| [Surface conversion](skills/md2asm/references/openifs/input/surface_initial_state_conversion.md), [unit scaling](skills/md2asm/references/openifs/input/surface_field_unit_scaling.md) and [owned conversion configuration](skills/md2asm/references/openifs/input/owned_surface_input_configuration.md) | All 3.96 GB of converted values and the complete 2,304-byte configuration |
| [Surface-state placement](skills/md2asm/references/openifs/input/operational_surface_state_placement.md) and [complete surface loading](skills/md2asm/references/openifs/input/operational_initial_surface_state_loading.md) | All 7.02 GB in six complete model arrays after file decoding, selection and conversion, with untouched fields and padding preserved |
| [Transform setup](skills/md2asm/references/openifs/setup/operational_transform_setup.md) and [reduced-grid layout](skills/md2asm/references/openifs/setup/operational_reduced_grid_configuration.md) | Complete controls, row lists, owners and release |
| [Vertical system](skills/md2asm/references/openifs/setup/owned_vertical_system_contract.md), [startup context](skills/md2asm/references/openifs/setup/vertical_startup_context.md) and [semi-implicit modes](skills/md2asm/references/openifs/dynamics/semi_implicit_mode_setup.md) | Complete 137-layer operators and five mode arrays, with exact source agreement, independent physical checks and release |
| [Spherical grid setup](skills/md2asm/references/openifs/setup/spherical_grid_setup.md#operational-reduced-grid-entry), [latitude geometry](skills/md2asm/references/openifs/setup/operational_latitude_geometry.md), [Laplacian setup](skills/md2asm/references/openifs/setup/serial_laplacian_setup.md), [local maps](skills/md2asm/references/openifs/setup/local_geometry_maps.md) and [block storage](skills/md2asm/references/openifs/setup/geometry_block_storage.md) | Complete arrays, local halos and independent geometric relations |
| [Complete spherical geometry](skills/md2asm/references/openifs/setup/spherical_geometry_setup.md#complete-operational-geometry) | All 54 owners, every point, blocked storage and views, exact source agreement and independent physical checks |
| [Field configuration](skills/md2asm/references/openifs/setup/operational_grid_field_configuration.md) and [owned field storage](skills/md2asm/references/openifs/setup/operational_grid_point_field_context.md) | Complete namespace, control effects, raw model buffers and release |
| [Surface numerical storage](skills/md2asm/references/openifs/setup/surface_field_storage.md) and [initial defaults](skills/md2asm/references/openifs/input/operational_surface_defaults.md) | All 34 arrays, 29.197 GB, 423 default planes, preserved padding and release |
| [Owned surface startup](skills/md2asm/references/openifs/setup/operational_owned_surface_state_startup.md) | Complete metadata, all 104 owners, defaults, surface-file loading and release, with caller-owned constants and physics |
| [Complete serial partition setup](skills/md2asm/references/openifs/setup/serial_partition_map_contract.md) | All 36 arrays, public transform queries, 17-position blocks, complete maps and release |
| [Terrain storage](skills/md2asm/references/openifs/setup/orography_owner_storage.md#operational-grid) and [initialisation](skills/md2asm/references/openifs/setup/operational_orography_initialization.md) | Complete scalar and derivative transforms, both layouts, all block owners, independent physical checks and exact reference agreement |
| [Complete serial operational Geometry](skills/md2asm/references/openifs/setup/operational_owned_geometry_system.md) | 9 km grid and 137 layers, with 3,866,085,928 complete owner, metadata and status bytes matching exactly |
| [File and vertical startup](skills/md2asm/references/openifs/input/owned_operational_startup_inputs.md) and [complete distributed Geometry](skills/md2asm/references/openifs/setup/owned_distributed_geometry_system.md) | 9 km grid, 137 layers and four processes, with live file inputs, complete setup, exact stored bytes and release |
| [Loaded grid-point connection](skills/md2asm/references/openifs/runtime/loaded_grid_point_prefix.md) and [tile storage](skills/md2asm/references/openifs/runtime/loaded_grid_point_tile_storage.md) | Loaded first/final tiles on four processes, owned temporary fields, 17,254,944 exact output/status bytes, independent physics and full release |
| [Initial physics interval](skills/md2asm/references/openifs/setup/initial_physics_interval.md) and [current-step clocks](skills/md2asm/references/openifs/setup/operational_step_clock_publication.md) | Source-ordered initial and current values, actual one-hour settings, exact linked clock addresses and complete other-byte preservation |
| [Loaded-model ownership](skills/md2asm/references/openifs/input/loaded_operational_model_composition.md), [configuration](skills/md2asm/references/openifs/setup/operational_model_configuration.md), [runtime metadata](skills/md2asm/references/openifs/setup/runtime_model_configuration.md), [distributed storage](skills/md2asm/references/openifs/setup/operational_enclosing_model_storage.md) and [source-ordered initialisation](skills/md2asm/references/openifs/input/source_ordered_operational_model_initialization.md) and [runtime configuration](skills/md2asm/references/openifs/input/runtime_configured_model_initialization.md) | Four live process maps, complete storage/input joins, terrain before surface, temperature conversion before initial norms, exact results and release, with runtime 24-hour records and process controls |
| [Distributed partition](skills/md2asm/references/openifs/setup/operational_distributed_partition.md), [upper-air loading](skills/md2asm/references/openifs/input/partitioned_operational_upper_air_loading.md) and [surface loading](skills/md2asm/references/openifs/input/partitioned_operational_surface_loading.md) | Four processes with complete transform and point maps, all 65.1 GB of upper-air and 7.02 GB of surface buffers exact, matched status and release |
| [Connected operational input](skills/md2asm/references/openifs/input/runtime_operational_input_state.md) | Actual 9 km files on 23 processes, 161 setup and release calls, complete field descriptions and released storage, with the weather step and full forecast still pending |
| [Streaming upper-air loading](skills/md2asm/references/openifs/input/streaming_runtime_upper_air_loading.md) | Two small real GRIB inputs, one decoded record plus private local storage, exact complete outputs and final-block padding, with ABI, failure preservation and cleanup checks |
| [Streaming spectral loading](skills/md2asm/references/openifs/input/streaming_runtime_spectral_loading.md) | One global record plus private local arrays, 12 small runtime partitions with exact complete outputs, empty-wave handling, preserved state on late input failure and checked cleanup, followed by the separate 23-process input lifetime check |
| [Runtime local surface storage and placement](skills/md2asm/references/openifs/input/runtime_partitioned_surface_startup.md) | Live local rows and blocks, four small shapes with exact defaults and complete buffers, preserved final-block padding and checked cleanup, with full input integration pending |
| [Runtime spectral packing fit](skills/md2asm/references/openifs/output/spectral_packing_fit.md#runtime-dimensions) | Live truncation and subset bounds, exact original result words and status on 11 profiles through T4096, independent mathematical checks and bounded refusals, with complete writer integration pending |
| [Runtime output namelist](skills/md2asm/references/openifs/output/runtime_output_namelist.md) and [Fullpos configuration](skills/md2asm/references/openifs/fullpos/runtime_fullpos_configuration.md) | Eight parser cases include all 103 operational physical requests and 137 model levels. Four original configuration calls match all 223,056 returned bytes, with bounds and machine-status checks. Complete output integration remains pending |
| [Runtime GRIB templates and fields](skills/md2asm/references/openifs/output/runtime_grib_encoding.md) and [packing policy](skills/md2asm/references/openifs/output/runtime_grib_packing_policy.md) | 67 paired observations, including 51 complete messages with zero differing bytes on small changed grids, matched machine state and 14 critical observations, with complete operational files pending |
| [Distributed terrain](skills/md2asm/references/openifs/setup/distributed_operational_orography_initialization.md) and [virtual temperature](skills/md2asm/references/openifs/input/operational_virtual_temperature_conversion.md) | All four process maps, complete assigned terrain and spectral owners, unchanged inputs and exact status |
| [Time coefficients](skills/md2asm/references/openifs/dynamics/operational_time_coefficients.md) and [forecast schedule](skills/md2asm/references/openifs/dynamics/operational_forecast_schedule.md) | Live time interval, source enable flags and closing wave-collection visit, with exact component results |
| [Returned wave fields](skills/md2asm/references/openifs/waves/returned_surface_field_copy.md) and [live wrapper](skills/md2asm/references/openifs/waves/runtime_wave_surface_return.md) | Complete bit-preserving copies, remapped final blocks and exact original call order through public profiling, within the selected disabled-hook scope |
| [Persistent grid work](skills/md2asm/references/openifs/setup/operational_persistent_grid_work.md), [initialisation](skills/md2asm/references/openifs/dynamics/operational_grid_work_initialization.md) and [flux configuration](skills/md2asm/references/openifs/setup/operational_selected_flux_configuration.md) | Owned buffers, complete 14.48 GB zero assignment, actual reset settings, exact records and failure cleanup |
| [Model transforms](skills/md2asm/references/openifs/dynamics/operational_model_transform_callers.md) and [distributed spectral norms](skills/md2asm/references/openifs/dynamics/distributed_spectral_norms.md) | All four process maps, complete result bytes, ordered global sums, independent checks and exact status |
| [Runtime spectral transposes](skills/md2asm/references/openifs/dynamics/runtime_spectral_transpose_contract.md) | Actual 23-process and 2 by 2 distributions, 132 calls and 20,004,096,000 paired destination bytes exact, with independent field maps and complete cleanup. Component checked, complete forecast pending |
| [Shared public matrix service](skills/md2asm/references/openifs/support/public_matrix_product_serialization.md) | Four matrix shapes with one and six threads, 636,848 complete output bytes exact, independent sums and full status checks. Accepted component for the recorded serial Sci provider |
| [Runtime output schedules](skills/md2asm/references/openifs/support/runtime_periodic_output_schedule.md) | 18 source/native pairs, 5,588 complete output bytes exact and 1,226 independently selected entries, including explicit steps and hour/minute requests. Component checked, enclosing forecast pending |
| [Owned forecast event tables](skills/md2asm/references/openifs/dynamics/runtime_forecast_events.md) | Three joined profiles, 35 original selector calls and 19,352 complete event bytes exact. Runtime schedules, private publication and release checked, complete forecast pending |
| [Runtime distributed spectral norms](skills/md2asm/references/openifs/dynamics/runtime_distributed_spectral_norms.md) | Six distributed parent shapes and boundary arithmetic, 123,337,368 nonaddress bytes exact, independent norms and seven collective refusals checked. Operational forecast pending |
| [Runtime grid-field norms](skills/md2asm/references/openifs/dynamics/runtime_grid_field_norms.md) and [atmospheric mass correction](skills/md2asm/references/openifs/dynamics/runtime_atmospheric_mass_correction.md) | Two block widths on four processes and 137 layers, with 222,415,936 complete nonaddress bytes exact, independent means, extrema and mass checks, and checked cleanup. Full forecast pending |
| [Spectral pressure mass correction](skills/md2asm/references/openifs/dynamics/spectral_pressure_mass_correction.md) | Twelve original comparisons, exact pressure outputs, independent arithmetic checks and six atomic refusals. Complete spectral caller and forecast pending |
| [Runtime coupled-field accumulators](skills/md2asm/references/openifs/setup/runtime_coupled_field_accumulators.md) | Operational and odd tiled dimensions, 32,140,608 defined bytes exact with descriptor and independent zero checks. Release and atomic refusals pass, complete forecast pending |
| [Fresh model trajectory metadata](skills/md2asm/references/openifs/setup/fresh_model_trajectory_metadata.md) | Original null-base correspondence, complete preservation of other bytes, four atomic refusals and cleanup checked. Active saving and forecast pending |
| [Runtime physical grid output](skills/md2asm/references/openifs/output/runtime_physical_grid_output.md) | HPOS, SCAN2M_HPOS, GRIDFPOS and CHECKINCLIM with all 121 fields, 64 component calls and 5,496,896 paired bytes exact, independent physical checks and cleanup. Full forecast pending |
| [Fullpos field descriptions and file names](skills/md2asm/references/openifs/output/fullpos_field_metadata_and_file_names.md) | 36 component calls, 455,672 compared bytes exact and 7,693 independent field and name checks. Empty levels, time labels, refusals and owner release pass. Complete output and forecast pending |
| [Runtime Fullpos norms](skills/md2asm/references/openifs/output/runtime_fullpos_norms.md) | 145 component observations at one and four MPI ranks, 87,664 compared bytes exact, 55 matched status pairs and 593 independent relations. Field maps, missing values, extrema and owner lifetimes checked. Complete output and forecast pending |
| [Vertical output physics](skills/md2asm/references/openifs/output/fullpos_vertical_physics.md) | 54 component calls, 184,880 compared bytes exact and 21,379 independent physical checks. Potential vorticity, theta and PV level pressure, humidity, boundaries and refusals pass. Complete output and forecast pending |
| [GRIB time labels](skills/md2asm/references/openifs/output/runtime_grib_time.md) and [soil layer labels](skills/md2asm/references/openifs/output/runtime_grib_soil_levels.md) | 57 time pairs and 8 soil pairs match 10,214 and 1,152 complete bytes. Independent time, unit and boundary checks pass. Operational output and forecast pending |
| [Distributed GRIB file writers](skills/md2asm/references/openifs/output/runtime_fullpos_file_writers.md) | 145 observations on one and four processes, 3,346,076 saved bytes exact and 2,080,807 independent relations. Nine complete files per process-count case, field order, padding, bounds and cleanup checked. Operational output and forecast pending |
| [Spectral pressure and rotation](skills/md2asm/references/openifs/dynamics/runtime_pressure_and_rotation.md) | 10 source/native pairs and one budget refusal, 47,279,604 nonaddress bytes exact with typed pointer checks and independent equations. Coarse single-thread parents and high-degree rotation components checked, operational forecast pending |
| [Distributed grid-point norms](skills/md2asm/references/openifs/transport/distributed_grid_point_norms.md) and [surface-pressure correction](skills/md2asm/references/openifs/transport/surface_pressure_mass_correction.md) and [column mass](skills/md2asm/references/openifs/transport/pressure_weighted_column_integral.md) | Runtime-derived block sizes, two layouts, complete pressure and log-pressure bytes exact, independent checks and matched status |
| [Runtime physics storage](skills/md2asm/references/openifs/physics/runtime_local_physics_work_storage.md), [work reset](skills/md2asm/references/openifs/physics/runtime_physics_work_reset.md) and [radiation latitude interpolation](skills/md2asm/references/openifs/radiation/radiation_latitude_interpolation.md) | Live dimensions, different supported shapes, exact complete component bytes, independent checks and cleanup |
| [Runtime tracer interpolation](skills/md2asm/references/openifs/dynamics/laitli.md#runtime-operational-shapes) and [field bounds](skills/md2asm/references/openifs/dynamics/laminmaxint.md#runtime-operational-shapes) | Unchanged assembly at 137 levels and two operational source-plane sizes, exact complete outputs and independent affine-field checks |
| [Runtime polar halo](skills/md2asm/references/openifs/transport/runtime_polar_halo_fill.md) | All four process maps, complete field bytes, independent boundary checks and matched status |
| [Runtime ozone coefficient copy](skills/md2asm/references/openifs/physics/runtime_ozone_chemistry_field_copy.md) and [ozone tendency](skills/md2asm/references/openifs/physics/runtime_ozone_chemistry_tendency.md) | Live column and layer counts, exact component outputs, independent chemistry checks and preserved inactive cells |
| [Runtime physics state copy](skills/md2asm/references/openifs/physics/runtime_physics_state_copy.md) | Live column and layer counts, field masks, exact copied bits, preserved inactive cells and no original global |
| [Runtime radiation latitude fields](skills/md2asm/references/openifs/radiation/radiation_gaussian_fields.md) and [point coordinates](skills/md2asm/references/openifs/radiation/radiation_point_coordinates.md) | Two latitude counts, owned buffers, exact Gaussian and polar values, independent geometry checks and cleanup |
| [Runtime radiation interpolation](skills/md2asm/references/openifs/radiation/runtime_radiation_interpolation.md) | Exact coordinate weights and twelve-point results, constant-field preservation, complete mask checks and partial-block padding, with the owning radiation parent pending |
| [Runtime aerosol and ozone preparation](skills/md2asm/references/openifs/radiation/aerosol_and_ozone_preparation.md#runtime-columns-and-layers) | Exact three-dimensional aerosol outputs at 137 layers, independent mass and positivity checks, partial groups and cleanup, with complete radiation integration pending |
| [Runtime departure weights](skills/md2asm/references/openifs/dynamics/runtime_local_departure_weights.md) and [angular limits](skills/md2asm/references/openifs/radiation/grid_angular_extrema.md) and [preallocated degree fields](skills/md2asm/references/openifs/radiation/preallocated_grid_angular_extrema.md) | Live grid dimensions, shared numerical bodies, exact component outputs and preserved boundary and tie rules |
| [Runtime Cartesian trajectories](skills/md2asm/references/openifs/dynamics/runtime_cartesian_departure_points.md), [departure fields](skills/md2asm/references/openifs/dynamics/runtime_departure_coordinate_fields.md) and [interpolation weights](skills/md2asm/references/openifs/dynamics/runtime_trajectory_interpolation_weights.md) | Owned constants and clock, shared numerical bodies, exact component outputs and actual source-plane addressing with constructed winds |
| [Runtime radiation grid](skills/md2asm/references/openifs/radiation/radiation_grid_shape.md) and [halo widths](skills/md2asm/references/openifs/radiation/radiation_halo_widths.md) | Six grid shapes, live interpolation controls, exact row and owner bytes, independent checks and allocation rollback |
| [Runtime radiation owners](skills/md2asm/references/openifs/radiation/runtime_radiation_flux_owners.md) | Two source-selected controls and 21 live-shaped buffers, exact complete bytes through the full P17/L137/B97055 storage shape, allocation rollback and full release |
| [Runtime radiation schedules](skills/md2asm/references/openifs/radiation/runtime_radiation_frequencies.md) | Live forecast time step, source-selected frequency controls, exact complete records and numerical status, with explicit terminating search bounds |
| [Runtime tracer mass correction](skills/md2asm/references/openifs/transport/runtime_tracer_mass_correction.md) | Four operational grid maps and 137 layers, all complete component output bytes exact, independent global mass and local-bound checks |
| [Runtime mountain-wave layer](skills/md2asm/references/openifs/physics/runtime_mountain_wave_layer.md) | Real numerical children at two shapes, owned constants, exact complete outputs and empty-interval status |
| [Runtime mass-correction dispatcher](skills/md2asm/references/openifs/transport/runtime_tracer_mass_correction_dispatch.md) | Exact selected call forwarding, two runtime shapes, complete bytes and collective failure status |
| [State time updates](skills/md2asm/references/openifs/physics/state_update.md), [state increments](skills/md2asm/references/openifs/physics/state_increment.md) and [field transfers](skills/md2asm/references/openifs/physics/update_fields.md) | Unchanged accepted generic providers, exact object identities, live dimensions and reused independent checks |
| [Runtime radiative-flux layer](skills/md2asm/references/openifs/physics/runtime_radiative_flux_layer.md) | Exact complete outputs and independent energy checks at two shapes, including both approximate thermal-update settings and owned physical/dynamics/thermal constants |
| [Runtime radiation transform storage](skills/md2asm/references/openifs/radiation/radiation_transform_storage.md) | Source-ordered public setup, nine owners and query, actual process maps, exact data and coordinated failure cleanup |
| [Early radiation controls and Planck storage](skills/md2asm/references/openifs/radiation/runtime_radiation_control_prefix.md), [grid connection](skills/md2asm/references/openifs/radiation/runtime_radiation_grid_from_prefix.md) and [live transform join](skills/md2asm/references/openifs/radiation/runtime_radiation_transform_from_prefix.md) | Actual distributed Geometry and control owners, exact source comparisons, runtime grid dimensions, public transform agreement and collective cleanup |
| [Runtime prognostic departure update](skills/md2asm/references/openifs/dynamics/runtime_prognostic_departure_update.md) | Shared numerical body, 137 layers and actual source strides, exact complete component bytes, independent checks and final-column boundaries |
| [Preallocated radiation Gaussian fields](skills/md2asm/references/openifs/radiation/preallocated_radiation_gaussian_fields.md) | Real parent-produced owners, exact vectors and status, preserved complete records, independent geometry checks and no new allocation |
| [Humidity floor](skills/md2asm/references/openifs/physics/qnegat.md) and [saturation humidity](skills/md2asm/references/openifs/physics/satur.md) | Unchanged accepted providers, owned constants and exact mathematical call targets, with reused independent water checks |
| [Runtime physics working fields](skills/md2asm/references/openifs/setup/runtime_ecmwf_physics_field_storage.md) and [live field forwarding](skills/md2asm/references/openifs/setup/live_ecmwf_physics_field_forwarding.md) | Live allocation dimensions, all six final-address arrays, exact records and payloads, wide integer bounds and reused full operational zero-state evidence |
| [Local physics work](skills/md2asm/references/openifs/support/runtime_self_owned_physics_work.md) and [live shape counts](skills/md2asm/references/openifs/support/runtime_physics_work_shape_counts.md) | Seven owned record lifetimes on the actual four-process grid, first and final block views, complete perturbation zeroing, exact records and status, and failure cleanup |
| [Runtime field registry](skills/md2asm/references/openifs/setup/runtime_field_registry.md) and [release](skills/md2asm/references/openifs/setup/runtime_field_registry_release.md), [state initialization](skills/md2asm/references/openifs/support/runtime_physics_state_initialization.md), [complete state views and cloud copies](skills/md2asm/references/openifs/support/physics_state_complete_update.md), [private field views](skills/md2asm/references/openifs/support/runtime_field_variable_lifecycle.md) and [dimensions and latitude](skills/md2asm/references/openifs/support/runtime_physics_dimension_block_binding.md), plus [surface block views](skills/md2asm/references/openifs/support/physics_surface_block_views.md) | Live grid counts, ordered registry and eight-state construction, block views and reset, all 17 surface association or fallback branches, exact source-defined records, preserved numerical owners and checked cleanup |
| [Live radiation setup](skills/md2asm/references/openifs/radiation/live_radiation_gaussian_setup.md), [point fields](skills/md2asm/references/openifs/radiation/live_radiation_point_setup.md), [halo setup](skills/md2asm/references/openifs/radiation/live_radiation_halo_setup.md) , [input interpolation](skills/md2asm/references/openifs/radiation/live_radiation_first_interpolation.md) and [output interpolation](skills/md2asm/references/openifs/radiation/live_radiation_second_interpolation.md) | Source-ordered setup and exchange maps, exact complete data and separate pointer checks, with collective cleanup on four processes |
| [Runtime transport field handoff](skills/md2asm/references/openifs/dynamics/runtime_transport_field_handoff.md) | Two 137-level blocks and all 3337 fields, actual source-point maps, exact complete buffers and shared bit-copy loops, within the prepared-input scope |
| [Runtime transport driver](skills/md2asm/references/openifs/transport/runtime_semi_lagrangian_transport.md) and [retained work storage](skills/md2asm/references/openifs/transport/runtime_retained_transport_storage.md) | Serial and four-process constructed finite-difference fields, actual communication maps and widths, exact outputs across retained allocation, reuse and resize, with independent checks and explicit failure limits |
| [Slow-physics binding](skills/md2asm/references/openifs/physics/sltend_layer.md#runtime-provider-binding) and [height-wind interpolation](skills/md2asm/references/openifs/physics/runtime_height_wind_interpolation.md) | Unchanged slow-physics objects and owned constants, plus 96 height-wind calls with complete exact outputs and independent interpolation checks |
| [Methane humidity tendency](skills/md2asm/references/openifs/physics/methox.md#runtime-provider-binding) and [surface radiation](skills/md2asm/references/openifs/surface/surfrad_layer.md#runtime-provider-binding), with [shared runtime owners](skills/md2asm/references/openifs/setup/canonical_physical_clock_runtime_owners.md) and [startup](skills/md2asm/references/openifs/setup/canonical_physics_runtime_startup.md), plus [inactive coupling](skills/md2asm/references/openifs/setup/operational_inactive_coupling_context_bindings.md) | Unchanged numerical bodies, actual produced constants and clocks, shared control addresses and exact mathematical routes |
| [Cloud saturation adjustment](skills/md2asm/references/openifs/physics/cloud_satadj.md#runtime-provider-binding) and [cloud weather diagnostics](skills/md2asm/references/openifs/physics/cloud_weather_diagnostics.md#runtime-provider-binding) | Unchanged selected numerical bodies and children, actual owned constants and exact mathematical calls, with their declared physical and return limits retained |
| [Convective energy diagnostic](skills/md2asm/references/openifs/physics/convective_energy_diagnostics.md) and [live-level convection setup](skills/md2asm/references/openifs/setup/convection_parameter_setup.md) | Unchanged diagnostic bodies, actual post-convection constants, runtime level bounds and exact source-ordered field publication |
| [Fine-grid gravity-wave child and launches](skills/md2asm/references/openifs/physics/runtime_nonorographic_gravity_waves.md) | Full source grid-spacing factor, live columns and levels, exact complete outputs and independent momentum and energy checks, with actual owned [wave setup](skills/md2asm/references/openifs/setup/runtime_nonorographic_gravity_wave_parameters.md) and [mountain-wave setup](skills/md2asm/references/openifs/setup/runtime_orographic_gravity_wave_parameters.md) joined through the original interface |
| [Runtime surface boundary layer](skills/md2asm/references/openifs/surface/runtime_surface_boundary_layer.md) | Actual owned surface parameters, live column bounds, exact complete outputs and independent area, snow and canopy checks |
| [Runtime snow initialisation](skills/md2asm/references/openifs/surface/runtime_surface_snow_initialisation.md) and [shared helper entries](skills/md2asm/references/openifs/support/shared_hook_snow_providers.md) | Actual surface settings, five snow layers, exact complete outputs, independent snow and water checks, source-preserving aliases and checked cleanup |
| [Runtime cloud microphysics layer](skills/md2asm/references/openifs/physics/runtime_cloud_microphysics_layer.md) | Live columns and levels, the actual diagnosed cloud top, exact complete outputs, and independent water and energy checks |
| [Runtime cloud-radiation layer](skills/md2asm/references/openifs/physics/runtime_cloud_radiation_layer.md) | Live latitude and level counts, real mathematical children, exact complete outputs and independent cloud checks, with unchanged default objects |
| [Runtime convection layer](skills/md2asm/references/openifs/physics/runtime_convection_layer.md) | Live dimensions and owned parameters, active and inactive columns, exact complete outputs, independent heat, water and momentum checks, and unchanged default objects |
| [Prepared GPU convection layer](skills/md2asm-gpu/references/openifs/convection/runtime_convection_layer.md) | Thirteen saved source/CPU comparisons at 137 layers, exact numerical and status bytes, separate typed address proofs, independent checks and preserved default objects |
| [Runtime surface time update](skills/md2asm/references/openifs/surface/runtime_surface_time_layer.md) | Live dimensions and actual surface parameters, exact complete outputs, independent water checks, empty-range status and complete storage release |
| [Runtime surface turbulence](skills/md2asm/references/openifs/surface/runtime_surface_turbulence.md) | Actual owned parameters, original sea calculation, exact complete outputs, independent physical checks, bounds and storage release |
| [Live-level cloud setup](skills/md2asm/references/openifs/setup/runtime_prognostic_cloud_parameter_setup.md) | Live level counts from 2 through 256, exact complete parameters and cloud-top selection, actual physical and mathematical providers, with unchanged default objects |
| [Uncoupled ocean layer](skills/md2asm/references/openifs/physics/uncoupled_ocean_field_layer.md) | Actual owned coupling settings, generic typed temperature views and exact complete identity at two grid shapes, preserving the source disabled-ocean route |
| [Inactive chemistry and aerosol storage](skills/md2asm/references/openifs/setup/inactive_composition_owners.md) | Complete defaults, the 152-byte allocated buffer and release |

</details>

## Notes

OpenIFS’s twelve-point radiation interpolation can overshoot and produce negative temperatures. The assembly preserves the original aerosol calculation for finite, nonzero temperatures. The observed case uses the even exponent `RCTRPT=30`. This source-compatible result does not make negative temperatures physically valid, and complete forecast acceptance remains pending.

The original `CPG_DRV` flux-reset call selects a one-element time array with an index outside its declared bounds after step zero. The existing component control uses the documented quotient-index correction. Exact reset behavior against an unchanged operational executable at step 20 and later remains unverified. The reference executable and weather physics are unchanged.

The original aerosol-climatology routine fills a temporary latitude basis from column 1. The selected forecast also starts every block at column 1, and full and cropped-last comparisons agree exactly. For a first column above 1, the original can read an uninitialized tail. Separate partial-first Arm and GPU checks therefore claim agreement with each other, while retaining this original limitation.

In tested vertical-diffusion calls, the source and GPU results both show a gap of up to 0.139 W/m² between the column heat change and the tested boundary-flow balance. The source sets its upper boundary separately, so we preserve its equations and do not claim whole-column heat conservation.

For gas interpolation with zero model layers, complete output bytes agree but seven small cases expose an existing difference in numerical exception flags. Assembly retains its early return. The tested forecast has 19 layers, and its returned flags match the original.

In guarded shortwave cases, the original compiled routine changes platform register `x18`. Assembly preserves it. Original output bytes, floating-point controls, exception flags, system error values and ordinary saved-register obligations remain checked separately.

The original urban setup stores `RSBCONS=5.67e+08`, although its comment describes the Stefan–Boltzmann constant. This source value is preserved. Urban flux is disabled in the tested forecast, and this coefficient is excluded from the independent physical validation.

In a tested ice-formation call, the OpenIFS lake update stores an average water temperature of 277.13 K, while its limited temperature profile can represent at most 276.334 K. The profile describes how water temperature changes with depth. We retain the original OpenIFS equations and update rules, and report this known limitation separately from exact assembly byte agreement. Independent whole-forecast physics remains unverified.

The original solar averaging can omit daylight from a neighbouring day when a long daylight interval crosses midnight. A supported 9 km grid-cell witness exposes this limit. The [entry that matches the original behaviour](skills/md2asm/references/openifs/physics/solar_zenith_source_compatibility.md) preserves the calculation and passes its focused byte comparison. Its independent periodic-light check reports the physical discrepancy. The strict solar entry retains its qualified physical domain.

The supplied 21 June 2026 climate input has two present top-soil temperature entries that original OpenIFS uses as sea-surface temperatures. Its update and assembly both produce −1870.689453125 K and −830.193359375 K at those sea cells. The input values and source update are preserved. Exact implementation agreement passes at this boundary, while physical temperature admissibility fails.

The operational turbulence component preserves original `VSURF` sea-derivative ordering for agreement with the unchanged OpenIFS reference. That source derivative includes an extra salinity factor of 0.98 and is about two percent below the derivative of its humidity equation. This physical-model limitation is explicit; the earlier corrected sea-derivative model remains separate. See the [runtime turbulence contract](skills/md2asm/references/openifs/surface/runtime_surface_turbulence.md).

All 2,086,488,208 bytes of the initial upper-air output match the supplied operational Fortran reference, while initial surface files still differ. Full operational output agreement and comparative timing remain unverified. The [basic formulations](formulations/openifs/README.md) explain the physical balances, and the [coverage record](src/openifs/README.md) retains detailed checks and limitations.
