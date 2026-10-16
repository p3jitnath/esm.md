/* Source build for the qualified private forecast graph.
 * Contract: skills/md2asm/references/openifs/dynamics/private_forecast_graph_sources.md.
 * Preserve the original interface, ordered arithmetic, and caller-owned storage. */
// Source contract grid_transform_copy_contract_r1.md.
// Eleven addresses, including raw PGLAT/field sets and GNU optional descriptors.
// All FP64 copies use integer registers. Unrelated words remain untouched.
.arch armv8-a
.include "grid_transform_copies_layout.inc.S"
.text
.p2align 4
.macro GLOBAL reg,name
 adrp \reg,:got:\name
 ldr \reg,[\reg,:got_lo12:\name]
.endm
.macro EVENT id,phase
 adrp x0,.Levent_\id
 add x0,x0,:lo12:.Levent_\id
 adrp x1,.Lphase_\phase
 add x1,x1,:lo12:.Lphase_\phase
 bl gstats_
.endm
.macro NORM_EVENT phase
 GLOBAL x9,__tpm_trans_MOD_lgpnorm
 ldr w9,[x9]
 cbnz w9,92f
 EVENT 803,\phase
 b 93f
92:
 EVENT 804,\phase
93:
.endm
.macro PROFILE name,phase,handle,length
 GLOBAL x9,__yomhook_MOD_lhook
 ldr w9,[x9]
 cbz w9,91f
 adrp x0,.Lname_\name
 add x0,x0,:lo12:.Lname_\name
 adrp x1,.Lphase_\phase
 add x1,x1,:lo12:.Lphase_\phase
 add x2,sp,#\handle
 mov x3,#\length
 bl __yomhook_MOD_dr_hook_default8
