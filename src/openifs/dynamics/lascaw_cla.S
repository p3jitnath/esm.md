/* Complete latitude weights from the frozen Markdown contract.
 * Every argument is a pointer in the original twenty-one-argument Arm ABI.
 * Binary64 calculations preserve the source's separate rounding points.
 * The input layout is B by 3 by L, and outputs are B by L by 3.
 */
.text
.p2align 4
.global lascaw_cla_assembly_
.type lascaw_cla_assembly_,%function
lascaw_cla_assembly_:
    cbz x6,.Lcla_guard_return
    ldr w8,[x6]
    cmp w8,#1
    b.hi .Lcla_guard_return
    mov w9,w8
    ldr w8,[x6,#4]
    cmp w8,#1
    b.hi .Lcla_guard_return
    orr w9,w9,w8,lsl #1
    ldr w8,[x6,#8]
    cmp w8,#1
    b.hi .Lcla_guard_return
    orr w9,w9,w8,lsl #2
    ldr w8,[x6,#12]
    cmp w8,#1
    b.hi .Lcla_guard_return
    orr w9,w9,w8,lsl #3
    cmp w9,#1
    b.eq .Lcla_guard_return
    cmp w9,#9
    b.eq .Lcla_guard_return
    ldrsw x10,[x3]
    ldrsw x11,[x2]
    cbz x10,.Lcla_guard_return
    cbz x11,.Lcla_guard_return
    ldrsw x12,[x4]
    ldrsw x13,[x5]
    sub x14,x13,x12
    add x14,x14,#1
    cmp x14,#0
    b.le .Lcla_guard_return

    /* Save every preserved register used by the complete two-pass body. */
    sub sp,sp,#208
    stp x19,x20,[sp]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    str x9,[sp,#96]
    str x7,[sp,#104]
    str x1,[sp,#112]
    str x14,[sp,#152]
    str x11,[sp,#160]
    mul x16,x10,x11
    lsl x16,x16,#3
    str x16,[sp,#136]
    lsl x17,x10,#3
    str x17,[sp,#144]
    sub x12,x12,#1
    lsl x12,x12,#3
    str x12,[sp,#168]
    ldrsw x15,[x0,#1672]
    str x15,[sp,#120]
    ldrsw x16,[x0,#1676]
    sub x16,x16,x15
    add x16,x16,#1
    lsl x16,x16,#3
    str x16,[sp,#128]
    ldr x15,[sp,#264]
    str x15,[sp,#176]
    ldr x15,[sp,#272]
    str x15,[sp,#184]
    ldr x15,[sp,#280]
    str x15,[sp,#192]
    ldr x24,[sp,#208]
    add x24,x24,x12,lsr #1
    ldr x22,[sp,#216]
    add x22,x22,x12
    ldr x23,[sp,#224]
    add x23,x23,x12
    ldr x25,[sp,#232]
    add x25,x25,x12
    ldr x26,[sp,#248]
    add x26,x26,x12
    ldr x19,[sp,#288]
    add x19,x19,x12
    ldr x20,[sp,#296]
    add x20,x20,x12
    ldr x21,[sp,#304]
    add x21,x21,x12
    sub x29,x17,x14,lsl #3
    ldr x27,[sp,#160]
    ldr x8,[sp,#96]
    ldr x9,[sp,#136]
    ldr x10,[sp,#144]
    fmov d6,#1.0
.Lcla_first_level:
    ldr x28,[sp,#152]
.Lcla_first_cell:
    ldrsw x11,[x24]
    add x11,x11,#1
    ldr x12,[sp,#120]
    sub x11,x11,x12
    lsl x13,x11,#3
    add x14,x11,x11,lsl #3
    lsl x14,x14,#3
    ldr d0,[x22]
    ldr d1,[x22,x10]
    add x11,x22,x10,lsl #1
    ldr d2,[x11]
    tbnz x8,#1,.Lcla_quadratic
    tbnz x8,#2,.Lcla_old_linear
    b .Lcla_low_done
.Lcla_quadratic:
    ldr d30,[x25]
    fsub d7,d6,d30
    fmul d31,d30,d7
    ldr x12,[sp,#176]
    add x12,x12,x13
    ldr x15,[sp,#128]
    ldr d3,[x12]
    fmul d3,d31,d3
    fadd d3,d3,d7
    ldr d4,[x12,x15]
    fmul d4,d31,d4
    fadd d4,d4,d30
    add x11,x12,x15,lsl #1
    ldr d5,[x11]
    fmul d5,d31,d5
    b .Lcla_low_done
.Lcla_old_linear:
    ldr d4,[x25]
    fsub d3,d6,d4
    fmov d5,xzr
.Lcla_low_done:
    tbnz x8,#0,.Lcla_diffusion
    tbnz x8,#1,.Lcla_quadratic_blend
    fmov d16,d0
    fmov d17,d1
    fmov d18,d2
    fmov d22,d0
    fmov d23,d1
    fmov d24,d2
    b .Lcla_first_write
.Lcla_quadratic_blend:
    ldr x11,[sp,#104]
    ldr d25,[x11]
    fsub d7,d3,d0
    fmul d16,d25,d7
    fadd d16,d0,d16
    fsub d7,d4,d1
    fmul d17,d25,d7
    fadd d17,d1,d17
    fsub d7,d5,d2
    fmul d18,d25,d7
    fadd d18,d2,d18
    fmov d22,d16
    fmov d23,d17
    fmov d24,d18
    b .Lcla_first_write
.Lcla_diffusion:
    ldr d25,[x26]
    fmov x11,d25
    and x11,x11,#0x8000000000000000
    fmov d29,#0.5
    fmov x12,d29
    orr x11,x11,x12
    fmov d29,x11
    fmov d31,#0.5
    fadd d7,d31,d29
    ldr x11,[sp,#104]
    ldr d28,[x11]
    fmul d7,d7,d28
    fsub d31,d29,d31
    ldr x12,[sp,#112]
    ldr d27,[x12,#128]
    fmul d31,d31,d27
    fsub d28,d7,d31
    ldr d26,[x12,#120]
    fsub d7,d3,d0
    fmul d16,d28,d7
    fadd d16,d0,d16
    fmul d19,d26,d7
    fadd d19,d0,d19
    fsub d7,d4,d1
    fmul d17,d28,d7
    fadd d17,d1,d17
    fmul d20,d26,d7
    fadd d20,d1,d20
    fsub d7,d5,d2
    fmul d18,d28,d7
    fadd d18,d2,d18
    fmul d21,d26,d7
    fadd d21,d2,d21
    ldr x11,[sp,#184]
    add x11,x11,x14
.macro cla_diffusion_row output,first,second,third
    ldr d7,[x11,#\first]
    fmul \output,d7,d19
    ldr d7,[x11,#\second]
    fmul d7,d7,d20
    fadd \output,\output,d7
    ldr d7,[x11,#\third]
    fmul d7,d7,d21
    fadd \output,\output,d7
.endm
    cla_diffusion_row d22,0,24,48
    cla_diffusion_row d23,8,32,56
    cla_diffusion_row d24,16,40,64
    fabs d25,d25
    fsub d22,d22,d16
    fmul d22,d25,d22
    fadd d22,d16,d22
    fsub d23,d23,d17
    fmul d23,d25,d23
    fadd d23,d17,d23
    fsub d24,d24,d18
    fmul d24,d25,d24
    fadd d24,d18,d24
.Lcla_first_write:
    str d16,[x19]
    str d17,[x19,x9]
    add x11,x19,x9,lsl #1
    str d18,[x11]
    str d22,[x21]
    str d23,[x21,x9]
    add x11,x21,x9,lsl #1
    str d24,[x11]
    ldr d28,[x23]
    ldr d29,[x23,x10]
    add x11,x23,x10,lsl #1
    ldr d30,[x11]
    str d28,[x20]
    str d29,[x20,x9]
    add x11,x20,x9,lsl #1
    str d30,[x11]
    add x19,x19,#8
    add x20,x20,#8
    add x21,x21,#8
    add x22,x22,#8
    add x23,x23,#8
    add x24,x24,#4
    add x25,x25,#8
    add x26,x26,#8
    subs x28,x28,#1
    b.ne .Lcla_first_cell
    add x19,x19,x29
    add x20,x20,x29
    add x21,x21,x29
    add x22,x22,x29
    add x22,x22,x10,lsl #1
    add x23,x23,x29
    add x23,x23,x10,lsl #1
    add x24,x24,x29,lsr #1
    add x25,x25,x29
    add x26,x26,x29
    subs x27,x27,#1
    b.ne .Lcla_first_level
    tbz x8,#3,.Lcla_finish

    /* Turbulence is a separate full pass, leaving correction untouched. */
    ldr x12,[sp,#168]
    ldr x19,[sp,#288]
    add x19,x19,x12
    ldr x21,[sp,#304]
    add x21,x21,x12
    ldr x24,[sp,#208]
    add x24,x24,x12,lsr #1
    ldr x26,[sp,#256]
    add x26,x26,x12
    ldr x27,[sp,#160]
    fmov d29,#2.0
.Lcla_turb_level:
    ldr x28,[sp,#152]
.Lcla_turb_cell:
    ldrsw x11,[x24]
    add x11,x11,#1
    ldr x12,[sp,#120]
    sub x11,x11,x12
    add x11,x11,x11,lsl #3
    lsl x11,x11,#3
    ldr x12,[sp,#192]
    add x11,x12,x11
    ldp d19,d20,[x11]
    ldp d21,d22,[x11,#16]
    ldp d23,d24,[x11,#32]
    ldp d25,d26,[x11,#48]
    ldr d27,[x11,#64]
    ldr d30,[x26]
    fmul d31,d30,d29
.macro cla_turb_matrix
    fmul d16,d19,d0
    fmul d7,d22,d1
    fadd d16,d16,d7
    fmul d7,d25,d2
    fadd d16,d16,d7
    fmul d17,d20,d0
    fmul d7,d23,d1
    fadd d17,d17,d7
    fmul d7,d26,d2
    fadd d17,d17,d7
    fmul d18,d21,d0
    fmul d7,d24,d1
    fadd d18,d18,d7
    fmul d7,d27,d2
    fadd d18,d18,d7
.endm
.macro cla_turb_update
    fsub d16,d16,d0
    fmul d16,d31,d16
    fadd d16,d0,d16
    fsub d17,d17,d1
    fmul d17,d31,d17
    fadd d17,d1,d17
    fsub d18,d18,d2
    fmul d18,d31,d18
    fadd d18,d2,d18
.endm
    ldr d0,[x19]
    ldr d1,[x19,x9]
    add x11,x19,x9,lsl #1
    ldr d2,[x11]
    cla_turb_matrix
    cla_turb_update
    str d16,[x19]
    str d17,[x19,x9]
    str d18,[x11]
    ldr d0,[x21]
    ldr d1,[x21,x9]
    add x11,x21,x9,lsl #1
    ldr d2,[x11]
    cla_turb_matrix
    cla_turb_update
    str d16,[x21]
    str d17,[x21,x9]
    str d18,[x11]
    add x19,x19,#8
    add x21,x21,#8
    add x24,x24,#4
    add x26,x26,#8
    subs x28,x28,#1
    b.ne .Lcla_turb_cell
    add x19,x19,x29
    add x21,x21,x29
    add x24,x24,x29,lsr #1
    add x26,x26,x29
    subs x27,x27,#1
    b.ne .Lcla_turb_level
.Lcla_finish:
    ldp x19,x20,[sp]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#208
.Lcla_guard_return:
    ret
.purgem cla_diffusion_row
.purgem cla_turb_matrix
.purgem cla_turb_update
.size lascaw_cla_assembly_,.-lascaw_cla_assembly_

/* Forward all twenty-one pointers without supplying any calculation. */
.p2align 4
.global lascaw_cla_abi_invoke
.type lascaw_cla_abi_invoke,%function
lascaw_cla_abi_invoke:
    sub sp,sp,#128
    stp x29,x30,[sp,#112]
    mov x9,x0
    ldp x10,x11,[x9,#64]
    stp x10,x11,[sp]
    ldp x10,x11,[x9,#80]
    stp x10,x11,[sp,#16]
    ldp x10,x11,[x9,#96]
    stp x10,x11,[sp,#32]
    ldp x10,x11,[x9,#112]
    stp x10,x11,[sp,#48]
    ldp x10,x11,[x9,#128]
    stp x10,x11,[sp,#64]
    ldp x10,x11,[x9,#144]
    stp x10,x11,[sp,#80]
    ldr x10,[x9,#160]
    str x10,[sp,#96]
    ldp x0,x1,[x9]
    ldp x2,x3,[x9,#16]
    ldp x4,x5,[x9,#32]
    ldp x6,x7,[x9,#48]
    bl lascaw_cla_assembly_
    ldp x29,x30,[sp,#112]
    add sp,sp,#128
    ret
.size lascaw_cla_abi_invoke,.-lascaw_cla_abi_invoke
.section .note.GNU-stack,"",%progbits
