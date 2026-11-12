# Surface Coupling Diagnostic Storage

This assembly component implements allocation and initialization in the original OpenIFS `SUALGCO` routine. It creates storage for surface diagnostics that later coupling routines can use. `SU0YOMB` calls this stage when the coupled-field frequency `NFRCO` is nonzero, including when external ocean coupling is inactive. These `YOMGCO` fields are separate from the `YOMCPL` fields created by `SUCPL0`. The [assembly source](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/setup/runtime_surface_coupling_diagnostics_storage.S) uses owned memory and public allocation services, with no original OpenIFS callable or module storage.

An owner retains the allocation address, dimensions and array descriptions until the last consumer finishes. This component creates all 23 source arrays and their exact initial values. It performs no physical flux update or unit conversion. The later [CUMCOE update](../physics/coupled_surface_flux_accumulation.md) defines the stress, heat and water units of its eleven accumulated fields. The initial `TMAX2` and `TMIN2` temperature bounds are in kelvin; these are initialization bounds, not predicted temperatures. Future updates of the remaining fields require their own physical and numerical contracts.

## Initialization Interface

The entry is `md2asm_initialize_runtime_surface_coupling_diagnostics`. Its application binary interface, or ABI, passes four arguments in Arm registers.

| Register | Complete mapped span | Meaning |
| --- | ---: | --- |
| x0 | 20400 bytes | Readable Geometry grid record, aligned to 8 bytes |
| x1 | 88 bytes | Readable TDPHY physical dimensions, aligned to 4 bytes |
| x2 | 2176 bytes | Writable fresh owner, aligned to 8 bytes |
| x3 | One unsigned 64-bit value | Available payload budget in bytes |

The three complete memory ranges must be separate and must not wrap around the address space. The caller establishes mapped storage; integer address checks alone do not prove that memory is mapped. Before entry, the owner's allocation address at byte 0 and ready word at byte 16 are zero. Other incoming owner bytes may have any value. The floating-point control register, FPCR, must be zero.

Let $`Q`$ be the local cell count in the signed 32-bit Geometry word at byte 7376. Let $`T=\mathrm{NTSSG}+1`$, where the signed 32-bit `NTSSG` word is at TDPHY byte 76. `NTSSG` counts surface temperatures for subgrid diagnostics. Both $`Q`$ and $`T`$ are dimensionless counts. Admit $`1\leq Q\leq2^{31}-1`$ and $`0\leq\mathrm{NTSSG}\leq32`$, so $`1\leq T\leq33`$. The positive budget is at most 64 GiB and must cover the payload size $`B`$, in bytes:

```math
B=8Q(19+6T).
```

Thus the budget also limits $`Q`$ at each $`T`$. These storage checks do not establish support for every Geometry producer or forecast resolution. The original Fortran entry receives the Geometry `TGEM` part; its `NGPTOT` word is the same live cell count. The assembly entry receives the complete Geometry record.

## Array Order And Initial Values

FP64 stores one floating-point value in eight bytes. The table follows the original allocation and initialization order. Every element receives positive FP64 zero except the two stated temperature bounds. Multidimensional arrays store the first dimension consecutively.

| Index | Source field | Shape | Initial value |
| ---: | --- | --- | --- |
| 0 | STRSU | $`Q`$ | Positive zero |
| 1 | STRSV | $`Q`$ | Positive zero |
| 2 | FCHAS | $`Q\times T`$ | Positive zero |
| 3 | FRSOS | $`Q\times T`$ | Positive zero |
| 4 | FHUMS | $`Q\times T`$ | Positive zero |
| 5 | RUIST | $`Q`$ | Positive zero |
| 6 | FCHLL | $`Q\times T`$ | Positive zero |
| 7 | FCHLN | $`Q\times T`$ | Positive zero |
| 8 | FCHSS | $`Q\times T`$ | Positive zero |
| 9 | FHUML | $`Q`$ | Positive zero |
| 10 | FHUMN | $`Q`$ | Positive zero |
| 11 | FRLDS | $`Q`$ | Positive zero |
| 12 | QWPRO | $`Q`$ | Positive zero |
| 13 | TMAX2 | $`Q`$ | -1000 K |
| 14 | TMIN2 | $`Q`$ | 1000 K |
| 15 | HSNOW | $`Q`$ | Positive zero |
| 16 | TSUR2 | $`Q`$ | Positive zero |
| 17 | TSTS | $`Q`$ | Positive zero |
| 18 | TSFL | $`Q`$ | Positive zero |
| 19 | XPUQ | $`Q`$ | Positive zero |
| 20 | XPVQ | $`Q`$ | Positive zero |
| 21 | FCRFTH | $`Q\times2`$ | Positive zero |
| 22 | FCRFSO | $`Q\times2`$ | Positive zero |

