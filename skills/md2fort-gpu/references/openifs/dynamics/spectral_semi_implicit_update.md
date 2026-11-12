# Complete spectral semi-implicit update on the GPU

Arithmetic revision 2 remains frozen from the [physical formulation](../../../../../formulations/openifs/dynamics/spectral_semi_implicit_update.md) and [original numerical contract](../../../../md2fort/references/openifs/dynamics/spectral_semi_implicit_update.md). Spectral storage represents atmospheric fields by wave coefficients; this selected route has 19 levels and 506 real and imaginary columns for the full degree-21 sphere. The semi-implicit update treats selected pressure-wave terms implicitly to keep fast waves stable. It uses finite elements, which represent vertical fields by local polynomials, with integral boundary code IBC 3 and one process. Preserve the complete hydrostatic coupled solve.

Both dense matrix products retain the arithmetic revision 2 route: start at positive zero, visit the summation index in increasing order, and round each multiplication and addition separately. The old fused vendor result remains a separate reference and is never substituted. Complete SIGAM, SPCIMPFSOLVE, SIMPLICO and SITNU execute on the GPU.

Implementation revision 2 gives each of the three child admission calls its own return parameter and reads it immediately on the same call path before the paths join. Admission checks decide whether the input layout is supported. The public arguments, context, error codes, numerical status, physical equations and ordered arithmetic remain unchanged.

## Interface and original arguments

The application binary interface (ABI) defines how a caller supplies arguments, storage and returned status. Entry `openifs_spcsi_ptx` and callable function `openifs_spcsi_parent_fp64` receive a vector of 18 original addresses and a shared 64-byte context record. Launch exactly one block with one thread. Dynamic shared memory is unused: zero is configured, and any supported allocation is admitted.

Slots are numbered from zero. An array descriptor records an array's address, shape and strides; a stride is the spacing between successive elements.

| Address-vector slots | Original arguments, in order |
| --- | --- |
| 0–4 | Geometry, diagnostics, integration, dynamics, nonhydrostatic configuration |
| 5–9 | Wave sentinel, local wave sentinel, first column, last column, single-wave logical flag |
| 10–13 | Vorticity, divergence, temperature and surface-pressure descriptors |
| 14–16 | Vorticity, divergence and temperature tendency descriptors |
| 17 | Auxiliary descriptor |

The two wave sentinels, vorticity values and tendency values are unconsumed. Scalar arguments have 4-byte alignment; real-valued owners and metadata have 8-byte alignment. An owner is the complete allocation behind an address or array view. Preserve aliases between read-only objects, including a last-column argument or vertical records embedded inside geometry.

| Original record | Required capacity, bytes |
| --- | ---: |
| Geometry | 17,096 |
| Diagnostics | 120 |
| Integration | 175,976 |
| Dynamics | 4,720 |
| Nonhydrostatic configuration | 456 |

## Parent record

Field locations in the record tables are byte offsets from the start of the named record. A pair `address/capacity` stores an owner's starting address and byte capacity. The specific parent record has 1,280 bytes.

| Parent-record byte offsets | Contents |
| --- | --- |
| 0–136, in 8-byte steps | Capacities of the 18 original arguments |
| 144 | Argument-vector capacity, in bytes |
| 152, 160, 168 | Pointers to NPRTRN, NPRTRV and MYSETV |
| 176/184 | Complete NVALUE owner address/capacity |
| 192/200 | Complete NPTRSV owner address/capacity |
| 208/216 | Complete RLAPDI owner address/capacity |
| 224/232 | Complete SIMI owner address/capacity |
| 240/248 | Complete SIMO owner address/capacity |
| 256–511 | 256-byte SIGAM template |
| 512–767 | 256-byte SITNU template |
| 768–1023 | 256-byte SPCIMPFSOLVE template |
| 1024/1032 | Optional original five-stage counter owner address/capacity |
| 1040/1048, 1056/1064 | Complete D and T owner address/capacity pairs |
| 1072/1080, 1088/1096 | Complete q and auxiliary owner address/capacity pairs |
| 1104–1279 | Reserved zero bytes |

