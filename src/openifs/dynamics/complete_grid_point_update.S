/* Direct selected CPG body from OpenIFS 48.1.1.
 * Physics formulations/openifs/dynamics/complete_grid_point_update.md.
 * Contract skills/md2asm/references/openifs/dynamics/complete_grid_point_update.md.
 * Original routine names and frozen arithmetic are preserved. */
.arch armv8.2-a+simd
.text
.p2align 4
.global md2asm_cpg_7358525
.global cpg_
.set cpg_,md2asm_cpg_7358525
.type md2asm_cpg_7358525,%function
md2asm_cpg_7358525:
 mov x17,sp
 sub sp,sp,#1,lsl #12
 add x16,sp,#1344
 stp x18,x19,[x16,#0]
 stp x20,x21,[x16,#16]
 stp x22,x23,[x16,#32]
 stp x24,x25,[x16,#48]
 stp x26,x27,[x16,#64]
 stp x28,x29,[x16,#80]
 str x30,[sp,#1440]
 mov x29,sp
 str x0,[sp,#1488]
 str x1,[sp,#1496]
 str x2,[sp,#1504]
 str x3,[sp,#1512]
 str x4,[sp,#1520]
 str x5,[sp,#1528]
 str x6,[sp,#1536]
 str x7,[sp,#1544]
 ldr x9,[x17,#0]
 str x9,[sp,#1552]
 ldr x9,[x17,#8]
 str x9,[sp,#1560]
 ldr x9,[x17,#16]
 str x9,[sp,#1568]
 ldr x9,[x17,#24]
 str x9,[sp,#1576]
 ldr x9,[x17,#32]
 str x9,[sp,#1584]
 ldr x9,[x17,#40]
 str x9,[sp,#1592]
 ldr x9,[x17,#48]
 str x9,[sp,#1600]
 ldr x9,[x17,#56]
 str x9,[sp,#1608]
 ldr x9,[x17,#64]
 str x9,[sp,#1616]
 ldr x9,[x17,#72]
 str x9,[sp,#1624]
 ldr x9,[x17,#80]
 str x9,[sp,#1632]
 ldr x9,[x17,#88]
 str x9,[sp,#1640]
 ldr x9,[x17,#96]
 str x9,[sp,#1648]
 ldr x9,[x17,#104]
 str x9,[sp,#1656]
 ldr x9,[x17,#112]
 str x9,[sp,#1664]
 ldr x9,[x17,#120]
 str x9,[sp,#1672]
 ldr x9,[x17,#128]
 str x9,[sp,#1680]
 ldr x9,[x17,#136]
 str x9,[sp,#1688]
 ldr x9,[x17,#144]
 str x9,[sp,#1696]
 ldr x9,[x17,#152]
 str x9,[sp,#1704]
 ldr x9,[x17,#160]
 str x9,[sp,#1712]
 ldr x9,[x17,#168]
 str x9,[sp,#1720]
 ldr x9,[x17,#176]
 str x9,[sp,#1728]
 ldr x9,[x17,#184]
 str x9,[sp,#1736]
 ldr x9,[x17,#192]
 str x9,[sp,#1744]
 ldr x9,[x17,#200]
 str x9,[sp,#1752]
 ldr x9,[x17,#208]
 str x9,[sp,#1760]
 ldr x9,[x17,#216]
 str x9,[sp,#1768]
 ldr x9,[x17,#224]
 str x9,[sp,#1776]
 ldr x9,[x17,#232]
 str x9,[sp,#1784]
 ldr x9,[x17,#240]
 str x9,[sp,#1792]
 ldr x9,[x17,#248]
 str x9,[sp,#1800]
 ldr x9,[x17,#256]
 str x9,[sp,#1808]
 ldr x9,[x17,#264]
 str x9,[sp,#1816]
 ldr x9,[x17,#272]
 str x9,[sp,#1824]
 ldr x9,[x17,#280]
 str x9,[sp,#1832]
 ldr x9,[x17,#288]
 str x9,[sp,#1840]
 ldr x9,[x17,#296]
 str x9,[sp,#1848]
 ldr x9,[x17,#304]
 str x9,[sp,#1856]
 ldr x9,[x17,#312]
 str x9,[sp,#1864]
 ldr x9,[x17,#320]
 str x9,[sp,#1872]
 ldr x9,[x17,#328]
 str x9,[sp,#1880]
 ldr x9,[x17,#336]
 str x9,[sp,#1888]
 ldr x9,[x17,#344]
 str x9,[sp,#1896]
 ldr x9,[x17,#352]
 str x9,[sp,#1904]
 ldr x9,[x17,#360]
 str x9,[sp,#1912]
 ldr x9,[x17,#368]
 str x9,[sp,#1920]
 ldr x9,[x17,#376]
 str x9,[sp,#1928]
 ldr x9,[x17,#384]
 str x9,[sp,#1936]
 ldr x9,[x17,#392]
 str x9,[sp,#1944]
 ldr x9,[x17,#400]
 str x9,[sp,#1952]
 ldr x9,[x17,#408]
 str x9,[sp,#1960]
 ldr x9,[x17,#416]
 str x9,[sp,#1968]
 ldr x9,[x17,#424]
 str x9,[sp,#1976]
 ldr x9,[x17,#432]
 str x9,[sp,#1984]
 ldr x9,[x17,#440]
 str x9,[sp,#1992]
 ldr x9,[x17,#448]
 str x9,[sp,#2000]
 ldr x9,[x17,#456]
 str x9,[sp,#2008]
 ldr x9,[x17,#464]
 str x9,[sp,#2016]
 ldr x9,[x17,#472]
 str x9,[sp,#2024]
 ldr x9,[x17,#480]
 str x9,[sp,#2032]
 ldr x9,[x17,#488]
 str x9,[sp,#2040]
 ldr x9,[x17,#496]
 str x9,[sp,#2048]
 ldr x9,[x17,#504]
 str x9,[sp,#2056]
 ldr x9,[x17,#512]
 str x9,[sp,#2064]
 ldr x9,[x17,#520]
 str x9,[sp,#2072]
 ldr x9,[x17,#528]
 str x9,[sp,#2080]
 ldr x9,[x17,#536]
 str x9,[sp,#2088]
 ldr x9,[x17,#544]
 str x9,[sp,#2096]
 ldr x9,[x17,#552]
 str x9,[sp,#2104]
 ldr x9,[x17,#560]
 str x9,[sp,#2112]
 ldr x9,[x17,#568]
 str x9,[sp,#2120]
 ldr x9,[x17,#576]
 str x9,[sp,#2128]
 ldr x9,[x17,#584]
 str x9,[sp,#2136]
 ldr x9,[x17,#592]
 str x9,[sp,#2144]
 ldr x9,[x17,#600]
 str x9,[sp,#2152]
 ldr x9,[x17,#608]
 str x9,[sp,#2160]
 mrs x9,fpcr
 cbnz x9,.Lreject
 ldr x9,[x29,#1488]
 movz x16,#5144
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#24
 b.ne .Lreject
 ldr x9,[x29,#1488]
 movz x16,#5148
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#24
 b.ne .Lreject
 ldr x9,[x29,#1488]
 movz x16,#5156
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lreject
 ldr x9,[x29,#1488]
 movz x16,#5224
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#19
 b.ne .Lreject
 ldr x9,[x29,#1488]
 movz x16,#7376
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#2048
 b.ne .Lreject
 ldr x9,[x29,#1496]
 movz x16,#57016
 movk x16,#23,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 ldr x9,[x29,#1496]
 movz x16,#57024
 movk x16,#23,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 ldr x9,[x29,#1496]
 movz x16,#57144
 movk x16,#23,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 ldr x9,[x29,#1496]
 movz x16,#57148
 movk x16,#23,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 ldr x9,[x29,#1496]
 movz x16,#59840
 movk x16,#23,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 ldr x9,[x29,#1496]
 movz x16,#59844
 movk x16,#23,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 ldr x9,[x29,#1496]
 movz x16,#14760
 movk x16,#24,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 ldr x9,[x29,#1496]
 movz x16,#61568
 movk x16,#23,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 ldr x9,[x29,#1496]
 movz x16,#38608
 movk x16,#64,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 ldr x9,[x29,#1496]
 movz x16,#38612
 movk x16,#64,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 ldr x9,[x29,#1496]
 movz x16,#12720
 movk x16,#65,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 ldr x9,[x29,#1496]
 movz x16,#24172
 movk x16,#64,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 ldr x9,[x29,#1496]
 movz x16,#152
 movk x16,#24,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#463
 b.ne .Lreject
 ldr x9,[x29,#1496]
 movz x16,#364
 movk x16,#24,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#359
 b.ne .Lreject
 ldr x9,[x29,#1496]
 movz x16,#368
 movk x16,#24,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#380
 b.ne .Lreject
 ldr x9,[x29,#1496]
 movz x16,#376
 movk x16,#24,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#401
 b.ne .Lreject
 ldr x9,[x29,#1496]
 movz x16,#380
 movk x16,#24,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#422
 b.ne .Lreject
 ldr x9,[x29,#1496]
 movz x16,#496
 movk x16,#24,lsl #16
 add x9,x9,x16
 ldr w10,[x9]
 cmp w10,#59
 b.ne .Lreject
 ldr x9,[x29,#1536]
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 ldr x9,[x29,#1544]
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lreject
 ldr x9,[x29,#1552]
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lreject
 ldr x9,[x29,#1560]
 ldr w10,[x9]
 cmp w10,#2048
 b.ne .Lreject
 adrp x9,:got:__intdyn_mod_MOD_yytxyb0
 ldr x9,[x9,:got_lo12:__intdyn_mod_MOD_yytxyb0]
 ldr w10,[x9,#4]
 cmp w10,#2
 b.ne .Lreject
 adrp x9,:got:__intdyn_mod_MOD_yytxyb0
 ldr x9,[x9,:got_lo12:__intdyn_mod_MOD_yytxyb0]
 ldr w10,[x9,#28]
 cmp w10,#7
 b.ne .Lreject
 adrp x9,:got:__intdyn_mod_MOD_yytxyb9
 ldr x9,[x9,:got_lo12:__intdyn_mod_MOD_yytxyb9]
 ldr w10,[x9,#28]
 cmp w10,#7
 b.ne .Lreject
 adrp x9,:got:__intdyn_mod_MOD_yythw0
 ldr x9,[x9,:got_lo12:__intdyn_mod_MOD_yythw0]
 ldr w10,[x9,#12]
 cmp w10,#3
 b.ne .Lreject
 adrp x9,:got:__intdyn_mod_MOD_yytrcp9
 ldr x9,[x9,:got_lo12:__intdyn_mod_MOD_yytrcp9]
 ldr w10,[x9,#12]
 cmp w10,#3
 b.ne .Lreject
 ldr x9,[x29,#1568]
 ldrsw x21,[x9]
 cmp x21,#1
 b.lt .Lreject
 cmp x21,#2048
 b.gt .Lreject
 sub x9,x21,#1
 mov x10,#24
 sdiv x11,x9,x10
 msub x12,x11,x10,x9
 cbnz x12,.Lreject
 add w11,w11,#1
 str w11,[x29,#2192]
 mov x9,#2049
 sub x22,x9,x21
 mov x9,#24
 cmp x22,x9
 csel x22,x22,x9,lt
 str w22,[x29,#2180]
 str w22,[x29,#2188]
 mov w9,#1
 str w9,[x29,#2176]
 str w9,[x29,#2184]
 ldr x9,[x29,#1616]
 ldrsw x25,[x9,#1016]
 cmp x25,#1
 b.lt .Lreject
 add x9,x9,#1456
 ldr x23,[x9]
 cbz x23,.Lreject
 ldr x10,[x9,#8]
 ldr x24,[x9,#40]
 ldr x11,[x9,#48]
 cmp x11,x21
 b.gt .Lreject
 ldr x11,[x9,#56]
 add x12,x21,x22
 sub x12,x12,#1
 cmp x11,x12
 b.lt .Lreject
 madd x10,x21,x24,x10
 add x23,x23,x10,lsl #2
 lsl x24,x24,#2
 mov x9,#0
.Lmap_bounds:
 mul x10,x9,x24
 ldrsw x11,[x23,x10]
 cmp x11,#1
 b.lt .Lreject
 cmp x11,x25
 b.gt .Lreject
 add x9,x9,#1
 cmp x9,x22
 b.lo .Lmap_bounds
 ldr x9,[x29,#1496]
 movz x16,#58544
 movk x16,#23,lsl #16
 add x9,x9,x16
 ldr x10,[x9]
 cbz x10,.Lreject
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 madd x11,x21,x12,x11
 add x10,x10,x11,lsl #3
 str x10,[x29,#2280]
 ldr x9,[x29,#1496]
 movz x16,#58640
 movk x16,#23,lsl #16
 add x9,x9,x16
 ldr x10,[x9]
 cbz x10,.Lreject
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 madd x11,x21,x12,x11
 add x10,x10,x11,lsl #3
 str x10,[x29,#2288]
 ldr x9,[x29,#1488]
 movz x16,#8472
 add x9,x9,x16
 ldr x10,[x9]
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#16]
 ldr x14,[x29,#1576]
 ldrsw x14,[x14]
 madd x11,x12,x14,x11
 madd x9,x11,x13,x10
 movz x16,#704
 add x9,x9,x16
 ldr x10,[x9]
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
 str x10,[x29,#2344]
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 str w9,[x29,#2216]
 ldr w9,[x29,#2216]
 cbz w9,.Lprofile0
 adrp x0,.Lname
 add x0,x0,:lo12:.Lname
 mov w9,#0
 str w9,[x29,#2220]
 add x1,x29,#2220
 add x2,x29,#2208
 mov x3,#3
 bl __yomhook_MOD_dr_hook_default8
.Lprofile0:
 movz x0,#38864
 movk x0,#3,lsl #16
 bl malloc
 cbz x0,.Lreject
 mov x27,x0
 ldr x26,[x29,#1672]
 movz x0,#3648
 bl malloc
 cbz x0,.Lreject
 str x0,[x29,#2240]
 str x0,[x26,#352]
 adrp x10,.Lmeta_RT0L
 add x10,x10,:lo12:.Lmeta_RT0L
 ldr x9,[x10,#0]
 str x9,[x26,#360]
 ldr x9,[x10,#8]
 str x9,[x26,#368]
 ldr x9,[x10,#16]
 str x9,[x26,#376]
 ldr x9,[x10,#24]
 str x9,[x26,#384]
 ldr x9,[x10,#32]
 str x9,[x26,#392]
 ldr x9,[x10,#40]
 str x9,[x26,#400]
 ldr x9,[x10,#48]
 str x9,[x26,#408]
 ldr x9,[x10,#56]
 str x9,[x26,#416]
 ldr x9,[x10,#64]
 str x9,[x26,#424]
 ldr x9,[x10,#72]
 str x9,[x26,#432]
 movz x0,#3648
 bl malloc
 cbz x0,.Lreject
 str x0,[x29,#2248]
 str x0,[x26,#440]
 adrp x10,.Lmeta_RT0M
 add x10,x10,:lo12:.Lmeta_RT0M
 ldr x9,[x10,#0]
 str x9,[x26,#448]
 ldr x9,[x10,#8]
 str x9,[x26,#456]
 ldr x9,[x10,#16]
 str x9,[x26,#464]
 ldr x9,[x10,#24]
 str x9,[x26,#472]
 ldr x9,[x10,#32]
 str x9,[x26,#480]
 ldr x9,[x10,#40]
 str x9,[x26,#488]
 ldr x9,[x10,#48]
 str x9,[x26,#496]
 ldr x9,[x10,#56]
 str x9,[x26,#504]
 ldr x9,[x10,#64]
 str x9,[x26,#512]
 ldr x9,[x10,#72]
 str x9,[x26,#520]
 movz x0,#3648
 bl malloc
 cbz x0,.Lreject
 str x0,[x29,#2256]
 str x0,[x26,#88]
 adrp x10,.Lmeta_PHI0FL
 add x10,x10,:lo12:.Lmeta_PHI0FL
 ldr x9,[x10,#0]
 str x9,[x26,#96]
 ldr x9,[x10,#8]
 str x9,[x26,#104]
 ldr x9,[x10,#16]
 str x9,[x26,#112]
 ldr x9,[x10,#24]
 str x9,[x26,#120]
 ldr x9,[x10,#32]
 str x9,[x26,#128]
 ldr x9,[x10,#40]
 str x9,[x26,#136]
 ldr x9,[x10,#48]
 str x9,[x26,#144]
 ldr x9,[x10,#56]
 str x9,[x26,#152]
 ldr x9,[x10,#64]
 str x9,[x26,#160]
 ldr x9,[x10,#72]
 str x9,[x26,#168]
 movz x0,#3648
 bl malloc
 cbz x0,.Lreject
 str x0,[x29,#2264]
 str x0,[x26,#176]
 adrp x10,.Lmeta_PHI0FM
 add x10,x10,:lo12:.Lmeta_PHI0FM
 ldr x9,[x10,#0]
 str x9,[x26,#184]
 ldr x9,[x10,#8]
 str x9,[x26,#192]
 ldr x9,[x10,#16]
 str x9,[x26,#200]
 ldr x9,[x10,#24]
 str x9,[x26,#208]
 ldr x9,[x10,#32]
 str x9,[x26,#216]
 ldr x9,[x10,#40]
 str x9,[x26,#224]
 ldr x9,[x10,#48]
 str x9,[x26,#232]
 ldr x9,[x10,#56]
 str x9,[x26,#240]
 ldr x9,[x10,#64]
 str x9,[x26,#248]
 ldr x9,[x10,#72]
 str x9,[x26,#256]
 movz x0,#3840
 bl malloc
 cbz x0,.Lreject
 str x0,[x29,#2272]
 str x0,[x26,#528]
 adrp x10,.Lmeta_PHI0H
 add x10,x10,:lo12:.Lmeta_PHI0H
 ldr x9,[x10,#0]
 str x9,[x26,#536]
 ldr x9,[x10,#8]
 str x9,[x26,#544]
 ldr x9,[x10,#16]
 str x9,[x26,#552]
 ldr x9,[x10,#24]
 str x9,[x26,#560]
 ldr x9,[x10,#32]
 str x9,[x26,#568]
 ldr x9,[x10,#40]
 str x9,[x26,#576]
 ldr x9,[x10,#48]
 str x9,[x26,#584]
 ldr x9,[x10,#56]
 str x9,[x26,#592]
 ldr x9,[x10,#64]
 str x9,[x26,#600]
 ldr x9,[x10,#72]
 str x9,[x26,#608]
 movz x9,#39168
 movk x9,#1,lsl #16
 add x9,x27,x9
 mov x10,#24
.Lzero_parameters:
 str xzr,[x9],#8
 subs x10,x10,#1
 b.ne .Lzero_parameters
 ldr x0,[x29,#1488]
 ldr x1,[x29,#1496]
 ldr x2,[x29,#1504]
 ldr x3,[x29,#1520]
 add x4,x29,#2176
 add x5,x29,#2180
 add x6,x29,#2184
 add x7,x29,#2188
 add x9,x29,#2192
 str x9,[sp,#0]
 ldr x9,[x29,#1568]
 str x9,[sp,#8]
 ldr x9,[x29,#1528]
 str x9,[sp,#16]
 ldr x9,[x29,#1536]
 str x9,[sp,#24]
 ldr x9,[x29,#1584]
 str x9,[sp,#32]
 ldr x9,[x29,#1600]
 str x9,[sp,#40]
 ldr x9,[x29,#1576]
 str x9,[sp,#48]
 ldr x9,[x29,#1672]
 str x9,[sp,#56]
 ldr x9,[x29,#1696]
 str x9,[sp,#64]
 ldr x9,[x29,#1680]
 str x9,[sp,#72]
 ldr x9,[x29,#1688]
 str x9,[sp,#80]
 ldr x9,[x29,#1736]
 str x9,[sp,#88]
 ldr x9,[x29,#1720]
 str x9,[sp,#96]
 ldr x9,[x29,#1728]
 str x9,[sp,#104]
 ldr x9,[x29,#1752]
 str x9,[sp,#112]
 ldr x9,[x29,#1768]
 str x9,[sp,#120]
 ldr x9,[x29,#2080]
 str x9,[sp,#128]
 ldr x9,[x29,#2088]
 str x9,[sp,#136]
 movz x9,#0
 add x9,x27,x9
 str x9,[sp,#144]
 movz x9,#192
 add x9,x27,x9
 str x9,[sp,#152]
 movz x9,#384
 add x9,x27,x9
 str x9,[sp,#160]
 movz x9,#4224
 add x9,x27,x9
 str x9,[sp,#168]
 movz x9,#4416
 add x9,x27,x9
 str x9,[sp,#176]
 ldr x9,[x29,#2136]
 str x9,[sp,#184]
 movz x9,#4608
 add x9,x27,x9
 str x9,[sp,#192]
 movz x9,#4768
 add x9,x27,x9
 str x9,[sp,#200]
 movz x9,#4928
 add x9,x27,x9
 str x9,[sp,#208]
 movz x9,#30464
 add x9,x27,x9
 str x9,[sp,#216]
 ldr x9,[x29,#2120]
 str x9,[sp,#224]
 ldr x9,[x29,#2128]
 str x9,[sp,#232]
 ldr x9,[x29,#2144]
 str x9,[sp,#240]
 movz x9,#41984
 add x9,x27,x9
 str x9,[sp,#248]
 movz x9,#45632
 add x9,x27,x9
 str x9,[sp,#256]
 movz x9,#49280
 add x9,x27,x9
 str x9,[sp,#264]
 movz x9,#53120
 add x9,x27,x9
 str x9,[sp,#272]
 movz x9,#56768
 add x9,x27,x9
 str x9,[sp,#280]
 movz x9,#56928
 add x9,x27,x9
 str x9,[sp,#288]
 movz x9,#57088
 add x9,x27,x9
 str x9,[sp,#296]
 movz x9,#17088
 movk x9,#1,lsl #16
 add x9,x27,x9
 str x9,[sp,#304]
 movz x9,#20928
 movk x9,#1,lsl #16
 add x9,x27,x9
 str x9,[sp,#312]
 movz x9,#24576
 movk x9,#1,lsl #16
 add x9,x27,x9
 str x9,[sp,#320]
 movz x9,#35520
 movk x9,#1,lsl #16
 add x9,x27,x9
 str x9,[sp,#328]
 movz x9,#39168
 movk x9,#1,lsl #16
 add x9,x27,x9
 str x9,[sp,#336]
 ldr x9,[x29,#2040]
 str x9,[sp,#344]
 ldr x9,[x29,#2048]
 str x9,[sp,#352]
 ldr x9,[x29,#2056]
 str x9,[sp,#360]
 ldr x9,[x29,#2064]
 str x9,[sp,#368]
 movz x9,#39360
 movk x9,#1,lsl #16
 add x9,x27,x9
 str x9,[sp,#376]
 movz x9,#39552
 movk x9,#1,lsl #16
 add x9,x27,x9
 str x9,[sp,#384]
 movz x9,#39744
 movk x9,#1,lsl #16
 add x9,x27,x9
 str x9,[sp,#392]
 movz x9,#43392
 movk x9,#1,lsl #16
 add x9,x27,x9
 str x9,[sp,#400]
 movz x9,#47040
 movk x9,#1,lsl #16
 add x9,x27,x9
 str x9,[sp,#408]
 movz x9,#50688
 movk x9,#1,lsl #16
 add x9,x27,x9
 str x9,[sp,#416]
 movz x9,#54336
 movk x9,#1,lsl #16
 add x9,x27,x9
 str x9,[sp,#424]
 movz x9,#7040
 movk x9,#2,lsl #16
 add x9,x27,x9
 str x9,[sp,#432]
 movz x9,#7056
 movk x9,#2,lsl #16
 add x9,x27,x9
 str x9,[sp,#440]
 movz x9,#7216
 movk x9,#2,lsl #16
 add x9,x27,x9
 str x9,[sp,#448]
 movz x9,#7376
 movk x9,#2,lsl #16
 add x9,x27,x9
 str x9,[sp,#456]
 movz x9,#7536
 movk x9,#2,lsl #16
 add x9,x27,x9
 str x9,[sp,#464]
 movz x9,#7552
 movk x9,#2,lsl #16
 add x9,x27,x9
 str x9,[sp,#472]
 movz x9,#7712
 movk x9,#2,lsl #16
 add x9,x27,x9
 str x9,[sp,#480]
 movz x9,#7872
 movk x9,#2,lsl #16
 add x9,x27,x9
 str x9,[sp,#488]
 movz x9,#11520
 movk x9,#2,lsl #16
 add x9,x27,x9
 str x9,[sp,#496]
 movz x9,#15168
 movk x9,#2,lsl #16
 add x9,x27,x9
 str x9,[sp,#504]
 movz x9,#15328
 movk x9,#2,lsl #16
 add x9,x27,x9
 str x9,[sp,#512]
 ldr x9,[x29,#2072]
 str x9,[sp,#520]
 ldr x9,[x29,#2112]
 str x9,[sp,#528]
 bl md2asm_forecast_grid_7259755
 adrp x16,.Lcounts
 add x16,x16,:lo12:.Lcounts
 ldr x17,[x16,#8]
 add x17,x17,#1
 str x17,[x16,#8]
 movz x19,#15488
 movk x19,#2,lsl #16
 add x19,x27,x19
 mov x10,#463
.Lzero_field:
 mov x11,x19
 mov x12,x22
.Lzero_row:
 str xzr,[x11],#8
 subs x12,x12,#1
 b.ne .Lzero_row
 add x19,x19,#192
 subs x10,x10,#1
 b.ne .Lzero_field
 ldr x0,[x29,#1488]
 ldr x1,[x29,#1496]
 movz x16,#4592
 movk x16,#24,lsl #16
 add x1,x1,x16
 ldr x2,[x29,#1496]
 add x2,x2,#8
 ldr x3,[x29,#1496]
 movz x16,#21240
 movk x16,#63,lsl #16
 add x3,x3,x16
 add x4,x29,#2176
 add x5,x29,#2180
 ldr x6,[x29,#1528]
 ldr x7,[x29,#1592]
 movz x9,#15488
 movk x9,#2,lsl #16
 add x9,x27,x9
 movz x16,#3200
 movk x16,#1,lsl #16
 add x9,x9,x16
 str x9,[sp,#0]
 movz x9,#15488
 movk x9,#2,lsl #16
 add x9,x27,x9
 movz x16,#7232
 movk x16,#1,lsl #16
 add x9,x9,x16
 str x9,[sp,#8]
 movz x9,#15488
 movk x9,#2,lsl #16
 add x9,x27,x9
 movz x16,#11264
 movk x16,#1,lsl #16
 add x9,x9,x16
 str x9,[sp,#16]
 movz x9,#15488
 movk x9,#2,lsl #16
 add x9,x27,x9
 movz x16,#15296
 movk x16,#1,lsl #16
 add x9,x9,x16
 str x9,[sp,#24]
 ldr x9,[x29,#1632]
 str x9,[sp,#32]
 ldr x9,[x29,#1624]
 str x9,[sp,#40]
 bl md2asm_ec_phys_lslphy
 adrp x16,.Lcounts
 add x16,x16,:lo12:.Lcounts
 ldr x17,[x16,#16]
 add x17,x17,#1
 str x17,[x16,#16]
 ldr x0,[x29,#1488]
 ldr x1,[x29,#1504]
 add x1,x1,#1856
 ldr x2,[x29,#1504]
 movz x16,#4512
 add x2,x2,x16
 ldr x3,[x29,#1504]
 movz x16,#35304
 add x3,x3,x16
 ldr x4,[x29,#1504]
 movz x16,#968
 movk x16,#3,lsl #16
 add x4,x4,x16
 ldr x5,[x29,#1496]
 add x6,x29,#2176
 add x7,x29,#2180
 add x9,x29,#2184
 str x9,[sp,#0]
 add x9,x29,#2188
 str x9,[sp,#8]
 ldr x9,[x29,#1568]
 str x9,[sp,#16]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#24]
 ldr x9,[x29,#1512]
 str x9,[sp,#32]
 ldr x9,[x29,#1536]
 str x9,[sp,#40]
 ldr x9,[x29,#1528]
 str x9,[sp,#48]
 ldr x9,[x29,#1520]
 str x9,[sp,#56]
 ldr x9,[x29,#1576]
 str x9,[sp,#64]
 movz x9,#0
 add x9,x27,x9
 str x9,[sp,#72]
 movz x9,#192
 add x9,x27,x9
 str x9,[sp,#80]
 ldr x9,[x29,#1680]
 str x9,[sp,#88]
 ldr x9,[x29,#1696]
 str x9,[sp,#96]
 movz x9,#384
 add x9,x27,x9
 str x9,[sp,#104]
 ldr x9,[x29,#2136]
 str x9,[sp,#112]
 movz x9,#4928
 add x9,x27,x9
 str x9,[sp,#120]
 ldr x9,[x29,#1672]
 ldr x9,[x9,#528]
 str x9,[sp,#128]
 ldr x9,[x29,#2120]
 str x9,[sp,#136]
 ldr x9,[x29,#1672]
 ldr x9,[x9,#88]
 str x9,[sp,#144]
 ldr x9,[x29,#1672]
 ldr x9,[x9,#176]
 str x9,[sp,#152]
 ldr x9,[x29,#2128]
 str x9,[sp,#160]
 ldr x9,[x29,#2144]
 str x9,[sp,#168]
 ldr x9,[x29,#2040]
 movz x16,#11136
 add x9,x9,x16
 str x9,[sp,#176]
 movz x9,#45632
 add x9,x27,x9
 str x9,[sp,#184]
 ldr x9,[x29,#1672]
 ldr x9,[x9,#352]
 str x9,[sp,#192]
 ldr x9,[x29,#1672]
 ldr x9,[x9,#440]
 str x9,[sp,#200]
 movz x9,#4224
 add x9,x27,x9
 str x9,[sp,#208]
 movz x9,#4416
 add x9,x27,x9
 str x9,[sp,#216]
 movz x9,#4608
 add x9,x27,x9
 str x9,[sp,#224]
 movz x9,#4768
 add x9,x27,x9
 str x9,[sp,#232]
 movz x9,#15168
 movk x9,#2,lsl #16
 add x9,x27,x9
 str x9,[sp,#240]
 movz x9,#15328
 movk x9,#2,lsl #16
 add x9,x27,x9
 str x9,[sp,#248]
 ldr x9,[x29,#1752]
 str x9,[sp,#256]
 ldr x9,[x29,#1728]
 str x9,[sp,#264]
 ldr x9,[x29,#1720]
 str x9,[sp,#272]
 ldr x9,[x29,#1736]
 str x9,[sp,#280]
 ldr x9,[x29,#1848]
 str x9,[sp,#288]
 ldr x9,[x29,#1856]
 str x9,[sp,#296]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#304]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#312]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#320]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#328]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#336]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#344]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#352]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#360]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#368]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#376]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#384]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#392]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#400]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#408]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#416]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#424]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#432]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#440]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#448]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#456]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#464]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#472]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#480]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#488]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#496]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#504]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#512]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#520]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#528]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#536]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#544]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#552]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#560]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#568]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#576]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#584]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#592]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#600]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#608]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#616]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#624]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#632]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#640]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#648]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#656]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#664]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#672]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#680]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#688]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#696]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#704]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#712]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#720]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#728]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#736]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#744]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#752]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#760]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#768]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#776]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#784]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#792]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#800]
 movz x9,#39744
 movk x9,#1,lsl #16
 add x9,x27,x9
 str x9,[sp,#808]
 movz x9,#43392
 movk x9,#1,lsl #16
 add x9,x27,x9
 str x9,[sp,#816]
 movz x9,#47040
 movk x9,#1,lsl #16
 add x9,x27,x9
 str x9,[sp,#824]
 movz x9,#50688
 movk x9,#1,lsl #16
 add x9,x27,x9
 str x9,[sp,#832]
 movz x9,#39552
 movk x9,#1,lsl #16
 add x9,x27,x9
 str x9,[sp,#840]
 ldr x9,[x29,#1832]
 str x9,[sp,#848]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#856]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#864]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#872]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#880]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#888]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#896]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#904]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#912]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#920]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#928]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#936]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#944]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#952]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#960]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#968]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#976]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#984]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#992]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1000]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1008]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1016]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1024]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1032]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1040]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1048]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1056]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1064]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1072]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1080]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1088]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1096]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1104]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1112]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1120]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1128]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1136]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1144]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1152]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1160]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1168]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1176]
 movz x9,#39168
 movk x9,#1,lsl #16
 add x9,x27,x9
 str x9,[sp,#1184]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1192]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1200]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1208]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1216]
 ldr x9,[x29,#1664]
 str x9,[sp,#1224]
 ldr x9,[x29,#1896]
 str x9,[sp,#1232]
 ldr x9,[x29,#1640]
 str x9,[sp,#1240]
 ldr x9,[x29,#1648]
 str x9,[sp,#1248]
 movz x9,#54336
 movk x9,#1,lsl #16
 add x9,x27,x9
 str x9,[sp,#1256]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1264]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1272]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1280]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1288]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1296]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1304]
 ldr x9,[x29,#2112]
 str x9,[sp,#1312]
 ldr x9,[x29,#1744]
 str x9,[sp,#1320]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#1328]
 bl md2asm_cpg_dia_7358525
 adrp x16,.Lcounts
 add x16,x16,:lo12:.Lcounts
 ldr x17,[x16,#24]
 add x17,x17,#1
 str x17,[x16,#24]
 ldr x0,[x29,#1488]
 ldr x1,[x29,#1504]
 add x1,x1,#1856
 ldr x2,[x29,#1496]
 add x3,x29,#2176
 add x4,x29,#2180
 ldr x5,[x29,#1608]
 ldr x6,[x29,#1584]
 ldr x7,[x29,#2280]
 ldr x9,[x29,#2288]
 str x9,[sp,#0]
 ldr x9,[x29,#1576]
 str x9,[sp,#8]
 movz x9,#0
 add x9,x27,x9
 str x9,[sp,#16]
 movz x9,#192
 add x9,x27,x9
 str x9,[sp,#24]
 movz x9,#384
 add x9,x27,x9
 str x9,[sp,#32]
 movz x9,#4928
 add x9,x27,x9
 add x9,x9,#3648
 str x9,[sp,#40]
 movz x9,#30464
 add x9,x27,x9
 str x9,[sp,#48]
 ldr x9,[x29,#1672]
 ldr x9,[x9,#528]
 str x9,[sp,#56]
 ldr x9,[x29,#2120]
 str x9,[sp,#64]
 ldr x9,[x29,#2128]
 str x9,[sp,#72]
 ldr x9,[x29,#2144]
 str x9,[sp,#80]
 movz x9,#45632
 add x9,x27,x9
 str x9,[sp,#88]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#96]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#104]
 movz x9,#38848
 movk x9,#3,lsl #16
 add x9,x27,x9
 str x9,[sp,#112]
 movz x9,#54336
 movk x9,#1,lsl #16
 add x9,x27,x9
 str x9,[sp,#120]
 movz x9,#7040
 movk x9,#2,lsl #16
 add x9,x27,x9
 str x9,[sp,#128]
 movz x9,#7056
 movk x9,#2,lsl #16
 add x9,x27,x9
 str x9,[sp,#136]
 movz x9,#7216
 movk x9,#2,lsl #16
 add x9,x27,x9
 str x9,[sp,#144]
 movz x9,#41984
 add x9,x27,x9
 str x9,[sp,#152]
 movz x9,#7376
 movk x9,#2,lsl #16
 add x9,x27,x9
 str x9,[sp,#160]
 movz x9,#7872
 movk x9,#2,lsl #16
 add x9,x27,x9
 str x9,[sp,#168]
 movz x9,#11520
 movk x9,#2,lsl #16
 add x9,x27,x9
 str x9,[sp,#176]
 ldr x9,[x29,#1696]
 str x9,[sp,#184]
 ldr x9,[x29,#2024]
 str x9,[sp,#192]
 ldr x9,[x29,#1704]
 str x9,[sp,#200]
 movz x9,#7536
 movk x9,#2,lsl #16
 add x9,x27,x9
 str x9,[sp,#208]
 ldr x9,[x29,#1680]
 str x9,[sp,#216]
 ldr x9,[x29,#1688]
 str x9,[sp,#224]
 movz x9,#15488
 movk x9,#2,lsl #16
 add x9,x27,x9
 str x9,[sp,#232]
 ldr x9,[x29,#2040]
 str x9,[sp,#240]
 ldr x9,[x29,#2048]
 str x9,[sp,#248]
 ldr x9,[x29,#2056]
 str x9,[sp,#256]
 ldr x9,[x29,#2064]
 str x9,[sp,#264]
 ldr x9,[x29,#1896]
 str x9,[sp,#272]
 ldr x9,[x29,#2152]
 str x9,[sp,#280]
 ldr x9,[x29,#2160]
 str x9,[sp,#288]
 ldr x9,[x29,#2104]
 str x9,[sp,#296]
 bl md2asm_cpg_dyn_7358525
 adrp x16,.Lcounts
 add x16,x16,:lo12:.Lcounts
 ldr x17,[x16,#32]
 add x17,x17,#1
 str x17,[x16,#32]
 movz x19,#15488
 movk x19,#2,lsl #16
 add x19,x27,x19
 ldr x20,[x29,#2032]
 mov x28,#0
.Lscatter_field:
 mov x10,#0
.Lscatter_row:
 mul x11,x10,x24
 ldrsw x12,[x23,x11]
 sub x12,x12,#1
 madd x12,x28,x25,x12
 ldr x13,[x19,x10,lsl #3]
 str x13,[x20,x12,lsl #3]
 add x10,x10,#1
 cmp x10,x22
 b.lo .Lscatter_row
 add x19,x19,#192
 add x28,x28,#1
 cmp x28,#463
 b.lo .Lscatter_field
 ldr x0,[x29,#1488]
 ldr x1,[x29,#1504]
 add x1,x1,#1856
 ldr x2,[x29,#1504]
 movz x16,#4512
 add x2,x2,x16
 ldr x3,[x29,#1496]
 movz x16,#5024
 movk x16,#24,lsl #16
 add x3,x3,x16
 ldr x4,[x29,#1496]
 add x4,x4,#8
 ldr x5,[x29,#1496]
 movz x16,#57264
 movk x16,#23,lsl #16
 add x5,x5,x16
 ldr x6,[x29,#1496]
 movz x16,#56808
 movk x16,#23,lsl #16
 add x6,x6,x16
 ldr x7,[x29,#1496]
 movz x16,#14992
 movk x16,#63,lsl #16
 add x7,x7,x16
 ldr x9,[x29,#1496]
 movz x16,#12720
 movk x16,#65,lsl #16
 add x9,x9,x16
 str x9,[sp,#0]
 add x9,x29,#2176
 str x9,[sp,#8]
 add x9,x29,#2180
 str x9,[sp,#16]
 add x9,x29,#2184
 str x9,[sp,#24]
 add x9,x29,#2188
 str x9,[sp,#32]
 add x9,x29,#2192
 str x9,[sp,#40]
 ldr x9,[x29,#1568]
 str x9,[sp,#48]
 ldr x9,[x29,#1512]
 str x9,[sp,#56]
 ldr x9,[x29,#1536]
 str x9,[sp,#64]
 ldr x9,[x29,#2344]
 str x9,[sp,#72]
 movz x9,#39552
 movk x9,#1,lsl #16
 add x9,x27,x9
 str x9,[sp,#80]
 ldr x9,[x29,#1736]
 str x9,[sp,#88]
 ldr x9,[x29,#1728]
 str x9,[sp,#96]
 ldr x9,[x29,#1744]
 str x9,[sp,#104]
 ldr x9,[x29,#1696]
 str x9,[sp,#112]
 movz x9,#39168
 movk x9,#1,lsl #16
 add x9,x27,x9
 str x9,[sp,#120]
 ldr x9,[x29,#1680]
 str x9,[sp,#128]
 ldr x9,[x29,#1688]
 str x9,[sp,#136]
 ldr x9,[x29,#2096]
 str x9,[sp,#144]
 bl md2asm_cpg_end_7358525
 adrp x16,.Lcounts
 add x16,x16,:lo12:.Lcounts
 ldr x17,[x16,#40]
 add x17,x17,#1
 str x17,[x16,#40]
 ldr x0,[x29,#2240]
 bl free
 str xzr,[x26,#352]
 ldr x0,[x29,#2248]
 bl free
 str xzr,[x26,#440]
 ldr x0,[x29,#2256]
 bl free
 str xzr,[x26,#88]
 ldr x0,[x29,#2264]
 bl free
 str xzr,[x26,#176]
 ldr x0,[x29,#2272]
 bl free
 str xzr,[x26,#528]
 adrp x16,.Lcounts
 add x16,x16,:lo12:.Lcounts
 ldr x17,[x16,#0]
 add x17,x17,#1
 str x17,[x16,#0]
 ldr w9,[x29,#2216]
 cbz w9,.Lprofile1
 adrp x0,.Lname
 add x0,x0,:lo12:.Lname
 mov w9,#1
 str w9,[x29,#2220]
 add x1,x29,#2220
 add x2,x29,#2208
 mov x3,#3
 bl __yomhook_MOD_dr_hook_default8
.Lprofile1:
 mov x0,x27
 bl free
 add x16,sp,#1344
 ldp x18,x19,[x16,#0]
 ldp x20,x21,[x16,#16]
 ldp x22,x23,[x16,#32]
 ldp x24,x25,[x16,#48]
 ldp x26,x27,[x16,#64]
 ldp x28,x29,[x16,#80]
 ldr x30,[sp,#1440]
 add sp,sp,#1,lsl #12
 ret
.Lreject:
 bl abort
 brk #0
.size md2asm_cpg_7358525,.-md2asm_cpg_7358525
.global md2asm_cpg_stage_count_get
.type md2asm_cpg_stage_count_get,%function
md2asm_cpg_stage_count_get:
 cmp w0,#5
 b.hi .Lcount_zero
 adrp x9,.Lcounts
 add x9,x9,:lo12:.Lcounts
 ldr x0,[x9,x0,lsl #3]
 ret
.Lcount_zero:
 mov x0,#0
 ret
.section .rodata
.Lname: .ascii "CPG"
.p2align 3
.Lmeta_RT0L: .quad -25,8,3307124817920,8,1,1,24,24,1,19
.Lmeta_RT0M: .quad -25,8,3307124817920,8,1,1,24,24,1,19
.Lmeta_PHI0FL: .quad -25,8,3307124817920,8,1,1,24,24,1,19
.Lmeta_PHI0FM: .quad -25,8,3307124817920,8,1,1,24,24,1,19
.Lmeta_PHI0H: .quad -1,8,3307124817920,8,1,1,24,24,0,19
.bss
.p2align 3
.Lcounts: .zero 48
.section .note.GNU-stack,"",%progbits