The initializer uses one allocation and retains the complete payload in source array order. Integer zero stores and exact temperature bit patterns introduce no floating-point rounding. All matrices except the last two have lower bounds one in both dimensions. `FCRFTH` and `FCRFSO` have first lower bound one and second bounds zero through one. These bounds remain part of the interface for later consumers.

## Owner And Descriptors

The owner has 2176 bytes. It stores the allocation address at byte 0, payload bytes at 8, ready value 1 at 16, $`Q`$ at 24 and $`T`$ at 32. These are unsigned 64-bit words after the input counts pass admission. The remaining header bytes are zero.

A descriptor records an array's address, element size, bounds and strides. Descriptor $`i`$ starts at owner byte $`128+88i`$, for $`i`$ from 0 to 22. Each slot has 88 bytes and starts with its first physical data address.

| Descriptor byte | Size | Meaning |
| ---: | ---: | --- |
| 0 | 8 bytes | First physical data address |
| 8 | 8 bytes | Signed GNU address offset |
| 16 | 8 bytes | Element size 8 |
| 24 | 4 bytes | Version 0 |
| 28 | 1 byte | Rank: 1 or 2 |
| 29 | 1 byte | Floating-point type code 3 |
| 30 | 2 bytes | Zero reserved bytes |
| 32 | 8 bytes | Element span 8 |
| 40 | 8 bytes | First stride 1 |
| 48 | 8 bytes | First lower bound 1 |
| 56 | 8 bytes | First upper bound $`Q`$ |
| 64 | 8 bytes | Second stride $`Q`$, for rank 2 |
| 72 | 8 bytes | Second lower bound, for rank 2 |
| 80 | 8 bytes | Second upper bound, for rank 2 |

Stride values count elements. The signed GNU offset is -1 for a vector or a matrix whose second lower bound is zero, and $`-1-Q`$ for a matrix whose lower bounds are both one. Unused descriptor words and owner padding are zero. Each data address and complete range belong to this owner; later readers preserve those relations.

## Return, Release And Preserved State

Initialization returns 0 only after all payload values and metadata are ready, then publishes the complete owner. Return 1 reports allocation failure, and return 2 refuses invalid dimensions, budget, alignment, range arithmetic or a nonfresh owner. Both failures preserve every caller-owner byte. The implementation uses a 2560-byte stack frame. Its private owner starts at byte 256 and ends before byte 2432.

The release entry is `md2asm_release_runtime_surface_coupling_diagnostics`. Registers x0 and x1 contain the genuine owner address and its available capacity. The owner is eight-byte aligned, its complete range is mapped and nonwrapping, and capacity is at least 2176 bytes. Return 0 follows release of a nonnull allocation and clearing of the allocation address, payload byte count, ready word and all 23 descriptor data addresses. Other metadata remains unchanged. Repeated release returns 0. Invalid alignment, capacity or address arithmetic returns 2 before a write or release. An arbitrary unproduced record is not a valid release input.

Both entries preserve x18, required saved integer and vector registers, FPCR and sixteen-byte stack alignment. Integer initialization stores add no floating-point status flags. Allocation and release use public libc services; their natural system-error value `errno` remains visible. A failed allocation can report `ENOMEM`. Release uses a 32-byte frame.

## Checks And Lifetime Limits

Two original/native setup comparisons use $`Q=17,T=3`$ and $`Q=286943,T=1`$. All 23 defined payloads agree in 57393632 bytes with zero differences, and 46 source/native descriptor relations pass. Independent checks require positive zero and exact -1000 K and 1000 K bit patterns. The checks retain protected caller edges, complete input and owner bytes, saved-register status and immediate floating-point and system-error observations. Nine native calls cover setup, release, repeated release, short-budget and invalid-NTSSG refusal, and a real allocation refusal under a 4 GiB address-space limit. A separate source/result peer checks original array order, shapes, initial values and saved descriptors without repeating numerical pairs.

Storage remains live across every CUMCOE update and through the final coupling or output reader. The original `SUGCO0` reset and `WRCOE` output have separate configuration conditions and lifetime requirements. This setup check does not accept their omission or an active-ocean route. Production caller insertion, immutable configuration, reset/output decisions, normal and error cleanup, and complete forecast output agreement remain separate acceptance requirements.
