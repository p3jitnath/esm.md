/* Original SUDEFO_VV1 five-pointer ABI; no original callable or data input.
 * Contract: skills/md2asm/references/openifs/setup/hybrid_coordinate_defaults.md.
 */
.arch armv8.2-a
.text
.p2align 4
.global sudefo_vv1_
.type sudefo_vv1_,%function
sudefo_vv1_:
 sub sp,sp,#32
 stp x29,x30,[sp]
 stp x19,x18,[sp,#16]
 mov x29,sp
 cbz x0,.Lhybrid_defaults_native_fail
 cbz x1,.Lhybrid_defaults_native_fail
 orr x9,x0,x1
 tst x9,#3
 b.ne .Lhybrid_defaults_native_fail
 ldr w0,[x0]
 ldr w1,[x1]
 bl md2asm_initialize_default_hybrid_coefficients
 cbnz w0,.Lhybrid_defaults_native_fail
 adrp x9,.Lhybrid_defaults_native_count
 add x9,x9,:lo12:.Lhybrid_defaults_native_count
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ldp x19,x18,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#32
 ret
.Lhybrid_defaults_native_fail:
 mov w0,#121
 bl _exit
 brk #0
.size sudefo_vv1_,.-sudefo_vv1_
.p2align 4
.global md2asm_default_hybrid_native_count_get
.type md2asm_default_hybrid_native_count_get,%function
md2asm_default_hybrid_native_count_get:
 adrp x9,.Lhybrid_defaults_native_count
 ldr x0,[x9,:lo12:.Lhybrid_defaults_native_count]
 ret
.size md2asm_default_hybrid_native_count_get,.-md2asm_default_hybrid_native_count_get
.bss
.p2align 3
.Lhybrid_defaults_native_count: .zero 8
.section .note.GNU-stack,"",%progbits
