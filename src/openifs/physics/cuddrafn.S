// Physics input formulations/openifs/physics/convective_downdraft_descent.md.
// Contract skills/md2asm/references/openifs/physics/cuddrafn.md.
#ifndef CUDDRAFN_SYMBOL
#define CUDDRAFN_SYMBOL cuddrafn_
#endif
#ifndef CUDDRAFN_ADJUSTMENT
#define CUDDRAFN_ADJUSTMENT md2asm_cuadjtq
#endif
.text
.p2align 4
.global CUDDRAFN_SYMBOL
.type CUDDRAFN_SYMBOL,%function
CUDDRAFN_SYMBOL:
    ldr w9,[x0,#4]
    cbnz w9,.Ldomain
    sub sp,sp,#640
    stp x29,x30,[sp]
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    str x0,[x29,#112]
    str x1,[x29,#120]
    str x2,[x29,#128]
    str x3,[x29,#136]
    str x4,[x29,#144]
    str x5,[x29,#152]
    str x6,[x29,#160]
    str x7,[x29,#168]
    ldr x9,[x29,#640]
    str x9,[x29,#176]
    ldr x9,[x29,#648]
    str x9,[x29,#184]
    ldr x9,[x29,#656]
    str x9,[x29,#192]
    ldr x9,[x29,#664]
    str x9,[x29,#200]
    ldr x9,[x29,#672]
    str x9,[x29,#208]
    ldr x9,[x29,#680]
    str x9,[x29,#216]
    ldr x9,[x29,#688]
    str x9,[x29,#224]
    ldr x9,[x29,#696]
    str x9,[x29,#232]
    ldr x9,[x29,#704]
    str x9,[x29,#240]
    ldr x9,[x29,#712]
    str x9,[x29,#248]
    ldr x9,[x29,#720]
    str x9,[x29,#256]
    ldr x9,[x29,#728]
    str x9,[x29,#264]
    ldr x9,[x29,#736]
    str x9,[x29,#272]
    ldr x9,[x29,#744]
    str x9,[x29,#280]
    ldr x9,[x29,#752]
    str x9,[x29,#288]
    ldr x9,[x29,#760]
    str x9,[x29,#296]
    ldr w19,[x2]
    ldr w20,[x3]
    ldr w21,[x4]
    ldr w22,[x5]
    cmp w21,#1
    b.lt .Ldomain
    cmp w22,#1
    b.lt .Ldomain
    cmp w19,#1
    b.lt .Ldomain
    cmp w20,w21
    b.gt .Ldomain
    cmp w19,w20
    b.gt .Lreturn
    uxtw x21,w21
    uxtw x22,w22
    ldr d0,[x1,#40]
    str d0,[x29,#352]
    ldr d0,[x1,#120]
    str d0,[x29,#360]
    ldr w9,[x1,#316]
    cmp w9,#1
    b.lt .Ldomain
    cmp w9,w22
    b.gt .Ldomain
    str w9,[x29,#384]
    mov w9,#2
    str w9,[x29,#388]
    mov x9,#52
    mul x9,x21,x9
    add x9,x9,#47
    and x9,x9,#-16
    mov x10,#1048576
    cmp x9,x10
    b.hi .Ldomain
    sub sp,sp,x9
    add x27,sp,#32
    add x9,x27,x21,lsl #3
    str x9,[x29,#400]
    add x9,x9,x21,lsl #3
    str x9,[x29,#408]
    add x9,x9,x21,lsl #3
    str x9,[x29,#416]
    add x9,x9,x21,lsl #3
    str x9,[x29,#424]
    add x9,x9,x21,lsl #3
    str x9,[x29,#432]
    add x9,x9,x21,lsl #3
    str x9,[x29,#440]
    adrp x9,:got:__yomcst_MOD_rcpd
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rcpd]
    ldr d0,[x9]
    str d0,[x29,#320]
    adrp x9,:got:__yomcst_MOD_retv
    ldr x9,[x9,:got_lo12:__yomcst_MOD_retv]
    ldr d0,[x9]
    str d0,[x29,#328]
    adrp x9,:got:__yomcst_MOD_rg
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rg]
    ldr d0,[x9]
    str d0,[x29,#336]
    fmov d1,#1.0
    fdiv d0,d1,d0
    str d0,[x29,#344]
    fmov d0,#0.5
    fmov d1,#1.5
    fdiv d0,d0,d1
    str d0,[x29,#368]
    fmov d0,#0.375
    adrp x9,.Lpoint506
    ldr d1,[x9,:lo12:.Lpoint506]
    fmul d0,d0,d1
    adrp x9,.Lpoint2
    ldr d1,[x9,:lo12:.Lpoint2]
    fdiv d0,d0,d1
    str d0,[x29,#376]
    sub w24,w19,#1
    fmov d0,xzr
.Lhistory_defaults:
    str d0,[x27,x24,lsl #3]
    ldr x9,[x29,#400]
    str d0,[x9,x24,lsl #3]
    ldr x9,[x29,#416]
    str d0,[x9,x24,lsl #3]
    ldr x9,[x29,#424]
    str d0,[x9,x24,lsl #3]
    add w24,w24,#1
    cmp w24,w20
    b.lt .Lhistory_defaults
    mov x23,#0
.Loutput_defaults_row:
    sub w24,w19,#1
.Loutput_defaults_column:
    madd x25,x23,x21,x24
    ldr x9,[x29,#280]
    str d0,[x9,x25,lsl #3]
    ldr x9,[x29,#288]
    str d0,[x9,x25,lsl #3]
    ldr x9,[x29,#296]
    str d0,[x9,x25,lsl #3]
    add w24,w24,#1
    cmp w24,w20
    b.lt .Loutput_defaults_column
    add x23,x23,#1
    cmp x23,x22
    b.lt .Loutput_defaults_row
    mov x23,#2
.Lrow:
    cmp x23,x22
    b.ge .Lreturn
    sub w24,w19,#1
    mov w28,#0
.Lmask_column:
    madd x25,x23,x21,x24
    sub x26,x25,x21
    ldr x9,[x29,#208]
    ldr d0,[x9,x25,lsl #3]
    ldr x9,[x29,#432]
    str d0,[x9,x24,lsl #3]
    mov w10,#0
    ldr x9,[x29,#160]
    ldr w11,[x9,x24,lsl #2]
    cbz w11,.Lmask_store
    ldr x9,[x29,#248]
    ldr d0,[x9,x26,lsl #3]
    fcmp d0,#0.0
    b.ge .Lmask_store
    mov w10,#1
    add w28,w28,#1
.Lmask_store:
    ldr x9,[x29,#440]
    str w10,[x9,x24,lsl #2]
    add w24,w24,#1
    cmp w24,w20
    b.lt .Lmask_column
    cbz w28,.Lrow_next
    sub w24,w19,#1
.Ltransport_column:
    ldr x9,[x29,#440]
    ldr w10,[x9,x24,lsl #2]
    cbz w10,.Lupper_unconditional
    madd x25,x23,x21,x24
    sub x26,x25,x21
    ldr d0,[x29,#352]
    ldr x9,[x29,#248]
    ldr d1,[x9,x26,lsl #3]
    fmul d0,d0,d1
    ldr x9,[x29,#200]
    ldr d2,[x9,x26,lsl #3]
    ldr x9,[x29,#200]
    ldr d3,[x9,x25,lsl #3]
    fsub d2,d2,d3
    fmul d0,d0,d2
    ldr d3,[x29,#344]
    fmul d0,d0,d3
    str d0,[x27,x24,lsl #3]
    ldr x9,[x29,#400]
    str d0,[x9,x24,lsl #3]
    add w10,w23,#1
    ldr w11,[x29,#384]
    cmp w10,w11
    b.le .Lupper_transport
    fmov d0,xzr
    str d0,[x27,x24,lsl #3]
    sub w11,w11,#1
    madd x10,x11,x21,x24
    ldr x9,[x29,#248]
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x29,#208]
    ldr d1,[x9,x25,lsl #3]
    ldr x9,[x29,#208]
    ldr d2,[x9,x26,lsl #3]
    fsub d1,d1,d2
    fmul d0,d0,d1
    madd x10,x22,x21,x24
    ldr x9,[x29,#208]
    ldr d1,[x9,x10,lsl #3]
    ldr w11,[x29,#384]
    sub w11,w11,#1
    madd x10,x11,x21,x24
    ldr x9,[x29,#208]
    ldr d2,[x9,x10,lsl #3]
    fsub d1,d1,d2
    fdiv d0,d0,d1
    ldr x9,[x29,#400]
    str d0,[x9,x24,lsl #3]
    b .Lmix_flux
.Lupper_transport:
    ldr x9,[x29,#200]
    ldr d0,[x9,x26,lsl #3]
    ldr x9,[x29,#200]
    ldr d1,[x9,x25,lsl #3]
    fsub d0,d0,d1
    fneg d0,d0
    ldr d1,[x29,#344]
    fmul d0,d0,d1
    ldr x9,[x29,#416]
    ldr d1,[x9,x24,lsl #3]
    fmul d0,d1,d0
    ldr x9,[x29,#248]
    ldr d1,[x9,x26,lsl #3]
    fmul d0,d0,d1
    ldr d2,[x27,x24,lsl #3]
    fadd d0,d2,d0
    adrp x9,.Lpoint3
    ldr d2,[x9,:lo12:.Lpoint3]
    fmul d2,d2,d1
    fmax d0,d0,d2
    ldr x9,[x29,#240]
    ldr d2,[x9,x25,lsl #3]
    fmov d3,#-0.75
    fmul d2,d3,d2
    ldr x9,[x29,#400]
    ldr d3,[x9,x24,lsl #3]
    fsub d1,d1,d3
    fsub d2,d2,d1
    fmax d0,d0,d2
    fmov d1,xzr
    fmin d0,d0,d1
    str d0,[x27,x24,lsl #3]
.Lupper_unconditional:
    add w10,w23,#1
    ldr w11,[x29,#384]
    cmp w10,w11
    b.gt .Linactive_check
    madd x25,x23,x21,x24
    ldr d0,[x27,x24,lsl #3]
    ldr x9,[x29,#400]
    ldr d1,[x9,x24,lsl #3]
    fsub d0,d0,d1
    ldr x9,[x29,#280]
    str d0,[x9,x25,lsl #3]
.Linactive_check:
    ldr x9,[x29,#440]
    ldr w10,[x9,x24,lsl #2]
    cbz w10,.Ltransport_next
    madd x25,x23,x21,x24
    sub x26,x25,x21
.Lmix_flux:
    ldr x9,[x29,#248]
    ldr d0,[x9,x26,lsl #3]
    ldr d1,[x27,x24,lsl #3]
    ldr x9,[x29,#400]
    ldr d2,[x9,x24,lsl #3]
    fadd d0,d0,d1
    fsub d0,d0,d2
    ldr x9,[x29,#248]
    str d0,[x9,x25,lsl #3]
    ldr d3,[x29,#360]
    fneg d3,d3
    fmin d0,d3,d0
    fmov d3,#1.0
    fdiv d0,d3,d0
    str d0,[x29,#448]
    ldr x9,[x29,#176]
    ldr d0,[x9,x26,lsl #3]
    fmul d0,d0,d1
    ldr x9,[x29,#232]
    ldr d3,[x9,x26,lsl #3]
    fmul d3,d3,d2
    ldr x9,[x29,#264]
    ldr d4,[x9,x26,lsl #3]
    fadd d0,d4,d0
    fsub d0,d0,d3
    ldr d3,[x29,#448]
    fmul d0,d0,d3
    ldr x9,[x29,#232]
    str d0,[x9,x25,lsl #3]
    ldr x9,[x29,#408]
    str d0,[x9,x24,lsl #3]
    ldr x9,[x29,#168]
    ldr d0,[x9,x26,lsl #3]
    ldr d3,[x29,#320]
    fmul d0,d3,d0
    ldr x9,[x29,#200]
    ldr d4,[x9,x26,lsl #3]
    fadd d0,d0,d4
    fmul d0,d0,d1
    ldr x9,[x29,#224]
    ldr d1,[x9,x26,lsl #3]
    fmul d1,d3,d1
    fadd d1,d1,d4
    fmul d1,d1,d2
    ldr x9,[x29,#256]
    ldr d2,[x9,x26,lsl #3]
    fadd d0,d2,d0
    fsub d0,d0,d1
    ldr d1,[x29,#448]
    fmul d0,d0,d1
    ldr x9,[x29,#200]
    ldr d1,[x9,x25,lsl #3]
    fsub d0,d0,d1
    fdiv d0,d0,d3
    adrp x9,.Lpoint400
    ldr d1,[x9,:lo12:.Lpoint400]
    fmin d0,d1,d0
    adrp x9,.Lpoint100
    ldr d1,[x9,:lo12:.Lpoint100]
    fmax d0,d1,d0
    ldr x9,[x29,#224]
    str d0,[x9,x25,lsl #3]
.Ltransport_next:
    add w24,w24,#1
    cmp w24,w20
    b.lt .Ltransport_column
    add w9,w23,#1
    str w9,[x29,#392]
    ldr x9,[x29,#232]
    str x9,[sp]
    ldr x9,[x29,#440]
    str x9,[sp,#8]
    add x9,x29,#388
    str x9,[sp,#16]
    str xzr,[sp,#24]
    ldr x0,[x29,#112]
    ldr x1,[x29,#128]
    ldr x2,[x29,#136]
    ldr x3,[x29,#144]
    ldr x4,[x29,#152]
    add x5,x29,#392
    ldr x6,[x29,#432]
    ldr x7,[x29,#224]
    bl CUDDRAFN_ADJUSTMENT
    sub w24,w19,#1
.Lfinal_column:
    ldr x9,[x29,#440]
    ldr w10,[x9,x24,lsl #2]
    cbz w10,.Lfinal_next
    madd x25,x23,x21,x24
    sub x26,x25,x21
    ldr x9,[x29,#408]
    ldr d0,[x9,x24,lsl #3]
    ldr x9,[x29,#232]
    ldr d1,[x9,x25,lsl #3]
    fsub d0,d0,d1
    ldr x9,[x29,#408]
    str d0,[x9,x24,lsl #3]
    ldr d2,[x29,#328]
    fmul d1,d2,d1
    fmov d3,#1.0
    fadd d1,d3,d1
    ldr x9,[x29,#224]
    ldr d4,[x9,x25,lsl #3]
    fmul d1,d4,d1
    ldr x9,[x29,#176]
    ldr d5,[x9,x25,lsl #3]
    fmul d5,d2,d5
    fadd d5,d3,d5
    ldr x9,[x29,#168]
    ldr d6,[x9,x25,lsl #3]
    fmul d5,d6,d5
    fsub d1,d1,d5
    ldr x9,[x29,#216]
    ldr d2,[x9,x24,lsl #3]
    fcmp d2,#0.0
    b.le .Lrain_loaded
    ldr x9,[x29,#240]
    ldr d3,[x9,x25,lsl #3]
    fcmp d3,#0.0
    b.le .Lrain_loaded
    fdiv d2,d2,d3
    fmul d2,d4,d2
    fsub d1,d1,d2
.Lrain_loaded:
    str d1,[x29,#456]
    fcmp d1,#0.0
    b.ge .Lstop
    ldr x9,[x29,#248]
    ldr d2,[x9,x25,lsl #3]
    fmul d0,d2,d0
    ldr x9,[x29,#216]
    ldr d3,[x9,x24,lsl #3]
    fcmp d3,d0
    b.gt .Lflux_store
.Lstop:
    fmov d0,xzr
    ldr x9,[x29,#248]
    str d0,[x9,x25,lsl #3]
    str d0,[x29,#456]
.Lflux_store:
    ldr x9,[x29,#224]
    ldr d0,[x9,x25,lsl #3]
    ldr d1,[x29,#320]
    fmul d0,d1,d0
    ldr x9,[x29,#200]
    ldr d1,[x9,x25,lsl #3]
    fadd d0,d0,d1
    ldr x9,[x29,#248]
    ldr d2,[x9,x25,lsl #3]
    fmul d0,d0,d2
    ldr x9,[x29,#256]
    str d0,[x9,x25,lsl #3]
    ldr x9,[x29,#232]
    ldr d0,[x9,x25,lsl #3]
    fmul d0,d0,d2
    ldr x9,[x29,#264]
    str d0,[x9,x25,lsl #3]
    fneg d0,d2
    ldr x9,[x29,#408]
    ldr d1,[x9,x24,lsl #3]
    fmul d0,d0,d1
    ldr x9,[x29,#272]
    str d0,[x9,x26,lsl #3]
    ldr x9,[x29,#216]
    ldr d1,[x9,x24,lsl #3]
    fadd d0,d1,d0
    ldr x9,[x29,#216]
    str d0,[x9,x24,lsl #3]
    ldr d0,[x29,#456]
    ldr x9,[x29,#168]
    ldr d1,[x9,x25,lsl #3]
    fdiv d0,d0,d1
    str d0,[x29,#464]
    fmov d1,xzr
    fmin d0,d0,d1
    str d0,[x29,#472]
    ldr x9,[x29,#192]
    ldr d1,[x9,x26,lsl #3]
    ldr x9,[x29,#192]
    ldr d2,[x9,x25,lsl #3]
    fsub d1,d1,d2
    fneg d1,d1
    str d1,[x29,#480]
    fmul d0,d0,d1
    ldr x9,[x29,#424]
    ldr d1,[x9,x24,lsl #3]
    fadd d0,d1,d0
    ldr x9,[x29,#424]
    str d0,[x9,x24,lsl #3]
    fmov d1,#1.0
    fadd d0,d1,d0
    ldr d1,[x29,#336]
    ldr d2,[x29,#472]
    fmul d1,d1,d2
    fmov d2,#0.5
    fmul d1,d1,d2
    fdiv d0,d1,d0
    ldr x9,[x29,#416]
    str d0,[x9,x24,lsl #3]
    ldr x9,[x29,#400]
    ldr d0,[x9,x24,lsl #3]
    fneg d0,d0
    ldr x9,[x29,#288]
    str d0,[x9,x25,lsl #3]
    ldr d0,[x29,#480]
    ldr d1,[x29,#464]
    fmul d0,d0,d1
    ldr d1,[x29,#368]
    fmul d0,d0,d1
    str d0,[x29,#488]
    ldr d0,[x27,x24,lsl #3]
    fcmp d0,#0.0
    b.lt .Lkinetic_mix
    ldr x9,[x29,#400]
    ldr d0,[x9,x24,lsl #3]
.Lkinetic_mix:
    ldr d1,[x29,#376]
    fmov d2,#1.0
    fadd d1,d2,d1
    fmul d0,d1,d0
    ldr d1,[x29,#360]
    fneg d1,d1
    ldr x9,[x29,#248]
    ldr d3,[x9,x26,lsl #3]
    fmin d1,d1,d3
    fdiv d0,d0,d1
    fmin d0,d2,d0
    fsub d1,d2,d0
    fadd d0,d2,d0
    ldr x9,[x29,#296]
    ldr d2,[x9,x26,lsl #3]
    fmul d1,d2,d1
    ldr d2,[x29,#488]
    fadd d1,d1,d2
    fdiv d0,d1,d0
    fmov d1,xzr
    fmax d0,d1,d0
    ldr x9,[x29,#296]
    str d0,[x9,x25,lsl #3]
.Lfinal_next:
    add w24,w24,#1
    cmp w24,w20
    b.lt .Lfinal_column
.Lrow_next:
    add x23,x23,#1
    b .Lrow
.Lreturn:
    mov sp,x29
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp]
    add sp,sp,#640
    ret
.Ldomain:
    brk #0x4c6
.size CUDDRAFN_SYMBOL,.-CUDDRAFN_SYMBOL
.section .rodata
.p2align 3
.Lpoint3: .double 0.3
.Lpoint2: .double 0.2
.Lpoint506: .double 0.506
.Lpoint400: .double 400.0
.Lpoint100: .double 100.0
.section .note.GNU-stack,"",%progbits
