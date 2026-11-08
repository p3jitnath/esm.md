# esm.md

esm.md develops CPU solvers from physics and mathematics in Markdown through portable Fortran source. An optimising compiler turns that source into machine code for each target architecture. The models retain ordered 64-bit floating-point calculations, independent physical checks and exact output comparisons. Earlier direct-assembly results remain part of the research record.

Start with the [short template](formulations/TEMPLATE.md), [shallow-water formulation](formulations/sw/2d_periodic.md) or [energy-balance formulation](formulations/ebm/budyko_sellers.md). The [md2asm skill](skills/md2asm/SKILL.md) supplies numerical methods, portable Fortran interfaces, compiler guidance, verification and optimisation. New CPU sources are Fortran. The verified shallow-water and energy-balance replacements are active; their earlier CPU assembly, direct GPU PTX and older source snapshots are archived locally with hashes and retained in Git history. Comparison tools, controls, data and archives stay local. [AGENTS.md](AGENTS.md) defines the writing and development rules.

## CPU Solvers

These historical tables compare optimised solvers on one Neoverse V2 processor. Values are median million complete cell updates per second across twelve quiet-node runs. Higher is faster. An update advances every field in one cell through a full time step. All seven variants, including vanilla Fortran, Julia and compiled Python controls, pass physical checks and produce identical output bytes. Detailed controls and timing variation remain in the local research records.

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

### esm.md CPU

The requested **super-optimised Fortran** variants use the label **esm.md** in the poster charts. The [editable poster project](paper/pasc27/poster/README.md) contains the PowerPoint, PDF, plotting scripts, data and assets.

The new [shallow-water](src/sw/solver.f90) and [energy-balance](src/ebm/solver.f90) sources use standard Fortran with interfaces callable from C. Their dimensions come from runtime arguments, so the same executable handles the admitted grids. Recompile these sources for x86 or another supported CPU, select that processor’s compiler options, then verify exact outputs and performance there. Current acceptance and timings cover one Neoverse V2 core; they do not establish x86 performance. CUDA Fortran is a separate GPU route and still requires a supported NVIDIA GPU even with an x86 host.

This twelve-pair checkpoint uses CPU 1 and memory domain 0 in exclusive job 8199657 on `nid010573`. Both implementations use the same arrays and ordered arithmetic. Rates are median [minimum–maximum] million complete cell updates per second. The CPU performance target remains open, and these values replace earlier exploratory estimates.

| Model | Grid | Assembly | esm.md | Ratio |
| --- | --- | ---: | ---: | ---: |
| Shallow water | 64² | 89.857 [89.791–89.890] | 84.371 [84.350–84.385] | 0.939× |
| Shallow water | 256² | 95.259 [95.199–95.292] | 87.491 [87.429–87.533] | 0.918× |
| Shallow water | 1024² | 82.573 [82.520–82.618] | 78.048 [78.038–78.089] | 0.945× |
| Energy balance | 128 | 654.423 [652.569–655.570] | 642.073 [641.904–642.258] | 0.981× |
| Energy balance | 4096 | 630.581 [628.924–632.546] | 603.740 [603.607–603.967] | 0.957× |
| Energy balance | 65536 | 615.444 [612.960–619.474] | 561.561 [561.314–561.881] | 0.912× |

All timed current, preceding and first-stage state buffers match the canonical Fortran bytes exactly. Independent acceptance retains 23 water scientific cases and four spacing-edge trajectories, and 19 energy-balance scientific cases with focused boundary, threshold and repeated-buffer checks. The timer includes complete repeated updates and excludes compilation, setup, input restoration, verification and file writing. Hardware calibration completed several arithmetic and first-level-cache groups but stopped before its final raw-sample record, so no complete new CPU roofline result is claimed.

The formatting checkpoint used a pinned `fprettify` revision on 224 project Fortran files. All selected files preserve executable tokens and compiler directives, and a second formatting pass makes no change. Both selected CPU libraries rebuild byte for byte. The formatted GPU sources preserve executable instructions, constants, data, relocations and launch metadata, with debug-only differences recorded separately. Active Python tools were formatted with Black and retain identical syntax trees. No active Julia files were present; the reusable skills require JuliaFormatter when Julia sources are used.

## GPU Solvers

