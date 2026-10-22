/* Source defaults: one/ECMWF19 tables, or N137 pressure-only publication.
 * Contract: skills/md2asm/references/openifs/setup/hybrid_coordinate_defaults.md.
 * w0=canonical ECMWF flag,w1=N,x2=A[0:N],x3=B[0:N],x4=P0out.
 * Return w0=0, or2 before output mutation. No allocation or FP arithmetic.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_default_hybrid_coefficients
.type md2asm_initialize_default_hybrid_coefficients,%function
md2asm_initialize_default_hybrid_coefficients:
 cmp w0,#1
 b.hi .Lhybrid_default_reject
 cmp w1,#1
 b.eq .Lhybrid_default_buffers
 cmp w1,#137
 b.eq .Lhybrid_default_buffers
 cmp w0,#1
 b.ne .Lhybrid_default_reject
 cmp w1,#19
 b.ne .Lhybrid_default_reject
.Lhybrid_default_buffers:
 cbz x2,.Lhybrid_default_reject
 cbz x3,.Lhybrid_default_reject
 cbz x4,.Lhybrid_default_reject
 orr x9,x2,x3
 orr x9,x9,x4
 tst x9,#7
 b.ne .Lhybrid_default_reject
 mov w1,w1
 add x9,x1,#1
 lsl x9,x9,#3
 adds x5,x2,x9
 b.cs .Lhybrid_default_reject
 adds x6,x3,x9
 b.cs .Lhybrid_default_reject
 adds x7,x4,#8
 b.cs .Lhybrid_default_reject
 cmp x2,x6
 b.hs .Lhybrid_default_first_pressure
 cmp x3,x5
 b.lo .Lhybrid_default_reject
.Lhybrid_default_first_pressure:
 cmp x2,x7
 b.hs .Lhybrid_default_second_pressure
 cmp x4,x5
 b.lo .Lhybrid_default_reject
.Lhybrid_default_second_pressure:
 cmp x3,x7
 b.hs .Lhybrid_default_table
 cmp x4,x6
 b.lo .Lhybrid_default_reject
.Lhybrid_default_table:
 cmp w1,#137
 b.eq .Lhybrid_default_store_pressure
 cmp w1,#1
 b.ne .Lhybrid_default_nineteen
 adrp x5,md2asm_hybrid_defaults_1
 add x5,x5,:lo12:md2asm_hybrid_defaults_1
 b .Lhybrid_default_copy_setup
.Lhybrid_default_nineteen:
 adrp x5,md2asm_hybrid_defaults_19
 add x5,x5,:lo12:md2asm_hybrid_defaults_19
.Lhybrid_default_copy_setup:
 add x6,x5,x9
 mov x10,#0
.Lhybrid_default_copy:
 ldr x11,[x5,x10]
 ldr x12,[x6,x10]
 str x11,[x2,x10]
 str x12,[x3,x10]
 add x10,x10,#8
 cmp x10,x9
 b.lo .Lhybrid_default_copy
.Lhybrid_default_store_pressure:
 adr x9,.Lhybrid_default_pressure
 ldr x10,[x9]
 str x10,[x4]
 mov w0,#0
 ret
.Lhybrid_default_reject:
 mov w0,#2
 ret
.size md2asm_initialize_default_hybrid_coefficients,.-md2asm_initialize_default_hybrid_coefficients
.p2align 3
.Lhybrid_default_pressure: .double 101325.0
.section .note.GNU-stack,"",%progbits
