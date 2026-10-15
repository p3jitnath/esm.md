// Solver contract skills/md2asm/references/openifs/support/physics_perturbation_views.md.
// Contract: skills/md2asm/references/openifs/support/physics_perturbation_views.md. No floating-point calculation.
.arch armv8.2-a
.text
.p2align 4
.global md2asm_update_perturbation_views
.type md2asm_update_perturbation_views,%function
md2asm_update_perturbation_views:
 movz x10,#28280
 movk x10,#23,lsl #16
 add x10,x1,x10
 ldr w9,[x10]
 cbnz w9,.Lpert_unsupported
 movz x10,#45600
 movk x10,#23,lsl #16
 add x10,x1,x10
 ldr w9,[x10]
 cbnz w9,.Lpert_unsupported
 sub sp,sp,#192
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mrs x9,fpcr
 str x9,[sp,#104]
 mrs x9,fpsr
 str x9,[sp,#112]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 ldp w24,w25,[x22]
 ldp w26,w27,[x22,#8]
 ldr w28,[x22,#16]
 bl __errno_location
 str x0,[sp,#120]
 ldr w9,[x0]
 str w9,[sp,#128]
 movz x9,#0
 add x9,x21,x9
 ldr x9,[x9]
 cbz x9,.Lpert_no_ca_pattern
 movz x0,#0
 add x0,x19,x0
 movz x1,#0
 add x1,x21,x1
 mov w2,w25
 mov w3,w26
 bl .Lpert_slice1
.Lpert_no_ca_pattern:
 str xzr,[x19,#64]
 str xzr,[x19,#176]
 movz x9,#984
 add x9,x21,x9
 ldr x9,[x9]
 cbz x9,.Lpert_no_smooth
 movz x0,#552
 add x0,x19,x0
 movz x1,#1096
 add x1,x21,x1
 mov w2,w24
 mov w3,#0
 mov w4,#0
 bl .Lpert_slice2
.Lpert_no_smooth:
 movz x9,#1208
 add x9,x21,x9
 ldr x9,[x9]
 cbz x9,.Lpert_no_vorticity
 movz x0,#288
 add x0,x19,x0
 movz x1,#1208
 add x1,x21,x1
 mov w2,w24
 mov w3,#0
 mov w4,#0
 mov w3,#1
 mov w4,w28
 bl .Lpert_slice2
 movz x0,#376
 add x0,x19,x0
 movz x1,#1208
 add x1,x21,x1
 mov w2,w24
 mov w3,#0
 mov w4,#0
 mov w3,#1
 mov w4,w28
 add w3,w28,#1
 bl .Lpert_slice2
 movz x0,#464
 add x0,x19,x0
 movz x1,#1208
 add x1,x21,x1
 mov w2,w24
 mov w3,#0
 mov w4,#0
 mov w3,#1
 mov w4,w28
 lsl w3,w28,#1
 add w3,w3,#1
 bl .Lpert_slice2
.Lpert_no_vorticity:
 movz x10,#1700
 add x10,x21,x10
 ldr w9,[x10]
 cbz w9,.Lpert_no_forcing
 movz x0,#640
 add x0,x19,x0
 ldr x1,[x23,#0]
 mov w2,w24
 mov w3,#0
 mov w4,#0
 bl .Lpert_slice2
 movz x0,#728
 add x0,x19,x0
 ldr x1,[x23,#8]
 mov w2,w24
 mov w3,#0
 mov w4,#0
 bl .Lpert_slice2
 movz x0,#816
 add x0,x19,x0
 ldr x1,[x23,#16]
 mov w2,w24
 mov w3,#0
 mov w4,#0
 bl .Lpert_slice2
 movz x0,#904
 add x0,x19,x0
 ldr x1,[x23,#24]
 mov w2,w24
 mov w3,#0
 mov w4,#0
 bl .Lpert_slice2
.Lpert_no_forcing:
 movz x0,#992
 add x0,x19,x0
 movz x1,#12112
 movk x1,#24,lsl #16
 add x1,x20,x1
 mov w2,w25
 mov w3,w26
 bl .Lpert_slice1
 movz x0,#1056
 add x0,x19,x0
 movz x1,#12176
 movk x1,#24,lsl #16
 add x1,x20,x1
 mov w2,w25
 mov w3,w26
 bl .Lpert_slice1
 movz x10,#14760
 movk x10,#24,lsl #16
 add x10,x20,x10
 ldr w9,[x10]
 cbz w9,.Lpert_no_cape
 movz x0,#1120
 add x0,x19,x0
 movz x1,#12240
 movk x1,#24,lsl #16
 add x1,x20,x1
 mov w2,w25
 mov w3,w26
 bl .Lpert_slice1
.Lpert_no_cape:
 movz x9,#760
 add x9,x21,x9
 ldr x9,[x9]
 cbz x9,.Lpert_no_stream
 movz x0,#1184
 add x0,x19,x0
 movz x1,#760
 add x1,x21,x1
 mov w2,w24
 mov w3,#0
 mov w4,#0
 bl .Lpert_slice2
.Lpert_no_stream:
 movz x10,#2192
 add x10,x21,x10
 ldr w9,[x10]
 cbz w9,.Lpert_allocate_dummy
 movz x0,#1272
 add x0,x19,x0
 movz x1,#2584
 add x1,x21,x1
 mov w2,w24
 mov w3,#0
 mov w4,#0
 bl .Lpert_slice2
 b .Lpert_temperature_ready
.Lpert_allocate_dummy:
 mov x0,#8
 bl malloc
 cbz x0,.Lpert_allocation_failed
 mov x1,x0
 movz x0,#1272
 add x0,x19,x0
 bl .Lpert_dummy_descriptor
.Lpert_temperature_ready:
 movz x9,#984
 add x9,x21,x9
 ldr x9,[x9]
 cbz x9,.Lpert_view_success
 movz x0,#1360
 add x0,x19,x0
 movz x1,#984
 add x1,x21,x1
 mov w2,w24
 mov w3,#0
 mov w4,#0
 bl .Lpert_slice2
.Lpert_view_success:
 mov w0,#0
 b .Lpert_update_return
.Lpert_allocation_failed:
 mov w0,#1
.Lpert_update_return:
 ldr x9,[sp,#120]
 ldr w10,[sp,#128]
 str w10,[x9]
 ldr x9,[sp,#104]
 msr fpcr,x9
 ldr x9,[sp,#112]
 msr fpsr,x9
 ldr x18,[sp,#96]
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#192
 ret
.size md2asm_update_perturbation_views,.-md2asm_update_perturbation_views
.global md2asm_finalize_perturbation_views
.type md2asm_finalize_perturbation_views,%function
md2asm_finalize_perturbation_views:
 movz x10,#28280
 movk x10,#23,lsl #16
 add x10,x1,x10
 ldr w9,[x10]
 cbnz w9,.Lpert_unsupported
 movz x10,#45600
 movk x10,#23,lsl #16
 add x10,x1,x10
 ldr w9,[x10]
 cbnz w9,.Lpert_unsupported
 sub sp,sp,#192
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mrs x9,fpcr
 str x9,[sp,#104]
 mrs x9,fpsr
 str x9,[sp,#112]
 mov x19,x0
 mov x21,x2
 bl __errno_location
 str x0,[sp,#120]
 ldr w9,[x0]
 str w9,[sp,#128]
 movz x10,#2192
 add x10,x21,x10
 ldr w9,[x10]
 cbnz w9,.Lpert_final_success
 ldr x0,[x19,#1272]
 bl free
 str xzr,[x19,#1272]
.Lpert_final_success:
 mov w0,#0
 ldr x9,[sp,#120]
 ldr w10,[sp,#128]
 str w10,[x9]
 ldr x9,[sp,#104]
 msr fpcr,x9
 ldr x9,[sp,#112]
 msr fpsr,x9
 ldr x18,[sp,#96]
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#192
 ret
.size md2asm_finalize_perturbation_views,.-md2asm_finalize_perturbation_views
.Lpert_unsupported:
 mov w0,#2
 ret
.Lpert_slice1:
 ldp x9,x10,[x1]
 ldr x11,[x1,#40]
 sxtw x12,w2
 madd x10,x12,x11,x10
 add x9,x9,x10,lsl #3
 str x9,[x0]
 neg x10,x11
 str x10,[x0,#8]
 mov x9,#8
 str x9,[x0,#16]
 str xzr,[x0,#24]
 mov w10,#1
 strb w10,[x0,#28]
 mov w12,#3
 strb w12,[x0,#29]
 str x9,[x0,#32]
 stp x11,x10,[x0,#40]
 sxtw x12,w3
 str x12,[x0,#56]
 ret
.Lpert_slice2:
 ldp x9,x10,[x1]
 ldp x11,x12,[x1,#40]
 ldr x13,[x1,#56]
 sub x13,x13,x12
 add x13,x13,#1
 madd x10,x12,x11,x10
 ldp x14,x15,[x1,#64]
 ldr x16,[x1,#80]
 cbnz w3,.Lpert_explicit_levels
 sub x16,x16,x15
 add x16,x16,#1
 b .Lpert_slice_level_ready
.Lpert_explicit_levels:
 sxtw x15,w3
 sxtw x16,w4
.Lpert_slice_level_ready:
 madd x10,x15,x14,x10
 ldr x12,[x1,#88]
 sxtw x15,w2
 madd x10,x15,x12,x10
 add x9,x9,x10,lsl #3
 str x9,[x0]
 add x10,x11,x14
 neg x10,x10
 str x10,[x0,#8]
 mov x9,#8
 str x9,[x0,#16]
 str xzr,[x0,#24]
 mov w17,#2
 strb w17,[x0,#28]
 mov w17,#3
 strb w17,[x0,#29]
 str x9,[x0,#32]
 mov x17,#1
 stp x11,x17,[x0,#40]
 str x13,[x0,#56]
 stp x14,x17,[x0,#64]
 str x16,[x0,#80]
 ret
.Lpert_dummy_descriptor:
 str x1,[x0]
 mov x9,#-2
 str x9,[x0,#8]
 mov x9,#8
 str x9,[x0,#16]
 str xzr,[x0,#24]
 mov w10,#2
 strb w10,[x0,#28]
 mov w10,#3
 strb w10,[x0,#29]
 str x9,[x0,#32]
 mov x9,#1
 stp x9,x9,[x0,#40]
 str x9,[x0,#56]
 stp x9,x9,[x0,#64]
 str x9,[x0,#80]
 ret
.global __ecphys_perturb_type_mod_MOD_perturb_type_update_view
.type __ecphys_perturb_type_mod_MOD_perturb_type_update_view,%function
__ecphys_perturb_type_mod_MOD_perturb_type_update_view:
 adrp x9,md2asm_perturbation_view_native_counters
 add x9,x9,:lo12:md2asm_perturbation_view_native_counters
 ldr x10,[x9,#0]
 add x10,x10,#1
 str x10,[x9,#0]
 ldr x0,[x0]
 stp x29,x30,[sp,#-112]!
 mov x29,sp
 stp x18,x19,[sp,#16]
 ldr w9,[x3]
 str w9,[sp,#32]
 ldr w9,[x4]
 str w9,[sp,#36]
 ldr w9,[x5]
 str w9,[sp,#40]
 ldr w9,[x6]
 str w9,[sp,#44]
 ldr w9,[x7]
 str w9,[sp,#48]
 adrp x9,:got:__yomlcz_MOD_gpforceu
 ldr x9,[x9,:got_lo12:__yomlcz_MOD_gpforceu]
 str x9,[sp,#64]
 adrp x9,:got:__yomlcz_MOD_gpforcev
 ldr x9,[x9,:got_lo12:__yomlcz_MOD_gpforcev]
 str x9,[sp,#72]
 adrp x9,:got:__yomlcz_MOD_gpforcet
 ldr x9,[x9,:got_lo12:__yomlcz_MOD_gpforcet]
 str x9,[sp,#80]
 adrp x9,:got:__yomlcz_MOD_gpforceq
 ldr x9,[x9,:got_lo12:__yomlcz_MOD_gpforceq]
 str x9,[sp,#88]
 add x3,sp,#32
 add x4,sp,#64
 bl md2asm_update_perturbation_views
 cbnz w0,.Lpert_native_abort
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp],#112
 ret
.size __ecphys_perturb_type_mod_MOD_perturb_type_update_view,.-__ecphys_perturb_type_mod_MOD_perturb_type_update_view
.global __ecphys_perturb_type_mod_MOD_perturb_type_final
.type __ecphys_perturb_type_mod_MOD_perturb_type_final,%function
__ecphys_perturb_type_mod_MOD_perturb_type_final:
 adrp x9,md2asm_perturbation_view_native_counters
 add x9,x9,:lo12:md2asm_perturbation_view_native_counters
 ldr x10,[x9,#8]
 add x10,x10,#1
 str x10,[x9,#8]
 ldr x0,[x0]
 stp x29,x30,[sp,#-32]!
 stp x18,x19,[sp,#16]
 bl md2asm_finalize_perturbation_views
 cbnz w0,.Lpert_native_abort
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp],#32
 ret
.size __ecphys_perturb_type_mod_MOD_perturb_type_final,.-__ecphys_perturb_type_mod_MOD_perturb_type_final
.Lpert_native_abort:
 bl abort
.bss
.p2align 3
.global md2asm_perturbation_view_native_counters
.type md2asm_perturbation_view_native_counters,%object
md2asm_perturbation_view_native_counters:
 .zero 16
.size md2asm_perturbation_view_native_counters,16
.section .note.GNU-stack,"",%progbits
