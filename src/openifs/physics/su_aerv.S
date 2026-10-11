/* Cumulative aerosol optical-depth profiles from formulations/openifs/physics/aerosol_vertical_profiles.md. */
#ifndef SU_AERV_SYMBOL
#define SU_AERV_SYMBOL su_aerv_
#endif
#ifndef SU_AERV_POWER
#define SU_AERV_POWER md2asm_pow_original_rounding_candidate
#endif
.text
.p2align 4
.global SU_AERV_SYMBOL
.type SU_AERV_SYMBOL,%function
SU_AERV_SYMBOL:
    sub sp,sp,#512
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    stp x29,x30,[sp,#96]
    stp d8,d9,[sp,#112]
    mov x19,x0
    mov x21,x2
    mrs x9,fpcr
    cbnz x9,.Lreject
    ldrsw x20,[x1]
    cmp x20,#0
    b.lt .Lreject
    cmp x20,#512
    b.gt .Lreject
    add x20,x20,#1
    adrp x27,.Lconstants
    add x27,x27,:lo12:.Lconstants
    mov x23,#0
.Lmetadata:
    add x24,x19,#656
    ldr d1,[x24,x23,lsl #3]
    fcmp d1,#0.0
    b.vs .Lreject
    ldr d0,[x27,#8]
    fcmp d1,d0
    b.lt .Lreject
    ldr d0,[x27,#16]
    fcmp d1,d0
    b.gt .Lreject
    ldr d0,[x27]
    fdiv d0,d0,d1
    ldr d1,[x27,#8]
    fmax d0,d1,d0
    add x9,sp,#256
    str d0,[x9,x23,lsl #3]
    add x24,x19,#1480
    add x24,x24,x23,lsl #6
    ldr x9,[x24,#16]
    cmp x9,#8
    b.ne .Lreject
    ldr x9,[x24,#40]
    cmp x9,#1
    b.ne .Lreject
    ldr x9,[x24,#48]
    cmp x9,#1
    b.gt .Lreject
    ldr x10,[x24,#8]
    neg x11,x9
    cmp x10,x11
    b.ne .Lreject
    ldr x11,[x24,#56]
    cmp x11,x20
    b.lt .Lreject
    ldr x9,[x24]
    cbz x9,.Lreject
    tst x9,#7
    b.ne .Lreject
    add x10,x10,#1
    add x9,x9,x10,lsl #3
    add x10,sp,#304
    str x9,[x10,x23,lsl #3]
    add x23,x23,#1
    cmp x23,#5
    b.lt .Lmetadata
    mov x22,#0
    fmov d2,xzr
.Lcoordinate_guard:
    ldr d0,[x21,x22,lsl #3]
    fcmp d0,#0.0
    b.vs .Lreject
    b.lt .Lreject
    ldr d1,[x27,#8]
    fcmp d0,d1
    b.gt .Lreject
    fcmp d0,d2
    b.lt .Lreject
    fmov d2,d0
    add x22,x22,#1
    cmp x22,x20
    b.lt .Lcoordinate_guard
    mov x23,#0
    fmov d0,xzr
.Ltop_zero:
    add x9,sp,#304
    ldr x9,[x9,x23,lsl #3]
    str d0,[x9]
    add x23,x23,#1
    cmp x23,#5
    b.lt .Ltop_zero
    mov x22,#0
    ldr d8,[x21]
    fcmp d8,#0.0
    b.eq .Lnext_level
.Llevel:
    ldr d8,[x21,x22,lsl #3]
    mov x23,#0
.Ltype:
    fmov d0,d8
    add x9,sp,#256
    ldr d1,[x9,x23,lsl #3]
    bl SU_AERV_POWER
    add x9,sp,#304
    ldr x9,[x9,x23,lsl #3]
    str d0,[x9,x22,lsl #3]
    add x23,x23,#1
    cmp x23,#5
    b.lt .Ltype
.Lnext_level:
    add x22,x22,#1
    cmp x22,x20
    b.lt .Llevel
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp,#96]
    ldp d8,d9,[sp,#112]
    add sp,sp,#512
    ret
.Lreject:
    bl abort
    brk #0
.size SU_AERV_SYMBOL,.-SU_AERV_SYMBOL
.section .rodata
.p2align 3
.Lconstants:
    .double 8434.0,1.0,1000000.0
.section .note.GNU-stack,"",%progbits
