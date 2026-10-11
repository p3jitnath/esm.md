// Physics input formulations/openifs/physics/ozone_climatology.md.
// Complete contract skills/md2asm/references/openifs/physics/ozone_climatology.md.
// Direct ordered FP64 update with the complete qualified fixed sine grid.
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL updecozc_
#endif
.text
.p2align 4
.global md2asm_ozone_climatology
.global ORIGINAL_SYMBOL
.type md2asm_ozone_climatology,%function
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
md2asm_ozone_climatology:
    sub sp,sp,#96
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    mov x19,x0
    mov x20,x1
    mov x21,x2
    adrp x8,:got:__yomcst_MOD_rpi
    ldr x8,[x8,:got_lo12:__yomcst_MOD_rpi]
    ldr x8,[x8]
    adrp x9,.Lpi
    ldr x9,[x9,:lo12:.Lpi]
    cmp x8,x9
    b.ne .Linvalid
    ldr w22,[x3]
    ldr w23,[x4]
    cmp w23,#0
    b.lt .Linvalid
    mov w8,#100
    sdiv w9,w22,w8
    msub w10,w9,w8,w22
    sdiv w11,w9,w8
    msub w12,w11,w8,w9
    cmp w11,#1
    b.lt .Linvalid
    mov w13,#9999
    cmp w11,w13
    b.gt .Linvalid
    cmp w12,#1
    b.lt .Linvalid
    cmp w12,#12
    b.gt .Linvalid
    cmp w10,#1
    b.lt .Linvalid
    adrp x0,.Lmonth_days
    add x0,x0,:lo12:.Lmonth_days
    sub w1,w12,#1
    ldr w13,[x0,x1,lsl #2]
    cmp w12,#2
    b.ne .Lday_guard
    tst w11,#3
    b.ne .Lday_guard
    sdiv w0,w11,w8
    msub w0,w0,w8,w11
    cbnz w0,.Lleap
    mov w1,#400
    sdiv w0,w11,w1
    msub w0,w0,w1,w11
    cbnz w0,.Lday_guard
.Lleap:
    add w13,w13,#1
.Lday_guard:
    cmp w10,w13
    b.gt .Linvalid
    sub w10,w10,#1
    scvtf d2,w23
    adrp x0,.Ltime_constants
    add x0,x0,:lo12:.Ltime_constants
    ldr d3,[x0]
    cmp w12,#1
    b.eq .Ljanuary_time
    cmp w12,#2
    b.eq .Lfebruary_time
    sub w1,w12,#2
    adrp x0,.Lmdays
    add x0,x0,:lo12:.Lmdays
    ldr d0,[x0,x1,lsl #3]
    scvtf d1,w10
    fadd d0,d0,d1
    fmul d0,d0,d3
    fadd d0,d0,d2
    b .Ltime_ready
.Ljanuary_time:
    scvtf d0,w10
    fmul d0,d0,d3
    fadd d0,d0,d2
    b .Ltime_ready
.Lfebruary_time:
    cmp w10,#28
    b.ne .Lfebruary_day_ready
    sub w10,w10,#1
.Lfebruary_day_ready:
    scvtf d0,w10
    ldr d1,[x0,#8]
    fmul d0,d0,d1
    ldr d1,[x0,#16]
    fadd d0,d1,d0
    fadd d0,d0,d2
.Ltime_ready:
    // Keep the source remainder of the rounded elapsed calendar time.
    mov x8,#1672
    movk x8,#8,lsl #16
    ucvtf d1,x8
    fcmp d0,d1
    b.lt .Lyear_reduced
    fcvtzu x9,d0
    ucvtf d2,x9
    fsub d3,d0,d2
    udiv x10,x9,x8
    msub x9,x10,x8,x9
    ucvtf d0,x9
    fadd d0,d0,d3
.Lyear_reduced:
    adrp x0,.Lmidpoints
    add x0,x0,:lo12:.Lmidpoints
    ldr d1,[x0]
    fcmp d0,d1
    b.le .Ljanuary_weight
    ldr d1,[x0,#88]
    fcmp d0,d1
    b.gt .Ldecember_weight
    mov x1,#0
.Lfind_interval:
    ldr d1,[x0,x1,lsl #3]
    add x2,x1,#1
    ldr d2,[x0,x2,lsl #3]
    fcmp d0,d1
    b.le .Lfind_next
    fcmp d0,d2
    b.gt .Lfind_next
    fsub d3,d0,d2
    fsub d4,d1,d2
    fdiv d17,d3,d4
    add x1,x1,#1
    add x2,x2,#1
    b .Lweight_ready
.Lfind_next:
    add x1,x1,#1
    cmp x1,#11
    b.lt .Lfind_interval
    b .Linvalid
.Ljanuary_weight:
    fsub d3,d1,d0
    b .Lyear_crossing_weight
.Ldecember_weight:
    adrp x8,.Ltime_constants
    add x8,x8,:lo12:.Ltime_constants
    ldr d1,[x8,#24]
    fsub d3,d1,d0
.Lyear_crossing_weight:
    adrp x8,.Ltime_constants
    add x8,x8,:lo12:.Ltime_constants
    ldr d4,[x8,#16]
    fdiv d17,d3,d4
    mov x1,#12
    mov x2,#1
.Lweight_ready:
    ldp x25,x8,[x21]
    add x25,x25,x8,lsl #3
    ldr x9,[x21,#88]
    mul x1,x1,x9
    mul x2,x2,x9
    add x27,x25,x1,lsl #3
    add x26,x25,x2,lsl #3
    ldr x24,[x21,#64]
    lsl x24,x24,#3
    add x28,x21,#1288
    ldr d16,[x20,#48]
    ldr d18,[x19,#576]
    mov x7,#1
.Linterior_level:
    mul x0,x7,x24
    add x4,x27,x0
    add x5,x26,x0
    add x4,x4,#8
    add x5,x5,#8
    add x6,x28,x7,lsl #9
    mov w8,#19
.Linterior_latitude:
    ldr d0,[x5],#8
    ldr d1,[x4],#8
    fsub d1,d1,d0
    fmul d1,d17,d1
    fadd d0,d0,d1
    fmul d0,d16,d0
    str d0,[x6],#8
    subs w8,w8,#1
    b.ne .Linterior_latitude
    add x7,x7,#1
    cmp x7,#34
    b.le .Linterior_level
    mov x0,x28
    mov x1,#34
    add x1,x28,x1,lsl #9
    mov x2,#35
    add x2,x28,x2,lsl #9
    mov w8,#19
.Lboundary_latitude:
    str xzr,[x0],#8
    ldr d0,[x1],#8
    str d0,[x2],#8
    subs w8,w8,#1
    b.ne .Lboundary_latitude
    fcmp d18,#0.0
    b.eq .Llatitude_sines
    ldr w8,[x19,#140]
    cmp w8,#0
    b.eq .Lupper_perturbation
    cmp w8,#1
    b.ne .Llatitude_sines
    mov x7,#27
    b .Lperturbation_ready
.Lupper_perturbation:
    mov x7,#23
.Lperturbation_ready:
    adrp x0,.Lperturbation_latitude
    add x0,x0,:lo12:.Lperturbation_latitude
    adrp x1,.Lperturbation_height
    add x1,x1,:lo12:.Lperturbation_height
    add x2,x28,#40
    mov x3,#0
    fmov d22,#1.0
.Lperturbation_latitude_loop:
    ldr d19,[x0,x3,lsl #3]
    fmul d20,d18,d19
    add x4,x2,x7,lsl #9
    mov x5,#0
.Lperturbation_height_loop:
    ldr d21,[x1,x5,lsl #3]
    fmul d21,d20,d21
    fadd d21,d22,d21
    ldr d0,[x4]
    fmul d0,d0,d21
    str d0,[x4]
    add x4,x4,#512
    add x5,x5,#1
    cmp x5,#7
    b.lt .Lperturbation_height_loop
    add x2,x2,#8
    add x3,x3,#1
    cmp x3,#9
    b.lt .Lperturbation_latitude_loop
.Llatitude_sines:
    adrp x0,.Llatitude_table
    add x0,x0,:lo12:.Llatitude_table
    add x1,x21,#776
    mov w2,#19
.Llatitude_sine:
    ldr d0,[x0],#8
    str d0,[x1],#8
    subs w2,w2,#1
    b.ne .Llatitude_sine
    ldp x29,x30,[sp,#80]
    ldp x27,x28,[sp,#64]
    ldp x25,x26,[sp,#48]
    ldp x23,x24,[sp,#32]
    ldp x21,x22,[sp,#16]
    ldp x19,x20,[sp,#0]
    add sp,sp,#96
    ret
.Linvalid:
    brk #0x4a0
.size md2asm_ozone_climatology,.-md2asm_ozone_climatology
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .rodata
.p2align 3
.Lpi:
    .quad 0x400921fb54442d18
.Lmonth_days:
    .word 31,28,31,30,31,30,31,31,30,31,30,31
.Ltime_constants:
    .quad 0x4096800000000000
    .quad 0x4096b36dab9f559b
    .quad 0x40e5cc0000000000
    .quad 0x4120bb7000000000
.Lmdays:
    .quad 0x403f000000000000
    .quad 0x404da00000000000
    .quad 0x4056900000000000
    .quad 0x405e100000000000
    .quad 0x4062e80000000000
    .quad 0x4066a80000000000
    .quad 0x406a880000000000
    .quad 0x406e680000000000
    .quad 0x4071140000000000
    .quad 0x4073040000000000
    .quad 0x4074e40000000000
    .quad 0x4076d40000000000
.Lmidpoints:
    .quad 0x40d5cc0000000000
    .quad 0x40efba8000000000
    .quad 0x40fa478000000000
    .quad 0x4102804000000000
    .quad 0x4107dcc000000000
    .quad 0x410d394000000000
    .quad 0x41114ae000000000
    .quad 0x4114046000000000
    .quad 0x4116b2a000000000
    .quad 0x411960e000000000
    .quad 0x411c0f2000000000
    .quad 0x411ebd6000000000
.Llatitude_table:
    .quad 0xbff0000000000000
    .quad 0xbfef838b8c811c17
    .quad 0xbfee11f642522d1b
    .quad 0xbfebb67ae8584caa
    .quad 0xbfe8836fa2cf5039
    .quad 0xbfe491b7523c161c
    .quad 0xbfdfffffffffffff
    .quad 0xbfd5e3a8748a0bf5
    .quad 0xbfc63a1a7e0b7389
    .quad 0x0000000000000000
    .quad 0x3fc63a1a7e0b7389
    .quad 0x3fd5e3a8748a0bf5
    .quad 0x3fdfffffffffffff
    .quad 0x3fe491b7523c161c
    .quad 0x3fe8836fa2cf5039
    .quad 0x3febb67ae8584caa
    .quad 0x3fee11f642522d1b
    .quad 0x3fef838b8c811c17
    .quad 0x3ff0000000000000
.Lperturbation_latitude:
    .quad 0x0000000000000000
    .quad 0x3fd87de2a6aea963
    .quad 0x3fe6a09e667f3bcc
    .quad 0x3fed906bcf328d46
    .quad 0x3ff0000000000000
    .quad 0x3fed906bcf328d46
    .quad 0x3fe6a09e667f3bcd
    .quad 0x3fd87de2a6aea965
    .quad 0x3ca1a62633145c07
.Lperturbation_height:
    .quad 0x0000000000000000
    .quad 0x3fdfffffffffffff
    .quad 0x3febb67ae8584caa
    .quad 0x3ff0000000000000
    .quad 0x3febb67ae8584cab
    .quad 0x3fdfffffffffffff
    .quad 0x3ca1a62633145c07
.section .note.GNU-stack,"",%progbits
