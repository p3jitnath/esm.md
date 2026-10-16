/* Ordered MINV_CALLER scaling and selected MINV_8 operations.
 * Contract skills/md2asm/references/openifs/dynamics/semi_implicit_mode_setup.md.
 * x0 order, x1 input, x2 output, x3 matrix scratch, x4 4N-real work,
 * x5 N-int pivots, x6 N-int condition work. Inputs are already admitted.
 * Public LAPACK owns factorisation, condition estimation and inversion. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_invert_scaled_mode_matrix
.type md2asm_invert_scaled_mode_matrix,%function
md2asm_invert_scaled_mode_matrix:
 sub sp,sp,#256
 stp x18,x19,[sp,#32]
 stp x20,x21,[sp,#48]
 stp x22,x23,[sp,#64]
 stp x24,x25,[sp,#80]
 stp x26,x27,[sp,#96]
 stp x29,x30,[sp,#112]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 mov x24,x5
 mov x25,x6
 str w19,[sp,#160]
 lsl w9,w19,#2
 str w9,[sp,#164]
 /* The source sums absolute diagonal values in increasing row order. */
 fmov d0,xzr
 mov x9,#0
 add x10,x19,#1
.Linverse_diagonal:
 mul x11,x9,x10
 ldr d1,[x20,x11,lsl#3]
 fabs d1,d1
 fadd d0,d0,d1
 add x9,x9,#1
 cmp x9,x19
 b.lo .Linverse_diagonal
 scvtf d1,x19
 fdiv d0,d0,d1
 str d0,[sp,#176]
 mov x26,#0
.Linverse_scale_row:
 mov x27,#0
.Linverse_scale_column:
 madd x9,x27,x19,x26
 ldr d1,[x20,x9,lsl#3]
 fcmp d0,#0.0
 b.le .Linverse_store_scaled
 fdiv d1,d1,d0
.Linverse_store_scaled:
 str d1,[x22,x9,lsl#3]
 add x27,x27,#1
 cmp x27,x19
 b.lo .Linverse_scale_column
 add x26,x26,#1
 cmp x26,x19
 b.lo .Linverse_scale_row
 /* The source 1-norm is the largest column sum of absolute values. */
 fmov d0,xzr
 mov x26,#0
.Linverse_norm_column:
 fmov d1,xzr
 mov x27,#0
.Linverse_norm_row:
 madd x9,x26,x19,x27
 ldr d2,[x22,x9,lsl#3]
 fabs d2,d2
 fadd d1,d1,d2
 add x27,x27,#1
 cmp x27,x19
 b.lo .Linverse_norm_row
 fcmp d0,d1
 fcsel d0,d0,d1,ge
 add x26,x26,#1
 cmp x26,x19
 b.lo .Linverse_norm_column
 str d0,[sp,#184]
 add x0,sp,#160
 mov x1,x0
 mov x2,x22
 mov x3,x0
 mov x4,x24
 add x5,sp,#168
 bl dgetrf_
 ldr w9,[sp,#168]
 tbnz w9,#31,.Linverse_failed
 adr x0,.Linverse_norm_name
 add x1,sp,#160
 mov x2,x22
 mov x3,x1
 add x4,sp,#184
 add x5,sp,#192
 mov x6,x23
 mov x7,x25
 add x9,sp,#168
 str x9,[sp]
 mov x9,#1
 str x9,[sp,#8]
 bl dgecon_
 ldr w9,[sp,#168]
 cbnz w9,.Linverse_failed
 ldr d0,[sp,#192]
 adr x9,.Linverse_tolerance
 ldr d1,[x9]
 fcmp d0,d1
 b.le .Linverse_failed
 add x0,sp,#160
 mov x1,x22
 mov x2,x0
 mov x3,x24
 mov x4,x23
 add x5,sp,#164
 add x6,sp,#168
 bl dgetri_
 ldr w9,[sp,#168]
 cbnz w9,.Linverse_failed
 ldr d0,[sp,#176]
 mov x26,#0
.Linverse_output_row:
 mov x27,#0
.Linverse_output_column:
 madd x9,x27,x19,x26
 ldr d1,[x22,x9,lsl#3]
 fcmp d0,#0.0
 b.le .Linverse_store_output
 fdiv d1,d1,d0
.Linverse_store_output:
 str d1,[x21,x9,lsl#3]
 add x27,x27,#1
 cmp x27,x19
 b.lo .Linverse_output_column
 add x26,x26,#1
 cmp x26,x19
 b.lo .Linverse_output_row
 mov w0,#0
 b .Linverse_return
.Linverse_failed:
 mov w0,#3
.Linverse_return:
 ldp x29,x30,[sp,#112]
 ldp x26,x27,[sp,#96]
 ldp x24,x25,[sp,#80]
 ldp x22,x23,[sp,#64]
 ldp x20,x21,[sp,#48]
 ldp x18,x19,[sp,#32]
 add sp,sp,#256
 ret
.size md2asm_invert_scaled_mode_matrix,.-md2asm_invert_scaled_mode_matrix
.section .rodata
.Linverse_norm_name: .ascii "1"
.p2align 3
/* 100 times the smallest positive normal FP64 value, as in MINV_CALLER. */
.Linverse_tolerance: .quad 0x0079000000000000
.section .note.GNU-stack,"",%progbits
