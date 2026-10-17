// Physics formulations/openifs/physics/two_stream_shortwave_transport.md.
// Contract skills/md2asm/references/openifs/physics/calc_reflectance_transmittance_sw.md.
/* Two adjacent independent shortwave layer cells with the frozen equations.
 * Public twelve-pointer ABI and bounds match calc_reflectance_transmittance_sw.
 * The 256-byte frame has 32 outgoing bytes, saves x19..x30 and d8..d15,
 * and keeps the original angle and two final output pointers. x18 is untouched.
 * Integer guards precede FP work. A matching prefix may add only eventual
 * scalar flags. Four EXP arguments pass admission before calls or outputs.
 * Private pair EXP preserves full q8..q15/q24..q31. Every refusal and odd
 * cell calls the accepted own scalar reflection body below. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __radiation_two_stream_MOD_calc_reflectance_transmittance_sw
#endif
.arch armv8.2-a
.text
.p2align 4

/* Both lanes must be nonnegative except signed zero, with magnitude <=x12. */
.macro NONNEGATIVE_PAIR reg
 fmov x9,d\reg
 umov x10,v\reg\().d[1]
 and x11,x9,#0x7fffffffffffffff
 cmp x11,x12
 b.hi .Lpair_scalar
 cbz x11,.Lfirst_nonnegative\@
 tbnz x9,#63,.Lpair_scalar
.Lfirst_nonnegative\@:
 and x11,x10,#0x7fffffffffffffff
 cmp x11,x12
 b.hi .Lpair_scalar
 cbz x11,.Lsecond_nonnegative\@
 tbnz x10,#63,.Lpair_scalar
.Lsecond_nonnegative\@:
.endm
.macro BOUNDED_PAIR reg
 fmov x9,d\reg
 umov x10,v\reg\().d[1]
 and x9,x9,#0x7fffffffffffffff
 and x10,x10,#0x7fffffffffffffff
 cmp x9,x12
 b.hi .Lpair_scalar
 cmp x10,x12
 b.hi .Lpair_scalar
.endm
/* Both lanes are exact signed zero or finite2^-54<=abs(x)<512. */
.macro EXP_PAIR_GUARD reg
 fmov x9,d\reg
 umov x10,v\reg\().d[1]
 and x9,x9,#0x7fffffffffffffff
 and x10,x10,#0x7fffffffffffffff
 cbz x9,.Lfirst_exp_ready\@
 cmp x9,x11
 b.lo .Lpair_scalar
 cmp x9,x12
 b.hs .Lpair_scalar
.Lfirst_exp_ready\@:
 cbz x10,.Lsecond_exp_ready\@
 cmp x10,x11
 b.lo .Lpair_scalar
 cmp x10,x12
 b.hs .Lpair_scalar
.Lsecond_exp_ready\@:
.endm

