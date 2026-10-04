# Implementation comparison

The accepted comparisons were collected on 2026-10-04 on one Neoverse V2 core in exclusive Slurm job 7060642, node nid010550, with CPU 1, NUMA node 0, SVE length 16 bytes, and FPCR=0. Both models use ordered FP64 arithmetic with contraction and fast-math disabled, and all seven implementations pass independent physical checks and zero differing bytes at every verification stage and step and in canonical output files.

The [compact evidence](results.json) retains twelve accepted durations, variation, paired speedups, counters, physical cases, input and canonical-output hashes, source and binary fingerprints, placement, clocks, startup, and toolchain versions. Full raw records and generated binaries remain local in Git-ignored folders; the [evaluation instructions](README.md) give the build and launch commands. The later GitHub rendering update preserves every scientific equation and output bit; its before-and-after document hashes appear in the evidence, while the benchmark fingerprints retain the document bytes used for those measurements.

## Shallow water

| Grid | Implementation | Mcell steps/s | Median ms | MAD ms | Range ms |
| --- | --- | ---: | ---: | ---: | --- |
| 64² | Fortran vanilla | 40.18 | 417.535 | 0.178 | 417.142–418.309 |
| 64² | Fortran specialised | 83.29 | 201.434 | 0.040 | 201.336–201.577 |
| 64² | Direct assembly | 81.78 | 205.159 | 0.026 | 205.030–205.504 |
| 64² | Python vanilla | 29.58 | 567.164 | 0.050 | 566.999–567.441 |
| 64² | Python specialised | 55.24 | 303.730 | 0.028 | 303.584–303.881 |
| 64² | Julia vanilla | 30.18 | 555.920 | 0.376 | 554.744–557.848 |
| 64² | Julia specialised | 77.20 | 217.311 | 0.261 | 216.651–220.749 |
| 256² | Fortran vanilla | 40.58 | 413.458 | 1.055 | 411.581–416.555 |
| 256² | Fortran specialised | 80.22 | 209.139 | 0.208 | 208.906–209.874 |
| 256² | Direct assembly | 79.55 | 210.888 | 0.321 | 210.329–211.430 |
| 256² | Python vanilla | 29.93 | 560.492 | 0.276 | 559.757–562.831 |
| 256² | Python specialised | 54.84 | 305.926 | 0.120 | 305.640–306.527 |
| 256² | Julia vanilla | 30.51 | 549.896 | 1.890 | 547.429–554.647 |
| 256² | Julia specialised | 75.97 | 220.846 | 0.487 | 219.314–221.952 |
| 1024² | Fortran vanilla | 39.64 | 423.197 | 0.521 | 421.883–424.909 |
| 1024² | Fortran specialised | 71.86 | 233.486 | 0.310 | 232.896–235.886 |
| 1024² | Direct assembly | 72.11 | 232.666 | 0.206 | 232.120–233.567 |
| 1024² | Python vanilla | 29.82 | 562.655 | 0.204 | 562.318–563.234 |
| 1024² | Python specialised | 52.09 | 322.075 | 0.432 | 321.616–324.015 |
| 1024² | Julia vanilla | 30.02 | 558.829 | 0.142 | 558.269–569.496 |
| 1024² | Julia specialised | 69.44 | 241.612 | 0.327 | 240.885–243.745 |

| Grid | Fortran / vanilla | Julia / vanilla | Python / vanilla | Assembly / fastest language |
| --- | ---: | ---: | ---: | ---: |
| 64² | 2.073× | 2.558× | 1.867× | 0.982× |
| 256² | 1.977× | 2.490× | 1.832× | 0.992× |
| 1024² | 1.813× | 2.313× | 1.747× | 1.004× |

Every specialised language is faster than its matched vanilla implementation in all twelve paired batches on every reported grid; paired ranges in the evidence describe observations rather than confidence intervals. The controls retain their reviewed sources and use strong CPU-aware compilation, with Numba in both Python variants and IEEE Julia execution.

The sixteen physical cases include exact rest and uniform states, transported shear, independent dam-break profiles, small and irregular grids, and a 1000-step trajectory. Shear convergence orders are 0.975 and 0.988 in both directions, the largest dam-break relative error is 0.028651 against the 0.04 limit, maximum normalised budget drift is 7.4e-17, and maximum stage CFL is 0.188 against the 0.4 limit.

