# Implementation comparison

These measurements ran overnight on 4–5 October 2026 on one Arm Neoverse V2 core in quiet exclusive Slurm job 7072889, node nid011277. Every implementation uses the same inputs, numerical method, and ordered 64-bit floating-point calculations. Assembly is faster than optimised Fortran in all twelve matched runs at each of the six workloads.

Speed is measured in million complete cell updates per second; each update advances one cell through one full time step. The median is the middle timing of twelve runs. MAD is the median absolute distance from that middle value, while the range gives the shortest and longest observed times. These ranges describe the runs and are not confidence intervals. Vanilla means the unchanged language control, compiled for the same processor; optimised means its loops were tuned using measured performance.

The [compact evidence](results.json) records all accepted timings, physical checks, input and output hashes, implementation fingerprints, hardware counters, and software versions. See the [evaluation instructions](README.md) to reproduce the comparison.

## Shallow water

| Grid | Implementation | Million updates/s | Median ms | MAD ms | Range ms |
| --- | --- | ---: | ---: | ---: | --- |
| 64² | Assembly | 89.80 | 373.639 | 0.027 | 373.581–373.868 |
| 64² | Fortran, optimised | 84.94 | 395.044 | 0.049 | 394.967–395.468 |
| 64² | Fortran, vanilla | 40.95 | 819.440 | 0.230 | 818.766–820.191 |
| 64² | Julia, optimised | 78.39 | 428.064 | 0.412 | 427.221–428.798 |
| 64² | Julia, vanilla | 30.62 | 1095.675 | 0.475 | 1093.279–1097.710 |
| 64² | Python, optimised | 56.40 | 594.926 | 0.080 | 594.630–595.202 |
| 64² | Python, vanilla | 30.05 | 1116.662 | 0.147 | 1116.496–1117.100 |
| 256² | Assembly | 95.31 | 352.057 | 0.160 | 351.856–352.462 |
| 256² | Fortran, optimised | 81.51 | 411.667 | 0.511 | 411.128–413.605 |
| 256² | Fortran, vanilla | 41.26 | 813.332 | 0.679 | 810.982–819.639 |
| 256² | Julia, optimised | 77.00 | 435.799 | 1.161 | 431.761–439.737 |
| 256² | Julia, vanilla | 30.92 | 1085.279 | 1.751 | 1078.352–1091.987 |
| 256² | Python, optimised | 56.42 | 594.700 | 0.479 | 594.193–595.582 |
| 256² | Python, vanilla | 30.40 | 1103.920 | 0.372 | 1103.082–1105.487 |
| 1024² | Assembly | 82.66 | 405.914 | 0.068 | 405.725–405.985 |
| 1024² | Fortran, optimised | 72.23 | 464.554 | 0.371 | 463.721–471.251 |
| 1024² | Fortran, vanilla | 37.38 | 897.712 | 0.642 | 896.296–898.743 |
| 1024² | Julia, optimised | 70.77 | 474.141 | 1.182 | 470.926–477.081 |
| 1024² | Julia, vanilla | 30.65 | 1094.749 | 0.833 | 1093.437–1100.664 |
| 1024² | Python, optimised | 52.61 | 637.740 | 0.530 | 636.569–639.309 |
| 1024² | Python, vanilla | 29.32 | 1144.531 | 0.126 | 1144.379–1145.493 |

## Budyko–Sellers energy balance

