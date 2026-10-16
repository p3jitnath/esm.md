/* Source-ordered correction and relative-weight tables. Contract: skills/md2asm/references/openifs/radiation/longwave_gpoint_reduction.md. */
.text
.p2align 4
.global md2asm_longwave_corrections_and_weights
.hidden md2asm_longwave_corrections_and_weights
.type md2asm_longwave_corrections_and_weights,%function
/* Internal leaf: x0 complete owned output. */
md2asm_longwave_corrections_and_weights:
 mov x1,#3328
 add x1,x0,x1
 add x2,x1,#1608
 fmov d0,#1.0
 str d0,[x1]
 str d0,[x2]
 str d0,[x1,#1600]
 str d0,[x2,#1600]
 adrp x3,.Lcorrection_step
 ldr d1,[x3,:lo12:.Lcorrection_step]
 mov x3,#1
.Lcorrection_loop:
 scvtf d2,w3
 fmul d2,d1,d2
 fsqrt d3,d2
 fdiv d4,d3,d2
 fsub d5,d0,d3
 fsub d6,d0,d2
 fdiv d5,d5,d6
 str d4,[x1,x3,lsl #3]
 str d5,[x2,x3,lsl #3]
 add x3,x3,#1
 cmp x3,#200
 b.lo .Lcorrection_loop
 /* x1 WT, x2 NGN, x3 RWGT; consume each group's contiguous WT values. */
 add x1,x0,#3200
 add x2,x0,#128
 mov x3,#6544
 add x3,x0,x3
 mov x4,#0
.Lweight_band:
 ldr w5,[x0,x4,lsl #2]
 mov x6,#0
 cmp w5,#16
 b.eq .Lweight_unit
.Lweight_group:
 ldr w7,[x2],#4
 mov x8,x7
 fmov d1,xzr
 mov x9,x6
.Lweight_sum:
 ldr d2,[x1,x9,lsl #3]
 fadd d1,d1,d2
 add x9,x9,#1
 subs x8,x8,#1
 b.ne .Lweight_sum
.Lweight_divide:
 ldr d2,[x1,x6,lsl #3]
 fdiv d2,d2,d1
 str d2,[x3],#8
 add x6,x6,#1
 cmp x6,x9
 b.lo .Lweight_divide
 cmp x6,#16
 b.lo .Lweight_group
 b .Lweight_next
.Lweight_unit:
 str d0,[x3],#8
 add x6,x6,#1
 cmp x6,#16
 b.lo .Lweight_unit
 add x2,x2,#64
.Lweight_next:
 add x4,x4,#1
 cmp x4,#16
 b.lo .Lweight_band
 ret
.size md2asm_longwave_corrections_and_weights,.-md2asm_longwave_corrections_and_weights
.section .rodata
.p2align 3
.Lcorrection_step: .double 0.005
.section .note.GNU-stack,"",%progbits
