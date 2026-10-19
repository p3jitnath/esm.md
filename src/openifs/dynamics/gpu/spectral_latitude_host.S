#include "../../support/gpu/preserved_weather_calls.inc.S"
/* Direct AArch64 assembly for complete spectral latitude operations.
 * Physics: formulations/openifs/dynamics/spectral_latitude_operators.md
 * Contract: skills/md2asm/references/openifs/dynamics/spectral_latitude_operators.md
 * GNU rank-two arrays have a base address and signed row/column strides.
 * The caller owns every array and keeps FPCR zero. No stage is in a driver.
 */
#ifndef SPNSDE_SYMBOL
#define SPNSDE_SYMBOL __spnsde_mod_MOD_spnsde
#endif
#ifndef UVTVD_SYMBOL
#define UVTVD_SYMBOL __uvtvd_mod_MOD_uvtvd
#endif
#ifndef VDTUV_SYMBOL
#define VDTUV_SYMBOL __vdtuv_mod_MOD_vdtuv
#endif
.text
.p2align 4

.global SPNSDE_SYMBOL
.type SPNSDE_SYMBOL,%function
SPNSDE_SYMBOL:
    ldrsw x7, [x1]
    cbz x7, .Lnsd_empty
    lsl x7, x7, #1
    stp x19, x20, [sp, #-80]!
    stp x21, x22, [sp, #16]
    stp x23, x24, [sp, #32]
    stp x25, x26, [sp, #48]
    stp x27, x28, [sp, #64]
    mov x19, x2
    ldrsw x28, [x0]
    ldr x20, [x3]
    ldr x21, [x4]
    ldr x22, [x3, #40]
    ldr x23, [x3, #64]
    ldr x24, [x4, #40]
    ldr x25, [x4, #64]
    lsl x22, x22, #3
    lsl x23, x23, #3
    lsl x24, x24, #3
    lsl x25, x25, #3
    adrp x8, :got:__tpm_dim_MOD_r
    ldr x8, [x8, :got_lo12:__tpm_dim_MOD_r]
    ldr x8, [x8]
    ldrsw x27, [x8]
    adrp x8, :got:__tpm_fields_MOD_f
    ldr x8, [x8, :got_lo12:__tpm_fields_MOD_f]
    ldr x8, [x8]
    ldr x26, [x8, #408]
    add x26, x26, #8       /* Address of RN(0), after RN(-1). */
    mov x17, #1
    cbnz x28, .Lnsd_step
    mov x17, #2
.Lnsd_step:
    add x9, x27, #1
.Lnsd_row:
    sub x8, x9, #1
    ldr d0, [x26, x8, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,15,d0,d0 // fneg d0, d0
    ldr d4, [x19, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d4 // fmul d0, d0, d4
    add x8, x9, #2
    ldr d1, [x26, x8, lsl #3]
    add x8, x9, #1
    ldr d4, [x19, x8, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d4 // fmul d1, d1, d4
    add x10, x27, #2
    sub x10, x10, x9
    madd x11, x10, x22, x20
    madd x12, x10, x24, x21
    mov x13, #0
.Lnsd_column:
    madd x14, x13, x23, x11
    madd x15, x13, x25, x12
    add x16, x14, x22
    ldr d2, [x16]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d0,d2 // fmul d2, d0, d2
    sub x16, x14, x22
    ldr d3, [x16]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d3,d1,d3 // fmul d3, d1, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
    str d2, [x15]
    add x13, x13, x17
    cmp x13, x7
    b.lt .Lnsd_column
    sub x9, x9, #1
    cmp x9, x28
    b.ge .Lnsd_row
    ldp x21, x22, [sp, #16]
    ldp x23, x24, [sp, #32]
    ldp x25, x26, [sp, #48]
    ldp x27, x28, [sp, #64]
    ldp x19, x20, [sp], #80
.Lnsd_empty:
    ret
.size SPNSDE_SYMBOL,.-SPNSDE_SYMBOL

/* Keep the four matrix descriptors' base, row bytes and column bytes.
 * These fixed addresses and strides replace temporary coefficient arrays.
 */
.macro wind_save
    stp x19, x20, [sp, #-256]!
    stp x21, x22, [sp, #16]
    stp x23, x24, [sp, #32]
    stp x25, x26, [sp, #48]
    stp x27, x28, [sp, #64]
    stp x29, x30, [sp, #80]
.endm
.macro wind_restore
    ldp x21, x22, [sp, #16]
    ldp x23, x24, [sp, #32]
    ldp x25, x26, [sp, #48]
    ldp x27, x28, [sp, #64]
    ldp x29, x30, [sp, #80]
    ldp x19, x20, [sp], #256
    ret
.endm
.macro save_matrix desc, slot
    ldr x8, [\desc]
    ldr x9, [\desc, #40]
    ldr x10, [\desc, #64]
    lsl x9, x9, #3
    lsl x10, x10, #3
    str x8, [sp, #\slot]
    str x9, [sp, #(\slot+8)]
    str x10, [sp, #(\slot+16)]
.endm
.macro matrix_row slot, ptr, pitch, column
    ldr \ptr, [sp, #\slot]
    ldr \pitch, [sp, #(\slot+8)]
    ldr \column, [sp, #(\slot+16)]
    madd \ptr, x0, \pitch, \ptr
.endm
.macro wind_setup dimoff, lap
    mov x19, x2
    ldrsw x20, [x0]
    ldrsw x21, [x1]
    lsl x21, x21, #1
    save_matrix x3, 96
    save_matrix x4, 120
    save_matrix x5, 144
    save_matrix x6, 168
    adrp x8, :got:__tpm_dim_MOD_r
    ldr x8, [x8, :got_lo12:__tpm_dim_MOD_r]
    ldr x8, [x8]
    ldrsw x22, [x8, #\dimoff]
    adrp x8, :got:__tpm_fields_MOD_f
    ldr x8, [x8, :got_lo12:__tpm_fields_MOD_f]
    ldr x8, [x8]
    ldr x23, [x8, #408]
    add x23, x23, #8
.if \lap
    ldr x24, [x8, #472]
    add x24, x24, #8
.else
    ldr x24, [x8, #536]
.endif
.endm
.macro wind_rows
    matrix_row 96, x3, x7, x11
    matrix_row 120, x4, x8, x12
    matrix_row 144, x5, x9, x13
    matrix_row 168, x6, x10, x14
.endm
.macro wind_cells
    madd x15, x26, x11, x3
    madd x16, x26, x12, x4
    madd x17, x26, x13, x5
    madd x0, x26, x14, x6
.endm

.p2align 4
.global UVTVD_SYMBOL
.type UVTVD_SYMBOL,%function
UVTVD_SYMBOL:
    ldr w8, [x1]
    cbz w8, .Luv_empty
    wind_save
    wind_setup 4, 0
    ldrsw x0, [x24, x20, lsl #2] /* NLTN(M-1), with lower bound -1. */
    sub x0, x0, #1
    wind_rows
    mov x26, #0
    fmov d16, xzr
.Luv_zero:
    madd x15, x26, x11, x3
    madd x16, x26, x12, x4
    str d16, [x15]
    str d16, [x16]
    add x26, x26, #1
    cmp x26, x21
    b.lt .Luv_zero
 md2asm_gpu_upper_operation md2asm_gpu_startup_integer_cell_host,17,d6,x20 // scvtf d6, x20
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,15,d7,d6 // fneg d7, d6
    mov x25, x20
.Luv_row:
    ldr d0, [x23, x25, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,15,d2,d0 // fneg d2, d0
    add x1, x25, #1
    ldr d4, [x19, x1, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d4 // fmul d0, d0, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d4 // fmul d2, d2, d4
    ldr d1, [x23, x1, lsl #3]
    ldr d4, [x19, x25, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d4 // fmul d1, d1, d4
    add x0, x22, #1
    sub x0, x0, x25
    wind_rows
    mov x26, #0
.Luv_column:
    wind_cells
    cbz x20, .Luv_real_only
    /* Real rotation starts with minus M times the imaginary north wind. */
    ldr d16, [x16, x12]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d16,d7,d16 // fmul d16, d7, d16
    sub x1, x15, x7
    ldr d17, [x1]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d17,d0,d17 // fmul d17, d0, d17
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d16,d16,d17 // fsub d16, d16, d17
    add x1, x15, x7
    ldr d18, [x1]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d18,d1,d18 // fmul d18, d1, d18
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d16,d16,d18 // fadd d16, d16, d18
    str d16, [x17]
    /* Imaginary rotation starts with M times the real north wind. */
    ldr d16, [x16]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d16,d6,d16 // fmul d16, d6, d16
    sub x1, x15, x7
    ldr d17, [x1, x11]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d17,d0,d17 // fmul d17, d0, d17
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d16,d16,d17 // fsub d16, d16, d17
    add x1, x15, x7
    ldr d18, [x1, x11]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d18,d1,d18 // fmul d18, d1, d18
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d16,d16,d18 // fadd d16, d16, d18
    str d16, [x17, x13]
    /* Real spreading starts with minus M times the imaginary east wind. */
    ldr d16, [x15, x11]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d16,d7,d16 // fmul d16, d7, d16
    sub x1, x16, x8
    ldr d17, [x1]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d17,d0,d17 // fmul d17, d0, d17
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d16,d16,d17 // fadd d16, d16, d17
    add x1, x16, x8
    ldr d18, [x1]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d18,d1,d18 // fmul d18, d1, d18
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d16,d16,d18 // fsub d16, d16, d18
    str d16, [x0]
    /* Imaginary spreading starts with M times the real east wind. */
    ldr d16, [x15]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d16,d6,d16 // fmul d16, d6, d16
    sub x1, x16, x8
    ldr d17, [x1, x12]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d17,d0,d17 // fmul d17, d0, d17
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d16,d16,d17 // fadd d16, d16, d17
    add x1, x16, x8
    ldr d18, [x1, x12]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d18,d1,d18 // fmul d18, d1, d18
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d16,d16,d18 // fsub d16, d16, d18
    str d16, [x0, x14]
    b .Luv_next_column
.Luv_real_only:
    sub x1, x15, x7
    ldr d16, [x1]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d16,d2,d16 // fmul d16, d2, d16
    add x1, x15, x7
    ldr d17, [x1]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d17,d1,d17 // fmul d17, d1, d17
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d16,d16,d17 // fadd d16, d16, d17
    str d16, [x17]
    sub x1, x16, x8
    ldr d16, [x1]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d16,d0,d16 // fmul d16, d0, d16
    add x1, x16, x8
    ldr d17, [x1]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d17,d1,d17 // fmul d17, d1, d17
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d16,d16,d17 // fsub d16, d16, d17
    str d16, [x0]
.Luv_next_column:
    add x26, x26, #2
    cmp x26, x21
    b.lt .Luv_column
    add x25, x25, #1
    cmp x25, x22
    b.le .Luv_row
    wind_restore
.Luv_empty:
    ret
.size UVTVD_SYMBOL,.-UVTVD_SYMBOL

.p2align 4
.global VDTUV_SYMBOL
.type VDTUV_SYMBOL,%function
VDTUV_SYMBOL:
    ldr w8, [x1]
    cbz w8, .Lvd_empty
    wind_save
    wind_setup 0, 1
    add x25, x22, #1
.Lvd_row:
    sub x1, x25, #1
    ldr d0, [x23, x1, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,15,d2,d0 // fneg d2, d0
    ldr d4, [x19, x25, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d4 // fmul d0, d0, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d4 // fmul d2, d2, d4
    ldr d4, [x24, x1, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d4 // fmul d0, d0, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d4 // fmul d2, d2, d4
    add x1, x25, #2
    ldr d1, [x23, x1, lsl #3]
    add x1, x25, #1
    ldr d4, [x19, x1, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d4 // fmul d1, d1, d4
    ldr d4, [x24, x1, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d4 // fmul d1, d1, d4
 md2asm_gpu_upper_operation md2asm_gpu_startup_integer_cell_host,17,d6,x20 // scvtf d6, x20
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,15,d7,d6 // fneg d7, d6
    ldr d4, [x24, x25, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d6,d6,d4 // fmul d6, d6, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d7,d7,d4 // fmul d7, d7, d4
    add x0, x22, #2
    sub x0, x0, x25
    wind_rows
    mov x26, #0
.Lvd_column:
    wind_cells
    cbz x20, .Lvd_real_only
    /* Real east wind uses the imaginary spreading potential first. */
    ldr d16, [x16, x12]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d16,d7,d16 // fmul d16, d7, d16
    add x1, x15, x7
    ldr d17, [x1]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d17,d0,d17 // fmul d17, d0, d17
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d16,d16,d17 // fadd d16, d16, d17
    sub x1, x15, x7
    ldr d18, [x1]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d18,d1,d18 // fmul d18, d1, d18
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d16,d16,d18 // fsub d16, d16, d18
    str d16, [x17]
    ldr d16, [x16]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d16,d6,d16 // fmul d16, d6, d16
    add x1, x15, x7
    ldr d17, [x1, x11]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d17,d0,d17 // fmul d17, d0, d17
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d16,d16,d17 // fadd d16, d16, d17
    sub x1, x15, x7
    ldr d18, [x1, x11]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d18,d1,d18 // fmul d18, d1, d18
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d16,d16,d18 // fsub d16, d16, d18
    str d16, [x17, x13]
    /* North wind subtracts the lower spreading term and adds the upper. */
    ldr d16, [x15, x11]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d16,d7,d16 // fmul d16, d7, d16
    add x1, x16, x8
    ldr d17, [x1]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d17,d0,d17 // fmul d17, d0, d17
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d16,d16,d17 // fsub d16, d16, d17
    sub x1, x16, x8
    ldr d18, [x1]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d18,d1,d18 // fmul d18, d1, d18
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d16,d16,d18 // fadd d16, d16, d18
    str d16, [x0]
    ldr d16, [x15]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d16,d6,d16 // fmul d16, d6, d16
    add x1, x16, x8
    ldr d17, [x1, x12]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d17,d0,d17 // fmul d17, d0, d17
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d16,d16,d17 // fsub d16, d16, d17
    sub x1, x16, x8
    ldr d18, [x1, x12]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d18,d1,d18 // fmul d18, d1, d18
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d16,d16,d18 // fadd d16, d16, d18
    str d16, [x0, x14]
    b .Lvd_next_column
.Lvd_real_only:
    add x1, x15, x7
    ldr d16, [x1]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d16,d0,d16 // fmul d16, d0, d16
    sub x1, x15, x7
    ldr d17, [x1]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d17,d1,d17 // fmul d17, d1, d17
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d16,d16,d17 // fsub d16, d16, d17
    str d16, [x17]
    add x1, x16, x8
    ldr d16, [x1]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d16,d2,d16 // fmul d16, d2, d16
    sub x1, x16, x8
    ldr d17, [x1]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d17,d1,d17 // fmul d17, d1, d17
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d16,d16,d17 // fadd d16, d16, d17
    str d16, [x0]
.Lvd_next_column:
    add x26, x26, #2
    cmp x26, x21
    b.lt .Lvd_column
    sub x25, x25, #1
    cmp x25, x20
    b.ge .Lvd_row
    wind_restore
.Lvd_empty:
    ret
.size VDTUV_SYMBOL,.-VDTUV_SYMBOL
.section .note.GNU-stack,"",%progbits
