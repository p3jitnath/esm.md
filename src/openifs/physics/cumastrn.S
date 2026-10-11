/* Complete deterministic normal-physics convection caller.
 * Physics is formulations/openifs/physics/convective_column_update.md.
 * Contract is skills/md2asm/references/openifs/physics/cumastrn.md.
 * Reuse complete direct children and preserve source level ordering.
 * Primary FP64 arithmetic rounds separately.
 * Active chemical tracer transport is outside this weather domain. */
#ifndef CUMASTRN_SYMBOL
#define CUMASTRN_SYMBOL cumastrn_
#endif
.text
.p2align 4
.global CUMASTRN_SYMBOL
.type CUMASTRN_SYMBOL,%function
CUMASTRN_SYMBOL:
    sub sp,sp,#4096
    add x16,sp,#3840
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
    ldr x9,[x29,#4096]
    str x9,[x29,#704]
    ldr x9,[x29,#4104]
    str x9,[x29,#712]
    ldr x9,[x29,#4112]
    str x9,[x29,#720]
    ldr x9,[x29,#4120]
    str x9,[x29,#728]
    ldr x9,[x29,#4128]
    str x9,[x29,#736]
    ldr x9,[x29,#4136]
    str x9,[x29,#744]
    ldr x9,[x29,#4144]
    str x9,[x29,#752]
    ldr x9,[x29,#4152]
    str x9,[x29,#760]
    ldr x9,[x29,#4160]
    str x9,[x29,#768]
    ldr x9,[x29,#4168]
    str x9,[x29,#776]
    ldr x9,[x29,#4176]
    str x9,[x29,#784]
    ldr x9,[x29,#4184]
    str x9,[x29,#792]
    ldr x9,[x29,#4192]
    str x9,[x29,#800]
    ldr x9,[x29,#4200]
    str x9,[x29,#808]
    ldr x9,[x29,#4208]
    str x9,[x29,#816]
    ldr x9,[x29,#4216]
    str x9,[x29,#824]
    ldr x9,[x29,#4224]
    str x9,[x29,#832]
    ldr x9,[x29,#4232]
    str x9,[x29,#840]
    ldr x9,[x29,#4240]
    str x9,[x29,#848]
    ldr x9,[x29,#4248]
    str x9,[x29,#856]
    ldr x9,[x29,#4256]
    str x9,[x29,#864]
    ldr x9,[x29,#4264]
    str x9,[x29,#872]
    ldr x9,[x29,#4272]
    str x9,[x29,#880]
    ldr x9,[x29,#4280]
    str x9,[x29,#888]
    ldr x9,[x29,#4288]
    str x9,[x29,#896]
    ldr x9,[x29,#4296]
    str x9,[x29,#904]
    ldr x9,[x29,#4304]
    str x9,[x29,#912]
    ldr x9,[x29,#4312]
    str x9,[x29,#920]
    ldr x9,[x29,#4320]
    str x9,[x29,#928]
    ldr x9,[x29,#4328]
    str x9,[x29,#936]
    ldr x9,[x29,#4336]
    str x9,[x29,#944]
    ldr x9,[x29,#4344]
    str x9,[x29,#952]
    ldr x9,[x29,#4352]
    str x9,[x29,#960]
    ldr x9,[x29,#4360]
    str x9,[x29,#968]
    ldr x9,[x29,#4368]
    str x9,[x29,#976]
    ldr x9,[x29,#4376]
    str x9,[x29,#984]
    ldr x9,[x29,#4384]
    str x9,[x29,#992]
    ldr x9,[x29,#4392]
    str x9,[x29,#1000]
    ldr x9,[x29,#4400]
    str x9,[x29,#1008]
    ldr x9,[x29,#4408]
    str x9,[x29,#1016]
    ldr x9,[x29,#4416]
    str x9,[x29,#1024]
    ldr x9,[x29,#4424]
    str x9,[x29,#1032]
    ldr x9,[x29,#4432]
    str x9,[x29,#1040]
    ldr x9,[x29,#4440]
    str x9,[x29,#1048]
    ldr x9,[x29,#4448]
    str x9,[x29,#1056]
    ldr x9,[x29,#4456]
    str x9,[x29,#1064]
    ldr x9,[x29,#4464]
    str x9,[x29,#1072]
    ldr x9,[x29,#4472]
    str x9,[x29,#1080]
    ldr x9,[x29,#4480]
    str x9,[x29,#1088]
    ldr x9,[x29,#4488]
    str x9,[x29,#1096]
    ldr x9,[x29,#4496]
    str x9,[x29,#1104]
    ldr x9,[x29,#4504]
    str x9,[x29,#1112]
    ldr x9,[x29,#4512]
    str x9,[x29,#1120]
    ldr x9,[x29,#4520]
    str x9,[x29,#1128]
    ldr x9,[x29,#4528]
    str x9,[x29,#1136]
    ldr x9,[x29,#4536]
    str x9,[x29,#1144]
    ldr x9,[x29,#4544]
    str x9,[x29,#1152]
    ldr x9,[x29,#4552]
    str x9,[x29,#1160]
    ldr x9,[x29,#4560]
    str x9,[x29,#1168]
    ldr x9,[x29,#4568]
    str x9,[x29,#1176]
    mrs x9,fpcr
    cbnz x9,.Ldomain
    ldr x16,[x29,#640]
    ldr w9,[x16,#4]
    cbnz w9,.Ldomain
    ldr x16,[x29,#672]
    ldr w9,[x16]
    cbnz w9,.Ldomain
    ldr x16,[x29,#648]
    add x9,x16,#3504
    str x9,[x29,#2120]
    add x9,x16,#712
    str x9,[x29,#2128]
    ldr w10,[x16,#140]
    ldr x16,[x29,#1152]
    ldr w9,[x16]
    cmp w9,#0
    b.lt .Ldomain
    cmp w9,#0
    cset w9,gt
    cmp w10,#0
    cset w10,ne
    and w9,w9,w10
    cbnz w9,.Ldomain
    ldr x16,[x29,#2120]
    ldr w9,[x16,#260]
    cbz w9,.Ldomain
    ldr x16,[x29,#680]
    ldr w19,[x16]
    ldr x16,[x29,#688]
    ldr w24,[x16]
    ldr x16,[x29,#696]
    ldr w20,[x16]
    ldr x16,[x29,#704]
    ldr w21,[x16]
    cmp w20,#1
    b.lt .Ldomain
    cmp w20,#4096
    b.gt .Ldomain
    cmp w21,#4
    b.lt .Ldomain
    cmp w21,#1024
    b.gt .Ldomain
    mul x9,x20,x21
    mov x10,#65536
    cmp x9,x10
    b.gt .Ldomain
    cmp w19,#1
    b.lt .Ldomain
    cmp w19,w20
    b.gt .Ldomain
    cmp w24,#0
    b.lt .Ldomain
    cmp w24,w20
    b.gt .Ldomain
    sub x19,x19,#1
    ldr x16,[x29,#720]
    ldr d0,[x16]
    fcmp d0,#0.0
    b.le .Ldomain
    b.vs .Ldomain
    adrp x16,:got:__yomcst_MOD_rg
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rg]
    ldr d1,[x16]
    fmul d0,d1,d0
    ldr x16,[x29,#2120]
    ldr d1,[x16,#56]
    fdiv d11,d1,d0
    ldr d1,.LC0
    fdiv d12,d1,d0
    adrp x16,:got:__yomcst_MOD_rcpd
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rcpd]
    ldr d8,[x16]
    fdiv d9,d1,d8
    adrp x16,:got:__yomcst_MOD_rd
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rd]
    ldr d0,[x16]
    fmul d13,d0,d9
    adrp x16,:got:__yomcst_MOD_rg
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rg]
    ldr d0,[x16]
    fdiv d10,d1,d0
    ldr x16,[x29,#2120]
    ldr w9,[x16,#308]
    cmp w9,#2
    b.lt .Ldomain
    cmp w9,w21
    b.gt .Ldomain
    ldr x16,[x29,#2120]
    ldr w9,[x16,#312]
    cmp w9,#2
    b.lt .Ldomain
    cmp w9,w21
    b.gt .Ldomain
    cmp w9,w21
    b.ge .Ldomain
    ldr x16,[x29,#2120]
    ldr w9,[x16,#316]
    cmp w9,#1
    b.lt .Ldomain
    cmp w9,w21
    b.gt .Ldomain
    ldr x16,[x29,#2120]
    ldr w9,[x16,#324]
    cmp w9,#1
    b.lt .Ldomain
    cmp w9,w21
    b.gt .Ldomain
    mul x9,x20,x21
    mov x10,#268
    mul x9,x9,x10
    mov x10,#248
    madd x9,x20,x10,x9
    add x9,x9,#15
    and x9,x9,#-16
    sub sp,sp,x9
    mov x26,sp
    str x26,[x29,#1184]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1192]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1200]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1208]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1216]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1224]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1232]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1240]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1248]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1256]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1264]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1272]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1280]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1288]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1296]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1304]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1312]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1320]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1328]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1336]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1344]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1352]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1360]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1368]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1376]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1384]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1392]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1400]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1408]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1416]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1424]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1432]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1440]
    mul x9,x20,x21
    add x26,x26,x9,lsl #3
    str x26,[x29,#1448]
    mul x9,x20,x21
    add x26,x26,x9,lsl #2
    str x26,[x29,#1456]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1464]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1472]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1480]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1488]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1496]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1504]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1512]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1520]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1528]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1536]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1544]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1552]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1560]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1568]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1576]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1584]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1592]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1600]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1608]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1616]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1624]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1632]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1640]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1648]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1656]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1664]
    add x26,x26,x20,lsl #3
    str x26,[x29,#1672]
    add x26,x26,x20,lsl #2
    str x26,[x29,#1680]
    add x26,x26,x20,lsl #2
    str x26,[x29,#1688]
    add x26,x26,x20,lsl #2
    str x26,[x29,#1696]
    add x26,x26,x20,lsl #2
    str x26,[x29,#1704]
    add x26,x26,x20,lsl #2
    str x26,[x29,#1712]
    add x26,x26,x20,lsl #2
    str x26,[x29,#1720]
    add x26,x26,x20,lsl #2
    str x26,[x29,#1728]
    add x26,x26,x20,lsl #2
    sub sp,sp,#512
    str wzr,[x29,#2144]
    mov x23,xzr
.Lallworkzero1:
    cmp x23,x20
    b.ge .Lallworkzeroend2
    ldr d0,.LC1
    ldr x16,[x29,#1592]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1648]
    str d0,[x16,x23,lsl #3]
    add x23,x23,#1
    b .Lallworkzero1
.Lallworkzeroend2:
    mov x23,x19
.Linitialize3:
    cmp x23,x24
    b.ge .Linitializeend4
    ldr d0,.LC1
    ldr x16,[x29,#1120]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1136]
    str d0,[x16,x23,lsl #3]
    mov w9,#0
    ldr x16,[x29,#904]
    str w9,[x16,x23,lsl #2]
    add x23,x23,#1
    b .Linitialize3
.Linitializeend4:
    ldr x9,[x29,#640]
    mov x0,x9
    ldr x9,[x29,#2120]
    mov x1,x9
    ldr x9,[x29,#680]
    mov x2,x9
    ldr x9,[x29,#688]
    mov x3,x9
    ldr x9,[x29,#696]
    mov x4,x9
    ldr x9,[x29,#704]
    mov x5,x9
    ldr x9,[x29,#728]
    mov x6,x9
    ldr x9,[x29,#736]
    mov x7,x9
    ldr x9,[x29,#776]
    str x9,[sp,#0]
    ldr x9,[x29,#744]
    str x9,[sp,#8]
    ldr x9,[x29,#752]
    str x9,[sp,#16]
    ldr x9,[x29,#816]
    str x9,[sp,#24]
    ldr x9,[x29,#808]
    str x9,[sp,#32]
    ldr x9,[x29,#1448]
    str x9,[sp,#40]
    ldr x9,[x29,#1184]
    str x9,[sp,#48]
    ldr x9,[x29,#1192]
    str x9,[sp,#56]
    ldr x9,[x29,#1216]
    str x9,[sp,#64]
    ldr x9,[x29,#824]
    str x9,[sp,#72]
    ldr x9,[x29,#992]
    str x9,[sp,#80]
    ldr x9,[x29,#1000]
    str x9,[sp,#88]
    ldr x9,[x29,#1224]
    str x9,[sp,#96]
    ldr x9,[x29,#1232]
    str x9,[sp,#104]
    ldr x9,[x29,#1296]
    str x9,[sp,#112]
    ldr x9,[x29,#1304]
    str x9,[sp,#120]
    ldr x9,[x29,#1312]
    str x9,[sp,#128]
    ldr x9,[x29,#1320]
    str x9,[sp,#136]
    ldr x9,[x29,#1008]
    str x9,[sp,#144]
    bl md2asm_cuinin
    ldr x9,[x29,#640]
    mov x0,x9
    ldr x9,[x29,#2128]
    mov x1,x9
    ldr x9,[x29,#2120]
    mov x2,x9
    ldr x9,[x29,#672]
    mov x3,x9
    ldr x9,[x29,#680]
    mov x4,x9
    ldr x9,[x29,#688]
    mov x5,x9
    ldr x9,[x29,#696]
    mov x6,x9
    ldr x9,[x29,#704]
    mov x7,x9
    ldr x9,[x29,#2120]
    add x9,x9,#308
    str x9,[sp,#0]
    add x9,x29,#2144
    str x9,[sp,#8]
    ldr x9,[x29,#1184]
    str x9,[sp,#16]
    ldr x9,[x29,#1192]
    str x9,[sp,#24]
    ldr x9,[x29,#824]
    str x9,[sp,#32]
    ldr x9,[x29,#808]
    str x9,[sp,#40]
    ldr x9,[x29,#784]
    str x9,[sp,#48]
    ldr x9,[x29,#792]
    str x9,[sp,#56]
    ldr x9,[x29,#848]
    str x9,[sp,#64]
    ldr x9,[x29,#1648]
    str x9,[sp,#72]
    ldr x9,[x29,#728]
    str x9,[sp,#80]
    ldr x9,[x29,#736]
    str x9,[sp,#88]
    ldr x9,[x29,#776]
    str x9,[sp,#96]
    ldr x9,[x29,#816]
    str x9,[sp,#104]
    ldr x9,[x29,#992]
    str x9,[sp,#112]
    ldr x9,[x29,#1000]
    str x9,[sp,#120]
    ldr x9,[x29,#1008]
    str x9,[sp,#128]
    ldr x9,[x29,#1328]
    str x9,[sp,#136]
    ldr x9,[x29,#1536]
    str x9,[sp,#144]
    ldr x9,[x29,#1448]
    str x9,[sp,#152]
    ldr x9,[x29,#904]
    str x9,[sp,#160]
    ldr x9,[x29,#968]
    str x9,[sp,#168]
    ldr x9,[x29,#920]
    str x9,[sp,#176]
    ldr x9,[x29,#960]
    str x9,[sp,#184]
    ldr x9,[x29,#1680]
    str x9,[sp,#192]
    ldr x9,[x29,#1688]
    str x9,[sp,#200]
    ldr x9,[x29,#1120]
    str x9,[sp,#208]
    bl md2asm_cubasen_7240564
    mov x23,x19
.Lpblinit5:
    cmp x23,x24
    b.ge .Lpblinitend6
    ldr d0,.LC1
    ldr x16,[x29,#1528]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1576]
    str d0,[x16,x23,lsl #3]
    mov w9,#0
    ldr x16,[x29,#1672]
    str w9,[x16,x23,lsl #2]
    ldr x16,[x29,#792]
    mov x10,x21
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fneg d0,d0
    fmul d0,d0,d9
    adrp x16,:got:__yomcst_MOD_retv
    ldr x16,[x16,:got_lo12:__yomcst_MOD_retv]
    ldr d1,[x16]
    ldr x16,[x29,#728]
    sub x10,x21,#1
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    ldr x16,[x29,#784]
    mov x10,x21
    madd x10,x10,x20,x23
    ldr d3,[x16,x10,lsl #3]
    fmul d1,d1,d2
    fmul d1,d1,d3
    fsub d0,d0,d1
    adrp x16,:got:__yomdyncore_MOD_rplrg
    ldr x16,[x16,:got_lo12:__yomdyncore_MOD_rplrg]
    ldr d1,[x16]
    adrp x16,:got:__yomdyncore_MOD_rpldare
    ldr x16,[x16,:got_lo12:__yomdyncore_MOD_rpldare]
    ldr d2,[x16]
    fmul d1,d1,d2
    fdiv d0,d0,d1
    ldr x16,[x29,#1480]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#792]
    mov x10,x21
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fneg d0,d0
    adrp x16,:got:__yomcst_MOD_rlvtt
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rlvtt]
    ldr d1,[x16]
    ldr x16,[x29,#784]
    mov x10,x21
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fmul d1,d1,d2
    fsub d0,d0,d1
    adrp x16,:got:__yomdyncore_MOD_rplrg
    ldr x16,[x16,:got_lo12:__yomdyncore_MOD_rplrg]
    ldr d1,[x16]
    adrp x16,:got:__yomdyncore_MOD_rpldare
    ldr x16,[x16,:got_lo12:__yomdyncore_MOD_rpldare]
    ldr d2,[x16]
    fmul d1,d1,d2
    fdiv d0,d0,d1
    ldr x16,[x29,#1488]
    str d0,[x16,x23,lsl #3]
    add x23,x23,#1
    b .Lpblinit5
.Lpblinitend6:
    ldr x16,[x29,#2120]
    ldr w22,[x16,#312]
    sub x22,x22,#1
    mov x22,x22
.Lpbllevels7:
    cmp x22,x21
    b.ge .Lpbllevelsend8
    mov x23,x19
.Lpblheat9:
    cmp x23,x24
    b.ge .Lpblheatend10
    ldr x16,[x29,#904]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lpblnone11
    ldr x16,[x29,#920]
    ldr w9,[x16,x23,lsl #2]
    add w10,w22,#1
    cmp w10,w9
    b.lt .Lpblnone11
    ldr x16,[x29,#808]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#808]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d2,d0,d1
    adrp x16,:got:__yomcst_MOD_rlvtt
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rlvtt]
    ldr d0,[x16]
    ldr x16,[x29,#864]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmul d0,d0,d1
    ldr x16,[x29,#856]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmul d1,d8,d1
    fadd d0,d0,d1
    fmul d0,d0,d2
    ldr x16,[x29,#1528]
    ldr d1,[x16,x23,lsl #3]
    fadd d0,d1,d0
    ldr x16,[x29,#1528]
    str d0,[x16,x23,lsl #3]
    adrp x16,:got:__yomcst_MOD_retv
    ldr x16,[x16,:got_lo12:__yomcst_MOD_retv]
    ldr d0,[x16]
    ldr x16,[x29,#728]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#864]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d3,[x16,x10,lsl #3]
    fmul d0,d0,d1
    fmul d0,d0,d3
    ldr x16,[x29,#856]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fadd d0,d1,d0
    fmul d0,d0,d2
    ldr x16,[x29,#1576]
    ldr d1,[x16,x23,lsl #3]
    fadd d0,d1,d0
    ldr x16,[x29,#1576]
    str d0,[x16,x23,lsl #3]
.Lpblnone11:
    add x23,x23,#1
    b .Lpblheat9
.Lpblheatend10:
    add x22,x22,#1
    b .Lpbllevels7
.Lpbllevelsend8:
    mov x23,x19
.Lclassify12:
    cmp x23,x24
    b.ge .Lclassifyend13
    ldr x16,[x29,#904]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lnobase14
    ldr x16,[x29,#920]
    ldr w9,[x16,x23,lsl #2]
    sub x27,x9,#1
    ldr x16,[x29,#1680]
    ldr w9,[x16,x23,lsl #2]
    sub x28,x9,#1
    ldr x16,[x29,#808]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#808]
    mov x10,x28
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d0,d0,d1
    ldr x16,[x29,#2120]
    ldr d1,[x16,#136]
    fcmp d0,d1
    mov w9,#2
    mov w10,#1
    csel w9,w10,w9,ge
    ldr x16,[x29,#912]
    str w9,[x16,x23,lsl #2]
    b .Lclassified15
.Lnobase14:
    mov w9,#0
    ldr x16,[x29,#912]
    str w9,[x16,x23,lsl #2]
.Lclassified15:
    add x23,x23,#1
    b .Lclassify12
.Lclassifyend13:
    ldr x16,[x29,#2120]
    ldr w9,[x16,#296]
    cbz w9,.Lnowstar16
    mov x23,x19
.Lwstar17:
    cmp x23,x24
    b.ge .Lwstarend18
    ldr x16,[x29,#904]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lwstarinactive19
    ldr x16,[x29,#920]
    ldr w9,[x16,x23,lsl #2]
    sub x27,x9,#1
    ldr x16,[x29,#824]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#824]
    mov x10,x21
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    adrp x16,:got:__yomcst_MOD_rg
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rg]
    ldr d2,[x16]
    fsub d0,d0,d1
    fdiv d0,d0,d2
    ldr d7,.LC2
    fmin d0,d0,d7
    ldr d7,.LC1
    fmax d0,d0,d7
    ldr x16,[x29,#728]
    sub x10,x21,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fdiv d1,d2,d1
    fmul d0,d1,d0
    ldr x16,[x29,#1480]
    ldr d1,[x16,x23,lsl #3]
    ldr d7,.LC1
    fmax d1,d1,d7
    fmul d0,d0,d1
    ldr d1,.LC3
    bl md2asm_pow_original_rounding_candidate
    ldr d1,.LC4
    fmul d0,d1,d0
    str d0,[x29,#1896]
    ldr x16,[x29,#808]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#808]
    mov x10,x27
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d0,d0,d1
    fmul d0,d0,d11
    ldr d1,[x29,#1896]
    fmin d0,d1,d0
    ldr x16,[x29,#1640]
    str d0,[x16,x23,lsl #3]
.Lwstarinactive19:
    add x23,x23,#1
    b .Lwstar17
.Lwstarend18:
.Lnowstar16:
    mov x23,x19
.Linitialmass20:
    cmp x23,x24
    b.ge .Linitialmassend21
    ldr x16,[x29,#904]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lmassinactive22
    ldr x16,[x29,#920]
    ldr w9,[x16,x23,lsl #2]
    sub x27,x9,#1
    ldr x16,[x29,#808]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#808]
    mov x10,x27
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d0,d0,d1
    fmul d0,d0,d11
    str d0,[x29,#1864]
    ldr x16,[x29,#912]
    ldr w9,[x16,x23,lsl #2]
    cmp w9,#1
    b.ne .Linitialshallow24
    ldr d1,.LC5
    fmul d0,d0,d1
    ldr x16,[x29,#1464]
    str d0,[x16,x23,lsl #3]
    b .Lmassend23
.Linitialshallow24:
    ldr x16,[x29,#1000]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1008]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#1192]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fadd d0,d0,d1
    fsub d0,d0,d2
    str d0,[x29,#1880]
    ldr d1,.LC6
    fmul d2,d1,d2
    ldr d7,.LC7
    fmax d2,d2,d7
    str d2,[x29,#1832]
    ldr x16,[x29,#992]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1184]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d0,d0,d1
    fmul d0,d8,d0
    adrp x16,:got:__yomcst_MOD_rlvtt
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rlvtt]
    ldr d1,[x16]
    ldr d2,[x29,#1880]
    fmul d1,d1,d2
    fadd d0,d0,d1
    ldr d1,[x29,#1832]
    ldr d2,.LC8
    fmul d1,d1,d2
    fmax d0,d0,d1
    adrp x16,:got:__yomcst_MOD_rg
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rg]
    ldr d1,[x16]
    fmul d0,d1,d0
    str d0,[x29,#1816]
    ldr x16,[x29,#1528]
    ldr d1,[x16,x23,lsl #3]
    fcmp d1,#0.0
    b.gt .Lpositivepbl25
    ldr d0,[x29,#1864]
    ldr d1,.LC5
    fmul d0,d0,d1
    ldr x16,[x29,#1464]
    str d0,[x16,x23,lsl #3]
    mov w9,#0
    ldr x16,[x29,#904]
    str w9,[x16,x23,lsl #2]
    b .Lpblmassdone26
.Lpositivepbl25:
    fdiv d0,d1,d0
    ldr d1,[x29,#1864]
    fmin d0,d0,d1
    ldr x16,[x29,#1464]
    str d0,[x16,x23,lsl #3]
.Lpblmassdone26:
    ldr x16,[x29,#2120]
    ldr w9,[x16,#296]
    cbz w9,.Lmassend23
    ldr x16,[x29,#1640]
    ldr d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1464]
    str d0,[x16,x23,lsl #3]
    b .Lmassend23
.Lmassinactive22:
    ldr d0,.LC1
    ldr x16,[x29,#1464]
    str d0,[x16,x23,lsl #3]
.Lmassend23:
    add x23,x23,#1
    b .Linitialmass20
.Linitialmassend21:
    ldr x9,[x29,#640]
    mov x0,x9
    ldr x9,[x29,#2128]
    mov x1,x9
    ldr x9,[x29,#2120]
    mov x2,x9
    ldr x9,[x29,#672]
    mov x3,x9
    ldr x9,[x29,#656]
    mov x4,x9
    ldr x9,[x29,#680]
    mov x5,x9
    ldr x9,[x29,#688]
    mov x6,x9
    ldr x9,[x29,#696]
    mov x7,x9
    ldr x9,[x29,#704]
    str x9,[sp,#0]
    ldr x9,[x29,#720]
    str x9,[sp,#8]
    ldr x9,[x29,#1184]
    str x9,[sp,#16]
    ldr x9,[x29,#1192]
    str x9,[sp,#24]
    ldr x9,[x29,#744]
    str x9,[sp,#32]
    ldr x9,[x29,#752]
    str x9,[sp,#40]
    ldr x9,[x29,#728]
    str x9,[sp,#48]
    ldr x9,[x29,#736]
    str x9,[sp,#56]
    ldr x9,[x29,#776]
    str x9,[sp,#64]
    ldr x9,[x29,#760]
    str x9,[sp,#72]
    ldr x9,[x29,#816]
    str x9,[sp,#80]
    ldr x9,[x29,#824]
    str x9,[sp,#88]
    ldr x9,[x29,#800]
    str x9,[sp,#96]
    ldr x9,[x29,#808]
    str x9,[sp,#104]
    ldr x9,[x29,#768]
    str x9,[sp,#112]
    ldr x9,[x29,#1536]
    str x9,[sp,#120]
    ldr x9,[x29,#848]
    str x9,[sp,#128]
    ldr x9,[x29,#712]
    str x9,[sp,#136]
    ldr x9,[x29,#904]
    str x9,[sp,#144]
    ldr x9,[x29,#912]
    str x9,[sp,#152]
    ldr x9,[x29,#1448]
    str x9,[sp,#160]
    ldr x9,[x29,#1720]
    str x9,[sp,#168]
    ldr x9,[x29,#992]
    str x9,[sp,#176]
    ldr x9,[x29,#1000]
    str x9,[sp,#184]
    ldr x9,[x29,#1008]
    str x9,[sp,#192]
    ldr x9,[x29,#1072]
    str x9,[sp,#200]
    ldr x9,[x29,#1088]
    str x9,[sp,#208]
    ldr x9,[x29,#1464]
    str x9,[sp,#216]
    ldr x9,[x29,#1352]
    str x9,[sp,#224]
    ldr x9,[x29,#1240]
    str x9,[sp,#232]
    ldr x9,[x29,#1256]
    str x9,[sp,#240]
    ldr x9,[x29,#1288]
    str x9,[sp,#248]
    ldr x9,[x29,#1016]
    str x9,[sp,#256]
    ldr x9,[x29,#1024]
    str x9,[sp,#264]
    ldr x9,[x29,#1272]
    str x9,[sp,#272]
    ldr x9,[x29,#984]
    str x9,[sp,#280]
    ldr x9,[x29,#1360]
    str x9,[sp,#288]
    ldr x9,[x29,#920]
    str x9,[sp,#296]
    ldr x9,[x29,#928]
    str x9,[sp,#304]
    ldr x9,[x29,#1680]
    str x9,[sp,#312]
    ldr x9,[x29,#1688]
    str x9,[sp,#320]
    ldr x9,[x29,#1104]
    str x9,[sp,#328]
    ldr x9,[x29,#1328]
    str x9,[sp,#336]
    ldr x9,[x29,#1128]
    str x9,[sp,#344]
    bl md2asm_cuascn_7240564
    mov x23,x19
.Lreclassify27:
    cmp x23,x24
    b.ge .Lreclassifyend28
    ldr x16,[x29,#904]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lnoreclass29
    ldr x16,[x29,#920]
    ldr w9,[x16,x23,lsl #2]
    sub x27,x9,#1
    ldr x16,[x29,#928]
    ldr w9,[x16,x23,lsl #2]
    sub x28,x9,#1
    ldr x16,[x29,#808]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#808]
    mov x10,x28
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d0,d0,d1
    ldr x16,[x29,#2120]
    ldr d1,[x16,#136]
    ldr x16,[x29,#912]
    ldr w9,[x16,x23,lsl #2]
    ldr d2,.LC1
    cmp w9,#1
    b.ne .Lnotdeep30
    fcmp d0,d1
    b.ge .Lnotdeep30
    mov w9,#2
    ldr x16,[x29,#912]
    str w9,[x16,x23,lsl #2]
.Lnotdeep30:
    ldr x16,[x29,#912]
    ldr w9,[x16,x23,lsl #2]
    cmp w9,#2
    b.ne .Lnotshallow31
    fcmp d0,d1
    b.lt .Lnotshallow31
    mov w9,#1
    ldr x16,[x29,#912]
    str w9,[x16,x23,lsl #2]
.Lnotshallow31:
    ldr x16,[x29,#928]
    ldr w9,[x16,x23,lsl #2]
    ldr x16,[x29,#1680]
    str w9,[x16,x23,lsl #2]
.Lnoreclass29:
    ldr x16,[x29,#1272]
    mov x10,#0
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1456]
    str d0,[x16,x23,lsl #3]
    add x23,x23,#1
    b .Lreclassify27
.Lreclassifyend28:
    mov x22,#1
.Lrainfalllevels32:
    cmp x22,x21
    b.ge .Lrainfalllevelsend33
    mov x23,x19
.Lrainfall34:
    cmp x23,x24
    b.ge .Lrainfallend35
    ldr x16,[x29,#1456]
    ldr d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1272]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fadd d0,d0,d1
    ldr x16,[x29,#1456]
    str d0,[x16,x23,lsl #3]
    add x23,x23,#1
    b .Lrainfall34
.Lrainfallend35:
    add x22,x22,#1
    b .Lrainfalllevels32
.Lrainfalllevelsend33:
    mov x22,#0
.Ldowndraftzero36:
    cmp x22,x21
    b.ge .Ldowndraftzeroend37
    mov x23,x19
.Lzerodd38:
    cmp x23,x24
    b.ge .Lzeroddend39
    ldr d0,.LC1
    ldr x16,[x29,#1096]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1248]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1264]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1280]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1344]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#872]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1408]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#880]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1416]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    add x23,x23,#1
    b .Lzerodd38
.Lzeroddend39:
    add x22,x22,#1
    b .Ldowndraftzero36
.Ldowndraftzeroend37:
    ldr x9,[x29,#640]
    mov x0,x9
    ldr x9,[x29,#2120]
    mov x1,x9
    ldr x9,[x29,#680]
    mov x2,x9
    ldr x9,[x29,#688]
    mov x3,x9
    ldr x9,[x29,#696]
    mov x4,x9
    ldr x9,[x29,#704]
    mov x5,x9
    ldr x9,[x29,#920]
    mov x6,x9
    ldr x9,[x29,#928]
    mov x7,x9
    ldr x9,[x29,#904]
    str x9,[sp,#0]
    ldr x9,[x29,#1184]
    str x9,[sp,#8]
    ldr x9,[x29,#1192]
    str x9,[sp,#16]
    ldr x9,[x29,#728]
    str x9,[sp,#24]
    ldr x9,[x29,#776]
    str x9,[sp,#32]
    ldr x9,[x29,#816]
    str x9,[sp,#40]
    ldr x9,[x29,#824]
    str x9,[sp,#48]
    ldr x9,[x29,#808]
    str x9,[sp,#56]
    ldr x9,[x29,#992]
    str x9,[sp,#64]
    ldr x9,[x29,#1000]
    str x9,[sp,#72]
    ldr x9,[x29,#1464]
    str x9,[sp,#80]
    ldr x9,[x29,#1456]
    str x9,[sp,#88]
    ldr x9,[x29,#1224]
    str x9,[sp,#96]
    ldr x9,[x29,#1232]
    str x9,[sp,#104]
    ldr x9,[x29,#1096]
    str x9,[sp,#112]
    ldr x9,[x29,#1248]
    str x9,[sp,#120]
    ldr x9,[x29,#1264]
    str x9,[sp,#128]
    ldr x9,[x29,#1280]
    str x9,[sp,#136]
    ldr x9,[x29,#1672]
    str x9,[sp,#144]
    ldr x9,[x29,#1696]
    str x9,[sp,#152]
    bl md2asm_cudlfsn
    ldr x9,[x29,#640]
    mov x0,x9
    ldr x9,[x29,#2120]
    mov x1,x9
    ldr x9,[x29,#680]
    mov x2,x9
    ldr x9,[x29,#688]
    mov x3,x9
    ldr x9,[x29,#696]
    mov x4,x9
    ldr x9,[x29,#704]
    mov x5,x9
    ldr x9,[x29,#1696]
    mov x6,x9
    ldr x9,[x29,#1184]
    mov x7,x9
    ldr x9,[x29,#1192]
    str x9,[sp,#0]
    ldr x9,[x29,#776]
    str x9,[sp,#8]
    ldr x9,[x29,#816]
    str x9,[sp,#16]
    ldr x9,[x29,#824]
    str x9,[sp,#24]
    ldr x9,[x29,#808]
    str x9,[sp,#32]
    ldr x9,[x29,#1456]
    str x9,[sp,#40]
    ldr x9,[x29,#1224]
    str x9,[sp,#48]
    ldr x9,[x29,#1232]
    str x9,[sp,#56]
    ldr x9,[x29,#1088]
    str x9,[sp,#64]
    ldr x9,[x29,#1096]
    str x9,[sp,#72]
    ldr x9,[x29,#1248]
    str x9,[sp,#80]
    ldr x9,[x29,#1264]
    str x9,[sp,#88]
    ldr x9,[x29,#1280]
    str x9,[sp,#96]
    ldr x9,[x29,#1368]
    str x9,[sp,#104]
    ldr x9,[x29,#1112]
    str x9,[sp,#112]
    ldr x9,[x29,#1336]
    str x9,[sp,#120]
    bl md2asm_cuddrafn
    mov x23,x19
.Lclosureinit40:
    cmp x23,x24
    b.ge .Lclosureinitend41
    ldr d0,.LC1
    ldr x16,[x29,#1568]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1552]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1560]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1496]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1520]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1464]
    ldr d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1472]
    str d0,[x16,x23,lsl #3]
    adrp x16,:got:__yomcst_MOD_rpi
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rpi]
    ldr d0,[x16]
    ldr x16,[x29,#832]
    ldr d1,[x16,x23,lsl #3]
    fmul d0,d0,d1
    fsqrt d0,d0
    adrp x16,:got:__yomcst_MOD_ra
    ldr x16,[x16,:got_lo12:__yomcst_MOD_ra]
    ldr d1,[x16]
    ldr d2,.LC9
    fmul d1,d2,d1
    fmul d0,d1,d0
    ldr d7,.LC10
    fmax d0,d0,d7
    ldr x16,[x29,#1544]
    str d0,[x16,x23,lsl #3]
    add x23,x23,#1
    b .Lclosureinit40
.Lclosureinitend41:
    ldr x16,[x29,#2120]
    ldr w22,[x16,#312]
    sub x22,x22,#1
    mov x22,x22
.Lcapelayers42:
    cmp x22,x21
    b.ge .Lcapelayersend43
    mov x23,x19
.Lcapelayer44:
    cmp x23,x24
    b.ge .Lcapelayerend45
    ldr x16,[x29,#904]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lnotdeepcape46
    ldr x16,[x29,#912]
    ldr w9,[x16,x23,lsl #2]
    cmp w9,#1
    b.ne .Lnotdeepcape46
    ldr x16,[x29,#920]
    ldr w9,[x16,x23,lsl #2]
    sub x27,x9,#1
    ldr x16,[x29,#928]
    ldr w9,[x16,x23,lsl #2]
    sub x28,x9,#1
    cmp x22,x27
    b.gt .Lskipcapelayer47
    cmp x22,x28
    b.le .Lskipcapelayer47
    ldr x16,[x29,#816]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#816]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d2,d0,d1
    fmul d2,d2,d9
    ldr x16,[x29,#728]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#728]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#1184]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d3,[x16,x10,lsl #3]
    fsub d0,d0,d1
    fadd d0,d0,d2
    fdiv d0,d0,d3
    ldr x16,[x29,#736]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#736]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    adrp x16,:got:__yomcst_MOD_retv
    ldr x16,[x16,:got_lo12:__yomcst_MOD_retv]
    ldr d4,[x16]
    fsub d1,d1,d2
    fmul d1,d4,d1
    fadd d0,d0,d1
    ldr x16,[x29,#1088]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#1096]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    adrp x16,:got:__yomcst_MOD_rg
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rg]
    ldr d3,[x16]
    fadd d1,d1,d2
    fmul d1,d3,d1
    fmul d0,d0,d1
    ldr d7,.LC1
    fmax d0,d0,d7
    ldr x16,[x29,#1568]
    ldr d1,[x16,x23,lsl #3]
    fadd d0,d1,d0
    ldr x16,[x29,#1568]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#800]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#800]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d2,d0,d1
    str d2,[x29,#1840]
    ldr x16,[x29,#992]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1184]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d0,d0,d1
    fdiv d0,d0,d1
    ldr x16,[x29,#1000]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#1192]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d3,[x16,x10,lsl #3]
    adrp x16,:got:__yomcst_MOD_retv
    ldr x16,[x16,:got_lo12:__yomcst_MOD_retv]
    ldr d4,[x16]
    fsub d1,d1,d3
    fmul d1,d4,d1
    fadd d0,d0,d1
    ldr x16,[x29,#1008]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d0,d0,d1
    fmul d0,d0,d2
    ldr x16,[x29,#1552]
    ldr d1,[x16,x23,lsl #3]
    fadd d0,d1,d0
    ldr x16,[x29,#1552]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#2120]
    ldr d0,[x16,#168]
    fcmp d0,#0.0
    b.le .Lnocapadv48
    ldr x16,[x29,#888]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#888]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr d2,.LC11
    fadd d0,d0,d1
    fmul d0,d2,d0
    ldr x16,[x29,#720]
    ldr d1,[x16]
    fmul d0,d0,d1
    ldr x16,[x29,#1184]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d0,d1,d0
    ldr x16,[x29,#1200]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#896]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#896]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr d2,.LC11
    fadd d0,d0,d1
    fmul d0,d2,d0
    ldr x16,[x29,#720]
    ldr d1,[x16]
    fmul d0,d0,d1
    ldr x16,[x29,#1192]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d0,d1,d0
    ldr x16,[x29,#1208]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#992]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1200]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d0,d0,d1
    fdiv d0,d0,d1
    ldr x16,[x29,#1000]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#1208]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    adrp x16,:got:__yomcst_MOD_retv
    ldr x16,[x16,:got_lo12:__yomcst_MOD_retv]
    ldr d3,[x16]
    fsub d1,d1,d2
    fmul d1,d3,d1
    fadd d0,d0,d1
    ldr x16,[x29,#1008]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr d2,[x29,#1840]
    fsub d0,d0,d1
    fmul d0,d0,d2
    ldr x16,[x29,#1560]
    ldr d1,[x16,x23,lsl #3]
    fadd d0,d1,d0
    ldr x16,[x29,#1560]
    str d0,[x16,x23,lsl #3]
.Lnocapadv48:
.Lskipcapelayer47:
    ldr x16,[x29,#808]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#808]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d2,d0,d1
    ldr x16,[x29,#896]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#736]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#776]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d3,[x16,x10,lsl #3]
    fmul d0,d0,d2
    fdiv d1,d1,d3
    fmul d0,d0,d1
    ldr x16,[x29,#1496]
    ldr d1,[x16,x23,lsl #3]
    fadd d0,d1,d0
    ldr x16,[x29,#1496]
    str d0,[x16,x23,lsl #3]
    cmp x22,x28
    b.lt .Lnotdeepcape46
    ldr x16,[x29,#736]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#776]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fdiv d0,d0,d1
    fmul d0,d0,d2
    ldr x16,[x29,#1520]
    ldr d1,[x16,x23,lsl #3]
    fadd d0,d1,d0
    ldr x16,[x29,#1520]
    str d0,[x16,x23,lsl #3]
.Lnotdeepcape46:
    add x23,x23,#1
    b .Lcapelayer44
.Lcapelayerend45:
    add x22,x22,#1
    b .Lcapelayers42
.Lcapelayersend43:
    mov x23,x19
.Ltimescale49:
    cmp x23,x24
    b.ge .Ltimescaleend50
    ldr d0,.LC1
    ldr x16,[x29,#1584]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1592]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#904]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lnotdeep_time51
    ldr x16,[x29,#912]
    ldr w9,[x16,x23,lsl #2]
    cmp w9,#1
    b.ne .Lnotdeep_time51
    ldr x16,[x29,#1544]
    ldr d0,[x16,x23,lsl #3]
    ldr d1,.LC12
    ldr d2,.LC13
    ldr d3,.LC0
    fmul d1,d1,d0
    fdiv d1,d1,d2
    fadd d1,d3,d1
    str d1,[x29,#1944]
    ldr d1,.LC14
    fcmp d0,d1
    b.ge .Lnarrowresdone52
    fdiv d0,d1,d0
    bl log
    fmul d0,d0,d0
    ldr d1,.LC0
    fadd d0,d1,d0
    str d0,[x29,#1944]
.Lnarrowresdone52:
    ldr x16,[x29,#1544]
    ldr d0,[x16,x23,lsl #3]
    ldr d1,.LC13
    fcmp d0,d1
    b.le .Lcoarseresdone53
    ldr d0,[x29,#1944]
    ldr d7,.LC15
    fmin d0,d0,d7
    str d0,[x29,#1944]
.Lcoarseresdone53:
    ldr x16,[x29,#920]
    ldr w9,[x16,x23,lsl #2]
    sub x27,x9,#1
    ldr x16,[x29,#928]
    ldr w9,[x16,x23,lsl #2]
    sub x28,x9,#1
    ldr x16,[x29,#1688]
    ldr w9,[x16,x23,lsl #2]
    sub x25,x9,#1
    ldr x16,[x29,#824]
    mov x10,x28
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#824]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d0,d0,d1
    ldr x16,[x29,#1128]
    ldr d1,[x16,x23,lsl #3]
    ldr d7,.LC16
    fmin d1,d1,d7
    ldr d2,.LC9
    fadd d1,d2,d1
    adrp x16,:got:__yomcst_MOD_rg
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rg]
    ldr d2,[x16]
    fmul d1,d1,d2
    fdiv d0,d0,d1
    ldr d1,[x29,#1944]
    ldr x16,[x29,#2120]
    ldr d2,[x16,#152]
    fmul d0,d0,d1
    fmul d0,d0,d2
    ldr x16,[x29,#1592]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1592]
    ldr d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1608]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#808]
    mov x10,x21
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#808]
    mov x10,x25
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d0,d0,d1
    ldr d1,.LC17
    fcmp d0,d1
    cset w9,lt
    str w9,[x29,#2148]
    ldr x16,[x29,#712]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lnotcycle154
    ldr w9,[x29,#2148]
    cbz w9,.Lnotcycle154
    ldr x16,[x29,#2120]
    ldr d0,[x16,#160]
    ldr d1,.LC0
    fcmp d0,d1
    b.ne .Lnotcycle154
    ldr x16,[x29,#824]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#824]
    mov x10,x21
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d0,d0,d1
    ldr d7,.LC18
    fmin d0,d0,d7
    adrp x16,:got:__yomcst_MOD_rg
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rg]
    ldr d1,[x16]
    fdiv d2,d0,d1
    ldr x16,[x29,#1608]
    ldr d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1480]
    ldr d1,[x16,x23,lsl #3]
    ldr d7,.LC1
    fmax d1,d1,d7
    fmul d0,d0,d1
    fmul d0,d0,d8
    fdiv d0,d0,d2
    ldr x16,[x29,#1584]
    str d0,[x16,x23,lsl #3]
.Lnotcycle154:
    ldr w9,[x29,#2148]
    cbz w9,.Lnotcycle255
    ldr x16,[x29,#2120]
    ldr d0,[x16,#160]
    ldr d1,.LC9
    fcmp d0,d1
    b.ne .Lnotcycle255
    ldr x16,[x29,#712]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lcycle2sea56
    ldr x16,[x29,#1576]
    ldr d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1592]
    ldr d1,[x16,x23,lsl #3]
    ldr d2,[x29,#1944]
    fmul d0,d0,d1
    fdiv d0,d0,d2
    ldr x16,[x29,#1584]
    str d0,[x16,x23,lsl #3]
    b .Lcycle2done57
.Lcycle2sea56:
    ldr x16,[x29,#744]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d0,d0
    ldr x16,[x29,#752]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmul d1,d1,d1
    fadd d0,d0,d1
    ldr x16,[x29,#2120]
    ldr w9,[x16,#316]
    sub x25,x9,#1
    ldr x16,[x29,#744]
    mov x10,x25
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmul d1,d1,d1
    fadd d0,d0,d1
    ldr x16,[x29,#752]
    mov x10,x25
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmul d1,d1,d1
    fadd d0,d0,d1
    ldr d1,.LC11
    ldr d2,.LC9
    fmul d0,d1,d0
    fsqrt d0,d0
    fadd d0,d2,d0
    str d0,[x29,#1920]
    ldr x16,[x29,#824]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#824]
    mov x10,x21
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d0,d0,d1
    ldr d7,.LC18
    fmin d0,d0,d7
    adrp x16,:got:__yomcst_MOD_rg
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rg]
    ldr d1,[x16]
    ldr d2,[x29,#1920]
    fmul d1,d1,d2
    fdiv d0,d0,d1
    ldr x16,[x29,#1600]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1576]
    ldr d1,[x16,x23,lsl #3]
    fmul d0,d1,d0
    ldr x16,[x29,#1584]
    str d0,[x16,x23,lsl #3]
.Lcycle2done57:
.Lnotcycle255:
    ldr x16,[x29,#1496]
    ldr d0,[x16,x23,lsl #3]
    adrp x16,:got:__yomcst_MOD_rlvtt
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rlvtt]
    ldr d1,[x16]
    ldr x16,[x29,#824]
    mov x10,x28
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fmul d0,d0,d1
    fdiv d0,d0,d2
    ldr x16,[x29,#1608]
    ldr d1,[x16,x23,lsl #3]
    fmul d0,d0,d1
    ldr d1,[x29,#1944]
    ldr d7,.LC19
    fmax d1,d1,d7
    fdiv d0,d0,d1
    ldr x16,[x29,#2120]
    ldr d1,[x16,#168]
    fmul d0,d0,d1
    ldr x16,[x29,#1496]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#808]
    mov x10,x21
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#808]
    mov x10,x28
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d1,d0,d1
    ldr x16,[x29,#1520]
    ldr d0,[x16,x23,lsl #3]
    fdiv d0,d0,d1
    ldr x16,[x29,#1520]
    str d0,[x16,x23,lsl #3]
.Lnotdeep_time51:
    add x23,x23,#1
    b .Ltimescale49
.Ltimescaleend50:
    mov x23,x19
.Lmodulation58:
    cmp x23,x24
    b.ge .Lmodulationend59
    ldr x16,[x29,#2120]
    ldr w9,[x16,#300]
    cbz w9,.Lnocuca60
    ldr x16,[x29,#840]
    ldr d0,[x16,x23,lsl #3]
    ldr d7,.LC20
    fmin d0,d0,d7
    ldr d7,.LC21
    fmax d0,d0,d7
    b .Lcucadone61
.Lnocuca60:
    ldr d0,.LC0
.Lcucadone61:
    ldr x16,[x29,#1504]
    str d0,[x16,x23,lsl #3]
    add x23,x23,#1
    b .Lmodulation58
.Lmodulationend59:
    mov x23,x19
.Ldeepmass62:
    cmp x23,x24
    b.ge .Ldeepmassend63
    ldr x16,[x29,#904]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lnodeepmass64
    ldr x16,[x29,#912]
    ldr w9,[x16,x23,lsl #2]
    cmp w9,#1
    b.ne .Lnodeepmass64
    ldr x16,[x29,#920]
    ldr w9,[x16,x23,lsl #2]
    sub x27,x9,#1
    ldr x16,[x29,#2120]
    ldr d0,[x16,#168]
    ldr x16,[x29,#1560]
    ldr d1,[x16,x23,lsl #3]
    ldr x16,[x29,#1552]
    ldr d2,[x16,x23,lsl #3]
    ldr d3,.LC0
    fmul d1,d0,d1
    fsub d0,d3,d0
    fmul d0,d0,d2
    fadd d0,d1,d0
    ldr x16,[x29,#1560]
    str d0,[x16,x23,lsl #3]
    ldr d1,.LC22
    fmul d1,d1,d0
    ldr x16,[x29,#1584]
    ldr d2,[x16,x23,lsl #3]
    fmax d1,d2,d1
    ldr x16,[x29,#1584]
    str d1,[x16,x23,lsl #3]
    ldr x16,[x29,#1520]
    ldr d2,[x16,x23,lsl #3]
    ldr d3,.LC23
    fcmp d2,d3
    b.le .Lcapselected66
    ldr x16,[x29,#2120]
    ldr w9,[x16,#324]
    sub x25,x9,#1
    ldr x16,[x29,#768]
    mov x10,x25
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    ldr d3,.LC24
    fcmp d2,d3
    b.ge .Lveryhumid65
.Lcapselected66:
    ldr x16,[x29,#1560]
    ldr d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1584]
    ldr d1,[x16,x23,lsl #3]
    ldr x16,[x29,#1496]
    ldr d2,[x16,x23,lsl #3]
    fsub d0,d0,d1
    fadd d0,d0,d2
    b .Lcapeproposed67
.Lveryhumid65:
    ldr x16,[x29,#1552]
    ldr d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1584]
    ldr d1,[x16,x23,lsl #3]
    fsub d0,d0,d1
.Lcapeproposed67:
    ldr x16,[x29,#2120]
    ldr d1,[x16,#176]
    ldr x16,[x29,#1552]
    ldr d2,[x16,x23,lsl #3]
    fmul d1,d1,d2
    fmax d0,d1,d0
    ldr d7,.LC17
    fmin d0,d0,d7
    ldr x16,[x29,#1552]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1568]
    ldr d0,[x16,x23,lsl #3]
    ldr d7,.LC25
    fmax d0,d0,d7
    ldr x16,[x29,#1568]
    str d0,[x16,x23,lsl #3]
    adrp x16,:got:__yomdyncore_MOD_rplrg
    ldr x16,[x16,:got_lo12:__yomdyncore_MOD_rplrg]
    ldr d1,[x16]
    adrp x16,:got:__yomdyncore_MOD_rpldare
    ldr x16,[x16,:got_lo12:__yomdyncore_MOD_rpldare]
    ldr d2,[x16]
    ldr d0,.LC26
    fmul d0,d0,d1
    fmul d0,d0,d2
    ldr d3,.LC27
    fdiv d3,d3,d0
    fmul d2,d1,d2
    ldr d0,.LC28
    fdiv d2,d0,d2
    ldr x16,[x29,#1608]
    ldr d0,[x16,x23,lsl #3]
    fmin d0,d2,d0
    fmax d0,d3,d0
    ldr x16,[x29,#1608]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1552]
    ldr d1,[x16,x23,lsl #3]
    ldr x16,[x29,#1464]
    ldr d2,[x16,x23,lsl #3]
    ldr x16,[x29,#1568]
    ldr d3,[x16,x23,lsl #3]
    fmul d1,d1,d2
    fmul d0,d3,d0
    fdiv d0,d1,d0
    ldr d7,.LC29
    fmax d0,d0,d7
    ldr x16,[x29,#1504]
    ldr d1,[x16,x23,lsl #3]
    fmul d0,d0,d1
    str d0,[x29,#1896]
    ldr x16,[x29,#808]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#808]
    mov x10,x27
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d0,d0,d1
    fmul d0,d0,d11
    ldr d1,[x29,#1896]
    fmin d0,d1,d0
    ldr x16,[x29,#1472]
    str d0,[x16,x23,lsl #3]
.Lnodeepmass64:
    add x23,x23,#1
    b .Ldeepmass62
.Ldeepmassend63:
    mov x23,x19
.Lshallowmass68:
    cmp x23,x24
    b.ge .Lshallowmassend69
    ldr x16,[x29,#904]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lnoshallowmass70
    ldr x16,[x29,#912]
    ldr w9,[x16,x23,lsl #2]
    cmp w9,#2
    b.lt .Lnoshallowmass70
    ldr x16,[x29,#920]
    ldr w9,[x16,x23,lsl #2]
    sub x27,x9,#1
    ldr x16,[x29,#1096]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fcmp d0,#0.0
    b.ge .Lnoddfrac71
    ldr x16,[x29,#1464]
    ldr d1,[x16,x23,lsl #3]
    ldr d7,.LC7
    fmax d1,d1,d7
    fneg d0,d0
    fdiv d0,d0,d1
    b .Lddfracdone72
.Lnoddfrac71:
    ldr d0,.LC1
.Lddfracdone72:
    str d0,[x29,#1848]
    ldr x16,[x29,#808]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#808]
    mov x10,x27
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d0,d0,d1
    fmul d0,d0,d11
    str d0,[x29,#1864]
    ldr x16,[x29,#912]
    ldr w9,[x16,x23,lsl #2]
    cmp w9,#2
    b.ne .Ltrymidmass73
    ldr x16,[x29,#1528]
    ldr d0,[x16,x23,lsl #3]
    fcmp d0,#0.0
    b.le .Lshallow_noheat74
    ldr x16,[x29,#1000]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1008]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr d2,[x29,#1848]
    ldr x16,[x29,#1232]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d3,[x16,x10,lsl #3]
    ldr x16,[x29,#1192]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d4,[x16,x10,lsl #3]
    ldr d5,.LC0
    fadd d0,d0,d1
    fmul d3,d2,d3
    fsub d0,d0,d3
    fsub d5,d5,d2
    fmul d4,d5,d4
    fsub d0,d0,d4
    str d0,[x29,#1880]
    ldr x16,[x29,#992]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1224]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr d2,[x29,#1848]
    ldr d3,.LC0
    ldr x16,[x29,#1184]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d4,[x16,x10,lsl #3]
    fmul d1,d2,d1
    fsub d0,d0,d1
    fsub d3,d3,d2
    fmul d4,d3,d4
    fsub d0,d0,d4
    fmul d0,d8,d0
    adrp x16,:got:__yomcst_MOD_rlvtt
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rlvtt]
    ldr d1,[x16]
    ldr d2,[x29,#1880]
    fmul d1,d1,d2
    fadd d0,d0,d1
    str d0,[x29,#1816]
    ldr x16,[x29,#992]
    mov x10,x27
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1224]
    mov x10,x27
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr d2,[x29,#1848]
    ldr d3,.LC0
    ldr x16,[x29,#1184]
    mov x10,x27
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d4,[x16,x10,lsl #3]
    fmul d1,d2,d1
    fsub d0,d0,d1
    fsub d3,d3,d2
    fmul d4,d3,d4
    fsub d0,d0,d4
    fmul d0,d8,d0
    adrp x16,:got:__yomcst_MOD_rlvtt
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rlvtt]
    ldr d1,[x16]
    ldr d2,[x29,#1880]
    fmul d1,d1,d2
    fadd d0,d0,d1
    str d0,[x29,#1824]
    ldr d0,[x29,#1816]
    ldr d1,[x29,#1824]
    ldr d2,.LC11
    fadd d0,d0,d1
    fmul d0,d2,d0
    ldr d1,.LC5
    fmul d1,d1,d8
    fmax d0,d0,d1
    adrp x16,:got:__yomcst_MOD_rg
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rg]
    ldr d1,[x16]
    fmul d0,d1,d0
    str d0,[x29,#1816]
    ldr x16,[x29,#1528]
    ldr d1,[x16,x23,lsl #3]
    fdiv d0,d1,d0
    ldr x16,[x29,#1472]
    str d0,[x16,x23,lsl #3]
    ldr d1,[x29,#1864]
    ldr d2,.LC30
    ldr x16,[x29,#2120]
    ldr d3,[x16,#56]
    fmul d1,d2,d1
    fdiv d1,d1,d3
    fcmp d0,d1
    b.le .Lshallowcapdone76
    ldr d0,[x29,#1816]
    ldr d1,.LC11
    adrp x16,:got:__yomcst_MOD_rg
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rg]
    ldr d2,[x16]
    fmul d1,d1,d2
    fmul d1,d1,d8
    fcmp d0,d1
    b.ge .Lshallowcapdone76
    ldr d0,.LC31
    adrp x16,:got:__yomcst_MOD_rg
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rg]
    ldr d1,[x16]
    fmul d0,d0,d8
    fmul d0,d0,d1
    ldr x16,[x29,#1528]
    ldr d1,[x16,x23,lsl #3]
    fdiv d0,d1,d0
    ldr x16,[x29,#1472]
    str d0,[x16,x23,lsl #3]
.Lshallowcapdone76:
    b .Lshallowadjusted75
.Lshallow_noheat74:
    ldr x16,[x29,#1464]
    ldr d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1472]
    str d0,[x16,x23,lsl #3]
.Lshallowadjusted75:
    ldr x16,[x29,#2120]
    ldr w9,[x16,#296]
    cbz w9,.Ldontwstar77
    ldr x16,[x29,#1640]
    ldr d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1472]
    str d0,[x16,x23,lsl #3]
.Ldontwstar77:
    ldr x16,[x29,#1472]
    ldr d0,[x16,x23,lsl #3]
    ldr d1,[x29,#1864]
    fmin d0,d0,d1
    ldr x16,[x29,#1472]
    str d0,[x16,x23,lsl #3]
.Ltrymidmass73:
    ldr x16,[x29,#912]
    ldr w9,[x16,x23,lsl #2]
    cmp w9,#3
    b.ne .Lnoshallowmass70
    ldr x16,[x29,#1488]
    ldr d0,[x16,x23,lsl #3]
    ldr d1,.LC26
    ldr x16,[x29,#824]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    ldr d7,.LC10
    fmax d2,d2,d7
    fmul d0,d1,d0
    fdiv d0,d0,d2
    ldr x16,[x29,#1464]
    ldr d1,[x16,x23,lsl #3]
    fmax d0,d1,d0
    ldr d1,[x29,#1848]
    ldr d2,.LC0
    fadd d1,d2,d1
    fmul d0,d0,d1
    str d0,[x29,#1896]
    ldr x16,[x29,#824]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr d2,.LC2
    fcmp d1,d2
    b.ge .Lmidcapnormal78
    ldr d1,[x29,#1864]
    ldr d2,.LC32
    ldr x16,[x29,#2120]
    ldr d3,[x16,#56]
    fmul d2,d2,d3
    fdiv d1,d1,d2
    b .Lmidcapdone79
.Lmidcapnormal78:
    ldr d1,[x29,#1864]
.Lmidcapdone79:
    ldr d0,[x29,#1896]
    fmin d0,d0,d1
    ldr x16,[x29,#1472]
    str d0,[x16,x23,lsl #3]
.Lnoshallowmass70:
    add x23,x23,#1
    b .Lshallowmass68
.Lshallowmassend69:
    mov x22,#0
.Lddrescale80:
    cmp x22,x21
    b.ge .Lddrescaleend81
    mov x23,x19
.Lrescaledd82:
    cmp x23,x24
    b.ge .Lrescaleddend83
    ldr x16,[x29,#1696]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lskipddscale84
    ldr x16,[x29,#912]
    ldr w9,[x16,x23,lsl #2]
    cmp w9,#1
    b.lt .Lskipddscale84
    cmp w9,#2
    b.gt .Lskipddscale84
    ldr x16,[x29,#1472]
    ldr d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1464]
    ldr d1,[x16,x23,lsl #3]
    ldr d7,.LC7
    fmax d1,d1,d7
    fdiv d2,d0,d1
    ldr x16,[x29,#1096]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d0,d2
    ldr x16,[x29,#1096]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1112]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d0,d2
    ldr x16,[x29,#1112]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1248]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d0,d2
    ldr x16,[x29,#1248]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1264]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d0,d2
    ldr x16,[x29,#1264]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1280]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d0,d2
    ldr x16,[x29,#1280]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
.Lskipddscale84:
    add x23,x23,#1
    b .Lrescaledd82
.Lrescaleddend83:
    add x22,x22,#1
    b .Lddrescale80
.Lddrescaleend81:
    mov x23,x19
.Lscalinginit85:
    cmp x23,x24
    b.ge .Lscalinginitend86
    ldr x16,[x29,#904]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lnoscales87
    ldr x16,[x29,#1472]
    ldr d0,[x16,x23,lsl #3]
    ldr x16,[x29,#2120]
    ldr d1,[x16,#120]
    ldr x16,[x29,#1464]
    ldr d2,[x16,x23,lsl #3]
    fmax d1,d1,d2
    fdiv d0,d0,d1
    ldr x16,[x29,#1616]
    str d0,[x16,x23,lsl #3]
.Lnoscales87:
    add x23,x23,#1
    b .Lscalinginit85
.Lscalinginitend86:
    mov x22,#1
.Lscalingbounds88:
    cmp x22,x21
    b.ge .Lscalingboundsend89
    mov x23,x19
.Lscalingbounds_col90:
    cmp x23,x24
    b.ge .Lscalingbounds_colend91
    ldr x16,[x29,#904]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lskipscalebound92
    ldr x16,[x29,#928]
    ldr w9,[x16,x23,lsl #2]
    sub x28,x9,#1
    sub x9,x28,#1
    cmp x22,x9
    b.lt .Lskipscalebound92
    ldr x16,[x29,#920]
    ldr w9,[x16,x23,lsl #2]
    sub x27,x9,#1
    cmp x22,x27
    b.le .Lnotbelowbase93
    ldr x16,[x29,#808]
    mov x10,x21
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#808]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#808]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fsub d1,d0,d1
    fsub d0,d0,d2
    fdiv d0,d1,d0
    ldr x16,[x29,#1088]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmul d0,d1,d0
    ldr x16,[x29,#1088]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
.Lnotbelowbase93:
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
    ldr x16,[x29,#2120]
    ldr d1,[x16,#64]
    fmin d0,d0,d1
    str d0,[x29,#1864]
    ldr x16,[x29,#1088]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#1616]
    ldr d2,[x16,x23,lsl #3]
    fmul d2,d1,d2
    fcmp d2,d0
    b.le .Lskipscalebound92
    fdiv d0,d0,d1
    ldr x16,[x29,#1616]
    ldr d1,[x16,x23,lsl #3]
    fmin d0,d1,d0
    ldr d7,.LC7
    fmax d0,d0,d7
    ldr x16,[x29,#1616]
    str d0,[x16,x23,lsl #3]
.Lskipscalebound92:
    add x23,x23,#1
    b .Lscalingbounds_col90
.Lscalingbounds_colend91:
    add x22,x22,#1
    b .Lscalingbounds88
.Lscalingboundsend89:
    ldr x16,[x29,#2120]
    ldr d0,[x16,#104]
    fcmp d0,#0.0
    b.le .Lnodivlimit94
    mov x22,#1
.Ldivlimit95:
    sub x9,x21,#1
    cmp x22,x9
    b.ge .Ldivlimitend96
    mov x23,x19
.Ldivlimitcol97:
    cmp x23,x24
    b.ge .Ldivlimitcolend98
    ldr x16,[x29,#912]
    ldr w9,[x16,x23,lsl #2]
    cmp w9,#1
    b.ne .Lnodivcolumn99
    ldr x16,[x29,#928]
    ldr w9,[x16,x23,lsl #2]
    sub x28,x9,#1
    sub x9,x28,#1
    cmp x22,x9
    b.lt .Lnodivcolumn99
    ldr x16,[x29,#1616]
    ldr d0,[x16,x23,lsl #3]
    adrp x16,:got:__yomcst_MOD_rg
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rg]
    ldr d1,[x16]
    ldr x16,[x29,#2120]
    ldr d2,[x16,#104]
    fmul d0,d0,d1
    fmul d0,d0,d2
    ldr x16,[x29,#1088]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#1096]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    ldr x16,[x29,#2120]
    ldr d3,[x16,#112]
    ldr x16,[x29,#1088]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d4,[x16,x10,lsl #3]
    ldr x16,[x29,#1096]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d5,[x16,x10,lsl #3]
    fsub d1,d1,d4
    fsub d2,d2,d5
    fmul d2,d3,d2
    fadd d1,d1,d2
    fmul d0,d0,d1
    ldr x16,[x29,#808]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#808]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fsub d1,d1,d2
    fdiv d0,d0,d1
    ldr x16,[x29,#720]
    ldr d1,[x16]
    fmul d0,d0,d1
    fabs d0,d0
    ldr d1,.LC33
    fcmp d0,d1
    b.le .Lnodivcolumn99
    ldr d7,.LC34
    fmax d0,d0,d7
    ldr x16,[x29,#1616]
    ldr d1,[x16,x23,lsl #3]
    fdiv d0,d1,d0
    ldr x16,[x29,#1616]
    str d0,[x16,x23,lsl #3]
.Lnodivcolumn99:
    add x23,x23,#1
    b .Ldivlimitcol97
.Ldivlimitcolend98:
    add x22,x22,#1
    b .Ldivlimit95
.Ldivlimitend96:
    sub x22,x21,#1
    mov x23,x19
.Ldivbottom100:
    cmp x23,x24
    b.ge .Ldivbottomend101
    ldr x16,[x29,#912]
    ldr w9,[x16,x23,lsl #2]
    cmp w9,#1
    b.ne .Lnodivcolumn102
    ldr x16,[x29,#1616]
    ldr d0,[x16,x23,lsl #3]
    adrp x16,:got:__yomcst_MOD_rg
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rg]
    ldr d1,[x16]
    ldr x16,[x29,#2120]
    ldr d2,[x16,#104]
    fmul d0,d0,d1
    fmul d0,d0,d2
    ldr x16,[x29,#1088]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#1096]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    ldr x16,[x29,#2120]
    ldr d3,[x16,#112]
    fmul d2,d3,d2
    fadd d1,d1,d2
    fmul d0,d0,d1
    ldr x16,[x29,#808]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#808]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fsub d1,d1,d2
    fdiv d0,d0,d1
    ldr x16,[x29,#720]
    ldr d1,[x16]
    fmul d0,d0,d1
    fabs d0,d0
    ldr d1,.LC33
    fcmp d0,d1
    b.le .Lnodivcolumn102
    ldr d7,.LC34
    fmax d0,d0,d7
    ldr x16,[x29,#1616]
    ldr d1,[x16,x23,lsl #3]
    fdiv d0,d1,d0
    ldr x16,[x29,#1616]
    str d0,[x16,x23,lsl #3]
.Lnodivcolumn102:
    add x23,x23,#1
    b .Ldivbottom100
.Ldivbottomend101:
.Lnodivlimit94:
    mov x22,#1
.Lscalefluxes103:
    cmp x22,x21
    b.ge .Lscalefluxesend104
    mov x23,x19
.Lscalefluxcol105:
    cmp x23,x24
    b.ge .Lscalefluxcolend106
    ldr x16,[x29,#904]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lnofluxscale107
    ldr x16,[x29,#920]
    ldr w9,[x16,x23,lsl #2]
    sub x27,x9,#1
    ldr x16,[x29,#928]
    ldr w9,[x16,x23,lsl #2]
    sub x28,x9,#1
    cmp x22,x27
    b.gt .Lnofluxscale107
    sub x9,x28,#1
    cmp x22,x9
    b.lt .Lnofluxscale107
    ldr x16,[x29,#1616]
    ldr d2,[x16,x23,lsl #3]
    ldr x16,[x29,#1088]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d0,d2
    ldr x16,[x29,#1088]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1016]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d0,d2
    ldr x16,[x29,#1016]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1104]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d0,d2
    ldr x16,[x29,#1104]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1240]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d0,d2
    ldr x16,[x29,#1240]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1256]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d0,d2
    ldr x16,[x29,#1256]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1288]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d0,d2
    ldr x16,[x29,#1288]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1272]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d0,d2
    ldr x16,[x29,#1272]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1360]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d0,d2
    ldr x16,[x29,#1360]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1024]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d0,d2
    ldr x16,[x29,#1024]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1024]
    mov x10,x22
    madd x10,x10,x20,x23
    mul x11,x20,x21
    add x10,x10,x11
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d0,d2
    ldr x16,[x29,#1024]
    mov x10,x22
    madd x10,x10,x20,x23
    mul x11,x20,x21
    add x10,x10,x11
    str d0,[x16,x10,lsl #3]
.Lnofluxscale107:
    add x23,x23,#1
    b .Lscalefluxcol105
.Lscalefluxcolend106:
    add x22,x22,#1
    b .Lscalefluxes103
.Lscalefluxesend104:
    mov x23,x19
.Lpathology108:
    cmp x23,x24
    b.ge .Lpathologyend109
    ldr x16,[x29,#912]
    ldr w9,[x16,x23,lsl #2]
    cmp w9,#2
    b.ne .Lnotpathology110
    ldr x16,[x29,#920]
    ldr w9,[x16,x23,lsl #2]
    ldr x16,[x29,#928]
    ldr w10,[x16,x23,lsl #2]
    cmp w9,w10
    b.ne .Lnotpathology110
    sub w10,w21,#1
    cmp w9,w10
    b.lt .Lnotpathology110
    mov w9,#0
    ldr x16,[x29,#904]
    str w9,[x16,x23,lsl #2]
    ldr x16,[x29,#912]
    str w9,[x16,x23,lsl #2]
.Lnotpathology110:
    add x23,x23,#1
    b .Lpathology108
.Lpathologyend109:
    mov x23,x19
.Lclearscv111:
    cmp x23,x24
    b.ge .Lclearscvend112
    mov w9,#0
    ldr x16,[x29,#1728]
    str w9,[x16,x23,lsl #2]
    ldr x16,[x29,#976]
    ldr w9,[x16,x23,lsl #2]
    cbnz w9,.Lkeepshal113
    ldr x16,[x29,#912]
    ldr w9,[x16,x23,lsl #2]
    cmp w9,#2
    b.ne .Lkeepshal113
    mov w9,#1
    ldr x16,[x29,#1728]
    str w9,[x16,x23,lsl #2]
    mov w9,#0
    ldr x16,[x29,#904]
    str w9,[x16,x23,lsl #2]
.Lkeepshal113:
    add x23,x23,#1
    b .Lclearscv111
.Lclearscvend112:
    ldr x16,[x29,#648]
    ldr w9,[x16,#296]
    ldr x16,[x29,#664]
    ldr w10,[x16,#44]
    orr w9,w9,w10
    cbz w9,.Lnolight114
    mov x23,x19
.Llightning115:
    cmp x23,x24
    b.ge .Llightningend116
    ldr x16,[x29,#904]
    ldr w9,[x16,x23,lsl #2]
    ldr x16,[x29,#936]
    str w9,[x16,x23,lsl #2]
    ldr x16,[x29,#928]
    ldr w9,[x16,x23,lsl #2]
    ldr x16,[x29,#952]
    str w9,[x16,x23,lsl #2]
    ldr x16,[x29,#920]
    ldr w9,[x16,x23,lsl #2]
    ldr x16,[x29,#944]
    str w9,[x16,x23,lsl #2]
    add x23,x23,#1
    b .Llightning115
.Llightningend116:
.Lnolight114:
    mov x23,x19
.Ldisableswitch117:
    cmp x23,x24
    b.ge .Ldisableswitchend118
    ldr x16,[x29,#912]
    ldr w9,[x16,x23,lsl #2]
    ldr x16,[x29,#2120]
    ldr w10,[x16,#252]
    cbnz w10,.Ltestdeep120
    cmp w9,#2
    b.eq .Ldisableconv121
.Ltestdeep120:
    ldr x16,[x29,#2120]
    ldr w10,[x16,#248]
    cbnz w10,.Lkeepconv119
    cmp w9,#1
    b.ne .Lkeepconv119
.Ldisableconv121:
    mov w9,#1
    ldr x16,[x29,#1728]
    str w9,[x16,x23,lsl #2]
    mov w9,#0
    ldr x16,[x29,#904]
    str w9,[x16,x23,lsl #2]
.Lkeepconv119:
    add x23,x23,#1
    b .Ldisableswitch117
.Ldisableswitchend118:
    mov x23,x19
.Lddtopbound122:
    cmp x23,x24
    b.ge .Lddtopboundend123
    ldr x16,[x29,#1696]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lnotopbound124
    ldr x16,[x29,#1672]
    ldr w9,[x16,x23,lsl #2]
    ldr x16,[x29,#928]
    ldr w10,[x16,x23,lsl #2]
    cmp w9,w10
    b.gt .Lnotopbound124
    add w9,w10,#1
    ldr x16,[x29,#1672]
    str w9,[x16,x23,lsl #2]
.Lnotopbound124:
    add x23,x23,#1
    b .Lddtopbound122
.Lddtopboundend123:
    mov x22,#1
.Lddzerotop125:
    cmp x22,x21
    b.ge .Lddzerotopend126
    mov x23,x19
.Lddzerotopcol127:
    cmp x23,x24
    b.ge .Lddzerotopcolend128
    ldr x16,[x29,#1696]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lnoddzero129
    ldr x16,[x29,#1672]
    ldr w9,[x16,x23,lsl #2]
    add w10,w22,#1
    cmp w10,w9
    b.gt .Lnoddzero129
    ldr d0,.LC1
    ldr x16,[x29,#1112]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    b.eq .Lnoddzero129
    ldr x16,[x29,#1096]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1248]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1264]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1280]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
.Lnoddzero129:
    add x23,x23,#1
    b .Lddzerotopcol127
.Lddzerotopcolend128:
    add x22,x22,#1
    b .Lddzerotop125
.Lddzerotopend126:
    ldr x9,[x29,#640]
    mov x0,x9
    ldr x9,[x29,#2120]
    mov x1,x9
    ldr x9,[x29,#680]
    mov x2,x9
    ldr x9,[x29,#688]
    mov x3,x9
    ldr x9,[x29,#696]
    mov x4,x9
    ldr x9,[x29,#704]
    mov x5,x9
    ldr x9,[x29,#720]
    mov x6,x9
    ldr x9,[x29,#728]
    mov x7,x9
    ldr x9,[x29,#736]
    str x9,[sp,#0]
    ldr x9,[x29,#776]
    str x9,[sp,#8]
    ldr x9,[x29,#1184]
    str x9,[sp,#16]
    ldr x9,[x29,#1192]
    str x9,[sp,#24]
    ldr x9,[x29,#808]
    str x9,[sp,#32]
    ldr x9,[x29,#800]
    str x9,[sp,#40]
    ldr x9,[x29,#824]
    str x9,[sp,#48]
    ldr x9,[x29,#712]
    str x9,[sp,#56]
    ldr x9,[x29,#904]
    str x9,[sp,#64]
    ldr x9,[x29,#920]
    str x9,[sp,#72]
    ldr x9,[x29,#928]
    str x9,[sp,#80]
    ldr x9,[x29,#1672]
    str x9,[sp,#88]
    add x9,x29,#2160
    str x9,[sp,#96]
    ldr x9,[x29,#912]
    str x9,[sp,#104]
    ldr x9,[x29,#1696]
    str x9,[sp,#112]
    ldr x9,[x29,#1088]
    str x9,[sp,#120]
    ldr x9,[x29,#1096]
    str x9,[sp,#128]
    ldr x9,[x29,#1240]
    str x9,[sp,#136]
    ldr x9,[x29,#1248]
    str x9,[sp,#144]
    ldr x9,[x29,#1256]
    str x9,[sp,#152]
    ldr x9,[x29,#1264]
    str x9,[sp,#160]
    ldr x9,[x29,#1288]
    str x9,[sp,#168]
    ldr x9,[x29,#1016]
    str x9,[sp,#176]
    ldr x9,[x29,#1024]
    str x9,[sp,#184]
    ldr x9,[x29,#1072]
    str x9,[sp,#192]
    ldr x9,[x29,#1032]
    str x9,[sp,#200]
    ldr x9,[x29,#1272]
    str x9,[sp,#208]
    ldr x9,[x29,#1280]
    str x9,[sp,#216]
    ldr x9,[x29,#1344]
    str x9,[sp,#224]
    ldr x9,[x29,#1352]
    str x9,[sp,#232]
    ldr x9,[x29,#1048]
    str x9,[sp,#240]
    ldr x9,[x29,#1056]
    str x9,[sp,#248]
    ldr x9,[x29,#1064]
    str x9,[sp,#256]
    ldr x9,[x29,#1104]
    str x9,[sp,#264]
    ldr x9,[x29,#1112]
    str x9,[sp,#272]
    bl md2asm_cuflxn
    mov x22,#1
.Lrates130:
    sub x9,x21,#1
    cmp x22,x9
    b.ge .Lratesend131
    mov x23,x19
.Lratescol132:
    cmp x23,x24
    b.ge .Lratescolend133
    ldr x16,[x29,#1696]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lnoddrate135
    ldr x16,[x29,#1672]
    ldr w9,[x16,x23,lsl #2]
    sub w9,w9,#1
    add w10,w22,#1
    cmp w10,w9
    b.lt .Lnoddrate135
    ldr x16,[x29,#1096]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1096]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#1112]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fneg d0,d0
    fadd d0,d0,d1
    fadd d0,d0,d2
    fcmp d0,#0.0
    b.ge .Lnoddrate135
    fsub d0,d2,d0
    ldr x16,[x29,#1112]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
.Lnoddrate135:
    ldr x16,[x29,#904]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lnouprate134
    ldr x16,[x29,#928]
    ldr w9,[x16,x23,lsl #2]
    sub w9,w9,#1
    add w10,w22,#1
    cmp w10,w9
    b.lt .Lnouprate134
    ldr x16,[x29,#1088]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1088]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#1104]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fsub d0,d0,d1
    fadd d0,d0,d2
    fcmp d0,#0.0
    b.ge .Lupratedone136
    fsub d0,d2,d0
    ldr x16,[x29,#1104]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
.Lupratedone136:
    ldr x16,[x29,#1048]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1056]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#1048]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    ldr x16,[x29,#1056]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d3,[x16,x10,lsl #3]
    fadd d0,d0,d1
    fsub d0,d0,d2
    fsub d0,d0,d3
    ldr x16,[x29,#1272]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr d0,.LC1
    ldr x16,[x29,#1280]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
.Lnouprate134:
    add x23,x23,#1
    b .Lratescol132
.Lratescolend133:
    add x22,x22,#1
    b .Lrates130
.Lratesend131:
    mov x23,x19
.Lddhumidity137:
    cmp x23,x24
    b.ge .Lddhumidityend138
    ldr x16,[x29,#1696]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lnoddhumidity139
    ldr x16,[x29,#1672]
    ldr w9,[x16,x23,lsl #2]
    sub x22,x9,#1
    add x25,x22,#1
    sub x9,x21,#1
    cmp x25,x9
    csel x25,x25,x9,lt
    ldr x16,[x29,#1264]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1264]
    mov x10,x25
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr d2,.LC21
    fmul d1,d2,d1
    fcmp d0,d1
    b.ge .Lnoddhumidity139
    ldr x16,[x29,#2120]
    ldr d0,[x16,#80]
    fcmp d0,#0.0
    b.ne .Lddhumiditymass140
    ldr x16,[x29,#1264]
    mov x10,x22
    madd x10,x10,x20,x23
    str d1,[x16,x10,lsl #3]
    b .Lnoddhumidity139
.Lddhumiditymass140:
    ldr x16,[x29,#1096]
    mov x10,x25
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr d1,.LC21
    fmul d0,d1,d0
    ldr x16,[x29,#1096]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
.Lnoddhumidity139:
    add x23,x23,#1
    b .Lddhumidity137
.Lddhumidityend138:
    mov x22,#1
.Lwatercorrection141:
    cmp x22,x21
    b.ge .Lwatercorrectionend142
    mov x23,x19
.Lwatercorrectcol143:
    cmp x23,x24
    b.ge .Lwatercorrectcolend144
    ldr x16,[x29,#904]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lnowatercorrect145
    ldr x16,[x29,#928]
    ldr w9,[x16,x23,lsl #2]
    sub x28,x9,#1
    ldr x16,[x29,#920]
    ldr w9,[x16,x23,lsl #2]
    sub x27,x9,#1
    sub x9,x28,#1
    cmp x22,x9
    b.lt .Lnowatercorrect145
    cmp x22,x27
    b.ge .Lnowatercorrect145
    ldr x16,[x29,#720]
    ldr d0,[x16]
    adrp x16,:got:__yomcst_MOD_rg
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rg]
    ldr d1,[x16]
    ldr x16,[x29,#808]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    ldr x16,[x29,#808]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d3,[x16,x10,lsl #3]
    fmul d0,d0,d1
    fsub d1,d2,d3
    fdiv d0,d0,d1
    str d0,[x29,#1840]
    ldr x16,[x29,#1256]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d4,[x16,x10,lsl #3]
    ldr x16,[x29,#1264]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#1256]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    ldr x16,[x29,#1264]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d3,[x16,x10,lsl #3]
    fadd d0,d2,d3
    fsub d0,d0,d4
    fsub d0,d0,d1
    ldr x16,[x29,#1288]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#1288]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    ldr x16,[x29,#1272]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d3,[x16,x10,lsl #3]
    fadd d0,d0,d1
    fsub d0,d0,d2
    fadd d0,d0,d3
    ldr x16,[x29,#1032]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#1032]
    mov x10,x22
    madd x10,x10,x20,x23
    mul x11,x20,x21
    add x10,x10,x11
    ldr d2,[x16,x10,lsl #3]
    ldr x16,[x29,#1016]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d3,[x16,x10,lsl #3]
    ldr d4,[x29,#1840]
    fsub d0,d0,d1
    fsub d0,d0,d2
    fsub d0,d0,d3
    fmul d0,d0,d4
    str d0,[x29,#1896]
    ldr x16,[x29,#736]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fadd d0,d1,d0
    fcmp d0,#0.0
    b.ge .Lnodeficiency146
    fcmp d3,#0.0
    b.le .Lnodeficiency146
    fneg d0,d0
    fdiv d0,d0,d4
    fmin d0,d0,d3
    fadd d3,d3,d0
    ldr x16,[x29,#1016]
    mov x10,x22
    madd x10,x10,x20,x23
    str d3,[x16,x10,lsl #3]
    str d0,[x29,#1856]
    ldr x16,[x29,#1024]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr d0,[x29,#1856]
    ldr x16,[x29,#1016]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fmul d0,d0,d1
    fdiv d0,d0,d2
    fadd d0,d1,d0
    ldr x16,[x29,#1024]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1024]
    mov x10,x22
    madd x10,x10,x20,x23
    mul x11,x20,x21
    add x10,x10,x11
    ldr d1,[x16,x10,lsl #3]
    ldr d0,[x29,#1856]
    ldr x16,[x29,#1016]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fmul d0,d0,d1
    fdiv d0,d0,d2
    fadd d0,d1,d0
    ldr x16,[x29,#1024]
    mov x10,x22
    madd x10,x10,x20,x23
    mul x11,x20,x21
    add x10,x10,x11
    str d0,[x16,x10,lsl #3]
.Lnodeficiency146:
    ldr x16,[x29,#1016]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fcmp d0,#0.0
    b.ge .Lnowatercorrect145
    ldr d0,.LC1
    ldr x16,[x29,#1016]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1024]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1024]
    mov x10,x22
    madd x10,x10,x20,x23
    mul x11,x20,x21
    add x10,x10,x11
    str d0,[x16,x10,lsl #3]
.Lnowatercorrect145:
    ldr x16,[x29,#904]
    ldr w9,[x16,x23,lsl #2]
    cbnz w9,.Lkeeprate147
    ldr d0,.LC1
    ldr x16,[x29,#1104]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
.Lkeeprate147:
    ldr x16,[x29,#1096]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fcmp d0,#0.0
    b.ne .Lhasprevdd148
    ldr d0,.LC1
    ldr x16,[x29,#1112]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
.Lhasprevdd148:
    add x23,x23,#1
    b .Lwatercorrectcol143
.Lwatercorrectcolend144:
    add x22,x22,#1
    b .Lwatercorrection141
.Lwatercorrectionend142:
    ldr x16,[x29,#2120]
    ldr d0,[x16,#80]
    fcmp d0,#0.0
    b.le .Lnoimplicitstate149
    sub x22,x21,#1
.Limplicitstate150:
    cmp x22,#1
    b.lt .Limplicitstateend151
    mov x23,x19
.Limplicitstatecol152:
    cmp x23,x24
    b.ge .Limplicitstatecolend153
    ldr x16,[x29,#904]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lnoimplicitcol154
    ldr x16,[x29,#920]
    ldr w9,[x16,x23,lsl #2]
    sub x27,x9,#1
    ldr x16,[x29,#928]
    ldr w9,[x16,x23,lsl #2]
    sub x28,x9,#1
    cmp x22,x27
    b.le .Limplicitcloud155
    ldr x16,[x29,#1088]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr d7,.LC35
    fmax d0,d0,d7
    ldr d1,.LC0
    fdiv d2,d1,d0
    ldr x16,[x29,#1192]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1256]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmul d1,d1,d2
    fadd d0,d0,d1
    ldr x16,[x29,#1000]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1184]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1240]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmul d1,d1,d2
    fmul d1,d1,d9
    fadd d0,d0,d1
    ldr x16,[x29,#992]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1088]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#824]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fmul d0,d8,d0
    fadd d0,d0,d2
    fmul d0,d1,d0
    ldr x16,[x29,#1240]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1000]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d1,d0
    ldr x16,[x29,#1256]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1696]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lnoimplicitcol154
    ldr x16,[x29,#1096]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr d7,.LC36
    fmin d0,d0,d7
    ldr d1,.LC0
    fdiv d2,d1,d0
    ldr x16,[x29,#1192]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1264]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmul d1,d1,d2
    fadd d0,d0,d1
    ldr x16,[x29,#1232]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1184]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1248]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmul d1,d1,d2
    fmul d1,d1,d9
    fadd d0,d0,d1
    ldr x16,[x29,#1224]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1096]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#824]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fmul d0,d8,d0
    fadd d0,d0,d2
    fmul d0,d1,d0
    ldr x16,[x29,#1248]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1232]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d1,d0
    ldr x16,[x29,#1264]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    b .Lnoimplicitcol154
.Limplicitcloud155:
    cmp x22,x28
    b.lt .Lnoimplicitcol154
    ldr x16,[x29,#992]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#824]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#1088]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fmul d0,d8,d0
    fadd d0,d0,d1
    fmul d0,d2,d0
    ldr x16,[x29,#1240]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1000]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d2,d0
    ldr x16,[x29,#1256]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1224]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#824]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#1096]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fmul d0,d8,d0
    fadd d0,d0,d1
    fmul d0,d2,d0
    ldr x16,[x29,#1248]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1232]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d2,d0
    ldr x16,[x29,#1264]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
.Lnoimplicitcol154:
    add x23,x23,#1
    b .Limplicitstatecol152
.Limplicitstatecolend153:
    sub x22,x22,#1
    b .Limplicitstate150
.Limplicitstateend151:
.Lnoimplicitstate149:
    ldr x9,[x29,#640]
    mov x0,x9
    ldr x9,[x29,#640]
    add x9,x9,#456
    mov x1,x9
    ldr x9,[x29,#2120]
    mov x2,x9
    ldr x9,[x29,#648]
    mov x3,x9
    ldr x9,[x29,#680]
    mov x4,x9
    ldr x9,[x29,#688]
    mov x5,x9
    ldr x9,[x29,#696]
    mov x6,x9
    ldr x9,[x29,#704]
    mov x7,x9
    add x9,x29,#2160
    str x9,[sp,#0]
    ldr x9,[x29,#912]
    str x9,[sp,#8]
    ldr x9,[x29,#928]
    str x9,[sp,#16]
    ldr x9,[x29,#920]
    str x9,[sp,#24]
    ldr x9,[x29,#1672]
    str x9,[sp,#32]
    ldr x9,[x29,#904]
    str x9,[sp,#40]
    ldr x9,[x29,#1696]
    str x9,[sp,#48]
    ldr x9,[x29,#1720]
    str x9,[sp,#56]
    ldr x9,[x29,#720]
    str x9,[sp,#64]
    ldr x9,[x29,#808]
    str x9,[sp,#72]
    ldr x9,[x29,#800]
    str x9,[sp,#80]
    ldr x9,[x29,#824]
    str x9,[sp,#88]
    ldr x9,[x29,#816]
    str x9,[sp,#96]
    ldr x9,[x29,#728]
    str x9,[sp,#104]
    ldr x9,[x29,#1184]
    str x9,[sp,#112]
    ldr x9,[x29,#736]
    str x9,[sp,#120]
    ldr x9,[x29,#1192]
    str x9,[sp,#128]
    ldr x9,[x29,#776]
    str x9,[sp,#136]
    ldr x9,[x29,#1352]
    str x9,[sp,#144]
    ldr x9,[x29,#1016]
    str x9,[sp,#152]
    ldr x9,[x29,#1024]
    str x9,[sp,#160]
    ldr x9,[x29,#1032]
    str x9,[sp,#168]
    ldr x9,[x29,#1088]
    str x9,[sp,#176]
    ldr x9,[x29,#1096]
    str x9,[sp,#184]
    ldr x9,[x29,#1240]
    str x9,[sp,#192]
    ldr x9,[x29,#1248]
    str x9,[sp,#200]
    ldr x9,[x29,#1256]
    str x9,[sp,#208]
    ldr x9,[x29,#1264]
    str x9,[sp,#216]
    ldr x9,[x29,#1288]
    str x9,[sp,#224]
    ldr x9,[x29,#1272]
    str x9,[sp,#232]
    ldr x9,[x29,#1344]
    str x9,[sp,#240]
    ldr x9,[x29,#1048]
    str x9,[sp,#248]
    ldr x9,[x29,#1056]
    str x9,[sp,#256]
    ldr x9,[x29,#856]
    str x9,[sp,#264]
    ldr x9,[x29,#864]
    str x9,[sp,#272]
    ldr x9,[x29,#1040]
    str x9,[sp,#280]
    bl md2asm_cudtdqn
    ldr x16,[x29,#2120]
    ldr w9,[x16,#264]
    cbz w9,.Lnomomentum156
    sub x22,x21,#2
.Lupwind157:
    cmp x22,#1
    b.lt .Lupwindend158
    mov x23,x19
.Lupwindcol159:
    cmp x23,x24
    b.ge .Lupwindcolend160
    ldr x16,[x29,#904]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lnoupwind161
    ldr x16,[x29,#920]
    ldr w9,[x16,x23,lsl #2]
    sub x27,x9,#1
    cmp x22,x27
    b.ne .Lnotwindbase162
    ldr x16,[x29,#912]
    ldr w9,[x16,x23,lsl #2]
    cmp w9,#3
    b.ge .Lmidwindbase163
    ldr x16,[x29,#1688]
    ldr w9,[x16,x23,lsl #2]
    sub x25,x9,#2
    ldr x16,[x29,#744]
    mov x10,x25
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1296]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#752]
    mov x10,x25
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1304]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    b .Lwindbasecopied164
.Lmidwindbase163:
    ldr x16,[x29,#744]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1296]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#752]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1304]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
.Lwindbasecopied164:
.Lnotwindbase162:
    ldr x16,[x29,#928]
    ldr w9,[x16,x23,lsl #2]
    sub x28,x9,#1
    cmp x22,x27
    b.ge .Lnoupwind161
    cmp x22,x28
    b.lt .Lnoupwind161
    ldr x16,[x29,#1088]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1088]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#1104]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fsub d0,d0,d1
    fadd d0,d0,d2
    str d0,[x29,#1904]
    str d2,[x29,#1912]
    ldr x16,[x29,#2120]
    ldr d0,[x16,#120]
    ldr x16,[x29,#1088]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmax d0,d0,d1
    ldr d1,.LC0
    fdiv d0,d1,d0
    str d0,[x29,#1896]
    ldr x16,[x29,#1296]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1088]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr d2,[x29,#1904]
    ldr x16,[x29,#744]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d3,[x16,x10,lsl #3]
    ldr d4,[x29,#1912]
    fmul d1,d0,d1
    fmul d2,d2,d3
    fadd d1,d1,d2
    fmul d0,d4,d0
    fsub d0,d1,d0
    ldr d1,[x29,#1896]
    fmul d0,d0,d1
    ldr x16,[x29,#1296]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1304]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1088]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr d2,[x29,#1904]
    ldr x16,[x29,#752]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d3,[x16,x10,lsl #3]
    ldr d4,[x29,#1912]
    fmul d1,d0,d1
    fmul d2,d2,d3
    fadd d1,d1,d2
    fmul d0,d4,d0
    fsub d0,d1,d0
    ldr d1,[x29,#1896]
    fmul d0,d0,d1
    ldr x16,[x29,#1304]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
.Lnoupwind161:
    add x23,x23,#1
    b .Lupwindcol159
.Lupwindcolend160:
    sub x22,x22,#1
    b .Lupwind157
.Lupwindend158:
    mov x22,#2
.Ldownwind165:
    cmp x22,x21
    b.ge .Ldownwindend166
    mov x23,x19
.Ldownwindcol167:
    cmp x23,x24
    b.ge .Ldownwindcolend168
    ldr x16,[x29,#904]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lnodownwind169
    ldr x16,[x29,#1672]
    ldr w9,[x16,x23,lsl #2]
    add w10,w22,#1
    cmp w10,w9
    b.ne .Lbelowddwind170
    ldr x16,[x29,#1296]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#744]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr d2,.LC11
    fadd d0,d0,d1
    fmul d0,d2,d0
    ldr x16,[x29,#1312]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1304]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#752]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr d2,.LC11
    fadd d0,d0,d1
    fmul d0,d2,d0
    ldr x16,[x29,#1320]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    b .Lnodownwind169
.Lbelowddwind170:
    b.lt .Lnodownwind169
    ldr x16,[x29,#1096]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1096]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#1112]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fneg d0,d0
    fadd d0,d0,d1
    fadd d0,d0,d2
    str d0,[x29,#1904]
    ldr x16,[x29,#2120]
    ldr d0,[x16,#120]
    fneg d0,d0
    ldr x16,[x29,#1096]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmin d0,d0,d1
    ldr d1,.LC0
    fdiv d0,d1,d0
    str d0,[x29,#1896]
    ldr x16,[x29,#1312]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1096]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr d2,[x29,#1904]
    ldr x16,[x29,#744]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d3,[x16,x10,lsl #3]
    ldr x16,[x29,#1112]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d4,[x16,x10,lsl #3]
    fmul d1,d0,d1
    fmul d2,d2,d3
    fsub d1,d1,d2
    fmul d0,d4,d0
    fadd d0,d1,d0
    ldr d1,[x29,#1896]
    fmul d0,d0,d1
    ldr x16,[x29,#1312]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1320]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1096]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr d2,[x29,#1904]
    ldr x16,[x29,#752]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d3,[x16,x10,lsl #3]
    ldr x16,[x29,#1112]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d4,[x16,x10,lsl #3]
    fmul d1,d0,d1
    fmul d2,d2,d3
    fsub d1,d1,d2
    fmul d0,d4,d0
    fadd d0,d1,d0
    ldr d1,[x29,#1896]
    fmul d0,d0,d1
    ldr x16,[x29,#1320]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
.Lnodownwind169:
    add x23,x23,#1
    b .Ldownwindcol167
.Ldownwindcolend168:
    add x22,x22,#1
    b .Ldownwind165
.Ldownwindend166:
    mov x23,xzr
.Lunitmfs171:
    cmp x23,x20
    b.ge .Lunitmfsend172
    ldr d0,.LC0
    ldr x16,[x29,#1616]
    str d0,[x16,x23,lsl #3]
    add x23,x23,#1
    b .Lunitmfs171
.Lunitmfsend172:
    ldr x16,[x29,#2120]
    ldr d0,[x16,#72]
    ldr d1,.LC0
    fcmp d0,d1
    b.gt .Lnoexplicitmomentumlimit173
    mov x22,#1
.Lmomentumlimit174:
    cmp x22,x21
    b.ge .Lmomentumlimitend175
    mov x23,x19
.Lmomentumlimitcol176:
    cmp x23,x24
    b.ge .Lmomentumlimitcolend177
    ldr x16,[x29,#904]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lnomomentumlimit178
    ldr x16,[x29,#928]
    ldr w9,[x16,x23,lsl #2]
    sub x28,x9,#1
    sub x9,x28,#1
    cmp x22,x9
    b.lt .Lnomomentumlimit178
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
    fmul d0,d0,d12
    ldr x16,[x29,#1088]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fcmp d1,d0
    b.le .Lnomomentumlimit178
    cmp x22,x28
    b.lt .Lnomomentumlimit178
    fdiv d0,d0,d1
    ldr x16,[x29,#1616]
    ldr d1,[x16,x23,lsl #3]
    fmin d0,d1,d0
    ldr x16,[x29,#1616]
    str d0,[x16,x23,lsl #3]
.Lnomomentumlimit178:
    add x23,x23,#1
    b .Lmomentumlimitcol176
.Lmomentumlimitcolend177:
    add x22,x22,#1
    b .Lmomentumlimit174
.Lmomentumlimitend175:
.Lnoexplicitmomentumlimit173:
    mov x22,#0
.Lmomentumflux179:
    cmp x22,x21
    b.ge .Lmomentumfluxend180
    mov x23,x19
.Lmomentumfluxcol181:
    cmp x23,x24
    b.ge .Lmomentumfluxcolend182
    ldr x16,[x29,#1088]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1376]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1096]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1384]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#904]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lnomomentumscale183
    ldr x16,[x29,#928]
    ldr w9,[x16,x23,lsl #2]
    sub x28,x9,#1
    sub x9,x28,#1
    cmp x22,x9
    b.lt .Lnomomentumscale183
    ldr x16,[x29,#1616]
    ldr d2,[x16,x23,lsl #3]
    ldr x16,[x29,#1088]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d0,d2
    ldr x16,[x29,#1376]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1096]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d0,d2
    ldr x16,[x29,#1384]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
.Lnomomentumscale183:
    add x23,x23,#1
    b .Lmomentumfluxcol181
.Lmomentumfluxcolend182:
    add x22,x22,#1
    b .Lmomentumflux179
.Lmomentumfluxend180:
    ldr x16,[x29,#2120]
    ldr d0,[x16,#72]
    fcmp d0,#0.0
    b.le .Lnoimplicitwind184
    mov x23,x19
.Lbasewindflux185:
    cmp x23,x24
    b.ge .Lbasewindfluxend186
    ldr x16,[x29,#904]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lnobasewindflux187
    ldr x16,[x29,#920]
    ldr w9,[x16,x23,lsl #2]
    sub x27,x9,#1
    ldr x16,[x29,#1376]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    ldr x16,[x29,#1296]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#744]
    mov x10,x27
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d0,d0,d1
    fmul d0,d2,d0
    ldr x16,[x29,#1624]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1376]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    ldr x16,[x29,#1304]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#752]
    mov x10,x27
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d0,d0,d1
    fmul d0,d2,d0
    ldr x16,[x29,#1632]
    str d0,[x16,x23,lsl #3]
.Lnobasewindflux187:
    add x23,x23,#1
    b .Lbasewindflux185
.Lbasewindfluxend186:
    mov x22,#1
.Limplicitwind188:
    cmp x22,x21
    b.ge .Limplicitwindend189
    mov x23,x19
.Limplicitwindcol190:
    cmp x23,x24
    b.ge .Limplicitwindcolend191
    ldr x16,[x29,#904]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lnoimplicitwindcol192
    ldr x16,[x29,#920]
    ldr w9,[x16,x23,lsl #2]
    sub x27,x9,#1
    ldr x16,[x29,#928]
    ldr w9,[x16,x23,lsl #2]
    sub x28,x9,#1
    cmp x22,x27
    b.le .Lnotbelowwind193
    ldr x16,[x29,#808]
    mov x10,x21
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#808]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#808]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fsub d1,d0,d1
    fsub d0,d0,d2
    fdiv d0,d1,d0
    str d0,[x29,#1840]
    ldr x16,[x29,#912]
    ldr w9,[x16,x23,lsl #2]
    cmp w9,#3
    b.ne .Lnonsquarewind194
    fmul d0,d0,d0
    str d0,[x29,#1840]
.Lnonsquarewind194:
    ldr x16,[x29,#2120]
    ldr d0,[x16,#120]
    ldr x16,[x29,#1376]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmax d0,d0,d1
    ldr d1,.LC0
    fdiv d0,d1,d0
    str d0,[x29,#1896]
    ldr x16,[x29,#1624]
    ldr d0,[x16,x23,lsl #3]
    ldr d1,[x29,#1840]
    ldr d2,[x29,#1896]
    ldr x16,[x29,#744]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d3,[x16,x10,lsl #3]
    fmul d0,d0,d1
    fmul d0,d0,d2
    fadd d0,d3,d0
    ldr x16,[x29,#1296]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1632]
    ldr d0,[x16,x23,lsl #3]
    ldr d1,[x29,#1840]
    ldr d2,[x29,#1896]
    ldr x16,[x29,#752]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d3,[x16,x10,lsl #3]
    fmul d0,d0,d1
    fmul d0,d0,d2
    fadd d0,d3,d0
    ldr x16,[x29,#1304]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1384]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr d1,[x29,#1840]
    fmul d0,d0,d1
    ldr x16,[x29,#1384]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#744]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1312]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#744]
    mov x10,x27
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fadd d0,d0,d1
    fsub d0,d0,d2
    ldr x16,[x29,#1312]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#752]
    mov x10,x22
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1320]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#752]
    mov x10,x27
    sub x10,x10,#1
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fadd d0,d0,d1
    fsub d0,d0,d2
    ldr x16,[x29,#1320]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
.Lnotbelowwind193:
    cmp x22,x28
    b.lt .Lnoimplicitwindcol192
    ldr x16,[x29,#1296]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fabs d1,d0
    ldr x16,[x29,#2120]
    ldr d2,[x16,#224]
    fmin d1,d1,d2
    fmov x9,d0
    and x9,x9,#0x8000000000000000
    mov x10,#0x3ff0000000000000
    orr x9,x9,x10
    fmov d2,x9
    fmul d1,d1,d2
    fsub d0,d0,d1
    ldr x16,[x29,#1296]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1304]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fabs d1,d0
    ldr x16,[x29,#2120]
    ldr d2,[x16,#224]
    fmin d1,d1,d2
    fmov x9,d0
    and x9,x9,#0x8000000000000000
    mov x10,#0x3ff0000000000000
    orr x9,x9,x10
    fmov d2,x9
    fmul d1,d1,d2
    fsub d0,d0,d1
    ldr x16,[x29,#1304]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
.Lnoimplicitwindcol192:
    add x23,x23,#1
    b .Limplicitwindcol190
.Limplicitwindcolend191:
    add x22,x22,#1
    b .Limplicitwind188
.Limplicitwindend189:
.Lnoimplicitwind184:
    ldr x9,[x29,#2120]
    mov x0,x9
    ldr x9,[x29,#672]
    mov x1,x9
    ldr x9,[x29,#680]
    mov x2,x9
    ldr x9,[x29,#688]
    mov x3,x9
    ldr x9,[x29,#696]
    mov x4,x9
    ldr x9,[x29,#704]
    mov x5,x9
    add x9,x29,#2160
    mov x6,x9
    ldr x9,[x29,#912]
    mov x7,x9
    ldr x9,[x29,#920]
    str x9,[sp,#0]
    ldr x9,[x29,#928]
    str x9,[sp,#8]
    ldr x9,[x29,#904]
    str x9,[sp,#16]
    ldr x9,[x29,#720]
    str x9,[sp,#24]
    ldr x9,[x29,#808]
    str x9,[sp,#32]
    ldr x9,[x29,#800]
    str x9,[sp,#40]
    ldr x9,[x29,#744]
    str x9,[sp,#48]
    ldr x9,[x29,#752]
    str x9,[sp,#56]
    ldr x9,[x29,#1376]
    str x9,[sp,#64]
    ldr x9,[x29,#1384]
    str x9,[sp,#72]
    ldr x9,[x29,#1088]
    str x9,[sp,#80]
    ldr x9,[x29,#1096]
    str x9,[sp,#88]
    ldr x9,[x29,#1296]
    str x9,[sp,#96]
    ldr x9,[x29,#1312]
    str x9,[sp,#104]
    ldr x9,[x29,#1304]
    str x9,[sp,#112]
    ldr x9,[x29,#1320]
    str x9,[sp,#120]
    ldr x9,[x29,#848]
    str x9,[sp,#128]
    ldr x9,[x29,#872]
    str x9,[sp,#136]
    ldr x9,[x29,#880]
    str x9,[sp,#144]
    bl md2asm_cududv
    ldr x16,[x29,#2120]
    ldr w9,[x16,#288]
    cbz w9,.Lnodissheating195
    mov x23,x19
.Linitenergy196:
    cmp x23,x24
    b.ge .Linitenergyend197
    ldr d0,.LC1
    ldr x16,[x29,#1656]
    str d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1664]
    str d0,[x16,x23,lsl #3]
    add x23,x23,#1
    b .Linitenergy196
.Linitenergyend197:
    mov x22,#0
.Lenergy198:
    cmp x22,x21
    b.ge .Lenergyend199
    mov x23,x19
.Lenergycol200:
    cmp x23,x24
    b.ge .Lenergycolend201
    ldr d0,.LC1
    ldr x16,[x29,#1440]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#904]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lnocolenergy202
    ldr x16,[x29,#928]
    ldr w9,[x16,x23,lsl #2]
    sub x28,x9,#1
    sub x9,x28,#1
    cmp x22,x9
    b.lt .Lnocolenergy202
    ldr x16,[x29,#808]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#808]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d0,d0,d1
    str d0,[x29,#1840]
    ldr x16,[x29,#872]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1408]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d0,d0,d1
    str d0,[x29,#1920]
    ldr x16,[x29,#880]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1416]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d1,d0,d1
    str d1,[x29,#1928]
    ldr d0,[x29,#1920]
    fmul d2,d0,d0
    fmul d3,d1,d1
    fadd d2,d2,d3
    fsqrt d2,d2
    ldr x16,[x29,#1440]
    mov x10,x22
    madd x10,x10,x20,x23
    str d2,[x16,x10,lsl #3]
    ldr d3,[x29,#1840]
    fmul d2,d2,d3
    ldr x16,[x29,#1664]
    ldr d4,[x16,x23,lsl #3]
    fadd d2,d4,d2
    ldr x16,[x29,#1664]
    str d2,[x16,x23,lsl #3]
    ldr x16,[x29,#744]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    ldr x16,[x29,#752]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d4,[x16,x10,lsl #3]
    fmul d0,d2,d0
    fmul d1,d4,d1
    fadd d0,d0,d1
    fmul d0,d0,d3
    ldr x16,[x29,#1656]
    ldr d1,[x16,x23,lsl #3]
    fsub d0,d1,d0
    ldr x16,[x29,#1656]
    str d0,[x16,x23,lsl #3]
.Lnocolenergy202:
    add x23,x23,#1
    b .Lenergycol200
.Lenergycolend201:
    add x22,x22,#1
    b .Lenergy198
.Lenergyend199:
    mov x23,x19
.Lintegratedenergy203:
    cmp x23,x24
    b.ge .Lintegratedenergyend204
    ldr x16,[x29,#1656]
    ldr d0,[x16,x23,lsl #3]
    fmul d0,d0,d10
    ldr x16,[x29,#1136]
    str d0,[x16,x23,lsl #3]
    add x23,x23,#1
    b .Lintegratedenergy203
.Lintegratedenergyend204:
    mov x22,#0
.Lheating205:
    cmp x22,x21
    b.ge .Lheatingend206
    mov x23,x19
.Lheatingcol207:
    cmp x23,x24
    b.ge .Lheatingcolend208
    ldr x16,[x29,#904]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lnocolheating209
    ldr x16,[x29,#928]
    ldr w9,[x16,x23,lsl #2]
    sub x28,x9,#1
    sub x9,x28,#1
    cmp x22,x9
    b.lt .Lnocolheating209
    ldr x16,[x29,#1656]
    ldr d0,[x16,x23,lsl #3]
    ldr x16,[x29,#1440]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#1664]
    ldr d2,[x16,x23,lsl #3]
    ldr d7,.LC35
    fmax d2,d2,d7
    fmul d0,d9,d0
    fmul d0,d0,d1
    fdiv d0,d0,d2
    ldr x16,[x29,#856]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fadd d0,d1,d0
    ldr x16,[x29,#856]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
.Lnocolheating209:
    add x23,x23,#1
    b .Lheatingcol207
.Lheatingcolend208:
    add x22,x22,#1
    b .Lheating205
.Lheatingend206:
.Lnodissheating195:
.Lnomomentum156:
    ldr x16,[x29,#2120]
    ldr w9,[x16,#252]
    ldr x16,[x29,#2120]
    ldr w10,[x16,#248]
    and w9,w9,w10
    cbnz w9,.Lnofinalswitch210
    mov x22,#1
.Lswitchrates211:
    cmp x22,x21
    b.ge .Lswitchratesend212
    mov x23,x19
.Lswitchratescol213:
    cmp x23,x24
    b.ge .Lswitchratescolend214
    ldr x16,[x29,#1728]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lkeepswitchrate215
    ldr x16,[x29,#928]
    ldr w9,[x16,x23,lsl #2]
    sub x28,x9,#1
    sub x9,x28,#1
    cmp x22,x9
    b.lt .Lkeepswitchrate215
    ldr d0,.LC1
    ldr x16,[x29,#1104]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1112]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
.Lkeepswitchrate215:
    add x23,x23,#1
    b .Lswitchratescol213
.Lswitchratescolend214:
    add x22,x22,#1
    b .Lswitchrates211
.Lswitchratesend212:
    mov x23,x19
.Lswitchnames216:
    cmp x23,x24
    b.ge .Lswitchnamesend217
    ldr x16,[x29,#1728]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Lkeepswitchname218
    sub w9,w21,#1
    ldr x16,[x29,#928]
    str w9,[x16,x23,lsl #2]
    ldr x16,[x29,#920]
    str w9,[x16,x23,lsl #2]
.Lkeepswitchname218:
    add x23,x23,#1
    b .Lswitchnames216
.Lswitchnamesend217:
.Lnofinalswitch210:
    mov x23,xzr
.Lfirstdiss219:
    cmp x23,x20
    b.ge .Lfirstdissend220
    ldr d0,.LC1
    ldr x16,[x29,#1144]
    mov x10,#0
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    add x23,x23,#1
    b .Lfirstdiss219
.Lfirstdissend220:
    ldr d0,.LC37
    str d0,[x29,#1952]
    ldr d0,.LC38
    str d0,[x29,#1960]
    ldr d0,.LC39
    str d0,[x29,#1968]
    ldr d0,.LC40
    str d0,[x29,#1976]
    mov x22,#0
.Ldiagnostics221:
    cmp x22,x21
    b.ge .Ldiagnosticsend222
    mov x23,x19
.Ldiagnosticscol223:
    cmp x23,x24
    b.ge .Ldiagnosticscolend224
    ldr d0,.LC1
    ldr x16,[x29,#1144]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1080]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1080]
    mov x10,x22
    madd x10,x10,x20,x23
    mul x11,x20,x21
    add x10,x10,x11
    str d0,[x16,x10,lsl #3]
    add x25,x22,#1
    sub x9,x21,#1
    cmp x25,x9
    csel x25,x25,x9,lt
    sub x27,x22,#1
    cmp x27,#0
    csel x27,x27,xzr,gt
    ldr x16,[x29,#904]
    ldr w9,[x16,x23,lsl #2]
    cbz w9,.Linactivefinal225
    ldr x16,[x29,#928]
    ldr w9,[x16,x23,lsl #2]
    sub x28,x9,#1
    sub x9,x28,#1
    cmp x22,x9
    b.lt .Linactivefinal225
    ldr x16,[x29,#1104]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    ldr x16,[x29,#1112]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d3,[x16,x10,lsl #3]
    ldr x16,[x29,#1000]
    mov x10,x25
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1192]
    mov x10,x25
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d0,d0,d1
    fmul d0,d2,d0
    ldr x16,[x29,#1232]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#1192]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d4,[x16,x10,lsl #3]
    fsub d1,d1,d4
    fmul d1,d3,d1
    fadd d0,d0,d1
    ldr x16,[x29,#1024]
    mov x10,x22
    madd x10,x10,x20,x23
    mul x11,x20,x21
    mov x12,#2
    madd x10,x11,x12,x10
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#992]
    mov x10,x25
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1184]
    mov x10,x25
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d0,d0,d1
    fmul d0,d2,d0
    ldr x16,[x29,#1224]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#1184]
    mov x10,x27
    madd x10,x10,x20,x23
    ldr d4,[x16,x10,lsl #3]
    fsub d1,d1,d4
    fmul d1,d3,d1
    fadd d0,d0,d1
    ldr x16,[x29,#1024]
    mov x10,x22
    madd x10,x10,x20,x23
    mul x11,x20,x21
    mov x12,#3
    madd x10,x11,x12,x10
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#824]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#824]
    mov x10,x22
    add x10,x10,#1
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    adrp x16,:got:__yomcst_MOD_rg
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rg]
    ldr d2,[x16]
    fsub d0,d0,d1
    fdiv d2,d2,d0
    ldr x16,[x29,#1104]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d0,d2
    ldr x16,[x29,#1104]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1112]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    fmul d0,d0,d2
    ldr x16,[x29,#1112]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    adrp x16,:got:__yomcst_MOD_rd
    ldr x16,[x16,:got_lo12:__yomcst_MOD_rd]
    ldr d0,[x16]
    ldr x16,[x29,#728]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fmul d0,d0,d1
    adrp x16,:got:__yomcst_MOD_retv
    ldr x16,[x16,:got_lo12:__yomcst_MOD_retv]
    ldr d1,[x16]
    ldr x16,[x29,#736]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    ldr d3,.LC0
    fmul d1,d1,d2
    fadd d1,d3,d1
    fmul d0,d0,d1
    ldr x16,[x29,#800]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fdiv d0,d0,d1
    str d0,[x29,#1888]
    ldr x16,[x29,#872]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1408]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    fsub d0,d0,d1
    ldr x16,[x29,#744]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    fmul d0,d2,d0
    ldr x16,[x29,#880]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d1,[x16,x10,lsl #3]
    ldr x16,[x29,#1416]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d2,[x16,x10,lsl #3]
    ldr x16,[x29,#752]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d3,[x16,x10,lsl #3]
    fsub d1,d1,d2
    fmul d1,d3,d1
    fadd d0,d0,d1
    fabs d0,d0
    ldr d1,.LC3
    bl md2asm_pow_original_rounding_candidate
    ldr x16,[x29,#1144]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1048]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr d1,.LC27
    ldr d2,[x29,#1952]
    fmul d0,d0,d1
    fmul d0,d0,d2
    ldr d1,[x29,#1968]
    bl md2asm_pow_original_rounding_candidate
    ldr d1,[x29,#1888]
    ldr d2,.LC29
    fmul d1,d2,d1
    fmul d0,d1,d0
    ldr x16,[x29,#1080]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1056]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr d1,.LC41
    ldr d2,.LC27
    ldr d3,[x29,#1960]
    fmul d0,d1,d0
    fmul d0,d0,d2
    fmul d0,d0,d3
    ldr d1,[x29,#1976]
    bl md2asm_pow_original_rounding_candidate
    ldr d1,[x29,#1888]
    ldr d2,.LC42
    fmul d1,d2,d1
    fmul d0,d1,d0
    ldr x16,[x29,#1080]
    mov x10,x22
    madd x10,x10,x20,x23
    mul x11,x20,x21
    add x10,x10,x11
    str d0,[x16,x10,lsl #3]
    b .Lfinaldone226
.Linactivefinal225:
    ldr d0,.LC1
    ldr x16,[x29,#1088]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1096]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1016]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1008]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1040]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1104]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1112]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1024]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1024]
    mov x10,x22
    madd x10,x10,x20,x23
    mul x11,x20,x21
    add x10,x10,x11
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1024]
    mov x10,x22
    madd x10,x10,x20,x23
    mul x11,x20,x21
    mov x12,#2
    madd x10,x11,x12,x10
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1024]
    mov x10,x22
    madd x10,x10,x20,x23
    mul x11,x20,x21
    mov x12,#3
    madd x10,x11,x12,x10
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1032]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1032]
    mov x10,x22
    madd x10,x10,x20,x23
    mul x11,x20,x21
    add x10,x10,x11
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#728]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#992]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
    ldr x16,[x29,#736]
    mov x10,x22
    madd x10,x10,x20,x23
    ldr d0,[x16,x10,lsl #3]
    ldr x16,[x29,#1000]
    mov x10,x22
    madd x10,x10,x20,x23
    str d0,[x16,x10,lsl #3]
.Lfinaldone226:
    add x23,x23,#1
    b .Ldiagnosticscol223
.Ldiagnosticscolend224:
    add x22,x22,#1
    b .Ldiagnostics221
.Ldiagnosticsend222:
    mov sp,x29
    add x16,sp,#3840
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
    add sp,sp,#4096
    ret
.Ldomain:
    mov w0,#116
    bl _exit
.size CUMASTRN_SYMBOL,.-CUMASTRN_SYMBOL
.section .rodata
.p2align 3
.LC0:
    .quad 0x3ff0000000000000
.LC1:
    .quad 0x0000000000000000
.LC2:
    .quad 0x4097700000000000
.LC3:
    .quad 0x3fd554c980000000
.LC4:
    .quad 0x3fb1eb851eb851ec
.LC5:
    .quad 0x3fb999999999999a
.LC6:
    .quad 0x3f847ae147ae147b
.LC7:
    .quad 0x3ddb7cdfd9d7bdbb
.LC8:
    .quad 0x40f86a0000000000
.LC9:
    .quad 0x4000000000000000
.LC10:
    .quad 0x4059000000000000
.LC11:
    .quad 0x3fe0000000000000
.LC12:
    .quad 0x3ff999999999999a
.LC13:
    .quad 0x40fe848000000000
.LC14:
    .quad 0x40bf400000000000
.LC15:
    .quad 0x4008000000000000
.LC16:
    .quad 0x402e000000000000
.LC17:
    .quad 0x40b3880000000000
.LC18:
    .quad 0x40c3880000000000
.LC19:
    .quad 0x3ff4000000000000
.LC20:
    .quad 0x3ffccccccccccccd
.LC21:
    .quad 0x3fd3333333333333
.LC22:
    .quad 0xc000000000000000
.LC23:
    .quad 0x3fee147ae0000000
.LC24:
    .quad 0xc059000000000000
.LC25:
    .quad 0x3f1a36e2eb1c432d
.LC26:
    .quad 0x4014000000000000
.LC27:
    .quad 0x40ac200000000000
.LC28:
    .quad 0x40c5180000000000
.LC29:
    .quad 0x3f50624dd2f1a9fc
.LC30:
    .quad 0x3feccccccccccccd
.LC31:
    .quad 0x3fe8000000000000
.LC32:
    .quad 0x3ff0cccccccccccd
.LC33:
    .quad 0x3fef5c28f5c28f5c
.LC34:
    .quad 0x3ff051eb851eb852
.LC35:
    .quad 0x3cd203af9ee75616
.LC36:
    .quad 0xbcd203af9ee75616
.LC37:
    .quad 0x3fa88263c0c4131e
.LC38:
    .quad 0x3fa1599cee63c346
.LC39:
    .quad 0x3febd37a6f4de9be
.LC40:
    .quad 0x3fed1745d1745d17
.LC41:
    .quad 0x4024000000000000
.LC42:
    .quad 0x3f40624dd2f1a9fc
.section .note.GNU-stack,"",%progbits
