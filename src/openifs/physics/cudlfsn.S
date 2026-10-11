// Physics input formulations/openifs/physics/convective_downdraft_start.md.
// Contract skills/md2asm/references/openifs/physics/cudlfsn.md.
#ifndef CUDLFSN_SYMBOL
#define CUDLFSN_SYMBOL cudlfsn_
#endif
#ifndef CUDLFSN_ADJUSTMENT
#define CUDLFSN_ADJUSTMENT md2asm_cuadjtq
#endif
.text
.p2align 4
.global CUDLFSN_SYMBOL
.type CUDLFSN_SYMBOL,%function
CUDLFSN_SYMBOL:
    ldr w9,[x0,#4]
    cbnz w9,.Ldomain
    stp x29,x30,[sp,#-512]!
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
    ldr x9,[x29,#512]
    str x9,[x29,#176]
    ldr x9,[x29,#520]
    str x9,[x29,#184]
    ldr x9,[x29,#528]
    str x9,[x29,#192]
    ldr x9,[x29,#536]
    str x9,[x29,#200]
    ldr x9,[x29,#544]
    str x9,[x29,#208]
    ldr x9,[x29,#552]
    str x9,[x29,#216]
    ldr x9,[x29,#560]
    str x9,[x29,#224]
    ldr x9,[x29,#568]
    str x9,[x29,#232]
    ldr x9,[x29,#576]
    str x9,[x29,#240]
    ldr x9,[x29,#584]
    str x9,[x29,#248]
    ldr x9,[x29,#592]
    str x9,[x29,#256]
    ldr x9,[x29,#600]
    str x9,[x29,#264]
    ldr x9,[x29,#608]
    str x9,[x29,#272]
    ldr x9,[x29,#616]
    str x9,[x29,#280]
    ldr x9,[x29,#624]
    str x9,[x29,#288]
    ldr x9,[x29,#632]
    str x9,[x29,#296]
    ldr x9,[x29,#640]
    str x9,[x29,#304]
    ldr x9,[x29,#648]
    str x9,[x29,#312]
    ldr x9,[x29,#656]
    str x9,[x29,#320]
    ldr x9,[x29,#664]
    str x9,[x29,#328]

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
    sub w24,w19,#1
    add w10,w22,#1
    ldr x11,[x29,#320]
    ldr x12,[x29,#328]
.Ldefaults:
    str w10,[x11,x24,lsl #2]
    str wzr,[x12,x24,lsl #2]
    add w24,w24,#1
    cmp w24,w20
    b.lt .Ldefaults
    ldr x9,[x29,#120]
    ldr w10,[x9,#260]
    cbz w10,.Lreturn
    ldr d0,[x9,#128]
    str d0,[x29,#400]
    mov x9,#40
    mul x9,x21,x9
    add x9,x9,#47
    and x9,x9,#-16
    mov x10,#1048576
    cmp x9,x10
    b.hi .Ldomain
    sub sp,sp,x9
    add x27,sp,#32
    add x9,x27,x21,lsl #3
    str x9,[x29,#432]
    add x9,x9,x21,lsl #3
    str x9,[x29,#440]
    add x9,x9,x21,lsl #3
    str x9,[x29,#448]
    add x9,x9,x21,lsl #2
    str x9,[x29,#456]
    add x9,x9,x21,lsl #2
    str x9,[x29,#464]
    mov w9,#1
    str w9,[x29,#408]
    mov w9,#2
    str w9,[x29,#412]
    adrp x9,:got:__yomcst_MOD_rcpd
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rcpd]
    ldr d0,[x9]
    str d0,[x29,#344]
    adrp x9,:got:__yomcst_MOD_retv
    ldr x9,[x9,:got_lo12:__yomcst_MOD_retv]
    ldr d0,[x9]
    str d0,[x29,#352]
    adrp x9,:got:__yomcst_MOD_rlvtt
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rlvtt]
    ldr d0,[x9]
    str d0,[x29,#360]
    adrp x9,:got:__yomcst_MOD_rlstt
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rlstt]
    ldr d0,[x9]
    str d0,[x29,#368]
    adrp x9,:got:__yoethf_MOD_rtwat
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rtwat]
    ldr d0,[x9]
    str d0,[x29,#376]
    adrp x9,:got:__yoethf_MOD_rticecu
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rticecu]
    ldr d0,[x9]
    str d0,[x29,#384]
    adrp x9,:got:__yoethf_MOD_rtwat_rticecu_r
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rtwat_rticecu_r]
    ldr d0,[x9]
    str d0,[x29,#392]

    sub w24,w19,#1
    add w10,w22,#1
    ldr x11,[x29,#456]
    ldr x12,[x29,#464]
    adrp x9,.Lminimum_start
    ldr d0,[x9,:lo12:.Lminimum_start]
.Lminimum_defaults:
    str w10,[x11,x24,lsl #2]
    str d0,[x12,x24,lsl #3]
    add w24,w24,#1
    cmp w24,w20
    b.lt .Lminimum_defaults
    mov x23,#2
.Lminimum_row:
    sub x9,x22,#2
    cmp x23,x9
    b.ge .Lsearch_start
    sub w24,w19,#1
.Lminimum_column:
    madd x25,x23,x21,x24
    ldr x9,[x29,#200]
    ldr d0,[x9,x25,lsl #3]
    ldr d1,[x29,#376]
    fmin d1,d1,d0
    ldr d2,[x29,#384]
    fmax d1,d2,d1
    fsub d1,d1,d2
    ldr d2,[x29,#392]
    fmul d1,d1,d2
    fmul d1,d1,d1
    fmov d2,#1.0
    fmin d1,d2,d1
    fsub d2,d2,d1
    ldr d3,[x29,#360]
    fmul d1,d1,d3
    ldr d3,[x29,#368]
    fmul d2,d2,d3
    fadd d1,d1,d2
    ldr x9,[x29,#208]
    ldr d2,[x9,x25,lsl #3]
    fmul d1,d1,d2
    ldr d2,[x29,#344]
    fmul d0,d2,d0
    ldr x9,[x29,#216]
    ldr d2,[x9,x25,lsl #3]
    fadd d0,d0,d2
    fadd d0,d0,d1
    ldr x9,[x29,#464]
    ldr d1,[x9,x24,lsl #3]
    fcmp d0,d1
    b.ge .Lminimum_next
    str d0,[x9,x24,lsl #3]
    ldr x9,[x29,#456]
    add w10,w23,#1
    str w10,[x9,x24,lsl #2]
.Lminimum_next:
    add w24,w24,#1
    cmp w24,w20
    b.lt .Lminimum_column
    add x23,x23,#1
    b .Lminimum_row
.Lsearch_start:
    mov x23,#2
.Lsearch_row:
    sub x9,x22,#3
    cmp x23,x9
    b.ge .Lreturn
    sub w24,w19,#1
    mov w26,#0
.Lprepare_column:
    madd x25,x23,x21,x24
    ldr x9,[x29,#184]
    ldr d0,[x9,x25,lsl #3]
    str d0,[x27,x24,lsl #3]
    ldr x9,[x29,#192]
    ldr d0,[x9,x25,lsl #3]
    ldr x9,[x29,#432]
    str d0,[x9,x24,lsl #3]
    ldr x9,[x29,#232]
    ldr d0,[x9,x25,lsl #3]
    ldr x9,[x29,#440]
    str d0,[x9,x24,lsl #3]
    mov w10,#0
    ldr x9,[x29,#176]
    ldr w11,[x9,x24,lsl #2]
    cbz w11,.Lflag_store
    ldr x9,[x29,#264]
    ldr d0,[x9,x24,lsl #3]
    fcmp d0,#0.0
    b.le .Lflag_store
    ldr x9,[x29,#328]
    ldr w11,[x9,x24,lsl #2]
    cbnz w11,.Lflag_store
    add w11,w23,#1
    ldr x9,[x29,#160]
    ldr w12,[x9,x24,lsl #2]
    cmp w11,w12
    b.ge .Lflag_store
    ldr x9,[x29,#168]
    ldr w12,[x9,x24,lsl #2]
    cmp w11,w12
    b.le .Lflag_store
    ldr x9,[x29,#456]
    ldr w12,[x9,x24,lsl #2]
    cmp w11,w12
    b.lt .Lflag_store
    mov w10,#1
    add w26,w26,#1
.Lflag_store:
    ldr x9,[x29,#448]
    str w10,[x9,x24,lsl #2]
    add w24,w24,#1
    cmp w24,w20
    b.lt .Lprepare_column
    cbz w26,.Lrow_next
    ldr x9,[x29,#432]
    str x9,[sp]
    ldr x9,[x29,#448]
    str x9,[sp,#8]
    add x9,x29,#412
    str x9,[sp,#16]
    str xzr,[sp,#24]
    ldr x0,[x29,#112]
    ldr x1,[x29,#128]
    ldr x2,[x29,#136]
    ldr x3,[x29,#144]
    add x4,x29,#408
    mov x5,x4
    ldr x6,[x29,#440]
    mov x7,x27
    bl CUDLFSN_ADJUSTMENT
    sub w24,w19,#1
.Lmix_column:
    ldr x9,[x29,#448]
    ldr w10,[x9,x24,lsl #2]
    cbz w10,.Lmix_next
    madd x25,x23,x21,x24
    ldr x9,[x29,#240]
    ldr d0,[x9,x25,lsl #3]
    ldr d1,[x27,x24,lsl #3]
    fadd d0,d0,d1
    fmov d1,#0.5
    fmul d0,d1,d0
    str d0,[x29,#480]
    ldr x9,[x29,#248]
    ldr d0,[x9,x25,lsl #3]
    ldr x9,[x29,#432]
    ldr d1,[x9,x24,lsl #3]
    fadd d0,d0,d1
    fmov d2,#0.5
    fmul d0,d2,d0
    str d0,[x29,#488]
    ldr x9,[x29,#192]
    ldr d2,[x9,x25,lsl #3]
    fsub d1,d2,d1
    str d1,[x29,#496]
    ldr d3,[x29,#352]
    fmul d0,d3,d0
    fmov d4,#1.0
    fadd d0,d4,d0
    ldr d5,[x29,#480]
    fmul d0,d5,d0
    fmul d2,d3,d2
    fadd d2,d4,d2
    ldr x9,[x29,#184]
    ldr d3,[x9,x25,lsl #3]
    fmul d2,d3,d2
    fsub d0,d0,d2
    ldr d2,[x29,#400]
    fneg d2,d2
    ldr x9,[x29,#256]
    ldr d3,[x9,x24,lsl #3]
    fmul d2,d2,d3
    str d2,[x29,#504]
    fcmp d0,#0.0
    b.ge .Lmix_next
    fmov d3,#10.0
    fmul d3,d3,d2
    fmul d3,d3,d1
    ldr x9,[x29,#264]
    ldr d4,[x9,x24,lsl #3]
    fcmp d4,d3
    b.le .Lmix_next
    add w10,w23,#1
    ldr x9,[x29,#320]
    str w10,[x9,x24,lsl #2]
    mov w10,#1
    ldr x9,[x29,#328]
    str w10,[x9,x24,lsl #2]
    ldr d0,[x29,#480]
    ldr x9,[x29,#272]
    str d0,[x9,x25,lsl #3]
    ldr d1,[x29,#488]
    ldr x9,[x29,#280]
    str d1,[x9,x25,lsl #3]
    ldr d2,[x29,#504]
    ldr x9,[x29,#288]
    str d2,[x9,x25,lsl #3]
    ldr d3,[x29,#344]
    fmul d0,d3,d0
    ldr x9,[x29,#224]
    ldr d3,[x9,x25,lsl #3]
    fadd d0,d0,d3
    fmul d0,d2,d0
    ldr x9,[x29,#296]
    str d0,[x9,x25,lsl #3]
    fmul d0,d2,d1
    ldr x9,[x29,#304]
    str d0,[x9,x25,lsl #3]
    fmov d0,#-0.5
    fmul d0,d0,d2
    ldr d1,[x29,#496]
    fmul d0,d0,d1
    sub x10,x25,x21
    ldr x9,[x29,#312]
    str d0,[x9,x10,lsl #3]
    fadd d0,d4,d0
    ldr x9,[x29,#264]
    str d0,[x9,x24,lsl #3]
.Lmix_next:
    add w24,w24,#1
    cmp w24,w20
    b.lt .Lmix_column
.Lrow_next:
    add x23,x23,#1
    b .Lsearch_row
.Lreturn:
    mov sp,x29
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp]
    add sp,sp,#512
    ret
.Ldomain:
    brk #0x4c5
.size CUDLFSN_SYMBOL,.-CUDLFSN_SYMBOL
.section .rodata
.p2align 3
.Lminimum_start:
    .double 1.0e8
.section .note.GNU-stack,"",%progbits
