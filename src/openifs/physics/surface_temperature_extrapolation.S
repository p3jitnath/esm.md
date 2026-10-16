/* Source build for the qualified private forecast graph.
 * Contract: skills/md2asm/references/openifs/dynamics/private_forecast_graph_sources.md.
 * Preserve the original interface, ordered arithmetic, and caller-owned storage. */
.text
.p2align 4
.macro LOAD_GLOBAL reg,symbol
 adrp x9,:got:\symbol
 ldr x9,[x9,:got_lo12:\symbol]
 ldr \reg,[x9]
.endm
.macro CALL symbol
 str x18,[sp,#192]
 bl \symbol
 ldr x18,[sp,#192]
.endm

.global md2asm_surface_temperature_extrapolation_7358525
.type md2asm_surface_temperature_extrapolation_7358525,%function
md2asm_surface_temperature_extrapolation_7358525:
 sub sp,sp,#256
 stp x0,x1,[sp,#0]
 stp x2,x3,[sp,#16]
 stp x4,x5,[sp,#32]
 stp x6,x7,[sp,#48]
 ldr x9,[sp,#256]
 str x9,[sp,#64]
 stp x19,x20,[sp,#96]
 stp x21,x22,[sp,#112]
 stp x23,x24,[sp,#128]
 stp x25,x26,[sp,#144]
 stp x27,x28,[sp,#160]
 stp x29,x30,[sp,#176]
 mrs x9,fpcr
 cbnz x9,.Lreject
 ldr x9,[sp]
 ldr w19,[x9]
 cmp w19,#1
 b.lt .Lreject
 cmp w19,#24
 b.gt .Lreject
 ldr x9,[sp,#8]
 ldr w20,[x9]
 cmp w20,#1
 b.lt .Lreject
 ldr x9,[sp,#16]
 ldr w21,[x9]
 cmp w21,w19
 b.gt .Lreject
 sub w9,w20,#1
 cmp w21,w9
 b.lt .Lreject
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 str w9,[sp,#204]
 cbz w9,.Lentry_hook_done
 adr x0,.Lhook_name
 str wzr,[sp,#200]
 add x1,sp,#200
 add x2,sp,#208
 mov x3,#6
 CALL __yomhook_MOD_dr_hook_default8
.Lentry_hook_done:
 sub w20,w20,#1

 LOAD_GLOBAL d16,__yomsta_MOD_rdtdz1
 fneg d16,d16
 LOAD_GLOBAL d17,__yomcst_MOD_rg
 fdiv d16,d16,d17
 LOAD_GLOBAL d17,__yomcst_MOD_rd
 fmul d17,d16,d17
 fmov d18,#1.0
 cmp w20,w21
 b.ge .Lct_done
.Lct_row:
 ldr x9,[sp,#32]
 ldr d0,[x9,x20,lsl #3]
 ldr x9,[sp,#40]
 ldr d1,[x9,x20,lsl #3]
 fdiv d0,d0,d1
 fsub d0,d0,d18
 fmul d0,d17,d0
 fadd d0,d18,d0
 ldr x9,[sp,#24]
 ldr d1,[x9,x20,lsl #3]
 fmul d0,d1,d0
 ldr x9,[sp,#56]
 str d0,[x9,x20,lsl #3]
 ldr x9,[sp,#48]
 ldr d1,[x9,x20,lsl #3]
 fmul d1,d16,d1
 fadd d0,d0,d1
 ldr x9,[sp,#64]
 str d0,[x9,x20,lsl #3]
 add w20,w20,#1
 cmp w20,w21
 b.lt .Lct_row
.Lct_done:
 ldr w9,[sp,#204]
 cbz w9,.Lexit_hook_done
 adr x0,.Lhook_name
 mov w9,#1
 str w9,[sp,#200]
 add x1,sp,#200
 add x2,sp,#208
 mov x3,#6
 CALL __yomhook_MOD_dr_hook_default8
.Lexit_hook_done:
 ldp x19,x20,[sp,#96]
 ldp x21,x22,[sp,#112]
 ldp x23,x24,[sp,#128]
 ldp x25,x26,[sp,#144]
 ldp x27,x28,[sp,#160]
 ldp x29,x30,[sp,#176]
 add sp,sp,#256
 ret
.Lreject:
 CALL abort
.size md2asm_surface_temperature_extrapolation_7358525,.-md2asm_surface_temperature_extrapolation_7358525
.section .rodata
.Lhook_name:
.ascii "CTSTAR"
.section .note.GNU-stack,"",%progbits
