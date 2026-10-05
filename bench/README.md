# Arm interfaces and evaluation

The target is Linux on little-endian AArch64 Neoverse V2, with one pinned core, binary64 NEON, and a verified 128-bit SVE vector length. The short formulations explain [shallow water](../formulations/shallow_water.md) and [energy balance](../formulations/budyko_sellers.md). The md2asm [shallow-water contract](../skills/md2asm/references/shallow_water.md) and [energy-balance contract](../skills/md2asm/references/budyko_sellers.md) define the numerical operations and output encoding, while [results.md](results.md) records the accepted comparisons.

## Solver interfaces

The application binary interface (ABI) specifies how a function receives arguments and preserves the caller’s data. Assembly and both Fortran libraries expose the following C ABI entry points, with signed 32-bit dimensions and step counts passed by value and 64-bit buffer pointers.

| Entry points | Registers | Arguments |
| --- | --- | --- |
| sw_step, sw_run | w0, w1 | Interior nx, ny |
| sw_step, sw_run | x2, x3, x4 | Current q, first stage, complete-step output |
| sw_step, sw_run | x5, x6 | Work storage, parameters |
| sw_run | w7 | Complete-step count M |
| eb_step, eb_run | w0 | Interior cell count N |
| eb_step, eb_run | x1, x2, x3 | Current q, first stage, complete-step output |
| eb_step, eb_run | x4, x5, x6 | Work storage, coefficients, parameters |
| eb_run | w7 | Complete-step count M |

For shallow water, P=nx+2 and S=P(ny+2), with q, stage, and output each storing three consecutive S-element fields in h,mx,my order, x contiguous; work has five S-element fields, and parameters contain g,dx,dy,dt. For energy balance, P=N+2, with q, stage, output, and work each storing P temperatures, coefficients storing three P-element fields in K,W,I order, and parameters containing C,dt,delta,A,B,Tf. All arrays are disjoint, contiguous, and at least eight-byte aligned, with sizes and units fixed in Section 10 of each solver contract.

A step preserves the input interior while copying its required ghosts, then returns both complete stages and their ghosts. A run alternates q and output, returning the final state in output after an odd count and q after an even count, with stage containing the last first-stage state; a zero count leaves every buffer unchanged. Work contents have no scientific output contract, and coefficients and parameters remain immutable.

