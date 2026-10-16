/* INV_TRANS and DIR_TRANS.
 * Contract: skills/md2asm/references/openifs/dynamics/retained_forecast_callers.md.
 * Original by-address interfaces and frozen child order are retained. */
.arch armv8-a
.text
.p2align 4
.macro GLOBAL r,name
 adrp \r,:got:\name
 ldr \r,[\r,:got_lo12:\name]
.endm
.macro STORE value,name
 GLOBAL x9,\name
 str \value,[x9]
.endm
.macro EVENT id,phase
 adrp x0,.Levent_\id
 add x0,x0,:lo12:.Levent_\id
 adrp x1,.Lphase_\phase
 add x1,x1,:lo12:.Lphase_\phase
 bl gstats_
.endm
.macro PROFILE name,phase,length
 GLOBAL x9,__yomhook_MOD_lhook
 ldr w9,[x9]
 cbz w9,91f
 adrp x0,.Lname_\name
 add x0,x0,:lo12:.Lname_\name
 adrp x1,.Lphase_\phase
 add x1,x1,:lo12:.Lphase_\phase
 add x2,sp,#752
 mov x3,#\length
 bl __yomhook_MOD_dr_hook_default8
91:
.endm
.global md2asm_inv_trans_7358525
.type md2asm_inv_trans_7358525,%function
md2asm_inv_trans_7358525:
 mov x17,sp
 sub sp,sp,#896
 stp x18,x30,[sp,#160]
 stp x19,x20,[sp,#176]
 stp x21,x22,[sp,#192]
 stp x23,x24,[sp,#208]
 stp x25,x26,[sp,#224]
 stp x27,x28,[sp,#240]
 str x29,[sp,#256]
 str x0,[sp,#288]
 str x1,[sp,#296]
 str x2,[sp,#304]
 str x3,[sp,#312]
 str x4,[sp,#320]
 str x5,[sp,#328]
 str x6,[sp,#336]
 str x7,[sp,#344]
 ldr x9,[x17,#0]
 str x9,[sp,#352]
 ldr x9,[x17,#8]
 str x9,[sp,#360]
 ldr x9,[x17,#16]
 str x9,[sp,#368]
 ldr x9,[x17,#24]
 str x9,[sp,#376]
 ldr x9,[x17,#32]
 str x9,[sp,#384]
 ldr x9,[x17,#40]
 str x9,[sp,#392]
 ldr x9,[x17,#48]
 str x9,[sp,#400]
 ldr x9,[x17,#56]
 str x9,[sp,#408]
 ldr x9,[x17,#64]
 str x9,[sp,#416]
 ldr x9,[x17,#72]
 str x9,[sp,#424]
 ldr x9,[x17,#80]
 str x9,[sp,#432]
 ldr x9,[x17,#88]
 str x9,[sp,#440]
 ldr x9,[x17,#96]
 str x9,[sp,#448]
 ldr x9,[x17,#104]
 str x9,[sp,#456]
 ldr x9,[x17,#112]
 str x9,[sp,#464]
 ldr x9,[x17,#120]
 str x9,[sp,#472]
 mrs x9,fpcr
 cbnz x9,.Lapi_guard_site_87
 ldr x9,[sp,#336]
 cbnz x9,.Lapi_guard_site_89
 GLOBAL x9,__tpm_distr_MOD_nproc
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lapi_guard_site_93
 GLOBAL x9,__tpm_distr_MOD_nprtrv
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lapi_guard_site_97
 GLOBAL x9,__tpm_distr_MOD_mysetv
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lapi_guard_site_101
 GLOBAL x9,__tpm_gen_MOD_npromatr
 ldr w9,[x9]
 cmp w9,#0
 b.gt .Lapi_guard_site_105
 GLOBAL x9,__tpm_gen_MOD_msetup0
 ldr w9,[x9]
 cbz w9,.Lapi_guard_site_108
 GLOBAL x9,__tpm_gen_MOD_ncur_resol
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lapi_guard_site_112
 ldr x9,[sp,#408]
 cbz x9,.Linv_trans_res_checked
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lapi_guard_site_117
 GLOBAL x9,__tpm_gen_MOD_nmax_resol
 ldr w9,[x9]
 cmp w9,#1
 b.lt .Lapi_guard_site_121
 GLOBAL x0,__tpm_gen_MOD_lenabled
 mov x1,#1
 bl .Lapi_int1
 cbz w0,.Lapi_guard_site_125
.Linv_trans_res_checked:
 ldr x9,[sp,#384]
 cbz x9,.Lapi_guard_site_128
 ldr w9,[x9]
 cmp w9,#24
 b.ne .Lapi_guard_site_131
 ldr x9,[sp,#376]
 cbz x9,.Linv_trans_lat_checked
 ldr w9,[x9]
 cbnz w9,.Lapi_guard_site_135
.Linv_trans_lat_checked:
 GLOBAL x9,__tpm_distr_MOD_d
 ldr x19,[x9]
 cbz x19,.Lapi_guard_site_139
 ldr w9,[x19,#2352]
 cmp w9,#2048
 b.ne .Lapi_guard_site_142
 ldr x0,[sp,#288]
 ldr x1,[sp,#392]
 mov w2,#2
 bl .Lapi_count
 str w0,[sp,#600]
 str w1,[sp,#632]
 str w2,[sp,#664]
 ldr x0,[sp,#304]
 ldr x1,[sp,#400]
 mov w2,#2
 bl .Lapi_count
 str w0,[sp,#604]
 str w1,[sp,#636]
 str w2,[sp,#668]
 ldr x0,[sp,#328]
 ldr x1,[sp,#432]
 mov w2,#2
 bl .Lapi_count
 str w0,[sp,#608]
 str w1,[sp,#640]
 str w2,[sp,#672]
 ldr x0,[sp,#312]
 ldr x1,[sp,#416]
 mov w2,#3
 bl .Lapi_count
 str w0,[sp,#612]
 str w1,[sp,#644]
 str w2,[sp,#676]
 ldr x0,[sp,#320]
 ldr x1,[sp,#424]
 mov w2,#3
 bl .Lapi_count
 str w0,[sp,#616]
 str w1,[sp,#648]
 str w2,[sp,#680]
 ldr w20,[sp,#600]
 ldr w21,[sp,#604]
 ldr w9,[sp,#608]
 add w21,w21,w9
 ldr w9,[sp,#612]
 add w21,w21,w9
 ldr w9,[sp,#616]
 add w21,w21,w9
 cmp w21,#136
 b.gt .Lapi_guard_site_187
 ldr x9,[sp,#304]
 cbz x9,.Linv_trans_scalar_layout
 ldr x10,[sp,#312]
 ldr x11,[sp,#320]
 orr x10,x10,x11
 ldr x11,[sp,#328]
 orr x10,x10,x11
 cbnz x10,.Lapi_guard_site_195
.Linv_trans_scalar_layout:
 mov w22,#0
 mov w23,#0
 mov w24,#0
 mov w25,#0
 ldr x9,[sp,#344]
 cbz x9,.Linv_trans_flag_7_done
 ldr w22,[x9]
 cmp w22,#1
 b.hi .Lapi_guard_site_205
.Linv_trans_flag_7_done:
 ldr x9,[sp,#352]
 cbz x9,.Linv_trans_flag_8_done
 ldr w23,[x9]
 cmp w23,#1
 b.hi .Lapi_guard_site_211
.Linv_trans_flag_8_done:
 ldr x9,[sp,#360]
 cbz x9,.Linv_trans_flag_9_done
 ldr w24,[x9]
 cmp w24,#1
 b.hi .Lapi_guard_site_217
.Linv_trans_flag_9_done:
 ldr x9,[sp,#368]
 cbz x9,.Linv_trans_flag_10_done
 ldr w25,[x9]
 cmp w25,#1
 b.hi .Lapi_guard_site_223
.Linv_trans_flag_10_done:
 cbnz w21,.Linv_trans_has_scalars
 mov w22,#0
.Linv_trans_has_scalars:
 cbz w23,.Linv_trans_divflag_done
 mov w24,#1
.Linv_trans_divflag_done:
 cbnz w20,.Linv_trans_windflag_done
 mov w25,#0
.Linv_trans_windflag_done:
 mul w26,w21,w22
 lsl w27,w20,#1
 add w27,w27,w21
 add w27,w27,w26
 madd w27,w20,w23,w27
 madd w27,w20,w24,w27
 add w28,w27,w26
 lsl w9,w20,#1
 madd w28,w9,w25,w28
 cmp w28,#1
 b.lt .Lapi_guard_site_244
 cmp w28,#136
 b.gt .Lapi_guard_site_246
 str w20,[sp,#704]
 str w21,[sp,#708]
 str w26,[sp,#712]
 str w27,[sp,#716]
 str w28,[sp,#720]
 str w28,[sp,#724]
 cbz w20,.Linv_trans_uv_bounds_done
 ldr x0,[sp,#288]
 mov w1,#2
 mov w2,w20
 bl .Lapi_spectral_bound
 ldr x0,[sp,#296]
 mov w1,#2
 mov w2,w20
 bl .Lapi_spectral_bound
.Linv_trans_uv_bounds_done:
 ldr x0,[sp,#440]
 cbz x0,.Linv_trans_split_targets
 ldr x9,[sp,#448]
 cbnz x9,.Lapi_guard_site_266
 ldr x9,[sp,#456]
 cbnz x9,.Lapi_guard_site_268
 ldr x9,[sp,#464]
 cbnz x9,.Lapi_guard_site_270
 ldr x9,[sp,#472]
 cbnz x9,.Lapi_guard_site_272
 mov w1,#3
 mov w2,w28
 mov w3,#1
 mov w4,#0
 mov w5,#0
 bl .Lapi_grid_bound
 b .Linv_trans_targets_done
.Linv_trans_split_targets:
 ldr x0,[sp,#448]
 cbz w20,.Linv_trans_wind_target_zero
 mov w1,#4
 mov w2,w20
 add w3,w23,w24
 add w3,w3,#2
 add w3,w3,w25,lsl #1
 mov w4,#1
 mov w5,#0
 bl .Lapi_grid_bound
 b .Linv_trans_wind_target_done
.Linv_trans_wind_target_zero:
 cbnz x0,.Lapi_guard_site_293
.Linv_trans_wind_target_done:
 ldr w2,[sp,#640]
 ldr w3,[sp,#672]
 ldr x0,[sp,#472]
 cbz w2,.Linv_trans_target_5_zero
 // Scalar expansion is 1+2*LSCDERS.
 mov w9,#2
 mul w9,w9,w22
 add w9,w9,#1
 mul w2,w2,w9
 mov w1,#3
 mov w4,#1
 mov w5,#1
 bl .Lapi_grid_bound
 b .Linv_trans_target_5_done
.Linv_trans_target_5_zero:
 cbnz x0,.Lapi_guard_site_310
.Linv_trans_target_5_done:
 ldr w2,[sp,#644]
 ldr w3,[sp,#676]
 ldr x0,[sp,#456]
 cbz w2,.Linv_trans_target_3_zero
 mov w9,#2
 mul w9,w9,w22
 add w9,w9,#1
 mul w3,w3,w9
 mov w1,#4
 mov w4,#1
 mov w5,#1
 bl .Lapi_grid_bound
 b .Linv_trans_target_3_done
.Linv_trans_target_3_zero:
 cbnz x0,.Lapi_guard_site_326
.Linv_trans_target_3_done:
 ldr w2,[sp,#648]
 ldr w3,[sp,#680]
 ldr x0,[sp,#464]
 cbz w2,.Linv_trans_target_4_zero
 mov w9,#2
 mul w9,w9,w22
 add w9,w9,#1
 mul w3,w3,w9
 mov w1,#4
 mov w4,#1
 mov w5,#1
 bl .Lapi_grid_bound
 b .Linv_trans_target_4_done
.Linv_trans_target_4_zero:
 cbnz x0,.Lapi_guard_site_342
.Linv_trans_target_4_done:
.Linv_trans_targets_done:
 PROFILE inv_trans,0,9
 EVENT 1807,0
 STORE w23,__tpm_trans_MOD_lvorgp
 STORE w24,__tpm_trans_MOD_ldivgp
 STORE w25,__tpm_trans_MOD_luvder
 STORE w22,__tpm_trans_MOD_lscders
 STORE wzr,__tpm_trans_MOD_latlon
 mov w9,#24
 GLOBAL x10,__tpm_trans_MOD_nproma
 str w9,[x10]
 mov w9,#86
 GLOBAL x10,__tpm_trans_MOD_ngpblks
 str w9,[x10]
 ldr w11,[sp,#640]
 STORE w11,__tpm_trans_MOD_nf_sc2
 ldr w11,[sp,#644]
 STORE w11,__tpm_trans_MOD_nf_sc3a
 ldr w11,[sp,#648]
 STORE w11,__tpm_trans_MOD_nf_sc3b
 EVENT 1807,1
 add x0,sp,#704
 add x1,sp,#708
 add x2,sp,#724
 add x3,sp,#720
 add x4,sp,#716
 add x5,sp,#704
 add x6,sp,#708
 add x7,sp,#712
 ldr x9,[sp,#288]
 str x9,[sp,#0]
 ldr x9,[sp,#296]
 str x9,[sp,#8]
 ldr x9,[sp,#304]
 str x9,[sp,#16]
 ldr x9,[sp,#392]
 str x9,[sp,#24]
 ldr x9,[sp,#400]
 str x9,[sp,#32]
 ldr x9,[sp,#440]
 str x9,[sp,#40]
 ldr x9,[sp,#336]
 str x9,[sp,#48]
 ldr x9,[sp,#312]
 str x9,[sp,#56]
 ldr x9,[sp,#320]
 str x9,[sp,#64]
 ldr x9,[sp,#328]
 str x9,[sp,#72]
 ldr x9,[sp,#416]
 str x9,[sp,#80]
 ldr x9,[sp,#424]
 str x9,[sp,#88]
 ldr x9,[sp,#432]
 str x9,[sp,#96]
 ldr x9,[sp,#448]
 str x9,[sp,#104]
 ldr x9,[sp,#456]
 str x9,[sp,#112]
 ldr x9,[sp,#464]
 str x9,[sp,#120]
 ldr x9,[sp,#472]
 str x9,[sp,#128]
 bl md2asm_inv_trans_ctl_7358525
 PROFILE inv_trans,1,9
 adrp x9,.Lapi_counts
 add x9,x9,:lo12:.Lapi_counts
 ldr x10,[x9,#0]
 add x10,x10,#1
 str x10,[x9,#0]
 ldp x18,x30,[sp,#160]
 ldp x19,x20,[sp,#176]
 ldp x21,x22,[sp,#192]
 ldp x23,x24,[sp,#208]
 ldp x25,x26,[sp,#224]
 ldp x27,x28,[sp,#240]
 ldr x29,[sp,#256]
 add sp,sp,#896
 ret
.size md2asm_inv_trans_7358525,.-md2asm_inv_trans_7358525
.global md2asm_dir_trans_7358525
.type md2asm_dir_trans_7358525,%function
md2asm_dir_trans_7358525:
 mov x17,sp
 sub sp,sp,#896
 stp x18,x30,[sp,#160]
 stp x19,x20,[sp,#176]
 stp x21,x22,[sp,#192]
 stp x23,x24,[sp,#208]
 stp x25,x26,[sp,#224]
 stp x27,x28,[sp,#240]
 str x29,[sp,#256]
 str x0,[sp,#288]
 str x1,[sp,#296]
 str x2,[sp,#304]
 str x3,[sp,#312]
 str x4,[sp,#320]
 str x5,[sp,#328]
 str x6,[sp,#336]
 str x7,[sp,#344]
 ldr x9,[x17,#0]
 str x9,[sp,#352]
 ldr x9,[x17,#8]
 str x9,[sp,#360]
 ldr x9,[x17,#16]
 str x9,[sp,#368]
 ldr x9,[x17,#24]
 str x9,[sp,#376]
 ldr x9,[x17,#32]
 str x9,[sp,#384]
 ldr x9,[x17,#40]
 str x9,[sp,#392]
 ldr x9,[x17,#48]
 str x9,[sp,#400]
 ldr x9,[x17,#56]
 str x9,[sp,#408]
 ldr x9,[x17,#64]
 str x9,[sp,#416]
 ldr x9,[x17,#72]
 str x9,[sp,#424]
 ldr x9,[x17,#80]
 str x9,[sp,#432]
 mrs x9,fpcr
 cbnz x9,.Lapi_guard_site_467
 GLOBAL x9,__tpm_distr_MOD_nproc
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lapi_guard_site_471
 GLOBAL x9,__tpm_distr_MOD_nprtrv
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lapi_guard_site_475
 GLOBAL x9,__tpm_distr_MOD_mysetv
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lapi_guard_site_479
 GLOBAL x9,__tpm_gen_MOD_npromatr
 ldr w9,[x9]
 cmp w9,#0
 b.gt .Lapi_guard_site_483
 GLOBAL x9,__tpm_gen_MOD_msetup0
 ldr w9,[x9]
 cbz w9,.Lapi_guard_site_486
 GLOBAL x9,__tpm_gen_MOD_ncur_resol
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lapi_guard_site_490
 ldr x9,[sp,#368]
 cbz x9,.Ldir_trans_res_checked
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lapi_guard_site_495
 GLOBAL x9,__tpm_gen_MOD_nmax_resol
 ldr w9,[x9]
 cmp w9,#1
 b.lt .Lapi_guard_site_499
 GLOBAL x0,__tpm_gen_MOD_lenabled
 mov x1,#1
 bl .Lapi_int1
 cbz w0,.Lapi_guard_site_503
.Ldir_trans_res_checked:
 ldr x9,[sp,#344]
 cbz x9,.Lapi_guard_site_506
 ldr w9,[x9]
 cmp w9,#24
 b.ne .Lapi_guard_site_509
 ldr x9,[sp,#336]
 cbz x9,.Ldir_trans_lat_checked
 ldr w9,[x9]
 cbnz w9,.Lapi_guard_site_513
.Ldir_trans_lat_checked:
 GLOBAL x9,__tpm_distr_MOD_d
 ldr x19,[x9]
 cbz x19,.Lapi_guard_site_517
 ldr w9,[x19,#2352]
 cmp w9,#2048
 b.ne .Lapi_guard_site_520
 ldr x0,[sp,#288]
 ldr x1,[sp,#352]
 mov w2,#2
 bl .Lapi_count
 str w0,[sp,#600]
 str w1,[sp,#632]
 str w2,[sp,#664]
 ldr x0,[sp,#304]
 ldr x1,[sp,#360]
 mov w2,#2
 bl .Lapi_count
 str w0,[sp,#604]
 str w1,[sp,#636]
 str w2,[sp,#668]
 ldr x0,[sp,#328]
 ldr x1,[sp,#392]
 mov w2,#2
 bl .Lapi_count
 str w0,[sp,#608]
 str w1,[sp,#640]
 str w2,[sp,#672]
 ldr x0,[sp,#312]
 ldr x1,[sp,#376]
 mov w2,#3
 bl .Lapi_count
 str w0,[sp,#612]
 str w1,[sp,#644]
 str w2,[sp,#676]
 ldr x0,[sp,#320]
 ldr x1,[sp,#384]
 mov w2,#3
 bl .Lapi_count
 str w0,[sp,#616]
 str w1,[sp,#648]
 str w2,[sp,#680]
 ldr w20,[sp,#600]
 ldr w21,[sp,#604]
 ldr w9,[sp,#608]
 add w21,w21,w9
 ldr w9,[sp,#612]
 add w21,w21,w9
 ldr w9,[sp,#616]
 add w21,w21,w9
 cmp w21,#136
 b.gt .Lapi_guard_site_565
 ldr x9,[sp,#304]
 cbz x9,.Ldir_trans_scalar_layout
 ldr x10,[sp,#312]
 ldr x11,[sp,#320]
 orr x10,x10,x11
 ldr x11,[sp,#328]
 orr x10,x10,x11
 cbnz x10,.Lapi_guard_site_573
.Ldir_trans_scalar_layout:
 mov w22,#0
 mov w23,#0
 mov w24,#0
 mov w25,#0
 mul w26,w21,w22
 lsl w27,w20,#1
 add w27,w27,w21
 add w27,w27,w26
 madd w27,w20,w23,w27
 madd w27,w20,w24,w27
 add w28,w27,w26
 lsl w9,w20,#1
 madd w28,w9,w25,w28
 cmp w28,#1
 b.lt .Lapi_guard_site_589
 cmp w28,#136
 b.gt .Lapi_guard_site_591
 str w20,[sp,#704]
 str w21,[sp,#708]
 str w26,[sp,#712]
 str w27,[sp,#716]
 str w28,[sp,#720]
 str w28,[sp,#724]
 cbz w20,.Ldir_trans_uv_bounds_done
 ldr x0,[sp,#288]
 mov w1,#2
 mov w2,w20
 bl .Lapi_spectral_bound
 ldr x0,[sp,#296]
 mov w1,#2
 mov w2,w20
 bl .Lapi_spectral_bound
.Ldir_trans_uv_bounds_done:
 ldr x0,[sp,#400]
 cbz x0,.Ldir_trans_split_targets
 ldr x9,[sp,#408]
 cbnz x9,.Lapi_guard_site_611
 ldr x9,[sp,#416]
 cbnz x9,.Lapi_guard_site_613
 ldr x9,[sp,#424]
 cbnz x9,.Lapi_guard_site_615
 ldr x9,[sp,#432]
 cbnz x9,.Lapi_guard_site_617
 mov w1,#3
 mov w2,w28
 mov w3,#1
 mov w4,#0
 mov w5,#0
 bl .Lapi_grid_bound
 b .Ldir_trans_targets_done
.Ldir_trans_split_targets:
 ldr x0,[sp,#408]
 cbz w20,.Ldir_trans_wind_target_zero
 mov w1,#4
 mov w2,w20
 add w3,w23,w24
 add w3,w3,#2
 add w3,w3,w25,lsl #1
 mov w4,#1
 mov w5,#0
 bl .Lapi_grid_bound
 b .Ldir_trans_wind_target_done
.Ldir_trans_wind_target_zero:
 cbnz x0,.Lapi_guard_site_638
.Ldir_trans_wind_target_done:
 ldr w2,[sp,#640]
 ldr w3,[sp,#672]
 ldr x0,[sp,#432]
 cbz w2,.Ldir_trans_target_5_zero
 // Scalar expansion is 1+2*LSCDERS.
 mov w9,#2
 mul w9,w9,w22
 add w9,w9,#1
 mul w2,w2,w9
 mov w1,#3
 mov w4,#1
 mov w5,#1
 bl .Lapi_grid_bound
 b .Ldir_trans_target_5_done
.Ldir_trans_target_5_zero:
 cbnz x0,.Lapi_guard_site_655
.Ldir_trans_target_5_done:
 ldr w2,[sp,#644]
 ldr w3,[sp,#676]
 ldr x0,[sp,#416]
 cbz w2,.Ldir_trans_target_3_zero
 mov w9,#2
 mul w9,w9,w22
 add w9,w9,#1
 mul w3,w3,w9
 mov w1,#4
 mov w4,#1
 mov w5,#1
 bl .Lapi_grid_bound
 b .Ldir_trans_target_3_done
.Ldir_trans_target_3_zero:
 cbnz x0,.Lapi_guard_site_671
.Ldir_trans_target_3_done:
 ldr w2,[sp,#648]
 ldr w3,[sp,#680]
 ldr x0,[sp,#424]
 cbz w2,.Ldir_trans_target_4_zero
 mov w9,#2
 mul w9,w9,w22
 add w9,w9,#1
 mul w3,w3,w9
 mov w1,#4
 mov w4,#1
 mov w5,#1
 bl .Lapi_grid_bound
 b .Ldir_trans_target_4_done
.Ldir_trans_target_4_zero:
 cbnz x0,.Lapi_guard_site_687
.Ldir_trans_target_4_done:
.Ldir_trans_targets_done:
 PROFILE dir_trans,0,9
 EVENT 1808,0
 STORE w23,__tpm_trans_MOD_lvorgp
 STORE w24,__tpm_trans_MOD_ldivgp
 STORE w25,__tpm_trans_MOD_luvder
 STORE w22,__tpm_trans_MOD_lscders
 STORE wzr,__tpm_trans_MOD_latlon
 mov w9,#24
 GLOBAL x10,__tpm_trans_MOD_nproma
 str w9,[x10]
 mov w9,#86
 GLOBAL x10,__tpm_trans_MOD_ngpblks
 str w9,[x10]
 ldr w11,[sp,#640]
 STORE w11,__tpm_trans_MOD_nf_sc2
 ldr w11,[sp,#644]
 STORE w11,__tpm_trans_MOD_nf_sc3a
 ldr w11,[sp,#648]
 STORE w11,__tpm_trans_MOD_nf_sc3b
 EVENT 1808,1
 add x0,sp,#704
 add x1,sp,#708
 add x2,sp,#724
 add x3,sp,#720
 add x4,sp,#704
 add x5,sp,#708
 ldr x6,[sp,#288]
 ldr x7,[sp,#296]
 ldr x9,[sp,#304]
 str x9,[sp,#0]
 ldr x9,[sp,#352]
 str x9,[sp,#8]
 ldr x9,[sp,#360]
 str x9,[sp,#16]
 ldr x9,[sp,#400]
 str x9,[sp,#24]
 ldr x9,[sp,#312]
 str x9,[sp,#32]
 ldr x9,[sp,#320]
 str x9,[sp,#40]
 ldr x9,[sp,#328]
 str x9,[sp,#48]
 ldr x9,[sp,#376]
 str x9,[sp,#56]
 ldr x9,[sp,#384]
 str x9,[sp,#64]
 ldr x9,[sp,#392]
 str x9,[sp,#72]
 ldr x9,[sp,#408]
 str x9,[sp,#80]
 ldr x9,[sp,#416]
 str x9,[sp,#88]
 ldr x9,[sp,#424]
 str x9,[sp,#96]
 ldr x9,[sp,#432]
 str x9,[sp,#104]
 bl md2asm_dir_trans_ctl_7358525
 PROFILE dir_trans,1,9
 adrp x9,.Lapi_counts
 add x9,x9,:lo12:.Lapi_counts
 ldr x10,[x9,#8]
 add x10,x10,#1
 str x10,[x9,#8]
 ldp x18,x30,[sp,#160]
 ldp x19,x20,[sp,#176]
 ldp x21,x22,[sp,#192]
 ldp x23,x24,[sp,#208]
 ldp x25,x26,[sp,#224]
 ldp x27,x28,[sp,#240]
 ldr x29,[sp,#256]
 add sp,sp,#896
 ret
.size md2asm_dir_trans_7358525,.-md2asm_dir_trans_7358525
// x0 spectral descriptor, x1 optional field-set descriptor, w2 rank.
// Return total fields w0, first-dimension category width w1, parameters w2.
.Lapi_count:
 stp x18,x30,[sp,#-64]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 mov x19,x0
 mov x20,x1
 mov w21,w2
 mov w22,#0
 mov w23,#0
 cbz x19,.Lapi_count_absent
 ldr x9,[x19,#16]
 cmp x9,#8
 b.ne .Lapi_guard_site_778
 ldrb w9,[x19,#28]
 cmp w9,w21
 b.ne .Lapi_guard_site_781
 ldr x9,[x19,#48]
 cmp x9,#1
 b.ne .Lapi_guard_site_784
 ldr w22,[x19,#56]
 cmp w22,#0
 b.lt .Lapi_guard_site_787
 cmp w22,#136
 b.gt .Lapi_guard_site_789
 mov w23,#1
 cmp w21,#2
 b.eq .Lapi_count_width
 ldr x9,[x19,#96]
 cmp x9,#1
 b.ne .Lapi_guard_site_795
 ldr w23,[x19,#104]
 cmp w23,#0
 b.lt .Lapi_guard_site_798
 cmp w23,#136
 b.gt .Lapi_guard_site_800
.Lapi_count_width:
 cbz x20,.Lapi_count_done
 ldr x9,[x20,#16]
 cmp x9,#4
 b.ne .Lapi_guard_site_805
 ldrb w9,[x20,#28]
 cmp w9,#1
 b.ne .Lapi_guard_site_808
 ldr x9,[x20,#48]
 cmp x9,#1
 b.ne .Lapi_guard_site_811
 ldr w24,[x20,#56]
 cmp w24,#0
 b.lt .Lapi_guard_site_814
 cmp w24,w22
 b.gt .Lapi_guard_site_816
 mov w22,w24
 mov w24,#1
.Lapi_count_set:
 cmp w24,w22
 b.gt .Lapi_count_done
 mov x0,x20
 sxtw x1,w24
 bl .Lapi_int1
 cmp w0,#1
 b.ne .Lapi_guard_site_826
 add w24,w24,#1
 b .Lapi_count_set
.Lapi_count_absent:
 cbnz x20,.Lapi_guard_site_830
.Lapi_count_done:
 mul w0,w22,w23
 mov w1,w22
 mov w2,w23
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x18,x30,[sp],#64
 ret
.Lapi_spectral_bound:
 cbz x0,.Lapi_guard_site_841
 ldr x9,[x0]
 cbz x9,.Lapi_guard_site_843
 ldrb w9,[x0,#28]
 cmp w9,w1
 b.ne .Lapi_guard_site_846
 ldr x9,[x0,#16]
 cmp x9,#8
 b.ne .Lapi_guard_site_849
 ldr x9,[x0,#48]
 cmp x9,#1
 b.ne .Lapi_guard_site_852
 ldr w9,[x0,#56]
 cmp w9,w2
 b.lt .Lapi_guard_site_855
 ret
// w4 selects exact category shapes or a generic grid array's minimum width.
.Lapi_grid_bound:
 cbz x0,.Lapi_guard_site_859
 ldr x9,[x0]
 cbz x9,.Lapi_guard_site_861
 tst x9,#7
 b.ne .Lapi_guard_site_863
 ldrb w9,[x0,#28]
 cmp w9,w1
 b.ne .Lapi_guard_site_866
 ldr x9,[x0,#16]
 cmp x9,#8
 b.ne .Lapi_guard_site_869
 ldr x9,[x0,#48]
 cmp x9,#1
 b.ne .Lapi_guard_site_872
 ldr x9,[x0,#56]
 cmp x9,#24
 b.lt .Lapi_guard_site_875
 ldr x9,[x0,#72]
 cmp x9,#1
 b.ne .Lapi_guard_site_878
 ldr w9,[x0,#80]
 cmp w9,w2
 b.lt .Lapi_guard_site_881
 cbz w4,.Lapi_grid_width_done
 b.ne .Lapi_guard_site_883
.Lapi_grid_width_done:
 ldr x9,[x0,#96]
 cmp x9,#1
 b.ne .Lapi_guard_site_887
 cmp w1,#3
 b.eq .Lapi_grid_rank3
 ldr w9,[x0,#104]
 cmp w9,w3
 b.lt .Lapi_guard_site_892
 cbz w5,.Lapi_grid_parameter_done
 b.ne .Lapi_guard_site_894
.Lapi_grid_parameter_done:
 ldr x9,[x0,#120]
 cmp x9,#1
 b.ne .Lapi_guard_site_898
 ldr x9,[x0,#128]
 cmp x9,#86
 b.lt .Lapi_guard_site_901
 ret
.Lapi_grid_rank3:
 ldr x9,[x0,#104]
 cmp x9,#86
 b.lt .Lapi_guard_site_906
 ret
.Lapi_int1:
 ldr x9,[x0]
 cbz x9,.Lapi_guard_site_910
 ldr x10,[x0,#16]
 cmp x10,#4
 b.ne .Lapi_guard_site_913
 ldrb w10,[x0,#28]
 cmp w10,#1
 b.ne .Lapi_guard_site_916
 ldr x10,[x0,#48]
 cmp x1,x10
 b.lt .Lapi_guard_site_919
 ldr x10,[x0,#56]
 cmp x1,x10
 b.gt .Lapi_guard_site_922
 ldr x10,[x0,#8]
 ldr x11,[x0,#40]
 madd x10,x1,x11,x10
 ldr w0,[x9,x10,lsl #2]
 ret
.Lapi_guard_site_87:
 mov w17,#87
 b .Lapi_guard_terminal
.Lapi_guard_site_89:
 mov w17,#89
 b .Lapi_guard_terminal
.Lapi_guard_site_93:
 mov w17,#93
 b .Lapi_guard_terminal
.Lapi_guard_site_97:
 mov w17,#97
 b .Lapi_guard_terminal
.Lapi_guard_site_101:
 mov w17,#101
 b .Lapi_guard_terminal
.Lapi_guard_site_105:
 mov w17,#105
 b .Lapi_guard_terminal
.Lapi_guard_site_108:
 mov w17,#108
 b .Lapi_guard_terminal
.Lapi_guard_site_112:
 mov w17,#112
 b .Lapi_guard_terminal
.Lapi_guard_site_117:
 mov w17,#117
 b .Lapi_guard_terminal
.Lapi_guard_site_121:
 mov w17,#121
 b .Lapi_guard_terminal
.Lapi_guard_site_125:
 mov w17,#125
 b .Lapi_guard_terminal
.Lapi_guard_site_128:
 mov w17,#128
 b .Lapi_guard_terminal
.Lapi_guard_site_131:
 mov w17,#131
 b .Lapi_guard_terminal
.Lapi_guard_site_135:
 mov w17,#135
 b .Lapi_guard_terminal
.Lapi_guard_site_139:
 mov w17,#139
 b .Lapi_guard_terminal
.Lapi_guard_site_142:
 mov w17,#142
 b .Lapi_guard_terminal
.Lapi_guard_site_187:
 mov w17,#187
 b .Lapi_guard_terminal
.Lapi_guard_site_195:
 mov w17,#195
 b .Lapi_guard_terminal
.Lapi_guard_site_205:
 mov w17,#205
 b .Lapi_guard_terminal
.Lapi_guard_site_211:
 mov w17,#211
 b .Lapi_guard_terminal
.Lapi_guard_site_217:
 mov w17,#217
 b .Lapi_guard_terminal
.Lapi_guard_site_223:
 mov w17,#223
 b .Lapi_guard_terminal
.Lapi_guard_site_244:
 mov w17,#244
 b .Lapi_guard_terminal
.Lapi_guard_site_246:
 mov w17,#246
 b .Lapi_guard_terminal
.Lapi_guard_site_266:
 mov w17,#266
 b .Lapi_guard_terminal
.Lapi_guard_site_268:
 mov w17,#268
 b .Lapi_guard_terminal
.Lapi_guard_site_270:
 mov w17,#270
 b .Lapi_guard_terminal
.Lapi_guard_site_272:
 mov w17,#272
 b .Lapi_guard_terminal
.Lapi_guard_site_293:
 mov w17,#293
 b .Lapi_guard_terminal
.Lapi_guard_site_310:
 mov w17,#310
 b .Lapi_guard_terminal
.Lapi_guard_site_326:
 mov w17,#326
 b .Lapi_guard_terminal
.Lapi_guard_site_342:
 mov w17,#342
 b .Lapi_guard_terminal
.Lapi_guard_site_467:
 mov w17,#467
 b .Lapi_guard_terminal
.Lapi_guard_site_471:
 mov w17,#471
 b .Lapi_guard_terminal
.Lapi_guard_site_475:
 mov w17,#475
 b .Lapi_guard_terminal
.Lapi_guard_site_479:
 mov w17,#479
 b .Lapi_guard_terminal
.Lapi_guard_site_483:
 mov w17,#483
 b .Lapi_guard_terminal
.Lapi_guard_site_486:
 mov w17,#486
 b .Lapi_guard_terminal
.Lapi_guard_site_490:
 mov w17,#490
 b .Lapi_guard_terminal
.Lapi_guard_site_495:
 mov w17,#495
 b .Lapi_guard_terminal
.Lapi_guard_site_499:
 mov w17,#499
 b .Lapi_guard_terminal
.Lapi_guard_site_503:
 mov w17,#503
 b .Lapi_guard_terminal
.Lapi_guard_site_506:
 mov w17,#506
 b .Lapi_guard_terminal
.Lapi_guard_site_509:
 mov w17,#509
 b .Lapi_guard_terminal
.Lapi_guard_site_513:
 mov w17,#513
 b .Lapi_guard_terminal
.Lapi_guard_site_517:
 mov w17,#517
 b .Lapi_guard_terminal
.Lapi_guard_site_520:
 mov w17,#520
 b .Lapi_guard_terminal
.Lapi_guard_site_565:
 mov w17,#565
 b .Lapi_guard_terminal
.Lapi_guard_site_573:
 mov w17,#573
 b .Lapi_guard_terminal
.Lapi_guard_site_589:
 mov w17,#589
 b .Lapi_guard_terminal
.Lapi_guard_site_591:
 mov w17,#591
 b .Lapi_guard_terminal
.Lapi_guard_site_611:
 mov w17,#611
 b .Lapi_guard_terminal
.Lapi_guard_site_613:
 mov w17,#613
 b .Lapi_guard_terminal
.Lapi_guard_site_615:
 mov w17,#615
 b .Lapi_guard_terminal
.Lapi_guard_site_617:
 mov w17,#617
 b .Lapi_guard_terminal
.Lapi_guard_site_638:
 mov w17,#638
 b .Lapi_guard_terminal
.Lapi_guard_site_655:
 mov w17,#655
 b .Lapi_guard_terminal
.Lapi_guard_site_671:
 mov w17,#671
 b .Lapi_guard_terminal
.Lapi_guard_site_687:
 mov w17,#687
 b .Lapi_guard_terminal
.Lapi_guard_site_778:
 mov w17,#778
 b .Lapi_guard_terminal
.Lapi_guard_site_781:
 mov w17,#781
 b .Lapi_guard_terminal
.Lapi_guard_site_784:
 mov w17,#784
 b .Lapi_guard_terminal
.Lapi_guard_site_787:
 mov w17,#787
 b .Lapi_guard_terminal
.Lapi_guard_site_789:
 mov w17,#789
 b .Lapi_guard_terminal
.Lapi_guard_site_795:
 mov w17,#795
 b .Lapi_guard_terminal
.Lapi_guard_site_798:
 mov w17,#798
 b .Lapi_guard_terminal
.Lapi_guard_site_800:
 mov w17,#800
 b .Lapi_guard_terminal
.Lapi_guard_site_805:
 mov w17,#805
 b .Lapi_guard_terminal
.Lapi_guard_site_808:
 mov w17,#808
 b .Lapi_guard_terminal
.Lapi_guard_site_811:
 mov w17,#811
 b .Lapi_guard_terminal
.Lapi_guard_site_814:
 mov w17,#814
 b .Lapi_guard_terminal
.Lapi_guard_site_816:
 mov w17,#816
 b .Lapi_guard_terminal
.Lapi_guard_site_826:
 mov w17,#826
 b .Lapi_guard_terminal
.Lapi_guard_site_830:
 mov w17,#830
 b .Lapi_guard_terminal
.Lapi_guard_site_841:
 mov w17,#841
 b .Lapi_guard_terminal
.Lapi_guard_site_843:
 mov w17,#843
 b .Lapi_guard_terminal
.Lapi_guard_site_846:
 mov w17,#846
 b .Lapi_guard_terminal
.Lapi_guard_site_849:
 mov w17,#849
 b .Lapi_guard_terminal
.Lapi_guard_site_852:
 mov w17,#852
 b .Lapi_guard_terminal
.Lapi_guard_site_855:
 mov w17,#855
 b .Lapi_guard_terminal
.Lapi_guard_site_859:
 mov w17,#859
 b .Lapi_guard_terminal
.Lapi_guard_site_861:
 mov w17,#861
 b .Lapi_guard_terminal
.Lapi_guard_site_863:
 mov w17,#863
 b .Lapi_guard_terminal
.Lapi_guard_site_866:
 mov w17,#866
 b .Lapi_guard_terminal
.Lapi_guard_site_869:
 mov w17,#869
 b .Lapi_guard_terminal
.Lapi_guard_site_872:
 mov w17,#872
 b .Lapi_guard_terminal
.Lapi_guard_site_875:
 mov w17,#875
 b .Lapi_guard_terminal
.Lapi_guard_site_878:
 mov w17,#878
 b .Lapi_guard_terminal
.Lapi_guard_site_881:
 mov w17,#881
 b .Lapi_guard_terminal
.Lapi_guard_site_883:
 mov w17,#883
 b .Lapi_guard_terminal
.Lapi_guard_site_887:
 mov w17,#887
 b .Lapi_guard_terminal
.Lapi_guard_site_892:
 mov w17,#892
 b .Lapi_guard_terminal
.Lapi_guard_site_894:
 mov w17,#894
 b .Lapi_guard_terminal
.Lapi_guard_site_898:
 mov w17,#898
 b .Lapi_guard_terminal
.Lapi_guard_site_901:
 mov w17,#901
 b .Lapi_guard_terminal
.Lapi_guard_site_906:
 mov w17,#906
 b .Lapi_guard_terminal
.Lapi_guard_site_910:
 mov w17,#910
 b .Lapi_guard_terminal
.Lapi_guard_site_913:
 mov w17,#913
 b .Lapi_guard_terminal
.Lapi_guard_site_916:
 mov w17,#916
 b .Lapi_guard_terminal
.Lapi_guard_site_919:
 mov w17,#919
 b .Lapi_guard_terminal
.Lapi_guard_site_922:
 mov w17,#922
 b .Lapi_guard_terminal
.Lapi_guard_terminal:
 sub sp,sp,#160
 stp x0,x1,[sp,#0]
 stp x2,x3,[sp,#16]
 stp x4,x5,[sp,#32]
 stp x6,x7,[sp,#48]
 stp x8,x9,[sp,#64]
 stp x10,x11,[sp,#80]
 stp x12,x13,[sp,#96]
 stp x14,x15,[sp,#112]
 str x16,[sp,#128]
 mov w0,w17
 add x1,sp,#448
 mov x2,sp
 mrs x3,fpcr
 mrs x4,fpsr
 bl md2asm_external_transform_guard_terminal_r2
 brk #0
.Lapi_bad:
 bl abort
 brk #0
.global md2asm_external_transform_count_get
.type md2asm_external_transform_count_get,%function
md2asm_external_transform_count_get:
 cmp w0,#2
 b.hs .Lapi_count_zero
 adrp x9,.Lapi_counts
 add x9,x9,:lo12:.Lapi_counts
 ldr x0,[x9,x0,lsl #3]
 ret
.Lapi_count_zero:
 mov x0,#0
 ret
.data
.p2align 3
.Lapi_counts: .quad 0,0
.Lphase_0: .word 0
.Lphase_1: .word 1
.Lname_inv_trans: .asciz "INV_TRANS"
.Lname_dir_trans: .asciz "DIR_TRANS"
.Levent_1807: .word 1807
.Levent_1808: .word 1808
.section .note.GNU-stack,"",%progbits
