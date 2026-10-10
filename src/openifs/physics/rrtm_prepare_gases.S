/* Prepare every gas, pressure, temperature and reflection output.
 * Inputs use full column width. Outputs use only the selected columns.
 * Each FP64 operation rounds separately. The source wet correction is retained.
 * The 384-byte frame saves registers and all 27 incoming pointer arguments. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL rrtm_prepare_gases_
#endif
.text
.p2align 2
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    sub sp,sp,#384
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    stp d8,d9,[sp,#96]
    stp d10,d11,[sp,#112]
    stp d12,d13,[sp,#128]
    stp d14,d15,[sp,#144]
    stp x0,x1,[sp,#160]
    stp x2,x3,[sp,#176]
    stp x4,x5,[sp,#192]
    stp x6,x7,[sp,#208]
    ldp x9,x10,[sp,#384]
    stp x9,x10,[sp,#224]
    ldp x9,x10,[sp,#400]
    stp x9,x10,[sp,#240]
    ldp x9,x10,[sp,#416]
    stp x9,x10,[sp,#256]
    ldp x9,x10,[sp,#432]
    stp x9,x10,[sp,#272]
    ldp x9,x10,[sp,#448]
    stp x9,x10,[sp,#288]
    ldp x9,x10,[sp,#464]
    stp x9,x10,[sp,#304]
    ldp x9,x10,[sp,#480]
    stp x9,x10,[sp,#320]
    ldp x9,x10,[sp,#496]
    stp x9,x10,[sp,#336]
    ldr x9,[sp,#512]
    ldr x10,[sp,#520]
    stp x9,x10,[sp,#352]
    ldr x9,[sp,#528]
    str x9,[sp,#368]
    ldrsw x19,[x0]
    sub x19,x19,#1          /* Zero-based first input column. */
    ldrsw x20,[x1]
    sub x20,x20,x19         /* Compact selected output width. */
    ldrsw x21,[x2]          /* Full input width. */
    ldrsw x22,[x3]          /* Layer count. */
    adrp x9,.Lgas_constants
    add x9,x9,:lo12:.Lgas_constants
    ldp d9,d10,[x9,#0]      /* Dry-air and water molar masses. */
    ldr d11,[x9,#16]        /* Original Avogadro constant. */
    fmov d12,#1.0
    ldp d13,d14,[x9,#32]    /* Pressure and gravity unit factors. */
    ldr d15,[x9,#48]        /* Fixed oxygen volume ratio. */
    ldp d16,d17,[x9,#56]    /* Carbon dioxide and ozone masses. */
    ldp d18,d19,[x9,#72]    /* Nitrous oxide and methane masses. */
    ldp d20,d21,[x9,#88]    /* PCL4 and PC11 masses. */
    ldp d22,d23,[x9,#104]   /* PC12 and PC22 masses. */
    ldr d24,[x9,#120]       /* Trace-column scale. */
    adrp x9,:got:__yomcst_MOD_rg
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rg]
    ldr d8,[x9]
    adrp x9,:got:__yomdyncore_MOD_rplrg
    ldr x9,[x9,:got_lo12:__yomdyncore_MOD_rplrg]
    ldr d0,[x9]
    fdiv d8,d8,d0
    fmul d8,d8,d13          /* Rounded gravity in centimetres per second squared. */
    cbz x20,.Lgas_return
    ldr x9,[sp,#368]
    mov x10,x20
.Lgas_reflection:
    str wzr,[x9],#4
    subs x10,x10,#1
    b.ne .Lgas_reflection
    mul x10,x20,x22
    mov x11,#35
    mul x10,x10,x11
    cbz x10,.Lgas_surface
    ldr x9,[sp,#320]
    movi v0.2d,#0
    cmp x10,#4
    b.lo .Lgas_zero_wkl_tail
.Lgas_zero_wkl_vector:
    stp q0,q0,[x9],#32
    sub x10,x10,#4
    cmp x10,#4
    b.hs .Lgas_zero_wkl_vector
.Lgas_zero_wkl_tail:
    cbz x10,.Lgas_surface
.Lgas_zero_wkl:
    str xzr,[x9],#8
    subs x10,x10,#1
    b.ne .Lgas_zero_wkl
.Lgas_surface:
    mul x25,x22,x21
    add x25,x25,x19
    lsl x25,x25,#3
    ldr x0,[sp,#192]
    ldr x1,[sp,#208]
    ldr x2,[sp,#352]
    ldr x3,[sp,#360]
    mov x27,#0
.Lgas_surface_row:
    add x28,x25,x27,lsl#3
    ldr d0,[x0,x28]
    fdiv d0,d0,d13
    str d0,[x2,x27,lsl#3]
    ldr d1,[x1,x28]
    str d1,[x3,x27,lsl#3]
    add x27,x27,#1
    cmp x27,x20
    b.ne .Lgas_surface_row
    cbz x22,.Lgas_return
    mov x23,#0
.Lgas_first_level:
    mul x24,x23,x20         /* Output layer cell base, in elements. */
    sub x25,x22,x23
    sub x25,x25,#1
    mul x25,x25,x21
    add x25,x25,x19         /* Reversed full-width input level base. */
    mov x9,#35
    mul x26,x24,x9
    lsl x26,x26,#3          /* Output gas layer base, in bytes. */
    mov x27,#0
.Lgas_first_row:
    add x28,x25,x27
    lsl x28,x28,#3          /* Complete input cell byte offset. */
    add x10,x24,x27
    lsl x10,x10,#3          /* Compact scalar-output cell byte offset. */
    ldr x9,[sp,#200]
    ldr d0,[x9,x28]
    fdiv d0,d0,d13
    ldr x9,[sp,#336]
    str d0,[x9,x10]
    ldr x9,[sp,#216]
    ldr d1,[x9,x28]
    ldr x9,[sp,#344]
    str d1,[x9,x10]
    ldr x9,[sp,#192]
    ldr d3,[x9,x28]
    fdiv d3,d3,d13
    ldr x9,[sp,#352]
    ldr d2,[x9,x10]         /* Previous rounded interface pressure. */
    add x11,x10,x20,lsl#3
    str d3,[x9,x11]         /* Current rounded interface pressure. */
    ldr x9,[sp,#208]
    ldr d1,[x9,x28]
    ldr x9,[sp,#360]
    str d1,[x9,x11]
    ldr x9,[sp,#320]
    add x9,x9,x26
    add x9,x9,x27,lsl#3     /* First gas channel at this cell. */
    lsl x4,x20,#3           /* Channel stride in bytes. */
    ldr x11,[sp,#224]
    ldr d0,[x11,x28]
    fmul d0,d0,d9
    fdiv d0,d0,d10
    str d0,[x9]             /* Rounded water volume ratio. */
    add x11,x9,x4
    ldr x12,[sp,#232]
    ldr d1,[x12,x28]
    fmul d1,d1,d9
    fdiv d1,d1,d16
    str d1,[x11]
    add x11,x11,x4
    ldr x12,[sp,#296]
    ldr d1,[x12,x28]
    fmul d1,d1,d9
    fdiv d1,d1,d17
    str d1,[x11]
    add x11,x11,x4
    ldr x12,[sp,#248]
    ldr d1,[x12,x28]
    fmul d1,d1,d9
    fdiv d1,d1,d18
    str d1,[x11]
    add x11,x11,x4,lsl#1    /* Keep channel five at its initial positive zero. */
    ldr x12,[sp,#240]
    ldr d1,[x12,x28]
    fmul d1,d1,d9
    fdiv d1,d1,d19
    str d1,[x11]
    add x11,x11,x4
    str d15,[x11]
    fsub d5,d12,d0
    fmul d5,d5,d9
    fmul d6,d0,d10
    fadd d5,d5,d6           /* Legacy mixture molar mass. */
    fsub d4,d2,d3
    fmul d4,d4,d14
    fmul d4,d4,d11          /* Ordered column numerator. */
    fmul d5,d8,d5
    fadd d6,d12,d0
    fmul d5,d5,d6
    fdiv d4,d4,d5
    ldr x9,[sp,#304]
    str d4,[x9,x10]         /* Complete dry molecular column. */
    add x27,x27,#1
    cmp x27,x20
    b.ne .Lgas_first_row
    add x23,x23,#1
    cmp x23,x22
    b.ne .Lgas_first_level
    mul x10,x20,x22
    lsl x10,x10,#2
    ldr x9,[sp,#328]
    movi v0.2d,#0
.Lgas_zero_wx:
    stp q0,q0,[x9],#32
    subs x10,x10,#4
    b.ne .Lgas_zero_wx
    mov x23,#0
.Lgas_second_level:
    mul x24,x23,x20
    sub x25,x22,x23
    sub x25,x25,#1
    mul x25,x25,x21
    add x25,x25,x19
    lsl x26,x24,#5          /* Four-channel layer base, in bytes. */
    mov x27,#0
.Lgas_second_row:
    add x28,x25,x27
    lsl x28,x28,#3
    add x10,x24,x27
    lsl x10,x10,#3
    ldr x9,[sp,#304]
    ldr d0,[x9,x10]         /* Stored rounded dry column. */
    ldr x9,[sp,#328]
    add x9,x9,x26
    add x9,x9,x27,lsl#3
    lsl x4,x20,#3
    ldr x11,[sp,#288]
    ldr d1,[x11,x28]
    fmul d1,d1,d9
    fdiv d1,d1,d20
    str d1,[x9]
    add x12,x9,x4
    ldr x11,[sp,#264]
    ldr d1,[x11,x28]
    fmul d1,d1,d9
    fdiv d1,d1,d21
    str d1,[x12]
    add x12,x12,x4
    ldr x11,[sp,#272]
    ldr d1,[x11,x28]
    fmul d1,d1,d9
    fdiv d1,d1,d22
    str d1,[x12]
    add x12,x12,x4
    ldr x11,[sp,#280]
    ldr d1,[x11,x28]
    fmul d1,d1,d9
    fdiv d1,d1,d23
    str d1,[x12]
    mov x11,x9
    mov x12,#4
.Lgas_scale_trace:
    ldr d1,[x11]
    fmul d1,d0,d1
    fmul d1,d1,d24
    str d1,[x11]
    add x11,x11,x4
    subs x12,x12,#1
    b.ne .Lgas_scale_trace
    mov x11,#35
    mul x11,x24,x11
    add x11,x11,x27
    lsl x11,x11,#3
    ldr x9,[sp,#320]
    add x9,x9,x11           /* First rounded gas volume ratio. */
    add x11,x9,x4
    mov x12,#6
    fmov d1,xzr
.Lgas_sum_volume:
    ldr d2,[x11]
    fadd d1,d1,d2
    add x11,x11,x4
    subs x12,x12,#1
    b.ne .Lgas_sum_volume
    fsub d1,d12,d1
    fmul d1,d0,d1
    ldr x11,[sp,#312]
    str d1,[x11,x10]
    mov x11,x9
    mov x12,#7
.Lgas_scale_molecules:
    ldr d1,[x11]
    fmul d1,d0,d1
    str d1,[x11]
    add x11,x11,x4
    subs x12,x12,#1
    b.ne .Lgas_scale_molecules
    add x27,x27,#1
    cmp x27,x20
    b.ne .Lgas_second_row
    add x23,x23,#1
    cmp x23,x22
    b.ne .Lgas_second_level
.Lgas_return:
    ldp d8,d9,[sp,#96]
    ldp d10,d11,[sp,#112]
    ldp d12,d13,[sp,#128]
    ldp d14,d15,[sp,#144]
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#384
    ret
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .rodata
.p2align 3
.Lgas_constants:
    .double 28.970,18.0154,6.02214e23,1.0,100.0,1000.0,0.209488
    .double 44.011,47.9982,44.013,16.043,153.8230,137.3686,120.9140,86.4690,1e-20
.section .note.GNU-stack,"",%progbits
