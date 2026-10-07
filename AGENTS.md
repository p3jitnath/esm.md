# Instructions for esm.md

## Source and layout

This project studies direct assembly generation from physics and mathematics in Markdown, beginning with shallow-water equations on an Arm CPU. Before starting work, read the local `.agents/HANDOVER.md` if it exists so that current decisions and unfinished work remain clear.

- Keep the basic physical model in `formulations/`, using the concise [TEMPLATE.md](formulations/TEMPLATE.md). Store the derived numerical and implementation contracts under `skills/md2asm/references/`.
- Group generated assembly and language comparison code by model under `src/`, using model folders such as `src/shallow_water/` and `src/budyko_sellers/`, with `solver.S`, `solver.f90`, `solver.jl`, and `solver.py` for optimised implementations and `vanilla.f90`, `vanilla.jl`, and `vanilla.py` for the unchanged language controls, with verification, timing tools, and compact benchmark records in `bench/`.
- Keep writing conventions in `standards/`, with AGENTS.md and README.md at the repository root so that instructions and the entry point are easy to find.
- Exclude `.agents/research.md` and `.agents/HANDOVER.md` through the `.agents/` rule in `.gitignore`, and keep venue names and submission details outside tracked files. Store local poster drafts under Git-ignored `poster/` and exclude them from every commit.

## Documentation

Write all documentation for a first-year undergraduate, including README files, formulations, skills, solver contracts, comments, docstrings, reports, and conversation. Use short connected explanations, define unfamiliar terms and symbols before using them, state units, and explain what each equation does. Keep the formulation files very simple: the physical idea, basic mathematics, parameter values, initial state, and boundaries. The LLM takes care of numerical methods and implementation through md2asm; keep those details in the skill and its supporting references.

Use [ASD-STE100-CONV](standards/ASD-STE100-CONV.md) for all project prose, including physics and mathematics formulations, comments, docstrings, skills, work reports, and conversation. This overrides earlier strict ASD-STE100 prose requirements for formulations. The writing should read as fluent technical writing, with connected clauses and useful transitions that make the explanation easy to follow.

Keep each prose paragraph or list item on one physical Markdown source line in all project Markdown files, preserving separate lines for display equations, tables, headings, and code blocks.

Use GitHub-compatible Markdown throughout, with dollar-and-backtick delimiters for inline mathematics and fenced `math` blocks for display equations, following [GitHub’s mathematical-expression guidance](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/writing-mathematical-expressions). Use LaTeX `\lvert` and `\rvert` inside table cells when vertical bars would divide the columns, and verify equation rendering without changing the mathematical meaning.

Preserve mathematical meaning, units, identifiers, and reference titles when revising prose, and define unfamiliar technical terms before relying on them. Review vocabulary and grammatical relationships as well as structure, and claim formal ASD-STE100 compliance only after checking the official rules and dictionary.

