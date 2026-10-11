// Physics input formulations/openifs/physics/monthly_aerosol_fields.md.
// Complete interface skills/md2asm/references/openifs/physics/updecaec.md.
// Monthly inputs are contiguous FP64 arrays with twelve complete months.
// Each point uses three separate rounded operations. The output owner is separate.
// The complete parent contract defines nonnegative fields and weights between zero and one.
// Seven or eight address arguments use x0 through x7. No callee-saved state or stack changes.
.text
.p2align 4
.global md2asm_update_arr_2d
.type md2asm_update_arr_2d,%function
md2asm_update_arr_2d:
    ldr w8, [x0]
    ldr w9, [x1]
    umull x8, w8, w9
    b .Lmonthly_flattened

.p2align 4
.global md2asm_update_arr_3d
.type md2asm_update_arr_3d,%function
md2asm_update_arr_3d:
    ldr w8, [x0]
    ldr w9, [x1]
    umull x8, w8, w9
    ldr w9, [x2]
    mul x8, x8, x9
    mov x2, x3
    mov x3, x4
    mov x4, x5
    mov x5, x6
    mov x6, x7
.Lmonthly_flattened:
    cbz x8, .Lmonthly_return
    ldr w9, [x4]
    ldr w10, [x5]
    sub w9, w9, #1
    sub w10, w10, #1
    mul x9, x9, x8
    mul x10, x10, x8
    add x9, x2, x9, lsl #3
    add x10, x2, x10, lsl #3
    ld1r {v0.2d}, [x6]
    cmp x8, #2
    b.lo .Lmonthly_tail
.Lmonthly_pair:
    ldr q1, [x9], #16
    ldr q2, [x10], #16
    fsub v3.2d, v1.2d, v2.2d
    fmul v3.2d, v3.2d, v0.2d
    fadd v3.2d, v2.2d, v3.2d
    str q3, [x3], #16
    sub x8, x8, #2
    cmp x8, #2
    b.hs .Lmonthly_pair
    cbz x8, .Lmonthly_return
.Lmonthly_tail:
    ldr d1, [x9]
    ldr d2, [x10]
    fsub d3, d1, d2
    fmul d3, d3, d0
    fadd d3, d2, d3
    str d3, [x3]
.Lmonthly_return:
    ret
.size md2asm_update_arr_3d,.-md2asm_update_arr_3d
.size md2asm_update_arr_2d,.-md2asm_update_arr_2d
.section .note.GNU-stack,"",%progbits
