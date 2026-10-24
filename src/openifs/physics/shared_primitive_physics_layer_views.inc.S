#ifndef CLDPRG_LAYER_SYMBOL
#define CLDPRG_LAYER_SYMBOL md2asm_cloud_radiation_layer_state_r2_7358525
#endif
#ifndef CLDPRG_CHILD_SYMBOL
#define CLDPRG_CHILD_SYMBOL md2asm_cldpp
#endif
/* Source build for the qualified private forecast graph.
 * Contract: skills/md2asm/references/openifs/dynamics/private_forecast_graph_sources.md.
 * Preserve the original interface, ordered arithmetic, and caller-owned storage. */
// Exact selected primitive layer interfaces. The retained qualified interface is unchanged.
.text
.p2align 4
.macro CALL target
 str x18,[sp,#1184]
 bl \target
 ldr x18,[sp,#1184]
.endm
.global CLDPRG_LAYER_SYMBOL
.type CLDPRG_LAYER_SYMBOL,%function
CLDPRG_LAYER_SYMBOL:
 mov x16,sp
 sub sp,sp,#2048
 stp x29,x30,[sp,#320]
 mov x29,sp
 stp x19,x20,[sp,#336]
 stp x21,x22,[sp,#352]
 stp x23,x24,[sp,#368]
 stp x25,x26,[sp,#384]
 stp x27,x28,[sp,#400]
 add x19,sp,#576
 str x0,[x19,#0]
 str x1,[x19,#8]
 str x2,[x19,#16]
 str x3,[x19,#24]
 str x4,[x19,#32]
 str x5,[x19,#40]
 str x6,[x19,#48]
 mrs x9,fpcr
 cbnz x9,.Llayer_reject
#ifdef CLDPRG_RUNTIME_ONLY
 bl .Lruntime_admit_cldprg
#endif
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 cbz w9,9f
 adr x0,.Lcldprg_layer_name
 adr x1,.Llayer_phase0
 add x2,sp,#1160
 mov x3,#12
 CALL __yomhook_MOD_dr_hook_default8
9:
 ldr x0,[x19,#8]
 movz x16,#36864
 movk x16,#62,lsl #16
 add x0,x0,x16
 str x0,[sp,#832]
 ldr x0,[x19,#8]
 movz x16,#35864
 movk x16,#24,lsl #16
 add x0,x0,x16
 str x0,[sp,#840]
 ldr x0,[x19,#8]
 movz x16,#21392
 movk x16,#28,lsl #16
 add x0,x0,x16
 str x0,[sp,#848]
 ldr x0,[x19,#8]
 movz x16,#5472
 movk x16,#24,lsl #16
 add x0,x0,x16
 str x0,[sp,#856]
 ldr x0,[x19,#8]
 movz x16,#48608
 movk x16,#20,lsl #16
 add x0,x0,x16
 str x0,[sp,#864]
 ldr x0,[x19,#16]
 str x0,[sp,#872]
 ldr x0,[x19,#16]
 mov x16,#4
 add x0,x0,x16
 str x0,[sp,#880]
 ldr x0,[x19,#16]
 mov x16,#12
 add x0,x0,x16
 str x0,[sp,#888]
 ldr x0,[x19,#16]
 mov x16,#48
 add x0,x0,x16
 str x0,[sp,#896]
 ldr x0,[x19,#24]
 mov x16,#624
 add x0,x0,x16
 mov x1,#0
 mov x2,#0
 bl .Llayer_first
 str x0,[sp,#904]
 ldr x0,[x19,#24]
 mov x16,#712
 add x0,x0,x16
 mov x1,#0
 mov x2,#0
 bl .Llayer_first
 str x0,[sp,#912]
 ldr x0,[x19,#32]
 mov x16,#472
 add x0,x0,x16
 mov x1,#0
 mov x2,#0
 bl .Llayer_first
 str x0,[sp,#920]
 ldr x0,[x19,#32]
 mov x16,#1000
 add x0,x0,x16
 mov x1,#0
 mov x2,#1
 bl .Llayer_first
 str x0,[sp,#928]
 ldr x0,[x19,#32]
 mov x16,#1000
 add x0,x0,x16
 mov x1,#0
 mov x2,#2
 bl .Llayer_first
 str x0,[sp,#936]
 ldr x0,[x19,#32]
 mov x16,#208
 add x0,x0,x16
 mov x1,#0
 mov x2,#0
 bl .Llayer_first
 str x0,[sp,#944]
 ldr x0,[x19,#24]
 mov x16,#1040
 add x0,x0,x16
 mov x1,#0
 mov x2,#0
 bl .Llayer_first
 str x0,[sp,#952]
 ldr x0,[x19,#24]
 mov x16,#976
 add x0,x0,x16
 mov x1,#0
 mov x2,#0
 bl .Llayer_first
 str x0,[sp,#960]
 mov w9,#1
 str w9,[sp,#1152]
 add x0,sp,#1152
 str x0,[sp,#968]
 ldr x9,[x19,#0]
 ldr x9,[x9,#12872]
 ldrsw x20,[x9,#0]
 ldr x0,[x19,#40]
 mov x16,#8992
 add x0,x0,x16
 mov x1,x20
 mov x2,#0
 bl .Llayer_first
 str x0,[sp,#976]
 ldr x9,[x19,#0]
 ldr x9,[x9,#12896]
 ldrsw x20,[x9,#0]
 ldr x0,[x19,#40]
 mov x16,#8992
 add x0,x0,x16
 mov x1,x20
 mov x2,#0
 bl .Llayer_first
 str x0,[sp,#984]
 ldr x9,[x19,#0]
 ldr x9,[x9,#12880]
 ldrsw x20,[x9,#0]
 ldr x0,[x19,#40]
 mov x16,#8992
 add x0,x0,x16
 mov x1,x20
 mov x2,#0
 bl .Llayer_first
 str x0,[sp,#992]
 ldr x9,[x19,#0]
 ldr x9,[x9,#12888]
 ldrsw x20,[x9,#0]
 ldr x0,[x19,#40]
 mov x16,#8992
 add x0,x0,x16
 mov x1,x20
 mov x2,#0
 bl .Llayer_first
 str x0,[sp,#1000]
 ldr x9,[x19,#0]
 ldr x9,[x9,#12760]
 ldrsw x20,[x9,#0]
 ldr x0,[x19,#40]
 mov x16,#8992
 add x0,x0,x16
 mov x1,x20
 mov x2,#0
 bl .Llayer_first
 str x0,[sp,#1008]
 ldr x0,[x19,#48]
 mov x1,#0
 mov x2,#0
 bl .Llayer_first
 str x0,[sp,#1016]
 ldr x0,[x19,#48]
 mov x16,#88
 add x0,x0,x16
 mov x1,#0
 mov x2,#0
 bl .Llayer_first
 str x0,[sp,#1024]
 ldr x0,[x19,#48]
 mov x16,#176
 add x0,x0,x16
 mov x1,#0
 mov x2,#0
 bl .Llayer_first
 str x0,[sp,#1032]
 ldr x9,[sp,#896]
 str x9,[sp,#0]
 ldr x9,[sp,#904]
 str x9,[sp,#8]
 ldr x9,[sp,#912]
 str x9,[sp,#16]
 ldr x9,[sp,#920]
 str x9,[sp,#24]
 ldr x9,[sp,#928]
 str x9,[sp,#32]
 ldr x9,[sp,#936]
 str x9,[sp,#40]
 ldr x9,[sp,#944]
 str x9,[sp,#48]
 ldr x9,[sp,#952]
 str x9,[sp,#56]
 ldr x9,[sp,#960]
 str x9,[sp,#64]
 ldr x9,[sp,#968]
 str x9,[sp,#72]
 ldr x9,[sp,#976]
 str x9,[sp,#80]
 ldr x9,[sp,#984]
 str x9,[sp,#88]
 ldr x9,[sp,#992]
 str x9,[sp,#96]
 ldr x9,[sp,#1000]
 str x9,[sp,#104]
 ldr x9,[sp,#1008]
 str x9,[sp,#112]
 ldr x9,[sp,#1016]
 str x9,[sp,#120]
 ldr x9,[sp,#1024]
 str x9,[sp,#128]
 ldr x9,[sp,#1032]
 str x9,[sp,#136]
 ldr x0,[sp,#832]
 ldr x1,[sp,#840]
 ldr x2,[sp,#848]
 ldr x3,[sp,#856]
 ldr x4,[sp,#864]
 ldr x5,[sp,#872]
 ldr x6,[sp,#880]
 ldr x7,[sp,#888]
 CALL CLDPRG_CHILD_SYMBOL
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 cbz w9,9f
 adr x0,.Lcldprg_layer_name
 adr x1,.Llayer_phase1
 add x2,sp,#1160
 mov x3,#12
 CALL __yomhook_MOD_dr_hook_default8
9:
 ldp x19,x20,[sp,#336]
 ldp x21,x22,[sp,#352]
 ldp x23,x24,[sp,#368]
 ldp x25,x26,[sp,#384]
 ldp x27,x28,[sp,#400]
 ldp x29,x30,[sp,#320]
 add sp,sp,#2048
 ret
.size CLDPRG_LAYER_SYMBOL,.-CLDPRG_LAYER_SYMBOL
#ifndef CLDPRG_RUNTIME_ONLY
.global md2asm_visibility_layer_state_r2_7358525
.type md2asm_visibility_layer_state_r2_7358525,%function
md2asm_visibility_layer_state_r2_7358525:
 mov x16,sp
 sub sp,sp,#2048
 stp x29,x30,[sp,#320]
 mov x29,sp
 stp x19,x20,[sp,#336]
 stp x21,x22,[sp,#352]
 stp x23,x24,[sp,#368]
 stp x25,x26,[sp,#384]
 stp x27,x28,[sp,#400]
 add x19,sp,#576
 str x0,[x19,#0]
 str x1,[x19,#8]
 str x2,[x19,#16]
 str x3,[x19,#24]
 str x4,[x19,#32]
 str x5,[x19,#40]
 str x6,[x19,#48]
 str x7,[x19,#56]
 ldr x9,[x16,#0]
 str x9,[x19,#64]
 mrs x9,fpcr
 cbnz x9,.Llayer_reject
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 cbz w9,9f
 adr x0,.Lradvis_layer_name
 adr x1,.Llayer_phase0
 add x2,sp,#1160
 mov x3,#12
 CALL __yomhook_MOD_dr_hook_default8
9:
 ldr x9,[x19,#16]
 ldr w9,[x9,#112]
 cbnz w9,.Llayer_reject
 ldr x21,[x19,#32]
 ldrsw x22,[x21]
 ldrsw x23,[x21,#4]
 cmp x22,x23
 b.gt .Lvis_copy_done
 ldr x0,[x19,#56]
 mov x16,#4504
 add x0,x0,x16
 mov x1,#0
 mov x2,#0
 bl .Llayer_first
 str x0,[sp,#832]
 ldr x0,[x19,#64]
 mov x16,#600
 add x0,x0,x16
 mov x1,#0
 mov x2,#0
 bl .Llayer_first
 str x0,[sp,#840]
 ldr x24,[sp,#832]
 ldr x25,[sp,#840]
 sub x22,x22,#1
.Lvis_copy_column:
 ldr x9,[x24,x22,lsl #3]
 str x9,[x25,x22,lsl #3]
 add x22,x22,#1
 cmp x22,x23
 b.lt .Lvis_copy_column
.Lvis_copy_done:
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 cbz w9,9f
 adr x0,.Lradvis_layer_name
 adr x1,.Llayer_phase1
 add x2,sp,#1160
 mov x3,#12
 CALL __yomhook_MOD_dr_hook_default8
9:
 ldp x19,x20,[sp,#336]
 ldp x21,x22,[sp,#352]
 ldp x23,x24,[sp,#368]
 ldp x25,x26,[sp,#384]
 ldp x27,x28,[sp,#400]
 ldp x29,x30,[sp,#320]
 add sp,sp,#2048
 ret
.size md2asm_visibility_layer_state_r2_7358525,.-md2asm_visibility_layer_state_r2_7358525
.global md2asm_uncoupled_ocean_fields_state_r2_7358525
.type md2asm_uncoupled_ocean_fields_state_r2_7358525,%function
md2asm_uncoupled_ocean_fields_state_r2_7358525:
 mov x16,sp
 sub sp,sp,#2048
 stp x29,x30,[sp,#320]
 mov x29,sp
 stp x19,x20,[sp,#336]
 stp x21,x22,[sp,#352]
 stp x23,x24,[sp,#368]
 stp x25,x26,[sp,#384]
 stp x27,x28,[sp,#400]
 add x19,sp,#576
 str x0,[x19,#0]
 str x1,[x19,#8]
 str x2,[x19,#16]
 str x3,[x19,#24]
 str x4,[x19,#32]
 str x5,[x19,#40]
 mrs x9,fpcr
 cbnz x9,.Llayer_reject
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 cbz w9,9f
 adr x0,.Lnemoaddflds_name
 adr x1,.Llayer_phase0
 add x2,sp,#1160
 mov x3,#11
 CALL __yomhook_MOD_dr_hook_default8
9:
 ldr x9,[x19,#0]
 ldr w9,[x9,#6796]
 cbnz w9,.Llayer_reject
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 cbz w9,9f
 adr x0,.Lnemoaddflds_name
 adr x1,.Llayer_phase1
 add x2,sp,#1160
 mov x3,#11
 CALL __yomhook_MOD_dr_hook_default8
9:
 ldp x19,x20,[sp,#336]
 ldp x21,x22,[sp,#352]
 ldp x23,x24,[sp,#368]
 ldp x25,x26,[sp,#384]
 ldp x27,x28,[sp,#400]
 ldp x29,x30,[sp,#320]
 add sp,sp,#2048
 ret
.size md2asm_uncoupled_ocean_fields_state_r2_7358525,.-md2asm_uncoupled_ocean_fields_state_r2_7358525
.global md2asm_surface_ocean_layer_state_r2_7358525
.type md2asm_surface_ocean_layer_state_r2_7358525,%function
md2asm_surface_ocean_layer_state_r2_7358525:
 mov x16,sp
 sub sp,sp,#2048
 stp x29,x30,[sp,#320]
 mov x29,sp
 stp x19,x20,[sp,#336]
 stp x21,x22,[sp,#352]
 stp x23,x24,[sp,#368]
 stp x25,x26,[sp,#384]
 stp x27,x28,[sp,#400]
 add x19,sp,#576
 str x0,[x19,#0]
 str x1,[x19,#8]
 str x2,[x19,#16]
 str x3,[x19,#24]
 str x4,[x19,#32]
 mrs x9,fpcr
 cbnz x9,.Llayer_reject
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 cbz w9,9f
 adr x0,.Lnemoaddflds_layer_name
 adr x1,.Llayer_phase0
 add x2,sp,#1160
 mov x3,#17
 CALL __yomhook_MOD_dr_hook_default8
9:
 ldr x0,[x19,#8]
 str x0,[sp,#832]
 ldr x0,[x19,#16]
 mov x16,#28
 add x0,x0,x16
 str x0,[sp,#840]
 ldr x0,[x19,#16]
 str x0,[sp,#848]
 ldr x0,[x19,#16]
 mov x16,#4
 add x0,x0,x16
 str x0,[sp,#856]
 ldr x9,[x19,#0]
 ldr x9,[x9,#9048]
 ldrsw x20,[x9,#0]
 ldr x0,[x19,#32]
 mov x16,#8728
 add x0,x0,x16
 mov x1,x20
 mov x2,#0
 bl .Llayer_first
 str x0,[sp,#864]
 ldr x0,[x19,#32]
 mov x16,#10592
 add x0,x0,x16
 mov x1,#1
 mov x2,#0
 bl .Llayer_first
 str x0,[sp,#872]
 ldr x9,[x19,#16]
 ldrsw x9,[x9]
 sub x9,x9,#1
 lsl x9,x9,#3
 ldr x0,[sp,#864]
 add x0,x0,x9
 str x0,[sp,#864]
 ldr x0,[sp,#872]
 add x0,x0,x9
 str x0,[sp,#872]
 ldr x0,[sp,#832]
 ldr x1,[sp,#840]
 ldr x2,[sp,#848]
 ldr x3,[sp,#856]
 ldr x4,[sp,#864]
 ldr x5,[sp,#872]
 CALL md2asm_uncoupled_ocean_fields_state_r2_7358525
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 cbz w9,9f
 adr x0,.Lnemoaddflds_layer_name
 adr x1,.Llayer_phase1
 add x2,sp,#1160
 mov x3,#17
 CALL __yomhook_MOD_dr_hook_default8
9:
 ldp x19,x20,[sp,#336]
 ldp x21,x22,[sp,#352]
 ldp x23,x24,[sp,#368]
 ldp x25,x26,[sp,#384]
 ldp x27,x28,[sp,#400]
 ldp x29,x30,[sp,#320]
 add sp,sp,#2048
 ret
.size md2asm_surface_ocean_layer_state_r2_7358525,.-md2asm_surface_ocean_layer_state_r2_7358525
#endif
#ifdef CLDPRG_RUNTIME_ONLY
.Lruntime_admit_cldprg:
 str x30,[sp,#1120]
 mov x22,#0
 adr x23,.Lruntime_record_bytes
.Lruntime_record_preflight:
 ldr x9,[x19,x22,lsl #3]
 cbz x9,.Llayer_reject
 tst x9,#7
 b.ne .Llayer_reject
 ldr x10,[x23,x22,lsl #3]
 adds x10,x9,x10
 b.cs .Llayer_reject
 add x22,x22,#1
 cmp x22,#7
 b.lo .Lruntime_record_preflight
 ldr x9,[x19,#16]
 ldr w20,[x9,#12]
 ldr w21,[x9,#48]
 cmp w20,#1
 b.lt .Llayer_reject
 cmp w20,#2048
 b.gt .Llayer_reject
 cmp w21,#3
 b.lt .Llayer_reject
 cmp w21,#512
 b.gt .Llayer_reject
 ldr w10,[x9]
 cmp w10,#1
 b.lt .Llayer_reject
 cmp w10,w20
 b.gt .Llayer_reject
 ldr w10,[x9,#4]
 cmp w10,#0
 b.lt .Llayer_reject
 cmp w10,w20
 b.gt .Llayer_reject
 adr x22,.Lruntime_descriptor_config
 add x24,sp,#1248
 mov x23,#11
.Lruntime_descriptor_loop:
 ldp x9,x10,[x22],#16
 ldp x1,x2,[x22],#16
 ldr x0,[x19,x9,lsl #3]
 add x0,x0,x10
 cmp x2,#-1
 b.eq .Lruntime_descriptor_expected
 add x2,x21,x2
.Lruntime_descriptor_expected:
 bl .Lruntime_check_dense_descriptor
 stp x0,x1,[x24],#16
 subs x23,x23,#1
 b.ne .Lruntime_descriptor_loop
 ldr x9,[x19,#40]
 mov x10,#9072
 ldr x25,[x9,x10]
 ldr x22,[x19]
 adr x23,.Lruntime_metadata_offsets
 add x24,sp,#1456
 mov x26,#0
.Lruntime_metadata_loop:
 ldr x10,[x23,x26,lsl #3]
 ldr x9,[x22,x10]
 cbz x9,.Llayer_reject
 tst x9,#3
 b.ne .Llayer_reject
 ldrsw x10,[x9]
 cmp x10,#1
 b.lt .Llayer_reject
 cmp x10,x25
 b.gt .Llayer_reject
 mov x11,#0
.Lruntime_metadata_unique:
 cmp x11,x26
 b.hs .Lruntime_metadata_store
 ldr x12,[x24,x11,lsl #3]
 cmp x10,x12
 b.eq .Llayer_reject
 add x11,x11,#1
 b .Lruntime_metadata_unique
.Lruntime_metadata_store:
 str x10,[x24,x26,lsl #3]
 add x26,x26,#1
 cmp x26,#5
 b.lo .Lruntime_metadata_loop
 add x22,sp,#1248
 mov x23,#7
.Lruntime_mutable_alias_outer:
 add x9,x22,x23,lsl #4
 ldp x10,x11,[x9]
 mov x24,#0
.Lruntime_array_alias_inner:
 cmp x24,x23
 b.eq .Lruntime_array_alias_next
 add x9,x22,x24,lsl #4
 ldp x12,x13,[x9]
 cmp x10,x13
 b.hs .Lruntime_array_alias_next
 cmp x12,x11
 b.lo .Llayer_reject
.Lruntime_array_alias_next:
 add x24,x24,#1
 cmp x24,#11
 b.lo .Lruntime_array_alias_inner
 mov x24,#0
 adr x25,.Lruntime_record_bytes
.Lruntime_record_alias_inner:
 ldr x12,[x19,x24,lsl #3]
 ldr x13,[x25,x24,lsl #3]
 add x13,x12,x13
 cmp x10,x13
 b.hs .Lruntime_record_alias_next
 cmp x12,x11
 b.lo .Llayer_reject
.Lruntime_record_alias_next:
 add x24,x24,#1
 cmp x24,#7
 b.lo .Lruntime_record_alias_inner
 add x23,x23,#1
 cmp x23,#11
 b.lo .Lruntime_mutable_alias_outer
 ldr x30,[sp,#1120]
 ret

// Check the complete dense owner before the unmodified address unroll.
.Lruntime_check_dense_descriptor:
 ldrb w9,[x0,#28]
 cmp w9,w1
 b.ne .Llayer_reject
 ldrb w9,[x0,#29]
 cmp w9,#3
 b.ne .Llayer_reject
 ldr x9,[x0,#16]
 cmp x9,#8
 b.ne .Llayer_reject
 ldr x9,[x0,#32]
 cmp x9,#8
 b.ne .Llayer_reject
 ldr x9,[x0,#40]
 cmp x9,#1
 b.ne .Llayer_reject
 ldr x9,[x0,#48]
 cmp x9,#1
 b.ne .Llayer_reject
 ldr x9,[x0,#56]
 cmp x9,x20
 b.ne .Llayer_reject
 mov x13,x20
 mov x14,#1
 cmp x1,#1
 b.eq .Lruntime_descriptor_finish
 ldr x9,[x0,#64]
 cmp x9,x20
 b.ne .Llayer_reject
 ldr x9,[x0,#72]
 cmp x9,#1
 b.ne .Llayer_reject
 ldr x12,[x0,#80]
 cmp x12,#1
 b.lt .Llayer_reject
 cmp x2,#-1
 b.eq .Lruntime_descriptor_free_fields
 cmp x12,x2
 b.ne .Llayer_reject
 b .Lruntime_descriptor_second_ok
.Lruntime_descriptor_free_fields:
 cmp x12,#4096
 b.gt .Llayer_reject
.Lruntime_descriptor_second_ok:
 add x14,x14,x20
 mul x13,x13,x12
 cmp x1,#2
 b.eq .Lruntime_descriptor_finish
 ldr x9,[x0,#88]
 cmp x9,x13
 b.ne .Llayer_reject
 ldr x9,[x0,#96]
 cmp x9,#1
 b.ne .Llayer_reject
 ldr x12,[x0,#104]
 cmp x12,#2
 b.lt .Llayer_reject
 cmp x12,#4096
 b.gt .Llayer_reject
 add x14,x14,x13
 mul x13,x13,x12
.Lruntime_descriptor_finish:
 mov x15,#0x4000000
 cmp x13,x15
 b.hi .Llayer_reject
 neg x14,x14
 ldr x9,[x0,#8]
 cmp x9,x14
 b.ne .Llayer_reject
 ldr x0,[x0]
 cbz x0,.Llayer_reject
 tst x0,#7
 b.ne .Llayer_reject
 adds x1,x0,x13,lsl #3
 b.cs .Llayer_reject
 ret
#endif
// First element of a GNU dense view, with optional second/third source subscript.
.Llayer_first:
ldr x8,[x0]
cbz x8,.Llayer_reject
ldr x9,[x0,#8]
ldrb w10,[x0,#28]
ldr x11,[x0,#40]
ldr x12,[x0,#48]
madd x9,x11,x12,x9
cmp w10,#1
b.eq .Llayer_first_done
ldr x11,[x0,#64]
ldr x12,[x0,#72]
cmp x1,#0
csel x12,x12,x1,eq
madd x9,x11,x12,x9
cmp w10,#2
b.eq .Llayer_first_done
ldr x11,[x0,#88]
ldr x12,[x0,#96]
cmp x2,#0
csel x12,x12,x2,eq
madd x9,x11,x12,x9
.Llayer_first_done:
ldr x11,[x0,#32]
madd x0,x9,x11,x8
ret
.Llayer_reject:
CALL abort
brk #0
.section .rodata
.p2align 2
.Llayer_phase0: .word 0
.Llayer_phase1: .word 1
.Lcldprg_layer_name: .ascii "CLDPRG_LAYER"
.Lradvis_layer_name: .ascii "RADVIS_LAYER"
.Lnemoaddflds_name: .ascii "NEMOADDFLDS"
.Lnemoaddflds_layer_name: .ascii "NEMOADDFLDS_LAYER"
#ifdef CLDPRG_RUNTIME_ONLY
.p2align 3
.Lruntime_record_bytes:
 .quad 18224,4275088,192,1992,1240,13680,2664
.Lruntime_descriptor_config:
 .quad 3,624,2,1
 .quad 3,712,2,0
 .quad 4,472,2,0
 .quad 4,1000,3,0
 .quad 4,208,2,0
 .quad 3,1040,1,0
 .quad 3,976,1,0
 .quad 5,8992,2,-1
 .quad 6,0,2,0
 .quad 6,88,2,0
 .quad 6,176,2,0
.Lruntime_metadata_offsets:
 .quad 12872,12896,12880,12888,12760
#endif
.section .note.GNU-stack,"",%progbits