- Use [NumPy docstring format](https://numpydoc.readthedocs.io/en/stable/format.html) for Python, including the applicable Parameters, Returns, Raises, and Notes sections.
- Use [FORD comments](https://forddocs.readthedocs.io/en/stable/user_guide/writing_documentation.html) for Fortran and [Julia conventions](https://docs.julialang.org/en/v1/manual/documentation/) for Julia, stating types, shapes, units, argument intent, and mutation.
- Explain each assembly interface through its application binary interface (ABI), buffer bounds, alignment, register obligations, and equation correspondence.

## Formulations and generation

### GPU extension

The `gpu` branch carries the two frozen models from GitHub main `6536b88` to NVIDIA GPUs. Keep the original CPU sources and contracts as the numerical reference. Group GPU sources under each model's `gpu/` directory, with direct `solver.ptx` assembly and separate CUDA Fortran `.cuf`, CUDA.jl `.jl`, and Numba CUDA `.py` controls. Use [md2asm-gpu](skills/md2asm-gpu/SKILL.md) and its [GPU contract](skills/md2asm-gpu/references/gpu-contract.md) for this extension; their GPU target and execution rules replace the CPU-specific target rules below for GPU work. Preserve all scientific equations, arithmetic dependencies, required stages, and canonical output bytes.

Emit the GPU solver directly as PTX assembly and assemble it with `ptxas` into an `sm_90` cubin, which contains NVIDIA machine instructions. PTX is NVIDIA's virtual instruction set; report this assembly route accurately. Do not generate the direct solver from CUDA C, Fortran, Julia, Python, compiler intermediate representations, or compiler output. The host launcher may allocate, transfer, launch, synchronise, and time kernels, but every numerical stage and boundary operation belongs to the GPU implementation.

Use quiet compute nodes for all work. GPU timing additionally requires a verified exclusive Slurm node allocation, idle allocated GPUs before warm-up, one fixed GPU, fixed host affinity, and recorded clocks, temperature, power, utilisation, memory, and other processes. Stop disturbed measurements. Retain both unchanged vanilla GPU language controls and separately measured optimised versions; compilation, transfers, graph construction, and validation stay outside the primary GPU timer, with their costs reported separately.

Use the short formulation as the physics input. The LLM must choose and explain a suitable numerical method, then record its grid, complete time update, storage, ordered arithmetic, output bytes, and acceptance limits in the model's md2asm solver contract before generation. Preserve the verified contract for existing models; changing the physical model or numerical method requires independent scientific verification and new comparison records.

Use [md2asm](skills/md2asm/SKILL.md) for direct assembly development and optimisation, applying its measured workflow to the current formulation.

Preserve equation IDs and increase the formulation revision when its mathematics changes, keeping generated artifacts traceable to the scientific source. The direct solver must be emitted as AArch64 assembly and built with an assembler and linker; it must not use high-level solver code, compiler intermediate representations, or compiler-generated assembly.

Keep comparison implementations and evaluation drivers separate from the direct solver, ensuring that no driver supplies an omitted numerical stage. Every implementation must obey its declared Arm ABI and instruction set while handling supported shapes, boundary cells, and vector remainders. Describe the observable generation route without claiming knowledge of an LLM's internal representations.

## Arithmetic and output agreement

Focus the current study on implementation comparisons among direct assembly, Fortran, Julia, and compiled Python, deferring comparisons among LLMs and skill ablations. Keep vanilla and optimised language sources, with normal CPU-aware compilation for the vanilla controls and measured tuning for the optimised implementations; assembly always follows the optimised md2asm workflow. Retain a specialised language implementation only when its accepted measurements improve on the matched vanilla control, with variation reported for every workload. Use the reviewed vanilla Fortran implementation as the canonical discrete reference after independent physical verification, and require byte-for-byte identical simulation outputs from every implementation before comparative timing.

Freeze shared binary inputs and constants, ordered FP64 arithmetic dependencies, intermediate rounding points, and deterministic reduction and tie rules. Use round-to-nearest with ties to even, gradual underflow, and preserved signed zeros, verifying the Arm floating-point control register before execution. Forbid fused multiply-add, expression contraction, reassociation, approximate division or square root, reduced precision, and fast-math in the primary contract.

Define canonical output bytes, including field and cell order, endianness, checkpoints, and deterministic metadata, while keeping timing records separate. Preserve every declared output bit; do not round, mask, or normalise values to conceal a mismatch. Compare raw states after each verification stage and step, then compare checkpoint and final files directly, using zero differing bytes as the acceptance limit and hashes only to identify archived artifacts.

Reject a mismatch before timing and report its first stage, step, field, cell, and bit patterns. Check timed runs' final states outside the timer, and retain independent physical checks because exact agreement can still reproduce a shared scientific defect.

## Optimisation and verification

Run every benchmark through `srun` on a quiet compute node in a verified exclusive Slurm allocation, using the [Slurm allocation rules](https://slurm.schedmd.com/salloc.html). Check node exclusivity and load before timing, stop disturbed measurements, and record the job ID, node, affinity, memory placement, and observed load. Keep compilation and model inference outside timed work, and exclude login nodes and unallocated nodes from benchmarking.

Maximise measured performance within the frozen numerical contract by matching the method, precision, layout, workload, and CPU features across implementations. Profile complete time steps and inspect machine instructions before changing memory access, arithmetic, or allocation patterns.

Optimise generated assembly as far as the declared target and numerical contract permit, using measured results to select vector instructions, register reuse, instruction scheduling, addressing modes, and cache access patterns. Use supported Arm SIMD or SVE features, minimise redundant work and spills, and measure unrolling, fusion, and tiling while preserving boundary correctness.

Apply the md2asm skill's roofline analysis to identify the attainable compute and memory bounds, including division and square-root throughput under the numerical contract, then use measured bottlenecks to reduce the gap. Report the measured fraction of the relevant bound and its assumptions rather than claiming global optimality.

- For Python, use reusable NumPy buffers or compiled numerical loops, with a strong compiled baseline and no interpreted loops in the timed kernel.
- For Fortran, use explicit kinds and interfaces, contiguous arrays, and suitable loop order, enabling strong optimisation for the actual CPU and inspecting vectorisation reports.
- For Julia, use type-stable functions, concrete arrays, and reusable buffers, measuring allocations and reporting just-in-time compilation separately from steady-state timing.
- Apply vectorisation, tiling, fusion, and unrolling when measurements support them and each output preserves the frozen arithmetic dependencies and rounding points, removing bounds checks only after verifying the buffer contract.

Use strong CPU-aware optimisation with contraction and fast-math disabled, including `-ffp-contract=off` for GNU Fortran, `--math-mode=ieee` for Julia, and `fastmath=False` for Numba. Inspect emitted instructions and rerun the small verifier after numerical kernel changes, since flags alone cannot establish byte agreement.

Limit tests to critical numerical or other business logic paths and their edge cases, identifying the requirement or defect that each check addresses. Use one small verifier for independent physics, conservation, complete trajectories, admissibility, exact output agreement, boundaries, and buffer bounds, adding checks only for new scientific requirements or observed defects. Do not write boilerplate, standard-framework checks, trivial unit tests, coverage-driven suites, mocks, repeated tests, or checks that merely repeat the implementation, and remove project-authored tests that do not meet this restriction.

Freeze the formulation, ordered arithmetic, input corpus, output encoding, implementation revisions, target features, toolchains, and measurement protocol before final comparisons. Preserve build commands, generator provenance, failures, hashes, and measured tuning results while timing only implementations that pass both the exact agreement and independent scientific checks.

Report repeated timing variation for each implementation, and limit conclusions to the equations, hardware, and conditions that the experiments cover.

## Size and handover

Keep Julia and any dependencies installed for this project in the Git-ignored `.runtime/` folder inside the repository, recording their versions and using the local installation paths in development commands.

Add files and dependencies only when the current research phase needs them, preferring small functions and direct build commands over general frameworks, orchestration layers, containers, or large CI configurations. Keep binaries, model weights, caches, and large logs outside Git, and preserve unrelated work without using destructive Git operations.

After meaningful work, update the local `.agents/HANDOVER.md`, creating it if necessary and keeping the current state, decisions, and next steps concise. Append a dated entry that records completed work and actual checks, rather than every tool call, so that the handover remains useful without presenting plans as results.
