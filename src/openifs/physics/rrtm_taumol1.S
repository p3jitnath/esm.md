// Complete longwave water, continuum, nitrogen and aerosol absorption.
// Physics: formulations/openifs/physics/longwave_water_nitrogen.md.
// Contract: skills/md2asm/references/openifs/physics/rrtm_taumol1.md.
// GNU Fortran has 27 reference arguments, copied into a fixed 352-byte frame.
// Complete outputs store columns, then 140 spectral points, then levels.
// Preserve x19-x29, the link register, x18, d8-d15 and stack alignment.
.arch armv8-a
.text
.p2align 4
.global md2asm_rrtm_taumol1
.type md2asm_rrtm_taumol1,%function
.macro FIELD reg,idx
    ldr \reg,[x29,#(96+8*\idx)]
.endm
.macro GOT reg,sym
    adrp \reg,:got:\sym
    ldr \reg,[\reg,:got_lo12:\sym]
.endm
md2asm_rrtm_taumol1:
    sub sp,sp,#352
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    stp x0,x1,[sp,#96]
    stp x2,x3,[sp,#112]
    stp x4,x5,[sp,#128]
    stp x6,x7,[sp,#144]
    ldp x9,x10,[sp,#352]
    stp x9,x10,[sp,#160]
    ldp x9,x10,[sp,#368]
    stp x9,x10,[sp,#176]
    ldp x9,x10,[sp,#384]
    stp x9,x10,[sp,#192]
    ldp x9,x10,[sp,#400]
    stp x9,x10,[sp,#208]
    ldp x9,x10,[sp,#416]
    stp x9,x10,[sp,#224]
    ldp x9,x10,[sp,#432]
    stp x9,x10,[sp,#240]
    ldp x9,x10,[sp,#448]
    stp x9,x10,[sp,#256]
    ldp x9,x10,[sp,#464]
    stp x9,x10,[sp,#272]
    ldp x9,x10,[sp,#480]
    stp x9,x10,[sp,#288]
    ldr x9,[sp,#496]
    str x9,[sp,#304]
    ldr w19,[x2]
    ldr w9,[x1]
    sub w19,w19,w9
    add w19,w19,#1
    ldr w20,[x3]
    ldr w21,[x0]
    cbz w19,.Llw1_return
    cbz w20,.Llw1_return
    mov x29,sp
    lsl x22,x19,#3
    fmov d31,#1.0
    mov x23,#0
.Llw1_layer:
    mov x24,#0
.Llw1_column:
    madd x25,x23,x19,x24
    FIELD x9,18
    ldr w10,[x9,x24,lsl #2]
    cmp w23,w10
    cset w16,lt
    str w16,[x29,#312]
    FIELD x9,14
    ldr w10,[x9,x25,lsl #2]
    FIELD x9,15
    ldr w11,[x9,x25,lsl #2]
    FIELD x9,16
    ldr w12,[x9,x25,lsl #2]
    sub w11,w11,#1
    sub w12,w12,#1
    cbz w16,.Llw1_upper_rows
    mov w9,w10
    sub w10,w10,#1
    GOT x13,yoerrta1.eq.1_
    b .Llw1_rows
.Llw1_upper_rows:
    sub w9,w10,#12
    sub w10,w10,#13
    GOT x13,yoerrta1.eq.0_
.Llw1_rows:
    mov w17,#5
    madd w11,w10,w17,w11
    madd w12,w9,w17,w12
    add x28,x13,x11,lsl #3
    add x17,x13,x12,lsl #3
    FIELD x9,13
    ldr w10,[x9,x25,lsl #2]
    sub w10,w10,#1
    GOT x14,__yoerrta1_MOD_forref
    add x14,x14,x10,lsl #3
    FIELD x9,24
    ldr w10,[x9,x25,lsl #2]
    sub w10,w10,#1
    cbz w16,.Llw1_upper_tables
    GOT x15,__yoerrta1_MOD_ka_mn2
    GOT x12,__yoerrta1_MOD_fracrefa
    FIELD x9,21
    ldr w11,[x9,x25,lsl #2]
    sub w11,w11,#1
    GOT x13,__yoerrta1_MOD_selfref
    add x13,x13,x11,lsl #3
    FIELD x9,19
    ldr d18,[x9,x25,lsl #3]
    FIELD x9,20
    ldr d19,[x9,x25,lsl #3]
    b .Llw1_tables
.Llw1_upper_tables:
    GOT x15,__yoerrta1_MOD_kb_mn2
    GOT x12,__yoerrta1_MOD_fracrefb
    mov x13,#0
.Llw1_tables:
    add x15,x15,x10,lsl #3
    FIELD x9,5
    ldr d25,[x9,x25,lsl #3]
    cbz w16,.Llw1_upper_pressure
    fmov d5,d31
    adrp x9,.Llw1_250
    ldr d26,[x9,:lo12:.Llw1_250]
    fcmp d25,d26
    b.ge .Llw1_pressure_done
    fsub d26,d26,d25
    adrp x9,.Llw1_015
    ldr d27,[x9,:lo12:.Llw1_015]
    fmul d26,d27,d26
    adrp x9,.Llw1_1544
    ldr d27,[x9,:lo12:.Llw1_1544]
    fdiv d26,d26,d27
    fsub d5,d31,d26
    b .Llw1_pressure_done
.Llw1_upper_pressure:
    adrp x9,.Llw1_956
    ldr d27,[x9,:lo12:.Llw1_956]
    fdiv d26,d25,d27
    adrp x9,.Llw1_015
    ldr d27,[x9,:lo12:.Llw1_015]
    fmul d26,d27,d26
    fsub d5,d31,d26
.Llw1_pressure_done:
    FIELD x9,26
    ldr d6,[x9,x25,lsl #3]
    FIELD x9,25
    ldr d25,[x9,x25,lsl #3]
    fmul d6,d6,d25
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
    FIELD x9,11
    ldr d16,[x9,x25,lsl #3]
    FIELD x9,12
    ldr d17,[x9,x25,lsl #3]
    FIELD x9,23
    ldr d7,[x9,x25,lsl #3]
    FIELD x9,6
    ldr d20,[x9,x25,lsl #3]
    mov x9,#140
    mul x9,x23,x9
    madd x9,x9,x19,x24
    FIELD x10,4
    add x26,x10,x9,lsl #3
    FIELD x10,22
    add x27,x10,x9,lsl #3
    mov x30,#0
.Llw1_point:
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
    ldr w9,[x29,#312]
    cbz w9,.Llw1_foreign
    ldp d26,d27,[x13]
    fsub d27,d27,d26
    fmul d27,d19,d27
    fadd d26,d26,d27
    fmul d22,d18,d26
    fadd d21,d21,d22
.Llw1_foreign:
    ldp d26,d27,[x14]
    fsub d27,d27,d26
    fmul d27,d17,d27
    fadd d26,d26,d27
    fmul d23,d16,d26
    fadd d21,d21,d23
    ldp d26,d27,[x15]
    fsub d27,d27,d26
    fmul d27,d7,d27
    fadd d26,d26,d27
    fmul d24,d6,d26
    fadd d21,d21,d24
    fmul d21,d5,d21
    fadd d21,d21,d20
    str d21,[x26]
    ldr d25,[x12]
    str d25,[x27]
    add x30,x30,#1
    cmp x30,#10
    b.eq .Llw1_next_column
    ldr w10,[x29,#312]
    mov x9,#520
    mov x11,#1880
    cmp w10,#0
    csel x9,x9,x11,ne
    add x28,x28,x9
    add x17,x17,x9
    add x13,x13,#80
    add x14,x14,#32
    add x15,x15,#152
    add x12,x12,#8
    add x26,x26,x22
    add x27,x27,x22
    b .Llw1_point
.Llw1_next_column:
    add x24,x24,#1
    cmp x24,x19
    b.lt .Llw1_column
    add x23,x23,#1
    cmp x23,x20
    b.lt .Llw1_layer
.Llw1_return:
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#352
    ret
.size md2asm_rrtm_taumol1,.-md2asm_rrtm_taumol1
.section .rodata
.p2align 3
.Llw1_250:
    .double 250.0
.Llw1_015:
    .double 0.15
.Llw1_1544:
    .double 154.4
.Llw1_956:
    .double 95.6
.section .note.GNU-stack,"",%progbits
