/* GPU contract: skills/md2asm-gpu/references/openifs/setup/spline_lu_factorization_complete_contract.md */
#include "../../support/gpu/preserved_weather_calls.inc.S"
.arch armv8-a
.text
.p2align 4
.global md2asm_spline_lu_factor
.type md2asm_spline_lu_factor,%function
md2asm_spline_lu_factor:
    cbz x0,.Lreject
    cbz x1,.Lreject
    cbz x2,.Lreject
    cbz x3,.Lreject
    orr x9,x0,x2
    orr x9,x9,x3
    tst x9,#3
    b.ne .Lreject
    tst x1,#7
    b.ne .Lreject
    ldr w4,[x0]
    sub w9,w4,#1
    cmp w9,#23
    b.hi .Lreject
    mul w5,w4,w4
    mov x6,#0
.Lfinite_input:
    ldr x7,[x1,x6,lsl #3]
    ubfx x8,x7,#52,#11
    cmp x8,#2047
    b.eq .Lreject
    add x6,x6,#1
    cmp w6,w5
    b.lt .Lfinite_input
    stp x29,x30,[sp,#-176]!
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    stp d8,d9,[sp,#96]
    stp d10,d11,[sp,#112]
    stp d12,d13,[sp,#128]
    stp d14,d15,[sp,#144]
    mov x19,x1
    mov x20,x2
    mov x21,x3
    mov w22,w4
    mov x23,#0
    str wzr,[x21]
    fmov d12,#-1.0
    mov x9,#0x0010000000000000
    fmov d13,x9
    fmov d14,xzr
    fmov d15,#1.0
    bl md2asm_spline_lu_gpu_phase
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp d8,d9,[sp,#96]
    ldp d10,d11,[sp,#112]
    ldp d12,d13,[sp,#128]
    ldp d14,d15,[sp,#144]
    ldp x29,x30,[sp],#176
    mov w0,#0
    ret
.Lreject:
    mov w0,#2
    ret
.size md2asm_spline_lu_factor,.-md2asm_spline_lu_factor
.section .note.GNU-stack,"",%progbits
