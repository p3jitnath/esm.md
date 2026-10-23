/* Owned operational upper-air initial-state construction, revision 1.
 * Contract: skills/md2asm/references/openifs/input/owned_operational_upper_air_initial_state.md.
 * x0 readable path4096, x1 borrowed persistent namespace1359136, x2 output8.
 * All spans are mapped, nonwrapping and disjoint; namespace/output align8.
 * Only 69,048 incoming padding bytes are set before unchanged file placement.
 * Frame80, alignment16; preserve x18 and AAPCS64 saved registers/status.
 * Success transfers the context to the caller; paired operational release frees it.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_create_loaded_operational_upper_air_state
.type md2asm_create_loaded_operational_upper_air_state,%function
md2asm_create_loaded_operational_upper_air_state:
 cbz x0,.Lowned_upper_reject
 cbz x1,.Lowned_upper_reject
 cbz x2,.Lowned_upper_reject
 orr x9,x1,x2
 tst x9,#7
 b.ne .Lowned_upper_reject
 mov x16,#0xbd20
 movk x16,#0x14,lsl#16
 adds x10,x1,x16
 b.cs .Lowned_upper_reject
 adds x11,x2,#8
 b.cs .Lowned_upper_reject
 cmp x1,x11
 b.hs .Lowned_upper_scan
 cmp x2,x10
 b.lo .Lowned_upper_reject
.Lowned_upper_scan:
 mov x9,x0
 mov w12,#4096
.Lowned_upper_path_byte:
 ldrb w13,[x9]
 cbz w13,.Lowned_upper_path_end
 adds x9,x9,#1
 b.cs .Lowned_upper_reject
 subs w12,w12,#1
 b.ne .Lowned_upper_path_byte
 b .Lowned_upper_reject
.Lowned_upper_path_end:
 adds x9,x9,#1
 b.cs .Lowned_upper_reject
 cmp x0,x10
 b.hs .Lowned_upper_path_slot
 cmp x1,x9
 b.lo .Lowned_upper_reject
.Lowned_upper_path_slot:
 cmp x0,x11
 b.hs .Lowned_upper_mode
 cmp x2,x9
 b.lo .Lowned_upper_reject
.Lowned_upper_mode:
 mrs x9,fpcr
 cbnz x9,.Lowned_upper_reject
 sub sp,sp,#80
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 str xzr,[sp,#64]
 adr x0,.Lowned_upper_configuration
 mov x1,x20
 add x2,sp,#64
 bl md2asm_create_operational_gridpoint_field_context
 cbnz w0,.Lowned_upper_constructor_error
 ldr x22,[sp,#64]
 ldr x10,[x22]
 // The copied fields occupy seven adjacent field slots in the final block.
 movz x12,#27648
 movk x12,#10294,lsl#16
 movk x12,#15,lsl#32
 add x13,x10,x12
 mov w14,#959
.Lowned_upper_padding_level:
 stp xzr,xzr,[x13]
 stp xzr,xzr,[x13,#16]
 stp xzr,xzr,[x13,#32]
 stp xzr,xzr,[x13,#48]
 str xzr,[x13,#64]
 add x13,x13,#136
 subs w14,w14,#1
 b.ne .Lowned_upper_padding_level
 mov x0,x19
 ldr x1,[x22]
 movz x2,#64200
 movk x2,#10296,lsl#16
 movk x2,#15,lsl#32
 bl md2asm_load_operational_upper_air_initial_state
 cbnz w0,.Lowned_upper_load_error
 str x22,[x21]
 mov w0,#0
 b .Lowned_upper_return
.Lowned_upper_constructor_error:
 add w0,w0,#16
 b .Lowned_upper_return
.Lowned_upper_load_error:
 add w23,w0,#32
 mov x0,x22
 bl md2asm_release_operational_gridpoint_field_context
 mov w0,w23
.Lowned_upper_return:
 ldp x22,x23,[sp,#48]
 ldp x20,x21,[sp,#32]
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#80
 ret
.Lowned_upper_reject:
 mov w0,#1
 ret
.size md2asm_create_loaded_operational_upper_air_state,.-md2asm_create_loaded_operational_upper_air_state
.section .rodata
.p2align 3
.Lowned_upper_configuration: .word 17,137,388217,9,3,0,0
.section .note.GNU-stack,"",%progbits
