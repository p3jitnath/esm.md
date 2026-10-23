# esm.md

esm.md generates Arm assembly from short physics and mathematics notes in Markdown. Assembly is a processor’s low-level instruction language. We compare it with Fortran, Julia, and compiled Python on a Neoverse V2 processor, using identical 64-bit floating-point calculations.

The tables show median speed in million complete cell updates per second for optimised solvers across twelve quiet-node runs. Each update advances one cell by one full time step. All seven variants, including the unchanged vanilla language controls, pass independent physics checks and produce identical output bytes. Detailed results, including the controls and timing variation, are kept with the local research records.

## Shallow water

This model follows water depth and horizontal flow over a flat bottom. Gravity creates waves when the depth is uneven. Each grid has the stated number of cells in both horizontal directions.

| Grid | Assembly | Fortran | Julia | Python |
| --- | ---: | ---: | ---: | ---: |
| 64² | 89.80 | 84.94 | 78.39 | 56.40 |
| 256² | 95.31 | 81.51 | 77.00 | 56.42 |
| 1024² | 82.66 | 72.23 | 70.77 | 52.61 |

## Budyko–Sellers energy balance

This model gives one average temperature for each latitude band. The Sun’s radiation warms the surface, radiation cools it, and heat moves between neighbouring bands. The grid size is the number of bands from the South Pole to the North Pole.

| Grid | Assembly | Fortran | Julia | Python |
| --- | ---: | ---: | ---: | ---: |
| 128 | 650.56 | 510.74 | 531.46 | 548.93 |
| 4096 | 599.68 | 498.27 | 509.81 | 493.75 |
| 65536 | 590.51 | 488.69 | 489.47 | 514.88 |

Start with the [short template](formulations/TEMPLATE.md), [shallow-water maths](formulations/sw/2d_periodic.md), or [energy-balance maths](formulations/ebm/budyko_sellers.md). The [md2asm skill](skills/md2asm/SKILL.md) supplies the numerical and implementation details and retains the measured assembly optimisations.

The published tree contains Markdown and assembly. Build instructions and the local comparison protocol are in the [evaluation notes](skills/md2asm/SKILL.md). [AGENTS.md](AGENTS.md) defines the first-year-undergraduate writing convention. Local tools, language controls, data and the poster remain outside Git.

## GPU solvers

The same shallow-water and energy-balance models also run on one NVIDIA GH200 GPU. The LLM emits PTX, NVIDIA’s virtual assembly language, directly from the frozen numerical contracts. NVIDIA’s assembler then creates GPU machine code. The [md2asm-gpu skill](skills/md2asm-gpu/SKILL.md) and [GPU execution contract](skills/md2asm-gpu/references/gpu-contract.md) describe the direct route, complete stages and supported launches. Sources are [shallow water](src/sw/gpu/2d_rusanov_ssprk2.ptx) and [energy balance](src/ebm/gpu/budyko_sellers.ptx).

These archived tables give million complete cell updates per second from twelve accepted repetitions on one fixed GPU in a completed quiet exclusive allocation. Each entry is the median rate followed by its minimum–maximum range. Higher is faster. A water update includes all three fields, both time stages and periodic boundaries. An energy-balance update includes both stages and pole boundaries.

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

The timer measures replay of an already prepared sequence of GPU launches. It excludes compilation, startup, allocation, transfers, graph construction and verification. Julia uses separate sequential processes on the same GPU. All seven variants pass independent physics, complete trajectories, ordinary launches, replay, boundary and buffer checks with zero differing output bytes. The water check has 34 scientific cases and the energy-balance check has 28, including 1000-step trajectories. These GPU times describe steady computation and are separate from the CPU forecast’s complete-process times. These GPU checks and measurements belong to the archived study; this merge does not rerun them. Controls, tools, raw repeated samples and figures remain in the local research archive.

## OpenIFS development

The OpenIFS GPU extension has passed six complete 24-hour forecasts with combined CPU/GPU assembly. The expanded run includes complete GPU cloud microphysics, aerosol optics and shortwave transport. These ordinary runs use the original files and run without the OpenIFS harness or verification input writes. Each matches all ten saved files across 618,140 bytes and 59 final numerical views across 18,971,680 bytes. These views overlap. The latest run also matches both complete model-history buffers, which retain previous time levels, across 1,882,368 bytes. A correction to GPU call handling passes its check against saved CPU outputs.

The latest complete GPU assembly run finishes all 25 forecast steps in **464.19 seconds**, including input, setup and output. All ten saved files match the CPU reference across 618,140 bytes. This is one complete-process measurement, about 33 times the accepted CPU assembly median of 14.13 seconds. Complete internal-state and counter checks remain pending for this GPU image, so no GPU speedup is accepted. Ordinary performance candidates retain the CPU time limit, with longer progress diagnostics permitted by the user.

