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

The openifs-md branch extends this workflow to OpenIFS 48.1.1. Assembly replaces 274 original routine bodies. Their small checks cover independent physical relations within declared input ranges, with known source limits recorded below. The checked forecast-call cases pass exact byte comparisons in a coarse global forecast.

| Check | Coverage | Differing bytes |
| --- | --- | ---: |
| Radiation-field preparation | 6,400 complete calls | 0 |
| Plant photosynthesis | 6,450 complete C3/C4 calls | 0 |
| Interpolation boundaries | 2,150 complete calls | 0 |
| Fourier coefficient transfer | 352 complete field-count/latitude pairs | 0 |
| Spectral forecast step | 25 complete calls and seven direct stages | 0 |
| Complete final state | 685 buffers across 27,486,113 bytes | 0 |
| Saved forecast files | 10 files across 618,140 bytes | 0 |

The latest verified forecast starts on 15 October 2004 and advances 24 hours on 2,048 grid points with 19 atmospheric levels. Input, setup, metadata services and retained reference forwards still use Fortran. Complete assembly coverage, independent whole-forecast physics and external-library arithmetic checks remain unfinished. Whole-forecast speed has not been measured. The [OpenIFS verification note](src/openifs/README.md) gives the latest evidence and the limits of complete-storage comparisons.

The [basic formulations](formulations/openifs/README.md) explain the physical balances. The [coverage tables](src/openifs/README.md) give accepted counts and verification limits. All **255 audited weather and forcing routines** in this T21 main phase have accepted assembly replacements. The overlapping broader lists still have 95 local calculations and 438 main-forecast bodies remaining. The ordered original routine names and source paths remain in the local records.

## Notes

In a tested ice-formation call, the OpenIFS lake update stores an average water temperature of 277.13 K, while its limited temperature profile can represent at most 276.334 K. The profile describes how water temperature changes with depth. We retain the original OpenIFS equations and update rules, and report this known limitation separately from exact assembly byte agreement. Independent whole-forecast physics remains unverified.

For the complete-storage comparison, both forecasts use the same input bytes in the unused part of an allocated albedo table. OpenIFS writes only its physical part during setup. The unused bytes are bound before the first native calculation, and all 1,344 final table bytes remain in the comparison.
