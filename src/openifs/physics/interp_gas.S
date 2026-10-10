// Gas profile interpolation from formulations/openifs/physics/greenhouse_gas_profiles.md.
// Contract skills/md2asm/references/openifs/physics/greenhouse_gas_interpolation.md.
// x0..x7 hold eight address arguments. Three more pointers are on the stack.
// Pressure is Pa and output is gas mass per air mass, kg kg^-1.
// One rounded cumulative buffer replaces three original temporary arrays.
// All calculations use ordered FP64 operations. No numerical helper is called.
// x18 and preserved FP registers remain untouched. The frame preserves x19..x30.
.text
.p2align 4
.global md2asm_openifs_interp_gas
.type md2asm_openifs_interp_gas,%function
md2asm_openifs_interp_gas:
    mov x17,sp
    stp x29,x30,[sp,#-128]!
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    ldrsw x26,[x2]
    ldrsw x27,[x5]
    ldrsw x28,[x6]
    ldrsw x0,[x0]
    ldrsw x1,[x1]
    sub x0,x0,#1
    sub x1,x1,#1
    cmp x0,x1
    b.gt .Lgas_interp_restore
    cmp x28,#0
    b.le .Lgas_interp_restore
    mov x2,x3
    mov x3,x4
    ldp x8,x24,[x17]
    ldr x25,[x17,#16]
    ldr x19,[x7]
    ldr x20,[x7,#40]
    ldr x21,[x8]
    ldr x22,[x8,#40]
    ldr x23,[x8,#64]
    mov x17,#1
    cmp x20,#0
    csel x20,x17,x20,eq
    cmp x22,#0
    csel x22,x17,x22,eq
    lsl x20,x20,#3
    lsl x22,x22,#3
    lsl x23,x23,#3
    lsl x26,x26,#3
    add x17,x27,#1
    lsl x17,x17,#3
    add x17,x17,#15
    and x17,x17,#-16
    sub sp,sp,x17
    mov x4,sp
.Lgas_interp_column:
    ldrsw x5,[x2,x0,lsl #2]
    sub x5,x5,#1
    madd x5,x5,x22,x21
    ldr d6,[x3,x0,lsl #3]
    fmov d5,xzr
    str d5,[x4]
    mov x6,#0
.Lgas_interp_prefix:
    ldr d0,[x5]
    ldr d1,[x5,x22]
    fsub d2,d1,d0
    fmul d3,d6,d2
    fadd d4,d0,d3
    fadd d5,d5,d4
    add x6,x6,#1
    str d5,[x4,x6,lsl #3]
    add x5,x5,x23
    cmp x6,x27
    b.lt .Lgas_interp_prefix
    add x13,x24,x0,lsl #3
    add x13,x13,x26
    add x14,x25,x0,lsl #3
    mov x10,#1
    fmov d7,xzr
.Lgas_interp_model_layer:
    ldr d0,[x13]
    mov x11,#0
    mov x8,x19
.Lgas_interp_search:
    ldr d1,[x8]
    ldr d2,[x8,x20]
    fcmp d0,d1
    b.lt .Lgas_interp_next_interval
    fcmp d0,d2
    b.lt .Lgas_interp_interval_found
.Lgas_interp_next_interval:
    add x11,x11,#1
    cmp x11,x27
    b.ge .Lgas_interp_last_interval
    add x8,x8,x20
    b .Lgas_interp_search
.Lgas_interp_last_interval:
    sub x11,x27,#1
    madd x8,x11,x20,x19
    ldr d1,[x8]
    ldr d2,[x8,x20]
.Lgas_interp_interval_found:
    fsub d3,d0,d1
    fsub d4,d2,d1
    fdiv d3,d3,d4
    ldr d1,[x4,x11,lsl #3]
    add x15,x11,#1
    ldr d2,[x4,x15,lsl #3]
    fsub d4,d2,d1
    fmul d4,d3,d4
    fadd d5,d1,d4
    sub x8,x13,x26
    ldr d1,[x8]
    fsub d2,d0,d1
    fsub d3,d5,d7
    fdiv d3,d3,d2
    str d3,[x14]
    fmov d7,d5
    add x13,x13,x26
    add x14,x14,x26
    add x10,x10,#1
    cmp x10,x28
    b.le .Lgas_interp_model_layer
    add x0,x0,#1
    cmp x0,x1
    b.le .Lgas_interp_column
.Lgas_interp_restore:
    mov sp,x29
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp],#128
    ret
.size md2asm_openifs_interp_gas,.-md2asm_openifs_interp_gas
.section .note.GNU-stack,"",%progbits