The counter is absent when both address and capacity are zero (0/0), or it has an 8-byte-aligned, mutable 40-byte owner. On success, increment each original private stage count once using wrapping unsigned 64-bit arithmetic. The production host can own this counter storage and expose the original getter.

An existing context error returns before any argument-vector access. Refusal codes 11520–11525 distinguish launch, record, selected shape, range, descriptor/table and child-admission failures. Refusal precedes every numerical, global-scratch and counter store, and publishes no numerical flags.

## Supported shape and ownership

Each field offset is relative to its named object, rather than part of the field identifier. For example, NFLEVG is read at geometry byte 5224.

| Object | Field or selection | Byte offset | Required value |
| --- | --- | ---: | --- |
| Geometry | NFLEVG, NFLEVL, NFLSUR | 5224, 5228, 5236 | Each is 19 |
| Geometry | NSMAX | 5172 | 21 |
| Geometry | NUMP | 5212 | 22 |
| Geometry | NSPEC2 | 5200 | 506 |
| Geometry | Complete-copy extents | 7212, 7216 | Both are 506 |
| Geometry | NPROMA | 5144 | Positive |
| Geometry | Raw RSTRET | 7512 | 1 |
| Geometry | CVER pointer | 3264 | Complete 216-byte record |
| Diagnostics | Diagnostic selection | 108 | False |
| Dynamics | Stretching selection | 2476 | False |
| Dynamics | Coupled selection | 4444 | True |
| Nonhydrostatic configuration | Both source selections | 8, 40 | False |
| CVER | FE | 52 | True |
| CVER | IBC | 36 | 3 |

Require first column 1, last column 506, a false single-wave flag, and actual NPRTRN and NPRTRV values both equal to 1.

Consumed rank-two descriptors use the canonical GNU real8 layout, where real8 is the 8-byte floating-point type. Field row bounds are 1–19 and column bounds are 1–506; strides are 1 and 19 elements, the descriptor index offset is −20 elements, the type word is `0x0000030200000000` and span is 8 bytes. SIMI at dynamics byte 3224 and SIMO at byte 3136 use the same schema with 19 columns. Surface pressure uses a canonical real8 rank-one descriptor with bounds 1–506, stride 1 and index offset −1 element. Validate every complete owner and its selected view before stores.

The complete D, T and q owners and scratch are separate from each other and from every consumed read-only owner, descriptor, configuration, constant, integer table, vector, context and routine record. The optional counter is separate from all these owners. Inactive original arrays and descriptor bytes remain unchanged. Check the complete indirect VETA (320 bytes), VFE (2,176 bytes), CVER (216 bytes) and every used source coefficient allocation against all parent mutable owners.

SIGAM and SITNU templates retain the original RD and RKAPPA pointers and all coefficient capacities; only their original views and argument capacities are replaced. The solve template retains actual ROMEGA, NPRTRN and NPRTRV pointers and complete MYMS, NASM0, MYLEVS, RLAPDI and SIVP capacities. Its partition pointers equal parent-record fields 152 and 160. Validate all three prospective child records in local metadata before any global write. These integer-only admission copies reuse the original directly emitted PTX, with no numerical body or global store.

Use the original NPTRSV descriptor at geometry byte 5576 and actual MYSETV to select the one-based starting NVALUE position. Both integer descriptors are GNU allocations with 4-byte elements, unit stride, and signed 32-bit index offsets and bounds. Resolve `NPTRSV[MYSETV]` through `base+4*(offset+MYSETV)`, then the first of 506 NVALUE entries through `base+4*(offset+start)`. Every selected degree is in 0–21 before output writes. RLAPDI at geometry byte 4104 is the original real-valued, unit-stride allocation with bounds containing 0–21; resolve logical degree 0 through its signed descriptor offset. All selected addresses lie in their complete immutable owners. The implicit solve's integer-table and permutation proof remains in its child admission and retained physical gate.

