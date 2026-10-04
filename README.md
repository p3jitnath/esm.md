# esm.md

esm.md studies Earth system model development in which complete physics and mathematics in Markdown form the maintained scientific source, with a direct assembly implementation built by an assembler and linker. The current Arm CPU study covers nonlinear shallow-water flow and a diffusive Budyko–Sellers energy balance model, comparing optimised assembly with vanilla and specialised Fortran, Julia, and compiled Python.

Every implementation uses the same numerical method, input bytes, ordered FP64 arithmetic, and binary output encoding. All seven variants of each model pass independent physical checks and byte-for-byte comparisons after every verification stage and step, including long trajectories; complete-step timings are collected on a quiet node in a verified exclusive Slurm allocation.

The authoritative source is in `formulations/`, while `src/shallow_water/` and `src/budyko_sellers/` contain the implementations. Each model has optimised `solver.S`, `solver.f90`, `solver.jl`, and `solver.py` sources alongside unchanged `vanilla.f90`, `vanilla.jl`, and `vanilla.py` controls, with one verifier, timing tools, and compact measurement records in `bench/`.

- [Formulation template](formulations/TEMPLATE.md) defines the 12 required sections.
- [Shallow-water formulation](formulations/shallow_water.md) specifies the periodic finite-volume flow model.
- [Energy-balance formulation](formulations/budyko_sellers.md) specifies the equal-area climate model and ice-albedo closure.
- [Evaluation instructions](bench/README.md) define the interfaces, local toolchains, and controlled execution protocol.
- [Implementation results](bench/results.md) report exact agreement, physical checks, performance, and measured bounds.
- [Markdown-to-assembly skill](skills/md2asm/SKILL.md) records reusable generation and optimisation methods.
- [Agent instructions](AGENTS.md) and [ASD-STE100-CONV](standards/ASD-STE100-CONV.md) govern development and fluent technical prose.

Build with `make all ebm` using the target compiler, then run the verifier and timing commands from an exclusive allocation as described in the evaluation instructions. Project runtimes, build artifacts, raw measurements, research notes, and the progress handover remain in Git-ignored folders, keeping the maintained repository small.

The result concerns the observable route from a complete Markdown contract to assembly and the measured implementations on this target, without making claims about a model's internal representations. Each prose paragraph or list item occupies one physical Markdown source line, including in the physics formulations, which use GitHub-compatible inline mathematics and fenced `math` display blocks.
