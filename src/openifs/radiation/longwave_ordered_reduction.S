/* Source-ordered longwave sums. Contract: skills/md2asm/references/openifs/radiation/longwave_gpoint_reduction.md. */
.text
.p2align 4
.global md2asm_reduce_longwave_field
.hidden md2asm_reduce_longwave_field
.type md2asm_reduce_longwave_field,%function
/* Internal leaf: x0 source, x1 destination, x2 group counts, x3 groups,
   x4 weights or zero, x5 five-word shape. All bounds are fixed by the parent. */
md2asm_reduce_longwave_field:
 ldp x6,x7,[x5]
 ldp x8,x9,[x5,#16]
 ldr x10,[x5,#32]
.Lfield_cell:
 mov x11,#0
 mov x12,#0
.Lfield_group:
 ldr w13,[x2,x11,lsl #2]
 fmov d0,xzr
.Lfield_term:
 madd x14,x12,x8,x0
 ldr d1,[x14]
 cbz x4,.Lfield_add
 ldr d2,[x4,x12,lsl #3]
 fmul d1,d1,d2
.Lfield_add:
 fadd d0,d0,d1
 add x12,x12,#1
 subs w13,w13,#1
 b.ne .Lfield_term
 madd x14,x11,x10,x1
 str d0,[x14]
 add x11,x11,#1
 cmp x11,x3
 b.lo .Lfield_group
 add x0,x0,x7
 add x1,x1,x9
 subs x6,x6,#1
 b.ne .Lfield_cell
 ret
.size md2asm_reduce_longwave_field,.-md2asm_reduce_longwave_field
.section .note.GNU-stack,"",%progbits
