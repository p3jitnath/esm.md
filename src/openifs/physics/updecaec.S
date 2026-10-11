// Monthly aerosol physics is in formulations/openifs/physics/monthly_aerosol_fields.md.
// Complete ordered contract is in skills/md2asm/references/openifs/physics/updecaec.md.
// Five Fortran address arguments use the verified geometry, radiation and physics objects.
// The 416-byte aligned frame preserves x19..x29 and d8..d15. x18 is untouched.
// Calendar, complete interpolation, pressure and all five profile children are native.
// Private allocation stores pressure scratch and supplies no numerical calculation.
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL updecaec_
#endif
.text
.p2align 4
.global md2asm_updecaec
.type md2asm_updecaec,%function
.global ORIGINAL_SYMBOL
.set ORIGINAL_SYMBOL,md2asm_updecaec
.macro LOAD_CONST reg,label
    adrp x17,\label
    ldr \reg,[x17,:lo12:\label]
.endm
.macro LONG_OFFSET reg,base,value
    movz \reg,#(\value & 65535)
    movk \reg,#((\value >> 16) & 65535),lsl #16
    add \reg,\base,\reg
.endm
md2asm_updecaec:
    sub sp,sp,#416
    stp x19,x20,[sp,#256]
    stp x21,x22,[sp,#272]
    stp x23,x24,[sp,#288]
    stp x25,x26,[sp,#304]
    stp x27,x28,[sp,#320]
    stp x29,x30,[sp,#336]
    stp d8,d9,[sp,#352]
    stp d10,d11,[sp,#368]
    stp d12,d13,[sp,#384]
    stp d14,d15,[sp,#400]
    mov x19,x0
    mov x20,x1
    mov x21,x2
    ldr w25,[x3]
    ldr w24,[x4]
    LONG_OFFSET x22,x21,35632
    LONG_OFFSET x23,x21,169240
    LONG_OFFSET x9,x19,5224
    ldr w26,[x9]
    str w26,[sp,#20]
    mov w9,#1
    str w9,[sp,#16]
    mov w9,#72
    str w9,[sp,#180]
    mov w9,#46
    str w9,[sp,#184]
    mov w9,#-1
    str w9,[sp,#176]
    // Decode the initial Gregorian date. The complete caller contract checks validity.
    mov w9,#100
    sdiv w10,w25,w9
    msub w11,w10,w9,w25
    sdiv w12,w10,w9
    msub w13,w12,w9,w10
    str w11,[sp,#40]
    str w13,[sp,#44]
    str w12,[sp,#48]
    sub w11,w11,#1
    scvtf d2,w24
    LOAD_CONST d3,.Lminutes_day
    cmp w13,#1
    b.eq .Laer_jan
    cmp w13,#2
    b.eq .Laer_feb
    sub w9,w13,#2
    adrp x10,.Laer_mdays
    add x10,x10,:lo12:.Laer_mdays
    ldr d0,[x10,x9,lsl #3]
    scvtf d1,w11
    fadd d0,d0,d1
    fmul d0,d0,d3
    fadd d0,d0,d2
    b .Laer_time_ready
.Laer_jan:
    scvtf d0,w11
    fmul d0,d0,d3
    fadd d0,d0,d2
    b .Laer_time_ready
.Laer_feb:
    cmp w11,#28
    b.ne .Laer_feb_day
    sub w11,w11,#1
.Laer_feb_day:
    scvtf d0,w11
    LOAD_CONST d1,.Lfeb_day
    fmul d0,d0,d1
    LOAD_CONST d1,.Lcyclic_width
    fadd d0,d1,d0
    fadd d0,d0,d2
.Laer_time_ready:
    // Reuse the accepted exact positive calendar remainder from the ozone solver.
    mov x8,#1672
    movk x8,#8,lsl #16
    ucvtf d1,x8
    fcmp d0,d1
    b.lt .Laer_year_reduced
    fcvtzu x9,d0
    ucvtf d2,x9
    fsub d3,d0,d2
    udiv x10,x9,x8
    msub x9,x10,x8,x9
    ucvtf d0,x9
    fadd d0,d0,d3
.Laer_year_reduced:
    adrp x10,.Laer_midpoints
    add x10,x10,:lo12:.Laer_midpoints
    ldr d1,[x10]
    fcmp d0,d1
    b.le .Laer_first_weight
    ldr d1,[x10,#88]
    fcmp d0,d1
    b.gt .Laer_last_weight
    mov x11,#0
.Laer_find_month:
    ldr d1,[x10,x11,lsl #3]
    add x12,x11,#1
    ldr d2,[x10,x12,lsl #3]
    fcmp d0,d2
    b.gt .Laer_next_month
    fsub d3,d0,d2
    fsub d4,d1,d2
    fdiv d8,d3,d4
    add w11,w11,#1
    add w12,w12,#1
    b .Laer_month_ready
.Laer_next_month:
    add x11,x11,#1
    cmp x11,#11
    b.lt .Laer_find_month
    brk #0x4a0
.Laer_first_weight:
    fsub d3,d1,d0
    b .Laer_cross_weight
.Laer_last_weight:
    LOAD_CONST d1,.Llast_midpoint
    fsub d3,d1,d0
.Laer_cross_weight:
    LOAD_CONST d4,.Lcyclic_width
    fdiv d8,d3,d4
    mov w11,#12
    mov w12,#1
.Laer_month_ready:
    str w11,[sp,#24]
    str w12,[sp,#28]
    str d8,[sp,#32]
    // Advance the date through the complete direct Gregorian calendar child.
    mov w9,#1440
    sdiv w10,w24,w9
    msub w11,w10,w9,w24
    str w10,[sp,#52]
    str w11,[sp,#140]
    add x0,sp,#40
    add x1,sp,#44
    add x2,sp,#48
    add x3,sp,#52
    add x4,sp,#56
    add x5,sp,#60
    add x6,sp,#64
    add x7,sp,#68
    add x9,sp,#176
    str x9,[sp]
    bl md2asm_updcal
    ldr w9,[sp,#56]
    ldr w10,[sp,#60]
    ldr w11,[sp,#64]
    cmp w9,#16
    b.lt .Laer_before_midmonth
    str w10,[sp,#116]
    cmp w10,#12
    add w12,w10,#1
    mov w13,#1
    csel w12,w13,w12,eq
    str w12,[sp,#120]
    str w11,[sp,#124]
    add w12,w11,#1
    csel w12,w12,w11,eq
    str w12,[sp,#128]
    mov w12,#16
    str w12,[sp,#132]
    sub w13,w10,#1
    add x14,sp,#68
    ldr w13,[x14,x13,lsl #2]
    add w12,w13,#16
    str w12,[sp,#136]
    b .Laer_volcanic_weight
.Laer_before_midmonth:
    cmp w10,#1
    sub w12,w10,#1
    mov w13,#12
    csel w12,w13,w12,eq
    str w12,[sp,#116]
    str w10,[sp,#120]
    sub w13,w11,#1
    csel w13,w13,w11,eq
    str w13,[sp,#124]
    str w11,[sp,#128]
    sub w13,w12,#1
    add x14,sp,#68
    ldr w13,[x14,x13,lsl #2]
    mov w12,#16
    sub w13,w12,w13
    str w13,[sp,#132]
    str w12,[sp,#136]
.Laer_volcanic_weight:
    LONG_OFFSET x14,x22,133592
    ldp w10,w11,[x14]
    ldr w12,[sp,#124]
    ldr w13,[sp,#128]
    cmp w12,w10
    csel w12,w10,w12,lt
    cmp w13,w10
    csel w13,w10,w13,lt
    cmp w12,w11
    csel w12,w11,w12,gt
    cmp w13,w11
    csel w13,w11,w13,gt
    str w12,[sp,#124]
    str w13,[sp,#128]
    ldr w10,[sp,#132]
    ldr w11,[sp,#136]
    ldr w12,[sp,#140]
    mov w13,#1440
    madd w12,w9,w13,w12
    mul w14,w11,w13
    sub w14,w14,w12
    sub w11,w11,w10
    mul w11,w11,w13
    scvtf d0,w14
    scvtf d1,w11
    fdiv d9,d0,d1
    fmov d10,#1.0
    fsub d10,d10,d9
    str d9,[sp,#144]
    str d10,[sp,#152]
    // Interpolate all five fixed-size tropospheric fields.
    mov x28,#0
.Laer_tegen:
    adrp x9,.Laer_tegen_pairs
    add x9,x9,:lo12:.Laer_tegen_pairs
    add x9,x9,x28
    ldp w10,w11,[x9]
    ldr x2,[x22,x10]
    add x3,x22,x11
    add x0,sp,#180
    add x1,sp,#184
    add x4,sp,#24
    add x5,sp,#28
    add x6,sp,#32
    bl md2asm_update_arr_2d
    add x28,x28,#8
    cmp x28,#40
    b.lt .Laer_tegen
    ldr w9,[x20,#180]
    cmp w9,#1
    b.ne .Laer_volcanic
    ldr w9,[x20,#516]
    cbz w9,.Laer_macc3
    // Seasonal dust height, complete half/full pressure and all five profiles.
    ldr w10,[sp,#24]
    ldr w11,[sp,#28]
    sub w10,w10,#1
    sub w11,w11,#1
    adrp x9,.Laer_dust
    add x9,x9,:lo12:.Laer_dust
    ldr d0,[x9,x11,lsl #3]
    ldr d1,[x9,x10,lsl #3]
    fsub d1,d1,d0
    fmul d1,d8,d1
    fadd d0,d0,d1
    str d0,[x20,#664]
    mov x9,#3
    madd x0,x26,x9,xzr
    add x0,x0,#2
    lsl x0,x0,#3
    bl malloc
    cbz x0,.Laer_reject
    mov x27,x0
    add x9,x26,#1
    add x10,x27,x9,lsl #3
    add x11,x10,x9,lsl #3
    str x10,[sp,#160]
    str x11,[sp,#168]
    adrp x9,:got:__yomvert_MOD_vp00
    ldr x9,[x9,:got_lo12:__yomvert_MOD_vp00]
    ldr d0,[x9]
    str d0,[x27,x26,lsl #3]
    add x0,sp,#16
    add x1,sp,#20
    mov x2,x0
    mov x3,x0
    ldr x4,[x19,#3240]
    ldr x5,[x19,#3264]
    mov x6,x27
    mov x7,#0
    str x11,[sp]
    bl md2asm_updecaec_private_gphpre
    ldr x10,[sp,#160]
    ldr d1,[x27,x26,lsl #3]
    mov x9,#0
.Laer_eta:
    ldr d0,[x27,x9,lsl #3]
    fdiv d0,d0,d1
    str d0,[x10,x9,lsl #3]
    add x9,x9,#1
    cmp x9,x26
    b.le .Laer_eta
    mov x0,x20
    add x1,sp,#20
    mov x2,x10
    bl md2asm_su_aerv
    mov x0,x27
    bl free
.Laer_macc3:
    ldr w9,[x20,#464]
    cbz w9,.Laer_macc2
    mov x28,#0
.Laer_macc3_loop:
    adrp x9,.Laer_macc3_pairs
    add x9,x9,:lo12:.Laer_macc3_pairs
    add x9,x9,x28
    ldp w10,w11,[x9]
    ldr x3,[x23,x10]
    ldr x4,[x23,x11]
    add x0,x20,#188
    add x1,x20,#184
    add x2,x20,#192
    add x5,sp,#24
    add x6,sp,#28
    add x7,sp,#32
    bl md2asm_update_arr_3d
    add x28,x28,#8
    cmp x28,#104
    b.lt .Laer_macc3_loop
.Laer_macc2:
    mov x28,#0
.Laer_macc2_loop:
    adrp x9,.Laer_macc2_pairs
    add x9,x9,:lo12:.Laer_macc2_pairs
    add x9,x9,x28
    ldp w10,w11,[x9]
    ldr x2,[x23,x10]
    ldr x3,[x23,x11]
    add x0,x20,#188
    add x1,x20,#184
    add x4,sp,#24
    add x5,sp,#28
    add x6,sp,#32
    bl md2asm_update_arr_2d
    add x28,x28,#8
    cmp x28,#88
    b.lt .Laer_macc2_loop
.Laer_volcanic:
    // Apply the declared fixed forcing year, then locate both source month planes.
    LONG_OFFSET x9,x21,33332
    ldr w10,[x9]
    cmp w10,#0
    b.le .Laer_years_ready
    str w10,[sp,#124]
    str w10,[sp,#128]
.Laer_years_ready:
    ldr x9,[x22,#568]
    ldr x10,[x22,#648]
    ldr x11,[x22,#640]
    sub x10,x10,x11
    add x10,x10,#1
    // Volcanic dimensions are 24 latitude points, source years, and twelve months.
    ldr x11,[x22,#640]
    ldrsw x12,[sp,#124]
    sub x12,x12,x11
    ldrsw x13,[sp,#128]
    sub x13,x13,x11
    ldr w14,[sp,#116]
    sub w14,w14,#1
    ldr w15,[sp,#120]
    sub w15,w15,#1
    madd x12,x14,x10,x12
    madd x13,x15,x10,x13
    mov x10,#24
    mul x12,x12,x10
    mul x13,x13,x10
    add x27,x9,x12,lsl #3
    add x28,x9,x13,lsl #3
    ldr x24,[x22,#680]
    LONG_OFFSET x26,x22,133224
    mov x25,#0
.Laer_volcanic_latitude:
    scvtf d0,x25
    fmov d1,#4.0
    fmul d0,d0,d1
    LOAD_CONST d1,.Laer_north
    fsub d11,d1,d0
    mov x9,#0
.Laer_volcanic_face:
    ldr d0,[x24,x9,lsl #3]
    fcmp d11,d0
    b.eq .Laer_exact_latitude
    b.ge .Laer_next_latitude_face
    add x10,x9,#1
    ldr d1,[x24,x10,lsl #3]
    fcmp d11,d1
    b.lt .Laer_next_latitude_face
    fsub d2,d11,d1
    fsub d3,d0,d1
    fdiv d14,d2,d3
    ldr d0,[x27,x9,lsl #3]
    ldr d1,[x28,x9,lsl #3]
    fmul d0,d9,d0
    fmul d1,d10,d1
    fadd d13,d0,d1
    ldr d0,[x27,x10,lsl #3]
    ldr d1,[x28,x10,lsl #3]
    fmul d0,d9,d0
    fmul d1,d10,d1
    fadd d0,d0,d1
    fsub d1,d0,d13
    fmul d1,d14,d1
    fsub d12,d0,d1
    b .Laer_next_latitude_face
.Laer_exact_latitude:
    ldr d0,[x27,x9,lsl #3]
    ldr d1,[x28,x9,lsl #3]
    fmul d0,d9,d0
    fmul d1,d10,d1
    fadd d12,d0,d1
.Laer_next_latitude_face:
    add x9,x9,#1
    cmp x9,#23
    b.lt .Laer_volcanic_face
    str d12,[x26,x25,lsl #3]
    add x25,x25,#1
    cmp x25,#46
    b.lt .Laer_volcanic_latitude
    LOAD_CONST d0,.Laer_minimum
    str d0,[x22]
    ldp d14,d15,[sp,#400]
    ldp d12,d13,[sp,#384]
    ldp d10,d11,[sp,#368]
    ldp d8,d9,[sp,#352]
    ldp x29,x30,[sp,#336]
    ldp x27,x28,[sp,#320]
    ldp x25,x26,[sp,#304]
    ldp x23,x24,[sp,#288]
    ldp x21,x22,[sp,#272]
    ldp x19,x20,[sp,#256]
    add sp,sp,#416
    ret
.Laer_reject:
    brk #0x4a0
.size md2asm_updecaec,.-md2asm_updecaec
.section .rodata
.p2align 3
.Lminutes_day: .double 1440.0
.Lfeb_day: .double 1452.8571
.Lcyclic_width: .double 44640.0
.Llast_midpoint: .double 548280.0
.Laer_north: .double 90.0
.Laer_minimum: .double 1.0e-12
.Laer_mdays: .double 31.0,59.25,90.25,120.25,151.25,181.25,212.25,243.25,273.25,304.25,334.25,365.25
.Laer_midpoints: .double 22320.0,64980.0,107640.0,151560.0,195480.0,239400.0,283320.0,327960.0,371880.0,415800.0,459720.0,503640.0
.Laer_dust: .double 1000.0,1000.0,2000.0,2000.0,2000.0,3000.0,3000.0,2000.0,2000.0,2000.0,1000.0,1000.0
.Laer_tegen_pairs: .word 8,744,120,27240,232,53736,344,80232,456,106728
.Laer_macc2_pairs: .word 1000,1224,1112,1312,1400,1624,1512,1712,1800,2136,1912,2224,2024,2312,2400,2736,2512,2824,2624,2912,3000,3112
.Laer_macc3_pairs: .word 3200,4968,3336,5080,3472,5192,3608,5304,3744,5416,3880,5528,4016,5640,4152,5752,4288,5864,4424,5976,4560,6088,4696,6200,4832,6312
.section .note.GNU-stack,"",%progbits