## Budyko–Sellers energy balance

| Grid | Implementation | Mcell steps/s | Median ms | MAD ms | Range ms |
| --- | --- | ---: | ---: | ---: | --- |
| 128 | Fortran vanilla | 499.92 | 256.043 | 0.134 | 254.483–257.547 |
| 128 | Fortran specialised | 504.74 | 253.593 | 0.360 | 252.423–254.507 |
| 128 | Direct assembly | 625.92 | 204.498 | 0.048 | 204.300–204.604 |
| 128 | Python vanilla | 318.16 | 402.312 | 0.145 | 402.138–402.976 |
| 128 | Python specialised | 550.14 | 232.668 | 0.125 | 232.540–233.660 |
| 128 | Julia vanilla | 280.01 | 457.126 | 0.323 | 456.228–458.625 |
| 128 | Julia specialised | 524.73 | 243.937 | 0.448 | 243.350–245.503 |
| 4096 | Fortran vanilla | 475.67 | 344.443 | 0.063 | 344.356–344.612 |
| 4096 | Fortran specialised | 508.83 | 321.994 | 0.088 | 321.787–322.275 |
| 4096 | Direct assembly | 601.06 | 272.586 | 0.043 | 272.493–272.775 |
| 4096 | Python vanilla | 399.18 | 410.438 | 0.061 | 410.322–410.817 |
| 4096 | Python specialised | 517.91 | 316.348 | 0.070 | 316.245–316.664 |
| 4096 | Julia vanilla | 280.45 | 584.213 | 3.591 | 578.525–601.577 |
| 4096 | Julia specialised | 501.67 | 326.589 | 1.629 | 324.729–330.622 |
| 65536 | Fortran vanilla | 382.32 | 351.065 | 1.508 | 343.842–352.703 |
| 65536 | Fortran specialised | 450.51 | 297.923 | 1.469 | 294.909–301.905 |
| 65536 | Direct assembly | 565.35 | 237.405 | 0.689 | 236.551–240.106 |
| 65536 | Python vanilla | 355.55 | 377.491 | 0.568 | 376.319–381.684 |
| 65536 | Python specialised | 505.17 | 265.689 | 0.300 | 264.856–266.441 |
| 65536 | Julia vanilla | 263.32 | 509.720 | 1.979 | 501.924–531.969 |
| 65536 | Julia specialised | 486.70 | 275.772 | 4.442 | 266.477–290.001 |

| Grid | Fortran / vanilla | Julia / vanilla | Python / vanilla | Assembly / fastest language |
| --- | ---: | ---: | ---: | ---: |
| 128 | 1.010× | 1.874× | 1.729× | 1.138× |
| 4096 | 1.070× | 1.789× | 1.297× | 1.161× |
| 65536 | 1.178× | 1.848× | 1.421× | 1.119× |

Every specialised language is faster than its matched vanilla implementation in all twelve paired batches on every reported grid; paired ranges in the evidence describe observations rather than confidence intervals. The controls retain their reviewed sources and use strong CPU-aware compilation, with Numba in both Python variants and IEEE Julia execution.

The sixteen physical cases include exact equilibrium, radiative relaxation, the cell-averaged Legendre mode, threshold ties, signed zeros, 8193 cells across the tiling boundary, and 1000 climate steps. Relaxation orders are 2.069 and 2.034, mode orders are 2.002 and 2.001, maximum normalised heat-balance residual is 1.1e-16 against the 1e-10 limit, and maximum symmetry error is 3.55e-14 K; this independently specified discretisation is not a byte reference for climlab.

## Compatible roofline bounds

A roofline bound combines compatible arithmetic throughput with memory bandwidth at the level that supplies a kernel’s traffic. These probes use strict FP64 instructions on the same node and core as the solvers, so fused-multiply-add peaks and unmeasured DRAM traffic do not enter the comparison.

| Arithmetic probe | Median rate | MAD / median |
| --- | ---: | ---: |
| add | 25.927 Goperations/s | 0.006% |
| multiply | 25.927 Goperations/s | 0.007% |
| divide | 1.296 Goperations/s | 0.005% |
| sqrt | 0.926 Goperations/s | 0.005% |
| sqrt_neon | 0.926 Goperations/s | 0.005% |
| mixed | 190.642 Mcell-step equivalents/s | 0.004% |
| mixed_neon | 190.646 Mcell-step equivalents/s | 0.003% |

