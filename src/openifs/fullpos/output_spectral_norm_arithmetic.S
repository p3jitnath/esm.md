/* Source build for the qualified private forecast graph.
 * Contract: skills/md2asm/references/openifs/dynamics/private_forecast_graph_sources.md.
 * Preserve the original interface, ordered arithmetic, and caller-owned storage. */
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
.global md2asm_output_spectral_norm_matrix_7358525
.type md2asm_output_spectral_norm_matrix_7358525,%function
md2asm_output_spectral_norm_matrix_7358525:
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
 mov x24,#0
.Loutputmatrix_wave:
 cmp x24,#22
 b.ge .Loutputmatrix_done
 add x14,x24,#1
 NVAL w13,x19,48,x14,2
 cmp w13,w24
 b.ne .Loutputmatrix_bad
 mov x25,#0
.Loutputmatrix_level:
 cmp x25,x22
 b.ge .Loutputmatrix_nextwave
 fmov d0,xzr
 mov x26,x24
 NVAL w15,x19,368,x24,2
 sxtw x27,w15
.Loutputmatrix_degree:
 cmp x26,#21
 b.gt .Loutputmatrix_store
 NROW d1,x20,x25,x27
 fmul d1,d1,d1
 cbz x24,.Loutputmatrix_real
 add x28,x27,#1
 NROW d2,x20,x25,x28
 fmul d2,d2,d2
 fadd d1,d1,d2
.Loutputmatrix_real:
 fmov d3,#1.0
.Loutputmatrix_metric_ready:
 cbz x24,.Loutputmatrix_single_weight
 fmov d4,#2.0
 fmul d3,d4,d3
.Loutputmatrix_single_weight:
 fmul d1,d3,d1
 fadd d0,d0,d1
 add x27,x27,#2
 add x26,x26,#1
 b .Loutputmatrix_degree
.Loutputmatrix_store:
 madd x9,x24,x22,x25
 str d0,[x23,x9,lsl #3]
 add x25,x25,#1
 b .Loutputmatrix_level
.Loutputmatrix_nextwave:
 add x24,x24,#1
 b .Loutputmatrix_wave
.Loutputmatrix_done:
 ldp x19,x20,[sp,#32]
 ldp x21,x22,[sp,#48]
 ldp x23,x24,[sp,#64]
 ldp x25,x26,[sp,#80]
 ldp x27,x28,[sp,#96]
 ldp x29,x30,[sp,#112]
 add sp,sp,#256
 ret
.Loutputmatrix_bad:
 NCALL abort
.size md2asm_output_spectral_norm_matrix_7358525,.-md2asm_output_spectral_norm_matrix_7358525

.section .note.GNU-stack,"",%progbits
