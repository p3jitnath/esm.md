/* Direct source-order SUECRAD RLATI/RIPI child. See skills/md2asm/references/openifs/radiation/radiation_latitude_interpolation.md.
 * x0 mapped RADGRID[1376], x1 capacity. Inputs RLATIG[-1:N+2], even live N2..8192.
 * Return0 ready,1 allocation failure,2 unsupported; frame112 aligned16.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_create_runtime_radiation_latitude_interpolation
.type md2asm_create_runtime_radiation_latitude_interpolation,%function
md2asm_create_runtime_radiation_latitude_interpolation:
 cbz x0,.Lrrli_bad
 tst x0,#7
 b.ne .Lrrli_bad
 cmp x1,#1376
 b.lo .Lrrli_bad
 adds x2,x0,#1376
 b.cs .Lrrli_bad
 mrs x9,fpcr
 cbnz x9,.Lrrli_bad
 ldr w12,[x0,#52]
 cmp w12,#800
 b.eq md2asm_create_operational_radiation_latitude_interpolation
 cmp w12,#2
 b.lo .Lrrli_bad
 mov w9,#8192
 cmp w12,w9
 b.hi .Lrrli_bad
 tbnz w12,#0,.Lrrli_bad
 ldrsw x3,[x0,#44]
 ldrsw x4,[x0,#48]
 cmp x3,x4
 b.gt .Lrrli_bad
 ldrsw x5,[x0,#68]
 cmp x5,x12
 b.hs .Lrrli_bad
 add x9,x3,x5
 cmn x9,#1
 b.lt .Lrrli_bad
 add x9,x4,x5
 add x13,x12,#2
 cmp x9,x13
 b.gt .Lrrli_bad
 ldr x9,[x0,#1160]
 ldr x10,[x0,#1288]
 orr x9,x9,x10
 cbnz x9,.Lrrli_bad
 ldr x6,[x0,#1096]
 cbz x6,.Lrrli_bad
 tst x6,#7
 b.ne .Lrrli_bad
 add x9,x12,#4
 lsl x9,x9,#3
 adds x7,x6,x9
 b.cs .Lrrli_bad
 cmp x6,x2
 b.hs .Lrrli_input_apart
 cmp x0,x7
 b.lo .Lrrli_bad
.Lrrli_input_apart:
 add x10,x0,#1096
 ldr x9,[x10,#8]
 cmp x9,#1
 b.ne .Lrrli_bad
 ldr x9,[x10,#16]
 cmp x9,#8
 b.ne .Lrrli_bad
 ldr x9,[x10,#24]
 ldr x11,=0x0000030100000000
 cmp x9,x11
 b.ne .Lrrli_bad
 ldr x9,[x10,#32]
 cmp x9,#8
 b.ne .Lrrli_bad
 ldr x9,[x10,#40]
 cmp x9,#1
 b.ne .Lrrli_bad
 ldr x9,[x10,#48]
 cmn x9,#1
 b.ne .Lrrli_bad
 ldr x9,[x10,#56]
 add x11,x12,#2
 cmp x9,x11
 b.ne .Lrrli_bad
 sub sp,sp,#112
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x29,sp
 str x12,[sp,#104]
 mov x19,x0
 mov x20,x3
 mov x21,x4
 mov x22,x5
 mov x24,x6
 sub x23,x21,x20
 add x23,x23,#1
 lsl x0,x23,#3
 bl malloc
 cbz x0,.Lrrli_nomem
 mov x25,x0
 mov x9,#24
 mul x0,x23,x9
 bl malloc
 cbz x0,.Lrrli_rollback
 mov x26,x0
 mov x27,#0
 lsl x28,x23,#3
.Lrrli_row:
 add x9,x20,x27
 add x9,x9,x22
 add x10,x9,#1
 ldr x11,[x24,x10,lsl#3]
 str x11,[x25,x27,lsl#3]
 ldr x13,[sp,#104]
 cmp x9,x13
 b.hi .Lrrli_next
 add x10,x24,x10,lsl#3
 ldur d0,[x10,#-8]
 ldr d1,[x10]
 ldr d2,[x10,#8]
 ldr d3,[x10,#16]
 fsub d4,d0,d1
 fsub d5,d0,d2
 fsub d6,d0,d3
 fsub d7,d1,d2
 fsub d1,d1,d3
 fsub d2,d2,d3
 fmul d4,d4,d7
 fmul d4,d4,d1
 fmov d0,#-1.0
 fdiv d4,d0,d4
 fmul d5,d5,d7
 fmul d5,d5,d2
 fmov d3,#1.0
 fdiv d5,d3,d5
 fmul d6,d6,d1
 fmul d6,d6,d2
 fdiv d6,d0,d6
 add x10,x26,x27,lsl#3
 str d4,[x10]
 add x10,x10,x28
 str d5,[x10]
 add x10,x10,x28
 str d6,[x10]
.Lrrli_next:
 add x27,x27,#1
 cmp x27,x23
 b.lo .Lrrli_row
 /* Publish both completed source descriptors. */
 add x9,x19,#1160
 str x25,[x9]
 neg x10,x20
 str x10,[x9,#8]
 mov x10,#8
 str x10,[x9,#16]
 str x10,[x9,#32]
 ldr x10,=0x0000030100000000
 str x10,[x9,#24]
 mov x10,#1
 str x10,[x9,#40]
 str x20,[x9,#48]
 str x21,[x9,#56]
 add x9,x19,#1288
 str x26,[x9]
 neg x10,x20
 sub x10,x10,x23
 str x10,[x9,#8]
 mov x10,#8
 str x10,[x9,#16]
 str x10,[x9,#32]
 ldr x10,=0x0000030200000000
 str x10,[x9,#24]
 mov x10,#1
 str x10,[x9,#40]
 str x20,[x9,#48]
 str x21,[x9,#56]
 str x23,[x9,#64]
 str x10,[x9,#72]
 mov x10,#3
 str x10,[x9,#80]
 mov w0,#0
 b .Lrrli_return
.Lrrli_rollback:
 mov x0,x25
 bl free
.Lrrli_nomem:
 mov w0,#1
.Lrrli_return:
 ldr x18,[sp,#96]
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#112
 ret
.Lrrli_bad:
 mov w0,#2
 ret
.size md2asm_create_runtime_radiation_latitude_interpolation,.-md2asm_create_runtime_radiation_latitude_interpolation
.ltorg

/* Release the two complete owners. Source bounds remain after release. */
.p2align 4
.global md2asm_release_runtime_radiation_latitude_interpolation
.type md2asm_release_runtime_radiation_latitude_interpolation,%function
md2asm_release_runtime_radiation_latitude_interpolation:
#include "shared_radiation_latitude_release_admission.inc.S"
 sub sp,sp,#96
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 str x18,[sp,#48]
 mov x29,sp
 mov x19,x0
 mov x20,x3
 mov x21,x4
 mrs x9,fpcr
 mrs x10,fpsr
 stp x9,x10,[sp,#56]
 bl __errno_location
 mov x22,x0
 ldr w9,[x22]
 str w9,[sp,#72]
 mov x0,x21
 bl free
 str xzr,[x19,#1288]
 mov x0,x20
 bl free
 str xzr,[x19,#1160]
 ldr w9,[sp,#72]
 str w9,[x22]
 ldp x9,x10,[sp,#56]
 msr fpcr,x9
 msr fpsr,x10
 ldr x18,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#96
.Lrrli_released_empty:
 mov w0,#0
 ret
.Lrrli_release_bad:
 mov w0,#2
 ret
.size md2asm_release_runtime_radiation_latitude_interpolation,.-md2asm_release_runtime_radiation_latitude_interpolation
.ltorg
.section .note.GNU-stack,"",%progbits
