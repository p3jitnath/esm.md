// Direct AArch64 SVE realisation of budyko_sellers.md revision 1.1.
// Public ABI: w0=N; x1=q, x2=stage, x3=out, x4=work, x5=K/W/I, x6=par.
// eb_run also takes w7=steps. Buffers are disjoint, contiguous, and 8-byte aligned.
// Each state has N+2 doubles; coefficients contain three such planes.
// The target has two FP64 SVE lanes; separate predicates protect all eight vector tails.
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
    // x0=q, x1=base, x2=out, x3=coeff, x4=N, x5=plane bytes.
    // z24=beta, z25=delta or exact inverse, z26=A, z27=B, z28=Tf, z29=1/2.
    // Independent vectors cover latency; exact east fluxes supply adjacent west fluxes.
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
.Leb_cells\@:
    add x8,x7,#1
    add x17,x7,#0
    whilelo p0.d,x17,x4
    add x17,x17,#2
    ld1d {z0.d},p0/z,[x0,x8,lsl #3]
    ld1d {z2.d},p0/z,[x0,x17,lsl #3]
    ld1d {z1.d},p0/z,[x3,x8,lsl #3]
    add x10,x7,#3
    add x17,x7,#2
    whilelo p1.d,x17,x4
    add x17,x17,#2
    ld1d {z3.d},p1/z,[x0,x10,lsl #3]
    ld1d {z5.d},p1/z,[x0,x17,lsl #3]
    ld1d {z4.d},p1/z,[x3,x10,lsl #3]
    add x11,x7,#5
    add x17,x7,#4
    whilelo p2.d,x17,x4
    add x17,x17,#2
    ld1d {z6.d},p2/z,[x0,x11,lsl #3]
    ld1d {z8.d},p2/z,[x0,x17,lsl #3]
    ld1d {z7.d},p2/z,[x3,x11,lsl #3]
    add x12,x7,#7
    add x17,x7,#6
    whilelo p3.d,x17,x4
    add x17,x17,#2
    ld1d {z9.d},p3/z,[x0,x12,lsl #3]
    ld1d {z11.d},p3/z,[x0,x17,lsl #3]
    ld1d {z10.d},p3/z,[x3,x12,lsl #3]
    add x13,x7,#9
    add x17,x7,#8
    whilelo p4.d,x17,x4
    add x17,x17,#2
    ld1d {z12.d},p4/z,[x0,x13,lsl #3]
    ld1d {z14.d},p4/z,[x0,x17,lsl #3]
    ld1d {z13.d},p4/z,[x3,x13,lsl #3]
    add x14,x7,#11
    add x17,x7,#10
    whilelo p5.d,x17,x4
    add x17,x17,#2
    ld1d {z15.d},p5/z,[x0,x14,lsl #3]
    ld1d {z17.d},p5/z,[x0,x17,lsl #3]
    ld1d {z16.d},p5/z,[x3,x14,lsl #3]
    add x15,x7,#13
    add x17,x7,#12
    whilelo p6.d,x17,x4
    add x17,x17,#2
    ld1d {z18.d},p6/z,[x0,x15,lsl #3]
    ld1d {z20.d},p6/z,[x0,x17,lsl #3]
    ld1d {z19.d},p6/z,[x3,x15,lsl #3]
    add x16,x7,#15
    add x17,x7,#14
    whilelo p7.d,x17,x4
    add x17,x17,#2
    ld1d {z21.d},p7/z,[x0,x16,lsl #3]
    ld1d {z23.d},p7/z,[x0,x17,lsl #3]
    ld1d {z22.d},p7/z,[x3,x16,lsl #3]
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
    ld1d {z2.d},p0/z,[x6,x8,lsl #3]
    ld1d {z30.d},p0/z,[x9,x8,lsl #3]
    fcmle p8.d,p0/z,z0.d,z28.d
    sel z2.d,p8,z30.d,z2.d
    fmul z30.d,z27.d,z0.d
    fadd z30.d,z26.d,z30.d
    fsub z2.d,z2.d,z30.d
    ld1d {z5.d},p1/z,[x6,x10,lsl #3]
    ld1d {z30.d},p1/z,[x9,x10,lsl #3]
    fcmle p8.d,p1/z,z3.d,z28.d
    sel z5.d,p8,z30.d,z5.d
    fmul z30.d,z27.d,z3.d
    fadd z30.d,z26.d,z30.d
    fsub z5.d,z5.d,z30.d
    ld1d {z8.d},p2/z,[x6,x11,lsl #3]
    ld1d {z30.d},p2/z,[x9,x11,lsl #3]
    fcmle p8.d,p2/z,z6.d,z28.d
    sel z8.d,p8,z30.d,z8.d
    fmul z30.d,z27.d,z6.d
    fadd z30.d,z26.d,z30.d
    fsub z8.d,z8.d,z30.d
    ld1d {z11.d},p3/z,[x6,x12,lsl #3]
    ld1d {z30.d},p3/z,[x9,x12,lsl #3]
    fcmle p8.d,p3/z,z9.d,z28.d
    sel z11.d,p8,z30.d,z11.d
    fmul z30.d,z27.d,z9.d
    fadd z30.d,z26.d,z30.d
    fsub z11.d,z11.d,z30.d
    ld1d {z14.d},p4/z,[x6,x13,lsl #3]
    ld1d {z30.d},p4/z,[x9,x13,lsl #3]
    fcmle p8.d,p4/z,z12.d,z28.d
    sel z14.d,p8,z30.d,z14.d
    fmul z30.d,z27.d,z12.d
    fadd z30.d,z26.d,z30.d
    fsub z14.d,z14.d,z30.d
    ld1d {z17.d},p5/z,[x6,x14,lsl #3]
    ld1d {z30.d},p5/z,[x9,x14,lsl #3]
    fcmle p8.d,p5/z,z15.d,z28.d
    sel z17.d,p8,z30.d,z17.d
    fmul z30.d,z27.d,z15.d
    fadd z30.d,z26.d,z30.d
    fsub z17.d,z17.d,z30.d
    ld1d {z20.d},p6/z,[x6,x15,lsl #3]
    ld1d {z30.d},p6/z,[x9,x15,lsl #3]
    fcmle p8.d,p6/z,z18.d,z28.d
    sel z20.d,p8,z30.d,z20.d
    fmul z30.d,z27.d,z18.d
    fadd z30.d,z26.d,z30.d
    fsub z20.d,z20.d,z30.d
    ld1d {z23.d},p7/z,[x6,x16,lsl #3]
    ld1d {z30.d},p7/z,[x9,x16,lsl #3]
    fcmle p8.d,p7/z,z21.d,z28.d
    sel z23.d,p8,z30.d,z23.d
    fmul z30.d,z27.d,z21.d
    fadd z30.d,z26.d,z30.d
    fsub z23.d,z23.d,z30.d
    umov x17,v22.d[1]
    mov z30.d,z19.d
    ext z30.b,z30.b,z22.b,#8
    fsub z22.d,z22.d,z30.d
    mov z30.d,z16.d
    ext z30.b,z30.b,z19.b,#8
    fsub z19.d,z19.d,z30.d
    mov z30.d,z13.d
    ext z30.b,z30.b,z16.b,#8
    fsub z16.d,z16.d,z30.d
    mov z30.d,z10.d
    ext z30.b,z30.b,z13.b,#8
    fsub z13.d,z13.d,z30.d
    mov z30.d,z7.d
    ext z30.b,z30.b,z10.b,#8
    fsub z10.d,z10.d,z30.d
    mov z30.d,z4.d
    ext z30.b,z30.b,z7.b,#8
    fsub z7.d,z7.d,z30.d
    mov z30.d,z1.d
    ext z30.b,z30.b,z4.b,#8
    fsub z4.d,z4.d,z30.d
    mov z30.d,z31.d
    ext z30.b,z30.b,z1.b,#8
    fsub z1.d,z1.d,z30.d
    dup z31.d,x17
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
    fdiv z1.d,p0/m,z1.d,z25.d
    fdiv z4.d,p1/m,z4.d,z25.d
    fdiv z7.d,p2/m,z7.d,z25.d
    fdiv z10.d,p3/m,z10.d,z25.d
    fdiv z13.d,p4/m,z13.d,z25.d
    fdiv z16.d,p5/m,z16.d,z25.d
    fdiv z19.d,p6/m,z19.d,z25.d
    fdiv z22.d,p7/m,z22.d,z25.d
.endif
    fadd z2.d,z2.d,z1.d
    fadd z5.d,z5.d,z4.d
    fadd z8.d,z8.d,z7.d
    fadd z11.d,z11.d,z10.d
    fadd z14.d,z14.d,z13.d
    fadd z17.d,z17.d,z16.d
    fadd z20.d,z20.d,z19.d
    fadd z23.d,z23.d,z22.d
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
    ld1d {z0.d},p0/z,[x1,x8,lsl #3]
    ld1d {z3.d},p1/z,[x1,x10,lsl #3]
    ld1d {z6.d},p2/z,[x1,x11,lsl #3]
    ld1d {z9.d},p3/z,[x1,x12,lsl #3]
    ld1d {z12.d},p4/z,[x1,x13,lsl #3]
    ld1d {z15.d},p5/z,[x1,x14,lsl #3]
    ld1d {z18.d},p6/z,[x1,x15,lsl #3]
    ld1d {z21.d},p7/z,[x1,x16,lsl #3]
    fmul z0.d,z0.d,z29.d
    fmul z2.d,z2.d,z29.d
    fmul z3.d,z3.d,z29.d
    fmul z5.d,z5.d,z29.d
    fmul z6.d,z6.d,z29.d
    fmul z8.d,z8.d,z29.d
    fmul z9.d,z9.d,z29.d
    fmul z11.d,z11.d,z29.d
    fmul z12.d,z12.d,z29.d
    fmul z14.d,z14.d,z29.d
    fmul z15.d,z15.d,z29.d
    fmul z17.d,z17.d,z29.d
    fmul z18.d,z18.d,z29.d
    fmul z20.d,z20.d,z29.d
    fmul z21.d,z21.d,z29.d
    fmul z23.d,z23.d,z29.d
    fadd z2.d,z0.d,z2.d
    fadd z5.d,z3.d,z5.d
    fadd z8.d,z6.d,z8.d
    fadd z11.d,z9.d,z11.d
    fadd z14.d,z12.d,z14.d
    fadd z17.d,z15.d,z17.d
    fadd z20.d,z18.d,z20.d
    fadd z23.d,z21.d,z23.d
.endif
    st1d {z2.d},p0,[x2,x8,lsl #3]
    st1d {z5.d},p1,[x2,x10,lsl #3]
    st1d {z8.d},p2,[x2,x11,lsl #3]
    st1d {z11.d},p3,[x2,x12,lsl #3]
    st1d {z14.d},p4,[x2,x13,lsl #3]
    st1d {z17.d},p5,[x2,x14,lsl #3]
    st1d {z20.d},p6,[x2,x15,lsl #3]
    st1d {z23.d},p7,[x2,x16,lsl #3]
    add x7,x7,#16
    cmp x7,x4
    b.lo .Leb_cells\@
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
