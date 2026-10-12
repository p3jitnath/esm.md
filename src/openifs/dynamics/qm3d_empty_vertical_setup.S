/* Physics input is formulations/openifs/dynamics/departure_field_transport.md. */
/* Complete the original input-dependent vertical setup for empty work.
 * The full native interpolation remains the unchanged accepted child.
 * Each ratio uses two separately rounded differences and one FP64 division.
 * The 19-argument original ABI is forwarded without changing any argument.
 */
.text
.p2align 4
.global md2asm_laitriqm3d_complete_status_7259755
.type md2asm_laitriqm3d_complete_status_7259755,%function
md2asm_laitriqm3d_complete_status_7259755:
 ldr w9,[x4]
 ldr w10,[x5]
 cmp w9,w10
 b.le .Lqm3d_forward
 ldr w11,[x6]
 cmp w11,#2
 b.lt .Lqm3d_forward
 ldr w9,[x1]
 cbz w9,.Lqm3d_forward
 ldr x9,[sp,#8]
 ldr w9,[x9]
 cmp w9,#2
 b.ne .Lqm3d_forward
 ldr x9,[x0]
 mov x10,#2
.Lqm3d_empty_vertical:
 ldr d0,[x9,x10,lsl #3]
 sub x12,x10,#1
 ldr d1,[x9,x12,lsl #3]
 fsub d0,d0,d1
 sub x12,x12,#1
 ldr d2,[x9,x12,lsl #3]
 fsub d1,d1,d2
 fdiv d0,d0,d1
 add x10,x10,#1
 cmp x10,x11
 b.le .Lqm3d_empty_vertical
.Lqm3d_forward:
 b md2asm_laitriqm3d
.size md2asm_laitriqm3d_complete_status_7259755,.-md2asm_laitriqm3d_complete_status_7259755
.section .note.GNU-stack,"",%progbits

