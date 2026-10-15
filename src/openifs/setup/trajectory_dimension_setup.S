/* Source-ordered empty-group trajectory dimensions.
 * Contract skills/md2asm/references/openifs/setup/trajectory_dimension_setup.md. w0 wave limit, x1 twelve
 * output addresses. Integer metadata only, no external calls or stack.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_trajectory_dimensions
.type md2asm_initialize_trajectory_dimensions,%function
md2asm_initialize_trajectory_dimensions:
 mov w9,#8191
 cmp w0,w9
 b.hi .Ltdim_reject
 cbz x1,.Ltdim_reject
 tst x1,#7
 b.ne .Ltdim_reject
 mov x2,#0
.Ltdim_validate:
 ldr x3,[x1,x2,lsl#3]
 cbz x3,.Ltdim_reject
 tst x3,#3
 b.ne .Ltdim_reject
 add x2,x2,#1
 cmp x2,#12
 b.lo .Ltdim_validate
 mov x2,#0
.Ltdim_write:
 ldr x3,[x1,x2,lsl#3]
 str w0,[x3]
 add x2,x2,#1
 cmp x2,#12
 b.lo .Ltdim_write
 mov w0,#0
 ret
.Ltdim_reject:
 mov w0,#2
 ret
.size md2asm_initialize_trajectory_dimensions,.-md2asm_initialize_trajectory_dimensions
.section .note.GNU-stack,"",%progbits
