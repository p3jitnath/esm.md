/* Repair humidity and retain its pressure-weighted diagnostic flux.
 * Physics formulations/openifs/physics/humidity_floor.md.
 * Contract skills/md2asm/references/openifs/physics/qnegat.md.
 * Eleven addresses, including a nullable final tendency input. */
#ifndef QNEGAT_SYMBOL
#define QNEGAT_SYMBOL qnegat_
#endif
.text
.p2align 4
.global QNEGAT_SYMBOL
.type QNEGAT_SYMBOL,%function
QNEGAT_SYMBOL:
    mov x9,sp
    stp x29,x30,[sp,#-96]!
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    ldr d18,[x0,#8]
    ldrsw x19,[x1]
    ldrsw x20,[x2]
    ldrsw x21,[x3]
    ldrsw x22,[x4]
    ldr d16,[x5]
    mov x23,x6
    mov x24,x7
    ldp x25,x26,[x9]
    ldr x27,[x9,#16]
    cmp x19,x20
    b.gt .Lhumidity_return
    fmov d0,#1.0
    fdiv d17,d0,d16
    adrp x9,:got:__yomcst_MOD_rg
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rg]
    ldr d19,[x9]
    mov x28,x19
.Lhumidity_column:
    sub x9,x28,#1
    mov x8,#0
.Lhumidity_initialize:
    fmov d0,xzr
    cbz x27,.Lhumidity_initialize_store
    ldr d0,[x27,x9,lsl #3]
.Lhumidity_initialize_store:
    str d0,[x24,x9,lsl #3]
    add x9,x9,x21
    add x8,x8,#1
    cmp x8,x22
    b.lt .Lhumidity_initialize
    sub x9,x28,#1
    mov x8,#0
.Lhumidity_repair:
    ldr d0,[x24,x9,lsl #3]
    ldr d1,[x23,x9,lsl #3]
    fmul d2,d16,d0
    fadd d2,d1,d2
    fsub d2,d18,d2
    fmov d3,xzr
    fmax d2,d3,d2
    fmul d2,d17,d2
    fadd d0,d0,d2
    str d0,[x24,x9,lsl #3]
    add x8,x8,#1
    cmp x8,x22
    b.ge .Lhumidity_extract_start
    add x10,x9,x21
    add x11,x10,x21
    ldr d3,[x25,x9,lsl #3]
    ldr d4,[x25,x10,lsl #3]
    ldr d5,[x25,x11,lsl #3]
    fsub d3,d4,d3
    fsub d4,d5,d4
    fmul d2,d2,d3
    fdiv d2,d2,d4
    ldr d0,[x24,x10,lsl #3]
    fsub d0,d0,d2
    str d0,[x24,x10,lsl #3]
    mov x9,x10
    b .Lhumidity_repair
.Lhumidity_extract_start:
    cbz x27,.Lhumidity_flux_start
    sub x9,x28,#1
    mov x8,#0
.Lhumidity_extract:
    ldr d0,[x24,x9,lsl #3]
    ldr d1,[x27,x9,lsl #3]
    fsub d0,d0,d1
    str d0,[x24,x9,lsl #3]
    add x9,x9,x21
    add x8,x8,#1
    cmp x8,x22
    b.lt .Lhumidity_extract
.Lhumidity_flux_start:
    sub x9,x28,#1
    mov x8,#0
    fmov d20,xzr
.Lhumidity_flux:
    add x10,x9,x21
    ldr d0,[x24,x9,lsl #3]
    ldr d1,[x25,x9,lsl #3]
    ldr d2,[x25,x10,lsl #3]
    fsub d1,d2,d1
    fneg d0,d0
    fmul d0,d0,d1
    fdiv d0,d0,d19
    fadd d20,d0,d20
    ldr d0,[x26,x10,lsl #3]
    fadd d0,d0,d20
    str d0,[x26,x10,lsl #3]
    mov x9,x10
    add x8,x8,#1
    cmp x8,x22
    b.lt .Lhumidity_flux
    add x28,x28,#1
    cmp x28,x20
    b.le .Lhumidity_column
.Lhumidity_return:
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp],#96
    ret
.size QNEGAT_SYMBOL,.-QNEGAT_SYMBOL
.section .note.GNU-stack,"",%progbits
