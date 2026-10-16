/* Source-owned scalar state for the selected one-process forecast.
 * x0 text, x1 bytes, x2 table80 of address/capacity pairs.
 * Views: forecast51512, loop552, TMCC7584, process count4, output112.
 * All views are mapped, aligned and disjoint. Return0/2 before mutation.
 * The accepted loop producer has already admitted first NAMPAR1/NAMVAR.
 * This parent admits empty first NAMPPVI, then commits all named scalars.
 * Integer-only frame208 preserves x18, saved GP registers and FP state. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_selected_forecast_scalar_data
.type md2asm_initialize_selected_forecast_scalar_data,%function
md2asm_initialize_selected_forecast_scalar_data:
 cbz x0,.Lbad_leaf
 cbz x1,.Lbad_leaf
 cbz x2,.Lbad_leaf
 cmp x1,#64,lsl#12
 b.hi .Lbad_leaf
 tst x2,#7
 b.ne .Lbad_leaf
 adds x9,x0,x1
 b.cs .Lbad_leaf
 adds x10,x2,#80
 b.cs .Lbad_leaf
 mrs x11,fpcr
 cbnz x11,.Lbad_leaf
 sub sp,sp,#208
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 str x18,[sp,#64]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 stp x0,x9,[sp,#80]
 stp x2,x10,[sp,#96]
 adrp x17,.Lcapacities
 add x17,x17,:lo12:.Lcapacities
 mov x8,#0
.Lview:
 add x9,x21,x8,lsl#4
 ldp x10,x11,[x9]
 cbz x10,.Lbad
 cmp x8,#3
 mov x12,#7
 mov x13,#3
 csel x12,x13,x12,eq
 tst x10,x12
 b.ne .Lbad
 ldr x12,[x17,x8,lsl#3]
 cmp x11,x12
 b.lo .Lbad
 adds x11,x10,x12
 b.cs .Lbad
 add x9,sp,#112
 add x9,x9,x8,lsl#4
 stp x10,x11,[x9]
 add x8,x8,#1
 cmp x8,#5
 b.lo .Lview
 mov x8,#0
.Louter:
 add x9,sp,#80
 add x9,x9,x8,lsl#4
 ldp x10,x11,[x9]
 add x12,x8,#1
.Linner:
 cmp x12,#7
 b.hs .Lnext
 add x9,sp,#80
 add x9,x9,x12,lsl#4
 ldp x13,x14,[x9]
 cmp x10,x14
 b.hs .Lclear
 cmp x13,x11
 b.lo .Lbad
.Lclear:
 add x12,x12,#1
 b .Linner
.Lnext:
 add x8,x8,#1
 cmp x8,#6
 b.lo .Louter
 ldr x22,[x21,#64]
 adrp x9,:got:md2asm_owned_forecast_scalar_data
 ldr x9,[x9,:got_lo12:md2asm_owned_forecast_scalar_data]
 cmp x22,x9
 b.ne .Lbad
 ldr x9,[x21]
 mov x10,#35104
 ldr w11,[x9,x10]
 cmp w11,#1
 b.ne .Lbad
 mov x10,#35184
 ldr w11,[x9,x10]
 cbnz w11,.Lbad
 mov x10,#35288
 ldr w11,[x9,x10]
 cbnz w11,.Lbad
 mov x10,#39520
 ldr w11,[x9,x10]
 cmp w11,#1
 b.ne .Lbad
 mov x10,#35264
 ldr w23,[x9,x10]
 cmp w23,#1
 b.hi .Lbad
 mov x10,#35180
 ldr w11,[x9,x10]
 cbnz w11,.Lbad
 ldr x9,[x21,#16]
 ldr x10,[x9,#544]
 cmp x10,#15
 b.ne .Lbad
 ldr w10,[x9,#16]
 cmp w10,#1
 b.ne .Lbad
 mov w24,#0
 ldr x9,[x21,#32]
 mov x10,#7424
 ldr w11,[x9,x10]
 cbnz w11,.Lbad
 ldr x9,[x21,#48]
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lbad
 mov x0,x19
 mov x1,x20
 adrp x2,.Lnamppvi
 add x2,x2,:lo12:.Lnamppvi
 mov x3,#7
 bl md2asm_require_empty_physics_group
 ldr x18,[sp,#64]
 cbnz w0,.Lleave
 mov x9,x22
 mov x10,#14
.Lzero:
 str xzr,[x9],#8
 subs x10,x10,#1
 b.ne .Lzero
 str w24,[x22,#28]
 mov w9,#1
 str w9,[x22,#32]
 str w23,[x22,#40]
 mov w9,#-1
 str w9,[x22,#104]
 mov w0,#0
 b .Lleave
.Lbad:
 mov w0,#2
.Lleave:
 ldr x18,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#208
 ret
.Lbad_leaf:
 mov w0,#2
 ret
.size md2asm_initialize_selected_forecast_scalar_data,.-md2asm_initialize_selected_forecast_scalar_data
.section .rodata
.p2align 3
.Lcapacities:.quad 51512,552,7584,4,112
.Lnamppvi:.ascii "NAMPPVI"
.bss
.p2align 3
.global md2asm_owned_forecast_scalar_data
.type md2asm_owned_forecast_scalar_data,%object
md2asm_owned_forecast_scalar_data:.skip 112
.size md2asm_owned_forecast_scalar_data,112

.global __coupling_MOD_cpl_nemo_lim
.type __coupling_MOD_cpl_nemo_lim,%object
.set __coupling_MOD_cpl_nemo_lim,md2asm_owned_forecast_scalar_data+0
.size __coupling_MOD_cpl_nemo_lim,4

.global __yoerdu_MOD_nimp
.type __yoerdu_MOD_nimp,%object
.set __yoerdu_MOD_nimp,md2asm_owned_forecast_scalar_data+4
.size __yoerdu_MOD_nimp,4

.global __yoerdu_MOD_nout
.type __yoerdu_MOD_nout,%object
.set __yoerdu_MOD_nout,md2asm_owned_forecast_scalar_data+8
.size __yoerdu_MOD_nout,4

.global __yomancs_MOD_rmdi
.type __yomancs_MOD_rmdi,%object
.set __yomancs_MOD_rmdi,md2asm_owned_forecast_scalar_data+16
.size __yomancs_MOD_rmdi,8

.global __yommp0_MOD_lsldebug
.type __yommp0_MOD_lsldebug,%object
.set __yommp0_MOD_lsldebug,md2asm_owned_forecast_scalar_data+24
.size __yommp0_MOD_lsldebug,4

.global __yommp0_MOD_lsplitout
.type __yommp0_MOD_lsplitout,%object
.set __yommp0_MOD_lsplitout,md2asm_owned_forecast_scalar_data+28
.size __yommp0_MOD_lsplitout,4

.global __yommp0_MOD_my_region_ew
.type __yommp0_MOD_my_region_ew,%object
.set __yommp0_MOD_my_region_ew,md2asm_owned_forecast_scalar_data+32
.size __yommp0_MOD_my_region_ew,4

.global __yomppvi_MOD_lnots_t
.type __yomppvi_MOD_lnots_t,%object
.set __yomppvi_MOD_lnots_t,md2asm_owned_forecast_scalar_data+36
.size __yomppvi_MOD_lnots_t,4

.global __yomppvi_MOD_lrppuv_callitpq
.type __yomppvi_MOD_lrppuv_callitpq,%object
.set __yomppvi_MOD_lrppuv_callitpq,md2asm_owned_forecast_scalar_data+40
.size __yomppvi_MOD_lrppuv_callitpq,4

.global __yomppvi_MOD_lrppuv_cstext
.type __yomppvi_MOD_lrppuv_cstext,%object
.set __yomppvi_MOD_lrppuv_cstext,md2asm_owned_forecast_scalar_data+44
.size __yomppvi_MOD_lrppuv_cstext,4

.global __yomtraj_MOD_ltrajsave
.type __yomtraj_MOD_ltrajsave,%object
.set __yomtraj_MOD_ltrajsave,md2asm_owned_forecast_scalar_data+48
.size __yomtraj_MOD_ltrajsave,4

.global __yomtraj_MOD_ltrajslag
.type __yomtraj_MOD_ltrajslag,%object
.set __yomtraj_MOD_ltrajslag,md2asm_owned_forecast_scalar_data+52
.size __yomtraj_MOD_ltrajslag,4

.global __yomtraj_oops_MOD_ltrajsave_oops
.type __yomtraj_oops_MOD_ltrajsave_oops,%object
.set __yomtraj_oops_MOD_ltrajsave_oops,md2asm_owned_forecast_scalar_data+56
.size __yomtraj_oops_MOD_ltrajsave_oops,4

.global __yomtraj_oops_MOD_ltrajslag_oops
.type __yomtraj_oops_MOD_ltrajslag_oops,%object
.set __yomtraj_oops_MOD_ltrajslag_oops,md2asm_owned_forecast_scalar_data+60
.size __yomtraj_oops_MOD_ltrajslag_oops,4

.global __yomvar_MOD_ltwgra
.type __yomvar_MOD_ltwgra,%object
.set __yomvar_MOD_ltwgra,md2asm_owned_forecast_scalar_data+64
.size __yomvar_MOD_ltwgra,4

.global __yomvar_MOD_ltwinc
.type __yomvar_MOD_ltwinc,%object
.set __yomvar_MOD_ltwinc,md2asm_owned_forecast_scalar_data+68
.size __yomvar_MOD_ltwinc,4

.global __yomvar_MOD_ltwbgv
.type __yomvar_MOD_ltwbgv,%object
.set __yomvar_MOD_ltwbgv,md2asm_owned_forecast_scalar_data+72
.size __yomvar_MOD_ltwbgv,4

.global __yomvar_MOD_ltwcgl
.type __yomvar_MOD_ltwcgl,%object
.set __yomvar_MOD_ltwcgl,md2asm_owned_forecast_scalar_data+76
.size __yomvar_MOD_ltwcgl,4

.global __yomct0_MOD_lsfcflx
.type __yomct0_MOD_lsfcflx,%object
.set __yomct0_MOD_lsfcflx,md2asm_owned_forecast_scalar_data+80
.size __yomct0_MOD_lsfcflx,4

.global __yomct0_MOD_rextlhf
.type __yomct0_MOD_rextlhf,%object
.set __yomct0_MOD_rextlhf,md2asm_owned_forecast_scalar_data+88
.size __yomct0_MOD_rextlhf,8

.global __yomct0_MOD_rextshf
.type __yomct0_MOD_rextshf,%object
.set __yomct0_MOD_rextshf,md2asm_owned_forecast_scalar_data+96
.size __yomct0_MOD_rextshf,8

.global __yomjfh_MOD_n_vmass
.type __yomjfh_MOD_n_vmass,%object
.set __yomjfh_MOD_n_vmass,md2asm_owned_forecast_scalar_data+104
.size __yomjfh_MOD_n_vmass,4

.section .note.GNU-stack,"",%progbits
