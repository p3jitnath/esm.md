/* Source build for the qualified private forecast graph.
 * Contract: skills/md2asm/references/openifs/dynamics/private_forecast_graph_sources.md.
 * Preserve the original interface, ordered arithmetic, and caller-owned storage. */
/* Complete selected CPG_DIA, source contract revision 1.
 * Physics formulations/openifs/dynamics/grid_point_diagnostic_caller.md.
 * Contract skills/md2asm/references/openifs/dynamics/grid_point_diagnostic_caller.md.
 * Original ordinary addresses and all caller fields stay unchanged. */
.arch armv8.2-a+simd
.text
.p2align 4
.global md2asm_cpg_dia_7358525
.global cpg_dia_
.set cpg_dia_,md2asm_cpg_dia_7358525
.type md2asm_cpg_dia_7358525,%function
md2asm_cpg_dia_7358525:
 sub sp,sp,#64
 stp x18,x19,[sp,#0]
 stp x29,x30,[sp,#16]
 mov x29,sp
 mrs x9,fpcr
 cbnz x9,.Lreject
 movz x10,#38608
 movk x10,#64,lsl #16
 ldr w10,[x5,x10]
 cmp w10,#0
 b.ne .Lreject
 movz x10,#38704
 movk x10,#64,lsl #16
 ldr w10,[x5,x10]
 cmp w10,#0
 b.ne .Lreject
 movz x10,#5088
 movk x10,#24,lsl #16
 ldr w10,[x5,x10]
 cmp w10,#1
 b.ne .Lreject
 movz x10,#23880
 movk x10,#64,lsl #16
 ldr w10,[x5,x10]
 cmp w10,#0
 b.ne .Lreject
 movz x10,#4588
 movk x10,#24,lsl #16
 ldr w10,[x5,x10]
 cmp w10,#0
 b.ne .Lreject
 ldr x9,[sp,#104]
 ldr w9,[x9]
 cbnz w9,.Lreject
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 str w9,[sp,#40]
 cbz w9,.Lprofile_done
 adrp x0,.Lname
 add x0,x0,:lo12:.Lname
 str wzr,[sp,#44]
 add x1,sp,#44
 add x2,sp,#32
 mov x3,#7
 bl __yomhook_MOD_dr_hook_default8
 mov x19,#14
.Lviews:
 adrp x0,.Lview_name
 add x0,x0,:lo12:.Lview_name
 str wzr,[sp,#44]
 add x1,sp,#44
 add x2,sp,#48
 mov x3,#17
 bl __yomhook_MOD_dr_hook_default8
 adrp x0,.Lview_name
 add x0,x0,:lo12:.Lview_name
 mov w9,#1
 str w9,[sp,#44]
 add x1,sp,#44
 add x2,sp,#48
 mov x3,#17
 bl __yomhook_MOD_dr_hook_default8
 subs x19,x19,#1
 b.ne .Lviews
 adrp x0,.Lname
 add x0,x0,:lo12:.Lname
 mov w9,#1
 str w9,[sp,#44]
 add x1,sp,#44
 add x2,sp,#32
 mov x3,#7
 bl __yomhook_MOD_dr_hook_default8
.Lprofile_done:
 adrp x9,.Lcalls
 ldr x10,[x9,:lo12:.Lcalls]
 add x10,x10,#1
 str x10,[x9,:lo12:.Lcalls]
 ldp x18,x19,[sp,#0]
 ldp x29,x30,[sp,#16]
 add sp,sp,#64
 ret
.Lreject:
 bl abort
 brk #0
.size md2asm_cpg_dia_7358525,.-md2asm_cpg_dia_7358525
.global md2asm_cpg_dia_count_get
md2asm_cpg_dia_count_get:
 adrp x9,.Lcalls
 ldr x0,[x9,:lo12:.Lcalls]
 ret
.section .rodata
.Lname: .ascii "CPG_DIA"
.Lview_name: .ascii "SC2PRG_MOD:SC2PRG"
.bss
.p2align 3
.Lcalls: .zero 8
.section .note.GNU-stack,"",%progbits
