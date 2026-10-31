#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
/* Direct runtime CALL_SL_HEAP2: explicit retained owners and exact CALL_SL child.
 * Contract skills/md2asm/references/openifs/transport/runtime_retained_transport_storage.md. */
#else
/* Source build for the qualified private forecast graph.
 * Contract: skills/md2asm/references/openifs/dynamics/private_forecast_graph_sources.md.
 * Preserve the original interface, ordered arithmetic, and caller-owned storage. */
/* Direct retained transport storage, complete selected CALL_SL_HEAP2.
 * Physics formulations/openifs/dynamics/trajectory_interpolation_weights.md
 * and formulations/openifs/dynamics/prognostic_departure_update.md.
 * Contract skills/md2asm/references/openifs/transport/runtime_retained_transport_storage.md.
 * 20 ordinary data addresses, no numerical Fortran fallback. */
#endif
.arch armv8.2-a+simd
.text
.p2align 4
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
.global md2asm_runtime_transport_work_storage
.type md2asm_runtime_transport_work_storage,%function
md2asm_runtime_transport_work_storage:
#else
.global md2asm_call_sl_heap2_7358525
.global call_sl_heap2_
.set call_sl_heap2_,md2asm_call_sl_heap2_7358525
.type md2asm_call_sl_heap2_7358525,%function
md2asm_call_sl_heap2_7358525:
#endif
 mov x17,sp
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 sub sp,sp,#1536
 stp x18,x19,[sp,#256]
 stp x20,x21,[sp,#272]
 stp x22,x23,[sp,#288]
 stp x24,x25,[sp,#304]
 stp x26,x27,[sp,#320]
 stp x28,x29,[sp,#336]
 str x30,[sp,#352]
 add x29,sp,#32
 str x0,[x29,#352]
 str x1,[x29,#360]
 str x2,[x29,#368]
 str x3,[x29,#376]
 str x4,[x29,#384]
 str x5,[x29,#392]
 str x6,[x29,#400]
 str x7,[x29,#408]
#else
 sub sp,sp,#512
 stp x18,x19,[sp,#128]
 stp x20,x21,[sp,#144]
 stp x22,x23,[sp,#160]
 stp x24,x25,[sp,#176]
 stp x26,x27,[sp,#192]
 stp x28,x29,[sp,#208]
 str x30,[sp,#224]
 mov x29,sp
 str x0,[sp,#256]
 str x1,[sp,#264]
 str x2,[sp,#272]
 str x3,[sp,#280]
 str x4,[sp,#288]
 str x5,[sp,#296]
 str x6,[sp,#304]
 str x7,[sp,#312]
#endif
 ldr x9,[x17,#0]
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 str x9,[x29,#416]
#else
 str x9,[sp,#320]
#endif
 ldr x9,[x17,#8]
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 str x9,[x29,#424]
#else
 str x9,[sp,#328]
#endif
 ldr x9,[x17,#16]
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 str x9,[x29,#432]
#else
 str x9,[sp,#336]
#endif
 ldr x9,[x17,#24]
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 str x9,[x29,#440]
#else
 str x9,[sp,#344]
#endif
 ldr x9,[x17,#32]
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 str x9,[x29,#448]
#else
 str x9,[sp,#352]
#endif
 ldr x9,[x17,#40]
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 str x9,[x29,#456]
#else
 str x9,[sp,#360]
#endif
 ldr x9,[x17,#48]
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 str x9,[x29,#464]
#else
 str x9,[sp,#368]
#endif
 ldr x9,[x17,#56]
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 str x9,[x29,#472]
#else
 str x9,[sp,#376]
#endif
 ldr x9,[x17,#64]
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 str x9,[x29,#480]
#else
 str x9,[sp,#384]
#endif
 ldr x9,[x17,#72]
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 str x9,[x29,#488]
#else
 str x9,[sp,#392]
#endif
 ldr x9,[x17,#80]
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 str x9,[x29,#496]
#else
 str x9,[sp,#400]
#endif
 ldr x9,[x17,#88]
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 str x9,[x29,#504]
 ldr x20,[x17,#96]
 cbz x20,.Lreject
 tst x20,#7
 b.ne .Lreject
 adds x9,x20,#32
 b.cs .Lreject
 ldr x19,[x20]
 cbz x19,.Lreject
 tst x19,#7
 b.ne .Lreject
 adds x9,x19,#128
 b.cs .Lreject
 ldr x9,[x20,#24]
 cbnz x9,.Lreject
 ldr x21,[x20,#16]
 cbz x21,.Lreject
 tst x21,#7
 b.ne .Lreject
 adds x9,x21,#4
 b.cs .Lreject
 ldr w9,[x21]
 cbnz w9,.Lreject
 str xzr,[x29,#512]
 str xzr,[x29,#520]
 str xzr,[x29,#528]
#else
 str x9,[sp,#408]
#endif
 mrs x9,fpcr
 cbnz x9,.Lreject
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 ldr x9,[x29,#368]
 movz x16,#57144
 movk x16,#23,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#0
#else
 ldr x9,[x29,#256]
 ldr w10,[x9,#5144]
 cmp w10,#24
#endif
 b.ne .Lreject
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 ldr x9,[x29,#368]
 movz x16,#57148
 movk x16,#23,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#0
#else
 ldr w10,[x9,#5224]
 cmp w10,#19
#endif
 b.ne .Lreject
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 ldr x9,[x29,#368]
 movz x16,#59844
 movk x16,#23,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#0
#else
 ldr w10,[x9,#5160]
 cmp w10,#86
#endif
 b.ne .Lreject
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 ldr x9,[x29,#368]
 movz x16,#14760
 movk x16,#24,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 ldr x9,[x29,#368]
 movz x16,#5088
 movk x16,#24,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lreject
 ldr x9,[x29,#368]
 movz x16,#5284
 movk x16,#24,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lreject
 ldr x9,[x29,#368]
 movz x16,#5024
 movk x16,#24,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lreject
 ldr x9,[x29,#368]
 movz x16,#15004
 movk x16,#63,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 ldr x9,[x20,#8]
 str x9,[x29,#952]
 cbz x9,.Lreject
 tst x9,#7
 b.ne .Lreject
 adds x10,x9,#64
 b.cs .Lreject
 ldr x10,[x9,#0]
 cbz x10,.Lreject
 tst x10,#7
 b.ne .Lreject
 mov x11,#520
 adds x11,x10,x11
 b.cs .Lreject
 str x10,[x29,#960]
 ldr x10,[x9,#8]
 cbz x10,.Lreject
 tst x10,#7
 b.ne .Lreject
 mov x11,#360
 adds x11,x10,x11
 b.cs .Lreject
 str x10,[x29,#968]
 ldr x10,[x9,#16]
 cbz x10,.Lreject
 tst x10,#7
 b.ne .Lreject
 mov x11,#51512
 adds x11,x10,x11
 b.cs .Lreject
 str x10,[x29,#976]
 ldr x10,[x9,#24]
 cbz x10,.Lreject
 tst x10,#7
 b.ne .Lreject
 mov x11,#4096
 adds x11,x10,x11
 b.cs .Lreject
 str x10,[x29,#984]
 ldr x10,[x9,#32]
 cbz x10,.Lreject
 tst x10,#7
 b.ne .Lreject
 mov x11,#16
 adds x11,x10,x11
 b.cs .Lreject
 str x10,[x29,#992]
 ldr x10,[x9,#48]
 cmp x10,#1
 b.eq .Lruntime_nproc_ok
 cmp x10,#4
 b.ne .Lreject
.Lruntime_nproc_ok:
 ldr x10,[x9,#56]
 cbnz x10,.Lreject
 ldr x10,[x29,#976]
 movz x11,#35292
 movk x11,#0,lsl #16
 ldr w10,[x10,x11]
 cbnz w10,.Lreject
 ldr x10,[x29,#992]
 ldr x11,[x10]
 cbnz x11,.Lreject
 ldr x11,[x10,#8]
 cbnz x11,.Lreject
 ldr x9,[x29,#352]
 movz x16,#5144
 movk x16,#0,lsl #16
 add x9,x9,x16
 ldrsw x10,[x9]
 cmp x10,#1
 b.lt .Lreject
 movz x11,#1024
 movk x11,#0,lsl #16
 cmp x10,x11
 b.gt .Lreject
 str x10,[x29,#904]
 ldr x9,[x29,#352]
 movz x16,#5224
 movk x16,#0,lsl #16
 add x9,x9,x16
 ldrsw x10,[x9]
 cmp x10,#4
 b.lt .Lreject
 movz x11,#256
 movk x11,#0,lsl #16
 cmp x10,x11
 b.gt .Lreject
 str x10,[x29,#912]
 ldr x9,[x29,#352]
 movz x16,#5160
 movk x16,#0,lsl #16
 add x9,x9,x16
 ldrsw x10,[x9]
 cmp x10,#1
 b.lt .Lreject
 movz x11,#65535
 movk x11,#32767,lsl #16
 cmp x10,x11
 b.gt .Lreject
 str x10,[x29,#920]
 ldr x9,[x29,#352]
 movz x16,#7376
 movk x16,#0,lsl #16
 add x9,x9,x16
 ldrsw x10,[x9]
 cmp x10,#1
 b.lt .Lreject
 movz x11,#65535
 movk x11,#32767,lsl #16
 cmp x10,x11
 b.gt .Lreject
 str x10,[x29,#928]
 ldr x9,[x29,#352]
 movz x16,#7380
 movk x16,#0,lsl #16
 add x9,x9,x16
 ldrsw x10,[x9]
 ldr x11,[x29,#928]
 cmp x10,x11
 b.ne .Lreject
 ldr x12,[x29,#904]
 add x10,x10,x12
 sub x10,x10,#1
 udiv x10,x10,x12
 ldr x11,[x29,#920]
 cmp x10,x11
 b.ne .Lreject
 ldr x9,[x29,#352]
 movz x16,#5156
 movk x16,#0,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lreject
 ldr x10,[x29,#904]
 ldr x11,[x29,#912]
 mul x10,x10,x11
 lsl x10,x10,#3
 str x10,[x29,#1000]
 ldr x10,[x29,#904]
 lsl x10,x10,#3
 str x10,[x29,#1008]
 mov x10,#4
 str x10,[x29,#1128]
 ldr x9,[x29,#368]
 movz x16,#456
 movk x16,#24,lsl #16
 add x9,x9,x16
 ldrsw x10,[x9]
 cmp x10,#1
 b.lt .Lreject
 cmp x10,#16384
 b.gt .Lreject
 ldr x11,[x29,#1008]
 mul x10,x10,x11
 str x10,[x29,#1016]
 ldr x9,[x29,#368]
 movz x16,#240
 movk x16,#0,lsl #16
 add x9,x9,x16
 ldrsw x10,[x9]
 cmp x10,#1
 b.lt .Lreject
 cmp x10,#4096
 b.gt .Lreject
 str x10,[x29,#1152]
 ldr x11,[x29,#1000]
 mul x10,x10,x11
 str x10,[x29,#1024]
 ldr x9,[x29,#368]
 movz x16,#256
 movk x16,#0,lsl #16
 add x9,x9,x16
 ldrsw x10,[x9]
 cmp x10,#1
 b.lt .Lreject
 cmp x10,#4096
 b.gt .Lreject
 ldr x11,[x29,#1000]
 mul x10,x10,x11
 str x10,[x29,#1048]
 ldr x9,[x29,#368]
 movz x16,#276
 movk x16,#0,lsl #16
 add x9,x9,x16
 ldrsw x10,[x9]
 cmp x10,#0
 b.lt .Lreject
 cmp x10,#0
 b.gt .Lreject
 ldr x11,[x29,#1000]
 mul x10,x10,x11
 str x10,[x29,#1056]
 ldr x9,[x29,#368]
 movz x16,#63280
 movk x16,#23,lsl #16
 add x9,x9,x16
 ldrsw x10,[x9]
 cmp x10,#1
 b.lt .Lreject
 cmp x10,#256
 b.gt .Lreject
 ldr x11,[x29,#1000]
 mul x10,x10,x11
 str x10,[x29,#1072]
 ldr x9,[x29,#368]
#else
 ldr x9,[x29,#272]
#endif
 movz x16,#63452
 movk x16,#23,lsl #16
 add x9,x9,x16
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 ldrsw x10,[x9]
 cmp x10,#1
 b.lt .Lreject
 cmp x10,#256
 b.gt .Lreject
 ldr x11,[x29,#1000]
 mul x10,x10,x11
 str x10,[x29,#1080]
 ldr x9,[x29,#368]
#else
 ldr w10,[x9]
 cmp w10,#66
 b.ne .Lreject
 ldr x9,[x29,#272]
#endif
 movz x16,#63616
 movk x16,#23,lsl #16
 add x9,x9,x16
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 ldrsw x10,[x9]
 cmp x10,#1
 b.lt .Lreject
 cmp x10,#64
 b.gt .Lreject
 ldr x11,[x29,#1000]
 mul x10,x10,x11
 str x10,[x29,#1088]
 ldr x9,[x29,#368]
 movz x16,#63636
 movk x16,#23,lsl #16
 add x9,x9,x16
 ldrsw x10,[x9]
 cmp x10,#4
 b.lt .Lreject
 cmp x10,#4
 b.gt .Lreject
 ldr x11,[x29,#1000]
 mul x10,x10,x11
 str x10,[x29,#1104]
 ldr x9,[x29,#360]
 ldrsw x10,[x9,#1360]
 cmp x10,#1
 b.lt .Lreject
 cmp x10,#64
 b.gt .Lreject
 ldr x11,[x29,#1000]
 mul x10,x10,x11
 str x10,[x29,#1032]
 ldrsw x10,[x9,#1364]
 cmp x10,#1
 b.lt .Lreject
 cmp x10,#64
 b.gt .Lreject
 ldr x11,[x29,#1008]
 mul x10,x10,x11
 str x10,[x29,#1040]
 ldr x9,[x29,#368]
 ldrsw x10,[x9,#264]
 cmp x10,#0
 b.lt .Lreject
 cmp x10,#2163
 b.gt .Lreject
 ldr x11,[x29,#1000]
 mul x10,x10,x11
 str x10,[x29,#1096]
 ldr x10,[x29,#1000]
 lsl x10,x10,#1
 str x10,[x29,#1064]
 lsr x10,x10,#2
 str x10,[x29,#1144]
 ldr x10,[x29,#912]
 lsl x10,x10,#4
 str x10,[x29,#1112]
 ldr x9,[x29,#368]
 movz x16,#63308
 movk x16,#23,lsl #16
 add x9,x9,x16
 ldrsw x10,[x9]
 cmp x10,#1
 b.lt .Lreject
 cmp x10,#256
 b.gt .Lreject
 ldr x11,[x29,#912]
 mul x10,x10,x11
 lsl x10,x10,#3
 str x10,[x29,#1120]
 ldr x9,[x29,#368]
 movz x16,#63596
 movk x16,#23,lsl #16
 add x9,x9,x16
 ldrsw x10,[x9]
 cmp x10,#1
 b.lt .Lreject
 cmp x10,#256
 b.gt .Lreject
 ldr x11,[x29,#912]
 mul x10,x10,x11
 lsl x10,x10,#3
 str x10,[x29,#1136]
 ldr x9,[x29,#368]
 movz x16,#152
 movk x16,#24,lsl #16
 add x9,x9,x16
 ldrsw x10,[x9]
 cmp x10,#1
 b.lt .Lreject
 cmp x10,#16384
 b.gt .Lreject
 ldr x9,[x29,#384]
 ldrsw x11,[x9,#1016]
 cmp x11,#1
 b.lt .Lreject
 mul x10,x10,x11
 lsl x10,x10,#3
 str x10,[x29,#1160]
 ldr x9,[x29,#952]
 ldr x11,[x9,#40]
 str x11,[x29,#1168]
 cmp x11,x10
 b.lo .Lreject
 ldr x11,[x29,#408]
 cbz x11,.Lreject
 tst x11,#7
#else
 ldr w10,[x9]
 cmp w10,#4
#endif
 b.ne .Lreject
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 ldr x12,[x29,#1168]
 adds x11,x11,x12
 b.cs .Lreject
 ldr x9,[x29,#960]
 str x9,[x29,#1200]
 ldr x9,[x29,#968]
 str x9,[x29,#1208]
 ldr x9,[x29,#976]
 str x9,[x29,#1216]
 ldr x9,[x29,#960]
 str x9,[x29,#1224]
 ldr x9,[x29,#976]
 str x9,[x29,#1232]
 ldr x9,[x29,#1160]
 str x9,[x29,#1240]
 str xzr,[x29,#1248]
 str xzr,[x29,#880]
 ldr x0,[x29,#952]
 mov x1,#64
 bl .Lruntime_borrowed_span
 ldr x0,[x29,#960]
 mov x1,#520
 bl .Lruntime_borrowed_span
 ldr x0,[x29,#968]
 mov x1,#360
 bl .Lruntime_borrowed_span
 ldr x0,[x29,#976]
 mov x1,#51512
 bl .Lruntime_borrowed_span
 ldr x0,[x29,#984]
 mov x1,#4096
 bl .Lruntime_borrowed_span
 ldr x0,[x29,#992]
 mov x1,#16
 bl .Lruntime_borrowed_span
 ldr x9,[x29,#384]
 ldr w10,[x9,#1032]
 cbnz w10,.Lreject
 ldr x9,[x29,#384]
 ldr w10,[x9,#1036]
 cbnz w10,.Lreject
 ldr x9,[x29,#360]
 ldr x9,[x29,#368]
 movz x16,#58408
 movk x16,#23,lsl #16
 add x9,x9,x16
 ldr x10,[x9]
 cbz x10,.Lreject
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 ldr x12,[x9,#112]
 ldr x13,[x9,#120]
 cmp x13,#1
 b.ne .Lreject
 ldr x14,[x9,#128]
 ldr x15,[x29,#920]
 cmp x14,x15
 b.lt .Lreject
 add x11,x11,x12
 add x10,x10,x11,lsl #3
 str x10,[x29,#712]
 lsl x12,x12,#3
 str x12,[x29,#720]
 ldr x9,[x29,#368]
 movz x16,#9432
 movk x16,#65,lsl #16
 add x9,x9,x16
 ldr x10,[x9]
 cbz x10,.Lreject
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 ldr x12,[x9,#112]
 ldr x13,[x9,#120]
 cmp x13,#1
 b.ne .Lreject
 ldr x14,[x9,#128]
 ldr x15,[x29,#920]
 cmp x14,x15
 b.lt .Lreject
 add x11,x11,x12
 add x10,x10,x11,lsl #3
 str x10,[x29,#752]
 lsl x12,x12,#3
 str x12,[x29,#760]
 ldr x9,[x29,#368]
 movz x16,#9568
 movk x16,#65,lsl #16
 add x9,x9,x16
 ldr x10,[x9]
 cbz x10,.Lreject
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 ldr x12,[x9,#112]
 ldr x13,[x9,#120]
 cmp x13,#1
 b.ne .Lreject
 ldr x14,[x9,#128]
 ldr x15,[x29,#920]
 cmp x14,x15
 b.lt .Lreject
 add x11,x11,x12
 add x10,x10,x11,lsl #3
 str x10,[x29,#768]
 lsl x12,x12,#3
 str x12,[x29,#776]
 ldr x9,[x29,#368]
 movz x16,#9296
 movk x16,#65,lsl #16
 add x9,x9,x16
 ldr x10,[x9]
 cbz x10,.Lreject
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 ldr x12,[x9,#112]
 ldr x13,[x9,#120]
 cmp x13,#1
 b.ne .Lreject
 ldr x14,[x9,#128]
 ldr x15,[x29,#920]
 cmp x14,x15
 b.lt .Lreject
 add x11,x11,x12
 add x10,x10,x11,lsl #3
 str x10,[x29,#784]
 lsl x12,x12,#3
 str x12,[x29,#792]
 ldr x9,[x29,#368]
 movz x16,#160
 movk x16,#24,lsl #16
 add x9,x9,x16
 ldr x10,[x9]
 cbz x10,.Lreject
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
 str x10,[x29,#704]
 ldr x9,[x29,#368]
 movz x16,#13600
 movk x16,#12,lsl #16
 add x9,x9,x16
 ldr x9,[x9]
 cbz x9,.Lreject
 ldrsw x10,[x9,#168]
 cmp x10,#1
 b.lt .Lreject
 ldr x11,[x29,#1152]
 cmp x10,x11
 b.gt .Lreject
 sub x10,x10,#1
 ldr x11,[x29,#1000]
 mul x10,x10,x11
 str x10,[x29,#744]
 str wzr,[x29,#664]
 mov x0,#0
 ldr x10,[x29,#1104]
 add x0,x0,x10
 ldr x10,[x29,#1120]
 add x0,x0,x10
 ldr x10,[x29,#1136]
 add x0,x0,x10
 ldr x10,[x29,#1000]
 add x0,x0,x10
 ldr x10,[x29,#1000]
 add x0,x0,x10
 ldr x10,[x29,#1112]
 add x0,x0,x10
 ldr x10,[x29,#1144]
 add x0,x0,x10
 ldr x10,[x29,#920]
 mul x0,x0,x10
 mov x11,#0x1000000000
 cmp x0,x11
 b.hi .Lreject
 str x0,[x29,#1176]
 ldr x9,[x29,#912]
 cmp x9,#5
 b.lo .Lreject
 ldr x9,[x29,#952]
 ldr x9,[x9,#48]
 cmp x9,#1
 b.eq .Lretained_world_member_ok
 cmp x9,#4
 b.ne .Lreject
.Lretained_world_member_ok:
 mov x0,x19
 mov x1,#128
 bl .Lruntime_borrowed_span
 mov x0,x20
 mov x1,#32
 bl .Lruntime_borrowed_span
 mov x0,x21
 mov x1,#4
 bl .Lruntime_borrowed_span
 mov x0,x19
 mov x1,#128
 ldr x2,[x29,#352]
 movz x3,#17096
 movk x3,#0,lsl #16
 bl .Ldisjoint
 mov x0,x19
 mov x1,#128
 ldr x2,[x29,#360]
 movz x3,#1560
 movk x3,#0,lsl #16
 bl .Ldisjoint
 mov x0,x19
 mov x1,#128
 ldr x2,[x29,#368]
 movz x3,#15248
 movk x3,#65,lsl #16
 bl .Ldisjoint
 mov x0,x19
 mov x1,#128
 ldr x2,[x29,#384]
 movz x3,#1800
 movk x3,#0,lsl #16
 bl .Ldisjoint
 mov x0,x19
 mov x1,#128
 ldr x2,[x29,#952]
 movz x3,#64
 movk x3,#0,lsl #16
 bl .Ldisjoint
 mov x0,x19
 mov x1,#128
 ldr x2,[x29,#960]
 movz x3,#520
 movk x3,#0,lsl #16
 bl .Ldisjoint
 mov x0,x19
 mov x1,#128
 ldr x2,[x29,#968]
 movz x3,#360
 movk x3,#0,lsl #16
 bl .Ldisjoint
 mov x0,x19
 mov x1,#128
 ldr x2,[x29,#976]
 movz x3,#51512
 movk x3,#0,lsl #16
 bl .Ldisjoint
 mov x0,x19
 mov x1,#128
 ldr x2,[x29,#984]
 movz x3,#4096
 movk x3,#0,lsl #16
 bl .Ldisjoint
 mov x0,x19
 mov x1,#128
 ldr x2,[x29,#992]
 movz x3,#16
 movk x3,#0,lsl #16
 bl .Ldisjoint
 mov x0,x20
 mov x1,#32
 ldr x2,[x29,#352]
 movz x3,#17096
 movk x3,#0,lsl #16
 bl .Ldisjoint
 mov x0,x20
 mov x1,#32
 ldr x2,[x29,#360]
 movz x3,#1560
 movk x3,#0,lsl #16
 bl .Ldisjoint
 mov x0,x20
 mov x1,#32
 ldr x2,[x29,#368]
 movz x3,#15248
 movk x3,#65,lsl #16
 bl .Ldisjoint
 mov x0,x20
 mov x1,#32
 ldr x2,[x29,#384]
 movz x3,#1800
 movk x3,#0,lsl #16
 bl .Ldisjoint
 mov x0,x20
 mov x1,#32
 ldr x2,[x29,#952]
 movz x3,#64
 movk x3,#0,lsl #16
 bl .Ldisjoint
 mov x0,x20
 mov x1,#32
 ldr x2,[x29,#960]
 movz x3,#520
 movk x3,#0,lsl #16
 bl .Ldisjoint
 mov x0,x20
 mov x1,#32
 ldr x2,[x29,#968]
 movz x3,#360
 movk x3,#0,lsl #16
 bl .Ldisjoint
 mov x0,x20
 mov x1,#32
 ldr x2,[x29,#976]
 movz x3,#51512
 movk x3,#0,lsl #16
 bl .Ldisjoint
 mov x0,x20
 mov x1,#32
 ldr x2,[x29,#984]
 movz x3,#4096
 movk x3,#0,lsl #16
 bl .Ldisjoint
 mov x0,x20
 mov x1,#32
 ldr x2,[x29,#992]
 movz x3,#16
 movk x3,#0,lsl #16
 bl .Ldisjoint
 mov x0,x21
 mov x1,#4
 ldr x2,[x29,#352]
 movz x3,#17096
 movk x3,#0,lsl #16
 bl .Ldisjoint
 mov x0,x21
 mov x1,#4
 ldr x2,[x29,#360]
 movz x3,#1560
 movk x3,#0,lsl #16
 bl .Ldisjoint
 mov x0,x21
 mov x1,#4
 ldr x2,[x29,#368]
 movz x3,#15248
 movk x3,#65,lsl #16
 bl .Ldisjoint
 mov x0,x21
 mov x1,#4
 ldr x2,[x29,#384]
 movz x3,#1800
 movk x3,#0,lsl #16
 bl .Ldisjoint
 mov x0,x21
 mov x1,#4
 ldr x2,[x29,#952]
 movz x3,#64
 movk x3,#0,lsl #16
 bl .Ldisjoint
 mov x0,x21
 mov x1,#4
 ldr x2,[x29,#960]
 movz x3,#520
 movk x3,#0,lsl #16
 bl .Ldisjoint
 mov x0,x21
 mov x1,#4
 ldr x2,[x29,#968]
 movz x3,#360
 movk x3,#0,lsl #16
 bl .Ldisjoint
 mov x0,x21
 mov x1,#4
 ldr x2,[x29,#976]
 movz x3,#51512
 movk x3,#0,lsl #16
 bl .Ldisjoint
 mov x0,x21
 mov x1,#4
 ldr x2,[x29,#984]
 movz x3,#4096
 movk x3,#0,lsl #16
 bl .Ldisjoint
 mov x0,x21
 mov x1,#4
 ldr x2,[x29,#992]
 movz x3,#16
 movk x3,#0,lsl #16
 bl .Ldisjoint
 mov x0,x19
 mov x1,#128
 mov x2,x20
 mov x3,#32
 bl .Ldisjoint
 mov x0,x19
 mov x1,#128
 mov x2,x21
 mov x3,#4
 bl .Ldisjoint
 mov x0,x20
 mov x1,#32
 mov x2,x21
 mov x3,#4
 bl .Ldisjoint
 mov x0,x19
 mov x1,#128
 ldr x2,[x29,#376]
 ldr x3,[x29,#1024]
 ldr x4,[x29,#920]
 mul x3,x3,x4
 bl .Ldisjoint
 mov x0,x20
 mov x1,#32
 ldr x2,[x29,#376]
 ldr x3,[x29,#1024]
 ldr x4,[x29,#920]
 mul x3,x3,x4
 bl .Ldisjoint
 mov x0,x21
 mov x1,#4
 ldr x2,[x29,#376]
 ldr x3,[x29,#1024]
 ldr x4,[x29,#920]
 mul x3,x3,x4
 bl .Ldisjoint
 mov x0,x19
 bl .Lvalidate_state
 mov x22,x0
 ldr x23,[x19,#88]
 ldr x24,[x19,#96]
 ldr x25,[x19,#104]
 cbz x22,.Lretained_spans_done
 ldr x0,[x19,#40]
 ldr x1,[x19,#64]
 bl .Lruntime_borrowed_span
 ldr x0,[x19,#40]
 ldr x1,[x19,#64]
 mov x2,x20
 mov x3,#32
 bl .Ldisjoint
 ldr x0,[x19,#40]
 ldr x1,[x19,#64]
 mov x2,x21
 mov x3,#4
 bl .Ldisjoint
 ldr x0,[x19,#40]
 ldr x1,[x19,#64]
 ldr x2,[x29,#352]
 movz x3,#17096
 movk x3,#0,lsl #16
 bl .Ldisjoint
 ldr x0,[x19,#40]
 ldr x1,[x19,#64]
 ldr x2,[x29,#360]
 movz x3,#1560
 movk x3,#0,lsl #16
 bl .Ldisjoint
 ldr x0,[x19,#40]
 ldr x1,[x19,#64]
 ldr x2,[x29,#368]
 movz x3,#15248
 movk x3,#65,lsl #16
 bl .Ldisjoint
 ldr x0,[x19,#40]
 ldr x1,[x19,#64]
 ldr x2,[x29,#384]
 movz x3,#1800
 movk x3,#0,lsl #16
 bl .Ldisjoint
 ldr x0,[x19,#40]
 ldr x1,[x19,#64]
 ldr x2,[x29,#952]
 movz x3,#64
 movk x3,#0,lsl #16
 bl .Ldisjoint
 ldr x0,[x19,#40]
 ldr x1,[x19,#64]
 ldr x2,[x29,#960]
 movz x3,#520
 movk x3,#0,lsl #16
 bl .Ldisjoint
 ldr x0,[x19,#40]
 ldr x1,[x19,#64]
 ldr x2,[x29,#968]
 movz x3,#360
 movk x3,#0,lsl #16
 bl .Ldisjoint
 ldr x0,[x19,#40]
 ldr x1,[x19,#64]
 ldr x2,[x29,#976]
 movz x3,#51512
 movk x3,#0,lsl #16
 bl .Ldisjoint
 ldr x0,[x19,#40]
 ldr x1,[x19,#64]
 ldr x2,[x29,#984]
 movz x3,#4096
 movk x3,#0,lsl #16
 bl .Ldisjoint
 ldr x0,[x19,#40]
 ldr x1,[x19,#64]
 ldr x2,[x29,#992]
 movz x3,#16
 movk x3,#0,lsl #16
 bl .Ldisjoint
 ldr x0,[x19,#40]
 ldr x1,[x19,#64]
 ldr x2,[x29,#376]
 ldr x3,[x29,#1024]
 ldr x4,[x29,#920]
 mul x3,x3,x4
 bl .Ldisjoint
 ldr x0,[x19,#48]
 ldr x1,[x19,#72]
 bl .Lruntime_borrowed_span
 ldr x0,[x19,#48]
 ldr x1,[x19,#72]
 mov x2,x20
 mov x3,#32
 bl .Ldisjoint
 ldr x0,[x19,#48]
 ldr x1,[x19,#72]
 mov x2,x21
 mov x3,#4
 bl .Ldisjoint
 ldr x0,[x19,#48]
 ldr x1,[x19,#72]
 ldr x2,[x29,#352]
 movz x3,#17096
 movk x3,#0,lsl #16
 bl .Ldisjoint
 ldr x0,[x19,#48]
 ldr x1,[x19,#72]
 ldr x2,[x29,#360]
 movz x3,#1560
 movk x3,#0,lsl #16
 bl .Ldisjoint
 ldr x0,[x19,#48]
 ldr x1,[x19,#72]
 ldr x2,[x29,#368]
 movz x3,#15248
 movk x3,#65,lsl #16
 bl .Ldisjoint
 ldr x0,[x19,#48]
 ldr x1,[x19,#72]
 ldr x2,[x29,#384]
 movz x3,#1800
 movk x3,#0,lsl #16
 bl .Ldisjoint
 ldr x0,[x19,#48]
 ldr x1,[x19,#72]
 ldr x2,[x29,#952]
 movz x3,#64
 movk x3,#0,lsl #16
 bl .Ldisjoint
 ldr x0,[x19,#48]
 ldr x1,[x19,#72]
 ldr x2,[x29,#960]
 movz x3,#520
 movk x3,#0,lsl #16
 bl .Ldisjoint
 ldr x0,[x19,#48]
 ldr x1,[x19,#72]
 ldr x2,[x29,#968]
 movz x3,#360
 movk x3,#0,lsl #16
 bl .Ldisjoint
 ldr x0,[x19,#48]
 ldr x1,[x19,#72]
 ldr x2,[x29,#976]
 movz x3,#51512
 movk x3,#0,lsl #16
 bl .Ldisjoint
 ldr x0,[x19,#48]
 ldr x1,[x19,#72]
 ldr x2,[x29,#984]
 movz x3,#4096
 movk x3,#0,lsl #16
 bl .Ldisjoint
 ldr x0,[x19,#48]
 ldr x1,[x19,#72]
 ldr x2,[x29,#992]
 movz x3,#16
 movk x3,#0,lsl #16
 bl .Ldisjoint
 ldr x0,[x19,#48]
 ldr x1,[x19,#72]
 ldr x2,[x29,#376]
 ldr x3,[x29,#1024]
 ldr x4,[x29,#920]
 mul x3,x3,x4
 bl .Ldisjoint
 ldr x0,[x19,#56]
 ldr x1,[x19,#80]
 bl .Lruntime_borrowed_span
 ldr x0,[x19,#56]
 ldr x1,[x19,#80]
 mov x2,x20
 mov x3,#32
 bl .Ldisjoint
 ldr x0,[x19,#56]
 ldr x1,[x19,#80]
 mov x2,x21
 mov x3,#4
 bl .Ldisjoint
 ldr x0,[x19,#56]
 ldr x1,[x19,#80]
 ldr x2,[x29,#352]
 movz x3,#17096
 movk x3,#0,lsl #16
 bl .Ldisjoint
 ldr x0,[x19,#56]
 ldr x1,[x19,#80]
 ldr x2,[x29,#360]
 movz x3,#1560
 movk x3,#0,lsl #16
 bl .Ldisjoint
 ldr x0,[x19,#56]
 ldr x1,[x19,#80]
 ldr x2,[x29,#368]
 movz x3,#15248
 movk x3,#65,lsl #16
 bl .Ldisjoint
 ldr x0,[x19,#56]
 ldr x1,[x19,#80]
 ldr x2,[x29,#384]
 movz x3,#1800
 movk x3,#0,lsl #16
 bl .Ldisjoint
 ldr x0,[x19,#56]
 ldr x1,[x19,#80]
 ldr x2,[x29,#952]
 movz x3,#64
 movk x3,#0,lsl #16
 bl .Ldisjoint
 ldr x0,[x19,#56]
 ldr x1,[x19,#80]
 ldr x2,[x29,#960]
 movz x3,#520
 movk x3,#0,lsl #16
 bl .Ldisjoint
 ldr x0,[x19,#56]
 ldr x1,[x19,#80]
 ldr x2,[x29,#968]
 movz x3,#360
 movk x3,#0,lsl #16
 bl .Ldisjoint
 ldr x0,[x19,#56]
 ldr x1,[x19,#80]
 ldr x2,[x29,#976]
 movz x3,#51512
 movk x3,#0,lsl #16
 bl .Ldisjoint
 ldr x0,[x19,#56]
 ldr x1,[x19,#80]
 ldr x2,[x29,#984]
 movz x3,#4096
 movk x3,#0,lsl #16
 bl .Ldisjoint
 ldr x0,[x19,#56]
 ldr x1,[x19,#80]
 ldr x2,[x29,#992]
 movz x3,#16
 movk x3,#0,lsl #16
 bl .Ldisjoint
 ldr x0,[x19,#56]
 ldr x1,[x19,#80]
 ldr x2,[x29,#376]
 ldr x3,[x29,#1024]
 ldr x4,[x29,#920]
 mul x3,x3,x4
 bl .Ldisjoint
.Lretained_spans_done:
 ldr x9,[x29,#1144]
 lsl x9,x9,#2
 ldr x10,[x29,#920]
 umulh x11,x9,x10
 cbnz x11,.Lreject
 mul x9,x9,x10
 mov x10,#0x1000000000
 cmp x9,x10
 b.hi .Lreject
 str x9,[x29,#1280]
 ldr x9,[x29,#1080]
 ldr x10,[x29,#920]
 umulh x11,x9,x10
 cbnz x11,.Lreject
 mul x9,x9,x10
 mov x10,#0x1000000000
 cmp x9,x10
 b.hi .Lreject
 str x9,[x29,#1288]
 ldr x9,[x29,#1088]
 ldr x10,[x29,#920]
 umulh x11,x9,x10
 cbnz x11,.Lreject
 mul x9,x9,x10
 mov x10,#0x1000000000
 cmp x9,x10
 b.hi .Lreject
 str x9,[x29,#1296]
 cbz x22,.Lallocate
 ldr x9,[x19,#16]
 ldr x10,[x29,#904]
 cmp x9,x10
 b.ne .Lreshape
 ldr x9,[x19,#24]
 ldr x10,[x29,#912]
 cmp x9,x10
 b.ne .Lreshape
 ldr x9,[x19,#32]
 ldr x10,[x29,#920]
 cmp x9,x10
 b.ne .Lreshape
 ldr x9,[x19,#64]
 ldr x10,[x29,#1280]
 cmp x9,x10
 b.ne .Lreshape
 ldr x9,[x19,#72]
 ldr x10,[x29,#1288]
 cmp x9,x10
 b.ne .Lreshape
 ldr x9,[x19,#80]
 ldr x10,[x29,#1296]
 cmp x9,x10
 b.ne .Lreshape
 b .Lready
.Lreshape:
 ldr x0,[x19,#56]
 bl free
 add x25,x25,#1
 ldr x0,[x19,#48]
 bl free
 add x25,x25,#1
 ldr x0,[x19,#40]
 bl free
 add x25,x25,#1
.Lallocate:
 stp xzr,xzr,[x19,#0]
 stp xzr,xzr,[x19,#16]
 stp xzr,xzr,[x19,#32]
 stp xzr,xzr,[x19,#48]
 stp xzr,xzr,[x19,#64]
 stp xzr,xzr,[x19,#80]
 stp xzr,xzr,[x19,#96]
 stp xzr,xzr,[x19,#112]
 ldr x0,[x29,#1280]
#else
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 str w9,[x29,#424]
 ldr w9,[x29,#424]
 cbz w9,.Lprofile0
 adrp x0,.Lname
 add x0,x0,:lo12:.Lname
 mov w9,#0
 str w9,[x29,#428]
 add x1,x29,#428
 add x2,x29,#432
 mov x3,#13
 bl __yomhook_MOD_dr_hook_default8
.Lprofile0:
 adrp x19,.Lretained
 add x19,x19,:lo12:.Lretained
 ldr x9,[x19]
 cbnz x9,.Lready
 movz x0,#37632
 movk x0,#9,lsl #16
#endif
 bl malloc
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 cbz x0,.Lalloc_fail0
 str x0,[x19,#40]
 add x24,x24,#1
 ldr x0,[x29,#1288]
#else
 cbz x0,.Lreject
 str x0,[x19,#0]
 movz x0,#62208
 movk x0,#315,lsl #16
#endif
 bl malloc
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 cbz x0,.Lalloc_fail1
 str x0,[x19,#48]
 add x24,x24,#1
 ldr x0,[x29,#1296]
#else
 cbz x0,.Lreject
 str x0,[x19,#8]
 movz x0,#9728
 movk x0,#19,lsl #16
#endif
 bl malloc
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 cbz x0,.Lalloc_fail2
 str x0,[x19,#56]
 add x24,x24,#1
 mov x9,#0x4850
 str x9,[x19]
 ldr x9,[x29,#904]
 str x9,[x19,#16]
 ldr x9,[x29,#912]
 str x9,[x19,#24]
 ldr x9,[x29,#920]
 str x9,[x19,#32]
 ldr x9,[x29,#1280]
 str x9,[x19,#64]
 ldr x9,[x29,#1288]
 str x9,[x19,#72]
 ldr x9,[x29,#1296]
 str x9,[x19,#80]
#else
 cbz x0,.Lreject
 str x0,[x19,#16]
#endif
.Lready:
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 mov x9,#1
 str x9,[x19,#8]
 ldr x0,[x29,#352]
 ldr x1,[x29,#360]
 ldr x2,[x29,#368]
 ldr x3,[x29,#376]
 ldr x4,[x29,#384]
 ldr x5,[x29,#392]
 ldr x6,[x29,#400]
 ldr x7,[x29,#408]
 ldr x9,[x29,#416]
#else
 ldr x0,[x29,#256]
 ldr x1,[x29,#264]
 ldr x2,[x29,#272]
 ldr x3,[x29,#280]
 ldr x4,[x29,#288]
 ldr x5,[x29,#296]
 ldr x6,[x29,#304]
 ldr x7,[x29,#312]
 ldr x9,[x29,#320]
#endif
 str x9,[sp,#0]
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 ldr x9,[x29,#424]
#else
 ldr x9,[x29,#328]
#endif
 str x9,[sp,#8]
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 ldr x9,[x29,#432]
#else
 ldr x9,[x29,#336]
#endif
 str x9,[sp,#16]
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 ldr x9,[x29,#440]
#else
 ldr x9,[x29,#344]
#endif
 str x9,[sp,#24]
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 ldr x9,[x29,#448]
#else
 ldr x9,[x29,#352]
#endif
 str x9,[sp,#32]
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 ldr x9,[x29,#456]
#else
 ldr x9,[x29,#360]
#endif
 str x9,[sp,#40]
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 ldr x9,[x29,#464]
#else
 ldr x9,[x29,#368]
#endif
 str x9,[sp,#48]
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 ldr x9,[x29,#472]
#else
 ldr x9,[x29,#376]
#endif
 str x9,[sp,#56]
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 ldr x9,[x29,#480]
#else
 ldr x9,[x29,#384]
#endif
 str x9,[sp,#64]
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 ldr x9,[x29,#488]
#else
 ldr x9,[x29,#392]
#endif
 str x9,[sp,#72]
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 ldr x9,[x29,#496]
#else
 ldr x9,[x29,#400]
#endif
 str x9,[sp,#80]
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 ldr x9,[x29,#504]
#else
 ldr x9,[x29,#408]
#endif
 str x9,[sp,#88]
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 ldr x9,[x19,#40]
#else
 ldr x9,[x19,#0]
#endif
 str x9,[sp,#96]
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 ldr x9,[x19,#48]
#else
 ldr x9,[x19,#8]
#endif
 str x9,[sp,#104]
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 ldr x9,[x19,#56]
#else
 ldr x9,[x19,#16]
#endif
 str x9,[sp,#112]
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
 ldr x9,[x20,#8]
 str x9,[sp,#120]
 bl md2asm_runtime_semi_lagrangian_transport
#ifdef MD2ASM_DISCARD_COMPLETED_TRANSPORT_PAGES
 ldr x9,[x19,#24]
 cmp x9,#137
 b.ne .Lcompleted_pages_done
 ldr x9,[x29,#368]
 movz x10,#61552
 movk x10,#23,lsl #16
 ldr w10,[x9,x10]
 cbnz w10,.Lcompleted_pages_done
 movz x10,#56884
 movk x10,#23,lsl #16
 add x9,x9,x10
 ldr w10,[x9,#0]
 cbnz w10,.Lcompleted_pages_done
 ldr w10,[x9,#4]
 cbnz w10,.Lcompleted_pages_done
 ldr w10,[x9,#8]
 cbnz w10,.Lcompleted_pages_done
 ldr w10,[x9,#12]
 cbnz w10,.Lcompleted_pages_done
 ldr w10,[x9,#16]
 cbnz w10,.Lcompleted_pages_done
 ldr w10,[x9,#20]
 cbnz w10,.Lcompleted_pages_done
 ldr w10,[x9,#24]
 cbnz w10,.Lcompleted_pages_done
 ldr x9,[x29,#368]
 ldr w12,[x9,#192]
 cmp w12,#2163
 b.hi .Lcompleted_pages_done
 add x9,x9,#4040
 movz x14,#21288
 movk x14,#17484,lsl #16
 movk x14,#41,lsl #32
 cbz w12,.Lcompleted_pages_eligible
.Lcompleted_pages_gfl_scan:
 ldr x13,[x9,#160]
 ubfx x15,x13,#16,#40
 cmp x15,x14
 b.eq .Lcompleted_pages_done
 lsr x15,x13,#24
 cmp x15,x14
 b.eq .Lcompleted_pages_done
 add x9,x9,#368
 sub w12,w12,#1
 cbnz w12,.Lcompleted_pages_gfl_scan
.Lcompleted_pages_eligible:
 mov x1,x19
 bl md2asm_discard_completed_transport_private_pages
.Lcompleted_pages_done:
#endif
 add x23,x23,#1
 str xzr,[x19,#8]
 str x23,[x19,#88]
 str x24,[x19,#96]
 str x25,[x19,#104]
 b .Lreturn
.Lalloc_fail2:
 ldr x0,[x19,#48]
 bl free
.Lalloc_fail1:
 ldr x0,[x19,#40]
 bl free
.Lalloc_fail0:
 stp xzr,xzr,[x19,#0]
 stp xzr,xzr,[x19,#16]
 stp xzr,xzr,[x19,#32]
 stp xzr,xzr,[x19,#48]
 stp xzr,xzr,[x19,#64]
 stp xzr,xzr,[x19,#80]
 stp xzr,xzr,[x19,#96]
 stp xzr,xzr,[x19,#112]
 b .Lreject
.Lreturn:
 ldp x18,x19,[sp,#256]
 ldp x20,x21,[sp,#272]
 ldp x22,x23,[sp,#288]
 ldp x24,x25,[sp,#304]
 ldp x26,x27,[sp,#320]
 ldp x28,x29,[sp,#336]
 ldr x30,[sp,#352]
 add sp,sp,#1536
#else
 bl md2asm_call_sl_7358525
 adrp x9,.Lcalls
 add x9,x9,:lo12:.Lcalls
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ldr w9,[x29,#424]
 cbz w9,.Lprofile1
 adrp x0,.Lname
 add x0,x0,:lo12:.Lname
 mov w9,#1
 str w9,[x29,#428]
 add x1,x29,#428
 add x2,x29,#432
 mov x3,#13
 bl __yomhook_MOD_dr_hook_default8
.Lprofile1:
 ldp x18,x19,[sp,#128]
 ldp x20,x21,[sp,#144]
 ldp x22,x23,[sp,#160]
 ldp x24,x25,[sp,#176]
 ldp x26,x27,[sp,#192]
 ldp x28,x29,[sp,#208]
 ldr x30,[sp,#224]
 add sp,sp,#512
#endif
 ret
.Lreject:
 bl abort
 brk #0
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
.size md2asm_runtime_transport_work_storage,.-md2asm_runtime_transport_work_storage
.global md2asm_runtime_release_transport_work_storage
.type md2asm_runtime_release_transport_work_storage,%function
md2asm_runtime_release_transport_work_storage:
 stp x19,x30,[sp,#-32]!
 mov x19,x0
 bl .Lvalidate_state
 cbz x0,.Lrelease_clear
 ldr x0,[x19,#56]
 bl free
 ldr x0,[x19,#48]
 bl free
 ldr x0,[x19,#40]
 bl free
.Lrelease_clear:
 stp xzr,xzr,[x19,#0]
 stp xzr,xzr,[x19,#16]
 stp xzr,xzr,[x19,#32]
 stp xzr,xzr,[x19,#48]
 stp xzr,xzr,[x19,#64]
 stp xzr,xzr,[x19,#80]
 stp xzr,xzr,[x19,#96]
 stp xzr,xzr,[x19,#112]
 ldp x19,x30,[sp],#32
#else
.size md2asm_call_sl_heap2_7358525,.-md2asm_call_sl_heap2_7358525
.global md2asm_call_sl_heap2_count_get
.type md2asm_call_sl_heap2_count_get,%function
md2asm_call_sl_heap2_count_get:
 adrp x9,.Lcalls
 add x9,x9,:lo12:.Lcalls
 ldr x0,[x9]
#endif
 ret
#ifdef CALL_SL_HEAP2_EXPLICIT_CONTEXT
.size md2asm_runtime_release_transport_work_storage,.-md2asm_runtime_release_transport_work_storage
.Ldisjoint:
 cbz x0,.Lreject
 cbz x2,.Lreject
 adds x1,x0,x1
 b.cs .Lreject
 adds x3,x2,x3
 b.cs .Lreject
 cmp x0,x3
 b.hs .Ldisjoint_done
 cmp x2,x1
 b.lo .Lreject
.Ldisjoint_done:
 ret
.Lvalidate_state:
 cbz x0,.Lreject
 tst x0,#7
 b.ne .Lreject
 adds x9,x0,#128
 b.cs .Lreject
 ldr x9,[x0]
 cbz x9,.Lstate_empty
 mov x10,#0x4850
 cmp x9,x10
 b.ne .Lreject
 ldr x9,[x0,#8]
 cbnz x9,.Lreject
 ldr x9,[x0,#112]
 cbnz x9,.Lreject
 ldr x9,[x0,#120]
 cbnz x9,.Lreject
 ldr x9,[x0,#88]
 lsr x10,x9,#60
 cbnz x10,.Lreject
 ldr x9,[x0,#96]
 lsr x10,x9,#60
 cbnz x10,.Lreject
 ldr x9,[x0,#104]
 lsr x10,x9,#60
 cbnz x10,.Lreject
 ldr x9,[x0,#88]
 cbz x9,.Lreject
 ldr x10,[x0,#96]
 cmp x10,#3
 b.lo .Lreject
 mov x11,#3
 udiv x12,x10,x11
 msub x11,x12,x11,x10
 cbnz x11,.Lreject
 cmp x12,x9
 b.hi .Lreject
 sub x10,x10,#3
 ldr x11,[x0,#104]
 cmp x10,x11
 b.ne .Lreject
 ldr x9,[x0,#16]
 cmp x9,#1
 b.lo .Lreject
 movz x10,#1024
 movk x10,#0,lsl #16
 cmp x9,x10
 b.hi .Lreject
 ldr x9,[x0,#24]
 cmp x9,#4
 b.lo .Lreject
 movz x10,#256
 movk x10,#0,lsl #16
 cmp x9,x10
 b.hi .Lreject
 ldr x9,[x0,#32]
 cmp x9,#1
 b.lo .Lreject
 movz x10,#65535
 movk x10,#32767,lsl #16
 cmp x9,x10
 b.hi .Lreject
 ldr x9,[x0,#16]
 ldr x10,[x0,#24]
 mul x9,x9,x10
 ldr x10,[x0,#32]
 umulh x11,x9,x10
 cbnz x11,.Lreject
 mul x9,x9,x10
 lsl x10,x9,#4
 ldr x11,[x0,#64]
 cmp x10,x11
 b.ne .Lreject
 lsl x9,x9,#3
 ldr x10,[x0,#72]
 udiv x11,x10,x9
 msub x12,x11,x9,x10
 cbnz x12,.Lreject
 cmp x11,#1
 b.lo .Lreject
 cmp x11,#256
 b.hi .Lreject
 ldr x10,[x0,#80]
 udiv x11,x10,x9
 msub x12,x11,x9,x10
 cbnz x12,.Lreject
 cmp x11,#1
 b.lo .Lreject
 cmp x11,#64
 b.hi .Lreject
 ldr x9,[x0,#40]
 cbz x9,.Lreject
 tst x9,#7
 b.ne .Lreject
 ldr x10,[x0,#64]
 mov x11,#0x1000000000
 cmp x10,x11
 b.hi .Lreject
 adds x10,x9,x10
 b.cs .Lreject
 add x11,x0,#128
 cmp x9,x11
 b.hs .Lst40
 cmp x0,x10
 b.lo .Lreject
.Lst40:
 ldr x9,[x0,#48]
 cbz x9,.Lreject
 tst x9,#7
 b.ne .Lreject
 ldr x10,[x0,#72]
 mov x11,#0x1000000000
 cmp x10,x11
 b.hi .Lreject
 adds x10,x9,x10
 b.cs .Lreject
 add x11,x0,#128
 cmp x9,x11
 b.hs .Lst48
 cmp x0,x10
 b.lo .Lreject
.Lst48:
 ldr x9,[x0,#56]
 cbz x9,.Lreject
 tst x9,#7
 b.ne .Lreject
 ldr x10,[x0,#80]
 mov x11,#0x1000000000
 cmp x10,x11
 b.hi .Lreject
 adds x10,x9,x10
 b.cs .Lreject
 add x11,x0,#128
 cmp x9,x11
 b.hs .Lst56
 cmp x0,x10
 b.lo .Lreject
.Lst56:
 ldr x9,[x0,#40]
 ldr x10,[x0,#64]
 add x10,x9,x10
 ldr x11,[x0,#48]
 ldr x12,[x0,#72]
 add x12,x11,x12
 cmp x9,x12
 b.hs .Lpair40_48
 cmp x11,x10
 b.lo .Lreject
.Lpair40_48:
 ldr x9,[x0,#40]
 ldr x10,[x0,#64]
 add x10,x9,x10
 ldr x11,[x0,#56]
 ldr x12,[x0,#80]
 add x12,x11,x12
 cmp x9,x12
 b.hs .Lpair40_56
 cmp x11,x10
 b.lo .Lreject
.Lpair40_56:
 ldr x9,[x0,#48]
 ldr x10,[x0,#72]
 add x10,x9,x10
 ldr x11,[x0,#56]
 ldr x12,[x0,#80]
 add x12,x11,x12
 cmp x9,x12
 b.hs .Lpair48_56
 cmp x11,x10
 b.lo .Lreject
.Lpair48_56:
 mov x0,#1
 ret
.Lstate_empty:
 ldr x9,[x0,#8]
 cbnz x9,.Lreject
 ldr x9,[x0,#16]
 cbnz x9,.Lreject
 ldr x9,[x0,#24]
 cbnz x9,.Lreject
 ldr x9,[x0,#32]
 cbnz x9,.Lreject
 ldr x9,[x0,#40]
 cbnz x9,.Lreject
 ldr x9,[x0,#48]
 cbnz x9,.Lreject
 ldr x9,[x0,#56]
 cbnz x9,.Lreject
 ldr x9,[x0,#64]
 cbnz x9,.Lreject
 ldr x9,[x0,#72]
 cbnz x9,.Lreject
 ldr x9,[x0,#80]
 cbnz x9,.Lreject
 ldr x9,[x0,#88]
 cbnz x9,.Lreject
 ldr x9,[x0,#96]
 cbnz x9,.Lreject
 ldr x9,[x0,#104]
 cbnz x9,.Lreject
 ldr x9,[x0,#112]
 cbnz x9,.Lreject
 ldr x9,[x0,#120]
 cbnz x9,.Lreject
 mov x0,#0
 ret
.Lruntime_borrowed_span:
 cbz x0,.Lreject
 tst x0,#7
 b.ne .Lreject
 adds x2,x0,x1
 b.cs .Lreject
 ldr x3,[x29,#392]
 ldr x4,[x29,#1128]
 ldr x5,[x29,#920]
 mul x4,x4,x5
 cbz x4,.Lruntime_span_next_5
 cbz x3,.Lreject
 tst x3,#3
 b.ne .Lreject
 adds x4,x3,x4
 b.cs .Lreject
 cmp x0,x4
 b.hs .Lruntime_span_next_5
 cmp x3,x2
 b.lo .Lreject
.Lruntime_span_next_5:
 ldr x3,[x29,#400]
 ldr x4,[x29,#1128]
 ldr x5,[x29,#920]
 mul x4,x4,x5
 cbz x4,.Lruntime_span_next_6
 cbz x3,.Lreject
 tst x3,#3
 b.ne .Lreject
 adds x4,x3,x4
 b.cs .Lreject
 cmp x0,x4
 b.hs .Lruntime_span_next_6
 cmp x3,x2
 b.lo .Lreject
.Lruntime_span_next_6:
 ldr x3,[x29,#416]
 ldr x4,[x29,#1016]
 ldr x5,[x29,#920]
 mul x4,x4,x5
 cbz x4,.Lruntime_span_next_8
 cbz x3,.Lreject
 tst x3,#7
 b.ne .Lreject
 adds x4,x3,x4
 b.cs .Lreject
 cmp x0,x4
 b.hs .Lruntime_span_next_8
 cmp x3,x2
 b.lo .Lreject
.Lruntime_span_next_8:
 ldr x3,[x29,#424]
 ldr x4,[x29,#1000]
 ldr x5,[x29,#920]
 mul x4,x4,x5
 cbz x4,.Lruntime_span_next_9
 cbz x3,.Lreject
 tst x3,#7
 b.ne .Lreject
 adds x4,x3,x4
 b.cs .Lreject
 cmp x0,x4
 b.hs .Lruntime_span_next_9
 cmp x3,x2
 b.lo .Lreject
.Lruntime_span_next_9:
 ldr x3,[x29,#432]
 ldr x4,[x29,#1032]
 ldr x5,[x29,#920]
 mul x4,x4,x5
 cbz x4,.Lruntime_span_next_10
 cbz x3,.Lreject
 tst x3,#7
 b.ne .Lreject
 adds x4,x3,x4
 b.cs .Lreject
 cmp x0,x4
 b.hs .Lruntime_span_next_10
 cmp x3,x2
 b.lo .Lreject
.Lruntime_span_next_10:
 ldr x3,[x29,#440]
 ldr x4,[x29,#1040]
 ldr x5,[x29,#920]
 mul x4,x4,x5
 cbz x4,.Lruntime_span_next_11
 cbz x3,.Lreject
 tst x3,#7
 b.ne .Lreject
 adds x4,x3,x4
 b.cs .Lreject
 cmp x0,x4
 b.hs .Lruntime_span_next_11
 cmp x3,x2
 b.lo .Lreject
.Lruntime_span_next_11:
 ldr x3,[x29,#448]
 ldr x4,[x29,#1048]
 ldr x5,[x29,#920]
 mul x4,x4,x5
 cbz x4,.Lruntime_span_next_12
 cbz x3,.Lreject
 tst x3,#7
 b.ne .Lreject
 adds x4,x3,x4
 b.cs .Lreject
 cmp x0,x4
 b.hs .Lruntime_span_next_12
 cmp x3,x2
 b.lo .Lreject
.Lruntime_span_next_12:
 ldr x3,[x29,#456]
 ldr x4,[x29,#1056]
 ldr x5,[x29,#920]
 mul x4,x4,x5
 cbz x4,.Lruntime_span_next_13
 cbz x3,.Lreject
 tst x3,#7
 b.ne .Lreject
 adds x4,x3,x4
 b.cs .Lreject
 cmp x0,x4
 b.hs .Lruntime_span_next_13
 cmp x3,x2
 b.lo .Lreject
.Lruntime_span_next_13:
 ldr x3,[x29,#464]
 ldr x4,[x29,#1064]
 ldr x5,[x29,#920]
 mul x4,x4,x5
 cbz x4,.Lruntime_span_next_14
 cbz x3,.Lreject
 tst x3,#7
 b.ne .Lreject
 adds x4,x3,x4
 b.cs .Lreject
 cmp x0,x4
 b.hs .Lruntime_span_next_14
 cmp x3,x2
 b.lo .Lreject
.Lruntime_span_next_14:
 ldr x3,[x29,#472]
 ldr x4,[x29,#1072]
 ldr x5,[x29,#920]
 mul x4,x4,x5
 cbz x4,.Lruntime_span_next_15
 cbz x3,.Lreject
 tst x3,#7
 b.ne .Lreject
 adds x4,x3,x4
 b.cs .Lreject
 cmp x0,x4
 b.hs .Lruntime_span_next_15
 cmp x3,x2
 b.lo .Lreject
.Lruntime_span_next_15:
 ldr x3,[x29,#480]
 ldr x4,[x29,#1000]
 ldr x5,[x29,#920]
 mul x4,x4,x5
 cbz x4,.Lruntime_span_next_16
 cbz x3,.Lreject
 tst x3,#7
 b.ne .Lreject
 adds x4,x3,x4
 b.cs .Lreject
 cmp x0,x4
 b.hs .Lruntime_span_next_16
 cmp x3,x2
 b.lo .Lreject
.Lruntime_span_next_16:
 ldr x3,[x29,#488]
 ldr x4,[x29,#1000]
 ldr x5,[x29,#920]
 mul x4,x4,x5
 cbz x4,.Lruntime_span_next_17
 cbz x3,.Lreject
 tst x3,#7
 b.ne .Lreject
 adds x4,x3,x4
 b.cs .Lreject
 cmp x0,x4
 b.hs .Lruntime_span_next_17
 cmp x3,x2
 b.lo .Lreject
.Lruntime_span_next_17:
 ldr x3,[x29,#496]
 ldr x4,[x29,#1000]
 ldr x5,[x29,#920]
 mul x4,x4,x5
 cbz x4,.Lruntime_span_next_18
 cbz x3,.Lreject
 tst x3,#7
 b.ne .Lreject
 adds x4,x3,x4
 b.cs .Lreject
 cmp x0,x4
 b.hs .Lruntime_span_next_18
 cmp x3,x2
 b.lo .Lreject
.Lruntime_span_next_18:
 ldr x3,[x29,#504]
 ldr x4,[x29,#1096]
 ldr x5,[x29,#920]
 mul x4,x4,x5
 cbz x4,.Lruntime_span_next_19
 cbz x3,.Lreject
 tst x3,#7
 b.ne .Lreject
 adds x4,x3,x4
 b.cs .Lreject
 cmp x0,x4
 b.hs .Lruntime_span_next_19
 cmp x3,x2
 b.lo .Lreject
.Lruntime_span_next_19:
 ldr x3,[x29,#408]
 ldr x4,[x29,#1168]
 adds x4,x3,x4
 b.cs .Lreject
 cmp x0,x4
 b.hs .Lruntime_span_done
 cmp x3,x2
 b.lo .Lreject
.Lruntime_span_done:
 ldr x9,[x29,#368]
 movz x16,#58408
 movk x16,#23,lsl #16
 add x9,x9,x16
 ldr x3,[x9]
 cbz x3,.Lreject
 tst x3,#7
 b.ne .Lreject
 ldr x4,[x9,#8]
 ldr x5,[x9,#40]
 ldr x6,[x9,#48]
 madd x4,x5,x6,x4
 ldr x5,[x9,#64]
 ldr x6,[x9,#72]
 madd x4,x5,x6,x4
 ldr x5,[x9,#88]
 ldr x6,[x9,#96]
 madd x4,x5,x6,x4
 ldr x5,[x9,#112]
 add x4,x4,x5
 cbnz x4,.Lreject
 cmp x5,#1
 b.lt .Lreject
 lsr x6,x5,#60
 cbnz x6,.Lreject
 lsl x5,x5,#3
 ldr x6,[x29,#920]
 umulh x7,x5,x6
 cbnz x7,.Lreject
 mul x5,x5,x6
 adds x4,x3,x5
 b.cs .Lreject
 cmp x0,x4
 b.hs .Lruntime_desc_span_next0
 cmp x3,x2
 b.lo .Lreject
.Lruntime_desc_span_next0:
 ldr x9,[x29,#368]
 movz x16,#9432
 movk x16,#65,lsl #16
 add x9,x9,x16
 ldr x3,[x9]
 cbz x3,.Lreject
 tst x3,#7
 b.ne .Lreject
 ldr x4,[x9,#8]
 ldr x5,[x9,#40]
 ldr x6,[x9,#48]
 madd x4,x5,x6,x4
 ldr x5,[x9,#64]
 ldr x6,[x9,#72]
 madd x4,x5,x6,x4
 ldr x5,[x9,#88]
 ldr x6,[x9,#96]
 madd x4,x5,x6,x4
 ldr x5,[x9,#112]
 add x4,x4,x5
 cbnz x4,.Lreject
 cmp x5,#1
 b.lt .Lreject
 lsr x6,x5,#60
 cbnz x6,.Lreject
 lsl x5,x5,#3
 ldr x6,[x29,#920]
 umulh x7,x5,x6
 cbnz x7,.Lreject
 mul x5,x5,x6
 adds x4,x3,x5
 b.cs .Lreject
 cmp x0,x4
 b.hs .Lruntime_desc_span_next1
 cmp x3,x2
 b.lo .Lreject
.Lruntime_desc_span_next1:
 ldr x9,[x29,#368]
 movz x16,#9568
 movk x16,#65,lsl #16
 add x9,x9,x16
 ldr x3,[x9]
 cbz x3,.Lreject
 tst x3,#7
 b.ne .Lreject
 ldr x4,[x9,#8]
 ldr x5,[x9,#40]
 ldr x6,[x9,#48]
 madd x4,x5,x6,x4
 ldr x5,[x9,#64]
 ldr x6,[x9,#72]
 madd x4,x5,x6,x4
 ldr x5,[x9,#88]
 ldr x6,[x9,#96]
 madd x4,x5,x6,x4
 ldr x5,[x9,#112]
 add x4,x4,x5
 cbnz x4,.Lreject
 cmp x5,#1
 b.lt .Lreject
 lsr x6,x5,#60
 cbnz x6,.Lreject
 lsl x5,x5,#3
 ldr x6,[x29,#920]
 umulh x7,x5,x6
 cbnz x7,.Lreject
 mul x5,x5,x6
 adds x4,x3,x5
 b.cs .Lreject
 cmp x0,x4
 b.hs .Lruntime_desc_span_next2
 cmp x3,x2
 b.lo .Lreject
.Lruntime_desc_span_next2:
 ldr x9,[x29,#368]
 movz x16,#9296
 movk x16,#65,lsl #16
 add x9,x9,x16
 ldr x3,[x9]
 cbz x3,.Lreject
 tst x3,#7
 b.ne .Lreject
 ldr x4,[x9,#8]
 ldr x5,[x9,#40]
 ldr x6,[x9,#48]
 madd x4,x5,x6,x4
 ldr x5,[x9,#64]
 ldr x6,[x9,#72]
 madd x4,x5,x6,x4
 ldr x5,[x9,#88]
 ldr x6,[x9,#96]
 madd x4,x5,x6,x4
 ldr x5,[x9,#112]
 add x4,x4,x5
 cbnz x4,.Lreject
 cmp x5,#1
 b.lt .Lreject
 lsr x6,x5,#60
 cbnz x6,.Lreject
 lsl x5,x5,#3
 ldr x6,[x29,#920]
 umulh x7,x5,x6
 cbnz x7,.Lreject
 mul x5,x5,x6
 adds x4,x3,x5
 b.cs .Lreject
 cmp x0,x4
 b.hs .Lruntime_desc_span_next3
 cmp x3,x2
 b.lo .Lreject
.Lruntime_desc_span_next3:
 ret

#else
.section .rodata
.Lname: .ascii "CALL_SL_HEAP2"
.bss
.p2align 3
.Lretained: .zero 24
.Lcalls: .zero 8
#endif
.section .note.GNU-stack,"",%progbits
