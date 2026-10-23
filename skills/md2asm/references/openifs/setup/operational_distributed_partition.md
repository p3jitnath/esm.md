# Operational Distributed Partition

A partition assigns grid points and spectral waves to processes that run in parallel. This direct assembly creates the public transform context, complete original SUMP maps and owned metadata for four processes. Each process keeps its live Geometry record at its final address. Later horizontal geometry, the interpolation halo and complete model arrays remain separate stages.

## Input And Ownership

The application binary interface, or ABI, defines argument registers and saved state. `md2asm_create_owned_distributed_transform_partition(geometry, constants, text, text_bytes, expected_world, out_owner)` uses x0 through x5. The expected process count is four. Geometry is a writable 17,096-byte record, constants is a read-only 520-byte record and the writable eight-byte output slot starts null. These records align to eight bytes. Text has 1 through 262,144 readable bytes. All consumed spans are mapped, nonwrapping and disjoint.

Geometry supplies truncation 1279, 2,560 global latitude rows and the live reduced-grid row-length array `NLOENG`. Its transform handle starts zero. Constants supplies the Earth radius at byte offset 104. The original first `NAMPAR0` group is read with all thirteen admitted assignments, including `NPROC=4` and `NSPECRESMIN=1280`. Statistics controls remain source-derived. The actual MPI world count must match four. The selected `NAM_DISTRIBUTED_VECTORS` and `NAMTRANS0` groups remain empty.

The returned 4,096-byte owner borrows Geometry and its row array. It owns its control, public inquiry payload, source SUMP arrays and stream metadata. Keep every borrowed owner live until release. It uses a 2 by 2 process layout and retains the region dimensions returned by the public transform. Fresh control metadata is zero at allocation. Physical values and source-unwritten numerical storage are not normalized.

## Source Order And Maps

Assembly follows the source process factorization, public message initialization, group creation, transform setup and inquiry order. It then runs all SUMP allocation phases, preserves the 69/68 vertical split and reverse whole-column partition, constructs stream metadata, derives the one-thread block size and fills every complete local/global map. The temporary rectangular global index array has 52,592,640 bytes and is released before publication.

| Live Geometry Field | Byte Offset | Meaning |
| --- | ---: | --- |
| `NGLOBALINDEX` descriptor | 6648 | Local points as one-based packed global GRIB indices |
| `NGPTOT` | 7376 | Local physical point count |
| Transform handle | 5168 | Public resolution owned by this context |

Each process owns 1,649,920 of the 6,599,680 global physical points. Its local storage has 97,055 blocks of 17 columns, with two active columns in the last block. Packed physical indices differ from the rectangular index used by spherical geometry. Bind the live map when loading fields, then release its consumers before the partition owner.

The public inquiry payload requires $`4[7682+4N_S+5P+E_W(5118+3N_S)]`$ bytes. Here $`P=4`$ is the process count, and $`N_S`$ and $`E_W`$ are the actual north–south and east–west region counts. Each region count is 1 through 4, with a product at most 8. These bounds cover metadata only and do not establish complete forecast memory use.

## Status And Release

Every process follows the same collective call order. A public integer maximum reduction agrees on local parser and allocation results before the next collective stage. Return 0 publishes the complete owner, 1 reports allocation failure, 2 refuses unsupported input and 3 reports an unexpected external result. Recoverable failure releases acquired storage. An unrecoverable external failure uses the public coordinated abort, so one process cannot return while another enters a collective call.

`md2asm_release_owned_distributed_transform_partition(owner)` receives the owner in x0. Every process calls release in the same order. It releases the 34 partition arrays, both stream arrays, inquiry payload and outer owner, ends the public transform and message context, and clears the transform handle and owned partition pointers in Geometry. Scalars and released descriptor metadata retain their declared state. A null release succeeds only when all processes follow that path. This MPI lifecycle runs once and cannot be initialized again after finalization.

The create and release frames have 256 and 64 bytes. Internal allocation, stream and block-size helpers are called only through this ordered owner lifecycle. Every entry preserves x18, x19 through x29, d8 through d15, the return address and 16-byte stack alignment. FPCR must be zero. No new floating-point arithmetic is introduced. Public-library FPSR flags and `errno` remain natural. Public MPI, FIAT, ectrans, C and required language runtimes remain allowed. No original OpenIFS routine, global object or harness supplies a production stage.

## Acceptance And Limits

The whole distributed source and native comparisons cover 317,409,688 complete owner, Geometry and stream bytes across four owned exclusive nodes, with zero differences. Each process passes 13,199,390 independent map relations, complete release, guards, padding and ABI checks. All 39 acquired owners are released. Three further collective calls cover process-count refusal and allocation failure on one process at the first and last owned allocation stages. All sixteen process calls pass.

A matched source-status check establishes incoming and returned FPCR 0, FPSR 24 and `errno` 0. An earlier source fixture's file handling had changed incoming `errno` on three processes. The completed payload comparison was retained, and only the missing matched status was checked again. Returned status and numerical bytes were never repaired. A separate original typed read confirms all thirteen process-control words. Focused independent review passes without replaying the numerical comparisons.

This boundary does not yet accept distributed horizontal geometry, the SLCSET communication halo, complete model storage or a forecast. Exact source, interface, dependency, input and comparison records remain locally under `.runtime/`. Exported map files are verification inputs. Production borrows the live map owner.
