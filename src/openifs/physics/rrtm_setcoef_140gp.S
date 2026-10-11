/* Longwave pressure, temperature and gas preparation.
 * Physics formulations/openifs/physics/longwave_atmospheric_inputs.md.
 * Contract skills/md2asm/references/openifs/physics/rrtm_setcoef_140gp.md.
 * Forty-nine addresses and forty complete returned owners.
 * x19 columns, x20 layers, x21 reference gas table, x22 layer,
 * x23 column, x24 ordinary cell and x25 molecular cell.
 * Preserve x18 and d8 through d15. LOG and EXP use accepted scalar routes. */
.text
.p2align 4
.macro PARG reg,index
    ldr x\reg,[sp,#(96+8*\index)]
.endm
.macro GET reg,arg
    PARG 9,\arg
    ldr \reg,[x9,x24,lsl #3]
.endm
.macro PUT reg,arg
    PARG 9,\arg
    str \reg,[x9,x24,lsl #3]
.endm
.macro PUTI reg,arg
    PARG 9,\arg
    str \reg,[x9,x24,lsl #2]
.endm
.global md2asm_rrtm_setcoef_140gp
.type md2asm_rrtm_setcoef_140gp,%function
md2asm_rrtm_setcoef_140gp:
    mov x16,sp
    sub sp,sp,#640
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    mov x29,sp
    stp x0,x1,[sp,#96]
    stp x2,x3,[sp,#112]
    stp x4,x5,[sp,#128]
    stp x6,x7,[sp,#144]
    ldp x9,x10,[x16,#0]
    stp x9,x10,[sp,#160]
    ldp x9,x10,[x16,#16]
    stp x9,x10,[sp,#176]
    ldp x9,x10,[x16,#32]
    stp x9,x10,[sp,#192]
    ldp x9,x10,[x16,#48]
    stp x9,x10,[sp,#208]
    ldp x9,x10,[x16,#64]
    stp x9,x10,[sp,#224]
    ldp x9,x10,[x16,#80]
    stp x9,x10,[sp,#240]
    ldp x9,x10,[x16,#96]
    stp x9,x10,[sp,#256]
    ldp x9,x10,[x16,#112]
    stp x9,x10,[sp,#272]
    ldp x9,x10,[x16,#128]
    stp x9,x10,[sp,#288]
    ldp x9,x10,[x16,#144]
    stp x9,x10,[sp,#304]
    ldp x9,x10,[x16,#160]
    stp x9,x10,[sp,#320]
    ldp x9,x10,[x16,#176]
    stp x9,x10,[sp,#336]
    ldp x9,x10,[x16,#192]
    stp x9,x10,[sp,#352]
    ldp x9,x10,[x16,#208]
    stp x9,x10,[sp,#368]
    ldp x9,x10,[x16,#224]
    stp x9,x10,[sp,#384]
    ldp x9,x10,[x16,#240]
    stp x9,x10,[sp,#400]
    ldp x9,x10,[x16,#256]
    stp x9,x10,[sp,#416]
    ldp x9,x10,[x16,#272]
    stp x9,x10,[sp,#432]
    ldp x9,x10,[x16,#288]
    stp x9,x10,[sp,#448]
    ldp x9,x10,[x16,#304]
    stp x9,x10,[sp,#464]
    ldr x9,[x16,#320]
    str x9,[sp,#480]
    ldr w19,[x2]
    ldr w9,[x1]
    sub w19,w19,w9
    add w19,w19,#1
    sxtw x19,w19
    cbz x19,.Llwcoef_return
    ldr w20,[x3]
    uxtw x20,w20
    adrp x9,:got:__yoerrtrf_MOD_preflog
    ldr x27,[x9,:got_lo12:__yoerrtrf_MOD_preflog]
    adrp x9,:got:__yoerrtrf_MOD_tref
    ldr x28,[x9,:got_lo12:__yoerrtrf_MOD_tref]
    adrp x9,:got:__yoerrtrf_MOD_chi_mls
    ldr x21,[x9,:got_lo12:__yoerrtrf_MOD_chi_mls]
    mov x23,#0
.Llwcoef_counts:
    PARG 9,25
    str wzr,[x9,x23,lsl #2]
    PARG 9,26
    str wzr,[x9,x23,lsl #2]
    PARG 9,27
    mov w10,#1
    str w10,[x9,x23,lsl #2]
    add x23,x23,#1
    cmp x23,x19
    b.lt .Llwcoef_counts
    cbz x20,.Llwcoef_return
    mov x22,#0
.Llwcoef_level:
    mov x23,#0
.Llwcoef_column:
    madd x24,x22,x19,x23
    mov x9,#35
    mul x25,x22,x9
    madd x25,x25,x19,x23
    GET d0,28
    bl log
    str d0,[sp,#512]
    ldr d1,.LC_pressure_shift
    fadd d1,d0,d1
    ldr d2,.LC_five
    fmul d1,d2,d1
    ldr d3,.LC_thirtysix
    fsub d1,d3,d1
    fcvtzs w26,d1
    mov w9,#1
    cmp w26,w9
    csel w26,w9,w26,lt
    mov w9,#58
    cmp w26,w9
    csel w26,w9,w26,gt
    PUTI w26,14
    sub w10,w26,#1
    ldr d1,[x27,x10,lsl #3]
    fsub d1,d1,d0
    fmul d1,d2,d1
    ldr d2,.LC_one
    fmin d1,d2,d1
    fneg d2,d2
    fmax d1,d2,d1
    str d1,[sp,#520]
    sub w10,w26,#1
    ldr d2,[x28,x10,lsl #3]
    GET d1,29
    fsub d3,d1,d2
    ldr d4,.LC_fifteen
    fdiv d3,d3,d4
    ldr d4,.LC_three
    fadd d4,d4,d3
    fcvtzs w10,d4
    mov w11,#1
    cmp w10,w11
    csel w10,w11,w10,lt
    mov w11,#4
    cmp w10,w11
    csel w10,w11,w10,gt
    PUTI w10,15
    sub w10,w10,#3
    scvtf d4,w10
    fsub d3,d3,d4
    str d3,[sp,#528]
    mov w10,w26
    ldr d2,[x28,x10,lsl #3]
    GET d1,29
    fsub d3,d1,d2
    ldr d4,.LC_fifteen
    fdiv d3,d3,d4
    ldr d4,.LC_three
    fadd d4,d4,d3
    fcvtzs w10,d4
    mov w11,#1
    cmp w10,w11
    csel w10,w11,w10,lt
    mov w11,#4
    cmp w10,w11
    csel w10,w11,w10,gt
    PUTI w10,16
    sub w10,w10,#3
    scvtf d4,w10
    fsub d3,d3,d4
    str d3,[sp,#536]
    PARG 9,6
    ldr d2,[x9,x25,lsl #3]
    GET d3,4
    fdiv d2,d2,d3
    str d2,[sp,#544]
    GET d0,28
    ldr d4,.LC_standard_ratio
    fmul d0,d0,d4
    GET d1,29
    fdiv d0,d0,d1
    ldr d4,.LC_one
    fadd d3,d4,d2
    fdiv d0,d0,d3
    PUT d0,11
    fmul d2,d2,d0
    PUT d2,30
    ldr d2,[sp,#512]
    ldr d3,.LC_lower_switch
    fcmp d2,d3
    b.le .Llwcoef_upper
    PARG 9,25
    ldr w10,[x9,x23,lsl #2]
    add w10,w10,#1
    str w10,[x9,x23,lsl #2]
    ldr d2,.LC_threehundredthirtytwo
    fsub d2,d2,d1
    ldr d3,.LC_thirtysix
    fdiv d2,d2,d3
    fcvtzs w10,d2
    mov w11,#1
    cmp w10,w11
    csel w10,w11,w10,lt
    mov w11,#2
    cmp w10,w11
    csel w10,w11,w10,gt
    PUTI w10,13
    scvtf d3,w10
    fsub d2,d2,d3
    PUT d2,12
    ldr d2,.LC_oneeighteight
    fsub d2,d1,d2
    ldr d3,.LC_self_spacing
    fdiv d2,d2,d3
    fcvtzs w10,d2
    sub w10,w10,#7
    mov w11,#1
    cmp w10,w11
    csel w10,w11,w10,lt
    mov w11,#9
    cmp w10,w11
    csel w10,w11,w10,gt
    PUTI w10,32
    add w10,w10,#7
    scvtf d3,w10
    fsub d2,d2,d3
    PUT d2,31
    b .Llwcoef_minor
.Llwcoef_upper:
    mov w10,#3
    PUTI w10,13
    ldr d2,.LC_oneeighteight
    fsub d2,d1,d2
    ldr d3,.LC_thirtysix
    fdiv d2,d2,d3
    ldr d3,.LC_one
    fsub d2,d2,d3
    PUT d2,12
.Llwcoef_minor:
    GET d0,28
    GET d1,29
    fdiv d0,d0,d1
    PUT d0,34
    GET d2,4
    PARG 9,6
    ldr d3,[x9,x25,lsl #3]
    fadd d2,d2,d3
    GET d3,5
    fdiv d3,d3,d2
    fmul d0,d0,d3
    PUT d0,35
    ldr d2,.LC_minor_offset
    fsub d2,d1,d2
    ldr d3,.LC_self_spacing
    fdiv d2,d2,d3
    fcvtzs w10,d2
    mov w11,#1
    cmp w10,w11
    csel w10,w11,w10,lt
    mov w11,#18
    cmp w10,w11
    csel w10,w11,w10,gt
    PUTI w10,33
    scvtf d3,w10
    fsub d2,d2,d3
    PUT d2,36
    sub w10,w26,#1
    mov x11,#7
    mul x10,x10,x11
    add x11,x10,#0
    ldr d0,[x21,x11,lsl #3]
    add x11,x10,#1
    ldr d1,[x21,x11,lsl #3]
    fdiv d0,d0,d1
    PUT d0,37
    mov w10,w26
    mov x11,#7
    mul x10,x10,x11
    add x11,x10,#0
    ldr d0,[x21,x11,lsl #3]
    add x11,x10,#1
    ldr d1,[x21,x11,lsl #3]
    fdiv d0,d0,d1
    PUT d0,38
    ldr d2,[sp,#512]
    ldr d3,.LC_lower_switch
    fcmp d2,d3
    b.le .Llwcoef_upper_ratios
    sub w10,w26,#1
    mov x11,#7
    mul x10,x10,x11
    add x11,x10,#0
    ldr d0,[x21,x11,lsl #3]
    add x11,x10,#2
    ldr d1,[x21,x11,lsl #3]
    fdiv d0,d0,d1
    PUT d0,39
    mov w10,w26
    mov x11,#7
    mul x10,x10,x11
    add x11,x10,#0
    ldr d0,[x21,x11,lsl #3]
    add x11,x10,#2
    ldr d1,[x21,x11,lsl #3]
    fdiv d0,d0,d1
    PUT d0,40
    sub w10,w26,#1
    mov x11,#7
    mul x10,x10,x11
    add x11,x10,#0
    ldr d0,[x21,x11,lsl #3]
    add x11,x10,#3
    ldr d1,[x21,x11,lsl #3]
    fdiv d0,d0,d1
    PUT d0,41
    mov w10,w26
    mov x11,#7
    mul x10,x10,x11
    add x11,x10,#0
    ldr d0,[x21,x11,lsl #3]
    add x11,x10,#3
    ldr d1,[x21,x11,lsl #3]
    fdiv d0,d0,d1
    PUT d0,42
    sub w10,w26,#1
    mov x11,#7
    mul x10,x10,x11
    add x11,x10,#0
    ldr d0,[x21,x11,lsl #3]
    add x11,x10,#5
    ldr d1,[x21,x11,lsl #3]
    fdiv d0,d0,d1
    PUT d0,43
    mov w10,w26
    mov x11,#7
    mul x10,x10,x11
    add x11,x10,#0
    ldr d0,[x21,x11,lsl #3]
    add x11,x10,#5
    ldr d1,[x21,x11,lsl #3]
    fdiv d0,d0,d1
    PUT d0,44
    sub w10,w26,#1
    mov x11,#7
    mul x10,x10,x11
    add x11,x10,#3
    ldr d0,[x21,x11,lsl #3]
    add x11,x10,#1
    ldr d1,[x21,x11,lsl #3]
    fdiv d0,d0,d1
    PUT d0,45
    mov w10,w26
    mov x11,#7
    mul x10,x10,x11
    add x11,x10,#3
    ldr d0,[x21,x11,lsl #3]
    add x11,x10,#1
    ldr d1,[x21,x11,lsl #3]
    fdiv d0,d0,d1
    PUT d0,46
    b .Llwcoef_gases
.Llwcoef_upper_ratios:
    sub w10,w26,#1
    mov x11,#7
    mul x10,x10,x11
    add x11,x10,#2
    ldr d0,[x21,x11,lsl #3]
    add x11,x10,#1
    ldr d1,[x21,x11,lsl #3]
    fdiv d0,d0,d1
    PUT d0,47
    mov w10,w26
    mov x11,#7
    mul x10,x10,x11
    add x11,x10,#2
    ldr d0,[x21,x11,lsl #3]
    add x11,x10,#1
    ldr d1,[x21,x11,lsl #3]
    fdiv d0,d0,d1
    PUT d0,48
.Llwcoef_gases:
    ldr d5,.LC_gas_scale
    mov x10,#0
    madd x10,x10,x19,x25
    PARG 9,6
    ldr d0,[x9,x10,lsl #3]
    fmul d0,d5,d0
    PUT d0,17
    mov x10,#1
    madd x10,x10,x19,x25
    PARG 9,6
    ldr d0,[x9,x10,lsl #3]
    fmul d0,d5,d0
    fcmp d0,#0.0
    b.ne .Llwcoef_gas18_ready
    GET d1,4
    ldr d2,.LC_gas_floor
    fmul d0,d2,d1
.Llwcoef_gas18_ready:
    PUT d0,18
    mov x10,#2
    madd x10,x10,x19,x25
    PARG 9,6
    ldr d0,[x9,x10,lsl #3]
    fmul d0,d5,d0
    PUT d0,19
    mov x10,#3
    madd x10,x10,x19,x25
    PARG 9,6
    ldr d0,[x9,x10,lsl #3]
    fmul d0,d5,d0
    fcmp d0,#0.0
    b.ne .Llwcoef_gas20_ready
    GET d1,4
    ldr d2,.LC_gas_floor
    fmul d0,d2,d1
.Llwcoef_gas20_ready:
    PUT d0,20
    mov x10,#5
    madd x10,x10,x19,x25
    PARG 9,6
    ldr d0,[x9,x10,lsl #3]
    fmul d0,d5,d0
    fcmp d0,#0.0
    b.ne .Llwcoef_gas21_ready
    GET d1,4
    ldr d2,.LC_gas_floor
    fmul d0,d2,d1
.Llwcoef_gas21_ready:
    PUT d0,21
    mov x10,#6
    madd x10,x10,x19,x25
    PARG 9,6
    ldr d0,[x9,x10,lsl #3]
    fmul d0,d5,d0
    PUT d0,22
    GET d0,5
    fmul d0,d5,d0
    PUT d0,24
    GET d0,4
    ldr d1,.LC_co2_reference
    fmul d1,d1,d0
    GET d0,18
    fsub d0,d0,d1
    ldr d1,.LC_co2_scale
    fmul d0,d0,d1
    str d0,[sp,#560]
    ldr d0,.LC_co2_activation
    fneg d0,d0
    GET d1,29
    fdiv d0,d0,d1
    bl exp
    ldr d1,[sp,#560]
    fmul d0,d1,d0
    GET d1,29
    ldr d2,.LC_co2_denominator
    fmul d1,d2,d1
    fdiv d0,d0,d1
    PUT d0,23
    ldr d0,[sp,#520]
    ldr d1,[sp,#528]
    ldr d2,[sp,#536]
    ldr d3,.LC_one
    fsub d4,d3,d0
    fmul d5,d4,d1
    PUT d5,9
    fsub d5,d3,d1
    fmul d5,d4,d5
    PUT d5,7
    fmul d5,d0,d2
    PUT d5,10
    fsub d5,d3,d2
    fmul d5,d0,d5
    PUT d5,8
    GET d0,17
    GET d1,30
    fmul d1,d0,d1
    PUT d1,30
    GET d1,11
    fmul d1,d0,d1
    PUT d1,11
    add x23,x23,#1
    cmp x23,x19
    b.lt .Llwcoef_column
    add x22,x22,#1
    cmp x22,x20
    b.lt .Llwcoef_level
.Llwcoef_return:
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#640
    ret
.size md2asm_rrtm_setcoef_140gp,.-md2asm_rrtm_setcoef_140gp
.section .rodata
.p2align 3
.LC_pressure_shift: .quad 0x3fa47ae147ae147b
.LC_self_spacing: .quad 0x401ccccccccccccd
.LC_gas_scale: .quad 0x3bc79ca10c924223
.LC_gas_floor: .quad 0x3949f623d5a8a733
.LC_standard_ratio: .quad 0x3fd2b36d6ceb87b5
.LC_lower_switch: .quad 0x40123d70a3d70a3d
.LC_minor_offset: .quad 0x406699999999999a
.LC_co2_reference: .quad 0x3b112aafe85f31ce
.LC_co2_scale: .quad 0x40710a147ae147ae
.LC_co2_activation: .quad 0x409dfd999999999a
.LC_co2_denominator: .quad 0x3f4cb4c19332cd32
.LC_five: .quad 0x4014000000000000
.LC_thirtysix: .quad 0x4042000000000000
.LC_fifteen: .quad 0x402e000000000000
.LC_three: .quad 0x4008000000000000
.LC_one: .quad 0x3ff0000000000000
.LC_threehundredthirtytwo: .quad 0x4074c00000000000
.LC_oneeighteight: .quad 0x4067800000000000
.section .note.GNU-stack,"",%progbits
