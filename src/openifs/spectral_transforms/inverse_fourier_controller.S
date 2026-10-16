/* Source build for the qualified private forecast graph.
 * Contract: skills/md2asm/references/openifs/dynamics/private_forecast_graph_sources.md.
 * Preserve the original interface, ordered arithmetic, and caller-owned storage. */
// Complete selected Fourier controller, from the frozen local contract.
// Physical operations belong to accepted direct children. This body owns every
// work array, view, integer field map, latitude loop and persistent buffer update.
.text
.p2align 4
.macro ARG reg,index
 ldr \reg,[x19,#(8*\index)]
.endm
.macro CALL target
 str x18,[sp,#360]
 bl \target
 ldr x18,[sp,#360]
.endm
.macro PLACE index
 .if \index<8
  mov x\index,x9
 .else
  str x9,[sp,#((\index-8)*8)]
 .endif
.endm
.macro STAT section,event
 mov w9,#\section
 str w9,[sp,#436]
 mov w9,#\event
 str w9,[sp,#440]
 add x0,sp,#436
 add x1,sp,#440
 CALL gstats_
.endm
.global md2asm_ftinv_ctl_7358525
.type md2asm_ftinv_ctl_7358525,%function
md2asm_ftinv_ctl_7358525:
 mov x16,sp
 sub sp,sp,#4096
 add x17,sp,#256
 stp x19,x20,[x17]
 stp x21,x22,[x17,#16]
 stp x23,x24,[x17,#32]
 stp x25,x26,[x17,#48]
 stp x27,x28,[x17,#64]
 stp x29,x30,[x17,#80]
 str x18,[sp,#352]
 add x19,sp,#512
 stp x0,x1,[x19]
 stp x2,x3,[x19,#16]
 stp x4,x5,[x19,#32]
 stp x6,x7,[x19,#48]
 mov x10,#8
.Lftinv_ctl_arguments:
 ldr x9,[x16],#8
 str x9,[x19,x10,lsl #3]
 add x10,x10,#1
 cmp x10,#19
 b.lt .Lftinv_ctl_arguments
 mrs x9,fpcr
 cbnz x9,.Lftinv_ctl_reject
 ARG x9,0
 ldr w10,[x9]
 cmp w10,#0
 b.lt .Lftinv_ctl_reject
 cmp w10,#136
 b.gt .Lftinv_ctl_reject
 str w10,[sp,#400]
 ARG x9,1
 ldr w10,[x9]
 cmp w10,#0
 b.lt .Lftinv_ctl_reject
 cmp w10,#136
 b.gt .Lftinv_ctl_reject
 str w10,[sp,#404]
 ARG x9,2
 ldr w10,[x9]
 cmp w10,#0
 b.lt .Lftinv_ctl_reject
 cmp w10,#136
 b.gt .Lftinv_ctl_reject
 str w10,[sp,#408]
 ARG x9,3
 ldr w10,[x9]
 cmp w10,#0
 b.lt .Lftinv_ctl_reject
 cmp w10,#136
 b.gt .Lftinv_ctl_reject
 str w10,[sp,#412]
 ARG x9,4
 ldr w10,[x9]
 cmp w10,#0
 b.lt .Lftinv_ctl_reject
 cmp w10,#136
 b.gt .Lftinv_ctl_reject
 str w10,[sp,#416]
 ARG x9,5
 ldr w10,[x9]
 cmp w10,#0
 b.lt .Lftinv_ctl_reject
 cmp w10,#136
 b.gt .Lftinv_ctl_reject
 str w10,[sp,#420]
 ARG x9,6
 ldr w10,[x9]
 cmp w10,#0
 b.lt .Lftinv_ctl_reject
 cmp w10,#136
 b.gt .Lftinv_ctl_reject
 str w10,[sp,#424]
 ARG x9,7
 ldr w10,[x9]
 cmp w10,#0
 b.lt .Lftinv_ctl_reject
 cmp w10,#136
 b.gt .Lftinv_ctl_reject
 str w10,[sp,#428]
 adrp x9,:got:__tpm_distr_MOD_nproc
 ldr x9,[x9,:got_lo12:__tpm_distr_MOD_nproc]
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lftinv_ctl_reject
 adrp x9,:got:__tpm_distr_MOD_myproc
 ldr x9,[x9,:got_lo12:__tpm_distr_MOD_myproc]
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lftinv_ctl_reject
 adrp x9,:got:__tpm_distr_MOD_d
 ldr x9,[x9,:got_lo12:__tpm_distr_MOD_d]
 ldr x21,[x9]
 cbz x21,.Lftinv_ctl_reject
 ldr w9,[x21,#992]
 cmp w9,#32
 b.ne .Lftinv_ctl_reject
 ldr w9,[x21,#1064]
 cmp w9,#2144
 b.ne .Lftinv_ctl_reject
 adrp x9,:got:__tpm_trans_MOD_latlon
 ldr x9,[x9,:got_lo12:__tpm_trans_MOD_latlon]
 ldr w10,[x9]
 cmp w10,#1
 b.hi .Lftinv_ctl_reject
 str w10,[sp,#368]
 adrp x9,:got:__tpm_trans_MOD_luvder
 ldr x9,[x9,:got_lo12:__tpm_trans_MOD_luvder]
 ldr w10,[x9]
 cmp w10,#1
 b.hi .Lftinv_ctl_reject
 str w10,[sp,#372]
 adrp x9,:got:__tpm_trans_MOD_lvorgp
 ldr x9,[x9,:got_lo12:__tpm_trans_MOD_lvorgp]
 ldr w10,[x9]
 cmp w10,#1
 b.hi .Lftinv_ctl_reject
 str w10,[sp,#376]
 adrp x9,:got:__tpm_trans_MOD_ldivgp
 ldr x9,[x9,:got_lo12:__tpm_trans_MOD_ldivgp]
 ldr w10,[x9]
 cmp w10,#1
 b.hi .Lftinv_ctl_reject
 str w10,[sp,#380]
 adrp x9,:got:__tpm_trans_MOD_lscders
 ldr x9,[x9,:got_lo12:__tpm_trans_MOD_lscders]
 ldr w10,[x9]
 cmp w10,#1
 b.hi .Lftinv_ctl_reject
 str w10,[sp,#384]
 ldr w9,[sp,#368]
 cbnz w9,.Lftinv_ctl_reject
 ldr w9,[sp,#372]
 cbnz w9,.Lftinv_ctl_reject
 ldr w9,[sp,#400]
 ldr w10,[sp,#408]
 cmp w9,w10
 b.ne .Lftinv_ctl_reject
 ldr w9,[sp,#404]
 ldr w10,[sp,#412]
 cmp w9,w10
 b.ne .Lftinv_ctl_reject
 ldr w9,[sp,#416]
 cbz w9,.Lftinv_ctl_derivatives_valid
 cmp w9,w10
 b.ne .Lftinv_ctl_reject
.Lftinv_ctl_derivatives_valid:
 ldr w20,[sp,#424]
 ldr w9,[sp,#428]
 ldr w10,[sp,#416]
 add w9,w9,w10
 cmp w9,w20
 b.ne .Lftinv_ctl_reject
 mov x9,#17152
 mul x0,x20,x9
 cmp x0,#0
 mov x9,#1
 csel x0,x0,x9,ne
 CALL malloc
 cbz x0,.Lftinv_ctl_reject
 mov x22,x0
 str x0,[sp,#448]
 add x0,sp,#704
 mov x1,x22
 mov x2,x20
 mov x3,#2144
 cmp x20,#0
 mov x4,#1
 csel x4,x20,x4,ne
 bl .Lftinv_ctl_make_descriptor
 cbz x20,.Lftinv_ctl_zero_done
 str xzr,[x22]
.Lftinv_ctl_zero_done:
 mov x0,#17152
 CALL malloc
 cbz x0,.Lftinv_ctl_reject
 str x0,[sp,#456]
 add x0,sp,#792
 ldr x1,[sp,#456]
 mov x2,#1
 mov x3,#2144
 mov x4,#1
 bl .Lftinv_ctl_make_descriptor
 add x0,sp,#880
 ldr x1,[sp,#456]
 mov x2,#1
 mov x3,#2144
 mov x4,#1
 bl .Lftinv_ctl_make_descriptor
 add x0,sp,#968
 ldr x1,[sp,#456]
 mov x2,#1
 mov x3,#2144
 mov x4,#1
 bl .Lftinv_ctl_make_descriptor
 add x0,sp,#1056
 ldr x1,[sp,#456]
 mov x2,#1
 mov x3,#2144
 mov x4,#1
 bl .Lftinv_ctl_make_descriptor
 add x0,sp,#1144
 ldr x1,[sp,#456]
 mov x2,#1
 mov x3,#2144
 mov x4,#1
 bl .Lftinv_ctl_make_descriptor
 ldr w9,[sp,#408]
 ldr w10,[sp,#416]
 orr w9,w9,w10
 cbz w9,.Lftinv_ctl_views_done
 mov x24,#0
 ldr w9,[sp,#376]
 ldr w10,[sp,#408]
 madd x24,x9,x10,x24
 ldr w9,[sp,#380]
 madd x24,x9,x10,x24
 ldr w25,[sp,#408]
 lsl x25,x25,#1
 cbz x25,.Lftinv_ctl_view_skip792
 add x26,x24,x25
 cmp x26,x20
 b.gt .Lftinv_ctl_reject
 add x0,sp,#792
 add x1,x22,x24,lsl #3
 mov x2,x25
 mov x3,#2144
 mov x4,x20
 bl .Lftinv_ctl_make_descriptor
.Lftinv_ctl_view_skip792:
 add x24,x24,x25
 ldr w25,[sp,#412]
 cbz x25,.Lftinv_ctl_view_skip880
 add x26,x24,x25
 cmp x26,x20
 b.gt .Lftinv_ctl_reject
 add x0,sp,#880
 add x1,x22,x24,lsl #3
 mov x2,x25
 mov x3,#2144
 mov x4,x20
 bl .Lftinv_ctl_make_descriptor
.Lftinv_ctl_view_skip880:
 add x24,x24,x25
 ldr w25,[sp,#416]
 cbz x25,.Lftinv_ctl_view_skip968
 add x26,x24,x25
 cmp x26,x20
 b.gt .Lftinv_ctl_reject
 add x0,sp,#968
 add x1,x22,x24,lsl #3
 mov x2,x25
 mov x3,#2144
 mov x4,x20
 bl .Lftinv_ctl_make_descriptor
.Lftinv_ctl_view_skip968:
 add x24,x24,x25
 ldr w25,[sp,#416]
 cbz x25,.Lftinv_ctl_view_skip1056
 add x26,x24,x25
 cmp x26,x20
 b.gt .Lftinv_ctl_reject
 add x0,sp,#1056
 add x1,x22,x24,lsl #3
 mov x2,x25
 mov x3,#2144
 mov x4,x20
 bl .Lftinv_ctl_make_descriptor
.Lftinv_ctl_view_skip1056:
 add x24,x24,x25
.Lftinv_ctl_views_done:
 STAT 107,0
 STAT 1639,0
 mov x23,#1
.Lftinv_ctl_row:
 str w23,[sp,#432]
 add x0,sp,#704
 ARG x1,7
 add x2,sp,#432
 CALL md2asm_fourier_in_7358525
 ldr w9,[sp,#408]
 ldr w10,[sp,#416]
 orr w9,w9,w10
 cbz w9,.Lftinv_ctl_metric_done
 add x0,sp,#432
 ARG x1,2
 ARG x2,3
 ARG x3,4
 add x4,sp,#792
 add x5,sp,#880
 add x6,sp,#968
 add x7,sp,#1056
 add x9,sp,#1144
 str x9,[sp]
 CALL md2asm_ftcontroller_fsc
.Lftinv_ctl_metric_done:
 cbz x20,.Lftinv_ctl_inverse_done
 add x0,sp,#704
 ARG x1,6
 add x2,sp,#432
 CALL md2asm_ftinv_7358525
.Lftinv_ctl_inverse_done:
 add x23,x23,#1
 cmp x23,#32
 b.le .Lftinv_ctl_row
 STAT 1639,1
 ldr x0,[sp,#456]
 CALL free
 STAT 107,1
 ldr w9,[sp,#400]
 ldr w10,[sp,#404]
 ldr w11,[sp,#420]
 add x0,x9,x10
 add x0,x0,x11
 lsl x0,x0,#2
 cmp x0,#0
 mov x9,#1
 csel x0,x0,x9,ne
 CALL malloc
 cbz x0,.Lftinv_ctl_reject
 str x0,[sp,#464]
 str x0,[sp,#472]
 ldr w9,[sp,#400]
 add x9,x0,x9,lsl #2
 str x9,[sp,#480]
 ldr w10,[sp,#404]
 add x9,x9,x10,lsl #2
 str x9,[sp,#488]
 mov x1,x0
 ldr w9,[sp,#400]
 ldr w10,[sp,#404]
 add x2,x9,x10
 mov w3,#-1
 cbz x2,.Lftinv_ctl_sets_default_done
.Lftinv_ctl_sets_default:
 str w3,[x1],#4
 subs x2,x2,#1
 b.ne .Lftinv_ctl_sets_default
.Lftinv_ctl_sets_default_done:
 ARG x0,8
 cbz x0,.Lftinv_ctl_uv_map_done
 ldr x1,[sp,#472]
 ldr w2,[sp,#400]
 bl .Lftinv_ctl_copy_map
.Lftinv_ctl_uv_map_done:
 ARG x0,9
 cbz x0,.Lftinv_ctl_split_maps
 ldr x1,[sp,#480]
 ldr w2,[sp,#404]
 bl .Lftinv_ctl_copy_map
 b .Lftinv_ctl_scalar_map_done
.Lftinv_ctl_split_maps:
 mov x24,#0
 ARG x0,13
 cbz x0,.Lftinv_ctl_map_skip0
 bl .Lftinv_ctl_map_extent
 mov x25,x0
 mov x26,#1
 cbz x26,.Lftinv_ctl_map_skip0
.Lftinv_ctl_map_repeat0:
 add x9,x24,x25
 ldr w10,[sp,#404]
 cmp x9,x10
 b.gt .Lftinv_ctl_reject
 ARG x0,13
 ldr x1,[sp,#480]
 add x1,x1,x24,lsl #2
 mov x2,x25
 bl .Lftinv_ctl_copy_map
 add x24,x24,x25
 subs x26,x26,#1
 b.ne .Lftinv_ctl_map_repeat0
.Lftinv_ctl_map_skip0:
 ARG x0,11
 cbz x0,.Lftinv_ctl_map_skip1
 bl .Lftinv_ctl_map_extent
 mov x25,x0
 mov x26,#1
 ARG x9,16
 cbz x9,.Lftinv_ctl_reject
 ldr x26,[x9,#104]
 ldr x10,[x9,#96]
 sub x26,x26,x10
 add x26,x26,#1
 ldr w9,[sp,#384]
 cbz w9,.Lftinv_ctl_repeat_ready1
 mov x9,#3
 udiv x26,x26,x9
.Lftinv_ctl_repeat_ready1:
 cbz x26,.Lftinv_ctl_map_skip1
.Lftinv_ctl_map_repeat1:
 add x9,x24,x25
 ldr w10,[sp,#404]
 cmp x9,x10
 b.gt .Lftinv_ctl_reject
 ARG x0,11
 ldr x1,[sp,#480]
 add x1,x1,x24,lsl #2
 mov x2,x25
 bl .Lftinv_ctl_copy_map
 add x24,x24,x25
 subs x26,x26,#1
 b.ne .Lftinv_ctl_map_repeat1
.Lftinv_ctl_map_skip1:
 ARG x0,12
 cbz x0,.Lftinv_ctl_map_skip2
 bl .Lftinv_ctl_map_extent
 mov x25,x0
 mov x26,#1
 ARG x9,17
 cbz x9,.Lftinv_ctl_reject
 ldr x26,[x9,#104]
 ldr x10,[x9,#96]
 sub x26,x26,x10
 add x26,x26,#1
 ldr w9,[sp,#384]
 cbz w9,.Lftinv_ctl_repeat_ready2
 mov x9,#3
 udiv x26,x26,x9
.Lftinv_ctl_repeat_ready2:
 cbz x26,.Lftinv_ctl_map_skip2
.Lftinv_ctl_map_repeat2:
 add x9,x24,x25
 ldr w10,[sp,#404]
 cmp x9,x10
 b.gt .Lftinv_ctl_reject
 ARG x0,12
 ldr x1,[sp,#480]
 add x1,x1,x24,lsl #2
 mov x2,x25
 bl .Lftinv_ctl_copy_map
 add x24,x24,x25
 subs x26,x26,#1
 b.ne .Lftinv_ctl_map_repeat2
.Lftinv_ctl_map_skip2:
 cbz x24,.Lftinv_ctl_scalar_map_done
 ldr w9,[sp,#404]
 cmp x24,x9
 b.ne .Lftinv_ctl_reject
.Lftinv_ctl_scalar_map_done:
 mov x24,#0
 ldr w9,[sp,#376]
 cbz w9,.Lftinv_ctl_group_skip0
 ldr w25,[sp,#400]
 add x9,x24,x25
 ldr w10,[sp,#420]
 cmp x9,x10
 b.gt .Lftinv_ctl_reject
 ldr x0,[sp,#472]
 ldr x1,[sp,#488]
 add x1,x1,x24,lsl #2
 mov x2,x25
 bl .Lftinv_ctl_copy_words
 add x24,x24,x25
.Lftinv_ctl_group_skip0:
 ldr w9,[sp,#380]
 cbz w9,.Lftinv_ctl_group_skip1
 ldr w25,[sp,#400]
 add x9,x24,x25
 ldr w10,[sp,#420]
 cmp x9,x10
 b.gt .Lftinv_ctl_reject
 ldr x0,[sp,#472]
 ldr x1,[sp,#488]
 add x1,x1,x24,lsl #2
 mov x2,x25
 bl .Lftinv_ctl_copy_words
 add x24,x24,x25
.Lftinv_ctl_group_skip1:
 ldr w25,[sp,#400]
 add x9,x24,x25
 ldr w10,[sp,#420]
 cmp x9,x10
 b.gt .Lftinv_ctl_reject
 ldr x0,[sp,#472]
 ldr x1,[sp,#488]
 add x1,x1,x24,lsl #2
 mov x2,x25
 bl .Lftinv_ctl_copy_words
 add x24,x24,x25
.Lftinv_ctl_group_skip2:
 ldr w25,[sp,#400]
 add x9,x24,x25
 ldr w10,[sp,#420]
 cmp x9,x10
 b.gt .Lftinv_ctl_reject
 ldr x0,[sp,#472]
 ldr x1,[sp,#488]
 add x1,x1,x24,lsl #2
 mov x2,x25
 bl .Lftinv_ctl_copy_words
 add x24,x24,x25
.Lftinv_ctl_group_skip3:
 ldr w25,[sp,#404]
 add x9,x24,x25
 ldr w10,[sp,#420]
 cmp x9,x10
 b.gt .Lftinv_ctl_reject
 ldr x0,[sp,#480]
 ldr x1,[sp,#488]
 add x1,x1,x24,lsl #2
 mov x2,x25
 bl .Lftinv_ctl_copy_words
 add x24,x24,x25
.Lftinv_ctl_group_skip4:
 ldr w9,[sp,#384]
 cbz w9,.Lftinv_ctl_group_skip5
 ldr w25,[sp,#404]
 add x9,x24,x25
 ldr w10,[sp,#420]
 cmp x9,x10
 b.gt .Lftinv_ctl_reject
 ldr x0,[sp,#480]
 ldr x1,[sp,#488]
 add x1,x1,x24,lsl #2
 mov x2,x25
 bl .Lftinv_ctl_copy_words
 add x24,x24,x25
.Lftinv_ctl_group_skip5:
 ldr w9,[sp,#384]
 cbz w9,.Lftinv_ctl_group_skip6
 ldr w25,[sp,#404]
 add x9,x24,x25
 ldr w10,[sp,#420]
 cmp x9,x10
 b.gt .Lftinv_ctl_reject
 ldr x0,[sp,#480]
 ldr x1,[sp,#488]
 add x1,x1,x24,lsl #2
 mov x2,x25
 bl .Lftinv_ctl_copy_words
 add x24,x24,x25
.Lftinv_ctl_group_skip6:
 ldr w9,[sp,#420]
 cmp x24,x9
 b.ne .Lftinv_ctl_reject
 STAT 157,0
 mov x9,x22
 PLACE 0
 ARG x9,6
 PLACE 1
 ARG x9,5
 PLACE 2
 ARG x9,1
 PLACE 3
 ldr x9,[sp,#488]
 PLACE 4
 ARG x9,10
 PLACE 5
 ARG x9,14
 PLACE 6
 ARG x9,15
 PLACE 7
 ARG x9,16
 PLACE 8
 ARG x9,17
 PLACE 9
 ARG x9,18
 PLACE 10
 CALL md2asm_trltog_7358525
 STAT 157,1
 ldr x0,[sp,#464]
 CALL free
 mov x0,x22
 CALL free
 adrp x9,:got:md2asm_ftinv_ctl_7358525_count
 ldr x9,[x9,:got_lo12:md2asm_ftinv_ctl_7358525_count]
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 add x17,sp,#256
 ldp x19,x20,[x17]
 ldp x21,x22,[x17,#16]
 ldp x23,x24,[x17,#32]
 ldp x25,x26,[x17,#48]
 ldp x27,x28,[x17,#64]
 ldp x29,x30,[x17,#80]
 ldr x18,[sp,#352]
 add sp,sp,#4096
 ret
.Lftinv_ctl_reject:
 brk #0x542
.size md2asm_ftinv_ctl_7358525,.-md2asm_ftinv_ctl_7358525

// Descriptor metadata retains the full parent pitch for every sliced view.
.Lftinv_ctl_make_descriptor:
 str x1,[x0]
 neg x9,x4
 sub x9,x9,#1
 str x9,[x0,#8]
 mov x9,#8
 str x9,[x0,#16]
 str x9,[x0,#32]
 movz x9,#0x0302,lsl #32
 str x9,[x0,#24]
 mov x9,#1
 str x9,[x0,#40]
 str x9,[x0,#48]
 str x2,[x0,#56]
 str x4,[x0,#64]
 str x9,[x0,#72]
 str x3,[x0,#80]
 ret

.Lftinv_ctl_map_extent:
 ldr x9,[x0,#16]
 cmp x9,#4
 b.ne .Lftinv_ctl_reject
 ldr x9,[x0,#24]
 ubfx x10,x9,#32,#8
 cmp x10,#1
 b.ne .Lftinv_ctl_reject
 lsr x10,x9,#40
 cmp x10,#1
 b.ne .Lftinv_ctl_reject
 ldr x9,[x0,#56]
 ldr x10,[x0,#48]
 sub x9,x9,x10
 add x0,x9,#1
 cmp x0,#136
 b.hi .Lftinv_ctl_reject
 ret
.Lftinv_ctl_copy_map:
 cbz x2,.Lftinv_ctl_map_return
 ldr x9,[x0,#56]
 ldr x10,[x0,#48]
 sub x9,x9,x10
 add x9,x9,#1
 cmp x9,x2
 b.ne .Lftinv_ctl_reject
 ldr x3,[x0,#40]
 lsl x3,x3,#2
 ldr x0,[x0]
 cbz x0,.Lftinv_ctl_reject
.Lftinv_ctl_map_words:
 ldr w9,[x0]
 str w9,[x1],#4
 add x0,x0,x3
 subs x2,x2,#1
 b.ne .Lftinv_ctl_map_words
.Lftinv_ctl_map_return:
 ret
.Lftinv_ctl_copy_words:
 cbz x2,.Lftinv_ctl_words_return
.Lftinv_ctl_words_loop:
 ldr w9,[x0],#4
 str w9,[x1],#4
 subs x2,x2,#1
 b.ne .Lftinv_ctl_words_loop
.Lftinv_ctl_words_return:
 ret
.bss
.p2align 3
.global md2asm_ftinv_ctl_7358525_count
.type md2asm_ftinv_ctl_7358525_count,%object
md2asm_ftinv_ctl_7358525_count: .zero 8
.size md2asm_ftinv_ctl_7358525_count,8
.section .note.GNU-stack,"",%progbits
