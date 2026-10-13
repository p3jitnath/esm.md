// Original routine TRSTOM. Direct AArch64 assembly.
// Physics formulations/openifs/dynamics/spectral_calculation_driver.md.
// Contract skills/md2asm/references/openifs/dynamics/spectral_calculation_driver.md.
// Supported 19-level, 506-coefficient route on one process.
// Full allocated buffers and source metadata follow the frozen contract.
.text
.p2align 4
.macro ARG reg,index
 ldr \reg,[x19,#(8*\index)]
.endm
.macro CALL symbol
 str x18,[sp,#488]
 bl \symbol
 ldr x18,[sp,#488]
.endm
.global md2asm_spectral_column_to_level_7358525
.type md2asm_spectral_column_to_level_7358525,%function
md2asm_spectral_column_to_level_7358525:
 mov x16,sp
 sub sp,sp,#512
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 stp x29,x30,[sp,#96]
 str x18,[sp,#480]
 add x19,sp,#128
 stp x0,x1,[x19]
 stp x2,x3,[x19,#16]
 stp x4,x5,[x19,#32]
 stp x6,x7,[x19,#48]
 mov x10,#8
.Ltrstom_arguments:
 ldr x9,[x16],#8
 str x9,[x19,x10,lsl #3]
 add x10,x10,#1
 cmp x10,#29
 b.lt .Ltrstom_arguments
 mrs x9,fpcr
 cbnz x9,.Ltrstom_reject
 ARG x9,0
 ldr w10,[x9,#5224]
 cmp w10,#19
 b.ne .Ltrstom_reject
 ldr w10,[x9,#7208]
 cmp w10,#1
 b.ne .Ltrstom_reject
 adrp x9,:got:__yommp0_MOD_nprtrn
 ldr x9,[x9,:got_lo12:__yommp0_MOD_nprtrn]
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Ltrstom_reject
 ARG x9,1
 ldr w10,[x9]
 cbnz w10,.Ltrstom_reject
 ARG x9,2
 ldr w10,[x9]
 cbnz w10,.Ltrstom_reject
 ARG x9,8
 cbnz x9,.Ltrstom_reject
 ARG x9,9
 cbnz x9,.Ltrstom_reject
 ARG x9,12
 cbnz x9,.Ltrstom_reject
 ARG x9,13
 cbnz x9,.Ltrstom_reject
 ARG x9,19
 cbnz x9,.Ltrstom_reject
 ARG x9,20
 cbnz x9,.Ltrstom_reject
 ARG x9,23
 cbnz x9,.Ltrstom_reject
 ARG x9,24
 cbnz x9,.Ltrstom_reject
 ARG x9,25
 cbnz x9,.Ltrstom_reject
 ARG x9,26
 cbnz x9,.Ltrstom_reject
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Ltrstom_reject
 str w9,[sp,#116]
 cbz w9,.Ltrstom_entry_done
 adr x0,.Ltrstom_hook_name
 add x1,sp,#112
 str wzr,[x1]
 add x2,sp,#120
 mov x3,#6
 CALL __yomhook_MOD_dr_hook_default8
.Ltrstom_entry_done:
 ARG x9,14
 cbz x9,.Ltrstom_check_skip0
 ARG x0,3
 ARG x1,14
 cbz x0,.Ltrstom_reject
 cbz x1,.Ltrstom_reject
 bl .Ltrstom_check2
.Ltrstom_check_skip0:
 ARG x9,15
 cbz x9,.Ltrstom_check_skip1
 ARG x0,4
 ARG x1,15
 cbz x0,.Ltrstom_reject
 cbz x1,.Ltrstom_reject
 bl .Ltrstom_check2
.Ltrstom_check_skip1:
 ARG x9,16
 cbz x9,.Ltrstom_check_skip2
 ARG x0,5
 ARG x1,16
 cbz x0,.Ltrstom_reject
 cbz x1,.Ltrstom_reject
 bl .Ltrstom_check2
.Ltrstom_check_skip2:
 ARG x9,22
 cbz x9,.Ltrstom_check_skip3
 ARG x0,11
 ARG x1,22
 cbz x0,.Ltrstom_reject
 cbz x1,.Ltrstom_reject
 bl .Ltrstom_check2
.Ltrstom_check_skip3:
 ARG x9,21
 cbz x9,.Ltrstom_check_skip_pressure
 ARG x0,10
 ARG x1,21
 cbz x0,.Ltrstom_reject
 cbz x1,.Ltrstom_reject
 bl .Ltrstom_check1
.Ltrstom_check_skip_pressure:
 ARG x9,14
 cbz x9,.Ltrstom_copy_skip0
 ARG x0,3
 ARG x1,14
 cbz x0,.Ltrstom_reject
 cbz x1,.Ltrstom_reject
 bl .Ltrstom_copy2
.Ltrstom_copy_skip0:
 ARG x9,15
 cbz x9,.Ltrstom_copy_skip1
 ARG x0,4
 ARG x1,15
 cbz x0,.Ltrstom_reject
 cbz x1,.Ltrstom_reject
 bl .Ltrstom_copy2
.Ltrstom_copy_skip1:
 ARG x9,16
 cbz x9,.Ltrstom_copy_skip2
 ARG x0,5
 ARG x1,16
 cbz x0,.Ltrstom_reject
 cbz x1,.Ltrstom_reject
 bl .Ltrstom_copy2
.Ltrstom_copy_skip2:
 ARG x9,22
 cbz x9,.Ltrstom_copy_skip3
 ARG x0,11
 ARG x1,22
 cbz x0,.Ltrstom_reject
 cbz x1,.Ltrstom_reject
 bl .Ltrstom_copy2
.Ltrstom_copy_skip3:
 ARG x9,21
 cbz x9,.Ltrstom_copy_skip_pressure
 ARG x0,10
 ARG x1,21
 cbz x0,.Ltrstom_reject
 cbz x1,.Ltrstom_reject
 bl .Ltrstom_copy1
.Ltrstom_copy_skip_pressure:
 ldr w9,[sp,#116]
 cbz w9,.Ltrstom_return
 adr x0,.Ltrstom_hook_name
 add x1,sp,#112
 mov w9,#1
 str w9,[x1]
 add x2,sp,#120
 mov x3,#6
 CALL __yomhook_MOD_dr_hook_default8
.Ltrstom_return:
 adrp x9,:got:md2asm_spectral_column_to_level_7358525_count
 ldr x9,[x9,:got_lo12:md2asm_spectral_column_to_level_7358525_count]
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp,#96]
 ldr x18,[sp,#480]
 add sp,sp,#512
 ret
.Ltrstom_check2:
 mov x2,#2
 b .Ltrstom_check_descriptor_pair
.Ltrstom_check1:
 mov x2,#1
.Ltrstom_check_descriptor_pair:
 mov x3,x0
 mov x4,x1
 mov x5,#2
.Ltrstom_check_descriptor:
 ldr x9,[x3]
 cbz x9,.Ltrstom_reject
 tst x9,#7
 b.ne .Ltrstom_reject
 ldr x9,[x3,#16]
 cmp x9,#8
 b.ne .Ltrstom_reject
 ldr x9,[x3,#24]
 ubfx x10,x9,#32,#8
 cmp x10,x2
 b.ne .Ltrstom_reject
 lsr x10,x9,#40
 cmp x10,#3
 b.ne .Ltrstom_reject
 ldr x9,[x3,#32]
 cmp x9,#8
 b.ne .Ltrstom_reject
 ldr x9,[x3,#40]
 cmp x9,#1
 b.ne .Ltrstom_reject
 ldr x9,[x3,#56]
 ldr x10,[x3,#48]
 sub x9,x9,x10
 add x9,x9,#1
 cmp x2,#1
 mov x10,#506
 mov x11,#19
 csel x10,x10,x11,eq
 cmp x9,x10
 b.ne .Ltrstom_reject
 cmp x2,#1
 b.eq .Ltrstom_next_descriptor
 ldr x9,[x3,#64]
 cmp x9,#19
 b.ne .Ltrstom_reject
 ldr x9,[x3,#80]
 ldr x10,[x3,#72]
 sub x9,x9,x10
 add x9,x9,#1
 cmp x9,#506
 b.ne .Ltrstom_reject
.Ltrstom_next_descriptor:
 mov x3,x4
 subs x5,x5,#1
 b.ne .Ltrstom_check_descriptor
 ret
.Ltrstom_copy2:
 ldr x9,[x0]
 ldr x10,[x1]
 mov x11,#0
.Ltrstom_copy_level:
 add x12,x9,x11,lsl #3
 add x13,x10,x11,lsl #3
 mov x14,#506
.Ltrstom_copy_column:
 ldr x15,[x12],#152
 str x15,[x13],#152
 subs x14,x14,#1
 b.ne .Ltrstom_copy_column
 add x11,x11,#1
 cmp x11,#19
 b.lt .Ltrstom_copy_level
 ret
.Ltrstom_copy1:
 ldr x9,[x0]
 ldr x10,[x1]
 mov x11,#506
.Ltrstom_copy_pressure:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#1
 b.ne .Ltrstom_copy_pressure
 ret
.Ltrstom_reject:
 brk #0x53c
.size md2asm_spectral_column_to_level_7358525,.-md2asm_spectral_column_to_level_7358525
.section .rodata
.Ltrstom_hook_name: .ascii "TRSTOM"
.bss
.p2align 3
.global md2asm_spectral_column_to_level_7358525_count
.type md2asm_spectral_column_to_level_7358525_count,%object
md2asm_spectral_column_to_level_7358525_count: .zero 8
.size md2asm_spectral_column_to_level_7358525_count,8
.section .note.GNU-stack,"",%progbits
