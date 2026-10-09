/* Complete eight-sample interpolation under its frozen Markdown contract.
 * Thirteen ordinary pointers describe complete input/output arrays.
 * All seven blends and every gather are performed in this body.
 */
#ifndef LAITLI_ENTRY
#define LAITLI_ENTRY laitli_assembly_
#endif
.text
.p2align 4
.global LAITLI_ENTRY
.type LAITLI_ENTRY,%function
LAITLI_ENTRY:
    ldrsw x0,[x0]
    ldrsw x1,[x1]
    ldrsw x2,[x2]
    ldrsw x3,[x3]
    ldrsw x4,[x4]
    cbz x4,.Lreturn
    sub x2,x2,#1
    subs x3,x3,x2
    b.le .Lreturn
    ldr x8,[sp]
    ldr x9,[sp,#8]
    ldr x10,[sp,#16]
    ldr x11,[sp,#24]
    ldr x6,[sp,#32]
    mul x15,x1,x4
    add x14,x8,x15,lsl #3
    add x5,x9,x15,lsl #2
    lsl x16,x0,#3
    mov x12,x2
    add x13,x12,x3
    sub x1,x1,x3
.Lpoint:
    /* Latitude, two longitude fractions and height fraction have no unit. */
    ldr d0,[x7,x12,lsl #3]
    ldr d1,[x8,x12,lsl #3]
    ldr d2,[x14,x12,lsl #3]
    ldr d3,[x10,x12,lsl #3]
    /* Zero-based first corner is KL0+A, with adjacent east sample at +8. */
    ldrsw x0,[x9,x12,lsl #2]
    add x0,x16,x0,lsl #3
    add x0,x11,x0
    ldrsw x17,[x5,x12,lsl #2]
    add x17,x16,x17,lsl #3
    add x17,x11,x17
    /* Upper height, first latitude row. */
    ldp d4,d5,[x0]
    fsub d5,d5,d4
    fmul d5,d1,d5
    fadd d4,d4,d5
    /* Upper height, second latitude row and complete latitude blend. */
    ldp d6,d7,[x17]
    fsub d7,d7,d6
    fmul d7,d2,d7
    fadd d6,d6,d7
    fsub d6,d6,d4
    fmul d6,d0,d6
    fadd d4,d4,d6
    /* Lower height starts one complete source plane later. */
    add x0,x0,x16
    add x17,x17,x16
    ldp d5,d6,[x0]
    fsub d6,d6,d5
    fmul d6,d1,d6
    fadd d5,d5,d6
    ldp d6,d7,[x17]
    fsub d7,d7,d6
    fmul d7,d2,d7
    fadd d6,d6,d7
    fsub d6,d6,d5
    fmul d6,d0,d6
    fadd d5,d5,d6
    /* Complete final height blend preserves the field's unit. */
    fsub d5,d5,d4
    fmul d5,d3,d5
    fadd d4,d4,d5
    str d4,[x6,x12,lsl #3]
    add x12,x12,#1
    cmp x12,x13
    b.lt .Lpoint
    subs x4,x4,#1
    b.eq .Lreturn
    add x12,x12,x1
    add x13,x12,x3
    b .Lpoint
.Lreturn:
    ret
.size LAITLI_ENTRY,.-LAITLI_ENTRY

#ifdef LAITLI_ABI_PROBE
/* Load ordinary arguments without hiding any callee-saved-register change.
 * The wrapper supplies only the ABI's five stack arguments.
 */
.p2align 4
.global laitli_abi_invoke
.type laitli_abi_invoke,%function
laitli_abi_invoke:
    sub sp,sp,#64
    str x30,[sp,#48]
    mov x9,x0
    ldp x0,x1,[x9]
    ldp x2,x3,[x9,#16]
    ldp x4,x5,[x9,#32]
    ldp x6,x7,[x9,#48]
    ldp x10,x11,[x9,#64]
    stp x10,x11,[sp]
    ldp x10,x11,[x9,#80]
    stp x10,x11,[sp,#16]
    ldr x10,[x9,#96]
    str x10,[sp,#32]
    bl LAITLI_ENTRY
    ldr x30,[sp,#48]
    add sp,sp,#64
    ret
.size laitli_abi_invoke,.-laitli_abi_invoke
#endif
.section .note.GNU-stack,"",%progbits
