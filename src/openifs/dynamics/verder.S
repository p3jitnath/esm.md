/* Direct FP64 derivative from skills/md2asm/references/openifs/dynamics/verder.md revision 1.
 * x0..x7 are integer-address arguments, matrix, input and output.
 * The complete reduction is in the private direct matrix dependency.
 */
#ifndef VERDER_ENTRY
#define VERDER_ENTRY verder_
#endif
.text
.p2align 4
.global VERDER_ENTRY
.type VERDER_ENTRY, %function
VERDER_ENTRY:
    sub sp, sp, #144
    stp x19, x20, [sp, #96]
    stp x21, x22, [sp, #112]
    stp x29, x30, [sp, #128]
    mov x19, x5
    mov x20, x6
    mov x21, x7
    ldr w9, [x0]
    ldr w10, [x1]
    ldr w11, [x2]
    ldr w12, [x3]
    ldr w13, [x4]
    str w9, [sp, #64]
    str w10, [sp, #68]
    str w11, [sp, #72]
    str w12, [sp, #76]
    str w13, [sp, #80]
    cmp w9, #1
    b.lt .Lderivative_bad
    cmp w10, #1
    b.ne .Lderivative_bad
    cmp w11, #0
    b.lt .Lderivative_bad
    cmp w11, w9
    b.gt .Lderivative_bad
    cmp w12, #1
    b.lt .Lderivative_bad
    cmp w13, #1
    b.lt .Lderivative_bad
    str w11, [sp, #84]
    str x19, [sp]
    add x9, sp, #80
    str x9, [sp, #8]
    adrp x9, .Lderivative_zero
    add x9, x9, :lo12:.Lderivative_zero
    str x9, [sp, #16]
    str x21, [sp, #24]
    add x9, sp, #64
    str x9, [sp, #32]
    mov x9, #1
    str x9, [sp, #40]
    str x9, [sp, #48]
    adrp x0, .Lderivative_n
    add x0, x0, :lo12:.Lderivative_n
    adrp x1, .Lderivative_t
    add x1, x1, :lo12:.Lderivative_t
    add x2, sp, #84
    add x3, sp, #80
    add x4, sp, #76
    adrp x5, .Lderivative_one
    add x5, x5, :lo12:.Lderivative_one
    mov x6, x20
    add x7, sp, #64
    bl verdisint_strict_nt_fp64_
    ldp x19, x20, [sp, #96]
    ldp x21, x22, [sp, #112]
    ldp x29, x30, [sp, #128]
    add sp, sp, #144
    ret
.Lderivative_bad:
    adrp x0, .Lderivative_message
    add x0, x0, :lo12:.Lderivative_message
    mov x1, .Lderivative_message_end-.Lderivative_message
    bl abor1_
    brk #0
.size VERDER_ENTRY, .-VERDER_ENTRY
.section .rodata
.p2align 3
.Lderivative_one: .quad 0x3ff0000000000000
.Lderivative_zero: .quad 0
.Lderivative_n: .ascii "N"
.Lderivative_t: .ascii "T"
.Lderivative_message: .ascii "VERDER: UNSUPPORTED SHAPE OR KSTART"
.Lderivative_message_end:
.section .note.GNU-stack,"",%progbits
