/* GPU contract: skills/md2asm-gpu/references/openifs/setup/hybrid_coordinate_setup.md */
#include "../../support/gpu/preserved_weather_calls.inc.S"
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_hybrid_coordinate_owners
.type md2asm_initialize_hybrid_coordinate_owners,%function
md2asm_initialize_hybrid_coordinate_owners:
 cbz x0,.Lhybrid_reject
 cbz x2,.Lhybrid_reject
 cbz x3,.Lhybrid_reject
 orr x9,x0,x2
 orr x9,x9,x3
 tst x9,#7
 b.ne .Lhybrid_reject
 cmp w1,#256
 b.hi .Lhybrid_reject
 mov w1,w1
 mrs x9,fpcr
 cbnz x9,.Lhybrid_reject
 fmov x9,d0
 tbnz x9,#63,.Lhybrid_reject
 cbz x9,.Lhybrid_reject
 ubfx x10,x9,#52,#11
 cmp x10,#2047
 b.eq .Lhybrid_reject
 adds x11,x0,#512
 b.cs .Lhybrid_reject
 add x9,x1,#1
 lsl x9,x9,#3
 adds x12,x2,x9
 b.cs .Lhybrid_reject
 adds x13,x3,x9
 b.cs .Lhybrid_reject
 cmp x0,x12
 b.hs .Lhybrid_check_second_alias
 cmp x2,x11
 b.lo .Lhybrid_reject
.Lhybrid_check_second_alias:
 cmp x0,x13
 b.hs .Lhybrid_fresh_owners
 cmp x3,x11
 b.lo .Lhybrid_reject
.Lhybrid_fresh_owners:
 mov x9,#0
.Lhybrid_fresh_loop:
 ldr x10,[x0,x9]
 cbnz x10,.Lhybrid_reject
 add x9,x9,#64
 cmp x9,#512
 b.lo .Lhybrid_fresh_loop
 mov x9,#0
.Lhybrid_finite_inputs:
 ldr x10,[x2,x9,lsl#3]
 ubfx x10,x10,#52,#11
 cmp x10,#2047
 b.eq .Lhybrid_reject
 ldr x10,[x3,x9,lsl#3]
 ubfx x10,x10,#52,#11
 cmp x10,#2047
 b.eq .Lhybrid_reject
 add x9,x9,#1
 cmp x9,x1
 b.ls .Lhybrid_finite_inputs
 sub sp,sp,#96
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x18,[sp,#64]
 str d0,[sp,#80]
 mov x29,sp
 mov x19,x0
 mov w20,w1
 mov x21,x2
 mov x22,x3
 adr x25,.Lhybrid_allocation_order
 mov x24,#0
.Lhybrid_allocate:
 ldp w9,w10,[x25]
 add x23,x19,w9,uxtw
 add x0,x20,#1
 sub x0,x0,x10
 lsl x0,x0,#3
 cmp x0,#0
 mov x9,#1
 csel x0,x0,x9,ne
 bl malloc
 cbz x0,.Lhybrid_allocation_failed
 str x0,[x23]
 ldrsw x10,[x25,#4]
 neg x11,x10
 str x11,[x23,#8]
 mov x9,#8
 str x9,[x23,#16]
 str xzr,[x23,#24]
 mov w11,#0x301
 str w11,[x23,#28]
 str x9,[x23,#32]
 mov x9,#1
 str x9,[x23,#40]
 str x10,[x23,#48]
 str x20,[x23,#56]
 add x25,x25,#8
 add x24,x24,#1
 cmp x24,#8
 b.lo .Lhybrid_allocate
 ldr d0,[sp,#80]
 mov x0,x19
 mov w1,w20
 mov x2,x21
 mov x3,x22
 bl md2asm_hybrid_coordinate_setup_gpu_phase
 ldr d0,[sp,#80]
 add x12,x20,#1
 cmp x12,x20
.Lhybrid_ready:
 mov w0,#0
 b .Lhybrid_return
.Lhybrid_allocation_failed:
 mov x0,x19
 bl md2asm_release_hybrid_coordinate_owners
 mov w0,#1
.Lhybrid_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x18,[sp,#64]
 ldp x29,x30,[sp]
 add sp,sp,#96
 ret
.Lhybrid_reject:
 mov w0,#2
 ret
.size md2asm_initialize_hybrid_coordinate_owners,.-md2asm_initialize_hybrid_coordinate_owners
.p2align 4
.global md2asm_release_hybrid_coordinate_owners
.type md2asm_release_hybrid_coordinate_owners,%function
md2asm_release_hybrid_coordinate_owners:
 sub sp,sp,#48
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mov x29,sp
 mov x19,x0
 adr x20,.Lhybrid_allocation_order
 mov x21,#0
.Lhybrid_release:
 ldr w9,[x20]
 ldr x0,[x19,w9,uxtw]
 cbz x0,.Lhybrid_release_next
 bl free
 ldr w9,[x20]
 str xzr,[x19,w9,uxtw]
.Lhybrid_release_next:
 add x20,x20,#8
 add x21,x21,#1
 cmp x21,#8
 b.lo .Lhybrid_release
 ldp x19,x20,[sp,#16]
 ldp x21,x18,[sp,#32]
 ldp x29,x30,[sp]
 add sp,sp,#48
 ret
.size md2asm_release_hybrid_coordinate_owners,.-md2asm_release_hybrid_coordinate_owners
.p2align 3
.Lhybrid_allocation_order:
 .word 128,0,64,0,0,0,192,1,384,1,448,1,256,0,320,0
.section .note.GNU-stack,"",%progbits
