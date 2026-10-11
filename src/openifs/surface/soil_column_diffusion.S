/* Complete layer solve from formulations/openifs/surface/soil_column_diffusion.md, revision 1.0, WD-1 and WD-2.
 * The ABI, signed strides, source order and limits are in skills/md2asm/references/openifs/surface/soil_column_diffusion.md.
 * Eleven addresses provide four scalar bounds, four input descriptors, TSOIL, output and land flags.
 * A fixed 128-byte frame and at most 4096 bytes of aligned scratch preserve every required register. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __srfwdif_mod_MOD_srfwdif
#endif
.text
.p2align 4
.global md2asm_soil_column_diffusion
.global ORIGINAL_SYMBOL
.type md2asm_soil_column_diffusion,%function
.type ORIGINAL_SYMBOL,%function
.macro column_element descriptor
    ldr x9,[\descriptor]
    ldr x10,[\descriptor,#40]
    ldr x11,[\descriptor,#64]
    mul x10,x10,x28
    madd x10,x11,x25,x10
    add x9,x9,x10,lsl #3
.endm
md2asm_soil_column_diffusion:
ORIGINAL_SYMBOL:
    ldr w9,[x3]
    cmp w9,#2
    b.lt .Ldiffusion_reject
    cmp w9,#512
    b.gt .Ldiffusion_reject
    sub sp,sp,#128
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    stp d8,d9,[sp,#96]
    mov x29,sp
    ldr w9,[x0]
    sub w9,w9,#1
    str w9,[x29,#112]
    ldr w10,[x1]
    str w10,[x29,#116]
    ldrsw x26,[x3]
    mov x19,x4
    mov x20,x5
    mov x21,x6
    mov x22,x7
    ldr x9,[x29,#128]
    ldp x23,x24,[x29,#136]
    fmov d9,#1.0
    ldr d0,[x9,#144]
    fdiv d8,d9,d0
    lsl x9,x26,#3
    add x9,x9,#15
    and x9,x9,#-16
    sub sp,sp,x9
    mov x27,sp
    ldrsw x28,[x29,#112]
    ldrsw x10,[x29,#116]
    cmp x28,x10
    b.ge .Ldiffusion_return
.Ldiffusion_column:
    ldr x9,[x24]
    ldr x10,[x24,#40]
    mul x10,x10,x28
    ldr w9,[x9,x10,lsl #2]
    cbz w9,.Ldiffusion_next_column
    mov x25,#0
.Ldiffusion_rhs:
    column_element x19
    ldr d0,[x9]
    fmul d0,d8,d0
    column_element x21
    ldr d1,[x9]
    fadd d0,d0,d1
    column_element x23
    str d0,[x9]
    add x25,x25,#1
    cmp x25,x26
    b.lt .Ldiffusion_rhs
    mov x25,#0
    column_element x20
    ldr d7,[x9]
    column_element x22
    ldr d0,[x9]
    fdiv d6,d9,d0
    fmul d2,d7,d6
    fadd d3,d9,d2
    fdiv d3,d9,d3
    fmul d4,d3,d2
    str d4,[x27]
    column_element x23
    ldr d0,[x9]
    fmul d0,d3,d0
    str d0,[x9]
    mov x25,#1
.Ldiffusion_down:
    column_element x22
    ldr d0,[x9]
    fdiv d6,d9,d0
    fmul d0,d7,d6
    sub x10,x25,#1
    ldr d1,[x27,x10,lsl #3]
    fsub d2,d9,d1
    fmul d2,d0,d2
    fadd d2,d9,d2
    column_element x20
    ldr d7,[x9]
    fmul d4,d7,d6
    fadd d2,d2,d4
    fdiv d3,d9,d2
    add x10,x25,#1
    cmp x10,x26
    b.ge .Ldiffusion_bottom
    fmul d2,d3,d4
    str d2,[x27,x25,lsl #3]
.Ldiffusion_bottom:
    column_element x23
    ldr d1,[x9]
    ldr x10,[x23,#64]
    sub x11,x9,x10,lsl #3
    ldr d2,[x11]
    fmul d2,d0,d2
    fadd d1,d1,d2
    fmul d1,d3,d1
    str d1,[x9]
    add x25,x25,#1
    cmp x25,x26
    b.lt .Ldiffusion_down
    sub x25,x26,#2
.Ldiffusion_up:
    column_element x23
    ldr d0,[x9]
    ldr x10,[x23,#64]
    add x11,x9,x10,lsl #3
    ldr d1,[x11]
    ldr d2,[x27,x25,lsl #3]
    fmul d1,d2,d1
    fadd d0,d0,d1
    str d0,[x9]
    subs x25,x25,#1
    b.ge .Ldiffusion_up
.Ldiffusion_next_column:
    add x28,x28,#1
    ldrsw x10,[x29,#116]
    cmp x28,x10
    b.lt .Ldiffusion_column
.Ldiffusion_return:
    mov sp,x29
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    ldp d8,d9,[sp,#96]
    add sp,sp,#128
    ret
.Ldiffusion_reject:
    mov w0,#119
    b _exit
.size md2asm_soil_column_diffusion,.-md2asm_soil_column_diffusion
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .note.GNU-stack,"",%progbits
