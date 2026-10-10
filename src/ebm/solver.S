// Direct AArch64 NEON/SVE realisation of formulations/ebm/budyko_sellers.md revision 1.1.
// Public ABI: w0=N; x1=q, x2=stage, x3=out, x4=work, x5=K/W/I, x6=par.
// eb_run also takes w7=steps. Buffers are disjoint, contiguous, and 8-byte aligned.
// Each state has N+2 doubles; coefficients contain three such planes.
// Two FP64 SVE lanes use sixteen-cell groups with paired NEON memory operations and bounded SVE tails.
// x19-x29 and the low 64 bits of v8-v15 are preserved; the stack stays 16-byte aligned.
.text
.p2align 4
.type .Leb_halo,%function
.Leb_halo:
    // x0=state, x1=N; integer copies implement BC01 without altering sign bits.
    ldr x2,[x0,#8]
    ldr x3,[x0,x1,lsl #3]
    str x2,[x0]
    add x1,x1,#1
    str x3,[x0,x1,lsl #3]
    ret
.size .Leb_halo,.-.Leb_halo

.macro UPDATE name, final, scaled
.p2align 4
.type \name,%function
\name:
    // D02-D03 use complete NEON groups and bounded SVE remainders.
    // Each rounded east face becomes the next cell’s west face.
    add x6,x3,x5
    add x9,x6,x5
    mov x7,x17
    mov z31.d,#0
    cmp x7,x4
    b.hs .Leb_return\@
    cbz x7,.Leb_seeded\@
    ldr d0,[x0,x7,lsl #3]
    add x8,x7,#1
    ldr d1,[x0,x8,lsl #3]
    ldr d2,[x3,x7,lsl #3]
    fsub d1,d1,d0
    fmul d2,d2,d1
    dup z31.d,z2.d[0]
.Leb_seeded\@:
    add x8,x7,#16
    cmp x8,x4
    b.hi .Leb_tail\@
.Leb_bulk\@:
    add x8,x7,#1
    add x10,x3,x8,lsl #3
    add x11,x6,x8,lsl #3
    add x12,x9,x8,lsl #3
    add x13,x2,x8,lsl #3
    add x14,x1,x8,lsl #3
    add x8,x0,x8,lsl #3
    // Paired accesses combine existing adjacent values within the complete sixteen-cell group.
    ldp q0,q3,[x8,#0]
    ldp q1,q4,[x10,#0]
    ldp q6,q9,[x8,#32]
    ldp q7,q10,[x10,#32]
    ldp q12,q15,[x8,#64]
    ldp q13,q16,[x10,#64]
    ldp q18,q21,[x8,#96]
    ldp q19,q22,[x10,#96]
    ext v2.16b,v0.16b,v3.16b,#8
    ext v5.16b,v3.16b,v6.16b,#8
    ext v8.16b,v6.16b,v9.16b,#8
    ext v11.16b,v9.16b,v12.16b,#8
    ext v14.16b,v12.16b,v15.16b,#8
    ext v17.16b,v15.16b,v18.16b,#8
    ext v20.16b,v18.16b,v21.16b,#8
    ldur q23,[x8,#120]
    fsub z2.d,z2.d,z0.d
    fsub z5.d,z5.d,z3.d
    fsub z8.d,z8.d,z6.d
    fsub z11.d,z11.d,z9.d
    fsub z14.d,z14.d,z12.d
    fsub z17.d,z17.d,z15.d
    fsub z20.d,z20.d,z18.d
    fsub z23.d,z23.d,z21.d
    fmul z1.d,z1.d,z2.d
    fmul z4.d,z4.d,z5.d
    fmul z7.d,z7.d,z8.d
    fmul z10.d,z10.d,z11.d
    fmul z13.d,z13.d,z14.d
    fmul z16.d,z16.d,z17.d
    fmul z19.d,z19.d,z20.d
    fmul z22.d,z22.d,z23.d
    umov x17,v22.d[1]
    ext v30.16b,v19.16b,v22.16b,#8
    fsub z22.d,z22.d,z30.d
    ext v30.16b,v16.16b,v19.16b,#8
    fsub z19.d,z19.d,z30.d
    ext v30.16b,v13.16b,v16.16b,#8
    fsub z16.d,z16.d,z30.d
    ext v30.16b,v10.16b,v13.16b,#8
    fsub z13.d,z13.d,z30.d
    ext v30.16b,v7.16b,v10.16b,#8
    fsub z10.d,z10.d,z30.d
    ext v30.16b,v4.16b,v7.16b,#8
    fsub z7.d,z7.d,z30.d
    ext v30.16b,v1.16b,v4.16b,#8
    fsub z4.d,z4.d,z30.d
    ext v30.16b,v31.16b,v1.16b,#8
    fsub z1.d,z1.d,z30.d
.if \scaled
    fmul z1.d,z1.d,z25.d
    fmul z4.d,z4.d,z25.d
    fmul z7.d,z7.d,z25.d
    fmul z10.d,z10.d,z25.d
    fmul z13.d,z13.d,z25.d
    fmul z16.d,z16.d,z25.d
    fmul z19.d,z19.d,z25.d
    fmul z22.d,z22.d,z25.d
.else
    fdiv v1.2d,v1.2d,v25.2d
    fdiv v4.2d,v4.2d,v25.2d
    fdiv v7.2d,v7.2d,v25.2d
    fdiv v10.2d,v10.2d,v25.2d
    fdiv v13.2d,v13.2d,v25.2d
    fdiv v16.2d,v16.2d,v25.2d
    fdiv v19.2d,v19.2d,v25.2d
    fdiv v22.2d,v22.2d,v25.2d
.endif
    ldr q30,[x11,#0]
    ldr q31,[x12,#0]
    fcmge v2.2d,v28.2d,v0.2d
    bsl v2.16b,v31.16b,v30.16b
    fmul z30.d,z27.d,z0.d
    fadd z30.d,z26.d,z30.d
    fsub z2.d,z2.d,z30.d
    ldr q30,[x11,#16]
    ldr q31,[x12,#16]
    fcmge v5.2d,v28.2d,v3.2d
    bsl v5.16b,v31.16b,v30.16b
    fmul z30.d,z27.d,z3.d
    fadd z30.d,z26.d,z30.d
    fsub z5.d,z5.d,z30.d
    ldr q30,[x11,#32]
    ldr q31,[x12,#32]
    fcmge v8.2d,v28.2d,v6.2d
    bsl v8.16b,v31.16b,v30.16b
    fmul z30.d,z27.d,z6.d
    fadd z30.d,z26.d,z30.d
    fsub z8.d,z8.d,z30.d
    ldr q30,[x11,#48]
    ldr q31,[x12,#48]
    fcmge v11.2d,v28.2d,v9.2d
    bsl v11.16b,v31.16b,v30.16b
    fmul z30.d,z27.d,z9.d
    fadd z30.d,z26.d,z30.d
    fsub z11.d,z11.d,z30.d
    ldr q30,[x11,#64]
    ldr q31,[x12,#64]
    fcmge v14.2d,v28.2d,v12.2d
    bsl v14.16b,v31.16b,v30.16b
    fmul z30.d,z27.d,z12.d
    fadd z30.d,z26.d,z30.d
    fsub z14.d,z14.d,z30.d
    ldr q30,[x11,#80]
    ldr q31,[x12,#80]
    fcmge v17.2d,v28.2d,v15.2d
    bsl v17.16b,v31.16b,v30.16b
    fmul z30.d,z27.d,z15.d
    fadd z30.d,z26.d,z30.d
    fsub z17.d,z17.d,z30.d
    ldr q30,[x11,#96]
    ldr q31,[x12,#96]
    fcmge v20.2d,v28.2d,v18.2d
    bsl v20.16b,v31.16b,v30.16b
    fmul z30.d,z27.d,z18.d
    fadd z30.d,z26.d,z30.d
    fsub z20.d,z20.d,z30.d
    ldr q30,[x11,#112]
    ldr q31,[x12,#112]
    fcmge v23.2d,v28.2d,v21.2d
    bsl v23.16b,v31.16b,v30.16b
    fmul z30.d,z27.d,z21.d
    fadd z30.d,z26.d,z30.d
    fsub z23.d,z23.d,z30.d
    fadd z2.d,z2.d,z1.d
    fadd z5.d,z5.d,z4.d
    fadd z8.d,z8.d,z7.d
    fadd z11.d,z11.d,z10.d
    fadd z14.d,z14.d,z13.d
    fadd z17.d,z17.d,z16.d
    fadd z20.d,z20.d,z19.d
    fadd z23.d,z23.d,z22.d
.if \final
    ldp q1,q4,[x14,#0]
    fmul z1.d,z1.d,z29.d
    fmul z4.d,z4.d,z29.d
    ldp q7,q10,[x14,#32]
    fmul z7.d,z7.d,z29.d
    fmul z10.d,z10.d,z29.d
    ldp q13,q16,[x14,#64]
    fmul z13.d,z13.d,z29.d
    fmul z16.d,z16.d,z29.d
    ldp q19,q22,[x14,#96]
    fmul z19.d,z19.d,z29.d
    fmul z22.d,z22.d,z29.d
.endif
    fmul z2.d,z24.d,z2.d
    fmul z5.d,z24.d,z5.d
    fmul z8.d,z24.d,z8.d
    fmul z11.d,z24.d,z11.d
    fmul z14.d,z24.d,z14.d
    fmul z17.d,z24.d,z17.d
    fmul z20.d,z24.d,z20.d
    fmul z23.d,z24.d,z23.d
    fadd z2.d,z0.d,z2.d
    fadd z5.d,z3.d,z5.d
    fadd z8.d,z6.d,z8.d
    fadd z11.d,z9.d,z11.d
    fadd z14.d,z12.d,z14.d
    fadd z17.d,z15.d,z17.d
    fadd z20.d,z18.d,z20.d
    fadd z23.d,z21.d,z23.d
.if \final
    fmul z2.d,z2.d,z29.d
    fmul z5.d,z5.d,z29.d
    fmul z8.d,z8.d,z29.d
    fmul z11.d,z11.d,z29.d
    fmul z14.d,z14.d,z29.d
    fmul z17.d,z17.d,z29.d
    fmul z20.d,z20.d,z29.d
    fmul z23.d,z23.d,z29.d
    fadd z2.d,z1.d,z2.d
    fadd z5.d,z4.d,z5.d
    fadd z8.d,z7.d,z8.d
    fadd z11.d,z10.d,z11.d
    fadd z14.d,z13.d,z14.d
    fadd z17.d,z16.d,z17.d
    fadd z20.d,z19.d,z20.d
    fadd z23.d,z22.d,z23.d
.endif
    stp q2,q5,[x13,#0]
    stp q8,q11,[x13,#32]
    stp q14,q17,[x13,#64]
    stp q20,q23,[x13,#96]
    dup z31.d,x17
    add x7,x7,#16
    add x8,x7,#16
    cmp x8,x4
    b.ls .Leb_bulk\@
    cmp x7,x4
    b.hs .Leb_return\@
.Leb_tail\@:
    whilelo p0.d,x7,x4
    add x8,x7,#1
    add x10,x7,#2
    ld1d {z0.d},p0/z,[x0,x8,lsl #3]
    ld1d {z2.d},p0/z,[x0,x10,lsl #3]
    ld1d {z1.d},p0/z,[x3,x8,lsl #3]
    fsub z2.d,z2.d,z0.d
    fmul z1.d,z1.d,z2.d
    umov x11,v1.d[1]
    mov z30.d,z31.d
    ext z30.b,z30.b,z1.b,#8
    fsub z1.d,z1.d,z30.d
.if \scaled
    fmul z1.d,z1.d,z25.d
.else
    fdiv z1.d,p0/m,z1.d,z25.d
.endif
    ld1d {z2.d},p0/z,[x6,x8,lsl #3]
    ld1d {z30.d},p0/z,[x9,x8,lsl #3]
    fcmle p1.d,p0/z,z0.d,z28.d
    sel z2.d,p1,z30.d,z2.d
    fmul z30.d,z27.d,z0.d
    fadd z30.d,z26.d,z30.d
    fsub z2.d,z2.d,z30.d
    fadd z2.d,z2.d,z1.d
    fmul z2.d,z24.d,z2.d
    fadd z2.d,z0.d,z2.d
.if \final
    ld1d {z0.d},p0/z,[x1,x8,lsl #3]
    fmul z0.d,z0.d,z29.d
    fmul z2.d,z2.d,z29.d
    fadd z2.d,z0.d,z2.d
.endif
    st1d {z2.d},p0,[x2,x8,lsl #3]
    dup z31.d,x11
    add x7,x7,#2
    cmp x7,x4
    b.lo .Leb_tail\@
.Leb_return\@:
    ret
.size \name,.-\name
.endm
UPDATE .Leb_first,0,0
UPDATE .Leb_final,1,0
UPDATE .Leb_first_scaled,0,1
UPDATE .Leb_final_scaled,1,1
.macro SAVE
    stp x29,x30,[sp,#-160]!
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    stp d8,d9,[sp,#96]
    stp d10,d11,[sp,#112]
    stp d12,d13,[sp,#128]
    stp d14,d15,[sp,#144]
.endm
.macro RESTORE
    ldp d8,d9,[sp,#96]
    ldp d10,d11,[sp,#112]
    ldp d12,d13,[sp,#128]
    ldp d14,d15,[sp,#144]
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp],#160
    ret
.endm
.macro PARAMETERS
    uxtw x19,w0
    mov x20,x1
    mov x21,x2
    mov x22,x3
    mov x23,x4
    mov x24,x5
    mov x25,x6
    add x26,x19,#2
    lsl x26,x26,#3
    mov x27,#0
    ldr x0,[x25,#16]
    tst x0,#0x000fffffffffffff
    b.ne .Leb_scale_ready\@
    ubfx x1,x0,#52,#11
    cbz x1,.Leb_scale_ready\@
    cmp x1,#2047
    b.eq .Leb_scale_ready\@
    mov x27,#1
.Leb_scale_ready\@:
    ptrue p7.d
    ld1rd {z24.d},p7/z,[x25,#8]
    ld1rd {z23.d},p7/z,[x25]
    fdiv z24.d,p7/m,z24.d,z23.d
    ld1rd {z25.d},p7/z,[x25,#16]
    ld1rd {z26.d},p7/z,[x25,#24]
    ld1rd {z27.d},p7/z,[x25,#32]
    ld1rd {z28.d},p7/z,[x25,#40]
    fmov z29.d,#0.5
    cbz x27,.Leb_parameters\@
    fmov z30.d,#1.0
    fdivr z25.d,p7/m,z25.d,z30.d
.Leb_parameters\@:
.endm
.macro CALL_UPDATE name,current,output
    mov x0,\current
    mov x1,x20
    mov x2,\output
    mov x3,x24
    mov x4,x19
    mov x17,#0
    mov x5,x26
    bl \name
.endm
.macro COMPLETE_SMALL
    mov x0,x20
    mov x1,x19
    bl .Leb_halo
    cbz x27,.Leb_first_general\@
    CALL_UPDATE .Leb_first_scaled,x20,x21
    b .Leb_first_done\@
.Leb_first_general\@:
    CALL_UPDATE .Leb_first,x20,x21
.Leb_first_done\@:
    mov x0,x21
    mov x1,x19
    bl .Leb_halo
    cbz x27,.Leb_final_general\@
    CALL_UPDATE .Leb_final_scaled,x21,x22
    b .Leb_final_done\@
.Leb_final_general\@:
    CALL_UPDATE .Leb_final,x21,x22
.Leb_final_done\@:
    mov x0,x22
    mov x1,x19
    bl .Leb_halo
.endm
.macro CALL_RANGE name,current,output
    mov x0,\current
    mov x1,x20
    mov x2,\output
    mov x3,x24
    mov x5,x26
    bl \name
.endm
.macro COMPLETE
    cmp x19,#8192
    b.hs .Leb_tiled\@
    COMPLETE_SMALL
    b .Leb_complete\@
.Leb_tiled\@:
    mov x0,x20
    mov x1,x19
    bl .Leb_halo
    mov x23,#0
.Leb_tile\@:
    add x25,x23,#512
    cmp x25,x19
    csel x25,x25,x19,lo
    mov x17,x23
    cbz x23,.Leb_tile_first\@
    add x17,x17,#1
.Leb_tile_first\@:
    add x4,x25,#1
    cmp x4,x19
    csel x4,x4,x19,lo
    cbz x27,.Leb_tile_general\@
    CALL_RANGE .Leb_first_scaled,x20,x21
    b .Leb_tile_first_done\@
.Leb_tile_general\@:
    CALL_RANGE .Leb_first,x20,x21
.Leb_tile_first_done\@:
    cbnz x23,.Leb_left_ready\@
    ldr x8,[x21,#8]
    str x8,[x21]
.Leb_left_ready\@:
    add x8,x25,#1
    cmp x8,x19
    b.lo .Leb_right_ready\@
    ldr x8,[x21,x19,lsl #3]
    add x9,x19,#1
    str x8,[x21,x9,lsl #3]
.Leb_right_ready\@:
    mov x17,x23
    mov x4,x25
    cbz x27,.Leb_tile_final_general\@
    CALL_RANGE .Leb_final_scaled,x21,x22
    b .Leb_tile_final_done\@
.Leb_tile_final_general\@:
    CALL_RANGE .Leb_final,x21,x22
.Leb_tile_final_done\@:
    mov x23,x25
    cmp x23,x19
    b.lo .Leb_tile\@
    mov x0,x22
    mov x1,x19
    bl .Leb_halo
.Leb_complete\@:
.endm

.p2align 4
.global eb_step
.type eb_step,%function
eb_step:
    SAVE
    PARAMETERS
    COMPLETE
    RESTORE
.size eb_step,.-eb_step

.p2align 4
.global eb_run
.type eb_run,%function
eb_run:
    cbz w7,.Leb_empty
    SAVE
    uxtw x28,w7
    PARAMETERS
.Leb_steps:
    COMPLETE
    mov x9,x20
    mov x20,x22
    mov x22,x9
    subs x28,x28,#1
    b.ne .Leb_steps
    RESTORE
.Leb_empty:
    ret
.size eb_run,.-eb_run
.section .note.GNU-stack,"",%progbits
