# Assembly-Owned CUDA Runtime

Revision 4 supplies process services for the PTX forecast. The [assembly module](../../../../src/openifs/support/gpu/cuda_runtime.S) performs no weather calculation. Host assembly retains the original input loading, complete model storage and output rules. The declared NVIDIA device must support coherent ordinary host memory through the host page tables, as checked during initialization.

The application binary interface (ABI) defines argument and register duties. This AArch64 interface uses the ordinary Arm procedure-call rules. Preserve x18, x19 to x29, the required low halves of v8 to v15 and 16-byte stack alignment. The floating-point control register (FPCR) selects rounding and related settings. The status register (FPSR) records numerical events, and the C error slot (`errno`) records library errors. These entries preserve incoming FPCR and errno across CUDA service calls. The launch entry also combines newly reported numerical flags and the last ordered mathematical error with the incoming state after a successful kernel. Other CUDA effects must not replace numerical status.

`md2asm_openifs_gpu_initialize(path,device)` takes a zero-terminated native cubin path in x0 and the CUDA-visible device index as u32 in w1. It creates one owned CUDA context, loads the module and each entry function, creates separate nonblocking streams for ordinary launches and a persistent worker, and restores the caller's previously current CUDA context. Return a CUDA result in w0. Refuse a second initialization. Keep the module and context until finalization.

`md2asm_openifs_gpu_launch(name,args,context,grid_x,block_x,shared_bytes)` takes the zero-terminated entry name in x0, original argument-vector address in x1, [64-byte GPU context](gpu_call_context.md) in x2 and unsigned launch dimensions in w3 to w5. Use one-dimensional grid and blocks, with y and z dimensions one. The argument vector and context need eight-byte alignment, valid complete storage and a lifetime through synchronization. The entry receives exactly two u64 parameters, the vector and context addresses. Clear only the three writable diagnostic fields before launch. Read results only after synchronization. Refuse a validation error before applying numerical diagnostics. An error after a completed numerical launch can retain that launch’s reported numerical flags. The caller must stop on a returned error.

`md2asm_openifs_gpu_prepare()` loads the module named by the zero-terminated `MD2ASM_OPENIFS_GPU_MODULE` environment value on CUDA-visible device zero. It reuses an already owned module, with no cache of model inputs. The first call registers the cleanup entry through the public GNU `on_exit(callback,NULL)` interface. The cleanup entry ignores callback arguments. Preserve incoming FPCR, FPSR and errno across environment, initialization and callback registration. Return a nonzero result on missing configuration or service failure. This service needs no compiler startup object handle.

`md2asm_openifs_gpu_finalize()` stops and joins an active worker before destroying the owned streams, module and context. It is safe when no context was initialized. One process-owned lock serializes callers, including initialization and finalization. Each caller saves its numerical state before waiting for the lock, and retains the lock through completion and context restoration. These interfaces must not be invoked recursively. Each launch temporarily makes the owned context current, then restores the caller's previous current context.

## Persistent Scalar Service

The [soil-water scalar body](../../../../src/openifs/surface/gpu/soil_water_stages.ptx) keeps its complete 17-mode calculation in a callable device function. Its ordinary entry and the [persistent worker](../../../../src/openifs/surface/gpu/soil_water_mailbox_worker.ptx) call that same body. Only the named soil-water entry with one block, one thread and zero shared bytes uses this service. Before an ordinary lookup or launch, the host stops and joins an active worker under the request lock. The next scalar request starts it again. This lets CUDA prepare larger per-thread working storage while no persistent work is active, following its [context resource rules](https://docs.nvidia.com/cuda/archive/12.6.0/cuda-driver-api/group__CUDA__CTX.html). Ordinary launches use their own stream and wait for that stream to complete.

A mailbox is a small shared request record. This process-owned mailbox has 64 bytes and 64-byte alignment. It remains live until the worker stops and its stream completes.

| Byte Offset | Type | Meaning |
| --- | --- | --- |
| 0 | Unsigned 64-bit integer | Request sequence |
| 8 | Unsigned 64-bit integer | Completed sequence |
| 16 | Unsigned 32-bit integer | Operation, zero to stop or one to call |
| 20 | Unsigned 32-bit integer | Private transport error |
| 24 | 64-bit address | Original argument vector |
| 32 | 64-bit address | Original GPU context |
| 40–63 | Reserved bytes | Unchanged |

The host writes a fresh request, then publishes its sequence with a release store. The worker reads it with a system-scope acquire load, which makes the preceding request writes visible. It calls the complete numerical body and publishes completion in the same way. The host waits with an acquire load before reading results. Sequence arithmetic wraps at the unsigned 64-bit limit. Keep the argument vector, context, every referenced buffer and all aliases live until completion. No physical input or result is cached.

Load all entry functions before starting the worker so that later function loading does not wait for the persistent stream. Ordinary work uses its own nonblocking stream and waits only for that stream. For a long pending request, query the worker stream to expose asynchronous driver failure. On shutdown, publish stop and wait for worker-stream completion before releasing its storage.

The component checks preserve complete owner bytes for all 17 modes, changing requests from eight host threads, shared counters, sequence wrap, refusal, stop and restart. The original runtime ABI checks pass while the worker is active. Two complete soil-water calls also preserve outputs, inactive bytes, read-only inputs, status, actual helper counters and 97 independent physical relations. These results qualify the transport component. Complete-forecast agreement and quiet-node performance remain separate gates.

Check the actual imported CUDA signatures against the installed CUDA 12.6 header. Verification must cover nested original pointers, a caller-owned stack vector, unchanged input and surrounding bytes, x18 and saved registers, fresh and inherited floating-point state, mathematical error preservation and writes, invalid module and entry names, repeated initialization, and final cleanup. Use only storage operations in the verification kernel. No runtime result is a numerical forecast result.
