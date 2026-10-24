# Runtime Retained Transport Storage

CALL_SL_HEAP2 keeps three private arrays between transport calls, so the next call can reuse their storage. The [trajectory](../../../../../formulations/openifs/dynamics/trajectory_interpolation_weights.md) and [prognostic field](../../../../../formulations/openifs/dynamics/prognostic_departure_update.md) formulations describe the physics. This parent performs no floating-point arithmetic. It forwards the complete calculation to the accepted [runtime CALL_SL](runtime_semi_lagrangian_transport.md) entry.

The source is [runtime_retained_transport_storage.S](../../../../../src/openifs/transport/runtime_retained_transport_storage.S), with one [shared body](../../../../../src/openifs/transport/semi_lagrangian_work_storage_body.S). The existing [coarse entry](../../../../../src/openifs/transport/semi_lagrangian_work_storage.S) expands to its unchanged complete object. It retains its earlier bounds and receives no new numerical claim here.

## Interface and lifetime

`md2asm_runtime_transport_work_storage` keeps all 20 original addresses, from YDGEOMETRY through PGFLP9, in their original order. Argument 21 is the address of an eight-byte aligned, read-only 32-byte context. The application binary interface, or ABI, defines these arguments and the registers that each call must preserve.

| Context byte | Content |
| --- | --- |
| 0 | Address of the writable, eight-byte aligned 128-byte owner record. |
| 8 | Address of the accepted CALL_SL context64. |
| 16 | Address of a false four-byte hook flag, aligned to eight bytes. |
| 24 | Zero reserved word. |

The caller starts with an all-zero owner record, keeps its address valid and gives it exclusive use through the final dependent call. Only these assembly entries may modify it. The busy word detects an already active record; the caller still supplies exclusive use. The three private payloads belong to this record and must not be exposed as ordinary caller buffers. Call `md2asm_runtime_release_transport_work_storage(record)` after the final successful call. Release validates all recorded owners before freeing any of them, then returns all 128 record bytes to zero. Releasing an empty record is safe. The release entry takes its sole argument in x0.

| Record byte | Unsigned 64-bit content |
| --- | --- |
| 0, 8 | Tag 0x4850 and active-call flag. |
| 16, 24, 32 | Columns per block P, levels L and blocks B. |
| 40, 48, 56 | Complete ILH0, ZRSCAW and ZSCO addresses. |
| 64, 72, 80 | Their complete byte capacities. |
| 88, 96, 104 | Completed calls, allocations and frees. |
| 112, 120 | Zero reserved words. |

The 1536-byte stack frame stays aligned to 16 bytes. Its 128 outgoing argument bytes end before the saved registers at stack byte 256. Preserve x18 through x29, the return address and the low halves of v8 through v15; this parent does not change any SIMD register. Argument 21 arrives at incoming stack byte 96. The child receives the original 20 addresses unchanged, followed by the three retained raw addresses at outgoing stack bytes 96, 104 and 112, then context64 at byte 120. The selected hook flag must be false. The accepted child still uses the public FIAT statistics interface with valid caller-owned library configuration.

## Live dimensions and storage

Read P at Geometry byte 5144, L at byte 5224 and B at byte 5160. Read the interpolation-family counts R and S at MODEL bytes 1570780 and 1570944. Admit P from 1 through 1024, L from 5 through 256, positive signed 32-bit B, R from 1 through 256 and S from 1 through 64. The accepted child retains its full point-count, block, field, finite-difference and policy checks. This parent admits process counts one and four. The separate numerical scopes are stated below.

ILH0 contains four-byte integers with four planes, so its complete capacity is 16PLB bytes. ZRSCAW and ZSCO contain eight-byte floating-point values with R and S planes, so their capacities are 8PLRB and 8PLSB bytes. Every product and address span stays in 64-bit integer arithmetic, and each private owner is limited to 64 GiB. All complete ranges must be nonwrapping and disjoint from the owner record, new context and hook, ordinary returned owners, complete supplied PB1, fixed input records and the complete PGFL input. The record also keeps bounded, consistent allocation counters. The caller supplies every borrowed record and array over its declared complete bounds.

The first call allocates ILH0, ZRSCAW and ZSCO in that source order. It imposes no initial values on their private payloads, as in the original source. The complete CALL_SL child defines the values that it consumes. Matching P, L, B, R and S reuse all three addresses. A change frees ZSCO, ZRSCAW and ILH0 in the original source order, then allocates all three again. If a new allocation fails, free every newly acquired owner, clear the record and refuse. A fatal refusal inside the child keeps that child's accepted behavior; this entry does not provide general recovery from an aborted numerical child.

