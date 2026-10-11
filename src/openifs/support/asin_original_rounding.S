/* Direct inverse sine from the frozen mathematical contract.
 * Contract skills/md2asm/references/openifs/support/asin_original_rounding.md
 * Algorithm derived from GNU libc 2.38 IBM Accurate Math Library.
 * Copyright (C) 2001-2023 Free Software Foundation, Inc.
 * This derived component is licensed under LGPL-2.1-or-later.
 * Handwritten AArch64. Input and result use d0, finite [-1,1], FPCR zero.
 * Include the qualified direct inverse-cosine source to share its literal tables.
 */
.include "src/openifs/support/acos_original_rounding.S"
.text
.p2align 4
.global md2asm_asin_original_rounding
.type md2asm_asin_original_rounding,%function
md2asm_asin_original_rounding:
    mrs x9,fpcr
    cbnz x9,.Lasin_bad
    fmov x9,d0
    and x10,x9,#0x7fffffffffffffff
    mov x11,#0x3ff0000000000000
    cmp x10,x11
    b.hi .Lasin_bad
    b.eq .Lasin_endpoint
    lsr x10,x10,#32
    mov w11,#0x3e500000
    cmp w10,w11
    b.lo .Lasin_tiny
    stp x19,x20,[sp,#-128]!
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x29,x30,[sp,#48]
    stp d8,d9,[sp,#64]
    stp d10,d11,[sp,#80]
    stp d12,d13,[sp,#96]
    stp d14,d15,[sp,#112]
    mov x29,sp
    mov x19,x9
    mov x20,x10
    fmov d8,d0
    mov w9,#0x3fc00000
    cmp w20,w9
    b.lo .Lasin_small
    mov w9,#0x3fe00000
    cmp w20,w9
    b.lo .Lasin_table1
    mov w9,#0x3fe80000
    cmp w20,w9
    b.lo .Lasin_table2
    movz w9,#0x8000
    movk w9,#0x3fed,lsl #16
    cmp w20,w9
    b.lo .Lasin_table3
    movz w9,#0x8000
    movk w9,#0x3fee,lsl #16
    cmp w20,w9
    b.lo .Lasin_table4
    mov w9,#0x3fef0000
    cmp w20,w9
    b.lo .Lasin_table5
    b .Lasin_root

.Lasin_small:
    fmul d9,d8,d8
    ACOS_CONST d10,5
    ACOS_CONST d2,4
    ACOS_SUM d10,d10,d9,d2
    ACOS_CONST d2,3
    ACOS_SUM d10,d10,d9,d2
    ACOS_CONST d2,2
    ACOS_SUM d10,d10,d9,d2
    ACOS_CONST d2,1
    ACOS_SUM d10,d10,d9,d2
    ACOS_CONST d2,0
    ACOS_SUM d10,d10,d9,d2
    fmul d11,d9,d8
    ACOS_SUM d0,d10,d11,d8
    b .Lasin_return
.Lasin_table1:
    mov w9,#0x3fd00000
    cmp w20,w9
    b.hs .Lasin_table1high
    ubfx x20,x20,#15,#5
    mov x9,#11
    mul x20,x20,x9
    b .Lasin_table1done
.Lasin_table1high:
    ubfx x20,x20,#14,#6
    mov x9,#11
    mul x20,x20,x9
    add x20,x20,#352
.Lasin_table1done:
    mov x24,#6
    b .Lasin_table
.Lasin_table2:
    ubfx x20,x20,#13,#7
    mov x9,#12
    mul x20,x20,x9
    add x20,x20,#1056
    mov x24,#7
    b .Lasin_table
.Lasin_table3:
    ubfx x20,x20,#13,#7
    mov x9,#13
    mul x20,x20,x9
    add x20,x20,#992
    mov x24,#8
    b .Lasin_table
.Lasin_table4:
    ubfx x20,x20,#13,#7
    mov x9,#14
    mul x20,x20,x9
    add x20,x20,#884
    mov x24,#9
    b .Lasin_table
.Lasin_table5:
    ubfx x20,x20,#13,#7
    mov x9,#15
    mul x20,x20,x9
    add x20,x20,#768
    mov x24,#10
.Lasin_table:
    adrp x21,.Lacos_table_words
    add x21,x21,:lo12:.Lacos_table_words
    add x23,x21,x20,lsl #3
    ldr d0,[x23]
    fabs d8,d8
    fsub d8,d8,d0
    fmul d11,d8,d8
    ldr d10,[x23,x24,lsl #3]
    sub x22,x24,#1
.Lasin_table_poly:
    ldr d2,[x23,x22,lsl #3]
    ACOS_SUM d10,d10,d8,d2
    sub x22,x22,#1
    cmp x22,#2
    b.ge .Lasin_table_poly
    add x9,x24,#1
    ldr d2,[x23,x9,lsl #3]
    ACOS_SUM d10,d11,d10,d2
    ldr d0,[x23,#8]
    fmov d1,d8
    fmov d2,d10
    bl md2asm_round_product_sum_candidate
    fmov d10,d0
    add x9,x24,#2
    ldr d11,[x23,x9,lsl #3]

    fadd d0,d11,d10
    tbnz x19,#63,.Lasin_negative
    b .Lasin_return
.Lasin_negative:
    fneg d0,d0
    b .Lasin_return
.Lasin_root:
    fabs d8,d8
    fmov d9,#1.0
    fsub d9,d9,d8
    fmov d2,#0.5
    fmul d9,d9,d2
    fmov x9,d9
    ubfx x10,x9,#46,#7
    lsr x11,x9,#53
    mov x12,#511
    sub x11,x12,x11
    adrp x9,.Lacos_inverse_root
    add x9,x9,:lo12:.Lacos_inverse_root
    ldr d11,[x9,x10,lsl #3]
    adrp x9,.Lacos_power_two
    add x9,x9,:lo12:.Lacos_power_two
    ldr d2,[x9,x11,lsl #3]
    fmul d11,d11,d2
    fmul d14,d11,d11
    fneg d14,d14
    fmov d2,#1.0
    ACOS_SUM d12,d14,d9,d2
    ACOS_CONST d14,9
    ACOS_CONST d2,8
    ACOS_SUM d14,d14,d12,d2
    ACOS_CONST d2,7
    ACOS_SUM d14,d14,d12,d2
    ACOS_CONST d2,6
    ACOS_SUM d14,d14,d12,d2
    fmul d11,d11,d14
    fmul d13,d11,d9
    fmov d2,#0.5
    fmul d14,d11,d2
    fneg d14,d14
    fmov d2,#1.5
    ACOS_SUM d14,d14,d13,d2

    mov x9,#0x4170000000000000
    fmov d12,x9
    fadd d15,d13,d12
    fsub d12,d15,d12
    ACOS_SUM d15,d14,d13,d12
    fneg d14,d12
    ACOS_SUM d14,d14,d12,d9
    fdiv d14,d14,d15
    ACOS_CONST d10,5
    ACOS_CONST d2,4
    ACOS_SUM d10,d10,d9,d2
    ACOS_CONST d2,3
    ACOS_SUM d10,d10,d9,d2
    ACOS_CONST d2,2
    ACOS_SUM d10,d10,d9,d2
    ACOS_CONST d2,1
    ACOS_SUM d10,d10,d9,d2
    ACOS_CONST d2,0
    ACOS_SUM d10,d10,d9,d2
    fmul d10,d10,d9
    ACOS_CONST d15,11
    fneg d13,d14
    fmov d11,#2.0
    ACOS_SUM d15,d13,d11,d15
    fadd d13,d12,d14
    fadd d13,d13,d13
    fneg d13,d13
    ACOS_SUM d15,d13,d10,d15
    ACOS_CONST d13,10
    fneg d12,d12
    ACOS_SUM d13,d12,d11,d13
    fadd d0,d13,d15
    tbnz x19,#63,.Lasin_negative
    b .Lasin_return
.Lasin_return:
    ldp d14,d15,[sp,#112]
    ldp d12,d13,[sp,#96]
    ldp d10,d11,[sp,#80]
    ldp d8,d9,[sp,#64]
    ldp x29,x30,[sp,#48]
    ldp x23,x24,[sp,#32]
    ldp x21,x22,[sp,#16]
    ldp x19,x20,[sp],#128
    ret

.Lasin_tiny:
    and x10,x9,#0x7fffffffffffffff
    mov x11,#0x0010000000000000
    cmp x10,x11
    b.hs .Lasin_leaf_return
    fmul d1,d0,d0
.Lasin_leaf_return:
    ret
.Lasin_endpoint:
    tbnz x9,#63,.Lasin_endpoint_negative
    ACOS_CONST d0,10
    ret
.Lasin_endpoint_negative:
    ACOS_CONST d0,10
    fneg d0,d0
    ret
.Lasin_bad:
    b abort
.size md2asm_asin_original_rounding,.-md2asm_asin_original_rounding
.section .note.GNU-stack,"",%progbits
