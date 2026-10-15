// Contract: skills/md2asm/references/openifs/setup/field_registry.md.
/* Complete direct GP_MODEL selected route with direct field registry.
 * Local contract: skills/md2asm/references/openifs/setup/field_registry.md.
 * All other selected GP instructions retain the admitted raw-array caller.
 * Physics formulations/openifs/dynamics/complete_forecast_grid_driver.md.
 * Contract skills/md2asm/references/openifs/dynamics/complete_forecast_grid_driver.md.
 * Eleven ordinary addresses and one GNU hidden character length. */
.arch armv8.2-a+simd
.text
.p2align 4
.global md2asm_gp_model_physics_cape_r7_7358525
.global md2asm_gp_model_lagged_raw_caller_r8_7388001
.type md2asm_gp_model_lagged_raw_caller_r8_7388001,%function
.type md2asm_gp_model_physics_cape_r7_7358525,%function
md2asm_gp_model_physics_cape_r7_7358525:
md2asm_gp_model_lagged_raw_caller_r8_7388001:
 mov x17,sp
 sub sp,sp,#4096
 add x16,sp,#640
 stp x18,x19,[x16,#0]
 stp x20,x21,[x16,#16]
 stp x22,x23,[x16,#32]
 stp x24,x25,[x16,#48]
 stp x26,x27,[x16,#64]
 stp x28,x29,[x16,#80]
 str x30,[sp,#736]
 mov x29,sp
 str x0,[sp,#768]
 str x1,[sp,#776]
 str x2,[sp,#784]
 str x3,[sp,#792]
 str x4,[sp,#800]
 str x5,[sp,#808]
 str x6,[sp,#816]
 str x7,[sp,#824]
 ldr x9,[x17,#0]
 str x9,[sp,#832]
 ldr x9,[x17,#8]
 str x9,[sp,#840]
 ldr x9,[x17,#16]
 str x9,[sp,#848]
 ldr x9,[x17,#24]
 str x9,[sp,#856]
 ldr x19,[x29,#768]
 ldr x20,[x29,#776]
 ldr x21,[x29,#784]
 mrs x9,fpcr
 cbnz x9,.Lreject
 ldr x9,[x29,#856]
 cmp x9,#9
 b.ne .Lreject
 movz x16,#5144
 add x9,x19,x16
 ldr w10,[x9]
 cmp w10,#24
 b.ne .Lreject
 movz x16,#5160
 add x9,x19,x16
 ldr w10,[x9]
 cmp w10,#86
 b.ne .Lreject
 movz x16,#5224
 add x9,x19,x16
 ldr w10,[x9]
 cmp w10,#19
 b.ne .Lreject
 movz x16,#7376
 add x9,x19,x16
 ldr w10,[x9]
 cmp w10,#2048
 b.ne .Lreject
 movz x16,#57144
 movk x16,#23,lsl #16
 add x9,x21,x16
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 movz x16,#56832
 movk x16,#23,lsl #16
 add x9,x21,x16
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lreject
 movz x16,#5284
 movk x16,#24,lsl #16
 add x9,x21,x16
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lreject
 movz x16,#57012
 movk x16,#23,lsl #16
 add x9,x21,x16
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 movz x16,#57016
 movk x16,#23,lsl #16
 add x9,x21,x16
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 movz x16,#5064
 movk x16,#24,lsl #16
 add x9,x21,x16
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lreject
 movz x16,#35876
 movk x16,#24,lsl #16
 add x9,x21,x16
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lreject
 movz x16,#5060
 movk x16,#24,lsl #16
 add x9,x21,x16
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lreject
 movz x16,#15436
 movk x16,#24,lsl #16
 add x9,x21,x16
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 movz x16,#61804
 movk x16,#23,lsl #16
 add x9,x21,x16
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 movz x16,#61832
 movk x16,#23,lsl #16
 add x9,x21,x16
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 movz x16,#14760
 movk x16,#24,lsl #16
 add x9,x21,x16
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 movz x16,#25684
 movk x16,#64,lsl #16
 add x9,x21,x16
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 movz x16,#25704
 movk x16,#64,lsl #16
 add x9,x21,x16
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 add x9,x21,#352
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lreject
 add x9,x21,#512
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 add x9,x21,#192
 ldr w10,[x9]
 cmp w10,#8
 b.ne .Lreject
 add x9,x21,#256
 ldr w10,[x9]
 cmp w10,#6
 b.ne .Lreject
 add x9,x21,#264
 ldr w10,[x9]
 cmp w10,#2
 b.ne .Lreject
 movz x16,#4548
 movk x16,#24,lsl #16
 add x9,x21,x16
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 movz x16,#5188
 movk x16,#24,lsl #16
 add x9,x21,x16
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 movz x16,#5192
 movk x16,#24,lsl #16
 add x9,x21,x16
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 adrp x9,:got:__yomct0_MOD_lr2d
 ldr x9,[x9,:got_lo12:__yomct0_MOD_lr2d]
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 adrp x9,:got:__yomct0_MOD_lelam
 ldr x9,[x9,:got_lo12:__yomct0_MOD_lelam]
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 adrp x9,:got:__yomct0_MOD_lcanari
 ldr x9,[x9,:got_lo12:__yomct0_MOD_lcanari]
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 adrp x9,:got:__yommp0_MOD_nproc
 ldr x9,[x9,:got_lo12:__yommp0_MOD_nproc]
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lreject
 adrp x9,:got:__yomtraj_MOD_ltrajsave
 ldr x9,[x9,:got_lo12:__yomtraj_MOD_ltrajsave]
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 adrp x9,:got:__yomtraj_MOD_ltrajslag
 ldr x9,[x9,:got_lo12:__yomtraj_MOD_ltrajslag]
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 adrp x9,:got:__yomsekf_MOD_luse_smos_tb
 ldr x9,[x9,:got_lo12:__yomsekf_MOD_luse_smos_tb]
 ldr w10,[x9]
 cmp w10,#0
 b.ne .Lreject
 adrp x9,:got:__yomct0_MOD_nopt_memory
 ldr x9,[x9,:got_lo12:__yomct0_MOD_nopt_memory]
 ldr w9,[x9]
 cmp w9,#1
 b.le .Lreject
 add x9,x20,#1840
 ldr x9,[x9]
 cmp x9,x21
 b.ne .Lreject
 movz x16,#4504
 add x9,x20,x16
 ldr x9,[x9]
 add x10,x21,#192
 cmp x9,x10
 b.ne .Lreject
 add x9,x21,#4040
 mov x10,#8
.Lvalidate_components:
 ldr w11,[x9,#92]
 cbz w11,.Lvalidate_next
 ldr w11,[x9,#184]
 sub w11,w11,#1
 cmp w11,#7
 b.hi .Lreject
 ldr w11,[x9,#188]
 sub w11,w11,#1
 cmp w11,#5
 b.hi .Lreject
.Lvalidate_next:
 add x9,x9,#368
 subs x10,x10,#1
 b.ne .Lvalidate_components
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 str w9,[x29,#1536]
 ldr w9,[x29,#1536]
 cbz w9,.Lprofile0
 adrp x0,.Lname
 add x0,x0,:lo12:.Lname
 mov w9,#0
 str w9,[x29,#1540]
 add x1,x29,#1540
 add x2,x29,#1544
 mov x3,#8
 bl __yomhook_MOD_dr_hook_default8
.Lprofile0:
 adrp x0,.Ltracefile
 add x0,x0,:lo12:.Ltracefile
 mov w1,#215
 adrp x2,.Ltrace_title
 add x2,x2,:lo12:.Ltrace_title
 bl new_atlas_Trace
 str x0,[x29,#1592]
 mov w9,#2048
 str w9,[x29,#1560]
 mov w9,#1
 str w9,[x29,#1564]
 ldr x9,[x29,#792]
 ldrb w9,[x9,#3]
 cmp w9,#88
 cset w9,eq
 str w9,[x29,#1568]
 mov w9,#1228
 str w9,[x29,#1540]
 mov w9,#0
 str w9,[x29,#1532]
 add x0,x29,#1540
 add x1,x29,#1532
 bl gstats_
 add x9,x20,#2104
 ldr x9,[x9]
 cbnz x9,.Lallocated_gmvt1
 movz x0,#23680
 movk x0,#14,lsl #16
 bl malloc
 cbz x0,.Lreject
 add x9,x20,#2104
 str x0,[x9]
 mov x15,x0
 movz x10,#63687
 movk x10,#65535,lsl #16
 movk x10,#65535,lsl #32
 movk x10,#65535,lsl #48
 str x10,[x9,#8]
 movz x10,#8
 str x10,[x9,#16]
 movz x10,#0
 movk x10,#772,lsl #32
 str x10,[x9,#24]
 movz x10,#8
 str x10,[x9,#32]
 movz x10,#1
 str x10,[x9,#40]
 movz x10,#1
 str x10,[x9,#48]
 movz x10,#24
 str x10,[x9,#56]
 movz x10,#24
 str x10,[x9,#64]
 movz x10,#1
 str x10,[x9,#72]
 movz x10,#19
 str x10,[x9,#80]
 movz x10,#456
 str x10,[x9,#88]
 movz x10,#1
 str x10,[x9,#96]
 movz x10,#3
 str x10,[x9,#104]
 movz x10,#1368
 str x10,[x9,#112]
 movz x10,#1
 str x10,[x9,#120]
 movz x10,#86
 str x10,[x9,#128]
 mov x9,x15
 movz x10,#23680
 movk x10,#14,lsl #16
 bl .Lzero_bytes
.Lallocated_gmvt1:
 add x9,x20,#2240
 ldr x9,[x9]
 cbnz x9,.Lallocated_gmvt1s
 movz x0,#16512
 bl malloc
 cbz x0,.Lreject
 add x9,x20,#2240
 str x0,[x9]
 mov x15,x0
 movz x10,#65487
 movk x10,#65535,lsl #16
 movk x10,#65535,lsl #32
 movk x10,#65535,lsl #48
 str x10,[x9,#8]
 movz x10,#8
 str x10,[x9,#16]
 movz x10,#0
 movk x10,#771,lsl #32
 str x10,[x9,#24]
 movz x10,#8
 str x10,[x9,#32]
 movz x10,#1
 str x10,[x9,#40]
 movz x10,#1
 str x10,[x9,#48]
 movz x10,#24
 str x10,[x9,#56]
 movz x10,#24
 str x10,[x9,#64]
 movz x10,#1
 str x10,[x9,#72]
 movz x10,#1
 str x10,[x9,#80]
 movz x10,#24
 str x10,[x9,#88]
 movz x10,#1
 str x10,[x9,#96]
 movz x10,#86
 str x10,[x9,#104]
 mov x9,x15
 movz x10,#16512
 bl .Lzero_bytes
.Lallocated_gmvt1s:
 add x9,x20,#3552
 ldr x9,[x9]
 cbnz x9,.Lallocated_gflt1
 movz x0,#47360
 movk x0,#28,lsl #16
 bl malloc
 cbz x0,.Lreject
 add x9,x20,#3552
 str x0,[x9]
 mov x15,x0
 movz x10,#62319
 movk x10,#65535,lsl #16
 movk x10,#65535,lsl #32
 movk x10,#65535,lsl #48
 str x10,[x9,#8]
 movz x10,#8
 str x10,[x9,#16]
 movz x10,#0
 movk x10,#772,lsl #32
 str x10,[x9,#24]
 movz x10,#8
 str x10,[x9,#32]
 movz x10,#1
 str x10,[x9,#40]
 movz x10,#1
 str x10,[x9,#48]
 movz x10,#24
 str x10,[x9,#56]
 movz x10,#24
 str x10,[x9,#64]
 movz x10,#1
 str x10,[x9,#72]
 movz x10,#19
 str x10,[x9,#80]
 movz x10,#456
 str x10,[x9,#88]
 movz x10,#1
 str x10,[x9,#96]
 movz x10,#6
 str x10,[x9,#104]
 movz x10,#2736
 str x10,[x9,#112]
 movz x10,#1
 str x10,[x9,#120]
 movz x10,#86
 str x10,[x9,#128]
 mov x9,x15
 movz x10,#47360
 movk x10,#28,lsl #16
 bl .Lzero_bytes
.Lallocated_gflt1:
 mov w9,#1228
 str w9,[x29,#1540]
 mov w9,#1
 str w9,[x29,#1532]
 add x0,x29,#1540
 add x1,x29,#1532
 bl gstats_
 mov w9,#1228
 str w9,[x29,#1540]
 mov w9,#0
 str w9,[x29,#1532]
 add x0,x29,#1540
 add x1,x29,#1532
 bl gstats_
 movz x16,#1928
 movk x16,#24,lsl #16
 add x9,x21,x16
 ldr w9,[x9]
 cmp w9,#0
 b.le .Lpadding_done
 movz x16,#1920
 movk x16,#24,lsl #16
 add x9,x21,x16
 ldrsw x10,[x9]
 cmp x10,#1
 b.lt .Lreject
 cmp x10,#8192
 b.gt .Lreject
 mov x11,#463
 mul x10,x10,x11
 ldr x9,[x29,#824]
 movz x11,#65535
 movk x11,#65535,lsl #16
 movk x11,#65535,lsl #32
 movk x11,#32751,lsl #48
.Lpadding_loop:
 str x11,[x9],#8
 subs x10,x10,#1
 b.ne .Lpadding_loop
.Lpadding_done:
 ldr x9,[x29,#832]
 movz x10,#35968
 movk x10,#38,lsl #16
 bl .Lzero_bytes
 mov w9,#1228
 str w9,[x29,#1540]
 mov w9,#1
 str w9,[x29,#1532]
 add x0,x29,#1540
 add x1,x29,#1532
 bl gstats_
 movz x16,#4984
 movk x16,#8,lsl #16
 add x9,x20,x16
 ldr x9,[x9]
 cbnz x9,.Lregistry_done
 // Construct metadata after the original next-time allocations and zeroing.
 // The direct caller owns all seven methods and needs no Fortran vtable.
 mov x0,x19
 mov x1,x20
 mov x2,x21
 add x3,x29,#3360
 bl md2asm_prepare_field_registry
 ldr w9,[x29,#3360]
 cbnz w9,.Lreject
 adrp x16,.Lcounts
 add x16,x16,:lo12:.Lcounts
 ldr x17,[x16,#56]
 add x17,x17,#1
 str x17,[x16,#56]
.Lregistry_done:
 adrp x9,:got:__yomsmos_MOD_lesmos_active
 ldr x9,[x9,:got_lo12:__yomsmos_MOD_lesmos_active]
 str wzr,[x9]
 adrp x9,:got:__yomsmos_MOD_lesmap_active
 ldr x9,[x9,:got_lo12:__yomsmos_MOD_lesmap_active]
 str wzr,[x9]
 adrp x9,:got:__yomsmos_MOD_lesmos_sekf
 ldr x9,[x9,:got_lo12:__yomsmos_MOD_lesmos_sekf]
 str wzr,[x9]
 adrp x9,:got:__yomgbrad_MOD_legbrad_active
 ldr x9,[x9,:got_lo12:__yomgbrad_MOD_legbrad_active]
 str wzr,[x9]
 adrp x9,:got:__yomraingg_MOD_leraingg_active
 ldr x9,[x9,:got_lo12:__yomraingg_MOD_leraingg_active]
 str wzr,[x9]
 add x9,x29,#1760
 mov x10,#704
 bl .Lzero_bytes
 movz x16,#8184
 movk x16,#65,lsl #16
 add x9,x21,x16
 ldr w9,[x9]
 str w9,[x29,#1784]
 movz x16,#8196
 movk x16,#65,lsl #16
 add x9,x21,x16
 ldr w9,[x9]
 str w9,[x29,#1976]
 movz x16,#8188
 movk x16,#65,lsl #16
 add x9,x21,x16
 str wzr,[x9]
 movz x16,#8200
 movk x16,#65,lsl #16
 add x9,x21,x16
 str wzr,[x9]
 movz x0,#32496
 movk x0,#131,lsl #16
 bl malloc
 cbz x0,.Lreject
 mov x22,x0
 movz x16,#55936
 movk x16,#77,lsl #16
 add x9,x22,x16
 movz x10,#17712
 movk x10,#1,lsl #16
 bl .Lzero_bytes
 movz x16,#31792
 movk x16,#131,lsl #16
 add x9,x22,x16
 mov x10,#344
 bl .Lzero_bytes
 movz x16,#32144
 movk x16,#131,lsl #16
 add x9,x22,x16
 mov x10,#344
 bl .Lzero_bytes
 add x9,x20,#1856
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1024
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 ldr x12,[x9,#112]
 ldr x13,[x9,#120]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1024:
 str x10,[x29,#1024]
 add x9,x20,#1992
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1032
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1032:
 str x10,[x29,#1032]
 add x9,x20,#2104
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1040
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 ldr x12,[x9,#112]
 ldr x13,[x9,#120]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1040:
 str x10,[x29,#1040]
 add x9,x20,#2240
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1048
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1048:
 str x10,[x29,#1048]
 add x9,x20,#3416
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1056
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 ldr x12,[x9,#112]
 ldr x13,[x9,#120]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1056:
 str x10,[x29,#1056]
 movz x16,#10256
 add x9,x20,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1064
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 ldr x12,[x9,#112]
 ldr x13,[x9,#120]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1064:
 str x10,[x29,#1064]
 movz x16,#10544
 add x9,x20,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1072
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 ldr x12,[x9,#112]
 ldr x13,[x9,#120]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1072:
 str x10,[x29,#1072]
 movz x16,#11144
 add x9,x20,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1080
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1080:
 str x10,[x29,#1080]
 movz x16,#13296
 add x9,x20,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1088
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1088:
 str x10,[x29,#1088]
 movz x16,#33624
 movk x16,#24,lsl #16
 add x9,x21,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1096
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1096:
 str x10,[x29,#1096]
 movz x16,#33736
 movk x16,#24,lsl #16
 add x9,x21,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1104
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1104:
 str x10,[x29,#1104]
 movz x16,#9024
 movk x16,#65,lsl #16
 add x9,x21,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1112
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 ldr x12,[x9,#112]
 ldr x13,[x9,#120]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1112:
 str x10,[x29,#1112]
 movz x16,#9160
 movk x16,#65,lsl #16
 add x9,x21,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1120
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 ldr x12,[x9,#112]
 ldr x13,[x9,#120]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1120:
 str x10,[x29,#1120]
 movz x16,#34072
 movk x16,#24,lsl #16
 add x9,x21,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1128
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1128:
 str x10,[x29,#1128]
 movz x16,#35664
 movk x16,#24,lsl #16
 add x9,x21,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1136
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1136:
 str x10,[x29,#1136]
 movz x16,#9296
 movk x16,#65,lsl #16
 add x9,x21,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1144
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 ldr x12,[x9,#112]
 ldr x13,[x9,#120]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1144:
 str x10,[x29,#1144]
 movz x16,#34816
 movk x16,#62,lsl #16
 add x9,x21,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1152
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 ldr x12,[x9,#112]
 ldr x13,[x9,#120]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1152:
 str x10,[x29,#1152]
 movz x16,#34952
 movk x16,#62,lsl #16
 add x9,x21,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1160
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 ldr x12,[x9,#112]
 ldr x13,[x9,#120]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1160:
 str x10,[x29,#1160]
 movz x16,#35088
 movk x16,#62,lsl #16
 add x9,x21,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1168
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1168:
 str x10,[x29,#1168]
 movz x16,#35200
 movk x16,#62,lsl #16
 add x9,x21,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1176
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1176:
 str x10,[x29,#1176]
 movz x16,#35288
 movk x16,#62,lsl #16
 add x9,x21,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1184
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1184:
 str x10,[x29,#1184]
 movz x16,#33808
 movk x16,#62,lsl #16
 add x9,x21,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1192
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1192:
 str x10,[x29,#1192]
 movz x16,#33920
 movk x16,#62,lsl #16
 add x9,x21,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1200
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1200:
 str x10,[x29,#1200]
 movz x16,#34032
 movk x16,#62,lsl #16
 add x9,x21,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1208
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1208:
 str x10,[x29,#1208]
 movz x16,#34144
 movk x16,#62,lsl #16
 add x9,x21,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1216
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1216:
 str x10,[x29,#1216]
 movz x16,#34256
 movk x16,#62,lsl #16
 add x9,x21,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1224
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1224:
 str x10,[x29,#1224]
 movz x16,#34368
 movk x16,#62,lsl #16
 add x9,x21,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1232
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1232:
 str x10,[x29,#1232]
 movz x16,#34480
 movk x16,#62,lsl #16
 add x9,x21,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1240
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1240:
 str x10,[x29,#1240]
 movz x16,#34592
 movk x16,#62,lsl #16
 add x9,x21,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1248
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1248:
 str x10,[x29,#1248]
 movz x16,#34704
 movk x16,#62,lsl #16
 add x9,x21,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1256
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1256:
 str x10,[x29,#1256]
 movz x16,#33720
 movk x16,#62,lsl #16
 add x9,x21,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1264
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1264:
 str x10,[x29,#1264]
 movz x16,#9432
 movk x16,#65,lsl #16
 add x9,x21,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1272
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 ldr x12,[x9,#112]
 ldr x13,[x9,#120]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1272:
 str x10,[x29,#1272]
 movz x16,#9568
 movk x16,#65,lsl #16
 add x9,x21,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1280
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 ldr x12,[x9,#112]
 ldr x13,[x9,#120]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1280:
 str x10,[x29,#1280]
 add x9,x20,#3688
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1288
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 ldr x12,[x9,#112]
 ldr x13,[x9,#120]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1288:
 str x10,[x29,#1288]
 movz x16,#22136
 add x9,x20,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1296
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 ldr x12,[x9,#112]
 ldr x13,[x9,#120]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1296:
 str x10,[x29,#1296]
 add x9,x20,#3960
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1304
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 ldr x12,[x9,#112]
 ldr x13,[x9,#120]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1304:
 str x10,[x29,#1304]
 add x9,x20,#3824
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1312
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 ldr x12,[x9,#112]
 ldr x13,[x9,#120]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1312:
 str x10,[x29,#1312]
 movz x16,#11424
 add x9,x20,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1320
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1320:
 str x10,[x29,#1320]
 movz x16,#14368
 add x9,x20,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1328
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1328:
 str x10,[x29,#1328]
 movz x16,#14624
 add x9,x20,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1336
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1336:
 str x10,[x29,#1336]
 movz x16,#15224
 add x9,x20,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1344
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1344:
 str x10,[x29,#1344]
 movz x16,#15552
 add x9,x20,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1352
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1352:
 str x10,[x29,#1352]
 movz x16,#15800
 add x9,x20,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1360
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1360:
 str x10,[x29,#1360]
 movz x16,#16088
 add x9,x20,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1368
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1368:
 str x10,[x29,#1368]
 movz x16,#17000
 add x9,x20,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1376
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1376:
 str x10,[x29,#1376]
 movz x16,#21656
 add x9,x20,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1384
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1384:
 str x10,[x29,#1384]
 movz x16,#21896
 add x9,x20,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1392
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1392:
 str x10,[x29,#1392]
 movz x16,#20616
 add x9,x20,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1400
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 ldr x12,[x9,#112]
 ldr x13,[x9,#120]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1400:
 str x10,[x29,#1400]
 movz x16,#20880
 add x9,x20,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1408
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 ldr x12,[x9,#112]
 ldr x13,[x9,#120]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1408:
 str x10,[x29,#1408]
 movz x16,#12752
 add x9,x20,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1416
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 ldr x12,[x9,#112]
 ldr x13,[x9,#120]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1416:
 str x10,[x29,#1416]
 movz x16,#13024
 add x9,x20,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1424
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 ldr x12,[x9,#112]
 ldr x13,[x9,#120]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1424:
 str x10,[x29,#1424]
 add x9,x20,#3552
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1432
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 ldr x12,[x9,#112]
 ldr x13,[x9,#120]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1432:
 str x10,[x29,#1432]
 movz x16,#10848
 add x9,x20,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1440
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1440:
 str x10,[x29,#1440]
 movz x16,#12008
 add x9,x20,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1448
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 ldr x12,[x9,#112]
 ldr x13,[x9,#120]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1448:
 str x10,[x29,#1448]
 movz x16,#12272
 add x9,x20,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1456
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1456:
 str x10,[x29,#1456]
 movz x16,#14944
 add x9,x20,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1464
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1464:
 str x10,[x29,#1464]
 movz x16,#19648
 add x9,x20,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1472
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1472:
 str x10,[x29,#1472]
 movz x16,#19960
 add x9,x20,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1480
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1480:
 str x10,[x29,#1480]
 movz x16,#21416
 add x9,x20,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1488
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1488:
 str x10,[x29,#1488]
 movz x16,#19368
 add x9,x20,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1496
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 ldr x12,[x9,#112]
 ldr x13,[x9,#120]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1496:
 str x10,[x29,#1496]
 movz x16,#11712
 add x9,x20,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1504
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 ldr x12,[x9,#112]
 ldr x13,[x9,#120]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1504:
 str x10,[x29,#1504]
 movz x16,#16352
 add x9,x20,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1512
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1512:
 str x10,[x29,#1512]
 movz x16,#16616
 add x9,x20,x16
 ldr x10,[x9]
 cbz x10,.Lnull_descriptor_1520
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 madd x11,x12,x13,x11
 ldr x12,[x9,#64]
 ldr x13,[x9,#72]
 madd x11,x12,x13,x11
 ldr x12,[x9,#88]
 ldr x13,[x9,#96]
 madd x11,x12,x13,x11
 ldr x12,[x9,#112]
 ldr x13,[x9,#120]
 madd x11,x12,x13,x11
 add x10,x10,x11,lsl #3
.Lnull_descriptor_1520:
 str x10,[x29,#1520]
 ldr x0,[x29,#768]
 ldr x1,[x29,#784]
 ldr x2,[x29,#776]
 ldr x3,[x29,#792]
 add x3,x3,#3
 ldr x4,[x29,#800]
 movz x16,#904
 movk x16,#24,lsl #16
 add x5,x21,x16
 add x6,x29,#1560
 ldr x7,[x29,#1288]
 ldr x9,[x29,#1112]
 str x9,[sp,#0]
 ldr x9,[x29,#1120]
 str x9,[sp,#8]
 add x9,x29,#1584
 str x9,[sp,#16]
 ldr x9,[x29,#1296]
 str x9,[sp,#24]
 movz x16,#55936
 movk x16,#77,lsl #16
 add x9,x22,x16
 str x9,[sp,#32]
 ldr x9,[x29,#1024]
 str x9,[sp,#40]
 ldr x9,[x29,#1032]
 str x9,[sp,#48]
 ldr x9,[x29,#1056]
 str x9,[sp,#56]
 ldr x9,[x29,#1304]
 str x9,[sp,#64]
 ldr x9,[x29,#1312]
 str x9,[sp,#72]
 ldr x9,[x29,#1064]
 str x9,[sp,#80]
 ldr x9,[x29,#1072]
 str x9,[sp,#88]
 ldr x9,[x29,#1080]
 str x9,[sp,#96]
 ldr x9,[x29,#1320]
 str x9,[sp,#104]
 ldr x9,[x29,#1088]
 str x9,[sp,#112]
 ldr x9,[x29,#1328]
 str x9,[sp,#120]
 ldr x9,[x29,#1336]
 str x9,[sp,#128]
 ldr x9,[x29,#1344]
 str x9,[sp,#136]
 ldr x9,[x29,#1352]
 str x9,[sp,#144]
 ldr x9,[x29,#1360]
 str x9,[sp,#152]
 ldr x9,[x29,#1368]
 str x9,[sp,#160]
 ldr x9,[x29,#1376]
 str x9,[sp,#168]
 ldr x9,[x29,#1384]
 str x9,[sp,#176]
 ldr x9,[x29,#1392]
 str x9,[sp,#184]
 ldr x9,[x29,#1400]
 str x9,[sp,#192]
 ldr x9,[x29,#1408]
 str x9,[sp,#200]
 ldr x9,[x29,#1416]
 str x9,[sp,#208]
 ldr x9,[x29,#1424]
 str x9,[sp,#216]
 ldr x9,[x29,#1096]
 str x9,[sp,#224]
 ldr x9,[x29,#1128]
 str x9,[sp,#232]
 ldr x9,[x29,#1104]
 str x9,[sp,#240]
 ldr x9,[x29,#1136]
 str x9,[sp,#248]
 ldr x9,[x29,#1144]
 str x9,[sp,#256]
 ldr x9,[x29,#1152]
 str x9,[sp,#264]
 ldr x9,[x29,#1160]
 str x9,[sp,#272]
 ldr x9,[x29,#1168]
 str x9,[sp,#280]
 ldr x9,[x29,#1176]
 str x9,[sp,#288]
 ldr x9,[x29,#1184]
 str x9,[sp,#296]
 ldr x9,[x29,#1192]
 str x9,[sp,#304]
 ldr x9,[x29,#1200]
 str x9,[sp,#312]
 ldr x9,[x29,#1208]
 str x9,[sp,#320]
 ldr x9,[x29,#1216]
 str x9,[sp,#328]
 ldr x9,[x29,#1224]
 str x9,[sp,#336]
 ldr x9,[x29,#1232]
 str x9,[sp,#344]
 ldr x9,[x29,#1240]
 str x9,[sp,#352]
 ldr x9,[x29,#1248]
 str x9,[sp,#360]
 ldr x9,[x29,#1256]
 str x9,[sp,#368]
 ldr x9,[x29,#1264]
 str x9,[sp,#376]
 ldr x9,[x29,#824]
 str x9,[sp,#384]
 ldr x9,[x29,#832]
 str x9,[sp,#392]
 ldr x9,[x29,#1040]
 str x9,[sp,#400]
 ldr x9,[x29,#1048]
 str x9,[sp,#408]
 ldr x9,[x29,#1432]
 str x9,[sp,#416]
 add x9,x29,#1584
 str x9,[sp,#424]
 ldr x9,[x29,#1272]
 str x9,[sp,#432]
 ldr x9,[x29,#1280]
 str x9,[sp,#440]
 add x9,x29,#1760
 str x9,[sp,#448]
 movz x16,#0
 add x9,x22,x16
 str x9,[sp,#456]
 movz x16,#51584
 movk x16,#4,lsl #16
 add x9,x22,x16
 str x9,[sp,#464]
 movz x16,#9728
 movk x16,#19,lsl #16
 add x9,x22,x16
 str x9,[sp,#472]
 movz x16,#61312
 movk x16,#23,lsl #16
 add x9,x22,x16
 str x9,[sp,#480]
 movz x16,#8576
 movk x16,#49,lsl #16
 add x9,x22,x16
 str x9,[sp,#488]
 ldr x9,[x29,#840]
 str x9,[sp,#496]
 ldr x9,[x29,#848]
 str x9,[sp,#504]
 mov x9,#1
 str x9,[sp,#512]
 bl md2asm_cpg_drv_7358525
 adrp x16,.Lcounts
 add x16,x16,:lo12:.Lcounts
 ldr x17,[x16,#8]
 add x17,x17,#1
 str x17,[x16,#8]
 ldr x0,[x29,#768]
 add x1,x20,#1856
 ldr x2,[x29,#784]
 ldr x3,[x29,#1056]
 movz x16,#904
 movk x16,#24,lsl #16
 add x4,x21,x16
 movz x16,#31792
 movk x16,#131,lsl #16
 add x5,x22,x16
 movz x16,#32144
 movk x16,#131,lsl #16
 add x6,x22,x16
 ldr x7,[x29,#824]
 ldr x9,[x29,#832]
 str x9,[sp,#0]
 movz x16,#8576
 movk x16,#49,lsl #16
 add x9,x22,x16
 str x9,[sp,#8]
 ldr x9,[x29,#1040]
 str x9,[sp,#16]
 ldr x9,[x29,#1048]
 str x9,[sp,#24]
 ldr x9,[x29,#1432]
 str x9,[sp,#32]
 ldr x9,[x29,#1304]
 str x9,[sp,#40]
 ldr x9,[x29,#808]
 str x9,[sp,#48]
 ldr x9,[x29,#816]
 str x9,[sp,#56]
 movz x16,#60160
 movk x16,#53,lsl #16
 add x9,x22,x16
 str x9,[sp,#64]
 movz x16,#46208
 movk x16,#58,lsl #16
 add x9,x22,x16
 str x9,[sp,#72]
 movz x16,#32256
 movk x16,#63,lsl #16
 add x9,x22,x16
 str x9,[sp,#80]
 movz x16,#18304
 movk x16,#68,lsl #16
 add x9,x22,x16
 str x9,[sp,#88]
 bl md2asm_call_sl_heap2_7358525
 adrp x16,.Lcounts
 add x16,x16,:lo12:.Lcounts
 ldr x17,[x16,#16]
 add x17,x17,#1
 str x17,[x16,#16]
 mov w9,#7
 str w9,[x29,#1540]
 mov w9,#0
 str w9,[x29,#1532]
 add x0,x29,#1540
 add x1,x29,#1532
 bl gstats_
 ldr x0,[x29,#768]
 add x1,x20,#1856
 movz x16,#37560
 movk x16,#64,lsl #16
 add x2,x21,x16
 movz x16,#4504
 movk x16,#24,lsl #16
 add x3,x21,x16
 add x4,x21,#8
 movz x16,#56808
 movk x16,#23,lsl #16
 add x5,x21,x16
 add x6,x29,#1564
 ldr x7,[x29,#808]
 ldr x9,[x29,#816]
 str x9,[sp,#0]
 ldr x9,[x29,#824]
 str x9,[sp,#8]
 movz x16,#904
 movk x16,#24,lsl #16
 add x9,x21,x16
 str x9,[sp,#16]
 ldr x9,[x29,#1032]
 str x9,[sp,#24]
 ldr x9,[x29,#1048]
 str x9,[sp,#32]
 ldr x9,[x29,#1056]
 str x9,[sp,#40]
 ldr x9,[x29,#1432]
 str x9,[sp,#48]
 add x9,x29,#1584
 str x9,[sp,#56]
 bl md2asm_trmfixers_address_r2_7358525
 adrp x16,.Lcounts
 add x16,x16,:lo12:.Lcounts
 ldr x17,[x16,#24]
 add x17,x17,#1
 str x17,[x16,#24]
 mov w9,#7
 str w9,[x29,#1540]
 mov w9,#1
 str w9,[x29,#1532]
 add x0,x29,#1540
 add x1,x29,#1532
 bl gstats_
 mov w9,#8
 str w9,[x29,#1540]
 mov w9,#2
 str w9,[x29,#1532]
 add x0,x29,#1540
 add x1,x29,#1532
 bl gstats_
 mov w9,#10
 str w9,[x29,#1540]
 mov w9,#0
 str w9,[x29,#1532]
 add x0,x29,#1540
 add x1,x29,#1532
 bl gstats_
 mov w9,#8
 str w9,[x29,#1540]
 mov w9,#2
 str w9,[x29,#1532]
 add x0,x29,#1540
 add x1,x29,#1532
 bl gstats_
 mov w9,#13
 str w9,[x29,#1540]
 mov w9,#0
 str w9,[x29,#1532]
 add x0,x29,#1540
 add x1,x29,#1532
 bl gstats_
 mov x23,#0
.Lswap_block:
 mov x25,#24
 cmp x23,#85
 b.ne .Lswap_row_count
 mov x25,#8
.Lswap_row_count:
 mov x24,#0
.Lswap_component:
 add x9,x21,#4040
 mov x10,#368
 madd x9,x24,x10,x9
 ldr w10,[x9,#92]
 cbz w10,.Lswap_next_component
 ldrsw x10,[x9,#184]
 sub x10,x10,#1
 mov x11,#3648
 mul x10,x10,x11
 mov x11,#29184
 madd x10,x23,x11,x10
 ldr x26,[x29,#1056]
 add x26,x26,x10
 movz x16,#8112
 movk x16,#79,lsl #16
 add x28,x22,x16
 movz x10,#49152
 movk x10,#4,lsl #16
 mul x10,x24,x10
 mov x11,#192
 madd x10,x23,x11,x10
 add x28,x28,x10
 ldrsw x10,[x9,#188]
 sub x10,x10,#1
 mov x11,#3648
 mul x10,x10,x11
 mov x11,#21888
 madd x10,x23,x11,x10
 ldr x27,[x29,#1432]
 add x27,x27,x10
 mov x10,#19
.Lswap_level:
 mov x11,#0
.Lswap_row:
 ldr x12,[x26,x11,lsl #3]
 str x12,[x28,x11,lsl #3]
 ldr x12,[x27,x11,lsl #3]
 str x12,[x26,x11,lsl #3]
 add x11,x11,#1
 cmp x11,x25
 b.lo .Lswap_row
 add x26,x26,#192
 add x28,x28,#4,lsl #12
 add x27,x27,#192
 subs x10,x10,#1
 b.ne .Lswap_level
.Lswap_next_component:
 add x24,x24,#1
 cmp x24,#8
 b.lo .Lswap_component
 add x23,x23,#1
 cmp x23,#86
 b.lo .Lswap_block
 ldr x0,[x29,#768]
 ldr x1,[x29,#776]
 ldr x2,[x29,#784]
 movz x16,#7376
 add x3,x19,x16
 movz x16,#456
 movk x16,#24,lsl #16
 add x4,x21,x16
 movz x16,#5160
 add x5,x19,x16
 ldr x6,[x29,#832]
 bl md2asm_radiation_driver_caller
 adrp x16,.Lcounts
 add x16,x16,:lo12:.Lcounts
 ldr x17,[x16,#32]
 add x17,x17,#1
 str x17,[x16,#32]
 mov x23,#0
.Lrestore_block:
 mov x25,#24
 cmp x23,#85
 b.ne .Lrestore_row_count
 mov x25,#8
.Lrestore_row_count:
 mov x24,#0
.Lrestore_component:
 add x9,x21,#4040
 mov x10,#368
 madd x9,x24,x10,x9
 ldr w10,[x9,#92]
 cbz w10,.Lrestore_next_component
 ldrsw x10,[x9,#184]
 sub x10,x10,#1
 mov x11,#3648
 mul x10,x10,x11
 mov x11,#29184
 madd x10,x23,x11,x10
 ldr x26,[x29,#1056]
 add x26,x26,x10
 movz x16,#8112
 movk x16,#79,lsl #16
 add x28,x22,x16
 movz x10,#49152
 movk x10,#4,lsl #16
 mul x10,x24,x10
 mov x11,#192
 madd x10,x23,x11,x10
 add x28,x28,x10
 mov x10,#19
.Lrestore_level:
 mov x11,#0
.Lrestore_row:
 ldr x12,[x28,x11,lsl #3]
 str x12,[x26,x11,lsl #3]
 add x11,x11,#1
 cmp x11,x25
 b.lo .Lrestore_row
 add x26,x26,#192
 add x28,x28,#4,lsl #12
 subs x10,x10,#1
 b.ne .Lrestore_level
.Lrestore_next_component:
 add x24,x24,#1
 cmp x24,#8
 b.lo .Lrestore_component
 add x23,x23,#1
 cmp x23,#86
 b.lo .Lrestore_block
 mov w9,#13
 str w9,[x29,#1540]
 mov w9,#1
 str w9,[x29,#1532]
 add x0,x29,#1540
 add x1,x29,#1532
 bl gstats_
 mov w9,#8
 str w9,[x29,#1540]
 mov w9,#3
 str w9,[x29,#1532]
 add x0,x29,#1540
 add x1,x29,#1532
 bl gstats_
 ldr x0,[x29,#768]
 ldr x1,[x29,#776]
 movz x16,#4984
 movk x16,#8,lsl #16
 add x2,x20,x16
 ldr x2,[x2]
 add x3,x20,#1856
 movz x16,#4512
 add x4,x20,x16
 ldr x5,[x29,#784]
 ldr x6,[x29,#792]
 add x6,x6,#3
 ldr x7,[x29,#832]
 movz x16,#60160
 movk x16,#53,lsl #16
 add x9,x22,x16
 str x9,[sp,#0]
 movz x16,#46208
 movk x16,#58,lsl #16
 add x9,x22,x16
 str x9,[sp,#8]
 movz x16,#32256
 movk x16,#63,lsl #16
 add x9,x22,x16
 str x9,[sp,#16]
 movz x16,#18304
 movk x16,#68,lsl #16
 add x9,x22,x16
 str x9,[sp,#24]
 add x9,x29,#1584
 str x9,[sp,#32]
 ldr x9,[x29,#1296]
 str x9,[sp,#40]
 ldr x9,[x29,#1024]
 str x9,[sp,#48]
 ldr x9,[x29,#1032]
 str x9,[sp,#56]
 ldr x9,[x29,#1040]
 str x9,[sp,#64]
 ldr x9,[x29,#1048]
 str x9,[sp,#72]
 ldr x9,[x29,#1432]
 str x9,[sp,#80]
 ldr x9,[x29,#1312]
 str x9,[sp,#88]
 ldr x9,[x29,#1056]
 str x9,[sp,#96]
 ldr x9,[x29,#1288]
 str x9,[sp,#104]
 ldr x9,[x29,#1064]
 str x9,[sp,#112]
 ldr x9,[x29,#1072]
 str x9,[sp,#120]
 ldr x9,[x29,#1440]
 str x9,[sp,#128]
 ldr x9,[x29,#1080]
 str x9,[sp,#136]
 ldr x9,[x29,#1448]
 str x9,[sp,#144]
 ldr x9,[x29,#1456]
 str x9,[sp,#152]
 ldr x9,[x29,#1088]
 str x9,[sp,#160]
 ldr x9,[x29,#1464]
 str x9,[sp,#168]
 ldr x9,[x29,#1376]
 str x9,[sp,#176]
 ldr x9,[x29,#1472]
 str x9,[sp,#184]
 ldr x9,[x29,#1480]
 str x9,[sp,#192]
 ldr x9,[x29,#1400]
 str x9,[sp,#200]
 ldr x9,[x29,#1488]
 str x9,[sp,#208]
 ldr x9,[x29,#1496]
 str x9,[sp,#216]
 ldr x9,[x29,#1504]
 str x9,[sp,#224]
 ldr x9,[x29,#1512]
 str x9,[sp,#232]
 ldr x9,[x29,#1520]
 str x9,[sp,#240]
 movz x16,#25728
 add x9,x20,x16
 str x9,[sp,#248]
 movz x16,#26288
 add x9,x20,x16
 str x9,[sp,#256]
 add x9,x29,#1584
 str x9,[sp,#264]
 add x9,x29,#1584
 str x9,[sp,#272]
 add x9,x29,#1584
 str x9,[sp,#280]
 add x9,x29,#1584
 str x9,[sp,#288]
 add x9,x29,#1584
 str x9,[sp,#296]
 add x9,x29,#1584
 str x9,[sp,#304]
 add x9,x29,#1584
 str x9,[sp,#312]
 add x9,x29,#1584
 str x9,[sp,#320]
 add x9,x29,#1584
 str x9,[sp,#328]
 add x9,x29,#1584
 str x9,[sp,#336]
 ldr x9,[x29,#840]
 str x9,[sp,#344]
 ldr x9,[x29,#848]
 str x9,[sp,#352]
 mov x9,#1
 str x9,[sp,#360]
 bl md2asm_complete_physics_driver_cape_r5_7358525
 adrp x16,.Lcounts
 add x16,x16,:lo12:.Lcounts
 ldr x17,[x16,#40]
 add x17,x17,#1
 str x17,[x16,#40]
 mov w9,#1040
 str w9,[x29,#1540]
 mov w9,#0
 str w9,[x29,#1532]
 add x0,x29,#1540
 add x1,x29,#1532
 bl gstats_
 mov x23,#0
.Llagged_block:
 mov w9,#24
 mul w9,w23,w9
 add w9,w9,#1
 str w9,[x29,#1572]
 ldr x9,[x29,#1024]
 movz x16,#128
 movk x16,#1,lsl #16
 madd x9,x23,x16,x9
 str x9,[x29,#2464]
 movz x9,#65055
 movk x9,#65535,lsl #16
 movk x9,#65535,lsl #32
 movk x9,#65535,lsl #48
 str x9,[x29,#2472]
 movz x9,#8
 str x9,[x29,#2480]
 movz x9,#0
 movk x9,#771,lsl #32
 str x9,[x29,#2488]
 movz x9,#8
 str x9,[x29,#2496]
 movz x9,#1
 str x9,[x29,#2504]
 movz x9,#1
 str x9,[x29,#2512]
 movz x9,#24
 str x9,[x29,#2520]
 movz x9,#24
 str x9,[x29,#2528]
 movz x9,#1
 str x9,[x29,#2536]
 movz x9,#19
 str x9,[x29,#2544]
 movz x9,#456
 str x9,[x29,#2552]
 movz x9,#1
 str x9,[x29,#2560]
 movz x9,#18
 str x9,[x29,#2568]
 ldr x9,[x29,#1032]
 movz x16,#576
 madd x9,x23,x16,x9
 str x9,[x29,#2576]
 movz x9,#65511
 movk x9,#65535,lsl #16
 movk x9,#65535,lsl #32
 movk x9,#65535,lsl #48
 str x9,[x29,#2584]
 movz x9,#8
 str x9,[x29,#2592]
 movz x9,#0
 movk x9,#770,lsl #32
 str x9,[x29,#2600]
 movz x9,#8
 str x9,[x29,#2608]
 movz x9,#1
 str x9,[x29,#2616]
 movz x9,#1
 str x9,[x29,#2624]
 movz x9,#24
 str x9,[x29,#2632]
 movz x9,#24
 str x9,[x29,#2640]
 movz x9,#1
 str x9,[x29,#2648]
 movz x9,#3
 str x9,[x29,#2656]
 ldr x9,[x29,#832]
 movz x16,#29376
 madd x9,x23,x16,x9
 str x9,[x29,#2688]
 movz x9,#65511
 movk x9,#65535,lsl #16
 movk x9,#65535,lsl #32
 movk x9,#65535,lsl #48
 str x9,[x29,#2696]
 movz x9,#8
 str x9,[x29,#2704]
 movz x9,#0
 movk x9,#770,lsl #32
 str x9,[x29,#2712]
 movz x9,#8
 str x9,[x29,#2720]
 movz x9,#1
 str x9,[x29,#2728]
 movz x9,#1
 str x9,[x29,#2736]
 movz x9,#24
 str x9,[x29,#2744]
 movz x9,#24
 str x9,[x29,#2752]
 movz x9,#1
 str x9,[x29,#2760]
 movz x9,#153
 str x9,[x29,#2768]
 ldr x9,[x29,#1432]
 movz x16,#21888
 madd x9,x23,x16,x9
 str x9,[x29,#2800]
 movz x9,#65055
 movk x9,#65535,lsl #16
 movk x9,#65535,lsl #32
 movk x9,#65535,lsl #48
 str x9,[x29,#2808]
 movz x9,#8
 str x9,[x29,#2816]
 movz x9,#0
 movk x9,#771,lsl #32
 str x9,[x29,#2824]
 movz x9,#8
 str x9,[x29,#2832]
 movz x9,#1
 str x9,[x29,#2840]
 movz x9,#1
 str x9,[x29,#2848]
 movz x9,#24
 str x9,[x29,#2856]
 movz x9,#24
 str x9,[x29,#2864]
 movz x9,#1
 str x9,[x29,#2872]
 movz x9,#19
 str x9,[x29,#2880]
 movz x9,#456
 str x9,[x29,#2888]
 movz x9,#1
 str x9,[x29,#2896]
 movz x9,#6
 str x9,[x29,#2904]
 ldr x9,[x29,#1040]
 movz x16,#10944
 madd x9,x23,x16,x9
 str x9,[x29,#2912]
 movz x9,#65055
 movk x9,#65535,lsl #16
 movk x9,#65535,lsl #32
 movk x9,#65535,lsl #48
 str x9,[x29,#2920]
 movz x9,#8
 str x9,[x29,#2928]
 movz x9,#0
 movk x9,#771,lsl #32
 str x9,[x29,#2936]
 movz x9,#8
 str x9,[x29,#2944]
 movz x9,#1
 str x9,[x29,#2952]
 movz x9,#1
 str x9,[x29,#2960]
 movz x9,#24
 str x9,[x29,#2968]
 movz x9,#24
 str x9,[x29,#2976]
 movz x9,#1
 str x9,[x29,#2984]
 movz x9,#19
 str x9,[x29,#2992]
 movz x9,#456
 str x9,[x29,#3000]
 movz x9,#1
 str x9,[x29,#3008]
 movz x9,#3
 str x9,[x29,#3016]
 ldr x9,[x29,#1048]
 movz x16,#192
 madd x9,x23,x16,x9
 str x9,[x29,#3024]
 movz x9,#65511
 movk x9,#65535,lsl #16
 movk x9,#65535,lsl #32
 movk x9,#65535,lsl #48
 str x9,[x29,#3032]
 movz x9,#8
 str x9,[x29,#3040]
 movz x9,#0
 movk x9,#770,lsl #32
 str x9,[x29,#3048]
 movz x9,#8
 str x9,[x29,#3056]
 movz x9,#1
 str x9,[x29,#3064]
 movz x9,#1
 str x9,[x29,#3072]
 movz x9,#24
 str x9,[x29,#3080]
 movz x9,#24
 str x9,[x29,#3088]
 movz x9,#1
 str x9,[x29,#3096]
 movz x9,#1
 str x9,[x29,#3104]
 ldr x9,[x29,#1056]
 movz x16,#29184
 madd x9,x23,x16,x9
 str x9,[x29,#3136]
 movz x9,#65055
 movk x9,#65535,lsl #16
 movk x9,#65535,lsl #32
 movk x9,#65535,lsl #48
 str x9,[x29,#3144]
 movz x9,#8
 str x9,[x29,#3152]
 movz x9,#0
 movk x9,#771,lsl #32
 str x9,[x29,#3160]
 movz x9,#8
 str x9,[x29,#3168]
 movz x9,#1
 str x9,[x29,#3176]
 movz x9,#1
 str x9,[x29,#3184]
 movz x9,#24
 str x9,[x29,#3192]
 movz x9,#24
 str x9,[x29,#3200]
 movz x9,#1
 str x9,[x29,#3208]
 movz x9,#19
 str x9,[x29,#3216]
 movz x9,#456
 str x9,[x29,#3224]
 movz x9,#1
 str x9,[x29,#3232]
 movz x9,#8
 str x9,[x29,#3240]
 movz x16,#8112
 movk x16,#117,lsl #16
 add x9,x22,x16
 movz x16,#10944
 madd x9,x23,x16,x9
 str x9,[x29,#3248]
 movz x9,#65055
 movk x9,#65535,lsl #16
 movk x9,#65535,lsl #32
 movk x9,#65535,lsl #48
 str x9,[x29,#3256]
 movz x9,#8
 str x9,[x29,#3264]
 movz x9,#0
 movk x9,#771,lsl #32
 str x9,[x29,#3272]
 movz x9,#8
 str x9,[x29,#3280]
 movz x9,#1
 str x9,[x29,#3288]
 movz x9,#1
 str x9,[x29,#3296]
 movz x9,#24
 str x9,[x29,#3304]
 movz x9,#24
 str x9,[x29,#3312]
 movz x9,#1
 str x9,[x29,#3320]
 movz x9,#19
 str x9,[x29,#3328]
 movz x9,#456
 str x9,[x29,#3336]
 movz x9,#1
 str x9,[x29,#3344]
 movz x9,#3
 str x9,[x29,#3352]
 mov x0,x19
 add x1,x20,#1856
 movz x16,#38096
 movk x16,#64,lsl #16
 add x2,x21,x16
 add x3,x21,#8
 movz x16,#56808
 movk x16,#23,lsl #16
 add x4,x21,x16
 add x5,x29,#1560
 add x6,x29,#1572
 add x7,x29,#1568
 ldr x9,[x29,#2464]
 str x9,[sp,#0]
 ldr x9,[x29,#2576]
 str x9,[sp,#8]
 ldr x9,[x29,#2688]
 str x9,[sp,#16]
 ldr x9,[x29,#2800]
 str x9,[sp,#24]
 ldr x9,[x29,#2912]
 str x9,[sp,#32]
 ldr x9,[x29,#3024]
 str x9,[sp,#40]
 ldr x9,[x29,#3136]
 str x9,[sp,#48]
 ldr x9,[x29,#1272]
 str x9,[sp,#56]
 ldr x9,[x29,#1280]
 str x9,[sp,#64]
 add x9,x29,#1760
 str x9,[sp,#72]
 ldr x9,[x29,#3248]
 str x9,[sp,#80]
 ldr x9,[x29,#840]
 str x9,[sp,#88]
 ldr x9,[x29,#848]
 str x9,[sp,#96]
 bl md2asm_lagged_grid_update_private_entry
 adrp x16,.Lcounts
 add x16,x16,:lo12:.Lcounts
 ldr x17,[x16,#48]
 add x17,x17,#1
 str x17,[x16,#48]
 add x23,x23,#1
 cmp x23,#86
 b.lo .Llagged_block
 mov w9,#1040
 str w9,[x29,#1540]
 mov w9,#1
 str w9,[x29,#1532]
 add x0,x29,#1540
 add x1,x29,#1532
 bl gstats_
 mov w9,#10
 str w9,[x29,#1540]
 mov w9,#1
 str w9,[x29,#1532]
 add x0,x29,#1540
 add x1,x29,#1532
 bl gstats_
 mov w9,#8
 str w9,[x29,#1540]
 mov w9,#3
 str w9,[x29,#1532]
 add x0,x29,#1540
 add x1,x29,#1532
 bl gstats_
 mov x0,x22
 bl free
 ldr x0,[x29,#1592]
 bl delete_atlas_Trace
 adrp x16,.Lcounts
 add x16,x16,:lo12:.Lcounts
 ldr x17,[x16,#0]
 add x17,x17,#1
 str x17,[x16,#0]
 ldr w9,[x29,#1536]
 cbz w9,.Lprofile1
 adrp x0,.Lname
 add x0,x0,:lo12:.Lname
 mov w9,#1
 str w9,[x29,#1540]
 add x1,x29,#1540
 add x2,x29,#1544
 mov x3,#8
 bl __yomhook_MOD_dr_hook_default8
.Lprofile1:
 add x16,sp,#640
 ldp x18,x19,[x16,#0]
 ldp x20,x21,[x16,#16]
 ldp x22,x23,[x16,#32]
 ldp x24,x25,[x16,#48]
 ldp x26,x27,[x16,#64]
 ldp x28,x29,[x16,#80]
 ldr x30,[sp,#736]
 add sp,sp,#4096
 ret
.Lreject:
 bl abort
 brk #0
.size md2asm_gp_model_lagged_raw_caller_r8_7388001,.-md2asm_gp_model_lagged_raw_caller_r8_7388001
.size md2asm_gp_model_physics_cape_r7_7358525,.-md2asm_gp_model_physics_cape_r7_7358525
.Lzero_bytes:
 cbz x10,.Lzero_done
.Lzero_loop:
 str xzr,[x9],#8
 subs x10,x10,#8
 b.ne .Lzero_loop
.Lzero_done:
 ret
.global md2asm_gp_model_physics_cape_r7_stage_count_get
.type md2asm_gp_model_physics_cape_r7_stage_count_get,%function
md2asm_gp_model_physics_cape_r7_stage_count_get:
 cmp w0,#7
 b.hi .Lcount_zero
 adrp x9,.Lcounts
 add x9,x9,:lo12:.Lcounts
 ldr x0,[x9,x0,lsl #3]
 ret
.Lcount_zero:
 mov x0,#0
 ret
.section .rodata
.Lname: .ascii "GP_MODEL"
.Ltracefile: .asciz "gp_model.F90"
.Ltrace_title: .asciz "GP_MODEL"
.bss
.p2align 3
.Lcounts: .zero 64
.section .note.GNU-stack,"",%progbits
