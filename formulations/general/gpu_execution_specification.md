# GPU Execution Specification

Revision 1.5 carries the verified shallow-water and energy-balance methods to an NVIDIA GH200. The [water formulation](../sw/shallow_water.md) and [Rusanov–SSPRK2 specification](../sw/shallow_water_specification.md), and the [energy-balance formulation](../ebm/budyko_sellers.md) and [numerical specification](../ebm/budyko_sellers_specification.md), remain authoritative for equations, ordered arithmetic, stability, supported inputs and canonical bytes. This reference fixes GPU execution and does not change the physical models.

## Target and Direct Sources

The qualified target is one NVIDIA GH200 with compute capability 9.0, little-endian Linux, CUDA 12.6, PTX 8.5 and an `sm_90` cubin. PTX is NVIDIA’s virtual assembly language. The archived direct sources are [two-dimensional Rusanov–SSPRK2](https://github.com/p3jitnath/esm.md/blob/8be04b8/src/sw/gpu/2d_rusanov_ssprk2.ptx) and [Budyko–Sellers](https://github.com/p3jitnath/esm.md/blob/8be04b8/src/ebm/gpu/budyko_sellers.ptx). They are emitted from the frozen Markdown specifications and assembled with `ptxas -arch=sm_90 --fmad=false`. A cubin contains the resulting native GPU machine code.

Each required operation uses nearest-even FP64 rounding with gradual underflow, preserved signed zeros and the original operand order. Threshold ties, intermediate stages and canonical bytes stay unchanged. Correctly rounded division and square root may use internal machine-code refinement. Model multiply and add remain separately rounded. The canonical CPU Fortran reference uses verified round-to-nearest arithmetic, gradual underflow and disabled contraction.

## Arguments and Storage

Kernel dimensions, stage selectors and step counts are unsigned 32-bit integers. Device addresses are unsigned 64-bit values. Numerical buffer owners are disjoint and at least eight-byte aligned. The existing CPU specifications limit water dimensions to 1 through 4096 in each direction, energy balance to 1 through 65536 bands, and either run to at most 1000000 complete steps; these inherited bounds keep the declared index calculations within their integer ranges. Water has `P=nx+2`, `S=P*(ny+2)`, three state fields with `3*S` FP64 values per state, five scratch fields with `5*S` values, and four FP64 parameters. Energy balance has `P=n+2`, one state field and one scratch field with `P` values each, three coefficient fields with `3*P` values, and six FP64 parameters. Their field order and parameter bytes are those of the CPU specifications. In a water update, `q` means the current stage input and `base` means the complete-step input: they refer to the same owner for the first stage, while the second stage reads distinct `stage` and complete-step input owners. The update output is always a separate owner.

| Entry | Ordered Arguments | Launch Requirement |
| --- | --- | --- |
| `sw_edges` | `nx,ny,q` | Covers `3*(2*(nx+2)+2*ny)` boundary values |
| `sw_prepare_clean` | `nx,ny,q,work,par` | Covers `S` cells, including ready ghosts |
| `sw_update_small` | `nx,ny,q,base,out,work,par,final` | 64 threads per block, three grid z planes, at most 4096 interior cells |
| `sw_update_medium` | Same as `sw_update_small` | 128 threads per block, grid y equals `ny`, 4097 to 65536 interior cells |
| `sw_update` | Same as `sw_update_small` | 64 threads per block, flat grid above 65536 interior cells |
| `eb_persistent` | `n,q,stage,out,work,coeff,par,steps` | One block of exactly 128 threads, 1 to 128 bands |
| `eb_temporal` | Same as `eb_persistent` | Exactly 128 threads per block, `ceil(n/112)` blocks, 1 to 4 steps per call |
| `eb_publish` | `n,q,out,work,steps` | 128 threads per block, covers `n` bands |

`final` is zero for the first stage and one for the second stage. Threads outside ordinary declared work ranges return before numerical loads or stores. Persistent and tiled entries keep inactive threads at every required barrier. The sources retain `sw_halo`, `eb_halo`, `eb_update` and `eb_complete` compatibility entries, and `division_check` for the accepted arithmetic probe. Every launch uses one ordered stream. GPU thread registers are private, while shared storage and barriers obey the launch requirements above.

The host owns allocation, transfer, launches, synchronisation, graph capture and writing returned bytes. All fluxes, wave speeds, stages and boundaries run on the GPU. Scientific reductions run separately outside the solver timer. There is no reduction across cells inside either model’s time update.

## Complete Water Steps

The unfused reference follows the original boundary copy, point preparation D03 and component update D04 for each of the two stages. A boundary cell reads its matching interior source directly. No copied ghost depends on another concurrent ghost write.

The selected direct schedule copies only the required periodic edges once before a nonempty batch. `sw_prepare_clean` then reads the ready input and ghost values. Each update thread writes its interior result and every corresponding periodic ghost from that same rounded result. Unique interior sources own corners and one-cell boundaries. Two ordered preparation launches and two ordered update launches complete each step, with all required first-stage values retained.

The small route assigns a separate component to each grid z plane. The medium route uses x/y coordinates, and the large route uses a flat cell index. Medium and large routes compute a face’s rounded half-wave-speed once before the three-component calculation. They preserve the left-speed tie rule and each face’s original arithmetic. The thresholds select work layout from dimensions alone.

## Complete Energy-Balance Steps

The unfused reference follows input pole copies, face flux D02 and first update D03, then repeats flux and update for the second stage and writes the output poles. Pole fluxes are positive zero. Temperature equal to the ice threshold selects the ice forcing. Local recomputation repeats the same rounded neighbouring expressions.

For 1 to 128 bands, `eb_persistent` keeps each active band’s current temperature in registers and uses two shared rows of 130 FP64 values, totalling 2080 bytes. All 128 threads reach the initial barrier and two barriers per complete step. Each active thread loads immutable coefficients, parameters and the rounded time-step-to-heat-capacity ratio once. The final preceding state, first stage and final state restore physical buffers and pole copies according to total step parity.

Above 128 bands, `eb_temporal` uses 128-thread tiles. Each tile owns 112 bands and loads eight extra bands on each side. With local indices starting at zero, a thread’s one-based global band is `112*block+thread-7`, and owned local indices are 8 to 119. At step `k`, starting at zero, the first stage uses local indices `2*k+1` through `126-2*k` and the second stage uses `2*k+2` through `125-2*k`. Every stage ends with a block barrier. These bounds retain every dependency of the owned bands for up to four complete steps. Two shared rows of 128 values use 2048 bytes.

Only owned threads return the last preceding state to `out`, the last first stage to `stage`, and the last final state to `work`, with unique pole owners. The tile never changes global `q`. After all tiles finish, `eb_publish` restores physical rows. For an even batch, `q` receives `work` while `out` retains the preceding state. For an odd batch, `q` receives the preceding `out` and `out` receives `work`. Full batches contain four steps, followed by an optional remainder. No tile reads another tile’s newly produced state.

## Exact Spacing Dispatch and Repeated Calls

A positive normal power-of-two spacing with a finite normal exact inverse permits multiplication by that inverse in place of division, because both operations round the same real value once. Its sign and fraction bits are zero and its stored exponent is from 1 to 2045. The inverse’s stored exponent is 2046 minus the original exponent. Water takes this path only when both spacings qualify. Other spacings retain correctly rounded division. Dispatch happens once before the whole component calculation or repeated loop. `division_check` exposes the same inverse construction and rounded operation for independent CPU edge-value checks.

Repeated steps alternate `q` and `out`. The last state is in `out` after an odd count and `q` after an even count, while `stage` holds the last first stage. Zero steps launch no numerical operation and leave all buffers unchanged. Ordinary launches and CUDA graph replay use the same sequence and physical buffer rule. Graph capture records compiled launches and supplies no numerical stage on the host.

## Acceptance and Measurement

The unchanged physically verified CPU vanilla Fortran implementation remains the discrete reference. Acceptance compares complete stages, trajectories and canonical files with zero differing bytes. Reports identify the first case, step, stage, component, cell and both raw 64-bit words if a mismatch occurs. Reuse inherited checks, adding only GPU partial blocks, changed dispatch or tile boundaries, graph replay and arithmetic edge cases as needed.

The archived seven-way GPU comparison passes 34 water scientific cases and 28 energy-balance cases, including 1000-step trajectories, independent convergence and conservation, boundaries, threshold ties, signed zero, gradual underflow, unchanged inputs and guarded device owners. Ordinary-versus-graph checks cover zero, odd and even counts, tile boundaries, partial tiles and repeated batches. The exact spacing route passes 96969 rounding-edge operands. Every timed required stage and final state is checked outside the timer.

| Model | Workloads | Complete Steps per Timed Batch |
| --- | --- | --- |
| Water | 64², 256², 1024² cells | 256, 128, 32 |
| Energy balance | 128, 4096, 65536 bands | 512, 256, 128 |

Twelve accepted repetitions rotate implementations and process groups on the same fixed GPU in an exclusive quiet allocation. GPU events time one replay of complete solver launches after warm-up. Compilation, startup, allocation, transfers, capture, file writing and verification remain outside the primary interval, with separate records. Native and compiled Python controls reuse the same device buffers. Julia variants run in separate sequential processes on the same GPU, while their supervising process holds no CUDA context.

Before each accepted batch, the evaluator verifies the owned exclusive node, fixed host affinity and GPU UUID, an idle selected GPU, no foreign GPU process, and bounded CPU activity. It retains load, clocks, utilisation, memory, power and temperature. Disturbed batches are rejected. Report median throughput and observed minimum–maximum ranges in million complete cell updates per second. These steady GPU rates are separate from complete CPU forecast wall times.

The archived final comparison used `nid010353`, exclusive job `7143612`, host CPU 0 and one NVIDIA GH200 120GB with 132 streaming multiprocessors. GPU clocks were 1980 MHz, temperature 36 to 38 degrees Celsius and observed power 130.7 to 171.8 W. Sampling occurred outside kernel timing and does not give energy per update. These records describe that completed study and are not a substitute for live quiet-node checks in a new run.

## Performance Guides and Evidence

Compatible device probes measure ordinary rounded arithmetic, division, square root, cache and streaming copies, and launch rate. A performance guide takes the smallest relevant operation, logical-memory or launch guide for the actual schedule. Include expanded tile work, publication traffic, small-grid occupancy and repeated-buffer costs. Logical copy bytes do not equal measured hardware transactions. The guides assume independent arithmetic and optimistic reuse or cache residence, so dependencies and barriers can lower observed performance.

| Model and Size | Relevant Guide | Observed Fraction |
| --- | --- | ---: |
| Water 64² | Launch rate | 32.7% |
| Water 256² | Logical memory | 32.6% |
| Water 1024² | Logical memory | 87.9% |
| Energy balance 128 | Ordinary arithmetic | 24.6% |
| Energy balance 4096 | Launch rate | 30.4% |
| Energy balance 65536 | Logical memory | 24.5% |

The [main README](../../README.md) gives the accepted GPU comparison. Original source versions, controls, host tools, detailed build commands, binary hashes, instruction audits, physical results, repeated samples, performance-guide counts and editable figures are retained in the ignored local GPU research archive. The source-branch archive manifest records their original paths and hashes before reorganisation. The direct PTX instructions retain their qualified numerical behaviour when the source files move into the current model folders. Rebuilding and remeasuring is required if numerical instructions, launch rules, target or controls change.


## ESM.md CUDA Fortran Execution and Build

The 12 November 2026 variants publish [shallow-water CUDA Fortran](../../src/sw/gpu/solver.cuf) and [energy-balance CUDA Fortran](../../src/ebm/gpu/solver.cuf). The equations, ordered FP64 arithmetic, state layouts, parameters, canonical bytes and inherited dimension bounds remain those of the numerical specifications above. CUDA Fortran requires a supporting NVIDIA compiler. The qualified build targets compute capability 9.0; another host, GPU or toolchain requires a new build and numerical qualification.

Each dimension, stage selector and step count is a signed `C_INT` argument passed by value. Its nonnegative supported values have the same four argument bytes as the launch record's unsigned 32-bit words. Each device-array argument is an address to caller-owned, contiguous binary64 storage aligned to at least eight bytes. `real64` and `C_DOUBLE` are binary64 in this qualified build. Water retains three state planes, five scratch planes and four parameters; energy balance retains one state row, one scratch row, three coefficient planes and six parameters. The complete storage and units are defined above. `q`, `stage`, `out` and writable scratch have separate owners. In a water stage, `base` may name the read-only complete-step input while `q` names the current stage; the output owner is separate. Parameters and coefficients remain unchanged, and source-unwritten scratch contents remain unspecified.

The measured compiler is NVIDIA HPC SDK 24.11 with CUDA 12.6 and `ptxas` 12.6.77. Set `solver_source` to the model's absolute `solver.cuf` path and run the following command in a separate local build directory:

```sh
nvfortran -O3 -cuda -Kieee \
  -gpu=cc90,nofma,noflushz,nordc,keep,ptxinfo,cuda12.6 \
  -c "$solver_source" -o solver.o
```

The water route uses the compiler-produced `solver.n001.cubin`. The selected energy-balance configuration assembles the compiler-produced PTX with the measured register-use setting:

```sh
ptxas -arch=sm_90 --fmad=false --register-usage-level=0 -v \
  solver.n001.ptx -o solver_esm.cubin
```

Keep objects, modules, compiler PTX, cubins and reports in the local build directory. The selected options disable model multiply-add contraction and preserve gradual underflow. Correctly rounded division and square root may use internal refinement instructions. Exact output checks establish agreement; compiler options alone do not. Both published source files passed `fprettify`, unchanged numerical-token and compiler-directive checks, and formatter idempotence before the accepted build.

Every numerical and state-publication kernel used by a Fortran route comes from that model's own `solver.cuf` build. The launcher opens its compiled module and resolves every selected entry from that same module. Shared C++ services allocate, copy, capture, synchronise and launch; the GPU kernels calculate all primitives, fluxes, stages, boundaries and state publication. The selected directly written PTX comparisons and their source/build/acceptance records are retained locally under `.archive/sw_ebm_assembly/20261112_gpu_optimisation/`.

| Selected entry | Ordered arguments | Launch requirement |
| --- | --- | --- |
| `sw_edges` | `nx,ny,q` | Once before a positive run; covers `3*(2*(nx+2)+2*ny)` boundary values with the selected route's block width |
| `sw_prepare_clean` | `nx,ny,q,work,par` | Before each medium or large stage; covers all `S=(nx+2)*(ny+2)` padded cells with 128 or 64 threads, respectively |
| `sw_update_small_tiled4` | `nx,ny,q,base,out,work,par,final` | At most 4,096 interior cells; 64 threads and grid `(ceil(nx/4),ceil(ny/4),1)` |
| `sw_update_medium` | Same eight update arguments | 4,097 to 65,536 interior cells; 128 threads and grid `(ceil(nx/128),ny,1)` |
| `sw_update_xy` | Same eight update arguments | Above 65,536 interior cells; 64 threads and grid `(ceil(nx/64),ny,1)` |
| `eb_persistent` | `n,q,stage,out,work,coeff,par,steps` | 1 to 128 bands; one block of 128 threads |
| `eb_temporal_dynamic_256_56` | Same eight persistent arguments | 129 to 8,192 bands; 256 threads and at most 56 complete steps per call |
| `eb_temporal_dynamic_1024_128` | Same eight persistent arguments | 8,193 to 65,536 bands; 1,024 threads and at most 128 complete steps per call |
| `eb_publish` | `n,q,out,work,steps` | After every temporal call; 128 threads and `ceil(n/128)` blocks |

For a positive water run, `sw_edges` first copies the initial periodic edges. Each complete step then makes a first-stage call with `final=0`, the current state as `q` and `base`, and `stage` as output. The second-stage call uses `stage` as `q`, the same complete-step input as `base`, the other physical state row as output, and `final=1`. The launcher exchanges the current and next state addresses after the complete step. The last state is physically in `out` after an odd total count and in `q` after an even count; `stage` retains the last first stage.

On the small water route, a tile is a four-by-four group of interior cells. The first 36 threads prepare its six-by-six patch, including neighbours, in eight shared planes: three state values, three momentum fluxes and two wave speeds. These planes use 2,304 bytes. All 64 threads reach one block barrier before any owner returns. The first 48 threads then own one field of one interior cell each. Partial tiles read only valid interior or ready ghost values. Each owner computes its stage result and publishes its unique periodic copies, including corners and one-cell grids. The second stage forms the two separately rounded half-products and their ordered sum, stores that local result once, and uses it for the ghosts. Two update launches complete a step.

Medium and large water stages first call `sw_prepare_clean`, then their selected update. They reuse each face's rounded half-wave speed across the three fields and retain the left-speed tie rule. Each update publishes its own periodic ghosts. Two preparation and two update launches complete a step. These selected layouts use live dimensions with the same compiled module across resolutions.

For energy balance at most 128 bands, one `eb_persistent` call advances the complete run. Active threads retain temperatures and immutable coefficients while two shared rows carry neighbouring stage values. All 128 threads reach each required barrier. The full 128-band path removes inactive-thread checks and the last unused shared publication. The kernel returns the final preceding state, last first stage and final state to their physical `q`, `stage` and `out` rows, including pole copies, according to total parity.

For a temporal energy-balance call, let $`B`$ be its thread count and $`K`$ its actual positive complete-step count. Its owned width is $`W=B-4K`$, its grid has `ceil(n/W)` blocks, and each side has a $`2K`$-band halo. With zero-based block and thread indices `b` and `t`, the one-based global band is `W*b+t-(2*K-1)`; owned local indices satisfy `2*K <= t < B-2*K`. Two shared rows use `2*B*8` bytes: 4,096 or 16,384 bytes. At local complete step `k`, starting at zero, the first-stage interval is `2*k+1` through `B-2*k-2`, and the second-stage interval is `2*k+2` through `B-2*k-3`. Only valid physical bands calculate values, while every thread reaches both stage barriers. The shrinking intervals retain all dependencies of the owned output.

A temporal kernel keeps global `q` unchanged. On its last step, owned threads put the preceding state in `out`, the first stage in `stage`, and the final state in `work`, with unique pole owners. An ordered `eb_publish` launch then restores the physical rows. For an even count, it copies `work` to `q` and leaves the preceding state in `out`; for an odd count, it copies the preceding `out` to `q` and the final `work` to `out`. The host repeats maximum batches of 56 or 128 steps and uses the actual remaining count for the last call. Both maximum counts are even, so each continuing batch starts from the current `q`. For 1,000 steps, the medium route has seventeen 56-step calls and one 48-step call, with owned widths 32 and 64; the large route has seven 128-step calls and one 104-step call, with widths 512 and 608. Every temporal call includes its publication launch in graph replay.

Zero steps launch no numerical kernel and leave all buffers unchanged. Ordinary launches and graph replay use the same stream order, stage calculations and physical buffer rules. Compatibility entries remain available in the source module; the table identifies the selected measured paths.

The accepted [six-condition dataset](../../paper/pasc27/poster/data/gpu-results-20261112.json) uses mixed water inputs at 64², 256² and 1,024² cells and climate energy-balance inputs at 128, 4,096 and 65,536 bands. Each timed call advances 1,000 complete physical steps, and each condition has twelve paired baseline/ESM.md samples. Exact initial state, scratch, coefficient and scalar words were frozen before an oracle could mutate them. Independent physics checks were retained, and qualification compared complete `q`, `stage` and `out` buffers, unchanged inputs, guards and canonical phase files with zero differing bytes. Launch checks include partial spatial tiles, one-cell boundaries, zero/odd/even runs, dispatch edges and complete-step counts below, at and above temporal maxima, including 55/56/57 and 127/128/129 cases.

CUDA events enclose one warmed replay of all complete solver launches. Compilation, initialisation, allocation, transfers, capture, file writing and verification are outside that interval. Returned states are checked after every timed replay. A point rate is complete cell updates divided by median seconds; its observed range uses the minimum and maximum per-sample rates. These steady GPU measurements cover one GH200, one host control core, fixed CPU1/NUMA0 placement, the selected builds and these six workloads.

The accepted run used an exclusive allocation with automatic clocks and configured/default/enforced power limits of 900 W. The fixed quiet policy required one-minute load at most 2.0, foreign CPU activity at most one busy core, idle GPU utilisation and authorised GPU processes for two consecutive 0.2-second windows. All SW1,024² post-sample records report normal software power capping, with baseline clocks of 1,425–1,440 MHz and ESM.md clocks of 1,410–1,425 MHz. Temperatures were 43–45 degrees Celsius, with no thermal event bits or foreign work. Post-event power polls are not in-event average power. The dataset retains this operating scope and repeated variation. Source-operation counts and profiles describe arithmetic, helper, launch and storage limits; requested bytes are not DRAM traffic, and the results do not establish a global performance maximum.
