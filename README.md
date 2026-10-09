# esm.md

esm.md generates Arm assembly from short physics and mathematics notes in Markdown. Assembly is a processor’s low-level instruction language. We compare it with Fortran, Julia, and compiled Python on a Neoverse V2 processor, using identical 64-bit floating-point calculations.

The tables show median speed in million complete cell updates per second for optimised solvers across twelve quiet-node runs. Each update advances one cell by one full time step. All seven variants, including the unchanged vanilla language controls, pass independent physics checks and produce identical output bytes. The [full results](bench/results.md) include the controls and timing variation.

## Shallow water

This model follows water depth and horizontal flow over a flat bottom. Gravity creates waves when the depth is uneven. Each grid has the stated number of cells in both horizontal directions.

| Grid | Assembly | Fortran | Julia | Python |
| --- | ---: | ---: | ---: | ---: |
| 64² | 89.80 | 84.94 | 78.39 | 56.40 |
| 256² | 95.31 | 81.51 | 77.00 | 56.42 |
| 1024² | 82.66 | 72.23 | 70.77 | 52.61 |

## Budyko–Sellers energy balance

This model gives one average temperature for each latitude band. Sunlight warms the surface, radiation cools it, and heat moves between neighbouring bands. The grid size is the number of bands from the South Pole to the North Pole.

| Grid | Assembly | Fortran | Julia | Python |
| --- | ---: | ---: | ---: | ---: |
| 128 | 650.56 | 510.74 | 531.46 | 548.93 |
| 4096 | 599.68 | 498.27 | 509.81 | 493.75 |
| 65536 | 590.51 | 488.69 | 489.47 | 514.88 |

Start with the [short template](formulations/TEMPLATE.md), [shallow-water maths](formulations/shallow_water.md), or [energy-balance maths](formulations/budyko_sellers.md). The [md2asm skill](skills/md2asm/SKILL.md) supplies the numerical and implementation details and retains the measured assembly optimisations.

Build with `make all ebm` on the target processor, then follow the [evaluation instructions](bench/README.md). [AGENTS.md](AGENTS.md) defines the first-year-undergraduate writing convention. Runtimes, binaries, and local research records stay outside Git.

## OpenIFS development

The openifs-md branch extends the workflow to OpenIFS 48.1.1. Direct assembly implements eleven complete routines for surface changes, moist-air properties, pressure terms, wind accelerations, physics updates and column diagnostics. All eleven pass independent small checks and byte comparisons inside the upstream coarse forecast. Files are grouped by dynamics, physics, surface and waves, with forecast dynamics taking priority.

| Verified routine | Critical calls | Calls in the forecast | Differing bytes |
| --- | ---: | ---: | ---: |
| CPSPE surface update | 449 | 2,150 | 0 |
| GPRCP moist-air properties | 3,976 | 13,846 | 0 |
| GPPWC column integral | 13 | 36,120 | 0 |
| GPRT thermal pressure | 73 | 2,150 | 0 |
| GPGRP pressure force | 46 | 2,150 | 0 |
| GPMKTEND state-change rates | 69 | 2,150 | 0 |
| GPADDSLPHY physics increments | 117 | 2,150 | 0 |
| GP_TNDLAGADIAB_UV wind | 137 | 2,150 | 0 |
| GPGRXYB pressure coefficients | 192 | 2,150 | 0 |
| GPTCO3 scalar-column integral | 66 | 2,150 | 0 |
| GP_SPV surface pressure | 122 | 2,150 | 0 |

All ten saved forecast output files match a fresh strict-source Fortran run using the same verified pressure math library. Other stages remain in Fortran, and whole-forecast independent physics and external-library arithmetic checks remain unfinished. [Basic formulations](formulations/openifs/README.md) and [verification](bench/openifs/README.md) describe the coverage and commands. OpenIFS performance has not been measured.
