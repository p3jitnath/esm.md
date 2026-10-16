/* Internal owner leaf. Contract: skills/md2asm/references/openifs/radiation/ecrad_configuration.md. */
.text
.p2align 4
.global md2asm_allocate_ecrad_vector
.hidden md2asm_allocate_ecrad_vector
.type md2asm_allocate_ecrad_vector,%function
/* x0 descriptor64, w1 positive count, w2 element bytes 4 or 8. */
md2asm_allocate_ecrad_vector:
 stp x29,x30,[sp,#-64]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mov x19,x0
 uxtw x20,w1
 uxtw x21,w2
 mul x0,x20,x21
 bl malloc
 cbz x0,.Lvector_failed
 mov x1,#-1
 stp x0,x1,[x19]
 str x21,[x19,#16]
 mov w1,#769
 cmp x21,#8
 b.eq .Lvector_type
 mov w1,#257
.Lvector_type:
 str wzr,[x19,#24]
 str w1,[x19,#28]
 str x21,[x19,#32]
 mov x1,#1
 stp x1,x1,[x19,#40]
 str x20,[x19,#56]
 mov w0,#0
 b .Lvector_return
.Lvector_failed:
 mov w0,#1
.Lvector_return:
 ldp x21,x18,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#64
 ret
.size md2asm_allocate_ecrad_vector,.-md2asm_allocate_ecrad_vector
.section .note.GNU-stack,"",%progbits
