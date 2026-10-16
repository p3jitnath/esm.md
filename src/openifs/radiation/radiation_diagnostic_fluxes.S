/* Source build for the qualified private forecast graph.
 * Contract: skills/md2asm/references/openifs/dynamics/private_forecast_graph_sources.md.
 * Preserve the original interface, ordered arithmetic, and caller-owned storage. */
/* Selected RADDIAG flux reconstruction, with printed diagnostics disabled.
 * The retained joint qualification is reused.
 */
.text
.p2align 4
.macro diagnostic_integer reg,value
 movz \reg,#(\value & 65535)
 movk \reg,#((\value >> 16)&65535),lsl #16
.endm
.macro diagnostic_call symbol
 str x18,[x29,#216]
 bl \symbol
 ldr x18,[x29,#216]
.endm
.macro diagnostic_hook phase
 adrp x8,:got:__yomhook_MOD_lhook
 ldr x8,[x8,:got_lo12:__yomhook_MOD_lhook]
 ldr w8,[x8]
 cbz w8,990f
 adr x0,.Ldiagnostic_hook_name
 add x1,x29,#228
 mov w8,#\phase
 str w8,[x1]
 add x2,x29,#208
 mov x3,#7
 diagnostic_call __yomhook_MOD_dr_hook_default8
990:
.endm
.global md2asm_radiation_diagnostic_fluxes
.type md2asm_radiation_diagnostic_fluxes,%function
md2asm_radiation_diagnostic_fluxes:
 mov x9,sp
 sub sp,sp,#1024
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 add x19,sp,#256
 stp x0,x1,[x19]
 stp x2,x3,[x19,#16]
 stp x4,x5,[x19,#32]
 stp x6,x7,[x19,#48]
 mov x10,#0
.Ldiagnostic_save_arguments:
 ldr x11,[x9,x10]
 add x12,x19,#64
 str x11,[x12,x10]
 add x10,x10,#8
 cmp x10,#208
 b.ne .Ldiagnostic_save_arguments
 ldr x20,[x19]
 ldr x25,[x19,#8]
 ldr x9,[x19,#48]
 ldr w21,[x9]
 cmp w21,#1
 b.lt .Ldiagnostic_reject
 cmp w21,#2048
 b.gt .Ldiagnostic_reject
 ldr x9,[x19,#56]
 ldr w28,[x9]
 cmp w28,#19
 b.ne .Ldiagnostic_reject
 ldr w9,[x25,#2256]
 cbnz w9,.Ldiagnostic_reject
 /* The actual coarse region is one longitude region. */
 adrp x9,:got:__yommp0_MOD_my_region_ew
 ldr x9,[x9,:got_lo12:__yommp0_MOD_my_region_ew]
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Ldiagnostic_reject
 ldr x9,[x19,#32]
 ldr w22,[x9]
 ldr x9,[x19,#40]
 ldr w24,[x9]
 str w22,[x29,#232]
 str w24,[x29,#236]
 cmp w22,w24
 b.gt .Ldiagnostic_guard_complete
 cmp w22,#1
 b.lt .Ldiagnostic_reject
 cmp w24,#32
 b.gt .Ldiagnostic_reject
 /* Original integer descriptors have lower bounds 1 and -1. */
 diagnostic_integer x9,7896
 add x10,x20,x9
 adr x11,.Ldiagnostic_nstagp_tail
 mov x12,#8
.Ldiagnostic_nstagp_words:
 ldr x13,[x10,x12]
 sub x14,x12,#8
 ldr x14,[x11,x14]
 cmp x13,x14
 b.ne .Ldiagnostic_reject
 add x12,x12,#8
 cmp x12,#64
 b.ne .Ldiagnostic_nstagp_words
 ldr x10,[x10]
 cbz x10,.Ldiagnostic_reject
 diagnostic_integer x9,6176
 add x11,x20,x9
 adr x12,.Ldiagnostic_nonl_tail
 mov x13,#8
.Ldiagnostic_nonl_words:
 ldr x14,[x11,x13]
 sub x15,x13,#8
 ldr x15,[x12,x15]
 cmp x14,x15
 b.ne .Ldiagnostic_reject
 add x13,x13,#8
 cmp x13,#88
 b.ne .Ldiagnostic_nonl_words
 ldr x11,[x11]
 cbz x11,.Ldiagnostic_reject
 diagnostic_integer x9,7244
 ldr w12,[x20,x9]
 cbnz w12,.Ldiagnostic_reject
.Ldiagnostic_guard_row:
 sub w9,w22,#1
 ldr w13,[x10,w9,uxtw #2]
 cbz w13,.Ldiagnostic_guard_row_next
 cmp w13,#1
 b.lt .Ldiagnostic_reject
 add w9,w22,#1
 ldr w14,[x11,w9,uxtw #2]
 cmp w14,#1
 b.lt .Ldiagnostic_reject
 add w15,w13,w14
 sub w15,w15,#1
 cmp w15,w21
 b.gt .Ldiagnostic_reject
.Ldiagnostic_guard_row_next:
 add w22,w22,#1
 cmp w22,w24
 b.le .Ldiagnostic_guard_row
.Ldiagnostic_guard_complete:
 mrs x9,fpcr
 cbnz x9,.Ldiagnostic_reject
 diagnostic_integer x9,249912
 ldr d0,[x25,x9]
 fcmp d0,#0.0
 b.le .Ldiagnostic_reject
 fcmp d0,d0
 b.vs .Ldiagnostic_reject
 diagnostic_hook 0
 mov x0,#1
 lsl x1,x21,#3
 diagnostic_call calloc
 cbz x0,.Ldiagnostic_reject
 mov x26,x0
 /* Source computes the curvature coefficient before the row loop. */
 diagnostic_integer x9,249912
 ldr d0,[x25,x9]
 fmov d1,#2.0
 fadd d1,d0,d1
 fmul d1,d0,d1
 str d0,[x29,#112]
 str d1,[x29,#120]
 ldr x27,[x19,#24]
 add x27,x27,#616
 ldr w22,[x29,#232]
 ldr w24,[x29,#236]
 cmp w22,w24
 b.gt .Ldiagnostic_finish
.Ldiagnostic_row:
 diagnostic_integer x9,7896
 ldr x10,[x20,x9]
 sub w9,w22,#1
 ldr w23,[x10,w9,uxtw #2]
 cbz w23,.Ldiagnostic_next_row
 diagnostic_integer x9,6176
 ldr x10,[x20,x9]
 add w9,w22,#1
 ldr w9,[x10,w9,uxtw #2]
 add w24,w23,w9
 sub w24,w24,#1
 sub w23,w23,#1
 str w23,[x29,#128]
 str w24,[x29,#132]
 /* Convert the inclusive source row to zero-based storage. */
 ldr x10,[x19,#168]
.Ldiagnostic_solar_cell:
 ldr d0,[x10,x23,lsl #3]
 adr x9,.Ldiagnostic_cosine_threshold
 ldr d1,[x9]
 fcmp d0,d1
 b.lt .Ldiagnostic_night
 ldr d1,[x29,#120]
 fmul d2,d0,d0
 fadd d2,d2,d1
 fsqrt d2,d2
 fsub d2,d2,d0
 ldr d3,[x29,#112]
 fdiv d3,d3,d2
 b .Ldiagnostic_solar_store
.Ldiagnostic_night:
 fmov d3,xzr
.Ldiagnostic_solar_store:
 str d3,[x26,x23,lsl #3]
 add x23,x23,#1
 cmp w23,w24
 b.lt .Ldiagnostic_solar_cell
 mov x9,#0
.Ldiagnostic_level:
 mul x10,x9,x21
 lsl x10,x10,#3
 ldr w23,[x29,#128]
 ldr w24,[x29,#132]
.Ldiagnostic_flux_cell:
 add x11,x10,x23,lsl #3
 ldr x12,[x19,#200]
 ldr d0,[x12,x11]
 ldr x12,[x19,#224]
 str d0,[x12,x11]
 ldr d0,[x26,x23,lsl #3]
 ldr d1,[x27]
 fmul d0,d0,d1
 ldr x12,[x19,#208]
 ldr d1,[x12,x11]
 fmul d0,d0,d1
 ldr x12,[x19,#240]
 str d0,[x12,x11]
 add x23,x23,#1
 cmp w23,w24
 b.lt .Ldiagnostic_flux_cell
 add x9,x9,#1
 cmp x9,#20
 b.ne .Ldiagnostic_level
 ldr w23,[x29,#128]
 ldr w24,[x29,#132]
.Ldiagnostic_clear_cell:
 ldr d0,[x26,x23,lsl #3]
 ldr d1,[x27]
 fmul d0,d0,d1
 ldr x12,[x19,#256]
 ldr d1,[x12,x23,lsl #3]
 fmul d2,d0,d1
 ldr x12,[x19,#232]
 str d2,[x12,x23,lsl #3]
 mov x9,#19
 mul x9,x9,x21
 add x9,x9,x23
 ldr x12,[x19,#256]
 ldr d1,[x12,x9,lsl #3]
 fmul d0,d0,d1
 ldr x12,[x19,#232]
 add x10,x21,x23
 str d0,[x12,x10,lsl #3]
 ldr x12,[x19,#264]
 ldr d0,[x12,x23,lsl #3]
 ldr d1,[x12,x9,lsl #3]
 ldr x12,[x19,#216]
 str d0,[x12,x23,lsl #3]
 str d1,[x12,x10,lsl #3]
 add x23,x23,#1
 cmp w23,w24
 b.lt .Ldiagnostic_clear_cell
.Ldiagnostic_next_row:
 add w22,w22,#1
 ldr w24,[x29,#236]
 cmp w22,w24
 b.le .Ldiagnostic_row
.Ldiagnostic_finish:
 mov x0,x26
 diagnostic_call free
 diagnostic_hook 1
 adrp x9,.Ldiagnostic_calls
 add x9,x9,:lo12:.Ldiagnostic_calls
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ldr x18,[sp,#96]
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#1024
 ret
.Ldiagnostic_reject:
 bl abort
 brk #0
.size md2asm_radiation_diagnostic_fluxes,.-md2asm_radiation_diagnostic_fluxes
.global md2asm_radiation_diagnostic_count_get
.type md2asm_radiation_diagnostic_count_get,%function
md2asm_radiation_diagnostic_count_get:
 adrp x0,.Ldiagnostic_calls
 ldr x0,[x0,:lo12:.Ldiagnostic_calls]
 ret
.size md2asm_radiation_diagnostic_count_get,.-md2asm_radiation_diagnostic_count_get
.section .rodata
.p2align 3
.Ldiagnostic_nstagp_tail:
 .quad -1,4,0x0000010100000000,4,1,1,32
.Ldiagnostic_nonl_tail:
 .quad -35,4,0x0000010200000000,4,1,-1,34,36,1,1
.Ldiagnostic_cosine_threshold: .double 1.0e-10
.Ldiagnostic_hook_name: .ascii "RADDIAG"
.bss
.p2align 3
.Ldiagnostic_calls: .zero 8
.section .note.GNU-stack,"",%progbits
