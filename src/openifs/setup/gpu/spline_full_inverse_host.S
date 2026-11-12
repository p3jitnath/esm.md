/* Complete spline inverse from LU factors; skills/md2fort-gpu/references/openifs/setup/spline_inverse_from_factors_complete_contract.md. */
#include "../../support/gpu/preserved_weather_calls.inc.S"
.arch armv8-a
.text
.p2align 4
.global md2asm_spline_inverse_from_lu
.type md2asm_spline_inverse_from_lu,%function
md2asm_spline_inverse_from_lu:
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
    mov x5,#0
.Lpivots:
    ldr w6,[x2,x5,lsl #2]
    add w7,w5,#1
    cmp w6,w7
    b.lt .Lreject
    cmp w6,w4
    b.gt .Lreject
    add x5,x5,#1
    cmp w5,w4
    b.lt .Lpivots
    stp x29,x30,[sp,#-16]!
    bl md2asm_spline_inverse_from_lu_gpu_phase
    ldp x29,x30,[sp],#16
    ret
.Lreject:
    mov w0,#2
    ret
.size md2asm_spline_inverse_from_lu,.-md2asm_spline_inverse_from_lu
.section .note.GNU-stack,"",%progbits
