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
    mov w10,#\value
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
.global md2asm_initialize_operational_spherical_point_geometry
.type md2asm_initialize_operational_spherical_point_geometry,%function
md2asm_initialize_operational_spherical_point_geometry:
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
    opp_dim 4876,2560
    opp_dim 4892,1
    opp_dim 4908,2560
    opp_dim 4936,5136
    opp_dim 5172,1279
    opp_dim 7244,0
    ldr x9,[x2,#7512]
    ldr x10,[x1]
    cmp x9,x10
    b.ne .Lopp_invalid
    ldr x9,[x2,#7544]
    ldr x10,[x1,#8]
    cmp x9,x10
    b.ne .Lopp_invalid
    ldr x9,[x2,#7552]
    ldr x10,[x1,#16]
    cmp x9,x10
    b.ne .Lopp_invalid
    opp_descriptor 7144,-1,1,2560
    opp_descriptor 7640,1,-1,2562
    opp_descriptor 7896,-1,1,2560
    opp_descriptor 6088,-2563,-1,2562,2
    ldp x9,x10,[x6,#64]
    mov x11,#2564
    cmp x9,x11
    b.ne .Lopp_invalid
    cmp x10,#1
    b.ne .Lopp_invalid
    ldr x9,[x6,#80]
    cmp x9,#1
    b.ne .Lopp_invalid
    opp_descriptor 6176,-2563,-1,2562,2
    ldp x9,x10,[x6,#64]
    mov x11,#2564
    cmp x9,x11
    b.ne .Lopp_invalid
    cmp x10,#1
    b.ne .Lopp_invalid
    ldr x9,[x6,#80]
    cmp x9,#1
    b.ne .Lopp_invalid
    ldr x10,[x2,#7144]
    ldr x11,[x2,#7640]
    add x11,x11,#8
    ldr x12,[x2,#7896]
    ldr x13,[x2,#6088]
    add x13,x13,#8
    ldr x14,[x2,#6176]
    add x14,x14,#8
    mov w6,#0
    mov w7,#1
.Lopp_map_check:
    ldr w9,[x10,x6,lsl#2]
    add w8,w6,#1
    cmp w9,w8
    b.ne .Lopp_invalid
    mov w8,#2559
    sub w8,w8,w6
    cmp w6,w8
    csel w8,w6,w8,lo
    lsl w8,w8,#2
    add w8,w8,#20
    ldr w9,[x11,x6,lsl#2]
    cmp w9,w8
    b.ne .Lopp_invalid
    ldr w9,[x12,x6,lsl#2]
    cmp w9,w7
    b.ne .Lopp_invalid
    ldr w9,[x13,x6,lsl#2]
    cmp w9,#1
    b.ne .Lopp_invalid
    ldr w9,[x14,x6,lsl#2]
    cmp w9,w8
    b.ne .Lopp_invalid
    add w7,w7,w8
    add w6,w6,#1
    cmp w6,#2560
    b.lo .Lopp_map_check
    movz w9,#46081
    movk w9,#100,lsl#16
    cmp w7,w9
    b.ne .Lopp_invalid
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
    movz x0, #40960
    movk x0, #805, lsl #16
    cmp x26, #21
    b.lo .Lopp_allocate_size
    movz x0, #53248
    movk x0, #402, lsl #16
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
    movz x9, #46080
    movk x9, #100, lsl #16
    str x9, [x27, #56]
    add x26, x26, #1
    cmp x26, #23
    b.lo .Lopp_allocate
    mov x23, #0
    mov x25, #0
.Lopp_latitude:
    ldr x9, [sp, #184]
    ldr w26, [x9, x23, lsl #2]
    ldr d0, [x21, x23, lsl #3]
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
    mov x24, #0
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
    ldr d0, [x22, x23, lsl #3]
    fmul d1, d10, d10
    scvtf d2, w26
    fmul d1, d2, d1
    fdiv d0, d0, d1
    opp_store d0,20
    lsl x10, x25, #2
    add w11, w23, #1
    ldr x9, [x19, #(21*64)]
    str w11, [x9, x10]
    mov w11, #5136
    madd w11, w23, w11, w24
    add w11, w11, #1
    ldr x9, [x19, #(22*64)]
    str w11, [x9, x10]
    add x25, x25, #1
    add x24, x24, #1
    cmp x24, x26
    b.lo .Lopp_longitude
    add x23, x23, #1
    cmp x23, #2560
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
.size md2asm_initialize_operational_spherical_point_geometry,.-md2asm_initialize_operational_spherical_point_geometry
.section .rodata
.balign 8
.Lopp_radius:
    .double 6371229.0
.Lopp_pi:
    .quad 0x400921fb54442d18
.section .note.GNU-stack,"",%progbits
