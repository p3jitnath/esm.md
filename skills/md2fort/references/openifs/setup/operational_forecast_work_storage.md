# Operational Forecast Work Storage

This boundary owns six arrays needed by the selected fresh forecast. It borrows the final, stable Geometry, MODEL and FIELDS records. It does not load or change the physical initial state. The earlier accepted record constructors remain responsible for the outer MODEL and FIELDS allocations.

The operational shape is 17 points per block, 137 vertical levels and 388,217 blocks. There are 6,599,680 physical points and 6,599,689 stored point positions. The last block contains eight physical points and nine padding positions. Each stored three-dimensional scalar has 7,233,259,144 bytes. Padding belongs to the declared array extents; this boundary does not trim the final block.

## Source order and values

SUDYN calls SUALDYNB before SUSAVTEND. SUALDYNB allocates RSAVEDP(17,137,3,388217) without assigning its values. SUSAVTEND allocates RSLWX(137) and sets NVTEND=3 and its three positions to 1,2,3. SUDYN then writes each RSLWX value as binary64 0.5. SUSC2B then allocates SAVTEND(17,137,3,388217) and assigns positive zero to the whole array. The create entry allocates RSAVEDP at the SUALDYNB point. The first advance allocates RSLWX and writes 0.5 at the SUSAVTEND and following SUDYN assignment point. The second advance allocates SAVTEND at the later SUSC2B point. The enclosing startup must retain the intervening source calculations, including NFLEVSF and the setup calls between SUDYN and SUSC2B. These stages precede initial-condition loading.

After loading, the first GP_MODEL call allocates missing GMVT1(17,137,YT1.NDIM,388217), GMVT1S(17,YT1.NDIMS,388217) and GFLT1(17,137,YGFL.NDIM1,388217), in that order, and assigns positive zero only to newly allocated logical elements. The third advance reads the three live counts from the already produced MODEL and FIELDS maps. No count comes from a captured record. Their admission limit is 64; the selected live producers must separately qualify the operational counts.

The create entry requires all six descriptor bases to be zero. Each advance requires all not-yet-acquired bases to remain zero. A private owner records the acquired bases. Release checks these exact bases before freeing anything, releases next-time storage before dynamic storage, and leaves the borrowed records allocated. The namespace and loaded-state owners outlive this storage owner.

## Interface and failures

`int md2asm_create_operational_forecast_work_storage(Geometry17096, MODEL4275088, FIELDS529288, output_pointer8)` takes four eight-byte-aligned, complete, pairwise disjoint spans; the output word must initially be zero and must be disjoint from each record. It publishes one opaque owner after RSAVEDP exists. A failed create frees every acquired allocation, restores all changed MODEL bytes, and leaves the output word zero.

`int md2asm_advance_operational_forecast_work_storage(owner)` validates the pinned records and shape and performs the next declared storage stage. The first two advances allocate RSLWX and SAVTEND respectively. The third advance derives the four-integer next-time shape from live records and creates the three next-time arrays. Failure leaves the owner in its earlier phase and frees only arrays acquired by this call. An advance after all three stages is refused.

`int md2asm_release_operational_forecast_work_storage(owner)` accepts null as an empty release. A valid release frees only the exact arrays recorded by the owner and then frees the owner. The caller must not reuse the released address. Status 0 means success, 1 means allocation failure, and 2 means a refused argument, shape, state or floating-point mode.

The accompanying `md2asm_prepare_operational_fresh_forecast(table64)` retains the accepted four address/capacity pairs for MODEL, clock, forecast configuration and SUIOS records. It extends only the accepted fresh-continuation stop-count admission from 1 through 25 to any positive signed 32-bit value. All path checks, five tiny forcing allocations, source assignments and rollback remain unchanged. Pair it with `md2asm_release_selected_fresh_forecast()`. These five 16-byte arrays add 80 bytes. Their complete source boundary and record offsets remain defined in [fresh forecast continuation](fresh_forecast_continuation.md).

The Arm application binary interface (ABI) defines argument and register rules. FPCR controls rounding, FPSR records arithmetic exception flags, and errno stores C library errors. Entries preserve registers x18 through x29, the stack pointer, FPCR and FPSR. The stack remains aligned to 16 bytes. Create and advance require FPCR to be zero. The integer fresh-continuation entry preserves the incoming floating-point mode without using it. The dynamic child uses only exact integer address calculations and literal binary64 0.5; the next-time child stores positive zero. No fused arithmetic or changed physical equation is introduced.

## Allocation bound

The two dynamic rank-four owners each contain 21,699,777,432 bytes. RSLWX contains 1,096 bytes. Their sum is 43,399,555,960 bytes. With source-produced map counts 3,1,7, the three next-time owners contain 21,699,777,432, 52,797,512 and 50,632,814,008 bytes, for a combined six-array payload of 115,784,944,912 bytes. The opaque owner contains 128 bytes. A matched complete source/native check needs at most twice this payload, plus small records, guards and checker workspace. It must run with memory spread across CPU NUMA nodes 0 through 3 under the job's 482,344,960,000-byte cgroup limit. The independent terrain process is separately limited to 24 GiB.

The four GP_MODEL_HEAP2 owners are not part of this six-array allocation claim. Their exact live sizes are 14,466,518,288 bytes for IL0, 7,233,259,144 times YYTLSCAW.NDIM for ZLSCAW, 8 times NASLB1 times NFLDSLB1 for ZSLBUF1, and 52,797,512 times NFLDSLB2 for ZSLBUF2. The original producers of those counts remain required. The 233 physics work fields are tile views and are not 233 global allocations.

This storage check does not qualify the complete operational time loop or its weather calculations. The original OpenIFS program remains verification only.

The complete operational storage check compared 115,784,944,912 payload bytes with zero differing bytes and compared 24,021,880 complete MODEL/FIELDS bytes across five source points. It checked all 157,896 final-block padding bytes, including 29,592 source-unwritten RSAVEDP bytes and 128,304 zero bytes. All 25 ABI/status calls had zero ABI error masks. Refusal, all new allocation-failure positions, rollback, exact recorded bases, 544 heap-guard bytes and complete release passed. The native/source child ended normally after 68.098 seconds with empty standard error. Its observed resident-memory peak was 231,589,085,184 bytes; the whole job peak was 237,798,490,112 bytes, with no OOM event. These are qualification measurements, not comparative forecast timings.

The operational fresh-continuation check copied NSTOP 576 through the genuine source SU2YOM/SU3YOM/RERESF_PART1 route and matched 4,327,944 record and payload bytes. All three nonpositive signed stop-count cases were refused before mutation. Existing source checks for path errors, five allocation failures, protected bounds and release remain reused because only stop-count admission changed. The source process emitted the inherited public BLAS-library warning; no numerical disagreement occurred.

The accepted live configuration produces next-time counts 3,1,7. The six-owner check uses those same counts, and a separate small live-metadata check closes their producer binding. This boundary does not supply the main GMV owners, four GP work heaps or a missing weather calculation.
