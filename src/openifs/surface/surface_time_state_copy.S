/* Source build for the qualified private forecast graph.
 * Contract: skills/md2asm/references/openifs/dynamics/private_forecast_graph_sources.md.
 * Preserve the original interface, ordered arithmetic, and caller-owned storage. */
// Source surface time-level assignments. The retained qualified body is unchanged.
.text
.p2align 4
.global md2asm_physics_surface_time_copy_recorded_body_7388001
.hidden md2asm_physics_surface_time_copy_recorded_body_7388001
.type md2asm_physics_surface_time_copy_recorded_body_7388001,%function
md2asm_physics_surface_time_copy_recorded_body_7388001:
stp x29,x30,[sp,#-32]!
stp x19,x20,[sp,#16]
mov x19,x0
mov w20,w1
 mov x9,x19
 mov x16,#904
 add x9,x9,x16
 ldr x9,[x9]
 mov x16,#36
 add x9,x9,x16
 ldr w9,[x9]
 cbz w9,.Lsurface_SB_T_done
 cmp w20,#2
 b.eq .Lsurface_SB_T_reverse
 mov x0,x19
 mov x16,#88
 add x0,x0,x16
 cmp w20,#1
 b.eq .Lsurface_SB_T_from9
 mov x1,x19
 mov x16,#0
 add x1,x1,x16
 b .Lsurface_SB_T_ready
.Lsurface_SB_T_from9:
 mov x1,x19
 mov x16,#176
 add x1,x1,x16
 b .Lsurface_SB_T_ready
.Lsurface_SB_T_reverse:
 mov x0,x19
 mov x16,#0
 add x0,x0,x16
 mov x1,x19
 mov x16,#88
 add x1,x1,x16
.Lsurface_SB_T_ready:
 mov w2,#2
 bl .Lsurface_copy_view
.Lsurface_SB_T_done:
 mov x9,x19
 mov x16,#904
 add x9,x9,x16
 ldr x9,[x9]
 mov x16,#764
 add x9,x9,x16
 ldr w9,[x9]
 cbz w9,.Lsurface_SB_Q_done
 cmp w20,#2
 b.eq .Lsurface_SB_Q_reverse
 mov x0,x19
 mov x16,#352
 add x0,x0,x16
 cmp w20,#1
 b.eq .Lsurface_SB_Q_from9
 mov x1,x19
 mov x16,#264
 add x1,x1,x16
 b .Lsurface_SB_Q_ready
.Lsurface_SB_Q_from9:
 mov x1,x19
 mov x16,#440
 add x1,x1,x16
 b .Lsurface_SB_Q_ready
.Lsurface_SB_Q_reverse:
 mov x0,x19
 mov x16,#264
 add x0,x0,x16
 mov x1,x19
 mov x16,#352
 add x1,x1,x16
.Lsurface_SB_Q_ready:
 mov w2,#2
 bl .Lsurface_copy_view
.Lsurface_SB_Q_done:
 mov x9,x19
 mov x16,#904
 add x9,x9,x16
 ldr x9,[x9]
 mov x16,#1492
 add x9,x9,x16
 ldr w9,[x9]
 cbz w9,.Lsurface_SB_TL_done
 cmp w20,#2
 b.eq .Lsurface_SB_TL_reverse
 mov x0,x19
 mov x16,#616
 add x0,x0,x16
 cmp w20,#1
 b.eq .Lsurface_SB_TL_from9
 mov x1,x19
 mov x16,#528
 add x1,x1,x16
 b .Lsurface_SB_TL_ready
.Lsurface_SB_TL_from9:
 mov x1,x19
 mov x16,#704
 add x1,x1,x16
 b .Lsurface_SB_TL_ready
.Lsurface_SB_TL_reverse:
 mov x0,x19
 mov x16,#528
 add x0,x0,x16
 mov x1,x19
 mov x16,#616
 add x1,x1,x16
.Lsurface_SB_TL_ready:
 mov w2,#2
 bl .Lsurface_copy_view
.Lsurface_SB_TL_done:
 mov x9,x19
 mov x16,#2424
 add x9,x9,x16
 ldr x9,[x9]
 mov x16,#36
 add x9,x9,x16
 ldr w9,[x9]
 cbz w9,.Lsurface_SG_F_done
 cmp w20,#2
 b.eq .Lsurface_SG_F_reverse
 mov x0,x19
 mov x16,#1080
 add x0,x0,x16
 cmp w20,#1
 b.eq .Lsurface_SG_F_from9
 mov x1,x19
 mov x16,#992
 add x1,x1,x16
 b .Lsurface_SG_F_ready
.Lsurface_SG_F_from9:
 mov x1,x19
 mov x16,#1168
 add x1,x1,x16
 b .Lsurface_SG_F_ready
.Lsurface_SG_F_reverse:
 mov x0,x19
 mov x16,#992
 add x0,x0,x16
 mov x1,x19
 mov x16,#1080
 add x1,x1,x16
.Lsurface_SG_F_ready:
 mov w2,#2
 bl .Lsurface_copy_view
.Lsurface_SG_F_done:
 mov x9,x19
 mov x16,#2424
 add x9,x9,x16
 ldr x9,[x9]
 mov x16,#764
 add x9,x9,x16
 ldr w9,[x9]
 cbz w9,.Lsurface_SG_A_done
 cmp w20,#2
 b.eq .Lsurface_SG_A_reverse
 mov x0,x19
 mov x16,#1344
 add x0,x0,x16
 cmp w20,#1
 b.eq .Lsurface_SG_A_from9
 mov x1,x19
 mov x16,#1256
 add x1,x1,x16
 b .Lsurface_SG_A_ready
.Lsurface_SG_A_from9:
 mov x1,x19
 mov x16,#1432
 add x1,x1,x16
 b .Lsurface_SG_A_ready
.Lsurface_SG_A_reverse:
 mov x0,x19
 mov x16,#1256
 add x0,x0,x16
 mov x1,x19
 mov x16,#1344
 add x1,x1,x16
.Lsurface_SG_A_ready:
 mov w2,#2
 bl .Lsurface_copy_view
.Lsurface_SG_A_done:
 mov x9,x19
 mov x16,#2424
 add x9,x9,x16
 ldr x9,[x9]
 mov x16,#1492
 add x9,x9,x16
 ldr w9,[x9]
 cbz w9,.Lsurface_SG_R_done
 cmp w20,#2
 b.eq .Lsurface_SG_R_reverse
 mov x0,x19
 mov x16,#1608
 add x0,x0,x16
 cmp w20,#1
 b.eq .Lsurface_SG_R_from9
 mov x1,x19
 mov x16,#1520
 add x1,x1,x16
 b .Lsurface_SG_R_ready
.Lsurface_SG_R_from9:
 mov x1,x19
 mov x16,#1696
 add x1,x1,x16
 b .Lsurface_SG_R_ready
.Lsurface_SG_R_reverse:
 mov x0,x19
 mov x16,#1520
 add x0,x0,x16
 mov x1,x19
 mov x16,#1608
 add x1,x1,x16
.Lsurface_SG_R_ready:
 mov w2,#2
 bl .Lsurface_copy_view
.Lsurface_SG_R_done:
 mov x9,x19
 mov x16,#2424
 add x9,x9,x16
 ldr x9,[x9]
 mov x16,#2220
 add x9,x9,x16
 ldr w9,[x9]
 cbz w9,.Lsurface_SG_T_done
 cmp w20,#2
 b.eq .Lsurface_SG_T_reverse
 mov x0,x19
 mov x16,#1872
 add x0,x0,x16
 cmp w20,#1
 b.eq .Lsurface_SG_T_from9
 mov x1,x19
 mov x16,#1784
 add x1,x1,x16
 b .Lsurface_SG_T_ready
.Lsurface_SG_T_from9:
 mov x1,x19
 mov x16,#1960
 add x1,x1,x16
 b .Lsurface_SG_T_ready
.Lsurface_SG_T_reverse:
 mov x0,x19
 mov x16,#1784
 add x0,x0,x16
 mov x1,x19
 mov x16,#1872
 add x1,x1,x16
.Lsurface_SG_T_ready:
 mov w2,#2
 bl .Lsurface_copy_view
.Lsurface_SG_T_done:
 mov x9,x19
 mov x16,#2424
 add x9,x9,x16
 ldr x9,[x9]
 mov x16,#2948
 add x9,x9,x16
 ldr w9,[x9]
 cbz w9,.Lsurface_SG_W_done
 cmp w20,#2
 b.eq .Lsurface_SG_W_reverse
 mov x0,x19
 mov x16,#2136
 add x0,x0,x16
 cmp w20,#1
 b.eq .Lsurface_SG_W_from9
 mov x1,x19
 mov x16,#2048
 add x1,x1,x16
 b .Lsurface_SG_W_ready
.Lsurface_SG_W_from9:
 mov x1,x19
 mov x16,#2224
 add x1,x1,x16
 b .Lsurface_SG_W_ready
.Lsurface_SG_W_reverse:
 mov x0,x19
 mov x16,#2048
 add x0,x0,x16
 mov x1,x19
 mov x16,#2136
 add x1,x1,x16
.Lsurface_SG_W_ready:
 mov w2,#2
 bl .Lsurface_copy_view
.Lsurface_SG_W_done:
 mov x9,x19
 mov x16,#3992
 add x9,x9,x16
 ldr x9,[x9]
 mov x16,#36
 add x9,x9,x16
 ldr w9,[x9]
 cbz w9,.Lsurface_SL_LICT_done
 cmp w20,#2
 b.eq .Lsurface_SL_LICT_reverse
 mov x0,x19
 mov x16,#2624
 add x0,x0,x16
 cmp w20,#1
 b.eq .Lsurface_SL_LICT_from9
 mov x1,x19
 mov x16,#2560
 add x1,x1,x16
 b .Lsurface_SL_LICT_ready
.Lsurface_SL_LICT_from9:
 mov x1,x19
 mov x16,#2688
 add x1,x1,x16
 b .Lsurface_SL_LICT_ready
.Lsurface_SL_LICT_reverse:
 mov x0,x19
 mov x16,#2560
 add x0,x0,x16
 mov x1,x19
 mov x16,#2624
 add x1,x1,x16
.Lsurface_SL_LICT_ready:
 mov w2,#1
 bl .Lsurface_copy_view
.Lsurface_SL_LICT_done:
 mov x9,x19
 mov x16,#3992
 add x9,x9,x16
 ldr x9,[x9]
 mov x16,#596
 add x9,x9,x16
 ldr w9,[x9]
 cbz w9,.Lsurface_SL_LMLT_done
 cmp w20,#2
 b.eq .Lsurface_SL_LMLT_reverse
 mov x0,x19
 mov x16,#2816
 add x0,x0,x16
 cmp w20,#1
 b.eq .Lsurface_SL_LMLT_from9
 mov x1,x19
 mov x16,#2752
 add x1,x1,x16
 b .Lsurface_SL_LMLT_ready
.Lsurface_SL_LMLT_from9:
 mov x1,x19
 mov x16,#2880
 add x1,x1,x16
 b .Lsurface_SL_LMLT_ready
.Lsurface_SL_LMLT_reverse:
 mov x0,x19
 mov x16,#2752
 add x0,x0,x16
 mov x1,x19
 mov x16,#2816
 add x1,x1,x16
.Lsurface_SL_LMLT_ready:
 mov w2,#1
 bl .Lsurface_copy_view
.Lsurface_SL_LMLT_done:
 mov x9,x19
 mov x16,#3992
 add x9,x9,x16
 ldr x9,[x9]
 mov x16,#1156
 add x9,x9,x16
 ldr w9,[x9]
 cbz w9,.Lsurface_SL_LTLT_done
 cmp w20,#2
 b.eq .Lsurface_SL_LTLT_reverse
 mov x0,x19
 mov x16,#3008
 add x0,x0,x16
 cmp w20,#1
 b.eq .Lsurface_SL_LTLT_from9
 mov x1,x19
 mov x16,#2944
 add x1,x1,x16
 b .Lsurface_SL_LTLT_ready
.Lsurface_SL_LTLT_from9:
 mov x1,x19
 mov x16,#3072
 add x1,x1,x16
 b .Lsurface_SL_LTLT_ready
.Lsurface_SL_LTLT_reverse:
 mov x0,x19
 mov x16,#2944
 add x0,x0,x16
 mov x1,x19
 mov x16,#3008
 add x1,x1,x16
.Lsurface_SL_LTLT_ready:
 mov w2,#1
 bl .Lsurface_copy_view
.Lsurface_SL_LTLT_done:
 mov x9,x19
 mov x16,#3992
 add x9,x9,x16
 ldr x9,[x9]
 mov x16,#1716
 add x9,x9,x16
 ldr w9,[x9]
 cbz w9,.Lsurface_SL_LBLT_done
 cmp w20,#2
 b.eq .Lsurface_SL_LBLT_reverse
 mov x0,x19
 mov x16,#3200
 add x0,x0,x16
 cmp w20,#1
 b.eq .Lsurface_SL_LBLT_from9
 mov x1,x19
 mov x16,#3136
 add x1,x1,x16
 b .Lsurface_SL_LBLT_ready
.Lsurface_SL_LBLT_from9:
 mov x1,x19
 mov x16,#3264
 add x1,x1,x16
 b .Lsurface_SL_LBLT_ready
.Lsurface_SL_LBLT_reverse:
 mov x0,x19
 mov x16,#3136
 add x0,x0,x16
 mov x1,x19
 mov x16,#3200
 add x1,x1,x16
.Lsurface_SL_LBLT_ready:
 mov w2,#1
 bl .Lsurface_copy_view
.Lsurface_SL_LBLT_done:
 mov x9,x19
 mov x16,#3992
 add x9,x9,x16
 ldr x9,[x9]
 mov x16,#2276
 add x9,x9,x16
 ldr w9,[x9]
 cbz w9,.Lsurface_SL_LSHF_done
 cmp w20,#2
 b.eq .Lsurface_SL_LSHF_reverse
 mov x0,x19
 mov x16,#3392
 add x0,x0,x16
 cmp w20,#1
 b.eq .Lsurface_SL_LSHF_from9
 mov x1,x19
 mov x16,#3328
 add x1,x1,x16
 b .Lsurface_SL_LSHF_ready
.Lsurface_SL_LSHF_from9:
 mov x1,x19
 mov x16,#3456
 add x1,x1,x16
 b .Lsurface_SL_LSHF_ready
.Lsurface_SL_LSHF_reverse:
 mov x0,x19
 mov x16,#3328
 add x0,x0,x16
 mov x1,x19
 mov x16,#3392
 add x1,x1,x16
.Lsurface_SL_LSHF_ready:
 mov w2,#1
 bl .Lsurface_copy_view
.Lsurface_SL_LSHF_done:
 mov x9,x19
 mov x16,#3992
 add x9,x9,x16
 ldr x9,[x9]
 mov x16,#2836
 add x9,x9,x16
 ldr w9,[x9]
 cbz w9,.Lsurface_SL_LICD_done
 cmp w20,#2
 b.eq .Lsurface_SL_LICD_reverse
 mov x0,x19
 mov x16,#3584
 add x0,x0,x16
 cmp w20,#1
 b.eq .Lsurface_SL_LICD_from9
 mov x1,x19
 mov x16,#3520
 add x1,x1,x16
 b .Lsurface_SL_LICD_ready
.Lsurface_SL_LICD_from9:
 mov x1,x19
 mov x16,#3648
 add x1,x1,x16
 b .Lsurface_SL_LICD_ready
.Lsurface_SL_LICD_reverse:
 mov x0,x19
 mov x16,#3520
 add x0,x0,x16
 mov x1,x19
 mov x16,#3584
 add x1,x1,x16
.Lsurface_SL_LICD_ready:
 mov w2,#1
 bl .Lsurface_copy_view
.Lsurface_SL_LICD_done:
 mov x9,x19
 mov x16,#3992
 add x9,x9,x16
 ldr x9,[x9]
 mov x16,#3396
 add x9,x9,x16
 ldr w9,[x9]
 cbz w9,.Lsurface_SL_LMLD_done
 cmp w20,#2
 b.eq .Lsurface_SL_LMLD_reverse
 mov x0,x19
 mov x16,#3776
 add x0,x0,x16
 cmp w20,#1
 b.eq .Lsurface_SL_LMLD_from9
 mov x1,x19
 mov x16,#3712
 add x1,x1,x16
 b .Lsurface_SL_LMLD_ready
.Lsurface_SL_LMLD_from9:
 mov x1,x19
 mov x16,#3840
 add x1,x1,x16
 b .Lsurface_SL_LMLD_ready
.Lsurface_SL_LMLD_reverse:
 mov x0,x19
 mov x16,#3712
 add x0,x0,x16
 mov x1,x19
 mov x16,#3776
 add x1,x1,x16
.Lsurface_SL_LMLD_ready:
 mov w2,#1
 bl .Lsurface_copy_view
.Lsurface_SL_LMLD_done:
 mov x9,x19
 mov x16,#5224
 add x9,x9,x16
 ldr x9,[x9]
 mov x16,#36
 add x9,x9,x16
 ldr w9,[x9]
 cbz w9,.Lsurface_RR_T_done
 cmp w20,#2
 b.eq .Lsurface_RR_T_reverse
 mov x0,x19
 mov x16,#4240
 add x0,x0,x16
 cmp w20,#1
 b.eq .Lsurface_RR_T_from9
 mov x1,x19
 mov x16,#4176
 add x1,x1,x16
 b .Lsurface_RR_T_ready
.Lsurface_RR_T_from9:
 mov x1,x19
 mov x16,#4304
 add x1,x1,x16
 b .Lsurface_RR_T_ready
.Lsurface_RR_T_reverse:
 mov x0,x19
 mov x16,#4176
 add x0,x0,x16
 mov x1,x19
 mov x16,#4240
 add x1,x1,x16
.Lsurface_RR_T_ready:
 mov w2,#1
 bl .Lsurface_copy_view
.Lsurface_RR_T_done:
 mov x9,x19
 mov x16,#5224
 add x9,x9,x16
 ldr x9,[x9]
 mov x16,#596
 add x9,x9,x16
 ldr w9,[x9]
 cbz w9,.Lsurface_RR_W_done
 cmp w20,#2
 b.eq .Lsurface_RR_W_reverse
 mov x0,x19
 mov x16,#4432
 add x0,x0,x16
 cmp w20,#1
 b.eq .Lsurface_RR_W_from9
 mov x1,x19
 mov x16,#4368
 add x1,x1,x16
 b .Lsurface_RR_W_ready
.Lsurface_RR_W_from9:
 mov x1,x19
 mov x16,#4496
 add x1,x1,x16
 b .Lsurface_RR_W_ready
.Lsurface_RR_W_reverse:
 mov x0,x19
 mov x16,#4368
 add x0,x0,x16
 mov x1,x19
 mov x16,#4432
 add x1,x1,x16
.Lsurface_RR_W_ready:
 mov w2,#1
 bl .Lsurface_copy_view
.Lsurface_RR_W_done:
 mov x9,x19
 mov x16,#5224
 add x9,x9,x16
 ldr x9,[x9]
 mov x16,#1156
 add x9,x9,x16
 ldr w9,[x9]
 cbz w9,.Lsurface_RR_FC_done
 cmp w20,#2
 b.eq .Lsurface_RR_FC_reverse
 mov x0,x19
 mov x16,#4624
 add x0,x0,x16
 cmp w20,#1
 b.eq .Lsurface_RR_FC_from9
 mov x1,x19
 mov x16,#4560
 add x1,x1,x16
 b .Lsurface_RR_FC_ready
.Lsurface_RR_FC_from9:
 mov x1,x19
 mov x16,#4688
 add x1,x1,x16
 b .Lsurface_RR_FC_ready
.Lsurface_RR_FC_reverse:
 mov x0,x19
 mov x16,#4560
 add x0,x0,x16
 mov x1,x19
 mov x16,#4624
 add x1,x1,x16
.Lsurface_RR_FC_ready:
 mov w2,#1
 bl .Lsurface_copy_view
.Lsurface_RR_FC_done:
 mov x9,x19
 mov x16,#5224
 add x9,x9,x16
 ldr x9,[x9]
 mov x16,#1716
 add x9,x9,x16
 ldr w9,[x9]
 cbz w9,.Lsurface_RR_IC_done
 cmp w20,#2
 b.eq .Lsurface_RR_IC_reverse
 mov x0,x19
 mov x16,#4816
 add x0,x0,x16
 cmp w20,#1
 b.eq .Lsurface_RR_IC_from9
 mov x1,x19
 mov x16,#4752
 add x1,x1,x16
 b .Lsurface_RR_IC_ready
.Lsurface_RR_IC_from9:
 mov x1,x19
 mov x16,#4880
 add x1,x1,x16
 b .Lsurface_RR_IC_ready
.Lsurface_RR_IC_reverse:
 mov x0,x19
 mov x16,#4752
 add x0,x0,x16
 mov x1,x19
 mov x16,#4816
 add x1,x1,x16
.Lsurface_RR_IC_ready:
 mov w2,#1
 bl .Lsurface_copy_view
.Lsurface_RR_IC_done:
 mov x9,x19
 mov x16,#5224
 add x9,x9,x16
 ldr x9,[x9]
 mov x16,#2276
 add x9,x9,x16
 ldr w9,[x9]
 cbz w9,.Lsurface_RR_FP1_done
 cmp w20,#2
 b.eq .Lsurface_RR_FP1_reverse
 mov x0,x19
 mov x16,#5008
 add x0,x0,x16
 cmp w20,#1
 b.eq .Lsurface_RR_FP1_from9
 mov x1,x19
 mov x16,#4944
 add x1,x1,x16
 b .Lsurface_RR_FP1_ready
.Lsurface_RR_FP1_from9:
 mov x1,x19
 mov x16,#5072
 add x1,x1,x16
 b .Lsurface_RR_FP1_ready
.Lsurface_RR_FP1_reverse:
 mov x0,x19
 mov x16,#4944
 add x0,x0,x16
 mov x1,x19
 mov x16,#5008
 add x1,x1,x16
.Lsurface_RR_FP1_ready:
 mov w2,#1
 bl .Lsurface_copy_view
.Lsurface_RR_FP1_done:
 mov x9,x19
 mov x16,#6600
 add x9,x9,x16
 ldr x9,[x9]
 mov x16,#36
 add x9,x9,x16
 ldr w9,[x9]
 cbz w9,.Lsurface_CL_TCLS_done
 cmp w20,#2
 b.eq .Lsurface_CL_TCLS_reverse
 mov x0,x19
 mov x16,#5424
 add x0,x0,x16
 cmp w20,#1
 b.eq .Lsurface_CL_TCLS_from9
 mov x1,x19
 mov x16,#5360
 add x1,x1,x16
 b .Lsurface_CL_TCLS_ready
.Lsurface_CL_TCLS_from9:
 mov x1,x19
 mov x16,#5488
 add x1,x1,x16
 b .Lsurface_CL_TCLS_ready
.Lsurface_CL_TCLS_reverse:
 mov x0,x19
 mov x16,#5360
 add x0,x0,x16
 mov x1,x19
 mov x16,#5424
 add x1,x1,x16
.Lsurface_CL_TCLS_ready:
 mov w2,#1
 bl .Lsurface_copy_view
.Lsurface_CL_TCLS_done:
 mov x9,x19
 mov x16,#6600
 add x9,x9,x16
 ldr x9,[x9]
 mov x16,#596
 add x9,x9,x16
 ldr w9,[x9]
 cbz w9,.Lsurface_CL_HUCLS_done
 cmp w20,#2
 b.eq .Lsurface_CL_HUCLS_reverse
 mov x0,x19
 mov x16,#5616
 add x0,x0,x16
 cmp w20,#1
 b.eq .Lsurface_CL_HUCLS_from9
 mov x1,x19
 mov x16,#5552
 add x1,x1,x16
 b .Lsurface_CL_HUCLS_ready
.Lsurface_CL_HUCLS_from9:
 mov x1,x19
 mov x16,#5680
 add x1,x1,x16
 b .Lsurface_CL_HUCLS_ready
.Lsurface_CL_HUCLS_reverse:
 mov x0,x19
 mov x16,#5552
 add x0,x0,x16
 mov x1,x19
 mov x16,#5616
 add x1,x1,x16
.Lsurface_CL_HUCLS_ready:
 mov w2,#1
 bl .Lsurface_copy_view
.Lsurface_CL_HUCLS_done:
 mov x9,x19
 mov x16,#6600
 add x9,x9,x16
 ldr x9,[x9]
 mov x16,#1156
 add x9,x9,x16
 ldr w9,[x9]
 cbz w9,.Lsurface_CL_UCLS_done
 cmp w20,#2
 b.eq .Lsurface_CL_UCLS_reverse
 mov x0,x19
 mov x16,#5808
 add x0,x0,x16
 cmp w20,#1
 b.eq .Lsurface_CL_UCLS_from9
 mov x1,x19
 mov x16,#5744
 add x1,x1,x16
 b .Lsurface_CL_UCLS_ready
.Lsurface_CL_UCLS_from9:
 mov x1,x19
 mov x16,#5872
 add x1,x1,x16
 b .Lsurface_CL_UCLS_ready
.Lsurface_CL_UCLS_reverse:
 mov x0,x19
 mov x16,#5744
 add x0,x0,x16
 mov x1,x19
 mov x16,#5808
 add x1,x1,x16
.Lsurface_CL_UCLS_ready:
 mov w2,#1
 bl .Lsurface_copy_view
.Lsurface_CL_UCLS_done:
 mov x9,x19
 mov x16,#6600
 add x9,x9,x16
 ldr x9,[x9]
 mov x16,#1716
 add x9,x9,x16
 ldr w9,[x9]
 cbz w9,.Lsurface_CL_VCLS_done
 cmp w20,#2
 b.eq .Lsurface_CL_VCLS_reverse
 mov x0,x19
 mov x16,#6000
 add x0,x0,x16
 cmp w20,#1
 b.eq .Lsurface_CL_VCLS_from9
 mov x1,x19
 mov x16,#5936
 add x1,x1,x16
 b .Lsurface_CL_VCLS_ready
.Lsurface_CL_VCLS_from9:
 mov x1,x19
 mov x16,#6064
 add x1,x1,x16
 b .Lsurface_CL_VCLS_ready
.Lsurface_CL_VCLS_reverse:
 mov x0,x19
 mov x16,#5936
 add x0,x0,x16
 mov x1,x19
 mov x16,#6000
 add x1,x1,x16
.Lsurface_CL_VCLS_ready:
 mov w2,#1
 bl .Lsurface_copy_view
.Lsurface_CL_VCLS_done:
 mov x9,x19
 mov x16,#6600
 add x9,x9,x16
 ldr x9,[x9]
 mov x16,#2276
 add x9,x9,x16
 ldr w9,[x9]
 cbz w9,.Lsurface_CL_NUCLS_done
 cmp w20,#2
 b.eq .Lsurface_CL_NUCLS_reverse
 mov x0,x19
 mov x16,#6192
 add x0,x0,x16
 cmp w20,#1
 b.eq .Lsurface_CL_NUCLS_from9
 mov x1,x19
 mov x16,#6128
 add x1,x1,x16
 b .Lsurface_CL_NUCLS_ready
.Lsurface_CL_NUCLS_from9:
 mov x1,x19
 mov x16,#6256
 add x1,x1,x16
 b .Lsurface_CL_NUCLS_ready
.Lsurface_CL_NUCLS_reverse:
 mov x0,x19
 mov x16,#6128
 add x0,x0,x16
 mov x1,x19
 mov x16,#6192
 add x1,x1,x16
.Lsurface_CL_NUCLS_ready:
 mov w2,#1
 bl .Lsurface_copy_view
.Lsurface_CL_NUCLS_done:
 mov x9,x19
 mov x16,#6600
 add x9,x9,x16
 ldr x9,[x9]
 mov x16,#2836
 add x9,x9,x16
 ldr w9,[x9]
 cbz w9,.Lsurface_CL_NVCLS_done
 cmp w20,#2
 b.eq .Lsurface_CL_NVCLS_reverse
 mov x0,x19
 mov x16,#6384
 add x0,x0,x16
 cmp w20,#1
 b.eq .Lsurface_CL_NVCLS_from9
 mov x1,x19
 mov x16,#6320
 add x1,x1,x16
 b .Lsurface_CL_NVCLS_ready
.Lsurface_CL_NVCLS_from9:
 mov x1,x19
 mov x16,#6448
 add x1,x1,x16
 b .Lsurface_CL_NVCLS_ready
.Lsurface_CL_NVCLS_reverse:
 mov x0,x19
 mov x16,#6320
 add x0,x0,x16
 mov x1,x19
 mov x16,#6384
 add x1,x1,x16
.Lsurface_CL_NVCLS_ready:
 mov w2,#1
 bl .Lsurface_copy_view
.Lsurface_CL_NVCLS_done:
 mov x9,x19
 mov x16,#7928
 add x9,x9,x16
 ldr x9,[x9]
 mov x16,#36
 add x9,x9,x16
 ldr w9,[x9]
 cbz w9,.Lsurface_OM_TO_done
 cmp w20,#2
 b.eq .Lsurface_OM_TO_reverse
 mov x0,x19
 mov x16,#6848
 add x0,x0,x16
 cmp w20,#1
 b.eq .Lsurface_OM_TO_from9
 mov x1,x19
 mov x16,#6760
 add x1,x1,x16
 b .Lsurface_OM_TO_ready
.Lsurface_OM_TO_from9:
 mov x1,x19
 mov x16,#6936
 add x1,x1,x16
 b .Lsurface_OM_TO_ready
.Lsurface_OM_TO_reverse:
 mov x0,x19
 mov x16,#6760
 add x0,x0,x16
 mov x1,x19
 mov x16,#6848
 add x1,x1,x16
.Lsurface_OM_TO_ready:
 mov w2,#2
 bl .Lsurface_copy_view
.Lsurface_OM_TO_done:
 mov x9,x19
 mov x16,#7928
 add x9,x9,x16
 ldr x9,[x9]
 mov x16,#764
 add x9,x9,x16
 ldr w9,[x9]
 cbz w9,.Lsurface_OM_SO_done
 cmp w20,#2
 b.eq .Lsurface_OM_SO_reverse
 mov x0,x19
 mov x16,#7112
 add x0,x0,x16
 cmp w20,#1
 b.eq .Lsurface_OM_SO_from9
 mov x1,x19
 mov x16,#7024
 add x1,x1,x16
 b .Lsurface_OM_SO_ready
.Lsurface_OM_SO_from9:
 mov x1,x19
 mov x16,#7200
 add x1,x1,x16
 b .Lsurface_OM_SO_ready
.Lsurface_OM_SO_reverse:
 mov x0,x19
 mov x16,#7024
 add x0,x0,x16
 mov x1,x19
 mov x16,#7112
 add x1,x1,x16
.Lsurface_OM_SO_ready:
 mov w2,#2
 bl .Lsurface_copy_view
.Lsurface_OM_SO_done:
 mov x9,x19
 mov x16,#7928
 add x9,x9,x16
 ldr x9,[x9]
 mov x16,#1492
 add x9,x9,x16
 ldr w9,[x9]
 cbz w9,.Lsurface_OM_UO_done
 cmp w20,#2
 b.eq .Lsurface_OM_UO_reverse
 mov x0,x19
 mov x16,#7376
 add x0,x0,x16
 cmp w20,#1
 b.eq .Lsurface_OM_UO_from9
 mov x1,x19
 mov x16,#7288
 add x1,x1,x16
 b .Lsurface_OM_UO_ready
.Lsurface_OM_UO_from9:
 mov x1,x19
 mov x16,#7464
 add x1,x1,x16
 b .Lsurface_OM_UO_ready
.Lsurface_OM_UO_reverse:
 mov x0,x19
 mov x16,#7288
 add x0,x0,x16
 mov x1,x19
 mov x16,#7376
 add x1,x1,x16
.Lsurface_OM_UO_ready:
 mov w2,#2
 bl .Lsurface_copy_view
.Lsurface_OM_UO_done:
 mov x9,x19
 mov x16,#7928
 add x9,x9,x16
 ldr x9,[x9]
 mov x16,#2220
 add x9,x9,x16
 ldr w9,[x9]
 cbz w9,.Lsurface_OM_VO_done
 cmp w20,#2
 b.eq .Lsurface_OM_VO_reverse
 mov x0,x19
 mov x16,#7640
 add x0,x0,x16
 cmp w20,#1
 b.eq .Lsurface_OM_VO_from9
 mov x1,x19
 mov x16,#7552
 add x1,x1,x16
 b .Lsurface_OM_VO_ready
.Lsurface_OM_VO_from9:
 mov x1,x19
 mov x16,#7728
 add x1,x1,x16
 b .Lsurface_OM_VO_ready
.Lsurface_OM_VO_reverse:
 mov x0,x19
 mov x16,#7552
 add x0,x0,x16
 mov x1,x19
 mov x16,#7640
 add x1,x1,x16
.Lsurface_OM_VO_ready:
 mov w2,#2
 bl .Lsurface_copy_view
.Lsurface_OM_VO_done:
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#32
 ret
.size md2asm_physics_surface_time_copy_recorded_body_7388001,.-md2asm_physics_surface_time_copy_recorded_body_7388001
// Copy rank-one or rank-two views in original Fortran element order.
.Lsurface_copy_view:
ldr x3,[x0]
ldr x4,[x1]
ldr x5,[x0,#8]
ldr x6,[x1,#8]
ldr x7,[x0,#40]
ldr x8,[x1,#40]
ldr x9,[x0,#48]
ldr x10,[x1,#48]
madd x5,x7,x9,x5
madd x6,x8,x10,x6
ldr x11,[x0,#56]
sub x11,x11,x9
add x11,x11,#1
cmp w2,#2
b.ne 1f
ldr x12,[x0,#64]
ldr x13,[x1,#64]
ldr x14,[x0,#72]
ldr x15,[x1,#72]
madd x5,x12,x14,x5
madd x6,x13,x15,x6
ldr x16,[x0,#80]
sub x16,x16,x14
add x16,x16,#1
b 2f
1:
mov x12,#0
mov x13,#0
mov x16,#1
2:
lsl x7,x7,#3
lsl x8,x8,#3
lsl x12,x12,#3
lsl x13,x13,#3
add x3,x3,x5,lsl #3
add x4,x4,x6,lsl #3
cmp x11,#0
b.le 6f
cmp x16,#0
b.le 6f
3:
mov x9,x3
mov x10,x4
mov x14,x11
4:
ldr x15,[x10]
str x15,[x9]
add x9,x9,x7
add x10,x10,x8
subs x14,x14,#1
b.ne 4b
add x3,x3,x12
add x4,x4,x13
subs x16,x16,#1
b.ne 3b
6:
ret
.section .note.GNU-stack,"",%progbits

.text
.p2align 4
// Two ordinary arguments: x0 surface-view object and w1 selected copy mode.
// Retain context only; preserve argument addresses, x18, NZCV and FP status.
.global md2asm_physics_surface_time_copy_7358525
.type md2asm_physics_surface_time_copy_7358525,%function
md2asm_physics_surface_time_copy_7358525:
 sub sp,sp,#32
 stp x9,x10,[sp]
 stp x16,x17,[sp,#16]
 adrp x9,.Lsoil_copy_context_r1
 add x9,x9,:lo12:.Lsoil_copy_context_r1
 str x0,[x9]
 str w1,[x9,#8]
 ldr x10,[x9,#16]
 add x10,x10,#1
 str x10,[x9,#16]
 ldp x16,x17,[sp,#16]
 ldp x9,x10,[sp]
 add sp,sp,#32
 b md2asm_physics_surface_time_copy_recorded_body_7388001
.size md2asm_physics_surface_time_copy_7358525,.-md2asm_physics_surface_time_copy_7358525
.p2align 4
// int getter(void **object, int32_t *mode, uint64_t *sequence).
// Failure-only consumer calls this getter; it changes no captured model owner.
.global md2asm_surface_time_copy_context_get_7388001
.type md2asm_surface_time_copy_context_get_7388001,%function
md2asm_surface_time_copy_context_get_7388001:
 adrp x9,.Lsoil_copy_context_r1
 add x9,x9,:lo12:.Lsoil_copy_context_r1
 ldr x10,[x9]
 str x10,[x0]
 ldr w10,[x9,#8]
 str w10,[x1]
 ldr x10,[x9,#16]
 str x10,[x2]
 ldr x10,[x9]
 mov w0,#0
 cbz x10,1f
 mov w0,#1
1:
 ret
.size md2asm_surface_time_copy_context_get_7388001,.-md2asm_surface_time_copy_context_get_7388001
.bss
.p2align 3
.Lsoil_copy_context_r1:
 .zero 24
.section .note.GNU-stack,"",%progbits
