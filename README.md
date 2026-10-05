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
