/* Direct complete selected longwave cloudy-column transport.
 * Physics is formulations/openifs/radiation/longwave_cloud_transport.md, equations P01 to P03.
 * Ordered rules are in skills/md2asm/references/openifs/radiation/longwave_cloud_transport.md.
 * Sixteen ordinary addresses use the Arm ABI. All children are private assembly.
 * The 2048-byte frame preserves x18, x19 to x30 and saved vector portions.
 * Private outputs are committed only after every selected column completes. */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __radiation_mcica_lw_MOD_solver_mcica_lw
#endif
.text
.p2align 2
.macro LWCOUNT index
 adrp x8,.Lmcica_lw_counts
 add x8,x8,:lo12:.Lmcica_lw_counts
 ldr x9,[x8,#(\index*8)]
 add x9,x9,#1
 str x9,[x8,#(\index*8)]
.endm
.global ORIGINAL_SYMBOL
.global md2asm_solver_mcica_lw
.type md2asm_solver_mcica_lw,%function
ORIGINAL_SYMBOL:
md2asm_solver_mcica_lw:
 mov x17,sp
 sub sp,sp,#2048
 stp x19,x20,[sp,#96]
 stp x21,x22,[sp,#112]
 stp x23,x24,[sp,#128]
 stp x25,x26,[sp,#144]
 stp x27,x28,[sp,#160]
 stp x29,x30,[sp,#176]
 stp d8,d9,[sp,#192]
 stp d10,d11,[sp,#208]
 stp d12,d13,[sp,#224]
 stp d14,d15,[sp,#240]
 mov x29,sp
 str x18,[x29,#1680]
 stp x0,x1,[x29,#256]
 stp x2,x3,[x29,#272]
 stp x4,x5,[x29,#288]
 stp x6,x7,[x29,#304]
 ldp x8,x9,[x17]
 stp x8,x9,[x29,#320]
 ldp x8,x9,[x17,#16]
 stp x8,x9,[x29,#336]
 ldp x8,x9,[x17,#32]
 stp x8,x9,[x29,#352]
 ldp x8,x9,[x17,#48]
 stp x8,x9,[x29,#368]
 mov x27,x3
 mov x28,x9
 mrs x8,fpcr
 cbnz x8,.Lmcica_lw_reject
 ldr w8,[x0]
 cmp w8,#19
 b.ne .Lmcica_lw_reject
 str w8,[x29,#388]
 ldr w8,[x1]
 cmp w8,#1
 b.ne .Lmcica_lw_reject
 str w8,[x29,#420]
 ldr w20,[x2]
 cmp w20,#8
 b.gt .Lmcica_lw_reject
 cmp w20,#0
 b.lt .Lmcica_lw_reject
 str w20,[x29,#416]
 ldr w8,[x27,#6856]
 cmp w8,#1
 b.ne .Lmcica_lw_reject
 ldr w8,[x27,#608]
 cmp w8,#1
 b.ne .Lmcica_lw_reject
 ldr w8,[x27,#612]
 cbnz w8,.Lmcica_lw_reject
 ldr w8,[x27,#7952]
 cmp w8,#1
 b.ne .Lmcica_lw_reject
 ldr w8,[x27,#536]
 cmp w8,#1
 b.ne .Lmcica_lw_reject
 ldr w8,[x27,#540]
 cbnz w8,.Lmcica_lw_reject
 mov x8,#20000
 ldr w9,[x27,x8]
 cmp w9,#140
 b.ne .Lmcica_lw_reject
 str w9,[x29,#384]
 mov x8,#20008
 ldr w9,[x27,x8]
 cmp w9,#16
 b.ne .Lmcica_lw_reject
 mov x8,#20020
 ldr w9,[x27,x8]
 cmp w9,#140
 b.ne .Lmcica_lw_reject
 mov x8,#20024
 ldr w9,[x27,x8]
 cmp w9,#16
 b.ne .Lmcica_lw_reject
 ldr x8,[x27,#520]
 ldr x9,.Lmcica_lw_threshold_bits
 cmp x8,x9
 b.ne .Lmcica_lw_reject
 ldr x8,[x27,#552]
 mov x9,#0x3fe0000000000000
 cmp x8,x9
 b.ne .Lmcica_lw_reject
 cbz w20,.Lmcica_lw_return
 ldr x0,[x29,#280]
 mov x8,#10864
 add x0,x0,x8
 mov x1,#140
 mov x2,#0
 mov x3,#1
 mov x4,#4
 bl .Lmcica_lw_descriptor_guard
 ldr x0,[x29,#288]
 mov x8,#552
 add x0,x0,x8
 mov x1,#8
 mov x2,#0
 mov x3,#1
 mov x4,#4
 bl .Lmcica_lw_descriptor_guard
 ldr x0,[x29,#296]
 mov x8,#352
 add x0,x0,x8
 mov x1,#8
 mov x2,#19
 mov x3,#2
 mov x4,#8
 bl .Lmcica_lw_descriptor_guard
 ldr x0,[x29,#296]
 mov x8,#440
 add x0,x0,x8
 mov x1,#8
 mov x2,#19
 mov x3,#2
 mov x4,#8
 bl .Lmcica_lw_descriptor_guard
 ldr x0,[x29,#296]
 mov x8,#704
 add x0,x0,x8
 mov x1,#8
 mov x2,#18
 mov x3,#2
 mov x4,#8
 bl .Lmcica_lw_descriptor_guard
 mov x8,#0
 add x0,x28,x8
 mov x1,#8
 mov x2,#20
 mov x3,#2
 mov x4,#8
 bl .Lmcica_lw_descriptor_guard
 mov x8,#0
 ldr x9,[x28,x8]
 str x9,[x29,#680]
 mov x8,#88
 add x0,x28,x8
 mov x1,#8
 mov x2,#20
 mov x3,#2
 mov x4,#8
 bl .Lmcica_lw_descriptor_guard
 mov x8,#88
 ldr x9,[x28,x8]
 str x9,[x29,#688]
 mov x8,#440
 add x0,x28,x8
 mov x1,#8
 mov x2,#20
 mov x3,#2
 mov x4,#8
 bl .Lmcica_lw_descriptor_guard
 mov x8,#440
 ldr x9,[x28,x8]
 str x9,[x29,#696]
 mov x8,#528
 add x0,x28,x8
 mov x1,#8
 mov x2,#20
 mov x3,#2
 mov x4,#8
 bl .Lmcica_lw_descriptor_guard
 mov x8,#528
 ldr x9,[x28,x8]
 str x9,[x29,#704]
 mov x8,#2000
 add x0,x28,x8
 mov x1,#140
 mov x2,#8
 mov x3,#2
 mov x4,#8
 bl .Lmcica_lw_descriptor_guard
 mov x8,#2000
 ldr x9,[x28,x8]
 str x9,[x29,#712]
 mov x8,#2088
 add x0,x28,x8
 mov x1,#140
 mov x2,#8
 mov x3,#2
 mov x4,#8
 bl .Lmcica_lw_descriptor_guard
 mov x8,#2088
 ldr x9,[x28,x8]
 str x9,[x29,#720]
 mov x8,#3144
 add x0,x28,x8
 mov x1,#8
 mov x2,#0
 mov x3,#1
 mov x4,#8
 bl .Lmcica_lw_descriptor_guard
 mov x8,#3144
 ldr x9,[x28,x8]
 str x9,[x29,#728]
 mov x8,#3272
 add x0,x28,x8
 mov x1,#8
 mov x2,#20
 mov x3,#2
 mov x4,#8
 bl .Lmcica_lw_descriptor_guard
 mov x8,#3272
 ldr x9,[x28,x8]
 str x9,[x29,#736]
 ldr x8,[x27,#10864]
 mov x9,#0
.Lmcica_lw_band_guard:
 ldr w10,[x8,x9,lsl #2]
 sub w10,w10,#1
 cmp w10,#15
 b.hi .Lmcica_lw_reject
 add x9,x9,#1
 cmp x9,#140
 b.lt .Lmcica_lw_band_guard
 mov x0,#0xc3a0
 movk x0,#4,lsl #16
 bl malloc
 cbz x0,.Lmcica_lw_reject
 str x0,[x29,#1712]
 mov x8,x0
 str x8,[x29,#448]
 mov x9,#21280
 add x8,x8,x9
 str x8,[x29,#456]
 mov x9,#21280
 add x8,x8,x9
 str x8,[x29,#464]
 mov x9,#21280
 add x8,x8,x9
 str x8,[x29,#472]
 mov x9,#21280
 add x8,x8,x9
 str x8,[x29,#480]
 mov x9,#21280
 add x8,x8,x9
 str x8,[x29,#488]
 mov x9,#21280
 add x8,x8,x9
 str x8,[x29,#496]
 mov x9,#21280
 add x8,x8,x9
 str x8,[x29,#504]
 mov x9,#21280
 add x8,x8,x9
 str x8,[x29,#512]
 mov x9,#22400
 add x8,x8,x9
 str x8,[x29,#520]
 mov x9,#22400
 add x8,x8,x9
 str x8,[x29,#528]
 mov x9,#22400
 add x8,x8,x9
 str x8,[x29,#536]
 mov x9,#22400
 add x8,x8,x9
 str x8,[x29,#544]
 mov x9,#21280
 add x8,x8,x9
 str x8,[x29,#552]
 mov x9,#1120
 add x8,x8,x9
 str x8,[x29,#560]
 mov x9,#1120
 add x8,x8,x9
 str x8,[x29,#568]
 mov x9,#1120
 add x8,x8,x9
 str x8,[x29,#576]
 mov x9,#1120
 add x8,x8,x9
 str x8,[x29,#584]
 mov x9,#1120
 add x8,x8,x9
 str x8,[x29,#592]
 mov x9,#1120
 add x8,x8,x9
 str x8,[x29,#616]
 mov x9,#1280
 add x8,x8,x9
 str x8,[x29,#624]
 mov x9,#1280
 add x8,x8,x9
 str x8,[x29,#632]
 mov x9,#1280
 add x8,x8,x9
 str x8,[x29,#640]
 mov x9,#1280
 add x8,x8,x9
 str x8,[x29,#648]
 mov x9,#8960
 add x8,x8,x9
 str x8,[x29,#656]
 mov x9,#8960
 add x8,x8,x9
 str x8,[x29,#664]
 mov x9,#64
 add x8,x8,x9
 str x8,[x29,#672]
 mov x9,#1280
 add x8,x8,x9
 ldr x0,[x29,#616]
 ldr x1,[x29,#680]
 mov x2,#1280
 bl .Lmcica_lw_copy
 ldr x0,[x29,#624]
 ldr x1,[x29,#688]
 mov x2,#1280
 bl .Lmcica_lw_copy
 ldr x0,[x29,#632]
 ldr x1,[x29,#696]
 mov x2,#1280
 bl .Lmcica_lw_copy
 ldr x0,[x29,#640]
 ldr x1,[x29,#704]
 mov x2,#1280
 bl .Lmcica_lw_copy
 ldr x0,[x29,#648]
 ldr x1,[x29,#712]
 mov x2,#8960
 bl .Lmcica_lw_copy
 ldr x0,[x29,#656]
 ldr x1,[x29,#720]
 mov x2,#8960
 bl .Lmcica_lw_copy
 ldr x0,[x29,#664]
 ldr x1,[x29,#728]
 mov x2,#64
 bl .Lmcica_lw_copy
 ldr x0,[x29,#672]
 ldr x1,[x29,#736]
 mov x2,#1280
 bl .Lmcica_lw_copy
 add x0,x29,#768
 ldr x1,[x29,#560]
 bl .Lmcica_lw_make_rank1
 add x0,x29,#832
 ldr x1,[x29,#568]
 bl .Lmcica_lw_make_rank1
 add x0,x29,#896
 ldr x1,[x29,#576]
 bl .Lmcica_lw_make_rank1
 add x0,x29,#960
 ldr x1,[x29,#584]
 bl .Lmcica_lw_make_rank1
 add x0,x29,#1024
 mov x8,#3272
 add x1,x28,x8
 mov x2,#88
 bl .Lmcica_lw_copy
 ldr x8,[x29,#672]
 str x8,[x29,#1024]
 mov w21,#1

.Lmcica_lw_column:
 str w21,[x29,#392]
 sub w8,w21,#1
 mov x9,#21280
 mul x10,x8,x9
 ldr x24,[x29,#304]
 add x24,x24,x10
 mov x9,#22400
 mul x10,x8,x9
 ldr x25,[x29,#352]
 add x25,x25,x10
 mov x9,#2432
 mul x10,x8,x9
 ldr x26,[x29,#328]
 add x26,x26,x10
 ldr x0,[x29,#448]
 mov x1,#21280
 bl .Lmcica_lw_zero
 mov w22,#0
.Lmcica_lw_clear_layer:
 mov x8,#1120
 mul x9,x22,x8
 add x0,x29,#384
 add x1,x24,x9
 add x2,x25,x9
 add x3,x2,#1120
 ldr x4,[x29,#456]
 add x4,x4,x9
 ldr x5,[x29,#464]
 add x5,x5,x9
 ldr x6,[x29,#472]
 add x6,x6,x9
 bl md2asm_mcica_lw_clear_layer
 LWCOUNT 0
 add w22,w22,#1
 cmp w22,#19
 b.lt .Lmcica_lw_clear_layer
 add x0,x29,#384
 add x1,x29,#388
 ldr x2,[x29,#456]
 ldr x3,[x29,#464]
 ldr x4,[x29,#472]
 sub w8,w21,#1
 mov x9,#1120
 mul x8,x8,x9
 ldr x5,[x29,#360]
 add x5,x5,x8
 ldr x6,[x29,#368]
 add x6,x6,x8
 ldr x7,[x29,#528]
 ldr x9,[x29,#536]
 str x9,[sp]
 bl md2asm_mcica_lw_clear_fluxes
 LWCOUNT 1
 sub w8,w21,#1
 ldr x0,[x29,#528]
 ldr x1,[x29,#632]
 add x1,x1,x8,lsl #3
 bl .Lmcica_lw_sum_profile
 sub w8,w21,#1
 ldr x0,[x29,#536]
 ldr x1,[x29,#640]
 add x1,x1,x8,lsl #3
 bl .Lmcica_lw_sum_profile
 sub w8,w21,#1
 mov x9,#1120
 mul x8,x8,x9
 ldr x0,[x29,#656]
 add x0,x0,x8
 ldr x1,[x29,#536]
 mov x9,#21280
 add x1,x1,x9
 mov x2,#1120
 bl .Lmcica_lw_copy
 ldr x8,[x29,#296]
 ldr x9,[x8,#352]
 ldr x10,[x8,#440]
 ldr x11,[x8,#704]
 sub w8,w21,#1
 add x9,x9,x8,lsl #3
 add x10,x10,x8,lsl #3
 add x11,x11,x8,lsl #3
 add x12,x29,#1128
 add x13,x29,#1280
 add x14,x29,#1432
 mov x15,#0
.Lmcica_lw_cloud_rows:
 ldr d0,[x9]
 ldr d1,[x10]
 str d0,[x12,x15,lsl #3]
 str d1,[x13,x15,lsl #3]
 cmp x15,#18
 b.eq .Lmcica_lw_cloud_row_no_overlap
 ldr d0,[x11]
 str d0,[x14,x15,lsl #3]
 add x11,x11,#64
.Lmcica_lw_cloud_row_no_overlap:
 add x9,x9,#64
 add x10,x10,#64
 add x15,x15,#1
 cmp x15,#19
 b.lt .Lmcica_lw_cloud_rows
 ldr x8,[x29,#288]
 ldr x8,[x8,#552]
 sub w9,w21,#1
 ldr w8,[x8,x9,lsl #2]
 add w8,w8,#997
 str w8,[x29,#396]
 add x0,x29,#384
 add x1,x29,#388
 add x2,x27,#536
 add x3,x29,#396
 add x4,x27,#520
 add x5,x29,#1128
 add x6,x29,#1432
 add x7,x27,#552
 add x8,x29,#1280
 mov x9,#17840
 add x9,x27,x9
 stp x8,x9,[sp]
 ldr x8,[x29,#544]
 add x9,x29,#400
 stp x8,x9,[sp,#16]
 add x8,x27,#540
 str x8,[sp,#32]
 bl md2asm_mcica_lw_cloud_generator
 LWCOUNT 2
 ldr d0,[x29,#400]
 ldr x8,[x29,#664]
 sub w9,w21,#1
 str d0,[x8,x9,lsl #3]
 ldr d1,[x27,#520]
 fcmp d0,d1
 b.lt .Lmcica_lw_unclouded
 fmov d1,#1.0
 fsub d1,d1,d0
 str d1,[x29,#408]
 mov w8,#20
 str w8,[x29,#424]
 add x8,x29,#1576
 mov x9,#0
 mov w10,#1
.Lmcica_lw_clear_flags:
 str w10,[x8,x9,lsl #2]
 add x9,x9,#1
 cmp x9,#19
 b.lt .Lmcica_lw_clear_flags
 mov w22,#0
.Lmcica_lw_cloud_layer:
 add x8,x29,#1128
 ldr d0,[x8,x22,lsl #3]
 ldr d1,[x27,#520]
 fcmp d0,d1
 b.lt .Lmcica_lw_copy_clear_layer
 add x8,x29,#1576
 str wzr,[x8,x22,lsl #2]
 add w8,w22,#1
 ldr w9,[x29,#424]
 cmp w9,w8
 csel w9,w8,w9,gt
 str w9,[x29,#424]
 mov x8,#1120
 mul x23,x22,x8
 ldr x8,[x29,#544]
 add x8,x8,x23
 ldr x9,[x27,#10864]
 ldr x10,[x29,#552]
 ldr x11,[x29,#560]
 ldr x12,[x29,#568]
 ldr x13,[x29,#592]
 mov x14,#0
.Lmcica_lw_mix_point:
 ldr w15,[x9,x14,lsl #2]
 sub w15,w15,#1
 add x16,x26,x22,lsl #7
 ldr d0,[x16,x15,lsl #3]
 ldr d1,[x8,x14,lsl #3]
 fmul d0,d1,d0
 str d0,[x13,x14,lsl #3]
 add x16,x24,x23
 ldr d1,[x16,x14,lsl #3]
 fadd d1,d1,d0
 str d1,[x10,x14,lsl #3]
 fmov d2,xzr
 fmov d3,xzr
 fcmp d1,#0.0
 b.le .Lmcica_lw_mix_no_scattering
 sub w16,w21,#1
 mov x17,#2432
 mul x16,x16,x17
 add x16,x16,x22,lsl #7
 ldr x17,[x29,#336]
 add x17,x17,x16
 ldr d4,[x17,x15,lsl #3]
 fmul d5,d4,d0
 fdiv d2,d5,d1
 fmul d5,d2,d1
 fcmp d5,#0.0
 b.le .Lmcica_lw_mix_no_scattering
 ldr x17,[x29,#344]
 add x17,x17,x16
 ldr d3,[x17,x15,lsl #3]
 fmul d3,d3,d4
 fmul d3,d3,d0
 fdiv d3,d3,d5
.Lmcica_lw_mix_no_scattering:
 str d2,[x11,x14,lsl #3]
 str d3,[x12,x14,lsl #3]
 add x14,x14,#1
 cmp x14,#140
 b.lt .Lmcica_lw_mix_point
 add x0,x29,#384
 add x1,x29,#768
 add x2,x29,#832
 add x3,x29,#896
 add x4,x29,#960
 bl md2asm_mcica_lw_gammas
 LWCOUNT 3
 add x0,x29,#384
 ldr x1,[x29,#552]
 ldr x2,[x29,#576]
 ldr x3,[x29,#584]
 add x4,x25,x23
 add x5,x4,#1120
 ldr x6,[x29,#480]
 add x6,x6,x23
 ldr x7,[x29,#488]
 add x7,x7,x23
 ldr x8,[x29,#496]
 add x8,x8,x23
 ldr x9,[x29,#504]
 add x9,x9,x23
 stp x8,x9,[sp]
 bl md2asm_mcica_lw_layer
 LWCOUNT 4
 b .Lmcica_lw_cloud_layer_next
.Lmcica_lw_copy_clear_layer:
 mov x8,#1120
 mul x23,x22,x8
 ldr x0,[x29,#480]
 add x0,x0,x23
 ldr x1,[x29,#448]
 add x1,x1,x23
 mov x2,#1120
 bl .Lmcica_lw_copy
 ldr x0,[x29,#488]
 add x0,x0,x23
 ldr x1,[x29,#456]
 add x1,x1,x23
 mov x2,#1120
 bl .Lmcica_lw_copy
 ldr x0,[x29,#496]
 add x0,x0,x23
 ldr x1,[x29,#464]
 add x1,x1,x23
 mov x2,#1120
 bl .Lmcica_lw_copy
 ldr x0,[x29,#504]
 add x0,x0,x23
 ldr x1,[x29,#472]
 add x1,x1,x23
 mov x2,#1120
 bl .Lmcica_lw_copy
.Lmcica_lw_cloud_layer_next:
 add w22,w22,#1
 cmp w22,#19
 b.lt .Lmcica_lw_cloud_layer
 add x0,x29,#384
 add x1,x29,#388
 ldr x2,[x29,#480]
 ldr x3,[x29,#488]
 ldr x4,[x29,#496]
 ldr x5,[x29,#504]
 sub w8,w21,#1
 mov x9,#1120
 mul x8,x8,x9
 ldr x6,[x29,#360]
 add x6,x6,x8
 ldr x7,[x29,#368]
 add x7,x7,x8
 add x8,x29,#1576
 add x9,x29,#424
 stp x8,x9,[sp]
 ldr x8,[x29,#536]
 ldr x9,[x29,#512]
 stp x8,x9,[sp,#16]
 ldr x8,[x29,#520]
 str x8,[sp,#32]
 bl md2asm_mcica_lw_fast_fluxes
 LWCOUNT 5
 sub w8,w21,#1
 ldr x0,[x29,#512]
 ldr x1,[x29,#616]
 add x1,x1,x8,lsl #3
 bl .Lmcica_lw_sum_profile
 sub w8,w21,#1
 ldr x0,[x29,#520]
 ldr x1,[x29,#624]
 add x1,x1,x8,lsl #3
 bl .Lmcica_lw_sum_profile
 sub w8,w21,#1
 ldr x9,[x29,#616]
 add x9,x9,x8,lsl #3
 ldr x10,[x29,#624]
 add x10,x10,x8,lsl #3
 ldr x11,[x29,#632]
 add x11,x11,x8,lsl #3
 ldr x12,[x29,#640]
 add x12,x12,x8,lsl #3
 ldr d4,[x29,#400]
 ldr d5,[x29,#408]
 mov x13,#0
.Lmcica_lw_weight_profile:
 ldr d0,[x9]
 ldr d1,[x11]
 fmul d0,d4,d0
 fmul d1,d5,d1
 fadd d0,d0,d1
 str d0,[x9]
 ldr d0,[x10]
 ldr d1,[x12]
 fmul d0,d4,d0
 fmul d1,d5,d1
 fadd d0,d0,d1
 str d0,[x10]
 add x9,x9,#64
 add x10,x10,#64
 add x11,x11,#64
 add x12,x12,#64
 add x13,x13,#1
 cmp x13,#20
 b.lt .Lmcica_lw_weight_profile
 sub w8,w21,#1
 mov x9,#1120
 mul x8,x8,x9
 ldr x9,[x29,#648]
 add x9,x9,x8
 ldr x10,[x29,#656]
 add x10,x10,x8
 ldr x11,[x29,#520]
 mov x8,#21280
 add x11,x11,x8
 mov x12,#0
.Lmcica_lw_weight_surface:
 ldr d0,[x11,x12,lsl #3]
 ldr d1,[x10,x12,lsl #3]
 fmul d0,d4,d0
 fmul d1,d5,d1
 fadd d0,d0,d1
 str d0,[x9,x12,lsl #3]
 add x12,x12,#1
 cmp x12,#140
 b.lt .Lmcica_lw_weight_surface
 add x0,x29,#384
 add x1,x29,#388
 add x2,x29,#392
 ldr x3,[x29,#488]
 ldr x4,[x29,#512]
 mov x8,#21280
 add x4,x4,x8
 add x5,x29,#1024
 bl md2asm_mcica_lw_calc_derivatives
 LWCOUNT 6
 ldr d0,[x29,#400]
 ldr d1,[x27,#520]
 fmov d2,#1.0
 fsub d2,d2,d1
 fcmp d0,d2
 b.ge .Lmcica_lw_column_next
 add x0,x29,#384
 add x1,x29,#388
 add x2,x29,#392
 ldr x3,[x29,#456]
 ldr x4,[x29,#528]
 mov x8,#21280
 add x4,x4,x8
 add x5,x29,#408
 add x6,x29,#1024
 bl md2asm_mcica_lw_modify_derivatives
 LWCOUNT 7
 b .Lmcica_lw_column_next
.Lmcica_lw_unclouded:
 sub w8,w21,#1
 ldr x0,[x29,#616]
 add x0,x0,x8,lsl #3
 ldr x1,[x29,#632]
 add x1,x1,x8,lsl #3
 bl .Lmcica_lw_copy_profile
 sub w8,w21,#1
 ldr x0,[x29,#624]
 add x0,x0,x8,lsl #3
 ldr x1,[x29,#640]
 add x1,x1,x8,lsl #3
 bl .Lmcica_lw_copy_profile
 sub w8,w21,#1
 mov x9,#1120
 mul x8,x8,x9
 ldr x0,[x29,#648]
 add x0,x0,x8
 ldr x1,[x29,#656]
 add x1,x1,x8
 mov x2,#1120
 bl .Lmcica_lw_copy
 add x0,x29,#384
 add x1,x29,#388
 add x2,x29,#392
 ldr x3,[x29,#456]
 ldr x4,[x29,#528]
 mov x8,#21280
 add x4,x4,x8
 add x5,x29,#1024
 bl md2asm_mcica_lw_calc_derivatives
 LWCOUNT 6
.Lmcica_lw_column_next:
 add w21,w21,#1
 ldr w8,[x29,#416]
 cmp w21,w8
 b.le .Lmcica_lw_column
 ldr x0,[x29,#680]
 ldr x1,[x29,#616]
 mov x2,#1280
 bl .Lmcica_lw_copy
 ldr x0,[x29,#688]
 ldr x1,[x29,#624]
 mov x2,#1280
 bl .Lmcica_lw_copy
 ldr x0,[x29,#696]
 ldr x1,[x29,#632]
 mov x2,#1280
 bl .Lmcica_lw_copy
 ldr x0,[x29,#704]
 ldr x1,[x29,#640]
 mov x2,#1280
 bl .Lmcica_lw_copy
 ldr x0,[x29,#712]
 ldr x1,[x29,#648]
 mov x2,#8960
 bl .Lmcica_lw_copy
 ldr x0,[x29,#720]
 ldr x1,[x29,#656]
 mov x2,#8960
 bl .Lmcica_lw_copy
 ldr x0,[x29,#728]
 ldr x1,[x29,#664]
 mov x2,#64
 bl .Lmcica_lw_copy
 ldr x0,[x29,#736]
 ldr x1,[x29,#672]
 mov x2,#1280
 bl .Lmcica_lw_copy
 ldr x0,[x29,#1712]
 bl free
.Lmcica_lw_return:
 mov sp,x29
 ldr x18,[sp,#1680]
 ldp d8,d9,[sp,#192]
 ldp d10,d11,[sp,#208]
 ldp d12,d13,[sp,#224]
 ldp d14,d15,[sp,#240]
 ldp x19,x20,[sp,#96]
 ldp x21,x22,[sp,#112]
 ldp x23,x24,[sp,#128]
 ldp x25,x26,[sp,#144]
 ldp x27,x28,[sp,#160]
 ldp x29,x30,[sp,#176]
 add sp,sp,#2048
 ret
.Lmcica_lw_reject:
 bl abort
.size md2asm_solver_mcica_lw,.-md2asm_solver_mcica_lw

.p2align 2
.Lmcica_lw_descriptor_guard:
 ldr x8,[x0]
 cbz x8,.Lmcica_lw_reject
 sub x9,x4,#1
 tst x8,x9
 b.ne .Lmcica_lw_reject
 ldr x8,[x0,#16]
 cmp x8,x4
 b.ne .Lmcica_lw_reject
 ldr w8,[x0,#24]
 cbnz w8,.Lmcica_lw_reject
 ldrb w8,[x0,#28]
 cmp w8,w3
 b.ne .Lmcica_lw_reject
 ldrb w8,[x0,#29]
 cmp x4,#4
 mov w9,#1
 mov w10,#3
 csel w9,w9,w10,eq
 cmp w8,w9
 b.ne .Lmcica_lw_reject
 ldr x8,[x0,#32]
 cmp x8,x4
 b.ne .Lmcica_lw_reject
 ldr x8,[x0,#40]
 cmp x8,#1
 b.ne .Lmcica_lw_reject
 ldr x8,[x0,#48]
 cmp x8,#1
 b.ne .Lmcica_lw_reject
 ldr x8,[x0,#56]
 cmp x8,x1
 b.ne .Lmcica_lw_reject
 cmp x3,#1
 b.eq .Lmcica_lw_descriptor_rank1
 ldr x8,[x0,#64]
 cmp x8,x1
 b.ne .Lmcica_lw_reject
 ldr x8,[x0,#72]
 cmp x8,#1
 b.ne .Lmcica_lw_reject
 ldr x8,[x0,#80]
 cmp x8,x2
 b.ne .Lmcica_lw_reject
 add x8,x1,#1
 neg x8,x8
 b .Lmcica_lw_descriptor_offset
.Lmcica_lw_descriptor_rank1:
 mov x8,#-1
.Lmcica_lw_descriptor_offset:
 ldr x9,[x0,#8]
 cmp x8,x9
 b.ne .Lmcica_lw_reject
 ret

.p2align 2
.Lmcica_lw_make_rank1:
 str x1,[x0]
 mov x8,#-1
 str x8,[x0,#8]
 mov x8,#8
 str x8,[x0,#16]
 str wzr,[x0,#24]
 mov w8,#0x301
 str w8,[x0,#28]
 mov x8,#8
 str x8,[x0,#32]
 mov x8,#1
 str x8,[x0,#40]
 str x8,[x0,#48]
 mov x8,#140
 str x8,[x0,#56]
 ret

.p2align 2
.Lmcica_lw_copy:
 cmp x2,#16
 b.lt .Lmcica_lw_copy_tail
.Lmcica_lw_copy_block:
 ldr q0,[x1],#16
 str q0,[x0],#16
 sub x2,x2,#16
 cmp x2,#16
 b.ge .Lmcica_lw_copy_block
.Lmcica_lw_copy_tail:
 cbz x2,.Lmcica_lw_copy_done
 ldr x3,[x1]
 str x3,[x0]
.Lmcica_lw_copy_done:
 ret

.p2align 2
.Lmcica_lw_zero:
 str xzr,[x0],#8
 subs x1,x1,#8
 b.ne .Lmcica_lw_zero
 ret

.p2align 2
.Lmcica_lw_sum_profile:
 mov x2,#0
.Lmcica_lw_sum_boundary:
 fmov d0,xzr
 fmov d2,xzr
 fmov d4,xzr
 fmov d6,xzr
 mov x3,#0
.Lmcica_lw_sum_point:
 ldr d1,[x0]
 ldr d3,[x0,#1120]
 ldr d5,[x0,#2240]
 ldr d7,[x0,#3360]
 fadd d0,d0,d1
 fadd d2,d2,d3
 fadd d4,d4,d5
 fadd d6,d6,d7
 add x0,x0,#8
 add x3,x3,#1
 cmp x3,#140
 b.lt .Lmcica_lw_sum_point
 str d0,[x1]
 str d2,[x1,#64]
 str d4,[x1,#128]
 str d6,[x1,#192]
 add x0,x0,#3360
 add x1,x1,#256
 add x2,x2,#4
 cmp x2,#20
 b.lt .Lmcica_lw_sum_boundary
 ret

.p2align 2
.Lmcica_lw_copy_profile:
 mov x2,#0
.Lmcica_lw_copy_boundary:
 ldr x3,[x1]
 str x3,[x0]
 add x0,x0,#64
 add x1,x1,#64
 add x2,x2,#1
 cmp x2,#20
 b.lt .Lmcica_lw_copy_boundary
 ret

.p2align 2
.global md2asm_mcica_lw_child_count_get
.type md2asm_mcica_lw_child_count_get,%function
md2asm_mcica_lw_child_count_get:
 cmp w0,#8
 b.hs .Lmcica_lw_counter_zero
 adrp x1,.Lmcica_lw_counts
 add x1,x1,:lo12:.Lmcica_lw_counts
 ldr x0,[x1,x0,lsl #3]
 ret
.Lmcica_lw_counter_zero:
 mov x0,#0
 ret
.size md2asm_mcica_lw_child_count_get,.-md2asm_mcica_lw_child_count_get
.section .rodata
.p2align 3
.Lmcica_lw_threshold_bits:
 .quad 0x3eb0c6f7a0b5ed8d
.bss
.p2align 3
.Lmcica_lw_counts:
 .zero 64
.section .note.GNU-stack,"",%progbits