These GPU components pass their declared exact-output checks.

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

Separately, 257 distinct original routines have passed their component checks. The complete required-routine total and the number used on the GPU during a forecast remain under review, so these results do not give a completion percentage.

Complete [Legendre analysis](skills/md2asm-gpu/references/openifs/dynamics/complete_legendre_analysis.md), [inverse-Legendre sums](skills/md2asm-gpu/references/openifs/dynamics/inverse_legendre_reconstruction.md), the [north–south derivative](skills/md2asm-gpu/references/openifs/dynamics/spectral_latitude_derivative.md), [spline-matrix construction](skills/md2asm-gpu/references/openifs/setup/complete_spline_operator_matrix.md), [hybrid-coordinate setup](skills/md2asm-gpu/references/openifs/setup/hybrid_coordinate_setup.md), [hybrid pressure](skills/md2asm-gpu/references/openifs/dynamics/private_hybrid_pressure.md), [vertical eta coordinates](skills/md2asm-gpu/references/openifs/setup/vertical_eta_coordinates.md) and [radiation field sums](skills/md2asm-gpu/references/openifs/radiation/ordered_radiation_field_reduction.md) also pass their component checks. The current forecast combines AArch64 control and PTX calculations. All saved files from the last completed run agree, while full internal acceptance remains pending. The [mathematical support](skills/md2asm-gpu/references/openifs/mathematical_support.md) and [assembly CUDA launcher](skills/md2asm-gpu/references/openifs/cuda_runtime.md) define the numerical and storage rules.

The openifs-md branch extends this workflow to OpenIFS 48.1.1. Assembly replaces 373 original routine bodies within their selected input and calculation scopes, and seven field-registry methods that store array addresses and dimensions. Their small checks cover independent physical relations within declared input ranges, with known source limits recorded below. The checked forecast-call cases pass exact byte comparisons in a coarse global forecast.

| Check | Coverage | Differing bytes |
| --- | --- | ---: |
| Radiation-field preparation | 6,400 complete calls | 0 |
| Plant photosynthesis | 6,450 complete C3/C4 calls | 0 |
| Interpolation boundaries | 2,150 complete calls | 0 |
| Fourier coefficient transfer | 352 complete field-count/latitude pairs | 0 |
| Spectral forecast step | 25 complete calls and seven direct stages | 0 |
| Complete final state | 685 buffers across 27,486,113 bytes | 0 |
| Saved forecast files | 10 files across 618,140 bytes | 0 |

The [autonomous assembly forecast](skills/md2asm/references/openifs/input/standalone_weather_forecast.md) starts on 15 October 2004 and advances 24 hours on 2,048 grid points with 19 atmospheric layers. Assembly owns original-file loading, configuration, setup, storage, the time loop, calculations, state updates and output. The production executable runs without original OpenIFS routines or its harness. External file-format, transform, mathematical and runtime services remain explicit. All ten saved files match all 618,140 bytes. A separate verification with matched source-unused incoming storage also matches all 27,486,113 bytes across 685 internal buffers. Accepted component checks and saved-trajectory checks cover humidity bounds, finite spectral coefficients, mean temperature and pressure, grid metadata and time schedules. Whole water and heat budgets remain unverified. The [OpenIFS verification note](src/openifs/README.md) states the checks and limits. The separate full 24-hour optimisation phase is in progress.

Three matched complete-process runs per variant on a quiet exclusive Grace node give the results below. Earlier rows use one pinned CPU. Worker comparisons give both variants the same available CPUs, four for the one-to-four comparison and eight for the four-to-eight comparison. The main thread stays on CPU 0, and extra workers calculate independent cloud columns and, in the latest version, complete shortwave radiation columns. Other threaded services retain `OMP_NUM_THREADS=1`. The timer includes loading, setup, forecast calculations and output, with checks outside the timer. Every run reproduces all ten saved files and the 59 observed final numerical fields exactly. The larger complete-state comparison above separately accepts the changed implementation.

Selected earlier batches are shown below, with the full history in the local research records. Each row comes from a separate matched batch. Each time is the median followed by the minimum–maximum range, in seconds.

| Matched Change | Before (s) | After (s) | Speedup |
| --- | ---: | ---: | ---: |
| Compact exact arithmetic | 76.98 [76.64–83.88] | 37.75 [37.23–44.64] | 2.04× |
| Wider clears, status writes and grouped integer sequences | 37.47 [37.42–37.50] | 31.49 [31.19–31.64] | 1.19× |
| Bounded exact integers for widely separated terms | 31.15 [30.91–31.68] | 26.65 [26.58–26.70] | 1.17× |
| Four-cell reflection with eight-value exponentials | 22.48 [22.23–22.64] | 22.04 [21.63–22.43] | 1.020× |

