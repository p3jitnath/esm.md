/* Direct AArch64 from the revision-1 LDFOU2 contract.
 * Physics input is formulations/openifs/dynamics/fourier_wind_scaling.md.
 * x0 and x1 point to four-byte KM and KF_UV.
 * x2 and x3 point to GNU rank-two PAIA and PSIA descriptors.
 * Each selected coefficient has one rounded product with 1/(a*cos(latitude)).
 * Separate owners, positive strides and the contract's finite values are required.
 */
#ifndef LDFOU2_ENTRY
#define LDFOU2_ENTRY __ldfou2_mod_MOD_ldfou2
#endif
.text
.p2align 4
.global LDFOU2_ENTRY
.type LDFOU2_ENTRY,%function
LDFOU2_ENTRY:
    mrs x17,fpcr
    cbnz x17,.Lldf_bad
    ldr w0,[x0]
    ldr w1,[x1]
    cmp w0,#1024
    b.hi .Lldf_bad
    cmp w1,#1024
    b.hi .Lldf_bad
    lsl w12,w1,#2
    adrp x4,:got:__tpm_dim_MOD_r
    ldr x4,[x4,:got_lo12:__tpm_dim_MOD_r]
    ldr x4,[x4]
    cbz x4,.Lldf_bad
    ldr w11,[x4,#28]
    cmp w11,#4096
    b.hi .Lldf_bad
    adrp x4,:got:__tpm_geometry_MOD_g
    ldr x4,[x4,:got_lo12:__tpm_geometry_MOD_g]
    ldr x4,[x4]
    cbz x4,.Lldf_bad
    add x4,x4,#128
    ldr x16,[x4,#40]
    cmp x16,#1
    b.ne .Lldf_bad
    ldrsw x16,[x4,#48]
    cmp x0,x16
    b.lt .Lldf_bad
    ldrsw x16,[x4,#56]
    cmp x0,x16
    b.gt .Lldf_bad
    ldp x16,x17,[x4]
    add x17,x17,x0
    ldr w4,[x16,x17,lsl #2]
    cmp w4,w11
    b.hi .Lldf_bad
    sub w13,w11,w4
    cbz w12,.Lldf_done
    cmp w13,w11
    b.ge .Lldf_done

    /* Assumed-shape dummy index one starts at descriptor.data. */
    ldr x5,[x2]
    ldr x6,[x3]
    tst x5,#7
    b.ne .Lldf_bad
    tst x6,#7
    b.ne .Lldf_bad
    ldr x7,[x2,#40]
    ldr x8,[x3,#40]
    ldr x9,[x2,#64]
    ldr x10,[x3,#64]
    cmp x7,#0
    b.le .Lldf_bad
    cmp x8,#0
    b.le .Lldf_bad
    cmp x9,#0
    b.le .Lldf_bad
    cmp x10,#0
    b.le .Lldf_bad
    ldp x16,x17,[x2,#48]
    sub x17,x17,x16
    add x17,x17,#1
    cmp x17,x12
    b.lt .Lldf_bad
    ldp x16,x17,[x3,#48]
    sub x17,x17,x16
    add x17,x17,#1
    cmp x17,x12
    b.lt .Lldf_bad
    ldp x16,x17,[x2,#72]
    sub x17,x17,x16
    add x17,x17,#1
    cmp x17,x11
    b.lt .Lldf_bad
    ldp x16,x17,[x3,#72]
    sub x17,x17,x16
    add x17,x17,#1
    cmp x17,x11
    b.lt .Lldf_bad
    lsl x7,x7,#3
    lsl x8,x8,#3
    lsl x9,x9,#3
    lsl x10,x10,#3
    madd x5,x13,x9,x5
    madd x6,x13,x10,x6

    adrp x4,:got:__tpm_fields_MOD_f
    ldr x4,[x4,:got_lo12:__tpm_fields_MOD_f]
    ldr x4,[x4]
    cbz x4,.Lldf_bad
    add x4,x4,#280
    ldr x16,[x4,#40]
    cmp x16,#1
    b.ne .Lldf_bad
    ldr x16,[x4,#48]
    add x17,x13,#1
    cmp x16,x17
    b.gt .Lldf_bad
    ldr x16,[x4,#56]
    cmp x16,x11
    b.lt .Lldf_bad
    ldp x14,x16,[x4]
    add x16,x16,#1
    add x14,x14,x16,lsl #3

.Lldf_latitude:
    ldr d16,[x14,x13,lsl #3]
    mov x1,x5
    mov x2,x6
    mov x0,x12
    cmp x7,#8
    b.ne .Lldf_scalar
    cmp x8,#8
    b.ne .Lldf_scalar
    dup v16.2d,v16.d[0]
.Lldf_four:
    ldp q0,q1,[x1]
    ldp q2,q3,[x2]
    fmul v0.2d,v0.2d,v16.2d
    fmul v1.2d,v1.2d,v16.2d
    fmul v2.2d,v2.2d,v16.2d
    fmul v3.2d,v3.2d,v16.2d
    stp q0,q1,[x1],#32
    stp q2,q3,[x2],#32
    subs x0,x0,#4
    b.ne .Lldf_four
    b .Lldf_next
.Lldf_scalar:
    ldr d0,[x1]
    ldr d1,[x2]
    fmul d0,d0,d16
    fmul d1,d1,d16
    str d0,[x1]
    str d1,[x2]
    add x1,x1,x7
    add x2,x2,x8
    subs x0,x0,#1
    b.ne .Lldf_scalar
.Lldf_next:
    add x5,x5,x9
    add x6,x6,x10
    add x13,x13,#1
    cmp x13,x11
    b.lt .Lldf_latitude
.Lldf_done:
    ret
.Lldf_bad:
    mov w0,#116
    b _exit
.size LDFOU2_ENTRY,.-LDFOU2_ENTRY
.section .note.GNU-stack,"",%progbits
