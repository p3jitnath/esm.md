// Complete VDFEXCU from formulations/openifs/physics/turbulent_exchange_coefficients.md.
// Source rounding, registered surface metadata and all SPP branches follow its md2asm contract.
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL vdfexcu_
#endif
.text
.p2align 4
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
    sub sp,sp,#1024
    stp x29,x30,[sp,#0]
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    stp d8,d9,[sp,#96]
    stp d10,d11,[sp,#112]
    stp d12,d13,[sp,#128]
    stp d14,d15,[sp,#144]
    stp x0,x1,[sp,#160]
    stp x2,x3,[sp,#176]
    stp x4,x5,[sp,#192]
    stp x6,x7,[sp,#208]
    str x18,[sp,#736]
    add x16,sp,#1024
    ldr x9,[x16,#0]
    str x9,[sp,#224]
    ldr x9,[x16,#8]
    str x9,[sp,#232]
    ldr x9,[x16,#16]
    str x9,[sp,#240]
    ldr x9,[x16,#24]
    str x9,[sp,#248]
    ldr x9,[x16,#32]
    str x9,[sp,#256]
    ldr x9,[x16,#40]
    str x9,[sp,#264]
    ldr x9,[x16,#48]
    str x9,[sp,#272]
    ldr x9,[x16,#56]
    str x9,[sp,#280]
    ldr x9,[x16,#64]
    str x9,[sp,#288]
    ldr x9,[x16,#72]
    str x9,[sp,#296]
    ldr x9,[x16,#80]
    str x9,[sp,#304]
    ldr x9,[x16,#88]
    str x9,[sp,#312]
    ldr x9,[x16,#96]
    str x9,[sp,#320]
    ldr x9,[x16,#104]
    str x9,[sp,#328]
    ldr x9,[x16,#112]
    str x9,[sp,#336]
    ldr x9,[x16,#120]
    str x9,[sp,#344]
    ldr x9,[x16,#128]
    str x9,[sp,#352]
    ldr x9,[x16,#136]
    str x9,[sp,#360]
    ldr x9,[x16,#144]
    str x9,[sp,#368]
    ldr x9,[x16,#152]
    str x9,[sp,#376]
    ldr x9,[x16,#160]
    str x9,[sp,#384]
    ldr x9,[x16,#168]
    str x9,[sp,#392]
    ldr x9,[x16,#176]
    str x9,[sp,#400]
    ldr x9,[x16,#184]
    str x9,[sp,#408]
    ldr x9,[x16,#192]
    str x9,[sp,#416]
    ldr x9,[x16,#200]
    str x9,[sp,#424]
    ldr x9,[x16,#208]
    str x9,[sp,#432]
    ldr x9,[x16,#216]
    str x9,[sp,#440]
    mov x19,sp
    adrp x28,.Lconstants
    add x28,x28,:lo12:.Lconstants
    mrs x9,fpcr
    cbnz x9,.Lreject
    ldr x9,[x19,#160]
    cbz x9,.Lreject
    tst x9,#7
    b.ne .Lreject
    ldr x9,[x19,#168]
    cbz x9,.Lreject
    tst x9,#7
    b.ne .Lreject
    ldr x9,[x19,#176]
    cbz x9,.Lreject
    tst x9,#7
    b.ne .Lreject
    ldr x9,[x19,#184]
    cbz x9,.Lreject
    tst x9,#3
    b.ne .Lreject
    ldr x9,[x19,#192]
    cbz x9,.Lreject
    tst x9,#3
    b.ne .Lreject
    ldr x9,[x19,#200]
    cbz x9,.Lreject
    tst x9,#3
    b.ne .Lreject
    ldr x9,[x19,#208]
    cbz x9,.Lreject
    tst x9,#3
    b.ne .Lreject
    ldr x9,[x19,#216]
    cbz x9,.Lreject
    tst x9,#3
    b.ne .Lreject
    ldr x9,[x19,#224]
    cbz x9,.Lreject
    tst x9,#3
    b.ne .Lreject
    ldr x9,[x19,#232]
    cbz x9,.Lreject
    tst x9,#3
    b.ne .Lreject
    ldr x9,[x19,#240]
    cbz x9,.Lreject
    tst x9,#7
    b.ne .Lreject
    ldr x9,[x19,#248]
    cbz x9,.Lreject
    tst x9,#7
    b.ne .Lreject
    ldr x9,[x19,#256]
    cbz x9,.Lreject
    tst x9,#7
    b.ne .Lreject
    ldr x9,[x19,#264]
    cbz x9,.Lreject
    tst x9,#7
    b.ne .Lreject
    ldr x9,[x19,#272]
    cbz x9,.Lreject
    tst x9,#7
    b.ne .Lreject
    ldr x9,[x19,#280]
    cbz x9,.Lreject
    tst x9,#7
    b.ne .Lreject
    ldr x9,[x19,#288]
    cbz x9,.Lreject
    tst x9,#7
    b.ne .Lreject
    ldr x9,[x19,#296]
    cbz x9,.Lreject
    tst x9,#7
    b.ne .Lreject
    ldr x9,[x19,#304]
    cbz x9,.Lreject
    tst x9,#7
    b.ne .Lreject
    ldr x9,[x19,#312]
    cbz x9,.Lreject
    tst x9,#7
    b.ne .Lreject
    ldr x9,[x19,#320]
    cbz x9,.Lreject
    tst x9,#7
    b.ne .Lreject
    ldr x9,[x19,#328]
    cbz x9,.Lreject
    tst x9,#7
    b.ne .Lreject
    ldr x9,[x19,#336]
    cbz x9,.Lreject
    tst x9,#7
    b.ne .Lreject
    ldr x9,[x19,#344]
    cbz x9,.Lreject
    tst x9,#7
    b.ne .Lreject
    ldr x9,[x19,#352]
    cbz x9,.Lreject
    tst x9,#7
    b.ne .Lreject
    ldr x9,[x19,#360]
    cbz x9,.Lreject
    tst x9,#7
    b.ne .Lreject
    ldr x9,[x19,#368]
    cbz x9,.Lreject
    tst x9,#7
    b.ne .Lreject
    ldr x9,[x19,#384]
    cbz x9,.Lreject
    tst x9,#7
    b.ne .Lreject
    ldr x9,[x19,#392]
    cbz x9,.Lreject
    tst x9,#7
    b.ne .Lreject
    ldr x9,[x19,#408]
    cbz x9,.Lreject
    tst x9,#7
    b.ne .Lreject
    ldr x9,[x19,#416]
    cbz x9,.Lreject
    tst x9,#7
    b.ne .Lreject
    ldr x9,[x19,#424]
    cbz x9,.Lreject
    tst x9,#7
    b.ne .Lreject
    ldr x9,[x19,#440]
    cbz x9,.Lreject
    tst x9,#3
    b.ne .Lreject
    ldr x9,[x19,#184]
    ldr w20,[x9]
    sub w20,w20,#1
    ldr x9,[x19,#192]
    ldr w23,[x9]
    ldr x9,[x19,#200]
    ldr w21,[x9]
    ldr x9,[x19,#208]
    ldr w22,[x9]
    cmp w21,#1
    b.lt .Lreject
    cmp w21,#4096
    b.gt .Lreject
    cmp w22,#1
    b.lt .Lreject
    cmp w22,#1024
    b.gt .Lreject
    cmp w20,#0
    b.lt .Lreject
    cmp w20,w21
    b.gt .Lreject
    cmp w23,#0
    b.lt .Lreject
    cmp w23,w21
    b.gt .Lreject
    cmp w20,w23
    b.ge .Ldone
    adrp x9,:got:__yomcst_MOD_rg
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rg]
    ldr d0,[x9]
    str d0,[x19,#448]
    adrp x9,:got:__yomcst_MOD_rd
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rd]
    ldr d0,[x9]
    str d0,[x19,#456]
    adrp x9,:got:__yomcst_MOD_rcpd
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rcpd]
    ldr d0,[x9]
    str d0,[x19,#464]
    adrp x9,:got:__yomcst_MOD_retv
    ldr x9,[x9,:got_lo12:__yomcst_MOD_retv]
    ldr d0,[x9]
    str d0,[x19,#472]
    adrp x9,:got:__yomcst_MOD_rlvtt
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rlvtt]
    ldr d0,[x9]
    str d0,[x19,#480]
    adrp x9,:got:__yomdyncore_MOD_rplrg
    ldr x9,[x9,:got_lo12:__yomdyncore_MOD_rplrg]
    ldr d0,[x9]
    str d0,[x19,#488]
    adrp x9,:got:__yomdyncore_MOD_rpldare
    ldr x9,[x9,:got_lo12:__yomdyncore_MOD_rpldare]
    ldr d0,[x9]
    str d0,[x19,#496]
    adrp x9,:got:__yoevdfs_MOD_rcdhalf
    ldr x9,[x9,:got_lo12:__yoevdfs_MOD_rcdhalf]
    ldr d0,[x9]
    str d0,[x19,#504]
    ldr x9,[x19,#168]
    ldr x9,[x9,#440]
    cbz x9,.Lreject
    ldr d0,[x9,#4056]
    str d0,[x19,#760]
    fmov d0,#1.0
    ldr d1,[x19,#448]
    fdiv d0,d0,d1
    str d0,[x19,#744]
    fmov d0,#1.0
    ldr d1,[x19,#464]
    fdiv d0,d0,d1
    str d0,[x19,#752]
    ldr x0,[x19,#176]
    ldr w9,[x0]
    cbz w9,.Lcolumn
    mov w10,#488
    bl .Lvalidate
    mov w10,#464
    bl .Lvalidate
    mov w10,#468
    bl .Lvalidate
    mov w10,#472
    bl .Lvalidate
    mov w10,#476
    bl .Lvalidate
.Lcolumn:
    fmov d0,#1.0
    str d0,[x19,#512]
    str d0,[x19,#520]
    ldr x0,[x19,#176]
    ldr w9,[x0]
    cbz w9,.Lsurface
    mov w10,#488
    bl .Lfactor
    str d0,[x19,#512]
    ldr x9,[x19,#440]
    ldr w9,[x9,x20,lsl #2]
    cmp w9,#3
    b.hi .Lsurface
    lsl w10,w9,#2
    add w10,w10,#464
    ldr x0,[x19,#176]
    bl .Lfactor
    str d0,[x19,#520]
.Lsurface:
    ldr x9,[x19,#440]
    ldr w9,[x9,x20,lsl #2]
    str w9,[x19,#800]
    ldr x9,[x19,#216]
    ldr w9,[x9,x20,lsl #2]
    sub w9,w9,#1
    sxtw x9,w9
    str x9,[x19,#544]
    ldr x9,[x19,#344]
    ldr d0,[x9,x20,lsl #3]
    ldr d1,[x19,#760]
    fsqrt d0,d0
    fmaxnm d0,d0,d1
    str d0,[x19,#528]
    fmov d1,#1.0
    str d1,[x19,#536]
    ldr x9,[x19,#368]
    ldr d1,[x9,x20,lsl #3]
    fcmp d1,#0.0
    b.ge .Lradiation
    ldr d2,[x28,#24]
    fsub d1,d1,d2
    ldr d2,[x19,#520]
    ldr d3,[x28,#0]
    ldr d4,[x19,#448]
    fmul d2,d3,d2
    fmul d2,d2,d4
    fmul d1,d2,d1
    fmul d2,d0,d0
    fmul d0,d2,d0
    sub x10,x22,#1
    madd x26,x10,x21,x20
    ldr x9,[x19,#288]
    ldr d2,[x9,x26,lsl #3]
    fmul d0,d0,d2
    fdiv d0,d0,d1
    fmov x10,d0
    fabs d0,d0
    ldr d1,[x28,#16]
    fmaxnm d0,d0,d1
    fmov x11,d0
    and x10,x10,#0x8000000000000000
    orr x10,x10,x11
    fmov d0,x10
    str d0,[x19,#536]
.Lradiation:
    str xzr,[x19,#552]
    ldr w9,[x19,#800]
    cmp w9,#2
    b.ne .Lpbl_prepare
    ldr x10,[x19,#544]
    cmp x10,#2
    b.lt .Lreject
    cmp x10,x22
    b.gt .Lreject
    sub x11,x10,#1
    madd x26,x11,x21,x20
    ldr x9,[x19,#256]
    ldr d0,[x9,x26,lsl #3]
    ldr x9,[x19,#264]
    ldr d1,[x9,x26,lsl #3]
    fadd d0,d0,d1
    sub x26,x26,x21
    ldr x9,[x19,#256]
    ldr d1,[x9,x26,lsl #3]
    ldr x9,[x19,#264]
    ldr d2,[x9,x26,lsl #3]
    fadd d1,d1,d2
    fminnm d0,d0,d1
    fneg d0,d0
    ldr x10,[x19,#544]
    sub x11,x10,#1
    madd x26,x11,x21,x20
    ldr x9,[x19,#320]
    ldr d1,[x9,x26,lsl #3]
    add x26,x26,x21
    ldr x9,[x19,#320]
    ldr d2,[x9,x26,lsl #3]
    ldr d3,[x19,#744]
    ldr d4,[x19,#496]
    fsub d1,d1,d2
    fmul d0,d0,d1
    fmul d0,d0,d3
    fdiv d0,d0,d4
    fmov d1,xzr
    fmaxnm d0,d0,d1
    str d0,[x19,#552]
.Lpbl_prepare:
    str xzr,[x19,#560]
    str xzr,[x19,#576]
    sub x10,x22,#1
    madd x26,x10,x21,x20
    ldr x9,[x19,#288]
    ldr d0,[x9,x26,lsl #3]
    ldr x9,[x19,#296]
    ldr d1,[x9,x26,lsl #3]
    ldr d2,[x19,#472]
    ldr d3,[x19,#464]
    ldr x9,[x19,#312]
    ldr d4,[x9,x26,lsl #3]
    fmul d1,d2,d1
    fmov d2,#1.0
    fadd d1,d2,d1
    fmul d0,d3,d0
    fmul d0,d0,d1
    fadd d0,d0,d4
    ldr d1,[x28,#24]
    fadd d0,d0,d1
    str d0,[x19,#568]
    ldr x9,[x19,#368]
    ldr d0,[x9,x20,lsl #3]
    fcmp d0,#0.0
    b.le .Lmain_prepare
    sub x25,x22,#2
.Lpbl_scan:
    cmp x25,#0
    b.lt .Lmain_prepare
    madd x26,x25,x21,x20
    ldr x9,[x19,#288]
    ldr d0,[x9,x26,lsl #3]
    ldr x9,[x19,#296]
    ldr d1,[x9,x26,lsl #3]
    ldr d2,[x19,#472]
    ldr d3,[x19,#464]
    ldr x9,[x19,#312]
    ldr d4,[x9,x26,lsl #3]
    fmul d1,d2,d1
    fmov d2,#1.0
    fadd d1,d2,d1
    fmul d0,d3,d0
    fmul d0,d0,d1
    fadd d0,d0,d4
    ldr d1,[x19,#568]
    fsub d1,d0,d1
    fsub d0,d0,d4
    fdiv d1,d1,d0
    sub x10,x22,#1
    madd x10,x10,x21,x20
    ldr x9,[x19,#312]
    ldr d0,[x9,x10,lsl #3]
    fsub d0,d4,d0
    fmul d1,d0,d1
    ldr x9,[x19,#272]
    ldr d0,[x9,x26,lsl #3]
    ldr x9,[x19,#280]
    ldr d2,[x9,x26,lsl #3]
    fmul d0,d0,d0
    fmul d2,d2,d2
    fadd d0,d0,d2
    ldr d2,[x28,#8]
    fmaxnm d0,d0,d2
    fdiv d0,d1,d0
    fmov d1,#0.25
    fcmp d0,d1
    b.gt .Lpbl_cross
    str d0,[x19,#576]
    sub x25,x25,#1
    b .Lpbl_scan
.Lpbl_cross:
    ldr d2,[x19,#576]
    fsub d3,d0,d1
    add x10,x26,x21
    ldr x9,[x19,#312]
    ldr d4,[x9,x10,lsl #3]
    ldr x9,[x19,#312]
    ldr d5,[x9,x26,lsl #3]
    ldr d6,[x19,#448]
    fsub d1,d1,d2
    fmul d3,d3,d4
    fmul d1,d1,d5
    fadd d1,d3,d1
    fsub d0,d0,d2
    fmul d0,d0,d6
    fdiv d0,d1,d0
    str d0,[x19,#560]
.Lmain_prepare:
    sub x25,x22,#2
.Llevel:
    cmp x25,#0
    b.lt .Lnext_column
    madd x26,x25,x21,x20
    add x10,x26,x21
    ldr x9,[x19,#312]
    ldr d0,[x9,x26,lsl #3]
    ldr x9,[x19,#312]
    ldr d1,[x9,x10,lsl #3]
    fsub d0,d0,d1
    str d0,[x19,#584]
    ldr x9,[x19,#272]
    ldr d0,[x9,x26,lsl #3]
    ldr x9,[x19,#272]
    ldr d1,[x9,x10,lsl #3]
    ldr x9,[x19,#280]
    ldr d2,[x9,x26,lsl #3]
    ldr x9,[x19,#280]
    ldr d3,[x9,x10,lsl #3]
    fsub d0,d0,d1
    fsub d2,d2,d3
    fmul d0,d0,d0
    fmul d2,d2,d2
    fadd d0,d0,d2
    ldr d1,[x28,#8]
    ldr d2,[x19,#584]
    ldr d3,[x19,#448]
    fmaxnm d0,d0,d1
    fsqrt d0,d0
    fdiv d0,d0,d2
    fmul d0,d0,d3
    str d0,[x19,#592]
    ldr x9,[x19,#424]
    ldr d0,[x9,x26,lsl #3]
    str d0,[x19,#600]
    ldr x9,[x19,#312]
    ldr d0,[x9,x26,lsl #3]
    ldr x9,[x19,#312]
    ldr d1,[x9,x10,lsl #3]
    ldr d2,[x19,#744]
    ldr x9,[x19,#248]
    ldr d3,[x9,x20,lsl #3]
    fadd d0,d0,d1
    fmov d1,#0.5
    fmul d1,d1,d2
    fmul d0,d1,d0
    fadd d0,d0,d3
    str d0,[x19,#608]
    ldr d0,[x19,#600]
    fcmp d0,#0.0
    b.le .Lunstable_length
    ldr x9,[x19,#312]
    ldr d0,[x9,x26,lsl #3]
    ldr d1,[x19,#744]
    ldr d2,[x19,#560]
    fmul d0,d0,d1
    fcmp d0,d2
    b.gt .Lfree_length
    ldr d0,[x19,#512]
    ldr d1,[x28,#56]
    ldr d3,[x19,#488]
    fmul d0,d0,d1
    fmul d0,d0,d2
    fmul d0,d0,d3
    ldr d1,[x28,#40]
    ldr d2,[x28,#48]
    fmaxnm d0,d0,d1
    fminnm d0,d0,d2
    b .Lstability_length
.Lfree_length:
    ldr d0,[x28,#40]
.Lstability_length:
    ldr d1,[x19,#488]
    fdiv d0,d0,d1
    b .Lmixing_length
.Lunstable_length:
    ldr x9,[x19,#240]
    ldr d0,[x9]
.Lmixing_length:
    str d0,[x19,#616]
    ldr d1,[x28,#0]
    ldr d2,[x19,#520]
    ldr d3,[x19,#608]
    fmul d1,d1,d2
    fmul d1,d1,d3
    fmul d2,d1,d0
    fadd d1,d1,d0
    fdiv d0,d2,d1
    fmul d0,d0,d0
    str d0,[x19,#624]
    ldr d0,[x19,#600]
    fcmp d0,#0.0
    b.le .Lunstable
    fmov d1,#1.0
    fadd d2,d1,d0
    fsqrt d2,d2
    fmov d3,#10.0
    fmul d3,d3,d0
    fdiv d4,d3,d2
    fadd d4,d1,d4
    fdiv d4,d1,d4
    fmul d3,d3,d2
    fadd d3,d1,d3
    fdiv d3,d1,d3
    b .Lshear_coefficients
.Lunstable:
    ldr d1,[x19,#504]
    fmul d0,d1,d0
    fmov d1,#1.0
    fsub d0,d1,d0
    fsqrt d0,d0
    fsqrt d2,d0
    fdiv d2,d1,d2
    fdiv d0,d1,d0
    fmul d4,d2,d2
    fdiv d4,d1,d4
    fmul d3,d2,d0
    fdiv d3,d1,d3
.Lshear_coefficients:
    ldr d0,[x19,#592]
    ldr d1,[x19,#624]
    fmul d0,d0,d1
    fmul d1,d0,d4
    fmul d0,d0,d3
    str d1,[x19,#632]
    str d0,[x19,#640]
    ldr x10,[x19,#544]
    add x11,x25,#1
    cmp x11,x10
    b.le .Lentrainment
    sub x11,x22,#1
    cmp x10,x11
    b.ge .Lentrainment
    add x11,x25,#1
    madd x11,x11,x21,x20
    ldr x9,[x19,#320]
    ldr d0,[x9,x11,lsl #3]
    ldr d1,[x19,#744]
    fmul d0,d0,d1
    str d0,[x19,#648]
    madd x10,x10,x21,x20
    ldr x9,[x19,#320]
    ldr d2,[x9,x10,lsl #3]
    fmul d2,d2,d1
    str d2,[x19,#688]
    ldr d3,[x28,#16]
    fmaxnm d2,d2,d3
    fdiv d2,d0,d2
    str d2,[x19,#656]
    ldr d1,[x19,#536]
    fdiv d0,d0,d1
    str d0,[x19,#704]
    ldr d1,[x28,#64]
    fmul d0,d1,d0
    fmov d1,#1.0
    fsub d0,d1,d0
    ldr d1,[x28,#72]
    bl md2asm_pow_original_rounding_candidate
    str d0,[x19,#664]
    ldr d0,[x19,#704]
    fmov d1,#15.0
    fmul d0,d1,d0
    fmov d1,#1.0
    fsub d0,d1,d0
    ldr d1,[x28,#72]
    bl md2asm_pow_original_rounding_candidate
    str d0,[x19,#672]
    ldr d0,[x19,#656]
    ldr d2,[x19,#648]
    fmov d1,#1.0
    fsub d0,d1,d0
    fmul d0,d0,d0
    fmul d1,d2,d0
    str d1,[x19,#680]
    ldr w9,[x19,#800]
    cmp w9,#2
    b.lt .Lsurface_mixed
    ldr x9,[x19,#224]
    ldr w11,[x9,x20,lsl #2]
    ldr x9,[x19,#232]
    ldr w10,[x9,x20,lsl #2]
    add w10,w10,#1
    cmp w11,w10
    b.le .Lsurface_mixed
    ldr x9,[x19,#352]
    ldr d0,[x9,x20,lsl #3]
    ldr d1,[x19,#464]
    fmul d0,d1,d0
    ldr d2,[x28,#56]
    fneg d2,d2
    fcmp d0,d2
    b.ge .Lsurface_mixed
    fneg d0,d0
    ldr x9,[x19,#360]
    ldr d1,[x9,x20,lsl #3]
    ldr d2,[x19,#480]
    fmov d3,#0.25
    fneg d3,d3
    fmul d2,d3,d2
    fmul d1,d2,d1
    fcmp d0,d1
    b.ge .Lsurface_mixed
    ldr d0,[x19,#656]
    ldr d2,[x19,#648]
    fmov d1,#1.0
    fsub d0,d1,d0
    fmul d0,d0,d0
    fmul d0,d0,d0
    fmul d0,d2,d0
    str d0,[x19,#680]
    ldr x9,[x19,#224]
    ldr w10,[x9,x20,lsl #2]
    sub w10,w10,#1
    madd x10,x10,x21,x20
    ldr x9,[x19,#320]
    ldr d0,[x9,x10,lsl #3]
    ldr d1,[x19,#744]
    fmul d0,d0,d1
    ldr d1,[x28,#16]
    ldr d2,[x19,#648]
    fmaxnm d0,d0,d1
    fdiv d0,d2,d0
    fmov d1,#1.0
    fminnm d0,d0,d1
    fsub d0,d1,d0
    fmul d0,d0,d0
    fmul d0,d2,d0
    ldr d1,[x19,#680]
    fadd d0,d1,d0
    str d0,[x19,#680]
.Lsurface_mixed:
    ldr d0,[x28,#0]
    ldr d1,[x19,#520]
    ldr d2,[x19,#664]
    ldr d3,[x19,#672]
    ldr d4,[x19,#528]
    ldr d5,[x19,#680]
    fmul d0,d0,d1
    fdiv d1,d0,d2
    fdiv d0,d0,d3
    fmul d1,d1,d4
    fmul d0,d0,d4
    fmul d1,d1,d5
    fmul d0,d0,d5
    str d1,[x19,#640]
    str d0,[x19,#632]
    ldr w9,[x19,#800]
    cmp w9,#2
    b.ne .Lentrainment
    ldr d0,[x19,#448]
    ldr x9,[x19,#288]
    ldr d1,[x9,x26,lsl #3]
    ldr d2,[x19,#688]
    ldr d3,[x19,#552]
    fdiv d0,d0,d1
    fmul d0,d0,d2
    fmul d0,d0,d3
    ldr d1,[x28,#80]
    bl md2asm_pow_original_rounding_candidate
    str d0,[x19,#696]
    ldr d0,[x19,#648]
    ldr d1,[x19,#688]
    fdiv d0,d0,d1
    fmov d1,#1.0
    fsub d0,d1,d0
    fmov d1,#0.5
    bl md2asm_pow_original_rounding_candidate
    str d0,[x19,#704]
    ldr d0,[x28,#88]
    ldr d1,[x19,#520]
    ldr d2,[x28,#0]
    ldr d3,[x19,#696]
    ldr d4,[x19,#648]
    ldr d5,[x19,#688]
    ldr d6,[x19,#704]
    fmul d0,d0,d1
    fmul d0,d0,d2
    fmul d0,d0,d3
    fmul d4,d4,d4
    fmul d0,d0,d4
    fdiv d0,d0,d5
    fmul d0,d0,d6
    ldr d1,[x19,#640]
    ldr d2,[x19,#632]
    fadd d1,d1,d0
    fadd d0,d2,d0
    str d1,[x19,#640]
    str d0,[x19,#632]
.Lentrainment:
    ldr x10,[x19,#544]
    add x11,x25,#1
    cmp x10,x11
    b.ne .Lcap
    sub x11,x22,#1
    cmp x10,x11
    b.ge .Lcap
    cmp x10,#2
    b.lt .Lreject
    ldr x9,[x19,#368]
    ldr d0,[x9,x20,lsl #3]
    ldr d1,[x28,#32]
    fneg d1,d1
    fmul d0,d1,d0
    ldr w9,[x19,#800]
    cmp w9,#2
    b.ne .Lentrainment_surface
    ldr d1,[x28,#32]
    ldr d2,[x19,#552]
    fmul d1,d1,d2
    fadd d0,d0,d1
.Lentrainment_surface:
    fmov d1,xzr
    fmaxnm d0,d0,d1
    str d0,[x19,#704]
    sub x10,x26,x21
    ldr x9,[x19,#336]
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x19,#336]
    ldr d1,[x9,x26,lsl #3]
    ldr d2,[x19,#752]
    fsub d0,d0,d1
    fmul d0,d0,d2
    ldr x9,[x19,#296]
    ldr d1,[x9,x10,lsl #3]
    ldr x9,[x19,#296]
    ldr d2,[x9,x26,lsl #3]
    ldr d3,[x19,#472]
    fsub d1,d1,d2
    fmov d2,#0.5
    fmul d3,d3,d2
    fmul d1,d3,d1
    ldr x9,[x19,#288]
    ldr d2,[x9,x26,lsl #3]
    ldr x9,[x19,#288]
    ldr d3,[x9,x10,lsl #3]
    fadd d2,d2,d3
    fmul d1,d1,d2
    fadd d0,d0,d1
    ldr d1,[x28,#96]
    fcmp d0,d1
    b.le .Lzero_entrainment
    ldr x9,[x19,#312]
    ldr d1,[x9,x10,lsl #3]
    ldr x9,[x19,#312]
    ldr d2,[x9,x26,lsl #3]
    ldr d3,[x19,#704]
    ldr d4,[x19,#744]
    fsub d1,d1,d2
    fmul d1,d3,d1
    fmul d1,d1,d4
    fdiv d0,d1,d0
    b .Lstore_entrainment
.Lzero_entrainment:
    fmov d0,xzr
.Lstore_entrainment:
    str d0,[x19,#632]
    str d0,[x19,#640]
.Lcap:
    ldr d0,[x28,#104]
    ldr d1,[x19,#632]
    ldr d2,[x19,#640]
    fminnm d1,d1,d0
    fminnm d2,d2,d0
    str d1,[x19,#632]
    str d2,[x19,#640]
    ldr x9,[x19,#160]
    ldr w10,[x9,#88]
    cbz w10,.Lpostprocess
    ldr w9,[x9,#12]
    str w9,[x19,#804]
    ldr d0,[x19,#600]
    fmov d1,#0.25
    fcmp d0,d1
    b.le .Lpostprocess
    cmp w9,#1
    b.eq .Lstrato_one
    cmp w9,#2
    b.eq .Lstrato_two
    cmp w9,#5
    b.ne .Lpostprocess
    b .Lstrato_common
.Lstrato_two:
    ldr x9,[x19,#328]
    ldr d0,[x9,x20,lsl #3]
    fabs d0,d0
    fmov d1,#0.5
    fcmp d0,d1
    b.ge .Lpostprocess
    b .Lstrato_common
.Lstrato_one:
    add x10,x26,x21
    ldr x9,[x19,#304]
    ldr d0,[x9,x10,lsl #3]
    ldr d1,[x28,#112]
    fcmp d0,d1
    b.le .Lstrato_small
    fsub d0,d0,d1
    fmul d0,d0,d0
    ldr d1,[x28,#144]
    fdiv d0,d0,d1
    fmov d1,#1.0
    fminnm d0,d0,d1
    ldr d1,[x28,#160]
    fmaxnm d0,d0,d1
    b .Lreduce
.Lstrato_small:
    ldr d0,[x28,#160]
    b .Lreduce
.Lstrato_common:
    add x10,x26,x21
    ldr x9,[x19,#304]
    ldr d0,[x9,x10,lsl #3]
    ldr w9,[x19,#804]
    cmp w9,#5
    b.ne .Lpressure_8000
    ldr d1,[x28,#136]
    fcmp d0,d1
    b.gt .Lpressure_one
.Lpressure_8000:
    ldr d1,[x28,#112]
    fcmp d0,d1
    b.le .Lpressure_1200
    fsub d0,d0,d1
    fmul d0,d0,d0
    ldr d1,[x28,#144]
    fdiv d0,d0,d1
    b .Lpressure_ready
.Lpressure_1200:
    ldr d1,[x28,#120]
    fcmp d0,d1
    b.le .Lpressure_800
    fmov d0,xzr
    b .Lpressure_ready
.Lpressure_800:
    ldr d1,[x28,#128]
    fcmp d0,d1
    b.le .Lpressure_one
    ldr d1,[x28,#120]
    fsub d0,d0,d1
    fmul d0,d0,d0
    ldr d1,[x28,#152]
    fdiv d0,d0,d1
    b .Lpressure_ready
.Lpressure_one:
    fmov d0,#1.0
.Lpressure_ready:
    ldr w9,[x19,#804]
    cmp w9,#5
    b.eq .Llatitude_reduce
    fmov d1,#1.0
    fminnm d0,d0,d1
    b .Lri_floor
.Llatitude_reduce:
    ldr x9,[x19,#328]
    ldr d1,[x9,x20,lsl #3]
    ldr d2,[x28,#168]
    fabs d1,d1
    fmul d1,d1,d2
    ldr d2,[x28,#176]
    fcmp d1,d2
    b.lt .Lri_floor
    ldr d3,[x28,#40]
    fcmp d1,d3
    b.ge .Llatitude_one
    fsub d1,d1,d2
    ldr d2,[x28,#184]
    fmul d2,d2,d1
    fmul d2,d2,d1
    fmov d1,#1.0
    fsub d2,d1,d2
    fsub d0,d1,d0
    fmul d0,d2,d0
    fsub d0,d1,d0
    b .Lri_floor
.Llatitude_one:
    fmov d0,#1.0
.Lri_floor:
    ldr d1,[x19,#600]
    fmov d2,#1.0
    fadd d1,d2,d1
    fmul d1,d1,d1
    fmul d1,d1,d1
    fdiv d1,d2,d1
    fmaxnm d0,d0,d1
.Lreduce:
    ldr d1,[x19,#632]
    ldr d2,[x19,#640]
    fmul d1,d1,d0
    fmul d2,d2,d0
    str d1,[x19,#632]
    str d2,[x19,#640]
.Lpostprocess:
    ldr d1,[x19,#632]
    ldr d2,[x19,#640]
    ldr d0,[x19,#496]
    fmul d3,d1,d0
    fmul d4,d2,d0
    ldr x9,[x19,#408]
    str d4,[x9,x26,lsl #3]
    ldr x9,[x19,#416]
    str d3,[x9,x26,lsl #3]
    add x10,x26,x21
    ldr x9,[x19,#288]
    ldr d0,[x9,x26,lsl #3]
    ldr x9,[x19,#296]
    ldr d1,[x9,x26,lsl #3]
    ldr d2,[x19,#472]
    fmul d1,d2,d1
    fmov d3,#1.0
    fadd d1,d3,d1
    fmul d0,d0,d1
    ldr x9,[x19,#288]
    ldr d1,[x9,x10,lsl #3]
    ldr x9,[x19,#296]
    ldr d4,[x9,x10,lsl #3]
    fmul d4,d2,d4
    fadd d4,d3,d4
    fmul d1,d1,d4
    fadd d0,d0,d1
    ldr d1,[x19,#456]
    ldr d2,[x19,#584]
    fmov d3,#0.5
    fmul d1,d3,d1
    fmul d1,d1,d2
    fmul d1,d1,d0
    ldr x9,[x19,#304]
    ldr d0,[x9,x10,lsl #3]
    ldr d2,[x19,#448]
    fmul d0,d2,d0
    fdiv d0,d0,d1
    ldr d1,[x19,#632]
    ldr d2,[x19,#640]
    ldr d3,[x19,#496]
    fmul d1,d1,d0
    fmul d2,d2,d0
    fmul d1,d1,d3
    fmul d2,d2,d3
    ldr x9,[x19,#384]
    str d1,[x9,x26,lsl #3]
    ldr x9,[x19,#392]
    str d2,[x9,x26,lsl #3]
    sub x25,x25,#1
    b .Llevel
.Lnext_column:
    add x20,x20,#1
    cmp x20,x23
    b.lt .Lcolumn
.Ldone:
    ldr x18,[x19,#736]
    ldp d14,d15,[sp,#144]
    ldp d12,d13,[sp,#128]
    ldp d10,d11,[sp,#112]
    ldp d8,d9,[sp,#96]
    ldp x27,x28,[sp,#80]
    ldp x25,x26,[sp,#64]
    ldp x23,x24,[sp,#48]
    ldp x21,x22,[sp,#32]
    ldp x19,x20,[sp,#16]
    ldp x29,x30,[sp,#0]
    add sp,sp,#1024
    ret
.Lreject:
    mov x0,#116
    bl _exit
    brk #0
.Lvalidate:
    ldr w11,[x0,x10]
    cmp w11,#0
    b.le .Lvalidate_done
    ldr x12,[x0,#352]
    cbz x12,.Lreject
    ldr x13,[x0,#392]
    cmp x13,#1
    b.ne .Lreject
    ldr x14,[x0,#400]
    ldr x15,[x0,#408]
    cmp x11,x14
    b.lt .Lreject
    cmp x11,x15
    b.gt .Lreject
    sub x11,x11,x14
    mul x11,x11,x13
    mov x13,#184
    madd x12,x11,x13,x12
    ldr w11,[x12,#136]
    cmp w11,#1
    b.lt .Lreject
    ldr w12,[x0,#216]
    cmp w11,w12
    b.gt .Lreject
    ldr x12,[x19,#376]
    cbz x12,.Lreject
.Lvalidate_done:
    ret
.Lfactor:
    ldr w11,[x0,x10]
    cmp w11,#0
    b.gt .Lfactor_active
    fmov d0,#1.0
    ret
.Lfactor_active:
    ldr x12,[x0,#352]
    ldr x13,[x0,#392]
    ldr x14,[x0,#400]
    sub x11,x11,x14
    mul x11,x11,x13
    mov x13,#184
    madd x12,x11,x13,x12
    ldr w11,[x12,#136]
    sub w11,w11,#1
    madd x11,x11,x21,x20
    ldr x9,[x19,#376]
    ldr d0,[x9,x11,lsl #3]
    ldr d1,[x12,#24]
    ldr d2,[x12,#56]
    fmul d0,d1,d0
    fadd d0,d2,d0
    mov x27,x30
    bl exp
    ret x27
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .rodata
.p2align 3
.Lconstants:
    .quad 0x3fd999999999999a
    .quad 0x3f847ae147ae147c
    .quad 0x3d19000000000000
    .quad 0x3ddb7cdfd9d7bdbb
    .quad 0x3fc999999999999a
    .quad 0x403e000000000000
    .quad 0x4072c00000000000
    .quad 0x3fb999999999999a
    .quad 0x4043800000000000
    .quad 0xbfd5555555555555
    .quad 0x3fd5555555555555
    .quad 0x3feb333333333333
    .quad 0x3f50624dd2f1a9fc
    .quad 0x412e848000000000
    .quad 0x40bf400000000000
    .quad 0x4092c00000000000
    .quad 0x4089000000000000
    .quad 0x40c7700000000000
    .quad 0x416e848000000000
    .quad 0x4103880000000000
    .quad 0x3f60624dd2f1a9fc
    .quad 0x404ca5e353f7ced9
    .quad 0x4034000000000000
    .quad 0x3f847ae147ae147b
    .quad 0x4049000000000000
.section .note.GNU-stack,"",@progbits
