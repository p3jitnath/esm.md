/* GP_DERIVATIVES.
 * Contract: skills/md2asm/references/openifs/dynamics/retained_forecast_callers.md.
 * Original by-address interfaces and frozen child order are retained. */
.text
.p2align 4
.global md2asm_gp_derivatives_7358525
.global gp_derivatives_
.set gp_derivatives_,md2asm_gp_derivatives_7358525
.type md2asm_gp_derivatives_7358525,%function
md2asm_gp_derivatives_7358525:
 sub sp,sp,#64
 stp x18,x30,[sp,#32]
 str x19,[sp,#48]
 mov x19,x2
 adrp x9,:got:__yomdyna_static_MOD_lgradgp
 ldr x9,[x9,:got_lo12:__yomdyna_static_MOD_lgradgp]
 ldr w9,[x9]
 cbnz w9,.Lreject
 ldr w9,[x19]
 cmp w9,#8
 b.ne .Lreject
 add x9,x19,#3848
 mov x10,#8
.Lcomponent:
 ldr w11,[x9,#52]
 ldr w12,[x9,#60]
 and w11,w11,w12
 cbnz w11,.Lreject
 add x9,x9,#368
 subs x10,x10,#1
 b.ne .Lcomponent
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 str w9,[sp,#0]
 cbz w9,.Lhook0
 adrp x0,.Lname
 add x0,x0,:lo12:.Lname
 str wzr,[sp,#4]
 add x1,sp,#4
 add x2,sp,#8
 mov x3,#14
 bl __yomhook_MOD_dr_hook_default8
.Lhook0:
 adrp x9,.Lcount
 add x9,x9,:lo12:.Lcount
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ldr w9,[sp,#0]
 cbz w9,.Lhook1
 adrp x0,.Lname
 add x0,x0,:lo12:.Lname
 mov w9,#1
 str w9,[sp,#4]
 add x1,sp,#4
 add x2,sp,#8
 mov x3,#14
 bl __yomhook_MOD_dr_hook_default8
.Lhook1:
 ldr x19,[sp,#48]
 ldp x18,x30,[sp,#32]
 add sp,sp,#64
 ret
.Lreject:
 bl abort
 brk #0
.size md2asm_gp_derivatives_7358525,.-md2asm_gp_derivatives_7358525
.global md2asm_gp_derivatives_count_get
md2asm_gp_derivatives_count_get:
 adrp x9,.Lcount
 add x9,x9,:lo12:.Lcount
 ldr x0,[x9]
 ret
.section .rodata
.Lname: .ascii "GP_DERIVATIVES"
.bss
.p2align 3
.Lcount: .zero 8
.section .note.GNU-stack,"",%progbits
