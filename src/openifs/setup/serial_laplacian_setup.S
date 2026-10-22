// Contract: skills/md2asm/references/openifs/setup/serial_laplacian_setup.md.
// Construct serial spectral maps and spherical Laplacian factors from inputs.
// Contract: skills/md2asm/references/openifs/setup/serial_laplacian_setup.md.
// ABI: x0 owns an unassociated 576-byte TLAP record; w1 is N in 0..21 or 1279;
// d0 is the physical radius 6371229 metres. Return w0: 0 ready, 1 allocation
// failure with all data pointers cleared, 2 unsupported N before mutation.
// Bounds written before allocation failure can remain. Caller owns successful
// malloc buffers and releases each once. Preserve x18 and AAPCS64 saved registers.
.text
.p2align 4
.global md2asm_initialize_serial_laplacian
.type md2asm_initialize_serial_laplacian,%function
md2asm_initialize_serial_laplacian:
    cmp w1, #1279
    b.eq .Llap_supported
    cmp w1, #21
    b.hi .Llap_domain_failed
.Llap_supported:
    stp x29, x30, [sp, #-96]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    str x18, [sp, #64]
    str d0, [sp, #72]
    mov x19, x0
    mov w20, w1
    mov x4, x0
    add x5, x0, #576
.Llap_clear_record:
    str xzr, [x4], #8
    cmp x4, x5
    b.lo .Llap_clear_record
    adrp x21, .Llap_arrays
    add x21, x21, :lo12:.Llap_arrays
    mov x22, #0
.Llap_allocate_array:
    ldr w4, [x21, #4]
    add x23, x20, #1
    cbz w4, .Llap_count_ready
    cmp w4, #1
    b.ne .Llap_coefficient_count
    add x5, x20, #2
    mul x23, x23, x5
    b .Llap_count_ready
.Llap_coefficient_count:
    add x23, x20, #4
.Llap_count_ready:
    ldr w4, [x21, #8]
    mul x0, x23, x4
    bl malloc
    cbz x0, .Llap_allocation_failed
    ldr w4, [x21]
    add x24, x19, w4, uxtw
    str x0, [x24]
    ldrsw x5, [x21, #12]
    neg x6, x5
    str x6, [x24, #8]
    ldr w4, [x21, #8]
    str x4, [x24, #16]
    str xzr, [x24, #24]
    mov w6, #1
    strb w6, [x24, #28]
    ldr w7, [x21, #16]
    strb w7, [x24, #29]
    str x4, [x24, #32]
    stp x6, x5, [x24, #40]
    add x5, x5, x23
    sub x5, x5, #1
    str x5, [x24, #56]
    add x21, x21, #32
    add x22, x22, #1
    cmp x22, #9
    b.lo .Llap_allocate_array
    // The scalar maps retain the source's integer ordering.
    ldr x3, [x19]
    ldr x4, [x19, #64]
    ldr x5, [x19, #128]
    ldr x6, [x19, #256]
    ldr x7, [x19, #320]
    ldr x8, [x19, #384]
    mov w9, #0
    mov w10, #1
    mov w11, #0
.Llap_integer_maps:
    madd w12, w9, w9, w9
    add w12, w12, #1
    str w12, [x3, x9, lsl #2]
    str w10, [x4, x9, lsl #2]
    str w10, [x5, x9, lsl #2]
    str w9, [x6, x9, lsl #2]
    lsl w12, w9, #1
    add w12, w12, #2
    str w12, [x7, x9, lsl #2]
    str w11, [x8, x9, lsl #2]
    add w12, w20, #1
    sub w12, w12, w9
    add w11, w11, w12
    add w10, w10, w12, lsl #1
    add w9, w9, #1
    cmp w9, w20
    b.ls .Llap_integer_maps
    ldr x3, [x19, #192]
    mov w4, #0
.Llap_m_block:
    mov w5, w4
.Llap_degrees:
    stp w5, w5, [x3], #8
    add w5, w5, #1
    cmp w5, w20
    b.ls .Llap_degrees
    add w4, w4, #1
    cmp w4, w20
    b.ls .Llap_m_block
    // Coefficients are evaluated with the original separate rounding points.
    ldr d0, [sp, #72]
    ldr x3, [x19, #448]
    ldr x4, [x19, #512]
    stp xzr, xzr, [x3]
    stp xzr, xzr, [x4]
    add x3, x3, #16
    add x4, x4, #16
    mov w5, #1
    add w6, w20, #2
.Llap_eigenvalues:
    add w7, w5, #1
    mul w7, w5, w7
    scvtf d1, w7
    fneg d2, d1
    fmul d3, d0, d0
    fdiv d4, d2, d3
    str d4, [x3], #8
    fmul d3, d0, d0
    fneg d3, d3
    fdiv d4, d3, d1
    str d4, [x4], #8
    add w5, w5, #1
    cmp w5, w6
    b.ls .Llap_eigenvalues
    mov w0, #0
    b .Llap_return
.Llap_allocation_failed:
    mov x21, #0
.Llap_cleanup:
    lsl x4, x21, #6
    ldr x0, [x19, x4]
    cbz x0, .Llap_cleanup_next
    bl free
    lsl x4, x21, #6
    str xzr, [x19, x4]
.Llap_cleanup_next:
    add x21, x21, #1
    cmp x21, #9
    b.lo .Llap_cleanup
    mov w0, #1
.Llap_return:
    ldr x18, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret
.Llap_domain_failed:
    mov w0, #2
    ret
.size md2asm_initialize_serial_laplacian,.-md2asm_initialize_serial_laplacian
.section .rodata
.p2align 3
.Llap_arrays:
    // descriptor offset, count kind, element bytes, lower bound, type, padding
    .word 0,0,4,0,1,0,0,0
    .word 64,0,4,0,1,0,0,0
    .word 128,0,4,0,1,0,0,0
    .word 192,1,4,1,1,0,0,0
    .word 256,0,4,1,1,0,0,0
    .word 320,0,4,0,1,0,0,0
    .word 384,0,4,1,1,0,0,0
    .word 448,2,8,-1,3,0,0,0
    .word 512,2,8,-1,3,0,0,0
.section .note.GNU-stack,"",%progbits