The stack stays 16-byte aligned under the [Arm procedure call standard](https://github.com/ARM-software/abi-aa/blob/main/aapcs64/aapcs64.rst), with the direct shallow-water and energy-balance solvers using 176-byte and 160-byte public frames respectively. They preserve x19–x29 and the required low 64 bits of v8–v15, handle predicated vector remainders within the declared buffers, and implement both time stages and all boundary copies themselves.

Vanilla Fortran supplies the canonical discrete trajectory after independent physical verification. Both Python variants use Numba, and each Julia variant runs in a separate persistent worker, with shared input bytes and direct returned-state comparisons; the driver supplies storage and evaluation without performing an omitted numerical stage.

## Local toolchains and commands

Keep project installations in the Git-ignored `.runtime/` folder. The current paths are `.runtime/python` and `.runtime/julia-1.12.7`, with the Python packages pinned in [requirements.txt](requirements.txt), Julia's depot inside `.runtime/`, and one thread for every language runtime.

Load `gcc-native/14.2` and `cray-python/3.11.7` on this system, then build with `make all ebm`; the compiler reports GNU Fortran 14.3.0 despite the module label. Normal CPU-aware controls use `-O3 -mcpu=neoverse-v2 -msve-vector-bits=128`, with contraction and fast-math disabled, while [Makefile](../Makefile) records the additional measured compiler tuning for specialised Fortran.

Obtain an exclusive single-node Slurm allocation, confirm that no other job occupies its node, and use the following launch inside that allocation after setting OMP_NUM_THREADS, OPENBLAS_NUM_THREADS, and NUMBA_NUM_THREADS to 1.

```bash
srun --jobid="$SLURM_JOB_ID" --overlap --exact \
  --ntasks=1 --cpus-per-task=2 --cpu-bind=map_cpu:1 \
  --mem-bind=local .runtime/python/bin/python bench/run.py verify
```

The Slurm step reserves two CPUs so that CPU 1 can be selected explicitly, while the process itself uses that single core with local NUMA placement. Replace the command arguments with `--model budyko_sellers verify` for energy balance, keeping the same launch and environment; all development commands and benchmarks use the allocated compute node.

After both verifiers pass for the current source and binary hashes, use `bench --sizes 64,256,1024 --steps-per-size 8192,512,32 --target-seconds 0.4` for shallow water and `--model budyko_sellers bench --sizes 128,4096,65536 --steps-per-size 1000000,40000,2048 --target-seconds 0.2` for energy balance. Verification and raw timing records stay in `bench/.runs/`, with energy-balance records under its model subfolder and all binaries under `bench/.build/`; these folders are ignored by Git.

The compact verifier covers analytic states, convergence, budgets, admissibility, complete trajectories, boundary copies, input preservation, parameter immutability, and guarded buffers. It compares every verification stage and step bit for bit and then compares canonical files directly, rejecting a mismatch with its first stage, step, field, cell, and bit patterns; hashes identify artifacts without replacing byte comparisons.

## Controlled measurement

The protocol uses four warm-up steps, identical buffer preparation, twelve repeated batches, rotating and reversed execution order, and garbage collection disabled inside the timer. Each accepted batch lasts at least 0.1 seconds, and the timed final stage and state are compared directly outside the timer, while compilation, input preparation, and file output remain outside timed work.

Before and after timing, the driver requires two consecutive 0.2-second windows with one-minute load at most 2 and activity outside the pinned core at most one busy-core equivalent, allowing ten seconds for the node to settle. It verifies exclusivity, CPU and NUMA placement, FPCR=0, and the actual SVE vector length, rejecting changed conditions or foreign activity above that limit during a batch.

A disturbed batch is discarded with its reason, then the same input and warm-up are restored before another attempt under the unchanged limits. Three consecutive failures stop the comparison and require another quiet exclusive node; accepted records retain the rejection history, observed clocks, PMU counters, toolchain versions, and artifact hashes.

Cold Julia process startup, first numerical invocation, Numba cache hits and misses, and Julia request compilation are recorded separately from steady-state time. Julia's request compilation covers the numerical invocation and driver code, while native-process peak memory covers the shared Python harness and its loaded implementations; numerical buffer storage is reported separately and these aggregate process values are not per-kernel memory costs.

Native timing reuses identical physical arrays across implementations and restores each frozen input before warm-up and again before the timer, while Julia's separate workers allocate their own arrays for each batch. Every sample records buffer addresses, and repeated variation must therefore accompany comparisons where those runtimes cannot share placement.

## Exact transformations and measured bounds

Specialised paths replace division by a positive normal power of two with multiplication by its exactly representable inverse when the declared domain permits it. Both sequences perform the same real operation followed by the same single rounding, preserving computed signs and gradual underflow; other divisors retain correctly rounded division, and unchanged vanilla trajectories verify the complete result.

Apply [md2asm](../skills/md2asm/SKILL.md) to analyse the [roofline model](https://www2.eecs.berkeley.edu/Pubs/TechRpts/2008/EECS-2008-134.pdf) using the [Neoverse V2 optimisation guide](https://documentation-service.arm.com/static/668bc0a369e89f01e39c4668). The relevant bound combines compatible arithmetic throughput with bandwidth at the memory level that supplies the kernel's traffic, including division and square-root resources where needed; fused-multiply-add peak throughput is outside this experiment's arithmetic contract.

Run `roof --target-seconds 0.2` under the same launch to calibrate add, multiply, division, square root, and representative mixed-instruction throughput, together with one-read/one-write, seven-read/one-write, five-read/two-write, and eleven-read/two-write streams. Cache-sized and memory-sized working sets, numerical probe checks, repeated variation, and PMU readings remain in `bench/.runs/roofline.json`, with model-specific counts and achieved fractions in the compact results.

The per-thread Linux PMU group measures user-space cycles, retired instructions, and Arm L1D and L2D refills without multiplexing, rejecting incomplete readings. Refills describe cache fills rather than complete memory traffic, so the analysis keeps logical load/store bytes, cache refills, and DRAM bandwidth separate and treats calibrated roofs as empirical ceilings rather than proof of global optimality.
