---
name: md2asm-gpu
description: Generate and optimise GPU assembly directly from physics and mathematics in Markdown, preserving ordered FP64 arithmetic, independently verified physics and exact outputs on quiet exclusive nodes.
---

# Markdown to GPU Assembly

Use this skill to generate a complete GPU solver directly from a short Markdown physics formulation. A numerical contract fixes the method, arithmetic order, storage and output bytes. Read that contract before emitting or changing assembly, and write for a first-year undergraduate. Keep the formulation focused on basic physics and mathematics.

For this project, read [AGENTS.md](../../AGENTS.md), the [writing convention](../../standards/ASD-STE100-CONV.md), and the [GPU execution contract](references/gpu-contract.md). Model inputs are the [shallow-water formulation](../../formulations/sw/2d_periodic.md) with its [Rusanov–SSPRK2 contract](../md2asm/references/2d_rusanov_ssprk2.md), or the [energy-balance formulation](../../formulations/ebm/budyko_sellers.md) with its [numerical contract](../md2asm/references/budyko_sellers.md). Resolve the repository from the installed skill’s real directory when it uses a symbolic link.

## Freeze the Numerical Work

Record the formulation and contract revisions, target GPU, assembly instruction set, arguments, dimensions, buffers, launch shapes, synchronisation and complete stage sequence before generation. Emit assembly from the equations and ordered contract, keeping comparison-language source and compiler output separate. The NVIDIA route emits PTX, a virtual assembly language, then uses `ptxas` to create a cubin containing native GPU machine code. State this observable route clearly.

Use explicitly rounded FP64 instructions for each required operation. The PTX suffix `rn` means round to nearest with ties to even. Preserve intermediate rounding, signed zero, gradual underflow, operand order and threshold ties. Retain constant-only and setup arithmetic when its flags are observable, including calls with no active output cell. Inspect final machine instructions as well as source. Internal refinement inside correctly rounded division or square root is distinct from contracting a model multiply and add.

For a complete weather forecast, use the existing theme folders and audit every linked numerical dependency, including setup and input conversion. Keep public file-format, transform and operating-system services explicit. Freeze the complete call graph before counting progress, and distinguish source routines from linker aliases and internal entry addresses. Bind launch wrappers to the actual production entries, including renamed copies, and confirm execution with live counters. The [OpenIFS GPU context](references/openifs/gpu_call_context.md), [assembly CUDA runtime](references/openifs/cuda_runtime.md) and [mathematical support](references/openifs/mathematical_support.md) define this project’s original-interface route.

## Own Complete Updates and Buffers

Keep every numerical stage and required boundary calculation in GPU assembly. The host may load, allocate, transfer, launch, synchronise and store returned bytes. Use an ordered stream for dependencies across the whole grid. A block barrier orders threads within one block, so cross-block consumers require an ordered launch or a proof that all required inputs are already immutable.

Document each entry’s integer dimensions, device addresses, alignment, extents, alias rules, thread bounds, shared storage and barriers. Preserve both required time stages, zero-step behaviour and the physical input/output buffers for odd and even repeated steps. When fusing a stage, retain the original rounded neighbouring expression or load its completed result. Give each boundary copy one clear owner, including corners and one-cell grids.

On a device with coherent host page tables, verify ordinary host-memory access before moving an existing pointer graph. Assembly can retain its owned records and original addresses when every required device capability and complete allocation lifetime is established. Synchronise before the host reads results, and preserve caller numerical flags across nonnumerical CUDA services. Other devices need explicit device owners and pointer relocation.

## Reuse Work Where Dependencies Permit

Neighbouring threads should access neighbouring values when this reduces memory transactions. Compare thread-block sizes, one-field and whole-cell threads, and flat or multidimensional grids on their intended workloads. Cache a repeated rounded value outside a component loop when its operands stay unchanged. Place workload-specific dispatch thresholds in the execution contract and local measurement records.

