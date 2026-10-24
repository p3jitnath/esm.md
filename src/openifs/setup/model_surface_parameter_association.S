/* Actual MODEL/SUSURF source-order pointer association. No numerical operation. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_attach_selected_model_surface
.type md2asm_attach_selected_model_surface,%function
md2asm_attach_selected_model_surface:
 mov w3,#0
 b .Lsurface_associate
.size md2asm_attach_selected_model_surface,.-md2asm_attach_selected_model_surface
.global md2asm_detach_selected_model_surface
.type md2asm_detach_selected_model_surface,%function
md2asm_detach_selected_model_surface:
 mov w3,#1
.Lsurface_associate:
 cbz x0,.Lsurface_association_bad
 cbz x2,.Lsurface_association_bad
 orr x9,x0,x2
 tst x9,#7
 b.ne .Lsurface_association_bad
 mov x9,#0x3b90
 movk x9,#0x41,lsl#16
 cmp x1,x9
 b.lo .Lsurface_association_bad
 adds x10,x0,x9
 b.cs .Lsurface_association_bad
 adds x11,x2,#16
 b.cs .Lsurface_association_bad
 cmp x0,x11
 b.hs .Lsurface_association_records_clear
 cmp x2,x10
 b.lo .Lsurface_association_bad
.Lsurface_association_records_clear:
 adrp x9,md2asm_owned_initial_model_owner
 ldr x9,[x9,:lo12:md2asm_owned_initial_model_owner]
 cmp x9,x0
 b.ne .Lsurface_association_bad
 ldp x12,x13,[x2]
 cbz x12,.Lsurface_association_bad
 tst x12,#7
 b.ne .Lsurface_association_bad
 mov x14,#11584
 cmp x13,x14
 b.ne .Lsurface_association_bad
 adds x14,x12,x14
 b.cs .Lsurface_association_bad
 cmp x12,x10
 b.hs .Lsurface_association_model_clear
 cmp x0,x14
 b.lo .Lsurface_association_bad
.Lsurface_association_model_clear:
 cmp x12,x11
 b.hs .Lsurface_association_result_clear
 cmp x2,x14
 b.lo .Lsurface_association_bad
.Lsurface_association_result_clear:
 movz x9,#(1578328 & 65535)
 movk x9,#(1578328 >> 16),lsl#16
 add x9,x0,x9
 ldr x10,[x9]
 cbnz w3,.Lsurface_detach
 cbnz x10,.Lsurface_association_bad
 str x12,[x9]
 mov w0,#0
 ret
.Lsurface_detach:
 cmp x10,x12
 b.ne .Lsurface_association_bad
 str xzr,[x9]
 mov w0,#0
 ret
.Lsurface_association_bad:
 mov w0,#2
 ret
.size md2asm_detach_selected_model_surface,.-md2asm_detach_selected_model_surface
.section .note.GNU-stack,"",%progbits
