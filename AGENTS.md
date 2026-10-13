# Instructions for esm.md

## Source and layout

This project studies direct assembly generation from physics and mathematics in Markdown, beginning with shallow-water equations on an Arm CPU. Before starting work, read the local `.agents/HANDOVER.md` if it exists so that current decisions and unfinished work remain clear.

- Publish only Markdown documents and assembly source. Keep shallow-water physics under `formulations/sw/` and its solver under `src/sw/`. Keep energy-balance physics under `formulations/ebm/` and its solver under `src/ebm/`. Keep OpenIFS formulations in `formulations/openifs/` and assembly in `src/openifs/`, grouped by physical theme.
- Use the concise [TEMPLATE.md](formulations/TEMPLATE.md) for physical inputs. Store derived numerical and implementation contracts under `skills/md2asm/references/`. Keep the public comparison tables in README.md and detailed benchmark results locally under the ignored `.agents/bench/` folder.
- Retain language controls, verification and timing tools, detailed records, downloaded data and dependencies locally under `.runtime/`. Preserve their source versions and hashes before removing them from the published tree. The public documentation must explain actual checks and limits.
- Keep writing conventions in `standards/`, with AGENTS.md and README.md at the repository root so that instructions and the entry point are easy to find.
- Keep `.agents/`, `.runtime/`, `poster/`, binaries, caches and large logs outside commits through local rules in `.git/info/exclude`. Keep venue names and submission details outside tracked files. Retain local tools and poster drafts when cleaning published files.

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

Use the short formulation as the physics input. The LLM must choose and explain a suitable numerical method, then record its grid, complete time update, storage, ordered arithmetic, output bytes, and acceptance limits in the model's md2asm solver contract before generation. Preserve the verified contract for existing models; changing the physical model or numerical method requires independent scientific verification and new comparison records.

Use [md2asm](skills/md2asm/SKILL.md) for direct assembly development and optimisation, applying its measured workflow to the current formulation.

Preserve equation IDs and increase the formulation revision when its mathematics changes, keeping generated artifacts traceable to the scientific source. The direct solver must be emitted as AArch64 assembly and built with an assembler and linker; it must not use high-level solver code, compiler intermediate representations, or compiler-generated assembly.

Keep comparison implementations and evaluation drivers separate from the direct solver, ensuring that no driver supplies an omitted numerical stage. Every implementation must obey its declared Arm ABI and instruction set while handling supported shapes, boundary cells, and vector remainders. Describe the observable generation route without claiming knowledge of an LLM's internal representations.

## Work sequence

Finish all remaining audited weather routines and their required checks first. Then complete these phases in order, one at a time, finishing each phase before starting the next.

1. Build a complete autonomous forecast from direct assembly. Its executable must own initialisation, the time loop, every forecast calculation, state updates and output, with no OpenIFS Fortran calls or numerical fallback. Keep the original Fortran forecast separate as a verification reference. Require independent physical checks and exact saved-output agreement before starting performance optimisation.
2. Dedicate one full day, meaning 24 hours, to aggressive optimisation of the verified autonomous forecast on a quiet exclusive node. Preserve the frozen arithmetic and every output bit. Improve md2asm with concise, general, positive lessons and guidance, keeping measurements and detailed tuning records locally.
3. Make filenames and document titles clear and readable. Prefer descriptive names with more than one word, joined by underscores, and use abbreviations only when they are commonly accepted. Preserve conventional entry-point names such as AGENTS.md, README.md and SKILL.md. Keep original routine names in assembly interfaces and traceability records, and update affected links, source headers, contracts and local build paths together.

## Arithmetic and output agreement

Focus the current study on implementation comparisons among direct assembly, Fortran, Julia, and compiled Python, deferring comparisons among LLMs and skill ablations. Keep vanilla and optimised language sources locally under `.runtime/`, with normal CPU-aware compilation for the vanilla controls and measured tuning for the optimised implementations; assembly always follows the optimised md2asm workflow. Retain a specialised language implementation only when its accepted measurements improve on the matched vanilla control, with variation reported for every workload. Use the reviewed vanilla Fortran implementation as the canonical discrete reference after independent physical verification, and require byte-for-byte identical simulation outputs from every implementation before comparative timing.

Freeze shared binary inputs and constants, ordered FP64 arithmetic dependencies, intermediate rounding points, and deterministic reduction and tie rules. Use round-to-nearest with ties to even, gradual underflow, and preserved signed zeros, verifying the Arm floating-point control register before execution. Forbid fused multiply-add, expression contraction, reassociation, approximate division or square root, reduced precision, and fast-math in the primary contract.

Define canonical output bytes, including field and cell order, endianness, checkpoints, and deterministic metadata, while keeping timing records separate. Preserve every declared output bit; do not round, mask, or normalise values to conceal a mismatch. Compare raw states after each verification stage and step, then compare checkpoint and final files directly, using zero differing bytes as the acceptance limit and hashes only to identify archived artifacts.

Reject a mismatch before timing and report its first stage, step, field, cell, and bit patterns. Check timed runs' final states outside the timer, and retain independent physical checks because exact agreement can still reproduce a shared scientific defect.

## Optimisation and verification

