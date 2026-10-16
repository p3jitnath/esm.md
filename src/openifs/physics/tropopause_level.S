/* Source build for the qualified private forecast graph.
 * Contract: skills/md2asm/references/openifs/dynamics/private_forecast_graph_sources.md.
 * Preserve the original interface, ordered arithmetic, and caller-owned storage. */
// Direct TROPLEV from tropopause_level_contract.md.
.text
.p2align 4
.macro ARG reg,index
 ldr \reg,[x19,#(\index*8)]
.endm
.macro FIELD reg,index,col
 ARG x9,\index
 madd x10,\col,x22,x20
 ldr \reg,[x9,x10,lsl #3]
.endm
.macro CALL name
 str x18,[sp,#344]
 bl \name
 ldr x18,[sp,#344]
.endm
.global md2asm_tropopause_level_7358525
.type md2asm_tropopause_level_7358525,%function
md2asm_tropopause_level_7358525:
 mov x16,sp
 sub sp,sp,#512
 stp x19,x20,[sp,#32]
 stp x21,x22,[sp,#48]
 stp x23,x24,[sp,#64]
 stp x25,x26,[sp,#80]
 stp x27,x28,[sp,#96]
 stp x29,x30,[sp,#112]
 stp d8,d9,[sp,#128]
 stp d10,d11,[sp,#144]
 stp d12,d13,[sp,#160]
 stp d14,d15,[sp,#176]
 str x18,[sp,#192]
 add x19,sp,#208
 stp x0,x1,[x19]
 stp x2,x3,[x19,#16]
 stp x4,x5,[x19,#32]
 stp x6,x7,[x19,#48]
 ldr x9,[x16]
 str x9,[x19,#64]
 mrs x9,fpcr
 cbnz x9,.Ltr_reject
 ARG x9,0
 ldr w22,[x9]
 cmp w22,#1
 b.lt .Ltr_reject
 cmp w22,#4096
 b.gt .Ltr_reject
 ARG x9,3
 ldr w28,[x9]
 cmp w28,#3
 b.lt .Ltr_reject
 cmp w28,#512
 b.gt .Ltr_reject
 ARG x9,1
 ldrsw x23,[x9]
 sub x23,x23,#1
 cmp x23,#0
 b.lt .Ltr_reject
 cmp x23,x22
 b.gt .Ltr_reject
 ARG x9,2
 ldrsw x24,[x9]
 cmp x24,x22
 b.gt .Ltr_reject
 cmp x24,#0
 b.lt .Ltr_reject
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Ltr_reject
 str w9,[sp,#320]
 cbz w9,.Ltr_entry_hook_done
 adr x0,.Ltr_hook_name
 add x1,sp,#324
 str wzr,[x1]
 add x2,sp,#328
 mov x3,#7
 CALL __yomhook_MOD_dr_hook_default8
.Ltr_entry_hook_done:

 ARG x9,4
 ldr w27,[x9]
 cmp w27,#1
 b.hi .Ltr_reject
 sub x26,x28,#2
 cmp x24,x23
 b.le .Ltr_calculation_done
 mov x20,x23
.Ltr_default_row:
 ARG x9,8
 str w26,[x9,x20,lsl #2]
 add x20,x20,#1
 cmp x20,x24
 b.lt .Ltr_default_row
 mov x21,#0
.Ltr_level:
 mov x20,x23
.Ltr_row:
 FIELD d0,7,x21
 adr x9,.Ltr_pressure_min
 ldr d1,[x9]
 fcmp d0,d1
 b.lt .Ltr_pressure_else
 adr x9,.Ltr_pressure_max
 ldr d1,[x9]
 fcmp d0,d1
 b.gt .Ltr_pressure_else
 cbnz w27,.Ltr_humidity
 // Thermal arithmetic is required even after an earlier selected level.
 add x25,x21,#1
 add x28,x21,#2
 FIELD d0,7,x25
 FIELD d1,5,x28
 FIELD d2,5,x21
 fsub d1,d1,d2
 fmul d0,d0,d1
 FIELD d1,5,x25
 FIELD d2,7,x28
 FIELD d3,7,x21
 fsub d2,d2,d3
 fmul d2,d1,d2
 fdiv d0,d0,d2
 adrp x9,:got:__yomcst_MOD_rd
 ldr x9,[x9,:got_lo12:__yomcst_MOD_rd]
 ldr d2,[x9]
 fmul d2,d2,d1
 adr x9,.Ltr_frequency_square
 ldr d3,[x9]
 fmul d2,d2,d3
 adrp x9,:got:__yomcst_MOD_rg
 ldr x9,[x9,:got_lo12:__yomcst_MOD_rg]
 ldr d3,[x9]
 fmul d3,d3,d3
 fdiv d2,d2,d3
 fadd d0,d0,d2
 ARG x9,8
 ldr w10,[x9,x20,lsl #2]
 cmp w10,w26
 b.ne .Ltr_next_row
 adrp x9,:got:__yomcst_MOD_rkappa
 ldr x9,[x9,:got_lo12:__yomcst_MOD_rkappa]
 ldr d1,[x9]
 fcmp d0,d1
 b.le .Ltr_next_row
 b .Ltr_select_level
.Ltr_humidity:
 ARG x9,8
 ldr w10,[x9,x20,lsl #2]
 cmp w10,w26
 b.ne .Ltr_next_row
 FIELD d0,6,x21
 adr x9,.Ltr_humidity_first
 ldr d1,[x9]
 fcmp d0,d1
 b.le .Ltr_next_row
 add x25,x21,#2
 FIELD d0,6,x25
 adr x9,.Ltr_humidity_below
 ldr d1,[x9]
 fcmp d0,d1
 b.le .Ltr_next_row
.Ltr_select_level:
 add w10,w21,#1
 ARG x9,8
 str w10,[x9,x20,lsl #2]
 b .Ltr_next_row
.Ltr_pressure_else:
 adr x9,.Ltr_pressure_max
 ldr d1,[x9]
 fcmp d0,d1
 b.le .Ltr_next_row
 ARG x9,8
 ldr w10,[x9,x20,lsl #2]
 cmp w10,w26
 b.ne .Ltr_next_row
 str w21,[x9,x20,lsl #2]
.Ltr_next_row:
 add x20,x20,#1
 cmp x20,x24
 b.lt .Ltr_row
 add x21,x21,#1
 cmp x21,x26
 b.lt .Ltr_level
.Ltr_calculation_done:
 ldr w9,[sp,#320]
 cbz w9,.Ltr_exit_hook_done
 adr x0,.Ltr_hook_name
 add x1,sp,#324
 mov w9,#1
 str w9,[x1]
 add x2,sp,#328
 mov x3,#7
 CALL __yomhook_MOD_dr_hook_default8
.Ltr_exit_hook_done:
 ldp x19,x20,[sp,#32]
 ldp x21,x22,[sp,#48]
 ldp x23,x24,[sp,#64]
 ldp x25,x26,[sp,#80]
 ldp x27,x28,[sp,#96]
 ldp x29,x30,[sp,#112]
 ldp d8,d9,[sp,#128]
 ldp d10,d11,[sp,#144]
 ldp d12,d13,[sp,#160]
 ldp d14,d15,[sp,#176]
 ldr x18,[sp,#192]
 add sp,sp,#512
 ret
.Ltr_reject:
 brk #0x538
.size md2asm_tropopause_level_7358525,.-md2asm_tropopause_level_7358525
.section .rodata
.Ltr_hook_name: .ascii "TROPLEV"
.p2align 3
.Ltr_pressure_min: .double 7000.0
.Ltr_pressure_max: .double 50000.0
.Ltr_frequency_square: .double 0.00025
.Ltr_humidity_first: .double 0.000003
.Ltr_humidity_below: .double 0.000005
.section .note.GNU-stack,"",%progbits

