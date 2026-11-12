# State Rates And Physical Increments On The GPU

Revision 3 joins two qualified PTX calculations to the autonomous AArch64 forecast. GPMKTEND converts state differences into rates, and GPADDSLPHY adds physical rates to transport state. Other numerical stages remain CPU assembly. This intermediate forecast verifies integration and does not establish a complete PTX forecast or its speedup.

## Physics And Arithmetic

The physical inputs are [state-change rates](../../../../formulations/openifs/dynamics/state_rates.md) and [physical increments](../../../../formulations/openifs/physics/physics_increment.md). Preserve the complete [GPMKTEND contract](../../../md2fort/references/openifs/dynamics/gpmktend.md) and [GPADDSLPHY contract](../../../md2fort/references/openifs/physics/gpaddslphy.md), including units, descriptor order, buffer extents and inactive cells. FP64 means 64-bit floating-point arithmetic, and RN rounds once to nearest FP64 with ties to even.

GPMKTEND forms the rounded reciprocal of the positive interval, subtracts earlier from later state, then multiplies by that reciprocal. GPADDSLPHY multiplies the supplied rate by its interval, then adds the rounded product to state. Preserve each separate rounding point and every repeated field selection. Wind uses metres per second, temperature uses kelvin and mass fractions use kilograms per kilogram. Rates use the corresponding units per second. Tracers with other units retain their caller's units.

Direct sources are [state rates](../../../../src/openifs/dynamics/gpu/state_rates.ptx) and [physical increments](../../../../src/openifs/physics/gpu/physics_increment.ptx). Each PTX entry takes two u64 values, the original argument-vector address and the [64-byte GPU context](gpu_call_context.md). Each original argument occupies one eight-byte vector slot and holds an address. The existing CPU contracts define the 14 GPMKTEND slots and 13 GPADDSLPHY slots, measured object offsets and nonoverlap rules. Integer and logical values use 32 bits, and numerical arrays need eight-byte alignment.

One thread owns one column and level, with the column varying first. Launch 128 threads per block across NPROMA times NFLEVG cells. Threads outside the rectangle or active columns return before numerical access. Preserve leading and trailing vertical boundaries, inactive columns and unselected tracers bit for bit. The qualified [mathematical helpers](mathematical_support.md) preserve signed zeros, subnormals and new Arm-equivalent numerical flags. Independent threads combine flags with integer OR. These two calculations write no mathematical error event.

The accepted production GPMKTEND implementation returns before forming its reciprocal on an empty interval or zero layers. Original Fortran forms that reciprocal before the loop, so these inherited no-work edges can differ in per-call flags. This GPU route preserves the accepted production arithmetic and diagnostics. It does not make a new original-Fortran status claim for those edges.

## Original Calls And Storage

The [host call assembly](../../../../src/openifs/support/gpu/pointwise_forecast_calls.S) supplies the actual production GPMKTEND name `md2asm_drv_tendency_prepare_7358525`, with `gpmktend_` as an additional alias. GPADDSLPHY retains `gpaddslphy_`. The interface preserves x18, required saved registers and vector-register parts, and 16-byte stack alignment. Its 256-byte frame holds the original vector at byte 64 and a fresh context at byte 176. The wrapper performs no floating-point calculation. All owners stay at their original coherent host addresses until synchronization completes.

The first GPADDSLPHY logical flag can return without accessing unused rate addresses. Accepted zero-layer and empty-range decisions also remain. Active calls prepare the owned CUDA module, then use the [assembly launch service](cuda_runtime.md). Invalid dimensions, missing configuration or CUDA failure stop the process without a numerical fallback. A successful synchronized launch increments an integer observation counter. The host call order is serial and nonrecursive.

Build PTX for `sm_90` with `ptxas -c -arch=sm_90 --fmad=false`, then link the qualified mathematical helper objects with `nvlink`. Assemble the host calls and runtime, placing their objects before the accepted CPU archives. Confirm that the two replaced CPU archive members are absent from the selected link. The current route requires coherent host page tables and their checked device capabilities.

## Accepted Evidence And Limits

The original-interface component check passes eight cases with exact complete outputs, inherited diagnostics, x18 and saved registers. The complete controlled forecast records 2,150 calls per routine. It observes 2,150 successful GPMKTEND launches and 2,064 GPADDSLPHY launches, with 86 first-step no-work calls. All 117,957,600 GPMKTEND record bytes and 43,636,400 GPADDSLPHY record bytes match without masking. All 4,300 immediate diagnostic records match.

Controlled runs share incoming values in previously unspecified inactive storage. The existing 7,744-byte global input definition remains unchanged. A separate pre-calculation definition sets 364,800 incoming bytes across 25 private tendency allocations. It preserves every active byte, all other allocation bytes and register/status state. These inputs precede numerical work, and every returned byte remains compared. Production assembly and physics contain no such initializer or output repair.

Final controlled storage matches all 27,486,113 raw numerical bytes across 685 owners and 560 descriptor relations, with exact natural return diagnostics and register obligations. Both runs match ten saved files containing 618,140 bytes. A separate ordinary run uses only original files, with no debugger or input writes, and matches the ten saved files and all 59 retained final field views. Existing independent physical evidence and its [limits](../../../../src/openifs/README.md) remain unchanged. No GPU performance measurement is accepted by these checks.
