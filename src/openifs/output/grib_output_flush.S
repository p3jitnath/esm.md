/* Selected original GRIBIOFLUSH: ordinary closed-file output needs no flush.
 * Contract: skills/md2asm/references/openifs/output/grib_field_writers.md.
 * NOUTTYPE2 is the unsupported field-database route and fails closed.
 * This integer-only leaf preserves x18, saved registers, FPCR/FPSR and errno.
 */
.arch armv8.2-a
.text
.p2align 4
.global gribioflush_
.global md2asm_gribioflush_direct
.type gribioflush_,%function
.type md2asm_gribioflush_direct,%function
gribioflush_:
md2asm_gribioflush_direct:
 adrp x9,:got:__yommp0_MOD_nouttype
 ldr x9,[x9,:got_lo12:__yommp0_MOD_nouttype]
 ldr w9,[x9]
 cmp w9,#2
 b.eq .Lflush_reject
 adrp x9,.Lflush_count
 add x9,x9,:lo12:.Lflush_count
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ret
.Lflush_reject:
 mov x0,#116
 mov x8,#93
 svc #0
 brk #0
.size gribioflush_,.-gribioflush_
.size md2asm_gribioflush_direct,.-md2asm_gribioflush_direct
.global md2asm_grib_output_flush_count_get
.type md2asm_grib_output_flush_count_get,%function
md2asm_grib_output_flush_count_get:
 adrp x0,.Lflush_count
 ldr x0,[x0,:lo12:.Lflush_count]
 ret
.size md2asm_grib_output_flush_count_get,.-md2asm_grib_output_flush_count_get
.bss
.p2align 3
.Lflush_count: .zero 8
.section .note.GNU-stack,"",%progbits
