// Complete lower water/nitrous-oxide mixture and upper ozone absorption.
// Physics: formulations/openifs/physics/longwave_water_nitrous_oxide_minor_gas_absorption.md.
// Contract: skills/md2asm/references/openifs/physics/rrtm_taumol13.md.
// GNU Arm ABI has 31 address arguments and a fixed 768-byte aligned frame.
// Preserve x19-x29, link, x18, d8-d15 and all inactive output cells.
.arch armv8-a
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL rrtm_taumol13_
#endif
#ifndef POWER_SYMBOL
#define POWER_SYMBOL md2asm_pow_original_rounding_candidate
#endif
.text
.p2align 4
.global md2asm_rrtm_taumol13
.type md2asm_rrtm_taumol13,%function
.global ORIGINAL_SYMBOL
.set ORIGINAL_SYMBOL,md2asm_rrtm_taumol13
.macro FIELD reg,idx
    ldr \reg,[x29,#(96+8*\idx)]
.endm
.macro GOT reg,sym
    adrp \reg,:got:\sym
    ldr \reg,[\reg,:got_lo12:\sym]
.endm
// Prepare one pressure corner from the selected species and nitrous oxide.
// d0, d1 and d2 hold species column, nitrous-oxide column and scalar cap.
.macro CORNER ptr,ratio,fac0,fac1,qslot,wslot,mode
    FIELD x9,\ratio
    ldr d3,[x9,x25,lsl #3]
    fmul d3,d3,d1
    fadd d3,d0,d3
    str d3,[x29,#\qslot]
    fdiv d4,d0,d3
    fminnm d4,d4,d2
    fmov d5,#8.0
    fmul d5,d5,d4
    fcvtzs w10,d5
    scvtf d7,w10
    fsub d6,d5,d7
    add \ptr,\ptr,x10,lsl #3
    FIELD x9,\fac0
    ldr d19,[x9,x25,lsl #3]
    FIELD x9,\fac1
    ldr d20,[x9,x25,lsl #3]
    fmov d5,#0.125
    fcmp d4,d5
    b.lt .Lcorner_low\@
    fmov d5,#0.875
    fcmp d4,d5
    b.gt .Lcorner_high\@
.Lcorner_linear\@:
    fsub d16,d31,d6
    fmul d17,d16,d19
    fmul d18,d6,d19
    str d17,[x29,#\wslot]
    str d18,[x29,#(\wslot+8)]
    fmul d17,d16,d20
    fmul d18,d6,d20
    str d17,[x29,#(\wslot+16)]
    str d18,[x29,#((\wslot+16)+8)]
    mov w9,#4
    str w9,[x29,#\mode]
    b .Lcorner_done\@
.Lcorner_low\@:
    fsub d7,d6,d31
    mov w11,#0
    b .Lcorner_quartic\@
.Lcorner_high\@:
    fneg d7,d6
    sub \ptr,\ptr,#8
    mov w11,#1
.Lcorner_quartic\@:
    fmul d16,d7,d7
    fmul d16,d16,d16
    fsub d17,d31,d7
    fadd d5,d16,d16
    fsub d17,d17,d5
    fadd d18,d7,d16
    cbz w11,.Lcorner_weights\@
    fmov d5,d16
    fmov d16,d18
    fmov d18,d5
.Lcorner_weights\@:
    fmul d3,d16,d19
    fmul d4,d17,d19
    fmul d5,d18,d19
    str d3,[x29,#\wslot]
    str d4,[x29,#(\wslot+8)]
    str d5,[x29,#(\wslot+16)]
    fmul d3,d16,d20
    fmul d4,d17,d20
    fmul d5,d18,d20
    str d3,[x29,#(\wslot+24)]
    str d4,[x29,#((\wslot+24)+8)]
    str d5,[x29,#(\wslot+40)]
    mov w9,#6
    str w9,[x29,#\mode]
.Lcorner_done\@:
.endm
// Add four or six table terms in the original left-to-right order.
.macro MAJOR out,ptr,qslot,wslot,mode
    ldr d25,[\ptr]
    ldr d26,[x29,#\wslot]
    fmul \out,d26,d25
    ldr d25,[\ptr,#8]
    ldr d26,[x29,#(\wslot+8)]
    fmul d25,d26,d25
    fadd \out,\out,d25
    ldr w9,[x29,#\mode]
    cmp w9,#6
    b.eq .Lmajor_six\@
    ldr d25,[\ptr,#72]
    ldr d26,[x29,#(\wslot+16)]
    fmul d25,d26,d25
    fadd \out,\out,d25
    ldr d25,[\ptr,#80]
.Lmajor_linear_last\@:
    ldr d26,[x29,#(\wslot+24)]
    fmul d25,d26,d25
    fadd \out,\out,d25
    b .Lmajor_scale\@
.Lmajor_six\@:
    ldr d25,[\ptr,#16]
    ldr d26,[x29,#(\wslot+16)]
    fmul d25,d26,d25
    fadd \out,\out,d25
    ldr d25,[\ptr,#72]
    ldr d26,[x29,#(\wslot+24)]
    fmul d25,d26,d25
    fadd \out,\out,d25
    ldr d25,[\ptr,#80]
    ldr d26,[x29,#(\wslot+32)]
    fmul d25,d26,d25
    fadd \out,\out,d25
    ldr d25,[\ptr,#88]
    ldr d26,[x29,#(\wslot+40)]
    fmul d25,d26,d25
    fadd \out,\out,d25
.Lmajor_scale\@:
    ldr d26,[x29,#\qslot]
    fmul \out,d26,\out
.endm
.macro CONSTANT reg,sym
    adrp x9,\sym
    ldr \reg,[x9,:lo12:\sym]
.endm
md2asm_rrtm_taumol13:
    sub sp,sp,#768
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    stp d8,d9,[sp,#352]
    stp d10,d11,[sp,#368]
    stp d12,d13,[sp,#384]
    stp d14,d15,[sp,#400]
    stp x0,x1,[sp,#96]
    stp x2,x3,[sp,#112]
    stp x4,x5,[sp,#128]
    stp x6,x7,[sp,#144]
    add x17,sp,#768
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
    ldp x9,x10,[x17,#160]
    stp x9,x10,[sp,#320]

    ldr x9,[x17,#176]
    str x9,[sp,#336]

    mov x29,sp
    mrs x9,fpcr
    cbnz x9,.Llw13_reject
    GOT x9,__yoerrtrf_MOD_chi_mls
    ldr d0,[x9,#224]
    ldr d1,[x9,#248]
    fdiv d0,d0,d1
    str d0,[x29,#432]
    ldr d0,[x9]
    ldr d1,[x9,#24]
    fdiv d0,d0,d1
    str d0,[x29,#440]
    ldr d0,[x9,#112]
    ldr d1,[x9,#136]
    fdiv d0,d0,d1
    str d0,[x29,#600]
    ldr w19,[x2]
    ldr w9,[x1]
    sub w19,w19,w9
    add w19,w19,#1
    ldr w20,[x3]
    ldr w21,[x0]
    cbz w19,.Llw13_return
    cbz w20,.Llw13_return
    lsl x22,x19,#3
    mov x23,#0
.Llw13_layer:
    mov x24,#0
.Llw13_column:
    madd x25,x23,x19,x24
    FIELD x9,22
    ldr w10,[x9,x24,lsl #2]
    cmp w23,w10
    cset w16,lt
    str w16,[x29,#416]
    cbz w16,.Llw13_upper_setup

    // Preserve both literal precisions in the ordered carbon dioxide law.
    FIELD x9,19
    ldr d0,[x9,x25,lsl #3]
    FIELD x9,21
    ldr d2,[x9,x25,lsl #3]
    fdiv d0,d0,d2
    CONSTANT d2,.Llw13_scale
    fmul d0,d2,d0
    CONSTANT d2,.Llw13_chi64
    fdiv d0,d0,d2
    fmov d3,#3.0
    fcmp d0,d3
    b.gt .Llw13_adjust
    FIELD x9,19
    ldr d0,[x9,x25,lsl #3]
    b .Llw13_adjusted
.Llw13_adjust:
    fmov d1,#2.0
    fsub d0,d0,d1
    CONSTANT d1,.Llw13_exponent
    bl POWER_SYMBOL
    fmov d1,#2.0
    fadd d0,d1,d0
    CONSTANT d1,.Llw13_chi32_promoted
    fmul d0,d0,d1
    FIELD x9,21
    ldr d1,[x9,x25,lsl #3]
    fmul d0,d0,d1
    CONSTANT d1,.Llw13_inverse_scale
    fmul d0,d0,d1
.Llw13_adjusted:
    str d0,[x29,#584]
    fmov d31,#1.0
    FIELD x9,13
    ldr w10,[x9,x25,lsl #2]
    FIELD x9,14
    ldr w11,[x9,x25,lsl #2]
    FIELD x9,15
    ldr w12,[x9,x25,lsl #2]
    sub w11,w11,#1
    sub w12,w12,#1
    mov w9,w10
    sub w10,w10,#1
    mov w16,#9
    GOT x13,yoerrta13.eq.0_
    mov w7,#5
    madd w11,w10,w7,w11
    madd w12,w9,w7,w12
    mul w11,w11,w16
    mul w12,w12,w16
    add x28,x13,x11,lsl #3
    add x17,x13,x12,lsl #3

    FIELD x9,17
    ldr d0,[x9,x25,lsl #3]
    FIELD x9,18
    ldr d1,[x9,x25,lsl #3]
    FIELD x9,16
    ldr d2,[x9]
    CORNER x28,27,6,8,448,480,576
    CORNER x17,28,7,9,456,528,580

    // Lower Planck mixture has four spectral entries at each node.
    ldr d3,[x29,#432]
    fmul d3,d3,d1
    fadd d3,d0,d3
    fdiv d4,d0,d3
    fminnm d4,d4,d2
    fmov d5,#8.0
    fmul d5,d5,d4
    fcvtzs w10,d5
    scvtf d7,w10
    fsub d6,d5,d7
    str d6,[x29,#464]
    GOT x12,__yoerrta13_MOD_fracrefa
    add x12,x12,x10,lsl #5

    // Minor carbon dioxide mixture has nine nodes at each temperature.
    ldr d3,[x29,#440]
    fmul d3,d3,d1
    fadd d3,d0,d3
    fdiv d4,d0,d3
    fminnm d4,d4,d2
    fmov d5,#8.0
    fmul d5,d5,d4
    fcvtzs w10,d5
    scvtf d7,w10
    fsub d6,d5,d7
    str d6,[x29,#592]
    FIELD x9,30
    ldr w11,[x9,x25,lsl #2]
    sub w11,w11,#1
    mov w9,#9
    madd w11,w11,w9,w10
    GOT x15,__yoerrta13_MOD_ka_mco2
    add x15,x15,x11,lsl #3

    // The zero-column carbon monoxide stage still evaluates its coefficient.
    ldr d3,[x29,#600]
    fmul d3,d3,d1
    fadd d3,d0,d3
    fdiv d4,d0,d3
    fminnm d4,d4,d2
    fmov d5,#8.0
    fmul d5,d5,d4
    fcvtzs w10,d5
    scvtf d7,w10
    fsub d6,d5,d7
    str d6,[x29,#608]
    FIELD x9,30
    ldr w11,[x9,x25,lsl #2]
    sub w11,w11,#1
    mov w9,#9
    madd w11,w11,w9,w10
    GOT x16,__yoerrta13_MOD_ka_mco
    add x16,x16,x11,lsl #3

    FIELD x9,12
    ldr w11,[x9,x25,lsl #2]
    sub w11,w11,#1
    GOT x14,__yoerrta13_MOD_forref
    add x14,x14,x11,lsl #3
    FIELD x9,10
    ldr d16,[x9,x25,lsl #3]
    FIELD x9,11
    ldr d17,[x9,x25,lsl #3]
    FIELD x9,25
    ldr w11,[x9,x25,lsl #2]
    sub w11,w11,#1
    GOT x13,__yoerrta13_MOD_selfref
    add x13,x13,x11,lsl #3
    FIELD x9,23
    ldr d18,[x9,x25,lsl #3]
    FIELD x9,24
    ldr d19,[x9,x25,lsl #3]
    ldr d8,[x29,#584]
    b .Llw13_common
.Llw13_upper_setup:
    FIELD x9,30
    ldr w11,[x9,x25,lsl #2]
    sub w11,w11,#1
    GOT x15,__yoerrta13_MOD_kb_mo3
    add x15,x15,x11,lsl #3
    GOT x12,__yoerrta13_MOD_fracrefb
    FIELD x9,20
    ldr d18,[x9,x25,lsl #3]
.Llw13_common:
    FIELD x9,29
    ldr d7,[x9,x25,lsl #3]
    mul x9,x19,x21
    mov x10,#12
    madd x9,x9,x10,x25
    FIELD x10,5
    ldr d20,[x10,x9,lsl #3]
    mov x9,#140
    mul x9,x23,x9
    add x9,x9,#130
    madd x9,x9,x19,x24
    FIELD x10,4
    add x26,x10,x9,lsl #3
    FIELD x10,26
    add x27,x10,x9,lsl #3
    mov x30,#0
.Llw13_point:
    ldr w9,[x29,#416]
    cbz w9,.Llw13_upper_point
    MAJOR d21,x28,448,480,576
    MAJOR d22,x17,456,528,580
    fadd d21,d21,d22
    ldp d26,d27,[x13]
    fsub d27,d27,d26
    fmul d27,d19,d27
    fadd d26,d26,d27
    fmul d26,d18,d26
    fadd d21,d21,d26
    ldp d26,d27,[x14]
    fsub d27,d27,d26
    fmul d27,d17,d27
    fadd d26,d26,d27
    fmul d26,d16,d26
    fadd d21,d21,d26
    ldp d24,d25,[x15]
    fsub d25,d25,d24
    ldr d26,[x29,#592]
    fmul d25,d26,d25
    fadd d24,d24,d25
    ldp d25,d27,[x15,#72]
    fsub d27,d27,d25
    fmul d27,d26,d27
    fadd d25,d25,d27
    fsub d25,d25,d24
    fmul d25,d7,d25
    fadd d24,d24,d25
    fmul d24,d8,d24
    fadd d21,d21,d24
    ldp d24,d25,[x16]
    fsub d25,d25,d24
    ldr d26,[x29,#608]
    fmul d25,d26,d25
    fadd d24,d24,d25
    ldp d25,d27,[x16,#72]
    fsub d27,d27,d25
    fmul d27,d26,d27
    fadd d25,d25,d27
    fsub d25,d25,d24
    fmul d25,d7,d25
    fadd d24,d24,d25
    fmov d26,xzr
    fmul d24,d26,d24
    fadd d21,d21,d24
    fadd d21,d21,d20
    ldr d25,[x12]
    ldr d26,[x12,#32]
    fsub d26,d26,d25
    ldr d27,[x29,#464]
    fmul d26,d27,d26
    fadd d25,d25,d26
    b .Llw13_store
.Llw13_upper_point:
    ldp d24,d25,[x15]
    fsub d25,d25,d24
    fmul d25,d7,d25
    fadd d24,d24,d25
    fmul d21,d18,d24
    fadd d21,d21,d20
    ldr d25,[x12]
.Llw13_store:
    str d21,[x26]
    str d25,[x27]
    add x30,x30,#1
    cmp x30,#4
    b.eq .Llw13_next_column
    ldr w9,[x29,#416]
    cbz w9,.Llw13_upper_next
    mov x9,#4680
    add x28,x28,x9
    add x17,x17,x9
    add x13,x13,#80
    add x14,x14,#32
    add x15,x15,#1368
    add x16,x16,#1368
    b .Llw13_next_point
.Llw13_upper_next:
    add x15,x15,#152
.Llw13_next_point:
    add x12,x12,#8
    add x26,x26,x22
    add x27,x27,x22
    b .Llw13_point
.Llw13_next_column:
    add x24,x24,#1
    cmp x24,x19
    b.lt .Llw13_column
    add x23,x23,#1
    cmp x23,x20
    b.lt .Llw13_layer
.Llw13_return:
    ldp d8,d9,[sp,#352]
    ldp d10,d11,[sp,#368]
    ldp d12,d13,[sp,#384]
    ldp d14,d15,[sp,#400]
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#768
    ret
.Llw13_reject:
    brk #0x691
.size md2asm_rrtm_taumol13,.-md2asm_rrtm_taumol13
.section .rodata
.p2align 3
.Llw13_scale:
    .quad 0x4415af1d78b58c40
.Llw13_inverse_scale:
    .quad 0x3bc79ca10c924223
.Llw13_exponent:
    .quad 0x3fe5c28f5c28f5c3
.Llw13_chi64:
    .quad 0x3f3743e963dc486b
.Llw13_chi32_promoted:
    .quad 0x3f3743e960000000
.section .note.GNU-stack,"",%progbits
