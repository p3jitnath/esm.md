/* Distributed setup contract: skills/md2asm/references/openifs/setup/distributed_horizontal_geometry.md. */
// Direct operational nonblocked SUGEM2 point geometry.
// Contract: skills/md2asm/references/openifs/setup/spherical_point_geometry.md.
// x0 output1472, x1 physical48, x2 complete geometry17096, x3 active MU20480,
// x4 active Gaussian weights20480. All spans are mapped and aligned8.
// Return0 ready,1 allocation failure,2 refusal before mutation. Caller owns23
// successful buffers. Frame208, alignment16; preserve x18 and AAPCS64 registers.
.macro opp_store register,index
    ldr x9, [x19, #(64*\index)]
    str \register, [x9, x28]
.endm
.macro opp_span reg,bytes,mask=7
    cbz \reg,.Lopp_invalid
    tst \reg,#\mask
    b.ne .Lopp_invalid
    mov x9,#\bytes
    adds x10,\reg,x9
    b.cs .Lopp_invalid
    cmp x0,x10
    b.hs .Lopp_span_ok\@
    cmp \reg,x5
    b.lo .Lopp_invalid
.Lopp_span_ok\@:
.endm
.macro opp_dim offset,value
    ldr w9,[x2,#\offset]
    movz w10,#(\value & 65535)
    movk w10,#((\value >> 16) & 65535),lsl#16
    cmp w9,w10
    b.ne .Lopp_invalid
.endm
.macro opp_descriptor offset,origin,lower,upper,rank=1
    mov x9,#\offset
    add x6,x2,x9
    ldr x7,[x6]
    .if \upper == 2562
    opp_span x7,10256,3
    .else
    opp_span x7,10240,3
    .endif
    ldr x9,[x6,#8]
    mov x10,#\origin
    cmp x9,x10
    b.ne .Lopp_invalid
    ldr x9,[x6,#16]
    cmp x9,#4
    b.ne .Lopp_invalid
    ldrb w9,[x6,#28]
    cmp w9,#\rank
    b.ne .Lopp_invalid
    ldrb w9,[x6,#29]
    cmp w9,#1
    b.ne .Lopp_invalid
    ldr x9,[x6,#32]
    cmp x9,#4
    b.ne .Lopp_invalid
    ldr x9,[x6,#40]
    cmp x9,#1
    b.ne .Lopp_invalid
    ldr x9,[x6,#48]
    mov x10,#\lower
    cmp x9,x10
    b.ne .Lopp_invalid
    ldr x9,[x6,#56]
    mov x10,#\upper
    cmp x9,x10
    b.ne .Lopp_invalid
.endm
.text
.p2align 4
.global md2asm_initialize_distributed_spherical_point_geometry
.type md2asm_initialize_distributed_spherical_point_geometry,%function
md2asm_initialize_distributed_spherical_point_geometry:
    mov x15,x5
    mrs x9,fpcr
    cbnz x9,.Lopp_invalid
    cbz x0,.Lopp_invalid
    tst x0,#7
    b.ne .Lopp_invalid
    adds x5,x0,#1472
    b.cs .Lopp_invalid
    opp_span x1,48
    cbz x2,.Lopp_invalid
    tst x2,#7
    b.ne .Lopp_invalid
    mov x9,#17096
    adds x10,x2,x9
    b.cs .Lopp_invalid
    mov x9,#8536
    add x9,x2,x9
    cmp x0,x9
    b.eq .Lopp_geometry_span_ok
    opp_span x2,17096
.Lopp_geometry_span_ok:
    opp_span x3,20480
    opp_span x4,20480
    ldr x9, [x1]
    movz x10, #0x3ff0, lsl #48
    cmp x9, x10
    b.ne .Lopp_invalid
    ldr x9, [x1, #8]
    movz x10, #0x4000, lsl #48
    cmp x9, x10
    b.ne .Lopp_invalid
    ldr x9, [x1, #16]
    cbnz x9, .Lopp_invalid
    ldr x9, [x1, #24]
    adrp x10, .Lopp_radius
    ldr x10, [x10, :lo12:.Lopp_radius]
    cmp x9, x10
    b.ne .Lopp_invalid
    ldr x9, [x1, #32]
    adrp x10, .Lopp_pi
    ldr x10, [x10, :lo12:.Lopp_pi]
    cmp x9, x10
    b.ne .Lopp_invalid
    ldr x9, [x1, #40]
    movz x10, #0x3e10, lsl #48
    cmp x9, x10
    b.lo .Lopp_invalid
    movz x10, #0x3f70, lsl #48
    cmp x9, x10
    b.hi .Lopp_invalid
    opp_dim 4872,2560
    opp_dim 4892,1
    opp_dim 4936,5136
    opp_dim 5172,1279
    opp_dim 7376,1649920
    cbz x15,.Lopp_invalid
    tst x15,#3
    b.ne .Lopp_invalid
    ldr w9,[x15,#4]
    sub w9,w9,#1
    cmp w9,#1
    b.hi .Lopp_invalid
    ldr w9,[x2,#4908]
    cmp w9,#904
    b.eq .Ldpoint_rows
    cmp w9,#754
    b.ne .Lopp_invalid
.Ldpoint_rows:
    mov x9, x0
    mov w10, #23
.Lopp_association:
    ldr x11, [x9], #64
    cbnz x11, .Lopp_invalid
    subs w10, w10, #1
    b.ne .Lopp_association
    stp x29, x30, [sp, #-208]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    str x18, [sp, #96]
    stp d8, d9, [sp, #112]
    stp d10, d11, [sp, #128]
    stp d12, d13, [sp, #144]
    stp d14, d15, [sp, #160]
    mov x19, x0
    mov x20, x1
    mov x21, x3
    mov x22, x4
    str x2, [sp, #176]
    // Select the actual source EW column and global row offset once.
    ldrsw x8,[x15,#4]
    ldrsw x10,[x2,#7244]
    add x10,x10,#1
    add x6,x2,#4096
    add x6,x6,#1992
    ldp x9,x11,[x6]
    ldr x12,[x6,#64]
    madd x11,x12,x8,x11
    add x11,x11,x10
    add x9,x9,x11,lsl#2
    str x9,[sp,#192]
    add x6,x6,#88
    ldp x9,x11,[x6]
    ldr x12,[x6,#64]
    madd x11,x12,x8,x11
    add x11,x11,x10
    add x9,x9,x11,lsl#2
    str x9,[sp,#200]
    ldr x9, [x2, #7640]
    add x9, x9, #8
    str x9, [sp, #184]
    mov x9, x0
    add x10, x0, #1472
.Lopp_clear:
    str xzr, [x9], #8
    cmp x9, x10
    b.lo .Lopp_clear
    mov x26, #0
.Lopp_allocate:
    movz x0,#0x6800
    movk x0,#201,lsl#16
    cmp x26, #21
    b.lo .Lopp_allocate_size
    movz x0,#0xb400
    movk x0,#100,lsl#16
.Lopp_allocate_size:
    bl malloc
    cbz x0, .Lopp_failed
    add x27, x19, x26, lsl #6
    str x0, [x27]
    mov x9, #-1
    str x9, [x27, #8]
    mov x9, #8
    mov w10, #3
    cmp x26, #21
    b.lo .Lopp_descriptor_type
    mov x9, #4
    mov w10, #1
.Lopp_descriptor_type:
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
    cmp x26, #23
    b.lo .Lopp_allocate
    mov x23, #0
    mov x25, #0
.Lopp_latitude:
    ldr x9,[sp,#176]
    ldr x10,[x9,#7144]
    ldr w27,[x10,x23,lsl#2]
    sub x27,x27,#1
    ldr x9,[x9,#7896]
    ldr w25,[x9,x23,lsl#2]
    sub x25,x25,#1
    ldr x9,[sp,#184]
    ldr w26,[x9,x27,lsl#2]
    ldr d0,[x21,x27,lsl#3]
    ldr d1, [x20, #8]
    ldr d2, [x20, #16]
    fmul d3, d1, d0
    fadd d3, d2, d3
    fmul d4, d2, d0
    fadd d4, d1, d4
    fdiv d8, d3, d4
    fmul d0, d8, d8
    fmov d1, #1.0
    fsub d0, d1, d0
    fsqrt d9, d0
    ldr d0, [x20]
    fmov d1, #0.5
    fdiv d1, d1, d0
    fmul d10, d4, d1
    ldr d0, [x20, #40]
    fmov d1, #2.0
    fmul d1, d1, d0
    fmul d11, d1, d8
    fmul d12, d1, d9
    ldr d0, [x20, #24]
    fmul d1, d1, d0
    fmul d13, d1, d9
    fmov d1, #1.0
    fdiv d1, d1, d0
    fneg d1, d1
    fmul d14, d1, d8
    ldr x9,[sp,#192]
    ldr w24,[x9,x23,lsl#2]
    sub w24,w24,#1
    ldr x9,[sp,#200]
    ldr w10,[x9,x23,lsl#2]
    add w10,w10,w24
    str w10,[sp,#104]
    cmp w24,w10
    b.ge .Ldpoint_next_row
.Lopp_longitude:
    lsl x28, x25, #3
    opp_store d11,0
    opp_store d12,1
    opp_store d8,2
    opp_store d9,3
    lsl w9, w24, #1
    scvtf d0, w9
    ldr d1, [x20, #32]
    fmul d0, d1, d0
    scvtf d1, w26
    fdiv d0, d0, d1
    fmov d1, xzr
    fadd d15, d1, d0
    opp_store d15,4
    fmov d0, d8
    bl md2asm_asin_original_rounding
    opp_store d0,5
    fmov d0, d15
    bl md2asm_cos_original_rounding
    opp_store d0,6
    ldr d1, [x20, #24]
    fmul d1, d1, d9
    fmul d0, d1, d0
    opp_store d0,8
    fmov d0, d15
    bl md2asm_sin_original_rounding
    opp_store d0,7
    ldr d1, [x20, #24]
    fmul d1, d1, d9
    fmul d0, d1, d0
    opp_store d0,9
    ldr d0, [x20, #24]
    fmul d0, d0, d8
    opp_store d0,10
    opp_store d10,11
    ldr d0, [x20]
    fmul d0, d0, d0
    opp_store d0,12
    opp_store d13,13
    fmov d0, xzr
    opp_store d0,14
    opp_store d0,15
    opp_store d0,17
    opp_store d0,18
    fmov d0, #1.0
    opp_store d0,16
    opp_store d14,19
    ldr d0, [x22, x27, lsl #3]
    fmul d1, d10, d10
    scvtf d2, w26
    fmul d1, d2, d1
    fdiv d0, d0, d1
    opp_store d0,20
    lsl x10, x25, #2
    add w11, w27, #1
    ldr x9, [x19, #(21*64)]
    str w11, [x9, x10]
    mov w11, #5136
    madd w11, w27, w11, w24
    add w11, w11, #1
    ldr x9, [x19, #(22*64)]
    str w11, [x9, x10]
    add x25, x25, #1
    add x24, x24, #1
    ldr w9,[sp,#104]
    cmp w24,w9
    b.lo .Lopp_longitude
.Ldpoint_next_row:
    add x23,x23,#1
    ldr x9,[sp,#176]
    ldr w9,[x9,#4908]
    cmp w23,w9
    b.lo .Lopp_latitude
    mov w0, #0
    b .Lopp_return
.Lopp_failed:
    mov x26, #0
.Lopp_free:
    add x27, x19, x26, lsl #6
    ldr x0, [x27]
    str xzr, [x27]
    cbz x0, .Lopp_next_free
    bl free
.Lopp_next_free:
    add x26, x26, #1
    cmp x26, #23
    b.lo .Lopp_free
    mov w0, #1
.Lopp_return:
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
    ldp x29, x30, [sp], #208
    ret
.Lopp_invalid:
    mov w0, #2
    ret
.size md2asm_initialize_distributed_spherical_point_geometry,.-md2asm_initialize_distributed_spherical_point_geometry
.section .rodata
.balign 8
.Lopp_radius:
    .double 6371229.0
.Lopp_pi:
    .quad 0x400921fb54442d18
.section .note.GNU-stack,"",%progbits
