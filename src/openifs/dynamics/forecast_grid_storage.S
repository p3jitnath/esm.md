/* GP_MODEL selected storage caller.
 * Contract: skills/md2asm/references/openifs/dynamics/retained_forecast_callers.md.
 * Original by-address interfaces and frozen child order are retained. */
.arch armv8.2-a+simd
.text
.p2align 4
.global md2asm_gp_model_heap2_pressure_return_r3_7358525
.type md2asm_gp_model_heap2_pressure_return_r3_7358525,%function
md2asm_gp_model_heap2_pressure_return_r3_7358525:
 sub sp,sp,#256
 stp x18,x19,[sp,#64]
 stp x20,x21,[sp,#80]
 stp x22,x23,[sp,#96]
 stp x24,x25,[sp,#112]
 stp x26,x27,[sp,#128]
 stp x28,x29,[sp,#144]
 str x30,[sp,#160]
 mov x29,sp
 str x0,[sp,#168]
 str x1,[sp,#176]
 str x2,[sp,#184]
 str x3,[sp,#192]
 str x4,[sp,#200]
 str x5,[sp,#208]
 str x6,[sp,#216]
 str x7,[sp,#224]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 cmp x7,#9
 b.ne .Lreject
 mrs x9,fpcr
 cbnz x9,.Lreject
 movz x16,#5144
 add x9,x19,x16
 ldr w9,[x9]
 cmp w9,#24
 b.ne .Lreject
 movz x16,#5160
 add x9,x19,x16
 ldr w9,[x9]
 cmp w9,#86
 b.ne .Lreject
 movz x16,#5224
 add x9,x19,x16
 ldr w9,[x9]
 cmp w9,#19
 b.ne .Lreject
 movz x16,#63280
 movk x16,#23,lsl #16
 add x9,x21,x16
 ldr w9,[x9]
 cmp w9,#12
 b.ne .Lreject
 movz x16,#1920
 movk x16,#24,lsl #16
 add x9,x21,x16
 ldr w9,[x9]
 cmp w9,#3101
 b.ne .Lreject
 movz x16,#152
 movk x16,#24,lsl #16
 add x9,x21,x16
 ldr w9,[x9]
 cmp w9,#463
 b.ne .Lreject
 movz x16,#456
 movk x16,#24,lsl #16
 add x9,x21,x16
 ldr w9,[x9]
 cmp w9,#153
 b.ne .Lreject
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 str w9,[sp,#232]
 cbz w9,.Lhook0
 adrp x0,.Lname
 add x0,x0,:lo12:.Lname
 str wzr,[sp,#236]
 add x1,sp,#236
 add x2,sp,#240
 mov x3,#14
 bl __yomhook_MOD_dr_hook_default8
.Lhook0:
 adrp x22,.Lowners
 add x22,x22,:lo12:.Lowners
 ldr x9,[x22]
 cbnz x9,.Lallocated
 movz x0,#37632
 movk x0,#9,lsl #16
 bl malloc
 cbz x0,.Lreject
 str x0,[x22,#0]
 movz x0,#29184
 movk x0,#57,lsl #16
 bl malloc
 cbz x0,.Lreject
 str x0,[x22,#8]
 movz x0,#17304
 movk x0,#175,lsl #16
 bl malloc
 cbz x0,.Lreject
 str x0,[x22,#16]
 movz x0,#35968
 movk x0,#38,lsl #16
 bl malloc
 cbz x0,.Lreject
 str x0,[x22,#24]
.Lallocated:
 mov x0,x19
 mov x1,x20
 mov x2,x21
 ldr x3,[sp,#192]
 ldr x4,[sp,#200]
 ldr x5,[x22]
 ldr x6,[x22,#8]
 ldr x7,[x22,#16]
 ldr x9,[x22,#24]
 str x9,[sp]
 ldr x9,[sp,#208]
 str x9,[sp,#8]
 ldr x9,[sp,#216]
 str x9,[sp,#16]
 mov x9,#9
 str x9,[sp,#24]
 bl md2asm_gp_model_physics_cape_r7_7358525
 adrp x9,.Lcount
 add x9,x9,:lo12:.Lcount
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ldr w9,[sp,#232]
 cbz w9,.Lhook1
 adrp x0,.Lname
 add x0,x0,:lo12:.Lname
 mov w9,#1
 str w9,[sp,#236]
 add x1,sp,#236
 add x2,sp,#240
 mov x3,#14
 bl __yomhook_MOD_dr_hook_default8
.Lhook1:
 ldp x18,x19,[sp,#64]
 ldp x20,x21,[sp,#80]
 ldp x22,x23,[sp,#96]
 ldp x24,x25,[sp,#112]
 ldp x26,x27,[sp,#128]
 ldp x28,x29,[sp,#144]
 ldr x30,[sp,#160]
 add sp,sp,#256
 ret
.Lreject:
 bl abort
 brk #0
.size md2asm_gp_model_heap2_pressure_return_r3_7358525,.-md2asm_gp_model_heap2_pressure_return_r3_7358525
.global md2asm_gp_model_heap2_pressure_return_r3_count_get
md2asm_gp_model_heap2_pressure_return_r3_count_get:
 adrp x9,.Lcount
 add x9,x9,:lo12:.Lcount
 ldr x0,[x9]
 ret
.section .rodata
.Lname: .ascii "GP_MODEL_HEAP2"
.bss
.p2align 3
.Lowners: .zero 32
.Lcount: .zero 8
.section .note.GNU-stack,"",%progbits
