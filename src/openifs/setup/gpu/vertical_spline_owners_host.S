#include "../../support/gpu/preserved_weather_calls.inc.S"
.arch armv8-a
.text
.p2align 4
.global md2asm_initialize_vertical_spline_owners
.type md2asm_initialize_vertical_spline_owners,%function
md2asm_initialize_vertical_spline_owners:
    cbz x0,.Lreject
    cbz x1,.Lreject
    cbz x2,.Lreject
    orr x9,x0,x1
    orr x9,x9,x2
    tst x9,#7
    b.ne .Lreject
    mrs x9,fpcr
    cbnz x9,.Lreject
    ldr x9,[x2]
    cbnz x9,.Lreject
    mov x9,#0
.Lowner_guard:
    ldr x10,[x1,x9,lsl #3]
    cbz x10,.Lreject
    tst x10,#7
    b.ne .Lreject
    add x9,x9,#1
    cmp x9,#5
    b.lt .Lowner_guard
    ldr x9,[x0]
    cbnz x9,.Lreject
    ldr x9,[x0,#160]
    mov x10,#0x3ff0000000000000
    cmp x9,x10
    b.ne .Lreject
    fmov d1,xzr
    mov x9,#1
.Leta_guard:
    ldr x10,[x0,x9,lsl #3]
    ubfx x11,x10,#52,#11
    cmp x11,#2047
    b.eq .Lreject
    fmov d0,x10
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,4,none,d0,d1,comparison // fcmp d0,d1
    b.le .Lreject
    fmov d1,d0
    add x9,x9,#1
    cmp x9,#21
    b.lt .Leta_guard
    stp x29,x30,[sp,#-128]!
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x18,[sp,#80]
    mov x19,x0
    mov x20,x1
    mov x21,x2
    mov x22,#0
    mov x26,#0
    bl __errno_location
    mov x24,x0
    ldr w25,[x24]
    mov x0,#61856
    str x0,[sp,#96]
    bl malloc
    cbz x0,.Lallocation_failure
    mov x22,x0
    mov x23,#0
    adrp x27,.Loperator_controls
    add x27,x27,:lo12:.Loperator_controls
.Loperator:
    mov x0,x27
    mov x1,x19
    add x2,x19,#8
    ldr x3,[x20,x23,lsl #3]
    mov x4,x22
    add x5,sp,#96
    bl md2asm_selected_spline_operator
    cbnz w0,.Lnumerical_failure
    cmp x23,#1
    b.ne .Lnext_operator
    mov x0,#3192
    bl malloc
    cbz x0,.Lallocation_failure
    mov x26,x0
    ldr x9,[x20,#8]
    mov x10,#0
.Lcopy:
    ldr x11,[x9,x10,lsl #3]
    str x11,[x26,x10,lsl #3]
    add x10,x10,#1
    cmp x10,#399
    b.lt .Lcopy
    str x26,[x21]
    mov x9,#-20
    str x9,[x21,#8]
    mov x9,#8
    str x9,[x21,#16]
    str xzr,[x21,#24]
    mov w10,#0x302
    str w10,[x21,#28]
    str x9,[x21,#32]
    mov x9,#1
    str x9,[x21,#40]
    str x9,[x21,#48]
    mov x10,#19
    str x10,[x21,#56]
    str x10,[x21,#64]
    str x9,[x21,#72]
    mov x10,#21
    str x10,[x21,#80]
.Lnext_operator:
    add x23,x23,#1
    add x27,x27,#24
    cmp x23,#5
    b.lt .Loperator
    mov w27,#0
    b .Lcleanup
.Lallocation_failure:
    mov w27,#1
    b .Ldiscard_copy
.Lnumerical_failure:
    mov w27,#3
.Ldiscard_copy:
    cbz x26,.Lcleanup
    mov x0,x26
    bl free
    str xzr,[x21]
.Lcleanup:
    cbz x22,.Lreturn
    mov x0,x22
    bl free
.Lreturn:
    str w25,[x24]
    mov w0,w27
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x18,[sp,#80]
    ldp x29,x30,[sp],#128
    ret
.Lreject:
    mov w0,#2
    ret
.size md2asm_initialize_vertical_spline_owners,.-md2asm_initialize_vertical_spline_owners
.p2align 4
.global md2asm_release_vertical_spline_copy
.type md2asm_release_vertical_spline_copy,%function
md2asm_release_vertical_spline_copy:
    cbz x0,.Lrelease_reject
    tst x0,#7
    b.ne .Lrelease_reject
    ldr x9,[x0]
    cbz x9,.Lreleased
    stp x29,x30,[sp,#-48]!
    stp x19,x20,[sp,#16]
    stp x21,x18,[sp,#32]
    mov x29,sp
    mov x19,x0
    bl __errno_location
    mov x20,x0
    ldr w21,[x20]
    ldr x0,[x19]
    bl free
    str xzr,[x19]
    str w21,[x20]
    ldp x19,x20,[sp,#16]
    ldp x21,x18,[sp,#32]
    ldp x29,x30,[sp],#48
.Lreleased:
    mov w0,#0
    ret
.Lrelease_reject:
    mov w0,#2
    ret
.size md2asm_release_vertical_spline_copy,.-md2asm_release_vertical_spline_copy
.section .rodata
.p2align 2
.Loperator_controls:
    .word -1,20,1,0,1,1
    .word 1,19,0,0,0,0
    .word 1,19,0,1,0,1
    .word 1,19,1,0,1,0
    .word 1,19,0,0,1,1
.section .note.GNU-stack,"",%progbits
