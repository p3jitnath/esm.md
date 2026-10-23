/* Distributed setup contract: skills/md2asm/references/openifs/setup/distributed_horizontal_geometry.md. */
// Construct the complete operational SUGEM2 nonblocked computational geometry.
// Contract: skills/md2asm/references/openifs/setup/distributed_horizontal_geometry.md.; x0 record384, x1 physical48,
// x2 latitude sines20480, x3 positive cosines20480 (aligned8), x4 PL10240 (aligned4).
// Return0 ready,1 allocation failure,2 unsupported checked input or associated owner.
// Six malloc owners transfer to the caller. Failure frees earlier owners and
// clears all six pointers, while partial descriptor bounds can remain.
// Frame176, alignment16; preserve x18 and required AAPCS64 saved registers.
.macro operational_computational_store register,index
    ldr x9, [x19, #(64*\index)]
    str \register, [x9, x28]
.endm
.text
.p2align 4
.global md2asm_initialize_distributed_computational_geometry
.type md2asm_initialize_distributed_computational_geometry,%function
md2asm_initialize_distributed_computational_geometry:
    cbz x5,.Loperational_computational_invalid
    cbz x6,.Loperational_computational_invalid
    cbz x0,.Loperational_computational_invalid
    cbz x1,.Loperational_computational_invalid
    cbz x2,.Loperational_computational_invalid
    cbz x3,.Loperational_computational_invalid
    cbz x4,.Loperational_computational_invalid
    ldr w9,[x5,#7376]
    movz w10,#0x2d00
    movk w10,#25,lsl#16
    cmp w9,w10
    b.ne .Loperational_computational_invalid
    mov x9,x0
    mov w10,#6
.Loperational_computational_association:
    ldr x11,[x9],#64
    cbnz x11,.Loperational_computational_invalid
    subs w10,w10,#1
    b.ne .Loperational_computational_association
    stp x29, x30, [sp, #-224]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    str x18, [sp, #96]
    str x4,[sp,#104]
    str x5,[sp,#176]
    ldrsw x8,[x6,#4]
    ldrsw x10,[x5,#7244]
    add x10,x10,#1
    add x6,x5,#4096
    add x6,x6,#1992
    ldp x9,x11,[x6]
    ldr x12,[x6,#64]
    madd x11,x12,x8,x11
    add x11,x11,x10
    add x9,x9,x11,lsl#2
    str x9,[sp,#184]
    add x6,x6,#88
    ldp x9,x11,[x6]
    ldr x12,[x6,#64]
    madd x11,x12,x8,x11
    add x11,x11,x10
    add x9,x9,x11,lsl#2
    str x9,[sp,#192]
    stp d8, d9, [sp, #112]
    stp d10, d11, [sp, #128]
    stp d12, d13, [sp, #144]
    stp d14, d15, [sp, #160]
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    mov x9, x0
    add x10, x0, #384
.Loperational_computational_clear:
    str xzr, [x9], #8
    cmp x9, x10
    b.lo .Loperational_computational_clear
    mov x26, #0
.Loperational_computational_allocate:
    movz x0,#0x6800
    movk x0,#201,lsl#16
    bl malloc
    cbz x0, .Loperational_computational_failed
    add x27, x19, x26, lsl #6
    str x0, [x27]
    mov x9, #-1
    str x9, [x27, #8]
    mov x9, #8
    mov w10, #3
    str x9, [x27, #16]
    str x9, [x27, #32]
    mov w11, #1
    strb w11, [x27, #28]
    strb w10, [x27, #29]
    mov x9, #1
    stp x9, x9, [x27, #40]
    movz x9,#0x2d00
    movk x9,#25,lsl#16
    str x9, [x27, #56]
    add x26, x26, #1
    cmp x26, #6
    b.lo .Loperational_computational_allocate
    mov x23, #0
    mov x25, #0
.Loperational_computational_latitude:
    ldr x9,[sp,#176]
    ldr x10,[x9,#7144]
    ldr w27,[x10,x23,lsl#2]
    sub x27,x27,#1
    ldr x9,[x9,#7896]
    ldr w25,[x9,x23,lsl#2]
    sub x25,x25,#1
    ldr x9,[sp,#104]
    ldr w26,[x9,x27,lsl#2]
    ldr d8,[x21,x27,lsl#3]
    ldr d9,[x22,x27,lsl#3]
    ldr x9,[sp,#184]
    ldr w24,[x9,x23,lsl#2]
    sub w24,w24,#1
    ldr x9,[sp,#192]
    ldr w10,[x9,x23,lsl#2]
    add w10,w10,w24
    str w10,[sp,#200]
    cmp w24,w10
    b.ge .Ldcomp_next_row
.Loperational_computational_longitude:
    lsl x28, x25, #3
    lsl w9, w24, #1
    scvtf d0, w9
    ldr d1, [x20, #32]
    fmul d0, d1, d0
    scvtf d1, w26
    fdiv d0, d0, d1
    fmov d1, xzr
    fadd d15, d1, d0
    fmov d0, d15
    bl md2asm_cos_original_rounding
    operational_computational_store d0,0
    fmov d0, d15
    bl md2asm_sin_original_rounding
    operational_computational_store d0,1
    add w9, w24, #1
    scvtf d0, w9
    operational_computational_store d0,2
    add w9, w27, #1
    scvtf d0, w9
    operational_computational_store d0,3
    ldr d1, [x20, #8]
    fmul d0, d8, d1
    ldr d1, [x20, #16]
    fadd d0, d1, d0
    ldr d1, [x20]
    ldr d2, [x20, #24]
    fmul d1, d1, d2
    fmul d1, d1, d9
    fdiv d0, d0, d1
    operational_computational_store d0,4
    fmov d0, xzr
    operational_computational_store d0,5
    add x25, x25, #1
    add x24, x24, #1
    ldr w9,[sp,#200]
    cmp w24,w9
    b.lo .Loperational_computational_longitude
.Ldcomp_next_row:
    add x23,x23,#1
    ldr x9,[sp,#176]
    ldr w9,[x9,#4908]
    cmp w23,w9
    b.lo .Loperational_computational_latitude
    mov w0, #0
    b .Loperational_computational_return
.Loperational_computational_failed:
    mov x26, #0
.Loperational_computational_free:
    add x27, x19, x26, lsl #6
    ldr x0, [x27]
    str xzr, [x27]
    cbz x0, .Loperational_computational_next_free
    bl free
.Loperational_computational_next_free:
    add x26, x26, #1
    cmp x26, #6
    b.lo .Loperational_computational_free
    mov w0, #1
.Loperational_computational_return:
    ldp d14, d15, [sp, #160]
    ldp d12, d13, [sp, #144]
    ldp d10, d11, [sp, #128]
    ldp d8, d9, [sp, #112]
    ldr x18, [sp, #96]
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #224
    ret
.Loperational_computational_invalid:
    mov w0, #2
    ret
.size md2asm_initialize_distributed_computational_geometry,.-md2asm_initialize_distributed_computational_geometry
.section .rodata
.balign 8
.Loperational_computational_radius:
    .double 6371229.0
.Loperational_computational_pi:
    .quad 0x400921fb54442d18
.section .note.GNU-stack,"",%progbits
