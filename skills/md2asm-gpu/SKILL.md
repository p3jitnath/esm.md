---
name: md2asm-gpu
description: Generate and optimise GPU assembly directly from physics and mathematics in Markdown, with frozen FP64 arithmetic, independent physical verification, matched GPU language controls, and quiet exclusive-node measurements.
---

# Markdown to GPU assembly

Use this skill when a Markdown formulation must become a complete GPU solver written directly as assembly. Read the short physical note and the existing numerical contract before changing the implementation. A numerical contract fixes the grid, time update, arithmetic order, buffers, and output bytes; keep the physical note simple and place implementation details in a supporting reference. Explain unfamiliar terms for a first-year undergraduate.

For this repository, read the [GPU contract](references/gpu-contract.md) and the frozen [shallow-water](../md2asm/references/shallow_water.md) or [energy-balance](../md2asm/references/budyko_sellers.md) contract. Use [AGENTS.md](../../AGENTS.md) and the [writing convention](../../standards/ASD-STE100-CONV.md). Locate the repository through the skill's resolved directory when installed through a symbolic link; do not hard-code the current workspace in solver code.

## Preserve the science and arithmetic

Keep the verified physical equations and numerical method. Record the formulation and contract hashes, target GPU, assembly instruction set, kernel arguments, launch dimensions, buffer shapes, synchronisation, and complete stage sequence before emitting assembly. Independent physical checks remain necessary because several implementations can share the same scientific error.

The current NVIDIA route is handwritten PTX assembled by `ptxas` to an `sm_90` cubin, which contains native GPU machine code. PTX is a virtual instruction set, so distinguish its source from the final machine instructions. Emit the direct assembly from the equations and ordered contract; do not derive it from compiler-generated assembly, CUDA C, or compiler intermediate representations. Keep compiler-generated comparison kernels separate.

Use explicit `add.rn.f64`, `sub.rn.f64`, `mul.rn.f64`, `div.rn.f64`, and `sqrt.rn.f64` where the contract requires a rounded binary64 operation. The `rn` suffix means round to nearest, with ties to even. Preserve gradual underflow, signed zero, operand order, and threshold tie rules. Explicit rounding prevents contraction of the declared multiply and add. Audit final machine code as well as source: correctly rounded division and square-root implementations can contain internal refinement instructions without changing the required output rounding.

## Implement and verify complete updates

GPU threads may process independent cells together, but a consumer must see every completed producer it needs. Use ordered launches on one stream for whole-grid dependencies, or prove the necessary block-local dependencies before fusing stages. A barrier inside one block cannot synchronise different blocks. Return both complete stages and all required boundary values; the host driver must not compute an omitted flux, update, or boundary.

Check raw state bits after each stage and step against the unchanged physically verified Fortran reference. Compare canonical files directly, including headers. Report the first mismatch by case, step, phase, field, cell, and bit patterns; exclude that implementation from timing. Also check conservation, analytic solutions and convergence, valid states, unchanged inputs, buffer guards, zero steps, odd/even repeated steps, one-cell grids, and partial thread blocks when those paths exist.

Use device buffers with the same FP64 layout and input bytes for every implementation. Complete all warm-up and compilation before capturing a CUDA graph, which records a sequence of GPU launches for replay. Verify both ordinary launches and graph replay; capture must preserve buffer alternation and the last returned stage. Validate final timed states outside the timer without rounding, masking, or normalising output bits.

## Maintain useful language controls

Keep unchanged vanilla GPU Fortran, Julia, and compiled Python sources beside separately tuned sources. Match their numerical method, precision, layout, device, workload, stream sequence, and timer boundaries to assembly. Compile Fortran with contraction and flush-to-zero disabled; use explicit rounded device arithmetic in Julia and Python when their compiler could fuse expressions. Inspect emitted code rather than relying on flags alone.

Apply successful reuse, coalesced memory access, block sizing, and stage fusion to the tuned controls where appropriate. Coalescing means neighbouring threads access neighbouring values, reducing memory transactions. Retain a specialised control only when repeated matched measurements support its gain over vanilla. Report compilation and runtime startup separately from steady-state execution.

## Measure and retain successful methods

Use quiet compute nodes for development. Run all performance work through `srun` in a verified exclusive Slurm node allocation. Check the actual scheduler job and node, host affinity, CPU load, allocated GPU identities, idle utilisation, foreign processes, clocks, power, temperature, and memory before timing. Stop and discard disturbed samples rather than loosening the quiet criteria. Poll a running job or process by its live handle before restarting it after an observation timeout.

Time complete updates with GPU events on the same stream. Keep allocation, input transfers, compilation, graph capture, output transfers, and validation outside the primary timer, and report these costs separately. Reuse the same native device buffers for paired kernels, restore identical inputs, rotate implementation order, and report medians, variation, and ranges at every workload. Disclose separate-runtime placement when Julia uses its own process.

Profile complete steps and inspect register use, spills, memory transactions, and launch costs before tuning. Measure thread-block size, neighbouring-value reuse, fusion, tiling, and temporal reuse only where the frozen dependency and buffer rules permit them. A register is a small per-thread storage location; using too many can reduce the number of active threads. Preserve any required stage output even when intermediate scratch traffic is removed.

Build a roofline estimate from useful operations and bytes per complete update, then calibrate compatible bandwidth and arithmetic on the same GPU. Include correctly rounded division and square root, dependency limits, small-grid launch cost, and cache residency rather than using a tensor-core or fused-arithmetic peak that the contract cannot reach. Keep logical traffic separate from measured hardware traffic. Report the achieved fraction and assumptions; do not claim global optimality.

Freeze source hashes, cubin hashes, input corpus, toolchains, device identity, and measurement protocol before final comparisons. Preserve failed candidates in ignored local records and retain only demonstrated positive methods here. Update the project handover after a verified milestone and keep the goal open until every requested model, control, verification gate, benchmark, and skill artifact has current evidence.
