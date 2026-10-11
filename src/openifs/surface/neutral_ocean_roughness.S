/* Complete neutral ocean roughness from physical equation R01.
 * Physics input formulations/openifs/surface/surface_roughness.md.
 * Contract skills/md2asm/references/openifs/surface/neutral_ocean_roughness.md.
 * Scalar Arm C ABI, d0 to d5 inputs and d0 return, FP64, fixed 192-byte frame.
 * All fifteen Newton iterations and the source fallback are included.
 * No fused arithmetic, approximate instructions or driver-supplied stage. */
#ifndef LOG_SYMBOL
#define LOG_SYMBOL log
#endif
.text
.p2align 4
.global md2asm_neutral_ocean_roughness
.type md2asm_neutral_ocean_roughness,%function
md2asm_neutral_ocean_roughness:
    sub sp,sp,#192
    stp x19,x20,[sp,#0]
    stp x29,x30,[sp,#16]
    stp d8,d9,[sp,#32]
    stp d10,d11,[sp,#48]
    stp d12,d13,[sp,#64]
    stp d14,d15,[sp,#80]
    mov x29,sp
    fcmp d0,#0.0
    b.le .Lreject
    b.vs .Lreject
    fcmp d1,#0.0
    b.le .Lreject
    b.vs .Lreject
    fcmp d2,#0.0
    b.lt .Lreject
    b.vs .Lreject
    fcmp d3,#0.0
    b.le .Lreject
    b.vs .Lreject
    fcmp d4,#0.0
    b.le .Lreject
    b.vs .Lreject
    fcmp d5,#0.0
    b.le .Lreject
    b.vs .Lreject
    fmov d8,d0
    fdiv d9,d1,d3
    adrp x20,.Lconstants
    add x20,x20,:lo12:.Lconstants
    ldr d0,[x20,#32]
    fmin d10,d2,d0
    fdiv d10,d10,d3
    fmul d11,d5,d8
    fmov d12,d4
    ldp d0,d1,[x20]
    fmul d1,d1,d8
    fadd d0,d0,d1
    fsqrt d0,d0
    fmul d13,d8,d0
    ldr d15,[x20,#24]
    mov w19,#1
.Literation:
    fmax d14,d13,d15
    fmul d0,d13,d13
    fmul d0,d10,d0
    str d0,[sp,#104]
    fdiv d1,d12,d13
    str d1,[sp,#112]
    fadd d2,d0,d1
    str d2,[sp,#120]
    fadd d0,d9,d2
    fdiv d0,d9,d0
    str d0,[sp,#128]
    fdiv d0,d9,d2
    fmov d1,#1.0
    fadd d0,d1,d0
    bl LOG_SYMBOL
    fmov d1,#1.0
    fdiv d0,d1,d0
    str d0,[sp,#136]
    fmul d1,d11,d0
    fsub d1,d13,d1
    str d1,[sp,#144]
    fmul d1,d0,d0
    fmul d1,d11,d1
    ldr d2,[sp,#128]
    fmul d1,d1,d2
    ldr d2,[sp,#104]
    fmov d3,#2.0
    fmul d2,d3,d2
    ldr d3,[sp,#112]
    fsub d2,d2,d3
    fmul d1,d1,d2
    ldr d2,[sp,#120]
    fmul d2,d13,d2
    fdiv d1,d1,d2
    fmov d2,#1.0
    fsub d1,d2,d1
    fcmp d1,#0.0
    b.eq .Lconvergence
    ldr d0,[sp,#144]
    fdiv d0,d0,d1
    fsub d13,d13,d0
.Lconvergence:
    fsub d0,d13,d14
    fabs d0,d0
    ldr d1,[x20,#16]
    fmul d2,d13,d1
    fcmp d0,d2
    b.vs .Lnext_iteration
    b.gt .Lnext_iteration
    ldr d0,[sp,#144]
    fabs d0,d0
    fcmp d0,d1
    b.vs .Lnext_iteration
    b.le .Lconverged
.Lnext_iteration:
    add w19,w19,#1
    cmp w19,#15
    b.le .Literation
    ldr d0,[x20,#40]
    b .Lreturn
.Lconverged:
    fmax d13,d13,d15
    fdiv d0,d12,d13
    fmul d1,d13,d13
    fmul d1,d10,d1
    fadd d0,d0,d1
.Lreturn:
    ldp d14,d15,[sp,#80]
    ldp d12,d13,[sp,#64]
    ldp d10,d11,[sp,#48]
    ldp d8,d9,[sp,#32]
    ldp x29,x30,[sp,#16]
    ldp x19,x20,[sp,#0]
    add sp,sp,#192
    ret
.Lreject:
    brk #0
.size md2asm_neutral_ocean_roughness,.-md2asm_neutral_ocean_roughness
.section .rodata
.p2align 3
.Lconstants:
    .quad 0x3f4a36e2eb1c432d
    .quad 0x3f14f8b588e368f1
    .quad 0x3ee4f8b588e368f1
    .quad 0x3eb0c6f7a0b5ed8d
    .quad 0x3fb999999999999a
    .quad 0x3f847ae147ae147b
.section .note.GNU-stack,"",%progbits
