# Physics Calls In The GPU Forecast

Revision 1 adds six qualified PTX calls to the two accepted [state-rate and physical-increment calls](pointwise_forecast_calls.md). This eight-stage forecast retains the autonomous assembly executable and original input files. Other calculations remain AArch64 assembly, so this checkpoint establishes integration rather than a complete PTX forecast or speedup.

## Original Interfaces

The [host assembly](../../../../src/openifs/support/gpu/physics_forecast_calls.S) stores original arguments and launches each qualified entry through the [CUDA runtime](cuda_runtime.md). An application binary interface, or ABI, defines where a caller places arguments and which registers a routine must preserve. Every argument here is an original address in an eight-byte slot. The wrapper performs no numerical calculation.

| Original Call | Production Name | Address Slots | Numerical Contract |
| --- | --- | ---: | --- |
| STATE_UPDATE | `md2asm_callpar_state_update_7358525` | 5 | [State update](physics/state_updates.md) |
| STATE_INCREMENT | `md2asm_callpar_state_increment_7358525` | 13 | [State increment](physics/state_updates.md) |
| UPDATE_FIELDS | `md2asm_callpar_update_fields_7358525` | 97 | [Field transfer](physics/state_updates.md) |
| QNEGAT | `md2asm_callpar_qnegat_7358525` | 11 | [Humidity repair](physics/state_updates.md) |
| SATUR | `md2asm_callpar_satur_7358525`, also `satur_` | 10 | [Saturation humidity](physics/saturation_humidity.md) |
| CPQTUV | `md2asm_drv_physics_close_7358525` | 18 | [Physics rate closure](dynamics/physics_rate_closure.md) |

The 1,152-byte frame keeps 16-byte stack alignment. Saved registers occupy bytes 0 through 47, the argument vector bytes 128 through 903, the fresh [64-byte context](gpu_call_context.md) bytes 912 through 975 and the immutable constant-address record bytes 976 through 1071. Stack arguments are copied from the incoming stack before service calls. Preserve x18, x19 through x21, the frame pointer and return address; other required saved registers and vector-register parts remain unchanged. A focused 97-argument check verifies all thirteen complete output owners, 89 stack arguments and register obligations.

QNEGAT supplies the original gravity address in its eight-byte record. SATUR supplies its twelve original constant addresses in a 96-byte record. CPQTUV supplies its two latent-heat constant addresses in a sixteen-byte record. State and transfer calls need no record. All six entries use one block of 128 threads, no dynamic shared memory and their qualified stride loops. Metadata and complete allocation bounds follow the linked numerical contracts. Original storage remains live at coherent host addresses until synchronization.

Calls are serial and nonrecursive. Module preparation, launch and synchronization must succeed before the wrapper increments its observation counter. Failure stops the process. No numerical fallback is selected. Assemble these wrappers before the accepted CPU archives and confirm that all replaced provider members, including both SATUR providers, are absent from the selected link. Link unchanged PTX and mathematical helper objects for `sm_90` with `ptxas -c -arch=sm_90 --fmad=false` and `nvlink`.

## Accepted Forecast Evidence

The matched 24-hour forecast compares complete returned storage and immediate floating-point controls, flags, system error values and ABI state at every changed call. All 106,018 paired records agree, with no masked bytes. Empty work retains its declared behavior.

| Original Call | Recorded Calls | Successful GPU Launches |
| --- | ---: | ---: |
| GPMKTEND | 2,150 | 2,150 |
| GPADDSLPHY | 2,150 | 2,064 |
| STATE_UPDATE | 9,718 | 9,718 |
| STATE_INCREMENT | 19,350 | 19,350 |
| UPDATE_FIELDS | 2,150 | 2,150 |
| QNEGAT | 2,150 | 2,150 |
| SATUR | 66,200 | 66,200 |
| CPQTUV | 2,150 | 2,150 |

Complete comparisons include untouched incoming cells. Before calculations, both controlled runs define identical values in source-unspecified fresh storage. The prior global definition covers 7,744 bytes and the private tendency definition covers 364,800 bytes across 25 allocations. A focused allocator definition covers 33,061,824 incoming bytes across 11,760 fresh field and named private-humidity allocations per run. It operates only on newly owned numerical storage before its producer. Metadata, other allocation bytes, registers and numerical status remain unchanged. The original physics and production assembly contain no such definition, and returned values are never repaired.

At natural return, all 27,486,113 raw numerical bytes across 685 owners and 560 descriptor relations agree. Numerical status and register obligations also agree. Ten saved files match all 618,140 bytes. An ordinary run uses original files without a debugger or verification input writes and matches the ten files and 59 retained final field views. Accepted independent physical checks and their [limits](../../../../src/openifs/README.md) are unchanged. These checks measure correctness; no GPU runtime or speedup is accepted yet.