Run all development, file work, simulations and benchmarks through `srun` in an owned, verified exclusive allocation on a quiet compute node. Use the [Slurm allocation rules](https://slurm.schedmd.com/salloc.html). Check node exclusivity and load before timing, stop disturbed measurements, and record the job ID, node, affinity, memory placement, and observed load. Keep compilation and model inference outside timed work, and exclude login nodes and unallocated nodes from benchmarking.

During an active allocation, check the allocation and forecast status at intervals of at most five minutes. Use a four-minute target to allow time for each check.

Maximise measured performance within the frozen numerical contract by matching the method, precision, layout, workload, and CPU features across implementations. Profile complete time steps and inspect machine instructions before changing memory access, arithmetic, or allocation patterns.

Optimise generated assembly as far as the declared target and numerical contract permit, using measured results to select vector instructions, register reuse, instruction scheduling, addressing modes, and cache access patterns. Use supported Arm SIMD or SVE features, minimise redundant work and spills, and measure unrolling, fusion, and tiling while preserving boundary correctness.

Apply the md2asm skill's roofline analysis to identify the attainable compute and memory bounds, including division and square-root throughput under the numerical contract, then use measured bottlenecks to reduce the gap. Report the measured fraction of the relevant bound and its assumptions rather than claiming global optimality.

- For Python, use reusable NumPy buffers or compiled numerical loops, with a strong compiled baseline and no interpreted loops in the timed kernel.
- For Fortran, use explicit kinds and interfaces, contiguous arrays, and suitable loop order, enabling strong optimisation for the actual CPU and inspecting vectorisation reports.
- For Julia, use type-stable functions, concrete arrays, and reusable buffers, measuring allocations and reporting just-in-time compilation separately from steady-state timing.
- Apply vectorisation, tiling, fusion, and unrolling when measurements support them and each output preserves the frozen arithmetic dependencies and rounding points, removing bounds checks only after verifying the buffer contract.

Use strong CPU-aware optimisation with contraction and fast-math disabled, including `-ffp-contract=off` for GNU Fortran, `--math-mode=ieee` for Julia, and `fastmath=False` for Numba. Inspect emitted instructions and rerun the small verifier after numerical kernel changes, since flags alone cannot establish byte agreement.

Limit tests to critical numerical or other business logic paths and their edge cases, identifying the requirement or defect that each check addresses. Use one small verifier for independent physics, conservation, complete trajectories, admissibility, exact output agreement, boundaries, and buffer bounds, adding checks only for new scientific requirements or observed defects. Do not write boilerplate, standard-framework checks, trivial unit tests, coverage-driven suites, mocks, repeated tests, or checks that merely repeat the implementation, and remove project-authored tests that do not meet this restriction.

Work efficiently towards the requested 24-hour target for the remaining weather routines. Keep an exact ordered list with original routine names, source paths, completed checks and remaining counts. Prioritise forecast-reachable calculations and develop numerical children before their callers. Use the original Fortran to understand the interface and ordered calculations, record the physics and numerical contract, then write the assembly directly. Verify several completed replacements in one forecast batch when their dependencies permit it. Report accepted routines and blockers plainly, update the completion estimate from actual results, and keep the published evidence compact.

Prepare all remaining weather assembly candidates with three parallel workers before starting the next forecast acceptance batch. Write numerical children before their callers and keep unverified candidates local. Run the required critical checks and complete forecast comparisons together, counting only routines that pass. Finish a forecast that is already running before changing this sequence.

Keep checks lean. Run only checks needed to accept changed numerical behaviour or investigate an observed defect, then stop when they pass. Reuse accepted results, verification tools, arithmetic routes and interface checks for unchanged code. Do not repeat provenance reviews, large-file hashes, full forecasts or broad audits without a specific unresolved requirement. Documentation and layout changes need only a focused review of affected content and links. Retain independent physical verification and zero differing output bytes for changed numerical routines.

Freeze the formulation, ordered arithmetic, input corpus, output encoding, implementation revisions, target features, toolchains, and measurement protocol before final comparisons. Preserve build commands, generator provenance, failures, hashes, and measured tuning results while timing only implementations that pass both the exact agreement and independent scientific checks.

Report repeated timing variation for each implementation, and limit conclusions to the equations, hardware, and conditions that the experiments cover.

## Size and handover

Keep Julia and any dependencies installed for this project in the Git-ignored `.runtime/` folder inside the repository, recording their versions and using the local installation paths in development commands.

Add files and dependencies only when the current research phase needs them, preferring small functions and direct build commands over general frameworks, orchestration layers, containers, or large CI configurations. Keep binaries, model weights, caches, and large logs outside Git, and preserve unrelated work without using destructive Git operations.

Commit and push each completed and verified research milestone during longer work, and record its actual checks in the local handover. When the user requests a pause after the current checkpoint, finish its required checks, cleanup, commit and push, record the handover, then pause the goal and stop. Before starting another checkpoint, compare its expected duration with the allocation time left. Leave time to verify, clean up, commit and push. If a new checkpoint cannot finish within that time, ask for a new allocation before starting it.

After meaningful work, update the local `.agents/HANDOVER.md`, creating it if necessary and keeping the current state, decisions, and next steps concise. Append a dated entry that records completed work and actual checks, rather than every tool call, so that the handover remains useful without presenting plans as results.