PGFLP9 remains the caller's raw address. Its actual owner uses live NDIMSLP, even though the old HEAP2 dummy declaration spells NUMFLDS. The child uses its accepted live owner pitch, and one new case gives those two counts different values. No setup run or main Fortran recompilation supplies this storage route.

## Checks and limits

Five new original-source and direct calls compare 238,267,872 complete public output and immediate status bytes with zero differences. Cases cover P8/L5/B1, P17/L137/B2 with two final active columns, and P8/L5/B3 with three final active columns and unequal NUMFLDS/NDIMSLP. They include unchanged-shape reuse, changed P/L/B and changed R/S counts. Both routes pass 134,901 independent scalar, pressure-integral, vector-norm, positivity and inactive-byte relations. The original reference changes the probe's x18 canary and returns mask 2 under this project's x18-preservation check; its other checked preserved registers pass. This source register limitation is separate from exact numerical agreement. Native and release ABI masks are zero. Raw FPCR, FPSR and errno agree, including both incoming status seeds. Two normal release calls pass ABI and status checks, and every verification owner is explicitly released.

The final source adds only integer admission guards. Removing exactly those insertions recovers the complete numerically checked source. The passed inputs already satisfy the stronger level, membership, counter and complete-span conditions. Two new native cases at P3/L5/B2 and P2/L6/B1 check 27,552 private payload bytes with protected pages and canaries, and pass another 626 independent relations. These two cases provide extra bounds evidence; the complete source/native byte total above covers the five paired calls. Unused, uninitialised private cells are not public output.

There are 42 new refusal cases, with 1,230,351,128 complete shared bytes preserved. They cover context and record bounds, aliases, invalid states and counters, each of the first three allocation failures, each allocation failure after releasing an old shape, and release preflight. First-allocation and resize failures leave zero live private owners. Complete retained buffers are checked before free. Earlier numerical and source banks remain frozen.

Each source/native process has a 120-second deadline and a 4 GiB resident-memory limit. All accepted processes finish, and no comparative timing is claimed. The five paired calls above qualify the serial finite-difference route with constructed NAS4096 inputs. The original main executable and accepted child providers stay unchanged.

A later retained-owner gate composes the accepted four-process CALL_SL route at P8/L5/B2 with two final active columns. It uses all five actual communication maps per rank and complete NAS widths 1744925 on ranks one and four and 1783837 on ranks two and three. NAS is the source-point count in each complete field plane. The fixture has 168 constructed constant physical planes and one unused exchange-signature plane. Interpolation geometry remains a constructed ten-row subset inside the first 4096 source points. This checks retained ownership around the actual-width communication join; it does not establish a loaded-weather geometry or field join.

Each rank makes three original and three native calls, for 12 calls per route. Fresh allocation, same-shape reuse and changed R/S capacities compare all 28625637312 ordinary public-output, complete PB1, diagnostic and raw-status bytes with zero differences. Each route passes 14064 independent parent physical relations, 21123420 exchange-signature relations and 3556992096 constant-plane preservation relations. Before release, each native record shows three completed calls, six allocations and three frees. The second call retains all three addresses. The final release frees the remaining owners and returns all 128 state bytes to zero on every rank, with ABI mask zero and preserved status. Native child counts per rank are three exchanges, three polar fills, six trajectory calls and six provisional-field calls. Native ABI masks are zero; the original source retains mask two. FPCR zero, FPSR 24 and errno 777 agree. All normal verification owners are released and MPI is finalized.

The new shared-source revision changes only the final integer membership test to permit four processes. Removing its added branch, comparison and label recovers the complete accepted runtime source and object. The complete legacy object is unchanged. Actual parent call-table resolution reaches the unchanged accepted CALL_SL DSO. Existing serial bounds, pointer-span, allocation-rollback and child-science evidence is retained without a replay. Each new phase has a 300-second process-group deadline and a 64 GiB address-space limit per rank on four owned exclusive nodes. No comparative timing is claimed.

Two new fatal-policy cases reject process count two on one rank and fail its second retained allocation. The initiating ranks preserve all 2436292900 and 2436292904 caller-owner bytes, including an all-zero state record. The allocation case records two attempts, one acquisition, one release and zero live retained owners. Slurm terminates each complete step in 29.41 and 1.60 seconds. Final peer bytes and normal peer cleanup are not observed after fatal termination; this policy promises no recoverable collective return. Complete 3337-field operational composition, 137-level distributed composition, finite-element and actual loaded-weather joins, and the complete autonomous forecast remain separate gates.
