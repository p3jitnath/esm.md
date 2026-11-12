# Runtime Complete Physics Driver Contract

This runtime driver implements the OpenIFS `EC_PHYS_DRV` interface in direct assembly. The original OpenIFS 48.1.1 source is `arpifs/phys_ec/ec_phys_drv.F90`, called by `arpifs/control/gp_model.F90`. Its assembly entry is `md2asm_run_runtime_complete_physics_driver`. The [column and block physics contract](column_physical_rates.md) keeps the earlier fixed-grid route and its acceptance unchanged. The runtime entry has passed the owner-address interface check described below. Its complete numerical calculation remains unverified.

## Original Arguments And Native Interface

The application binary interface, or ABI, defines argument positions, registers and stack storage. Preserve these 53 ordinary arguments in their original order, including the declared record, array and optional-argument types.

```text
YDGEOMETRY, YDFIELDS, YDVARS, YDGMV, YDSURF, YDMODEL, CDCONF,
PB2, PPBUP9, PPBVP9, PPBTP9, PPBGFLP9, PEXTRADYN, PSD_PF,
PGMV, PGMVS, PGMVT1, PGMVT1S, PGFLT1, PGFLPT, PGFL, PGFLSLP,
PSP_SB, PSP_SG, PSP_SL, PSP_RR, PSP_EP, PSP_X2,
PSD_VF, PSD_VN, PSD_VD, PSD_WS, PSD_WW, PSD_XA, PSD_X2, PSD_SM,
PSP_OM, PSD_V2, PSD_V3, YDTILEPROP, YDPHYSMWAVE,
PSMOS_OBS_BUF, PSMOS_TB_BUF, PSMOS_ANGLE, PSMOS_FARAD, PSMOS_GEOMET,
KSMOS_BUF, PSMAP_OBS_BUF, PSMAP_TB_BUF, PSMAP_ANGLE, KSMAP_BUF,
PTRAJEC, PTRAJEC_OOPS
```

Number arguments from zero. The first eight addresses use x0 through x7. Arguments 8 through 52 occupy consecutive eight-byte incoming stack slots, starting at offset zero. The GNU hidden character length is the value one at stack offset 360. The native interface appends an address of a 64-byte dependency record at offset 368, giving 55 arguments in total. That record supplies the live registry, setup bridge and storage budgets. Its last four eight-byte words must be zero. `CDCONF` addresses one character. Record and numerical-array addresses must be nonnull and eight-byte aligned where the selected path consumes them. Optional arrays retain their original presence and active-extent rules.

## Records And Runtime Bounds

The source type `TEC_PHYS_FIELDS` contains a 560-byte `YRTILEPROP` record followed by a 144-byte `YRPHYSMWAVE` record. In the declared `Fields` layout, their starts are offsets 25728 and 26288. Argument 39 is the standalone `TETILEPROP` record `YDTILEPROP`. Argument 40 is the standalone `TEPHYSMWAVE` record `YDPHYSMWAVE`, not the enclosing record. Its four-byte logical flag starts at offset zero, and its complete 136-byte rank-four `PHYS_MWAVE` array descriptor starts at offset eight. The descriptor gives the numerical storage address and the four array bounds and strides. The source allocation has shape `P, L, 9, B`, with columns first. Read the descriptor base at argument 40 plus eight before adding the selected block's byte stride.

Derive the allocated column count `P`, level count `L`, physical point count `Q` and block count `B` from live Geometry metadata. Entry admission requires `1 <= P <= 128`, `6 <= L <= 137`, positive `Q`, and `B = (Q-1)/P + 1` using integer division. Each array must retain its complete declared owner, source-selected field counts and final partial-block bounds. Fields and Model require their complete 529288-byte and 4275088-byte records. The field-variable record has 72696 bytes. The trajectory record has 512 bytes and retains the source `PHYS` descriptor for `B` records of 5528 bytes. Check every storage-size product, sum and available budget before allocation.

## Build Routes And Preserved State

Build [the assembly source](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/physics/runtime_complete_physics_driver.S) with `gcc -c -fPIC`. Without a definition, it selects the serial branch, which requires the reported maximum thread count to be one. Add `-DMD2ASM_RUNTIME_THREAD_PHYSICS_DRIVER` for the thread-aware branch. That branch accepts a reported maximum from one through six, requires entry outside a parallel region, and gives each worker its own 119328-byte metadata bundle. Both branches measure the microwave member from its standalone record. The caller's argument order and every numerical operation remain unchanged.

The parent frame has 8192 bytes with 16-byte alignment. The thread-aware worker adds a 128-byte saved-register header. Preserve x18, x19 through x29, the return address and the required low halves of v8 through v15. Require FPCR zero and retain the frozen FP64 rounding order, signed zeros and gradual underflow. Fused operations, reassociation and approximate arithmetic remain forbidden. The floating-point status register, FPSR, records arithmetic exceptions, while `errno` stores a library error value. Preserve their source-defined effects through the numerical route. Native return values are zero for success, one for allocation failure, two for entry refusal and three for a later child or cleanup failure.

## Accepted Check And Remaining Limits

The correction changes two integer instructions in each compiled branch: the argument-40 owner check uses Fields plus 26288, and the member load uses offset eight. Fresh base builds and complete inverse builds match their retained objects exactly. All other object bytes, including floating-point instructions, calls, constants and relocations, are unchanged.

One bounded seven-call interface check used the exact production guard and member-load instructions. The correct owner passed, three wrong owner addresses refused, and three nonzero-stride block selections returned the expected addresses. A standalone 144-byte record ended at an inaccessible memory page, which checks the upper read bound. All 4250368 readonly bytes, raw floating-point state, errno and preserved registers passed. This check does not call the complete driver or its numerical parent. Full parent numerical agreement, independent physics, returned state and complete forecast output acceptance remain pending.

Each worker stores its four-byte integer error status at byte offset 119280 in its 119328-byte record. For worker index `i`, the address is `base + i * 119328 + 119280`, with `0 <= i < thread_count`. Keep the computed record base live while forming this address. Clear only these status words before launch, then combine the returned statuses in worker order. A guarded-memory component check passes for one, two and six workers, including unchanged surrounding bytes. Complete parent and forecast numerical acceptance remain pending.