| Grid | Implementation | Million updates/s | Median ms | MAD ms | Range ms |
| --- | --- | ---: | ---: | ---: | --- |
| 128 | Assembly | 650.56 | 196.753 | 0.183 | 196.338–197.517 |
| 128 | Fortran, optimised | 510.74 | 250.617 | 0.399 | 249.298–251.096 |
| 128 | Fortran, vanilla | 504.79 | 253.571 | 0.468 | 252.558–254.662 |
| 128 | Julia, optimised | 531.46 | 240.848 | 0.336 | 239.953–241.781 |
| 128 | Julia, vanilla | 283.75 | 451.102 | 0.709 | 450.330–452.448 |
| 128 | Python, optimised | 548.93 | 233.180 | 0.176 | 232.998–234.219 |
| 128 | Python, vanilla | 324.64 | 394.288 | 0.112 | 393.808–394.717 |
| 4096 | Assembly | 599.68 | 273.211 | 0.086 | 272.923–273.684 |
| 4096 | Fortran, optimised | 498.27 | 328.818 | 0.560 | 328.151–335.277 |
| 4096 | Fortran, vanilla | 457.34 | 358.247 | 0.073 | 358.095–358.364 |
| 4096 | Julia, optimised | 509.81 | 321.374 | 2.068 | 315.267–327.355 |
| 4096 | Julia, vanilla | 283.04 | 578.865 | 3.858 | 569.363–592.181 |
| 4096 | Python, optimised | 493.75 | 331.831 | 0.302 | 331.292–333.013 |
| 4096 | Python, vanilla | 383.12 | 427.646 | 0.096 | 427.356–428.587 |
| 65536 | Assembly | 590.51 | 227.290 | 1.286 | 225.643–230.778 |
| 65536 | Fortran, optimised | 488.69 | 274.648 | 0.814 | 272.457–276.935 |
| 65536 | Fortran, vanilla | 385.84 | 347.859 | 0.702 | 345.759–350.015 |
| 65536 | Julia, optimised | 489.47 | 274.210 | 4.313 | 266.081–290.392 |
| 65536 | Julia, vanilla | 266.40 | 503.820 | 7.473 | 492.677–530.003 |
| 65536 | Python, optimised | 514.88 | 260.680 | 0.809 | 258.923–261.910 |
| 65536 | Python, vanilla | 347.03 | 386.766 | 0.563 | 385.629–388.128 |

## Checks and scope

All seven implementations pass 23 shallow-water and 19 energy-balance cases, including independent physical solutions, conservation, long trajectories, boundaries, and storage limits. Every checked stage, step, and saved output has zero differing bytes against the reviewed vanilla Fortran reference. Every optimised language also beats its own vanilla control in all twelve matched runs at every workload.

The generated machine instructions were checked in six native libraries, nineteen compiled Python functions, and twenty-seven Julia methods. The audit found no fused arithmetic or approximate division or square root. Both Julia variants allocate no new numerical storage during warmed execution; compilation and start-up remain outside the timer.

## Measured hardware limits

A roofline estimate combines measured arithmetic speed and memory transfer speed to give an upper bound under stated assumptions. The table compares assembly speed with that estimate; a larger fraction means the solver is closer to the measured bound. These broad bounds leave additional loop, boundary, and processor costs, so they do not prove global optimality.

| Model | Grid | Estimated limit, million updates/s | Assembly / limit |
| --- | --- | ---: | ---: |
| Shallow water | 64² | 186.12 | 48.2% |
| Shallow water | 256² | 186.12 | 51.2% |
| Shallow water | 1024² | 186.12 | 44.4% |
| Energy balance | 128 | 1141.02 | 57.0% |
| Energy balance | 4096 | 1141.02 | 52.6% |
| Energy balance | 65536 | 1141.02 | 51.8% |

The estimate uses 141 arithmetic operations and 552 logical load/store bytes per bulk shallow-water update, including the measured four-division/two-square-root instruction mix. Energy balance uses 23 operations and 104 bytes, with no per-cell division at these grid spacings. Both estimates use matched measurements from the nearest, fastest cache; boundary and partial-vector work is additional. The evidence retains all probe variation, cache measurements, and lower-level memory counters.

The core is pinned to CPU 1 with nearby memory on NUMA node 0, which keeps processor and memory placement fixed. Arm SVE vector instructions process two 64-bit values at a time here. The floating-point control register is zero, which selects the required rounding and underflow rules. Toolchains, build flags, clock policy, observed load, and placement are recorded in the evidence.

The retained assembly methods and their conditions are in [md2asm](../skills/md2asm/SKILL.md). Conclusions apply to these two models, this processor, and the measured workloads.

The formulation explanations were expanded after measurement without changing the mathematics or numerical contracts. The JSON record preserves the measured source hashes and records the revised documentation hashes separately.
