/* Complete normal-physics moist cloud ascent.
 * Physics is formulations/openifs/physics/moist_cloud_ascent.md.
 * Contract is skills/md2asm/references/openifs/physics/cuascn.md.
 * Preserve the full level order and the shared work flag across columns.
 * Every primary solver operation rounds separately in FP64. */
#ifndef CUASCN_SYMBOL
#define CUASCN_SYMBOL cuascn_
#endif
.text
.p2align 4
.global CUASCN_SYMBOL
.type CUASCN_SYMBOL,%function
CUASCN_SYMBOL:
    sub sp,sp,#2048
    add x16,sp,#1792
    stp x29,x30,[x16]
    stp x19,x20,[x16,#16]
    stp x21,x22,[x16,#32]
    stp x23,x24,[x16,#48]
    stp x25,x26,[x16,#64]
    stp x27,x28,[x16,#80]
    stp d8,d9,[x16,#96]
    stp d10,d11,[x16,#112]
    stp d12,d13,[x16,#128]
    stp d14,d15,[x16,#144]
    mov x29,sp
    str x0,[x29,#640]
    str x1,[x29,#648]
    str x2,[x29,#656]
    str x3,[x29,#664]
    str x4,[x29,#672]
    str x5,[x29,#680]
    str x6,[x29,#688]
    str x7,[x29,#696]
    ldr x9,[x29,#2048]
    str x9,[x29,#704]
    ldr x9,[x29,#2056]
    str x9,[x29,#712]
    ldr x9,[x29,#2064]
    str x9,[x29,#720]
    ldr x9,[x29,#2072]
    str x9,[x29,#728]
    ldr x9,[x29,#2080]
    str x9,[x29,#736]
    ldr x9,[x29,#2088]
    str x9,[x29,#744]
    ldr x9,[x29,#2096]
    str x9,[x29,#752]
    ldr x9,[x29,#2104]
    str x9,[x29,#760]
    ldr x9,[x29,#2112]
    str x9,[x29,#768]
    ldr x9,[x29,#2120]
    str x9,[x29,#776]
    ldr x9,[x29,#2128]
    str x9,[x29,#784]
    ldr x9,[x29,#2136]
    str x9,[x29,#792]
    ldr x9,[x29,#2144]
    str x9,[x29,#800]
    ldr x9,[x29,#2152]
    str x9,[x29,#808]
    ldr x9,[x29,#2160]
    str x9,[x29,#816]
    ldr x9,[x29,#2168]
    str x9,[x29,#824]
    ldr x9,[x29,#2176]
    str x9,[x29,#832]
    ldr x9,[x29,#2184]
    str x9,[x29,#840]
    ldr x9,[x29,#2192]
    str x9,[x29,#848]
    ldr x9,[x29,#2200]
    str x9,[x29,#856]
    ldr x9,[x29,#2208]
    str x9,[x29,#864]
    ldr x9,[x29,#2216]
    str x9,[x29,#872]
    ldr x9,[x29,#2224]
    str x9,[x29,#880]
    ldr x9,[x29,#2232]
    str x9,[x29,#888]
    ldr x9,[x29,#2240]
    str x9,[x29,#896]
    ldr x9,[x29,#2248]
    str x9,[x29,#904]
    ldr x9,[x29,#2256]
    str x9,[x29,#912]
    ldr x9,[x29,#2264]
    str x9,[x29,#920]
    ldr x9,[x29,#2272]
    str x9,[x29,#928]
    ldr x9,[x29,#2280]
    str x9,[x29,#936]
    ldr x9,[x29,#2288]
    str x9,[x29,#944]
    ldr x9,[x29,#2296]
    str x9,[x29,#952]
    ldr x9,[x29,#2304]
    str x9,[x29,#960]
    ldr x9,[x29,#2312]
    str x9,[x29,#968]
    ldr x9,[x29,#2320]
    str x9,[x29,#976]
    ldr x9,[x29,#2328]
    str x9,[x29,#984]
    ldr x9,[x29,#2336]
    str x9,[x29,#992]
    ldr x9,[x29,#2344]
    str x9,[x29,#1000]
    ldr x9,[x29,#2352]
    str x9,[x29,#1008]
    ldr x9,[x29,#2360]
    str x9,[x29,#1016]
    ldr x9,[x29,#2368]
    str x9,[x29,#1024]
    ldr x9,[x29,#2376]
    str x9,[x29,#1032]
    ldr x9,[x29,#2384]
    str x9,[x29,#1040]
    ldr x9,[x29,#2392]
    str x9,[x29,#1048]
    mrs x9,fpcr
    cbnz x9,.Ldomain
    ldr x9,[x29,#640]
    ldr w9,[x9,#4]
    cbnz w9,.Ldomain
    ldr x9,[x29,#680]
    ldr w19,[x9]
    ldr x9,[x29,#688]
    ldr w24,[x9]
    ldr x9,[x29,#696]
    ldr w20,[x9]
    ldr x9,[x29,#704]
    ldr w21,[x9]
    cmp w20,#1
    b.lt .Ldomain
    cmp w20,#4096
    b.gt .Ldomain
    cmp w21,#4
    b.lt .Ldomain
    cmp w21,#1024
    b.gt .Ldomain
    cmp w19,#1
    b.lt .Ldomain
    cmp w24,w20
    b.gt .Ldomain
    cmp w19,w24
    b.gt .Lreturn
    sub x19,x19,#1
    ldr x9,[x29,#712]
    ldr d0,[x9]
    fcmp d0,#0.0
    b.le .Ldomain
    b.vs .Ldomain
    ldr x16,[x29,#656]
    ldr d1,[x16,#56]
    adrp x9,:got:__yomcst_MOD_rg
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rg]
    ldr d2,[x9]
    fmul d0,d2,d0
    fdiv d11,d1,d0
    adrp x9,:got:__yomcst_MOD_rcpd
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rcpd]
    ldr d8,[x9]
    adrp x9,:got:__yomcst_MOD_rg
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rg]
    ldr d0,[x9]
    ldr d1,.LC0
    fdiv d9,d1,d0
    fdiv d10,d1,d8
    adrp x9,:got:__yomcst_MOD_retv
    ldr x9,[x9,:got_lo12:__yomcst_MOD_retv]
    ldr d12,[x9]
    ldr d13,.LC1
    ldr x16,[x29,#656]
    ldr d0,[x16,#144]
    adrp x9,:got:__yomcst_MOD_rg
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rg]
    ldr d1,[x9]
    fdiv d14,d0,d1
    ldr x16,[x29,#656]
    ldr w9,[x16,#276]
    cmp w9,#0
    cset w9,ne
    ucvtf d15,w9
    ldr d0,.LC2
    str d0,[x29,#1560]
    ldr x9,[x29,#664]
    ldr w10,[x9,#216]
    cmp w10,#0
    b.lt .Ldomain
    cmp w10,#512
    b.gt .Ldomain
    str xzr,[x29,#1704]
    ldr x9,[x29,#664]
    ldr w10,[x9]
    cbz w10,.Lresolve1
    ldrsw x10,[x9,#492]
    cmp x10,#0
    b.le .Lresolve1
    ldr x11,[x9,#352]
    cbz x11,.Ldomain
    ldr x12,[x9,#368]
    cmp x12,#184
    b.ne .Ldomain
    ldr x12,[x9,#392]
    cmp x12,#1
    b.ne .Ldomain
    ldr x12,[x9,#400]
    ldr x13,[x9,#408]
    cmp x10,x12
    b.lt .Ldomain
    cmp x10,x13
    b.gt .Ldomain
    sub x10,x10,x12
    mov x12,#184
    madd x11,x10,x12,x11
    ldr w10,[x11,#136]
    ldr w12,[x9,#216]
    cmp w10,#1
    b.lt .Ldomain
    cmp w10,w12
    b.gt .Ldomain
    str x11,[x29,#1704]
.Lresolve1:
    str xzr,[x29,#1712]
    ldr x9,[x29,#664]
    ldr w10,[x9]
    cbz w10,.Lresolve2
    ldrsw x10,[x9,#496]
    cmp x10,#0
    b.le .Lresolve2
    ldr x11,[x9,#352]
    cbz x11,.Ldomain
    ldr x12,[x9,#368]
    cmp x12,#184
    b.ne .Ldomain
    ldr x12,[x9,#392]
    cmp x12,#1
    b.ne .Ldomain
    ldr x12,[x9,#400]
    ldr x13,[x9,#408]
    cmp x10,x12
    b.lt .Ldomain
    cmp x10,x13
    b.gt .Ldomain
    sub x10,x10,x12
    mov x12,#184
    madd x11,x10,x12,x11
    ldr w10,[x11,#136]
    ldr w12,[x9,#216]
    cmp w10,#1
    b.lt .Ldomain
    cmp w10,w12
    b.gt .Ldomain
    str x11,[x29,#1712]
.Lresolve2:
    str xzr,[x29,#1720]
    ldr x9,[x29,#664]
    ldr w10,[x9]
    cbz w10,.Lresolve3
    ldrsw x10,[x9,#508]
    cmp x10,#0
    b.le .Lresolve3
    ldr x11,[x9,#352]
    cbz x11,.Ldomain
    ldr x12,[x9,#368]
    cmp x12,#184
    b.ne .Ldomain
    ldr x12,[x9,#392]
    cmp x12,#1
    b.ne .Ldomain
    ldr x12,[x9,#400]
    ldr x13,[x9,#408]
    cmp x10,x12
    b.lt .Ldomain
    cmp x10,x13
    b.gt .Ldomain
    sub x10,x10,x12
    mov x12,#184
    madd x11,x10,x12,x11
    ldr w10,[x11,#136]
    ldr w12,[x9,#216]
    cmp w10,#1
    b.lt .Ldomain
    cmp w10,w12
    b.gt .Ldomain
    str x11,[x29,#1720]
.Lresolve3:
    str xzr,[x29,#1728]
    ldr x9,[x29,#664]
    ldr w10,[x9]
    cbz w10,.Lresolve4
    ldrsw x10,[x9,#504]
    cmp x10,#0
    b.le .Lresolve4
    ldr x11,[x9,#352]
    cbz x11,.Ldomain
    ldr x12,[x9,#368]
    cmp x12,#184
    b.ne .Ldomain
    ldr x12,[x9,#392]
    cmp x12,#1
    b.ne .Ldomain
    ldr x12,[x9,#400]
    ldr x13,[x9,#408]
    cmp x10,x12
    b.lt .Ldomain
    cmp x10,x13
    b.gt .Ldomain
    sub x10,x10,x12
    mov x12,#184
    madd x11,x10,x12,x11
    ldr w10,[x11,#136]
    ldr w12,[x9,#216]
    cmp w10,#1
    b.lt .Ldomain
    cmp w10,w12
    b.gt .Ldomain
    str x11,[x29,#1728]
.Lresolve4:
    mov x23,x19
.Linput_bounds5:
    cmp x23,x24
    b.ge .Linput_boundsend6
    ldr x16,[x29,#848]
    ldr w9,[x16,x23,lsl #2]
    cmp w9,#1
    b.hi .Ldomain
    ldr x16,[x29,#856]
    ldr w10,[x16,x23,lsl #2]
    cmp w10,#3
    b.hi .Ldomain
    cbz w9,.Linactive_bounds7
    ldr x16,[x29,#1000]
    ldr w9,[x16,x23,lsl #2]
    cmp w9,#1
    b.lt .Ldomain
    cmp w9,w21
    b.gt .Ldomain
.Linactive_bounds7:
    ldr x16,[x29,#1024]
    ldr w9,[x16,x23,lsl #2]
    cmp w9,#1
    b.lt .Ldomain
    cmp w9,w21
    b.gt .Ldomain
    add x23,x23,#1
    b .Linput_bounds5
.Linput_boundsend6:
    mul x9,x20,x21
    lsl x9,x9,#3
    mov x10,#76
    madd x9,x20,x10,x9
    add x9,x9,#15
    and x9,x9,#-16
    str x9,[x29,#1664]
    sub sp,sp,x9
    mov x26,sp
    str x26,[x29,#1104]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1112]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1120]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1128]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1136]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1144]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1152]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1160]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1168]
    add x26,x26,x20,lsl #2
    str x26,[x29,#1176]
    add x26,x26,x20,lsl #2
    str x26,[x29,#1184]
    add x26,x26,x20,lsl #2
    str x26,[x29,#1192]
    sub sp,sp,#256
    mov w28,#0
    str w28,[x29,#1604]
    mov x23,x19
.Linitialize8:
    cmp x23,x24
    b.ge .Linitializeend9
    ldr d0,.LC3
    ldr x16,[x29,#1136]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#848]
    ldr w9,[x16,x23,lsl #2]
    cbnz w9,.Lhasconvection10
    mov w9,#-1
    ldr x16,[x29,#1000]
    str w9,[x16,x23,lsl #2]
    ldr d0,.LC3
    ldr x16,[x29,#920]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#888]
    sub x10,x21,#1
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    mov w9,#0
    ldr x16,[x29,#856]
    str w9,[x16,x23,lsl #2]
.Lhasconvection10:
    ldr d0,.LC3
    ldr x16,[x29,#1048]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1144]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1152]
    str d0,[x16,x23,lsl #3]
    mov w9,#0
    ldr x16,[x29,#872]
    str w9,[x16,x23,lsl #2]
    ldr x16,[x29,#856]
    ldr w9,[x16,x23,lsl #2]
    cmp w9,#1
    b.le .Lnoliquid11
    ldr x16,[x29,#656]
    ldr w9,[x16,#280]
    cbz w9,.Lnoliquid11
    mov w9,#1
    ldr x16,[x29,#872]
    str w9,[x16,x23,lsl #2]
.Lnoliquid11:
    ldr x16,[x29,#848]
    ldr w9,[x16,x23,lsl #2]
    ldr x16,[x29,#856]
    ldr w10,[x16,x23,lsl #2]
    cmp w10,#3
    cset w10,eq
    eor w9,w9,#1
    orr w9,w9,w10
    ldr x16,[x29,#1184]
    str w9,[x16,x23,lsl #2]
    add x23,x23,#1
    b .Linitialize8
.Linitializeend9:
    mov x22,#0
.Linitialize_levels:
    mov x23,x19
.Linit_level12:
    cmp x23,x24
    b.ge .Linit_levelend13
    ldr x16,[x29,#1000]
    ldr w9,[x16,x23,lsl #2]
    add w10,w22,#1
    cmp w9,w10
    b.eq .Lkeepcloud14
    ldr d0,.LC3
    ldr x16,[x29,#896]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
.Lkeepcloud14:
    ldr d0,.LC3
    ldr x16,[x29,#1040]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#912]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#936]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#944]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#952]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#960]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#928]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#976]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#904]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#992]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1032]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#968]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#968]
    mov x10,x22
    madd x10,x10,x20,x23
    madd x10,x20,x21,x10
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1192]
    madd x10,x22,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1184]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lkeeplab15
    mov w9,#0
    ldr x16,[x29,#864]
    mov x10,x22
    madd x10,x10,x20,x23
    str w9,[x16,x10,lsl #2]
.Lkeeplab15:
    ldr x16,[x29,#848]
    ldr w9,[x16,x23,lsl #2]
    cbnz w9,.Lkeeptop16
    ldr x16,[x29,#808]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr d1,.LC4
    fcmp d0,d1
    b.ge .Lkeeptop16
    add w9,w22,#1
    ldr x16,[x29,#1016]
    str w9,[x16,x23,lsl #2]
.Lkeeptop16:
    add x23,x23,#1
    b .Linit_level12
.Linit_levelend13:
    add x22,x22,#1
    cmp x22,x21
    b.lt .Linitialize_levels
    mov x23,x19
.Lcloud_base17:
    cmp x23,x24
    b.ge .Lcloud_baseend18
    ldr x16,[x29,#856]
    ldr w9,[x16,x23,lsl #2]
    cmp w9,#3
    b.ne .Lnotmid19
    mov w9,#0
    ldr x16,[x29,#848]
    str w9,[x16,x23,lsl #2]
.Lnotmid19:
    ldr x16,[x29,#1000]
    ldr w9,[x16,x23,lsl #2]
    ldr x16,[x29,#1008]
    str w9,[x16,x23,lsl #2]
    ldr x16,[x29,#848]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lnobase20
    ldr x16,[x29,#1000]
    ldr w9,[x16,x23,lsl #2]
    sub x27,x9,#1
    ldr x16,[x29,#824]
    ldr d0,[x16,x23,lsl #3]
    fmul d0,d0,d0
    ldr d1,.LC5
    fmul d0,d1,d0
    ldr x16,[x29,#1040]
    mov x10,x27
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#920]
    ldr d0,[x16,x23,lsl #3]
    ldr x16,[x29,#912]
    mov x10,x27
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#880]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#792]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fmul d1,d8,d1
    fadd d1,d1,d2
    fmul d1,d0,d1
    ldr x16,[x29,#936]
    mov x10,x27
    madd x10,x10,x20,x23
    str d1,[x16,x10,lsl #3]
    ldr x16,[x29,#888]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmul d1,d0,d1
    ldr x16,[x29,#944]
    mov x10,x27
    madd x10,x10,x20,x23
    str d1,[x16,x10,lsl #3]
    ldr x16,[x29,#896]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmul d1,d0,d1
    ldr x16,[x29,#952]
    mov x10,x27
    madd x10,x10,x20,x23
    str d1,[x16,x10,lsl #3]
.Lnobase20:
    add x23,x23,#1
    b .Lcloud_base17
.Lcloud_baseend18:
    sub x22,x21,#2
.Lascent_level:
    add w9,w22,#1
    str w9,[x29,#1600]
    ldr x9,[x29,#656]
    mov x0,x9
    ldr x9,[x29,#680]
    mov x1,x9
    ldr x9,[x29,#688]
    mov x2,x9
    ldr x9,[x29,#696]
    mov x3,x9
    ldr x9,[x29,#704]
    mov x4,x9
    add x9,x29,#1600
    mov x5,x9
    ldr x9,[x29,#752]
    mov x6,x9
    ldr x9,[x29,#760]
    mov x7,x9
    ldr x9,[x29,#768]
    str x9,[sp,#0]
    ldr x9,[x29,#816]
    str x9,[sp,#8]
    ldr x9,[x29,#784]
    str x9,[sp,#16]
    ldr x9,[x29,#792]
    str x9,[sp,#24]
    ldr x9,[x29,#848]
    str x9,[sp,#32]
    ldr x9,[x29,#856]
    str x9,[sp,#40]
    ldr x9,[x29,#864]
    str x9,[sp,#48]
    ldr x9,[x29,#1000]
    str x9,[sp,#56]
    ldr x9,[x29,#912]
    str x9,[sp,#64]
    ldr x9,[x29,#920]
    str x9,[sp,#72]
    ldr x9,[x29,#904]
    str x9,[sp,#80]
    ldr x9,[x29,#880]
    str x9,[sp,#88]
    ldr x9,[x29,#888]
    str x9,[sp,#96]
    ldr x9,[x29,#896]
    str x9,[sp,#104]
    ldr x9,[x29,#936]
    str x9,[sp,#112]
    ldr x9,[x29,#944]
    str x9,[sp,#120]
    ldr x9,[x29,#952]
    str x9,[sp,#128]
    ldr x9,[x29,#976]
    str x9,[sp,#136]
    bl md2asm_cubasmcn_7240564
    str wzr,[x29,#1620]
    str wzr,[x29,#1624]
    mov x23,x19
.Lflags21:
    cmp x23,x24
    b.ge .Lflagsend22
    mov w9,#0
    ldr x16,[x29,#1168]
    str w9,[x16,x23,lsl #2]
    ldr x16,[x29,#1176]
    str w9,[x16,x23,lsl #2]
    ldr d0,.LC3
    ldr x16,[x29,#1128]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#864]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr w11,[x16,x10,lsl #2]
    ldr w12,[x29,#1620]
    add w12,w12,w11
    str w12,[x29,#1620]
    cbnz w11,.Lnonzerolab23
    mov w9,#0
    ldr x16,[x29,#864]
    mov x10,x22
    madd x10,x10,x20,x23
    str w9,[x16,x10,lsl #2]
.Lnonzerolab23:
    ldr x16,[x29,#848]
    ldr w9,[x16,x23,lsl #2]
    ldr x16,[x29,#856]
    ldr w10,[x16,x23,lsl #2]
    cmp w11,#2
    cset w12,eq
    and w9,w9,w12
    cmp w10,#3
    cset w10,eq
    cmp w11,#1
    cset w11,eq
    and w10,w10,w11
    orr w9,w9,w10
    ldr x16,[x29,#1168]
    str w9,[x16,x23,lsl #2]
    ldr w12,[x29,#1624]
    add w12,w12,w9
    str w12,[x29,#1624]
    ldr x16,[x29,#808]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1160]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#856]
    ldr w9,[x16,x23,lsl #2]
    cmp w9,#3
    b.ne .Lnotmidcap24
    ldr x16,[x29,#1000]
    ldr w9,[x16,x23,lsl #2]
    add w10,w22,#1
    cmp w9,w10
    b.ne .Lnotmidcap24
    ldr x16,[x29,#808]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#808]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d0,d0,d1
    fmul d0,d0,d11
    ldr x16,[x29,#920]
    ldr d1,[x16,x23,lsl #3]
    fcmp d1,d0
    b.le .Lnotmidcap24
    fdiv d2,d0,d1
    ldr x16,[x29,#920]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#912]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d0,d2
    ldr x16,[x29,#912]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#936]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d0,d2
    ldr x16,[x29,#936]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#944]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d0,d2
    ldr x16,[x29,#944]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
.Lnotmidcap24:
    add x23,x23,#1
    b .Lflags21
.Lflagsend22:
    ldr w9,[x29,#1620]
    cmp w9,#0
    cset w9,gt
    orr w28,w28,w9
    str w28,[x29,#1604]
    ldr x9,[x29,#656]
    mov x0,x9
    ldr x9,[x29,#664]
    mov x1,x9
    ldr x9,[x29,#680]
    mov x2,x9
    ldr x9,[x29,#688]
    mov x3,x9
    ldr x9,[x29,#696]
    mov x4,x9
    ldr x9,[x29,#704]
    mov x5,x9
    add x9,x29,#1600
    mov x6,x9
    ldr x9,[x29,#1000]
    mov x7,x9
    ldr x9,[x29,#856]
    str x9,[sp,#0]
    ldr x9,[x29,#848]
    str x9,[sp,#8]
    add x9,x29,#1604
    str x9,[sp,#16]
    ldr x9,[x29,#768]
    str x9,[sp,#24]
    ldr x9,[x29,#808]
    str x9,[sp,#32]
    ldr x9,[x29,#792]
    str x9,[sp,#40]
    ldr x9,[x29,#912]
    str x9,[sp,#48]
    ldr x9,[x29,#832]
    str x9,[sp,#56]
    ldr x9,[x29,#1104]
    str x9,[sp,#64]
    ldr x9,[x29,#1112]
    str x9,[sp,#72]
    bl md2asm_cuentr_7240564
    cbz w28,.Lnext_level
    mov x23,x19
.Ladiabatic25:
    cmp x23,x24
    b.ge .Ladiabaticend26
    ldr d0,.LC3
    ldr x16,[x29,#1120]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1168]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lskipadiabatic27
    ldr x16,[x29,#1112]
    ldr d0,[x16,x23,lsl #3]
    ldr x16,[x29,#912]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr d2,.LC6
    fmul d1,d2,d1
    fmin d0,d0,d1
    ldr x16,[x29,#1112]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1000]
    ldr w9,[x16,x23,lsl #2]
    add w10,w22,#1
    cmp w9,w10
    b.ne .Lnotbaseentr28
    ldr x9,[x29,#1704]
    cbz x9,.Lnopert29
    ldr d1,[x9,#56]
    ldr d2,[x9,#24]
    ldrsw x13,[x9,#136]
    sub x13,x13,#1
    ldr x9,[x29,#832]
    madd x13,x13,x20,x23
    ldr d0,[x9,x13,lsl #3]
    fmul d0,d2,d0
    fadd d0,d1,d0
    bl exp
    ldr x16,[x29,#656]
    ldr d1,[x16,#0]
    fmul d0,d1,d0
    b .Lpertend30
.Lnopert29:
    ldr x16,[x29,#656]
    ldr d0,[x16,#0]
.Lpertend30:
    fneg d0,d0
    ldr x16,[x29,#760]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#768]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fdiv d1,d1,d2
    ldr d2,.LC0
    fmin d1,d2,d1
    fsub d1,d1,d2
    fmul d0,d0,d1
    ldr x16,[x29,#792]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#792]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fsub d1,d1,d2
    fmul d0,d0,d1
    fmul d0,d0,d9
    ldr d1,.LC7
    fmin d0,d1,d0
    ldr x16,[x29,#912]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmul d0,d0,d1
    ldr x16,[x29,#1152]
    str d0,[x16,x23,lsl #3]
.Lnotbaseentr28:
    ldr x16,[x29,#1000]
    ldr w9,[x16,x23,lsl #2]
    add w10,w22,#1
    cmp w10,w9
    b.ge .Lbelowbase31
    ldr x16,[x29,#808]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#808]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d0,d0,d1
    fmul d0,d0,d11
    str d0,[x29,#1400]
    ldr x16,[x29,#912]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d0,d1,d0
    ldr d2,.LC3
    fmax d0,d0,d2
    str d0,[x29,#1408]
    ldr x16,[x29,#1040]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#800]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#800]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fsub d1,d1,d2
    fmul d0,d0,d1
    ldr x16,[x29,#1048]
    ldr d1,[x16,x23,lsl #3]
    fadd d0,d1,d0
    ldr x16,[x29,#1048]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1144]
    ldr d0,[x16,x23,lsl #3]
    ldr x16,[x29,#800]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#800]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fadd d0,d0,d1
    fsub d0,d0,d2
    ldr x16,[x29,#1144]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1152]
    ldr d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1104]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#856]
    ldr w9,[x16,x23,lsl #2]
    cmp w9,#2
    b.lt .Ldeepentr32
    ldr x9,[x29,#1712]
    cbz x9,.Lnopert33
    ldr d1,[x9,#56]
    ldr d2,[x9,#24]
    ldrsw x13,[x9,#136]
    sub x13,x13,#1
    ldr x9,[x29,#832]
    madd x13,x13,x20,x23
    ldr d0,[x9,x13,lsl #3]
    fmul d0,d2,d0
    fadd d0,d1,d0
    bl exp
    ldr x16,[x29,#656]
    ldr d1,[x16,#8]
    fmul d0,d1,d0
    b .Lpertend34
.Lnopert33:
    ldr x16,[x29,#656]
    ldr d0,[x16,#8]
.Lpertend34:
    ldr x16,[x29,#1104]
    ldr d1,[x16,x23,lsl #3]
    fmul d0,d0,d1
    ldr x16,[x29,#1104]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1112]
    str d0,[x16,x23,lsl #3]
.Ldeepentr32:
    ldr x16,[x29,#760]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#768]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fdiv d0,d0,d1
    ldr d1,.LC0
    fmin d0,d1,d0
    ldr d1,.LC8
    fsub d0,d1,d0
    ldr x16,[x29,#1112]
    ldr d1,[x16,x23,lsl #3]
    fmul d0,d1,d0
    ldr x16,[x29,#1112]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#912]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1104]
    ldr d1,[x16,x23,lsl #3]
    ldr x16,[x29,#1112]
    ldr d2,[x16,x23,lsl #3]
    fadd d0,d0,d1
    fsub d0,d0,d2
    ldr d1,[x29,#1400]
    fsub d0,d0,d1
    ldr d1,.LC3
    fmax d0,d0,d1
    str d0,[x29,#1416]
    ldr d2,[x29,#1408]
    fsub d2,d0,d2
    fmax d2,d2,d1
    ldr x16,[x29,#1104]
    ldr d3,[x16,x23,lsl #3]
    fsub d3,d3,d2
    ldr x16,[x29,#1104]
    str d3,[x16,x23,lsl #3]
    fsub d0,d0,d2
    ldr x16,[x29,#1112]
    ldr d3,[x16,x23,lsl #3]
    fadd d3,d3,d0
    ldr x16,[x29,#1112]
    str d3,[x16,x23,lsl #3]
.Lbelowbase31:
    ldr x16,[x29,#1104]
    ldr d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1112]
    ldr d1,[x16,x23,lsl #3]
    fsub d2,d0,d1
    ldr x16,[x29,#992]
    mov x10,x22
    madd x10,x10,x20,x23
    str d2,[x16,x10,lsl #3]
    ldr x16,[x29,#912]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fadd d2,d2,d0
    fsub d2,d2,d1
    ldr x16,[x29,#912]
    mov x10,x22
    madd x10,x10,x20,x23
    str d2,[x16,x10,lsl #3]
    ldr x16,[x29,#728]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fmul d2,d2,d0
    str d2,[x29,#1432]
    ldr x16,[x29,#720]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    ldr x16,[x29,#792]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d3,[x16,x10,lsl #3]
    fmul d2,d8,d2
    fadd d2,d2,d3
    fmul d2,d2,d0
    str d2,[x29,#1424]
    ldr x16,[x29,#776]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    ldr x16,[x29,#648]
    ldr d3,[x16,#120]
    fcmp d2,d3
    b.le .Lnoliquid35
    fmul d2,d2,d0
    b .Lliquiddone36
.Lnoliquid35:
    ldr d2,.LC3
.Lliquiddone36:
    str d2,[x29,#1440]
    ldr x16,[x29,#880]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    ldr x16,[x29,#792]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d3,[x16,x10,lsl #3]
    fmul d2,d8,d2
    fadd d2,d2,d3
    fmul d2,d2,d1
    str d2,[x29,#1448]
    ldr x16,[x29,#888]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fmul d2,d2,d1
    str d2,[x29,#1456]
    ldr x16,[x29,#896]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fmul d2,d2,d1
    ldr x16,[x29,#960]
    mov x10,x22
    madd x10,x10,x20,x23
    str d2,[x16,x10,lsl #3]
    ldr x16,[x29,#936]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    ldr d3,[x29,#1424]
    ldr d4,[x29,#1448]
    fadd d2,d2,d3
    fsub d2,d2,d4
    str d2,[x29,#1464]
    ldr x16,[x29,#944]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    ldr d3,[x29,#1432]
    ldr d4,[x29,#1456]
    fadd d2,d2,d3
    fsub d2,d2,d4
    str d2,[x29,#1472]
    ldr x16,[x29,#952]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    ldr d3,[x29,#1440]
    ldr x16,[x29,#960]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d4,[x16,x10,lsl #3]
    fadd d2,d2,d3
    fsub d2,d2,d4
    str d2,[x29,#1480]
    ldr x16,[x29,#912]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#656]
    ldr d1,[x16,#120]
    fmax d0,d1,d0
    ldr d1,.LC0
    fdiv d0,d1,d0
    str d0,[x29,#1488]
    ldr d1,[x29,#1480]
    fmul d1,d1,d0
    ldr x16,[x29,#896]
    mov x10,x22
    madd x10,x10,x20,x23
    str d1,[x16,x10,lsl #3]
    ldr d1,[x29,#1472]
    fmul d1,d1,d0
    ldr x16,[x29,#888]
    mov x10,x22
    madd x10,x10,x20,x23
    str d1,[x16,x10,lsl #3]
    ldr x16,[x29,#1120]
    str d1,[x16,x23,lsl #3]
    ldr d1,[x29,#1464]
    ldr x16,[x29,#792]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fmul d1,d1,d0
    fsub d1,d1,d2
    fmul d1,d1,d10
    ldr d2,.LC9
    fmax d1,d2,d1
    ldr d2,.LC10
    fmin d1,d2,d1
    ldr x16,[x29,#880]
    mov x10,x22
    madd x10,x10,x20,x23
    str d1,[x16,x10,lsl #3]
    ldr x16,[x29,#904]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#912]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    ldr x16,[x29,#1112]
    ldr d3,[x16,x23,lsl #3]
    fsub d2,d2,d3
    ldr d3,.LC3
    fmax d2,d3,d2
    fmul d1,d1,d2
    fmul d1,d1,d0
    ldr x16,[x29,#904]
    mov x10,x22
    madd x10,x10,x20,x23
    str d1,[x16,x10,lsl #3]
    ldr x16,[x29,#896]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1136]
    str d0,[x16,x23,lsl #3]
.Lskipadiabatic27:
    add x23,x23,#1
    b .Ladiabatic25
.Ladiabaticend26:
    mov x23,x19
.Lreset_departure37:
    cmp x23,x24
    b.ge .Lreset_departureend38
    ldr x16,[x29,#1024]
    ldr w9,[x16,x23,lsl #2]
    add w10,w22,#1
    cmp w10,w9
    b.le .Labove_departure39
    ldr x16,[x29,#720]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#880]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#728]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#888]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr d0,.LC3
    ldr x16,[x29,#896]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1136]
    str d0,[x16,x23,lsl #3]
.Labove_departure39:
    add x23,x23,#1
    b .Lreset_departure37
.Lreset_departureend38:
    ldr w9,[x29,#1624]
    cbz w9,.Lafter_adjustment
    ldr x16,[x29,#656]
    ldr w9,[x16,#280]
    cmp w9,#0
    mov w10,#1
    mov w11,#6
    csel w9,w11,w10,ne
    str w9,[x29,#1608]
    ldr x9,[x29,#640]
    mov x0,x9
    ldr x9,[x29,#680]
    mov x1,x9
    ldr x9,[x29,#688]
    mov x2,x9
    ldr x9,[x29,#696]
    mov x3,x9
    ldr x9,[x29,#704]
    mov x4,x9
    add x9,x29,#1600
    mov x5,x9
    ldr x9,[x29,#1160]
    mov x6,x9
    ldr x9,[x29,#880]
    mov x7,x9
    ldr x9,[x29,#888]
    str x9,[sp,#0]
    ldr x9,[x29,#1168]
    str x9,[sp,#8]
    add x9,x29,#1608
    str x9,[sp,#16]
    ldr x9,[x29,#872]
    str x9,[sp,#24]
    bl md2asm_cuadjtq
.Lafter_adjustment:
    mov x23,x19
.Lglaciation40:
    cmp x23,x24
    b.ge .Lglaciationend41
    ldr x16,[x29,#1168]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lnoglaciation42
    ldr x16,[x29,#888]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1120]
    ldr d1,[x16,x23,lsl #3]
    fcmp d0,d1
    b.eq .Lnoglaciation42
    ldr x16,[x29,#880]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    adrp x9,:got:__yoethf_MOD_rtwat
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rtwat]
    ldr d1,[x9]
    adrp x9,:got:__yoethf_MOD_rticecu
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rticecu]
    ldr d2,[x9]
    adrp x9,:got:__yoethf_MOD_rtwat_rticecu_r
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rtwat_rticecu_r]
    ldr d3,[x9]
    fmin d0,d1,d0
    fmax d0,d2,d0
    fsub d0,d0,d2
    fmul d0,d0,d3
    fmul d0,d0,d0
    ldr d1,.LC0
    fmin d0,d1,d0
    ldr d1,.LC0
    fsub d0,d1,d0
    str d0,[x29,#1488]
    ldr x16,[x29,#880]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    adrp x9,:got:__yoethf_MOD_rtwat
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rtwat]
    ldr d1,[x9]
    adrp x9,:got:__yoethf_MOD_rticecu
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rticecu]
    ldr d2,[x9]
    adrp x9,:got:__yoethf_MOD_rtwat_rticecu_r
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rtwat_rticecu_r]
    ldr d3,[x9]
    fmin d0,d1,d0
    fmax d0,d2,d0
    fsub d0,d0,d2
    fmul d0,d0,d3
    fmul d0,d0,d0
    ldr d1,.LC0
    fmin d0,d1,d0
    ldr d1,.LC0
    fsub d0,d1,d0
    ldr d1,[x29,#1488]
    fsub d1,d1,d0
    ldr x16,[x29,#896]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d0,d1
    ldr x16,[x29,#928]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#872]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lmixedglac43
    ldr d0,.LC3
    ldr x16,[x29,#928]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
.Lmixedglac43:
    ldr x16,[x29,#752]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    adrp x9,:got:__yoethf_MOD_rtwat
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rtwat]
    ldr d1,[x9]
    adrp x9,:got:__yoethf_MOD_rticecu
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rticecu]
    ldr d2,[x9]
    adrp x9,:got:__yoethf_MOD_rtwat_rticecu_r
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rtwat_rticecu_r]
    ldr d3,[x9]
    fmin d0,d1,d0
    fmax d0,d2,d0
    fsub d0,d0,d2
    fmul d0,d0,d3
    fmul d0,d0,d0
    ldr d1,.LC0
    fmin d0,d1,d0
    ldr x16,[x29,#976]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmul d0,d0,d1
    ldr x16,[x29,#912]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#656]
    ldr d2,[x16,#120]
    fmax d1,d2,d1
    fdiv d0,d0,d1
    adrp x9,:got:__yomcst_MOD_rtt
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rtt]
    ldr d1,[x9]
    ldr x16,[x29,#752]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fsub d1,d1,d2
    fmov x9,d1
    and x9,x9,#0x8000000000000000
    ldr d2,.LC5
    fmov x10,d2
    orr x10,x10,x9
    fmov d1,x10
    fadd d1,d2,d1
    fmul d0,d0,d1
    fmul d0,d0,d15
    ldr x16,[x29,#928]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fadd d0,d1,d0
    ldr x16,[x29,#928]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    adrp x9,:got:__yoethf_MOD_ralfdcp
    ldr x9,[x9,:got_lo12:__yoethf_MOD_ralfdcp]
    ldr d1,[x9]
    fmul d0,d1,d0
    ldr x16,[x29,#880]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fadd d0,d1,d0
    ldr x16,[x29,#880]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
.Lnoglaciation42:
    add x23,x23,#1
    b .Lglaciation40
.Lglaciationend41:
    mov x23,x19
.Lbuoyancy44:
    cmp x23,x24
    b.ge .Lbuoyancyend45
    ldr x16,[x29,#1168]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lskipbuoyancy46
    ldr x16,[x29,#888]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1120]
    ldr d1,[x16,x23,lsl #3]
    fcmp d0,d1
    b.eq .Lsamehumidity47
    mov w9,#2
    ldr x16,[x29,#864]
    mov x10,x22
    madd x10,x10,x20,x23
    str w9,[x16,x10,lsl #2]
    ldr x16,[x29,#896]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1120]
    ldr d1,[x16,x23,lsl #3]
    ldr x16,[x29,#888]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fadd d0,d0,d1
    fsub d0,d0,d2
    ldr x16,[x29,#896]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#888]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d12,d0
    ldr d1,.LC0
    fadd d0,d1,d0
    ldr x16,[x29,#896]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#904]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fsub d0,d0,d1
    fsub d0,d0,d2
    ldr x16,[x29,#880]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmul d0,d1,d0
    str d0,[x29,#1496]
    ldr x16,[x29,#728]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmul d1,d12,d1
    ldr d2,.LC0
    fadd d1,d2,d1
    ldr x16,[x29,#720]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fmul d1,d2,d1
    fsub d0,d0,d1
    ldr x16,[x29,#1192]
    madd x10,x22,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#856]
    ldr w9,[x16,x23,lsl #2]
    cmp w9,#3
    b.ne .Lnotmidstart49
    ldr x16,[x29,#864]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr w9,[x16,x10,lsl #2]
    cmp w9,#1
    b.ne .Lnotmidstart49
    ldr x16,[x29,#1192]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr d1,.LC11
    fcmp d0,d1
    b.le .Lfailedmid50
    mov w9,#1
    ldr x16,[x29,#848]
    str w9,[x16,x23,lsl #2]
    add w9,w22,#1
    ldr x16,[x29,#1008]
    str w9,[x16,x23,lsl #2]
    ldr d0,.LC5
    ldr x16,[x29,#1040]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    b .Lmidstartdone51
.Lfailedmid50:
    mov w9,#0
    ldr x16,[x29,#864]
    mov x10,x22
    madd x10,x10,x20,x23
    str w9,[x16,x10,lsl #2]
    ldr d0,.LC3
    ldr x16,[x29,#912]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#960]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#896]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
.Lmidstartdone51:
.Lnotmidstart49:
    ldr x16,[x29,#864]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr w9,[x16,x10,lsl #2]
    cmp w9,#2
    b.ne .Lnotcloudcontinuation52
    ldr x16,[x29,#1192]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr d1,.LC12
    fcmp d0,d1
    b.ge .Lnoenvcorrection53
    ldr x16,[x29,#752]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#752]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fadd d0,d0,d1
    ldr d1,.LC5
    fmul d0,d1,d0
    ldr x16,[x29,#720]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#760]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#760]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fadd d0,d0,d1
    ldr d1,.LC5
    fmul d0,d1,d0
    ldr x16,[x29,#728]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#728]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d12,d0
    ldr d1,.LC0
    fadd d0,d1,d0
    ldr x16,[x29,#720]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmul d0,d1,d0
    ldr d1,[x29,#1496]
    fsub d0,d1,d0
    ldr x16,[x29,#1192]
    madd x10,x22,x20,x23
    str d0,[x16,x10,lsl #3]
.Lnoenvcorrection53:
    ldr x16,[x29,#1192]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1192]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fadd d0,d0,d1
    ldr d1,.LC5
    fmul d0,d1,d0
    ldr x16,[x29,#728]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmul d1,d12,d1
    ldr d2,.LC0
    fadd d1,d2,d1
    ldr x16,[x29,#720]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fmul d1,d2,d1
    fdiv d0,d0,d1
    str d0,[x29,#1504]
    ldr x16,[x29,#792]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#792]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fsub d1,d1,d2
    fmul d1,d1,d13
    fmul d1,d1,d0
    str d1,[x29,#1552]
    ldr x16,[x29,#1104]
    ldr d0,[x16,x23,lsl #3]
    fcmp d0,#0.0
    b.le .Lusedetrainment54
    b .Lchosenmix55
.Lusedetrainment54:
    ldr x16,[x29,#1112]
    ldr d0,[x16,x23,lsl #3]
.Lchosenmix55:
    ldr d1,[x29,#1560]
    ldr d2,.LC0
    fadd d1,d2,d1
    fmul d0,d1,d0
    ldr x16,[x29,#912]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#656]
    ldr d3,[x16,#120]
    fmax d1,d3,d1
    fdiv d0,d0,d1
    fmin d0,d2,d0
    str d0,[x29,#1512]
    fsub d1,d2,d0
    ldr x16,[x29,#1040]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d3,[x16,x10,lsl #3]
    fmul d1,d3,d1
    ldr d3,[x29,#1552]
    fadd d1,d1,d3
    fadd d0,d2,d0
    fdiv d0,d1,d0
    ldr d1,.LC13
    fmax d0,d1,d0
    ldr x16,[x29,#1040]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr d0,[x29,#1504]
    fcmp d0,#0.0
    b.ge .Lpositivebuoyancy56
    ldr x16,[x29,#1040]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1040]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr d2,.LC14
    fmax d1,d2,d1
    fdiv d0,d0,d1
    ldr d1,.LC0
    ldr d2,.LC3
    fmin d0,d1,d0
    fmax d0,d2,d0
    fsqrt d0,d0
    str d0,[x29,#1488]
    ldr x16,[x29,#760]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#768]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fdiv d0,d0,d1
    ldr d1,.LC0
    fmin d0,d1,d0
    ldr d1,.LC8
    fsub d0,d1,d0
    ldr d1,[x29,#1488]
    fmul d0,d0,d1
    ldr d1,.LC0
    fsub d0,d1,d0
    ldr x16,[x29,#912]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmul d0,d1,d0
    ldr x16,[x29,#1112]
    ldr d1,[x16,x23,lsl #3]
    fmax d0,d1,d0
    ldr x16,[x29,#1112]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#896]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmul d1,d1,d0
    ldr x16,[x29,#960]
    mov x10,x22
    madd x10,x10,x20,x23
    str d1,[x16,x10,lsl #3]
    ldr x16,[x29,#912]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#1104]
    ldr d2,[x16,x23,lsl #3]
    fadd d1,d1,d2
    fsub d1,d1,d0
    ldr x16,[x29,#912]
    mov x10,x22
    madd x10,x10,x20,x23
    str d1,[x16,x10,lsl #3]
.Lpositivebuoyancy56:
    ldr x16,[x29,#1192]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr d1,.LC15
    fcmp d0,d1
    b.le .Lnoorganizedentr57
    ldr x9,[x29,#1704]
    cbz x9,.Lnopert59
    ldr d1,[x9,#56]
    ldr d2,[x9,#24]
    ldrsw x13,[x9,#136]
    sub x13,x13,#1
    ldr x9,[x29,#832]
    madd x13,x13,x20,x23
    ldr d0,[x9,x13,lsl #3]
    fmul d0,d2,d0
    fadd d0,d1,d0
    bl exp
    ldr x16,[x29,#656]
    ldr d1,[x16,#0]
    fmul d0,d1,d0
    b .Lpertend60
.Lnopert59:
    ldr x16,[x29,#656]
    ldr d0,[x16,#0]
.Lpertend60:
    str d0,[x29,#1488]
    ldr x16,[x29,#760]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#768]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fdiv d0,d0,d1
    ldr d1,.LC0
    fmin d0,d1,d0
    fsub d0,d0,d1
    ldr d1,.LC16
    fsub d0,d1,d0
    ldr d1,[x29,#1488]
    fmul d0,d1,d0
    ldr x16,[x29,#792]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#792]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fsub d1,d1,d2
    fmul d0,d0,d1
    fmul d0,d0,d9
    str d0,[x29,#1488]
    ldr x16,[x29,#1000]
    ldr w9,[x16,x23,lsl #2]
    sub x27,x9,#1
    ldr x16,[x29,#768]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#768]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fdiv d0,d0,d1
    ldr d1,.LC0
    fmin d0,d1,d0
    fmul d1,d0,d0
    fmul d0,d1,d0
    ldr d1,[x29,#1488]
    fmul d0,d1,d0
    ldr d1,.LC7
    fmin d0,d1,d0
    ldr x16,[x29,#912]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmul d0,d0,d1
    ldr x16,[x29,#1152]
    str d0,[x16,x23,lsl #3]
    b .Lorganizeddone58
.Lnoorganizedentr57:
    ldr d0,.LC3
    ldr x16,[x29,#1152]
    str d0,[x16,x23,lsl #3]
.Lorganizeddone58:
    ldr x16,[x29,#1024]
    ldr w9,[x16,x23,lsl #2]
    add w10,w22,#1
    cmp w10,w9
    b.le .Labove_dpl_kinetic61
    ldr x16,[x29,#912]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#912]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr d0,.LC5
    ldr x16,[x29,#1040]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
.Labove_dpl_kinetic61:
    ldr x16,[x29,#1040]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fcmp d0,#0.0
    b.le .Lstopcloud63
    ldr x16,[x29,#912]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fcmp d0,#0.0
    b.le .Lstopcloud63
    ldr x16,[x29,#1192]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr d1,.LC17
    fcmp d0,d1
    b.gt .Lkeepcloud62
    ldr x16,[x29,#752]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#752]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d0,d0,d1
    ldr x16,[x29,#784]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#784]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fsub d1,d1,d2
    fmul d1,d9,d1
    fdiv d0,d0,d1
    ldr d1,.LC18
    fcmp d0,d1
    b.lt .Lkeepcloud62
    b .Lstopcloud63
.Lkeepcloud62:
    add w9,w22,#1
    ldr x16,[x29,#1008]
    str w9,[x16,x23,lsl #2]
    mov w9,#1
    ldr x16,[x29,#1176]
    str w9,[x16,x23,lsl #2]
    b .Ltopdone64
.Lstopcloud63:
    mov w9,#0
    ldr x16,[x29,#864]
    mov x10,x22
    madd x10,x10,x20,x23
    str w9,[x16,x10,lsl #2]
    ldr d0,.LC3
    ldr x16,[x29,#912]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1040]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#912]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1112]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#896]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmul d0,d1,d0
    ldr x16,[x29,#960]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
.Ltopdone64:
    ldr x16,[x29,#912]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fcmp d0,#0.0
    b.le .Lnostoredetr65
    ldr x16,[x29,#1112]
    ldr d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1032]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
.Lnostoredetr65:
.Lnotcloudcontinuation52:
    b .Ldonebuoyancy48
.Lsamehumidity47:
    ldr x16,[x29,#856]
    ldr w9,[x16,x23,lsl #2]
    cmp w9,#2
    b.ne .Ldonebuoyancy48
    mov w9,#0
    ldr x16,[x29,#864]
    mov x10,x22
    madd x10,x10,x20,x23
    str w9,[x16,x10,lsl #2]
    ldr d0,.LC3
    ldr x16,[x29,#912]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1040]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#912]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1112]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1032]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#896]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmul d0,d1,d0
    ldr x16,[x29,#960]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
.Ldonebuoyancy48:
.Lskipbuoyancy46:
    add x23,x23,#1
    b .Lbuoyancy44
.Lbuoyancyend45:
    mov x23,x19
.Lprecipitation66:
    cmp x23,x24
    b.ge .Lprecipitationend67
    ldr x16,[x29,#1176]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lnoprecip68
    ldr x16,[x29,#896]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr d1,.LC19
    fcmp d0,d1
    b.le .Lnoprecip68
    ldr x16,[x29,#1040]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr d1,.LC5
    fmax d0,d1,d0
    ldr d1,.LC20
    fmul d0,d1,d0
    fsqrt d0,d0
    ldr d1,.LC21
    fmin d0,d1,d0
    ldr d1,.LC6
    fmul d0,d1,d0
    str d0,[x29,#1488]
    ldr x16,[x29,#880]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    adrp x9,:got:__yoethf_MOD_rtwat
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rtwat]
    ldr d1,[x9]
    adrp x9,:got:__yoethf_MOD_rticecu
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rticecu]
    ldr d2,[x9]
    adrp x9,:got:__yoethf_MOD_rtwat_rticecu_r
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rtwat_rticecu_r]
    ldr d3,[x9]
    fmin d0,d1,d0
    fmax d0,d2,d0
    fsub d0,d0,d2
    fmul d0,d0,d3
    fmul d0,d0,d0
    ldr d1,.LC0
    fmin d0,d1,d0
    ldr d1,.LC16
    fmul d0,d1,d0
    ldr d1,.LC0
    fadd d0,d1,d0
    str d0,[x29,#1520]
    ldr x9,[x29,#1720]
    cbz x9,.Lnopert69
    ldr d1,[x9,#56]
    ldr d2,[x9,#24]
    ldrsw x13,[x9,#136]
    sub x13,x13,#1
    ldr x9,[x29,#832]
    madd x13,x13,x20,x23
    ldr d0,[x9,x13,lsl #3]
    fmul d0,d2,d0
    fadd d0,d1,d0
    bl exp
    fmul d0,d14,d0
    b .Lpertend70
.Lnopert69:
    fmov d0,d14
.Lpertend70:
    ldr d1,[x29,#1488]
    fdiv d0,d0,d1
    ldr d1,[x29,#1520]
    fmul d0,d0,d1
    str d0,[x29,#1552]
    adrp x9,:got:__yoethf_MOD_rtbercu
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rtbercu]
    ldr d0,[x9]
    adrp x9,:got:__yoethf_MOD_rticecu
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rticecu]
    ldr d1,[x9]
    fsub d1,d0,d1
    ldr x16,[x29,#880]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fsub d0,d0,d2
    ldr d2,.LC3
    fmax d0,d0,d2
    fmin d0,d1,d0
    fsqrt d0,d0
    ldr d1,.LC5
    fmul d0,d1,d0
    ldr d1,.LC0
    fadd d0,d1,d0
    str d0,[x29,#1488]
    ldr d1,[x29,#1552]
    fmul d1,d1,d0
    str d1,[x29,#1552]
    ldr x9,[x29,#672]
    ldr w9,[x9,#112]
    cmp w9,#0
    b.le .Lstandardcrit71
    ldr x16,[x29,#648]
    ldr w9,[x16,#1112]
    cbnz w9,.Llocalcrit73
    ldr x16,[x29,#648]
    ldr w9,[x16,#1116]
    cbz w9,.Lstandardcrit71
    ldr x16,[x29,#1000]
    ldr w9,[x16,x23,lsl #2]
    sub x27,x9,#1
    ldr x16,[x29,#984]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d4,[x16,x10,lsl #3]
    b .Lcritdone72_phase
.Llocalcrit73:
    ldr x16,[x29,#984]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d4,[x16,x10,lsl #3]
.Lcritdone72_phase:
    str d4,[x29,#1536]
    ldr x16,[x29,#880]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    adrp x9,:got:__yoethf_MOD_rtwat
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rtwat]
    ldr d1,[x9]
    adrp x9,:got:__yoethf_MOD_rticecu
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rticecu]
    ldr d2,[x9]
    adrp x9,:got:__yoethf_MOD_rtwat_rticecu_r
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rtwat_rticecu_r]
    ldr d3,[x9]
    fmin d0,d1,d0
    fmax d0,d2,d0
    fsub d0,d0,d2
    fmul d0,d0,d3
    fmul d0,d0,d0
    ldr d1,.LC0
    fmin d0,d1,d0
    ldr d4,[x29,#1536]
    fmul d4,d0,d4
    ldr d1,.LC0
    fsub d0,d1,d0
    ldr d1,.LC19
    fmul d0,d0,d1
    fadd d0,d4,d0
    b .Lcritdone72
.Lstandardcrit71:
    ldr d0,.LC19
    ldr d1,[x29,#1488]
    fdiv d0,d0,d1
.Lcritdone72:
    str d0,[x29,#1488]
    ldr x16,[x29,#792]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#792]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fsub d1,d1,d2
    str d1,[x29,#1520]
    ldr x16,[x29,#896]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#1136]
    ldr d2,[x16,x23,lsl #3]
    fsub d2,d1,d2
    str d2,[x29,#1544]
    fdiv d0,d1,d0
    fmul d0,d0,d0
    fneg d0,d0
    bl exp
    ldr d1,.LC0
    fsub d0,d1,d0
    ldr d1,[x29,#1552]
    ldr d2,[x29,#1520]
    fmul d0,d1,d0
    fmul d0,d0,d2
    str d0,[x29,#1552]
    fneg d0,d0
    bl exp
    str d0,[x29,#1528]
    ldr x16,[x29,#1136]
    ldr d1,[x16,x23,lsl #3]
    fmul d1,d1,d0
    ldr d2,.LC0
    fsub d0,d2,d0
    ldr d2,[x29,#1544]
    ldr d3,[x29,#1552]
    fdiv d2,d2,d3
    fmul d0,d2,d0
    fadd d0,d1,d0
    ldr x16,[x29,#896]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmin d0,d1,d0
    ldr d1,.LC3
    fmax d0,d1,d0
    ldr d1,.LC22
    fmin d0,d1,d0
    str d0,[x29,#1536]
    ldr x16,[x29,#1136]
    ldr d1,[x16,x23,lsl #3]
    ldr d2,[x29,#1544]
    fadd d1,d1,d2
    fsub d1,d1,d0
    ldr d2,.LC3
    fmax d1,d2,d1
    ldr x16,[x29,#1128]
    str d1,[x16,x23,lsl #3]
    ldr x16,[x29,#912]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fmul d2,d1,d2
    ldr x16,[x29,#976]
    mov x10,x22
    madd x10,x10,x20,x23
    str d2,[x16,x10,lsl #3]
    ldr x16,[x29,#904]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fadd d2,d2,d1
    ldr x16,[x29,#904]
    mov x10,x22
    madd x10,x10,x20,x23
    str d2,[x16,x10,lsl #3]
    ldr d0,[x29,#1536]
    ldr x16,[x29,#896]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
.Lnoprecip68:
    add x23,x23,#1
    b .Lprecipitation66
.Lprecipitationend67:
    mov x23,x19
.Lrain_removal74:
    cmp x23,x24
    b.ge .Lrain_removalend75
    ldr x16,[x29,#1176]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lnorain76
    ldr x16,[x29,#904]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fcmp d0,#0.0
    b.le .Lnorain76
    ldr d1,.LC23
    bl md2asm_pow_original_rounding_candidate
    ldr d1,.LC24
    fmul d0,d1,d0
    str d0,[x29,#1520]
    ldr x16,[x29,#880]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    adrp x9,:got:__yoethf_MOD_rtwat
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rtwat]
    ldr d1,[x9]
    adrp x9,:got:__yoethf_MOD_rticecu
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rticecu]
    ldr d2,[x9]
    adrp x9,:got:__yoethf_MOD_rtwat_rticecu_r
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rtwat_rticecu_r]
    ldr d3,[x9]
    fmin d0,d1,d0
    fmax d0,d2,d0
    fsub d0,d0,d2
    fmul d0,d0,d3
    fmul d0,d0,d0
    ldr d1,.LC0
    fmin d0,d1,d0
    ldr x16,[x29,#872]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lrainmixed77
    ldr d0,.LC0
.Lrainmixed77:
    ldr d1,[x29,#1520]
    fmul d2,d0,d1
    ldr d3,.LC5
    fmul d1,d3,d1
    ldr d3,.LC0
    fsub d0,d3,d0
    fmul d0,d0,d1
    fadd d0,d2,d0
    str d0,[x29,#1488]
    ldr x16,[x29,#904]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1128]
    ldr d1,[x16,x23,lsl #3]
    fsub d0,d0,d1
    str d0,[x29,#1536]
    ldr x16,[x29,#1040]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr d1,.LC25
    fmax d0,d1,d0
    ldr d1,.LC20
    fmul d0,d1,d0
    fsqrt d0,d0
    ldr d1,.LC21
    fmin d0,d1,d0
    ldr d1,[x29,#1488]
    fdiv d0,d1,d0
    str d0,[x29,#1552]
    fneg d0,d0
    bl exp
    str d0,[x29,#1528]
    ldr d1,[x29,#1536]
    fmul d1,d1,d0
    ldr d2,.LC0
    fsub d0,d2,d0
    ldr x16,[x29,#1128]
    ldr d2,[x16,x23,lsl #3]
    ldr d3,[x29,#1552]
    fdiv d2,d2,d3
    fmul d0,d2,d0
    fadd d0,d1,d0
    ldr x16,[x29,#904]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmin d0,d1,d0
    ldr d1,.LC3
    fmax d0,d1,d0
    ldr x16,[x29,#904]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
.Lnorain76:
    add x23,x23,#1
    b .Lrain_removal74
.Lrain_removalend75:
    mov x23,x19
.Lfinal_fluxes78:
    cmp x23,x24
    b.ge .Lfinal_fluxesend79
    ldr x16,[x29,#1168]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lnoflux80
    ldr x16,[x29,#896]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#912]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmul d0,d0,d1
    ldr x16,[x29,#952]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#880]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#792]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fmul d0,d8,d0
    fadd d0,d0,d2
    fmul d0,d0,d1
    ldr x16,[x29,#936]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#888]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d0,d1
    ldr x16,[x29,#944]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#880]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    adrp x9,:got:__yoethf_MOD_rtwat
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rtwat]
    ldr d1,[x9]
    adrp x9,:got:__yoethf_MOD_rticecu
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rticecu]
    ldr d2,[x9]
    adrp x9,:got:__yoethf_MOD_rtwat_rticecu_r
    ldr x9,[x9,:got_lo12:__yoethf_MOD_rtwat_rticecu_r]
    ldr d3,[x9]
    fmin d0,d1,d0
    fmax d0,d2,d0
    fsub d0,d0,d2
    fmul d0,d0,d3
    fmul d0,d0,d0
    ldr d1,.LC0
    fmin d0,d1,d0
    ldr x16,[x29,#872]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lfluxmixed81
    ldr d0,.LC0
.Lfluxmixed81:
    ldr x16,[x29,#960]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmul d2,d0,d1
    ldr x16,[x29,#968]
    mov x10,x22
    madd x10,x10,x20,x23
    str d2,[x16,x10,lsl #3]
    ldr d2,.LC0
    fsub d0,d2,d0
    fmul d0,d0,d1
    ldr x16,[x29,#968]
    mov x10,x22
    madd x10,x10,x20,x23
    madd x10,x20,x21,x10
    str d0,[x16,x10,lsl #3]
.Lnoflux80:
    add x23,x23,#1
    b .Lfinal_fluxes78
.Lfinal_fluxesend79:
.Lnext_level:
    sub x22,x22,#1
    cmp x22,#2
    b.ge .Lascent_level
    mov x23,x19
.Lfinalize82:
    cmp x23,x24
    b.ge .Lfinalizeend83
    ldr x16,[x29,#1008]
    ldr w9,[x16,x23,lsl #2]
    cmn w9,#1
    b.ne .Lhastop84
    mov w10,#0
    ldr x16,[x29,#848]
    str w10,[x16,x23,lsl #2]
.Lhastop84:
    ldr x16,[x29,#1008]
    ldr w9,[x16,x23,lsl #2]
    ldr x16,[x29,#1000]
    ldr w10,[x16,x23,lsl #2]
    cmp w10,w9
    csel w9,w10,w9,ge
    ldr x16,[x29,#1000]
    str w9,[x16,x23,lsl #2]
    ldr x16,[x29,#848]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Linactivefinal85
    ldr x16,[x29,#1048]
    ldr d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1144]
    ldr d1,[x16,x23,lsl #3]
    ldr d2,.LC0
    fmax d1,d2,d1
    fdiv d0,d0,d1
    ldr d1,.LC26
    fmax d0,d1,d0
    ldr d1,.LC20
    fmul d0,d1,d0
    fsqrt d0,d0
    ldr x16,[x29,#1048]
    str d0,[x16,x23,lsl #3]
.Linactivefinal85:
    add x23,x23,#1
    b .Lfinalize82
.Lfinalizeend83:
    mov sp,x29
.Lreturn:
    add x16,x29,#1792
    ldp x29,x30,[x16]
    ldp x19,x20,[x16,#16]
    ldp x21,x22,[x16,#32]
    ldp x23,x24,[x16,#48]
    ldp x25,x26,[x16,#64]
    ldp x27,x28,[x16,#80]
    ldp d8,d9,[x16,#96]
    ldp d10,d11,[x16,#112]
    ldp d12,d13,[x16,#128]
    ldp d14,d15,[x16,#144]
    add sp,sp,#2048
    ret
.Ldomain:
    mov w0,#116
    bl _exit
    brk #0
.size CUASCN_SYMBOL,.-CUASCN_SYMBOL
.p2align 3
.LC0:
    .quad 0x3ff0000000000000
.LC1:
    .quad 0x3fd5555555555555
.LC2:
    .quad 0x3fee5c28f5c28f5c
.LC3:
    .quad 0x0000000000000000
.LC4:
    .quad 0x40e3880000000000
.LC5:
    .quad 0x3fe0000000000000
.LC6:
    .quad 0x3fe8000000000000
.LC7:
    .quad 0x3fd999999999999a
.LC8:
    .quad 0x3ff999999999999a
.LC9:
    .quad 0x4059000000000000
.LC10:
    .quad 0x4079000000000000
.LC11:
    .quad 0xbfe0000000000000
.LC12:
    .quad 0xbfb999999999999a
.LC13:
    .quad 0xc08f400000000000
.LC14:
    .quad 0x3f50624dd2f1a9fc
.LC15:
    .quad 0xbfc999999999999a
.LC16:
    .quad 0x3fd3333333333333
.LC17:
    .quad 0xc000000000000000
.LC18:
    .quad 0xbf689374bc6a7efa
.LC19:
    .quad 0x3f33a92a30553261
.LC20:
    .quad 0x4000000000000000
.LC21:
    .quad 0x402e000000000000
.LC22:
    .quad 0x3f747ae147ae147b
.LC23:
    .quad 0x3fc999999999999a
.LC24:
    .quad 0x40352e147ae147ae
.LC25:
    .quad 0x3fb999999999999a
.LC26:
    .quad 0x3f847ae147ae147b
.section .note.GNU-stack,"",%progbits
