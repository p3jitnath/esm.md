---
name: md2asm
description: Generate and optimise native assembly directly from complete physics and mathematics in Markdown, with explicit numerical contracts, independent scientific verification, and controlled performance comparisons.
---

# Markdown to assembly

Use this workflow when a Markdown formulation is the maintained scientific source and the requested solver must be emitted directly as native assembly. Establish the model, numerical method, processor, instruction set, and comparison implementations from the current task, following the repository's [instructions](../../AGENTS.md), [formulation template](../../formulations/TEMPLATE.md), and [writing convention](../../standards/ASD-STE100-CONV.md).

## Establish the contract

Read the complete formulation and target interface, then confirm that they specify all physics, spatial operators, time stages, boundaries, storage, arithmetic dependencies, and acceptance limits. Resolve missing scientific choices before generating a kernel, and retain the formulation revision and hash so that later changes invalidate earlier evidence. Apply any required document structure, including this repository's 12-section template, without treating one model's equations as a universal numerical method.

Identify the precision, rounding points, floating-point environment, special-value rules, reductions, input mutation, and output encoding before selecting instructions. Where byte agreement is required, preserve shared input bits and every specified output bit, including signed zeros and subnormal values; verify the relevant processor control registers rather than assuming their defaults. The current [shallow-water](../../formulations/shallow_water.md) and [energy-balance](../../formulations/budyko_sellers.md) formulations and [Arm interface](../../bench/README.md) provide one project-specific application of this workflow.

Emit assembly source directly from the contract, using assembly macros, an assembler, and a linker to build the solver. Keep high-level comparison implementations separate, and do not use their compiler-generated assembly or intermediate representations to construct the direct solver. Record the source, build commands, target features, and equation correspondence without claiming knowledge of an LLM's internal representations.

## Build and establish correctness

Implement the complete numerical operation behind the declared application binary interface (ABI), including boundary updates and every time stage, so that the driver supplies only inputs, storage, invocation, and evaluation. Respect stack alignment, callee-saved registers, array alignment, and alias rules; handle all supported shapes rather than only the benchmark dimensions.

Use one compact verifier to check independent physical solutions or identities, the declared budgets and admissibility bounds, buffer guards, input mutation, and complete numerical trajectories. For exact comparisons, require zero differing bytes in state arrays and canonical output files, reporting the first differing phase, step, component, cell, and bit patterns. Correct the arithmetic or memory access that caused a failure before timing, preserving the frozen acceptance limits.

## Optimise the measured bottleneck

