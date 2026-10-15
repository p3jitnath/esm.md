// Construct the23 selected nonblocked SUGEM2 point-geometry owners.
// Contract: skills/md2asm/references/openifs/setup/spherical_point_geometry.md. x0 TGSGEOM1472,
// x1 physical48, x2 latitude sines256, x3 Gaussian weights256; all aligned8.
// Return0 ready,1 allocation failure,2 invalid checked input or associated owner.
// Caller owns all23 successful malloc buffers. Failure frees prior owners and
// clears all data pointers; descriptor bounds written before failure can remain.
// Frame176, alignment16; preserve x18 and required AAPCS64 saved registers.
.macro point_store register,index
    ldr x9, [x19, #(64*\index)]
    str \register, [x9, x28]
.endm
.text
.p2align 4
.global md2asm_initialize_spherical_point_geometry
.type md2asm_initialize_spherical_point_geometry,%function
md2asm_initialize_spherical_point_geometry:
    mrs x9, fpcr
    cbnz x9, .Lpoint_invalid
    cbz x0, .Lpoint_invalid
    cbz x1, .Lpoint_invalid
    cbz x2, .Lpoint_invalid
    cbz x3, .Lpoint_invalid
    orr x9, x0, x1
    orr x9, x9, x2
    orr x9, x9, x3
    tst x9, #7
    b.ne .Lpoint_invalid
    adds x10, x0, #1472
    b.cs .Lpoint_invalid
    adds x9, x1, #48
    b.cs .Lpoint_invalid
    cmp x0, x9
    b.hs .Lpoint_physical_disjoint
    cmp x1, x10
    b.lo .Lpoint_invalid
.Lpoint_physical_disjoint:
    adds x9, x2, #256
    b.cs .Lpoint_invalid
    cmp x0, x9
    b.hs .Lpoint_sines_disjoint
    cmp x2, x10
    b.lo .Lpoint_invalid
.Lpoint_sines_disjoint:
    adds x9, x3, #256
    b.cs .Lpoint_invalid
    cmp x0, x9
    b.hs .Lpoint_weights_disjoint
    cmp x3, x10
    b.lo .Lpoint_invalid
.Lpoint_weights_disjoint:
    ldr x9, [x1]
    movz x10, #0x3ff0, lsl #48
    cmp x9, x10
    b.ne .Lpoint_invalid
    ldr x9, [x1, #8]
    movz x10, #0x4000, lsl #48
    cmp x9, x10
    b.ne .Lpoint_invalid
    ldr x9, [x1, #16]
    cbnz x9, .Lpoint_invalid
    ldr x9, [x1, #24]
    adrp x10, .Lpoint_radius
    ldr x10, [x10, :lo12:.Lpoint_radius]
    cmp x9, x10
    b.ne .Lpoint_invalid
    ldr x9, [x1, #32]
    adrp x10, .Lpoint_pi
    ldr x10, [x10, :lo12:.Lpoint_pi]
    cmp x9, x10
    b.ne .Lpoint_invalid
    ldr x9, [x1, #40]
    movz x10, #0x3e10, lsl #48
    cmp x9, x10
    b.lo .Lpoint_invalid
    movz x10, #0x3f70, lsl #48
    cmp x9, x10
    b.hi .Lpoint_invalid
    mov x9, x0
    mov w10, #23
.Lpoint_association:
    ldr x11, [x9], #64
    cbnz x11, .Lpoint_invalid
    subs w10, w10, #1
    b.ne .Lpoint_association
    stp x29, x30, [sp, #-176]!
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
    mov x21, x2
    mov x22, x3
    mov x9, x0
    add x10, x0, #1472
.Lpoint_clear:
    str xzr, [x9], #8
    cmp x9, x10
    b.lo .Lpoint_clear
    mov x26, #0
.Lpoint_allocate:
    mov x0, #16384
    cmp x26, #21
    b.lo .Lpoint_allocate_size
    mov x0, #8192
.Lpoint_allocate_size:
    bl malloc
    cbz x0, .Lpoint_failed
    add x27, x19, x26, lsl #6
    str x0, [x27]
    mov x9, #-1
    str x9, [x27, #8]
    mov x9, #8
    mov w10, #3
    cmp x26, #21
    b.lo .Lpoint_descriptor_type
    mov x9, #4
    mov w10, #1
.Lpoint_descriptor_type:
    str x9, [x27, #16]
    str x9, [x27, #32]
    mov w11, #1
    strb w11, [x27, #28]
    strb w10, [x27, #29]
    mov x9, #1
    stp x9, x9, [x27, #40]
    mov x9, #2048
    str x9, [x27, #56]
    add x26, x26, #1
    cmp x26, #23
    b.lo .Lpoint_allocate
    mov x23, #0
    mov x25, #0
.Lpoint_latitude:
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
.Lpoint_longitude:
    lsl x28, x25, #3
    point_store d11,0
    point_store d12,1
    point_store d8,2
    point_store d9,3
    lsl w9, w24, #1
    scvtf d0, w9
    ldr d1, [x20, #32]
    fmul d0, d1, d0
    mov w9, #64
    scvtf d1, w9
    fdiv d0, d0, d1
    fmov d1, xzr
    fadd d15, d1, d0
    point_store d15,4
    fmov d0, d8
    bl md2asm_asin_original_rounding
    point_store d0,5
    fmov d0, d15
    bl md2asm_cos_original_rounding
    point_store d0,6
    ldr d1, [x20, #24]
    fmul d1, d1, d9
    fmul d0, d1, d0
    point_store d0,8
    fmov d0, d15
    bl md2asm_sin_original_rounding
    point_store d0,7
    ldr d1, [x20, #24]
    fmul d1, d1, d9
    fmul d0, d1, d0
    point_store d0,9
    ldr d0, [x20, #24]
    fmul d0, d0, d8
    point_store d0,10
    point_store d10,11
    ldr d0, [x20]
    fmul d0, d0, d0
    point_store d0,12
    point_store d13,13
    fmov d0, xzr
    point_store d0,14
    point_store d0,15
    point_store d0,17
    point_store d0,18
    fmov d0, #1.0
    point_store d0,16
    point_store d14,19
    ldr d0, [x22, x23, lsl #3]
    fmul d1, d10, d10
    mov w9, #64
    scvtf d2, w9
    fmul d1, d2, d1
    fdiv d0, d0, d1
    point_store d0,20
    lsl x10, x25, #2
    add w11, w23, #1
    ldr x9, [x19, #(21*64)]
    str w11, [x9, x10]
    add w11, w25, #1
    ldr x9, [x19, #(22*64)]
    str w11, [x9, x10]
    add x25, x25, #1
    add x24, x24, #1
    cmp x24, #64
    b.lo .Lpoint_longitude
    add x23, x23, #1
    cmp x23, #32
    b.lo .Lpoint_latitude
    mov w0, #0
    b .Lpoint_return
.Lpoint_failed:
    mov x26, #0
.Lpoint_free:
    add x27, x19, x26, lsl #6
    ldr x0, [x27]
    str xzr, [x27]
    cbz x0, .Lpoint_next_free
    bl free
.Lpoint_next_free:
    add x26, x26, #1
    cmp x26, #23
    b.lo .Lpoint_free
    mov w0, #1
.Lpoint_return:
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
    ldp x29, x30, [sp], #176
    ret
.Lpoint_invalid:
    mov w0, #2
    ret
.size md2asm_initialize_spherical_point_geometry,.-md2asm_initialize_spherical_point_geometry
.section .rodata
.balign 8
.Lpoint_radius:
    .double 6371229.0
.Lpoint_pi:
    .quad 0x400921fb54442d18
.section .note.GNU-stack,"",%progbits
