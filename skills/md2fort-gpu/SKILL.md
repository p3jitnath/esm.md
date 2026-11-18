---
name: md2fort-gpu
description: Generate and optimise GPU solvers from physics and mathematics in Markdown through compiled Fortran or an explicitly selected assembly route, preserving ordered FP64 arithmetic, independently verified physics and exact outputs on quiet exclusive nodes.
---

# Markdown to GPU

Use the Markdown formulation and its numerical specification to generate a complete GPU solver. Publish compiled CUDA Fortran for this study. Treat explicitly selected direct PTX as a separate route, with `ptxas` producing the native machine code. Follow [AGENTS.md](../../AGENTS.md) and the [GPU execution specification](../../formulations/general/gpu_execution_specification.md) for the study target and build flags.

## Numerical Specification

Freeze the equations, target, arithmetic dependencies, grid layouts, time stages and canonical outputs. Preserve binary64 intermediate rounding, nearest-even rounding, signed zero, gradual underflow and branch ties. Disable contraction, fast math and approximate arithmetic. Inspect the emitted instructions against the required order.

## Complete GPU Updates

Record each API entry’s types, dimensions, units, buffer extents, alignment and ownership. Derive storage and launch bounds from live metadata, using checked size calculations. Keep all numerical stages, boundary updates and synchronisation in the solver, with the driver controlling input and timing.

Check halos, partial blocks, shared-buffer lifetimes and barriers before tuning. Measure tile shapes, register and shared-memory use, memory traffic and occupancy, which is the fraction of thread capacity in use. Test each change through complete updates so savings include repeated halo work and launch overhead.

## Verify Numerical Outputs

Use the [CPU workflow’s exact comparison](../md2fort/SKILL.md#establish-correctness-efficiently) with the fixed Fortran reference. Compare complete intermediate and final states, and preserve exact output bytes. Combine this with independent physics and buffer checks. Exercise partial tiles, dispatch boundaries, and repeated launches for any changed path.

## Match GPU Measurements

Use the declared GPU on a quiet, exclusive Slurm allocation. Check device identity, load, clocks and host affinity before timing. Match inputs, precision, device, update counts and entry points for CUDA Fortran, PTX, Julia and compiled Python controls. Time complete updates with warm GPU events on the same stream and state the treatment of allocation, transfers and graph capture. Report repeated medians, observed ranges, source identities and device settings.

## Format Project Sources

Run `fprettify`, the project’s Python formatter and JuliaFormatter before freezing sources. Preserve recorded references, then rebuild and check any changed arithmetic, buffer or launch behaviour.

## Full Workflow

See the [complete workflow at the release snapshot](https://github.com/p3jitnath/esm.md/blob/83295ed7b522f8b6ca63c384d8ddcb2892fcb75f/skills/md2fort-gpu/SKILL.md) for detailed device, PTX and verification guidance.
