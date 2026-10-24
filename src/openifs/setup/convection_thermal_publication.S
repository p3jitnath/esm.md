/* Contract: skills/md2asm/references/openifs/setup/convection_parameter_setup.md.
 * Publish the source-ordered SUCUMF thermal outputs into the live namespace.
 * x0 owns 1920 writable bytes. x1 borrows 24 read-only bytes.
 * Both complete ranges are aligned to eight bytes and disjoint.
 * Call only after their declared producers. No floating-point operation. */
.arch armv8.2-a
.text
.p2align 2
.global md2asm_publish_convection_thermal_parameters
.type md2asm_publish_convection_thermal_parameters,%function
md2asm_publish_convection_thermal_parameters:
 ldr x9,[x1]
 str x9,[x0,#112]
 ldp x10,x11,[x1,#8]
 str x10,[x0,#144]
 str x11,[x0,#160]
 ret
.size md2asm_publish_convection_thermal_parameters,.-md2asm_publish_convection_thermal_parameters
.section .note.GNU-stack,"",%progbits