Establish a [roofline model](https://www2.eecs.berkeley.edu/Pubs/TechRpts/2008/EECS-2008-134.pdf) for the declared processor and numerical contract before selecting optimisations. Count useful operations and traffic at each relevant memory level, including boundaries and scratch storage, then measure attainable bandwidth and compatible arithmetic throughput under the same controlled conditions as the solver. Distinguish measured traffic from estimates, and include instruction ceilings for division, square root, dependencies, and issue rate when a simple floating-point peak is too loose.

Count traffic separately at each memory level, using actual live working sets rather than the allocated scratch capacity; logical load/store bytes and PMU cache refills describe different quantities, and neither alone establishes DRAM traffic. Match bandwidth probes to the kernel’s read/write ratio, vector width, working size, and arithmetic constraints, including representative operand values when iterative instruction latency may depend on them.

Use operational intensity I in operations per byte and bandwidth B to compare measured performance with the bound min(P_compute, I B), adding tighter instruction or dependency bounds where needed. Drive tuning towards the relevant bound through the choices below, then report the achieved fraction, uncertainty, and remaining bottleneck; proximity to an estimated roof does not establish global machine optimality.

Optimisation must preserve the numerical contract. Use the following choices where measurements justify them, keeping unsuccessful variants in local records rather than expanding the maintained codebase.

| Area | Decisions that can improve the kernel |
| --- | --- |
| Vector execution | Use the target's supported scalar or vector instructions, inspect the actual lane count, and keep predicated or scalar tails within buffer bounds |
| Shared quantities | Reuse rounded intermediates and unique face or stencil values when their ordered operands are identical, retaining a proof of bit equivalence over the declared domain |
| Operator and stage work | Reuse common coefficients across components, avoid duplicated neighbour loads, and fuse compatible loops while retaining each output's rounding points |
| Registers and scheduling | Keep frequently used values in registers, shorten live ranges, minimise spills, and interleave independent vector groups to cover latency, preserving an exact carry where neighbouring cells share a rounded value |
| Addressing | Hoist pitches and field offsets, use suitable contiguous loads and stores, and avoid recomputing addresses inside the cell loop |
| Cache and memory | Measure live-row windows, row traversal, tiling, buffer reuse, and prefetch distance against complete steps, preserving the declared pitch and scratch allowance |
| Control flow | Hoist invariant conditions and immutable rounded coefficients across repeated steps, select constant stage and arithmetic variants explicitly, and measure modest unrolling without excessive code growth |
| Exact transformations | Consider an alternative instruction sequence only when it gives the same rounded value over the declared input domain; sampled agreement alone is insufficient proof |

Separate the source-level work saved by common quantities from machine throughput: a faster implementation can execute fewer floating-point operations, so complete physical updates per second remain the main comparison metric. Include a fixed vector length in compiler settings only when the execution contract verifies that length, and measure inlining or specialisation settings when call boundaries prevent the intended loop schedule. Hoist strategy selection outside repeated work where possible, retaining a small set of paths only when their measurements resolve a gain.

Treat scheduling identities and unchecked arithmetic primitives as domain-dependent transformations that require both a mathematical justification and exact output checks; include their executed instructions when estimating bounds.

For a local multi-stage stencil, measure temporal blocking after proving its producer and consumer dependencies: prepare the necessary next-stage neighbours before consuming a cell, apply each boundary value before its first use, and retain complete output buffers when the interface requires them. A one-cell look-ahead can avoid repeated stage work, but its final empty range and vector remainders need explicit checks; choose block sizes from measured cache behaviour rather than copying a previous model's threshold. Preserve previously prepared values across partial writes, including the language's definition and mutation rules; a Fortran helper that updates a subrange should use intent(inout) when the remaining values are still needed.

Use fused operations, reassociation, reciprocal approximations, or reduced precision only when the numerical contract explicitly permits their resulting arithmetic. This repository's primary comparison forbids these changes and requires correctly rounded division and square root. Inspect the assembled instructions to confirm that the source and selected instruction set match the intended route, then rerun the verifier after kernel changes.

Optimise each selected comparison implementation against the same performance bounds as the assembly, using current compilers, appropriate processor features, concrete data types, reusable storage, and the same numerical contract. Inspect vectorisation, allocations, alias checks, and invariant branches, hoisting immutable array elements into scalars when possible and replacing a branch with eager selection only when both operands are valid and side-effect free; use valid compile-time specialisation or compiler loop tuning when these obstruct the target instructions, then retain changes only when measurements support them and the specialised control improves on its matched vanilla measurements. Fortran, Julia, and compiled Python are useful controls when the task calls for them, with just-in-time compilation separated from steady-state timing and each remaining bottleneck reported explicitly.

Hoist a coefficient only when its inputs and floating-point environment remain unchanged throughout the invocation, preserving its original rounding point and the zero-step interface. Where a stencil shares a face between adjacent cells, compare a register carry or vector-lane shift with recomputation and scratch storage; the fastest choice depends on memory traffic, dependency latency, and available registers.

Use compile-time specialisation for a small set of invariant choices, while verifying that the language actually resolves those choices before entering the repeated loop. In Julia, select literal Val variants through explicit branches rather than assuming that Val applied to a run-time Boolean will infer a concrete type; inspect inference and emitted instructions, and keep code growth proportionate to measured benefit.

Measure boundary specialisation, loop independence declarations, and modest unrolling instead of assuming that each helps; a gain on one working size can accompany a regression on another. Reject unresolved or regressing changes, and apply successful algorithmic reuse to the comparison languages as well as assembly.

When the study retains vanilla controls, keep those reviewed sources fixed while tuning their separate optimised variants. Use normal CPU-aware compilation for the vanilla controls, rather than deliberately weak flags or interpreted numerical loops, so that measured differences describe the benefit of source and compiler tuning under the common contract.

## Measure and retain evidence

Use the task's required controlled execution environment, verifying processor occupancy, affinity, memory placement, vector length, clocks, and load. In this repository, every benchmark must run through srun on a quiet node in a verified exclusive Slurm allocation. Match input bytes, method, scratch allowance, target features, warm-up, cache preparation, step counts, and timer boundaries, then compare complete numerical operations against every accepted implementation.

Record cold process startup, first invocation, cache hits, and measured JIT compilation separately, defining whether each number covers the numerical kernel or its driver. Report numerical buffer storage independently from process peak memory, since interpreter and harness storage must not be attributed to a kernel.

Keep compilation, initialisation, file output, and validation outside the timed region, but verify each timed final state afterward. Alternate implementation order and report repeated measurements and uncertainty, retaining a change only when its gain is resolved and its outputs remain valid. Report limits of the tested optimisation space rather than claiming global machine optimality.

Maintain the skill's reusable optimisation guidance as work proceeds, including the preconditions, bit-equivalence argument, applicable bottleneck, and measured outcome for each retained technique. Keep model-specific failed variants in local tuning records, adding a rejected approach to the skill only when it exposes a useful general constraint, and avoid presenting one machine's thresholds as universal constants.

The [implementation record](../../bench/results.md) connects these retained techniques to the measured model and target conditions, while the skill keeps their reusable constraints and decision rules.

Update the project's handover after a completed scientific, implementation, or measurement milestone, keeping its current state and next action concise. Add only the source and tools needed by the current phase, extending an existing verifier and benchmark driver when possible rather than introducing another framework.
