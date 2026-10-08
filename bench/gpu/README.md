# GPU evaluation

This evaluation runs the frozen shallow-water and Budyko–Sellers methods on one NVIDIA GH200. Direct PTX assembly, vanilla and tuned CUDA Fortran, CUDA.jl and Numba CUDA compute complete FP64 time steps with exactly the same output bytes as the unchanged CPU Fortran reference. The [GPU contract](../../skills/md2asm-gpu/references/gpu-contract.md) defines the arithmetic, storage and schedules. The [results](results.md) and [raw repeated samples](results.json) describe the accepted measurements.

## Runtime and build

Use an exclusive Slurm compute-node allocation with a quiet node and one fixed GPU. The evaluator checks scheduler occupancy, CPU affinity, FPCR=0, GPU identity, foreign activity and live telemetry. It rejects shared nodes, overlapping Slurm steps or disturbed timing. Reserve the node with the site's `salloc` options and set `GPU_JOB_ID` to that allocation's job ID. Run steps sequentially because the current GPU permits one compute process at a time.

The recorded environment uses NVIDIA HPC SDK 24.11, CUDA 12.6.77, Python 3.11.7 and Julia 1.12.7 with CUDA.jl 6.4.2. Keep Python in `.runtime/python` and Julia in `.runtime/julia-1.12.7`, with the Julia project and depot in `.runtime/julia-env` and `.runtime/julia-depot`. Install the Python packages from [requirements.txt](requirements.txt). The full installed package versions are recorded in results.json. Adjust [env.sh](env.sh) to the local SDK location while preserving the numerical flags and `sm_90` target.

Julia uses the local CUDA toolkit through this `.runtime/julia-env/LocalPreferences.toml` file. Its project depends on CUDA and records CUDA_Compiler_jll and CUDA_Runtime_jll as extras, so that these preferences are discovered.

```toml
[CUDA_Compiler_jll]
local = "true"
version = "12.6"

[CUDA_Runtime_jll]
local = "true"
version = "12.6"
```

On the recorded system, load `gcc-native/14.2` after sourcing env.sh. That module supplies GNU 14.3.0 and supports the Neoverse V2 CPU reference flags. Fortran GPU controls use `-O3 -cuda -gpu=cc90,nofma,noflushz,nordc,keep,cuda12.6 -Kieee`. The direct route uses `ptxas -arch=sm_90 --fmad=false`. The host driver only makes CUDA calls and selects launch geometry.

```bash
srun --jobid="$GPU_JOB_ID" --overlap --gres=none -N1 -n1 -c1 --cpu-bind=cores bash -lc '
  source bench/gpu/env.sh
  module load gcc-native/14.2
  make gpu gpu-reference gpu-calibration gpu-pass1
'
```

The `gpu-pass1` target assembles the frozen first-pass PTX from local commit `2ef5dc5`. That baseline supports a matched measurement of the additional aggressive assembly pass. Source and generated binary hashes identify both routes. Every numerical source is under `src/<model>/gpu/`, while the original CPU sources and formulations remain unchanged.

## Scientific, graph and instruction checks

Complete every check before comparative timing. The scientific verifier checks all inherited physical cases, complete trajectories, each stage and step, conservation, convergence, boundary copies, threshold ties, immutable inputs, buffer guards and canonical file bytes. Additional cases exercise one-cell dimensions, partial blocks, dispatch thresholds and gradual underflow. There are 34 shallow-water cases and 25 energy-balance cases for each implementation. Native checks include the first-pass assembly baseline.

Graph checks cover zero, odd and even step counts at grids that use each selected dispatch route. Ordinary launches and captured graph replay must preserve all required outputs, including the last first stage and physical q/out parity. Zero steps must leave every buffer unchanged.

```bash
srun --jobid="$GPU_JOB_ID" --overlap --gres=gpu:1 -N1 -n1 -c1 --cpu-bind=cores bash -lc '
  source bench/gpu/env.sh
  module load gcc-native/14.2
  for model in sw eb; do
    names=fortran_vanilla,assembly,gpu_fortran_vanilla,gpu_fortran,gpu_python_vanilla,gpu_python,gpu_pass1
    .runtime/python/bin/python bench/gpu/run.py --model "$model" --mode verify --names "$names" || exit
    .runtime/python/bin/python bench/gpu/run.py --model "$model" --mode graphs --names "$names" || exit
    .runtime/python/bin/python bench/gpu/audit.py --model "$model" || exit
    for variant in julia_vanilla julia; do
      .runtime/python/bin/python bench/gpu/run.py --model "$model" --mode verify --names "fortran_vanilla,$variant" || exit
      .runtime/python/bin/python bench/gpu/run.py --model "$model" --mode graphs --names "$variant" || exit
      .runtime/python/bin/python bench/gpu/audit.py --model "$model" --group "$variant" || exit
    done
  done
  .runtime/python/bin/python bench/gpu/division_check.py || exit
  .runtime/python/bin/python bench/gpu/calibrate.py
'
```

