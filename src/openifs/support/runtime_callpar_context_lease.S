/* Contract: skills/md2asm/references/openifs/support/runtime_callpar_context_lease.md.
 * x0 lease96,x1 capacity,x2 cfg67616,x3 MODEL4275088,x4 partition4096,x5 step4.
 * The first80B are context; its16B hook policy is contained at+80.
 * Inputs and canonical owners already have their actual accepted producers.
 * Only output separation is added; unchanged children retain their own guards.
 * Return0 publishes all96B;2 keeps them unchanged, retaining earlier child effects.
 * Integer wrapper,80B own frame/240B maximum with unchanged coupling child.
 * Preserve x18,saved integer/vector registers,FPCR,FPSR anderrno. */
.arch armv8.2-a
.text
.p2align 4
.macro CONST reg,value
 movz \reg,#(\value&65535)
 movk \reg,#(\value>>16),lsl#16
.endm
.macro OWNER reg,symbol
 adrp \reg,:got:\symbol
 ldr \reg,[\reg,:got_lo12:\symbol]
.endm
.macro SEPARATE ptr,bytes,mask
 cbz \ptr,.Lcontext_bad
 tst \ptr,#\mask
 b.ne .Lcontext_bad
 CONST x9,\bytes
 adds x10,\ptr,x9
 b.cs .Lcontext_bad
 cmp x19,x10
 b.hs .Lcontext_separate\@
 cmp \ptr,x24
 b.lo .Lcontext_bad
.Lcontext_separate\@:
.endm
.global md2asm_initialize_runtime_callpar_context_lease
.type md2asm_initialize_runtime_callpar_context_lease,%function
md2asm_initialize_runtime_callpar_context_lease:
 mrs x9,fpcr
 cbnz x9,.Lcontext_bad_leaf
 stp x29,x30,[sp,#-80]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 mov x19,x0
 mov x20,x2
 mov x21,x3
 mov x22,x4
 mov x23,x5
 cbz x19,.Lcontext_bad
 tst x19,#7
 b.ne .Lcontext_bad
 cmp x1,#96
 b.lo .Lcontext_bad
 adds x24,x19,#96
 b.cs .Lcontext_bad
 SEPARATE x20,67616,7
 SEPARATE x21,4275088,7
 SEPARATE x22,4096,7
 SEPARATE x23,4,3
 ldr x8,[x20,#16]
 SEPARATE x8,20400,7
 ldr x8,[x20,#8]
 SEPARATE x8,529288,7
 OWNER x8,md2asm_owned_initial_physical_constants
 SEPARATE x8,520,7
 OWNER x8,md2asm_owned_runtime_convection_clock
 SEPARATE x8,360,7
 OWNER x8,md2asm_owned_surface_runtime_inputs
 SEPARATE x8,32,7
 OWNER x8,md2asm_owned_dynamical_namespace
 SEPARATE x8,320,7
 OWNER x8,md2asm_owned_ecmwf_thermal_namespace
 SEPARATE x8,1920,7
 OWNER x8,md2asm_owned_physics_runtime_data
 SEPARATE x8,608,7
 OWNER x8,md2asm_owned_forecast_scalar_data
 SEPARATE x8,112,7
 OWNER x8,md2asm_owned_shared_false_hook_policy
 SEPARATE x8,4,3
 ldr w9,[x8]
 cbnz w9,.Lcontext_bad
 /* Actual coupling child supplies both pointers at private stack bytes64..79. */
 mov x0,x20
 CONST x1,67616
 mov x2,x21
 CONST x3,4275088
 mov x4,x22
 mov x5,#4096
 add x6,sp,#64
 mov x7,#16
 bl md2asm_bind_operational_inactive_coupling_context
 cbnz w0,.Lcontext_return
 mov x0,x20
 CONST x1,67616
 mov x2,x23
 bl md2asm_publish_operational_convection_step
 cbnz w0,.Lcontext_return
 bl md2asm_initialize_canonical_physics_runtime_inputs
 cbnz w0,.Lcontext_return
 /* Publish only after all accepted children succeed. The policy is in this lease. */
 OWNER x9,md2asm_owned_initial_physical_constants
 OWNER x10,md2asm_owned_runtime_convection_clock
 add x10,x10,#36
 add x11,x19,#80
 ldp x12,x13,[sp,#64]
 OWNER x14,md2asm_owned_dynamical_namespace
 OWNER x15,md2asm_owned_ecmwf_thermal_namespace
 OWNER x16,md2asm_owned_shared_false_hook_policy
 stp x9,x10,[x19]
 stp x11,x12,[x19,#16]
 stp x13,xzr,[x19,#32]
 stp xzr,xzr,[x19,#48]
 stp x14,x15,[x19,#64]
 stp x16,xzr,[x19,#80]
 mov w0,#0
.Lcontext_return:
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#80
 ret
.Lcontext_bad:
 mov w0,#2
 b .Lcontext_return
.Lcontext_bad_leaf:
 mov w0,#2
 ret
.size md2asm_initialize_runtime_callpar_context_lease,.-md2asm_initialize_runtime_callpar_context_lease
.section .note.GNU-stack,"",%progbits
