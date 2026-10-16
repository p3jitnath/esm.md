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
.global md2asm_ftdir_ctl_7358525
.type md2asm_ftdir_ctl_7358525,%function
md2asm_ftdir_ctl_7358525:
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
.Lftdir_ctl_arguments:
 ldr x9,[x16],#8
 str x9,[x19,x10,lsl #3]
 add x10,x10,#1
 cmp x10,#15
 b.lt .Lftdir_ctl_arguments
 mrs x9,fpcr
 cbnz x9,.Lftdir_ctl_reject
 ARG x9,0
 ldr w10,[x9]
 cmp w10,#0
 b.lt .Lftdir_ctl_reject
 cmp w10,#136
 b.gt .Lftdir_ctl_reject
 str w10,[sp,#400]
 ARG x9,1
 ldr w10,[x9]
 cmp w10,#0
 b.lt .Lftdir_ctl_reject
 cmp w10,#136
 b.gt .Lftdir_ctl_reject
 str w10,[sp,#404]
 ARG x9,2
 ldr w10,[x9]
 cmp w10,#0
 b.lt .Lftdir_ctl_reject
 cmp w10,#136
 b.gt .Lftdir_ctl_reject
 str w10,[sp,#420]
 ARG x9,3
 ldr w10,[x9]
 cmp w10,#0
 b.lt .Lftdir_ctl_reject
 cmp w10,#136
 b.gt .Lftdir_ctl_reject
 str w10,[sp,#424]
 ldr w9,[sp,#400]
 str w9,[sp,#408]
 ldr w9,[sp,#404]
 str w9,[sp,#412]
 str wzr,[sp,#416]
 str wzr,[sp,#428]
 adrp x9,:got:__tpm_distr_MOD_nproc
 ldr x9,[x9,:got_lo12:__tpm_distr_MOD_nproc]
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lftdir_ctl_reject
 adrp x9,:got:__tpm_distr_MOD_myproc
 ldr x9,[x9,:got_lo12:__tpm_distr_MOD_myproc]
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lftdir_ctl_reject
 adrp x9,:got:__tpm_distr_MOD_d
 ldr x9,[x9,:got_lo12:__tpm_distr_MOD_d]
 ldr x21,[x9]
 cbz x21,.Lftdir_ctl_reject
 ldr w9,[x21,#992]
 cmp w9,#32
 b.ne .Lftdir_ctl_reject
 ldr w9,[x21,#1064]
 cmp w9,#2144
 b.ne .Lftdir_ctl_reject
 adrp x9,:got:__tpm_trans_MOD_latlon
 ldr x9,[x9,:got_lo12:__tpm_trans_MOD_latlon]
 ldr w10,[x9]
 cmp w10,#1
 b.hi .Lftdir_ctl_reject
 str w10,[sp,#368]
 adrp x9,:got:__tpm_trans_MOD_luvder
 ldr x9,[x9,:got_lo12:__tpm_trans_MOD_luvder]
 ldr w10,[x9]
 cmp w10,#1
 b.hi .Lftdir_ctl_reject
 str w10,[sp,#372]
 adrp x9,:got:__tpm_trans_MOD_lvorgp
 ldr x9,[x9,:got_lo12:__tpm_trans_MOD_lvorgp]
 ldr w10,[x9]
 cmp w10,#1
 b.hi .Lftdir_ctl_reject
 str w10,[sp,#376]
 adrp x9,:got:__tpm_trans_MOD_ldivgp
 ldr x9,[x9,:got_lo12:__tpm_trans_MOD_ldivgp]
 ldr w10,[x9]
 cmp w10,#1
 b.hi .Lftdir_ctl_reject
 str w10,[sp,#380]
 adrp x9,:got:__tpm_trans_MOD_lscders
 ldr x9,[x9,:got_lo12:__tpm_trans_MOD_lscders]
 ldr w10,[x9]
 cmp w10,#1
 b.hi .Lftdir_ctl_reject
 str w10,[sp,#384]
 ldr w9,[sp,#368]
 cbnz w9,.Lftdir_ctl_reject
 ldr w20,[sp,#424]
 mov x9,#17152
 mul x0,x20,x9
 cmp x0,#0
 mov x9,#1
 csel x0,x0,x9,ne
 CALL malloc
 cbz x0,.Lftdir_ctl_reject
 mov x22,x0
 str x0,[sp,#448]
 add x0,sp,#704
 mov x1,x22
 mov x2,x20
 mov x3,#2144
 cmp x20,#0
 mov x4,#1
 csel x4,x20,x4,ne
 bl .Lftdir_ctl_make_descriptor
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
 cbz x0,.Lftdir_ctl_reject
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
 cbz x2,.Lftdir_ctl_sets_default_done
.Lftdir_ctl_sets_default:
 str w3,[x1],#4
 subs x2,x2,#1
 b.ne .Lftdir_ctl_sets_default
.Lftdir_ctl_sets_default_done:
 ARG x0,4
 cbz x0,.Lftdir_ctl_uv_map_done
 ldr x1,[sp,#472]
 ldr w2,[sp,#400]
 bl .Lftdir_ctl_copy_map
.Lftdir_ctl_uv_map_done:
 ARG x0,5
 cbz x0,.Lftdir_ctl_split_maps
 ldr x1,[sp,#480]
 ldr w2,[sp,#404]
 bl .Lftdir_ctl_copy_map
 b .Lftdir_ctl_scalar_map_done
.Lftdir_ctl_split_maps:
 mov x24,#0
 ARG x0,9
 cbz x0,.Lftdir_ctl_map_skip0
 bl .Lftdir_ctl_map_extent
 mov x25,x0
 mov x26,#1
 cbz x26,.Lftdir_ctl_map_skip0
.Lftdir_ctl_map_repeat0:
 add x9,x24,x25
 ldr w10,[sp,#404]
 cmp x9,x10
 b.gt .Lftdir_ctl_reject
 ARG x0,9
 ldr x1,[sp,#480]
 add x1,x1,x24,lsl #2
 mov x2,x25
 bl .Lftdir_ctl_copy_map
 add x24,x24,x25
 subs x26,x26,#1
 b.ne .Lftdir_ctl_map_repeat0
.Lftdir_ctl_map_skip0:
 ARG x0,7
 cbz x0,.Lftdir_ctl_map_skip1
 bl .Lftdir_ctl_map_extent
 mov x25,x0
 mov x26,#1
 ARG x9,12
 cbz x9,.Lftdir_ctl_reject
 ldr x26,[x9,#104]
 ldr x10,[x9,#96]
 sub x26,x26,x10
 add x26,x26,#1
 cbz x26,.Lftdir_ctl_map_skip1
.Lftdir_ctl_map_repeat1:
 add x9,x24,x25
 ldr w10,[sp,#404]
 cmp x9,x10
 b.gt .Lftdir_ctl_reject
 ARG x0,7
 ldr x1,[sp,#480]
 add x1,x1,x24,lsl #2
 mov x2,x25
 bl .Lftdir_ctl_copy_map
 add x24,x24,x25
 subs x26,x26,#1
 b.ne .Lftdir_ctl_map_repeat1
.Lftdir_ctl_map_skip1:
 ARG x0,8
 cbz x0,.Lftdir_ctl_map_skip2
 bl .Lftdir_ctl_map_extent
 mov x25,x0
 mov x26,#1
 ARG x9,13
 cbz x9,.Lftdir_ctl_reject
 ldr x26,[x9,#104]
 ldr x10,[x9,#96]
 sub x26,x26,x10
 add x26,x26,#1
 cbz x26,.Lftdir_ctl_map_skip2
.Lftdir_ctl_map_repeat2:
 add x9,x24,x25
 ldr w10,[sp,#404]
 cmp x9,x10
 b.gt .Lftdir_ctl_reject
 ARG x0,8
 ldr x1,[sp,#480]
 add x1,x1,x24,lsl #2
 mov x2,x25
 bl .Lftdir_ctl_copy_map
 add x24,x24,x25
 subs x26,x26,#1
 b.ne .Lftdir_ctl_map_repeat2
.Lftdir_ctl_map_skip2:
.Lftdir_ctl_scalar_map_done:
 mov x24,#0
 ldr w25,[sp,#400]
 add x9,x24,x25
 ldr w10,[sp,#420]
 cmp x9,x10
 b.gt .Lftdir_ctl_reject
 ldr x0,[sp,#472]
 ldr x1,[sp,#488]
 add x1,x1,x24,lsl #2
 mov x2,x25
 bl .Lftdir_ctl_copy_words
 add x24,x24,x25
.Lftdir_ctl_group_skip0:
 ldr w25,[sp,#400]
 add x9,x24,x25
 ldr w10,[sp,#420]
 cmp x9,x10
 b.gt .Lftdir_ctl_reject
 ldr x0,[sp,#472]
 ldr x1,[sp,#488]
 add x1,x1,x24,lsl #2
 mov x2,x25
 bl .Lftdir_ctl_copy_words
 add x24,x24,x25
.Lftdir_ctl_group_skip1:
 ldr w25,[sp,#404]
 add x9,x24,x25
 ldr w10,[sp,#420]
 cmp x9,x10
 b.gt .Lftdir_ctl_reject
 ldr x0,[sp,#480]
 ldr x1,[sp,#488]
 add x1,x1,x24,lsl #2
 mov x2,x25
 bl .Lftdir_ctl_copy_words
 add x24,x24,x25
.Lftdir_ctl_group_skip2:
 ldr w9,[sp,#420]
 cmp x24,x9
 b.ne .Lftdir_ctl_reject
 STAT 158,0
 mov x9,x22
 PLACE 0
 ARG x9,3
 PLACE 1
 ARG x9,2
 PLACE 2
 ARG x9,1
 PLACE 3
 ldr x9,[sp,#488]
 PLACE 4
 ARG x9,6
 PLACE 5
 ARG x9,10
 PLACE 6
 ARG x9,11
 PLACE 7
 ARG x9,12
 PLACE 8
 ARG x9,13
 PLACE 9
 ARG x9,14
 PLACE 10
 CALL md2asm_trgtol_7358525
 STAT 158,1
 STAT 106,0
 adrp x9,:got:__tpm_trans_MOD_foubuf_in
 ldr x24,[x9,:got_lo12:__tpm_trans_MOD_foubuf_in]
 ldr w9,[x21,#1760]
 cmp w9,#0
 b.lt .Lftdir_ctl_reject
 umull x25,w9,w20
 lsl x25,x25,#1
 mov x9,#1
 cmp x25,#0
 csel x25,x25,x9,ne
 mov w9,#0x7fffffff
 cmp x25,x9
 b.gt .Lftdir_ctl_reject
 ldr x0,[x24]
 cbz x0,.Lftdir_ctl_allocate_packed
 ldr x9,[x24,#56]
 ldr x10,[x24,#48]
 sub x9,x9,x10
 add x9,x9,#1
 cmp x9,x25
 b.ge .Lftdir_ctl_packed_ready
 CALL free
 str xzr,[x24]
.Lftdir_ctl_allocate_packed:
 lsl x0,x25,#3
 CALL malloc
 cbz x0,.Lftdir_ctl_reject
 str x0,[x24]
 mov x9,#-1
 str x9,[x24,#8]
 mov x9,#8
 str x9,[x24,#16]
 str x9,[x24,#32]
 movz x9,#0x0301,lsl #32
 str x9,[x24,#24]
 mov x9,#1
 str x9,[x24,#40]
 str x9,[x24,#48]
 str x25,[x24,#56]
.Lftdir_ctl_packed_ready:
 STAT 1640,0
 mov x23,#1
.Lftdir_ctl_row:
 str w23,[sp,#432]
 cbz x20,.Lftdir_ctl_direct_done
 add x0,sp,#704
 ARG x1,3
 add x2,sp,#432
 CALL md2asm_ftdir
.Lftdir_ctl_direct_done:
 add x0,sp,#704
 ARG x1,3
 add x2,sp,#432
 CALL md2asm_fourier_out_7358525
 add x23,x23,#1
 cmp x23,#32
 b.le .Lftdir_ctl_row
 STAT 1640,1
 STAT 106,1
 ldr x0,[sp,#464]
 CALL free
 mov x0,x22
 CALL free
 adrp x9,:got:md2asm_ftdir_ctl_7358525_count
 ldr x9,[x9,:got_lo12:md2asm_ftdir_ctl_7358525_count]
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
.Lftdir_ctl_reject:
 brk #0x542
.size md2asm_ftdir_ctl_7358525,.-md2asm_ftdir_ctl_7358525

// Descriptor metadata retains the full parent pitch for every sliced view.
.Lftdir_ctl_make_descriptor:
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

.Lftdir_ctl_map_extent:
 ldr x9,[x0,#16]
 cmp x9,#4
 b.ne .Lftdir_ctl_reject
 ldr x9,[x0,#24]
 ubfx x10,x9,#32,#8
 cmp x10,#1
 b.ne .Lftdir_ctl_reject
 lsr x10,x9,#40
 cmp x10,#1
 b.ne .Lftdir_ctl_reject
 ldr x9,[x0,#56]
 ldr x10,[x0,#48]
 sub x9,x9,x10
 add x0,x9,#1
 cmp x0,#136
 b.hi .Lftdir_ctl_reject
 ret
.Lftdir_ctl_copy_map:
 cbz x2,.Lftdir_ctl_map_return
 ldr x9,[x0,#56]
 ldr x10,[x0,#48]
 sub x9,x9,x10
 add x9,x9,#1
 cmp x9,x2
 b.ne .Lftdir_ctl_reject
 ldr x3,[x0,#40]
 lsl x3,x3,#2
 ldr x0,[x0]
 cbz x0,.Lftdir_ctl_reject
.Lftdir_ctl_map_words:
 ldr w9,[x0]
 str w9,[x1],#4
 add x0,x0,x3
 subs x2,x2,#1
 b.ne .Lftdir_ctl_map_words
.Lftdir_ctl_map_return:
 ret
.Lftdir_ctl_copy_words:
 cbz x2,.Lftdir_ctl_words_return
.Lftdir_ctl_words_loop:
 ldr w9,[x0],#4
 str w9,[x1],#4
 subs x2,x2,#1
 b.ne .Lftdir_ctl_words_loop
.Lftdir_ctl_words_return:
 ret
.bss
.p2align 3
.global md2asm_ftdir_ctl_7358525_count
.type md2asm_ftdir_ctl_7358525_count,%object
md2asm_ftdir_ctl_7358525_count: .zero 8
.size md2asm_ftdir_ctl_7358525_count,8
.section .note.GNU-stack,"",%progbits