.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
 ldr w9,[x0]
 cmp w9,#0
 b.le .Lpair_empty
 sub sp,sp,#256
 stp x19,x20,[sp,#32]
 stp x21,x22,[sp,#48]
 stp x23,x24,[sp,#64]
 stp x25,x26,[sp,#80]
 stp x27,x28,[sp,#96]
 stp x29,x30,[sp,#112]
 stp d8,d9,[sp,#128]
 stp d10,d11,[sp,#144]
 stp d12,d13,[sp,#160]
 stp d14,d15,[sp,#176]
 str w9,[sp,#192]
 str x1,[sp,#208]
 mov x19,#0
 lsl x20,x9,#3
 mov x21,x2
 mov x22,x3
 mov x23,x4
 mov x24,x5
 mov x25,x6
 mov x26,x7
 ldp x27,x28,[sp,#256]
 ldp x9,x10,[sp,#272]
 stp x9,x10,[sp,#224]
 ldr x9,[x1]
 and x10,x9,#0x7fffffffffffffff
 mov x11,#0x3ff0000000000000
 cmp x10,x11
 b.hi .Lpair_scalar
 cbz x10,.Lpair_loop
 tbnz x9,#63,.Lpair_scalar
.Lpair_loop:
 sub x9,x20,x19
 cmp x9,#16
 b.lo .Lpair_last_scalar
 mov w9,#2
 str w9,[sp,#192]
 ldr q13,[x21,x19]
 ldr q30,[x22,x19]
 ldr q9,[x23,x19]
 ldr q10,[x24,x19]
 ldr q11,[x25,x19]
 movz x12,#0x412e,lsl #48
 movk x12,#0x8480,lsl #32
 NONNEGATIVE_PAIR 13
 mov x12,#0x3ff0000000000000
 NONNEGATIVE_PAIR 30
 mov x12,#0x4020000000000000
 BOUNDED_PAIR 9
 BOUNDED_PAIR 10
 BOUNDED_PAIR 11
 ldr x9,[sp,#208]
 ldr d8,[x9]
 dup v8.2d,v8.d[0]
 fmov d31,#1.0
 dup v31.2d,v31.d[0]
 fsub v24.2d,v31.2d,v11.2d
 fsub v0.2d,v9.2d,v10.2d
 fadd v1.2d,v9.2d,v10.2d
 fmul v0.2d,v0.2d,v1.2d
 ldr d1,.Lpair_floor
 dup v1.2d,v1.d[0]
 fmaxnm v0.2d,v0.2d,v1.2d
 fsqrt v12.2d,v0.2d
 fmul v0.2d,v9.2d,v24.2d
 fmul v1.2d,v10.2d,v11.2d
 fadd v14.2d,v0.2d,v1.2d
 fmul v0.2d,v9.2d,v11.2d
 fmul v1.2d,v10.2d,v24.2d
 fadd v15.2d,v0.2d,v1.2d
 fmul v0.2d,v12.2d,v8.2d
 fsub v0.2d,v31.2d,v0.2d
 fabs v0.2d,v0.2d
 ldr d1,.Lpair_threshold
 dup v1.2d,v1.d[0]
 fcmgt v2.2d,v1.2d,v0.2d
 and v3.16b,v8.16b,v2.16b
 ldr d1,.Lpair_adjustment
 dup v1.2d,v1.d[0]
 fmul v3.2d,v3.2d,v1.2d
 bsl v2.16b,v3.16b,v8.16b
 mov v8.16b,v2.16b
 fdiv v0.2d,v13.2d,v8.2d
 fmul v25.2d,v12.2d,v8.2d
 fmul v26.2d,v12.2d,v11.2d
 fmul v27.2d,v12.2d,v24.2d
 movi v1.2d,#0
 fmaxnm v0.2d,v0.2d,v1.2d
 fneg v28.2d,v0.2d
 fmul v29.2d,v12.2d,v13.2d
 fneg v29.2d,v29.2d
 mov x11,#0x3c90000000000000
 mov x12,#0x4080000000000000
 EXP_PAIR_GUARD 28
 EXP_PAIR_GUARD 29
 mov v0.16b,v28.16b
 bl md2asm_try_exp_pair_counted
 mov v28.16b,v0.16b
 mov v0.16b,v29.16b
 bl md2asm_try_exp_pair_counted
 mov v29.16b,v0.16b
 fmul v16.2d,v29.2d,v29.2d
 fmov d17,#2.0
 dup v17.2d,v17.d[0]
 fmul v17.2d,v17.2d,v12.2d
 fmul v17.2d,v17.2d,v29.2d
 fadd v3.2d,v12.2d,v9.2d
 fsub v4.2d,v12.2d,v9.2d
 fmul v4.2d,v4.2d,v16.2d
 fadd v3.2d,v3.2d,v4.2d
 fdiv v3.2d,v31.2d,v3.2d
 fmul v7.2d,v25.2d,v25.2d
 fsub v7.2d,v31.2d,v7.2d
 fmul v0.2d,v8.2d,v30.2d
 fsub v1.2d,v31.2d,v25.2d
 fadd v2.2d,v31.2d,v25.2d
 fsub v6.2d,v31.2d,v16.2d
 fmul v6.2d,v10.2d,v6.2d
 fmul v4.2d,v6.2d,v3.2d
 str q4,[x26,x19]
 fmul v4.2d,v17.2d,v3.2d
 str q4,[x27,x19]
 fmul v0.2d,v0.2d,v3.2d
 fdiv v0.2d,v0.2d,v7.2d
 fadd v4.2d,v15.2d,v26.2d
 fmul v4.2d,v1.2d,v4.2d
 fsub v3.2d,v15.2d,v26.2d
 fmul v3.2d,v2.2d,v3.2d
 fmul v3.2d,v3.2d,v16.2d
 fsub v4.2d,v4.2d,v3.2d
 fmul v3.2d,v15.2d,v8.2d
 fsub v3.2d,v11.2d,v3.2d
 fmul v3.2d,v17.2d,v3.2d
 fmul v3.2d,v3.2d,v28.2d
 fsub v4.2d,v4.2d,v3.2d
 fmul v4.2d,v0.2d,v4.2d
 movi v3.2d,#0
 fminnm v4.2d,v4.2d,v31.2d
 fmaxnm v4.2d,v4.2d,v3.2d
 str q4,[x28,x19]
 fmul v3.2d,v14.2d,v8.2d
 fadd v3.2d,v24.2d,v3.2d
 fmul v3.2d,v17.2d,v3.2d
 fadd v7.2d,v14.2d,v27.2d
 fmul v7.2d,v2.2d,v7.2d
 fsub v6.2d,v14.2d,v27.2d
 fmul v6.2d,v1.2d,v6.2d
 fmul v6.2d,v6.2d,v16.2d
 fsub v7.2d,v7.2d,v6.2d
 fmul v7.2d,v28.2d,v7.2d
 fsub v3.2d,v3.2d,v7.2d
 fmul v3.2d,v0.2d,v3.2d
 fsub v5.2d,v31.2d,v4.2d
 fminnm v3.2d,v3.2d,v5.2d
 movi v1.2d,#0
 fmaxnm v3.2d,v3.2d,v1.2d
 ldr x9,[sp,#224]
 str q3,[x9,x19]
 ldr x9,[sp,#232]
 str q28,[x9,x19]
 add x19,x19,#16
 cmp x19,x20
 b.lo .Lpair_loop
 b .Lpair_return
.Lpair_last_scalar:
 mov w9,#1
 str w9,[sp,#192]
.Lpair_scalar:
 add x0,sp,#192
 ldr x1,[sp,#208]
 add x2,x21,x19
 add x3,x22,x19
 add x4,x23,x19
 add x5,x24,x19
 add x6,x25,x19
 add x7,x26,x19
 add x9,x27,x19
 add x10,x28,x19
 stp x9,x10,[sp,#0]
 ldp x9,x10,[sp,#224]
 add x9,x9,x19
 add x10,x10,x19
 stp x9,x10,[sp,#16]
 bl md2asm_mcica_reflect_scalar_fallback
 ldr w9,[sp,#192]
 add x19,x19,x9,lsl #3
 cmp x19,x20
 b.lo .Lpair_loop
.Lpair_return:
 ldp d8,d9,[sp,#128]
 ldp d10,d11,[sp,#144]
 ldp d12,d13,[sp,#160]
 ldp d14,d15,[sp,#176]
 ldp x19,x20,[sp,#32]
 ldp x21,x22,[sp,#48]
 ldp x23,x24,[sp,#64]
 ldp x25,x26,[sp,#80]
 ldp x27,x28,[sp,#96]
 ldp x29,x30,[sp,#112]
 add sp,sp,#256
.Lpair_empty:
 ret
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.p2align 3
.Lpair_floor: .double 1.0e-12
.Lpair_threshold: .double 2.220446049250313080847263336181640625e-13
.Lpair_adjustment: .double 0.9999999999997779553950749686919152736663818359375
.section .note.GNU-stack,"",%progbits

/* Accepted own scalar body for refused pairs and the odd final cell. */
#undef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL md2asm_mcica_reflect_scalar_fallback
.hidden md2asm_mcica_reflect_scalar_fallback
/* Accepted scalar fallback for the unchanged layer equations P01 and P02.
 * Physics is formulations/openifs/physics/two_stream_shortwave_transport.md.
 * Contract is skills/md2asm/references/openifs/physics/calc_reflectance_transmittance_sw.md.
 * x0 count, x1 mu, x2..x6 input arrays, x7 diffuse reflection.
 * Four remaining output pointers are at entry sp+0, +8, +16 and +24.
 * Arrays are disjoint aligned FP64, with count cells. Separate rounding.
 * The shared EXP route has an explicitly recorded accuracy and FP contract. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __radiation_two_stream_MOD_calc_reflectance_transmittance_sw
#endif
.text
.p2align 2
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    ldr w9,[x0]
    cmp w9,#0
    b.le .Lsw_rt_empty
    sub sp,sp,#256
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
    mov x19,#0
    lsl x20,x9,#3
    mov x21,x2
    mov x22,x3
    mov x23,x4
    mov x24,x5
    mov x25,x6
    mov x26,x7
    ldr x27,[sp,#256]
    ldr x28,[sp,#264]
    ldr x9,[sp,#272]
    str x9,[sp,#160]
    ldr x9,[sp,#280]
    str x9,[sp,#168]
    ldr d0,[x1]
    str d0,[sp,#176]
.Lsw_rt_point:
    ldr d8,[sp,#176]
    ldr d9,[x23,x19]
    ldr d10,[x24,x19]
    ldr d11,[x25,x19]
    ldr d13,[x21,x19]
    fmov d0,#1.0
    fsub d1,d0,d11
    str d1,[sp,#184]
    // Start the independent square root before both coupling sums.
    fsub d2,d9,d10
    fadd d3,d9,d10
    fmul d2,d2,d3
    ldr d3,.Lsw_rt_floor
    fmaxnm d2,d2,d3
    fsqrt d12,d2
    fmul d2,d9,d1
    fmul d3,d10,d11
    fadd d14,d2,d3
    fmul d2,d9,d11
    fmul d3,d10,d1
    fadd d15,d2,d3
    fmul d2,d12,d8
    fsub d2,d0,d2
    fabs d2,d2
    ldr d3,.Lsw_rt_threshold
    fcmp d2,d3
    b.ge .Lsw_rt_angle_ready
    ldr d3,.Lsw_rt_adjustment
    fmul d8,d8,d3
.Lsw_rt_angle_ready:
    // Independent products cover part of the division wait.
    fdiv d0,d13,d8
    fmul d2,d12,d8
    str d2,[sp,#192]
    fmul d2,d12,d11
    str d2,[sp,#200]
    ldr d1,[sp,#184]
    fmul d2,d12,d1
    str d2,[sp,#208]
    fmov d1,xzr
    fmaxnm d0,d0,d1
    fneg d0,d0
    bl exp
    str d0,[sp,#216]
    ldr x9,[sp,#168]
    str d0,[x9,x19]
    fmul d0,d12,d13
    fneg d0,d0
    bl exp
    // EXP is finished for this cell, so caller registers keep rounded values.
    fmul d16,d0,d0
    fmov d17,#2.0
    fmul d17,d17,d12
    fmul d17,d17,d0
    ldp d18,d19,[sp,#192]
    ldr d20,[sp,#208]
    ldr d21,[sp,#184]
    ldr d22,[sp,#216]
    fadd d3,d12,d9
    fsub d4,d12,d9
    fmul d4,d4,d16
    fadd d3,d3,d4
    fmov d5,#1.0
    fdiv d3,d5,d3
    // Prepare independent factors while the reciprocal is in progress.
    fmul d7,d18,d18
    fsub d7,d5,d7
    ldr d0,[x22,x19]
    fmul d0,d8,d0
    fsub d1,d5,d18
    fadd d2,d5,d18
    fsub d6,d5,d16
    fmul d6,d10,d6
    fmul d4,d6,d3
    str d4,[x26,x19]
    fmul d4,d17,d3
    str d4,[x27,x19]
    fmul d0,d0,d3
    fdiv d0,d0,d7
    fadd d4,d15,d19
    fmul d4,d1,d4
    fsub d3,d15,d19
    fmul d3,d2,d3
    fmul d3,d3,d16
    fsub d4,d4,d3
    fmul d3,d15,d8
    fsub d3,d11,d3
    fmul d3,d17,d3
    fmul d3,d3,d22
    fsub d4,d4,d3
    fmul d4,d0,d4
    fmov d3,xzr
    fminnm d4,d4,d5
    fmaxnm d4,d4,d3
    str d4,[x28,x19]
    fmul d3,d14,d8
    fadd d3,d21,d3
    fmul d3,d17,d3
    fadd d7,d14,d20
    fmul d7,d2,d7
    fsub d6,d14,d20
    fmul d6,d1,d6
    fmul d6,d6,d16
    fsub d7,d7,d6
    fmul d7,d22,d7
    fsub d3,d3,d7
    fmul d3,d0,d3
    fsub d5,d5,d4
    fminnm d3,d3,d5
    fmov d1,xzr
    fmaxnm d3,d3,d1
    ldr x9,[sp,#160]
    str d3,[x9,x19]
    add x19,x19,#8
    cmp x19,x20
    b.ne .Lsw_rt_point
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
    add sp,sp,#256
.Lsw_rt_empty:
    ret
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.p2align 3
.Lsw_rt_floor:
    .double 1.0e-12
.Lsw_rt_threshold:
    .double 2.220446049250313080847263336181640625e-13
.Lsw_rt_adjustment:
    .double 0.9999999999997779553950749686919152736663818359375
.section .note.GNU-stack,"",%progbits
