/* Midlevel plume initiation from formulations/openifs/physics/midlevel_plume_base.md.
 * Ordered arithmetic and the 26-address ABI are in
 * skills/md2asm/references/openifs/physics/cubasmcn.md.
 * Separate FP64 instructions preserve each original rounding point. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL cubasmcn_
#endif
.text
.p2align 4
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
.macro ARG reg,number
    ldr \reg,[sp,#(96+8*\number)]
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
    stp x0,x1,[sp,#96]
    stp x2,x3,[sp,#112]
    stp x4,x5,[sp,#128]
    stp x6,x7,[sp,#144]
    add x10,sp,#160
    mov x11,#18
.Lcubasmcn_copy_arguments:
    ldr x12,[x17],#8
    str x12,[x10],#8
    subs x11,x11,#1
    b.ne .Lcubasmcn_copy_arguments

    /* Accepted globals supply gravity and specific heat. */
    adrp x9,:got:__yomcst_MOD_rg
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rg]
    ldr d0,[x9]
    fmov d1,#1.0
    fdiv d7,d1,d0
    adrp x9,:got:__yomcst_MOD_rcpd
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rcpd]
    ldr d5,[x9]
    fdiv d6,d1,d5
    ARG x9,0
    ldr d4,[x9,#64]
    ldr w24,[x9,#256]
    ldr w25,[x9,#332]
    ARG x9,1
    ldrsw x19,[x9]
    sub x19,x19,#1
    ARG x9,2
    ldrsw x20,[x9]
    ARG x9,3
    ldrsw x23,[x9]
    lsl x21,x23,#3
    ARG x9,5
    ldrsw x22,[x9]
    cmp x19,x20
    b.ge .Lcubasmcn_return
    cbz w24,.Lcubasmcn_return
    cmp w22,w25
    b.le .Lcubasmcn_return
    sub x26,x22,#1
    mul x26,x26,x21
    add x26,x26,x19,lsl #3
    add x27,x26,x21
    lsl x28,x19,#3
    adrp x9,.Lcubasmcn_literals
    add x9,x9,:lo12:.Lcubasmcn_literals
    ldp d16,d17,[x9]
    fmov d18,xzr
.Lcubasmcn_column:
    lsr x10,x28,#1
    GET w0,12,x10
    cbnz w0,.Lcubasmcn_next
    lsr x10,x27,#1
    GET w0,14,x10
    cbnz w0,.Lcubasmcn_next
    GET d20,7,x26
    GET d0,8,x26
    fmul d0,d16,d0
    fcmp d20,d0
    b.le .Lcubasmcn_next

    /* Keep the environment's dry static energy at the new base. */
    GET d0,6,x26
    GET d1,10,x26
    GET d2,11,x27
    fmul d0,d5,d0
    fadd d0,d0,d1
    fsub d0,d0,d2
    fmul d19,d0,d6
    PUT d19,19,x27
    PUT d20,20,x27
    PUT d18,21,x27

    /* Pressure ascent gives a mass flux with a floor and cap. */
    GET d0,9,x26
    fneg d0,d0
    fmul d0,d0,d7
    fmax d0,d17,d0
    fmin d0,d0,d4
    PUT d0,17,x28
    PUT d0,16,x27
    fmul d1,d5,d19
    fadd d1,d1,d2
    fmul d1,d0,d1
    PUT d1,22,x27
    fmul d1,d0,d20
    PUT d1,23,x27
    PUT d18,24,x27
    PUT d18,25,x27
    PUT d18,18,x27
    lsr x10,x28,#1
    PUT w22,15,x10
    lsr x10,x27,#1
    mov w0,#1
    PUT w0,14,x10
    lsr x10,x28,#1
    mov w0,#3
    PUT w0,13,x10
.Lcubasmcn_next:
    add x19,x19,#1
    add x26,x26,#8
    add x27,x27,#8
    add x28,x28,#8
    cmp x19,x20
    b.lt .Lcubasmcn_column
.Lcubasmcn_return:
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#304
    ret
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .rodata
.p2align 3
.Lcubasmcn_literals:
    .quad 0x3fe999999999999a
    .quad 0x3eb0c6f7a0b5ed8d
.section .note.GNU-stack,"",%progbits