## Ordered arithmetic

FP64 means the 64-bit floating-point format. RN denotes one FP64 operation rounded to nearest with ties to even, with gradual underflow (retaining very small representable values) and preserved signed zeros. All consumed real values and intermediate results are finite. The accepted child limits on numerical conditioning, or sensitivity to small input changes, remain unchanged. Forbid fused multiply-add (FMA), contraction, reassociation, reduced precision and approximate model arithmetic.

First form `b=RN(dynamics.RBTS2_2496*integration.TDT208)`. Here the integration value is at byte 208, and b is a time weight in seconds. Complete SIGAM with KLEV=1, KLON=19, KNLON=506 and N=19, using original T and q to form gamma. Visit columns, then levels, in this order:

~~~text
weight=RN(b*RLAPDI[degree])
rhs=RN(RN(D-RN(weight*gamma))+auxiliary)
~~~

For matrix stage one, start every output at positive zero and visit c=0–18 in increasing order:

~~~text
sum=RN(sum+RN(SIMI[row+19*c]*rhs[c+19*column]))
~~~

Complete SPCIMPFSOLVE using two canonical private descriptors, including both complete copies, rotation coefficients and SIMPLICO. Compute matrix stage two in the same order with SIMO and the solved modes, writing original D. Retain every zero endpoint and independent output.

Next prepare all velocity values with `RN(RN(D*RSTRET)*RSTRET)`, retaining both source operations even though RSTRET=1. Complete SITNU with the same level and column strides into private tau and nu. Finally visit columns, then levels, setting `T=RN(T-RN(b*tau))`; after each column, set `q=RN(q-RN(b*nu))`. Complete each child field before its consumer begins. The parent owns every original arithmetic stage; the driver supplies none.

## Scratch and numerical status

Scratch has 558,672 bytes: 4,096 metadata bytes, five complete 76,912-byte fields (gamma, modes, solved, velocity and tau), a 4,048-byte nu field, and one reusable 165,968-byte child workspace. The metadata contains the following source-defined regions before the numerical fields.

| Scratch byte range | Contents |
| --- | --- |
| 0–71 | Child argument vector |
| 96–159 | Child context |
| 160–415 | Child record |
| 448–463 | Integer controls |
| 512–599, 608–695 | Two 88-byte solve descriptors |

Use private local prospective metadata for all child admission. SIGAM and SITNU finite-element workspace each require 165,968 bytes. The complete solve needs 161,584 bytes and reuses this allocation only after a complete child return. Preserve these source-defined scratch phases; host code supplies no numerical results.

Every child and dense dot product uses the qualified 16-byte result/status interface and fresh call parameters. On success, combine all raised software flags with integer OR into context byte 8. Preserve the incoming errno event, the mathematical-library error indicator, because these stages have no mathematical errno writer. No equivalence to the Arm floating-point status register (FPSR), or performance result, is claimed.

## Component evidence and remaining qualification

Retain the original arithmetic revision 2 whole-owner packet: 77,924 exact ordered values, 52,965 independent relations evaluated with 100-digit arithmetic, eight intermediate fields, source stage counts, ABI/status and 523,496 complete owner bytes. Reuse the original selected and refusal cases, metadata/owner/child controls, and an ordinary-device graph. Assembly and source review alone give no numerical acceptance or actual forecast credit.

The implementation revision reuses the retained independent physical and component qualification for the unchanged arithmetic. Native instruction review confirms that all three admission paths consume their returned code before joining. One captured production call through the corrected module agrees with its accepted CPU reference across all 46 complete storage owners and 523,500 bytes, with zero differing bytes, exact immediate numerical status and error indicator, and each of the five original stage counters increasing once. Complete-forecast qualification remains pending.
