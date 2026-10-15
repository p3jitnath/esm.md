// Solver contract skills/md2asm/references/openifs/setup/postprocessing_atmosphere.md.
/* Post-processing atmosphere, local revision 1.
 * Contract: skills/md2asm/references/openifs/setup/postprocessing_atmosphere.md in this directory.
 * x0 output288, x1 layers288, x2 pressure[levels], x3 physical32,
 * x4 levels1..256. w0 returns zero or two. All spans are mapped/aligned.
 * SUSTA section 2, source nearest-level tie and rounded arithmetic order.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_adjust_postprocessing_atmosphere
.type md2asm_adjust_postprocessing_atmosphere,%function
md2asm_adjust_postprocessing_atmosphere:
 mrs x9,fpcr
 cbnz x9,.Lpost_reject
 sub x9,x4,#1
 cmp x9,#255
 b.hi .Lpost_reject
 orr x9,x0,x1
 orr x9,x9,x2
 orr x9,x9,x3
 tst x9,#7
 b.ne .Lpost_reject
 cbz x0,.Lpost_reject
 cbz x1,.Lpost_reject
 cbz x2,.Lpost_reject
 cbz x3,.Lpost_reject
 adds x10,x0,#288
 b.cs .Lpost_reject
 adds x11,x1,#288
 b.cs .Lpost_reject
 lsl x12,x4,#3
 adds x12,x2,x12
 b.cs .Lpost_reject
 adds x13,x3,#32
 b.cs .Lpost_reject
 cmp x0,x11
 b.hs .Lpost_pair1
 cmp x1,x10
 b.lo .Lpost_reject
.Lpost_pair1:
 cmp x0,x12
 b.hs .Lpost_pair2
 cmp x2,x10
 b.lo .Lpost_reject
.Lpost_pair2:
 cmp x0,x13
 b.hs .Lpost_guard
 cmp x3,x10
 b.lo .Lpost_reject
.Lpost_guard:
 mov x9,#0
 movz x10,#0x7ff0,lsl#48
.Lpost_pressure_guard:
 ldr x11,[x2,x9,lsl#3]
 cbz x11,.Lpost_reject
 cmp x11,x10
 b.hs .Lpost_reject
 add x9,x9,#1
 cmp x9,x4
 b.lo .Lpost_pressure_guard
 sub sp,sp,#160
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x18,[sp,#64]
 stp d8,d9,[sp,#80]
 stp d10,d11,[sp,#96]
 stp d12,d13,[sp,#112]
 stp d14,d15,[sp,#128]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 mov x9,#0
.Lpost_copy:
 ldr x10,[x20,x9,lsl#3]
 str x10,[x19,x9,lsl#3]
 add x9,x9,#1
 cmp x9,#36
 b.lo .Lpost_copy
 ldr d0,[x21]
 ldr d1,[x20,#224]
 fsub d0,d0,d1
 fabs d15,d0
 mov x24,#0
 mov x25,#1
.Lpost_search:
 cmp x25,x23
 b.hs .Lpost_threshold
 ldr d0,[x21,x25,lsl#3]
 fsub d0,d0,d1
 fabs d0,d0
 fcmp d0,d15
 b.gt .Lpost_search_next
 fmov d15,d0
 mov x24,x25
.Lpost_search_next:
 add x25,x25,#1
 b .Lpost_search
.Lpost_threshold:
 adrp x9,.Lpost_5000
 ldr d0,[x9,:lo12:.Lpost_5000]
 fcmp d15,d0
 b.gt .Lpost_done
 ldp d8,d9,[x22]
 ldr d10,[x19,#72]
 ldr d11,[x19,#144]
 ldr d0,[x21,x24,lsl#3]
 str d0,[x19,#224]
 ldr d1,[x22,#24]
 fdiv d0,d0,d1
 fneg d1,d10
 fmul d1,d1,d9
 fdiv d1,d1,d8
 bl md2asm_pow_original_rounding_candidate
 fmov d1,#1.0
 fsub d0,d0,d1
 fdiv d1,d11,d10
 fmul d0,d1,d0
 fmov d2,xzr
 fadd d12,d2,d0
 str d12,[x19,#8]
 fsub d0,d12,d2
 fmul d0,d10,d0
 fadd d13,d11,d0
 str d13,[x19,#152]
 ldr d0,[x20,#160]
 fsub d0,d0,d13
 ldr d1,[x20,#16]
 fsub d1,d1,d12
 fdiv d0,d0,d1
 str d0,[x19,#80]
 mov x25,#1
.Lpost_recompute:
 add x9,x19,#72
 ldr d10,[x9,x25,lsl#3]
 add x10,x25,#1
 ldr d0,[x19,x10,lsl#3]
 ldr d1,[x19,x25,lsl#3]
 fsub d14,d0,d1
 add x9,x19,#144
 ldr d11,[x9,x25,lsl#3]
 fneg d1,d8
 fdiv d1,d1,d9
 fcmp d10,#0.0
 b.eq .Lpost_isothermal
 fmul d0,d10,d14
 fadd d12,d11,d0
 fdiv d0,d0,d11
 fmov d2,#1.0
 fadd d0,d2,d0
 fdiv d1,d1,d10
 bl md2asm_pow_original_rounding_candidate
 b .Lpost_pressure
.Lpost_isothermal:
 fmov d12,d11
 fdiv d0,d1,d11
 fmul d0,d0,d14
 bl md2asm_exp_original_rounding
.Lpost_pressure:
 add x9,x19,#216
 ldr d1,[x9,x25,lsl#3]
 fmul d0,d1,d0
 add x10,x25,#1
 str d0,[x9,x10,lsl#3]
 add x9,x19,#144
 str d12,[x9,x10,lsl#3]
 add x25,x25,#1
 cmp x25,#8
 b.lo .Lpost_recompute
.Lpost_done:
 mov w0,#0
 ldp d14,d15,[sp,#128]
 ldp d12,d13,[sp,#112]
 ldp d10,d11,[sp,#96]
 ldp d8,d9,[sp,#80]
 ldp x25,x18,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#160
 ret
.Lpost_reject:
 mov w0,#2
 ret
.size md2asm_adjust_postprocessing_atmosphere,.-md2asm_adjust_postprocessing_atmosphere
.section .rodata
.p2align 3
.Lpost_5000: .double 5000.0
.section .note.GNU-stack,"",%progbits
