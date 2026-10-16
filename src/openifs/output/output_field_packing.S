/* Selected spectral and grid output packing.
 * Contract: skills/md2asm/references/openifs/dynamics/retained_forecast_callers.md.
 * Original by-address interfaces and frozen child order are retained. */
.text
.p2align 4
.macro CALL name
 str x18,[sp,#512]
 bl \name
 ldr x18,[sp,#512]
.endm
.macro ARRAYVAL reg,base,offset,index,shift
 add x9,\base,#\offset
 ldr x10,[x9,#8]
 ldr x11,[x9,#40]
 ldr x12,[x9,#48]
 add x12,x12,\index
 madd x10,x12,x11,x10
 ldr x9,[x9]
 add x9,x9,x10,lsl #\shift
 ldr \reg,[x9]
.endm
.macro GLOBAL reg,name
 adrp x9,:got:\name
 ldr x9,[x9,:got_lo12:\name]
 ldr \reg,[x9]
.endm

.global md2asm_pack_spectral_output_7358525
.type md2asm_pack_spectral_output_7358525,%function
md2asm_pack_spectral_output_7358525:
 sub sp,sp,#640
 stp x19,x20,[sp,#384]
 stp x21,x22,[sp,#400]
 stp x23,x24,[sp,#416]
 stp x25,x26,[sp,#432]
 stp x27,x28,[sp,#448]
 stp x29,x30,[sp,#464]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 mov x24,x5
 ldr w27,[x19]
 cmp w27,#39
 b.hi .Lsp_reject
 ldr w9,[x19,#608]
 cmp w9,w27
 b.ne .Lsp_reject
 mov x25,#0
 mov x26,#0
 cbz w27,.Lsp_done
.Lsp_field:
 ARRAYVAL w13,x19,72,x25,2
 cmp w13,#130
 b.eq .Lsp_code_ok
 cmp w13,#133
 b.eq .Lsp_code_ok
 cmp w13,#152
 b.ne .Lsp_reject
.Lsp_code_ok:
 add x28,x22,x26,lsl #4
 str w13,[x28]
 ARRAYVAL w14,x19,136,x25,2
 cbz w14,.Lsp_level
 mov w15,#1
 cbz w24,.Lsp_level_done
 mov w15,#34464
 movk w15,#1,lsl #16
 b .Lsp_level_done
.Lsp_level:
 ARRAYVAL d0,x19,264,x25,3
 fcvtas w15,d0
.Lsp_level_done:
 add x28,x22,x26,lsl #4
 str w15,[x28,#4]
 ARRAYVAL w14,x19,616,x25,2
 cmp w14,#1
 b.ne .Lsp_reject
 str w14,[x28,#8]
 ARRAYVAL w15,x19,680,x25,2
 str w15,[x28,#12]
 sxtw x15,w15
 ldr x9,[x20,#48]
 sub x15,x15,x9
 cmp x15,#0
 b.lt .Lsp_reject
 ldr x10,[x20,#56]
 sub x10,x10,x9
 cmp x15,x10
 b.gt .Lsp_reject
 ldr x10,[x20,#40]
 ldr x11,[x20,#8]
 madd x11,x15,x10,x11
 madd x11,x9,x10,x11
 ldr x12,[x20,#72]
 ldr x13,[x20,#64]
 madd x11,x12,x13,x11
 ldr x12,[x20]
 add x12,x12,x11,lsl #3
 madd x28,x26,x23,xzr
 add x28,x21,x28,lsl #3
 mov x14,#0
.Lsp_wave:
 mul x9,x14,x13
 ldr x10,[x12,x9,lsl #3]
 str x10,[x28,x14,lsl #3]
 add x14,x14,#1
 cmp x14,x23
 b.lt .Lsp_wave
 add x26,x26,#1
 add x25,x25,#1
 cmp x25,x27
 b.lt .Lsp_field
.Lsp_done:
 mov x0,x26
 ldp x19,x20,[sp,#384]
 ldp x21,x22,[sp,#400]
 ldp x23,x24,[sp,#416]
 ldp x25,x26,[sp,#432]
 ldp x27,x28,[sp,#448]
 ldp x29,x30,[sp,#464]
 add sp,sp,#640
 ret
.Lsp_reject:
 CALL abort
.size md2asm_pack_spectral_output_7358525,.-md2asm_pack_spectral_output_7358525
.global md2asm_pack_grid_output_7358525
.type md2asm_pack_grid_output_7358525,%function
md2asm_pack_grid_output_7358525:
 sub sp,sp,#640
 stp x19,x20,[sp,#384]
 stp x21,x22,[sp,#400]
 stp x23,x24,[sp,#416]
 stp x25,x26,[sp,#432]
 stp x27,x28,[sp,#448]
 stp x29,x30,[sp,#464]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 mov x24,x5
 str x6,[sp,#528]
 ldr w27,[x19]
 cmp w27,#39
 b.hi .Lgp_reject
 mov x25,#0
 mov x26,#0
 cbz w27,.Lgp_done
.Lgp_field:
 ARRAYVAL w13,x19,72,x25,2
 cmp w13,#130
 b.eq .Lgp_code_ok
 cmp w13,#133
 b.eq .Lgp_code_ok
 cmp w13,#152
 b.ne .Lgp_reject
.Lgp_code_ok:
 ldr x9,[sp,#528]
 cbz x9,.Lgp_selected
 ARRAYVAL w14,x19,136,x25,2
 cbz w14,.Lgp_selected
 cmp w13,#152
 b.eq .Lgp_next
.Lgp_selected:
 add x28,x22,x26,lsl #3
 str w13,[x28]
 ARRAYVAL d0,x19,264,x25,3
 fcvtas w15,d0
 str w15,[x28,#4]
 mov x14,#0
.Lgp_cell:
 udiv x15,x14,x24
 msub x16,x15,x24,x14
 ldr x9,[x20,#8]
 ldr x10,[x20,#48]
 add x10,x10,x16
 ldr x11,[x20,#40]
 madd x9,x10,x11,x9
 ldr x10,[x20,#72]
 add x10,x10,x25
 ldr x11,[x20,#64]
 madd x9,x10,x11,x9
 ldr x10,[x20,#96]
 add x10,x10,x15
 ldr x11,[x20,#88]
 madd x9,x10,x11,x9
 ldr x10,[x20]
 ldr x11,[x10,x9,lsl #3]
 madd x10,x26,x23,x14
 str x11,[x21,x10,lsl #3]
 add x14,x14,#1
 cmp x14,x23
 b.lt .Lgp_cell
 add x26,x26,#1
.Lgp_next:
 add x25,x25,#1
 cmp x25,x27
 b.lt .Lgp_field
.Lgp_done:
 mov x0,x26
 ldp x19,x20,[sp,#384]
 ldp x21,x22,[sp,#400]
 ldp x23,x24,[sp,#416]
 ldp x25,x26,[sp,#432]
 ldp x27,x28,[sp,#448]
 ldp x29,x30,[sp,#464]
 add sp,sp,#640
 ret
.Lgp_reject:
 CALL abort
.size md2asm_pack_grid_output_7358525,.-md2asm_pack_grid_output_7358525
.section .note.GNU-stack,"",%progbits
