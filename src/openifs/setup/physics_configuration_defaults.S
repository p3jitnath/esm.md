/* Contract: skills/md2asm/references/openifs/setup/selected_physics_configuration.md. */
/* Selected SU0PHY state stores after complete parent validation.
 * x0 points at 17 {owned record pointer, capacity} pairs (272 bytes).
 * The complete bounds and disjointness contract belongs to the parent.
 * Integer leaf: x0..x17 and NZCV are scratch; x18 and FP state are unchanged.
 * Source-assigned bytes only; every other payload and descriptor is kept.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_default_remaining_physics_configuration
.type md2asm_default_remaining_physics_configuration,%function
md2asm_default_remaining_physics_configuration:
 adr x1,.Lphysics_source_operations
 adr x2,.Lphysics_source_operations_end
.Lphysics_operation:
 ldrh w9,[x1]
 ldrh w10,[x1,#2]
 ldr w11,[x1,#4]
 ldr x12,[x1,#8]
 add x13,x0,x9,lsl#4
 ldr x13,[x13]
 add x13,x13,x10
 cmp w11,#8
 b.eq .Lphysics_store8
 cmp w11,#4
 b.eq .Lphysics_store4
 strb w12,[x13]
 b .Lphysics_next
.Lphysics_store8:
 str x12,[x13]
 b .Lphysics_next
.Lphysics_store4:
 str w12,[x13]
.Lphysics_next:
 add x1,x1,#16
 cmp x1,x2
 b.lo .Lphysics_operation
 /* TMSE's source-declared maximum remains a live owned input. */
 ldr x9,[x0,#16]
 ldr w10,[x9,#12]
 str w10,[x9,#16]
 /* SUSCM assigns every element of NSCMTS(0:240). */
 ldr x9,[x0,#240]
 add x9,x9,#56
 mov w10,#241
.Lphysics_scm_times:
 str wzr,[x9],#4
 subs w10,w10,#1
 b.ne .Lphysics_scm_times
 mov w0,#0
 ret
.size md2asm_default_remaining_physics_configuration,.-md2asm_default_remaining_physics_configuration
.section .rodata
#include "physics_configuration_operations.S"
.section .note.GNU-stack,"",%progbits
