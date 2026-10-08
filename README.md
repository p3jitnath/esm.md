# esm.md

This `gpu` branch carries the shallow-water and Budyko–Sellers models from GitHub main `6536b88` to an NVIDIA GH200. It generates GPU assembly directly from the same short physics and mathematics notes in Markdown. Handwritten PTX is assembled into NVIDIA machine instructions and compared with vanilla and tuned GPU Fortran, Julia and compiled Python. Every implementation preserves the original ordered 64-bit floating-point calculations and canonical output bytes.

Read the [GPU evaluation instructions](bench/gpu/README.md), [GPU results](bench/gpu/results.md) and [md2asm-gpu skill](skills/md2asm-gpu/SKILL.md). The GPU plots use the same units as the CPU study, million complete cell updates per second. Each update includes both stages and boundaries, and a shallow-water update includes all three fields. The final GPU comparison uses twelve accepted repetitions of all seven variants on one fixed GPU in an exclusive quiet-node allocation.

The CPU results below are the historical upstream comparison on one Neoverse V2 processor. They remain separate from the GPU measurements. Their tables show median speed in million complete cell updates per second across twelve quiet-node runs, and the [original full results](bench/results.md) include the controls and timing variation.

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
