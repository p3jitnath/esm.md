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

## OpenIFS development

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

Three matched complete-process runs per variant on one pinned CPU of a quiet exclusive Grace node give the results below. The timer includes loading, setup, forecast calculations and output, with checks outside the timer. Every run reproduces all ten saved files and the 59 observed final numerical fields exactly. The larger complete-state comparison above separately accepts the changed implementation.

Selected earlier batches are shown below, with the full history in the local research records. Each row comes from a separate matched batch. Each time is the median followed by the minimum–maximum range, in seconds.

| Matched Change | Before (s) | After (s) | Speedup |
| --- | ---: | ---: | ---: |
| Compact exact arithmetic | 76.98 [76.64–83.88] | 37.75 [37.23–44.64] | 2.04× |
| Wider clears, status writes and grouped integer sequences | 37.47 [37.42–37.50] | 31.49 [31.19–31.64] | 1.19× |
| Bounded exact integers for widely separated terms | 31.15 [30.91–31.68] | 26.65 [26.58–26.70] | 1.17× |
| Four-cell reflection with eight-value exponentials | 22.48 [22.23–22.64] | 22.04 [21.63–22.43] | 1.020× |

The runtime setting `EC_PMON=0` disables hardware energy monitoring. Energy and power diagnostic columns become zero. Weather calculations, memory and status reports, and all canonical forecast files remain in the timed process. The first two contrasts below come from one rotated nine-run batch, with three runs per variant. The later contrasts each come from a separate batch of three alternating matched pairs, with monitoring disabled for both variants.

| Matched Change | Before (s) | After (s) | Speedup |
| --- | ---: | ---: | ---: |
| Same solver, energy monitoring disabled | 22.11 [21.84–22.39] | 20.59 [20.58–20.61] | 1.074× |
| Prepared public arithmetic, monitoring disabled for both | 20.59 [20.58–20.61] | 20.55 [20.55–20.55] | 1.002× |
| Decoded mathematical constants and radiation layer counts, monitoring disabled for both | 19.81 [19.81–19.81] | 19.71 [19.71–19.72] | 1.005× |
| Bounded integer rounding and grouped polynomial seeds, monitoring disabled for both | 19.72 [19.71–19.73] | 19.32 [19.30–19.33] | 1.021× |

The latest median is **19.32 seconds** for this forecast and machine. The joint change recovers a small product-rounding error from its exact integer bits and groups three independent polynomial seeds. Each seed retains its original separate rounding. All three wall-time and user CPU pairs favour the combined change, with nonoverlapping ranges. User CPU medians are 19.58 [19.54–19.58] and 19.17 [19.14–19.18] seconds. The timer reports 0.01 seconds. The measurements establish the joint gain without separating the two contributions. General input paths remain available, and performance on other forecast inputs remains unmeasured.

The [basic formulations](formulations/openifs/README.md) explain the physical balances. The [coverage tables](src/openifs/README.md) give accepted counts and verification limits. All **255 audited weather and forcing routines** in this T21 main phase have accepted assembly replacements. The overlapping broader lists still have 91 local calculations and 358 main-forecast bodies remaining. The ordered original routine names and source paths remain in the local records.

## Notes

The original urban setup stores `RSBCONS=5.67e+08`, although its comment describes the Stefan–Boltzmann constant. This source value is preserved. Urban flux is disabled in the tested forecast, and this coefficient is excluded from the independent physical validation.

In a tested ice-formation call, the OpenIFS lake update stores an average water temperature of 277.13 K, while its limited temperature profile can represent at most 276.334 K. The profile describes how water temperature changes with depth. We retain the original OpenIFS equations and update rules, and report this known limitation separately from exact assembly byte agreement. Independent whole-forecast physics remains unverified.

The complete-storage verification gives both separate runs the same 7,744 incoming bytes in unused table bands and array padding, which holds allocated cells outside the physical grid. It preserves earlier frozen input bytes and checks active physical values unchanged before the first forecast calculation. Every returned byte remains compared, and the production run uses only original files without this verification initializer. Unused call arguments and incoming process-status values remain distinct and visible. Both forecasts naturally return the same floating-point controls, exception flags and system error value. The [direct power routine](skills/md2asm/references/openifs/support/power_original_rounding.md) supplies the accepted mathematical helper without the original C implementation.
