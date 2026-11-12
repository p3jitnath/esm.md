# esm.md

esm.md develops CPU solvers from physics and mathematics in Markdown through portable Fortran source. An optimising compiler turns that source into machine code for each target architecture. The models retain ordered 64-bit floating-point calculations, independent physical checks and exact output comparisons. Earlier direct-assembly results remain part of the research record.

Start with the [short template](formulations/TEMPLATE.md), [shallow-water formulation](formulations/sw/dam_break.md) or [energy-balance formulation](formulations/ebm/budyko_sellers.md). The [md2fort skill](skills/md2fort/SKILL.md) supplies numerical methods, portable Fortran interfaces, compiler guidance, verification and optimisation. New CPU sources are Fortran. The verified shallow-water and energy-balance replacements are active; their earlier CPU assembly, direct GPU PTX and older source snapshots are archived locally with hashes and retained in Git history. Comparison tools, controls, data and archives stay local. [AGENTS.md](AGENTS.md) defines the writing and development rules.

## CPU Solvers

The **super-optimised Fortran** variants are labelled **ESM.md**. The active [shallow-water](src/sw/solver.f90) and [energy-balance](src/ebm/solver.f90) solvers use portable Fortran with interfaces callable from C. The shallow-water model follows water depth and horizontal flow on a periodic square. The energy-balance model follows temperature in latitude bands, balancing sunlight, heat loss and transport between neighbouring bands. An update advances every field in one cell through a complete time step.

Both CPU routes use the same Fortran/OpenMP coordinator to advance one coupled domain. OpenMP runs concurrent workers, each of which gathers a tile with enough neighbouring cells for its local steps and publishes its owned state. The coordinator selects either the ESM.md Fortran calculations or the handwritten assembly baseline. All gathering, overlap calculations, state publication, boundaries and synchronisation remain inside the solver timer. The [CPU execution contract](skills/md2fort/references/multicore_cpu_solvers.md) defines the interfaces and buffer requirements.

The matched campaign reserves 288 physical Neoverse V2 cores in exclusive job 8331485 on `nid011103` and gives each workload a configured ceiling of 248. The paired routes use the same selected actual team, shown below, with placement recorded in the accepted data. Each workload advances 1,000 complete steps from its shared frozen input bank and uses twelve rotated timing pairs. Rates divide useful updates by median elapsed time, with the observed minimum–maximum per-run rate [million updates/s]. The ratio is ESM.md rate divided by baseline rate.

| Model | Grid | Actual workers | Hand-tuned baseline | ESM.md | Ratio |
| --- | --- | ---: | ---: | ---: | ---: |
| Shallow water | 64² | 16 | 393.66 [392.89–395.83] | 375.12 [373.61–377.12] | 0.953× |
| Shallow water | 256² | 72 | 2,694.79 [2,661.39–2,715.26] | 2,483.82 [2,465.89–2,500.23] | 0.922× |
| Shallow water | 1,024² | 248 | 7,137.06 [6,993.53–7,444.57] | 6,488.71 [6,279.37–6,619.71] | 0.909× |
| Energy balance | 128 | 1 | 631.03 [622.39–635.54] | 597.88 [490.27–600.44] | 0.947× |
| Energy balance | 4,096 | 32 | 7,874.95 [7,551.83–7,926.89] | 7,665.80 [7,629.71–7,693.43] | 0.973× |
| Energy balance | 65,536 | 72 | 33,673.50 [32,450.12–33,827.02] | 31,543.50 [30,656.30–32,619.65] | 0.937× |

ESM.md reaches 90.9–97.3% of the baseline rate across these six workloads. The largest water case uses all 248 workers, while the other selected teams follow the preliminary baseline screens within that ceiling.

Separate scaling measurements vary the configured CPU budget through 1, 2, 4, 8, 16, 32, 64, 72, 128, 144 and 248 while keeping each grid, input and 1,000 complete steps fixed. Their records distinguish requested budgets, actual teams and workers with at least one owned cell. The 128-band model caps its team at 128, so its 144- and 248-core budget entries do not represent larger teams. The [complete scaling data](paper/pasc27/poster/data/cpu-scaling-results-20261112.json) contain all 66 model/grid/budget conditions, with twelve pairs at each point. The largest observed Fortran points use 64, 72 and 144 cores for the three water grids, and 1, 32 and 72 cores for the three energy-balance grids. Local step groups also change at declared dispatch points, so these measurements describe complete schedules. At one core, Fortran exceeds the baseline point by 2.64% for 4,096 bands and 4.80% for 65,536 bands. These specific advantages do not extend to every grid or budget.

