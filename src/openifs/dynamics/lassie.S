/* Complete LASSIE from the frozen linear forecast terms, revision 1.0.
 * Source physics is formulations/openifs/dynamics/linear_forecast_terms.md.
 * The nineteen-address ABI and every buffer bound are in references/openifs/dynamics/lassie.md.
 * Columns change fastest. Every multiplication, addition and division rounds separately.
 * Accepted private children perform complete pressure, gradient and mixture stages.
 * The 512-byte aligned frame preserves x19 through x30 and holds outgoing addresses. */
#ifndef LASSIE_SYMBOL
#define LASSIE_SYMBOL md2asm_lassie
#endif
#ifndef LASSIE_SITNU
#define LASSIE_SITNU md2asm_lassie_sitnu
#endif
#ifndef LASSIE_SIGAM
#define LASSIE_SIGAM md2asm_lassie_sigam
#endif
#ifndef LASSIE_GPRCP
#define LASSIE_GPRCP md2asm_lassie_gprcp
#endif
.text
.p2align 4
.global LASSIE_SYMBOL
.type LASSIE_SYMBOL,%function
LASSIE_SYMBOL:
    mov x17,sp
    sub sp,sp,#512
    stp x19,x20,[sp,#64]
    stp x21,x22,[sp,#80]
    stp x23,x24,[sp,#96]
    stp x25,x26,[sp,#112]
    stp x27,x28,[sp,#128]
    stp x29,x30,[sp,#144]
    mov x29,sp
    stp x0,x1,[sp,#160]
    stp x2,x3,[sp,#176]
    stp x4,x5,[sp,#192]
    stp x6,x7,[sp,#208]
    ldp x9,x10,[x17,#0]
    stp x9,x10,[sp,#224]
    ldp x9,x10,[x17,#16]
    stp x9,x10,[sp,#240]
    ldp x9,x10,[x17,#32]
    stp x9,x10,[sp,#256]
    ldp x9,x10,[x17,#48]
    stp x9,x10,[sp,#272]
    ldp x9,x10,[x17,#64]
    stp x9,x10,[sp,#288]
    ldr x9,[x17,#80]
    str x9,[sp,#304]
    mov x9,#5144
    ldrsw x19,[x0,x9]
    mov x9,#5224
    ldrsw x20,[x0,x9]
    ldrsw x21,[x5]
    sub x21,x21,#1
    ldrsw x22,[x6]
    subs x9,x22,x21
    b.le .Llassie_return
    str w9,[sp,#316]
    mov w9,#1
    str w9,[sp,#312]
    mov w9,#9
    str w9,[sp,#320]
    ldr w9,[x4,#20]
    str w9,[sp,#328]
    ldr w9,[x4,#16]
    str w9,[sp,#332]
    mov x9,#4444
    ldr w9,[x3,x9]
    str w9,[sp,#336]
    mul x24,x19,x20
    lsl x24,x24,#3
    ldp x25,x26,[sp,#224]
    ldr x27,[sp,#168]
    mov x28,#0
    mov x23,#0
/* Each time plane contains one expansion stage and two gradient stages. */
.Llassie_time:
    ldr x0,[sp,#160]
    ldr x1,[sp,#184]
    mov x9,#5144
    add x2,x0,x9
    add x3,sp,#312
    mov w9,#1032
    cbz x23,.Llassie_div_field
    mov w9,#1188
.Llassie_div_field:
    ldrsw x9,[x27,x9]
    sub x9,x9,#1
    madd x4,x9,x24,x25
    add x4,x4,x21,lsl #3
    add x9,sp,#264
    ldr x5,[x9,x23,lsl #3]
    add x5,x5,x21,lsl #3
    add x9,sp,#248
    ldr x6,[x9,x23,lsl #3]
    add x6,x6,x21,lsl #3
    add x7,sp,#316
    bl LASSIE_SITNU
    mov x9,#5224
    ldr x10,[sp,#160]
    add x10,x10,x9
    str x10,[sp,#0]
    ldr x0,[sp,#160]
    ldr x1,[sp,#184]
    mov x9,#5144
    add x2,x0,x9
    add x3,sp,#312
    add x9,sp,#280
    add x9,x9,x23,lsl #4
    ldr x4,[x9]
    add x4,x4,x21,lsl #3
    mov w9,#1024
    mov w10,#1100
    cbz x23,.Llassie_l_fields
    mov w9,#1128
    mov w10,#1328
.Llassie_l_fields:
    ldrsw x9,[x27,x9]
    sub x9,x9,#1
    madd x5,x9,x24,x25
    add x5,x5,x21,lsl #3
    ldrsw x10,[x27,x10]
    sub x10,x10,#1
    mul x10,x10,x19
    add x6,x26,x10,lsl #3
    add x6,x6,x21,lsl #3
    add x7,sp,#316
    bl LASSIE_SIGAM
    mov x9,#5224
    ldr x10,[sp,#160]
    add x10,x10,x9
    str x10,[sp,#0]
    ldr x0,[sp,#160]
    ldr x1,[sp,#184]
    mov x9,#5144
    add x2,x0,x9
    add x3,sp,#312
    add x9,sp,#288
    add x9,x9,x23,lsl #4
    ldr x4,[x9]
    add x4,x4,x21,lsl #3
    mov w9,#1028
    mov w10,#1104
    cbz x23,.Llassie_m_fields
    mov w9,#1132
    mov w10,#1332
.Llassie_m_fields:
    ldrsw x9,[x27,x9]
    sub x9,x9,#1
    madd x5,x9,x24,x25
    add x5,x5,x21,lsl #3
    ldrsw x10,[x27,x10]
    sub x10,x10,#1
    mul x10,x10,x19
    add x6,x26,x10,lsl #3
    add x6,x6,x21,lsl #3
    add x7,sp,#316
    bl LASSIE_SIGAM
    ldr w9,[sp,#328]
    cbnz w9,.Llassie_moist
    add x23,x23,#1
    cmp x23,#2
    b.lt .Llassie_time
/* GPRCP returns the exact mixture gas constant for both temperature planes. */
.Llassie_moist:
    ldr w9,[sp,#332]
    cbz w9,.Llassie_rotation
    cbz x20,.Llassie_rotation
    mov x0,x24
    bl malloc
    cbz x0,.Llassie_alloc_failure
    mov x28,x0
    ldr x9,[sp,#160]
    mov x10,#5144
    add x0,x9,x10
    ldr x1,[sp,#200]
    ldr x2,[sp,#208]
    mov x10,#5224
    add x3,x9,x10
    mov x4,#0
    mov x5,#0
    mov x6,#0
    mov x7,#0
    stp xzr,xzr,[sp,#0]
    str xzr,[sp,#16]
    str x28,[sp,#24]
    str xzr,[sp,#32]
    ldr x9,[sp,#240]
    str x9,[sp,#40]
    mov x9,#0
    ldr w10,[sp,#328]
    cbnz w10,.Llassie_gas_mode
    add x9,sp,#320
.Llassie_gas_mode:
    str x9,[sp,#48]
    str xzr,[sp,#56]
    bl LASSIE_GPRCP
    adrp x9,:got:__yomcst_MOD_rd
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rd]
    ldr d0,[x9]
    ldr x12,[sp,#264]
    ldr x13,[sp,#272]
    ldr w17,[sp,#328]
    mov x9,#0
.Llassie_moist_layer:
    mov x10,x21
    mul x11,x9,x19
.Llassie_moist_cell:
    add x14,x11,x10
    lsl x14,x14,#3
    ldr d1,[x12,x14]
    ldr d2,[x28,x14]
    fmul d1,d0,d1
    fdiv d1,d1,d2
    str d1,[x12,x14]
    cbnz w17,.Llassie_moist_next
    ldr d1,[x13,x14]
    fmul d1,d0,d1
    fdiv d1,d1,d2
    str d1,[x13,x14]
.Llassie_moist_next:
    add x10,x10,#1
    cmp x10,x22
    b.lt .Llassie_moist_cell
    add x9,x9,#1
    cmp x9,x20
    b.lt .Llassie_moist_layer
    mov x0,x28
    bl free
    mov x28,#0
/* Coriolis acceleration couples the two independent horizontal winds. */
.Llassie_rotation:
    ldr w9,[sp,#336]
    cbz w9,.Llassie_return
    cbz x20,.Llassie_return
    mov x23,#0
.Llassie_rotation_time:
    add x9,sp,#280
    add x9,x9,x23,lsl #4
    ldr x12,[x9]
    add x9,sp,#288
    add x9,x9,x23,lsl #4
    ldr x13,[x9]
    mov w9,#1012
    mov w10,#1016
    cbz x23,.Llassie_wind_fields
    mov w9,#1116
    mov w10,#1120
.Llassie_wind_fields:
    ldrsw x9,[x27,x9]
    ldrsw x10,[x27,x10]
    sub x9,x9,#1
    sub x10,x10,#1
    madd x14,x9,x24,x25
    madd x15,x10,x24,x25
    ldr x16,[sp,#216]
    mov x9,#0
.Llassie_rotation_layer:
    mov x10,x21
    mul x11,x9,x19
.Llassie_rotation_cell:
    add x17,x11,x10
    lsl x17,x17,#3
    ldr d0,[x16,x10,lsl #3]
    ldr d1,[x15,x17]
    fmul d1,d0,d1
    ldr d2,[x12,x17]
    fsub d2,d2,d1
    str d2,[x12,x17]
    ldr d1,[x14,x17]
    fmul d1,d0,d1
    ldr d2,[x13,x17]
    fadd d2,d2,d1
    str d2,[x13,x17]
    add x10,x10,#1
    cmp x10,x22
    b.lt .Llassie_rotation_cell
    add x9,x9,#1
    cmp x9,x20
    b.lt .Llassie_rotation_layer
    ldr w9,[sp,#328]
    cbnz w9,.Llassie_return
    add x23,x23,#1
    cmp x23,#2
    b.lt .Llassie_rotation_time
.Llassie_return:
    ldp x19,x20,[sp,#64]
    ldp x21,x22,[sp,#80]
    ldp x23,x24,[sp,#96]
    ldp x25,x26,[sp,#112]
    ldp x27,x28,[sp,#128]
    ldp x29,x30,[sp,#144]
    add sp,sp,#512
    ret
.Llassie_alloc_failure:
    bl abort
    brk #0
.size LASSIE_SYMBOL,.-LASSIE_SYMBOL
.section .note.GNU-stack,"",%progbits
