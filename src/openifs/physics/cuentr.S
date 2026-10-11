/* Plume exchange from formulations/openifs/physics/plume_air_exchange.md.
 * The ordered update, SPP storage and 18-address ABI are in
 * skills/md2asm/references/openifs/physics/cuentr.md.
 * The complete body calls only the accepted strict scalar exponential. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL cuentr_
#endif
.text
.p2align 4
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
.macro ARG reg,number
    ldr \reg,[sp,#(160+8*\number)]
.endm
.macro GET reg,number,index
    ARG x9,\number
    ldr \reg,[x9,\index]
.endm
.macro PUT reg,number,index
    ARG x9,\number
    str \reg,[x9,\index]
.endm
ORIGINAL_SYMBOL:
    mov x17,sp
    sub sp,sp,#304
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    stp d8,d9,[sp,#96]
    stp d10,d11,[sp,#112]
    stp d12,d13,[sp,#128]
    stp d14,d15,[sp,#144]
    stp x0,x1,[sp,#160]
    stp x2,x3,[sp,#176]
    stp x4,x5,[sp,#192]
    stp x6,x7,[sp,#208]
    add x10,sp,#224
    mov x11,#10
.Lcuentr_copy_arguments:
    ldr x12,[x17],#8
    str x12,[x10],#8
    subs x11,x11,#1
    b.ne .Lcuentr_copy_arguments
    ARG x9,10
    ldr w0,[x9]
    cbz w0,.Lcuentr_return

    adrp x9,:got:__yomcst_MOD_rg
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rg]
    ldr d0,[x9]
    fmov d1,#1.0
    fdiv d8,d1,d0
    ARG x9,0
    ldr d9,[x9,#48]
    ARG x9,2
    ldrsw x19,[x9]
    sub x19,x19,#1
    ARG x9,3
    ldrsw x20,[x9]
    ARG x9,4
    ldrsw x21,[x9]
    lsl x21,x21,#3
    ARG x9,6
    ldrsw x22,[x9]
    lsl x27,x19,#3
    sub x23,x22,#1
    mul x23,x23,x21
    add x23,x23,x27
    add x24,x23,x21
    fmov d13,xzr
    mov x25,#0
    ARG x9,1
    ldr w0,[x9]
    cbz w0,.Lcuentr_perturbation_ready
    ldrsw x11,[x9,#504]
    cmp x11,#0
    b.le .Lcuentr_perturbation_ready

    /* Resolve the selected complete SPP element from its GNU descriptor. */
    add x9,x9,#352
    ldp x12,x13,[x9]
    ldr x14,[x9,#40]
    madd x13,x11,x14,x13
    mov x14,#184
    madd x12,x13,x14,x12
    ldr d10,[x12,#56]
    ldr d11,[x12,#24]
    ldrsw x11,[x12,#136]
    sub x11,x11,#1
    mul x26,x11,x21
    add x26,x26,x27
    mov x25,#1
.Lcuentr_perturbation_ready:
    cmp x19,x20
    b.ge .Lcuentr_return
.Lcuentr_column:
    PUT d13,16,x27
    PUT d13,17,x27
    lsr x10,x27,#1
    GET w0,9,x10
    cbz w0,.Lcuentr_next
    GET d0,13,x23
    GET d1,13,x24
    fsub d0,d0,d1
    fmul d0,d0,d8
    GET d1,14,x24
    fmul d12,d1,d0
    GET w0,7,x10
    cmp w22,w0
    b.ge .Lcuentr_next
    cbz x25,.Lcuentr_unperturbed

    /* Saved scalar registers keep the source mass flux across EXP. */
    GET d0,15,x26
    fmul d0,d11,d0
    fadd d0,d10,d0
    bl exp
    fmul d0,d9,d0
    b .Lcuentr_store
.Lcuentr_unperturbed:
    fmov d0,d9
.Lcuentr_store:
    fmul d1,d13,d12
    PUT d1,16,x27
    fmul d0,d0,d12
    PUT d0,17,x27
.Lcuentr_next:
    add x19,x19,#1
    add x23,x23,#8
    add x24,x24,#8
    add x26,x26,#8
    add x27,x27,#8
    cmp x19,x20
    b.lt .Lcuentr_column
.Lcuentr_return:
    ldp d8,d9,[sp,#96]
    ldp d10,d11,[sp,#112]
    ldp d12,d13,[sp,#128]
    ldp d14,d15,[sp,#144]
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#304
    ret
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .note.GNU-stack,"",%progbits
