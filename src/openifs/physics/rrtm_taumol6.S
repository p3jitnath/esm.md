// Complete lower and upper longwave water and trace-gas absorption.
// Physics: formulations/openifs/physics/longwave_water_trace_gas_absorption.md.
// Contract: skills/md2asm/references/openifs/physics/rrtm_taumol6.md.
// GNU Arm ABI has 27 address arguments and a fixed 512-byte frame.
// Preserve x19-x29, the link register, x18, d8-d15 and stack alignment.
.arch armv8-a
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL rrtm_taumol6_
#endif
#ifndef POWER_SYMBOL
#define POWER_SYMBOL md2asm_pow_original_rounding_candidate
#endif
.text
.p2align 4
.global md2asm_rrtm_taumol6
.type md2asm_rrtm_taumol6,%function
.global ORIGINAL_SYMBOL
.set ORIGINAL_SYMBOL,md2asm_rrtm_taumol6
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
md2asm_rrtm_taumol6:
    sub sp,sp,#512
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    stp d8,d9,[sp,#320]
    stp d10,d11,[sp,#336]
    stp d12,d13,[sp,#352]
    stp d14,d15,[sp,#368]
    stp x0,x1,[sp,#96]
    stp x2,x3,[sp,#112]
    stp x4,x5,[sp,#128]
    stp x6,x7,[sp,#144]
    add x17,sp,#512
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
    ldr x9,[x17,#144]
    str x9,[sp,#304]
    mov x29,sp
    mrs x9,fpcr
    cbnz x9,.Llw6_reject
    ldr w19,[x2]
    ldr w9,[x1]
    sub w19,w19,w9
    add w19,w19,#1
    ldr w20,[x3]
    ldr w21,[x0]
    cbz w19,.Llw6_return
    cbz w20,.Llw6_return
    lsl x22,x19,#3
    mov x23,#0
.Llw6_layer:
    mov x24,#0
.Llw6_column:
    madd x25,x23,x19,x24
    FIELD x9,20
    ldr w10,[x9,x24,lsl #2]
    cmp w23,w10
    cset w16,lt
    str w16,[x29,#384]
    cbz w16,.Llw6_common

    // Preserve the separately rounded reference-ratio adjustment.
    FIELD x9,18
    ldr d0,[x9,x25,lsl #3]
    FIELD x9,19
    ldr d2,[x9,x25,lsl #3]
    fdiv d0,d0,d2
    CONSTANT d2,.Llw6_scale
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
    b.gt .Llw6_adjust
    FIELD x9,18
    ldr d0,[x9,x25,lsl #3]
    b .Llw6_adjusted
.Llw6_adjust:
    fmov d1,#2.0
    fsub d0,d0,d1
    CONSTANT d1,.Llw6_exponent
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
    FIELD x9,19
    ldr d1,[x9,x25,lsl #3]
    fmul d0,d0,d1
    CONSTANT d1,.Llw6_inverse_scale
    fmul d0,d0,d1
.Llw6_adjusted:
    str d0,[x29,#392]

    // Select all four water corners and each adjacent continuum row.
    FIELD x9,14
    ldr w10,[x9,x25,lsl #2]
    FIELD x9,15
    ldr w11,[x9,x25,lsl #2]
    FIELD x9,16
    ldr w12,[x9,x25,lsl #2]
    sub w11,w11,#1
    sub w12,w12,#1
    mov w17,#5
    madd w12,w10,w17,w12
    sub w10,w10,#1
    madd w11,w10,w17,w11
    GOT x13,yoerrta6.eq.0_
    add x28,x13,x11,lsl #3
    add x17,x13,x12,lsl #3
    FIELD x9,23
    ldr w11,[x9,x25,lsl #2]
    sub w11,w11,#1
    GOT x13,__yoerrta6_MOD_selfref
    add x13,x13,x11,lsl #3
    FIELD x9,13
    ldr w11,[x9,x25,lsl #2]
    sub w11,w11,#1
    GOT x14,__yoerrta6_MOD_forref
    add x14,x14,x11,lsl #3
    FIELD x9,26
    ldr w11,[x9,x25,lsl #2]
    sub w11,w11,#1
    GOT x15,__yoerrta6_MOD_ka_mco2
    add x15,x15,x11,lsl #3
    FIELD x9,7
    ldr d0,[x9,x25,lsl #3]
    FIELD x9,9
    ldr d1,[x9,x25,lsl #3]
    FIELD x9,8
    ldr d2,[x9,x25,lsl #3]
    FIELD x9,10
    ldr d3,[x9,x25,lsl #3]
    FIELD x9,17
    ldr d4,[x9,x25,lsl #3]
    FIELD x9,25
    ldr d7,[x9,x25,lsl #3]
    ldr d8,[x29,#392]
    FIELD x9,11
    ldr d16,[x9,x25,lsl #3]
    FIELD x9,12
    ldr d17,[x9,x25,lsl #3]
    FIELD x9,21
    ldr d18,[x9,x25,lsl #3]
    FIELD x9,22
    ldr d19,[x9,x25,lsl #3]
.Llw6_common:
    mov x9,#4
    mul x9,x23,x9
    add x9,x9,#1
    madd x9,x9,x19,x24
    FIELD x10,5
    ldr d5,[x10,x9,lsl #3]
    add x9,x9,x19
    ldr d6,[x10,x9,lsl #3]
    mul x9,x19,x21
    mov x10,#5
    madd x9,x9,x10,x25
    FIELD x10,6
    ldr d20,[x10,x9,lsl #3]
    mov x9,#140
    mul x9,x23,x9
    add x9,x9,#68
    madd x9,x9,x19,x24
    FIELD x10,4
    add x26,x10,x9,lsl #3
    FIELD x10,24
    add x27,x10,x9,lsl #3
    GOT x10,__yoerrta6_MOD_cfc11adj
    GOT x11,__yoerrta6_MOD_cfc12
    GOT x12,__yoerrta6_MOD_fracrefa
    mov x30,#0
.Llw6_point:
    ldr w9,[x29,#384]
    cbz w9,.Llw6_upper
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
    b .Llw6_trace
.Llw6_upper:
    fmov d21,xzr
.Llw6_trace:
    ldr d25,[x10]
    fmul d25,d5,d25
    fadd d21,d21,d25
    ldr d25,[x11]
    fmul d25,d6,d25
    fadd d21,d21,d25
    ldr w9,[x29,#384]
    cbz w9,.Llw6_aerosol
    ldp d26,d27,[x15]
    fsub d27,d27,d26
    fmul d27,d7,d27
    fadd d26,d26,d27
    fmul d24,d8,d26
    fadd d21,d21,d24
.Llw6_aerosol:
    fadd d21,d21,d20
    str d21,[x26]
    ldr d25,[x12]
    str d25,[x27]
    add x30,x30,#1
    cmp x30,#8
    b.eq .Llw6_next_column
    ldr w9,[x29,#384]
    cbz w9,.Llw6_next_point
    add x28,x28,#520
    add x17,x17,#520
    add x13,x13,#80
    add x14,x14,#32
    add x15,x15,#152
.Llw6_next_point:
    add x10,x10,#8
    add x11,x11,#8
    add x12,x12,#8
    add x26,x26,x22
    add x27,x27,x22
    b .Llw6_point
.Llw6_next_column:
    add x24,x24,#1
    cmp x24,x19
    b.lt .Llw6_column
    add x23,x23,#1
    cmp x23,x20
    b.lt .Llw6_layer
.Llw6_return:
    ldp d8,d9,[sp,#320]
    ldp d10,d11,[sp,#336]
    ldp d12,d13,[sp,#352]
    ldp d14,d15,[sp,#368]
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#512
    ret
.Llw6_reject:
    brk #0x661
.size md2asm_rrtm_taumol6,.-md2asm_rrtm_taumol6
.section .rodata
.p2align 3
.Llw6_scale:
    .quad 0x4415af1d78b58c40
.Llw6_inverse_scale:
    .quad 0x3bc79ca10c924223
.Llw6_exponent:
    .quad 0x3fe8a3d70a3d70a4
.section .note.GNU-stack,"",%progbits
