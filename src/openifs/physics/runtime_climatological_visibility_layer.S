// Runtime CLIMAER_LAYER with complete input spans and original ordered arithmetic.
// Interface and checks: skills/md2asm/references/openifs/physics/runtime_climatological_visibility_layer.md.
// x0 through x7 carry the eight original record addresses; incoming stack byte 0 holds context32.
// P is 1 through 128, L is 2 through 137, first is 1, and the cloud array has 4 or 5 planes.
// Status 0 means completion; 1 means allocation failure; 2 admission failure; 3 child failure.
.arch armv8.2-a
.text
.p2align 4
.macro MC reg,value
 movz \reg,#((\value)&65535)
 .if (\value)>65535
 movk \reg,#(((\value)>>16)&65535),lsl#16
 .endif
.endm
.macro PCALL target
 bl \target
 ldr x18,[sp,#288]
.endm
.macro INPUT record,bytes
 ldr x0,[x19,#\record]
 MC x1,\bytes
 mov x2,#7
 bl .Lp_input
 cbnz w0,.Lp_bad
.endm
.macro FLAG offset,wanted
 ldr x9,[x19,#8]
 MC x10,\offset
 ldr w9,[x9,x10]
 cmp w9,#\wanted
 b.ne .Lp_bad
.endm
.macro VIEW record,offset,rank,d1,d2,d3,half,dest,span=1,fslot=0,bslot=0
 ldr x0,[x19,#\record]
 MC x9,\offset
 add x0,x0,x9
 mov w1,#\rank
 mov x2,#8
 mov w3,\d1
 mov w4,\d2
 mov w5,\d3
 mov w6,#3
 mov w7,#\half
 bl .Lp_view
 cbz x0,.Lp_bad
 str x0,[sp,#\dest]
 .if \fslot
 str x2,[sp,#\fslot]
 .endif
 .if \bslot
 str x1,[sp,#\bslot]
 .endif
 .if \span
 mov x2,#7
 bl .Lp_input
 cbnz w0,.Lp_bad
 .endif
.endm
.macro META pointer,slot,field=0
 ldr x9,[x19]
 MC x10,\pointer
 ldr x20,[x9,x10]
 mov x0,x20
 mov x1,#64
 mov x2,#7
 bl .Lp_input
 cbnz w0,.Lp_bad
 ldr w9,[x20,#\field]
 cmp w9,#1
 b.lt .Lp_bad
 str w9,[sp,#\slot]
.endm
.macro ALIAS name,base,offset
 ldr x9,[sp,#\base]
 add x9,x9,#\offset
 adrp x10,:got:\name
 ldr x10,[x10,:got_lo12:\name]
 cmp x9,x10
 b.ne .Lp_bad
.endm
.global md2asm_runtime_climatological_visibility_layer
.type md2asm_runtime_climatological_visibility_layer,%function
md2asm_runtime_climatological_visibility_layer:
 mov x17,sp
 sub sp,sp,#4096
 stp x19,x20,[sp,#192]
 stp x21,x22,[sp,#208]
 stp x23,x24,[sp,#224]
 stp x25,x26,[sp,#240]
 stp x27,x28,[sp,#256]
 stp x29,x30,[sp,#272]
 str x18,[sp,#288]
 mov x29,sp
 add x19,sp,#320
 stp x0,x1,[x19]
 stp x2,x3,[x19,#16]
 stp x4,x5,[x19,#32]
 stp x6,x7,[x19,#48]
 ldr x8,[x17]
 str x8,[x19,#64]
 str xzr,[sp,#400]
 str wzr,[sp,#456]
 str wzr,[sp,#460]
 str xzr,[sp,#464]
 str xzr,[sp,#2304]
 str xzr,[sp,#2312]
 str wzr,[sp,#2320]
 mov x28,#0
 mrs x9,fpcr
 cbnz x9,.Lp_bad
 PCALL __errno_location
 str x0,[sp,#400]
 ldr w9,[x0]
 str w9,[sp,#408]
 INPUT 0,18224
 INPUT 8,4275088
 INPUT 16,192
 INPUT 24,1992
 INPUT 32,1240
 INPUT 40,1240
 INPUT 48,13680
 INPUT 56,4680
 INPUT 64,32
 ldr x9,[x19,#64]
 ldp x0,x10,[x9]
 stp x0,x10,[sp,#416]
 ldp x11,x12,[x9,#16]
 stp x11,x12,[sp,#432]
 mov x1,#520
 mov x2,#7
 bl .Lp_input
 cbnz w0,.Lp_bad
 ldr x0,[sp,#432]
 mov x1,#1920
 mov x2,#7
 bl .Lp_input
 cbnz w0,.Lp_bad
 ldr x20,[sp,#424]
 mov x0,x20
 mov x1,#16
 mov x2,#7
 bl .Lp_input
 cbnz w0,.Lp_bad
 ldr x9,[x20,#8]
 cbnz x9,.Lp_bad
 ldr x20,[x20]
 mov x0,x20
 mov x1,#4
 mov x2,#3
 bl .Lp_input
 cbnz w0,.Lp_bad
 ldr w9,[x20]
 cbnz w9,.Lp_bad
 ldr x9,[sp,#416]
 ldr w10,[x9,#512]
 cmp w10,#1
 b.ne .Lp_bad
 ldr x9,[x19,#16]
 ldr w25,[x9,#12]
 cmp w25,#1
 b.lt .Lp_bad
 cmp w25,#128
 b.gt .Lp_bad
 ldr w24,[x9,#48]
 cmp w24,#2
 b.lt .Lp_bad
 cmp w24,#137
 b.gt .Lp_bad
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lp_bad
 mov w26,#0
 ldr w27,[x9,#4]
 cmp w27,#1
 b.lt .Lp_bad
 cmp w27,w25
 b.gt .Lp_bad
 sub w27,w27,#1
 FLAG 1577928,1
 FLAG 1609132,0
 FLAG 1609240,0
 FLAG 1608908,1
 FLAG 1608924,12
 FLAG 4107008,12
 ldr x9,[x19,#8]
 MC x10,1588300
 ldr w9,[x9,x10]
 cmp w9,#1
 b.hi .Lp_bad
 // SATUR keeps its accepted assembly-owned scalar aliases.
 ALIAS __yomcst_MOD_retv,416,240
 ALIAS __yomcst_MOD_rtt,416,368
 ALIAS __yoethf_MOD_r2es,432,0
 ALIAS __yoethf_MOD_r3les,432,8
 ALIAS __yoethf_MOD_r3ies,432,16
 ALIAS __yoethf_MOD_r4les,432,24
 ALIAS __yoethf_MOD_r4ies,432,32
 ALIAS __yoethf_MOD_rtwat,432,112
 ALIAS __yoethf_MOD_rtice,432,136
 ALIAS __yoethf_MOD_rticecu,432,144
 ALIAS __yoethf_MOD_rtwat_rtice_r,432,152
 ALIAS __yoethf_MOD_rtwat_rticecu_r,432,160
 umull x9,w24,w25
 lsl x9,x9,#3
 str x9,[sp,#760]
 uxtw x10,w25
 lsl x10,x10,#3
 str x10,[sp,#784]
 add x11,x9,x10
 str x11,[sp,#768]
 lsl x11,x9,#2
 str x11,[sp,#776]
 add w23,w24,#1
 VIEW 24,624,2,w25,w23,#0,1,512
 VIEW 24,712,2,w25,w24,#0,0,520
 VIEW 40,208,2,w25,w24,#0,0,528
 VIEW 40,384,2,w25,w24,#0,0,536
 VIEW 40,472,2,w25,w24,#0,0,544
 // Protect the complete declared CLD allocation, including vapour plane5.
 ldr x9,[x19,#40]
 ldr x10,[x9,#1104]
 sub x10,x10,#4
 cmp x10,#1
 b.hi .Lp_bad
 VIEW 40,1000,3,w25,w24,#0,0,552,1,0,776
 ldr x9,[sp,#552]
 ldr x10,[sp,#760]
 add x9,x9,x10
 str x9,[sp,#688]
 add x9,x9,x10
 str x9,[sp,#696]
 add x9,x9,x10
 str x9,[sp,#704]
 VIEW 24,976,1,w25,#0,#0,0,576
 VIEW 24,1488,1,w25,#0,#0,0,584
 VIEW 24,1168,1,w25,#0,#0,0,592
 VIEW 24,1232,1,w25,#0,#0,0,600
 VIEW 48,8464,2,w25,#0,#0,0,560,1,856
 VIEW 48,8992,2,w25,#0,#0,0,568,0,864,872
 VIEW 56,4376,1,w25,#0,#0,0,608,0
 VIEW 56,4504,1,w25,#0,#0,0,616,0
 META 6808,800,8
 ldr x0,[x19]
 MC x9,14240
 add x0,x0,x9
 mov w1,#2
 mov x2,#64
 mov w3,#0
 mov w4,#0
 mov w5,#0
 mov w6,#5
 mov w7,#0
 bl .Lp_view
 cbz x0,.Lp_bad
 mov x20,x0
 mov x2,#7
 bl .Lp_input
 cbnz w0,.Lp_bad
 ldr w9,[x20]
 cmp w9,#1
 b.lt .Lp_bad
 str w9,[sp,#808]
 META 14424,816
 META 14432,824
 META 14440,832
 META 14448,840
 META 14456,848
 ldr w9,[sp,#800]
 ldr x10,[sp,#856]
 cmp x9,x10
 b.hi .Lp_bad
 sub x9,x9,#1
 ldr x10,[sp,#784]
 ldr x11,[sp,#560]
 madd x11,x9,x10,x11
 str x11,[sp,#560]
 mov w20,#0
.Lp_diag_fields:
 add x9,sp,#808
 add x10,x9,w20,uxtw#3
 ldr w10,[x10]
 ldr x11,[sp,#864]
 cmp x10,x11
 b.hi .Lp_bad
 mov w21,#0
.Lp_diag_unique:
 cmp w21,w20
 b.eq .Lp_diag_unique_done
 add x11,x9,w21,uxtw#3
 ldr w11,[x11]
 cmp w11,w10
 b.eq .Lp_bad
 add w21,w21,#1
 b .Lp_diag_unique
.Lp_diag_unique_done:
 sub x10,x10,#1
 ldr x11,[sp,#784]
 ldr x12,[sp,#568]
 madd x12,x10,x11,x12
 add x9,sp,#712
 str x12,[x9,w20,uxtw#3]
 add w20,w20,#1
 cmp w20,#6
 b.lo .Lp_diag_fields
 // Check all source-read profile and current climate payloads.
 adr x21,.Lp_profiles
 mov w22,#9
.Lp_profile:
 ldr w9,[x21],#4
 ldr x0,[x19,#8]
 add x0,x0,x9
 mov w1,#1
 mov x2,#8
 add w3,w24,#1
 mov w4,#0
 mov w5,#0
 mov w6,#3
 mov w7,#0
 bl .Lp_view
 cbz x0,.Lp_bad
 mov x2,#7
 bl .Lp_input
 cbnz w0,.Lp_bad
 subs w22,w22,#1
 b.ne .Lp_profile
 adr x21,.Lp_tables
 mov w22,#11
.Lp_table:
 ldr w9,[x21],#4
 ldr x0,[x19,#8]
 add x0,x0,x9
 mov w1,#2
 mov x2,#8
 mov w3,#120
 mov w4,#61
 mov w5,#0
 mov w6,#3
 mov w7,#0
 bl .Lp_view
 cbz x0,.Lp_bad
 mov x2,#7
 bl .Lp_input
 cbnz w0,.Lp_bad
 subs w22,w22,#1
 b.ne .Lp_table
 adr x21,.Lp_coefficients
 mov w22,#5
.Lp_coefficient:
 ldp w9,w1,[x21]
 ldp w2,w6,[x21,#8]
 ldp w3,w4,[x21,#16]
 ldr w5,[x21,#24]
 add x21,x21,#28
 ldr x0,[x19,#8]
 add x0,x0,x9
 mov w7,#0
 bl .Lp_view
 cbz x0,.Lp_bad
 mov x2,#7
 cmp w22,#4
 b.lo .Lp_coeff_alignment_ready
 mov x2,#3
.Lp_coeff_alignment_ready:
 bl .Lp_input
 cbnz w0,.Lp_bad
 subs w22,w22,#1
 b.ne .Lp_coefficient
 ldr x0,[sp,#568]
 ldr x1,[sp,#872]
 bl .Lp_output
 cbnz w0,.Lp_bad
 ldr x0,[sp,#608]
 ldr x1,[sp,#784]
 bl .Lp_output
 cbnz w0,.Lp_bad
 ldr x0,[sp,#616]
 ldr x1,[sp,#784]
 bl .Lp_output
 cbnz w0,.Lp_bad
 mov w9,#21
 umull x9,w24,w9
 add x9,x9,#15
 umull x9,w25,w9
 lsl x9,x9,#3
 str x9,[sp,#448]
 ldr x10,[sp,#440]
 cmp x10,x9
 b.lo .Lp_bad
 mov x0,x9
 PCALL malloc
 cbz x0,.Lp_allocation_failure
 mov x28,x0
 str x28,[sp,#464]
 str x28,[sp,#2240]
 ldr x9,[sp,#768]
 add x10,x28,x9
 str x10,[sp,#2248]
 ldr x9,[sp,#760]
 mov x11,#6
 madd x10,x9,x11,x10
 str x10,[sp,#2256]
 mov x11,#12
 madd x10,x9,x11,x10
 str x10,[sp,#2264]
 add x10,x10,x9
 str x10,[sp,#2272]
 add x10,x10,x9
 str x10,[sp,#2280]
 ldr x11,[sp,#784]
 add x10,x10,x11
 str x10,[sp,#2288]
 add x10,x10,x11
 str x10,[sp,#2296]
 ldr x9,[sp,#416]
 ldr x9,[x9,#112]
 str x9,[sp,#2360]
 b .Lp_temperature_start

.Lp_temperature_start:
 mov w21,#2
.Lp_temperature_level:
 mov w20,w26
.Lp_temperature_column:
 sub w22,w21,#1
 madd w22,w22,w25,w20
 sub w23,w22,w25
 ldr x9,[sp,#528]
 ldr d0,[x9,w23,uxtw #3]
 ldr d1,[x9,w22,uxtw #3]
 ldr x9,[sp,#520]
 ldr d2,[x9,w23,uxtw #3]
 ldr d3,[x9,w22,uxtw #3]
 ldr x9,[sp,#512]
 add w10,w22,w25
 ldr d4,[x9,w10,uxtw #3]
 fmul d0,d0,d2
 fsub d5,d3,d4
 fmul d0,d0,d5
 fmul d1,d1,d3
 fsub d5,d4,d2
 fmul d1,d1,d5
 fadd d0,d0,d1
 fsub d1,d3,d2
 fmul d1,d4,d1
 fmov d2,#1.0
 fdiv d1,d2,d1
 fmul d0,d0,d1
 str d0,[x28,w22,uxtw #3]
 add w20,w20,#1
 cmp w20,w27
 b.le .Lp_temperature_column
 add w21,w21,#1
 cmp w21,w24
 b.le .Lp_temperature_level
 mov w20,w26
.Lp_temperature_boundaries:
 ldr x9,[sp,#528]
 ldr d0,[x9,w20,uxtw #3]
 add w22,w20,w25
 ldr d1,[x28,w22,uxtw #3]
 fsub d1,d0,d1
 ldr x9,[sp,#520]
 ldr d2,[x9,w20,uxtw #3]
 fmul d1,d2,d1
 ldr x9,[sp,#512]
 add w10,w22,w25
 ldr d3,[x9,w10,uxtw #3]
 fsub d2,d2,d3
 fdiv d1,d1,d2
 fsub d0,d0,d1
 str d0,[x28,w20,uxtw #3]
 ldr x9,[sp,#560]
 ldr d0,[x9,w20,uxtw #3]
 madd w22,w24,w25,w20
 str d0,[x28,w22,uxtw #3]
 add w20,w20,#1
 cmp w20,w27
 b.le .Lp_temperature_boundaries
 // Actual RADACA ordinary argument order, followed by context16.
 ldr x9,[sp,#576]
 str x9,[sp]
 ldr x9,[sp,#584]
 str x9,[sp,#8]
 ldr x9,[sp,#592]
 str x9,[sp,#16]
 ldr x9,[sp,#600]
 str x9,[sp,#24]
 ldr x9,[sp,#2240]
 str x9,[sp,#32]
 ldr x9,[sp,#2248]
 str x9,[sp,#40]
 ldr x9,[sp,#2256]
 str x9,[sp,#48]
 ldr x9,[sp,#2264]
 str x9,[sp,#56]
 ldr x9,[sp,#608]
 str x9,[sp,#64]
 ldr x9,[sp,#712]
 ldr x10,[sp,#720]
 stp x9,x10,[sp,#72]
 ldr x9,[sp,#728]
 ldr x10,[sp,#736]
 stp x9,x10,[sp,#88]
 ldr x9,[sp,#744]
 ldr x10,[sp,#752]
 stp x9,x10,[sp,#104]
 ldr x9,[x19,#64]
 str x9,[sp,#120]
 ldr x9,[x19,#8]
 MC x10,1622464
 add x0,x9,x10
 MC x10,1608728
 add x1,x9,x10
 MC x10,1359328
 add x2,x9,x10
 ldr x3,[x19,#16]
 add x4,x3,#4
 add x5,x3,#12
 add x6,x3,#48
 ldr x7,[sp,#512]
 mov w9,#1
 str w9,[sp,#2320]
 PCALL md2asm_runtime_aerosol_visibility_climatology
 cbnz w0,.Lp_child_failure
.Lp_after_RADACA:
 // The original SATUR call selects only the bottom level and flag2.
 ldr x0,[x19,#16]
 add x1,x0,#4
 add x2,x0,#12
 add x3,x0,#48
 mov x4,x3
 ldr x9,[x19,#8]
 MC x10,1588300
 add x5,x9,x10
 ldr x6,[sp,#520]
 ldr x7,[sp,#528]
 ldr x9,[sp,#2272]
 str x9,[sp]
 mov w9,#2
 str w9,[sp,#2340]
 add x9,sp,#2340
 str x9,[sp,#8]
 mov w9,#2
 str w9,[sp,#2320]
 PCALL md2asm_callpar_satur_7358525
.Lp_after_SATUR:
 mov w20,w26
.Lp_humidity:
 sub w22,w24,#1
 madd w22,w22,w25,w20
 ldr x9,[sp,#536]
 ldr d0,[x9,w22,uxtw#3]
 ldr x9,[sp,#2272]
 ldr d1,[x9,w22,uxtw#3]
 fdiv d0,d0,d1
 ldr x9,[sp,#2280]
 str d0,[x9,w20,uxtw#3]
 ldr x9,[sp,#520]
 ldr d0,[x9,w22,uxtw#3]
 sub w23,w22,w25
 ldr d1,[x9,w23,uxtw#3]
 fsub d0,d0,d1
 ldr d1,[sp,#2360]
 fdiv d0,d1,d0
 ldr x9,[sp,#2288]
 str d0,[x9,w20,uxtw#3]
 add w20,w20,#1
 cmp w20,w27
 b.le .Lp_humidity
 mov w21,#0
.Lp_species:
 mov w20,w26
.Lp_mixing_ratio:
 mul w9,w24,w25
 mul w22,w21,w9
 sub w9,w24,#1
 madd w22,w9,w25,w22
 add w22,w22,w20
 ldr x9,[sp,#2256]
 ldr d0,[x9,w22,uxtw#3]
 ldr d1,.Lp_thousand
 fmul d0,d1,d0
 ldr x9,[sp,#2288]
 ldr d1,[x9,w20,uxtw#3]
 fmul d0,d0,d1
 madd w22,w21,w25,w20
 ldr x9,[sp,#2296]
 str d0,[x9,w22,uxtw#3]
 add w20,w20,#1
 cmp w20,w27
 b.le .Lp_mixing_ratio
 add w21,w21,#1
 cmp w21,#12
 b.lt .Lp_species
 // The 550nm band is original source band10.
 ldr x0,[x19,#16]
 add x2,x0,#4
 mov x1,x0
 add x0,x0,#12
 ldr x3,[x19,#8]
 MC x9,4100096
 add x3,x3,x9
 mov w9,#10
 str w9,[sp,#2344]
 add x4,sp,#2344
 ldr x5,[sp,#2296]
 ldr x6,[sp,#2280]
 ldr x7,[sp,#608]
 ldr x9,[x19,#64]
 str x9,[sp]
 mov w9,#3
 str w9,[sp,#2320]
 PCALL md2asm_runtime_shortwave_aerosol_extinction
 cbnz w0,.Lp_child_failure
.Lp_after_extinction:
 ldr x0,[x19,#16]
 add x1,x0,#4
 add x2,x0,#12
 add x3,x0,#48
 ldr x4,[sp,#608]
 ldr x5,[sp,#544]
 ldr x6,[sp,#552]
 ldr x7,[sp,#688]
 ldr x9,[sp,#696]
 str x9,[sp]
 ldr x9,[sp,#704]
 str x9,[sp,#8]
 ldr x9,[sp,#520]
 str x9,[sp,#16]
 ldr x9,[sp,#528]
 str x9,[sp,#24]
 ldr x9,[sp,#616]
 str x9,[sp,#32]
 ldr x9,[x19,#64]
 str x9,[sp,#40]
 mov w9,#4
 str w9,[sp,#2320]
 PCALL md2asm_runtime_cloud_aerosol_visibility
 cbnz w0,.Lp_child_failure
.Lp_after_CLAERVIS:
 mov w0,#0
 b .Lp_cleanup
.global md2asm_runtime_climaer_first_child_failure
.hidden md2asm_runtime_climaer_first_child_failure
.type md2asm_runtime_climaer_first_child_failure,%function
md2asm_runtime_climaer_first_child_failure:
.Lp_child_failure:
 str w0,[sp,#2304]
 str x30,[sp,#2312]
 mov w0,#3
 b .Lp_cleanup
.Lp_allocation_failure:
 mov w0,#1
 b .Lp_cleanup
.Lp_bad:
 mov w0,#2
.Lp_cleanup:
 str w0,[sp,#412]
 cbz x28,.Lp_return
 mov x0,x28
 PCALL free
 mov x28,#0
 str xzr,[sp,#464]
.Lp_return:
 ldr x9,[sp,#400]
 cbz x9,.Lp_restore
 ldr w10,[sp,#408]
 str w10,[x9]
.Lp_restore:
 ldr w0,[sp,#412]
 ldr x18,[sp,#288]
 ldp x19,x20,[sp,#192]
 ldp x21,x22,[sp,#208]
 ldp x23,x24,[sp,#224]
 ldp x25,x26,[sp,#240]
 ldp x27,x28,[sp,#256]
 ldp x29,x30,[sp,#272]
 add sp,sp,#4096
 ret
.size md2asm_runtime_climatological_visibility_layer,.-md2asm_runtime_climatological_visibility_layer
// Private bounded span and canonical GNU view helpers. No target calls.
.Lp_input:
 cbz x0,.Lp_span_bad
 tst x0,x2
 b.ne .Lp_span_bad
 cbz x1,.Lp_span_bad
 adds x9,x0,x1
 b.cs .Lp_span_bad
 ldr w10,[sp,#456]
 cmp w10,#64
 b.hs .Lp_span_bad
 add x11,sp,#896
 add x11,x11,w10,uxtw#4
 stp x0,x9,[x11]
 add w10,w10,#1
 str w10,[sp,#456]
 mov w0,#0
 ret
.Lp_span_bad:
 mov w0,#2
 ret
.Lp_output:
 cbz x0,.Lp_span_bad
 tst x0,#7
 b.ne .Lp_span_bad
 cbz x1,.Lp_span_bad
 adds x9,x0,x1
 b.cs .Lp_span_bad
 ldr w10,[sp,#456]
 add x11,sp,#896
.Lp_output_inputs:
 cbz w10,.Lp_output_previous
 ldp x12,x13,[x11],#16
 cmp x9,x12
 b.ls .Lp_output_input_next
 cmp x13,x0
 b.hi .Lp_span_bad
.Lp_output_input_next:
 sub w10,w10,#1
 b .Lp_output_inputs
.Lp_output_previous:
 ldr w14,[sp,#460]
 cmp w14,#8
 b.hs .Lp_span_bad
 mov w10,w14
 add x11,sp,#1920
.Lp_output_outputs:
 cbz w10,.Lp_output_store
 ldp x12,x13,[x11],#16
 cmp x9,x12
 b.ls .Lp_output_output_next
 cmp x13,x0
 b.hi .Lp_span_bad
.Lp_output_output_next:
 sub w10,w10,#1
 b .Lp_output_outputs
.Lp_output_store:
 stp x0,x9,[x11]
 add w14,w14,#1
 str w14,[sp,#460]
 mov w0,#0
 ret
// x0 header;w1 rank;x2 elementbytes;w3..5 expected extents(0=dynamic);
// w6 GNU type;w7=1 selects rank2 half-pressure second lowerbound0.
// Return x0=data,x1=fullpayloadbytes,x2=secondextent;zero x0 refuses.
.Lp_view:
 mov x9,x0
 ldr x10,[x9]
 cbz x10,.Lp_view_bad
 mov x6,#8
 cmp x2,x6
 csel x6,x2,x6,lo
 sub x6,x6,#1
 tst x10,x6
 b.ne .Lp_view_bad
 ldr x6,[x9,#16]
 cmp x6,x2
 b.ne .Lp_view_bad
 ldr x6,[x9,#32]
 cmp x6,x2
 b.ne .Lp_view_bad
 ldrb w6,[x9,#28]
 cmp w6,w1
 b.ne .Lp_view_bad
 // Admitted element widths4/8/64 identify integer/real/derived GNU types.
 ldrb w6,[x9,#29]
 cmp x2,#64
 mov w0,#5
 mov w8,#3
 csel w0,w0,w8,eq
 cmp x2,#4
 mov w8,#1
 csel w0,w8,w0,eq
 cmp w6,w0
 b.ne .Lp_view_bad
 mov x11,#1
 mov x12,#0
 add x13,x9,#40
 mov w14,#0
 mov x8,#0
.Lp_view_axis:
 ldr x15,[x13]
 cmp x15,x11
 b.ne .Lp_view_bad
 ldr x16,[x13,#8]
 mov x6,#1
 cmp w14,#1
 csel x0,x7,xzr,eq
 sub x6,x6,x0
 cmp x16,x6
 b.ne .Lp_view_bad
 ldr x17,[x13,#16]
 subs x17,x17,x16
 b.vs .Lp_view_bad
 b.mi .Lp_view_bad
 adds x17,x17,#1
 b.cs .Lp_view_bad
 cmp w14,#0
 csel x6,x3,x4,eq
 cmp w14,#2
 csel x6,x5,x6,eq
 cbz x6,.Lp_view_extent_ready
 cmp x17,x6
 b.ne .Lp_view_bad
.Lp_view_extent_ready:
 cmp w14,#1
 csel x8,x17,x8,eq
 mul x6,x15,x16
 adds x12,x12,x6
 b.cs .Lp_view_bad
 umulh x6,x11,x17
 cbnz x6,.Lp_view_bad
 mul x11,x11,x17
 add x13,x13,#24
 add w14,w14,#1
 cmp w14,w1
 b.lo .Lp_view_axis
 ldr x6,[x9,#8]
 add x6,x6,x12
 cbnz x6,.Lp_view_bad
 umulh x6,x11,x2
 cbnz x6,.Lp_view_bad
 mul x1,x11,x2
 adds x6,x10,x1
 b.cs .Lp_view_bad
 mov x0,x10
 mov x2,x8
 ret
.Lp_view_bad:
 mov x0,#0
 ret
.section .rodata
.p2align 3
.Lp_thousand: .double 1000.0
.p2align 2
.Lp_profiles:
 .word 1622464,1622528,1622592,1622656
 .word 1610208,1610272,1610336,1610400,1610464
.Lp_tables:
 .word 1529792,1529880,1530192,1530280,1530704,1530792
 .word 1530880,1531304,1531392,1531480,1531680
.Lp_coefficients:
 // Model-relative descriptor,rank,elementbytes,type,extents1,2,3.
 .word 4111704,1,4,1,12,0,0
 .word 4111768,1,4,1,12,0,0
 .word 4111832,2,8,3,14,18,0
 .word 4112360,3,8,3,14,12,13
 .word 4113832,1,8,3,12,0,0
.section .note.GNU-stack,"",%progbits