| Working level | Copy, GB/s | 7 reads / 1 write, GB/s | 5 reads / 2 writes, GB/s | 11 reads / 2 writes, GB/s |
| --- | ---: | ---: | ---: | ---: |
| L1 | 80.65 | 134.82 | 142.14 | 137.03 |
| L2 | 81.26 | 57.14 | 129.20 | 76.31 |
| L3 | 37.97 | 51.15 | 64.33 | 48.66 |
| DRAM | 32.84 | 28.41 | 29.04 | 26.49 |

The assembly counts below describe executed arithmetic and logical load/store bytes, including boundary and inactive-lane work where applicable; complete physical updates per second remain the comparison metric because reuse changes operation counts. Logical traffic is paired with the closest L1 read/write probe, while lower-level refill counters remain separate and do not establish total DRAM traffic.

| Model and grid | FP operations / cell step | Logical bytes / cell step | Empirical ceiling, Mcell steps/s | Assembly / ceiling |
| --- | ---: | ---: | ---: | ---: |
| shallow_water, 64² | 144.838 | 785.863 | 179.00 | 45.7% |
| shallow_water, 256² | 143.455 | 766.398 | 180.73 | 44.0% |
| shallow_water, 1024² | 143.113 | 761.595 | 181.16 | 39.8% |
| budyko_sellers, 128 | 23.000 | 104.750 | 1127.24 | 55.5% |
| budyko_sellers, 4096 | 23.000 | 104.023 | 1127.24 | 53.3% |
| budyko_sellers, 65536 | 23.010 | 104.094 | 1126.74 | 50.2% |

Shallow-water counts are F=143C+84nx+32ny+106 and T=760C+688nx+944ny+1488 bytes per complete step, with C=nx·ny and a small amortised public-frame cost outside the cell counts. Its compatible ceiling also includes the measured four-division/two-square-root mixture for representative seed values; the read/write ratio is approximately 67:28 rather than an exact match to the 5:2 probe.

Energy-balance bulk work is 23 FP operations and 104 logical bytes per cell step, with three ghost-copy pairs, exact scalar face prefixes between temporal blocks, and inactive first-stage lanes at block boundaries. The power-of-two benchmark spacings remove per-cell division exactly and require no square root, so the shallow-water mixed-instruction ceiling does not apply; the 11:2 stream matches its bulk read/write ratio.

These are broad empirical ceilings, with dependency chains, address generation, predicate work, instruction issue, and cache interactions still able to limit the solver. Refill counters and the complete accepted PMU summaries in the evidence support further analysis, but the results do not prove global optimality or assembly superiority for other models or targets.

## Retained implementation strategies

| Model | Retained choices |
| --- | --- |
| Shallow water | Shared rounded speeds and face values, fused north-point preparation, short live-row windows on larger grids, exact scaling, constant stage paths, and measured vector scheduling |
| Energy balance | Hoisted immutable coefficients, exact scaling, unique assembly faces with a vector carry, eight independent vector groups, and 512-cell temporal blocks for assembly, Julia, and Python on larger grids |
| Language controls | Julia literal Val dispatch and safe eager selection, Python strategy selection outside repeated steps, and measured Fortran face caching or fused loops according to working size |

The reusable conditions and proofs are maintained in [md2asm](../skills/md2asm/SKILL.md), while local archives retain failed candidates and accepted predecessor records. Compilers, strategy thresholds, and unrolling were selected from complete-step measurements, and the final evidence records source hashes rather than treating a technique’s name as evidence of its benefit.

The toolchains are GNU Fortran and GCC 14.3.0, GNU Binutils 2.43.1, Julia 1.12.7, CPython 3.11.7, NumPy 2.4.6, Numba 0.68.0, and llvmlite 0.50.0. Both Julia variants allocate zero warmed numerical bytes; cold startup, request compilation, cache activity, numerical storage, and aggregate process memory are retained with their scopes in the evidence.

Instruction inspection covers all six native solver libraries, nineteen fresh Numba compilations, and twenty-seven Julia method instantiations under the declared target and IEEE settings, with no fused or approximate arithmetic instructions; the inspected Numba IR also contains no detected unsafe floating-point flags. These checks complement the exact trajectories, with local disassembly and compact audit provenance retained separately.
