/* Contract skills/md2asm/references/openifs/dynamics/runtime_distributed_spectral_norms.md.
 * Live bounds preserve the qualified source arithmetic and instruction order. */
.text
.p2align 4
.macro NCALL symbol
 str x18,[sp,#240]
 bl \symbol
 ldr x18,[sp,#240]
.endm
.macro NVAL reg,base,offset,index,shift
 mov x9,#\offset
 add x9,\base,x9
 ldr x10,[x9,#8]
 ldr x11,[x9,#40]
 madd x10,\index,x11,x10
 ldr x9,[x9]
 ldr \reg,[x9,x10,lsl #\shift]
.endm
.macro NROW reg,desc,level,coefficient
 ldr x9,[\desc,#8]
 ldr x10,[\desc,#40]
 add x11,\level,#1
 madd x9,x11,x10,x9
 ldr x10,[\desc,#64]
 madd x9,\coefficient,x10,x9
 ldr x10,[\desc]
 ldr \reg,[x10,x9,lsl #3]
.endm
.macro NGLOBAL reg,name
 adrp x9,:got:\name
 ldr x9,[x9,:got_lo12:\name]
 ldr \reg,[x9]
.endm

// Custom internal ABI x0 Geometry, x1 rank-two field, x2 kinetic metric,
// x3 level count, x4 output level-by-wave matrix. All preserved registers survive.
.global md2asm_runtime_spectral_norm_matrix
.type md2asm_runtime_spectral_norm_matrix,%function
md2asm_runtime_spectral_norm_matrix:
 sub sp,sp,#256
 stp x19,x20,[sp,#32]
 stp x21,x22,[sp,#48]
 stp x23,x24,[sp,#64]
 stp x25,x26,[sp,#80]
 stp x27,x28,[sp,#96]
 stp x29,x30,[sp,#112]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 ldrsw x17,[x19,#5172]
 ldrsw x30,[x19,#5212]
 mov x24,#0
 adr x9,.Lfloor
 ldr d7,[x9]
.Lmatrix_wave:
 cmp x24,x30
 b.ge .Lmatrix_done
 add x14,x24,#1
 NVAL w13,x19,3912,x14,2
 uxtw x29,w13
 mov x25,#0
.Lmatrix_level:
 cmp x25,x22
 b.ge .Lmatrix_nextwave
 fmov d0,xzr
 mov x26,x29
 NVAL w15,x19,3720,x29,2
 sxtw x27,w15
.Lmatrix_degree:
 cmp x26,x17
 b.gt .Lmatrix_store
 NROW d1,x20,x25,x27
 fmul d1,d1,d1
 cbz x29,.Lmatrix_real
 add x28,x27,#1
 NROW d2,x20,x25,x28
 fmul d2,d2,d2
 fadd d1,d1,d2
.Lmatrix_real:
 fmov d3,#1.0
 cbz x21,.Lmatrix_metric_ready
 NVAL d3,x19,4168,x26,3
 fneg d3,d3
.Lmatrix_metric_ready:
 cbz x29,.Lmatrix_single_weight
 fmov d4,#2.0
 fmul d3,d4,d3
.Lmatrix_single_weight:
 fmul d1,d3,d1
 fadd d0,d0,d1
 add x27,x27,#2
 add x26,x26,#1
 b .Lmatrix_degree
.Lmatrix_store:
 fmaxnm d0,d7,d0
 madd x9,x24,x22,x25
 str d0,[x23,x9,lsl #3]
 add x25,x25,#1
 b .Lmatrix_level
.Lmatrix_nextwave:
 add x24,x24,#1
 b .Lmatrix_wave
.Lmatrix_done:
 ldp x19,x20,[sp,#32]
 ldp x21,x22,[sp,#48]
 ldp x23,x24,[sp,#64]
 ldp x25,x26,[sp,#80]
 ldp x27,x28,[sp,#96]
 ldp x29,x30,[sp,#112]
 add sp,sp,#256
 ret
.Lmatrix_bad:
 NCALL abort
.size md2asm_runtime_spectral_norm_matrix,.-md2asm_runtime_spectral_norm_matrix
// x0 matrix, x1 levels, x2 is zero for square-root norm and one for energy.
// x3 per-level result and x4 global wave count. Return the ordered mean in d0.
.global md2asm_runtime_spectral_norm_average
.type md2asm_runtime_spectral_norm_average,%function
md2asm_runtime_spectral_norm_average:
 mov x7,x4
 fmov d0,xzr
 mov x4,#0
.Laverage_level:
 fmov d1,xzr
 mov x5,#0
.Laverage_wave:
 madd x6,x5,x1,x4
 ldr d2,[x0,x6,lsl #3]
 fadd d1,d1,d2
 add x5,x5,#1
 cmp x5,x7
 b.lt .Laverage_wave
 cbnz x2,.Laverage_no_root
 fsqrt d1,d1
.Laverage_no_root:
 str d1,[x3,x4,lsl #3]
 fadd d0,d0,d1
 add x4,x4,#1
 cmp x4,x1
 b.lt .Laverage_level
 scvtf d2,x1
 fdiv d0,d0,d2
 ret
.size md2asm_runtime_spectral_norm_average,.-md2asm_runtime_spectral_norm_average
.section .rodata
.p2align 3
.Lfloor: .quad 0x0079000000000000
.section .note.GNU-stack,"",%progbits
