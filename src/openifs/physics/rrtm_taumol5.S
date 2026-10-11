// Complete longwave water-carbon-dioxide and ozone-carbon-dioxide absorption.
// Physics: formulations/openifs/physics/longwave_water_carbon_dioxide_ozone_trace.md.
// Contract: skills/md2asm/references/openifs/physics/rrtm_taumol5.md.
// GNU Fortran has 32 reference arguments and a fixed 640-byte aligned frame.
// Complete outputs store columns, then 140 spectral points, then levels.
// Preserve x19-x29, the link register, x18 and d8-d15.
.arch armv8-a
.text
.p2align 4
.global md2asm_rrtm_taumol5
.type md2asm_rrtm_taumol5,%function
.macro FIELD reg,idx
    ldr \reg,[x29,#(96+8*\idx)]
.endm
.macro GOT reg,sym
    adrp \reg,:got:\sym
    ldr \reg,[\reg,:got_lo12:\sym]
.endm
// Prepare one pressure corner from the selected species and carbon dioxide.
// d0, d1 and d2 hold species column, carbon-dioxide column and scalar cap.
.macro CORNER ptr,ratio,fac0,fac1,qslot,wslot,mode
    FIELD x9,\ratio
    ldr d3,[x9,x25,lsl #3]
    fmul d3,d3,d1
    fadd d3,d0,d3
    str d3,[x29,#\qslot]
    fdiv d4,d0,d3
    fminnm d4,d4,d2
    ldr w9,[x29,#352]
    fmov d5,#4.0
    cbz w9,.Lcorner_scale\@
    fmov d5,#8.0
.Lcorner_scale\@:
    fmul d5,d5,d4
    fcvtzs w10,d5
    scvtf d7,w10
    fsub d6,d5,d7
    add \ptr,\ptr,x10,lsl #3
    FIELD x9,\fac0
    ldr d19,[x9,x25,lsl #3]
    FIELD x9,\fac1
    ldr d20,[x9,x25,lsl #3]
    ldr w9,[x29,#352]
    cbz w9,.Lcorner_linear\@
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
    stp d17,d18,[x29,#\wslot]
    fmul d17,d16,d20
    fmul d18,d6,d20
    stp d17,d18,[x29,#(\wslot+16)]
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
    stp d3,d4,[x29,#\wslot]
    str d5,[x29,#(\wslot+16)]
    fmul d3,d16,d20
    fmul d4,d17,d20
    fmul d5,d18,d20
    stp d3,d4,[x29,#(\wslot+24)]
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
    ldr w9,[x29,#352]
    cbz w9,.Lmajor_upper\@
    ldr d25,[\ptr,#72]
    ldr d26,[x29,#(\wslot+16)]
    fmul d25,d26,d25
    fadd \out,\out,d25
    ldr d25,[\ptr,#80]
    b .Lmajor_linear_last\@
.Lmajor_upper\@:
    ldr d25,[\ptr,#40]
    ldr d26,[x29,#(\wslot+16)]
    fmul d25,d26,d25
    fadd \out,\out,d25
    ldr d25,[\ptr,#48]
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
md2asm_rrtm_taumol5:
    sub sp,sp,#640
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
    ldr x9,[sp,#640]
    ldr x10,[sp,#648]
    stp x9,x10,[sp,#160]
    ldr x9,[sp,#656]
    ldr x10,[sp,#664]
    stp x9,x10,[sp,#176]
    ldr x9,[sp,#672]
    ldr x10,[sp,#680]
    stp x9,x10,[sp,#192]
    ldr x9,[sp,#688]
    ldr x10,[sp,#696]
    stp x9,x10,[sp,#208]
    ldr x9,[sp,#704]
    ldr x10,[sp,#712]
    stp x9,x10,[sp,#224]
    ldr x9,[sp,#720]
    ldr x10,[sp,#728]
    stp x9,x10,[sp,#240]
    ldr x9,[sp,#736]
    ldr x10,[sp,#744]
    stp x9,x10,[sp,#256]
    ldr x9,[sp,#752]
    ldr x10,[sp,#760]
    stp x9,x10,[sp,#272]
    ldr x9,[sp,#768]
    ldr x10,[sp,#776]
    stp x9,x10,[sp,#288]
    ldr x9,[sp,#784]
    ldr x10,[sp,#792]
    stp x9,x10,[sp,#304]
    ldr x9,[sp,#800]
    ldr x10,[sp,#808]
    stp x9,x10,[sp,#320]
    ldr x9,[sp,#816]
    ldr x10,[sp,#824]
    stp x9,x10,[sp,#336]
    mov x29,sp
    GOT x9,__yoerrtrf_MOD_chi_mls
    ldr d0,[x9,#224]
    ldr d1,[x9,#232]
    fdiv d0,d0,d1
    str d0,[x29,#368]
    ldr d0,[x9,#2368]
    ldr d1,[x9,#2360]
    fdiv d0,d0,d1
    str d0,[x29,#376]
    ldr d0,[x9,#336]
    ldr d1,[x9,#344]
    fdiv d0,d0,d1
    str d0,[x29,#528]
    ldr w19,[x2]
    ldr w9,[x1]
    sub w19,w19,w9
    add w19,w19,#1
    ldr w20,[x3]
    ldr w21,[x0]
    cbz w19,.Llw5_return
    cbz w20,.Llw5_return
    lsl x22,x19,#3
    fmov d31,#1.0
    mov x23,#0
.Llw5_layer:
    mov x24,#0
.Llw5_column:
    madd x25,x23,x19,x24
    FIELD x9,21
    ldr w10,[x9,x24,lsl #2]
    cmp w23,w10
    cset w16,lt
    str w16,[x29,#352]
    FIELD x9,14
    ldr w10,[x9,x25,lsl #2]
    FIELD x9,15
    ldr w11,[x9,x25,lsl #2]
    FIELD x9,16
    ldr w12,[x9,x25,lsl #2]
    sub w11,w11,#1
    sub w12,w12,#1
    cbz w16,.Llw5_upper_rows
    mov w9,w10
    sub w10,w10,#1
    mov w16,#9
    GOT x13,yoerrta5.eq.1_
    mov x14,#4680
    b .Llw5_rows
.Llw5_upper_rows:
    sub w9,w10,#12
    sub w10,w10,#13
    mov w16,#5
    GOT x13,yoerrta5.eq.0_
    mov x14,#9400
.Llw5_rows:
    str x14,[x29,#360]
    mov w17,#5
    madd w11,w10,w17,w11
    madd w12,w9,w17,w12
    mul w11,w11,w16
    mul w12,w12,w16
    add x28,x13,x11,lsl #3
    add x17,x13,x12,lsl #3
    FIELD x9,19
    ldr d1,[x9,x25,lsl #3]
    FIELD x9,17
    ldr d2,[x9]
    ldr w9,[x29,#352]
    cbz w9,.Llw5_upper_mixture
    FIELD x9,18
    ldr d0,[x9,x25,lsl #3]
    CORNER x28,26,7,9,384,432,408
    CORNER x17,27,8,10,392,480,412
    ldr d3,[x29,#368]
    GOT x12,__yoerrta5_MOD_fracrefa
    fmov d5,#8.0
    b .Llw5_planck
.Llw5_upper_mixture:
    FIELD x9,20
    ldr d0,[x9,x25,lsl #3]
    CORNER x28,28,7,9,384,432,408
    CORNER x17,29,8,10,392,480,412
    ldr d3,[x29,#376]
    GOT x12,__yoerrta5_MOD_fracrefb
    fmov d5,#4.0
.Llw5_planck:
    fmul d3,d3,d1
    fadd d3,d0,d3
    fdiv d4,d0,d3
    fminnm d4,d4,d2
    fmul d5,d5,d4
    fcvtzs w10,d5
    scvtf d7,w10
    fsub d6,d5,d7
    str d6,[x29,#400]
    mov x9,#128
    madd x12,x10,x9,x12
    ldr w9,[x29,#352]
    cbz w9,.Llw5_continuum_done
    FIELD x9,13
    ldr w10,[x9,x25,lsl #2]
    sub w10,w10,#1
    GOT x14,__yoerrta5_MOD_forref
    add x14,x14,x10,lsl #3
    FIELD x9,24
    ldr w10,[x9,x25,lsl #2]
    sub w10,w10,#1
    GOT x13,__yoerrta5_MOD_selfref
    add x13,x13,x10,lsl #3
    FIELD x9,11
    ldr d16,[x9,x25,lsl #3]
    FIELD x9,12
    ldr d17,[x9,x25,lsl #3]
    FIELD x9,22
    ldr d18,[x9,x25,lsl #3]
    FIELD x9,23
    ldr d19,[x9,x25,lsl #3]

    // Prepare lower minor ozone mixture and its adjacent temperature nodes.
    ldr d3,[x29,#528]
    fmul d3,d3,d1
    fadd d3,d0,d3
    fdiv d4,d0,d3
    fminnm d4,d4,d2
    fmov d5,#8.0
    fmul d5,d5,d4
    fcvtzs w10,d5
    scvtf d7,w10
    fsub d6,d5,d7
    str d6,[x29,#536]
    FIELD x9,31
    ldr w11,[x9,x25,lsl #2]
    sub w11,w11,#1
    mov w9,#9
    madd w11,w11,w9,w10
    GOT x9,__yoerrta5_MOD_ka_mo3
    add x11,x9,x11,lsl #3
    FIELD x9,30
    ldr d3,[x9,x25,lsl #3]
    str d3,[x29,#544]
    FIELD x9,20
    ldr d3,[x9,x25,lsl #3]
    str d3,[x29,#568]
.Llw5_continuum_done:
    FIELD x9,6
    mul x10,x19,x21
    lsl x10,x10,#2
    add x10,x10,x25
    ldr d20,[x9,x10,lsl #3]

    // WX holds four trace-gas columns at each allocated level.
    FIELD x9,5
    mul x10,x23,x19
    add x10,x10,x10,lsl #1
    add x10,x10,x25
    ldr d23,[x9,x10,lsl #3]
    GOT x15,__yoerrta5_MOD_ccl4
    mov x9,#140
    mul x9,x23,x9
    madd x9,x9,x19,x24
    mov x10,#52
    madd x9,x19,x10,x9
    FIELD x10,4
    add x26,x10,x9,lsl #3
    FIELD x10,25
    add x27,x10,x9,lsl #3
    mov x30,#0
.Llw5_point:
    MAJOR d21,x28,384,432,408
    MAJOR d22,x17,392,480,412
    fadd d21,d21,d22
    ldr w9,[x29,#352]
    cbz w9,.Llw5_trace
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

    // Interpolate ozone by mixture first, then by minor temperature.
    ldp d24,d25,[x11]
    fsub d25,d25,d24
    ldr d26,[x29,#536]
    fmul d25,d26,d25
    fadd d24,d24,d25
    ldp d25,d27,[x11,#72]
    fsub d27,d27,d25
    fmul d27,d26,d27
    fadd d25,d25,d27
    fsub d25,d25,d24
    ldr d27,[x29,#544]
    fmul d25,d27,d25
    fadd d24,d24,d25
    ldr d25,[x29,#568]
    fmul d24,d24,d25
    fadd d21,d21,d24
.Llw5_trace:
    ldr d25,[x15]
    fmul d25,d23,d25
    fadd d21,d21,d25
    fadd d21,d21,d20
    str d21,[x26]
    ldr d25,[x12]
    ldr d26,[x12,#128]
    fsub d26,d26,d25
    ldr d27,[x29,#400]
    fmul d26,d27,d26
    fadd d25,d25,d26
    str d25,[x27]
    add x30,x30,#1
    cmp x30,#16
    b.eq .Llw5_next_column
    ldr x9,[x29,#360]
    add x28,x28,x9
    add x17,x17,x9
    add x13,x13,#80
    add x14,x14,#32
    add x11,x11,#1368
    add x15,x15,#8
    add x12,x12,#8
    add x26,x26,x22
    add x27,x27,x22
    b .Llw5_point
.Llw5_next_column:
    add x24,x24,#1
    cmp x24,x19
    b.lt .Llw5_column
    add x23,x23,#1
    cmp x23,x20
    b.lt .Llw5_layer
.Llw5_return:
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#640
    ret
.size md2asm_rrtm_taumol5,.-md2asm_rrtm_taumol5
.section .note.GNU-stack,"",%progbits