The runtime setting `EC_PMON=0` disables hardware energy monitoring. Energy and power diagnostic columns become zero. Weather calculations, memory and status reports, and all canonical forecast files remain in the timed process. The energy-monitoring contrast comes from one rotated nine-run batch, with three runs per variant. Each numerical contrast comes from a separate batch of three alternating matched pairs, with monitoring disabled for both variants.

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

The latest median is **14.13 seconds**, with complete forecast times of 14.13, 14.11 and 14.13 seconds. Eight workers calculate independent shortwave columns with unchanged arithmetic and random streams. The latest change reuses one bounded private workspace, copies only required incoming owners and joins workers at the output dependency. The matched control takes 14.23, 14.60 and 14.28 seconds, retaining all observed variation. All three wall-time pairs improve, with nonoverlapping ranges. Median aggregate user-plus-system CPU time falls from 19.68 to 19.43 seconds. Both variants have the same eight available CPUs, eight cloud workers and eight shortwave workers. A live count of at least four daylight columns selects the shortwave team, while other supported work keeps the serial assembly path. The timer reports 0.01 seconds. Performance on other forecast inputs remains unmeasured.

The [basic formulations](formulations/openifs/README.md) explain the physical balances. The [coverage tables](src/openifs/README.md) give accepted counts and verification limits. All **255 audited weather and forcing routines** in this T21 main phase have accepted assembly replacements. Other inventories describe separate, overlapping scopes and do not add unfinished routines to this tested route. The ordered original routine names and source paths remain in the local records.

## Notes

