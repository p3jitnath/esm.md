// Construct selected SULEGA latitude geometry from direct Gaussian arithmetic.
// Contract: skills/md2asm/references/openifs/setup/latitude_geometry_setup.md. x0 owns a640-byte TCSGLEG;
// d0 is radius6371229 metres. Return w0:0 ready,1 allocation/child failure,
// 2 invalid record, preassociated owner or FPCR. Nine outputs use malloc.
// Failure frees earlier owners and clears all nine data pointers; partial
// descriptor bounds can remain. The tenth RLATI descriptor stays unchanged.
// Frame112, alignment16; preserve x18 and required AAPCS64 saved registers.
.text
.p2align 4
.global md2asm_initialize_latitude_geometry
.type md2asm_initialize_latitude_geometry,%function
md2asm_initialize_latitude_geometry:
    mrs x9, fpcr
    cbnz x9, .Llatitude_invalid
    cbz x0, .Llatitude_invalid
    tst x0, #7
    b.ne .Llatitude_invalid
    adds x9, x0, #640
    b.cs .Llatitude_invalid
    mov x9, x0
    mov w10, #9
.Llatitude_association:
    ldr x11, [x9], #64
    cbnz x11, .Llatitude_invalid
    subs w10, w10, #1
    b.ne .Llatitude_association
    stp x29, x30, [sp, #-112]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    str x18, [sp, #64]
    stp d8, d9, [sp, #72]
    str d10, [sp, #88]
    fmov d8, d0
    mov x19, x0
    mov x9, x0
    add x10, x0, #576
.Llatitude_clear_descriptors:
    str xzr, [x9], #8
    cmp x9, x10
    b.lo .Llatitude_clear_descriptors
    mov x20, #0
.Llatitude_allocate:
    mov x0, #288
    cbnz x20, .Llatitude_size_ready
    mov x0, #256
.Llatitude_size_ready:
    bl malloc
    cbz x0, .Llatitude_failed
    add x21, x19, x20, lsl #6
    str x0, [x21]
    mov x9, #-1
    mov x10, #32
    mov x11, #1
    cbz x20, .Llatitude_bounds_ready
    mov x9, #1
    mov x10, #34
    mov x11, #-1
.Llatitude_bounds_ready:
    str x9, [x21, #8]
    mov x9, #8
    str x9, [x21, #16]
    str xzr, [x21, #24]
    mov w12, #1
    strb w12, [x21, #28]
    mov w12, #3
    strb w12, [x21, #29]
    str x9, [x21, #32]
    mov x9, #1
    stp x9, x11, [x21, #40]
    str x10, [x21, #56]
    add x20, x20, #1
    cmp x20, #9
    b.lo .Llatitude_allocate
    ldr x0, [x19, #64]
    add x0, x0, #16
    ldr x1, [x19]
    bl md2asm_initialize_gaussian_latitudes
    cbnz w0, .Llatitude_failed
    mov x20, #0
    ldr x23, [x19, #64]
    add x23, x23, #16
.Llatitude_physical_rows:
    ldr d0, [x23, x20, lsl #3]
    fmul d1, d0, d0
    fmov d2, #1.0
    fsub d9, d2, d1
    fsqrt d10, d9
    bl md2asm_asin_original_rounding
    add x24, x20, #2
    lsl x24, x24, #3
    ldr x9, [x19, #512]
    str d0, [x9, x24]
    ldr x9, [x19, #128]
    str d9, [x9, x24]
    fmov d2, #1.0
    fdiv d0, d2, d9
    ldr x9, [x19, #192]
    str d0, [x9, x24]
    fmul d0, d8, d9
    fdiv d0, d2, d0
    ldr x9, [x19, #256]
    str d0, [x9, x24]
    ldr x9, [x19, #320]
    str d10, [x9, x24]
    fdiv d0, d2, d10
    ldr x9, [x19, #384]
    str d0, [x9, x24]
    fmul d0, d8, d10
    fdiv d0, d2, d0
    ldr x9, [x19, #448]
    str d0, [x9, x24]
    add x20, x20, #1
    cmp x20, #32
    b.lo .Llatitude_physical_rows
    adrp x9, .Llatitude_pi
    ldr d8, [x9, :lo12:.Llatitude_pi]
    mov x20, #1
.Llatitude_pole_rows:
    add x10, x20, #1
    lsl x10, x10, #3
    mov x11, #2
    sub x11, x11, x20
    lsl x11, x11, #3
    mov x12, #34
    sub x12, x12, x20
    lsl x12, x12, #3
    add x13, x20, #33
    lsl x13, x13, #3
    mov x21, #64
.Llatitude_copy_pole_arrays:
    ldr x9, [x19, x21]
    ldr x14, [x9, x10]
    str x14, [x9, x11]
    ldr x14, [x9, x12]
    str x14, [x9, x13]
    add x21, x21, #64
    cmp x21, #512
    b.lo .Llatitude_copy_pole_arrays
    ldr x9, [x19, #512]
    ldr d0, [x9, x10]
    fsub d0, d8, d0
    str d0, [x9, x11]
    ldr d0, [x9, x12]
    fneg d1, d8
    fsub d0, d1, d0
    str d0, [x9, x13]
    add x20, x20, #1
    cmp x20, #2
    b.ls .Llatitude_pole_rows
    mov w0, #0
    b .Llatitude_return
.Llatitude_failed:
    mov x20, #0
.Llatitude_cleanup:
    add x21, x19, x20, lsl #6
    ldr x0, [x21]
    cbz x0, .Llatitude_cleanup_next
    bl free
    str xzr, [x21]
.Llatitude_cleanup_next:
    add x20, x20, #1
    cmp x20, #9
    b.lo .Llatitude_cleanup
    mov w0, #1
.Llatitude_return:
    ldr d10, [sp, #88]
    ldp d8, d9, [sp, #72]
    ldr x18, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #112
    ret
.Llatitude_invalid:
    mov w0, #2
    ret
.size md2asm_initialize_latitude_geometry,.-md2asm_initialize_latitude_geometry
.section .rodata
.balign 8
.Llatitude_pi:
    .xword 0x400921fb54442d18
.section .note.GNU-stack,"",%progbits
