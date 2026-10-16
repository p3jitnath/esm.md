/* Contract: skills/md2asm/references/openifs/runtime/post_csta_continuation.md.
 * x0: ten address/capacity pairs. Own only selected CNT3_GLO tail after CSTA.
 * Numerical SPNORM body is the unchanged accepted direct child.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_complete_selected_fresh_initialization
.type md2asm_complete_selected_fresh_initialization,%function
md2asm_complete_selected_fresh_initialization:
 cbz x0,.Lpost_csta_bad_leaf
 tst x0,#7
 b.ne .Lpost_csta_bad_leaf
 adds x9,x0,#160
 b.cs .Lpost_csta_bad_leaf
 mrs x10,fpcr
 cbnz x10,.Lpost_csta_bad_leaf
 sub sp,sp,#128
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 str x18,[sp,#64]
 mov x29,sp
 mov x19,x0
 adrp x20,.Lpost_csta_extents
 add x20,x20,:lo12:.Lpost_csta_extents
 mov x21,#0
.Lpost_csta_ranges:
 add x9,x19,x21,lsl#4
 ldp x10,x11,[x9]
 cbz x10,.Lpost_csta_bad
 tst x10,#7
 b.ne .Lpost_csta_bad
 ldr x12,[x20,x21,lsl#3]
 cmp x11,x12
 b.lo .Lpost_csta_bad
 adds x13,x10,x12
 b.cs .Lpost_csta_bad
 add x21,x21,#1
 cmp x21,#10
 b.lo .Lpost_csta_ranges
 /* Both outputs must not overlap the argument table or any other span. */
 mov x21,#5
.Lpost_csta_output:
 add x9,x19,x21,lsl#4
 ldr x22,[x9]
 ldr x10,[x20,x21,lsl#3]
 add x23,x22,x10
 add x10,x19,#160
 cmp x22,x10
 b.hs 1f
 cmp x19,x23
 b.lo .Lpost_csta_bad
1:
 mov x24,#0
.Lpost_csta_other:
 cmp x24,x21
 b.eq 2f
 add x9,x19,x24,lsl#4
 ldr x10,[x9]
 ldr x11,[x20,x24,lsl#3]
 add x11,x10,x11
 cmp x22,x11
 b.hs 2f
 cmp x10,x23
 b.lo .Lpost_csta_bad
2:
 add x24,x24,#1
 cmp x24,#10
 b.lo .Lpost_csta_other
 add x21,x21,#1
 cmp x21,#7
 b.lo .Lpost_csta_output
 ldr x9,[x19,#112]
 mov x10,#35104
 ldr w10,[x9,x10]
 cmp w10,#1
 b.ne .Lpost_csta_bad
 mov x10,#35176
 ldr w10,[x9,x10]
 cmp w10,#1
 b.ne .Lpost_csta_bad
 ldr x9,[x19,#128]
 ldr w10,[x9]
 cbnz w10,.Lpost_csta_bad
 ldr x9,[x19,#144]
 mov x10,#6796
 ldr w10,[x9,x10]
 cbnz w10,.Lpost_csta_bad
 mov x10,#6808
 ldr w10,[x9,x10]
 cbnz w10,.Lpost_csta_bad
 ldr x0,[x19]
 ldr x1,[x19,#16]
 ldr x2,[x19,#32]
 ldr x3,[x19,#48]
 ldr x4,[x19,#64]
 ldr x5,[x19,#80]
 ldr x6,[x19,#96]
 bl md2asm_compute_selected_spectral_norms
 b .Lpost_csta_return
.Lpost_csta_bad:
 mov w0,#2
.Lpost_csta_return:
 ldr x18,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#128
 ret
.Lpost_csta_bad_leaf:
 mov w0,#2
 ret
.size md2asm_complete_selected_fresh_initialization,.-md2asm_complete_selected_fresh_initialization
.section .rodata
.p2align 3
.Lpost_csta_extents: .quad 17096,1556112,456,2992,24,24,20928,51512,24,7584
.section .note.GNU-stack,"",%progbits
