/* Boundary-layer height and dry updraft flux.
 * Physics input is formulations/openifs/physics/boundary_layer_height.md.
 * Contract is skills/md2asm/references/openifs/physics/vdfhghtn.md.
 * Forty ordinary pointer arguments follow the Arm procedure-call standard.
 * The parent streams one column and calls complete accepted numerical children.
 * Every solver multiply, sum and division rounds separately in FP64. */
#ifndef VDFHGHTN_SYMBOL
#define VDFHGHTN_SYMBOL vdfhghtn_
#endif
.text
.p2align 4
.global VDFHGHTN_SYMBOL
.type VDFHGHTN_SYMBOL,%function
VDFHGHTN_SYMBOL:
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
    str x0,[x29,#256]
    str x1,[x29,#264]
    str x2,[x29,#272]
    str x3,[x29,#280]
    str x4,[x29,#288]
    str x5,[x29,#296]
    str x6,[x29,#304]
    str x7,[x29,#312]
    ldr x9,[x29,#2048]
    str x9,[x29,#320]
    ldr x9,[x29,#2056]
    str x9,[x29,#328]
    ldr x9,[x29,#2064]
    str x9,[x29,#336]
    ldr x9,[x29,#2072]
    str x9,[x29,#344]
    ldr x9,[x29,#2080]
    str x9,[x29,#352]
    ldr x9,[x29,#2088]
    str x9,[x29,#360]
    ldr x9,[x29,#2096]
    str x9,[x29,#368]
    ldr x9,[x29,#2104]
    str x9,[x29,#376]
    ldr x9,[x29,#2112]
    str x9,[x29,#384]
    ldr x9,[x29,#2120]
    str x9,[x29,#392]
    ldr x9,[x29,#2128]
    str x9,[x29,#400]
    ldr x9,[x29,#2136]
    str x9,[x29,#408]
    ldr x9,[x29,#2144]
    str x9,[x29,#416]
    ldr x9,[x29,#2152]
    str x9,[x29,#424]
    ldr x9,[x29,#2160]
    str x9,[x29,#432]
    ldr x9,[x29,#2168]
    str x9,[x29,#440]
    ldr x9,[x29,#2176]
    str x9,[x29,#448]
    ldr x9,[x29,#2184]
    str x9,[x29,#456]
    ldr x9,[x29,#2192]
    str x9,[x29,#464]
    ldr x9,[x29,#2200]
    str x9,[x29,#472]
    ldr x9,[x29,#2208]
    str x9,[x29,#480]
    ldr x9,[x29,#2216]
    str x9,[x29,#488]
    ldr x9,[x29,#2224]
    str x9,[x29,#496]
    ldr x9,[x29,#2232]
    str x9,[x29,#504]
    ldr x9,[x29,#2240]
    str x9,[x29,#512]
    ldr x9,[x29,#2248]
    str x9,[x29,#520]
    ldr x9,[x29,#2256]
    str x9,[x29,#528]
    ldr x9,[x29,#2264]
    str x9,[x29,#536]
    ldr x9,[x29,#2272]
    str x9,[x29,#544]
    ldr x9,[x29,#2280]
    str x9,[x29,#552]
    ldr x9,[x29,#2288]
    str x9,[x29,#560]
    ldr x9,[x29,#2296]
    str x9,[x29,#568]
    mrs x9,fpcr
    cbnz x9,.Ldomain
    ldr x9,[x29,#256]
    ldr w9,[x9,#4]
    cbnz w9,.Ldomain
    ldr x9,[x29,#296]
    ldr w19,[x9]
    ldr x9,[x29,#304]
    ldr w23,[x9]
    ldr x9,[x29,#312]
    ldr w20,[x9]
    ldr x9,[x29,#320]
    ldr w21,[x9]
    cmp w20,#1
    b.lt .Ldomain
    cmp w20,#4096
    b.gt .Ldomain
    cmp w21,#2
    b.lt .Ldomain
    cmp w21,#1024
    b.gt .Ldomain
    cmp w19,#1
    b.lt .Ldomain
    cmp w23,w20
    b.gt .Ldomain
    cmp w19,w23
    b.gt .Lreturn
    sub w19,w19,#1
    mov w9,#1
    str w9,[x29,#880]
    str w21,[x29,#884]
    str w9,[x29,#888]
    str w9,[x29,#892]
    ldr x9,[x29,#272]
    ldr w10,[x9,#312]
    cmp w10,#1
    b.lt .Ldomain
    cmp w10,w21
    b.ge .Ldomain
    str w10,[x29,#1040]
    ldr w10,[x9,#316]
    cmp w10,#1
    b.lt .Ldomain
    cmp w10,w21
    b.gt .Ldomain
    str w10,[x29,#1044]
    ldr w10,[x9,#324]
    cmp w10,#1
    b.lt .Ldomain
    cmp w10,w21
    b.gt .Ldomain
    str w10,[x29,#1048]
    ldr w10,[x9,#328]
    cmp w10,#1
    b.lt .Ldomain
    cmp w10,w21
    b.gt .Ldomain
    str w10,[x29,#1052]
    ldr x9,[x29,#328]
    ldr d0,[x9]
    fcmp d0,#0.0
    b.le .Ldomain
    b.vs .Ldomain
    ldr x9,[x29,#288]
    ldr w10,[x9,#216]
    cmp w10,#0
    b.lt .Ldomain
    cmp w10,#4096
    b.gt .Ldomain
    str w10,[x29,#1056]
    ldr w11,[x9]
    cbz w11,.Lspp_ready
    ldr x12,[x9,#352]
    cbz x12,.Ldomain
    ldr x13,[x9,#368]
    cmp x13,#184
    b.ne .Ldomain
    ldr x13,[x9,#392]
    cmp x13,#1
    b.ne .Ldomain
    ldr x13,[x9,#400]
    ldr x14,[x9,#408]
    ldrsw x11,[x9,#492]
    cbz x11,.Lspp_skip492
    cmp x11,x13
    b.lt .Ldomain
    cmp x11,x14
    b.gt .Ldomain
.Lspp_skip492:
    ldrsw x11,[x9,#500]
    cbz x11,.Lspp_skip500
    cmp x11,x13
    b.lt .Ldomain
    cmp x11,x14
    b.gt .Ldomain
.Lspp_skip500:
.Lspp_ready:
    adrp x16,:got:__yomcst_MOD_rcpd
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rcpd]
    ldr d10,[x16]
    adrp x16,:got:__yomcst_MOD_retv
    ldr x16,[x16,:got_lo12:__yomcst_MOD_retv]
    ldr d11,[x16]
    adrp x16,:got:__yomcst_MOD_rd
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rd]
    ldr d12,[x16]
    adrp x16,:got:__yoethf_MOD_rvtmp2
    ldr x16,[x16,:got_lo12:__yoethf_MOD_rvtmp2]
    ldr d14,[x16]
    adrp x16,:got:__yomcst_MOD_rg
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rg]
    ldr d0,[x16]
    fmov d1,#1.0
    fdiv d8,d1,d0
    fdiv d9,d1,d10
    ldr x9,[x29,#328]
    ldr d1,[x9]
    fmul d0,d0,d1
    fmov d1,#3.0
    fdiv d15,d1,d0
    add x22,x21,#1
    lsl x22,x22,#3
    mov x9,#25
    mul x28,x22,x9
    ldr w9,[x29,#1056]
    add x28,x28,x9,lsl #3
    add x28,x28,#271
    and x28,x28,#-16
    sub sp,sp,x28
    add x24,sp,#256
    mov x9,x24
    str x9,[x29,#576]
    add x9,x9,x22
    str x9,[x29,#584]
    add x9,x9,x22
    str x9,[x29,#592]
    add x9,x9,x22
    str x9,[x29,#600]
    add x9,x9,x22
    str x9,[x29,#608]
    add x9,x9,x22
    str x9,[x29,#616]
    add x9,x9,x22
    str x9,[x29,#624]
    add x9,x9,x22
    str x9,[x29,#632]
    add x9,x9,x22
    str x9,[x29,#640]
    add x9,x9,x22
    str x9,[x29,#648]
    add x9,x9,x22
    str x9,[x29,#656]
    add x9,x9,x22
    str x9,[x29,#664]
    add x9,x9,x22
    str x9,[x29,#672]
    add x9,x9,x22
    str x9,[x29,#680]
    add x9,x9,x22
    str x9,[x29,#688]
    add x9,x9,x22
    str x9,[x29,#696]
    add x9,x9,x22
    str x9,[x29,#704]
    add x9,x9,x22
    str x9,[x29,#712]
    add x9,x9,x22
    str x9,[x29,#720]
    add x9,x9,x22
    str x9,[x29,#728]
    add x9,x9,x22
    str x9,[x29,#736]
    add x9,x9,x22
    str x9,[x29,#744]
    add x9,x9,x22
    str x9,[x29,#752]
    add x9,x9,x22
    str x9,[x29,#760]
    add x9,x9,x22
    str x9,[x29,#768]
    add x9,x9,x22
    str x9,[x29,#776]
.Lcolumn:
    mov x25,#0
.Lgather_full:
    ldr x9,[x29,#344]
    madd x10,x25,x20,x19
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x29,#576]
    str d0,[x9,x25,lsl #3]
    ldr x9,[x29,#352]
    madd x10,x25,x20,x19
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x29,#584]
    str d0,[x9,x25,lsl #3]
    ldr x9,[x29,#368]
    madd x10,x25,x20,x19
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x29,#592]
    str d0,[x9,x25,lsl #3]
    ldr x9,[x29,#376]
    madd x10,x25,x20,x19
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x29,#600]
    str d0,[x9,x25,lsl #3]
    ldr x9,[x29,#408]
    madd x10,x25,x20,x19
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x29,#608]
    str d0,[x9,x25,lsl #3]
    ldr x9,[x29,#400]
    madd x10,x25,x20,x19
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x29,#616]
    str d0,[x9,x25,lsl #3]
    ldr x9,[x29,#584]
    ldr d0,[x9,x25,lsl #3]
    ldr x9,[x29,#640]
    str d0,[x9,x25,lsl #3]
    add x25,x25,#1
    cmp x25,x21
    b.lt .Lgather_full
    mov x25,#0
.Lgather_half:
    ldr x9,[x29,#392]
    madd x10,x25,x20,x19
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x29,#624]
    str d0,[x9,x25,lsl #3]
    ldr x9,[x29,#416]
    madd x10,x25,x20,x19
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x29,#632]
    str d0,[x9,x25,lsl #3]
    movi d0,#0
    ldr x9,[x29,#648]
    str d0,[x9,x25,lsl #3]
    ldr x9,[x29,#656]
    str d0,[x9,x25,lsl #3]
    add x25,x25,#1
    cmp x25,x21
    b.le .Lgather_half
    mov x25,#0
    ldr w27,[x29,#1056]
    cbz w27,.Lgather_pgp_done
.Lgather_pgp:
    ldr x9,[x29,#456]
    madd x10,x25,x20,x19
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x29,#776]
    str d0,[x9,x25,lsl #3]
    add x25,x25,#1
    cmp x25,x27
    b.lt .Lgather_pgp
.Lgather_pgp_done:
    mov x25,#0
.Lrichardson:
    ldr x9,[x29,#408]
    madd x10,x25,x20,x19
    ldr d0,[x9,x10,lsl #3]
    add x11,x25,#1
    ldr x9,[x29,#408]
    madd x10,x11,x20,x19
    ldr d1,[x9,x10,lsl #3]
    fsub d2,d0,d1
    ldr x9,[x29,#368]
    madd x10,x25,x20,x19
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x29,#368]
    madd x10,x11,x20,x19
    ldr d1,[x9,x10,lsl #3]
    fsub d0,d0,d1
    fmul d3,d0,d0
    ldr x9,[x29,#376]
    madd x10,x25,x20,x19
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x29,#376]
    madd x10,x11,x20,x19
    ldr d1,[x9,x10,lsl #3]
    fsub d0,d0,d1
    fmul d0,d0,d0
    fadd d3,d3,d0
    adrp x16,.LC0
    ldr d0,[x16,:lo12:.LC0]
    fmaxnm d3,d3,d0
    ldr x9,[x29,#384]
    madd x10,x25,x20,x19
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x29,#384]
    madd x10,x11,x20,x19
    ldr d1,[x9,x10,lsl #3]
    fsub d4,d0,d1
    fmov d5,#2.0
    fmul d4,d5,d4
    fadd d5,d0,d1
    ldr x9,[x29,#408]
    madd x10,x25,x20,x19
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x29,#408]
    madd x10,x11,x20,x19
    ldr d1,[x9,x10,lsl #3]
    fsub d5,d5,d0
    fsub d5,d5,d1
    fdiv d4,d4,d5
    ldr x9,[x29,#352]
    madd x10,x25,x20,x19
    ldr d0,[x9,x10,lsl #3]
    ldr x9,[x29,#352]
    madd x10,x11,x20,x19
    ldr d1,[x9,x10,lsl #3]
    fsub d0,d0,d1
    fmul d0,d11,d0
    fadd d4,d4,d0
    fmul d0,d2,d4
    fdiv d0,d0,d3
    ldr x9,[x29,#552]
    madd x10,x25,x20,x19
    str d0,[x9,x10,lsl #3]
    add x25,x25,#1
    sub x9,x21,#1
    cmp x25,x9
    b.lt .Lrichardson
    movi d0,#0
    ldr x9,[x29,#552]
    madd x10,x25,x20,x19
    str d0,[x9,x10,lsl #3]
    add x0,x29,#880
    add x1,x29,#880
    add x2,x29,#880
    add x3,x29,#1040
    add x4,x29,#884
    ldr x5,[x29,#256]
    add x5,x5,#4
    ldr x6,[x29,#616]
    ldr x7,[x29,#576]
    ldr x9,[x29,#640]
    str x9,[sp,#0]
    add x9,x29,#892
    str x9,[sp,#8]
    bl md2asm_satur_7240564
    ldr x0,[x29,#256]
    ldr x1,[x29,#272]
    add x2,x29,#880
    add x3,x29,#880
    add x4,x29,#880
    add x5,x29,#884
    ldr x6,[x29,#576]
    ldr x7,[x29,#584]
    ldr x9,[x29,#640]
    str x9,[sp,#0]
    ldr x9,[x29,#592]
    str x9,[sp,#8]
    ldr x9,[x29,#600]
    str x9,[sp,#16]
    ldr x9,[x29,#608]
    str x9,[sp,#24]
    ldr x9,[x29,#624]
    str x9,[sp,#32]
    ldr x9,[x29,#768]
    str x9,[sp,#40]
    ldr x9,[x29,#664]
    str x9,[sp,#48]
    ldr x9,[x29,#672]
    str x9,[sp,#56]
    ldr x9,[x29,#680]
    str x9,[sp,#64]
    ldr x9,[x29,#632]
    str x9,[sp,#72]
    ldr x9,[x29,#688]
    str x9,[sp,#80]
    ldr x9,[x29,#696]
    str x9,[sp,#88]
    ldr x9,[x29,#712]
    str x9,[sp,#96]
    ldr x9,[x29,#720]
    str x9,[sp,#104]
    ldr x9,[x29,#752]
    str x9,[sp,#112]
    ldr x9,[x29,#760]
    str x9,[sp,#120]
    ldr x9,[x29,#728]
    str x9,[sp,#128]
    ldr x9,[x29,#736]
    str x9,[sp,#136]
    ldr x9,[x29,#704]
    str x9,[sp,#144]
    bl md2asm_cuinin
    sub x25,x21,#1
    ldr x9,[x29,#576]
    ldr d0,[x9,x25,lsl #3]
    fmul d0,d12,d0
    ldr x9,[x29,#584]
    ldr d1,[x9,x25,lsl #3]
    fmul d1,d11,d1
    fmov d2,#1.0
    fadd d1,d2,d1
    fmul d0,d0,d1
    mov x25,x21
    ldr x9,[x29,#624]
    ldr d1,[x9,x25,lsl #3]
    fdiv d2,d1,d0
    ldr x9,[x29,#440]
    ldr d0,[x9,x19,lsl #3]
    str d0,[x29,#952]
    fmul d0,d0,d10
    fmul d0,d0,d2
    ldr x9,[x29,#648]
    str d0,[x9,x25,lsl #3]
    ldr x9,[x29,#448]
    ldr d0,[x9,x19,lsl #3]
    str d0,[x29,#960]
    fmul d0,d0,d2
    ldr x9,[x29,#656]
    str d0,[x9,x25,lsl #3]
    ldr x9,[x29,#432]
    ldr d0,[x9,x19,lsl #3]
    str d0,[x29,#944]
    ldr x0,[x29,#256]
    ldr x1,[x29,#264]
    ldr x2,[x29,#272]
    ldr x3,[x29,#288]
    add x4,x29,#880
    add x5,x29,#880
    add x6,x29,#880
    add x7,x29,#884
    add x9,x29,#884
    str x9,[sp,#0]
    add x9,x29,#888
    str x9,[sp,#8]
    ldr x9,[x29,#664]
    str x9,[sp,#16]
    ldr x9,[x29,#672]
    str x9,[sp,#24]
    ldr x9,[x29,#632]
    str x9,[sp,#32]
    ldr x9,[x29,#624]
    str x9,[sp,#40]
    ldr x9,[x29,#656]
    str x9,[sp,#48]
    ldr x9,[x29,#648]
    str x9,[sp,#56]
    ldr x9,[x29,#776]
    str x9,[sp,#64]
    add x9,x29,#944
    str x9,[sp,#72]
    ldr x9,[x29,#576]
    str x9,[sp,#80]
    ldr x9,[x29,#584]
    str x9,[sp,#88]
    ldr x9,[x29,#640]
    str x9,[sp,#96]
    ldr x9,[x29,#608]
    str x9,[sp,#104]
    ldr x9,[x29,#688]
    str x9,[sp,#112]
    ldr x9,[x29,#696]
    str x9,[sp,#120]
    ldr x9,[x29,#704]
    str x9,[sp,#128]
    ldr x9,[x29,#744]
    str x9,[sp,#136]
    add x9,x29,#896
    str x9,[sp,#144]
    ldr x9,[x29,#768]
    str x9,[sp,#152]
    add x9,x29,#912
    str x9,[sp,#160]
    add x9,x29,#916
    str x9,[sp,#168]
    add x9,x29,#920
    str x9,[sp,#176]
    add x9,x29,#924
    str x9,[sp,#184]
    add x9,x29,#928
    str x9,[sp,#192]
    add x9,x29,#932
    str x9,[sp,#200]
    add x9,x29,#904
    str x9,[sp,#208]
    bl md2asm_cubasen_7240564
    mov x25,#0
.Lenergy:
    ldr x9,[x29,#688]
    ldr d0,[x9,x25,lsl #3]
    ldr x9,[x29,#696]
    ldr d1,[x9,x25,lsl #3]
    fmul d2,d14,d1
    fmov d3,#1.0
    fadd d2,d3,d2
    fmul d2,d10,d2
    fmul d2,d2,d0
    ldr x9,[x29,#632]
    ldr d3,[x9,x25,lsl #3]
    fadd d2,d2,d3
    adrp x16,:got:__yomcst_MOD_rtt
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rtt]
    ldr d3,[x16]
    fsub d3,d0,d3
    fmov x10,d3
    tbz x10,#63,.Llatent_water
    adrp x16,:got:__yomcst_MOD_rlstt
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rlstt]
    ldr d3,[x16]
    b .Llatent_done
.Llatent_water:
    adrp x16,:got:__yomcst_MOD_rlvtt
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rlvtt]
    ldr d3,[x16]
.Llatent_done:
    ldr x9,[x29,#704]
    ldr d4,[x9,x25,lsl #3]
    fmul d3,d3,d4
    fsub d2,d2,d3
    ldr x9,[x29,#480]
    madd x10,x25,x20,x19
    str d2,[x9,x10,lsl #3]
    fadd d0,d1,d4
    ldr x9,[x29,#488]
    madd x10,x25,x20,x19
    str d0,[x9,x10,lsl #3]
    movi d0,#0
    ldr x9,[x29,#472]
    madd x10,x25,x20,x19
    str d0,[x9,x10,lsl #3]
    add x25,x25,#1
    cmp x25,x21
    b.lt .Lenergy
    sub x25,x21,#1
    ldr x9,[x29,#480]
    madd x10,x25,x20,x19
    ldr d0,[x9,x10,lsl #3]
    mov x25,x21
    ldr x9,[x29,#480]
    madd x10,x25,x20,x19
    str d0,[x9,x10,lsl #3]
    sub x25,x21,#1
    ldr x9,[x29,#488]
    madd x10,x25,x20,x19
    ldr d0,[x9,x10,lsl #3]
    mov x25,x21
    ldr x9,[x29,#488]
    madd x10,x25,x20,x19
    str d0,[x9,x10,lsl #3]
    sub x25,x21,#1
    ldr x9,[x29,#592]
    ldr d0,[x9,x25,lsl #3]
    mov x25,x21
    ldr x9,[x29,#752]
    str d0,[x9,x25,lsl #3]
    sub x25,x21,#1
    ldr x9,[x29,#600]
    ldr d0,[x9,x25,lsl #3]
    mov x25,x21
    ldr x9,[x29,#760]
    str d0,[x9,x25,lsl #3]
    sub x25,x21,#1
    mov x25,x21
    movi d0,#0
    ldr x9,[x29,#472]
    madd x10,x25,x20,x19
    str d0,[x9,x10,lsl #3]
    sub x25,x21,#1
    ldr x9,[x29,#576]
    ldr d0,[x9,x25,lsl #3]
    fmul d0,d11,d0
    ldr d1,[x29,#960]
    fmul d0,d0,d1
    ldr d1,[x29,#952]
    fadd d0,d1,d0
    str d0,[x29,#968]
    ldr w25,[x29,#1052]
    sub x25,x25,#1
    ldr x9,[x29,#360]
    madd x10,x25,x20,x19
    ldr d0,[x9,x10,lsl #3]
    ldr w25,[x29,#1044]
    sub x25,x25,#1
    ldr x9,[x29,#360]
    madd x10,x25,x20,x19
    ldr d1,[x9,x10,lsl #3]
    fsub d2,d0,d1
    sub x25,x21,#1
    ldr x9,[x29,#360]
    madd x10,x25,x20,x19
    ldr d0,[x9,x10,lsl #3]
    fsub d1,d1,d0
    fmaxnm d0,d2,d1
    fmul d0,d0,d9
    str d0,[x29,#976]
    sub w9,w21,#1
    str w9,[x29,#1008]
    str wzr,[x29,#1012]
    movi d0,#0
    str d0,[x29,#984]
    str d0,[x29,#992]
    adrp x16,.LC1
    ldr d0,[x16,:lo12:.LC1]
    str d0,[x29,#1000]
    ldr d0,[x29,#968]
    fcmp d0,#0.0
    b.ge .Lheight_done
    b.vs .Lheight_done
    sub x25,x21,#1
.Lheight_scan:
    ldr x9,[x29,#744]
    ldr d0,[x9,x25,lsl #3]
    fcmp d0,#0.0
    b.le .Lheight_scan_next
    b.vs .Lheight_scan_next
    ldr x9,[x29,#552]
    madd x10,x25,x20,x19
    ldr d0,[x9,x10,lsl #3]
    adrp x16,.LC2
    ldr d1,[x16,:lo12:.LC2]
    fcmp d0,d1
    b.ge .Lheight_scan_next
    b.vs .Lheight_scan_next
    str w25,[x29,#1008]
.Lheight_scan_next:
    sub x25,x25,#1
    cbnz x25,.Lheight_scan
    ldr w25,[x29,#1008]
    ldr x9,[x29,#632]
    ldr d0,[x9,x25,lsl #3]
    fmul d0,d0,d8
    str d0,[x29,#984]
    str d0,[x29,#992]
    mov w9,#1
    str w9,[x29,#1012]
    ldr w25,[x29,#920]
    cmp w25,#0
    b.le .Lheight_cap
    sub x25,x25,#1
    ldr x9,[x29,#632]
    ldr d0,[x9,x25,lsl #3]
    fmul d0,d0,d8
    str d0,[x29,#1000]
    str d0,[x29,#984]
    mov w9,#3
    str w9,[x29,#1012]
    ldr d0,[x29,#976]
    ldr x9,[x29,#280]
    ldr d1,[x9,#56]
    fcmp d0,d1
    b.le .Lheight_cap
    b.vs .Lheight_cap
    ldr x9,[x29,#624]
    ldr d0,[x9,x25,lsl #3]
    ldr w9,[x29,#928]
    ldr w10,[x29,#920]
    cmp w9,w10
    csel w25,w9,w10,ne
    cset w9,eq
    sub w25,w25,w9
    ldr x9,[x29,#624]
    ldr d1,[x9,x25,lsl #3]
    fsub d0,d0,d1
    ldr x9,[x29,#272]
    ldr d1,[x9,#136]
    fcmp d0,d1
    b.gt .Lheight_cap
    b.vs .Lheight_cap
    mov w9,#2
    str w9,[x29,#1012]
    str w25,[x29,#1008]
    ldr x9,[x29,#632]
    ldr d0,[x9,x25,lsl #3]
    fmul d0,d0,d8
    str d0,[x29,#992]
.Lheight_cap:
    ldr w25,[x29,#1048]
    sub x25,x25,#1
    ldr x9,[x29,#632]
    ldr d0,[x9,x25,lsl #3]
    fmul d0,d0,d8
    ldr d1,[x29,#992]
    fminnm d1,d0,d1
    str d1,[x29,#992]
    ldr d1,[x29,#984]
    fminnm d1,d0,d1
    str d1,[x29,#984]
.Lheight_done:
    ldr w9,[x29,#1008]
    add w9,w9,#1
    ldr w10,[x29,#1048]
    cmp w9,w10
    csel w9,w9,w10,ge
    str w9,[x29,#1008]
    ldr x9,[x29,#464]
    ldr d0,[x29,#968]
    str d0,[x9,x19,lsl #3]
    ldr x9,[x29,#512]
    ldr d0,[x29,#992]
    str d0,[x9,x19,lsl #3]
    ldr x9,[x29,#520]
    ldr w10,[x29,#1008]
    str w10,[x9,x19,lsl #2]
    ldr x9,[x29,#528]
    ldr w10,[x29,#920]
    str w10,[x9,x19,lsl #2]
    ldr x9,[x29,#536]
    ldr w10,[x29,#928]
    str w10,[x9,x19,lsl #2]
    ldr x9,[x29,#544]
    ldr d0,[x29,#1000]
    str d0,[x9,x19,lsl #3]
    ldr x9,[x29,#560]
    ldr d0,[x29,#976]
    str d0,[x9,x19,lsl #3]
    ldr x9,[x29,#568]
    ldr w10,[x29,#1012]
    str w10,[x9,x19,lsl #2]
    sub x25,x21,#1
    ldr x9,[x29,#632]
    ldr d0,[x9,x25,lsl #3]
    fmul d0,d0,d8
    str d0,[x29,#1016]
    ldr d1,[x29,#984]
    fcmp d1,d0
    b.le .Lmass_done
    b.vs .Lmass_done
    ldr w9,[x29,#1012]
    cmp w9,#1
    b.gt .Lmass_done
    ldr d0,[x29,#968]
    fneg d0,d0
    movi d1,#0
    fmaxnm d0,d0,d1
    adrp x16,.LC3
    ldr d1,[x16,:lo12:.LC3]
    fmul d0,d1,d0
    adrp x16,:got:__yomcst_MOD_rg
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rg]
    ldr d1,[x16]
    fmul d0,d0,d1
    ldr d1,[x29,#1016]
    fmul d0,d0,d1
    ldr x9,[x29,#576]
    ldr d1,[x9,x25,lsl #3]
    fdiv d0,d0,d1
    adrp x16,.LC4
    ldr d1,[x16,:lo12:.LC4]
    bl md2asm_pow_original_rounding_candidate
    str d0,[x29,#1032]
    ldr d0,[x29,#1016]
    ldr d1,[x29,#984]
    fdiv d0,d0,d1
    fmov d1,#1.0
    fsub d0,d1,d0
    fmov d1,#0.5
    bl md2asm_pow_original_rounding_candidate
    ldr d1,[x29,#1032]
    adrp x16,.LC5
    ldr d2,[x16,:lo12:.LC5]
    fmul d1,d2,d1
    fmul d3,d1,d0
    ldr x9,[x29,#576]
    ldr d0,[x9,x25,lsl #3]
    fmul d0,d12,d0
    ldr x9,[x29,#584]
    ldr d1,[x9,x25,lsl #3]
    fmul d1,d11,d1
    fmov d2,#1.0
    fadd d1,d2,d1
    fmul d0,d0,d1
    ldr x9,[x29,#616]
    ldr d1,[x9,x25,lsl #3]
    fdiv d0,d1,d0
    fmul d3,d3,d0
    sub x11,x25,#1
    ldr x9,[x29,#616]
    ldr d0,[x9,x11,lsl #3]
    fsub d1,d1,d0
    fmul d1,d1,d15
    fminnm d0,d3,d1
    ldr x9,[x29,#472]
    madd x10,x25,x20,x19
    str d0,[x9,x10,lsl #3]
    sub x25,x21,#2
.Lmass_profile:
    ldr x9,[x29,#632]
    ldr d0,[x9,x25,lsl #3]
    fmul d0,d0,d8
    ldr d1,[x29,#984]
    fcmp d0,d1
    b.ge .Lmass_profile_next
    b.vs .Lmass_profile_next
    cbz x25,.Ldomain
    fdiv d0,d0,d1
    fmov d1,#1.0
    fsub d0,d1,d0
    fmul d0,d0,d0
    ldr x9,[x29,#632]
    ldr d1,[x9,x25,lsl #3]
    sub x11,x21,#1
    ldr x9,[x29,#472]
    madd x10,x11,x20,x19
    ldr d2,[x9,x10,lsl #3]
    fmul d1,d2,d1
    ldr x9,[x29,#632]
    ldr d2,[x9,x11,lsl #3]
    fdiv d1,d1,d2
    fmul d3,d1,d0
    ldr x9,[x29,#616]
    ldr d0,[x9,x25,lsl #3]
    sub x11,x25,#1
    ldr x9,[x29,#616]
    ldr d1,[x9,x11,lsl #3]
    fsub d0,d0,d1
    fmul d0,d0,d15
    fminnm d0,d3,d0
    ldr x9,[x29,#472]
    madd x10,x25,x20,x19
    str d0,[x9,x10,lsl #3]
    add x11,x25,#1
    ldr x9,[x29,#472]
    madd x10,x11,x20,x19
    ldr d1,[x9,x10,lsl #3]
    fsub d1,d0,d1
    fmov x10,d1
    fmov d2,#1.0
    tbz x10,#63,.Lpositive_mass_delta
    fneg d2,d2
.Lpositive_mass_delta:
    adrp x16,.LC6
    ldr d3,[x16,:lo12:.LC6]
    fmul d3,d3,d2
    movi d4,#0
    fmaxnm d3,d4,d3
    adrp x16,.LC7
    ldr d5,[x16,:lo12:.LC7]
    fmul d5,d5,d2
    fmaxnm d5,d4,d5
    fmov d2,#0.5
    fmul d5,d5,d2
    fadd d3,d3,d5
    adrp x16,.LC8
    ldr d2,[x16,:lo12:.LC8]
    fadd d0,d0,d2
    fdiv d0,d1,d0
    fabs d0,d0
    fmul d3,d3,d0
    ldr x9,[x29,#752]
    ldr d0,[x9,x11,lsl #3]
    fmov d1,#1.0
    fsub d2,d1,d3
    fmul d0,d0,d2
    fmov d2,#2.0
    fmul d2,d2,d3
    ldr x9,[x29,#592]
    ldr d4,[x9,x25,lsl #3]
    fmul d2,d2,d4
    fadd d0,d0,d2
    fadd d1,d1,d3
    fdiv d0,d0,d1
    ldr x9,[x29,#752]
    str d0,[x9,x25,lsl #3]
    ldr x9,[x29,#760]
    ldr d0,[x9,x11,lsl #3]
    fmov d1,#1.0
    fsub d2,d1,d3
    fmul d0,d0,d2
    fmov d2,#2.0
    fmul d2,d2,d3
    ldr x9,[x29,#600]
    ldr d4,[x9,x25,lsl #3]
    fmul d2,d2,d4
    fadd d0,d0,d2
    fadd d1,d1,d3
    fdiv d0,d0,d1
    ldr x9,[x29,#760]
    str d0,[x9,x25,lsl #3]
    .Lmass_profile_next:
    subs x25,x25,#1
    b.ge .Lmass_profile
.Lmass_done:
    mov x25,#0
.Lreturn_wind:
    ldr x9,[x29,#752]
    ldr d0,[x9,x25,lsl #3]
    ldr x9,[x29,#496]
    madd x10,x25,x20,x19
    str d0,[x9,x10,lsl #3]
    ldr x9,[x29,#760]
    ldr d0,[x9,x25,lsl #3]
    ldr x9,[x29,#504]
    madd x10,x25,x20,x19
    str d0,[x9,x10,lsl #3]
    add x25,x25,#1
    cmp x25,x21
    b.le .Lreturn_wind
    add x19,x19,#1
    cmp x19,x23
    b.lt .Lcolumn
    mov sp,x29
.Lreturn:
    add x16,x29,#1792
    ldp x19,x20,[x16,#16]
    ldp x21,x22,[x16,#32]
    ldp x23,x24,[x16,#48]
    ldp x25,x26,[x16,#64]
    ldp x27,x28,[x16,#80]
    ldp d8,d9,[x16,#96]
    ldp d10,d11,[x16,#112]
    ldp d12,d13,[x16,#128]
    ldp d14,d15,[x16,#144]
    ldp x29,x30,[x16]
    add sp,sp,#2048
    ret
.Ldomain:
    mov w0,#116
    bl _exit
.size VDFHGHTN_SYMBOL,.-VDFHGHTN_SYMBOL
.section .rodata
.p2align 3
.LC0:
    .quad 0x3f847ae147ae147c
.LC1:
    .quad 0xc059000000000000
.LC2:
    .quad 0x4049000000000000
.LC3:
    .quad 0x3fe3333333333334
.LC4:
    .quad 0x3fd555475a31a4be
.LC5:
    .quad 0x3fbeb851eb851eb8
.LC6:
    .quad 0x3feccccccccccccd
.LC7:
    .quad 0xbfb999999999999a
.LC8:
    .quad 0x3ddb7cdfd9d7bdbb
.section .note.GNU-stack,"",%progbits