Every accepted timed run matches the canonical current, preceding and first-stage state buffers with zero differing bytes. The [accepted CPU data](paper/pasc27/poster/data/cpu-results-20261112.json) retain every elapsed-time value, actual team, source/input identity and independently checked pair order. Floating-point exception flags record events such as division by zero or rounding. The canonical reference’s immediate flags were not recorded, so acceptance compares the five observed standard IEEE flags across implementations. Compilation, allocation, initial writes that place memory pages near their owners, input restoration, verification and file output stay outside the timer. Strict compiler options preserve the declared arithmetic, including separate multiplication and addition, gradual underflow and ordered rounding.

The same source can be recompiled for x86 or another supported CPU by selecting that processor's compiler options, then repeating scientific, exact-output and performance checks. These measurements establish performance only on the stated Neoverse V2 hardware. CUDA Fortran is a separate route that requires a supported NVIDIA GPU, including when its host uses x86.

The earlier formatting checkpoint used a pinned `fprettify` revision on 224 project Fortran files. The two final accepted CPU sources produce byte-identical output on a read-only repeated formatting pass, including quoted literals and OpenMP directives. Their numerical qualification used the exact formatted sources, so these later checks require no rebuild or repeated simulation. Active Python tools use Black. No active Julia files were present; the reusable skills require JuliaFormatter when Julia sources are used. The [editable poster project](paper/pasc27/poster/README.md) contains the PowerPoint, PDF, plotting sources, data and licensed assets.

## GPU Solvers

The active [shallow-water](src/sw/gpu/solver.cuf) and [energy-balance](src/ebm/gpu/solver.cuf) solvers use CUDA Fortran and are labelled **ESM.md**. NVIDIA Fortran compiles their numerical calculations and state publication into GPU machine code. The comparison baseline is written in PTX, NVIDIA’s virtual instruction language, and assembled separately. Its selected source, build commands and verification evidence are archived locally. The [md2fort-gpu skill](skills/md2fort-gpu/SKILL.md) and [execution contract](skills/md2fort-gpu/references/gpu-contract.md) describe both routes.

This comparison uses one GH200 GPU in exclusive job 8331485 on `nid011103`, with host CPU 1 and memory domain 0. Each workload advances 1,000 complete time steps from the same frozen input bank and has twelve rotated timing pairs. A complete update advances every field in one cell through both stages and the required boundaries. Rates are useful updates divided by median elapsed time, shown with the minimum–maximum observed per-run rate [million updates/s]. The ratio is ESM.md rate divided by baseline rate.

| Model | Grid | Hand-tuned baseline | ESM.md | Ratio |
| --- | --- | ---: | ---: | ---: |
| Shallow water | 64² | 1,162.50 [1,161.86–1,162.81] | 1,051.81 [1,051.55–1,052.20] | 0.905× |
| Shallow water | 256² | 6,843.52 [6,838.70–6,847.07] | 6,785.51 [6,774.73–6,788.76] | 0.992× |
| Shallow water | 1,024² | 8,325.77 [8,304.57–8,361.50] | 8,521.20 [8,483.74–8,544.23] | 1.023× |
| Energy balance | 128 | 968.99 [940.29–971.11] | 971.70 [968.05–973.71] | 1.003× |
| Energy balance | 4,096 | 15,576.51 [15,468.28–15,609.76] | 15,769.37 [15,753.85–15,792.72] | 1.012× |
| Energy balance | 65,536 | 148,266.12 [147,944.81–148,610.41] | 152,972.81 [152,380.95–153,270.47] | 1.032× |

Every timed run matches the canonical complete current, preceding and first-stage state buffers, with zero differing bytes. Independent physical, trajectory, boundary and buffer checks also pass. The [accepted data](paper/pasc27/poster/data/gpu-results-20261112.json) preserve all 144 elapsed-time values, source and input identities, acceptance records and observation limits.

Small-grid water reuses neighbouring values in shared memory, while the larger grids use compiled face calculations. Energy balance advances several complete steps in overlapping tiles and publishes the required states. NVIDIA HPC SDK 24.11 uses CUDA 12.6 with contraction and underflow flushing disabled. CUDA events time warmed replay of the full prepared launch sequence. Compilation, setup, allocation, transfers, input restoration, verification and file writing stay outside the timer.

ESM.md reaches 90.5% of the baseline rate on the smallest water grid and 99.2–103.2% on the other five workloads. Post-sample telemetry for the largest water grid reports software power limiting under the unchanged 900 W device policy for both routes, with no recorded thermal event. These measurements describe the stated workloads and hardware. Older controls and timing records remain archived locally and in Git history.

The [poster’s language comparisons](paper/pasc27/poster/README.md) show a separate matched eight-route campaign for Assembly, ESM.md and tuned and vanilla Fortran, Julia and compiled Python on both processors. Each route advances 1,000 complete steps from the same frozen input bank. CPU teams use 248 workers for one coupled domain, capped at 128 for the 128-band EBM, and GPU runs use one GH200. Points divide useful updates by median elapsed time from twelve rotated accepted runs, with the observed individual-rate ranges. The earlier selected-team CPU and two-route GPU measurements above retain their original records and conclusions. Historical October and 8 November records remain available locally and in Git history.

