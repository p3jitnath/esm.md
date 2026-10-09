/* Complete SIGAM from the frozen Markdown contract, revision 1.0.
 * Inputs use the measured GNU 12.3 ABI; all operations are scalar binary64.
 * Each multiplication and addition is separate. The descending sum keeps
 * the old accumulator for the current output before advancing the sum.
 */
#ifndef SIGAM_ENTRY
#define SIGAM_ENTRY sigam_assembly_
#endif
#ifndef VERDISINT_ENTRY
#define VERDISINT_ENTRY verdisint_assembly_
#endif
.text
.p2align 4
.global SIGAM_ENTRY
.type SIGAM_ENTRY,%function
SIGAM_ENTRY:
    sub sp,sp,#320
    stp x19,x20,[sp,#48]
    stp x21,x22,[sp,#64]
    stp x23,x24,[sp,#80]
    stp x25,x26,[sp,#96]
    stp x27,x28,[sp,#112]
    stp x29,x30,[sp,#128]
    stp d8,d9,[sp,#144]
    stp d10,d11,[sp,#160]
    stp d12,d13,[sp,#176]
    stp d14,d15,[sp,#192]
    mov x29,sp
    mov x19,x0
    mov x20,x1
    mov x21,x4
    mov x22,x5
    mov x23,x6
    ldrsw x24,[x2]
    ldrsw x25,[x3]
    lsl x24,x24,#3
    lsl x25,x25,#3
    ldrsw x26,[x7]
    ldr x9,[sp,#320]
    ldrsw x27,[x9]
    str w26,[sp,#208]
    str w27,[sp,#212]
    mov w9,#1
    str w9,[sp,#216]
    cbz x26,.Lsigam_return
    cbz x27,.Lsigam_return

    adrp x9,:got:__yomcst_MOD_rd
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rd]
    ldr d8,[x9]
    ldr d9,[x20,#2560]
    add x9,x20,#2600
    ldp x10,x11,[x9]
    add x11,x11,#1
    add x10,x10,x11,lsl #3
    str x10,[sp,#256]
    add x9,x20,#2664
    ldp x10,x11,[x9]
    add x11,x11,#1
    add x10,x10,x11,lsl #3
    str x10,[sp,#264]
    ldr x9,[x19,#3264]
    ldr w9,[x9,#52]
    cbnz w9,.Lsigam_fe

/* Conventional path: A starts at +0 below the last layer. */
    mov x10,x22
    mov x11,x21
    mov x12,x23
    mov x13,x26
.Lsigam_cv_column:
    fmov d10,xzr
    ldr d11,[x12]
    fmul d11,d11,d9
    ldr x14,[sp,#256]
    add x14,x14,x27,lsl #3
    sub x14,x14,#8
    ldr x15,[sp,#264]
    add x15,x15,x27,lsl #3
    sub x15,x15,#8
    sub x17,x27,#1
    madd x16,x17,x24,x10
    madd x6,x17,x24,x11
    mov x7,x27
.Lsigam_cv_level:
    ldr d0,[x16]
    ldr d1,[x15]
    fmul d2,d8,d0
    fmul d2,d2,d1
    fadd d3,d10,d2
    ldr d1,[x14]
    fmul d1,d1,d8
    fmul d1,d1,d0
    fadd d1,d10,d1
    fadd d1,d1,d11
    str d1,[x6]
    fmov d10,d3
    sub x16,x16,x24
    sub x6,x6,x24
    sub x14,x14,#8
    sub x15,x15,#8
    subs x7,x7,#1
    b.ne .Lsigam_cv_level
    add x10,x10,x25
    add x11,x11,x25
    add x12,x12,#8
    subs x13,x13,#1
    b.ne .Lsigam_cv_column
    b .Lsigam_return

/* Finite-element path: allocate both complete live scratch fields. */
.Lsigam_fe:
    lsl x0,x27,#1
    add x0,x0,#3
    mul x0,x0,x26
    lsl x0,x0,#3
    bl malloc
    cbz x0,.Lsigam_alloc_failure
    mov x28,x0
    add x9,x27,#2
    mul x9,x9,x26
    add x9,x28,x9,lsl #3
    str x9,[sp,#280]
    ldr x9,[x19,#3248]
    add x9,x9,#256
    ldp x10,x11,[x9]
    add x11,x11,#1
    add x10,x10,x11,lsl #3
    str x10,[sp,#272]
    fneg d12,d8
    mov x9,x28
    mov x10,x26
.Lsigam_fe_top:
    str xzr,[x9],#8
    subs x10,x10,#1
    b.ne .Lsigam_fe_top
    mov x10,x22
    mov x11,x9
    ldr x12,[sp,#264]
    ldr x13,[sp,#272]
    mov x14,x27
.Lsigam_fe_level:
    ldr d1,[x12],#8
    ldr d2,[x13],#8
    mov x15,x10
    mov x16,x11
    mov x17,x26
.Lsigam_fe_column:
    ldr d0,[x15]
    fmul d0,d12,d0
    fmul d0,d0,d1
    fmul d0,d0,d2
    str d0,[x16],#8
    add x15,x15,x25
    subs x17,x17,#1
    b.ne .Lsigam_fe_column
    mov x11,x16
    add x10,x10,x24
    subs x14,x14,#1
    b.ne .Lsigam_fe_level
    mov x10,x26
.Lsigam_fe_bottom:
    str xzr,[x11],#8
    subs x10,x10,#1
    b.ne .Lsigam_fe_bottom

/* Full accepted VERDISINT IBOT/11 call; absent KBC uses configuration. */
    ldr x0,[x19,#3256]
    ldr x1,[x19,#3264]
    adrp x2,.Lsigam_ibot
    add x2,x2,:lo12:.Lsigam_ibot
    adrp x3,.Lsigam_11
    add x3,x3,:lo12:.Lsigam_11
    add x4,sp,#208
    add x5,sp,#216
    mov x6,x4
    add x7,sp,#212
    str x28,[sp]
    ldr x9,[sp,#280]
    str x9,[sp,#8]
    str xzr,[sp,#16]
    add x9,x19,#1,lsl #12
    add x9,x9,#1048
    str x9,[sp,#24]
    mov x9,#4
    str x9,[sp,#32]
    mov x9,#2
    str x9,[sp,#40]
    bl VERDISINT_ENTRY

/* Add the independent rounded surface contribution at every full level. */
    mov x9,x23
    mov x10,x21
    ldr x11,[sp,#280]
    mov x12,x26
    lsl x17,x26,#3
.Lsigam_fe_output_column:
    ldr d11,[x9],#8
    fmul d11,d11,d9
    mov x13,x10
    mov x14,x11
    mov x15,x27
.Lsigam_fe_output_level:
    ldr d0,[x14]
    fadd d0,d0,d11
    str d0,[x13]
    add x13,x13,x24
    add x14,x14,x17
    subs x15,x15,#1
    b.ne .Lsigam_fe_output_level
    add x10,x10,x25
    add x11,x11,#8
    subs x12,x12,#1
    b.ne .Lsigam_fe_output_column
    mov x0,x28
    bl free
.Lsigam_return:
    ldp x19,x20,[sp,#48]
    ldp x21,x22,[sp,#64]
    ldp x23,x24,[sp,#80]
    ldp x25,x26,[sp,#96]
    ldp x27,x28,[sp,#112]
    ldp x29,x30,[sp,#128]
    ldp d8,d9,[sp,#144]
    ldp d10,d11,[sp,#160]
    ldp d12,d13,[sp,#176]
    ldp d14,d15,[sp,#192]
    add sp,sp,#320
    ret
.Lsigam_alloc_failure:
    bl abort
    brk #0
.size SIGAM_ENTRY,.-SIGAM_ENTRY
.section .rodata
.Lsigam_ibot: .ascii "IBOT"
.Lsigam_11: .ascii "11"
.section .note.GNU-stack,"",%progbits
