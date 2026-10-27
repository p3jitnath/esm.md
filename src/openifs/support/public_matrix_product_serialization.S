/* Serialize public DGEMM calls that share the observed packing-buffer service.
 * The application binary interface forwards thirteen addresses and two lengths.
 * All 56 incoming stack bytes are copied unchanged. The private frame is 96B. */
.text
.p2align 4
.global md2asm_public_dgemm_serialized
.type md2asm_public_dgemm_serialized,%function
md2asm_public_dgemm_serialized:
 sub sp,sp,#96
 stp x18,x30,[sp,#64]
 stp x19,x20,[sp,#80]
 ldp x9,x10,[sp,#96]
 stp x9,x10,[sp]
 ldp x9,x10,[sp,#112]
 stp x9,x10,[sp,#16]
 ldp x9,x10,[sp,#128]
 stp x9,x10,[sp,#32]
 ldr x9,[sp,#144]
 str x9,[sp,#48]
 adrp x19,:got:md2asm_owned_public_matrix_lock
 ldr x19,[x19,:got_lo12:md2asm_owned_public_matrix_lock]
 mov w10,#1
 sevl
1:
 wfe
2:
 ldaxr w9,[x19]
 cbnz w9,1b
 stxr w11,w10,[x19]
 cbnz w11,2b
 bl dgemm_
 stlr wzr,[x19]
 sev
 ldp x19,x20,[sp,#80]
 ldp x18,x30,[sp,#64]
 add sp,sp,#96
 ret
.size md2asm_public_dgemm_serialized,.-md2asm_public_dgemm_serialized
.bss
.p2align 6
.global md2asm_owned_public_matrix_lock
.type md2asm_owned_public_matrix_lock,%object
md2asm_owned_public_matrix_lock: .zero 8
.size md2asm_owned_public_matrix_lock,8
.section .note.GNU-stack,"",%progbits
