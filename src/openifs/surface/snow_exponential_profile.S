// Complete snow profiles from formulations/openifs/surface/snow_exponential_profile.md.
// The source follows the frozen 31-address GNU ABI and ordered md2asm contract.
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __surfws_fgprof_mod_MOD_surfws_fgprof
#endif
.text
.p2align 4
.global md2asm_snow_exponential_profile
.global ORIGINAL_SYMBOL
.type md2asm_snow_exponential_profile,%function
md2asm_snow_exponential_profile:
ORIGINAL_SYMBOL:
    sub sp,sp,#640
    stp x29,x30,[sp,#0]
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    stp d8,d9,[sp,#96]
    stp d10,d11,[sp,#112]
    stp d12,d13,[sp,#128]
    stp d14,d15,[sp,#144]
    stp x0,x1,[sp,#160]
    stp x2,x3,[sp,#176]
    stp x4,x5,[sp,#192]
    stp x6,x7,[sp,#208]
    add x16,sp,#640
    ldr x9,[x16,#0]
    str x9,[sp,#224]
    ldr x9,[x16,#8]
    str x9,[sp,#232]
    ldr x9,[x16,#16]
    str x9,[sp,#240]
    ldr x9,[x16,#24]
    str x9,[sp,#248]
    ldr x9,[x16,#32]
    str x9,[sp,#256]
    ldr x9,[x16,#40]
    str x9,[sp,#264]
    ldr x9,[x16,#48]
    str x9,[sp,#272]
    ldr x9,[x16,#56]
    str x9,[sp,#280]
    ldr x9,[x16,#64]
    str x9,[sp,#288]
    ldr x9,[x16,#72]
    str x9,[sp,#296]
    ldr x9,[x16,#80]
    str x9,[sp,#304]
    ldr x9,[x16,#88]
    str x9,[sp,#312]
    ldr x9,[x16,#96]
    str x9,[sp,#320]
    ldr x9,[x16,#104]
    str x9,[sp,#328]
    ldr x9,[x16,#112]
    str x9,[sp,#336]
    ldr x9,[x16,#120]
    str x9,[sp,#344]
    ldr x9,[x16,#128]
    str x9,[sp,#352]
    ldr x9,[x16,#136]
    str x9,[sp,#360]
    ldr x9,[x16,#144]
    str x9,[sp,#368]
    ldr x9,[x16,#152]
    str x9,[sp,#376]
    ldr x9,[x16,#160]
    str x9,[sp,#384]
    ldr x9,[x16,#168]
    str x9,[sp,#392]
    ldr x9,[x16,#176]
    str x9,[sp,#400]
    mov x19,sp
    ldr x0,[x19,#160]
    ldr w20,[x0]
    sub w20,w20,#1
    ldr x0,[x19,#168]
    ldr w22,[x0]
    ldr x0,[x19,#184]
    ldr w21,[x0]
    cmp w20,w22
    b.ge .Ldone
    ldr x0,[x19,#392]
    ldr d0,[x0]
    str d0,[x19,#416]
    ldr x0,[x19,#400]
    ldr d0,[x0,#1832]
    str d0,[x19,#424]
    ldr w9,[x0,#488]
    str w9,[x19,#432]
    ldr x0,[x19,#208]
    ldr d0,[x0]
    str d0,[x19,#440]
    ldr x0,[x19,#216]
    ldr d0,[x0]
    str d0,[x19,#448]
    ldr d15,.Lepsilon
.Lcolumn:
    ldr x0,[x19,#224]
    mov x1,x20
    bl .Lload_integer
    cbnz w0,.Lnext_column
    ldr x0,[x19,#192]
    mov x1,x20
    bl .Lload_integer
    mov w23,w0
    cmp w23,#1
    b.le .Lnext_column
    ldr x0,[x19,#264]
    mov x1,x20
    bl .Lload_real
    ldr d1,[x19,#440]
    fcmp d0,d1
    b.lt .Lnext_column
    str d0,[x19,#576]
    ldr x0,[x19,#200]
    mov x1,x20
    bl .Lload_integer
    mov w24,w0
    sub x24,x24,#1
    ldr x0,[x19,#352]
    mov x1,x20
    bl .Lload_integer
    mov w28,w0
    sub x28,x28,#1
    ldr x0,[x19,#344]
    mov x1,x20
    mov x2,x28
    bl .Lload_layer
    fmov d8,d0
    ldr x0,[x19,#368]
    mov x1,x20
    bl .Lload_integer
    mov w28,w0
    sub x28,x28,#1
    ldr x0,[x19,#360]
    mov x1,x20
    mov x2,x28
    bl .Lload_layer
    fmov d9,d0
    ldr x0,[x19,#312]
    mov x1,x20
    bl .Lload_real
    str d0,[x19,#520]
    ldr x0,[x19,#304]
    mov x1,x20
    bl .Lload_real
    str d0,[x19,#528]
    ldr x0,[x19,#320]
    mov x1,x20
    bl .Lload_real
    str d0,[x19,#536]
    ldr x0,[x19,#248]
    mov x1,x20
    bl .Lload_real
    str d0,[x19,#544]
    ldr x0,[x19,#328]
    mov x1,x20
    bl .Lload_real
    str d0,[x19,#552]
    ldr x0,[x19,#336]
    mov x1,x20
    bl .Lload_real
    str d0,[x19,#560]
    ldr x0,[x19,#240]
    mov x1,x20
    bl .Lload_real
    str d0,[x19,#568]
    ldr x0,[x19,#272]
    mov x1,x20
    bl .Lload_real
    str d0,[x19,#584]
    ldr x0,[x19,#296]
    mov x1,x20
    bl .Lload_real
    str d0,[x19,#592]
    ldr x0,[x19,#256]
    mov x1,x20
    bl .Lload_real
    str d0,[x19,#600]
    ldr d0,[x19,#568]
    ldr d1,[x19,#448]
    fcmp d0,d1
    cset w26,ge
    mov x25,#-1
    ldr w9,[x19,#432]
    cmp w9,#2
    b.eq .Lchoose_middle
    cmp w9,#3
    b.ne .Lmiddle_ready
.Lchoose_middle:
    ldr d0,[x19,#576]
    ldr d1,.Lhalf
    fcmp d0,d1
    sub x9,x23,#2
    csel x25,x9,x24,ge
.Lmiddle_ready:
// Select the temperature anchor and its depth before calling the accepted EXP.
    ldr d0,[x19,#576]
    ldr d1,.Lpoint2
    fcmp d0,d1
    b.lt .Lshallow_anchor
    ldr d2,[x19,#520]
    ldr d3,[x19,#536]
    fcmp d2,d3
    b.lt .Lcold_anchor
    ldr d0,[x19,#584]
    ldr d1,[x19,#416]
    fmin d2,d2,d1
    str d2,[x19,#608]
    b .Ltemperature_amplitude
.Lcold_anchor:
    ldr d0,[x19,#584]
    ldr d1,[x19,#592]
    fadd d0,d0,d1
    ldr d2,[x19,#520]
    str d2,[x19,#608]
    b .Ltemperature_amplitude
.Lshallow_anchor:
    ldr d2,[x19,#520]
    str d2,[x19,#608]
.Ltemperature_amplitude:
    fneg d0,d0
    fmul d0,d0,d8
    bl exp
    fmax d0,d0,d15
    fmov d1,#1.0
    fsub d0,d0,d1
    bl .Lregularise
    ldr d0,[x19,#528]
    ldr d2,[x19,#520]
    fsub d0,d0,d2
    fdiv d10,d0,d1
    ldr d0,[x19,#608]
    fsub d11,d0,d10
// Density anchoring uses the unmodified top and middle exponentials.
    ldr x0,[x19,#288]
    mov x1,x20
    mov x2,x24
    bl .Lload_layer
    fneg d0,d0
    fmul d0,d0,d9
    bl exp
    str d0,[x19,#616]
    ldr x0,[x19,#288]
    mov x1,x20
    mov x2,xzr
    bl .Lload_layer
    fneg d0,d0
    fmul d0,d0,d9
    bl exp
    fmov d14,d0
    ldr d0,[x19,#616]
    fsub d0,d0,d14
    bl .Lregularise
    ldr d0,[x19,#544]
    ldr d2,[x19,#552]
    fsub d0,d0,d2
    fdiv d12,d0,d1
    fmul d0,d12,d14
    fsub d13,d2,d0
    mov x27,#0
.Llayer:
    ldr x0,[x19,#280]
    mov x1,x20
    mov x2,x27
    bl .Lload_layer
    fneg d0,d0
    fmul d0,d0,d8
    bl exp
    fmax d0,d0,d15
    fmul d0,d10,d0
    fadd d0,d11,d0
    ldr d1,[x19,#416]
    fmin d0,d1,d0
    ldr x0,[x19,#376]
    mov x1,x20
    mov x2,x27
    bl .Lstore_layer
    cmp x25,#0
    b.lt .Ltemperature_safety
    ldr d0,[x19,#536]
    ldr x0,[x19,#376]
    mov x1,x20
    mov x2,x25
    bl .Lstore_layer
.Ltemperature_safety:
    ldr x0,[x19,#376]
    mov x1,x20
    mov x2,x27
    bl .Lload_layer
    ldr d1,.Lhundred
    fcmp d0,d1
    b.ge .Ldensity_layer
    ldr d0,[x19,#536]
    ldr x0,[x19,#376]
    mov x1,x20
    mov x2,x27
    bl .Lstore_layer
.Ldensity_layer:
    ldr x0,[x19,#288]
    mov x1,x20
    mov x2,x27
    bl .Lload_layer
    fneg d0,d0
    fmul d0,d0,d9
    bl exp
    fmax d0,d0,d15
    fmul d0,d12,d0
    fadd d0,d13,d0
    ldr x0,[x19,#384]
    mov x1,x20
    mov x2,x27
    bl .Lstore_layer
    ldr d0,[x19,#544]
    ldr x0,[x19,#384]
    mov x1,x20
    mov x2,x24
    bl .Lstore_layer
    ldr x0,[x19,#384]
    mov x1,x20
    mov x2,x27
    bl .Lload_layer
    ldr d1,[x19,#424]
    fcmp d0,d1
    b.ge .Lmaximum_density
    fmov d0,d1
    ldr x0,[x19,#384]
    mov x1,x20
    mov x2,x27
    bl .Lstore_layer
.Lmaximum_density:
    ldr d1,[x19,#560]
    fcmp d0,d1
    b.le .Lglacier_layer
    fmov d0,d1
    ldr x0,[x19,#384]
    mov x1,x20
    mov x2,x27
    bl .Lstore_layer
.Lglacier_layer:
    cbz w26,.Llayer_next
    sub x28,x23,#2
    ldr d0,.Lthreehundred
    ldr x0,[x19,#384]
    mov x1,x20
    mov x2,x28
    bl .Lstore_layer
    sub x28,x23,#1
    ldr d0,.Lthreehundred
    ldr x0,[x19,#384]
    mov x1,x20
    mov x2,x28
    bl .Lstore_layer
.Llayer_next:
    add x27,x27,#1
    cmp x27,x23
    b.lt .Llayer
    cbz w26,.Linactive
    sub x28,x23,#1
    ldr d0,[x19,#600]
    ldr d1,[x19,#416]
    fmin d0,d1,d0
    ldr x0,[x19,#376]
    mov x1,x20
    mov x2,x28
    bl .Lstore_layer
    mov x27,#0
.Lglacier_density:
    ldr d0,.Lthreehundred
    ldr x0,[x19,#384]
    mov x1,x20
    mov x2,x27
    bl .Lstore_layer
    add x27,x27,#1
    cmp x27,x21
    b.lt .Lglacier_density
.Linactive:
    cmp x23,x21
    b.ge .Lnext_column
    sub x28,x23,#1
    ldr x0,[x19,#376]
    mov x1,x20
    mov x2,x28
    bl .Lload_layer
    fmov d14,d0
    mov x27,x23
.Linactive_layer:
    fmov d0,d14
    ldr x0,[x19,#376]
    mov x1,x20
    mov x2,x27
    bl .Lstore_layer
    ldr d0,.Lhundred
    ldr x0,[x19,#384]
    mov x1,x20
    mov x2,x27
    bl .Lstore_layer
    add x27,x27,#1
    cmp x27,x21
    b.lt .Linactive_layer
.Lnext_column:
    add x20,x20,#1
    cmp x20,x22
    b.lt .Lcolumn
.Ldone:
    ldp x29,x30,[sp,#0]
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp d8,d9,[sp,#96]
    ldp d10,d11,[sp,#112]
    ldp d12,d13,[sp,#128]
    ldp d14,d15,[sp,#144]
    add sp,sp,#640
    ret
.size md2asm_snow_exponential_profile,.-md2asm_snow_exponential_profile
// Preserve the sign bit of the unclipped difference in the regularised denominator.
.Lregularise:
    fmov x9,d0
    and x9,x9,#0x8000000000000000
    fabs d1,d0
    fmax d1,d1,d15
    fmov x10,d1
    orr x10,x10,x9
    fmov d1,x10
    ret
// Descriptor accessors use caller-saved scratch registers only.
.Lload_real:
    ldr x9,[x0]
    ldr x10,[x0,#40]
    cmp x10,#0
    csinc x10,x10,xzr,ne
    mul x10,x1,x10
    ldr d0,[x9,x10,lsl #3]
    ret
.Lload_layer:
    ldr x9,[x0]
    ldr x10,[x0,#40]
    cmp x10,#0
    csinc x10,x10,xzr,ne
    ldr x11,[x0,#64]
    mul x10,x1,x10
    madd x10,x2,x11,x10
    ldr d0,[x9,x10,lsl #3]
    ret
.Lstore_layer:
    ldr x9,[x0]
    ldr x10,[x0,#40]
    cmp x10,#0
    csinc x10,x10,xzr,ne
    ldr x11,[x0,#64]
    mul x10,x1,x10
    madd x10,x2,x11,x10
    str d0,[x9,x10,lsl #3]
    ret
.Lload_integer:
    ldr x9,[x0]
    ldr x10,[x0,#40]
    cmp x10,#0
    csinc x10,x10,xzr,ne
    mul x10,x1,x10
    ldr w0,[x9,x10,lsl #2]
    ret
.p2align 3
.Lepsilon:
    .quad 0x3db86a0000000000
.Lhalf:
    .quad 0x3fe0000000000000
.Lpoint2:
    .quad 0x3fc999999999999a
.Lhundred:
    .quad 0x4059000000000000
.Lthreehundred:
    .quad 0x4072c00000000000
.section .note.GNU-stack,"",%progbits
