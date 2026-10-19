// GPU contract: skills/md2asm-gpu/references/openifs/setup/selected_spline_inverse_complete_contract.md
#include "../../support/gpu/preserved_weather_calls.inc.S"
.arch armv8-a
.text
.p2align 4
.global md2asm_selected_spline_inverse
.type md2asm_selected_spline_inverse,%function
md2asm_selected_spline_inverse:
    cbz x0,.Lreject
    cbz x1,.Lreject
    cbz x2,.Lreject
    cbz x3,.Lreject
    orr x9,x0,x1
    tst x9,#3
    b.ne .Lreject
    orr x9,x2,x3
    tst x9,#7
    b.ne .Lreject
    ldr w4,[x1]
    cmp w4,#4
    b.eq .Ldimension_ok
    cmp w4,#21
    b.ne .Lreject
.Ldimension_ok:
    ldr w6,[x0]
    cmp w6,#1
    b.hi .Lreject
    mul w5,w4,w4
    mov x9,#0
.Lfinite_input:
    ldr x10,[x2,x9,lsl #3]
    ubfx x11,x10,#52,#11
    cmp x11,#2047
    b.eq .Lreject
    add x9,x9,#1
    cmp w9,w5
    b.lt .Lfinite_input
    stp x29,x30,[sp,#-16]!
    bl md2asm_selected_spline_inverse_gpu_phase
    ldp x29,x30,[sp],#16
    ret
.Lreject:
    mov w0,#2
    ret
.size md2asm_selected_spline_inverse,.-md2asm_selected_spline_inverse
.section .note.GNU-stack,"",%progbits
