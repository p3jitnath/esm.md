---
name: md2asm
description: Generate and optimise native assembly directly from basic physics and mathematics in Markdown, using exact numerical contracts, independent scientific verification, and controlled measurements.
---

# Markdown to assembly

Apply this workflow when a short Markdown note supplies the physical equations and the LLM must derive the numerical method and emit the complete solver directly as native assembly. Write for a first-year undergraduate, defining unfamiliar terms and explaining each choice. Follow the repository’s [instructions](../../AGENTS.md), [short formulation template](../../formulations/TEMPLATE.md), and [writing convention](../../standards/ASD-STE100-CONV.md).

## Derive and freeze the solver contract

Read the basic formulation, then choose and explain the grid, spatial approximation, time update, and verification cases. A numerical method turns continuous equations into calculations on cells and time steps; its contract records the exact choices so that every implementation solves the same problem. Keep this detail in a model reference under references/, leaving the formulation short.

For the existing models, read the frozen [shallow-water contract](references/shallow_water.md) or [energy-balance contract](references/budyko_sellers.md) and preserve its equations and arithmetic. Read the corresponding [OpenIFS contract](../../bench/openifs/README.md) before changing one of its verified routines. Define every additional symbol, unit, stage, storage rule, dependency, and acceptance limit before generation. Record the source and contract revisions and hashes, processor instructions, and application binary interface (ABI), which defines function arguments, registers, and stack use.

For exact agreement, freeze input bits, intermediate rounding points, reductions, tie rules, signed zeros, and subnormal handling. Verify the floating-point control register and vector length before execution. This project uses FP64, the 64-bit floating-point format, with round-to-nearest with ties to even and gradual underflow, with correctly rounded division and square root; contraction, reassociation, approximate arithmetic, and fast-math are forbidden.

Emit the complete solver as assembly source and build it with an assembler and linker. Keep language controls separate and use neither compiler-generated assembly nor compiler intermediate representations to construct the direct solver. Include all boundaries and stages inside the solver, preserve the ABI’s register and stack obligations, and document equation correspondence and observable generation provenance.

## Establish correctness

Use one small verifier for independent physical solutions, conserved quantities, physically valid states, complete trajectories, standard output files, buffer guards, and allowed mutation. A buffer guard is a value placed beside an array to detect writes beyond its bounds. Compare raw states after every stage and step against the reviewed vanilla reference, requiring zero differing bytes and reporting the first phase, step, field, cell, and bit patterns if agreement fails. Check the returned state after each timed run outside the timer.

Add cases only for a scientific requirement or a changed critical path, such as a dispatch threshold, boundary, partial vector, threshold tie, or scratch lifetime. State the requirement each case protects, and repeat the verifier and instruction audit after a numerical change.

## Locate the performance bound