## OpenIFS Forecasts

Current verification targets step 0 only. The reference completed that step, and the corrected native physics setup passes on all 32 processes; numerical byte agreement remains pending. See the [operational handoff](OPERATIONAL_FORECAST_HANDOFF.md).

The OpenIFS 48.1.1 work has two distinct scopes. The coarse autonomous CPU forecast has completed. The operational 9 km CPU forecast remains unverified. Component checks do not establish a complete operational forecast.

### Coarse CPU Forecast

The [autonomous forecast](skills/md2fort/references/openifs/input/standalone_weather_forecast.md) advances 24 hours from 15 October 2004 on 2,048 horizontal points and 19 atmospheric layers. Assembly owns loading, configuration, setup, storage, the time loop, weather calculations, state updates and output. It runs without original OpenIFS routines or its harness. Public file-format, transform, mathematical and runtime services remain explicit.

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

The latest complete GPU run finishes 25 steps in **464.19 seconds**, including input, setup and output. This single measurement is about 33 times the CPU median. Complete internal-state and counter checks remain pending for that image, so no GPU speedup is accepted. The [mathematical support](skills/md2fort-gpu/references/openifs/mathematical_support.md) and [assembly launcher](skills/md2fort-gpu/references/openifs/cuda_runtime.md) state its numerical and storage rules.

Component acceptance and its limits are recorded in the [GPU contracts](skills/md2fort-gpu/SKILL.md). These checks do not establish a complete operational GPU forecast.

### Operational 9 km Forecast

The CPU port now has compiled Fortran counterparts for all 1,203 archived assembly source files. The current target is **step 0 only, with byte verification pending**. The original reference completed step 0 and closed its three +000000 output files. Raw reference state after step 0 was not captured, so full-state verification still needs that checkpoint. See the [operational forecast handoff](OPERATIONAL_FORECAST_HANDOFF.md) and [ordered Fortran source catalog](src/openifs/source_catalog.json) for the current sources, compiled corrections and remaining checks. The assembly results below describe earlier implementations and do not establish acceptance of the Fortran port.

The target has 6,599,680 horizontal points, 137 atmospheric layers and 192 steps of 450 seconds for a 24-hour forecast. A supplied Fortran reference completes that workload with 32 MPI processes and 32 OpenMP threads per process, using strict arithmetic and single-threaded OpenBLAS. Its effective block size is 24 points. MPI exchanges data between processes, while OpenMP shares work between threads.

The standalone CPU executable starts without the OpenIFS harness. The matching 32-process assembly run has no confirmed completed model step or complete saved-output acceptance. The earlier **14.13-second result is for the coarse model**, and is not a 9 km timing. Complete raw-state comparison, independent physical acceptance and full output agreement remain required. Memory and supported runtime shapes remain limited by the linked contracts. The [lake input correction](skills/md2fort/references/openifs/surface/lake_temperature_profile.md) admits the shape value produced by the frozen input encoding. Four captured-column comparisons match 262,144 complete protected bytes, and 36 independent physical checks pass. The integrated forecast still needs complete step and output verification.

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

The original solar averaging can omit daylight from a neighbouring day when a long daylight interval crosses midnight. A supported 9 km grid-cell witness exposes this limit. The [entry that matches the original behaviour](skills/md2fort/references/openifs/physics/solar_zenith_source_compatibility.md) preserves the calculation and passes its focused byte comparison. Its independent periodic-light check reports the physical discrepancy. The strict solar entry retains its qualified physical domain.

The supplied 21 June 2026 climate input has two present top-soil temperature entries that original OpenIFS uses as sea-surface temperatures. Its update and assembly both produce −1870.689453125 K and −830.193359375 K at those sea cells. The input values and source update are preserved. Exact implementation agreement passes at this boundary, while physical temperature admissibility fails.

The operational turbulence component preserves original `VSURF` sea-derivative ordering for agreement with the unchanged OpenIFS reference. That source derivative includes an extra salinity factor of 0.98 and is about two percent below the derivative of its humidity equation. This physical-model limitation is explicit; the earlier corrected sea-derivative model remains separate. See the [runtime turbulence contract](skills/md2fort/references/openifs/surface/runtime_surface_turbulence.md).

All 2,086,488,208 bytes of the initial upper-air output match the supplied operational Fortran reference, while initial surface files still differ. Full operational output agreement and comparative timing remain unverified. The [basic formulations](formulations/openifs/README.md) explain the physical balances, and the [coverage record](src/openifs/README.md) retains detailed checks and limitations.
