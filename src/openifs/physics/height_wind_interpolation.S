/* Source build for the qualified private forecast graph.
 * Contract: skills/md2asm/references/openifs/physics/runtime_height_wind_interpolation.md.
 * Preserve the original interface, ordered arithmetic, and caller-owned storage. */
// Direct VDFVINT from height_wind_interpolation_contract.md.
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
.global md2asm_height_wind_interpolation_7358525
.type md2asm_height_wind_interpolation_7358525,%function
md2asm_height_wind_interpolation_7358525:
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
 ldp x9,x10,[x16]
 stp x9,x10,[x19,#64]
 mrs x9,fpcr
 cbnz x9,.Lhv_reject
 ARG x9,2
 ldr w22,[x9]
 cmp w22,#1
 b.lt .Lhv_reject
 cmp w22,#4096
 b.gt .Lhv_reject
 ARG x9,3
 ldr w28,[x9]
 cmp w28,#2
 b.lt .Lhv_reject
 cmp w28,#512
 b.gt .Lhv_reject
 ARG x9,0
 ldrsw x23,[x9]
 sub x23,x23,#1
 cmp x23,#0
 b.lt .Lhv_reject
 cmp x23,x22
 b.gt .Lhv_reject
 ARG x9,1
 ldrsw x24,[x9]
 cmp x24,x22
 b.gt .Lhv_reject
 cmp x24,#0
 b.lt .Lhv_reject
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lhv_reject
 str w9,[sp,#320]
 cbz w9,.Lhv_entry_hook_done
 adr x0,.Lhv_hook_name
 add x1,sp,#324
 str wzr,[x1]
 add x2,sp,#328
 mov x3,#7
 CALL __yomhook_MOD_dr_hook_default8
.Lhv_entry_hook_done:
 // Preserve the setup arithmetic even for an empty requested interval.
 adrp x9,:got:__yomcst_MOD_rg
 ldr x9,[x9,:got_lo12:__yomcst_MOD_rg]
 ldr d0,[x9]
 adrp x9,:got:__yomdyncore_MOD_rplrg
 ldr x9,[x9,:got_lo12:__yomdyncore_MOD_rplrg]
 ldr d1,[x9]
 fdiv d0,d0,d1
 ARG x9,7
 ldr d1,[x9]
 fmul d7,d1,d0
 cmp x24,x23
 b.le .Lhv_calculation_done
 mov x20,x23
.Lhv_row:
 sub x21,x28,#1
.Lhv_level:
 sub x25,x21,#1
 FIELD d1,6,x25
 fcmp d7,d1
 b.vs .Lhv_next_level
 b.ge .Lhv_next_level
 FIELD d2,6,x21
 fcmp d7,d2
 b.lt .Lhv_next_level
 fsub d3,d7,d2
 fsub d4,d1,d7
 fsub d5,d1,d2
 FIELD d0,4,x25
 fmul d0,d0,d3
 FIELD d6,4,x21
 fmul d6,d6,d4
 fadd d0,d0,d6
 fdiv d0,d0,d5
 ARG x9,8
 str d0,[x9,x20,lsl #3]
 FIELD d0,5,x25
 fmul d0,d0,d3
 FIELD d6,5,x21
 fmul d6,d6,d4
 fadd d0,d0,d6
 fdiv d0,d0,d5
 ARG x9,9
 str d0,[x9,x20,lsl #3]
 b .Lhv_next_row
.Lhv_next_level:
 sub x21,x21,#1
 cbnz x21,.Lhv_level
.Lhv_next_row:
 add x20,x20,#1
 cmp x20,x24
 b.lt .Lhv_row
.Lhv_calculation_done:
 ldr w9,[sp,#320]
 cbz w9,.Lhv_exit_hook_done
 adr x0,.Lhv_hook_name
 add x1,sp,#324
 mov w9,#1
 str w9,[x1]
 add x2,sp,#328
 mov x3,#7
 CALL __yomhook_MOD_dr_hook_default8
.Lhv_exit_hook_done:
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
.Lhv_reject:
 brk #0x537
.size md2asm_height_wind_interpolation_7358525,.-md2asm_height_wind_interpolation_7358525
.section .rodata
.Lhv_hook_name: .ascii "VDFVINT"
.section .note.GNU-stack,"",%progbits
