---
name: md2fort
description: Generate and optimise portable Fortran CPU solvers from physics and mathematics in Markdown, using a compiler to produce machine code while preserving exact numerical specifications, independent scientific verification and controlled measurements.
---

# Markdown to Fortran

Turn a short Markdown physics formulation into portable Fortran. Publish the source and let an optimising compiler generate instructions for each target. Follow [AGENTS.md](../../AGENTS.md), the [formulation template](../../formulations/TEMPLATE.md) and the [writing convention](../../standards/ASD-STE100-CONV.md).

## Numerical Specification

Choose a numerical method and explain how it converts the equations into a complete grid update. Record the grid, units, initial state, boundaries, stability limits, time stages, arithmetic order, storage and output encoding beside the formulation. Keep shared specifications in `formulations/general/`. Freeze inputs, constant values, reduction and tie rules, and required output bytes before comparing routes.

Preserve ordered binary64 operations, intermediate rounding, nearest-even rounding, signed zero and gradual underflow. Disable fast math, contraction, reassociation and approximate division and square root. Record the target’s floating-point environment and inspect compiled instructions where flags alone cannot establish the required order.

## Complete Solver

Use modules, explicit interfaces, named kinds and contiguous arrays. The solver owns every numerical stage and boundary update. Derive dimensions, strides and storage from runtime metadata. Keep target flags and libraries in build records so the same source can be recompiled and verified for another architecture.

Document each entry’s types, units, shape, bounds, intent, ownership and mutation. Use `ISO_C_BINDING` for public C interfaces and state alignment and overlap rules. Preserve partially written arrays and zero-work results with `INTENT(INOUT)` where applicable. Check the allocated extent, including halos, for the supported inputs.

## Establish Correctness Efficiently

Check the physics independently using conservation, admissibility, analytic cases or convergence, with each check tied to its calculation stage. Use a fixed verified Fortran reference for complete state and canonical file comparisons. Require zero differing bytes and report the first case, step, stage, field, cell and bit patterns when a comparison fails.

Check boundaries, duplicate work, partial tiles, array bounds and repeated calls when they affect a change. Use focused agreed checks for unchanged paths before an integrated run. Retain replaced assembly and its evidence after the verified Fortran route passes both checks.

## Find Performance Limits

Profile complete updates, inspect compiler reports and instructions, then measure changes to loop order, vectorisation, unrolling, tiling, allocation and buffer reuse. Preserve the dependency order on every path. Use a roofline estimate to compare attainable arithmetic throughput with memory bandwidth, accounting for required division and square root and their dependencies. Report the smaller justified bound, its assumptions and the measured fraction.

## Compare and Record

Use a quiet, exclusive allocation through `srun`. Match workloads, precision, target features, placement and timer boundaries across implementations. Measure repeated complete updates only after verification, with build and checks outside the timer. Check timed outputs afterwards and report the median, observed range and exact resources, including CPU budget, actual team and workers with assigned cells.

Use strong compiler settings for vanilla and tuned Fortran, with contraction off. Use type-stable Julia and compiled Python loops or reusable NumPy arrays, with strict arithmetic. Record warm-up, compilation, allocation and I/O boundaries. Keep tuned changes supported by measurements and retain source versions, build flags, hashes and detailed timing records.

## Format Project Sources

Run `fprettify` for Fortran, the project’s established Python formatter, and JuliaFormatter before freezing the final source. Preserve frozen reference snapshots and dependencies. Rebuild and check ordered arithmetic, interface and output behaviour when formatting alters the compiled route.

## Full Workflow

See the [complete workflow at the release snapshot](https://github.com/p3jitnath/esm.md/blob/83295ed7b522f8b6ca63c384d8ddcb2892fcb75f/skills/md2fort/SKILL.md) for detailed porting, verification and benchmarking guidance.
