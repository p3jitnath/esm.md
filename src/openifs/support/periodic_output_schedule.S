/* MONIO_T.
 * Contract: skills/md2asm/references/openifs/dynamics/retained_forecast_callers.md.
 * Original by-address interfaces and frozen child order are retained. */
.arch armv8.2-a+simd
.text
.p2align 4
.global md2asm_monio_t_7358525
.type md2asm_monio_t_7358525,%function
md2asm_monio_t_7358525:
 mov x17,sp
 sub sp,sp,#256
 stp x18,x19,[sp]
 stp x20,x21,[sp,#16]
 stp x22,x23,[sp,#32]
 stp x24,x25,[sp,#48]
 stp x26,x27,[sp,#64]
 stp x28,x29,[sp,#80]
 str x30,[sp,#96]
 mov x29,sp
 mrs x9,fpcr
 cbnz x9,.Lreject
 ldrsw x23,[x0]
 cmp x23,#0
 b.lt .Lreject
 ldrsw x27,[x1]
 ldrsw x28,[x1,#4]
 cmp x27,#0
 b.lt .Lreject
 movz x9,#16960
 movk x9,#15,lsl #16
 cmp x28,x9
 b.gt .Lreject
 ldr x9,[x1,#200]
 ubfx x10,x9,#52,#11
 cbz x10,.Lreject
 cmp x10,#2047
 b.eq .Lreject
 ldrsw x25,[x3]
 ldrsw x26,[x4]
 cmp x26,#1
 b.lt .Lreject
 ldr w9,[x5]
 cbnz w9,.Lreject
 mov w19,#1
 cbz x7,.Lcondition_ready
 ldr w19,[x7]
 cmp w19,#1
 b.hi .Lreject
.Lcondition_ready:
 str w19,[x29,#112]
 ldr x9,[x17]
 cbz x9,.Lactive_ready
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lreject
 cbnz w9,.Lactive_ready
 mov x25,#0
.Lactive_ready:
 ldr x9,[x2,#16]
 cmp x9,#4
 b.ne .Lreject
 ldrb w9,[x2,#28]
 cmp w9,#1
 b.ne .Lreject
 ldr x21,[x2,#40]
 cmp x21,#1
 b.lt .Lreject
 ldr x10,[x2,#48]
 ldr x11,[x2,#56]
 sub x22,x11,x10
 add x22,x22,#1
 cmp x22,#0
 b.lt .Lreject
 movz x9,#16960
 movk x9,#15,lsl #16
 cmp x22,x9
 b.gt .Lreject
 add x24,x23,x22
 sub x24,x24,#1
 ldr x20,[x2]
 cbz x22,.Loutput_address_ready
 cbz x20,.Lreject
 ldr x11,[x2,#8]
 madd x11,x21,x10,x11
 add x20,x20,x11,lsl #2
.Loutput_address_ready:
 lsl x21,x21,#2
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 str w9,[x29,#116]
 cbz w9,.Lprofile_entry_ready
 adrp x0,.Lname
 add x0,x0,:lo12:.Lname
 str wzr,[x29,#120]
 add x1,x29,#120
 add x2,x29,#128
 mov x3,#7
 bl __yomhook_MOD_dr_hook_default8
.Lprofile_entry_ready:
 mov x9,#0
 cbz x22,.Lclear_done
.Lclear:
 mul x10,x9,x21
 str wzr,[x20,x10]
 add x9,x9,#1
 cmp x9,x22
 b.lo .Lclear
.Lclear_done:
 ldr w9,[x29,#112]
 cbz w9,.Lschedule_done
 cmp x27,x28
 b.gt .Lschedule_done
.Lsource_step:
 sdiv x9,x27,x26
 msub x10,x9,x26,x27
 cbnz x10,.Lnext_step
 cmp x9,x23
 b.lt .Lnext_step
 cmp x9,x24
 b.gt .Lnext_step
 sub x9,x9,x23
 mul x9,x9,x21
 str w25,[x20,x9]
.Lnext_step:
 add x27,x27,#1
 cmp x27,x28
 b.le .Lsource_step
.Lschedule_done:
 adrp x9,.Lcalls
 add x9,x9,:lo12:.Lcalls
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ldr w9,[x29,#116]
 cbz w9,.Lreturn
 adrp x0,.Lname
 add x0,x0,:lo12:.Lname
 mov w9,#1
 str w9,[x29,#120]
 add x1,x29,#120
 add x2,x29,#128
 mov x3,#7
 bl __yomhook_MOD_dr_hook_default8
.Lreturn:
 ldp x18,x19,[sp]
 ldp x20,x21,[sp,#16]
 ldp x22,x23,[sp,#32]
 ldp x24,x25,[sp,#48]
 ldp x26,x27,[sp,#64]
 ldp x28,x29,[sp,#80]
 ldr x30,[sp,#96]
 add sp,sp,#256
 ret
.Lreject:
 bl abort
 brk #0
.size md2asm_monio_t_7358525,.-md2asm_monio_t_7358525
.global md2asm_monio_t_count_get
.type md2asm_monio_t_count_get,%function
md2asm_monio_t_count_get:
 adrp x9,.Lcalls
 add x9,x9,:lo12:.Lcalls
 ldr x0,[x9]
 ret
.section .rodata
.Lname: .ascii "MONIO_T"
.bss
.p2align 3
.Lcalls: .zero 8
.section .note.GNU-stack,"",%progbits
