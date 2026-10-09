/* Complete positive temperature (K/s) and log-pressure (s^-1) operators.
 * The frozen SITNU contract defines each separately rounded FP64 stage.
 * x0..x7: geometry, TDYN, KLEV*, KLON*, PD, PT, PSP, KNLON*.
 * Only selected strided PT cells and the C surface values can change.
 * The accepted native vertical body provides the complete ITOP/11 stage. */
#ifndef SITNU_ENTRY
#define SITNU_ENTRY sitnu_
#endif
#ifndef SITNU_VERTICAL_ENTRY
#define SITNU_VERTICAL_ENTRY verdisint_assembly_
#endif
.text
.p2align 4
.global SITNU_ENTRY
.type SITNU_ENTRY,%function
SITNU_ENTRY:
    sub sp,sp,#256
    stp x19,x20,[sp,#160]
    stp x21,x22,[sp,#176]
    stp x23,x24,[sp,#192]
    stp x25,x26,[sp,#208]
    stp x27,x28,[sp,#224]
    stp x29,x30,[sp,#240]
    mov x19,x0
    mov x20,x1
    mov x21,x4
    mov x22,x5
    mov x23,x6
    ldr w24,[x7]
    cbz x24,.Lsit_return
    ldrsw x25,[x19,#5224]
    ldrsw x26,[x2]
    ldrsw x27,[x3]
    lsl x26,x26,#3
    lsl x27,x27,#3
    str w24,[sp,#48]
    str w25,[sp,#52]
    mov w8,#1
    str w8,[sp,#56]
    ldr d6,[x20,#2568]
    cbz x25,.Lsit_zero_levels
    str d6,[sp,#88]
    adrp x8,:got:__yomcst_MOD_rkappa
    ldr x8,[x8,:got_lo12:__yomcst_MOD_rkappa]
    ldr d0,[x8]
    ldr d1,[x20,#2520]
    fmul d7,d0,d1
    str d7,[sp,#96]
    ldr x8,[x19,#3264]
    ldr w8,[x8,#52]
    cbnz w8,.Lsit_fe

    /* Level-one addresses respect the measured descriptor lower bounds. */
    mov x17,#1
    ldr x8,[x20,#2728]
    ldr x12,[x20,#2776]
    sub x12,x17,x12
    add x8,x8,x12,lsl #3
    ldr x9,[x20,#2792]
    ldr x12,[x20,#2840]
    sub x12,x17,x12
    add x9,x9,x12,lsl #3
    ldr x10,[x20,#2664]
    ldr x12,[x20,#2712]
    sub x12,x17,x12
    add x10,x10,x12,lsl #3
    ldr x11,[x20,#2600]
    ldr x12,[x20,#2648]
    sub x12,x17,x12
    add x11,x11,x12,lsl #3
    mov x12,#0
.Lsit_column:
    madd x13,x12,x27,x21
    madd x14,x12,x27,x22
    mov x15,#0
    fmov d5,xzr
.Lsit_level:
    fmov d4,d5
    ldr d0,[x13]
    ldr d1,[x8,x15,lsl #3]
    fmul d1,d0,d1
    fadd d5,d5,d1
    ldr d1,[x9,x15,lsl #3]
    ldr d2,[x10,x15,lsl #3]
    fmul d1,d1,d2
    fmul d1,d1,d4
    ldr d2,[x11,x15,lsl #3]
    fmul d2,d2,d0
    fadd d1,d1,d2
    fmul d1,d7,d1
    str d1,[x14]
    add x13,x13,x26
    add x14,x14,x26
    add x15,x15,#1
    cmp x15,x25
    b.lt .Lsit_level
    fmul d0,d5,d6
    str d0,[x23,x12,lsl #3]
    add x12,x12,#1
    cmp x12,x24
    b.lt .Lsit_column
    b .Lsit_return

.Lsit_zero_levels:
    /* A conventional empty vertical column still returns its mass rate. */
    fmov d0,xzr
    fmul d0,d0,d6
    mov x8,#0
.Lsit_zero_surface:
    str d0,[x23,x8,lsl #3]
    add x8,x8,#1
    cmp x8,x24
    b.lt .Lsit_zero_surface
    b .Lsit_return

.Lsit_fe:
    mov x17,#1
    ldr x8,[x20,#2728]
    ldr x9,[x20,#2776]
    sub x9,x17,x9
    add x8,x8,x9,lsl #3
    str x8,[sp,#64]
    ldr x9,[x19,#3248]
    ldr x8,[x9,#256]
    ldr x9,[x9,#304]
    sub x9,x17,x9
    add x8,x8,x9,lsl #3
    str x8,[sp,#72]
    ldr x8,[x20,#2920]
    ldr x9,[x20,#2968]
    sub x9,x17,x9
    add x8,x8,x9,lsl #3
    str x8,[sp,#80]
    add x0,x25,x25
    add x0,x0,#3
    mul x0,x0,x24
    lsl x0,x0,#3
    bl malloc
    cbz x0,.Lsit_allocation_failed
    mov x28,x0
    add x8,x25,#2
    mul x8,x8,x24
    add x8,x28,x8,lsl #3
    str x8,[sp,#104]
    ldr x8,[sp,#64]
    ldr x9,[sp,#72]
    lsl x16,x24,#3
    add x17,x25,#1
    mul x17,x17,x16
    add x17,x28,x17
    mov x13,#0
.Lsit_fe_column:
    str xzr,[x28,x13,lsl #3]
    str xzr,[x17,x13,lsl #3]
    madd x10,x13,x27,x21
    add x11,x28,x16
    add x11,x11,x13,lsl #3
    mov x12,#0
.Lsit_fe_input:
    ldr d0,[x10]
    ldr d1,[x8,x12,lsl #3]
    fmul d0,d0,d1
    ldr d1,[x9,x12,lsl #3]
    fmul d0,d0,d1
    str d0,[x11]
    add x10,x10,x26
    add x11,x11,x16
    add x12,x12,#1
    cmp x12,x25
    b.lt .Lsit_fe_input
    add x13,x13,#1
    cmp x13,x24
    b.lt .Lsit_fe_column

    /* Forty-eight outgoing bytes include both hidden character lengths. */
    ldr x0,[x19,#3256]
    ldr x1,[x19,#3264]
    adrp x2,.Lsit_operation
    add x2,x2,:lo12:.Lsit_operation
    adrp x3,.Lsit_boundary
    add x3,x3,:lo12:.Lsit_boundary
    add x4,sp,#48
    add x5,sp,#56
    mov x6,x4
    add x7,sp,#52
    str x28,[sp,#0]
    ldr x8,[sp,#104]
    str x8,[sp,#8]
    str xzr,[sp,#16]
    add x8,x19,#1,lsl #12
    add x8,x8,#1048
    str x8,[sp,#24]
    mov x8,#4
    str x8,[sp,#32]
    mov x8,#2
    str x8,[sp,#40]
    bl SITNU_VERTICAL_ENTRY

    ldr x8,[sp,#80]
    ldr x9,[sp,#104]
    ldr d6,[sp,#88]
    ldr d7,[sp,#96]
    fmov d4,#1.0
    lsl x16,x24,#3
    mov x10,#0
.Lsit_fe_output_column:
    add x12,x9,x10,lsl #3
    madd x13,x10,x27,x22
    mov x11,#0
.Lsit_fe_output_level:
    ldr d0,[x8,x11,lsl #3]
    fdiv d0,d4,d0
    ldr d1,[x12]
    fmul d1,d7,d1
    fmul d1,d1,d0
    str d1,[x13]
    add x12,x12,x16
    add x13,x13,x26
    add x11,x11,#1
    cmp x11,x25
    b.lt .Lsit_fe_output_level
    ldr d0,[x12]
    fmul d0,d0,d6
    str d0,[x23,x10,lsl #3]
    add x10,x10,#1
    cmp x10,x24
    b.lt .Lsit_fe_output_column
    mov x0,x28
    bl free
.Lsit_return:
    ldp x19,x20,[sp,#160]
    ldp x21,x22,[sp,#176]
    ldp x23,x24,[sp,#192]
    ldp x25,x26,[sp,#208]
    ldp x27,x28,[sp,#224]
    ldp x29,x30,[sp,#240]
    add sp,sp,#256
    ret
.Lsit_allocation_failed:
    bl abort
    brk #0
.size SITNU_ENTRY,.-SITNU_ENTRY
.section .rodata
.Lsit_operation:
    .ascii "ITOP"
.Lsit_boundary:
    .ascii "11"
.section .note.GNU-stack,"",%progbits
