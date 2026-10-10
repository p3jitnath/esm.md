/* Saturation humidity from the mixed water and ice vapour-pressure laws.
 * Physics is formulations/openifs/physics/saturation.md.
 * ABI and ordered operations are skills/md2asm/references/openifs/physics/satur.md.
 * Ten ordinary pointers use x0..x7 and two caller stack slots.
 * Every cell uses separate FP64 operations and the accepted scalar EXP route.
 * The 256-byte aligned frame preserves x19..x30 and d8..d15.
 * Inputs and frozen module constants stay read-only. No array scratch is used. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL satur_
#endif
.text
.p2align 2
.macro GLOBAL reg,name
    adrp x16,:got:\name
    ldr x16,[x16,:got_lo12:\name]
    ldr \reg,[x16]
.endm
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    sub sp,sp,#256
    stp x29,x30,[sp,#0]
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    stp d8,d9,[sp,#96]
    stp d10,d11,[sp,#112]
    stp d12,d13,[sp,#128]
    stp d14,d15,[sp,#144]
    mov x29,sp
    ldrsw x25,[x0]
    sub x25,x25,#1
    ldrsw x26,[x1]
    cmp x25,x26
    b.ge .Ldone
    ldrsw x22,[x2]
    ldrsw x24,[x3]
    sub x24,x24,#1
    ldrsw x23,[x4]
    cmp x24,x23
    b.ge .Ldone
    ldr w28,[x5]
    mov x19,x6
    mov x20,x7
    ldr x21,[sp,#256]
    ldr x9,[sp,#264]
    ldr w9,[x9]
    cbnz w28,.Lordinary_phase
    cmp w9,#1
    b.ne .Lordinary_phase
    GLOBAL d0,__yoethf_MOD_rticecu
    GLOBAL d1,__yoethf_MOD_rtwat_rticecu_r
    b .Lphase_ready
.Lordinary_phase:
    GLOBAL d0,__yoethf_MOD_rtice
    GLOBAL d1,__yoethf_MOD_rtwat_rtice_r
.Lphase_ready:
    stp d0,d1,[sp,#160]
    GLOBAL d0,__yoethf_MOD_rtwat
    GLOBAL d14,__yomcst_MOD_retv
    stp d0,d14,[sp,#176]
    GLOBAL d0,__yomcst_MOD_rtt
    GLOBAL d15,__yoethf_MOD_r2es
    stp d0,d15,[sp,#192]
    GLOBAL d0,__yoethf_MOD_r3les
    GLOBAL d1,__yoethf_MOD_r4les
    stp d0,d1,[sp,#208]
    GLOBAL d0,__yoethf_MOD_r3ies
    GLOBAL d1,__yoethf_MOD_r4ies
    stp d0,d1,[sp,#224]
    fmov d12,#1.0
    fmov d13,#0.5
.Llevel:
    madd x27,x24,x22,x25
.Lcell:
    ldr d8,[x20,x27,lsl #3]
    ldr d0,[sp,#176]
    fmin d9,d0,d8
    ldp d0,d1,[sp,#160]
    fmax d9,d0,d9
    fsub d9,d9,d0
    fmul d9,d9,d1
    fmul d9,d9,d9
    fmin d9,d12,d9
    ldr d1,[sp,#192]
    fsub d0,d8,d1
    ldp d1,d2,[sp,#208]
    fmul d0,d1,d0
    fsub d2,d8,d2
    fdiv d0,d0,d2
    bl exp
    fmov d10,d0
    cbz w28,.Lwater_ready
    fmul d10,d15,d10
.Lwater_ready:
    ldr d1,[sp,#192]
    fsub d0,d8,d1
    ldp d1,d2,[sp,#224]
    fmul d0,d1,d0
    fsub d2,d8,d2
    fdiv d0,d0,d2
    bl exp
    fmov d11,d0
    cbz w28,.Lice_ready
    fmul d11,d15,d11
.Lice_ready:
    fmul d0,d9,d10
    fsub d1,d12,d9
    fmul d1,d1,d11
    fadd d0,d0,d1
    cbnz w28,.Lpressure_ready
    fmul d0,d15,d0
.Lpressure_ready:
    ldr d1,[x19,x27,lsl #3]
    fdiv d0,d0,d1
    fmin d0,d13,d0
    fmul d1,d14,d0
    fsub d1,d12,d1
    fdiv d1,d12,d1
    fmul d0,d0,d1
    str d0,[x21,x27,lsl #3]
    add x27,x27,#1
    madd x9,x24,x22,x26
    cmp x27,x9
    b.lt .Lcell
    add x24,x24,#1
    cmp x24,x23
    b.lt .Llevel
.Ldone:
    ldp x29,x30,[sp,#0]
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp d8,d9,[sp,#96]
    ldp d10,d11,[sp,#112]
    ldp d12,d13,[sp,#128]
    ldp d14,d15,[sp,#144]
    add sp,sp,#256
    ret
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .note.GNU-stack,"",%progbits