The historical comparison runs the same models on one NVIDIA GH200 GPU. For that earlier route, the LLM emitted PTX, NVIDIA’s virtual assembly language, and NVIDIA’s assembler created machine code. The [GPU skill](skills/md2asm-gpu/SKILL.md) and [execution contract](skills/md2asm-gpu/references/gpu-contract.md) describe this route. Sources are [shallow water](https://github.com/p3jitnath/esm.md/blob/8be04b8/src/sw/gpu/2d_rusanov_ssprk2.ptx) and [energy balance](https://github.com/p3jitnath/esm.md/blob/8be04b8/src/ebm/gpu/budyko_sellers.ptx).

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

### esm.md GPU

The new [shallow-water](src/sw/gpu/solver.cuf) and [energy-balance](src/ebm/gpu/solver.cuf) variants are labelled **esm.md**. NVIDIA Fortran compiles these sources into GPU instructions. The earlier assembly sources are archived, and their comparison results above remain historical records. The [GPU execution contract](skills/md2asm-gpu/references/gpu-contract.md) records the interfaces, complete launch sequence and strict build options.

This fresh comparison uses twelve rotated pairs per workload on one GH200 in exclusive job 8199657 on `nid010573`. Both variants use GPU 0, host CPU 7 and memory domain 0. Rates are million complete cell updates per second, shown as median [minimum–maximum]. A complete update includes both time stages, every field and the boundaries. The ratio is Fortran speed divided by assembly speed.

| Model | Grid | Assembly | esm.md | Ratio |
| --- | --- | ---: | ---: | ---: |
| Shallow water | 64² | 675.22 [674.57–675.92] | 707.93 [704.40–708.67] | 1.048× |
| Shallow water | 256² | 5813.54 [5802.34–5821.02] | 6743.69 [6733.21–6750.20] | 1.160× |
| Shallow water | 1024² | 8696.90 [8648.62–8712.14] | 8887.03 [8831.60–8900.80] | 1.022× |
| Energy balance | 128 | 740.29 [719.10–752.39] | 929.85 [913.47–937.73] | 1.256× |
| Energy balance | 4096 | 5033.10 [4964.10–5042.78] | 7505.30 [7454.05–7558.94] | 1.491× |
| Energy balance | 65536 | 60639.37 [59768.36–61248.60] | 88592.46 [86316.76–90644.54] | 1.461× |

Fortran is faster in every paired run. All 144 timed runs match the complete state buffers and both saved phase files, with zero differing bytes. Independent acceptance covers 34 scientific cases and nine graph schedules for water, and 40 scientific cases and 25 graph schedules for the integrated energy-balance source. These checks include conservation, analytic solutions, complete trajectories, boundaries, buffer guards, threshold ties and subnormal values.

Water combines preparation and update on small grids, uses row-based work on larger grids and declares read-only inputs precisely. Energy balance retains four active thread groups on its small grid and advances eight steps inside each larger tile. All model arithmetic runs on the GPU. NVIDIA HPC SDK 24.11 uses CUDA 12.6 with contraction and underflow flushing disabled. GPU events time warmed graph replay, while compilation, allocation, transfers, verification and file writing stay outside the timer.

Simple hardware probes give conditional performance guides. At 1024², water reaches about 90% of the streaming-copy guide under an assumed 328 logical array bytes per update. Actual solver memory traffic is unmeasured. The energy-balance guide includes repeated halo calculations, which add about 16% to the useful stage work on large grids. These guides and the recorded variation limit conclusions to the declared workloads and hardware. Detailed records remain under the ignored local research folders.

## OpenIFS Forecasts

Current verification targets step 0 only. The reference completed that step, and the corrected native physics setup passes on all 32 processes; numerical byte agreement remains pending. See the [operational handoff](OPERATIONAL_FORECAST_HANDOFF.md).

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

The forecast results in this section describe the archived numerical method. The current conservative surface and cloud updates have passed their declared component checks; complete forecast state and file comparisons for the revised method remain pending.

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

Component acceptance and its limits are recorded in the [GPU contracts](skills/md2asm-gpu/SKILL.md). These checks do not establish a complete operational GPU forecast.

### Operational 9 km Forecast

The CPU port now has compiled Fortran counterparts for all 1,203 archived assembly source files. The current target is **step 0 only, with byte verification pending**. The original reference completed step 0 and closed its three +000000 output files. Raw reference state after step 0 was not captured, so full-state verification still needs that checkpoint. See the [operational forecast handoff](OPERATIONAL_FORECAST_HANDOFF.md) and [ordered Fortran source catalog](src/openifs/source_catalog.json) for the current sources, compiled corrections and remaining checks. The assembly results below describe earlier implementations and do not establish acceptance of the Fortran port.

The target has 6,599,680 horizontal points, 137 atmospheric layers and 192 steps of 450 seconds for a 24-hour forecast. A supplied Fortran reference completes that workload with 32 MPI processes and 32 OpenMP threads per process, using strict arithmetic and single-threaded OpenBLAS. Its effective block size is 24 points. MPI exchanges data between processes, while OpenMP shares work between threads.

The standalone CPU executable starts without the OpenIFS harness. The matching 32-process assembly run has no confirmed completed model step or complete saved-output acceptance. The earlier **14.13-second result is for the coarse model**, and is not a 9 km timing. Complete raw-state comparison, independent physical acceptance and full output agreement remain required. Memory and supported runtime shapes remain limited by the linked contracts. The [lake input correction](skills/md2asm/references/openifs/surface/lake_temperature_profile.md) admits the shape value produced by the frozen input encoding. Four captured-column comparisons match 262,144 complete protected bytes, and 36 independent physical checks pass. The integrated forecast still needs complete step and output verification.

All 32 CPU processes reached the end of step 0 in the current operational assembly run. The complete spectral files `ICMSHacfl+000000` and `ICMUAacfl+000000` match Fortran across 4,307,954,808 bytes, with zero differing bytes and stable file identities before and after reading. Spectral fields represent weather fields as waves. The gridpoint file differs, so complete step-0 output agreement remains unverified. Step 1 is stopped in vertical continuity, which calculates transport through atmospheric layers, and step 2 has not run. Raw state agreement and a complete operational forecast remain pending.

The [OpenIFS coverage record](src/openifs/README.md#input-and-setup-components) and linked contracts describe accepted input, setup and numerical components. Their individual checks do not establish agreement of the complete 32-process forecast.

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
