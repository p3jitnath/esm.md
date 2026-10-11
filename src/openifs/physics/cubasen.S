// Physics input formulations/openifs/physics/convective_cloud_base.md.
// Contract skills/md2asm/references/openifs/physics/cubasen.md.
// Complete normal-physics parcel lifting, mixing and cloud search.
#ifndef CUBASEN_SYMBOL
#define CUBASEN_SYMBOL cubasen_
#endif
.text
.p2align 4
.global CUBASEN_SYMBOL
.type CUBASEN_SYMBOL,%function
CUBASEN_SYMBOL:
    sub sp,sp,#1536
    add x16,sp,#1344
    stp x29,x30,[x16,#0]
    stp x19,x20,[x16,#16]
    stp x21,x22,[x16,#32]
    stp x23,x24,[x16,#48]
    stp x25,x26,[x16,#64]
    stp x27,x28,[x16,#80]
    stp d8,d9,[x16,#96]
    stp d10,d11,[x16,#112]
    stp d12,d13,[x16,#128]
    stp d14,d15,[x16,#144]
    mov x28,sp
    stp x0,x1,[x28]
    stp x2,x3,[x28,#16]
    stp x4,x5,[x28,#32]
    stp x6,x7,[x28,#48]
    ldr x9,[x28,#1536]
    str x9,[x28,#64]
    ldr x9,[x28,#1544]
    str x9,[x28,#72]
    ldr x9,[x28,#1552]
    str x9,[x28,#80]
    ldr x9,[x28,#1560]
    str x9,[x28,#88]
    ldr x9,[x28,#1568]
    str x9,[x28,#96]
    ldr x9,[x28,#1576]
    str x9,[x28,#104]
    ldr x9,[x28,#1584]
    str x9,[x28,#112]
    ldr x9,[x28,#1592]
    str x9,[x28,#120]
    ldr x9,[x28,#1600]
    str x9,[x28,#128]
    ldr x9,[x28,#1608]
    str x9,[x28,#136]
    ldr x9,[x28,#1616]
    str x9,[x28,#144]
    ldr x9,[x28,#1624]
    str x9,[x28,#152]
    ldr x9,[x28,#1632]
    str x9,[x28,#160]
    ldr x9,[x28,#1640]
    str x9,[x28,#168]
    ldr x9,[x28,#1648]
    str x9,[x28,#176]
    ldr x9,[x28,#1656]
    str x9,[x28,#184]
    ldr x9,[x28,#1664]
    str x9,[x28,#192]
    ldr x9,[x28,#1672]
    str x9,[x28,#200]
    ldr x9,[x28,#1680]
    str x9,[x28,#208]
    ldr x9,[x28,#1688]
    str x9,[x28,#216]
    ldr x9,[x28,#1696]
    str x9,[x28,#224]
    ldr x9,[x28,#1704]
    str x9,[x28,#232]
    ldr x9,[x28,#1712]
    str x9,[x28,#240]
    ldr x9,[x28,#1720]
    str x9,[x28,#248]
    ldr x9,[x28,#1728]
    str x9,[x28,#256]
    ldr x9,[x28,#1736]
    str x9,[x28,#264]
    ldr x9,[x28,#1744]
    str x9,[x28,#272]
    mrs x9,fpcr
    cbnz x9,.Ldomain
    ldr w9,[x0,#4]
    cbnz w9,.Ldomain
    ldr w20,[x6]
    ldr w21,[x7]
    cmp w20,#1
    b.lt .Ldomain
    cmp w20,#4096
    b.gt .Ldomain
    cmp w21,#2
    b.lt .Ldomain
    cmp w21,#1024
    b.gt .Ldomain
    ldr w19,[x4]
    ldr w9,[x5]
    str w9,[x28,#592]
    cmp w19,w9
    b.gt .Lreturn
    cmp w19,#1
    b.lt .Ldomain
    cmp w9,w20
    b.gt .Ldomain
    sub w19,w19,#1
    ldr x9,[x28,#64]
    ldr w9,[x9]
    cmp w9,#2
    b.lt .Ldomain
    cmp w9,w21
    b.gt .Ldomain
    str w9,[x28,#536]
    ldr x9,[x28,#16]
    ldr w10,[x9,#312]
    cmp w10,#1
    b.lt .Ldomain
    cmp w10,w21
    b.ge .Ldomain
    str w10,[x28,#540]
    ldr d0,[x9,#0]
    str d0,[x28,#488]
    ldr d0,[x9,#16]
    str d0,[x28,#496]
    ldr d0,[x9,#24]
    str d0,[x28,#504]
    ldr d0,[x9,#32]
    str d0,[x28,#512]
    ldr d0,[x9,#136]
    str d0,[x28,#520]
    ldr x9,[x28,#8]
    ldr d0,[x9,#120]
    str d0,[x28,#528]
    ldr x9,[x28,#72]
    ldr w9,[x9]
    cmp w9,#1
    b.hi .Ldomain
    str w9,[x28,#584]
    adrp x9,:got:__yomcst_MOD_rg
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rg]
    ldr d0,[x9]
    str d0,[x28,#320]
    adrp x9,:got:__yomcst_MOD_rcpd
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rcpd]
    ldr d0,[x9]
    str d0,[x28,#328]
    adrp x9,:got:__yomcst_MOD_rd
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rd]
    ldr d0,[x9]
    str d0,[x28,#336]
    adrp x9,:got:__yomcst_MOD_retv
    ldr x9,[x9,:got_lo12:__yomcst_MOD_retv]
    ldr d0,[x9]
    str d0,[x28,#344]
    adrp x9,:got:__yomcst_MOD_rtt
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rtt]
    ldr d0,[x9]
    str d0,[x28,#896]
    adrp x9,:got:__yoethf_MOD_r2es
    ldr x9,[x9,:got_lo12:__yoethf_MOD_r2es]
    ldr d0,[x9]
    str d0,[x28,#352]
    adrp x9,:got:__yoethf_MOD_r3les
    ldr x9,[x9,:got_lo12:__yoethf_MOD_r3les]
    ldr d0,[x9]
    str d0,[x28,#360]
    adrp x9,:got:__yoethf_MOD_r3ies
    ldr x9,[x9,:got_lo12:__yoethf_MOD_r3ies]
    ldr d0,[x9]
    str d0,[x28,#368]
    adrp x9,:got:__yoethf_MOD_r4les
    ldr x9,[x9,:got_lo12:__yoethf_MOD_r4les]
    ldr d0,[x9]
    str d0,[x28,#376]
    adrp x9,:got:__yoethf_MOD_r4ies
    ldr x9,[x9,:got_lo12:__yoethf_MOD_r4ies]
    ldr d0,[x9]
    str d0,[x28,#384]
    adrp x9,:got:__yoethf_MOD_r5les
    ldr x9,[x9,:got_lo12:__yoethf_MOD_r5les]
    ldr d0,[x9]
    str d0,[x28,#392]
    adrp x9,:got:__yoethf_MOD_r5ies
    ldr x9,[x9,:got_lo12:__yoethf_MOD_r5ies]
    ldr d0,[x9]
    str d0,[x28,#400]
    adrp x9,:got:__yoethf_MOD_ralfdcp
    ldr x9,[x9,:got_lo12:__yoethf_MOD_ralfdcp]
    ldr d0,[x9]
    str d0,[x28,#408]
    adrp x9,:got:__yoethf_MOD_rtwat
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rtwat]
    ldr d0,[x9]
    str d0,[x28,#416]
    adrp x9,:got:__yoethf_MOD_rtice
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rtice]
    ldr d0,[x9]
    str d0,[x28,#424]
    adrp x9,:got:__yoethf_MOD_rticecu
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rticecu]
    ldr d0,[x9]
    str d0,[x28,#432]
    adrp x9,:got:__yoethf_MOD_rtwat_rticecu_r
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rtwat_rticecu_r]
    ldr d0,[x9]
    str d0,[x28,#440]
    adrp x9,:got:__yoethf_MOD_rtwat_rtice_r
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rtwat_rtice_r]
    ldr d0,[x9]
    str d0,[x28,#448]
    adrp x9,:got:__yomdyncore_MOD_rplrg
    ldr x9,[x9,:got_lo12:__yomdyncore_MOD_rplrg]
    ldr d0,[x9]
    str d0,[x28,#456]
    adrp x9,:got:__yomdyncore_MOD_rpldare
    ldr x9,[x9,:got_lo12:__yomdyncore_MOD_rpldare]
    ldr d0,[x9]
    str d0,[x28,#464]
    ldr d0,.Lc0
    ldr d1,[x28,#320]
    fdiv d1,d0,d1
    str d1,[x28,#472]
    ldr d1,[x28,#328]
    fdiv d1,d0,d1
    str d1,[x28,#480]
    str xzr,[x28,#600]
    str xzr,[x28,#608]
    ldr x9,[x28,#24]
    ldr w10,[x9]
    cmp w10,#1
    b.hi .Ldomain
    cbz w10,.Lspp_done
    ldrsw x10,[x9,#492]
    cmp x10,#0
    b.le .Lspp_ent_done
    ldr x11,[x9,#352]
    cbz x11,.Ldomain
    ldr x12,[x9,#392]
    cmp x12,#1
    b.ne .Ldomain
    ldr x12,[x9,#368]
    cmp x12,#184
    b.ne .Ldomain
    ldr x12,[x9,#400]
    cmp x10,x12
    b.lt .Ldomain
    ldr x12,[x9,#408]
    cmp x10,x12
    b.gt .Ldomain
    ldr x12,[x9,#360]
    add x10,x10,x12
    mov x12,#184
    madd x10,x10,x12,x11
    str x10,[x28,#600]
    ldr w11,[x10,#136]
    cmp w11,#1
    b.lt .Ldomain
    ldr w12,[x9,#216]
    cmp w11,w12
    b.gt .Ldomain
    str w11,[x28,#616]
.Lspp_ent_done:
    ldrsw x10,[x9,#500]
    cmp x10,#0
    b.le .Lspp_ent1_done
    ldr x11,[x9,#352]
    cbz x11,.Ldomain
    ldr x12,[x9,#392]
    cmp x12,#1
    b.ne .Ldomain
    ldr x12,[x9,#368]
    cmp x12,#184
    b.ne .Ldomain
    ldr x12,[x9,#400]
    cmp x10,x12
    b.lt .Ldomain
    ldr x12,[x9,#408]
    cmp x10,x12
    b.gt .Ldomain
    ldr x12,[x9,#360]
    add x10,x10,x12
    mov x12,#184
    madd x10,x10,x12,x11
    str x10,[x28,#608]
    ldr w11,[x10,#136]
    cmp w11,#1
    b.lt .Ldomain
    ldr w12,[x9,#216]
    cmp w11,w12
    b.gt .Ldomain
    str w11,[x28,#620]
.Lspp_ent1_done:
.Lspp_done:
    mov x9,#80
    mul x9,x9,x21
    add x9,x9,#15
    and x9,x9,#-16
    sub sp,sp,x9
    mov x27,sp
    lsl x25,x20,#3
    mov x10,x27
    lsl x11,x21,#3
    str x10,[x28,#768]
    add x10,x10,x11
    str x10,[x28,#776]
    add x10,x10,x11
    str x10,[x28,#784]
    add x10,x10,x11
    str x10,[x28,#792]
    add x10,x10,x11
    str x10,[x28,#800]
    add x10,x10,x11
    str x10,[x28,#808]
    add x10,x10,x11
    str x10,[x28,#816]
    add x10,x10,x11
    str x10,[x28,#824]
    add x10,x10,x11
    str x10,[x28,#832]
    add x10,x10,x11
    str x10,[x28,#840]
    add x10,x10,x11
    mov w9,#1
    str w9,[x28,#856]
    mov w9,#1
    str w9,[x28,#860]
    mov w9,#1
    str w9,[x28,#864]
    mov w9,#1
    str w9,[x28,#868]
.Lcolumn:
    mov w9,#1
    str w9,[x28,#544]
    mov w9,#1
    str w9,[x28,#548]
    mov w9,#0
    str w9,[x28,#552]
    ldr d0,.Lc1
    ldr x9,[x28,#208]
    str d0,[x9,x19,lsl #3]
    ldr x9,[x28,#264]
    str w21,[x9,x19,lsl #2]
    mov x23,#1
.Linitialise:
    ldr x9,[x28,#176]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x28,#768]
    sub x10,x23,#1
    str d0,[x9,x10,lsl #3]
    ldr x9,[x28,#184]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x28,#776]
    sub x10,x23,#1
    str d0,[x9,x10,lsl #3]
    ldr x9,[x28,#192]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x28,#784]
    sub x10,x23,#1
    str d0,[x9,x10,lsl #3]
    ldr x9,[x28,#216]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    ldr w11,[x9,x10,lsl #2]
    ldr x9,[x28,#840]
    sub x10,x23,#1
    add x10,x9,x10,lsl #3
    str w11,[x10]
    ldr d0,.Lc1
    ldr x9,[x28,#832]
    sub x10,x23,#1
    str d0,[x9,x10,lsl #3]
    ldr x9,[x28,#808]
    sub x10,x23,#1
    str d0,[x9,x10,lsl #3]
    ldr x9,[x28,#200]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    str d0,[x9,x10,lsl #3]
    ldr x9,[x28,#80]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    ldr d0,[x9,x10,lsl #3]
    ldr d1,[x28,#328]
    fmul d0,d0,d1
    ldr x9,[x28,#96]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    ldr d1,[x9,x10,lsl #3]
    fadd d0,d0,d1
    ldr x9,[x28,#816]
    sub x10,x23,#1
    str d0,[x9,x10,lsl #3]
    ldr x9,[x28,#88]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x28,#824]
    sub x10,x23,#1
    str d0,[x9,x10,lsl #3]
    add x23,x23,#1
    cmp x23,x21
    b.le .Linitialise
    mov x22,x21
.Ldeparture:
    ldr w9,[x28,#544]
    cbz w9,.Linner_start
    str w22,[x28,#580]
    str w22,[x28,#568]
    sub w9,w21,#1
    str w9,[x28,#572]
    str w9,[x28,#576]
    mov w9,#0
    str w9,[x28,#556]
    mov w9,#0
    str w9,[x28,#560]
    mov w9,#0
    str w9,[x28,#564]
    cmp x22,x21
    b.ne .Lelevated
    ldr x9,[x28,#144]
    sub x10,x22,#1
    madd x10,x10,x20,x19
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x28,#152]
    sub x10,x22,#1
    madd x10,x10,x20,x19
    ldr d1,[x9,x10,lsl #3]
    ldr d2,[x28,#344]
    fmul d1,d1,d2
    ldr d2,.Lc0
    fadd d1,d1,d2
    fmul d0,d0,d1
    ldr d1,[x28,#336]
    fmul d0,d1,d0
    ldr x9,[x28,#104]
    sub x10,x22,#1
    madd x10,x10,x20,x19
    add x10,x10,x20
    ldr d1,[x9,x10,lsl #3]
    fdiv d0,d1,d0
    str d0,[x28,#640]
    ldr x9,[x28,#120]
    sub x10,x22,#1
    madd x10,x10,x20,x19
    add x10,x10,x20
    ldr d0,[x9,x10,lsl #3]
    ldr d1,[x28,#480]
    fmul d0,d0,d1
    ldr d1,[x28,#344]
    ldr x9,[x28,#144]
    sub x10,x22,#1
    madd x10,x10,x20,x19
    ldr d2,[x9,x10,lsl #3]
    fmul d1,d1,d2
    ldr x9,[x28,#112]
    sub x10,x22,#1
    madd x10,x10,x20,x19
    add x10,x10,x20
    ldr d2,[x9,x10,lsl #3]
    fmul d1,d1,d2
    fadd d0,d0,d1
    ldr d1,[x28,#640]
    ldr d2,[x28,#456]
    fmul d1,d1,d2
    ldr d2,[x28,#464]
    fmul d1,d1,d2
    fdiv d0,d0,d1
    str d0,[x28,#648]
    ldr d1,.Lc1
    str d1,[x28,#624]
    str d1,[x28,#632]
    fcmp d0,#0.0
    b.mi .Lsurface_buoyant
    mov w9,#0
    str w9,[x28,#544]
    b .Linner_start
.Lsurface_buoyant:
    ldr x9,[x28,#136]
    ldr d0,[x9,x19,lsl #3]
    fsqrt d0,d0
    ldr d1,.Lc2
    fmaxnm d0,d0,d1
    ldr d1,.Lc3
    bl md2asm_pow_original_rounding_candidate
    str d0,[x28,#656]
    ldr d0,.Lc4
    ldr d1,[x28,#648]
    fmul d0,d0,d1
    ldr x9,[x28,#96]
    sub x10,x22,#1
    madd x10,x10,x20,x19
    ldr d1,[x9,x10,lsl #3]
    ldr x9,[x28,#96]
    sub x10,x22,#1
    madd x10,x10,x20,x19
    add x10,x10,x20
    ldr d2,[x9,x10,lsl #3]
    fsub d1,d1,d2
    fmul d0,d0,d1
    ldr x9,[x28,#144]
    sub x10,x22,#1
    madd x10,x10,x20,x19
    ldr d1,[x9,x10,lsl #3]
    fdiv d0,d0,d1
    ldr d1,[x28,#656]
    fsub d0,d1,d0
    ldr d1,.Lc5
    bl md2asm_pow_original_rounding_candidate
    ldr d1,.Lc6
    fmul d0,d0,d1
    str d0,[x28,#656]
    ldr d0,.Lc7
    ldr x9,[x28,#120]
    sub x10,x22,#1
    madd x10,x10,x20,x19
    add x10,x10,x20
    ldr d1,[x9,x10,lsl #3]
    fmul d0,d0,d1
    ldr d1,[x28,#640]
    ldr d2,[x28,#656]
    fmul d1,d1,d2
    ldr d2,[x28,#328]
    fmul d1,d1,d2
    ldr d2,[x28,#456]
    fmul d1,d1,d2
    ldr d2,[x28,#464]
    fmul d1,d1,d2
    fdiv d0,d0,d1
    ldr d1,.Lc8
    fmaxnm d0,d0,d1
    str d0,[x28,#624]
    str d0,[x28,#712]
    ldr d0,.Lc7
    ldr x9,[x28,#112]
    sub x10,x22,#1
    madd x10,x10,x20,x19
    add x10,x10,x20
    ldr d1,[x9,x10,lsl #3]
    fmul d0,d0,d1
    ldr d1,[x28,#640]
    ldr d2,[x28,#656]
    fmul d1,d1,d2
    ldr d2,[x28,#456]
    fmul d1,d1,d2
    ldr d2,[x28,#464]
    fmul d1,d1,d2
    fdiv d0,d0,d1
    ldr d1,.Lc9
    fmaxnm d0,d0,d1
    str d0,[x28,#632]
    str d0,[x28,#704]
    ldr d0,[x28,#656]
    fmul d0,d0,d0
    ldr d1,.Lc2
    fadd d0,d0,d1
    ldr x9,[x28,#808]
    sub x10,x22,#1
    str d0,[x9,x10,lsl #3]
    ldr x9,[x28,#200]
    sub x10,x22,#1
    madd x10,x10,x20,x19
    str d0,[x9,x10,lsl #3]
    b .Ldeparture_values
.Lelevated:
    ldr d0,.Lc8
    str d0,[x28,#712]
    ldr d0,.Lc9
    str d0,[x28,#704]
    sub x9,x21,#1
    cmp x22,x9
    b.ne .Lelevated_excess_done
    ldr d0,[x28,#624]
    ldr d1,.Lc8
    fmaxnm d0,d0,d1
    ldr d1,.Lc0
    fminnm d0,d0,d1
    str d0,[x28,#712]
    ldr d0,[x28,#632]
    ldr d1,.Lc9
    fmaxnm d0,d0,d1
    ldr d1,.Lc10
    fminnm d0,d0,d1
    str d0,[x28,#704]
.Lelevated_excess_done:
    ldr d0,.Lc0
    ldr x9,[x28,#808]
    sub x10,x22,#1
    str d0,[x9,x10,lsl #3]
.Ldeparture_values:
    mov w11,#1
    ldr x9,[x28,#840]
    sub x10,x22,#1
    add x10,x9,x10,lsl #3
    str w11,[x10]
    ldr x9,[x28,#824]
    sub x10,x22,#1
    ldr d0,[x9,x10,lsl #3]
    ldr d1,[x28,#704]
    fadd d0,d0,d1
    ldr x9,[x28,#776]
    sub x10,x22,#1
    str d0,[x9,x10,lsl #3]
    ldr x9,[x28,#816]
    sub x10,x22,#1
    ldr d0,[x9,x10,lsl #3]
    ldr d1,[x28,#328]
    ldr d2,[x28,#712]
    fmul d1,d1,d2
    fadd d0,d0,d1
    ldr x9,[x28,#792]
    sub x10,x22,#1
    str d0,[x9,x10,lsl #3]
    ldr x9,[x28,#816]
    sub x10,x22,#1
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x28,#96]
    sub x10,x22,#1
    madd x10,x10,x20,x19
    ldr d1,[x9,x10,lsl #3]
    fsub d0,d0,d1
    ldr d1,[x28,#480]
    fmul d0,d0,d1
    ldr d1,[x28,#712]
    fadd d0,d0,d1
    ldr x9,[x28,#768]
    sub x10,x22,#1
    str d0,[x9,x10,lsl #3]
    ldr d0,.Lc1
    ldr x9,[x28,#784]
    sub x10,x22,#1
    str d0,[x9,x10,lsl #3]
    cmp x22,x21
    b.eq .Ldeparture_buoyancy
    ldr x9,[x28,#104]
    sub x10,x21,#1
    madd x10,x10,x20,x19
    add x10,x10,x20
    ldr d0,[x9,x10,lsl #3]
    mov x23,x22
    sub x23,x23,#1
    ldr x9,[x28,#104]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    ldr d1,[x9,x10,lsl #3]
    fsub d0,d0,d1
    ldr d1,.Lc11
    fcmp d0,d1
    b.ge .Ldeparture_buoyancy
    ldr d0,.Lc1
    str d0,[x28,#720]
    str d0,[x28,#728]
    str d0,[x28,#736]
    add x23,x22,#1
.Lweighted_mix:
    ldr d0,[x28,#736]
    ldr d1,.Lc12
    fcmp d0,d1
    b.ge .Lweighted_skip
    ldr x9,[x28,#104]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x28,#104]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    sub x10,x10,x20
    ldr d1,[x9,x10,lsl #3]
    fsub d0,d0,d1
    str d0,[x28,#744]
    ldr d1,[x28,#736]
    fadd d1,d1,d0
    str d1,[x28,#736]
    ldr x9,[x28,#824]
    sub x10,x23,#1
    ldr d1,[x9,x10,lsl #3]
    fmul d1,d1,d0
    ldr d2,[x28,#720]
    fadd d1,d2,d1
    str d1,[x28,#720]
    ldr x9,[x28,#816]
    sub x10,x23,#1
    ldr d1,[x9,x10,lsl #3]
    fmul d1,d1,d0
    ldr d2,[x28,#728]
    fadd d1,d2,d1
    str d1,[x28,#728]
.Lweighted_skip:
    sub x23,x23,#1
    sub x9,x22,#1
    cmp x23,x9
    b.ge .Lweighted_mix
    ldr d0,[x28,#720]
    ldr d1,[x28,#736]
    fdiv d0,d0,d1
    ldr d1,[x28,#704]
    fadd d0,d0,d1
    ldr x9,[x28,#776]
    sub x10,x22,#1
    str d0,[x9,x10,lsl #3]
    ldr d0,[x28,#728]
    ldr d1,[x28,#736]
    fdiv d0,d0,d1
    ldr d1,[x28,#328]
    ldr d2,[x28,#712]
    fmul d1,d1,d2
    fadd d0,d0,d1
    ldr x9,[x28,#792]
    sub x10,x22,#1
    str d0,[x9,x10,lsl #3]
    ldr x9,[x28,#96]
    sub x10,x22,#1
    madd x10,x10,x20,x19
    ldr d1,[x9,x10,lsl #3]
    fsub d0,d0,d1
    ldr d1,[x28,#480]
    fmul d0,d0,d1
    ldr d1,[x28,#712]
    fadd d0,d0,d1
    ldr x9,[x28,#768]
    sub x10,x22,#1
    str d0,[x9,x10,lsl #3]
.Ldeparture_buoyancy:
    ldr x9,[x28,#824]
    sub x10,x22,#1
    ldr d0,[x9,x10,lsl #3]
    ldr d1,[x28,#344]
    fmul d0,d0,d1
    ldr d2,.Lc0
    fadd d0,d0,d2
    ldr x9,[x28,#816]
    sub x10,x22,#1
    ldr d1,[x9,x10,lsl #3]
    ldr x9,[x28,#96]
    sub x10,x22,#1
    madd x10,x10,x20,x19
    ldr d2,[x9,x10,lsl #3]
    fsub d1,d1,d2
    fmul d0,d0,d1
    ldr d1,[x28,#480]
    fmul d0,d0,d1
    str d0,[x28,#720]
    ldr x9,[x28,#776]
    sub x10,x22,#1
    ldr d0,[x9,x10,lsl #3]
    ldr d1,[x28,#344]
    fmul d0,d0,d1
    ldr d1,.Lc0
    fadd d0,d0,d1
    ldr x9,[x28,#768]
    sub x10,x22,#1
    ldr d1,[x9,x10,lsl #3]
    fmul d0,d0,d1
    ldr d1,[x28,#720]
    fsub d0,d0,d1
    ldr d2,[x28,#320]
    fmul d0,d0,d2
    fdiv d0,d0,d1
    ldr x9,[x28,#800]
    sub x10,x22,#1
    str d0,[x9,x10,lsl #3]
.Linner_start:
    sub x23,x22,#1
.Lascent:
    ldr w9,[x28,#540]
    cmp w23,w9
    b.lt .Ldeparture_finish
    ldr w9,[x28,#544]
    cbz w9,.Ldeparture_finish
    ldr x9,[x28,#96]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x28,#96]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    add x10,x10,x20
    ldr d1,[x9,x10,lsl #3]
    fsub d0,d0,d1
    ldr d1,[x28,#472]
    fmul d0,d0,d1
    str d0,[x28,#672]
    cmp x22,x21
    b.eq .Lshallow
    ldr w9,[x28,#536]
    sub w10,w21,#1
    cmp w9,w10
    b.eq .Lshallow
    b .Ldeep_mix
.Lshallow:
    ldr d0,[x28,#496]
    str d0,[x28,#752]
    ldr x9,[x28,#608]
    cbz x9,.Lshallow_parameter
    ldr d0,[x9,#56]
    ldr d1,[x9,#24]
    ldr w10,[x28,#620]
    sub x10,x10,#1
    madd x10,x10,x20,x19
    ldr x9,[x28,#128]
    ldr d2,[x9,x10,lsl #3]
    fmul d1,d1,d2
    fadd d0,d0,d1
    bl exp
    ldr d1,[x28,#496]
    fmul d0,d1,d0
    str d0,[x28,#752]
.Lshallow_parameter:
    ldr x9,[x28,#168]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x28,#96]
    sub x10,x21,#1
    madd x10,x10,x20,x19
    add x10,x10,x20
    ldr d1,[x9,x10,lsl #3]
    fsub d0,d0,d1
    ldr d1,[x28,#472]
    fmul d0,d0,d1
    ldr d1,[x28,#456]
    fmul d0,d0,d1
    ldr d1,[x28,#752]
    fdiv d0,d1,d0
    ldr d1,[x28,#504]
    fadd d0,d0,d1
    str d0,[x28,#752]
    ldr w9,[x28,#584]
    cbz w9,.Lshallow_epsilon
    ldr w9,[x28,#536]
    cmp w9,w21
    b.ne .Lshallow_epsilon
    ldr x9,[x28,#784]
    sub x10,x23,#1
    add x10,x10,#1
    ldr d1,[x9,x10,lsl #3]
    fcmp d1,#0.0
    b.le .Lshallow_epsilon
    ldr d1,[x28,#512]
    fmul d0,d0,d1
    str d0,[x28,#752]
.Lshallow_epsilon:
    ldr d0,.Lc13
    ldr d1,[x28,#672]
    fmul d0,d0,d1
    ldr d1,[x28,#456]
    fmul d0,d0,d1
    ldr d1,[x28,#752]
    fmul d0,d0,d1
    ldr d1,.Lc0
    fminnm d0,d1,d0
    str d0,[x28,#664]
    ldr d1,.Lc0
    fadd d2,d1,d0
    fdiv d2,d1,d2
    str d2,[x28,#752]
    ldr x9,[x28,#776]
    sub x10,x23,#1
    add x10,x10,#1
    ldr d0,[x9,x10,lsl #3]
    ldr d1,[x28,#664]
    ldr d2,.Lc0
    fsub d2,d2,d1
    fmul d0,d0,d2
    str d0,[x28,#720]
    ldr x9,[x28,#88]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    add x10,x10,x20
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x28,#88]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    ldr d1,[x9,x10,lsl #3]
    fadd d0,d0,d1
    ldr d1,.Lc13
    fmul d0,d0,d1
    ldr d1,.Lc14
    ldr d2,[x28,#664]
    fmul d1,d1,d2
    fmul d0,d1,d0
    ldr d1,[x28,#720]
    fadd d0,d1,d0
    ldr d1,[x28,#752]
    fmul d0,d0,d1
    ldr x9,[x28,#776]
    sub x10,x23,#1
    str d0,[x9,x10,lsl #3]
    ldr x9,[x28,#792]
    sub x10,x23,#1
    add x10,x10,#1
    ldr d0,[x9,x10,lsl #3]
    ldr d1,[x28,#664]
    ldr d2,.Lc0
    fsub d2,d2,d1
    fmul d0,d0,d2
    str d0,[x28,#720]
    ldr x9,[x28,#816]
    sub x10,x23,#1
    add x10,x10,#1
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x28,#816]
    sub x10,x23,#1
    ldr d1,[x9,x10,lsl #3]
    fadd d0,d0,d1
    ldr d1,.Lc13
    fmul d0,d0,d1
    ldr d1,.Lc14
    ldr d2,[x28,#664]
    fmul d1,d1,d2
    fmul d0,d1,d0
    ldr d1,[x28,#720]
    fadd d0,d1,d0
    ldr d1,[x28,#752]
    fmul d0,d0,d1
    ldr x9,[x28,#792]
    sub x10,x23,#1
    str d0,[x9,x10,lsl #3]
    b .Lmixed_parcel
.Ldeep_mix:
    ldr d0,[x28,#488]
    str d0,[x28,#752]
    ldr x9,[x28,#600]
    cbz x9,.Ldeep_parameter
    ldr d0,[x9,#56]
    ldr d1,[x9,#24]
    ldr w10,[x28,#616]
    sub x10,x10,#1
    madd x10,x10,x20,x19
    ldr x9,[x28,#128]
    ldr d2,[x9,x10,lsl #3]
    fmul d1,d1,d2
    fadd d0,d0,d1
    bl exp
    ldr d1,[x28,#488]
    fmul d0,d1,d0
    str d0,[x28,#752]
.Ldeep_parameter:
    ldr x9,[x28,#160]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x28,#160]
    sub x10,x21,#1
    madd x10,x10,x20,x19
    ldr d1,[x9,x10,lsl #3]
    fdiv d0,d0,d1
    fmul d1,d0,d0
    fmul d0,d1,d0
    ldr d1,.Lc0
    fminnm d0,d1,d0
    str d0,[x28,#720]
    ldr d0,.Lc15
    ldr d1,[x28,#752]
    fmul d0,d0,d1
    ldr d1,[x28,#672]
    fmul d0,d0,d1
    ldr d1,[x28,#720]
    fmul d0,d0,d1
    ldr d1,.Lc0
    fminnm d0,d1,d0
    str d0,[x28,#664]
    ldr x9,[x28,#776]
    sub x10,x23,#1
    add x10,x10,#1
    ldr d0,[x9,x10,lsl #3]
    ldr d1,[x28,#664]
    ldr d2,.Lc0
    fsub d2,d2,d1
    fmul d0,d0,d2
    str d0,[x28,#720]
    ldr x9,[x28,#88]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    add x10,x10,x20
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x28,#88]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    ldr d1,[x9,x10,lsl #3]
    fadd d0,d0,d1
    ldr d1,.Lc13
    fmul d0,d0,d1
    ldr d1,[x28,#664]
    fmul d0,d0,d1
    ldr d1,[x28,#720]
    fadd d0,d1,d0
    ldr x9,[x28,#776]
    sub x10,x23,#1
    str d0,[x9,x10,lsl #3]
    ldr x9,[x28,#792]
    sub x10,x23,#1
    add x10,x10,#1
    ldr d0,[x9,x10,lsl #3]
    ldr d1,[x28,#664]
    ldr d2,.Lc0
    fsub d2,d2,d1
    fmul d0,d0,d2
    str d0,[x28,#720]
    ldr x9,[x28,#816]
    sub x10,x23,#1
    add x10,x10,#1
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x28,#816]
    sub x10,x23,#1
    ldr d1,[x9,x10,lsl #3]
    fadd d0,d0,d1
    ldr d1,.Lc13
    fmul d0,d0,d1
    ldr d1,[x28,#664]
    fmul d0,d0,d1
    ldr d1,[x28,#720]
    fadd d0,d1,d0
    ldr x9,[x28,#792]
    sub x10,x23,#1
    str d0,[x9,x10,lsl #3]
.Lmixed_parcel:
    ldr x9,[x28,#776]
    sub x10,x23,#1
    ldr d0,[x9,x10,lsl #3]
    str d0,[x28,#680]
    ldr x9,[x28,#792]
    sub x10,x23,#1
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x28,#96]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    ldr d1,[x9,x10,lsl #3]
    fsub d0,d0,d1
    ldr d1,[x28,#480]
    fmul d0,d0,d1
    ldr x9,[x28,#768]
    sub x10,x23,#1
    str d0,[x9,x10,lsl #3]
    ldr x9,[x28,#104]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    ldr d0,[x9,x10,lsl #3]
    str d0,[x28,#872]
    str w23,[x28,#868]
    mov w9,#1
    str w9,[x28,#880]
    sub sp,sp,#32
    ldr x9,[x28,#776]
    str x9,[sp]
    add x9,x28,#544
    str x9,[sp,#8]
    add x9,x28,#880
    str x9,[sp,#16]
    str xzr,[sp,#24]
    ldr x0,[x28,#0]
    add x1,x28,#856
    add x2,x28,#860
    add x3,x28,#864
    ldr x4,[x28,#56]
    add x5,x28,#868
    add x6,x28,#872
    ldr x7,[x28,#768]
    bl md2asm_cuadjtq
    add sp,sp,#32
    ldr d0,[x28,#680]
    ldr x9,[x28,#776]
    sub x10,x23,#1
    ldr d1,[x9,x10,lsl #3]
    fsub d0,d0,d1
    ldr d1,.Lc1
    fmaxnm d0,d0,d1
    str d0,[x28,#752]
    ldr x9,[x28,#784]
    sub x10,x23,#1
    add x10,x10,#1
    ldr d1,[x9,x10,lsl #3]
    fadd d0,d1,d0
    ldr x9,[x28,#784]
    sub x10,x23,#1
    str d0,[x9,x10,lsl #3]
    ldr x9,[x28,#768]
    sub x10,x23,#1
    ldr d0,[x9,x10,lsl #3]
    ldr d6,.Lc0
    ldr d5,[x28,#416]
    fminnm d0,d0,d5
    ldr d5,[x28,#432]
    fmaxnm d0,d0,d5
    fsub d0,d0,d5
    ldr d5,[x28,#440]
    fmul d0,d0,d5
    fmul d0,d0,d0
    fminnm d0,d0,d6
    ldr d1,.Lc0
    fsub d0,d1,d0
    str d0,[x28,#720]
    ldr x9,[x28,#768]
    sub x10,x23,#1
    add x10,x10,#1
    ldr d0,[x9,x10,lsl #3]
    ldr d6,.Lc0
    ldr d5,[x28,#416]
    fminnm d0,d0,d5
    ldr d5,[x28,#432]
    fmaxnm d0,d0,d5
    fsub d0,d0,d5
    ldr d5,[x28,#440]
    fmul d0,d0,d5
    fmul d0,d0,d0
    fminnm d0,d0,d6
    ldr d1,.Lc0
    fsub d0,d1,d0
    ldr d1,[x28,#720]
    fsub d0,d1,d0
    ldr d1,[x28,#752]
    fmul d0,d1,d0
    str d0,[x28,#688]
    ldr x9,[x28,#784]
    sub x10,x23,#1
    ldr d0,[x9,x10,lsl #3]
    ldr d1,.Lc13
    fmul d0,d1,d0
    ldr x9,[x28,#784]
    sub x10,x23,#1
    str d0,[x9,x10,lsl #3]
    ldr x9,[x28,#768]
    sub x10,x23,#1
    ldr d0,[x9,x10,lsl #3]
    ldr d1,[x28,#408]
    ldr d2,[x28,#688]
    fmul d1,d1,d2
    fadd d0,d0,d1
    ldr x9,[x28,#768]
    sub x10,x23,#1
    str d0,[x9,x10,lsl #3]
    ldr d1,[x28,#328]
    fmul d0,d1,d0
    ldr x9,[x28,#96]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    ldr d1,[x9,x10,lsl #3]
    fadd d0,d0,d1
    ldr x9,[x28,#792]
    sub x10,x23,#1
    str d0,[x9,x10,lsl #3]
    ldr x9,[x28,#776]
    sub x10,x23,#1
    ldr d0,[x9,x10,lsl #3]
    ldr d1,[x28,#344]
    fmul d0,d0,d1
    ldr d1,.Lc0
    fadd d0,d1,d0
    ldr x9,[x28,#784]
    sub x10,x23,#1
    ldr d1,[x9,x10,lsl #3]
    fsub d0,d0,d1
    ldr x9,[x28,#768]
    sub x10,x23,#1
    ldr d1,[x9,x10,lsl #3]
    fmul d0,d0,d1
    ldr d1,[x28,#408]
    ldr d2,[x28,#688]
    fmul d1,d1,d2
    fadd d0,d0,d1
    str d0,[x28,#720]
    ldr x9,[x28,#824]
    sub x10,x23,#1
    ldr d0,[x9,x10,lsl #3]
    ldr d1,[x28,#344]
    fmul d0,d0,d1
    ldr d1,.Lc0
    fadd d0,d1,d0
    ldr x9,[x28,#816]
    sub x10,x23,#1
    ldr d1,[x9,x10,lsl #3]
    ldr x9,[x28,#96]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    ldr d2,[x9,x10,lsl #3]
    fsub d1,d1,d2
    fmul d0,d0,d1
    ldr d1,[x28,#480]
    fmul d0,d0,d1
    str d0,[x28,#728]
    ldr d1,[x28,#720]
    fsub d1,d1,d0
    ldr d2,[x28,#320]
    fmul d1,d1,d2
    fdiv d0,d1,d0
    ldr x9,[x28,#800]
    sub x10,x23,#1
    str d0,[x9,x10,lsl #3]
    ldr x9,[x28,#800]
    sub x10,x23,#1
    add x10,x10,#1
    ldr d1,[x9,x10,lsl #3]
    fadd d0,d0,d1
    ldr d1,.Lc13
    fmul d0,d0,d1
    str d0,[x28,#696]
    ldr d0,.Lc14
    ldr d1,[x28,#664]
    fmul d0,d0,d1
    ldr d1,.Lc0
    fadd d2,d1,d0
    fdiv d2,d1,d2
    fsub d0,d1,d0
    ldr x9,[x28,#808]
    sub x10,x23,#1
    add x10,x10,#1
    ldr d1,[x9,x10,lsl #3]
    fmul d0,d1,d0
    str d0,[x28,#720]
    str d2,[x28,#728]
    ldr d0,.Lc14
    ldr d1,[x28,#696]
    fmul d0,d0,d1
    ldr d1,[x28,#672]
    fmul d0,d0,d1
    ldr d1,[x28,#720]
    fadd d0,d1,d0
    ldr d1,[x28,#728]
    fmul d0,d0,d1
    ldr x9,[x28,#808]
    sub x10,x23,#1
    str d0,[x9,x10,lsl #3]
    cmp x22,x21
    b.ne .Lsave_surface_done
    ldr x9,[x28,#200]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    str d0,[x9,x10,lsl #3]
.Lsave_surface_done:
    ldr d0,[x28,#696]
    ldr d1,[x28,#672]
    fmul d0,d0,d1
    ldr d1,.Lc1
    fmaxnm d0,d1,d0
    ldr x9,[x28,#832]
    sub x10,x22,#1
    ldr d1,[x9,x10,lsl #3]
    fadd d0,d1,d0
    ldr x9,[x28,#832]
    sub x10,x22,#1
    str d0,[x9,x10,lsl #3]
    ldr x9,[x28,#784]
    sub x10,x23,#1
    ldr d0,[x9,x10,lsl #3]
    fcmp d0,#0.0
    b.le .Lcloud_base_done
    ldr x9,[x28,#840]
    sub x10,x23,#1
    add x10,x10,#1
    add x10,x9,x10,lsl #3
    ldr w11,[x10]
    cmp w11,#1
    b.ne .Lcloud_base_done
    ldr x9,[x28,#768]
    sub x10,x23,#1
    add x10,x10,#1
    ldr d0,[x9,x10,lsl #3]
    str d0,[x28,#720]
    ldr d6,.Lc0
    ldr d5,[x28,#416]
    fminnm d0,d0,d5
    ldr d5,[x28,#424]
    fmaxnm d0,d0,d5
    fsub d0,d0,d5
    ldr d5,[x28,#448]
    fmul d0,d0,d5
    fmul d0,d0,d0
    fminnm d0,d0,d6
    str d0,[x28,#728]
    ldr d0,[x28,#720]
    ldr d1,[x28,#376]
    fsub d1,d0,d1
    ldr d2,[x28,#360]
    ldr d3,[x28,#896]
    fsub d0,d0,d3
    fmul d0,d2,d0
    fdiv d0,d0,d1
    bl exp
    str d0,[x28,#736]
    ldr d0,[x28,#720]
    ldr d1,[x28,#384]
    fsub d1,d0,d1
    ldr d2,[x28,#368]
    ldr d3,[x28,#896]
    fsub d0,d0,d3
    fmul d0,d2,d0
    fdiv d0,d0,d1
    bl exp
    ldr d1,[x28,#728]
    ldr d2,.Lc0
    fsub d2,d2,d1
    fmul d0,d2,d0
    ldr d2,[x28,#736]
    fmul d1,d1,d2
    fadd d0,d1,d0
    ldr d1,[x28,#352]
    fmul d0,d1,d0
    ldr x9,[x28,#104]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    add x10,x10,x20
    ldr d1,[x9,x10,lsl #3]
    fdiv d0,d0,d1
    str d0,[x28,#744]
    ldr d1,.Lc13
    fminnm d0,d1,d0
    ldr d1,[x28,#344]
    fmul d1,d1,d0
    ldr d2,.Lc0
    fsub d1,d2,d1
    fdiv d1,d2,d1
    fmul d0,d0,d1
    str d0,[x28,#752]
    ldr x9,[x28,#776]
    sub x10,x23,#1
    add x10,x10,#1
    ldr d1,[x9,x10,lsl #3]
    fsub d0,d1,d0
    ldr d1,.Lc1
    fminnm d0,d1,d0
    str d0,[x28,#888]
    ldr d0,[x28,#720]
    ldr d1,[x28,#376]
    fsub d0,d0,d1
    fmul d0,d0,d0
    ldr d1,[x28,#392]
    fdiv d0,d1,d0
    str d0,[x28,#736]
    ldr d0,[x28,#720]
    ldr d1,[x28,#384]
    fsub d0,d0,d1
    fmul d0,d0,d0
    ldr d1,[x28,#400]
    fdiv d0,d1,d0
    ldr d1,[x28,#728]
    ldr d2,.Lc0
    fsub d2,d2,d1
    fmul d0,d2,d0
    ldr d2,[x28,#736]
    fmul d1,d1,d2
    fadd d0,d1,d0
    str d0,[x28,#736]
    ldr d1,[x28,#344]
    ldr d2,[x28,#744]
    fmul d1,d1,d2
    ldr d2,.Lc0
    fsub d1,d2,d1
    fdiv d1,d2,d1
    fmul d0,d0,d1
    ldr d1,[x28,#752]
    fmul d0,d0,d1
    str d0,[x28,#736]
    ldr d0,[x28,#336]
    ldr d1,[x28,#720]
    fmul d0,d0,d1
    ldr d1,[x28,#328]
    ldr x9,[x28,#104]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    add x10,x10,x20
    ldr d2,[x9,x10,lsl #3]
    fmul d1,d1,d2
    fdiv d0,d0,d1
    ldr d1,[x28,#736]
    fmul d0,d1,d0
    ldr d1,[x28,#888]
    fdiv d0,d1,d0
    ldr x9,[x28,#104]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    add x10,x10,x20
    ldr d1,[x9,x10,lsl #3]
    fadd d0,d1,d0
    str d0,[x28,#736]
    ldr x9,[x28,#104]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    ldr d1,[x9,x10,lsl #3]
    fsub d1,d0,d1
    ldr x9,[x28,#104]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    add x10,x10,x20
    ldr d2,[x9,x10,lsl #3]
    fsub d2,d2,d0
    fcmp d1,d2
    b.le .Lupper_cloud_base
    ldr x9,[x28,#808]
    sub x10,x23,#1
    add x10,x10,#1
    ldr d0,[x9,x10,lsl #3]
    fcmp d0,#0.0
    b.le .Lcloud_base_done
    sub x11,x21,#1
    add x12,x23,#1
    cmp x11,x12
    csel x12,x11,x12,le
    mov w11,#2
    ldr x9,[x28,#840]
    sub x10,x12,#1
    add x10,x9,x10,lsl #3
    str w11,[x10]
    ldr x9,[x28,#840]
    sub x10,x23,#1
    add x10,x9,x10,lsl #3
    str w11,[x10]
    str w12,[x28,#568]
    str w12,[x28,#576]
    mov w9,#1
    str w9,[x28,#560]
    mov w9,#1
    str w9,[x28,#564]
    ldr d0,[x28,#528]
    ldr x9,[x28,#784]
    sub x10,x23,#1
    add x10,x10,#1
    str d0,[x9,x10,lsl #3]
    b .Lcloud_base_done
.Lupper_cloud_base:
    ldr x9,[x28,#808]
    sub x10,x23,#1
    ldr d0,[x9,x10,lsl #3]
    fcmp d0,#0.0
    b.le .Lcloud_base_done
    mov w11,#2
    ldr x9,[x28,#840]
    sub x10,x23,#1
    add x10,x9,x10,lsl #3
    str w11,[x10]
    str w23,[x28,#568]
    str w23,[x28,#576]
    mov w9,#1
    str w9,[x28,#560]
    mov w9,#1
    str w9,[x28,#564]
.Lcloud_base_done:
    ldr x9,[x28,#808]
    sub x10,x23,#1
    ldr d0,[x9,x10,lsl #3]
    fcmp d0,#0.0
    b.mi .Lkinetic_stop
    ldr x9,[x28,#784]
    sub x10,x23,#1
    ldr d0,[x9,x10,lsl #3]
    fcmp d0,#0.0
    mov w11,#1
    mov w12,#2
    csel w11,w12,w11,gt
    ldr x9,[x28,#840]
    sub x10,x23,#1
    add x10,x9,x10,lsl #3
    str w11,[x10]
    b .Lascent_next
.Lkinetic_stop:
    mov w9,#0
    str w9,[x28,#544]
    ldr x9,[x28,#784]
    sub x10,x23,#1
    add x10,x10,#1
    ldr d0,[x9,x10,lsl #3]
    fcmp d0,#0.0
    b.le .Lstop_dry
    str w23,[x28,#572]
    mov w9,#1
    str w9,[x28,#556]
    b .Lascent_next
.Lstop_dry:
    mov w9,#0
    str w9,[x28,#556]
.Lascent_next:
    sub x23,x23,#1
    b .Lascent
.Ldeparture_finish:
    cmp x22,x21
    b.eq .Lsurface_finish
    sub x9,x21,#1
    cmp x22,x9
    b.ne .Ldeep_finish
    ldr w10,[x28,#536]
    cmp w10,w9
    b.ne .Ldeep_finish
.Lsurface_finish:
    ldr w11,[x28,#560]
    ldr x9,[x28,#232]
    str w11,[x9,x19,lsl #2]
    cbz w11,.Lno_sc
    ldr w11,[x28,#576]
    ldr x9,[x28,#248]
    str w11,[x9,x19,lsl #2]
    b .Lsc_done
.Lno_sc:
    mov w11,#-1
    ldr x9,[x28,#248]
    str w11,[x9,x19,lsl #2]
.Lsc_done:
    ldr w23,[x28,#568]
    ldr x9,[x28,#104]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    ldr d0,[x9,x10,lsl #3]
    ldr w23,[x28,#572]
    ldr x9,[x28,#104]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    ldr d1,[x9,x10,lsl #3]
    fsub d0,d0,d1
    ldr d1,[x28,#520]
    fcmp d0,d1
    b.le .Ldepth_limit_done
    ldr w9,[x28,#536]
    sub w10,w21,#1
    cmp w9,w10
    b.ge .Ldepth_limit_done
    mov w9,#0
    str w9,[x28,#556]
.Ldepth_limit_done:
    mov w9,#0
    str w9,[x28,#552]
    mov w9,#1
    str w9,[x28,#544]
    ldr w9,[x28,#536]
    sub w10,w21,#1
    cmp w9,w10
    b.ne .Lsurface_go_done
    ldr w9,[x28,#556]
    eor w9,w9,#1
    str w9,[x28,#544]
.Lsurface_go_done:
    ldr w11,[x28,#556]
    cbz w11,.Lno_convection
    ldr x9,[x28,#224]
    str w11,[x9,x19,lsl #2]
    ldr w11,[x28,#568]
    ldr x9,[x28,#240]
    str w11,[x9,x19,lsl #2]
    ldr w11,[x28,#572]
    ldr x9,[x28,#256]
    str w11,[x9,x19,lsl #2]
    ldr w11,[x28,#580]
    ldr x9,[x28,#264]
    str w11,[x9,x19,lsl #2]
    ldr w23,[x28,#568]
    ldr x9,[x28,#808]
    sub x10,x23,#1
    ldr d0,[x9,x10,lsl #3]
    ldr d1,.Lc1
    fmaxnm d0,d0,d1
    fsqrt d0,d0
    ldr x9,[x28,#208]
    str d0,[x9,x19,lsl #3]
    b .Lsurface_fields
.Lno_convection:
    mov w11,#-1
    ldr x9,[x28,#256]
    str w11,[x9,x19,lsl #2]
    ldr x9,[x28,#240]
    str w11,[x9,x19,lsl #2]
    sub w11,w21,#1
    ldr x9,[x28,#264]
    str w11,[x9,x19,lsl #2]
    mov w11,#0
    ldr x9,[x28,#224]
    str w11,[x9,x19,lsl #2]
    ldr d0,.Lc1
    ldr x9,[x28,#208]
    str d0,[x9,x19,lsl #3]
.Lsurface_fields:
    mov x23,x21
.Lsurface_copy:
    ldr w9,[x28,#572]
    cmp w23,w9
    b.ge .Lsurface_copy_cell
    ldr w9,[x28,#536]
    sub w10,w21,#1
    cmp w9,w10
    b.lt .Lsurface_copy_skip
    cmp x22,x21
    b.ne .Lsurface_copy_skip
.Lsurface_copy_cell:
    ldr x9,[x28,#768]
    sub x10,x23,#1
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x28,#176]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    str d0,[x9,x10,lsl #3]
    ldr x9,[x28,#776]
    sub x10,x23,#1
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x28,#184]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    str d0,[x9,x10,lsl #3]
    ldr x9,[x28,#784]
    sub x10,x23,#1
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x28,#192]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    str d0,[x9,x10,lsl #3]
    ldr x9,[x28,#840]
    sub x10,x23,#1
    add x10,x9,x10,lsl #3
    ldr w11,[x10]
    ldr x9,[x28,#216]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    str w11,[x9,x10,lsl #2]
.Lsurface_copy_skip:
    sub x23,x23,#1
    cbnz x23,.Lsurface_copy
.Ldeep_finish:
    cmp x22,x21
    b.ge .Ldeparture_next
    ldr w9,[x28,#552]
    cbnz w9,.Ldeep_decision
    ldr w23,[x28,#568]
    ldr x9,[x28,#104]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    ldr d0,[x9,x10,lsl #3]
    ldr w23,[x28,#572]
    ldr x9,[x28,#104]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    ldr d1,[x9,x10,lsl #3]
    fsub d0,d0,d1
    ldr d1,[x28,#520]
    fcmp d0,d1
    cset w9,ge
    str w9,[x28,#552]
.Ldeep_decision:
    ldr w9,[x28,#552]
    cbz w9,.Ldeep_continue
    ldr w9,[x28,#548]
    cbz w9,.Ldeep_hold
    mov x23,x21
.Lreset_fields:
    ldr w9,[x28,#580]
    cmp w23,w9
    b.gt .Lreset_environment
    ldr w9,[x28,#572]
    cmp w23,w9
    b.lt .Lreset_environment
    ldr x9,[x28,#768]
    sub x10,x23,#1
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x28,#176]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    str d0,[x9,x10,lsl #3]
    ldr x9,[x28,#776]
    sub x10,x23,#1
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x28,#184]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    str d0,[x9,x10,lsl #3]
    ldr x9,[x28,#784]
    sub x10,x23,#1
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x28,#192]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    str d0,[x9,x10,lsl #3]
    ldr x9,[x28,#840]
    sub x10,x23,#1
    add x10,x9,x10,lsl #3
    ldr w11,[x10]
    b .Lreset_label
.Lreset_environment:
    ldr x9,[x28,#80]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x28,#176]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    str d0,[x9,x10,lsl #3]
    ldr x9,[x28,#88]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x28,#184]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    str d0,[x9,x10,lsl #3]
    ldr d0,.Lc1
    ldr x9,[x28,#192]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    str d0,[x9,x10,lsl #3]
    ldr w9,[x28,#572]
    cmp w23,w9
    mov w11,#1
    csel w11,wzr,w11,lt
.Lreset_label:
    ldr x9,[x28,#216]
    sub x10,x23,#1
    madd x10,x10,x20,x19
    str w11,[x9,x10,lsl #2]
    sub x23,x23,#1
    cbnz x23,.Lreset_fields
    ldr w11,[x28,#580]
    ldr x9,[x28,#264]
    str w11,[x9,x19,lsl #2]
    ldr w11,[x28,#572]
    ldr x9,[x28,#256]
    str w11,[x9,x19,lsl #2]
    ldr w11,[x28,#568]
    ldr x9,[x28,#240]
    str w11,[x9,x19,lsl #2]
    ldr w11,[x28,#556]
    ldr x9,[x28,#224]
    str w11,[x9,x19,lsl #2]
    mov w11,#0
    ldr x9,[x28,#232]
    str w11,[x9,x19,lsl #2]
    mov w11,#-1
    ldr x9,[x28,#248]
    str w11,[x9,x19,lsl #2]
    ldr w23,[x28,#568]
    ldr x9,[x28,#808]
    sub x10,x23,#1
    ldr d0,[x9,x10,lsl #3]
    ldr d1,.Lc1
    fmaxnm d0,d0,d1
    fsqrt d0,d0
    ldr x9,[x28,#208]
    str d0,[x9,x19,lsl #3]
    mov w9,#0
    str w9,[x28,#548]
.Ldeep_hold:
    mov w9,#0
    str w9,[x28,#544]
    b .Ldeparture_next
.Ldeep_continue:
    mov w9,#1
    str w9,[x28,#544]
.Ldeparture_next:
    sub x22,x22,#1
    ldr w9,[x28,#536]
    cmp w22,w9
    b.ge .Ldeparture
    ldr d0,.Lc16
    str d0,[x28,#720]
    mov x23,#1
.Lcape_max:
    ldr x9,[x28,#832]
    sub x10,x23,#1
    ldr d0,[x9,x10,lsl #3]
    ldr d1,[x28,#720]
    fmaxnm d0,d1,d0
    str d0,[x28,#720]
    add x23,x23,#1
    cmp x23,x21
    b.le .Lcape_max
    ldr d0,[x28,#720]
    ldr x9,[x28,#272]
    str d0,[x9,x19,lsl #3]
    add x19,x19,#1
    ldr w9,[x28,#592]
    cmp w19,w9
    b.lt .Lcolumn
.Lreturn:
    mov sp,x28
    add x16,sp,#1344
    ldp x29,x30,[x16,#0]
    ldp x19,x20,[x16,#16]
    ldp x21,x22,[x16,#32]
    ldp x23,x24,[x16,#48]
    ldp x25,x26,[x16,#64]
    ldp x27,x28,[x16,#80]
    ldp d8,d9,[x16,#96]
    ldp d10,d11,[x16,#112]
    ldp d12,d13,[x16,#128]
    ldp d14,d15,[x16,#144]
    add sp,sp,#1536
    ret
.Ldomain:
    mov w0,#116
    bl _exit
.size CUBASEN_SYMBOL,.-CUBASEN_SYMBOL
.section .rodata
.p2align 3
.Lc0:
    .quad 0x3ff0000000000000
.Lc1:
    .quad 0x0000000000000000
.Lc2:
    .quad 0x3fb999999999999a
.Lc3:
    .quad 0x4008000000000000
.Lc4:
    .quad 0x3fe3333333333334
.Lc5:
    .quad 0x3fd554c985f06f69
.Lc6:
    .quad 0x3ff3333333333333
.Lc7:
    .quad 0xbff8000000000000
.Lc8:
    .quad 0x3fc999999999999a
.Lc9:
    .quad 0x3f1a36e2eb1c432d
.Lc10:
    .quad 0x3f40624dd2f1a9fc
.Lc11:
    .quad 0x40b7700000000000
.Lc12:
    .quad 0x40b3880000000000
.Lc13:
    .quad 0x3fe0000000000000
.Lc14:
    .quad 0x4000000000000000
.Lc15:
    .quad 0x3fd999999999999a
.Lc16:
    .quad 0xffefffffffffffff
.section .note.GNU-stack,"",%progbits
