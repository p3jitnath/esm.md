/* Source SUMPINI sections 4.1 and 4.4, scalar zero-factor route.
 * ABI w0 world, w1 threads, w2 spectral minimum, x3 out32, x4 capacity.
 * The local contract was frozen before this direct assembly was emitted.
 * All output words commit together only after source-domain success.
 */
.text
.p2align 2
.global md2asm_derive_runtime_process_partitions
.type md2asm_derive_runtime_process_partitions, %function
md2asm_derive_runtime_process_partitions:
    cmp w0, #0
    b.lt .Lrefuse
    cmp w0, #16, lsl #12
    b.gt .Lrefuse
    cmp w1, #1
    b.lt .Lrefuse
    cmp w1, #16, lsl #12
    b.gt .Lrefuse
    cmp w2, #0
    b.lt .Lrefuse
    mov w9, #0x4240
    movk w9, #0xf, lsl #16
    cmp w2, w9
    b.gt .Lrefuse
    cbz x3, .Lrefuse
    tst x3, #7
    b.ne .Lrefuse
    cmp x4, #32
    b.lo .Lrefuse
    adds x9, x3, #32
    b.cs .Lrefuse
    mrs x9, fpcr
    cbnz x9, .Lrefuse
    mov w5, w0
    cbnz w5, .Lworld_ready
    mov w5, #1
.Lworld_ready:
    mov w6, w1
    mov w7, w2
    cbnz w7, .Lminimum_ready
    mov w7, w5
.Lminimum_ready:
    scvtf d0, w5
    fsqrt d0, d0
    fcvtzs w8, d0
    mov w9, w8
.Lgrid_divisor:
    sdiv w10, w5, w9
    mul w15, w9, w10
    cmp w15, w5
    b.eq .Lgrid_selected
    add w9, w9, #1
    b .Lgrid_divisor
.Lgrid_selected:
    cmp w9, w10
    csel w11, w9, w10, ge
    csel w12, w9, w10, le
    lsl w9, w6, #1
    sdiv w16, w7, w9
    mov w13, #0
    mov w14, #0
    mov w9, #4
    cmp w9, w5
    b.gt .Ltransform_trial_end
.Ltransform_trial:
    mov w14, w9
    sdiv w13, w5, w14
    mul w15, w14, w13
    cmp w15, w5
    b.ne .Ltransform_next
    cmp w14, w13
    b.gt .Ltransform_trial_end
    cmp w13, w7
    b.gt .Ltransform_next
    cmp w13, w16
    b.le .Ltransform_trial_end
.Ltransform_next:
    add w9, w9, #1
    cmp w9, w5
    b.le .Ltransform_trial
.Ltransform_trial_end:
    mul w15, w14, w13
    cmp w15, w5
    b.ne .Ltransform_fallback
    cmp w13, w7
    b.gt .Ltransform_fallback
    cmp w14, w13
    b.gt .Ltransform_fallback
    b .Lcommit
.Ltransform_fallback:
    scvtf d0, w5
    fsqrt d0, d0
    fcvtzs w8, d0
    mov w9, w8
.Ltransform_divisor:
    sdiv w10, w5, w9
    mul w15, w9, w10
    cmp w15, w5
    b.eq .Ltransform_selected
    add w9, w9, #1
    b .Ltransform_divisor
.Ltransform_selected:
    cmp w9, w10
    csel w13, w9, w10, ge
    csel w14, w9, w10, le
    cmp w13, w7
    b.gt .Lrefuse
.Lcommit:
    stp w5, w11, [x3]
    stp w12, w13, [x3, #8]
    stp w14, w13, [x3, #16]
    stp w14, w7, [x3, #24]
    mov w0, #0
    ret
.Lrefuse:
    mov w0, #2
    ret
.size md2asm_derive_runtime_process_partitions, .-md2asm_derive_runtime_process_partitions
.section .note.GNU-stack,"",%progbits
