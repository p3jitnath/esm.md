/* Continue the accepted raw prefix through source-selected grid shape.
 * Contract: skills/md2asm/references/openifs/radiation/runtime_radiation_grid_from_prefix.md. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_create_runtime_radiation_grid_from_prefix
.type md2asm_create_runtime_radiation_grid_from_prefix,%function
md2asm_create_runtime_radiation_grid_from_prefix:
 stp x29,x30,[sp,#-80]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 str x18,[sp,#64]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 mov x24,x5
 mov x0,x21
 mov x1,x22
 mov x2,x23
 mov x3,x24
 bl md2asm_publish_runtime_radiation_interpolation_controls
 cbnz w0,.Lreturn
 mov x0,x19
 mov x1,x20
 mov x2,x21
 mov x3,x22
 bl md2asm_create_runtime_radiation_grid_shape
.Lreturn:
 ldr x18,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#80
 ret
.size md2asm_create_runtime_radiation_grid_from_prefix,.-md2asm_create_runtime_radiation_grid_from_prefix
.section .note.GNU-stack,"",%progbits