A small grid can keep a cell’s own state in registers and use shared rows for neighbours. Every thread, including inactive threads, must reach each required block barrier. For larger grids, a tile can load extra neighbouring cells and advance several complete steps while shrinking the valid region after each stage. Prove that the owned cells retain every dependency for the whole batch. Keep the original global input immutable until all tiles finish, then publish physical buffer updates in an ordered copy. Return the last first stage and final state with the original buffer parity.

Copy required initial boundary edges once before a nonempty batch when later update threads can publish their own corresponding ghosts. Reuse the same rounded result for an interior value and its ghosts. This can remove separate boundary launches while keeping a unique source for every copied cell.

A positive power-of-two divisor with a finite normal exact inverse permits one rounded multiplication in place of division. Both round the same real value once. Guard the divisor’s bits before dispatching the whole repeated calculation, retain correctly rounded division for other divisors, and preserve signed zeros and gradual underflow. Verify edge-value operands and the final assembled route before acceptance.

## Verify Changed Numerical Paths

Use the unchanged, independently verified Fortran solver as the canonical discrete reference. Compare complete raw states after each changed stage and step, then compare canonical files directly with zero differing bytes. Freeze every incoming byte that the complete comparison observes, including inactive scratch cells, and define shared comparison inputs before numerical work while preserving active state. Report a first mismatch by case, step, stage, field, cell and both bit patterns. Reuse accepted checks for unchanged paths and add only cases needed for changed launch, tile, boundary, arithmetic or buffer behaviour.

Keep independent conservation, analytic or convergence checks, valid-state limits, unchanged inputs and buffer bounds. Cover partial blocks, dispatch edges, tile boundaries, zero steps and odd/even repeated batches when supported. Verify ordinary launches and CUDA graph replay. A graph records an already compiled launch sequence and must retain the same buffer alternation and final stage. Check timed final states outside the timer without changing output bits.

When matching another processor, carry its floating-point flags and mathematical error writes explicitly. Diagnose rounding from exact operand bits, preserve its NaN selection and underflow rule, and combine independent flags with integer OR. Give error writes unique positions in the original operation order so that a parallel join selects the final write, including a repeated write of the incoming value. For relocatable PTX functions, use one aligned aggregate return and store each call’s parameter values immediately before that call.

## Match Controls and Measurements

Retain unchanged vanilla and separately tuned GPU Fortran, Julia and compiled Python sources locally. Match method, precision, layout, inputs, device, stream sequence and timer boundaries. Use explicit rounded arithmetic where a compiler could contract expressions, inspect emitted instructions, and retain tuned controls when matched repeated measurements improve their vanilla versions.

Perform all development and measurement through `srun` in an owned exclusive node allocation. Before timing, verify the actual node, host affinity, fixed GPU identity, CPU load, foreign GPU processes, utilisation, memory, clocks, temperature and power. Stop disturbed measurements. Poll the existing job or process before restarting after an observation timeout.

Time complete updates with GPU events on one stream after compilation and warm-up. Keep allocation, transfers, graph capture and verification outside that timer and record their costs separately. Restore identical inputs, reuse matched device buffers, rotate implementation order, and report medians and observed ranges at each workload. Disclose separate sequential runtimes, including Julia startup and device placement. Distinguish steady GPU computation from complete request or forecast wall time.

Profile complete steps before tuning. Build a performance guide from useful arithmetic, correctly rounded division and square root, logical data traffic, launch costs and compatible device measurements. Account for register pressure, shared-memory barriers, dependencies and cache residence. Report the achieved fraction and assumptions. Keep measured hardware traffic separate from logical bytes.

Freeze sources, binary hashes, input corpus, toolchain, device and measurement protocol before final comparisons. Keep tools, controls, detailed timings, raw samples and figures under ignored local research folders. Publish concise evidence and positive reusable methods. Update the handover after a verified milestone, with actual checks and remaining limits.