The existing 9 km case has 137 atmospheric layers and 6,599,680 horizontal points. The requested operational run has a one-hour lead time, using eight 450-second steps and four processes. Its separate run configuration changes only the stop time and process count. The following setup and input components pass complete byte comparisons and their required independent checks. These are component results. The complete operational forecast has not run.

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
| [Vertical system](skills/md2asm/references/openifs/setup/owned_vertical_system_contract.md) and [startup context](skills/md2asm/references/openifs/setup/vertical_startup_context.md) | Complete 137-layer operators, coordinate update, ownership and release |
| [Spherical grid setup](skills/md2asm/references/openifs/setup/spherical_grid_setup.md#operational-reduced-grid-entry), [latitude geometry](skills/md2asm/references/openifs/setup/operational_latitude_geometry.md), [Laplacian setup](skills/md2asm/references/openifs/setup/serial_laplacian_setup.md), [local maps](skills/md2asm/references/openifs/setup/local_geometry_maps.md) and [block storage](skills/md2asm/references/openifs/setup/geometry_block_storage.md) | Complete arrays, local halos and independent geometric relations |
| [Complete spherical geometry](skills/md2asm/references/openifs/setup/spherical_geometry_setup.md#complete-operational-geometry) | All 54 owners, every point, blocked storage and views, exact source agreement and independent physical checks |
| [Field configuration](skills/md2asm/references/openifs/setup/operational_grid_field_configuration.md) and [owned field storage](skills/md2asm/references/openifs/setup/operational_grid_point_field_context.md) | Complete namespace, control effects, raw model buffers and release |
| [Surface numerical storage](skills/md2asm/references/openifs/setup/surface_field_storage.md) and [initial defaults](skills/md2asm/references/openifs/input/operational_surface_defaults.md) | All 34 arrays, 29.197 GB, 423 default planes, preserved padding and release |
| [Owned surface startup](skills/md2asm/references/openifs/setup/operational_owned_surface_state_startup.md) | Complete metadata, all 104 owners, defaults, surface-file loading and release, with caller-owned constants and physics |
| [Complete serial partition setup](skills/md2asm/references/openifs/setup/serial_partition_map_contract.md) | All 36 arrays, public transform queries, 17-position blocks, complete maps and release |
| [Terrain storage](skills/md2asm/references/openifs/setup/orography_owner_storage.md#operational-grid) and [initialisation](skills/md2asm/references/openifs/setup/operational_orography_initialization.md) | Complete scalar and derivative transforms, both layouts, all block owners, independent physical checks and exact reference agreement |
| [Complete serial operational Geometry](skills/md2asm/references/openifs/setup/operational_owned_geometry_system.md) | 9 km grid and 137 layers, with 3,866,085,928 complete owner, metadata and status bytes matching exactly |
| [File and vertical startup](skills/md2asm/references/openifs/input/owned_operational_startup_inputs.md) and [complete distributed Geometry](skills/md2asm/references/openifs/setup/owned_distributed_geometry_system.md) | 9 km grid, 137 layers and four processes, with live file inputs, complete setup, exact stored bytes and release |
| [Loaded-model ownership](skills/md2asm/references/openifs/input/loaded_operational_model_composition.md), [configuration](skills/md2asm/references/openifs/setup/operational_model_configuration.md) and [distributed storage](skills/md2asm/references/openifs/setup/operational_enclosing_model_storage.md) | Four live process maps, distinct initial files, exact accepted child data, complete storage/input joins and release |
| [Distributed partition](skills/md2asm/references/openifs/setup/operational_distributed_partition.md), [upper-air loading](skills/md2asm/references/openifs/input/partitioned_operational_upper_air_loading.md) and [surface loading](skills/md2asm/references/openifs/input/partitioned_operational_surface_loading.md) | Four processes with complete transform and point maps, all 65.1 GB of upper-air and 7.02 GB of surface buffers exact, matched status and release |
| [Distributed terrain](skills/md2asm/references/openifs/setup/distributed_operational_orography_initialization.md) and [virtual temperature](skills/md2asm/references/openifs/input/operational_virtual_temperature_conversion.md) | All four process maps, complete assigned terrain and spectral owners, unchanged inputs and exact status |
| [Time coefficients](skills/md2asm/references/openifs/dynamics/operational_time_coefficients.md) and [forecast schedule](skills/md2asm/references/openifs/dynamics/operational_forecast_schedule.md) | Live time interval, source enable flags and closing wave-collection visit, with exact component results |
| [Returned wave fields](skills/md2asm/references/openifs/waves/returned_surface_field_copy.md) | Complete target owners, field remapping, final-block padding and every copied bit |
| [Persistent grid work](skills/md2asm/references/openifs/setup/operational_persistent_grid_work.md), [initialisation](skills/md2asm/references/openifs/dynamics/operational_grid_work_initialization.md) and [flux configuration](skills/md2asm/references/openifs/setup/operational_selected_flux_configuration.md) | Owned buffers, complete 14.48 GB zero assignment, actual reset settings, exact records and failure cleanup |
| [Model transforms](skills/md2asm/references/openifs/dynamics/operational_model_transform_callers.md) and [distributed spectral norms](skills/md2asm/references/openifs/dynamics/distributed_spectral_norms.md) | All four process maps, complete result bytes, ordered global sums, independent checks and exact status |
| [Inactive chemistry and aerosol storage](skills/md2asm/references/openifs/setup/inactive_composition_owners.md) | Complete defaults, the 152-byte allocated buffer and release |

Complete model initialization, the remaining operational time-step calculations, output and full CPU/GPU forecast acceptance remain unfinished. Native physics and GPU kernels still need qualified operational shapes. The earlier 14.13-second CPU result is for T21 and is not a 9 km timing.

The selected four-process route requires one node per process for the full forecast. Complete simultaneous memory requirements, including public transform work storage, remain under review.

The original aerosol-climatology routine fills a temporary latitude basis from column 1. The selected forecast also starts every block at column 1, and full and cropped-last comparisons agree exactly. For a first column above 1, the original can read an uninitialized tail. Separate partial-first Arm and GPU checks therefore claim agreement with each other, while retaining this original limitation.

In tested vertical-diffusion calls, the source and GPU results both show a gap of up to 0.139 W/m² between the column heat change and the tested boundary-flow balance. The source sets its upper boundary separately, so we preserve its equations and do not claim whole-column heat conservation.

For gas interpolation with zero model layers, complete output bytes agree but seven small cases expose an existing difference in numerical exception flags. Assembly retains its early return. The tested forecast has 19 layers, and its returned flags match the original.

In guarded shortwave cases, the original compiled routine changes platform register `x18`. Assembly preserves it. Original output bytes, floating-point controls, exception flags, system error values and ordinary saved-register obligations remain checked separately.

The original urban setup stores `RSBCONS=5.67e+08`, although its comment describes the Stefan–Boltzmann constant. This source value is preserved. Urban flux is disabled in the tested forecast, and this coefficient is excluded from the independent physical validation.

In a tested ice-formation call, the OpenIFS lake update stores an average water temperature of 277.13 K, while its limited temperature profile can represent at most 276.334 K. The profile describes how water temperature changes with depth. We retain the original OpenIFS equations and update rules, and report this known limitation separately from exact assembly byte agreement. Independent whole-forecast physics remains unverified.

The complete-storage verification gives both separate runs the same 7,744 incoming bytes in unused table bands and array padding, which holds allocated cells outside the physical grid. It preserves earlier frozen input bytes and checks active physical values unchanged before the first forecast calculation. Every returned byte remains compared, and the production run uses only original files without this verification initializer. Unused call arguments and incoming process-status values remain distinct and visible. Both forecasts naturally return the same floating-point controls, exception flags and system error value. The [direct power routine](skills/md2asm/references/openifs/support/power_original_rounding.md) supplies the accepted mathematical helper without the original C implementation.
