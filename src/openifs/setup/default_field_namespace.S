/* Selected READ_DYNAMIC_NAMESPACE input effect for an absent optional file.
 * Contract: skills/md2asm/references/openifs/setup/field_container_attachment.md
 * x0 output int32 count; return0 if absent,2 if present or inaccessible.
 * The caller supplies mapped writable4B. No original input namespace is read.
 */
.text
.p2align 4
.global md2asm_require_default_field_namespace
.type md2asm_require_default_field_namespace,%function
md2asm_require_default_field_namespace:
 cbz x0,.Lnamespace_reject
 tst x0,#3
 b.ne .Lnamespace_reject
 mov x9,x0
.Lnamespace_retry:
 mov x0,#-100
 adrp x1,.Lnamespace_name
 add x1,x1,:lo12:.Lnamespace_name
 mov x2,#0
 mov x8,#48
 svc #0
 cmn x0,#4
 b.eq .Lnamespace_retry
 cmn x0,#2
 b.ne .Lnamespace_reject
 str wzr,[x9]
 mov w0,#0
 ret
.Lnamespace_reject:
 mov w0,#2
 ret
.size md2asm_require_default_field_namespace,.-md2asm_require_default_field_namespace
.section .rodata
.Lnamespace_name:.asciz "dynamic_namespace"
.section .note.GNU-stack,"",%progbits
