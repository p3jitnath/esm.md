/* Direct runtime PHYS_ARRAYS_INI and PHYS_ARRAYS_FIN storage.
 * Contract skills/md2asm/references/openifs/physics/runtime_physics_work_reset.md.
 * Original whole-array positive-zero assignments and live surface-vector extents. */
.text
.p2align 4
.macro CALL target
 str x18,[sp,#3024]
 bl \target
 ldr x18,[sp,#3024]
.endm
.global md2asm_initialize_runtime_physics_work
.type md2asm_initialize_runtime_physics_work,%function
md2asm_initialize_runtime_physics_work:
 mov x16,sp
 sub sp,sp,#8192
 str x29,[sp,#800]
 str x30,[sp,#808]
 mov x29,sp
 str x19,[sp,#816]
 str x20,[sp,#824]
 str x21,[sp,#832]
 str x22,[sp,#840]
 str x23,[sp,#848]
 str x24,[sp,#856]
 str x25,[sp,#864]
 str x26,[sp,#872]
 str x27,[sp,#880]
 str x28,[sp,#888]
 add x19,sp,#1024
 str x0,[x19,#0]
 str x1,[x19,#8]
 str x2,[x19,#16]
 str x3,[x19,#24]
 str x4,[x19,#32]
 str x5,[x19,#40]
 str x6,[x19,#48]
 str x7,[x19,#56]
 ldr x9,[x16,#0]
 str x9,[x19,#64]
 ldr x9,[x16,#8]
 str x9,[x19,#72]
 ldr x9,[x16,#16]
 str x9,[x19,#80]
 ldr x9,[x19,#0]
 cbz x9,.Ldispatch_reject
 tst x9,#7
 b.ne .Ldispatch_reject
 ldr x9,[x19,#8]
 cbz x9,.Ldispatch_reject
 tst x9,#7
 b.ne .Ldispatch_reject
 ldr x9,[x19,#16]
 cbz x9,.Ldispatch_reject
 tst x9,#7
 b.ne .Ldispatch_reject
 ldr x9,[x19,#24]
 cbz x9,.Ldispatch_reject
 tst x9,#7
 b.ne .Ldispatch_reject
 ldr x9,[x19,#32]
 cbz x9,.Ldispatch_reject
 tst x9,#7
 b.ne .Ldispatch_reject
 ldr x9,[x19,#40]
 cbz x9,.Ldispatch_reject
 tst x9,#7
 b.ne .Ldispatch_reject
 ldr x9,[x19,#48]
 cbz x9,.Ldispatch_reject
 tst x9,#7
 b.ne .Ldispatch_reject
 ldr x9,[x19,#56]
 cbz x9,.Ldispatch_reject
 tst x9,#7
 b.ne .Ldispatch_reject
 ldr x9,[x19,#64]
 cbz x9,.Ldispatch_reject
 tst x9,#7
 b.ne .Ldispatch_reject
 ldr x9,[x19,#72]
 cbz x9,.Ldispatch_reject
 tst x9,#7
 b.ne .Ldispatch_reject
 ldr x9,[x19,#80]
 cbz x9,.Ldispatch_reject
 tst x9,#7
 b.ne .Ldispatch_reject
 ldr x9,[x19,#80]
 ldr x10,[x9,#8]
 cbnz x10,.Ldispatch_reject
 ldr x9,[x9]
 cbz x9,.Ldispatch_reject
 tst x9,#3
 b.ne .Ldispatch_reject
 ldr w9,[x9]
 cbnz w9,.Ldispatch_reject
 mrs x9,fpcr
 cbnz x9,.Ldispatch_reject
 ldr x21,[x19,#24]
 ldr w9,[x21,#12]
 cmp w9,#1
 b.lt .Ldispatch_reject
 cmp w9,#1024
 b.gt .Ldispatch_reject
 ldr w9,[x21,#48]
 cmp w9,#1
 b.lt .Ldispatch_reject
 cmp w9,#512
 b.gt .Ldispatch_reject

 ldr x0,[x19,#40]
 bl .Lreset_view
 cbz x2,.Lreset_f96_end
.Lreset_f96_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f96_loop
.Lreset_f96_end:
 ldr x0,[x19,#40]
 mov x16,#112
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f97_end
.Lreset_f97_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f97_loop
.Lreset_f97_end:
 ldr x0,[x19,#40]
 mov x16,#224
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f98_end
.Lreset_f98_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f98_loop
.Lreset_f98_end:
 ldr x0,[x19,#40]
 mov x16,#336
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f99_end
.Lreset_f99_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f99_loop
.Lreset_f99_end:
 ldr x0,[x19,#40]
 mov x16,#448
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f100_end
.Lreset_f100_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f100_loop
.Lreset_f100_end:
 ldr x0,[x19,#40]
 mov x16,#560
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f101_end
.Lreset_f101_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f101_loop
.Lreset_f101_end:
 ldr x0,[x19,#40]
 mov x16,#648
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f102_end
.Lreset_f102_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f102_loop
.Lreset_f102_end:
 ldr x0,[x19,#48]
 mov x16,#1704
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f106_end
.Lreset_f106_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f106_loop
.Lreset_f106_end:
 ldr x0,[x19,#48]
 mov x16,#1792
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f107_end
.Lreset_f107_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f107_loop
.Lreset_f107_end:
 ldr x0,[x19,#48]
 mov x16,#2744
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f108_end
.Lreset_f108_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f108_loop
.Lreset_f108_end:
 ldr x0,[x19,#48]
 mov x16,#2832
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f109_end
.Lreset_f109_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f109_loop
.Lreset_f109_end:
 ldr x0,[x19,#48]
 mov x16,#2920
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f110_end
.Lreset_f110_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f110_loop
.Lreset_f110_end:
 ldr x0,[x19,#48]
 mov x16,#3008
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f111_end
.Lreset_f111_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f111_loop
.Lreset_f111_end:
 ldr x0,[x19,#48]
 mov x16,#3296
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f112_end
.Lreset_f112_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f112_loop
.Lreset_f112_end:
 ldr x0,[x19,#48]
 mov x16,#3408
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f113_end
.Lreset_f113_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f113_loop
.Lreset_f113_end:
 ldr x0,[x19,#48]
 mov x16,#3120
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f114_end
.Lreset_f114_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f114_loop
.Lreset_f114_end:
 ldr x0,[x19,#48]
 mov x16,#3208
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f115_end
.Lreset_f115_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f115_loop
.Lreset_f115_end:
 ldr x0,[x19,#48]
 mov x16,#2272
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f116_end
.Lreset_f116_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f116_loop
.Lreset_f116_end:
 ldr x0,[x19,#48]
 mov x16,#64
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f117_end
.Lreset_f117_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f117_loop
.Lreset_f117_end:
 ldr x0,[x19,#48]
 mov x16,#600
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f118_end
.Lreset_f118_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f118_loop
.Lreset_f118_end:
 ldr x0,[x19,#48]
 mov x16,#3520
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f119_end
.Lreset_f119_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f119_loop
.Lreset_f119_end:
 ldr x0,[x19,#48]
 mov x16,#3584
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f120_end
.Lreset_f120_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f120_loop
.Lreset_f120_end:
 ldr x0,[x19,#48]
 mov x16,#3648
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f121_end
.Lreset_f121_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f121_loop
.Lreset_f121_end:
 ldr x0,[x19,#48]
 mov x16,#2360
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f123_end
.Lreset_f123_loop:
 str wzr,[x0],#4
 subs x2,x2,#1
 b.ne .Lreset_f123_loop
.Lreset_f123_end:
 ldr x0,[x19,#48]
 mov x16,#2552
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f124_end
.Lreset_f124_loop:
 str wzr,[x0],#4
 subs x2,x2,#1
 b.ne .Lreset_f124_loop
.Lreset_f124_end:
 ldr x0,[x19,#48]
 mov x16,#2424
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f125_end
.Lreset_f125_loop:
 str wzr,[x0],#4
 subs x2,x2,#1
 b.ne .Lreset_f125_loop
.Lreset_f125_end:
 ldr x0,[x19,#48]
 mov x16,#2488
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f126_end
.Lreset_f126_loop:
 str wzr,[x0],#4
 subs x2,x2,#1
 b.ne .Lreset_f126_loop
.Lreset_f126_end:
 ldr x0,[x19,#48]
 mov x16,#2616
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f127_end
.Lreset_f127_loop:
 str wzr,[x0],#4
 subs x2,x2,#1
 b.ne .Lreset_f127_loop
.Lreset_f127_end:
 ldr x0,[x19,#48]
 mov x16,#2680
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f128_end
.Lreset_f128_loop:
 str wzr,[x0],#4
 subs x2,x2,#1
 b.ne .Lreset_f128_loop
.Lreset_f128_end:
 ldr x0,[x19,#56]
 mov x16,#11440
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f131_end
.Lreset_f131_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f131_loop
.Lreset_f131_end:
 ldr x0,[x19,#56]
 mov x16,#11528
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f132_end
.Lreset_f132_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f132_loop
.Lreset_f132_end:
 ldr x0,[x19,#56]
 mov x16,#11616
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f133_end
.Lreset_f133_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f133_loop
.Lreset_f133_end:
 ldr x0,[x19,#56]
 mov x16,#11376
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f134_end
.Lreset_f134_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f134_loop
.Lreset_f134_end:
 ldr x0,[x19,#56]
 mov x16,#11312
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f135_end
.Lreset_f135_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f135_loop
.Lreset_f135_end:
 ldr x0,[x19,#56]
 mov x16,#10872
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f136_end
.Lreset_f136_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f136_loop
.Lreset_f136_end:
 ldr x0,[x19,#56]
 mov x16,#11224
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f137_end
.Lreset_f137_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f137_loop
.Lreset_f137_end:
 ldr x0,[x19,#56]
 mov x16,#10960
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f138_end
.Lreset_f138_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f138_loop
.Lreset_f138_end:
 ldr x0,[x19,#56]
 mov x16,#11048
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f139_end
.Lreset_f139_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f139_loop
.Lreset_f139_end:
 ldr x0,[x19,#56]
 mov x16,#11136
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f140_end
.Lreset_f140_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f140_loop
.Lreset_f140_end:
 ldr x0,[x19,#56]
 mov x16,#12888
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f141_end
.Lreset_f141_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f141_loop
.Lreset_f141_end:
 ldr x0,[x19,#56]
 mov x16,#12952
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f142_end
.Lreset_f142_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f142_loop
.Lreset_f142_end:
 ldr x0,[x19,#56]
 mov x16,#13016
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f143_end
.Lreset_f143_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f143_loop
.Lreset_f143_end:
 ldr x0,[x19,#56]
 mov x16,#13080
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f144_end
.Lreset_f144_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f144_loop
.Lreset_f144_end:
 ldr x0,[x19,#56]
 mov x16,#13144
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f145_end
.Lreset_f145_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f145_loop
.Lreset_f145_end:
 ldr x0,[x19,#56]
 mov x16,#13208
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f146_end
.Lreset_f146_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f146_loop
.Lreset_f146_end:
 ldr x0,[x19,#56]
 mov x16,#13272
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f147_end
.Lreset_f147_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f147_loop
.Lreset_f147_end:
 ldr x9,[x19,#8]
 mov x16,#124
 add x9,x9,x16
 ldr w9,[x9]
 cbnz w9,.Lreset_current_done
 ldr x9,[x19,#0]
 mov x16,#9176
 add x9,x9,x16
 ldr x9,[x9]
 ldrsw x20,[x9,#0]
 ldr x0,[x19,#56]
 mov x16,#8728
 add x0,x0,x16
 mov x1,x20
 mov x2,#0
 bl .Ldispatch_first
 str x0,[sp,#1536]
 ldr x9,[sp,#1536]
 ldrsw x10,[x21,#12]
.Lreset_ucur_loop:
 str xzr,[x9],#8
 subs x10,x10,#1
 b.ne .Lreset_ucur_loop
 ldr x9,[x19,#0]
 mov x16,#9184
 add x9,x9,x16
 ldr x9,[x9]
 ldrsw x20,[x9,#0]
 ldr x0,[x19,#56]
 mov x16,#8728
 add x0,x0,x16
 mov x1,x20
 mov x2,#0
 bl .Ldispatch_first
 str x0,[sp,#1536]
 ldr x9,[sp,#1536]
 ldrsw x10,[x21,#12]
.Lreset_vcur_loop:
 str xzr,[x9],#8
 subs x10,x10,#1
 b.ne .Lreset_vcur_loop
.Lreset_current_done:
 ldr x9,[x19,#0]
 mov x16,#14424
 add x9,x9,x16
 ldr x9,[x9]
 ldrsw x20,[x9,#0]
 ldr x0,[x19,#56]
 mov x16,#8992
 add x0,x0,x16
 mov x1,x20
 mov x2,#0
 bl .Ldispatch_first
 str x0,[sp,#1536]
 ldr x9,[sp,#1536]
 ldrsw x10,[x21,#12]
.Lreset_s155_loop:
 str xzr,[x9],#8
 subs x10,x10,#1
 b.ne .Lreset_s155_loop
 ldr x9,[x19,#0]
 mov x16,#14432
 add x9,x9,x16
 ldr x9,[x9]
 ldrsw x20,[x9,#0]
 ldr x0,[x19,#56]
 mov x16,#8992
 add x0,x0,x16
 mov x1,x20
 mov x2,#0
 bl .Ldispatch_first
 str x0,[sp,#1536]
 ldr x9,[sp,#1536]
 ldrsw x10,[x21,#12]
.Lreset_s156_loop:
 str xzr,[x9],#8
 subs x10,x10,#1
 b.ne .Lreset_s156_loop
 ldr x9,[x19,#0]
 mov x16,#14440
 add x9,x9,x16
 ldr x9,[x9]
 ldrsw x20,[x9,#0]
 ldr x0,[x19,#56]
 mov x16,#8992
 add x0,x0,x16
 mov x1,x20
 mov x2,#0
 bl .Ldispatch_first
 str x0,[sp,#1536]
 ldr x9,[sp,#1536]
 ldrsw x10,[x21,#12]
.Lreset_s157_loop:
 str xzr,[x9],#8
 subs x10,x10,#1
 b.ne .Lreset_s157_loop
 ldr x9,[x19,#0]
 mov x16,#14448
 add x9,x9,x16
 ldr x9,[x9]
 ldrsw x20,[x9,#0]
 ldr x0,[x19,#56]
 mov x16,#8992
 add x0,x0,x16
 mov x1,x20
 mov x2,#0
 bl .Ldispatch_first
 str x0,[sp,#1536]
 ldr x9,[sp,#1536]
 ldrsw x10,[x21,#12]
.Lreset_s158_loop:
 str xzr,[x9],#8
 subs x10,x10,#1
 b.ne .Lreset_s158_loop
 ldr x9,[x19,#0]
 mov x16,#14456
 add x9,x9,x16
 ldr x9,[x9]
 ldrsw x20,[x9,#0]
 ldr x0,[x19,#56]
 mov x16,#8992
 add x0,x0,x16
 mov x1,x20
 mov x2,#0
 bl .Ldispatch_first
 str x0,[sp,#1536]
 ldr x9,[sp,#1536]
 ldrsw x10,[x21,#12]
.Lreset_s159_loop:
 str xzr,[x9],#8
 subs x10,x10,#1
 b.ne .Lreset_s159_loop
 ldr x9,[x19,#0]
 mov x16,#14464
 add x9,x9,x16
 ldr x9,[x9]
 ldrsw x20,[x9,#0]
 ldr x0,[x19,#56]
 mov x16,#8992
 add x0,x0,x16
 mov x1,x20
 mov x2,#0
 bl .Ldispatch_first
 str x0,[sp,#1536]
 ldr x9,[sp,#1536]
 ldrsw x10,[x21,#12]
.Lreset_s160_loop:
 str xzr,[x9],#8
 subs x10,x10,#1
 b.ne .Lreset_s160_loop
 ldr x9,[x19,#0]
 mov x16,#14472
 add x9,x9,x16
 ldr x9,[x9]
 ldrsw x20,[x9,#0]
 ldr x0,[x19,#56]
 mov x16,#8992
 add x0,x0,x16
 mov x1,x20
 mov x2,#0
 bl .Ldispatch_first
 str x0,[sp,#1536]
 ldr x9,[sp,#1536]
 ldrsw x10,[x21,#12]
.Lreset_s161_loop:
 str xzr,[x9],#8
 subs x10,x10,#1
 b.ne .Lreset_s161_loop
 ldr x9,[x19,#0]
 mov x16,#14488
 add x9,x9,x16
 ldr x9,[x9]
 ldrsw x20,[x9,#0]
 ldr x0,[x19,#56]
 mov x16,#8992
 add x0,x0,x16
 mov x1,x20
 mov x2,#0
 bl .Ldispatch_first
 str x0,[sp,#1536]
 ldr x9,[sp,#1536]
 ldrsw x10,[x21,#12]
.Lreset_s162_loop:
 str xzr,[x9],#8
 subs x10,x10,#1
 b.ne .Lreset_s162_loop
 ldr x9,[x19,#0]
 mov x16,#14496
 add x9,x9,x16
 ldr x9,[x9]
 ldrsw x20,[x9,#0]
 ldr x0,[x19,#56]
 mov x16,#8992
 add x0,x0,x16
 mov x1,x20
 mov x2,#0
 bl .Ldispatch_first
 str x0,[sp,#1536]
 ldr x9,[sp,#1536]
 ldrsw x10,[x21,#12]
.Lreset_s163_loop:
 str xzr,[x9],#8
 subs x10,x10,#1
 b.ne .Lreset_s163_loop
 ldr x9,[x19,#0]
 mov x16,#14512
 add x9,x9,x16
 ldr x9,[x9]
 ldrsw x20,[x9,#0]
 ldr x0,[x19,#56]
 mov x16,#8992
 add x0,x0,x16
 mov x1,x20
 mov x2,#0
 bl .Ldispatch_first
 str x0,[sp,#1536]
 ldr x9,[sp,#1536]
 ldrsw x10,[x21,#12]
.Lreset_s165_loop:
 str xzr,[x9],#8
 subs x10,x10,#1
 b.ne .Lreset_s165_loop
 ldr x9,[x19,#0]
 mov x16,#14520
 add x9,x9,x16
 ldr x9,[x9]
 ldrsw x20,[x9,#0]
 ldr x0,[x19,#56]
 mov x16,#8992
 add x0,x0,x16
 mov x1,x20
 mov x2,#0
 bl .Ldispatch_first
 str x0,[sp,#1536]
 ldr x9,[sp,#1536]
 ldrsw x10,[x21,#12]
.Lreset_s166_loop:
 str xzr,[x9],#8
 subs x10,x10,#1
 b.ne .Lreset_s166_loop
 ldr x9,[x19,#0]
 mov x16,#14528
 add x9,x9,x16
 ldr x9,[x9]
 ldrsw x20,[x9,#0]
 ldr x0,[x19,#56]
 mov x16,#8992
 add x0,x0,x16
 mov x1,x20
 mov x2,#0
 bl .Ldispatch_first
 str x0,[sp,#1536]
 ldr x9,[sp,#1536]
 ldrsw x10,[x21,#12]
.Lreset_s167_loop:
 str xzr,[x9],#8
 subs x10,x10,#1
 b.ne .Lreset_s167_loop
 ldr x9,[x19,#0]
 mov x16,#14536
 add x9,x9,x16
 ldr x9,[x9]
 ldrsw x20,[x9,#0]
 ldr x0,[x19,#56]
 mov x16,#8992
 add x0,x0,x16
 mov x1,x20
 mov x2,#0
 bl .Ldispatch_first
 str x0,[sp,#1536]
 ldr x9,[sp,#1536]
 ldrsw x10,[x21,#12]
.Lreset_s169_loop:
 str xzr,[x9],#8
 subs x10,x10,#1
 b.ne .Lreset_s169_loop
 ldr x9,[x19,#0]
 mov x16,#14544
 add x9,x9,x16
 ldr x9,[x9]
 ldrsw x20,[x9,#0]
 ldr x0,[x19,#56]
 mov x16,#8992
 add x0,x0,x16
 mov x1,x20
 mov x2,#0
 bl .Ldispatch_first
 str x0,[sp,#1536]
 ldr x9,[sp,#1536]
 ldrsw x10,[x21,#12]
.Lreset_s170_loop:
 str xzr,[x9],#8
 subs x10,x10,#1
 b.ne .Lreset_s170_loop
 ldr x0,[x19,#72]
 mov x16,#440
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f174_end
.Lreset_f174_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f174_loop
.Lreset_f174_end:
 ldr x0,[x19,#72]
 mov x16,#528
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f175_end
.Lreset_f175_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f175_loop
.Lreset_f175_end:
 ldr x0,[x19,#72]
 mov x16,#880
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f176_end
.Lreset_f176_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f176_loop
.Lreset_f176_end:
 ldr x0,[x19,#72]
 mov x16,#792
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f177_end
.Lreset_f177_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f177_loop
.Lreset_f177_end:
 ldr x0,[x19,#72]
 mov x16,#2816
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f178_end
.Lreset_f178_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f178_loop
.Lreset_f178_end:
 ldr x0,[x19,#72]
 mov x16,#2728
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f179_end
.Lreset_f179_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f179_loop
.Lreset_f179_end:
 ldr x0,[x19,#72]
 mov x16,#2904
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f180_end
.Lreset_f180_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f180_loop
.Lreset_f180_end:
 ldr x0,[x19,#72]
 mov x16,#2992
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f181_end
.Lreset_f181_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f181_loop
.Lreset_f181_end:
 ldr x0,[x19,#72]
 mov x16,#968
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f182_end
.Lreset_f182_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f182_loop
.Lreset_f182_end:
 ldr x0,[x19,#72]
 mov x16,#1056
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f183_end
.Lreset_f183_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f183_loop
.Lreset_f183_end:
 ldr x0,[x19,#72]
 mov x16,#3080
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f184_end
.Lreset_f184_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f184_loop
.Lreset_f184_end:
 ldr x0,[x19,#72]
 mov x16,#3168
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f185_end
.Lreset_f185_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f185_loop
.Lreset_f185_end:
 ldr x0,[x19,#72]
 mov x16,#2552
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f186_end
.Lreset_f186_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f186_loop
.Lreset_f186_end:
 ldr x0,[x19,#72]
 mov x16,#2640
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f187_end
.Lreset_f187_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f187_loop
.Lreset_f187_end:
 ldr x0,[x19,#72]
 mov x16,#1144
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f188_end
.Lreset_f188_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f188_loop
.Lreset_f188_end:
 ldr x0,[x19,#72]
 mov x16,#1232
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f189_end
.Lreset_f189_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f189_loop
.Lreset_f189_end:
 ldr x0,[x19,#72]
 mov x16,#1320
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f190_end
.Lreset_f190_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f190_loop
.Lreset_f190_end:
 ldr x0,[x19,#72]
 mov x16,#1408
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f191_end
.Lreset_f191_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f191_loop
.Lreset_f191_end:
 ldr x0,[x19,#72]
 mov x16,#704
 add x0,x0,x16
 bl .Lreset_view
 cbz x2,.Lreset_f192_end
.Lreset_f192_loop:
 str xzr,[x0],#8
 subs x2,x2,#1
 b.ne .Lreset_f192_loop
.Lreset_f192_end:

 mov w0,#0
 ldr x19,[sp,#816]
 ldr x20,[sp,#824]
 ldr x21,[sp,#832]
 ldr x22,[sp,#840]
 ldr x23,[sp,#848]
 ldr x24,[sp,#856]
 ldr x25,[sp,#864]
 ldr x26,[sp,#872]
 ldr x27,[sp,#880]
 ldr x28,[sp,#888]
 ldr x29,[sp,#800]
 ldr x30,[sp,#808]
 add sp,sp,#8192
 ret
.size md2asm_initialize_runtime_physics_work,.-md2asm_initialize_runtime_physics_work
.global md2asm_finish_runtime_physics_work
.type md2asm_finish_runtime_physics_work,%function
md2asm_finish_runtime_physics_work:
 mov x16,sp
 sub sp,sp,#8192
 str x29,[sp,#800]
 str x30,[sp,#808]
 mov x29,sp
 str x19,[sp,#816]
 str x20,[sp,#824]
 str x21,[sp,#832]
 str x22,[sp,#840]
 str x23,[sp,#848]
 str x24,[sp,#856]
 str x25,[sp,#864]
 str x26,[sp,#872]
 str x27,[sp,#880]
 str x28,[sp,#888]
 add x19,sp,#1024
 str x0,[x19,#0]
 str x1,[x19,#8]
 str x2,[x19,#16]
 str x3,[x19,#24]
 str x4,[x19,#32]
 str x5,[x19,#40]
 str x6,[x19,#48]
 str x7,[x19,#56]
 ldr x9,[x19,#0]
 cbz x9,.Ldispatch_reject
 tst x9,#7
 b.ne .Ldispatch_reject
 ldr x9,[x19,#8]
 cbz x9,.Ldispatch_reject
 tst x9,#7
 b.ne .Ldispatch_reject
 ldr x9,[x19,#16]
 cbz x9,.Ldispatch_reject
 tst x9,#7
 b.ne .Ldispatch_reject
 ldr x9,[x19,#24]
 cbz x9,.Ldispatch_reject
 tst x9,#7
 b.ne .Ldispatch_reject
 ldr x9,[x19,#32]
 cbz x9,.Ldispatch_reject
 tst x9,#7
 b.ne .Ldispatch_reject
 ldr x9,[x19,#40]
 cbz x9,.Ldispatch_reject
 tst x9,#7
 b.ne .Ldispatch_reject
 ldr x9,[x19,#48]
 cbz x9,.Ldispatch_reject
 tst x9,#7
 b.ne .Ldispatch_reject
 ldr x9,[x19,#56]
 cbz x9,.Ldispatch_reject
 tst x9,#7
 b.ne .Ldispatch_reject
 ldr x9,[x19,#56]
 ldr x10,[x9,#8]
 cbnz x10,.Ldispatch_reject
 ldr x9,[x9]
 cbz x9,.Ldispatch_reject
 tst x9,#3
 b.ne .Ldispatch_reject
 ldr w9,[x9]
 cbnz w9,.Ldispatch_reject
 mrs x9,fpcr
 cbnz x9,.Ldispatch_reject
 ldr x21,[x19,#0]
 ldr w9,[x21,#12]
 cmp w9,#1
 b.lt .Ldispatch_reject
 cmp w9,#1024
 b.gt .Ldispatch_reject
 ldr w9,[x21,#48]
 cmp w9,#1
 b.lt .Ldispatch_reject
 cmp w9,#512
 b.gt .Ldispatch_reject


 mov w0,#0
 ldr x19,[sp,#816]
 ldr x20,[sp,#824]
 ldr x21,[sp,#832]
 ldr x22,[sp,#840]
 ldr x23,[sp,#848]
 ldr x24,[sp,#856]
 ldr x25,[sp,#864]
 ldr x26,[sp,#872]
 ldr x27,[sp,#880]
 ldr x28,[sp,#888]
 ldr x29,[sp,#800]
 ldr x30,[sp,#808]
 add sp,sp,#8192
 ret
.size md2asm_finish_runtime_physics_work,.-md2asm_finish_runtime_physics_work
// Return a complete contiguous source view and its total element count.
.Lreset_view:
mov x15,x30
mov x14,x0
ldrb w13,[x0,#28]
mov x2,#1
add x12,x0,#48
.Lreset_extent:
ldr x9,[x12]
ldr x10,[x12,#8]
sub x10,x10,x9
add x10,x10,#1
cmp x10,#0
csel x10,x10,xzr,gt
mul x2,x2,x10
add x12,x12,#24
subs w13,w13,#1
b.ne .Lreset_extent
str x2,[sp,#3072]
mov x1,#0
mov x2,#0
bl .Ldispatch_first
ldr x2,[sp,#3072]
mov x30,x15
ret
// Read the first declared element. A null zero-size view stays null.
.Ldispatch_first:
ldr x8,[x0]
cbnz x8,1f
mov x0,#0
ret
1:
ldr x9,[x0,#8]
ldrb w10,[x0,#28]
ldr x11,[x0,#40]
ldr x12,[x0,#48]
madd x9,x11,x12,x9
cmp w10,#1
b.eq .Ldispatch_first_done
ldr x11,[x0,#64]
ldr x12,[x0,#72]
cmp x1,#0
csel x12,x12,x1,eq
madd x9,x11,x12,x9
cmp w10,#2
b.eq .Ldispatch_first_done
ldr x11,[x0,#88]
ldr x12,[x0,#96]
cmp x2,#0
csel x12,x12,x2,eq
madd x9,x11,x12,x9
cmp w10,#3
b.eq .Ldispatch_first_done
ldr x11,[x0,#112]
ldr x12,[x0,#120]
madd x9,x11,x12,x9
.Ldispatch_first_done:
ldr x11,[x0,#32]
madd x0,x9,x11,x8
ret
.Ldispatch_reject:
 mov w0,#2
 ldr x19,[sp,#816]
 ldr x20,[sp,#824]
 ldr x21,[sp,#832]
 ldr x22,[sp,#840]
 ldr x23,[sp,#848]
 ldr x24,[sp,#856]
 ldr x25,[sp,#864]
 ldr x26,[sp,#872]
 ldr x27,[sp,#880]
 ldr x28,[sp,#888]
 ldr x29,[sp,#800]
 ldr x30,[sp,#808]
 add sp,sp,#8192
 ret
.section .rodata
.p2align 2
.Ldispatch_phase0:.word 0
.Ldispatch_phase1:.word 1
.Lphys_arrays_ini_name:.ascii "PHYS_ARRAYS_INI"
.Lphys_arrays_fin_name:.ascii "PHYS_ARRAYS_FIN"
.section .note.GNU-stack,"",%progbits