Instruction inspection archives real PTX and NVIDIA machine instructions. Julia's read-only audit uses CUPTI to obtain the actual loaded cubin and cuobjdump to disassemble it, avoiding a CUDA 12.6 nvdisasm failure while expanding inline source-line information. An internal DFMA instruction can belong to a correctly rounded divide or square-root refinement. It does not by itself show a fused model operation. Explicit rounded assembly and Julia/Python intrinsics, the Fortran flags, inspected code and complete bit checks provide the combined arithmetic evidence.

The division check records a numerically exact power-of-two shortcut that was screened and rejected for performance. It spans signed zero, gradual underflow, overflow, rounding ties and fallback divisors. It lives only in the calibration probe cubin, and the selected solvers retain correctly rounded ordinary division.

## Timing and plots

Do not change sources or binaries between final verification and timing. Comparative timing requires scientific and graph reports with exactly the current source and binary fingerprints. The final driver rotates native and sequential Julia process groups across twelve repetitions, reverses their order on alternating cycles, and rotates the five native implementations within their group. Julia uses the same GPU UUID in a separate worker because the GPU permits one process at a time. Allocation and startup differ between these processes and are recorded separately.

The numerical fingerprint covers models, contracts, build inputs, evaluation drivers and actual binaries. The report and plotting scripts process saved measurements and have separate source hashes in results.json. Their presentation edits do not change accepted solver evidence. A launch handles a complete grid, so the launch-cost guide divides launches per complete time step by the number of cells before comparing cell updates per second.

The native group shares the same guarded device buffers. All variants receive the same binary inputs, parameter values and complete step counts. Warm-up lasts at least 30 ms outside the timer. CUDA events on the solver stream time one replay of the complete graph. Compilation, runtime startup, allocation, transfers, graph construction, file output and validation are outside this interval. Their costs appear separately in results.json. Every timed last stage and final state must still match the canonical files with zero differing bytes.

```bash
srun --jobid="$GPU_JOB_ID" --overlap --gres=gpu:1 -N1 -n1 -c1 --cpu-bind=cores bash -lc '
  source bench/gpu/env.sh
  module load gcc-native/14.2
  for model in sw eb; do
    .runtime/python/bin/python bench/gpu/run.py --model "$model" --mode benchmark --names gpu_pass1,assembly --repeats 12 --output "bench/.runs/gpu/aggressive/$model-paired.json" || exit
    .runtime/python/bin/python bench/gpu/compare.py --model "$model" --repeats 12 || exit
  done
  .runtime/python/bin/python bench/gpu/report.py
'
```

The primary unit is million complete cell updates per second, the same `Million/s` axis used in the CPU plots. Higher is faster. A shallow-water cell update includes all three fields, both stages and periodic boundaries. An energy-balance band update includes both stages and pole boundaries. Timing records also retain microseconds per complete step for reproducibility. Candidate screening uses the explicit `--screening` option, with ordinary, replay and timed-output checks. Screening results are separate from the final twelve-run comparison.

Render the accepted records with [plot.py](plot.py) and the installed graph-plotting skill's style helper. `GRAPH_PLOTTING_SKILL_DIR` or `--style-bundle` can select a refreshed skill bundle. The figures retain the CPU plot colours, row order, horizontal bars and vanilla hatching. They use Nimbus Sans at readable publication size, with medians and observed minimum-to-maximum whiskers. Each panel has its own linear scale starting at zero. The script audits the figure and exports editable SVG, vector PDF and 300-dpi PNG files. Inspect the exports visually before accepting them.

```bash
.runtime/python/bin/python bench/gpu/plot.py
```

The performance guide uses measured ordinary FP64 arithmetic, true division, true square root, cache and streaming-copy rates and empty-kernel launch cost on the same GPU. The 128-band persistent method uses a one-multiprocessor calibration. Operation counts, logical bytes and assumptions are explicit. These measurements guide interpretation and do not establish a hard upper bound or global optimality. Large raw logs, cubins and local failed candidates remain in ignored folders, while compact evidence and plotting sources are tracked.
