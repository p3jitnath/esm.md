/* Complete twelve-neighbour interpolation and all three optional clips.
 * The frozen contract defines all fourteen ordinary pointer arguments.
 * Each operation uses binary64 and each inactive output bit remains.
 */
#ifndef LAIDDI_ENTRY
#define LAIDDI_ENTRY laiddi_assembly_
#endif
.text
.p2align 4
.global LAIDDI_ENTRY
.type LAIDDI_ENTRY,%function
LAIDDI_ENTRY:
    ldrsw x1,[x1]
    ldrsw x2,[x2]
    ldrsw x3,[x3]
    ldrsw x4,[x4]
    cbz x4,.Lreturn
    sub x2,x2,#1
    subs x3,x3,x2
    b.le .Lreturn
    ldr w7,[x7]
    ldp x8,x9,[sp]
    ldp x10,x11,[sp,#16]
    ldp x12,x13,[sp,#32]
    mul x5,x1,x4
    lsl x16,x5,#3
    add x6,x16,x16,lsl #1
    mov x14,x2
    add x15,x14,x3
    sub x1,x1,x3
.Lpoint:
    /* The same clipping flag controls all three finite-value clips. */
    cmp w7,#1
    /* First outer latitude row, with two adjacent source values. */
    ldrsw x0,[x11,x14,lsl #2]
    add x0,x12,x0,lsl #3
    ldp d0,d1,[x0]
    fsub d1,d1,d0
    ldr d2,[x9,x14,lsl #3]
    fmul d1,d2,d1
    fadd d3,d0,d1
    /* First middle row has four neighbours and three coefficients. */
    add x17,x11,x16,lsr #1
    ldrsw x0,[x17,x14,lsl #2]
    sub x0,x0,#1
    add x0,x12,x0,lsl #3
    add x17,x10,x14,lsl #3
    ldr d0,[x0]
    ldr d1,[x0,#8]
    fsub d1,d1,d0
    ldr d2,[x17]
    fmul d1,d2,d1
    fadd d4,d0,d1
    ldr d1,[x0,#16]
    fsub d1,d1,d0
    ldr d2,[x17,x16]
    fmul d1,d2,d1
    fadd d4,d4,d1
    ldr d1,[x0,#24]
    fsub d1,d1,d0
    add x17,x17,x16,lsl #1
    ldr d2,[x17]
    fmul d1,d2,d1
    fadd d4,d4,d1
    b.ne .Lmiddle1_done
    ldp d0,d1,[x0,#8]
    fmin d2,d0,d1
    fmax d0,d0,d1
    fmin d4,d0,d4
    fmax d4,d2,d4
.Lmiddle1_done:
    /* Second middle row follows the same ordered update. */
    add x17,x11,x16
    ldrsw x0,[x17,x14,lsl #2]
    sub x0,x0,#1
    add x0,x12,x0,lsl #3
    add x17,x10,x6
    add x17,x17,x14,lsl #3
    ldr d0,[x0]
    ldr d1,[x0,#8]
    fsub d1,d1,d0
    ldr d2,[x17]
    fmul d1,d2,d1
    fadd d5,d0,d1
    ldr d1,[x0,#16]
    fsub d1,d1,d0
    ldr d2,[x17,x16]
    fmul d1,d2,d1
    fadd d5,d5,d1
    ldr d1,[x0,#24]
    fsub d1,d1,d0
    add x17,x17,x16,lsl #1
    ldr d2,[x17]
    fmul d1,d2,d1
    fadd d5,d5,d1
    b.ne .Lmiddle2_done
    ldp d0,d1,[x0,#8]
    fmin d2,d0,d1
    fmax d0,d0,d1
    fmin d5,d0,d5
    fmax d5,d2,d5
.Lmiddle2_done:
    /* Last outer latitude row uses longitude fraction plane three. */
    add x17,x11,x6,lsr #1
    ldrsw x0,[x17,x14,lsl #2]
    add x0,x12,x0,lsl #3
    ldp d0,d1,[x0]
    fsub d1,d1,d0
    add x17,x9,x6
    ldr d2,[x17,x14,lsl #3]
    fmul d1,d2,d1
    fadd d6,d0,d1
    /* Latitude uses the complete, already clipped middle-row values. */
    add x17,x8,x14,lsl #3
    fsub d0,d4,d3
    ldr d2,[x17]
    fmul d0,d2,d0
    fadd d7,d3,d0
    fsub d0,d5,d3
    ldr d2,[x17,x16]
    fmul d0,d2,d0
    fadd d7,d7,d0
    fsub d0,d6,d3
    add x17,x17,x16,lsl #1
    ldr d2,[x17]
    fmul d0,d2,d0
    fadd d7,d7,d0
    b.ne .Llatitude_done
    fmin d0,d4,d5
    fmax d1,d4,d5
    fmin d7,d1,d7
    fmax d7,d0,d7
.Llatitude_done:
    str d7,[x13,x14,lsl #3]
    add x14,x14,#1
    cmp x14,x15
    b.lt .Lpoint
    subs x4,x4,#1
    b.eq .Lreturn
    add x14,x14,x1
    add x15,x14,x3
    b .Lpoint
.Lreturn:
    ret
.size LAIDDI_ENTRY,.-LAIDDI_ENTRY

#ifdef LAIDDI_ABI_PROBE
/* Forward all fourteen pointers without hiding callee-saved-register changes. */
.p2align 4
.global laiddi_abi_invoke
.type laiddi_abi_invoke,%function
laiddi_abi_invoke:
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
    ldp x10,x11,[x9,#96]
    stp x10,x11,[sp,#32]
    bl LAIDDI_ENTRY
    ldr x30,[sp,#48]
    add sp,sp,#64
    ret
.size laiddi_abi_invoke,.-laiddi_abi_invoke
#endif
.section .note.GNU-stack,"",%progbits
