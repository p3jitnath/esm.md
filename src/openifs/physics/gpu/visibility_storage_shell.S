// Contract: skills/md2asm-gpu/references/openifs/physics/cloud_aerosol_visibility.md.
/* Source build for the qualified private forecast graph.
 * Contract: skills/md2asm/references/openifs/dynamics/private_forecast_graph_sources.md.
 * Preserve the original interface, ordered arithmetic, and caller-owned storage. */
// Direct FP64 visibility equations. Source CLAERVIS. The retained qualified implementation is unchanged.
.text
.p2align 4
.macro CALL target
 stp x18,x30,[sp,#-16]!
 bl \target
 ldp x18,x30,[sp],#16
.endm
.global md2asm_cloud_aerosol_visibility_7358525
.type md2asm_cloud_aerosol_visibility_7358525,%function
md2asm_cloud_aerosol_visibility_7358525:
 mov x10,sp
 sub sp,sp,#768
 stp x29,x30,[sp,#128]
 mov x29,sp
 stp x19,x20,[sp,#144]
 stp x21,x22,[sp,#160]
 stp x23,x24,[sp,#176]
 stp x25,x26,[sp,#192]
 stp x27,x28,[sp,#208]
 stp d8,d9,[sp,#224]
 stp d10,d11,[sp,#240]
 stp d12,d13,[sp,#256]
 stp d14,d15,[sp,#272]
 add x19,sp,#320
 str x0,[x19,#0]
 str x1,[x19,#8]
 str x2,[x19,#16]
 str x3,[x19,#24]
 str x4,[x19,#32]
 str x5,[x19,#40]
 str x6,[x19,#48]
 str x7,[x19,#56]
 ldr x9,[x10,#0]
 str x9,[x19,#64]
 ldr x9,[x10,#8]
 str x9,[x19,#72]
 ldr x9,[x10,#16]
 str x9,[x19,#80]
 ldr x9,[x10,#24]
 str x9,[x19,#88]
 ldr x9,[x10,#32]
 str x9,[x19,#96]
 ldr x9,[x19,#0]
 ldr w20,[x9]
 ldr x9,[x19,#8]
 ldr w21,[x9]
 ldr x9,[x19,#16]
 ldr w22,[x9]
 ldr x9,[x19,#24]
 ldr w23,[x9]
 cmp w20,#1
 b.lt .Lcv_reject
 cmp w22,#24
 b.hi .Lcv_reject
 cmp w23,#1
 b.lt .Lcv_reject
 cmp w23,#19
 b.hi .Lcv_reject
 cmp w21,w22
 b.gt .Lcv_reject
 sub w20,w20,#1
 sub w23,w23,#1
 umull x23,w23,w22
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w25,[x9]
 cbz w25,.Lcv_hook0_done
 adr x0,.Lcv_hook_name
 adr x1,.Lcv_hook_phase0
 add x2,sp,#536
 mov x3,#8
 CALL __yomhook_MOD_dr_hook_default8
.Lcv_hook0_done:
 mov x0,x19
 CALL md2asm_gpu_visibility_stage
.Lcv_done:
 cbz w25,.Lcv_hook1_done
 adr x0,.Lcv_hook_name
 adr x1,.Lcv_hook_phase1
 add x2,sp,#536
 mov x3,#8
 CALL __yomhook_MOD_dr_hook_default8
.Lcv_hook1_done:
 ldp d8,d9,[sp,#224]
 ldp d10,d11,[sp,#240]
 ldp d12,d13,[sp,#256]
 ldp d14,d15,[sp,#272]
 ldp x19,x20,[sp,#144]
 ldp x21,x22,[sp,#160]
 ldp x23,x24,[sp,#176]
 ldp x25,x26,[sp,#192]
 ldp x27,x28,[sp,#208]
 ldp x29,x30,[sp,#128]
 add sp,sp,#768
 ret
.Lcv_reject:
 CALL abort
 brk #0
.size md2asm_cloud_aerosol_visibility_7358525,.-md2asm_cloud_aerosol_visibility_7358525
.section .rodata
.p2align 3
.Lcv_hook_name: .ascii "CLAERVIS"
.p2align 2
.Lcv_hook_phase0: .word 0
.Lcv_hook_phase1: .word 1
.p2align 3
.Lcv_c0: .quad 0x400f4bd2b6f19935 // 3.912023
.Lcv_c1: .quad 0x40f86a0000000000 // 100000.0
.Lcv_c2: .quad 0x408f500000000000 // 1002.0
.Lcv_c3: .quad 0x408f400000000000 // 1000.0
.Lcv_c4: .quad 0x4049000000000000 // 50.0
.Lcv_c5: .quad 0x3fe4b6ae7d566cf4 // 0.6473
.Lcv_c6: .quad 0x3fc4faacd9e83e42 // 0.1639
.Lcv_c7: .quad 0x3fe8f5c28f5c28f6 // 0.78
.Lcv_c8: .quad 0x3f70624dd2f1a9fc // 0.004
.Lcv_c9: .quad 0x3fe8000000000000 // 0.75
.Lcv_c10: .quad 0x3f747ae147ae147b // 0.005
.section .note.GNU-stack,"",%progbits
