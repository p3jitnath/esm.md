// Complete SUAERL/SUAERH/SUAERV/SU_AERV with prevalidated owned records.
// Contract: skills/md2asm/references/openifs/radiation/aerosol_distribution_setup.md.
.text
.p2align 4
.global md2asm_aerosol_longwave_absorption_fields
.type md2asm_aerosol_longwave_absorption_fields,%function
// x0 TESWRT10744; write RAER(6,6) only.
md2asm_aerosol_longwave_absorption_fields:
    mov x9,#10384
    add x0,x0,x9
    adrp x1,.Ldistribution_longwave_plan
    add x1,x1,:lo12:.Ldistribution_longwave_plan
    adrp x2,.Ldistribution_longwave_end
    add x2,x2,:lo12:.Ldistribution_longwave_end
    b .Ldistribution_literal_stores
.size md2asm_aerosol_longwave_absorption_fields,.-md2asm_aerosol_longwave_absorption_fields
.p2align 4
.global md2asm_aerosol_horizontal_distribution_fields
.type md2asm_aerosol_horizontal_distribution_fields,%function
// x0 TEAERD4232; source T10 coefficients and RCAEROS only.
md2asm_aerosol_horizontal_distribution_fields:
    adrp x1,.Ldistribution_horizontal_plan
    add x1,x1,:lo12:.Ldistribution_horizontal_plan
    adrp x2,.Ldistribution_horizontal_end
    add x2,x2,:lo12:.Ldistribution_horizontal_end
    b .Ldistribution_literal_stores
.size md2asm_aerosol_horizontal_distribution_fields,.-md2asm_aerosol_horizontal_distribution_fields
.Ldistribution_literal_stores:
    ldr w9,[x1]
    ldr x10,[x1,#8]
    str x10,[x0,x9]
    add x1,x1,#16
    cmp x1,x2
    b.lo .Ldistribution_literal_stores
    ret
.p2align 4
.global md2asm_legacy_aerosol_vertical_profiles
.type md2asm_legacy_aerosol_vertical_profiles,%function
// x0 eta160,x1 TEAERD4232,x2 TERAD2040. Four source POW calls per level.
md2asm_legacy_aerosol_vertical_profiles:
    sub sp,sp,#80
    stp x29,x30,[sp]
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    str x18,[sp,#64]
    mov x29,sp
    mov x19,x0
    mov x20,x1
    mov x21,x2
    mov x22,#0
    ldr x9,[x19]
    lsl x9,x9,#1
    cbnz x9,.Llegacy_level
    mov x23,#0
.Llegacy_top_zero:
    add x9,x20,x23,lsl #6
    ldr x9,[x9]
    str xzr,[x9]
    add x23,x23,#1
    cmp x23,#4
    b.lo .Llegacy_top_zero
    mov x22,#1
.Llegacy_level:
    mov x23,#0
.Llegacy_field:
    ldr d0,[x19,x22,lsl #3]
    adrp x9,.Llegacy_exponents
    add x9,x9,:lo12:.Llegacy_exponents
    ldr d1,[x9,x23,lsl #3]
    bl pow
    ldr x18,[sp,#64]
    add x9,x20,x23,lsl #6
    ldr x9,[x9]
    str d0,[x9,x22,lsl #3]
    add x23,x23,#1
    cmp x23,#4
    b.lo .Llegacy_field
    add x22,x22,#1
    cmp x22,#20
    b.lo .Llegacy_level
    ldr d0,[x21,#696]
    adrp x9,.Llegacy_pressure_scales
    add x9,x9,:lo12:.Llegacy_pressure_scales
    ldr d1,[x9]
    fdiv d0,d0,d1
    str d0,[x20,#4160]
    ldr d0,[x21,#704]
    ldr d1,[x9,#8]
    fdiv d0,d0,d1
    str d0,[x20,#4176]
    mov x0,x20
    adrp x1,.Llegacy_scalar_plan
    add x1,x1,:lo12:.Llegacy_scalar_plan
    adrp x2,.Llegacy_scalar_end
    add x2,x2,:lo12:.Llegacy_scalar_end
    bl .Ldistribution_literal_stores
    ldr x18,[sp,#64]
    ldp x23,x24,[sp,#48]
    ldp x21,x22,[sp,#32]
    ldp x19,x20,[sp,#16]
    ldp x29,x30,[sp]
    add sp,sp,#80
    ret
.size md2asm_legacy_aerosol_vertical_profiles,.-md2asm_legacy_aerosol_vertical_profiles
.p2align 4
.global md2asm_macc_aerosol_vertical_profiles
.type md2asm_macc_aerosol_vertical_profiles,%function
// x0 eta160,x1 TERAD2040. Five live-height exponents and source field order.
md2asm_macc_aerosol_vertical_profiles:
    sub sp,sp,#160
    stp x29,x30,[sp]
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    str x18,[sp,#64]
    mov x29,sp
    mov x19,x0
    mov x20,x1
    add x24,sp,#96
    mov x22,#0
    adrp x9,.Lmacc_atmosphere_height
    ldr d2,[x9,:lo12:.Lmacc_atmosphere_height]
    fmov d3,#1.0
    add x10,x20,#656
.Lmacc_exponent:
    ldr d1,[x10,x22,lsl #3]
    fdiv d0,d2,d1
    fmax d0,d0,d3
    str d0,[x24,x22,lsl #3]
    add x22,x22,#1
    cmp x22,#5
    b.lo .Lmacc_exponent
    mov x21,#0
    ldr x9,[x19]
    lsl x9,x9,#1
    cbnz x9,.Lmacc_level
    mov x22,#0
.Lmacc_top_zero:
    add x9,x20,x22,lsl #6
    ldr x9,[x9,#1480]
    str xzr,[x9]
    add x22,x22,#1
    cmp x22,#5
    b.lo .Lmacc_top_zero
    mov x21,#1
.Lmacc_level:
    mov x22,#0
.Lmacc_field:
    ldr d0,[x19,x21,lsl #3]
    ldr d1,[x24,x22,lsl #3]
    bl pow
    ldr x18,[sp,#64]
    add x9,x20,x22,lsl #6
    ldr x9,[x9,#1480]
    str d0,[x9,x21,lsl #3]
    add x22,x22,#1
    cmp x22,#5
    b.lo .Lmacc_field
    add x21,x21,#1
    cmp x21,#20
    b.lo .Lmacc_level
    ldr x18,[sp,#64]
    ldp x23,x24,[sp,#48]
    ldp x21,x22,[sp,#32]
    ldp x19,x20,[sp,#16]
    ldp x29,x30,[sp]
    add sp,sp,#160
    ret
.size md2asm_macc_aerosol_vertical_profiles,.-md2asm_macc_aerosol_vertical_profiles
.section .rodata
.p2align 3
.Llegacy_exponents: .double 8.434,8.434,8.434,2.8113333333333332
.Llegacy_pressure_scales: .double 81995.0,19330.0
.Lmacc_atmosphere_height: .double 8434.0
#include "aerosol_distribution_literals.inc.S"
#include "aerosol_vertical_scalar_literals.inc.S"
.section .note.GNU-stack,"",%progbits
