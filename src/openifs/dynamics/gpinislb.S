// Direct from formulations/openifs/dynamics/work_buffer_initialisation.md.
// Contract skills/md2asm/references/openifs/dynamics/gpinislb.md, revision 1.
// Thirty-eight ordinary addresses. Shared PB2 views preserve their parent bytes.
// A 400-byte aligned frame saves GPR obligations and all argument addresses.
// The local assembly loop covers every copy, clear, scale and product stage.
// No external numerical helper. Independent columns use two FP64 lanes.
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL gpinislb_
#endif
.arch armv8.2-a+simd
.text
.p2align 4
.macro PARG r,index
    ldr \r,[sp,#(96+8*\index)]
.endm
.macro IMM64 r,value
    movz \r,#(\value & 65535)
    movk \r,#((\value >> 16) & 65535),lsl #16
.endm
.macro FILL out,source,levels,mode
    PARG x0,\out
    PARG x1,\source
    mov x2,xzr
    mov x3,\levels
    mov w4,\mode
    bl .Lgpinislb_fill
.endm
.macro WATER slot,out
    IMM64 x9,\slot
    ldr x9,[x23,x9]
    ldr w10,[x9,#64]
    PARG x0,\out
    mov x1,xzr
    mov x2,xzr
    mov x3,x22
    mov w4,#0
    cbz w10,.Lwater_ready\@
    ldr w10,[x24,#24]
    ldr w11,[x24,#20]
    and w10,w10,w11
    ldr w11,[x9,#168]
    ldr w12,[x9,#180]
    cmp w10,#0
    csel w11,w11,w12,ne
    sub w11,w11,#1
    mul x11,x11,x19
    mul x11,x11,x22
    PARG x1,9
    add x1,x1,x11,lsl #3
    mov w4,#1
.Lwater_ready\@:
    bl .Lgpinislb_fill
.endm
.macro WAVE slot,levels
    PARG x0,27
    ldr w9,[x26,#\slot]
    sub w9,w9,#1
    mul x9,x9,x19
    add x0,x0,x9,lsl #3
    add x9,sp,#96
    ldr x1,[x9,x27,lsl #3]
    mov x2,xzr
    mov x3,\levels
    mov w4,#1
    bl .Lgpinislb_fill
    add x27,x27,#1
.endm
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    sub sp,sp,#400
    stp x19,x20,[sp]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    stp x0,x1,[sp,#96]
    stp x2,x3,[sp,#112]
    stp x4,x5,[sp,#128]
    stp x6,x7,[sp,#144]
    add x9,sp,#400
    add x10,sp,#160
    mov x11,#30
.Lgpinislb_arguments:
    ldr x12,[x9],#8
    str x12,[x10],#8
    subs x11,x11,#1
    b.ne .Lgpinislb_arguments
    ldr w19,[x0,#5144]
    ldr w22,[x0,#5224]
    ldr w20,[x5]
    ldr w21,[x6]
    sub w21,w21,w20
    add w21,w21,#1
    sub w20,w20,#1
    mov x23,x1
    mov x25,x2
    mov x24,x3
    mov x26,x4
    ldr d16,[x7]
    dup v16.2d,v16.d[0]
    cmp w21,#0
    b.le .Lgpinislb_done
    ldr w9,[x24,#24]
    ldr w10,[x25,#2580]
    orr w9,w9,w10
    cmp w9,#0
    mov w27,#2
    csel w27,w27,wzr,eq
    FILL 19,10,x22,w27
    FILL 20,11,x22,w27
    FILL 21,12,x22,w27
    ldr w9,[x24,#8]
    cbz w9,.Lgpinislb_water
    FILL 23,13,x22,w27
    FILL 24,14,x22,w27
    ldr w9,[x24,#40]
    cbz w9,.Lgpinislb_water
    FILL 25,15,x22,w27
.Lgpinislb_water:
    WATER 799848,28
    WATER 799856,29
    WATER 799920,30
    WATER 799912,31
    mov x28,#0
.Lgpinislb_tracer:
    ldr w9,[x23]
    cmp x28,x9
    b.ge .Lgpinislb_surface
    mov x10,#368
    madd x9,x28,x10,x23
    add x9,x9,#3848
    ldr w10,[x24,#24]
    cbz w10,.Lgpinislb_euler_tracer
    ldr w10,[x9,#20]
    cbnz w10,.Lgpinislb_clear_tracer
    ldr w10,[x9,#92]
    cbz w10,.Lgpinislb_next_tracer
    ldr w10,[x24,#20]
    ldr w11,[x9,#168]
    ldr w12,[x9,#180]
    cmp w10,#0
    csel w11,w11,w12,ne
    b .Lgpinislb_scale_tracer
.Lgpinislb_euler_tracer:
    ldr w10,[x9,#92]
    cbz w10,.Lgpinislb_next_tracer
    ldr w10,[x25,#2580]
    cbnz w10,.Lgpinislb_clear_tracer
    ldr w11,[x9,#180]
.Lgpinislb_scale_tracer:
    sub w11,w11,#1
    mul x11,x11,x19
    mul x11,x11,x22
    PARG x1,9
    add x1,x1,x11,lsl #3
    mov w4,#2
    b .Lgpinislb_write_tracer
.Lgpinislb_clear_tracer:
    mov x1,xzr
    mov w4,#0
.Lgpinislb_write_tracer:
    ldr w10,[x9,#188]
    sub w10,w10,#1
    mul x10,x10,x19
    mul x10,x10,x22
    PARG x0,22
    add x0,x0,x10,lsl #3
    mov x2,xzr
    mov x3,x22
    bl .Lgpinislb_fill
.Lgpinislb_next_tracer:
    add x28,x28,#1
    b .Lgpinislb_tracer
.Lgpinislb_surface:
    mov x9,#1
    FILL 26,16,x9,w27
    PARG x9,8
    ldr w9,[x9]
    cbnz w9,.Lgpinislb_done
    PARG x0,27
    ldr w9,[x26,#40]
    sub w9,w9,#1
    mul x9,x9,x19
    add x0,x0,x9,lsl #3
    PARG x1,17
    PARG x2,18
    mov x3,x22
    mov w4,#3
    bl .Lgpinislb_fill
    ldr w9,[x24,#8]
    cbz w9,.Lgpinislb_done
    ldr w9,[x24,#48]
    cbz w9,.Lgpinislb_done
    ldr w9,[x24,#24]
    cbz w9,.Lgpinislb_done
    PARG x9,0
    ldr x9,[x9,#3264]
    ldr w10,[x9,#52]
    cbz w10,.Lgpinislb_done
    ldr w10,[x9,#96]
    cbz w10,.Lgpinislb_done
    ldr w9,[x24,#20]
    mov x10,#32
    mov x11,#35
    cmp w9,#0
    csel x27,x10,x11,ne
    WAVE 124,x22
    WAVE 128,x22
    mov x12,#1
    WAVE 132,x12
.Lgpinislb_done:
    ldp x19,x20,[sp]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#400
    ret
// x0 destination, x1/x2 sources, x3 levels, w4 zero/copy/scale/product.
// x19 pitch, x20 first zero-based column and x21 active width stay unchanged.
.Lgpinislb_fill:
    mov x5,#0
.Lgpinislb_level:
    madd x6,x5,x19,x20
    lsl x6,x6,#3
    add x7,x0,x6
    add x8,x1,x6
    add x9,x2,x6
    mov x10,x21
    cbz w4,.Lgpinislb_zero
    cmp w4,#1
    b.eq .Lgpinislb_copy
    cmp w4,#2
    b.eq .Lgpinislb_scale
    cmp x10,#2
    b.lt .Lgpinislb_product_tail
.Lgpinislb_product_pair:
    ld1 {v0.2d},[x8],#16
    ld1 {v1.2d},[x9],#16
    fmul v0.2d,v0.2d,v1.2d
    st1 {v0.2d},[x7],#16
    sub x10,x10,#2
    cmp x10,#2
    b.ge .Lgpinislb_product_pair
.Lgpinislb_product_tail:
    cbz x10,.Lgpinislb_next_level
    ldr d0,[x8]
    ldr d1,[x9]
    fmul d0,d0,d1
    str d0,[x7]
    b .Lgpinislb_next_level
.Lgpinislb_scale:
    cmp x10,#2
    b.lt .Lgpinislb_scale_tail
.Lgpinislb_scale_pair:
    ld1 {v0.2d},[x8],#16
    fmul v0.2d,v0.2d,v16.2d
    st1 {v0.2d},[x7],#16
    sub x10,x10,#2
    cmp x10,#2
    b.ge .Lgpinislb_scale_pair
.Lgpinislb_scale_tail:
    cbz x10,.Lgpinislb_next_level
    ldr d0,[x8]
    fmul d0,d0,d16
    str d0,[x7]
    b .Lgpinislb_next_level
.Lgpinislb_copy:
    cmp x10,#2
    b.lt .Lgpinislb_copy_tail
.Lgpinislb_copy_pair:
    ldr q0,[x8],#16
    str q0,[x7],#16
    sub x10,x10,#2
    cmp x10,#2
    b.ge .Lgpinislb_copy_pair
.Lgpinislb_copy_tail:
    cbz x10,.Lgpinislb_next_level
    ldr x11,[x8]
    str x11,[x7]
    b .Lgpinislb_next_level
.Lgpinislb_zero:
    cmp x10,#2
    b.lt .Lgpinislb_zero_tail
.Lgpinislb_zero_pair:
    stp xzr,xzr,[x7],#16
    sub x10,x10,#2
    cmp x10,#2
    b.ge .Lgpinislb_zero_pair
.Lgpinislb_zero_tail:
    cbz x10,.Lgpinislb_next_level
    str xzr,[x7]
.Lgpinislb_next_level:
    add x5,x5,#1
    cmp x5,x3
    b.lt .Lgpinislb_level
    ret
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .note.GNU-stack,"",%progbits
