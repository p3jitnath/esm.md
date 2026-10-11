/* Complete pressure-weighted monthly gas amount from formulation revision 1.0.
 * Physics is formulations/openifs/physics/monthly_gas_climatology.md, MG-1 and MG-2.
 * Interface and bounds are in skills/md2asm/references/openifs/physics/climatology_layer_mass.md.
 * Seven addresses select months, weight, pressure, scaling, volume and amount.
 * GNU descriptors give signed strides in eight-byte elements, with latitude first.
 * The 112-byte aligned frame preserves x19 through x30 and d8 through d9.
 * Every subtraction, multiplication and addition rounds separately. */
#ifndef CLIMATOLOGY_LAYER_SYMBOL
#define CLIMATOLOGY_LAYER_SYMBOL md2asm_climatology_layer
#endif
.text
.p2align 4
.global CLIMATOLOGY_LAYER_SYMBOL
.type CLIMATOLOGY_LAYER_SYMBOL,%function
CLIMATOLOGY_LAYER_SYMBOL:
    sub sp,sp,#112
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    stp d8,d9,[sp,#96]
    ldp x9,x10,[x3,#48]
    sub x20,x10,x9
    cbz x20,.Lmonthly_layer_return
    ldp x9,x10,[x6,#48]
    sub x19,x10,x9
    add x19,x19,#1
    cbz x19,.Lmonthly_layer_return
    ldr x21,[x3]
    ldr x22,[x3,#40]
    lsl x22,x22,#3
    ldr x23,[x6]
    ldr x24,[x6,#40]
    lsl x24,x24,#3
    ldr x25,[x6,#64]
    lsl x25,x25,#3
    ldr x12,[x5,#40]
    lsl x12,x12,#3
    ldr x13,[x5,#64]
    lsl x13,x13,#3
    ldr x14,[x5,#88]
    lsl x14,x14,#3
    ldr x9,[x5]
    ldrsw x10,[x0]
    sub x10,x10,#1
    madd x26,x10,x14,x9
    ldrsw x10,[x1]
    sub x10,x10,#1
    madd x27,x10,x14,x9
    ldr d8,[x2]
    ldr d9,[x4]
    ldr d0,[x21]
    mov x28,#0
.Lmonthly_layer_level:
    add x21,x21,x22
    ldr d1,[x21]
    fsub d2,d1,d0
    fmul d2,d2,d9
    fmov d0,d1
    mov x10,x26
    mov x11,x27
    mov x16,x23
    mov x17,x19
.Lmonthly_layer_latitude:
    ldr d3,[x10]
    ldr d4,[x11]
    fsub d5,d3,d4
    fmul d5,d8,d5
    fadd d5,d4,d5
    fmul d5,d2,d5
    str d5,[x16]
    add x10,x10,x12
    add x11,x11,x12
    add x16,x16,x24
    subs x17,x17,#1
    b.ne .Lmonthly_layer_latitude
    add x26,x26,x13
    add x27,x27,x13
    add x23,x23,x25
    add x28,x28,#1
    cmp x28,x20
    b.lt .Lmonthly_layer_level
.Lmonthly_layer_return:
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    ldp d8,d9,[sp,#96]
    add sp,sp,#112
    ret
.size CLIMATOLOGY_LAYER_SYMBOL,.-CLIMATOLOGY_LAYER_SYMBOL
.section .note.GNU-stack,"",%progbits
