// Physics input formulations/openifs/spectral_transforms/fourier_metric.md revision 1.0.
// Contract skills/md2asm/references/openifs/spectral_transforms/fourier_metric.md.
// Nine GNU Fortran addresses, with the ninth at entry sp. See the contract for strides and bounds.
// Convert weighted Fourier wind and northward gradients, then form eastward derivatives.
// Shared views retain first-element addresses. SIMD preserves separate FP64 products.
#ifndef FSC_SYMBOL
#define FSC_SYMBOL __fsc_mod_MOD_fsc
#endif
.text
.p2align 4
.global FSC_SYMBOL
.type FSC_SYMBOL,%function
FSC_SYMBOL:
    mov x9,sp
    sub sp,sp,#176
    stp x19,x20,[sp]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    stp x0,x1,[sp,#96]
    stp x2,x3,[sp,#112]
    stp x4,x5,[sp,#128]
    stp x6,x7,[sp,#144]
    ldr x10,[x9]
    str x10,[sp,#160]
    add x19,sp,#96
    adrp x9,:got:__tpm_trans_MOD_latlon
    ldr x9,[x9,:got_lo12:__tpm_trans_MOD_latlon]
    ldr w10,[x9]
    cbnz w10,.Lfsc_outside_domain
    ldr x9,[x19,#8]
    ldrsw x20,[x9]
    lsl x20,x20,#1
    ldr x9,[x19,#16]
    ldrsw x21,[x9]
    ldr x9,[x19,#24]
    ldr w22,[x9]
    adrp x9,:got:__tpm_trans_MOD_luvder
    ldr x9,[x9,:got_lo12:__tpm_trans_MOD_luvder]
    ldr w26,[x9]
    adrp x9,:got:__tpm_distr_MOD_d
    ldr x9,[x9,:got_lo12:__tpm_distr_MOD_d]
    ldr x23,[x9]
    adrp x9,:got:__tpm_distr_MOD_mysetw
    ldr x9,[x9,:got_lo12:__tpm_distr_MOD_mysetw]
    ldrsw x10,[x9]
    add x9,x23,#1200
    ldr x11,[x9]
    ldr x12,[x9,#8]
    ldr x13,[x9,#40]
    madd x10,x10,x13,x12
    ldrsw x27,[x11,x10,lsl #2]
    ldr x9,[x19]
    ldrsw x28,[x9]
    add x27,x27,x28
    sub x27,x27,#1
    add x9,x23,#1000
    ldr x10,[x9]
    ldr x11,[x9,#8]
    ldr x12,[x9,#40]
    madd x11,x28,x12,x11
    ldrsw x25,[x10,x11,lsl #2]
    adrp x9,:got:__tpm_geometry_MOD_g
    ldr x9,[x9,:got_lo12:__tpm_geometry_MOD_g]
    ldr x9,[x9]
    add x9,x9,#64
    ldr x10,[x9]
    ldr x11,[x9,#8]
    ldr x12,[x9,#40]
    madd x11,x27,x12,x11
    ldrsw x24,[x10,x11,lsl #2]
    adrp x9,:got:__tpm_fields_MOD_f
    ldr x9,[x9,:got_lo12:__tpm_fields_MOD_f]
    ldr x9,[x9]
    add x9,x9,#280
    ldr x10,[x9]
    ldr x11,[x9,#8]
    ldr x12,[x9,#40]
    madd x11,x27,x12,x11
    ldr d16,[x10,x11,lsl #3]
    dup v16.2d,v16.d[0]
    ldr x0,[x19,#32]
    mov x1,x20
    mov x2,x25
    add x3,x24,#1
    lsl x3,x3,#1
    bl .Lfsc_scale
    cbz w22,.Lfsc_scaled
    ldr x0,[x19,#48]
    mov x1,x21
    mov x2,x25
    add x3,x24,#1
    lsl x3,x3,#1
    bl .Lfsc_scale
.Lfsc_scaled:
    cbz w26,.Lfsc_scalar_derivative
    ldr x0,[x19,#32]
    ldr x1,[x19,#64]
    mov x2,x20
    mov x3,x25
    mov x4,x24
    bl .Lfsc_derivative
.Lfsc_scalar_derivative:
    cbz w22,.Lfsc_done
    ldr x0,[x19,#40]
    ldr x1,[x19,#56]
    mov x2,x21
    mov x3,x25
    mov x4,x24
    bl .Lfsc_derivative
.Lfsc_done:
    ldp x19,x20,[sp]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#176
    ret
.Lfsc_outside_domain:
    brk #0xf5c

// x0 descriptor, x1 fields, x2 first zero-based column, x3 columns.
.Lfsc_scale:
    cmp x1,#0
    b.le .Lfsc_scale_return
    cmp x3,#0
    b.le .Lfsc_scale_return
    ldr x5,[x0]
    ldr x6,[x0,#40]
    ldr x7,[x0,#64]
    lsl x6,x6,#3
    lsl x7,x7,#3
    madd x5,x2,x7,x5
.Lfsc_scale_column:
    mov x8,x5
    mov x9,x1
    cmp x6,#8
    b.ne .Lfsc_scale_scalar
.Lfsc_scale_vector:
    cmp x9,#2
    b.lt .Lfsc_scale_scalar
    ldr q0,[x8]
    fmul v0.2d,v0.2d,v16.2d
    str q0,[x8],#16
    sub x9,x9,#2
    b .Lfsc_scale_vector
.Lfsc_scale_scalar:
    cbz x9,.Lfsc_scale_next
.Lfsc_scale_scalar_loop:
    ldr d0,[x8]
    fmul d0,d0,d16
    str d0,[x8]
    add x8,x8,x6
    subs x9,x9,#1
    b.ne .Lfsc_scale_scalar_loop
.Lfsc_scale_next:
    add x5,x5,x7
    subs x3,x3,#1
    b.ne .Lfsc_scale_column
.Lfsc_scale_return:
    ret

// Input/output descriptors may have different strides.
.Lfsc_derivative:
    cmp x2,#0
    b.le .Lfsc_derivative_return
    cmp x4,#0
    b.lt .Lfsc_derivative_return
    ldr x5,[x0]
    ldr x6,[x0,#40]
    ldr x7,[x0,#64]
    ldr x8,[x1]
    ldr x9,[x1,#40]
    ldr x10,[x1,#64]
    lsl x6,x6,#3
    lsl x7,x7,#3
    lsl x9,x9,#3
    lsl x10,x10,#3
    madd x5,x3,x7,x5
    madd x8,x3,x10,x8
    mov x11,#0
.Lfsc_derivative_wave:
    scvtf d17,x11
    fmul d17,d16,d17
    dup v17.2d,v17.d[0]
    mov x12,x5
    add x13,x5,x7
    mov x14,x8
    add x15,x8,x10
    mov x16,x2
    cmp x6,#8
    b.ne .Lfsc_derivative_scalar
    cmp x9,#8
    b.ne .Lfsc_derivative_scalar
.Lfsc_derivative_vector:
    cmp x16,#2
    b.lt .Lfsc_derivative_scalar
    ldr q0,[x12],#16
    ldr q1,[x13],#16
    fneg v1.2d,v1.2d
    fmul v1.2d,v1.2d,v17.2d
    fmul v0.2d,v0.2d,v17.2d
    str q1,[x14],#16
    str q0,[x15],#16
    sub x16,x16,#2
    b .Lfsc_derivative_vector
.Lfsc_derivative_scalar:
    cbz x16,.Lfsc_derivative_next
.Lfsc_derivative_scalar_loop:
    ldr d0,[x12]
    ldr d1,[x13]
    fneg d1,d1
    fmul d1,d1,d17
    fmul d0,d0,d17
    str d1,[x14]
    str d0,[x15]
    add x12,x12,x6
    add x13,x13,x6
    add x14,x14,x9
    add x15,x15,x9
    subs x16,x16,#1
    b.ne .Lfsc_derivative_scalar_loop
.Lfsc_derivative_next:
    add x5,x5,x7,lsl #1
    add x8,x8,x10,lsl #1
    add x11,x11,#1
    cmp x11,x4
    b.le .Lfsc_derivative_wave
.Lfsc_derivative_return:
    ret
.size FSC_SYMBOL,.-FSC_SYMBOL
.section .note.GNU-stack,"",%progbits
