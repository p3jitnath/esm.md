/* Contract: skills/md2asm/references/openifs/setup/ecmwf_physics_setup.md.
 * Release only resources owned by this complete selected SUPHEC context.
 * x0 MODEL4275088,x1 context208,x2 radiation context. int0/2.
 * Preserve incoming errno and FPCR/FPSR across every release service. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_release_selected_ecmwf_physics
.type md2asm_release_selected_ecmwf_physics,%function
md2asm_release_selected_ecmwf_physics:
 cbz x0,.Lrelease_bad
 cbz x1,.Lrelease_bad
 cbz x2,.Lrelease_bad
 orr x3,x0,x1
 orr x3,x3,x2
 tst x3,#7
 b.ne .Lrelease_bad
 ldr x3,[x1,#192]
 tst x3,#0xfffffffffffffff0
 b.ne .Lrelease_bad
 sub sp,sp,#160
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov w22,#0
 mrs x9,fpcr
 mrs x10,fpsr
 stp x9,x10,[sp,#112]
 bl __errno_location
 ldr x18,[sp,#96]
 str x0,[sp,#128]
 ldr w9,[x0]
 str w9,[sp,#136]
 ldr x9,[x20,#192]
 tbz x9,#3,.Lrelease_optimization
 ldr x0,[x20,#176]
 bl md2asm_release_selected_surface_parameters
 ldr x18,[sp,#96]
 cbz w0,.Lrelease_surface_done
 mov w22,w0
 b .Lrelease_optimization
.Lrelease_surface_done:
 mov x9,#0x1558
 movk x9,#0x18,lsl #16
 str xzr,[x19,x9]
 ldr x9,[x20,#192]
 and x9,x9,#0xfffffffffffffff7
 str x9,[x20,#192]
.Lrelease_optimization:
 ldr x9,[x20,#192]
 tbz x9,#1,.Lrelease_radiation
 ldr x0,[x20,#96]
 mov x1,#1368
 bl md2asm_release_surface_optimization_parameters
 ldr x18,[sp,#96]
 cbz w0,.Lrelease_optimization_done
 mov w22,w0
 b .Lrelease_radiation
.Lrelease_optimization_done:
 ldr x9,[x20,#192]
 and x9,x9,#0xfffffffffffffffd
 str x9,[x20,#192]
.Lrelease_radiation:
 ldr x9,[x20,#192]
 tbz x9,#2,.Lrelease_cloud
 mov x0,x19
 mov x1,x21
 bl md2asm_release_selected_radiation_setup
 ldr x18,[sp,#96]
 cbz w0,.Lrelease_radiation_done
 mov w22,w0
 b .Lrelease_cloud
.Lrelease_radiation_done:
 ldr x9,[x20,#192]
 and x9,x9,#0xfffffffffffffffb
 str x9,[x20,#192]
.Lrelease_cloud:
 ldr x9,[x20,#192]
 tbz x9,#0,.Lrelease_complete
 mov x9,#0x1560
 movk x9,#0x18,lsl #16
 add x0,x19,x9
 mov x1,#264
 bl md2asm_release_cloud_parameter_eta
 ldr x18,[sp,#96]
 cbz w0,.Lrelease_cloud_done
 mov w22,w0
 b .Lrelease_complete
.Lrelease_cloud_done:
 ldr x9,[x20,#192]
 and x9,x9,#0xfffffffffffffffe
 str x9,[x20,#192]
.Lrelease_complete:
 ldr x9,[sp,#128]
 ldr w10,[sp,#136]
 str w10,[x9]
 ldp x9,x10,[sp,#112]
 msr fpcr,x9
 msr fpsr,x10
 mov w0,w22
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#160
 ret
.Lrelease_bad:
 mov w0,#2
 ret
.size md2asm_release_selected_ecmwf_physics,.-md2asm_release_selected_ecmwf_physics
.section .note.GNU-stack,"",%progbits
