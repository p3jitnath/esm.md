/* Shared direct SL and RI SLCSET. Contract: skills/md2asm/references/openifs/radiation/live_radiation_first_interpolation.md.
 * x0 Geometry, x1 capacity, x2 MODEL, x3 capacity, x4 process64, x5 capacity.
 * Integer map payloads use live typed Geometry views. No original callables. */
.text
.p2align 4
.macro SLADDR reg,base
 movz x17,#(MD2ASM_INTERPOLATION_RECORD_OFFSET&65535)
 movk x17,#(MD2ASM_INTERPOLATION_RECORD_OFFSET>>16),lsl#16
 add \reg,\base,x17
.endm
.macro DCHK off,value
 ldr w9,[x19,#\off]
 cmp w9,#\value
 b.ne .Lrefuse
.endm
.macro CPDIM goff,soff
 ldr w9,[x19,#\goff]
 str w9,[x21,#\soff]
.endm
.global MD2ASM_INTERPOLATION_ENTRY
.type MD2ASM_INTERPOLATION_ENTRY,%function
MD2ASM_INTERPOLATION_ENTRY:
 cbz x0,.Lbad_early
 cbz x2,.Lbad_early
 cbz x4,.Lbad_early
 tst x0,#7
 b.ne .Lbad_early
 tst x2,#7
 b.ne .Lbad_early
 tst x4,#3
 b.ne .Lbad_early
 mov x9,#17096
 cmp x1,x9
 b.lo .Lbad_early
 adds x10,x0,x9
 b.cs .Lbad_early
 mov x9,#(4275088&65535)
 movk x9,#(4275088>>16),lsl#16
 cmp x3,x9
 b.lo .Lbad_early
 adds x10,x2,x9
 b.cs .Lbad_early
 cmp x5,#64
 b.lo .Lbad_early
 adds x10,x4,#64
 b.cs .Lbad_early
 cmp x5,#64
 b.lo .Lbad_early
 sub sp,sp,#2560
 stp x18,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x29,[sp,#96]
 mov x19,x0
 SLADDR x20,x2
 add x21,sp,#256
 str x4,[sp,#2200]
 str xzr,[sp,#2080]
 str wzr,[sp,#2296]
 /* Private staging retains every source-unwritten byte. */
 mov x9,x20
 mov x10,x21
 mov x11,#1800
 bl .Lcopy
 ldr x4,[sp,#2200]
 ldp w9,w10,[x4]
 cmp w9,#4
 b.ne .Lrefuse
 sub w10,w10,#1
 cmp w10,#3
 b.hi .Lrefuse
 ldp w9,w10,[x4,#8]
 cmp w9,#3
 b.ne .Lrefuse
 cmp w10,#2
 b.ne .Lrefuse
 str w9,[sp,#2240]
 str w10,[sp,#2244]
 ldp w9,w10,[x4,#16]
 sub w11,w9,#1
 cmp w11,#2
 b.hi .Lrefuse
 sub w11,w10,#1
 cmp w11,#1
 b.hi .Lrefuse
 str w9,[sp,#2212]
 str w10,[sp,#2208]
 ldp w9,w10,[x4,#24]
 orr w9,w9,w10
 cbnz w9,.Lrefuse
 ldp x9,x10,[x4,#32]
 cbz x9,.Lrefuse
 cbz x10,.Lrefuse
 orr x11,x9,x10
 tst x11,#3
 b.ne .Lrefuse
 ldr w9,[x4,#48]
 cmp w9,#6
 b.ne .Lrefuse
 ldr w9,[x4,#52]
 cbnz w9,.Lrefuse
 ldr w9,[x4,#56]
 cmp w9,#1
 b.ne .Lrefuse
 ldr w9,[x4,#60]
 cbnz w9,.Lrefuse
 ldrh w9,[x20]
#ifdef MD2ASM_RI
 mov w10,#0x4952
#else
 mov w10,#0x4c53
#endif
 cmp w9,w10
 b.ne .Lrefuse
 ldr w9,[x20,#1024]
 cbnz w9,.Lrefuse
 ldr w22,[x19,#4872]
 cmp w22,#2560
 b.ne .Lrefuse
 ldr w23,[x19,#4936]
 mov w9,#5136
 cmp w23,w9
 b.ne .Lrefuse
#ifdef MD2ASM_RI
 ldr w9,[x20,#1348]
 ldr w10,[x20,#1352]
 cmp w9,#63
 b.hi .Lrefuse
 cmp w10,#63
 b.hi .Lrefuse
 cmp w9,w10
 csel w24,w9,w10,ge
 ldr w11,[x20,#1356]
 ldr w12,[x20,#1360]
 cmp w11,#63
 b.hi .Lrefuse
 cmp w12,#63
 b.hi .Lrefuse
 cmp w11,w12
 csel w11,w11,w12,ge
 cmp w24,w11
 csel w11,w24,w11,ge
 cbz w11,.Lrefuse
 str w11,[sp,#2304]
#else
 ldr w24,[x20,#1364]
 cmp w24,#25
 b.ne .Lrefuse
#endif
 DCHK 4888,-1
 DCHK 4892,1
 DCHK 4884,2
 DCHK 4940,3
 DCHK 4944,2
 DCHK 4956,1
 ldr w9,[x19,#4904]
 mov w10,#2562
 cmp w9,w10
 b.ne .Lrefuse
 ldr w9,[x19,#4948]
 add w10,w23,#3
 cmp w9,w10
 b.ne .Lrefuse
 ldr w9,[x19,#4908]
 cmp w9,#754
 b.eq .Llocal_rows_ready
 cmp w9,#904
 b.ne .Lrefuse
.Llocal_rows_ready:
 str w9,[sp,#2228]
 ldr w9,[x19,#7232]
 str w9,[sp,#2220]
 ldr w9,[x19,#7244]
 str w9,[sp,#2224]
 ldr w9,[x19,#7236]
 ldr w10,[x19,#7240]
 str w9,[sp,#2232]
 str w10,[sp,#2236]
 /* Each fresh output descriptor base must be null. */
 adr x9,.Lowner_offsets
#ifdef MD2ASM_RI
 mov w10,#14
#else
 mov w10,#15
#endif
.Lcheck_owner:
 ldr w11,[x9],#4
 ldr x12,[x20,x11]
 cbnz x12,.Lrefuse
 subs w10,w10,#1
 b.ne .Lcheck_owner
 /* The live source maps have canonical GNU descriptors and explicit region shapes. */
 adr x27,.Linput_descriptors
 mov w28,#6
.Lcheck_descriptor:
 ldp w9,w10,[x27],#8
 add x9,x19,x9
 ldr x11,[x9]
 cbz x11,.Lrefuse
 tst x11,#3
 b.ne .Lrefuse
 ldr x11,[x9,#16]
 cmp x11,#4
 b.ne .Lrefuse
 ldr w11,[x9,#28]
 add w12,w10,#256
 cmp w11,w12
 b.ne .Lrefuse
 ldr x11,[x9,#40]
 cmp x11,#1
 b.ne .Lrefuse
 ldp x11,x12,[x9,#48]
 cmp w28,#3
 b.le .Ldescriptor_region
 cmn x11,#1
 b.ne .Lrefuse
 mov w13,#2562
 cmp w10,#2
 cinc w13,w13,eq
 cmp w10,#2
 cinc w13,w13,eq
 cmp x12,x13
 b.ne .Lrefuse
 cmp w10,#2
 b.ne .Ldescriptor_done
 ldr x11,[x9,#64]
 mov w12,#2566
 cmp x11,x12
 b.ne .Lrefuse
 str w12,[sp,#2216]
 ldp x11,x12,[x9,#72]
 cmp x11,#1
 b.ne .Lrefuse
 cmp x12,#2
 b.ne .Lrefuse
 b .Ldescriptor_done
.Ldescriptor_region:
 cmp x11,#1
 b.ne .Lrefuse
 cmp x12,#3
 b.ne .Lrefuse
.Ldescriptor_done:
 subs w28,w28,#1
 b.ne .Lcheck_descriptor
 /* Prebias the two selected region columns for local row indexing. */
 ldr w9,[sp,#2208]
 sub w9,w9,#1
 ldr w10,[sp,#2216]
 mul w9,w9,w10
 ldr w10,[sp,#2224]
 add w9,w9,w10
 add w9,w9,#1
 ldr x10,[x19,#6088]
 add x10,x10,x9,lsl#2
 str x10,[sp,#2256]
 ldr x10,[x19,#6176]
 add x10,x10,x9,lsl#2
 str x10,[sp,#2264]
 ldr x10,[x19,#7640]
 add x10,x10,#4
 str x10,[sp,#2272]
 ldr w9,[sp,#2212]
 sub w9,w9,#1
 ldr x10,[x19,#6456]
 ldr w11,[x10,w9,uxtw#2]
 ldr x10,[x19,#6520]
 ldr w12,[x10,w9,uxtw#2]
 str w11,[sp,#2280]
 str w12,[sp,#2284]
 /* Every selected physical column and the total come from the live SUMP maps. */
 mov w9,#1
 mov w10,#0
 ldr x11,[sp,#2264]
 ldr w12,[sp,#2228]
.Lcheck_local_row:
 ldr w13,[x11,w9,uxtw#2]
 cmp w13,#0
 b.lt .Lrefuse
 add w10,w10,w13
 add w9,w9,#1
 cmp w9,w12
 b.le .Lcheck_local_row
 ldr w9,[x19,#7376]
 cmp w9,w10
 b.ne .Lrefuse
 CPDIM 4872,1648
 CPDIM 4936,1652
 CPDIM 4888,1656
 CPDIM 4904,1660
 CPDIM 4892,1664
 CPDIM 4908,1668
 CPDIM 7376,1680
#ifdef MD2ASM_RI
 str wzr,[x21,#1684]
 str wzr,[x21,#1688]
 str wzr,[x21,#1692]
 str wzr,[x21,#1696]
 str wzr,[x21,#1700]
#else
 CPDIM 4932,1684
 CPDIM 4956,1688
 CPDIM 4960,1692
 CPDIM 4920,1696
 CPDIM 4924,1700
#endif
 CPDIM 4940,1704
 CPDIM 4948,1708
 CPDIM 7244,1716
 CPDIM 7232,1720
 CPDIM 7236,1724
 CPDIM 7240,1728
 /* The source does not assign SL.NDGSUR here. */
 ldr w11,[sp,#2220]
#ifdef MD2ASM_RI
 add w9,w11,#1
 ldr w10,[x21,#1348]
 sub w9,w9,w10
#else
 add w9,w11,#1
 sub w9,w9,w24
#endif
 mov w10,#-1
 cmp w9,w10
 csel w9,w9,w10,ge
 sub w9,w9,w11
 str w9,[x21,#1672]
#ifdef MD2ASM_RI
 ldr w9,[sp,#2228]
 add w9,w9,w11
 ldr w10,[x21,#1352]
 add w9,w9,w10
#else
 ldr w9,[sp,#2228]
 add w9,w9,w11
 add w9,w9,w24
#endif
 mov w10,#2562
 cmp w9,w10
 csel w9,w9,w10,le
 sub w9,w9,w11
 str w9,[x21,#1676]
#ifdef MD2ASM_RI
 mov w9,#2
 str w9,[x21,#4]
 ldr w9,[sp,#2304]
 str w9,[x21,#1364]
#else
 mov w9,#1
 str w9,[x21,#4]
 str w24,[x21,#1348]
 str w24,[x21,#1352]
 str w24,[x21,#1356]
 str w24,[x21,#1360]
#endif
#ifdef MD2ASM_RI
 mov w9,#1
 ldr w10,[x21,#1348]
 sub w25,w9,w10
 ldr w26,[sp,#2228]
 ldr w10,[x21,#1352]
 add w26,w26,w10
#else
 mov w9,#1
 sub w25,w9,w24
 ldr w26,[sp,#2228]
 add w26,w26,w24
#endif
 sub w26,w26,w25
 add w26,w26,#1
 str w25,[sp,#2160]
 str w26,[sp,#2164]
 mov w9,#1
 str w9,[sp,#2296]
 /* Scratch contains source ZLSA,ZLFA and IMAP with bounded exact extents. */
 uxtw x0,w22
#ifdef MD2ASM_RI
 lsl x0,x0,#4
 bl malloc
#else
 lsl x0,x0,#5
 bl malloc
#endif
 cbz x0,.Lallocation_failure
 str x0,[sp,#2080]
 str x0,[sp,#2088]
 add x9,x0,x22,lsl#3
 str x9,[sp,#2096]
 add x9,x9,x22,lsl#3
 str x9,[sp,#2104]
 add x0,x21,#1736
 mov x1,#-1
 add w2,w22,#2
 bl .Lalloc1
 cbnz w0,.Lallocation_failure
 ldr x9,[x19,#7640]
 ldr x10,[x21,#1736]
 add w11,w22,#4
 uxtw x11,w11
 lsl x11,x11,#2
 bl .Lcopy
 add x0,x21,#8
 sxtw x1,w25
#ifdef MD2ASM_RI
 ldr w2,[sp,#2228]
 ldr w9,[x21,#1352]
 add w2,w2,w9
#else
 ldr w2,[sp,#2228]
 add w2,w2,w24
#endif
 sxtw x2,w2
 bl .Lalloc1
 cbnz w0,.Lallocation_failure
 add x0,x21,#72
 sxtw x1,w25
#ifdef MD2ASM_RI
 ldr w2,[sp,#2228]
 ldr w9,[x21,#1352]
 add w2,w2,w9
#else
 ldr w2,[sp,#2228]
 add w2,w2,w24
#endif
 sxtw x2,w2
 bl .Lalloc1
 cbnz w0,.Lallocation_failure
 add x0,x21,#136
 sxtw x1,w25
#ifdef MD2ASM_RI
 ldr w2,[sp,#2228]
 ldr w9,[x21,#1352]
 add w2,w2,w9
#else
 ldr w2,[sp,#2228]
 add w2,w2,w24
#endif
 sxtw x2,w2
 bl .Lalloc1
 cbnz w0,.Lallocation_failure
 mov w11,#(0xc4653601&65535)
 movk w11,#(0xc4653601>>16),lsl#16
 ldr x9,[x21,#8]
 ldr x10,[x21,#72]
 ldr x12,[x21,#136]
 mov w13,w26
.Linitial_rows:
 str w11,[x9],#4
 str w11,[x10],#4
 str w11,[x12],#4
 subs w13,w13,#1
 b.ne .Linitial_rows
 /* Source ZLSA and ZLFA retain local row order and separate rounding. */
 mov w28,#1
.Lfractions:
 ldr x9,[sp,#2256]
 ldr x10,[sp,#2264]
 ldr x11,[sp,#2272]
 ldr w13,[x9,w28,uxtw#2]
 ldr w14,[x10,w28,uxtw#2]
 cbz w14,.Lfraction_next
 ldr w12,[sp,#2220]
 add w12,w12,w28
 ldr w15,[x11,w12,sxtw#2]
 sub w13,w13,#1
 add w14,w13,w14
 sub w14,w14,#1
 scvtf d0,w13
 scvtf d1,w15
 fdiv d0,d0,d1
 scvtf d2,w14
 fdiv d2,d2,d1
 sub w12,w28,#1
 ldr x9,[sp,#2088]
 str d0,[x9,w12,uxtw#3]
 ldr x9,[sp,#2096]
 str d2,[x9,w12,uxtw#3]
.Lfraction_next:
 add w28,w28,#1
 ldr w9,[sp,#2228]
 cmp w28,w9
 b.le .Lfractions
 /* Source latitude bounds and ordered longitude coverage arithmetic. */
 ldr w11,[sp,#2220]
#ifdef MD2ASM_RI
 ldr w9,[sp,#2232]
 ldr w10,[x21,#1348]
 sub w9,w9,w10
#else
 ldr w9,[sp,#2232]
 sub w9,w9,w24
#endif
 mov w10,#-1
 cmp w9,w10
 csel w28,w9,w10,ge
 sub w28,w28,w11
 str w28,[sp,#2116]
#ifdef MD2ASM_RI
 ldr w9,[sp,#2236]
 ldr w10,[x21,#1352]
 add w9,w9,w10
#else
 ldr w9,[sp,#2236]
 add w9,w9,w24
#endif
 mov w10,#2562
 cmp w9,w10
 csel w9,w9,w10,le
 sub w9,w9,w11
 str w9,[sp,#2120]
 mov w27,#0
 str wzr,[sp,#2112]
.Llatitude:
 ldr w11,[sp,#2220]
 add w12,w28,w11
 sub w9,w12,w24
 ldr w10,[sp,#2232]
 cmp w9,w10
 csel w9,w9,w10,ge
 add w10,w12,w24
 ldr w13,[sp,#2236]
 cmp w10,w13
 csel w10,w10,w13,le
 sub w9,w9,w11
 sub w10,w10,w11
 fmov d0,#1.0
 fmov d1,xzr
 ldr x11,[sp,#2088]
 ldr x12,[sp,#2096]
 mov w17,#0
.Lfraction_limits:
 ldr x13,[sp,#2264]
 ldr w14,[x13,w9,sxtw#2]
 cbz w14,.Lfraction_limit_next
 mov w17,#1
 sub w13,w9,#1
 ldr d2,[x11,w13,sxtw#3]
 ldr d3,[x12,w13,sxtw#3]
 fmin d0,d0,d2
 fmax d1,d1,d3
.Lfraction_limit_next:
 add w9,w9,#1
 cmp w9,w10
 b.le .Lfraction_limits
 cbz w17,.Lno_halo
 ldr w11,[sp,#2220]
 add w12,w28,w11
 sub w9,w12,#2
 mov w10,#-1
 cmp w9,w10
 csel w9,w9,w10,ge
 add w10,w12,#2
 add w11,w22,#2
 cmp w10,w11
 csel w10,w10,w11,le
 fmov d2,xzr
 fmov d3,xzr
 fmov d4,xzr
 fmov d16,#1.0
 fmov d17,#0.5
#ifdef MD2ASM_RI
 ldr w11,[x21,#1360]
 sub w11,w11,#1
 scvtf d18,w11
 ldr w11,[x21,#1356]
 sub w11,w11,#1
 scvtf d19,w11
#else
 sub w11,w24,#1
 scvtf d18,w11
#endif
 ldr x12,[sp,#2272]
.Lneighbor:
 ldr w14,[x12,w9,sxtw#2]
 scvtf d5,w14
 fdiv d6,d16,d5
 fmax d2,d2,d6
 fdiv d7,d18,d5
 fmax d3,d3,d7
#ifdef MD2ASM_RI
 fdiv d7,d19,d5
 fmax d4,d4,d7
#else
 fdiv d7,d18,d5
 fmax d4,d4,d7
#endif
 add w9,w9,#1
 cmp w9,w10
 b.le .Lneighbor
 fadd d3,d3,d2
 fadd d4,d4,d2
 ldr w13,[sp,#2220]
 add w13,w13,w28
 ldr w14,[x12,w13,sxtw#2]
 scvtf d5,w14
 fmul d3,d3,d5
 fadd d3,d3,d17
 fmul d4,d4,d5
 fadd d4,d4,d17
 fdiv d3,d3,d5
 fdiv d4,d4,d5
 fsub d0,d0,d3
 fadd d1,d1,d4
 fmul d0,d0,d5
 fmul d1,d1,d5
 fmov d6,#1.0
 fsub d0,d0,d6
 fmov d6,#2.0
 fadd d1,d1,d6
 fcvtms w15,d0
 fcvtps w16,d1
 cmp w13,#1
 b.lt .Lrotate
 cmp w13,w22
 b.le .Lrotated
.Lrotate:
 lsr w9,w14,#1
 cmp w15,w9
 b.le .Lrotate_positive
 sub w15,w15,w9
 sub w16,w16,w9
 b .Lrotated
.Lrotate_positive:
 add w15,w15,w9
 add w16,w16,w9
.Lrotated:
 sub w9,w16,w15
 add w9,w9,#1
 cmp w9,w14
 b.ge .Lwhole_latitude
#ifdef MD2ASM_RI
 ldr w10,[x21,#1348]
 cmp w13,w10
 b.le .Lwhole_latitude
 ldr w10,[x21,#1352]
 sub w10,w22,w10
#else
 cmp w13,w24
 b.le .Lwhole_latitude
 sub w10,w22,w24
#endif
 add w10,w10,#1
 cmp w13,w10
 b.ge .Lwhole_latitude
 mov w10,w15
 mov w11,w9
 mov w12,w27
 add w27,w27,w9
 b .Lstore_latitude
.Lwhole_latitude:
 mov w10,#1
 mov w11,w14
 add w12,w27,#1
 add w27,w27,w14
 add w27,w27,#3
.Lstore_latitude:
 b .Lstore_latitude_values
.Lno_halo:
 mov w10,#0
 mov w11,#0
 mov w12,#0
.Lstore_latitude_values:
 sub w9,w28,w25
 ldr x13,[x21,#8]
 str w10,[x13,w9,uxtw#2]
 ldr x13,[x21,#72]
 str w11,[x13,w9,uxtw#2]
 ldr x13,[x21,#136]
 str w12,[x13,w9,uxtw#2]
#ifdef MD2ASM_RI
 /* RI does not construct the SL/AD-only IMAP. */
#else
 ldr w14,[sp,#2220]
 add w14,w14,w28
 cmp w14,#1
 b.lt .Lnext_latitude
 cmp w14,w22
 b.gt .Lnext_latitude
 ldr w9,[sp,#2112]
 ldr x13,[sp,#2104]
 add x13,x13,x9,lsl#4
 stp w14,w10,[x13]
 stp w11,w12,[x13,#8]
 add w9,w9,#1
 str w9,[sp,#2112]
#endif
.Lnext_latitude:
 add w28,w28,#1
 ldr w9,[sp,#2120]
 cmp w28,w9
 b.le .Llatitude
#ifdef MD2ASM_RI
 /* RI leaves the SL/AD-only NSLMAP descriptor unchanged. */
#else
 add x0,x21,#1368
 mov x1,#1
 mov x2,#4
 mov x3,#1
 ldr w4,[sp,#2112]
 bl .Lalloc2
 cbnz w0,.Lallocation_failure
 ldr x9,[sp,#2104]
 ldr x10,[x21,#1368]
 ldr w11,[sp,#2112]
 uxtw x11,w11
 lsl x11,x11,#4
 bl .Lcopy
#endif
 add x0,x21,#1456
 mov x1,#1
 ldr w2,[x21,#1680]
 bl .Lalloc1
 cbnz w0,.Lallocation_failure
 /* Complete source core-map recurrence. */
 mov w22,#1
 ldr x9,[sp,#2264]
 ldr w23,[x9,#4]
 mov w24,#0
 mov w28,#1
.Lcore_point:
 cbnz w23,.Lcore_row_ready
.Lnext_core_row:
 add w22,w22,#1
 ldr x9,[sp,#2264]
 ldr w23,[x9,w22,uxtw#2]
 cmp w23,#0
 b.le .Lnext_core_row
 add w24,w24,#3
.Lcore_row_ready:
 sub w23,w23,#1
 sub w10,w22,w25
 ldr x9,[x21,#136]
 ldr w24,[x9,w10,uxtw#2]
 ldr x9,[sp,#2264]
 ldr w12,[x9,w22,uxtw#2]
 add w24,w24,w12
 sub w24,w24,w23
 sub w24,w24,#1
 ldr x9,[sp,#2256]
 ldr w12,[x9,w22,uxtw#2]
 add w24,w24,w12
 ldr x9,[x21,#8]
 ldr w12,[x9,w10,uxtw#2]
 sub w24,w24,w12
 sub w24,w24,w28
 add w12,w24,#1
 add w12,w12,w28
 ldr x9,[x21,#1456]
 sub w10,w28,#1
 str w12,[x9,w10,uxtw#2]
 add w28,w28,#1
 ldr w9,[x21,#1680]
 cmp w28,w9
 b.le .Lcore_point
 ldr w22,[x21,#1648]
 ldr w23,[x21,#1652]
#ifdef MD2ASM_RI
 ldr w24,[x21,#1348]
 add x0,x21,#328
#else
 ldr w24,[x21,#1364]
 add x0,x21,#328
#endif
 mov w1,#1
 sub w1,w1,w23
 sxtw x1,w1
 lsl w2,w23,#1
 mov w3,#1
 sub w3,w3,w24
 sxtw x3,w3
#ifdef MD2ASM_RI
 ldr w4,[sp,#2228]
 ldr w9,[x21,#1352]
 add w4,w4,w9
#else
 ldr w4,[sp,#2228]
 add w4,w4,w24
#endif
 bl .Lalloc2
 cbnz w0,.Lallocation_failure
 /* Complete signed MOD longitude extension, retaining unwritten halo rows. */
 ldr w11,[sp,#2220]
 ldr w9,[sp,#2280]
 sub w9,w9,w24
 mov w10,#-1
 cmp w9,w10
 csel w28,w9,w10,ge
 sub w28,w28,w11
#ifdef MD2ASM_RI
 ldr w9,[sp,#2284]
 ldr w10,[x21,#1352]
 add w9,w9,w10
#else
 ldr w9,[sp,#2284]
 add w9,w9,w24
#endif
 mov w10,#2562
 cmp w9,w10
 csel w9,w9,w10,le
 sub w9,w9,w11
 str w9,[sp,#2288]
.Lextension_row:
 ldr w9,[sp,#2220]
 add w9,w9,w28
 ldr x10,[sp,#2272]
 ldr w10,[x10,w9,sxtw#2]
 sub w9,w28,w25
 ldr x11,[x21,#8]
 ldr w11,[x11,w9,uxtw#2]
 ldr x12,[x21,#72]
 ldr w12,[x12,w9,uxtw#2]
 mov w13,#1
 sub w13,w13,w23
 mov w14,w13
 mov w15,w9
 add w9,w23,w23,lsl#1
 mul w15,w15,w9
 ldr x16,[x21,#328]
 add x16,x16,x15,lsl#2
.Lextension_longitude:
 mov w9,w14
 ldr w17,[sp,#2220]
 add w17,w17,w28
 cmp w17,#1
 b.lt .Lextension_mirror
 cmp w17,w22
 b.le .Lextension_unmirrored
.Lextension_mirror:
 add w9,w9,w10,lsr#1
.Lextension_unmirrored:
 sub w9,w9,w11
 add w9,w9,w10
 sdiv w15,w9,w10
 msub w9,w15,w10,w9
 add w9,w9,#1
 cmp w11,#1
 b.ne .Lextension_store
 cmp w12,w10
 b.ne .Lextension_store
 cmp w9,w10
 csel w9,wzr,w9,eq
.Lextension_store:
 str w9,[x16],#4
 add w14,w14,#1
 lsl w9,w23,#1
 cmp w14,w9
 b.le .Lextension_longitude
 add w28,w28,#1
 ldr w9,[sp,#2288]
 cmp w28,w9
 b.le .Lextension_row
 str w27,[x21,#1020]
 sub w9,w27,#1
 lsr w9,w9,#10
 add w9,w9,#1
 lsl w9,w9,#10
 add w9,w9,#29
 str w9,[x21,#1016]
 add w26,w9,#4
 add x0,x21,#1056
 mov x1,#1
 uxtw x2,w26
 bl .Lalloc1
 cbnz w0,.Lallocation_failure
 add x0,x21,#1120
 mov x1,#1
 uxtw x2,w26
 bl .Lalloc1
 cbnz w0,.Lallocation_failure
 add x0,x21,#1272
 mov x1,#1
 uxtw x2,w26
 bl .Lalloc1
 cbnz w0,.Lallocation_failure
 ldr x9,[x21,#1056]
 ldr x10,[x21,#1120]
 ldr x11,[x21,#1272]
 mov w12,w26
.Lzero_masks:
 str wzr,[x9],#4
 str wzr,[x10],#4
 str wzr,[x11],#4
 subs w12,w12,#1
 b.ne .Lzero_masks
 /* All ranks finish local allocation before any communication child. */
 mov w0,#0
 bl md2asm_agree_owned_distributed_partition_status
 cbnz w0,.Lrollback_status
 mov x0,x21
 ldr x1,[sp,#2200]
 add x1,x1,#48
 bl md2asm_write_distributed_halo_status
 cbnz w0,.Lhalo_report_fatal
 mov x0,x21
 mov x1,x19
 ldr x2,[sp,#2200]
 bl md2asm_initialize_distributed_interpolation_communication
 cbnz w0,.Lrollback_status
 mov x9,x21
 mov x10,x20
 mov x11,#1800
 bl .Lcopy
 ldr x0,[sp,#2080]
 bl free
 mov w0,#0
 b .Ldone
.Lhalo_report_fatal:
 mov w0,#3
 bl fortran_mpi_abort
 brk #0
.Lallocation_failure:
 mov w0,#1
 b .Lstage_failed
.Lrefuse:
 mov w0,#2
.Lstage_failed:
 bl md2asm_agree_owned_distributed_partition_status
.Lrollback_status:
 str w0,[sp,#2248]
 ldr w9,[sp,#2296]
 cbz w9,.Lrollback_scratch
 adr x22,.Lowner_offsets
#ifdef MD2ASM_RI
 mov w23,#14
#else
 mov w23,#15
#endif
.Lrollback_owner:
 ldr w9,[x22],#4
 ldr x0,[x21,x9]
 cbz x0,.Lrollback_next
 bl free
.Lrollback_next:
 subs w23,w23,#1
 b.ne .Lrollback_owner
.Lrollback_scratch:
 ldr x0,[sp,#2080]
 cbz x0,.Lallocation_return
 bl free
.Lallocation_return:
 ldr w0,[sp,#2248]
 b .Ldone
.Ldone:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldr x29,[sp,#96]
 ldp x18,x30,[sp]
 add sp,sp,#2560
 ret
.Lbad_early:
 mov w0,#2
 ret
.size MD2ASM_INTERPOLATION_ENTRY,.-MD2ASM_INTERPOLATION_ENTRY
/* Allocate and construct the GNU typed integer descriptor from explicit bounds. */
.Lalloc1:
 stp x0,x1,[sp,#-48]!
 stp x2,x30,[sp,#16]
 sub x0,x2,x1
 add x0,x0,#1
 lsl x0,x0,#2
 bl malloc
 cbz x0,.Lalloc1_bad
 ldp x9,x10,[sp]
 ldr x11,[sp,#16]
 str x0,[x9]
 neg x12,x10
 str x12,[x9,#8]
 mov x12,#4
 str x12,[x9,#16]
 str wzr,[x9,#24]
 mov w12,#0x101
 strh w12,[x9,#28]
 strh wzr,[x9,#30]
 mov x12,#4
 str x12,[x9,#32]
 mov x12,#1
 str x12,[x9,#40]
 stp x10,x11,[x9,#48]
 mov w0,#0
 b .Lalloc1_done
.Lalloc1_bad:
 mov w0,#1
.Lalloc1_done:
 ldr x30,[sp,#24]
 add sp,sp,#48
 ret
.Lalloc2:
 stp x0,x1,[sp,#-64]!
 stp x2,x3,[sp,#16]
 stp x4,x30,[sp,#32]
 sub x9,x2,x1
 add x9,x9,#1
 sub x10,x4,x3
 add x10,x10,#1
 mul x0,x9,x10
 lsl x0,x0,#2
 bl malloc
 cbz x0,.Lalloc2_bad
 ldp x9,x10,[sp]
 ldp x11,x12,[sp,#16]
 ldr x13,[sp,#32]
 str x0,[x9]
 sub x14,x11,x10
 add x14,x14,#1
 mul x15,x14,x12
 neg x15,x15
 sub x15,x15,x10
 str x15,[x9,#8]
 mov x15,#4
 str x15,[x9,#16]
 str wzr,[x9,#24]
 mov w15,#0x102
 strh w15,[x9,#28]
 strh wzr,[x9,#30]
 mov x15,#4
 str x15,[x9,#32]
 mov x15,#1
 str x15,[x9,#40]
 stp x10,x11,[x9,#48]
 str x14,[x9,#64]
 stp x12,x13,[x9,#72]
 mov w0,#0
 b .Lalloc2_done
.Lalloc2_bad:
 mov w0,#1
.Lalloc2_done:
 ldr x30,[sp,#40]
 add sp,sp,#64
 ret
.Lcopy:
 ldr w12,[x9],#4
 str w12,[x10],#4
 subs x11,x11,#4
 b.ne .Lcopy
 ret
.p2align 4
.global MD2ASM_INTERPOLATION_RELEASE
.type MD2ASM_INTERPOLATION_RELEASE,%function
MD2ASM_INTERPOLATION_RELEASE:
 cbz x0,.Lbad_early
 tst x0,#7
 b.ne .Lbad_early
 mov x9,#(4275088&65535)
 movk x9,#(4275088>>16),lsl#16
 cmp x1,x9
 b.lo .Lbad_early
 stp x18,x30,[sp,#-48]!
 stp x19,x20,[sp,#16]
 str x21,[sp,#32]
 SLADDR x19,x0
 adr x20,.Lowner_offsets
#ifdef MD2ASM_RI
 mov w21,#14
#else
 mov w21,#15
#endif
.Lrelease_owner:
 ldr w9,[x20],#4
 ldr x0,[x19,x9]
 cbz x0,.Lrelease_next
 str xzr,[x19,x9]
 bl free
.Lrelease_next:
 subs w21,w21,#1
 b.ne .Lrelease_owner
 mov w0,#0
 ldp x19,x20,[sp,#16]
 ldr x21,[sp,#32]
 ldp x18,x30,[sp],#48
 ret
.size MD2ASM_INTERPOLATION_RELEASE,.-MD2ASM_INTERPOLATION_RELEASE
.p2align 3
.Lowner_offsets:
#ifdef MD2ASM_RI
 .word 1736,8,72,136,1456,328,1056,1120,1272,608,672,736,800,864
#else
 .word 1736,8,72,136,1368,1456,328,1056,1120,1272,608,672,736,800,864
#endif
.Linput_descriptors:
 .word 7640,1,6088,2,6176,2,6264,1,6456,1,6520,1
.section .note.GNU-stack,"",%progbits
