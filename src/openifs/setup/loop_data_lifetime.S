/* Contract: skills/md2asm/references/openifs/setup/loop_data_bindings.md.
 * int md2asm_release_selected_loop_data(void). Owned four-array lifetime only. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_release_selected_loop_data
.type md2asm_release_selected_loop_data,%function
md2asm_release_selected_loop_data:
 adrp x9,md2asm_owned_loop_data
 add x9,x9,:lo12:md2asm_owned_loop_data
 ldr x10,[x9,#544]
 cbz x10,.Lloop_release_done
 cmp x10,#15
 b.ne .Lloop_release_bad
 stp x29,x30,[sp,#-48]!
 stp x19,x20,[sp,#16]
 str x18,[sp,#32]
 mov x29,sp
 mov x19,x9
 mov x20,#3
.Lloop_release_next:
 adrp x9,.Lloop_release_offsets
 add x9,x9,:lo12:.Lloop_release_offsets
 ldr x9,[x9,x20,lsl#3]
 ldr x0,[x19,x9]
 bl free
 ldr x18,[sp,#32]
 adrp x9,.Lloop_release_offsets
 add x9,x9,:lo12:.Lloop_release_offsets
 ldr x9,[x9,x20,lsl#3]
 str xzr,[x19,x9]
 subs x20,x20,#1
 b.pl .Lloop_release_next
 str xzr,[x19,#544]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#48
.Lloop_release_done:
 mov w0,#0
 ret
.Lloop_release_bad:
 mov w0,#2
 ret
.size md2asm_release_selected_loop_data,.-md2asm_release_selected_loop_data
.section .rodata
.p2align 3
.Lloop_release_offsets:.quad 72,160,416,480
.section .note.GNU-stack,"",%progbits
