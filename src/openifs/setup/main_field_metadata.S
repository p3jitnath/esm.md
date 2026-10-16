/* Main field namespace from declared source literals and four live attributes.
 * Contract: skills/md2asm/references/openifs/setup/field_namespace_metadata.md
 * ABI: x0 records772800, x1 capacity, x2 attributes32, x3 dimensions8,
 * x4 dynamic_name_count0. Return w0=0 success or2 unsupported.
 * Mapped, disjoint and nonwrapping ranges are caller obligations.
 */
.text
.p2align 4
.global md2asm_initialize_main_field_metadata
.type md2asm_initialize_main_field_metadata,%function
md2asm_initialize_main_field_metadata:
 cbz x0,.Lfield_reject
 cbz x2,.Lfield_reject
 cbz x3,.Lfield_reject
 orr x9,x0,x2
 tst x9,#7
 b.ne .Lfield_reject
 tst x3,#3
 b.ne .Lfield_reject
 cbnz x4,.Lfield_reject
 movz x9,#0xcac0
 movk x9,#0xb,lsl #16
 cmp x1,x9
 b.lo .Lfield_reject
 mov x5,x0
 mov x10,x0
 mov w11,#4200
.Lfield_defaults:
 adrp x9,.Lfield_default
 add x9,x9,:lo12:.Lfield_default
 mov w12,#23
.Lfield_default_copy:
 ldr x13,[x9],#8
 str x13,[x10],#8
 subs w12,w12,#1
 b.ne .Lfield_default_copy
 subs w11,w11,#1
 b.ne .Lfield_defaults
 adrp x9,.Lfield_rows
 add x9,x9,:lo12:.Lfield_rows
 mov w11,#field_literal_count
.Lfield_literal:
 ldr x10,[x9],#8
 add x10,x5,x10
 mov w12,#23
.Lfield_literal_copy:
 ldr x13,[x9],#8
 str x13,[x10],#8
 subs w12,w12,#1
 b.ne .Lfield_literal_copy
 subs w11,w11,#1
 b.ne .Lfield_literal
 adrp x9,.Lfield_patches
 add x9,x9,:lo12:.Lfield_patches
 mov w11,#field_patch_count
.Lfield_patch:
 ldp w10,w12,[x9],#8
 ldr x13,[x2,x12]
 str x13,[x5,x10]
 subs w11,w11,#1
 b.ne .Lfield_patch
 mov w10,#11
 mov w11,#2
 stp w10,w11,[x3]
 mov w0,#0
 ret
.Lfield_reject:
 mov w0,#2
 ret
.size md2asm_initialize_main_field_metadata,.-md2asm_initialize_main_field_metadata
#include "field_metadata_literals.inc.S"
.section .note.GNU-stack,"",%progbits
