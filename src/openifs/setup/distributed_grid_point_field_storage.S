/* Qualified live-provider contract: skills/md2asm/references/openifs/setup/operational_enclosing_model_storage.md. */
/* Contract: skills/md2asm/references/openifs/setup/grid_point_field_storage.md. */
/* Owned selected TGFL allocation, ZERO_YOMGFL and DEALXMO release stages.
 * initialize(x0 zero record1096B,x1 cfg7,x2 borrowed owned YGFL)->w0 status.
 * No original callable, module data, type, vtable or state-packet input.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_gridpoint_field
.type md2asm_initialize_gridpoint_field,%function
md2asm_initialize_gridpoint_field:
 cbz x0,.Ltgfl_initialize_reject
 cbz x2,.Ltgfl_initialize_reject
 orr x9,x0,x2
 tst x9,#7
 b.ne .Ltgfl_initialize_reject
 cbz x1,.Ltgfl_initialize_reject
 tst x1,#3
 b.ne .Ltgfl_initialize_reject
 ldr w9,[x1]
 sub w9,w9,#1
 cmp w9,#63
 b.hi .Ltgfl_initialize_reject
 ldr w9,[x1,#4]
 sub w9,w9,#1
 cmp w9,#63
 b.hi .Ltgfl_initialize_reject
 ldr w9,[x1,#8]
 sub w9,w9,#1
 cmp w9,#127
 b.hi .Ltgfl_initialize_reject
 ldr w9,[x1,#12]
 cmp w9,#8
 b.ne .Ltgfl_initialize_reject
 ldr w9,[x1,#16]
 cmp w9,#2
 b.ne .Ltgfl_initialize_reject
 ldr w9,[x1,#20]
 cbnz w9,.Ltgfl_initialize_reject
 ldr w9,[x1,#24]
 cbnz w9,.Ltgfl_initialize_reject
 mrs x9,fpcr
 cbnz x9,.Ltgfl_initialize_reject
 mov x9,#0
.Ltgfl_check_fresh:
 ldr x10,[x0,x9]
 cbnz x10,.Ltgfl_initialize_reject
 add x9,x9,#8
 cmp x9,#1096
 b.lo .Ltgfl_check_fresh
 sub sp,sp,#160
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mrs x9,fpcr
 str x9,[sp,#104]
 mrs x9,fpsr
 str x9,[sp,#112]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 ldr w27,[x20]
 ldr w28,[x20,#4]
 ldr w9,[x20,#8]
 str w9,[sp,#128]
 bl __errno_location
 mov x22,x0
 ldr w23,[x22]
 str x21,[x19,#1088]
 mov x26,#0
.Ltgfl_allocate:
 adr x9,.Ltgfl_owner_fields
 ldr w24,[x9,x26,lsl#2]
 mul x25,x27,x28
 mul x25,x25,x24
 ldr w9,[sp,#128]
 mul x25,x25,x9
 lsl x25,x25,#3
 mov x0,#1
 cmp x25,#0
 csel x0,x25,x0,ne
 bl malloc
 cbz x0,.Ltgfl_initialize_failed
 mov x1,x0
 adr x9,.Ltgfl_owner_offsets
 ldr w9,[x9,x26,lsl#2]
 add x0,x19,x9
 mov w2,w27
 mov w3,w28
 mov w4,w24
 ldr w5,[sp,#128]
 bl .Ltgfl_rank_four_descriptor
 add x26,x26,#1
 cmp x26,#4
 b.lo .Ltgfl_allocate
 mov w0,#0
 b .Ltgfl_initialize_restore
.Ltgfl_initialize_failed:
 mov x0,x19
 bl md2asm_release_gridpoint_field
 mov w0,#1
.Ltgfl_initialize_restore:
 str w23,[x22]
 ldr x9,[sp,#104]
 msr fpcr,x9
 ldr x9,[sp,#112]
 msr fpsr,x9
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldr x18,[sp,#96]
 ldp x29,x30,[sp]
 add sp,sp,#160
 ret
.Ltgfl_initialize_reject:
 mov w0,#2
 ret
.size md2asm_initialize_gridpoint_field,.-md2asm_initialize_gridpoint_field

/* Source GNU descriptor: base, offset, width, dtype, span, four dimensions. */
.Ltgfl_rank_four_descriptor:
 uxtw x2,w2
 uxtw x3,w3
 uxtw x4,w4
 uxtw x5,w5
 str x1,[x0]
 mul x6,x2,x3
 mul x7,x6,x4
 add x8,x2,x6
 add x8,x8,x7
 add x8,x8,#1
 neg x8,x8
 str x8,[x0,#8]
 mov x8,#8
 str x8,[x0,#16]
 str wzr,[x0,#24]
 mov w8,#0x304
 str w8,[x0,#28]
 mov x8,#8
 str x8,[x0,#32]
 mov x8,#1
 stp x8,x8,[x0,#40]
 str x2,[x0,#56]
 stp x2,x8,[x0,#64]
 str x3,[x0,#80]
 stp x6,x8,[x0,#88]
 str x4,[x0,#104]
 stp x7,x8,[x0,#112]
 str x5,[x0,#128]
 ret

.p2align 4
.global md2asm_zero_gridpoint_field
.type md2asm_zero_gridpoint_field,%function
md2asm_zero_gridpoint_field:
 cbz x0,.Ltgfl_zero_reject
 tst x0,#7
 b.ne .Ltgfl_zero_reject
 mov x9,#0
 mov x17,#136
.Ltgfl_zero_owner:
 madd x10,x9,x17,x0
 ldr x11,[x10]
 cbz x11,.Ltgfl_zero_next
 mov x12,#1
 add x13,x10,#40
 mov x14,#0
.Ltgfl_zero_extent:
 ldp x15,x16,[x13,#8]
 sub x16,x16,x15
 add x16,x16,#1
 mul x12,x12,x16
 add x13,x13,#24
 add x14,x14,#1
 cmp x14,#4
 b.lo .Ltgfl_zero_extent
 cbz x12,.Ltgfl_zero_next
.Ltgfl_zero_words:
 str xzr,[x11],#8
 subs x12,x12,#1
 b.ne .Ltgfl_zero_words
.Ltgfl_zero_next:
 add x9,x9,#1
 cmp x9,#5
 b.lo .Ltgfl_zero_owner
 mov w0,#0
 ret
.Ltgfl_zero_reject:
 mov w0,#2
 ret
.size md2asm_zero_gridpoint_field,.-md2asm_zero_gridpoint_field

.p2align 4
.global md2asm_release_gridpoint_field
.type md2asm_release_gridpoint_field,%function
md2asm_release_gridpoint_field:
 cbz x0,.Ltgfl_release_reject
 tst x0,#7
 b.ne .Ltgfl_release_reject
 sub sp,sp,#96
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x18,[sp,#64]
 mov x19,x0
 mrs x24,fpcr
 mrs x25,fpsr
 bl __errno_location
 mov x20,x0
 ldr w21,[x20]
 adr x22,.Ltgfl_owner_offsets
 mov x23,#0
.Ltgfl_release_owner:
 ldr w9,[x22,x23,lsl#2]
 ldr x0,[x19,x9]
 cbz x0,.Ltgfl_release_next
 bl free
 ldr w9,[x22,x23,lsl#2]
 str xzr,[x19,x9]
.Ltgfl_release_next:
 add x23,x23,#1
 cmp x23,#4
 b.lo .Ltgfl_release_owner
 str w21,[x20]
 msr fpcr,x24
 msr fpsr,x25
 mov w0,#0
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x18,[sp,#64]
 ldp x29,x30,[sp]
 add sp,sp,#96
 ret
.Ltgfl_release_reject:
 mov w0,#2
 ret
.size md2asm_release_gridpoint_field,.-md2asm_release_gridpoint_field
.section .rodata
.p2align 3
.Ltgfl_owner_offsets: .word 0,272,408,544
.Ltgfl_owner_fields: .word 8,2,0,0
.section .note.GNU-stack,"",%progbits

/* Raw operational TGFL storage, fixed one-thread layout.
 * Contract: skills/md2asm/references/openifs/setup/operational_grid_point_field_storage.md.
 * x0 fresh TGFL[1096], x1 int32 controls[7], x2 borrowed GFL[1359136].
 * Controls are live17,137,97055,9,3,0,0 for the qualified world-four local domain. Existing zero/release entries apply.
 */
.text
.p2align 4
.global md2asm_initialize_distributed_gridpoint_field
.type md2asm_initialize_distributed_gridpoint_field,%function
md2asm_initialize_distributed_gridpoint_field:
 cbz x0,.Loperational_tgfl_initialize_reject
 cbz x2,.Loperational_tgfl_initialize_reject
 orr x9,x0,x2
 tst x9,#7
 b.ne .Loperational_tgfl_initialize_reject
 cbz x1,.Loperational_tgfl_initialize_reject
 tst x1,#3
 b.ne .Loperational_tgfl_initialize_reject
 ldr w9,[x1]
 cmp w9,#17
 b.ne .Loperational_tgfl_initialize_reject
 ldr w9,[x1,#4]
 cmp w9,#137
 b.ne .Loperational_tgfl_initialize_reject
 ldr w9,[x1,#8]
 movz w10,#(97055&65535)
 movk w10,#(97055>>16),lsl#16
 cmp w9,w10
 b.ne .Loperational_tgfl_initialize_reject
 ldr w9,[x1,#12]
 cmp w9,#9
 b.ne .Loperational_tgfl_initialize_reject
 ldr w9,[x1,#16]
 cmp w9,#3
 b.ne .Loperational_tgfl_initialize_reject
 ldr w9,[x1,#20]
 cbnz w9,.Loperational_tgfl_initialize_reject
 ldr w9,[x1,#24]
 cbnz w9,.Loperational_tgfl_initialize_reject
 mrs x9,fpcr
 cbnz x9,.Loperational_tgfl_initialize_reject
 mov x9,#0
.Loperational_tgfl_check_fresh:
 ldr x10,[x0,x9]
 cbnz x10,.Loperational_tgfl_initialize_reject
 add x9,x9,#8
 cmp x9,#1096
 b.lo .Loperational_tgfl_check_fresh
 sub sp,sp,#160
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mrs x9,fpcr
 str x9,[sp,#104]
 mrs x9,fpsr
 str x9,[sp,#112]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 ldr w27,[x20]
 ldr w28,[x20,#4]
 ldr w9,[x20,#8]
 str w9,[sp,#128]
 bl __errno_location
 mov x22,x0
 ldr w23,[x22]
 str x21,[x19,#1088]
 mov x26,#0
.Loperational_tgfl_allocate:
 adr x9,.Loperational_tgfl_owner_fields
 ldr w24,[x9,x26,lsl#2]
 mul x25,x27,x28
 mul x25,x25,x24
 ldr w9,[sp,#128]
 mul x25,x25,x9
 lsl x25,x25,#3
 mov x0,#1
 cmp x25,#0
 csel x0,x25,x0,ne
 bl malloc
 cbz x0,.Loperational_tgfl_initialize_failed
 mov x1,x0
 adr x9,.Ltgfl_owner_offsets
 ldr w9,[x9,x26,lsl#2]
 add x0,x19,x9
 mov w2,w27
 mov w3,w28
 mov w4,w24
 ldr w5,[sp,#128]
 bl .Ltgfl_rank_four_descriptor
 add x26,x26,#1
 cmp x26,#4
 b.lo .Loperational_tgfl_allocate
 mov w0,#0
 b .Loperational_tgfl_initialize_restore
.Loperational_tgfl_initialize_failed:
 mov x0,x19
 bl md2asm_release_gridpoint_field
 mov w0,#1
.Loperational_tgfl_initialize_restore:
 str w23,[x22]
 ldr x9,[sp,#104]
 msr fpcr,x9
 ldr x9,[sp,#112]
 msr fpsr,x9
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldr x18,[sp,#96]
 ldp x29,x30,[sp]
 add sp,sp,#160
 ret
.Loperational_tgfl_initialize_reject:
 mov w0,#2
 ret
.size md2asm_initialize_distributed_gridpoint_field,.-md2asm_initialize_distributed_gridpoint_field

.section .rodata
.p2align 2
.Loperational_tgfl_owner_fields: .word 9,3,0,0
.section .note.GNU-stack,"",%progbits
