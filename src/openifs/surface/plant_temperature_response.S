// Plant response from formulations/openifs/surface/plant_temperature_response.md.
// The numerical contract is skills/md2asm/references/openifs/surface/plant_temperature_response.md.
#ifndef ARRHENIUS_SYMBOL
#define ARRHENIUS_SYMBOL __farquhar_mod_MOD_arrhenius_fn
#endif
#ifndef ARRHENIUS_MODIFIED_SYMBOL
#define ARRHENIUS_MODIFIED_SYMBOL __farquhar_mod_MOD_arrhenius_modified_fn
#endif
.text
.p2align 4
.global ARRHENIUS_SYMBOL
.type ARRHENIUS_SYMBOL,%function
ARRHENIUS_SYMBOL:
    ldr d0,[x0]
    ldr d1,[x1]
    ldr d2,[x2]
    ldr d3,[x4,#24]
    fsub d4,d0,d1
    fmul d4,d4,d2
    fmul d1,d1,d3
    fmul d1,d1,d0
    fdiv d0,d4,d1
    b exp
.size ARRHENIUS_SYMBOL,.-ARRHENIUS_SYMBOL

.p2align 4
.global ARRHENIUS_MODIFIED_SYMBOL
.type ARRHENIUS_MODIFIED_SYMBOL,%function
ARRHENIUS_MODIFIED_SYMBOL:
    stp x29,x30,[sp,#-80]!
    mov x29,sp
    stp d8,d9,[sp,#16]
    stp d10,d11,[sp,#32]
    stp d12,d13,[sp,#48]
    stp d14,d15,[sp,#64]
    ldr d8,[x0]
    ldr d9,[x1]
    ldr d10,[x2]
    ldr d11,[x3]
    ldr d12,[x4]
    ldr d13,[x6,#24]
    fsub d0,d8,d9
    fmul d0,d0,d10
    fmul d1,d9,d13
    fmul d1,d1,d8
    fdiv d0,d0,d1
    bl exp
    fmov d14,d0
    fmul d0,d9,d12
    fsub d0,d0,d11
    fmul d1,d9,d13
    fdiv d0,d0,d1
    bl exp
    fmov d1,#1.0
    fadd d0,d1,d0
    fmul d14,d14,d0
    fmul d0,d8,d12
    fsub d0,d0,d11
    fmul d1,d13,d8
    fdiv d0,d0,d1
    bl exp
    fmov d1,#1.0
    fadd d0,d1,d0
    fdiv d0,d14,d0
    ldp d8,d9,[sp,#16]
    ldp d10,d11,[sp,#32]
    ldp d12,d13,[sp,#48]
    ldp d14,d15,[sp,#64]
    ldp x29,x30,[sp],#80
    ret
.size ARRHENIUS_MODIFIED_SYMBOL,.-ARRHENIUS_MODIFIED_SYMBOL
.section .note.GNU-stack,"",%progbits