Profile complete steps and inspect their machine instructions before tuning. Registers are small storage locations inside the processor; vector instructions apply one operation to several values at once. Build a [roofline model](https://www2.eecs.berkeley.edu/Pubs/TechRpts/2008/EECS-2008-134.pdf) from useful operations, live working sets, and traffic at each relevant memory level. Keep estimated logical bytes distinct from measured cache refills and DRAM traffic.

Measure bandwidth with the kernel’s read/write ratio, vector width, alignment, and working size. Calibrate compatible arithmetic with representative operands, including division, square root, comparisons, lane shifts, and shared issue resources. A joint instruction mix captures resource sharing better than separate peaks; compare independent schedules and report calibration variation alongside any broader hardware bound.

Use the smaller compute or bandwidth limit, adding justified dependency and instruction limits. Compare complete physical updates per second because reuse can reduce the operation count itself. Report the achieved fraction, assumptions, uncertainty, and remaining bottleneck for the measured target and workload.

## Apply successful methods

Retain a method when its complete-step gain exceeds measured variation and the frozen outputs remain identical. Keep each method’s domain argument with the source; exact sampled agreement complements this argument.

| Method | Preconditions and implementation |
| --- | --- |
| Vector execution | Compare supported SIMD and SVE forms per operation at a verified width, selecting measured load, arithmetic, division, and square-root forms. Keep predicated or scalar tails within buffer bounds, and interleave independent vector groups to cover latency. For ordered sums, vectorise independent outputs while each lane retains its original multiplication and addition order. Share a coefficient across these outputs when its rounded bits are identical. Measure shape-gated load/product/store schedules for short contiguous fields, comparing paired and separate vector memory instructions. |
| Rounded-value reuse | Share identical coefficients, speeds, faces, and stencil values across components when their ordered operands and rounding points match. For repeated integer indices, compute each coefficient once and store its rounded bits in a small array owned by the call. Choose an unused marker outside the proven coefficient range. Retain each required stage output. |
| Early point preparation | Start the next group’s division and square root during independent current-cell work, after the registers’ last consumers. Use carried results directly in their registers, guarding the final look-ahead and partial-vector carry. |
| Face and update fusion | Compute a rounded face beside its immediate divergence consumer, carrying the shared face in a register or live row. Peel the first cell when aligned loads improve measured timing; a partial vector must carry its last active lane. |
| Live scratch and temporal blocking | Retain only the rows or neighbours still needed by the stencil while preserving the public pitch and scratch allowance. Consume an old rounded face before overwriting its slot; a separate consumer pass needs its own previous-face row. Use complete halo dependencies for stage tiling, prepare boundaries before consumers, and preserve untouched values across partial writes. |
| Address and invariant reuse | Hoist pitches, field pointers, immutable rounded coefficients, and stage selection outside repeated work. Pair adjacent memory operations when both values meet the bounds, alignment, and lifetime contract. Preserve coefficient rounding and the zero-step interface. |
| Exact scaling | Use power-of-two multiplication in place of division only where the declared domain proves equal rounded bits, including underflow and signed-zero behaviour; retain the general path for other inputs. |
| Control specialisation | Select a small set of fixed stage or arithmetic variants before the loop. Use literal Julia Val variants through explicit branches and inspect inference; choose eager selection only when both operands are valid and side-effect free. |

Select unrolling, tiling, prefetch distance, and dispatch ranges from measured cache behaviour and register pressure. Keep thresholds specific to the model and target, and prefer compact code where setup costs dominate small workloads.

The shallow-water implementation combines direct carried registers, a compact scratch window, and load-before-store face reuse. [Matched measurements](../../bench/results.md) establish the retained gains; model-specific rates, thresholds, and evidence stay in that record. The [OpenIFS vertical matrix](references/openifs/dynamics/strict_matrix.md) applies independent lanes and shared coefficients, with measured gains for complete vertical integration. The [OpenIFS spectral filter](references/openifs/dynamics/spfilt.md) uses a private table of rounded factors and a shape-checked schedule of paired vector loads and stores, selected by complete-call measurements.

## Maintain strong language controls

Keep reviewed vanilla sources fixed and tune separate optimised implementations under the same numerical contract. Use CPU-aware optimisation for both, with contraction and fast-math disabled. Apply successful algorithmic reuse to the optimised controls as well as assembly, retaining a specialised implementation when it improves on its matched vanilla control across the declared workloads.

Use explicit Fortran kinds and interfaces, contiguous arrays, suitable loop order, and inspected vectorisation. Use concrete Julia arrays, type-stable specialisation, and reusable buffers, measuring warmed allocations. Use reusable NumPy storage or compiled Python loops with fastmath=False. Inspect emitted instructions, and report JIT compilation and process startup separately from steady-state execution.

## Measure and preserve evidence

Run benchmarks through srun on a quiet node in a verified exclusive Slurm allocation. Check occupancy, load, affinity, memory placement, clocks, FPCR, and vector length, stopping disturbed measurements. Freeze input bytes, implementation revisions, toolchains, target features, cache preparation, warm-up, step counts, and timer boundaries.

Reuse the same physical arrays for paired native kernels, restoring inputs before warm-up and timing; record their addresses and alignment. Disclose separate-runtime placement limits and measure their variation. Keep compilation, initialisation, output, and validation outside the timer, rotate implementation order, and report repeated medians, dispersion, and ranges at every workload.

Keep the [implementation record](../../bench/results.md) compact and tied to source hashes, commands, canonical outputs, and measurement conditions. Store detailed tuning records locally, preserve only positive reusable lessons in this skill, and update the concise project handover after completed milestones. Add only the source and tools required by the current phase.
