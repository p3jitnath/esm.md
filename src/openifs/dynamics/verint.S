/* Direct vertical integral from verint.md revision 1.
 * Obtain all Q by ordered matrix reduction, then optionally subtract Q_last.
 * AAPCS64 preserves x19..x29 and LR; d0/d1 are caller-saved.
 */
#ifndef VERINT_ENTRY
#define VERINT_ENTRY verint_
#endif
.text
.p2align 4
.global VERINT_ENTRY
.type VERINT_ENTRY, %function
VERINT_ENTRY:
    mov x9, sp
    sub sp, sp, #224
    stp x19, x20, [sp, #128]
    stp x21, x22, [sp, #144]
    stp x23, x24, [sp, #160]
    stp x25, x26, [sp, #176]
    stp x27, x28, [sp, #192]
    stp x29, x30, [sp, #208]
    mov x21, x5
    mov x22, x6
    mov x23, x7
    ldr w19, [x0]
    ldr w24, [x1]
    ldr w25, [x2]
    ldr w20, [x3]
    ldr w27, [x4]
    ldr x10, [x9]
    ldr w28, [x10]
    ldr x10, [x9, #8]
    ldr w26, [x10]
    str w19, [sp, #64]
    str w24, [sp, #68]
    str w25, [sp, #72]
    str w20, [sp, #76]
    str w27, [sp, #80]
    str w28, [sp, #84]
    str w26, [sp, #88]
    str w24, [sp, #92]
    cmp w19, #1
    b.lt .Lintegral_bad
    cmp w20, #1
    b.lt .Lintegral_bad
    cmp w27, #1
    b.lt .Lintegral_bad
    cmp w24, #1
    b.lt .Lintegral_bad
    cmp w24, w19
    b.gt .Lintegral_bad
    sub w10, w24, #1
    cmp w25, w10
    b.lt .Lintegral_bad
    cmp w25, w19
    b.gt .Lintegral_bad
    cmp w28, #1
    b.hi .Lintegral_bad
    cmp w26, #1
    b.lt .Lintegral_bad
    bl __oml_mod_MOD_oml_in_parallel
    mov w29, w0
    cbz w29, .Lintegral_interval
    cmp w24, #1
    b.ne .Lintegral_bad
.Lintegral_interval:
    cmp w25, w24
    b.lt .Lintegral_done
.Lintegral_chunk:
    ldr w10, [sp, #92]
    sub w11, w25, w10
    add w11, w11, #1
    cbnz w29, .Lintegral_length
    cmp w11, w26
    csel w11, w11, w26, le
.Lintegral_length:
    str w11, [sp, #96]
    sub w12, w10, #1
    lsl x12, x12, #3
    add x6, x22, x12
    add x13, x23, x12
    str x21, [sp]
    add x9, sp, #80
    str x9, [sp, #8]
    adrp x9, .Lintegral_zero
    add x9, x9, :lo12:.Lintegral_zero
    str x9, [sp, #16]
    str x13, [sp, #24]
    add x9, sp, #64
    str x9, [sp, #32]
    mov x9, #1
    str x9, [sp, #40]
    str x9, [sp, #48]
    adrp x0, .Lintegral_n
    add x0, x0, :lo12:.Lintegral_n
    adrp x1, .Lintegral_t
    add x1, x1, :lo12:.Lintegral_t
    add x2, sp, #96
    add x3, sp, #80
    add x4, sp, #76
    adrp x5, .Lintegral_one
    add x5, x5, :lo12:.Lintegral_one
    add x7, sp, #64
    bl verdisint_strict_nt_fp64_
    cbnz w29, .Lintegral_matrix_done
    ldr w10, [sp, #92]
    ldr w11, [sp, #96]
    add w10, w10, w11
    str w10, [sp, #92]
    cmp w10, w25
    b.le .Lintegral_chunk
.Lintegral_matrix_done:
    cbz w28, .Lintegral_done
    lsl x9, x19, #3
    sub w10, w27, #1
    mul x10, x10, x9
    sub w11, w24, #1
    lsl x11, x11, #3
    add x12, x23, x11
    add x13, x12, x10
    sub w14, w25, w24
    add w14, w14, #1
    mov w15, w27
.Lintegral_subtract_row:
    mov x0, x12
    mov x1, x13
    mov w2, w14
.Lintegral_subtract_point:
    ldr d0, [x0]
    ldr d1, [x1]
    fsub d0, d0, d1
    str d0, [x0], #8
    add x1, x1, #8
    subs w2, w2, #1
    b.ne .Lintegral_subtract_point
    add x12, x12, x9
    subs w15, w15, #1
    b.ne .Lintegral_subtract_row
.Lintegral_done:
    ldp x19, x20, [sp, #128]
    ldp x21, x22, [sp, #144]
    ldp x23, x24, [sp, #160]
    ldp x25, x26, [sp, #176]
    ldp x27, x28, [sp, #192]
    ldp x29, x30, [sp, #208]
    add sp, sp, #224
    ret
.Lintegral_bad:
    adrp x0, .Lintegral_message
    add x0, x0, :lo12:.Lintegral_message
    mov x1, .Lintegral_message_end-.Lintegral_message
    bl abor1_
    brk #0
.size VERINT_ENTRY, .-VERINT_ENTRY
.section .rodata
.p2align 3
.Lintegral_one: .quad 0x3ff0000000000000
.Lintegral_zero: .quad 0
.Lintegral_n: .ascii "N"
.Lintegral_t: .ascii "T"
.Lintegral_message: .ascii "VERINT: UNSUPPORTED SHAPE TYPE CHUNK OR PARALLEL START"
.Lintegral_message_end:
.section .note.GNU-stack,"",%progbits
