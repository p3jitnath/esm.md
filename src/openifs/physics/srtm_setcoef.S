/* Shortwave pressure, temperature and gas preparation.
 * Physics formulations/openifs/physics/shortwave_atmospheric_inputs.md.
 * Contract skills/md2asm/references/openifs/physics/srtm_setcoef.md.
 * Twenty-nine addresses, complete column owners and separate FP64 stages.
 * x19 columns, x20 layers, x22 layer, x23 column, x24 ordinary cell,
 * x25 molecular cell, x27 pressure table, x28 temperature table.
 * Preserve x18 and d8 through d15. Scalar LOG reuses its accepted route. */
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
.global md2asm_srtm_setcoef
.type md2asm_srtm_setcoef,%function
md2asm_srtm_setcoef:
    mov x16,sp
    sub sp,sp,#512
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
    ldr x9,[x16,#160]
    str x9,[sp,#320]
    ldr w19,[x2]
    ldr w9,[x1]
    sub w19,w19,w9
    add w19,w19,#1
    sxtw x19,w19
    cbz x19,.Lcoef_return
    ldr w20,[x3]
    uxtw x20,w20
    adrp x9,:got:__yoesrtwn_MOD_preflog
    ldr x27,[x9,:got_lo12:__yoesrtwn_MOD_preflog]
    adrp x9,:got:__yoesrtwn_MOD_tref
    ldr x28,[x9,:got_lo12:__yoesrtwn_MOD_tref]
    mov x23,#0
.Lcoef_count_zero:
    PARG 9,28
    ldr d0,[x9,x23,lsl #3]
    fcmp d0,#0.0
    b.le .Lcoef_count_next
    PARG 9,8
    str wzr,[x9,x23,lsl #2]
.Lcoef_count_next:
    add x23,x23,#1
    cmp x23,x19
    b.lt .Lcoef_count_zero
    cbz x20,.Lcoef_return
    mov x22,#0
.Lcoef_level:
    mov x23,#0
.Lcoef_column:
    PARG 9,28
    ldr d0,[x9,x23,lsl #3]
    fcmp d0,#0.0
    b.le .Lcoef_next_column
    madd x24,x22,x19,x23
    mov x9,#35
    mul x25,x22,x9
    madd x25,x25,x19,x23
    GET d0,4
    bl log
    str d0,[sp,#352]
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
    PUTI w26,25
    sub w10,w26,#1
    ldr d1,[x27,x10,lsl #3]
    fsub d1,d1,d0
    fmul d1,d2,d1
    str d1,[sp,#360]
    sub w10,w26,#1
    ldr d2,[x28,x10,lsl #3]
    GET d1,5
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
    PUTI w10,26
    sub w10,w10,#3
    scvtf d4,w10
    fsub d3,d3,d4
    str d3,[sp,#368]
    mov w10,w26
    ldr d2,[x28,x10,lsl #3]
    GET d1,5
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
    PUTI w10,27
    sub w10,w10,#3
    scvtf d4,w10
    fsub d3,d3,d4
    str d3,[sp,#376]
    PARG 9,7
    ldr d2,[x9,x25,lsl #3]
    GET d3,6
    fdiv d2,d2,d3
    str d2,[sp,#384]
    GET d0,4
    ldr d4,.LC_standard_ratio
    fmul d0,d0,d4
    GET d1,5
    fdiv d0,d0,d1
    str d0,[sp,#392]
    ldr d4,.LC_one
    fadd d3,d4,d2
    fdiv d0,d0,d3
    PUT d0,15
    cmp w26,#13
    b.ge .Lcoef_upper
    PARG 9,8
    ldr w10,[x9,x23,lsl #2]
    add w10,w10,#1
    str w10,[x9,x23,lsl #2]
    ldr d2,.LC_thirtytwo
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
    PUTI w10,17
    scvtf d3,w10
    fsub d2,d2,d3
    PUT d2,16
    ldr d2,[sp,#384]
    fmul d2,d2,d0
    PUT d2,18
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
    PUTI w10,20
    add w10,w10,#7
    scvtf d3,w10
    fsub d2,d2,d3
    PUT d2,19
    b .Lcoef_gases
.Lcoef_upper:
    mov w10,#3
    PUTI w10,17
    ldr d2,.LC_oneeighteight
    fsub d2,d1,d2
    ldr d3,.LC_thirtysix
    fdiv d2,d2,d3
    ldr d3,.LC_one
    fsub d2,d2,d3
    PUT d2,16
    PUT xzr,18
    PUT xzr,19
    PUTI wzr,20
.Lcoef_gases:
    ldr d5,.LC_gas_scale
    mov x10,#0
    madd x10,x10,x19,x25
    PARG 9,7
    ldr d0,[x9,x10,lsl #3]
    fmul d0,d5,d0
    PUT d0,11
    mov x10,#1
    madd x10,x10,x19,x25
    PARG 9,7
    ldr d0,[x9,x10,lsl #3]
    fmul d0,d5,d0
    fcmp d0,#0.0
    b.ne .Lcoef_gas10_ready
    GET d1,6
    ldr d2,.LC_gas_floor
    fmul d0,d2,d1
.Lcoef_gas10_ready:
    PUT d0,10
    mov x10,#2
    madd x10,x10,x19,x25
    PARG 9,7
    ldr d0,[x9,x10,lsl #3]
    fmul d0,d5,d0
    PUT d0,14
    mov x10,#5
    madd x10,x10,x19,x25
    PARG 9,7
    ldr d0,[x9,x10,lsl #3]
    fmul d0,d5,d0
    fcmp d0,#0.0
    b.ne .Lcoef_gas9_ready
    GET d1,6
    ldr d2,.LC_gas_floor
    fmul d0,d2,d1
.Lcoef_gas9_ready:
    PUT d0,9
    mov x10,#6
    madd x10,x10,x19,x25
    PARG 9,7
    ldr d0,[x9,x10,lsl #3]
    fmul d0,d5,d0
    fcmp d0,#0.0
    b.ne .Lcoef_gas13_ready
    GET d1,6
    ldr d2,.LC_gas_floor
    fmul d0,d2,d1
.Lcoef_gas13_ready:
    PUT d0,13
    GET d0,6
    fmul d0,d5,d0
    GET d1,11
    fadd d0,d0,d1
    PUT d0,12
    ldr d0,[sp,#360]
    ldr d1,[sp,#368]
    ldr d2,[sp,#376]
    ldr d3,.LC_one
    fsub d4,d3,d0
    fmul d5,d4,d1
    PUT d5,23
    fsub d5,d3,d1
    fmul d5,d4,d5
    PUT d5,21
    fmul d5,d0,d2
    PUT d5,24
    fsub d5,d3,d2
    fmul d5,d0,d5
    PUT d5,22
.Lcoef_next_column:
    add x23,x23,#1
    cmp x23,x19
    b.lt .Lcoef_column
    add x22,x22,#1
    cmp x22,x20
    b.lt .Lcoef_level
.Lcoef_return:
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#512
    ret
.size md2asm_srtm_setcoef,.-md2asm_srtm_setcoef
.section .rodata
.p2align 3
.LC_pressure_shift: .quad 0x3fa47ae140000000
.LC_self_spacing: .quad 0x401cccccc0000000
.LC_gas_scale: .quad 0x3bc79ca100000000
.LC_gas_floor: .quad 0x3949f623e0000000
.LC_standard_ratio: .quad 0x3fd2b36d6ceb87b5
.LC_five: .quad 0x4014000000000000
.LC_thirtysix: .quad 0x4042000000000000
.LC_fifteen: .quad 0x402e000000000000
.LC_three: .quad 0x4008000000000000
.LC_one: .quad 0x3ff0000000000000
.LC_thirtytwo: .quad 0x4074c00000000000
.LC_oneeighteight: .quad 0x4067800000000000
.section .note.GNU-stack,"",%progbits
