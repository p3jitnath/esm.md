/* Complete inactive field-description defaults after nine-field registration.
 * x0: owned, aligned grid-field record[1359136], with fresh inactive ranges.
 * Return 0 on success, or 2 before any store when a checked input is refused.
 * All 53 family tables and ordered stores retain the selected helper body.
 * Contract: skills/md2asm/references/openifs/setup/operational_inactive_grid_defaults.md.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_operational_inactive_grid_defaults
.type md2asm_initialize_operational_inactive_grid_defaults,%function
md2asm_initialize_operational_inactive_grid_defaults:
 cbz x0,.Linactive_reject
 tst x0,#7
 b.ne .Linactive_reject
 mrs x9,fpcr
 cbnz x9,.Linactive_reject
 mov x9,#0xbd20
 movk x9,#0x14,lsl#16
 adds x9,x0,x9
 b.cs .Linactive_reject
 ldr w9,[x0]
 cmp w9,#9
 b.ne .Linactive_reject
 ldr w9,[x0,#124]
 cmp w9,#2
 b.ne .Linactive_reject
 ldr w9,[x0,#304]
 cmp w9,#5
 b.ne .Linactive_reject
 adrp x1,.Linactive_families
 add x1,x1,:lo12:.Linactive_families
 mov w2,#53
.Linactive_validate_family:
 ldp w9,w10,[x1]
 ldr w11,[x1,#8]
 mul w10,w10,w11
 add x9,x0,x9
 add x10,x9,x10
.Linactive_validate_words:
 ldr w11,[x9],#4
 cbnz w11,.Linactive_reject
 cmp x9,x10
 b.lo .Linactive_validate_words
 add x1,x1,#24
 subs w2,w2,#1
 b.ne .Linactive_validate_family
 adrp x1,.Linactive_families
 add x1,x1,:lo12:.Linactive_families
 mov w2,#53
.Linactive_apply_family:
 ldp w9,w5,[x1]
 ldp w6,w8,[x1,#8]
 ldr x7,[x1,#16]
 adrp x10,.Linactive_operations
 add x10,x10,:lo12:.Linactive_operations
 add x7,x10,x7
 add x3,x0,x9
 mov w4,#0
.Linactive_apply_record:
 mov x9,x7
 mov w10,w8
 cbz w10,.Linactive_record_done
.Linactive_apply_operation:
 ldrh w11,[x9]
 ldrh w12,[x9,#2]
 ldrh w15,[x9,#4]
 ldr x13,[x9,#8]
 add x14,x3,x11
 cbz w15,.Linactive_constant
 cmp w15,#1
 b.eq .Linactive_index_code
 adrp x15,.Linactive_names
 add x15,x15,:lo12:.Linactive_names
 add x15,x15,x13
 ldp x16,x17,[x15]
 stp x16,x17,[x14]
 ldrh w15,[x9,#4]
 cmp w15,#2
 b.eq .Linactive_operation_done
 /* Decimal Iw.w names use integer division; no Fortran formatter is called. */
 ldrh w12,[x9,#6]
 ubfx w15,w12,#8,#8
 and w12,w12,#255
 add x14,x14,x15
 add x14,x14,x12
 add w13,w4,#1
 mov w15,#10
.Linactive_decimal_digit:
 udiv w16,w13,w15
 msub w17,w16,w15,w13
 add w17,w17,#48
 strb w17,[x14,#-1]!
 mov w13,w16
 subs w12,w12,#1
 b.ne .Linactive_decimal_digit
 b .Linactive_operation_done
.Linactive_index_code:
 add w13,w13,w4
 str w13,[x14]
 b .Linactive_operation_done
.Linactive_constant:
 cmp w12,#4
 b.ne .Linactive_constant_eight
 str w13,[x14]
 b .Linactive_operation_done
.Linactive_constant_eight:
 str x13,[x14]
.Linactive_operation_done:
 add x9,x9,#16
 subs w10,w10,#1
 b.ne .Linactive_apply_operation
.Linactive_record_done:
 add x3,x3,x6
 add w4,w4,#1
 cmp w4,w5
 b.lo .Linactive_apply_record
 add x1,x1,#24
 subs w2,w2,#1
 b.ne .Linactive_apply_family
 /* Fixed-index overrides and final scalar choices retain exact source order. */
 adrp x1,.Linactive_overrides
 add x1,x1,:lo12:.Linactive_overrides
 adrp x9,.Linactive_override_count
 ldr w2,[x9,:lo12:.Linactive_override_count]
.Linactive_override:
 ldr w9,[x1]
 ldrh w10,[x1,#4]
 ldrh w11,[x1,#6]
 ldr x12,[x1,#8]
 add x13,x0,x9
 cbnz w11,.Linactive_override_name
 cmp w10,#4
 b.ne .Linactive_override_eight
 str w12,[x13]
 b .Linactive_override_done
.Linactive_override_eight:
 str x12,[x13]
 b .Linactive_override_done
.Linactive_override_name:
 adrp x14,.Linactive_names
 add x14,x14,:lo12:.Linactive_names
 add x14,x14,x12
 ldp x15,x16,[x14]
 stp x15,x16,[x13]
.Linactive_override_done:
 add x1,x1,#16
 subs w2,w2,#1
 b.ne .Linactive_override
 mov w0,#0
 ret
.Linactive_reject:
 mov w0,#2
 ret
.size md2asm_initialize_operational_inactive_grid_defaults,.-md2asm_initialize_operational_inactive_grid_defaults
#include "selected_inactive_grid_default_tables.inc.S"
