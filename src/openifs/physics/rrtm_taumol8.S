// Complete lower and upper longwave water, ozone and minor-gas absorption.
// Physics: formulations/openifs/physics/longwave_water_ozone_minor_gas_absorption.md.
// Contract: skills/md2asm/references/openifs/physics/rrtm_taumol8.md.
// GNU Arm ABI has 29 address arguments and a fixed 640-byte frame.
// Preserve x19-x29, the link register, x18, d8-d15 and stack alignment.
.arch armv8-a
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL rrtm_taumol8_
#endif
#ifndef POWER_SYMBOL
#define POWER_SYMBOL md2asm_pow_original_rounding_candidate
#endif
.text
.p2align 4
.global md2asm_rrtm_taumol8
.type md2asm_rrtm_taumol8,%function
.global ORIGINAL_SYMBOL
.set ORIGINAL_SYMBOL,md2asm_rrtm_taumol8
.macro FIELD reg,idx
    ldr \reg,[x29,#(96+8*\idx)]
.endm
.macro GOT reg,sym
    adrp \reg,:got:\sym
    ldr \reg,[\reg,:got_lo12:\sym]
.endm
.macro CONSTANT reg,sym
    adrp x9,\sym
    ldr \reg,[x9,:lo12:\sym]
.endm

.macro MINOR_TERM ptr,column
    ldp d26,d27,[\ptr]
    fsub d27,d27,d26
    fmul d27,d7,d27
    fadd d26,d26,d27
    fmul d24,\column,d26
    fadd d21,d21,d24
.endm
md2asm_rrtm_taumol8:
    sub sp,sp,#640
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    stp d8,d9,[sp,#336]
    stp d10,d11,[sp,#352]
    stp d12,d13,[sp,#368]
    stp d14,d15,[sp,#384]
    stp x0,x1,[sp,#96]
    stp x2,x3,[sp,#112]
    stp x4,x5,[sp,#128]
    stp x6,x7,[sp,#144]
    add x17,sp,#640
    ldp x9,x10,[x17,#0]
    stp x9,x10,[sp,#160]
    ldp x9,x10,[x17,#16]
    stp x9,x10,[sp,#176]
    ldp x9,x10,[x17,#32]
    stp x9,x10,[sp,#192]
    ldp x9,x10,[x17,#48]
    stp x9,x10,[sp,#208]
    ldp x9,x10,[x17,#64]
    stp x9,x10,[sp,#224]
    ldp x9,x10,[x17,#80]
    stp x9,x10,[sp,#240]
    ldp x9,x10,[x17,#96]
    stp x9,x10,[sp,#256]
    ldp x9,x10,[x17,#112]
    stp x9,x10,[sp,#272]
    ldp x9,x10,[x17,#128]
    stp x9,x10,[sp,#288]
    ldp x9,x10,[x17,#144]
    stp x9,x10,[sp,#304]
    ldr x9,[x17,#160]
    str x9,[sp,#320]

    mov x29,sp
    mrs x9,fpcr
    cbnz x9,.Llw8_reject
    ldr w19,[x2]
    ldr w9,[x1]
    sub w19,w19,w9
    add w19,w19,#1
    ldr w20,[x3]
    ldr w21,[x0]
    cbz w19,.Llw8_return
    cbz w20,.Llw8_return
    lsl x22,x19,#3
    mov x23,#0
.Llw8_layer:
    mov x24,#0
.Llw8_column:
    madd x25,x23,x19,x24
    FIELD x9,22
    ldr w10,[x9,x24,lsl #2]
    cmp w23,w10
    cset w16,lt
    str w16,[x29,#400]

    // Both regions use the original rounded carbon-dioxide adjustment.
    FIELD x9,20
    ldr d0,[x9,x25,lsl #3]
    FIELD x9,21
    ldr d2,[x9,x25,lsl #3]
    fdiv d0,d0,d2
    CONSTANT d2,.Llw8_scale
    fmul d0,d2,d0
    FIELD x9,14
    ldr w10,[x9,x25,lsl #2]
    mov w11,#7
    mov w12,#1
    madd w10,w10,w11,w12
    GOT x9,__yoerrtrf_MOD_chi_mls
    ldr d2,[x9,x10,lsl #3]
    fdiv d0,d0,d2
    fmov d3,#3.0
    fcmp d0,d3
    b.gt .Llw8_adjust
    FIELD x9,20
    ldr d0,[x9,x25,lsl #3]
    b .Llw8_adjusted
.Llw8_adjust:
    fmov d1,#2.0
    fsub d0,d0,d1
    CONSTANT d1,.Llw8_exponent
    bl POWER_SYMBOL
    fmov d1,#2.0
    fadd d0,d1,d0
    FIELD x9,14
    ldr w10,[x9,x25,lsl #2]
    mov w11,#7
    mov w12,#1
    madd w10,w10,w11,w12
    GOT x9,__yoerrtrf_MOD_chi_mls
    ldr d1,[x9,x10,lsl #3]
    fmul d0,d0,d1
    FIELD x9,21
    ldr d1,[x9,x25,lsl #3]
    fmul d0,d0,d1
    CONSTANT d1,.Llw8_inverse_scale
    fmul d0,d0,d1
.Llw8_adjusted:
    str d0,[x29,#408]

    FIELD x9,14
    ldr w10,[x9,x25,lsl #2]
    FIELD x9,15
    ldr w11,[x9,x25,lsl #2]
    FIELD x9,16
    ldr w12,[x9,x25,lsl #2]
    sub w11,w11,#1
    sub w12,w12,#1
    ldr w9,[x29,#400]
    cbz w9,.Llw8_upper_rows
    mov w9,w10
    sub w10,w10,#1
    GOT x13,yoerrta8.eq.1_
    mov x14,#520
    b .Llw8_rows
.Llw8_upper_rows:
    sub w9,w10,#12
    sub w10,w10,#13
    GOT x13,yoerrta8.eq.0_
    mov x14,#1880
.Llw8_rows:
    str x14,[x29,#416]
    mov w17,#5
    madd w11,w10,w17,w11
    madd w12,w9,w17,w12
    add x28,x13,x11,lsl #3
    add x17,x13,x12,lsl #3

    FIELD x9,7
    ldr d0,[x9,x25,lsl #3]
    FIELD x9,9
    ldr d1,[x9,x25,lsl #3]
    FIELD x9,8
    ldr d2,[x9,x25,lsl #3]
    FIELD x9,10
    ldr d3,[x9,x25,lsl #3]
    FIELD x9,27
    ldr d7,[x9,x25,lsl #3]
    ldr d8,[x29,#408]
    FIELD x9,19
    ldr d9,[x9,x25,lsl #3]
    FIELD x9,28
    ldr w11,[x9,x25,lsl #2]
    sub w11,w11,#1
    ldr w9,[x29,#400]
    cbz w9,.Llw8_upper_prepare
    GOT x15,__yoerrta8_MOD_ka_mco2
    GOT x11,__yoerrta8_MOD_ka_mn2o
    // Reuse the selected minor row for all three lower gas tables.
    FIELD x9,28
    ldr w16,[x9,x25,lsl #2]
    sub w16,w16,#1
    add x15,x15,x16,lsl #3
    add x11,x11,x16,lsl #3
    GOT x10,__yoerrta8_MOD_ka_mo3
    add x10,x10,x16,lsl #3
    GOT x12,__yoerrta8_MOD_fracrefa
    FIELD x9,17
    ldr d4,[x9,x25,lsl #3]
    FIELD x9,18
    ldr d10,[x9,x25,lsl #3]
    FIELD x9,25
    ldr w16,[x9,x25,lsl #2]
    sub w16,w16,#1
    GOT x13,__yoerrta8_MOD_selfref
    add x13,x13,x16,lsl #3
    FIELD x9,13
    ldr w16,[x9,x25,lsl #2]
    sub w16,w16,#1
    GOT x14,__yoerrta8_MOD_forref
    add x14,x14,x16,lsl #3
    FIELD x9,11
    ldr d16,[x9,x25,lsl #3]
    FIELD x9,12
    ldr d17,[x9,x25,lsl #3]
    FIELD x9,23
    ldr d18,[x9,x25,lsl #3]
    FIELD x9,24
    ldr d19,[x9,x25,lsl #3]
    b .Llw8_common
.Llw8_upper_prepare:
    mov w16,w11
    GOT x15,__yoerrta8_MOD_kb_mco2
    GOT x11,__yoerrta8_MOD_kb_mn2o
    add x15,x15,x16,lsl #3
    add x11,x11,x16,lsl #3
    GOT x12,__yoerrta8_MOD_fracrefb
    FIELD x9,18
    ldr d4,[x9,x25,lsl #3]
.Llw8_common:
    mov x9,#4
    mul x9,x23,x9
    add x9,x9,#2
    madd x9,x9,x19,x24
    FIELD x16,5
    ldr d5,[x16,x9,lsl #3]
    add x9,x9,x19
    ldr d6,[x16,x9,lsl #3]
    mul x9,x19,x21
    mov x16,#7
    madd x9,x9,x16,x25
    FIELD x16,6
    ldr d20,[x16,x9,lsl #3]
    mov x9,#140
    mul x9,x23,x9
    add x9,x9,#88
    madd x9,x9,x19,x24
    FIELD x16,4
    add x26,x16,x9,lsl #3
    FIELD x16,26
    add x27,x16,x9,lsl #3
    GOT x0,__yoerrta8_MOD_cfc12
    GOT x1,__yoerrta8_MOD_cfc22adj
    mov x30,#0
.Llw8_point:
    ldr d21,[x28]
    fmul d21,d0,d21
    ldr d25,[x28,#8]
    fmul d25,d1,d25
    fadd d21,d21,d25
    ldr d25,[x17]
    fmul d25,d2,d25
    fadd d21,d21,d25
    ldr d25,[x17,#8]
    fmul d25,d3,d25
    fadd d21,d21,d25
    fmul d21,d4,d21
    ldr w9,[x29,#400]
    cbz w9,.Llw8_co2
    ldp d26,d27,[x13]
    fsub d27,d27,d26
    fmul d27,d19,d27
    fadd d26,d26,d27
    fmul d22,d18,d26
    fadd d21,d21,d22
    ldp d26,d27,[x14]
    fsub d27,d27,d26
    fmul d27,d17,d27
    fadd d26,d26,d27
    fmul d23,d16,d26
    fadd d21,d21,d23
.Llw8_co2:
    MINOR_TERM x15,d8
    ldr w9,[x29,#400]
    cbz w9,.Llw8_n2o
    MINOR_TERM x10,d10
.Llw8_n2o:
    MINOR_TERM x11,d9
    ldr d25,[x0]
    fmul d25,d5,d25
    fadd d21,d21,d25
    ldr d25,[x1]
    fmul d25,d6,d25
    fadd d21,d21,d25
    fadd d21,d21,d20
    str d21,[x26]
    ldr d25,[x12]
    str d25,[x27]
    add x30,x30,#1
    cmp x30,#8
    b.eq .Llw8_next_column
    ldr x9,[x29,#416]
    add x28,x28,x9
    add x17,x17,x9
    add x15,x15,#152
    add x11,x11,#152
    ldr w9,[x29,#400]
    cbz w9,.Llw8_next_point
    add x13,x13,#80
    add x14,x14,#32
    add x10,x10,#152
.Llw8_next_point:
    add x0,x0,#8
    add x1,x1,#8
    add x12,x12,#8
    add x26,x26,x22
    add x27,x27,x22
    b .Llw8_point
.Llw8_next_column:
    add x24,x24,#1
    cmp x24,x19
    b.lt .Llw8_column
    add x23,x23,#1
    cmp x23,x20
    b.lt .Llw8_layer
.Llw8_return:
    ldp d8,d9,[sp,#336]
    ldp d10,d11,[sp,#352]
    ldp d12,d13,[sp,#368]
    ldp d14,d15,[sp,#384]
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#640
    ret
.Llw8_reject:
    brk #0x681
.size md2asm_rrtm_taumol8,.-md2asm_rrtm_taumol8
.section .rodata
.p2align 3
.Llw8_scale:
    .quad 0x4415af1d78b58c40
.Llw8_inverse_scale:
    .quad 0x3bc79ca10c924223
.Llw8_exponent:
    .quad 0x3fe4cccccccccccd
.section .note.GNU-stack,"",%progbits