91:
.endm
.global md2asm_trltog_7358525
.type md2asm_trltog_7358525,%function
md2asm_trltog_7358525:
 mov x17,sp
 sub sp,sp,#640
 stp x18,x30,[sp,#48]
 stp x19,x20,[sp,#64]
 stp x21,x22,[sp,#80]
 stp x23,x24,[sp,#96]
 stp x25,x26,[sp,#112]
 stp x27,x28,[sp,#128]
 str x29,[sp,#144]
 str x0,[sp,#160]
 str x1,[sp,#168]
 str x2,[sp,#176]
 str x3,[sp,#184]
 str x4,[sp,#192]
 str x5,[sp,#200]
 str x6,[sp,#208]
 str x7,[sp,#216]
 ldr x9,[x17,#0]
 str x9,[sp,#224]
 ldr x9,[x17,#8]
 str x9,[sp,#232]
 ldr x9,[x17,#16]
 str x9,[sp,#240]
 mov x19,x0
 cbz x19,.Lgrid_bad
 tst x19,#7
 b.ne .Lgrid_bad
 cbz x1,.Lgrid_bad
 cbz x2,.Lgrid_bad
 cbz x3,.Lgrid_bad
 cbz x4,.Lgrid_bad
 ldr w20,[x1]
 ldr w21,[x2]
 ldr w22,[x3]
 cmp w20,#1
 b.lt .Lgrid_bad
 cmp w20,#136
 b.gt .Lgrid_bad
 cmp w21,w20
 b.ne .Lgrid_bad
 cmp w22,#0
 b.lt .Lgrid_bad
 cmp w22,w21
 b.gt .Lgrid_bad
 GLOBAL x9,__tpm_distr_MOD_nproc
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lgrid_bad
 GLOBAL x9,__tpm_distr_MOD_myproc
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lgrid_bad
 GLOBAL x9,__tpm_distr_MOD_nprtrns
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lgrid_bad
 GLOBAL x9,__tpm_distr_MOD_mysetw
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lgrid_bad
 GLOBAL x9,__tpm_distr_MOD_mysetv
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lgrid_bad
 GLOBAL x9,__eq_regions_mod_MOD_my_region_ns
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lgrid_bad
 GLOBAL x9,__eq_regions_mod_MOD_my_region_ew
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lgrid_bad
 GLOBAL x9,__tpm_trans_MOD_nproma
 ldr w9,[x9]
 cmp w9,#24
 b.ne .Lgrid_bad
 GLOBAL x9,__tpm_trans_MOD_ngpblks
 ldr w9,[x9]
 cmp w9,#86
 b.ne .Lgrid_bad
 GLOBAL x9,__tpm_distr_MOD_d
 ldr x23,[x9]
 cbz x23,.Lgrid_bad
 ldr w9,[x23,#D_NDGL_FS]
 cmp w9,#32
 b.ne .Lgrid_bad
 ldr w9,[x23,#D_NDGL_GP]
 cmp w9,#32
 b.ne .Lgrid_bad
 ldr w9,[x23,#D_NLENGTF]
 cmp w9,#2144
 b.ne .Lgrid_bad
 ldr w9,[x23,#D_NFRSTLOFF]
 cmp w9,#0
 b.ne .Lgrid_bad
 ldr w9,[x23,#D_NPTRFLOFF]
 cmp w9,#0
 b.ne .Lgrid_bad
 ldr w9,[x23,#D_NGPTOT]
 cmp w9,#2048
 b.ne .Lgrid_bad
 GLOBAL x9,__tpm_gen_MOD_ntrans_sync_level
 ldr w9,[x9]
 cmp w9,#0
 b.gt .Lgrid_bad
 GLOBAL x9,__tpm_trans_MOD_lvorgp
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lgrid_bad
 str w9,[sp,#288]
 GLOBAL x9,__tpm_trans_MOD_ldivgp
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lgrid_bad
 str w9,[sp,#292]
 GLOBAL x9,__tpm_trans_MOD_lscders
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lgrid_bad
 str w9,[sp,#296]
 GLOBAL x9,__tpm_trans_MOD_luvder
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lgrid_bad
 str w9,[sp,#300]
 PROFILE trltog,0,256,6
 EVENT 1806,0
 add x0,x23,#D_NPTRLS
 mov x1,#1
 bl .Lgrid_int1
 cmp w0,#1
 b.ne .Lgrid_bad
 add x0,x23,#D_NFRSTLAT
 mov x1,#1
 bl .Lgrid_int1
 cmp w0,#1
 b.ne .Lgrid_bad
 add x0,x23,#D_NLSTLAT
 mov x1,#1
 bl .Lgrid_int1
 cmp w0,#32
 b.ne .Lgrid_bad
 add x0,x23,#D_NPTRFRSTLAT
 mov x1,#1
 bl .Lgrid_int1
 cmp w0,#1
 b.ne .Lgrid_bad
 add x0,x23,#D_NULTPP
 mov x1,#1
 bl .Lgrid_int1
 cmp w0,#32
 b.ne .Lgrid_bad
 mov x0,#8736
 bl malloc
 cbz x0,.Lgrid_bad
 mov x25,x0
 mov w26,#1
 mov x27,#0
.Ltrltog_latitude:
 add x0,x23,#D_NPROCL
 mov x1,x26
 bl .Lgrid_int1
 cmp w0,#1
 b.ne .Lgrid_bad
 add x0,x23,#D_NSTAGTF
 mov x1,x26
 bl .Lgrid_int1
 str w0,[sp,#304]
 add x0,x23,#D_NSTA
 mov x1,x26
 mov x2,#1
 bl .Lgrid_int2
 cmp w0,#1
 b.ne .Lgrid_bad
 str w0,[sp,#308]
 add x0,x23,#D_NONL
 mov x1,x26
 mov x2,#1
 bl .Lgrid_int2
 cmp w0,#1
 b.lt .Lgrid_bad
 cmp w0,#64
 b.gt .Lgrid_bad
 mov w9,w0
 ldr w10,[sp,#304]
 ldr w11,[sp,#308]
 add w10,w10,w11
.Ltrltog_longitude:
 cmp x27,#2048
 b.hs .Lgrid_bad
 cmp w10,#1
 b.lt .Lgrid_bad
 cmp w10,#2144
 b.gt .Lgrid_bad
 str w10,[x25,x27,lsl #2]
 add x27,x27,#1
 add w10,w10,#1
 subs w9,w9,#1
 b.ne .Ltrltog_longitude
 add w26,w26,#1
 cmp w26,#32
 b.le .Ltrltog_latitude
 cmp x27,#2048
 b.ne .Lgrid_bad
 EVENT 1806,1
 PROFILE trltog_bar,0,264,10
 adrp x0,.Lbarrier_762
 add x0,x0,:lo12:.Lbarrier_762
 bl gstats_barrier_
 PROFILE trltog_bar,1,264,10
 EVENT 805,0
 EVENT 805,1
 EVENT 1806,0
 lsl x0,x21,#5
 bl malloc
 cbz x0,.Lgrid_bad
 mov x24,x0
 mov x10,x0
 lsl x11,x21,#2
.Ltrltog_map_clear:
 str xzr,[x10],#8
 subs x11,x11,#1
 b.ne .Ltrltog_map_clear
 ldr x0,[sp,#208]
 cbz x0,.Ltrltog_split
 mov x1,x24
 mov w2,#1
 mov w3,#1
 mov w4,w21
 mov w5,#1
 bl .Lgrid_map_group
 b .Ltrltog_map_done
.Ltrltog_split:
 mov w9,#0
 str w9,[sp,#312]
 mov w9,#2
 ldr w10,[sp,#288]
 add w9,w9,w10
 ldr w10,[sp,#292]
 add w9,w9,w10
 str w9,[sp,#316]
 ldr x0,[sp,#216]
 cbz x0,.Ltrltog_uv_done
 ldr w3,[x0,#80]
 cmp w3,#1
 b.lt .Lgrid_bad
 mov x1,x24
 mov w2,#1
 ldr w4,[sp,#316]
 mov w5,#1
 bl .Lgrid_map_group
 sub w9,w0,#1
 str w9,[sp,#312]
.Ltrltog_uv_done:
 mov x0,sp
 mov x1,x24
 ldr w2,[sp,#312]
 add w2,w2,#1
 mov w3,#0
 bl .Lgrid_scalar_groups
 ldr w9,[sp,#312]
 add w9,w9,w22
 add w9,w9,#1
 cmp w0,w9
 b.ne .Lgrid_bad
 ldr w10,[sp,#296]
 cbz w10,.Ltrltog_ns_done
 mov x0,sp
 mov x1,x24
 mov w2,w9
 mov w3,#1
 bl .Lgrid_scalar_groups
.Ltrltog_ns_done:
 ldr w9,[sp,#300]
 cbz w9,.Ltrltog_uvder_done
 ldr x0,[sp,#216]
 cbz x0,.Ltrltog_uvder_done
 mov x1,x24
 ldr w2,[sp,#312]
 add w2,w2,w22
 ldr w9,[sp,#296]
 cbz w9,.Ltrltog_uvder_pos
 add w2,w2,w22
.Ltrltog_uvder_pos:
 add w2,w2,#1
 ldr w3,[x0,#80]
 mov w4,#2
 ldr w5,[sp,#316]
 add w5,w5,#1
 bl .Lgrid_map_group
.Ltrltog_uvder_done:
 ldr w9,[sp,#296]
 cbz w9,.Ltrltog_map_done
 mov x0,sp
 mov x1,x24
 ldr w2,[sp,#312]
 add w2,w2,w22,lsl #1
 ldr w9,[sp,#300]
 cbz w9,.Ltrltog_ew_pos
 ldr x10,[sp,#216]
 cbz x10,.Ltrltog_ew_pos
 ldr w10,[x10,#80]
 add w2,w2,w10,lsl #1
.Ltrltog_ew_pos:
 add w2,w2,#1
 mov w3,#2
 bl .Lgrid_scalar_groups
.Ltrltog_map_done:
 mov w26,#1
 ldr x27,[sp,#192]
 ldr x28,[sp,#200]
.Ltrltog_field_validate:
 sub w9,w26,#1
 ldr w9,[x27,w9,uxtw #2]
 cmp w9,#1
 b.eq .Ltrltog_set_valid
 cmn w9,#1
 b.ne .Lgrid_bad
.Ltrltog_set_valid:
 mov w10,w26
 cbz x28,.Ltrltog_target_field
 mov x0,x28
 mov x1,x26
 bl .Lgrid_int1
 mov w10,w0
.Ltrltog_target_field:
 cmp w10,#1
 b.lt .Lgrid_bad
 cmp w10,w21
 b.gt .Lgrid_bad
 sub w10,w10,#1
 lsl x10,x10,#5
 ldr x9,[x24,x10]
 cbz x9,.Lgrid_bad
 // Keep the source target index in a separate compact array after the index list.
 mov x11,#8192
 add x11,x25,x11
 sub w9,w26,#1
 str w10,[x11,w9,uxtw #2]
 add w26,w26,#1
 cmp w26,w21
 b.le .Ltrltog_field_validate
 EVENT 1806,1
 EVENT 1604,0
 mov w26,#1
.Ltrltog_block:
 mov w27,#1
.Ltrltog_field:
 mov x9,#8192
 add x9,x25,x9
 sub w10,w27,#1
 ldr w10,[x9,w10,uxtw #2]
 add x10,x24,x10
 ldr x28,[x10]
 ldr x11,[x10,#16]
 madd x28,x26,x11,x28
 mov w9,#24
 cmp w26,#86
 mov w10,#8
 csel w9,w10,w9,eq
 sub w10,w26,#1
 mov w11,#24
 mul w10,w10,w11
 add x12,x25,w10,uxtw #2
 mov w13,#1
.Ltrltog_row:
 ldr w14,[x12],#4
 sub w14,w14,#1
 mul x14,x14,x20
 sub w15,w27,#1
 add x14,x14,x15
 lsl x14,x14,#3
 ldr x16,[x19,x14]
 str x16,[x28,#8]
 add x28,x28,#8
 add w13,w13,#1
 cmp w13,w9
 b.le .Ltrltog_row
 add w27,w27,#1
 cmp w27,w21
 b.le .Ltrltog_field
 add w26,w26,#1
 cmp w26,#86
 b.le .Ltrltog_block
 EVENT 1604,1
 EVENT 805,0
 EVENT 805,1

 mov x0,x25
 bl free
 mov x0,x24
 bl free
 adrp x0,.Lbarrier_762
 add x0,x0,:lo12:.Lbarrier_762
 bl gstats_barrier2_
 PROFILE trltog,1,256,6
 adrp x9,.Lgrid_counts
 add x9,x9,:lo12:.Lgrid_counts
 ldr x10,[x9,#0]
 add x10,x10,#1
 str x10,[x9,#0]
 ldp x18,x30,[sp,#48]
 ldp x19,x20,[sp,#64]
 ldp x21,x22,[sp,#80]
 ldp x23,x24,[sp,#96]
 ldp x25,x26,[sp,#112]
 ldp x27,x28,[sp,#128]
 ldr x29,[sp,#144]
 add sp,sp,#640
 ret
.size md2asm_trltog_7358525,.-md2asm_trltog_7358525
.global md2asm_trgtol_7358525
.type md2asm_trgtol_7358525,%function
md2asm_trgtol_7358525:
 mov x17,sp
 sub sp,sp,#640
 stp x18,x30,[sp,#48]
 stp x19,x20,[sp,#64]
 stp x21,x22,[sp,#80]
 stp x23,x24,[sp,#96]
 stp x25,x26,[sp,#112]
 stp x27,x28,[sp,#128]
 str x29,[sp,#144]
 str x0,[sp,#160]
 str x1,[sp,#168]
 str x2,[sp,#176]
 str x3,[sp,#184]
 str x4,[sp,#192]
 str x5,[sp,#200]
 str x6,[sp,#208]
 str x7,[sp,#216]
 ldr x9,[x17,#0]
 str x9,[sp,#224]
 ldr x9,[x17,#8]
 str x9,[sp,#232]
 ldr x9,[x17,#16]
 str x9,[sp,#240]
 mov x19,x0
 cbz x19,.Lgrid_bad
 tst x19,#7
 b.ne .Lgrid_bad
 cbz x1,.Lgrid_bad
 cbz x2,.Lgrid_bad
 cbz x3,.Lgrid_bad
 cbz x4,.Lgrid_bad
 ldr w20,[x1]
 ldr w21,[x2]
 ldr w22,[x3]
 cmp w20,#1
 b.lt .Lgrid_bad
 cmp w20,#136
 b.gt .Lgrid_bad
 cmp w21,w20
 b.ne .Lgrid_bad
 cmp w22,#0
 b.lt .Lgrid_bad
 cmp w22,w21
 b.gt .Lgrid_bad
 GLOBAL x9,__tpm_distr_MOD_nproc
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lgrid_bad
 GLOBAL x9,__tpm_distr_MOD_myproc
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lgrid_bad
 GLOBAL x9,__tpm_distr_MOD_nprtrns
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lgrid_bad
 GLOBAL x9,__tpm_distr_MOD_mysetw
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lgrid_bad
 GLOBAL x9,__tpm_distr_MOD_mysetv
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lgrid_bad
 GLOBAL x9,__eq_regions_mod_MOD_my_region_ns
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lgrid_bad
 GLOBAL x9,__eq_regions_mod_MOD_my_region_ew
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lgrid_bad
 GLOBAL x9,__tpm_trans_MOD_nproma
 ldr w9,[x9]
 cmp w9,#24
 b.ne .Lgrid_bad
 GLOBAL x9,__tpm_trans_MOD_ngpblks
 ldr w9,[x9]
 cmp w9,#86
 b.ne .Lgrid_bad
 GLOBAL x9,__tpm_distr_MOD_d
 ldr x23,[x9]
 cbz x23,.Lgrid_bad
 ldr w9,[x23,#D_NDGL_FS]
 cmp w9,#32
 b.ne .Lgrid_bad
 ldr w9,[x23,#D_NDGL_GP]
 cmp w9,#32
 b.ne .Lgrid_bad
 ldr w9,[x23,#D_NLENGTF]
 cmp w9,#2144
 b.ne .Lgrid_bad
 ldr w9,[x23,#D_NFRSTLOFF]
 cmp w9,#0
 b.ne .Lgrid_bad
 ldr w9,[x23,#D_NPTRFLOFF]
 cmp w9,#0
 b.ne .Lgrid_bad
 ldr w9,[x23,#D_NGPTOT]
 cmp w9,#2048
 b.ne .Lgrid_bad
 GLOBAL x9,__tpm_gen_MOD_ntrans_sync_level
 ldr w9,[x9]
 cmp w9,#0
 b.gt .Lgrid_bad
 GLOBAL x9,__tpm_trans_MOD_lvorgp
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lgrid_bad
 str w9,[sp,#288]
 GLOBAL x9,__tpm_trans_MOD_ldivgp
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lgrid_bad
 str w9,[sp,#292]
 GLOBAL x9,__tpm_trans_MOD_lscders
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lgrid_bad
 str w9,[sp,#296]
 GLOBAL x9,__tpm_trans_MOD_luvder
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lgrid_bad
 str w9,[sp,#300]
 ldr w9,[sp,#288]
 ldr w10,[sp,#292]
 orr w9,w9,w10
 ldr w10,[sp,#296]
 orr w9,w9,w10
 ldr w10,[sp,#300]
 orr w9,w9,w10
 cbnz w9,.Lgrid_bad
 PROFILE trgtol,0,256,6
 EVENT 1805,0
 add x0,x23,#D_NPTRLS
 mov x1,#1
 bl .Lgrid_int1
 cmp w0,#1
 b.ne .Lgrid_bad
 add x0,x23,#D_NFRSTLAT
 mov x1,#1
 bl .Lgrid_int1
 cmp w0,#1
 b.ne .Lgrid_bad
 add x0,x23,#D_NLSTLAT
 mov x1,#1
 bl .Lgrid_int1
 cmp w0,#32
 b.ne .Lgrid_bad
 add x0,x23,#D_NPTRFRSTLAT
 mov x1,#1
 bl .Lgrid_int1
 cmp w0,#1
 b.ne .Lgrid_bad
 add x0,x23,#D_NULTPP
 mov x1,#1
 bl .Lgrid_int1
 cmp w0,#32
 b.ne .Lgrid_bad
 mov x0,#8736
 bl malloc
 cbz x0,.Lgrid_bad
 mov x25,x0
 mov w26,#1
 mov x27,#0
.Ltrgtol_latitude:
 add x0,x23,#D_NPROCL
 mov x1,x26
 bl .Lgrid_int1
 cmp w0,#1
 b.ne .Lgrid_bad
 add x0,x23,#D_NSTAGTF
 mov x1,x26
 bl .Lgrid_int1
 str w0,[sp,#304]
 add x0,x23,#D_NSTA
 mov x1,x26
 mov x2,#1
 bl .Lgrid_int2
 cmp w0,#1
 b.ne .Lgrid_bad
 str w0,[sp,#308]
 add x0,x23,#D_NONL
 mov x1,x26
 mov x2,#1
 bl .Lgrid_int2
 cmp w0,#1
 b.lt .Lgrid_bad
 cmp w0,#64
 b.gt .Lgrid_bad
 mov w9,w0
 ldr w10,[sp,#304]
 ldr w11,[sp,#308]
 add w10,w10,w11
.Ltrgtol_longitude:
 cmp x27,#2048
 b.hs .Lgrid_bad
 cmp w10,#1
 b.lt .Lgrid_bad
 cmp w10,#2144
 b.gt .Lgrid_bad
 str w10,[x25,x27,lsl #2]
 add x27,x27,#1
 add w10,w10,#1
 subs w9,w9,#1
 b.ne .Ltrgtol_longitude
 add w26,w26,#1
 cmp w26,#32
 b.le .Ltrgtol_latitude
 cmp x27,#2048
 b.ne .Lgrid_bad
 EVENT 1805,1
 PROFILE trgtol_bar,0,264,10
 adrp x0,.Lbarrier_761
 add x0,x0,:lo12:.Lbarrier_761
 bl gstats_barrier_
 PROFILE trgtol_bar,1,264,10
 NORM_EVENT 0
 NORM_EVENT 1
 EVENT 1805,0
 lsl x0,x21,#5
 bl malloc
 cbz x0,.Lgrid_bad
 mov x24,x0
 mov x10,x0
 lsl x11,x21,#2
.Ltrgtol_map_clear:
 str xzr,[x10],#8
 subs x11,x11,#1
 b.ne .Ltrgtol_map_clear
 ldr x0,[sp,#208]
 cbz x0,.Ltrgtol_split
 mov x1,x24
 mov w2,#1
 mov w3,#1
 mov w4,w21
 mov w5,#1
 bl .Lgrid_map_group
 b .Ltrgtol_map_done
.Ltrgtol_split:
 mov w9,#0
 str w9,[sp,#312]
 mov w9,#2
 ldr w10,[sp,#288]
 add w9,w9,w10
 ldr w10,[sp,#292]
 add w9,w9,w10
 str w9,[sp,#316]
 ldr x0,[sp,#216]
 cbz x0,.Ltrgtol_uv_done
 ldr w3,[x0,#80]
 cmp w3,#1
 b.lt .Lgrid_bad
 mov x1,x24
 mov w2,#1
 ldr w4,[sp,#316]
 mov w5,#1
 bl .Lgrid_map_group
 sub w9,w0,#1
 str w9,[sp,#312]
.Ltrgtol_uv_done:
 mov x0,sp
 mov x1,x24
 ldr w2,[sp,#312]
 add w2,w2,#1
 mov w3,#0
 bl .Lgrid_scalar_groups
 ldr w9,[sp,#312]
 add w9,w9,w22
 add w9,w9,#1
 cmp w0,w9
 b.ne .Lgrid_bad
 ldr w10,[sp,#296]
 cbz w10,.Ltrgtol_ns_done
 mov x0,sp
 mov x1,x24
 mov w2,w9
 mov w3,#1
 bl .Lgrid_scalar_groups
.Ltrgtol_ns_done:
 ldr w9,[sp,#300]
 cbz w9,.Ltrgtol_uvder_done
 ldr x0,[sp,#216]
 cbz x0,.Ltrgtol_uvder_done
 mov x1,x24
 ldr w2,[sp,#312]
 add w2,w2,w22
 ldr w9,[sp,#296]
 cbz w9,.Ltrgtol_uvder_pos
 add w2,w2,w22
.Ltrgtol_uvder_pos:
 add w2,w2,#1
 ldr w3,[x0,#80]
 mov w4,#2
 ldr w5,[sp,#316]
 add w5,w5,#1
 bl .Lgrid_map_group
.Ltrgtol_uvder_done:
 ldr w9,[sp,#296]
 cbz w9,.Ltrgtol_map_done
 mov x0,sp
 mov x1,x24
 ldr w2,[sp,#312]
 add w2,w2,w22,lsl #1
 ldr w9,[sp,#300]
 cbz w9,.Ltrgtol_ew_pos
 ldr x10,[sp,#216]
 cbz x10,.Ltrgtol_ew_pos
 ldr w10,[x10,#80]
 add w2,w2,w10,lsl #1
.Ltrgtol_ew_pos:
 add w2,w2,#1
 mov w3,#2
 bl .Lgrid_scalar_groups
.Ltrgtol_map_done:
 mov w26,#1
 ldr x27,[sp,#192]
 ldr x28,[sp,#200]
.Ltrgtol_field_validate:
 sub w9,w26,#1
 ldr w9,[x27,w9,uxtw #2]
 cmp w9,#1
 b.eq .Ltrgtol_set_valid
 cmn w9,#1
 b.ne .Lgrid_bad
.Ltrgtol_set_valid:
 mov w10,w26
 cbz x28,.Ltrgtol_target_field
 mov x0,x28
 mov x1,x26
 bl .Lgrid_int1
 mov w10,w0
.Ltrgtol_target_field:
 cmp w10,#1
 b.lt .Lgrid_bad
 cmp w10,w21
 b.gt .Lgrid_bad
 sub w10,w10,#1
 lsl x10,x10,#5
 ldr x9,[x24,x10]
 cbz x9,.Lgrid_bad
 // Keep the source target index in a separate compact array after the index list.
 mov x11,#8192
 add x11,x25,x11
 sub w9,w26,#1
 str w10,[x11,w9,uxtw #2]
 add w26,w26,#1
 cmp w26,w21
 b.le .Ltrgtol_field_validate
 EVENT 1805,1
 EVENT 1601,0
 mov w26,#1
.Ltrgtol_block:
 mov w27,#1
.Ltrgtol_field:
 mov x9,#8192
 add x9,x25,x9
 sub w10,w27,#1
 ldr w10,[x9,w10,uxtw #2]
 add x10,x24,x10
 ldr x28,[x10]
 ldr x11,[x10,#16]
 madd x28,x26,x11,x28
 mov w9,#24
 cmp w26,#86
 mov w10,#8
 csel w9,w10,w9,eq
 sub w10,w26,#1
 mov w11,#24
 mul w10,w10,w11
 add x12,x25,w10,uxtw #2
 mov w13,#1
.Ltrgtol_row:
 ldr w14,[x12],#4
 sub w14,w14,#1
 mul x14,x14,x20
 sub w15,w27,#1
 add x14,x14,x15
 lsl x14,x14,#3
 ldr x16,[x28,#8]
 str x16,[x19,x14]
 add x28,x28,#8
 add w13,w13,#1
 cmp w13,w9
 b.le .Ltrgtol_row
 add w27,w27,#1
 cmp w27,w21
 b.le .Ltrgtol_field
 add w26,w26,#1
 cmp w26,#86
 b.le .Ltrgtol_block
 EVENT 1601,1
 NORM_EVENT 0
 NORM_EVENT 1

 mov x0,x25
 bl free
 mov x0,x24
 bl free
 adrp x0,.Lbarrier_761
 add x0,x0,:lo12:.Lbarrier_761
 bl gstats_barrier2_
 PROFILE trgtol,1,256,6
 adrp x9,.Lgrid_counts
 add x9,x9,:lo12:.Lgrid_counts
 ldr x10,[x9,#8]
 add x10,x10,#1
 str x10,[x9,#8]
 ldp x18,x30,[sp,#48]
 ldp x19,x20,[sp,#64]
 ldp x21,x22,[sp,#80]
 ldp x23,x24,[sp,#96]
 ldp x25,x26,[sp,#112]
 ldp x27,x28,[sp,#128]
 ldr x29,[sp,#144]
 add sp,sp,#640
 ret
.size md2asm_trgtol_7358525,.-md2asm_trgtol_7358525
// Create field-address records in exact source parameter/level order.
// x0 target descriptor, x1 records, w2 first field, w3 levels, w4 parameters,
// w5 first parameter. Rank-three targets use one level and dimension1 parameters.
.Lgrid_map_group:
 stp x18,x30,[sp,#-112]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 mov x19,x0
 mov x20,x1
 mov w21,w2
 mov w22,w3
 mov w23,w4
 mov w24,w5
 cmp w23,#0
 b.lt .Lgrid_bad
 cbz w23,.Lgrid_group_done
 cbz x19,.Lgrid_bad
 cmp w22,#1
 b.lt .Lgrid_bad
 ldr x25,[x19]
 cbz x25,.Lgrid_bad
 tst x25,#7
 b.ne .Lgrid_bad
 ldr x9,[x19,#16]
 cmp x9,#8
 b.ne .Lgrid_bad
 ldr x9,[x19,#32]
 cmp x9,#8
 b.ne .Lgrid_bad
 ldr x9,[x19,#40]
 cmp x9,#1
 b.ne .Lgrid_bad
 ldr x9,[x19,#48]
 cmp x9,#1
 b.ne .Lgrid_bad
 ldr x9,[x19,#56]
 cmp x9,#24
 b.lt .Lgrid_bad
 ldr x9,[x19,#72]
 cmp x9,#1
 b.ne .Lgrid_bad
 ldrb w26,[x19,#28]
 cmp w26,#3
 b.eq .Lgrid_group_rank3
 cmp w26,#4
 b.ne .Lgrid_bad
 ldr x9,[x19,#96]
 cmp x9,#1
 b.ne .Lgrid_bad
 ldr x9,[x19,#120]
 cmp x9,#1
 b.ne .Lgrid_bad
 ldr x9,[x19,#128]
 cmp x9,#86
 b.lt .Lgrid_bad
 ldr x9,[x19,#80]
 cmp x9,x22
 b.lt .Lgrid_bad
 add w9,w24,w23
 sub w9,w9,#1
 ldr x10,[x19,#104]
 cmp x10,x9
 b.lt .Lgrid_bad
 b .Lgrid_group_begin
.Lgrid_group_rank3:
 cmp w22,#1
 b.ne .Lgrid_bad
 ldr x9,[x19,#96]
 cmp x9,#1
 b.ne .Lgrid_bad
 ldr x9,[x19,#104]
 cmp x9,#86
 b.lt .Lgrid_bad
 add w9,w24,w23
 sub w9,w9,#1
 ldr x10,[x19,#80]
 cmp x10,x9
 b.lt .Lgrid_bad
.Lgrid_group_begin:
 mov w27,#0
.Lgrid_group_parameter:
 mov w28,#1
.Lgrid_group_level:
 cmp w21,#1
 b.lt .Lgrid_bad
 cmp w21,#136
 b.gt .Lgrid_bad
 ldr x9,[x19,#8]
 ldr x10,[x19,#64]
 add w11,w24,w27
 cmp w26,#3
 b.eq .Lgrid_group_rank3_address
 madd x9,x28,x10,x9
 ldr x10,[x19,#88]
 madd x9,x11,x10,x9
 ldr x10,[x19,#112]
 b .Lgrid_group_record
.Lgrid_group_rank3_address:
 madd x9,x11,x10,x9
 ldr x10,[x19,#88]
.Lgrid_group_record:
 add x9,x25,x9,lsl #3
 lsl x10,x10,#3
 sub w11,w21,#1
 lsl x11,x11,#5
 add x11,x20,x11
 str x9,[x11]
 mov x12,#8
 str x12,[x11,#8]
 str x10,[x11,#16]
 mov x12,#1
 str x12,[x11,#24]
 add w21,w21,#1
 add w28,w28,#1
 cmp w28,w22
 b.le .Lgrid_group_level
 add w27,w27,#1
 cmp w27,w23
 b.lt .Lgrid_group_parameter
.Lgrid_group_done:
 mov w0,w21
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x18,x30,[sp],#112
 ret
// Map all three scalar categories for base, north/south or east/west phase.
.Lgrid_scalar_groups:
 stp x18,x30,[sp,#-64]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 str x23,[sp,#48]
 mov x19,x0
 mov x20,x1
 mov w21,w2
 mov w22,w3
 mov w23,#0
.Lgrid_scalar_category:
 cmp w23,#0
 b.ne .Lgrid_scalar_rank4
 ldr x0,[x19,#240]
 cbz x0,.Lgrid_scalar_next
 mov w3,#1
 ldr w4,[x0,#80]
 b .Lgrid_scalar_counts
.Lgrid_scalar_rank4:
 cmp w23,#1
 b.ne .Lgrid_scalar_B
 ldr x0,[x19,#224]
 b .Lgrid_scalar_pointer
.Lgrid_scalar_B:
 ldr x0,[x19,#232]
.Lgrid_scalar_pointer:
 cbz x0,.Lgrid_scalar_next
 ldr w3,[x0,#80]
 ldr w4,[x0,#104]
.Lgrid_scalar_counts:
 ldr w9,[x19,#296]
 cbz w9,.Lgrid_scalar_not_derivative
 mov w9,#3
 udiv w4,w4,w9
.Lgrid_scalar_not_derivative:
 mul w5,w4,w22
 add w5,w5,#1
 mov x1,x20
 mov w2,w21
 bl .Lgrid_map_group
 mov w21,w0
.Lgrid_scalar_next:
 add w23,w23,#1
 cmp w23,#3
 b.lt .Lgrid_scalar_category
 mov w0,w21
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldr x23,[sp,#48]
 ldp x18,x30,[sp],#64
 ret
.Lgrid_int1:
 ldr x9,[x0]
 cbz x9,.Lgrid_bad
 ldr x10,[x0,#16]
 cmp x10,#4
 b.ne .Lgrid_bad
 ldrb w10,[x0,#28]
 cmp w10,#1
 b.ne .Lgrid_bad
 ldr x10,[x0,#48]
 cmp x1,x10
 b.lt .Lgrid_bad
 ldr x10,[x0,#56]
 cmp x1,x10
 b.gt .Lgrid_bad
 ldr x10,[x0,#8]
 ldr x11,[x0,#40]
 madd x10,x1,x11,x10
 ldr w0,[x9,x10,lsl #2]
 ret
.Lgrid_int2:
 ldr x9,[x0]
 cbz x9,.Lgrid_bad
 ldr x10,[x0,#16]
 cmp x10,#4
 b.ne .Lgrid_bad
 ldrb w10,[x0,#28]
 cmp w10,#2
 b.ne .Lgrid_bad
 ldr x10,[x0,#48]
 cmp x1,x10
 b.lt .Lgrid_bad
 ldr x10,[x0,#56]
 cmp x1,x10
 b.gt .Lgrid_bad
 ldr x10,[x0,#72]
 cmp x2,x10
 b.lt .Lgrid_bad
 ldr x10,[x0,#80]
 cmp x2,x10
 b.gt .Lgrid_bad
 ldr x10,[x0,#8]
 ldr x11,[x0,#40]
 madd x10,x1,x11,x10
 ldr x11,[x0,#64]
 madd x10,x2,x11,x10
 ldr w0,[x9,x10,lsl #2]
 ret
.Lgrid_bad:
 bl abort
 brk #0
.global md2asm_grid_transform_copy_count_get
.type md2asm_grid_transform_copy_count_get,%function
md2asm_grid_transform_copy_count_get:
 cmp w0,#2
 b.hs .Lgrid_count_zero
 adrp x9,.Lgrid_counts
 add x9,x9,:lo12:.Lgrid_counts
 ldr x0,[x9,x0,lsl #3]
 ret
.Lgrid_count_zero:
 mov x0,#0
 ret
.data
.p2align 3
.Lgrid_counts: .quad 0,0
.Lphase_0: .word 0
.Lphase_1: .word 1
.Lbarrier_761: .word 761
.Lbarrier_762: .word 762
.Lname_trltog: .asciz "TRLTOG"
.Lname_trgtol: .asciz "TRGTOL"
.Lname_trltog_bar: .asciz "TRLTOG_BAR"
.Lname_trgtol_bar: .asciz "TRGTOL_BAR"
.Levent_1805: .word 1805
.Levent_1806: .word 1806
.Levent_1601: .word 1601
.Levent_1604: .word 1604
.Levent_801: .word 801
.Levent_805: .word 805
.Levent_803: .word 803
.Levent_804: .word 804
.Levent_807: .word 807
.Levent_808: .word 808
.section .note.GNU-stack,"",%progbits
