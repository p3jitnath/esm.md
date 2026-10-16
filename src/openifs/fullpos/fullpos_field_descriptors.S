// Contract: skills/md2asm/references/openifs/fullpos/field_descriptors.md.
/* Selected SUAFN owns declaration defaults, SUAFN1, SUAFN2 and quiet SUAFN3. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_selected_fullpos_field_descriptors
.type md2asm_initialize_selected_fullpos_field_descriptors,%function
md2asm_initialize_selected_fullpos_field_descriptors:
 sub sp,sp,#96
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 str x18,[sp,#64]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 mrs x9,fpcr
 cbnz x9,.Lparent_bad
 mov x0,x22
 mov x1,x23
 bl md2asm_initialize_fullpos_field_descriptor_defaults
 cbnz w0,.Lparent_return
 mov x0,x19
 mov x1,x20
 mov x2,x21
 mov x3,x22
 mov x4,x23
 bl md2asm_initialize_selected_fullpos_field_defaults
 cbnz w0,.Lparent_return
 ldr x24,[x21,#80]
 mov x0,x22
 mov x1,x23
 mov x2,x24
 bl md2asm_initialize_selected_fullpos_field_equivalences
 cbnz w0,.Lparent_return
 mov x0,x22
 mov x1,x23
 mov x2,x24
 bl md2asm_check_selected_fullpos_field_descriptors
 b .Lparent_return
.Lparent_bad:
 mov w0,#2
.Lparent_return:
 ldr x18,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#96
 ret
.section .note.GNU-stack,"",%progbits
