/* Apply supplied physical rates through the complete accepted child.
 * Physics input: formulations/openifs/physics/physics_increment.md
 * Contract: skills/md2asm/references/openifs/physics/ec_phys_lslphy.md
 * All intervals are seconds. Each child product and sum rounds separately.
 * Fourteen ordinary addresses use the frozen GNU Fortran 12.3 interface.
 * Own only the physics interval and the complete declared state outputs. */
.text
.p2align 4
.global md2asm_ec_phys_lslphy
.type md2asm_ec_phys_lslphy,%function
md2asm_ec_phys_lslphy:
    mrs x9,fpcr
    cbnz x9,.Lec_controller_reject
    cbz x0,.Lec_controller_reject
    cbz x1,.Lec_controller_reject
    cbz x2,.Lec_controller_reject
    cbz x3,.Lec_controller_reject
    cbz x4,.Lec_controller_reject
    cbz x5,.Lec_controller_reject
    cbz x6,.Lec_controller_reject
    cbz x7,.Lec_controller_reject
    ldr w9,[x6]
    cmp w9,#1
    b.hi .Lec_controller_reject
    ldr w9,[x0,#5144]
    cmp w9,#1
    b.lt .Lec_controller_reject
    cmp w9,#4096
    b.gt .Lec_controller_reject
    ldr w10,[x0,#5224]
    cmp w10,#512
    b.hi .Lec_controller_reject
    ldrsw x11,[x0,#5244]
    cmp x11,#1
    b.gt .Lec_controller_reject
    ldrsw x12,[x0,#5248]
    cmp x12,x10
    b.lt .Lec_controller_reject
    sub x13,x12,x11
    add x13,x13,#1
    cmp x13,#1024
    b.hi .Lec_controller_reject
    ldr w10,[x4]
    cmp w10,#1
    b.lt .Lec_controller_reject
    add w11,w9,#1
    cmp w10,w11
    b.gt .Lec_controller_reject
    ldr w11,[x5]
    cmp w11,w9
    b.gt .Lec_controller_reject
    sub w10,w10,#1
    cmp w11,w10
    b.lt .Lec_controller_reject
    ldr d0,[x7]
    movz x9,#0xbea8
    movk x9,#0x14,lsl #16
    ldr d1,[x2,x9]
    ldr d2,[x3,#8]
    fmov x9,d0
    ubfx x9,x9,#52,#11
    cmp x9,#2047
    b.eq .Lec_controller_reject
    fmov x9,d1
    ubfx x9,x9,#52,#11
    cmp x9,#2047
    b.eq .Lec_controller_reject
    fmov x9,d2
    ubfx x9,x9,#52,#11
    cmp x9,#2047
    b.eq .Lec_controller_reject
    fcmp d0,#0.0
    b.lt .Lec_controller_reject
    fcmp d1,#0.0
    b.lt .Lec_controller_reject
    fcmp d2,#0.0
    b.lt .Lec_controller_reject
    fcmp d0,d1
    b.eq .Lec_controller_child
    fmov d3,#1.0
    fcmp d0,d3
    fcsel d0,d0,d3,ge
    str d0,[x3,#8]
.Lec_controller_child:
    add x9,x3,#8
    mov x3,x6
    mov x6,x9
    add x2,x2,#184
    ldp x9,x10,[sp,#0]
    ldp x11,x12,[sp,#16]
    ldp x7,x13,[sp,#32]
    sub sp,sp,#80
    stp x29,x30,[sp,#48]
    stp x13,x9,[sp,#0]
    stp x10,x11,[sp,#16]
    str x12,[sp,#32]
    bl md2asm_ec_private_gpaddslphy
    ldp x29,x30,[sp,#48]
    add sp,sp,#80
    ret
.Lec_controller_reject:
    brk #0xe41
.size md2asm_ec_phys_lslphy,.-md2asm_ec_phys_lslphy
.section .note.GNU-stack,"",%progbits
