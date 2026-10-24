#ifdef CALL_SL_EXPLICIT_CONTEXT
#else
/* Source build for the qualified private forecast graph.
 * Contract: skills/md2asm/references/openifs/dynamics/private_forecast_graph_sources.md.
 * Preserve the original interface, ordered arithmetic, and caller-owned storage. */
#endif
/* Complete direct CALL_SL, selected spherical hydrostatic route.
 * Physics formulations/openifs/dynamics/trajectory_interpolation_weights.md
 * and formulations/openifs/dynamics/prognostic_departure_update.md.
 * Contract skills/md2asm/references/openifs/transport/runtime_semi_lagrangian_transport.md.
 * 23 ordinary addresses. No original Fortran numerical fallback. */
.arch armv8.2-a+simd
.text
.p2align 4
#ifdef CALL_SL_EXPLICIT_CONTEXT
.global md2asm_runtime_semi_lagrangian_transport
.global runtime_call_sl_
.set runtime_call_sl_,md2asm_runtime_semi_lagrangian_transport
.type md2asm_runtime_semi_lagrangian_transport,%function
md2asm_runtime_semi_lagrangian_transport:
#else
.global md2asm_call_sl_7358525
.global call_sl_
.set call_sl_,md2asm_call_sl_7358525
.type md2asm_call_sl_7358525,%function
md2asm_call_sl_7358525:
#endif
 mov x17,sp
