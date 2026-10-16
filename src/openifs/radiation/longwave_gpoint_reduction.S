/* Selected source-owned 256-to-140 longwave reduction.
   Contract: skills/md2asm/references/openifs/radiation/longwave_gpoint_reduction.md. */
.text
.p2align 4
.global md2asm_reduce_longwave_absorption
.type md2asm_reduce_longwave_absorption,%function
md2asm_reduce_longwave_absorption:
 cbz x0,.Lreduce_bad
 cbz x2,.Lreduce_bad
 orr x4,x0,x2
 tst x4,#7
 b.ne .Lreduce_bad
 mov x4,#0x0c80
 movk x4,#0x30,lsl #16
 cmp x1,x4
 b.lo .Lreduce_bad
 adds x5,x0,x4
 b.cs .Lreduce_bad
 mov x4,#0xc228
 movk x4,#0x12,lsl #16
 cmp x3,x4
 b.lo .Lreduce_bad
 adds x6,x2,x4
 b.cs .Lreduce_bad
 cmp x0,x6
 b.hs .Lreduce_disjoint
 cmp x2,x5
 b.lo .Lreduce_bad
.Lreduce_disjoint:
 mrs x4,fpcr
 cbnz x4,.Lreduce_bad
 stp x29,x30,[sp,#-112]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x19,x0
 mov x20,x2
 adrp x21,.Lmap_copy
 add x21,x21,:lo12:.Lmap_copy
 mov x22,#6
.Lmap_row:
 ldp x3,x4,[x21]
 ldr x5,[x21,#16]
 add x5,x5,x21
 add x3,x20,x3
.Lmap_word:
 ldr w6,[x5],#4
 str w6,[x3],#4
 subs x4,x4,#4
 b.ne .Lmap_word
 add x21,x21,#24
 subs x22,x22,#1
 b.ne .Lmap_row
 mov x0,x20
 bl md2asm_longwave_corrections_and_weights
 adrp x21,.Lfref_zero
 add x21,x21,:lo12:.Lfref_zero
 mov x22,#4
.Lzero_array:
 ldp x3,x4,[x21],#16
 add x3,x20,x3
.Lzero_column:
 mov x5,#140
 mov x6,x3
.Lzero_row:
 str xzr,[x6],#8
 subs x5,x5,#1
 b.ne .Lzero_row
 add x3,x3,#2048
 subs x4,x4,#1
 b.ne .Lzero_column
 subs x22,x22,#1
 b.ne .Lzero_array
 adrp x21,.Lreduction_plan
 add x21,x21,:lo12:.Lreduction_plan
 mov x22,#115
.Lreduce_field:
 ldp x0,x1,[x21]
 ldp x2,x3,[x21,#16]
 ldr x4,[x21,#32]
 add x0,x19,x0
 add x1,x20,x1
 add x2,x20,x2
 cbz x4,.Lweight_ready
 add x4,x20,x4
.Lweight_ready:
 add x5,x21,#40
 bl md2asm_reduce_longwave_field
 add x21,x21,#80
 subs x22,x22,#1
 b.ne .Lreduce_field
 mov w0,#0
 ldr x18,[sp,#96]
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#112
 ret
.Lreduce_bad:
 mov w0,#1
 ret
.size md2asm_reduce_longwave_absorption,.-md2asm_reduce_longwave_absorption
.section .rodata
.p2align 3
#include "longwave_reduction_plan.inc.S"
.section .note.GNU-stack,"",%progbits
