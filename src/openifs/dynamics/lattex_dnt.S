// Direct from formulations/openifs/dynamics/two_level_transport_terms.md.
// Contract skills/md2asm/references/openifs/dynamics/lattex_dnt.md, revision 1.
// All 27 ordinary addresses are retained in a 320-byte aligned frame.
// Complete independent points use two FP64 lanes, with a scalar remainder.
// Original products and sums round separately, with no numerical helper.
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL lattex_dnt_
#endif
.arch armv8.2-a+simd
.text
.p2align 4
.macro LOAD W,D,A,P=0
    ldr x9,[x28,#(8*\A)]
.if \P
.if \W==2
    ldr q\D,[x9,x26]
.else
    ldr d\D,[x9,x26]
.endif
.else
.if \W==2
    ldr q\D,[x9,x25]
.else
    ldr d\D,[x9,x25]
.endif
.endif
.endm
.macro STORE W,D,A,P=0
    ldr x9,[x28,#(8*\A)]
.if \P
.if \W==2
    str q\D,[x9,x26]
.else
    str d\D,[x9,x26]
.endif
.else
.if \W==2
    str q\D,[x9,x25]
.else
    str d\D,[x9,x25]
.endif
.endif
.endm
.macro FP W,OP,D,A,B
.if \W==2
    \OP v\D\().2d,v\A\().2d,v\B\().2d
.else
    \OP d\D,d\A,d\B
.endif
.endm
.macro INCREMENT W,A,D,P=0
    LOAD \W,16,\A,\P
    FP \W,fadd,16,16,\D
    STORE \W,16,\A,\P
.endm
.macro POINT W
    LOAD \W,0,13
    LOAD \W,1,15
    FP \W,fmul,2,22,1
    FP \W,fadd,2,0,2
    tbnz w27,#0,.Lcorrector\@
    cmp w29,#2
    b.lt .Lpredictor_save\@
    FP \W,fmul,4,21,0
    tbnz w27,#5,.Learly\@
    LOAD \W,3,16
    FP \W,fsub,5,2,3
    tbnz w27,#4,.Lstable\@
// Centred outgoing and final-point terms retain left-to-right additions.
    FP \W,fmul,6,24,21
    FP \W,fmul,5,6,5
    FP \W,fmul,17,25,2
    FP \W,fmul,7,24,3
    FP \W,fsub,17,17,7
    FP \W,fmul,17,20,17
    cmp w29,#2
    b.ne .Lcentred_large\@
    LOAD \W,18,11
    tbz w27,#7,.Lcentred_unsplit\@
    INCREMENT \W,19,18,1
    LOAD \W,16,20,1
    FP \W,fadd,16,16,4
    FP \W,fadd,16,16,5
    STORE \W,16,20,1
    b .Lforcing\@
.Lcentred_unsplit\@:
    LOAD \W,16,19,1
    FP \W,fadd,16,16,18
    FP \W,fadd,16,16,4
    FP \W,fadd,16,16,5
    STORE \W,16,19,1
    b .Lforcing\@
.Lcentred_large\@:
    LOAD \W,16,18,1
    FP \W,fadd,16,16,4
    FP \W,fadd,16,16,5
    STORE \W,16,18,1
    LOAD \W,18,11
    INCREMENT \W,19,18,1
    b .Lforcing\@
// Stable mixing preserves old + w*extrapolated + (1-w)*base.
.Lstable\@:
    LOAD \W,6,14
    cmp w29,#2
    b.ne .Lstable_large\@
    LOAD \W,18,11
    mov w10,#19
    tbz w27,#7,.Lstable_add_state\@
    INCREMENT \W,19,18,1
    mov w10,#20
    b .Lstable_mix\@
.Lstable_add_state\@:
    FP \W,fadd,4,18,4
.Lstable_mix\@:
    FP \W,fadd,7,4,5
    FP \W,fmul,5,6,7
    FP \W,fsub,7,26,6
    FP \W,fmul,7,7,4
    ldr x9,[x28,x10,lsl #3]
.if \W==2
    ldr q16,[x9,x26]
.else
    ldr d16,[x9,x26]
.endif
    FP \W,fadd,16,16,5
    FP \W,fadd,16,16,7
.if \W==2
    str q16,[x9,x26]
.else
    str d16,[x9,x26]
.endif
    b .Lordinary_forcing\@
.Lstable_large\@:
    FP \W,fmul,5,6,5
    LOAD \W,16,18,1
    FP \W,fadd,16,16,4
    tbnz w27,#2,.Lstable_cheap\@
    FP \W,fadd,16,16,5
    STORE \W,16,18,1
    b .Lstable_previous\@
.Lstable_cheap\@:
    STORE \W,16,18,1
    STORE \W,5,25,1
.Lstable_previous\@:
    LOAD \W,18,11
    INCREMENT \W,19,18,1
    b .Lordinary_forcing\@
.Learly\@:
    cmp w29,#2
    b.ne .Learly_large\@
    LOAD \W,18,11
    tbz w27,#7,.Learly_unsplit\@
    INCREMENT \W,19,18,1
    INCREMENT \W,20,4,1
    b .Lordinary_forcing\@
.Learly_unsplit\@:
    LOAD \W,16,19,1
    FP \W,fadd,16,16,18
    FP \W,fadd,16,16,4
    STORE \W,16,19,1
    b .Lordinary_forcing\@
.Learly_large\@:
    INCREMENT \W,18,4,1
    LOAD \W,18,11
    INCREMENT \W,19,18,1
.Lordinary_forcing\@:
    FP \W,fmul,17,20,2
.Lforcing\@:
    INCREMENT \W,17,17
.Lpredictor_save\@:
    tbz w27,#1,.Lsave_residual\@
    STORE \W,0,21
.Lsave_residual\@:
    tbnz w27,#3,.Llinear\@
    STORE \W,2,16
    b .Llinear\@
// The corrector uses the saved earlier nonlinear model.
.Lcorrector\@:
    cmp w29,#2
    b.lt .Llinear\@
    tbnz w27,#2,.Lcorrector_forcing\@
    LOAD \W,18,12
    LOAD \W,3,21
    FP \W,fmul,4,21,3
    cmp w29,#2
    b.ne .Lcorrector_large\@
    tbz w27,#7,.Lcorrector_unsplit\@
    INCREMENT \W,19,18,1
    INCREMENT \W,20,4,1
    b .Lcorrector_forcing\@
.Lcorrector_unsplit\@:
    LOAD \W,16,19,1
    FP \W,fadd,16,16,18
    FP \W,fadd,16,16,4
    STORE \W,16,19,1
    b .Lcorrector_forcing\@
.Lcorrector_large\@:
    INCREMENT \W,18,4,1
    INCREMENT \W,19,18,1
.Lcorrector_forcing\@:
    FP \W,fmul,17,20,2
    INCREMENT \W,17,17
// Apply the linear correction before its diagnostic update.
.Llinear\@:
    FP \W,fmul,1,23,1
    LOAD \W,16,17
    FP \W,fsub,16,16,1
    STORE \W,16,17
    STORE \W,1,15
    tbz w27,#6,.Lpoint_done\@
    tbnz w27,#0,.Ldiagnostic_corrector\@
    cmp w29,#3
    b.lt .Ldiagnostic_save\@
    tbnz w27,#5,.Ldiagnostic_simple\@
    LOAD \W,3,23
    FP \W,fmul,2,22,1
    FP \W,fsub,5,2,3
    tbnz w27,#4,.Ldiagnostic_stable\@
    FP \W,fmul,6,24,21
    FP \W,fmul,5,6,5
    INCREMENT \W,24,5,1
    FP \W,fmul,6,25,22
    FP \W,fmul,6,6,1
    FP \W,fmul,7,24,3
    FP \W,fsub,6,6,7
    FP \W,fmul,6,20,6
    INCREMENT \W,22,6
    b .Ldiagnostic_save\@
.Ldiagnostic_stable\@:
    INCREMENT \W,24,5,1
.Ldiagnostic_simple\@:
    FP \W,fmul,6,20,22
    FP \W,fmul,6,6,1
    INCREMENT \W,22,6
.Ldiagnostic_save\@:
    tbnz w27,#3,.Lpoint_done\@
    FP \W,fmul,2,22,1
    STORE \W,2,23
    b .Lpoint_done\@
.Ldiagnostic_corrector\@:
    cmp w29,#3
    b.lt .Lpoint_done\@
    FP \W,fmul,6,20,22
    FP \W,fmul,6,6,1
    INCREMENT \W,22,6
.Lpoint_done\@:
.endm
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    sub sp,sp,#320
    stp x19,x20,[sp]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    add x28,sp,#96
    stp x0,x1,[x28]
    stp x2,x3,[x28,#16]
    stp x4,x5,[x28,#32]
    stp x6,x7,[x28,#48]
    add x9,sp,#320
    add x10,x28,#64
    mov x11,#19
.Larguments:
    ldr x12,[x9],#8
    str x12,[x10],#8
    subs x11,x11,#1
    b.ne .Larguments
    ldr w19,[x0,#5144]
    ldr w20,[x0,#5224]
    ldr w21,[x5]
    sub w21,w21,#1
    ldr w22,[x6]
    cmp w20,#0
    b.le .Ldone
    cmp w22,w21
    b.le .Ldone
    ldr w11,[x0,#5244]
    mov w12,#1
    sub w11,w12,w11
    mul x11,x11,x19
    lsl x11,x11,#3
    str x11,[sp,#312]
    mov w27,wzr
    ldr w9,[x4,#336]
    lsl w27,w9,#1
    ldr w10,[x3,#2580]
    cmp w10,#0
    cset w10,gt
    and w10,w9,w10
    orr w27,w27,w10
    ldr w9,[x4,#340]
    orr w27,w27,w9,lsl #2
    ldr x9,[x28,#208]
    cbz x9,.Ldefault_nesc
    ldr w9,[x9]
    b .Lnesc_ready
.Ldefault_nesc:
    ldr w9,[x4,#280]
.Lnesc_ready:
    orr w27,w27,w9,lsl #3
    ldr w10,[x7]
    orr w27,w27,w10,lsl #4
    adrp x10,:got:__yomct3_MOD_nstep
    ldr x10,[x10,:got_lo12:__yomct3_MOD_nstep]
    ldr w10,[x10]
    ldr w11,[x2,#24]
    cmp w10,w11
    cset w10,le
    orr w9,w9,w10
    orr w27,w27,w9,lsl #5
    ldr w9,[x1,#108]
    orr w27,w27,w9,lsl #6
    ldr w9,[x3,#4204]
    cmp w9,#0
    cset w9,ne
    orr w27,w27,w9,lsl #7
    ldr x9,[x28,#64]
    ldr w29,[x9]
    ldr x9,[x28,#72]
    ldr d20,[x9]
    dup v20.2d,v20.d[0]
    ldr x9,[x28,#80]
    ldr d21,[x9]
    dup v21.2d,v21.d[0]
    ldr d0,[x3,#4328]
    fmov d26,#1.0
    fadd d22,d26,d0
    fcmp d0,#0.0
    fcsel d23,d22,d20,gt
    dup v22.2d,v22.d[0]
    dup v23.2d,v23.d[0]
    dup v26.2d,v26.d[0]
    fmov d24,#0.5
    fmov d25,#1.5
    dup v24.2d,v24.d[0]
    dup v25.2d,v25.d[0]
    mov x23,xzr
.Llevel:
    mov x24,x21
.Lpair:
    add x9,x24,#2
    cmp x9,x22
    b.gt .Ltail
    madd x25,x23,x19,x24
    lsl x25,x25,#3
    ldr x26,[sp,#312]
    add x26,x26,x25
    POINT 2
    add x24,x24,#2
    b .Lpair
.Ltail:
    cmp x24,x22
    b.ge .Lnext_level
    madd x25,x23,x19,x24
    lsl x25,x25,#3
    ldr x26,[sp,#312]
    add x26,x26,x25
    POINT 1
.Lnext_level:
    add x23,x23,#1
    cmp x23,x20
    b.lt .Llevel
.Ldone:
    ldp x19,x20,[sp]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#320
    ret
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .note.GNU-stack,"",%progbits
