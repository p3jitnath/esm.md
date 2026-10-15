// Solver contract skills/md2asm/references/openifs/setup/local_geometry_maps.md.
// Contract: skills/md2asm/references/openifs/setup/local_geometry_maps.md. x0 Geometry[17096], w1 process=1.
// Own three allocations and copy source maps and radians without FP arithmetic.
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_local_geometry_maps
.type md2asm_initialize_local_geometry_maps,%function
md2asm_initialize_local_geometry_maps:
 cbz x0,.Lreject
 tst x0,#7
 b.ne .Lreject
 cmp w1,#1
 b.ne .Lreject
 ldr w9,[x0,#4888]
 cmn w9,#1
 b.ne .Lreject
 ldr w9,[x0,#4904]
 cmp w9,#34
 b.ne .Lreject
 ldr w9,[x0,#4892]
 cmp w9,#1
 b.ne .Lreject
 ldr w9,[x0,#4876]
 cmp w9,#32
 b.ne .Lreject
 ldr w9,[x0,#4908]
 cmp w9,#32
 b.ne .Lreject
 ldr w9,[x0,#7232]
 cbnz w9,.Lreject
 sub sp,sp,#160
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mrs x9,fpcr
 str x9,[sp,#104]
 mrs x9,fpsr
 str x9,[sp,#112]
 mov x19,x0
 mov x0,#7640
 add x0,x19,x0
 mov w1,#4
 mov w2,#1
 bl .Lcheck_global
 cbz x0,.Lguard_failed
 mov x20,x0
 mov x0,#7768
 add x0,x19,x0
 mov w1,#4
 mov w2,#1
 bl .Lcheck_global
 cbz x0,.Lguard_failed
 mov x21,x0
 mov x0,#4744
 add x0,x19,x0
 mov w1,#8
 mov w2,#3
 bl .Lcheck_global
 cbz x0,.Lguard_failed
 mov x22,x0
 mov x9,#5512
 add x9,x19,x9
 ldr x10,[x9]
 cbz x10,.Lguard_failed
 tst x10,#3
 b.ne .Lguard_failed
 ldr x11,[x9,#8]
 cmn x11,#1
 b.ne .Lguard_failed
 ldr x11,[x9,#16]
 cmp x11,#4
 b.ne .Lguard_failed
 ldrb w11,[x9,#28]
 cmp w11,#1
 b.ne .Lguard_failed
 ldrb w11,[x9,#29]
 cmp w11,#1
 b.ne .Lguard_failed
 ldr x11,[x9,#32]
 cmp x11,#4
 b.ne .Lguard_failed
 ldp x11,x12,[x9,#40]
 cmp x11,#1
 b.ne .Lguard_failed
 cmp x12,#1
 b.ne .Lguard_failed
 ldr x11,[x9,#56]
 cmp x11,#1
 b.ne .Lguard_failed
 ldr w10,[x10]
 mov w26,w10
 cmp w10,#1
 b.ne .Lguard_failed
 bl __errno_location
 str x0,[sp,#120]
 ldr w9,[x0]
 str w9,[sp,#128]
 // NDGSAH=max(NDGSAG,NDGSAL+NFRSTLOFF-48)-NFRSTLOFF.
 ldr w9,[x19,#4892]
 ldr w10,[x19,#7232]
 add w9,w9,w10
 sub w9,w9,#48
 ldr w11,[x19,#4888]
 cmp w9,w11
 csel w9,w9,w11,ge
 sub w9,w9,w10
 str w9,[x19,#4896]
 // NDGENH=min(NDGENG,NDGENL+NFRSTLOFF+48)-NFRSTLOFF.
 ldr w9,[x19,#4908]
 add w9,w9,w10
 add w9,w9,#48
 ldr w11,[x19,#4904]
 cmp w9,w11
 csel w9,w9,w11,le
 sub w9,w9,w10
 str w9,[x19,#4912]
 adrp x23,.Lowners
 add x23,x23,:lo12:.Lowners
 mov w24,#3
.Lrelease_old:
 ldr w25,[x23],#4
 ldr x0,[x19,w25,uxtw]
 cbz x0,.Lold_released
 bl free
.Lold_released:
 str xzr,[x19,w25,uxtw]
 subs w24,w24,#1
 b.ne .Lrelease_old
 mov x0,#512
 bl malloc
 cbz x0,.Lallocation_failed
 mov x1,x0
 mov x0,#7576
 add x0,x19,x0
 mov x2,#4
 mov x3,#1
 mov x4,#-47
 mov x5,#80
 bl .Ldescriptor
 mov x23,x1
 mov x0,#512
 bl malloc
 cbz x0,.Lallocation_failed
 mov x1,x0
 mov x0,#7704
 add x0,x19,x0
 mov x2,#4
 mov x3,#1
 mov x4,#-47
 mov x5,#80
 bl .Ldescriptor
 mov x24,x1
 mov x0,#288
 bl malloc
 cbz x0,.Lallocation_failed
 mov x1,x0
 mov x0,#4808
 add x0,x19,x0
 mov x2,#8
 mov x3,#3
 mov x4,#-1
 mov x5,#34
 bl .Ldescriptor
 mov x25,x1
 mov x9,#-47
.Linteger_loop:
 add x13,x26,x9
 sub x13,x13,#1
 cmn x13,#1
 b.lt .Linteger_next
 cmp x13,#34
 b.gt .Linteger_next
 ldr w10,[x20,x13,lsl #2]
 ldr w11,[x21,x13,lsl #2]
 add x12,x9,#47
 str w10,[x23,x12,lsl #2]
 str w11,[x24,x12,lsl #2]
.Linteger_next:
 add x9,x9,#1
 cmp x9,#80
 b.le .Linteger_loop
 ldrsw x26,[x19,#7232]
 mov x9,#-1
.Llatitude_loop:
 add x13,x9,x26
 ldr x10,[x22,x13,lsl #3]
 add x11,x9,#1
 str x10,[x25,x11,lsl #3]
 add x9,x9,#1
 cmp x9,#34
 b.le .Llatitude_loop
 mov w28,#0
 b .Lreturn_status
.Lallocation_failed:
 adrp x23,.Lowners
 add x23,x23,:lo12:.Lowners
 mov w24,#3
.Lrelease_failed:
 ldr w25,[x23],#4
 ldr x0,[x19,w25,uxtw]
 cbz x0,.Lfailed_released
 bl free
.Lfailed_released:
 str xzr,[x19,w25,uxtw]
 subs w24,w24,#1
 b.ne .Lrelease_failed
 mov w28,#1
.Lreturn_status:
 ldr x9,[sp,#120]
 ldr w10,[sp,#128]
 str w10,[x9]
 b .Lrestore
.Lguard_failed:
 mov w28,#2
.Lrestore:
 ldr x9,[sp,#104]
 msr fpcr,x9
 ldr x9,[sp,#112]
 msr fpsr,x9
 mov w0,w28
 ldr x18,[sp,#96]
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#160
 ret
.Lreject:
 mov w0,#2
 ret
.size md2asm_initialize_local_geometry_maps,.-md2asm_initialize_local_geometry_maps
// x0 rank-one descriptor, w1 element bytes, w2 dtype. Return index-zero address.
.Lcheck_global:
 ldr x9,[x0]
 cbz x9,.Lcheck_failed
 sub w10,w1,#1
 tst x9,x10
 b.ne .Lcheck_failed
 ldr x10,[x0,#16]
 cmp x10,x1
 b.ne .Lcheck_failed
 ldrb w10,[x0,#28]
 cmp w10,#1
 b.ne .Lcheck_failed
 ldrb w10,[x0,#29]
 cmp w10,w2
 b.ne .Lcheck_failed
 ldr x10,[x0,#32]
 cmp x10,x1
 b.ne .Lcheck_failed
 ldp x10,x11,[x0,#40]
 cmp x10,#1
 b.ne .Lcheck_failed
 cmn x11,#2
 b.lt .Lcheck_failed
 cmn x11,#1
 b.gt .Lcheck_failed
 ldr x12,[x0,#56]
 cmp x12,#34
 b.lt .Lcheck_failed
 cmp x12,#35
 b.gt .Lcheck_failed
 ldr x10,[x0,#8]
 add x10,x10,x11
 cbnz x10,.Lcheck_failed
 mul x11,x11,x1
 sub x0,x9,x11
 ret
.Lcheck_failed:
 mov x0,#0
 ret
// x0 descriptor, x1 base, x2 element bytes, x3 dtype, x4 lower, x5 upper.
.Ldescriptor:
 stp x1,xzr,[x0]
 neg x9,x4
 str x9,[x0,#8]
 str x2,[x0,#16]
 str xzr,[x0,#24]
 mov w9,#1
 strb w9,[x0,#28]
 strb w3,[x0,#29]
 str x2,[x0,#32]
 stp x9,x4,[x0,#40]
 str x5,[x0,#56]
 ret
.global sugem3_
.type sugem3_,%function
sugem3_:
 stp x29,x30,[sp,#-32]!
 mov x29,sp
 stp x18,x19,[sp,#16]
 adrp x9,:got:__yommp0_MOD_mysetw
 ldr x9,[x9,:got_lo12:__yommp0_MOD_mysetw]
 ldr w1,[x9]
 bl md2asm_initialize_local_geometry_maps
 cbnz w0,.Lnative_abort
 adrp x9,.Lnative_count
 add x9,x9,:lo12:.Lnative_count
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp],#32
 ret
.Lnative_abort:
 bl abort
.size sugem3_,.-sugem3_
.global md2asm_local_geometry_native_count_get
.type md2asm_local_geometry_native_count_get,%function
md2asm_local_geometry_native_count_get:
 adrp x9,.Lnative_count
 ldr x0,[x9,:lo12:.Lnative_count]
 ret
.size md2asm_local_geometry_native_count_get,.-md2asm_local_geometry_native_count_get
.section .rodata
.p2align 2
.Lowners:
 .word 7576,7704,4808
.bss
.p2align 3
.Lnative_count:
 .zero 8
.section .note.GNU-stack,"",%progbits
