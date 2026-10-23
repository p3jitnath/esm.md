/* Distributed setup contract: skills/md2asm/references/openifs/setup/distributed_horizontal_geometry.md. */
// Contract: skills/md2asm/references/openifs/setup/spherical_grid_setup.md.
// Direct selected spherical SUGEM1B calculation and NSTAGP allocation.
// Contract: skills/md2asm/references/openifs/setup/spherical_grid_setup.md. x0: raw GEOMETRY, x1: physical
// inputs {int32 MYSETW, MY_REGION_EW; double pi, radius_metres}.
// Return w0: 0 ready, 1 malloc failure, 2 unsupported shape/stretch.
// Before success NSTAGP is unassociated; caller owns the new malloc buffer.
.text
.p2align 4
.global md2asm_initialize_spherical_grid
.type md2asm_initialize_spherical_grid,%function
md2asm_initialize_spherical_grid:
    // Check this selected shape and stretch before changing any output.
    mov x3, #7512
    ldr d2, [x0, x3]
    fmov d3, #1.0
    fcmp d2, d3
    b.ne .Lgrid_unsupported
    mov x3, #4872
    ldr w4, [x0, x3]
    sub w5, w4, #1
    cmp w5, #31
    b.hi .Lgrid_unsupported
    ldr w5, [x0, #4876]
    cmp w5, #1
    b.lt .Lgrid_unsupported
    cmp w5, w4
    b.gt .Lgrid_unsupported
    ldr w4, [x0, #4936]
    sub w4, w4, #1
    cmp w4, #63
    b.hi .Lgrid_unsupported
    ldr w4, [x0, #4892]
    cmp w4, #1
    b.lt .Lgrid_unsupported
    ldr w5, [x0, #4908]
    sub w6, w5, w4
    cmp w6, #31
    b.hi .Lgrid_unsupported
    mov x3, #7896
    ldr x4, [x0, x3]
    cbnz x4, .Lgrid_unsupported
.Lgrid_construct:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    str x18, [sp, #48]
    mov x19, x0
    mov x20, x1
    add w21, w6, #1
    uxtw x0, w21
    lsl x0, x0, #2
    bl malloc
    cbz x0, .Lgrid_allocation_failed
    mov x3, #7896
    add x22, x19, x3
    // Construct the integer rank-one descriptor without a type constructor.
    str x0, [x22]
    ldrsw x4, [x19, #4892]
    neg x5, x4
    str x5, [x22, #8]
    mov x5, #4
    str x5, [x22, #16]
    str xzr, [x22, #24]
    mov w6, #1
    strb w6, [x22, #28]
    strb w6, [x22, #29]
    str x5, [x22, #32]
    mov x5, #1
    stp x5, x4, [x22, #40]
    ldrsw x4, [x19, #4908]
    str x4, [x22, #56]
    // Keep the source's separately rounded arithmetic dependencies.
    ldp d0, d1, [x20, #8]
    ldr w4, [x19, #4872]
    scvtf d2, w4
    fmov d3, #4.0
    fmul d2, d3, d2
    fmov d4, #2.0
    fadd d2, d2, d4
    fmul d3, d3, d0
    fdiv d2, d2, d3
    str d2, [x19, #7536]
    ldr d2, [x19, #7512]
    fmul d3, d2, d2
    fmov d4, #1.0
    fadd d3, d3, d4
    str d3, [x19, #7544]
    fmul d3, d2, d2
    fsub d3, d3, d4
    str d3, [x19, #7552]
    str xzr, [x19, #7560]
    fmov d3, #3.0
    fsqrt d3, d3
    ldr d2, [x19, #7496]
    fdiv d2, d2, d3
    str d2, [x19, #7568]
    // Build pointers for index zero using each descriptor's signed offset.
    mov x3, #5512
    add x3, x19, x3
    ldp x4, x5, [x3]
    ldr x6, [x3, #40]
    ldrsw x7, [x20]
    madd x5, x6, x7, x5
    ldr w21, [x4, x5, lsl #2]
    sub w21, w21, #1
    mov x3, #7576
    add x3, x19, x3
    ldp x4, x5, [x3]
    add x4, x4, x5, lsl #2
    ldr x5, [x3, #40]
    ldp x6, x7, [x3, #64]
    add x6, x6, x7, lsl #2
    ldr x7, [x3, #104]
    ldp x8, x9, [x3, #128]
    add x8, x8, x9, lsl #2
    ldr x9, [x3, #168]
    ldp x10, x11, [x3, #192]
    add x10, x10, x11, lsl #2
    ldr x11, [x3, #232]
    mov x12, #1
    ldrsw x13, [x19, #4876]
.Lgrid_copy_latitude:
    add w14, w21, w12
    sxtw x14, w14
    mul x15, x14, x11
    ldr w16, [x10, x15, lsl #2]
    mul x15, x12, x9
    str w16, [x8, x15, lsl #2]
    mul x15, x14, x7
    ldr w16, [x6, x15, lsl #2]
    mul x15, x12, x5
    str w16, [x4, x15, lsl #2]
    add x12, x12, #1
    cmp x12, x13
    b.le .Lgrid_copy_latitude
    // NONL has two index dimensions. Keep its declared strides.
    mov x3, #6176
    add x3, x19, x3
    ldp x4, x5, [x3]
    ldr x6, [x3, #40]
    ldr x7, [x3, #64]
    ldrsw x8, [x20, #4]
    madd x5, x7, x8, x5
    add x4, x4, x5, lsl #2
    ldrsw x7, [x19, #7244]
    ldrsw x8, [x19, #4892]
    ldrsw x9, [x19, #4908]
    ldr x10, [x22]
    mov w11, #1
.Lgrid_latitude_start:
    add w12, w7, w8
    sxtw x12, w12
    mul x12, x12, x6
    ldr w13, [x4, x12, lsl #2]
    cmp w13, #0
    b.le .Lgrid_inactive_latitude
    str w11, [x10], #4
    add w11, w11, w13
    b .Lgrid_next_latitude
.Lgrid_inactive_latitude:
    str wzr, [x10], #4
.Lgrid_next_latitude:
    add x8, x8, #1
    cmp x8, x9
    b.le .Lgrid_latitude_start
    fmov d2, #2.0
    fmul d2, d2, d0
    fmul d2, d2, d1
    ldr w4, [x19, #4936]
    scvtf d3, w4
    fdiv d2, d2, d3
    str d2, [x19, #7480]
    mov w0, #0
    b .Lgrid_return
.Lgrid_allocation_failed:
    mov w0, #1
.Lgrid_return:
    ldr x18, [sp, #48]
    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x29, x30, [sp], #64
    ret
.Lgrid_unsupported:
    mov w0, #2
    ret
.size md2asm_initialize_spherical_grid,.-md2asm_initialize_spherical_grid

/* Operational one-process entry. The accepted arithmetic body is shared. */
.p2align 4
.global md2asm_initialize_distributed_spherical_grid
.type md2asm_initialize_distributed_spherical_grid,%function
md2asm_initialize_distributed_spherical_grid:
    cbz x0,.Lgrid_operational_reject
    cbz x1,.Lgrid_operational_reject
    orr x9,x0,x1
    tst x9,#7
    b.ne .Lgrid_operational_reject
    mrs x9,fpcr
    cbnz x9,.Lgrid_operational_reject
    ldr w4,[x0,#4872]
    mov w5,#2560
    cmp w4,w5
    b.ne .Lgrid_operational_reject
    ldr w4,[x0,#4876]
    cmp w4,#1279
    b.eq .Ldg_wave_rows
    cmp w4,#1281
    b.ne .Lgrid_operational_reject
.Ldg_wave_rows:
    ldr w4,[x0,#4892]
    cmp w4,#1
    b.ne .Lgrid_operational_reject
    ldr w4,[x0,#4908]
    cmp w4,#904
    b.eq .Ldg_physical_rows
    cmp w4,#754
    b.ne .Lgrid_operational_reject
.Ldg_physical_rows:
    ldr w4,[x0,#5144]
    cmp w4,#17
    b.ne .Lgrid_operational_reject
    ldr w4,[x0,#5160]
    movz w5,#31519
    movk w5,#1,lsl#16
    cmp w4,w5
    b.ne .Lgrid_operational_reject
    ldp w4,w5,[x1]
    sub w4,w4,#1
    sub w5,w5,#1
    cmp w4,#1
    b.hi .Lgrid_operational_reject
    cmp w5,#1
    b.hi .Lgrid_operational_reject
    ldr x4,[x0,#7512]
    mov x5,#0x3ff0000000000000
    cmp x4,x5
    b.ne .Lgrid_operational_reject
    ldr x4,[x0,#7896]
    cbnz x4,.Lgrid_operational_reject
    ldr w4,[x0,#4892]
    ldr w5,[x0,#4908]
    sub w6,w5,w4
    b .Lgrid_construct
.Lgrid_operational_reject:
    mov w0,#2
    ret
.size md2asm_initialize_distributed_spherical_grid,.-md2asm_initialize_distributed_spherical_grid
.section .note.GNU-stack,"",%progbits