#ifdef CALL_SL_EXPLICIT_CONTEXT
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
 sub sp,sp,#1024
 stp x18,x19,[sp,#224]
 stp x20,x21,[sp,#240]
 stp x22,x23,[sp,#256]
 stp x24,x25,[sp,#272]
 stp x26,x27,[sp,#288]
 stp x28,x29,[sp,#304]
 str x30,[sp,#320]
 mov x29,sp
 str x0,[sp,#352]
 str x1,[sp,#360]
 str x2,[sp,#368]
 str x3,[sp,#376]
 str x4,[sp,#384]
 str x5,[sp,#392]
 str x6,[sp,#400]
 str x7,[sp,#408]
#endif
 ldr x9,[x17,#0]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 str x9,[x29,#416]
#else
 str x9,[sp,#416]
#endif
 ldr x9,[x17,#8]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 str x9,[x29,#424]
#else
 str x9,[sp,#424]
#endif
 ldr x9,[x17,#16]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 str x9,[x29,#432]
#else
 str x9,[sp,#432]
#endif
 ldr x9,[x17,#24]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 str x9,[x29,#440]
#else
 str x9,[sp,#440]
#endif
 ldr x9,[x17,#32]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 str x9,[x29,#448]
#else
 str x9,[sp,#448]
#endif
 ldr x9,[x17,#40]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 str x9,[x29,#456]
#else
 str x9,[sp,#456]
#endif
 ldr x9,[x17,#48]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 str x9,[x29,#464]
#else
 str x9,[sp,#464]
#endif
 ldr x9,[x17,#56]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 str x9,[x29,#472]
#else
 str x9,[sp,#472]
#endif
 ldr x9,[x17,#64]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 str x9,[x29,#480]
#else
 str x9,[sp,#480]
#endif
 ldr x9,[x17,#72]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 str x9,[x29,#488]
#else
 str x9,[sp,#488]
#endif
 ldr x9,[x17,#80]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 str x9,[x29,#496]
#else
 str x9,[sp,#496]
#endif
 ldr x9,[x17,#88]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 str x9,[x29,#504]
#else
 str x9,[sp,#504]
#endif
 ldr x9,[x17,#96]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 str x9,[x29,#512]
#else
 str x9,[sp,#512]
#endif
 ldr x9,[x17,#104]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 str x9,[x29,#520]
#else
 str x9,[sp,#520]
#endif
 ldr x9,[x17,#112]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 str x9,[x29,#528]
#else
 str x9,[sp,#528]
#endif
 mrs x9,fpcr
 cbnz x9,.Lreject
#ifdef CALL_SL_EXPLICIT_CONTEXT
#else
 ldr x9,[x29,#352]
 movz x16,#5144
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#24
 b.ne .Lreject
 ldr x9,[x29,#352]
 movz x16,#5156
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lreject
 ldr x9,[x29,#352]
 movz x16,#5160
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#86
 b.ne .Lreject
 ldr x9,[x29,#352]
 movz x16,#5224
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#19
 b.ne .Lreject
 ldr x9,[x29,#352]
 movz x16,#7376
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#2048
 b.ne .Lreject
 ldr x9,[x29,#352]
 movz x16,#7380
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#2048
 b.ne .Lreject
 ldr x9,[x29,#368]
 movz x16,#152
 movk x16,#24,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#463
 b.ne .Lreject
 ldr x9,[x29,#368]
 movz x16,#456
 movk x16,#24,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#153
 b.ne .Lreject
 ldr x9,[x29,#368]
 movz x16,#63636
 movk x16,#23,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#4
 b.ne .Lreject
 ldr x9,[x29,#368]
 movz x16,#63280
 movk x16,#23,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#12
 b.ne .Lreject
 ldr x9,[x29,#368]
 movz x16,#63452
 movk x16,#23,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#66
 b.ne .Lreject
 ldr x9,[x29,#368]
 movz x16,#63616
 movk x16,#23,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#4
 b.ne .Lreject
 ldr x9,[x29,#368]
 movz x16,#63308
 movk x16,#23,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#12
 b.ne .Lreject
 ldr x9,[x29,#368]
 movz x16,#63596
 movk x16,#23,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#66
 b.ne .Lreject
 ldr x9,[x29,#368]
 add x9,x9,#240
 ldr w10,[x9]
 cmp w10,#8
 b.ne .Lreject
 ldr x9,[x29,#368]
 add x9,x9,#256
 ldr w10,[x9]
 cmp w10,#6
 b.ne .Lreject
 ldr x9,[x29,#368]
 add x9,x9,#276
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 ldr x9,[x29,#368]
 add x9,x9,#264
 ldr w10,[x9]
 cmp w10,#2
 b.ne .Lreject
#endif
 ldr x9,[x29,#368]
 movz x16,#57144
 movk x16,#23,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 ldr x9,[x29,#368]
 movz x16,#57148
 movk x16,#23,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 ldr x9,[x29,#368]
 movz x16,#59844
 movk x16,#23,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
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
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x9,[x17,#120]
 str x9,[x29,#952]
 cbz x9,.Lreject
 tst x9,#7
#else
 adrp x9,:got:__yommp0_MOD_nproc
 ldr x9,[x9,:got_lo12:__yommp0_MOD_nproc]
 ldr w9,[x9]
 cmp w9,#1
#endif
 b.ne .Lreject
#ifdef CALL_SL_EXPLICIT_CONTEXT
 adds x10,x9,#64
 b.cs .Lreject
 ldr x10,[x9,#0]
 cbz x10,.Lreject
 tst x10,#7
#else
 adrp x9,:got:__yomct0_MOD_lrplane
 ldr x9,[x9,:got_lo12:__yomct0_MOD_lrplane]
 ldr w9,[x9]
 cmp w9,#0
#endif
 b.ne .Lreject
#ifdef CALL_SL_EXPLICIT_CONTEXT
 mov x11,#520
 adds x11,x10,x11
 b.cs .Lreject
 str x10,[x29,#960]
 ldr x10,[x9,#8]
 cbz x10,.Lreject
 tst x10,#7
#else
 adrp x9,:got:__yommp0_MOD_lsldebug
 ldr x9,[x9,:got_lo12:__yommp0_MOD_lsldebug]
 ldr w9,[x9]
 cmp w9,#0
#endif
 b.ne .Lreject
#ifdef CALL_SL_EXPLICIT_CONTEXT
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
 movz x16,#63452
 movk x16,#23,lsl #16
 add x9,x9,x16
 ldrsw x10,[x9]
 cmp x10,#1
 b.lt .Lreject
 cmp x10,#256
 b.gt .Lreject
 ldr x11,[x29,#1000]
 mul x10,x10,x11
 str x10,[x29,#1080]
 ldr x9,[x29,#368]
 movz x16,#63616
 movk x16,#23,lsl #16
 add x9,x9,x16
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
 b.ne .Lreject
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
#else
#endif
 ldr x9,[x29,#384]
 ldr w10,[x9,#1036]
 cbnz w10,.Lreject
 ldr x9,[x29,#360]
#ifdef CALL_SL_EXPLICIT_CONTEXT
#else
 ldr w10,[x9,#1360]
 cmp w10,#3
 b.ne .Lreject
 ldr w10,[x9,#1364]
 cmp w10,#1
 b.ne .Lreject
#endif
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
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x15,[x29,#920]
 cmp x14,x15
#else
 cmp x14,#86
#endif
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
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x15,[x29,#920]
 cmp x14,x15
#else
 cmp x14,#86
#endif
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
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x15,[x29,#920]
 cmp x14,x15
#else
 cmp x14,#86
#endif
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
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x15,[x29,#920]
 cmp x14,x15
#else
 cmp x14,#86
#endif
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
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x11,[x29,#1152]
 cmp x10,x11
#else
 cmp x10,#8
#endif
 b.gt .Lreject
 sub x10,x10,#1
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x11,[x29,#1000]
#else
 mov x11,#3648
#endif
 mul x10,x10,x11
 str x10,[x29,#744]
#ifdef CALL_SL_EXPLICIT_CONTEXT
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
#else
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 str w9,[x29,#664]
 ldr w9,[x29,#664]
 cbz w9,.Lprofile_skip0
 adrp x0,.Lname
 add x0,x0,:lo12:.Lname
 mov w9,#0
 str w9,[x29,#684]
 add x1,x29,#684
 add x2,x29,#656
 mov x3,#7
 bl __yomhook_MOD_dr_hook_default8
.Lprofile_skip0:
 movz x0,#4800
 movk x0,#47,lsl #16
#endif
 bl malloc
 cbz x0,.Lreject
 str x0,[x29,#800]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 mov x11,#0
 add x9,x0,x11
#else
 movz x9,#0
 add x9,x0,x9
#endif
 str x9,[x29,#544]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x10,[x29,#1104]
 ldr x12,[x29,#920]
 madd x11,x10,x12,x11
 add x9,x0,x11
#else
 movz x9,#9728
 movk x9,#19,lsl #16
 add x9,x0,x9
#endif
 str x9,[x29,#552]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x10,[x29,#1120]
 ldr x12,[x29,#920]
 madd x11,x10,x12,x11
 add x9,x0,x11
#else
 movz x9,#35520
 movk x9,#21,lsl #16
 add x9,x0,x9
#endif
 str x9,[x29,#560]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x10,[x29,#1136]
 ldr x12,[x29,#920]
 madd x11,x10,x12,x11
 add x9,x0,x11
#else
 movz x9,#46304
 movk x9,#34,lsl #16
 add x9,x0,x9
#endif
 str x9,[x29,#568]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x10,[x29,#1000]
 ldr x12,[x29,#920]
 madd x11,x10,x12,x11
 add x9,x0,x11
#else
 movz x9,#32352
 movk x9,#39,lsl #16
 add x9,x0,x9
#endif
 str x9,[x29,#576]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x10,[x29,#1000]
 ldr x12,[x29,#920]
 madd x11,x10,x12,x11
 add x9,x0,x11
#else
 movz x9,#18400
 movk x9,#44,lsl #16
 add x9,x0,x9
#endif
 str x9,[x29,#584]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x10,[x29,#1112]
 ldr x12,[x29,#920]
 madd x11,x10,x12,x11
 add x9,x0,x11
#else
 movz x9,#44544
 movk x9,#44,lsl #16
 add x9,x0,x9
#endif
 str x9,[x29,#592]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x10,[x29,#1144]
 ldr x12,[x29,#920]
 madd x11,x10,x12,x11
#else
#endif
 ldr x9,[x29,#352]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 movz x16,#4872
#else
 movz x16,#5072
#endif
 add x9,x9,x16
 str x9,[x29,#808]
 ldr x9,[x29,#368]
 movz x16,#152
 movk x16,#24,lsl #16
 add x9,x9,x16
 str x9,[x29,#816]
 add x9,x29,#880
 str x9,[x29,#824]
 str xzr,[x29,#832]
 ldr x9,[x29,#368]
 movz x16,#456
 movk x16,#24,lsl #16
 add x9,x9,x16
 str x9,[x29,#872]
 mov w9,#1
 str w9,[x29,#640]
 str w9,[x29,#668]
 str w9,[x29,#680]
 mov w9,#8
 str w9,[x29,#672]
 mov w9,#2
 str w9,[x29,#676]
 add x0,x29,#672
 add x1,x29,#676
 bl gstats_
 mov w9,#51
 str w9,[x29,#672]
 mov w9,#0
 str w9,[x29,#676]
 add x0,x29,#672
 add x1,x29,#676
 bl gstats_
 ldr x0,[x29,#808]
 ldr x1,[x29,#384]
 ldr x2,[x29,#816]
 ldr x3,[x29,#824]
 add x4,x29,#680
 ldr x5,[x29,#704]
 ldr x6,[x29,#408]
 ldr x7,[x29,#832]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x9,[x29,#952]
 ldr x9,[x9,#48]
 cmp x9,#1
 b.eq .Lruntime_exchange_done
 ldr x0,[x29,#384]
 ldr x1,[x29,#408]
 ldr x2,[x29,#1160]
 ldr x3,[x29,#816]
 add x4,x29,#880
 add x5,x29,#680
 str wzr,[x5]
 ldr x6,[x29,#984]
 ldr x7,[x29,#992]
 bl md2asm_operational_exchange_interpolation_buffer
 cbnz x0,.Lruntime_child_failure
.Lruntime_exchange_done:
 mov w9,#1
 str w9,[x29,#680]
 ldr x0,[x29,#808]
 ldr x1,[x29,#384]
 ldr x2,[x29,#816]
 add x3,x29,#880
 add x4,x29,#680
 ldr x5,[x29,#704]
 ldr x6,[x29,#408]
 mov x7,#0
 add x9,x29,#1240
 str x9,[sp]
 bl md2asm_runtime_fill_polar_halo
 cbnz x0,.Lruntime_child_failure
#else
 bl md2asm_transport_spherical_halo
#endif
 adrp x16,.Lcounts
 add x16,x16,:lo12:.Lcounts
 ldr x17,[x16,#8]
 add x17,x17,#1
 str x17,[x16,#8]
 mov w9,#51
 str w9,[x29,#672]
 mov w9,#1
 str w9,[x29,#676]
 add x0,x29,#672
 add x1,x29,#676
 bl gstats_
 mov w9,#37
 str w9,[x29,#672]
 mov w9,#0
 str w9,[x29,#676]
 add x0,x29,#672
 add x1,x29,#676
 bl gstats_
 mov w9,#1004
 str w9,[x29,#672]
 mov w9,#0
 str w9,[x29,#676]
 add x0,x29,#672
 add x1,x29,#676
 bl gstats_
 mov x21,#0
.Ltrajectory_loop:
 add w9,w21,#1
 str w9,[x29,#648]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x9,[x29,#928]
 ldr x10,[x29,#904]
 msub x9,x21,x10,x9
 cmp x9,x10
 csel x9,x9,x10,lo
#else
 mov w9,#24
 cmp x21,#85
 mov w10,#8
 csel w9,w10,w9,eq
#endif
 str w9,[x29,#644]
 ldr x9,[x29,#712]
 ldr x10,[x29,#720]
 madd x9,x21,x10,x9
 str x9,[x29,#840]
 ldr x0,[x29,#352]
 ldr x1,[x29,#368]
 movz x16,#8
 add x1,x1,x16
 ldr x2,[x29,#368]
 movz x16,#56808
 movk x16,#23,lsl #16
 add x2,x2,x16
 add x3,x29,#640
 add x4,x29,#644
 ldr x5,[x29,#384]
 add x6,x29,#648
 ldr x7,[x29,#408]
 ldr x9,[x29,#416]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1016]
#else
 movz x16,#29376
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#0]
 ldr x9,[x29,#424]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1000]
#else
 movz x16,#3648
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#8]
 ldr x9,[x29,#392]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1128]
#else
 movz x16,#4
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#16]
 ldr x9,[x29,#400]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1128]
#else
 movz x16,#4
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#24]
 ldr x9,[x29,#840]
 str x9,[sp,#32]
 ldr x9,[x29,#544]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1104]
#else
 movz x16,#14592
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#40]
 ldr x9,[x29,#568]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1000]
#else
 movz x16,#3648
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#48]
 ldr x9,[x29,#576]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1000]
#else
 movz x16,#3648
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#56]
 ldr x9,[x29,#464]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1064]
#else
 movz x16,#7296
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#64]
 ldr x9,[x29,#512]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1064]
#else
 movz x16,#7296
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#72]
 ldr x9,[x29,#472]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1072]
#else
 movz x16,#43776
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#80]
 ldr x9,[x29,#520]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1080]
#else
 movz x16,#44160
 movk x16,#3,lsl #16
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#88]
 ldr x9,[x29,#584]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1112]
#else
 movz x16,#304
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#96]
 ldr x9,[x29,#552]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1120]
#else
 movz x16,#1824
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#104]
 ldr x9,[x29,#560]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1136]
#else
 movz x16,#10032
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#112]
 ldr x9,[x29,#528]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1088]
#else
 movz x16,#14592
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#120]
 ldr x9,[x29,#448]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1048]
#else
 movz x16,#21888
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#128]
 ldr x9,[x29,#592]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1144]
#else
 movz x16,#1824
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#136]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 add x9,x29,#1200
 str x9,[sp,#144]
 bl md2asm_runtime_trajectory_interpolation_weights
#else
 bl md2asm_lapinea_7259755
#endif
 adrp x16,.Lcounts
 add x16,x16,:lo12:.Lcounts
 ldr x17,[x16,#16]
 add x17,x17,#1
 str x17,[x16,#16]
 add x21,x21,#1
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x9,[x29,#920]
 cmp x21,x9
#else
 cmp x21,#86
#endif
 b.lo .Ltrajectory_loop
 mov w9,#1004
 str w9,[x29,#672]
 mov w9,#1
 str w9,[x29,#676]
 add x0,x29,#672
 add x1,x29,#676
 bl gstats_
 mov w9,#1005
 str w9,[x29,#672]
 mov w9,#0
 str w9,[x29,#676]
 add x0,x29,#672
 add x1,x29,#676
 bl gstats_
 mov x21,#0
.Linterpolation_loop:
 add w9,w21,#1
 str w9,[x29,#648]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x9,[x29,#928]
 ldr x10,[x29,#904]
 msub x9,x21,x10,x9
 cmp x9,x10
 csel x9,x9,x10,lo
#else
 mov w9,#24
 cmp x21,#85
 mov w10,#8
 csel w9,w10,w9,eq
#endif
 str w9,[x29,#644]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x9,[x29,#904]
 mul x9,x21,x9
#else
 mov w9,#24
 madd w9,w21,w9,wzr
#endif
 add w9,w9,#1
 str w9,[x29,#652]
 ldr x9,[x29,#752]
 ldr x10,[x29,#760]
 madd x9,x21,x10,x9
 str x9,[x29,#848]
 ldr x9,[x29,#768]
 ldr x10,[x29,#776]
 madd x9,x21,x10,x9
 str x9,[x29,#856]
 ldr x9,[x29,#784]
 ldr x10,[x29,#792]
 madd x9,x21,x10,x9
 str x9,[x29,#864]
 ldr x0,[x29,#352]
 ldr x1,[x29,#360]
 ldr x2,[x29,#368]
 ldr x3,[x29,#872]
 add x4,x29,#640
 add x5,x29,#644
 ldr x6,[x29,#384]
 add x7,x29,#652
 add x9,x29,#668
 str x9,[sp,#0]
 add x9,x29,#648
 str x9,[sp,#8]
 ldr x9,[x29,#592]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1144]
#else
 movz x16,#1824
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#16]
 ldr x9,[x29,#464]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1064]
#else
 movz x16,#7296
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#24]
 ldr x9,[x29,#512]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1064]
#else
 movz x16,#7296
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#32]
 ldr x9,[x29,#472]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1072]
#else
 movz x16,#43776
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#40]
 ldr x9,[x29,#520]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1080]
#else
 movz x16,#44160
 movk x16,#3,lsl #16
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#48]
 ldr x9,[x29,#584]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1112]
#else
 movz x16,#304
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#56]
 ldr x9,[x29,#552]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1120]
#else
 movz x16,#1824
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#64]
 ldr x9,[x29,#560]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1136]
#else
 movz x16,#10032
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#72]
 ldr x9,[x29,#568]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1000]
#else
 movz x16,#3648
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#80]
 ldr x9,[x29,#576]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1000]
#else
 movz x16,#3648
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#88]
 ldr x9,[x29,#408]
 str x9,[sp,#96]
 ldr x9,[x29,#376]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1024]
#else
 movz x16,#29184
#endif
 madd x9,x21,x16,x9
 ldr x16,[x29,#744]
 add x9,x9,x16
 str x9,[sp,#104]
 ldr x9,[x29,#528]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1088]
#else
 movz x16,#14592
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#112]
 ldr x9,[x29,#544]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1104]
#else
 movz x16,#14592
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#120]
 ldr x9,[x29,#416]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1016]
#else
 movz x16,#29376
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#128]
 ldr x9,[x29,#432]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1032]
#else
 movz x16,#10944
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#136]
 ldr x9,[x29,#440]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1040]
#else
 movz x16,#192
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#144]
 ldr x9,[x29,#448]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1048]
#else
 movz x16,#21888
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#152]
 ldr x9,[x29,#456]
 str x9,[sp,#160]
 ldr x9,[x29,#848]
 str x9,[sp,#168]
 ldr x9,[x29,#856]
 str x9,[sp,#176]
 ldr x9,[x29,#864]
 str x9,[sp,#184]
 ldr x9,[x29,#480]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1000]
#else
 movz x16,#3648
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#192]
 ldr x9,[x29,#488]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1000]
#else
 movz x16,#3648
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#200]
 ldr x9,[x29,#496]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1000]
#else
 movz x16,#3648
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#208]
 ldr x9,[x29,#504]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x16,[x29,#1096]
#else
 movz x16,#7296
#endif
 madd x9,x21,x16,x9
 str x9,[sp,#216]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 add x9,x29,#1224
 str x9,[sp,#224]
 bl md2asm_runtime_prognostic_departure_update
#else
 bl md2asm_lapineb_7259755
#endif
 adrp x16,.Lcounts
 add x16,x16,:lo12:.Lcounts
 ldr x17,[x16,#24]
 add x17,x17,#1
 str x17,[x16,#24]
 add x21,x21,#1
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldr x9,[x29,#920]
 cmp x21,x9
#else
 cmp x21,#86
#endif
 b.lo .Linterpolation_loop
 mov w9,#1005
 str w9,[x29,#672]
 mov w9,#1
 str w9,[x29,#676]
 add x0,x29,#672
 add x1,x29,#676
 bl gstats_
 ldr x0,[x29,#800]
 bl free
 mov w9,#37
 str w9,[x29,#672]
 mov w9,#1
 str w9,[x29,#676]
 add x0,x29,#672
 add x1,x29,#676
 bl gstats_
 mov w9,#8
 str w9,[x29,#672]
 mov w9,#3
 str w9,[x29,#676]
 add x0,x29,#672
 add x1,x29,#676
 bl gstats_
 adrp x16,.Lcounts
 add x16,x16,:lo12:.Lcounts
 ldr x17,[x16,#0]
 add x17,x17,#1
 str x17,[x16,#0]
#ifdef CALL_SL_EXPLICIT_CONTEXT
 ldp x18,x19,[sp,#256]
 ldp x20,x21,[sp,#272]
 ldp x22,x23,[sp,#288]
 ldp x24,x25,[sp,#304]
 ldp x26,x27,[sp,#320]
 ldp x28,x29,[sp,#336]
 ldr x30,[sp,#352]
 add sp,sp,#1536
#else
 ldr w9,[x29,#664]
 cbz w9,.Lprofile_skip1
 adrp x0,.Lname
 add x0,x0,:lo12:.Lname
 mov w9,#1
 str w9,[x29,#684]
 add x1,x29,#684
 add x2,x29,#656
 mov x3,#7
 bl __yomhook_MOD_dr_hook_default8
.Lprofile_skip1:
 ldp x18,x19,[sp,#224]
 ldp x20,x21,[sp,#240]
 ldp x22,x23,[sp,#256]
 ldp x24,x25,[sp,#272]
 ldp x26,x27,[sp,#288]
 ldp x28,x29,[sp,#304]
 ldr x30,[sp,#320]
 add sp,sp,#1024
#endif
 ret
.Lreject:
 bl abort
 brk #0
#ifdef CALL_SL_EXPLICIT_CONTEXT
.size md2asm_runtime_semi_lagrangian_transport,.-md2asm_runtime_semi_lagrangian_transport
.global md2asm_runtime_call_sl_stage_count_get
.type md2asm_runtime_call_sl_stage_count_get,%function
md2asm_runtime_call_sl_stage_count_get:
#else
.size md2asm_call_sl_7358525,.-md2asm_call_sl_7358525
.global md2asm_call_sl_stage_count_get
.type md2asm_call_sl_stage_count_get,%function
md2asm_call_sl_stage_count_get:
#endif
 cmp w0,#3
 b.hi .Lcount_zero
 adrp x9,.Lcounts
 add x9,x9,:lo12:.Lcounts
 ldr x0,[x9,x0,lsl #3]
 ret
.Lcount_zero:
 mov x0,#0
 ret
.section .rodata
.Lname: .ascii "CALL_SL"
.bss
.p2align 3
.Lcounts: .zero 32
.section .note.GNU-stack,"",%progbits
#ifdef CALL_SL_EXPLICIT_CONTEXT
.text
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
 ldr x3,[x29,#512]
 ldr x4,[x29,#1064]
 ldr x5,[x29,#920]
 mul x4,x4,x5
 cbz x4,.Lruntime_span_next_20
 cbz x3,.Lreject
 tst x3,#7
 b.ne .Lreject
 adds x4,x3,x4
 b.cs .Lreject
 cmp x0,x4
 b.hs .Lruntime_span_next_20
 cmp x3,x2
 b.lo .Lreject
.Lruntime_span_next_20:
 ldr x3,[x29,#520]
 ldr x4,[x29,#1080]
 ldr x5,[x29,#920]
 mul x4,x4,x5
 cbz x4,.Lruntime_span_next_21
 cbz x3,.Lreject
 tst x3,#7
 b.ne .Lreject
 adds x4,x3,x4
 b.cs .Lreject
 cmp x0,x4
 b.hs .Lruntime_span_next_21
 cmp x3,x2
 b.lo .Lreject
.Lruntime_span_next_21:
 ldr x3,[x29,#528]
 ldr x4,[x29,#1088]
 ldr x5,[x29,#920]
 mul x4,x4,x5
 cbz x4,.Lruntime_span_next_22
 cbz x3,.Lreject
 tst x3,#7
 b.ne .Lreject
 adds x4,x3,x4
 b.cs .Lreject
 cmp x0,x4
 b.hs .Lruntime_span_next_22
 cmp x3,x2
 b.lo .Lreject
.Lruntime_span_next_22:
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

.Lruntime_child_failure:
 ldr x0,[x29,#800]
 bl free
 b .Lreject
#else
#endif
