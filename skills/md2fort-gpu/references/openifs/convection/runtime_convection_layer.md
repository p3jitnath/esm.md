# GPU Runtime Convection Layer

This component runs the prepared convection column parent on an NVIDIA GH200 GPU. The Arm entry keeps the same seventeen live addresses as the [accepted runtime convection layer](../../../../md2fort/references/openifs/physics/runtime_convection_layer.md). It forwards the original seventy-six child addresses and owns allocation, release and call order. The five local numerical stages, saturation, complete convective update and cloud/rain diagnostics execute on the GPU. The actual controls make the stratocumulus diagnostic branch inactive. This is a component check with prepared fields; loaded weather, complete CALLPAR, an autonomous time loop and comparative timing remain separate.

## Inputs And Ownership

The unchanged parent guards admit column count `P` from 1 through 4096 and level count `L` from 4 through 137, with `P*L<=65536` and `align16(60*P*L+8*P+16)<=1048576` bytes of parent work. The first column is from 1 through `P`, the last from 0 through `P`, and a first value greater than the last denotes an empty range. The new actual-producer comparisons use `P=1,8,17` and `L=137`, including full, partial, empty and active deep-convection cases. They retain the original protected placements and field indices.

The actual model setup supplies physical constants, thermal parameters, dynamical controls and two distinct corresponding clock records. The selected values include a 450-second current physics interval, radiation frequency 8, diffusion coefficient 1.5 and current step from 0 through 8. The global current-step alias is the assembly-owned clock plus 36 bytes. The hook policy is the accepted false policy, which keeps profiling inactive at its source position. Every input owner stays alive until the corresponding CUDA call has synchronized. The selected GPU supports ordinary host memory through its own page tables, so these live addresses need no device-copy relocation.

## Direct Launch Service And Generic Child

Select `generic_convective_column_calls.S` for the qualified generic CUMASTRN host boundary and `direct_cuda_launch_service.S` for the qualified direct CUDA service. Each includes an existing assembly body with a compile-time selector. Select one host boundary and one CUDA service when linking. The default CUMASTRN dispatcher and current mailbox service retain their complete native objects. The direct service has the same complete object as the retained qualified ordinary-launch service. The earlier R47 mailbox join returned CUDA error 2 at the provisional-state boundary and is retained as an unaccepted provider join.

The direct service uses a 384-byte aligned Arm frame and preserves the Arm ABI, including `x18`, saved registers, the floating-point control register and incoming status. Its launch combines only the new natural GPU flags and the last ordered mathematical error event with the incoming state. The common context has 64 bytes: refusal at 0, revision 1 at 4, new status flags at 8, control flags at 12, ordered error event at 16, call identifier at 24, scratch address/bytes at 32/40, and specific record address/bytes at 48/56.

| Entry | Consumed arguments | Result |
| --- | --- | --- |
| `md2asm_openifs_gpu_initialize` | `x0` module path, `x1` device ordinal | Zero on success; otherwise an input or CUDA error. |
| `md2asm_openifs_gpu_prepare` | No arguments; module path from `MD2ASM_OPENIFS_GPU_MODULE` and device ordinal zero. | Initialize once, then reuse the owned module/context. |
| `md2asm_openifs_gpu_launch` | `x0` entry name, `x1` complete address vector, `x2` context, `x3` blocks, `x4` threads per block, `x5` shared bytes. | Zero on success; otherwise refusal or CUDA error. |
| `md2asm_openifs_gpu_finalize` | No arguments. | Release the owned module/context. |

The parent keeps the exact accepted 4,696-byte object. The generic CUMASTRN boundary keeps its original sixty-eight-address interface and 320-byte record. The five local-stage records have 224 bytes, and CUCCDIA keeps eighteen addresses and a 192-byte capacity record. The selected complete numerical children and their status interfaces are unchanged. These joins supply no CPU weather fallback.

## Signed Diagnostic Accumulator

The old CUCCDIA variant admits a finite previous rain diagnostic from zero through $`2^{40}`$. The runtime variant admits a finite value from $`-2^{40}`$ through $`2^{40}`$. Only that lower-bound guard literal changes. The original separately rounded reciprocal, flux multiplication and addition keep their exact order. Humidity, flux, index, capacity, alignment and disjoint-owner guards retain their old limits.

The saved active comparison uses a declared `-47` preservation marker in the previous diagnostic. This marker tests accumulation; it is not a physically produced negative rain rate. The original source adds a positive rain increment and returns `-46.99913619073695`. The GPU returns those exact bytes, and an independent 120-digit relation checks the positive increment and its rounding bound. The default source/object/module remain qualified separately.

The default and signed PTX entries include `shared_convective_cloud_rain_diagnostics.inc.ptx`. Expand assembly-source inclusion with `gcc -E -P -nostdinc -x assembler-with-cpp`, then assemble the result with `ptxas -arch=sm_90 --fmad=false -O3 -c`. This preprocessing selects one guard constant and performs no numerical compilation. Both complete projected GPU objects match their qualified flat-PTX objects. The default source is also compared with a fresh pre-extraction public object.

## Actual Checks And Limits

Thirteen GPU-only calls reuse the thirteen exact accepted source/CPU packets without replaying either weather implementation. They compare 65,190,408 numerical, nonaddress metadata and defined-status bytes with zero differences. The status has exactly 20 defined bytes per call: FPCR 8, FPSR 8 and errno 4. All native ABI masks are zero; FPCR is zero, FPSR is 16 or 24, and errno is 777 or 34 as the saved source packet requires. The independent parent checks evaluate 105,048 high-precision relations, with two additional relations for the active rain increment.

Process-specific addresses account for a separate 19,552 bytes. All 2,444 typed pointer slots have exact owner, offset, stride and span correspondence, and 975 original child-argument address associations and 35 actual namespace/GOT symbols per case are checked. These addresses are never described as literal cross-process byte agreement. Complete current read-only owners preserve 60,667,648 bytes. Thirty-two additional typed setup owners per case preserve another 19,493,136 bytes; those extra payloads lie outside the archived weather packet, so their unchanged accepted producer science is reused with complete current preservation.

The new signed-domain check adds ten finite calls at both protected placements and twelve atomic refusals for values just outside the interval, infinities and quiet/signalling NaNs. Its 61,160 defined input/output/status bytes and twenty independent update relations pass. Both finite endpoints and both signed zeros are included. Refusals leave every returned word and immediate status unchanged. The sixteen parent admission refusals are reused from the byte-identical accepted parent.

One GiB is $`2^{30}`$ bytes. The supervised parent processes use a 32 GiB address-space ceiling, 8 GiB resident-memory cutoff, 128 MiB stack ceiling and explicit process deadlines. Their largest observed address-space peak is 17,665,228,800 bytes and sampled resident peak is 421,265,408 bytes. The fixed small raw edge process has the same address-space/stack ceilings and a 120-second deadline; no separate sampled resident peak is claimed for it. Complete owner releases pass, the raw CUDA service is finalized explicitly and the terminal check finds no remaining GPU process. The earlier mailbox failure, original nonnegative CUCCDIA refusal and verification-only harness corrections remain local and unaccepted.
